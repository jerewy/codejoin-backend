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
    "DOCS_DEPLOYMENT_GUIDE.md:/"
)

# Sync files
for file_mapping in "${FILES_TO_SYNC[@]}"; do
    IFS=':' read -r source_file target_dir <<< "$file_mapping"
    
    source_path="$BACKEND_REPO_PATH/$source_file"
    target_path="$DOCS_REPO_PATH/$target_dir$source_file"
    
    if [ -f "$source_path" ]; then
        echo "📄 Copying $source_file to $target_dir"
        mkdir -p "$DOCS_REPO_PATH/$target_dir"
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