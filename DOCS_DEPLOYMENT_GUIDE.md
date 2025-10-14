# Documentation Deployment Guide

## Overview

This guide explains how to move the documentation from the backend repository to a dedicated `codejoin-docs` repository and keep them synchronized.

## Step 1: Create the Documentation Repository

### 1.1 Create New Repository

```bash
# Create the new documentation repository
gh repo create codejoin-docs --public --clone
cd codejoin-docs

# Or create manually on GitHub and clone:
git clone https://github.com/your-org/codejoin-docs.git
cd codejoin-docs
```

### 1.2 Set Up Repository Structure

```bash
# Create directory structure
mkdir -p api/frontend
mkdir -p api/backend
mkdir -p examples
mkdir -p .github/workflows

# Create README
touch README.md
```

## Step 2: Move Documentation Files

### 2.1 Copy Files from Backend Repository

From your backend repository (`codejoin-backend`), run:

```bash
# Method 1: Using cp command
cp FRONTEND_API_DOCUMENTATION.md ../codejoin-docs/api/frontend/
cp FRONTEND_INTEGRATION_GUIDE.md ../codejoin-docs/api/frontend/
cp API_QUICK_REFERENCE.md ../codejoin-docs/api/frontend/
cp FRONTEND_DOCS_SETUP_GUIDE.md ../codejoin-docs/api/frontend/
cp README_FOR_FRONTEND_TEAMS.md ../codejoin-docs/
cp MULTI_REPOSITORY_INTEGRATION.md ../codejoin-docs/api/frontend/

# Method 2: Using git (preserves history)
git checkout --orphan docs-branch
git filter-branch --subdirectory-filter . --prune-empty --tag-name-filter cat -- -- docs/
git push origin docs-branch:main
```

### 2.2 Create Main README in Docs Repository

Create `README.md` in the `codejoin-docs` repository:

```markdown
# CodeJoin Documentation

Central documentation repository for CodeJoin frontend and backend APIs.

## 📚 Documentation Structure

### Frontend API Documentation

- [📖 Complete API Documentation](./api/frontend/FRONTEND_API_DOCUMENTATION.md)
- [🔧 Integration Guide](./api/frontend/FRONTEND_INTEGRATION_GUIDE.md)
- [⚡ Quick Setup Guide](./api/frontend/FRONTEND_DOCS_SETUP_GUIDE.md)
- [📋 Quick Reference](./api/frontend/API_QUICK_REFERENCE.md)
- [🔄 Multi-Repository Setup](./api/frontend/MULTI_REPOSITORY_INTEGRATION.md)

### Backend Documentation

- Backend API docs (coming soon)

### Examples

- [React Examples](./examples/react/)
- [Vue.js Examples](./examples/vue/)
- [Angular Examples](./examples/angular/)

## 🚀 Quick Start for Frontend Teams

1. **Read the [Setup Guide](./api/frontend/FRONTEND_DOCS_SETUP_GUIDE.md)** (5 minutes)
2. **Configure your environment** with API URL and key
3. **Install dependencies**: `npm install axios socket.io-client`
4. **Test your connection** using provided examples

## 🌐 Live Documentation

View the live documentation at: https://docs.codejoin.com

## 🤝 Contributing

To update documentation:

1. Make changes in this repository
2. Submit a pull request
3. Documentation will be automatically deployed

---

_Last updated: January 2024_
```

## Step 3: Set Up Automated Syncing

### 3.1 Create Sync Script

Create `scripts/sync-docs.sh` in the backend repository:

