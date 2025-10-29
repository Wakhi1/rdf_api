const crypto = require('crypto');
const db = require('../../config/database');

class OTPService {
  /**
   * Generate OTP
   */
  generateOTP(length = 6) {
    const digits = '0123456789';
    let otp = '';
    for (let i = 0; i < length; i++) {
      otp += digits[Math.floor(Math.random() * 10)];
    }
    return otp;
  }

  /**
   * Create and store OTP
   */
  async createOTP(userId, purpose = 'signature', expiryMinutes = 10) {
    const otp = this.generateOTP(6);
    const expiresAt = new Date(Date.now() + expiryMinutes * 60000);

    // Delete any existing OTPs for this user and purpose
    await db.query(
      'DELETE FROM otp_codes WHERE user_id = ? AND purpose = ? AND used = 0',
      [userId, purpose]
    );

    // Insert new OTP
    const result = await db.query(
      `INSERT INTO otp_codes (user_id, otp_code, purpose, expires_at) 
       VALUES (?, ?, ?, ?)`,
      [userId, otp, purpose, expiresAt]
    );

    // Log OTP generation
    await db.query(
      `INSERT INTO otp_logs (user_id, otp_id, action, created_at) 
       VALUES (?, ?, 'generated', NOW())`,
      [userId, result.insertId]
    );

    return {
      otpId: result.insertId,
      otp,
      expiresAt
    };
  }

  /**
   * Verify OTP
   */
  async verifyOTP(userId, otp, purpose = 'signature') {
    const otpRecord = await db.queryOne(
      `SELECT id, otp_code, expires_at, used 
       FROM otp_codes 
       WHERE user_id = ? AND purpose = ? AND used = 0
       ORDER BY created_at DESC 
       LIMIT 1`,
      [userId, purpose]
    );

    if (!otpRecord) {
      await this.logOTPAttempt(userId, null, 'not_found');
      return { valid: false, message: 'OTP not found or already used' };
    }

    // Check if expired
    if (new Date() > new Date(otpRecord.expires_at)) {
      await this.logOTPAttempt(userId, otpRecord.id, 'expired');
      return { valid: false, message: 'OTP has expired' };
    }

    // Verify OTP
    if (otpRecord.otp_code !== otp) {
      await this.logOTPAttempt(userId, otpRecord.id, 'invalid');
      return { valid: false, message: 'Invalid OTP' };
    }

    // Mark as used
    await db.query(
      'UPDATE otp_codes SET used = 1, used_at = NOW() WHERE id = ?',
      [otpRecord.id]
    );

    await this.logOTPAttempt(userId, otpRecord.id, 'verified');

    return { valid: true, otpId: otpRecord.id };
  }

  /**
   * Log OTP attempt
   */
  async logOTPAttempt(userId, otpId, action) {
    await db.query(
      `INSERT INTO otp_logs (user_id, otp_id, action, created_at) 
       VALUES (?, ?, ?, NOW())`,
      [userId, otpId, action]
    );
  }

  /**
   * Clean up expired OTPs
   */
  async cleanupExpiredOTPs() {
    await db.query(
      'DELETE FROM otp_codes WHERE expires_at < NOW() AND used = 0'
    );
  }

  /**
   * Get OTP history for user
   */
  async getOTPHistory(userId, limit = 50) {
    return await db.query(
      `SELECT 
        o.id,
        o.purpose,
        o.created_at,
        o.expires_at,
        o.used,
        o.used_at,
        l.action as last_action,
        l.created_at as last_action_at
       FROM otp_codes o
       LEFT JOIN otp_logs l ON o.id = l.otp_id AND l.id = (
         SELECT MAX(id) FROM otp_logs WHERE otp_id = o.id
       )
       WHERE o.user_id = ?
       ORDER BY o.created_at DESC
       LIMIT ?`,
      [userId, limit]
    );
  }
}

module.exports = new OTPService();
