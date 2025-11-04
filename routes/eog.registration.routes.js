const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const db = require('../utils/db');
const bcryptUtils = require('../utils/bcrypt');
const emailUtils = require('../utils/email');
const logger = require('../utils/logger');
const { authenticate, optionalAuth } = require('../middleware/auth.middleware');
const { requireRole, requireEOGOwnership } = require('../middleware/role.middleware');
const { validateBody, validateParams, schemas } = require('../middleware/validation.middleware');
const config = require('../config/config');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // For expression of interest, use temporary directory since we don't have eogId yet
    const tempDir = path.join(config.upload.dir, 'temp_eog_documents');
    fs.mkdirSync(tempDir, { recursive: true });
    cb(null, tempDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// File filter to only allow certain document types
const fileFilter = (req, file, cb) => {
  // Allow only PDF files for documents
  if (file.fieldname !== 'member_list' && file.mimetype !== 'application/pdf') {
    return cb(new Error('Only PDF files are allowed'), false);
  }

  // Allow Excel files for member list
  if (file.fieldname === 'member_list' &&
    !['application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.oasis.opendocument.spreadsheet',
      'text/csv'].includes(file.mimetype)) {
    return cb(new Error('Only Excel or CSV files are allowed for member list'), false);
  }

  cb(null, true);
};

// Configure upload limits
const limits = {
  fileSize: config.upload.maxFileSize
};

// Initialize multer
const upload = multer({ storage, fileFilter, limits });

/**
 * @route   POST /api/registration/expression-of-interest
 * @desc    Create EOG with documents upload (multipart form-data)
 * @access  Public
 */
router.post(
  '/expression-of-interest',
  upload.fields([
    { name: 'constitution', maxCount: 1 },
    { name: 'recognition_letter', maxCount: 1 },
    { name: 'articles', maxCount: 1 },
    { name: 'form_j', maxCount: 1 },
    { name: 'certificate', maxCount: 1 },
    { name: 'member_list', maxCount: 1 },
  ]),
  async (req, res) => {
    try {
      const {
        company_name,
        company_type,
        bin_cin,
        email,
        phone,
        region_id,
        tinkhundla_id,
        umphakatsi_id,
        total_members
      } = req.body;

      // Validate required fields
      if (!company_name || !company_type || !bin_cin || !email || !phone ||
          !region_id || !tinkhundla_id || !umphakatsi_id || !total_members) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'All fields are required'
        });
      }

      // Validate that required documents are uploaded
      const requiredDocs = ['constitution', 'recognition_letter', 'articles', 
        'form_j', 'certificate', 'member_list'];
      const missingDocs = requiredDocs.filter(doc => !req.files[doc]);

      if (missingDocs.length > 0) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Missing required documents: ${missingDocs.join(', ')}`
        });
      }

      // Check if company name already exists
      const existingCompany = await db.getOne(
        'SELECT id FROM eogs WHERE company_name = ?',
        [company_name]
      );

      if (existingCompany) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Company name already exists'
        });
      }

      // Check if BIN/CIN already exists
      const existingBinCin = await db.getOne(
        'SELECT id FROM eogs WHERE bin_cin = ?',
        [bin_cin]
      );

      if (existingBinCin) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'BIN/CIN already exists'
        });
      }

      // Check if email already exists
      const existingEmail = await db.getOne(
        'SELECT id FROM eogs WHERE email = ?',
        [email]
      );

      if (existingEmail) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Email already exists'
        });
      }

      // Validate region, tinkhundla, and umphakatsi
      const region = await db.getOne(
        'SELECT * FROM regions WHERE id = ?',
        [region_id]
      );

      if (!region) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid region'
        });
      }

      const tinkhundla = await db.getOne(
        'SELECT * FROM tinkhundla WHERE id = ? AND region_id = ?',
        [tinkhundla_id, region_id]
      );

      if (!tinkhundla) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid tinkhundla or tinkhundla not in selected region'
        });
      }

      const umphakatsi = await db.getOne(
        'SELECT * FROM imiphakatsi WHERE id = ? AND tinkhundla_id = ?',
        [umphakatsi_id, tinkhundla_id]
      );

      if (!umphakatsi) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid umphakatsi or umphakatsi not in selected tinkhundla'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Set account expiry date (30 days from now)
        const expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + 30);

        // Create EOG
        const eogResult = await connection.query(
          `INSERT INTO eogs (
            company_name, company_type, bin_cin, email, phone,
            region_id, tinkhundla_id, umphakatsi_id,
            status, temp_account_expires, total_members
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            company_name, company_type, bin_cin, email, phone,
            region_id, tinkhundla_id, umphakatsi_id,
            'temporary', expiryDate, total_members
          ]
        );

        const eogId = eogResult[0].insertId;

        // Save uploaded documents
        const documentTypes = ['constitution', 'recognition_letter', 'articles', 
                              'form_j', 'certificate', 'member_list'];
        
        for (const docType of documentTypes) {
          if (req.files[docType] && req.files[docType][0]) {
            const file = req.files[docType][0];
            
            await connection.query(
              `INSERT INTO eog_documents (
                eog_id, document_type, file_name, file_path, file_size, mime_type, status
              ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
              [
                eogId,
                docType,
                file.originalname,
                file.path,
                file.size,
                file.mimetype,
                'pending_review'
              ]
            );
          }
        }

        // Generate temporary username
        const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
        const randomNum = Math.floor(1000 + Math.random() * 9000);
        const username = `temp_${dateStr}_${randomNum}`;

        // Generate temporary password
        const tempPassword = bcryptUtils.generateRandomPassword(10);

        // Hash password
        const hashedPassword = await bcryptUtils.hashPassword(tempPassword);

        // Create temporary user
        const userResult = await connection.query(
          `INSERT INTO users (
            username, email, password, role, first_name, last_name,
            phone, status, region_id, tinkhundla_id, umphakatsi_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            username, email, hashedPassword, 'EOG',
            company_name, company_type,
            phone, 'temporary', region_id, tinkhundla_id, umphakatsi_id
          ]
        );

        const userId = userResult[0].insertId;

        // Link EOG to user
        await connection.query(
          `INSERT INTO eog_users (eog_id, user_id, is_primary_contact)
           VALUES (?, ?, ?)`,
          [eogId, userId, true]
        );

        // Log registration activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId, 'registration_completed',
            'EOG created account with documents uploaded',
            userId, req.ip
          ]
        );

        // Create notification preferences
        await connection.query(
          `INSERT INTO user_notification_preferences (
            user_id, email_notifications, sms_notifications,
            application_updates, committee_reminders, system_announcements
          ) VALUES (?, ?, ?, ?, ?, ?)`,
          [userId, true, false, true, true, true]
        );

        // Commit transaction
        await db.commit(connection);

        // Send credentials via email
        const user = {
          id: userId,
          email,
          first_name: company_name,
          last_name: '',
          username
        };

        await emailUtils.sendWelcomeEmail(user, tempPassword);

        // Return success
        return res.status(201).json({
          success: true,
          message: 'Account created successfully. Check your email for login credentials.',
          data: {
            eog_id: eogId,
            expires_at: expiryDate,
            days_remaining: 30,
            next_steps: [
              'Check your email for login credentials',
              'Login to your account',
              'Add executive members (minimum 10)',
              'Submit for CDO review'
            ]
          }
        });
      } catch (error) {
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Expression of interest error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/registration/:eogId/status
 * @desc    Check EOG registration status
 * @access  Private (EOG owner or CDO)
 */
router.get('/:eogId/status',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Get EOG details from view
      const eog = await db.getOne(
        'SELECT * FROM v_temporal_eogs WHERE id = ?',
        [eogId]
      );

      if (!eog) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'EOG not found'
        });
      }

      // Get document counts
      const documents = await db.query(
        `SELECT document_type, COUNT(*) as count
         FROM eog_documents
         WHERE eog_id = ?
         GROUP BY document_type`,
        [eogId]
      );

      // Format document status
      const documentStatus = {
        constitution: 0,
        recognition_letter: 0,
        articles: 0,
        form_j: 0,
        certificate: 0,
        member_list: 0
      };

      documents.forEach(doc => {
        documentStatus[doc.document_type] = doc.count;
      });

      // Get member counts
      const memberCounts = await db.getOne(
        `SELECT
           COUNT(*) as total_members,
           SUM(CASE WHEN is_executive = TRUE THEN 1 ELSE 0 END) as executive_members,
           SUM(CASE WHEN is_executive = TRUE AND verification_status = 'verified' THEN 1 ELSE 0 END) as verified_executives
         FROM eog_members
         WHERE eog_id = ?`,
        [eogId]
      );

      // Get recent activities
      const activities = await db.query(
        `SELECT * FROM eog_temporal_activity
         WHERE eog_id = ?
         ORDER BY created_at DESC
         LIMIT 10`,
        [eogId]
      );

      // Calculate completion percentages
      const requiredDocuments = 5; // Constitution, Recognition Letter, Articles, Form J, Certificate
      const documentsUploaded = Object.values(documentStatus).reduce((sum, count) => sum + (count > 0 ? 1 : 0), 0) - (documentStatus.member_list > 0 ? 1 : 0);

      const documentsPercentage = (documentsUploaded / requiredDocuments) * 100;
      const membersPercentage = Math.min((memberCounts.executive_members / 10) * 100, 100);

      const overallCompletion = (documentsPercentage + membersPercentage) / 2;

      // Check if ready for submission
      const readyForSubmission = documentsUploaded === requiredDocuments && memberCounts.executive_members >= 10;

      return res.status(200).json({
        success: true,
        data: {
          eog,
          documents: documentStatus,
          members: memberCounts,
          activities,
          completion: {
            documents: documentsPercentage,
            members: membersPercentage,
            overall: overallCompletion
          },
          ready_for_submission: readyForSubmission,
          days_remaining: eog.days_remaining
        }
      });
    } catch (error) {
      logger.error(`EOG status check error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/registration/:eogId/documents
 * @desc    Upload EOG documents
 * @access  Private (EOG owner)
 */
router.post('/:eogId/documents',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  (req, res, next) => {
    // Check if EOG is in temporal status
    db.getOne(
      'SELECT status FROM eogs WHERE id = ? AND status = ?',
      [req.params.eogId, 'temporary']
    ).then(eog => {
      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG must be in temporary status to upload documents'
        });
      }
      next();
    }).catch(error => {
      next(error);
    });
  },
  upload.fields([
    { name: 'constitution', maxCount: 1 },
    { name: 'recognition_letter', maxCount: 1 },
    { name: 'articles', maxCount: 1 },
    { name: 'form_j', maxCount: 1 },
    { name: 'certificate', maxCount: 1 },
    { name: 'member_list', maxCount: 1 }
  ]),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Validate that files were uploaded
      if (!req.files || Object.keys(req.files).length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'No files were uploaded'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Process each uploaded document
        const uploadedDocuments = [];

        for (const [fieldName, files] of Object.entries(req.files)) {
          const file = files[0]; // Only one file per field

          // Convert field name to document_type enum
          const documentType = fieldName;

          // Delete any existing documents of this type
          await connection.query(
            'DELETE FROM eog_documents WHERE eog_id = ? AND document_type = ?',
            [eogId, documentType]
          );

          // Save document metadata to database
          const docResult = await connection.query(
            `INSERT INTO eog_documents (
              eog_id, document_type, file_name, file_path, file_size
            ) VALUES (?, ?, ?, ?, ?)`,
            [
              eogId,
              documentType,
              file.originalname,
              file.path.replace(/\\/g, '/').replace(/^.*\/uploads\//, '/uploads/'), // Store relative path
              file.size
            ]
          );

          // Log activity
          await connection.query(
            `INSERT INTO eog_temporal_activity (
              eog_id, activity_type, description, performed_by, ip_address
            ) VALUES (?, ?, ?, ?, ?)`,
            [
              eogId,
              'document_uploaded',
              `Uploaded ${documentType} document: ${file.originalname}`,
              req.user.id,
              req.ip
            ]
          );

          uploadedDocuments.push({
            id: docResult[0].insertId,
            document_type: documentType,
            file_name: file.originalname,
            file_size: file.size
          });
        }

        // Commit transaction
        await db.commit(connection);

        // Return success
        return res.status(200).json({
          success: true,
          message: 'Documents uploaded successfully',
          data: {
            documents: uploadedDocuments
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Document upload error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/registration/:eogId/documents
 * @desc    List EOG documents
 * @access  Private (EOG owner or CDO)
 */
router.get('/:eogId/documents',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Get all documents for the EOG
      const documents = await db.query(
        `SELECT id, document_type, file_name, file_path, file_size, uploaded_at
         FROM eog_documents
         WHERE eog_id = ?
         ORDER BY document_type, uploaded_at DESC`,
        [eogId]
      );

      return res.status(200).json({
        success: true,
        data: {
          documents
        }
      });
    } catch (error) {
      logger.error(`Get documents error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/registration/:eogId/documents/:docId
 * @desc    Delete EOG document
 * @access  Private (EOG owner)
 */
router.delete('/:eogId/documents/:docId',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const docId = req.params.docId;

      // Check if EOG is in temporal status
      const eog = await db.getOne(
        'SELECT status FROM eogs WHERE id = ?',
        [eogId]
      );

      // if (eog.status !== 'temporary') {
      //   return res.status(400).json({
      //     success: false,
      //     error: 'Bad Request',
      //     message: 'EOG must be in temporary status to delete documents'
      //   });
      // }

      // Get document details
      const document = await db.getOne(
        `SELECT * FROM eog_documents
         WHERE id = ? AND eog_id = ?`,
        [docId, eogId]
      );

      if (!document) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Document not found or does not belong to this EOG'
        });
      }

      // Delete document from database
      await db.delete('eog_documents',
        'id = ? AND eog_id = ?',
        [docId, eogId]
      );

      // Log activity
      await db.insert('eog_temporal_activity', {
        eog_id: eogId,
        activity_type: 'document_deleted',
        description: `Deleted ${document.document_type} document: ${document.file_name}`,
        performed_by: req.user.id,
        ip_address: req.ip
      });

      // Try to delete file from filesystem (don't fail if file doesn't exist)
      try {
        const filePath = path.join(process.cwd(), document.file_path);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      } catch (fileError) {
        logger.warn(`Failed to delete document file: ${fileError.message}`);
      }

      return res.status(200).json({
        success: true,
        message: 'Document deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete document error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/registration/:eogId/members
 * @desc    Add EOG executive member
 * @access  Private (EOG owner)
 */
router.post('/:eogId/members',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  validateBody(schemas.eogMember),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const {
        id_number,
        first_name,
        surname,
        gender,
        contact_number,
        position
      } = req.body;

      // Check if EOG is in temporal status
      const eog = await db.getOne(
        'SELECT status FROM eogs WHERE id = ?',
        [eogId]
      );

      if (eog.status !== 'temporary') {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG must be in temporary status to add members'
        });
      }

      // Check if member already exists in this EOG
      const existingMember = await db.getOne(
        'SELECT * FROM eog_members WHERE eog_id = ? AND id_number = ?',
        [eogId, id_number]
      );

      if (existingMember) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Member with this ID number already exists in this EOG'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Save member
        const memberResult = await connection.query(
          `INSERT INTO eog_members (
            eog_id, id_number, first_name, surname, gender,
            contact_number, position, is_executive,
            verification_status
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            eogId, id_number, first_name, surname, gender,
            contact_number, position, true, // is_executive=true
            'pending' // verification_status=pending
          ]
        );

        const memberId = memberResult[0].insertId;

        // Auto pre-check against training register
        const trainingRecord = await connection.query(
          `SELECT * FROM training_register 
           WHERE id_number = ?`,
          [id_number]
        );

        // If found, check name/gender match
        if (trainingRecord.length > 0) {
          const training = trainingRecord[0];

          // Check if name and gender match
          const nameMatches = training.first_name && training.surname &&
            first_name && surname &&
            training.first_name.toLowerCase() === first_name.toLowerCase() &&
            training.surname.toLowerCase() === surname.toLowerCase();
          const genderMatches = training.gender && gender && training.gender === gender;

          // If issues, log verification issues
          if (!nameMatches || !genderMatches) {
            await connection.query(
              `INSERT INTO member_verification_issues (
                eog_member_id, issue_type, issue_description,
                training_register_id, reported_by
              ) VALUES (?, ?, ?, ?, ?)`,
              [
                memberId,
                !nameMatches ? 'name_mismatch' : 'gender_mismatch',
                !nameMatches ?
                  `Name mismatch: Member (${first_name} ${surname}) vs Training (${training.first_name} ${training.surname})` :
                  `Gender mismatch: Member (${gender}) vs Training (${training.gender})`,
                training.id,
                null // System pre-check
              ]
            );
          }
        } else {
          // No training record found
          await connection.query(
            `INSERT INTO member_verification_issues (
              eog_member_id, issue_type, issue_description,
              reported_by
            ) VALUES (?, ?, ?, ?)`,
            [
              memberId,
              'not_trained',
              'No training record found for this ID number',
              null // System pre-check
            ]
          );
        }

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'member_added',
            `Added executive member: ${first_name} ${surname} (${position})`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Get member with verification status
        const member = await db.getOne(
          `SELECT m.*, 
             CASE 
               WHEN vi.id IS NULL THEN 0
               ELSE 1
             END as has_issues
           FROM eog_members m
           LEFT JOIN member_verification_issues vi ON vi.eog_member_id = m.id
           WHERE m.id = ?`,
          [memberId]
        );

        return res.status(201).json({
          success: true,
          message: 'Executive member added successfully',
          data: {
            member
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Add member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/registration/:eogId/members
 * @desc    List EOG members
 * @access  Private (EOG owner or CDO)
 */
router.get('/:eogId/members',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Get all members for the EOG
      const members = await db.query(
        `SELECT m.*, 
           CASE 
             WHEN vi.id IS NULL THEN 0
             ELSE 1
           END as has_issues
         FROM eog_members m
         LEFT JOIN (
           SELECT eog_member_id, MIN(id) as id
           FROM member_verification_issues
           WHERE resolved = false
           GROUP BY eog_member_id
         ) vi ON vi.eog_member_id = m.id
         WHERE m.eog_id = ?
         ORDER BY m.is_executive DESC, m.first_name, m.surname`,
        [eogId]
      );

      // Get issue counts
      const issueCounts = await db.getOne(
        `SELECT 
           COUNT(*) as total_issues,
           SUM(CASE WHEN resolved = false THEN 1 ELSE 0 END) as unresolved_issues
         FROM member_verification_issues vi
         JOIN eog_members m ON m.id = vi.eog_member_id
         WHERE m.eog_id = ?`,
        [eogId]
      );

      return res.status(200).json({
        success: true,
        data: {
          members,
          issues: issueCounts || { total_issues: 0, unresolved_issues: 0 }
        }
      });
    } catch (error) {
      logger.error(`Get members error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/registration/:eogId/members/:memberId
 * @desc    Update EOG member
 * @access  Private (EOG owner)
 */
router.put('/:eogId/members/:memberId',
  authenticate,
  validateParams(schemas.eogIdParam),
  validateParams(schemas.memberIdParam),
  requireEOGOwnership,
  validateBody(schemas.eogMember),
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const memberId = req.params.memberId;

      const {
        id_number,
        first_name,
        surname,
        gender,
        contact_number,
        position
      } = req.body;

      // Check if EOG is in temporal status
      const eog = await db.getOne(
        'SELECT status FROM eogs WHERE id = ?',
        [eogId]
      );

      if (eog.status !== 'temporary') {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG must be in temporary status to update members'
        });
      }

      // Check if member exists and belongs to this EOG
      const member = await db.getOne(
        'SELECT * FROM eog_members WHERE id = ? AND eog_id = ?',
        [memberId, eogId]
      );

      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found or does not belong to this EOG'
        });
      }

      // Check if ID number is being changed and already exists in this EOG
      if (id_number !== member.id_number) {
        const existingMember = await db.getOne(
          'SELECT * FROM eog_members WHERE eog_id = ? AND id_number = ? AND id != ?',
          [eogId, id_number, memberId]
        );

        if (existingMember) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Another member with this ID number already exists in this EOG'
          });
        }
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update member
        await connection.query(
          `UPDATE eog_members SET
             id_number = ?,
             first_name = ?,
             surname = ?,
             gender = ?,
             contact_number = ?,
             position = ?,
             verification_status = ?
           WHERE id = ? AND eog_id = ?`,
          [
            id_number,
            first_name,
            surname,
            gender,
            contact_number,
            position,
            // Reset verification status if any personal info changes
            id_number !== member.id_number ||
              first_name !== member.first_name ||
              surname !== member.surname ||
              gender !== member.gender ? 'pending' : member.verification_status,
            memberId,
            eogId
          ]
        );

        // If key fields changed, remove old verification issues and run pre-checks again
        if (id_number !== member.id_number ||
          first_name !== member.first_name ||
          surname !== member.surname ||
          gender !== member.gender) {

          // Remove old verification issues
          await connection.query(
            'DELETE FROM member_verification_issues WHERE eog_member_id = ?',
            [memberId]
          );

          // Auto pre-check against training register
          const trainingRecord = await connection.query(
            'SELECT * FROM training_register WHERE id_number = ?',
            [id_number]
          );

          // If found, check name/gender match
          if (trainingRecord.length > 0) {
            const training = trainingRecord[0];

            // Check if name and gender match
            const nameMatches = training.first_name.toLowerCase() === first_name.toLowerCase() &&
              training.surname.toLowerCase() === surname.toLowerCase();
            const genderMatches = training.gender === gender;

            // If issues, log verification issues
            if (!nameMatches || !genderMatches) {
              await connection.query(
                `INSERT INTO member_verification_issues (
                  eog_member_id, issue_type, issue_description,
                  training_register_id, reported_by
                ) VALUES (?, ?, ?, ?, ?)`,
                [
                  memberId,
                  !nameMatches ? 'name_mismatch' : 'gender_mismatch',
                  !nameMatches ?
                    `Name mismatch: Member (${first_name} ${surname}) vs Training (${training.first_name} ${training.surname})` :
                    `Gender mismatch: Member (${gender}) vs Training (${training.gender})`,
                  training.id,
                  null // System pre-check
                ]
              );
            }
          } else {
            // No training record found
            await connection.query(
              `INSERT INTO member_verification_issues (
                eog_member_id, issue_type, issue_description,
                reported_by
              ) VALUES (?, ?, ?, ?)`,
              [
                memberId,
                'not_trained',
                'No training record found for this ID number',
                null // System pre-check
              ]
            );
          }
        }

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'member_updated',
            `Updated member: ${first_name} ${surname} (${position})`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        // Get updated member with verification status
        const updatedMember = await db.getOne(
          `SELECT m.*, 
             CASE 
               WHEN vi.id IS NULL THEN 0
               ELSE 1
             END as has_issues
           FROM eog_members m
           LEFT JOIN member_verification_issues vi ON vi.eog_member_id = m.id
           WHERE m.id = ?`,
          [memberId]
        );

        return res.status(200).json({
          success: true,
          message: 'Member updated successfully',
          data: {
            member: updatedMember
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Update member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/registration/:eogId/members/:memberId
 * @desc    Remove EOG member
 * @access  Private (EOG owner)
 */
router.delete('/:eogId/members/:memberId',
  authenticate,
  validateParams(schemas.eogIdParam),
  validateParams(schemas.memberIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;
      const memberId = req.params.memberId;

      // Check if EOG is in temporal status
      const eog = await db.getOne(
        'SELECT status FROM eogs WHERE id = ?',
        [eogId]
      );

      if (eog.status !== 'temporary') {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG must be in temporary status to remove members'
        });
      }

      // Check if member exists and belongs to this EOG
      const member = await db.getOne(
        'SELECT * FROM eog_members WHERE id = ? AND eog_id = ?',
        [memberId, eogId]
      );

      if (!member) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Member not found or does not belong to this EOG'
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // First delete any verification issues
        await connection.query(
          'DELETE FROM member_verification_issues WHERE eog_member_id = ?',
          [memberId]
        );

        // Delete member
        await connection.query(
          'DELETE FROM eog_members WHERE id = ? AND eog_id = ?',
          [memberId, eogId]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'member_removed',
            `Removed member: ${member.first_name} ${member.surname} (${member.position})`,
            req.user.id,
            req.ip
          ]
        );

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'Member removed successfully'
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Remove member error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   POST /api/registration/:eogId/submit
 * @desc    Submit EOG for CDO review
 * @access  Private (EOG owner)
 */
router.post('/:eogId/submit',
  authenticate,
  validateParams(schemas.eogIdParam),
  requireEOGOwnership,
  async (req, res) => {
    try {
      const eogId = req.params.eogId;

      // Check if EOG is in temporal status
      const eog = await db.getOne(
        'SELECT * FROM eogs WHERE id = ? AND status = ?',
        [eogId, 'temporary']
      );

      if (!eog) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'EOG must be in temporary status to submit for review'
        });
      }

      // Check if account has expired
      if (eog.temp_account_expires && new Date(eog.temp_account_expires) < new Date()) {
        return res.status(400).json({
          success: false,
          error: 'Account Expired',
          message: 'Your temporary EOG account has expired'
        });
      }

      // Validate: All 5 required documents uploaded
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
          message: `Missing required documents: ${missingDocuments.join(', ')}`
        });
      }

      // Validate: Minimum 10 executive members
      const memberCount = await db.getOne(
        `SELECT COUNT(*) as count
         FROM eog_members
         WHERE eog_id = ? AND is_executive = true`,
        [eogId]
      );

      if (memberCount.count < 10) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: `Not enough executive members. Minimum 10 required, ${memberCount.count} provided.`
        });
      }

      // Begin transaction
      const connection = await db.beginTransaction();

      try {
        // Update EOG status
        await connection.query(
          `UPDATE eogs SET
             status = 'pending_verification'
           WHERE id = ?`,
          [eogId]
        );

        // Find CDO for the region
        const cdo = await connection.query(
          `SELECT u.id
           FROM users u
           WHERE u.role = 'CDO' AND u.region_id = ? AND u.status = 'active'
           ORDER BY RAND()
           LIMIT 1`,
          [eog.region_id]
        );

        // Get CDO ID or null if none found
        const cdoId = cdo.length > 0 ? cdo[0].id : null;

        // Insert into CDO review queue
        await connection.query(
          `INSERT INTO cdo_review_queue (
            eog_id, assigned_cdo_id, priority, status, assigned_at
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            cdoId,
            'medium',
            'pending',
            cdoId ? new Date() : null
          ]
        );

        // Log activity
        await connection.query(
          `INSERT INTO eog_temporal_activity (
            eog_id, activity_type, description, performed_by, ip_address
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            eogId,
            'submitted_for_review',
            `Submitted EOG for CDO review`,
            req.user.id,
            req.ip
          ]
        );

        // If CDO assigned, send notification email
        if (cdoId) {
          const cdoUser = await connection.query(
            `SELECT * FROM users WHERE id = ?`,
            [cdoId]
          );

          if (cdoUser.length > 0) {
            // Send notification outside transaction (don't fail if email fails)
            setTimeout(async () => {
              try {
                const subject = `New EOG Awaiting Review - ${eog.company_name}`;
                const body = `
                  <h1>New EOG Awaiting Review</h1>
                  <p>Hello ${cdoUser[0].first_name} ${cdoUser[0].last_name},</p>
                  <p>A new EOG has been submitted for your review:</p>
                  <ul>
                    <li><strong>EOG Name:</strong> ${eog.company_name}</li>
                    <li><strong>EOG Type:</strong> ${eog.company_type}</li>
                    <li><strong>BIN/CIN:</strong> ${eog.bin_cin}</li>
                    <li><strong>Status:</strong> Pending verification</li>
                  </ul>
                  <p>Please log in to review and verify this EOG.</p>
                  <p>Thank you,</p>
                  <p>The RDF System Team</p>
                `;

                await emailUtils.sendEmail(cdoUser[0].email, subject, body, cdoUser[0].id, eogId, 'eogs');
              } catch (emailError) {
                logger.error(`Failed to send CDO notification: ${emailError.message}`);
              }
            }, 0);
          }
        }

        // Commit transaction
        await db.commit(connection);

        return res.status(200).json({
          success: true,
          message: 'EOG submitted for CDO review successfully',
          data: {
            status: 'pending_verification',
            cdo_assigned: cdoId !== null
          }
        });
      } catch (error) {
        // Rollback transaction on error
        await db.rollback(connection);
        throw error;
      }
    } catch (error) {
      logger.error(`Submit EOG error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/registration/expiring
 * @desc    Get expiring EOG accounts (for CRON job)
 * @access  Private (CRON job token)
 */
router.get('/expiring', async (req, res) => {
  try {
    // Check for CRON job token
    const token = req.headers['x-cron-token'];

    if (!token || token !== process.env.CRON_JOB_TOKEN) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        message: 'Invalid CRON job token'
      });
    }

    // Get accounts expiring in 7, 3, and 1 days
    const expiringIn7Days = await db.query(
      `SELECT e.*, u.id as user_id, u.email, u.first_name, u.last_name
       FROM eogs e
       JOIN eog_users eu ON eu.eog_id = e.id AND eu.is_primary_contact = true
       JOIN users u ON u.id = eu.user_id
       WHERE e.status = 'temporary'
         AND e.temp_account_expires BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
         AND DATE(e.temp_account_expires) = DATE_ADD(CURDATE(), INTERVAL 7 DAY)
         AND NOT EXISTS (
           SELECT 1 FROM eog_expiry_notifications n
           WHERE n.eog_id = e.id AND n.days_remaining = 7
         )`
    );

    const expiringIn3Days = await db.query(
      `SELECT e.*, u.id as user_id, u.email, u.first_name, u.last_name
       FROM eogs e
       JOIN eog_users eu ON eu.eog_id = e.id AND eu.is_primary_contact = true
       JOIN users u ON u.id = eu.user_id
       WHERE e.status = 'temporary'
         AND e.temp_account_expires BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 3 DAY)
         AND DATE(e.temp_account_expires) = DATE_ADD(CURDATE(), INTERVAL 3 DAY)
         AND NOT EXISTS (
           SELECT 1 FROM eog_expiry_notifications n
           WHERE n.eog_id = e.id AND n.days_remaining = 3
         )`
    );

    const expiringIn1Day = await db.query(
      `SELECT e.*, u.id as user_id, u.email, u.first_name, u.last_name
       FROM eogs e
       JOIN eog_users eu ON eu.eog_id = e.id AND eu.is_primary_contact = true
       JOIN users u ON u.id = eu.user_id
       WHERE e.status = 'temporary'
         AND e.temp_account_expires BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 1 DAY)
         AND DATE(e.temp_account_expires) = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
         AND NOT EXISTS (
           SELECT 1 FROM eog_expiry_notifications n
           WHERE n.eog_id = e.id AND n.days_remaining = 1
         )`
    );

    // Get expired accounts that need to be suspended
    const expiredAccounts = await db.query(
      `SELECT e.*
       FROM eogs e
       WHERE e.status = 'temporary'
         AND e.temp_account_expires < NOW()`
    );

    // Send expiry warnings
    const notifications = [];

    // Process 7-day warnings
    for (const eog of expiringIn7Days) {
      try {
        await emailUtils.sendExpiryWarning(eog, eog, 7);

        // Record notification
        await db.insert('eog_expiry_notifications', {
          eog_id: eog.id,
          days_remaining: 7,
          email_sent: true,
          sent_at: new Date()
        });

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 7,
          email: eog.email,
          success: true
        });
      } catch (error) {
        logger.error(`Failed to send 7-day warning to ${eog.company_name}: ${error.message}`);

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 7,
          email: eog.email,
          success: false,
          error: error.message
        });
      }
    }

    // Process 3-day warnings
    for (const eog of expiringIn3Days) {
      try {
        await emailUtils.sendExpiryWarning(eog, eog, 3);

        // Record notification
        await db.insert('eog_expiry_notifications', {
          eog_id: eog.id,
          days_remaining: 3,
          email_sent: true,
          sent_at: new Date()
        });

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 3,
          email: eog.email,
          success: true
        });
      } catch (error) {
        logger.error(`Failed to send 3-day warning to ${eog.company_name}: ${error.message}`);

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 3,
          email: eog.email,
          success: false,
          error: error.message
        });
      }
    }

    // Process 1-day warnings
    for (const eog of expiringIn1Day) {
      try {
        await emailUtils.sendExpiryWarning(eog, eog, 1);

        // Record notification
        await db.insert('eog_expiry_notifications', {
          eog_id: eog.id,
          days_remaining: 1,
          email_sent: true,
          sent_at: new Date()
        });

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 1,
          email: eog.email,
          success: true
        });
      } catch (error) {
        logger.error(`Failed to send 1-day warning to ${eog.company_name}: ${error.message}`);

        notifications.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          days_remaining: 1,
          email: eog.email,
          success: false,
          error: error.message
        });
      }
    }

    // Suspend expired accounts
    const suspensions = [];

    for (const eog of expiredAccounts) {
      try {
        // Update eog status
        await db.update('eogs',
          { status: 'suspended' },
          'id = ?',
          [eog.id]
        );

        // Log activity
        await db.insert('eog_temporal_activity', {
          eog_id: eog.id,
          activity_type: 'account_expired',
          description: 'Temporary account expired and was suspended',
          ip_address: req.ip
        });

        suspensions.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          success: true
        });
      } catch (error) {
        logger.error(`Failed to suspend expired account ${eog.company_name}: ${error.message}`);

        suspensions.push({
          eog_id: eog.id,
          company_name: eog.company_name,
          success: false,
          error: error.message
        });
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        expiringIn7Days: expiringIn7Days.length,
        expiringIn3Days: expiringIn3Days.length,
        expiringIn1Day: expiringIn1Day.length,
        expiredAccounts: expiredAccounts.length,
        notifications,
        suspensions
      }
    });
  } catch (error) {
    logger.error(`Process expiring accounts error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

module.exports = router;