```bash
#!/bin/bash

# Script to sync documentation to codejoin-docs repository

BACKEND_REPO_PATH="$(pwd)"
DOCS_REPO_PATH="../codejoin-docs"

echo "🚀 Starting documentation sync..."

# Check if docs repository exists
if [ ! -d "$DOCS_REPO_PATH" ]; then
    echo "❌ Docs repository not found at $DOCS_REPO_PATH"
    echo "Please clone the repository first:"
    echo "git clone https://github.com/your-org/codejoin-docs.git ../codejoin-docs"
    exit 1
fi

# Define files to sync
FILES_TO_SYNC=(
    "FRONTEND_API_DOCUMENTATION.md:api/frontend/"
    "FRONTEND_INTEGRATION_GUIDE.md:api/frontend/"
    "API_QUICK_REFERENCE.md:api/frontend/"
    "FRONTEND_DOCS_SETUP_GUIDE.md:api/frontend/"
    "README_FOR_FRONTEND_TEAMS.md:/"
    "MULTI_REPOSITORY_INTEGRATION.md:api/frontend/"
)

# Sync files
for file_mapping in "${FILES_TO_SYNC[@]}"; do
    IFS=':' read -r source_file target_dir <<< "$file_mapping"

    source_path="$BACKEND_REPO_PATH/$source_file"
    target_path="$DOCS_REPO_PATH/$target_dir$source_file"

    if [ -f "$source_path" ]; then
        echo "📄 Copying $source_file to $target_dir"
        cp "$source_path" "$target_path"
    else
        echo "⚠️  Warning: $source_file not found"
    fi
done

# Commit changes in docs repository
cd "$DOCS_REPO_PATH"

# Check if there are changes to commit
if ! git diff --quiet; then
    echo "📝 Committing changes to docs repository..."
    git add .
    git commit -m "📚 Auto-sync documentation from backend repository
    - Synced from $(date)
    - Source: codejoin-backend"

    # Push changes
    git push origin main
    echo "✅ Documentation synced and pushed successfully!"
else
    echo "ℹ️  No changes to commit"
fi

# Return to backend repository
cd "$BACKEND_REPO_PATH"
echo "🎉 Documentation sync complete!"
```

### 3.2 Make Script Executable

```bash
chmod +x scripts/sync-docs.sh
```

### 3.3 Create GitHub Action for Auto-Sync

Create `.github/workflows/sync-docs.yml` in the backend repository:

```yaml
name: Sync Documentation

on:
  push:
    paths:
      - "FRONTEND_*.md"
      - "README_FOR_FRONTEND_TEAMS.md"
      - "MULTI_REPOSITORY_INTEGRATION.md"
    branches: [main, develop]
  workflow_dispatch:

jobs:
  sync-docs:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Backend Repository
        uses: actions/checkout@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup Git
        run: |
          git config --global user.name "Documentation Bot"
          git config --global user.email "docs@codejoin.com"

      - name: Checkout Docs Repository
        uses: actions/checkout@v3
        with:
          repository: your-org/codejoin-docs
          token: ${{ secrets.DOCS_REPO_TOKEN }}
          path: docs-repo

      - name: Sync Documentation Files
        run: |
          # List of files to sync
          FILES_TO_SYNC=(
            "FRONTEND_API_DOCUMENTATION.md:api/frontend/"
            "FRONTEND_INTEGRATION_GUIDE.md:api/frontend/"
            "API_QUICK_REFERENCE.md:api/frontend/"
            "FRONTEND_DOCS_SETUP_GUIDE.md:api/frontend/"
            "README_FOR_FRONTEND_TEAMS.md:/"
            "MULTI_REPOSITORY_INTEGRATION.md:api/frontend/"
          )

          # Sync each file
          for file_mapping in "${FILES_TO_SYNC[@]}"; do
            IFS=':' read -r source_file target_dir <<< "$file_mapping"
            
            if [ -f "$source_file" ]; then
              echo "📄 Copying $source_file to $target_dir"
              mkdir -p "docs-repo/$target_dir"
              cp "$source_file" "docs-repo/$target_dir$source_file"
            fi
          done

      - name: Commit and Push Changes
        run: |
          cd docs-repo

          if ! git diff --quiet; then
            git add .
            git commit -m "📚 Auto-sync documentation from backend repository
            
            - Synced from commit: ${{ github.sha }}
            - Triggered by: ${{ github.actor }}
            - Timestamp: $(date -u)"
            
            git push origin main
            echo "✅ Documentation synced successfully!"
          else
            echo "ℹ️  No changes to commit"
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.DOCS_REPO_TOKEN }}
```

### 3.4 Set Up Repository Secret

1. Go to your backend repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Add a new secret:
   - Name: `DOCS_REPO_TOKEN`
   - Value: Personal Access Token with `repo` scope

## Step 4: Set Up Documentation Website

### 4.1 Deploy with Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# In the codejoin-docs repository
vercel --prod
```

Create `vercel.json` in the docs repository:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "*.md",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/",
      "dest": "/README.md"
    },
    {
      "src": "/api/(.*)",
      "dest": "/api/frontend/$1"
    }
  ]
}
```

