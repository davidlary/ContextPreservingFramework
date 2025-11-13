# Context-Preserving Framework - Repository

**Project Type**: Framework/Documentation Repository
**Context Management**: MANDATORY - This repository uses its own framework
**Protocol**: v4.0.1 with full enforcement

---

## 🚨 MANDATORY: Read At Session Start

**Before doing ANY work in this repository, Claude Code MUST read:**

1. **docs/core/PROTOCOL_CORE_RULES.md** (~1500 tokens, 5 min)
   - Contains all 19 enforcement rules
   - RFC 2119 MUST/SHALL keywords
   - 33-point validation checklist

2. **rules/CLAUDE.md** (enforcement rules - if it exists)
   - Detailed enforcement mechanisms
   - Tier 1 Critical rules that cannot be skipped

**Why**: This repository documents the framework. It MUST use the framework itself ("eat our own dog food"). All rules apply to work in this repository.

---

## Repository Structure

```
ContextPreservingFramework/
├── CLAUDE.md                              ← YOU ARE HERE
├── PROTOCOL_CORE_RULES.md                 ← READ THIS FIRST
├── rules/CLAUDE.md                        ← READ THIS SECOND
├── README.md                              ← User-facing documentation
├── guides/                                ← 14 comprehensive guides
│   ├── 02_SETUP_GUIDE.md                 ← Full setup instructions
│   ├── 03_TEMPLATES/                     ← Templates for user projects
│   ├── 04_CORE_WORKFLOW.md               ← Daily workflow
│   └── ... (10 more guides)
├── data/state/                            ← State tracking (THIS repo)
├── logs/                                  ← Operation logs (THIS repo)
└── .claude/                               ← Framework metadata
```

---

## Critical Files for THIS Repository

**State Tracking**:
- `data/state/master_state.json` - Current state of framework repository
- `data/state/context_tracking.json` - Context usage tracking
- `logs/operation_log.txt` - All operations logged

**Enforcement**:
- `rules/CLAUDE.md` - Full enforcement rules (MUST follow)
- `PROTOCOL_CORE_RULES.md` - Compressed rules reference

---

## MANDATORY Rules for THIS Repository

### RULE 14: State Tracking (MUST - Tier 1)
After EVERY Read, Write, Edit, Bash operation, Claude **MUST**:
1. Log to `logs/operation_log.txt`
2. Update `data/state/master_state.json`
3. Update `data/state/context_tracking.json`
4. Check context threshold

### RULE 15: Visible Tracking (MUST - Tier 1)
BEFORE completing ANY response, display checkpoint box:
```
═══════════════════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC - RULES 14-17)
═══════════════════════════════════════════════════════════════════════
✅ Operation logged: [type] → logs/operation_log.txt
✅ State updated: data/state/master_state.json (timestamp: HH:MM:SS)
✅ Context tracked: [N]K tokens ([X.X]%)
✅ Threshold check: [SAFE/WARNING/CRITICAL]
✅ Git status: [Last commit hash]
═══════════════════════════════════════════════════════════════════════
```

### RULE 17: Next Steps (MUST - Tier 1)
At END of EVERY response, display next steps block (see PROTOCOL_CORE_RULES.md section 17)

### RULE 18: Testing (MUST - Tier 1)
- Any code changes: Write tests, >80% coverage, 100% passing
- Before checkpoint: Verify all tests pass

### RULE 19: Documentation (MUST - Tier 2)
- Update README.md if user-facing changes
- Update relevant guides if framework changes
- Update CHANGELOG.md for all changes

---

## Commands

**Check state**: `cat data/state/master_state.json | jq .`
**Check context**: `cat data/state/context_tracking.json | jq .`
**View log**: `tail -20 logs/operation_log.txt`
**Run validation**: `bash scripts/validate_framework.sh` (if exists)

---

## Context Threshold for THIS Repository

**Default**: 65% primary, 75% emergency (research-based v4.0.1)
**Why**: Framework repository is documentation-heavy, not code-heavy
**Override**: Can be changed in `data/state/context_tracking.json`

---

## Current Work Instructions

**When working on framework repository:**

1. ✅ Read PROTOCOL_CORE_RULES.md first
2. ✅ Read rules/CLAUDE.md second
3. ✅ Check current state in data/state/master_state.json
4. ✅ Follow all 19 rules (MUST/SHALL keywords binding)
5. ✅ Display checkpoint box after every operation
6. ✅ Display next steps at end of response
7. ✅ Update state files after every operation
8. ✅ Commit with proper format (see RULE 16)

---

## CRITICAL: This Repository MUST Use Its Own Framework

**Purpose**: "Eat our own dog food" - the framework repository must follow its own rules.

**Why Critical**:
- Demonstrates framework works
- Validates enforcement mechanisms
- Proves rules are followable
- Shows users how it looks in practice

**Enforcement**: ALL 19 rules apply. No exceptions.

---

**Last Updated**: 2025-01-12
**Framework Version**: v4.0.1
**Enforcement**: MANDATORY - All rules binding with MUST/SHALL keywords
