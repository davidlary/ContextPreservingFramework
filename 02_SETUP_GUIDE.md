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

---

## Phase 0: Requirements Gathering (Do This BEFORE Framework Setup)

**Purpose**: Define what you're building before setting up implementation framework
**Duration**: 15-60 minutes (depending on project complexity)
**Why critical**: Framework is for implementation; you need requirements first

### Step 0.1: Problem Statement (5 minutes)

**Answer these questions** (write answers in a temporary `REQUIREMENTS.md` or notebook):

1. **What problem are you solving?**
   - One sentence description
   - Example: "Users need a way to track daily habits without complex apps"

2. **Who is this for?**
   - Target audience/users
   - Example: "Busy professionals who want simple CLI-based tracking"

3. **What currently exists?**
   - Existing solutions (if any)
   - Why they're insufficient
   - What you'll do differently

**Output**: Clear problem statement you can reference

---

### Step 0.2: Core Requirements (10-20 minutes)

**List functional requirements** (what the system must do):

**For coding projects**:
```markdown
## Functional Requirements

1. [ ] User authentication (login/logout)
2. [ ] Data storage (SQLite local database)
3. [ ] Export to CSV
4. [ ] CLI interface (no GUI)
5. [ ] Cross-platform (Mac, Linux, Windows)
```

**For non-coding projects**:
```markdown
## Content Requirements

1. [ ] Literature review (50+ papers)
2. [ ] Methodology section
3. [ ] Results with statistical analysis
4. [ ] Discussion comparing to prior work
5. [ ] 8,000-10,000 words
6. [ ] IEEE citation format
```

**For infrastructure projects**:
```markdown
## Infrastructure Requirements

1. [ ] Deploys to AWS (not Azure/GCP)
2. [ ] Multi-region (us-east-1, us-west-2)
3. [ ] Auto-scaling (2-10 instances)
4. [ ] Cost target: <$500/month
5. [ ] Terraform 1.5+ (not CloudFormation)
```

**For design projects**:
```markdown
## Design Requirements

1. [ ] Support 100K concurrent users (system design)
2. [ ] WCAG 2.1 AA compliance (UX design)
3. [ ] RESTful + GraphQL (API design)
4. [ ] 3NF normalization (database design)
5. [ ] Deliverables: Diagrams + ADRs + Specifications
```

**Output**: Prioritized list of must-have features/content

---

### Step 0.3: Constraints and Dependencies (5-10 minutes)

**Identify constraints** (limitations you must work within):

**Technical constraints**:
- [ ] Must use specific language/framework (e.g., "Must be Python 3.9+")
- [ ] Must integrate with existing system (e.g., "Must work with legacy MySQL DB")
- [ ] Performance requirements (e.g., "Response time <200ms")
- [ ] Platform requirements (e.g., "Must run on Raspberry Pi")

**Resource constraints**:
- [ ] Time limit (e.g., "Deliver in 6 weeks")
- [ ] Budget limit (e.g., "Zero cloud costs")
- [ ] Team size (e.g., "Solo project")
- [ ] Access constraints (e.g., "No access to production data")

**External dependencies**:
- [ ] Third-party APIs (e.g., "Requires Stripe API")
- [ ] External services (e.g., "Depends on AWS S3")
- [ ] Data sources (e.g., "Needs Census Bureau data")
- [ ] Approval processes (e.g., "Needs security review")

**Output**: List of constraints that will affect architecture/approach

---

### Step 0.4: Success Criteria (5 minutes)

**Define "done"** - How will you know the project succeeded?

**Quantitative criteria** (measurable):
- [ ] All 15 functional requirements implemented
- [ ] Test coverage ≥80%
- [ ] Performance: API responds in <200ms (p95)
- [ ] Documentation: 100% of public API documented

**Qualitative criteria** (subjective but verifiable):
- [ ] Code review passes (no major issues)
- [ ] Security scan: No high/critical vulnerabilities
- [ ] User testing: 4+ rating from 5 test users
- [ ] Stakeholder approval obtained

**Project-specific examples**:

**Coding project**:
- [ ] pytest: All tests pass
- [ ] pylint: Score >8.0
- [ ] Successfully deploys to staging
- [ ] Load test: Handles 1000 req/sec

**Research paper**:
- [ ] Journal submission ready (formatted correctly)
- [ ] 8,000-10,000 words
- [ ] Peer review ready (all sections complete)
- [ ] 50+ citations, all properly formatted

**Infrastructure project**:
- [ ] terraform plan: No errors
- [ ] Cost estimate: <$500/month
- [ ] Security scan: CIS benchmark level 1 pass
- [ ] DR test: Recovery in <4 hours

**Output**: Clear checklist of completion criteria

---

### Step 0.5: Risk Assessment (5-10 minutes)

**Identify potential blockers** early:

**Technical risks**:
- [ ] **Risk**: Unfamiliar technology (e.g., first Rust project)
  - **Mitigation**: Allocate learning time, start with simple modules
- [ ] **Risk**: Complex integration (e.g., legacy system interface)
  - **Mitigation**: Prototype integration early, document assumptions
- [ ] **Risk**: Performance unknowns (e.g., can SQLite handle this load?)
  - **Mitigation**: Early performance testing, have backup plan (PostgreSQL)

**Resource risks**:
- [ ] **Risk**: Tight deadline
  - **Mitigation**: Prioritize MVP features, defer nice-to-haves
