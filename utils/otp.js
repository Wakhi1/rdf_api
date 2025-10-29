const crypto = require('crypto');
const db = require('./db');
const logger = require('./logger');

/**
 * Generate a 6-digit OTP
 * @returns {string} 6-digit OTP
 */
const generateOTP = () => {
  // Generate a random number between 100000 and 999999
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Save OTP to database
 * @param {number} userId User ID
 * @param {string} otp OTP code
 * @param {string} purpose Purpose of OTP
 * @param {number|null} entityId Related entity ID
 * @param {string|null} entityType Related entity type
 * @returns {Promise<number>} OTP record ID
 */
const saveOTP = async (userId, otp, purpose, entityId = null, entityType = null) => {
  try {
    // Set expiry to 10 minutes from now
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    
    // Save to database
    const result = await db.insert('otps', {
      user_id: userId,
      otp_code: otp,
      purpose,
      entity_id: entityId,
      entity_type: entityType,
      expires_at: expiresAt,
      attempts: 0,
      status: 'active'
    });
    
    return result.id;
  } catch (error) {
    logger.error(`OTP save error: ${error.message}`);
    throw error;
  }
};

/**
 * Generate and save OTP
 * @param {number} userId User ID
 * @param {string} purpose Purpose of OTP
 * @param {number|null} entityId Related entity ID
 * @param {string|null} entityType Related entity type
 * @returns {Promise<string>} Generated OTP
 */
const createOTP = async (userId, purpose, entityId = null, entityType = null) => {
  try {
    // Invalidate any existing active OTPs for this user and purpose
    await db.update('otps',
      { status: 'expired' },
      'user_id = ? AND purpose = ? AND status = ?',
      [userId, purpose, 'active']
    );
    
    // Generate new OTP
    const otp = generateOTP();
    
    // Save to database
    await saveOTP(userId, otp, purpose, entityId, entityType);
    
    return otp;
  } catch (error) {
    logger.error(`OTP creation error: ${error.message}`);
    throw error;
  }
};

/**
 * Verify OTP
 * @param {number} userId User ID
 * @param {string} otp OTP code
 * @param {string} purpose Purpose of OTP
 * @param {number|null} entityId Related entity ID
 * @returns {Promise<boolean>} Whether OTP is valid
 */
const verifyOTP = async (userId, otp, purpose, entityId = null) => {
  try {
    // Get OTP record
    let otpRecord;
    
    if (entityId) {
      otpRecord = await db.getOne(
        'SELECT * FROM otps WHERE user_id = ? AND purpose = ? AND entity_id = ? AND status = ? ORDER BY created_at DESC LIMIT 1',
        [userId, purpose, entityId, 'active']
      );
    } else {
      otpRecord = await db.getOne(
        'SELECT * FROM otps WHERE user_id = ? AND purpose = ? AND status = ? ORDER BY created_at DESC LIMIT 1',
        [userId, purpose, 'active']
      );
    }
    
    // Check if OTP exists
    if (!otpRecord) {
      return false;
    }
    
    // Check if OTP is expired
    if (new Date(otpRecord.expires_at) < new Date()) {
      await db.update('otps',
        { status: 'expired' },
        'id = ?',
        [otpRecord.id]
      );
      return false;
    }
    
    // Increment attempts
    await db.update('otps',
      { attempts: otpRecord.attempts + 1 },
      'id = ?',
      [otpRecord.id]
    );
    
    // Check if too many attempts (max 3)
    if (otpRecord.attempts >= 3) {
      await db.update('otps',
        { status: 'blocked' },
        'id = ?',
        [otpRecord.id]
      );
      return false;
    }
    
    // Check if OTP matches
    if (otpRecord.otp_code !== otp) {
      return false;
    }
    
    // Mark OTP as used
    await db.update('otps',
      { status: 'used' },
      'id = ?',
      [otpRecord.id]
    );
    
    return true;
  } catch (error) {
    logger.error(`OTP verification error: ${error.message}`);
    throw error;
  }
};

module.exports = {
  generateOTP,
  createOTP,
  verifyOTP
};
