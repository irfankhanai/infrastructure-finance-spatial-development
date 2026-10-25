# Clear environment
rm(list = ls())
gc()

# Load packages
library(tidyverse)
library(haven)
library(sf)
library(readxl)
library(data.table)
library(countrycode)

# Set working directory
repo_path <- "/Users/R_project"
setwd(repo_path)

cat("✓ Working directory:", getwd(), "\n")

cat("✓ Packages loaded\n\n")

# Create output directories
dir.create("data/intermediate", showWarnings = FALSE, recursive = TRUE)
dir.create("data/output", showWarnings = FALSE, recursive = TRUE)


#{{{{{{{{{{{{Part 1: Prep Chinese Aid


cat("📦 PREP CHINA\n")

# Load Chinese aid data
chn_aid <- read.csv("./data/input/chn_projects/data/level_1a.csv", stringsAsFactors = FALSE)
chn_aid <- chn_aid[chn_aid$recipients_iso3 != "CHN", ]

# Merge transport classification
chn_transport <- read_dta("./data/input/chn_projects/data/all_flows_transport_project_types_final.dta")
chn_aid <- merge(chn_aid, chn_transport[, c("project_id", "transport_project_type")], 
                 by = "project_id", all.x = TRUE)

# Merge year and flow class
chn_aid_year <- read.csv("./data/input/chn_projects/data/projects_ancillary.csv", stringsAsFactors = FALSE)
chn_aid <- merge(chn_aid, chn_aid_year[, c("project_id", "year", "flow_class")], 
                 by = "project_id", all.x = TRUE)

# Filter ADM1 level
chn_aid_adm1 <- chn_aid[chn_aid$precision_code < 5, ]
write_dta(chn_aid_adm1, "./data/output/chn_aid_adm1.dta")

# Convert to spatial points
chn_aid_adm1_sf <- chn_aid_adm1 %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Load GADM and intersect
gadm28_adm1 <- st_read("./data/input/gadm28_adm1_shp/gadm28_adm1.shp", quiet = TRUE)
sf::sf_use_s2(FALSE)
chn_aid_adm1_sf <- st_make_valid(chn_aid_adm1_sf)
gadm28_adm1 <- st_make_valid(gadm28_adm1)

chn_aid_gadm1 <- st_join(chn_aid_adm1_sf, gadm28_adm1, join = st_intersects)

# Save as Stata file
chn_aid_gadm1_df <- chn_aid_gadm1 %>%
  st_drop_geometry() %>%
  as.data.frame()

write_dta(chn_aid_gadm1_df, "./data/output/chn_aid_gadm1.dta")

cat("✓ Chinese aid: ", nrow(chn_aid_gadm1_df), "observations\n\n")

#[[[[[[[[[[[[[Part 2: Prep World Bank Aid
cat("📦 PREP WB\n")

# Load WB aid data
wb_aid <- read.csv("./data/input/wb_aid_v1.4.2/data/level_1a.csv", stringsAsFactors = FALSE)

# Filter ADM1 level
wb_aid_adm1 <- wb_aid[wb_aid$precision_code < 5, ]

# Convert to SF
wb_aid_adm1_sf <- wb_aid_adm1 %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Intersect with GADM
wb_aid_gadm1 <- st_join(wb_aid_adm1_sf, gadm28_adm1, join = st_intersects)

# Save
wb_aid_gadm1_df <- wb_aid_gadm1 %>%
  st_drop_geometry() %>%
  as.data.frame()

write_dta(wb_aid_gadm1_df, "./data/output/wb_aid_gadm1.dta")

cat("✓ WB aid: ", nrow(wb_aid_gadm1_df), "observations\n\n")

#Part 3: Prep Auxiliary Data

cat("📦 PREP AUXILIARY DATA\n")

# 3. Bartke historical data
if(file.exists("code/build/prep_bartke.R")) {
  source("code/build/prep_bartke.R")
  cat("✓ Bartke data prepared\n")
}

