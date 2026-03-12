---
paths:
  - "Papers/**/*.tex"
  - "R/**/*.R"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for review
- **95/100 = Excellence** -- aspirational

## LaTeX Papers (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | XeLaTeX compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |
| Critical | Broken `expex` example numbering | -10 |
| Major | Inconsistent judgment markers | -5 |
| Major | Notation inconsistency | -3 |
| Major | Missing cross-reference | -3 |
| Minor | Overfull hbox < 10pt | -1 |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Wrong model specification (e.g., non-ordered factor in CLMM) | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing `set.seed()` | -10 |
| Major | Default treatment coding without justification | -10 |
| Major | Convergence warning ignored | -10 |
| Major | Missing figure generation | -5 |
| Minor | Style inconsistencies | -1 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.
