# Frontend Documentation Setup Guide

## Overview

This guide explains how to connect your frontend repositories to the CodeJoin backend API documentation. Follow these steps to integrate the documentation into your frontend projects.

## Quick Setup (5 minutes)

### Step 1: Add Environment Variables

Create or update your `.env` file in the frontend repository:

```env
# Backend API Configuration
REACT_APP_API_URL=https://your-backend-url.com
REACT_APP_WS_URL=wss://your-backend-url.com
REACT_APP_API_KEY=your_api_key_here

# Environment
REACT_APP_ENVIRONMENT=development
REACT_APP_ENABLE_DEBUG=true
```

### Step 2: Install API Client

Add the API client to your frontend project:

```bash
# For React projects
npm install axios socket.io-client

# For Vue projects
npm install axios socket.io-client

# For Angular projects
npm install axios socket.io-client
```

### Step 3: Create API Service

Create an API service file in your frontend project:

**React (`src/services/api.js`):**

```javascript
import axios from "axios";
import { io } from "socket.io-client";

const API_BASE_URL = process.env.REACT_APP_API_URL || "http://localhost:3001";
const API_KEY = process.env.REACT_APP_API_KEY;

class ApiService {
  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${API_KEY}`,
      },
      timeout: 30000,
    });

    // Add response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error) => {
        this.handleError(error);
        return Promise.reject(error);
      }
    );
  }

  // Health check
  async healthCheck() {
    const response = await this.client.get("/health");
    return response.data;
  }

  // Execute code
  async executeCode(language, code, options = {}) {
    const response = await this.client.post("/api/execute", {
      language,
      code,
      ...options,
    });
    return response.data;
  }

  // Get execution status
  async getExecutionStatus(executionId) {
    const response = await this.client.get(`/api/status/${executionId}`);
    return response.data;
  }

  // AI chat
  async chatWithAI(message, context = {}) {
    const response = await this.client.post("/api/ai/chat", {
      message,
      context,
    });
    return response.data;
  }

  // Create WebSocket connection
  createSocket() {
    return io(process.env.REACT_APP_WS_URL, {
      transports: ["websocket"],
      auth: {
        token: API_KEY,
      },
    });
  }

  // Error handling
  handleError(error) {
    if (error.response) {
      const { status, data } = error.response;

      switch (data.code) {
        case "RATE_LIMITED":
          console.error(
            "Rate limit exceeded. Please wait before making another request."
          );
          break;
        case "TIMEOUT":
          console.error("Request timed out. Please try again.");
          break;
        case "UNAUTHORIZED":
          console.error("Invalid API key. Please check your configuration.");
          break;
        default:
          console.error(`API Error: ${data.message || "Unknown error"}`);
      }
    } else if (error.request) {
      console.error("Network error. Please check your connection.");
    } else {
      console.error("Error:", error.message);
    }
  }
}

export default new ApiService();
```

### Step 4: Create Example Component

Create a simple component to test the API connection:

**React (`src/components/CodeExecutor.js`):**

```javascript
import React, { useState } from "react";
import apiService from "../services/api";

const CodeExecutor = () => {
  const [code, setCode] = useState('print("Hello, World!")');
  const [language, setLanguage] = useState("python");
  const [output, setOutput] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const executeCode = async () => {
    setLoading(true);
    setError("");
    setOutput("");

    try {
      const result = await apiService.executeCode(language, code);

      if (result.status === "completed") {
        setOutput(result.output);
      } else {
        setError(result.error || "Execution failed");
      }
    } catch (err) {
      setError(err.message || "Failed to execute code");
    } finally {
      setLoading(false);
    }
  };

  const testConnection = async () => {
    try {
      const health = await apiService.healthCheck();
      alert(`Backend is healthy! Status: ${health.status}`);
    } catch (err) {
      alert(`Failed to connect to backend: ${err.message}`);
    }
  };

  return (
    <div style={{ padding: "20px", maxWidth: "600px", margin: "0 auto" }}>
      <h2>CodeJoin API Test</h2>

      <div style={{ marginBottom: "20px" }}>
        <button onClick={testConnection} style={{ marginRight: "10px" }}>
          Test Connection
        </button>
        <span>API URL: {process.env.REACT_APP_API_URL}</span>
      </div>

      <div style={{ marginBottom: "20px" }}>
        <label>
          Language:
          <select
            value={language}
            onChange={(e) => setLanguage(e.target.value)}
            style={{ marginLeft: "10px", marginRight: "20px" }}
          >
            <option value="python">Python</option>
            <option value="javascript">JavaScript</option>
            <option value="java">Java</option>
            <option value="cpp">C++</option>
          </select>
        </label>

        <button
          onClick={executeCode}
          disabled={loading}
          style={{ padding: "8px 16px" }}
        >
          {loading ? "Running..." : "Run Code"}
        </button>
      </div>

      <div style={{ marginBottom: "20px" }}>
        <textarea
          value={code}
          onChange={(e) => setCode(e.target.value)}
          rows={6}
          style={{ width: "100%", fontFamily: "monospace" }}
          placeholder="Enter your code here..."
        />
      </div>

      {output && (
        <div style={{ marginBottom: "20px" }}>
          <h3>Output:</h3>
          <pre
            style={{
              background: "#f5f5f5",
              padding: "10px",
              borderRadius: "4px",
              whiteSpace: "pre-wrap",
            }}
          >
            {output}
          </pre>
        </div>
      )}

      {error && (
        <div
          style={{
            color: "red",
            background: "#ffe6e6",
            padding: "10px",
            borderRadius: "4px",
            marginBottom: "20px",
          }}
        >
          <strong>Error:</strong> {error}
        </div>
      )}
    </div>
  );
};

