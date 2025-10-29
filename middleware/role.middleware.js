const db = require('../utils/db');
const logger = require('../utils/logger');
const config = require('../config/config');

/**
 * Middleware to check if user has required role
 * @param {string|Array} roles Required role(s)
 * @returns {Function} Middleware function
 */
const requireRole = (roles) => {
  return (req, res, next) => {
    // Check if user exists on request
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Authentication required'
      });
    }
    
    // Convert roles to array if string
    const allowedRoles = Array.isArray(roles) ? roles : [roles];
    
    // Check if user has required role
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: 'Forbidden',
        message: 'Insufficient permissions'
      });
    }
    
    // Continue
    next();
  };
};

/**
 * Middleware to check if user has ownership of an EOG
 * @returns {Function} Middleware function
 */
const requireEOGOwnership = async (req, res, next) => {
  try {
    // Check if user exists on request
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Authentication required'
      });
    }
    
    // If user is SUPER_USER, allow access
    if (req.user.role === 'SUPER_USER') {
      return next();
    }
    
    // Get EOG ID from request parameters
    const eogId = parseInt(req.params.eogId);
    
    // If no EOG ID in parameters, check for it in the body
    if (!eogId && req.body && req.body.eogId) {
      req.params.eogId = req.body.eogId;
    }
    
    // If no EOG ID found, return error
    if (!eogId) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'EOG ID is required'
      });
    }
    
    // If user is EOG, check if they own the EOG
    if (req.user.role === 'EOG') {
      const ownership = await db.getOne(
        'SELECT * FROM eog_users WHERE user_id = ? AND eog_id = ?',
        [req.user.id, eogId]
      );
      
      if (!ownership) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this EOG'
        });
      }
      
      // Continue
      return next();
    }
    
    // If user is CDO, they can access EOGs in their region
    if (req.user.role === 'CDO') {
      const eog = await db.getOne(
        'SELECT * FROM eogs WHERE id = ? AND region_id = ?',
        [eogId, req.user.region_id]
      );
      
      if (!eog) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to EOGs outside your region'
        });
      }
      
      // Continue
      return next();
    }
    
    // Other roles don't have direct EOG ownership
    return res.status(403).json({
      success: false,
      error: 'Forbidden',
      message: 'Insufficient permissions to access this EOG'
    });
  } catch (error) {
    logger.error(`EOG ownership check error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
};

/**
 * Middleware to check if user has access to an application
 * @returns {Function} Middleware function
 */
const requireApplicationAccess = async (req, res, next) => {
  try {
    // Check if user exists on request
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Authentication required'
      });
    }
    
    // If user is SUPER_USER, allow access
    if (req.user.role === 'SUPER_USER') {
      return next();
    }
    
    // Get application ID from request parameters
    const applicationId = parseInt(req.params.applicationId || req.params.id);
    
    // If no application ID in parameters, check for it in the body
    if (!applicationId && req.body && req.body.applicationId) {
      req.params.applicationId = req.body.applicationId;
    }
    
    // If no application ID found, return error
    if (!applicationId) {
      return res.status(400).json({
        success: false,
        error: 'Bad Request',
        message: 'Application ID is required'
      });
    }
    
    // Get application details
    const application = await db.getOne(
      'SELECT * FROM applications WHERE id = ?',
      [applicationId]
    );
    
    if (!application) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: 'Application not found'
      });
    }
    
    // Check role-based access
    switch (req.user.role) {
      // EOG can only access their own applications
      case 'EOG':
        // Get EOG ID from user
        const eogUser = await db.getOne(
          'SELECT eog_id FROM eog_users WHERE user_id = ?',
          [req.user.id]
        );
        
        if (!eogUser || eogUser.eog_id !== application.eog_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You do not have access to this application'
          });
        }
        break;
      
      // CDO can access applications in their region
      case 'CDO':
        // Get EOG region
        const eog = await db.getOne(
          'SELECT region_id FROM eogs WHERE id = ?',
          [application.eog_id]
        );
        
        if (!eog || eog.region_id !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You do not have access to applications outside your region'
          });
        }
        break;
      
      // Check if user has access based on workflow level
      default:
        // Map roles to workflow levels
        const roleToLevel = {
          'LINE_MINISTRY': 'MINISTRY_LEVEL',
          'MICROPROJECTS': 'MICROPROJECTS_LEVEL',
          'CDC': 'UMPHAKATSI_LEVEL',
          'INKHUNDLA_COUNCIL': 'INKHUNDLA_LEVEL',
          'RDFTC': 'RDFTC_LEVEL',
          'RDFC': 'RDFC_LEVEL',
          'PS': 'PS_LEVEL'
        };
        
        // Check if role has a corresponding workflow level
        if (!roleToLevel[req.user.role]) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'Your role does not have access to applications'
          });
        }
        
        // Check if application is at the user's workflow level
        if (application.current_level !== roleToLevel[req.user.role]) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'Application is not at your workflow level'
          });
        }
        break;
    }
    
    // Continue
    next();
  } catch (error) {
    logger.error(`Application access check error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
};

module.exports = {
  requireRole,
  requireEOGOwnership,
  requireApplicationAccess
};
