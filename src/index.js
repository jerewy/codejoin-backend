const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');
const winston = require('winston');
const path = require('path');
const CodeExecutionService = require('./codeExecution');

// Load environment variables
dotenv.config();

// Initialize logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

// Create Express app
const app = express();
const PORT = process.env.PORT || 3001;

// Initialize Code Execution Service
const codeExecutionService = new CodeExecutionService();

// Security middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  }
});
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API routes
app.get('/api', (req, res) => {
  res.json({
    message: 'Code Execution Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      execute: '/api/execute (POST)',
      status: '/api/status/:id (GET)'
    }
  });
});

// Code execution endpoint
app.post('/api/execute', async (req, res) => {
  try {
    const result = await codeExecutionService.executeCode(req.body);
    res.status(202).json(result);
  } catch (error) {
    logger.error('Code execution error:', error);
    res.status(400).json({
      error: 'Code execution failed',
      message: error.message
    });
  }
});

// Status endpoint
app.get('/api/status/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const execution = await codeExecutionService.getExecutionStatus(id);
    res.json(execution);
  } catch (error) {
    logger.error('Status check error:', error);
    res.status(404).json({
      error: 'Execution not found',
      message: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Not found',
    message: 'The requested resource was not found'
  });
});

// Start server
app.listen(PORT, async () => {
  try {
    await codeExecutionService.initialize();
    logger.info(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
    logger.info('Code execution service initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize code execution service:', error);
    process.exit(1);
  }
});

module.exports = app;