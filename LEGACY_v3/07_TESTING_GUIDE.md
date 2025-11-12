# Testing Guide - Progressive Validation

**How to validate framework setup with 6 sequential tests**

**Duration**: 10-15 minutes total (2-3 min per test)
**Token cost per test**: ~2K tokens
**When to use**: After framework setup, before starting project work

---

## IMPORTANT: Test One at a Time

**DO NOT run all tests in one session.**

**Pattern**:
1. Run Test 1
2. If pass → proceed to Test 2
3. If fail → fix issue, re-run Test 1
4. Repeat for each test

**Why**: Each test is independent, running all at once wastes context.

---

## Test 1: AUTONOMOUS_MODE Recognition

### Purpose
Verify Claude recognizes AUTONOMOUS_MODE.md and operates autonomously.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 1: Check if AUTONOMOUS_MODE.md exists and is ACTIVE.

Steps:
1. Check if file exists: AUTONOMOUS_MODE.md
2. Read the STATUS line
3. Display status
4. If ACTIVE: Confirm autonomous operation enabled
```

### Expected Output

```
✅ Test 1: AUTONOMOUS_MODE Recognition

File: AUTONOMOUS_MODE.md
Status: ACTIVE
Permission granted: [date]
Scope: [project scope]

✅ AUTONOMOUS_MODE active - operating autonomously
✅ Will not ask for permission for:
   - Creating files in specifications
   - Running tests
   - Git commits
   - Installing packages in requirements

Test 1: PASSED
```

### If Test Fails

**Symptom**: File not found OR STATUS not ACTIVE

**Fix**:
```bash
# Check file exists
ls -la AUTONOMOUS_MODE.md

# If missing, copy template
cp 03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md

