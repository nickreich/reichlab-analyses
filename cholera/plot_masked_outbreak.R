# plot_masked_outbreak.R
#
# Multipage PDF of weekly suspected cholera cases (sCh) from the
# LOCATION-MASKED outbreak dataset (Zheng et al. 2026, Gates Open Research
# 10:16; OSF https://osf.io/2ncf7/). Location identifiers are anonymized
# four-character codes; outbreak episodes within a location are colored by
# outbreak_UID. Output: cholera/plots/masked_outbreak_by_location.pdf.
#
# By default we plot country-level series (spatial_scale == "country"). Set
# SCALE_FILTER to NULL for every masked location (~1100 pages).
#
# Usage (from repo root):
#   Rscript cholera/plot_masked_outbreak.R
#
# Dependencies: dplyr, ggplot2.

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

SCALE_FILTER <- "country"  # set to NULL for all masked locations
IN_FILE  <- "cholera/data/Location_masked_outbreak_dataset.csv"
OUT_FILE <- "cholera/plots/masked_outbreak_by_location.pdf"

dir.create(dirname(OUT_FILE), recursive = TRUE, showWarnings = FALSE)

ob <- utils::read.csv(IN_FILE, stringsAsFactors = FALSE)
ob$TL <- as.Date(ob$TL)
ob$TR <- as.Date(ob$TR)

if (!is.null(SCALE_FILTER)) {
  ob <- dplyr::filter(ob, spatial_scale == SCALE_FILTER)
}

locs <- sort(unique(ob$location_name))
message("Plotting ", length(locs), " masked locations at scale '",
        ifelse(is.null(SCALE_FILTER), "all", SCALE_FILTER), "' -> ", OUT_FILE)

pdf(OUT_FILE, width = 8, height = 3.5)
on.exit(dev.off(), add = TRUE)

for (loc in locs) {
  d <- ob[ob$location_name == loc, ]
  d <- d[order(d$TL), ]

  p <- ggplot(d, aes(x = TL, y = sCh, group = outbreak_UID, color = outbreak_UID)) +
    geom_line(linewidth = 0.4) +
    geom_point(size = 0.8, alpha = 0.7) +
    scale_color_viridis_d(option = "plasma", end = 0.85, guide = "none") +
    labs(
      title = paste0("masked location: ", loc),
      subtitle = sprintf("Outbreak episodes, weekly suspected cases (%d outbreaks, %d obs)",
                         length(unique(d$outbreak_UID)), nrow(d)),
      x = "Week (period start)",
      y = "Suspected cases (sCh)"
    ) +
    theme_minimal(base_size = 11)

  print(p)
}

message("Wrote ", length(locs), " pages to ", normalizePath(OUT_FILE))
