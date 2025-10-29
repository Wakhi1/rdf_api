const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, checkRole } = require('../middleware/auth.middleware');

/**
 * @route   GET /api/audit/activity-logs
 * @desc    Get user activity logs
 * @access  Private (SUPER_USER, CDO)
 */
router.get('/activity-logs', verifyToken, checkRole('SUPER_USER', 'CDO'), async (req, res, next) => {
  try {
    const { user_id, action, entity_type, from_date, to_date, page = 1, limit = 100 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT ual.*, u.first_name, u.last_name, u.email, u.role
      FROM user_activity_logs ual
      INNER JOIN users u ON ual.user_id = u.id
      WHERE 1=1
    `;
    const params = [];

    if (user_id) {
      query += ' AND ual.user_id = ?';
      params.push(user_id);
    }

    if (action) {
      query += ' AND ual.action = ?';
      params.push(action);
    }

    if (entity_type) {
      query += ' AND ual.entity_type = ?';
      params.push(entity_type);
    }

    if (from_date) {
      query += ' AND ual.created_at >= ?';
      params.push(from_date);
    }

    if (to_date) {
      query += ' AND ual.created_at <= ?';
      params.push(to_date);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY ual.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const logs = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        logs,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/audit/otp-logs
 * @desc    Get OTP logs for audit
 * @access  Private (SUPER_USER)
 */
router.get('/otp-logs', verifyToken, checkRole('SUPER_USER'), async (req, res, next) => {
  try {
    const { user_id, action, page = 1, limit = 100 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT ol.*, u.first_name, u.last_name, u.email, oc.purpose, oc.created_at as otp_created
      FROM otp_logs ol
      INNER JOIN users u ON ol.user_id = u.id
      LEFT JOIN otp_codes oc ON ol.otp_id = oc.id
      WHERE 1=1
    `;
    const params = [];

    if (user_id) {
      query += ' AND ol.user_id = ?';
      params.push(user_id);
    }

    if (action) {
      query += ' AND ol.action = ?';
      params.push(action);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY ol.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const logs = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        logs,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/audit/workflow-history
 * @desc    Get complete workflow history
 * @access  Private (SUPER_USER, CDO)
 */
router.get('/workflow-history', verifyToken, checkRole('SUPER_USER', 'CDO'), async (req, res, next) => {
  try {
    const { application_id, action, from_date, to_date, page = 1, limit = 100 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        aw.*,
        u.first_name, u.last_name, u.role,
        a.reference_number,
        e.company_name
      FROM application_workflow aw
      INNER JOIN users u ON aw.user_id = u.id
      INNER JOIN applications a ON aw.application_id = a.id
      INNER JOIN eogs e ON a.eog_id = e.id
      WHERE 1=1
    `;
    const params = [];

    if (application_id) {
      query += ' AND aw.application_id = ?';
      params.push(application_id);
    }

    if (action) {
      query += ' AND aw.action = ?';
      params.push(action);
    }

    if (from_date) {
      query += ' AND aw.created_at >= ?';
      params.push(from_date);
    }

    if (to_date) {
      query += ' AND aw.created_at <= ?';
      params.push(to_date);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY aw.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const history = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        history,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/audit/system-integrity
 * @desc    Check system integrity and data consistency
 * @access  Private (SUPER_USER)
 */
router.get('/system-integrity', verifyToken, checkRole('SUPER_USER'), async (req, res, next) => {
  try {
    // Check for orphaned records
    const [orphanedEOGUsers] = await db.query(`
      SELECT COUNT(*) as count FROM eog_users eu 
      WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = eu.user_id)
      OR NOT EXISTS (SELECT 1 FROM eogs e WHERE e.id = eu.eog_id)
    `);

    const [orphanedAnswers] = await db.query(`
      SELECT COUNT(*) as count FROM application_answers aa
      WHERE NOT EXISTS (SELECT 1 FROM applications a WHERE a.id = aa.application_id)
    `);

    const [incompleteApplications] = await db.query(`
      SELECT COUNT(*) as count FROM applications
      WHERE status = 'draft' AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
    `);

    const [expiredTempAccounts] = await db.query(`
      SELECT COUNT(*) as count FROM eogs
      WHERE status = 'temporary' AND temp_account_expires < NOW()
    `);

    res.json({
      status: 'success',
      data: {
        integrity_checks: {
          orphaned_eog_users: orphanedEOGUsers.count,
          orphaned_answers: orphanedAnswers.count,
          incomplete_applications: incompleteApplications.count,
          expired_temp_accounts: expiredTempAccounts.count
        },
        timestamp: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;