# Edit file, set:
STATUS: ACTIVE
PERMISSION GRANTED: [today's date]
```

**Re-run Test 1** after fix.

---

## Test 2: State File Updates

### Purpose
Verify Claude can update state files correctly.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 2: Update data/state/master_state.json

Steps:
1. Read current master_state.json
2. Update current_phase to "testing"
3. Add "test_module" to modules_in_progress
4. Update last_update timestamp
5. Display updated content
6. Verify JSON is valid
```

### Expected Output

```
✅ Test 2: State File Updates

Before:
{
  "current_phase": "setup",
  "modules_in_progress": [],
  ...
}

After:
{
  "current_phase": "testing",
  "modules_in_progress": ["test_module"],
  "last_update": "2025-01-11T16:45:00Z",
  ...
}

✅ File updated successfully
✅ JSON is valid
✅ Timestamp is current

Test 2: PASSED
```

### If Test Fails

**Symptom**: File not found OR JSON invalid OR update failed

**Fix**:
```bash
# Check file exists
cat data/state/master_state.json

# If missing or invalid, recreate from template
# For coding project:
cat > data/state/master_state.json <<EOF
{
  "project": "test_project",
  "version": "0.1.0",
  "project_type": "coding",
  "current_phase": "setup",
  "current_module": null,
  "modules_complete": [],
  "modules_in_progress": [],
  "modules_pending": [],
  "last_update": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Verify valid JSON
python -m json.tool data/state/master_state.json
```

**Re-run Test 2** after fix.

---

## Test 3: Checkpoint Box Display

### Purpose
Verify Claude displays state tracking checkpoint boxes (RULE 15).

### Instructions for Claude Code

**Prompt to paste**:
```
Test 3: Display a STATE TRACKING CHECKPOINT box per RULE 15.

Use these placeholder values:
- Operation: "test_operation"
- Context: 15K tokens (7.5%)
- Status: SAFE
- Git: test123
- Operations: 3

Display the checkpoint box exactly as specified in rules/CLAUDE.md RULE 15.
```

### Expected Output

```
═══════════════════════════════════════════════════════════
📊 STATE TRACKING CHECKPOINT (AUTOMATIC)
═══════════════════════════════════════════════════════════

✅ Operation logged: test_operation → logs/operation_log.txt
✅ State updated: data/state/master_state.json (timestamp: 16:45:23)
✅ Context tracked: 15K tokens (7.5%)
✅ Threshold check: SAFE
✅ Git status: test123

Next threshold: 35% at 70K tokens
Operations this session: 3

═══════════════════════════════════════════════════════════

✅ Test 3: PASSED
```

### If Test Fails

**Symptom**: No checkpoint box OR wrong format OR missing elements

**Fix**:
```
Check rules/CLAUDE.md RULE 15 has the exact template.

If RULE 15 is missing or wrong:
1. Copy from 03_TEMPLATES/rules_CLAUDE.md.template
2. Ensure RULE 15 section is complete
3. Save file
```

**Re-run Test 3** after fix.

---

## Test 4: Git Commit Protocol

### Purpose
Verify git commits follow framework format.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 4: Create test file and commit with framework format.

Steps:
1. Create file: test_framework.txt with content "Framework test"
2. Git add file
3. Git commit using the framework's commit message format from RULE 16
   Message should include:
   - Session/module identifier
   - Changes description
   - Progress indicator
   - Claude Code attribution
   - Co-authored-by line
4. Display commit message
5. Show git log entry
```

### Expected Output

```
✅ Test 4: Git Commit Protocol

File created: test_framework.txt

Commit message:
─────────────────────────────────────────
[Test Session] Framework validation

Changes:
- test_framework.txt (test file)

Status: Framework operational
Progress: Testing in progress

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
─────────────────────────────────────────

Git log:
abc1234 [Test Session] Framework validation

✅ Commit successful
✅ Format follows RULE 16
✅ Attribution included

Test 4: PASSED
```

### If Test Fails

**Symptom**: Commit failed OR wrong format OR missing attribution

**Fix**:
```bash
# Check git is initialized
git status

# If not initialized:
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Check RULE 16 in rules/CLAUDE.md has commit template
# If missing, copy from template
```

**Re-run Test 4** after fix.

---

## Test 5: Recovery Prompt Generation

### Purpose
Verify Claude can create recovery prompts.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 5: Create test recovery prompt.

Steps:
1. Generate recovery prompt in: docs/recovery_prompts/TEST_SESSION.md
2. Use template from: docs/recovery_prompts/SESSION_TEMPLATE.md
3. Include all required sections:
   - Session ID
   - Git commit
   - Context percentage
   - Completed items
   - Next steps
   - Recovery instructions
4. Display created prompt
5. Verify file exists
```

### Expected Output

```
✅ Test 5: Recovery Prompt Generation

Created: docs/recovery_prompts/TEST_SESSION.md

Content:
─────────────────────────────────────────
# Test Session Recovery

**Git commit**: abc1234
**Context**: 7.5%
**Status**: Testing

## Completed:
- Test 1-4 passed

## Next:
- Test 5-6

## Recovery Instructions:
Paste in next session:
```
Resume testing from Test 5.
Recovery prompt: docs/recovery_prompts/TEST_SESSION.md
```
─────────────────────────────────────────

✅ File created: docs/recovery_prompts/TEST_SESSION.md
✅ Template structure followed
✅ All sections present

Test 5: PASSED
```

### If Test Fails

**Symptom**: File not created OR wrong structure OR missing sections

**Fix**:
```bash
# Check directory exists
ls -la docs/recovery_prompts/

# If missing:
mkdir -p docs/recovery_prompts

# Check template exists
cat docs/recovery_prompts/SESSION_TEMPLATE.md

# If template missing, copy from 03_TEMPLATES/
```

**Re-run Test 5** after fix.

---

## Test 6: Context Threshold Simulation

### Purpose
Verify Claude responds correctly to high context usage.

### Instructions for Claude Code

**Prompt to paste**:
```
Test 6: Simulate context at 36% (above 35% critical threshold).

Question: What should happen per rules/CLAUDE.md when context exceeds 35%?

Display:
1. What RULE 15 says about this
2. What actions are required
3. Simulate those actions (don't actually exit, just show what would happen)
```

### Expected Output

```
✅ Test 6: Context Threshold Simulation

Context: 36% (CRITICAL - exceeds 35% threshold)

Per RULE 15:
"If context > 35%: prepare handoff and exit"

Required actions:
1. ✅ Finish current atomic task
2. ✅ Commit all work to git
3. ✅ Update all state files
4. ✅ Create recovery prompt
5. ✅ Display checkpoint box
6. ✅ Display NEXT STEPS section
7. ✅ Exit session

Simulation (what would happen):

[Would display checkpoint box showing 36% context]

[Would create recovery prompt]

[Would display NEXT STEPS with exact recovery instructions]

✅ Claude understands 35% threshold
✅ Correct procedures identified
✅ Would execute graceful exit

Test 6: PASSED
```

### If Test Fails

**Symptom**: Claude doesn't know threshold OR wrong actions

**Fix**:
```
Check rules/CLAUDE.md has:
- RULE 10: Mentions 35% threshold
- RULE 15: Mentions context > 35% behavior
- RULE 17: Mentions NEXT STEPS requirement

If rules missing or incomplete, copy from template.
```

**Re-run Test 6** after fix.

---

## Validation Summary

### After All 6 Tests Pass

**Display summary**:
```
════════════════════════════════════════════════════════════
✅ FRAMEWORK VALIDATION COMPLETE
════════════════════════════════════════════════════════════

Tests passed: 6/6

✅ Test 1: AUTONOMOUS_MODE Recognition
✅ Test 2: State File Updates
✅ Test 3: Checkpoint Box Display
✅ Test 4: Git Commit Protocol
✅ Test 5: Recovery Prompt Generation
✅ Test 6: Context Threshold Simulation

Framework is operational and ready for use.

════════════════════════════════════════════════════════════

Next steps:
1. Read: 04_CORE_WORKFLOW.md (understand daily workflow)
2. Define: Your modules in docs/IMPLEMENTATION_PLAN.md
3. Start: Implement Module 1.1 following workflow
```

### If Any Test Failed

**Do NOT proceed until all tests pass.**

**Pattern**:
1. Identify which test failed
2. Read "If Test Fails" section for that test
3. Apply fix
4. Re-run that test only
5. Continue to next test once passed

---

## Testing Checklist

**Before starting project work**:
- [ ] Test 1: AUTONOMOUS_MODE Recognition - PASSED
- [ ] Test 2: State File Updates - PASSED
- [ ] Test 3: Checkpoint Box Display - PASSED
- [ ] Test 4: Git Commit Protocol - PASSED
- [ ] Test 5: Recovery Prompt Generation - PASSED
- [ ] Test 6: Context Threshold Simulation - PASSED

**All passed?** → Framework ready, proceed to project work

**Any failed?** → Fix and re-test before proceeding

---

## Project-Type-Specific Validation Criteria

**Purpose**: Define what "passing" means for different project types
**When to use**: After each work unit (module/section/scene/page) completion
**Critical**: Validation must pass before marking unit complete and committing

---

### Coding Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Unit tests | Per module | 100% pass, 0 failures | `pytest tests/` or `npm test` or `cargo test` |
| Linting | Per module | 0 errors (warnings OK) | `pylint file.py` or `eslint file.js` or `clippy` |
| Type checking | Per module (typed languages) | 0 errors | `mypy file.py` or `tsc --noEmit` or `cargo check` |
| Integration tests | Per milestone (3-5 modules) | All scenarios pass | `pytest tests/integration/` |
| Code coverage | Per milestone | ≥80% line coverage | `pytest --cov=core tests/` |
| State integrity | Every checkpoint | JSON validates against schema | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Module)**:
```bash
# 1. Run unit tests
pytest tests/test_module_1_1.py
# Expected: All tests pass

# 2. Run linter
pylint core/module_1_1.py
# Expected: Score ≥8.0/10 (or 0 errors)

# 3. Run type checker (if applicable)
mypy core/module_1_1.py
# Expected: Success: no issues found

# 4. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark module complete, commit
```

