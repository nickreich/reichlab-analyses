# download_data.R
#
# Downloads the public cholera surveillance and outbreak datasets released with
# Zheng et al. (2026), "Cholera surveillance time series in Africa between 2010
# and 2023", Gates Open Research 10:16. Source files are parquet on OSF
# (https://osf.io/2ncf7/); this script converts them to CSV for portability.
# The data dictionary (xlsx) is downloaded as-is.
#
# Usage (from repo root):
#   Rscript cholera/download_data.R
#
# Dependencies: arrow (for reading parquet). CSVs are skipped if already
# present and non-empty.

suppressPackageStartupMessages(library(arrow))

data_dir <- "cholera/data"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

parquet_targets <- list(
  Public_surveillance_dataset           = "https://osf.io/download/69cbfafc2bb63d1327e31f94/",
  Public_outbreak_dataset               = "https://osf.io/download/69cbfafb76ceddbc9a7c4587/",
  Location_masked_surveillance_dataset  = "https://osf.io/download/69cbfafbd2892f16f0863f8e/",
  Location_masked_outbreak_dataset      = "https://osf.io/download/69cbfafc9d1b283e9e81e0c5/"
)

for (name in names(parquet_targets)) {
  csv_path <- file.path(data_dir, paste0(name, ".csv"))
  if (file.exists(csv_path) && file.size(csv_path) > 0) {
    message("Already present: ", csv_path)
    next
  }
  tmp <- tempfile(fileext = ".parquet")
  on.exit(unlink(tmp), add = TRUE)
  message("Downloading ", name, " ...")
  utils::download.file(parquet_targets[[name]], destfile = tmp,
                       mode = "wb", quiet = TRUE)
  df <- read_parquet(tmp)
  utils::write.csv(df, csv_path, row.names = FALSE)
  message("Wrote ", csv_path, " (", nrow(df), " rows)")
}

dict_url <- "https://osf.io/download/8sf35/"
dict_path <- file.path(data_dir, "data_dictionaries.xlsx")
if (!file.exists(dict_path) || file.size(dict_path) == 0) {
  message("Downloading data_dictionaries.xlsx ...")
  utils::download.file(dict_url, destfile = dict_path,
                       mode = "wb", quiet = TRUE)
}

message("Done. Files in ", normalizePath(data_dir), ":")
print(list.files(data_dir))
