#!/bin/bash
#
# pre_plan_adherence_check.sh - Plan/Spec Adherence Enforcement
#
# Purpose: Validate operations against user-specified plan and constraints
# Trigger: PreToolUse hook (before Write/Edit/Bash operations)
# Rule: NEW - Plan Adherence (addresses user complaint about not following specs)
# Version: 1.0.0
# Date: 2025-11-13
#
# CRITICAL FIX: Ensures Claude follows user-specified:
# - File lists (update X, don't create Y)
# - Module plans (work on Module 1.2, not 1.3)
# - Constraints (use existing DB code, don't create new)
# - Prohibited actions (don't refactor without approval)
#
# How it works:
# 1. Reads .cpf/plan.json (if exists)
# 2. Reads project CLAUDE.md for inline constraints
# 3. Validates operation against plan
# 4. BLOCKS major deviations (exit 2)
# 5. WARNS minor deviations (exit 0 + warning)
#
# Exit codes:
# 0 - Allow operation (adheres to plan or minor deviation)
# 2 - BLOCK operation (major plan violation)
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get operation details from environment
TOOL_NAME="${TOOL_NAME:-unknown}"
FILE_PATH="${FILE_PATH:-}"
COMMAND="${COMMAND:-}"

# Paths
PLAN_FILE=".cpf/plan.json"
CLAUDE_MD="CLAUDE.md"

echo "═══════════════════════════════════════════════════════════════════════"
echo "📋 PLAN ADHERENCE CHECK"
echo "═══════════════════════════════════════════════════════════════════════"
echo "Tool: $TOOL_NAME"
[ -n "$FILE_PATH" ] && echo "File: $FILE_PATH"
[ -n "$COMMAND" ] && echo "Command: $COMMAND"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Check if plan.json exists
if [ ! -f "$PLAN_FILE" ]; then
    echo -e "${BLUE}[INFO]${NC} No plan.json found - Plan adherence not enforced"
    echo "       To enable plan tracking, create $PLAN_FILE with:"
    echo "       {\"authorized_files\": [...], \"current_module\": \"...\", \"constraints\": [...]}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}[WARN]${NC} jq not available - Cannot parse plan.json"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

echo "✓ Found plan.json - Validating operation..."

# Read plan data
PLAN_ENABLED=$(jq -r '.enabled // true' "$PLAN_FILE")
if [ "$PLAN_ENABLED" != "true" ]; then
    echo -e "${BLUE}[INFO]${NC} Plan adherence disabled in plan.json"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Parse plan components
AUTHORIZED_FILES=$(jq -r '.authorized_files[]? // empty' "$PLAN_FILE")
CURRENT_MODULE=$(jq -r '.current_module // empty' "$PLAN_FILE")
CONSTRAINTS=$(jq -r '.constraints[]? // empty' "$PLAN_FILE")
PROHIBITED_ACTIONS=$(jq -r '.prohibited_actions[]? // empty' "$PLAN_FILE")

# Validation 1: File authorization (for Write/Edit)
if [ "$TOOL_NAME" = "Write" ] || [ "$TOOL_NAME" = "Edit" ]; then
    if [ -n "$FILE_PATH" ] && [ -n "$AUTHORIZED_FILES" ]; then
        FILE_AUTHORIZED=false
        while IFS= read -r authorized_file; do
            if [ "$FILE_PATH" = "$authorized_file" ]; then
                FILE_AUTHORIZED=true
                break
            fi
        done <<< "$AUTHORIZED_FILES"

        if [ "$FILE_AUTHORIZED" != "true" ]; then
            # Check if file matches any pattern
            while IFS= read -r authorized_file; do
                # Simple glob matching
                if [[ "$FILE_PATH" == $authorized_file ]]; then
                    FILE_AUTHORIZED=true
                    break
                fi
            done <<< "$AUTHORIZED_FILES"
        fi

        if [ "$FILE_AUTHORIZED" != "true" ]; then
            echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
            echo -e "❌ BLOCKED: File not in authorized list"
            echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${RED}PLAN VIOLATION: $FILE_PATH not authorized in plan.json${NC}"
            echo ""
            echo "Authorized files:"
            while IFS= read -r file; do
                echo "  ✓ $file"
            done <<< "$AUTHORIZED_FILES"
            echo ""
            echo "REQUIRED ACTION:"
            echo "  1. Update plan.json to include this file:"
            echo "     jq '.authorized_files += [\"$FILE_PATH\"]' $PLAN_FILE"
            echo "  2. OR work on an authorized file instead"
            echo ""
            echo -e "${RED}OPERATION BLOCKED - File not authorized in plan${NC}"
            echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
            exit 2  # EXIT CODE 2: BLOCKS operation
        fi
    fi
fi

# Validation 2: Prohibited actions (for any tool)
if [ -n "$PROHIBITED_ACTIONS" ]; then
    OPERATION_DESC="$TOOL_NAME"
    [ -n "$FILE_PATH" ] && OPERATION_DESC="$OPERATION_DESC on $FILE_PATH"
    [ -n "$COMMAND" ] && OPERATION_DESC="$OPERATION_DESC: $COMMAND"

    while IFS= read -r prohibited; do
        # Case-insensitive matching
        if echo "$OPERATION_DESC" | grep -iq "$prohibited"; then
            echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
            echo -e "❌ BLOCKED: Prohibited action detected"
            echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
            echo ""
            echo -e "${RED}PLAN VIOLATION: Operation matches prohibited action${NC}"
            echo "Prohibited: $prohibited"
            echo "Operation: $OPERATION_DESC"
            echo ""
            echo "REQUIRED ACTION:"
            echo "  1. Get user approval for this action"
            echo "  2. OR modify plan.json to remove prohibition"
            echo "  3. Then retry operation"
            echo ""
            echo -e "${RED}OPERATION BLOCKED - Action prohibited in plan${NC}"
            echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
            exit 2  # EXIT CODE 2: BLOCKS operation
        fi
    done <<< "$PROHIBITED_ACTIONS"
fi

# Validation 3: Module boundary check
if [ -n "$CURRENT_MODULE" ]; then
    # Just display current module (informational)
    echo -e "${GREEN}[INFO]${NC} Current module: $CURRENT_MODULE"
fi

# Validation 4: Constraint checking
if [ -n "$CONSTRAINTS" ]; then
    echo -e "${BLUE}[INFO]${NC} Active constraints:"
    while IFS= read -r constraint; do
        echo "  ⚠️  $constraint"
    done <<< "$CONSTRAINTS"
    echo ""
    echo -e "${YELLOW}[REMINDER]${NC} Ensure operation respects these constraints"
fi

echo -e "${GREEN}✅ ALLOWED: Operation adheres to plan${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
exit 0  # Allow operation
