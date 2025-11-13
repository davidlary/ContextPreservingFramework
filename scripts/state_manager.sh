#!/bin/bash
# state_manager.sh - Unified State Management with MCP Support
# Version: 1.0.0
# Purpose: Centralized state operations with MCP integration

set -euo pipefail

# Source MCP library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/mcp_lib.sh"

# Initialize
mcp_init_log

# ═══════════════════════════════════════════════════════════════════════
# STATE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════

# Update master state
update_master_state() {
    local key="$1"
    local value="$2"
    local state_file="${3:-.cpf/state/master_state.json}"

    if [ ! -f "$state_file" ]; then
        echo "Error: State file not found: $state_file" >&2
        return 1
    fi

    # Update JSON file
    if command -v jq &> /dev/null; then
        local updated_state=$(jq ".$key = $value" "$state_file")
        echo "$updated_state" > "$state_file"

        # Log to MCP if available
        if mcp_memory_is_available; then
            mcp_add_observation "master_state" "Updated $key to $value"
        fi

        echo "✓ State updated: $key"
        return 0
    else
        echo "Error: jq not available" >&2
        return 1
    fi
}

# Get state value
get_state_value() {
    local key="$1"
    local state_file="${2:-.cpf/state/master_state.json}"

    if [ ! -f "$state_file" ]; then
        echo "Error: State file not found: $state_file" >&2
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -r ".$key // empty" "$state_file"
        return 0
    else
        echo "Error: jq not available" >&2
        return 1
    fi
}

# Save complete state snapshot
save_state_snapshot() {
    local state_file="${1:-.cpf/state/master_state.json}"
    local snapshot_name="${2:-snapshot_$(date +%Y%m%d_%H%M%S)}"

    if [ ! -f "$state_file" ]; then
        echo "Error: State file not found: $state_file" >&2
        return 1
    fi

    local state_data=$(cat "$state_file")

    # Save to file
    local snapshot_dir=".cpf/state/snapshots"
    mkdir -p "$snapshot_dir"
    echo "$state_data" > "$snapshot_dir/${snapshot_name}.json"

    # Save to MCP if available
    if mcp_memory_is_available; then
        echo "[MCP] Saving state snapshot: $snapshot_name" >> .cpf/logs/mcp_operations.log
        # In Claude Code context:
        # mcp__memory__create_entities([{
        #     name: "state_snapshot_$snapshot_name",
        #     entityType: "snapshot",
        #     observations: ["$state_data"]
        # }])
    fi

    echo "✓ State snapshot saved: $snapshot_name"
    return 0
}

# ═══════════════════════════════════════════════════════════════════════
# MODULE STATE OPERATIONS
# ═══════════════════════════════════════════════════════════════════════

# Mark module as complete
complete_module() {
    local module_id="$1"
    local summary="$2"
    local state_file="${3:-.cpf/state/master_state.json}"

    # Update state file
    if command -v jq &> /dev/null && [ -f "$state_file" ]; then
        local updated_state=$(jq ".completed_modules += [\"$module_id\"]" "$state_file")
        echo "$updated_state" > "$state_file"
    fi

    # Save module summary
    if [ -n "$summary" ]; then
        mcp_save_module_summary "$module_id" "$summary"
    fi

    # Add observation if MCP available
    if mcp_memory_is_available; then
        mcp_add_observation "$module_id" "Module completed"
    fi

    echo "✓ Module completed: $module_id"
    return 0
}

