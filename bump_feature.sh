#!/usr/bin/env bash
# bump_feature.sh — make a small change to index.html on a feature branch and push it.
# Usage:
#   ./bump_feature.sh                        # auto branch name: feature/bump-YYYYMMDD-HHMMSS
#   ./bump_feature.sh feature/my-branch      # explicit branch name

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Branch name ────────────────────────────────────────────────────────────────
BRANCH="${1:-feature/bump-$(date +%Y%m%d-%H%M%S)}"

# ── Pool of realistic changes ──────────────────────────────────────────────────
# Each entry: DESCRIPTION | OLD_TEXT | NEW_TEXT
# sed uses | as delimiter so avoid | in the strings themselves
CHANGES=(
  "Add password strength hint to login form|placeholder=\"Enter password\"|placeholder=\"Min 8 chars, 1 number\""
  "Rename Sign In button to Log In|>Sign In<|>Log In<"
  "Update counter max step to 5|onclick=\"adjustCounter(1)\">+<|onclick=\"adjustCounter(5)\">+5<"
  "Change counter decrement label|onclick=\"adjustCounter(-1)\">−<|onclick=\"adjustCounter(-5)\">−5<"
  "Add required note to contact name|placeholder=\"Jane Smith\"|placeholder=\"Jane Smith (required)\""
  "Add more info to overview tab|It shows a summary of all activity.|It shows a summary of all activity and recent test runs."
  "Update disabled button label|>Disabled Button<|>Coming Soon<"
  "Rename Clear All Data to Reset All|>Clear All Data<|>Reset All<"
  "Change quantity selector max to 20|min=\"1\" max=\"10\" value=\"1\"|min=\"1\" max=\"20\" value=\"1\""
  "Update contact form submit button label|>Send Message<|>Submit Message<"
  "Add extra_context to confirm modal text|You can confirm or cancel the action.|You can confirm or cancel the action. This cannot be undone."
  "Rename Details tab to Config|>Details<|>Config<"
  "Change History tab label to Logs|>History<|>Logs<"
  "Update page subtitle|Interactive elements for automated E2E testing|Demo app for QA Pilot E2E automation"
)

# Pick a random change
IDX=$(( RANDOM % ${#CHANGES[@]} ))
IFS='|' read -r DESCRIPTION OLD NEW <<< "${CHANGES[$IDX]}"

echo "Branch  : $BRANCH"
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
FILE="index.html"

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
git commit -m "$DESCRIPTION"

# ── Push ─────────────────────────────────────────────────────────────────────
git push -u origin "$BRANCH"

echo ""
echo "✅  Done. Branch '$BRANCH' pushed."
echo "   → Open a PR on GitHub: https://github.com/himanshkukreja/qa-pilot-demo-app/compare/$BRANCH"
