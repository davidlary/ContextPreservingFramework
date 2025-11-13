#!/bin/bash
# analyze_violations.sh - Comprehensive violation log analysis
# Purpose: Analyze violation logs to identify patterns, trends, and improvement opportunities
# Version: 1.1.0 (Updated v4.5.1 - now uses common_functions.sh)
# Usage: bash scripts/analyze_violations.sh [days]
#
# OUTPUT:
# - Summary statistics
# - Trend analysis
# - Rule effectiveness metrics
# - Recommendations for improvement

set -euo pipefail

# Load common functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_functions.sh"

# Configuration
PROJECT_ROOT="${PWD}"
ANALYSIS_DAYS="${1:-30}"  # Default: analyze last 30 days

# Determine if this is a user project (.cpf/) or framework repository (logs/)
if [ -d ".cpf" ]; then
    # User project structure
    VIOLATIONS_LOG="${PROJECT_ROOT}/.cpf/issues/violations.log"
    VIOLATIONS_JSON="${PROJECT_ROOT}/.cpf/issues/violations.json"
else
    # Framework repository structure
    VIOLATIONS_LOG="${PROJECT_ROOT}/logs/violations.log"
    VIOLATIONS_JSON="${PROJECT_ROOT}/logs/violations.json"
fi

print_header "📊 VIOLATION LOG ANALYSIS"
echo "Analysis period: Last $ANALYSIS_DAYS days"
echo "Timestamp: $(get_timestamp)"
echo ""

# Check if violations exist
if [ ! -f "$VIOLATIONS_JSON" ]; then
    echo -e "${YELLOW}⚠️  No violation logs found${NC}"
    echo ""
    echo "Violation logging system is installed but no violations have been logged yet."
    echo "This is expected if:"
    echo "  • Framework was just installed"
    echo "  • All rules are being followed perfectly"
    echo "  • Enforcement scripts haven't been triggered yet"
    echo ""
    echo "To start logging violations:"
    echo "  1. Use the framework in a project"
    echo "  2. Enforcement scripts will automatically log violations"
    echo "  3. Run this analysis again after some usage"
    exit 0
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq is required for analysis${NC}"
    echo "Install jq: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Calculate cutoff date
CUTOFF_DATE=$(date -u -v-${ANALYSIS_DAYS}d +"%Y-%m-%d" 2>/dev/null || date -u -d "${ANALYSIS_DAYS} days ago" +"%Y-%m-%d" 2>/dev/null || date -u +"%Y-%m-%d")

# 1. SUMMARY STATISTICS
echo -e "${BLUE}[1/7] Summary Statistics${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

TOTAL_VIOLATIONS=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date)) | length' "$VIOLATIONS_JSON")
BLOCKED=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date and .severity == "BLOCK")) | length' "$VIOLATIONS_JSON")
WARNED=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date and .severity == "WARN")) | length' "$VIOLATIONS_JSON")
INFO=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date and .severity == "INFO")) | length' "$VIOLATIONS_JSON")

echo "Total violations: $TOTAL_VIOLATIONS"
echo "  • Blocked: $BLOCKED ($(awk "BEGIN {printf \"%.1f\", ($BLOCKED/$TOTAL_VIOLATIONS)*100}")%)"
echo "  • Warnings: $WARNED ($(awk "BEGIN {printf \"%.1f\", ($WARNED/$TOTAL_VIOLATIONS)*100}")%)"
echo "  • Info: $INFO ($(awk "BEGIN {printf \"%.1f\", ($INFO/$TOTAL_VIOLATIONS)*100}")%)"
echo ""

# 2. VIOLATIONS BY RULE
echo -e "${BLUE}[2/7] Violations by Rule (Top 10)${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

jq --arg date "$CUTOFF_DATE" -r '
    .violations
    | map(select(.date >= $date))
    | group_by(.rule)
    | map({rule: .[0].rule, count: length, blocked: (map(select(.severity == "BLOCK")) | length)})
    | sort_by(.count)
    | reverse
    | .[:10]
    | .[]
    | "  \(.rule): \(.count) total (\(.blocked) blocked)"
' "$VIOLATIONS_JSON"
echo ""

# 3. TREND ANALYSIS
echo -e "${BLUE}[3/7] Trend Analysis (Daily)${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

# Get last 7 days of data
for i in {6..0}; do
    DAY=$(date -u -v-${i}d +"%Y-%m-%d" 2>/dev/null || date -u -d "${i} days ago" +"%Y-%m-%d" 2>/dev/null || date -u +"%Y-%m-%d")
    DAY_COUNT=$(jq --arg day "$DAY" '.violations | map(select(.date == $day)) | length' "$VIOLATIONS_JSON")
    DAY_BLOCKS=$(jq --arg day "$DAY" '.violations | map(select(.date == $day and .severity == "BLOCK")) | length' "$VIOLATIONS_JSON")

    # Create bar chart
    BAR=""
    for ((j=0; j<DAY_COUNT && j<50; j++)); do
        BAR="${BAR}█"
    done

    printf "  %s: %3d violations (%2d blocks) %s\n" "$DAY" "$DAY_COUNT" "$DAY_BLOCKS" "$BAR"
