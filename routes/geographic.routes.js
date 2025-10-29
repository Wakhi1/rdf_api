const express = require('express');
const router = express.Router();
const db = require('../utils/db');
const logger = require('../utils/logger');
const { authenticate } = require('../middleware/auth.middleware');
const { requireRole } = require('../middleware/role.middleware');
const { validateParams, validateBody, schemas } = require('../middleware/validation.middleware');

/**
 * @route   GET /api/geographic/regions
 * @desc    Get all regions
 * @access  Public
 */
router.get('/regions', async (req, res) => {
  try {
    const regions = await db.query(
      'SELECT * FROM regions ORDER BY name'
    );
    
    return res.status(200).json({
      success: true,
      data: regions
    });
  } catch (error) {
    logger.error(`Get regions error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/geographic/regions/:id
 * @desc    Get region by ID
 * @access  Public
 */
router.get('/regions/:id', validateParams(schemas.idParam), async (req, res) => {
  try {
    const region = await db.getOne(
      'SELECT * FROM regions WHERE id = ?',
      [req.params.id]
    );
    
    if (!region) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: 'Region not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: region
    });
  } catch (error) {
    logger.error(`Get region by ID error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/geographic/regions
 * @desc    Create new region
 * @access  Private (SUPER_USER only)
 */
router.post('/regions', 
  authenticate, 
  requireRole('SUPER_USER'),
  async (req, res) => {
    try {
      const { name, code } = req.body;
      
      // Validate required fields
      if (!name || !code) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name and code are required'
        });
      }
      
      // Check if name already exists
      const existingName = await db.getOne(
        'SELECT id FROM regions WHERE name = ?',
        [name]
      );
      
      if (existingName) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Region name already exists'
        });
      }
      
      // Check if code already exists
      const existingCode = await db.getOne(
        'SELECT id FROM regions WHERE code = ?',
        [code]
      );
      
      if (existingCode) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Region code already exists'
        });
      }
      
      // Create region
      const result = await db.insert('regions', {
        name,
        code
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'region_created',
        'regions',
        result.id,
        { name, code },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created region
      const region = await db.getOne(
        'SELECT * FROM regions WHERE id = ?',
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Region created successfully',
        data: region
      });
    } catch (error) {
      logger.error(`Create region error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/geographic/regions/:id
 * @desc    Update region
 * @access  Private (SUPER_USER only)
 */
router.put('/regions/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const regionId = req.params.id;
      const { name, code } = req.body;
      
      // Validate required fields
      if (!name && !code) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name or code is required'
        });
      }
      
      // Check if region exists
      const region = await db.getOne(
        'SELECT * FROM regions WHERE id = ?',
        [regionId]
      );
      
      if (!region) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Region not found'
        });
      }
      
      // Check if name is being changed and already exists
      if (name && name !== region.name) {
        const existingName = await db.getOne(
          'SELECT id FROM regions WHERE name = ? AND id != ?',
          [name, regionId]
        );
        
        if (existingName) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Region name already exists'
          });
        }
      }
      
      // Check if code is being changed and already exists
      if (code && code !== region.code) {
        const existingCode = await db.getOne(
          'SELECT id FROM regions WHERE code = ? AND id != ?',
          [code, regionId]
        );
        
        if (existingCode) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Region code already exists'
          });
        }
      }
      
      // Update region
      const updateData = {};
      if (name) updateData.name = name;
      if (code) updateData.code = code;
      
      await db.update('regions',
        updateData,
        'id = ?',
        [regionId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'region_updated',
        'regions',
        regionId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated region
      const updatedRegion = await db.getOne(
        'SELECT * FROM regions WHERE id = ?',
        [regionId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Region updated successfully',
        data: updatedRegion
      });
    } catch (error) {
      logger.error(`Update region error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/geographic/regions/:id
 * @desc    Delete region
 * @access  Private (SUPER_USER only)
 */
router.delete('/regions/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const regionId = req.params.id;
      
      // Check if region exists
      const region = await db.getOne(
        'SELECT * FROM regions WHERE id = ?',
        [regionId]
      );
      
      if (!region) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Region not found'
        });
      }
      
      // Check if region is being used
      const tinkhundlaCount = await db.getOne(
        'SELECT COUNT(*) as count FROM tinkhundla WHERE region_id = ?',
        [regionId]
      );
      
      if (tinkhundlaCount.count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete region with associated Tinkhundla'
        });
      }
      
      // Delete region
      await db.delete('regions',
        'id = ?',
        [regionId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'region_deleted',
        'regions',
        regionId,
        { name: region.name },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Region deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete region error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/geographic/tinkhundla
 * @desc    Get all Tinkhundla
 * @access  Public
 */
router.get('/tinkhundla', async (req, res) => {
  try {
    const { region_id } = req.query;
    
    let tinkhundla;
    
    if (region_id) {
      tinkhundla = await db.query(
        `SELECT t.*, r.name as region_name
         FROM tinkhundla t
         JOIN regions r ON r.id = t.region_id
         WHERE t.region_id = ?
         ORDER BY t.name`,
        [region_id]
      );
    } else {
      tinkhundla = await db.query(
        `SELECT t.*, r.name as region_name
         FROM tinkhundla t
         JOIN regions r ON r.id = t.region_id
         ORDER BY r.name, t.name`
      );
    }
    
    return res.status(200).json({
      success: true,
      data: tinkhundla
    });
  } catch (error) {
    logger.error(`Get tinkhundla error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/geographic/tinkhundla/:id
 * @desc    Get Tinkhundla by ID
 * @access  Public
 */
router.get('/tinkhundla/:id', validateParams(schemas.idParam), async (req, res) => {
  try {
    const tinkhundla = await db.getOne(
      `SELECT t.*, r.name as region_name
       FROM tinkhundla t
       JOIN regions r ON r.id = t.region_id
       WHERE t.id = ?`,
      [req.params.id]
    );
    
    if (!tinkhundla) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: 'Tinkhundla not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: tinkhundla
    });
  } catch (error) {
    logger.error(`Get tinkhundla by ID error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/geographic/tinkhundla
 * @desc    Create new Tinkhundla
 * @access  Private (SUPER_USER only)
 */
router.post('/tinkhundla', 
  authenticate, 
  requireRole('SUPER_USER'),
  async (req, res) => {
    try {
      const { name, code, region_id } = req.body;
      
      // Validate required fields
      if (!name || !code || !region_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name, code and region_id are required'
        });
      }
      
      // Check if region exists
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
      
      // Check if code already exists
      const existingCode = await db.getOne(
        'SELECT id FROM tinkhundla WHERE code = ?',
        [code]
      );
      
      if (existingCode) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Tinkhundla code already exists'
        });
      }
      
      // Create tinkhundla
      const result = await db.insert('tinkhundla', {
        name,
        code,
        region_id
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'tinkhundla_created',
        'tinkhundla',
        result.id,
        { name, code, region_id },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created tinkhundla
      const tinkhundla = await db.getOne(
        `SELECT t.*, r.name as region_name
         FROM tinkhundla t
         JOIN regions r ON r.id = t.region_id
         WHERE t.id = ?`,
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Tinkhundla created successfully',
        data: tinkhundla
      });
    } catch (error) {
      logger.error(`Create tinkhundla error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/geographic/tinkhundla/:id
 * @desc    Update Tinkhundla
 * @access  Private (SUPER_USER only)
 */
router.put('/tinkhundla/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const tinkhundlaId = req.params.id;
      const { name, code, region_id } = req.body;
      
      // Validate required fields
      if (!name && !code && !region_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name, code, or region_id is required'
        });
      }
      
      // Check if tinkhundla exists
      const tinkhundla = await db.getOne(
        'SELECT * FROM tinkhundla WHERE id = ?',
        [tinkhundlaId]
      );
      
      if (!tinkhundla) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Tinkhundla not found'
        });
      }
      
      // Check if region_id is being changed and exists
      if (region_id && region_id !== tinkhundla.region_id) {
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
      
      // Check if code is being changed and already exists
      if (code && code !== tinkhundla.code) {
        const existingCode = await db.getOne(
          'SELECT id FROM tinkhundla WHERE code = ? AND id != ?',
          [code, tinkhundlaId]
        );
        
        if (existingCode) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Tinkhundla code already exists'
          });
        }
      }
      
      // Update tinkhundla
      const updateData = {};
      if (name) updateData.name = name;
      if (code) updateData.code = code;
      if (region_id) updateData.region_id = region_id;
      
      await db.update('tinkhundla',
        updateData,
        'id = ?',
        [tinkhundlaId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'tinkhundla_updated',
        'tinkhundla',
        tinkhundlaId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated tinkhundla
      const updatedTinkhundla = await db.getOne(
        `SELECT t.*, r.name as region_name
         FROM tinkhundla t
         JOIN regions r ON r.id = t.region_id
         WHERE t.id = ?`,
        [tinkhundlaId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Tinkhundla updated successfully',
        data: updatedTinkhundla
      });
    } catch (error) {
      logger.error(`Update tinkhundla error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/geographic/tinkhundla/:id
 * @desc    Delete Tinkhundla
 * @access  Private (SUPER_USER only)
 */
router.delete('/tinkhundla/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const tinkhundlaId = req.params.id;
      
      // Check if tinkhundla exists
      const tinkhundla = await db.getOne(
        'SELECT * FROM tinkhundla WHERE id = ?',
        [tinkhundlaId]
      );
      
      if (!tinkhundla) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Tinkhundla not found'
        });
      }
      
      // Check if tinkhundla is being used
      const imphakatsiCount = await db.getOne(
        'SELECT COUNT(*) as count FROM imiphakatsi WHERE tinkhundla_id = ?',
        [tinkhundlaId]
      );
      
      if (imphakatsiCount.count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete tinkhundla with associated Imiphakatsi'
        });
      }
      
      // Delete tinkhundla
      await db.delete('tinkhundla',
        'id = ?',
        [tinkhundlaId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'tinkhundla_deleted',
        'tinkhundla',
        tinkhundlaId,
        { name: tinkhundla.name },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Tinkhundla deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete tinkhundla error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   GET /api/geographic/imiphakatsi
 * @desc    Get all Imiphakatsi
 * @access  Public
 */
router.get('/imiphakatsi', async (req, res) => {
  try {
    const { tinkhundla_id, region_id } = req.query;
    
    let imiphakatsi;
    
    if (tinkhundla_id) {
      imiphakatsi = await db.query(
        `SELECT i.*, t.name as tinkhundla_name, r.name as region_name
         FROM imiphakatsi i
         JOIN tinkhundla t ON t.id = i.tinkhundla_id
         JOIN regions r ON r.id = t.region_id
         WHERE i.tinkhundla_id = ?
         ORDER BY i.name`,
        [tinkhundla_id]
      );
    } else if (region_id) {
      imiphakatsi = await db.query(
        `SELECT i.*, t.name as tinkhundla_name, r.name as region_name
         FROM imiphakatsi i
         JOIN tinkhundla t ON t.id = i.tinkhundla_id
         JOIN regions r ON r.id = t.region_id
         WHERE t.region_id = ?
         ORDER BY t.name, i.name`,
        [region_id]
      );
    } else {
      imiphakatsi = await db.query(
        `SELECT i.*, t.name as tinkhundla_name, r.name as region_name
         FROM imiphakatsi i
         JOIN tinkhundla t ON t.id = i.tinkhundla_id
         JOIN regions r ON r.id = t.region_id
         ORDER BY r.name, t.name, i.name`
      );
    }
    
    return res.status(200).json({
      success: true,
      data: imiphakatsi
    });
  } catch (error) {
    logger.error(`Get imiphakatsi error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   GET /api/geographic/imiphakatsi/:id
 * @desc    Get Umphakatsi by ID
 * @access  Public
 */
router.get('/imiphakatsi/:id', validateParams(schemas.idParam), async (req, res) => {
  try {
    const umphakatsi = await db.getOne(
      `SELECT i.*, t.name as tinkhundla_name, r.name as region_name, t.region_id
       FROM imiphakatsi i
       JOIN tinkhundla t ON t.id = i.tinkhundla_id
       JOIN regions r ON r.id = t.region_id
       WHERE i.id = ?`,
      [req.params.id]
    );
    
    if (!umphakatsi) {
      return res.status(404).json({
        success: false,
        error: 'Not Found',
        message: 'Umphakatsi not found'
      });
    }
    
    return res.status(200).json({
      success: true,
      data: umphakatsi
    });
  } catch (error) {
    logger.error(`Get umphakatsi by ID error: ${error.message}`);
    return res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: error.message
    });
  }
});

/**
 * @route   POST /api/geographic/imiphakatsi
 * @desc    Create new Umphakatsi
 * @access  Private (SUPER_USER only)
 */
router.post('/imiphakatsi', 
  authenticate, 
  requireRole('SUPER_USER'),
  async (req, res) => {
    try {
      const { name, chief_name, chief_contact, tinkhundla_id } = req.body;
      
      // Validate required fields
      if (!name || !chief_name || !tinkhundla_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Name, chief_name, and tinkhundla_id are required'
        });
      }
      
      // Check if tinkhundla exists
      const tinkhundla = await db.getOne(
        'SELECT * FROM tinkhundla WHERE id = ?',
        [tinkhundla_id]
      );
      
      if (!tinkhundla) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'Invalid tinkhundla_id'
        });
      }
      
      // Create umphakatsi
      const result = await db.insert('imiphakatsi', {
        name,
        chief_name,
        chief_contact,
        tinkhundla_id
      });
      
      // Log activity
      await logger.activity(
        req.user.id,
        'umphakatsi_created',
        'imiphakatsi',
        result.id,
        { name, chief_name, tinkhundla_id },
        req.ip,
        req.get('User-Agent')
      );
      
      // Get created umphakatsi
      const umphakatsi = await db.getOne(
        `SELECT i.*, t.name as tinkhundla_name, r.name as region_name
         FROM imiphakatsi i
         JOIN tinkhundla t ON t.id = i.tinkhundla_id
         JOIN regions r ON r.id = t.region_id
         WHERE i.id = ?`,
        [result.id]
      );
      
      return res.status(201).json({
        success: true,
        message: 'Umphakatsi created successfully',
        data: umphakatsi
      });
    } catch (error) {
      logger.error(`Create umphakatsi error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   PUT /api/geographic/imiphakatsi/:id
 * @desc    Update Umphakatsi
 * @access  Private (SUPER_USER only)
 */
router.put('/imiphakatsi/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const umphakatsiId = req.params.id;
      const { name, chief_name, chief_contact, tinkhundla_id } = req.body;
      
      // Validate required fields
      if (!name && !chief_name && !chief_contact && !tinkhundla_id) {
        return res.status(400).json({
          success: false,
          error: 'Validation Error',
          message: 'At least one field is required'
        });
      }
      
      // Check if umphakatsi exists
      const umphakatsi = await db.getOne(
        'SELECT * FROM imiphakatsi WHERE id = ?',
        [umphakatsiId]
      );
      
      if (!umphakatsi) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Umphakatsi not found'
        });
      }
      
      // Check if tinkhundla_id is being changed and exists
      if (tinkhundla_id && tinkhundla_id !== umphakatsi.tinkhundla_id) {
        const tinkhundla = await db.getOne(
          'SELECT * FROM tinkhundla WHERE id = ?',
          [tinkhundla_id]
        );
        
        if (!tinkhundla) {
          return res.status(400).json({
            success: false,
            error: 'Validation Error',
            message: 'Invalid tinkhundla_id'
          });
        }
      }
      
      // Update umphakatsi
      const updateData = {};
      if (name) updateData.name = name;
      if (chief_name) updateData.chief_name = chief_name;
      if (chief_contact !== undefined) updateData.chief_contact = chief_contact;
      if (tinkhundla_id) updateData.tinkhundla_id = tinkhundla_id;
      
      await db.update('imiphakatsi',
        updateData,
        'id = ?',
        [umphakatsiId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'umphakatsi_updated',
        'imiphakatsi',
        umphakatsiId,
        updateData,
        req.ip,
        req.get('User-Agent')
      );
      
      // Get updated umphakatsi
      const updatedUmphakatsi = await db.getOne(
        `SELECT i.*, t.name as tinkhundla_name, r.name as region_name
         FROM imiphakatsi i
         JOIN tinkhundla t ON t.id = i.tinkhundla_id
         JOIN regions r ON r.id = t.region_id
         WHERE i.id = ?`,
        [umphakatsiId]
      );
      
      return res.status(200).json({
        success: true,
        message: 'Umphakatsi updated successfully',
        data: updatedUmphakatsi
      });
    } catch (error) {
      logger.error(`Update umphakatsi error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

/**
 * @route   DELETE /api/geographic/imiphakatsi/:id
 * @desc    Delete Umphakatsi
 * @access  Private (SUPER_USER only)
 */
router.delete('/imiphakatsi/:id', 
  authenticate, 
  requireRole('SUPER_USER'),
  validateParams(schemas.idParam),
  async (req, res) => {
    try {
      const umphakatsiId = req.params.id;
      
      // Check if umphakatsi exists
      const umphakatsi = await db.getOne(
        'SELECT * FROM imiphakatsi WHERE id = ?',
        [umphakatsiId]
      );
      
      if (!umphakatsi) {
        return res.status(404).json({
          success: false,
          error: 'Not Found',
          message: 'Umphakatsi not found'
        });
      }
      
      // Check if umphakatsi is being used by EOGs
      const eogsCount = await db.getOne(
        'SELECT COUNT(*) as count FROM eogs WHERE umphakatsi_id = ?',
        [umphakatsiId]
      );
      
      if (eogsCount.count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete umphakatsi with associated EOGs'
        });
      }
      
      // Check if umphakatsi is being used by users
      const usersCount = await db.getOne(
        'SELECT COUNT(*) as count FROM users WHERE umphakatsi_id = ?',
        [umphakatsiId]
      );
      
      if (usersCount.count > 0) {
        return res.status(400).json({
          success: false,
          error: 'Bad Request',
          message: 'Cannot delete umphakatsi with associated users'
        });
      }
      
      // Delete umphakatsi
      await db.delete('imiphakatsi',
        'id = ?',
        [umphakatsiId]
      );
      
      // Log activity
      await logger.activity(
        req.user.id,
        'umphakatsi_deleted',
        'imiphakatsi',
        umphakatsiId,
        { name: umphakatsi.name },
        req.ip,
        req.get('User-Agent')
      );
      
      return res.status(200).json({
        success: true,
        message: 'Umphakatsi deleted successfully'
      });
    } catch (error) {
      logger.error(`Delete umphakatsi error: ${error.message}`);
      return res.status(500).json({
        success: false,
        error: 'Internal Server Error',
        message: error.message
      });
    }
  }
);

module.exports = router;
