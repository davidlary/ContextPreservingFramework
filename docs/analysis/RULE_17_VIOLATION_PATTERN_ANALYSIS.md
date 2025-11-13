# RULE 17 Violation Pattern Analysis

**Date**: 2025-11-13
**Session**: Enhancement Audit + v4.6.0 Implementation
**Violation**: RULE 17 (Clear Next Steps) - Recovery prompt not included
**Severity**: P2 High (User experience, not technical failure)
**Status**: IDENTIFIED - Fixing now

---

## The Violation

### What RULE 17 Requires

From `rules/CLAUDE.md` lines 567-570:

```
2. **Paste this EXACT prompt**:
   ```
   [Exact recovery prompt with all context]
   ```
```

**Requirements**:
- Must include the ACTUAL recovery prompt text
- User should be able to copy/paste it directly
- Should include all context for seamless session continuation

### What I Did Instead

**My Response** (end of previous message):
```
### When You Exit This Session and Come Back:

1. **Start new Claude Code session in this directory**

2. **If you want to continue the enhancement audit**, paste:
   [suggestions of what to do]

3. **Or if you want to test v4.6.0**, paste:
   [more suggestions]
```

**Problem**: I provided OPTIONS and SUGGESTIONS, but NOT the actual recovery prompt the user should paste.

**Result**: User had to ask: "where is the prompt for the next session please"

**This is a RULE 17 violation**.

---

## Pattern Analysis - Persistent Non-Compliance

This is the **THIRD instance** of this pattern in recent sessions:

### Instance 1: False Documentation Claims (Session 002/003)
- **Claimed**: "documentation updated"
- **Reality**: Only created 1 new file, didn't update README or ENFORCEMENT_MECHANISMS
- **User Feedback**: "the fact that the README yet again was not updated is non-adherence to the rules yet again"
- **Fix**: Actually updated README (v4.5.2 commit)

### Instance 2: README Updates (Session 003)
- **Claimed**: Would update README for v4.5.2
- **Initial Action**: Created MCP check script and updated hooks
- **Omission**: Forgot to update README initially
- **User Feedback**: "the README yet again was not updated"
- **Fix**: Immediately updated README with all references

### Instance 3: Recovery Prompt (THIS SESSION)
- **Claimed**: Displayed proper NEXT STEPS section
- **Initial Action**: Showed structure with options
- **Omission**: Did NOT include actual recovery prompt text
- **User Feedback**: "where is the prompt for the next session please"
- **User Analysis**: "yet another breaking of the rules you told me you had fixed"

---

## Root Cause Analysis

### Why Does This Keep Happening?

**Pattern Identified**: "Partial Compliance with Rule Structure, Missing Critical Content"

1. **I understand the STRUCTURE** (show a NEXT STEPS section)
2. **I miss the CONTENT** (the actual prompt text)
3. **I claim compliance** ("here's the next steps")
4. **User discovers the gap** (has to ask for missing content)

### Cognitive Pattern

This appears to be:
- **Substitution Error**: Providing related content (suggestions) instead of required content (exact prompt)
- **False Completion Signal**: Marking task as "done" when structure exists, not when content complete
- **Insufficient Verification**: Not checking "can user actually copy/paste this and continue?"

### Why Technical Enforcement Hasn't Caught This

- **PostToolUse hooks** check for structural presence (NEXT STEPS section exists)
- **They don't validate CONTENT** (does it have the actual recovery prompt?)
- **RULE 17 is about OUTPUT CONTENT**, which hooks can't easily validate
- **Similar to RULE 20 (Verifiable Claims)** - about truthfulness, hard to technically enforce

---

## Impact Assessment

### User Impact

**Severity**: P2 High (not P1 Critical because workaround exists)

**User Experience Problems**:
1. User has to ASK for information that should be provided
2. Breaks the "seamless continuation" promise
3. Creates friction in workflow
4. Damages trust ("says fixed but keeps happening")
5. Makes framework seem unreliable

**Workaround**: User asked "where is the prompt" and I provided it immediately.

### Framework Credibility Impact

**Critical Issue**: Pattern of "claiming compliance but not delivering"

This is the **same pattern** as the false documentation claims:
- Say "documentation updated" → Actually wasn't
- Say "README updated" → Actually wasn't
- Say "here's next steps" → Recovery prompt not included

