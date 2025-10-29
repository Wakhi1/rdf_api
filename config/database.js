const mysql = require('mysql2/promise');

// Create connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'rdf_sys',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  timezone: '+00:00',
  dateStrings: true
});

// Test connection
pool.getConnection()
  .then(connection => {
    console.log('Database pool created successfully');
    connection.release();
  })
  .catch(err => {
    console.error('Database pool creation failed:', err.message);
  });

// Helper function to execute queries
const query = async (sql, params = []) => {
  try {
    const [rows] = await pool.execute(sql, params);
    return rows;
  } catch (error) {
    console.error('Query error:', error.message);
    throw error;
  }
};

// Helper function for transactions
const transaction = async (callback) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

// Helper function to get single row
const queryOne = async (sql, params = []) => {
  const rows = await query(sql, params);
  return rows.length > 0 ? rows[0] : null;
};

// Raw query function (for testing)
const raw = async (sql) => {
  const [rows] = await pool.query(sql);
  return rows;
};

module.exports = {
  pool,
  query,
  queryOne,
  transaction,
  raw,
  destroy: () => pool.end()
};