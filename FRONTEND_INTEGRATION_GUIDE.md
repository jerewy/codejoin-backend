# Frontend Integration Guide

## Overview

This guide provides practical examples and best practices for integrating the frontend with the CodeJoin backend API. It includes code examples for common operations, error handling, and debugging.

## Quick Start

### 1. Base Configuration

```javascript
// config/api.js
const API_CONFIG = {
  BASE_URL:
    process.env.NODE_ENV === "production"
      ? "https://your-backend-url.com"
      : "http://localhost:3001",
  API_KEY: process.env.REACT_APP_API_KEY,
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
};

export default API_CONFIG;
```

### 2. API Client Setup

```javascript
// services/apiClient.js
import API_CONFIG from "../config/api";

class ApiClient {
  constructor() {
    this.baseURL = API_CONFIG.BASE_URL;
    this.apiKey = API_CONFIG.API_KEY;
    this.timeout = API_CONFIG.TIMEOUT;
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
        ...options.headers,
      },
      ...options,
    };

    try {
      const response = await fetch(url, config);

      if (!response.ok) {
        throw new ApiError(response.status, await response.json());
      }

      return await response.json();
    } catch (error) {
      if (error instanceof ApiError) {
        throw error;
      }
      throw new NetworkError(error.message);
    }
  }

  // Health check
  async healthCheck() {
    return this.request("/health");
  }

  // Execute code
  async executeCode(language, code, options = {}) {
    return this.request("/api/execute", {
      method: "POST",
      body: JSON.stringify({
        language,
        code,
        ...options,
      }),
    });
  }

  // Get execution status
  async getExecutionStatus(executionId) {
    return this.request(`/api/status/${executionId}`);
  }

  // Get detailed health
  async getDetailedHealth() {
    return this.request("/api/health/detailed");
  }

  // Get AI service health
  async getAIHealth() {
    return this.request("/api/health/ai");
  }

  // AI chat
  async chatWithAI(message, context = {}) {
    return this.request("/api/ai/chat", {
      method: "POST",
      body: JSON.stringify({
        message,
        context,
      }),
    });
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

class NetworkError extends Error {
  constructor(message) {
    super(message || "Network error");
    this.name = "NetworkError";
  }
}

export default new ApiClient();
```

## React Components Examples

### 1. Code Editor Component

```jsx
// components/CodeEditor.jsx
import React, { useState, useCallback } from "react";
import apiClient from "../services/apiClient";
import { useToast } from "../hooks/useToast";

const CodeEditor = () => {
  const [code, setCode] = useState("");
  const [language, setLanguage] = useState("python");
  const [isExecuting, setIsExecuting] = useState(false);
  const [output, setOutput] = useState("");
  const { showError, showSuccess } = useToast();

  const handleExecute = useCallback(async () => {
    if (!code.trim()) {
      showError("Please enter some code to execute");
      return;
    }

    setIsExecuting(true);
    setOutput("");

    try {
      const result = await apiClient.executeCode(language, code);

      if (result.status === "completed") {
        setOutput(result.output);
        showSuccess("Code executed successfully");
      } else {
        setOutput(result.error || "Execution failed");
        showError("Execution failed");
      }
    } catch (error) {
      console.error("Execution error:", error);

      if (error instanceof ApiError) {
        handleApiError(error);
      } else {
        showError("Network error. Please check your connection.");
      }
    } finally {
      setIsExecuting(false);
    }
  }, [code, language, showError, showSuccess]);

  const handleApiError = (error) => {
    switch (error.code) {
      case "TIMEOUT":
        showError("Code execution timed out. Try optimizing your code.");
        break;
      case "SYNTAX_ERROR":
        showError("Syntax error in your code. Please check and try again.");
        break;
      case "RATE_LIMITED":
        showError("Too many requests. Please wait a moment and try again.");
        break;
      case "INVALID_LANGUAGE":
        showError("Unsupported programming language.");
        break;
      default:
        showError(`Server error: ${error.message}`);
    }
  };

  return (
    <div className="code-editor">
      <div className="editor-header">
        <select
          value={language}
          onChange={(e) => setLanguage(e.target.value)}
          disabled={isExecuting}
        >
          <option value="python">Python</option>
          <option value="javascript">JavaScript</option>
          <option value="java">Java</option>
          <option value="cpp">C++</option>
          <option value="c">C</option>
          <option value="go">Go</option>
          <option value="rust">Rust</option>
        </select>

        <button
          onClick={handleExecute}
          disabled={isExecuting || !code.trim()}
          className="execute-button"
        >
          {isExecuting ? "Executing..." : "Run Code"}
        </button>
      </div>

      <textarea
        value={code}
        onChange={(e) => setCode(e.target.value)}
        placeholder={`Enter your ${language} code here...`}
        className="code-input"
        disabled={isExecuting}
      />

      {output && (
        <div className="output-section">
          <h3>Output:</h3>
          <pre className="output">{output}</pre>
        </div>
      )}
    </div>
  );
};

export default CodeEditor;
```

