@echo off
REM Script to set up organized documentation structure in codejoin-docs repository (Windows version)

set BACKEND_REPO_PATH=%CD%
set DOCS_REPO_PATH=..\codejoin-docs

echo 🚀 Setting up organized documentation structure...

REM Check if docs repository exists
if not exist "%DOCS_REPO_PATH%" (
    echo ❌ Docs repository not found at %DOCS_REPO_PATH%
    echo Please clone the repository first:
    echo git clone https://github.com/jerewy/codejoin-docs.git ../codejoin-docs
    pause
    exit /b 1
)

REM Create directory structure
echo 📁 Creating directory structure...
if not exist "%DOCS_REPO_PATH%\docs\backend" mkdir "%DOCS_REPO_PATH%\docs\backend"
if not exist "%DOCS_REPO_PATH%\docs\socket" mkdir "%DOCS_REPO_PATH%\docs\socket"
if not exist "%DOCS_REPO_PATH%\docs\frontend" mkdir "%DOCS_REPO_PATH%\docs\frontend"
if not exist "%DOCS_REPO_PATH%\examples\backend-examples" mkdir "%DOCS_REPO_PATH%\examples\backend-examples"
if not exist "%DOCS_REPO_PATH%\examples\socket-examples" mkdir "%DOCS_REPO_PATH%\examples\socket-examples"
if not exist "%DOCS_REPO_PATH%\examples\frontend-examples" mkdir "%DOCS_REPO_PATH%\examples\frontend-examples"
if not exist "%DOCS_REPO_PATH%\guides" mkdir "%DOCS_REPO_PATH%\guides"

REM Copy frontend documentation files
echo 📄 Copying frontend documentation...
copy "%BACKEND_REPO_PATH%\FRONTEND_API_DOCUMENTATION.md" "%DOCS_REPO_PATH%\docs\frontend\"
copy "%BACKEND_REPO_PATH%\FRONTEND_INTEGRATION_GUIDE.md" "%DOCS_REPO_PATH%\docs\frontend\"
copy "%BACKEND_REPO_PATH%\API_QUICK_REFERENCE.md" "%DOCS_REPO_PATH%\docs\frontend\"
copy "%BACKEND_REPO_PATH%\FRONTEND_DOCS_SETUP_GUIDE.md" "%DOCS_REPO_PATH%\docs\frontend\"
copy "%BACKEND_REPO_PATH%\README_FOR_FRONTEND_TEAMS.md" "%DOCS_REPO_PATH%\docs\frontend\README.md"
copy "%BACKEND_REPO_PATH%\MULTI_REPOSITORY_INTEGRATION.md" "%DOCS_REPO_PATH%\docs\frontend\"

REM Copy guides
echo 📋 Copying guides...
copy "%BACKEND_REPO_PATH%\DOCS_DEPLOYMENT_GUIDE.md" "%DOCS_REPO_PATH%\guides\"

REM Create placeholder files for missing documentation
echo 📝 Creating placeholder files...
echo. > "%DOCS_REPO_PATH%\docs\backend\API_DOCUMENTATION.md"
echo. > "%DOCS_REPO_PATH%\docs\backend\DEPLOYMENT_GUIDE.md"
echo. > "%DOCS_REPO_PATH%\docs\backend\ENVIRONMENT_SETUP.md"

echo. > "%DOCS_REPO_PATH%\docs\socket\SOCKET_API_DOCUMENTATION.md"
echo. > "%DOCS_REPO_PATH%\docs\socket\WEBSOCKET_GUIDE.md"
echo. > "%DOCS_REPO_PATH%\docs\socket\REALTIME_EXAMPLES.md"

echo. > "%DOCS_REPO_PATH%\guides\GETTING_STARTED.md"
echo. > "%DOCS_REPO_PATH%\guides\TROUBLESHOOTING.md"
echo. > "%DOCS_REPO_PATH%\guides\BEST_PRACTICES.md"

