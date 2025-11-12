# Success Metrics Reference

**How to measure framework effectiveness**

---

## Overview

The Context-Preserving Framework aims to improve several key metrics compared to working without the framework. This document defines those metrics and provides benchmarks.

---

## Primary Metrics

### 1. Session Duration

**Definition**: How long a single working session lasts before context exhaustion

**Without Framework**:
- Typical: 30-60 minutes
- Forced exit at: 80-95% context
- Abrupt endings: Frequent
- Lost momentum: Common

**With Framework**:
- Target: 2-4 hours
- Planned exit at: 30-35% context
- Abrupt endings: Rare
- Lost momentum: Minimal

**Measurement**:
```bash
# Track in master_state.json
session_info.session_start → session_info.last_update

# Or via git
git log --since="session_start" --until="session_end" --format="%at" | head -1
git log --since="session_start" --until="session_end" --format="%at" | tail -1
```

**Success Criteria**:
- ✅ Sessions last > 90 minutes consistently
- ✅ Average session > 2 hours
- ✅ < 10% of sessions end abruptly (unplanned)

---

### 2. Work Completed Per Session

**Definition**: Amount of meaningful work completed in one session

**Without Framework**:
- Modules per session: 1-2
- Lines of code: 200-400
- Tests written: 5-10
- Rework needed: 20-30%

**With Framework**:
- Modules per session: 4-6
- Lines of code: 800-1,500
- Tests written: 20-40
- Rework needed: < 10%

**Measurement**:
```bash
# Modules completed
jq '.modules_complete | length' data/state/master_state.json

# Lines of code (for session)
git diff --stat session_start_commit..session_end_commit

# Tests
pytest --collect-only | wc -l
```

**Success Criteria**:
- ✅ 3+ modules completed per session
- ✅ 600+ lines of quality code per session
- ✅ 15+ tests written and passing per session

---

### 3. Context Efficiency

**Definition**: Percentage of context used for actual work vs. overhead

**Without Framework**:
- Work context: 20-30%
- Overhead context: 70-80%
- Effective usage: Low
- Wasted capacity: High

**With Framework**:
- Work context: 60-70%
- Overhead context: 30-40%
- Effective usage: High
- Wasted capacity: Minimal

**Measurement**:
```python
# From context_tracking.json
work_tokens = sum(tokens for files in actual_work_files)
overhead_tokens = sum(tokens for files in framework_files)
efficiency = work_tokens / (work_tokens + overhead_tokens)

# Target: > 0.60 (60% efficiency)
```

**Success Criteria**:
- ✅ < 35% context usage at session end
- ✅ > 60% of context used for actual work
- ✅ Framework overhead < 10K tokens

---

### 4. Recovery Success Rate

**Definition**: How successfully you can resume work in a new session

**Without Framework**:
- Successful recovery: 40-60%
- Time to resume: 15-30 minutes
- Re-reading files: Extensive
- Lost context: Common

**With Framework**:
- Successful recovery: 95-100%
- Time to resume: < 2 minutes
- Re-reading files: Minimal
- Lost context: Rare

**Measurement**:
```bash
# Track manually or via state
recovered_successfully = (sessions_with_smooth_recovery / total_sessions) * 100

# Time to resume = time from new session start to first actual work
```

**Success Criteria**:
- ✅ > 90% of sessions resume smoothly
- ✅ < 5 minutes to resume work
- ✅ No work re-done due to lost context

---

### 5. Session Count to Completion

**Definition**: How many sessions needed to complete a project

**Without Framework**:
- Sessions per module: 1.5-2
- Total for 10 modules: 15-20 sessions
- Calendar time: 4-6 weeks

**With Framework**:
- Sessions per module: 0.2-0.25 (4-5 per session)
- Total for 10 modules: 2-3 sessions
- Calendar time: 1-2 weeks

**Measurement**:
```bash
# From master_state.json
total_sessions = session_info.current_session
modules_completed = length(modules_complete)
sessions_per_module = total_sessions / modules_completed
```

**Success Criteria**:
- ✅ < 0.5 sessions per module (2+ modules per session)
- ✅ Complete typical project in 3-5 sessions
- ✅ < 2 weeks calendar time for 10-module project

---

## Secondary Metrics

### 6. Test Coverage

**Definition**: Percentage of code covered by tests

**Target**: > 80% coverage

**Measurement**:
```bash
# Python
pytest --cov=src --cov-report=term

# JavaScript
npm test -- --coverage

# Store in master_state.json
"metrics": {
  "test_coverage": 0.85
}
```

---

### 7. Git Commit Frequency

**Definition**: How often work is committed

**Target**: Every 30 minutes or per module (whichever is more frequent)

