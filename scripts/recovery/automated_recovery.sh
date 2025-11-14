#!/bin/bash
# Automated Recovery System - Self-Healing Context Corruption
# Version: 4.7.1
# Purpose: Detect and auto-recover from state corruption

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Import common functions if available
if [ -f "$SCRIPT_DIR/../common_functions.sh" ]; then
    source "$SCRIPT_DIR/../common_functions.sh"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
STATE_DIR="$PROJECT_ROOT/data/state"
BACKUP_DIR="$STATE_DIR/backups"
CHECKPOINT_DIR="$PROJECT_ROOT/.claude/checkpoints"
LOG_FILE="$PROJECT_ROOT/logs/recovery_log.txt"

# Required state files
MASTER_STATE="$STATE_DIR/master_state.json"
CONTEXT_TRACKING="$STATE_DIR/context_tracking.json"
OPERATION_LOG="$PROJECT_ROOT/logs/operation_log.txt"

# Recovery statistics
ISSUES_FOUND=0
ISSUES_FIXED=0
RECOVERY_FAILED=0

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_recovery() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    case "$level" in
        ERROR)
            echo -e "${RED}✗ $message${NC}" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}✓ $message${NC}"
            ;;
        WARNING)
            echo -e "${YELLOW}⚠ $message${NC}"
            ;;
        INFO)
            echo "ℹ $message"
            ;;
    esac
}

create_backup() {
    local file=$1
    local backup_dir="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"

    if [ -f "$file" ]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/$(basename "$file")"
        log_recovery INFO "Backup created: $backup_dir/$(basename "$file")"
        return 0
    fi

    return 1
}

# ============================================================================
# DETECTION LAYER - Identify Corruption Patterns
# ============================================================================

validate_json_file() {
    local file=$1

    if [ ! -f "$file" ]; then
        log_recovery WARNING "File not found: $file"
        return 1
    fi

    if jq . "$file" > /dev/null 2>&1; then
        return 0
    else
        log_recovery ERROR "Invalid JSON: $file"
        return 1
    fi
}

validate_json_files() {
    local all_valid=0

    for file in "$MASTER_STATE" "$CONTEXT_TRACKING"; do
        if [ -f "$file" ]; then
            if ! validate_json_file "$file"; then
                all_valid=1
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        fi
    done

    return $all_valid
}

validate_schema() {
    local valid=0

    # Validate master_state.json schema
    if [ -f "$MASTER_STATE" ]; then
        local required_fields=("version" "last_update" "project")

        for field in "${required_fields[@]}"; do
            if ! jq -e ".$field" "$MASTER_STATE" > /dev/null 2>&1; then
                log_recovery WARNING "Missing required field in master_state.json: $field"
                valid=1
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        done
    fi

    # Validate context_tracking.json schema
    if [ -f "$CONTEXT_TRACKING" ]; then
        # Use actual schema field names from the framework
        local required_fields=("estimated_tokens" "usage_pct" "operations_this_session")

        for field in "${required_fields[@]}"; do
            if ! jq -e ".$field" "$CONTEXT_TRACKING" > /dev/null 2>&1; then
                log_recovery WARNING "Missing required field in context_tracking.json: $field"
                valid=1
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        done
    fi

    return $valid
}

is_state_stale() {
    if [ ! -f "$MASTER_STATE" ]; then
        return 0
    fi

    local last_update=$(jq -r '.last_update // empty' "$MASTER_STATE")

    if [ -z "$last_update" ]; then
        return 0
    fi

    # Check if state is older than 24 hours
    local last_update_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_update" "+%s" 2>/dev/null || echo 0)
    local current_ts=$(date "+%s")
    local age_seconds=$((current_ts - last_update_ts))
    local age_hours=$((age_seconds / 3600))

    if [ $age_hours -gt 24 ]; then
        log_recovery WARNING "State is stale (${age_hours}h old). Last update: $last_update"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        return 0
    fi

    return 1
}

