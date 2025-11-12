# Token Cost Reference

**Quick lookup for token estimation**

**Context Window**: Claude Code has 200,000 tokens (~100 MB text)
**Target Usage**: 30-35% (60,000-70,000 tokens)
**Safety Margin**: Stop at 35% to ensure smooth operation

---

## File Size to Tokens

**Conversion Formula**: `tokens ≈ bytes / 4`

| File Size | Bytes | Estimated Tokens | Context % |
|-----------|-------|------------------|-----------|
| 1 KB | 1,024 | 256 | 0.13% |
| 5 KB | 5,120 | 1,280 | 0.64% |
| 10 KB | 10,240 | 2,560 | 1.28% |
| 20 KB | 20,480 | 5,120 | 2.56% |
| 50 KB | 51,200 | 12,800 | 6.40% |
| 100 KB | 102,400 | 25,600 | 12.80% |
| 200 KB | 204,800 | 51,200 | 25.60% |
| 500 KB | 512,000 | 128,000 | 64.00% |

**Key Insights**:
- Files < 20 KB are "cheap" (< 3% context each)
- Files 50-100 KB are "expensive" (6-13% context each)
- Files > 200 KB are "critical" (> 25% context each)
- Keep important docs under 20 KB for efficiency

---

## Language-Specific Ratios

Different languages have different token densities.

| Language | Chars/Token | Example: 1000 chars → Tokens |
|----------|-------------|------------------------------|
| Python | 4.2 | 238 tokens |
| JavaScript | 3.8 | 263 tokens |
| TypeScript | 3.9 | 256 tokens |
| Java | 4.5 | 222 tokens |
| Go | 4.0 | 250 tokens |
| Rust | 4.3 | 233 tokens |
| C/C++ | 4.1 | 244 tokens |
| Ruby | 3.9 | 256 tokens |
| PHP | 3.7 | 270 tokens |
| HTML | 3.5 | 286 tokens |
| CSS | 3.6 | 278 tokens |
| Markdown | 4.0 | 250 tokens |
| JSON | 3.5 | 286 tokens |
| YAML | 3.8 | 263 tokens |
| SQL | 4.0 | 250 tokens |

**Practical Use**:
```python
# Estimate Python file tokens
file_size_bytes = 10240  # 10 KB
chars = file_size_bytes  # Approximate (UTF-8)
tokens = chars / 4.2
# Result: ~2,438 tokens (1.2% context)
```

---

## Common File Types

Typical token costs for common project files:

| File Type | Typical Size | Tokens | Context % | Notes |
|-----------|--------------|--------|-----------|-------|
| CLAUDE.md | 5-15 KB | 1,250-3,750 | 0.6-1.9% | Keep < 10 KB |
| AUTONOMOUS_MODE.md | 8-12 KB | 2,000-3,000 | 1.0-1.5% | One-time cost |
| ARCHITECTURE.md | 10-30 KB | 2,500-7,500 | 1.3-3.8% | Consider splitting if > 20 KB |
| README.md | 2-10 KB | 500-2,500 | 0.3-1.3% | Usually small |
| master_state.json | 1-3 KB | 286-857 | 0.1-0.4% | Grows with project |
| module_state.json | 0.5-1 KB | 143-286 | 0.1-0.1% | Per module |
| Python module | 5-15 KB | 1,190-3,571 | 0.6-1.8% | Per 250 lines |
| Test file | 3-10 KB | 714-2,381 | 0.4-1.2% | Per module |
| Config file (JSON) | 0.5-2 KB | 143-571 | 0.1-0.3% | Small |

**Session Budget Example**:

Base files (loaded at start):
- CLAUDE.md: 10 KB = 2,500 tokens (1.3%)
- AUTONOMOUS_MODE.md: 10 KB = 2,500 tokens (1.3%)
- ARCHITECTURE.md: 15 KB = 3,750 tokens (1.9%)
- master_state.json: 2 KB = 571 tokens (0.3%)
**Subtotal**: 37 KB = 9,321 tokens (4.7%)

Work on 3 modules:
- 3× Python modules: 30 KB = 7,143 tokens (3.6%)
- 3× Test files: 18 KB = 4,286 tokens (2.1%)
**Subtotal**: 48 KB = 11,429 tokens (5.7%)

