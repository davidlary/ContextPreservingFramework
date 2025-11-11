# Enhancement: External Memory Pattern

**Purpose**: Offload context-heavy reference material to external memory system
**Value**: High
**Integration**: Works with core workflow to extend effective context window
**Complexity**: Medium

---

## Concept

**The Problem**: Some projects require large reference materials (API docs, specifications, existing codebases) that would consume too much context if loaded directly.

**The Solution**: Use external memory pattern where Claude can query specific information on-demand rather than loading everything into context.

**Key Insight**: You don't need all information at once, just the ability to retrieve relevant information when needed.

---

## Implementation

### Option 1: Structured Note System (Simple)

**Setup**:

```bash
project/
├── memory/
│   ├── index.md           # Table of contents
│   ├── api_reference.md   # Searchable API docs
│   ├── design_decisions.md
│   ├── code_patterns.md
│   └── troubleshooting.md
```

**Usage Pattern**:

1. **Index creation** (one-time):
   ```markdown
   # Project Memory Index

   ## API Reference
   - File: memory/api_reference.md
   - Contains: All public API signatures
   - When to use: Before implementing new features

   ## Design Decisions
   - File: memory/design_decisions.md
   - Contains: Architectural choices and rationale
   - When to use: Before making design changes
   ```

2. **Query in CLAUDE.md**:
   ```markdown
   ## External Memory

   Before implementing features, consult:
   - memory/index.md for available references
   - Use Grep to search relevant memory files
   - Load only needed sections into context
   ```

3. **During work**:
   - Claude searches memory/ directory
   - Reads only relevant sections
   - Never loads entire memory at once

**Example**:
```
User: "Add authentication to the API"

Claude actions:
1. grep "auth" memory/*.md
2. Read memory/api_reference.md (authentication section only)
3. Implement based on found patterns
```

---

### Option 2: Database-Backed Memory (Advanced)

**Setup**:

```bash
pip install sqlite3

python scripts/init_memory.py
# Creates: data/memory.db
```

**Schema**:
```sql
CREATE TABLE memory (
  id INTEGER PRIMARY KEY,
  category TEXT,      -- 'api', 'design', 'code', 'docs'
  key TEXT,           -- searchable identifier
  content TEXT,       -- the actual content
  metadata JSON,      -- tags, dates, etc.
  created_at TIMESTAMP
);

CREATE INDEX idx_category ON memory(category);
CREATE INDEX idx_key ON memory(key);
CREATE VIRTUAL TABLE memory_fts USING fts5(key, content);
```

**Usage Pattern**:

1. **Populate memory**:
   ```python
   # scripts/add_to_memory.py
   import sqlite3

   def add_memory(category, key, content, metadata=None):
       conn = sqlite3.connect('data/memory.db')
       conn.execute(
           "INSERT INTO memory (category, key, content, metadata) VALUES (?, ?, ?, ?)",
           (category, key, content, json.dumps(metadata or {}))
       )
       conn.commit()

   # Usage
   add_memory('api', 'User.authenticate',
              'def authenticate(username, password) -> Token: ...',
              {'module': 'auth', 'returns': 'Token'})
   ```

2. **Query memory**:
   ```python
   # scripts/query_memory.py
   def query_memory(search_term, category=None):
       conn = sqlite3.connect('data/memory.db')
       if category:
           results = conn.execute(
               "SELECT key, content FROM memory_fts WHERE key MATCH ? AND category = ?",
               (search_term, category)
           ).fetchall()
       else:
           results = conn.execute(
               "SELECT key, content FROM memory_fts WHERE key MATCH ?",
               (search_term,)
           ).fetchall()
       return results
   ```

3. **Integration with Claude**:
   ```markdown
   # In CLAUDE.md

   ## External Memory Access

   Before implementing features:
   1. Search memory: python scripts/query_memory.py "authentication"
   2. Review relevant entries
   3. Implement using found patterns
   ```

---

## Integration with Core Workflow

### At Session Start (Step 1)

**Add to workflow**:
```
1. Read AUTONOMOUS_MODE.md
2. Read master_state.json
3. **Check memory/index.md for available references**
4. Proceed with implementation
```

### Before Implementing Features (Step 3)

**Add to workflow**:
```
Before writing code:
1. **Search external memory for relevant patterns**
2. Read only relevant sections (not entire files)
3. Implement following established patterns
```

### At Context Warning (30%)

**Add to workflow**:
```
When context reaches 30%:
1. Identify information that could be offloaded
2. **Write to external memory**
3. Remove from active context
4. Continue working
```

