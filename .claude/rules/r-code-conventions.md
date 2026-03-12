---
paths:
  - "**/*.R"
  - "R/**/*.R"
---

# R Code Standards

**Standard:** Reproducible experimental linguistics analysis

---

## 1. Reproducibility

- `set.seed()` called ONCE at top (YYYYMMDD format)
- All packages loaded at top via `library()` (not `require()`)
- All paths relative to repository root
- `dir.create(..., recursive = TRUE)` for output directories

## 2. Function Design

- `snake_case` naming, verb-noun pattern
- Roxygen-style documentation
- Default parameters, no magic numbers
- Named return values (lists or tibbles)

## 3. Data Pipeline (PCIbex)

### Import
```r
# Standard PCIbex import pattern
raw <- read.csv("Data/project-name/results.csv",
                comment.char = "#",
                stringsAsFactors = FALSE)
```

### Cleaning Checklist
- [ ] Remove practice/filler items (or analyze separately)
- [ ] Apply participant exclusion criteria (document in comments)
- [ ] Check attention/comprehension question accuracy (threshold: e.g., >80%)
- [ ] Convert response columns to correct types
- [ ] Set factor levels explicitly: `factor(condition, levels = c("a", "b", "c"))`
- [ ] Set contrast coding explicitly: `contrasts(df$condition) <- contr.sum(n)`

### RT Data (Maze Task)
- [ ] Exclude RTs < 100ms and > 5000ms (or document your cutoffs)
- [ ] Log-transform or inverse-transform if needed
- [ ] Z-score by participant if comparing across experiments
- [ ] Analyze critical region AND spillover region(s)

## 4. Model Specification

### Acceptability Judgments (CLMM)
```r
library(ordinal)
df$response <- factor(df$response, ordered = TRUE)

# Maximal model first
m_full <- clmm(response ~ condition + (1 + condition | participant) + (1 + condition | item),
               data = df)

# If convergence fails, document and simplify
m_reduced <- clmm(response ~ condition + (1 | participant) + (1 | item),
                  data = df)
# ALWAYS check: m_reduced$convergence
```

### Reading Times (lmer)
```r
library(lme4)

# Maximal model first (Barr et al. 2013)
m_full <- lmer(log_rt ~ condition * region + (1 + condition | participant) + (1 + condition | item),
               data = df)

# If singular fit, simplify random effects (document each step)
```

### Post-hoc Tests
```r
library(emmeans)
emm <- emmeans(model, pairwise ~ condition)
summary(emm$contrasts, adjust = "bonferroni")
```

## 5. Visual Identity

```r
# --- Project palette ---
primary_purple <- "#4E2A84"   # Northwestern purple
primary_black  <- "#000000"
accent_gray    <- "#525252"
positive_green <- "#15803d"
negative_red   <- "#b91c1c"
```

### Custom Theme
```r
theme_ling <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
}
```

### Figure Dimensions
```r
ggsave(filepath, width = 7, height = 5, dpi = 300)
```

## 6. Results Export

```r
# Save fitted model
saveRDS(model, file.path(out_dir, "clmm_condition.rds"))

# Save tidy summary for paper
library(broom)
write.csv(tidy(model, conf.int = TRUE),
          file.path(out_dir, "clmm_condition_summary.csv"),
          row.names = FALSE)
```

## 7. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| `ordinal::clmm` convergence warning ignored | Invalid estimates | Check `model$convergence$code == 0` |
| Default treatment coding | Misleading main effects | Set `contr.sum` or custom contrasts |
| PCIbex column order changes between experiments | Wrong data | Read with explicit column names |
| Maze task: analyzing only critical region | Missing spillover effects | Always check region + 1 and + 2 |
| Not saving model objects | Can't reproduce tables | `saveRDS()` every model |

## 8. Code Quality Checklist

```
[ ] Packages at top via library()
[ ] set.seed() once at top
[ ] All paths relative
[ ] Factor levels set explicitly
[ ] Contrast coding set explicitly
[ ] Maximal model attempted first
[ ] Convergence checked
[ ] Figures: explicit dimensions, labeled axes
[ ] Models saved via saveRDS()
[ ] Comments explain WHY not WHAT
```
