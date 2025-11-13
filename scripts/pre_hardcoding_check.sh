#!/bin/bash
# pre_hardcoding_check.sh - RULE 1 Proactive Enforcement
# Purpose: Scan for hardcoded values BEFORE Write/Edit
# Version: 1.0.0

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FILE_PATH="${FILE_PATH:-}"
CONTENT="${CONTENT:-}"

# Only check code files
if ! [[ "$FILE_PATH" =~ \.(py|js|ts|go|rs|java|cpp|c|h)$ ]]; then
    exit 0
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔍 PRE-HARDCODING CHECK (RULE 1 - Zero Hard-Coding)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "File: $FILE_PATH"

# Patterns to detect
VIOLATIONS=()

# Check for hardcoded URLs
if echo "$CONTENT" | grep -E 'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | grep -v '# ' | grep -v '//' > /dev/null; then
    VIOLATIONS+=("Hardcoded URL detected (use environment variable or config)")
fi

# Check for hardcoded passwords/secrets
if echo "$CONTENT" | grep -iE '(password|secret|api[_-]?key|token)\s*=\s*["\047][^"\047]{8,}["\047]' | grep -v '# ' > /dev/null; then
    VIOLATIONS+=("Potential hardcoded secret detected (use environment variable)")
fi

# Check for hardcoded IPs
if echo "$CONTENT" | grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | grep -v '127.0.0.1' | grep -v '0.0.0.0' | grep -v 'localhost' | grep -v '# ' > /dev/null; then
    VIOLATIONS+=("Hardcoded IP address detected (use configuration)")
fi

# If violations found, warn (don't block - too strict)
if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════"
    echo -e "⚠️  WARNING: Potential hardcoding detected"
    echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    for violation in "${VIOLATIONS[@]}"; do
        echo -e "${YELLOW}  ⚠  $violation${NC}"
    done
    echo ""
    echo "RECOMMENDATION: Use environment variables or config files"
    echo "═══════════════════════════════════════════════════════════════════════"
    # Don't block - just warn (RULE 1 is advisory for some cases)
    exit 0
fi

echo -e "${GREEN}✅ No obvious hardcoding detected${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
exit 0
