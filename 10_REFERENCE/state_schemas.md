# State File Schemas Reference

**Quick reference for JSON state file structures**

---

## Master State (Coding Projects)

**File**: `data/state/master_state.json`
**Purpose**: Track overall project state for coding projects
**Updated**: After every module completion, at session boundaries

### Schema

```json
{
  "project": string,                    // Project name
  "version": string,                    // Semantic version (X.Y.Z)
  "project_type": "coding",             // Project type
  "language": string,                   // Primary language
  "framework": string,                  // Framework (optional)
  "current_phase": enum,                // "setup" | "implementation" | "testing" | "complete"
  "current_module": string | null,      // Currently active module (e.g., "1.2")
  "modules_complete": [string],         // ["1.1", "1.2", ...]
  "modules_in_progress": [string],      // ["1.3"] (max 1 item)
  "modules_pending": [string],          // ["1.4", "1.5", ...]
  "tests_passing": integer,             // ≥ 0
  "tests_total": integer,               // ≥ 0
  "context_usage": {
    "current_tokens": integer,          // ≥ 0
    "max_tokens": integer,              // Usually 200000
    "percentage": float,                // 0.0-100.0
    "warning_threshold": float,         // Usually 0.30
    "critical_threshold": float         // Usually 0.35
  },
  "session_info": {
    "current_session": integer,         // ≥ 1
    "session_start": string,            // ISO 8601 timestamp
    "last_update": string,              // ISO 8601 timestamp
    "operations_this_session": integer  // ≥ 0
  },
  "git_info": {
    "repository_initialized": boolean,
    "last_commit": string | null,       // Git commit hash
    "commits_this_session": integer,    // ≥ 0
    "branch": string                    // Default "main"
  },
  "metrics": {
    "total_files": integer,             // ≥ 0
    "total_lines": integer,             // ≥ 0
    "test_coverage": float              // 0.0-1.0
  },
  "last_update": string                 // ISO 8601 timestamp
}
```

### Example

```json
{
  "project": "task_api",
  "version": "0.3.0",
  "project_type": "coding",
  "language": "python",
  "framework": "fastapi",
  "current_phase": "implementation",
  "current_module": "1.3",
  "modules_complete": ["1.1", "1.2"],
  "modules_in_progress": ["1.3"],
  "modules_pending": ["1.4", "1.5", "1.6"],
  "tests_passing": 24,
  "tests_total": 24,
  "context_usage": {
    "current_tokens": 52000,
    "max_tokens": 200000,
    "percentage": 26.0,
    "warning_threshold": 0.30,
    "critical_threshold": 0.35
  },
  "session_info": {
    "current_session": 2,
    "session_start": "2025-01-15T10:00:00Z",
    "last_update": "2025-01-15T12:30:45Z",
    "operations_this_session": 18
  },
  "git_info": {
    "repository_initialized": true,
    "last_commit": "abc123def456",
    "commits_this_session": 3,
    "branch": "main"
  },
  "metrics": {
    "total_files": 12,
    "total_lines": 1840,
    "test_coverage": 0.95
  },
  "last_update": "2025-01-15T12:30:45Z"
}
```

---

## Master State (Non-Coding Projects)

**File**: `data/state/master_state.json`
**Purpose**: Track overall state for writing/research projects
**Updated**: After every section completion, at session boundaries

### Schema

```json
{
  "project": string,                    // Project name
  "version": string,                    // Semantic version
  "project_type": "non_coding",         // Project type
  "domain": enum,                       // "research" | "book" | "documentation" | "article"
  "current_phase": enum,                // "planning" | "writing" | "revision" | "complete"
  "current_section": string | null,     // Current section ID
  "sections_complete": [string],        // ["intro", "section1", ...]
  "sections_in_progress": [string],     // ["section2"] (max 1)
  "sections_pending": [string],         // ["section3", "conclusion", ...]
  "word_count": integer,                // ≥ 0
  "target_word_count": integer,         // ≥ 0
  "references_cited": integer,          // ≥ 0
  "target_references": integer,         // ≥ 0 (optional)
  "context_usage": {
    "current_tokens": integer,
    "max_tokens": integer,
    "percentage": float,
    "warning_threshold": float,
    "critical_threshold": float
  },
  "session_info": {
    "current_session": integer,
    "session_start": string,
    "last_update": string,
    "operations_this_session": integer
  },
  "git_info": {
    "repository_initialized": boolean,
    "last_commit": string | null,
    "commits_this_session": integer,
    "branch": string
  },
  "quality_metrics": {
    "readability_score": float,         // 0.0-100.0
    "citations_valid": boolean,
    "structure_complete": boolean,
    "peer_reviewed": boolean
  },
  "last_update": string
}
```

