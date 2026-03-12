# =============================================================================
# Title:   Symbiotic Gaps Experiment 1 -- Acceptability Judgment Analysis
# Author:  Michael Dover
# Purpose: Fit CLMMs to 2x2 acceptability judgment data (Subject Gap x
#          Adjunct Gap) and generate publication-ready figures.
# Input:   Data/symbiotic-gaps/experiment-1/results.csv (PCIbex output)
# Output:  Figures/symbiotic-gaps/experiment-1/*.pdf
#          R/symbiotic-gaps/experiment-1/output/*.rds, *.csv
# =============================================================================

# 0. Setup ====================================================================

set.seed(20260312)

library(tidyverse)
library(ordinal)
library(emmeans)
library(broom)

# Northwestern visual identity
primary_purple <- "#4E2A84"
primary_black  <- "#000000"
accent_gray    <- "#525252"

theme_ling <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
}

# 1. Data Import & Cleaning ===================================================

# PCIbex results have variable column counts per row type, so standard
# read.csv(comment.char = "#") cannot parse them cleanly. We read raw lines
# and filter to experimental items (MD4- prefix), which removes practice
# and filler trials.
raw_lines <- read_lines("Data/symbiotic-gaps/experiment-1/results.csv")
md4_lines <- raw_lines[str_detect(raw_lines, "MD4-")]

# Pad short rows to 11 fields so read_csv parses all columns
md4_lines <- sapply(md4_lines, function(x) {
  n_commas <- str_count(x, ",")
  if (n_commas < 10) paste0(x, paste(rep(",", 10 - n_commas), collapse = ""))
  else x
}, USE.NAMES = FALSE)

d <- read_csv(I(md4_lines),
              col_names = paste0("V", 1:11),
              col_types = cols(.default = "c"))

# Extract sentence rows (8 fields, V9 is NA)
sentences <- d %>%
  filter(is.na(V9)) %>%
  select(ip_hash = V2, order = V4, label = V6, latin_group = V7, sentence = V8)

# Extract response rows (11 fields)
responses <- d %>%
  filter(!is.na(V9)) %>%
  select(ip_hash = V2, order = V4, label = V6, latin_group = V7,
         rating = V9, rt = V11) %>%
  mutate(rating = as.numeric(rating),
         rt = as.numeric(rt))

# Join into a single trial-level dataframe
trials_raw <- responses %>%
  left_join(sentences, by = c("ip_hash", "order", "label", "latin_group")) %>%
  mutate(condition = str_remove(label, "MD4-"),
         participant = as.factor(ip_hash),
         item = as.factor(latin_group))

# No attention/comprehension check items were included in this experiment;
# data quality is assessed via RT and invariance filters below.

# --- Data Cleaning ---

n_trials_before <- nrow(trials_raw)
n_participants_before <- n_distinct(trials_raw$participant)

# 1. Exclude trials with RT < 1500ms (too fast to have read the sentence)
trials_clean <- trials_raw %>%
  filter(rt >= 1500)

n_trials_rt_excluded <- n_trials_before - nrow(trials_clean)

# 2. Exclude participants who lost >50% of trials to RT filter
trial_loss <- trials_raw %>%
  group_by(participant) %>%
  summarise(
    n_total = n(),
    n_kept = sum(rt >= 1500),
    pct_lost = 1 - n_kept / n_total,
    .groups = "drop"
  )

excluded_participants_rt <- trial_loss %>%
  filter(pct_lost > 0.5) %>%
  pull(participant)

trials_clean <- trials_clean %>%
  filter(!participant %in% excluded_participants_rt)

# 3. Exclude invariant responders (same rating on >90% of trials)
invariance <- trials_clean %>%
  group_by(participant) %>%
  summarise(
    max_pct_same = max(table(rating)) / n(),
    .groups = "drop"
  )

excluded_participants_invariant <- invariance %>%
  filter(max_pct_same > 0.9) %>%
  pull(participant)

trials_clean <- trials_clean %>%
  filter(!participant %in% excluded_participants_invariant)

# Report data loss
all_excluded_participants <- union(as.character(excluded_participants_rt),
                                   as.character(excluded_participants_invariant))
n_participants_after <- n_distinct(trials_clean$participant)
n_trials_after <- nrow(trials_clean)

cat("\n--- Data Cleaning Report ---\n")
cat(sprintf("Trials before cleaning: %d\n", n_trials_before))
cat(sprintf("Trials excluded (RT < 1500ms): %d (%.1f%%)\n",
            n_trials_rt_excluded, 100 * n_trials_rt_excluded / n_trials_before))
cat(sprintf("Participants before cleaning: %d\n", n_participants_before))
cat(sprintf("Participants excluded (>50%% trial loss): %d %s\n",
            length(excluded_participants_rt),
            if (length(excluded_participants_rt) > 0)
              paste0("[", paste(excluded_participants_rt, collapse = ", "), "]") else ""))
