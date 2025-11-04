const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');

// ============================================================================
// HELPER FUNCTIONS - Keep statistics logic modular and reusable
// ============================================================================

/**
 * Get EOG statistics
 */
const getEogStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as total_eogs,
      COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_eogs,
      COUNT(CASE WHEN status = 'pending_verification' THEN 1 END) as pending_eogs,
      COUNT(CASE WHEN status = 'temporary' THEN 1 END) as temporary_eogs,
      COUNT(CASE WHEN status = 'suspended' THEN 1 END) as suspended_eogs,
      COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_eogs,
      COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_eogs_last_30_days,
      COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as new_eogs_last_7_days
    FROM eogs
  `);
  
  return stats;
};

/**
 * Get application statistics
 */
const getApplicationStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as total_applications,
      COUNT(CASE WHEN status = 'draft' THEN 1 END) as draft_applications,
      COUNT(CASE WHEN status = 'submitted' THEN 1 END) as submitted_applications,
      COUNT(CASE WHEN status = 'in_review' THEN 1 END) as in_review_applications,
      COUNT(CASE WHEN status = 'returned' THEN 1 END) as returned_applications,
      COUNT(CASE WHEN status = 'recommended' THEN 1 END) as recommended_applications,
      COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_applications,
      COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_applications,
      COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_applications,
      COUNT(CASE WHEN submitted_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_applications_last_30_days,
      COUNT(CASE WHEN submitted_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as new_applications_last_7_days
    FROM applications
  `);
  
  return stats;
};

/**
 * Get application level statistics
 */
const getApplicationLevelStatistics = async () => {
  const stats = await db.query(`
    SELECT 
      current_level,
      COUNT(*) as count,
      ROUND(AVG(progress_percentage), 2) as avg_progress
    FROM applications
    WHERE status NOT IN ('draft', 'completed', 'rejected')
    GROUP BY current_level
    ORDER BY 
      FIELD(current_level, 
        'EOG_LEVEL', 
        'MINISTRY_LEVEL', 
        'MICROPROJECTS_LEVEL', 
        'CDO_LEVEL', 
        'UMPHAKATSI_LEVEL', 
        'INKHUNDLA_LEVEL', 
        'RDFTC_LEVEL', 
        'RDFC_LEVEL', 
        'PS_LEVEL', 
        'PROCUREMENT_LEVEL', 
        'IMPLEMENTATION_LEVEL'
      )
  `);
  
  return stats;
};

/**
 * Get user statistics
 */
const getUserStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as total_users,
      COUNT(CASE WHEN status = 'active' THEN 1 END) as active_users,
      COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactive_users,
      COUNT(CASE WHEN status = 'suspended' THEN 1 END) as suspended_users,
      COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as new_users_last_30_days,
      COUNT(CASE WHEN last_login >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as active_users_last_7_days
    FROM users
  `);
  
  return stats;
};

/**
 * Get user role statistics
 */
const getUserRoleStatistics = async () => {
  const stats = await db.query(`
    SELECT 
      role,
      COUNT(*) as count,
      COUNT(CASE WHEN status = 'active' THEN 1 END) as active_count
    FROM users
    GROUP BY role
    ORDER BY count DESC
  `);
  
  return stats;
};

/**
 * Get financial statistics
 */
const getFinancialStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as applications_with_funding,
      COALESCE(SUM(funding_amount), 0) as total_requested_funding,
      COALESCE(SUM(approved_amount), 0) as total_approved_funding,
      COALESCE(SUM(disbursed_amount), 0) as total_disbursed_funding,
      COALESCE(AVG(funding_amount), 0) as avg_requested_amount,
      COALESCE(AVG(approved_amount), 0) as avg_approved_amount,
      COALESCE(MAX(funding_amount), 0) as max_requested_amount,
      COALESCE(MIN(funding_amount), 0) as min_requested_amount
    FROM applications
    WHERE funding_amount IS NOT NULL
  `);
  
  return stats;
};

/**
 * Get regional statistics
 */
