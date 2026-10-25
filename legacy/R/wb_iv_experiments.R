library(tidyverse)
library(fixest)
library(haven)
library(modelsummary)
library(kableExtra)
library(ggplot2)


# Set working directory
repo_path <- "/Users/R_project"
setwd(repo_path)

cat("📁 Loading final dataset...\n")

final_data <- read_dta("data/output/chnineq_reg_ADM1_V04.dta")

cat("  ✓ Dataset loaded:", nrow(final_data), "observations\n")

cat("  ✓ Variables:", ncol(final_data), "\n")

# Create WB lag variables if they don't exist
if(!"L2_wb_tra_project_dum" %in% names(final_data) || 
   !"L2_wb_usd_tra_con_ln" %in% names(final_data)) {
  
  cat("Creating WB lag variables...\n")
  
  final_data <- final_data %>%
    arrange(iso3c, id_1, year) %>%
    group_by(iso3c, id_1) %>%
    mutate(
      L2_wb_tra_project_dum = lag(wb_tra_project_dum, 2),
      L2_wb_usd_tra_con = lag(wb_usd_tra_con, 2)
    ) %>%
    ungroup() %>%
    mutate(
      L2_wb_usd_tra_con_ln = log(L2_wb_usd_tra_con + 1)
    )
  
  cat("  ✓ Created WB lag variables\n")
} else {
  cat("  ✓ WB lag variables already exist\n")
  
  # Ensure log version exists
  if(!"L2_wb_usd_tra_con_ln" %in% names(final_data)) {
    final_data <- final_data %>%
      mutate(L2_wb_usd_tra_con_ln = log(L2_wb_usd_tra_con + 1))
  }
}

#done

# Apply sample restrictions (matching original Stata code)
final_data <- final_data %>%
  filter(
    iso3c != "CHN",                    # Exclude China
    !is.na(d_aw_gini0_sqkm),          # Non-missing outcome
    !is.na(L2_detrendIV_tra)          # Non-missing IV
  )

cat("✓ Final sample:", nrow(final_data), "observations\n")


cat("✓ Countries:", length(unique(final_data$iso3c)), "\n")

cat("✓ Regions:", length(unique(final_data$pid)), "\n")

cat("✓ Years:", paste(range(final_data$year), collapse = "-"), "\n")


#done

# Column 1: OLS
t1_col1_ols <- feols(
  d_aw_gini0_sqkm ~ L2_wb_tra_project_dum | pid + cy,
  data = final_data,
  vcov = ~cid
)

# Column 2: Reduced Form
t1_col2_rf <- feols(
  d_aw_gini0_sqkm ~ L2_detrendIV_tra | pid + cy,
  data = final_data %>% filter(!is.na(L2_wb_tra_project_dum)),
  vcov = ~cid
)

# Column 3: 2SLS (MAIN RESULT)
t1_col3_2sls <- feols(
  d_aw_gini0_sqkm ~ 1 | pid + cy | L2_wb_tra_project_dum ~ L2_detrendIV_tra,
  data = final_data,
  vcov = ~cid
)

# Column 4: First Stage
t1_col4_first <- feols(
  L2_wb_tra_project_dum ~ L2_detrendIV_tra | pid + cy,
  data = final_data %>% filter(!is.na(d_aw_gini0_sqkm)),
  vcov = ~cid
)

cat("✓ Columns 1-4 complete\n")

#done

# Column 5: OLS
t1_col5_ols_usd <- feols(
  d_aw_gini0_sqkm ~ L2_wb_usd_tra_con_ln | pid + cy,
  data = final_data,
  vcov = ~cid
)

# Column 6: Reduced Form (same as col 2)
t1_col6_rf <- t1_col2_rf

# Column 7: 2SLS
t1_col7_2sls_usd <- feols(
  d_aw_gini0_sqkm ~ 1 | pid + cy | L2_wb_usd_tra_con_ln ~ L2_detrendIV_tra,
  data = final_data,
  vcov = ~cid
)

# Column 8: First Stage
t1_col8_first_usd <- feols(
  L2_wb_usd_tra_con_ln ~ L2_detrendIV_tra | pid + cy,
  data = final_data %>% filter(!is.na(d_aw_gini0_sqkm)),
  vcov = ~cid
)

cat("✓ Columns 5-8 complete\n")


#done

