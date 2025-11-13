#!/bin/bash
# pre_git_check.sh - RULE 16 Proactive Enforcement
# Purpose: Validate git operations BEFORE execution
# Version: 1.0.0

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMMAND="${COMMAND:-}"

# Only check git commands
if ! echo "$COMMAND" | grep -q "^git"; then
    exit 0
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🔧 PRE-GIT CHECK (RULE 16 - Git Operations)"
echo "═══════════════════════════════════════════════════════════════════════"

# Block dangerous operations
DANGEROUS_PATTERNS=(
    "push.*--force"
    "push.*-f"
    "reset.*--hard"
    "clean.*-fd"
    "branch.*-D"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
        echo -e "❌ BLOCKED: Dangerous git operation"
        echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${RED}RULE 16 VIOLATION: Potentially destructive git command${NC}"
        echo "Command: $COMMAND"
        echo ""
        echo "REQUIRED ACTION:"
        echo "  Get explicit user approval for destructive operations"
        echo ""
        echo -e "${RED}OPERATION BLOCKED - Dangerous git command${NC}"
        exit 2  # BLOCKS dangerous git commands
    fi
done

echo -e "${GREEN}✅ Git command safe to execute${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
exit 0
