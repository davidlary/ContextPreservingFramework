#!/bin/bash
#
# post_hardcoding_check.sh - RULE 1 Enforcement
#
# Purpose: Detect hardcoded values AFTER Write/Edit on code files
# Trigger: PostToolUse hook after Write/Edit on code files
# Rule: RULE 1 - Zero Hard-Coding
# Version: 1.0.0
# Date: 2025-11-13
#
# Warns about hardcoded values like URLs, passwords, API keys, magic numbers
# Does not block (some hardcoding is legitimate) but raises awareness
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
echo "🔍 POST-HARDCODING CHECK (RULE 1 - Zero Hard-Coding)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "File: $FILE_PATH"
echo ""

# Define patterns for hardcoded values
WARNINGS=()

# Check for URLs
URL_COUNT=$(grep -E 'https?://|ftp://' "$FILE_PATH" 2>/dev/null | grep -v '^ *//' | grep -v '^#' | wc -l || echo 0)
if [ "$URL_COUNT" -gt 0 ]; then
    WARNINGS+=("URLs hardcoded: $URL_COUNT occurrences")
fi

# Check for potential passwords/secrets
SECRET_COUNT=$(grep -iE 'password|api_key|secret|token' "$FILE_PATH" 2>/dev/null | grep -E '=.*["\']' | grep -v '^ *//' | grep -v '^#' | wc -l || echo 0)
if [ "$SECRET_COUNT" -gt 0 ]; then
    WARNINGS+=("Potential secrets/passwords: $SECRET_COUNT occurrences")
fi

# Check for hardcoded paths
PATH_COUNT=$(grep -E '["\'']/[a-z]+/|["\'']/home/|["\'']/usr/' "$FILE_PATH" 2>/dev/null | grep -v '^ *//' | grep -v '^#' | wc -l || echo 0)
if [ "$PATH_COUNT" -gt 0 ]; then
    WARNINGS+=("Hardcoded paths: $PATH_COUNT occurrences")
fi

# Check for magic numbers (numbers >100 not in const/config lines)
MAGIC_NUMBER_COUNT=$(grep -E '[^a-zA-Z_][0-9]{3,}[^0-9]' "$FILE_PATH" 2>/dev/null | grep -v -iE 'const|config|^#|^ *//' | wc -l || echo 0)
if [ "$MAGIC_NUMBER_COUNT" -gt 5 ]; then
    WARNINGS+=("Possible magic numbers: $MAGIC_NUMBER_COUNT occurrences")
fi

# Check for hardcoded email/IP addresses
EMAIL_COUNT=$(grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$FILE_PATH" 2>/dev/null | grep -v '^ *//' | grep -v '^#' | grep -v example\.com | wc -l || echo 0)
if [ "$EMAIL_COUNT" -gt 0 ]; then
    WARNINGS+=("Email addresses: $EMAIL_COUNT occurrences")
fi

IP_COUNT=$(grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' "$FILE_PATH" 2>/dev/null | grep -v '^ *//' | grep -v '^#' | grep -v '127\.0\.0\.1' | grep -v '0\.0\.0\.0' | wc -l || echo 0)
if [ "$IP_COUNT" -gt 0 ]; then
    WARNINGS+=("IP addresses: $IP_COUNT occurrences")
fi

# Report results
if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED: No obvious hardcoded values detected${NC}"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
else
    echo -e "${YELLOW}⚠️  WARNING: Potential hardcoded values detected${NC}"
    echo ""
    echo "Findings:"
    for warning in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $warning"
    done
    echo ""
    echo "RULE 1 RECOMMENDATION:"
    echo "  - Move hardcoded values to config files (config.json, .env)"
    echo "  - Use environment variables for deployment-specific values"
    echo "  - Store constants in dedicated config modules"
    echo "  - Use database for dynamic configuration"
    echo ""
    echo "Why this matters:"
    echo "  - Hardcoding makes code inflexible"
    echo "  - Difficult to change across environments (dev/staging/prod)"
    echo "  - Security risk if secrets are hardcoded"
    echo "  - Violates DRY principle"
    echo ""
    echo "Legitimate exceptions:"
    echo "  - Protocol names (\"http\", \"https\")"
    echo "  - Standard ports (80, 443, 22)"
    echo "  - Mathematical constants (π, e)"
    echo "  - Example/documentation values"
    echo ""
    echo -e "${YELLOW}[INFO]${NC} This is a warning only - operation not blocked"
    echo "═══════════════════════════════════════════════════════════════════════"
    exit 0
fi