**Total**: 85 KB = 20,750 tokens (10.4%)
**Remaining**: ~179 KB / 179,250 tokens (89.6%)

Result: Can comfortably work on 3 modules per session with room for conversation history.

---

## Operation Costs

Estimated token costs for common operations:

| Operation | Tokens Added | Context % | Notes |
|-----------|--------------|-----------|-------|
| Read 1 file (10 KB) | 2,560 | 1.3% | Per file |
| Write 1 file (10 KB) | 2,560 | 1.3% | New file in context |
| Edit 1 file | 200-500 | 0.1-0.3% | Only changed section |
| Run test suite | 500-1,000 | 0.3-0.5% | Output in context |
| Git commit | 200 | 0.1% | Minimal |
| Conversation turn | 100-500 | 0.1-0.3% | Varies by complexity |
| Error + fix | 500-1,000 | 0.3-0.5% | Error message + solution |
| Context estimation | 100 | 0.05% | Script output |

**Conversation History Cost**:
- 10 conversation turns: ~3,000 tokens (1.5%)
- 20 conversation turns: ~6,000 tokens (3.0%)
- 30 conversation turns: ~9,000 tokens (4.5%)
- 40 conversation turns: ~12,000 tokens (6.0%)

**Rule of Thumb**: Budget 5-10K tokens (2.5-5%) for conversation history per session.

---

## Module Size Guidelines

Target module sizes to stay within context budget:

### Micro-Modules (Recommended)

| Lines of Code | File Size | Tokens | Context % | Modules per Session |
|---------------|-----------|--------|-----------|---------------------|
| 100-150 | 4-6 KB | 952-1,429 | 0.5-0.7% | 8-10 |
| 150-200 | 6-8 KB | 1,429-1,905 | 0.7-1.0% | 6-8 |
| 200-250 | 8-10 KB | 1,905-2,381 | 1.0-1.2% | 5-6 |
| 250-300 | 10-12 KB | 2,381-2,857 | 1.2-1.4% | 4-5 |

**Calculation**:
```
Target: 35% context = 70,000 tokens
Base cost: ~10,000 tokens (4 KB files)
Available: 60,000 tokens for modules

Module size: 250 lines = ~10 KB = 2,381 tokens
Modules that fit: 60,000 / 2,381 = 25 modules

But with conversation history (~10K tokens):
Realistically: 50,000 / 2,381 = ~21 modules per session

Practical recommendation: 4-5 modules per session
Allows room for errors, revisions, conversation
```

### Standard Modules

| Lines of Code | File Size | Tokens | Context % | Modules per Session |
|---------------|-----------|--------|-----------|---------------------|
| 300-400 | 12-16 KB | 2,857-3,810 | 1.4-1.9% | 3-4 |
| 400-500 | 16-20 KB | 3,810-4,762 | 1.9-2.4% | 2-3 |
| 500-750 | 20-30 KB | 4,762-7,143 | 2.4-3.6% | 1-2 |
| 750-1000 | 30-40 KB | 7,143-9,524 | 3.6-4.8% | 1 |

**Recommendation**: Keep modules under 300 lines (< 12 KB) for best context efficiency.

---

## Session Length Estimation

Based on context usage patterns:

### Conservative (30% target)

| Work Type | Modules | Tokens | Session Length | Notes |
|-----------|---------|--------|----------------|-------|
| New code | 3-4 | 60,000 | 2-3 hours | Includes tests |
| Refactor | 4-5 | 60,000 | 2-3 hours | Less new context |
| Documentation | 4-5 pages | 60,000 | 2-3 hours | Text content |
| Bug fixes | 5-7 | 60,000 | 2-3 hours | Small changes |

### Aggressive (35% target)

| Work Type | Modules | Tokens | Session Length | Notes |
|-----------|---------|--------|----------------|-------|
| New code | 4-5 | 70,000 | 3-4 hours | Includes tests |
| Refactor | 5-6 | 70,000 | 3-4 hours | Less new context |
| Documentation | 5-6 pages | 70,000 | 3-4 hours | Text content |
| Bug fixes | 6-8 | 70,000 | 3-4 hours | Small changes |