# Get completed modules
get_completed_modules() {
    local state_file="${1:-.cpf/state/master_state.json}"

    # Try MCP first
    if mcp_memory_is_available; then
        echo "[MCP] Would search for completed modules" >> .cpf/logs/mcp_operations.log
        # In Claude Code context:
        # mcp__memory__search_nodes("status:complete entityType:module")
    fi

    # Fall back to state file
    if [ -f "$state_file" ] && command -v jq &> /dev/null; then
        jq -r '.completed_modules[]' "$state_file" 2>/dev/null
        return 0
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# CONTEXT TRACKING
# ═══════════════════════════════════════════════════════════════════════

# Update context usage
update_context_usage() {
    local tokens="$1"
    local percent="$2"
    local state_file="${3:-.cpf/state/master_state.json}"

    if command -v jq &> /dev/null && [ -f "$state_file" ]; then
        local updated_state=$(jq ".context_tracking.current_tokens = $tokens | .context_tracking.percent_used = $percent" "$state_file")
        echo "$updated_state" > "$state_file"

        # Log to MCP
        if mcp_memory_is_available; then
            mcp_add_observation "context_tracking" "Tokens: $tokens ($percent%)"
        fi

        echo "✓ Context updated: $tokens tokens ($percent%)"
        return 0
    fi

    return 1
}

# Check if checkpoint needed
check_checkpoint_threshold() {
    local state_file="${1:-.cpf/state/master_state.json}"
    local threshold="${2:-65}"

    if [ -f "$state_file" ] && command -v jq &> /dev/null; then
        local current_percent=$(jq -r '.context_tracking.percent_used // 0' "$state_file")

        if [ "${current_percent%.*}" -ge "$threshold" ]; then
            echo "CHECKPOINT_NEEDED"
            return 0
        else
            echo "OK"
            return 1
        fi
    fi

    echo "UNKNOWN"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# SESSION MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════

# Start new session
start_session() {
    local state_file="${1:-.cpf/state/master_state.json}"

    if command -v jq &> /dev/null && [ -f "$state_file" ]; then
        local session_id=$(jq -r '.session.session_id // 0' "$state_file")
        local new_session_id=$((session_id + 1))
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        local updated_state=$(jq ".session.session_id = $new_session_id | .session.started_at = \"$timestamp\" | .session.status = \"active\"" "$state_file")
        echo "$updated_state" > "$state_file"

        # Log to MCP
        if mcp_memory_is_available; then
            echo "[MCP] New session started: $new_session_id" >> .cpf/logs/mcp_operations.log
        fi

        echo "✓ Session started: #$new_session_id"
        return 0
    fi

    return 1
}

# End session
end_session() {
    local state_file="${1:-.cpf/state/master_state.json}"

    if command -v jq &> /dev/null && [ -f "$state_file" ]; then
        local updated_state=$(jq '.session.status = "completed"' "$state_file")
        echo "$updated_state" > "$state_file"

        # Save final snapshot
        save_state_snapshot "$state_file" "session_end_$(date +%Y%m%d_%H%M%S)"

        echo "✓ Session ended"
        return 0
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# RECOVERY
# ═══════════════════════════════════════════════════════════════════════

# Restore from snapshot
restore_from_snapshot() {
    local snapshot_name="$1"
    local state_file="${2:-.cpf/state/master_state.json}"
    local snapshot_dir=".cpf/state/snapshots"

    if [ -f "$snapshot_dir/${snapshot_name}.json" ]; then
        cp "$snapshot_dir/${snapshot_name}.json" "$state_file"
        echo "✓ State restored from snapshot: $snapshot_name"
        return 0
    fi

    # Try MCP if available
    if mcp_memory_is_available; then
        echo "[MCP] Would search for snapshot: $snapshot_name" >> .cpf/logs/mcp_operations.log
        # In Claude Code context:
        # mcp__memory__search_nodes("state_snapshot_$snapshot_name")
    fi

    echo "Error: Snapshot not found: $snapshot_name" >&2
    return 1
}

# List available snapshots
list_snapshots() {
    local snapshot_dir=".cpf/state/snapshots"

    if [ -d "$snapshot_dir" ]; then
        echo "Available snapshots:"
        ls -1t "$snapshot_dir"/*.json 2>/dev/null | while read -r file; do
            local name=$(basename "$file" .json)
            local size=$(wc -c < "$file" | tr -d ' ')
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1-2)
            echo "  $name (${size} bytes, $date)"
        done
        return 0
    fi

    echo "No snapshots found"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

# If called directly, run command
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    command="$1"
    shift

    case "$command" in
        update)
            update_master_state "$@"
            ;;
        get)
            get_state_value "$@"
            ;;
        snapshot)
            save_state_snapshot "$@"
            ;;
        complete)
            complete_module "$@"
            ;;
        list-completed)
            get_completed_modules "$@"
            ;;
        check-checkpoint)
            check_checkpoint_threshold "$@"
            ;;
        start-session)
            start_session "$@"
            ;;
        end-session)
            end_session "$@"
            ;;
        restore)
            restore_from_snapshot "$@"
            ;;
        list-snapshots)
            list_snapshots "$@"
            ;;
        mcp-status)
            mcp_status_summary
            ;;
        *)
            echo "Usage: $0 {update|get|snapshot|complete|list-completed|check-checkpoint|start-session|end-session|restore|list-snapshots|mcp-status}"
            exit 1
            ;;
    esac
fi
