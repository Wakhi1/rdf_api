const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const db = require('../config/database');
const { validate, schemas } = require('../utils/validation');
const { verifyToken, checkRole } = require('../middleware/auth.middleware');

/**
 * @route   GET /api/users
 * @desc    Get all users
 * @access  Private (SUPER_USER, CDO)
 */
router.get('/', verifyToken, checkRole('SUPER_USER', 'CDO'), async (req, res, next) => {
  try {
    const { role, status, region_id, search, page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT u.id, u.username, u.email, u.role, u.first_name, u.last_name, u.phone, 
             u.status, u.region_id, u.tinkhundla_id, u.umphakatsi_id, u.ministry, u.last_login, u.created_at,
             r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
      FROM users u
      LEFT JOIN regions r ON u.region_id = r.id
      LEFT JOIN tinkhundla t ON u.tinkhundla_id = t.id
      LEFT JOIN imiphakatsi i ON u.umphakatsi_id = i.id
      WHERE 1=1
    `;
    const params = [];

    if (role) {
      query += ' AND u.role = ?';
      params.push(role);
    }

    if (status) {
      query += ' AND u.status = ?';
      params.push(status);
    }

    if (region_id) {
      query += ' AND u.region_id = ?';
      params.push(region_id);
    }

    if (search) {
      query += ' AND (u.username LIKE ? OR u.email LIKE ? OR u.first_name LIKE ? OR u.last_name LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm, searchTerm);
    }

    // Get total count
    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY u.created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const users = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        users,
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
 * @route   GET /api/users/:id
 * @desc    Get user by ID
 * @access  Private
 */
router.get('/:id', verifyToken, async (req, res, next) => {
  try {
    const { id } = req.params;

    // Users can only view themselves unless they're SUPER_USER or CDO
    if (req.user.role !== 'SUPER_USER' && req.user.role !== 'CDO' && req.user.id != id) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions'
      });
    }

    const user = await db.queryOne(
      `SELECT u.id, u.username, u.email, u.role, u.first_name, u.last_name, u.phone, 
              u.status, u.region_id, u.tinkhundla_id, u.umphakatsi_id, u.ministry, u.last_login, u.created_at,
              r.name as region_name, t.name as tinkhundla_name, i.name as umphakatsi_name
       FROM users u
       LEFT JOIN regions r ON u.region_id = r.id
       LEFT JOIN tinkhundla t ON u.tinkhundla_id = t.id
       LEFT JOIN imiphakatsi i ON u.umphakatsi_id = i.id
       WHERE u.id = ?`,
      [id]
    );

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.json({
      status: 'success',
      data: { user }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/users
 * @desc    Create new user
 * @access  Private (SUPER_USER)
 */
router.post('/', verifyToken, checkRole('SUPER_USER'), validate(schemas.createUserSchema), async (req, res, next) => {
  try {
    const userData = req.validatedData;

    // Check if username or email already exists
    const existing = await db.queryOne(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [userData.username, userData.email]
    );

    if (existing) {
      return res.status(409).json({
        status: 'error',
        message: 'Username or email already exists'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(userData.password, parseInt(process.env.BCRYPT_ROUNDS) || 10);

    // Insert user
    const result = await db.query(
      `INSERT INTO users (username, email, password, role, first_name, last_name, phone, 
                          region_id, tinkhundla_id, umphakatsi_id, ministry, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active')`,
      [
        userData.username,
        userData.email,
        hashedPassword,
        userData.role,
        userData.first_name,
        userData.last_name,
        userData.phone || null,
        userData.region_id || null,
        userData.tinkhundla_id || null,
        userData.umphakatsi_id || null,
        userData.ministry || null
      ]
    );

    // Log activity
    await db.query(
      `INSERT INTO user_activity_logs (user_id, action, entity_type, entity_id, description, created_at)
       VALUES (?, 'user_created', 'user', ?, 'New user created', NOW())`,
      [req.user.id, result.insertId]
    );

    const newUser = await db.queryOne(
      `SELECT id, username, email, role, first_name, last_name, phone, status, 
              region_id, tinkhundla_id, umphakatsi_id, ministry, created_at
       FROM users WHERE id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      status: 'success',
      message: 'User created successfully',
      data: { user: newUser }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/users/:id
 * @desc    Update user
 * @access  Private (SUPER_USER or self)
 */
router.put('/:id', verifyToken, validate(schemas.updateUserSchema), async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = req.validatedData;

    // Users can only update themselves unless they're SUPER_USER
    if (req.user.role !== 'SUPER_USER' && req.user.id != id) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions'
      });
    }

    // Check if user exists
    const user = await db.queryOne('SELECT id FROM users WHERE id = ?', [id]);
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Non-SUPER_USER cannot change status
    if (req.user.role !== 'SUPER_USER' && updates.status) {
      delete updates.status;
    }

    // Build update query
    const fields = Object.keys(updates);
    if (fields.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'No fields to update'
      });
    }

    const setClause = fields.map(field => `${field} = ?`).join(', ');
    const values = fields.map(field => updates[field]);
    values.push(id);

    await db.query(
      `UPDATE users SET ${setClause}, updated_at = NOW() WHERE id = ?`,
      values
    );

    // Log activity
    await db.query(
      `INSERT INTO user_activity_logs (user_id, action, entity_type, entity_id, description, created_at)
       VALUES (?, 'user_updated', 'user', ?, 'User information updated', NOW())`,
      [req.user.id, id]
    );

    const updatedUser = await db.queryOne(
      `SELECT id, username, email, role, first_name, last_name, phone, status, 
              region_id, tinkhundla_id, umphakatsi_id, ministry
       FROM users WHERE id = ?`,
      [id]
    );

    res.json({
      status: 'success',
      message: 'User updated successfully',
      data: { user: updatedUser }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   DELETE /api/users/:id
 * @desc    Delete user (soft delete by setting status to inactive)
 * @access  Private (SUPER_USER)
 */
router.delete('/:id', verifyToken, checkRole('SUPER_USER'), async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const user = await db.queryOne('SELECT id, username FROM users WHERE id = ?', [id]);
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Cannot delete yourself
    if (req.user.id == id) {
      return res.status(400).json({
        status: 'error',
        message: 'Cannot delete your own account'
      });
    }

    // Soft delete by setting status to inactive
    await db.query(
      'UPDATE users SET status = ?, updated_at = NOW() WHERE id = ?',
      ['inactive', id]
    );

    // Log activity
    await db.query(
      `INSERT INTO user_activity_logs (user_id, action, entity_type, entity_id, description, created_at)
       VALUES (?, 'user_deleted', 'user', ?, 'User account deactivated', NOW())`,
      [req.user.id, id]
    );

    res.json({
      status: 'success',
      message: 'User deleted successfully'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/users/:id/activity
 * @desc    Get user activity logs
 * @access  Private (SUPER_USER, CDO or self)
 */
router.get('/:id/activity', verifyToken, async (req, res, next) => {
  try {
    const { id } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    // Check permissions
    if (req.user.role !== 'SUPER_USER' && req.user.role !== 'CDO' && req.user.id != id) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions'
      });
    }

    // Get total count
    const [{ total }] = await db.query(
      'SELECT COUNT(*) as total FROM user_activity_logs WHERE user_id = ?',
      [id]
    );

    const activities = await db.query(
      `SELECT id, action, entity_type, entity_id, description, ip_address, user_agent, created_at
       FROM user_activity_logs
       WHERE user_id = ?
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [id, parseInt(limit), offset]
    );

    res.json({
      status: 'success',
      data: {
        activities,
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
 * @route   GET /api/users/by-role/:role
 * @desc    Get users by role
 * @access  Private
 */
router.get('/by-role/:role', verifyToken, async (req, res, next) => {
  try {
    const { role } = req.params;
    const { region_id, tinkhundla_id, umphakatsi_id } = req.query;

    let query = `
      SELECT u.id, u.username, u.email, u.first_name, u.last_name, u.role, u.region_id, 
             u.tinkhundla_id, u.umphakatsi_id, r.name as region_name
      FROM users u
      LEFT JOIN regions r ON u.region_id = r.id
      WHERE u.role = ? AND u.status = 'active'
    `;
    const params = [role];

    if (region_id) {
      query += ' AND u.region_id = ?';
      params.push(region_id);
    }

    if (tinkhundla_id) {
      query += ' AND u.tinkhundla_id = ?';
      params.push(tinkhundla_id);
    }

    if (umphakatsi_id) {
      query += ' AND u.umphakatsi_id = ?';
      params.push(umphakatsi_id);
    }

    query += ' ORDER BY u.first_name, u.last_name';

    const users = await db.query(query, params);

    res.json({
      status: 'success',
      data: { users }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
