const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const emailUtils = require('../utils/email');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, validateBody, validateQuery, schemas } = require('../middleware/validation.middleware');

/**
* @route   GET /api/cdo/queue
* @desc    Get CDO review queue (all EOGs in region)
* @access  Private (CDO and SUPER_USER only)
*/
router.get('/queue', 
  authenticate, 
  requireRole(['CDO', 'SUPER_USER']),
  async (req, res) => {
    try {
      const isSuperUser = req.user.role === 'SUPER_USER';
      
      // ✅ FIXED: Using subqueries for accurate per-EOG member counting
      let baseQuery = `
        SELECT 
          COALESCE(q.id, 0) as queue_id,
          COALESCE(q.status, e.status) as review_status,
          COALESCE(q.priority, 'medium') as priority,
          q.assigned_at,
          q.reviewed_at,
          e.id as eog_id,
          e.company_name,
          e.company_type,
          e.bin_cin,
          e.email,
          e.phone,
          r.name as region,
          t.name as tinkhundla,
          i.name as umphakatsi,
          i.chief_name,
          (SELECT COUNT(*) FROM eog_members em WHERE em.eog_id = e.id) as total_members,
          (SELECT COUNT(*) FROM eog_members em WHERE em.eog_id = e.id AND em.is_executive = TRUE) as executive_members,
          (SELECT COUNT(*) FROM eog_members em WHERE em.eog_id = e.id AND em.is_executive = TRUE AND em.verification_status = 'verified') as verified_executives,
          (SELECT COUNT(*) FROM eog_documents ed WHERE ed.eog_id = e.id) as uploaded_documents,
          e.status as eog_status,
          e.created_at
        FROM eogs e
        JOIN regions r ON r.id = e.region_id
        JOIN tinkhundla t ON t.id = e.tinkhundla_id
        JOIN imiphakatsi i ON i.id = e.umphakatsi_id
        LEFT JOIN cdo_review_queue q ON q.eog_id = e.id
      `;
      
      let statsQuery = `
        SELECT
          COUNT(*) as total_queue,
          SUM(CASE WHEN e.status = 'pending_verification' AND (q.status IS NULL OR q.status = 'pending') THEN 1 ELSE 0 END) as pending_count,
          SUM(CASE WHEN q.status = 'in_review' THEN 1 ELSE 0 END) as in_review_count,
          SUM(CASE WHEN e.status = 'approved' THEN 1 ELSE 0 END) as approved_count,
          SUM(CASE WHEN e.status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
          SUM(CASE WHEN q.status = 'more_info_needed' THEN 1 ELSE 0 END) as more_info_count,
          SUM(CASE WHEN e.status = 'suspended' THEN 1 ELSE 0 END) as suspended_count,
          SUM(CASE WHEN e.status = 'temporary' THEN 1 ELSE 0 END) as temporary_count
        FROM eogs e
        LEFT JOIN cdo_review_queue q ON q.eog_id = e.id
      `;
      
      const queryParams = [];
      
      // Add WHERE clause for non-super users
      if (!isSuperUser) {
        const whereClause = ' WHERE e.region_id = ?';
        baseQuery += whereClause;
        statsQuery += whereClause;
        queryParams.push(req.user.region_id);
      }
      
      // ✅ FIXED: No GROUP BY needed - subqueries handle counting per EOG
      baseQuery += `
        ORDER BY 
          FIELD(COALESCE(q.status, e.status), 'pending', 'in_review', 'more_info_needed', 'approved', 'rejected', 'suspended'),
          q.assigned_at DESC
      `;
      
      // Execute queries
      const queue = await db.query(baseQuery, queryParams);
      const stats = await db.getOne(statsQuery, queryParams);
      
      return res.status(200).json({
        success: true,
        data: {
          queue,
          stats: stats || {
            total_queue: 0,
            pending_count: 0,
            in_review_count: 0,
            approved_count: 0,
            rejected_count: 0,
            more_info_count: 0,
            suspended_count: 0,
            temporary_count: 0
          },
          user_role: req.user.role
        }
      });
    } catch (error) {
      logger.error(`CDO queue error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
 );

/**
 * @route   POST /api/cdo/queue/:eogId/approve
 * @desc    Approve EOG
 * @access  Private (CDO only)
 */
router.post('/queue/:eogId/approve',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Check if EOG is in CDO's region and in review
      const eog = await db.getOne(
        `SELECT e.*, q.id as queue_id
         FROM eogs e
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE e.id = ? AND e.region_id = ? 
         AND e.status = 'pending_verification'
         AND q.status = 'in_review' AND q.assigned_cdo_id = ?`,
        [eogId, req.user.region_id, req.user.id]
      );

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not in your region, or not in review'
        });
      }

      // Check: All documents uploaded
      const documentCounts = await db.getOne(
        `SELECT COUNT(*) as count, 
          SUM(CASE WHEN document_type = 'constitution' THEN 1 ELSE 0 END) as constitution,
          SUM(CASE WHEN document_type = 'recognition_letter' THEN 1 ELSE 0 END) as recognition_letter,
          SUM(CASE WHEN document_type = 'articles' THEN 1 ELSE 0 END) as articles,
          SUM(CASE WHEN document_type = 'form_j' THEN 1 ELSE 0 END) as form_j,
          SUM(CASE WHEN document_type = 'certificate' THEN 1 ELSE 0 END) as certificate
         FROM eog_documents
         WHERE eog_id = ?`,
        [eogId]
      );

      const requiredDocuments = [
        'constitution',
        'recognition_letter',
        'articles',
        'form_j',
        'certificate'
      ];

      const missingDocuments = [];
      for (const doc of requiredDocuments) {
        if (!documentCounts[doc] || documentCounts[doc] === 0) {
          missingDocuments.push(doc.replace('_', ' '));
        }
      }

      if (missingDocuments.length > 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Cannot approve: Missing required documents: ${missingDocuments.join(', ')}`
        });
      }

      // Check: Min 10 executives verified
      const verifiedCount = await db.getOne(
        `SELECT COUNT(*) as count
         FROM eog_members
         WHERE eog_id = ? AND is_executive = TRUE 
         AND verification_status = 'verified'`,
        [eogId]
      );

      if (verifiedCount.count < 10) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Cannot approve: Needs at least 10 verified executives, only ${verifiedCount.count} verified`
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update EOG status
        await connection.query(
          `UPDATE eogs SET 
             status = 'approved',
             approved_by = ?,
             approved_at = NOW(),
             temp_account_expires = NULL
           WHERE id = ?`,
          [req.user.id, eogId]
        );

        // Update user status and change username to email
        await connection.query(
          `UPDATE users u
           JOIN eog_users eu ON eu.user_id = u.id
           SET u.status = 'active',
               u.username = u.email  -- Change username to email
           WHERE eu.eog_id = ? AND u.status = 'temporary'`,
          [eogId]
        );

        // Update review status
        await connection.query(
          `UPDATE cdo_review_queue SET
             status = 'approved',
             review_notes = ?,
             reviewed_at = NOW()
           WHERE id = ?`,
          [
            req.body.notes || 'Approved by CDO',
            eog.queue_id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'eog_approved',
            `EOG approved by CDO: ${req.body.notes || 'No notes provided'}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Send approval notification (outside transaction)
        setTimeout(async () => {
          try {
            // Get user to notify
            const eogUser = await db.getOne(
              `SELECT u.* FROM users u
               JOIN eog_users eu ON eu.user_id = u.id
               WHERE eu.eog_id = ? AND eu.is_primary_contact = TRUE`,
              [eogId]
            );

            if (eogUser) {
              await emailUtils.sendApprovalNotification(eog, eogUser);
            }
          } catch (emailError) {
            logger.error(`Failed to send approval notification: ${emailError.message}`);
          }
        }, 0);

        return res.status(200).json({
          success: true,
          message: 'EOG approved successfully',
          data: {
            eog_id: eogId,
            status: 'approved',
            approved_by: req.user.id,
            approved_at: new Date()
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Approve EOG error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);


/**
* @route   GET /api/cdo/queue/:eogId
* @desc    Get EOG details for review
* @access  Private (CDO and SUPER_USER only)
*/
router.get('/queue/:eogId',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const isSuperUser = req.user.role === 'SUPER_USER';

      // Build base query
      let eogQuery = `
       SELECT e.*, r.name as region, t.name as tinkhundla, i.name as umphakatsi, i.chief_name
       FROM eogs e
       JOIN regions r ON r.id = e.region_id
       JOIN tinkhundla t ON t.id = e.tinkhundla_id
       JOIN imiphakatsi i ON i.id = e.umphakatsi_id
       WHERE e.id = ?
     `;

      const eogParams = [eogId];

      // Add region check for non-super users
      if (!isSuperUser) {
        eogQuery += ' AND e.region_id = ?';
        eogParams.push(req.user.region_id);
      }

      // Check if EOG exists and is accessible
      const eog = await db.getOne(eogQuery, eogParams);

      if (!eog) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'EOG not found or not accessible'
        });
      }

      // Get review status
      const review = await db.getOne(
        `SELECT * FROM cdo_review_queue WHERE eog_id = ?`,
        [eogId]
      );

      // Get documents
      const documents = await db.query(
        `SELECT * FROM eog_documents WHERE eog_id = ? ORDER BY document_type`,
        [eogId]
      );

      // Get members
      const members = await db.query(
        `SELECT m.*,
         (SELECT COUNT(*) FROM member_verification_issues vi WHERE vi.eog_member_id = m.id AND vi.resolved = FALSE) as issues_count
        FROM eog_members m
        WHERE m.eog_id = ?
        ORDER BY m.is_executive DESC, m.first_name, m.surname`,
        [eogId]
      );

      // Get activity log
      const activities = await db.query(
        `SELECT * FROM eog_temporal_activity
        WHERE eog_id = ?
        ORDER BY created_at DESC
        LIMIT 20`,
        [eogId]
      );

      return res.status(200).json({
        success: true,
        data: {
          eog,
          review,
          documents,
          members,
          activities,
          user_role: req.user.role
        }
      });
    } catch (error) {
      logger.error(`CDO EOG details error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
* @route   POST /api/cdo/queue/:eogId/start-review
* @desc    Start reviewing EOG
* @access  Private (CDO and SUPER_USER only)
*/
router.post('/queue/:eogId/start-review',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const isSuperUser = req.user.role === 'SUPER_USER';

      // Build EOG check query based on user role
      let eogCheckQuery = `
       SELECT e.* FROM eogs e
       JOIN cdo_review_queue q ON q.eog_id = e.id
       WHERE e.id = ? AND e.status = 'pending_verification'
       AND q.status = 'pending'
     `;

      const eogCheckParams = [eogId];

      // Add region check for non-super users
      if (!isSuperUser) {
        eogCheckQuery += ' AND e.region_id = ?';
        eogCheckParams.push(req.user.region_id);
      }

      // Check if EOG is accessible and pending review
      const eog = await db.getOne(eogCheckQuery, eogCheckParams);

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not accessible, or not pending review'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update review status
        await connection.query(
          `UPDATE cdo_review_queue SET
           status = 'in_review',
           assigned_cdo_id = ?,
           assigned_at = NOW()
          WHERE eog_id = ?`,
          [req.user.id, eogId]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
           eog_id, activity_type, description, performed_by, ip_address
         ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'review_started',
            `${isSuperUser ? 'SUPER_USER' : 'CDO'} started reviewing EOG`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'Review started successfully',
          data: {
            review_status: 'in_review',
            assigned_by: req.user.id,
            user_role: req.user.role,
            assigned_at: new Date()
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Start review error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
* @route   GET /api/cdo/members/:eogId/verify
* @desc    Verify all members in one go
* @access  Private (CDO and SUPER_USER only)
*/
router.get('/members/:eogId/verify',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const isSuperUser = req.user.role === 'SUPER_USER';

      // Build EOG check query based on user role
      let eogCheckQuery = `
       SELECT e.* FROM eogs e
       JOIN cdo_review_queue q ON q.eog_id = e.id
       WHERE e.id = ? AND e.status = 'pending_verification'
       AND q.status = 'in_review'
     `;

      const eogCheckParams = [eogId];

      // Add region and assigned CDO check for non-super users
      if (!isSuperUser) {
        eogCheckQuery += ' AND e.region_id = ? AND q.assigned_cdo_id = ?';
        eogCheckParams.push(req.user.region_id, req.user.id);
      }

      // Check if EOG is accessible and in review
      const eog = await db.getOne(eogCheckQuery, eogCheckParams);

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not accessible, or not in review'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Get all members with training records that match
        const memberResults = await connection.query(
          `SELECT m.id
          FROM eog_members m
          JOIN training_register t ON t.id_number = m.id_number
          WHERE m.eog_id = ?
          AND m.verification_status = 'pending'
          AND t.first_name = m.first_name
          AND t.surname = m.surname
          AND t.gender = m.gender`,
          [eogId]
        );

        const memberIds = memberResults.map(m => m.id);

        if (memberIds.length === 0) {
          return res.status(400).json({
            success: false,
            error: 'Bad Request',
            message: 'No members available for automatic verification'
          });
        }

        // Update all matching members
        await connection.query(
          `UPDATE eog_members SET
            verification_status = 'verified',
            verified_by = ?,
            verified_at = NOW()
          WHERE id IN (?)`,
          [req.user.id, memberIds]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
           eog_id, activity_type, description, performed_by, ip_address
         ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'members_verified',
            `${isSuperUser ? 'SUPER_USER' : 'CDO'} verified ${memberIds.length} members automatically`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: `${memberIds.length} members verified successfully`,
          data: {
            verified_count: memberIds.length,
            member_ids: memberIds,
            verified_by: req.user.id,
            user_role: req.user.role
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Verify all members error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/cdo/members/:memberId/verify
 * @desc    Verify single member
 * @access  Private (CDO only)
 */
router.post('/members/:memberId/verify',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.memberIdParam),
  async (req, res) => {
    try {
      const memberId = req.params.memberId;
      const regionId = req.user.region_id;

      // Check if member exists and belongs to an EOG in CDO's region
      const member = await db.getOne(
        `SELECT m.*, e.id as eog_id, e.region_id
         FROM eog_members m
         JOIN eogs e ON e.id = m.eog_id
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE m.id = ? AND e.region_id = ?
         AND e.status = 'pending_verification'
         AND q.status = 'in_review'`,
        [memberId, regionId]
      );

      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found or EOG not in your region'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update member status
        await connection.query(
          `UPDATE eog_members SET
             verification_status = 'verified',
             verified_by = ?,
             verified_at = NOW()
           WHERE id = ?`,
          [req.user.id, memberId]
        );

        // Resolve any verification issues
        await connection.query(
          `UPDATE member_verification_issues SET
             resolved = true,
             resolution_notes = 'Manually verified by CDO',
             resolved_by = ?,
             resolved_at = NOW()
           WHERE eog_member_id = ? AND resolved = false`,
          [req.user.id, memberId]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            member.eog_id,
            'member_verified',
            `CDO verified member: ${member.first_name} ${member.surname}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'Member verified successfully',
          data: {
            member_id: memberId,
            verification_status: 'verified'
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Verify member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/cdo/members/:memberId/reject
 * @desc    Reject member verification
 * @access  Private (CDO only)
 */
router.post('/members/:memberId/reject',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.memberIdParam),
  async (req, res) => {
    try {
      const memberId = req.params.memberId;
      const { reason, notes } = req.body;

      if (!reason) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Rejection reason is required'
        });
      }

      // Check if member exists and belongs to an EOG in CDO's region
      const member = await db.getOne(
        `SELECT m.*, e.id as eog_id, e.region_id
         FROM eog_members m
         JOIN eogs e ON e.id = m.eog_id
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE m.id = ? AND e.region_id = ?
         AND e.status = 'pending_verification'
         AND q.status = 'in_review'`,
        [memberId, req.user.region_id]
      );

      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found or EOG not in your region'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update member status
        await connection.query(
          `UPDATE eog_members SET
             verification_status = 'failed',
             verification_notes = ?
           WHERE id = ?`,
          [notes || reason, memberId]
        );

        // Add verification issue
        await connection.query(
          `INSERT INTO member_verification_issues (
            eog_member_id, issue_type, issue_description,
            reported_by
          ) VALUES (?, ?, ?, ?)`,
          [
            memberId,
            reason,
            notes || '',
            req.user.id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            member.eog_id,
            'member_verification_failed',
            `CDO rejected member: ${member.first_name} ${member.surname} - ${reason}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'Member verification rejected',
          data: {
            member_id: memberId,
            verification_status: 'failed'
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Reject member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/cdo/members/:memberId/correction
 * @desc    Request member info correction
 * @access  Private (CDO only)
 */
router.put('/members/:memberId/correction',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.memberIdParam),
  async (req, res) => {
    try {
      const memberId = req.params.memberId;
      const { correction_needed, training_record_id } = req.body;

      if (!correction_needed) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Correction details are required'
        });
      }

      // Check if member exists and belongs to an EOG in CDO's region
      const member = await db.getOne(
        `SELECT m.*, e.id as eog_id, e.region_id
         FROM eog_members m
         JOIN eogs e ON e.id = m.eog_id
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE m.id = ? AND e.region_id = ?
         AND e.status = 'pending_verification'
         AND q.status = 'in_review'`,
        [memberId, req.user.region_id]
      );

      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found or EOG not in your region'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update member status
        await connection.query(
          `UPDATE eog_members SET
             verification_status = 'corrected',
             verification_notes = ?
           WHERE id = ?`,
          [correction_needed, memberId]
        );

        // Add verification issue
        await connection.query(
          `INSERT INTO member_verification_issues (
            eog_member_id, issue_type, issue_description,
            training_register_id, reported_by
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            memberId,
            'other',
            correction_needed,
            training_record_id || null,
            req.user.id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            member.eog_id,
            'member_correction_requested',
            `CDO requested correction for member: ${member.first_name} ${member.surname}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'Member correction requested',
          data: {
            member_id: memberId,
            verification_status: 'corrected'
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Request correction error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/cdo/queue/:eogId/approve
 * @desc    Approve EOG
 * @access  Private (CDO only)
 */
router.post('/queue/:eogId/approve',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Check if EOG is in CDO's region and in review
      const eog = await db.getOne(
        `SELECT e.*, q.id as queue_id
         FROM eogs e
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE e.id = ? AND e.region_id = ? 
         AND e.status = 'pending_verification'
         AND q.status = 'in_review' AND q.assigned_cdo_id = ?`,
        [eogId, req.user.region_id, req.user.id]
      );

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not in your region, or not in review'
        });
      }

      // Check: All documents uploaded
      const documentCounts = await db.getOne(
        `SELECT COUNT(*) as count, 
          SUM(CASE WHEN document_type = 'constitution' THEN 1 ELSE 0 END) as constitution,
          SUM(CASE WHEN document_type = 'recognition_letter' THEN 1 ELSE 0 END) as recognition_letter,
          SUM(CASE WHEN document_type = 'articles' THEN 1 ELSE 0 END) as articles,
          SUM(CASE WHEN document_type = 'form_j' THEN 1 ELSE 0 END) as form_j,
          SUM(CASE WHEN document_type = 'certificate' THEN 1 ELSE 0 END) as certificate
         FROM eog_documents
         WHERE eog_id = ?`,
        [eogId]
      );

      const requiredDocuments = [
        'constitution',
        'recognition_letter',
        'articles',
        'form_j',
        'certificate'
      ];

      const missingDocuments = [];
      for (const doc of requiredDocuments) {
        if (!documentCounts[doc] || documentCounts[doc] === 0) {
          missingDocuments.push(doc.replace('_', ' '));
        }
      }

      if (missingDocuments.length > 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Cannot approve: Missing required documents: ${missingDocuments.join(', ')}`
        });
      }

      // Check: Min 10 executives verified
      const verifiedCount = await db.getOne(
        `SELECT COUNT(*) as count
         FROM eog_members
         WHERE eog_id = ? AND is_executive = TRUE 
         AND verification_status = 'verified'`,
        [eogId]
      );

      if (verifiedCount.count < 10) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Cannot approve: Needs at least 10 verified executives, only ${verifiedCount.count} verified`
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update EOG status
        await connection.query(
          `UPDATE eogs SET 
             status = 'approved',
             approved_by = ?,
             approved_at = NOW(),
             temp_account_expires = NULL
           WHERE id = ?`,
          [req.user.id, eogId]
        );

        // Update user status
        await connection.query(
          `UPDATE users u
           JOIN eog_users eu ON eu.user_id = u.id
           SET u.status = 'active'
           WHERE eu.eog_id = ? AND u.status = 'temporary'`,
          [eogId]
        );

        // Update review status
        await connection.query(
          `UPDATE cdo_review_queue SET
             status = 'approved',
             review_notes = ?,
             reviewed_at = NOW()
           WHERE id = ?`,
          [
            req.body.notes || 'Approved by CDO',
            eog.queue_id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'eog_approved',
            `EOG approved by CDO: ${req.body.notes || 'No notes provided'}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Send approval notification (outside transaction)
        setTimeout(async () => {
          try {
            // Get user to notify
            const eogUser = await db.getOne(
              `SELECT u.* FROM users u
               JOIN eog_users eu ON eu.user_id = u.id
               WHERE eu.eog_id = ? AND eu.is_primary_contact = TRUE`,
              [eogId]
            );

            if (eogUser) {
              await emailUtils.sendApprovalNotification(eog, eogUser);
            }
          } catch (emailError) {
            logger.error(`Failed to send approval notification: ${emailError.message}`);
          }
        }, 0);

        return res.status(200).json({
          success: true,
          message: 'EOG approved successfully',
          data: {
            eog_id: eogId,
            status: 'approved',
            approved_by: req.user.id,
            approved_at: new Date()
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Approve EOG error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/cdo/queue/:eogId/reject
 * @desc    Reject EOG
 * @access  Private (CDO only)
 */
router.post('/queue/:eogId/reject',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const { rejection_reason } = req.body;

      if (!rejection_reason) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Rejection reason is required'
        });
      }

      // Check if EOG is in CDO's region and in review
      const eog = await db.getOne(
        `SELECT e.*, q.id as queue_id
         FROM eogs e
         JOIN cdo_review_queue q ON q.eog_id = e.id
         WHERE e.id = ? AND e.region_id = ? 
         AND e.status = 'pending_verification'
         AND q.status = 'in_review' AND q.assigned_cdo_id = ?`,
        [eogId, req.user.region_id, req.user.id]
      );

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not in your region, or not in review'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update EOG status
        await connection.query(
          `UPDATE eogs SET 
             status = 'rejected',
             rejection_reason = ?
           WHERE id = ?`,
          [rejection_reason, eogId]
        );

        // Update review status
        await connection.query(
          `UPDATE cdo_review_queue SET
             status = 'rejected',
             review_notes = ?,
             reviewed_at = NOW()
           WHERE id = ?`,
          [
            rejection_reason,
            eog.queue_id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'eog_rejected',
            `EOG rejected by CDO: ${rejection_reason}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Send rejection notification (outside transaction)
        setTimeout(async () => {
          try {
            // Get user to notify
            const eogUser = await db.getOne(
              `SELECT u.* FROM users u
               JOIN eog_users eu ON eu.user_id = u.id
               WHERE eu.eog_id = ? AND eu.is_primary_contact = TRUE`,
              [eogId]
            );

            if (eogUser) {
              const subject = 'RDF System - EOG Registration Rejected';
              const body = `
                <h1>EOG Registration Rejected</h1>
                <p>Hello ${eogUser.first_name} ${eogUser.last_name},</p>
                <p>We regret to inform you that your EOG registration for "${eog.company_name}" has been rejected for the following reason:</p>
                <p><strong>${rejection_reason}</strong></p>
                <p>If you have any questions or would like to appeal this decision, please contact your regional CDO office.</p>
                <p>Thank you,</p>
                <p>The RDF System Team</p>
              `;

              await emailUtils.sendEmail(eogUser.email, subject, body, eogUser.id, eogId, 'eogs');
            }
          } catch (emailError) {
            logger.error(`Failed to send rejection notification: ${emailError.message}`);
          }
        }, 0);

        return res.status(200).json({
          success: true,
          message: 'EOG rejected successfully',
          data: {
            eog_id: eogId,
            status: 'rejected',
            rejection_reason
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Reject EOG error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/cdo/queue/:eogId/more-info
 * @desc    Request more information for EOG
 * @access  Private (CDO only)
 */
router.post('/queue/:eogId/more-info',
  authenticate,
  requireRole('CDO'),
  validateParams(schemas.eogIdParam),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const { info_needed } = req.body;

      if (!info_needed) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Information needed details are required'
        });
      }

      // Check if EOG is in CDO's region and assigned to them
      const eog = await db.getOne(
        `SELECT e.*, q.id as queue_id, q.status as queue_status
   FROM eogs e
   JOIN cdo_review_queue q ON q.eog_id = e.id
   WHERE e.id = ? 
   AND e.region_id = ? 
   AND q.assigned_cdo_id = ?
   AND e.status = 'pending_verification'`,
        [eogId, req.user.region_id, req.user.id]
      );

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG not found, not in your region, or not in review'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update review status
        await connection.query(
          `UPDATE cdo_review_queue SET
             status = 'more_info_needed',
             review_notes = ?,
             reviewed_at = NOW()
           WHERE id = ?`,
          [
            info_needed,
            eog.queue_id
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'more_info_requested',
            `CDO requested more information: ${info_needed}`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Send more info notification (outside transaction)
        setTimeout(async () => {
          try {
            // Get user to notify
            const eogUser = await db.getOne(
              `SELECT u.* FROM users u
               JOIN eog_users eu ON eu.user_id = u.id
               WHERE eu.eog_id = ? AND eu.is_primary_contact = TRUE`,
              [eogId]
            );

            if (eogUser) {
              const subject = 'RDF System - Additional Information Needed for EOG Registration';
              const body = `
                <h1>Additional Information Needed</h1>
                <p>Hello ${eogUser.first_name} ${eogUser.last_name},</p>
                <p>Our CDO needs additional information regarding your EOG registration for "${eog.company_name}":</p>
                <p><strong>${info_needed}</strong></p>
                <p>Please log in to your account and provide the requested information. Your application remains in "Pending Verification" status until this information is provided.</p>
                <p>Thank you,</p>
                <p>The RDF System Team</p>
              `;

              await emailUtils.sendEmail(eogUser.email, subject, body, eogUser.id, eogId, 'eogs');
            }
          } catch (emailError) {
            logger.error(`Failed to send more info notification: ${emailError.message}`);
          }
        }, 0);

        return res.status(200).json({
          success: true,
          message: 'More information requested successfully',
          data: {
            eog_id: eogId,
            review_status: 'more_info_needed',
            info_needed
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Request more info error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/cdo/dashboard
 * @desc    Get CDO dashboard stats
 * @access  Private (CDO and SUPER_USER only)
 */
router.get('/dashboard',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  async (req, res) => {
    try {
      const isSuperUser = req.user.role === 'SUPER_USER';
      const regionId = req.user.region_id;

      // Build queries based on user role
      let queueStatsQuery = `
        SELECT
          COUNT(*) as total_queue,
          SUM(CASE WHEN q.status = 'pending' THEN 1 ELSE 0 END) as pending_count,
          SUM(CASE WHEN q.status = 'in_review' THEN 1 ELSE 0 END) as in_review_count,
          SUM(CASE WHEN q.status = 'approved' THEN 1 ELSE 0 END) as approved_count,
          SUM(CASE WHEN q.status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
          SUM(CASE WHEN q.status = 'more_info_needed' THEN 1 ELSE 0 END) as more_info_count
        FROM cdo_review_queue q
        JOIN eogs e ON e.id = q.eog_id
      `;

      let eogStatsQuery = `
        SELECT
          COUNT(*) as total_eogs,
          SUM(CASE WHEN e.status = 'temporary' THEN 1 ELSE 0 END) as temporary_count,
          SUM(CASE WHEN e.status = 'pending_verification' THEN 1 ELSE 0 END) as pending_count,
          SUM(CASE WHEN e.status = 'approved' THEN 1 ELSE 0 END) as approved_count,
          SUM(CASE WHEN e.status = 'rejected' THEN 1 ELSE 0 END) as rejected_count,
          SUM(CASE WHEN e.status = 'suspended' THEN 1 ELSE 0 END) as suspended_count
        FROM eogs e
      `;

      let recentActivitiesQuery = `
        SELECT a.*, e.company_name
        FROM eog_temporal_activity a
        JOIN eogs e ON e.id = a.eog_id
      `;

      let memberStatsQuery = `
        SELECT
          COUNT(*) as total_members,
          SUM(CASE WHEN m.verification_status = 'pending' THEN 1 ELSE 0 END) as pending_count,
          SUM(CASE WHEN m.verification_status = 'verified' THEN 1 ELSE 0 END) as verified_count,
          SUM(CASE WHEN m.verification_status = 'failed' THEN 1 ELSE 0 END) as failed_count,
          SUM(CASE WHEN m.verification_status = 'corrected' THEN 1 ELSE 0 END) as corrected_count
        FROM eog_members m
        JOIN eogs e ON e.id = m.eog_id
      `;

      // Add WHERE clause for non-super users
      const queryParams = [];
      if (!isSuperUser) {
        const whereClause = ' WHERE e.region_id = ?';
        queueStatsQuery += whereClause;
        eogStatsQuery += whereClause;
        recentActivitiesQuery += whereClause;
        memberStatsQuery += whereClause;
        queryParams.push(regionId);
      }

      // Add ORDER BY and LIMIT for recent activities
      recentActivitiesQuery += ' ORDER BY a.created_at DESC LIMIT 10';

      // Execute queries
      const queueStats = await db.getOne(queueStatsQuery, queryParams);
      const eogStats = await db.getOne(eogStatsQuery, queryParams);
      const recentActivities = await db.query(recentActivitiesQuery, queryParams);
      const memberStats = await db.getOne(memberStatsQuery, queryParams);

      // Get region information
      let regionName = null;
      if (isSuperUser) {
        regionName = 'All Regions';
      } else {
        const region = await db.getOne(
          'SELECT name FROM regions WHERE id = ?',
          [regionId]
        );
        regionName = region ? region.name : null;
      }

      return res.status(200).json({
        success: true,
        data: {
          region: regionName,
          user_role: req.user.role,
          queue_stats: queueStats || {
            total_queue: 0,
            pending_count: 0,
            in_review_count: 0,
            approved_count: 0,
            rejected_count: 0,
            more_info_count: 0
          },
          eog_stats: eogStats || {
            total_eogs: 0,
            temporary_count: 0,
            pending_count: 0,
            approved_count: 0,
            rejected_count: 0,
            suspended_count: 0
          },
          member_stats: memberStats || {
            total_members: 0,
            pending_count: 0,
            verified_count: 0,
            failed_count: 0,
            corrected_count: 0
          },
          recent_activities: recentActivities
        }
      });
    } catch (error) {
      logger.error(`CDO dashboard error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;
