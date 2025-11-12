#!/bin/bash
# validate_compliance.sh - Verify compliance with Framework Rules 14-17
# Usage: ./scripts/validate_compliance.sh [operation_type]
# Returns: 0 if compliant, 1 if non-compliant (with error messages)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OPERATION_TYPE="${1:-general}"
ERRORS=0

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 COMPLIANCE VALIDATION (Framework Rules 14-17)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "Operation type: $OPERATION_TYPE"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# RULE 14: State Tracking - Verify state files exist and are valid
echo "Checking RULE 14: State Tracking..."

if [ ! -f "data/state/master_state.json" ]; then
    echo -e "${RED}❌ VIOLATION: data/state/master_state.json missing${NC}"
    echo "   RULE 14 REQUIRES: State files must exist and be updated after EVERY operation"
    ((ERRORS++))
else
    # Verify valid JSON
    if ! jq empty data/state/master_state.json 2>/dev/null; then
        echo -e "${RED}❌ VIOLATION: master_state.json is invalid JSON${NC}"
        ((ERRORS++))
    else
        # Check timestamp is recent (within last 5 minutes)
        LAST_UPDATE=$(jq -r '.last_update' data/state/master_state.json)
        LAST_UPDATE_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_UPDATE" +%s 2>/dev/null || echo 0)
        NOW_EPOCH=$(date +%s)
        AGE_SECONDS=$((NOW_EPOCH - LAST_UPDATE_EPOCH))

        if [ "$AGE_SECONDS" -gt 300 ]; then
            echo -e "${YELLOW}⚠️  WARNING: master_state.json last updated ${AGE_SECONDS}s ago (>5 min)${NC}"
            echo "   RULE 14 REQUIRES: Update after EVERY operation"
            echo "   Last update: $LAST_UPDATE"
        else
            echo -e "${GREEN}✅ master_state.json: Valid and recent${NC}"
        fi
    fi
fi

if [ ! -f "data/state/context_tracking.json" ]; then
    echo -e "${RED}❌ VIOLATION: data/state/context_tracking.json missing${NC}"
    ((ERRORS++))
else
    if ! jq empty data/state/context_tracking.json 2>/dev/null; then
        echo -e "${RED}❌ VIOLATION: context_tracking.json is invalid JSON${NC}"
        ((ERRORS++))
    else
        USAGE_PCT=$(jq -r '.usage_pct' data/state/context_tracking.json)
        echo -e "${GREEN}✅ context_tracking.json: Valid (${USAGE_PCT}% context)${NC}"

        # Check if approaching thresholds
        if (( $(echo "$USAGE_PCT > 65" | bc -l) )); then
            echo -e "${YELLOW}⚠️  WARNING: Context usage ${USAGE_PCT}% exceeds 65% threshold${NC}"
            echo "   RULE 5.2 REQUIRES: Checkpoint at 65%, emergency at 75%"
        fi
    fi
fi

# Verify operation log exists and was recently updated
echo ""
echo "Checking operation log..."
if [ ! -f "logs/operation_log.txt" ]; then
    echo -e "${RED}❌ VIOLATION: logs/operation_log.txt missing${NC}"
    echo "   RULE 14 REQUIRES: Log every operation"
    ((ERRORS++))
else
    # Check if log was updated in last 5 minutes
    if [ "$(uname)" = "Darwin" ]; then
        LOG_MOD_TIME=$(stat -f %m logs/operation_log.txt)
    else
        LOG_MOD_TIME=$(stat -c %Y logs/operation_log.txt)
    fi
    NOW=$(date +%s)
    LOG_AGE=$((NOW - LOG_MOD_TIME))

    if [ "$LOG_AGE" -gt 300 ]; then
        echo -e "${YELLOW}⚠️  WARNING: operation_log.txt not updated in ${LOG_AGE}s (>5 min)${NC}"
        echo "   RULE 14 REQUIRES: Log after EVERY operation"
    else
        echo -e "${GREEN}✅ operation_log.txt: Recently updated${NC}"
    fi
fi

# RULE 15: Visible Tracking - Check if checkpoint box should be displayed
echo ""
echo "Checking RULE 15: Visible Tracking..."
echo "   RULE 15 REQUIRES: Display checkpoint box BEFORE completing ANY response"
echo "   NOTE: This validation runs after tool calls. Claude must display box in response."
echo -e "${GREEN}✅ Verification: This script confirms state files updated (checkpoint box required)${NC}"

# RULE 17: Next Steps - Reminder
echo ""
echo "Checking RULE 17: Next Steps..."
echo "   RULE 17 REQUIRES: Display next steps block at END of EVERY response"
echo "   NOTE: Claude must include next steps in final response"
echo -e "${GREEN}✅ Reminder: Next steps block required in response${NC}"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ COMPLIANCE CHECK: PASSED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${RED}❌ COMPLIANCE CHECK: FAILED (${ERRORS} violations)${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    echo ""
    echo "REQUIRED ACTIONS:"
    echo "1. Update data/state/master_state.json with current state"
    echo "2. Update data/state/context_tracking.json with token count"
    echo "3. Append operation to logs/operation_log.txt"
    echo "4. Display checkpoint box in response (RULE 15)"
    echo "5. Display next steps in response (RULE 17)"
    echo ""
    echo "These are MANDATORY (Tier 1 Critical) rules that MUST be followed."
    exit 1
fi
