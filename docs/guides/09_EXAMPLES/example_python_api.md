# Example: Python FastAPI Web API

**Project**: REST API for task management
**Language**: Python 3.11+ with FastAPI
**Duration**: 6-8 hours (6 modules across 2-3 sessions)
**Database**: PostgreSQL
**Framework**: Context-Preserving v3.0

---

## Project Overview

**What we're building**: A task management API with user authentication, CRUD operations, and search.

**Endpoints**:
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /tasks` - List tasks (paginated, filtered)
- `POST /tasks` - Create task
- `GET /tasks/{id}` - Get task details
- `PUT /tasks/{id}` - Update task
- `DELETE /tasks/{id}` - Delete task

**Features**:
- JWT authentication
- Input validation with Pydantic
- Database migrations with Alembic
- 100% test coverage
- OpenAPI documentation

---

## Framework Setup (30 minutes)

### Step 1: Initialize Framework

```bash
cd ~/projects/task_api
python scripts/setup_framework.py --interactive

# Prompts:
# Project name? task_api
# Project type? coding
# Language? python
# Project kind? web_api

# Output: Framework files created
```

**Or manual setup**:
```bash
cd ~/projects/task_api

# Copy framework files
cp -r ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp -r ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md
# [etc. - see 02_SETUP_GUIDE.md]

# Customize
vi CLAUDE.md  # Set project name, test command
vi AUTONOMOUS_MODE.md  # Set STATUS: ACTIVE, scope
```

### Step 2: Define Project Structure

**Edit**: `ARCHITECTURE.md`

```markdown
# Task API Architecture

## Technology Stack
- Language: Python 3.11+
- Framework: FastAPI 0.104+
- Database: PostgreSQL 15
- ORM: SQLAlchemy 2.0
- Migrations: Alembic
- Testing: pytest
- Auth: JWT with python-jose

## Module Breakdown

### Module 1.1: Database Connection & Models (250 lines, 1 hour)
### Module 1.2: Authentication (JWT) (240 lines, 1 hour)
### Module 1.3: Task CRUD Operations (230 lines, 1 hour)
### Module 1.4: API Routes (220 lines, 1 hour)
### Module 1.5: Input Validation (210 lines, 1 hour)
### Module 1.6: Integration Tests (200 lines, 1 hour)
```

### Step 3: Create Implementation Plan

**Edit**: `docs/IMPLEMENTATION_PLAN.md`

```markdown
# Implementation Plan

## Phase 1: Foundation (Session 1, 3 hours)
- Module 1.1: Database & Models
- Module 1.2: Authentication
- Module 1.3: Task CRUD
[Checkpoint at 35%]

## Phase 2: API Layer (Session 2, 2 hours)
- Module 1.4: API Routes
- Module 1.5: Input Validation
[Checkpoint at 35%]

## Phase 3: Testing (Session 3, 2 hours)
- Module 1.6: Integration Tests
- Final validation
```

### Step 4: Run Validation Tests

```bash
# From 07_TESTING_GUIDE.md
# Run tests 1-6 sequentially

# Test 1: AUTONOMOUS_MODE Recognition
# ... [all 6 tests]

# Result: ✅ 6/6 tests passed
```

**Framework is ready!**

---

## Session 1: Modules 1.1-1.3 (3 hours, 30% context)

### Session Start

**Time**: 9:00 AM
**Starting context**: 0%

**Prompt**:
```
Start implementing Task API.

Project: task_api (Python FastAPI)
Framework: Context-Preserving v3.0
Plan: docs/IMPLEMENTATION_PLAN.md

Check AUTONOMOUS_MODE.md and begin Module 1.1.
```

**Claude response**:
```
✅ AUTONOMOUS_MODE active - operating autonomously

Reading master_state.json...
- Current phase: setup
- Modules pending: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6

Reading IMPLEMENTATION_PLAN.md... (Module 1.1 section only)

Starting Module 1.1: Database & Models
```

---

### Module 1.1: Database & Models (60 minutes)

**Files created**:
- `core/database.py` (80 lines) - Connection management
- `core/models.py` (120 lines) - SQLAlchemy models (User, Task)
- `tests/test_database.py` (50 lines) - Database tests

**Implementation**:

`core/database.py`:
```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@localhost/taskdb")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

`core/models.py`:
```python
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    tasks = relationship("Task", back_populates="owner")

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String)
    completed = Column(Boolean, default=False)
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    owner = relationship("User", back_populates="tasks")
```

**Tests**:
```python
def test_database_connection():
    from core.database import engine
    assert engine is not None

def test_user_model():
    from core.models import User
    user = User(email="test@example.com", hashed_password="hash")
    assert user.email == "test@example.com"

# [3 more tests]
```

