const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, optionalAuth } = require('../middleware/auth.middleware');

/**
 * @route   GET /api/geography/regions
 * @desc    Get all regions
 * @access  Public
 */
router.get('/regions', optionalAuth, async (req, res, next) => {
  try {
    const regions = await db.query(
      'SELECT id, name, code, created_at FROM regions ORDER BY name'
    );

    res.json({
      status: 'success',
      data: { regions }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/regions/:id
 * @desc    Get region by ID
 * @access  Public
 */
router.get('/regions/:id', optionalAuth, async (req, res, next) => {
  try {
    const { id } = req.params;

    const region = await db.queryOne(
      'SELECT id, name, code, created_at FROM regions WHERE id = ?',
      [id]
    );

    if (!region) {
      return res.status(404).json({
        status: 'error',
        message: 'Region not found'
      });
    }

    // Get tinkhundla count
    const [{ tinkhundla_count }] = await db.query(
      'SELECT COUNT(*) as tinkhundla_count FROM tinkhundla WHERE region_id = ?',
      [id]
    );

    region.tinkhundla_count = tinkhundla_count;

    res.json({
      status: 'success',
      data: { region }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/tinkhundla
 * @desc    Get all tinkhundla or filtered by region
 * @access  Public
 */
router.get('/tinkhundla', optionalAuth, async (req, res, next) => {
  try {
    const { region_id } = req.query;

    let query = `
      SELECT t.id, t.name, t.code, t.region_id, t.created_at, r.name as region_name
      FROM tinkhundla t
      INNER JOIN regions r ON t.region_id = r.id
    `;
    const params = [];

    if (region_id) {
      query += ' WHERE t.region_id = ?';
      params.push(region_id);
    }

    query += ' ORDER BY r.name, t.name';

    const tinkhundla = await db.query(query, params);

    res.json({
      status: 'success',
      data: { tinkhundla }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/tinkhundla/:id
 * @desc    Get tinkhundla by ID
 * @access  Public
 */
router.get('/tinkhundla/:id', optionalAuth, async (req, res, next) => {
  try {
    const { id } = req.params;

    const tinkhundla = await db.queryOne(
      `SELECT t.id, t.name, t.code, t.region_id, t.created_at, r.name as region_name
       FROM tinkhundla t
       INNER JOIN regions r ON t.region_id = r.id
       WHERE t.id = ?`,
      [id]
    );

    if (!tinkhundla) {
      return res.status(404).json({
        status: 'error',
        message: 'Tinkhundla not found'
      });
    }

    // Get imiphakatsi count
    const [{ imiphakatsi_count }] = await db.query(
      'SELECT COUNT(*) as imiphakatsi_count FROM imiphakatsi WHERE tinkhundla_id = ?',
      [id]
    );

    tinkhundla.imiphakatsi_count = imiphakatsi_count;

    res.json({
      status: 'success',
      data: { tinkhundla }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/imiphakatsi
 * @desc    Get all imiphakatsi or filtered
 * @access  Public
 */
router.get('/imiphakatsi', optionalAuth, async (req, res, next) => {
  try {
    const { region_id, tinkhundla_id } = req.query;

    let query = `
      SELECT i.id, i.name, i.chief_name, i.chief_contact, i.tinkhundla_id, i.created_at,
             t.name as tinkhundla_name, t.region_id, r.name as region_name
      FROM imiphakatsi i
      INNER JOIN tinkhundla t ON i.tinkhundla_id = t.id
      INNER JOIN regions r ON t.region_id = r.id
      WHERE 1=1
    `;
    const params = [];

    if (tinkhundla_id) {
      query += ' AND i.tinkhundla_id = ?';
      params.push(tinkhundla_id);
    } else if (region_id) {
      query += ' AND t.region_id = ?';
      params.push(region_id);
    }

    query += ' ORDER BY r.name, t.name, i.name';

    const imiphakatsi = await db.query(query, params);

    res.json({
      status: 'success',
      data: { imiphakatsi }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/imiphakatsi/:id
 * @desc    Get umphakatsi by ID
 * @access  Public
 */
router.get('/imiphakatsi/:id', optionalAuth, async (req, res, next) => {
  try {
    const { id } = req.params;

    const umphakatsi = await db.queryOne(
      `SELECT i.id, i.name, i.chief_name, i.chief_contact, i.tinkhundla_id, i.created_at,
              t.name as tinkhundla_name, t.region_id, r.name as region_name
       FROM imiphakatsi i
       INNER JOIN tinkhundla t ON i.tinkhundla_id = t.id
       INNER JOIN regions r ON t.region_id = r.id
       WHERE i.id = ?`,
      [id]
    );

    if (!umphakatsi) {
      return res.status(404).json({
        status: 'error',
        message: 'Umphakatsi not found'
      });
    }

    res.json({
      status: 'success',
      data: { umphakatsi }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/hierarchy
 * @desc    Get complete geographic hierarchy
 * @access  Public
 */
router.get('/hierarchy', optionalAuth, async (req, res, next) => {
  try {
    // Get all regions
    const regions = await db.query(
      'SELECT id, name, code FROM regions ORDER BY name'
    );

    // For each region, get tinkhundla
    for (const region of regions) {
      const tinkhundla = await db.query(
        'SELECT id, name, code FROM tinkhundla WHERE region_id = ? ORDER BY name',
        [region.id]
      );

      // For each tinkhundla, get imiphakatsi
      for (const inkhundla of tinkhundla) {
        const imiphakatsi = await db.query(
          'SELECT id, name, chief_name FROM imiphakatsi WHERE tinkhundla_id = ? ORDER BY name',
          [inkhundla.id]
        );
        inkhundla.imiphakatsi = imiphakatsi;
      }

      region.tinkhundla = tinkhundla;
    }

    res.json({
      status: 'success',
      data: { hierarchy: regions }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/geography/statistics
 * @desc    Get geography statistics
 * @access  Public
 */
router.get('/statistics', optionalAuth, async (req, res, next) => {
  try {
    const [stats] = await db.query(`
      SELECT 
        (SELECT COUNT(*) FROM regions) as total_regions,
        (SELECT COUNT(*) FROM tinkhundla) as total_tinkhundla,
        (SELECT COUNT(*) FROM imiphakatsi) as total_imiphakatsi,
        (SELECT COUNT(*) FROM eogs WHERE status = 'approved') as total_approved_eogs,
        (SELECT COUNT(*) FROM applications) as total_applications
    `);

    // Get breakdown by region
    const regionBreakdown = await db.query(`
      SELECT 
        r.id,
        r.name,
        r.code,
        (SELECT COUNT(*) FROM tinkhundla WHERE region_id = r.id) as tinkhundla_count,
        (SELECT COUNT(*) FROM imiphakatsi i 
         INNER JOIN tinkhundla t ON i.tinkhundla_id = t.id 
         WHERE t.region_id = r.id) as imiphakatsi_count,
        (SELECT COUNT(*) FROM eogs WHERE region_id = r.id AND status = 'approved') as eogs_count,
        (SELECT COUNT(*) FROM applications a
         INNER JOIN eogs e ON a.eog_id = e.id
         WHERE e.region_id = r.id) as applications_count
      FROM regions r
      ORDER BY r.name
    `);

    res.json({
      status: 'success',
      data: {
        summary: stats,
        breakdown: regionBreakdown
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;