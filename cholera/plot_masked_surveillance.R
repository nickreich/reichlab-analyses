# plot_masked_surveillance.R
#
# Multipage PDF of weekly suspected cholera cases (sCh) from the
# LOCATION-MASKED surveillance dataset (Zheng et al. 2026, Gates Open Research
# 10:16; OSF https://osf.io/2ncf7/). Location identifiers in this file are
# anonymized four-character codes, so each unique location_name is treated as
# a distinct series. Output: cholera/plots/masked_surveillance_by_location.pdf.
#
# By default we plot country-level series (spatial_scale == "country"). Set
# SCALE_FILTER to NULL for every unique code (~4000 pages) or to another
# spatial_scale level (e.g. "admin1", "admin2").
#
# Usage (from repo root):
#   Rscript cholera/plot_masked_surveillance.R
#
# Dependencies: dplyr, ggplot2.

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

SCALE_FILTER <- "country"  # set to NULL for all masked locations
IN_FILE  <- "cholera/data/Location_masked_surveillance_dataset.csv"
OUT_FILE <- "cholera/plots/masked_surveillance_by_location.pdf"

dir.create(dirname(OUT_FILE), recursive = TRUE, showWarnings = FALSE)

surv <- utils::read.csv(IN_FILE, stringsAsFactors = FALSE)
surv$TL <- as.Date(surv$TL)
surv$TR <- as.Date(surv$TR)

if (!is.null(SCALE_FILTER)) {
  surv <- dplyr::filter(surv, spatial_scale == SCALE_FILTER)
}

locs <- sort(unique(surv$location_name))
message("Plotting ", length(locs), " masked locations at scale '",
        ifelse(is.null(SCALE_FILTER), "all", SCALE_FILTER), "' -> ", OUT_FILE)

pdf(OUT_FILE, width = 8, height = 3.5)
on.exit(dev.off(), add = TRUE)

for (loc in locs) {
  d <- surv[surv$location_name == loc, ]
  d <- d[order(d$TL), ]

  p <- ggplot(d, aes(x = TL, y = sCh)) +
    geom_line(color = "steelblue", linewidth = 0.4) +
    geom_point(size = 0.6, alpha = 0.5, color = "steelblue") +
    labs(
      title = paste0("masked location: ", loc),
      subtitle = sprintf("Suspected cholera cases, weekly (n=%d obs)", nrow(d)),
      x = "Week (period start)",
      y = "Suspected cases (sCh)"
    ) +
    theme_minimal(base_size = 11)

  print(p)
}

message("Wrote ", length(locs), " pages to ", normalizePath(OUT_FILE))
