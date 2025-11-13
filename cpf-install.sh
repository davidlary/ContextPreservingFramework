#!/bin/bash
# cpf-install.sh - Context-Preserving Framework Installation
# Version: 1.0.0
# Purpose: Set up framework in user project

set -euo pipefail

echo "═══════════════════════════════════════════════════════════════════════"
echo "Context-Preserving Framework - Installation"
echo "Version: 4.3.0"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""

# Check if already installed
if [ -d ".cpf" ]; then
    echo "❌ Framework already installed (.cpf/ directory exists)"
    echo ""
    echo "To reinstall:"
    echo "  1. Run: ./cpf/cpf-uninstall.sh"
    echo "  2. Run: ./cpf/cpf-install.sh"
    exit 1
fi

# Get framework root (where this script is)
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$FRAMEWORK_DIR")"

echo "Framework location: $FRAMEWORK_DIR"
echo "Project root: $PROJECT_ROOT"
echo ""

# Create .cpf/ structure
echo "[1/7] Creating .cpf/ directory structure..."
cd "$PROJECT_ROOT"
mkdir -p .cpf/{state,progress,logs,issues}
echo "✓ Created .cpf/{state,progress,logs,issues}"
echo ""

# Copy configuration templates
echo "[2/7] Copying configuration templates..."
if [ -f "$FRAMEWORK_DIR/templates/config_template.json" ]; then
    cp "$FRAMEWORK_DIR/templates/config_template.json" .cpf/config.json
    echo "✓ Created .cpf/config.json"
else
    echo "⚠️  Warning: config_template.json not found, skipping"
fi

if [ -f "$FRAMEWORK_DIR/templates/state_template.json" ]; then
    cp "$FRAMEWORK_DIR/templates/state_template.json" .cpf/state/master_state.json
    # Update timestamps
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if command -v jq &> /dev/null; then
        jq ".project.initialized_at = \"$TIMESTAMP\" | .project.last_updated = \"$TIMESTAMP\" | .session.started_at = \"$TIMESTAMP\" | .session.last_active = \"$TIMESTAMP\"" .cpf/state/master_state.json > .cpf/state/master_state.json.tmp
        mv .cpf/state/master_state.json.tmp .cpf/state/master_state.json
    fi
    echo "✓ Created .cpf/state/master_state.json"
else
    echo "⚠️  Warning: state_template.json not found, skipping"
fi

if [ -f "$FRAMEWORK_DIR/templates/AUTONOMOUS_MODE_template.md" ]; then
    cp "$FRAMEWORK_DIR/templates/AUTONOMOUS_MODE_template.md" .cpf/AUTONOMOUS_MODE.md
    echo "✓ Created .cpf/AUTONOMOUS_MODE.md"
else
    echo "⚠️  Warning: AUTONOMOUS_MODE_template.md not found, skipping"
fi
echo ""

# Copy .claude/ to project root
echo "[3/7] Setting up Claude Code hooks..."
if [ -d "$FRAMEWORK_DIR/.claude" ]; then
    if [ -d ".claude" ]; then
        echo "⚠️  Warning: .claude/ already exists, backing up to .claude.backup"
        mv .claude .claude.backup
    fi
    cp -r "$FRAMEWORK_DIR/.claude" .
    echo "✓ Copied .claude/ directory"
else
    echo "⚠️  Warning: .claude/ directory not found in framework"
fi
echo ""

# Create git hooks (if git repo exists)
echo "[4/7] Creating git hooks..."
if [ -d ".git/hooks" ]; then
    cd .git/hooks

    # Pre-commit hook
    if [ -f "$FRAMEWORK_DIR/scripts/pre-commit-master.sh" ]; then
        ln -sf ../../cpf/scripts/pre-commit-master.sh pre-commit
        chmod +x pre-commit
        echo "✓ Created pre-commit hook"
    else
        echo "⚠️  Warning: pre-commit-master.sh not found"
    fi

    cd "$PROJECT_ROOT"
else
    echo "⚠️  Not a git repository, skipping git hooks"
fi
echo ""

