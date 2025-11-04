const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');
const config = require('./config/config');
const db = require('./utils/db');
const logger = require('./utils/logger');

// Initialize express app
const app = express();

// Create logs and uploads directories if they don't exist
const logDir = path.join(process.cwd(), 'logs');
const uploadDir = path.join(process.cwd(), config.upload.dir);

if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Middlewares
app.use(helmet());
app.use(cors(config.cors));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Setup logging
app.use(morgan('combined', { 
  stream: { 
    write: message => logger.http(message.trim()) 
  } 
}));

// Serve uploads as static files
app.use('/uploads', express.static(path.join(process.cwd(), config.upload.dir)));

// Import routes
const authRoutes = require('./routes/auth.routes');
const eogRegistrationRoutes = require('./routes/eog.registration.routes');
const cdoRoutes = require('./routes/cdo.routes');
const applicationRoutes = require('./routes/application.routes');
const formRoutes = require('./routes/forms.routes');
const workflowRoutes = require('./routes/workflow.routes');
const committeeRoutes = require('./routes/committee.routes');
const microprojectsRoutes = require('./routes/microprojects.routes');
const monitoringRoutes = require('./routes/monitoring.routes');
const geographicRoutes = require('./routes/geographic.routes');
const trainingRoutes = require('./routes/training.routes');
const reportsRoutes = require('./routes/reports.routes');
const adminRoutes = require('./routes/admin.routes');
const statisticsRoutes = require('./routes/statistics.routes');

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/registration', eogRegistrationRoutes);
app.use('/api/cdo', cdoRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/forms', formRoutes),
app.use('/api/workflow', workflowRoutes);
app.use('/api/committees', committeeRoutes);
app.use('/api/microprojects', microprojectsRoutes);
app.use('/api/monitoring', monitoringRoutes);
app.use('/api/geographic', geographicRoutes);
app.use('/api/training', trainingRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/statistics', statisticsRoutes);

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    // Check database connection
    await db.testConnection();
    
    res.status(200).json({
      success: true,
      message: 'Server is healthy',
      timestamp: new Date()
    });
  } catch (error) {
    logger.error(`Health check failed: ${error.message}`);
    res.status(500).json({
      success: false,
      error: 'Internal Server Error',
      message: 'Database connection failed'
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'RDF System API',
    version: '1.0.0'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Not Found',
    message: `Route ${req.method} ${req.url} not found`
  });
});

// Error handler
app.use((err, req, res, next) => {
  logger.error(`Unhandled error: ${err.message}`);
  
  res.status(err.status || 500).json({
    success: false,
    error: err.name || 'Internal Server Error',
    message: err.message || 'An unexpected error occurred'
  });
});

// Start server
const PORT = config.server.port;

const startServer = async () => {
  try {
    // Test database connection
    await db.testConnection();
    
    // Start server
    app.listen(PORT, () => {
      logger.info(`Server running on port ${PORT} in ${config.server.env} mode`);
    });
  } catch (error) {
    logger.error(`Failed to start server: ${error.message}`);
    process.exit(1);
  }
};

startServer();

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error(`Unhandled Promise Rejection: ${reason}`);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error(`Uncaught Exception: ${err.message}`);
  process.exit(1);
});

module.exports = app; // For testing