### 4.2 Deploy with GitHub Pages

Create `.github/workflows/deploy-docs.yml` in the docs repository:

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Build Documentation
        run: |
          # If using a static site generator
          npm install
          npm run build

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
```

## Step 5: Manual Sync Process

### 5.1 Sync Individual Files

```bash
# From backend repository
cp FRONTEND_API_DOCUMENTATION.md ../codejoin-docs/api/frontend/
cd ../codejoin-docs
git add api/frontend/FRONTEND_API_DOCUMENTATION.md
git commit -m "Update API documentation"
git push origin main
```

### 5.2 Sync All Documentation

```bash
# From backend repository
./scripts/sync-docs.sh
```

### 5.3 Pull Latest Documentation

```bash
# In frontend repository
git submodule add https://github.com/your-org/codejoin-docs.git docs
git submodule update --init --recursive
```

## Step 6: Update Backend Repository

### 6.1 Add Reference to Docs Repository

Update the main README.md in the backend repository:

```markdown
## 📚 Documentation

**Frontend documentation has moved to:** https://github.com/your-org/codejoin-docs

### Quick Links

- 📖 [API Documentation](https://github.com/your-org/codejoin-docs/blob/main/api/frontend/FRONTEND_API_DOCUMENTATION.md)
- 🔧 [Integration Guide](https://github.com/your-org/codejoin-docs/blob/main/api/frontend/FRONTEND_INTEGRATION_GUIDE.md)
- ⚡ [Setup Guide](https://github.com/your-org/codejoin-docs/blob/main/api/frontend/FRONTEND_DOCS_SETUP_GUIDE.md)
- 📋 [Quick Reference](https://github.com/your-org/codejoin-docs/blob/main/api/frontend/API_QUICK_REFERENCE.md)

### Live Documentation

View the live documentation at: https://docs.codejoin.com
```

### 6.2 Add Deprecation Notice

Add a notice at the top of each documentation file in the backend:

```markdown
> ⚠️ **This documentation has moved!**
>
> Please visit [codejoin-docs](https://github.com/your-org/codejoin-docs) for the latest documentation.
>
> This file will be removed in a future version.

---
```

## Step 7: Automate Updates

### 7.1 Set Up Webhook (Optional)

Create a webhook to automatically update documentation when changes are made:

```javascript
// scripts/webhook.js
const express = require("express");
const { execSync } = require("child_process");

const app = express();
app.use(express.json());

app.post("/sync-docs", (req, res) => {
  const { repository, ref } = req.body;

  if (repository.name === "codejoin-backend" && ref === "refs/heads/main") {
    try {
      execSync("./scripts/sync-docs.sh", { stdio: "inherit" });
      res.json({ status: "success", message: "Documentation synced" });
    } catch (error) {
      res.status(500).json({ status: "error", message: error.message });
    }
  } else {
    res.json({ status: "ignored" });
  }
});

app.listen(3000, () => {
  console.log("Webhook server running on port 3000");
});
```

## Step 8: Testing the Setup

### 8.1 Test Manual Sync

```bash
# Test the sync script
./scripts/sync-docs.sh

# Verify files were copied
ls -la ../codejoin-docs/api/frontend/
```

### 8.2 Test GitHub Actions

1. Make a small change to a documentation file
2. Commit and push to main branch
3. Check the Actions tab to see if the sync runs
4. Verify the changes appear in the docs repository

### 8.3 Test Documentation Website

1. Deploy the docs repository
2. Visit the deployed URL
3. Verify all documentation is accessible
4. Test links and navigation

## Maintenance

### Regular Tasks

1. **Monthly**: Review and update documentation
2. **Quarterly**: Check for broken links and outdated information
3. **As needed**: Sync when API changes are made

### Monitoring

Set up monitoring to ensure:

- Documentation website is accessible
- Links are working
- Sync process is functioning
- No sensitive information is exposed

---

## 🎉 Success!

Your documentation is now:

- ✅ Centralized in a dedicated repository
- ✅ Automatically synced from backend changes
- ✅ Deployed as a live website
- ✅ Easily accessible to frontend teams
- ✅ Version controlled and maintained

Frontend teams can now reference the documentation at:

- GitHub: https://github.com/your-org/codejoin-docs
- Live Site: https://docs.codejoin.com
