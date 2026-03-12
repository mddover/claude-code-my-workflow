library(tidyverse)
library(ordinal)
library(emmeans)

# Read PCIbex results, skipping comment lines
d <- read_csv("Data/symbiotic-gaps/experiment-2/results.csv", comment = "#",
              col_names = FALSE,
              col_types = cols(.default = "c"))

# Filter for experimental items (MD_ labels)
d_md <- d %>%
  filter(str_detect(X6, "^MD_"))

# Extract ratings from Scale/score/Choice rows
responses <- d_md %>%
  filter(X8 == "Scale", X9 == "score", X10 == "Choice") %>%
  select(ip_hash = X2, order = X4, label = X6,
         rating = X11, event_time = X12, item_num = X14)

# Extract trial start times to compute RT
trial_starts <- d_md %>%
  filter(X10 == "_Trial_", X11 == "Start") %>%
  select(ip_hash = X2, order = X4, label = X6,
         start_time = X12)

# Join and compute RT (ms from trial start to rating selection)
# Map condition codes to descriptive labels
condition_map <- c(
  "A" = "NoGap",    "B" = "AdjIsl",  "C" = "MatWh",    "D" = "AdjPG",
  "E" = "SubjIsl",  "F" = "SymGap",  "G" = "SubjPG",   "H" = "ThreeGap"
)

trials_raw <- responses %>%
  left_join(trial_starts, by = c("ip_hash", "order", "label")) %>%
  mutate(
    rating = as.numeric(rating),
    rt = as.numeric(event_time) - as.numeric(start_time),
    condition_code = str_remove(label, "MD_"),
    condition = condition_map[condition_code],
    participant = as.factor(ip_hash),
    item = as.factor(item_num)
  )

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

# Create 2x2x2 factor coding
# subject_gap: E,F,G,H = yes; A,B,C,D = no
# matrix_gap:  C,D,G,H = yes; A,B,E,F = no
# adjunct_gap: B,D,F,H = yes; A,C,E,G = no
trials <- trials %>%
  mutate(
    # Sum-coded contrasts (+/- 0.5) for model
    subject_gap = if_else(condition_code %in% c("E", "F", "G", "H"), 0.5, -0.5),
    matrix_gap  = if_else(condition_code %in% c("C", "D", "G", "H"), 0.5, -0.5),
    adjunct_gap = if_else(condition_code %in% c("B", "D", "F", "H"), 0.5, -0.5),
    # Labelled factors for summaries and plots
    subject_gap_label = if_else(subject_gap == 0.5, "yes", "no"),
    matrix_gap_label  = if_else(matrix_gap == 0.5, "yes", "no"),
    adjunct_gap_label = if_else(adjunct_gap == 0.5, "yes", "no"),
    rating_ord = as.factor(rating)
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

# Summary stats by 2x2x2 factors
factorial_means <- trials %>%
  group_by(subject_gap_label, matrix_gap_label, adjunct_gap_label) %>%
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
  group_by(participant, condition,
           subject_gap_label, matrix_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    .groups = "drop"
  )

# By-item means (for by-items analysis)
by_item <- trials %>%
  group_by(item, condition,
           subject_gap_label, matrix_gap_label, adjunct_gap_label) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    mean_rt = mean(rt, na.rm = TRUE),
    .groups = "drop"
  )

# --- Ordinal Regression (Cumulative Link Mixed Model) ---

# Full model: three-way interaction, random intercepts for participant and item
m_full <- clmm(rating_ord ~ subject_gap * matrix_gap * adjunct_gap +
                  (1 | participant) + (1 | item),
                data = trials)
summary(m_full)
m_full_coefs <- as.data.frame(summary(m_full)$coefficients)

# Model without three-way interaction (for comparison)
m_no_3way <- clmm(rating_ord ~ (subject_gap + matrix_gap + adjunct_gap)^2 +
                     (1 | participant) + (1 | item),
                   data = trials)

# Likelihood ratio test for three-way interaction
anova(m_no_3way, m_full)

# Pairwise comparisons between conditions
m_condition <- clmm(rating_ord ~ condition + (1 | participant) + (1 | item),
                    data = trials)
pairwise <- emmeans(m_condition, pairwise ~ condition, adjust = "tukey")
pairwise_results <- as.data.frame(pairwise$contrasts)
print(pairwise)

# --- Visualizations (black-and-white, publication-ready) ---