# Create comprehensive table
modelsummary(
  list(
    "(1)\nOLS\nDummy" = t1_col1_ols,
    "(2)\nReduced\nForm" = t1_col2_rf,
    "(3)\n2SLS\nDummy" = t1_col3_2sls,
    "(4)\nFirst\nStage" = t1_col4_first,
    "(5)\nOLS\nLog USD" = t1_col5_ols_usd,
    "(6)\n2SLS\nLog USD" = t1_col7_2sls_usd,
    "(7)\nFirst Stage\nLog USD" = t1_col8_first_usd
  ),
  stars = c('*' = .1, '**' = .05, '***' = .01),
  coef_rename = c(
    "L2_wb_tra_project_dum" = "WB Transport Project (t-2)",
    "L2_detrendIV_tra" = "IV: Steel Shock × Cum. Projects (t-3)",
    "fit_L2_wb_tra_project_dum" = "WB Transport Project (fitted)",
    "L2_wb_usd_tra_con_ln" = "log(WB Transport USD, t-2)",
    "fit_L2_wb_usd_tra_con_ln" = "log(WB Transport USD, fitted)"
  ),
  gof_map = c("nobs", "r.squared", "adj.r.squared", "FE: pid", "FE: cy"),
  title = "Table 1: World Bank Transport Projects and Regional Inequality",
  notes = c(
    "Dependent variable: Δ Gini (within-region inequality from nighttime lights)",
    "Fixed effects: Region (pid) and Country-Year (cy)",
    "Standard errors clustered at country level (cid)",
    "Sample: 2000-2013, excluding China"
  ),
  output = "kableExtra"
) %>%
  kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    position = "center",
    font_size = 11
  ) %>%
  add_header_above(c(" " = 1, "Project Dummy" = 4, "log(USD)" = 3))


#done

# Function to extract stats
extract_stats <- function(model, name) {
  coef_val <- coef(model)[1]
  se_val <- se(model)[1]
  pval_val <- pvalue(model)[1]
  ci_vals <- confint(model)[1,]
  
  tibble(
    Model = name,
    Coef = coef_val,
    SE = se_val,
    Pval = pval_val,
    CI_lower = ci_vals[1],
    CI_upper = ci_vals[2],
    R2 = r2(model, type = "ar2"),
    N = nobs(model)
  )
}

# Collect results
results_df <- bind_rows(
  extract_stats(t1_col1_ols, "OLS (Dummy)"),
  extract_stats(t1_col2_rf, "Reduced Form"),
  extract_stats(t1_col3_2sls, "2SLS (Dummy)"),
  extract_stats(t1_col4_first, "First Stage"),
  extract_stats(t1_col5_ols_usd, "OLS (Log USD)"),
  extract_stats(t1_col7_2sls_usd, "2SLS (Log USD)"),
  extract_stats(t1_col8_first_usd, "First Stage (USD)")
) %>%
  mutate(
    CI_lower = unlist(CI_lower),
    CI_upper = unlist(CI_upper),
    Significance = case_when(
      Pval < 0.01 ~ "***",
      Pval < 0.05 ~ "**",
      Pval < 0.1 ~ "*",
      TRUE ~ ""
    )
  )

# Display
results_df %>%
  mutate(across(where(is.numeric), ~round(.x, 4))) %>%
  kable(caption = "Detailed Regression Statistics") %>%
  kable_styling(bootstrap_options = c("striped", "hover"), full_width = FALSE)

#done

# Plot main results
results_df %>%
  filter(Model %in% c("OLS (Dummy)", "2SLS (Dummy)", "OLS (Log USD)", "2SLS (Log USD)")) %>%
  mutate(
    Model = factor(Model, levels = rev(c("OLS (Dummy)", "2SLS (Dummy)", 
                                         "OLS (Log USD)", "2SLS (Log USD)"))),
    Method = ifelse(str_detect(Model, "OLS"), "OLS", "2SLS"),
    Significant = Pval < 0.05
  ) %>%
  ggplot(aes(x = Model, y = Coef, fill = Method)) +
  geom_col(width = 0.6, alpha = 0.8) +
  geom_errorbar(
    aes(ymin = CI_lower, ymax = CI_upper),
    width = 0.25
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  scale_fill_manual(values = c("OLS" = "#3498DB", "2SLS" = "#E74C3C")) +
  coord_flip() +
  labs(
    title = "Coefficient Estimates: WB Transport Projects on Regional Inequality",
    subtitle = "95% Confidence Intervals, Clustered SE at Country Level",
    x = NULL,
    y = "Coefficient (Effect on Gini)",
    caption = "Note: Negative = inequality reduction"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14)
  )

#done

# Extract main result (2SLS with dummy)
coef_2sls <- coef(t1_col3_2sls)[1]
se_2sls <- se(t1_col3_2sls)[1]
pval_2sls <- pvalue(t1_col3_2sls)[1]

# First Stage F-stat
fstat_first <- fitstat(t1_col3_2sls, "ivf")
fstat_val <- if(!is.null(fstat_first) && length(fstat_first$ivf) > 0) fstat_first$ivf[1] else NA


#done

