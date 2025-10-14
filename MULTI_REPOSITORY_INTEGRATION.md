# Multi-Repository Integration Guide

## Overview

This guide explains how to integrate the CodeJoin backend with frontend applications that are in separate repositories. It covers deployment scenarios, CORS configuration, environment management, and best practices for distributed development.

## Repository Structure

### Typical Setup

```
organization/
├── codejoin-backend/          # Backend repository (this repo)
│   ├── src/
│   ├── docs/
│   └── Dockerfile
├── codejoin-frontend/         # Frontend repository
│   ├── src/
│   ├── public/
│   └── package.json
├── codejoin-mobile/          # Mobile app repository
│   ├── src/
│   └── package.json
└── codejoin-docs/            # Documentation repository
    └── README.md
```

### Shared Configuration

Create a shared configuration repository or use environment-specific configs:

```
codejoin-config/
├── environments/
│   ├── development.json
│   ├── staging.json
│   └── production.json
└── README.md
```

## Deployment Scenarios

### 1. Backend on Railway/Render, Frontend on Vercel/Netlify

#### Backend Configuration

Update your backend CORS settings to allow multiple frontend domains:

```javascript
// src/index.js - Enhanced CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      "http://localhost:3000", // Local development
      "http://localhost:3001", // Alternative local port
      "https://your-frontend.vercel.app", // Production frontend
      "https://staging.your-frontend.vercel.app", // Staging frontend
      "https://your-mobile-app.com", // Mobile app domain
    ];

    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));
```

#### Frontend Configuration

```javascript
// config/environments.js
const environments = {
  development: {
    API_URL: "http://localhost:3001",
    WS_URL: "ws://localhost:3001",
    ENVIRONMENT: "development",
  },
  staging: {
    API_URL: "https://codejoin-backend-staging.onrender.com",
    WS_URL: "wss://codejoin-backend-staging.onrender.com",
    ENVIRONMENT: "staging",
  },
  production: {
    API_URL: "https://codejoin-backend-production.onrender.com",
    WS_URL: "wss://codejoin-backend-production.onrender.com",
    ENVIRONMENT: "production",
  },
};

const getEnvironment = () => {
  const hostname = window.location.hostname;

  if (hostname === "localhost" || hostname === "127.0.0.1") {
    return environments.development;
  } else if (hostname.includes("staging") || hostname.includes("preview")) {
    return environments.staging;
  } else {
    return environments.production;
  }
};

export default getEnvironment();
```

### 2. Backend on Custom Domain, Frontend on Subdomains

#### Domain Structure

```
api.codejoin.com          # Backend API
app.codejoin.com          # Frontend application
docs.codejoin.com         # Documentation
staging.codejoin.com      # Staging environment
```

#### Backend CORS for Subdomains

```javascript
// src/index.js - Subdomain CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow all subdomains of codejoin.com
    const allowedPattern = /^https?:\/\/([a-zA-Z0-9-]+\.)*codejoin\.com$/;

    if (!origin || allowedPattern.test(origin)) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));
```

### 3. Backend and Frontend on Same Domain (API Proxy)

#### Frontend Build Configuration

For Next.js:

```javascript
// next.config.js
module.exports = {
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "https://your-backend-url.com/api/:path*",
      },
      {
        source: "/socket.io/:path*",
        destination: "https://your-backend-url.com/socket.io/:path*",
      },
    ];
  },
};
```

For Create React App:

```javascript
// src/setupProxy.js
const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function (app) {
  app.use(
    "/api",
    createProxyMiddleware({
      target: "https://your-backend-url.com",
      changeOrigin: true,
      secure: true,
      headers: {
        Authorization: `Bearer ${process.env.REACT_APP_API_KEY}`,
      },
    })
  );

  app.use(
    "/socket.io",
    createProxyMiddleware({
      target: "https://your-backend-url.com",
      changeOrigin: true,
      ws: true,
      secure: true,
    })
  );
};
```

## Environment Management

### 1. Environment Variables

#### Backend (.env)

