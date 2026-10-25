# Portable release utilities; separate from the archived replication scripts.
validate_panel <- function(d) {
  required <- c("iso3c", "id_1", "year", "aw_gini0_sqkm", "wb_tra_project_dum")
  absent <- setdiff(required, names(d))
  if (length(absent)) stop("Missing columns: ", paste(absent, collapse = ", "))
  if (!nrow(d)) stop("Panel is empty")
  if (anyNA(d[c("iso3c", "id_1", "year")])) stop("Missing panel keys")
  if (!is.numeric(d$year) || any(!is.finite(d$year)) || any(d$year != floor(d$year)))
    stop("Year must contain finite integers")
  if (anyDuplicated(d[c("iso3c", "id_1", "year")])) stop("Duplicate region-year keys")
  if (!is.numeric(d$aw_gini0_sqkm) || any(!is.finite(d$aw_gini0_sqkm) & !is.na(d$aw_gini0_sqkm)))
    stop("Outcome must be numeric and finite or missing")
  if (any(!is.na(d$wb_tra_project_dum) & !d$wb_tra_project_dum %in% c(0, 1)))
    stop("WB treatment must be binary or missing")
  invisible(d)
}

# Match a calendar year, never the preceding observed row across a gap.
calendar_lag <- function(d, variable, k = 1L) {
  if (length(k) != 1L || !is.finite(k) || k < 0 || k != floor(k)) stop("Invalid lag")
  if (!variable %in% names(d)) stop("Unknown variable")
  keys <- function(year) paste(d$iso3c, d$id_1, year, sep = "\r")
  d[[variable]][match(keys(d$year - k), keys(d$year))]
}

prepare_panel <- function(d) {
  validate_panel(d)
  d$delta_gini <- d$aw_gini0_sqkm - calendar_lag(d, "aw_gini0_sqkm", 1L)
  d$wb_lag2 <- calendar_lag(d, "wb_tra_project_dum", 2L)
  d$region <- interaction(d$iso3c, d$id_1, drop = TRUE)
  d$country_year <- interaction(d$iso3c, d$year, drop = TRUE)
  d
}

fit_association <- function(d) {
  if (!requireNamespace("fixest", quietly = TRUE)) stop("Install fixest first")
  d <- prepare_panel(d)
  sample <- d[d$iso3c != "CHN" & complete.cases(d[c("delta_gini", "wb_lag2")]), ]
  if (length(unique(sample$iso3c)) < 2L) stop("At least two country clusters are required")
  model <- fixest::feols(delta_gini ~ wb_lag2 | region + country_year,
                         data = sample, vcov = ~iso3c)
  list(model = model, audit = data.frame(
    input_rows = nrow(d), eligible_rows = nrow(sample), estimation_rows = stats::nobs(model),
    first_input_year = min(d$year), last_input_year = max(d$year),
    eligible_countries = length(unique(sample$iso3c))))
}

save_association <- function(result, label) {
  dir.create("results/generated", recursive = TRUE, showWarnings = FALSE)
  table <- as.data.frame(fixest::coeftable(result$model))
  table$term <- rownames(table)
  write.csv(table, paste0("results/generated/", label, "_coefficients.csv"), row.names = FALSE)
  write.csv(result$audit, paste0("results/generated/", label, "_sample.csv"), row.names = FALSE)
  capture.output(sessionInfo(), file = paste0("results/generated/", label, "_session.txt"))
}
