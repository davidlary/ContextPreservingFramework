#!/bin/bash
# PostToolUse Hook: RULE 19 Documentation Detection
# Purpose: Warn if code files change but documentation doesn't
# Enforcement: SHOULD (Tier 2 - Warning only, doesn't block)
# Version: 1.0.0
# Created: 2025-11-13

set -euo pipefail

# Input: File path that was modified
FILE_CHANGED="${1:-}"

# Exit codes
EXIT_SUCCESS=0
EXIT_WARNING=2  # Warning, but don't block

# Color codes for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_detail() {
    echo -e "${BLUE}[DETAIL]${NC} $*" >&2
}

# Check if file is a code file (needs doc updates)
is_code_file() {
    local file="$1"
    [[ "$file" =~ \.(py|js|ts|tsx|jsx|go|rs|java|cpp|c|h|hpp|rb|php)$ ]]
}

# Check if file is a documentation file
is_doc_file() {
    local file="$1"
    [[ "$file" =~ (README|API|ARCHITECTURE|CHANGELOG)\.md$ ]] || [[ "$file" =~ \.md$ ]]
}

# Check if file is a test file (tests don't require doc updates)
is_test_file() {
    local file="$1"
    [[ "$file" =~ (test_|_test\.|\.test\.|\.spec\.|_spec\.) ]] || [[ "$file" =~ ^tests/ ]]
}

# Get recently modified files from git
get_recent_doc_changes() {
    # Check staged files
    local staged_docs=$(git diff --cached --name-only 2>/dev/null | grep -E "(README|API|ARCHITECTURE|CHANGELOG)\.md" || echo "")

    # Check unstaged files
    local unstaged_docs=$(git diff --name-only 2>/dev/null | grep -E "(README|API|ARCHITECTURE|CHANGELOG)\.md" || echo "")

    # Check recent commits (last 10 minutes)
    local recent_docs=$(git log --since="10 minutes ago" --name-only --pretty=format: 2>/dev/null | grep -E "(README|API|ARCHITECTURE|CHANGELOG)\.md" | sort -u || echo "")

    # Combine all (unique)
    echo "$staged_docs $unstaged_docs $recent_docs" | tr ' ' '\n' | grep -v "^$" | sort -u
}

# Get recently modified code files (excluding the current one)
get_recent_code_changes() {
    local current_file="$1"

    # Check staged files
    local staged_code=$(git diff --cached --name-only 2>/dev/null | grep -E "\.(py|js|ts|go|rs|java|cpp)$" || echo "")

    # Check unstaged files
    local unstaged_code=$(git diff --name-only 2>/dev/null | grep -E "\.(py|js|ts|go|rs|java|cpp)$" || echo "")

    # Combine and exclude current file
    echo "$staged_code $unstaged_code" | tr ' ' '\n' | grep -v "^$" | grep -v "^${current_file}$" | sort -u
}

# Suggest which docs might need updating based on code changes
suggest_docs() {
    local file="$1"
    local suggestions=()

    # README.md: User-facing features, installation, usage
    if [[ "$file" =~ (main\.|index\.|app\.|cli\.|install|setup|config) ]]; then
        suggestions+=("README.md")
    fi

    # API.md: API endpoints, public functions
    if [[ "$file" =~ (api|endpoint|route|controller|handler) ]]; then
        suggestions+=("API.md")
    fi

    # ARCHITECTURE.md: New components, major subsystems
    if [[ "$file" =~ (core|component|module|service|engine) ]]; then
        suggestions+=("ARCHITECTURE.md")
    fi

    # CHANGELOG.md: Always consider for significant changes
    suggestions+=("CHANGELOG.md")

    echo "${suggestions[@]}"
}

# Main validation logic
validate_doc_sync() {
    local file="$FILE_CHANGED"

    # Skip if no file specified
    if [[ -z "$file" ]]; then
        return $EXIT_SUCCESS
    fi

    # Skip if file is documentation itself
    if is_doc_file "$file"; then
        log_info "File is documentation, no doc update check needed"
        return $EXIT_SUCCESS
    fi

    # Skip if file is a test
    if is_test_file "$file"; then
        log_info "File is test, no doc update check needed"
        return $EXIT_SUCCESS
    fi

    # Only check code files
    if ! is_code_file "$file"; then
        log_info "File is not code, no doc update check needed"
        return $EXIT_SUCCESS
    fi

    log_info "========================================"
    log_info "RULE 19: Documentation Sync Check"
    log_info "========================================"
    log_detail "Code file modified: $file"

    # Check if documentation was recently updated
    local doc_changes=$(get_recent_doc_changes)

    if [[ -n "$doc_changes" ]]; then
        log_info "✅ RULE 19 COMPLIANCE: Documentation updated recently"
        log_detail "Modified docs: $(echo $doc_changes | tr '\n' ' ')"
        return $EXIT_SUCCESS
    fi

    # Check if multiple code files changed (batch update scenario)
    local other_code=$(get_recent_code_changes "$file")
    local code_count=$(echo "$other_code" | grep -v "^$" | wc -l | tr -d ' ')

    if [[ $code_count -gt 2 ]]; then
        log_warning "⚠️  RULE 19 REMINDER: Multiple code files changed ($((code_count + 1)) total)"
        log_warning "    Consider updating documentation to reflect all changes"
    else
        log_warning "⚠️  RULE 19 REMINDER: Code file changed but no doc updates detected"
    fi

    # Suggest which docs might need updating
    local suggestions=$(suggest_docs "$file")
    if [[ -n "$suggestions" ]]; then
        log_warning "    Suggested docs to consider updating:"
        for doc in $suggestions; do
            if [[ -f "$doc" ]]; then
                log_warning "      - $doc (exists)"
            else
                log_warning "      - $doc (create if needed)"
            fi
        done
    fi

    log_warning ""
    log_warning "RULE 19 GUIDANCE:"
    log_warning "  - If changes are user-facing: Update README.md"
    log_warning "  - If changes affect APIs: Update API.md"
    log_warning "  - If new components added: Update ARCHITECTURE.md"
    log_warning "  - For all significant changes: Update CHANGELOG.md"
    log_warning "  - If docs don't need updating, you can ignore this reminder"
    log_warning ""
    log_info "========================================"

    # Return success (warning only, doesn't block)
    return $EXIT_SUCCESS
}

# Main execution
main() {
    validate_doc_sync
    exit $?
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
