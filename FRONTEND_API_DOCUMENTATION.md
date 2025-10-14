# CodeJoin Backend API Documentation

## Overview

This document provides comprehensive API documentation for connecting the frontend with the CodeJoin backend service. The backend provides secure code execution capabilities with Docker isolation, AI resilience features, and comprehensive monitoring.

**Base URL**: `https://your-backend-url.com` (or `http://localhost:3001` for development)

## API Version

Current API Version: `1.0.0`

## Authentication

The backend uses API key authentication. Include the API key in the request headers:

```http
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

## Core Endpoints

### 1. Health Check

#### GET /health

Check the overall health status of the backend service.

**Response**:

```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "environment": "production"
}
```

**Status Codes**:

- `200` - Service is healthy
- `503` - Service is unhealthy

---

### 2. API Information

#### GET /api

Get basic API information and available endpoints.

**Response**:

```json
{
  "message": "Code Execution Backend API",
  "version": "1.0.0",
  "endpoints": {
    "health": "/health",
    "execute": "/api/execute (POST)",
    "status": "/api/status/:id (GET)"
  }
}
```

---

### 3. Code Execution

#### POST /api/execute

Execute code in a secure Docker container.

**Request Body**:

```json
{
  "language": "python",
  "code": "print('Hello, World!')",
  "input": "optional input data",
  "timeout": 10000
}
```

**Parameters**:

- `language` (string, required): Programming language (python, javascript, java, etc.)
- `code` (string, required): Code to execute
- `input` (string, optional): Input data for the program
- `timeout` (number, optional): Execution timeout in milliseconds (default: 10000)

**Response**:

```json
{
  "id": "execution-id-123",
  "status": "completed",
  "output": "Hello, World!\n",
  "error": null,
  "executionTime": 1500,
  "memoryUsage": 1048576,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Status Codes**:

- `200` - Execution completed successfully
- `202` - Execution started (async mode)
- `400` - Bad request (invalid parameters)
- `408` - Execution timeout
- `429` - Rate limit exceeded
- `500` - Internal server error

---

### 4. Execution Status

#### GET /api/status/:id

Check the status of a code execution request.

**Parameters**:

- `id` (string, required): Execution ID returned from `/api/execute`

**Response**:

```json
{
  "id": "execution-id-123",
  "status": "completed",
  "output": "Hello, World!\n",
  "error": null,
  "executionTime": 1500,
  "memoryUsage": 1048576,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

**Status Values**:

- `pending` - Execution is queued
- `running` - Execution is in progress
- `completed` - Execution finished successfully
- `failed` - Execution failed
- `timeout` - Execution timed out

---

## Enhanced Endpoints

### 5. Detailed Health Check

#### GET /api/health/detailed

Get comprehensive health status of all system components.

**Response**:

```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "services": {
    "docker": {
      "status": "healthy",
      "version": "20.10.0",
      "containers": 3
    },
    "ai": {
      "status": "healthy",
      "providers": {
        "gemini": "healthy",
        "openai": "healthy",
        "anthropic": "degraded"
      }
    },
    "redis": {
      "status": "healthy",
      "connected": true
    }
  },
  "metrics": {
    "memoryUsage": "45%",
    "cpuUsage": "12%",
    "activeConnections": 5
  }
}
```

---

### 6. Docker Health Check

#### GET /api/health/docker

Check Docker service availability and status.

**Response**:

```json
{
  "status": "healthy",
  "docker": {
    "version": "20.10.0",
    "apiVersion": "1.41",
    "containers": {
      "running": 2,
      "stopped": 1,
      "total": 3
    },
    "images": 15,
    "memoryUsage": "2.1GB"
  }
}
```

---

### 7. AI Service Health Check

#### GET /api/health/ai

Check AI service provider availability and status.

**Response**:

```json
{
  "status": "healthy",
  "providers": {
    "gemini": {
      "status": "healthy",
      "responseTime": 150,
      "lastCheck": "2024-01-01T00:00:00.000Z",
      "model": "gemini-1.5-flash"
    },
    "openai": {
      "status": "healthy",
      "responseTime": 200,
      "lastCheck": "2024-01-01T00:00:00.000Z",
      "model": "gpt-3.5-turbo"
    },
    "anthropic": {
      "status": "degraded",
      "responseTime": 500,
      "lastCheck": "2024-01-01T00:00:00.000Z",
      "model": "claude-3-sonnet-20240229"
    }
  },
  "circuitBreakers": {
    "gemini": "closed",
    "openai": "closed",
    "anthropic": "half-open"
  }
}
```

---

### 8. Error Metrics

#### GET /api/metrics/errors

Get error analytics and metrics.

**Response**:

```json
{
  "totalErrors": 25,
  "errorRate": 0.05,
  "last24Hours": {
    "total": 25,
    "byType": {
      "timeout": 5,
      "syntax": 8,
      "runtime": 7,
      "system": 5
    }
  },
  "trends": {
    "daily": [
      { "date": "2024-01-01", "count": 25 },
      { "date": "2024-01-02", "count": 18 }
    ]
  },
  "topErrors": [
    {
      "message": "SyntaxError: invalid syntax",
      "count": 8,
      "language": "python"
    }
  ]
}
```

---

## Supported Languages

The backend supports the following programming languages:

| Language   | Identifier   | Version    | Docker Image                              |
| ---------- | ------------ | ---------- | ----------------------------------------- |
| Python     | `python`     | 3.11       | `python:3.11-alpine`                      |
| JavaScript | `javascript` | Node.js 20 | `node:20-alpine`                          |
| Java       | `java`       | 17         | `openjdk:17-alpine`                       |
| C++        | `cpp`        | GCC 11     | `gcc:11-alpine`                           |
| C          | `c`          | GCC 11     | `gcc:11-alpine`                           |
| Go         | `go`         | 1.21       | `golang:1.21-alpine`                      |
| Rust       | `rust`       | 1.73       | `rust:1.73-alpine`                        |
| Ruby       | `ruby`       | 3.2        | `ruby:3.2-alpine`                         |
| PHP        | `php`        | 8.2        | `php:8.2-alpine`                          |
| C#         | `csharp`     | 7.0        | `mcr.microsoft.com/dotnet/sdk:7.0-alpine` |
| Bash       | `bash`       | 5.1        | `bash:5.1-alpine`                         |

---

## Rate Limiting

The backend implements rate limiting to prevent abuse:

- **Window**: 15 minutes
- **Max Requests**: 100 per IP (configurable)
- **Headers**: Rate limit info is included in response headers

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

When rate limited:

```json
{
  "error": "Too many requests from this IP, please try again later."
}
```

---

## Error Handling

### Error Response Format

All errors follow this consistent format:

```json
{
  "error": "Error type",
  "message": "Human-readable error message",
  "code": "ERROR_CODE",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "requestId": "req-123456"
}
```

### Common Error Codes

| Code                  | Description                      | HTTP Status |
| --------------------- | -------------------------------- | ----------- |
| `INVALID_LANGUAGE`    | Unsupported programming language | 400         |
| `CODE_TOO_LARGE`      | Code exceeds size limit          | 400         |
| `SYNTAX_ERROR`        | Code has syntax errors           | 400         |
| `TIMEOUT`             | Execution timed out              | 408         |
| `RATE_LIMITED`        | Too many requests                | 429         |
| `INTERNAL_ERROR`      | Server error                     | 500         |
| `SERVICE_UNAVAILABLE` | Service temporarily unavailable  | 503         |

---

## WebSocket Support

### Terminal Sessions

The backend supports real-time terminal sessions via WebSocket:

**Connection**: `ws://localhost:3001/socket.io/`

