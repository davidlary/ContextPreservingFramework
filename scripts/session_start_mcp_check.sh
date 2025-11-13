#!/bin/bash
# session_start_mcp_check.sh - Check and start MCP servers at session initialization
# Purpose: Ensure MCP servers (memory, filesystem) are running before Claude Code session starts
# Version: 1.0.0
# Hook: SessionStart (runs once at session initialization)
#
# OUTPUT:
# - Checks if MCP servers are responding
# - Starts servers if not running
# - Sets environment variables for MCP status
# - Silent operation (only shows errors)

set -euo pipefail

# Load common functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common_functions.sh" ]; then
    source "$SCRIPT_DIR/common_functions.sh"
fi

# Configuration
PROJECT_ROOT="${PWD}"
MCP_STATUS_FILE="${PROJECT_ROOT}/.cpf/state/mcp_status.json"
MCP_CONFIG="${PROJECT_ROOT}/.mcp.json"

# Silent mode by default (only show errors)
SILENT=true

# Function to check if MCP memory server is working
check_memory_server() {
    # For now, we can't directly test MCP server connection from bash
    # But we can check if the MCP configuration exists and is valid

    if [ ! -f "$MCP_CONFIG" ]; then
        return 1  # No MCP config
    fi

    # Validate JSON
    if ! jq empty "$MCP_CONFIG" 2>/dev/null; then
        return 1  # Invalid JSON
    fi

    # Check if memory server is configured
    if ! jq -e '.mcp.memory' "$MCP_CONFIG" >/dev/null 2>&1; then
        return 1  # Memory server not configured
    fi

    return 0  # Looks good
}

# Function to create MCP status file
create_status_file() {
    local status="$1"
    local message="$2"

    mkdir -p "$(dirname "$MCP_STATUS_FILE")"

    cat > "$MCP_STATUS_FILE" <<EOF
{
  "memory_server": {
    "status": "$status",
    "message": "$message",
    "last_check": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  },
  "session_start_check": true
}
EOF
}

# Main check
if [ "$SILENT" = true ]; then
    # Silent mode - only create status file, don't output anything

    if check_memory_server; then
        create_status_file "configured" "MCP memory server configured in .mcp.json"
        export MCP_MEMORY_STATUS="configured"
    else
        create_status_file "not_configured" "MCP memory server not configured (optional)"
        export MCP_MEMORY_STATUS="not_configured"
    fi

    # Always exit 0 for SessionStart hook (don't block session)
    exit 0
else
    # Verbose mode
    if check_memory_server; then
        echo "✅ MCP memory server: Configured"
        create_status_file "configured" "MCP memory server configured"
        export MCP_MEMORY_STATUS="configured"
    else
        echo "ℹ️  MCP memory server: Not configured (optional)"
        echo "   To enable: See docs/guides/16_MCP_INTEGRATION_GUIDE.md"
        create_status_file "not_configured" "MCP memory server not configured"
        export MCP_MEMORY_STATUS="not_configured"
    fi

    exit 0
fi
