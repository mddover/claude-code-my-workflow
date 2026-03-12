---
paths:
  - "Papers/**/*.tex"
  - "R/**/*.R"
---

# Research Knowledge Base: Syntax & Psycholinguistics

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Ungrammatical | `*` before sentence | `*Who did you wonder whether left?` | Omitting judgment |
| Marginal | `?` or `??` before sentence | `?Who did you wonder left?` | Using `#` without definition |
| Speaker variation | `%` before sentence | `%Who did you want to leave?` | Mixing `%` and `?` |
| Coindexation | Subscript indices `_i`, `_j` | `Who_i did you see t_i?` | Inconsistent index letters |
| Traces | `t_i` at extraction site | `Who_i t_i left?` | Switching between traces and copies mid-paper |

## Symbol Reference

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| | | |

## Paper Progression

| Paper | Core Question | Key Constructions | Key Method |
|-------|--------------|-------------------|------------|
| Anti-c-command | Locality without c-command | | Acceptability judgments (CLMM) |
| Symbiotic gaps | Symbiotic gap licensing | | Acceptability judgments (CLMM) |
| PG prediction processing | Processing predictions for PGs | Parasitic gaps | Reading times (maze, lmer) |

## LaTeX Conventions

| Package | Convention | Anti-Pattern |
|---------|-----------|-------------|
| `expex` | All examples via `\ex`/`\pex` | Never use `gb4e` or `linguex` |
| `forest` | Trees with `[linguistics]` library | Never use `tikz-qtree` |
| `biblatex` | `style=unified`, `backend=biber` | Never use `bibtex` or `natbib` alone |
| `fontspec` | TeX Gyre Termes | Never use `times` or `mathptmx` |

## R Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| `ordinal::clmm` silent convergence failure | Wrong estimates | Always check `model$convergence` |
| Default treatment coding in `lmer` | Misleading contrasts | Set `contr.sum` or custom contrasts explicitly |
| PCIbex timestamps as strings | Broken RT calculation | `as.numeric()` on import |
| Forgetting to exclude practice items | Inflated N | Filter by `item_type != "practice"` |

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| Renumber examples without asking | Breaks all cross-references | Always ask before renumbering |
| Switch trace/copy notation mid-paper | Reader confusion | Pick one convention, stick with it |
| Use `\cite` instead of `\textcite`/`\parencite` | Inconsistent with Unified Style | Use `biblatex` citation commands |
