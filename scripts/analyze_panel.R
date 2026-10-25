# Usage: Rscript scripts/analyze_panel.R /path/to/panel.dta
source("R/panel.R")
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Supply one local .dta or .csv panel path")
path <- args[[1]]
if (!file.exists(path)) stop("Input file does not exist")
if (grepl("\\.dta$", path, ignore.case = TRUE)) {
  if (!requireNamespace("haven", quietly = TRUE)) stop("Install haven first")
  d <- as.data.frame(haven::read_dta(path))
} else if (grepl("\\.csv$", path, ignore.case = TRUE)) {
  d <- read.csv(path, stringsAsFactors = FALSE)
} else stop("Expected a .dta or .csv panel")
result <- fit_association(d)
save_association(result, "empirical_association")
print(result$audit)
cat("Association model only. Review coverage and estimation sample before interpretation.\n")
