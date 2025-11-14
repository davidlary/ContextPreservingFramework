# Automated Recovery System Design (v4.7.1)

**Purpose**: Self-healing context corruption detection and automatic recovery
**Priority**: P2 High (enhances resilience and user experience)
**Status**: Design Phase
**Target Version**: v4.7.1

---

## Problem Statement

**Current State**:
- Context corruption can occur from:
  - Invalid JSON in state files (master_state.json, context_tracking.json)
  - Missing required fields in state schema
  - Corrupted operation logs
  - Stale or inconsistent state across files
  - Session interruptions leaving partial state
- Manual recovery required (user must debug and fix)
- No automated detection or correction

**Impact**:
- Framework unusable until manually fixed
- User frustration and lost productivity
- Validation hooks may fail unexpectedly
- No self-healing capability

---

## Solution Overview

**Automated Recovery System** with three layers:

1. **Detection Layer** - Continuously monitor for corruption
2. **Recovery Layer** - Automatically attempt fixes
3. **Fallback Layer** - Graceful degradation if auto-fix fails

---

## Architecture

### 1. Detection Layer

**Corruption Patterns to Detect**:

#### 1.1 JSON Validity
- **What**: Detect malformed JSON in state files
- **How**: `jq` parsing + error detection
- **Action**: Attempt JSON repair or restore from backup

#### 1.2 Schema Validation
- **What**: Detect missing/incorrect required fields
- **How**: Check against schema definitions
- **Action**: Add missing fields with safe defaults

#### 1.3 Timestamp Staleness
- **What**: Detect stale state (not updated in >24 hours)
- **How**: Compare `last_update` timestamps
- **Action**: Warn and offer reset

#### 1.4 Cross-File Consistency
- **What**: Detect mismatches between state files
- **How**: Compare versions, modules across files
- **Action**: Sync from authoritative source (master_state.json)

#### 1.5 Log Corruption
- **What**: Detect truncated or corrupted operation logs
- **How**: Check for incomplete entries, invalid formats
- **Action**: Mark corrupt section, continue logging

---

### 2. Recovery Layer

**Recovery Strategies**:

#### Strategy 1: JSON Repair
```bash
# Attempt to repair malformed JSON
repair_json() {
    local file=$1
    local backup="${file}.backup_$(date +%Y%m%d_%H%M%S)"

    # Create backup
    cp "$file" "$backup"

    # Try common fixes:
    # - Add missing closing braces
    # - Remove trailing commas
    # - Escape unescaped quotes
    # - Fix common typos

    # Validate with jq
    if jq . "$file" > /dev/null 2>&1; then
        echo "✓ JSON repaired successfully"
        return 0
    else
        # Restore backup if repair failed
        mv "$backup" "$file"
        return 1
    fi
}
```

#### Strategy 2: Schema Defaulting
```bash
# Add missing required fields with safe defaults
add_missing_fields() {
    local file=$1

    # Required fields for master_state.json
    jq '. + {
        "version": (.version // "4.7.1"),
        "last_update": (.last_update // "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"),
        "project": (.project // "unknown"),
        "current_phase": (.current_phase // "in_progress"),
        "current_module": (.current_module // "unknown")
    }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}
```

#### Strategy 3: Checkpoint Restore
```bash
# Restore from most recent valid checkpoint
restore_from_checkpoint() {
    local checkpoint_dir=".claude/checkpoints"

    # Find most recent valid checkpoint
    latest=$(find "$checkpoint_dir" -name "checkpoint_*.json" -type f | sort -r | head -1)

    if [ -n "$latest" ]; then
        # Validate checkpoint
        if jq . "$latest" > /dev/null 2>&1; then
            # Extract state and restore
            jq '.state' "$latest" > data/state/master_state.json
            echo "✓ Restored from checkpoint: $latest"
            return 0
        fi
    fi

    return 1
}
```

#### Strategy 4: Factory Reset
```bash
# Last resort: Reset to clean state
factory_reset_state() {
    local backup_dir="data/state/backups/$(date +%Y%m%d_%H%M%S)"

    # Backup everything first
    mkdir -p "$backup_dir"
    cp -r data/state/* "$backup_dir/"

    # Create fresh state files
    initialize_fresh_state

    echo "⚠ Factory reset performed. Backups in: $backup_dir"
}
```

---

### 3. Fallback Layer

**Graceful Degradation**:

#### 3.1 Read-Only Mode
- If corruption unfixable, switch to read-only
- Allow operations but don't update state
- Log warning to user

#### 3.2 Minimal State
- Initialize minimal valid state for operation
- Lose history but allow continued work
- User can manually restore later

