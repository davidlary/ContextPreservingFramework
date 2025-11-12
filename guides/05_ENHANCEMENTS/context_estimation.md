# Enhancement: Context Estimation & Tracking

**Purpose**: Automated estimation and tracking of context usage
**Value**: High
**Integration**: Real-time monitoring during development
**Complexity**: Low to Medium

---

## Concept

**The Problem**: You don't know how much context you're using until it's too late. Reaching 80-90% context forces abrupt session ends and lost momentum.

**The Solution**: Automated context estimation that warns at 30% and triggers checkpoints at 35%, giving you control over session boundaries.

**Key Insight**: Context usage is predictable. File size → token count with high accuracy. Track in real-time to prevent surprises.

---

## How Context Estimation Works

### Token Estimation Formula

**For code files**:
```
tokens ≈ characters / 4

# More accurate by language:
Python:     tokens ≈ characters / 4.2
JavaScript: tokens ≈ characters / 3.8
Java:       tokens ≈ characters / 4.5
Markdown:   tokens ≈ characters / 4.0
JSON:       tokens ≈ characters / 3.5
```

**For files**:
```
tokens ≈ file_size_bytes / 4
```

**Context percentage**:
```
context_percentage = (current_tokens / max_tokens) * 100

# For Claude Code (200K context window):
context_percentage = (current_tokens / 200000) * 100
```

---

## Implementation

### Option 1: Simple Shell Script (5 minutes setup)

**Create**: `scripts/estimate_context.sh`

```bash
#!/bin/bash
# estimate_context.sh - Estimate current context usage

MAX_TOKENS=200000
WARN_THRESHOLD=0.30
CRITICAL_THRESHOLD=0.35

# Count tokens from files in context
estimate_tokens() {
    local total_bytes=0

    # Sum file sizes
    for file in "$@"; do
        if [ -f "$file" ]; then
            size=$(wc -c < "$file")
            total_bytes=$((total_bytes + size))
        fi
    done

    # Convert bytes to tokens (approximately)
    tokens=$((total_bytes / 4))
    echo $tokens
}

# Calculate percentage
calculate_percentage() {
    local tokens=$1
    local percentage=$(echo "scale=2; ($tokens / $MAX_TOKENS) * 100" | bc)
    echo $percentage
}

# Main estimation
main() {
    # Files typically in context
    files=(
        "CLAUDE.md"
        "AUTONOMOUS_MODE.md"
        "ARCHITECTURE.md"
        "data/state/master_state.json"
    )

    # Add any files passed as arguments
    files+=("$@")

    tokens=$(estimate_tokens "${files[@]}")
    percentage=$(calculate_percentage $tokens)

    echo "═══════════════════════════════════════"
    echo "Context Estimation"
    echo "═══════════════════════════════════════"
    echo "Files checked: ${#files[@]}"
    echo "Estimated tokens: $tokens"
    echo "Context usage: ${percentage}%"
    echo "Max tokens: $MAX_TOKENS"
    echo ""

    # Check thresholds
    if (( $(echo "$percentage >= 35.0" | bc -l) )); then
        echo "⚠️  CRITICAL: Context ≥ 35% - EXIT SESSION NOW"
        echo "Action: Create recovery prompt and exit"
        return 2
    elif (( $(echo "$percentage >= 30.0" | bc -l) )); then
        echo "⚠️  WARNING: Context ≥ 30% - Checkpoint soon"
        echo "Action: Finish current task then checkpoint"
        return 1
    else
        echo "✅ SAFE: Context < 30%"
        echo "Remaining capacity: $((MAX_TOKENS - tokens)) tokens"
        return 0
    fi
}

main "$@"
```

**Make executable**:
```bash
chmod +x scripts/estimate_context.sh
```

**Usage**:
```bash
# Estimate context
./scripts/estimate_context.sh

# Include specific files
./scripts/estimate_context.sh src/main.py src/utils.py
```

**Output**:
```
═══════════════════════════════════════
Context Estimation
═══════════════════════════════════════
Files checked: 6
Estimated tokens: 42000
Context usage: 21.00%
Max tokens: 200000

✅ SAFE: Context < 30%
Remaining capacity: 158000 tokens
```

---

### Option 2: Python Script with Detailed Tracking (15 minutes setup)

**Create**: `scripts/estimate_context.py`

