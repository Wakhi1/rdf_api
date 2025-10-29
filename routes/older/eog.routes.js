const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const db = require('../config/database');
const { validate, schemas } = require('../utils/validation');
const { verifyToken, checkRole } = require('../middleware/auth.middleware');
const emailService = require('../utils/email.service');
const { uploadConfigs, handleUploadError, validateEOGDocuments, getFileInfo } = require('../utils/upload.service');

/**
 * @route   POST /api/eogs/expression-of-interest
 * @desc    Submit EOG Expression of Interest (Phase 1)
 * @access  Public
 */
router.post('/expression-of-interest', validate(schemas.eogExpressionOfInterestSchema), async (req, res, next) => {
  try {
    const data = req.validatedData;

    // Check if BIN/CIN or email already exists
    const existing = await db.queryOne(
      'SELECT id FROM eogs WHERE bin_cin = ? OR email = ?',
      [data.bin_cin, data.email]
    );

    if (existing) {
      return res.status(409).json({
        status: 'error',
        message: 'EOG with this BIN/CIN or email already exists'
      });
    }

    // Generate temporary credentials
    const tempUsername = `temp_${Date.now()}${Math.floor(1000 + Math.random() * 9000)}`;
    const tempPassword = `Temp${Math.random().toString(36).slice(-8)}!`;
    const hashedPassword = await bcrypt.hash(tempPassword, parseInt(process.env.BCRYPT_ROUNDS) || 10);
    
    const expiryDays = parseInt(process.env.TEMP_ACCOUNT_EXPIRY_DAYS) || 30;
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + expiryDays);

    // Start transaction
    await db.transaction(async (connection) => {
      // Insert EOG
      const [eogResult] = await connection.execute(
        `INSERT INTO eogs (company_name, company_type, bin_cin, email, phone, region_id, 
                          tinkhundla_id, umphakatsi_id, total_members, status, temp_account_expires)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'temporary', ?)`,
        [data.company_name, data.company_type, data.bin_cin, data.email, data.phone,
         data.region_id, data.tinkhundla_id, data.umphakatsi_id, data.total_members, expiresAt]
      );

      const eogId = eogResult.insertId;

      // Create temporary user account
      const [userResult] = await connection.execute(
        `INSERT INTO users (username, email, password, role, first_name, last_name, phone, 
                           status, region_id, tinkhundla_id, umphakatsi_id)
         VALUES (?, ?, ?, 'EOG', ?, ?, ?, 'temporary', ?, ?, ?)`,
        [tempUsername, data.email, hashedPassword, data.company_name, 'Representative', data.phone,
         data.region_id, data.tinkhundla_id, data.umphakatsi_id]
      );

      const userId = userResult.insertId;

      // Link user to EOG
      await connection.execute(
        'INSERT INTO eog_users (eog_id, user_id, is_primary) VALUES (?, ?, 1)',
        [eogId, userId]
      );

      // Insert executive members
      for (const member of data.executive_members) {
        await connection.execute(
          `INSERT INTO eog_members (eog_id, id_number, first_name, surname, gender, 
                                    contact_number, position, is_executive, verification_status)
           VALUES (?, ?, ?, ?, ?, ?, ?, 1, 'pending')`,
          [eogId, member.id_number, member.first_name, member.surname, member.gender,
           member.contact_number, member.position]
        );
      }
    });

    // Send email with temporary credentials
    const eog = await db.queryOne('SELECT * FROM eogs WHERE bin_cin = ?', [data.bin_cin]);
    await emailService.sendEOGRegistrationEmail(eog, {
      username: tempUsername,
      password: tempPassword
    });

    res.status(201).json({
      status: 'success',
      message: 'Expression of Interest submitted successfully. Temporary credentials sent to email.',
      data: {
        eog_id: eog.id,
        temp_username: tempUsername,
        expires_at: expiresAt
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/eogs/:id/documents
 * @desc    Upload EOG documents
 * @access  Private (EOG)
 */
router.post('/:id/documents',
  verifyToken,
  uploadConfigs.eogDocuments,
  handleUploadError,
  async (req, res, next) => {
    try {
      const { id } = req.params;

      // Verify EOG ownership
      const eog = await db.queryOne(
        `SELECT e.* FROM eogs e 
         INNER JOIN eog_users eu ON e.id = eu.eog_id 
         WHERE e.id = ? AND eu.user_id = ?`,
        [id, req.user.id]
      );

      if (!eog) {
        return res.status(404).json({
          status: 'error',
          message: 'EOG not found or access denied'
        });
      }

      // Validate documents
      const validation = validateEOGDocuments(req.files);
      if (!validation.valid) {
        return res.status(400).json({
          status: 'error',
          message: 'Document validation failed',
          errors: validation.errors
        });
      }

      // Save document records
      const documentTypes = ['constitution', 'recognition_letter', 'articles', 'form_j', 'certificate', 'member_list'];
      
      for (const docType of documentTypes) {
        if (req.files[docType] && req.files[docType].length > 0) {
          const file = req.files[docType][0];
          const fileInfo = getFileInfo(file);

          await db.query(
            `INSERT INTO eog_documents (eog_id, document_type, file_name, file_path, file_size)
             VALUES (?, ?, ?, ?, ?)`,
            [id, docType, fileInfo.fileName, fileInfo.filePath, fileInfo.fileSize]
          );
        }
      }

      // Update EOG status
      await db.query(
        `UPDATE eogs SET status = 'pending_verification', updated_at = NOW() WHERE id = ?`,
        [id]
      );

      res.json({
        status: 'success',
        message: 'Documents uploaded successfully. EOG is now pending verification.'
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @route   POST /api/eogs/:id/verify-members
 * @desc    CDO verifies EOG members against training register
 * @access  Private (CDO, SUPER_USER)
 */
router.post('/:id/verify-members', verifyToken, checkRole('CDO', 'SUPER_USER'), async (req, res, next) => {
  try {
    const { id } = req.params;
    const { member_ids, action, notes } = req.body; // action: 'verify' or 'reject'

    if (!member_ids || !Array.isArray(member_ids) || member_ids.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Member IDs array is required'
      });
    }

    const results = [];

    for (const memberId of member_ids) {
      const member = await db.queryOne(
        'SELECT * FROM eog_members WHERE id = ? AND eog_id = ?',
        [memberId, id]
      );

      if (!member) {
        results.push({ member_id: memberId, status: 'not_found' });
        continue;
      }

      // Verify against training register
      const trainingRecord = await db.queryOne(
        `SELECT * FROM training_register 
         WHERE id_number = ? AND first_name = ? AND surname = ? AND gender = ?`,
        [member.id_number, member.first_name, member.surname, member.gender]
      );

      let verificationStatus = 'failed';
      let verificationNotes = notes || '';

      if (action === 'verify' && trainingRecord) {
        verificationStatus = 'verified';
        verificationNotes = 'Verified against training register';
      } else if (action === 'reject') {
        verificationStatus = 'failed';
      } else if (!trainingRecord) {
        verificationStatus = 'failed';
        verificationNotes = 'Not found in training register';
      }

      await db.query(
        `UPDATE eog_members 
         SET verification_status = ?, verification_notes = ?, verified_by = ?, verified_at = NOW()
         WHERE id = ?`,
        [verificationStatus, verificationNotes, req.user.id, memberId]
      );

      results.push({
        member_id: memberId,
        status: verificationStatus,
        name: `${member.first_name} ${member.surname}`
      });
    }

    // Check if all executive members are verified
    const [{ total, verified }] = await db.query(
      `SELECT 
         COUNT(*) as total,
         SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) as verified
       FROM eog_members 
       WHERE eog_id = ? AND is_executive = 1`,
      [id]
    );

    const allVerified = total === verified;

    res.json({
      status: 'success',
      message: `Processed ${results.length} members`,
      data: {
        results,
        summary: {
          total_executive: total,
          verified: verified,
          all_verified: allVerified
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/eogs/:id/approve
 * @desc    CDO approves EOG registration
 * @access  Private (CDO, SUPER_USER)
 */
router.post('/:id/approve', verifyToken, checkRole('CDO', 'SUPER_USER'), async (req, res, next) => {
  try {
    const { id } = req.params;

    const eog = await db.queryOne('SELECT * FROM eogs WHERE id = ?', [id]);
    if (!eog) {
      return res.status(404).json({
        status: 'error',
        message: 'EOG not found'
      });
    }

    // Check if all executive members are verified
    const [{ total, verified }] = await db.query(
      `SELECT 
         COUNT(*) as total,
         SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) as verified
       FROM eog_members 
       WHERE eog_id = ? AND is_executive = 1`,
      [id]
    );

    if (total !== verified) {
      return res.status(400).json({
        status: 'error',
        message: 'All executive members must be verified before approval'
      });
    }

    // Approve EOG
    await db.query(
      `UPDATE eogs SET status = 'approved', approved_by = ?, approved_at = NOW() WHERE id = ?`,
      [req.user.id, id]
    );

    // Update user status to active
    await db.query(
      `UPDATE users u
       INNER JOIN eog_users eu ON u.id = eu.user_id
       SET u.status = 'active'
       WHERE eu.eog_id = ?`,
      [id]
    );

    res.json({
      status: 'success',
      message: 'EOG approved successfully'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/eogs
 * @desc    Get all EOGs
 * @access  Private
 */
router.get('/', verifyToken, async (req, res, next) => {
  try {
    const { status, region_id, search, page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT e.*, r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
      FROM eogs e
      LEFT JOIN regions r ON e.region_id = r.id
      LEFT JOIN tinkhundla t ON e.tinkhundla_id = t.id
      LEFT JOIN imiphakatsi i ON e.umphakatsi_id = i.id
      WHERE 1=1
    `;
    const params = [];

    if (status) {
      query += ' AND e.status = ?';
      params.push(status);
    }

    if (region_id) {
      query += ' AND e.region_id = ?';
      params.push(region_id);
    }

    if (search) {
      query += ' AND (e.company_name LIKE ? OR e.bin_cin LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY e.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const eogs = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        eogs,
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
 * @route   GET /api/eogs/:id
 * @desc    Get EOG by ID with members and documents
 * @access  Private
 */
router.get('/:id', verifyToken, async (req, res, next) => {
  try {
    const { id } = req.params;

    const eog = await db.queryOne(
      `SELECT e.*, r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
       FROM eogs e
       LEFT JOIN regions r ON e.region_id = r.id
       LEFT JOIN tinkhundla t ON e.tinkhundla_id = t.id
       LEFT JOIN imiphakatsi i ON e.umphakatsi_id = i.id
       WHERE e.id = ?`,
      [id]
    );

    if (!eog) {
      return res.status(404).json({
        status: 'error',
        message: 'EOG not found'
      });
    }

    // Get members
    const members = await db.query(
      'SELECT * FROM eog_members WHERE eog_id = ? ORDER BY is_executive DESC, first_name',
      [id]
    );

    // Get documents
    const documents = await db.query(
      'SELECT * FROM eog_documents WHERE eog_id = ? ORDER BY uploaded_at DESC',
      [id]
    );

    eog.members = members;
    eog.documents = documents;

    res.json({
      status: 'success',
      data: { eog }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;