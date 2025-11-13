#!/bin/bash
# pre_module_boundary_check.sh - PreToolUse hook for RULE 20 enforcement
# Purpose: Enforce 200-300 line module size limit BEFORE Write/Edit operations
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before Write/Edit tool executes
#
# ENFORCEMENT:
# - Checks if file being written/edited exceeds 300 lines
# - BLOCKS (exit 2) if >300 lines without proper module structure
# - Warns if approaching limit (250-300 lines)
# - Suggests splitting into sub-modules

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
MAX_MODULE_SIZE=300
WARNING_THRESHOLD=250
RECOMMENDED_SIZE=250

# Get file path from tool arguments
if [ -z "${TOOL_ARGS:-}" ]; then
    if [ $# -eq 0 ]; then
        exit 0  # No args, skip check
    fi
    FILE_PATH="$1"
else
    if command -v jq &> /dev/null; then
        FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.file_path // empty')
        if [ -z "$FILE_PATH" ]; then
            exit 0  # No file_path, skip check
        fi
    else
        exit 0  # No jq, skip check
    fi
fi

# Check if file is a code file (not docs/tests/configs)
FILE_EXT="${FILE_PATH##*.}"
case "$FILE_EXT" in
    py|js|ts|tsx|jsx|go|rs|java|cpp|c|h|hpp|rb|php|cs)
        # This is a code file, check size
        ;;
    md|txt|json|yaml|yml|toml|sh|bash|rst|adoc)
        # Documentation/config file, skip check
        exit 0
        ;;
    *)
        # Unknown extension, skip check
        exit 0
        ;;
esac

# Check if file exists and get line count
if [ -f "$FILE_PATH" ]; then
    LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')

    echo "═══════════════════════════════════════════════════════════════════════"
    echo "📏 MODULE BOUNDARY CHECK (RULE 20 - Proactive Enforcement)"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "File: $FILE_PATH"
    echo "Current size: $LINE_COUNT lines"
    echo "Limit: $MAX_MODULE_SIZE lines (recommended: $RECOMMENDED_SIZE)"
    echo ""

    if [ "$LINE_COUNT" -gt "$MAX_MODULE_SIZE" ]; then
        echo -e "${RED}❌ BLOCKED: Module exceeds maximum size limit${NC}"
        echo ""
        echo "This file has $LINE_COUNT lines (limit: $MAX_MODULE_SIZE)"
        echo ""
        echo "RULE 20 requires modules to be 200-300 lines for:"
        echo "  • Better maintainability"
        echo "  • Easier code review"
        echo "  • Single responsibility principle"
        echo "  • Reduced cognitive load"
        echo ""
        echo "REQUIRED ACTION:"
        echo "  1. Split this module into smaller sub-modules"
        echo "  2. Extract large functions into separate files"
        echo "  3. Create a module hierarchy (main + helpers)"
        echo ""
        echo "EXAMPLE STRUCTURE:"
        echo "  ${FILE_PATH%.${FILE_EXT}}/"
        echo "    ├── __init__.${FILE_EXT}  (main interface, <100 lines)"
        echo "    ├── core.${FILE_EXT}      (core logic, <300 lines)"
        echo "    ├── utils.${FILE_EXT}     (utilities, <300 lines)"
        echo "    └── helpers.${FILE_EXT}   (helpers, <300 lines)"
        echo ""
        echo "═══════════════════════════════════════════════════════════════════════"
        exit 2  # BLOCK operation (Claude Code enforcement signal)

    elif [ "$LINE_COUNT" -ge "$WARNING_THRESHOLD" ]; then
        echo -e "${YELLOW}⚠️  WARNING: Module approaching size limit${NC}"
        echo ""
        echo "This file has $LINE_COUNT lines (limit: $MAX_MODULE_SIZE)"
        echo ""
        echo "Consider splitting soon to maintain RULE 20 compliance"
        echo ""
        echo "Proceeding with operation..."
        echo "═══════════════════════════════════════════════════════════════════════"
        exit 0  # Allow operation with warning

    else
        echo -e "${GREEN}✅ Module size within limits ($LINE_COUNT/$MAX_MODULE_SIZE lines)${NC}"
        echo "═══════════════════════════════════════════════════════════════════════"
        exit 0  # Allow operation
    fi
else
    # New file, will check after Write
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "📏 MODULE BOUNDARY CHECK (RULE 20 - Pre-Write)"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "File: $FILE_PATH (new file)"
    echo ""
    echo "ℹ️  Creating new file - will validate size after Write"
    echo "   Remember: Keep modules to 200-300 lines (RULE 20)"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # Allow new file creation
fi