### 2. System Status Component

```jsx
// components/SystemStatus.jsx
import React, { useState, useEffect } from "react";
import apiClient from "../services/apiClient";

const SystemStatus = () => {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchHealth = async () => {
      try {
        const healthData = await apiClient.getDetailedHealth();
        setHealth(healthData);
        setError(null);
      } catch (err) {
        setError("Failed to fetch system status");
        console.error("Health check error:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchHealth();
    const interval = setInterval(fetchHealth, 30000); // Update every 30 seconds

    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (status) => {
    switch (status) {
      case "healthy":
        return "green";
      case "degraded":
        return "orange";
      case "unhealthy":
        return "red";
      default:
        return "gray";
    }
  };

  if (loading) return <div>Loading system status...</div>;
  if (error) return <div className="error">{error}</div>;
  if (!health) return <div>No health data available</div>;

  return (
    <div className="system-status">
      <h2>System Status</h2>

      <div className="status-overview">
        <div className={`status-indicator ${health.status}`}>
          Overall Status: {health.status.toUpperCase()}
        </div>
        <div className="uptime">
          Uptime: {Math.floor(health.uptime / 3600)}h{" "}
          {Math.floor((health.uptime % 3600) / 60)}m
        </div>
      </div>

      <div className="services-status">
        <h3>Services</h3>

        <div className="service-item">
          <span className="service-name">Docker</span>
          <span
            className="service-status"
            style={{ color: getStatusColor(health.services.docker.status) }}
          >
            {health.services.docker.status}
          </span>
          {health.services.docker.version && (
            <span className="service-version">
              v{health.services.docker.version}
            </span>
          )}
        </div>

        <div className="service-item">
          <span className="service-name">AI Services</span>
          <span
            className="service-status"
            style={{ color: getStatusColor(health.services.ai.status) }}
          >
            {health.services.ai.status}
          </span>
        </div>

        {health.services.redis && (
          <div className="service-item">
            <span className="service-name">Redis</span>
            <span
              className="service-status"
              style={{ color: getStatusColor(health.services.redis.status) }}
            >
              {health.services.redis.status}
            </span>
          </div>
        )}
      </div>

      {health.metrics && (
        <div className="metrics">
          <h3>Metrics</h3>
          <div className="metric-item">
            <span>Memory Usage:</span>
            <span>{health.metrics.memoryUsage}</span>
          </div>
          <div className="metric-item">
            <span>CPU Usage:</span>
            <span>{health.metrics.cpuUsage}</span>
          </div>
          <div className="metric-item">
            <span>Active Connections:</span>
            <span>{health.metrics.activeConnections}</span>
          </div>
        </div>
      )}
    </div>
  );
};

export default SystemStatus;
```

### 3. AI Chat Component

