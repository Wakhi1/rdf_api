// forms_routes.js - Form Management Routes
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, validateBody, schemas } = require('../middleware/validation.middleware');
const config = require('../config/config');

// ============================================
// MULTER CONFIGURATION FOR FILE UPLOADS
// ============================================

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const formId = req.params.formId || 'temp';
    const dir = path.join(config.upload.dir, 'form_files', formId);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    const filename = 'form-file-' + uniqueSuffix + ext;
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
    'text/csv'
  ];
  
  if (!allowedTypes.includes(file.mimetype)) {
    return cb(new Error('File type not allowed'), false);
  }
  
  cb(null, true);
};

const upload = multer({ 
  storage, 
  fileFilter, 
  limits: { fileSize: config.upload.maxFileSize } 
});

// ============================================
// CONSTANTS AND HELPERS
// ============================================

const QUESTION_TYPES = [
  'TEXT', 'TEXTAREA', 'NUMBER', 'DECIMAL', 'SELECT', 'MULTISELECT',
  'RADIO', 'CHECKBOX', 'DATE', 'BOOLEAN', 'FILE', 'SIGNATURE', 'TABLE'
];

const WORKFLOW_LEVELS = [
  'EOG_LEVEL', 'MINISTRY_LEVEL', 'MICROPROJECTS_LEVEL', 'CDO_LEVEL',
  'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', 'RDFTC_LEVEL', 'RDFC_LEVEL',
  'PS_LEVEL', 'PROCUREMENT_LEVEL', 'IMPLEMENTATION_LEVEL'
];

/**
 * Helper: Validate workflow level
 */
function isValidWorkflowLevel(level) {
  return !level || WORKFLOW_LEVELS.includes(level);
}

/**
 * Helper: Validate question type
 */
function isValidQuestionType(type) {
  return QUESTION_TYPES.includes(type);
}

/**
 * Helper: Parse options (handles string, array, JSON)
 */
function parseOptions(options) {
  if (!options) return null;
  
  if (typeof options === 'string') {
    try {
      return JSON.parse(options);
    } catch (error) {
      return options.split(',').map(opt => opt.trim()).filter(opt => opt);
    }
  }
  
  return options;
}

/**
 * Helper: Parse roles
 */
function parseRoles(roles) {
  if (!roles) return null;
  
  if (typeof roles === 'string') {
    return roles.split(',').map(role => role.trim()).filter(role => role);
  }
  
  if (Array.isArray(roles)) {
    return roles.filter(role => role);
  }
  
  return null;
}

/**
 * Helper: Create question in database
 */
