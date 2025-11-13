# Rule Priorities and Conflict Resolution

**Version**: 1.0.0
**Date**: 2025-01-12
**Purpose**: Resolve all rule conflicts with clear priorities and decision rules
**Status**: CANONICAL - This document resolves all ambiguities

---

## 🎯 PURPOSE

When multiple rules conflict, this document provides **deterministic resolution** so Claude Code always knows which rule takes priority.

**User's Requirement**: "Make sure that all rules are self-consistent"

**Solution**: Define explicit priority tiers and conflict resolution algorithms.

---

## 📊 RULE HIERARCHY (3 TIERS)

### TIER 1: CRITICAL (NEVER VIOLATE - THESE OVERRIDE ALL OTHERS)

**These rules are safety-critical and ALWAYS win conflicts:**

- **RULE 10**: Context Management (never exceed 65% primary, 75% emergency)
- **RULE 14**: State Tracking (update after EVERY operation)
- **RULE 15**: Visible Checkpoint (display checkpoint box)
- **RULE 16**: Git Commit Protocol (commit before checkpoint)
- **RULE 17**: Next Steps (display at end of response)

**Why Tier 1?**: Prevent context loss, data loss, and session continuity breaks

---

### TIER 2: IMPORTANT (FOLLOW UNLESS OVERRIDDEN BY TIER 1)

**These rules are important but yield to Tier 1 in conflicts:**

- **RULE 1**: Zero hard-coding
- **RULE 2**: Named files only
- **RULE 3**: Zero silent failures
- **RULE 4**: Autonomous issue resolution
- **RULE 5**: Documentation synchronization
- **RULE 6**: Strategy vs status separation
- **RULE 7**: Validation gates
- **RULE 8**: Performance optimization
- **RULE 9**: Code reuse mandatory
- **RULE 18**: Mandatory testing (>80% coverage, 100% passing)
- **RULE 19**: Auto-documentation (README, API, ARCHITECTURE, CHANGELOG)
- **RULE 20**: Verifiable claims (provide proof/verification with claims) ⭐ NEW

**Why Tier 2?**: Essential for quality but can be deferred if context exhausted

---

### TIER 3: OPTIMIZATION (FOLLOW WHEN POSSIBLE, LOWEST PRIORITY)

**These rules are optimizations:**

- **RULE 11**: Autonomous execution mode
- **RULE 12**: Preserve core requirements
- **RULE 13**: Real data only (no placeholders)

**Why Tier 3?**: Nice-to-have improvements, not safety-critical

---

## ⚖️ CONFLICT RESOLUTION ALGORITHM

### Decision Tree

```
When rules conflict:
├─ ANY Tier 1 rule involved?
│  ├─ YES → Tier 1 rule ALWAYS wins
│  └─ NO → Continue
├─ ANY Tier 2 rule involved?
│  ├─ YES → Tier 2 rule wins over Tier 3
│  └─ NO → All Tier 3, follow first mentioned
```

### Pseudocode

```python
def resolve_conflict(rules_in_conflict):
    tier1_rules = [r for r in rules_in_conflict if r.tier == 1]
    tier2_rules = [r for r in rules_in_conflict if r.tier == 2]
    tier3_rules = [r for r in rules_in_conflict if r.tier == 3]

    if tier1_rules:
        return tier1_rules[0]  # Tier 1 always wins
    elif tier2_rules:
        return tier2_rules[0]  # Tier 2 wins over Tier 3
    else:
        return tier3_rules[0]  # All Tier 3, follow first
```

---

## 🔥 COMMON CONFLICTS AND RESOLUTIONS

### Conflict 1: Documentation Files (RULE 2 vs RULE 19)

**Scenario**:
- RULE 2: "Only create files specified in architecture"
- RULE 19: "MUST update README.md, API.md, ARCHITECTURE.md, CHANGELOG.md"
- Problem: What if ARCHITECTURE.md doesn't exist?

**Resolution**:
```yaml
Priority: RULE 19 (Tier 2) wins over RULE 2 (Tier 2) for DOCUMENTATION files only
Decision:
  - Documentation files (README, API, ARCHITECTURE, CHANGELOG) are ALWAYS allowed
  - Code files (.py, .js, .go, .rs) MUST be in manifest or approved
  - Test files matching patterns (test_*.py, *.test.js) are ALWAYS allowed
```

**Implementation**:
- `file_manifest.json` has `always_allowed_patterns` for docs
- RULE 2 validation skips documentation files
- RULE 19 can create docs without asking

**Example**:
```
User: "Add authentication module"
Claude needs to:
  ✅ Create ARCHITECTURE.md (documentation - always allowed)
  ❌ Create auth_new.py (code - needs manifest approval)
  ✅ Update existing auth.py (update existing - preferred)
```

---

### Conflict 2: Context Threshold (RULE 10 v4.0.1 vs Backward Compatibility)

