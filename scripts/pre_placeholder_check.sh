#!/bin/bash
#
# pre_placeholder_check.sh - RULE 13 Enforcement
#
# Purpose: Detect placeholders/TODOs BEFORE Write/Edit operations
# Trigger: PreToolUse hook before Write/Edit
# Rule: RULE 13 - Real Data Only
# Version: 1.0.0
# Date: 2025-11-13
#
# Blocks commits containing: TODO, FIXME, PLACEHOLDER, XXX, TBD, empty strings
# Exception: Allows in draft branches, test files, and markdown files
#
# Exit codes:
# 0 - No placeholders found or acceptable context (allow operation)
# 1 - Placeholders found (block operation)
#

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get file path and content from tool arguments
FILE_PATH="${FILE_PATH:-}"
CONTENT="${CONTENT:-}"

# If not provided, try to get from command line
if [ -z "$FILE_PATH" ] && [ $# -gt 0 ]; then
    FILE_PATH="$1"
fi

if [ -z "$FILE_PATH" ]; then
    # No file path provided, skip check
    exit 0
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 PRE-PLACEHOLDER CHECK (RULE 13 - Real Data Only)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "File: $FILE_PATH"
echo ""

# Check if this is an exception case
ALLOW_PLACEHOLDERS=false

# Exception 1: Test files (always allow placeholders in tests)
if [[ "$FILE_PATH" =~ test_.*\.py$ ]] || \
   [[ "$FILE_PATH" =~ .*_test\.py$ ]] || \
   [[ "$FILE_PATH" =~ .*\.test\.js$ ]] || \
   [[ "$FILE_PATH" =~ .*\.spec\.js$ ]] || \
   [[ "$FILE_PATH" =~ .*_test\.go$ ]] || \
   [[ "$FILE_PATH" =~ tests/.* ]]; then
    ALLOW_PLACEHOLDERS=true
    echo -e "${GREEN}✓ Test file - placeholders allowed${NC}"
fi

# Exception 2: Markdown files (documentation can have TODO sections)
if [[ "$FILE_PATH" =~ .*\.md$ ]]; then
    ALLOW_PLACEHOLDERS=true
    echo -e "${GREEN}✓ Markdown file - placeholders allowed${NC}"
fi

# Exception 3: Draft branches
if [ -d ".git" ]; then
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    if [[ "$CURRENT_BRANCH" =~ draft ]] || \
       [[ "$CURRENT_BRANCH" =~ wip ]] || \
       [[ "$CURRENT_BRANCH" =~ temp ]]; then
        ALLOW_PLACEHOLDERS=true
        echo -e "${GREEN}✓ Draft branch ($CURRENT_BRANCH) - placeholders allowed${NC}"
    fi
fi

# Exception 4: Config/template files
if [[ "$FILE_PATH" =~ .*\.template$ ]] || \
   [[ "$FILE_PATH" =~ .*\.example$ ]] || \
   [[ "$FILE_PATH" =~ \.env\.* ]]; then
    ALLOW_PLACEHOLDERS=true
    echo -e "${GREEN}✓ Template/example file - placeholders allowed${NC}"
fi

if [ "$ALLOW_PLACEHOLDERS" = true ]; then
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Read file content if not provided
if [ -z "$CONTENT" ] && [ -f "$FILE_PATH" ]; then
    CONTENT=$(cat "$FILE_PATH")
fi

if [ -z "$CONTENT" ]; then
    # Can't check content, assume OK
    echo -e "${YELLOW}⚠️  Cannot read file content (skipping placeholder check)${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Define placeholder patterns to detect
FORBIDDEN_PATTERNS=(
    "TODO"
    "FIXME"
    "XXX"
    "PLACEHOLDER"
    "TBD"
    "HACK"
    "TEMP"
    "\\bFIX\\b"
)

# Search for forbidden patterns
VIOLATIONS=()

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -i "$pattern" > /dev/null 2>&1; then
        # Found a match - get line numbers
        MATCHES=$(echo "$CONTENT" | grep -n -i "$pattern" | head -5)
        VIOLATIONS+=("$pattern")
    fi
done

# Check for empty strings (only in code files)
if [[ "$FILE_PATH" =~ \.(py|js|ts|go|rs|java|cpp)$ ]]; then
    # Count suspicious empty strings (common placeholder pattern)
    EMPTY_STRING_COUNT=$(echo "$CONTENT" | grep -c '= ""' 2>/dev/null || echo 0)
    if [ "$EMPTY_STRING_COUNT" -gt 3 ]; then
        VIOLATIONS+=("Multiple empty strings (possible placeholders)")
    fi
fi

# Report results
if [ ${#VIOLATIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED: No placeholders detected${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
    echo -e "❌ BLOCKED: Placeholders detected in file"
    echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}RULE 13 VIOLATION: Real data only - no placeholders allowed${NC}"
    echo ""
    echo "Placeholders found:"
    for violation in "${VIOLATIONS[@]}"; do
        echo -e "  ${RED}✗${NC} $violation"
    done
    echo ""
    echo "REQUIRED ACTIONS:"
    echo "  1. Replace all placeholders with real data/values"
    echo "  2. Research actual values before committing"
    echo "  3. Remove TODO/FIXME comments"
    echo "  4. OR move to draft branch for work-in-progress"
    echo ""
    echo "Why blocked:"
    echo "  - Placeholders indicate incomplete work"
    echo "  - Production code must be complete and functional"
    echo "  - Framework enforces 'done means done'"
    echo ""
    echo "Exceptions (where placeholders ARE allowed):"
    echo "  - Test files (test_*.py, *.test.js, etc.)"
    echo "  - Markdown documentation (*.md)"
    echo "  - Draft/WIP branches"
    echo "  - Template files (*.template, *.example)"
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