# 4. Onshore petroleum
if(file.exists("code/build/prep_onshore.R")) {
  source("code/build/prep_onshore.R")
  cat("✓ Petroleum data prepared\n")
}

#[[[[[[[[Part 4: Prep Trade & Macro Data
cat("📊 PREP IMF DOTS\n")
# Exports to China
if (file.exists("data/input/IMF_DOTS/TXG_FOB_USD_panel_1980_2013.csv")) {
  exports_raw <- read_delim("data/input/IMF_DOTS/TXG_FOB_USD_panel_1980_2013.csv", 
                            delim = ";", show_col_types = FALSE)
  
  exports <- exports_raw %>%
    filter(nchar(country) == 2, nchar(partner) == 2) %>%
    filter(partner_name == "China", year >= 1995) %>%
    filter(!country %in% c("R1", "RE", "MQ", "GP", "GF", "F6", "E1", "F1", "B0", "CS")) %>%
    mutate(iso3c = countrycode(country, "iso2c", "iso3c")) %>%
    filter(!is.na(iso3c)) %>%
    dplyr::select(iso3c, year, exp_to_chn_fob_current = value) %>%
    mutate(exp_to_chn_fob_current = as.numeric(exp_to_chn_fob_current))
  
  write_dta(exports, "data/intermediate/TXG_FOB_USD_panel_1995_2013.dta")
  cat("✓ Exports data\n")
}

# Imports from China
if (file.exists("data/input/IMF_DOTS/TMG_CIF_USD_panel_1980_2013.csv")) {
  imports_raw <- read_delim("data/input/IMF_DOTS/TMG_CIF_USD_panel_1980_2013.csv", 
                            delim = ";", show_col_types = FALSE)
  
  imports <- imports_raw %>%
    filter(nchar(country) == 2, nchar(partner) == 2) %>%
    filter(partner_name == "China", year >= 1995) %>%
    filter(!country %in% c("R1", "RE", "MQ", "GP", "GF", "F6", "E1", "F1", "B0", "CS")) %>%
    mutate(iso3c = countrycode(country, "iso2c", "iso3c")) %>%
    filter(!is.na(iso3c)) %>%
    dplyr::select(iso3c, year, imp_from_chn_cif_current = value) %>%
    mutate(imp_from_chn_cif_current = as.numeric(imp_from_chn_cif_current))
  
  write_dta(imports, "data/intermediate/TMG_CIF_USD_panel_1995_2013.dta")
  cat("✓ Imports data\n")
}
## ✓ Imports data
cat("\n")


#[[[[[[[[[[[[[FDI Data
cat("📊 PREP FDI (UNCTAD)\n")

if (file.exists("data/input/fdi_unctad/US_FdiFlowsStock_ST201909021702_v2.csv")) {
  fdi_raw <- read_csv("data/input/fdi_unctad/US_FdiFlowsStock_ST201909021702_v2.csv", 
                      show_col_types = FALSE)
  
  fdi <- fdi_raw %>%
    rename(year = Year, economy = Economy, economylabel = `Economy Label`,
           direction = Direction, mode = Mode) %>%
    filter(year >= 1992, year < 2014, economy < 1000, economylabel != "World") %>%
    filter(economylabel == "China", direction == 2, mode == 8) %>%
    rename(fdiCHN_UNCTAD_cur = `US dollars at current prices in millions`) %>%
    dplyr::select(year, fdiCHN_UNCTAD_cur)
  
  write_dta(fdi, "data/intermediate/fdiCHN_UNCTAD.dta")
  cat("✓ FDI data\n\n")
}


#[[[[[[[[[[Income Classification

cat("📊 PREP INCOME LEVELS\n")

