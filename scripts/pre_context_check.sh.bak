#!/bin/bash
# pre_context_check.sh - PreToolUse hook for RULE 10 enforcement
# Purpose: Block operations if context exceeds emergency threshold (proactive)
# Version: 2.0.0 (Enhanced - backwards compatibility + auto-detection)
# Usage: Called automatically by PreToolUse hook before operations
#
# ENHANCEMENTS (v2.0.0):
# - Backwards compatibility: 35% for old projects (created before 2025-01-12)
# - Auto-detection: Checks project age and explicit configuration
# - Priority: Explicit config > Project age > Defaults
# - New projects: 65% primary, 75% emergency (research-based)

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

# Determine appropriate thresholds with backwards compatibility
# Priority order:
# 1. Explicit user configuration (config/context_config.json or context_tracking.json)
# 2. Project age detection (old projects use 35%, new use 65%)
# 3. Default (65% for new projects)

PRIMARY_THRESHOLD=65
EMERGENCY_THRESHOLD=75

# Check 1: Explicit configuration in config file
if [ -f "config/context_config.json" ]; then
    EXPLICIT_PRIMARY=$(jq -r '.threshold_critical // empty' config/context_config.json)
    EXPLICIT_EMERGENCY=$(jq -r '.threshold_emergency // empty' config/context_config.json)

    if [ -n "$EXPLICIT_PRIMARY" ]; then
        PRIMARY_THRESHOLD=$EXPLICIT_PRIMARY
    fi
    if [ -n "$EXPLICIT_EMERGENCY" ]; then
        EMERGENCY_THRESHOLD=$EXPLICIT_EMERGENCY
    fi
# Check 2: Explicit configuration in context_tracking.json
elif [ -f "data/state/context_tracking.json" ]; then
    EXPLICIT_PRIMARY=$(jq -r '.threshold_critical // empty' data/state/context_tracking.json)
    EXPLICIT_EMERGENCY=$(jq -r '.threshold_emergency // empty' data/state/context_tracking.json)

    if [ -n "$EXPLICIT_PRIMARY" ]; then
        PRIMARY_THRESHOLD=$EXPLICIT_PRIMARY
    fi
    if [ -n "$EXPLICIT_EMERGENCY" ]; then
        EMERGENCY_THRESHOLD=$EXPLICIT_EMERGENCY
    fi
fi

# Check 3: Project age detection (for backwards compatibility)
# If no explicit config, detect if this is an old project (v3.x)
if [ "$PRIMARY_THRESHOLD" -eq 65 ]; then
    # Check master_state.json for created_before field
    if [ -f "data/state/master_state.json" ]; then
        PROJECT_DATE=$(jq -r '.created_before // empty' data/state/master_state.json)
        if [ -n "$PROJECT_DATE" ]; then
            # Parse date and compare to 2025-01-12
            if [[ "$PROJECT_DATE" < "2025-01-12" ]]; then
                # Old project - use conservative thresholds
                PRIMARY_THRESHOLD=35
                EMERGENCY_THRESHOLD=40
            fi
        fi
    fi

    # Check git for first commit date
    if [ -d ".git" ] && [ "$PRIMARY_THRESHOLD" -eq 65 ]; then
        FIRST_COMMIT_DATE=$(git log --reverse --format=%ci | head -1 | cut -d' ' -f1)
        if [ -n "$FIRST_COMMIT_DATE" ] && [[ "$FIRST_COMMIT_DATE" < "2025-01-12" ]]; then
            # Old project - use conservative thresholds
            PRIMARY_THRESHOLD=35
            EMERGENCY_THRESHOLD=40
        fi
    fi
fi

# Get current context percentage
CONTEXT_PCT=$(jq -r '.usage_pct // 0' data/state/context_tracking.json)

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
    echo "Thresholds in use:"
    echo "  - Primary checkpoint: ${PRIMARY_THRESHOLD}%"
    echo "  - Emergency checkpoint: ${EMERGENCY_THRESHOLD}%"
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