### Example

```json
{
  "project": "climate_paper",
  "version": "0.2.0",
  "project_type": "non_coding",
  "domain": "research",
  "current_phase": "writing",
  "current_section": "methods",
  "sections_complete": ["introduction", "background"],
  "sections_in_progress": ["methods"],
  "sections_pending": ["results", "discussion", "conclusion"],
  "word_count": 3200,
  "target_word_count": 8000,
  "references_cited": 18,
  "target_references": 30,
  "context_usage": {
    "current_tokens": 45000,
    "max_tokens": 200000,
    "percentage": 22.5,
    "warning_threshold": 0.30,
    "critical_threshold": 0.35
  },
  "session_info": {
    "current_session": 2,
    "session_start": "2025-01-15T14:00:00Z",
    "last_update": "2025-01-15T16:15:30Z",
    "operations_this_session": 12
  },
  "git_info": {
    "repository_initialized": true,
    "last_commit": "def789abc012",
    "commits_this_session": 2,
    "branch": "main"
  },
  "quality_metrics": {
    "readability_score": 65.0,
    "citations_valid": true,
    "structure_complete": false,
    "peer_reviewed": false
  },
  "last_update": "2025-01-15T16:15:30Z"
}
```

---

## Module State (Coding Projects)

**File**: `data/state/module_[id].json`
**Purpose**: Track individual module progress
**Updated**: During module implementation, at module completion

### Schema

```json
{
  "module_id": string,                  // "1.1", "1.2", etc.
  "module_name": string,                // Human-readable name
  "status": enum,                       // "pending" | "in_progress" | "completed" | "blocked"
  "phase": string,                      // Current phase of module
  "start_time": string | null,          // ISO 8601 timestamp
  "end_time": string | null,            // ISO 8601 timestamp
  "duration_minutes": number,           // ≥ 0
  "files": {
    "created": [string],                // File paths
    "modified": [string],
    "deleted": [string]
  },
  "tests": {
    "total": integer,                   // ≥ 0
    "passing": integer,                 // ≥ 0
    "failing": integer,                 // ≥ 0
    "skipped": integer                  // ≥ 0
  },
  "dependencies": {
    "modules": [string],                // Module IDs this depends on
    "packages": [string]                // External packages needed
  },
  "context_at_start": float,            // 0.0-100.0
  "context_at_end": float,              // 0.0-100.0
  "git_commits": [string],              // Commit hashes for this module
  "issues": [string],                   // Issue descriptions
  "validation": {
    "code_complete": boolean,
    "tests_passing": boolean,
    "documented": boolean,
    "reviewed": boolean
  },
  "notes": string,                      // Freeform notes
  "last_update": string                 // ISO 8601 timestamp
}
```

### Example

```json
{
  "module_id": "1.2",
  "module_name": "Authentication System",
  "status": "completed",
  "phase": "testing",
  "start_time": "2025-01-15T10:15:00Z",
  "end_time": "2025-01-15T11:30:00Z",
  "duration_minutes": 75,
  "files": {
    "created": [
      "src/auth/authenticator.py",
      "src/auth/jwt_handler.py",
      "tests/test_auth.py"
    ],
    "modified": [
      "src/config.py"
    ],
    "deleted": []
  },
  "tests": {
    "total": 12,
    "passing": 12,
    "failing": 0,
    "skipped": 0
  },
  "dependencies": {
    "modules": ["1.1"],
    "packages": ["python-jose", "passlib"]
  },
  "context_at_start": 12.5,
  "context_at_end": 19.8,
  "git_commits": ["abc123", "def456"],
  "issues": [],
  "validation": {
    "code_complete": true,
    "tests_passing": true,
    "documented": true,
    "reviewed": false
  },
  "notes": "JWT token expiration set to 24 hours. Consider making configurable in future.",
  "last_update": "2025-01-15T11:30:00Z"
}
```

