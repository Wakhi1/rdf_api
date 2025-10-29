const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, schemas } = require('../middleware/validation.middleware');
const { sendEmail } = require('../utils/email');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(
      process.env.UPLOAD_DIR || './uploads', 
      'procurement_documents', 
      req.params.applicationId || 'temp'
    );
    
    fs.mkdirSync(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: process.env.MAX_FILE_SIZE ? parseInt(process.env.MAX_FILE_SIZE) : 10 * 1024 * 1024
  },
  fileFilter: function (req, file, cb) {
    const filetypes = /jpeg|jpg|png|pdf|doc|docx|xls|xlsx|ppt|pptx|txt|csv/;
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = filetypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Only document files are allowed'));
    }
  }
});

/**
 * @route   GET /api/microprojects/applications
 * @desc    Get all applications at procurement level
 * @access  Private (MICROPROJECTS role)
 */
router.get('/applications', 
  authenticate, 
  requireRole(['MICROPROJECTS', 'SUPER_USER']), 
  async (req, res) => {
    try {
      const { status, region, tinkhundla, search } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      
      // Build query
      let query = `
        SELECT 
          a.id, 
          a.reference_number, 
          a.current_level,
          a.status,
          a.progress_percentage,
          a.funding_amount,
          a.approved_amount,
          a.disbursed_amount,
          a.submitted_at,
          e.company_name as eog_name,
          r.name as region,
          t.name as tinkhundla
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        JOIN regions r ON e.region_id = r.id
        JOIN tinkhundla t ON e.tinkhundla_id = t.id
        WHERE a.current_level = 'PROCUREMENT_LEVEL'
      `;
      
      const whereParams = [];
      
      // Add filters
      if (status) {
        query += ` AND a.status = ?`;
        whereParams.push(status);
      }
      
      if (region) {
        query += ` AND e.region_id = ?`;
        whereParams.push(region);
      }
      
      if (tinkhundla) {
        query += ` AND e.tinkhundla_id = ?`;
        whereParams.push(tinkhundla);
      }
      
      if (search) {
        query += ` AND (a.reference_number LIKE ? OR e.company_name LIKE ?)`;
        const searchTerm = `%${search}%`;
        whereParams.push(searchTerm, searchTerm);
      }
      
      // Get total count
      const countQuery = `SELECT COUNT(*) as total FROM (${query}) as count_query`;
      const countResult = await db.query(countQuery, whereParams);
      const totalCount = countResult[0].total;
      
      // Add sorting and pagination
      query += ` ORDER BY a.submitted_at DESC`;
      query += ` LIMIT ? OFFSET ?`;
      whereParams.push(limit, offset);
      
      // Execute query
      const applications = await db.query(query, whereParams);
      
      return res.status(200).json({
        success: true,
        data: {
          applications,
          pagination: {
            total: totalCount,
            page,
            limit,
            pages: Math.ceil(totalCount / limit)
          }
        }
      });
    } catch (error) {
      logger.error(`Get procurement applications error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/microprojects/implementations
 * @desc    Get applications at implementation level
 * @access  Private (MICROPROJECTS role)
 */
router.get('/implementations', 
  authenticate, 
  requireRole(['MICROPROJECTS']), 
  async (req, res) => {
    try {
      const { status, region, tinkhundla, search } = req.query;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const offset = (page - 1) * limit;
      
      // Build query
      let query = `
        SELECT 
          a.id, 
          a.reference_number, 
          a.current_level,
          a.status,
          a.progress_percentage,
          a.funding_amount,
          a.approved_amount,
          a.disbursed_amount,
          a.submitted_at,
          e.company_name as eog_name,
          r.name as region,
          t.name as tinkhundla,
          (SELECT COUNT(*) FROM project_milestones WHERE application_id = a.id) as total_milestones,
          (SELECT COUNT(*) FROM project_milestones WHERE application_id = a.id AND status = 'completed') as completed_milestones,
          (SELECT COUNT(*) FROM site_visits WHERE application_id = a.id) as site_visits,
          (SELECT ROUND(AVG(rating), 1) FROM beneficiary_feedback WHERE application_id = a.id) as avg_feedback_rating
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        JOIN regions r ON e.region_id = r.id
        JOIN tinkhundla t ON e.tinkhundla_id = t.id
        WHERE a.current_level = 'IMPLEMENTATION_LEVEL'
      `;
      
      const whereParams = [];
      
      // Add filters
      if (status) {
        query += ` AND a.status = ?`;
        whereParams.push(status);
      }
      
      if (region) {
        query += ` AND e.region_id = ?`;
        whereParams.push(region);
      }
      
      if (tinkhundla) {
        query += ` AND e.tinkhundla_id = ?`;
        whereParams.push(tinkhundla);
      }
      
      if (search) {
        query += ` AND (a.reference_number LIKE ? OR e.company_name LIKE ?)`;
        const searchTerm = `%${search}%`;
        whereParams.push(searchTerm, searchTerm);
      }
      
      // Get total count
      const countQuery = `SELECT COUNT(*) as total FROM (${query}) as count_query`;
      const countResult = await db.query(countQuery, whereParams);
      const totalCount = countResult[0].total;
      
      // Add sorting and pagination
      query += ` ORDER BY a.progress_percentage DESC, a.submitted_at DESC`;
      query += ` LIMIT ? OFFSET ?`;
      whereParams.push(limit, offset);
      
      // Execute query
      const applications = await db.query(query, whereParams);
      
      return res.status(200).json({
        success: true,
        data: {
          applications,
          pagination: {
            total: totalCount,
            page,
            limit,
            pages: Math.ceil(totalCount / limit)
          }
        }
      });
    } catch (error) {
      logger.error(`Get implementation applications error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/microprojects/applications/:applicationId
 * @desc    Get application details
 * @access  Private (MICROPROJECTS role)
 */
router.get('/applications/:applicationId', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      
      // Get application details
      const application = await db.getOne(`
        SELECT 
          a.*,
          e.company_name as eog_name,
          e.company_type,
          e.email as eog_email,
          e.phone as eog_phone,
          r.name as region,
          t.name as tinkhundla,
          i.name as umphakatsi,
          i.chief_name
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        JOIN regions r ON e.region_id = r.id
        JOIN tinkhundla t ON e.tinkhundla_id = t.id
        JOIN imiphakatsi i ON e.umphakatsi_id = i.id
        WHERE a.id = ?
      `, [applicationId]);
      
      if (!application) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Application not found'
        });
      }
      
      // Get milestones
      const milestones = await db.query(`
        SELECT * FROM project_milestones
        WHERE application_id = ?
        ORDER BY target_date ASC
      `, [applicationId]);
      
      // Get site visits
      const siteVisits = await db.query(`
        SELECT 
          sv.*,
          u.first_name as visitor_first_name,
          u.last_name as visitor_last_name
        FROM site_visits sv
        JOIN users u ON sv.visitor_user_id = u.id
        WHERE sv.application_id = ?
        ORDER BY sv.visit_date DESC
      `, [applicationId]);
      
      // Get feedback
      const feedback = await db.query(`
        SELECT * FROM beneficiary_feedback
        WHERE application_id = ?
        ORDER BY submitted_at DESC
      `, [applicationId]);
      
      // Get impact assessment
      const impactAssessments = await db.query(`
        SELECT 
          ia.*,
          u.first_name as assessor_first_name,
          u.last_name as assessor_last_name
        FROM impact_assessments ia
        JOIN users u ON ia.assessor_user_id = u.id
        WHERE ia.application_id = ?
      `, [applicationId]);
      
      return res.status(200).json({
        success: true,
        data: {
          application,
          milestones,
          site_visits: siteVisits,
          feedback,
          impact_assessments: impactAssessments
        }
      });
    } catch (error) {
      logger.error(`Get application details error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/microprojects/applications/:applicationId/milestones
 * @desc    Create milestone
 * @access  Private (MICROPROJECTS role)
 */
router.post('/applications/:applicationId/milestones', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      const { milestone_name, description, target_date, budget_allocated } = req.body;
      
      // Validate required fields
      if (!milestone_name || !target_date) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Milestone name and target date are required'
        });
      }
      
      // Verify application exists
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
      
      // Create milestone
      const result = await db.insert('project_milestones', {
        application_id: applicationId,
        milestone_name,
        description: description || null,
        target_date,
        budget_allocated: budget_allocated || null,
        status: 'pending'
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'milestone_created',
        'project_milestones',
        result.id,
        { application_id: applicationId, milestone_name },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created milestone
      const milestone = await db.getOne(
        'SELECT * FROM project_milestones WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Milestone created successfully',
        data: milestone
      });
    } catch (error) {
      logger.error(`Create milestone error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/microprojects/milestones/:milestoneId
 * @desc    Update milestone
 * @access  Private (MICROPROJECTS role)
 */
router.put('/milestones/:milestoneId', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { milestoneId } = req.params;
      const { status, completion_date, budget_utilized, description } = req.body;
      
      // Verify milestone exists
      const milestone = await db.getOne(
        'SELECT * FROM project_milestones WHERE id = ?',
        [milestoneId]
      );
      
      if (!milestone) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Milestone not found'
        });
      }
      
      // Build update data
      const updateData = {};
      if (status) updateData.status = status;
      if (completion_date) updateData.completion_date = completion_date;
      if (budget_utilized !== undefined) updateData.budget_utilized = budget_utilized;
      if (description) updateData.description = description;
      
      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'No fields to update'
        });
      }
      
      // Update milestone
      await db.update('project_milestones', updateData, 'id = ?', [milestoneId]);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'milestone_updated',
        'project_milestones',
        milestoneId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated milestone
      const updatedMilestone = await db.getOne(
        'SELECT * FROM project_milestones WHERE id = ?',
        [milestoneId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Milestone updated successfully',
        data: updatedMilestone
      });
    } catch (error) {
      logger.error(`Update milestone error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/microprojects/applications/:applicationId/site-visits
 * @desc    Record site visit
 * @access  Private (MICROPROJECTS role)
 */
router.post('/applications/:applicationId/site-visits', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      const { visit_date, purpose, findings, recommendations } = req.body;
      
      // Validate required fields
      if (!visit_date || !purpose) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Visit date and purpose are required'
        });
      }
      
      // Verify application exists
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
      
      // Create site visit
      const result = await db.insert('site_visits', {
        application_id: applicationId,
        visitor_user_id: req.user.id,
        visit_date,
        purpose,
        findings: findings || null,
        recommendations: recommendations || null,
        status: 'completed'
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'site_visit_recorded',
        'site_visits',
        result.id,
        { application_id: applicationId, visit_date },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created site visit
      const siteVisit = await db.getOne(
        'SELECT * FROM site_visits WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Site visit recorded successfully',
        data: siteVisit
      });
    } catch (error) {
      logger.error(`Record site visit error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/microprojects/applications/:applicationId/feedback
 * @desc    Record beneficiary feedback
 * @access  Private (MICROPROJECTS role)
 */
router.post('/applications/:applicationId/feedback', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      const { feedback_type, feedback_text, rating, submitted_by } = req.body;
      
      // Validate required fields
      if (!feedback_type || !feedback_text) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Feedback type and text are required'
        });
      }
      
      // Validate feedback type
      const validTypes = ['survey', 'interview', 'complaint', 'suggestion'];
      if (!validTypes.includes(feedback_type)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Feedback type must be one of: ${validTypes.join(', ')}`
        });
      }
      
      // Validate rating if provided
      if (rating && (rating < 1 || rating > 5)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Rating must be between 1 and 5'
        });
      }
      
      // Verify application exists
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
      
      // Create feedback
      const result = await db.insert('beneficiary_feedback', {
        application_id: applicationId,
        feedback_type,
        feedback_text,
        rating: rating || null,
        submitted_by: submitted_by || null
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'feedback_recorded',
        'beneficiary_feedback',
        result.id,
        { application_id: applicationId, feedback_type },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created feedback
      const feedback = await db.getOne(
        'SELECT * FROM beneficiary_feedback WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Feedback recorded successfully',
        data: feedback
      });
    } catch (error) {
      logger.error(`Record feedback error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/microprojects/applications/:applicationId/impact-assessment
 * @desc    Create impact assessment
 * @access  Private (MICROPROJECTS role)
 */
router.post('/applications/:applicationId/impact-assessment', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      const { 
        assessment_date,
        jobs_created, 
        beneficiaries_reached, 
        economic_impact, 
        social_impact_score,
        environmental_impact_score,
        assessment_report
      } = req.body;
      
      // Validate required fields
      if (!assessment_date || !assessment_report) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Assessment date and report are required'
        });
      }
      
      // Verify application exists
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
      
      // Check if assessment already exists
      const existing = await db.getOne(
        'SELECT id FROM impact_assessments WHERE application_id = ?',
        [applicationId]
      );
      
      if (existing) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Impact assessment already exists for this application'
        });
      }
      
      // Create impact assessment
      const result = await db.insert('impact_assessments', {
        application_id: applicationId,
        assessment_date,
        assessor_user_id: req.user.id,
        jobs_created: jobs_created || 0,
        beneficiaries_reached: beneficiaries_reached || 0,
        economic_impact: economic_impact || null,
        social_impact_score: social_impact_score || null,
        environmental_impact_score: environmental_impact_score || null,
        assessment_report
      });
      
      // Update application status to completed
      await db.update('applications', 
        { 
          progress_percentage: 100.00,
          status: 'completed',
          completed_at: new Date()
        },
        'id = ? AND status != ?',
        [applicationId, 'completed']
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'impact_assessment_created',
        'impact_assessments',
        result.id,
        { application_id: applicationId },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created assessment
      const assessment = await db.getOne(
        'SELECT * FROM impact_assessments WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Impact assessment created successfully',
        data: assessment
      });
    } catch (error) {
      logger.error(`Create impact assessment error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/microprojects/statistics
 * @desc    Get microprojects statistics
 * @access  Private (MICROPROJECTS role)
 */
router.get('/statistics', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  async (req, res) => {
    try {
      const { region_id, tinkhundla_id } = req.query;
      
      // Build where clause
      let whereClause = 'WHERE 1=1';
      const params = [];
      
      if (region_id) {
        whereClause += ' AND e.region_id = ?';
        params.push(region_id);
      }
      
      if (tinkhundla_id) {
        whereClause += ' AND e.tinkhundla_id = ?';
        params.push(tinkhundla_id);
      }
      
      // Get procurement statistics
      const procurementStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_at_procurement,
          SUM(approved_amount) as total_approved_funding
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        ${whereClause}
        AND a.current_level = 'PROCUREMENT_LEVEL'
      `, params);
      
      // Get implementation statistics
      const implementationStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_at_implementation,
          COUNT(CASE WHEN a.status = 'completed' THEN 1 END) as completed_projects,
          AVG(a.progress_percentage) as avg_progress,
          SUM(a.disbursed_amount) as total_disbursed
        FROM applications a
        JOIN eogs e ON a.eog_id = e.id
        ${whereClause}
        AND a.current_level = 'IMPLEMENTATION_LEVEL'
      `, params);
      
      // Get milestone statistics
      const milestoneStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_milestones,
          COUNT(CASE WHEN pm.status = 'completed' THEN 1 END) as completed_milestones,
          COUNT(CASE WHEN pm.status = 'delayed' THEN 1 END) as delayed_milestones
        FROM project_milestones pm
        JOIN applications a ON pm.application_id = a.id
        JOIN eogs e ON a.eog_id = e.id
        ${whereClause}
      `, params);
      
      // Get feedback statistics
      const feedbackStats = await db.getOne(`
        SELECT 
          COUNT(*) as total_feedback,
          AVG(bf.rating) as avg_rating
        FROM beneficiary_feedback bf
        JOIN applications a ON bf.application_id = a.id
        JOIN eogs e ON a.eog_id = e.id
        ${whereClause}
      `, params);
      
      return res.status(200).json({
        success: true,
        data: {
          procurement: procurementStats || { total_at_procurement: 0, total_approved_funding: 0 },
          implementation: implementationStats || { total_at_implementation: 0, completed_projects: 0, avg_progress: 0, total_disbursed: 0 },
          milestones: milestoneStats || { total_milestones: 0, completed_milestones: 0, delayed_milestones: 0 },
          feedback: feedbackStats || { total_feedback: 0, avg_rating: 0 }
        }
      });
    } catch (error) {
      logger.error(`Get microprojects statistics error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/microprojects/applications/:applicationId/progress
 * @desc    Update application progress
 * @access  Private (MICROPROJECTS role)
 */
router.put('/applications/:applicationId/progress', 
  authenticate, 
  requireRole(['MICROPROJECTS']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const { applicationId } = req.params;
      const { progress_percentage, status } = req.body;
      
      // Validate progress percentage
      if (progress_percentage !== undefined && (progress_percentage < 0 || progress_percentage > 100)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Progress percentage must be between 0 and 100'
        });
      }
      
      // Verify application exists
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
      
      // Build update data
      const updateData = {};
      if (progress_percentage !== undefined) updateData.progress_percentage = progress_percentage;
      if (status) updateData.status = status;
      
      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'No fields to update'
        });
      }
      
      // Update application
      await db.update('applications', updateData, 'id = ?', [applicationId]);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_progress_updated',
        'applications',
        applicationId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated application
      const updatedApplication = await db.getOne(
        'SELECT * FROM applications WHERE id = ?',
        [applicationId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Application progress updated successfully',
        data: updatedApplication
      });
    } catch (error) {
      logger.error(`Update application progress error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;