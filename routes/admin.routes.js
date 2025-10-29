const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, schemas } = require('../middleware/validation.middleware');
const { hashPassword } = require('../utils/bcrypt');
const { sendEmail } = require('../utils/email');
const crypto = require('crypto');

/**
 * @route   GET /api/admin/users
 * @desc    Get all users with filtering and pagination
 * @access  Private (SUPER_USER only)
 */
router.get('/users', authenticate, requireRole(['SUPER_USER']), async (req, res) => {
  try {
    const { 
      role, status, region_id, tinkhundla_id, 
      search, sort_by, sort_order, limit, page 
    } = req.query;
    
    // Build base query
    let query = `
      SELECT 
        u.id, u.username, u.email, u.role, u.first_name, u.last_name, 
        u.phone, u.status, u.region_id, u.tinkhundla_id, u.umphakatsi_id,
        u.ministry, u.last_login, u.created_at, u.updated_at,
        r.name as region_name,
        t.name as tinkhundla_name,
        i.name as umphakatsi_name
      FROM users u
      LEFT JOIN regions r ON u.region_id = r.id
      LEFT JOIN tinkhundla t ON u.tinkhundla_id = t.id
      LEFT JOIN imiphakatsi i ON u.umphakatsi_id = i.id
      WHERE 1=1
    `;
    
    const queryParams = [];
    
    // Add filters
    if (role) {
      query += ` AND u.role = ?`;
      queryParams.push(role);
    }
    
    if (status) {
      query += ` AND u.status = ?`;
      queryParams.push(status);
    }
    
    if (region_id) {
      query += ` AND u.region_id = ?`;
      queryParams.push(region_id);
    }
    
    if (tinkhundla_id) {
      query += ` AND u.tinkhundla_id = ?`;
      queryParams.push(tinkhundla_id);
    }
    
    if (search) {
      query += ` AND (u.username LIKE ? OR u.email LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ? OR u.phone LIKE ?)`;
      const searchTerm = `%${search}%`;
      queryParams.push(searchTerm, searchTerm, searchTerm, searchTerm, searchTerm);
    }
    
    // Get total count
    const countQuery = `SELECT COUNT(*) as total FROM (${query}) as count_query`;
    const countResult = await db.query(countQuery, queryParams);
    const total = countResult[0].total;
    
    // Add sorting
    const validSortFields = ['username', 'email', 'role', 'status', 'first_name', 'last_name', 'created_at', 'last_login'];
    const sortField = validSortFields.includes(sort_by) ? sort_by : 'created_at';
    const sortDir = sort_order === 'asc' ? 'ASC' : 'DESC';
    query += ` ORDER BY u.${sortField} ${sortDir}`;
    
    // Add pagination
    const pageSize = parseInt(limit) || 10;
    const pageNum = parseInt(page) || 1;
    const offset = (pageNum - 1) * pageSize;
    query += ` LIMIT ? OFFSET ?`;
    queryParams.push(pageSize, offset);
    
    // Execute query
    const users = await db.query(query, queryParams);
    
    return res.status(200).json({
      success: true,
      data: {
        users,
        pagination: {
          total,
          page: pageNum,
          limit: pageSize,
          pages: Math.ceil(total / pageSize)
        }
      }
    });
  } catch (error) {
    logger.error(`Get users error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/admin/users/:id
 * @desc    Get user details
 * @access  Private (SUPER_USER only)
 */
router.get('/users/:id', 
  authenticate, 
  requireRole(['SUPER_USER']), 
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params;
      
      // Get user details
      const user = await db.getOne(`
        SELECT 
          u.id, u.username, u.email, u.role, u.first_name, u.last_name, 
          u.phone, u.status, u.region_id, u.tinkhundla_id, u.umphakatsi_id,
          u.ministry, u.last_login, u.created_at, u.updated_at,
          r.name as region_name,
          t.name as tinkhundla_name,
          i.name as umphakatsi_name
        FROM users u
        LEFT JOIN regions r ON u.region_id = r.id
        LEFT JOIN tinkhundla t ON u.tinkhundla_id = t.id
        LEFT JOIN imiphakatsi i ON u.umphakatsi_id = i.id
        WHERE u.id = ?
      `, [id]);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'User not found'
        });
      }
      
      // Get active sessions
      const sessions = await db.query(`
        SELECT 
          id, ip_address, user_agent, created_at, last_activity, expires_at
        FROM user_sessions
        WHERE user_id = ? AND is_active = TRUE
        ORDER BY last_activity DESC
      `, [id]);
      
      // Get role-specific data
      let roleData = {};
      
      if (user.role === 'EOG') {
        const eogData = await db.query(`
          SELECT e.* 
          FROM eog_users eu
          JOIN eogs e ON eu.eog_id = e.id
          WHERE eu.user_id = ?
        `, [id]);
        
        if (eogData.length > 0) {
          roleData.eog = eogData[0];
        }
      } else if (user.role === 'CDO') {
        const cdoStats = await db.getOne(`
          SELECT 
            COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_reviews,
            COUNT(CASE WHEN status = 'in_review' THEN 1 END) as in_progress_reviews,
            COUNT(*) as total_assigned
          FROM cdo_review_queue
          WHERE assigned_cdo_id = ?
        `, [id]);
        
        roleData.cdo_stats = cdoStats || { pending_reviews: 0, in_progress_reviews: 0, total_assigned: 0 };
      } else if (['CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC'].includes(user.role)) {
        const committees = await db.query(`
          SELECT 
            c.id, c.name, c.type, cm.position, cm.is_chairperson
          FROM committee_members cm
          JOIN committees c ON cm.committee_id = c.id
          WHERE cm.user_id = ?
        `, [id]);
        
        roleData.committees = committees;
      }
      
      // Get notification preferences
      const preferences = await db.getOne(`
        SELECT * FROM user_notification_preferences WHERE user_id = ?
      `, [id]);
      
      return res.status(200).json({
        success: true,
        data: {
          user,
          sessions,
          role_data: roleData,
          notification_preferences: preferences
        }
      });
    } catch (error) {
      logger.error(`Get user details error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/admin/users
 * @desc    Create new user
 * @access  Private (SUPER_USER only)
 */
router.post('/users', 
  authenticate, 
  requireRole(['SUPER_USER']),
  async (req, res) => {
    try {
      const { 
        username, email, password, role, first_name, last_name,
        phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry
      } = req.body;
      
      // Validate required fields
      if (!username || !email || !password || !role || !first_name || !last_name) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Username, email, password, role, first name, and last name are required'
        });
      }
      
      // Validate role
      const validRoles = ['EOG', 'CDO', 'LINE_MINISTRY', 'MICROPROJECTS', 'CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC', 'PS', 'SUPER_USER'];
      if (!validRoles.includes(role)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Role must be one of: ${validRoles.join(', ')}`
        });
      }
      
      // Check if username exists
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
      
      // Check if email exists
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
      
      // Hash password
      const hashedPassword = await hashPassword(password);
      
      // Create user
      const result = await db.insert('users', {
        username,
        email,
        password: hashedPassword,
        role,
        first_name,
        last_name,
        phone: phone || null,
        status: status || 'active',
        region_id: region_id || null,
        tinkhundla_id: tinkhundla_id || null,
        umphakatsi_id: umphakatsi_id || null,
        ministry: ministry || null
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'user_created',
        'users',
        result.id,
        { username, email, role },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created user
      const user = await db.getOne(
        'SELECT id, username, email, role, first_name, last_name, phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry, created_at FROM users WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: user
      });
    } catch (error) {
      logger.error(`Create user error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/admin/users/:id
 * @desc    Update user
 * @access  Private (SUPER_USER only)
 */
router.put('/users/:id', 
  authenticate, 
  requireRole(['SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { 
        username, email, role, first_name, last_name,
        phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry
      } = req.body;
      
      // Check if user exists
      const user = await db.getOne(
        'SELECT * FROM users WHERE id = ?',
        [id]
      );
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'User not found'
        });
      }
      
      // Build update data
      const updateData = {};
      
      if (username && username !== user.username) {
        const existingUsername = await db.getOne(
          'SELECT id FROM users WHERE username = ? AND id != ?',
          [username, id]
        );
        
        if (existingUsername) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Username already exists'
          });
        }
        updateData.username = username;
      }
      
      if (email && email !== user.email) {
        const existingEmail = await db.getOne(
          'SELECT id FROM users WHERE email = ? AND id != ?',
          [email, id]
        );
        
        if (existingEmail) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Email already exists'
          });
        }
        updateData.email = email;
      }
      
      if (role) updateData.role = role;
      if (first_name) updateData.first_name = first_name;
      if (last_name) updateData.last_name = last_name;
      if (phone !== undefined) updateData.phone = phone;
      if (status) updateData.status = status;
      if (region_id !== undefined) updateData.region_id = region_id;
      if (tinkhundla_id !== undefined) updateData.tinkhundla_id = tinkhundla_id;
      if (umphakatsi_id !== undefined) updateData.umphakatsi_id = umphakatsi_id;
      if (ministry !== undefined) updateData.ministry = ministry;
      
      // Update user
      await db.update('users', updateData, 'id = ?', [id]);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'user_updated',
        'users',
        id,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated user
      const updatedUser = await db.getOne(
        'SELECT id, username, email, role, first_name, last_name, phone, status, region_id, tinkhundla_id, umphakatsi_id, ministry, updated_at FROM users WHERE id = ?',
        [id]
      );
      
      return res.status(200).json({
        success: true,
        message: 'User updated successfully',
        data: updatedUser
      });
    } catch (error) {
      logger.error(`Update user error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/admin/users/:id
 * @desc    Delete user
 * @access  Private (SUPER_USER only)
 */
router.delete('/users/:id', 
  authenticate, 
  requireRole(['SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params;
      
      // Check if user exists
      const user = await db.getOne(
        'SELECT * FROM users WHERE id = ?',
        [id]
      );
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'User not found'
        });
      }
      
      // Prevent self-deletion
      if (parseInt(id) === req.user.id) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete your own account'
        });
      }
      
      // Delete user
      await db.delete('users', 'id = ?', [id]);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'user_deleted',
        'users',
        id,
        { username: user.username, email: user.email },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'User deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete user error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/admin/users/:id/reset-password
 * @desc    Reset user password
 * @access  Private (SUPER_USER only)
 */
router.post('/users/:id/reset-password', 
  authenticate, 
  requireRole(['SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { new_password } = req.body;
      
      if (!new_password) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'New password is required'
        });
      }
      
      // Check if user exists
      const user = await db.getOne(
        'SELECT * FROM users WHERE id = ?',
        [id]
      );
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'User not found'
        });
      }
      
      // Hash new password
      const hashedPassword = await hashPassword(new_password);
      
      // Update password
      await db.update('users', 
        { password: hashedPassword },
        'id = ?',
        [id]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'password_reset',
        'users',
        id,
        { reset_by: 'admin' },
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
  }
);

/**
 * @route   GET /api/admin/dashboard/stats
 * @desc    Get dashboard statistics
 * @access  Private (SUPER_USER only)
 */
router.get('/dashboard/stats', 
  authenticate, 
  requireRole(['SUPER_USER']),
  async (req, res) => {
    try {
      // Get user stats
      const userStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_users,
          COUNT(CASE WHEN status = 'active' THEN 1 END) as active_users,
          COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactive_users,
          COUNT(CASE WHEN status = 'suspended' THEN 1 END) as suspended_users,
          COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_users_last_30_days
        FROM users
      `);
      
      // Get EOG stats
      const eogStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_eogs,
          COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_eogs,
          COUNT(CASE WHEN status = 'pending_verification' THEN 1 END) as pending_eogs,
          COUNT(CASE WHEN status = 'temporary' THEN 1 END) as temporary_eogs
        FROM eogs
      `);
      
      // Get application stats
      const applicationStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_applications,
          COUNT(CASE WHEN status = 'submitted' THEN 1 END) as submitted_applications,
          COUNT(CASE WHEN status = 'in_review' THEN 1 END) as in_review_applications,
          COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_applications,
          COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_applications
        FROM applications
      `);
      
      return res.status(200).json({
        success: true,
        data: {
          users: userStats,
          eogs: eogStats,
          applications: applicationStats
        }
      });
    } catch (error) {
      logger.error(`Get dashboard stats error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;