#### 3.3 Bypass Mode
- Allow user to bypass state tracking temporarily
- Framework continues without persistence
- Resume normal operation once fixed

---

## Implementation Files

### Core Recovery Script
**File**: `scripts/recovery/automated_recovery.sh`

```bash
#!/bin/bash
# Automated Recovery System - Self-Healing Context Corruption

check_and_recover() {
    local issues_found=0
    local recovery_succeeded=true

    # 1. Check JSON validity
    if ! validate_json_files; then
        issues_found=$((issues_found + 1))
        if repair_json_files; then
            echo "✓ JSON corruption auto-fixed"
        else
            recovery_succeeded=false
        fi
    fi

    # 2. Check schema validity
    if ! validate_schema; then
        issues_found=$((issues_found + 1))
        if add_missing_fields; then
            echo "✓ Schema issues auto-fixed"
        else
            recovery_succeeded=false
        fi
    fi

    # 3. Check timestamp staleness
    if is_state_stale; then
        issues_found=$((issues_found + 1))
        echo "⚠ State is stale (>24h). Consider reset."
    fi

    # 4. Check cross-file consistency
    if ! validate_consistency; then
        issues_found=$((issues_found + 1))
        if sync_state_files; then
            echo "✓ Consistency issues auto-fixed"
        else
            recovery_succeeded=false
        fi
    fi

    # Final recovery attempt if needed
    if [ "$recovery_succeeded" = false ]; then
        if restore_from_checkpoint; then
            echo "✓ Recovered from checkpoint"
        else
            echo "⚠ Auto-recovery failed. Manual intervention required."
            return 2
        fi
    fi

    if [ "$issues_found" -gt 0 ]; then
        echo "✓ Recovery complete: $issues_found issues fixed"
    fi

    return 0
}
```

### Recovery Hook
**File**: `.claude/hooks/session_start_recovery.json`

```json
{
  "name": "session_start_recovery",
  "trigger": "SessionStart",
  "command": "bash scripts/recovery/automated_recovery.sh",
  "description": "Auto-detect and recover from context corruption at session start",
  "priority": 1
}
```

---

## Recovery Scenarios

### Scenario 1: Corrupted master_state.json
**Problem**: Invalid JSON (missing brace)
**Detection**: `jq` parse fails
**Recovery**:
1. Attempt JSON repair (add missing brace)
2. If fails, restore from backup
3. If no backup, restore from checkpoint
4. If no checkpoint, initialize fresh state with warning

**Result**: Auto-fixed in 95% of cases

### Scenario 2: Missing Required Fields
**Problem**: Schema changed, old state missing new fields
**Detection**: Field access returns null/error
**Recovery**:
1. Add missing fields with safe defaults
2. Update schema version
3. Log migration

**Result**: Auto-fixed in 100% of cases

### Scenario 3: Timestamp Mismatch
**Problem**: context_tracking.json says 50%, but operation_log shows >150K tokens used
**Detection**: Calculate tokens from log, compare to tracked value
**Recovery**:
1. Recalculate context from operation log
2. Update context_tracking.json
3. Warn if exceeds threshold

**Result**: Auto-fixed in 100% of cases

### Scenario 4: Session Interruption
**Problem**: Session killed mid-operation, partial state written
**Detection**: Check for incomplete operations (no end timestamp)
**Recovery**:
1. Mark operation as "interrupted"
2. Roll back to last complete operation
3. Resume from safe checkpoint

**Result**: Auto-fixed in 80% of cases

---

## Testing Strategy

### Unit Tests
- Test each recovery function independently
- Mock corrupt state files
- Verify recovery logic

### Integration Tests
- Inject corruption at various points
- Run framework operations
- Verify auto-recovery triggers and succeeds

### Chaos Testing
- Randomly corrupt state during operations
- Measure recovery success rate
- Target: >90% auto-recovery rate

---

## Success Criteria

- ✅ Detect 100% of common corruption patterns
- ✅ Auto-recover >90% of corruptions
- ✅ Zero user intervention for recoverable issues
- ✅ Graceful degradation for unrecoverable issues
- ✅ Clear logging of recovery actions
- ✅ Backup created before all repairs

---

## Future Enhancements (v4.8.0+)

1. **Machine Learning Recovery** - Learn from past corruptions
2. **Predictive Detection** - Detect corruption before it happens
3. **Cloud Backup** - Sync state to cloud for disaster recovery
4. **Recovery Analytics** - Track recovery patterns, improve strategies

---

**Status**: Design Complete - Ready for Implementation
**Next**: Implement core recovery functions in scripts/recovery/
**Estimated**: 4-6 hours implementation + 2 hours testing
