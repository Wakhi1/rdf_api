const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const db = require('../utils/db');
const logger = require('../utils/logger');
const emailUtils = require('../utils/email');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole, requireEOGOwnership, requireApplicationAccess } = require('../middleware/role.middleware');
const { validateParams, validateBody, schemas } = require('../middleware/validation.middleware');
const config = require('../config/config');

// ============================================
// MULTER CONFIGURATION FOR FILE UPLOADS
// ============================================

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const applicationId = req.params.applicationId || 'temp';
    const dir = path.join(config.upload.dir, 'application_attachments', applicationId);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const filename = file.fieldname + '-' + uniqueSuffix + ext;
    cb(null, filename);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'image/jpeg',
    'image/png',
    'image/gif',
    'text/plain',
    'application/zip'
  ];
  
  if (!allowedTypes.includes(file.mimetype)) {
    return cb(new Error('File type not allowed'), false);
  }
  
  cb(null, true);
};

const limits = {
  fileSize: config.upload.maxFileSize
};

const upload = multer({ storage, fileFilter, limits });

// ============================================
// CONSTANTS
// ============================================

const WORKFLOW_LEVELS = [
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
];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Check if user has access to an application
 */
async function checkApplicationAccess(user, application) {
  if (user.role === 'SUPER_USER') {
    return true;
  }
  
  if (user.role === 'EOG') {
    const eog = await db.getOne(
      'SELECT eog_id FROM eog_users WHERE user_id = ?',
      [user.id]
    );
    
    return eog && eog.eog_id === application.eog_id;
  }
  
  if (user.role === 'CDO') {
    if (!user.region_id) {
      return false;
    }
    
    const eog = await db.getOne(
      'SELECT region_id FROM eogs WHERE id = ?',
      [application.eog_id]
    );
    
    return eog && eog.region_id === user.region_id;
  }
  
  const roleToLevel = {
    'LINE_MINISTRY': 'MINISTRY_LEVEL',
    'MICROPROJECTS': 'MICROPROJECTS_LEVEL',
    'CDC': 'UMPHAKATSI_LEVEL',
    'INKHUNDLA_COUNCIL': 'INKHUNDLA_LEVEL',
    'RDFTC': 'RDFTC_LEVEL',
    'RDFC': 'RDFC_LEVEL',
    'PS': 'PS_LEVEL'
  };
  
  if (user.role === 'CDC' && user.umphakatsi_id) {
    if (application.current_level !== 'UMPHAKATSI_LEVEL') {
      return false;
    }
    
    const eog = await db.getOne(
      'SELECT umphakatsi_id FROM eogs WHERE id = ?',
      [application.eog_id]
    );
    
    return eog && eog.umphakatsi_id === user.umphakatsi_id;
  } else if (user.role === 'INKHUNDLA_COUNCIL' && user.tinkhundla_id) {
    if (application.current_level !== 'INKHUNDLA_LEVEL') {
      return false;
    }
    
    const eog = await db.getOne(
      'SELECT tinkhundla_id FROM eogs WHERE id = ?',
      [application.eog_id]
    );
    
    return eog && eog.tinkhundla_id === user.tinkhundla_id;
  } else {
    return roleToLevel[user.role] === application.current_level;
  }
}

/**
 * Check if user can edit a specific question
 */
function canUserEditQuestion(user, question) {
  if (user.role === 'SUPER_USER') {
    return true;
  }
  
  if (!question.editable_by_roles) {
    return false;
  }
  
  const editableRoles = question.editable_by_roles.split(',').map(r => r.trim());
  return editableRoles.includes(user.role);
}

/**
 * Check if user can view a specific question
 */
function canUserViewQuestion(user, question) {
  if (user.role === 'SUPER_USER') {
    return true;
  }
  
  if (!question.visible_to_roles) {
    return false;
  }
  
  const visibleRoles = question.visible_to_roles.split(',').map(r => r.trim());
  return visibleRoles.includes(user.role);
}

/**
 * Get all questions user has permission to edit for an application
 */