- [ ] **Risk**: Limited access (e.g., can't test on Windows)
  - **Mitigation**: Document testing limitations, recruit testers

**Dependency risks**:
- [ ] **Risk**: Third-party API changes
  - **Mitigation**: Abstract API behind interface, monitor changelog
- [ ] **Risk**: Approval delays
  - **Mitigation**: Submit early, have backup plans

**Output**: Risk register with mitigation strategies

---

### Step 0.6: Decomposition Planning (10-20 minutes)

**Break project into modules/sections** (rough first pass):

**For coding projects** (modules):
```markdown
## Module Breakdown (Rough Estimate)

1. **Authentication** (2-3 sessions)
   - User login
   - Token management
   - Password reset

2. **Data Layer** (2-3 sessions)
   - Database schema
   - CRUD operations
   - Migration system

3. **API Layer** (3-4 sessions)
   - RESTful endpoints
   - Request validation
   - Error handling

4. **CLI Interface** (2-3 sessions)
   - Command parsing
   - User prompts
   - Output formatting

Total: ~10-15 sessions (rough estimate)
```

**For non-coding projects** (sections):
```markdown
## Section Breakdown (Rough Estimate)

1. **Introduction** (1 session, 1,000 words)
2. **Literature Review** (3-4 sessions, 2,500 words)
3. **Methodology** (2 sessions, 1,500 words)
4. **Results** (3 sessions, 2,000 words)
5. **Discussion** (2 sessions, 1,500 words)
6. **Conclusion** (1 session, 800 words)
7. **References** (1 session, formatting)

Total: ~12-15 sessions (rough estimate)
```

**For infrastructure projects** (resource groups):
```markdown
## Resource Group Breakdown

1. **Networking** (1 session)
   - VPC, subnets, security groups

2. **Compute** (2 sessions)
   - EC2 launch configs, auto-scaling groups

3. **Storage** (1 session)
   - S3 buckets, EBS volumes

4. **Database** (1 session)
   - RDS instance, parameter groups

5. **CI/CD** (2 sessions)
   - GitHub Actions workflows, deployment pipeline

Total: ~7-9 sessions (rough estimate)
```

**Output**: High-level module/section list (will be refined during implementation)

---

### Step 0.7: Technology Selection (For Autonomous Implementation)

**IMPORTANT**: If you want Claude to implement autonomously, make technology decisions NOW.

**Decision checklist for coding projects**:
- [ ] **Language**: Python / JavaScript / Rust / Go / Other: _____
- [ ] **Framework**: (if applicable) Django / Flask / Express / Next.js / Other: _____
- [ ] **Database**: SQLite / PostgreSQL / MongoDB / Other: _____
- [ ] **Testing**: pytest / Jest / cargo test / Other: _____
- [ ] **Deployment**: Docker / AWS / Heroku / None (local only)

**Decision checklist for infrastructure projects**:
- [ ] **IaC Tool**: Terraform / CloudFormation / Pulumi / Ansible
- [ ] **Cloud Provider**: AWS / Azure / GCP / Multi-cloud
- [ ] **Container Runtime**: Docker / Podman / containerd
- [ ] **Orchestration**: Kubernetes / Docker Compose / ECS / None

**Decision checklist for design projects**:
- [ ] **Diagramming**: Mermaid / PlantUML / draw.io / Lucidchart
- [ ] **Specification Format**: Markdown / YAML / JSON / PDF
- [ ] **Version Control**: Git / Other / None

**If you haven't decided**: Framework setup can proceed, but Claude will need to ask questions during implementation OR you'll need to provide explicit tech stack in prompts.

**Output**: Technology decisions documented (reference during setup)

---

### Step 0.7A: Autonomous Technology Selection (Decision Trees for Claude)

**Purpose**: Enable Claude to make technology choices autonomously based on requirements
**When to use**: When user hasn't specified tech stack OR when user wants recommendations

**IMPORTANT FOR CLAUDE**: If user hasn't specified technology in requirements, use these decision trees to make informed choices. Document your reasoning in REQUIREMENTS.md or memory/requirements.md.

---

#### Decision Tree 1: Programming Language Selection

**START**: What type of project?

**For Web APIs / Backend Services**:
```
Q1: What are your performance requirements?
├─ High throughput (>10K req/sec), low latency (<50ms) → Go or Rust
├─ Moderate throughput, rapid development priority → Python (FastAPI/Flask) or Node.js (Express)
└─ Enterprise environment, strong typing → Java (Spring) or C# (.NET)

Q2: What's your deployment environment?
├─ Cloud-native (AWS Lambda, serverless) → Node.js or Python
├─ Containerized (Kubernetes) → Any (prefer Go for small images)
├─ Traditional servers → Any

Q3: Data science / ML integration needed?
├─ Yes, heavy ML → Python (ecosystem advantage)
└─ No → Continue with Q1 choice
```

**For CLI Tools**:
```
Q1: Distribution method?
├─ Single binary (no dependencies) → Go or Rust
├─ Package manager (npm, pip) → Node.js or Python
└─ Multi-platform (Windows, Mac, Linux) → Go (easiest cross-compilation)

Q2: Complexity?
├─ Simple scripts (<500 lines) → Python or Bash
├─ Medium tools (500-5000 lines) → Python or Go
└─ Complex tools (>5000 lines) → Go or Rust
```

**For Libraries / Packages**:
```
Q1: Target ecosystem?
├─ Data science / ML → Python
├─ Web development → JavaScript/TypeScript
├─ Systems programming → Rust or C++
├─ Enterprise / Android → Java or Kotlin
└─ iOS / macOS → Swift
```

**For Mobile Apps**:
```
Q1: Platform support?
├─ iOS only → Swift
├─ Android only → Kotlin
├─ Cross-platform (iOS + Android) → React Native or Flutter
└─ Web + Mobile → React Native (shared code with web)
```

**Default recommendations** (when unclear):
- **General-purpose**: Python 3.11+ (versatile, readable, rich ecosystem)
- **Performance-critical**: Go (balance of speed and simplicity)
- **Systems/embedded**: Rust (memory safety + performance)
- **Enterprise**: Java 17+ or C# .NET 8+

**Claude's decision format**:
```markdown
## Technology Decision: Programming Language

**Selected**: Python 3.11+

**Rationale**:
- Project type: Web API with data processing
- Requirements indicate moderate throughput (<1K req/sec)
- Rapid development prioritized (6-week deadline)
- Data analysis integration mentioned (pandas, numpy)
- User constraint: Must deploy on AWS Lambda (Python well-supported)

**Alternative considered**: Node.js (rejected: no data science integration)
```

---

#### Decision Tree 2: Web Framework Selection (by Language)

**Python Web Frameworks**:
```
Q1: Project complexity?
├─ Microservice / API only → FastAPI (modern, fast, auto-docs)
├─ Full-stack with admin panel → Django (batteries-included)
├─ Lightweight, flexibility priority → Flask (minimalist)
└─ Async/high-concurrency → FastAPI or aiohttp

Q2: Database ORM needed?
├─ Yes, complex models → Django (built-in ORM)
├─ Yes, lightweight → SQLAlchemy (with Flask/FastAPI)
└─ No (raw SQL) → FastAPI or Flask

Recommendation: FastAPI (modern default for new APIs)
```

**JavaScript/TypeScript Frameworks**:
```
Q1: Frontend included?
├─ Yes, SSR (Server-Side Rendering) → Next.js
├─ Yes, SPA (Single-Page App) → React + Express API
├─ No, API only → Express or Fastify
└─ Real-time (WebSockets) → Express + Socket.io or Nest.js

Q2: TypeScript requirement?
├─ Yes, large project → Nest.js (TypeScript-first, structured)
├─ Yes, simple project → Express + TypeScript
└─ No (JavaScript) → Express

Recommendation: Express (simplest) or Next.js (if frontend needed)
```

**Go Frameworks**:
```
Q1: Project size?
├─ Microservice / simple API → Chi or Fiber (lightweight)
├─ Complex API with many routes → Gin (popular, feature-rich)
└─ Enterprise / large team → Echo or Go standard library (most explicit)

Recommendation: Gin (balance of features and simplicity)
```

---

#### Decision Tree 3: Database Selection

**START**: What type of data?

**Structured Data (tables, relationships)**:
```
Q1: Scale expectations?
├─ Small (<100K rows total) → SQLite (serverless, simple)
├─ Medium (<10M rows) → PostgreSQL (robust, feature-rich)
├─ Large (>10M rows) → PostgreSQL with partitioning OR cloud DB (RDS, Cloud SQL)
└─ Massive (>100M rows) → PostgreSQL + read replicas OR distributed SQL (CockroachDB)

Q2: ACID requirements?
├─ Critical (financial, medical) → PostgreSQL or MySQL
├─ Important → PostgreSQL
└─ Relaxed → SQLite or NoSQL

Q3: Deployment complexity?
├─ Zero setup (local, prototyping) → SQLite
├─ Cloud-hosted → Amazon RDS (PostgreSQL) or Cloud SQL
└─ Self-hosted → PostgreSQL in Docker

Recommendation: PostgreSQL (most versatile) or SQLite (simplest)
```

**Unstructured / Semi-Structured Data (documents, JSON)**:
```
Q1: Query patterns?
├─ Key-value lookup only → Redis (in-memory) or DynamoDB
├─ Rich queries, indexing → MongoDB (flexible schema)
├─ Full-text search → Elasticsearch
└─ Graph relationships → Neo4j or PostgreSQL with JSONB

Q2: Consistency vs availability?
├─ Consistency critical → PostgreSQL with JSONB (SQL + JSON)
├─ Availability critical → MongoDB or DynamoDB
└─ Balanced → MongoDB

Recommendation: PostgreSQL with JSONB (SQL benefits + JSON flexibility)
```

**Time-Series Data (metrics, logs, IoT)**:
```
Q1: Volume?
├─ Low (<1M points/day) → PostgreSQL with TimescaleDB extension
├─ High (>1M points/day) → InfluxDB or TimescaleDB
└─ Massive (>100M points/day) → InfluxDB or cloud solution (Timestream)

Recommendation: TimescaleDB (PostgreSQL extension, familiar SQL)
```

**Default recommendation** (when unclear): PostgreSQL 15+ (handles most use cases)

---

#### Decision Tree 4: Infrastructure Tool Selection

**For Infrastructure as Code (IaC)**:
```
Q1: Cloud provider?
├─ AWS only, AWS-native → CloudFormation
├─ AWS, multi-tool ecosystem → Terraform or Pulumi
├─ Azure only → Azure Resource Manager (ARM) or Terraform
├─ GCP only → Google Deployment Manager or Terraform
├─ Multi-cloud → Terraform (de facto standard)
└─ Cloud-agnostic → Pulumi (modern, supports programming languages)

Q2: Team background?
├─ DevOps / HCL experience → Terraform
├─ Developers (Python/JS/Go) → Pulumi (real programming languages)
└─ Sysadmin / YAML preference → Ansible

Q3: State management?
├─ Simple (small team) → Terraform with local/S3 state
├─ Complex (large team) → Terraform Cloud or Pulumi Cloud
└─ No cloud dependencies → Ansible (agentless, stateless)

Recommendation: Terraform (most widely adopted, mature ecosystem)
```

**For Container Orchestration**:
```
Q1: Scale?
├─ Single server, simple → Docker Compose
├─ Multi-server, moderate scale → Docker Swarm or Nomad
├─ Large scale, production → Kubernetes
└─ Serverless containers → AWS ECS/Fargate or Google Cloud Run

Q2: Team Kubernetes expertise?
├─ Yes → Kubernetes (industry standard)
├─ No, willing to learn → Kubernetes (invest in learning)
├─ No, need simplicity → Docker Compose or cloud-managed (ECS, Cloud Run)
└─ No, need something between → Nomad

Recommendation: Kubernetes (if scale justifies complexity) or Docker Compose (simple)
```

**For CI/CD Pipelines**:
```
Q1: Repository platform?
├─ GitHub → GitHub Actions (native integration)
├─ GitLab → GitLab CI (native integration)
├─ Bitbucket → Bitbucket Pipelines or Jenkins
├─ Self-hosted Git → Jenkins or GitLab CI (self-hosted)
└─ Multiple platforms → Jenkins (universal)

Q2: Complexity?
├─ Simple (build + test + deploy) → GitHub Actions or GitLab CI
├─ Complex (many stages, approvals) → Jenkins or CircleCI
└─ Highly customized → Jenkins

Recommendation: GitHub Actions (if GitHub repo) or GitLab CI (if GitLab repo)
```

---

#### Decision Tree 5: Testing Framework Selection

**Python**:
- **Unit/Integration**: pytest (de facto standard)
- **Web API**: pytest + httpx or requests
- **BDD**: behave or pytest-bdd

**JavaScript/TypeScript**:
- **Unit/Integration**: Jest (React/Node) or Vitest (Vite projects)
- **E2E Web**: Playwright or Cypress
- **API**: Supertest + Jest

**Go**:
- **Unit**: Built-in `testing` package
- **HTTP**: `httptest` (built-in)
- **Advanced**: testify (assertions), ginkgo/gomega (BDD)

**Rust**:
- **Unit**: Built-in `#[test]`
- **Integration**: `tests/` directory
- **Property-based**: proptest

---

#### Autonomous Selection Example (Complete)

**Scenario**: User requests "Build a web API for habit tracking with user authentication, deployed on AWS Lambda, needs to be done in 6 weeks."

**Claude's autonomous technology decisions**:

```markdown
## Autonomous Technology Selections

### Language: Python 3.11+
**Decision Tree Used**: Decision Tree 1 (Language Selection) → Web APIs branch
**Rationale**:
- Project type: Web API (REST endpoints)
- Performance: Moderate throughput expected (habit tracking = <1K users initially)
- Deployment: AWS Lambda (Python well-supported, fast cold starts)
- Timeline: 6 weeks (rapid development needed → Python or Node.js)
- Choice: Python (mature API frameworks, easier authentication libraries)

### Framework: FastAPI
**Decision Tree Used**: Decision Tree 2 (Python Web Frameworks)
**Rationale**:
- Microservice / API only (no admin panel needed)
- Async support (good for Lambda)
- Auto-generated OpenAPI docs (useful for development)
- Modern Python 3.11+ features (type hints, async/await)
- Alternative considered: Flask (rejected: FastAPI more modern, better async)

### Database: PostgreSQL (Amazon RDS)
**Decision Tree Used**: Decision Tree 3 (Database Selection) → Structured Data
**Rationale**:
- Data type: Structured (users, habits, entries → clear relationships)
- Scale: Medium (starting small, may grow → SQLite too limited)
- ACID: Important (user data, authentication → consistency matters)
- Deployment: Cloud-hosted (AWS Lambda → can't use local SQLite)
- Choice: PostgreSQL on RDS (managed, serverless option available)
- Alternative considered: DynamoDB (rejected: relational data model fits SQL better)

### Testing: pytest
**Decision Tree Used**: Decision Tree 5 (Testing Framework)
**Rationale**: Python standard for testing

### Deployment: AWS Lambda + API Gateway
**Rationale**: User specified AWS Lambda

## Summary
- **Stack**: Python 3.11 + FastAPI + PostgreSQL (RDS) + pytest
- **Deployment**: AWS Lambda + API Gateway + RDS
- **Estimated effort**: 8-12 sessions (breakdown in decomposition plan)
```

**This decision set is now documented** and Claude can proceed with implementation autonomously.

---

### Technology Selection Completion

**After Step 0.7 or 0.7A, verify**:
- [ ] ✅ All technology choices made (explicitly or via decision trees)
- [ ] ✅ Choices documented in REQUIREMENTS.md or memory/requirements.md
- [ ] ✅ Rationale provided for each choice (why this vs alternatives)
- [ ] ✅ Stack is compatible (language + framework + database + deployment work together)

**Output**: Complete, documented technology stack ready for framework setup

**Before proceeding to framework setup, verify**:

- [ ] ✅ Problem statement written (Step 0.1)
- [ ] ✅ Core requirements listed (5+ items minimum) (Step 0.2)
- [ ] ✅ Constraints identified (Step 0.3)
- [ ] ✅ Success criteria defined (Step 0.4)
- [ ] ✅ Risks assessed (Step 0.5)
- [ ] ✅ Rough decomposition completed (Step 0.6)
- [ ] ✅ Technology decisions made (Step 0.7) OR acknowledged as "decide later"

**Where to save this information**:
- Temporary file: `REQUIREMENTS.md` in project root (can delete after setup)
- OR: In project documentation: `docs/requirements.md`
- OR: In framework memory: `memory/requirements.md` (preferred - preserves requirements for Claude)

---

### Project Readiness (Final Check)

**Now verify you're ready for framework setup**:
- [ ] Project directory created
- [ ] Requirements documented (Phase 0 above completed)
- [ ] Technology stack decided (or explicitly deferred)
- [ ] Time allocated (30-45 min for framework setup)

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

## Lightweight Mode (For Small Projects)

**When to use**: Projects with <20 modules OR <5,000 lines of code OR <2 weeks duration
**Benefits**: Reduced setup overhead, simplified workflow, faster start
**Trade-off**: Less automation, manual tracking (but still context-safe)

### Is Lightweight Mode Right for You?

**Use Lightweight Mode if**:
- [ ] Project has <20 modules (or <10 sections for writing)
- [ ] Estimated <5,000 lines of code (or <15,000 words for writing)
- [ ] Solo developer (not team collaboration)
- [ ] Duration: <2 weeks full-time (or <1 month part-time)
- [ ] Low complexity (straightforward requirements, few dependencies)

**Use Full Framework if**:
- [ ] Project has >20 modules
- [ ] Multiple developers collaborating
- [ ] Duration: >2 weeks
- [ ] High complexity (many dependencies, integration points)
- [ ] Critical project (must not lose work)

### Lightweight Setup (5 minutes)

**Step 1: Minimal Directory Structure**

```bash
# Create only essential directories
mkdir -p .claude docs logs

# Initialize git
git init
```

**Step 2: Create Minimal CLAUDE.md**

```bash
cat > CLAUDE.md << 'EOF'
# [Project Name]

**Type**: [Coding/Research/Design/etc.]
**Size**: Small (<20 modules)
**Mode**: Lightweight (simplified framework)

## Project Goal

[1-2 sentences: What are we building?]

## Modules/Sections

1. [Module 1 name] - [status: pending/in-progress/complete]
2. [Module 2 name] - [status: pending/in-progress/complete]
3. [Module 3 name] - [status: pending/in-progress/complete]
...

## Current Work

**Module**: [Current module name]
**Status**: [Brief status]
**Next**: [Next task]

## Rules

1. **Context Exit**: Stop at 35% context
2. **Checkpoints**: Commit after each module complete
3. **Recovery**: Update "Current Work" section before ending session
4. **Module Size**: Max 250 lines or 1 hour per module

## Commands

**Test**: [your test command]
**Run**: [your run command]
EOF
```

**Step 3: Create Simple Recovery System**

```bash
# Create docs directory for notes
mkdir -p docs/notes

# Optional: Create lightweight state file
cat > docs/progress.md << 'EOF'
# Project Progress

## Modules Complete
- [ ] Module 1
- [ ] Module 2
- [ ] Module 3

## Current Session
**Started**: [date/time]
**Module**: [current module]
**Progress**: [what's done]

## Next Session
**Start with**: [module name or task]
**Remember**: [any important context]
EOF
```

**Duration**: 5 minutes

---

### Lightweight Workflow

**Session Start**:
1. Read CLAUDE.md "Current Work" section (30 seconds)
2. Check docs/progress.md (if used)
3. Start working on current module

**During Work**:
1. Write code/content (no state file updates needed)
2. Monitor context (use /context command or manual estimate)
3. Commit when module complete: `git add . && git commit -m "Module X complete"`

**Session End** (at 30-35% context):
1. **Update CLAUDE.md "Current Work" section**:
   ```markdown
   ## Current Work

   **Module**: Module 3 - User authentication
   **Status**: 70% complete - login done, logout pending
   **Next**: Implement logout function, then test both
   ```
2. **Commit** (if module complete): `git add . && git commit -m "Module X: [description]"`
3. **Quick note** (if useful): Add to docs/notes/[date].md

**Recovery** (Next Session):
1. Read CLAUDE.md "Current Work" - immediate context
2. `git log --oneline -3` - see recent commits
3. Continue where you left off

---

### What Lightweight Mode Skips

**Not included** (vs full framework):
- ❌ Automated state files (master_state.json, module_state.json)
- ❌ Context estimation scripts
- ❌ Recovery prompt generation
- ❌ AUTONOMOUS_MODE.md
- ❌ Detailed validation tests
- ❌ External memory system

**Still included** (essential):
- ✅ 35% exit threshold (critical)
- ✅ Git checkpoints after modules
- ✅ CLAUDE.md instructions
- ✅ Manual recovery (via CLAUDE.md updates)
- ✅ Module-based workflow

**Result**: 80% less setup, 90% of the safety

---

### When to Upgrade to Full Framework

**Consider upgrading if**:
1. Project grows beyond 20 modules
2. You're losing track of progress (need automated state)
3. Recovery takes >5 minutes (need better recovery prompts)
4. Team collaboration starts (need formal state tracking)
5. Context management becomes challenging

**How to upgrade**:
1. Read 02_SETUP_GUIDE.md "Manual Setup" section
2. Add missing directories (data/state/, memory/, etc.)
3. Create state files (master_state.json)
4. Set up automated scripts
5. Migrate progress from CLAUDE.md to state files

**Migration time**: 15-20 minutes

---

### Lightweight Mode Example

**Scenario**: Simple CLI tool (5 modules, 1,500 lines, 1 week project)

**Setup** (5 min):
```bash
mkdir my-cli-tool
cd my-cli-tool
git init
mkdir -p .claude docs logs

# Create CLAUDE.md with 5 modules listed
# Module 1: Argument parsing
# Module 2: Config file loading
# Module 3: Core logic
# Module 4: Output formatting
# Module 5: Error handling
```

**Implementation** (5 sessions over 1 week):
```
Session 1 (1 hour, 35% context):
- Module 1: Argument parsing (250 lines) ✅
- Commit: "Module 1: Argument parsing complete"
- Update CLAUDE.md: "Current Work: Module 2 - Config loading"

Session 2 (1 hour, 33% context):
- Module 2: Config file loading (180 lines) ✅
- Module 3: Core logic START (120 lines of 300)
- Commit: "Module 2 complete, Module 3 started"
- Update CLAUDE.md: "Module 3 - 40% complete, main logic done, edge cases pending"

Session 3 (1 hour, 34% context):
- Module 3: Core logic COMPLETE (180 more lines) ✅
- Commit: "Module 3: Core logic complete"
- Update CLAUDE.md: "Module 4 - Output formatting"

Session 4 (1 hour, 32% context):
- Module 4: Output formatting (200 lines) ✅
- Module 5: Error handling (150 lines) ✅
- Commit: "Modules 4 & 5 complete"
- Update CLAUDE.md: "Project complete"

Session 5 (45 min, 25% context):
- Testing, bug fixes, documentation
- Commit: "Testing complete, v1.0 ready"
```

**Total time**: ~5 hours implementation + 5 min setup = 5 hours
**Context crashes**: 0
**Sessions needed**: 5 (vs 10-15 without framework)

---

### Lightweight Mode Checklist

**Before starting, verify**:
- [ ] ✅ Project qualifies (<20 modules, <2 weeks)
- [ ] ✅ CLAUDE.md created with module list
- [ ] ✅ Git initialized
- [ ] ✅ Understand 35% exit threshold
- [ ] ✅ Know how to update "Current Work" section

**After each session, verify**:
- [ ] ✅ CLAUDE.md "Current Work" updated (30 seconds)
- [ ] ✅ Commit created if module complete
- [ ] ✅ Context stayed below 35% (or exited)

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

**B) Infrastructure or configuration (deployed, not executed locally)**
→ **Project Type: INFRASTRUCTURE**
→ Go to: Question 2-A