# Income levels (2000)
if (file.exists("data/input/income_levs_wb/GNI_Per_Capita_&_Income_Thresholds_data.csv")) {
  wb_inc_raw <- read_csv("data/input/income_levs_wb/GNI_Per_Capita_&_Income_Thresholds_data.csv",
                         show_col_types = FALSE)
  
  wb_inc_2000 <- wb_inc_raw %>%
    filter(Year == 2000, !is.na(Countrycode), Countrycode != "") %>%
    mutate(
      low_middle_2000 = ifelse(!is.na(`Max. Ny Gnp Pcap Cd`), `Max. Ny Gnp Pcap Cd` < 2995, NA),
      low_2000 = ifelse(!is.na(`Max. Ny Gnp Pcap Cd`), `Max. Ny Gnp Pcap Cd` < 755, NA)
    ) %>%
    mutate(
      low_middle_2000 = case_when(
        Countryname %in% c("Somalia", "South Sudan", "Djibouti", "Afghanistan", "Timor-Leste") ~ TRUE,
        Countrycode == "PRK" ~ TRUE,
        TRUE ~ low_middle_2000
      ),
      low_2000 = case_when(
        Countryname %in% c("Somalia", "South Sudan", "Djibouti", "Afghanistan", "Timor-Leste") ~ TRUE,
        Countrycode == "PRK" ~ TRUE,
        TRUE ~ low_2000
      )
    ) %>%
    dplyr::select(iso3c = Countrycode, low_middle_2000, low_2000)
  
  write_dta(wb_inc_2000, "data/intermediate/inc_levs_wb_2000.dta")
  cat("✓ Income 2000\n")
}

# Income panel (1987-2016)
if (file.exists("data/input/income_levs_wb/OGHIST.xlsx")) {
  wb_inc_panel_raw <- read_excel("data/input/income_levs_wb/OGHIST.xlsx", 
                                 sheet = "Country Analytical History",
                                 range = "A12:AM229")
  
  names(wb_inc_panel_raw)[1:2] <- c("iso3c", "cname")
  years <- 1987:2016
  names(wb_inc_panel_raw)[3:length(names(wb_inc_panel_raw))] <- paste0("y_", years)
  
  wb_inc_panel <- wb_inc_panel_raw %>%
    pivot_longer(cols = starts_with("y_"), names_to = "year", values_to = "wb_inc") %>%
    mutate(year = as.numeric(str_remove(year, "y_"))) %>%
    dplyr::select(iso3c, year, wb_inc)
  
  write_dta(wb_inc_panel, "data/intermediate/wb_inc.dta")
  cat("✓ Income panel\n")
}


#[[[[WDI Population

cat("📊 PREP WDI\n")

if (!requireNamespace("WDI", quietly = TRUE)) {
  install.packages("WDI")
}
library(WDI)

wdi_data <- WDI(indicator = "SP.POP.TOTL", start = 2000, end = 2000, extra = TRUE)

wdi_clean <- wdi_data %>%
  rename(wdi_pop = SP.POP.TOTL) %>%
  dplyr::select(iso3c, wdi_pop) %>%
  filter(!is.na(iso3c), !is.na(wdi_pop))

write_dta(wdi_clean, "data/intermediate/wdi.dta")
cat("✓ WDI population\n\n")



#[[[[[[[[[[[[[Part 5: Collapse to ADM1-Year
#hinese Aid]

cat("📦 COLLAPSE CHINESE AID\n")
chn_aid_raw <- read_dta("data/output/chn_aid_gadm1.dta")

chn_aid <- chn_aid_raw %>%
  filter(year >= 2000, year <= 2014) %>%
  rename(crs_sector = ad_sector_codes, usd_con = even_split_commitments, iso3c = ISO) %>%
  mutate(
    # Sector amounts
    usd_soc_con = ifelse(crs_sector < 200, usd_con, NA),
    usd_eco_con = ifelse(crs_sector > 200 & crs_sector < 300, usd_con, NA),
    usd_tra_con = ifelse(crs_sector == 210, usd_con, NA),
    # Project counts
    project_count = 1,
    tra_project_count = ifelse(crs_sector == 210, 1, NA)
  )

