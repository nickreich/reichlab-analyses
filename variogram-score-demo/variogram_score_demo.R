# ==========================================================================
# Variogram Score Demo
#
# Demonstrates that the variogram score rewards correct relative structure
# (pairwise differences across locations) over absolute accuracy.
#
# A model with large absolute bias but correct pairwise differences can
# score better on the variogram score than a model that is much closer
# to the truth but has ranking inversions and distorted gaps.
#
# Usage (from repo root):
#   Rscript variogram-score-demo/variogram_score_demo.R
#
# Dependencies: ggplot2, patchwork
# ==========================================================================

library(ggplot2)
library(patchwork)

out_dir <- "variogram-score-demo/plots"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# -- Helpers ---------------------------------------------------------------

variogram_score <- function(forecast, observed, p = 0.5) {
  # VS_p(f, y) = sum_{i<j} (|f_i - f_j|^p - |y_i - y_j|^p)^2
  # Lower is better. Unit weights.
  n <- length(observed)
  score <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      f_diff <- abs(forecast[i] - forecast[j])^p
      y_diff <- abs(observed[i] - observed[j])^p
      score <- score + (f_diff - y_diff)^2
    }
  }
  score
}

mae <- function(forecast, observed) mean(abs(forecast - observed))

print_comparison <- function(true_vals, model_a, model_b, label_a, label_b) {
  cat(strrep("=", 70), "\n")
  cat("True values: ", true_vals, "\n")
  cat("True ranking:", rank(-true_vals), "\n\n")

  cat(label_a, ":", model_a, "\n")
  cat("  Ranking:  ", rank(-model_a), "\n")
  cat(sprintf("  MAE:       %.3f\n", mae(model_a, true_vals)))
  cat(sprintf("  Rank corr: %.3f\n", cor(model_a, true_vals, method = "spearman")))
  cat("\n")

  cat(label_b, ":", model_b, "\n")
  cat("  Ranking:  ", rank(-model_b), "\n")
  cat(sprintf("  MAE:       %.3f\n", mae(model_b, true_vals)))
  cat(sprintf("  Rank corr: %.3f\n", cor(model_b, true_vals, method = "spearman")))
  cat("\n")

  for (p in c(0.5, 1.0)) {
    vs_a <- variogram_score(model_a, true_vals, p = p)
    vs_b <- variogram_score(model_b, true_vals, p = p)
    winner <- if (vs_a < vs_b) label_a else label_b
    cat(sprintf("  Variogram Score (p=%.1f):\n", p))
    cat(sprintf("    %s: %.4f\n", label_a, vs_a))
    cat(sprintf("    %s: %.4f\n", label_b, vs_b))
    cat(sprintf("    Winner: %s\n\n", winner))
  }
}

pairwise_diff_matrix <- function(x) {
  n <- length(x)
  m <- matrix(NA, n, n)
  for (i in seq_len(n)) {
    for (j in seq_len(n)) {
      m[i, j] <- abs(x[i] - x[j])
    }
  }
  m
}

mat_to_df <- function(m, label) {
  n <- nrow(m)
  data.frame(
    row = rep(seq_len(n), each = n),
    col = rep(seq_len(n), times = n),
    value = as.vector(m),
    source = label
  )
}


# =====================================================================
# EXAMPLE 1: Constant bias vs ranking inversions
# =====================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXAMPLE 1: Constant bias vs close-but-misordered\n")
cat(strrep("=", 70), "\n\n")

true_values <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

# Model A: correct ranking and correct gaps, shifted up by 3.
# Every pairwise difference is perfectly preserved.
model_a <- true_values + 3  # [4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

# Model B: much closer to truth, but locations 4/5 and 8/9 are swapped,
# and some gaps are compressed.
model_b <- c(1.2, 2.3, 3.1, 4.8, 4.2, 5.8, 7.2, 8.5, 8.3, 9.7)

print_comparison(true_values, model_a, model_b,
                 "A (biased, correct ranking)",
                 "B (close, wrong ranking)")


# =====================================================================
# EXAMPLE 2: Misidentified hotspots
# =====================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXAMPLE 2: Correct spatial pattern vs misidentified hotspot\n")
cat(strrep("=", 70), "\n\n")

# 6 locations, one clear hotspot (loc 6) and one cold spot (loc 1)
true_values_2 <- c(1, 3, 5, 7, 4, 12)

# Model A: correct spatial pattern, proportionally scaled up by 1.5x
model_a2 <- true_values_2 * 1.5  # [1.5, 4.5, 7.5, 10.5, 6, 18]

# Model B: closer overall, but thinks loc 6 is only moderate
model_b2 <- c(3, 4, 5, 6, 4, 8)

