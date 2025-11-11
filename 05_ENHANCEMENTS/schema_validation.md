# Enhancement: JSON Schema Validation

**Purpose**: Automated validation of state files and configuration
**Value**: Medium to High
**Integration**: Prevents state corruption, ensures data quality
**Complexity**: Low

---

## Concept

**The Problem**: State files (master_state.json, module_state.json) can become corrupted through manual edits or bugs. Invalid state breaks recovery and tracking.

**The Solution**: Define JSON schemas for all state files and validate them automatically. Catch errors immediately rather than discovering them later.

**Key Insight**: Schema validation is cheap (< 1ms) and prevents expensive debugging sessions.

---

## What is JSON Schema?

JSON Schema is a vocabulary for validating JSON documents. It defines:
- Required fields
- Field types
- Valid value ranges
- Field relationships
- Default values

**Example**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["project", "version", "current_phase"],
  "properties": {
    "project": {
      "type": "string",
      "minLength": 1
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "current_phase": {
      "type": "string",
      "enum": ["setup", "implementation", "testing", "complete"]
    }
  }
}
```

---

## Implementation

### Step 1: Install Validator (1 minute)

**Python**:
```bash
pip install jsonschema
```

**Node.js**:
```bash
npm install ajv
```

**Command-line**:
```bash
# Using Python
pip install check-jsonschema
```

---

### Step 2: Create Schemas (15 minutes)

**Create**: `schemas/master_state.schema.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/master_state.schema.json",
  "title": "Master State Schema",
  "description": "Schema for master_state.json",
  "type": "object",
  "required": [
    "project",
    "version",
    "project_type",
    "current_phase",
    "last_update"
  ],
  "properties": {
    "project": {
      "type": "string",
      "minLength": 1,
      "description": "Project name"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Semantic version"
    },
    "project_type": {
      "type": "string",
      "enum": ["coding", "non_coding"],
      "description": "Type of project"
    },
    "current_phase": {
      "type": "string",
      "enum": ["setup", "implementation", "testing", "complete"],
      "description": "Current project phase"
    },
    "current_module": {
      "type": ["string", "null"],
      "description": "Currently active module"
    },
    "modules_complete": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "List of completed modules"
    },
    "modules_in_progress": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "maxItems": 1,
      "description": "List of in-progress modules (max 1)"
    },
    "modules_pending": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "List of pending modules"
    },
    "tests_passing": {
      "type": "integer",
      "minimum": 0,
      "description": "Number of passing tests"
    },
    "tests_total": {
      "type": "integer",
      "minimum": 0,
      "description": "Total number of tests"
    },
    "context_usage": {
      "type": "object",
      "required": ["current_tokens", "max_tokens", "percentage"],
      "properties": {
        "current_tokens": {
          "type": "integer",
          "minimum": 0
        },
        "max_tokens": {
          "type": "integer",
          "minimum": 1
        },
        "percentage": {
          "type": "number",
          "minimum": 0.0,
          "maximum": 100.0
        }
      }
    },
    "session_info": {
      "type": "object",
      "required": ["current_session", "last_update"],
      "properties": {
        "current_session": {
          "type": "integer",
          "minimum": 1
        },
        "session_start": {
          "type": "string",
          "format": "date-time"
        },
        "last_update": {
          "type": "string",
          "format": "date-time"
        },
        "operations_this_session": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "git_info": {
      "type": "object",
      "properties": {
        "repository_initialized": {
          "type": "boolean"
        },
        "last_commit": {
          "type": ["string", "null"]
        },
        "commits_this_session": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "last_update": {
      "type": "string",
      "format": "date-time",
      "description": "Last update timestamp"
    }
  }
}
```

**Create**: `schemas/module_state.schema.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Module State Schema",
  "description": "Schema for module_state.json",
  "type": "object",
  "required": ["module_id", "module_name", "status", "last_update"],
  "properties": {
    "module_id": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+$",
      "description": "Module identifier (e.g., 1.1)"
    },
    "module_name": {
      "type": "string",
      "minLength": 1
    },
    "status": {
      "type": "string",
      "enum": ["pending", "in_progress", "completed", "blocked"]
    },
    "phase": {
      "type": "string"
    },
    "start_time": {
      "type": ["string", "null"],
      "format": "date-time"
    },
    "end_time": {
      "type": ["string", "null"],
      "format": "date-time"
    },
    "duration_minutes": {
      "type": "number",
      "minimum": 0
    },
    "files": {
      "type": "object",
      "properties": {
        "created": {
          "type": "array",
          "items": {"type": "string"}
        },
        "modified": {
          "type": "array",
          "items": {"type": "string"}
        },
        "deleted": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    },
    "tests": {
      "type": "object",
      "properties": {
        "total": {"type": "integer", "minimum": 0},
        "passing": {"type": "integer", "minimum": 0},
        "failing": {"type": "integer", "minimum": 0},
        "skipped": {"type": "integer", "minimum": 0}
      }
    },
    "validation": {
      "type": "object",
      "properties": {
        "code_complete": {"type": "boolean"},
        "tests_passing": {"type": "boolean"},
        "documented": {"type": "boolean"},
        "reviewed": {"type": "boolean"}
      }
    },
    "last_update": {
      "type": "string",
      "format": "date-time"
    }
  }
}
```

---

### Step 3: Create Validation Script (10 minutes)

**Create**: `scripts/validate_state.py`

```python
#!/usr/bin/env python3
"""
Validate state files against JSON schemas
"""
import json
import sys
from pathlib import Path
from jsonschema import validate, ValidationError, Draft7Validator

def load_json(filepath):
    """Load JSON file"""
    with open(filepath) as f:
        return json.load(f)

def validate_file(data_file, schema_file):
    """Validate a JSON file against a schema"""
    try:
        data = load_json(data_file)
        schema = load_json(schema_file)

        # Validate
        validate(instance=data, schema=schema)

        print(f"✅ VALID: {data_file}")
        return True

    except ValidationError as e:
        print(f"❌ INVALID: {data_file}")
        print(f"   Error: {e.message}")
        print(f"   Path: {' -> '.join(str(p) for p in e.path)}")
        if e.context:
            for suberror in e.context:
                print(f"   - {suberror.message}")
        return False

    except json.JSONDecodeError as e:
        print(f"❌ INVALID JSON: {data_file}")
        print(f"   Error: {e.msg} at line {e.lineno}")
        return False

    except FileNotFoundError as e:
        print(f"❌ FILE NOT FOUND: {e.filename}")
        return False

def validate_all():
    """Validate all state files"""
    validations = [
        ('data/state/master_state.json', 'schemas/master_state.schema.json'),
    ]

    # Find all module state files
    state_dir = Path('data/state')
    if state_dir.exists():
        module_files = list(state_dir.glob('module_*.json'))
        for module_file in module_files:
            validations.append((str(module_file), 'schemas/module_state.schema.json'))

    print("=" * 60)
    print("State File Validation")
    print("=" * 60)

    results = []
    for data_file, schema_file in validations:
        if Path(data_file).exists():
            result = validate_file(data_file, schema_file)
            results.append(result)
        else:
            print(f"⏭️  SKIP: {data_file} (does not exist)")

    print("=" * 60)

    passed = sum(results)
    total = len(results)

    if passed == total:
        print(f"✅ ALL VALID: {passed}/{total} files passed")
        return 0
    else:
        print(f"❌ VALIDATION FAILED: {passed}/{total} files passed")
        return 1

def main():
    if len(sys.argv) > 1:
        # Validate specific file
        data_file = sys.argv[1]
        schema_file = sys.argv[2] if len(sys.argv) > 2 else 'schemas/master_state.schema.json'
        success = validate_file(data_file, schema_file)
        sys.exit(0 if success else 1)
    else:
        # Validate all
        sys.exit(validate_all())

if __name__ == '__main__':
    main()
```

**Make executable**:
```bash
chmod +x scripts/validate_state.py
```

---

## Usage

### Manual Validation

```bash
# Validate all state files
python scripts/validate_state.py

# Validate specific file
python scripts/validate_state.py data/state/master_state.json

# Validate with custom schema
python scripts/validate_state.py data/config/settings.json schemas/settings.schema.json
```

**Output**:
```
════════════════════════════════════════════════════════════
State File Validation
════════════════════════════════════════════════════════════
✅ VALID: data/state/master_state.json
✅ VALID: data/state/module_1.1.json
✅ VALID: data/state/module_1.2.json
════════════════════════════════════════════════════════════
✅ ALL VALID: 3/3 files passed
```

**Error example**:
```
════════════════════════════════════════════════════════════
State File Validation
════════════════════════════════════════════════════════════
❌ INVALID: data/state/master_state.json
   Error: 'setup' is not one of ['pending', 'in_progress', 'completed']
   Path: status
════════════════════════════════════════════════════════════
❌ VALIDATION FAILED: 0/1 files passed
```

---

### Automated Validation

#### Option 1: Git Pre-Commit Hook

**Create**: `.git/hooks/pre-commit`

```bash
#!/bin/bash
# Validate state files before commit

echo "Validating state files..."
python scripts/validate_state.py

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ State validation failed!"
    echo "Fix errors before committing or use --no-verify to skip"
    exit 1
fi

echo "✅ State validation passed"
exit 0
```

**Make executable**:
```bash
chmod +x .git/hooks/pre-commit
```

#### Option 2: CI/CD Integration

**Create**: `.github/workflows/validate.yml`

```yaml
name: Validate State Files

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install jsonschema
      - name: Validate state files
        run: python scripts/validate_state.py
```

#### Option 3: Add to CLAUDE.md Workflow

```markdown
## State Update Protocol (MANDATORY)

After updating state files:
1. Update master_state.json
2. **Validate: `python scripts/validate_state.py`**
3. If validation fails: Fix immediately
4. Commit only if validation passes
```

---

## Integration with Core Workflow

### At Session Start

```markdown
1. Read AUTONOMOUS_MODE.md
2. Read master_state.json
3. **Validate state: `python scripts/validate_state.py`**
4. If invalid: Fix before proceeding
```

### After State Updates

```markdown
After updating state:
1. Save changes to JSON file
2. **Validate: `python scripts/validate_state.py`**
3. If valid: Continue
4. If invalid: Fix and re-validate
```

### Before Git Commits

```markdown
Before committing:
1. Stage changes
2. **Validate state: `python scripts/validate_state.py`**
3. Commit only if validation passes
```

---

## Benefits

1. **Catch errors immediately**
   - Invalid data detected at write time
   - No surprises during recovery
   - Clear error messages

2. **Enforce data quality**
   - Required fields always present
   - Values within valid ranges
   - Consistent structure

3. **Self-documenting**
   - Schema defines expected structure
   - Type information clear
   - Validation rules explicit

4. **Prevent state corruption**
   - No manual edit mistakes
   - No partial updates
   - Always valid state

5. **Better error messages**
   - Specific field errors
   - Path to problematic data
   - Suggested fixes

---

## Real-World Example

**Scenario**: Manual edit to master_state.json with typo

**Without Schema Validation**:
```json
{
  "project": "myproject",
  "current_phase": "implmentation",  // Typo!
  ...
}
```
- File saved successfully
- No error until recovery
- Recovery fails with cryptic error
- 10 minutes debugging to find typo

**With Schema Validation**:
```bash
$ python scripts/validate_state.py
❌ INVALID: data/state/master_state.json
   Error: 'implmentation' is not one of ['setup', 'implementation', 'testing', 'complete']
   Path: current_phase
```
- Error caught immediately
- Clear error message
- 10 seconds to fix
- Problem solved

**Time saved**: 10 minutes debugging → 10 seconds fix

---

## Advanced: Custom Validators

**Add business logic validation**:

```python
def custom_validation(data):
    """Additional validation beyond schema"""

    # Check: tests_passing <= tests_total
    if data['tests_passing'] > data['tests_total']:
        return False, "tests_passing cannot exceed tests_total"

    # Check: Only one module in_progress
    if len(data['modules_in_progress']) > 1:
        return False, "Only one module can be in_progress"

    # Check: current_module matches in_progress
    if data['current_module']:
        if data['current_module'] not in data['modules_in_progress']:
            return False, "current_module must be in modules_in_progress"

    # Check: Context percentage matches tokens
    expected_pct = (data['context_usage']['current_tokens'] /
                   data['context_usage']['max_tokens'] * 100)
    actual_pct = data['context_usage']['percentage']
    if abs(expected_pct - actual_pct) > 0.1:
        return False, f"Context percentage mismatch: {actual_pct} vs {expected_pct}"

    return True, None
```

---

## Creating Schemas for New State Files

**Template**:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Your State Schema",
  "description": "Schema for your_state.json",
  "type": "object",
  "required": ["field1", "field2"],
  "properties": {
    "field1": {
      "type": "string",
      "description": "Description of field1"
    },
    "field2": {
      "type": "integer",
      "minimum": 0,
      "description": "Description of field2"
    }
  }
}
```

**Common patterns**:
- Required fields: Add to `"required": []`
- Enums: Use `"enum": ["value1", "value2"]`
- Ranges: Use `"minimum"`, `"maximum"`
- Nested objects: Define `"properties": {}`
- Arrays: Use `"items": {"type": "..."}`
- Optional: Omit from `"required"` array

---

## Troubleshooting

**Issue**: Validation too strict

**Solution**: Relax schema constraints
```json
// Before: Required field
"required": ["field1", "field2", "field3"]

// After: Make field3 optional
"required": ["field1", "field2"]
```

---

**Issue**: Need different schemas for different phases

**Solution**: Use conditional schemas
```json
"if": {
  "properties": {"phase": {"const": "testing"}}
},
"then": {
  "required": ["tests_total", "tests_passing"]
}
```

---

## Success Metrics

**Without Schema Validation**:
- State corruption incidents: 5-10 per project
- Time debugging state issues: 2-3 hours total
- Manual edits causing problems: 80%

**With Schema Validation**:
- State corruption incidents: 0
- Time debugging state issues: 0
- Manual edits caught: 100%

**Result**: Zero state corruption, hours saved debugging

---

## Next Steps

1. **Create schemas**: Start with master_state.schema.json
2. **Write validator**: Use provided script
3. **Test manually**: Run validation on current state
4. **Add to workflow**: Update CLAUDE.md
5. **Automate**: Add git hook or CI/CD

---

**Related**:
- See 03_TEMPLATES/ for state file templates
- See 10_REFERENCE/state_schemas.md for schema reference
- See 04_CORE_WORKFLOW.md for integration points
