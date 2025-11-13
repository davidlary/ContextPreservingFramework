#!/bin/bash
# mcp_lib.sh - MCP Integration Library
# Version: 1.0.0
# Purpose: Wrapper functions for MCP operations with graceful degradation

set -euo pipefail

# This library provides high-level functions that use MCP when available
# and fall back to file-based storage when MCP is not available

# Source MCP detection if not already loaded
if [ -z "$MCP_AVAILABLE" ]; then
    if [ -f ".cpf/mcp_status.sh" ]; then
        source .cpf/mcp_status.sh
    else
        # Default to not available
        export MCP_AVAILABLE="false"
        export MCP_MEMORY_AVAILABLE="false"
        export MCP_FILESYSTEM_AVAILABLE="false"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════

# Save state (dual storage: JSON + MCP)
mcp_save_state() {
    local state_data="$1"
    local state_file="${2:-.cpf/state/master_state.json}"

    # Always save to JSON (primary/fallback)
    echo "$state_data" > "$state_file"
    local json_status=$?

    # If MCP available, also save to memory server
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        # Note: Actual MCP calls would happen in Claude Code context
        # This is a placeholder that logs the intent
        echo "[MCP] Would call: mcp__memory__create_entities for master_state" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__create_entities([{
        #     name: "master_state",
        #     entityType: "state",
        #     observations: ["$state_data"]
        # }])
    fi

    return $json_status
}

# Load state (try MCP first, fall back to JSON)
mcp_load_state() {
    local state_file="${1:-.cpf/state/master_state.json}"

    # Try MCP memory first if available
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__search_nodes for master_state" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # result=$(mcp__memory__search_nodes("master_state"))
        # if [ -n "$result" ]; then
        #     echo "$result"
        #     return 0
        # fi
    fi

    # Fall back to JSON file
    if [ -f "$state_file" ]; then
        cat "$state_file"
        return 0
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# MODULE MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════

# Save module summary
mcp_save_module_summary() {
    local module_id="$1"
    local summary="$2"
    local summary_dir="${3:-.claude/summaries}"

    mkdir -p "$summary_dir"

    # Always save to file (primary)
    echo "$summary" > "$summary_dir/${module_id}.md"
    local file_status=$?

    # If MCP available, also save to memory server
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__create_entities for module $module_id" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__create_entities([{
        #     name: "$module_id",
        #     entityType: "module",
        #     observations: ["$summary"]
        # }])
    fi

    return $file_status
}

# Search modules (semantic search with MCP, grep fallback)
mcp_search_modules() {
    local search_term="$1"
    local summary_dir="${2:-.claude/summaries}"

    # Try MCP semantic search first
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__search_nodes for '$search_term'" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__search_nodes("$search_term")
        # return $?
    fi

    # Fall back to grep search in summary files
    if [ -d "$summary_dir" ]; then
        grep -r -l "$search_term" "$summary_dir" 2>/dev/null
        return 0
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# DEPENDENCY TRACKING
# ═══════════════════════════════════════════════════════════════════════

# Track module dependency
mcp_track_dependency() {
    local from_module="$1"
    local to_module="$2"
    local relation_type="${3:-depends_on}"
    local plan_file="${4:-.claude/plan.json}"

    # Always update plan.json (primary)
    if [ -f "$plan_file" ] && command -v jq &> /dev/null; then
        jq ".dependencies[\"$from_module\"] += [\"$to_module\"]" "$plan_file" > "${plan_file}.tmp"
        mv "${plan_file}.tmp" "$plan_file"
    fi

    # If MCP available, also track relationship
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__create_relations for $from_module -> $to_module" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__create_relations([{
        #     from: "$from_module",
        #     to: "$to_module",
        #     relationType: "$relation_type"
        # }])
    fi

    return 0
}

# Get module dependencies
mcp_get_dependencies() {
    local module_id="$1"
    local plan_file="${2:-.claude/plan.json}"

    # Try MCP first
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__get_relations for $module_id" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__get_relations("$module_id")
        # return $?
    fi

    # Fall back to plan.json
    if [ -f "$plan_file" ] && command -v jq &> /dev/null; then
        jq -r ".dependencies[\"$module_id\"] // []" "$plan_file"
        return 0
    fi

    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# OBSERVATION TRACKING
# ═══════════════════════════════════════════════════════════════════════

# Add observation to module
mcp_add_observation() {
    local module_id="$1"
    local observation="$2"
    local log_file="${3:-.cpf/logs/observations.log}"

    # Always log to file
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | $module_id | $observation" >> "$log_file"

    # If MCP available, also add to memory server
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[MCP] Would call: mcp__memory__add_observations for $module_id" >> .cpf/logs/mcp_operations.log
        # In actual use within Claude Code:
        # mcp__memory__add_observations("$module_id", ["$observation"])
    fi

    return 0
}

# ═══════════════════════════════════════════════════════════════════════
# CONTEXT RECOVERY
# ═══════════════════════════════════════════════════════════════════════

# Recover context from MCP or checkpoints
mcp_recover_context() {
    local checkpoint_dir="${1:-.claude/checkpoints}"

    echo "═══════════════════════════════════════════════════════════════════════"
    echo "Context Recovery"
    echo "═══════════════════════════════════════════════════════════════════════"

    # Try MCP memory first
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        echo "[1/2] Attempting MCP memory recovery..."
        echo "[MCP] Would call: mcp__memory__search_nodes for completed modules" >> .cpf/logs/mcp_operations.log

        # In actual use within Claude Code:
        # completed=$(mcp__memory__search_nodes("status:complete"))
        # current=$(mcp__memory__search_nodes("status:in_progress"))
        # if [ -n "$completed" ]; then
        #     echo "✓ Recovered from MCP memory"
        #     echo "  Completed modules: $completed"
        #     echo "  Current module: $current"
        #     return 0
        # fi

        echo "  ℹ MCP memory recovery not available in bash context"
    fi

    # Fall back to checkpoint files
    echo "[2/2] Using checkpoint file recovery..."
    if [ -d "$checkpoint_dir" ]; then
        local latest_checkpoint=$(ls -t "$checkpoint_dir"/*.json 2>/dev/null | head -1)
        if [ -n "$latest_checkpoint" ]; then
            echo "✓ Found checkpoint: $latest_checkpoint"
            cat "$latest_checkpoint"
            return 0
        fi
    fi

    echo "✗ No recovery data found"
    return 1
}

# ═══════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════

# Check if MCP is operational
mcp_is_available() {
    [ "$MCP_AVAILABLE" = "true" ]
    return $?
}

# Check if memory server is available
mcp_memory_is_available() {
    [ "$MCP_MEMORY_AVAILABLE" = "true" ]
    return $?
}

# Get MCP status summary
mcp_status_summary() {
    echo "MCP Integration Status:"
    echo "  Overall: $MCP_AVAILABLE"
    echo "  Memory Server: $MCP_MEMORY_AVAILABLE"
    echo "  Filesystem Server: $MCP_FILESYSTEM_AVAILABLE"

    if [ "$MCP_AVAILABLE" = "true" ]; then
        echo "  Mode: Enhanced (MCP + File-based)"
    else
        echo "  Mode: Standard (File-based only)"
    fi
}

# Initialize MCP operations log
mcp_init_log() {
    local log_file="${1:-.cpf/logs/mcp_operations.log}"
    mkdir -p "$(dirname "$log_file")"

    if [ ! -f "$log_file" ]; then
        cat > "$log_file" <<EOF
═══════════════════════════════════════════════════════════════════════
MCP Operations Log
═══════════════════════════════════════════════════════════════════════
Framework Version: 4.4.0
Initialized: $(date)

This log tracks MCP operations (actual or intended).
Operations logged here would execute as mcp__* calls in Claude Code context.

═══════════════════════════════════════════════════════════════════════
EOF
    fi
}

# Export all functions
export -f mcp_save_state
export -f mcp_load_state
export -f mcp_save_module_summary
export -f mcp_search_modules
export -f mcp_track_dependency
export -f mcp_get_dependencies
export -f mcp_add_observation
export -f mcp_recover_context
export -f mcp_is_available
export -f mcp_memory_is_available
export -f mcp_status_summary
export -f mcp_init_log