# Condition labels for display
condition_labels <- c(
  "NoGap"    = "No Gap",
  "AdjIsl"   = "Adjunct Island",
  "MatWh"    = "Matrix Wh",
  "AdjPG"    = "Adjunct PG",
  "SubjIsl"  = "Subject Island",
  "SymGap"   = "Symbiotic Gap",
  "SubjPG"   = "Subject PG",
  "ThreeGap" = "Three Gaps"
)

condition_order <- c("NoGap", "MatWh", "AdjIsl", "AdjPG",
                     "SubjIsl", "SubjPG", "SymGap", "ThreeGap")

# 1. Mean rating by condition
p_condition <- trials %>%
  mutate(condition = factor(condition,
                            levels = condition_order,
                            labels = condition_labels[condition_order])) %>%
  group_by(condition) %>%
  summarise(
    mean_rating = mean(rating, na.rm = TRUE),
    se = sd(rating, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = condition, y = mean_rating)) +
  geom_col(width = 0.6, fill = "grey60", color = "black") +
  geom_errorbar(aes(ymin = mean_rating - se, ymax = mean_rating + se),
                width = 0.2, linewidth = 0.5) +
  scale_y_continuous(limits = c(0, 7), breaks = 1:7) +
  labs(x = "Condition", y = "Mean Acceptability Rating (1\u20137)") +
  theme_classic(base_size = 12) +
  theme(axis.text.x = element_text(angle = 35, hjust = 1))

print(p_condition)
fig_dir <- "Figures/symbiotic-gaps/experiment-2"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

ggsave(file.path(fig_dir, "mean_acceptability_by_condition.pdf"),
       p_condition, width = 7, height = 4.5)

# 2. Interaction plot: Subject Gap x Adjunct Gap, faceted by Matrix Gap
p_interaction <- trials %>%
  mutate(
    subject_gap_label = factor(subject_gap_label,
                               levels = c("no", "yes"),
                               labels = c("Absent", "Present")),
    adjunct_gap_label = factor(adjunct_gap_label,
                               levels = c("no", "yes"),
                               labels = c("Absent", "Present")),
    matrix_gap_label = factor(matrix_gap_label,
                              levels = c("no", "yes"),
                              labels = c("Matrix Gap Absent",
                                         "Matrix Gap Present"))
  ) %>%
  group_by(subject_gap_label, adjunct_gap_label, matrix_gap_label) %>%
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
  scale_y_continuous(breaks = 1:7) +
  facet_wrap(~ matrix_gap_label) +
  labs(x = "Subject Gap", y = "Mean Acceptability Rating (1\u20137)",
       shape = "Adjunct Gap", linetype = "Adjunct Gap") +
  theme_classic(base_size = 12) +
  theme(legend.position = "top",
        strip.background = element_blank(),
        strip.text = element_text(face = "bold", size = 11))

print(p_interaction)
ggsave(file.path(fig_dir, "interaction_plot.pdf"),
       p_interaction, width = 8, height = 4.5)

# 3. Distribution of ratings by condition
p_dist <- trials %>%
  mutate(condition = factor(condition,
                            levels = condition_order,
                            labels = condition_labels[condition_order])) %>%
  ggplot(aes(x = rating_ord)) +
  geom_bar(fill = "grey60", color = "black", width = 0.7) +
  facet_wrap(~ condition, ncol = 4) +
  labs(x = "Acceptability Rating (1\u20137)", y = "Number of Responses") +
  theme_classic(base_size = 12) +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold", size = 10))

print(p_dist)
ggsave(file.path(fig_dir, "rating_distributions_by_condition.pdf"),
       p_dist, width = 9, height = 5)

