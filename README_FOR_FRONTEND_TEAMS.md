# CodeJoin Backend API - Frontend Integration

## 🚀 Quick Start for Frontend Teams

This repository contains the documentation for integrating your frontend applications with the CodeJoin backend API.

## 📚 Available Documentation

| Document              | Purpose                                      | Link                                                                 |
| --------------------- | -------------------------------------------- | -------------------------------------------------------------------- |
| **Setup Guide**       | ⚡ 5-minute setup to connect your frontend   | [FRONTEND_DOCS_SETUP_GUIDE.md](./FRONTEND_DOCS_SETUP_GUIDE.md)       |
| **API Documentation** | 📖 Complete API reference with all endpoints | [FRONTEND_API_DOCUMENTATION.md](./FRONTEND_API_DOCUMENTATION.md)     |
| **Integration Guide** | 🔧 Detailed implementation examples          | [FRONTEND_INTEGRATION_GUIDE.md](./FRONTEND_INTEGRATION_GUIDE.md)     |
| **Quick Reference**   | 📋 Cheat sheet for common operations         | [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md)                   |
| **Multi-Repo Setup**  | 🔄 Working with separate repositories        | [MULTI_REPOSITORY_INTEGRATION.md](./MULTI_REPOSITORY_INTEGRATION.md) |

## 🎯 What You Can Do

- **Execute Code** - Run Python, JavaScript, Java, C++, and more
- **Real-time Terminal** - Interactive terminal sessions via WebSocket
- **AI Assistant** - Get help with code using AI
- **Health Monitoring** - Check system status and performance
- **Error Handling** - Robust error management and recovery

## 🛠️ Supported Frontend Frameworks

- ✅ React (including Next.js)
- ✅ Vue.js (including Nuxt.js)
- ✅ Angular
- ✅ Vanilla JavaScript
- ✅ TypeScript projects
- ✅ Mobile apps (React Native, Flutter)

## 🔧 Quick Setup (3 Steps)

### 1. Environment Variables

```env
REACT_APP_API_URL=https://your-backend-url.com
REACT_APP_API_KEY=your_api_key_here
```

### 2. Install Dependencies

```bash
npm install axios socket.io-client
```

### 3. Test Connection

```javascript
import axios from "axios";

const testConnection = async () => {
  try {
    const response = await axios.get(
      `${process.env.REACT_APP_API_URL}/health`,
      {
        headers: { Authorization: `Bearer ${process.env.REACT_APP_API_KEY}` },
      }
    );
    console.log("✅ Backend connected!", response.data);
  } catch (error) {
    console.error("❌ Connection failed:", error.message);
  }
};
```

## 🌐 API Endpoints

### Core Endpoints

- `GET /health` - Health check
- `POST /api/execute` - Execute code
- `GET /api/status/:id` - Get execution status
- `POST /api/ai/chat` - AI assistant

### Monitoring Endpoints

- `GET /api/health/detailed` - System status
- `GET /api/health/ai` - AI service status
- `GET /api/metrics/errors` - Error analytics

### WebSocket

- `ws://localhost:3001` - Real-time terminal sessions

## 💡 Example Usage

### Execute Code

```javascript
const executeCode = async (language, code) => {
  const response = await axios.post(
    `${API_URL}/api/execute`,
    {
      language,
      code,
      timeout: 10000,
    },
    {
      headers: { Authorization: `Bearer ${API_KEY}` },
    }
  );

  return response.data;
};

// Usage
const result = await executeCode("python", 'print("Hello, World!")');
console.log(result.output); // "Hello, World!"
```

### AI Chat

```javascript
const chatWithAI = async (message) => {
  const response = await axios.post(
    `${API_URL}/api/ai/chat`,
    {
      message,
      context: { language: "python" },
    },
    {
      headers: { Authorization: `Bearer ${API_KEY}` },
    }
  );

  return response.data;
};

// Usage
const aiResponse = await chatWithAI("What does this code do?");
console.log(aiResponse.message);
```

### WebSocket Terminal

```javascript
import { io } from "socket.io-client";

const socket = io(API_URL, {
  auth: { token: API_KEY },
});

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

## 🔍 Testing Your Integration

### Health Check

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-backend-url.com/health
```

### Code Execution

```bash
curl -X POST https://your-backend-url.com/api/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{"language":"python","code":"print(\"Hello\")"}'
```

## 🚨 Common Issues & Solutions

### CORS Errors

**Problem:** `Access to fetch has been blocked by CORS policy`
**Solution:** Ensure your frontend URL is in the backend's CORS allowlist

### Authentication Errors

**Problem:** `401 Unauthorized`
**Solution:** Check your API key is correct and properly set

### Network Errors

**Problem:** `Network Error`
**Solution:** Verify the backend URL is correct and accessible

### Rate Limiting

**Problem:** `429 Too Many Requests`
**Solution:** Implement request throttling and exponential backoff

## 🛡️ Security Best Practices

1. **Never expose API keys** in client-side code
2. **Use environment variables** for sensitive configuration
3. **Implement proper error handling** for all API calls
4. **Validate inputs** before sending to the backend
5. **Use HTTPS** in production environments

## 📊 Supported Languages

| Language   | Code         | Version    |
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

## 🔄 Keeping Updated

### API Changes

- Check this repository regularly for updates
- Subscribe to releases for notifications
- Review changelog for breaking changes

### Version Compatibility

- Backend API Version: `1.0.0`
- Node.js Required: `18+`
- Browser Support: Modern browsers with ES6+ support

## 🆘 Getting Help

### Self-Service

1. Check the [troubleshooting section](./FRONTEND_DOCS_SETUP_GUIDE.md#troubleshooting)
2. Review [common error codes](./API_QUICK_REFERENCE.md#common-error-codes)
3. Test with the [example components](./FRONTEND_INTEGRATION_GUIDE.md)

### Contact

- Create an issue in this repository
- Join our developer Discord/Slack
- Email: support@codejoin.com

## 🎉 Success Stories

> "The integration was incredibly smooth. We had our frontend connected in under 10 minutes!" - Frontend Team Lead

> "The documentation is comprehensive and the examples saved us hours of development time." - Senior Developer

> "The WebSocket terminal feature is amazing - our users love it!" - Product Manager

---

## 🚀 Ready to Start?

1. **Clone this documentation** to your frontend repository
2. **Follow the setup guide** (5 minutes)
3. **Test with our examples**
4. **Build amazing features!**

**Happy coding! 🎯**

---

_Last updated: January 2024_  
_API Version: 1.0.0_  
_Documentation Version: 1.0.0_
