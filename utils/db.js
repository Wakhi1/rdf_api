const mysql = require('mysql2/promise');
const config = require('../config/config');
const logger = require('./logger');

// Create connection pool
const pool = mysql.createPool(config.database);

// Test database connection
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    logger.info('Database connection established successfully');
    connection.release();
    return true;
  } catch (error) {
    logger.error(`Database connection failed: ${error.message}`);
    throw error;
  }
};

module.exports = {
  pool,
  testConnection,
  
  // Helper functions for common query patterns
  async query(sql, params = []) {
    try {
      const [results] = await pool.query(sql, params);
      return results;
    } catch (error) {
      logger.error(`Database query error: ${error.message}`);
      logger.error(`Query: ${sql}`);
      logger.error(`Params: ${JSON.stringify(params)}`);
      throw error;
    }
  },
  
  async getOne(sql, params = []) {
    try {
      const results = await this.query(sql, params);
      return results[0] || null;
    } catch (error) {
      logger.error(`getOne error: ${error.message}`);
      throw error;
    }
  },
  
  async insert(table, data) {
    try {
      const keys = Object.keys(data);
      const values = Object.values(data);
      const placeholders = keys.map(() => '?').join(', ');
      
      const sql = `INSERT INTO ${table} (${keys.join(', ')}) VALUES (${placeholders})`;
      const [result] = await pool.query(sql, values);
      
      return {
        id: result.insertId,
        affectedRows: result.affectedRows
      };
    } catch (error) {
      logger.error(`Insert error: ${error.message}`);
      throw error;
    }
  },
  
  async update(table, data, where, whereParams = []) {
    try {
      const keys = Object.keys(data);
      const values = Object.values(data);
      
      const setClause = keys.map(key => `${key} = ?`).join(', ');
      const sql = `UPDATE ${table} SET ${setClause} WHERE ${where}`;
      
      const [result] = await pool.query(sql, [...values, ...whereParams]);
      
      return {
        affectedRows: result.affectedRows
      };
    } catch (error) {
      logger.error(`Update error: ${error.message}`);
      throw error;
    }
  },
  
  async delete(table, where, whereParams = []) {
    try {
      const sql = `DELETE FROM ${table} WHERE ${where}`;
      const [result] = await pool.query(sql, whereParams);
      
      return {
        affectedRows: result.affectedRows
      };
    } catch (error) {
      logger.error(`Delete error: ${error.message}`);
      throw error;
    }
  },
  
  async beginTransaction() {
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    return connection;
  },
  
  async commit(connection) {
    await connection.commit();
    connection.release();
  },
  
  async rollback(connection) {
    await connection.rollback();
    connection.release();
  }
};