**Scenario**:
- RULE 10 (v4.0.1): "65% primary, 75% emergency (research-based)"
- Backward Compatibility: "Check for existing projects with 35% threshold"
- Problem: Which threshold applies?

**Resolution**:
```yaml
Priority: Explicit user configuration ALWAYS wins
Decision Tree:
  1. Check for explicit config (config/context_config.json or master_state.json)
     - If found: Use configured threshold
     - If not found: Continue
  2. Check for existing project indicators
     - If .claude/ exists with created_before < 2025-01-12: Use 35% (v3.x)
     - If git commits dated before 2025-01-12: Use 35% (v3.x)
     - If not found: Continue
  3. Default for new projects
     - Use 65% primary, 75% emergency (research-based v4.0.1)
```

**Implementation**:
- Check sequence: explicit config → project age detection → default
- Never force new thresholds on existing projects
- Document clearly in CLAUDE.md which threshold applies

**Example**:
```json
// config/context_config.json (if user wants 35%)
{
  "threshold_critical": 35,
  "threshold_emergency": 40,
  "note": "Conservative 35% for this project"
}
```

---

### Conflict 3: Testing Documentation (RULE 18 vs RULE 19)

**Scenario**:
- RULE 18: "Every module MUST have tests >80% coverage"
- RULE 19: "Update documentation (which is also a 'module')"
- Problem: Do documentation updates need tests?

**Resolution**:
```yaml
Priority: Clarify scope
Decision:
  - RULE 18 applies to CODE modules only (*.py, *.js, *.go, *.rs)
  - RULE 19 applies to DOCUMENTATION files only (*.md)
  - They don't conflict because they target different file types
```

**Definition**:
```python
is_code_module = lambda file: file.endswith(('.py', '.js', '.ts', '.go', '.rs', '.java', '.cpp'))
is_documentation = lambda file: file.endswith('.md') or file.startswith('docs/')

if is_code_module(file):
    apply_rule_18_testing()
if is_documentation(file):
    apply_rule_19_documentation()
```

---

### Conflict 4: Git Commit Timing (RULE 16 vs RULE 10)

**Scenario**:
- RULE 16: "Commit after module complete, before context reaches 35%"
- RULE 10: "Checkpoint at 65%"
- Problem: Which threshold triggers commit?

**Resolution**:
```yaml
Priority: RULE 10 (Tier 1) wins
Decision:
  - Commit triggers:
    1. Module/task complete (RULE 16 primary)
    2. Context reaches configured threshold (RULE 10 override)
    3. Every 5 significant operations (RULE 16 minimum)
  - Use threshold from RULE 10 (65% for v4.0.1, or user-configured)
  - Ignore "35%" mention in RULE 16 (outdated from v3.x)
```

**Clarification**:
- RULE 16 should be updated to say "before context reaches RULE 10 threshold"
- Don't hard-code 35% in RULE 16 text
- Reference RULE 10 for threshold value

---

### Conflict 5: Retry vs Context Limit (RULE 4 vs RULE 10)

**Scenario**:
- RULE 4: "Retry max 3 times with exponential backoff"
- RULE 10: "Exit at configured threshold (65% or user-configured)"
- Problem: What if 2nd retry would push context to 67%?

**Resolution**:
```yaml
Priority: RULE 10 (Tier 1) ALWAYS wins
Decision:
  - If retry would exceed context threshold: DON'T retry
  - Instead: Checkpoint immediately with "retry_pending" status
  - Next session: Resume retries
```

**Example**:
```
Attempt 1: Fails, context 58%
Attempt 2: Fails, context 62%
Check: Attempt 3 would push to 67% (exceeds 65%)
Action: Checkpoint now with status "retry_pending: attempt 2 of 3"
Next session: Resume with attempt 3
```

---

### Conflict 6: Validation vs Context Limit (RULE 7 vs RULE 10)

**Scenario**:
- RULE 7: "Validation must pass before proceeding"
- RULE 10: "Exit at configured threshold"
- Problem: Validation fails, debugging would push to 70%

**Resolution**:
```yaml
Priority: RULE 10 (Tier 1) wins
Decision:
  - If debugging would exceed threshold: DON'T debug
  - Instead: Checkpoint with "validation_failed" status
  - Document failure in state
  - Next session: Debug from clean context
```

**Example**:
```
Validation: Tests failing, context 63%
Debug estimate: Would push to 70% (exceeds 65%)
Action: Checkpoint with status "validation_failed: tests/test_auth.py line 45"
Next session: Resume debugging with full context available
```

---

### Conflict 7: Documentation Completeness vs Context (RULE 19 vs RULE 10)

**Scenario**:
- RULE 19: "MUST update README, API, ARCHITECTURE, CHANGELOG"
- RULE 10: "Exit at 65%"
- Problem: Context at 64%, 3 of 4 docs updated