**Measurement**:
```bash
# Commits per session
git log --since="session_start" --until="session_end" --oneline | wc -l

# Average time between commits
git log --since="session_start" --until="session_end" --format="%at" |
  awk '{if(NR>1) print ($1-prev)/60; prev=$1}'
```

**Success Criteria**:
- ✅ 3+ commits per session
- ✅ Average < 45 minutes between commits
- ✅ Every module has at least one commit

---

### 8. State File Accuracy

**Definition**: How often state files match reality

**Target**: 100% accuracy

**Measurement**:
```bash
# Validate state
python scripts/validate_state.py

# Check state vs. reality
actual_tests=$(pytest --collect-only | wc -l)
state_tests=$(jq '.tests_total' data/state/master_state.json)
accuracy=$((actual_tests == state_tests ? 100 : 0))
```

**Success Criteria**:
- ✅ State validation passes 100% of time
- ✅ Test counts match actual
- ✅ Module statuses accurate

---

### 9. Documentation Completeness

**Definition**: How well code is documented

**Measurement**:
```python
# Python docstring coverage
import ast

def count_docstrings(file_path):
    with open(file_path) as f:
        tree = ast.parse(f.read())

    functions = [node for node in ast.walk(tree) if isinstance(node, ast.FunctionDef)]
    with_docstrings = [f for f in functions if ast.get_docstring(f)]

    return len(with_docstrings) / len(functions) if functions else 0
```

**Success Criteria**:
- ✅ All public functions documented
- ✅ All modules have docstrings
- ✅ README.md exists and current

---

### 10. Error Rate

**Definition**: Frequency of errors during development

**Measurement**:
```bash
# Track in logs
errors=$(grep "ERROR" logs/operation_log.txt | wc -l)
operations=$(wc -l logs/operation_log.txt | cut -d' ' -f1)
error_rate=$(echo "scale=4; $errors / $operations" | bc)
```

**Success Criteria**:
- ✅ < 5% error rate
- ✅ No repeated errors (indicates learning)
- ✅ All errors handled within 3 retries

---

## Framework-Specific Metrics

### 11. Context Warnings

**Definition**: Frequency of context warnings during session

**Without Framework**: Not tracked, only know when too late

**With Framework**:
- Warnings at 30%: Useful, allows planning
- Critical at 35%: Early enough to exit gracefully

**Measurement**:
```bash
# From context_tracking.json
warnings=$(jq '[.[] | select(.status == "WARNING")] | length' data/state/context_tracking.json)
criticals=$(jq '[.[] | select(.status == "CRITICAL")] | length' data/state/context_tracking.json)
```

**Success Criteria**:
- ✅ 0-1 warnings per session (hitting 30% is okay, shows good usage)
- ✅ 0 criticals after session start (no surprises)
- ✅ Exit before reaching critical

---

### 12. Recovery Prompt Quality

**Definition**: How complete and useful recovery prompts are

**Measurement** (manual checklist):
- [ ] Includes git commit hash
- [ ] Lists completed modules
- [ ] Describes current work
- [ ] Provides specific next steps
- [ ] Lists files to read
- [ ] Includes context percentage

**Success Criteria**:
- ✅ All 6 items present in recovery prompt
- ✅ Recovery prompt successfully used
- ✅ No additional context needed beyond prompt

---

### 13. Module Size Consistency

**Definition**: How consistently modules stay within target size

**Target**: 150-300 lines per module

**Measurement**:
```bash
# For all modules
for file in src/*.py; do
    wc -l "$file"
done | awk '{if($1 < 150 || $1 > 300) print $2}'

# Should return empty (all within range)
```

**Success Criteria**:
- ✅ 90% of modules within 150-300 lines
- ✅ No modules > 500 lines
- ✅ Consistent sizing across project

---

## Comparison Tables

### Before vs. After Framework

| Metric | Without Framework | With Framework | Improvement |
|--------|------------------|----------------|-------------|
| Session duration | 30-60 min | 120-240 min | 4× longer |
| Modules per session | 1-2 | 4-6 | 3× more |
| Context usage | 80-95% | 30-35% | 3× more efficient |
| Recovery success | 40-60% | 95-100% | 2× better |
| Sessions per project | 15-20 | 2-3 | 6× fewer |
| Time to resume | 15-30 min | < 2 min | 10× faster |
| Rework needed | 20-30% | < 10% | 3× less |
| Calendar time | 4-6 weeks | 1-2 weeks | 3× faster |

---

### Project Size Benchmarks

