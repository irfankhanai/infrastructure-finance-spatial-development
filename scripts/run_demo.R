# Synthetic smoke test; no empirical claims or client data.
source("R/panel.R")
set.seed(2026)
d <- expand.grid(iso3c = sprintf("C%02d", 1:30), id_1 = 1:8, year = 2000:2013,
                 KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
d$wb_tra_project_dum <- rbinom(nrow(d), 1, 0.2)
d$aw_gini0_sqkm <- runif(nrow(d), 0.25, 0.65)
result <- fit_association(d)
save_association(result, "synthetic")
print(result$audit)
cat("Synthetic demonstration completed. These estimates are not research findings.\n")
