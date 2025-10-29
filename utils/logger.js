const winston = require('winston');
const config = require('../config/config');
const path = require('path');
const db = require('./db'); // Import only after logger initialization

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define colors for each level
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'blue',
};

// Add colors to Winston
winston.addColors(colors);

// Create the format
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`
  )
);

// Define file transport
const logDir = path.join(process.cwd(), 'logs');

// Create transports
const transports = [
  // Console transport
  new winston.transports.Console(),
  // Error log file
  new winston.transports.File({
    filename: path.join(logDir, 'error.log'),
    level: 'error',
  }),
  // Combined log file
  new winston.transports.File({ 
    filename: path.join(logDir, 'combined.log') 
  }),
];

// Create the logger
const logger = winston.createLogger({
  level: config.server.env === 'development' ? 'debug' : 'info',
  levels,
  format,
  transports,
});

/**
 * Log user activity to database
 * @param {number} userId User ID
 * @param {string} action Action performed
 * @param {string} entityType Type of entity
 * @param {number} entityId Entity ID
 * @param {Object} description Additional description
 * @param {string} ipAddress IP address
 * @param {string} userAgent User agent
 * @returns {Promise<number>} Activity log ID
 */
const logActivity = async (
  userId,
  action,
  entityType = null,
  entityId = null,
  description = null,
  ipAddress = null,
  userAgent = null
) => {
  try {
    // Don't try to log to DB before it's initialized
    if (!db.pool) return null;
    
    const result = await db.insert('user_activity_logs', {
      user_id: userId,
      action,
      entity_type: entityType,
      entity_id: entityId,
      description: description ? JSON.stringify(description) : null,
      ip_address: ipAddress,
      user_agent: userAgent
    });
    
    return result.id;
  } catch (error) {
    logger.error(`Failed to log activity: ${error.message}`);
    return null;
  }
};

// Add activity logging method to logger
logger.activity = logActivity;

module.exports = logger;