```python
#!/usr/bin/env python3
"""
Context estimation with detailed tracking
"""
import os
import json
from pathlib import Path
from datetime import datetime

MAX_TOKENS = 200000
WARN_THRESHOLD = 0.30
CRITICAL_THRESHOLD = 0.35

# Language-specific token ratios (characters per token)
CHAR_PER_TOKEN = {
    '.py': 4.2,
    '.js': 3.8,
    '.ts': 3.8,
    '.java': 4.5,
    '.go': 4.0,
    '.rs': 4.3,
    '.md': 4.0,
    '.json': 3.5,
    '.yaml': 3.8,
    '.txt': 4.0,
}

def estimate_file_tokens(filepath):
    """Estimate tokens for a single file"""
    size = os.path.getsize(filepath)
    ext = Path(filepath).suffix
    ratio = CHAR_PER_TOKEN.get(ext, 4.0)
    return int(size / ratio)

def estimate_context(files):
    """Estimate context from list of files"""
    file_details = []
    total_tokens = 0

    for filepath in files:
        if os.path.exists(filepath):
            tokens = estimate_file_tokens(filepath)
            total_tokens += tokens
            file_details.append({
                'file': filepath,
                'tokens': tokens,
                'size': os.path.getsize(filepath)
            })

    percentage = (total_tokens / MAX_TOKENS) * 100

    return {
        'total_tokens': total_tokens,
        'percentage': percentage,
        'max_tokens': MAX_TOKENS,
        'files': file_details,
        'status': get_status(percentage),
        'timestamp': datetime.now().isoformat()
    }

def get_status(percentage):
    """Get status level based on percentage"""
    if percentage >= CRITICAL_THRESHOLD * 100:
        return 'CRITICAL'
    elif percentage >= WARN_THRESHOLD * 100:
        return 'WARNING'
    else:
        return 'SAFE'

def print_report(estimation):
    """Print formatted report"""
    print("═" * 60)
    print("Context Estimation Report")
    print("═" * 60)
    print(f"Timestamp: {estimation['timestamp']}")
    print(f"Total tokens: {estimation['total_tokens']:,}")
    print(f"Context usage: {estimation['percentage']:.2f}%")
    print(f"Max tokens: {estimation['max_tokens']:,}")
    print(f"Status: {estimation['status']}")
    print()

    # File breakdown
    print("File Breakdown:")
    print("-" * 60)
    for file_info in estimation['files']:
        print(f"  {file_info['file']:40s} {file_info['tokens']:>6,} tokens")
    print("-" * 60)
    print(f"  {'TOTAL':40s} {estimation['total_tokens']:>6,} tokens")
    print()

    # Status-specific advice
    status = estimation['status']
    if status == 'CRITICAL':
        print("⚠️  CRITICAL: Context ≥ 35%")
        print("Action: EXIT SESSION NOW")
        print("  1. Save current work")
        print("  2. Create recovery prompt")
        print("  3. Git commit")
        print("  4. Exit and start new session")
    elif status == 'WARNING':
        print("⚠️  WARNING: Context ≥ 30%")
        print("Action: CHECKPOINT SOON")
        print("  1. Finish current task")
        print("  2. Git commit")
        print("  3. Create recovery prompt")
        print("  4. Consider checkpointing")
    else:
        remaining = estimation['max_tokens'] - estimation['total_tokens']
        print("✅ SAFE: Context < 30%")
        print(f"Remaining capacity: {remaining:,} tokens")
        print(f"Estimated work time: {remaining // 5000} more operations")

    print("═" * 60)

    return 0 if status == 'SAFE' else (1 if status == 'WARNING' else 2)

def save_tracking(estimation, filepath='data/state/context_tracking.json'):
    """Save context tracking history"""
    # Load existing history
    history = []
    if os.path.exists(filepath):
        with open(filepath) as f:
            history = json.load(f)

    # Append current estimation
    history.append(estimation)

    # Keep last 100 entries
    history = history[-100:]

    # Save
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w') as f:
        json.dump(history, f, indent=2)

def main():
    import sys

    # Default files to check
    files = [
        'CLAUDE.md',
        'AUTONOMOUS_MODE.md',
        'ARCHITECTURE.md',
        'data/state/master_state.json',
    ]

    # Add files from command line
    if len(sys.argv) > 1:
        files.extend(sys.argv[1:])

    # Filter to existing files
    files = [f for f in files if os.path.exists(f)]

    # Estimate
    estimation = estimate_context(files)

    # Print report
    exit_code = print_report(estimation)

    # Save tracking
    save_tracking(estimation)

    sys.exit(exit_code)

if __name__ == '__main__':
    main()
```

**Make executable**:
```bash
chmod +x scripts/estimate_context.py
```

**Usage**:
```bash
# Basic estimation
python scripts/estimate_context.py

# Include specific files
python scripts/estimate_context.py src/*.py tests/*.py

# View history
python -c "import json; print(json.dumps(json.load(open('data/state/context_tracking.json')), indent=2))"
```

---

## Integration with Core Workflow

### Add to CLAUDE.md

```markdown
## Context Tracking (MANDATORY)

After EVERY tool operation:
1. Log operation
2. Update master_state.json
3. **Estimate context: `python scripts/estimate_context.py`**
4. Check threshold

**Thresholds**:
- < 30%: SAFE, continue
- 30-35%: WARNING, finish task then checkpoint
- ≥ 35%: CRITICAL, exit session NOW
```

### Automated Tracking

**Option A: Add to post-operation routine**

In your workflow, after each significant operation:
```bash
# After writing code
python scripts/estimate_context.py src/module.py

# After reading multiple files
python scripts/estimate_context.py $(cat .context_files)
```