cat(sprintf("Participants excluded (invariant responding): %d %s\n",
            length(excluded_participants_invariant),
            if (length(excluded_participants_invariant) > 0)
              paste0("[", paste(excluded_participants_invariant, collapse = ", "), "]") else ""))
cat(sprintf("Participants after cleaning: %d\n", n_participants_after))
cat(sprintf("Trials after cleaning: %d (%.1f%% of original)\n",
            n_trials_after, 100 * n_trials_after / n_trials_before))
cat("---\n\n")

trials <- trials_clean %>%
  droplevels()

# Create 2x2 factor coding
# subject_gap: SymGap (yes/yes), SubjIsl (yes/no), AdjIsl (no/yes), NoGap (no/no)
# adjunct_gap: SymGap (yes/yes), AdjIsl (no/yes), SubjIsl (yes/no), NoGap (no/no)
trials <- trials %>%
  mutate(
    # Sum-coded contrasts (+/- 0.5) for model
    subject_gap = if_else(condition %in% c("SymGap", "SubjIsl"), 0.5, -0.5),
    adjunct_gap = if_else(condition %in% c("SymGap", "AdjIsl"), 0.5, -0.5),
    # Labelled factors for summaries and plots
    subject_gap_label = if_else(subject_gap == 0.5, "yes", "no"),
    adjunct_gap_label = if_else(adjunct_gap == 0.5, "yes", "no"),
    rating_ord = factor(rating, levels = 1:7, ordered = TRUE)
  )

# Summary stats by condition
condition_means <- trials %>%
  group_by(condition) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    sd_rating = sd(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    sd_rt = sd(rt, na.rm = TRUE),
    n = n()
  )

