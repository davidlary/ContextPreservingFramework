#!/bin/bash
# log_violation.sh - Centralized violation logging system
# Purpose: Log all rule violations, warnings, and blocks for analysis
# Version: 1.0.0 (Created for v4.5.0 enhancement)
# Usage: source scripts/log_violation.sh && log_violation <rule> <severity> <message> [details]
#
# SEVERITY LEVELS:
# - BLOCK: Operation was blocked (exit 2)
# - WARN: Warning issued (exit 0)
# - INFO: Informational (monitoring data)

set -euo pipefail

# Configuration
PROJECT_ROOT="${PWD}"

# Determine if this is a user project (.cpf/) or framework repository (logs/)
if [ -d ".cpf" ]; then
    # User project structure
    VIOLATIONS_LOG="${PROJECT_ROOT}/.cpf/issues/violations.log"
    VIOLATIONS_JSON="${PROJECT_ROOT}/.cpf/issues/violations.json"
else
    # Framework repository structure
    VIOLATIONS_LOG="${PROJECT_ROOT}/logs/violations.log"
    VIOLATIONS_JSON="${PROJECT_ROOT}/logs/violations.json"
fi

# Ensure directory exists
mkdir -p "$(dirname "$VIOLATIONS_LOG")"

# Initialize JSON file if it doesn't exist
if [ ! -f "$VIOLATIONS_JSON" ]; then
    echo '{"violations": []}' > "$VIOLATIONS_JSON"
fi

# Function to log a violation
log_violation() {
    local rule="$1"
    local severity="$2"
    local message="$3"
    local details="${4:-}"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date_only=$(date -u +"%Y-%m-%d")

    # Log to text file (human-readable)
    echo "[$timestamp] [$severity] $rule: $message" >> "$VIOLATIONS_LOG"
    if [ -n "$details" ]; then
        echo "  Details: $details" >> "$VIOLATIONS_LOG"
    fi

    # Log to JSON (machine-readable)
    if command -v jq &> /dev/null; then
        local entry=$(jq -n \
            --arg ts "$timestamp" \
            --arg date "$date_only" \
            --arg rule "$rule" \
            --arg sev "$severity" \
            --arg msg "$message" \
            --arg det "$details" \
            '{timestamp: $ts, date: $date, rule: $rule, severity: $sev, message: $msg, details: $det}')

        # Add entry to violations array
        jq ".violations += [$entry]" "$VIOLATIONS_JSON" > "${VIOLATIONS_JSON}.tmp" && \
            mv "${VIOLATIONS_JSON}.tmp" "$VIOLATIONS_JSON"
    fi
}

# Function to get violation stats
get_violation_stats() {
    local period="${1:-7}"  # Default: last 7 days

    if [ ! -f "$VIOLATIONS_JSON" ] || ! command -v jq &> /dev/null; then
        echo "No violation data available or jq not installed"
        return 1
    fi

    local cutoff_date=$(date -u -v-${period}d +"%Y-%m-%d" 2>/dev/null || date -u -d "${period} days ago" +"%Y-%m-%d" 2>/dev/null || date -u +"%Y-%m-%d")

    echo "=== Violation Statistics (Last $period days) ==="
    echo ""

    # Total violations
    local total=$(jq --arg date "$cutoff_date" '.violations | map(select(.date >= $date)) | length' "$VIOLATIONS_JSON")
    echo "Total violations: $total"
    echo ""

    # By severity
    echo "By Severity:"
    jq --arg date "$cutoff_date" -r '
        .violations
        | map(select(.date >= $date))
        | group_by(.severity)
        | map({severity: .[0].severity, count: length})
        | .[]
        | "  \(.severity): \(.count)"
    ' "$VIOLATIONS_JSON"
    echo ""

    # By rule
    echo "By Rule (Top 10):"
    jq --arg date "$cutoff_date" -r '
        .violations
        | map(select(.date >= $date))
        | group_by(.rule)
        | map({rule: .[0].rule, count: length})
        | sort_by(.count)
        | reverse
        | .[:10]
        | .[]
        | "  \(.rule): \(.count)"
    ' "$VIOLATIONS_JSON"
}

# Function to export violations for analysis
export_violations() {
    local output_file="${1:-violations_export_$(date +%Y%m%d).json}"

    if [ ! -f "$VIOLATIONS_JSON" ]; then
        echo "No violations to export"
        return 1
    fi

    cp "$VIOLATIONS_JSON" "$output_file"
    echo "Violations exported to: $output_file"
}

# Function to clear old violations (retention policy)
rotate_violations() {
    local retention_days="${1:-90}"  # Default: keep 90 days

    if [ ! -f "$VIOLATIONS_JSON" ] || ! command -v jq &> /dev/null; then
        return 0
    fi

    local cutoff_date=$(date -u -v-${retention_days}d +"%Y-%m-%d" 2>/dev/null || date -u -d "${retention_days} days ago" +"%Y-%m-%d" 2>/dev/null || date -u +"%Y-%m-%d")

    # Keep only violations after cutoff date
    jq --arg date "$cutoff_date" '.violations = (.violations | map(select(.date >= $date)))' \
        "$VIOLATIONS_JSON" > "${VIOLATIONS_JSON}.tmp" && \
        mv "${VIOLATIONS_JSON}.tmp" "$VIOLATIONS_JSON"

    echo "Rotated violations older than $retention_days days (before $cutoff_date)"
}

# Export functions for use in other scripts
export -f log_violation
export -f get_violation_stats
export -f export_violations
export -f rotate_violations
