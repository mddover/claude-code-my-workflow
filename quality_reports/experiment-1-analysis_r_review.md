# R Code Review: `R/symbiotic-gaps/experiment-1/analysis.R`

**Date:** 2026-03-12
**Reviewer:** r-reviewer agent

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 4 |
| High | 6 |
| Medium | 5 |
| Low | 3 |
| **Total** | **18** |

---

## Critical Issues

### 1. Response variable is not an ordered factor (line 121)
`as.factor(rating)` creates an unordered factor. `clmm()` requires an ordered factor for the ordinal link function to be meaningful.
```r
# Current
rating_ord = as.factor(rating)
# Fix
rating_ord = factor(rating, levels = 1:7, ordered = TRUE)
```

### 2. Maximal random effects structure not attempted (lines 168-170)
Script jumps directly to random-intercepts-only without attempting or documenting failure of random slopes (Barr et al. 2013).

### 3. Convergence not checked (lines 168-171)
No `m_full$convergence$code` check after fitting. Interpreting a non-converged CLMM produces invalid estimates.

### 4. Data import path not relative to repository root (line 6)
Path `"data/results.csv"` is relative to script location, not repo root. Also has case mismatch (`data/` vs `Data/`). Should be `"Data/symbiotic-gaps/experiment-1/results.csv"`.

---

## High Issues

### 5. No `set.seed()` call (line 1)
Conventions require `set.seed(YYYYMMDD)` at top for reproducibility.

### 6. No header block
Script begins directly with `library()`. Missing title, author, purpose, inputs, outputs.

### 7. No numbered section structure
Uses ad-hoc `# ---` comment markers instead of numbered sections (0-5).

### 8. Post-hoc comparisons use Tukey instead of Bonferroni (line 185)
Conventions specify Bonferroni unless Tukey is justified. No justification provided.

### 9. No models or summaries saved to disk
No `saveRDS()` or `write.csv()` calls. All results exist only in console output.

### 10. No `dir.create()` for output directories
Script will fail on fresh clone if output directories don't exist.

---

## Medium Issues

### 11. Figure save paths in wrong directory (lines 220-221, 256-257, 273-274)
Figures save to working directory instead of `Figures/symbiotic-gaps/experiment-1/`. Filenames contain spaces. Missing `dpi=300`. Dimensions don't match conventions (should be width=7, height=5).

### 12. No `theme_ling()` or Northwestern palette (lines 216, 251, 268)
Uses `theme_classic()` and `grey60` instead of project visual identity.

### 13. No attention/comprehension check filtering (lines 40-108)
Data cleaning applies RT and invariance filters but doesn't check filler accuracy. If no attention checks exist, this should be documented.

### 14. Non-standard PCIbex import pattern (lines 5-18)
Manual line parsing with column padding instead of standard `read.csv(..., comment.char = "#")`. If necessary, add a comment explaining why.

### 15. Practice/filler removal not documented (lines 7-8)
The `MD4-` filter implicitly removes non-experimental items but doesn't document what is excluded.

---

## Low Issues

### 16. Interaction plot uses line graph for ordinal data (lines 224-257)
Acceptable for showing interaction patterns but could use a justifying comment.

### 17. `broom` package not loaded (lines 1-3)
Needed for `tidy()` export per conventions. Becomes relevant once Issue 9 is fixed.

### 18. Results summary is a 130-line comment block (lines 276-403)
Hardcoded numbers will become stale. Export tables programmatically and move narrative to a separate file.

---

## Checklist

| Category | Status |
|----------|--------|
| Structure & Header | Fail (2 issues) |
| Data Pipeline | Fail (3 issues) |
| Reproducibility | Fail (4 issues) |
| Model Specification | Fail (4 issues) |
| Figures | Fail (3 issues) |
| Results Export | Fail (1 issue) |
| Code Quality | Fail (1 issue) |