---

### Research Paper Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Citation completeness | Per section | All [Author, Year] appear in references | `scripts/check_citations.sh` |
| Word count | Per section | Within ±15% of target | `wc -w section.md` and compare to target |
| Reference formatting | Per section | All match journal style (APA/MLA/etc.) | `scripts/validate_references.sh` (or manual check) |
| Figure references | Per section | All "Figure N" exist in figures/ | `grep "Figure [0-9]" section.md` + verify files |
| Table references | Per section | All "Table N" exist | `grep "Table [0-9]" section.md` + verify files |
| Section coherence | Per section | Outline points addressed (manual) | 30-second review against outline |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Section)**:
```bash
# 1. Check word count
wc -w sections/02_lit_review.md
# Expected: 1000-1500 words (target ±15%)

# 2. Check citations
scripts/check_citations.sh sections/02_lit_review.md references/bibliography.bib
# Expected: All citations found in bibliography

# 3. Check figure references
grep "Figure [0-9]" sections/02_lit_review.md
figures/ ls
# Expected: All referenced figures exist

# 4. Manual coherence check
# Review against outline: Did we cover all points?
# Expected: Yes

# 5. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark section complete, commit
```

---

### Book Writing Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Character consistency | Per scene/chapter | Names, traits match character_db.json | `scripts/check_characters.sh` |
| Timeline consistency | Per scene/chapter | No temporal contradictions | `scripts/check_timeline.sh` (or manual spreadsheet) |
| Word count | Per scene/chapter | Within ±20% of target | `wc -w chapter/scene.md` |
| POV consistency | Per scene | No POV shifts within scene | Manual review (60 seconds) |
| Plot points | Per chapter | All outline points addressed | `scripts/check_outline.sh` |
| Dialogue tags | Per scene | Consistent attribution style | Manual review or grep for patterns |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Scene)**:
```bash
# 1. Check word count
wc -w chapters/ch01/scene02.md
# Expected: 1000-1500 words (target ±20%)

# 2. Check character consistency
scripts/check_characters.sh chapters/ch01/scene02.md data/character_db.json
# Expected: All character mentions match database (names, traits)

# 3. Check timeline
scripts/check_timeline.sh chapters/ch01/scene02.md
# Expected: No date/time contradictions

# 4. Manual POV check
# Read scene: Is it all one POV? No head-hopping?
# Expected: Consistent POV throughout

# 5. Check against outline
scripts/check_outline.sh chapters/ch01/scene02.md docs/outline.md
# Expected: All plot points for this scene addressed

# 6. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark scene complete, commit
```

---

