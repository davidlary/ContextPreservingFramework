#!/bin/bash
# pre_decomposition_check.sh - PreToolUse hook for RULE 8 monitoring
# Purpose: Monitor hierarchical decomposition (warn if working without plan)
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before Write/Edit operations
#
# MONITORING (behavioral rule):
# - Checks if .claude/plan.json exists for projects
# - Warns if working without hierarchical plan
# - Cannot block (behavioral rule), only provides reminders

set -euo pipefail

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${PWD}"
PLAN_FILE="${PROJECT_ROOT}/.claude/plan.json"
STATE_FILE="${PROJECT_ROOT}/data/state/master_state.json"

# Only check on Write/Edit operations (when creating/modifying code)
if [ -z "${TOOL_ARGS:-}" ]; then
    # No tool args, skip check
    exit 0
fi

# Check if this is a Write or Edit operation
if command -v jq &> /dev/null; then
    TOOL_NAME=$(echo "$TOOL_ARGS" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
    if [ -z "$TOOL_NAME" ]; then
        # Try to infer from file_path presence
        FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.file_path // empty' 2>/dev/null || echo "")
        if [ -z "$FILE_PATH" ]; then
            exit 0  # Not a file operation, skip check
        fi
    fi
else
    exit 0  # No jq, skip check
fi

# Check if this is a large/complex project (has state tracking)
if [ ! -f "$STATE_FILE" ]; then
    # Not using framework, skip check
    exit 0
fi

# Check if plan exists
if [ ! -f "$PLAN_FILE" ]; then
    # Check operation count to decide if we should warn
    LOG_FILE="${PROJECT_ROOT}/logs/operation_log.txt"
    if [ -f "$LOG_FILE" ]; then
        TOTAL_OPS=$(grep -c "^[0-9]" "$LOG_FILE" 2>/dev/null || echo "0")

        # Only warn if significant work has been done (>10 operations)
        if [ "$TOTAL_OPS" -gt 10 ]; then
            # Only warn periodically (every 15 operations)
            CHECK_INTERVAL=15
            SHOULD_CHECK=$((TOTAL_OPS % CHECK_INTERVAL))

            if [ "$SHOULD_CHECK" -eq 0 ]; then
                echo "═══════════════════════════════════════════════════════════════════════"
                echo "🗂️  HIERARCHICAL DECOMPOSITION CHECK (RULE 8 - Monitoring)"
                echo "═══════════════════════════════════════════════════════════════════════"
                echo ""
                echo -e "${YELLOW}⚠️  REMINDER: Consider creating a hierarchical plan${NC}"
                echo ""
                echo "Project has state tracking but no .claude/plan.json"
                echo ""
                echo "RULE 8 encourages hierarchical decomposition:"
                echo "  • Break project into components"
                echo "  • Identify module dependencies"
                echo "  • Create execution order"
                echo "  • Track progress systematically"
                echo ""
                echo "RECOMMENDED:"
                echo "  • Create .claude/plan.json with project structure"
                echo "  • Define modules and their dependencies"
                echo "  • Use hierarchical task breakdown"
                echo ""
                echo "This is a REMINDER, not a blocker."
                echo "═══════════════════════════════════════════════════════════════════════"
                exit 0  # Warning only, don't block
            fi
        fi
    fi
    exit 0  # No plan but not enough operations to warn
fi

# Plan exists, all good
exit 0
