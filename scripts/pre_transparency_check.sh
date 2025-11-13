#!/bin/bash
# pre_transparency_check.sh - PreToolUse hook for RULE 12 monitoring
# Purpose: Monitor transparency (warn if exposing framework mechanics to users)
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before operations
#
# MONITORING (behavioral rule):
# - Scans for framework-specific terms in outputs/commits
# - Warns if exposing internal mechanics
# - Cannot block (behavioral rule), only provides reminders

set -euo pipefail

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${PWD}"

# Framework-specific patterns that should stay transparent
TRANSPARENCY_VIOLATIONS=(
    "checkpoint.*box"
    "state.*tracking.*required"
    "RULE [0-9]+ requires"
    "\.claude/plan\.json"
    "master_state\.json"
    "context_tracking\.json"
    "33-point.*checklist"
    "framework.*enforcement"
    "PreToolUse hook"
    "PostToolUse hook"
)

# Only check on Bash operations (especially git commits) and periodically
if [ -z "${TOOL_ARGS:-}" ]; then
    # Check if this is a command we care about
    if [ $# -gt 0 ]; then
        COMMAND="$*"
        # Only check git commits and output-generating commands
        if [[ ! "$COMMAND" =~ (git.*commit|echo|cat.*README) ]]; then
            exit 0  # Not a relevant command, skip check
        fi
    else
        exit 0  # No args, skip check
    fi
fi

# Periodically check operation log for transparency violations
LOG_FILE="${PROJECT_ROOT}/logs/operation_log.txt"
if [ -f "$LOG_FILE" ]; then
    TOTAL_OPS=$(grep -c "^[0-9]" "$LOG_FILE" 2>/dev/null || echo "0")
    CHECK_INTERVAL=12
    SHOULD_CHECK=$((TOTAL_OPS % CHECK_INTERVAL))

    if [ "$SHOULD_CHECK" -ne 0 ]; then
        exit 0  # Not time to check yet
    fi

    # Check recent log entries for violations
    RECENT_LOG=$(tail -30 "$LOG_FILE" 2>/dev/null || echo "")
    VIOLATIONS_FOUND=false
    VIOLATED_PATTERNS=""

    for pattern in "${TRANSPARENCY_VIOLATIONS[@]}"; do
        if echo "$RECENT_LOG" | grep -qiE "$pattern" 2>/dev/null; then
            VIOLATIONS_FOUND=true
            VIOLATED_PATTERNS="${VIOLATED_PATTERNS}\n  • $pattern"
        fi
    done

    if [ "$VIOLATIONS_FOUND" = true ]; then
        echo "═══════════════════════════════════════════════════════════════════════"
        echo "👁️  TRANSPARENCY CHECK (RULE 12 - Monitoring)"
        echo "═══════════════════════════════════════════════════════════════════════"
        echo ""
        echo -e "${YELLOW}⚠️  REMINDER: Keep framework mechanics transparent${NC}"
        echo ""
        echo "Detected framework-specific patterns in recent operations:"
        echo -e "$VIOLATED_PATTERNS"
        echo ""
        echo "RULE 12 requires:"
        echo "  • Framework operates invisibly to end users"
        echo "  • Don't mention internal mechanics in user output"
        echo "  • Don't expose .claude/ directory structure"
        echo "  • Don't reference checkpoint/validation systems"
        echo "  • Don't explain RULE numbers or enforcement"
        echo ""
        echo "RECOMMENDED:"
        echo "  • Focus on user's actual project needs"
        echo "  • Use natural language, not framework terms"
        echo "  • Keep technical implementation invisible"
        echo ""
        echo "This is a REMINDER, not a blocker."
        echo "═══════════════════════════════════════════════════════════════════════"
        exit 0  # Warning only, don't block
    fi
fi

# All good, no transparency violations detected
exit 0
