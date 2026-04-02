#!/usr/bin/env bash
# bump_feature.sh — make MULTIPLE changes across the React demo app on a feature
# branch and push it.
#
# This creates a realistic multi-file PR diff that the narrative-qa pipeline
# will analyze:
#   code analysis → route/API/flow extraction
#   DOM extraction → element/locator inventory
#   combined context → LLM-ready test generation input
#
# Every change is BIDIRECTIONAL (A↔B) so the script always has something to
# toggle, even after many consecutive runs.
#
# Usage:
#   ./bump_feature.sh                        # auto branch name, 3-6 changes
#   ./bump_feature.sh feature/my-branch      # explicit branch name
#   ./bump_feature.sh feature/x 8            # explicit branch + change count

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Branch name + change count ─────────────────────────────────────────────────
BRANCH="${1:-feature/bump-$(date +%Y%m%d-%H%M%S)}"
NUM_CHANGES="${2:-0}"  # 0 = random between 3 and 6

# ── Pool of bidirectional changes ──────────────────────────────────────────────
# Each entry: FILE | DESCRIPTION_A→B | TEXT_A | TEXT_B
# The script checks which direction applies and uses it.
# sed uses | as delimiter — avoid | in the text strings.
#
# GROUPED by file so the diff touches multiple pages / layers:
#   LoginPage  — auth flow, form labels, button text
#   Dashboard  — stats, headings, links
#   UserList   — search, table, labels
#   UserDetail — form, buttons, modals
#   Settings   — toggles, section headings
#   Layout     — sidebar, navigation
#   ConfirmModal — modal buttons
#   client.ts  — API layer, simulated data
#   styles.css — visual tweaks
PAIRS=(
  # ── LoginPage ───────────────────────────────────────────────
  "src/pages/LoginPage.tsx|Rename login title|>Sign In</h1>|>Log In</h1>"
  "src/pages/LoginPage.tsx|Update email placeholder|Enter your email|Enter your work email"
  "src/pages/LoginPage.tsx|Update password placeholder|Enter your password|Min 8 characters"
  "src/pages/LoginPage.tsx|Update login hint text|Use any email and password to sign in.|Enter any credentials to continue."
  "src/pages/LoginPage.tsx|Rename submit button label|'Sign In'}|'Log In'}"
  "src/pages/LoginPage.tsx|Rename loading button text|'Signing in...'|'Please wait...'"

  # ── Dashboard ───────────────────────────────────────────────
  "src/pages/Dashboard.tsx|Rename Dashboard page title|>Dashboard</h1>|>Overview</h1>"
  "src/pages/Dashboard.tsx|Rename Total Users stat label|>Total Users<|>All Users<"
  "src/pages/Dashboard.tsx|Rename Active Users stat label|>Active Users<|>Online Now<"
  "src/pages/Dashboard.tsx|Rename Test Executions stat label|>Test Executions<|>Tests Run<"
  "src/pages/Dashboard.tsx|Rename Quick Links heading|>Quick Links<|>Shortcuts<"
  "src/pages/Dashboard.tsx|Update Manage Users link text|👥 Manage Users|👥 View All Users"
  "src/pages/Dashboard.tsx|Update View Admins link text|🛡️ View Admins|🛡️ Admin Panel"

  # ── UserList ────────────────────────────────────────────────
  "src/pages/UserList.tsx|Rename Users page title|>Users</h1>|>Team Members</h1>"
  "src/pages/UserList.tsx|Update search placeholder|Search users by name or email...|Find team members..."
  "src/pages/UserList.tsx|Update result count label|user(s) found|member(s) found"
  "src/pages/UserList.tsx|Update empty state message|No users found|No matching members"

  # ── UserDetail ──────────────────────────────────────────────
  "src/pages/UserDetail.tsx|Rename Edit User title|>Edit User</h1>|>User Profile</h1>"
  "src/pages/UserDetail.tsx|Rename Delete User button|Delete User|Remove User"
  "src/pages/UserDetail.tsx|Rename Save Changes button|Save Changes|Update Profile"
  "src/pages/UserDetail.tsx|Update name placeholder|placeholder=\"Full Name\"|placeholder=\"Enter full name\""
  "src/pages/UserDetail.tsx|Update success message|User updated successfully!|Profile saved!"
  "src/pages/UserDetail.tsx|Update delete confirm text|This action cannot be undone.|This is permanent and cannot be reversed."

  # ── Settings ────────────────────────────────────────────────
  "src/pages/Settings.tsx|Rename Settings page title|>Settings</h1>|>Preferences</h1>"
  "src/pages/Settings.tsx|Rename Notifications section|>Notifications</h2>|>Alerts</h2>"
  "src/pages/Settings.tsx|Rename Email Notifications toggle|Email Notifications|Email Alerts"
  "src/pages/Settings.tsx|Rename Dark Mode toggle|Dark Mode|Night Theme"
  "src/pages/Settings.tsx|Rename Auto-Save toggle|Auto-Save|Auto-Sync"
  "src/pages/Settings.tsx|Rename Save Settings button|Save Settings|Apply Changes"
  "src/pages/Settings.tsx|Update success message|Settings saved successfully!|Preferences updated!"

  # ── Layout / navigation ─────────────────────────────────────
  "src/components/Layout.tsx|Rename sidebar app title|>QA Pilot Demo<|>QA Pilot App<"
  "src/components/Layout.tsx|Rename Dashboard nav link|📊 Dashboard|📊 Home"
  "src/components/Layout.tsx|Rename Users nav link|👥 Users|👥 Team"
  "src/components/Layout.tsx|Rename Logout button|Logout|Sign Out"

  # ── ConfirmModal ────────────────────────────────────────────
  "src/components/ConfirmModal.tsx|Rename modal confirm button|            Confirm|            Yes, proceed"
  "src/components/ConfirmModal.tsx|Rename modal cancel button|            Cancel|            Go back"

  # ── API client ──────────────────────────────────────────────
  "src/api/client.ts|Update user Alice name|Alice Johnson|Alice Chen"
  "src/api/client.ts|Update user Bob name|Bob Smith|Robert Smith"
  "src/api/client.ts|Update user Carol status|status: 'inactive'|status: 'suspended'"
  "src/api/client.ts|Update total tests count|totalTests: 142|totalTests: 256"

  # ── CSS / visual ────────────────────────────────────────────
  "src/styles.css|Change sidebar background|background: #1a1a2e;|background: #16213e;"
  "src/styles.css|Change sidebar accent color|color: #4cc9f0;|color: #00b4d8;"
  "src/styles.css|Change link color|color: #4361ee;|color: #3a86ff;"
)

