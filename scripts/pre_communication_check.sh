#!/bin/bash
# pre_communication_check.sh - PreToolUse hook for RULE 6 monitoring
# Purpose: Monitor communication protocol (warn about framework exposure)
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before operations
#
# MONITORING (behavioral rule):
# - Scans recent output for framework-specific terms
# - Warns if exposing framework mechanics to user
# - Cannot block (behavioral rule), only provides reminders

set -euo pipefail

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${PWD}"
LOG_FILE="${PROJECT_ROOT}/logs/operation_log.txt"

# Framework-specific terms that should not appear in user-facing output
FRAMEWORK_TERMS=(
    "\.claude/plan\.json"
    "master_state\.json"
    "context_tracking\.json"
    "PROTOCOL_CORE_RULES"
    "RULE [0-9]+:"
    "checkpoint validation"
    "33-point checklist"
    "HTDAG"
    "hierarchical decomposition"
    "module boundary"
)

# Only check periodically (every 10 operations) to avoid spam
if [ -f "$LOG_FILE" ]; then
    TOTAL_OPS=$(grep -c "^[0-9]" "$LOG_FILE" 2>/dev/null || echo "0")
    CHECK_INTERVAL=10
    SHOULD_CHECK=$((TOTAL_OPS % CHECK_INTERVAL))

    if [ "$SHOULD_CHECK" -ne 0 ]; then
        exit 0  # Not time to check yet
    fi
fi

# Check recent operation log for framework exposure
# This is a simple check - in production, would scan actual output
EXPOSURE_FOUND=false
EXPOSED_TERMS=""

if [ -f "$LOG_FILE" ]; then
    # Get last 20 log entries
    RECENT_LOG=$(tail -20 "$LOG_FILE" 2>/dev/null || echo "")

    for term in "${FRAMEWORK_TERMS[@]}"; do
        if echo "$RECENT_LOG" | grep -qE "$term" 2>/dev/null; then
            EXPOSURE_FOUND=true
            EXPOSED_TERMS="${EXPOSED_TERMS}\n  • $term"
        fi
    done
fi

if [ "$EXPOSURE_FOUND" = true ]; then
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "💬 COMMUNICATION PROTOCOL CHECK (RULE 6 - Monitoring)"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}⚠️  REMINDER: Keep framework transparent to user${NC}"
    echo ""
    echo "Detected framework-specific terms in recent operations:"
    echo -e "$EXPOSED_TERMS"
    echo ""
    echo "RULE 6 requires:"
    echo "  • Avoid mentioning internal framework mechanics"
    echo "  • Use natural language, not framework jargon"
    echo "  • Don't reference .claude/ directory structure"
    echo "  • Don't explain checkpoint/validation systems"
    echo ""
    echo "RECOMMENDED:"
    echo "  • Talk about 'implementing features', not 'modules'"
    echo "  • Say 'checking progress', not 'checkpoint validation'"
    echo "  • Focus on user's project, not framework internals"
    echo ""
    echo "This is a REMINDER, not a blocker."
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # Warning only, don't block
fi

# All good, no framework exposure detected
exit 0
