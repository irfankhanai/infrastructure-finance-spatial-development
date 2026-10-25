# Short version of chinese aid wrangling from CHN/IND paper
# Legacy code but everything works as intended 

# required
lop <- c("countrycode", "readstata13", "raster")
newp <- lop[!(lop %in% installed.packages()[,"Package"])]
if(length(newp)) install.packages(newp)
lapply(lop, require, character.only = TRUE)

### Prepare chn aid 

#load level_1a file (prejoined)
chn_aid <- read.csv("./data/input/chn_projects/data/level_1a.csv", stringsAsFactors = F)
#save.dta13(chn_aid, file = "chn_aid.dta", convert.factors = F)
    
#delete projects in China
chn_aid <- chn_aid[chn_aid$recipients_iso3!="CHN", ]
    
#check for date completeness
sum(is.na(chn_aid$transactions_start_year)) #1571 missings
sum(is.na(chn_aid$transactions_end_year)) #1571 missings
  
## load our new transport classification
chn_transport <- read.dta13("./data/input/chn_projects/data/all_flows_transport_project_types_final.dta")
chn_aid <- merge(x = chn_aid, y = chn_transport[,c("project_id", "transport_project_type")], by="project_id", all.x=T)

  
#load project_acillary file to re-capture year (from Brad Email 8.2.18: year = commitment year)
chn_aid_year <- read.csv("./data/input/chn_projects/data/projects_ancillary.csv", stringsAsFactors = F)
#save.dta13(chn_aid_year, file = "chn_aid_year.dta", convert.factors = F)
    
#check for date completeness
sum(is.na(chn_aid_year$year)) #0 missings, so I use those instead 
    
#add year variable from chn_aid_year
chn_aid <- merge(x = chn_aid, y = chn_aid_year[,c("project_id", "year")], by="project_id", all.x=T)
    
#add flow class variable from chn_aid_year
chn_aid <- merge(x = chn_aid, y = chn_aid_year[,c("project_id", "flow_class")], by="project_id", all.x=T)
    
#drop all precision codes above 4, to maintain ADM1 level only
chn_aid_adm1 <- chn_aid[chn_aid$precision_code < 5, ] #deletes 67 obs with PC 5, 587 obs with PC 6 and 1039 with PC 8, all remaining should be at ADM1 level  
save.dta13(chn_aid_adm1, file = "./data/output/chn_aid_adm1.dta", convert.factors = F)
    
##add spatial points (makes the dataframe spatially aware)
#ADM1

coordinates(chn_aid_adm1) <- ~longitude+latitude #tells R that those two variables are coordinates
crs(chn_aid_adm1) <- CRS(" +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") #tells R to use projection WGS84
shapefile(chn_aid_adm1, filename="./data/output/chn_aid_adm1.shp", overwrite=T)
  
### Prepare gadm 2.8 shapefile and intersect with aid to get id's
  
##ADM1
#load gadm shapefile
gadm28_adm1 <- shapefile("./data/input/gadm28_adm1_shp/gadm28_adm1.shp", stringsAsFactors = F)

#intersect chn aid points with gadm Version 2.8 shapefile 
chn_aid_gadm1 <- intersect(chn_aid_adm1, gadm28_adm1) 
shapefile(chn_aid_gadm1, filename = "./data/output/chn_aid_gadm1.shp", overwrite=TRUE)

chn_aid_gadm1_df <- as.data.frame(chn_aid_gadm1, stringsAsFactors = F) #keeps dataframe only
save.dta13(chn_aid_gadm1_df, file = "./data/output/chn_aid_gadm1.dta", convert.factors = F)  

