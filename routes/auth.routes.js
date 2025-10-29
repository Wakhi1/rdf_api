const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const bcryptUtils = require('../utils/bcrypt');
const jwtUtils = require('../utils/jwt');
const emailUtils = require('../utils/email');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { validateBody, schemas } = require('../middleware/validation.middleware');
const { requireRole } = require('../middleware/role.middleware');
const crypto = require('crypto');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user (SUPER_USER only)
 * @access  Private (SUPER_USER)
 */
router.post('/register', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateBody(schemas.register), 
  async (req, res) => {
    let connection;
    try {
      const { 
        username, email, password, role, first_name, last_name, phone,
        region_id, tinkhundla_id, umphakatsi_id, ministry 
      } = req.body;
      
      console.log('Starting user registration for:', username);
      
      // Check if username already exists
      const existingUsername = await db.getOne(
        'SELECT id FROM users WHERE username = ?',
        [username]
      );
      
      if (existingUsername) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Username already exists'
        });
      }
      
      // Check if email already exists
      const existingEmail = await db.getOne(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );
      
      if (existingEmail) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Email already exists'
        });
      }
      
      // Generate a temporary password if not provided
      const finalPassword = password || bcryptUtils.generateRandomPassword(12);
      
      // Hash password
      const hashedPassword = await bcryptUtils.hashPassword(finalPassword);
      
      // Begin transaction
      connection = await db.beginTransaction();
      console.log('Transaction started');
      
      // Create user
      console.log('Inserting into users table...');
      const userResult = await connection.query(
        `INSERT INTO users (
          username, email, password, role, first_name, last_name,
          phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          username, email, hashedPassword, role, first_name, last_name,
          phone, 'active', region_id, tinkhundla_id, umphakatsi_id, ministry
        ]
      );
      
      const userId = userResult[0].insertId;
      console.log('User created with ID:', userId);
      
      // Create default notification preferences
      console.log('Inserting into user_notification_preferences...');
      await connection.query(
        `INSERT INTO user_notification_preferences (
          user_id, email_notifications, sms_notifications,
          application_updates, committee_reminders, system_announcements
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [userId, true, false, true, true, true]
      );
      console.log('Notification preferences created');
      
      // Log activity - with detailed error handling
      console.log('Attempting to log activity...');
      try {
        // Let's first check what we're inserting
        const activityData = [
          req.user.id, 
          'user_created', 
          'users', 
          userId, 
          JSON.stringify({ role, creator: req.user.id }), 
          req.ip, 
          req.get('User-Agent')
        ];
        
        console.log('Activity log data:', activityData);
        
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, description, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          activityData
        );
        console.log('Activity log created successfully');
      } catch (logError) {
        console.error('Activity log error details:', {
          message: logError.message,
          sqlMessage: logError.sqlMessage,
          code: logError.code,
          errno: logError.errno,
          sqlState: logError.sqlState,
          sql: logError.sql
        });
        throw logError; // Re-throw to trigger rollback
      }
      
      // Commit transaction
      await db.commit(connection);
      console.log('Transaction committed');
      
      // Send welcome email with credentials
      try {
        const user = { id: userId, email, first_name, last_name, username };
        await emailUtils.sendWelcomeEmail(user, finalPassword);
        console.log('Welcome email sent');
      } catch (emailError) {
        console.warn('Failed to send welcome email:', emailError.message);
        // Don't fail the registration if email fails
      }
      
      // Return success
      return res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: {
          id: userId,
          username,
          email,
          role,
          first_name,
          last_name
        }
      });
      
    } catch (error) {
      console.error('Registration error caught:', {
        message: error.message,
        sqlMessage: error.sqlMessage,
        code: error.code,
        errno: error.errno,
        sqlState: error.sqlState,
        stack: error.stack
      });
      
      // Rollback transaction if it was started
      if (connection) {
        try {
          await db.rollback(connection);
          console.log('Transaction rolled back');
        } catch (rollbackError) {
          console.error('Rollback failed:', rollbackError.message);
        }
      }
      
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? error.message : 'Registration failed'
      });
    }
  }
);

/**
 * @route   POST /api/auth/login
 * @desc    Login a user
 * @access  Public
 */
