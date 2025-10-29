const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

// Ensure upload directories exist
const createUploadDirs = () => {
  const dirs = [
    './uploads',
    './uploads/eog-documents',
    './uploads/application-files',
    './uploads/member-lists',
    './uploads/signatures',
    './uploads/temp'
  ];

  dirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
};

createUploadDirs();

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let uploadPath = './uploads/temp';

    // Determine upload path based on field name
    if (file.fieldname.includes('document')) {
      uploadPath = './uploads/eog-documents';
    } else if (file.fieldname.includes('member_list')) {
      uploadPath = './uploads/member-lists';
    } else if (file.fieldname.includes('signature')) {
      uploadPath = './uploads/signatures';
    } else if (file.fieldname.includes('application')) {
      uploadPath = './uploads/application-files';
    }

    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = (process.env.ALLOWED_FILE_TYPES || 'pdf,jpg,jpeg,png,xlsx,xls').split(',');
  const fileExt = path.extname(file.originalname).toLowerCase().substring(1);

  if (allowedTypes.includes(fileExt)) {
    cb(null, true);
  } else {
    cb(new Error(`File type .${fileExt} is not allowed. Allowed types: ${allowedTypes.join(', ')}`), false);
  }
};

// Configure multer
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB default
    files: 10
  }
});

// Upload configurations for different purposes
const uploadConfigs = {
  // Single file upload
  single: (fieldName) => upload.single(fieldName),

  // Multiple files upload
  multiple: (fieldName, maxCount = 10) => upload.array(fieldName, maxCount),

  // EOG documents upload (5 required documents + 1 member list)
  eogDocuments: upload.fields([
    { name: 'constitution', maxCount: 1 },
    { name: 'recognition_letter', maxCount: 1 },
    { name: 'articles', maxCount: 1 },
    { name: 'form_j', maxCount: 1 },
    { name: 'certificate', maxCount: 1 },
    { name: 'member_list', maxCount: 1 }
  ]),

  // Application file upload
  applicationFile: upload.single('application_file'),

  // Signature upload
  signature: upload.single('signature')
};

// Helper function to delete file
const deleteFile = (filePath) => {
  try {
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      return true;
    }
    return false;
  } catch (error) {
    console.error('Error deleting file:', error);
    return false;
  }
};

// Helper function to get file info
const getFileInfo = (file) => {
  return {
    originalName: file.originalname,
    fileName: file.filename,
    filePath: file.path,
    fileSize: file.size,
    mimeType: file.mimetype,
    uploadedAt: new Date()
  };
};

// Helper function to validate file size
const validateFileSize = (file, maxSizeMB = 10) => {
  const maxSizeBytes = maxSizeMB * 1024 * 1024;
  return file.size <= maxSizeBytes;
};

// Helper function to validate EOG documents
const validateEOGDocuments = (files) => {
  const requiredDocs = ['constitution', 'recognition_letter', 'articles', 'form_j', 'certificate'];
  const errors = [];

  requiredDocs.forEach(doc => {
    if (!files[doc] || files[doc].length === 0) {
      errors.push(`${doc.replace('_', ' ')} is required`);
    }
  });

  // Validate file sizes
  Object.keys(files).forEach(key => {
    if (files[key] && files[key].length > 0) {
      const file = files[key][0];
      let maxSize = 10; // Default 10MB

      if (key === 'recognition_letter' || key === 'form_j' || key === 'certificate') {
        maxSize = 5; // 5MB for smaller documents
      }

      if (!validateFileSize(file, maxSize)) {
        errors.push(`${key.replace('_', ' ')} exceeds maximum size of ${maxSize}MB`);
      }
    }
  });

  return {
    valid: errors.length === 0,
    errors
  };
};

// Middleware to handle upload errors
const handleUploadError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        status: 'error',
        message: 'File too large',
        details: `Maximum file size is ${process.env.MAX_FILE_SIZE / (1024 * 1024)}MB`
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        status: 'error',
        message: 'Too many files'
      });
    }
    if (error.code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        status: 'error',
        message: 'Unexpected file field'
      });
    }
  }

  if (error.message) {
    return res.status(400).json({
      status: 'error',
      message: error.message
    });
  }

  next(error);
};

module.exports = {
  upload,
  uploadConfigs,
  deleteFile,
  getFileInfo,
  validateFileSize,
  validateEOGDocuments,
  handleUploadError
};
