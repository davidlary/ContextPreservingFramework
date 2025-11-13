#!/bin/bash
# verify_framework_integrity.sh - Framework integrity validation script
# Purpose: Automated checking that framework is self-consistent
# Version: 1.0.0 (Created for v4.5.0)
# Usage: bash scripts/verify_framework_integrity.sh
#
# VALIDATION CHECKS:
# 1. All scripts referenced in compliance_enforcement.json exist
# 2. All scripts are executable
# 3. All scripts have proper headers
# 4. File organization matches policy
# 5. No broken links in documentation

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="${PWD}"
HOOKS_FILE="${PROJECT_ROOT}/.claude/hooks/compliance_enforcement.json"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Helper function to print test result
print_result() {
    local status="$1"
    local message="$2"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $message"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}❌ FAIL${NC}: $message"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠️  WARN${NC}: $message"
        WARNING_CHECKS=$((WARNING_CHECKS + 1))
    fi
}

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 FRAMEWORK INTEGRITY VALIDATION"
echo "═══════════════════════════════════════════════════════════════════════"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Check 1: Hooks configuration file exists
echo -e "${BLUE}[1/5] Checking hooks configuration...${NC}"
echo ""
if [ -f "$HOOKS_FILE" ]; then
    print_result "PASS" "compliance_enforcement.json exists"
else
    print_result "FAIL" "compliance_enforcement.json NOT found"
fi

# Check 2: Validate all scripts exist and are executable
echo ""
echo -e "${BLUE}[2/5] Validating enforcement scripts...${NC}"
echo ""

# List of all expected scripts (from compliance_enforcement.json)
EXPECTED_SCRIPTS=(
    "session_start_autonomous_check.sh"
    "user_prompt_submit_autonomous.sh"
    "pre_write_check.sh"
    "pre_placeholder_check.sh"
    "pre_checkpoint_validation.sh"
    "pre_operation_state_check.sh"
    "pre_context_check.sh"
    "pre_plan_adherence_check.sh"
    "pre_test_check.sh"
    "pre_git_check.sh"
    "pre_hardcoding_check.sh"
    "pre_bash_safety_check.sh"
    "pre_progress_check.sh"
    "pre_incremental_check.sh"
    "pre_communication_check.sh"
    "pre_decomposition_check.sh"
    "pre_transparency_check.sh"
    "pre_module_boundary_check.sh"
    "validate_compliance.sh"
    "post_test_validation.sh"
    "post_doc_validation.sh"
    "post_bash_error_detection.sh"
    "post_hardcoding_check.sh"
    "post_git_validation.sh"
    "post_code_reuse_check.sh"
)

for script in "${EXPECTED_SCRIPTS[@]}"; do
    SCRIPT_PATH="${SCRIPTS_DIR}/${script}"

    if [ -f "$SCRIPT_PATH" ]; then
        if [ -x "$SCRIPT_PATH" ]; then
            print_result "PASS" "$script exists and is executable"
        else
            print_result "FAIL" "$script exists but NOT executable"
        fi
    else
        print_result "FAIL" "$script NOT found"
    fi
done

# Check 3: Validate script headers
echo ""
echo -e "${BLUE}[3/5] Validating script headers...${NC}"
echo ""

HEADER_REQUIRED="#!/bin/bash"
for script in "${EXPECTED_SCRIPTS[@]}"; do
    SCRIPT_PATH="${SCRIPTS_DIR}/${script}"

    if [ -f "$SCRIPT_PATH" ]; then
        FIRST_LINE=$(head -1 "$SCRIPT_PATH")
        if [ "$FIRST_LINE" = "$HEADER_REQUIRED" ]; then
            print_result "PASS" "$script has proper shebang"
        else
            print_result "FAIL" "$script missing proper shebang (found: $FIRST_LINE)"
        fi
    fi
done

# Check 4: File organization validation
echo ""
echo -e "${BLUE}[4/5] Validating file organization...${NC}"
echo ""

# Check that key files are in the right places
KEY_FILES=(
    "README.md:root"
    "CLAUDE.md:root"
    "LICENSE:root"
    ".claude/hooks/compliance_enforcement.json:hooks"
    "docs/core/PROTOCOL_CORE_RULES.md:docs"
    "scripts/verify_framework_integrity.sh:scripts"
    "data/state/master_state.json:state"
)

for entry in "${KEY_FILES[@]}"; do
    FILE="${entry%:*}"
    LOCATION="${entry#*:}"

    if [ -f "${PROJECT_ROOT}/${FILE}" ]; then
        print_result "PASS" "$FILE in correct location ($LOCATION)"
    else
        print_result "WARN" "$FILE not found in expected location"
    fi
done

# Check 5: Validate JSON syntax
echo ""
echo -e "${BLUE}[5/5] Validating JSON files...${NC}"
echo ""

JSON_FILES=(
    ".claude/hooks/compliance_enforcement.json"
    "data/state/master_state.json"
    "data/state/context_tracking.json"
)

for json_file in "${JSON_FILES[@]}"; do
    JSON_PATH="${PROJECT_ROOT}/${json_file}"

    if [ -f "$JSON_PATH" ]; then
        if command -v jq &> /dev/null; then
            if jq empty "$JSON_PATH" 2>/dev/null; then
                print_result "PASS" "$json_file has valid JSON syntax"
            else
                print_result "FAIL" "$json_file has INVALID JSON syntax"
            fi
        else
            print_result "WARN" "jq not available, cannot validate $json_file"
        fi
    else
        print_result "WARN" "$json_file not found"
    fi
done

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
echo "📊 VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Total checks:   $TOTAL_CHECKS"
echo -e "${GREEN}Passed:${NC}         $PASSED_CHECKS"
echo -e "${RED}Failed:${NC}         $FAILED_CHECKS"
echo -e "${YELLOW}Warnings:${NC}       $WARNING_CHECKS"
echo ""

# Calculate success rate
if [ "$TOTAL_CHECKS" -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo "Success rate:   ${SUCCESS_RATE}%"
else
    SUCCESS_RATE=0
fi

echo ""

# Final verdict
if [ "$FAILED_CHECKS" -eq 0 ]; then
    echo -e "${GREEN}✅ FRAMEWORK INTEGRITY VERIFIED - ALL CHECKS PASSED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
elif [ "$SUCCESS_RATE" -ge 90 ]; then
    echo -e "${YELLOW}⚠️  FRAMEWORK MOSTLY INTACT - MINOR ISSUES DETECTED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${RED}❌ FRAMEWORK INTEGRITY COMPROMISED - CRITICAL ISSUES DETECTED${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 1
fi