### Documentation Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Code examples | Per page | All code blocks runnable, 0 errors | `scripts/test_examples.sh page.md` |
| Link validity | Per page | No broken links (internal & external) | `scripts/check_links.sh page.md` |
| Image references | Per page | All images exist in images/ | `grep "!\[.*\]" page.md` + verify files |
| API accuracy | Per page | API examples match latest version | `scripts/validate_api_calls.sh` (calls API) |
| Spelling/grammar | Per page | 0 critical errors (minor OK) | `aspell check page.md` or Grammarly CLI |
| Heading structure | Per page | Proper H1-H6 hierarchy | `scripts/check_headings.sh page.md` |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Page)**:
```bash
# 1. Test all code examples
scripts/test_examples.sh docs/getting_started.md
# Expected: All code blocks execute successfully

# 2. Check links
scripts/check_links.sh docs/getting_started.md
# Expected: All links return 200 OK (or valid internal links)

# 3. Check images
grep "!\[.*\]" docs/getting_started.md | grep -o "images/[^)]*"
ls images/
# Expected: All referenced images exist

# 4. Spell check
aspell check docs/getting_started.md
# Expected: No spelling errors (or manually reviewed)

# 5. Check API examples
scripts/validate_api_calls.sh docs/getting_started.md
# Expected: All API calls return expected responses

# 6. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark page complete, commit
```

---

### Data Analysis Projects

| Test Type | Frequency | Pass Criteria | Automated Check |
|-----------|-----------|---------------|-----------------|
| Notebook execution | Per analysis unit | All cells run without error | `jupyter nbconvert --execute notebook.ipynb` |
| Data integrity | Per data load | No missing/corrupt values | `scripts/check_data_integrity.py` |
| Reproducibility | Per analysis | Same inputs → same outputs | Re-run analysis, compare results |
| Visualization validity | Per plot | No NaN/Inf in plotted data | Check data before plotting |
| Results documentation | Per analysis | Findings saved to results/ | Verify output files created |
| State integrity | Every checkpoint | JSON validates | `python scripts/validate_state.py` |

**Example Validation Sequence (Per Analysis)**:
```bash
# 1. Execute notebook
jupyter nbconvert --execute --to notebook --inplace notebooks/analysis_01.ipynb
# Expected: All cells execute, no errors

# 2. Check data integrity
python scripts/check_data_integrity.py data/processed/dataset.csv
# Expected: No missing values, no corrupt entries

# 3. Verify reproducibility
python scripts/compare_results.py results/analysis_01_run1.json results/analysis_01_run2.json
# Expected: Results match (within numerical precision)

# 4. Check visualizations
python -c "import pandas as pd; df = pd.read_csv('results/analysis_01.csv'); print(df.isnull().sum())"
# Expected: No NaNs in result data

# 5. Validate state
python scripts/validate_state.py
# Expected: All state files valid

# ALL PASS → Mark analysis complete, commit
```

---

### How to Use These Validation Tables

**Step 1**: Identify your project type
- Coding, Research, Book, Documentation, or Data Analysis

**Step 2**: After completing each work unit (module/section/scene/page/analysis):
1. Run all "Automated Check" commands for your project type (in order)
2. Perform any "manual" checks (typically <2 minutes total)
3. Record results (all must PASS)

**Step 3**: If ANY test FAILS:
1. **Do NOT mark unit complete**
2. **Do NOT commit** to git
3. Fix the issue immediately
4. Re-run ALL tests for that unit
5. Maximum 3 fix attempts before escalating to issue file

**Step 4**: When ALL tests PASS:
1. Update state files (mark unit complete)
2. Git commit with test results in message
3. Continue to next unit OR checkpoint if context ≥30%

---

### Creating Validation Scripts

**Note**: Many validation checks require scripts. If script doesn't exist:

**Option 1**: Implement script following `06_SCRIPTS_GUIDE.md` pattern
```bash
# Example: scripts/check_citations.sh
#!/bin/bash
# Extract citations from markdown
# Compare against bibliography
# Report missing citations
```

**Option 2**: Manual validation (acceptable for small projects)
```bash
# Instead of: scripts/check_citations.sh section.md
# Manually: grep '\[.*[0-9]\{4\}\]' section.md and verify each
```

**Option 3**: Use existing tools
```bash
# Link checking: use existing tool
npm install -g broken-link-checker
blc docs/page.md

# Spell checking: use aspell
aspell check page.md
```

---

## Next Steps After Validation

**Framework is validated!** Now:

1. **Read**: `04_CORE_WORKFLOW.md` - Understand daily workflow
2. **Implement**: Scripts per `06_SCRIPTS_GUIDE.md` (optional but recommended)
3. **Start**: Begin Module 1.1 implementation

Or:

- **See examples**: `09_EXAMPLES/` for your project type
- **Get help**: `08_TROUBLESHOOTING.md` if issues arise

---

## Integration Testing Patterns

**Purpose**: Test interactions between multiple components, services, or systems
**When to use**: After unit tests pass, before marking milestone complete
**Critical**: Integration tests validate system behavior, not just component behavior

---

### What is Integration Testing?

**Integration testing** validates that multiple components work together correctly:

- **Unit tests**: Test individual functions/classes in isolation
- **Integration tests**: Test how components interact (DB + API, API + external service, etc.)
- **End-to-end tests**: Test entire user workflows (full stack)