validate_consistency() {
    local consistent=0

    if [ ! -f "$MASTER_STATE" ] || [ ! -f "$CONTEXT_TRACKING" ]; then
        return 0
    fi

    # Check version consistency
    local master_version=$(jq -r '.version // "unknown"' "$MASTER_STATE")
    local context_version=$(jq -r '.framework_version // "unknown"' "$CONTEXT_TRACKING")

    if [ "$master_version" != "unknown" ] && [ "$context_version" != "unknown" ]; then
        if [ "$master_version" != "$context_version" ]; then
            log_recovery WARNING "Version mismatch: master=$master_version, context=$context_version"
            consistent=1
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi

    return $consistent
}

# ============================================================================
# RECOVERY LAYER - Automatic Fixes
# ============================================================================

repair_json_file() {
    local file=$1

    if [ ! -f "$file" ]; then
        return 1
    fi

    # Create backup before attempting repair
    create_backup "$file"

    # Try to repair common JSON issues
    local temp_file="${file}.tmp"

    # Multiple repair strategies
    # 1. Remove trailing commas before closing braces/brackets
    sed 's/,\([[:space:]]*[}\]]\)/\1/g' "$file" > "$temp_file.step1"

    # 2. Try to add missing closing braces if needed
    # Count opening and closing braces
    local open_braces=$(grep -o '{' "$temp_file.step1" | wc -l | tr -d ' ')
    local close_braces=$(grep -o '}' "$temp_file.step1" | wc -l | tr -d ' ')

    cp "$temp_file.step1" "$temp_file"

    # If more opening than closing braces, try adding closing braces
    if [ "$open_braces" -gt "$close_braces" ]; then
        local diff=$((open_braces - close_braces))
        for ((i=0; i<diff; i++)); do
            echo '}' >> "$temp_file"
        done
    fi

    # Validate repaired JSON
    if jq . "$temp_file" > /dev/null 2>&1; then
        mv "$temp_file" "$file"
        rm -f "$temp_file.step1"
        log_recovery SUCCESS "JSON repaired: $file"
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        return 0
    else
        rm -f "$temp_file" "$temp_file.step1"
        log_recovery ERROR "JSON repair failed: $file"
        RECOVERY_FAILED=$((RECOVERY_FAILED + 1))
        return 1
    fi
}

repair_json_files() {
    local all_repaired=0

    for file in "$MASTER_STATE" "$CONTEXT_TRACKING"; do
        if [ -f "$file" ] && ! validate_json_file "$file"; then
            if ! repair_json_file "$file"; then
                all_repaired=1
            fi
        fi
    done

    return $all_repaired
}

