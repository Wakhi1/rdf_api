const jwt = require('../utils/jwt');
const db = require('../utils/db');
const logger = require('../utils/logger');

/**
 * Middleware to verify JWT token and attach user to request
 */
const authenticate = async (req, res, next) => {
  try {
    // Get authorization header
    const authHeader = req.headers.authorization;
    
    
    // Check if auth header exists and has format "Bearer token"
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Authentication required'
      });
    }
    
    // Extract token
    const token = authHeader.split(' ')[1];
    
    // Verify token
    const decoded = jwt.verifyToken(token);
    if (!decoded) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid or expired token'
      });
    }
    
    // Check if session exists and is active
    const session = await db.getOne(
      'SELECT * FROM user_sessions WHERE session_token = ? AND is_active = true',
      [token]
    );
    
    if (!session) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Session not found or inactive'
      });
    }
    
    // Get user data
    const user = await db.getOne(
      'SELECT id, username, email, role, first_name, last_name, status, region_id, tinkhundla_id, umphakatsi_id, ministry FROM users WHERE id = ?',
      [decoded.id]
    );
    
    // Check if user exists and is active or temporary
    if (!user || (user.status !== 'active' && user.status !== 'temporary')) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'User not found or inactive'
      });
    }
    
    // Check if user is EOG and fetch EOG data
    if (user.role === 'EOG') {
      const eog = await db.getOne(`
        SELECT e.* 
        FROM eogs e 
        JOIN eog_users eu ON eu.eog_id = e.id 
        WHERE eu.user_id = ?
      `, [user.id]);
      
      if (eog) {
        user.eog = eog;
        
        // Check if temporary account has expired
        if (eog.status === 'temporary' && eog.temp_account_expires && new Date(eog.temp_account_expires) < new Date()) {
          return res.status(401).json({
            success: false,
            error: 'Account Expired',
            message: 'Your temporary EOG account has expired'
          });
        }
      }
    }
    
    // Attach user to request
    req.user = user;
    
    // Update session last_activity
    await db.update('user_sessions',
      { last_activity: new Date() },
      'session_token = ?',
      [token]
    );
    
    // Continue
    next();
  } catch (error) {
    logger.error(`Authentication error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
};

/**
 * Optional authentication middleware - doesn't require auth, but attaches user if present
 */
const optionalAuth = async (req, res, next) => {
  try {
    // Get authorization header
    const authHeader = req.headers.authorization;
    
    // If no auth header, continue without authentication
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }
    
    // Extract token
    const token = authHeader.split(' ')[1];
    
    // Verify token
    const decoded = jwt.verifyToken(token);
    if (!decoded) {
      return next();
    }
    
    // Get user data
    const user = await db.getOne(
      'SELECT id, username, email, role, first_name, last_name, status, region_id, tinkhundla_id, umphakatsi_id, ministry FROM users WHERE id = ?',
      [decoded.id]
    );
    
    // Check if user exists and is active or temporary
    if (!user || (user.status !== 'active' && user.status !== 'temporary')) {
      return next();
    }
    
    // Check if user is EOG and fetch EOG data
    if (user.role === 'EOG') {
      const eog = await db.getOne(`
        SELECT e.* 
        FROM eogs e 
        JOIN eog_users eu ON eu.eog_id = e.id 
        WHERE eu.user_id = ?
      `, [user.id]);
      
      if (eog) {
        user.eog = eog;
      }
    }
    
    // Attach user to request
    req.user = user;
    
    // Continue
    next();
  } catch (error) {
    // In optional auth, just continue if there's an error
    logger.error(`Optional authentication error: ${error.message}`);
    next();
  }
};

module.exports = {
  authenticate,
  optionalAuth
};