**When to write integration tests**:
1. After implementing 2+ modules that must communicate
2. Before milestone completion (every 3-5 modules)
3. When adding external service integrations (APIs, databases, message queues)
4. When refactoring shared interfaces

---

### Integration Testing Patterns by Project Type

#### Coding Projects - Common Integration Scenarios

| Scenario | What to Test | Example |
|----------|--------------|---------|
| **API + Database** | Data flows correctly from API to DB and back | POST /users → DB insert → GET /users returns new user |
| **Service-to-Service** | Services communicate via defined interfaces | AuthService validates token → UserService returns user data |
| **API + External Service** | API correctly calls third-party APIs | Payment API → Stripe API → returns transaction ID |
| **Database Transactions** | Multi-table operations maintain consistency | Create order → deduct inventory → update user balance (all or nothing) |
| **Message Queue Integration** | Messages published and consumed correctly | API publishes event → worker consumes → DB updated |

---

### API Testing Examples

**Purpose**: Test HTTP APIs with real or stubbed backends

#### Example 1: REST API Integration Test (Python + pytest)

```python
# tests/integration/test_api_users.py
import pytest
import requests
from app import create_app, db
from app.models import User

@pytest.fixture
def app():
    """Create test app with test database"""
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()

@pytest.fixture
def client(app):
    """Create test client"""
    return app.test_client()

@pytest.fixture
def auth_headers():
    """Create authentication headers"""
    token = "test_token_12345"
    return {"Authorization": f"Bearer {token}"}

class TestUserAPI:
    """Integration tests for User API"""

    def test_create_user_and_fetch(self, client):
        """Test POST /users then GET /users/{id}"""
        # 1. Create user via API
        response = client.post('/api/users', json={
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'securepass123'
        })
        assert response.status_code == 201
        user_id = response.json['id']

        # 2. Fetch created user
        response = client.get(f'/api/users/{user_id}')
        assert response.status_code == 200
        assert response.json['username'] == 'testuser'
        assert response.json['email'] == 'test@example.com'
        # Password should NOT be returned
        assert 'password' not in response.json

    def test_update_user_persists_to_db(self, client, app):
        """Test PUT /users/{id} updates database"""
        # 1. Create user
        response = client.post('/api/users', json={
            'username': 'oldname',
            'email': 'old@example.com'
        })
        user_id = response.json['id']

        # 2. Update via API
        response = client.put(f'/api/users/{user_id}', json={
            'username': 'newname'
        })
        assert response.status_code == 200

        # 3. Verify in database directly
        with app.app_context():
            user = User.query.get(user_id)
            assert user.username == 'newname'
            assert user.email == 'old@example.com'  # Unchanged

    def test_delete_user_cascade(self, client, app):
        """Test DELETE /users/{id} cascades to related records"""
        # 1. Create user with posts
        response = client.post('/api/users', json={
            'username': 'testuser'
        })
        user_id = response.json['id']

        # 2. Create posts for user
        client.post(f'/api/users/{user_id}/posts', json={
            'title': 'Post 1'
        })
        client.post(f'/api/users/{user_id}/posts', json={
            'title': 'Post 2'
        })

        # 3. Delete user
        response = client.delete(f'/api/users/{user_id}')
        assert response.status_code == 204

        # 4. Verify user and posts are gone
        with app.app_context():
            user = User.query.get(user_id)
            assert user is None
            posts = Post.query.filter_by(user_id=user_id).all()
            assert len(posts) == 0  # Cascade delete worked

    def test_auth_required_endpoints(self, client, auth_headers):
        """Test protected endpoints require authentication"""
        # 1. Without auth header - should fail
        response = client.get('/api/users/me')
        assert response.status_code == 401

        # 2. With auth header - should succeed
        response = client.get('/api/users/me', headers=auth_headers)
        assert response.status_code == 200
```

**Run integration tests**:
```bash
# Run only integration tests
pytest tests/integration/

# With coverage
pytest tests/integration/ --cov=app --cov-report=term
```

---

#### Example 2: GraphQL API Integration Test (JavaScript + Jest)