if(pval_2sls < 0.1) {
  direction <- ifelse(coef_2sls > 0, "**increases**", "**reduces**")
  magnitude <- abs(coef_2sls) * 100
  
  cat(sprintf("The 2SLS estimate suggests that World Bank transport projects %s regional inequality by approximately **%.1f percentage points**.\n\n", direction, magnitude))
  
  if(pval_2sls < 0.05) {
    cat("This effect is **statistically significant at the 5% level**.\n\n")
  } else {
    cat("This effect is **marginally significant at the 10% level**.\n\n")
  }
  
  # Instrument strength
  if(fstat_val < 10) {
    cat("⚠️ **Caution:** The instrument is relatively weak (F-stat < 10), suggesting limited power to detect effects. Results should be interpreted cautiously.\n\n")
  }
  
} else {
  cat("**No statistically significant effect** detected at conventional significance levels (p = ", sprintf("%.3f", pval_2sls), ").\n\n", sep = "")
  
  cat("This could indicate:\n")
  cat("1. True null effect of WB projects on regional inequality\n")
  cat("2. Insufficient statistical power due to weak instrument (F-stat = ", sprintf("%.2f", fstat_val), ")\n", sep = "")
  cat("3. Heterogeneous effects that average out to zero\n\n")
}


#done

# Create Chinese project dummy
final_data <- final_data %>%
  mutate(
    chn_tra_project_dum = ifelse(!is.na(chn_tra_project_count) & chn_tra_project_count > 0, 1, 0)
  ) %>%
  arrange(iso3c, id_1, year) %>%
  group_by(iso3c, id_1) %>%
  mutate(
    L2_chn_tra_project_dum = lag(chn_tra_project_dum, 2)
  ) %>%
  ungroup()

# First Stage: Chinese → WB
first_chn <- feols(
  L2_wb_tra_project_dum ~ L2_chn_tra_project_dum | pid + cy,
  data = final_data,
  vcov = ~cid
)

# 2SLS: WB → Inequality (instrumented by Chinese)
sls_chn <- feols(
  d_aw_gini0_sqkm ~ 1 | pid + cy | L2_wb_tra_project_dum ~ L2_chn_tra_project_dum,
  data = final_data,
  vcov = ~cid
)

# Original (Steel IV) for comparison
first_steel <- feols(
  L2_wb_tra_project_dum ~ L2_detrendIV_tra | pid + cy,
  data = final_data,
  vcov = ~cid
)

sls_steel <- feols(
  d_aw_gini0_sqkm ~ 1 | pid + cy | L2_wb_tra_project_dum ~ L2_detrendIV_tra,
  data = final_data,
  vcov = ~cid
)

#done

# Extract F-statistics safely
fstat_steel <- fitstat(first_steel, "ivf1")
fstat_chn <- fitstat(first_chn, "f")

# Steel IV F-stat extraction
fstat_steel_val <- tryCatch({
  if(!is.null(fstat_steel) && !is.null(fstat_steel[[1]])) {
    as.numeric(fstat_steel[[1]][1])
  } else {
    NA
  }
}, error = function(e) NA)

# Chinese IV F-stat extraction
fstat_chn_val <- tryCatch({
  if(!is.null(fstat_chn) && !is.null(fstat_chn$f) && !is.null(fstat_chn$f$stat)) {
    as.numeric(fstat_chn$f$stat)
  } else if(!is.null(fstat_chn) && is.list(fstat_chn$f)) {
    as.numeric(fstat_chn$f[[1]])
  } else {
    NA
  }
}, error = function(e) NA)

# Create comparison table
iv_comparison <- tibble(
  Instrument = c("Steel Production Shock", "Chinese Projects"),
  `First Stage Coef` = c(coef(first_steel)[1], coef(first_chn)[1]),
  `First Stage SE` = c(se(first_steel)[1], se(first_chn)[1]),
  `First Stage P-value` = c(pvalue(first_steel)[1], pvalue(first_chn)[1]),
  `F-statistic` = c(
    ifelse(!is.na(fstat_steel_val), fstat_steel_val, NA),
    ifelse(!is.na(fstat_chn_val), fstat_chn_val, NA)
  ),
  `2SLS Coef` = c(coef(sls_steel)[1], coef(sls_chn)[1]),
  `2SLS SE` = c(se(sls_steel)[1], se(sls_chn)[1]),
  `2SLS P-value` = c(pvalue(sls_steel)[1], pvalue(sls_chn)[1])
)

#done

# Save results
write_csv(results_df %>% mutate(across(where(is.numeric), ~round(.x, 4))), 
          "output/tables/table1_detailed_stats_formatted_original.csv")

cat("✅ Results saved to: output/tables/table1_detailed_stats_formatted.csv\n")