# Summary stats by 2x2 factors
factorial_means <- trials %>%
  group_by(subject_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    sd_rating = sd(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    sd_rt = sd(rt, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# By-participant means (for by-subjects analysis)
by_subj <- trials %>%
  group_by(participant, condition, subject_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    .groups = "drop"
  )

# By-item means (for by-items analysis)
by_item <- trials %>%
  group_by(item, condition, subject_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    .groups = "drop"
  )

# 2. Model Fitting =============================================================

# Helper: check clmm convergence (code may be NA or missing)
converged <- function(m) {
  !is.null(m) &&
    !is.null(m$convergence) &&
    isTRUE(m$convergence$code == 0)
}

# Maximal model: random slopes for both factors by participant and item
m_maximal <- tryCatch(
  clmm(rating_ord ~ subject_gap * adjunct_gap +
         (1 + subject_gap * adjunct_gap | participant) +
         (1 + subject_gap * adjunct_gap | item),
       data = trials),
  warning = function(w) NULL,
  error = function(e) NULL
)

if (converged(m_maximal)) {
  cat("Maximal model converged.\n")
  m_full <- m_maximal
} else {
  # Maximal model failed; try random slopes without interaction
  m_slopes <- tryCatch(
    clmm(rating_ord ~ subject_gap * adjunct_gap +
           (1 + subject_gap + adjunct_gap | participant) +
           (1 + subject_gap + adjunct_gap | item),
         data = trials),
    warning = function(w) NULL,
    error = function(e) NULL
  )

  if (converged(m_slopes)) {
    cat("Random-slopes model (no interaction slope) converged.\n")
    m_full <- m_slopes
  } else {
    # Fall back to random intercepts only
    cat("Random-slopes models failed to converge; using random intercepts only.\n")
    m_full <- clmm(rating_ord ~ subject_gap * adjunct_gap +
                      (1 | participant) + (1 | item),
                    data = trials)
    if (!converged(m_full)) {
      warning("Random-intercepts model did not achieve clean convergence. ",
              "Interpret results with caution.")
    }
  }
}

summary(m_full)
m_full_coefs <- as.data.frame(summary(m_full)$coefficients)

# Model without interaction (for comparison)
m_no_interaction <- clmm(rating_ord ~ subject_gap + adjunct_gap +
                           (1 | participant) + (1 | item),
                         data = trials)

# Likelihood ratio test for interaction
anova(m_no_interaction, m_full)

# 3. Post-hoc Tests ============================================================
m_condition <- clmm(rating_ord ~ condition + (1 | participant) + (1 | item),
                    data = trials)
pairwise <- emmeans(m_condition, pairwise ~ condition, adjust = "bonferroni")
pairwise_results <- as.data.frame(pairwise$contrasts)
print(pairwise)

fig_dir <- "Figures/symbiotic-gaps/experiment-1"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# 4. Figures ===================================================================

# Condition labels for display
condition_labels <- c(
  "NoGap" = "No Gap",
  "AdjIsl" = "Adjunct Island",
  "SubjIsl" = "Subject Island",
  "SymGap" = "Symbiotic Gap"
)

# 1. Mean rating by condition
p_condition <- trials %>%
  mutate(condition = factor(condition,
                            levels = c("NoGap", "AdjIsl", "SubjIsl", "SymGap"),
                            labels = condition_labels)) %>%
  group_by(condition) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    se = sd(rating, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = condition, y = mean_rating)) +
  geom_col(width = 0.6, fill = primary_purple, color = "black") +
  geom_errorbar(aes(ymin = mean_rating - se, ymax = mean_rating + se),
                width = 0.2, linewidth = 0.5) +
  scale_y_continuous(limits = c(0, 7), breaks = 1:7) +
  labs(x = "Condition", y = "Mean Acceptability Rating (1\u20137)") +
  theme_ling(base_size = 12) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

print(p_condition)
ggsave(file.path(fig_dir, "mean_acceptability_by_condition.pdf"),
       p_condition, width = 7, height = 5, dpi = 300)

# 2. Interaction plot (2x2)
p_interaction <- trials %>%
  mutate(
    subject_gap_label = factor(subject_gap_label,
                               levels = c("no", "yes"),
                               labels = c("Absent", "Present")),
    adjunct_gap_label = factor(adjunct_gap_label,
                               levels = c("no", "yes"),
                               labels = c("Absent", "Present"))
  ) %>%
  group_by(subject_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    se = sd(rating, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = subject_gap_label, y = mean_rating,
             shape = adjunct_gap_label, linetype = adjunct_gap_label,
             group = adjunct_gap_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3, fill = "white") +
  geom_errorbar(aes(ymin = mean_rating - se, ymax = mean_rating + se),
                width = 0.12, linewidth = 0.5) +
  scale_shape_manual(values = c("Absent" = 16, "Present" = 1)) +
  scale_linetype_manual(values = c("Absent" = "solid", "Present" = "dashed")) +
  scale_y_continuous(limits = c(1, 5), breaks = 1:5) +
  labs(x = "Subject Gap", y = "Mean Acceptability Rating (1\u20137)",
       shape = "Adjunct Gap", linetype = "Adjunct Gap") +
  theme_ling(base_size = 12) +
  theme(legend.position = c(0.8, 0.9),
        legend.background = element_rect(color = "black", linewidth = 0.3))

print(p_interaction)
ggsave(file.path(fig_dir, "interaction_plot.pdf"),
       p_interaction, width = 7, height = 5, dpi = 300)

# 3. Distribution of ratings by condition
p_dist <- trials %>%
  mutate(condition = factor(condition,
                            levels = c("NoGap", "AdjIsl", "SubjIsl", "SymGap"),
                            labels = condition_labels)) %>%
  ggplot(aes(x = rating_ord)) +
  geom_bar(fill = accent_gray, color = "black", width = 0.7) +
  facet_wrap(~ condition) +
  labs(x = "Acceptability Rating (1\u20137)", y = "Number of Responses") +
  theme_ling(base_size = 12) +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold", size = 11))

print(p_dist)
ggsave(file.path(fig_dir, "rating_distributions_by_condition.pdf"),
       p_dist, width = 7, height = 5, dpi = 300)

# 5. Export ===================================================================

out_dir <- "R/symbiotic-gaps/experiment-1/output"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

saveRDS(m_full, file.path(out_dir, "clmm_factorial.rds"))
saveRDS(m_no_interaction, file.path(out_dir, "clmm_no_interaction.rds"))
saveRDS(m_condition, file.path(out_dir, "clmm_condition.rds"))

write.csv(tidy(m_full), file.path(out_dir, "clmm_factorial_summary.csv"),
          row.names = FALSE)
write.csv(pairwise_results, file.path(out_dir, "pairwise_comparisons.csv"),
          row.names = FALSE)

# --- Results Summary ---
#
# --- Participants and data cleaning ---
#
# 46 participants rated 24 items in a 2x2 Latin Square design crossing
# Subject Gap (yes/no) and Adjunct Gap (yes/no), yielding 1,104
# experimental trials across four conditions. Three exclusion criteria
# were applied:
#   (1) Individual trials with RT < 1500ms were excluded, as these response
#       times are too fast to reflect genuine reading of the stimuli. This
#       removed 94 trials (8.5% of the data).
#   (2) Participants who lost >50% of their trials to the RT filter were
#       excluded entirely. This removed 2 participants.
#   (3) Participants who gave the same rating on >90% of their remaining
#       trials were excluded as invariant responders. This removed 1
#       additional participant.
# After cleaning: 43 participants, 24 items, 983 trials (89.0% of original
# data retained).
#
# --- Model results ---
#
# A cumulative link mixed model (CLMM) was fit to ordinal acceptability
# ratings (1-7) with Subject Gap, Adjunct Gap, and their interaction as
# fixed effects (sum-coded, +/-0.5), and random intercepts for
# participants (N = 43) and items (N = 24).
#
# Random effects: participant variance = 1.99 (SD = 1.41); item
# variance = 0.35 (SD = 0.59).
#
# Mean ratings by condition (1-7 scale):
#   No Gap: 3.17, Adjunct Island: 3.32, Subject Island: 2.22,
#   Symbiotic Gap: 2.47
#
# Main effect of Subject Gap: b = -1.38, z = -10.54, p < .001. The
# presence of a subject gap substantially lowers acceptability.
#
# Main effect of Adjunct Gap: b = 0.33, z = 2.63, p = .008. The
# presence of an adjunct gap significantly increases acceptability.
#
# Subject Gap x Adjunct Gap interaction: b = 0.04, z = 0.15, p = .882.
# The interaction was negligible and not significant, indicating that
# the effect of each gap type on acceptability is additive rather than
# interactive. The near-parallel lines in the interaction plot confirm
# this.
#
# --- Pairwise comparisons (Tukey-adjusted) ---
#
# Pairwise comparisons between the four conditions were conducted using
# emmeans with Tukey correction for multiple comparisons.
#
# Two groups of conditions emerged:
#   Higher acceptability: No Gap (3.17) and Adjunct Island (3.32)
#     - No Gap vs. Adjunct Island: z = 1.83, p = .261 (n.s.)
#   Lower acceptability: Subject Island (2.22) and Symbiotic Gap (2.47)
#     - Subject Island vs. Symbiotic Gap: z = -1.89, p = .234 (n.s.)
#
# All across-group comparisons were highly significant (all p < .001):
#     - Adjunct Island vs. Subject Island: z = 9.32, p < .001
#     - Adjunct Island vs. Symbiotic Gap: z = 7.62, p < .001
#     - No Gap vs. Subject Island: z = 7.64, p < .001
#     - No Gap vs. Symbiotic Gap: z = 5.95, p < .001
#
# Critically, the Symbiotic Gap condition did not differ from the Subject
# Island condition, and the Adjunct Island condition did not differ from
# the No Gap condition.
#
# --- Implications for symbiotic gaps ---
#
# The symbiotic gap hypothesis predicts a superadditive interaction:
# combining a subject gap and an adjunct gap (the Symbiotic Gap condition)
# should yield higher acceptability than predicted by the independent
# penalties of each gap alone.
#
# The present data do not support this claim. The interaction was near zero
# and far from significant (b = 0.04, p = .882). The mean ratings show
# that Symbiotic Gap (2.47) is rated only marginally better than Subject
# Island (2.22), and this difference is fully accounted for by the additive
# contribution of the adjunct gap. There is no evidence that combining both
# gaps produces any amelioration beyond what the independent effects predict.
#
# The pattern is consistent with simple additivity: subject gaps impose a
# significant penalty (p < .001), adjunct gaps provide a small but
# significant boost (p = .008), and their combination in symbiotic gap
# sentences shows no special improvement on island violations.
#
# --- Full statistical results for tables ---
#
# CLMM fixed effects (sum-coded +/-0.5):
#
#   Effect                          b       SE      z        p
#   Subject Gap                  -1.379   0.131  -10.541   <.001
#   Adjunct Gap                   0.326   0.124    2.635    .008
#   Subject Gap x Adjunct Gap     0.037   0.249    0.149    .882
#
# CLMM threshold coefficients:
#
#   Threshold    Estimate    SE
#   1|2          -1.083     0.261
#   2|3           0.285     0.259
#   3|4           1.158     0.262
#   4|5           1.832     0.266
#   5|6           2.975     0.278
#   6|7           4.101     0.307
#
# CLMM random effects:
#
#   Group          Variance    SD
#   Participant    1.985       1.409
#   Item           0.352       0.594
#
# Condition means (1-7 scale):
#
#   Condition          Subj  Adj    Mean    SD      n
#   No Gap              no    no    3.17   1.89    247
#   Adjunct Island      no   yes    3.32   1.84    247
#   Subject Island     yes    no    2.22   1.56    242
#   Symbiotic Gap      yes   yes    2.47   1.74    247
#
# Pairwise comparisons (Tukey-adjusted, from condition-level CLMM):
#
#   Contrast                          Estimate    SE      z        p
#   AdjIsl - NoGap                      0.307   0.168    1.827    .261
#   AdjIsl - SubjIsl                    1.705   0.183    9.318   <.001
#   AdjIsl - SymGap                     1.361   0.178    7.624   <.001
#   NoGap - SubjIsl                     1.398   0.183    7.643   <.001
#   NoGap - SymGap                      1.053   0.177    5.950   <.001
#   SubjIsl - SymGap                   -0.344   0.183   -1.886    .234
