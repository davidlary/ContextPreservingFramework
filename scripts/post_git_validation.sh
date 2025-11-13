#!/bin/bash
#
# post_git_validation.sh - RULE 16 Enforcement
#
# Purpose: Validate git commit message format AFTER git commit
# Trigger: PostToolUse hook after git commit commands
# Rule: RULE 16 - Automatic Git Operations
# Version: 1.0.0
# Date: 2025-11-13
#
# Validates that commit messages follow the required format:
# - Has proper structure (not just "fix" or "update")
# - Includes "Co-Authored-By: Claude" line
# - Includes context percentage (if framework commit)
#
# Exit codes:
# 0 - Always (warnings only, cannot rollback commits)
#

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    exit 0
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 POST-GIT VALIDATION (RULE 16 - Git Operations)"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Get last commit message
LAST_COMMIT_MSG=$(git log -1 --format=%B 2>/dev/null || echo "")

if [ -z "$LAST_COMMIT_MSG" ]; then
    echo -e "${YELLOW}⚠️  No commits found (new repository?)${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Get last commit hash
LAST_COMMIT_HASH=$(git log -1 --format=%h 2>/dev/null)

echo "Last commit: $LAST_COMMIT_HASH"
echo ""

# Validation checks
WARNINGS=()

# Check 1: Has Co-Authored-By line
if echo "$LAST_COMMIT_MSG" | grep -q "Co-Authored-By: Claude"; then
    echo -e "${GREEN}✓ Co-Authored-By line present${NC}"
else
    echo -e "${YELLOW}⚠ Missing Co-Authored-By: Claude line${NC}"
    WARNINGS+=("Missing Co-Authored-By line")
fi

# Check 2: Not a trivial message
FIRST_LINE=$(echo "$LAST_COMMIT_MSG" | head -1)
if [ "${#FIRST_LINE}" -lt 10 ]; then
    echo -e "${YELLOW}⚠ Commit message very short: \"$FIRST_LINE\"${NC}"
    WARNINGS+=("Commit message too short")
elif echo "$FIRST_LINE" | grep -qiE '^(fix|update|change)$'; then
    echo -e "${YELLOW}⚠ Commit message too vague: \"$FIRST_LINE\"${NC}"
    WARNINGS+=("Commit message too vague")
else
    echo -e "${GREEN}✓ Commit message has proper structure${NC}"
fi

# Check 3: Has Claude Code attribution (optional but recommended)
if echo "$LAST_COMMIT_MSG" | grep -q "Generated with.*Claude Code"; then
    echo -e "${GREEN}✓ Claude Code attribution present${NC}"
else
    echo -e "${YELLOW}⚠ Missing Claude Code attribution${NC}"
    WARNINGS+=("Missing Claude Code attribution")
fi

# Check 4: For framework commits, should have context percentage
if [ -f "data/state/context_tracking.json" ]; then
    if echo "$LAST_COMMIT_MSG" | grep -qE '[0-9]+%|Context:|context:'; then
        echo -e "${GREEN}✓ Context tracking info present${NC}"
    else
        echo -e "${YELLOW}⚠ Framework commit missing context info${NC}"
        WARNINGS+=("Missing context percentage")
    fi
fi

# Check 5: Has meaningful description (multiline)
LINE_COUNT=$(echo "$LAST_COMMIT_MSG" | wc -l)
if [ "$LINE_COUNT" -lt 3 ]; then
    echo -e "${YELLOW}⚠ Single-line commit (multiline preferred)${NC}"
    WARNINGS+=("Single-line commit (multiline preferred)")
else
    echo -e "${GREEN}✓ Multiline commit message${NC}"
fi

# Report results
echo ""
if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED: Commit message follows format${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️  WARNING: Commit message format issues detected${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Issues found:"
    for warning in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $warning"
    done
    echo ""
    echo "RULE 16 RECOMMENDED FORMAT:"
    echo ""
    echo "─────────────────────────────────────────────────────────────────────"
    echo "[Module/Task] Description - STATUS"
    echo ""
    echo "Changes:"
    echo "- File 1 modified (details)"
    echo "- File 2 created (details)"
    echo ""
    echo "Progress: X% complete"
    echo "Context: NK tokens (X%)"
    echo ""
    echo "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
    echo ""
    echo "Co-Authored-By: Claude <noreply@anthropic.com>"
    echo "─────────────────────────────────────────────────────────────────────"
    echo ""
    echo "To create commits with proper format:"
    echo "  Use HEREDOC syntax:"
    echo "  git commit -m \"\$(cat <<'EOF'"
    echo "  [Commit message here with proper format]"
    echo "  EOF"
    echo "  )\""
    echo ""
    echo "Why proper format matters:"
    echo "  - Clear commit history for project tracking"
    echo "  - Attribution shows AI-assisted development"
    echo "  - Context tracking helps with recovery"
    echo "  - Professional commit log"
    echo ""
    echo -e "${YELLOW}[INFO]${NC} This is a warning only - commit already created"
    echo -e "${YELLOW}[INFO]${NC} Consider amending if needed: git commit --amend"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi
