# Example: Academic Research Paper

**Project**: Machine learning research paper on climate model uncertainty
**Type**: Non-coding (Research Paper)
**Duration**: 8-10 hours (5 sections across 3-4 sessions)
**Target**: 8,000 words, 30+ citations
**Framework**: Context-Preserving v3.0

---

## Project Overview

**Title**: "Quantifying Uncertainty in Climate Model Predictions Using Ensemble Deep Learning"

**Abstract**: This paper presents a novel ensemble deep learning approach for quantifying uncertainty in regional climate predictions, comparing Bayesian neural networks with traditional ensemble methods.

**Target Journal**: *Climate Dynamics* (Springer)
**Format**: Standard research paper (Introduction, Methods, Results, Discussion, Conclusion)
**Word Count**: 8,000 words
**Citations**: 30-40 references

---

## Framework Setup (15 minutes)

### Step 1: Initialize Framework

```bash
cd ~/research/climate_uncertainty_paper
python scripts/setup_framework.py --interactive

# Prompts:
# Project name? climate_uncertainty_paper
# Project type? non_coding
# Domain? research
# Target word count? 8000

# Output: Framework files created
```

**Or manual setup**:
```bash
cd ~/research/climate_uncertainty_paper

# Copy framework files
cp -r ~/ContextPreservingFramework/03_TEMPLATES/CLAUDE.md.template ./CLAUDE.md
cp -r ~/ContextPreservingFramework/03_TEMPLATES/AUTONOMOUS_MODE.md.template ./AUTONOMOUS_MODE.md
cp -r ~/ContextPreservingFramework/03_TEMPLATES/project_types/non_coding/master_state_writing.json ./data/state/master_state.json

# Customize
vi CLAUDE.md  # Set project details
vi AUTONOMOUS_MODE.md  # Set STATUS: ACTIVE, scope: All sections
```

### Step 2: Define Paper Structure

**Create**: `STRUCTURE.md`

```markdown
# Paper Structure - Climate Uncertainty

## Sections

### Section 1: Introduction (1,500 words, 8 citations)
- Climate model uncertainty problem
- Current uncertainty quantification methods
- Limitations of existing approaches
- Paper contributions

### Section 2: Background & Related Work (1,800 words, 12 citations)
- Ensemble climate modeling
- Deep learning for climate
- Uncertainty quantification methods
- Bayesian neural networks

### Section 3: Methods (2,000 words, 6 citations)
- Dataset description (CMIP6)
- Model architecture
- Training procedure
- Uncertainty estimation techniques

### Section 4: Results (1,800 words, 3 citations)
- Prediction accuracy
- Uncertainty calibration
- Comparison with baselines
- Case study: Regional predictions

### Section 5: Discussion & Conclusion (900 words, 5 citations)
- Interpretation of results
- Limitations
- Future work
- Conclusions

## Figures & Tables
- Figure 1: Model architecture diagram
- Figure 2: Prediction vs. ground truth
- Figure 3: Uncertainty calibration plots
- Figure 4: Regional case study maps
- Table 1: Dataset statistics
- Table 2: Quantitative comparison
```

### Step 3: Gather References

**Create**: `references/sources.md`

```markdown
# Key References

## Primary Sources (Must Cite)
1. Haustein et al. (2019) - Climate model ensembles
2. Reichstein et al. (2019) - Deep learning for Earth sciences
3. Gal & Ghahramani (2016) - Dropout as Bayesian approximation
...

## Secondary Sources
[Additional references]

## Data Sources
- CMIP6 climate model outputs
- ERA5 reanalysis for validation
```

---

## Project Structure

```
climate_uncertainty_paper/
├── CLAUDE.md
├── AUTONOMOUS_MODE.md
├── STRUCTURE.md
├── manuscript/
│   ├── main.md              # Master document
│   ├── sections/
│   │   ├── 01_introduction.md
│   │   ├── 02_background.md
│   │   ├── 03_methods.md
│   │   ├── 04_results.md
│   │   └── 05_discussion.md
│   └── abstract.md
├── figures/
│   ├── figure1_architecture.png
│   ├── figure2_predictions.png
│   └── ...
├── references/
│   ├── sources.md           # Annotated bibliography
│   └── bibliography.bib     # BibTeX entries
├── data/
│   └── state/
│       ├── master_state.json
│       └── section_states/
└── notes/
    └── research_notes.md
```

