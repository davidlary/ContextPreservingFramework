# Common Functions Library Guide

**File**: `scripts/common_functions.sh`
**Version**: 1.0.0
**Created**: 2025-11-13 (v4.5.1)
**Purpose**: Eliminate code duplication across framework scripts

---

## Overview

The common functions library provides shared utilities that were previously duplicated across 15+ framework scripts. By centralizing these definitions, we:

- ✅ Reduce code duplication (RULE 9)
- ✅ Ensure consistency across scripts
- ✅ Simplify maintenance
- ✅ Provide reusable utilities

---

## Usage

### Basic Usage

```bash
#!/bin/bash
# your_script.sh

set -euo pipefail

# Load common functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"

# Now you can use all functions and variables
log_info "Starting operation..."
print_separator
```

### Migrating Existing Scripts

**Before** (duplicated code):
```bash
#!/bin/bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════════════════"
echo "My Script"
echo "═══════════════════════════════════════════════════════════════════════"
```

**After** (using library):
```bash
#!/bin/bash
set -euo pipefail

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"

print_header "My Script"
```

---

## Available Functions & Variables

### Color Variables

All ANSI color codes exported as environment variables:

```bash
RED GREEN YELLOW BLUE CYAN MAGENTA WHITE NC
```

**Usage**:
```bash
echo -e "${GREEN}✅ Success${NC}"
echo -e "${RED}❌ Error${NC}"
echo -e "${YELLOW}⚠️  Warning${NC}"
```

### Logging Functions

```bash
log_info "message"       # Green [INFO] prefix
log_success "message"    # Green ✅ prefix
log_warning "message"    # Yellow [WARNING] prefix
log_error "message"      # Red [ERROR] prefix
log_debug "message"      # Cyan [DEBUG] prefix (only if DEBUG=1)
```

**Example**:
```bash
log_info "Starting process..."
log_success "Process completed"
log_warning "Disk space low"
log_error "File not found"

DEBUG=1 log_debug "Variable value: $var"
```

### Path Utilities

```bash
get_framework_root          # Returns framework root directory
is_framework_repo           # Returns 0 if in framework repo, 1 otherwise
get_state_dir              # Returns .cpf/ or . based on context
```

**Example**:
```bash
FRAMEWORK_ROOT=$(get_framework_root)
STATE_DIR=$(get_state_dir)

if is_framework_repo; then
    echo "Running in framework repository"
else
    echo "Running in user project"
fi
```

### JSON Utilities

```bash
has_jq                               # Check if jq is available
json_get <file> <path> [default]    # Safely read JSON value
```

**Example**:
```bash
if has_jq; then
    VERSION=$(json_get "data/state/master_state.json" ".version" "unknown")
    echo "Version: $VERSION"
fi
```

### File Utilities

```bash
file_modified_within <file> <seconds>    # Check if file modified recently
count_lines <file>                       # Get line count of file
```

**Example**:
```bash
if file_modified_within "master_state.json" 60; then
    echo "State file updated within last minute"
fi

LINES=$(count_lines "script.sh")
echo "Script has $LINES lines"
```

### Validation Utilities

```bash
has_command <name>      # Check if command exists
in_git_repo            # Check if in git repository
git_status_clean       # Check if working tree is clean
```

**Example**:
```bash
if has_command jq; then
    echo "jq is available"
fi

if in_git_repo && git_status_clean; then
    echo "Git repository is clean"
fi
```

### Date/Time Utilities

```bash
get_timestamp           # ISO 8601 timestamp (UTC)
get_date               # Current date YYYY-MM-DD (UTC)
get_date_ago <days>    # Date N days ago (cross-platform)
```

**Example**:
```bash
TIMESTAMP=$(get_timestamp)    # 2025-11-13T19:26:52Z
TODAY=$(get_date)             # 2025-11-13
LAST_WEEK=$(get_date_ago 7)  # 2025-11-06
```

### Separator Utilities

```bash
print_separator         # Print ═══ line
print_subseparator      # Print ─── line
print_header <title>    # Print separator + title + separator
```

**Example**:
```bash
print_header "Framework Analysis"
# Output:
# ═══════════════════════════════════════════════════════════════════════
# Framework Analysis
# ═══════════════════════════════════════════════════════════════════════

print_subseparator
# Output:
# ───────────────────────────────────────────────────────────────────────
```

---

## Migration Status

### Scripts Updated (Examples)
- ✅ `scripts/analyze_violations.sh` (v1.1.0)

### Scripts To Migrate (Remaining)
- `scripts/verify_framework_integrity.sh`
- `scripts/validate_all_rules.sh`
- `scripts/pre_checkpoint_validation.sh`
- `scripts/post_bash_error_detection.sh`
- ...and 11 more enforcement scripts

**Migration Priority**: Migrate scripts as they're modified, not all at once.

---

## Benefits

### Code Reduction
- **Before**: 15 scripts × 6 lines (colors) = 90 lines duplicated
- **After**: 1 library (240 lines) + 2 lines per script (source) = 270 lines total
- **Savings**: When >15 scripts migrate, net savings increase

### Consistency
- All scripts use identical color codes
- All scripts use identical logging format
- All scripts use identical utilities

### Maintainability
- Change colors once, affects all scripts
- Add new utility once, available everywhere
- Fix bug once, fixed for all scripts

---

## Best Practices

### 1. Always Source, Don't Execute

**Good**:
```bash
source "$SCRIPT_DIR/common_functions.sh"
```

**Bad**:
```bash
bash "$SCRIPT_DIR/common_functions.sh"  # Wrong!
```

### 2. Use SCRIPT_DIR Pattern

Always calculate script directory before sourcing:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"
```

This ensures library is found regardless of where script is called from.

### 3. Check COMMON_FUNCTIONS_LOADED

For optional loading:

```bash
if [ "${COMMON_FUNCTIONS_LOADED:-false}" != "true" ]; then
    source "$SCRIPT_DIR/common_functions.sh"
fi
```

### 4. Extend, Don't Modify

If you need project-specific utilities, create a wrapper:

```bash
# my_project_functions.sh
source "cpf/scripts/common_functions.sh"

# Add your project-specific functions
my_custom_function() {
    log_info "Custom function executing..."
}
```

---

## Testing

To verify library is working:

```bash
# Run library directly (shows help)
bash scripts/common_functions.sh

# Test in another script
bash scripts/analyze_violations.sh 30
```

---

## Version History

- **v1.0.0** (2025-11-13): Initial release
  - Color definitions
  - Logging functions
  - Path utilities
  - JSON utilities
  - File utilities
  - Validation utilities
  - Date/time utilities
  - Separator utilities

---

## See Also

- [RULE 9: Code Reuse Mandatory](../core/PROTOCOL_CORE_RULES.md)
- [Enhancement Audit 2025-11-13](../analysis/ENHANCEMENT_AUDIT_20251113.md)
- [Script Development Guide](SCRIPT_DEVELOPMENT_GUIDE.md) (if exists)

---

**Last Updated**: 2025-11-13
**Version**: 1.0.0
**Part of**: Framework v4.5.1
