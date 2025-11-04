const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const emailUtils = require('../utils/email');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, schemas } = require('../middleware/validation.middleware');

/**
 * @route   GET /api/workflow/levels
 * @desc    Get all workflow levels
 * @access  Private
 */
router.get('/levels',
  authenticate,
  async (req, res) => {
    try {
      // Define all workflow levels with their sequence
      const workflowLevels = [
        {
          level: 'EOG_LEVEL',
          name: 'EOG Level',
          description: 'Application creation and submission',
          sequence: 1,
          progress: 0
        },
        {
          level: 'MINISTRY_LEVEL',
          name: 'Line Ministry Level',
          description: 'Review by relevant line ministry',
          sequence: 2,
          progress: 9.09
        },
        {
          level: 'MICROPROJECTS_LEVEL',
          name: 'Microprojects Level',
          description: 'Technical assessment by microprojects team',
          sequence: 3,
          progress: 18.18
        },
        {
          level: 'CDO_LEVEL',
          name: 'CDO Level',
          description: 'Review by Community Development Officer',
          sequence: 4,
          progress: 27.27
        },
        {
          level: 'UMPHAKATSI_LEVEL',
          name: 'Umphakatsi Level (CDC)',
          description: 'Review by Community Development Committee',
          sequence: 5,
          progress: 36.36
        },
        {
          level: 'INKHUNDLA_LEVEL',
          name: 'Inkhundla Level',
          description: 'Review by Inkhundla Council',
          sequence: 6,
          progress: 45.45
        },
        {
          level: 'RDFTC_LEVEL',
          name: 'RDFTC Level',
          description: 'Review by Regional Development Fund Technical Committee',
          sequence: 7,
          progress: 54.54
        },
        {
          level: 'RDFC_LEVEL',
          name: 'RDFC Level',
          description: 'Review by Regional Development Fund Committee',
          sequence: 8,
          progress: 63.63
        },
        {
          level: 'PS_LEVEL',
          name: 'PS Level',
          description: 'Final approval by Principal Secretary',
          sequence: 9,
          progress: 72.72
        },
        {
          level: 'PROCUREMENT_LEVEL',
          name: 'Procurement Level',
          description: 'Procurement of goods and services',
          sequence: 10,
          progress: 81.81
        },
        {
          level: 'IMPLEMENTATION_LEVEL',
          name: 'Implementation Level',
          description: 'Project implementation and monitoring',
          sequence: 11,
          progress: 90.90
        }
      ];

      return res.status(200).json({
        success: true,
        data: workflowLevels
      });
    } catch (error) {
      logger.error(`Get workflow levels error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/workflow/:applicationId/advance
 * @desc    Advance application to next level
 * @access  Private
 */
router.post('/:applicationId/advance',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments, otp_code } = req.body;

      // Get application
      const application = await db.getOne(
        `SELECT a.*, 
                e.company_name, 
                e.region_id, 
                e.tinkhundla_id, 
                e.umphakatsi_id,
                e.id as eog_id
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         WHERE a.id = ?`,
        [applicationId]
      );
      
      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }
      
      // Log location data for debugging
      logger.info(`Application location data - Region: ${application.region_id}, Tinkhundla: ${application.tinkhundla_id}, Umphakatsi: ${application.umphakatsi_id}, EOG: ${application.eog_id}`);

      // Check if user has permission to advance this application
      if (!await canModifyWorkflow(req.user, application)) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have permission to advance this application'
        });
      }

      // NEW: Check if current level is committee level and requires OTP
      const committeeTypeMap = {
        'UMPHAKATSI_LEVEL': 'CDC',
        'INKHUNDLA_LEVEL': 'INKHUNDLA_COUNCIL',
        'RDFTC_LEVEL': 'RDFTC',
        'RDFC_LEVEL': 'RDFC'
      };

      const committeeType = committeeTypeMap[application.current_level];

      // NEW: If it's a committee level, verify OTP
      if (committeeType) {
        // Check if user is a committee member
        const committeeMember = await db.getOne(
          `SELECT cm.* FROM committee_members cm
           JOIN committees c ON c.id = cm.committee_id
           WHERE cm.user_id = ? AND c.type = ? AND c.is_active = 1`,
          [req.user.id, committeeType]
        );

        if (committeeMember) {
          // Committee member must provide OTP
          if (!otp_code) {
            return res.status(400).json({
              success: false,
              error: 'Validation Error',
              message: 'OTP code is required to advance this application as a committee member'
            });
          }

          // Verify OTP - use consistent purpose and pass applicationId
          const otpValid = await verifyOTP(req.user.id, otp_code, 'verification', applicationId);

          if (!otpValid) {
            return res.status(400).json({
              success: false,
              error: 'Validation Error',
              message: 'Invalid or expired OTP code'
            });
          }

          logger.info(`OTP verified for user ${req.user.id} advancing application ${applicationId}`);
        }
      }

      // Get next workflow level
      const nextLevel = getNextWorkflowLevel(application.current_level);

      if (!nextLevel) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Application is already at the final level'
        });
      }

      // Check if special requirements are met
      if (nextLevel.level === 'PS_LEVEL' && !await hasAllCommitteeApprovals(applicationId, 'RDFC_LEVEL')) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'All RDFC committee members must approve before advancing to PS level'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // SIMPLIFIED: Check if advancing from PS_LEVEL
        const isAdvancingFromPS = application.current_level === 'PS_LEVEL';
        
        if (isAdvancingFromPS) {
          // Advancing from PS level - update status to 'approved'
          await connection.query(
            `UPDATE applications SET
              current_level = ?,
              progress_percentage = ?,
              status = 'approved',
              updated_at = NOW()
             WHERE id = ?`,
            [nextLevel.level, nextLevel.progress, applicationId]
          );
          logger.info(`Application ${applicationId} approved (advanced from PS_LEVEL)`);
        } else {
          // Advancing from other levels - keep original update
          await connection.query(
            `UPDATE applications SET
              current_level = ?,
              progress_percentage = ?,
              updated_at = NOW()
             WHERE id = ?`,
            [nextLevel.level, nextLevel.progress, applicationId]
          );
        }

        // Add workflow entry
        await connection.query(
          `INSERT INTO application_workflow (
            application_id, from_level, to_level, action, actioned_by, comments
          ) VALUES (?, ?, ?, ?, ?, ?)`,
          [
            applicationId,
            application.current_level,
            nextLevel.level,
            'advance',
            req.user.id,
            comments || 'Advanced to next level'
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, 
            description, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'workflow_advanced',
            'applications',
            applicationId,
            JSON.stringify({
              from: application.current_level,
              to: nextLevel.level,
              otp_verified: !!otp_code,
              approved: isAdvancingFromPS // Track if application was approved
            }),
            req.ip,
            req.get('User-Agent')
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Get updated application
        const updatedApplication = await db.getOne(
          `SELECT a.*, e.company_name as eog_name
           FROM applications a
           JOIN eogs e ON e.id = a.eog_id
           WHERE a.id = ?`,
          [applicationId]
        );

        // Notify relevant users
        const notifyUsers = await getUsersForLevel(nextLevel.level, application);

        if (notifyUsers.length > 0) {
          setTimeout(async () => {
            try {
              await emailUtils.sendApplicationNotification(
                updatedApplication,
                notifyUsers,
                'advanced to your level',
                `The application has been advanced from ${application.current_level} to ${nextLevel.level}.`
              );
            } catch (error) {
              logger.error(`Failed to send notifications: ${error.message}`);
            }
          }, 0);
        }

        return res.status(200).json({
          success: true,
          message: 'Application advanced to next level',
          data: {
            application: updatedApplication,
            from_level: application.current_level,
            to_level: nextLevel.level,
            approved: isAdvancingFromPS
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Advance workflow error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/workflow/:applicationId/return
 * @desc    Return application to previous level
 * @access  Private
 */
router.post('/:applicationId/return',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments, return_reason } = req.body;

      if (!comments || !return_reason) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Comments and return_reason are required'
        });
      }

      // Get application
      const application = await db.getOne(
        `SELECT a.*, e.company_name, e.region_id, e.tinkhundla_id, e.umphakatsi_id
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         WHERE a.id = ?`,
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Check if user has permission to return this application
      if (!await canModifyWorkflow(req.user, application)) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have permission to return this application'
        });
      }

      // Get previous workflow level
      const previousLevel = getPreviousWorkflowLevel(application.current_level);

      if (!previousLevel) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Application is already at the first level'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update application
        await connection.query(
          `UPDATE applications SET
            current_level = ?,
            progress_percentage = ?,
            updated_at = NOW()
           WHERE id = ?`,
          [previousLevel.level, previousLevel.progress, applicationId]
        );

        // Add workflow entry
        await connection.query(
          `INSERT INTO application_workflow (
            application_id, from_level, to_level, action, actioned_by, comments
          ) VALUES (?, ?, ?, ?, ?, ?)`,
          [
            applicationId,
            application.current_level,
            previousLevel.level,
            'return',
            req.user.id,
            `Returned for the following reason: ${return_reason}. ${comments}`
          ]
        );

        // Add a comment with return reason
        await connection.query(
          `INSERT INTO application_comments (
            application_id, user_id, workflow_level,
            comment_type, comment_text
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            applicationId,
            req.user.id,
            application.current_level,
            'return_reason',
            `Returned to ${previousLevel.name} for the following reason: ${return_reason}. ${comments}`
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, 
            details, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'workflow_returned',
            'applications',
            applicationId,
            JSON.stringify({
              from: application.current_level,
              to: previousLevel.level,
              reason: return_reason
            }),
            req.ip,
            req.get('User-Agent')
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Get updated application
        const updatedApplication = await db.getOne(
          `SELECT a.*, e.company_name as eog_name
           FROM applications a
           JOIN eogs e ON e.id = a.eog_id
           WHERE a.id = ?`,
          [applicationId]
        );

        // Notify relevant users
        const notifyUsers = await getUsersForLevel(previousLevel.level, application);

        if (notifyUsers.length > 0) {
          setTimeout(async () => {
            try {
              await emailUtils.sendApplicationNotification(
                updatedApplication,
                notifyUsers,
                'returned to your level',
                `The application has been returned from ${application.current_level} to ${previousLevel.level} for the following reason: ${return_reason}`
              );
            } catch (error) {
              logger.error(`Failed to send notifications: ${error.message}`);
            }
          }, 0);
        }

        return res.status(200).json({
          success: true,
          message: 'Application returned to previous level',
          data: {
            application: updatedApplication,
            from_level: application.current_level,
            to_level: previousLevel.level
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Return workflow error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/workflow/:applicationId/approve
 * @desc    Approve application by committee member
 * @access  Private
 */
router.post('/:applicationId/approve',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments, otp_code } = req.body;

      // Get application
      const application = await db.getOne(
        `SELECT a.*, e.company_name, e.region_id, e.tinkhundla_id, e.umphakatsi_id
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         WHERE a.id = ?`,
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Get committee for current level
      const committeeType = getCommitteeTypeForLevel(application.current_level);

      if (!committeeType) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Current level does not require committee approval'
        });
      }

      // Check if user is a member of this committee
      const committeeMember = await db.getOne(
        `SELECT cm.* FROM committee_members cm
         JOIN committees c ON c.id = cm.committee_id
         WHERE cm.user_id = ? AND c.type = ? AND c.is_active = 1
         AND (
           (c.type = 'cdc') OR
           (c.type = 'inkhundla_council' ) OR
           (c.type = 'rdftc' ) OR
           (c.type = 'rdfc' )
         )`,
        [req.user.id, committeeType, application.region_id, application.tinkhundla_id, application.umphakatsi_id]
      );

      if (!committeeMember) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You are not a member of the required committee'
        });
      }

      // Check if this member has already approved this application
      const existingApproval = await db.getOne(
        `SELECT * FROM committee_approvals
         WHERE application_id = ? AND committee_member_id = ?`,
        [applicationId, committeeMember.id]
      );

      if (existingApproval) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'You have already approved this application'
        });
      }

      // Validate OTP if required by committee
      const committee = await db.getOne(
        `SELECT * FROM committees WHERE id = ?`,
        [committeeMember.committee_id]
      );

      if (committee.requires_otp) {
        if (!otp_code) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'OTP code is required for this approval'
          });
        }

        // Verify OTP
        const otpValid = await verifyOTP(req.user.id, otp_code, 'committee_approval', applicationId);

        if (!otpValid) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid or expired OTP code'
          });
        }
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Add committee approval
        await connection.query(
          `INSERT INTO committee_approvals (
            committee_id, committee_member_id, application_id, 
            decision, comments, signed_at
          ) VALUES (?, ?, ?, ?, ?, NOW())`,
          [
            committeeMember.committee_id,
            committeeMember.id,
            applicationId,
            true,
            comments || 'Approved'
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, 
            description, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'committee_approval',
            'applications',
            applicationId,
            JSON.stringify({
              committee_type: committeeType,
              committee_id: committeeMember.committee_id,
              workflow_level: application.current_level
            }),
            req.ip,
            req.get('User-Agent')
          ]
        );

        // Add comment
        await connection.query(
          `INSERT INTO application_comments (
            application_id, user_id, workflow_level,
            comment_type, comment_text
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            applicationId,
            req.user.id,
            application.current_level,
            'recommendation',
            comments || `Approved by ${req.user.first_name} ${req.user.last_name} (${committeeType})`
          ]
        );

        // Check if all required approvals are complete
        const allApproved = await checkAllCommitteeApprovals(connection, applicationId, committeeType);

        // If PS approval and all RDFC approvals, set approved_amount
        if (committeeType === 'PS' && allApproved && application.approved_amount) {
          await connection.query(
            `UPDATE applications SET
              approved_amount = ?,
              updated_at = NOW()
             WHERE id = ?`,
            [application.funding_amount, applicationId]
          );
        }

        // Commit transaction
        await db.commit(connection);

        // Get committee approval stats
        const approvalStats = await getCommitteeApprovalStats(applicationId, committeeMember.committee_id);

        // Notify chairperson if all approvals complete
        if (allApproved) {
          const chairperson = await db.getOne(
            `SELECT u.* FROM users u
             JOIN committee_members cm ON cm.user_id = u.id
             WHERE cm.committee_id = ? AND cm.position = 'Chairperson'
             AND cm.status = 'active'`,
            [committeeMember.committee_id]
          );

          if (chairperson) {
            setTimeout(async () => {
              try {
                await emailUtils.sendEmail(
                  chairperson.email,
                  `All Approvals Complete - Application ${application.reference_number}`,
                  `
                  <h1>All Committee Approvals Complete</h1>
                  <p>Hello ${chairperson.first_name} ${chairperson.last_name},</p>
                  <p>All committee members have approved application ${application.reference_number} (${application.title}).</p>
                  <p>As the chairperson, you can now advance the application to the next level.</p>
                  <p>Thank you,</p>
                  <p>The RDF System</p>
                  `,
                  chairperson.id,
                  applicationId,
                  'applications'
                );
              } catch (error) {
                logger.error(`Failed to send chairperson notification: ${error.message}`);
              }
            }, 0);
          }
        }

        return res.status(200).json({
          success: true,
          message: 'Application approved successfully',
          data: {
            committee_type: committeeType,
            approval_stats: approvalStats,
            all_approved: allApproved
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Committee approval error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/workflow/:applicationId/reject
 * @desc    Reject application by committee member
 * @access  Private
 */
router.post('/:applicationId/reject',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments, reject_reason, otp_code } = req.body;

      if (!comments || !reject_reason) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Comments and reject_reason are required'
        });
      }

      // Get application
      const application = await db.getOne(
        `SELECT a.*, e.company_name, e.region_id, e.tinkhundla_id, e.umphakatsi_id
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         WHERE a.id = ?`,
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Get committee for current level
      const committeeType = getCommitteeTypeForLevel(application.current_level);

      if (!committeeType) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Current level does not require committee approval'
        });
      }

      // Check if user is a member of this committee
      const committeeMember = await db.getOne(
        `SELECT cm.* FROM committee_members cm
         JOIN committees c ON c.id = cm.committee_id
         WHERE cm.user_id = ? AND c.type = ? AND c.is_active = 1
         AND (
           (c.type = 'national') OR
           (c.type = 'region' ) OR
           (c.type = 'tinkhundla' ) OR
           (c.type = 'umphakatsi' )
         )`,
        [req.user.id, committeeType, application.region_id, application.tinkhundla_id, application.umphakatsi_id]
      );

      if (!committeeMember) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You are not a member of the required committee'
        });
      }

      // Check if this member has already rejected this application
      const existingApproval = await db.getOne(
        `SELECT * FROM committee_approvals
         WHERE application_id = ? AND committee_member_id = ?`,
        [applicationId, committeeMember.id]
      );

      if (existingApproval) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'You have already acted on this application'
        });
      }

      // Validate OTP if required by committee
      const committee = await db.getOne(
        `SELECT * FROM committees WHERE id = ?`,
        [committeeMember.committee_id]
      );

      if (committee.requires_otp) {
        if (!otp_code) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'OTP code is required for this action'
          });
        }

        // Verify OTP
        const otpValid = await verifyOTP(req.user.id, otp_code, 'committee_rejection', applicationId);

        if (!otpValid) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid or expired OTP code'
          });
        }
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Add committee rejection
        await connection.query(
          `INSERT INTO committee_approvals (
            committee_id, committee_member_id, application_id, 
            approved, comments, signed_at
          ) VALUES (?, ?, ?, ?, ?, NOW())`,
          [
            committeeMember.committee_id,
            committeeMember.id,
            applicationId,
            false,
            `Rejected: ${reject_reason}. ${comments}`
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, 
            details, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'committee_rejection',
            'applications',
            applicationId,
            JSON.stringify({
              committee_type: committeeType,
              committee_id: committeeMember.committee_id,
              workflow_level: application.current_level,
              reason: reject_reason
            }),
            req.ip,
            req.get('User-Agent')
          ]
        );

        // Add comment
        await connection.query(
          `INSERT INTO application_comments (
            application_id, user_id, workflow_level,
            comment_type, comment_text
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            applicationId,
            req.user.id,
            application.current_level,
            'return_reason',
            `Rejected by ${req.user.first_name} ${req.user.last_name} (${committeeType}): ${reject_reason}. ${comments}`
          ]
        );

        // If RDFC or PS rejection, update application status and return to previous level
        if (['RDFC', 'PS'].includes(committeeType)) {
          const previousLevel = getPreviousWorkflowLevel(application.current_level);

          await connection.query(
            `UPDATE applications SET
              current_level = ?,
              progress_percentage = ?,
              status = 'returned',
              updated_at = NOW()
             WHERE id = ?`,
            [previousLevel.level, previousLevel.progress, applicationId]
          );

          // Add workflow entry
          await connection.query(
            `INSERT INTO application_workflow (
              application_id, from_level, to_level, action, actioned_by, comments
            ) VALUES (?, ?, ?, ?, ?, ?)`,
            [
              applicationId,
              application.current_level,
              previousLevel.level,
              'reject',
              req.user.id,
              `Rejected by committee member: ${reject_reason}. ${comments}`
            ]
          );
        }

        // Commit transaction
        await db.commit(connection);

        // Get committee approval stats
        const approvalStats = await getCommitteeApprovalStats(applicationId, committeeMember.committee_id);

        // Notify chairperson of rejection
        const chairperson = await db.getOne(
          `SELECT u.* FROM users u
           JOIN committee_members cm ON cm.user_id = u.id
           WHERE cm.committee_id = ? AND cm.position = 'Chairperson'
           AND cm.status = 'active'`,
          [committeeMember.committee_id]
        );

        if (chairperson) {
          setTimeout(async () => {
            try {
              await emailUtils.sendEmail(
                chairperson.email,
                `Application Rejected - ${application.reference_number}`,
                `
                <h1>Application Rejected by Committee Member</h1>
                <p>Hello ${chairperson.first_name} ${chairperson.last_name},</p>
                <p>A committee member (${req.user.first_name} ${req.user.last_name}) has rejected application ${application.reference_number} (${application.title}).</p>
                <p>Reason: ${reject_reason}</p>
                <p>Comments: ${comments}</p>
                <p>Thank you,</p>
                <p>The RDF System</p>
                `,
                chairperson.id,
                applicationId,
                'applications'
              );
            } catch (error) {
              logger.error(`Failed to send chairperson notification: ${error.message}`);
            }
          }, 0);
        }

        return res.status(200).json({
          success: true,
          message: 'Application rejected successfully',
          data: {
            committee_type: committeeType,
            approval_stats: approvalStats
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Committee rejection error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/workflow/:applicationId/approvals
 * @desc    Get committee approvals for an application
 * @access  Private
 */
router.get('/:applicationId/approvals',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;

      // Get application
      const application = await db.getOne(
        'SELECT * FROM applications WHERE id = ?',
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Check if user has access to this application
      const hasAccess = await canAccessApplication(req.user, application);

      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }

      // Get all committees for this application
      const committees = await db.query(
        `SELECT c.*, 
         COUNT(cm.id) as total_members,
         COUNT(ca.id) as approvals_count,
         SUM(CASE WHEN ca.decision = TRUE THEN 1 ELSE 0 END) as approved_count,
         SUM(CASE WHEN ca.decision = FALSE THEN 1 ELSE 0 END) as rejected_count
         FROM committees c
         JOIN committee_members cm ON cm.committee_id = c.id AND cm.status = 'active'
         LEFT JOIN committee_approvals ca ON ca.committee_id = c.id 
           AND ca.committee_member_id = cm.id
           AND ca.application_id = ?
         GROUP BY c.id
         ORDER BY c.type`,
        [applicationId]
      );

      // Get all approvals
      const approvals = await db.query(
        `SELECT ca.*,
         cm.position as member_role,
         u.first_name, u.last_name, u.email
         FROM committee_approvals ca
         JOIN committee_members cm ON cm.id = ca.committee_member_id
         JOIN users u ON u.id = cm.user_id
         WHERE ca.application_id = ?
         ORDER BY ca.signed_at`,
        [applicationId]
      );

      // Group approvals by committee
      const committeeApprovals = {};

      for (const committee of committees) {
        const committeeId = committee.id;
        committeeApprovals[committeeId] = {
          committee,
          approvals: approvals.filter(a => a.committee_id === committeeId)
        };
      }

      return res.status(200).json({
        success: true,
        data: committeeApprovals
      });
    } catch (error) {
      logger.error(`Get approvals error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/workflow/:applicationId/history
 * @desc    Get workflow history for an application
 * @access  Private
 */
router.get('/:applicationId/history',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;

      // Get application
      const application = await db.getOne(
        'SELECT * FROM applications WHERE id = ?',
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Check if user has access to this application
      const hasAccess = await canAccessApplication(req.user, application);

      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }

      // Get workflow history
      const history = await db.query(
        `SELECT aw.*, 
         u.first_name, u.last_name, u.role as user_role
         FROM application_workflow aw
         JOIN users u ON u.id = aw.actioned_by
         WHERE aw.application_id = ?
         ORDER BY aw.actioned_at DESC`,
        [applicationId]
      );

      // Get level names
      const levelNames = {};
      const workflowLevels = getAllWorkflowLevels();

      for (const level of workflowLevels) {
        levelNames[level.level] = level.name;
      }

      // Add level names to history
      const historyWithLevels = history.map(item => ({
        ...item,
        from_level_name: levelNames[item.from_level] || item.from_level,
        to_level_name: levelNames[item.to_level] || item.to_level
      }));

      return res.status(200).json({
        success: true,
        data: historyWithLevels
      });
    } catch (error) {
      logger.error(`Get workflow history error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/workflow/:applicationId/complete
 * @desc    Mark application as complete (100%)
 * @access  Private (SUPER_USER only)
 */
router.post('/:applicationId/complete',
  authenticate,
  requireRole('SUPER_USER'),
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments } = req.body;

      // Get application
      const application = await db.getOne(
        'SELECT * FROM applications WHERE id = ?',
        [applicationId]
      );

      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }

      // Check if application is at implementation level
      if (application.current_level !== 'IMPLEMENTATION_LEVEL') {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Application must be at implementation level to be completed'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update application
        await connection.query(
          `UPDATE applications SET
            status = 'completed',
            progress_percentage = 100,
            completed_at = NOW(),
            updated_at = NOW()
           WHERE id = ?`,
          [applicationId]
        );

        // Add workflow entry
        await connection.query(
          `INSERT INTO application_workflow (
            application_id, from_level, to_level, action, actioned_by, comments
          ) VALUES (?, ?, ?, ?, ?, ?)`,
          [
            applicationId,
            'IMPLEMENTATION_LEVEL',
            'IMPLEMENTATION_LEVEL',
            'complete',
            req.user.id,
            comments || 'Project completed successfully'
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO user_activity_logs (
            user_id, action, entity_type, entity_id, 
            details, ip_address, user_agent
          ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'application_completed',
            'applications',
            applicationId,
            JSON.stringify({
              reference_number: application.reference_number
            }),
            req.ip,
            req.get('User-Agent')
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Get updated application
        const updatedApplication = await db.getOne(
          `SELECT a.*, e.company_name as eog_name
           FROM applications a
           JOIN eogs e ON e.id = a.eog_id
           WHERE a.id = ?`,
          [applicationId]
        );

        // Notify EOG
        const eogUser = await db.getOne(
          `SELECT u.* FROM users u
           JOIN eog_users eu ON eu.user_id = u.id
           WHERE eu.eog_id = ? AND eu.is_primary_contact = TRUE`,
          [application.eog_id]
        );

        if (eogUser) {
          setTimeout(async () => {
            try {
              await emailUtils.sendEmail(
                eogUser.email,
                `Project Completed - ${application.reference_number}`,
                `
                <h1>Project Completed!</h1>
                <p>Hello ${eogUser.first_name} ${eogUser.last_name},</p>
                <p>Your project (${application.reference_number} - ${application.title}) has been marked as complete.</p>
                <p>Thank you for your participation in the RDF program.</p>
                <p>The RDF System Team</p>
                `,
                eogUser.id,
                applicationId,
                'applications'
              );
            } catch (error) {
              logger.error(`Failed to send completion notification: ${error.message}`);
            }
          }, 0);
        }

        return res.status(200).json({
          success: true,
          message: 'Application marked as complete',
          data: updatedApplication
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Complete application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * Helper Functions
 */

/**
 * Check if a user can modify workflow for an application
 * @param {Object} user User object
 * @param {Object} application Application object
 * @returns {Promise<boolean>} Whether user has permission
 */
async function canModifyWorkflow(user, application) {
  // SUPER_USER can modify anything
  if (user.role === 'SUPER_USER') {
    return true;
  }

  // Only users at current level can modify workflow
  const roleToLevel = {
    'LINE_MINISTRY': 'MINISTRY_LEVEL',
    'MICROPROJECTS': 'MICROPROJECTS_LEVEL',
    'CDO': 'CDO_LEVEL',
    'CDC': 'UMPHAKATSI_LEVEL',
    'INKHUNDLA_COUNCIL': 'INKHUNDLA_LEVEL',
    'RDFTC': 'RDFTC_LEVEL',
    'RDFC': 'RDFC_LEVEL',
    'PS': 'PS_LEVEL'
  };

  if (roleToLevel[user.role] !== application.current_level) {
    return false;
  }

  // If committee level, check if user is chairperson
  if (['UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', 'RDFTC_LEVEL', 'RDFC_LEVEL'].includes(application.current_level)) {
    const committeeType = getCommitteeTypeForLevel(application.current_level);

    const isChairperson = await db.getOne(
      `SELECT cm.id FROM committee_members cm
       JOIN committees c ON c.id = cm.committee_id
       WHERE cm.user_id = ? AND cm.is_chairperson = 1 AND c.type = ? AND c.is_active = 1
       `,
      [user.id, committeeType, application.region_id, application.tinkhundla_id, application.umphakatsi_id]
    );

    return !!isChairperson;
  }

  // For non-committee levels, user must be at current level
  if (user.role === 'CDO' && application.current_level === 'CDO_LEVEL') {
    return user.region_id === application.region_id;
  }

  // For other roles, they must be the correct role for this level
  return true;
}

/**
 * Check if a user can access an application
 * @param {Object} user User object
 * @param {Object} application Application object
 * @returns {Promise<boolean>} Whether user has access
 */
async function canAccessApplication(user, application) {
  // SUPER_USER can access anything
  if (user.role === 'SUPER_USER') {
    return true;
  }

  // EOG users can access their own applications
  if (user.role === 'EOG') {
    const eog = await db.getOne(
      'SELECT eog_id FROM eog_users WHERE user_id = ?',
      [user.id]
    );

    return eog && eog.eog_id === application.eog_id;
  }

  // CDO can access applications in their region
  if (user.role === 'CDO' && user.region_id) {
    const eog = await db.getOne(
      'SELECT region_id FROM eogs WHERE id = ?',
      [application.eog_id]
    );

    return eog && eog.region_id === user.region_id;
  }

  // Committee members can access applications in their scope
  const committeeTypes = ['CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC'];
  if (committeeTypes.includes(user.role)) {
    const eog = await db.getOne(
      'SELECT region_id, tinkhundla_id, umphakatsi_id FROM eogs WHERE id = ?',
      [application.eog_id]
    );

    if (!eog) return false;

    // Check for committee membership in this scope
    const committeeType = getCommitteeTypeForUserRole(user.role);
    const committeeMember = await db.getOne(
      `SELECT cm.id FROM committee_members cm
       JOIN committees c ON c.id = cm.committee_id
       WHERE cm.user_id = ? AND c.type = ? AND c.is_active = 1
       AND (
         (c.type = 'national') OR
         (c.type = 'region' ) OR
         (c.type = 'tinkhundla' ) OR
         (c.type = 'umphakatsi' )
       )`,
      [user.id, committeeType, eog.region_id, eog.tinkhundla_id, eog.umphakatsi_id]
    );

    return !!committeeMember;
  }

  // Other roles can access all applications
  return true;
}

/**
 * Get the next workflow level
 * @param {string} currentLevel Current workflow level
 * @returns {Object|null} Next level or null if at final level
 */
function getNextWorkflowLevel(currentLevel) {
  const levels = getAllWorkflowLevels();

  const currentIndex = levels.findIndex(l => l.level === currentLevel);

  if (currentIndex === -1 || currentIndex === levels.length - 1) {
    return null; // Not found or at final level
  }

  return levels[currentIndex + 1];
}

/**
 * Get the previous workflow level
 * @param {string} currentLevel Current workflow level
 * @returns {Object|null} Previous level or null if at first level
 */
function getPreviousWorkflowLevel(currentLevel) {
  const levels = getAllWorkflowLevels();

  const currentIndex = levels.findIndex(l => l.level === currentLevel);

  if (currentIndex <= 0) {
    return null; // Not found or at first level
  }

  return levels[currentIndex - 1];
}

/**
 * Get all workflow levels
 * @returns {Array} All workflow levels
 */
function getAllWorkflowLevels() {
  return [
    {
      level: 'EOG_LEVEL',
      name: 'EOG Level',
      description: 'Application creation and submission',
      sequence: 1,
      progress: 0
    },
    {
      level: 'MINISTRY_LEVEL',
      name: 'Line Ministry Level',
      description: 'Review by relevant line ministry',
      sequence: 2,
      progress: 9.09
    },
    {
      level: 'MICROPROJECTS_LEVEL',
      name: 'Microprojects Level',
      description: 'Technical assessment by microprojects team',
      sequence: 3,
      progress: 18.18
    },
    {
      level: 'CDO_LEVEL',
      name: 'CDO Level',
      description: 'Review by Community Development Officer',
      sequence: 4,
      progress: 27.27
    },
    {
      level: 'UMPHAKATSI_LEVEL',
      name: 'Umphakatsi Level (CDC)',
      description: 'Review by Community Development Committee',
      sequence: 5,
      progress: 36.36
    },
    {
      level: 'INKHUNDLA_LEVEL',
      name: 'Inkhundla Level',
      description: 'Review by Inkhundla Council',
      sequence: 6,
      progress: 45.45
    },
    {
      level: 'RDFTC_LEVEL',
      name: 'RDFTC Level',
      description: 'Review by Regional Development Fund Technical Committee',
      sequence: 7,
      progress: 54.54
    },
    {
      level: 'RDFC_LEVEL',
      name: 'RDFC Level',
      description: 'Review by Regional Development Fund Committee',
      sequence: 8,
      progress: 63.63
    },
    {
      level: 'PS_LEVEL',
      name: 'PS Level',
      description: 'Final approval by Principal Secretary',
      sequence: 9,
      progress: 72.72
    },
    {
      level: 'PROCUREMENT_LEVEL',
      name: 'Procurement Level',
      description: 'Procurement of goods and services',
      sequence: 10,
      progress: 81.81
    },
    {
      level: 'IMPLEMENTATION_LEVEL',
      name: 'Implementation Level',
      description: 'Project implementation and monitoring',
      sequence: 11,
      progress: 90.90
    }
  ];
}

/**
 * Get committee type for workflow level
 * @param {string} workflowLevel Workflow level
 * @returns {string|null} Committee type or null if no committee
 */
function getCommitteeTypeForLevel(workflowLevel) {
  const levelToCommittee = {
    'UMPHAKATSI_LEVEL': 'CDC',
    'INKHUNDLA_LEVEL': 'INKHUNDLA_COUNCIL',
    'RDFTC_LEVEL': 'RDFTC',
    'RDFC_LEVEL': 'RDFC',
    'PS_LEVEL': 'PS'
  };

  return levelToCommittee[workflowLevel] || null;
}

/**
 * Get committee type for user role
 * @param {string} userRole User role
 * @returns {string|null} Committee type or null if not committee role
 */
function getCommitteeTypeForUserRole(userRole) {
  const roleToCommittee = {
    'CDC': 'CDC',
    'INKHUNDLA_COUNCIL': 'INKHUNDLA_COUNCIL',
    'RDFTC': 'RDFTC',
    'RDFC': 'RDFC',
    'PS': 'PS'
  };

  return roleToCommittee[userRole] || null;
}

/**
 * Check if all committee members have approved an application
 * @param {Object} connection Database connection
 * @param {number} applicationId Application ID
 * @param {string} committeeType Committee type
 * @returns {Promise<boolean>} Whether all members have approved
 */
async function checkAllCommitteeApprovals(connection, applicationId, committeeType) {
  const application = await connection.query(
    'SELECT e.region_id, e.tinkhundla_id, e.umphakatsi_id FROM applications a JOIN eogs e ON e.id = a.eog_id WHERE a.id = ?',
    [applicationId]
  );

  if (!application || application.length === 0) {
    return false;
  }

  const regionId = application[0].region_id;
  const tinkhundlaId = application[0].tinkhundla_id;
  const umphakatsiId = application[0].umphakatsi_id;

  // Get all active committee members
  const committeeMembers = await connection.query(
    `SELECT cm.id FROM committee_members cm
     JOIN committees c ON c.id = cm.committee_id
     WHERE c.type = ? AND c.is_active = 1 AND cm.status = 'active'
     AND (
       (c.type = 'national') OR
       (c.type = 'region' ) OR
       (c.type = 'tinkhundla' ) OR
       (c.type = 'umphakatsi' )
     )`,
    [committeeType, regionId, tinkhundlaId, umphakatsiId]
  );

  if (committeeMembers.length === 0) {
    return false;
  }

  // Get approvals
  const approvals = await connection.query(
    `SELECT ca.* FROM committee_approvals ca
     JOIN committee_members cm ON cm.id = ca.committee_member_id
     JOIN committees c ON c.id = ca.committee_id
     WHERE ca.application_id = ? AND c.type = ? 
     AND cm.status = 'active' AND ca.decision = TRUE`,
    [applicationId, committeeType]
  );

  // Check if all members have approved
  return committeeMembers.length === approvals.length;
}

/**
 * Check if an application has all committee approvals at a level
 * @param {number} applicationId Application ID
 * @param {string} workflowLevel Workflow level
 * @returns {Promise<boolean>} Whether all committee members have approved
 */
async function hasAllCommitteeApprovals(applicationId, workflowLevel) {
  const committeeType = getCommitteeTypeForLevel(workflowLevel);

  if (!committeeType) {
    return false;
  }

  const connection = await db.pool.getConnection();

  try {
    const result = await checkAllCommitteeApprovals(connection, applicationId, committeeType);
    return result;
  } finally {
    connection.release();
  }
}

/**
 * Get committee approval statistics for an application
 * @param {number} applicationId Application ID
 * @param {number} committeeId Committee ID
 * @returns {Promise<Object>} Approval statistics
 */
async function getCommitteeApprovalStats(applicationId, committeeId) {
  const stats = await db.getOne(
    `SELECT 
      COUNT(cm.id) as total_members,
      COUNT(ca.id) as approvals_count,
      SUM(CASE WHEN ca.decision = TRUE THEN 1 ELSE 0 END) as approved_count,
      SUM(CASE WHEN ca.decision = FALSE THEN 1 ELSE 0 END) as rejected_count
     FROM committees c
     JOIN committee_members cm ON cm.committee_id = c.id AND cm.status = 'active'
     LEFT JOIN committee_approvals ca ON ca.committee_id = c.id 
       AND ca.committee_member_id = cm.id
       AND ca.application_id = ?
     WHERE c.id = ?`,
    [applicationId, committeeId]
  );

  if (!stats) {
    return {
      total_members: 0,
      approvals_count: 0,
      approved_count: 0,
      rejected_count: 0,
      pending_count: 0,
      approval_percentage: 0
    };
  }

  const pendingCount = stats.total_members - stats.approvals_count;
  const approvalPercentage = stats.total_members > 0 ?
    Math.round((stats.approved_count / stats.total_members) * 100) : 0;

  return {
    ...stats,
    pending_count: pendingCount,
    approval_percentage: approvalPercentage
  };
}

/**
 * Get users for a workflow level
 * @param {string} level Workflow level
 * @param {Object} application Application object
 * @returns {Promise<Array>} Users for the level
 */
async function getUsersForLevel(level, application) {
  try {
    logger.info(`Getting users for level: ${level}, application: ${application.id}`);
    
    switch (level) {
      case 'MINISTRY_LEVEL':
        // Notify all LINE_MINISTRY users
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND status = ?',
          ['LINE_MINISTRY', 'active']
        );

      case 'MICROPROJECTS_LEVEL':
        // Notify all MICROPROJECTS users
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND status = ?',
          ['MICROPROJECTS', 'active']
        );

      case 'CDO_LEVEL':
        // Notify CDO in the same region as the application
        if (!application.region_id) {
          logger.warn('No region_id found for application, cannot find CDO');
          return [];
        }
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND region_id = ? AND status = ?',
          ['CDO', application.region_id, 'active']
        );

      case 'UMPHAKATSI_LEVEL':
        // Notify CDC committee members for this umphakatsi
        if (!application.umphakatsi_id) {
          logger.warn('No umphakatsi_id found for application, cannot find CDC members');
          return [];
        }
        return await db.query(
          `SELECT DISTINCT u.* FROM users u
           JOIN committee_members cm ON cm.user_id = u.id
           JOIN committees c ON c.id = cm.committee_id
           WHERE c.type = 'CDC' 
           AND c.umphakatsi_id = ? 
           AND c.is_active = 1
           AND u.status = 'active'`,
          [application.umphakatsi_id]
        );

      case 'INKHUNDLA_LEVEL':
        // Notify INKHUNDLA_COUNCIL members for this tinkhundla
        if (!application.tinkhundla_id) {
          logger.warn('No tinkhundla_id found for application, cannot find INKHUNDLA_COUNCIL members');
          return [];
        }
        return await db.query(
          `SELECT DISTINCT u.* FROM users u
           JOIN committee_members cm ON cm.user_id = u.id
           JOIN committees c ON c.id = cm.committee_id
           WHERE c.type = 'INKHUNDLA_COUNCIL' 
           AND c.tinkhundla_id = ? 
           AND c.is_active = 1
           AND u.status = 'active'`,
          [application.tinkhundla_id]
        );

      case 'RDFTC_LEVEL':
        // Notify RDFTC members for this region
        if (!application.region_id) {
          logger.warn('No region_id found for application, cannot find RDFTC members');
          return [];
        }
        return await db.query(
          `SELECT DISTINCT u.* FROM users u
           JOIN committee_members cm ON cm.user_id = u.id
           JOIN committees c ON c.id = cm.committee_id
           WHERE c.type = 'RDFTC' 
           AND c.region_id = ? 
           AND c.is_active = 1
           AND u.status = 'active'`,
          [application.region_id]
        );

      case 'RDFC_LEVEL':
        // Notify RDFC members for this region
        if (!application.region_id) {
          logger.warn('No region_id found for application, cannot find RDFC members');
          return [];
        }
        return await db.query(
          `SELECT DISTINCT u.* FROM users u
           JOIN committee_members cm ON cm.user_id = u.id
           JOIN committees c ON c.id = cm.committee_id
           WHERE c.type = 'RDFC' 
           AND c.region_id = ? 
           AND c.is_active = 1
           AND u.status = 'active'`,
          [application.region_id]
        );

      case 'PS_LEVEL':
        // Notify all PS users
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND status = ?',
          ['PS', 'active']
        );

      case 'PROCUREMENT_LEVEL':
        // Notify all PROCUREMENT users
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND status = ?',
          ['PROCUREMENT', 'active']
        );

      case 'IMPLEMENTATION_LEVEL':
        // Notify all IMPLEMENTATION users
        return await db.query(
          'SELECT * FROM users WHERE role = ? AND status = ?',
          ['IMPLEMENTATION', 'active']
        );

      case 'EOG_LEVEL':
        // Notify EOG users for their own application
        if (!application.eog_id) {
          logger.warn('No eog_id found for application, cannot find EOG users');
          return [];
        }
        return await db.query(
          `SELECT u.* FROM users u
           JOIN eog_users eu ON eu.user_id = u.id
           WHERE eu.eog_id = ? AND u.status = 'active'`,
          [application.eog_id]
        );

      default:
        logger.warn(`Unknown workflow level: ${level}`);
        return [];
    }
  } catch (error) {
    logger.error(`Error getting users for level ${level}: ${error.message}`);
    logger.error(error.stack);
    return [];
  }
}

/**
 * Verify OTP code for committee approval
 * @param {number} userId User ID
 * @param {string} otpCode OTP code
 * @param {string} purpose OTP purpose
 * @param {number} applicationId Application ID
 * @returns {Promise<boolean>} Whether OTP is valid
 */
async function verifyOTP(userId, otpCode, purpose, applicationId) {
  try {
    // Get OTP record - match the purpose used in committee.routes.js
    const otp = await db.getOne(
      `SELECT * FROM otps
       WHERE user_id = ? AND purpose = ? AND entity_type = 'applications'
       AND entity_id = ? AND status = 'active'
       ORDER BY created_at DESC
       LIMIT 1`,
      [userId, 'verification', applicationId] // Use consistent purpose
    );

    if (!otp) {
      logger.warn(`No active OTP found for user ${userId}, application ${applicationId}, purpose: verification`);
      return false;
    }

    // Check if OTP has expired
    if (new Date(otp.expires_at) < new Date()) {
      await db.update('otps',
        { status: 'expired' },
        'id = ?',
        [otp.id]
      );
      logger.warn(`OTP expired for user ${userId}`);
      return false;
    }

    // Check if OTP has too many attempts
    if (otp.attempts >= 3) {
      await db.update('otps',
        { status: 'blocked' },
        'id = ?',
        [otp.id]
      );
      logger.warn(`OTP blocked due to too many attempts for user ${userId}`);
      return false;
    }

    // Increment attempts
    await db.update('otps',
      { attempts: otp.attempts + 1 },
      'id = ?',
      [otp.id]
    );

    // Check if OTP matches
    if (otp.otp_code !== otpCode) {
      logger.warn(`OTP mismatch for user ${userId}. Expected: ${otp.otp_code}, Got: ${otpCode}`);
      return false;
    }

    // Mark OTP as used
    await db.update('otps',
      { status: 'used' },
      'id = ?',
      [otp.id]
    );

    logger.info(`OTP verified successfully for user ${userId}, application ${applicationId}`);
    return true;
  } catch (error) {
    logger.error(`OTP verification error: ${error.message}`);
    return false;
  }
}

module.exports = router;