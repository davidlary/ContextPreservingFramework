# Git Commit Templates

**Standard commit message formats for Context-Preserving Framework**

---

## Template Format

All commits should follow this structure for consistency and traceability:

```
[Session X] Brief Description - STATUS

Detailed changes section

Metadata section

Generated attribution
```

---

## Module Completion Commit

**Use when**: Completing a module with passing tests

### Template

```
[Session {N}] Module {X.Y}: {Module Name} - COMPLETE

Changes:
- Files created: {list}
- Files modified: {list}
- Tests: {passing}/{total} passing
- Validation: {validation_notes}

Duration: {minutes} minutes
Next: {next_module_or_task}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 1] Module 1.2: Authentication System - COMPLETE

Changes:
- Files created: src/auth/authenticator.py, src/auth/jwt_handler.py, tests/test_auth.py
- Files modified: src/config.py
- Tests: 12/12 passing
- Validation: JWT tokens working, password hashing secure

Duration: 75 minutes
Next: Module 1.3 (Task CRUD operations)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Module In-Progress Checkpoint

**Use when**: Saving progress mid-module (context approaching limit or natural breakpoint)

### Template

```
[Session {N}] Module {X.Y}: {Module Name} - IN PROGRESS

Progress:
- Completed: {what's done}
- Remaining: {what's left}
- Tests: {passing}/{total} (in progress)

Context: {percentage}%
Next session: {specific next steps}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 2] Module 1.4: API Routes - IN PROGRESS

Progress:
- Completed: Auth routes, user registration endpoint
- Remaining: Task endpoints (GET, POST, PUT, DELETE)
- Tests: 6/12 (6 passing for completed routes)

Context: 33%
Next session: Implement task CRUD endpoints, complete tests

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Session End Checkpoint

**Use when**: Ending session with all work complete

### Template

```
[Session {N}] Session complete - {modules} modules done

Modules completed:
- Module {X.Y}: {Name} ({status})
- Module {X.Z}: {Name} ({status})

Session metrics:
- Duration: {hours} hours
- Tests: {passing}/{total} passing
- Context used: {percentage}%
- Commits: {count}

Next session: {next_tasks}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 1] Session complete - 3 modules done

Modules completed:
- Module 1.1: Database & Models (complete)
- Module 1.2: Authentication (complete)
- Module 1.3: Task CRUD (complete)

Session metrics:
- Duration: 3.5 hours
- Tests: 36/36 passing
- Context used: 32%
- Commits: 4

Next session: Modules 1.4-1.6 (API routes, validation, integration tests)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Bug Fix Commit

**Use when**: Fixing bugs found during testing or review

### Template

```
[Session {N}] Fix: {bug description} - FIXED

Issue:
- {description of bug}
- {where it occurred}
- {impact}

Solution:
- {what was changed}
- {why this fixes it}

Tests: {passing}/{total} passing

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 2] Fix: JWT token expiration not validated - FIXED

Issue:
- Expired JWT tokens still accepted by API
- No validation of exp claim in jwt_handler.py
- Security vulnerability allowing stale tokens

Solution:
- Added expiration check in validate_token()
- Raise TokenExpiredError if exp < current time
- Updated tests to verify expiration handling

Tests: 38/38 passing (added 2 tests for expiration)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Refactor Commit

**Use when**: Refactoring code without changing functionality

### Template

```
[Session {N}] Refactor: {what was refactored} - COMPLETE

Changes:
- {description of refactoring}
- {why it was needed}
- {improvements gained}

Impact:
- Functionality: unchanged
- Tests: {passing}/{total} passing (same as before)
- Code quality: {improvements}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 3] Refactor: Extract database connection to separate module - COMPLETE

Changes:
- Moved database connection logic from multiple files to core/database.py
- Created DatabaseConnection singleton class
- Updated all modules to use shared connection

Impact:
- Functionality: unchanged
- Tests: 42/42 passing (same as before)
- Code quality: eliminated duplicate code, easier to configure, single source of truth

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Documentation Update

**Use when**: Updating documentation (should be in same commit as code when possible)

### Template

```
[Session {N}] Docs: {what was documented} - UPDATED

Documentation changes:
- {files updated}
- {what was added/changed}
- {why}

Code changes (if any):
- {related code changes}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 2] Docs: Add API authentication documentation - UPDATED

Documentation changes:
- docs/api/authentication.md: Complete authentication guide
- README.md: Added authentication section
- examples/auth_example.py: Sample authentication code

Code changes (if any):
- None (documentation only)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Initial Setup Commit

**Use when**: First commit of project setup

### Template

```
[Session 1] Initial project setup - {project_name}

Framework setup:
- Context-Preserving Framework v3.0
- {language} project
- {framework/tools}

Files created:
- Project structure
- Configuration files
- Framework files (CLAUDE.md, AUTONOMOUS_MODE.md, etc.)

Next: {first actual work}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 1] Initial project setup - task_api

Framework setup:
- Context-Preserving Framework v3.0
- Python 3.11+ with FastAPI
- PostgreSQL, SQLAlchemy, pytest

Files created:
- Project structure (src/, tests/, docs/, data/)
- Configuration: pyproject.toml, .gitignore, requirements.txt
- Framework files: CLAUDE.md, AUTONOMOUS_MODE.md, ARCHITECTURE.md
- State tracking: data/state/master_state.json

Next: Module 1.1 (Database connection & models)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Writing Project Commit (Section Complete)

**Use when**: Completing a section in a writing project

### Template

```
[Session {N}] Section {X}: {Section Name} - COMPLETE

