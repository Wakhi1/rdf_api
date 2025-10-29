/**
 * Reports & Analytics Routes
 * Handles all reporting endpoints for system analytics and data exports
 */

const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const logger = require('../utils/logger');

/**
 * @route   GET /api/reports/dashboard
 * @desc    Get dashboard overview statistics
 * @access  Private (All authenticated users)
 */
router.get('/dashboard', authenticate, async (req, res) => {
  try {
    const role = req.user.role;
    const userId = req.user.id;
    const regionId = req.user.region_id || null;
    const tinkhundlaId = req.user.tinkhundla_id || null;

    // Build where clause based on role
    let whereClause = '';
    const params = [];
    
    if (role === 'EOG') {
      // EOGs can only see their own data
      const eogResult = await db.query(
        'SELECT eog_id FROM eog_users WHERE user_id = ?',
        [userId]
      );
      
      if (!eogResult || eogResult.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'No EOG association',
          message: 'Your account is not associated with any EOG'
        });
      }
      
      const eogId = eogResult[0].eog_id;
      whereClause = 'WHERE a.eog_id = ?';
      params.push(eogId);
    } else if (role === 'CDO' && regionId) {
      whereClause = 'WHERE e.region_id = ?';
      params.push(regionId);
    } else if (['MICROPROJECTS', 'PS', 'SUPER_USER', 'LINE_MINISTRY', 'RDFC', 'RDFTC'].includes(role)) {
      whereClause = '';
    } else {
      if (regionId) {
        whereClause = 'WHERE e.region_id = ?';
        params.push(regionId);
        
        if (tinkhundlaId && (role === 'INKHUNDLA_COUNCIL' || role === 'CDC')) {
          whereClause += ' AND e.tinkhundla_id = ?';
          params.push(tinkhundlaId);
        }
      }
    }
    
    // Get application counts by status
    const applicationStats = await db.query(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN a.status = 'submitted' THEN 1 ELSE 0 END) as submitted,
        SUM(CASE WHEN a.status = 'in_review' THEN 1 ELSE 0 END) as in_review,
        SUM(CASE WHEN a.status = 'returned' THEN 1 ELSE 0 END) as returned,
        SUM(CASE WHEN a.status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN a.status = 'rejected' THEN 1 ELSE 0 END) as rejected,
        SUM(CASE WHEN a.status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN a.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled,
        SUM(CASE WHEN a.status = 'draft' THEN 1 ELSE 0 END) as draft
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    // Get application counts by level
    const levelStats = await db.query(`
      SELECT 
        SUM(CASE WHEN a.current_level = 'EOG_LEVEL' THEN 1 ELSE 0 END) as eog_level,
        SUM(CASE WHEN a.current_level = 'MINISTRY_LEVEL' THEN 1 ELSE 0 END) as ministry_level,
        SUM(CASE WHEN a.current_level = 'MICROPROJECTS_LEVEL' THEN 1 ELSE 0 END) as microprojects_level,
        SUM(CASE WHEN a.current_level = 'CDO_LEVEL' THEN 1 ELSE 0 END) as cdo_level,
        SUM(CASE WHEN a.current_level = 'UMPHAKATSI_LEVEL' THEN 1 ELSE 0 END) as umphakatsi_level,
        SUM(CASE WHEN a.current_level = 'INKHUNDLA_LEVEL' THEN 1 ELSE 0 END) as inkhundla_level,
        SUM(CASE WHEN a.current_level = 'RDFTC_LEVEL' THEN 1 ELSE 0 END) as rdftc_level,
        SUM(CASE WHEN a.current_level = 'RDFC_LEVEL' THEN 1 ELSE 0 END) as rdfc_level,
        SUM(CASE WHEN a.current_level = 'PS_LEVEL' THEN 1 ELSE 0 END) as ps_level,
        SUM(CASE WHEN a.current_level = 'PROCUREMENT_LEVEL' THEN 1 ELSE 0 END) as procurement_level,
        SUM(CASE WHEN a.current_level = 'IMPLEMENTATION_LEVEL' THEN 1 ELSE 0 END) as implementation_level
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    // Get funding statistics
    const fundingStats = await db.query(`
      SELECT 
        COALESCE(SUM(a.funding_amount), 0) as total_requested,
        COALESCE(SUM(a.approved_amount), 0) as total_approved,
        COALESCE(SUM(a.disbursed_amount), 0) as total_disbursed
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    // Get application counts by region
    const regionStats = await db.query(`
      SELECT 
        r.name as region_name,
        COUNT(*) as application_count,
        COALESCE(SUM(a.approved_amount), 0) as approved_amount
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      JOIN regions r ON e.region_id = r.id
      ${whereClause ? whereClause + ' AND' : 'WHERE'} a.status != 'draft'
      GROUP BY r.name
      ORDER BY application_count DESC
    `, params);
    
    // Safely build stats object with null checks
    const appStats = applicationStats && applicationStats.length > 0 ? applicationStats[0] : null;
    const lvlStats = levelStats && levelStats.length > 0 ? levelStats[0] : null;
    const fundStats = fundingStats && fundingStats.length > 0 ? fundingStats[0] : null;
    
    if (!appStats || !lvlStats || !fundStats) {
      return res.status(200).json({
        success: true,
        data: {
          applications: {
            counts: {
              total: 0,
              by_status: {
                draft: 0,
                submitted: 0,
                in_review: 0,
                returned: 0,
                approved: 0,
                rejected: 0,
                completed: 0,
                cancelled: 0
              },
              by_level: {
                eog_level: 0,
                ministry_level: 0,
                microprojects_level: 0,
                cdo_level: 0,
                umphakatsi_level: 0,
                inkhundla_level: 0,
                rdftc_level: 0,
                rdfc_level: 0,
                ps_level: 0,
                procurement_level: 0,
                implementation_level: 0
              }
            },
            funding: {
              total_requested: 0,
              total_approved: 0,
              total_disbursed: 0,
              approval_rate: 0,
              disbursement_rate: 0
            },
            by_region: []
          }
        },
        message: 'Dashboard statistics retrieved successfully (no data)'
      });
    }
    
    const stats = {
      applications: {
        counts: {
          total: appStats.total || 0,
          by_status: {
            draft: appStats.draft || 0,
            submitted: appStats.submitted || 0,
            in_review: appStats.in_review || 0,
            returned: appStats.returned || 0,
            approved: appStats.approved || 0,
            rejected: appStats.rejected || 0,
            completed: appStats.completed || 0,
            cancelled: appStats.cancelled || 0
          },
          by_level: {
            eog_level: lvlStats.eog_level || 0,
            ministry_level: lvlStats.ministry_level || 0,
            microprojects_level: lvlStats.microprojects_level || 0,
            cdo_level: lvlStats.cdo_level || 0,
            umphakatsi_level: lvlStats.umphakatsi_level || 0,
            inkhundla_level: lvlStats.inkhundla_level || 0,
            rdftc_level: lvlStats.rdftc_level || 0,
            rdfc_level: lvlStats.rdfc_level || 0,
            ps_level: lvlStats.ps_level || 0,
            procurement_level: lvlStats.procurement_level || 0,
            implementation_level: lvlStats.implementation_level || 0
          }
        },
        funding: {
          total_requested: parseFloat(fundStats.total_requested || 0),
          total_approved: parseFloat(fundStats.total_approved || 0),
          total_disbursed: parseFloat(fundStats.total_disbursed || 0),
          approval_rate: fundStats.total_requested > 0 
            ? parseFloat(((fundStats.total_approved / fundStats.total_requested) * 100).toFixed(1)) 
            : 0,
          disbursement_rate: fundStats.total_approved > 0 
            ? parseFloat(((fundStats.total_disbursed / fundStats.total_approved) * 100).toFixed(1)) 
            : 0
        },
        by_region: regionStats || []
      }
    };

    // Role-specific statistics
    if (role === 'EOG') {
      const eogDetails = await db.query(`
        SELECT e.*, 
          r.name as region_name, 
          t.name as tinkhundla_name,
          i.name as umphakatsi_name,
          i.chief_name,
          (SELECT COUNT(*) FROM eog_members WHERE eog_id = e.id) as member_count,
          (SELECT COUNT(*) FROM eog_members WHERE eog_id = e.id AND is_executive = TRUE) as executive_count,
          (SELECT COUNT(*) FROM eog_members WHERE eog_id = e.id AND verification_status = 'verified') as verified_count
        FROM eogs e
        JOIN eog_users eu ON e.id = eu.eog_id
        JOIN regions r ON e.region_id = r.id
        JOIN tinkhundla t ON e.tinkhundla_id = t.id
        JOIN imiphakatsi i ON e.umphakatsi_id = i.id
        WHERE eu.user_id = ?
      `, [userId]);
      
      if (eogDetails && eogDetails.length > 0) {
        stats.eog = eogDetails[0];
      }
      
      const pendingTasks = await db.query(`
        SELECT 
          COUNT(CASE WHEN a.status = 'returned' THEN 1 ELSE NULL END) as returned_applications,
          COUNT(CASE WHEN a.status = 'draft' THEN 1 ELSE NULL END) as draft_applications
        FROM applications a
        JOIN eog_users eu ON a.eog_id = eu.eog_id
        WHERE eu.user_id = ?
      `, [userId]);
      
      if (pendingTasks && pendingTasks.length > 0) {
        stats.pending_tasks = {
          returned_applications: pendingTasks[0].returned_applications || 0,
          draft_applications: pendingTasks[0].draft_applications || 0
        };
      }
    } else if (role === 'CDO') {
      const cdoQueue = await db.query(`
        SELECT 
          COUNT(CASE WHEN a.current_level = 'CDO_LEVEL' AND a.status = 'in_review' THEN 1 ELSE NULL END) as pending_reviews,
          COUNT(CASE WHEN e.status = 'pending_verification' THEN 1 ELSE NULL END) as pending_eog_verifications
        FROM eogs e
        LEFT JOIN applications a ON a.eog_id = e.id
        WHERE e.region_id = ?
      `, [regionId]);
      
      if (cdoQueue && cdoQueue.length > 0) {
        stats.cdo_queue = {
          pending_reviews: cdoQueue[0].pending_reviews || 0,
          pending_eog_verifications: cdoQueue[0].pending_eog_verifications || 0
        };
      }
    } else if (role === 'MICROPROJECTS') {
      const microprojectsQueue = await db.query(`
        SELECT 
          COUNT(CASE WHEN a.current_level = 'MICROPROJECTS_LEVEL' THEN 1 ELSE NULL END) as pending_technical_reviews,
          COUNT(CASE WHEN a.current_level = 'PROCUREMENT_LEVEL' THEN 1 ELSE NULL END) as pending_procurement,
          COUNT(CASE WHEN a.current_level = 'IMPLEMENTATION_LEVEL' THEN 1 ELSE NULL END) as ongoing_implementations
        FROM applications a
      `);
      
      if (microprojectsQueue && microprojectsQueue.length > 0) {
        stats.microprojects_queue = {
          pending_technical_reviews: microprojectsQueue[0].pending_technical_reviews || 0,
          pending_procurement: microprojectsQueue[0].pending_procurement || 0,
          ongoing_implementations: microprojectsQueue[0].ongoing_implementations || 0
        };
      }
    }
    
    return res.status(200).json({
      success: true,
      data: stats,
      message: 'Dashboard statistics retrieved successfully'
    });
  } catch (error) {
    logger.error(`Get dashboard error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/reports/eogs
 * @desc    Get EOG performance report
 * @access  Private (SUPER_USER, PS, RDFC, CDO)
 */
router.get('/eogs', authenticate, requireRole(['SUPER_USER', 'PS', 'RDFC', 'RDFTC', 'CDO']), async (req, res) => {
  try {
    const { region, status, search, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;
    
    // Build where clause
    const whereConditions = [];
    const params = [];
    
    // Role-based filtering
    if (req.user.role === 'CDO' && req.user.region_id) {
      whereConditions.push('e.region_id = ?');
      params.push(req.user.region_id);
    } else if (region) {
      whereConditions.push('e.region_id = ?');
      params.push(region);
    }
    
    if (status) {
      whereConditions.push('e.status = ?');
      params.push(status);
    }
    
    if (search) {
      whereConditions.push('(e.company_name LIKE ? OR e.bin_cin LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm);
    }
    
    const whereClause = whereConditions.length > 0 
      ? 'WHERE ' + whereConditions.join(' AND ') 
      : '';
    
    // Get EOGs with statistics
    const eogs = await db.query(`
      SELECT 
        e.*,
        r.name as region,
        t.name as tinkhundla,
        (SELECT COUNT(*) FROM eog_members WHERE eog_id = e.id) as total_members,
        (SELECT COUNT(*) FROM applications WHERE eog_id = e.id) as application_count,
        (SELECT COUNT(*) FROM applications WHERE eog_id = e.id AND status = 'approved') as approved_applications,
        COALESCE((SELECT SUM(funding_amount) FROM applications WHERE eog_id = e.id), 0) as total_requested,
        COALESCE((SELECT SUM(approved_amount) FROM applications WHERE eog_id = e.id), 0) as total_approved,
        COALESCE((SELECT SUM(disbursed_amount) FROM applications WHERE eog_id = e.id), 0) as total_disbursed
      FROM eogs e
      JOIN regions r ON e.region_id = r.id
      JOIN tinkhundla t ON e.tinkhundla_id = t.id
      ${whereClause}
      ORDER BY e.created_at DESC
      LIMIT ? OFFSET ?
    `, [...params, parseInt(limit), offset]);
    
    // Get total count
    const countResult = await db.query(`
      SELECT COUNT(*) as total
      FROM eogs e
      ${whereClause}
    `, params);
    
    const total = countResult && countResult.length > 0 ? countResult[0].total : 0;
    
    // Get summary statistics
    const summaryResult = await db.query(`
      SELECT 
        COUNT(*) as total_eogs,
        SUM(CASE WHEN status = 'temporary' THEN 1 ELSE 0 END) as temporary,
        SUM(CASE WHEN status = 'pending_verification' THEN 1 ELSE 0 END) as pending_verification,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
        SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END) as suspended,
        (SELECT COUNT(*) FROM eog_members) as total_members,
        (SELECT COUNT(DISTINCT eog_id) FROM applications) as eogs_with_applications
      FROM eogs e
      ${whereClause}
    `, params);
    
    const summary = summaryResult && summaryResult.length > 0 
      ? summaryResult[0] 
      : {
          total_eogs: 0,
          temporary: 0,
          pending_verification: 0,
          approved: 0,
          rejected: 0,
          suspended: 0,
          total_members: 0,
          eogs_with_applications: 0
        };
    
    return res.status(200).json({
      success: true,
      data: {
        eogs: eogs || [],
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        },
        summary: {
          total_eogs: summary.total_eogs || 0,
          by_status: {
            temporary: summary.temporary || 0,
            pending_verification: summary.pending_verification || 0,
            approved: summary.approved || 0,
            rejected: summary.rejected || 0,
            suspended: summary.suspended || 0
          },
          total_members: summary.total_members || 0,
          total_applications: summary.eogs_with_applications || 0
        }
      },
      message: `Retrieved ${eogs ? eogs.length : 0} EOGs`
    });
  } catch (error) {
    logger.error(`Get EOGs report error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/reports/applications
 * @desc    Get applications report
 * @access  Private (All authenticated users)
 */
router.get('/applications', authenticate, async (req, res) => {
  try {
    const {
      status,
      current_level,
      region,
      tinkhundla,
      eog_id,
      search,
      from_date,
      to_date,
      page = 1,
      limit = 10
    } = req.query;
    
    const offset = (page - 1) * limit;
    
    // Build where clause based on role and filters
    const whereConditions = [];
    const params = [];
    
    // Role-based filtering
    if (req.user.role === 'EOG') {
      const eogResult = await db.query(
        'SELECT eog_id FROM eog_users WHERE user_id = ?',
        [req.user.id]
      );
      
      if (eogResult && eogResult.length > 0) {
        whereConditions.push('a.eog_id = ?');
        params.push(eogResult[0].eog_id);
      }
    } else if (req.user.role === 'CDO' && req.user.region_id) {
      whereConditions.push('e.region_id = ?');
      params.push(req.user.region_id);
    } else {
      // System-level roles can see based on filters
      if (region) {
        whereConditions.push('e.region_id = ?');
        params.push(region);
      }
      
      if (tinkhundla) {
        whereConditions.push('e.tinkhundla_id = ?');
        params.push(tinkhundla);
      }
    }
    
    if (status) {
      whereConditions.push('a.status = ?');
      params.push(status);
    }
    
    if (current_level) {
      whereConditions.push('a.current_level = ?');
      params.push(current_level);
    }
    
    if (eog_id) {
      whereConditions.push('a.eog_id = ?');
      params.push(eog_id);
    }
    
    if (search) {
      whereConditions.push('(a.reference_number LIKE ? OR a.title LIKE ? OR e.company_name LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }
    
    if (from_date) {
      whereConditions.push('a.submitted_at >= ?');
      params.push(from_date);
    }
    
    if (to_date) {
      whereConditions.push('a.submitted_at <= ?');
      params.push(to_date);
    }
    
    const whereClause = whereConditions.length > 0 
      ? 'WHERE ' + whereConditions.join(' AND ') 
      : '';
    
    // Get applications
    const applications = await db.query(`
      SELECT 
        a.*,
        e.company_name as eog_name,
        r.name as region,
        t.name as tinkhundla
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      JOIN regions r ON e.region_id = r.id
      JOIN tinkhundla t ON e.tinkhundla_id = t.id
      ${whereClause}
      ORDER BY a.submitted_at DESC
      LIMIT ? OFFSET ?
    `, [...params, parseInt(limit), offset]);
    
    // Get total count
    const countResult = await db.query(`
      SELECT COUNT(*) as total
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    const total = countResult && countResult.length > 0 ? countResult[0].total : 0;
    
    // Get summary statistics
    const summaryResult = await db.query(`
      SELECT 
        COUNT(*) as total_applications,
        COALESCE(SUM(a.funding_amount), 0) as total_requested,
        COALESCE(SUM(a.approved_amount), 0) as total_approved,
        COALESCE(SUM(a.disbursed_amount), 0) as total_disbursed,
        COALESCE(AVG(DATEDIFF(a.completed_at, a.submitted_at)), 0) as average_processing_time_days,
        ROUND((SUM(CASE WHEN a.status = 'approved' OR a.status = 'completed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0)), 1) as approval_rate
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    const summary = summaryResult && summaryResult.length > 0 
      ? summaryResult[0] 
      : {
          total_applications: 0,
          total_requested: 0,
          total_approved: 0,
          total_disbursed: 0,
          average_processing_time_days: 0,
          approval_rate: 0
        };
    
    return res.status(200).json({
      success: true,
      data: {
        applications: applications || [],
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        },
        summary: {
          total_applications: summary.total_applications || 0,
          total_requested: parseFloat(summary.total_requested || 0),
          total_approved: parseFloat(summary.total_approved || 0),
          total_disbursed: parseFloat(summary.total_disbursed || 0),
          average_processing_time_days: parseInt(summary.average_processing_time_days || 0),
          approval_rate: parseFloat(summary.approval_rate || 0)
        }
      },
      message: `Retrieved ${applications ? applications.length : 0} applications`
    });
  } catch (error) {
    logger.error(`Get applications report error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/reports/users
 * @desc    Get user analytics report
 * @access  Private (SUPER_USER only)
 */
router.get('/users', authenticate, requireRole(['SUPER_USER']), async (req, res) => {
  try {
    const { role, region, status, search, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;
    
    // Build where clause
    const whereConditions = [];
    const params = [];
    
    if (role) {
      whereConditions.push('u.role = ?');
      params.push(role);
    }
    
    if (region) {
      whereConditions.push('u.region_id = ?');
      params.push(region);
    }
    
    if (status) {
      whereConditions.push('u.status = ?');
      params.push(status);
    }
    
    if (search) {
      whereConditions.push('(u.first_name LIKE ? OR u.last_name LIKE ? OR u.email LIKE ? OR u.username LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }
    
    const whereClause = whereConditions.length > 0 
      ? 'WHERE ' + whereConditions.join(' AND ') 
      : '';
    
    // Get users
    const users = await db.query(`
      SELECT 
        u.*,
        r.name as region,
        (SELECT COUNT(*) FROM user_activity_logs WHERE user_id = u.id AND action LIKE '%login%') as login_count
      FROM users u
      LEFT JOIN regions r ON u.region_id = r.id
      ${whereClause}
      ORDER BY u.created_at DESC
      LIMIT ? OFFSET ?
    `, [...params, parseInt(limit), offset]);
    
    // Get total count
    const countResult = await db.query(`
      SELECT COUNT(*) as total
      FROM users u
      ${whereClause}
    `, params);
    
    const total = countResult && countResult.length > 0 ? countResult[0].total : 0;
    
    // Get summary statistics
    const summaryResult = await db.query(`
      SELECT 
        COUNT(*) as total_users,
        SUM(CASE WHEN role = 'SUPER_USER' THEN 1 ELSE 0 END) as super_users,
        SUM(CASE WHEN role = 'PS' THEN 1 ELSE 0 END) as ps_users,
        SUM(CASE WHEN role = 'RDFC' THEN 1 ELSE 0 END) as rdfc_users,
        SUM(CASE WHEN role = 'RDFTC' THEN 1 ELSE 0 END) as rdftc_users,
        SUM(CASE WHEN role = 'CDO' THEN 1 ELSE 0 END) as cdo_users,
        SUM(CASE WHEN role = 'LINE_MINISTRY' THEN 1 ELSE 0 END) as ministry_users,
        SUM(CASE WHEN role = 'MICROPROJECTS' THEN 1 ELSE 0 END) as microprojects_users,
        SUM(CASE WHEN role = 'EOG' THEN 1 ELSE 0 END) as eog_users,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_users,
        SUM(CASE WHEN status = 'suspended' THEN 1 ELSE 0 END) as suspended_users
      FROM users u
      ${whereClause}
    `, params);
    
    const summary = summaryResult && summaryResult.length > 0 
      ? summaryResult[0] 
      : {
          total_users: 0,
          super_users: 0,
          ps_users: 0,
          rdfc_users: 0,
          rdftc_users: 0,
          cdo_users: 0,
          ministry_users: 0,
          microprojects_users: 0,
          eog_users: 0,
          active_users: 0,
          suspended_users: 0
        };
    
    return res.status(200).json({
      success: true,
      data: {
        users: users || [],
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        },
        summary: {
          total_users: summary.total_users || 0,
          by_role: {
            SUPER_USER: summary.super_users || 0,
            PS: summary.ps_users || 0,
            RDFC: summary.rdfc_users || 0,
            RDFTC: summary.rdftc_users || 0,
            CDO: summary.cdo_users || 0,
            LINE_MINISTRY: summary.ministry_users || 0,
            MICROPROJECTS: summary.microprojects_users || 0,
            EOG: summary.eog_users || 0
          },
          active_users: summary.active_users || 0,
          suspended_users: summary.suspended_users || 0
        }
      },
      message: `Retrieved ${users ? users.length : 0} users`
    });
  } catch (error) {
    logger.error(`Get users report error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/reports/training
 * @desc    Get training register report
 * @access  Private (SUPER_USER, PS, CDO)
 */
router.get('/training', authenticate, requireRole(['SUPER_USER', 'PS', 'CDO', 'RDFC', 'RDFTC']), async (req, res) => {
  try {
    const {
      training_type,
      region,
      gender,
      from_date,
      to_date,
      search,
      page = 1,
      limit = 10
    } = req.query;
    
    const offset = (page - 1) * limit;
    
    // Build where clause
    const whereConditions = [];
    const params = [];
    
    // Role-based filtering
    if (req.user.role === 'CDO' && req.user.region_id) {
      whereConditions.push('tr.region_id = ?');
      params.push(req.user.region_id);
    } else if (region) {
      whereConditions.push('tr.region_id = ?');
      params.push(region);
    }
    
    if (training_type) {
      whereConditions.push('tr.training_type = ?');
      params.push(training_type);
    }
    
    if (gender) {
      whereConditions.push('tr.gender = ?');
      params.push(gender);
    }
    
    if (from_date) {
      whereConditions.push('tr.training_date >= ?');
      params.push(from_date);
    }
    
    if (to_date) {
      whereConditions.push('tr.training_date <= ?');
      params.push(to_date);
    }
    
    if (search) {
      whereConditions.push('(tr.first_name LIKE ? OR tr.surname LIKE ? OR tr.id_number LIKE ?)');
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }
    
    const whereClause = whereConditions.length > 0 
      ? 'WHERE ' + whereConditions.join(' AND ') 
      : '';
    
    // Get training records
    const trainingRecords = await db.query(`
      SELECT 
        tr.*,
        r.name as region
      FROM training_register tr
      LEFT JOIN regions r ON tr.region_id = r.id
      ${whereClause}
      ORDER BY tr.training_date DESC
      LIMIT ? OFFSET ?
    `, [...params, parseInt(limit), offset]);
    
    // Get total count
    const countResult = await db.query(`
      SELECT COUNT(*) as total
      FROM training_register tr
      ${whereClause}
    `, params);
    
    const total = countResult && countResult.length > 0 ? countResult[0].total : 0;
    
    // Get training statistics
    const trainingStats = await db.query(`
      SELECT 
        COUNT(*) as total_records,
        COUNT(DISTINCT id_number) as total_individuals,
        SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) as male_count,
        SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) as female_count,
        COUNT(DISTINCT training_type) as training_types
      FROM training_register tr
      ${whereClause}
    `, params);
    
    const stats = trainingStats && trainingStats.length > 0 
      ? trainingStats[0] 
      : {
          total_records: 0,
          total_individuals: 0,
          male_count: 0,
          female_count: 0,
          training_types: 0
        };
    
    // Get training by type
    const trainingByType = await db.query(`
      SELECT 
        training_type,
        COUNT(*) as count,
        COUNT(CASE WHEN gender = 'Male' THEN 1 ELSE NULL END) as male_count,
        COUNT(CASE WHEN gender = 'Female' THEN 1 ELSE NULL END) as female_count
      FROM training_register tr
      ${whereClause}
      GROUP BY training_type
      ORDER BY count DESC
    `, params);
    
    // Get training by region
    const trainingByRegion = await db.query(`
      SELECT 
        r.name as region_name,
        COUNT(*) as count,
        COUNT(DISTINCT tr.id_number) as unique_individuals,
        ROUND((COUNT(CASE WHEN tr.gender = 'Female' THEN 1 ELSE NULL END) * 100.0 / NULLIF(COUNT(*), 0)), 1) as female_percentage
      FROM training_register tr
      LEFT JOIN regions r ON tr.region_id = r.id
      ${whereClause}
      GROUP BY r.name
      ORDER BY count DESC
    `, params);
    
    return res.status(200).json({
      success: true,
      data: {
        training_records: trainingRecords || [],
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(total / limit)
        },
        summary: {
          total_records: stats.total_records || 0,
          total_individuals: stats.total_individuals || 0,
          male_count: stats.male_count || 0,
          female_count: stats.female_count || 0,
          training_types: stats.training_types || 0,
          gender_ratio: stats.male_count > 0 
            ? parseFloat((stats.female_count / stats.male_count).toFixed(2))
            : 0
        },
        by_type: trainingByType || [],
        by_region: trainingByRegion || []
      },
      message: `Retrieved ${trainingRecords ? trainingRecords.length : 0} training records`
    });
  } catch (error) {
    logger.error(`Get training report error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/reports/financial
 * @desc    Get financial report
 * @access  Private (SUPER_USER, PS, RDFC only)
 */
router.get('/financial', authenticate, requireRole(['SUPER_USER', 'PS', 'RDFC']), async (req, res) => {
  try {
    const { region_id, year, quarter } = req.query;
    
    // Determine date range
    let fromDate, toDate;
    if (year && quarter) {
      const quarterMap = {
        '1': { start: '01-01', end: '03-31' },
        '2': { start: '04-01', end: '06-30' },
        '3': { start: '07-01', end: '09-30' },
        '4': { start: '10-01', end: '12-31' }
      };
      fromDate = `${year}-${quarterMap[quarter].start}`;
      toDate = `${year}-${quarterMap[quarter].end}`;
    } else if (year) {
      fromDate = `${year}-01-01`;
      toDate = `${year}-12-31`;
    }
    
    // Build where clause
    const whereConditions = [];
    const params = [];
    
    if (region_id) {
      whereConditions.push('e.region_id = ?');
      params.push(region_id);
    }
    
    if (fromDate) {
      whereConditions.push('a.submitted_at >= ?');
      params.push(fromDate);
    }
    
    if (toDate) {
      whereConditions.push('a.submitted_at <= ?');
      params.push(toDate);
    }
    
    whereConditions.push("a.status != 'draft'");
    
    const whereClause = whereConditions.length > 0 
      ? 'WHERE ' + whereConditions.join(' AND ') 
      : '';
    
    // Get funding by region
    const fundingByRegion = await db.query(`
      SELECT 
        r.name as region_name,
        COUNT(a.id) as application_count,
        COALESCE(SUM(a.funding_amount), 0) as requested_amount,
        COALESCE(SUM(a.approved_amount), 0) as approved_amount,
        COALESCE(SUM(a.disbursed_amount), 0) as disbursed_amount,
        ROUND((COALESCE(SUM(a.approved_amount), 0) * 100 / NULLIF(SUM(a.funding_amount), 0)), 1) as approval_rate,
        ROUND((COALESCE(SUM(a.disbursed_amount), 0) * 100 / NULLIF(SUM(a.approved_amount), 0)), 1) as disbursement_rate
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      JOIN regions r ON e.region_id = r.id
      ${whereClause}
      GROUP BY r.name
      ORDER BY approved_amount DESC
    `, params);
    
    // Get budget utilization
    const budgetUtilization = await db.query(`
      SELECT 
        COALESCE(SUM(a.approved_amount), 0) as total_budget,
        COALESCE(SUM(a.disbursed_amount), 0) as total_disbursed,
        ROUND((COALESCE(SUM(a.disbursed_amount), 0) * 100 / NULLIF(SUM(a.approved_amount), 0)), 1) as utilization_rate
      FROM applications a
      JOIN eogs e ON a.eog_id = e.id
      ${whereClause}
    `, params);
    
    const budget = budgetUtilization && budgetUtilization.length > 0 
      ? budgetUtilization[0] 
      : {
          total_budget: 0,
          total_disbursed: 0,
          utilization_rate: 0
        };
    
    return res.status(200).json({
      success: true,
      data: {
        period: {
          from: fromDate || 'All time',
          to: toDate || 'Present',
          year: year || 'All years',
          quarter: quarter || 'All quarters'
        },
        summary: {
          total_budget: parseFloat(budget.total_budget || 0),
          total_disbursed: parseFloat(budget.total_disbursed || 0),
          utilization_rate: parseFloat(budget.utilization_rate || 0)
        },
        by_region: fundingByRegion || []
      },
      message: 'Financial report generated successfully'
    });
  } catch (error) {
    logger.error(`Get financial report error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

module.exports = router;