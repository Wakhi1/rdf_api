const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth.middleware');

/**
 * @route   GET /api/statistics/dashboard
 * @desc    Get dashboard statistics
 * @access  Private
 */
router.get('/dashboard', verifyToken, async (req, res, next) => {
  try {
    // Overall statistics
    const [overallStats] = await db.query(`
      SELECT 
        (SELECT COUNT(*) FROM eogs WHERE status = 'approved') as total_eogs,
        (SELECT COUNT(*) FROM applications) as total_applications,
        (SELECT COUNT(*) FROM applications WHERE status = 'completed') as completed_applications,
        (SELECT COUNT(*) FROM applications WHERE status = 'pending') as pending_applications,
        (SELECT COUNT(*) FROM applications WHERE status = 'returned') as returned_applications,
        (SELECT COALESCE(SUM(amount), 0) FROM disbursements) as total_disbursed
    `);

    // Applications by status
    const applicationsByStatus = await db.query(`
      SELECT status, COUNT(*) as count
      FROM applications
      GROUP BY status
    `);

    // Applications by level
    const applicationsByLevel = await db.query(`
      SELECT current_level, COUNT(*) as count
      FROM applications
      WHERE status = 'pending'
      GROUP BY current_level
    `);

    // Regional distribution
    const regionalDistribution = await db.query(`
      SELECT 
        r.name as region,
        COUNT(DISTINCT e.id) as eogs,
        COUNT(DISTINCT a.id) as applications,
        COALESCE(SUM(d.amount), 0) as total_disbursed
      FROM regions r
      LEFT JOIN eogs e ON r.id = e.region_id
      LEFT JOIN applications a ON e.id = a.eog_id
      LEFT JOIN disbursements d ON a.id = d.application_id
      GROUP BY r.id, r.name
      ORDER BY r.name
    `);

    // Recent activity
    const recentActivity = await db.query(`
      SELECT 
        aw.action,
        aw.from_level,
        aw.to_level,
        aw.comments,
        aw.created_at,
        u.first_name,
        u.last_name,
        a.reference_number,
        e.company_name
      FROM application_workflow aw
      INNER JOIN users u ON aw.user_id = u.id
      INNER JOIN applications a ON aw.application_id = a.id
      INNER JOIN eogs e ON a.eog_id = e.id
      ORDER BY aw.created_at DESC
      LIMIT 20
    `);

    // Processing time analysis
    const processingTime = await db.query(`
      SELECT 
        current_level,
        AVG(DATEDIFF(NOW(), submitted_at)) as avg_days
      FROM applications
      WHERE status = 'pending'
      GROUP BY current_level
    `);

    res.json({
      status: 'success',
      data: {
        overall: overallStats,
        applications_by_status: applicationsByStatus,
        applications_by_level: applicationsByLevel,
        regional_distribution: regionalDistribution,
        recent_activity: recentActivity,
        processing_time: processingTime
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/statistics/trends
 * @desc    Get trend analysis
 * @access  Private
 */
router.get('/trends', verifyToken, async (req, res, next) => {
  try {
    const { period = '12' } = req.query; // months

    // Applications trend
    const applicationsTrend = await db.query(`
      SELECT 
        DATE_FORMAT(created_at, '%Y-%m') as month,
        COUNT(*) as total,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending
      FROM applications
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? MONTH)
      GROUP BY DATE_FORMAT(created_at, '%Y-%m')
      ORDER BY month
    `, [parseInt(period)]);

    // EOG registration trend
    const eogTrend = await db.query(`
      SELECT 
        DATE_FORMAT(created_at, '%Y-%m') as month,
        COUNT(*) as total,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved
      FROM eogs
      WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? MONTH)
      GROUP BY DATE_FORMAT(created_at, '%Y-%m')
      ORDER BY month
    `, [parseInt(period)]);

    // Disbursement trend
    const disbursementTrend = await db.query(`
      SELECT 
        DATE_FORMAT(disbursement_date, '%Y-%m') as month,
        SUM(amount) as total,
        COUNT(*) as count
      FROM disbursements
      WHERE disbursement_date >= DATE_SUB(NOW(), INTERVAL ? MONTH)
      GROUP BY DATE_FORMAT(disbursement_date, '%Y-%m')
      ORDER BY month
    `, [parseInt(period)]);

    res.json({
      status: 'success',
      data: {
        applications: applicationsTrend,
        eogs: eogTrend,
        disbursements: disbursementTrend
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/statistics/performance
 * @desc    Get performance metrics
 * @access  Private
 */
router.get('/performance', verifyToken, async (req, res, next) => {
  try {
    // Approval rates by level
    const approvalRates = await db.query(`
      SELECT 
        from_level,
        COUNT(*) as total,
        SUM(CASE WHEN action = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN action = 'returned' THEN 1 ELSE 0 END) as returned,
        ROUND((SUM(CASE WHEN action = 'approved' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as approval_rate
      FROM application_workflow
      WHERE from_level IS NOT NULL
      GROUP BY from_level
    `);

    // Average processing time by level
    const processingTimeByLevel = await db.query(`
      SELECT 
        aw1.from_level,
        AVG(DATEDIFF(aw2.created_at, aw1.created_at)) as avg_days
      FROM application_workflow aw1
      INNER JOIN application_workflow aw2 ON aw1.application_id = aw2.application_id
      WHERE aw1.from_level = aw2.from_level AND aw2.id > aw1.id
      GROUP BY aw1.from_level
    `);

    // User productivity
    const userProductivity = await db.query(`
      SELECT 
        u.first_name,
        u.last_name,
        u.role,
        COUNT(aw.id) as actions_count,
        DATE(MAX(aw.created_at)) as last_action
      FROM users u
      INNER JOIN application_workflow aw ON u.id = aw.user_id
      WHERE u.status = 'active'
      GROUP BY u.id, u.first_name, u.last_name, u.role
      ORDER BY actions_count DESC
      LIMIT 20
    `);

    res.json({
      status: 'success',
      data: {
        approval_rates: approvalRates,
        processing_time: processingTimeByLevel,
        user_productivity: userProductivity
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/statistics/export
 * @desc    Export statistics data
 * @access  Private (SUPER_USER)
 */
router.get('/export', verifyToken, async (req, res, next) => {
  try {
    const { type, format = 'json' } = req.query;

    let data;
    switch (type) {
      case 'applications':
        data = await db.query(`
          SELECT a.*, e.company_name, r.name as region_name
          FROM applications a
          INNER JOIN eogs e ON a.eog_id = e.id
          INNER JOIN regions r ON e.region_id = r.id
          ORDER BY a.created_at DESC
        `);
        break;
      
      case 'eogs':
        data = await db.query(`
          SELECT e.*, r.name as region_name, t.name as tinkhundla_name
          FROM eogs e
          INNER JOIN regions r ON e.region_id = r.id
          INNER JOIN tinkhundla t ON e.tinkhundla_id = t.id
          ORDER BY e.created_at DESC
        `);
        break;
      
      case 'disbursements':
        data = await db.query(`
          SELECT d.*, a.reference_number, e.company_name, t.name as tinkhundla_name
          FROM disbursements d
          INNER JOIN applications a ON d.application_id = a.id
          INNER JOIN eogs e ON a.eog_id = e.id
          INNER JOIN tinkhundla t ON d.tinkhundla_id = t.id
          ORDER BY d.disbursement_date DESC
        `);
        break;
      
      default:
        return res.status(400).json({
          status: 'error',
          message: 'Invalid export type'
        });
    }

    res.json({
      status: 'success',
      data: data
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
