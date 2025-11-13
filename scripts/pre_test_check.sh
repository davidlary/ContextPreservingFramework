#!/bin/bash
# pre_test_check.sh - RULE 18 Proactive Enforcement
# Purpose: Ensure tests exist BEFORE allowing commits/checkpoints
# Version: 1.0.0

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if this is a checkpoint-imminent operation
# (triggered before major commits or checkpoint operations)

TOOL_NAME="${TOOL_NAME:-unknown}"

# Only enforce for code commits
if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0  # Only check before Bash commands (like git commit)
fi

COMMAND="${COMMAND:-}"
if ! echo "$COMMAND" | grep -q "git.*commit"; then
    exit 0  # Only enforce for git commits
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo "🧪 PRE-TEST CHECK (RULE 18 - Mandatory Testing)"
echo "═══════════════════════════════════════════════════════════════════════"

# Check if tests directory exists
if [ ! -d "tests" ] && [ ! -d "test" ]; then
    echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
    echo -e "❌ BLOCKED: No tests directory found"
    echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}RULE 18 VIOLATION: Mandatory testing required${NC}"
    echo ""
    echo "REQUIRED ACTION:"
    echo "  1. Create tests/ directory"
    echo "  2. Write tests for your code (>80% coverage)"
    echo "  3. Run tests and ensure 100% passing"
    echo "  4. Then commit"
    echo ""
    echo -e "${RED}OPERATION BLOCKED - Tests required before commit${NC}"
    exit 2  # BLOCKS git commit
fi

# Check if there are recent test files
TEST_COUNT=$(find tests test -name "test_*.py" -o -name "*_test.py" -o -name "*.test.js" -o -name "test_*.sh" 2>/dev/null | wc -l)

if [ "$TEST_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}[WARN]${NC} No test files found"
    echo "       Consider adding tests before committing"
fi

echo -e "${GREEN}✅ Tests directory exists${NC}"
echo "═══════════════════════════════════════════════════════════════════════"
exit 0
