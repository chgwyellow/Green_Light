# Green_Light

Sync commit history from a **non-GitHub** project repository to a private GitHub repo — lighting up your GitHub contribution graph without exposing any source code.

---

## Overview

`sync_green_light.sh` is a Bash automation script designed for developers who work on projects hosted **outside of GitHub** (e.g., a company GitLab, Bitbucket, or any self-hosted git server) and cannot directly push those repositories to GitHub.

The script:

1. Clones the source repository from a non-GitHub remote
2. Switches to a specified branch
3. **Wipes all file contents** from every commit using `git filter-branch`, leaving only the commit skeleton (timestamp, message, author)
4. Pushes this empty-but-dated commit history to a **private GitHub repository**

The result: your GitHub contribution graph lights up to reflect your real work activity — with **zero source code leaked**.

> **Note:** If your project is already on GitHub, you do not need this tool.

---

## Prerequisites

- **Git** installed and available in `$PATH`
- **Bash** (Linux / macOS / WSL on Windows)
- You must have **push access** to the target GitHub repository
- The target GitHub repo must already exist (can be empty)

---

## Quick Start

```bash
# 1. Clone this repo
git clone <this-repo-url>
cd Green_Light

# 2. Make the script executable
chmod +x sync_green_light.sh

# 3. Run the script
./sync_green_light.sh
```

The script will interactively prompt you for three pieces of information:

| Prompt | Description | Example |
|--------|-------------|---------|
| **Source Clone URL** | The git clone URL of your **non-GitHub** project (GitLab, Bitbucket, self-hosted, etc.) | `https://gitlab.com/your-org/project.git` |
| **Branch name** | The branch whose commit history you want to mirror | `main` or `develop` |
| **Target GitHub URL** | The git remote URL of your **private GitHub** repository (the mirror destination) | `https://github.com/yourname/green-light-mirror.git` |

After reviewing the summary, press any key to proceed or `Ctrl+C` to abort.

---

## Setting Defaults (Optional)

To avoid re-typing URLs every run, edit the top of `sync_green_light.sh` and fill in the default values:

```bash
# Must be a non-GitHub URL (GitLab, Bitbucket, self-hosted, etc.)
DEFAULT_PROJECT_URL="https://gitlab.com/your-org/project.git"
DEFAULT_BRANCH="main"
# Must be a private GitHub repository URL
DEFAULT_GITHUB_URL="https://github.com/yourname/green-light-mirror.git"
```

Once set, you can press **Enter** at each prompt to use these defaults.

---

## What the Script Does (Step by Step)

| Step | Action |
|------|--------|
| **Step 1** | Deletes any existing local temp directory and clones the **non-GitHub** source repo fresh |
| **Step 2** | Checks out the specified branch |
| **Step 3** | Runs `git filter-branch` to **erase all file contents** from every commit — only commit metadata (date, message, author) is kept |
| **Step 4** | Cleans up all `refs/original/` leftovers and runs `git gc` to fully purge any remaining data |
| **Step 5** | Switches the remote to your **private GitHub** repo, resets the remote `main` branch, then force-pushes the content-free history |
| **Step 6** | Removes the local temp directory |

---

## Security Notes

- **No source code is pushed.** The script wipes all file contents before pushing — only commit metadata (timestamps, messages, author info) is transferred.
- **Author name and email** in commit metadata will be visible on GitHub. Ensure this is acceptable before running.
- The target GitHub remote URL may contain a **Personal Access Token (PAT)** if embedded in the URL (e.g. `https://<TOKEN>@github.com/...`). Never commit or log such URLs — use SSH keys or a credential manager instead.
- The script uses `set -euo pipefail`, so it will abort immediately on any error rather than continuing in an unsafe state.
- All required inputs are validated — the script will exit with an error if any field is left blank.

---

## Example Run

```
===========================================
   GitHub Green-Light Auto Sync Tool
===========================================
👉 Enter source Clone URL (press Enter to use default project: ):
https://gitlab.com/my-company/secret-project.git
👉 Enter the branch name to clean (press Enter to use default: ):
develop
👉 Enter target GitHub Private URL (press Enter to use default: ):
https://github.com/myname/green-light.git
-------------------------------------------
 Ready to start sync...
 [Source Project]: https://gitlab.com/my-company/secret-project.git
 [Target Branch ]: develop
 [Push to GitHub]: https://github.com/myname/green-light.git
-------------------------------------------
Press any key to continue, or Ctrl+C to cancel...
=== 🟢 Step 1: Clean local temp directory and re-clone ===
...
===========================================
 🎉 Done! Project has been synced successfully!
===========================================
```

---

## License

This tool is for personal use. No warranty is provided.