---

## Section State (Non-Coding Projects)

**File**: `data/state/section_[id].json`
**Purpose**: Track individual section progress
**Updated**: During section writing, at section completion

### Schema

```json
{
  "section_id": string,                 // "intro", "section1", etc.
  "section_name": string,               // Human-readable name
  "status": enum,                       // "pending" | "in_progress" | "completed" | "blocked"
  "phase": enum,                        // "outline" | "draft" | "revision" | "final"
  "start_time": string | null,
  "end_time": string | null,
  "duration_minutes": number,
  "content": {
    "word_count": integer,              // ≥ 0
    "target_word_count": integer,       // ≥ 0
    "paragraph_count": integer,         // ≥ 0
    "subsections": [string]             // Subsection IDs
  },
  "references": {
    "cited": [string],                  // Citation keys
    "to_cite": [string],                // Planned citations
    "total": integer                    // ≥ 0
  },
  "quality": {
    "draft_complete": boolean,
    "reviewed": boolean,
    "citations_valid": boolean,
    "readability_score": float          // 0.0-100.0
  },
  "dependencies": {
    "sections": [string],               // Section IDs this depends on
    "sources": [string]                 // Required sources
  },
  "context_at_start": float,
  "context_at_end": float,
  "git_commits": [string],
  "issues": [string],
  "notes": string,
  "last_update": string
}
```

### Example

```json
{
  "section_id": "methods",
  "section_name": "Methods",
  "status": "completed",
  "phase": "revision",
  "start_time": "2025-01-15T14:00:00Z",
  "end_time": "2025-01-15T16:00:00Z",
  "duration_minutes": 120,
  "content": {
    "word_count": 2008,
    "target_word_count": 2000,
    "paragraph_count": 14,
    "subsections": ["data_collection", "analysis", "validation"]
  },
  "references": {
    "cited": ["Smith2020", "Jones2019", "Lee2021"],
    "to_cite": [],
    "total": 3
  },
  "quality": {
    "draft_complete": true,
    "reviewed": false,
    "citations_valid": true,
    "readability_score": 62.5
  },
  "dependencies": {
    "sections": ["background"],
    "sources": ["CMIP6_dataset", "ERA5_reanalysis"]
  },
  "context_at_start": 15.0,
  "context_at_end": 28.5,
  "git_commits": ["ghi789"],
  "issues": [],
  "notes": "Consider adding more detail to validation subsection in revision.",
  "last_update": "2025-01-15T16:00:00Z"
}
```

---

## Context Tracking

**File**: `data/state/context_tracking.json`
**Purpose**: Historical context usage tracking
**Updated**: After each context estimation

### Schema

```json
[
  {
    "timestamp": string,                // ISO 8601 timestamp
    "total_tokens": integer,            // ≥ 0
    "percentage": float,                // 0.0-100.0
    "max_tokens": integer,              // Usually 200000
    "files": [
      {
        "file": string,                 // File path
        "tokens": integer,              // ≥ 0
        "size": integer                 // Bytes
      }
    ],
    "status": enum,                     // "SAFE" | "WARNING" | "CRITICAL"
    "session": integer,                 // Session number
    "operation_count": integer          // Operations in session
  }
]
```

### Example

