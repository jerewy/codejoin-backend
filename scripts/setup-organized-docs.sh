#!/bin/bash

# Script to set up organized documentation structure in codejoin-docs repository

BACKEND_REPO_PATH="$(pwd)"
DOCS_REPO_PATH="../codejoin-docs"

echo "🚀 Setting up organized documentation structure..."

# Check if docs repository exists
if [ ! -d "$DOCS_REPO_PATH" ]; then
    echo "❌ Docs repository not found at $DOCS_REPO_PATH"
    echo "Please clone the repository first:"
    echo "git clone https://github.com/jerewy/codejoin-docs.git ../codejoin-docs"
    exit 1
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$DOCS_REPO_PATH/docs/backend"
mkdir -p "$DOCS_REPO_PATH/docs/socket"
mkdir -p "$DOCS_REPO_PATH/docs/frontend"
mkdir -p "$DOCS_REPO_PATH/examples/backend-examples"
mkdir -p "$DOCS_REPO_PATH/examples/socket-examples"
mkdir -p "$DOCS_REPO_PATH/examples/frontend-examples"
mkdir -p "$DOCS_REPO_PATH/guides"

# Copy frontend documentation files
echo "📄 Copying frontend documentation..."
cp "$BACKEND_REPO_PATH/FRONTEND_API_DOCUMENTATION.md" "$DOCS_REPO_PATH/docs/frontend/"
cp "$BACKEND_REPO_PATH/FRONTEND_INTEGRATION_GUIDE.md" "$DOCS_REPO_PATH/docs/frontend/"
cp "$BACKEND_REPO_PATH/API_QUICK_REFERENCE.md" "$DOCS_REPO_PATH/docs/frontend/"
cp "$BACKEND_REPO_PATH/FRONTEND_DOCS_SETUP_GUIDE.md" "$DOCS_REPO_PATH/docs/frontend/"
cp "$BACKEND_REPO_PATH/README_FOR_FRONTEND_TEAMS.md" "$DOCS_REPO_PATH/docs/frontend/README.md"
cp "$BACKEND_REPO_PATH/MULTI_REPOSITORY_INTEGRATION.md" "$DOCS_REPO_PATH/docs/frontend/"

# Copy guides
echo "📋 Copying guides..."
cp "$BACKEND_REPO_PATH/DOCS_DEPLOYMENT_GUIDE.md" "$DOCS_REPO_PATH/guides/"

# Create placeholder files for missing documentation
echo "📝 Creating placeholder files..."
touch "$DOCS_REPO_PATH/docs/backend/API_DOCUMENTATION.md"
touch "$DOCS_REPO_PATH/docs/backend/DEPLOYMENT_GUIDE.md"
touch "$DOCS_REPO_PATH/docs/backend/ENVIRONMENT_SETUP.md"

touch "$DOCS_REPO_PATH/docs/socket/SOCKET_API_DOCUMENTATION.md"
touch "$DOCS_REPO_PATH/docs/socket/WEBSOCKET_GUIDE.md"
touch "$DOCS_REPO_PATH/docs/socket/REALTIME_EXAMPLES.md"

touch "$DOCS_REPO_PATH/guides/GETTING_STARTED.md"
touch "$DOCS_REPO_PATH/guides/TROUBLESHOOTING.md"
touch "$DOCS_REPO_PATH/guides/BEST_PRACTICES.md"

# Create main README.md
echo "📖 Creating main README.md..."
cat > "$DOCS_REPO_PATH/README.md" << 'EOF'
# CodeJoin Documentation

Welcome to the CodeJoin documentation hub! This repository contains comprehensive documentation for all CodeJoin services.

## 📚 Documentation Structure

### 🔧 Backend Services
- [Backend API Documentation](./docs/backend/API_DOCUMENTATION.md) - Core backend API reference
- [Backend Deployment Guide](./docs/backend/DEPLOYMENT_GUIDE.md) - How to deploy backend services
- [Environment Setup](./docs/backend/ENVIRONMENT_SETUP.md) - Backend environment configuration

### 🔌 Socket Services
- [Socket API Documentation](./docs/socket/SOCKET_API_DOCUMENTATION.md) - WebSocket and socket.io reference
- [WebSocket Guide](./docs/socket/WEBSOCKET_GUIDE.md) - Real-time communication guide
- [Real-time Examples](./docs/socket/REALTIME_EXAMPLES.md) - Socket implementation examples

### 🎨 Frontend Integration
- [Frontend API Documentation](./docs/frontend/FRONTEND_API_DOCUMENTATION.md) - Complete API reference for frontend
- [Frontend Integration Guide](./docs/frontend/FRONTEND_INTEGRATION_GUIDE.md) - Framework-specific integration examples
- [Frontend Setup Guide](./docs/frontend/FRONTEND_DOCS_SETUP_GUIDE.md) - 5-minute setup for frontend teams
- [API Quick Reference](./docs/frontend/API_QUICK_REFERENCE.md) - Cheat sheet for common operations
- [Multi-Repository Integration](./docs/frontend/MULTI_REPOSITORY_INTEGRATION.md) - Working with separate repositories

### 💡 Guides & Resources
- [Getting Started](./guides/GETTING_STARTED.md) - New user guide
- [Troubleshooting](./guides/TROUBLESHOOTING.md) - Common issues and solutions
- [Best Practices](./guides/BEST_PRACTICES.md) - Development best practices
- [Documentation Deployment](./guides/DOCS_DEPLOYMENT_GUIDE.md) - How to deploy and sync documentation