echo 📖 Creating main README.md...
(
echo # CodeJoin Documentation
echo.
echo Welcome to the CodeJoin documentation hub! This repository contains comprehensive documentation for all CodeJoin services.
echo.
echo ## 📚 Documentation Structure
echo.
echo ### 🔧 Backend Services
echo - [Backend API Documentation]^./docs/backend/API_DOCUMENTATION.md^ - Core backend API reference
echo - [Backend Deployment Guide]^./docs/backend/DEPLOYMENT_GUIDE.md^ - How to deploy backend services
echo - [Environment Setup]^./docs/backend/ENVIRONMENT_SETUP.md^ - Backend environment configuration
echo.
echo ### 🔌 Socket Services
echo - [Socket API Documentation]^./docs/socket/SOCKET_API_DOCUMENTATION.md^ - WebSocket and socket.io reference
echo - [WebSocket Guide]^./docs/socket/WEBSOCKET_GUIDE.md^ - Real-time communication guide
echo - [Real-time Examples]^./docs/socket/REALTIME_EXAMPLES.md^ - Socket implementation examples
echo.
echo ### 🎨 Frontend Integration
echo - [Frontend API Documentation]^./docs/frontend/FRONTEND_API_DOCUMENTATION.md^ - Complete API reference for frontend
echo - [Frontend Integration Guide]^./docs/frontend/FRONTEND_INTEGRATION_GUIDE.md^ - Framework-specific integration examples
echo - [Frontend Setup Guide]^./docs/frontend/FRONTEND_DOCS_SETUP_GUIDE.md^ - 5-minute setup for frontend teams
echo - [API Quick Reference]^./docs/frontend/API_QUICK_REFERENCE.md^ - Cheat sheet for common operations
echo - [Multi-Repository Integration]^./docs/frontend/MULTI_REPOSITORY_INTEGRATION.md^ - Working with separate repositories
echo.
echo ### 💡 Guides ^& Resources
echo - [Getting Started]^./guides/GETTING_STARTED.md^ - New user guide
echo - [Troubleshooting]^./guides/TROUBLESHOOTING.md^ - Common issues and solutions
echo - [Best Practices]^./guides/BEST_PRACTICES.md^ - Development best practices
echo - [Documentation Deployment]^./guides/DOCS_DEPLOYMENT_GUIDE.md^ - How to deploy and sync documentation
echo.
echo ### 🧩 Code Examples
echo - [Backend Examples]^./examples/backend-examples/^ - Backend implementation examples
echo - [Socket Examples]^./examples/socket-examples/^ - WebSocket and socket.io examples
echo - [Frontend Examples]^./examples/frontend-examples/^ - Frontend integration examples
echo.
echo ## 🚀 Quick Start
echo.
echo ### For Frontend Developers
echo 1. Read the [Frontend Setup Guide]^./docs/frontend/FRONTEND_DOCS_SETUP_GUIDE.md^ ^5 minutes^
echo 2. Check the [API Quick Reference]^./docs/frontend/API_QUICK_REFERENCE.md^ for common operations
echo 3. Follow the [Integration Guide]^./docs/frontend/FRONTEND_INTEGRATION_GUIDE.md^ for your framework
echo.
echo ### For Backend Developers
echo 1. Review the [Backend API Documentation]^./docs/backend/API_DOCUMENTATION.md^
echo 2. Follow the [Environment Setup]^./docs/backend/ENVIRONMENT_SETUP.md^
echo 3. Check the [Deployment Guide]^./docs/backend/DEPLOYMENT_GUIDE.md^
echo.
echo ### For Full-stack Developers
echo 1. Start with [Getting Started]^./guides/GETTING_STARTED.md^
echo 2. Review [Multi-Repository Integration]^./docs/frontend/MULTI_REPOSITORY_INTEGRATION.md^
echo 3. Check [Best Practices]^./guides/BEST_PRACTICES.md^
echo.
echo ## 🌐 Live Documentation
echo.
echo Visit our live documentation site: https://docs.codejoin.com
echo.
echo ## 🤝 Contributing
echo.
echo To contribute to documentation:
echo.
echo 1. Make changes in the appropriate repository ^backend, socket, etc.^
echo 2. Sync changes to this documentation repository
echo 3. Submit a pull request with clear description of changes
echo 4. Documentation will be automatically deployed
echo.
echo ## 📞 Support
echo.
echo - Create an issue in this repository
echo - Join our developer Discord
echo - Email: support@codejoin.com
echo.
echo ---
echo.
echo *Last updated: January 2024*
echo *Documentation Version: 1.0.0*
) > "%DOCS_REPO_PATH%\README.md"