print_comparison(true_values_2, model_a2, model_b2,
                 "A (scaled up, correct pattern)",
                 "B (closer, wrong hotspot)")


# =====================================================================
# EXAMPLE 3: Decomposing pairwise contributions
# =====================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXAMPLE 3: Decomposing pairwise contributions (p=1)\n")
cat(strrep("=", 70), "\n\n")

cat("Using Example 1 to show which location pairs drive the score:\n\n")

f_a <- true_values + 3
f_b <- c(1.2, 2.3, 3.1, 4.8, 4.2, 5.8, 7.2, 8.5, 8.3, 9.7)

# Show interesting pairs -- around the two rank swaps and some long-range
pairs <- list(c(4, 5), c(3, 5), c(4, 6),    # around swap at locs 4/5
              c(8, 9), c(7, 9), c(8, 10),    # around swap at locs 8/9
              c(1, 10), c(1, 6), c(4, 10))   # long-range

cat(sprintf("%10s  %10s  %10s  %10s  %10s  %10s\n",
            "Pair", "True diff", "A diff", "A penalty", "B diff", "B penalty"))
cat(strrep("-", 75), "\n")

for (pr in pairs) {
  i <- pr[1]; j <- pr[2]
  td <- abs(true_values[i] - true_values[j])
  ad <- abs(f_a[i] - f_a[j])
  bd <- abs(f_b[i] - f_b[j])
  ap <- (ad - td)^2
  bp <- (bd - td)^2
  cat(sprintf("  (%d,%2d)    %10.2f  %10.2f  %10.4f  %10.2f  %10.4f\n",
              i, j, td, ad, ap, bd, bp))
}

cat(sprintf("\nFull variogram score (p=1, all 45 pairs):\n"))
cat(sprintf("  Model A: %.4f\n", variogram_score(f_a, true_values, p = 1)))
cat(sprintf("  Model B: %.4f\n", variogram_score(f_b, true_values, p = 1)))


# =====================================================================
# EXAMPLE 4: Limitation -- correct ranking but wrong gap magnitudes
# =====================================================================
cat("\n", strrep("=", 70), "\n")
cat("EXAMPLE 4: Limitation -- correct ranking but wrong gap magnitudes\n")
cat(strrep("=", 70), "\n\n")

true_values_4 <- c(1, 2, 5, 6, 10)

# Model A: correct ranking but gaps are wrong (uniform spacing)
model_a4 <- c(2, 4, 6, 8, 10)

# Model B: correct ranking AND correct gap structure, shifted up by 3
model_b4 <- true_values_4 + 3  # [4, 5, 8, 9, 13]

print_comparison(true_values_4, model_a4, model_b4,
                 "A (correct ranking, wrong gaps)",
                 "B (correct gaps, biased +3)")

cat("Key insight: Both models rank correctly, but Model B preserves\n")
cat("the gap structure (locs 3-4 close together, big jump to loc 5).\n")
cat("The variogram score captures this; pure ranking metrics would not.\n")


# =====================================================================
# FIGURE 1: Example 1 -- location profiles + score summary
# =====================================================================

loc_labels <- paste0("Loc ", seq_along(true_values))

df1 <- data.frame(
  location = rep(factor(loc_labels, levels = loc_labels), 3),
  value = c(true_values, model_a, model_b),
  model = rep(c("Truth", "Model A (biased, correct ranking)",
                "Model B (close, wrong ranking)"), each = 10)
)
df1$model <- factor(df1$model, levels = c(
  "Truth", "Model A (biased, correct ranking)",
  "Model B (close, wrong ranking)"
))

p1_bars <- ggplot(df1, aes(x = location, y = value, fill = model)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  scale_fill_manual(values = c("Truth" = "grey30",
                                "Model A (biased, correct ranking)" = "#2166AC",
                                "Model B (close, wrong ranking)" = "#B2182B")) +
  labs(title = "Example 1: Constant bias vs close-but-misordered",
       subtitle = sprintf(
         "Model A: MAE=%.1f, VS=%.2f  |  Model B: MAE=%.2f, VS=%.2f",
         mae(model_a, true_values),
         variogram_score(model_a, true_values, p = 1),
         mae(model_b, true_values),
         variogram_score(model_b, true_values, p = 1)),
       x = NULL, y = "Incidence", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 45, hjust = 1))

dm_truth <- pairwise_diff_matrix(true_values)
dm_a     <- pairwise_diff_matrix(model_a)
dm_b     <- pairwise_diff_matrix(model_b)

err_a <- (dm_a - dm_truth)^2
err_b <- (dm_b - dm_truth)^2