---

## Implementation Session Example

### Session 1: Introduction & Background (2.5 hours)

**Context Budget**: Start 0% → Target < 35%

#### Starting Prompt

```
Resume climate_uncertainty_paper project - Session 1

Location: ~/research/climate_uncertainty_paper
Autonomous mode: ACTIVE (see AUTONOMOUS_MODE.md)

Goal: Write Section 1 (Introduction) and Section 2 (Background)

Instructions:
1. Read STRUCTURE.md for section requirements
2. Read references/sources.md for key papers
3. Write Section 1: Introduction (1,500 words, 8 citations)
4. Write Section 2: Background (1,800 words, 12 citations)
5. Keep context < 35%
```

#### Section 1: Introduction (1.5 hours)

**Writing Process**:

1. **Outline** (15 min)
   - Problem statement
   - Motivation
   - Contributions
   - Paper organization

2. **First Draft** (60 min)
   - Write freely, focus on flow
   - Add citation placeholders: [Haustein2019]
   - Target: 1,500 words

3. **Revision** (15 min)
   - Check argument flow
   - Verify all claims cited
   - Polish language

**Output**: `manuscript/sections/01_introduction.md`

**Word Count**: 1,487 words
**Citations**: 8 (all properly formatted)
**Context**: 0% → 15%

**Git Commit**:
```
[Session 1] Section 1: Introduction - COMPLETE

Changes:
- Created: manuscript/sections/01_introduction.md (1,487 words)
- Citations: 8 properly formatted references
- Structure: Problem → Motivation → Contributions → Organization

Quality: First draft complete, needs peer review
Next: Section 2 (Background & Related Work)

🤖 Generated with Claude Code
```

#### Section 2: Background & Related Work (1 hour)

**Writing Process**:

1. **Review Literature** (20 min)
   - Read notes from key papers
   - Organize into subsections:
     - Ensemble climate modeling
     - Deep learning for climate
     - Uncertainty quantification
     - Bayesian approaches

2. **Write Subsections** (35 min)
   - 2.1: Ensemble modeling (450 words, 4 citations)
   - 2.2: Deep learning (450 words, 3 citations)
   - 2.3: Uncertainty methods (450 words, 3 citations)
   - 2.4: Bayesian approaches (450 words, 2 citations)

3. **Connect to Our Work** (5 min)
   - Add transition to methods
   - Highlight gaps our work addresses

**Output**: `manuscript/sections/02_background.md`

**Word Count**: 1,812 words
**Citations**: 12
**Context**: 15% → 28%

**Session End Actions**:
1. Update `data/state/master_state.json`:
   - sections_complete: ["01_introduction", "02_background"]
   - word_count: 3299
   - references_cited: 20
2. Create recovery prompt
3. Git commit

**Final Context**: 28% ✅

---

### Session 2: Methods (2 hours)

**Starting Context**: 0% (new session)

#### Starting Prompt

```
Resume climate_uncertainty_paper project - Session 2

Location: ~/research/climate_uncertainty_paper
Git commit: [hash from Session 1]
Autonomous mode: ACTIVE

Status:
✅ Completed: Sections 1-2 (3,299 words, 20 citations)
🔄 In progress: Section 3 (Methods)
⏳ Next: Section 4 (Results)

Instructions:
1. Read data/state/master_state.json
2. Review previous sections for consistency
3. Write Section 3: Methods (2,000 words, 6 citations)
4. Create Figure 1 (architecture diagram)
5. Keep context < 35%
```

#### Section 3: Methods (2 hours)

**Writing Process**:

1. **Data Description** (30 min)
   - CMIP6 dataset details
   - Preprocessing steps
   - Train/validation/test splits
   - Table 1: Dataset statistics

2. **Model Architecture** (40 min)
   - Network design
   - Bayesian layers
   - Ensemble configuration
   - Figure 1: Architecture diagram

3. **Training & Evaluation** (30 min)
   - Training procedure
   - Hyperparameters
   - Evaluation metrics
   - Uncertainty quantification

4. **Technical Details** (20 min)
   - Implementation details
   - Computational resources
   - Reproducibility statement

**Outputs**:
- `manuscript/sections/03_methods.md` (2,004 words)
- `figures/figure1_architecture.png` (created)
- `figures/table1_data.md` (data for table)