```jsx
// components/AIChat.jsx
import React, { useState, useEffect } from "react";
import apiClient from "../services/apiClient";
import { useToast } from "../hooks/useToast";

const AIChat = ({ code, language }) => {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [aiHealth, setAiHealth] = useState(null);
  const { showError, showSuccess } = useToast();

  useEffect(() => {
    const fetchAIHealth = async () => {
      try {
        const health = await apiClient.getAIHealth();
        setAiHealth(health);
      } catch (error) {
        console.error("Failed to fetch AI health:", error);
      }
    };

    fetchAIHealth();
  }, []);

  const handleSendMessage = async () => {
    if (!input.trim()) return;

    const userMessage = { text: input, sender: "user", timestamp: new Date() };
    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsLoading(true);

    try {
      const response = await apiClient.chatWithAI(input, {
        code,
        language,
      });

      const aiMessage = {
        text: response.message,
        sender: "ai",
        timestamp: new Date(),
        provider: response.provider,
        model: response.model,
      };

      setMessages((prev) => [...prev, aiMessage]);
      showSuccess("Response received");
    } catch (error) {
      console.error("AI chat error:", error);

      const errorMessage = {
        text: "Sorry, I encountered an error. Please try again.",
        sender: "ai",
        timestamp: new Date(),
        error: true,
      };

      setMessages((prev) => [...prev, errorMessage]);
      showError("Failed to get AI response");
    } finally {
      setIsLoading(false);
    }
  };

  const getProviderStatus = (provider) => {
    if (!aiHealth || !aiHealth.providers) return "unknown";
    return aiHealth.providers[provider]?.status || "unknown";
  };

  const getProviderColor = (status) => {
    switch (status) {
      case "healthy":
        return "green";
      case "degraded":
        return "orange";
      case "unhealthy":
        return "red";
      default:
        return "gray";
    }
  };

  return (
    <div className="ai-chat">
      <div className="chat-header">
        <h3>AI Assistant</h3>
        {aiHealth && (
          <div className="ai-providers">
            {Object.entries(aiHealth.providers).map(([provider, info]) => (
              <span
                key={provider}
                className="provider-status"
                style={{ color: getProviderColor(info.status) }}
                title={`${provider}: ${info.status}`}
              >
                {provider.charAt(0).toUpperCase()}
              </span>
            ))}
          </div>
        )}
      </div>

      <div className="chat-messages">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`message ${message.sender} ${
              message.error ? "error" : ""
            }`}
          >
            <div className="message-content">{message.text}</div>
            <div className="message-meta">
              <span className="timestamp">
                {message.timestamp.toLocaleTimeString()}
              </span>
              {message.provider && (
                <span className="provider">
                  via {message.provider} ({message.model})
                </span>
              )}
            </div>
          </div>
        ))}

        {isLoading && (
          <div className="message ai loading">
            <div className="typing-indicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        )}
      </div>

      <div className="chat-input">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === "Enter" && handleSendMessage()}
          placeholder="Ask about your code..."
          disabled={isLoading}
        />
        <button
          onClick={handleSendMessage}
          disabled={isLoading || !input.trim()}
        >
          Send
        </button>
      </div>
    </div>
  );
};

export default AIChat;
```

## Custom Hooks

### 1. useApi Hook

```javascript
// hooks/useApi.js
import { useState, useEffect, useCallback } from "react";
import apiClient from "../services/apiClient";

export const useApi = (apiCall, dependencies = []) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const execute = useCallback(
    async (...args) => {
      setLoading(true);
      setError(null);

      try {
        const result = await apiCall(...args);
        setData(result);
        return result;
      } catch (err) {
        setError(err);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [apiCall]
  );

  useEffect(() => {
    if (dependencies.length > 0) {
      execute();
    }
  }, dependencies);

  const reset = useCallback(() => {
    setData(null);
    setError(null);
    setLoading(false);
  }, []);

  return { data, loading, error, execute, reset };
};
```

### 2. useWebSocket Hook

```javascript
// hooks/useWebSocket.js
import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

export const useWebSocket = (url, options = {}) => {
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState(null);
  const socketRef = useRef(null);

  useEffect(() => {
    socketRef.current = io(url, {
      transports: ["websocket"],
      ...options,
    });

    socketRef.current.on("connect", () => {
      setConnected(true);
      setError(null);
    });

    socketRef.current.on("disconnect", () => {
      setConnected(false);
    });

    socketRef.current.on("connect_error", (err) => {
      setError(err);
      setConnected(false);
    });

    return () => {
      if (socketRef.current) {
        socketRef.current.disconnect();
      }
    };
  }, [url]);

  const emit = useCallback(
    (event, data) => {
      if (socketRef.current && connected) {
        socketRef.current.emit(event, data);
      }
    },
    [connected]
  );

  const on = useCallback((event, callback) => {
    if (socketRef.current) {
      socketRef.current.on(event, callback);
    }
  }, []);

  const off = useCallback((event, callback) => {
    if (socketRef.current) {
      socketRef.current.off(event, callback);
    }
  }, []);

  return { connected, error, emit, on, off };
};
```

