#!/bin/bash
# pre_context_check.sh - PreToolUse hook for RULE 10 enforcement
# Purpose: Block operations if context exceeds 75% emergency threshold (proactive)
# Version: 1.0.0 (New - prevents context overflow)
# Usage: Called automatically by PreToolUse hook before operations

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if context_tracking.json exists
if [ ! -f "data/state/context_tracking.json" ]; then
    # No tracking file - allow operation
    exit 0
fi

# Get current context percentage
CONTEXT_PCT=$(jq -r '.usage_pct // 0' data/state/context_tracking.json)
EMERGENCY_THRESHOLD=$(jq -r '.threshold_emergency // 75.0' data/state/context_tracking.json)

# Use bc for floating point comparison (if available), otherwise use awk
if command -v bc &> /dev/null; then
    EXCEEDS=$(echo "$CONTEXT_PCT > $EMERGENCY_THRESHOLD" | bc -l)
else
    EXCEEDS=$(awk -v pct="$CONTEXT_PCT" -v thresh="$EMERGENCY_THRESHOLD" 'BEGIN { print (pct > thresh) ? 1 : 0 }')
fi

if [ "$EXCEEDS" -eq 1 ]; then
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${RED}❌ BLOCKED: RULE 10 VIOLATION PREVENTED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo -e "${RED}Context at ${CONTEXT_PCT}% exceeds emergency threshold (${EMERGENCY_THRESHOLD}%)${NC}"
    echo ""
    echo "RULE 10 REQUIRES: Create checkpoint BEFORE continuing"
    echo ""
    echo "REQUIRED ACTIONS:"
    echo "  1. Create checkpoint with current state"
    echo "  2. Commit all changes to git"
    echo "  3. Create recovery prompt for next session"
    echo "  4. Start fresh session with reduced context"
    echo ""
    echo "Use: /checkpoint command to create checkpoint"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
    echo -e "${RED}This is PROACTIVE enforcement - preventing context overflow.${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"

    # Exit with error to block operation
    exit 1
fi

# Context within safe limits - allow operation
exit 0
