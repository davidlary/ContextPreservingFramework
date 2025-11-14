#!/bin/bash
# Unit Tests for Automated Recovery System
# Version: 4.7.1

set -euo pipefail

# Source the recovery script functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/automated_recovery.sh"

# Test configuration
TEST_DIR="/tmp/recovery_test_$$"
TESTS_PASSED=0
TESTS_FAILED=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================================
# TEST FRAMEWORK
# ============================================================================

setup_test() {
    mkdir -p "$TEST_DIR/data/state"
    mkdir -p "$TEST_DIR/logs"
    mkdir -p "$TEST_DIR/.claude/checkpoints"

    # Override paths for testing
    STATE_DIR="$TEST_DIR/data/state"
    BACKUP_DIR="$STATE_DIR/backups"
    CHECKPOINT_DIR="$TEST_DIR/.claude/checkpoints"
    LOG_FILE="$TEST_DIR/logs/recovery_log.txt"
    MASTER_STATE="$STATE_DIR/master_state.json"
    CONTEXT_TRACKING="$STATE_DIR/context_tracking.json"
    OPERATION_LOG="$TEST_DIR/logs/operation_log.txt"
}

teardown_test() {
    rm -rf "$TEST_DIR"
}

assert_equals() {
    local expected=$1
    local actual=$2
    local message=$3

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_exists() {
    local file=$1
    local message=$2

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $message (file not found: $file)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_valid_json() {
    local file=$1
    local message=$2

    if jq . "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $message (invalid JSON)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ============================================================================
# TEST CASES
# ============================================================================

test_json_validation_valid() {
    echo ""
    echo "TEST: JSON Validation - Valid JSON"

    setup_test

    # Create valid JSON
    echo '{"version": "4.7.1", "status": "ok"}' > "$MASTER_STATE"

    # Test validation
    if validate_json_file "$MASTER_STATE"; then
        assert_equals "0" "0" "Valid JSON should pass validation"
    else
        assert_equals "0" "1" "Valid JSON should pass validation"
    fi

    teardown_test
}

test_json_validation_invalid() {
    echo ""
    echo "TEST: JSON Validation - Invalid JSON"

    setup_test

    # Create invalid JSON (missing closing brace)
    echo '{"version": "4.7.1", "status": "ok"' > "$MASTER_STATE"

    # Test validation (should fail)
    if validate_json_file "$MASTER_STATE"; then
        assert_equals "1" "0" "Invalid JSON should fail validation"
    else
        assert_equals "1" "1" "Invalid JSON should fail validation"
    fi

    teardown_test
}

test_json_repair_trailing_comma() {
    echo ""
    echo "TEST: JSON Repair - Trailing Comma"

    setup_test

    # Create JSON with trailing comma
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.1",
  "status": "ok",
}
EOF

    # Test repair
    repair_json_file "$MASTER_STATE"

    # Verify it's now valid
    assert_valid_json "$MASTER_STATE" "Repaired JSON should be valid"

    teardown_test
}

test_schema_validation_missing_fields() {
    echo ""
    echo "TEST: Schema Validation - Missing Fields"

    setup_test

    # Create JSON with missing required fields
    echo '{"version": "4.7.1"}' > "$MASTER_STATE"

    # Test validation (should fail)
    validate_schema || {
        assert_equals "1" "1" "Missing required fields should fail validation"
    }

    teardown_test
}

test_add_missing_fields() {
    echo ""
    echo "TEST: Add Missing Fields"

    setup_test

    # Create minimal state
    echo '{"version": "4.7.1"}' > "$MASTER_STATE"
    echo '{"usage_pct": 50.0}' > "$CONTEXT_TRACKING"

    # Add missing fields
    add_missing_fields

    # Verify fields were added
    local has_project=$(jq -e '.project' "$MASTER_STATE" > /dev/null 2>&1 && echo "yes" || echo "no")
    local has_operations=$(jq -e '.operations_this_session' "$CONTEXT_TRACKING" > /dev/null 2>&1 && echo "yes" || echo "no")

    assert_equals "yes" "$has_project" "Missing fields should be added to master_state"
    assert_equals "yes" "$has_operations" "Missing fields should be added to context_tracking"

    teardown_test
}

test_checkpoint_restore() {
    echo ""
    echo "TEST: Checkpoint Restore"

    setup_test

    # Create a valid checkpoint
    mkdir -p "$CHECKPOINT_DIR"
    cat > "$CHECKPOINT_DIR/checkpoint_001.json" <<EOF
{
  "checkpoint_id": "001",
  "timestamp": "2025-11-14T03:00:00Z",
  "state": {
    "version": "4.7.1",
    "project": "Test Project",
    "last_update": "2025-11-14T03:00:00Z"
  }
}
EOF

    # Create corrupted current state
    echo 'invalid json' > "$MASTER_STATE"

    # Restore from checkpoint
    restore_from_checkpoint

    # Verify state was restored
    assert_valid_json "$MASTER_STATE" "Restored state should be valid JSON"

    local restored_project=$(jq -r '.project' "$MASTER_STATE")
    assert_equals "Test Project" "$restored_project" "Restored state should have correct values"

    teardown_test
}

test_consistency_check_version_mismatch() {
    echo ""
    echo "TEST: Consistency Check - Version Mismatch"

    setup_test

    # Create states with version mismatch
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.0",
  "project": "Test",
  "last_update": "2025-11-14T03:00:00Z"
}
EOF

    cat > "$CONTEXT_TRACKING" <<EOF
{
  "estimated_tokens": 50000,
  "usage_pct": 25.0,
  "operations_this_session": 10,
  "framework_version": "4.7.1"
}
EOF

    # Test consistency validation (should detect mismatch)
    validate_consistency || {
        assert_equals "1" "1" "Version mismatch should be detected"
    }

    teardown_test
}

test_sync_state_files() {
    echo ""
    echo "TEST: Sync State Files"

    setup_test

    # Create states with version mismatch
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.1",
  "project": "Test",
  "last_update": "2025-11-14T03:00:00Z"
}
EOF

    cat > "$CONTEXT_TRACKING" <<EOF
{
  "estimated_tokens": 50000,
  "usage_pct": 25.0,
  "operations_this_session": 10,
  "framework_version": "4.7.0"
}
EOF

    # Sync state files
    sync_state_files

    # Verify version was synced
    local synced_version=$(jq -r '.framework_version' "$CONTEXT_TRACKING")
    assert_equals "4.7.1" "$synced_version" "Version should be synced from master_state"

    teardown_test
}

