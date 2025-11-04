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
 * Get email template with header and footer
 * @param {string} content Main email content
 * @param {string} title Email title
 * @returns {string} Formatted email HTML
 */
const getEmailTemplate = (content, title = '') => {
  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>${title}</title>
      <style>
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
          line-height: 1.6; 
          color: #333; 
          margin: 0; 
          padding: 0; 
          background-color: #f5f5f5;
        }
        .email-container { 
          max-width: 600px; 
          margin: 0 auto; 
          background-color: #ffffff; 
        }
        .email-header { 
          background: linear-gradient(135deg, #3a7bd5, #00d2ff);
          color: white; 
          padding: 30px 40px; 
          text-align: center;
        }
        .email-header h1 { 
          margin: 0; 
          font-size: 24px; 
          font-weight: 600;
        }
        .email-body { 
          padding: 40px; 
        }
        .email-footer { 
          background-color: #2c3e50; 
          color: #ecf0f1; 
          padding: 25px 40px; 
          text-align: center; 
          font-size: 14px;
          border-top: 4px solid #e74c3c;
        }
        .flag-container {
          margin: 15px 0;
          padding: 10px;
          background: rgba(255,255,255,0.1);
          border-radius: 5px;
          display: inline-block;
        }
        .flag-symbol {
          font-size: 24px;
          margin: 0 10px;
          vertical-align: middle;
        }
        .ministry-info {
          margin: 10px 0;
          font-weight: 600;
          color: #3498db;
        }
        .button {
          display: inline-block;
          background: linear-gradient(135deg, #e74c3c, #c0392b);
          color: white;
          padding: 14px 28px;
          text-decoration: none;
          border-radius: 5px;
          font-weight: 600;
          margin: 20px 0;
          text-align: center;
        }
        .notice {
          background-color: #fff9e6;
          border-left: 4px solid #f1c40f;
          padding: 15px;
          margin: 20px 0;
          border-radius: 0 4px 4px 0;
        }
        .credentials {
          background-color: #f8f9fa;
          border: 1px solid #e9ecef;
          padding: 20px;
          border-radius: 5px;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <div class="email-container">
        <div class="email-header">
          <h1>Ministry of Tinkhundla Administration and Development</h1>
          <p>Kingdom of Eswatini</p>
        </div>
        
        <div class="email-body">
          ${content}
        </div>
        
        <div class="email-footer">
          <div class="flag-container">
            <span class="flag-symbol">🇸🇿</span>
            <strong>Kingdom of Eswatini</strong>
            <span class="flag-symbol">🇸🇿</span>
          </div>
          <div class="ministry-info">Ministry of Tinkhundla Administration and Development</div>
          <p>
            Mbabane, Eswatini<br>
            Email: info@mtad.gov.sz | Phone: +268 2404 2000<br>
            Working towards regional development and community empowerment
          </p>
          <p style="font-size: 12px; color: #bdc3c7; margin-top: 15px;">
            This email was sent automatically. Please do not reply to this message.<br>
            © ${new Date().getFullYear()} Ministry of Tinkhundla Administration and Development. All rights reserved.
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
};

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
  const subject = 'Welcome to the Regional Development Fund System - Ministry of Tinkhundla Administration and Development';
  const content = `
    <h2>Welcome to the Regional Development Fund System</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    
    <p>On behalf of the Ministry of Tinkhundla Administration and Development, we are pleased to welcome you to the Regional Development Fund (RDF) System. This platform is designed to facilitate development initiatives across the regions of Eswatini.</p>
    
    <div class="credentials">
      <h3 style="margin-top: 0; color: #2c3e50;">Your Account Credentials</h3>
      <p><strong>Username:</strong> ${user.username}</p>
      <p><strong>Temporary Password:</strong> ${password}</p>
    </div>
    
    <div class="notice">
      <strong>Security Notice:</strong> For the security of your account, please change your password immediately after your first login.
    </div>
    
    <p>You can access the system by visiting: <strong>${config.frontend.url}</strong></p>
    
    <p>This system will enable you to submit and track development fund applications, manage your organization profile, and collaborate with regional development officers.</p>
    
    <p>Should you require any assistance, please contact our support team at <strong>rdf-support@mtad.gov.sz</strong> or call <strong>+268 2404 2015</strong>.</p>
    
    <p>We look forward to supporting your development initiatives.</p>
    
    <p>Yours in service,<br>
    <strong>Regional Development Fund Team</strong><br>
    Ministry of Tinkhundla Administration and Development</p>
  `;
  
  const body = getEmailTemplate(content, 'Welcome to RDF System');
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
  const subject = 'Verification Code - Regional Development Fund System';
  const content = `
    <h2>Account Verification</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    
    <p>You have requested a verification code for ${purpose} in the Regional Development Fund System.</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <div style="font-size: 32px; letter-spacing: 8px; font-weight: bold; color: #e74c3c; background: #f8f9fa; padding: 20px; border-radius: 8px; display: inline-block;">
        ${otpCode}
      </div>
    </div>
    
    <div class="notice">
      <strong>This verification code will expire in 10 minutes.</strong><br>
      Please use it immediately to complete your verification process.
    </div>
    
    <p>If you did not request this verification code, please disregard this email or contact our support team immediately at <strong>rdf-support@mtad.gov.sz</strong>.</p>
    
    <p>For security reasons, do not share this code with anyone.</p>
    
    <p>Yours in service,<br>
    <strong>Regional Development Fund Team</strong><br>
    Ministry of Tinkhundla Administration and Development</p>
  `;
  
  const body = getEmailTemplate(content, 'Verification Code');
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send password reset email
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @param {string} resetToken Reset token
 * @returns {Promise<number>} Email log ID
 */
const sendPasswordResetEmail = async (user, resetToken) => {
  const subject = 'Password Reset Request - Regional Development Fund System';
  const content = `
    <h2>Password Reset Request</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    
    <p>We received a request to reset your password for the Regional Development Fund System account.</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <a href="${config.frontend.url}/reset-password?token=${resetToken}" class="button">
        Reset Your Password
      </a>
    </div>
    
    <p>Alternatively, you can copy and paste the following link in your browser:</p>
    <p style="word-break: break-all; color: #3498db;">${config.frontend.url}/reset-password?token=${resetToken}</p>
    
    <div class="notice">
      <strong>This password reset link will expire in 1 hour.</strong><br>
      If you did not request a password reset, please ignore this email and ensure your account security.
    </div>
    
    <p>For security purposes, we recommend that you:</p>
    <ul>
      <li>Create a strong password that you haven't used before</li>
      <li>Enable two-factor authentication if available</li>
      <li>Contact us immediately if you suspect any unauthorized access</li>
    </ul>
    
    <p>Yours in service,<br>
    <strong>Regional Development Fund Team</strong><br>
    Ministry of Tinkhundla Administration and Development</p>
  `;
  
  const body = getEmailTemplate(content, 'Password Reset');
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
  const subject = `Action Required: EOG Registration Expiring in ${daysRemaining} Days - Ministry of Tinkhundla Administration and Development`;
  const content = `
    <h2>EOG Registration Expiry Notice</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    
    <p>This is to inform you that your Economic Operators Group (EOG) registration for <strong>"${eog.company_name}"</strong> will expire in <strong style="color: #e74c3c;">${daysRemaining} days</strong>.</p>
    
    <div class="notice">
      <strong>Immediate Action Required:</strong> To maintain your EOG status and continue accessing development funds, please complete the following requirements before the expiry date.
    </div>
    
    <h3 style="color: #2c3e50;">Required Completion Steps:</h3>
    <ol>
      <li><strong>Upload all required documentation</strong> including registration certificates and compliance documents</li>
      <li><strong>Register at least 10 executive members</strong> in your EOG profile</li>
      <li><strong>Submit your completed profile</strong> for Chief Development Officer (CDO) review and approval</li>
    </ol>
    
    <p>Failure to complete these requirements before the expiry date will result in the suspension of your EOG status and may affect your ability to apply for regional development funds.</p>
    
    <p>You can access your EOG profile and complete these requirements by logging into the RDF System at: <strong>${config.frontend.url}</strong></p>
    
    <p>If you require assistance with the completion process, please contact your regional CDO or our support team at <strong>eog-support@mtad.gov.sz</strong>.</p>
    
    <p>Yours in service,<br>
    <strong>Economic Operators Group Registry</strong><br>
    Ministry of Tinkhundla Administration and Development</p>
  `;
  
  const body = getEmailTemplate(content, 'EOG Expiry Warning');
  return sendEmail(user.email, subject, body, user.id);
};

/**
 * Send EOG approval notification
 * @param {Object} eog EOG object
 * @param {Object} user User object with properties: id, email, first_name, last_name
 * @returns {Promise<number>} Email log ID
 */
const sendApprovalNotification = async (eog, user) => {
  const subject = 'Congratulations! EOG Registration Approved - Ministry of Tinkhundla Administration and Development';
  const content = `
    <h2>EOG Registration Approved</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    
    <div style="text-align: center; background: linear-gradient(135deg, #27ae60, #2ecc71); color: white; padding: 30px; border-radius: 8px; margin: 20px 0;">
      <h3 style="margin: 0; font-size: 28px;">🎉 Congratulations! 🎉</h3>
      <p style="font-size: 18px; margin: 10px 0 0 0;">Your EOG registration has been approved!</p>
    </div>
    
    <p>We are pleased to inform you that your Economic Operators Group (EOG) registration for <strong>"${eog.company_name}"</strong> has been successfully approved by the Ministry of Tinkhundla Administration and Development.</p>
    
    <h3 style="color: #2c3e50;">What This Means For You:</h3>
    <ul>
      <li>You are now eligible to apply for Regional Development Fund opportunities</li>
      <li>Your EOG can participate in government development initiatives</li>
      <li>You have access to capacity building programs and support</li>
      <li>Your organization is officially recognized as a development partner</li>
    </ul>
    
    <p>You can now log into the RDF System and begin submitting applications for development funding that align with your EOG's objectives and capabilities.</p>
    
    <div class="notice">
      <strong>Next Steps:</strong> We encourage you to explore available funding opportunities and attend our upcoming EOG orientation sessions. Check the system announcements for scheduled events.
    </div>
    
    <p>For any queries regarding funding applications or EOG activities, please contact your Regional Development Officer or email <strong>eog-support@mtad.gov.sz</strong>.</p>
    
    <p>We look forward to working with you in advancing regional development in Eswatini.</p>
    
    <p>Yours in partnership,<br>
    <strong>Economic Operators Group Registry</strong><br>
    Ministry of Tinkhundla Administration and Development</p>
  `;
  
  const body = getEmailTemplate(content, 'EOG Approval');
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
  const subject = `Application Update: ${application.reference_number} - Regional Development Fund System`;
  
  const emailPromises = users.map(user => {
    const statusColors = {
      'approved': '#27ae60',
      'rejected': '#e74c3c',
      'pending': '#f39c12',
      'review': '#3498db'
    };
    
    const statusColor = statusColors[application.status] || '#7f8c8d';
    
    const content = `
      <h2>Application Status Update</h2>
      <p>Dear ${user.first_name} ${user.last_name},</p>
      
      <p>This is to inform you that there has been an update to your development fund application.</p>
      
      <div style="background-color: #f8f9fa; border-left: 4px solid ${statusColor}; padding: 20px; margin: 20px 0; border-radius: 0 4px 4px 0;">
        <h3 style="margin-top: 0; color: ${statusColor};">Application ${action}</h3>
        <p><strong>Reference Number:</strong> ${application.reference_number}</p>
        <p><strong>Current Status:</strong> <span style="color: ${statusColor}; font-weight: bold;">${application.status}</span></p>
        <p><strong>Processing Level:</strong> ${application.current_level}</p>
        <p><strong>Progress:</strong> ${application.progress_percentage}% complete</p>
        ${comment ? `<p><strong>Review Comment:</strong> "${comment}"</p>` : ''}
      </div>
      
      <p>You can view the detailed status and any required actions by logging into the RDF System and accessing your application dashboard.</p>
      
      <div style="text-align: center; margin: 25px 0;">
        <a href="${config.frontend.url}/applications/${application.id}" class="button">
          View Application Details
        </a>
      </div>
      
      <p>If you have any questions regarding this update or need clarification on next steps, please contact your assigned Development Officer or our support team at <strong>applications@mtad.gov.sz</strong>.</p>
      
      <p>Thank you for your commitment to regional development in Eswatini.</p>
      
      <p>Yours in service,<br>
      <strong>Applications Processing Team</strong><br>
      Ministry of Tinkhundla Administration and Development</p>
    `;
    
    const body = getEmailTemplate(content, 'Application Update');
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