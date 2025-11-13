#!/bin/bash
#
# user_prompt_submit_autonomous.sh - RULE 11 Ultimate Enforcement
#
# Purpose: BLOCK user prompts containing permission-requesting phrases
# Trigger: UserPromptSubmit hook (runs when user submits a prompt)
# Rule: RULE 11 - Autonomous Execution Mode
# Version: 1.0.0
# Date: 2025-11-13
#
# CRITICAL FIX: This COMPLETELY ELIMINATES permission-requesting behavior
#
# How it works:
# 1. Intercepts user prompt BEFORE it reaches Claude
# 2. Scans for permission-requesting phrases
# 3. If detected: BLOCKS the prompt (exit 2) and shows error
# 4. User sees clear message: "You have FULL PERMISSION - proceed without asking"
# 5. This is the ULTIMATE enforcement - prevents even the question from being asked
#
# Exit codes:
# 0 - Allow prompt (no permission-requesting detected)
# 2 - BLOCK prompt (permission-requesting detected)
#

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get user's prompt from environment or argument
# UserPromptSubmit hooks receive the prompt in $USER_PROMPT environment variable
USER_PROMPT="${USER_PROMPT:-${1:-}}"

if [ -z "$USER_PROMPT" ]; then
    # No prompt provided (shouldn't happen, but handle gracefully)
    exit 0
fi

# Check if AUTONOMOUS_MODE is active
AUTONOMOUS_ACTIVE=false
if [ -f ".claude/session/autonomous_mode" ]; then
    if grep -q "AUTONOMOUS_MODE=true" ".claude/session/autonomous_mode" 2>/dev/null; then
        AUTONOMOUS_ACTIVE=true
    fi
elif [ -f "AUTONOMOUS_MODE.md" ]; then
    if grep -q "STATUS:\s*\(ACTIVE\|ENABLED\)" "AUTONOMOUS_MODE.md" 2>/dev/null; then
        AUTONOMOUS_ACTIVE=true
    fi
fi

# If autonomous mode not active, allow all prompts
if [ "$AUTONOMOUS_ACTIVE" != "true" ]; then
    exit 0
fi

# Define permission-requesting patterns (case-insensitive)
PERMISSION_PATTERNS=(
    "may I"
    "can I"
    "should I"
    "is it okay"
    "is it ok"
    "allowed to"
    "permission to"
    "do I have permission"
    "am I allowed"
    "okay to"
    "ok to"
    "alright to"
    "would you like me to"
    "shall I"
    "do you want me to"
    "is this acceptable"
    "is this allowed"
)

# Check for permission-requesting patterns
VIOLATION_FOUND=false
MATCHED_PATTERN=""

for pattern in "${PERMISSION_PATTERNS[@]}"; do
    # Case-insensitive grep
    if echo "$USER_PROMPT" | grep -iq "$pattern"; then
        VIOLATION_FOUND=true
        MATCHED_PATTERN="$pattern"
        break
    fi
done

# If no violation, allow prompt
if [ "$VIOLATION_FOUND" != "true" ]; then
    exit 0
fi

# VIOLATION DETECTED - BLOCK PROMPT
echo -e "${RED}═══════════════════════════════════════════════════════════════════════"
echo -e "❌ BLOCKED: Permission-Requesting Prompt Detected"
echo -e "═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}RULE 11 VIOLATION: Autonomous mode is ACTIVE${NC}"
echo "Matched pattern: '$MATCHED_PATTERN'"
echo ""
echo -e "${BOLD}YOU HAVE FULL AUTONOMOUS PERMISSION${NC}"
echo ""
echo "Autonomous mode grants you permission to:"
echo "  ✓ Create, edit, delete files"
echo "  ✓ Run commands and tests"
echo "  ✓ Make decisions"
echo "  ✓ Commit changes"
echo "  ✓ Push to remote"
echo "  ✓ Complete tasks systematically"
echo ""
echo -e "${GREEN}REQUIRED ACTION:${NC}"
echo "  Rephrase your message WITHOUT asking for permission."
echo ""
echo "Examples:"
echo "  ❌ 'May I update the database schema?'"
echo "  ✅ 'I'll update the database schema to add...'"
echo ""
echo "  ❌ 'Should I create a new test file?'"
echo "  ✅ 'Creating test file test_auth.py...'"
echo ""
echo "  ❌ 'Can I proceed with the refactoring?'"
echo "  ✅ 'Proceeding with refactoring...'"
echo ""
echo -e "${YELLOW}Note:${NC} This enforcement exists to eliminate permission-requesting"
echo "       behavior. Autonomous mode means: PROCEED WITHOUT ASKING."
echo ""
echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}OPERATION BLOCKED - Permission request not allowed in autonomous mode${NC}"
echo -e "${RED}═══════════════════════════════════════════════════════════════════════${NC}"

# Exit with code 2 to BLOCK the prompt from reaching Claude
exit 2  # EXIT CODE 2: BLOCKS prompt processing (Claude Code enforcement signal)
