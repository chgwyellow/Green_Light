#!/bin/bash
set -e

# ==========================================
# ⚙️ Default values configuration
# ==========================================
DEFAULT_PROJECT_NAME="YOUR_PROJECT"
DEFAULT_PROJECT_URL="YOUR_URL"
DEFAULT_BRANCHES="YOUR_BRANCH"
DEFAULT_GITHUB_URL="YOUR_REPO"

TEMP_DIR="temp_green_light_build"

# ==========================================
# 💬 Interactive input section
# ==========================================
echo "==========================================="
echo "   GitHub Green-Light Auto Sync Tool       "
echo "==========================================="

echo "👉 Enter project name (press Enter to use default: $DEFAULT_PROJECT_NAME):"
read input_project_name
PROJECT_NAME="${input_project_name:-$DEFAULT_PROJECT_NAME}"

echo "👉 Enter source Clone URL (press Enter to use default project URL):"
read input_url
PROJECT_URL="${input_url:-$DEFAULT_PROJECT_URL}"

echo "👉 Enter branch name(s) to sync, space-separated (press Enter to use default: $DEFAULT_BRANCHES):"
read -a input_branches
if [[ ${#input_branches[@]} -eq 0 ]]; then
    read -ra BRANCHES <<<"$DEFAULT_BRANCHES"
else
    BRANCHES=("${input_branches[@]}")
fi

echo "👉 Enter target GitHub Private URL (press Enter to use default: $DEFAULT_GITHUB_URL):"
read input_github
GITHUB_URL="${input_github:-$DEFAULT_GITHUB_URL}"

# Validate required inputs
if [[ -z "$PROJECT_NAME" || -z "$PROJECT_URL" || ${#BRANCHES[@]} -eq 0 || -z "$GITHUB_URL" ]]; then
    echo "❌ Error: All fields are required. Aborting."
    exit 1
fi

echo "-------------------------------------------"
echo " Ready to start sync..."
echo " [Project Name  ]: $PROJECT_NAME"
echo " [Source Project]: $PROJECT_URL"
echo " [Branches      ]: ${BRANCHES[*]}"
echo " [Push to GitHub]: $GITHUB_URL"
echo " [Remote format ]: $PROJECT_NAME/<branch>"
echo "-------------------------------------------"
echo "Press any key to continue, or Ctrl+C to cancel..."
read -n 1 -s
echo ""

# ==========================================
# 🚀 Core automation logic
# ==========================================
TOTAL=${#BRANCHES[@]}
COUNT=0

for BRANCH in "${BRANCHES[@]}"; do
    COUNT=$((COUNT + 1))
    REMOTE_BRANCH="$PROJECT_NAME/$BRANCH"

    echo ""
    echo "==========================================="
    echo " [$COUNT/$TOTAL] Syncing branch: $BRANCH"
    echo "       → Remote target: $REMOTE_BRANCH"
    echo "==========================================="

    echo "=== 🟢 Step 1: Clean local temp directory and re-clone ==="
    rm -rf "$TEMP_DIR"
    git clone "$PROJECT_URL" "$TEMP_DIR"
    cd "$TEMP_DIR"

    echo "=== 🟢 Step 2: Switch to target branch [$BRANCH] ==="
    git checkout "$BRANCH"

    echo "=== 🟢 Step 3: Security scrubbing (erase all source code) ==="
    # git filter-repo removes all remotes as a safety measure; we re-add it in Step 4
    git filter-repo --invert-paths --path-glob '*' --prune-empty never --force

    echo "=== 🟢 Step 4: Set target GitHub remote and push ==="
    git remote add origin "$GITHUB_URL"
    git push -u origin "HEAD:$REMOTE_BRANCH" --force

    echo "=== 🟢 Step 5: Clean up local temp directory ==="
    cd ..
    rm -rf "$TEMP_DIR"

    echo "✅ Done: [$BRANCH] → $REMOTE_BRANCH"
done

echo ""
echo "==========================================="
echo " 🎉 All $TOTAL branch(es) synced successfully!"
echo "==========================================="
