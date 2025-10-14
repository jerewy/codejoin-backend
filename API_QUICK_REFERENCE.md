# API Quick Reference Guide

## Base Configuration

```javascript
const API_CONFIG = {
  BASE_URL:
    process.env.NODE_ENV === "production"
      ? "https://your-backend-url.com"
      : "http://localhost:3001",
  API_KEY: process.env.REACT_APP_API_KEY,
  HEADERS: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${process.env.REACT_APP_API_KEY}`,
  },
};
```

## Core Endpoints

### Health & Status

| Method | Endpoint               | Purpose                     |
| ------ | ---------------------- | --------------------------- |
| GET    | `/health`              | Basic health check          |
| GET    | `/api/health/detailed` | Comprehensive system status |
| GET    | `/api/health/docker`   | Docker service status       |
| GET    | `/api/health/ai`       | AI service provider status  |

### Code Execution

| Method | Endpoint          | Purpose                   |
| ------ | ----------------- | ------------------------- |
| POST   | `/api/execute`    | Execute code in container |
| GET    | `/api/status/:id` | Get execution status      |

### AI Services

| Method | Endpoint       | Purpose                |
| ------ | -------------- | ---------------------- |
| POST   | `/api/ai/chat` | Chat with AI assistant |

### Monitoring

| Method | Endpoint              | Purpose         |
| ------ | --------------------- | --------------- |
| GET    | `/api/metrics/errors` | Error analytics |

## Request Examples

### Health Check

```javascript
const response = await fetch(`${API_CONFIG.BASE_URL}/health`, {
  headers: API_CONFIG.HEADERS,
});
const health = await response.json();
```

### Execute Code

```javascript
const executeCode = async (language, code, options = {}) => {
  const response = await fetch(`${API_CONFIG.BASE_URL}/api/execute`, {
    method: "POST",
    headers: API_CONFIG.HEADERS,
    body: JSON.stringify({
      language,
      code,
      timeout: options.timeout || 10000,
      input: options.input || "",
    }),
  });

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${await response.text()}`);
  }

  return response.json();
};

// Usage
const result = await executeCode("python", 'print("Hello, World!")');
```

### Get Execution Status

```javascript
const getStatus = async (executionId) => {
  const response = await fetch(
    `${API_CONFIG.BASE_URL}/api/status/${executionId}`,
    {
      headers: API_CONFIG.HEADERS,
    }
  );
  return response.json();
};
```

### AI Chat

```javascript
const chatWithAI = async (message, context = {}) => {
  const response = await fetch(`${API_CONFIG.BASE_URL}/api/ai/chat`, {
    method: "POST",
    headers: API_CONFIG.HEADERS,
    body: JSON.stringify({
      message,
      context,
      provider: "gemini", // optional
    }),
  });

  return response.json();
};
```

## Response Formats

### Success Response

```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "data": { ... }
}
```

### Error Response

```json
{
  "error": "Error type",
  "message": "Human-readable error message",
  "code": "ERROR_CODE",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "requestId": "req-123456"
}
```

### Code Execution Response

```json
{
  "id": "execution-id-123",
  "status": "completed", // pending, running, completed, failed, timeout
  "output": "Hello, World!\n",
  "error": null,
  "executionTime": 1500,
  "memoryUsage": 1048576,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Supported Languages

| Language   | Code         | Notes      |
| ---------- | ------------ | ---------- |
| Python     | `python`     | 3.11       |
| JavaScript | `javascript` | Node.js 20 |
| Java       | `java`       | 17         |
| C++        | `cpp`        | GCC 11     |
| C          | `c`          | GCC 11     |
| Go         | `go`         | 1.21       |
| Rust       | `rust`       | 1.73       |
| Ruby       | `ruby`       | 3.2        |
| PHP        | `php`        | 8.2        |
| C#         | `csharp`     | 7.0        |
| Bash       | `bash`       | 5.1        |

## Common Error Codes

| Code                  | Description          | Action                            |
| --------------------- | -------------------- | --------------------------------- |
| `INVALID_LANGUAGE`    | Unsupported language | Use supported language            |
| `CODE_TOO_LARGE`      | Code exceeds limit   | Reduce code size                  |
| `SYNTAX_ERROR`        | Invalid syntax       | Fix code syntax                   |
| `TIMEOUT`             | Execution too long   | Optimize code or increase timeout |
| `RATE_LIMITED`        | Too many requests    | Wait and retry                    |
| `SERVICE_UNAVAILABLE` | Backend down         | Check status page                 |

## WebSocket Events

### Connection

```javascript
import { io } from "socket.io-client";

const socket = io(API_CONFIG.BASE_URL);
```

### Events

| Event             | Direction       | Description                |
| ----------------- | --------------- | -------------------------- |
| `terminal:create` | Client → Server | Create terminal session    |
| `terminal:data`   | Both            | Send/receive terminal data |
| `terminal:resize` | Client → Server | Resize terminal            |
| `terminal:close`  | Client → Server | Close session              |

### Example

```javascript
// Create terminal
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

## Rate Limiting

- **Window**: 15 minutes
- **Max Requests**: 100 per IP
- **Headers**: Check response headers for limits

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Environment Variables

### Required

```env
REACT_APP_API_KEY=your_api_key
REACT_APP_BACKEND_URL=http://localhost:3001
```

### Optional

```env
REACT_APP_DEFAULT_LANGUAGE=python
REACT_APP_DEFAULT_TIMEOUT=10000
REACT_APP_ENABLE_DEBUG=false
```

## Common Patterns

### 1. Error Handling

```javascript
const handleApiCall = async () => {
  try {
    const result = await apiCall();
    return result;
  } catch (error) {
    if (error.code === "RATE_LIMITED") {
      showWarning("Please wait before making another request");
    } else if (error.code === "TIMEOUT") {
      showError("Execution timed out. Try optimizing your code.");
    } else {
      showError("An error occurred. Please try again.");
    }
  }
};
```

### 2. Polling Execution Status

```javascript
const pollExecutionStatus = async (executionId, maxAttempts = 30) => {
  for (let i = 0; i < maxAttempts; i++) {
    const status = await getStatus(executionId);

    if (status.status === "completed") {
      return status;
    } else if (status.status === "failed" || status.status === "timeout") {
      throw new Error(status.error || "Execution failed");
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  throw new Error("Execution timed out");
};
```

### 3. Debounced Code Execution

```javascript
const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

const debouncedExecute = debounce(async (language, code) => {
  try {
    const result = await executeCode(language, code);
    setOutput(result.output);
  } catch (error) {
    setError(error.message);
  }
}, 500);
```

### 4. Health Check with Retry

```javascript
const checkHealthWithRetry = async (maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const health = await fetch(`${API_CONFIG.BASE_URL}/health`, {
        headers: API_CONFIG.HEADERS,
      });

      if (health.ok) {
        return await health.json();
      }
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise((resolve) => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
};
```

## Debugging Tips

### 1. Check Network Tab

- Look at request/response in browser dev tools
- Verify headers and payload
- Check status codes and error messages

### 2. Enable Debug Logging

```javascript
const DEBUG = process.env.NODE_ENV === "development";

const debugLog = (message, data) => {
  if (DEBUG) {
    console.log(`[API Debug] ${message}`, data);
  }
};
```

### 3. Monitor Health Endpoints

```javascript
// Check system health before operations
const preFlightCheck = async () => {
  try {
    const health = await checkHealthWithRetry();
    if (health.status !== "OK") {
      throw new Error("System is not healthy");
    }
    return true;
  } catch (error) {
    console.error("Pre-flight check failed:", error);
    return false;
  }
};
```

## Best Practices

1. **Always handle errors** - Check response status and handle different error types
2. **Use timeouts** - Set reasonable timeouts for all requests
3. **Implement retry logic** - Retry failed requests with exponential backoff
4. **Cache responses** - Cache health checks and other non-changing data
5. **Validate inputs** - Validate code and parameters before sending
6. **Monitor rate limits** - Check headers and respect limits
7. **Use WebSocket for real-time** - Use WebSocket for terminal sessions
8. **Implement graceful degradation** - Handle service failures gracefully

## Troubleshooting

### Connection Issues

- Check if backend is running: `curl http://localhost:3001/health`
- Verify API key is correct
- Check CORS settings
- Ensure firewall allows connection

### Execution Issues

- Verify language is supported
- Check code syntax
- Increase timeout if needed
- Check resource limits

### Rate Limiting

- Check remaining requests in headers
- Implement request queuing
- Use caching to reduce requests
- Consider increasing limits if needed

---

_For detailed documentation, see [FRONTEND_API_DOCUMENTATION.md](./FRONTEND_API_DOCUMENTATION.md)_
_For implementation examples, see [FRONTEND_INTEGRATION_GUIDE.md](./FRONTEND_INTEGRATION_GUIDE.md)_