| Project Size | Modules | Without Framework | With Framework | Time Saved |
|--------------|---------|------------------|----------------|------------|
| Small (5 modules) | 5 | 8-10 sessions (2 weeks) | 1-2 sessions (3 days) | 11 days |
| Medium (10 modules) | 10 | 15-20 sessions (5 weeks) | 2-3 sessions (1 week) | 4 weeks |
| Large (20 modules) | 20 | 30-40 sessions (10 weeks) | 4-5 sessions (2 weeks) | 8 weeks |
| Extra Large (50 modules) | 50 | 75-100 sessions (25 weeks) | 10-12 sessions (4 weeks) | 21 weeks |

---

## Tracking Sheet Template

Create a tracking sheet to monitor your metrics:

```markdown
# Project Metrics - [Project Name]

## Session Summary

| Session | Date | Duration | Modules | Context % | Commits | Tests | Notes |
|---------|------|----------|---------|-----------|---------|-------|-------|
| 1 | 2025-01-15 | 3h 15m | 3 | 32% | 4 | 36/36 | Smooth |
| 2 | 2025-01-16 | 2h 45m | 3 | 28% | 3 | 60/60 | Perfect |
| 3 | 2025-01-17 | 3h 30m | 4 | 34% | 5 | 88/88 | Excellent |

## Totals

- **Total sessions**: 3
- **Total time**: 9h 30m
- **Modules completed**: 10
- **Tests passing**: 88/88
- **Average context**: 31%
- **Average session**: 3h 10m

## Framework Effectiveness

- ✅ Average session > 2 hours: YES (3h 10m)
- ✅ Modules per session > 3: YES (3.3 avg)
- ✅ Context < 35%: YES (31% avg)
- ✅ Recovery rate > 90%: YES (100%)
- ✅ Test coverage > 80%: YES (95%)

**Overall**: Framework is effective ✅
```

---

## Automated Metrics Collection

**Script**: `scripts/collect_metrics.py`

```python
#!/usr/bin/env python3
"""
Collect project metrics automatically
"""
import json
import subprocess
from datetime import datetime

def collect_metrics():
    # Load state
    with open('data/state/master_state.json') as f:
        state = json.load(f)

    # Calculate metrics
    metrics = {
        'timestamp': datetime.now().isoformat(),
        'session': state['session_info']['current_session'],
        'modules_complete': len(state['modules_complete']),
        'tests_passing': state['tests_passing'],
        'tests_total': state['tests_total'],
        'test_coverage': state['metrics'].get('test_coverage', 0),
        'context_percentage': state['context_usage']['percentage'],
        'git_commits': state['git_info']['commits_this_session'],
    }

    # Session duration
    start = datetime.fromisoformat(state['session_info']['session_start'].replace('Z', '+00:00'))
    now = datetime.now().astimezone()
    duration = (now - start).total_seconds() / 3600  # hours
    metrics['session_duration_hours'] = round(duration, 2)

    # Save metrics
    history_file = 'data/metrics_history.json'
    try:
        with open(history_file) as f:
            history = json.load(f)
    except FileNotFoundError:
        history = []

    history.append(metrics)

    with open(history_file, 'w') as f:
        json.dump(history, f, indent=2)

    # Print summary
    print("📊 Current Session Metrics")
    print("=" * 50)
    print(f"Session: {metrics['session']}")
    print(f"Duration: {metrics['session_duration_hours']:.2f} hours")
    print(f"Modules: {metrics['modules_complete']}")
    print(f"Tests: {metrics['tests_passing']}/{metrics['tests_total']}")
    print(f"Context: {metrics['context_percentage']:.1f}%")
    print(f"Commits: {metrics['git_commits']}")

if __name__ == '__main__':
    collect_metrics()
```

**Run**:
```bash
python scripts/collect_metrics.py
```

---

## Success Checklist

Use this checklist to verify framework effectiveness:

### Session Level
- [ ] Session lasted > 2 hours
- [ ] Completed 3+ modules
- [ ] Context usage < 35% at end
- [ ] 3+ git commits
- [ ] All tests passing
- [ ] Recovery prompt created
- [ ] State files accurate

### Project Level
- [ ] Completed in ≤ 5 sessions
- [ ] Test coverage > 80%
- [ ] < 2 weeks calendar time
- [ ] Zero lost work
- [ ] All modules within size guidelines
- [ ] Documentation complete
- [ ] Git history clean and descriptive

### Framework Level
- [ ] No abrupt session ends
- [ ] 100% recovery success
- [ ] Context overhead < 10K tokens
- [ ] State validation always passes
- [ ] Commit frequency appropriate
- [ ] No repeated errors

---

**See Also**:
- 10_REFERENCE/token_costs.md - Context budgeting
- 04_CORE_WORKFLOW.md - Daily workflow
- 07_TESTING_GUIDE.md - Test coverage targets