**Resolution**:
```yaml
Priority: RULE 10 (Tier 1) wins at 65%+
Decision:
  - If context < 60%: Complete all documentation (RULE 19)
  - If context 60-65%: Complete critical docs (README, CHANGELOG)
  - If context ≥ 65%: Checkpoint immediately, document in TODO
  - Next session: Complete remaining docs first
```

**Priority Order for Docs** (when context limited):
1. CHANGELOG.md (highest - tracks what changed)
2. README.md (high - user-facing)
3. API.md (medium - if API changed)
4. ARCHITECTURE.md (lower - if new components)

---

## 📋 QUICK REFERENCE TABLES

### Rule Priority Quick Lookup

| Rule # | Name | Tier | Wins Against | Loses Against |
|--------|------|------|--------------|---------------|
| 10 | Context Management | 1 | ALL | NONE |
| 14 | State Tracking | 1 | 2-19 | 10 (can defer update if context critical) |
| 15 | Visible Checkpoint | 1 | 2-19 | 10, 14 |
| 16 | Git Commit | 1 | 2-19 | 10, 14, 15 |
| 17 | Next Steps | 1 | 2-19 | 10, 14, 15, 16 |
| 1 | Zero Hard-Coding | 2 | 11-13 | 10, 14-17 |
| 2 | Named Files Only | 2 | 11-13 | 10, 14-17, 19 (docs) |
| 18 | Testing | 2 | 11-13 | 10, 14-17 |
| 19 | Documentation | 2 | 2 (docs only), 11-13 | 10, 14-17 |
| 11-13 | Optimization | 3 | NONE | ALL |

---

### Conflict Decision Matrix

| If Rule X conflicts with Rule Y | Winner | Reason |
|----------------------------------|--------|--------|
| Tier 1 vs Tier 2 | Tier 1 | Safety critical |
| Tier 1 vs Tier 3 | Tier 1 | Safety critical |
| Tier 2 vs Tier 3 | Tier 2 | Quality > optimization |
| Same Tier | First mentioned or context-specific | Use resolution guide |
| RULE 10 vs ANY | RULE 10 | Context safety paramount |
| RULE 2 vs RULE 19 (docs) | RULE 19 | Docs always allowed |
| RULE 2 vs RULE 19 (code) | RULE 2 | Code needs manifest |

---

## 🧪 VALIDATION: How to Verify Resolution

### Test Conflict Resolution

```bash
# Test 1: Context threshold conflict
# Set context to 64%, trigger retry
# Expected: Checkpoint instead of retry

# Test 2: Documentation file creation
# Try to create ARCHITECTURE.md without manifest
# Expected: Success (docs always allowed)

# Test 3: Code file creation
# Try to create new_feature.py without manifest
# Expected: Violation detected by RULE 2 validation

# Test 4: Context + Testing conflict
# Context 66%, tests failing
# Expected: Checkpoint with "tests_failing" status
```

---

## 📝 IMPLEMENTATION CHECKLIST

For Claude Code to correctly resolve conflicts:

- [ ] Read this document at session start (if conflicts arise)
- [ ] Check rule tier before making decisions
- [ ] Apply conflict resolution algorithm
- [ ] Document resolution in logs ("RULE X overrode RULE Y due to tier")
- [ ] Never violate Tier 1 rules (safety-critical)
- [ ] Defer Tier 2 rules if Tier 1 requires (but document)
- [ ] Skip Tier 3 rules if resource-constrained

---

## 🔄 UPDATE POLICY

**When adding new rules**:
1. Assign tier based on impact (safety = Tier 1, quality = Tier 2, optimization = Tier 3)
2. Check for conflicts with existing rules
3. Add conflict resolution to this document
4. Update conflict decision matrix

**When conflicts found**:
1. Document in CRITICAL_GAPS_ANALYSIS.md
2. Add resolution to this document
3. Update relevant RULE descriptions
4. Test resolution with validation

---

## ✅ SELF-CONSISTENCY VERIFICATION

**This document resolves all conflicts identified in CRITICAL_GAPS_ANALYSIS.md**:

- ✅ Conflict 1 (RULE 2 vs 19 docs): RESOLVED - Docs always allowed
- ✅ Conflict 2 (Context thresholds): RESOLVED - Detection order defined
- ✅ Conflict 3 (Git commit timing): RESOLVED - Use RULE 10 threshold
- ✅ Conflict 4 (Testing docs): RESOLVED - Scope clarified (code only)
- ✅ Conflict 5 (Retry vs context): RESOLVED - RULE 10 wins
- ✅ Conflict 6 (Validation vs context): RESOLVED - RULE 10 wins
- ✅ Conflict 7 (Docs vs context): RESOLVED - Priority order defined

**Result**: Framework is now self-consistent at all levels.

---

**Last Updated**: 2025-01-12
**Status**: CANONICAL - All conflicts resolved deterministically
**Next Review**: When new rules added or conflicts discovered