### 3. useTerminal Hook

```javascript
// hooks/useTerminal.js
import { useState, useCallback, useEffect } from "react";
import { useWebSocket } from "./useWebSocket";

export const useTerminal = (language) => {
  const [sessionId, setSessionId] = useState(null);
  const [output, setOutput] = useState("");
  const [active, setActive] = useState(false);
  const { connected, emit, on, off } = useWebSocket("http://localhost:3001");

  const createSession = useCallback(() => {
    if (!connected) return;

    emit("terminal:create", {
      language,
      cols: 80,
      rows: 24,
    });
  }, [connected, language, emit]);

  const sendInput = useCallback(
    (data) => {
      if (!sessionId || !active) return;

      emit("terminal:data", {
        sessionId,
        data,
      });
    },
    [sessionId, active, emit]
  );

  const resizeTerminal = useCallback(
    (cols, rows) => {
      if (!sessionId || !active) return;

      emit("terminal:resize", {
        sessionId,
        cols,
        rows,
      });
    },
    [sessionId, active, emit]
  );

  const closeSession = useCallback(() => {
    if (!sessionId || !active) return;

    emit("terminal:close", { sessionId });
    setSessionId(null);
    setActive(false);
    setOutput("");
  }, [sessionId, active, emit]);

  useEffect(() => {
    on("terminal:created", (data) => {
      setSessionId(data.sessionId);
      setActive(true);
      setOutput("");
    });

    on("terminal:data", (data) => {
      if (data.sessionId === sessionId) {
        setOutput((prev) => prev + data.chunk);
      }
    });

    on("terminal:closed", (data) => {
      if (data.sessionId === sessionId) {
        setActive(false);
      }
    });

    return () => {
      off("terminal:created");
      off("terminal:data");
      off("terminal:closed");
    };
  }, [sessionId, on, off]);

  return {
    sessionId,
    output,
    active,
    connected,
    createSession,
    sendInput,
    resizeTerminal,
    closeSession,
  };
};
```

## Error Boundary

```jsx
// components/ErrorBoundary.jsx
import React from "react";

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error("Error caught by boundary:", error, errorInfo);

    // Log error to monitoring service
    if (window.analytics) {
      window.analytics.track("Error", {
        error: error.message,
        stack: error.stack,
        componentStack: errorInfo.componentStack,
      });
    }
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h2>Something went wrong</h2>
          <p>
            We apologize for the inconvenience. Please try refreshing the page.
          </p>
          <button onClick={() => window.location.reload()}>Refresh Page</button>
          {process.env.NODE_ENV === "development" && (
            <details className="error-details">
              <summary>Error Details</summary>
              <pre>{this.state.error?.stack}</pre>
            </details>
          )}
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
```

## Toast Notification Hook

```javascript
// hooks/useToast.js
import { useState, useCallback } from "react";

export const useToast = () => {
  const [toasts, setToasts] = useState([]);

  const addToast = useCallback((message, type = "info", duration = 5000) => {
    const id = Date.now();
    const toast = { id, message, type };

    setToasts((prev) => [...prev, toast]);

    if (duration > 0) {
      setTimeout(() => {
        removeToast(id);
      }, duration);
    }

    return id;
  }, []);

  const removeToast = useCallback((id) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const showSuccess = useCallback(
    (message, duration) => {
      return addToast(message, "success", duration);
    },
    [addToast]
  );

  const showError = useCallback(
    (message, duration) => {
      return addToast(message, "error", duration);
    },
    [addToast]
  );

  const showInfo = useCallback(
    (message, duration) => {
      return addToast(message, "info", duration);
    },
    [addToast]
  );

  const showWarning = useCallback(
    (message, duration) => {
      return addToast(message, "warning", duration);
    },
    [addToast]
  );

  return {
    toasts,
    addToast,
    removeToast,
    showSuccess,
    showError,
    showInfo,
    showWarning,
  };
};
```