```javascript
// tests/integration/userAPI.test.js
const { ApolloServer } = require('apollo-server');
const { createTestClient } = require('apollo-server-testing');
const { typeDefs, resolvers } = require('../../src/schema');
const { setupTestDB, teardownTestDB } = require('../helpers/db');

describe('User GraphQL API Integration', () => {
  let server, query, mutate, db;

  beforeAll(async () => {
    // Setup test database
    db = await setupTestDB();

    // Create Apollo server with test context
    server = new ApolloServer({
      typeDefs,
      resolvers,
      context: () => ({ db })
    });

    const testClient = createTestClient(server);
    query = testClient.query;
    mutate = testClient.mutate;
  });

  afterAll(async () => {
    await teardownTestDB(db);
  });

  test('createUser mutation persists to database', async () => {
    // 1. Execute mutation
    const CREATE_USER = `
      mutation CreateUser($input: CreateUserInput!) {
        createUser(input: $input) {
          id
          username
          email
        }
      }
    `;

    const { data } = await mutate({
      mutation: CREATE_USER,
      variables: {
        input: {
          username: 'testuser',
          email: 'test@example.com'
        }
      }
    });

    expect(data.createUser).toMatchObject({
      username: 'testuser',
      email: 'test@example.com'
    });

    const userId = data.createUser.id;

    // 2. Query database directly to verify persistence
    const user = await db.collection('users').findOne({ _id: userId });
    expect(user).toMatchObject({
      username: 'testuser',
      email: 'test@example.com'
    });
  });

  test('user query with posts relationship', async () => {
    // 1. Setup: Create user with posts in DB
    const user = await db.collection('users').insertOne({
      username: 'author',
      email: 'author@example.com'
    });

    await db.collection('posts').insertMany([
      { userId: user.insertedId, title: 'Post 1' },
      { userId: user.insertedId, title: 'Post 2' }
    ]);

    // 2. Query user with posts via GraphQL
    const GET_USER_WITH_POSTS = `
      query GetUser($id: ID!) {
        user(id: $id) {
          id
          username
          posts {
            id
            title
          }
        }
      }
    `;

    const { data } = await query({
      query: GET_USER_WITH_POSTS,
      variables: { id: user.insertedId.toString() }
    });

    // 3. Verify relationship loading
    expect(data.user.username).toBe('author');
    expect(data.user.posts).toHaveLength(2);
    expect(data.user.posts[0].title).toBe('Post 1');
    expect(data.user.posts[1].title).toBe('Post 2');
  });
});
```

---

### Database Integration Examples

**Purpose**: Test database operations with real database instances

#### Example 3: Database Transaction Integration Test (Python + SQLAlchemy)

```python
# tests/integration/test_db_transactions.py
import pytest
from sqlalchemy.exc import IntegrityError
from app import db
from app.models import Order, Inventory, User
from app.services.order_service import create_order

@pytest.fixture
def test_user(app):
    """Create test user"""
    with app.app_context():
        user = User(username='testuser', balance=100.0)
        db.session.add(user)
        db.session.commit()
        yield user
        db.session.delete(user)
        db.session.commit()

@pytest.fixture
def test_inventory(app):
    """Create test inventory item"""
    with app.app_context():
        item = Inventory(product_id='PROD001', quantity=10, price=15.0)
        db.session.add(item)
        db.session.commit()
        yield item
        db.session.delete(item)
        db.session.commit()

class TestDatabaseTransactions:
    """Test multi-table transaction integrity"""

    def test_create_order_updates_inventory_and_balance(self, app, test_user, test_inventory):
        """Test successful order creation updates all tables atomically"""
        with app.app_context():
            # Initial state
            initial_inventory = test_inventory.quantity
            initial_balance = test_user.balance

            # Create order (should update: orders, inventory, users)
            order = create_order(
                user_id=test_user.id,
                product_id='PROD001',
                quantity=3
            )

            # Verify all changes committed atomically
            db.session.refresh(test_user)
            db.session.refresh(test_inventory)

            assert order.status == 'confirmed'
            assert test_inventory.quantity == initial_inventory - 3  # Inventory reduced
            assert test_user.balance == initial_balance - (3 * 15.0)  # Balance deducted

    def test_order_rollback_on_insufficient_inventory(self, app, test_user, test_inventory):
        """Test transaction rollback when inventory check fails"""
        with app.app_context():
            initial_inventory = test_inventory.quantity
            initial_balance = test_user.balance
            initial_order_count = Order.query.count()

            # Try to order more than available
            with pytest.raises(ValueError, match="Insufficient inventory"):
                create_order(
                    user_id=test_user.id,
                    product_id='PROD001',
                    quantity=100  # More than available
                )

            # Verify NOTHING changed (full rollback)
            db.session.refresh(test_user)
            db.session.refresh(test_inventory)

            assert test_inventory.quantity == initial_inventory  # Unchanged
            assert test_user.balance == initial_balance  # Unchanged
            assert Order.query.count() == initial_order_count  # No order created

    def test_concurrent_order_handling(self, app, test_user, test_inventory):
        """Test database handles concurrent orders correctly (pessimistic locking)"""
        import threading

        with app.app_context():
            initial_inventory = test_inventory.quantity
            results = []

            def place_order():
                try:
                    order = create_order(
                        user_id=test_user.id,
                        product_id='PROD001',
                        quantity=6
                    )
                    results.append(('success', order.id))
                except Exception as e:
                    results.append(('failed', str(e)))

            # Simulate 2 concurrent orders for 6 items each (only 10 available)
            thread1 = threading.Thread(target=place_order)
            thread2 = threading.Thread(target=place_order)

            thread1.start()
            thread2.start()
            thread1.join()
            thread2.join()

            # Verify: One succeeds, one fails (no overselling)
            successes = [r for r in results if r[0] == 'success']
            failures = [r for r in results if r[0] == 'failed']

            assert len(successes) == 1  # Only one order succeeded
            assert len(failures) == 1  # Other order failed

            db.session.refresh(test_inventory)
            assert test_inventory.quantity == initial_inventory - 6  # Only 6 sold
```