**Formula**:
```
session_length (hours) = (modules * 45 minutes) / 60
                       = modules * 0.75

Example: 4 modules * 0.75 = 3 hours
```

---

## Context Budget Planning

**Before starting work**, estimate context budget:

### Example: Web API Project

**Base Files** (always loaded):
- CLAUDE.md: 10 KB = 2,500 tokens (1.3%)
- AUTONOMOUS_MODE.md: 10 KB = 2,500 tokens (1.3%)
- ARCHITECTURE.md: 20 KB = 5,000 tokens (2.5%)
- master_state.json: 2 KB = 500 tokens (0.3%)
- **Subtotal**: 42 KB = 10,500 tokens (5.3%)

**Per Module** (added during work):
- Implementation: 10 KB = 2,381 tokens (1.2%)
- Tests: 6 KB = 1,429 tokens (0.7%)
- **Subtotal per module**: 16 KB = 3,810 tokens (1.9%)

**How many modules fit?**
```
Target: 35% = 70,000 tokens
Base: 10,500 tokens
Available for modules: 59,500 tokens
Per module: 3,810 tokens

Modules that fit: 59,500 / 3,810 = 15.6 modules

Conservative (with conversation): ~10-12 modules
Realistic (one session): 4-5 modules
```

**Result**: Plan for 4-5 modules per session.

---

## Cost Reduction Strategies

### Strategy 1: External Memory

**Before**:
- API reference: 100 KB = 25,000 tokens (12.5%)
- Design specs: 80 KB = 20,000 tokens (10%)
- Total: 180 KB = 45,000 tokens (22.5%)

**After** (using external memory):
- API summary: 10 KB = 2,500 tokens (1.3%)
- Design summary: 8 KB = 2,000 tokens (1.0%)
- Load specific sections on-demand: 5 KB = 1,250 tokens (0.6%)
- Total: 23 KB = 5,750 tokens (2.9%)

**Savings**: 175 KB = 39,250 tokens (19.6%)

### Strategy 2: Micro-Modules

**Before**:
- 1 large module: 1,000 lines = 40 KB = 9,524 tokens (4.8%)
- Can fit: 7 modules per session

**After**:
- 4 micro-modules: 250 lines each = 10 KB = 2,381 tokens (1.2%)
- Can fit: 25 modules per session (but realistic: 20)

**Improvement**: 3× more modules per session

### Strategy 3: Lazy Loading

**Before** (load everything at start):
- Total docs: 200 KB = 50,000 tokens (25%)
- Available for work: 20,000 tokens (10%)

**After** (load on-demand):
- Load at start: 40 KB = 10,000 tokens (5%)
- Load as needed: 10 KB per module = 2,500 tokens (1.3%)
- Available for work: 60,000 tokens (30%)

**Improvement**: 3× more work capacity

---

## Quick Reference

**Golden Rules**:
1. Keep CLAUDE.md < 10 KB (2,500 tokens, 1.3%)
2. Keep ARCHITECTURE.md < 20 KB (5,000 tokens, 2.5%)
3. Keep modules < 250 lines (10 KB, 2,381 tokens, 1.2%)
4. Target 30-35% context usage per session
5. Use external memory for references > 20 KB

**Safe Session Budget**:
- Base files: ~10,000 tokens (5%)
- Work on 4-5 modules: ~20,000 tokens (10%)
- Conversation history: ~10,000 tokens (5%)
- Buffer for errors/revisions: ~20,000 tokens (10%)
- **Total**: ~60,000 tokens (30%)

**Maximum Session Budget**:
- Base files: ~10,000 tokens (5%)
- Work on 5-6 modules: ~25,000 tokens (12.5%)
- Conversation history: ~15,000 tokens (7.5%)
- Buffer: ~20,000 tokens (10%)
- **Total**: ~70,000 tokens (35%)

---

**See Also**:
- 05_ENHANCEMENTS/context_estimation.md - Automated tracking
- 05_ENHANCEMENTS/external_memory.md - Context reduction
- 04_CORE_WORKFLOW.md - Context management workflow
