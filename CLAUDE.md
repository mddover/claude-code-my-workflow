# CLAUDE.MD -- Linguistics Research Workflow

**Project:** Syntax & Psycholinguistics Research
**Institution:** Northwestern University
**Researcher:** Michael Dover
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile and confirm output at the end of every task
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md
- **No em-dashes** -- do not use em-dashes in writing
- **No plagiarism** -- when describing ideas from a cited source, use different language; never copy verbiage from the source

---

## Folder Structure

```
linguistics-workflow/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── Bibliography/                # .bib files (references.bib)
├── Papers/                      # LaTeX papers, per-project subdirs
│   ├── anti-c-command/
│   ├── symbiotic-gaps/
│   ├── control-scope-reconstruction/
│   └── dissertation-prospectus/
├── Presentations/               # PowerPoint (.pptx) files
├── Figures/                     # Shared figures and images
├── Preambles/                   # Shared LaTeX preambles
├── R/                           # Analysis scripts, per-project subdirs
│   ├── symbiotic-gaps/
│   └── control-scope-reconstruction/
├── Data/                        # Experimental data (gitignored)
├── scripts/                     # Utility scripts
├── explorations/                # Research sandbox (see rules)
├── quality_reports/             # Plans, session logs, merge reports
└── templates/                   # Document templates
```

---

## Commands

```bash
# LaTeX (3-pass, XeLaTeX + biber)
cd Papers/project-name && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex && \
  biber file && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex && \
  TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode file.tex

# Quality score
python scripts/quality_score.py Papers/project-name/file.tex
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for review |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass XeLaTeX + biber |
| `/extract-tikz [file]` | TikZ/forest → PDF → SVG |
| `/proofread [file]` | Grammar/typo/overflow review |
| `/visual-audit [file]` | Slide layout audit |
| `/pedagogy-review [file]` | Narrative, notation, pacing review |
| `/review-r [file]` | R code quality review |
| `/slide-excellence [file]` | Combined multi-agent review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge design/argumentation |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/review-paper [file]` | Manuscript review |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/learn [skill-name]` | Extract discovery into persistent skill |
| `/context-status` | Show session health + context usage |
| `/deep-audit` | Repository-wide consistency audit |

---

## LaTeX Conventions

**Compiler:** XeLaTeX + biber (never pdflatex, never bibtex)
**Style:** LSA Unified Style Sheet (`biblatex` with `style=unified`)
**Font:** TeX Gyre Termes via `fontspec`

### Linguistic Examples (`expex`)

| Command | Use | Example |
|---------|-----|---------|
| `\ex` ... `\xe` | Simple example | Single sentence with judgment |
| `\pex` ... `\xe` | Multi-part example | (a), (b), (c) sub-examples |
| `\begingl` ... `\endgl` | Interlinear gloss | Foreign language data |
| `\ljudge{*}` | Judgment marker | Ungrammaticality |
| `\ljudge{?}` | Judgment marker | Marginal acceptability |

**Anti-patterns:** Never renumber examples without asking. Never switch between `expex` and `gb4e`/`linguex` syntax. Never omit judgment markers on examples that have them.

### Syntactic Trees (`forest`)

Use `forest` with `linguistics` library. Trees should use:
- Triangles for elided structure (`triangle`)
- Movement arrows via `\draw` with appropriate edge styles
- Consistent node labels (TP, vP, CP, etc.)

### Notation Conventions

| Notation | Meaning | Convention |
|----------|---------|------------|
| `*` | Ungrammatical | Before example sentence |
| `?` / `??` | Marginal / degraded | Before example sentence |
| `%` | Speaker variation | Before example sentence |
| `_i` / `_j` | Coindexation | Subscript indices |
| `t_i` | Trace | Movement landing site |
| `<...>` | Copy (if using copy theory) | Struck-through or angle brackets |

---

## R Conventions

**Primary methods:**
- Ordinal regression (CLMMs) via `ordinal` package -- acceptability judgments
- Linear mixed-effects models via `lme4::lmer` -- reading times (maze task)

**Experiment platform:** PCIbex

**Typical data structure:** participant, item, condition, list, response (1-7 scale or RT in ms)

---

## Current Project State

| Paper | Directory | Status | Key Topic |
|-------|-----------|--------|-----------|
| Anti-c-command | `Papers/anti-c-command/` | Active | Anti-c-command and parasitic gaps |
| Symbiotic gaps | `Papers/symbiotic-gaps/` | Active | Symbiotic gap constructions |
| Control & scope reconstruction | `Papers/control-scope-reconstruction/` | Active | Control and scope reconstruction |
| Dissertation prospectus | `Papers/dissertation-prospectus/` | Reference | Prospectus (2024) |