# ── Shuffle the pool (Fisher-Yates) ──────────────────────────────────────────
TOTAL=${#PAIRS[@]}
ORDER=()
for (( i=0; i<TOTAL; i++ )); do ORDER+=("$i"); done
for (( i=TOTAL-1; i>0; i-- )); do
  j=$(( RANDOM % (i + 1) ))
  tmp=${ORDER[$i]}; ORDER[$i]=${ORDER[$j]}; ORDER[$j]=$tmp
done

# ── Determine how many changes to apply ──────────────────────────────────────
if [[ "$NUM_CHANGES" -eq 0 ]]; then
  # Random between 3 and 6
  NUM_CHANGES=$(( (RANDOM % 4) + 3 ))
fi
# Cap to pool size
if [[ "$NUM_CHANGES" -gt "$TOTAL" ]]; then
  NUM_CHANGES="$TOTAL"
fi

# ── Find applicable changes across different files ────────────────────────────
APPLIED=()        # descriptions
APPLIED_FILES=()  # unique files that were changed
CHANGE_COUNT=0
declare -A FILE_SUBS  # file -> newline-separated "OLD|||NEW" pairs

for IDX in "${ORDER[@]}"; do
  [[ "$CHANGE_COUNT" -ge "$NUM_CHANGES" ]] && break

  IFS='|' read -r FILE DESC TEXT_A TEXT_B <<< "${PAIRS[$IDX]}"

  OLD="" NEW=""
  if grep -qF "$TEXT_A" "$FILE" 2>/dev/null; then
    OLD="$TEXT_A"; NEW="$TEXT_B"
    DESC="$DESC (A→B)"
  elif grep -qF "$TEXT_B" "$FILE" 2>/dev/null; then
    OLD="$TEXT_B"; NEW="$TEXT_A"
    DESC="$DESC (B→A)"
  else
    continue  # neither direction applies
  fi

  # Track this substitution
  if [[ -z "${FILE_SUBS[$FILE]:-}" ]]; then
    FILE_SUBS[$FILE]="${OLD}|||${NEW}"
  else
    FILE_SUBS[$FILE]="${FILE_SUBS[$FILE]}"$'\n'"${OLD}|||${NEW}"
  fi
  APPLIED+=("  • $FILE — $DESC")

  # Track unique files
  local_found=0
  for af in "${APPLIED_FILES[@]:-}"; do
    [[ "$af" == "$FILE" ]] && local_found=1 && break
  done
  [[ "$local_found" -eq 0 ]] && APPLIED_FILES+=("$FILE")

  (( CHANGE_COUNT++ ))
done

if [[ "$CHANGE_COUNT" -eq 0 ]]; then
  echo "❌  No applicable changes found — all patterns exhausted."
  echo "    Try resetting to main: git checkout main"
  exit 1
fi

echo "Branch  : $BRANCH"
echo "Changes : $CHANGE_COUNT across ${#APPLIED_FILES[@]} file(s)"
echo ""
for line in "${APPLIED[@]}"; do
  echo "$line"
done
echo ""

# ── Checkout / create branch from main ────────────────────────────────────────
git fetch origin main --quiet

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
else
  git checkout -b "$BRANCH" origin/main
fi

# ── Apply all changes ─────────────────────────────────────────────────────────
for FILE in "${APPLIED_FILES[@]}"; do
  while IFS= read -r line; do
    OLD="${line%%|||*}"
    NEW="${line##*|||}"
    # macOS sed needs '' for in-place edit
    sed -i '' "s|${OLD}|${NEW}|g" "$FILE"
  done <<< "${FILE_SUBS[$FILE]}"
done

# ── Build commit message ──────────────────────────────────────────────────────
COMMIT_TITLE="feat: update UI labels across ${#APPLIED_FILES[@]} file(s)"
COMMIT_BODY="Changes ($CHANGE_COUNT):"
for line in "${APPLIED[@]}"; do
  COMMIT_BODY="$COMMIT_BODY
$line"
done

# ── Commit ────────────────────────────────────────────────────────────────────
git add "${APPLIED_FILES[@]}"
git commit -m "$COMMIT_TITLE

$COMMIT_BODY"

# ── Push ─────────────────────────────────────────────────────────────────────
git push -u origin "$BRANCH"

echo ""
echo "✅  Done. Branch '$BRANCH' pushed."
echo "    $CHANGE_COUNT change(s) across ${#APPLIED_FILES[@]} file(s)"
echo ""
echo "   → Open a PR on GitHub to trigger the QA pipeline"
