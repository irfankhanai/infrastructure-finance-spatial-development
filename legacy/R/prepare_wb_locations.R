# Legacy code but everything works as intended 

# required
lop <- c("tidyverse", "haven",  "sf")
newp <- lop[!(lop %in% installed.packages()[,"Package"])]
if(length(newp)) install.packages(newp)
lapply(lop, require, character.only = TRUE)

# invoke legacy behaviour
sf::sf_use_s2(FALSE)

### Prepare wb aid 

#load level_1a file (prejoined)
wb_aid <- read.csv("./data/input/world_bank_data/data/level_1a.csv", stringsAsFactors = F)

#check for date completeness
sum(is.na(wb_aid$transactions_start_year)) #0 missings, i.e. good to go
sum(is.na(wb_aid$transactions_end_year)) #0 missings, i.e. good to go

#drop all precision codes above 5, to maintain ADM1 level only
wb_aid_adm1 <- wb_aid[wb_aid$precision_code < 5, ]   
#save.dta13(wb_aid_adm1, file = "wb_aid_adm1.dta", convert.factors = F)

#load project_acillary file 
wb_aid_year <- read.csv("./data/input/world_bank_data/data/projects_ancillary.csv", stringsAsFactors = F) 
wb_aid_year <- select(wb_aid_year, project_id = PROJECT.ID, mjsec1_code= MJSECTOR.1.CODE, mjsec1 = MJSECTOR.1)

#add sectors
wb_aid_adm1 <- wb_aid_adm1 %>%  left_join(wb_aid_year, by ="project_id")

##add spatial points (makes the dataframe spatially aware)
#ADM1
wb_aid_adm1 <- st_as_sf(wb_aid_adm1, coords = c("longitude", "latitude"), crs=4326)

##ADM1
#intersect chn aid points with gadm Version 2.8 shapefile 
gadm28_adm1 <- st_read("./data/input/gadm28_adm1_shp/gadm28_adm1.shp")

wb_aid_gadm1 <- st_intersection(wb_aid_adm1, gadm28_adm1) 
wb_aid_gadm1_df <- wb_aid_gadm1 %>%  st_set_geometry(NULL)
write_dta(wb_aid_gadm1_df, path = "./data/analysis/wb_aid_gadm1_clean_2021.dta")  