---

#### Example 4: Database Migration Integration Test (Node.js + Knex)

```javascript
// tests/integration/migrations.test.js
const knex = require('knex');
const config = require('../../knexfile');

describe('Database Migration Integration', () => {
  let db;

  beforeAll(async () => {
    // Create fresh test database
    db = knex(config.test);
  });

  afterAll(async () => {
    await db.destroy();
  });

  test('migrations run successfully in order', async () => {
    // 1. Rollback all migrations
    await db.migrate.rollback(null, true);

    // 2. Run all migrations
    const [batch, migrations] = await db.migrate.latest();

    expect(batch).toBeGreaterThan(0);
    expect(migrations.length).toBeGreaterThan(0);

    // 3. Verify tables exist
    const tables = await db.raw(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
    `);

    const tableNames = tables.rows.map(t => t.table_name);
    expect(tableNames).toContain('users');
    expect(tableNames).toContain('posts');
    expect(tableNames).toContain('comments');
  });

  test('migration rollback works correctly', async () => {
    // 1. Apply all migrations
    await db.migrate.latest();

    // 2. Rollback one batch
    const [batch, migrations] = await db.migrate.rollback();

    expect(batch).toBeGreaterThan(0);
    expect(migrations.length).toBeGreaterThan(0);

    // 3. Verify rollback removed tables/columns
    // (Specific assertions depend on what your last migration did)
  });

  test('schema matches expected structure after migrations', async () => {
    // 1. Run all migrations
    await db.migrate.latest();

    // 2. Verify users table structure
    const usersColumns = await db.table('users').columnInfo();
    expect(usersColumns).toHaveProperty('id');
    expect(usersColumns).toHaveProperty('username');
    expect(usersColumns).toHaveProperty('email');
    expect(usersColumns).toHaveProperty('created_at');

    // 3. Verify foreign keys exist
    const fkQuery = await db.raw(`
      SELECT constraint_name, table_name, column_name
      FROM information_schema.key_column_usage
      WHERE constraint_name LIKE '%_fkey'
    `);

    const fkNames = fkQuery.rows.map(fk => fk.constraint_name);
    expect(fkNames).toContain('posts_user_id_fkey');
  });
});
```

---

### External Service Mocking Examples

**Purpose**: Test integrations with third-party APIs without actual API calls

#### Example 5: Mocking External HTTP APIs (Python + responses)

```python
# tests/integration/test_payment_service.py
import pytest
import responses
from app.services.payment_service import process_payment, PaymentError

class TestPaymentServiceIntegration:
    """Test payment service with mocked Stripe API"""

    @responses.activate
    def test_successful_payment_processing(self):
        """Test successful payment flow with Stripe API mock"""
        # 1. Mock Stripe API response
        responses.add(
            responses.POST,
            'https://api.stripe.com/v1/charges',
            json={
                'id': 'ch_test12345',
                'status': 'succeeded',
                'amount': 5000,
                'currency': 'usd'
            },
            status=200
        )

        # 2. Call our payment service
        result = process_payment(
            amount=50.00,
            currency='usd',
            card_token='tok_test_card'
        )

        # 3. Verify our service handled response correctly
        assert result['status'] == 'success'
        assert result['transaction_id'] == 'ch_test12345'
        assert result['amount'] == 50.00

        # 4. Verify API was called with correct parameters
        assert len(responses.calls) == 1
        assert responses.calls[0].request.url == 'https://api.stripe.com/v1/charges'
        assert 'amount=5000' in responses.calls[0].request.body

    @responses.activate
    def test_payment_failure_handling(self):
        """Test payment service handles Stripe errors correctly"""
        # 1. Mock Stripe API error response
        responses.add(
            responses.POST,
            'https://api.stripe.com/v1/charges',
            json={
                'error': {
                    'type': 'card_error',
                    'code': 'card_declined',
                    'message': 'Your card was declined.'
                }
            },
            status=402
        )

        # 2. Verify our service raises appropriate exception
        with pytest.raises(PaymentError) as exc_info:
            process_payment(
                amount=50.00,
                currency='usd',
                card_token='tok_test_card'
            )

        assert 'card_declined' in str(exc_info.value)
        assert exc_info.value.code == 'card_declined'

    @responses.activate
    def test_payment_retry_logic(self):
        """Test payment service retries on network errors"""
        # 1. Mock: First call fails (timeout), second succeeds
        responses.add(
            responses.POST,
            'https://api.stripe.com/v1/charges',
            body=Exception('Connection timeout')
        )
        responses.add(
            responses.POST,
            'https://api.stripe.com/v1/charges',
            json={'id': 'ch_retry_success', 'status': 'succeeded'},
            status=200
        )

        # 2. Call payment service (should retry automatically)
        result = process_payment(
            amount=50.00,
            currency='usd',
            card_token='tok_test_card'
        )

        # 3. Verify retry worked
        assert result['status'] == 'success'
        assert result['transaction_id'] == 'ch_retry_success'
        assert len(responses.calls) == 2  # Two attempts made