**Context**: 0% → 22%

**Git Commit**:
```
[Session 2] Section 3: Methods - COMPLETE

Changes:
- Created: manuscript/sections/03_methods.md (2,004 words)
- Figures: figure1_architecture.png, table1_data.md
- Citations: 6 technical references
- Total progress: 5,303 words (66% of target)

Next: Section 4 (Results)

🤖 Generated with Claude Code
```

---

### Session 3: Results & Discussion (2.5 hours)

**Starting Context**: 0%

#### Section 4: Results (1.5 hours)

**Writing Process**:

1. **Quantitative Results** (40 min)
   - Prediction accuracy metrics
   - Table 2: Comparison with baselines
   - Statistical significance tests

2. **Uncertainty Analysis** (30 min)
   - Calibration plots (Figure 3)
   - Reliability diagrams
   - Uncertainty vs. error correlation

3. **Case Study** (20 min)
   - Regional predictions for North America
   - Figure 4: Spatial uncertainty maps
   - Qualitative analysis

**Output**: `manuscript/sections/04_results.md` (1,795 words)
**Context**: 0% → 18%

#### Section 5: Discussion & Conclusion (1 hour)

**Writing Process**:

1. **Interpretation** (25 min)
   - What results mean
   - Comparison with literature
   - Implications for climate science

2. **Limitations** (15 min)
   - Dataset limitations
   - Model assumptions
   - Generalization concerns

3. **Future Work** (10 min)
   - Extensions to other variables
   - Longer time horizons
   - Real-time applications

4. **Conclusions** (10 min)
   - Summary of contributions
   - Practical recommendations
   - Final thoughts

**Output**: `manuscript/sections/05_discussion.md` (912 words)
**Context**: 18% → 30%

**Final Session Actions**:
1. Compile full manuscript: `manuscript/main.md`
2. Update word count: 8,010 words ✅
3. Verify all citations: 34 references ✅
4. Run citation validator
5. Git commit with tag

**Final Context**: 30% ✅

---

### Session 4: Revision & Finalization (1.5 hours)

**Tasks**:

1. **Full Read-Through** (30 min)
   - Check argument flow
   - Verify section transitions
   - Ensure consistency

2. **Citation Validation** (20 min)
   - All citations in bibliography
   - Format matches journal style
   - CrossRef validation

3. **Figure Quality Check** (20 min)
   - High resolution (300 dpi)
   - Readable labels
   - Consistent style

4. **Export Formats** (20 min)
   - Convert to LaTeX
   - Generate PDF
   - Word format for collaborators

---

## Lessons Learned

### What Worked Well

1. **Clear structure**: STRUCTURE.md guided writing throughout
2. **Session breaks**: Natural stopping points between sections
3. **Citation management**: BibTeX from start prevented late-stage chaos
4. **Context tracking**: Never exceeded 35%, maintained focus
5. **Autonomous mode**: Uninterrupted writing flow

### Challenges

1. **Technical depth**: Balancing detail vs. accessibility
2. **Figure creation**: Took longer than writing (not counted in time)
3. **Citation verification**: Some papers harder to access
4. **Word count targets**: Methods section ran long, had to trim

### Context Management

- Session 1: 0% → 28% (2 sections, 2.5 hours)
- Session 2: 0% → 22% (1 section, 2 hours)
- Session 3: 0% → 30% (2 sections, 2.5 hours)
- Session 4: 0% → 25% (revision, 1.5 hours)
- **Total**: 8.5 hours, 4 sessions

### Metrics

- **Final word count**: 8,010 words ✅
- **Citations**: 34 references ✅
- **Figures**: 4
- **Tables**: 2
- **Sessions**: 4
- **Total time**: 8.5 hours

---

## Key Takeaways

1. **Structure first**: Detailed STRUCTURE.md made writing efficient
2. **Write then revise**: First draft focus on content, not polish
3. **Citations as you go**: Don't leave for end
4. **Session breaks are features**: Natural stopping between sections
5. **Context preservation works**: Never lost thread across sessions

---

## Applicability

**This workflow applies to**:
- Journal papers
- Conference papers
- Technical reports
- Thesis chapters
- Grant proposals

**Key adaptation**: Adjust section structure and word counts for target format
