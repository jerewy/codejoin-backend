const Docker = require('dockerode');
const { v4: uuidv4 } = require('uuid');
const winston = require('winston');
const Joi = require('joi');

// Initialize Docker
const docker = new Docker();

// Redis is optional - use in-memory storage if not available
let redisClient = null;
if (process.env.REDIS_URL) {
  try {
    const redis = require('redis');
    redisClient = redis.createClient({
      url: process.env.REDIS_URL
    });
    redisClient.on('error', (err) => {
      logger.warn('Redis connection error, falling back to memory storage:', err.message);
      redisClient = null;
    });
  } catch (error) {
    logger.warn('Redis not available, using memory storage:', error.message);
  }
}

// In-memory storage fallback
const memoryStorage = new Map();

// Logger
const logger = winston.createLogger({
  level: 'debug', // Enable debug logging
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'code-execution.log' })
  ]
});

// Language configurations
const LANGUAGE_CONFIG = {
  javascript: {
    image: 'node:18-alpine',
    extension: '.js',
    runCommand: (filename) => `node ${filename}`,
    codeTemplate: (code) => code
  },
  python: {
    image: 'python:3.11-alpine',
    extension: '.py',
    runCommand: (filename) => `python ${filename}`,
    codeTemplate: (code) => code
  },
  java: {
    image: 'openjdk:17-alpine',
    extension: '.java',
    runCommand: (filename) => {
      const className = filename.replace('.java', '');
      return `javac ${filename} && java ${className}`;
    },
    codeTemplate: (code) => code
  },
  cpp: {
    image: 'gcc:latest',
    extension: '.cpp',
    runCommand: (filename) => {
      const executable = filename.replace('.cpp', '');
      return `g++ -o ${executable} ${filename} && ./${executable}`;
    },
    codeTemplate: (code) => code
  },
  c: {
    image: 'gcc:latest',
    extension: '.c',
    runCommand: (filename) => {
      const executable = filename.replace('.c', '');
      return `gcc -o ${executable} ${filename} && ./${executable}`;
    },
    codeTemplate: (code) => code
  }
};

// Input validation schema
const executionRequestSchema = Joi.object({
  language: Joi.string().valid('javascript', 'python', 'java', 'cpp', 'c').required(),
  code: Joi.string().max(50000).required(),
  input: Joi.string().max(10000).allow('').optional(),
  timeout: Joi.number().min(1).default(10)
});

class CodeExecutionService {
  constructor() {
    this.executions = new Map();
  }

  async initialize() {
    try {
      if (redisClient) {
        await redisClient.connect();
        logger.info('Code execution service initialized with Redis');
      } else {
        logger.info('Code execution service initialized with memory storage');
      }
    } catch (error) {
      logger.warn('Redis initialization failed, using memory storage:', error.message);
      redisClient = null;
    }
  }

  async executeCode(executionRequest) {
    // Log the incoming request for debugging
    logger.info('Received execution request:', {
      language: executionRequest.language,
      timeout: executionRequest.timeout,
      codeLength: executionRequest.code?.length || 0
    });

    // Convert timeout from milliseconds to seconds if it's large (> 100)
    if (executionRequest.timeout && executionRequest.timeout > 1000) {
      executionRequest.timeout = Math.ceil(executionRequest.timeout / 1000);
    }

    const { error, value } = executionRequestSchema.validate(executionRequest);
    if (error) {
      throw new Error(`Validation error: ${error.details[0].message}`);
    }

    const executionId = uuidv4();
    const { language, code, input, timeout } = value;

    const execution = {
      id: executionId,
      status: 'pending',
      language,
      code,
      input,
      timeout,
      startTime: new Date().toISOString(),
      endTime: null,
      output: null,
      error: null
    };

    try {
      // Store execution in Redis
      await this.storeExecution(executionId, execution);

      // Execute code asynchronously
      this.runCode(executionId, language, code, input, timeout);

      return {
        executionId,
        status: 'pending',
        message: 'Code execution started'
      };
    } catch (error) {
      execution.status = 'failed';
      execution.error = error.message;
      execution.endTime = new Date().toISOString();
      await this.storeExecution(executionId, execution);
      throw error;
    }
  }

