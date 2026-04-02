#!/usr/bin/env bash
# bump_feature.sh — make a small change to the React demo app on a feature branch and push it.
#
# This creates a realistic PR diff that the narrative-qa pipeline will analyze:
#   code analysis → route/API/flow extraction
#   DOM extraction → element/locator inventory
#   combined context → LLM-ready test generation input
#
# Every change is BIDIRECTIONAL (A↔B) so the script always has something to
# toggle, even after many consecutive runs.
#
# Usage:
#   ./bump_feature.sh                        # auto branch name: feature/bump-YYYYMMDD-HHMMSS
#   ./bump_feature.sh feature/my-branch      # explicit branch name

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Branch name ────────────────────────────────────────────────────────────────
BRANCH="${1:-feature/bump-$(date +%Y%m%d-%H%M%S)}"

# ── Pool of bidirectional changes ──────────────────────────────────────────────
# Each entry: FILE | DESCRIPTION_A→B | TEXT_A | TEXT_B
# The script checks which direction applies and uses it.
# sed uses | as delimiter — avoid | in the text strings.
PAIRS=(
  # LoginPage
  "src/pages/LoginPage.tsx|Rename login title|>Sign In</h1>|>Log In</h1>"
  "src/pages/LoginPage.tsx|Update email placeholder|Enter your email|Enter your work email"
  "src/pages/LoginPage.tsx|Update password placeholder|Enter your password|Min 8 characters"
  "src/pages/LoginPage.tsx|Update login hint text|Use any email and password to sign in.|Enter any credentials to continue."
  # Dashboard
  "src/pages/Dashboard.tsx|Rename Dashboard page title|>Dashboard</h1>|>Overview</h1>"
  "src/pages/Dashboard.tsx|Rename Total Users stat|>Total Users<|>All Users<"
  "src/pages/Dashboard.tsx|Rename Active Users stat|>Active Users<|>Online Now<"
  "src/pages/Dashboard.tsx|Rename Tests Run stat|>Tests Run<|>Test Executions<"
  "src/pages/Dashboard.tsx|Rename Quick Links heading|>Quick Links<|>Shortcuts<"
  "src/pages/Dashboard.tsx|Update Manage Users link|👥 Manage Users|👥 View All Users"
  # UserList
  "src/pages/UserList.tsx|Rename Users page title|>Users</h1>|>Team Members</h1>"
  "src/pages/UserList.tsx|Update search placeholder|Search users by name or email...|Find team members..."
  "src/pages/UserList.tsx|Update result count label|user(s) found|member(s) found"
  # UserDetail
  "src/pages/UserDetail.tsx|Rename Edit User title|>Edit User</h1>|>User Profile</h1>"
  "src/pages/UserDetail.tsx|Rename Delete User button and modal|Delete User|Remove User"
  "src/pages/UserDetail.tsx|Rename Save Changes button|Save Changes|Update Profile"
  "src/pages/UserDetail.tsx|Update name placeholder|placeholder=\"Full Name\"|placeholder=\"Enter full name\""
  # Settings
  "src/pages/Settings.tsx|Rename Settings page title|>Settings</h1>|>Preferences</h1>"
  "src/pages/Settings.tsx|Rename Notifications section|>Notifications</h2>|>Alerts</h2>"
  "src/pages/Settings.tsx|Rename Email Notifications toggle|Email Notifications|Email Alerts"
  "src/pages/Settings.tsx|Rename Dark Mode toggle|Dark Mode|Night Theme"
  "src/pages/Settings.tsx|Rename Auto-Save toggle|Auto-Save|Auto-Sync"
  "src/pages/Settings.tsx|Rename Save Settings button|Save Settings|Apply Changes"
  # Layout / navigation
  "src/components/Layout.tsx|Rename sidebar app title|>QA Pilot Demo<|>QA Pilot App<"
  "src/components/Layout.tsx|Rename Dashboard nav link|📊 Dashboard|📊 Home"
  "src/components/Layout.tsx|Rename Users nav link|👥 Users|👥 Team"
  # ConfirmModal
  "src/components/ConfirmModal.tsx|Rename modal confirm button|>Confirm<|>Yes, proceed<"
)

# ── Shuffle the pool (Fisher-Yates) ──────────────────────────────────────────
TOTAL=${#PAIRS[@]}
ORDER=()
for (( i=0; i<TOTAL; i++ )); do ORDER+=("$i"); done
for (( i=TOTAL-1; i>0; i-- )); do
  j=$(( RANDOM % (i + 1) ))
  tmp=${ORDER[$i]}; ORDER[$i]=${ORDER[$j]}; ORDER[$j]=$tmp
done

# ── Find a change that applies (try A→B first, then B→A) ─────────────────────
FOUND=0
for IDX in "${ORDER[@]}"; do
  IFS='|' read -r FILE DESC TEXT_A TEXT_B <<< "${PAIRS[$IDX]}"
  if grep -qF "$TEXT_A" "$FILE" 2>/dev/null; then
    OLD="$TEXT_A"; NEW="$TEXT_B"
    DESCRIPTION="$DESC (A→B)"
    FOUND=1; break
  elif grep -qF "$TEXT_B" "$FILE" 2>/dev/null; then
    OLD="$TEXT_B"; NEW="$TEXT_A"
    DESCRIPTION="$DESC (B→A)"
    FOUND=1; break
  fi
done

if [[ $FOUND -eq 0 ]]; then
  echo "❌  No applicable changes found — all patterns exhausted."
  echo "    Try resetting to main: git checkout main"
  exit 1
fi

echo "Branch  : $BRANCH"
echo "File    : $FILE"
echo "Change  : $DESCRIPTION"
echo ""

# ── Checkout / create branch from main ────────────────────────────────────────
git fetch origin main --quiet

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" origin/main
fi

# ── Apply the change ──────────────────────────────────────────────────────────
# macOS sed needs '' for in-place edit
sed -i '' "s|${OLD}|${NEW}|g" "$FILE"

# ── Commit ────────────────────────────────────────────────────────────────────
git add "$FILE"
git commit -m "$DESCRIPTION

File:     $FILE
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
