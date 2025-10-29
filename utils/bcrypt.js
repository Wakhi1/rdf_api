const bcrypt = require('bcrypt');
const config = require('../config/config');
const logger = require('./logger');

/**
 * Hash a password
 * @param {string} password Plain text password
 * @returns {Promise<string>} Hashed password
 */
const hashPassword = async (password) => {
  try {
    return await bcrypt.hash(password, config.bcrypt.saltRounds);
  } catch (error) {
    logger.error(`Password hashing error: ${error.message}`);
    throw error;
  }
};

/**
 * Verify a password against a hash
 * @param {string} password Plain text password
 * @param {string} hash Hashed password
 * @returns {Promise<boolean>} Whether password matches hash
 */
const verifyPassword = async (password, hash) => {
  try {
    return await bcrypt.compare(password, hash);
  } catch (error) {
    logger.error(`Password verification error: ${error.message}`);
    throw error;
  }
};

/**
 * Generate a random password of specified length
 * @param {number} length Password length (default: 10)
 * @returns {string} Random password
 */
const generateRandomPassword = (length = 10) => {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+';
  let password = '';
  
  // Ensure at least one of each: uppercase, lowercase, number, special char
  password += charset.charAt(Math.floor(Math.random() * 26)); // Uppercase
  password += charset.charAt(26 + Math.floor(Math.random() * 26)); // Lowercase
  password += charset.charAt(52 + Math.floor(Math.random() * 10)); // Number
  password += charset.charAt(62 + Math.floor(Math.random() * 14)); // Special
  
  // Fill the rest randomly
  for (let i = password.length; i < length; i++) {
    password += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  
  // Shuffle the password
  return password
    .split('')
    .sort(() => Math.random() - 0.5)
    .join('');
};

module.exports = {
  hashPassword,
  verifyPassword,
  generateRandomPassword
};
