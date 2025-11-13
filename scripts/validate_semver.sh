#!/bin/bash
# validate_semver.sh - Semantic Version Validator
# Purpose: BLOCKS commits with invalid version numbers (prevents going backwards)
# Version: 1.0.0 (New for v4.3.0)
# Usage: Called by pre-commit hook before commit is created
#
# This script would have PREVENTED the v4.0.0 error (v4.1.1 → v4.0.0)
#
# Validates:
# - Version numbers don't go backwards
# - Version numbers follow semantic versioning (MAJOR.MINOR.PATCH)
# - Version changes are appropriate for changes made
#
# Exit Codes:
# - 0: Version valid or no version change detected
# - 1: Version invalid (BLOCKS commit)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Extract version from file content
extract_version() {
    local file="$1"
    local pattern="$2"

    # Try multiple patterns to find version
    local version=""

    # Pattern 1: **Version**: v1.2.3 (README.md style)
    version=$(grep -E "^\*\*Version\*\*:" "$file" 2>/dev/null | sed -E 's/.*v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || echo "")
    if [ -n "$version" ]; then
        echo "$version"
        return
    fi

    # Pattern 2: "version": "1.2.3" (JSON style)
    version=$(grep -E '"version":\s*"' "$file" 2>/dev/null | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/' || echo "")
    if [ -n "$version" ]; then
        echo "$version"
        return
    fi

    # Pattern 3: Version: 1.2.3 (generic)
    version=$(grep -iE '^[#* ]*version:?\s*v?' "$file" 2>/dev/null | sed -E 's/.*v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -1 || echo "")
    if [ -n "$version" ]; then
        echo "$version"
        return
    fi

    echo ""
}

# Parse version into MAJOR MINOR PATCH
parse_version() {
    local version="$1"

    # Remove 'v' prefix if present
    version="${version#v}"

    # Split into components
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3)

    # Validate components are numbers
    if ! [[ "$major" =~ ^[0-9]+$ ]] || ! [[ "$minor" =~ ^[0-9]+$ ]] || ! [[ "$patch" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid version format: $version" >&2
        return 1
    fi

    echo "$major $minor $patch"
}

# Compare two versions: returns 0 if v1 < v2, 1 if v1 >= v2
version_less_than() {
    local v1="$1"
    local v2="$2"

    read -r major1 minor1 patch1 <<< "$(parse_version "$v1")"
    read -r major2 minor2 patch2 <<< "$(parse_version "$v2")"

    # Compare major
    if [ "$major1" -lt "$major2" ]; then
        return 0
    elif [ "$major1" -gt "$major2" ]; then
        return 1
    fi

    # Major equal, compare minor
    if [ "$minor1" -lt "$minor2" ]; then
        return 0
    elif [ "$minor1" -gt "$minor2" ]; then
        return 1
    fi

    # Major and minor equal, compare patch
    if [ "$patch1" -lt "$patch2" ]; then
        return 0
    else
        return 1
    fi
}

# Validate version transition is valid
validate_transition() {
    local old_version="$1"
    local new_version="$2"

    read -r old_major old_minor old_patch <<< "$(parse_version "$old_version")"
    read -r new_major new_minor new_patch <<< "$(parse_version "$new_version")"

    # Check 1: Version must not go backwards
    if version_less_than "$new_version" "$old_version"; then
        echo -e "${RED}❌ BLOCKED: Version goes backwards${NC}" >&2
        echo "  Previous: v$old_version" >&2
        echo "  New:      v$new_version" >&2
        echo "" >&2
        echo "Semantic versioning ERROR: Version numbers cannot decrease." >&2
        return 1
    fi

    # Check 2: Version must not stay the same (unless no real changes)
    if [ "$old_major" -eq "$new_major" ] && [ "$old_minor" -eq "$new_minor" ] && [ "$old_patch" -eq "$new_patch" ]; then
        echo -e "${YELLOW}⚠ WARNING: Version unchanged${NC}" >&2
        echo "  Version: v$old_version → v$new_version (same)" >&2
        echo "" >&2
        echo "If you made changes, increment the version." >&2
        # Don't block, just warn
        return 0
    fi

    # Check 3: Validate increment is reasonable
    local major_diff=$((new_major - old_major))
    local minor_diff=$((new_minor - old_minor))
    local patch_diff=$((new_patch - old_patch))

    # Major version bump: minor and patch should reset to 0
    if [ "$major_diff" -gt 0 ]; then
        if [ "$new_minor" -ne 0 ] || [ "$new_patch" -ne 0 ]; then
            echo -e "${YELLOW}⚠ WARNING: Major version bump${NC}" >&2
            echo "  Version: v$old_version → v$new_version" >&2
            echo "  Expected: v$new_major.0.0 (minor and patch should reset)" >&2
            echo "" >&2
            # Don't block, just warn (some projects don't follow this convention)
        fi
    fi

    # Minor version bump: patch should reset to 0
    if [ "$major_diff" -eq 0 ] && [ "$minor_diff" -gt 0 ]; then
        if [ "$new_patch" -ne 0 ]; then
            echo -e "${YELLOW}⚠ WARNING: Minor version bump${NC}" >&2
            echo "  Version: v$old_version → v$new_version" >&2
            echo "  Expected: v$new_major.$new_minor.0 (patch should reset)" >&2
            echo "" >&2
            # Don't block, just warn
        fi
    fi

    # Check 4: Version shouldn't skip multiple major/minor versions
    if [ "$major_diff" -gt 1 ]; then
        echo -e "${YELLOW}⚠ WARNING: Skipping major versions${NC}" >&2
        echo "  Version: v$old_version → v$new_version" >&2
        echo "  Skipped: $((major_diff - 1)) major versions" >&2
        echo "" >&2
        echo "Are you sure this is correct?" >&2
        # Don't block, just warn (might be intentional)
    fi

    if [ "$major_diff" -eq 0 ] && [ "$minor_diff" -gt 1 ]; then
        echo -e "${YELLOW}⚠ WARNING: Skipping minor versions${NC}" >&2
        echo "  Version: v$old_version → v$new_version" >&2
        echo "  Skipped: $((minor_diff - 1)) minor versions" >&2
        echo "" >&2
        echo "Are you sure this is correct?" >&2
        # Don't block, just warn
    fi

    return 0
}

# ==============================================================================
# MAIN VALIDATION
# ==============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SEMANTIC VERSION VALIDATION (Pre-Commit)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find version in staged files
STAGED_FILES=$(git diff --cached --name-only)

# Files that might contain version numbers
VERSION_FILES=(
    "README.md"
    "FRAMEWORK_VERSION"
    ".claude/hooks/compliance_enforcement.json"
    "package.json"
    "setup.py"
    "Cargo.toml"
)

NEW_VERSION=""
VERSION_FILE=""

# Check each potential version file
for file in "${VERSION_FILES[@]}"; do
    if echo "$STAGED_FILES" | grep -q "^${file}$"; then
        # File is staged, extract version from staged content
        version=$(git show ":${file}" | grep -E "(Version|version)" | sed -E 's/.*v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -1 || echo "")

        if [ -n "$version" ] && [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NEW_VERSION="$version"
            VERSION_FILE="$file"
            echo "✓ Version detected in staged file: $VERSION_FILE"
            echo "  New version: v$NEW_VERSION"
            break
        fi
    fi
done

# If no version change detected, allow commit
if [ -z "$NEW_VERSION" ]; then
    echo "✓ No version change detected in staged files"
    echo "✓ PASS: Semantic version validation not applicable"
    echo ""
    exit 0
fi

# Get last version from git
echo ""
echo "Checking previous version..."

# Method 1: Try git tags
LAST_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "")

# Method 2: If no tags, try last commit of VERSION_FILE
if [ -z "$LAST_VERSION" ] && [ -n "$VERSION_FILE" ]; then
    LAST_VERSION=$(git show "HEAD:${VERSION_FILE}" 2>/dev/null | grep -E "(Version|version)" | sed -E 's/.*v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/' | head -1 || echo "")
fi

# Method 3: If still no version, try README.md from last commit
if [ -z "$LAST_VERSION" ]; then
    LAST_VERSION=$(git show "HEAD:README.md" 2>/dev/null | grep -E "^\*\*Version\*\*:" | sed -E 's/.*v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || echo "")
fi

# If no previous version found, this might be first versioned commit
if [ -z "$LAST_VERSION" ]; then
    echo "⚠ No previous version found (might be first versioned commit)"
    echo "✓ PASS: Accepting v$NEW_VERSION as initial version"
    echo ""
    exit 0
fi

echo "✓ Previous version: v$LAST_VERSION"
echo ""

# Validate version transition
echo "Validating version transition..."
echo "  Previous: v$LAST_VERSION"
echo "  New:      v$NEW_VERSION"
echo ""

if ! validate_transition "$LAST_VERSION" "$NEW_VERSION"; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${RED}❌ COMMIT BLOCKED: Invalid semantic version${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To fix:"
    echo "  1. Update version in $VERSION_FILE to a valid version"
    echo "  2. Ensure version >= v$LAST_VERSION"
    echo "  3. Try git commit again"
    echo ""
    echo "Semantic Versioning Guide:"
    echo "  - MAJOR version: Incompatible API changes"
    echo "  - MINOR version: Backwards-compatible new features"
    echo "  - PATCH version: Backwards-compatible bug fixes"
    echo ""
    echo "Examples of valid version transitions:"
    echo "  v$LAST_VERSION → v$LAST_VERSION (no change, valid for docs-only)"

    # Suggest next version
    read -r major minor patch <<< "$(parse_version "$LAST_VERSION")"
    echo "  v$LAST_VERSION → v$((major+1)).0.0 (major release)"
    echo "  v$LAST_VERSION → v${major}.$((minor+1)).0 (minor release)"
    echo "  v$LAST_VERSION → v${major}.${minor}.$((patch+1)) (patch release)"
    echo ""

    exit 1
fi

echo -e "${GREEN}✓ PASS: Semantic version validation successful${NC}"
echo "  Version transition is valid: v$LAST_VERSION → v$NEW_VERSION"
echo ""

exit 0