```env
# Common settings
NODE_ENV=production
PORT=3001
API_KEY=your_secure_api_key

# CORS settings
CORS_ORIGINS=http://localhost:3000,https://your-frontend.vercel.app,https://app.codejoin.com

# Database
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# AI Services
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

#### Frontend (.env.example)

```env
# API Configuration
REACT_APP_API_URL=https://your-backend-url.com
REACT_APP_WS_URL=wss://your-backend-url.com
REACT_APP_API_KEY=your_frontend_api_key

# Environment
REACT_APP_ENVIRONMENT=production
REACT_APP_VERSION=1.0.0

# Feature Flags
REACT_APP_ENABLE_AI_FEATURES=true
REACT_APP_ENABLE_TERMINAL=true
REACT_APP_ENABLE_DEBUG=false
```

### 2. Shared Configuration Package

Create a shared npm package for configuration:

```javascript
// packages/config/src/index.js
const config = {
  development: {
    api: {
      baseUrl: "http://localhost:3001",
      wsUrl: "ws://localhost:3001",
      timeout: 30000,
    },
    features: {
      ai: true,
      terminal: true,
      debug: true,
    },
  },
  staging: {
    api: {
      baseUrl: "https://codejoin-backend-staging.onrender.com",
      wsUrl: "wss://codejoin-backend-staging.onrender.com",
      timeout: 30000,
    },
    features: {
      ai: true,
      terminal: true,
      debug: true,
    },
  },
  production: {
    api: {
      baseUrl: "https://api.codejoin.com",
      wsUrl: "wss://api.codejoin.com",
      timeout: 30000,
    },
    features: {
      ai: true,
      terminal: true,
      debug: false,
    },
  },
};

const getConfig = () => {
  const env = process.env.NODE_ENV || "development";
  return config[env];
};

export default getConfig();
```

## API Client Setup for Multi-Repo

### 1. Base API Client

```javascript
// packages/api-client/src/index.js
class ApiClient {
  constructor(config = {}) {
    this.config = {
      baseUrl: config.baseUrl || process.env.REACT_APP_API_URL,
      wsUrl: config.wsUrl || process.env.REACT_APP_WS_URL,
      apiKey: config.apiKey || process.env.REACT_APP_API_KEY,
      timeout: config.timeout || 30000,
      ...config,
    };

    this.setupInterceptors();
  }

