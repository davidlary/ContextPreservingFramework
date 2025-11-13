#!/bin/bash
# common_functions.sh - Shared Functions Library
# Version: 1.0.0
# Purpose: Centralized utilities and definitions for all framework scripts
# Created: 2025-11-13 (v4.5.1 enhancement)
#
# Usage: source "$(dirname "$0")/common_functions.sh"
#
# This library eliminates code duplication across framework scripts by
# providing shared color definitions, logging functions, and utilities.

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# COLOR DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════
# Used by 15+ scripts for consistent color output

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════
# Consistent logging across all scripts

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}✅${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" >&2
    fi
}

# ═══════════════════════════════════════════════════════════════════════
# PATH UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Get the framework root directory
get_framework_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$script_dir/.." && pwd)"
}

# Check if running in framework repository or user project
is_framework_repo() {
    [ -d "$(get_framework_root)/docs/core" ] && [ -f "$(get_framework_root)/CLAUDE.md" ]
}

# Get appropriate directory for .cpf/ or logs/
get_state_dir() {
    if [ -d ".cpf" ]; then
        echo ".cpf"
    elif is_framework_repo; then
        echo "."
    else
        echo ".cpf"
    fi
}

# ═══════════════════════════════════════════════════════════════════════
# JSON UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Check if jq is available
has_jq() {
    command -v jq &> /dev/null
}

# Safely read JSON value with fallback
json_get() {
    local file="$1"
    local path="$2"
    local default="${3:-}"

    if [ ! -f "$file" ]; then
        echo "$default"
        return 1
    fi

    if has_jq; then
        jq -r "$path // \"$default\"" "$file" 2>/dev/null || echo "$default"
    else
        echo "$default"
    fi
}

# ═══════════════════════════════════════════════════════════════════════
# FILE UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Check if file was modified within N seconds
file_modified_within() {
    local file="$1"
    local seconds="$2"

    if [ ! -f "$file" ]; then
        return 1
    fi

    local file_time
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        file_time=$(stat -f %m "$file")
    else
        # Linux
        file_time=$(stat -c %Y "$file")
    fi

    local current_time=$(date +%s)
    local diff=$((current_time - file_time))

    [ "$diff" -le "$seconds" ]
}

# Get file line count
count_lines() {
    local file="$1"
    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# ═══════════════════════════════════════════════════════════════════════
# VALIDATION UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Check if command exists
has_command() {
    command -v "$1" &> /dev/null
}

# Check if running in git repository
in_git_repo() {
    git rev-parse --git-dir &> /dev/null
}

# Get git status (clean/dirty)
git_status_clean() {
    if ! in_git_repo; then
        return 1
    fi

    [ -z "$(git status --porcelain)" ]
}

# ═══════════════════════════════════════════════════════════════════════
# DATE/TIME UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Get current timestamp in ISO 8601 format (UTC)
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get current date (UTC)
get_date() {
    date -u +"%Y-%m-%d"
}

# Get date N days ago (cross-platform)
get_date_ago() {
    local days="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -u -v-${days}d +"%Y-%m-%d"
    else
        # Linux
        date -u -d "${days} days ago" +"%Y-%m-%d"
    fi
}

# ═══════════════════════════════════════════════════════════════════════
# SEPARATOR UTILITIES
# ═══════════════════════════════════════════════════════════════════════

# Print separator line
print_separator() {
    echo "═══════════════════════════════════════════════════════════════════════"
}

print_subseparator() {
    echo "───────────────────────────────────────────────────────────────────────"
}

# Print header with separator
print_header() {
    local title="$1"
    print_separator
    echo "$title"
    print_separator
}

# ═══════════════════════════════════════════════════════════════════════
# LIBRARY METADATA
# ═══════════════════════════════════════════════════════════════════════

export COMMON_FUNCTIONS_VERSION="1.0.0"
export COMMON_FUNCTIONS_LOADED="true"

# Usage check
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being run directly, not sourced
    echo "common_functions.sh - Shared Functions Library v${COMMON_FUNCTIONS_VERSION}"
    echo ""
    echo "This library is meant to be sourced, not executed directly."
    echo ""
    echo "Usage:"
    echo "  source \"\$(dirname \"\$0\")/common_functions.sh\""
    echo ""
    echo "Available functions:"
    echo "  • Color variables: RED, GREEN, YELLOW, BLUE, CYAN, MAGENTA, WHITE, NC"
    echo "  • Logging: log_info, log_success, log_warning, log_error, log_debug"
    echo "  • Path utilities: get_framework_root, is_framework_repo, get_state_dir"
    echo "  • JSON utilities: has_jq, json_get"
    echo "  • File utilities: file_modified_within, count_lines"
    echo "  • Validation: has_command, in_git_repo, git_status_clean"
    echo "  • Date/time: get_timestamp, get_date, get_date_ago"
    echo "  • Separators: print_separator, print_subseparator, print_header"
    echo ""
    exit 0
fi