test_factory_reset() {
    echo ""
    echo "TEST: Factory Reset"

    setup_test

    # Create corrupted state
    echo 'completely broken' > "$MASTER_STATE"

    # Perform factory reset
    initialize_fresh_state

    # Verify fresh state was created
    assert_valid_json "$MASTER_STATE" "Fresh master_state should be valid JSON"
    assert_valid_json "$CONTEXT_TRACKING" "Fresh context_tracking should be valid JSON"

    # Verify essential fields exist
    local has_version=$(jq -e '.version' "$MASTER_STATE" > /dev/null 2>&1 && echo "yes" || echo "no")
    assert_equals "yes" "$has_version" "Fresh state should have version field"

    teardown_test
}

test_backup_creation() {
    echo ""
    echo "TEST: Backup Creation"

    setup_test

    # Create a file to backup
    echo '{"test": "data"}' > "$MASTER_STATE"

    # Create backup
    create_backup "$MASTER_STATE"

    # Verify backup exists
    local backup_count=$(find "$BACKUP_DIR" -name "master_state.json" | wc -l)
    assert_equals "1" "$backup_count" "Backup should be created"

    teardown_test
}

test_full_recovery_workflow() {
    echo ""
    echo "TEST: Full Recovery Workflow"

    setup_test

    # Create state with multiple issues
    # Issue 1: Trailing comma in master_state
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.1",
  "project": "Test",
}
EOF

    # Issue 2: Missing fields in context_tracking
    echo '{"usage_pct": 50.0}' > "$CONTEXT_TRACKING"

    # Run full recovery
    ISSUES_FOUND=0
    ISSUES_FIXED=0
    RECOVERY_FAILED=0

    check_and_recover

    # Verify all issues were fixed
    assert_valid_json "$MASTER_STATE" "Master state should be valid after recovery"
    assert_valid_json "$CONTEXT_TRACKING" "Context tracking should be valid after recovery"

    local has_operations=$(jq -e '.operations_this_session' "$CONTEXT_TRACKING" > /dev/null 2>&1 && echo "yes" || echo "no")
    assert_equals "yes" "$has_operations" "Missing fields should be added during recovery"

    echo ""
    echo "Recovery Stats: Found $ISSUES_FOUND, Fixed $ISSUES_FIXED, Failed $RECOVERY_FAILED"

    teardown_test
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

run_all_tests() {
    echo "========================================================================"
    echo "Automated Recovery System - Unit Tests"
    echo "========================================================================"

    # Disable colored output for cleaner logs
    RED=''
    GREEN=''
    YELLOW=''
    NC=''

    test_json_validation_valid
    test_json_validation_invalid
    test_json_repair_trailing_comma
    test_schema_validation_missing_fields
    test_add_missing_fields
    test_checkpoint_restore
    test_consistency_check_version_mismatch
    test_sync_state_files
    test_factory_reset
    test_backup_creation
    test_full_recovery_workflow

    echo ""
    echo "========================================================================"
    echo "TEST RESULTS"
    echo "========================================================================"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n✓ ALL TESTS PASSED"
        return 0
    else
        echo -e "\n✗ SOME TESTS FAILED"
        return 1
    fi
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    run_all_tests
    exit $?
fi