# --- Results Summary ---
#
# --- Participants and data cleaning ---
#
# 80 participants rated 24 items in a 2x2x2 Latin Square design crossing
# Subject Gap (yes/no), Matrix Gap (yes/no), and Adjunct Gap (yes/no),
# yielding 1,920 experimental trials across eight conditions. Three
# exclusion criteria were applied:
#   (1) Individual trials with RT < 1500ms were excluded, as these response
#       times are too fast to reflect genuine reading of the stimuli. This
#       removed 120 trials (6.3% of the data).
#   (2) Participants who lost >50% of their trials to the RT filter were
#       excluded entirely. This removed 0 participants.
#   (3) Participants who gave the same rating on >90% of their remaining
#       trials were excluded as invariant responders. This removed 0
#       participants.
# After cleaning: 80 participants, 24 items, 1,800 trials (93.8% of
# original data retained).
#
# --- Model results ---
#
# A cumulative link mixed model (CLMM) was fit to ordinal acceptability
# ratings (1-7) with Subject Gap, Matrix Gap, and Adjunct Gap as sum-coded
# fixed effects (+/-0.5) including all interactions, and random intercepts
# for participants (N = 80) and items (N = 24).
#
# Random effects: participant variance = 1.04 (SD = 1.02); item variance
# was negligible (< 0.001).
#
# Mean ratings by condition (1-7 scale):
#   No Gap: 2.68       Adjunct Island: 2.90
#   Matrix Wh: 4.91    Adjunct PG: 4.86
#   Subject Island: 2.01   Symbiotic Gap: 2.02
#   Subject PG: 2.43       Three Gaps: 2.48
#
# Main effect of Subject Gap: b = -1.90, z = -19.61, p < .001. The
# presence of a subject gap substantially lowers acceptability.
#
# Main effect of Matrix Gap: b = 1.31, z = 14.09, p < .001. The presence
# of a matrix wh-element significantly raises acceptability.
#
# Main effect of Adjunct Gap: b = 0.05, z = 0.53, p = .599. Not
# significant.
#
# Subject Gap x Matrix Gap interaction: b = -1.68, z = -9.24, p < .001.
# The acceptability boost from the matrix gap is substantially reduced in
# the presence of a subject gap.
#
# Subject Gap x Adjunct Gap interaction: b = -0.08, z = -0.46, p = .646.
# Not significant.
#
# Matrix Gap x Adjunct Gap interaction: b = -0.01, z = -0.04, p = .972.
# Not significant.
#
# Three-way interaction: b = 0.35, z = 1.00, p = .317. Not significant.
#
# --- Pairwise comparisons (Tukey-adjusted) ---
#
# Among conditions without a subject gap, two groups emerged:
#   Higher acceptability: Matrix Wh (4.91) and Adjunct PG (4.86)
#     - Matrix Wh vs. Adjunct PG: p = 1.000 (n.s.)
#   Lower acceptability: No Gap (2.68) and Adjunct Island (2.90)
#     - No Gap vs. Adjunct Island: p = .962 (n.s.)
#   All cross-group comparisons: p < .001.
#
# Among conditions with a subject gap, ratings were uniformly low:
#   Subject Island (2.01), Symbiotic Gap (2.02), Subject PG (2.43),
#   Three Gaps (2.48).
#     - Subject Island vs. Symbiotic Gap: p > .999 (n.s.)
#     - Subject PG vs. Three Gaps: p > .999 (n.s.)
#     - Subject Island vs. Subject PG: p = .427 (n.s.)
#     - Subject Island vs. Three Gaps: p = .158 (n.s.)
#     - Symbiotic Gap vs. Three Gaps: p = .049
#     - Subject PG vs. Symbiotic Gap: p = .185 (n.s.)
#
# --- Implications for symbiotic gaps ---
#
# The symbiotic gap hypothesis predicts that combining a subject gap with
# an adjunct gap should ameliorate the island violation, yielding higher
# acceptability than the subject island condition alone. The present data
# provide no support for this claim. The Symbiotic Gap condition (2.02)
# was rated virtually identically to the Subject Island condition (2.01),
# and the adjunct gap main effect was negligible and non-significant
# (b = 0.05, p = .599). Adding an adjunct gap to a subject island
# sentence produces no detectable improvement in acceptability.
#
# The significant Subject Gap x Matrix Gap interaction (b = -1.68,
# p < .001) demonstrates that the design was sensitive to genuine
# interactions between gap types: the matrix wh-element substantially
# boosted acceptability in non-island sentences (No Gap 2.68 vs. Matrix
# Wh 4.91) but provided a smaller boost in subject island sentences
# (Subject Island 2.01 vs. Subject PG 2.43). The failure of this
# numerically positive trend to reach significance (p = .427) may
# reflect the processing complexity of these multi-gap sentences, which
# could obscure what would otherwise be a detectable improvement. This
# contrasts with the adjunct gap result, where there is no numerical
# trend at all (Subject Island 2.01 vs. Symbiotic Gap 2.02), confirming
# that the null result for symbiotic gaps is not attributable to a lack
# of statistical power but rather reflects a genuine absence of
# amelioration.
#
# Notably, the Symbiotic Gap condition (2.02) was rated significantly
# lower than the Three Gaps condition (2.48; p = .049). The Three Gaps
# condition differs from Symbiotic Gap only in the addition of a matrix
# gap, suggesting that even in these complex multi-gap sentences, the
# presence of a matrix wh-element contributes to acceptability in a way
# that the adjunct gap alone cannot. This is consistent with the view
# that parasitic gaps are truly parasitic: their acceptability depends
# on the presence of a licensing matrix gap, and an adjunct gap without
# such licensing (as in the Symbiotic Gap condition) provides no benefit.
#
# --- Full statistical results for tables ---
#
# CLMM fixed effects (sum-coded +/-0.5):
#
#   Effect                                  b       SE      z        p
#   Subject Gap                          -1.899   0.097  -19.615   <.001
#   Matrix Gap                            1.305   0.093   14.085   <.001
#   Adjunct Gap                           0.046   0.088    0.526    .599
#   Subject Gap x Matrix Gap             -1.681   0.182   -9.241   <.001
#   Subject Gap x Adjunct Gap            -0.081   0.176   -0.459    .646
#   Matrix Gap x Adjunct Gap             -0.006   0.176   -0.036    .972
#   Subject Gap x Matrix Gap x Adj Gap    0.352   0.352    1.000    .317
#
# CLMM threshold coefficients:
#
#   Threshold    Estimate    SE
#   1|2          -1.150     0.130
#   2|3           0.176     0.128
#   3|4           0.845     0.130
#   4|5           1.388     0.132
#   5|6           2.185     0.139
#   6|7           3.192     0.153
#
# CLMM random effects:
#
#   Group          Variance    SD
#   Participant    1.043       1.021
#   Item           <0.001      <0.001
#
# Condition means (1-7 scale):
#
#   Condition          Subj  Mat  Adj    Mean    SD      n
#   No Gap              no    no   no    2.68   1.68    225
#   Adjunct Island      no    no  yes    2.90   1.74    226
#   Matrix Wh           no   yes   no    4.91   1.87    223
#   Adjunct PG          no   yes  yes    4.86   1.99    226
#   Subject Island     yes    no   no    2.01   1.39    220
#   Symbiotic Gap      yes    no  yes    2.02   1.46    225
#   Subject PG         yes   yes   no    2.43   1.88    226
#   Three Gaps         yes   yes  yes    2.48   1.87    229
#
# Pairwise comparisons (Tukey-adjusted, from condition-level CLMM):
#
#   Contrast                              Estimate    SE      z        p
#   AdjIsl - AdjPG                         -2.054   0.177  -11.616   <.001
#   AdjIsl - MatWh                         -2.059   0.176  -11.675   <.001
#   AdjIsl - NoGap                          0.178   0.165    1.076    .962
#   AdjIsl - SubjIsl                        1.108   0.175    6.316   <.001
#   AdjIsl - SubjPG                         0.728   0.173    4.215   <.001
#   AdjIsl - SymGap                         1.187   0.175    6.783   <.001
#   AdjIsl - ThreeGap                       0.637   0.171    3.721    .005
#   AdjPG - MatWh                          -0.004   0.175   -0.025   1.000
#   AdjPG - NoGap                           2.232   0.180   12.418   <.001
#   AdjPG - SubjIsl                         3.163   0.193   16.416   <.001
#   AdjPG - SubjPG                          2.783   0.189   14.731   <.001
#   AdjPG - SymGap                          3.242   0.193   16.822   <.001
#   AdjPG - ThreeGap                        2.692   0.187   14.407   <.001
#   MatWh - NoGap                           2.237   0.179   12.473   <.001
#   MatWh - SubjIsl                         3.167   0.192   16.471   <.001
#   MatWh - SubjPG                          2.787   0.189   14.776   <.001
#   MatWh - SymGap                          3.246   0.192   16.888   <.001
#   MatWh - ThreeGap                        2.696   0.187   14.448   <.001
#   NoGap - SubjIsl                         0.930   0.178    5.241   <.001
#   NoGap - SubjPG                          0.550   0.175    3.150    .035
#   NoGap - SymGap                          1.009   0.177    5.704   <.001
#   NoGap - ThreeGap                        0.459   0.173    2.655    .137
#   SubjIsl - SubjPG                       -0.380   0.183   -2.082    .427
#   SubjIsl - SymGap                        0.079   0.184    0.429   >.999
#   SubjIsl - ThreeGap                     -0.471   0.182   -2.593    .158
#   SubjPG - SymGap                         0.459   0.182    2.525    .185
#   SubjPG - ThreeGap                      -0.091   0.179   -0.508   >.999
#   SymGap - ThreeGap                      -0.550   0.181   -3.040    .049
