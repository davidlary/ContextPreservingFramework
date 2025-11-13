#!/bin/bash
# pre_bash_safety_check.sh - RULE 3 Proactive Enforcement
# Purpose: Validate Bash commands for safety BEFORE execution
# Version: 1.0.0

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMAND="${COMMAND:-}"

if [ -z "$COMMAND" ]; then
    exit 0
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🛡️  PRE-BASH SAFETY CHECK (RULE 3 - Zero Silent Failures)"
echo "═══════════════════════════════════════════════════════════════════════"
echo "Command: $COMMAND"

# Check for dangerous patterns
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf \*"
    "rm -rf ~"
    "> /dev/sda"
    "dd if="
    "mkfs"
    ":(){ :|:& };:"  # Fork bomb
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qF "$pattern"; then
        echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
        echo -e "❌ BLOCKED: Extremely dangerous command detected"
        echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${RED}RULE 3 VIOLATION: Command contains dangerous pattern${NC}"
        echo "Pattern: $pattern"
        echo ""
        echo -e "${RED}OPERATION BLOCKED - Dangerous command prevented${NC}"
        exit 2  # BLOCKS dangerous commands
    fi
done

# Warn about commands without error handling
if echo "$COMMAND" | grep -v "set -e" | grep -v "||" | grep -v "&&" | grep -qE "^(curl|wget|git|npm|pip)" 2>/dev/null; then
    echo -e "${YELLOW}[INFO]${NC} Consider adding error handling (|| or && or set -e)"
fi

echo -e "${GREEN}✅ Command appears safe${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
exit 0
