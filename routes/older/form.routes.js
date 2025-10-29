const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { validate, schemas } = require('../utils/validation');
const { verifyToken, checkRole } = require('../middleware/auth.middleware');

/**
 * @route   POST /api/forms
 * @desc    Create new form
 * @access  Private (SUPER_USER)
 */
router.post('/', verifyToken, checkRole('SUPER_USER'), validate(schemas.createFormSchema), async (req, res, next) => {
  try {
    const { name, description, version } = req.validatedData;

    const result = await db.query(
      'INSERT INTO forms (name, description, version, created_by) VALUES (?, ?, ?, ?)',
      [name, description || null, version || '1.0', req.user.id]
    );

    const form = await db.queryOne('SELECT * FROM forms WHERE id = ?', [result.insertId]);

    res.status(201).json({
      status: 'success',
      message: 'Form created successfully',
      data: { form }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/forms/:formId/sections
 * @desc    Add section to form
 * @access  Private (SUPER_USER)
 */
router.post('/:formId/sections', verifyToken, checkRole('SUPER_USER'), validate(schemas.createSectionSchema), async (req, res, next) => {
  try {
    const { formId } = req.params;
    const data = req.validatedData;

    const result = await db.query(
      `INSERT INTO form_sections (form_id, parent_section_id, title, description, order_number, workflow_level)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [data.form_id, data.parent_section_id || null, data.title, data.description || null, 
       data.order_number || 0, data.workflow_level || null]
    );

    const section = await db.queryOne('SELECT * FROM form_sections WHERE id = ?', [result.insertId]);

    res.status(201).json({
      status: 'success',
      message: 'Section created successfully',
      data: { section }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/forms/sections/:sectionId/questions
 * @desc    Add question to section
 * @access  Private (SUPER_USER)
 */
router.post('/sections/:sectionId/questions', verifyToken, checkRole('SUPER_USER'), validate(schemas.createQuestionSchema), async (req, res, next) => {
  try {
    const data = req.validatedData;

    const result = await db.query(
      `INSERT INTO form_questions 
       (section_id, question_text, question_type, required, order_number, validation_rules, options, can_answer, can_view)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        data.section_id,
        data.question_text,
        data.question_type,
        data.required || false,
        data.order_number || 0,
        data.validation_rules ? JSON.stringify(data.validation_rules) : null,
        data.options ? JSON.stringify(data.options) : null,
        data.can_answer ? JSON.stringify(data.can_answer) : null,
        data.can_view ? JSON.stringify(data.can_view) : null
      ]
    );

    const question = await db.queryOne('SELECT * FROM form_questions WHERE id = ?', [result.insertId]);

    res.status(201).json({
      status: 'success',
      message: 'Question created successfully',
      data: { question }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/forms
 * @desc    Get all forms
 * @access  Private
 */
router.get('/', verifyToken, async (req, res, next) => {
  try {
    const { is_active } = req.query;

    let query = 'SELECT * FROM forms WHERE 1=1';
    const params = [];

    if (is_active !== undefined) {
      query += ' AND is_active = ?';
      params.push(is_active === 'true' ? 1 : 0);
    }

    query += ' ORDER BY created_at DESC';

    const forms = await db.query(query, params);

    res.json({
      status: 'success',
      data: { forms }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/forms/:id
 * @desc    Get form with sections and questions
 * @access  Private
 */
router.get('/:id', verifyToken, async (req, res, next) => {
  try {
    const { id } = req.params;

    const form = await db.queryOne('SELECT * FROM forms WHERE id = ?', [id]);
    if (!form) {
      return res.status(404).json({
        status: 'error',
        message: 'Form not found'
      });
    }

    // Get sections
    const sections = await db.query(
      'SELECT * FROM form_sections WHERE form_id = ? ORDER BY order_number',
      [id]
    );

    // Get questions for each section
    for (const section of sections) {
      const questions = await db.query(
        `SELECT * FROM form_questions 
         WHERE section_id = ? 
         ORDER BY order_number`,
        [section.id]
      );

      // Parse JSON fields
      questions.forEach(q => {
        if (q.validation_rules) q.validation_rules = JSON.parse(q.validation_rules);
        if (q.options) q.options = JSON.parse(q.options);
        if (q.can_answer) q.can_answer = JSON.parse(q.can_answer);
        if (q.can_view) q.can_view = JSON.parse(q.can_view);
      });

      section.questions = questions;
    }

    form.sections = sections;

    res.json({
      status: 'success',
      data: { form }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/forms/:id
 * @desc    Update form
 * @access  Private (SUPER_USER)
 */
router.put('/:id', verifyToken, checkRole('SUPER_USER'), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, description, is_active } = req.body;

    const updates = {};
    if (name !== undefined) updates.name = name;
    if (description !== undefined) updates.description = description;
    if (is_active !== undefined) updates.is_active = is_active;

    const fields = Object.keys(updates);
    if (fields.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'No fields to update'
      });
    }

    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = [...Object.values(updates), id];

    await db.query(`UPDATE forms SET ${setClause} WHERE id = ?`, values);

    const form = await db.queryOne('SELECT * FROM forms WHERE id = ?', [id]);

    res.json({
      status: 'success',
      message: 'Form updated successfully',
      data: { form }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;