**Run tests**:
```bash
pytest tests/test_database.py -v
# Result: 5/5 passing
```

**Update state**:
```json
// data/state/module_1.1_state.json
{
  "module": "1.1",
  "status": "complete",
  "functions_implemented": ["get_db", "User", "Task"],
  "tests_written": 5,
  "tests_passing": 5
}
```

**Git commit**:
```
[Session 1] Module 1.1: Database & Models - COMPLETE

Changes:
- core/database.py (80 lines)
- core/models.py (120 lines)
- tests/test_database.py (50 lines)

Tests: 5/5 passing
Progress: 1/6 modules complete

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Context check**: 12% (24K tokens)

**Continue to Module 1.2**

---

### Module 1.2: Authentication (60 minutes)

**Files created**:
- `core/auth.py` (160 lines) - JWT token management
- `core/security.py` (80 lines) - Password hashing
- `tests/test_auth.py` (70 lines) - Auth tests

**Key functions**:
- `hash_password(password: str) -> str`
- `verify_password(plain: str, hashed: str) -> bool`
- `create_access_token(data: dict) -> str`
- `verify_token(token: str) -> dict`

**Tests**: 7 tests, all passing

**Git commit**: Module 1.2 complete

**Context check**: 23% (46K tokens)

**Continue to Module 1.3**

---

### Module 1.3: Task CRUD Operations (60 minutes)

**Files created**:
- `core/crud.py` (230 lines) - Database operations
- `tests/test_crud.py` (80 lines) - CRUD tests

**Key functions**:
- `create_task(db, task_data, user_id) -> Task`
- `get_task(db, task_id, user_id) -> Task`
- `get_tasks(db, user_id, skip, limit) -> List[Task]`
- `update_task(db, task_id, task_data, user_id) -> Task`
- `delete_task(db, task_id, user_id) -> bool`

**Tests**: 10 tests, all passing

**Git commit**: Module 1.3 complete

**Context check**: 34% (68K tokens)

**Decision**: Approaching 35% threshold, end session after checkpoint

---

### Session 1 End (3:00 PM)

**Checkpoint box**:
```
═══════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════

✅ Modules completed: 1.1, 1.2, 1.3
✅ Tests: 22/22 passing (100%)
✅ Context: 68K tokens (34%)
✅ Git commits: 3
✅ All work saved

Status: Phase 1 complete, approaching threshold
Next: Module 1.4 (API Routes)

═══════════════════════════════════════════════════════════
```

**Recovery prompt created**: `docs/recovery_prompts/SESSION_1_PHASE1.md`

**Next steps displayed**:
```
███████████████████████████████████████████████████████████
🎯 NEXT STEPS FOR YOU
███████████████████████████████████████████████████████████

When you start Session 2:

1. Paste this prompt:
```
Resume Task API implementation from Session 1.

Recovery: docs/recovery_prompts/SESSION_1_PHASE1.md
Git: abc1234
Next module: 1.4 (API Routes)

Continue per 04_CORE_WORKFLOW.md
```

2. Verify state:
   - ✅ Modules 1.1-1.3 complete
   - ✅ 22/22 tests passing
   - ✅ Git clean

3. Implement Module 1.4: API Routes

███████████████████████████████████████████████████████████
[END OF RESPONSE]
███████████████████████████████████████████████████████████
```

---

## Session 2: Modules 1.4-1.5 (2 hours, 30% context)

### Session Start

**Time**: Next day, 10:00 AM
**Starting context**: 0% (new session)

**Prompt** (copy-pasted):
```
Resume Task API implementation from Session 1.

Recovery: docs/recovery_prompts/SESSION_1_PHASE1.md
Git: abc1234
Next module: 1.4 (API Routes)

Continue per 04_CORE_WORKFLOW.md
```

**Claude reads** (5K tokens):
- Recovery prompt (2K)
- master_state.json (1K)
- Module 1.4 section from IMPLEMENTATION_PLAN.md (2K)

**Does NOT re-read**: All code from Session 1 (would be 50K+ tokens)

**Claude response**:
```
✅ Resuming from Session 1

State loaded:
- Modules complete: 1.1, 1.2, 1.3
- Tests: 22/22 passing
- Next: Module 1.4 (API Routes)

Starting Module 1.4...
```

---

### Module 1.4: API Routes (60 minutes)

**Files created**:
- `api/routes.py` (220 lines) - FastAPI endpoints
- `tests/test_api.py` (90 lines) - API endpoint tests

**Key endpoints**:
```python
@app.post("/auth/register")
@app.post("/auth/login")
@app.get("/tasks")
@app.post("/tasks")
@app.get("/tasks/{task_id}")
@app.put("/tasks/{task_id}")
@app.delete("/tasks/{task_id}")
```

**Tests**: 12 tests (integration with TestClient)

**Git commit**: Module 1.4 complete

**Context check**: 18% (36K tokens)

---

### Module 1.5: Input Validation (60 minutes)

**Files created**:
- `api/schemas.py` (210 lines) - Pydantic models
- `tests/test_schemas.py` (60 lines) - Validation tests

**Key schemas**:
```python
class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = None

