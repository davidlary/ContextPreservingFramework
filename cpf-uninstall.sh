#!/bin/bash
# cpf-uninstall.sh - Context-Preserving Framework Uninstallation
# Version: 1.0.0
# Purpose: Remove framework cleanly from project

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "Context-Preserving Framework - Uninstallation"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Check if framework is installed
if [ ! -d ".cpf" ]; then
    echo "❌ Framework not installed (.cpf/ directory not found)"
    exit 1
fi

# Get paths
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$FRAMEWORK_DIR")"

echo "Framework location: $FRAMEWORK_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""

cd "$PROJECT_ROOT"

# Warning
echo "⚠️  WARNING: This will remove framework files from your project"
echo ""
echo "The following will be removed/modified:"
echo "  - .git/hooks/pre-commit (symlink)"
echo "  - .claude/ directory (Claude Code hooks)"
echo "  - .gitignore entries (.cpf/state/, .cpf/logs/)"
echo ""
echo "The following will be preserved (your choice):"
echo "  - .cpf/ directory (configuration and state)"
echo "  - cpf/ directory (framework source - manually remove if submodule)"
echo ""

# Confirm
read -p "Continue with uninstallation? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Uninstallation cancelled"
    exit 0
fi
echo ""

# Remove git hooks
echo "[1/4] Removing git hooks..."
if [ -d ".git/hooks" ]; then
    if [ -L ".git/hooks/pre-commit" ]; then
        rm .git/hooks/pre-commit
        echo "✓ Removed pre-commit hook"
    else
        echo "  No framework pre-commit hook found"
    fi
else
    echo "  Not a git repository, skipping"
fi
echo ""

# Ask about .claude/ directory
echo "[2/4] Removing Claude Code hooks..."
if [ -d ".claude" ]; then
    read -p "Remove .claude/ directory? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup first
        mv .claude .claude.removed.$(date +%Y%m%d_%H%M%S)
        echo "✓ Moved .claude/ to .claude.removed.* (backup)"
    else
        echo "  Kept .claude/ directory"
    fi
else
    echo "  No .claude/ directory found"
fi
echo ""

# Ask about .cpf/ directory
echo "[3/4] Handling .cpf/ directory..."
if [ -d ".cpf" ]; then
    echo "⚠️  .cpf/ contains:"
    echo "    - Configuration (.cpf/config.json)"
    echo "    - State files (.cpf/state/)"
    echo "    - Progress tracking (.cpf/progress/)"
    echo "    - Logs (.cpf/logs/)"
    echo ""
    read -p "Remove .cpf/ directory? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup first
        mv .cpf .cpf.removed.$(date +%Y%m%d_%H%M%S)
        echo "✓ Moved .cpf/ to .cpf.removed.* (backup)"
    else
        echo "  Kept .cpf/ directory"
    fi
fi
echo ""

# Update .gitignore
echo "[4/4] Updating .gitignore..."
if [ -f ".gitignore" ]; then
    # Remove .cpf/ entries
    if grep -q ".cpf/state/" .gitignore 2>/dev/null; then
        # Create backup
        cp .gitignore .gitignore.backup
        # Remove lines
        sed -i.bak '/# Context-Preserving Framework/d' .gitignore 2>/dev/null || sed -i '' '/# Context-Preserving Framework/d' .gitignore
        sed -i.bak '/.cpf\/state\//d' .gitignore 2>/dev/null || sed -i '' '/.cpf\/state\//d' .gitignore
        sed -i.bak '/.cpf\/logs\//d' .gitignore 2>/dev/null || sed -i '' '/.cpf\/logs\//d' .gitignore
        rm -f .gitignore.bak
        echo "✓ Removed .cpf/ entries from .gitignore"
        echo "  Backup: .gitignore.backup"
    else
        echo "  No .cpf/ entries in .gitignore"
    fi
fi
echo ""

# Final instructions
echo "═══════════════════════════════════════════════════════════════════════"
echo "✅ Framework uninstallation complete!"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "📁 Removed:"
echo "  - Git hooks (pre-commit)"
echo "  - Claude Code hooks (if selected)"
echo "  - .gitignore entries"
echo ""
echo "📁 To complete removal:"
if [ -d "$FRAMEWORK_DIR" ]; then
    echo "  1. Remove framework source:"
    echo "     rm -rf cpf/"
    echo "     OR (if git submodule):"
    echo "     git submodule deinit cpf"
    echo "     git rm cpf"
fi
if [ -d ".cpf.removed"* ] 2>/dev/null; then
    echo "  2. Delete backed-up directories if no longer needed:"
    echo "     rm -rf .cpf.removed.*"
fi
if [ -d ".claude.removed"* ] 2>/dev/null; then
    echo "     rm -rf .claude.removed.*"
fi
echo ""
echo "Thank you for using Context-Preserving Framework! 👋"
echo ""
