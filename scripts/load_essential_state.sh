#!/bin/bash
# Selective State Loading - Context Optimization
# Purpose: Load only essential fields from state files for recovery
# Reduces context usage from ~2-3K tokens → ~1K tokens
# Version: 1.0.0
# Created: 2025-11-13

set -euo pipefail

# Configuration
STATE_FILE="${1:-data/state/master_state.json}"
CONTEXT_FILE="${2:-data/state/context_tracking.json}"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" >&2
}

log_detail() {
    echo -e "${BLUE}[DETAIL]${NC} $*" >&2
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is required but not installed" >&2
    exit 1
fi

# Check if state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo "ERROR: State file not found: $STATE_FILE" >&2
    exit 1
fi

# Load essential fields from master_state.json
load_essential_state() {
    log_info "Loading essential state from $STATE_FILE"

    # Extract only the essential fields needed for recovery
    jq '{
        project: .project,
        version: .version,
        current_phase: .current_phase,
        current_module: .current_module,
        modules_complete: .modules_complete,
        modules_pending: .modules_pending,
        last_update: .last_update,
        framework_version: .framework_version,
        using_own_framework: .using_own_framework
    }' "$STATE_FILE"

    log_detail "Essential state loaded (minimal fields)" >&2
}

# Load essential context tracking
load_essential_context() {
    if [[ ! -f "$CONTEXT_FILE" ]]; then
        log_detail "Context tracking file not found, skipping" >&2
        return
    fi

    log_info "Loading essential context from $CONTEXT_FILE" >&2

    # Extract only current context metrics
    jq '{
        total_operations: .total_operations,
        current_context_tokens: .current_context_tokens,
        current_context_pct: .current_context_pct,
        threshold_critical: .threshold_critical,
        threshold_emergency: .threshold_emergency,
        last_update: .last_update
    }' "$CONTEXT_FILE" 2>/dev/null || echo "{}"

    log_detail "Essential context loaded (current metrics only)" >&2
}

# Get recovery summary (minimal info)
get_recovery_summary() {
    log_info "Recovery Summary:" >&2

    local project=$(jq -r '.project // "Unknown"' "$STATE_FILE")
    local phase=$(jq -r '.current_phase // "unknown"' "$STATE_FILE")
    local module=$(jq -r '.current_module // "none"' "$STATE_FILE")
    local completed=$(jq -r '.modules_complete | length' "$STATE_FILE" 2>/dev/null || echo "0")
    local pending=$(jq -r '.modules_pending | length' "$STATE_FILE" 2>/dev/null || echo "0")
    local last_update=$(jq -r '.last_update // "unknown"' "$STATE_FILE")

    log_detail "  Project: $project" >&2
    log_detail "  Phase: $phase" >&2
    log_detail "  Current Module: $module" >&2
    log_detail "  Completed: $completed modules" >&2
    log_detail "  Pending: $pending modules" >&2
    log_detail "  Last Update: $last_update" >&2

    if [[ -f "$CONTEXT_FILE" ]]; then
        local context_pct=$(jq -r '.current_context_pct // "unknown"' "$CONTEXT_FILE" 2>/dev/null || echo "unknown")
        local ops=$(jq -r '.total_operations // "unknown"' "$CONTEXT_FILE" 2>/dev/null || echo "unknown")
        log_detail "  Context: $context_pct% ($ops operations)" >&2
    fi

    log_info "Ready to resume" >&2
}

# Main function
main() {
    local mode="${3:-essential}"  # essential, context, summary, or all

    case "$mode" in
        essential)
            load_essential_state
            ;;
        context)
            load_essential_context
            ;;
        summary)
            get_recovery_summary
            ;;
        all)
            log_info "Loading all essential data" >&2
            echo "{"
            echo "  \"state\":"
            load_essential_state | sed 's/^/  /'
            echo "  ,\"context\":"
            load_essential_context | sed 's/^/  /'
            echo "}"
            get_recovery_summary >&2
            ;;
        *)
            echo "ERROR: Unknown mode: $mode" >&2
            echo "Usage: $0 [state_file] [context_file] [essential|context|summary|all]" >&2
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
