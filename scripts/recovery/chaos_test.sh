#!/bin/bash
# Chaos Testing for Automated Recovery System
# Version: 4.7.1
# Purpose: Inject random corruption and measure recovery success rate

set -euo pipefail

# Source the recovery script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/automated_recovery.sh"

# Test configuration
TEST_DIR="/tmp/chaos_test_$$"
ITERATIONS=${1:-20}  # Default 20 iterations
RECOVERY_SUCCESS=0
RECOVERY_FAILURE=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================================
# CORRUPTION INJECTION FUNCTIONS
# ============================================================================

inject_trailing_comma() {
    local file=$1
    # Add trailing comma to last property
    sed -i '' 's/\(.*\)}/\1,\n}/' "$file" 2>/dev/null || true
}

inject_missing_brace() {
    local file=$1
    # Remove last closing brace
    sed -i '' '$ d' "$file" 2>/dev/null || true
}

inject_invalid_value() {
    local file=$1
    # Replace a value with invalid syntax
    sed -i '' 's/"version": "[^"]*"/"version": invalid_value/' "$file" 2>/dev/null || true
}

inject_missing_field() {
    local file=$1
    # Remove a random required field
    local fields=("version" "last_update" "project")
    local field=${fields[$((RANDOM % ${#fields[@]}))]}
    sed -i '' "/$field/d" "$file" 2>/dev/null || true
}

inject_version_mismatch() {
    # Make versions inconsistent between files
    jq '.version = "4.6.0"' "$MASTER_STATE" > "$MASTER_STATE.tmp" && mv "$MASTER_STATE.tmp" "$MASTER_STATE"
}

inject_stale_timestamp() {
    local file=$1
    # Set timestamp to 48 hours ago
    local old_date=$(date -u -v-48H +"%Y-%m-%dT%H:%M:%SZ")
    jq --arg date "$old_date" '.last_update = $date' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

inject_random_corruption() {
    local file=$1
    local corruptions=(
        "inject_trailing_comma"
        "inject_missing_brace"
        "inject_missing_field"
        "inject_stale_timestamp"
    )

    local corruption=${corruptions[$((RANDOM % ${#corruptions[@]}))]}
    echo "  Injecting: $corruption on $(basename "$file")"
    $corruption "$file"
}

# ============================================================================
# TEST SETUP
# ============================================================================

setup_chaos_test() {
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

    # Create valid initial state
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.1",
  "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project": "Chaos Test",
  "current_phase": "testing",
  "current_module": {"name": "chaos", "status": "in_progress"},
  "session_id": "chaos_test"
}
EOF

    cat > "$CONTEXT_TRACKING" <<EOF
{
  "estimated_tokens": 50000,
  "max_tokens": 200000,
  "usage_pct": 25.0,
  "threshold_warning": 50.0,
  "threshold_critical": 65.0,
  "threshold_emergency": 75.0,
  "operations_this_session": 10,
  "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "checkpoint_created": "chaos_test",
  "checkpoint_context": 25.0,
  "compression_metrics": {
    "enabled": true,
    "tokens_saved": 0,
    "compression_ratio": 1.0,
    "effective_context_pct": 25.0,
    "strategies_used": {
      "jit_loading": {"uses": 0, "tokens_saved": 0},
      "tool_filtering": {"uses": 0, "tokens_saved": 0},
      "context_editing": {"uses": 0, "tokens_saved": 0}
    }
  }
}
EOF

    # Create a checkpoint for fallback recovery
    mkdir -p "$CHECKPOINT_DIR"
    cat > "$CHECKPOINT_DIR/checkpoint_001.json" <<EOF
{
  "checkpoint_id": "001",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "state": {
    "version": "4.7.1",
    "project": "Chaos Test Checkpoint",
    "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "current_phase": "checkpoint",
    "current_module": {"name": "checkpoint", "status": "complete"},
    "session_id": "chaos_checkpoint"
  }
}
EOF
}

teardown_chaos_test() {
    rm -rf "$TEST_DIR"
}

# ============================================================================
# RUN CHAOS TEST
# ============================================================================

run_single_chaos_test() {
    local iteration=$1

    echo ""
    echo "=========================================="
    echo "Chaos Test Iteration $iteration/$ITERATIONS"
    echo "=========================================="

    # Setup fresh state
    setup_chaos_test

    # Inject 1-3 random corruptions
    local num_corruptions=$((1 + RANDOM % 3))
    echo "Injecting $num_corruptions corruption(s)..."

    for ((i=0; i<num_corruptions; i++)); do
        local target=$((RANDOM % 2))
        if [ $target -eq 0 ]; then
            inject_random_corruption "$MASTER_STATE"
        else
            inject_random_corruption "$CONTEXT_TRACKING"
        fi
    done

    # Occasionally inject version mismatch
    if [ $((RANDOM % 3)) -eq 0 ]; then
        echo "  Injecting: version_mismatch"
        inject_version_mismatch
    fi

    echo ""
    echo "Running recovery..."

    # Reset recovery stats
    ISSUES_FOUND=0
    ISSUES_FIXED=0
    RECOVERY_FAILED=0

    # Attempt recovery
    if check_and_recover > /dev/null 2>&1; then
        # Verify state is now valid
        if validate_json_file "$MASTER_STATE" && validate_json_file "$CONTEXT_TRACKING"; then
            echo -e "${GREEN}✓ RECOVERY SUCCESS${NC}: State fully recovered"
            RECOVERY_SUCCESS=$((RECOVERY_SUCCESS + 1))
        else
            echo -e "${RED}✗ RECOVERY FAILED${NC}: State still invalid after recovery"
            RECOVERY_FAILURE=$((RECOVERY_FAILURE + 1))
        fi
    else
        echo -e "${RED}✗ RECOVERY FAILED${NC}: Recovery process failed"
        RECOVERY_FAILURE=$((RECOVERY_FAILURE + 1))
    fi

    echo "Stats: Found $ISSUES_FOUND, Fixed $ISSUES_FIXED, Failed $RECOVERY_FAILED"

    # Cleanup
    teardown_chaos_test
}

run_chaos_test_suite() {
    echo "========================================================================"
    echo "Chaos Testing for Automated Recovery System"
    echo "========================================================================"
    echo "Iterations: $ITERATIONS"
    echo "Target Success Rate: >90%"
    echo ""

    for ((i=1; i<=ITERATIONS; i++)); do
        run_single_chaos_test $i
    done

    # Calculate success rate
    local total=$((RECOVERY_SUCCESS + RECOVERY_FAILURE))
    local success_rate=$((RECOVERY_SUCCESS * 100 / total))

    echo ""
    echo "========================================================================"
    echo "CHAOS TEST RESULTS"
    echo "========================================================================"
    echo "Total Iterations:    $total"
    echo "Successful Recovery: $RECOVERY_SUCCESS"
    echo "Failed Recovery:     $RECOVERY_FAILURE"
    echo "Success Rate:        $success_rate%"
    echo ""

    if [ $success_rate -ge 90 ]; then
        echo -e "${GREEN}✓ SUCCESS CRITERIA MET${NC}: Recovery rate $success_rate% >= 90%"
        return 0
    else
        echo -e "${YELLOW}⚠ SUCCESS CRITERIA NOT MET${NC}: Recovery rate $success_rate% < 90%"
        return 1
    fi
}

# Run chaos test if executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    run_chaos_test_suite
    exit $?
fi