df_err <- rbind(
  mat_to_df(err_a, "Model A"),
  mat_to_df(err_b, "Model B")
)
df_err$source <- factor(df_err$source, levels = c("Model A", "Model B"))

p1_heat <- ggplot(df_err, aes(x = col, y = row, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "#B2182B",
                      name = expression((Delta*f - Delta*y)^2)) +
  scale_y_reverse() +
  facet_wrap(~source) +
  coord_equal() +
  labs(title = "Pairwise difference errors (p=1)",
       subtitle = "Each cell: (|f_i - f_j| - |y_i - y_j|)^2. Sum = variogram score.",
       x = "Location", y = "Location") +
  theme_minimal(base_size = 11)

fig1 <- p1_bars / p1_heat + plot_layout(heights = c(1, 1))


# =====================================================================
# FIGURE 2: Example 2 -- hotspot misidentification
# =====================================================================

loc_labels_2 <- paste0("Loc ", seq_along(true_values_2))

df2 <- data.frame(
  location = rep(factor(loc_labels_2, levels = loc_labels_2), 3),
  value = c(true_values_2, model_a2, model_b2),
  model = rep(c("Truth", "Model A (scaled up, correct pattern)",
                "Model B (closer, wrong hotspot)"), each = 6)
)
df2$model <- factor(df2$model, levels = c(
  "Truth", "Model A (scaled up, correct pattern)",
  "Model B (closer, wrong hotspot)"
))

p2_bars <- ggplot(df2, aes(x = location, y = value, fill = model)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  scale_fill_manual(values = c("Truth" = "grey30",
                                "Model A (scaled up, correct pattern)" = "#2166AC",
                                "Model B (closer, wrong hotspot)" = "#B2182B")) +
  labs(title = "Example 2: Correct spatial pattern vs misidentified hotspot",
       subtitle = sprintf(
         "Model A: MAE=%.2f, VS=%.2f  |  Model B: MAE=%.2f, VS=%.2f",
         mae(model_a2, true_values_2),
         variogram_score(model_a2, true_values_2, p = 1),
         mae(model_b2, true_values_2),
         variogram_score(model_b2, true_values_2, p = 1)),
       x = NULL, y = "Incidence", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

dm_truth2 <- pairwise_diff_matrix(true_values_2)
dm_a2     <- pairwise_diff_matrix(model_a2)
dm_b2     <- pairwise_diff_matrix(model_b2)
err_a2    <- (dm_a2 - dm_truth2)^2
err_b2    <- (dm_b2 - dm_truth2)^2

df_err2 <- rbind(
  mat_to_df(err_a2, "Model A"),
  mat_to_df(err_b2, "Model B")
)
df_err2$source <- factor(df_err2$source, levels = c("Model A", "Model B"))

p2_heat <- ggplot(df_err2, aes(x = col, y = row, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "#B2182B",
                      name = expression((Delta*f - Delta*y)^2)) +
  scale_y_reverse() +
  facet_wrap(~source) +
  coord_equal() +
  labs(title = "Pairwise difference errors (p=1)",
       x = "Location", y = "Location") +
  theme_minimal(base_size = 11)

fig2 <- p2_bars / p2_heat + plot_layout(heights = c(1, 1))


# =====================================================================
# FIGURE 2b: Additive vs multiplicative bias -- why VS != 0 for scaling
# =====================================================================

df_diffs2 <- rbind(
  mat_to_df(dm_truth2, "Truth"),
  mat_to_df(dm_a2, "Model A (x1.5)"),
  mat_to_df(dm_b2, "Model B (wrong pattern)")
)
df_diffs2$source <- factor(df_diffs2$source, levels = c(
  "Truth", "Model A (x1.5)", "Model B (wrong pattern)"
))

p2b_diffs <- ggplot(df_diffs2, aes(x = col, y = row, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 1)), size = 3) +
  scale_fill_gradient(low = "white", high = "#2166AC",
                      name = "|f_i - f_j|") +
  scale_y_reverse() +
  facet_wrap(~source) +
  coord_equal() +
  labs(title = "Raw pairwise differences: additive bias = 0 penalty, multiplicative != 0",
       subtitle = paste0(
         "Multiplicative bias (x1.5) inflates ALL diffs uniformly ",
         "(each cell = 1.5x Truth). Pattern preserved, but magnitudes wrong.\n",
         "Model B distorts the PATTERN: hotspot gaps (row/col 6) are ",
         "selectively compressed."),
       x = "Location", y = "Location") +
  theme_minimal(base_size = 11) +
  theme(plot.subtitle = element_text(size = 9))

model_a2_additive <- true_values_2 + 3
dm_a2_add <- pairwise_diff_matrix(model_a2_additive)

df_diffs2_add <- rbind(
  mat_to_df(dm_truth2, "Truth"),
  mat_to_df(dm_a2_add, "Additive +3 (VS=0)"),
  mat_to_df(dm_a2, "Multiplicative x1.5 (VS=110)")
)
df_diffs2_add$source <- factor(df_diffs2_add$source, levels = c(
  "Truth", "Additive +3 (VS=0)", "Multiplicative x1.5 (VS=110)"
))

p2b_add_vs_mult <- ggplot(df_diffs2_add, aes(x = col, y = row, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 1)), size = 3) +
  scale_fill_gradient(low = "white", high = "#2166AC",
                      name = "|f_i - f_j|") +
  scale_y_reverse() +
  facet_wrap(~source) +
  coord_equal() +
  labs(title = "Why additive bias gives VS=0 but multiplicative bias does not",
       subtitle = paste0(
         "Additive +3: every cell is IDENTICAL to Truth (shift cancels in ",
         "differences). VS = 0.\n",
         "Multiplicative x1.5: every cell is 1.5x Truth. ",
         "Penalty per pair = (0.5 * |y_i-y_j|)^2 -- grows with gap size."),
       x = "Location", y = "Location") +
  theme_minimal(base_size = 11) +
  theme(plot.subtitle = element_text(size = 9))

fig2b <- p2b_add_vs_mult / p2b_diffs + plot_layout(heights = c(1, 1))


# =====================================================================
# FIGURE 3: Example 4 -- correct ranking but wrong gaps
# =====================================================================

loc_labels_4 <- paste0("Loc ", seq_along(true_values_4))

df4 <- data.frame(
  location = rep(factor(loc_labels_4, levels = loc_labels_4), 3),
  value = c(true_values_4, model_a4, model_b4),
  model = rep(c("Truth", "Model A (correct ranking, wrong gaps)",
                "Model B (correct gaps, biased +3)"), each = 5)
)
df4$model <- factor(df4$model, levels = c(
  "Truth", "Model A (correct ranking, wrong gaps)",
  "Model B (correct gaps, biased +3)"
))

p4_bars <- ggplot(df4, aes(x = location, y = value, fill = model)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  scale_fill_manual(values = c("Truth" = "grey30",
                                "Model A (correct ranking, wrong gaps)" = "#2166AC",
                                "Model B (correct gaps, biased +3)" = "#B2182B")) +
  labs(title = "Example 4: Both rank correctly, but gaps differ",
       subtitle = sprintf(
         "Model A: MAE=%.2f, VS=%.2f  |  Model B: MAE=%.2f, VS=%.2f",
         mae(model_a4, true_values_4),
         variogram_score(model_a4, true_values_4, p = 1),
         mae(model_b4, true_values_4),
         variogram_score(model_b4, true_values_4, p = 1)),
       x = NULL, y = "Incidence", fill = NULL) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

dm_truth4 <- pairwise_diff_matrix(true_values_4)
dm_a4     <- pairwise_diff_matrix(model_a4)
dm_b4     <- pairwise_diff_matrix(model_b4)
err_a4    <- (dm_a4 - dm_truth4)^2
err_b4    <- (dm_b4 - dm_truth4)^2

df_err4 <- rbind(
  mat_to_df(err_a4, "Model A"),
  mat_to_df(err_b4, "Model B")
)
df_err4$source <- factor(df_err4$source, levels = c("Model A", "Model B"))

p4_heat <- ggplot(df_err4, aes(x = col, y = row, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "#B2182B",
                      name = expression((Delta*f - Delta*y)^2)) +
  scale_y_reverse() +
  facet_wrap(~source) +
  coord_equal() +
  labs(title = "Pairwise difference errors (p=1)",
       x = "Location", y = "Location") +
  theme_minimal(base_size = 11)

fig3 <- p4_bars / p4_heat + plot_layout(heights = c(1, 1))


# =====================================================================
# Save
# =====================================================================

ggsave(file.path(out_dir, "variogram_ex1_bias_vs_misordered.png"),
       fig1, width = 9, height = 8, dpi = 150)
ggsave(file.path(out_dir, "variogram_ex2_hotspot.png"),
       fig2, width = 8, height = 8, dpi = 150)
ggsave(file.path(out_dir, "variogram_ex2b_additive_vs_multiplicative.png"),
       fig2b, width = 10, height = 10, dpi = 150)
ggsave(file.path(out_dir, "variogram_ex4_gaps.png"),
       fig3, width = 8, height = 8, dpi = 150)

cat("\nPlots saved to", out_dir, "\n")
