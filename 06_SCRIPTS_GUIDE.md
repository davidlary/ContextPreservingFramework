# Scripts Guide - Implementation Instructions

**How to implement the 3 core enhancement scripts**

**Purpose**: Instructions for Claude Code to implement scripts (not actual code)
**Token cost**: ~10K tokens (5% context)
**When to read**: When ready to implement automation scripts

---

## Table of Contents

1. [Script 1: setup_framework.py](#script-1-setup_frameworkpy)
2. [Script 2: estimate_context.py](#script-2-estimate_contextpy)
3. [Script 3: validate_state.py](#script-3-validate_statepy)
4. [Integration with Framework](#integration-with-framework)

---

## Script 1: setup_framework.py

### Purpose

Automate framework setup in any project with single command.

### Inputs

**Command-line arguments**:
- `--project-name`: Project name
- `--project-type`: `coding` or `non_coding`
- `--language`: For coding (python, javascript, go, rust, etc.)
- `--domain`: For non-coding (research, book, documentation, etc.)
- `--interactive`: Prompt for details (default)

**Example usage**:
```bash
python scripts/setup_framework.py --interactive
# or
python scripts/setup_framework.py --project-name "my_api" --project-type coding --language python
```

### Algorithm

**Step 1: Detect or Prompt for Project Details**
```
IF interactive mode:
    Prompt: "Project name?"
    Prompt: "Project type? [coding/non_coding]"
    IF coding:
        Prompt: "Language? [python/javascript/go/rust/etc.]"
        Prompt: "Project kind? [web_api/cli_tool/library/etc.]"
    ELSE:
        Prompt: "Domain? [research/book/documentation/etc.]"
ELSE:
    Use command-line arguments
```

**Step 2: Create Directory Structure**
```
Create directories:
    .claude/hooks/
    rules/
    data/state/
    data/audit/
    data/scratch/
    docs/recovery_prompts/
    logs/
    config/
    schemas/
    scripts/

IF coding project:
    Create: core/ or src/
    Create: tests/
ELSE:
    Create: drafts/
    Create: sections/
    Create: references/
```

**Step 3: Generate Framework Files from Templates**
```
Load templates from: 03_TEMPLATES/

Generate CLAUDE.md:
    Replace [PROJECT_NAME] with actual name
    Replace [TEST_COMMAND] with language-appropriate command:
        - python: "pytest tests/ -v"
        - javascript: "npm test"
        - go: "go test ./..."
        - rust: "cargo test"
        - non_coding: "scripts/validate_sections.sh"
    Write to: CLAUDE.md

Generate AUTONOMOUS_MODE.md:
    Replace [PROJECT_NAME]
    Set STATUS: ACTIVE
    Set PERMISSION GRANTED: today's date
    Replace [SCOPE] with project-appropriate scope
    Write to: AUTONOMOUS_MODE.md

Generate rules/CLAUDE.md:
    IF non_coding:
        Replace "modules" with "sections"
        Replace "tests" with "validations"
        Replace "code" with "draft text"
    Write to: rules/CLAUDE.md

Copy as-is:
    .claude/README.md
    docs/recovery_prompts/SESSION_TEMPLATE.md
```

**Step 4: Generate State Files**
```
IF coding project:
    Generate master_state.json with fields:
        project, version, project_type, language,
        current_phase, current_module,
        modules_complete, modules_in_progress, modules_pending,
        tests_passing, tests_total
ELSE:
    Generate master_state.json with fields:
        project, version, project_type, domain,
        current_phase, current_section,
        sections_complete, sections_in_progress, sections_pending,
        word_count, target_word_count, references_cited

Generate context_tracking.json:
    estimated_tokens: 0
    max_tokens: 200000
    usage_pct: 0.0
    threshold_warning: 30.0
    threshold_critical: 35.0
    threshold_force_exit: 40.0
    operations_this_session: 0
```

**Step 5: Generate Documentation Skeleton**
```
IF coding project:
    Generate ARCHITECTURE.md with sections:
        - System Overview
        - Technology Stack
        - Module Breakdown (placeholder for modules 1.1, 1.2, ...)
ELSE:
    Generate STRUCTURE.md with sections:
        - Project Overview
        - Outline (placeholder for sections)
        - Timeline

Generate docs/IMPLEMENTATION_PLAN.md:
    Phase 1: Foundation (modules/sections 1.1-1.3)
    Phase 2: Core (modules/sections 2.1-2.3)
    Phase 3: Integration (modules/sections 3.1-3.2)
    [Customize based on project type]
```

**Step 6: Generate JSON Schemas**
```
Copy schemas from: 10_REFERENCE/state_schemas.md
to: schemas/

Files:
    - master_state.schema.json
    - context_tracking.schema.json
    - module_state.schema.json (or section_state.schema.json)
```

**Step 7: Create .gitignore**
```
Generate .gitignore:
    logs/*.log
    data/scratch/*
    .DS_Store
    __pycache__/ (if python)
    node_modules/ (if javascript)
    target/ (if rust)
    [language-specific patterns]
```

**Step 8: Initialize Git**
```
Execute: git init
Execute: git add .
Execute: git commit -m "Initial commit: Framework v3.0 setup

Project: [name]
Type: [coding/non_coding]
Language/Domain: [value]

Framework components installed.

🤖 Automated setup with Claude Code"
```

**Step 9: Run Validation**
```
Run validation tests 1-6 from: 07_TESTING_GUIDE.md
Report: Which tests passed/failed
IF all passed:
    Display: "✅ Framework setup complete and validated"
ELSE:
    Display: "⚠️ Setup complete but validation failed. Check:"
    List failed tests
```

### Outputs

**On success**:
```
✅ Framework Setup Complete

Created:
- Core files: CLAUDE.md, AUTONOMOUS_MODE.md, rules/CLAUDE.md
- State files: master_state.json, context_tracking.json
- Documentation: ARCHITECTURE.md, IMPLEMENTATION_PLAN.md
- Schemas: 3 JSON schema files
- Scripts: Placeholders for estimate_context.py, validate_state.py

Git: Initialized, initial commit created

Validation: 6/6 tests passed

Next steps:
1. Read: 04_CORE_WORKFLOW.md
2. Define modules in docs/IMPLEMENTATION_PLAN.md
3. Start implementation
```

**On failure**:
```
❌ Setup Failed: [error message]

Completed steps: [list]
Failed at: [step]

To fix:
[Specific instructions based on failure]

To retry: python scripts/setup_framework.py [args]
```

---

## Script 2: estimate_context.py

### Purpose

Automate context token estimation from operation log (Enhancement #7).

### Inputs

**From file**: `logs/operation_log.txt`

**Format** (one line per operation):
```
[timestamp] [operation_type] [file_path_or_details]

Examples:
2025-01-11T14:23:45 Read core/database.py
2025-01-11T14:25:12 Write core/models.py
2025-01-11T14:26:30 Bash pytest tests/test_database.py
2025-01-11T14:28:15 Edit core/database.py
```

### Algorithm

**Step 1: Parse Operation Log**
```
Read: logs/operation_log.txt
Parse each line into:
    timestamp, operation_type, target

Group operations by session (detect gaps > 30 min = new session)
```

**Step 2: Estimate Tokens Per Operation**
```
FOR each operation:
    IF operation_type == "Read":
        IF file_exists(target):
            file_content = read_file(target)
            tokens = estimate_tokens_from_text(file_content)
        ELSE:
            tokens = 0  # File no longer exists

    ELIF operation_type == "Write":
        IF file_exists(target):
            file_content = read_file(target)
            # Writing costs ~2x (read intent + write)
            tokens = estimate_tokens_from_text(file_content) * 2
        ELSE:
            tokens = 2000  # Estimate if file no longer exists

    ELIF operation_type == "Edit":
        IF file_exists(target):
            file_content = read_file(target)
            # Editing costs ~1.5x (read + modify)
            tokens = estimate_tokens_from_text(file_content) * 1.5
        ELSE:
            tokens = 1500  # Estimate

    ELIF operation_type == "Bash":
        # Bash commands vary widely, use conservative estimate
        tokens = 1000  # Average command output

    ELSE:
        tokens = 500  # Unknown operation type

    total_tokens += tokens
```

**Helper function: estimate_tokens_from_text**
```
FUNCTION estimate_tokens_from_text(text):
    # Rough estimation: ~4 characters per token
    char_count = len(text)
    token_estimate = char_count / 4

    # Adjust for code vs. prose
    IF text contains many symbols ({}[]();):
        # Code tends to be more token-dense
        token_estimate *= 1.2

    RETURN int(token_estimate)
```

**Step 3: Add Conversation Overhead**
```
# Each operation involves conversation
operations_count = count_operations_in_log()
conversation_overhead = operations_count * 500  # ~500 tokens per operation

total_tokens += conversation_overhead
```

**Step 4: Calculate Percentages**
```
max_tokens = 200000
usage_pct = (total_tokens / max_tokens) * 100

# Determine status
IF usage_pct < 30:
    status = "SAFE"
ELIF usage_pct < 35:
    status = "WARNING"
ELIF usage_pct < 40:
    status = "CRITICAL"
ELSE:
    status = "EMERGENCY"
```

**Step 5: Update Context Tracking File**
```
Write to: data/state/context_tracking.json
{
    "estimated_tokens": total_tokens,
    "max_tokens": 200000,
    "usage_pct": usage_pct,
    "threshold_warning": 30.0,
    "threshold_critical": 35.0,
    "threshold_force_exit": 40.0,
    "operations_this_session": operations_count,
    "last_update": current_timestamp,
    "status": status,
    "breakdown": {
        "read_operations": read_tokens,
        "write_operations": write_tokens,
        "edit_operations": edit_tokens,
        "bash_operations": bash_tokens,
        "conversation_overhead": conversation_overhead
    }
}
```

**Step 6: Display Results** (optional, for manual runs)
```
IF run manually (not automatic):
    Print:
    "Context Estimation
    ==================
    Total tokens: [N] ([X.X]%)
    Status: [SAFE/WARNING/CRITICAL/EMERGENCY]

    Breakdown:
    - Read: [N] tokens ([X]%)
    - Write: [N] tokens ([X]%)
    - Edit: [N] tokens ([X]%)
    - Bash: [N] tokens ([X]%)
    - Conversation: [N] tokens ([X]%)

    Operations: [N]
    Threshold: Next warning at [30/35/40]%"
```

### Outputs

**File**: `data/state/context_tracking.json` (updated)

**Return code**:
- 0: Success, context safe (< 30%)
- 1: Warning (30-35%)
- 2: Critical (35-40%)
- 3: Emergency (> 40%)

**Integration**: Called automatically after every operation (via CLAUDE.md checklist).

---

## Script 3: validate_state.py

### Purpose

Validate state files against JSON schemas (Enhancement #6).

### Inputs

**State files**:
- `data/state/master_state.json`
- `data/state/context_tracking.json`
- `data/state/module_*.json` or `section_*.json`

**Schemas**:
- `schemas/master_state.schema.json`
- `schemas/context_tracking.schema.json`
- `schemas/module_state.schema.json` or `section_state.schema.json`

### Algorithm

**Step 1: Load Schemas**
```
Load JSON schemas from schemas/ directory

schemas = {
    "master_state": load_json("schemas/master_state.schema.json"),
    "context_tracking": load_json("schemas/context_tracking.schema.json"),
    "module_state": load_json("schemas/module_state.schema.json")
}
```

**Step 2: Load State Files**
```
state_files = {
    "master_state": "data/state/master_state.json",
    "context_tracking": "data/state/context_tracking.json"
}

# Find all module/section state files
module_files = glob("data/state/module_*.json")
OR
section_files = glob("data/state/section_*.json")

Add to state_files dict
```

**Step 3: Validate Each File**
```
results = []

FOR each (file_type, file_path) in state_files:
    TRY:
        state_data = load_json(file_path)
        schema = schemas[file_type]

        validate_json(state_data, schema)  # Using jsonschema library

        results.append({
            "file": file_path,
            "valid": True,
            "errors": []
        })

    EXCEPT ValidationError as e:
        results.append({
            "file": file_path,
            "valid": False,
            "errors": [e.message]
        })

    EXCEPT FileNotFoundError:
        results.append({
            "file": file_path,
            "valid": False,
            "errors": ["File not found"]
        })

    EXCEPT JSONDecodeError:
        results.append({
            "file": file_path,
            "valid": False,
            "errors": ["Invalid JSON syntax"]
        })
```

**Step 4: Additional Semantic Validation**
```
# Beyond schema: logical checks

IF master_state loaded:
    # Check: modules_complete + modules_in_progress + modules_pending
    #        should account for all modules

    # Check: last_update timestamp is recent (< 5 min old)
    time_since_update = now() - parse_timestamp(master_state["last_update"])
    IF time_since_update > 5 minutes:
        results.append(warning: "Master state is stale")

    # Check: current_module exists in state files if not null
    IF master_state["current_module"] is not null:
        module_file = f"data/state/module_{current_module}_state.json"
        IF not exists(module_file):
            results.append(error: "Current module state file missing")
```

**Step 5: Display Results**
```
Print validation report:

"State File Validation
=====================

Master State (master_state.json): [✅ VALID | ❌ INVALID]
[If invalid: list errors]

Context Tracking (context_tracking.json): [✅ VALID | ❌ INVALID]
[If invalid: list errors]

Module States:
- module_1.1_state.json: [✅ VALID | ❌ INVALID]
- module_1.2_state.json: [✅ VALID | ❌ INVALID]
[etc.]

Summary:
- Total files: [N]
- Valid: [N]
- Invalid: [N]
- Warnings: [N]

[If all valid:]
✅ All state files are valid

[If any invalid:]
❌ Validation failed. Fix errors above before proceeding.
"
```

**Step 6: Return Exit Code**
```
IF all valid:
    RETURN 0
ELSE:
    RETURN 1
```

### Outputs

**Console**: Validation report
**Return code**: 0 (success) or 1 (failure)

**Integration**: Run before git commits (via CLAUDE.md checklist or git pre-commit hook).

---

## Integration with Framework

### Auto-Execution Points

**estimate_context.py**:
```
Trigger: After EVERY tool operation
Called by: CLAUDE.md checklist step:
"- [ ] Update context_tracking.json with token estimate"

Implementation:
    Execute: python scripts/estimate_context.py
    Read result: data/state/context_tracking.json
    Check status: SAFE/WARNING/CRITICAL/EMERGENCY
    Display: In checkpoint box
```

**validate_state.py**:
```
Trigger: Before git commits
Called by: CLAUDE.md checklist step:
"- [ ] Validate state files before commit"

Implementation:
    Execute: python scripts/validate_state.py
    IF exit code != 0:
        Display error
        Abort commit
        Ask user to fix
    ELSE:
        Proceed with commit
```

**setup_framework.py**:
```
Trigger: Manual (user initiates)
Usage: python scripts/setup_framework.py --interactive

Called when: Setting up new project
```

---

### Testing Scripts

**Each script should include**:
```
IF __name__ == "__main__":
    # Test mode
    IF "--test" in sys.argv:
        run_unit_tests()
    ELSE:
        main()
```

**Unit tests to include**:
1. Token estimation accuracy (compare to known values)
2. State validation (valid vs. invalid JSON)
3. Setup script (dry-run mode, verify no actual changes)

---

## Next Steps

**To implement these scripts**:

1. **Read this guide** (you just did)
2. **For each script**:
   - Create empty Python file in `scripts/`
   - Add docstring with purpose from this guide
   - Implement algorithm step by step
   - Add unit tests
   - Test manually
3. **Integrate**:
   - Update CLAUDE.md checklist to call scripts
   - Test integration
4. **Validate**:
   - Run through workflow in `04_CORE_WORKFLOW.md`
   - Verify scripts run automatically

---

**Scripts guide version**: 3.0
**Last updated**: January 2025
