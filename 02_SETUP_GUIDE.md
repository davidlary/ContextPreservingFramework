# Setup Guide - Framework Implementation

**Complete step-by-step guide to set up the framework in your project**

**Estimated time**: 30-45 minutes
**Token cost**: ~12K tokens (6% context)
**When to read**: Once, during initial project setup

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (Automated)](#quick-setup-automated)
3. [Project Type Selection](#project-type-selection)
4. [Manual Setup (Step-by-Step)](#manual-setup-step-by-step)
5. [Project Type Adaptations](#project-type-adaptations)
6. [Validation](#validation)

---

## Prerequisites

### Required Tools

**For coding projects**:
- Git (version control)
- Your programming language environment
- Text editor or IDE

**For non-coding projects**:
- Git (version control)
- Text editor (Markdown support recommended)

**For both**:
- Claude Code access
- Terminal/command line

### Project Readiness

**Before starting framework setup**:
- [ ] Project directory created
- [ ] Basic project structure decided (language, type)
- [ ] Goals defined (what you're building)
- [ ] Time allocated (30-45 min for setup)

---

## Quick Setup (Automated)

### Option A: Use Setup Script (Recommended)

**Step 1**: Copy setup script instructions from `06_SCRIPTS_GUIDE.md` section 1.

**Step 2**: Ask Claude Code to implement and run:
```
Implement the framework setup script from 06_SCRIPTS_GUIDE.md section 1.
Run it for a [coding/non-coding] project in [language/domain].

Project details:
- Name: [project name]
- Type: [web API / CLI tool / research paper / book / etc.]
- Language/Domain: [Python / JavaScript / Academic Writing / etc.]
```

**Step 3**: Script will:
- Create directory structure
- Generate all framework files
- Customize templates for your project
- Initialize git
- Run validation tests
- Display results

**Duration**: 5-10 minutes (mostly automated)

**If script works**: Skip to [Validation](#validation) section.

**If script fails or unavailable**: Proceed to Project Type Selection below.

---

## Project Type Selection

**Purpose**: Determine correct framework configuration for your project
**Duration**: 2-5 minutes
**Critical**: Choosing the right type affects templates, state schemas, and validation

---

### Decision Tree: What Type is Your Project?

**START**: Answer these questions to determine your project type.

#### Question 1: What is your primary output?

**A) Executable code, library, or application**
→ **Project Type: CODING**
→ Go to: [Coding Project Setup](#coding-project-characteristics)

**B) Written document (paper, book, documentation)**
→ **Project Type: NON-CODING**
→ Go to: Question 2

**C) Both significant code AND significant writing**
→ **Project Type: HYBRID**
→ Go to: [Hybrid Projects](#hybrid-projects-separate-approach)

---

#### Question 2: What kind of document? (Non-Coding Projects)

**A) Academic research paper or technical report**
→ **Sub-type: RESEARCH**
→ Templates: `project_types/non_coding/`
→ State file: `master_state_writing.json` (adapt for research)

**B) Book (fiction or non-fiction)**
→ **Sub-type: WRITING**
→ Templates: `project_types/non_coding/`
→ State file: `master_state_writing.json`

**C) Technical documentation or user guides**
→ **Sub-type: DOCUMENTATION**
→ Templates: `project_types/non_coding/`
→ State file: `master_state_writing.json` (adapt for docs)

**D) Data analysis report or findings narrative**
→ **Consider**: Is there substantial code for the analysis?
→ If YES: This might be HYBRID (see below)
→ If NO (mainly narrative): Sub-type RESEARCH

---

### Coding Project Characteristics

**Use coding templates if your project includes**:
- Source code files that execute
- Test suites (unit, integration, e2e)
- Build/compile steps
- Package management (pip, npm, cargo, etc.)
- API endpoints, CLI commands, or libraries

**Examples**:
- Web APIs (FastAPI, Express, Rails)
- CLI tools (Python argparse, Go cobra, etc.)
- Libraries/packages (published to PyPI, npm, crates.io)
- Mobile apps (React Native, Flutter)
- Data pipelines (Airflow, dbt)
- Machine learning models (training code, not the paper)

**Work unit**: Module = 1 file or 250 lines of code
**Validation**: Test suites (pytest, jest, cargo test, etc.)
**State tracking**: Modules complete, tests passing

---

### Non-Coding Project Characteristics

**Use non-coding templates if your project includes**:
- Primarily written text (prose, explanations, arguments)
- Citations and references
- Narrative structure (introduction, body, conclusion)
- Word count targets
- Minimal or no executable code

**Examples**:
- Academic papers (research findings, meta-analyses)
- Books (fiction novels, technical books, memoirs)
- Documentation (user guides, API docs, tutorials)
- Grant proposals
- Technical reports
- Course curriculum (lesson plans, syllabi)

**Work unit**: Section = 1,000-1,500 words or 1 argument/concept
**Validation**: Citation checks, word counts, coherence review
**State tracking**: Sections complete, word count, references cited

---

### Hybrid Projects: Separate Approach

**What is a hybrid project?**
A project with BOTH:
- Substantial executable code (>500 lines, multiple modules)
- Substantial written narrative (>3,000 words, multiple sections)
- Neither dominates (roughly 40/60 to 60/40 split)

**Examples**:
- Machine learning research: Training code + research paper
- Software with academic publication: Implementation + paper
- Data analysis with report: Analysis scripts + findings document
- Book with code examples: Manuscript + example codebase

---

#### Hybrid Solution: Create Two Separate Projects

**Rationale**: Mixing coding and writing templates creates confusion. Separate projects maintain clarity.

**Step 1**: Create two project directories
```bash
# Example: ML research project
mkdir -p my_research_project/
cd my_research_project/

# Two sub-projects:
mkdir -p code/     # Coding project
mkdir -p paper/    # Non-coding (research) project
mkdir -p shared/   # Shared data/results
```

**Step 2**: Set up each project independently
```bash
# Setup coding project
cd code/
# Copy coding templates from 03_TEMPLATES/project_types/coding/
# Initialize as CODING project

# Setup paper project
cd ../paper/
# Copy non-coding templates from 03_TEMPLATES/project_types/non_coding/
# Initialize as RESEARCH project
```

**Step 3**: Link shared resources
```bash
# From code/ directory:
ln -s ../shared/data ./data/shared
ln -s ../shared/results ./results

# From paper/ directory:
ln -s ../shared/results ./figures/from_code
ln -s ../shared/data ./references/datasets
```

**Step 4**: Workflow
1. **Code phase**: Work in `code/`, implement ML training, generate results → `shared/results/`
2. **Writing phase**: Work in `paper/`, reference results from `shared/results/`, write narrative
3. Each project has independent:
   - State files (master_state.json)
   - Recovery prompts
   - Git commits (or same repo, different prefixes)
   - Context tracking

**Benefits**:
- ✅ Clean separation of concerns
- ✅ Appropriate validation for each (tests for code, citations for paper)
- ✅ Can work on code and paper in parallel (different sessions)
- ✅ No template confusion (each uses correct type)

**Alternative**: If one heavily dominates (>70%):
- Code-heavy (>70% code): Use CODING templates, treat paper as "documentation module"
- Writing-heavy (>70% writing): Use RESEARCH templates, treat code as "analysis scripts"

---

### Decision Summary Table

| Your Project | Primary Output | Code Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|-------------|----------------|----------------|-----------|
| Web API | Executable | High | Low (docs) | CODING | `coding/` |
| CLI Tool | Executable | High | Low (help) | CODING | `coding/` |
| Library | Executable | High | Low (docs) | CODING | `coding/` |
| Research Paper | Document | Low (none) | High | RESEARCH | `non_coding/` |
| Research Paper | Document | Low (figures) | High | RESEARCH | `non_coding/` |
| Book | Document | Low (examples) | High | WRITING | `non_coding/` |
| Documentation | Document | Low (examples) | High | DOCUMENTATION | `non_coding/` |
| ML Research | Both | High (training) | High (paper) | HYBRID | Separate projects |
| Data Analysis Report | Both | Medium (scripts) | High (findings) | HYBRID | Separate projects |
| Software + Paper | Both | High (implementation) | Medium (paper) | HYBRID | Separate projects |

---

### Next Steps After Selection

**Once you've determined your project type**:

1. **If CODING**: Proceed to [Manual Setup - Phase 1](#phase-1-directory-structure-5-minutes) with coding configurations

2. **If NON-CODING**: Proceed to [Manual Setup - Phase 1](#phase-1-directory-structure-5-minutes) with non-coding configurations

3. **If HYBRID**:
   - Create separate directories
   - Set up each as independent project
   - Follow manual setup twice (once for code/, once for paper/)
   - Link shared resources

---

## Manual Setup (Step-by-Step)

### Phase 1: Directory Structure (5 minutes)

**Step 1.1**: Create framework directories

```bash
# From your project root
mkdir -p .claude/hooks
mkdir -p rules
mkdir -p data/state
mkdir -p data/audit
mkdir -p data/scratch
mkdir -p docs/recovery_prompts
mkdir -p logs
mkdir -p config
mkdir -p schemas
mkdir -p scripts
```

**For coding projects, also create**:
```bash
mkdir -p core        # or src/
mkdir -p tests
```

**For non-coding projects, also create**:
```bash
mkdir -p drafts
mkdir -p sections
mkdir -p references
```

**Verify**:
```bash
ls -la
# Should see: .claude/, rules/, data/, docs/, logs/, config/, schemas/, scripts/
```

---

### Phase 2: Core Framework Files (15 minutes)

#### File 1: CLAUDE.md (Instruction Hub)

**Location**: Project root `CLAUDE.md`

**Action**: Copy template from `03_TEMPLATES/CLAUDE.md.template`

**Customizations**:
1. Replace `[PROJECT_NAME]` with your project name
2. Replace `[TEST_COMMAND]` with your test command
   - Coding: `pytest tests/` or `npm test` or `cargo test`
   - Non-coding: `scripts/validate_sections.sh` (create later)
3. Replace `[VALIDATION_COMMAND]` with validation command
4. List your critical files

**Example for Python API**:
```markdown
# My API Project

**Test**: `pytest tests/ -v`
**Validate**: `python scripts/validate_config.py`
**State**: `cat data/state/master_state.json | jq .`

## Critical Files

- State: data/state/master_state.json
- Config: config/api_config.json
- Logs: logs/operation_log.txt
```

**Example for Research Paper**:
```markdown
# Climate Change Meta-Analysis Paper

**Test**: `scripts/check_citations.sh`
**Validate**: `scripts/validate_sections.sh`
**State**: `cat data/state/master_state.json | jq .`

## Critical Files

- State: data/state/master_state.json
- Draft: drafts/current_draft.md
- Outline: docs/outline.md
- References: references/bibliography.bib
```

**Keep the MANDATORY CHECKLIST section exactly as is** (do not modify).

---

#### File 2: AUTONOMOUS_MODE.md (Permission Grant)

**Location**: Project root `AUTONOMOUS_MODE.md`

**Action**: Copy template from `03_TEMPLATES/AUTONOMOUS_MODE.md.template`

**Customizations**:
1. Set `STATUS: ACTIVE`
2. Set `PERMISSION GRANTED: [today's date]`
3. Define scope in "Explicit Permissions" section
4. Add your modules to list (or "all modules in specification")
5. Sign and date at bottom

**Example scope for coding project**:
```markdown
**SCOPE**: Full implementation of MyAPI project through v1.0 release

## Explicit Permissions

I, [Your Name], grant Claude Code permission to:

1. ✅ Create ALL files in docs/IMPLEMENTATION_PLAN.md
2. ✅ Write ALL code for modules 1.1 through 3.5
3. ✅ Install packages in requirements.txt
4. ✅ Run ALL tests (pytest)
5. ✅ Fix test failures autonomously
6. ✅ Git commit with descriptive messages
```

**Example scope for non-coding project**:
```markdown
**SCOPE**: Complete draft of climate change paper through submission

## Explicit Permissions

I, [Your Name], grant Claude Code permission to:

1. ✅ Write ALL sections per outline
2. ✅ Research and cite sources
3. ✅ Generate figures/tables
4. ✅ Revise sections based on review
5. ✅ Format per journal guidelines
6. ✅ Git commit drafts with version messages
```

---

#### File 3: rules/CLAUDE.md (Enforcement Rules)

**Location**: `rules/CLAUDE.md`

**Action**: Copy template from `03_TEMPLATES/rules_CLAUDE.md.template`

**Customizations**:
- For coding projects: Keep all rules as-is
- For non-coding projects: Adapt terminology
  - "modules" → "sections"
  - "tests" → "reviews" or "validations"
  - "code" → "draft text"

**Example adaptation for non-coding**:
```markdown
## RULE 10: CONTEXT MANAGEMENT

**Principle**: Prevent context exhaustion
**Action**:
  - Micro-sections (max 1,500 words per chunk)
  - Real-time context tracking
  - Warning at 30%, critical at 35%

## RULE 14: MANDATORY STATE TRACKING

**Principle**: State tracking after EVERY writing session
**Action**: After Read, Write, Edit:
  1. Append to logs/operation_log.txt
  2. Update data/state/master_state.json
  3. Update data/state/context_tracking.json
```

---

#### File 4: .claude/README.md (Documentation)

**Location**: `.claude/README.md`

**Action**: Copy template from `03_TEMPLATES/.claude_README.md.template`

**No customizations needed** - use as-is.

---

### Phase 3: State Files (10 minutes)

#### State File 1: Master State

**Location**: `data/state/master_state.json`

**For coding projects**:
```json
{
  "project": "my_api_project",
  "version": "0.1.0",
  "project_type": "coding",
  "language": "python",
  "current_phase": "setup",
  "current_module": null,
  "modules_complete": [],
  "modules_in_progress": [],
  "modules_pending": ["1.1", "1.2", "1.3", "..."],
  "tests_passing": 0,
  "tests_total": 0,
  "last_update": "2025-01-11T00:00:00Z"
}
```

**For non-coding projects**:
```json
{
  "project": "climate_paper",
  "version": "0.1.0",
  "project_type": "non_coding",
  "domain": "academic_research",
  "current_phase": "writing",
  "current_section": null,
  "sections_complete": [],
  "sections_in_progress": [],
  "sections_pending": ["introduction", "lit_review", "methodology", "..."],
  "word_count": 0,
  "target_word_count": 8000,
  "references_cited": 0,
  "last_update": "2025-01-11T00:00:00Z"
}
```

**Action**: Copy appropriate template, customize project name and pending items.

---

#### State File 2: Context Tracking

**Location**: `data/state/context_tracking.json`

**Universal (same for all projects)**:
```json
{
  "estimated_tokens": 0,
  "max_tokens": 200000,
  "usage_pct": 0.0,
  "threshold_warning": 30.0,
  "threshold_critical": 35.0,
  "threshold_force_exit": 40.0,
  "operations_this_session": 0,
  "last_update": "2025-01-11T00:00:00Z"
}
```

**No customizations needed**.

---

### Phase 4: Documentation Files (5 minutes)

#### File 1: ARCHITECTURE.md (Design Document)

**Location**: `ARCHITECTURE.md`

**For coding projects** - Include:
```markdown
# [Project Name] Architecture

## System Overview
[3-4 paragraphs describing what you're building]

## Technology Stack
- Language: [Python/JavaScript/etc.]
- Database: [PostgreSQL/MongoDB/etc.]
- Framework: [FastAPI/Express/etc.]
- Key Libraries: [list]

## Module Breakdown

### Module 1.1: [Name]
**Purpose**: [1 sentence]
**Key Functions**: [list]
**Lines**: ~250
**Duration**: 1 hour

[Repeat for each module]
```

**For non-coding projects** - Include:
```markdown
# [Paper/Book Title] Structure

## Project Overview
[What you're writing, for whom, why]

## Outline

### Section 1: Introduction
**Purpose**: [what this section accomplishes]
**Word Count**: ~1,200 words
**Key Points**: [list]
**Duration**: 2 hours

[Repeat for each section]
```

---

#### File 2: IMPLEMENTATION_PLAN.md

**Location**: `docs/IMPLEMENTATION_PLAN.md`

**Structure**:
```markdown
# Implementation Plan

## Phase 1: [Name]
- Module 1.1: [Name] (Session 1, 1 hour)
- Module 1.2: [Name] (Session 1, 1 hour)
[Checkpoint/recovery point]

## Phase 2: [Name]
- Module 2.1: [Name] (Session 2, 1 hour)
[...]

## Timeline
- Total modules: [N]
- Estimated sessions: [N]
- Total duration: [X] hours
```

**Adapt for non-coding**:
- "Module" → "Section"
- "Session" → "Writing session"

---

#### File 3: Recovery Prompt Template

**Location**: `docs/recovery_prompts/SESSION_TEMPLATE.md`

**Action**: Copy from `03_TEMPLATES/recovery_prompt.template`

**Customizations**:
- Replace placeholders with your project terminology
- Keep structure exactly the same

---

### Phase 5: Schemas (5 minutes)

**Location**: `schemas/`

**Action**: Copy JSON schemas from `10_REFERENCE/state_schemas.md`

**Files to create**:
1. `schemas/master_state.schema.json`
2. `schemas/context_tracking.schema.json`
3. `schemas/module_state.schema.json` (coding) OR
   `schemas/section_state.schema.json` (non-coding)

**These enable validation** (Enhancement #3).

---

### Phase 6: Scripts Directory (5 minutes)

**Location**: `scripts/`

**Don't implement scripts yet**, just create placeholders:

```bash
touch scripts/estimate_context.py
touch scripts/validate_state.py
touch scripts/setup_framework.py
```

**Add comments in each**:
```python
# scripts/estimate_context.py
# Implementation instructions: See 06_SCRIPTS_GUIDE.md Section 2
# Purpose: Automated context estimation from operation log
```

**You'll implement these later** following `06_SCRIPTS_GUIDE.md`.

---

### Phase 7: Git Initialization (3 minutes)

**Step 7.1**: Initialize git (if not already done)

```bash
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

**Step 7.2**: Create .gitignore

```gitignore
# Framework-specific
logs/*.log
data/scratch/*
.DS_Store

# Language-specific (add as needed)
__pycache__/
*.pyc
node_modules/
*.swp
```

**Step 7.3**: First commit

```bash
git add .
git commit -m "Initial commit: Context-Preserving Framework v3.0 setup

Framework components:
- CLAUDE.md (instruction hub)
- AUTONOMOUS_MODE.md (permission grant)
- rules/CLAUDE.md (enforcement rules)
- data/state/*.json (state tracking)
- docs/ (architecture, plans, recovery templates)
- schemas/ (JSON validation)

Project: [Your project name]
Type: [coding/non-coding]
Framework: v3.0

🤖 Framework setup with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Project Type Adaptations

### Adaptation 1: Web API (Python/FastAPI)

**Module structure**:
```
core/
  database.py          (Module 1.1)
  models.py            (Module 1.2)
  routes.py            (Module 1.3)
  auth.py              (Module 1.4)
  validators.py        (Module 1.5)
```

**State tracking**: Standard JSON (modules_complete, tests_passing)

**Checkpoints**: After each module's tests pass

---

### Adaptation 2: CLI Tool (Go/Rust)

**Module structure**:
```
src/
  main.rs              (Module 1.1)
  config.rs            (Module 1.2)
  commands/
    cmd_init.rs        (Module 1.3)
    cmd_run.rs         (Module 1.4)
```

**State tracking**: Standard JSON

**Checkpoints**: After each command implementation + tests

---

### Adaptation 3: Research Paper

**Section structure**:
```
sections/
  01_introduction.md        (Section 1, ~1,200 words)
  02_lit_review_part1.md    (Section 2a, ~1,000 words)
  02_lit_review_part2.md    (Section 2b, ~1,000 words)
  03_methodology.md         (Section 3, ~1,500 words)
  04_results_part1.md       (Section 4a, ~900 words)
  04_results_part2.md       (Section 4b, ~900 words)
  05_discussion.md          (Section 5, ~1,500 words)
  06_conclusion.md          (Section 6, ~800 words)
```

**State tracking**:
```json
{
  "sections_complete": ["01_introduction", "02_lit_review_part1"],
  "sections_in_progress": ["02_lit_review_part2"],
  "word_count": 2200,
  "references_cited": 34,
  "figures_created": 2
}
```

**Checkpoints**: After each section complete

**"Tests"**: Citations check, word count validation, outline adherence

---

### Adaptation 4: Book Writing (Fiction/Non-Fiction)

**Chapter structure**:
```
chapters/
  ch01_opening.md           (~3,000 words)
  ch02_conflict.md          (~3,000 words)
  ...
```

**For long chapters, split into scenes**:
```
chapters/
  ch01/
    scene01_intro.md        (~1,000 words)
    scene02_inciting.md     (~1,000 words)
    scene03_response.md     (~1,000 words)
```

**State tracking**:
```json
{
  "chapters_complete": ["ch01"],
  "scenes_in_progress": ["ch02_scene01"],
  "total_word_count": 3000,
  "target_word_count": 80000,
  "chapters_revised": 0
}
```

**Checkpoints**: After each scene or chapter

**"Tests"**: Consistency checks, character tracking, plot outline adherence

---

### Adaptation 5: Documentation Project

**Page structure**:
```
docs/
  getting_started.md
  installation.md
  configuration.md
  api_reference/
    endpoints.md
    authentication.md
    errors.md
  guides/
    quickstart.md
    advanced.md
```

**State tracking**:
```json
{
  "pages_complete": ["getting_started", "installation"],
  "pages_in_progress": ["configuration"],
  "total_pages": 12,
  "target_pages": 20,
  "code_examples": 15,
  "screenshots": 8
}
```

**Checkpoints**: After each page or section

**"Tests"**: Link checking, code example validation, spelling/grammar

---

## Validation

**After setup complete**, validate framework is operational:

**Next step**: Proceed to `07_TESTING_GUIDE.md`

**Run tests 1-6 sequentially** (one at a time):
1. AUTONOMOUS_MODE.md recognition
2. State file updates
3. Checkpoint box display
4. Git commit protocol
5. Recovery prompt generation
6. Context threshold simulation

**Duration**: 10-15 minutes total (2-3 min per test)

**If all tests pass**: Framework is ready, start project work.

**If any test fails**: See `08_TROUBLESHOOTING.md` for solutions.

---

## Quick Reference

### Setup Checklist

**Phase 1: Directories** (5 min)
- [ ] Create .claude/, rules/, data/, docs/, logs/, config/, schemas/, scripts/
- [ ] Create project-specific dirs (core/tests OR drafts/sections)

**Phase 2: Core Files** (15 min)
- [ ] CLAUDE.md (customize for project)
- [ ] AUTONOMOUS_MODE.md (set ACTIVE, define scope)
- [ ] rules/CLAUDE.md (adapt if non-coding)
- [ ] .claude/README.md (copy as-is)

**Phase 3: State Files** (10 min)
- [ ] data/state/master_state.json
- [ ] data/state/context_tracking.json

**Phase 4: Documentation** (5 min)
- [ ] ARCHITECTURE.md or equivalent
- [ ] docs/IMPLEMENTATION_PLAN.md
- [ ] docs/recovery_prompts/SESSION_TEMPLATE.md

**Phase 5: Schemas** (5 min)
- [ ] Copy schemas from 10_REFERENCE/state_schemas.md

**Phase 6: Scripts** (5 min)
- [ ] Create placeholder scripts

**Phase 7: Git** (3 min)
- [ ] git init
- [ ] .gitignore
- [ ] Initial commit

**Phase 8: Validation** (15 min)
- [ ] Run tests 1-6 from 07_TESTING_GUIDE.md

**Total Time**: 60 minutes (with validation)

---

## Next Steps

**Framework is set up!** Proceed to:

**→ Read**: `04_CORE_WORKFLOW.md` to understand daily workflow

Or:
- Implement scripts: `06_SCRIPTS_GUIDE.md`
- See examples: `09_EXAMPLES/` (your project type)
- Start coding/writing: Follow workflow in `04_CORE_WORKFLOW.md`

---

**Setup guide version**: 3.0
**Last updated**: January 2025
