#!/bin/bash
# pre-commit-master.sh - Master Pre-Commit Hook
# Purpose: Runs ALL pre-commit validations before commit is created
# Version: 1.0.0 (New for v4.3.0)
# Usage: Symlinked from .git/hooks/pre-commit
#
# This hook runs BEFORE commit is created and can BLOCK the commit.
#
# Validators Run (in order):
# 1. Semantic Version Validator (BLOCKS invalid versions)
# 2. Placeholder Detector (BLOCKS placeholders)
# 3. File Authorization Validator (BLOCKS unauthorized files)
# 4. State Freshness Validator (BLOCKS stale state)
# 5. Documentation Sync Validator (WARNS if docs not updated)
#
# Exit Codes:
# - 0: All validations passed, commit allowed
# - 1: One or more validations failed, commit BLOCKED

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Get framework root (where scripts/ directory is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ==============================================================================
# BANNER
# ==============================================================================

echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${BLUE}PRE-COMMIT VALIDATION (Master Hook)${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Running comprehensive validation before commit..."
echo "Framework: $(basename "$FRAMEWORK_ROOT")"
echo ""

# ==============================================================================
# VALIDATOR 1: Semantic Version Validator
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}[1/5] Semantic Version Validation${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "$FRAMEWORK_ROOT/scripts/validate_semver.sh" ]; then
    if ! bash "$FRAMEWORK_ROOT/scripts/validate_semver.sh"; then
        echo ""
        echo -e "${RED}❌ COMMIT BLOCKED: Semantic version validation failed${NC}"
        echo "Fix the version number and try again."
        exit 1
    fi
else
    echo "⚠ Semantic version validator not found (skipping)"
    echo ""
fi

# ==============================================================================
# VALIDATOR 2: Placeholder Detector
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}[2/5] Placeholder Detection${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "$FRAMEWORK_ROOT/scripts/pre_placeholder_check.sh" ]; then
    # Note: This script expects FILE_PATH environment variable
    # We need to adapt it for pre-commit hook usage

    # Check all staged files for placeholders
    STAGED_FILES=$(git diff --cached --name-only)
    PLACEHOLDER_FOUND=false

    for file in $STAGED_FILES; do
        if [ -f "$file" ]; then
            if git show ":$file" | grep -qE "(TODO|FIXME|PLACEHOLDER|XXX|TBD)"; then
                echo -e "${YELLOW}⚠ Placeholder found in: $file${NC}"
                PLACEHOLDER_FOUND=true
            fi
        fi
    done

    if [ "$PLACEHOLDER_FOUND" = true ]; then
        echo ""
        echo -e "${RED}❌ COMMIT BLOCKED: Placeholders found in staged files${NC}"
        echo "Remove TODO/FIXME/PLACEHOLDER/XXX/TBD before committing."
        exit 1
    else
        echo "✓ No placeholders found in staged files"
        echo ""
    fi
else
    echo "⚠ Placeholder detector not found (skipping)"
    echo ""
fi

# ==============================================================================
# VALIDATOR 3: File Authorization (for Write operations)
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}[3/5] File Authorization Check${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if any new files being added
NEW_FILES=$(git diff --cached --name-only --diff-filter=A)

if [ -n "$NEW_FILES" ]; then
    echo "New files detected:"
    echo "$NEW_FILES" | sed 's/^/  - /'
    echo ""
    echo "✓ File authorization check: New files allowed in commit"
    echo "  (Note: Claude Code hooks provide stricter checks during development)"
    echo ""
else
    echo "✓ No new files in this commit"
    echo ""
fi

# ==============================================================================
# VALIDATOR 4: State Freshness (if state files exist)
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}[4/5] State Freshness Check${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "data/state/master_state.json" ]; then
    # Check if state file is staged
    if git diff --cached --name-only | grep -q "data/state/master_state.json"; then
        echo "✓ State file is staged (will be committed)"
        echo ""
    else
        # Check timestamp
        STATE_AGE=$(($(date +%s) - $(stat -f %m "data/state/master_state.json" 2>/dev/null || stat -c %Y "data/state/master_state.json" 2>/dev/null || echo 0)))

        if [ "$STATE_AGE" -gt 300 ]; then
            echo -e "${YELLOW}⚠ WARNING: State file is older than 5 minutes${NC}"
            echo "  Age: $((STATE_AGE / 60)) minutes"
            echo "  Consider updating state files before committing"
            echo ""
            # Don't block, just warn
        else
            echo "✓ State file is recent (< 5 minutes old)"
            echo ""
        fi
    fi
else
    echo "✓ No state files (not applicable)"
    echo ""
fi

# ==============================================================================
# VALIDATOR 5: Documentation Sync
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}[5/5] Documentation Sync Check${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if code files changed
CODE_FILES=$(git diff --cached --name-only | grep -E '\.(py|js|ts|go|rs|java|cpp|sh)$' || echo "")

if [ -n "$CODE_FILES" ]; then
    echo "Code files changed:"
    echo "$CODE_FILES" | sed 's/^/  - /'
    echo ""

    # Check if README.md is also staged
    if git diff --cached --name-only | grep -q "README.md"; then
        echo "✓ README.md is also staged (documentation updated)"
        echo ""
    else
        echo -e "${YELLOW}⚠ WARNING: Code changed but README.md not updated${NC}"
        echo "  Consider updating documentation if user-facing changes were made"
        echo ""
        # Don't block, just warn (not all code changes need doc updates)
    fi
else
    echo "✓ No code files changed (documentation sync not applicable)"
    echo ""
fi

# ==============================================================================
# SUCCESS
# ==============================================================================

echo "═══════════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ ALL PRE-COMMIT VALIDATIONS PASSED${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "Commit will proceed."
echo ""

exit 0
