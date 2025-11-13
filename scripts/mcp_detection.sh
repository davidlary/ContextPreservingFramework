#!/bin/bash
# mcp_detection.sh - Detect MCP server availability
# Version: 1.0.0
# Purpose: Check if MCP tools are available and set environment flags

set -euo pipefail

# This script detects MCP tool availability and exports environment variables
# that other scripts can use to determine whether to use MCP or fall back

detect_mcp_availability() {
    local detection_log="${1:-.cpf/logs/mcp_detection.log}"

    echo "═══════════════════════════════════════════════════════════════════════" | tee -a "$detection_log"
    echo "MCP Server Detection" | tee -a "$detection_log"
    echo "═══════════════════════════════════════════════════════════════════════" | tee -a "$detection_log"
    echo "Timestamp: $(date)" | tee -a "$detection_log"
    echo "" | tee -a "$detection_log"

    # Initialize flags
    export MCP_AVAILABLE="false"
    export MCP_MEMORY_AVAILABLE="false"
    export MCP_FILESYSTEM_AVAILABLE="false"

    # Check for MCP memory tools
    echo "[1/3] Checking Memory Server..." | tee -a "$detection_log"

    # We can't directly check if mcp__ tools exist in bash
    # Instead, we check if the .mcp.json config exists and is valid
    if [ -f ".mcp.json" ] || [ -f "cpf/.mcp.json" ]; then
        echo "  ✓ MCP configuration found" | tee -a "$detection_log"

        # Check if jq can parse the config
        local config_file=".mcp.json"
        [ -f "cpf/.mcp.json" ] && config_file="cpf/.mcp.json"

        if command -v jq &> /dev/null; then
            if jq empty "$config_file" 2>/dev/null; then
                echo "  ✓ MCP configuration is valid JSON" | tee -a "$detection_log"

                # Check if memory server is configured
                if jq -e '.mcpServers.memory' "$config_file" &> /dev/null; then
                    echo "  ✓ Memory server configured" | tee -a "$detection_log"
                    # Assume available if configured (Claude Code will start it)
                    export MCP_MEMORY_AVAILABLE="true"
                    export MCP_AVAILABLE="true"
                else
                    echo "  ⚠ Memory server not configured in .mcp.json" | tee -a "$detection_log"
                fi

                # Check if filesystem server is configured
                if jq -e '.mcpServers.filesystem' "$config_file" &> /dev/null; then
                    echo "  ✓ Filesystem server configured" | tee -a "$detection_log"
                    export MCP_FILESYSTEM_AVAILABLE="true"
                    export MCP_AVAILABLE="true"
                else
                    echo "  ⚠ Filesystem server not configured" | tee -a "$detection_log"
                fi
            else
                echo "  ✗ MCP configuration is invalid JSON" | tee -a "$detection_log"
            fi
        else
            echo "  ⚠ jq not available, cannot parse MCP config" | tee -a "$detection_log"
            # Assume MCP might be available if config exists
            export MCP_AVAILABLE="possible"
        fi
    else
        echo "  ✗ No MCP configuration found" | tee -a "$detection_log"
    fi

    echo "" | tee -a "$detection_log"
    echo "[2/3] Checking for npx (required for MCP servers)..." | tee -a "$detection_log"
    if command -v npx &> /dev/null; then
        echo "  ✓ npx available ($(npx --version))" | tee -a "$detection_log"
    else
        echo "  ✗ npx not available - MCP servers cannot start" | tee -a "$detection_log"
        export MCP_AVAILABLE="false"
        export MCP_MEMORY_AVAILABLE="false"
        export MCP_FILESYSTEM_AVAILABLE="false"
    fi

    echo "" | tee -a "$detection_log"
    echo "[3/3] Checking for storage directories..." | tee -a "$detection_log"

    # Check if memory storage path exists (from config)
    if [ "$MCP_MEMORY_AVAILABLE" = "true" ]; then
        if [ -d ".claude/memory" ] || [ -d ".cpf/memory" ]; then
            echo "  ✓ Memory storage directory exists" | tee -a "$detection_log"
        else
            echo "  ℹ Memory storage will be created on first use" | tee -a "$detection_log"
        fi
    fi

    echo "" | tee -a "$detection_log"
    echo "═══════════════════════════════════════════════════════════════════════" | tee -a "$detection_log"
    echo "Detection Results:" | tee -a "$detection_log"
    echo "═══════════════════════════════════════════════════════════════════════" | tee -a "$detection_log"
    echo "MCP_AVAILABLE=$MCP_AVAILABLE" | tee -a "$detection_log"
    echo "MCP_MEMORY_AVAILABLE=$MCP_MEMORY_AVAILABLE" | tee -a "$detection_log"
    echo "MCP_FILESYSTEM_AVAILABLE=$MCP_FILESYSTEM_AVAILABLE" | tee -a "$detection_log"
    echo "" | tee -a "$detection_log"

    if [ "$MCP_AVAILABLE" = "true" ]; then
        echo "✅ MCP support: AVAILABLE" | tee -a "$detection_log"
        echo "   Framework will use MCP servers when possible" | tee -a "$detection_log"
    else
        echo "ℹ️  MCP support: NOT AVAILABLE" | tee -a "$detection_log"
        echo "   Framework will use standard file-based storage" | tee -a "$detection_log"
    fi
    echo "" | tee -a "$detection_log"

    # Export for use by other scripts
    echo "export MCP_AVAILABLE=\"$MCP_AVAILABLE\"" > .cpf/mcp_status.sh 2>/dev/null || true
    echo "export MCP_MEMORY_AVAILABLE=\"$MCP_MEMORY_AVAILABLE\"" >> .cpf/mcp_status.sh 2>/dev/null || true
    echo "export MCP_FILESYSTEM_AVAILABLE=\"$MCP_FILESYSTEM_AVAILABLE\"" >> .cpf/mcp_status.sh 2>/dev/null || true

    return 0
}

# If called directly (not sourced), run detection
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Create log directory if needed
    mkdir -p .cpf/logs 2>/dev/null || mkdir -p logs 2>/dev/null || true

    detect_mcp_availability "${1:-.cpf/logs/mcp_detection.log}"
fi
