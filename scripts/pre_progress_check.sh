#!/bin/bash
# pre_progress_check.sh - PreToolUse hook for RULE 4 monitoring
# Purpose: Monitor progress visibility (warn if no recent progress updates)
# Version: 1.0.0 (Created for v4.5.0)
# Usage: Called automatically by PreToolUse hook before operations
#
# MONITORING (behavioral rule):
# - Checks if progress updates were recently logged
# - Warns if no progress display in last N operations
# - Cannot block (behavioral rule), only provides reminders

set -euo pipefail

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${PWD}"
STATE_FILE="${PROJECT_ROOT}/data/state/master_state.json"
LOG_FILE="${PROJECT_ROOT}/logs/operation_log.txt"
WARNING_INTERVAL=5  # Warn every 5 operations if no progress shown

# Check if state tracking is initialized
if [ ! -f "$STATE_FILE" ]; then
    # State tracking not initialized, skip check
    exit 0
fi

# Check if operation log exists
if [ ! -f "$LOG_FILE" ]; then
    # No log file yet, skip check
    exit 0
fi

# Count operations since last progress indicator
# Progress indicators are logged with "PROGRESS:" prefix
TOTAL_OPS=$(grep -c "^[0-9]" "$LOG_FILE" 2>/dev/null || echo "0")
LAST_PROGRESS=$(grep -n "PROGRESS:" "$LOG_FILE" 2>/dev/null | tail -1 | cut -d: -f1 || echo "0")

if [ "$LAST_PROGRESS" = "0" ]; then
    # No progress indicators found yet
    OPS_SINCE_PROGRESS="$TOTAL_OPS"
else
    # Calculate operations since last progress
    OPS_SINCE_PROGRESS=$((TOTAL_OPS - LAST_PROGRESS))
fi

# Only warn every WARNING_INTERVAL operations
SHOULD_WARN=$((OPS_SINCE_PROGRESS % WARNING_INTERVAL))

if [ "$OPS_SINCE_PROGRESS" -ge "$WARNING_INTERVAL" ] && [ "$SHOULD_WARN" -eq 0 ]; then
    echo "═══════════════════════════════════════════════════════════════════════"
    echo "📊 PROGRESS VISIBILITY CHECK (RULE 4 - Monitoring)"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${YELLOW}⚠️  REMINDER: Display progress to user${NC}"
    echo ""
    echo "Operations since last progress update: $OPS_SINCE_PROGRESS"
    echo ""
    echo "RULE 4 requires:"
    echo "  • Show progress every few operations"
    echo "  • Display what module you're working on"
    echo "  • Update user on completion status"
    echo ""
    echo "RECOMMENDED:"
    echo "  • Use visible progress indicators"
    echo "  • Display checkpoint boxes regularly"
    echo "  • Show completion percentage"
    echo "  • List completed tasks"
    echo ""
    echo "This is a REMINDER, not a blocker."
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0  # Warning only, don't block
fi

# All good, no warning needed
exit 0
