#!/bin/bash
# pre_write_check.sh - PreToolUse hook for RULE 2 enforcement
# Purpose: Validate file authorization BEFORE Write operation (proactive)
# Version: 1.0.0 (New in v4.1.0)
# Usage: Called automatically by PreToolUse hook before Write tool executes

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get file path from Write tool arguments
# Tool args are passed as JSON in environment variable TOOL_ARGS
if [ -z "${TOOL_ARGS:-}" ]; then
    # Fallback: try to get from command line argument
    if [ $# -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No tool args provided (skipping pre-write check)${NC}"
        exit 0
    fi
    FILE_PATH="$1"
else
    # Extract file_path from JSON (if jq available)
    if command -v jq &> /dev/null; then
        FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.file_path // empty')
        if [ -z "$FILE_PATH" ]; then
            echo -e "${YELLOW}⚠️  No file_path in tool args (skipping)${NC}"
            exit 0
        fi
    else
        echo -e "${YELLOW}⚠️  jq not available (skipping pre-write check)${NC}"
        exit 0
    fi
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 PRE-WRITE VALIDATION (RULE 2 - Proactive Enforcement)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "File to create: $FILE_PATH"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo ""

# Check if file_manifest.json exists
if [ ! -f "data/state/file_manifest.json" ]; then
    echo -e "${YELLOW}⚠️  No file_manifest.json found (allowing write)${NC}"
    echo "   To enable RULE 2 enforcement, create data/state/file_manifest.json"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Check if enforcement is active
ENFORCEMENT_ACTIVE=$(jq -r '.enforcement_active // false' data/state/file_manifest.json)
if [ "$ENFORCEMENT_ACTIVE" != "true" ]; then
    echo -e "${YELLOW}⚠️  Enforcement disabled in manifest (allowing write)${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

echo "Checking authorization..."

# Check if file is in authorized_files
IS_AUTHORIZED=$(jq -r --arg file "$FILE_PATH" '.authorized_files | index($file) != null' data/state/file_manifest.json)

if [ "$IS_AUTHORIZED" = "true" ]; then
    echo -e "${GREEN}✅ AUTHORIZED: File is in authorized_files list${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# Check if file matches always_allowed_patterns
PATTERNS=$(jq -r '.always_allowed_patterns[]? // empty' data/state/file_manifest.json)
for pattern in $PATTERNS; do
    # Simple glob pattern matching (bash pattern match)
    if [[ "$FILE_PATH" == $pattern ]]; then
        echo -e "${GREEN}✅ AUTHORIZED: File matches pattern '$pattern'${NC}"
        echo "═══════════════════════════════════════════════════════════════════════"
        exit 0
    fi
done

# Check if extension is allowed
EXTENSION="${FILE_PATH##*.}"
IS_EXTENSION_ALLOWED=$(jq -r --arg ext ".$EXTENSION" '.always_allowed_extensions | index($ext) != null' data/state/file_manifest.json)

if [ "$IS_EXTENSION_ALLOWED" = "true" ]; then
    echo -e "${GREEN}✅ AUTHORIZED: Extension '.$EXTENSION' is always allowed${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

# If we get here, file is NOT authorized
echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
echo -e "❌ BLOCKED: Unauthorized file creation attempted"
echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}RULE 2 VIOLATION: $FILE_PATH not authorized in manifest${NC}"
echo ""
echo "REQUIRED ACTIONS (Choose one):"
echo "1. UPDATE existing file instead (if similar file exists)"
echo "2. ASK user for approval and add to manifest"
echo "3. CANCEL operation"
echo ""
echo "Why blocked:"
echo "  - Not in authorized_files list"
echo "  - Doesn't match any always_allowed_patterns"
echo "  - Extension '.$EXTENSION' not in always_allowed_extensions"
echo ""
echo "To authorize this file:"
echo "  1. Add to data/state/file_manifest.json authorized_files array"
echo "  2. OR use AskUserQuestion tool to get user approval"
echo "  3. Then retry Write operation"
echo ""
echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"

# Exit with error to block Write operation
exit 1