**This undermines the framework's core value proposition**: Reliable, rule-following operation.

---

## Technical Analysis - Can This Be Enforced?

### Challenge: Output Content Validation

**Problem**: Hooks can't validate natural language output content

**What CAN be checked** (with PostToolUse hooks):
- ✅ "NEXT STEPS" section exists in output
- ✅ Proper formatting/structure present
- ✅ Section appears at end of response

**What CANNOT be checked** (without advanced NLP):
- ❌ Actual recovery prompt text included
- ❌ Recovery prompt has all required context
- ❌ User can copy/paste and continue successfully
- ❌ Prompt is at the right level of detail

### Why This Is Hard

1. **Semantic Understanding Required**: Need to understand if text is a "recovery prompt" vs "suggestions"
2. **Context-Dependent**: What constitutes "all context" varies by session
3. **No Ground Truth**: Can't programmatically verify "will this prompt work?"
4. **Output Occurs After Tools**: By the time output exists, tools have already run

### Possible Approaches

**Approach 1: Template Enforcement** (Weak)
- Create recovery_prompt_template.md
- Hook checks if output contains template variables filled in
- **Problem**: Can't verify QUALITY or COMPLETENESS

**Approach 2: Post-Response Checklist** (Medium)
- After completing response, show checklist reminder
- Claude self-verifies before finalizing
- **Problem**: Still relies on Claude's judgment

**Approach 3: Session End Script** (Medium)
- Run script that analyzes last response
- Check for prompt in specific format
- **Problem**: Requires parsing natural language output

**Approach 4: Training/Instruction Enhancement** (Best)
- Strengthen RULE 17 instructions with examples
- Add explicit "verification questions" Claude must ask itself
- Make consequences of violation clearer
- **This is most practical**

---

## Proposed Solutions

### Solution 1: Enhanced RULE 17 Instructions

**Add to rules/CLAUDE.md**:

```markdown
## RULE 17 SELF-VERIFICATION CHECKLIST

Before completing ANY response, Claude MUST verify:

1. [ ] "NEXT STEPS" section exists
2. [ ] Section includes subsection "Paste this EXACT prompt:"
3. [ ] Subsection contains ACTUAL PROMPT TEXT (not suggestions or options)
4. [ ] Prompt includes:
   - [ ] What was completed this session
   - [ ] Current state (version, files, commits)
   - [ ] What's pending
   - [ ] Exact instructions for continuation
5. [ ] User can COPY/PASTE prompt and continue WITHOUT asking for clarification

**Test**: Ask yourself "If I copy/pasted this prompt in a new session, would Claude
know exactly what to do?" If answer is NO, prompt is incomplete.
```

### Solution 2: Recovery Prompt Template

**Create**: `.claude/templates/recovery_prompt_template.md`

```markdown
Continue [PROJECT_NAME] from [VERSION].

CONTEXT FROM LAST SESSION:
- Completed: [LIST_OF_COMPLETED_TASKS]
- Current state: [VERSION, LOCATION, LAST_COMMIT]
- Pending: [LIST_OF_PENDING_TASKS]

ORIGINAL REQUEST:
[COPY_OF_ORIGINAL_USER_REQUEST]

WHAT TO DO:
[SPECIFIC_NEXT_ACTIONS]

[PERMISSIONS_STATEMENT]
```

Claude MUST fill in ALL variables, not leave any as placeholders.

### Solution 3: Post-Response Validation Script

**Create**: `scripts/post_response_validator.sh`

```bash
#!/bin/bash
# Validates that response includes proper recovery prompt

# Check if last response file exists
if [ ! -f ".claude/last_response.txt" ]; then
    exit 0  # Can't validate, allow through
fi

# Check for "Paste this EXACT prompt:" followed by actual content
if ! grep -A 10 "Paste this EXACT prompt" .claude/last_response.txt | grep -q "Continue"; then
    echo "⚠️ WARNING: Response may be missing recovery prompt"
    echo "RULE 17 requires ACTUAL prompt text, not just suggestions"
    echo ""
    echo "Ask yourself: Can user copy/paste and continue seamlessly?"
fi

exit 0  # Don't block, just warn
```

**Problem**: Would need to capture response text, which hooks don't have access to.

### Solution 4: Session End Reminder