async function getUserEditableQuestions(userId, applicationId) {
  const user = await db.getOne('SELECT * FROM users WHERE id = ?', [userId]);
  
  const application = await db.getOne('SELECT * FROM applications WHERE id = ?', [applicationId]);
  
  if (!application) {
    return [];
  }
  
  const questions = await db.query(
    `SELECT fq.* 
     FROM form_questions fq
     JOIN form_sections fs ON fs.id = fq.section_id
     WHERE fs.form_id = ?`,
    [application.form_id]
  );
  
  return questions.filter(q => canUserEditQuestion(user, q));
}

/**
 * Check if all required editable questions are answered
 */
async function areAllRequiredQuestionsAnswered(userId, applicationId) {
  const editableQuestions = await getUserEditableQuestions(userId, applicationId);
  
  const requiredQuestions = editableQuestions.filter(q => q.is_required);
  
  if (requiredQuestions.length === 0) {
    return true;
  }
  
  for (const question of requiredQuestions) {
    const response = await db.getOne(
      `SELECT * FROM form_responses 
       WHERE application_id = ? AND question_id = ?`,
      [applicationId, question.id]
    );
    
    // Check if response exists and has valid data
    if (!response) {
      return false;
    }
    
    // Check based on question type
    const hasValidAnswer = response.answer_text || 
                          response.answer_number !== null || 
                          response.answer_date || 
                          response.answer_file_path;
    
    if (!hasValidAnswer) {
      return false;
    }
  }
  
  return true;
}

// ============================================
// APPLICATION ROUTES
// ============================================

/**
 * @route   GET /api/applications
 * @desc    Get applications list with filtering and pagination
 * @access  Private
 */