# Collapse to ADM1-year
chn_aid_collapsed <- chn_aid %>%
  group_by(iso3c, ID_1, year) %>%
  summarise(
    NAME_1 = first(NAME_1),
    across(starts_with("usd_"), ~sum(.x, na.rm = TRUE)),
    across(ends_with("_count"), ~sum(.x, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(across(starts_with("usd_") | ends_with("_count"), ~ifelse(.x == 0, NA, .x))) %>%
  rename_with(~paste0("chn_", .x), .cols = c(starts_with("usd_"), ends_with("_count"))) %>%
  rename(id_1 = ID_1, name_1 = NAME_1)

write_dta(chn_aid_collapsed, "data/output/chn_aid_global_adm1.dta")
cat("✓ Chinese aid collapsed:", nrow(chn_aid_collapsed), "obs\n\n")


#[[[[[[[[[[[Chinese Completed Projects

cat("📦 COLLAPSE CHINESE COMPLETED AID\n")


chn_comp_aid <- chn_aid_raw %>%
  filter(year >= 2000, year <= 2014, status != "Implementation") %>%
  rename(crs_sector = ad_sector_codes, usd_con = even_split_commitments, iso3c = ISO) %>%
  mutate(
    usd_tra_con = ifelse(crs_sector == 210, usd_con, NA),
    tra_project_count = ifelse(crs_sector == 210, 1, NA)
  ) %>%
  group_by(iso3c, ID_1, year) %>%
  summarise(
    NAME_1 = first(NAME_1),
    across(starts_with("usd_"), ~sum(.x, na.rm = TRUE)),
    across(ends_with("_count"), ~sum(.x, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(across(starts_with("usd_") | ends_with("_count"), ~ifelse(.x == 0, NA, .x))) %>%
  rename_with(~paste0("chn_comp_", .x), .cols = c(starts_with("usd_"), ends_with("_count"))) %>%
  rename(id_1 = ID_1, name_1 = NAME_1)

write_dta(chn_comp_aid, "data/output/chn_aid_global_completedonly_adm1.dta")
cat("✓ Completed aid collapsed\n\n")

#[[[[[[[[[[[[World Bank Aid

cat("📦 COLLAPSE WB AID\n")

wb_aid_raw <- read_dta("data/output/wb_aid_gadm1.dta")

wb_aid <- wb_aid_raw %>%
  mutate(year = transactions_start_year) %>%
  filter(year >= 2000, year <= 2014) %>%
  mutate(
    crs_sector = as.numeric(str_extract(ad_sector_codes, "^[0-9]+")),
    usd_con = even_split_commitments,
    usd_tra_con = ifelse(crs_sector == 210, even_split_commitments, NA),
    project_count = 1,
    tra_project_count = ifelse(crs_sector == 210, 1, NA)
  ) %>%
  rename(iso3c = ISO, id_1 = ID_1, name_1 = NAME_1) %>%
  group_by(iso3c, id_1, year) %>%
  summarise(
    name_1 = first(name_1),
    usd_con = sum(usd_con, na.rm = TRUE),
    project_count = sum(project_count, na.rm = TRUE),
    tra_project_count = sum(tra_project_count, na.rm = TRUE),
    usd_tra_con = sum(usd_tra_con, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  distinct(iso3c, id_1, year, .keep_all = TRUE) %>%
  rename_with(~paste0("wb_", .x), .cols = c(usd_con, project_count, usd_tra_con, tra_project_count))

write_dta(wb_aid, "data/intermediate/wb_aid_global_adm1.dta")

cat("✓ WB aid collapsed:", nrow(wb_aid), "obs\n\n")

#[[[[[[[[[[Part 6: Merge All Data

cat("🔗 MERGE ALL DATASETS\n")
# 1. Base: Chinese aid
panel <- read_dta("data/output/chn_aid_global_adm1.dta") %>%
  filter(iso3c != "CHN") %>%
  mutate(id_1 = as.character(id_1))

cat("✓ Base:", nrow(panel), "obs\n")

# 2. Merge nighttime lights + Gini (CRITICAL)
if (file.exists("data/input/allginis/within_gadm1.csv")) {
  lights_gini <- read_csv("data/input/allginis/within_gadm1.csv", show_col_types = FALSE) %>%
    rename(iso3c = ISO, id_1 = ID_1) %>%
    mutate(id_1 = as.character(id_1))
  
  panel <- panel %>%
    left_join(lights_gini, by = c("iso3c", "id_1", "year")) %>%
    filter(!is.na(aw_gini0_sqkm))
  
  cat("✓ Lights+Gini:", nrow(panel), "obs\n")
}

# 3. Completed Chinese aid
if (file.exists("data/output/chn_aid_global_completedonly_adm1.dta")) {
  chn_completed <- read_dta("data/output/chn_aid_global_completedonly_adm1.dta") %>%
    mutate(id_1 = as.character(id_1))
  panel <- panel %>% left_join(chn_completed, by = c("iso3c", "id_1", "year"))
  cat("✓ Completed Chinese aid\n")
}

# 4. WB aid
if (file.exists("data/intermediate/wb_aid_global_adm1.dta")) {
  wb_aid <- read_dta("data/intermediate/wb_aid_global_adm1.dta") %>%
    mutate(id_1 = as.character(id_1))
  panel <- panel %>%
    left_join(wb_aid, by = c("iso3c", "id_1", "year")) %>%
    mutate(
      wb_project_count = ifelse(is.na(wb_project_count) & year >= 2000 & year <= 2014, 0, wb_project_count),
      wb_usd_con = ifelse(is.na(wb_usd_con) & year >= 2000 & year <= 2014, 0, wb_usd_con),
      wb_tra_project_count = ifelse(is.na(wb_tra_project_count) & year >= 2000 & year <= 2014, 0, wb_tra_project_count),
      wb_usd_tra_con = ifelse(is.na(wb_usd_tra_con) & year >= 2000 & year <= 2014, 0, wb_usd_tra_con),
      wb_project_dum = ifelse(wb_project_count > 0, 1, 0),
      wb_tra_project_dum = ifelse(wb_tra_project_count > 0, 1, 0)
    )
  cat("✓ WB aid\n")
}


# 5-13. Merge auxiliary data (FDI, income, trade, etc.)
aux_files <- list(
  list(file = "data/intermediate/fdiCHN_UNCTAD.dta", by = "year", name = "FDI"),
  list(file = "data/intermediate/wb_inc.dta", by = c("iso3c", "year"), name = "Income panel"),
  list(file = "data/intermediate/TXG_FOB_USD_panel_1995_2013.dta", by = c("iso3c", "year"), name = "Exports"),
  list(file = "data/intermediate/TMG_CIF_USD_panel_1995_2013.dta", by = c("iso3c", "year"), name = "Imports"),
  list(file = "data/intermediate/wdi.dta", by = "iso3c", name = "Population"),
  list(file = "data/intermediate/inc_levs_wb_2000.dta", by = "iso3c", name = "Income 2000")
)

for (f in aux_files) {
  if (file.exists(f$file)) {
    aux_data <- read_dta(f$file)
    if ("id_1" %in% names(aux_data)) aux_data <- aux_data %>% mutate(id_1 = as.character(id_1))
    panel <- panel %>% left_join(aux_data, by = f$by)
    cat("✓", f$name, "\n")
  }
}

# Instruments
if (file.exists("data/output/final_instruments.dta")) {
  instruments <- read_dta("data/output/final_instruments.dta")
  panel <- panel %>% left_join(instruments, by = "year")
  cat("✓ Instruments\n")
}


cat("\n✓ Merged:", nrow(panel), "obs,", ncol(panel), "vars\n\n")


#[[[[[[[[[[[[Part 7: Construct Variables & Lags
cat("🔧 CONSTRUCT VARIABLES\n")
# Logs
panel <- panel %>%
  mutate(
    chn_usd_con_ln = log(chn_usd_con + 1),
    chn_usd_tra_con_ln = log(chn_usd_tra_con + 1),
    wb_usd_con_ln = log(wb_usd_con + 1),
    wb_usd_tra_con_ln = log(wb_usd_tra_con + 1)
  )

# Set Chinese vars to 0 if missing (2000-2014)
chn_vars <- grep("^chn_", names(panel), value = TRUE)
for (var in chn_vars) {
  panel[[var]] <- ifelse(is.na(panel[[var]]) & panel$year >= 2000 & panel$year <= 2014, 0, panel[[var]])
}

# Panel IDs
panel <- panel %>%
  mutate(
    pid = paste(iso3c, id_1),
    cy = paste(iso3c, year),
    cid = iso3c
  )

cat("✓ Variables constructed\n")

cat("🔧 CREATE LAGS\n")

panel <- panel %>% arrange(iso3c, id_1, year)
setDT(panel)

# Lag Chinese aid (1-7 years)
lag_vars_chn <- c("chn_usd_con", "chn_usd_tra_con", "chn_project_count", "chn_tra_project_count")
for (var in lag_vars_chn) {
  for (lag in 1:7) {
    new_var <- paste0("L", lag, "_", var)
    panel[, (new_var) := data.table::shift(get(var), n = lag, type = "lag"), by = .(iso3c, id_1)]
  }
}

# Lag WB aid (1-7 years)
lag_vars_wb <- c("wb_usd_con", "wb_usd_tra_con", "wb_project_count", "wb_tra_project_count", 
                 "wb_project_dum", "wb_tra_project_dum")
for (var in lag_vars_wb) {
  for (lag in 1:7) {
    new_var <- paste0("L", lag, "_", var)
    panel[, (new_var) := data.table::shift(get(var), n = lag, type = "lag"), by = .(iso3c, id_1)]
  }
}

# Lag Gini and create first difference
panel[, L1_aw_gini0_sqkm := data.table::shift(aw_gini0_sqkm, n = 1, type = "lag"), by = .(iso3c, id_1)]
panel[, d_aw_gini0_sqkm := aw_gini0_sqkm - L1_aw_gini0_sqkm]

cat("✓ Lags created (1-7 years)\n")


cat("🔧 CREATE IV\n")

# Cumulative project counts
# panel[, cum_chn := cumsum(ifelse(is.na(chn_project_count), 0, chn_project_count)), by = .(iso3c, id_1)]
# panel[, cum_wb := cumsum(ifelse(is.na(wb_project_count), 0, wb_project_count)), by = .(iso3c, id_1)]
# 
# # IV: Steel shock × (1 + cumulative)
# if ("factor1" %in% names(panel)) {
#   panel[, detrendIV_tra := factor1 * (1 + cum_chn)]
#   panel[, L3_detrendIV_tra := data.table::shift(detrendIV_tra, n = 3, type = "lag"), by = .(iso3c, id_1)]
#   cat("✓ IV with 3-year lag\n")
# }
# 
# panel <- as_tibble(panel)


#++++++++++++++++++++++++

# Cumulative project counts for Chinese and World Bank projects
panel[, cum_chn := cumsum(ifelse(is.na(chn_project_count), 0, chn_project_count)), by = .(iso3c, id_1)]
panel[, cum_wb := cumsum(ifelse(is.na(wb_project_count), 0, wb_project_count)), by = .(iso3c, id_1)]

# Create the instrument with a 2-year lag (instead of 3-year lag)
panel[, detrendIV_tra := factor1 * (1 + cum_chn)]  # Factor1 is retained for now
panel[, L2_detrendIV_tra := data.table::shift(detrendIV_tra, n = 2, type = "lag"), by = .(iso3c, id_1)]  # Use 2-year lag

cat("✓ IV with 2-year lag created\n")

# Convert the panel to a tibble for further use
panel <- as_tibble(panel)


#++++++++++++++++++++++++



#++++++++++++++++++
# # 1. Calculate the cumulative World Bank projects (transport sector only)
# panel[, cum_wb := cumsum(ifelse(is.na(wb_project_count), 0, wb_project_count)), by = .(iso3c, id_1)]
# 
# # 2. Calculate the cumulative Chinese projects
# panel[, cum_chn := cumsum(ifelse(is.na(chn_project_count), 0, chn_project_count)), by = .(iso3c, id_1)]
# 
# # 3. Create the 2-year lag for both World Bank and Chinese project counts
# panel[, L2_cum_wb := data.table::shift(cum_wb, n = 2, type = "lag"), by = .(iso3c, id_1)]
# panel[, L2_cum_chn := data.table::shift(cum_chn, n = 2, type = "lag"), by = .(iso3c, id_1)]
# 
# # 4. Create the instrument: Use the lagged cumulative project counts (2-year lag)
# panel[, detrendIV_tra := L2_cum_wb * (1 + L2_cum_chn)]  # Instrument for WB projects (2-year lag)
# 
# # 5. Apply the same logic to the main outcome and treatment variable for the instrument
# panel[, L2_detrendIV_tra := data.table::shift(detrendIV_tra, n = 2, type = "lag"), by = .(iso3c, id_1)]
# 
# cat("✓ 2-year lag instrument created successfully!\n")
# 
# # Convert the panel to a tibble for further use
# panel <- as_tibble(panel)
 
#++++++++++++++++++


#+++++++++++++++++++++++++++
# Create IV using historical share of WB transport projects instead of Steel shock

# # 1. Cumulative World Bank Project Counts (transport sector only)
# panel[, cum_wb := cumsum(ifelse(is.na(wb_project_count), 0, wb_project_count)), by = .(iso3c, id_1)]
# 
# # 2. Cumulative Chinese Project Counts
# panel[, cum_chn := cumsum(ifelse(is.na(chn_project_count), 0, chn_project_count)), by = .(iso3c, id_1)]
# 
# # 3. Calculate the total World Bank commitments for each year (total for all sectors)
# total_wb_con <- panel %>%
#   group_by(year) %>%
#   summarise(total_wb_con = sum(wb_usd_con, na.rm = TRUE))
# 
# # 4. Merge the total World Bank commitments and calculate the historical share
# panel <- panel %>%
#   left_join(total_wb_con, by = "year") %>%
#   mutate(
#     historical_share = cum_wb / total_wb_con  # Calculating the historical share for each region
#   )
# 
# # 5. Instrument: Historical Share as the IV for WB transport projects
# # Use historical_share as the instrument for WB projects in the 2SLS
# panel[, detrendIV_tra := historical_share * (1 + cum_wb)]  # Instrument for WB projects
# panel[, L3_detrendIV_tra := data.table::shift(detrendIV_tra, n = 3, type = "lag"), by = .(iso3c, id_1)]  # Apply 3-year lag
# cat("✓ IV using Historical Share with 3-year lag\n")
# 
# # Convert the panel to a tibble
# panel <- as_tibble(panel)
#++++++++++++++++++++++++++++++


#[[[[[[[[[[Part 8: Sample Restrictions & Save

cat("🔧 SAMPLE RESTRICTIONS\n")
panel <- panel %>%
  filter(
    year >= 2000, year <= 2013,
    !is.na(d_aw_gini0_sqkm)
  )

# Drop small countries
if ("wdi_pop" %in% names(panel)) {
  panel <- panel %>%
    filter(is.na(wdi_pop) | wdi_pop >= 1000000)
  cat("✓ Dropped small countries\n")
}

cat("✓ Final sample:", nrow(panel), "obs\n\n")

cat("💾 SAVE FINAL DATASET\n")



# Clean column names
panel_clean <- panel %>%
  rename_with(~gsub("\\.", "_", .x))

write_dta(panel_clean, "data/output/chnineq_reg_ADM1_V04.dta")

cat("✅ SAVED: chnineq_reg_ADM1.dta\n")

cat("   Observations:", nrow(panel_clean), "\n")

cat("   Variables:", ncol(panel_clean), "\n")

cat("   Years: 2000-2013\n\n")