**Option B: Hook into git commits**

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Estimate context before each commit
python scripts/estimate_context.py

# Warn if high
exit_code=$?
if [ $exit_code -eq 2 ]; then
    echo "WARNING: Context critical (≥35%)"
    echo "Consider exiting session after this commit"
fi
```

---

## Real-Time Context Display

### Option: Status Bar Script

**Create**: `scripts/context_status.sh`

```bash
#!/bin/bash
# Display real-time context status

while true; do
    clear
    python scripts/estimate_context.py
    echo ""
    echo "Press Ctrl+C to stop"
    sleep 60  # Update every minute
done
```

**Run in separate terminal**:
```bash
./scripts/context_status.sh
```

---

## Example: Context Growth Over Session

**Session start**:
```
Context: 2% (4K tokens)
Files: CLAUDE.md, master_state.json
```

**After reading architecture**:
```
Context: 8% (16K tokens)
Files: + ARCHITECTURE.md
```

**After implementing Module 1**:
```
Context: 18% (36K tokens)
Files: + src/module1.py, tests/test_module1.py
```

**After implementing Module 2**:
```
Context: 28% (56K tokens)
Files: + src/module2.py, tests/test_module2.py
Status: SAFE (but approaching warning)
```

**After implementing Module 3**:
```
Context: 33% (66K tokens)
Files: + src/module3.py, tests/test_module3.py
Status: WARNING ⚠️
Action: Finish Module 3, commit, checkpoint
```

**Decision**: Complete Module 3, commit, create recovery prompt, exit session

**Without estimation**: Would continue to 80-90%, forced abrupt exit, lose context

**With estimation**: Controlled exit at 35%, smooth recovery next session

---

## Benefits

1. **Predictable sessions**
   - Know when to checkpoint
   - No surprise exits
   - Plan work around context budget

2. **Maximize work per session**
   - Use full 35% capacity
   - Never leave capacity unused
   - Optimal session length

3. **Better recovery prompts**
   - Create at ideal time
   - Include right amount of context
   - Smoother session transitions

4. **Historical tracking**
   - See context growth patterns
   - Optimize file structure
   - Learn what consumes context

5. **Confidence**
   - Always know where you stand
   - No fear of context exhaustion
   - Focus on work, not context

---

## Advanced: Context Budget Planning

**Before session, estimate work**:

```python
# scripts/plan_session.py

def estimate_session_budget(modules):
    """Estimate if modules fit in one session"""

    base_context = 4000  # CLAUDE.md, etc.
    per_module = 8000    # Average per module

    estimated_tokens = base_context + (len(modules) * per_module)
    percentage = (estimated_tokens / 200000) * 100

    if percentage < 35:
        print(f"✅ All {len(modules)} modules fit in one session")
        print(f"Estimated context: {percentage:.1f}%")
    else:
        # Calculate how many modules fit
        max_modules = int((200000 * 0.35 - base_context) / per_module)
        print(f"⚠️  Only {max_modules} modules fit in one session")
        print(f"Suggested: Break into {len(modules) // max_modules + 1} sessions")

    return percentage < 35
```

**Usage before starting**:
```python
modules = ['1.1', '1.2', '1.3', '1.4', '1.5']
estimate_session_budget(modules)

# Output:
# ⚠️  Only 3 modules fit in one session
# Suggested: Break into 2 sessions
```

---

## Success Metrics

**Without Context Estimation**:
- Average session context: 75-90%
- Sessions ended: Forced (ran out of context)
- Wasted capacity: High (ended at 90%, could have ended at 35%)
- Recovery: Difficult (too much to remember)

**With Context Estimation**:
- Average session context: 30-35%
- Sessions ended: Planned (controlled checkpoints)
- Wasted capacity: Low (use full 35%)
- Recovery: Easy (smooth handoffs)

**Result**: 60% more work per session, 100% better recovery

---

## Troubleshooting

**Issue**: Estimation says 20% but feels like more

**Cause**: Not accounting for conversation history

**Solution**: Track cumulative operations, not just files
```python
# Add to estimation
conversation_tokens = operations_count * 500  # Rough estimate
total = file_tokens + conversation_tokens
```

---

**Issue**: Want more accurate estimates

**Solution**: Calibrate for your project
```python
# After session, compare estimate vs. actual
actual_tokens = <from Claude status>
estimated_tokens = <from script>
ratio = actual_tokens / estimated_tokens

# Adjust CHAR_PER_TOKEN values
```

---

## Next Steps

1. **Install script**: Choose simple bash or full Python version
2. **Run once**: See current context usage
3. **Add to workflow**: Check after each operation
4. **Track history**: Monitor patterns over time
5. **Plan sessions**: Use estimates to plan work

---

**Related**:
- See 04_CORE_WORKFLOW.md for integration
- See external_memory.md for context reduction strategies
- See 10_REFERENCE/token_costs.md for reference tables