```json
[
  {
    "timestamp": "2025-01-15T10:00:00Z",
    "total_tokens": 12000,
    "percentage": 6.0,
    "max_tokens": 200000,
    "files": [
      {
        "file": "CLAUDE.md",
        "tokens": 2500,
        "size": 10240
      },
      {
        "file": "ARCHITECTURE.md",
        "tokens": 5000,
        "size": 20480
      },
      {
        "file": "data/state/master_state.json",
        "tokens": 500,
        "size": 2048
      }
    ],
    "status": "SAFE",
    "session": 1,
    "operation_count": 0
  },
  {
    "timestamp": "2025-01-15T11:30:00Z",
    "total_tokens": 38000,
    "percentage": 19.0,
    "max_tokens": 200000,
    "files": [
      {
        "file": "CLAUDE.md",
        "tokens": 2500,
        "size": 10240
      },
      {
        "file": "src/module1.py",
        "tokens": 8000,
        "size": 32768
      },
      {
        "file": "src/module2.py",
        "tokens": 8000,
        "size": 32768
      }
    ],
    "status": "SAFE",
    "session": 1,
    "operation_count": 15
  }
]
```

---

## Validation Rules

### Master State (Coding)

- `modules_in_progress` must have ≤ 1 item
- `current_module` must be in `modules_in_progress` (if not null)
- `tests_passing` ≤ `tests_total`
- `context_usage.percentage` = (`current_tokens` / `max_tokens`) * 100
- `version` must match pattern: `\d+\.\d+\.\d+`

### Master State (Non-Coding)

- `sections_in_progress` must have ≤ 1 item
- `current_section` must be in `sections_in_progress` (if not null)
- `word_count` ≤ `target_word_count` (typically, but can exceed)
- `references_cited` ≤ total references in bibliography

### Module State

- `tests.passing` + `tests.failing` + `tests.skipped` = `tests.total`
- `status` = "completed" → all validation checks must be true
- `end_time` > `start_time` (if both present)
- `duration_minutes` = (`end_time` - `start_time`) / 60

### Section State

- `content.word_count` ≈ sum of words in subsections
- `references.total` = length of `references.cited`
- `quality.citations_valid` → all citations in `references.cited` exist in bibliography

---

## Update Frequency

| State File | Update Frequency | Triggers |
|------------|-----------------|----------|
| master_state.json | After each operation | Module complete, session start/end |
| module_state.json | During module work | Start, progress, completion |
| section_state.json | During section writing | Start, progress, completion |
| context_tracking.json | Every estimation | Context estimation script runs |

---

## Common Operations

### Initialize Master State

```python
import json
from datetime import datetime

state = {
    "project": "myproject",
    "version": "0.1.0",
    "project_type": "coding",
    "language": "python",
    "current_phase": "setup",
    "current_module": null,
    "modules_complete": [],
    "modules_in_progress": [],
    "modules_pending": ["1.1", "1.2", "1.3"],
    "tests_passing": 0,
    "tests_total": 0,
    "context_usage": {
        "current_tokens": 0,
        "max_tokens": 200000,
        "percentage": 0.0,
        "warning_threshold": 0.30,
        "critical_threshold": 0.35
    },
    "session_info": {
        "current_session": 1,
        "session_start": datetime.now().isoformat() + "Z",
        "last_update": datetime.now().isoformat() + "Z",
        "operations_this_session": 0
    },
    "git_info": {
        "repository_initialized": False,
        "last_commit": None,
        "commits_this_session": 0,
        "branch": "main"
    },
    "metrics": {
        "total_files": 0,
        "total_lines": 0,
        "test_coverage": 0.0
    },
    "last_update": datetime.now().isoformat() + "Z"
}

with open('data/state/master_state.json', 'w') as f:
    json.dump(state, f, indent=2)
```

### Update Module Status

```python
import json
from datetime import datetime

# Read current state
with open('data/state/master_state.json', 'r') as f:
    state = json.load(f)

# Move module from pending to in_progress
module_id = "1.2"
state['modules_pending'].remove(module_id)
state['modules_in_progress'].append(module_id)
state['current_module'] = module_id
state['last_update'] = datetime.now().isoformat() + "Z"

# Write back
with open('data/state/master_state.json', 'w') as f:
    json.dump(state, f, indent=2)
```

---

**See Also**:
- 05_ENHANCEMENTS/schema_validation.md - JSON schema validation
- 03_TEMPLATES/project_types/ - State file templates
- 06_SCRIPTS_GUIDE.md - State update scripts
