# Enhanced Recovery Guide

**Automatic crash detection and recovery procedures**

**Estimated reading time**: 15 minutes
**Token cost**: ~12K tokens (6% context)
**When to read**: When setting up robust recovery mechanisms

---

## Table of Contents

1. [Crash Detection](#crash-detection)
2. [Automatic Recovery](#automatic-recovery)
3. [State Corruption Detection](#state-corruption-detection)
4. [Session Timeout Handling](#session-timeout-handling)
5. [Recovery Validation](#recovery-validation)
6. [Emergency Recovery Protocols](#emergency-recovery-protocols)

---

## Crash Detection

### Types of Crashes

**1. Context Overflow Crash**
- **Symptom**: Session ends abruptly at 85%+ context
- **Cause**: Exceeded 200K token limit
- **Prevention**: Framework's 35% threshold (should never happen)

**2. Network Timeout**
- **Symptom**: Connection lost mid-operation
- **Cause**: Network interruption, API timeout
- **Detection**: Last operation incomplete in logs

**3. State Corruption**
- **Symptom**: Invalid JSON, missing fields
- **Cause**: Interrupted write, concurrent writes
- **Detection**: JSON validation fails

**4. Git Conflict**
- **Symptom**: Cannot commit, merge conflicts
- **Cause**: Multiple developers, force push
- **Detection**: `git status` shows conflicts

---

### Automated Crash Detection

**Script**: `scripts/detect_crash.py`

```python
#!/usr/bin/env python3
"""
Detect if previous session crashed and needs recovery.
"""

import json
import sys
from pathlib import Path
from datetime import datetime, timedelta

def check_state_files():
    """Check if state files are valid"""
    state_file = Path('data/state/master_state.json')

    if not state_file.exists():
        return {'status': 'missing', 'file': str(state_file)}

    try:
        with open(state_file, 'r') as f:
            state = json.load(f)

        # Check required fields
        required = ['project', 'current_phase', 'last_update']
        missing = [f for f in required if f not in state]

        if missing:
            return {'status': 'incomplete', 'missing_fields': missing}

        return {'status': 'valid', 'state': state}

    except json.JSONDecodeError as e:
        return {'status': 'corrupted', 'error': str(e)}

def check_recovery_prompt():
    """Check if recovery prompt exists for last session"""
    prompts_dir = Path('docs/recovery_prompts')

    if not prompts_dir.exists():
        return {'status': 'missing_directory'}

    # Find most recent recovery prompt
    prompts = sorted(prompts_dir.glob('*_RECOVERY.md'), key=lambda p: p.stat().st_mtime)

    if not prompts:
        return {'status': 'no_prompts'}

    latest = prompts[-1]
    age = datetime.now() - datetime.fromtimestamp(latest.stat().st_mtime)

    return {
        'status': 'found',
        'file': str(latest),
        'age_hours': age.total_seconds() / 3600
    }

def check_operation_log():
    """Check if last operation completed"""
    log_file = Path('logs/operation_log.txt')

    if not log_file.exists():
        return {'status': 'missing_log'}

    with open(log_file, 'r') as f:
        lines = f.readlines()

    if not lines:
        return {'status': 'empty_log'}

    last_line = lines[-1].strip()

    # Check if last operation was checkpoint
    if 'CHECKPOINT' in last_line or 'SESSION_END' in last_line:
        return {'status': 'clean_exit', 'last_operation': last_line}
    else:
        return {'status': 'incomplete_session', 'last_operation': last_line}

def detect_crash():
    """Main crash detection logic"""
    results = {
        'state': check_state_files(),
        'recovery_prompt': check_recovery_prompt(),
        'operation_log': check_operation_log()
    }

    # Determine if crash occurred
    crashed = False
    reasons = []

    if results['state']['status'] in ['corrupted', 'incomplete']:
        crashed = True
        reasons.append('State file corrupted or incomplete')

    if results['operation_log']['status'] == 'incomplete_session':
        crashed = True
        reasons.append('Last session did not end cleanly')

    if results['recovery_prompt']['status'] == 'no_prompts':
        crashed = True
        reasons.append('No recovery prompts found')

    return {
        'crashed': crashed,
        'reasons': reasons,
        'details': results
    }

def main():
    """Run crash detection"""
    print("🔍 Checking for previous crash...\n")

    result = detect_crash()

    if result['crashed']:
        print("❌ CRASH DETECTED")
        print("\nReasons:")
        for reason in result['reasons']:
            print(f"  - {reason}")

        print("\n⚠️  Recovery needed. Run: python scripts/auto_recover.py")
        sys.exit(1)
    else:
        print("✅ No crash detected. Session ended cleanly.")
        sys.exit(0)

if __name__ == '__main__':
    main()
```

**Usage**:
```bash
# Run at start of every session
python scripts/detect_crash.py

# If crash detected:
# ❌ CRASH DETECTED
# Reasons:
#   - Last session did not end cleanly
# ⚠️  Recovery needed. Run: python scripts/auto_recover.py
```

---

## Automatic Recovery

### Auto-Recovery Script

**Script**: `scripts/auto_recover.py`

```python
#!/usr/bin/env python3
"""
Automatically recover from crash.
"""

import json
import subprocess
from pathlib import Path
from datetime import datetime

def backup_corrupted_state():
    """Backup corrupted state before recovery"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_dir = Path(f'data/backups/crash_{timestamp}')
    backup_dir.mkdir(parents=True, exist_ok=True)

    # Backup all state files
    for state_file in Path('data/state').glob('*.json'):
        backup_file = backup_dir / state_file.name
        subprocess.run(['cp', str(state_file), str(backup_file)])

    print(f"✅ Backed up state to {backup_dir}")
    return backup_dir

def restore_from_git():
    """Restore state files from last good commit"""
    print("🔄 Restoring state from git...")

    # Find last commit that modified state files
    result = subprocess.run(
        ['git', 'log', '-1', '--format=%H', '--', 'data/state/'],
        capture_output=True,
        text=True
    )

    last_commit = result.stdout.strip()

    if not last_commit:
        print("❌ No previous state commit found")
        return False

    # Restore state files from that commit
    subprocess.run(['git', 'checkout', last_commit, '--', 'data/state/'])

    print(f"✅ Restored state from commit {last_commit[:7]}")
    return True

def validate_restored_state():
    """Validate that restored state is valid"""
    print("🔍 Validating restored state...")

    result = subprocess.run(
        ['python', 'scripts/validate_state.py', 'data/state/master_state.json'],
        capture_output=True
    )

    if result.returncode == 0:
        print("✅ Restored state is valid")
        return True
    else:
        print("❌ Restored state is still invalid")
        return False

def find_latest_recovery_prompt():
    """Find most recent recovery prompt"""
    prompts_dir = Path('docs/recovery_prompts')
    prompts = sorted(prompts_dir.glob('*_RECOVERY.md'), key=lambda p: p.stat().st_mtime)

    if prompts:
        return prompts[-1]
    return None

def create_recovery_instructions(backup_dir, recovery_prompt):
    """Create instructions for manual recovery if needed"""
    instructions = Path('RECOVERY_INSTRUCTIONS.md')

    with open(instructions, 'w') as f:
        f.write("# Recovery Instructions\n\n")
        f.write("## Crash Details\n\n")
        f.write(f"- **Time**: {datetime.now()}\n")
        f.write(f"- **Backup location**: {backup_dir}\n\n")

        f.write("## Recovery Steps\n\n")

        if recovery_prompt:
            f.write(f"1. Read recovery prompt: {recovery_prompt}\n")
        else:
            f.write("1. No recovery prompt found. Check git log for last work:\n")
            f.write("   ```bash\n")
            f.write("   git log --oneline -10\n")
            f.write("   ```\n\n")

        f.write("2. Review restored state:\n")
        f.write("   ```bash\n")
        f.write("   cat data/state/master_state.json\n")
        f.write("   ```\n\n")

        f.write("3. Check what was lost:\n")
        f.write("   ```bash\n")
        f.write("   git status\n")
        f.write("   git diff\n")
        f.write("   ```\n\n")

        f.write("4. If you need to restore from backup:\n")
        f.write(f"   ```bash\n")
        f.write(f"   cp {backup_dir}/*.json data/state/\n")
        f.write("   ```\n\n")

    print(f"✅ Recovery instructions written to {instructions}")

def auto_recover():
    """Main auto-recovery logic"""
    print("🔧 Starting automatic recovery...\n")

    # Step 1: Backup corrupted state
    backup_dir = backup_corrupted_state()

    # Step 2: Restore from git
    if not restore_from_git():
        print("❌ Cannot restore from git")
        create_recovery_instructions(backup_dir, None)
        return False

    # Step 3: Validate
    if not validate_restored_state():
        print("❌ Validation failed")
        create_recovery_instructions(backup_dir, None)
        return False

    # Step 4: Find recovery prompt
    recovery_prompt = find_latest_recovery_prompt()

    # Step 5: Create instructions
    create_recovery_instructions(backup_dir, recovery_prompt)

    print("\n✅ Automatic recovery complete!")
    print("\nNext steps:")
    if recovery_prompt:
        print(f"1. Read recovery prompt: {recovery_prompt}")
    print("2. Review RECOVERY_INSTRUCTIONS.md")
    print("3. Continue from where you left off")

    return True

def main():
    """Run auto-recovery"""
    try:
        success = auto_recover()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"❌ Recovery failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    import sys
    main()
```

**Usage**:
```bash
# Automatic recovery
python scripts/auto_recover.py

# Output:
# 🔧 Starting automatic recovery...
# ✅ Backed up state to data/backups/crash_20250111_153045
# 🔄 Restoring state from git...
# ✅ Restored state from commit a1b2c3d
# 🔍 Validating restored state...
# ✅ Restored state is valid
# ✅ Recovery instructions written to RECOVERY_INSTRUCTIONS.md
# ✅ Automatic recovery complete!
```

---

## State Corruption Detection

### Comprehensive State Validator

**Script**: `scripts/validate_state.py` (enhanced)

```python
#!/usr/bin/env python3
"""
Enhanced state validation with corruption detection.
"""

import json
import sys
from pathlib import Path
from jsonschema import validate, ValidationError

def load_state_safe(file_path):
    """Load state with error handling"""
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        return {
            'error': 'json_decode_error',
            'message': str(e),
            'line': e.lineno,
            'column': e.colno
        }
    except FileNotFoundError:
        return {
            'error': 'file_not_found',
            'message': f'File not found: {file_path}'
        }

def check_state_consistency(state):
    """Check logical consistency of state"""
    issues = []

    # Check: modules_in_progress should not be in modules_complete
    in_progress = set(state.get('modules_in_progress', []))
    complete = set(state.get('modules_complete', []))

    overlap = in_progress & complete
    if overlap:
        issues.append({
            'type': 'overlap',
            'message': f'Modules in both in_progress and complete: {overlap}'
        })

    # Check: current_module should be in modules_in_progress
    current = state.get('current_module')
    if current and current not in in_progress:
        issues.append({
            'type': 'orphan_current',
            'message': f'current_module "{current}" not in modules_in_progress'
        })

    # Check: last_update is recent (within 7 days)
    from datetime import datetime, timedelta
    last_update = state.get('last_update')
    if last_update:
        try:
            update_time = datetime.fromisoformat(last_update.replace('Z', '+00:00'))
            age = datetime.now() - update_time.replace(tzinfo=None)
            if age > timedelta(days=7):
                issues.append({
                    'type': 'stale',
                    'message': f'State not updated in {age.days} days'
                })
        except ValueError:
            issues.append({
                'type': 'invalid_timestamp',
                'message': f'Invalid timestamp format: {last_update}'
            })

    return issues

def attempt_repair(state, issues):
    """Attempt to automatically repair state"""
    repaired = state.copy()
    repairs = []

    for issue in issues:
        if issue['type'] == 'overlap':
            # Remove from in_progress (keep in complete)
            overlap = set(repaired.get('modules_in_progress', [])) & set(repaired.get('modules_complete', []))
            repaired['modules_in_progress'] = [m for m in repaired.get('modules_in_progress', []) if m not in overlap]
            repairs.append(f"Removed {overlap} from modules_in_progress")

        elif issue['type'] == 'orphan_current':
            # Set current_module to null
            repaired['current_module'] = None
            repairs.append("Set current_module to null")

        elif issue['type'] == 'stale':
            # Update timestamp to now
            from datetime import datetime
            repaired['last_update'] = datetime.now().isoformat() + 'Z'
            repairs.append("Updated last_update timestamp")

    return repaired, repairs

def main(file_path):
    """Main validation with repair"""
    print(f"🔍 Validating {file_path}...\n")

    # Step 1: Load state
    state = load_state_safe(file_path)

    if 'error' in state:
        print(f"❌ {state['error']}: {state['message']}")
        if 'line' in state:
            print(f"   Line {state['line']}, Column {state['column']}")
        return False

    # Step 2: Check consistency
    issues = check_state_consistency(state)

    if not issues:
        print("✅ State is valid and consistent")
        return True

    # Step 3: Report issues
    print("⚠️  Issues found:")
    for issue in issues:
        print(f"  - [{issue['type']}] {issue['message']}")

    # Step 4: Attempt repair
    print("\n🔧 Attempting automatic repair...")
    repaired, repairs = attempt_repair(state, issues)

    if repairs:
        print("\nRepairs made:")
        for repair in repairs:
            print(f"  ✅ {repair}")

        # Save repaired state
        backup_path = Path(file_path).with_suffix('.json.backup')
        import shutil
        shutil.copy(file_path, backup_path)
        print(f"\n💾 Original backed up to {backup_path}")

        with open(file_path, 'w') as f:
            json.dump(repaired, f, indent=2)

        print(f"💾 Repaired state saved to {file_path}")
        return True
    else:
        print("❌ Cannot automatically repair")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python validate_state.py <state_file>")
        sys.exit(1)

    success = main(sys.argv[1])
    sys.exit(0 if success else 1)
```

---

## Session Timeout Handling

### Detect Abandoned Sessions

**Script**: `scripts/check_abandoned_sessions.py`

```python
#!/usr/bin/env python3
"""
Detect and clean up abandoned sessions.
"""

import json
from pathlib import Path
from datetime import datetime, timedelta

def check_abandoned():
    """Check for sessions that didn't end properly"""
    state_file = Path('data/state/master_state.json')

    with open(state_file, 'r') as f:
        state = json.load(f)

    last_update = datetime.fromisoformat(state['last_update'].replace('Z', '+00:00'))
    now = datetime.now()
    age = now - last_update.replace(tzinfo=None)

    # Session is abandoned if:
    # 1. Last update > 24 hours ago
    # 2. current_module is not None (session was in progress)
    if age > timedelta(hours=24) and state.get('current_module'):
        print(f"⚠️  Abandoned session detected")
        print(f"   Last update: {age.days} days, {age.seconds // 3600} hours ago")
        print(f"   Module in progress: {state['current_module']}")

        # Clean up
        state['current_module'] = None
        state['modules_in_progress'] = []
        state['last_update'] = datetime.now().isoformat() + 'Z'

        with open(state_file, 'w') as f:
            json.dump(state, f, indent=2)

        print("✅ Session cleaned up")
        return True

    print("✅ No abandoned sessions")
    return False

if __name__ == '__main__':
    check_abandoned()
```

---

## Recovery Validation

### Verify Recovery Completeness

**Script**: `scripts/validate_recovery.py`

```python
#!/usr/bin/env python3
"""
Validate that recovery was successful.
"""

def validate_recovery():
    """Comprehensive recovery validation"""
    checks = []

    # Check 1: State files are valid
    result = subprocess.run(['python', 'scripts/validate_state.py', 'data/state/master_state.json'], capture_output=True)
    checks.append(('State files valid', result.returncode == 0))

    # Check 2: Git is clean (no conflicts)
    result = subprocess.run(['git', 'status', '--porcelain'], capture_output=True, text=True)
    has_conflicts = 'UU' in result.stdout  # Unmerged files
    checks.append(('No git conflicts', not has_conflicts))

    # Check 3: All tests pass
    result = subprocess.run(['pytest', 'tests/', '-v'], capture_output=True)
    checks.append(('Tests passing', result.returncode == 0))

    # Check 4: Recovery prompt exists
    recovery_prompt = find_latest_recovery_prompt()
    checks.append(('Recovery prompt exists', recovery_prompt is not None))

    # Report
    print("Recovery Validation Results:\n")
    all_passed = True

    for check_name, passed in checks:
        status = "✅" if passed else "❌"
        print(f"{status} {check_name}")
        if not passed:
            all_passed = False

    if all_passed:
        print("\n✅ Recovery successful! Safe to continue.")
        return True
    else:
        print("\n❌ Recovery incomplete. Manual intervention required.")
        return False

if __name__ == '__main__':
    import sys, subprocess
    success = validate_recovery()
    sys.exit(0 if success else 1)
```

---

## Emergency Recovery Protocols

### Complete State Loss

**If all state files are corrupted or lost**:

```bash
# Protocol: Rebuild from git history

# Step 1: List all commits with state changes
git log --oneline --all -- data/state/

# Step 2: Find last good commit (before corruption)
git show <commit>:data/state/master_state.json

# Step 3: Restore that commit
git checkout <commit> -- data/state/

# Step 4: Rebuild from git log
python scripts/rebuild_state_from_git.py
```

**Script**: `scripts/rebuild_state_from_git.py`

```python
#!/usr/bin/env python3
"""
Rebuild state from git commit history.
"""

import subprocess
import re
import json
from datetime import datetime

def extract_modules_from_git():
    """Extract completed modules from commit messages"""
    result = subprocess.run(
        ['git', 'log', '--all', '--oneline', '--grep=Module'],
        capture_output=True,
        text=True
    )

    modules_complete = []

    for line in result.stdout.split('\n'):
        # Parse: "abc1234 [Module 1.2] Complete authorization"
        match = re.search(r'\[Module ([\d.]+)\]', line)
        if match:
            module = match.group(1)
            if 'Complete' in line or 'complete' in line:
                modules_complete.append(module)

    return sorted(set(modules_complete))

def rebuild_master_state():
    """Rebuild master_state.json from git history"""
    modules = extract_modules_from_git()

    state = {
        'project': 'recovered_project',
        'version': '0.0.0',
        'project_type': 'coding',
        'current_phase': 'recovery',
        'current_module': None,
        'modules_complete': modules,
        'modules_in_progress': [],
        'modules_pending': [],
        'last_update': datetime.now().isoformat() + 'Z',
        'recovered': True,
        'recovery_time': datetime.now().isoformat() + 'Z'
    }

    with open('data/state/master_state.json', 'w') as f:
        json.dump(state, f, indent=2)

    print(f"✅ Rebuilt state with {len(modules)} completed modules")
    print(f"   Modules: {', '.join(modules)}")

if __name__ == '__main__':
    rebuild_master_state()
```

---

### Nuclear Option: Fresh Start

**If recovery is impossible**:

```bash
# Protocol: Archive and restart

# Step 1: Archive entire project
tar -czf ../project_archive_$(date +%Y%m%d).tar.gz .

# Step 2: Preserve critical files
mkdir -p ../recovery_backup
cp -r core/ tests/ ../recovery_backup/
cp -r docs/ ../recovery_backup/

# Step 3: Reinitialize framework
rm -rf data/state/*
python scripts/setup_framework.py --reinit

# Step 4: Rebuild from backup
# Manually review and commit each module

echo "⚠️  Fresh start initiated. Review ../recovery_backup/ for code."
```

---

## Recovery Best Practices

### 1. **Commit Frequently**
- Commit after every module completion
- Never wait until end of day

### 2. **Create Recovery Prompts**
- Generate after every checkpoint
- Include exact next steps

### 3. **Validate State Regularly**
- Run `validate_state.py` daily
- Fix issues immediately

### 4. **Test Recovery Procedures**
- Practice recovery quarterly
- Ensure scripts work

### 5. **Maintain Backups**
- Automated backups daily
- Offsite git remotes

---

## Recovery Checklist

**After any recovery**:

- [ ] State files validated (`validate_state.py`)
- [ ] Git status clean (no conflicts)
- [ ] Tests passing (`pytest tests/`)
- [ ] Recovery prompt exists
- [ ] RECOVERY_INSTRUCTIONS.md reviewed
- [ ] Next steps identified
- [ ] Incident documented in logs

---

**Recovery Guide version**: 3.4
**Last updated**: January 2025
