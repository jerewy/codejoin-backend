# Push Documentation to codejoin-docs Repository

## Quick Manual Steps

### Step 1: Clone your docs repository (if not already done)

```bash
# Go to your parent directory (one level up from backend)
cd ..

# Clone the docs repository
git clone https://github.com/jerewy/codejoin-docs.git

# Go back to your backend repository
cd codejoin-backend
```

### Step 2: Copy the documentation files

```bash
# Copy all documentation files to the docs repository
cp FRONTEND_API_DOCUMENTATION.md ../codejoin-docs/
cp FRONTEND_INTEGRATION_GUIDE.md ../codejoin-docs/
cp API_QUICK_REFERENCE.md ../codejoin-docs/
cp FRONTEND_DOCS_SETUP_GUIDE.md ../codejoin-docs/
cp README_FOR_FRONTEND_TEAMS.md ../codejoin-docs/
cp MULTI_REPOSITORY_INTEGRATION.md ../codejoin-docs/
cp DOCS_DEPLOYMENT_GUIDE.md ../codejoin-docs/
```

### Step 3: Go to docs repository and commit

```bash
# Navigate to docs repository
cd ../codejoin-docs

# Check git status
git status

# Add all files
git add .

# Commit the files
git commit -m "Add frontend API documentation

- Added complete API documentation for frontend teams
- Includes setup guides, integration examples, and quick reference
- Supports React, Vue, Angular, and vanilla JavaScript
- Added deployment guide for multi-repository setups"

# Push to GitHub
git push origin main
```

## Alternative: One-Command Method

If you want to do it from your current backend directory:

```bash
# Method 1: Using absolute paths
cp FRONTEND_API_DOCUMENTATION.md ~/codejoin-docs/  # Adjust path as needed
cp FRONTEND_INTEGRATION_GUIDE.md ~/codejoin-docs/
cp API_QUICK_REFERENCE.md ~/codejoin-docs/
cp FRONTEND_DOCS_SETUP_GUIDE.md ~/codejoin-docs/
cp README_FOR_FRONTEND_TEAMS.md ~/codejoin-docs/
cp MULTI_REPOSITORY_INTEGRATION.md ~/codejoin-docs/
cp DOCS_DEPLOYMENT_GUIDE.md ~/codejoin-docs/

# Then go to docs repo and push
cd ~/codejoin-docs
git add .
git commit -m "Add frontend API documentation"
git push origin main
```

## What These Files Are:

- **FRONTEND_API_DOCUMENTATION.md** - Complete API reference
- **FRONTEND_INTEGRATION_GUIDE.md** - Detailed implementation examples
- **API_QUICK_REFERENCE.md** - Cheat sheet for common operations
- **FRONTEND_DOCS_SETUP_GUIDE.md** - 5-minute setup guide
- **README_FOR_FRONTEND_TEAMS.md** - Main entry point for frontend teams
- **MULTI_REPOSITORY_INTEGRATION.md** - Guide for working with separate repos
- **DOCS_DEPLOYMENT_GUIDE.md** - How to deploy and sync documentation

## After Pushing

Once you've pushed the files:

1. **Check the repository**: https://github.com/jerewy/codejoin-docs
2. **Create a README.md** in the docs repo if it doesn't exist
3. **Share the link** with frontend teams: https://github.com/jerewy/codejoin-docs

## For Future Updates

When you update documentation in the backend repo, just repeat the copy and push steps:

```bash
# From backend repo
cp UPDATED_FILE.md ../codejoin-docs/

# From docs repo
cd ../codejoin-docs
git add UPDATED_FILE.md
git commit -m "Update documentation"
git push origin main
```

## Optional: Set Up Automatic Syncing

If you want to automate this in the future, you can use the GitHub Action I created earlier. But for now, the manual method is the simplest way to get your documentation uploaded.
