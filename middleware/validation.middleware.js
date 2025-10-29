const Joi = require('joi');
const logger = require('../utils/logger');

/**
 * Validate request body against a Joi schema
 * @param {Object} schema Joi schema
 * @returns {Function} Middleware function
 */
const validateBody = (schema) => {
  return (req, res, next) => {
    const result = schema.validate(req.body, { abortEarly: false });
    
    if (result.error) {
      const errors = result.error.details.map(err => ({
        field: err.path[0],
        message: err.message
      }));
      
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        errors
      });
    }
    
    // Update req.body with validated values
    req.body = result.value;
    next();
  };
};

/**
 * Validate request params against a Joi schema
 * @param {Object} schema Joi schema
 * @returns {Function} Middleware function
 */
const validateParams = (schema) => {
  return (req, res, next) => {
    const result = schema.validate(req.params, { abortEarly: false });
    
    if (result.error) {
      const errors = result.error.details.map(err => ({
        field: err.path[0],
        message: err.message
      }));
      
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        errors
      });
    }
    
    // Update req.params with validated values
    req.params = result.value;
    next();
  };
};

/**
 * Validate request query against a Joi schema
 * @param {Object} schema Joi schema
 * @returns {Function} Middleware function
 */
const validateQuery = (schema) => {
  return (req, res, next) => {
    const result = schema.validate(req.query, { abortEarly: false });
    
    if (result.error) {
      const errors = result.error.details.map(err => ({
        field: err.path[0],
        message: err.message
      }));
      
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        errors
      });
    }
    
    // Update req.query with validated values
    req.query = result.value;
    next();
  };
};

// Common validation schemas
const schemas = {
  // User schemas
  login: Joi.object({
    username: Joi.string().trim(),
    email: Joi.string().email(),
    password: Joi.string().required()
  }).xor('username', 'email'),
  
  register: Joi.object({
    username: Joi.string().required().min(3).max(50),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    role: Joi.string().valid(
      'EOG', 'CDO', 'LINE_MINISTRY', 'MICROPROJECTS', 
      'CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC', 
      'PS', 'SUPER_USER'
    ).required(),
    first_name: Joi.string().required().min(2).max(50),
    last_name: Joi.string().required().min(2).max(50),
    phone: Joi.string().pattern(/^[0-9+\- ]{7,20}$/),
    region_id: Joi.number().integer().positive(),
    tinkhundla_id: Joi.number().integer().positive(),
    umphakatsi_id: Joi.number().integer().positive(),
    ministry: Joi.string().max(100)
  }),
  
  changePassword: Joi.object({
    currentPassword: Joi.string().required(),
    newPassword: Joi.string().min(8).required(),
    confirmPassword: Joi.string().required().valid(Joi.ref('newPassword'))
      .messages({ 'any.only': 'Passwords must match' })
  }),
  
  resetPassword: Joi.object({
    token: Joi.string().required(),
    password: Joi.string().min(8).required(),
    confirmPassword: Joi.string().required().valid(Joi.ref('password'))
      .messages({ 'any.only': 'Passwords must match' })
  }),
  
  forgotPassword: Joi.object({
    email: Joi.string().email().required()
  }),
  
  updateProfile: Joi.object({
    first_name: Joi.string().min(2).max(50),
    last_name: Joi.string().min(2).max(50),
    phone: Joi.string().pattern(/^[0-9+\- ]{7,20}$/),
    email: Joi.string().email()
  }),
  
  // EOG Registration schemas
  eogRegistration: Joi.object({
    company_name: Joi.string().required().min(3).max(200),
    company_type: Joi.string().valid(
      'Association', 'Cooperative', 'Company', 'Community Group', 'Scheme', 'Partnership'
    ).required(),
    bin_cin: Joi.string().required().min(5).max(50),
    email: Joi.string().email().required(),
    phone: Joi.string().pattern(/^[0-9+\- ]{7,20}$/).required(),
    region_id: Joi.number().integer().positive().required(),
    tinkhundla_id: Joi.number().integer().positive().required(),
    umphakatsi_id: Joi.number().integer().positive().required(),
    total_members: Joi.number().integer().min(1).required()
  }),
  
  eogMember: Joi.object({
    id_number: Joi.string().required().length(13).pattern(/^[0-9]{13}$/),
    first_name: Joi.string().required().min(2).max(50),
    surname: Joi.string().required().min(2).max(50),
    gender: Joi.string().valid('Male', 'Female').required(),
    contact_number: Joi.string().pattern(/^[0-9+\- ]{7,20}$/).required(),
    position: Joi.string().required().min(2).max(100)
  }),
  
  // Application schemas
  application: Joi.object({
    title: Joi.string().required().min(5).max(255),
    description: Joi.string().required(),
    funding_requested: Joi.number().positive().required(),
    project_duration_months: Joi.number().integer().min(1).max(36).required(),
    project_category: Joi.string().required()
  }),
  
  // ID parameter schema
  idParam: Joi.object({
    id: Joi.number().integer().positive().required()
  }),
  
  eogIdParam: Joi.object({
    eogId: Joi.number().integer().positive().required()
  }),
  
  memberIdParam: Joi.object({
    memberId: Joi.number().integer().positive().required()
  }),
  
  applicationIdParam: Joi.object({
    applicationId: Joi.number().integer().positive().required()
  })
};

module.exports = {
  validateBody,
  validateParams,
  validateQuery,
  schemas
};