add_missing_fields() {
    local fixed=0

    # Fix master_state.json
    if [ -f "$MASTER_STATE" ]; then
        create_backup "$MASTER_STATE"

        local temp_file="${MASTER_STATE}.tmp"
        jq '. + {
            "version": (.version // "4.7.1"),
            "last_update": (.last_update // "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"),
            "project": (.project // "Context-Preserving Framework"),
            "current_phase": (.current_phase // "in_progress"),
            "current_module": (.current_module // {"name": "unknown", "status": "in_progress"}),
            "session_id": (.session_id // "recovery_'$(date +%Y%m%d_%H%M%S)'")
        }' "$MASTER_STATE" > "$temp_file"

        if validate_json_file "$temp_file"; then
            mv "$temp_file" "$MASTER_STATE"
            log_recovery SUCCESS "Added missing fields to master_state.json"
            ISSUES_FIXED=$((ISSUES_FIXED + 1))
            fixed=1
        else
            rm -f "$temp_file"
            log_recovery ERROR "Failed to add missing fields to master_state.json"
            RECOVERY_FAILED=$((RECOVERY_FAILED + 1))
        fi
    fi

    # Fix context_tracking.json
    if [ -f "$CONTEXT_TRACKING" ]; then
        create_backup "$CONTEXT_TRACKING"

        local temp_file="${CONTEXT_TRACKING}.tmp"
        # Use actual schema field names from the framework
        jq '. + {
            "estimated_tokens": (.estimated_tokens // 0),
            "max_tokens": (.max_tokens // 200000),
            "usage_pct": (.usage_pct // 0.0),
            "threshold_warning": (.threshold_warning // 50.0),
            "threshold_critical": (.threshold_critical // 65.0),
            "threshold_emergency": (.threshold_emergency // 75.0),
            "operations_this_session": (.operations_this_session // 0),
            "last_update": (.last_update // "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'")
        }' "$CONTEXT_TRACKING" > "$temp_file"

        if validate_json_file "$temp_file"; then
            mv "$temp_file" "$CONTEXT_TRACKING"
            log_recovery SUCCESS "Added missing fields to context_tracking.json"
            ISSUES_FIXED=$((ISSUES_FIXED + 1))
            fixed=1
        else
            rm -f "$temp_file"
            log_recovery ERROR "Failed to add missing fields to context_tracking.json"
            RECOVERY_FAILED=$((RECOVERY_FAILED + 1))
        fi
    fi

    [ $fixed -eq 1 ] && return 0 || return 1
}

restore_from_checkpoint() {
    if [ ! -d "$CHECKPOINT_DIR" ]; then
        log_recovery WARNING "No checkpoint directory found"
        return 1
    fi

    # Find most recent valid checkpoint
    local latest_checkpoint=$(find "$CHECKPOINT_DIR" -name "checkpoint_*.json" -type f 2>/dev/null | sort -r | head -1)

    if [ -z "$latest_checkpoint" ]; then
        log_recovery WARNING "No checkpoints found"
        return 1
    fi

    # Validate checkpoint
    if ! validate_json_file "$latest_checkpoint"; then
        log_recovery ERROR "Latest checkpoint is corrupted: $latest_checkpoint"
        return 1
    fi

    # Backup current state before restoring
    create_backup "$MASTER_STATE"
    create_backup "$CONTEXT_TRACKING"

    # Extract and restore state from checkpoint
    if jq -e '.state' "$latest_checkpoint" > /dev/null 2>&1; then
        jq '.state' "$latest_checkpoint" > "$MASTER_STATE"
        log_recovery SUCCESS "Restored master_state from checkpoint: $(basename "$latest_checkpoint")"
        ISSUES_FIXED=$((ISSUES_FIXED + 1))
        return 0
    else
        log_recovery ERROR "Checkpoint missing state field: $latest_checkpoint"
        return 1
    fi
}

sync_state_files() {
    if [ ! -f "$MASTER_STATE" ]; then
        return 1
    fi

    # Sync version from master_state to context_tracking
    local master_version=$(jq -r '.version // "unknown"' "$MASTER_STATE")

    if [ "$master_version" != "unknown" ] && [ -f "$CONTEXT_TRACKING" ]; then
        create_backup "$CONTEXT_TRACKING"

        local temp_file="${CONTEXT_TRACKING}.tmp"
        jq --arg version "$master_version" '.framework_version = $version' "$CONTEXT_TRACKING" > "$temp_file"

        if validate_json_file "$temp_file"; then
            mv "$temp_file" "$CONTEXT_TRACKING"
            log_recovery SUCCESS "Synced version to context_tracking.json"
            ISSUES_FIXED=$((ISSUES_FIXED + 1))
            return 0
        else
            rm -f "$temp_file"
        fi
    fi

    return 1
}

initialize_fresh_state() {
    local backup_dir="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)_factory_reset"
    mkdir -p "$backup_dir"

    # Backup all existing state
    if [ -d "$STATE_DIR" ]; then
        cp -r "$STATE_DIR"/* "$backup_dir/" 2>/dev/null || true
    fi

    # Create fresh master_state.json
    mkdir -p "$STATE_DIR"
    cat > "$MASTER_STATE" <<EOF
{
  "version": "4.7.1",
  "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "project": "Context-Preserving Framework",
  "current_phase": "initialized",
  "current_module": {
    "name": "initialization",
    "status": "complete"
  },
  "session_id": "recovery_$(date +%Y%m%d_%H%M%S)",
  "recovery_note": "State initialized by automated recovery system"
}
EOF

    # Create fresh context_tracking.json with actual framework schema
    cat > "$CONTEXT_TRACKING" <<EOF
{
  "estimated_tokens": 0,
  "max_tokens": 200000,
  "usage_pct": 0.0,
  "threshold_warning": 50.0,
  "threshold_critical": 65.0,
  "threshold_emergency": 75.0,
  "operations_this_session": 0,
  "last_update": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "checkpoint_created": "recovery_initialization",
  "checkpoint_context": 0.0,
  "compression_metrics": {
    "enabled": true,
    "tokens_saved": 0,
    "compression_ratio": 1.0,
    "effective_context_pct": 0.0,
    "strategies_used": {
      "jit_loading": {"uses": 0, "tokens_saved": 0},
      "tool_filtering": {"uses": 0, "tokens_saved": 0},
      "context_editing": {"uses": 0, "tokens_saved": 0}
    }
  }
}
EOF

    log_recovery WARNING "Factory reset performed. Backups in: $backup_dir"
    ISSUES_FIXED=$((ISSUES_FIXED + 1))

    return 0
}

factory_reset_state() {
    log_recovery WARNING "Attempting factory reset..."

    if initialize_fresh_state; then
        log_recovery SUCCESS "Factory reset complete"
        return 0
    else
        log_recovery ERROR "Factory reset failed"
        return 1
    fi
}

# ============================================================================
# MAIN RECOVERY ORCHESTRATION
# ============================================================================

check_and_recover() {
    local recovery_succeeded=true

    log_recovery INFO "Starting automated recovery check..."

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"
    mkdir -p "$BACKUP_DIR"

    # 1. Check JSON validity
    validate_json_files || {
        log_recovery INFO "JSON corruption detected, attempting repair..."
        if repair_json_files; then
            log_recovery SUCCESS "JSON corruption auto-fixed"
        else
            recovery_succeeded=false
        fi
    }

    # 2. Check schema validity
    validate_schema || {
        log_recovery INFO "Schema issues detected, adding missing fields..."
        if add_missing_fields; then
            log_recovery SUCCESS "Schema issues auto-fixed"
        else
            recovery_succeeded=false
        fi
    }

    # 3. Check timestamp staleness (warning only, don't fail)
    is_state_stale || true

    # 4. Check cross-file consistency
    validate_consistency || {
        log_recovery INFO "Consistency issues detected, syncing state files..."
        if sync_state_files; then
            log_recovery SUCCESS "Consistency issues auto-fixed"
        else
            recovery_succeeded=false
        fi
    }

    # Final recovery attempt if needed
    if [ "$recovery_succeeded" = false ]; then
        log_recovery WARNING "Standard recovery failed, attempting checkpoint restore..."
        if restore_from_checkpoint; then
            log_recovery SUCCESS "Recovered from checkpoint"
            recovery_succeeded=true
        else
            log_recovery WARNING "Checkpoint restore failed, attempting factory reset..."
            if factory_reset_state; then
                log_recovery WARNING "Factory reset successful (state history lost)"
                recovery_succeeded=true
            else
                log_recovery ERROR "All recovery attempts failed. Manual intervention required."
                return 2
            fi
        fi
    fi

    # Display recovery summary
    if [ "$ISSUES_FOUND" -gt 0 ]; then
        log_recovery INFO "Recovery summary: Found $ISSUES_FOUND issues, fixed $ISSUES_FIXED, failed $RECOVERY_FAILED"
    else
        log_recovery SUCCESS "No corruption detected. State is healthy."
    fi

    return 0
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main() {
    check_and_recover
    exit $?
}

# Run main function if executed directly
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