const getRegionalStatistics = async () => {
  const stats = await db.query(`
    SELECT 
      r.id as region_id,
      r.name as region_name,
      COUNT(DISTINCT e.id) as total_eogs,
      COUNT(DISTINCT a.id) as total_applications,
      COUNT(DISTINCT u.id) as total_users,
      COALESCE(SUM(a.funding_amount), 0) as total_funding_requested
    FROM regions r
    LEFT JOIN eogs e ON e.region_id = r.id
    LEFT JOIN applications a ON a.eog_id = e.id
    LEFT JOIN users u ON u.region_id = r.id
    GROUP BY r.id, r.name
    ORDER BY total_applications DESC
  `);
  
  return stats;
};

/**
 * Get workflow statistics
 */
const getWorkflowStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(DISTINCT application_id) as total_applications_in_workflow,
      COUNT(*) as total_workflow_actions,
      COUNT(CASE WHEN action = 'submit' THEN 1 END) as total_submissions,
      COUNT(CASE WHEN action = 'approve' THEN 1 END) as total_approvals,
      COUNT(CASE WHEN action = 'return' THEN 1 END) as total_returns,
      COUNT(CASE WHEN action = 'reject' THEN 1 END) as total_rejections,
      COUNT(CASE WHEN action = 'recommend' THEN 1 END) as total_recommendations
    FROM application_workflow
  `);
  
  return stats;
};

/**
 * Get recent activity statistics
 */
const getRecentActivityStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(CASE WHEN actioned_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR) THEN 1 END) as actions_last_24_hours,
      COUNT(CASE WHEN actioned_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END) as actions_last_7_days,
      COUNT(CASE WHEN actioned_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as actions_last_30_days
    FROM application_workflow
  `);
  
  return stats;
};

/**
 * Get training statistics
 */
const getTrainingStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as total_trained_members,
      COUNT(CASE WHEN verified_by IS NOT NULL THEN 1 END) as verified_members,
      COUNT(CASE WHEN verified_by IS NULL THEN 1 END) as pending_verification,
      COUNT(DISTINCT region_id) as regions_with_training
    FROM training_register
  `);
  
  return stats;
};

/**
 * Get comment statistics
 */
const getCommentStatistics = async () => {
  const stats = await db.getOne(`
    SELECT 
      COUNT(*) as total_comments,
      COUNT(DISTINCT application_id) as applications_with_comments,
      COUNT(CASE WHEN comment_type = 'question' THEN 1 END) as questions,
      COUNT(CASE WHEN comment_type = 'clarification_request' THEN 1 END) as clarification_requests,
      COUNT(CASE WHEN comment_type = 'feedback' THEN 1 END) as feedback_comments,
      COUNT(CASE WHEN comment_type = 'recommendation' THEN 1 END) as recommendations,
      COUNT(CASE WHEN comment_type = 'return_reason' THEN 1 END) as return_reasons
    FROM application_comments
  `);
  
  return stats;
};

// ============================================================================
// ROUTES
// ============================================================================

/**
 * @route   GET /api/statistics/overview
 * @desc    Get comprehensive system statistics overview
 * @access  Private (Authenticated users)
 */
router.get('/overview', authenticate, async (req, res) => {
  try {
    const [
      eogStats,
      applicationStats,
      userStats,
      financialStats,
      workflowStats
    ] = await Promise.all([
      getEogStatistics(),
      getApplicationStatistics(),
      getUserStatistics(),
      getFinancialStatistics(),
      getWorkflowStatistics()
    ]);

    return res.status(200).json({
      success: true,
      data: {
        eogs: eogStats,
        applications: applicationStats,
        users: userStats,
        financial: financialStats,
        workflow: workflowStats
      }
    });
  } catch (error) {
    logger.error(`Get statistics overview error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/eogs
 * @desc    Get detailed EOG statistics
 * @access  Private (Authenticated users)
 */
