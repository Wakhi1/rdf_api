const jwt = require('jsonwebtoken');
const config = require('../config/config');
const db = require('./db');
const logger = require('./logger');

/**
 * Generate an access token for a user
 * @param {Object} user User object
 * @returns {string} JWT access token
 */
const generateAccessToken = (user) => {
  const payload = {
    id: user.id,
    username: user.username,
    email: user.email,
    role: user.role
  };
  
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.accessExpiresIn
  });
};

/**
 * Generate a refresh token for a user
 * @param {Object} user User object
 * @returns {string} JWT refresh token
 */
const generateRefreshToken = (user) => {
  const payload = {
    id: user.id,
    tokenType: 'refresh'
  };
  
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.refreshExpiresIn
  });
};

/**
 * Create a new session for a user
 * @param {Object} user User object
 * @param {string} ipAddress IP address
 * @param {string} userAgent User agent
 * @returns {Object} Session tokens
 */
const createSession = async (user, ipAddress, userAgent) => {
  try {
    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);
    
    // Calculate expiry
    const refreshExpiry = jwt.decode(refreshToken).exp;
    const expiryDate = new Date(refreshExpiry * 1000);
    
    // Store session in database
    await db.insert('user_sessions', {
      user_id: user.id,
      session_token: accessToken,
      refresh_token: refreshToken,
      ip_address: ipAddress,
      user_agent: userAgent,
      is_active: true,
      expires_at: expiryDate
    });
    
    // Update last login
    await db.update('users', 
      { last_login: new Date() }, 
      'id = ?', 
      [user.id]
    );
    
    return {
      accessToken,
      refreshToken,
      expiresAt: expiryDate
    };
  } catch (error) {
    logger.error(`Session creation error: ${error.message}`);
    throw error;
  }
};

/**
 * Verify an access token
 * @param {string} token JWT token
 * @returns {Object|null} Decoded token payload or null if invalid
 */
const verifyToken = (token) => {
  try {
    return jwt.verify(token, config.jwt.secret);
  } catch (error) {
    logger.debug(`Token verification failed: ${error.message}`);
    return null;
  }
};

/**
 * Invalidate a user session
 * @param {number} userId User ID
 * @param {string} refreshToken Refresh token
 * @returns {boolean} Success status
 */
const invalidateSession = async (userId, refreshToken) => {
  try {
    const result = await db.update('user_sessions',
      { is_active: false },
      'user_id = ? AND refresh_token = ?',
      [userId, refreshToken]
    );
    
    return result.affectedRows > 0;
  } catch (error) {
    logger.error(`Session invalidation error: ${error.message}`);
    throw error;
  }
};

/**
 * Refresh an access token using a refresh token
 * @param {string} refreshToken Refresh token
 * @returns {Object|null} New tokens or null if invalid
 */
const refreshAccessToken = async (refreshToken) => {
  try {
    // Verify refresh token
    const decoded = verifyToken(refreshToken);
    if (!decoded || decoded.tokenType !== 'refresh') {
      return null;
    }
    
    // Check if session exists and is active
    const session = await db.getOne(
      'SELECT * FROM user_sessions WHERE refresh_token = ? AND is_active = true AND expires_at > NOW()',
      [refreshToken]
    );
    
    if (!session) {
      return null;
    }
    
    // Get user data
    const user = await db.getOne(
      'SELECT * FROM users WHERE id = ?',
      [decoded.id]
    );
    
    if (!user || user.status !== 'active') {
      return null;
    }
    
    // Generate new access token
    const accessToken = generateAccessToken(user);
    
    // Update session
    await db.update('user_sessions',
      { session_token: accessToken, last_activity: new Date() },
      'refresh_token = ?',
      [refreshToken]
    );
    
    return { accessToken };
  } catch (error) {
    logger.error(`Token refresh error: ${error.message}`);
    throw error;
  }
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  createSession,
  verifyToken,
  invalidateSession,
  refreshAccessToken
};
