#!/bin/bash
set -euo pipefail

# ==========================================
# ⚙️ Default values configuration
# ==========================================
DEFAULT_PROJECT_URL=""
DEFAULT_BRANCH=""
DEFAULT_GITHUB_URL=""

TEMP_DIR="temp_green_light_build"

# ==========================================
# 💬 Interactive input section
# ==========================================
echo "==========================================="
echo "   GitHub Green-Light Auto Sync Tool       "
echo "==========================================="

# 1. Ask for source Clone URL
echo "👉 Enter source Clone URL (press Enter to use default project: $DEFAULT_PROJECT_URL):"
read input_url
PROJECT_URL="${input_url:-$DEFAULT_PROJECT_URL}"

# 2. Ask for Branch Name
echo "👉 Enter the branch name to clean (press Enter to use default: $DEFAULT_BRANCH):"
read input_branch
BRANCH_NAME="${input_branch:-$DEFAULT_BRANCH}"

# 3. Ask for GitHub URL
echo "👉 Enter target GitHub Private URL (press Enter to use default: $DEFAULT_GITHUB_URL):"
read input_github
GITHUB_URL="${input_github:-$DEFAULT_GITHUB_URL}"

# Validate required inputs
if [[ -z "$PROJECT_URL" || -z "$BRANCH_NAME" || -z "$GITHUB_URL" ]]; then
  echo "❌ Error: PROJECT_URL, BRANCH_NAME, and GITHUB_URL are all required. Aborting."
  exit 1
fi

echo "-------------------------------------------"
echo " Ready to start sync..."
echo " [Source Project]: $PROJECT_URL"
echo " [Target Branch ]: $BRANCH_NAME"
echo " [Push to GitHub]: $GITHUB_URL"
echo "-------------------------------------------"
echo "Press any key to continue, or Ctrl+C to cancel..."
read -n 1 -s

# ==========================================
# 🚀 Core automation logic
# ==========================================
echo "=== 🟢 Step 1: Clean local temp directory and re-clone ==="
rm -rf "$TEMP_DIR"
git clone "$PROJECT_URL" "$TEMP_DIR"
cd "$TEMP_DIR"

echo "=== 🟢 Step 2: Switch to target branch [$BRANCH_NAME] ==="
git checkout "$BRANCH_NAME"

echo "=== 🟢 Step 3: Security scrubbing (erase all source code) ==="
git filter-branch --force --index-filter \
  'git rm --cached -qr --ignore-unmatch .' \
  --tag-name-filter cat -- --all

echo "=== 🟢 Step 4: Destroy local source code pointers ==="
git for-each-ref --format="%(refname)" refs/original/ | \
  xargs -r -I {} git update-ref -d {}
git gc --prune=now --aggressive

echo "=== 🟢 Step 5: Set target GitHub, clear remote cache and push ==="
git remote set-url origin "$GITHUB_URL"

# 1. Delete remote main branch on GitHub (forces GitHub to reset)
git push origin --delete main 2>/dev/null || true

# 2. Push the cleaned local branch to recreate main branch
git push -u origin "$BRANCH_NAME:main" --force

echo "=== 🟢 Step 6: Clean up temp directory ==="
cd ..
rm -rf "$TEMP_DIR"

echo "==========================================="
echo " 🎉 Done! Project has been synced successfully!"
echo "==========================================="