router.get('/eogs', authenticate, async (req, res) => {
  try {
    const eogStats = await getEogStatistics();

    return res.status(200).json({
      success: true,
      data: eogStats
    });
  } catch (error) {
    logger.error(`Get EOG statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/applications
 * @desc    Get detailed application statistics
 * @access  Private (Authenticated users)
 */
router.get('/applications', authenticate, async (req, res) => {
  try {
    const [applicationStats, levelStats] = await Promise.all([
      getApplicationStatistics(),
      getApplicationLevelStatistics()
    ]);

    return res.status(200).json({
      success: true,
      data: {
        summary: applicationStats,
        by_level: levelStats
      }
    });
  } catch (error) {
    logger.error(`Get application statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/users
 * @desc    Get detailed user statistics
 * @access  Private (Authenticated users with appropriate role)
 */
router.get('/users', 
  authenticate, 
  requireRole(['SUPER_USER', 'PS', 'MICROPROJECTS']),
  async (req, res) => {
    try {
      const [userStats, roleStats] = await Promise.all([
        getUserStatistics(),
        getUserRoleStatistics()
      ]);

      return res.status(200).json({
        success: true,
        data: {
          summary: userStats,
          by_role: roleStats
        }
      });
    } catch (error) {
      logger.error(`Get user statistics error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/statistics/financial
 * @desc    Get financial statistics
 * @access  Private (Authenticated users with appropriate role)
 */
router.get('/financial', 
  authenticate, 
  requireRole(['SUPER_USER', 'PS', 'RDFC', 'MICROPROJECTS']),
  async (req, res) => {
    try {
      const financialStats = await getFinancialStatistics();

      return res.status(200).json({
        success: true,
        data: financialStats
      });
    } catch (error) {
      logger.error(`Get financial statistics error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/statistics/regional
 * @desc    Get regional statistics
 * @access  Private (Authenticated users)
 */
router.get('/regional', authenticate, async (req, res) => {
  try {
    const regionalStats = await getRegionalStatistics();

    return res.status(200).json({
      success: true,
      data: regionalStats
    });
  } catch (error) {
    logger.error(`Get regional statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/workflow
 * @desc    Get workflow statistics
 * @access  Private (Authenticated users)
 */
router.get('/workflow', authenticate, async (req, res) => {
  try {
    const [workflowStats, activityStats] = await Promise.all([
      getWorkflowStatistics(),
      getRecentActivityStatistics()
    ]);

    return res.status(200).json({
      success: true,
      data: {
        summary: workflowStats,
        recent_activity: activityStats
      }
    });
  } catch (error) {
    logger.error(`Get workflow statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/training
 * @desc    Get training statistics
 * @access  Private (Authenticated users)
 */
router.get('/training', authenticate, async (req, res) => {
  try {
    const trainingStats = await getTrainingStatistics();

    return res.status(200).json({
      success: true,
      data: trainingStats
    });
  } catch (error) {
    logger.error(`Get training statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/comments
 * @desc    Get comment statistics
 * @access  Private (Authenticated users)
 */
router.get('/comments', authenticate, async (req, res) => {
  try {
    const commentStats = await getCommentStatistics();

    return res.status(200).json({
      success: true,
      data: commentStats
    });
  } catch (error) {
    logger.error(`Get comment statistics error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/statistics/dashboard
 * @desc    Get dashboard statistics (comprehensive view for admins)
 * @access  Private (SUPER_USER, PS only)
 */
router.get('/dashboard', 
  authenticate, 
  requireRole(['SUPER_USER', 'PS', 'MICROPROJECTS']),
  async (req, res) => {
    try {
      const [
        eogStats,
        applicationStats,
        applicationLevelStats,
        userStats,
        userRoleStats,
        financialStats,
        regionalStats,
        workflowStats,
        activityStats,
        trainingStats,
        commentStats
      ] = await Promise.all([
        getEogStatistics(),
        getApplicationStatistics(),
        getApplicationLevelStatistics(),
        getUserStatistics(),
        getUserRoleStatistics(),
        getFinancialStatistics(),
        getRegionalStatistics(),
        getWorkflowStatistics(),
        getRecentActivityStatistics(),
        getTrainingStatistics(),
        getCommentStatistics()
      ]);

      return res.status(200).json({
        success: true,
        data: {
          eogs: eogStats,
          applications: {
            summary: applicationStats,
            by_level: applicationLevelStats
          },
          users: {
            summary: userStats,
            by_role: userRoleStats
          },
          financial: financialStats,
          regional: regionalStats,
          workflow: {
            summary: workflowStats,
            recent_activity: activityStats
          },
          training: trainingStats,
          comments: commentStats
        }
      });
    } catch (error) {
      logger.error(`Get dashboard statistics error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;