## Testing Examples

### 1. API Client Tests

```javascript
// __tests__/apiClient.test.js
import apiClient from "../services/apiClient";

// Mock fetch
global.fetch = jest.fn();

describe("ApiClient", () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  test("health check returns status", async () => {
    const mockResponse = {
      status: "OK",
      timestamp: "2024-01-01T00:00:00.000Z",
    };
    fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockResponse),
    });

    const result = await apiClient.healthCheck();
    expect(result).toEqual(mockResponse);
    expect(fetch).toHaveBeenCalledWith(
      "http://localhost:3001/health",
      expect.objectContaining({
        headers: expect.objectContaining({
          "Content-Type": "application/json",
          Authorization: "Bearer test-api-key",
        }),
      })
    );
  });

  test("execute code sends correct request", async () => {
    const mockResponse = { id: "test-id", status: "completed" };
    fetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockResponse),
    });

    const result = await apiClient.executeCode("python", 'print("Hello")');
    expect(result).toEqual(mockResponse);
    expect(fetch).toHaveBeenCalledWith(
      "http://localhost:3001/api/execute",
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({
          language: "python",
          code: 'print("Hello")',
        }),
      })
    );
  });

  test("handles API errors correctly", async () => {
    const errorResponse = {
      error: "Syntax Error",
      message: "Invalid syntax",
      code: "SYNTAX_ERROR",
    };
    fetch.mockResolvedValueOnce({
      ok: false,
      status: 400,
      json: () => Promise.resolve(errorResponse),
    });

    await expect(apiClient.executeCode("python", "invalid")).rejects.toThrow(
      "Invalid syntax"
    );
  });
});
```

### 2. Component Tests

```javascript
// __tests__/CodeEditor.test.js
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import CodeEditor from "../components/CodeEditor";
import apiClient from "../services/apiClient";

// Mock API client
jest.mock("../services/apiClient");

describe("CodeEditor", () => {
  beforeEach(() => {
    apiClient.executeCode.mockClear();
  });

  test("renders code editor", () => {
    render(<CodeEditor />);
    expect(screen.getByRole("combobox")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Run Code" })
    ).toBeInTheDocument();
    expect(
      screen.getByPlaceholderText(/Enter your python code here.../)
    ).toBeInTheDocument();
  });

  test("executes code when run button is clicked", async () => {
    const mockResult = {
      status: "completed",
      output: "Hello, World!\n",
    };
    apiClient.executeCode.mockResolvedValue(mockResult);

    render(<CodeEditor />);

    const textarea = screen.getByPlaceholderText(
      /Enter your python code here.../
    );
    const runButton = screen.getByRole("button", { name: "Run Code" });

    fireEvent.change(textarea, { target: { value: 'print("Hello, World!")' } });
    fireEvent.click(runButton);

    await waitFor(() => {
      expect(apiClient.executeCode).toHaveBeenCalledWith(
        "python",
        'print("Hello, World!")'
      );
    });

    expect(screen.getByText("Hello, World!")).toBeInTheDocument();
  });

  test("handles execution errors", async () => {
    const mockError = new Error("Execution failed");
    mockError.code = "SYNTAX_ERROR";
    apiClient.executeCode.mockRejectedValue(mockError);

    render(<CodeEditor />);

    const textarea = screen.getByPlaceholderText(
      /Enter your python code here.../
    );
    const runButton = screen.getByRole("button", { name: "Run Code" });

    fireEvent.change(textarea, { target: { value: "invalid syntax" } });
    fireEvent.click(runButton);

    await waitFor(() => {
      expect(screen.getByText(/Syntax error in your code/)).toBeInTheDocument();
    });
  });
});
```

## Debugging Tools

### 1. API Logger

```javascript
// utils/apiLogger.js
const API_LOGGER = {
  log: (level, message, data = {}) => {
    if (process.env.NODE_ENV === "development") {
      console[level](`[API] ${message}`, {
        timestamp: new Date().toISOString(),
        ...data,
      });
    }
  },

  request: (method, url, data) => {
    API_LOGGER.log("info", `${method} ${url}`, { data });
  },

  response: (method, url, status, data) => {
    API_LOGGER.log("info", `${method} ${url} - ${status}`, { data });
  },

  error: (method, url, error) => {
    API_LOGGER.log("error", `${method} ${url} - Error`, { error });
  },
};

export default API_LOGGER;
```

