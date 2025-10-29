const nodemailer = require('nodemailer');
const db = require('../../config/database');

class EmailService {
  constructor() {
    // Configure transporter based on environment
    if (process.env.SENDGRID_API_KEY) {
      // SendGrid configuration
      this.transporter = nodemailer.createTransport({
        host: 'smtp.sendgrid.net',
        port: 587,
        secure: false,
        auth: {
          user: 'apikey',
          pass: process.env.SENDGRID_API_KEY
        }
      });
    } else {
      // Fallback to console logging for development
      console.warn('⚠️  SENDGRID_API_KEY not configured. Emails will be logged to console.');
      this.transporter = null;
    }
  }

  /**
   * Send email
   */
  async sendEmail({ to, subject, text, html, cc = [], bcc = [] }) {
    try {
      const mailOptions = {
        from: `${process.env.EMAIL_FROM_NAME || 'RDF System'} <${process.env.EMAIL_FROM || 'noreply@rdf.gov.sz'}>`,
        to,
        subject,
        text,
        html,
        cc,
        bcc
      };

      let messageId = null;

      if (this.transporter) {
        const info = await this.transporter.sendMail(mailOptions);
        messageId = info.messageId;
        console.log('✓ Email sent:', info.messageId);
      } else {
        // Log to console in development
        console.log('📧 EMAIL (Development Mode):');
        console.log('To:', to);
        console.log('Subject:', subject);
        console.log('Body:', text || html);
        messageId = `dev-${Date.now()}`;
      }

      // Log email to database
      await this.logEmail({
        recipient_email: to,
        subject,
        body: text || html,
        status: 'sent',
        message_id: messageId
      });

      return { success: true, messageId };
    } catch (error) {
      console.error('Email send error:', error);
      
      // Log failed email
      await this.logEmail({
        recipient_email: to,
        subject,
        body: text || html,
        status: 'failed',
        error_message: error.message
      });

      return { success: false, error: error.message };
    }
  }