**Events**:

- `terminal:create` - Create new terminal session
- `terminal:data` - Send/receive terminal data
- `terminal:resize` - Resize terminal
- `terminal:close` - Close terminal session

**Example**:

```javascript
const socket = io("http://localhost:3001");

// Create terminal session
socket.emit("terminal:create", {
  language: "python",
  cols: 80,
  rows: 24,
});

// Send input
socket.emit("terminal:data", {
  sessionId: "session-123",
  data: 'print("Hello")\n',
});

// Receive output
socket.on("terminal:data", (data) => {
  console.log("Output:", data.chunk);
});
```

---

## AI Integration

The backend includes AI resilience features with multiple providers:

### AI Providers

1. **Google Gemini** (Primary)

   - Model: `gemini-1.5-flash`
   - Cost-effective and reliable

2. **OpenAI GPT** (Secondary)

   - Model: `gpt-3.5-turbo`
   - High-quality responses

3. **Anthropic Claude** (Tertiary)
   - Model: `claude-3-sonnet-20240229`
   - Premium quality

### AI Endpoints

#### POST /api/ai/chat

Send chat messages to AI service.

**Request Body**:

```json
{
  "message": "Explain this code",
  "context": {
    "code": "print('Hello')",
    "language": "python"
  },
  "provider": "gemini"
}
```

