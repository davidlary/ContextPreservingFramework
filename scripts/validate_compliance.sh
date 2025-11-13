#!/bin/bash
# validate_compliance.sh - Verify compliance with Framework Rules 2, 14-17
# Usage: ./scripts/validate_compliance.sh [operation_type]
# Returns: 0 if compliant, 1 if non-compliant (with error messages)
# Version: 2.0.0 - Added RULE 2 (file authorization) enforcement

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OPERATION_TYPE="${1:-general}"
ERRORS=0

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 COMPLIANCE VALIDATION (Framework Rules 2, 14-17)"
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

# RULE 2: Named Files Only - Verify file authorization (NEW - addresses user complaint)
echo ""
echo "Checking RULE 2: Named Files Only (File Authorization)..."

if [ ! -f "data/state/file_manifest.json" ]; then
    echo -e "${YELLOW}⚠️  INFO: file_manifest.json not found (skipping RULE 2 validation)${NC}"
    echo "   To enable RULE 2 enforcement, create data/state/file_manifest.json"
else
    # Check if manifest is valid JSON
    if ! jq empty data/state/file_manifest.json 2>/dev/null; then
        echo -e "${RED}❌ VIOLATION: file_manifest.json is invalid JSON${NC}"
        ((ERRORS++))
    else
        ENFORCEMENT_ACTIVE=$(jq -r '.enforcement_active' data/state/file_manifest.json)
        if [ "$ENFORCEMENT_ACTIVE" = "true" ]; then
            # Check recent git changes for unauthorized file creation
            if command -v git &> /dev/null && [ -d ".git" ]; then
                # Get list of newly created files (untracked + added)
                UNTRACKED_FILES=$(git ls-files --others --exclude-standard 2>/dev/null || echo "")
                RECENTLY_ADDED=$(git diff --name-only --diff-filter=A --cached 2>/dev/null || echo "")
                NEW_FILES=$(echo -e "$UNTRACKED_FILES\n$RECENTLY_ADDED" | grep -v '^$' | sort -u)

                if [ -n "$NEW_FILES" ]; then
                    UNAUTHORIZED_COUNT=0
                    while IFS= read -r file; do
                        [ -z "$file" ] && continue

                        # Check if file is in authorized_files
                        IS_AUTHORIZED=$(jq -r --arg file "$file" '.authorized_files | index($file) != null' data/state/file_manifest.json)

                        # Check if file matches always_allowed_patterns
                        MATCHES_PATTERN="false"
                        PATTERNS=$(jq -r '.always_allowed_patterns[]' data/state/file_manifest.json 2>/dev/null)
                        for pattern in $PATTERNS; do
                            if [[ "$file" == $pattern ]]; then
                                MATCHES_PATTERN="true"
                                break
                            fi
                        done

                        # Check if extension is allowed
                        EXTENSION="${file##*.}"
                        IS_EXTENSION_ALLOWED=$(jq -r --arg ext ".$EXTENSION" '.always_allowed_extensions | index($ext) != null' data/state/file_manifest.json)

                        if [ "$IS_AUTHORIZED" = "false" ] && [ "$MATCHES_PATTERN" = "false" ] && [ "$IS_EXTENSION_ALLOWED" = "false" ]; then
                            echo -e "${RED}❌ VIOLATION: Unauthorized file created: $file${NC}"
                            echo "   RULE 2 REQUIRES: Only create files specified in manifest or matching allowed patterns"
                            echo "   REQUIRED ACTION: Either:"
                            echo "   1. DELETE $file and UPDATE existing file instead, OR"
                            echo "   2. ASK user for approval and add to manifest"
                            ((UNAUTHORIZED_COUNT++))
                            ((ERRORS++))
                        fi
                    done <<< "$NEW_FILES"

                    if [ "$UNAUTHORIZED_COUNT" -eq 0 ]; then
                        echo -e "${GREEN}✅ File authorization: All new files authorized${NC}"
                    fi
                else
                    echo -e "${GREEN}✅ File authorization: No new files created${NC}"
                fi
            else
                echo "   Git not available (skipping new file detection)"
            fi
        else
            echo "   File authorization enforcement disabled in manifest"
        fi
    fi
fi

# RULE 15: Visible Tracking - Check if checkpoint box should be displayed
echo ""
echo "Checking RULE 15: Visible Tracking..."
echo "   RULE 15 REQUIRES: Display checkpoint box BEFORE completing ANY response"
echo "   NOTE: This validation runs after tool calls. Claude must display box in response."
echo -e "${GREEN}✅ Verification: This script confirms state files updated (checkpoint box required)${NC}"

# RULE 16: Git Commit Protocol - Check for uncommitted changes
echo ""
echo "Checking RULE 16: Git Commit Protocol..."
if command -v git &> /dev/null && [ -d ".git" ]; then
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "")
    if [ -n "$GIT_STATUS" ]; then
        echo -e "${YELLOW}⚠️  WARNING: Uncommitted changes detected${NC}"
        echo "   RULE 16 REQUIRES: Commit before displaying checkpoint box"
        echo "   Files with uncommitted changes:"
        git status --short | head -10
        echo ""
        echo "   REQUIRED ACTION: git add -A && git commit -m 'Update state' && git push"
    else
        echo -e "${GREEN}✅ Git working tree: CLEAN (no uncommitted changes)${NC}"
    fi
else
    echo "   Git not available or not a git repository (skipping git check)"
fi

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
