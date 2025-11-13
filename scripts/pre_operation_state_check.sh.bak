#!/bin/bash
# pre_operation_state_check.sh - PreToolUse hook for RULE 14 enforcement
# Purpose: Verify state files updated BEFORE allowing next operation (proactive)
# Version: 1.0.0 (New - addresses persistent RULE 14 violations)
# Usage: Called automatically by PreToolUse hook before Read/Write/Edit/Bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if context_tracking.json exists
if [ ! -f "data/state/context_tracking.json" ]; then
    echo -e "${YELLOW}⚠️  No context_tracking.json found (allowing operation)${NC}"
    exit 0
fi

# Get timestamp of last state update
LAST_UPDATE=$(jq -r '.last_update // "1970-01-01T00:00:00Z"' data/state/context_tracking.json)

# Convert to epoch (handle both macOS and Linux date formats)
if date --version >/dev/null 2>&1; then
    # GNU date (Linux)
    LAST_EPOCH=$(date -d "$LAST_UPDATE" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
else
    # BSD date (macOS)
    LAST_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_UPDATE" "+%s" 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
fi

# Calculate gap (seconds since last update)
GAP=$((NOW_EPOCH - LAST_EPOCH))

# Threshold: 60 seconds (if state files not updated in 60s, they're stale)
THRESHOLD=60

if [ $GAP -gt $THRESHOLD ]; then
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${RED}❌ BLOCKED: RULE 14 VIOLATION PREVENTED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${RED}State files not updated in ${GAP} seconds (threshold: ${THRESHOLD}s)${NC}"
    echo ""
    echo "RULE 14 REQUIRES: Update state files after EVERY operation"
    echo ""
    echo "Last state update: $LAST_UPDATE"
    echo "Time since update: ${GAP}s"
    echo ""
    echo "REQUIRED ACTIONS (must complete before next operation):"
    echo "  1. Update data/state/master_state.json (current phase, modules, timestamp)"
    echo "  2. Update data/state/context_tracking.json (operations count, context %, timestamp)"
    echo "  3. Log to logs/operation_log.txt (operation type, timestamp)"
    echo ""
    echo "After updating state files, this operation will be allowed."
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${RED}This is PROACTIVE enforcement - preventing violations before they occur.${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"

    # Exit with error to block operation
    exit 1
fi

# State files updated recently - allow operation
# (Silent success - no output needed)
exit 0
