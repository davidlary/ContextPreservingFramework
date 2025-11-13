# MCP Integration Guide

**Version**: 1.0.0 (v4.4.0)
**Purpose**: Complete guide to Model Context Protocol (MCP) integration
**Audience**: Framework users and developers

---

## Table of Contents

1. [What is MCP?](#what-is-mcp)
2. [Benefits for This Framework](#benefits)
3. [How It Works](#how-it-works)
4. [Verification](#verification)
5. [Usage Examples](#usage-examples)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Configuration](#advanced-configuration)

---

## What is MCP?

**Model Context Protocol (MCP)** is Anthropic's protocol for connecting AI assistants to external tools and data sources. For this framework, MCP provides:

### Memory Server
- **Persistent context storage** across sessions
- **Semantic search** for past work
- **Relationship tracking** between modules
- **Observational history** for changes

### Filesystem Server
- **Enhanced file operations** with validation
- **Optimized searches** across codebases
- **Atomic operations** for safety

---

## Benefits

### 1. Seamless Recovery

**Without MCP**:
```
Session 1: Complete Module 1.1, 1.2, 1.3
[Session crashes]
Session 2: Load checkpoint file, parse JSON, reconstruct context
```

**With MCP**:
```
Session 1: Complete modules (auto-saved to memory)
[Session crashes]
Session 2: Automatic context retrieval via semantic search
```

### 2. Intelligent Search

**Without MCP**:
```bash
# Find modules related to "authentication"
grep -r "authentication" .claude/summaries/
→ Simple text match, no understanding
```

**With MCP**:
```bash
# Semantic search
mcp__memory__search_nodes("authentication")
→ Finds: Module_1.2 (JWT), Module_2.3 (OAuth), Module_3.1 (Sessions)
→ Understands relationships and context
```

### 3. Dependency Tracking

**Without MCP**:
```json
// Static dependency graph in plan.json
{
  "dependencies": {
    "Module_1.2": ["Module_1.1"]
  }
}
```

**With MCP**:
```javascript
// Dynamic relationship graph
mcp__memory__create_relations([{
  from: "Module_1.2",
  to: "Module_1.1",
  relationType: "depends_on"
}])

// Query anytime
mcp__memory__get_relations("Module_1.2")
→ Returns full dependency tree
```

### 4. Rich History

**Without MCP**:
```
Git commits only (coarse-grained)
```

**With MCP**:
```javascript
// Fine-grained observations
mcp__memory__add_observations("Module_1.2", [
  "Added error handling at 10:30 AM",
  "Refactored for performance at 2:15 PM",
  "Fixed edge case at 4:00 PM"
])
```

---

## How It Works

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Claude Code                                                  │
│                                                              │
│  ┌────────────────┐         ┌─────────────────┐            │
│  │ Framework      │         │ MCP Tools       │            │
│  │ Scripts        │────────▶│ (mcp__memory__*)│            │
│  │                │         │                 │            │
│  │ - Detection    │         │ - create_entities           │
│  │ - Library      │         │ - search_nodes             │
│  │ - State Mgr    │         │ - create_relations         │
│  └────────────────┘         └─────────────────┘            │
│         │                           │                        │
│         │                           ▼                        │
│         │                   ┌──────────────┐                │
│         │                   │ Memory Server│                │
│         │                   │ (@anthropic) │                │
│         │                   └──────────────┘                │
│         │                           │                        │
│         ▼                           ▼                        │
│  ┌────────────────┐         ┌─────────────────┐            │
│  │ File Storage   │         │ .claude/memory/ │            │
│  │ (.cpf/state/)  │         │ (persistent DB) │            │
│  └────────────────┘         └─────────────────┘            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Graceful Degradation

Framework uses **dual storage**:

1. **Primary**: File-based (JSON, .md files)
   - Always works
   - Portable
   - Human-readable

2. **Enhanced**: MCP memory server
   - When available
   - Semantic search
   - Persistent across crashes

**If MCP unavailable**: Framework falls back to file storage automatically.

---

## Verification

### Check 1: Configuration Exists

```bash
# Check if .mcp.json exists
cat .mcp.json | jq .mcpServers

# Should show:
# {
#   "memory": { ... },
#   "filesystem": { ... }
# }
```

### Check 2: Run Detection

```bash
# In project root
bash cpf/scripts/mcp_detection.sh

# Should output:
# ✅ MCP support: AVAILABLE
#    Framework will use MCP servers when possible
```

### Check 3: Check MCP Status

```bash
# Using state manager
bash cpf/scripts/state_manager.sh mcp-status

# Should output:
# MCP Integration Status:
#   Overall: true
#   Memory Server: true
#   Filesystem Server: true
#   Mode: Enhanced (MCP + File-based)
```

### Check 4: Verify Tools Available (In Claude Code)

Within a Claude Code session, MCP tools should be available:

```
mcp__memory__create_entities([{name: "test"}])
```

If this works, MCP is fully operational.

---

## Usage Examples

### Example 1: Saving Module Summary

**Manual (old way)**:
```bash
echo "Module 1.2 Complete - JWT Auth" > .claude/summaries/module_1.2.md
```

**With Framework (automatic)**:
```bash
# Framework does both:
bash cpf/scripts/state_manager.sh complete "Module_1.2" "JWT Auth Complete"

# Result:
# - Saves to .claude/summaries/module_1.2.md (file)
# - Saves to MCP memory (if available)
```

### Example 2: Searching Past Work

**Manual (old way)**:
```bash
grep -r "authentication" .claude/summaries/
```

**With Framework**:
```bash
# Source the MCP library
source cpf/scripts/mcp_lib.sh

# Search (tries MCP first, falls back to grep)
mcp_search_modules "authentication"
```

### Example 3: Tracking Dependencies

**Manual (old way)**:
```bash
# Edit plan.json manually
jq '.dependencies.Module_1_2 += ["Module_1_1"]' .claude/plan.json
```

**With Framework**:
```bash
# Automatic dual storage
source cpf/scripts/mcp_lib.sh
mcp_track_dependency "Module_1.2" "Module_1.1"

# Result:
# - Updates plan.json (file)
# - Creates MCP relationship (if available)
```

### Example 4: Session Recovery

**Manual (old way)**:
```bash
# Load checkpoint file
cat .claude/checkpoints/checkpoint_001.json

# Parse manually
# Reconstruct context from summaries
```

**With Framework**:
```bash
# Automatic recovery (tries MCP first)
source cpf/scripts/mcp_lib.sh
mcp_recover_context

# Result:
# - Tries MCP memory semantic search
# - Falls back to checkpoint files if needed
```

---

## Troubleshooting

### Issue 1: MCP Detection Says "NOT AVAILABLE"

**Check**:
```bash
# 1. Is .mcp.json present?
ls -la .mcp.json
ls -la cpf/.mcp.json

# 2. Is npx available?
which npx
npx --version

# 3. Is config valid?
cat .mcp.json | jq empty
```

**Fix**:
- If .mcp.json missing: Framework will work without MCP (file-based only)
- If npx missing: Install Node.js: `brew install node` (macOS) or system package manager
- If config invalid: Check JSON syntax

### Issue 2: MCP Tools Not Working in Claude Code

**Symptoms**: `mcp__memory__create_entities` command not found

**Possible Causes**:
1. Claude Code version doesn't support MCP
2. MCP servers didn't start
3. Running in bash instead of Claude Code context

**Check**:
```bash
# In Claude Code, try:
mcp__memory__create_entities([{name: "test"}])

# If error "command not found":
# → MCP not available in this Claude Code version
```

**Resolution**:
- Framework will automatically fall back to file-based storage
- No action needed - dual storage ensures compatibility

### Issue 3: "Memory server configured but not responding"

**Check logs**:
```bash
cat .cpf/logs/mcp_detection.log
cat .cpf/logs/mcp_operations.log
```

**Common causes**:
- npm packages not installed (npx will install on first use)
- Port conflicts (rare)
- Permissions issues with `.claude/memory/` directory

**Fix**:
```bash
# Create memory directory
mkdir -p .claude/memory

# Check permissions
ls -la .claude/memory

# Should be writable by your user
```

### Issue 4: Performance Issues

**Symptoms**: MCP operations slow

**Check**:
```bash
# How much data in memory?
du -sh .claude/memory/

# If > 100MB, consider cleanup
```

**Fix**:
```bash
# Archive old memory data
mv .claude/memory .claude/memory.backup.$(date +%Y%m%d)
mkdir -p .claude/memory

# MCP will rebuild from state files
```

---

## Advanced Configuration

### Custom Memory Storage Path

**Edit .mcp.json**:
```json
{
  "mcpServers": {
    "memory": {
      "env": {
        "MEMORY_STORAGE_PATH": ".cpf/memory",  // Custom path
        "MEMORY_AUTO_SAVE": "true"
      }
    }
  }
}
```

### Disable MCP for Testing

**Temporary**:
```bash
# Set environment variable
export MCP_AVAILABLE=false
export MCP_MEMORY_AVAILABLE=false

# Run framework operations
bash cpf/scripts/state_manager.sh mcp-status
# Should show: Mode: Standard (File-based only)
```

**Permanent**:
```bash
# Rename .mcp.json
mv .mcp.json .mcp.json.disabled

# Framework will detect absence and use file-based storage only
```

### Enable Only Memory Server

**Edit .mcp.json**:
```json
{
  "mcpServers": {
    "memory": {
      // ... keep this
    }
    // Remove "filesystem" section
  }
}
```

### Custom MCP Server

**Add to .mcp.json**:
```json
{
  "mcpServers": {
    "memory": { ... },
    "custom_server": {
      "command": "node",
      "args": ["path/to/custom-server.js"],
      "env": {
        "CUSTOM_ENV": "value"
      }
    }
  }
}
```

---

## Best Practices

### 1. Let Framework Handle MCP

✅ **Do**: Use framework scripts
```bash
bash cpf/scripts/state_manager.sh complete "Module_1.2" "Summary"
```

❌ **Don't**: Call MCP directly in bash scripts
```bash
# This won't work in bash context
mcp__memory__create_entities([...])
```

### 2. Check MCP Status Before Debugging

```bash
# Always run this first when troubleshooting
bash cpf/scripts/state_manager.sh mcp-status
```

### 3. Maintain Dual Storage

Framework maintains both file and MCP storage. **Never delete state files**, even if MCP is working. They serve as:
- Backup if MCP fails
- Human-readable documentation
- Git-trackable history

### 4. Monitor Memory Usage

```bash
# Check memory storage size
du -sh .claude/memory/

# If growing too large (>100MB), consider archiving
```

### 5. Test Without MCP

Periodically test that framework works without MCP:

```bash
# Temporarily disable
mv .mcp.json .mcp.json.tmp

# Run validation
bash cpf/scripts/pre-commit-master.sh

# Should still pass

# Re-enable
mv .mcp.json.tmp .mcp.json
```

---

## FAQ

### Q: Is MCP required for the framework?

**A**: No. MCP is an **optional enhancement**. Framework works fully with standard file-based storage.

### Q: What happens if MCP fails mid-session?

**A**: Framework automatically falls back to file-based storage. No data loss.

### Q: Can I use MCP in bash scripts?

**A**: MCP tools (`mcp__*`) only work within Claude Code context. Bash scripts log intended operations and use file fallbacks.

### Q: Does MCP work offline?

**A**: Yes! Memory server is local (runs via npx). No internet required.

### Q: How much disk space does MCP use?

**A**: Typically 1-50 MB for memory storage, depending on project size.

### Q: Can I sync MCP data across machines?

**A**: MCP memory is stored in `.claude/memory/`. You can sync this directory (e.g., via Dropbox) if desired. Framework recommends syncing state files instead.

### Q: What if Claude Code updates break MCP?

**A**: Framework's graceful degradation ensures it continues working with file-based storage only.

---

## Technical Details

### MCP Detection Logic

```bash
# Detection checks (in order):
1. .mcp.json exists and valid JSON?
2. Memory server configured in .mcp.json?
3. Filesystem server configured?
4. npx available (for server startup)?
5. Storage directories accessible?

# Result: Sets environment variables
export MCP_AVAILABLE="true|false"
export MCP_MEMORY_AVAILABLE="true|false"
export MCP_FILESYSTEM_AVAILABLE="true|false"
```

### File Organization

```
Project/
├── .mcp.json                     # MCP configuration (framework provides)
├── .cpf/
│   ├── mcp_status.sh            # Detected MCP status (generated)
│   ├── state/                   # Primary state storage (always used)
│   └── logs/
│       ├── mcp_detection.log    # Detection results
│       └── mcp_operations.log   # MCP operation log
├── .claude/
│   ├── memory/                  # MCP memory server storage
│   ├── summaries/               # File-based summaries (always used)
│   └── checkpoints/             # File-based checkpoints (always used)
└── cpf/
    └── scripts/
        ├── mcp_detection.sh     # Detection script
        ├── mcp_lib.sh          # MCP wrapper library
        └── state_manager.sh     # Unified state management
```

### MCP Tool Reference

**Available in Claude Code context only**:

| Tool | Purpose | Example |
|------|---------|---------|
| `mcp__memory__create_entities` | Store data | Module summaries, state |
| `mcp__memory__search_nodes` | Semantic search | Find modules by topic |
| `mcp__memory__create_relations` | Link entities | Track dependencies |
| `mcp__memory__get_relations` | Query relationships | Get dependency tree |
| `mcp__memory__add_observations` | Track changes | Observational history |

---

## Getting Help

### Framework Issues
- Check `.cpf/logs/mcp_detection.log`
- Check `.cpf/logs/mcp_operations.log`
- Run: `bash cpf/scripts/mcp_detection.sh`
- Disable MCP temporarily to isolate issue

### MCP Server Issues
- Check Anthropic MCP documentation
- Verify npx and Node.js versions
- Check `.claude/memory/` permissions

### Still Stuck?
- Framework works without MCP
- Disable MCP: `mv .mcp.json .mcp.json.disabled`
- File issue: https://github.com/davidlary/ContextPreservingFramework/issues

---

## Changelog

**v1.0.0** (2025-11-13)
- Initial MCP integration guide
- Detection, library, state manager documented
- Examples and troubleshooting added

---

**Guide Version**: 1.0.0
**Framework Version**: v4.4.0
**Last Updated**: 2025-11-13
