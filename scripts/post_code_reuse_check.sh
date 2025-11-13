#!/bin/bash
#
# post_code_reuse_check.sh - RULE 9 Enforcement
#
# Purpose: Detect potential code duplication AFTER Write on code files
# Trigger: PostToolUse hook after Write on code files
# Rule: RULE 9 - Code Reuse Mandatory
# Version: 1.0.0
# Date: 2025-11-13
#
# Searches for similar function names/signatures to encourage code reuse
# Does not block (similarity doesn't always mean duplication) but raises awareness
#
# Exit codes:
# 0 - Always (warnings only, never blocks)
#

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get file path from tool result
FILE_PATH="${FILE_PATH:-$1}"

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Only check code files
case "${FILE_PATH##*.}" in
    py|js|ts|tsx|jsx|go|rs|java|cpp|hpp|c|h)
        # Code file - proceed with check
        ;;
    *)
        # Not a code file - skip
        exit 0
        ;;
esac

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 POST-CODE-REUSE CHECK (RULE 9 - Code Reuse Mandatory)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "File: $FILE_PATH"
echo ""

# Extract function/class names from the new file
FUNCTIONS=()

case "${FILE_PATH##*.}" in
    py)
        # Python: def function_name or class ClassName
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*def[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]] || \
               [[ "$line" =~ ^[[:space:]]*class[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
                FUNCTIONS+=("${BASH_REMATCH[1]}")
            fi
        done < "$FILE_PATH"
        ;;
    js|ts|tsx|jsx)
        # JavaScript/TypeScript: function name or const name =
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]] || \
               [[ "$line" =~ ^[[:space:]]*const[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*= ]] || \
               [[ "$line" =~ ^[[:space:]]*export[[:space:]]+function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
                FUNCTIONS+=("${BASH_REMATCH[1]}")
            fi
        done < "$FILE_PATH"
        ;;
    go)
        # Go: func FunctionName
        while IFS= read -r line; do
            if [[ "$line" =~ ^func[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*) ]]; then
                FUNCTIONS+=("${BASH_REMATCH[1]}")
            fi
        done < "$FILE_PATH"
        ;;
esac

if [ ${#FUNCTIONS[@]} -eq 0 ]; then
    echo -e "${BLUE}ⓘ No functions/classes detected in file${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi

echo "Found ${#FUNCTIONS[@]} functions/classes:"
for func in "${FUNCTIONS[@]}"; do
    echo "  - $func"
done
echo ""

# Search for similar function names in the codebase
SIMILAR_FOUND=()

echo "Searching for similar names in codebase..."
echo ""

for func in "${FUNCTIONS[@]}"; do
    # Skip common/generic names
    if [[ "$func" =~ ^(main|init|test|setup|teardown|get|set|run)$ ]]; then
        continue
    fi

    # Search for similar function names
    SIMILAR_FILES=$(grep -r -l "\b${func}\b" --include="*.${FILE_PATH##*.}" . 2>/dev/null | grep -v "$FILE_PATH" | head -3)

    if [ -n "$SIMILAR_FILES" ]; then
        SIMILAR_FOUND+=("$func: $(echo "$SIMILAR_FILES" | tr '\n' ', ' | sed 's/,$//')")
    fi
done

# Report results
if [ ${#SIMILAR_FOUND[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED: No obvious code duplication detected${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${YELLOW}⚠️  WARNING: Potentially similar code found${NC}"
    echo ""
    echo "Similar function/class names found elsewhere:"
    for item in "${SIMILAR_FOUND[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $item"
    done
    echo ""
    echo "RULE 9 RECOMMENDATION:"
    echo "  - Review the similar code in other files"
    echo "  - If functionality is similar, consider reusing existing code"
    echo "  - If reuse is possible, import and use existing functions"
    echo "  - If modification is needed, extend existing code"
    echo "  - Only create new code if truly different functionality"
    echo ""
    echo "Benefits of code reuse:"
    echo "  - Reduces codebase size and complexity"
    echo "  - Easier maintenance (fix once, apply everywhere)"
    echo "  - Fewer bugs (tested code is more reliable)"
    echo "  - Consistent behavior across modules"
    echo ""
    echo "When duplication is acceptable:"
    echo "  - Different domains/modules with similar logic"
    echo "  - Performance-critical code that needs specialization"
    echo "  - Temporary implementation being refactored"
    echo "  - Test code vs production code"
    echo ""
    echo -e "${YELLOW}[INFO]${NC} This is a warning only - operation not blocked"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi
