const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { parse } = require('fast-csv');
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, validateBody, schemas } = require('../middleware/validation.middleware');
const config = require('../config/config');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Create directory if it doesn't exist
    const dir = path.join(config.upload.dir, 'training_imports');
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'training-import-' + uniqueSuffix + ext);
  }
});

// File filter to only allow certain document types
const fileFilter = (req, file, cb) => {
  // Allow only CSV files
  if (!['text/csv', 'application/vnd.ms-excel', 'application/csv'].includes(file.mimetype)) {
    return cb(new Error('Only CSV files are allowed'), false);
  }
  
  cb(null, true);
};

// Configure upload limits
const limits = {
  fileSize: 5 * 1024 * 1024 // 5MB limit for CSV files
};

// Initialize multer
const upload = multer({ storage, fileFilter, limits });

/**
 * @route   GET /api/training/register
 * @desc    Get training register entries
 * @access  Private (CDO, SUPER_USER)
 */
router.get('/register',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  async (req, res) => {
    try {
      const { 
        search,
        region_id,
        id_number,
        gender,
        sort_by = 'created_at',
        sort_order = 'desc',
        training_type
      } = req.query;
      
      // Build query
      let query = `
        SELECT tr.*, r.name as region_name, u.username as verifier_username
        FROM training_register tr
        LEFT JOIN regions r ON r.id = tr.region_id
        LEFT JOIN users u ON u.id = tr.verified_by
      `;
      
      // Build where clause
      const whereConditions = [];
      const params = [];
      
      // Filter by region for CDO
      if (req.user.role === 'CDO' && req.user.region_id) {
        whereConditions.push('tr.region_id = ?');
        params.push(req.user.region_id);
      } else if (region_id) {
        whereConditions.push('tr.region_id = ?');
        params.push(region_id);
      }
      
      // Filter by id_number
      if (id_number) {
        whereConditions.push('tr.id_number = ?');
        params.push(id_number);
      }
      
      // Filter by gender
      if (gender) {
        whereConditions.push('tr.gender = ?');
        params.push(gender);
      }
      
      // Filter by training_type
      if (training_type) {
        whereConditions.push('tr.training_type = ?');
        params.push(training_type);
      }
      
      // Search
      if (search) {
        whereConditions.push('(tr.first_name LIKE ? OR tr.surname LIKE ? OR tr.id_number LIKE ? OR tr.certificate_number LIKE ? OR tr.contact_number LIKE ?)');
        const searchParam = `%${search}%`;
        params.push(searchParam, searchParam, searchParam, searchParam, searchParam);
      }
      
      // Add where clause
      if (whereConditions.length > 0) {
        query += ' WHERE ' + whereConditions.join(' AND ');
      }
      
      // Add order by
      const allowedSortFields = ['created_at', 'first_name', 'surname', 'id_number', 'gender', 'training_date'];
      const sortField = allowedSortFields.includes(sort_by) ? sort_by : 'created_at';
      const order = sort_order.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
      query += ` ORDER BY tr.${sortField} ${order}`;
      
      // Execute query
      const data = await db.query(query, params);
      
      return res.status(200).json({
        success: true,
        data,
        total: data.length
      });
    } catch (error) {
      logger.error(`Get training register error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/training/register/:id
 * @desc    Get training register entry by ID
 * @access  Private (CDO, SUPER_USER)
 */
router.get('/register/:id',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const entryId = req.params.id;
      
      // Get training entry
      let entry = await db.getOne(
        `SELECT tr.*, r.name as region_name, u.username as verifier_username,
         u.first_name as verifier_first_name, u.last_name as verifier_last_name
         FROM training_register tr
         LEFT JOIN regions r ON r.id = tr.region_id
         LEFT JOIN users u ON u.id = tr.verified_by
         WHERE tr.id = ?`,
        [entryId]
      );
      
      if (!entry) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Training register entry not found'
        });
      }
      
      // If CDO, check if entry is in their region
      if (req.user.role === 'CDO' && req.user.region_id) {
        if (entry.region_id !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You do not have access to this training register entry'
          });
        }
      }
      
      // Get member verification matches
      const memberMatches = await db.query(
        `SELECT m.*, e.company_name as eog_name, e.id as eog_id,
         e.status as eog_status, vi.issue_type, vi.issue_description
         FROM eog_members m
         JOIN eogs e ON e.id = m.eog_id
         LEFT JOIN member_verification_issues vi 
           ON vi.eog_member_id = m.id 
           AND vi.training_register_id = ? 
           AND vi.resolved = false
         WHERE m.id_number = ?`,
        [entryId, entry.id_number]
      );
      
      entry.member_matches = memberMatches;
      
      return res.status(200).json({
        success: true,
        data: entry
      });
    } catch (error) {
      logger.error(`Get training entry error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/training/register
 * @desc    Create training register entry
 * @access  Private (CDO, SUPER_USER)
 */
router.post('/register',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  async (req, res) => {
    try {
      const {
        id_number,
        first_name,
        surname,
        gender,
        contact_number,
        region_id,
        training_date,
        training_type,
        certificate_number
      } = req.body;
      
      // Validate required fields
      if (!id_number || !first_name || !surname || !gender || !training_date || !training_type) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'id_number, first_name, surname, gender, training_date, and training_type are required'
        });
      }
      
      // Validate ID number format (13 digits)
      if (!/^\d{13}$/.test(id_number)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'ID number must be 13 digits'
        });
      }
      
      // Validate gender
      if (!['Male', 'Female'].includes(gender)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Gender must be either "Male" or "Female"'
        });
      }
      
      // Check if region_id exists
      if (region_id) {
        const region = await db.getOne(
          'SELECT * FROM regions WHERE id = ?',
          [region_id]
        );
        
        if (!region) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid region_id'
          });
        }
      }
      
      // For CDO, restrict to their region
      if (req.user.role === 'CDO' && req.user.region_id) {
        if (!region_id || region_id !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You can only add training entries for your region'
          });
        }
      }
      
      // Begin transaction
      const connection = await db.beginTransaction();
      
      try {
        // Check if ID number already exists for this training type
        const existingEntry = await connection.query(
          'SELECT * FROM training_register WHERE id_number = ? AND training_type = ?',
          [id_number, training_type]
        );
        
        if (existingEntry.length > 0) {
          // If entry exists, update it
          await connection.query(
            `UPDATE training_register SET
              first_name = ?,
              surname = ?,
              gender = ?,
              contact_number = ?,
              region_id = ?,
              training_date = ?,
              certificate_number = ?,
              verified_by = ?
             WHERE id_number = ? AND training_type = ?`,
            [
              first_name,
              surname,
              gender,
              contact_number || null,
              region_id || null,
              training_date,
              certificate_number || null,
              req.user.id,
              id_number,
              training_type
            ]
          );
          
          // Commit transaction
          await db.commit(connection);
          
          // Get updated entry
          const updatedEntry = await db.getOne(
            `SELECT tr.*, r.name as region_name
             FROM training_register tr
             LEFT JOIN regions r ON r.id = tr.region_id
             WHERE tr.id = ?`,
            [existingEntry[0].id]
          );
          
          // Log activity
          await logger.activity(
            req.user.id,
            'training_entry_updated',
            'training_register',
            existingEntry[0].id,
            { id_number, first_name, surname, training_type },
            req.ip,
            req.get('User-Agent')
          );
          
          return res.status(200).json({
            success: true,
            message: 'Training register entry updated',
            data: updatedEntry
          });
        }
        
        // Insert new entry
        const result = await connection.query(
          `INSERT INTO training_register (
            id_number, first_name, surname, gender, contact_number,
            region_id, training_date, training_type, certificate_number,
            verified_by
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            id_number,
            first_name,
            surname,
            gender,
            contact_number || null,
            region_id || null,
            training_date,
            training_type,
            certificate_number || null,
            req.user.id
          ]
        );
        
        const entryId = result[0].insertId;
        
        // Check for any pending member verification issues
        await connection.query(
          `UPDATE member_verification_issues vi
           JOIN eog_members m ON m.id = vi.eog_member_id
           SET vi.training_register_id = ?, 
               vi.issue_description = CONCAT(vi.issue_description, ' (Training record now available)')
           WHERE m.id_number = ? AND vi.issue_type = 'not_trained' AND vi.resolved = FALSE`,
          [entryId, id_number]
        );
        
        // Commit transaction
        await db.commit(connection);
        
        // Get created entry
        const entry = await db.getOne(
          `SELECT tr.*, r.name as region_name
           FROM training_register tr
           LEFT JOIN regions r ON r.id = tr.region_id
           WHERE tr.id = ?`,
          [entryId]
        );
        
        // Log activity
        await logger.activity(
          req.user.id,
          'training_entry_created',
          'training_register',
          entryId,
          { id_number, first_name, surname, training_type },
          req.ip,
          req.get('User-Agent')
        );
        
        return res.status(201).json({
          success: true,
          message: 'Training register entry created',
          data: entry
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Create training entry error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/training/register/:id
 * @desc    Update training register entry
 * @access  Private (CDO, SUPER_USER)
 */
router.put('/register/:id',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const entryId = req.params.id;
      const {
        id_number,
        first_name,
        surname,
        gender,
        contact_number,
        region_id,
        training_date,
        training_type,
        certificate_number
      } = req.body;
      
      // Get existing entry
      const entry = await db.getOne(
        'SELECT * FROM training_register WHERE id = ?',
        [entryId]
      );
      
      if (!entry) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Training register entry not found'
        });
      }
      
      // For CDO, restrict to their region
      if (req.user.role === 'CDO' && req.user.region_id) {
        if (entry.region_id !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You can only update training entries for your region'
          });
        }
        
        // Ensure they can't change region
        if (region_id && region_id !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You cannot change the region of a training entry'
          });
        }
      }
      
      // Check if region_id exists
      if (region_id) {
        const region = await db.getOne(
          'SELECT * FROM regions WHERE id = ?',
          [region_id]
        );
        
        if (!region) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid region_id'
          });
        }
      }
      
      // Validate ID number format if changed (13 digits)
      if (id_number && !/^\d{13}$/.test(id_number)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'ID number must be 13 digits'
        });
      }
      
      // Validate gender if changed
      if (gender && !['Male', 'Female'].includes(gender)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Gender must be either "Male" or "Female"'
        });
      }
      
      // Begin transaction
      const connection = await db.beginTransaction();
      
      try {
        // Check if ID number is changing and already exists for this training type
        if (id_number && id_number !== entry.id_number) {
          const existingEntry = await connection.query(
            'SELECT * FROM training_register WHERE id_number = ? AND training_type = ? AND id != ?',
            [id_number, training_type || entry.training_type, entryId]
          );
          
          if (existingEntry.length > 0) {
            return res.status(400).json({
              success: false,
              error: 'Validation Error',
              message: 'A training entry for this ID number and training type already exists'
            });
          }
        }
        
        // Update entry
        const updateData = {};
        if (id_number) updateData.id_number = id_number;
        if (first_name) updateData.first_name = first_name;
        if (surname) updateData.surname = surname;
        if (gender) updateData.gender = gender;
        if (contact_number !== undefined) updateData.contact_number = contact_number || null;
        if (region_id) updateData.region_id = region_id;
        if (training_date) updateData.training_date = training_date;
        if (training_type) updateData.training_type = training_type;
        if (certificate_number !== undefined) updateData.certificate_number = certificate_number || null;
        
        // Set verified_by to current user
        updateData.verified_by = req.user.id;
        
        await db.update('training_register',
          updateData,
          'id = ?',
          [entryId]
        );
        
        // If ID number is changing, update member verification issues
        if (id_number && id_number !== entry.id_number) {
          // Remove training_register_id reference from old ID
          await connection.query(
            `UPDATE member_verification_issues
             SET training_register_id = NULL
             WHERE training_register_id = ?`,
            [entryId]
          );
          
          // Check for any pending member verification issues for new ID
          await connection.query(
            `UPDATE member_verification_issues vi
             JOIN eog_members m ON m.id = vi.eog_member_id
             SET vi.training_register_id = ?, 
                 vi.issue_description = CONCAT(vi.issue_description, ' (Training record now available)')
             WHERE m.id_number = ? AND vi.issue_type = 'not_trained' AND vi.resolved = FALSE`,
            [entryId, id_number]
          );
        }
        
        // Commit transaction
        await db.commit(connection);
        
        // Get updated entry
        const updatedEntry = await db.getOne(
          `SELECT tr.*, r.name as region_name
           FROM training_register tr
           LEFT JOIN regions r ON r.id = tr.region_id
           WHERE tr.id = ?`,
          [entryId]
        );
        
        // Log activity
        await logger.activity(
          req.user.id,
          'training_entry_updated',
          'training_register',
          entryId,
          updateData,
          req.ip,
          req.get('User-Agent')
        );
        
        return res.status(200).json({
          success: true,
          message: 'Training register entry updated',
          data: updatedEntry
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Update training entry error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/training/register/:id
 * @desc    Delete training register entry
 * @access  Private (SUPER_USER only)
 */
router.delete('/register/:id',
  authenticate,
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const entryId = req.params.id;
      
      // Get existing entry
      const entry = await db.getOne(
        'SELECT * FROM training_register WHERE id = ?',
        [entryId]
      );
      
      if (!entry) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Training register entry not found'
        });
      }
      
      // Begin transaction
      const connection = await db.beginTransaction();
      
      try {
        // Check if entry is referenced in member verification issues
        const issuesCount = await connection.query(
          'SELECT COUNT(*) as count FROM member_verification_issues WHERE training_register_id = ?',
          [entryId]
        );
        
        if (issuesCount[0].count > 0) {
          // Update issues to remove reference to training record
          await connection.query(
            `UPDATE member_verification_issues
             SET training_register_id = NULL,
                 issue_description = CONCAT(issue_description, ' (Training record was deleted)')
             WHERE training_register_id = ?`,
            [entryId]
          );
          
          // Create new issues for members with this ID number
          await connection.query(
            `INSERT INTO member_verification_issues (
               eog_member_id, issue_type, issue_description, reported_by
             )
             SELECT m.id, 'not_trained', 'Training record was deleted', ?
             FROM eog_members m
             WHERE m.id_number = ? AND m.verification_status = 'pending'`,
            [req.user.id, entry.id_number]
          );
        }
        
        // Delete entry
        await connection.query(
          'DELETE FROM training_register WHERE id = ?',
          [entryId]
        );
        
        // Commit transaction
        await db.commit(connection);
        
        // Log activity
        await logger.activity(
          req.user.id,
          'training_entry_deleted',
          'training_register',
          entryId,
          { id_number: entry.id_number, name: `${entry.first_name} ${entry.surname}` },
          req.ip,
          req.get('User-Agent')
        );
        
        return res.status(200).json({
          success: true,
          message: 'Training register entry deleted'
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Delete training entry error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/training/register/import
 * @desc    Import training register entries from CSV
 * @access  Private (CDO, SUPER_USER)
 */
router.post('/register/import',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  upload.single('file'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'CSV file is required'
        });
      }
      
      const { training_type, region_id } = req.body;
      
      if (!training_type) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'training_type is required'
        });
      }
      
      // For CDO, restrict to their region
      if (req.user.role === 'CDO' && req.user.region_id) {
        if (!region_id || parseInt(region_id) !== req.user.region_id) {
          return res.status(403).json({
            success: false,
            error: 'Forbidden',
            message: 'You can only import training entries for your region'
          });
        }
      }
      
      // Check if region_id exists
      if (region_id) {
        const region = await db.getOne(
          'SELECT * FROM regions WHERE id = ?',
          [region_id]
        );
        
        if (!region) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid region_id'
          });
        }
      }
      
      // Parse CSV file
      const rows = [];
      const errors = [];
      
      const parseStream = fs.createReadStream(req.file.path)
        .pipe(parse({ headers: true, ignoreEmpty: true }))
        .on('error', error => {
          logger.error(`CSV parse error: ${error.message}`);
          errors.push(`CSV parse error: ${error.message}`);
        })
        .on('data', row => {
          // Validate row
          if (!row.id_number || !row.first_name || !row.surname || !row.gender || !row.training_date) {
            errors.push(`Row with ID ${row.id_number || 'unknown'} is missing required fields`);
            return;
          }
          
          // Validate ID number format (13 digits)
          if (!/^\d{13}$/.test(row.id_number)) {
            errors.push(`Row with ID ${row.id_number} has invalid ID number format`);
            return;
          }
          
          // Validate gender
          if (!['Male', 'Female'].includes(row.gender)) {
            errors.push(`Row with ID ${row.id_number} has invalid gender`);
            return;
          }
          
          // Format training date (expecting MM/DD/YYYY or YYYY-MM-DD)
          let trainingDate;
          try {
            trainingDate = new Date(row.training_date);
            if (isNaN(trainingDate)) {
              errors.push(`Row with ID ${row.id_number} has invalid training date`);
              return;
            }
          } catch (error) {
            errors.push(`Row with ID ${row.id_number} has invalid training date`);
            return;
          }
          
          // Add to rows
          rows.push({
            id_number: row.id_number,
            first_name: row.first_name,
            surname: row.surname,
            gender: row.gender,
            contact_number: row.contact_number || null,
            training_date: trainingDate.toISOString().split('T')[0],
            certificate_number: row.certificate_number || null
          });
        });
      
      // Wait for CSV parsing to complete
      await new Promise((resolve, reject) => {
        parseStream.on('end', resolve);
        parseStream.on('error', reject);
      });
      
      // Remove temporary file
      fs.unlinkSync(req.file.path);
      
      // Check if any rows were parsed
      if (rows.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'No valid rows found in CSV file',
          errors
        });
      }
      
      // Begin transaction
      const connection = await db.beginTransaction();
      
      try {
        const results = {
          total: rows.length,
          created: 0,
          updated: 0,
          failed: 0,
          errors: []
        };
        
        // Process each row
        for (const row of rows) {
          try {
            // Check if entry already exists
            const existingEntry = await connection.query(
              'SELECT * FROM training_register WHERE id_number = ? AND training_type = ?',
              [row.id_number, training_type]
            );
            
            if (existingEntry.length > 0) {
              // Update existing entry
              await connection.query(
                `UPDATE training_register SET
                  first_name = ?,
                  surname = ?,
                  gender = ?,
                  contact_number = ?,
                  region_id = ?,
                  training_date = ?,
                  certificate_number = ?,
                  verified_by = ?
                 WHERE id = ?`,
                [
                  row.first_name,
                  row.surname,
                  row.gender,
                  row.contact_number,
                  region_id || null,
                  row.training_date,
                  row.certificate_number,
                  req.user.id,
                  existingEntry[0].id
                ]
              );
              
              results.updated++;
            } else {
              // Insert new entry
              await connection.query(
                `INSERT INTO training_register (
                  id_number, first_name, surname, gender, contact_number,
                  region_id, training_date, training_type, certificate_number,
                  verified_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                  row.id_number,
                  row.first_name,
                  row.surname,
                  row.gender,
                  row.contact_number,
                  region_id || null,
                  row.training_date,
                  training_type,
                  row.certificate_number,
                  req.user.id
                ]
              );
              
              const entryId = (await connection.query('SELECT LAST_INSERT_ID() as id'))[0].id;
              
              // Check for any pending member verification issues
              await connection.query(
                `UPDATE member_verification_issues vi
                 JOIN eog_members m ON m.id = vi.eog_member_id
                 SET vi.training_register_id = ?, 
                     vi.issue_description = CONCAT(vi.issue_description, ' (Training record now available)')
                 WHERE m.id_number = ? AND vi.issue_type = 'not_trained' AND vi.resolved = FALSE`,
                [entryId, row.id_number]
              );
              
              results.created++;
            }
          } catch (error) {
            logger.error(`Error processing row with ID ${row.id_number}: ${error.message}`);
            results.errors.push(`Error processing row with ID ${row.id_number}: ${error.message}`);
            results.failed++;
          }
        }
        
        // Commit transaction
        await db.commit(connection);
        
        // Log activity
        await logger.activity(
          req.user.id,
          'training_entries_imported',
          'training_register',
          null,
          { 
            training_type, 
            region_id, 
            total: results.total,
            created: results.created,
            updated: results.updated
          },
          req.ip,
          req.get('User-Agent')
        );
        
        return res.status(200).json({
          success: true,
          message: 'Training register entries imported',
          data: results
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Import training entries error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/training/types
 * @desc    Get training types
 * @access  Public
 */
router.get('/types', async (req, res) => {
  try {
    // Get distinct training types
    const types = await db.query(
      'SELECT DISTINCT training_type FROM training_register WHERE training_type IS NOT NULL ORDER BY training_type'
    );
    
    return res.status(200).json({
      success: true,
      data: types.map(t => t.training_type)
    });
  } catch (error) {
    logger.error(`Get training types error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/training/verify/:idNumber
 * @desc    Verify ID number in training register
 * @access  Private (CDO)
 */
router.get('/verify/:idNumber',
  authenticate,
  requireRole(['CDO', 'SUPER_USER']),
  async (req, res) => {
    try {
      const idNumber = req.params.idNumber;
      
      // Validate ID number format (13 digits)
      if (!/^\d{13}$/.test(idNumber)) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'ID number must be 13 digits'
        });
      }
      
      // Get training records for this ID number
      let trainingRecords;
      
      if (req.user.role === 'CDO' && req.user.region_id) {
        // CDO can only see records in their region
        trainingRecords = await db.query(
          `SELECT tr.*, r.name as region_name
           FROM training_register tr
           LEFT JOIN regions r ON r.id = tr.region_id
           WHERE tr.id_number = ? AND (tr.region_id = ? OR tr.region_id IS NULL)
           ORDER BY tr.training_date DESC`,
          [idNumber, req.user.region_id]
        );
      } else {
        // SUPER_USER can see all records
        trainingRecords = await db.query(
          `SELECT tr.*, r.name as region_name
           FROM training_register tr
           LEFT JOIN regions r ON r.id = tr.region_id
           WHERE tr.id_number = ?
           ORDER BY tr.training_date DESC`,
          [idNumber]
        );
      }
      
      return res.status(200).json({
        success: true,
        data: {
          id_number: idNumber,
          records: trainingRecords,
          verified: trainingRecords.length > 0
        }
      });
    } catch (error) {
      logger.error(`Verify ID number error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;