  async getExecutionStatus(executionId) {
    try {
      const execution = await this.getExecution(executionId);
      if (!execution) {
        throw new Error('Execution not found');
      }
      return execution;
    } catch (error) {
      throw new Error(`Failed to get execution status: ${error.message}`);
    }
  }

  async storeExecution(executionId, execution) {
    if (redisClient) {
      try {
        await redisClient.setEx(
          `execution:${executionId}`,
          3600, // 1 hour expiry
          JSON.stringify(execution)
        );
      } catch (error) {
        logger.warn('Redis storage failed, using memory:', error.message);
        memoryStorage.set(executionId, execution);
      }
    } else {
      memoryStorage.set(executionId, execution);
    }
  }

  async getExecution(executionId) {
    if (redisClient) {
      try {
        const data = await redisClient.get(`execution:${executionId}`);
        return data ? JSON.parse(data) : null;
      } catch (error) {
        logger.warn('Redis retrieval failed, using memory:', error.message);
        return memoryStorage.get(executionId);
      }
    } else {
      return memoryStorage.get(executionId);
    }
  }

  async runCode(executionId, language, code, input, timeout) {
    const execution = await this.getExecution(executionId);
    const config = LANGUAGE_CONFIG[language];

    if (!config) {
      throw new Error(`Unsupported language: ${language}`);
    }

    let container;
    let timeoutHandle;
    try {
      logger.info(`Starting ${language} execution with timeout: ${timeout}s`);

      // Create container
      container = await docker.createContainer({
        Image: config.image,
        Cmd: ['sh', '-c', `echo '${code.replace(/'/g, "'\"'\"'")}' > main${config.extension} && ${config.runCommand(`main${config.extension}`)}`],
        WorkingDir: '/app',
        HostConfig: {
          Memory: 128 * 1024 * 1024, // 128MB limit
          CpuQuota: 50000, // Limit CPU usage
          NetworkMode: 'none', // No network access
          ReadonlyRootfs: true,
          Tmpfs: {
            '/app': 'rw,size=10m'
          }
        },
        AttachStdout: true,
        AttachStderr: true
      });

      logger.info(`Container created for ${language} execution`);

      // Start container
      await container.start();

      logger.info(`Container started, waiting for execution...`);

      // Set timeout so long-running code cannot hang the worker
      const timeoutPromise = new Promise((_, reject) => {
        timeoutHandle = setTimeout(() => reject(new Error('Execution timeout')), timeout * 1000);
      });

      // Wait for the container to exit before attempting to collect logs
      const executionPromise = (async () => {
        await container.wait();
        return this.getContainerOutput(container);
      })();

      const result = await Promise.race([
        executionPromise,
        timeoutPromise
      ]);

      clearTimeout(timeoutHandle);

      logger.info(`Execution completed for ${language}`, {
        stdoutLength: result.stdout?.length || 0,
        stderrLength: result.stderr?.length || 0
      });

      // Clean up container
      await container.remove({ force: true });

      // Update execution with results
      execution.status = 'completed';
      execution.output = result.stdout;
      execution.error = result.stderr;
      execution.endTime = new Date().toISOString();

    } catch (error) {
      logger.error(`Execution failed for ${language}:`, error);
      execution.status = 'failed';
      execution.error = error.message;
      execution.endTime = new Date().toISOString();

      if (container) {
        try {
          // Stop the container quickly if it's still running (e.g., timeout)
          await container.stop({ t: 0 });
        } catch (stopError) {
          logger.debug('Container stop skipped or failed (likely already exited):', stopError.message);
        }
        try {
          await container.remove({ force: true });
        } catch (cleanupError) {
          logger.error('Failed to cleanup container:', cleanupError);
        }
      }
    }

    await this.storeExecution(executionId, execution);
    logger.info(`Execution result stored for ${language}`, {
      status: execution.status,
      hasOutput: !!execution.output,
      outputLength: execution.output?.length || 0
    });

    if (timeoutHandle) {
      clearTimeout(timeoutHandle);
    }
  }