# Update .gitignore
echo "[5/7] Updating .gitignore..."
if [ -f ".gitignore" ]; then
    # Add .cpf/ entries if not already present
    if ! grep -q ".cpf/state/" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Context-Preserving Framework" >> .gitignore
        echo ".cpf/state/" >> .gitignore
        echo ".cpf/logs/" >> .gitignore
        echo "✓ Added .cpf/ entries to .gitignore"
    else
        echo "✓ .gitignore already contains .cpf/ entries"
    fi
else
    # Create .gitignore
    cat > .gitignore <<EOF
# Context-Preserving Framework
.cpf/state/
.cpf/logs/
EOF
    echo "✓ Created .gitignore with .cpf/ entries"
fi
echo ""

# Create initial log file
echo "[6/7] Initializing logs..."
cat > .cpf/logs/operations.log <<EOF
═══════════════════════════════════════════════════════════════════════
Context-Preserving Framework - Operations Log
═══════════════════════════════════════════════════════════════════════
Installation Date: $(date)
Framework Version: 4.3.0
Project: $(basename "$PROJECT_ROOT")

═══════════════════════════════════════════════════════════════════════
EOF
echo "✓ Created .cpf/logs/operations.log"
echo ""

# Detect MCP availability
echo "[7/8] Detecting MCP server availability..."
if [ -f "$FRAMEWORK_DIR/scripts/mcp_detection.sh" ]; then
    bash "$FRAMEWORK_DIR/scripts/mcp_detection.sh" .cpf/logs/mcp_detection.log
    if [ -f ".cpf/mcp_status.sh" ]; then
        echo "✓ MCP detection complete (see .cpf/logs/mcp_detection.log)"
    else
        echo "⚠️  MCP detection completed with warnings"
    fi
else
    echo "⚠️  MCP detection script not found"
fi
echo ""

# Verify installation
echo "[8/8] Verifying installation..."
CHECKS_PASSED=0
CHECKS_TOTAL=6

[ -d ".cpf" ] && ((CHECKS_PASSED++))
[ -f ".cpf/config.json" ] && ((CHECKS_PASSED++))
[ -f ".cpf/state/master_state.json" ] && ((CHECKS_PASSED++))
[ -d ".claude" ] && ((CHECKS_PASSED++))
[ -f ".gitignore" ] && ((CHECKS_PASSED++))
[ -f ".cpf/logs/operations.log" ] && ((CHECKS_PASSED++))

echo "✓ Installation checks: $CHECKS_PASSED/$CHECKS_TOTAL passed"
echo ""

# Installation complete
echo "═══════════════════════════════════════════════════════════════════════"
echo "✅ Context-Preserving Framework installed successfully!"
echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "📁 Created:"
echo "  .cpf/                    Framework configuration and state"
echo "  .cpf/config.json         Project configuration (edit as needed)"
echo "  .cpf/state/              Runtime state (tracked in git by default)"
echo "  .cpf/progress/           Progress tracking"
echo "  .cpf/logs/               Operation logs (not tracked in git)"
echo "  .cpf/issues/             Issue tracking"
echo "  .claude/                 Claude Code hooks"
echo "  .git/hooks/pre-commit    Pre-commit validation"
echo ""
echo "📖 Next steps:"
echo "  1. Review and customize .cpf/config.json for your project"
echo "  2. Update .cpf/AUTONOMOUS_MODE.md if you want autonomous execution"
echo "  3. See cpf/docs/ for complete documentation"
echo "  4. Start Claude Code and begin working - framework is active!"
echo ""
echo "📚 Documentation:"
echo "  Quick Start:    cpf/docs/core/PROTOCOL_CORE_RULES.md"
echo "  Full Setup:     cpf/docs/guides/02_SETUP_GUIDE.md"
echo "  Documentation:  cpf/docs/README.md"
echo ""
echo "🔧 Maintenance:"
echo "  Update framework:   ./cpf/cpf-update.sh"
echo "  Uninstall:          ./cpf/cpf-uninstall.sh"
echo ""
echo "Framework is now active. Happy coding! 🚀"
echo ""