**Response**:

```json
{
  "id": "chat-123",
  "message": "This code prints 'Hello' to the console...",
  "provider": "gemini",
  "model": "gemini-1.5-flash",
  "tokens": {
    "input": 10,
    "output": 25,
    "total": 35
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## Environment Configuration

### Required Environment Variables

```env
NODE_ENV=production
PORT=3001
API_KEY=your_secure_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Optional Environment Variables

```env
# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Container Limits
CONTAINER_TIMEOUT_MS=30000
CONTAINER_MEMORY_LIMIT=128m
CONTAINER_CPU_LIMIT=0.5
MAX_EXECUTION_TIME_MS=10000

# AI Configuration
GEMINI_API_KEY=your_gemini_key
GEMINI_MODEL=gemini-1.5-flash
OPENAI_API_KEY=your_openai_key
OPENAI_MODEL=gpt-3.5-turbo
ANTHROPIC_API_KEY=your_anthropic_key
ANTHROPIC_MODEL=claude-3-sonnet-20240229

# Logging
LOG_LEVEL=info
```

---

## Deployment Information

### Production Deployment

The backend is deployed on Railway/Render with the following configuration:

- **Node.js Version**: 18+
- **Platform**: Docker containers
- **Health Checks**: Enabled
- **Auto-scaling**: Configured
- **Monitoring**: Comprehensive logging

### Docker Configuration

```dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY src/ ./src/
EXPOSE 3001
CMD ["npm", "start"]
```

---

## Security Features

### Input Validation

- Code size limits (1MB max)
- Syntax validation
- Security pattern detection
- Binary data preservation

### Isolation

- Docker container isolation
- Resource limits (CPU, memory)
- Network restrictions
- File system isolation

### Rate Limiting

- IP-based rate limiting
- Request throttling
- Abuse detection

---

## Testing

### Local Development

1. Install dependencies:

   ```bash
   npm install
   ```

2. Start development server:

   ```bash
   npm run dev
   ```

3. Run tests:
   ```bash
   npm test
   ```

### API Testing

Use the following curl commands to test endpoints:

```bash
# Health check
curl http://localhost:3001/health

# Execute Python code
curl -X POST http://localhost:3001/api/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "language": "python",
    "code": "print(\"Hello, World!\")"
  }'

# Check execution status
curl http://localhost:3001/api/status/execution-id-123
```

---

## Recent Changes

### AI Resilience Implementation

1. **Multi-provider support** with automatic failover
2. **Circuit breaker pattern** for service reliability
3. **Intelligent retry logic** with backoff strategies
4. **Response caching** for performance optimization
5. **Health monitoring** with real-time alerts

### Enhanced Input Handling

1. **Binary data preservation** through input pipeline
2. **UTF-8 encoding support** for international characters
3. **Control character handling** for terminal operations
4. **Language-specific processing** for different REPL environments
5. **Security validation** to prevent malicious input

### Backend Fixes

1. **Docker connectivity improvements** with better retry logic
2. **Gemini API configuration** updated to use `gemini-1.5-flash`
3. **Circuit breaker optimization** with less aggressive thresholds
4. **Enhanced monitoring** with detailed health endpoints

---

## Troubleshooting

### Common Issues

1. **Docker Connection Failed**

   - Check Docker daemon status
   - Verify socket permissions
   - Monitor `/api/health/docker`

2. **AI Service Unavailable**

   - Check API key configuration
   - Verify model availability
   - Monitor `/api/health/ai`

3. **Execution Timeouts**
   - Increase timeout value
   - Check code complexity
   - Monitor resource usage

### Debug Information

Enable debug logging by setting `LOG_LEVEL=debug` in environment variables.

---

## Support

For issues or questions:

1. Check the health endpoints first
2. Review error logs and metrics
3. Verify environment configuration
4. Contact the backend team with request IDs

---

## Changelog

### v1.0.0 (Current)

- Initial API implementation
- Code execution with Docker isolation
- AI resilience features
- Enhanced input handling
- Comprehensive monitoring

---

_Last updated: January 2024_