router.get('/',
  authenticate,
  async (req, res) => {
    try {
      const {
        page = 1,
        limit = 10,
        status,
        sort_by = 'created_at',
        sort_order = 'desc',
        region_id,
        tinkhundla_id,
        search,
        current_level
      } = req.query;

      let baseQuery = `
        SELECT 
          a.*,
          e.company_name as eog_name,
          e.region_id,
          e.tinkhundla_id,
          e.umphakatsi_id,
          r.name as region_name,
          t.name as tinkhundla_name,
          i.name as umphakatsi_name,
          f.name as form_name
        FROM applications a
        JOIN eogs e ON e.id = a.eog_id
        LEFT JOIN regions r ON r.id = e.region_id
        LEFT JOIN tinkhundla t ON t.id = e.tinkhundla_id
        LEFT JOIN imiphakatsi i ON i.id = e.umphakatsi_id
        LEFT JOIN forms f ON f.id = a.form_id
        WHERE 1=1
      `;

      let countQuery = `
        SELECT COUNT(*) as total
        FROM applications a
        JOIN eogs e ON e.id = a.eog_id
        WHERE 1=1
      `;

      const queryParams = [];
      const countParams = [];

      // Role-based filtering
      if (req.user.role === 'EOG') {
        const eog = await db.getOne(
          'SELECT eog_id FROM eog_users WHERE user_id = ?',
          [req.user.id]
        );
        
        if (eog) {
          baseQuery += ' AND a.eog_id = ?';
          countQuery += ' AND a.eog_id = ?';
          queryParams.push(eog.eog_id);
          countParams.push(eog.eog_id);
        } else {
          return res.status(200).json({
            success: true,
            data: [],
            pagination: {
              page: parseInt(page),
              limit: parseInt(limit),
              total: 0,
              totalPages: 0
            }
          });
        }
      } else if (req.user.role === 'CDO' && req.user.region_id) {
        baseQuery += ' AND e.region_id = ?';
        countQuery += ' AND e.region_id = ?';
        queryParams.push(req.user.region_id);
        countParams.push(req.user.region_id);
      } else if (req.user.role === 'CDC' && req.user.umphakatsi_id) {
        baseQuery += ' AND e.umphakatsi_id = ?';
        countQuery += ' AND e.umphakatsi_id = ?';
        queryParams.push(req.user.umphakatsi_id);
        countParams.push(req.user.umphakatsi_id);
      } else if (req.user.role === 'INKHUNDLA_COUNCIL' && req.user.tinkhundla_id) {
        baseQuery += ' AND e.tinkhundla_id = ?';
        countQuery += ' AND e.tinkhundla_id = ?';
        queryParams.push(req.user.tinkhundla_id);
        countParams.push(req.user.tinkhundla_id);
      }

      // Add filters
      if (status) {
        baseQuery += ' AND a.status = ?';
        countQuery += ' AND a.status = ?';
        queryParams.push(status);
        countParams.push(status);
      }

      if (current_level) {
        baseQuery += ' AND a.current_level = ?';
        countQuery += ' AND a.current_level = ?';
        queryParams.push(current_level);
        countParams.push(current_level);
      }

      if (region_id) {
        baseQuery += ' AND e.region_id = ?';
        countQuery += ' AND e.region_id = ?';
        queryParams.push(region_id);
        countParams.push(region_id);
      }

      if (tinkhundla_id) {
        baseQuery += ' AND e.tinkhundla_id = ?';
        countQuery += ' AND e.tinkhundla_id = ?';
        queryParams.push(tinkhundla_id);
        countParams.push(tinkhundla_id);
      }

      if (search) {
        baseQuery += ' AND (a.reference_number LIKE ? OR e.company_name LIKE ? OR a.title LIKE ?)';
        countQuery += ' AND (a.reference_number LIKE ? OR e.company_name LIKE ? OR a.title LIKE ?)';
        const searchTerm = `%${search}%`;
        queryParams.push(searchTerm, searchTerm, searchTerm);
        countParams.push(searchTerm, searchTerm, searchTerm);
      }

      // Add sorting
      const validSortColumns = ['created_at', 'updated_at', 'submitted_at', 'reference_number', 'status', 'current_level'];
      const validSortOrders = ['asc', 'desc'];

      const sortColumn = validSortColumns.includes(sort_by) ? sort_by : 'created_at';
      const sortOrder = validSortOrders.includes(sort_order) ? sort_order : 'desc';

      baseQuery += ` ORDER BY a.${sortColumn} ${sortOrder}`;

      // Add pagination
      const offset = (page - 1) * limit;
      baseQuery += ' LIMIT ? OFFSET ?';
      queryParams.push(parseInt(limit), offset);

      // Get applications
      const applications = await db.query(baseQuery, queryParams);

      // Get total count
      const countResult = await db.getOne(countQuery, countParams);
      const total = countResult.total;
      const totalPages = Math.ceil(total / limit);

      return res.status(200).json({
        success: true,
        data: applications,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          totalPages
        }
      });
    } catch (error) {
      logger.error(`Get applications list error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/applications/:applicationId
 * @desc    Get application by ID with responses
 * @access  Private
 */
router.get('/:applicationId',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      
      const application = await db.getOne(
        `SELECT a.*, e.company_name as eog_name, e.status as eog_status,
         r.name as region, r.id as region_id, 
         t.name as tinkhundla, t.id as tinkhundla_id,
         i.name as umphakatsi, i.id as umphakatsi_id,
         f.name as form_name, f.id as form_id
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         JOIN regions r ON r.id = e.region_id
         JOIN tinkhundla t ON t.id = e.tinkhundla_id
         JOIN imiphakatsi i ON i.id = e.umphakatsi_id
         LEFT JOIN forms f ON f.id = a.form_id
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
      
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get responses
      const responses = await db.query(
        `SELECT fr.id, fr.application_id, fr.question_id, fr.answer_text, 
         fr.answer_number, fr.answer_date, fr.answer_file_path,
         fr.answered_by, fr.answered_at, fr.updated_at,
         u.username as answered_by_username, u.first_name, u.last_name
         FROM form_responses fr
         LEFT JOIN users u ON u.id = fr.answered_by
         WHERE fr.application_id = ?`,
        [applicationId]
      );
      
      // Get attachments
      const attachments = await db.query(
        `SELECT * FROM application_attachments WHERE application_id = ?`,
        [applicationId]
      );
      
      // Get comments
      const comments = await db.query(
        `SELECT ac.*, u.username, u.first_name, u.last_name, u.role
         FROM application_comments ac
         JOIN users u ON u.id = ac.user_id
         WHERE ac.application_id = ?
         ORDER BY ac.created_at ASC`,
        [applicationId]
      );
      
      // Get workflow history
      const workflow = await db.query(
        `SELECT aw.*, u.username, u.first_name, u.last_name, u.role
         FROM application_workflow aw
         JOIN users u ON u.id = aw.actioned_by
         WHERE aw.application_id = ?
         ORDER BY aw.actioned_at DESC`,
        [applicationId]
      );
      
      return res.status(200).json({
        success: true,
        data: {
          ...application,
          responses,
          attachments,
          comments,
          workflow
        }
      });
    } catch (error) {
      logger.error(`Get application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/applications
 * @desc    Create new application
 * @access  Private (EOG only)
 */
router.post('/',
  authenticate,
  requireRole('EOG'),
  async (req, res) => {
    try {
      const { form_id } = req.body;
      
      if (!form_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'form_id is required'
        });
      }
      
      // Get EOG
      const eog = await db.getOne(
        'SELECT eog_id FROM eog_users WHERE user_id = ?',
        [req.user.id]
      );
      
      if (!eog) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'No EOG associated with this user'
        });
      }
      
      // Verify form exists and is active
      const form = await db.getOne(
        'SELECT * FROM forms WHERE id = ? AND is_active = 1',
        [form_id]
      );
      
      if (!form) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Form not found or inactive'
        });
      }
      
      // Generate reference number
      const year = new Date().getFullYear();
      const count = await db.getOne(
        'SELECT COUNT(*) as count FROM applications WHERE YEAR(created_at) = ?',
        [year]
      );
      
      const referenceNumber = `RDF-${year}-${String(count.count + 1).padStart(6, '0')}`;
      
      // Create application
      const result = await db.insert('applications', {
        eog_id: eog.eog_id,
        form_id: form_id,
        reference_number: referenceNumber,
        current_level: 'EOG_LEVEL',
        status: 'draft',
        progress_percentage: 0.00
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_created',
        'applications',
        result.id,
        { reference_number: referenceNumber, form_id },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created application
      const application = await db.getOne(
        `SELECT a.*, e.company_name as eog_name, f.name as form_name
         FROM applications a
         JOIN eogs e ON e.id = a.eog_id
         JOIN forms f ON f.id = a.form_id
         WHERE a.id = ?`,
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Application created successfully',
        data: application
      });
    } catch (error) {
      logger.error(`Create application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// RESPONSE MANAGEMENT ROUTES
// ============================================

/**
 * @route   POST /api/applications/:applicationId/responses
 * @desc    Save or update response to a question (auto-save)
 * @access  Private
 */
router.post('/:applicationId/responses',
  authenticate,
  upload.single('file'),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { question_id, answer_text, answer_number, answer_date } = req.body;
      
      if (!question_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'question_id is required'
        });
      }
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get question
      const question = await db.getOne(
        `SELECT fq.* FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ? AND fs.form_id = ?`,
        [question_id, application.form_id]
      );
      
      if (!question) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Question not found in this form'
        });
      }
      
      // Check if user can edit this question
      if (!canUserEditQuestion(req.user, question)) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have permission to edit this question'
        });
      }
      
      // Prepare response data
      const responseData = {
        application_id: applicationId,
        question_id: question_id,
        answered_by: req.user.id
      };
      
      // Handle different answer types
      if (question.question_type === 'FILE' && req.file) {
        responseData.answer_file_path = req.file.path;
      } else if (['NUMBER', 'DECIMAL'].includes(question.question_type)) {
        responseData.answer_number = answer_number || null;
      } else if (question.question_type === 'DATE') {
        responseData.answer_date = answer_date || null;
      } else {
        responseData.answer_text = answer_text || null;
      }
      
      // Check if response already exists
      const existingResponse = await db.getOne(
        'SELECT * FROM form_responses WHERE application_id = ? AND question_id = ?',
        [applicationId, question_id]
      );
      
      let responseId;
      
      if (existingResponse) {
        // Update existing response
        await db.update(
          'form_responses',
          responseData,
          'application_id = ? AND question_id = ?',
          [applicationId, question_id]
        );
        responseId = existingResponse.id;
      } else {
        // Create new response
        const result = await db.insert('form_responses', responseData);
        responseId = result.id;
      }
      
      // Calculate progress percentage
      const totalQuestions = await getUserEditableQuestions(req.user.id, applicationId);
      const answeredQuestions = await db.query(
        `SELECT DISTINCT question_id FROM form_responses WHERE application_id = ?`,
        [applicationId]
      );
      
      const progressPercentage = totalQuestions.length > 0 
        ? (answeredQuestions.length / totalQuestions.length) * 100 
        : 0;
      
      // Update application progress
      await db.update(
        'applications',
        { progress_percentage: progressPercentage.toFixed(2) },
        'id = ?',
        [applicationId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        existingResponse ? 'response_updated' : 'response_saved',
        'form_responses',
        responseId,
        { question_id, application_id: applicationId },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get saved response
      const savedResponse = await db.getOne(
        `SELECT fr.*, fq.question_text, fq.question_type
         FROM form_responses fr
         JOIN form_questions fq ON fq.id = fr.question_id
         WHERE fr.id = ?`,
        [responseId]
      );
      
      return res.status(200).json({
        success: true,
        message: existingResponse ? 'Response updated successfully' : 'Response saved successfully',
        data: savedResponse
      });
    } catch (error) {
      logger.error(`Save response error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/applications/:applicationId/responses/:questionId
 * @desc    Get response for a specific question
 * @access  Private
 */
router.get('/:applicationId/responses/:questionId',
  authenticate,
  async (req, res) => {
    try {
      const { applicationId, questionId } = req.params;
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get response
      const response = await db.getOne(
        `SELECT fr.*, fq.question_text, fq.question_type,
         u.username as answered_by_username, u.first_name, u.last_name
         FROM form_responses fr
         JOIN form_questions fq ON fq.id = fr.question_id
         LEFT JOIN users u ON u.id = fr.answered_by
         WHERE fr.application_id = ? AND fr.question_id = ?`,
        [applicationId, questionId]
      );
      
      if (!response) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Response not found'
        });
      }
      
      return res.status(200).json({
        success: true,
        data: response
      });
    } catch (error) {
      logger.error(`Get response error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/applications/:applicationId/responses/:questionId
 * @desc    Delete response for a specific question
 * @access  Private
 */
router.delete('/:applicationId/responses/:questionId',
  authenticate,
  async (req, res) => {
    try {
      const { applicationId, questionId } = req.params;
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get question
      const question = await db.getOne(
        `SELECT fq.* FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ? AND fs.form_id = ?`,
        [questionId, application.form_id]
      );
      
      if (!question) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Question not found'
        });
      }
      
      // Check if user can edit this question
      if (!canUserEditQuestion(req.user, question)) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have permission to edit this question'
        });
      }
      
      // Get response
      const response = await db.getOne(
        'SELECT * FROM form_responses WHERE application_id = ? AND question_id = ?',
        [applicationId, questionId]
      );
      
      if (!response) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Response not found'
        });
      }
      
      // Delete file if exists
      if (response.answer_file_path) {
        try {
          const filePath = path.join(process.cwd(), response.answer_file_path);
          if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
          }
        } catch (err) {
          logger.warn(`Failed to delete response file: ${err.message}`);
        }
      }
      
      // Delete response
      await db.delete(
        'form_responses',
        'application_id = ? AND question_id = ?',
        [applicationId, questionId]
      );
      
      // Update progress
      const totalQuestions = await getUserEditableQuestions(req.user.id, applicationId);
      const answeredQuestions = await db.query(
        `SELECT DISTINCT question_id FROM form_responses WHERE application_id = ?`,
        [applicationId]
      );
      
      const progressPercentage = totalQuestions.length > 0 
        ? (answeredQuestions.length / totalQuestions.length) * 100 
        : 0;
      
      await db.update(
        'applications',
        { progress_percentage: progressPercentage.toFixed(2) },
        'id = ?',
        [applicationId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'response_deleted',
        'form_responses',
        response.id,
        { question_id: questionId, application_id: applicationId },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Response deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete response error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/applications/:applicationId/submit
 * @desc    Submit application (EOG submits after answering all required questions)
 * @access  Private (EOG only)
 */
router.post('/:applicationId/submit',
  authenticate,
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Check if already submitted
      if (application.status !== 'draft') {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Application has already been submitted'
        });
      }
      
      // Check if all required questions are answered
      const allAnswered = await areAllRequiredQuestionsAnswered(req.user.id, applicationId);
      
      if (!allAnswered) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Please answer all required questions before submitting'
        });
      }
      
      // Determine next level based on current level
      const nextLevel = 'MINISTRY_LEVEL'; // EOG submits to Ministry
      
      // Update application
      await db.update(
        'applications',
        {
          status: 'submitted',
          submitted_at: new Date(),
          current_level: nextLevel
        },
        'id = ?',
        [applicationId]
      );
      
      // Record workflow action
      await db.insert('application_workflow', {
        application_id: applicationId,
        from_level: 'EOG_LEVEL',
        to_level: nextLevel,
        action: 'submit',
        comments: 'Application submitted by EOG',
        actioned_by: req.user.id
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_submitted',
        'applications',
        applicationId,
        { next_level: nextLevel },
        req.ip,
        req.get('User-Agent')
      );
      
      // Send notification (implement email notification here if needed)
      
      return res.status(200).json({
        success: true,
        message: 'Application submitted successfully',
        data: {
          status: 'submitted',
          current_level: nextLevel
        }
      });
    } catch (error) {
      logger.error(`Submit application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/applications/:applicationId/validation
 * @desc    Check if application is ready for submission
 * @access  Private
 */
router.get('/:applicationId/validation',
  authenticate,
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get all editable questions
      const editableQuestions = await getUserEditableQuestions(req.user.id, applicationId);
      const requiredQuestions = editableQuestions.filter(q => q.is_required);
      
      // Check which required questions are not answered
      const unansweredQuestions = [];
      
      for (const question of requiredQuestions) {
        const response = await db.getOne(
          `SELECT * FROM form_responses WHERE application_id = ? AND question_id = ?`,
          [applicationId, question.id]
        );
        
        if (!response || 
            !(response.answer_text || 
              response.answer_number !== null || 
              response.answer_date || 
              response.answer_file_path)) {
          unansweredQuestions.push({
            id: question.id,
            question_text: question.question_text,
            question_type: question.question_type
          });
        }
      }
      
      const canSubmit = unansweredQuestions.length === 0;
      
      return res.status(200).json({
        success: true,
        data: {
          can_submit: canSubmit,
          total_required_questions: requiredQuestions.length,
          answered_required_questions: requiredQuestions.length - unansweredQuestions.length,
          unanswered_questions: unansweredQuestions,
          progress_percentage: application.progress_percentage
        }
      });
    } catch (error) {
      logger.error(`Validation check error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// WORKFLOW MANAGEMENT ROUTES
// ============================================

/**
 * @route   POST /api/applications/:applicationId/return
 * @desc    Return application to a specific workflow level
 * @access  Private (authorized roles only)
 */
router.post('/:applicationId/return',
  authenticate,
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { return_to_level, comments } = req.body;
      
      if (!return_to_level) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'return_to_level is required'
        });
      }
      
      if (!WORKFLOW_LEVELS.includes(return_to_level)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Invalid workflow level. Must be one of: ${WORKFLOW_LEVELS.join(', ')}`
        });
      }
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Validate return level (cannot return to same or higher level)
      const currentLevelIndex = WORKFLOW_LEVELS.indexOf(application.current_level);
      const returnLevelIndex = WORKFLOW_LEVELS.indexOf(return_to_level);
      
      if (returnLevelIndex >= currentLevelIndex) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Can only return to a previous workflow level'
        });
      }
      
      // Update application
      await db.update(
        'applications',
        {
          current_level: return_to_level,
          status: 'returned'
        },
        'id = ?',
        [applicationId]
      );
      
      // Record workflow action
      await db.insert('application_workflow', {
        application_id: applicationId,
        from_level: application.current_level,
        to_level: return_to_level,
        action: 'return',
        comments: comments || 'Application returned for corrections',
        actioned_by: req.user.id
      });
      
      // Add comment if provided
      if (comments) {
        await db.insert('application_comments', {
          application_id: applicationId,
          user_id: req.user.id,
          workflow_level: application.current_level,
          comment_type: 'return_reason',
          comment_text: comments,
          is_internal: false
        });
      }
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_returned',
        'applications',
        applicationId,
        { 
          from_level: application.current_level, 
          to_level: return_to_level,
          comments 
        },
        req.ip,
        req.get('User-Agent')
      );
      
      // Send notification (implement email notification here if needed)
      
      return res.status(200).json({
        success: true,
        message: `Application returned to ${return_to_level} successfully`,
        data: {
          status: 'returned',
          current_level: return_to_level,
          previous_level: application.current_level
        }
      });
    } catch (error) {
      logger.error(`Return application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/applications/:applicationId/approve
 * @desc    Approve and forward application to next level
 * @access  Private (authorized roles only)
 */
router.post('/:applicationId/approve',
  authenticate,
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments, next_level } = req.body;
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Determine next level if not provided
      let targetLevel = next_level;
      if (!targetLevel) {
        const currentIndex = WORKFLOW_LEVELS.indexOf(application.current_level);
        if (currentIndex < WORKFLOW_LEVELS.length - 1) {
          targetLevel = WORKFLOW_LEVELS[currentIndex + 1];
        } else {
          targetLevel = application.current_level;
        }
      }
      
      // Validate next level
      if (!WORKFLOW_LEVELS.includes(targetLevel)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid next_level'
        });
      }
      
      // Update application
      const updateData = {
        current_level: targetLevel,
        status: targetLevel === 'IMPLEMENTATION_LEVEL' ? 'approved' : 'in_review'
      };
      
      await db.update('applications', updateData, 'id = ?', [applicationId]);
      
      // Record workflow action
      await db.insert('application_workflow', {
        application_id: applicationId,
        from_level: application.current_level,
        to_level: targetLevel,
        action: 'approve',
        comments: comments || 'Application approved',
        actioned_by: req.user.id
      });
      
      // Add comment if provided
      if (comments) {
        await db.insert('application_comments', {
          application_id: applicationId,
          user_id: req.user.id,
          workflow_level: application.current_level,
          comment_type: 'recommendation',
          comment_text: comments,
          is_internal: false
        });
      }
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_approved',
        'applications',
        applicationId,
        { 
          from_level: application.current_level, 
          to_level: targetLevel,
          comments 
        },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Application approved and forwarded successfully',
        data: {
          status: updateData.status,
          current_level: targetLevel,
          previous_level: application.current_level
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
 * @route   POST /api/applications/:applicationId/reject
 * @desc    Reject application
 * @access  Private (authorized roles only)
 */
router.post('/:applicationId/reject',
  authenticate,
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { comments } = req.body;
      
      if (!comments) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Rejection comments are required'
        });
      }
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Update application
      await db.update(
        'applications',
        { status: 'rejected' },
        'id = ?',
        [applicationId]
      );
      
      // Record workflow action
      await db.insert('application_workflow', {
        application_id: applicationId,
        from_level: application.current_level,
        to_level: application.current_level,
        action: 'reject',
        comments: comments,
        actioned_by: req.user.id
      });
      
      // Add comment
      await db.insert('application_comments', {
        application_id: applicationId,
        user_id: req.user.id,
        workflow_level: application.current_level,
        comment_type: 'return_reason',
        comment_text: comments,
        is_internal: false
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'application_rejected',
        'applications',
        applicationId,
        { comments },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Application rejected successfully',
        data: {
          status: 'rejected'
        }
      });
    } catch (error) {
      logger.error(`Reject application error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// ATTACHMENT ROUTES
// ============================================

/**
 * @route   POST /api/applications/:applicationId/attachments
 * @desc    Upload attachment
 * @access  Private
 */
router.post('/:applicationId/attachments',
  authenticate,
  upload.single('file'),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { attachment_type, workflow_level } = req.body;
      
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'File is required'
        });
      }
      
      if (!attachment_type) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'attachment_type is required'
        });
      }
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Save attachment
      const result = await db.insert('application_attachments', {
        application_id: applicationId,
        uploaded_by: req.user.id,
        workflow_level: workflow_level || application.current_level,
        attachment_type: attachment_type,
        file_name: req.file.originalname,
        file_path: req.file.path,
        file_size: req.file.size
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'attachment_uploaded',
        'applications',
        applicationId,
        { 
          attachment_id: result.id,
          file_name: req.file.originalname,
          attachment_type
        },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get attachment
      const attachment = await db.getOne(
        'SELECT * FROM application_attachments WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Attachment uploaded successfully',
        data: attachment
      });
    } catch (error) {
      logger.error(`Upload attachment error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/applications/:applicationId/attachments/:attachmentId
 * @desc    Delete attachment
 * @access  Private
 */
router.delete('/:applicationId/attachments/:attachmentId',
  authenticate,
  async (req, res) => {
    try {
      const { applicationId, attachmentId } = req.params;
      
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
      
      // Check access
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Get attachment
      const attachment = await db.getOne(
        'SELECT * FROM application_attachments WHERE id = ? AND application_id = ?',
        [attachmentId, applicationId]
      );
      
      if (!attachment) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Attachment not found'
        });
      }
      
      // Check if user can delete (only uploader or SUPER_USER)
      if (req.user.role !== 'SUPER_USER' && attachment.uploaded_by !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You can only delete attachments you uploaded'
        });
      }
      
      // Delete attachment from database
      await db.delete('application_attachments',
        'id = ?',
        [attachmentId]
      );
      
      // Try to delete file from filesystem
      try {
        const filePath = path.join(process.cwd(), attachment.file_path);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      } catch (err) {
        logger.warn(`Failed to delete file: ${err.message}`);
      }
      
      // Log activity
      await logger.activity(
        req.user.id,
        'attachment_deleted',
        'applications',
        applicationId,
        { 
          attachment_id: attachmentId,
          file_name: attachment.file_name
        },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Attachment deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete attachment error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// COMMENT ROUTES
// ============================================

/**
 * @route   POST /api/applications/:applicationId/comments
 * @desc    Add comment
 * @access  Private
 */
router.post('/:applicationId/comments',
  authenticate,
  validateParams(schemas.applicationIdParam),
  async (req, res) => {
    try {
      const applicationId = req.params.applicationId;
      const { 
        workflow_level, 
        comment_type, 
        comment_text, 
        parent_comment_id,
        is_internal
      } = req.body;
      
      // Validate required fields
      if (!workflow_level || !comment_type || !comment_text) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'workflow_level, comment_type, and comment_text are required'
        });
      }
      
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
      const hasAccess = await checkApplicationAccess(req.user, application);
      
      if (!hasAccess) {
        return res.status(403).json({
          success: false,
          error: 'Forbidden',
          message: 'You do not have access to this application'
        });
      }
      
      // Validate workflow level
      if (!WORKFLOW_LEVELS.includes(workflow_level)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid workflow_level'
        });
      }
      
      // Validate comment type
      const validTypes = [
        'question',
        'clarification_request',
        'feedback',
        'recommendation',
        'return_reason',
        'general'
      ];
      
      if (!validTypes.includes(comment_type)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid comment_type'
        });
      }
      
      // If parent_comment_id, check if it exists
      if (parent_comment_id) {
        const parentComment = await db.getOne(
          'SELECT * FROM application_comments WHERE id = ? AND application_id = ?',
          [parent_comment_id, applicationId]
        );
        
        if (!parentComment) {
          return res.status(404).json({
            success: false,
            error: 'Not Found',
            message: 'Parent comment not found'
          });
        }
      }
      
      // Save comment
      const result = await db.insert('application_comments', {
        application_id: applicationId,
        user_id: req.user.id,
        workflow_level,
        comment_type,
        comment_text,
        parent_comment_id: parent_comment_id || null,
        is_internal: is_internal === true
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'comment_added',
        'applications',
        applicationId,
        { comment_type, workflow_level },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created comment
      const comment = await db.getOne(
        `SELECT ac.*, u.username, u.first_name, u.last_name, u.role
         FROM application_comments ac
         JOIN users u ON u.id = ac.user_id
         WHERE ac.id = ?`,
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Comment added successfully',
        data: comment
      });
    } catch (error) {
      logger.error(`Add comment error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;