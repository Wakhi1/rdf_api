const Joi = require('joi');

// Custom validators
const idNumber = Joi.string().pattern(/^\d{13}$/).message('ID number must be exactly 13 digits');
const phoneNumber = Joi.string().pattern(/^\+268(76|78|79)\d{6}$/).message('Phone must be in format +268 [76|78|79]XXXXXX');
const binCin = Joi.string().min(5).max(50);

// Auth validation schemas
const loginSchema = Joi.object({
  username: Joi.string().required(),
  password: Joi.string().required()
});

const refreshTokenSchema = Joi.object({
  refreshToken: Joi.string().required()
});

const changePasswordSchema = Joi.object({
  currentPassword: Joi.string().required(),
  newPassword: Joi.string().min(8).required()
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
    .message('Password must contain at least one uppercase, lowercase, number and special character')
});

const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required()
});

const resetPasswordSchema = Joi.object({
  token: Joi.string().required(),
  password: Joi.string().min(8).required()
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
    .message('Password must contain at least one uppercase, lowercase, number and special character')
});

// User validation schemas
const createUserSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required()
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
    .message('Password must contain at least one uppercase, lowercase, number and special character'),
  role: Joi.string().valid('CDO', 'LINE_MINISTRY', 'MICROPROJECTS', 'CDC', 'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC', 'PS', 'SUPER_USER').required(),
  first_name: Joi.string().min(2).max(50).required(),
  last_name: Joi.string().min(2).max(50).required(),
  phone: phoneNumber.optional(),
  region_id: Joi.number().integer().optional(),
  tinkhundla_id: Joi.number().integer().optional(),
  umphakatsi_id: Joi.number().integer().optional(),
  ministry: Joi.string().max(100).optional()
});

const updateUserSchema = Joi.object({
  email: Joi.string().email().optional(),
  first_name: Joi.string().min(2).max(50).optional(),
  last_name: Joi.string().min(2).max(50).optional(),
  phone: phoneNumber.optional(),
  status: Joi.string().valid('active', 'inactive', 'suspended').optional(),
  region_id: Joi.number().integer().optional(),
  tinkhundla_id: Joi.number().integer().optional(),
  umphakatsi_id: Joi.number().integer().optional(),
  ministry: Joi.string().max(100).optional()
}).min(1);

// EOG validation schemas
const eogExpressionOfInterestSchema = Joi.object({
  company_name: Joi.string().min(3).max(200).required(),
  company_type: Joi.string().valid('Association', 'Cooperative', 'Company', 'Community Group', 'Scheme', 'Partnership').required(),
  bin_cin: binCin.required(),
  email: Joi.string().email().required(),
  phone: phoneNumber.required(),
  region_id: Joi.number().integer().required(),
  tinkhundla_id: Joi.number().integer().required(),
  umphakatsi_id: Joi.number().integer().required(),
  total_members: Joi.number().integer().min(10).required(),
  executive_members: Joi.array().min(10).items(
    Joi.object({
      id_number: idNumber.required(),
      first_name: Joi.string().min(2).max(50).required(),
      surname: Joi.string().min(2).max(50).required(),
      gender: Joi.string().valid('Male', 'Female').required(),
      contact_number: phoneNumber.required(),
      position: Joi.string().min(2).max(100).required()
    })
  ).required()
});

const eogLoginCredentialsSchema = Joi.object({
  eog_id: Joi.number().integer().required(),
  username: Joi.string().alphanum().min(3).max(50).required(),
  password: Joi.string().min(8).required()
    .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
    .message('Password must contain at least one uppercase, lowercase, number and special character'),
  confirm_password: Joi.string().valid(Joi.ref('password')).required().messages({
    'any.only': 'Passwords do not match'
  })
});

// Training register validation
const trainingRegisterSchema = Joi.object({
  id_number: idNumber.required(),
  first_name: Joi.string().min(2).max(50).required(),
  surname: Joi.string().min(2).max(50).required(),
  gender: Joi.string().valid('Male', 'Female').required(),
  contact_number: phoneNumber.optional(),
  region_id: Joi.number().integer().required(),
  training_date: Joi.date().max('now').required(),
  training_type: Joi.string().max(100).optional(),
  certificate_number: Joi.string().max(50).optional()
});

// Form validation schemas
const createFormSchema = Joi.object({
  name: Joi.string().min(3).max(200).required(),
  description: Joi.string().optional(),
  version: Joi.string().max(20).default('1.0')
});