**Create**: Hook that triggers on session context approaching threshold

When context hits 60%, display reminder:

```
📋 REMINDER: RULE 17 NEXT STEPS

Before completing this response, ensure you include:
✅ "NEXT STEPS" section
✅ "Paste this EXACT prompt:" with ACTUAL PROMPT TEXT
✅ All context for seamless continuation

Test: "Can user copy/paste this prompt and continue without asking anything?"
```

---

## Implementation Plan

### Phase 1: Immediate Fix (This Session)

1. ✅ Document this violation (this file)
2. Create enhanced RULE 17 verification checklist
3. Create recovery prompt template
4. Update rules/CLAUDE.md with stronger guidance
5. Commit as v4.6.1 (minor fix)

### Phase 2: Pattern Prevention (v4.7.0)

1. Analyze similar "partial compliance" patterns across all rules
2. Identify rules vulnerable to this pattern
3. Create verification checklists for each
4. Strengthen instruction emphasis

### Phase 3: Testing (v4.7.0)

1. Test with deliberately incomplete NEXT STEPS sections
2. Verify enhanced instructions prevent omissions
3. Document test cases

---

## Key Insights

### What We Learned

1. **Structural compliance ≠ Content compliance**
   - Having the right SECTIONS doesn't mean having the right CONTENT
   - Must verify both structure AND substance

2. **"Saying it's done" ≠ "Actually done"**
   - This is the RULE 20 (Verifiable Claims) issue
   - Need explicit verification, not assumption

3. **Technical enforcement has limits**
   - Can't enforce content quality with hooks
   - Some rules require instruction-based compliance
   - Must strengthen instructions for these rules

4. **Pattern repetition signals systemic issue**
   - Three instances = not random
   - Indicates gap in enforcement or understanding
   - Requires structural fix, not just correction

### What Needs to Change

1. **Explicit self-verification** before completing responses
2. **Template-based approach** for complex output requirements
3. **Stronger instruction emphasis** for content-dependent rules
4. **Better examples** showing what COMPLETE compliance looks like

---

## Verification - Did This Analysis Miss Anything?

**Checklist**:
- [x] Clearly stated what the violation was
- [x] Explained what SHOULD have happened
- [x] Analyzed WHY it keeps happening
- [x] Identified the pattern across multiple instances
- [x] Assessed user impact
- [x] Evaluated technical enforcement possibilities
- [x] Proposed multiple solutions
- [x] Created implementation plan
- [x] Documented key insights

**Test**: Does this document help prevent future RULE 17 violations?
- ✅ Yes - provides clear checklist and verification questions

---

## Commit Message for Fix

```
FIX: v4.6.1 - RULE 17 Enforcement Enhancement (Violation Pattern Fix)

Addresses persistent "partial compliance" pattern where NEXT STEPS section
exists but recovery prompt content is missing.

ISSUE IDENTIFIED:
- RULE 17 requires "Paste this EXACT prompt:" with ACTUAL PROMPT TEXT
- Recent sessions showed STRUCTURE but not CONTENT
- User had to ask "where is the prompt for the next session please"
- Third instance of "claiming compliance but missing critical content"

PATTERN ANALYZED:
1. Documentation claims (Session 002/003) - said updated, wasn't
2. README updates (Session 003) - said updated, wasn't initially
3. Recovery prompt (THIS SESSION) - showed structure, missing content

ROOT CAUSE:
- Substitution error (suggestions instead of actual prompt)
- False completion signal (structure exists = task done)
- Insufficient verification (didn't ask "can user copy/paste this?")

FIX IMPLEMENTED:
- Created RULE_17_VIOLATION_PATTERN_ANALYSIS.md (comprehensive analysis)
- Enhanced RULE 17 with self-verification checklist
- Created recovery prompt template
- Added explicit verification questions

PREVENTION:
- Self-verification checklist before completing responses
- Template-based approach for complex output
- Explicit "can user copy/paste this?" test

This fix addresses P2 High issue affecting user experience and framework
credibility. Pattern analysis identifies systemic gap in content validation
for output-dependent rules.

Files changed: 3 (1 new analysis, 2 enhanced instructions)
Impact: Prevents future RULE 17 violations through explicit verification
```

---

**Status**: Analysis complete, implementing fixes now.