  setupInterceptors() {
    // Request interceptor
    this.requestInterceptor = (config) => {
      config.headers = {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.config.apiKey}`,
        ...config.headers,
      };
      return config;
    };

    // Response interceptor
    this.responseInterceptor = (response) => {
      return response;
    };

    this.errorInterceptor = (error) => {
      if (error.response?.status === 401) {
        // Handle unauthorized
        this.handleUnauthorized();
      }
      return Promise.reject(error);
    };
  }

  async request(endpoint, options = {}) {
    const url = `${this.config.baseUrl}${endpoint}`;
    const config = {
      timeout: this.config.timeout,
      ...options,
    };

    // Apply request interceptor
    config = this.requestInterceptor(config);

    try {
      const response = await fetch(url, config);

      // Apply response interceptor
      const processedResponse = this.responseInterceptor(response);

      if (!processedResponse.ok) {
        throw new ApiError(
          processedResponse.status,
          await processedResponse.json()
        );
      }

      return await processedResponse.json();
    } catch (error) {
      // Apply error interceptor
      this.errorInterceptor(error);
      throw error;
    }
  }

  // WebSocket connection
  createWebSocket() {
    return new WebSocket(this.config.wsUrl);
  }

  // Socket.io connection
  createSocket() {
    return io(this.config.wsUrl, {
      transports: ["websocket"],
      auth: {
        token: this.config.apiKey,
      },
    });
  }

  handleUnauthorized() {
    // Redirect to login or refresh token
    window.location.href = "/login";
  }
}

class ApiError extends Error {
  constructor(status, response) {
    super(response.message || "API Error");
    this.status = status;
    this.code = response.code;
    this.timestamp = response.timestamp;
    this.requestId = response.requestId;
  }
}

export default ApiClient;
```

### 2. Package.json Setup

```json
{
  "name": "@codejoin/api-client",
  "version": "1.0.0",
  "description": "Shared API client for CodeJoin applications",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "publish": "npm publish"
  },
  "dependencies": {
    "socket.io-client": "^4.7.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
```

## Deployment Strategies

### 1. Independent Deployment

#### Backend Deployment (Railway/Render)

```yaml
# render.yaml
services:
  - type: web
    name: codejoin-backend
    env: node
    buildCommand: "npm install"
    startCommand: "npm start"
    envVars:
      - key: NODE_ENV
        value: production
      - key: CORS_ORIGINS
        value: https://your-frontend.vercel.app,https://staging.your-frontend.vercel.app
    healthCheck:
      path: /health
```

#### Frontend Deployment (Vercel)

```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build"
      }
    }
  ],
  "env": {
    "REACT_APP_API_URL": "@api-url",
    "REACT_APP_API_KEY": "@api-key"
  },
  "functions": {
    "api/**/*.js": {
      "maxDuration": 10
    }
  }
}
```

### 2. Monorepo with Independent Deployments

#### Workspace Configuration

```json
// package.json (root)
{
  "name": "codejoin-monorepo",
  "private": true,
  "workspaces": ["packages/*", "apps/backend", "apps/frontend", "apps/mobile"],
  "scripts": {
    "dev:backend": "npm run dev --workspace=apps/backend",
    "dev:frontend": "npm run dev --workspace=apps/frontend",
    "build:all": "npm run build --workspaces",
    "deploy:backend": "npm run deploy --workspace=apps/backend",
    "deploy:frontend": "npm run deploy --workspace=apps/frontend"
  }
}
```

#### Shared Dependencies

```json
// packages/shared/package.json
{
  "name": "@codejoin/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "dependencies": {
    "typescript": "^5.0.0",
    "zod": "^3.22.0"
  }
}
```

## CI/CD Pipeline

### 1. GitHub Actions for Multi-Repo

#### Backend CI/CD

```yaml
# .github/workflows/backend.yml
name: Backend CI/CD

on:
  push:
    branches: [main, develop]
    paths: ["backend/**"]
  pull_request:
    branches: [main]
    paths: ["backend/**"]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"
      - run: npm ci --prefix backend
      - run: npm test --prefix backend

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Railway
        uses: railway-app/railway-action@v1
        with:
          api-token: ${{ secrets.RAILWAY_TOKEN }}
          service: codejoin-backend
```

#### Frontend CI/CD

```yaml
# .github/workflows/frontend.yml
name: Frontend CI/CD

on:
  push:
    branches: [main, develop]
    paths: ["frontend/**"]
  pull_request:
    branches: [main]
    paths: ["frontend/**"]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"
      - run: npm ci --prefix frontend
      - run: npm test --prefix frontend

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          working-directory: ./frontend
```

### 2. Shared Pipeline Configuration

```yaml
# .github/workflows/shared.yml
name: Shared Pipeline

on:
  workflow_call:
    inputs:
      app:
        required: true
        type: string
      environment:
        required: true
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: "18"
      - run: npm ci --prefix ${{ inputs.app }}
      - run: npm test --prefix ${{ inputs.app }}

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy ${{ inputs.app }}
        run: |
          echo "Deploying ${{ inputs.app }} to ${{ inputs.environment }}"
          # Deployment logic here
```

## Security Considerations

### 1. API Key Management

#### Environment-Specific Keys

```javascript
// config/api-keys.js
const apiKeys = {
  development: {
    backend: "dev-api-key-123",
    frontend: "dev-frontend-key-456",
  },
  staging: {
    backend: "staging-api-key-789",
    frontend: "staging-frontend-key-012",
  },
  production: {
    backend: process.env.PRODUCTION_API_KEY,
    frontend: process.env.PRODUCTION_FRONTEND_KEY,
  },
};

const getApiKey = (service, environment = process.env.NODE_ENV) => {
  return apiKeys[environment]?.[service];
};

export default getApiKey;
```

#### Key Rotation Strategy

```javascript
// utils/key-rotation.js
class KeyRotation {
  constructor() {
    this.currentKey = process.env.API_KEY;
    this.backupKey = process.env.BACKUP_API_KEY;
    this.rotationInterval = 24 * 60 * 60 * 1000; // 24 hours
  }

  async rotateKey() {
    try {
      // Test backup key
      await this.testKey(this.backupKey);

      // Switch to backup key
      this.currentKey = this.backupKey;

      // Generate new backup key
      this.backupKey = await this.generateNewKey();

      console.log("API key rotated successfully");
    } catch (error) {
      console.error("Key rotation failed:", error);
    }
  }

  async testKey(key) {
    const response = await fetch(`${this.config.baseUrl}/health`, {
      headers: {
        Authorization: `Bearer ${key}`,
      },
    });

    if (!response.ok) {
      throw new Error("Key validation failed");
    }
  }

  async generateNewKey() {
    // Generate new key from your key management service
    return "new-generated-key";
  }
}
```

### 2. CORS Security

#### Dynamic CORS Configuration

```javascript
// src/middleware/dynamic-cors.js
const allowedOrigins = new Set([
  "https://app.codejoin.com",
  "https://staging.codejoin.com",
  "http://localhost:3000",
]);

const dynamicCors = (req, res, next) => {
  const origin = req.headers.origin;

  if (allowedOrigins.has(origin)) {
    res.header("Access-Control-Allow-Origin", origin);
  }

  res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  );
  res.header("Access-Control-Allow-Credentials", "true");

  if (req.method === "OPTIONS") {
    res.sendStatus(200);
  } else {
    next();
  }
};

module.exports = dynamicCors;
```

## Testing Across Repositories

### 1. Contract Testing

#### API Contract Definition

```javascript
// contracts/api-contract.js
const ApiContract = {
  health: {
    method: "GET",
    path: "/health",
    response: {
      status: "OK",
      timestamp: "string",
      uptime: "number",
    },
  },
  execute: {
    method: "POST",
    path: "/api/execute",
    body: {
      language: "string",
      code: "string",
      timeout: "number?",
    },
    response: {
      id: "string",
      status: "string",
      output: "string?",
      error: "string?",
    },
  },
};

export default ApiContract;
```

#### Frontend Contract Tests

```javascript
// __tests__/contract.test.js
import ApiContract from "../contracts/api-contract";
import ApiClient from "../services/api-client";

describe("API Contract Tests", () => {
  let apiClient;

  beforeAll(() => {
    apiClient = new ApiClient({
      baseUrl: process.env.TEST_API_URL,
    });
  });

  test("health endpoint matches contract", async () => {
    const response = await apiClient.healthCheck();
    const contract = ApiContract.health.response;

    expect(response).toHaveProperty("status");
    expect(response).toHaveProperty("timestamp");
    expect(response).toHaveProperty("uptime");

    expect(typeof response.status).toBe("string");
    expect(typeof response.timestamp).toBe("string");
    expect(typeof response.uptime).toBe("number");
  });

  test("execute endpoint matches contract", async () => {
    const response = await apiClient.executeCode("python", 'print("test")');
    const contract = ApiContract.execute.response;

    expect(response).toHaveProperty("id");
    expect(response).toHaveProperty("status");

    expect(typeof response.id).toBe("string");
    expect(typeof response.status).toBe("string");
  });
});
```

### 2. Integration Testing

#### Docker Compose for Local Testing

```yaml
# docker-compose.test.yml
version: "3.8"
services:
  backend:
    build: ./backend
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=test
      - CORS_ORIGINS=http://localhost:3000
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:3001
    depends_on:
      backend:
        condition: service_healthy
```

## Monitoring and Debugging

### 1. Cross-Repository Logging

#### Correlation IDs

```javascript
// utils/correlation.js
class CorrelationManager {
  static generateId() {
    return `corr_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  static middleware() {
    return (req, res, next) => {
      const correlationId =
        req.headers["x-correlation-id"] || this.generateId();
      req.correlationId = correlationId;
      res.setHeader("X-Correlation-ID", correlationId);
      next();
    };
  }
}

module.exports = CorrelationManager;
```

#### Frontend Logger

```javascript
// utils/logger.js
class Logger {
  constructor() {
    this.logs = [];
    this.maxLogs = 1000;
  }

  log(level, message, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      data,
      correlationId: data.correlationId || this.generateCorrelationId(),
    };

    this.logs.push(logEntry);

    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // Send to backend for centralized logging
    this.sendToBackend(logEntry);
  }

  async sendToBackend(logEntry) {
    try {
      await fetch(`${process.env.REACT_APP_API_URL}/api/logs`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.REACT_APP_API_KEY}`,
        },
        body: JSON.stringify(logEntry),
      });
    } catch (error) {
      console.error("Failed to send log to backend:", error);
    }
  }

  generateCorrelationId() {
    return `frontend_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  info(message, data) {
    this.log("info", message, data);
  }

  error(message, data) {
    this.log("error", message, data);
  }

  warn(message, data) {
    this.log("warn", message, data);
  }
}

export default new Logger();
```

### 2. Performance Monitoring

#### Cross-Repository Metrics

```javascript
// utils/metrics.js
class MetricsCollector {
  constructor() {
    this.metrics = {
      apiCalls: {},
      errors: {},
      performance: {},
    };
  }

  trackApiCall(endpoint, duration, success) {
    if (!this.metrics.apiCalls[endpoint]) {
      this.metrics.apiCalls[endpoint] = {
        count: 0,
        totalDuration: 0,
        errors: 0,
      };
    }

    const metric = this.metrics.apiCalls[endpoint];
    metric.count++;
    metric.totalDuration += duration;

    if (!success) {
      metric.errors++;
    }

    // Send to backend
    this.sendMetric("api_call", {
      endpoint,
      duration,
      success,
      timestamp: Date.now(),
    });
  }

  trackError(error, context = {}) {
    const errorKey = `${error.code || "UNKNOWN"}_${
      context.endpoint || "unknown"
    }`;

    if (!this.metrics.errors[errorKey]) {
      this.metrics.errors[errorKey] = 0;
    }

    this.metrics.errors[errorKey]++;

    this.sendMetric("error", {
      code: error.code,
      message: error.message,
      context,
      timestamp: Date.now(),
    });
  }

  async sendMetric(type, data) {
    try {
      await fetch(`${process.env.REACT_APP_API_URL}/api/metrics`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.REACT_APP_API_KEY}`,
        },
        body: JSON.stringify({
          type,
          data,
          source: "frontend",
          timestamp: Date.now(),
        }),
      });
    } catch (error) {
      console.error("Failed to send metric:", error);
    }
  }
}

export default new MetricsCollector();
```

## Best Practices

### 1. Version Management

#### API Versioning Strategy

```javascript
// config/api-versions.js
const API_VERSIONS = {
  v1: {
    baseUrl: "https://api.codejoin.com/v1",
    deprecated: false,
    sunsetDate: null,
  },
  v2: {
    baseUrl: "https://api.codejoin.com/v2",
    deprecated: false,
    sunsetDate: null,
  },
};

const getCurrentVersion = () => {
  return API_VERSIONS.v1; // Default to v1
};

const getApiUrl = (version = "v1") => {
  const versionConfig = API_VERSIONS[version];
  if (!versionConfig) {
    throw new Error(`API version ${version} not found`);
  }

  if (versionConfig.deprecated) {
    console.warn(
      `API version ${version} is deprecated. Sunset date: ${versionConfig.sunsetDate}`
    );
  }

  return versionConfig.baseUrl;
};

export { getCurrentVersion, getApiUrl };
```

### 2. Error Handling

#### Centralized Error Handler

```javascript
// utils/error-handler.js
class ErrorHandler {
  static handle(error, context = {}) {
    const errorInfo = {
      message: error.message,
      code: error.code || "UNKNOWN",
      status: error.status || 500,
      context,
      timestamp: new Date().toISOString(),
    };

    // Log error
    console.error("Application Error:", errorInfo);

    // Send to monitoring service
    this.reportError(errorInfo);

    // Show user-friendly message
    this.showUserMessage(error);

    // Track metrics
    this.trackError(errorInfo);
  }

  static reportError(errorInfo) {
    // Send to error tracking service
    if (window.Sentry) {
      window.Sentry.captureException(errorInfo);
    }
  }

  static showUserMessage(error) {
    const messages = {
      NETWORK_ERROR:
        "Network connection failed. Please check your internet connection.",
      TIMEOUT: "Request timed out. Please try again.",
      UNAUTHORIZED: "Please log in to continue.",
      RATE_LIMITED: "Too many requests. Please wait a moment.",
      SERVER_ERROR: "Server error occurred. Please try again later.",
    };

    const message =
      messages[error.code] || "An error occurred. Please try again.";

    // Show toast notification
    if (window.toast) {
      window.toast.error(message);
    }
  }

  static trackError(errorInfo) {
    // Send error metrics to backend
    fetch(`${process.env.REACT_APP_API_URL}/api/errors`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.REACT_APP_API_KEY}`,
      },
      body: JSON.stringify(errorInfo),
    }).catch(() => {
      // Ignore errors in error reporting
    });
  }
}

export default ErrorHandler;
```

### 3. Cache Management

#### Cross-Repository Caching

```javascript
// utils/cache.js
class CacheManager {
  constructor() {
    this.cache = new Map();
    this.ttl = new Map();
    this.defaultTTL = 5 * 60 * 1000; // 5 minutes
  }