const createSectionSchema = Joi.object({
  form_id: Joi.number().integer().required(),
  parent_section_id: Joi.number().integer().optional(),
  title: Joi.string().min(3).max(200).required(),
  description: Joi.string().optional(),
  order_number: Joi.number().integer().default(0),
  workflow_level: Joi.string().valid(
    'EOG_LEVEL', 'MINISTRY_LEVEL', 'MICROPROJECTS_LEVEL', 'CDO_LEVEL',
    'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', 'RDFTC_LEVEL', 'RDFC_LEVEL',
    'PS_LEVEL', 'PROCUREMENT_LEVEL', 'IMPLEMENTATION_LEVEL'
  ).optional()
});

const createQuestionSchema = Joi.object({
  section_id: Joi.number().integer().required(),
  question_text: Joi.string().min(3).required(),
  question_type: Joi.string().valid(
    'text', 'textarea', 'number', 'decimal', 'date', 'time', 'datetime',
    'select', 'multiselect', 'radio', 'checkbox', 'file', 'signature'
  ).required(),
  required: Joi.boolean().default(false),
  order_number: Joi.number().integer().default(0),
  validation_rules: Joi.object().optional(),
  options: Joi.array().items(Joi.string()).optional(),
  can_answer: Joi.array().items(Joi.string().valid(
    'EOG', 'CDO', 'LINE_MINISTRY', 'MICROPROJECTS', 'CDC', 
    'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC', 'PS', 'SUPER_USER'
  )).optional(),
  can_view: Joi.array().items(Joi.string().valid(
    'EOG', 'CDO', 'LINE_MINISTRY', 'MICROPROJECTS', 'CDC', 
    'INKHUNDLA_COUNCIL', 'RDFTC', 'RDFC', 'PS', 'SUPER_USER'
  )).optional()
});

// Application validation schemas
const createApplicationSchema = Joi.object({
  form_id: Joi.number().integer().required(),
  eog_id: Joi.number().integer().required()
});

const submitAnswerSchema = Joi.object({
  question_id: Joi.number().integer().required(),
  answer_value: Joi.alternatives().try(
    Joi.string(),
    Joi.number(),
    Joi.array(),
    Joi.object()
  ).required()
});

const approveApplicationSchema = Joi.object({
  otp: Joi.string().length(6).required(),
  comments: Joi.string().optional()
});

const returnApplicationSchema = Joi.object({
  return_to_level: Joi.string().valid(
    'EOG_LEVEL', 'MINISTRY_LEVEL', 'MICROPROJECTS_LEVEL', 'CDO_LEVEL',
    'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', 'RDFTC_LEVEL', 'RDFC_LEVEL',
    'PS_LEVEL', 'PROCUREMENT_LEVEL'
  ).required(),
  return_to_user_id: Joi.number().integer().optional(),
  reason: Joi.string().min(10).required()
});

const recommendApplicationSchema = Joi.object({
  reason: Joi.string().min(10).required(),
  otp: Joi.string().length(6).required()
});

// Monitoring validation schemas
const updateBudgetSchema = Joi.object({
  category: Joi.string().required(),
  budgeted_amount: Joi.number().positive().required(),
  actual_amount: Joi.number().positive().optional(),
  variance: Joi.number().optional(),
  notes: Joi.string().optional()
});

const recordDisbursementSchema = Joi.object({
  amount: Joi.number().positive().required(),
  disbursement_date: Joi.date().required(),
  disbursement_method: Joi.string().valid('bank_transfer', 'cheque', 'cash', 'mobile_money').required(),
  reference_number: Joi.string().required(),
  approved_by: Joi.number().integer().required(),
  notes: Joi.string().optional()
});

// Validation middleware
const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors
      });
    }

    req.validatedData = value;
    next();
  };
};

module.exports = {
  validate,
  schemas: {
    // Auth
    loginSchema,
    refreshTokenSchema,
    changePasswordSchema,
    forgotPasswordSchema,
    resetPasswordSchema,
    // User
    createUserSchema,
    updateUserSchema,
    // EOG
    eogExpressionOfInterestSchema,
    eogLoginCredentialsSchema,
    // Training
    trainingRegisterSchema,
    // Form
    createFormSchema,
    createSectionSchema,
    createQuestionSchema,
    // Application
    createApplicationSchema,
    submitAnswerSchema,
    approveApplicationSchema,
    returnApplicationSchema,
    recommendApplicationSchema,
    // Monitoring
    updateBudgetSchema,
    recordDisbursementSchema
  }
};