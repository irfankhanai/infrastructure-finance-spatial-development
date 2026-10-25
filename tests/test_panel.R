source("R/panel.R")
fails <- function(expr) inherits(tryCatch({force(expr); NULL}, error = identity), "error")
d <- data.frame(iso3c = c("AAA", "AAA", "AAA", "BBB"), id_1 = 1,
                year = c(2000L, 2002L, 2003L, 2002L),
                aw_gini0_sqkm = c(.2, .3, .4, .5), wb_tra_project_dum = c(1, 0, 1, 0))
p <- prepare_panel(d)
stopifnot(is.na(p$delta_gini[2]), abs(p$delta_gini[3] - .1) < 1e-12,
          p$wb_lag2[2] == 1, is.na(p$wb_lag2[4]))
stopifnot(fails(validate_panel(rbind(d, d[1, ]))))
bad <- d; bad$year[1] <- NA
stopifnot(fails(validate_panel(bad)))
bad <- d; bad$wb_tra_project_dum[1] <- 2
stopifnot(fails(validate_panel(bad)))
stopifnot(fails(validate_panel(d[, -1])))
reordered <- d[c(3, 1, 4, 2), ]
stopifnot(identical(calendar_lag(reordered, "wb_tra_project_dum", 2),
                    calendar_lag(d, "wb_tra_project_dum", 2)[c(3, 1, 4, 2)]))
cat("Panel validation and calendar-lag checks passed.\n")
