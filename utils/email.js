const nodemailer = require('nodemailer');
const config = require('../config/config');
const db = require('./db');
const logger = require('./logger');

// Create reusable transporter object using SMTP
const transporter = nodemailer.createTransport({
  host: config.smtp.host,
  port: config.smtp.port,
  secure: config.smtp.port === 465,
  auth: {
    user: config.smtp.user,
    pass: config.smtp.password
  }
});

/**
 * Send an email and log to database
 * @param {string} to Recipient email
 * @param {string} subject Email subject
 * @param {string} body Email body (HTML)
 * @param {number|null} userId User ID (optional)
 * @returns {Promise<number>} Email log ID
 */
const sendEmail = async (to, subject, body, userId = null) => {
  try {
    // Send email
    const info = await transporter.sendMail({
      from: config.smtp.from,
      to,
      subject,
      html: body
    });
    
    // Log to database - using schema-correct column names
    const result = await db.insert('email_logs', {
      recipient_email: to,
      recipient_user_id: userId,
      subject,
      body,
      status: 'sent',
      sent_at: new Date()
    });
    
    logger.info(`Email sent to ${to}: ${subject}`);
    return result.id;
  } catch (error) {
    // Log failure to database
    if (to) {
      await db.insert('email_logs', {
        recipient_email: to,
        recipient_user_id: userId,
        subject,
        body,
        status: 'failed',
        error_message: error.message
      });
    }
    
    logger.error(`Email sending error to ${to}: ${error.message}`);
    throw error;
  }
};

/**
 * Send welcome email to new user with credentials
 * @param {Object} user User object with properties: id, email, first_name, last_name, username
 * @param {string} password Temporary password
 * @returns {Promise<number>} Email log ID
 */
const sendWelcomeEmail = async (user, password) => {
  const subject = 'Welcome to the RDF System';
  const body = `
    <h1>Welcome to the RDF System</h1>
    <p>Hello ${user.first_name} ${user.last_name},</p>
    <p>Your account has been created successfully. Here are your credentials:</p>
    <ul>
      <li><strong>Username:</strong> ${user.username}</li>
      <li><strong>Temporary Password:</strong> ${password}</li>
    </ul>
    <p>Please log in and change your password as soon as possible.</p>
    <p>Thank you,</p>
    <p>The RDF System Team</p>
  `;
  
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send OTP email for verification
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @param {string} otpCode OTP code
 * @param {string} purpose Purpose of the OTP
 * @returns {Promise<number>} Email log ID
 */
const sendOTPEmail = async (user, otpCode, purpose) => {
  const subject = 'RDF System - Verification Code';
  const body = `
    <h1>Verification Code</h1>
    <p>Hello ${user.first_name} ${user.last_name},</p>
    <p>Your verification code is:</p>
    <h2 style="font-size: 24px; background-color: #f0f0f0; padding: 10px; text-align: center;">${otpCode}</h2>
    <p>This code will expire in 10 minutes.</p>
    <p>If you did not request this code, please ignore this email.</p>
    <p>Thank you,</p>
    <p>The RDF System Team</p>
  `;
  
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send password reset email
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @param {string} resetToken Reset token
 * @returns {Promise<number>} Email log ID
 */
const sendPasswordResetEmail = async (user, resetToken) => {
  const subject = 'RDF System - Password Reset';
  const body = `
    <h1>Password Reset</h1>
    <p>Hello ${user.first_name} ${user.last_name},</p>
    <p>You have requested to reset your password. Click the link below to reset your password:</p>
    <p><a href="${config.frontend.url}/reset-password?token=${resetToken}">Reset Password</a></p>
    <p>This link will expire in 1 hour.</p>
    <p>If you did not request this reset, please ignore this email.</p>
    <p>Thank you,</p>
    <p>The RDF System Team</p>
  `;
  
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send EOG expiry warning email
 * @param {Object} eog EOG object
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @param {number} daysRemaining Days remaining until expiry
 * @returns {Promise<number>} Email log ID
 */
const sendExpiryWarning = async (eog, user, daysRemaining) => {
  const subject = `RDF System - Your EOG Account Will Expire in ${daysRemaining} Days`;
  const body = `
    <h1>EOG Account Expiry Warning</h1>
    <p>Hello ${user.first_name} ${user.last_name},</p>
    <p>Your EOG account for "${eog.company_name}" will expire in ${daysRemaining} days.</p>
    <p>To prevent your account from expiring, please complete your registration and submit for CDO review.</p>
    <p>Required steps:</p>
    <ol>
      <li>Upload all required documents</li>
      <li>Add at least 10 executive members</li>
      <li>Submit for CDO review</li>
    </ol>
    <p>Thank you,</p>
    <p>The RDF System Team</p>
  `;
  
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send EOG approval notification
 * @param {Object} eog EOG object
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @returns {Promise<number>} Email log ID
 */
const sendApprovalNotification = async (eog, user) => {
  const subject = 'RDF System - EOG Account Approved';
  const body = `
    <h1>EOG Account Approved</h1>
    <p>Hello ${user.first_name} ${user.last_name},</p>
    <p>Congratulations! Your EOG account for "${eog.company_name}" has been approved.</p>
    <p>You can now log in and submit applications for funding.</p>
    <p>Thank you,</p>
    <p>The RDF System Team</p>
  `;
  
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send application status notification
 * @param {Object} application Application object
 * @param {Array<Object>} users Array of user objects to notify
 * @param {string} action Action taken on application
 * @param {string} comment Optional comment
 * @returns {Promise<Array<number>>} Array of email log IDs
 */
const sendApplicationNotification = async (application, users, action, comment = '') => {
  const subject = `RDF System - Application ${application.reference_number} Update`;
  
  const emailPromises = users.map(user => {
    const body = `
      <h1>Application Update</h1>
      <p>Hello ${user.first_name} ${user.last_name},</p>
      <p>Application <strong>${application.reference_number}</strong> has been ${action}.</p>
      ${comment ? `<p><strong>Comment:</strong> ${comment}</p>` : ''}
      <p>Current status: ${application.status}</p>
      <p>Current level: ${application.current_level}</p>
      <p>Progress: ${application.progress_percentage}%</p>
      <p>Thank you,</p>
      <p>The RDF System Team</p>
    `;
    
    return sendEmail(user.email, subject, body, user.id);
  });
  
  return Promise.all(emailPromises);
};

module.exports = {
  sendEmail,
  sendWelcomeEmail,
  sendOTPEmail,
  sendPasswordResetEmail,
  sendExpiryWarning,
  sendApprovalNotification,
  sendApplicationNotification
};