  async getContainerOutput(container) {
    try {
      // First try to get logs from container
      let logs;
      try {
        logs = await container.logs({
          stdout: true,
          stderr: true,
          timestamps: false,
          follow: false,
          tail: 100
        });
      } catch (logError) {
        logger.warn('Failed to get container logs, trying alternative method:', logError);

        // Alternative: Wait for container to finish and get exit info
        const containerInfo = await container.inspect();
        logger.debug('Container info:', {
          state: containerInfo.State,
          exitCode: containerInfo.State.ExitCode,
          status: containerInfo.State.Status
        });

        // If logs are empty but container succeeded, try a different approach
        if (containerInfo.State.ExitCode === 0) {
          logger.info('Container succeeded but no logs - this might be expected for simple programs');
          return {
            stdout: 'Program executed successfully',
            stderr: ''
          };
        } else {
          return {
            stdout: '',
            stderr: `Container failed with exit code ${containerInfo.State.ExitCode}`
          };
        }
      }

      const outputBuffer = Buffer.isBuffer(logs) ? logs : Buffer.from(logs || '');
      logger.debug('Raw Docker logs:', {
        logLength: outputBuffer.length,
        hasLogs: outputBuffer.length > 0,
        preview: outputBuffer.length > 0 ? outputBuffer.toString('utf8', 0, Math.min(200, outputBuffer.length)) : 'No logs'
      });

      if (outputBuffer.length > 0) {
        const parsed = this.parseDockerLogs(outputBuffer);

        logger.debug('Parsed Docker output:', {
          stdoutLength: parsed.stdout.length,
          stderrLength: parsed.stderr.length,
          stdoutPreview: parsed.stdout.substring(0, 100),
          stderrPreview: parsed.stderr.substring(0, 100)
        });

        return parsed;
      } else {
        // No logs but container might have run successfully
        logger.info('No logs captured, checking container status');
        const containerInfo = await container.inspect();

        if (containerInfo.State.ExitCode === 0) {
          return {
            stdout: 'Program executed successfully (no output captured)',
            stderr: ''
          };
        } else {
          return {
            stdout: '',
            stderr: `Container exited with code ${containerInfo.State.ExitCode}`
          };
        }
      }
    } catch (error) {
      logger.error('Failed to get container output:', error);
      return {
        stdout: '',
        stderr: `Error capturing output: ${error.message}`
      };
    }
  }

  parseDockerLogs(buffer) {
    const stdout = [];
    const stderr = [];
    let offset = 0;

    while (offset + 8 <= buffer.length) {
      const streamType = buffer.readUInt8(offset);
      const frameLength = buffer.readUInt32BE(offset + 4);
      const frameStart = offset + 8;
      const frameEnd = frameStart + frameLength;

      if (frameEnd > buffer.length) {
        break;
      }

      const chunk = buffer.slice(frameStart, frameEnd).toString('utf8');
      if (streamType === 1) {
        stdout.push(chunk);
      } else if (streamType === 2) {
        stderr.push(chunk);
      } else {
        stdout.push(chunk);
      }

      offset = frameEnd;
    }

    // If nothing was parsed using the Docker framing, treat the payload as plain text
    if (stdout.length === 0 && stderr.length === 0) {
      const fallback = buffer.toString('utf8');
      return {
        stdout: fallback.trim(),
        stderr: ''
      };
    }

    return {
      stdout: stdout.join('').trim(),
      stderr: stderr.join('').trim()
    };
  }
}

module.exports = CodeExecutionService;