async function createQuestionInDB(connection, sectionId, questionData) {
  if (!isValidQuestionType(questionData.question_type)) {
    throw new Error(`Invalid question type: ${questionData.question_type}`);
  }
  
  const options = parseOptions(questionData.options);
  const visibleRoles = parseRoles(questionData.visible_to_roles);
  const editableRoles = parseRoles(questionData.editable_by_roles);
  
  const result = await connection.query(
    `INSERT INTO form_questions 
     (section_id, question_text, question_type, options, is_required, order_number,
      visible_to_roles, editable_by_roles, conditional_question_id, conditional_answer,
      validation_rules, help_text, table_columns, min_rows, max_rows, 
      allow_add_rows, allow_delete_rows) 
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      sectionId,
      questionData.question_text,
      questionData.question_type,
      options ? JSON.stringify(options) : null,
      questionData.is_required ? 1 : 0,
      questionData.order_number || 0,
      visibleRoles ? visibleRoles.join(',') : null,
      editableRoles ? editableRoles.join(',') : null,
      questionData.conditional_question_id || null,
      questionData.conditional_answer || null,
      questionData.validation_rules || null,
      questionData.help_text || null,
      // ✅ ADD TABLE CONFIGURATION:
      questionData.table_columns ? JSON.stringify(questionData.table_columns) : null,
      questionData.min_rows || null,
      questionData.max_rows || null,
      questionData.allow_add_rows ? 1 : 0,
      questionData.allow_delete_rows ? 1 : 0
    ]
  );
  
  return result.insertId;
}

/**
 * Helper: Create section with subsections and questions recursively
 */
async function createSectionRecursive(connection, formId, sectionData, parentSectionId = null) {
  if (!isValidWorkflowLevel(sectionData.workflow_level)) {
    throw new Error(`Invalid workflow level: ${sectionData.workflow_level}`);
  }
  
  // Create section
  const sectionResult = await connection.query(
    `INSERT INTO form_sections 
     (form_id, parent_section_id, title, description, order_number, workflow_level) 
     VALUES (?, ?, ?, ?, ?, ?)`,
    [
      formId,
      parentSectionId,
      sectionData.title,
      sectionData.description || null,
      sectionData.order_number || 0,
      sectionData.workflow_level || null
    ]
  );
  
  const sectionId = sectionResult.insertId;
  
  // Create questions for this section
  if (sectionData.questions && Array.isArray(sectionData.questions)) {
    for (const question of sectionData.questions) {
      await createQuestionInDB(connection, sectionId, question);
    }
  }
  
  // Create subsections recursively
  if (sectionData.subsections && Array.isArray(sectionData.subsections)) {
    for (const subsection of sectionData.subsections) {
      await createSectionRecursive(connection, formId, subsection, sectionId);
    }
  }
  
  return sectionId;
}

// ============================================
// ROUTES - FORM CRUD OPERATIONS
// ============================================

/**
 * @route   GET /api/forms
 * @desc    Get all forms with pagination and filtering
 * @access  Private
 */
router.get('/',
  authenticate,
  async (req, res) => {
    try {
      const { 
        page = 1, 
        limit = 10, 
        is_active, 
        sort_by = 'created_at', 
        sort_order = 'desc',
        search
      } = req.query;
      
      let countQuery = 'SELECT COUNT(*) as total FROM forms WHERE 1=1';
      let dataQuery = `
        SELECT f.*, u.username as created_by_username, 
               u.first_name, u.last_name,
               (SELECT COUNT(*) FROM form_sections WHERE form_id = f.id) as section_count,
               (SELECT COUNT(*) FROM form_questions fq 
                JOIN form_sections fs ON fs.id = fq.section_id 
                WHERE fs.form_id = f.id) as question_count
        FROM forms f
        LEFT JOIN users u ON u.id = f.created_by
        WHERE 1=1
      `;
      const params = [];
      
      // Add filters
      if (is_active !== undefined) {
        countQuery += ' AND is_active = ?';
        dataQuery += ' AND f.is_active = ?';
        params.push(is_active === 'true' ? 1 : 0);
      }
      
      if (search) {
        countQuery += ' AND (name LIKE ? OR description LIKE ?)';
        dataQuery += ' AND (f.name LIKE ? OR f.description LIKE ?)';
        const searchTerm = `%${search}%`;
        params.push(searchTerm, searchTerm);
      }
      
      // Add sorting
      const allowedSortFields = ['name', 'created_at', 'updated_at', 'version'];
      const sortField = allowedSortFields.includes(sort_by) ? sort_by : 'created_at';
      const order = sort_order.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
      
      dataQuery += ` ORDER BY f.${sortField} ${order}`;
      
      // Add pagination
      const offset = (page - 1) * limit;
      dataQuery += ' LIMIT ? OFFSET ?';
      
      // Execute queries
      const countResult = await db.getOne(countQuery, params);
      const total = countResult.total;
      const data = await db.query(dataQuery, [...params, parseInt(limit), offset]);
      
      const totalPages = Math.ceil(total / limit);
      
      return res.status(200).json({
        success: true,
        data,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: totalPages
        }
      });
    } catch (error) {
      logger.error(`Get forms error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/forms/active
 * @desc    Get active form with full structure
 * @access  Private
 */
router.get('/active',
  authenticate,
  async (req, res) => {
    try {
      const form = await db.getOne(
        'SELECT * FROM forms WHERE is_active = TRUE ORDER BY created_at DESC LIMIT 1'
      );
      
      if (!form) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'No active form found'
        });
      }
      
      // Get all sections for this form
      const sections = await db.query(
        `SELECT * FROM form_sections 
         WHERE form_id = ? 
         ORDER BY order_number ASC`,
        [form.id]
      );
      
      // Get all questions for this form
      const questions = await db.query(
        `SELECT fq.* 
         FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fs.form_id = ?
         ORDER BY fq.order_number ASC`,
        [form.id]
      );
      
      // Organize into hierarchical structure
      const sectionMap = new Map();
      const rootSections = [];
      
      // First pass: create section objects
      sections.forEach(section => {
        sectionMap.set(section.id, {
          ...section,
          questions: [],
          subsections: []
        });
      });
      
      // Second pass: organize hierarchy
      sections.forEach(section => {
        const sectionObj = sectionMap.get(section.id);
        if (section.parent_section_id) {
          const parent = sectionMap.get(section.parent_section_id);
          if (parent) {
            parent.subsections.push(sectionObj);
          }
        } else {
          rootSections.push(sectionObj);
        }
      });
      
      // Third pass: add questions to sections
      questions.forEach(question => {
        const section = sectionMap.get(question.section_id);
        if (section) {
          section.questions.push(question);
        }
      });
      
      return res.status(200).json({
        success: true,
        data: {
          form,
          sections: rootSections
        }
      });
    } catch (error) {
      logger.error(`Get active form error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/forms/:formId
 * @desc    Get form by ID with full structure
 * @access  Private
 */
router.get('/:formId',
  authenticate,
  async (req, res) => {
    try {
      const formId = req.params.formId;
      
      const form = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      
      if (!form) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Form not found'
        });
      }
      
      // Get all sections
      const sections = await db.query(
        'SELECT * FROM form_sections WHERE form_id = ? ORDER BY order_number ASC',
        [formId]
      );
      
      // Get all questions
      const questions = await db.query(
        `SELECT fq.* 
         FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fs.form_id = ?
         ORDER BY fq.order_number ASC`,
        [formId]
      );
      
      // Parse table_columns for each question
      const parsedQuestions = questions.map(q => {
        if (q.table_columns) {
          try {
            // If it's a string, parse it to JSON
            if (typeof q.table_columns === 'string') {
              q.table_columns = JSON.parse(q.table_columns);
            }
          } catch (e) {
            console.error(`Error parsing table_columns for question ${q.id}:`, e);
            q.table_columns = null;
          }
        }
        return q;
      });
      
      // Organize hierarchical structure
      const sectionMap = new Map();
      const rootSections = [];
      
      sections.forEach(section => {
        sectionMap.set(section.id, {
          ...section,
          questions: [],
          subsections: []
        });
      });
      
      sections.forEach(section => {
        const sectionObj = sectionMap.get(section.id);
        if (section.parent_section_id) {
          const parent = sectionMap.get(section.parent_section_id);
          if (parent) {
            parent.subsections.push(sectionObj);
          }
        } else {
          rootSections.push(sectionObj);
        }
      });
      
      parsedQuestions.forEach(question => {
        const section = sectionMap.get(question.section_id);
        if (section) {
          section.questions.push(question);
        }
      });
      
      return res.status(200).json({
        success: true,
        data: {
          form,
          sections: rootSections
        }
      });
    } catch (error) {
      logger.error(`Get form error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);
/**
 * @route   POST /api/forms
 * @desc    Create new form (simple)
 * @access  Private (SUPER_USER only)
 */
router.post('/',
  authenticate,
  requireRole('SUPER_USER'),
  async (req, res) => {
    try {
      const { name, description, version = '1.0', is_active = false } = req.body;
      
      // If setting as active, deactivate all other forms
      if (is_active) {
        await db.query('UPDATE forms SET is_active = FALSE WHERE is_active = TRUE');
      }
      
      // Create form
      const result = await db.insert('forms', {
        name,
        description,
        version,
        is_active: is_active ? 1 : 0,
        created_by: req.user.id
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'form_created',
        'forms',
        result.id,
        { name, version, is_active },
        req.ip,
        req.get('User-Agent')
      );
      
      const form = await db.getOne('SELECT * FROM forms WHERE id = ?', [result.id]);
      
      return res.status(201).json({
        success: true,
        message: 'Form created successfully',
        data: form
      });
    } catch (error) {
      logger.error(`Create form error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/forms/bulk
 * @desc    Create form with sections, subsections, and questions in one transaction
 * @access  Private (SUPER_USER only)
 * @body    { form: {}, sections: [] }
 */
router.post('/bulk',
  authenticate,
  requireRole('SUPER_USER'),
  async (req, res) => {
    const connection = await db.beginTransaction();
    
    try {
      const { form, sections } = req.body;
      
      // Validate form data
      if (!form || !form.name) {
        await db.rollback(connection);
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Form name is required'
        });
      }
      
      // Deactivate other forms if this is active
      if (form.is_active) {
        await connection.query('UPDATE forms SET is_active = FALSE WHERE is_active = TRUE');
      }
      
      // Create form
      const formResult = await connection.query(
        'INSERT INTO forms (name, description, version, is_active, created_by) VALUES (?, ?, ?, ?, ?)',
        [
          form.name, 
          form.description || null, 
          form.version || '1.0', 
          form.is_active ? 1 : 0, 
          req.user.id
        ]
      );
      
      const formId = formResult.insertId;
      
      // Process sections if provided
      if (sections && Array.isArray(sections)) {
        for (const section of sections) {
          await createSectionRecursive(connection, formId, section, null);
        }
      }
      
      await db.commit(connection);
      
      // Log activity
      await logger.activity(
        req.user.id,
        'form_bulk_created',
        'forms',
        formId,
        { name: form.name, sections_count: sections?.length || 0 },
        req.ip,
        req.get('User-Agent')
      );
      
      // Fetch complete form with structure
      const completeForm = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      const allSections = await db.query(
        'SELECT * FROM form_sections WHERE form_id = ? ORDER BY order_number',
        [formId]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Form created successfully with all components',
        data: {
          form: completeForm,
          sections: allSections
        }
      });
      
    } catch (error) {
      await db.rollback(connection);
      logger.error(`Bulk form creation error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/forms/:formId
 * @desc    Update form
 * @access  Private (SUPER_USER only)
 */
router.put('/:formId',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
//   validateBody(schemas.updateForm),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const { name, description, version, is_active } = req.body;
      
      const currentForm = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      
      if (!currentForm) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Form not found'
        });
      }
      
      // If setting as active, deactivate all other forms
      if (is_active && !currentForm.is_active) {
        await db.query('UPDATE forms SET is_active = FALSE WHERE is_active = TRUE AND id != ?', [formId]);
      }
      
      const updateData = {};
      if (name !== undefined) updateData.name = name;
      if (description !== undefined) updateData.description = description;
      if (version !== undefined) updateData.version = version;
      if (is_active !== undefined) updateData.is_active = is_active ? 1 : 0;
      
      await db.update('forms', updateData, 'id = ?', [formId]);
      
      await logger.activity(
        req.user.id,
        'form_updated',
        'forms',
        formId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      const form = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      
      return res.status(200).json({
        success: true,
        message: 'Form updated successfully',
        data: form
      });
    } catch (error) {
      logger.error(`Update form error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/forms/:formId
 * @desc    Delete form (only if no applications use it)
 * @access  Private (SUPER_USER only)
 */
router.delete('/:formId',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      
      const form = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      
      if (!form) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Form not found'
        });
      }
      
      // Check if form is being used
      const applications = await db.query(
        'SELECT COUNT(*) as count FROM applications WHERE form_id = ?',
        [formId]
      );
      
      if (applications[0].count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete form that is being used by applications'
        });
      }
      
      const connection = await db.beginTransaction();
      
      try {
        // Delete questions
        await connection.query(
          `DELETE fq FROM form_questions fq
           JOIN form_sections fs ON fs.id = fq.section_id
           WHERE fs.form_id = ?`,
          [formId]
        );
        
        // Delete sections
        await connection.query('DELETE FROM form_sections WHERE form_id = ?', [formId]);
        
        // Delete form
        await connection.query('DELETE FROM forms WHERE id = ?', [formId]);
        
        await db.commit(connection);
        
        await logger.activity(
          req.user.id,
          'form_deleted',
          'forms',
          formId,
          { name: form.name },
          req.ip,
          req.get('User-Agent')
        );
        
        return res.status(200).json({
          success: true,
          message: 'Form deleted successfully'
        });
      } catch (error) {
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Delete form error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// ROUTES - SECTION CRUD OPERATIONS
// ============================================

/**
 * @route   POST /api/forms/:formId/sections
 * @desc    Create new section in form
 * @access  Private (SUPER_USER only)
 */
router.post('/:formId/sections',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
//   validateBody(schemas.createSection),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const { 
        title, 
        description, 
        order_number = 0, 
        workflow_level,
        parent_section_id 
      } = req.body;
      
      const form = await db.getOne('SELECT * FROM forms WHERE id = ?', [formId]);
      
      if (!form) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Form not found'
        });
      }
      
      // Validate parent section if provided
      if (parent_section_id) {
        const parentSection = await db.getOne(
          'SELECT * FROM form_sections WHERE id = ? AND form_id = ?',
          [parent_section_id, formId]
        );
        
        if (!parentSection) {
          return res.status(400).json({
            success: false,
            error: 'Bad Request',
            message: 'Parent section not found in this form'
          });
        }
      }
      
      // Validate workflow level
      if (!isValidWorkflowLevel(workflow_level)) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Invalid workflow level'
        });
      }
      
      // Create section
      const result = await db.insert('form_sections', {
        form_id: formId,
        parent_section_id: parent_section_id || null,
        title,
        description: description || null,
        order_number,
        workflow_level: workflow_level || null
      });
      
      await logger.activity(
        req.user.id,
        'form_section_created',
        'form_sections',
        result.id,
        { form_id: formId, title, workflow_level },
        req.ip,
        req.get('User-Agent')
      );
      
      const section = await db.getOne('SELECT * FROM form_sections WHERE id = ?', [result.id]);
      
      return res.status(201).json({
        success: true,
        message: 'Section created successfully',
        data: section
      });
    } catch (error) {
      logger.error(`Create section error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/forms/:formId/sections
 * @desc    Get all sections for a form
 * @access  Private
 */
router.get('/:formId/sections',
  authenticate,
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      
      const sections = await db.query(
        `SELECT fs.*, 
                (SELECT COUNT(*) FROM form_questions WHERE section_id = fs.id) as question_count,
                (SELECT COUNT(*) FROM form_sections WHERE parent_section_id = fs.id) as subsection_count
         FROM form_sections fs
         WHERE fs.form_id = ?
         ORDER BY fs.order_number ASC`,
        [formId]
      );
      
      return res.status(200).json({
        success: true,
        data: sections
      });
    } catch (error) {
      logger.error(`Get sections error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/forms/:formId/sections/:sectionId
 * @desc    Update section
 * @access  Private (SUPER_USER only)
 */
router.put('/:formId/sections/:sectionId',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
//   validateBody(schemas.updateSection),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      const { title, description, order_number, workflow_level } = req.body;
      
      const section = await db.getOne(
        'SELECT * FROM form_sections WHERE id = ? AND form_id = ?',
        [sectionId, formId]
      );
      
      if (!section) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Section not found in this form'
        });
      }
      
      if (workflow_level && !isValidWorkflowLevel(workflow_level)) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Invalid workflow level'
        });
      }
      
      const updateData = {};
      if (title !== undefined) updateData.title = title;
      if (description !== undefined) updateData.description = description;
      if (order_number !== undefined) updateData.order_number = order_number;
      if (workflow_level !== undefined) updateData.workflow_level = workflow_level;
      
      await db.update('form_sections', updateData, 'id = ? AND form_id = ?', [sectionId, formId]);
      
      await logger.activity(
        req.user.id,
        'form_section_updated',
        'form_sections',
        sectionId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      const updatedSection = await db.getOne('SELECT * FROM form_sections WHERE id = ?', [sectionId]);
      
      return res.status(200).json({
        success: true,
        message: 'Section updated successfully',
        data: updatedSection
      });
    } catch (error) {
      logger.error(`Update section error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/forms/:formId/sections/:sectionId
 * @desc    Delete section
 * @access  Private (SUPER_USER only)
 */
router.delete('/:formId/sections/:sectionId',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      
      const section = await db.getOne(
        'SELECT * FROM form_sections WHERE id = ? AND form_id = ?',
        [sectionId, formId]
      );
      
      if (!section) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Section not found in this form'
        });
      }
      
      // Check for questions
      const questions = await db.query(
        'SELECT COUNT(*) as count FROM form_questions WHERE section_id = ?',
        [sectionId]
      );
      
      if (questions[0].count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete section that contains questions. Delete questions first.'
        });
      }
      
      // Check for subsections
      const subsections = await db.query(
        'SELECT COUNT(*) as count FROM form_sections WHERE parent_section_id = ?',
        [sectionId]
      );
      
      if (subsections[0].count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete section that contains subsections. Delete subsections first.'
        });
      }
      
      await db.delete('form_sections', 'id = ? AND form_id = ?', [sectionId, formId]);
      
      await logger.activity(
        req.user.id,
        'form_section_deleted',
        'form_sections',
        sectionId,
        { title: section.title },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Section deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete section error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// ROUTES - QUESTION CRUD OPERATIONS
// ============================================

/**
 * @route   POST /api/forms/:formId/sections/:sectionId/questions
 * @desc    Create new question in section
 * @access  Private (SUPER_USER only)
 */
router.post('/:formId/sections/:sectionId/questions',
  authenticate,
  requireRole('SUPER_USER'),
  upload.single('file'),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      const {
        question_text,
        question_type,
        options,
        is_required = false,
        order_number = 0,
        visible_to_roles,
        editable_by_roles,
        conditional_question_id,
        conditional_answer,
        validation_rules,
        help_text,
        // ✅ ADD TABLE CONFIGURATION:
        table_columns,
        min_rows,
        max_rows,
        allow_add_rows = true,
        allow_delete_rows = true
      } = req.body;
      
      // Verify section exists and belongs to form
      const section = await db.getOne(
        'SELECT * FROM form_sections WHERE id = ? AND form_id = ?',
        [sectionId, formId]
      );
      
      if (!section) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Section not found in this form'
        });
      }
      
      // Validate question type
      if (!isValidQuestionType(question_type)) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: `Invalid question type. Must be one of: ${QUESTION_TYPES.join(', ')}`
        });
      }
      
      // Parse options
      const parsedOptions = parseOptions(options);
      
      // Parse roles
      const visibleRoles = parseRoles(visible_to_roles);
      const editableRoles = parseRoles(editable_by_roles);
      
      // Create question
      const result = await db.insert('form_questions', {
        section_id: sectionId,
        question_text,
        question_type,
        options: parsedOptions ? JSON.stringify(parsedOptions) : null,
        is_required: is_required ? 1 : 0,
        order_number,
        visible_to_roles: visibleRoles ? visibleRoles.join(',') : null,
        editable_by_roles: editableRoles ? editableRoles.join(',') : null,
        conditional_question_id: conditional_question_id || null,
        conditional_answer: conditional_answer || null,
        validation_rules: validation_rules || null,
        help_text: help_text || null,
        // ✅ ADD TABLE CONFIGURATION:
        table_columns: table_columns ? JSON.stringify(table_columns) : null,
        min_rows: min_rows || null,
        max_rows: max_rows || null,
        allow_add_rows: allow_add_rows ? 1 : 0,
        allow_delete_rows: allow_delete_rows ? 1 : 0
      });
      
      await logger.activity(
        req.user.id,
        'form_question_created',
        'form_questions',
        result.id,
        { section_id: sectionId, question_type, is_required },
        req.ip,
        req.get('User-Agent')
      );
      
      const question = await db.getOne(
        `SELECT fq.*, fs.title as section_title, fs.workflow_level
         FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ?`,
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Question created successfully',
        data: question
      });
    } catch (error) {
      logger.error(`Create question error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/forms/:formId/sections/:sectionId/questions
 * @desc    Get all questions in a section
 * @access  Private
 */
router.get('/:formId/sections/:sectionId/questions',
  authenticate,
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      
      // Verify section belongs to form
      const section = await db.getOne(
        'SELECT * FROM form_sections WHERE id = ? AND form_id = ?',
        [sectionId, formId]
      );
      
      if (!section) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Section not found in this form'
        });
      }
      
      const questions = await db.query(
        `SELECT fq.*, fs.title as section_title, fs.workflow_level
         FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.section_id = ?
         ORDER BY fq.order_number ASC`,
        [sectionId]
      );
      
      return res.status(200).json({
        success: true,
        data: questions
      });
    } catch (error) {
      logger.error(`Get section questions error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/forms/:formId/questions
 * @desc    Get all questions for a form with filtering
 * @access  Private
 */
router.get('/:formId/questions',
  authenticate,
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const { workflow_level, question_type, role } = req.query;
      
      let query = `
        SELECT fq.*, fs.title as section_title, fs.workflow_level,
               parent_section.title as parent_section_title
        FROM form_questions fq
        JOIN form_sections fs ON fs.id = fq.section_id
        LEFT JOIN form_sections parent_section ON parent_section.id = fs.parent_section_id
        WHERE fs.form_id = ?
      `;
      const params = [formId];
      
      if (workflow_level) {
        query += ' AND fs.workflow_level = ?';
        params.push(workflow_level);
      }
      
      if (question_type) {
        query += ' AND fq.question_type = ?';
        params.push(question_type);
      }
      
      if (role) {
        query += ' AND (fq.visible_to_roles IS NULL OR fq.visible_to_roles = ? OR fq.visible_to_roles LIKE ?)';
        params.push('', `%${role}%`);
      }
      
      query += ' ORDER BY fs.order_number ASC, fq.order_number ASC';
      
      const questions = await db.query(query, params);
      
      return res.status(200).json({
        success: true,
        data: questions
      });
    } catch (error) {
      logger.error(`Get form questions error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/forms/:formId/sections/:sectionId/questions/:questionId
 * @desc    Update question
 * @access  Private (SUPER_USER only)
 */
router.put('/:formId/sections/:sectionId/questions/:questionId',
  authenticate,
  requireRole('SUPER_USER'),
  upload.single('file'),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      const questionId = req.params.questionId;
      
      const {
        question_text,
        question_type,
        options,
        is_required,
        order_number,
        visible_to_roles,
        editable_by_roles,
        conditional_question_id,
        conditional_answer,
        validation_rules,
        help_text,
        // ✅ ADD TABLE CONFIGURATION:
        table_columns,
        min_rows,
        max_rows,
        allow_add_rows,
        allow_delete_rows
      } = req.body;
      
      // Verify question exists
      const question = await db.getOne(
        `SELECT fq.* FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ? AND fq.section_id = ? AND fs.form_id = ?`,
        [questionId, sectionId, formId]
      );
      
      if (!question) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Question not found in this section and form'
        });
      }
      
      const updateData = {};
      
      if (question_text !== undefined) updateData.question_text = question_text;
      
      if (question_type !== undefined) {
        if (!isValidQuestionType(question_type)) {
          return res.status(400).json({
            success: false,
            error: 'Bad Request',
            message: `Invalid question type. Must be one of: ${QUESTION_TYPES.join(', ')}`
          });
        }
        updateData.question_type = question_type;
      }
      
      if (options !== undefined) {
        const parsedOptions = parseOptions(options);
        updateData.options = parsedOptions ? JSON.stringify(parsedOptions) : null;
      }
      
      if (is_required !== undefined) updateData.is_required = is_required ? 1 : 0;
      if (order_number !== undefined) updateData.order_number = order_number;
      
      if (visible_to_roles !== undefined) {
        const visibleRoles = parseRoles(visible_to_roles);
        updateData.visible_to_roles = visibleRoles ? visibleRoles.join(',') : null;
      }
      
      if (editable_by_roles !== undefined) {
        const editableRoles = parseRoles(editable_by_roles);
        updateData.editable_by_roles = editableRoles ? editableRoles.join(',') : null;
      }
      
      if (conditional_question_id !== undefined) updateData.conditional_question_id = conditional_question_id;
      if (conditional_answer !== undefined) updateData.conditional_answer = conditional_answer;
      if (validation_rules !== undefined) updateData.validation_rules = validation_rules;
      if (help_text !== undefined) updateData.help_text = help_text;
      
      // ✅ ADD TABLE CONFIGURATION:
      if (table_columns !== undefined) {
        updateData.table_columns = table_columns ? JSON.stringify(table_columns) : null;
      }
      if (min_rows !== undefined) updateData.min_rows = min_rows;
      if (max_rows !== undefined) updateData.max_rows = max_rows;
      if (allow_add_rows !== undefined) updateData.allow_add_rows = allow_add_rows ? 1 : 0;
      if (allow_delete_rows !== undefined) updateData.allow_delete_rows = allow_delete_rows ? 1 : 0;
      
      await db.update('form_questions', updateData, 'id = ?', [questionId]);
      
      await logger.activity(
        req.user.id,
        'form_question_updated',
        'form_questions',
        questionId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      const updatedQuestion = await db.getOne(
        `SELECT fq.*, fs.title as section_title, fs.workflow_level
         FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ?`,
        [questionId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Question updated successfully',
        data: updatedQuestion
      });
    } catch (error) {
      logger.error(`Update question error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/forms/:formId/sections/:sectionId/questions/:questionId
 * @desc    Delete question
 * @access  Private (SUPER_USER only)
 */
router.delete('/:formId/sections/:sectionId/questions/:questionId',
  authenticate,
  requireRole('SUPER_USER'),
//   validateParams(schemas.formIdParam),
  async (req, res) => {
    try {
      const formId = req.params.formId;
      const sectionId = req.params.sectionId;
      const questionId = req.params.questionId;
      
      const question = await db.getOne(
        `SELECT fq.* FROM form_questions fq
         JOIN form_sections fs ON fs.id = fq.section_id
         WHERE fq.id = ? AND fq.section_id = ? AND fs.form_id = ?`,
        [questionId, sectionId, formId]
      );
      
      if (!question) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Question not found in this section and form'
        });
      }
      
      // Check for dependent questions
      const dependentQuestions = await db.query(
        'SELECT COUNT(*) as count FROM form_questions WHERE conditional_question_id = ?',
        [questionId]
      );
      
      if (dependentQuestions[0].count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete question that has dependent conditional questions'
        });
      }
      
      // Check for responses
      const responses = await db.query(
        'SELECT COUNT(*) as count FROM form_responses WHERE question_id = ?',
        [questionId]
      );
      
      if (responses[0].count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete question that has existing responses'
        });
      }
      
      await db.delete('form_questions', 'id = ?', [questionId]);
      
      await logger.activity(
        req.user.id,
        'form_question_deleted',
        'form_questions',
        questionId,
        { question_text: question.question_text },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Question deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete question error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

// ============================================
// UTILITY ROUTES
// ============================================

/**
 * @route   GET /api/forms/metadata/question-types
 * @desc    Get all available question types
 * @access  Private
 */
router.get('/metadata/question-types',
  authenticate,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      data: QUESTION_TYPES
    });
  }
);

/**
 * @route   GET /api/forms/metadata/workflow-levels
 * @desc    Get all available workflow levels
 * @access  Private
 */
router.get('/metadata/workflow-levels',
  authenticate,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      data: WORKFLOW_LEVELS
    });
  }
);

module.exports = router;