  /**
   * Send OTP email
   */
  async sendOTPEmail(user, otp, purpose = 'signature') {
    const subject = 'Your OTP Code - RDF System';
    const text = `
Dear ${user.first_name} ${user.last_name},

Your OTP code for ${purpose} is: ${otp}

This code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.

If you did not request this code, please ignore this email or contact the administrator.

Best regards,
RDF System Team
    `;

    const html = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .otp-box { background: #f4f4f4; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 5px; border-radius: 5px; margin: 20px 0; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h2>RDF System - OTP Verification</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    <p>Your OTP code for <strong>${purpose}</strong> is:</p>
    <div class="otp-box">${otp}</div>
    <p>This code will expire in ${process.env.OTP_EXPIRY_MINUTES || 10} minutes.</p>
    <p>If you did not request this code, please ignore this email or contact the administrator.</p>
    <div class="footer">
      <p>Best regards,<br>RDF System Team</p>
      <p>This is an automated message. Please do not reply to this email.</p>
    </div>
  </div>
</body>
</html>
    `;

    return await this.sendEmail({
      to: user.email,
      subject,
      text,
      html
    });
  }

  /**
   * Send application status email
   */
  async sendApplicationStatusEmail(user, application, status, comments = '') {
    const statusMessages = {
      'approved': 'Your application has been approved and moved to the next level.',
      'returned': 'Your application has been returned for corrections.',
      'recommended': 'Your application has been recommended for further review.',
      'completed': 'Your application has been completed successfully!'
    };

    const subject = `Application ${application.reference_number} - ${status.toUpperCase()}`;
    const text = `
Dear ${user.first_name} ${user.last_name},

${statusMessages[status] || 'Your application status has been updated.'}

Application Reference: ${application.reference_number}
Current Status: ${status}
Current Level: ${application.current_level}

${comments ? `Comments: ${comments}` : ''}

Please log in to the RDF System to view the details.

Best regards,
RDF System Team
    `;

    const html = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .status-box { background: #f4f4f4; padding: 15px; border-left: 4px solid #007bff; margin: 20px 0; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Application Status Update</h2>
    <p>Dear ${user.first_name} ${user.last_name},</p>
    <p>${statusMessages[status] || 'Your application status has been updated.'}</p>
    <div class="status-box">
      <p><strong>Application Reference:</strong> ${application.reference_number}</p>
      <p><strong>Current Status:</strong> ${status}</p>
      <p><strong>Current Level:</strong> ${application.current_level}</p>
    </div>
    ${comments ? `<p><strong>Comments:</strong> ${comments}</p>` : ''}
    <p>Please log in to the RDF System to view the details.</p>
    <div class="footer">
      <p>Best regards,<br>RDF System Team</p>
    </div>
  </div>
</body>
</html>
    `;

    return await this.sendEmail({
      to: user.email,
      subject,
      text,
      html
    });
  }

  /**
   * Send EOG registration email
   */
  async sendEOGRegistrationEmail(eog, tempCredentials) {
    const subject = 'EOG Registration - Temporary Account Created';
    const text = `
Dear ${eog.company_name},

Your Expression of Interest has been received successfully. A temporary account has been created for your organization.

Company Name: ${eog.company_name}
BIN/CIN: ${eog.bin_cin}
Username: ${tempCredentials.username}
Temporary Password: ${tempCredentials.password}

This temporary account will expire in ${process.env.TEMP_ACCOUNT_EXPIRY_DAYS || 30} days.

Please complete your registration by:
1. Uploading all required documents
2. Verifying your executive members
3. Setting up your permanent login credentials

Login at: ${process.env.FRONTEND_URL || 'http://localhost:8080'}

Best regards,
RDF System Team
    `;

    const html = `
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .credentials-box { background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
    .warning { color: #856404; font-weight: bold; }
    .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666; }
  </style>
</head>
<body>
  <div class="container">
    <h2>EOG Registration - Temporary Account</h2>
    <p>Dear ${eog.company_name},</p>
    <p>Your Expression of Interest has been received successfully. A temporary account has been created for your organization.</p>
    <div class="credentials-box">
      <p><strong>Company Name:</strong> ${eog.company_name}</p>
      <p><strong>BIN/CIN:</strong> ${eog.bin_cin}</p>
      <p><strong>Username:</strong> ${tempCredentials.username}</p>
      <p><strong>Temporary Password:</strong> ${tempCredentials.password}</p>
      <p class="warning">⚠️ This account expires in ${process.env.TEMP_ACCOUNT_EXPIRY_DAYS || 30} days</p>
    </div>
    <p><strong>Next Steps:</strong></p>
    <ol>
      <li>Upload all required documents</li>
      <li>Verify your executive members</li>
      <li>Set up your permanent login credentials</li>
    </ol>
    <p><a href="${process.env.FRONTEND_URL || 'http://localhost:8080'}" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;">Login Now</a></p>
    <div class="footer">
      <p>Best regards,<br>RDF System Team</p>
    </div>
  </div>
</body>
</html>
    `;

    return await this.sendEmail({
      to: eog.email,
      subject,
      text,
      html
    });
  }

  /**
   * Log email to database
   */
  async logEmail({ recipient_email, subject, body, status, message_id = null, error_message = null }) {
    try {
      await db.query(
        `INSERT INTO email_logs (recipient_email, subject, body, status, message_id, error_message, sent_at)
         VALUES (?, ?, ?, ?, ?, ?, NOW())`,
        [recipient_email, subject, body, status, message_id, error_message]
      );
    } catch (error) {
      console.error('Failed to log email:', error);
    }
  }

  /**
   * Get email logs
   */
  async getEmailLogs(filters = {}, limit = 50) {
    let query = 'SELECT * FROM email_logs WHERE 1=1';
    const params = [];

    if (filters.recipient_email) {
      query += ' AND recipient_email = ?';
      params.push(filters.recipient_email);
    }

    if (filters.status) {
      query += ' AND status = ?';
      params.push(filters.status);
    }

    if (filters.from_date) {
      query += ' AND sent_at >= ?';
      params.push(filters.from_date);
    }

    if (filters.to_date) {
      query += ' AND sent_at <= ?';
      params.push(filters.to_date);
    }

    query += ' ORDER BY sent_at DESC LIMIT ?';
    params.push(limit);

    return await db.query(query, params);
  }
}

module.exports = new EmailService();
