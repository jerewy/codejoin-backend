# Windows Setup Instructions

## Quick Setup for Windows Users

Since you're on Windows, you have several options to set up the organized documentation. Choose the one that works best for you.

## Option 1: Use the Windows Batch File (Recommended)

### Step 1: Clone your docs repository

Open Command Prompt (cmd) or PowerShell and run:

```cmd
# Go to your parent directory (one level up from backend)
cd ..

# Clone your docs repository
git clone https://github.com/jerewy/codejoin-docs.git

# Go back to your backend repository
cd codejoin-backend
```

### Step 2: Run the Windows batch script

From your backend repository directory (`codejoin-backend`), run:

```cmd
# Using Command Prompt (cmd)
scripts\setup-organized-docs.bat

# OR using PowerShell
.\scripts\setup-organized-docs.bat
```

That's it! The script will:

- Create the organized folder structure
- Copy all documentation files to the right places
- Create placeholder files for missing documentation
- Generate a comprehensive README.md
- Commit and push everything to GitHub

## Option 2: Manual Setup (If scripts don't work)

### Step 1: Clone the docs repository

```cmd
cd ..
git clone https://github.com/jerewy/codejoin-docs.git
cd codejoin-backend
```

### Step 2: Create the directory structure

```cmd
mkdir ..\codejoin-docs\docs\backend
mkdir ..\codejoin-docs\docs\socket
mkdir ..\codejoin-docs\docs\frontend
mkdir ..\codejoin-docs\examples\backend-examples
mkdir ..\codejoin-docs\examples\socket-examples
mkdir ..\codejoin-docs\examples\frontend-examples
mkdir ..\codejoin-docs\guides
```

### Step 3: Copy frontend documentation files

```cmd
copy FRONTEND_API_DOCUMENTATION.md ..\codejoin-docs\docs\frontend\
copy FRONTEND_INTEGRATION_GUIDE.md ..\codejoin-docs\docs\frontend\
copy API_QUICK_REFERENCE.md ..\codejoin-docs\docs\frontend\
copy FRONTEND_DOCS_SETUP_GUIDE.md ..\codejoin-docs\docs\frontend\
copy README_FOR_FRONTEND_TEAMS.md ..\codejoin-docs\docs\frontend\README.md
copy MULTI_REPOSITORY_INTEGRATION.md ..\codejoin-docs\docs\frontend\
copy DOCS_DEPLOYMENT_GUIDE.md ..\codejoin-docs\guides\
```

### Step 4: Go to docs repository and commit

```cmd
cd ..\codejoin-docs
git add .
git commit -m "Add organized documentation structure"
git push origin main
```

## Option 3: Use Git Bash (If you have Git installed)

If you have Git for Windows installed, you can use Git Bash:

```bash
# Make the shell script executable and run it
chmod +x scripts/setup-organized-docs.sh
./scripts/setup-organized-docs.sh
```

## Option 4: Use VS Code Terminal

1. Open VS Code
2. Open your backend repository
3. Open the terminal (Ctrl + `)
4. Run the batch file:

```cmd
.\scripts\setup-organized-docs.bat
```

## Troubleshooting

### "Command not found" error

- Make sure you're in the correct directory (`codejoin-backend`)
- Check that the batch file exists in the `scripts` folder

### "Permission denied" error

- Right-click on Command Prompt and "Run as administrator"
- Or run PowerShell as administrator

### Git not found

- Install Git for Windows from https://git-scm.com/download/win
- Restart your command prompt after installation

### Script doesn't run

- Try running it from different locations:
  - Command Prompt (cmd)
  - PowerShell
  - Git Bash
  - VS Code terminal

## What You'll Get

After running the setup, your `codejoin-docs` repository will have this structure:

```
codejoin-docs/
├── README.md                           # Main overview
├── docs/
│   ├── backend/                        # Backend API docs
│   ├── socket/                         # Socket/WebSocket docs
│   └── frontend/                       # Frontend integration guides
├── examples/                           # Code examples
└── guides/                             # General guides
```

## Verification

1. Check the repository: https://github.com/jerewy/codejoin-docs
2. You should see the organized folder structure
3. Frontend documentation will be in `docs/frontend/`
4. Placeholder files will be ready for backend and socket docs

## Next Steps

1. Run the setup script
2. Verify the organization on GitHub
3. Share the link with your teams: https://github.com/jerewy/codejoin-docs
4. Add backend-specific docs to `docs/backend/`
5. Add socket-specific docs to `docs/socket/`

## Need Help?

If you run into any issues:

1. Check that Git is installed and working
2. Verify you're in the correct directory
3. Try a different command prompt (cmd, PowerShell, Git Bash)
4. Use the manual setup method as a fallback

---

**Recommended**: Use Option 1 (Windows batch file) for the easiest setup!