router.post('/login', validateBody(schemas.login), async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Find user by username or email
    let user;
    if (username) {
      user = await db.getOne(
        'SELECT * FROM users WHERE username = ?',
        [username]
      );
    } else {
      user = await db.getOne(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
    }
    
    // Check if user exists
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid credentials'
      });
    }
    
    // Check if user is active
    if (user.status !== 'active' && user.status !== 'temporary') {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Account is inactive or suspended'
      });
    }
    
    // Verify password
    const passwordValid = await bcryptUtils.verifyPassword(password, user.password);
    if (!passwordValid) {
      // Log failed login
      await logger.activity(
        user.id, 
        'login_failed', 
        'users', 
        user.id, 
        { reason: 'Invalid password' }, 
        req.ip, 
        req.get('User-Agent')
      );
      
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid credentials'
      });
    }
    
    // If user is EOG, fetch EOG data
    let eogData = null;
    if (user.role === 'EOG') {
      const eogUser = await db.getOne(
        'SELECT * FROM eog_users WHERE user_id = ?',
        [user.id]
      );
      
      if (eogUser) {
        const eog = await db.getOne(
          'SELECT * FROM eogs WHERE id = ?',
          [eogUser.eog_id]
        );
        
        if (eog) {
          // Check if temporary account has expired
          if (eog.status === 'temporary' && eog.temp_account_expires) {
            const expiryDate = new Date(eog.temp_account_expires);
            if (expiryDate < new Date()) {
              return res.status(401).json({
                success: false,
                error: 'Account Expired',
                message: 'Your temporary EOG account has expired'
              });
            }
            
            // Calculate days remaining
            const daysRemaining = Math.ceil((expiryDate - new Date()) / (1000 * 60 * 60 * 24));
            eog.days_remaining = daysRemaining;
          }
          
          eogData = eog;
          
          // Add region, tinkhundla, and umphakatsi names
          const region = await db.getOne(
            'SELECT name FROM regions WHERE id = ?',
            [eog.region_id]
          );
          
          const tinkhundla = await db.getOne(
            'SELECT name FROM tinkhundla WHERE id = ?',
            [eog.tinkhundla_id]
          );
          
          const umphakatsi = await db.getOne(
            'SELECT name FROM imiphakatsi WHERE id = ?',
            [eog.umphakatsi_id]
          );
          
          eogData.region = region ? region.name : null;
          eogData.tinkhundla = tinkhundla ? tinkhundla.name : null;
          eogData.umphakatsi = umphakatsi ? umphakatsi.name : null;
        }
      }
    }
    
    // Create session and tokens
    const session = await jwtUtils.createSession(user, req.ip, req.get('User-Agent'));
    
    // Log successful login
    await logger.activity(
      user.id, 
      'login_success', 
      'users', 
      user.id, 
      null, 
      req.ip, 
      req.get('User-Agent')
    );
    
    // Get region, tinkhundla, and umphakatsi names
    let regionName = null;
    let tinkhundlaName = null;
    let umphakatsiName = null;
    
    if (user.region_id) {
      const region = await db.getOne(
        'SELECT name FROM regions WHERE id = ?',
        [user.region_id]
      );
      regionName = region ? region.name : null;
    }
    
    if (user.tinkhundla_id) {
      const tinkhundla = await db.getOne(
        'SELECT name FROM tinkhundla WHERE id = ?',
        [user.tinkhundla_id]
      );
      tinkhundlaName = tinkhundla ? tinkhundla.name : null;
    }
    
    if (user.umphakatsi_id) {
      const umphakatsi = await db.getOne(
        'SELECT name FROM imiphakatsi WHERE id = ?',
        [user.umphakatsi_id]
      );
      umphakatsiName = umphakatsi ? umphakatsi.name : null;
    }
    
    // Return user data and tokens
    return res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          first_name: user.first_name,
          last_name: user.last_name,
          phone: user.phone,
          region: regionName,
          tinkhundla: tinkhundlaName,
          umphakatsi: umphakatsiName,
          ministry: user.ministry,
          status: user.status
        },
        eog: eogData,
        access_token: session.accessToken,
        refresh_token: session.refreshToken,
        expires_at: session.expiresAt
      }
    });
  } catch (error) {
    logger.error(`Login error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/auth/refresh
 * @desc    Refresh access token
 * @access  Public
 */
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;
    
    if (!refresh_token) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'Refresh token is required'
      });
    }
    
    // Refresh token
    const result = await jwtUtils.refreshAccessToken(refresh_token);
    
    if (!result) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid or expired refresh token'
      });
    }
    
    // Return new access token
    return res.status(200).json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        access_token: result.accessToken
      }
    });
  } catch (error) {
    logger.error(`Token refresh error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/auth/logout
 * @desc    Logout a user
 * @access  Private
 */
router.post('/logout', authenticate, async (req, res) => {
  try {
    const { refresh_token } = req.body;
    
    if (!refresh_token) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'Refresh token is required'
      });
    }
    
    // Invalidate session
    await jwtUtils.invalidateSession(req.user.id, refresh_token);
    
    // Log logout
    await logger.activity(
      req.user.id, 
      'logout', 
      'users', 
      req.user.id, 
      null, 
      req.ip, 
      req.get('User-Agent')
    );
    
    return res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    logger.error(`Logout error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/auth/change-password
 * @desc    Change user password
 * @access  Private
 */
router.post('/change-password', authenticate, validateBody(schemas.changePassword), async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    // Get user with password
    const user = await db.getOne(
      'SELECT * FROM users WHERE id = ?',
      [req.user.id]
    );
    
    // Verify current password
    const passwordValid = await bcryptUtils.verifyPassword(currentPassword, user.password);
    if (!passwordValid) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'Current password is incorrect'
      });
    }
    
    // Hash new password
    const hashedPassword = await bcryptUtils.hashPassword(newPassword);
    
    // Update password
    await db.update('users',
      { password: hashedPassword },
      'id = ?',
      [req.user.id]
    );
    
    // Log password change
    await logger.activity(
      req.user.id, 
      'password_changed', 
      'users', 
      req.user.id, 
      null, 
      req.ip, 
      req.get('User-Agent')
    );
    
    return res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    logger.error(`Change password error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post('/forgot-password', validateBody(schemas.forgotPassword), async (req, res) => {
  try {
    const { email } = req.body;
    
    // Find user by email
    const user = await db.getOne(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    
    // Always return success, even if user not found (for security)
    if (!user) {
      return res.status(200).json({
        success: true,
        message: 'If your email is registered, you will receive a password reset link'
      });
    }
    
    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    
    // Save reset token to database
    await db.update('users',
      { 
        password_reset_token: resetToken,
        password_reset_expires: resetExpires
      },
      'id = ?',
      [user.id]
    );
    
    // Send password reset email
    await emailUtils.sendPasswordResetEmail(user, resetToken);
    
    // Log password reset request
    await logger.activity(
      user.id, 
      'password_reset_requested', 
      'users', 
      user.id, 
      null, 
      req.ip, 
      req.get('User-Agent')
    );
    
    return res.status(200).json({
      success: true,
      message: 'If your email is registered, you will receive a password reset link'
    });
  } catch (error) {
    logger.error(`Forgot password error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/auth/reset-password
 * @desc    Reset password with token
 * @access  Public
 */
router.post('/reset-password', validateBody(schemas.resetPassword), async (req, res) => {
  try {
    const { token, password } = req.body;
    
    // Find user by reset token
    const user = await db.getOne(
      'SELECT * FROM users WHERE password_reset_token = ? AND password_reset_expires > NOW()',
      [token]
    );
    
    if (!user) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'Invalid or expired reset token'
      });
    }
    
    // Hash new password
    const hashedPassword = await bcryptUtils.hashPassword(password);
    
    // Update password and clear reset token
    await db.update('users',
      { 
        password: hashedPassword,
        password_reset_token: null,
        password_reset_expires: null
      },
      'id = ?',
      [user.id]
    );
    
    // Invalidate all user sessions
    await db.update('user_sessions',
      { is_active: false },
      'user_id = ?',
      [user.id]
    );
    
    // Log password reset
    await logger.activity(
      user.id, 
      'password_reset', 
      'users', 
      user.id, 
      null, 
      req.ip, 
      req.get('User-Agent')
    );
    
    return res.status(200).json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    logger.error(`Reset password error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/auth/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await db.getOne(
      `SELECT 
        id, username, email, role, first_name, last_name,
        phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry
      FROM users WHERE id = ?`,
      [req.user.id]
    );
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: 'User not found'
      });
    }
    
    // Get region, tinkhundla, and umphakatsi names
    let regionName = null;
    let tinkhundlaName = null;
    let umphakatsiName = null;
    
    if (user.region_id) {
      const region = await db.getOne(
        'SELECT name FROM regions WHERE id = ?',
        [user.region_id]
      );
      regionName = region ? region.name : null;
    }
    
    if (user.tinkhundla_id) {
      const tinkhundla = await db.getOne(
        'SELECT name FROM tinkhundla WHERE id = ?',
        [user.tinkhundla_id]
      );
      tinkhundlaName = tinkhundla ? tinkhundla.name : null;
    }
    
    if (user.umphakatsi_id) {
      const umphakatsi = await db.getOne(
        'SELECT name FROM imiphakatsi WHERE id = ?',
        [user.umphakatsi_id]
      );
      umphakatsiName = umphakatsi ? umphakatsi.name : null;
    }
    
    // If user is EOG, fetch EOG data
    let eogData = null;
    if (user.role === 'EOG') {
      const eogUser = await db.getOne(
        'SELECT * FROM eog_users WHERE user_id = ?',
        [user.id]
      );
      
      if (eogUser) {
        const eog = await db.getOne(
          'SELECT * FROM eogs WHERE id = ?',
          [eogUser.eog_id]
        );
        
        if (eog) {
          // Check if temporary account has expired
          if (eog.status === 'temporary' && eog.temp_account_expires) {
            const expiryDate = new Date(eog.temp_account_expires);
            if (expiryDate < new Date()) {
              return res.status(401).json({
                success: false,
                error: 'Account Expired',
                message: 'Your temporary EOG account has expired'
              });
            }
            
            // Calculate days remaining
            const daysRemaining = Math.ceil((expiryDate - new Date()) / (1000 * 60 * 60 * 24));
            eog.days_remaining = daysRemaining;
          }
          
          eogData = eog;
          
          // Add region, tinkhundla, and umphakatsi names
          eogData.region = regionName;
          eogData.tinkhundla = tinkhundlaName;
          eogData.umphakatsi = umphakatsiName;
        }
      }
    }
    
    // Get notification preferences
    const preferences = await db.getOne(
      'SELECT * FROM user_notification_preferences WHERE user_id = ?',
      [user.id]
    );
    
    return res.status(200).json({
      success: true,
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role,
          first_name: user.first_name,
          last_name: user.last_name,
          phone: user.phone,
          region: regionName,
          region_id: user.region_id,
          tinkhundla: tinkhundlaName,
          tinkhundla_id: user.tinkhundla_id,
          umphakatsi: umphakatsiName,
          umphakatsi_id: user.umphakatsi_id,
          ministry: user.ministry,
          status: user.status
        },
        eog: eogData,
        notification_preferences: preferences
      }
    });
  } catch (error) {
    logger.error(`Get profile error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   PUT /api/auth/profile
 * @desc    Update user profile
 * @access  Private
 */
router.put('/profile', authenticate, validateBody(schemas.updateProfile), async (req, res) => {
  try {
    const { first_name, last_name, phone, email } = req.body;
    
    // Check if email is being changed and already exists
    if (email && email !== req.user.email) {
      const existingEmail = await db.getOne(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, req.user.id]
      );
      
      if (existingEmail) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Email already exists'
        });
      }
    }
    
    // Update user profile
    const updateData = {};
    if (first_name) updateData.first_name = first_name;
    if (last_name) updateData.last_name = last_name;
    if (phone) updateData.phone = phone;
    if (email) updateData.email = email;
    
    // Only update if there's data to update
    if (Object.keys(updateData).length > 0) {
      await db.update('users',
        updateData,
        'id = ?',
        [req.user.id]
      );
      
      // Log profile update
      await logger.activity(
        req.user.id, 
        'profile_updated', 
        'users', 
        req.user.id, 
        { fields: Object.keys(updateData) }, 
        req.ip, 
        req.get('User-Agent')
      );
    }
    
    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        ...req.user,
        ...updateData
      }
    });
  } catch (error) {
    logger.error(`Update profile error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

module.exports = router;