### 2. Debug Panel

```jsx
// components/DebugPanel.jsx
import React, { useState, useEffect } from "react";
import apiClient from "../services/apiClient";

const DebugPanel = () => {
  const [logs, setLogs] = useState([]);
  const [apiResponses, setApiResponses] = useState([]);

  useEffect(() => {
    // Intercept fetch calls for debugging
    const originalFetch = window.fetch;
    window.fetch = async (...args) => {
      const [url, options] = args;
      const start = performance.now();

      try {
        const response = await originalFetch(...args);
        const end = performance.now();

        setApiResponses((prev) => [
          ...prev,
          {
            url,
            method: options?.method || "GET",
            status: response.status,
            duration: end - start,
            timestamp: new Date().toISOString(),
          },
        ]);

        return response;
      } catch (error) {
        setLogs((prev) => [
          ...prev,
          {
            type: "error",
            message: `API Error: ${error.message}`,
            timestamp: new Date().toISOString(),
          },
        ]);
        throw error;
      }
    };

    return () => {
      window.fetch = originalFetch;
    };
  }, []);

  const clearLogs = () => {
    setLogs([]);
    setApiResponses([]);
  };

  const testAPI = async () => {
    try {
      await apiClient.healthCheck();
      await apiClient.getDetailedHealth();
    } catch (error) {
      console.error("Test API error:", error);
    }
  };

  if (process.env.NODE_ENV !== "development") {
    return null;
  }

  return (
    <div className="debug-panel">
      <h3>Debug Panel</h3>

      <div className="debug-controls">
        <button onClick={testAPI}>Test API</button>
        <button onClick={clearLogs}>Clear Logs</button>
      </div>

      <div className="api-responses">
        <h4>API Responses</h4>
        {apiResponses.map((response, index) => (
          <div key={index} className="api-response">
            <span
              className={`status ${
                response.status < 400 ? "success" : "error"
              }`}
            >
              {response.status}
            </span>
            <span className="method">{response.method}</span>
            <span className="url">{response.url}</span>
            <span className="duration">{response.duration.toFixed(2)}ms</span>
          </div>
        ))}
      </div>

      <div className="logs">
        <h4>Logs</h4>
        {logs.map((log, index) => (
          <div key={index} className={`log ${log.type}`}>
            <span className="timestamp">{log.timestamp}</span>
            <span className="message">{log.message}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default DebugPanel;
```

## Performance Optimization

### 1. Request Debouncing

```javascript
// utils/debounce.js
export const debounce = (func, wait) => {
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
```

### 2. Request Caching

```javascript
// utils/cache.js
class SimpleCache {
  constructor(ttl = 60000) {
    // 1 minute default TTL
    this.cache = new Map();
    this.ttl = ttl;
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      timestamp: Date.now(),
    });
  }

  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;

    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }

    return item.value;
  }

  clear() {
    this.cache.clear();
  }
}

export default new SimpleCache();
```

### 3. Optimized API Client

```javascript
// services/optimizedApiClient.js
import apiClient from "./apiClient";
import cache from "../utils/cache";
import { debounce } from "../utils/debounce";

class OptimizedApiClient {
  async cachedHealthCheck() {
    const cached = cache.get("health");
    if (cached) return cached;

    const health = await apiClient.healthCheck();
    cache.set("health", health);
    return health;
  }

  debouncedExecuteCode = debounce(async (language, code, options) => {
    return apiClient.executeCode(language, code, options);
  }, 500);

  async batchExecute(requests) {
    const promises = requests.map(({ language, code, options }) =>
      apiClient.executeCode(language, code, options)
    );
    return Promise.allSettled(promises);
  }
}

export default new OptimizedApiClient();
```

This comprehensive integration guide provides the frontend team with all the necessary tools, components, and best practices to successfully connect with the backend API. The examples cover common use cases, error handling, testing, debugging, and performance optimization.
