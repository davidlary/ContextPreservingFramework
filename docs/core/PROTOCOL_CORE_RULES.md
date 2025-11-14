# Protocol Core Rules (Compressed Quick Reference)

**Version**: 4.7.0
**Purpose**: Compressed quick reference of all 22 enforcement rules
**Token Cost**: ~1500 tokens (0.75% of context)
**Application**: Quick start path - for experienced users or rapid refresh
**Full Details**: See [rules/CLAUDE.md](../../rules/CLAUDE.md) for complete 22-rule specification and `guides/` directory for comprehensive setup
**Enforcement**: ALL 22 rules enforced (100%) via 27 hooks - see [v4.7.0 Release Notes](../releases/FRAMEWORK_V4.7.0_RELEASE_NOTES.md)
**New in v4.7.0**: RULE 22 (Advanced Context Compression) enables 50-80% token reduction - see [Context Compression Guide](../../guides/11_CONTEXT_COMPRESSION.md)
**Note**: RULE 21 reserved (superseded by RULE 22) - see [rules/CLAUDE.md § RULE 21](../../rules/CLAUDE.md#rule-21-reserved---superseded-by-rule-22)

---

## 📍 SCOPE: Where Does This Apply?

**This protocol applies PER-PROJECT:**
- ✅ Applies to **projects with `CLAUDE.md` or `rules/CLAUDE.md`** in root
- ✅ Applies to **large projects Claude auto-detects** (>1000 lines, >3 components, >2 hours)
- ❌ Does **NOT** apply system-wide to all Claude Code sessions
- ❌ Does **NOT** apply to small projects (<1000 lines)

**Using this in YOUR project?** See [README.md § Using This Framework In Your Project](../README.md#-using-this-framework-in-your-project) for setup instructions.

**Want technical enforcement?** See [README.md § Option 4: Activate Technical Enforcement](../README.md#option-4-activate-technical-enforcement-recommended) to enable automated validation hooks.

---

## 🚨 SESSION START INSTRUCTION (READ THIS FIRST)

**When Claude Code starts a session in ANY project using this framework:**

1. **MUST** check for `CLAUDE.md` in project root
2. **MUST** check for `rules/CLAUDE.md`
3. If either exists: **MUST** read them before doing any work
4. **MUST** check for `data/state/master_state.json` and load state
5. **MUST** follow all 22 rules (see [rules/CLAUDE.md](../../rules/CLAUDE.md)) with RFC 2119 enforcement (MUST/SHALL/SHOULD/MAY)

**This applies to:**
- User projects that set up the framework
- **THIS framework repository itself** (we eat our own dog food)

**If no framework files exist**: Work normally, protocol not activated.

---

## CRITICAL: RFC 2119 Keywords

- **MUST** / **SHALL** / **REQUIRED**: Absolute requirement
- **MUST NOT** / **SHALL NOT**: Absolute prohibition
- **SHOULD** / **RECOMMENDED**: Strong recommendation (follow unless good reason)
- **MAY** / **OPTIONAL**: Truly optional

---

## 1. DETECTION (MUST)

Claude **MUST** activate protocol when:
- Estimated >1000 lines of code, OR
- >3 interconnected components, OR
- Task >2 hours estimated, OR
- User says "large", "complex", "full system"

**Validation**: If any trigger met → protocol MUST activate

---

## 2. INITIALIZATION (MUST)

When activated, Claude **MUST**:
1. Create `.claude/` directory (hidden state)
2. Generate hierarchical plan (HTDAG with dependencies)
3. Initialize `plan.json` and `state.json`
4. Begin Module 1.1 execution
5. **MUST NOT** describe framework to user (transparent operation)

**Validation**: `.claude/plan.json` MUST exist before starting Module 1.1

---

## 3. HIERARCHICAL PLANNING (MUST)

Claude **MUST**:
1. Decompose request into components (Level 1)
2. Break components into subsystems (Level 2)
3. Create 200-300 line modules (Level 3)
4. Generate dependency graph
5. Determine topological execution order

**Validation**: `plan.json` MUST contain:
- All modules (with estimated lines/tokens)
- Dependencies array
- Execution order

---

## 4. MODULE IMPLEMENTATION (MUST)

For EACH module, Claude **MUST**:

### 4.1 Write Implementation
- Write code (target 200-300 lines)
- Add inline comments (explain complex logic)
- Follow project patterns (check existing code style)

### 4.2 Write Tests (MANDATORY)
- **MUST** write tests for every module
- **MUST** achieve >80% line coverage
- Tests **MUST** be in `tests/` directory
- Test file **MUST** follow naming: `test_<module>.py` or `<module>.test.js`

### 4.3 Run Tests (MANDATORY)
- **MUST** run all tests: `pytest tests/` or `npm test`
- **MUST** verify 100% passing
- **MUST NOT** checkpoint if any test fails

### 4.4 Debug Failures (MANDATORY)
- If tests fail: **MUST** debug until passing
- **MUST NOT** skip tests
- **MUST NOT** comment out failing tests
- **MUST** fix root cause, not symptoms

### 4.5 Auto-Documentation (MANDATORY)
- **MUST** generate docstrings/JSDoc for all public functions
- **MUST** update API docs if module exposes API
- **MUST** update README.md if module changes user-facing behavior
- **MUST** create/update ARCHITECTURE.md for new components

**Validation Checklist (MUST pass before checkpoint)**:
```
✓ Code written and committed
✓ Tests written (>80% coverage)
✓ All tests passing (100%)
✓ Docstrings/JSDoc added
✓ Documentation updated
✓ Git committed
```

---

## 5. CONTEXT MANAGEMENT (MUST)

### 5.1 Monitoring (MUST)
Claude **MUST** track context after EVERY operation:
- Estimate tokens: conversation + files read + code written + tool outputs
- Calculate percentage: `(tokens / 200000) * 100`
- Check against thresholds

### 5.2 Thresholds (MUST)
- 0-50%: Continue normally
- 50-65%: Prepare for checkpoint, monitor every 5K tokens
- **65%**: **MUST** trigger normal checkpoint
- **75%**: **MUST** trigger emergency checkpoint
- **MUST NOT** exceed 75%

### 5.3 Checkpoint Actions (MUST)
At checkpoint (65% or module complete), Claude **MUST**:
1. **Finish current sub-task** (don't stop mid-function)
2. **Verify all tests passing** (if not, debug first)
3. **Save state atomically** (atomic write to `.claude/state.json`)
4. **Summarize completed modules** (compress 45K → 2K tokens)
5. **Git commit** with format: `[Module X.Y] Description (checkpoint N)`
6. **Create checkpoint file** (`.claude/checkpoints/checkpoint_NNN.json`)
7. **Notify user** (brief): "Checkpoint (65%). Module X.Y complete. Ready for X.{Y+1}."

**Validation**: Checkpoint **MUST NOT** proceed if:
- Tests failing
- Git uncommitted changes
- State file invalid JSON

### 5.4 Context Compression (SHOULD - v4.7.0+)
**RULE 22** provides advanced compression techniques to reduce context usage:
- **JIT Loading**: Use Grep/Glob before Read (30-50% reduction)
- **Tool Filtering**: Summarize verbose outputs >1K tokens (15-25% reduction)
- **Context Editing**: Prune completed work (10-15% reduction)
- **Target**: 50-80% total reduction (validated in testing)

**When to Apply**:
- Use JIT loading for all file exploration
- Filter tool outputs exceeding 1K tokens
- Consider context editing when approaching 50% threshold

**See**: [RULE 22 in rules/CLAUDE.md](../../rules/CLAUDE.md#rule-22-advanced-context-compression-v470-addition) and [Context Compression Guide](../../guides/11_CONTEXT_COMPRESSION.md)

---

## 6. SUMMARIZATION (MUST)

For completed modules, Claude **MUST**:

### 6.1 Compress (MUST)
Before (45K tokens):
```
[Full code, comments, debug history, all details...]
```

After (2K tokens):
```
Module X.Y COMPLETE ✓
- function_name(args) -> Return type
- key_function(args) -> Return type
Files: path/to/file.py (200 lines)
Tests: 12 passed
Commit: abc123
```

### 6.2 Storage (MUST)
- **MUST** save full details to `.claude/summaries/module_X.Y.md`
- **MUST** keep only compressed version in active context
- **MUST** achieve >90% token reduction

**Validation**: Active context **MUST** contain only summaries for completed modules

---

## 7. CRASH RECOVERY (MUST)

### 7.1 Session Start (MUST)
Every session, Claude **MUST**:
1. Check for `.claude/` directory
2. If exists: Load latest checkpoint
3. Read `state.json` and summaries
4. Resume from exact position
5. **MUST NOT** mention "recovery" or "checkpoint" to user

User sees: "Resuming. Modules 1.1-1.5 complete. Continuing 1.6..."

### 7.2 Recovery Time (MUST)
- **MUST** complete recovery in <30 seconds
- **MUST** load summaries, not full module details

**Validation**: Recovery **MUST** be transparent to user

---

## 8. AUTO-DOCUMENTATION (MUST)

Claude **MUST** maintain these documents automatically:

### 8.1 README.md (MUST UPDATE)
**When**: Any module changes user-facing behavior
**Content**:
- Installation instructions (if setup changed)
- Usage examples (if API changed)
- Updated feature list (if new features added)

### 8.2 API.md (MUST UPDATE)
**When**: Any module exposes new API endpoints or public functions
**Content**:
- Endpoint/function signature
- Parameters and types
- Return values
- Example usage
- Error cases

### 8.3 ARCHITECTURE.md (MUST UPDATE)
**When**: New component or major subsystem added
**Content**:
- Component diagram (ASCII art or description)
- Dependencies between components
- Data flow
- Technology stack

### 8.4 CHANGELOG.md (MUST UPDATE)
**When**: Every module completion
**Content**:
```markdown
## [Unreleased]
### Added
- Module X.Y: Feature description

### Changed
- Modified behavior in module X.Z

### Fixed
- Bug fix in module X.W
```

### 8.5 Inline Documentation (MUST)
**When**: Every function/class written
**Content**:
```python
def authenticate(username: str, password: str) -> Token:
    """
    Authenticate user with username and password.

    Args:
        username: User's username (required)
        password: User's password in plaintext (will be hashed)

    Returns:
        Token: JWT token valid for 24 hours

    Raises:
        AuthError: If credentials invalid or user locked

    Example:
        >>> token = authenticate("alice", "secret123")
        >>> print(token.expires_at)
    """
```

**Validation**: Before checkpoint, **MUST** verify:
- README.md exists and up to date
- API.md updated if APIs added
- ARCHITECTURE.md updated if components added
- CHANGELOG.md has entry for completed module
- All functions have docstrings

---

## 9. PROGRESS REPORTING (MUST)

Claude **MUST** display progress automatically:

### 9.1 After Each Module (MUST)
```
✓ Module X.Y: Description (200 lines, 12 tests passing)
⏳ Module X.{Y+1}: Description (in progress, 40% done)
⬜ Module X.{Y+2}: Description
⬜ Module X.{Y+3}: Description

Progress: 35% | Context: 58% | Next checkpoint: Module X.{Y+1} complete
```

### 9.2 At Checkpoint (MUST)
```
Checkpoint (65% context). Module X.Y complete.
N of M modules done (P% complete).
Ready for Module X.{Y+1}: Description
```

### 9.3 Status on Request (MUST)
If user asks "status", "progress", "where are we", Claude **MUST** display:
```
Project: [Name]
Progress: N/M modules complete (P%)
Current: Module X.Y (Q% done)
Context: R%
Last checkpoint: S minutes ago
Estimated completion: T modules remaining, ~U hours
```

**Validation**: User **MUST** always know current progress without asking

---

## 10. VALIDATION CHECKLIST (MUST)

Before ANY checkpoint, Claude **MUST** verify:

### 10.1 Code Quality (MUST)
- [ ] Code follows project style guide
- [ ] No syntax errors
- [ ] No obvious bugs
- [ ] Inline comments for complex logic

### 10.2 Testing (MUST)
- [ ] Tests written (>80% coverage)
- [ ] All tests passing (100%)
- [ ] No skipped/commented tests
- [ ] Edge cases covered

### 10.3 Documentation (MUST)
- [ ] Docstrings on all public functions
- [ ] README.md updated (if user-facing changes)
- [ ] API.md updated (if API changes)
- [ ] ARCHITECTURE.md updated (if new components)
- [ ] CHANGELOG.md has entry

### 10.4 State (MUST)
- [ ] state.json updated
- [ ] plan.json updated (module marked complete)
- [ ] Summary created in .claude/summaries/
- [ ] Checkpoint file created

### 10.5 Git (MUST)
- [ ] All changes committed
- [ ] Commit message follows format
- [ ] No uncommitted files
- [ ] Branch is clean

**If ANY item fails, MUST NOT checkpoint. Debug and retry.**

---

## 11. ENFORCEMENT (MUST)

### 11.1 Self-Validation (MUST)
Before each checkpoint, Claude **MUST** run internal validation:
```
VALIDATION:
✓ Tests passing?
✓ Documentation updated?
✓ State files valid?
✓ Git committed?
✓ Context <75%?

If ANY ✗: MUST NOT checkpoint. Fix issues first.
```

### 11.2 Auto-Correction (MUST)
If validation fails, Claude **MUST**:
1. Identify specific failure
2. Display: "Validation failed: [specific issue]. Fixing..."
3. Fix the issue
4. Re-run validation
5. Only checkpoint when all ✓

### 11.3 User Override (MAY)
User MAY override validation:
```
User: "Skip tests, checkpoint now"
Claude: "⚠️ Tests not passing. Checkpoint anyway? (not recommended)"
User: "Yes"
Claude: [creates checkpoint with warning flag]
```

**But**: Claude **SHOULD** strongly discourage skipping validation

---

## 12. CONTEXT-EFFICIENT PROTOCOL APPLICATION (MUST)

### 12.1 First Session (MUST)
- **MUST** read this file (PROTOCOL_CORE_RULES.md, ~1500 tokens)
- **MUST NOT** read full CLAUDE_AUTONOMOUS_PROTOCOL.md (4-5K tokens)
- **MAY** reference full protocol for specific sections if needed

### 12.2 Subsequent Sessions (MUST)
- **MUST** only reload checkpoint files (not entire protocol)
- Context usage: ~2-3K tokens (checkpoint + summaries)
- **MUST NOT** reload protocol every session

### 12.3 Reference Full Protocol (MAY)
Claude **MAY** reference full CLAUDE_AUTONOMOUS_PROTOCOL.md if:
- Encounter edge case not covered in core rules
- Need detailed algorithm (e.g., HTDAG generation)
- User explicitly requests protocol details

**But**: Default is to use ONLY this core rules file

---

## 13. FAILURE MODES (MUST)

### 13.1 Tests Fail (MUST)
- **MUST** display: "Tests failing: [error message]"
- **MUST** debug until tests pass
- **MUST NOT** checkpoint with failing tests (unless user overrides)

### 13.2 Context Exceeds 75% (MUST)
- **MUST** immediately trigger emergency checkpoint
- **MUST** display: "⚠️ Emergency checkpoint (75% context)"
- **MUST** save state mid-task if necessary
- **MUST** force session end

### 13.3 Estimation Wrong (MUST)
If module reaches 150% of estimated lines:
- **MUST** auto-split into 2 sub-modules
- **MUST** notify user: "Module larger than expected, splitting..."
- **MUST** update plan.json

### 13.4 User Interrupts (MUST)
If user says "stop" mid-module:
- **MUST** finish current sub-task (<5 min) OR save immediately
- **MUST** create intermediate checkpoint
- **MUST** ask: "Resume later? Skip module? Different approach?"

---

## 14. SUCCESS CRITERIA (MUST ACHIEVE)

Protocol is successful if:
- ✓ Context never exceeds 75%
- ✓ All modules have tests (>80% coverage)
- ✓ All tests passing at every checkpoint
- ✓ Documentation complete and up-to-date
- ✓ Recovery time <30 seconds
- ✓ User unaware of framework mechanics
- ✓ Progress always visible

---

## 15. QUICK DECISION TREE

```
USER REQUEST
    ↓
Triggers protocol? (>1000 lines / >3 components / >2 hours)
    ├─ NO → Work normally
    └─ YES → Initialize protocol
            ↓
        Create .claude/, plan.json, state.json
            ↓
        For EACH module:
            ├─ Write code (200-300 lines)
            ├─ Write tests (>80% coverage) ← MUST
            ├─ Run tests (100% passing) ← MUST
            ├─ Fix if failing ← MUST
            ├─ Add documentation ← MUST
            ├─ Git commit ← MUST
            ├─ Check context
            │   ├─ <65%: Continue
            │   ├─ 65%: Checkpoint
            │   └─ 75%: Emergency checkpoint
            └─ Validate (all checks ✓) ← MUST
                ↓
            Checkpoint (if valid)
                ↓
            Summarize (45K→2K)
                ↓
            Next module
```

---

## 16. PROTOCOL VERSION & UPDATES

**Current Version**: 4.0.1
**Last Updated**: January 2025

**Changes from 4.0.0**:
- Added explicit MUST/SHALL rules (RFC 2119)
- Added testing enforcement (>80% coverage, 100% passing)
- Added auto-documentation requirements (README, API, ARCHITECTURE, CHANGELOG)
- Added validation checklist (10-point check before checkpoint)
- Compressed for context efficiency (1500 tokens vs 4-5K)

---

**END OF CORE RULES**

**Context Cost**: ~1500 tokens (0.75%)
**Compliance**: MANDATORY - All rules marked MUST/SHALL are non-negotiable
**Validation**: See section 10 for pre-checkpoint validation checklist