**C) Design or architecture (specifications, not implementation)**
→ **Project Type: DESIGN**
→ Go to: Question 2-B

**D) Improvement to existing system (refactor, optimize, secure)**
→ **Project Type: MAINTENANCE**
→ Go to: Question 2-C

**E) Written document (paper, book, documentation)**
→ **Project Type: NON-CODING**
→ Go to: Question 2-D

**F) Both significant code AND significant writing**
→ **Project Type: HYBRID**
→ Go to: [Hybrid Projects](#hybrid-projects-separate-approach)

---

#### Question 2-A: What kind of infrastructure? (Infrastructure Projects)

**A) Infrastructure as Code (IaC) - cloud resources, servers**
→ **Sub-type: IAC**
→ Examples: Terraform, CloudFormation, Pulumi, Ansible
→ Templates: `project_types/infrastructure/iac/`
→ Go to: [Infrastructure Project Setup](#infrastructure-project-characteristics)

**B) Container/Orchestration - deployment configurations**
→ **Sub-type: CONTAINER_ORCHESTRATION**
→ Examples: Kubernetes manifests, Docker Compose, Helm charts
→ Templates: `project_types/infrastructure/containers/`
→ Go to: [Infrastructure Project Setup](#infrastructure-project-characteristics)

**C) CI/CD Pipelines - automation workflows**
→ **Sub-type: CI_CD**
→ Examples: GitHub Actions, GitLab CI, Jenkins pipelines
→ Templates: `project_types/infrastructure/cicd/`
→ Go to: [Infrastructure Project Setup](#infrastructure-project-characteristics)

**D) Configuration Management - app config, feature flags**
→ **Sub-type: CONFIGURATION**
→ Examples: Config files, environment setup
→ Templates: Use `project_types/coding/` (lightweight)
→ Go to: [Coding Project Setup](#coding-project-characteristics)

---

#### Question 2-B: What kind of design? (Design Projects)

**A) System Architecture - high-level system design**
→ **Sub-type: SYSTEM_ARCHITECTURE**
→ Deliverables: Architecture diagrams, ADRs, component specs
→ Templates: `project_types/design/architecture/`
→ Go to: [Design Project Setup](#design-project-characteristics)

**B) Database Schema - data model, relationships**
→ **Sub-type: DATABASE_DESIGN**
→ Deliverables: ERDs, migration scripts, seed data
→ Templates: `project_types/design/database/`
→ Go to: [Design Project Setup](#design-project-characteristics)

**C) API Design - endpoints, contracts (before implementation)**
→ **Sub-type: API_DESIGN**
→ Deliverables: OpenAPI/Swagger specs, GraphQL schemas
→ Templates: `project_types/design/api/`
→ Go to: [Design Project Setup](#design-project-characteristics)

**D) UI/UX Design - interfaces, user flows**
→ **Sub-type: UX_DESIGN**
→ Deliverables: Wireframes, mockups, prototypes, design system
→ Templates: `project_types/design/ux/`
→ Go to: [Design Project Setup](#design-project-characteristics)

---

#### Question 2-C: What kind of maintenance? (Maintenance Projects)

**A) Legacy Refactoring - improve existing code without changing behavior**
→ **Sub-type: REFACTORING**
→ Templates: `project_types/maintenance/refactoring/`
→ Go to: [Maintenance Project Setup](#maintenance-project-characteristics)

**B) Performance Optimization - make existing system faster**
→ **Sub-type: PERFORMANCE**
→ Templates: `project_types/maintenance/performance/`
→ Go to: [Maintenance Project Setup](#maintenance-project-characteristics)

**C) Security Hardening - fix vulnerabilities, improve security**
→ **Sub-type: SECURITY**
→ Templates: `project_types/maintenance/security/`
→ Go to: [Maintenance Project Setup](#maintenance-project-characteristics)

**D) Technical Debt Reduction - improve code quality, reduce debt**
→ **Sub-type: TECH_DEBT**
→ Templates: `project_types/maintenance/tech_debt/`
→ Go to: [Maintenance Project Setup](#maintenance-project-characteristics)

---

#### Question 2-D: What kind of document? (Non-Coding Projects)

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

### Infrastructure Project Characteristics

**Use infrastructure templates if your project includes**:
- Configuration files that define infrastructure (not execute)
- Declarative specifications (describe desired state)
- Deployment automation
- Resource provisioning
- Environment management

**Examples**:
- Terraform/CloudFormation/Pulumi (cloud resources)
- Kubernetes manifests (container orchestration)
- Ansible playbooks (configuration management)
- Docker Compose files (local orchestration)
- CI/CD pipelines (GitHub Actions, GitLab CI)

**Work unit sizing**:
- **IaC**: 1 resource group OR 1 service OR 10-15 resources (whichever smaller)
  - Example: "VPC + subnets + security groups" = 1 module
  - Example: "S3 bucket + IAM policies" = 1 module
- **Containers**: 1 deployment + service OR 1 namespace
  - Example: "Backend deployment + load balancer" = 1 module
- **CI/CD**: 1 job OR 1 stage (5-10 steps)
  - Example: "Build + test" job = 1 module

**Validation**:
- **IaC**: `terraform plan` (no errors), `terraform validate`, dry-run tests
- **Containers**: `kubectl dry-run`, `helm lint`, manifest validation
- **CI/CD**: Syntax validation, test run in isolated environment

**State tracking**: Modules (resource groups) complete, validation passing

**Special considerations**:
- State management conflicts (Terraform state, K8s state)
- Idempotency testing (can run multiple times safely?)
- Drift detection (infrastructure matches code?)

---

### Design Project Characteristics

**Use design templates if your project includes**:
- Specifications created before implementation
- Diagrams and visual artifacts
- Decision documentation
- Design review and iteration
- Non-executable deliverables

**Examples**:
- System architecture (C4 diagrams, component diagrams, ADRs)
- Database schema (ERDs, normalization, migration plans)
- API specifications (OpenAPI/Swagger, GraphQL schemas)
- UI/UX design (wireframes, mockups, prototypes, design systems)

**Work unit sizing**:
- **System Architecture**: 1 component OR 1 subsystem OR 1 ADR
  - Example: "Authentication service architecture" = 1 module
  - Example: "Data storage decision (ADR)" = 1 module
- **Database Design**: 1 entity + relationships OR 3-5 tables
  - Example: "User + Profile + Preferences tables" = 1 module
- **API Design**: 1 resource (all CRUD) OR 5-7 endpoints
  - Example: "/users endpoint (GET, POST, PUT, DELETE)" = 1 module
- **UX Design**: 1 screen + user flow OR 1 component family
  - Example: "Login screen + password reset flow" = 1 module

**Validation**:
- **System Architecture**: Design review checklist, ADR completeness, diagram clarity
- **Database**: Normalization check, relationship validity, migration testability
- **API**: OpenAPI validation, contract testing, consistency check
- **UX**: Usability heuristics, accessibility check, design system adherence

**State tracking**: Design modules complete, reviews passed

**Deliverables per module**:
- Diagrams (PNG/SVG exports)
- Specifications (Markdown/YAML/JSON)
- Decision records (ADRs in markdown)
- Design files (Figma/Sketch links or exports)

**Special considerations**:
- Design iteration (multiple revisions expected)
- Stakeholder review cycles
- Design-to-implementation handoff

---

### Maintenance Project Characteristics

**Use maintenance templates if your project includes**:
- Existing codebase as starting point
- Improvement without new features
- Preservation of existing functionality
- Regression testing critical
- Before/after comparison important

**Examples**:
- Legacy refactoring (improve structure, no behavior change)
- Performance optimization (make faster, same functionality)
- Security hardening (fix vulnerabilities, add protections)
- Technical debt reduction (improve quality metrics)

**Work unit sizing**:
- **Refactoring**: 1 function/class extraction OR 1 pattern application OR 1 file refactor (max 250 lines)
  - Example: "Extract payment processing into PaymentService class" = 1 module
  - Example: "Replace nested conditionals with strategy pattern in OrderProcessor" = 1 module
- **Performance**: 1 bottleneck fix OR 1 algorithm optimization
  - Example: "Optimize N+1 query in user dashboard" = 1 module
  - Example: "Add caching layer to product search" = 1 module
- **Security**: 1 vulnerability fix OR 1 attack vector mitigation
  - Example: "Fix SQL injection in search endpoint" = 1 module
  - Example: "Implement rate limiting on API" = 1 module
- **Tech Debt**: 1 debt item OR 1 code smell elimination
  - Example: "Remove deprecated API usage in auth module" = 1 module

**Validation (Critical for Maintenance)**:
- **ALL existing tests must pass** (before AND after)
- **New tests** for refactored code
- **Regression testing**: Ensure no behavior changes (unless intended)
- **Performance benchmarks**: Before/after comparison (for optimization)
- **Security scans**: Vulnerability scans before/after (for security)
- **Code quality metrics**: Complexity, duplication, coverage improvement

**State tracking**:
- Modules refactored/optimized/secured
- Tests passing (all, not just new)
- Metrics improvement (before/after)

**Special considerations**:
- **Context challenge**: Large existing codebase
  - Use external memory heavily (document existing code in memory/)
  - Don't load entire codebase into context
  - Target specific areas only
- **Risk management**: Higher risk than greenfield
  - Smaller modules (150-200 lines instead of 250)
  - More validation per module
  - Frequent checkpoints
- **Documentation**: Before/after comparison critical
  - Document original behavior
  - Document changes made
  - Document why changes were safe

**Refactoring-specific**:
- **Work unit**: Often smaller than greenfield (150-200 lines)
- **Tests first**: Ensure tests exist before refactoring
- **Incremental**: Small steps, validate frequently
- **Behavior preservation**: Critical constraint

**Performance-specific**:
- **Work unit**: Profile → Fix one bottleneck → Measure
- **Validation**: Benchmarks mandatory (before/after)
- **Tradeoffs**: Document what was traded (memory for speed, etc.)

**Security-specific**:
- **Work unit**: Fix one vulnerability or harden one attack surface
- **Validation**: Security scans, penetration testing
- **Compliance**: May need to document for audits

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

**Coding Projects** (Executable Output):

| Your Project | Primary Output | Code Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|-------------|----------------|----------------|-----------|
| Web API | Executable | High | Low (docs) | CODING | `coding/` |
| CLI Tool | Executable | High | Low (help) | CODING | `coding/` |
| Library/Package | Executable | High | Low (docs) | CODING | `coding/` |
| Mobile App | Executable | High | Low (docs) | CODING | `coding/` |
| Desktop Application | Executable | High | Low (docs) | CODING | `coding/` |

**Infrastructure Projects** (Configuration/Deployed):

| Your Project | Primary Output | Config Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|---------------|----------------|----------------|-----------|
| Terraform/IaC | Infrastructure | High (HCL/YAML) | Low (docs) | INFRASTRUCTURE (IaC) | `infrastructure/iac/` |
| Kubernetes Manifests | Containers | High (YAML) | Low (docs) | INFRASTRUCTURE (K8s) | `infrastructure/containers/` |
| CI/CD Pipelines | Automation | Medium (YAML) | Low (docs) | INFRASTRUCTURE (CI/CD) | `infrastructure/cicd/` |
| Ansible/Config Mgmt | Configuration | High (YAML) | Low (docs) | INFRASTRUCTURE (Config) | `infrastructure/config/` |

**Design Projects** (Specifications):

| Your Project | Primary Output | Design Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|---------------|----------------|----------------|-----------|
| System Architecture | Diagrams + ADRs | High (diagrams) | High (specs) | DESIGN (Architecture) | `design/architecture/` |
| Database Schema | ERDs + Migrations | Medium (SQL) | Medium (docs) | DESIGN (Database) | `design/database/` |
| API Specification | OpenAPI/GraphQL | Medium (YAML/JSON) | Medium (docs) | DESIGN (API) | `design/api/` |
| UI/UX Design | Mockups + Flows | High (design files) | Medium (specs) | DESIGN (UX) | `design/ux/` |

**Maintenance Projects** (Existing Codebase Improvement):

| Your Project | Primary Output | Code Changes | Testing Emphasis | Framework Type | Templates |
|--------------|----------------|--------------|------------------|----------------|-----------|
| Legacy Refactoring | Improved structure | Medium-High | Critical (no behavior change) | MAINTENANCE (Refactor) | `maintenance/refactoring/` |
| Performance Optimization | Faster system | Low-Medium | High (benchmarks required) | MAINTENANCE (Performance) | `maintenance/performance/` |
| Security Hardening | Secured system | Low-Medium | High (security scans) | MAINTENANCE (Security) | `maintenance/security/` |
| Tech Debt Reduction | Quality improvement | Low-Medium | High (metrics improvement) | MAINTENANCE (Tech Debt) | `maintenance/tech_debt/` |

**Non-Coding Projects** (Written Documents):

| Your Project | Primary Output | Code Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|-------------|----------------|----------------|-----------|
| Research Paper | Academic paper | Low (none/figures) | High | RESEARCH | `non_coding/research/` |
| Technical Book | Book manuscript | Low (examples) | High | WRITING (Book) | `non_coding/book/` |
| Documentation | User guides | Low (examples) | High | DOCUMENTATION | `non_coding/documentation/` |
| Grant Proposal | Proposal document | None | High | WRITING (Proposal) | `non_coding/proposal/` |
| Technical Report | Report | Low (data scripts) | High | RESEARCH | `non_coding/research/` |

**Hybrid Projects** (Both Code and Writing):

| Your Project | Primary Output | Code Amount | Writing Amount | Framework Type | Templates |
|--------------|----------------|-------------|----------------|----------------|-----------|
| ML Research | Code + Paper | High (training) | High (paper) | HYBRID | Separate projects |
| Data Analysis Report | Scripts + Report | Medium (analysis) | High (findings) | HYBRID | Separate projects |
| Software + Paper | Implementation + Paper | High (code) | Medium (paper) | HYBRID | Separate projects |
| Book + Code Examples | Book + Codebase | Medium (examples) | High (manuscript) | HYBRID | Separate projects |

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
