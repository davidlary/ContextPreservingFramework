#!/bin/bash
# PostToolUse Hook: RULE 18 Test Validation
# Purpose: Validate test coverage >80% and 100% passing rate after test commands
# Enforcement: MUST (Tier 1 - Critical)
# Version: 1.0.0
# Created: 2025-11-13

set -euo pipefail

# Input: Bash command output from tool result
# This script receives the output of test commands and validates:
# 1. Coverage >= 80% (if coverage report present)
# 2. All tests passing (0 failures)
# 3. No skipped/disabled tests (warnings only)

# Get the command that was run (from environment or argument)
COMMAND="${1:-}"
OUTPUT="${2:-$(cat)}"  # Read from stdin if not provided

# Exit codes
EXIT_SUCCESS=0
EXIT_VIOLATION=1
EXIT_WARNING=2

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Logging function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if this is a test command
is_test_command() {
    [[ "$COMMAND" =~ pytest|jest|npm[[:space:]]+test|yarn[[:space:]]+test|go[[:space:]]+test|cargo[[:space:]]+test ]]
}

# Parse pytest output for coverage and results
parse_pytest() {
    local coverage=""
    local failed=0
    local passed=0
    local skipped=0

    # Extract coverage percentage (BSD grep compatible)
    if echo "$OUTPUT" | grep -q "TOTAL.*%"; then
        coverage=$(echo "$OUTPUT" | grep "TOTAL" | grep -oE "[0-9]+%" | grep -oE "[0-9]+" | tail -1)
    fi

    # Extract test results (BSD grep compatible)
    if echo "$OUTPUT" | grep -qE "[0-9]+ (passed|failed|skipped)"; then
        passed=$(echo "$OUTPUT" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" | tail -1 || echo "0")
        failed=$(echo "$OUTPUT" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" | tail -1 || echo "0")
        skipped=$(echo "$OUTPUT" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" | tail -1 || echo "0")
    fi

    echo "$coverage|$passed|$failed|$skipped"
}

# Parse jest/npm test output
parse_jest() {
    local coverage=""
    local failed=0
    local passed=0
    local skipped=0

    # Extract coverage percentage (BSD grep compatible)
    if echo "$OUTPUT" | grep -q "All files.*%"; then
        coverage=$(echo "$OUTPUT" | grep "All files" | grep -oE "[0-9]+(\.[0-9]+)?|[0-9]+" | head -1)
    fi

    # Extract test results (BSD grep compatible)
    if echo "$OUTPUT" | grep -q "Tests:"; then
        passed=$(echo "$OUTPUT" | grep "Tests:" | grep -oE "[0-9]+ passed" | grep -oE "[0-9]+" | tail -1 || echo "0")
        failed=$(echo "$OUTPUT" | grep "Tests:" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" | tail -1 || echo "0")
        skipped=$(echo "$OUTPUT" | grep "Tests:" | grep -oE "[0-9]+ skipped" | grep -oE "[0-9]+" | tail -1 || echo "0")
    fi

    echo "$coverage|$passed|$failed|$skipped"
}

# Parse go test output
parse_go_test() {
    local coverage=""
    local failed=0
    local passed=0

    # Extract coverage percentage (BSD grep compatible)
    if echo "$OUTPUT" | grep -q "coverage:"; then
        coverage=$(echo "$OUTPUT" | grep "coverage:" | grep -oE "[0-9]+(\.[0-9]+)?|[0-9]+" | head -1)
    fi

    # Count PASS/FAIL
    passed=$(echo "$OUTPUT" | grep -c "^PASS" || echo "0")
    failed=$(echo "$OUTPUT" | grep -c "^FAIL" || echo "0")

    echo "$coverage|$passed|$failed|0"
}

# Main validation logic
validate_tests() {
    local coverage=""
    local passed=0
    local failed=0
    local skipped=0
    local violations=0
    local warnings=0

    # Determine test framework and parse output
    if [[ "$COMMAND" =~ pytest ]]; then
        log_info "Detected pytest command"
        IFS='|' read -r coverage passed failed skipped <<< "$(parse_pytest)"
    elif [[ "$COMMAND" =~ jest|npm[[:space:]]+test|yarn[[:space:]]+test ]]; then
        log_info "Detected Jest/npm test command"
        IFS='|' read -r coverage passed failed skipped <<< "$(parse_jest)"
    elif [[ "$COMMAND" =~ go[[:space:]]+test ]]; then
        log_info "Detected Go test command"
        IFS='|' read -r coverage passed failed skipped <<< "$(parse_go_test)"
    else
        log_info "Unknown test framework, skipping validation"
        return $EXIT_SUCCESS
    fi

    log_info "Test Results: Passed=$passed, Failed=$failed, Skipped=$skipped, Coverage=$coverage%"

    # Validate coverage (if present)
    if [[ -n "$coverage" && "$coverage" -gt 0 ]]; then
        if [[ "$coverage" -lt 80 ]]; then
            log_error "❌ RULE 18 VIOLATION: Coverage $coverage% < 80% (REQUIRED)"
            violations=$((violations + 1))
        else
            log_info "✅ RULE 18 COMPLIANCE: Coverage $coverage% >= 80%"
        fi
    else
        log_warning "⚠️  RULE 18 WARNING: No coverage data detected (run with --cov flag)"
        warnings=$((warnings + 1))
    fi

    # Validate test results
    if [[ "$failed" -gt 0 ]]; then
        log_error "❌ RULE 18 VIOLATION: $failed test(s) failing (REQUIRED: 0 failures)"
        violations=$((violations + 1))
    elif [[ "$passed" -gt 0 ]]; then
        log_info "✅ RULE 18 COMPLIANCE: All $passed test(s) passing"
    else
        log_warning "⚠️  RULE 18 WARNING: No tests detected in output"
        warnings=$((warnings + 1))
    fi

    # Check for skipped tests (warning only)
    if [[ "$skipped" -gt 0 ]]; then
        log_warning "⚠️  RULE 18 WARNING: $skipped test(s) skipped (not recommended)"
        warnings=$((warnings + 1))
    fi

    # Return appropriate exit code
    if [[ $violations -gt 0 ]]; then
        log_error ""
        log_error "RULE 18 ENFORCEMENT: Cannot proceed with failing tests or insufficient coverage"
        log_error "Required actions:"
        log_error "  1. Fix failing tests (100% passing required)"
        log_error "  2. Increase test coverage to ≥80%"
        log_error "  3. Re-run tests and verify compliance"
        return $EXIT_VIOLATION
    elif [[ $warnings -gt 0 ]]; then
        log_warning ""
        log_warning "RULE 18 WARNINGS: Consider addressing the warnings above"
        return $EXIT_SUCCESS  # Warnings don't block
    else
        log_info ""
        log_info "✅ RULE 18 FULL COMPLIANCE: All validations passed"
        return $EXIT_SUCCESS
    fi
}

# Main execution
main() {
    # Check if this is a test command
    if ! is_test_command; then
        # Not a test command, skip validation
        exit $EXIT_SUCCESS
    fi

    log_info "========================================"
    log_info "RULE 18: Test Validation (PostToolUse)"
    log_info "========================================"

    # Run validation
    validate_tests
    exit_code=$?

    log_info "========================================"

    exit $exit_code
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
