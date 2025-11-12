# Templates Directory

**Purpose**: Copy-paste templates for framework files

**IMPORTANT**: Do NOT read all templates at once. Copy only what you need.

---

## Template Files

### Core Framework Templates (Universal)

- `CLAUDE.md.template` - Instruction hub for project root
- `AUTONOMOUS_MODE.md.template` - Permission grant
- `rules_CLAUDE.md.template` - Enforcement rules
- `.claude_README.md.template` - .claude directory documentation
- `recovery_prompt.template` - Session recovery template

### Project Type Specific

**Coding Projects**: `project_types/coding/`
- `master_state_coding.json` - State file for code projects
- `module_state.json` - Module-level state
- `ARCHITECTURE_coding.md` - Architecture doc template

**Non-Coding Projects**: `project_types/non_coding/`
- `master_state_writing.json` - State file for writing projects
- `section_state.json` - Section-level state
- `STRUCTURE_writing.md` - Structure doc template

---

## How to Use Templates

### Step 1: Identify Your Need

**Setting up new project?**
→ Copy: Core framework templates (all 5)

**Need state file?**
→ Copy: Appropriate project type state template

**Need recovery prompt?**
→ Copy: `recovery_prompt.template`

### Step 2: Copy Template

```bash
# Example: Copy CLAUDE.md template to project root
cp 03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
```

### Step 3: Customize

Replace placeholders:
- `[PROJECT_NAME]` → Your project name
- `[TEST_COMMAND]` → Your test command
- `[DATE]` → Today's date
- etc.

### Step 4: Validate

Check that no placeholders remain:
```bash
grep -r "\[" CLAUDE.md
# Should return nothing (no remaining placeholders)
```

---

**Templates are in this directory - scroll down or open individual files**
