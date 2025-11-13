#!/bin/bash
#
# session_start_autonomous_check.sh - RULE 11 Enforcement
#
# Purpose: Check for AUTONOMOUS_MODE.md at session start and set environment variable
# Trigger: SessionStart hook (runs once at beginning of every Claude Code session)
# Rule: RULE 11 - Autonomous Execution Mode
# Version: 1.0.0
# Date: 2025-11-13
#
# CRITICAL FIX: This addresses user's complaint about "repeatedly asking for permission"
#
# How it works:
# 1. Check if AUTONOMOUS_MODE.md exists in project root
# 2. Check if it contains "STATUS: ACTIVE" or "STATUS: ENABLED"
# 3. If yes: Display clear message that autonomous mode is active
# 4. Export AUTONOMOUS_MODE=true environment variable
# 5. Claude sees this and stops asking for permissions
#
# Exit codes:
# 0 - Always (SessionStart hooks should never block)
#

set -euo pipefail

# ANSI color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Find project root (look for .git or .claude directory)
PROJECT_ROOT="$(pwd)"
if [ -d ".git" ]; then
    PROJECT_ROOT="$(pwd)"
elif [ -d ".claude" ]; then
    PROJECT_ROOT="$(pwd)"
else
    # Search parent directories for .git or .claude
    current_dir="$(pwd)"
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.git" ] || [ -d "$current_dir/.claude" ]; then
            PROJECT_ROOT="$current_dir"
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done
fi

AUTONOMOUS_MODE_FILE="$PROJECT_ROOT/AUTONOMOUS_MODE.md"

# Function to check if autonomous mode is active
check_autonomous_mode() {
    if [ ! -f "$AUTONOMOUS_MODE_FILE" ]; then
        echo -e "${BLUE}[INFO]${NC} AUTONOMOUS_MODE.md not found - Permission prompts enabled"
        echo -e "${BLUE}[DETAIL]${NC}   To enable autonomous mode, create AUTONOMOUS_MODE.md with:"
        echo -e "${BLUE}[DETAIL]${NC}   STATUS: ACTIVE"
        echo -e "${BLUE}[DETAIL]${NC}   (Claude will then proceed without asking for permissions)"
        return 1
    fi

    # Check if STATUS: ACTIVE or STATUS: ENABLED
    if grep -q "STATUS:\s*\(ACTIVE\|ENABLED\)" "$AUTONOMOUS_MODE_FILE"; then
        return 0
    else
        echo -e "${YELLOW}[WARN]${NC} AUTONOMOUS_MODE.md exists but STATUS is not ACTIVE"
        echo -e "${YELLOW}[DETAIL]${NC}   Current status: $(grep "STATUS:" "$AUTONOMOUS_MODE_FILE" || echo "Not set")"
        echo -e "${YELLOW}[DETAIL]${NC}   Permission prompts will be used"
        return 1
    fi
}

# Main execution
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}🤖 AUTONOMOUS MODE CHECK (Session Start - RULE 11)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"

if check_autonomous_mode; then
    # Autonomous mode is active
    echo -e "${GREEN}[AUTONOMOUS]${NC} ✅ Autonomous mode ACTIVE"
    echo -e "${GREEN}[DETAIL]${NC}   File: $AUTONOMOUS_MODE_FILE"
    echo -e "${GREEN}[DETAIL]${NC}   Status: ACTIVE"
    echo
    echo -e "${GREEN}[PERMISSIONS]${NC} 🚀 Full autonomous execution enabled"
    echo -e "${GREEN}[DETAIL]${NC}   Claude will:"
    echo -e "${GREEN}[DETAIL]${NC}   - Proceed without asking for permissions"
    echo -e "${GREEN}[DETAIL]${NC}   - Make decisions autonomously when possible"
    echo -e "${GREEN}[DETAIL]${NC}   - Complete tasks systematically without interruption"
    echo -e "${GREEN}[DETAIL]${NC}   - Only ask questions when truly ambiguous"
    echo
    echo -e "${GREEN}[ACTION]${NC} Setting AUTONOMOUS_MODE=true environment variable"

    # Export environment variable (this is visible to Claude in hook output)
    export AUTONOMOUS_MODE=true
    echo "export AUTONOMOUS_MODE=true"

    # Create a marker file that scripts can check
    mkdir -p "$PROJECT_ROOT/.claude/session"
    echo "AUTONOMOUS_MODE=true" > "$PROJECT_ROOT/.claude/session/autonomous_mode"
    echo "SESSION_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$PROJECT_ROOT/.claude/session/autonomous_mode"

    echo
    echo -e "${GREEN}[READY]${NC} ✅ Session initialized in autonomous mode"
else
    # Autonomous mode is not active
    echo -e "${YELLOW}[STANDARD]${NC} ⚠️  Standard mode (permission prompts enabled)"
    echo -e "${YELLOW}[DETAIL]${NC}   Claude will ask before major operations"
    echo
    echo -e "${YELLOW}[TIP]${NC} To enable autonomous mode:"
    echo -e "${YELLOW}[DETAIL]${NC}   1. Create AUTONOMOUS_MODE.md in project root"
    echo -e "${YELLOW}[DETAIL]${NC}   2. Add line: STATUS: ACTIVE"
    echo -e "${YELLOW}[DETAIL]${NC}   3. Restart Claude Code session"

    # Clear autonomous mode marker if it exists
    if [ -f "$PROJECT_ROOT/.claude/session/autonomous_mode" ]; then
        rm -f "$PROJECT_ROOT/.claude/session/autonomous_mode"
    fi
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
echo

# Always exit 0 (SessionStart hooks should not block session initialization)
exit 0
