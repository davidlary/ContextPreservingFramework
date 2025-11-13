#!/bin/bash
# pre_incremental_check.sh - PreToolUse hook for RULE 5 monitoring
# Purpose: Monitor incremental delivery (warn if large commits attempted)
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before git commit
#
# MONITORING (behavioral rule):
# - Checks if trying to commit >500 lines at once
# - Warns if commit is too large (encourages incremental delivery)
# - Cannot block (behavioral rule), only provides reminders

set -euo pipefail

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
MAX_LINES_PER_COMMIT=500
WARNING_THRESHOLD=300

# Only check on git commit operations
if [ -z "${TOOL_ARGS:-}" ]; then
    # Check if this is a git commit command
    if [ $# -gt 0 ]; then
        COMMAND="$*"
        if [[ ! "$COMMAND" =~ git.*commit ]]; then
            exit 0  # Not a commit, skip check
        fi
    else
        exit 0  # No args, skip check
    fi
else
    # Check tool args for git commit
    if command -v jq &> /dev/null; then
        COMMAND=$(echo "$TOOL_ARGS" | jq -r '.command // empty')
        if [[ ! "$COMMAND" =~ git.*commit ]]; then
            exit 0  # Not a commit, skip check
        fi
    else
        exit 0  # No jq, skip check
    fi
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0  # Not a git repo, skip check
fi

# Get staged changes line count
STAGED_LINES=$(git diff --cached --numstat 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+removed}')

# Handle case where no files are staged
if [ -z "$STAGED_LINES" ] || [ "$STAGED_LINES" = "0" ]; then
    exit 0  # No staged changes, skip check
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "📦 INCREMENTAL DELIVERY CHECK (RULE 5 - Monitoring)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "Staged changes: $STAGED_LINES lines"
echo ""

if [ "$STAGED_LINES" -gt "$MAX_LINES_PER_COMMIT" ]; then
    echo -e "${RED}⚠️  WARNING: Very large commit detected${NC}"
    echo ""
    echo "This commit includes $STAGED_LINES lines (recommended: <$MAX_LINES_PER_COMMIT)"
    echo ""
    echo "RULE 5 encourages incremental delivery:"
    echo "  • Commit smaller, focused changes"
    echo "  • Break large changes into logical steps"
    echo "  • Make commits easier to review"
    echo "  • Enable easier rollback if needed"
    echo ""
    echo "RECOMMENDATION:"
    echo "  • Consider splitting into multiple commits"
    echo "  • Group related changes together"
    echo "  • Use 'git add -p' for selective staging"
    echo ""
    echo "This is a WARNING, not a blocker. Proceeding with commit..."
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # Warning only, don't block

elif [ "$STAGED_LINES" -ge "$WARNING_THRESHOLD" ]; then
    echo -e "${YELLOW}⚠️  Large commit detected${NC}"
    echo ""
    echo "This commit includes $STAGED_LINES lines (recommended: <$MAX_LINES_PER_COMMIT)"
    echo ""
    echo "Consider breaking into smaller commits for easier review."
    echo ""
    echo "Proceeding with commit..."
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # Warning only, don't block

else
    echo -e "${GREEN}✅ Commit size appropriate ($STAGED_LINES lines)${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # All good
fi
