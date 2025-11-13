#!/bin/bash
#
# pre_checkpoint_validation.sh - RULE 7 Enforcement (Thin Wrapper)
#
# Purpose: Validate all 33 checklist items BEFORE allowing checkpoint
# Trigger: PreToolUse hook before operations when checkpoint is imminent
# Rule: RULE 7 - Validation Gates
# Version: 2.0.0 (v4.6.0 - Modular architecture)
# Date: 2025-11-13
#
# This script orchestrates the comprehensive 33-point validation checklist
# from rules/CLAUDE.md before allowing a checkpoint to proceed.
# It loads modular check components and coordinates validation.
#
# Architecture (v4.6.0):
# - validation_core.sh: Orchestration and threshold checking
# - code_quality_checks.sh: Checks 1-8 (syntax, style, placeholders)
# - documentation_checks.sh: Checks 14-18 (README, docs, changelog)
# - state_tracking_checks.sh: Checks 19-23 (state files, logs)
#
# Exit codes:
# 0 - Validation passed or checkpoint not imminent (allow operation)
# 2 - Validation failed (block operation, must fix issues first)
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# LOAD LIBRARIES AND MODULES
# ═══════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions library (colors, logging, utilities)
source "$SCRIPT_DIR/common_functions.sh"

# Load checkpoint validation modules
source "$SCRIPT_DIR/checkpoint/validation_core.sh"
source "$SCRIPT_DIR/checkpoint/code_quality_checks.sh"
source "$SCRIPT_DIR/checkpoint/documentation_checks.sh"
source "$SCRIPT_DIR/checkpoint/state_tracking_checks.sh"

# ═══════════════════════════════════════════════════════════════════════
# MAIN VALIDATION ORCHESTRATION
# ═══════════════════════════════════════════════════════════════════════

# Check if checkpoint is imminent
if ! check_context_threshold && ! check_module_complete; then
    # Checkpoint not imminent, skip validation
    exit 0
fi

# Checkpoint is imminent - run full validation
run_all_checks

# Exit code set by report_results() in validation_core.sh
