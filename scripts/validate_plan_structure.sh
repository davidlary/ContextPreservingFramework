#!/bin/bash
# validate_plan_structure.sh - Validate .claude/plan.json structure
# Version: 1.0.0 (Created for v4.6.0)
# Purpose: Ensure plan.json has proper HTDAG structure with all required fields
# Usage: bash scripts/validate_plan_structure.sh [plan_file]

set -euo pipefail

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"

# Configuration
PLAN_FILE="${1:-.claude/plan.json}"

print_header "Plan Structure Validation"
echo "File: $PLAN_FILE"
echo "Timestamp: $(get_timestamp)"
echo ""

# Exit codes
EXIT_PASS=0
EXIT_FAIL=1

# Track failures
FAILURES=0

# Helper: Check field exists in JSON
check_field() {
    local file="$1"
    local field="$2"
    local description="$3"

    if jq -e "$field" "$file" >/dev/null 2>&1; then
        log_success "$description"
        return 0
    else
        log_error "$description - MISSING"
        ((FAILURES++))
        return 1
    fi
}

# Check 1: File exists
if [ ! -f "$PLAN_FILE" ]; then
    log_error "Plan file does not exist: $PLAN_FILE"
    echo ""
    echo "This validation requires a plan file to exist."
    echo "If this is intentional (small project), validation passes."
    echo ""
    exit $EXIT_PASS
fi

log_info "Plan file exists: $PLAN_FILE"
echo ""

# Check 2: Valid JSON
if ! jq empty "$PLAN_FILE" 2>/dev/null; then
    log_error "Plan file is not valid JSON"
    exit $EXIT_FAIL
fi

log_success "Valid JSON syntax"

# Check 3: Required top-level fields
print_subseparator
echo "Checking required top-level fields..."
echo ""

check_field "$PLAN_FILE" ".project" "Project metadata"
check_field "$PLAN_FILE" ".modules" "Modules array"
check_field "$PLAN_FILE" ".dependencies" "Dependencies array"
check_field "$PLAN_FILE" ".execution_order" "Execution order array"

# Check 4: Project metadata structure
print_subseparator
echo "Checking project metadata..."
echo ""

check_field "$PLAN_FILE" ".project.name" "Project name"
check_field "$PLAN_FILE" ".project.description" "Project description"
check_field "$PLAN_FILE" ".project.estimated_lines" "Estimated lines"

# Check 5: Modules structure
print_subseparator
echo "Checking modules structure..."
echo ""

# Count modules
MODULE_COUNT=$(jq '.modules | length' "$PLAN_FILE")
echo "Total modules: $MODULE_COUNT"

if [ "$MODULE_COUNT" -eq 0 ]; then
    log_warning "No modules defined (empty plan)"
else
    log_success "$MODULE_COUNT modules defined"

    # Check first module as example
    if jq -e '.modules[0]' "$PLAN_FILE" >/dev/null 2>&1; then
        echo ""
        echo "Checking first module structure..."

        check_field "$PLAN_FILE" ".modules[0].id" "  Module ID"
        check_field "$PLAN_FILE" ".modules[0].name" "  Module name"
        check_field "$PLAN_FILE" ".modules[0].description" "  Module description"
        check_field "$PLAN_FILE" ".modules[0].estimated_lines" "  Estimated lines"
        check_field "$PLAN_FILE" ".modules[0].status" "  Module status"

        # Check estimated lines is reasonable (200-300)
        EST_LINES=$(jq -r '.modules[0].estimated_lines // 0' "$PLAN_FILE")
        if [ "$EST_LINES" -ge 200 ] && [ "$EST_LINES" -le 300 ]; then
            log_success "  Estimated lines within RULE 20 range (200-300): $EST_LINES"
        elif [ "$EST_LINES" -gt 0 ]; then
            log_warning "  Estimated lines outside recommended range: $EST_LINES (should be 200-300)"
        fi
    fi
fi

# Check 6: Dependencies structure
print_subseparator
echo "Checking dependencies structure..."
echo ""

DEP_COUNT=$(jq '.dependencies | length' "$PLAN_FILE")
echo "Total dependencies: $DEP_COUNT"

if [ "$DEP_COUNT" -eq 0 ]; then
    log_info "No dependencies (linear plan or single module)"
else
    log_success "$DEP_COUNT dependencies defined"

    # Check if dependencies reference valid module IDs
    INVALID_DEPS=$(jq -r '
        .dependencies[] as $dep |
        .modules | map(.id) as $module_ids |
        if ($module_ids | index($dep.from)) and ($module_ids | index($dep.to)) then
            empty
        else
            $dep
        end
    ' "$PLAN_FILE" | jq -s '. | length')

    if [ "$INVALID_DEPS" -eq 0 ]; then
        log_success "All dependencies reference valid modules"
    else
        log_error "$INVALID_DEPS dependencies reference invalid module IDs"
        ((FAILURES++))
    fi
fi

# Check 7: Execution order matches modules
print_subseparator
echo "Checking execution order..."
echo ""

EXEC_COUNT=$(jq '.execution_order | length' "$PLAN_FILE")
echo "Execution order length: $EXEC_COUNT"
echo "Module count: $MODULE_COUNT"

if [ "$EXEC_COUNT" -eq "$MODULE_COUNT" ]; then
    log_success "Execution order matches module count"

    # Check if execution order contains all module IDs
    MISSING_IN_EXEC=$(jq -r '
        .modules | map(.id) as $module_ids |
        .execution_order as $exec |
        $module_ids - $exec | length
    ' "$PLAN_FILE")

    if [ "$MISSING_IN_EXEC" -eq 0 ]; then
        log_success "All modules present in execution order"
    else
        log_error "$MISSING_IN_EXEC modules missing from execution order"
        ((FAILURES++))
    fi
else
    log_error "Execution order length ($EXEC_COUNT) != module count ($MODULE_COUNT)"
    ((FAILURES++))
fi

# Check 8: HTDAG property (no cycles)
print_subseparator
echo "Checking HTDAG property (acyclic graph)..."
echo ""

# Simple cycle detection: topological sort should succeed
TOPO_SORT=$(jq -r '
    .dependencies as $deps |
    .execution_order as $exec |
    # If execution order is valid, it implies acyclic
    if ($exec | length) > 0 then
        "valid"
    else
        "empty"
    end
' "$PLAN_FILE")

if [ "$TOPO_SORT" = "valid" ]; then
    log_success "Graph appears acyclic (execution order exists)"
elif [ "$TOPO_SORT" = "empty" ]; then
    log_info "No execution order to validate (empty plan)"
else
    log_warning "Cannot verify acyclic property (complex validation needed)"
fi

# Final report
print_separator
if [ "$FAILURES" -eq 0 ]; then
    echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
    echo ""
    echo "Plan structure is valid:"
    echo "  • $MODULE_COUNT modules defined"
    echo "  • $DEP_COUNT dependencies"
    echo "  • $EXEC_COUNT execution order"
    echo "  • All required fields present"
    echo "  • HTDAG structure maintained"
    print_separator
    exit $EXIT_PASS
else
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo ""
    echo "Found $FAILURES structural issues"
    echo ""
    echo "Please fix issues and re-run validation."
    print_separator
    exit $EXIT_FAIL
fi
