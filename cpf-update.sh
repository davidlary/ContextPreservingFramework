#!/bin/bash
# cpf-update.sh - Context-Preserving Framework Update
# Version: 1.0.0
# Purpose: Update framework from repository

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "Context-Preserving Framework - Update"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Check if framework is installed
if [ ! -d ".cpf" ]; then
    echo "❌ Framework not installed (.cpf/ directory not found)"
    echo ""
    echo "To install:"
    echo "  ./cpf/cpf-install.sh"
    exit 1
fi

# Get framework root
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$FRAMEWORK_DIR")"

echo "Framework location: $FRAMEWORK_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""

cd "$FRAMEWORK_DIR"

# Check if framework is a git repository
if [ ! -d ".git" ]; then
    echo "❌ Framework is not a git repository"
    echo "   Cannot update automatically"
    echo ""
    echo "To update manually:"
    echo "  1. Download latest framework from GitHub"
    echo "  2. Replace cpf/ directory"
    echo "  3. Run: ./cpf/cpf-install.sh"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(git describe --tags 2>/dev/null || git rev-parse --short HEAD)
echo "Current version: $CURRENT_VERSION"
echo ""

# Pull latest changes
echo "[1/4] Pulling latest framework code..."
if git pull origin main; then
    echo "✓ Framework code updated"
else
    echo "❌ Failed to pull latest code"
    echo "   Check git remote and network connection"
    exit 1
fi
echo ""

# Get new version
NEW_VERSION=$(git describe --tags 2>/dev/null || git rev-parse --short HEAD)
echo "New version: $NEW_VERSION"
echo ""

# Update .claude/ hooks if needed
echo "[2/4] Updating Claude Code hooks..."
cd "$PROJECT_ROOT"
if [ -d "$FRAMEWORK_DIR/.claude" ]; then
    # Backup existing hooks
    if [ -d ".claude" ]; then
        cp -r .claude .claude.backup.$(date +%Y%m%d_%H%M%S)
        echo "✓ Backed up existing .claude/ directory"
    fi

    # Copy updated hooks
    cp -r "$FRAMEWORK_DIR/.claude" .
    echo "✓ Updated .claude/ directory"
else
    echo "⚠️  Warning: .claude/ directory not found in framework"
fi
echo ""

# Update git hooks
echo "[3/4] Updating git hooks..."
if [ -d ".git/hooks" ]; then
    cd .git/hooks
    # Recreate symlinks
    if [ -f "$FRAMEWORK_DIR/scripts/pre-commit-master.sh" ]; then
        ln -sf ../../cpf/scripts/pre-commit-master.sh pre-commit
        chmod +x pre-commit
        echo "✓ Updated pre-commit hook"
    fi
    cd "$PROJECT_ROOT"
else
    echo "⚠️  Not a git repository, skipping git hooks"
fi
echo ""

# Check for config schema changes
echo "[4/4] Checking configuration compatibility..."
if [ -f ".cpf/config.json" ] && [ -f "$FRAMEWORK_DIR/templates/config_template.json" ]; then
    # Simple check - could be enhanced with jq
    echo "✓ Configuration file exists"
    echo "  Review $FRAMEWORK_DIR/templates/config_template.json for new options"
else
    echo "⚠️  Configuration check skipped"
fi
echo ""

# Update complete
echo "═══════════════════════════════════════════════════════════════════════"
if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    echo "✅ Framework updated successfully!"
    echo ""
    echo "📊 Version change:"
    echo "  From: $CURRENT_VERSION"
    echo "  To:   $NEW_VERSION"
else
    echo "✅ Framework is up to date!"
    echo ""
    echo "📊 Version: $CURRENT_VERSION"
fi
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "📖 Changelog:"
echo "  See cpf/docs/releases/ for release notes"
echo ""
echo "⚠️  Important:"
echo "  - Review .cpf/config.json for new configuration options"
echo "  - Check cpf/docs/README.md for documentation updates"
echo "  - Test your project to ensure compatibility"
echo ""
