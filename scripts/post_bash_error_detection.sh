#!/bin/bash
# PostToolUse Hook: RULE 3 Error Detection
# Purpose: Detect when Bash commands fail but errors aren't acknowledged
# Enforcement: MUST (Tier 2 - Important, warns loudly about failures)
# Version: 1.0.0
# Created: 2025-11-13

set -euo pipefail

# Input: Exit code and stderr from Bash command
EXIT_CODE="${1:-0}"
STDERR_OUTPUT="${2:-}"
COMMAND="${3:-}"

# Exit codes
EXIT_SUCCESS=0
EXIT_WARNING=0  # Warning, but don't block (Claude should acknowledge error)

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

# Check if command is exempted from error checking
is_exempted_command() {
    local cmd="$1"

    # Commands that are expected to fail sometimes
    # grep with no matches, test commands, conditional checks, etc.
    [[ "$cmd" =~ (grep|test|which|command -v|\[\[.*\]\]|if |while |until ) ]] && return 0

    # Background processes (don't check exit codes)
    [[ "$cmd" =~ (&$|nohup) ]] && return 0

    return 1
}

# Analyze severity of failure
get_failure_severity() {
    local exit_code="$1"
    local stderr="$2"

    # Critical errors (should never be ignored)
    # Updated 2025-11-13: Expanded patterns based on latest research
    if [[ "$stderr" =~ (Permission denied|No such file or directory|Cannot allocate memory|Disk.*full|Connection refused|connection refused|ECONNRESET|Timeout|timeout|timed out|Rate limit|rate limit|429 Too Many Requests|503 Service Unavailable|503 service unavailable|Certificate verify failed|certificate verification failed|Disk quota exceeded|disk quota exceeded|Out of memory|out of memory|OOM|Network is unreachable|network unreachable|ENETUNREACH) ]]; then
        echo "CRITICAL"
        return
    fi

    # High severity
    if [[ $exit_code -ge 126 ]]; then
        # 126: Command not executable
        # 127: Command not found
        # 128+: Fatal signals
        echo "HIGH"
        return
    fi

    # Medium severity
    if [[ $exit_code -gt 0 ]]; then
        echo "MEDIUM"
        return
    fi

    # Stderr only (no exit code)
    if [[ -n "$stderr" ]]; then
        echo "LOW"
        return
    fi

    echo "NONE"
}

# Main validation logic
validate_bash_errors() {
    local has_violations=0

    # Skip if exit code is 0 and no stderr
    if [[ $EXIT_CODE -eq 0 && -z "$STDERR_OUTPUT" ]]; then
        return $EXIT_SUCCESS
    fi

    # Skip exempted commands
    if is_exempted_command "$COMMAND"; then
        log_info "Command exempted from error checking (expected to fail sometimes)"
        return $EXIT_SUCCESS
    fi

    log_warning "========================================"
    log_warning "RULE 3: Bash Error Detection"
    log_warning "========================================"

    if [[ -n "$COMMAND" ]]; then
        log_warning "Command: $COMMAND"
    fi

    # Check exit code
    if [[ $EXIT_CODE -ne 0 ]]; then
        local severity=$(get_failure_severity "$EXIT_CODE" "$STDERR_OUTPUT")

        case "$severity" in
            CRITICAL)
                log_error "❌ RULE 3 CRITICAL: Command failed with exit code $EXIT_CODE"
                log_error "    This is a critical error that MUST be addressed"
                has_violations=1
                ;;
            HIGH)
                log_error "⚠️  RULE 3 HIGH SEVERITY: Command failed with exit code $EXIT_CODE"
                log_error "    This indicates a serious issue (command not found, not executable, or signal)"
                has_violations=1
                ;;
            MEDIUM)
                log_warning "⚠️  RULE 3 WARNING: Command failed with exit code $EXIT_CODE"
                log_warning "    RULE 3 REQUIRES: Acknowledge error and take corrective action"
                ;;
            *)
                log_warning "⚠️  RULE 3 INFO: Command exited with code $EXIT_CODE"
                ;;
        esac
    fi

    # Check stderr output
    if [[ -n "$STDERR_OUTPUT" ]]; then
        log_warning "⚠️  RULE 3 WARNING: Command produced error output on stderr:"
        echo "$STDERR_OUTPUT" | head -20 | while IFS= read -r line; do
            log_warning "    | $line"
        done

        # Count lines
        local line_count=$(echo "$STDERR_OUTPUT" | wc -l | tr -d ' ')
        if [[ $line_count -gt 20 ]]; then
            log_warning "    ... ($((line_count - 20)) more lines)"
        fi
    fi

    # Provide guidance
    log_warning ""
    log_warning "RULE 3 GUIDANCE:"
    log_warning "  - Zero Silent Failures: All errors MUST be surfaced and acknowledged"
    log_warning "  - If error is expected: Document why in response"
    log_warning "  - If error is unexpected: Debug and fix root cause"
    log_warning "  - If error prevents progress: Report to user clearly"
    log_warning "  - Never ignore or suppress errors without explanation"
    log_warning ""
    log_warning "========================================"

    return $EXIT_SUCCESS
}

# Main execution
main() {
    validate_bash_errors
    exit $?
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