export default CodeExecutor;
```

### Step 5: Update Your App

Import and use the component in your main App:

**React (`src/App.js`):**

```javascript
import React from "react";
import CodeExecutor from "./components/CodeExecutor";

function App() {
  return (
    <div className="App">
      <header
        style={{
          background: "#282c34",
          color: "white",
          padding: "20px",
          textAlign: "center",
        }}
      >
        <h1>CodeJoin Frontend Integration</h1>
        <p>Testing connection to backend API</p>
      </header>

      <main>
        <CodeExecutor />
      </main>
    </div>
  );
}

export default App;
```

## Framework-Specific Setup

### Vue.js Setup

**API Service (`src/services/api.js`):**

```javascript
import axios from "axios";
import { io } from "socket.io-client";

const API_BASE_URL = process.env.VUE_APP_API_URL || "http://localhost:3001";
const API_KEY = process.env.VUE_APP_API_KEY;

export default {
  install(app) {
    const api = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${API_KEY}`,
      },
    });

    app.config.globalProperties.$api = api;
    app.provide("api", api);
  },
};
```

**Component (`src/components/CodeExecutor.vue`):**

```vue
<template>
  <div class="code-executor">
    <h2>CodeJoin API Test</h2>

    <div class="controls">
      <select v-model="language">
        <option value="python">Python</option>
        <option value="javascript">JavaScript</option>
        <option value="java">Java</option>
      </select>

      <button @click="executeCode" :disabled="loading">
        {{ loading ? "Running..." : "Run Code" }}
      </button>
    </div>

    <textarea v-model="code" placeholder="Enter your code..."></textarea>

    <div v-if="output" class="output">
      <h3>Output:</h3>
      <pre>{{ output }}</pre>
    </div>

    <div v-if="error" class="error"><strong>Error:</strong> {{ error }}</div>
  </div>
</template>

<script>
import { inject } from "vue";

export default {
  name: "CodeExecutor",
  setup() {
    const api = inject("api");

    return {
      api,
      code: 'print("Hello, World!")',
      language: "python",
      output: "",
      error: "",
      loading: false,
    };
  },
  methods: {
    async executeCode() {
      this.loading = true;
      this.error = "";
      this.output = "";

      try {
        const response = await this.api.post("/api/execute", {
          language: this.language,
          code: this.code,
        });

        this.output = response.data.output;
      } catch (err) {
        this.error = err.response?.data?.message || "Execution failed";
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
```

### Angular Setup

**API Service (`src/app/services/api.service.ts`):**

```typescript
import { Injectable } from "@angular/core";
import { HttpClient, HttpHeaders } from "@angular/common/http";
import { Observable } from "rxjs";

@Injectable({
  providedIn: "root",
})
export class ApiService {
  private baseUrl = process.env["NG_APP_API_URL"] || "http://localhost:3001";
  private apiKey = process.env["NG_APP_API_KEY"];

  constructor(private http: HttpClient) {}

  private getHeaders() {
    return {
      headers: new HttpHeaders({
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      }),
    };
  }

  healthCheck(): Observable<any> {
    return this.http.get(`${this.baseUrl}/health`, this.getHeaders());
  }

  executeCode(language: string, code: string, options?: any): Observable<any> {
    return this.http.post(
      `${this.baseUrl}/api/execute`,
      {
        language,
        code,
        ...options,
      },
      this.getHeaders()
    );
  }
}
```

## Testing Your Integration

### 1. Test API Connection

Run your frontend application and check the browser console for any errors. The "Test Connection" button should show a success message.

### 2. Test Code Execution

Try executing some sample code:

**Python:**

```python
print("Hello from Python!")
for i in range(5):
    print(f"Count: {i}")
```

**JavaScript:**

```javascript
console.log("Hello from JavaScript!");
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map((n) => n * 2);
console.log("Doubled:", doubled);
```

### 3. Check Network Requests

Open your browser's Developer Tools (F12) and check the Network tab to see:

- API requests being sent to the backend
- Response status codes
- Response data

## Troubleshooting

### Common Issues

1. **CORS Errors**

   ```
   Access to fetch at 'https://your-backend-url.com' from origin 'http://localhost:3000' has been blocked by CORS policy
   ```

   **Solution:** Ensure your backend CORS configuration includes your frontend URL

2. **Authentication Errors**

   ```
   401 Unauthorized
   ```

   **Solution:** Check that your API key is correct and properly set in environment variables

3. **Network Errors**

   ```
   Network Error
   ```

   **Solution:** Verify the backend URL is correct and the backend is running

4. **Environment Variables Not Working**
   **Solution:** Restart your development server after changing .env files

### Debug Commands

Add these to your component for debugging:

```javascript
// Debug environment variables
console.log("API URL:", process.env.REACT_APP_API_URL);
console.log("API Key present:", !!process.env.REACT_APP_API_KEY);

// Debug API response
const debugResponse = (response) => {
  console.log("API Response:", response);
  return response;
};
```

## Next Steps

1. **Read the full documentation** at [FRONTEND_API_DOCUMENTATION.md](./FRONTEND_API_DOCUMENTATION.md)
2. **Check the quick reference** at [API_QUICK_REFERENCE.md](./API_QUICK_REFERENCE.md)
3. **Explore advanced examples** in [FRONTEND_INTEGRATION_GUIDE.md](./FRONTEND_INTEGRATION_GUIDE.md)
4. **Set up WebSocket connections** for real-time terminal sessions
5. **Implement error handling** and user feedback
6. **Add loading states** and progress indicators

## Support

If you encounter issues:

1. Check the browser console for error messages
2. Verify your environment variables are set correctly
3. Ensure the backend is running and accessible
4. Check the troubleshooting section in the full documentation

---

**Ready to build amazing features with the CodeJoin API! 🚀**
