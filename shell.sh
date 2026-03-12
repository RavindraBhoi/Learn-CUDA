#!/bin/bash

# 1. Navigate to your CUDA directory
cd ~/Desktop/cuda

# 2. Tell Git to remember your token for 1 hour (3600 seconds)
git config --global credential.helper 'cache --timeout=3600'

# 3. Check for changes
echo "Checking for changes in $(pwd)..."
git status

# 4. Add all files (respecting your .gitignore)
git add .

# 5. Ask for a commit message
echo "Enter your commit message (e.g., 'Completed CUDA Matrix Multiplication'):"
read commit_msg

# 6. Commit and Push
if [ -n "$commit_msg" ]; then
    git commit -m "$commit_msg"
    echo "Pushing to GitHub..."
    git push origin main
else
    echo "Error: Commit message cannot be empty. Script aborted."
fi