---

## Example: Large API Documentation

**Scenario**: You're adding features to a project with 50+ API endpoints.

**Without External Memory**:
- Load entire API docs (50K tokens = 25% context)
- Leaves only 10% for actual work
- Frequent context exhaustion

**With External Memory**:

1. **One-time setup** (5 minutes):
   ```bash
   # Extract API docs to memory
   python scripts/extract_api_docs.py --output memory/api_reference.md
   ```

2. **Create searchable index**:
   ```markdown
   # memory/api_reference.md

   ## Authentication Endpoints

   ### POST /auth/login
   ...

   ### POST /auth/logout
   ...

   ## User Endpoints

   ### GET /users
   ...
   ```

3. **During development**:
   ```
   Task: "Add password reset endpoint"

   Claude:
   1. Grep "auth" memory/api_reference.md
   2. Read only Authentication section (2K tokens)
   3. Implement following same pattern
   4. Context used: 2K instead of 50K
   ```

**Result**: 96% context saved

---

## Benefits

1. **Massive context savings**
   - 50-100K tokens of reference material
   - Load only 2-5K tokens when needed
   - 95%+ context savings

2. **Faster session starts**
   - Don't load entire codebase
   - Query only what's needed
   - Start working immediately

3. **Longer sessions**
   - More context available for actual work
   - Less time managing context
   - Complete more per session

4. **Better knowledge retention**
   - Structured storage
   - Searchable history
   - Consistent patterns

5. **Reusable across sessions**
   - Build up memory over time
   - Reference grows more valuable
   - Never re-explain same concepts

---

## Trade-offs

### Pros
- Dramatic context savings
- Scales to very large projects
- Searchable and organized
- Builds over time

### Cons
- Requires initial setup
- Must maintain memory files
- Query step adds small overhead
- Can miss context if search fails

---

## When to Use

**Use External Memory when**:
- Project has large API surface (20+ endpoints/classes)
- Extensive existing codebase to reference
- Complex domain knowledge required
- Long-running project (weeks/months)
- Multiple related projects

**Skip External Memory when**:
- Small project (< 10 files)
- Simple domain
- Short project (< 10 hours)
- All context fits comfortably

---

## Implementation Checklist

### Simple Setup (15 minutes)

- [ ] Create `memory/` directory
- [ ] Create `memory/index.md` with structure
- [ ] Extract key reference materials to memory files
- [ ] Add "Check memory/" to CLAUDE.md workflow
- [ ] Add Grep memory/ searches to workflow

### Advanced Setup (1 hour)

- [ ] Install SQLite
- [ ] Create database schema
- [ ] Write `scripts/add_to_memory.py`
- [ ] Write `scripts/query_memory.py`
- [ ] Populate initial memory from existing docs
- [ ] Add query commands to CLAUDE.md
- [ ] Test search functionality

---

## Success Metrics

**Before External Memory**:
- Context usage: 60-80% for reference material
- Effective work context: 20-40%
- Sessions: 30-60 minutes

**After External Memory**:
- Context usage: 5-15% for reference material
- Effective work context: 60-80%
- Sessions: 90-180 minutes

**Improvement**: 2-3x longer sessions, 3-4x more work per session

---

## Real-World Example

**Project**: REST API with 80 endpoints

**Setup**:
```bash
python scripts/extract_api.py
# Output: memory/api_reference.md (80 endpoints, 40K tokens)

# Create index
cat > memory/index.md << EOF
# API Memory
- Authentication: Lines 1-150
- Users: Lines 151-400
- Products: Lines 401-800
- Orders: Lines 801-1200
EOF
```

**Usage**:
```
Task: "Add product search endpoint"

Instead of loading 40K tokens:
1. Grep "product" memory/index.md → Lines 401-800
2. Read lines 401-800 only (5K tokens)
3. Implement following pattern
4. Context saved: 35K tokens (87%)
```

**Result**: Completed 4 endpoints in one session instead of 1

---

## Next Steps

1. **Try simple version first**: Create memory/ directory and index
2. **Populate with high-value references**: API docs, design decisions
3. **Add to workflow**: Update CLAUDE.md to check memory/ first
4. **Measure impact**: Track context savings
5. **Upgrade if needed**: Move to database if simple version insufficient

---

**Related**:
- See 04_CORE_WORKFLOW.md for integration points
- See 06_SCRIPTS_GUIDE.md for automation scripts
- See context_estimation.md for measuring impact
