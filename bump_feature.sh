#!/usr/bin/env bash
# bump_feature.sh — make a small change to the React demo app on a feature branch and push it.
#
# This creates a realistic PR diff that the narrative-qa pipeline will analyze:
#   code analysis → route/API/flow extraction
#   DOM extraction → element/locator inventory
#   combined context → LLM-ready test generation input
#
# Usage:
#   ./bump_feature.sh                        # auto branch name: feature/bump-YYYYMMDD-HHMMSS
#   ./bump_feature.sh feature/my-branch      # explicit branch name

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Branch name ────────────────────────────────────────────────────────────────
BRANCH="${1:-feature/bump-$(date +%Y%m%d-%H%M%S)}"

# ── Pool of realistic React app changes ────────────────────────────────────────
# Each entry: FILE | DESCRIPTION | OLD_TEXT | NEW_TEXT
# sed uses | as delimiter so avoid | in the strings themselves
CHANGES=(
  # LoginPage changes
  "src/pages/LoginPage.tsx|Rename login title from Sign In to Log In|>Sign In<|>Log In<"
  "src/pages/LoginPage.tsx|Update login button text|>Sign in<|>Continue<"
  "src/pages/LoginPage.tsx|Add placeholder hint to email field|placeholder=\"you@example.com\"|placeholder=\"Enter your work email\""
  "src/pages/LoginPage.tsx|Update password placeholder|placeholder=\"••••••••\"|placeholder=\"Min 8 characters\""
  # Dashboard changes
  "src/pages/Dashboard.tsx|Rename Dashboard title|>Dashboard<|>Overview<"
  "src/pages/Dashboard.tsx|Update Total Users label|>Total Users<|>All Users<"
  "src/pages/Dashboard.tsx|Rename Active Users stat|>Active Users<|>Online Now<"
  "src/pages/Dashboard.tsx|Update Total Tests label|>Total Tests<|>Test Runs<"
  # UserList changes
  "src/pages/UserList.tsx|Update user list title|>User Management<|>Team Members<"
  "src/pages/UserList.tsx|Update search placeholder|placeholder=\"Search users...\"|placeholder=\"Find by name or email...\""
  "src/pages/UserList.tsx|Rename Edit link text|>Edit<|>View Profile<"
  # UserDetail changes
  "src/pages/UserDetail.tsx|Rename Save button|>Save Changes<|>Update Profile<"
  "src/pages/UserDetail.tsx|Update delete button text|>Delete User<|>Remove User<"
  "src/pages/UserDetail.tsx|Update back link text|>← Back to Users<|>← Back to Team<"
  # Settings changes
  "src/pages/Settings.tsx|Rename settings title|>Settings<|>Preferences<"
  "src/pages/Settings.tsx|Update save button text|>Save Settings<|>Apply Changes<"
  "src/pages/Settings.tsx|Rename Email Notifications label|>Email Notifications<|>Email Alerts<"
  "src/pages/Settings.tsx|Update Dark Mode label|>Dark Mode<|>Night Theme<"
  # Layout / navigation changes
  "src/components/Layout.tsx|Rename app title in sidebar|>QA Pilot Demo<|>QA Pilot App<"
  "src/components/Layout.tsx|Rename Dashboard nav link|📊 Dashboard|📊 Overview"
  "src/components/Layout.tsx|Rename Users nav link|👥 Users|👥 Team"
  "src/components/Layout.tsx|Update logout button text|>Logout<|>Sign Out<"
  # ConfirmModal changes
  "src/components/ConfirmModal.tsx|Rename modal cancel button|>Cancel<|>Go Back<"
)

# Pick a random change
IDX=$(( RANDOM % ${#CHANGES[@]} ))
IFS='|' read -r FILE DESCRIPTION OLD NEW <<< "${CHANGES[$IDX]}"

echo "Branch  : $BRANCH"
echo "File    : $FILE"
echo "Change  : $DESCRIPTION"
echo ""

# ── Checkout / create branch from main ────────────────────────────────────────
git fetch origin main --quiet
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" origin/main
fi

# ── Apply the change ──────────────────────────────────────────────────────────
if ! grep -qF "$OLD" "$FILE"; then
  echo "⚠️  Pattern not found in $FILE — the file may have already been changed."
  echo "    OLD: $OLD"
  echo "Skipping edit, nothing to commit."
  exit 0
fi

# macOS sed needs '' for in-place edit
sed -i '' "s|${OLD}|${NEW}|" "$FILE"

# ── Commit ────────────────────────────────────────────────────────────────────
git add "$FILE"
git commit -m "$DESCRIPTION

Changed: $FILE
Previous: $OLD
Updated:  $NEW"

# ── Push ─────────────────────────────────────────────────────────────────────
git push -u origin "$BRANCH"

echo ""
echo "✅  Done. Branch '$BRANCH' pushed."
echo "    File:   $FILE"
echo "    Change: $DESCRIPTION"
echo ""
echo "   → Open a PR on GitHub to trigger the QA pipeline"