Content:
- Word count: {count} words (target: {target})
- Subsections: {list}
- References: {count} citations

Quality:
- {quality metrics}

Next: {next section}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 2] Section 3: Methods - COMPLETE

Content:
- Word count: 2008 words (target: 2000)
- Subsections: Data Collection, Analysis Methods, Validation
- References: 6 citations (3 methodology papers, 3 dataset references)

Quality:
- Draft complete, ready for review
- All citations valid
- Figures created: 1 (methodology flowchart)

Next: Section 4 (Results)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Emergency Checkpoint

**Use when**: Need to checkpoint immediately due to unexpected context exhaustion or error

### Template

```
[Session {N}] EMERGENCY CHECKPOINT - {reason}

Status:
- Current work: {what was being done}
- Completion: {percentage or description}
- Tests: {status}

Reason: {why emergency checkpoint}

URGENT - Resume immediately with:
{specific recovery instructions}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 2] EMERGENCY CHECKPOINT - context critical 90%

Status:
- Current work: Module 1.5 validation functions
- Completion: 60% (3 of 5 functions done)
- Tests: 18/24 passing (6 tests for incomplete functions)

Reason: Context reached 90% unexpectedly due to large error messages

URGENT - Resume immediately with:
1. Read src/validation.py lines 45-120 (work in progress)
2. Complete remaining 2 functions: validate_date_range(), validate_format()
3. Write 6 remaining tests
4. Verify all 24 tests passing

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Framework Update Commit

**Use when**: Updating framework files themselves

### Template

```
[Session {N}] Framework: {what was updated} - UPDATED

Framework changes:
- {files updated}
- {changes made}
- {reason}

Impact:
- {how this affects workflow}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```bash
git commit -m "$(cat <<'EOF'
[Session 3] Framework: Add context estimation script - UPDATED

Framework changes:
- scripts/estimate_context.py: New context estimation tool
- CLAUDE.md: Added context checking after each operation
- AUTONOMOUS_MODE.md: Updated to include context monitoring

Impact:
- Real-time context awareness
- Prevents unexpected context exhaustion
- Better session planning

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Commit Best Practices

### DO:
- ✅ Use HEREDOC format for multi-line messages
- ✅ Include session number for traceability
- ✅ List specific file changes
- ✅ Include test status
- ✅ Add "Next steps" for continuity
- ✅ Use present tense ("Add" not "Added")
- ✅ Add Claude attribution footer
- ✅ Commit frequently (every module, before 35% context)

### DON'T:
- ❌ Use vague messages ("Update files", "Fix stuff")
- ❌ Skip test status
- ❌ Forget session number
- ❌ Commit without running tests
- ❌ Batch multiple modules in one commit (exception: session end)
- ❌ Skip the "Next" section
- ❌ Use emoji excessively (only 🤖 at the end)

---

## Commit Frequency

| Event | Frequency | Template |
|-------|-----------|----------|
| Module complete | Every module | Module Completion |
| Mid-module checkpoint | When context > 30% | Module In-Progress |
| Session end | Every session | Session End |
| Bug fix | Each bug | Bug Fix |
| Refactor | Each refactor | Refactor |
| Documentation | With code or separately | Documentation |
| Emergency | Immediately | Emergency Checkpoint |

**Minimum**: Commit every 30 minutes or 5 significant operations, whichever comes first.

---

## Shell Helper Functions

Add to your shell profile for easy commits:

```bash
# ~/.bashrc or ~/.zshrc

# Module complete commit
mcommit() {
    local session=$1
    local module=$2
    local name=$3
    local files=$4
    local tests=$5
    local next=$6

    git commit -m "$(cat <<EOF
[Session ${session}] Module ${module}: ${name} - COMPLETE

Changes:
- Files: ${files}
- Tests: ${tests}

Next: ${next}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
}

# Session checkpoint commit
scommit() {
    local session=$1
    local modules=$2
    local metrics=$3
    local next=$4

    git commit -m "$(cat <<EOF
[Session ${session}] Session complete - ${modules} modules

${metrics}

Next session: ${next}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
}
```

---

## Git Tag Format

**For version releases**:

```bash
git tag -a v1.0.0 -m "Release v1.0.0 - {description}

Features:
- {feature 1}
- {feature 2}

Modules: {count} complete
Tests: {count} passing
Coverage: {percentage}%

Framework: Context-Preserving v3.0
"
```

---

**See Also**:
- 04_CORE_WORKFLOW.md - When to commit
- AUTONOMOUS_MODE.md template - Git permissions
- rules_CLAUDE.md template - Commit rules (RULE 16)