REM Create placeholder content for missing files
echo 📝 Adding placeholder content...

REM Backend placeholders
(
echo # Backend API Documentation
echo.
echo ## Overview
echo.
echo This section contains the complete API documentation for CodeJoin backend services.
echo.
echo ## Endpoints
echo.
echo Coming soon...
echo.
echo ## Authentication
echo.
echo Details about backend authentication...
echo.
echo ## Rate Limiting
echo.
echo Information about rate limiting...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\backend\API_DOCUMENTATION.md"

(
echo # Backend Deployment Guide
echo.
echo ## Overview
echo.
echo This guide explains how to deploy CodeJoin backend services.
echo.
echo ## Deployment Options
echo.
echo - Railway
echo - Render
echo - Docker
echo - AWS
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\backend\DEPLOYMENT_GUIDE.md"

(
echo # Backend Environment Setup
echo.
echo ## Required Environment Variables
echo.
echo ```env
echo NODE_ENV=production
echo PORT=3001
echo API_KEY=your_api_key
echo ```
echo.
echo ## Optional Environment Variables
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\backend\ENVIRONMENT_SETUP.md"

REM Socket placeholders
(
echo # Socket API Documentation
echo.
echo ## Overview
echo.
echo This section contains documentation for CodeJoin socket services and WebSocket implementation.
echo.
echo ## Socket Events
echo.
echo Coming soon...
echo.
echo ## WebSocket Connection
echo.
echo Details about connecting to WebSocket...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\socket\SOCKET_API_DOCUMENTATION.md"

(
echo # WebSocket Guide
echo.
echo ## Overview
echo.
echo This guide explains how to implement WebSocket connections with CodeJoin services.
echo.
echo ## Connection Examples
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\socket\WEBSOCKET_GUIDE.md"

(
echo # Real-time Examples
echo.
echo ## Overview
echo.
echo This section contains real-time implementation examples using CodeJoin socket services.
echo.
echo ## Examples
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\docs\socket\REALTIME_EXAMPLES.md"

REM Guide placeholders
(
echo # Getting Started
echo.
echo ## Overview
echo.
echo Welcome to CodeJoin! This guide will help you get started with our services.
echo.
echo ## Prerequisites
echo.
echo - Node.js 18+
echo - Code editor
echo - API keys
echo.
echo ## Quick Start
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\guides\GETTING_STARTED.md"

(
echo # Troubleshooting
echo.
echo ## Common Issues
echo.
echo ### Connection Issues
echo.
echo Coming soon...
echo.
echo ### Authentication Problems
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\guides\TROUBLESHOOTING.md"

(
echo # Best Practices
echo.
echo ## Overview
echo.
echo This guide covers best practices for working with CodeJoin services.
echo.
echo ## Backend Best Practices
echo.
echo Coming soon...
echo.
echo ## Frontend Best Practices
echo.
echo Coming soon...
echo.
echo ---
echo.
echo *This documentation is being updated. Please check back soon.*
) > "%DOCS_REPO_PATH%\guides\BEST_PRACTICES.md"

REM Go to docs repository and commit changes
cd /d "%DOCS_REPO_PATH%"

echo 📝 Committing organized documentation...
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

echo 🚀 Pushing to GitHub...
git push origin main

REM Return to backend repository
cd /d "%BACKEND_REPO_PATH%"
echo ✅ Documentation structure organized successfully!
echo.
echo 📚 Your documentation is now organized at:
echo    https://github.com/jerewy/codejoin-docs
echo.
echo 📁 Structure created:
echo    docs/backend/ - Backend documentation
echo    docs/socket/ - Socket documentation  
echo    docs/frontend/ - Frontend documentation
echo    guides/ - General guides
echo    examples/ - Code examples
echo.
echo 🎯 Next steps:
echo    1. Add backend-specific documentation to docs/backend/
echo    2. Add socket-specific documentation to docs/socket/
echo    3. Share the organized docs with your teams
echo.
pause