class TaskResponse(BaseModel):
    id: int
    title: str
    completed: bool
    created_at: datetime
```

**Tests**: 8 tests, all passing

**Git commit**: Module 1.5 complete

**Context check**: 32% (64K tokens)

**Decision**: Good stopping point, end session

---

### Session 2 End

**Recovery prompt created**: `SESSION_2_PHASE2.md`

**Modules remaining**: 1.6 (Integration Tests)

---

## Session 3: Module 1.6 & Validation (2 hours, 25% context)

### Module 1.6: Integration Tests (90 minutes)

**Files created**:
- `tests/test_integration.py` (200 lines) - End-to-end tests

**Tests**:
```python
def test_full_user_workflow():
    # Register → Login → Create task → Get task → Update → Delete
    # All in one test

def test_authentication_required():
    # Verify protected endpoints require auth

def test_authorization():
    # Verify users can only access own tasks

# [10 more integration tests]
```

**Result**: 13 tests, all passing

**Total test count**: 55 tests, 100% passing

---

### Final Validation (30 minutes)

**Run all tests**:
```bash
pytest tests/ -v --cov=core --cov=api
# Result: 55 passed, 98% coverage
```

**Validate API**:
```bash
python -m uvicorn api.main:app
# Visit: http://localhost:8000/docs
# OpenAPI docs working
```

**Validate framework**:
```bash
python scripts/validate_state.py
# All state files valid
```

**Git commit**:
```
[Session 3] Module 1.6 & Project Complete - v1.0

Changes:
- tests/test_integration.py (200 lines)
- All 6 modules implemented
- 55 tests, 100% passing
- 98% code coverage
- OpenAPI documentation

Project complete and production-ready.

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Project Complete!

### Final Statistics

**Duration**: 7 hours actual (6-8 estimated)
**Sessions**: 3 (2-3 estimated)
**Context crashes**: 0
**Recovery time**: < 2 min per session
**Tests**: 55, all passing
**Coverage**: 98%

### Modules Completed

1. ✅ Module 1.1: Database & Models (250 lines, 5 tests)
2. ✅ Module 1.2: Authentication (240 lines, 7 tests)
3. ✅ Module 1.3: Task CRUD (230 lines, 10 tests)
4. ✅ Module 1.4: API Routes (220 lines, 12 tests)
5. ✅ Module 1.5: Input Validation (210 lines, 8 tests)
6. ✅ Module 1.6: Integration Tests (200 lines, 13 tests)

**Total**: 1,350 lines of code, 55 tests

### Framework Benefits Demonstrated

**Without framework** (estimated):
- Sessions: 6-8 (context crashes)
- Recovery time: 30+ min per crash
- Total waste: 3-4 hours

**With framework**:
- Sessions: 3 (planned exits)
- Recovery time: < 2 min
- Total waste: < 10 min

**Savings**: 3-4 hours (40-50% efficiency gain)

---

## Lessons Learned

### What Worked Well

1. **Micro-modules**: 200-250 lines per module = perfect size
2. **35% threshold**: Never hit context issues
3. **State files**: Resume in < 2 min every time
4. **Progressive testing**: Caught issues early
5. **Git commits**: Clear history, easy to review

### What to Watch For

1. **Integration tests consume more context**: Module 1.6 used more tokens than expected (debugging test failures)
2. **Database setup**: External dependency (PostgreSQL) required additional setup time
3. **First module slowest**: Module 1.1 took 75 min (vs. 60 estimated) due to setup

### Recommendations

1. **Start with smallest module**: Build confidence
2. **Test continuously**: Don't batch all tests to end
3. **Use external memory**: Save exploration notes to `data/scratch/`
4. **Trust the 35% threshold**: Don't push to 40%

---

## Next Steps for Your Project

**To replicate this pattern**:

1. **Copy framework setup** from steps above
2. **Adapt module sizes** to your language (JavaScript modules might be 300-400 lines due to verbosity)
3. **Follow same session pattern**: Modules → Checkpoint → Resume
4. **Track your metrics**: Compare to estimates

**For larger projects**:
- 10-15 modules: 4-5 sessions
- 20-30 modules: 8-10 sessions
- 50+ modules: 15-20 sessions

All with consistent context management!

---

**Example version**: 3.0
**Created**: January 2025
**Project**: Task Management API (FastAPI/Python)
