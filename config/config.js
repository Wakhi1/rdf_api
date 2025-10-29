require('dotenv').config();

const config = {
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'rdf_sys',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRY || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRY || '7d'
  },
  bcrypt: {
    saltRounds: parseInt(process.env.BCRYPT_ROUNDS) || 10
  },
  smtp: {
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT) || 587,
    user: process.env.SMTP_USER,
    password: process.env.SMTP_PASS, // Changed from SMTP_PASSWORD to SMTP_PASS
    from: process.env.SMTP_FROM || 'RDF System <noreply@rdf.gov.sz>'
  },
  upload: {
    dir: process.env.UPLOAD_DIR || './uploads',
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 // 10MB
  },
  server: {
    port: parseInt(process.env.PORT) || 3000,
    env: process.env.NODE_ENV || 'development'
  },
  frontend: {
    url: process.env.FRONTEND_URL || 'http://localhost:4200' // Add this section
  },
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:4200',
    credentials: true
  },
  roles: [
    'EOG', 
    'CDO', 
    'LINE_MINISTRY', 
    'MICROPROJECTS', 
    'CDC', 
    'INKHUNDLA_COUNCIL',
    'RDFTC', 
    'RDFC', 
    'PS', 
    'SUPER_USER'
  ],
  workflowLevels: [
    'EOG_LEVEL',
    'MINISTRY_LEVEL', 
    'MICROPROJECTS_LEVEL',
    'CDO_LEVEL',
    'UMPHAKATSI_LEVEL', 
    'INKHUNDLA_LEVEL', 
    'RDFTC_LEVEL', 
    'RDFC_LEVEL', 
    'PS_LEVEL',
    'PROCUREMENT_LEVEL',
    'IMPLEMENTATION_LEVEL'
  ]
};

module.exports = config;