  set(key, value, ttl = this.defaultTTL) {
    this.cache.set(key, value);
    this.ttl.set(key, Date.now() + ttl);
  }

  get(key) {
    const expiry = this.ttl.get(key);
    if (expiry && Date.now() > expiry) {
      this.delete(key);
      return null;
    }

    return this.cache.get(key);
  }

  delete(key) {
    this.cache.delete(key);
    this.ttl.delete(key);
  }

  clear() {
    this.cache.clear();
    this.ttl.clear();
  }

  // Cache API responses
  async cachedFetch(url, options = {}, ttl = this.defaultTTL) {
    const cacheKey = `${url}_${JSON.stringify(options)}`;
    const cached = this.get(cacheKey);

    if (cached) {
      return cached;
    }

    try {
      const response = await fetch(url, options);
      const data = await response.json();

      if (response.ok) {
        this.set(cacheKey, data, ttl);
      }

      return data;
    } catch (error) {
      // Return stale cache if available
      const stale = this.get(cacheKey);
      if (stale) {
        return stale;
      }
      throw error;
    }
  }
}

export default new CacheManager();
```

## Troubleshooting

### Common Issues and Solutions

1. **CORS Errors**

   - Verify backend CORS configuration
   - Check if frontend URL is in allowed origins
   - Ensure credentials are included if needed

2. **Authentication Failures**

   - Verify API key is correct
   - Check if key is expired
   - Ensure proper header format

3. **Network Issues**

   - Check if backend is deployed and accessible
   - Verify DNS configuration
   - Test with curl or Postman

4. **Environment Mismatches**
   - Verify environment variables
   - Check if using correct API URLs
   - Ensure consistent configurations

### Debug Commands

```bash
# Test backend health
curl -H "Authorization: Bearer YOUR_API_KEY" https://your-backend-url.com/health

# Test CORS
curl -H "Origin: https://your-frontend-url.com" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: X-Requested-With" \
     -X OPTIONS https://your-backend-url.com/api/execute

# Test API with frontend
curl -X POST https://your-backend-url.com/api/execute \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_API_KEY" \
     -d '{"language":"python","code":"print(\"test\")"}'
```

This comprehensive guide covers all aspects of multi-repository integration, from setup and deployment to monitoring and troubleshooting. Use this as a reference when setting up your distributed development workflow.