### 🧩 Code Examples
- [Backend Examples](./examples/backend-examples/) - Backend implementation examples
- [Socket Examples](./examples/socket-examples/) - WebSocket and socket.io examples
- [Frontend Examples](./examples/frontend-examples/) - Frontend integration examples

## 🚀 Quick Start

### For Frontend Developers
1. Read the [Frontend Setup Guide](./docs/frontend/FRONTEND_DOCS_SETUP_GUIDE.md) (5 minutes)
2. Check the [API Quick Reference](./docs/frontend/API_QUICK_REFERENCE.md) for common operations
3. Follow the [Integration Guide](./docs/frontend/FRONTEND_INTEGRATION_GUIDE.md) for your framework

### For Backend Developers
1. Review the [Backend API Documentation](./docs/backend/API_DOCUMENTATION.md)
2. Follow the [Environment Setup](./docs/backend/ENVIRONMENT_SETUP.md)
3. Check the [Deployment Guide](./docs/backend/DEPLOYMENT_GUIDE.md)

### For Full-stack Developers
1. Start with [Getting Started](./guides/GETTING_STARTED.md)
2. Review [Multi-Repository Integration](./docs/frontend/MULTI_REPOSITORY_INTEGRATION.md)
3. Check [Best Practices](./guides/BEST_PRACTICES.md)

## 🌐 Live Documentation

Visit our live documentation site: https://docs.codejoin.com

## 🤝 Contributing

To contribute to documentation:

1. Make changes in the appropriate repository (backend, socket, etc.)
2. Sync changes to this documentation repository
3. Submit a pull request with clear description of changes
4. Documentation will be automatically deployed

## 📞 Support

- Create an issue in this repository
- Join our developer Discord
- Email: support@codejoin.com

---

*Last updated: January 2024*
*Documentation Version: 1.0.0*
EOF

# Create placeholder content for missing files
echo "📝 Adding placeholder content..."

# Backend placeholders
cat > "$DOCS_REPO_PATH/docs/backend/API_DOCUMENTATION.md" << 'EOF'
# Backend API Documentation

## Overview

This section contains the complete API documentation for CodeJoin backend services.

## Endpoints

Coming soon...

## Authentication

Details about backend authentication...

## Rate Limiting

Information about rate limiting...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/docs/backend/DEPLOYMENT_GUIDE.md" << 'EOF'
# Backend Deployment Guide

## Overview

This guide explains how to deploy CodeJoin backend services.

## Deployment Options

- Railway
- Render
- Docker
- AWS

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/docs/backend/ENVIRONMENT_SETUP.md" << 'EOF'
# Backend Environment Setup

## Required Environment Variables

```env
NODE_ENV=production
PORT=3001
API_KEY=your_api_key
```

## Optional Environment Variables

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

# Socket placeholders
cat > "$DOCS_REPO_PATH/docs/socket/SOCKET_API_DOCUMENTATION.md" << 'EOF'
# Socket API Documentation

## Overview

This section contains documentation for CodeJoin socket services and WebSocket implementation.

## Socket Events

Coming soon...

## WebSocket Connection

Details about connecting to WebSocket...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/docs/socket/WEBSOCKET_GUIDE.md" << 'EOF'
# WebSocket Guide

## Overview

This guide explains how to implement WebSocket connections with CodeJoin services.

## Connection Examples

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/docs/socket/REALTIME_EXAMPLES.md" << 'EOF'
# Real-time Examples

## Overview

This section contains real-time implementation examples using CodeJoin socket services.

## Examples

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

# Guide placeholders
cat > "$DOCS_REPO_PATH/guides/GETTING_STARTED.md" << 'EOF'
# Getting Started

## Overview

Welcome to CodeJoin! This guide will help you get started with our services.

## Prerequisites

- Node.js 18+
- Code editor
- API keys

## Quick Start

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/guides/TROUBLESHOOTING.md" << 'EOF'
# Troubleshooting

## Common Issues

### Connection Issues

Coming soon...

### Authentication Problems

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

cat > "$DOCS_REPO_PATH/guides/BEST_PRACTICES.md" << 'EOF'
# Best Practices

## Overview

This guide covers best practices for working with CodeJoin services.

## Backend Best Practices

Coming soon...

## Frontend Best Practices

Coming soon...

---

*This documentation is being updated. Please check back soon.*
EOF

# Go to docs repository and commit changes
cd "$DOCS_REPO_PATH"

echo "📝 Committing organized documentation..."
git add .
git commit -m "📚 Organize documentation structure

- Add organized folder structure for backend, socket, and frontend docs
- Move frontend documentation to dedicated frontend folder
- Create placeholder files for backend and socket documentation
- Add comprehensive main README.md
- Add placeholder content for upcoming documentation

Structure:
- docs/backend/ - Backend API and deployment docs
- docs/socket/ - WebSocket and socket.io docs  
- docs/frontend/ - Frontend integration guides
- guides/ - General guides and resources
- examples/ - Code examples (ready for future content)"

echo "🚀 Pushing to GitHub..."
git push origin main

# Return to backend repository
cd "$BACKEND_REPO_PATH"
echo "✅ Documentation structure organized successfully!"
echo ""
echo "📚 Your documentation is now organized at:"
echo "   https://github.com/jerewy/codejoin-docs"
echo ""
echo "📁 Structure created:"
echo "   docs/backend/ - Backend documentation"
echo "   docs/socket/ - Socket documentation"  
echo "   docs/frontend/ - Frontend documentation"
echo "   guides/ - General guides"
echo "   examples/ - Code examples"
echo ""
echo "🎯 Next steps:"
echo "   1. Add backend-specific documentation to docs/backend/"
echo "   2. Add socket-specific documentation to docs/socket/"
echo "   3. Share the organized docs with your teams"