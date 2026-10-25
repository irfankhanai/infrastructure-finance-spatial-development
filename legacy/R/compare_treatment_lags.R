# ============================================================================
# FINAL ANALYSIS - NEW STRATEGY: TESTING LAGS
# ============================================================================


# ----------------------------------------------------------------------------
# SETUP
# ----------------------------------------------------------------------------
rm(list = ls())
gc()

library(tidyverse)
library(haven)
library(fixest)
library(modelsummary)

# Set the working directory to your main project folder
setwd("/Users/R_project") # Please double-check this is your exact path

cat("✓ Setup complete.\n\n")


# ----------------------------------------------------------------------------
# DATA LOADING
# ----------------------------------------------------------------------------

# Load your final, corrected dataset
panel <- read_dta("./data/output/WB_corrected_analysis_V51.dta")

# Clean variable names (replace dots with underscores)
panel_clean <- panel %>%
  rename_with(~gsub("\\.", "_", .x))

cat(paste("✓ Corrected dataset loaded with", nrow(panel_clean), "initial observations.\n\n"))


# ----------------------------------------------------------------------------
# REGRESSION ANALYSIS (TESTING DIFFERENT LAGS)
# ----------------------------------------------------------------------------

cat("🚀 Running new models with different lags...\n")

# --- START OF FIX ---
# Model 0: The original 2-year lag model (we need to run this to include it in the table)
model_final_levels <- feols(aw_gini0_sqkm ~ L2_wb_tra_project_dum + L1_aw_gini0_sqkm | pid + cy,
                            data = panel_clean,
                            cluster = ~cid)
# --- END OF FIX ---


# Model 1: Using a 1-year lag for the WB project
model_lag1 <- feols(aw_gini0_sqkm ~ L1_wb_tra_project_dum + L1_aw_gini0_sqkm | pid + cy,
                    data = panel_clean,
                    cluster = ~cid)

# Model 2: Using the contemporaneous (current year) WB project variable
model_lag0 <- feols(aw_gini0_sqkm ~ wb_tra_project_dum + L1_aw_gini0_sqkm | pid + cy,
                    data = panel_clean,
                    cluster = ~cid)

cat("✓ Regressions complete.\n\n")


# ----------------------------------------------------------------------------
# CREATE AND SAVE THE FINAL RESULTS TABLE
# ----------------------------------------------------------------------------

# Create a list of the models to put them in a table side-by-side
model_list <- list("2-Year Lag (Original)" = model_final_levels, 
                   "1-Year Lag" = model_lag1, 
                   "Contemporaneous" = model_lag0)

modelsummary(
  model_list,
  output = "./output/Final_Lag_Comparison_Results_V513.html",
  title = "Comparing Different Lags: World Bank Transport Projects and Regional Inequality",
  coef_map = c("L2_wb_tra_project_dum" = "WB Project (2-yr lag)",
               "L1_wb_tra_project_dum" = "WB Project (1-yr lag)",
               "wb_tra_project_dum" = "WB Project (Contemporaneous)"),
  gof_map = c("nobs", "r.squared"),
  stars = TRUE,
  notes = "All models control for lagged Gini. Standard errors are clustered at the country level."
)

cat("🎉 SUCCESS! New comparison table saved to: /output/Final_Lag_Comparison_Results.html\n")