done
echo ""

# 4. MOST PROBLEMATIC RULES
echo -e "${BLUE}[4/7] Most Problematic Rules (Blocked Operations)${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

jq --arg date "$CUTOFF_DATE" -r '
    .violations
    | map(select(.date >= $date and .severity == "BLOCK"))
    | group_by(.rule)
    | map({rule: .[0].rule, count: length})
    | sort_by(.count)
    | reverse
    | .[:5]
    | .[]
    | "  \(.rule): \(.count) blocks"
' "$VIOLATIONS_JSON"
echo ""

# 5. RULE EFFECTIVENESS
echo -e "${BLUE}[5/7] Rule Effectiveness Analysis${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

# Calculate effectiveness (warnings vs blocks)
jq --arg date "$CUTOFF_DATE" -r '
    .violations
    | map(select(.date >= $date))
    | group_by(.rule)
    | map({
        rule: .[0].rule,
        total: length,
        blocked: (map(select(.severity == "BLOCK")) | length),
        warned: (map(select(.severity == "WARN")) | length),
        block_rate: ((map(select(.severity == "BLOCK")) | length) / length * 100)
    })
    | sort_by(.block_rate)
    | reverse
    | .[]
    | "  \(.rule):"
    + "\n    Total: \(.total), Blocked: \(.blocked), Warned: \(.warned)"
    + "\n    Effectiveness: \(.block_rate | round)% (higher = more violations blocked)"
' "$VIOLATIONS_JSON"
echo ""

# 6. COMMON VIOLATION MESSAGES
echo -e "${BLUE}[6/7] Common Violation Messages (Top 10)${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

jq --arg date "$CUTOFF_DATE" -r '
    .violations
    | map(select(.date >= $date))
    | group_by(.message)
    | map({message: .[0].message, count: length, rule: .[0].rule})
    | sort_by(.count)
    | reverse
    | .[:10]
    | .[]
    | "  [\(.rule)] \(.message) (\(.count)x)"
' "$VIOLATIONS_JSON" | fold -w 75 -s
echo ""

# 7. RECOMMENDATIONS
echo -e "${BLUE}[7/7] Improvement Recommendations${NC}"
echo "───────────────────────────────────────────────────────────────────────"
echo ""

# Generate recommendations based on data
TOTAL_VIOLATIONS=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date)) | length' "$VIOLATIONS_JSON")
BLOCKED=$(jq --arg date "$CUTOFF_DATE" '.violations | map(select(.date >= $date and .severity == "BLOCK")) | length' "$VIOLATIONS_JSON")

if [ "$TOTAL_VIOLATIONS" -eq 0 ]; then
    echo -e "${GREEN}✅ Excellent! No violations detected in the analysis period.${NC}"
    echo ""
    echo "This suggests:"
    echo "  • All rules are being followed"
    echo "  • Enforcement is working as intended"
    echo "  • No immediate improvements needed"
elif [ "$BLOCKED" -gt "$((TOTAL_VIOLATIONS / 2))" ]; then
    echo -e "${YELLOW}⚠️  High block rate detected (>50% of violations)${NC}"
    echo ""
    echo "Recommendations:"
    echo "  1. Review blocked operations to understand common causes"
    echo "  2. Consider if rules are too strict for current workflow"
    echo "  3. Add more educational warnings before blocks"
    echo "  4. Update documentation to prevent common violations"
else
    echo -e "${CYAN}ℹ️  Moderate violation rate detected${NC}"
    echo ""
    echo "Recommendations:"
    echo "  1. Review top 3 most violated rules"
    echo "  2. Check if enforcement mechanisms need strengthening"
    echo "  3. Consider adding monitoring for behavioral rules"
    echo "  4. Update user guidance for problem areas"
fi

echo ""

# Top 3 rules to focus on
TOP_RULES=$(jq --arg date "$CUTOFF_DATE" -r '
    .violations
    | map(select(.date >= $date))
    | group_by(.rule)
    | map({rule: .[0].rule, count: length})
    | sort_by(.count)
    | reverse
    | .[:3]
    | .[]
    | .rule
' "$VIOLATIONS_JSON")

if [ -n "$TOP_RULES" ]; then
    echo "Focus areas for improvement:"
    echo "$TOP_RULES" | while read -r rule; do
        echo "  • $rule"
    done
    echo ""
fi

echo "═══════════════════════════════════════════════════════════════════════"
echo ""
echo "For detailed analysis, examine: $VIOLATIONS_JSON"
echo "To export violations: bash scripts/log_violation.sh && export_violations"
echo ""