```

---

#### Example 6: Mocking External APIs (JavaScript + nock)

```javascript
// tests/integration/weatherService.test.js
const nock = require('nock');
const { getWeather, WeatherAPIError } = require('../../src/services/weatherService');

describe('Weather Service Integration', () => {
  afterEach(() => {
    nock.cleanAll();
  });

  test('successful weather data retrieval', async () => {
    // 1. Mock OpenWeatherMap API
    nock('https://api.openweathermap.org')
      .get('/data/2.5/weather')
      .query({ q: 'London', appid: 'test_api_key' })
      .reply(200, {
        main: { temp: 283.15, humidity: 75 },
        weather: [{ main: 'Clouds', description: 'overcast clouds' }],
        name: 'London'
      });

    // 2. Call our weather service
    const weather = await getWeather('London');

    // 3. Verify our service transformed response correctly
    expect(weather).toEqual({
      city: 'London',
      temperature: 10,  // Converted from Kelvin to Celsius
      humidity: 75,
      condition: 'Clouds',
      description: 'overcast clouds'
    });
  });

  test('handles API rate limiting gracefully', async () => {
    // 1. Mock rate limit response
    nock('https://api.openweathermap.org')
      .get('/data/2.5/weather')
      .query(true)
      .reply(429, {
        message: 'Rate limit exceeded. Try again in 60 seconds.'
      });

    // 2. Verify our service handles rate limit
    await expect(getWeather('London'))
      .rejects
      .toThrow(WeatherAPIError);

    await expect(getWeather('London'))
      .rejects
      .toThrow('Rate limit exceeded');
  });

  test('caches API responses to reduce calls', async () => {
    // 1. Mock API (should only be called once)
    const scope = nock('https://api.openweathermap.org')
      .get('/data/2.5/weather')
      .query({ q: 'Paris', appid: 'test_api_key' })
      .reply(200, {
        main: { temp: 290.15 },
        weather: [{ main: 'Clear' }],
        name: 'Paris'
      });

    // 2. Call service twice
    const weather1 = await getWeather('Paris');
    const weather2 = await getWeather('Paris');

    // 3. Verify cache worked (API called only once)
    expect(weather1).toEqual(weather2);
    expect(scope.isDone()).toBe(true);  // All mocked requests were called
    // Second call should not trigger mock (would fail if it did)
  });
});
```

---

### Integration Testing Best Practices

**1. Use Test Databases**
- Never run integration tests against production databases
- Create dedicated test database per test suite
- Reset database state between tests

```bash
# Example: Setup test database
createdb myapp_test
export DATABASE_URL=postgresql://localhost/myapp_test
pytest tests/integration/
```

**2. Isolate External Dependencies**
- Mock external APIs (Stripe, SendGrid, AWS, etc.)
- Use test accounts for third-party services when mocking isn't possible
- Implement circuit breakers for flaky external services

**3. Test Failure Scenarios**
- Happy path (success)
- Error responses (4xx, 5xx)
- Network timeouts
- Database connection failures
- Race conditions

**4. Performance Considerations**
- Integration tests are slower than unit tests (seconds vs milliseconds)
- Run integration tests less frequently (on commit, not on save)
- Parallelize test execution when possible

```bash
# Run tests in parallel
pytest tests/integration/ -n 4  # 4 parallel workers
```

**5. CI/CD Integration**
```yaml
# Example: .github/workflows/test.yml
name: Integration Tests
on: [push, pull_request]

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_DB: test_db
          POSTGRES_PASSWORD: test_pass
        options: >-
          --health-cmd pg_isready
          --health-interval 10s

    steps:
      - uses: actions/checkout@v2
      - name: Run integration tests
        env:
          DATABASE_URL: postgresql://postgres:test_pass@localhost/test_db
        run: |
          pytest tests/integration/ --cov --cov-report=xml
```

---

### When to Write Integration Tests vs Unit Tests

| Use Unit Tests When | Use Integration Tests When |
|---------------------|----------------------------|
| Testing single function/class logic | Testing multiple components together |
| Logic has no external dependencies | Testing database queries |
| Execution is fast (<10ms per test) | Testing API endpoints |
| Testing edge cases/error handling | Testing external service integrations |
| Mocking would make test meaningless | Testing transaction integrity |

**Example Decision Tree**:
```
Are you testing a single function with no I/O?
  Yes → Unit test
  No → Does it interact with a database/API?
    Yes → Integration test
    No → Does it call multiple modules?
      Yes → Integration test
      No → Unit test
```

---

**Testing guide version**: 3.3
**Last updated**: January 2025
