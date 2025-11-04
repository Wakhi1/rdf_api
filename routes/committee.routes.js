const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, schemas } = require('../middleware/validation.middleware');
const { sendEmail } = require('../utils/email');
const { createOTP, verifyOTP } = require('../utils/otp');

/**
 * @route   GET /api/committees/types/:type
 * @desc    Get committees by type
 * @access  Private
 */
router.get('/types/:type', authenticate, async (req, res) => {
  try {
    const { type } = req.params;
    
    // Validate committee type
    const validTypes = ['CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        error: 'Validation Error',
        message: 'Committee type must be one of: CDC, INKHUNDLA_COUNCIL, RDFTC, RDFC'
      });
    }
    
    const committees = await db.query(`
      SELECT c.*, r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
      FROM committees c
      LEFT JOIN regions r ON c.region_id = r.id
      LEFT JOIN tinkhundla t ON c.tinkhundla_id = t.id
      LEFT JOIN imiphakatsi i ON c.umphakatsi_id = i.id
      WHERE c.type = ? AND c.is_active = TRUE
      ORDER BY c.name ASC
    `, [type]);
    
    return res.status(200).json({
      success: true,
      data: committees
    });
  } catch (error) {
    logger.error(`Get committees by type error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/committees/:id
 * @desc    Get committee details with members
 * @access  Private
 */
router.get('/:id', 
  authenticate, 
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params;
      
      // Get committee details
      const committee = await db.getOne(`
        SELECT c.*, r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
        FROM committees c
        LEFT JOIN regions r ON c.region_id = r.id
        LEFT JOIN tinkhundla t ON c.tinkhundla_id = t.id
        LEFT JOIN imiphakatsi i ON c.umphakatsi_id = i.id
        WHERE c.id = ?
      `, [id]);
      
      if (!committee) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Committee not found'
        });
      }
      
      // Get committee members
      const members = await db.query(`
        SELECT cm.*, u.first_name, u.last_name, u.email, u.phone, u.role
        FROM committee_members cm
        JOIN users u ON cm.user_id = u.id
        WHERE cm.committee_id = ?
        ORDER BY 
          CASE WHEN cm.is_chairperson = TRUE THEN 0 ELSE 1 END,
          cm.position ASC
      `, [id]);
      
      return res.status(200).json({
        success: true,
        data: {
          ...committee,
          members
        }
      });
    } catch (error) {
      logger.error(`Get committee details error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/committees/member/pending-approvals
 * @desc    Get applications pending approval for committee member
 * @access  Private
 */
router.get('/member/pending-approvals', authenticate, async (req, res) => {
  try {
    const userId = req.user.id;
    
    // Get committees the user belongs to
    const userCommittees = await db.query(`
      SELECT 
        cm.id as committee_member_id, 
        cm.committee_id, 
        c.name as committee_name, 
        c.type as committee_type,
        c.region_id,
        c.tinkhundla_id,
        c.umphakatsi_id
      FROM committee_members cm
      JOIN committees c ON cm.committee_id = c.id
      WHERE cm.user_id = ? AND c.is_active = TRUE
    `, [userId]);
    
    if (userCommittees.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        message: 'You are not a member of any committee'
      });
    }
    
    // Get applications pending approval for each committee
    let pendingApprovals = [];
    
    for (const committee of userCommittees) {
      // Map committee types to workflow levels
      const workflowLevelMap = {
        'CDC': 'UMPHAKATSI_LEVEL',
        'INKHUNDLA_COUNCIL': 'INKHUNDLA_LEVEL',
        'RDFTC': 'RDFTC_LEVEL',
        'RDFC': 'RDFC_LEVEL'
      };
      
      const workflowLevel = workflowLevelMap[committee.committee_type];
      
      if (!workflowLevel) continue;
      
      const applications = await db.query(`
        SELECT 
          a.id, 
          a.reference_number, 
          a.funding_amount,
          e.company_name as eog_name,
          r.name as region_name,
          t.name as tinkhundla_name,
          a.submitted_at,
          DATEDIFF(NOW(), a.submitted_at) as days_in_system,
          (SELECT COUNT(*) FROM committee_approvals WHERE application_id = a.id AND committee_id = ?) as signatures_count,
          (SELECT COUNT(*) FROM committee_members WHERE committee_id = ?) as total_members,
          CASE
            WHEN EXISTS (
              SELECT 1 FROM committee_approvals 
              WHERE application_id = a.id AND committee_member_id = ?
            )
            THEN 1 ELSE 0
          END as signed_by_me
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        JOIN regions r ON e.region_id = r.id
        JOIN tinkhundla t ON e.tinkhundla_id = t.id
        WHERE a.current_level = ? 
          AND a.status IN ('pending', 'in_review')
        ORDER BY a.submitted_at ASC
      `, [committee.committee_id, committee.committee_id, committee.committee_member_id, workflowLevel]);
      
      if (applications.length > 0) {
        pendingApprovals = pendingApprovals.concat(
          applications.map(app => ({
            ...app,
            committee_id: committee.committee_id,
            committee_name: committee.committee_name,
            committee_type: committee.committee_type,
            committee_member_id: committee.committee_member_id
          }))
        );
      }
    }
    
    return res.status(200).json({
      success: true,
      data: pendingApprovals
    });
  } catch (error) {
    logger.error(`Get pending approvals error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/committees/applications/:applicationId/approval-status
 * @desc    Get approval status for specific application
 * @access  Private
 */
router.get('/applications/:applicationId/approval-status', 
  authenticate,
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      
      // Get application details
      const application = await db.getOne(`
        SELECT a.*, e.company_name as eog_name, e.region_id, e.tinkhundla_id, e.umphakatsi_id
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        WHERE a.id = ?
      `, [applicationId]);
      
      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }
      
      // Map workflow level to committee type
      const committeeTypeMap = {
        'UMPHAKATSI_LEVEL': 'CDC',
        'INKHUNDLA_LEVEL': 'INKHUNDLA_COUNCIL',
        'RDFTC_LEVEL': 'RDFTC',
        'RDFC_LEVEL': 'RDFC'
      };
      
      const committeeType = committeeTypeMap[application.current_level];
      
      if (!committeeType) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: `Application is not at a committee level (current: ${application.current_level})`
        });
      }
      
      // Get the appropriate committee
      let committee;
      if (application.current_level === 'UMPHAKATSI_LEVEL') {
        committee = await db.getOne(`
          SELECT c.* FROM committees c
          WHERE c.type = ? AND c.umphakatsi_id = ? AND c.is_active = TRUE
        `, [committeeType, application.umphakatsi_id]);
      } else if (application.current_level === 'INKHUNDLA_LEVEL') {
        committee = await db.getOne(`
          SELECT c.* FROM committees c
          WHERE c.type = ? AND c.tinkhundla_id = ? AND c.is_active = TRUE
        `, [committeeType, application.tinkhundla_id]);
      } else {
        committee = await db.getOne(`
          SELECT c.* FROM committees c
          WHERE c.type = ? AND c.region_id = ? AND c.is_active = TRUE
        `, [committeeType, application.region_id]);
      }
      
      if (!committee) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'No active committee found for this application'
        });
      }
      
      // Get committee members
      const members = await db.query(`
        SELECT 
          cm.id,
          cm.user_id,
          cm.position,
          cm.is_chairperson,
          u.first_name,
          u.last_name,
          u.email,
          CASE 
            WHEN EXISTS (
              SELECT 1 FROM committee_approvals ca
              WHERE ca.committee_member_id = cm.id AND ca.application_id = ?
            )
            THEN 1 ELSE 0
          END as has_signed
        FROM committee_members cm
        JOIN users u ON cm.user_id = u.id
        WHERE cm.committee_id = ?
        ORDER BY 
          CASE WHEN cm.is_chairperson = TRUE THEN 0 ELSE 1 END,
          cm.position ASC
      `, [applicationId, committee.id]);
      
      // Get approval details
      const approvals = await db.query(`
        SELECT 
          ca.*,
          cm.position,
          cm.is_chairperson,
          u.first_name,
          u.last_name
        FROM committee_approvals ca
        JOIN committee_members cm ON ca.committee_member_id = cm.id
        JOIN users u ON cm.user_id = u.id
        WHERE ca.application_id = ?
        ORDER BY ca.signed_at DESC
      `, [applicationId]);
      
      const totalMembers = members.length;
      const signedMembers = members.filter(m => m.has_signed === 1).length;
      const approvalPercentage = totalMembers > 0 ? Math.round((signedMembers / totalMembers) * 100) : 0;
      
      return res.status(200).json({
        success: true,
        data: {
          application: {
            id: application.id,
            reference_number: application.reference_number,
            eog_name: application.eog_name,
            current_level: application.current_level,
            status: application.status
          },
          committee: {
            id: committee.id,
            name: committee.name,
            type: committee.type
          },
          approval_status: {
            total_members: totalMembers,
            signed_members: signedMembers,
            percentage: approvalPercentage,
            is_complete: signedMembers === totalMembers
          },
          members,
          approvals
        }
      });
    } catch (error) {
      logger.error(`Get approval status error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/committees/send-otp
 * @desc    Send OTP to committee member for verification
 * @access  Private
 */
router.post('/send-otp',
  authenticate,
  async (req, res) => {
    try {
      const { application_id } = req.body;
      
      // Validate required fields
      if (!application_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Application ID is required'
        });
      }
      
      // Verify application exists
      const application = await db.getOne(`
        SELECT a.*, e.company_name 
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        WHERE a.id = ?
      `, [application_id]);
      
      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }
      
      // Map workflow level to committee type
      const committeeTypeMap = {
        'UMPHAKATSI_LEVEL': 'CDC',
        'INKHUNDLA_LEVEL': 'INKHUNDLA_COUNCIL',
        'RDFTC_LEVEL': 'RDFTC',
        'RDFC_LEVEL': 'RDFC'
      };
      
      const committeeType = committeeTypeMap[application.current_level];
      
      if (!committeeType) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: `Application is not at a committee level (current: ${application.current_level})`
        });
      }
      
      // Verify user is a member of this committee
      const committeeMember = await db.getOne(`
        SELECT cm.*, c.name as committee_name
        FROM committee_members cm
        JOIN committees c ON cm.committee_id = c.id
        WHERE cm.user_id = ? AND c.type = ? AND c.is_active = TRUE
      `, [req.user.id, committeeType]);
      
      if (!committeeMember) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You are not a member of the required committee'
        });
      }
      
      // Generate OTP using createOTP
      const otpCode = await createOTP(
        req.user.id,
        'verification', // This should match what verifyOTP looks for
        parseInt(application_id),
        'applications'
      );
      
      // Calculate expiry time
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
      
      // Send OTP email
      await sendEmail(
        req.user.email,
        `Committee Verification - ${application.reference_number}`,
        `
        <h1>Committee Member Verification</h1>
        <p>Hello ${req.user.first_name} ${req.user.last_name},</p>
        <p>You have requested to advance application <strong>${application.reference_number}</strong> (${application.company_name}).</p>
        <p>Your verification code is: <strong style="font-size: 24px; color: #2563eb;">${otpCode}</strong></p>
        <p>This code will expire in 10 minutes.</p>
        <p>If you did not request this code, please ignore this email.</p>
        <p>Thank you,</p>
        <p>The RDF System</p>
        `
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'otp_sent',
        'applications',
        application_id,
        { 
          purpose: 'verification',
          committee_type: committeeType 
        },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'OTP sent to your email',
        data: {
          expires_at: expiresAt
        }
      });
    } catch (error) {
      logger.error(`Send OTP error: ${error.message}`);
      logger.error(error.stack);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/committees/:committeeId/approve-application
 * @desc    Approve/sign application as committee member
 * @access  Private
 */
router.post('/:committeeId/approve-application',
  authenticate,
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { committeeId } = req.params;
      const { application_id, decision, comments, otp_code } = req.body;
      
      // Validate required fields
      if (!application_id || !decision) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Application ID and decision are required'
        });
      }
      
      if (!['approved', 'rejected'].includes(decision)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Decision must be either approved or rejected'
        });
      }
      
      // Verify user is a member of this committee
      const committeeMember = await db.getOne(`
        SELECT * FROM committee_members 
        WHERE committee_id = ? AND user_id = ?
      `, [committeeId, req.user.id]);
      
      if (!committeeMember) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You are not a member of this committee'
        });
      }
      
      // Verify application exists
      const application = await db.getOne(`
        SELECT * FROM applications WHERE id = ?
      `, [application_id]);
      
      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }
      
      // Check if already signed
      const existingApproval = await db.getOne(`
        SELECT * FROM committee_approvals 
        WHERE application_id = ? AND committee_member_id = ?
      `, [application_id, committeeMember.id]);
      
      if (existingApproval) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'You have already signed this application'
        });
      }
      
      // Verify OTP if provided
      let otp_id = null;
      if (otp_code) {
        const otpVerification = await verifyOTP(req.user.id, otp_code, 'signature');
        if (!otpVerification.valid) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: otpVerification.message || 'Invalid OTP'
          });
        }
        otp_id = otpVerification.otp_id;
      }
      
      // Map workflow level
      const workflowLevelMap = {
        'CDC': 'UMPHAKATSI_LEVEL',
        'INKHUNDLA_COUNCIL': 'INKHUNDLA_LEVEL',
        'RDFTC': 'RDFTC_LEVEL',
        'RDFC': 'RDFC_LEVEL'
      };
      
      const committee = await db.getOne('SELECT * FROM committees WHERE id = ?', [committeeId]);
      const workflowLevel = workflowLevelMap[committee.type];
      
      // Create approval record
      const result = await db.insert('committee_approvals', {
        application_id,
        committee_id: committeeId,
        committee_member_id: committeeMember.id,
        workflow_level: workflowLevel,
        signature_otp_id: otp_id,
        decision,
        comments: comments || null
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_signed',
        'applications',
        application_id,
        { decision, committee_id: committeeId },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(201).json({
        success: true,
        message: `Application ${decision} successfully`,
        data: {
          id: result.id,
          application_id,
          decision,
          signed_at: new Date()
        }
      });
    } catch (error) {
      logger.error(`Approve application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/committees
 * @desc    Create new committee
 * @access  Private (SUPER_USER only)
 */
router.post('/', 
  authenticate, 
  requireRole(['SUPER_USER']),
  async (req, res) => {
    try {
      const { name, type, region_id, tinkhundla_id, umphakatsi_id } = req.body;
      
      // Validate required fields
      if (!name || !type) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name and type are required'
        });
      }
      
      // Validate committee type
      const validTypes = ['CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC'];
      if (!validTypes.includes(type)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Type must be one of: ${validTypes.join(', ')}`
        });
      }
      
      // Create committee
      const result = await db.insert('committees', {
        name,
        type,
        region_id: region_id || null,
        tinkhundla_id: tinkhundla_id || null,
        umphakatsi_id: umphakatsi_id || null
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'committee_created',
        'committees',
        result.id,
        { name, type },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created committee
      const committee = await db.getOne(
        'SELECT * FROM committees WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Committee created successfully',
        data: committee
      });
    } catch (error) {
      logger.error(`Create committee error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/committees/:id/members
 * @desc    Add member to committee
 * @access  Private (SUPER_USER only)
 */
router.post('/:id/members', 
  authenticate, 
  requireRole(['SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { id } = req.params; // Changed from committeeId to id
      const {user_id, position, is_chairperson } = req.body;
      
      // Validate required fields
      if (!user_id || !position) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'User ID and position are required'
        });
      }
      
      // Verify committee exists
      const committee = await db.getOne(
        'SELECT * FROM committees WHERE id = ?',
        [id] // Use id instead of committeeId
      );
      
      if (!committee) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Committee not found'
        });
      }
      
      // Verify user exists
      const user = await db.getOne(
        'SELECT * FROM users WHERE id = ?',
        [user_id]
      );
      
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'User not found'
        });
      }
      
      // Check if already a member
      const existingMember = await db.getOne(
        'SELECT id FROM committee_members WHERE committee_id = ? AND user_id = ?',
        [id, user_id] // Use id instead of committeeId
      );
      
      if (existingMember) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'User is already a member of this committee'
        });
      }
      
      // If adding as chairperson, check if one already exists
      if (is_chairperson) {
        const existingChairperson = await db.getOne(
          'SELECT id FROM committee_members WHERE committee_id = ? AND is_chairperson = TRUE',
          [id] // Use id instead of committeeId
        );
        
        if (existingChairperson) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Committee already has a chairperson'
          });
        }
      }
      
      // Add member
      const result = await db.insert('committee_members', {
        committee_id: id, // Use id instead of committeeId
        user_id,
        position,
        is_chairperson: is_chairperson || false
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'committee_member_added',
        'committees',
        id, // Use id instead of committeeId
        { user_id, position, is_chairperson },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get member details
      const member = await db.getOne(`
        SELECT cm.*, u.first_name, u.last_name, u.email, u.phone
        FROM committee_members cm
        JOIN users u ON cm.user_id = u.id
        WHERE cm.id = ?
      `, [result.id]);
      
      return res.status(201).json({
        success: true,
        message: 'Member added successfully',
        data: member
      });
    } catch (error) {
      logger.error(`Add committee member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/committees/:committeeId/members/:memberId
 * @desc    Remove member from committee
 * @access  Private (SUPER_USER only)
 */
router.delete('/:committeeId/members/:memberId', 
  authenticate, 
  requireRole(['SUPER_USER']),
  async (req, res) => {
    try {
      const { committeeId, memberId } = req.params;
      
      // Verify member exists
      const member = await db.getOne(`
        SELECT cm.*, u.first_name, u.last_name 
        FROM committee_members cm
        JOIN users u ON cm.user_id = u.id
        WHERE cm.id = ? AND cm.committee_id = ?
      `, [memberId, committeeId]);
      
      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found'
        });
      }
      
      // Delete member
      await db.delete('committee_members', 'id = ?', [memberId]);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'committee_member_removed',
        'committees',
        committeeId,
        { member_id: memberId, name: `${member.first_name} ${member.last_name}` },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Member removed successfully'
      });
    } catch (error) {
      logger.error(`Remove committee member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;