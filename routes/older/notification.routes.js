const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, checkRole } = require('../middleware/auth.middleware');
const emailService = require('../utils/email.service');

/**
 * @route   GET /api/notifications
 * @desc    Get user notifications
 * @access  Private
 */
router.get('/', verifyToken, async (req, res, next) => {
  try {
    const { read, page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT * FROM notifications
      WHERE user_id = ?
    `;
    const params = [req.user.id];

    if (read !== undefined) {
      query += ' AND is_read = ?';
      params.push(read === 'true' ? 1 : 0);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const notifications = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        notifications,
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
 * @route   PUT /api/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:id/read', verifyToken, async (req, res, next) => {
  try {
    const { id } = req.params;

    await db.query(
      'UPDATE notifications SET is_read = 1, read_at = NOW() WHERE id = ? AND user_id = ?',
      [id, req.user.id]
    );

    res.json({
      status: 'success',
      message: 'Notification marked as read'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put('/read-all', verifyToken, async (req, res, next) => {
  try {
    await db.query(
      'UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND is_read = 0',
      [req.user.id]
    );

    res.json({
      status: 'success',
      message: 'All notifications marked as read'
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/notifications/email-logs
 * @desc    Get email logs
 * @access  Private (SUPER_USER, CDO)
 */
router.get('/email-logs', verifyToken, checkRole('SUPER_USER', 'CDO'), async (req, res, next) => {
  try {
    const { recipient_email, status, page = 1, limit = 50 } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM email_logs WHERE 1=1';
    const params = [];

    if (recipient_email) {
      query += ' AND recipient_email = ?';
      params.push(recipient_email);
    }

    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    const countQuery = query.replace(/SELECT.*FROM/, 'SELECT COUNT(*) as total FROM');
    const [{ total }] = await db.query(countQuery, params);

    query += ' ORDER BY sent_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const logs = await db.query(query, params);

    res.json({
      status: 'success',
      data: {
        logs,
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

module.exports = router;
