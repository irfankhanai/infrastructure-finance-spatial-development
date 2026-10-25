********************************************************************************
*** prepare aid variables 
********************************************************************************

*load data
use ./data/output/chn_aid_gadm1.dta, clear // new with tranport coding

*minor adjustments
drop if year < 2000 | year > 2014
ren ad_sector_codes crs_sector
ren ad_sector_names crs_sector_name

ren even_split_commitments usd_con
lab var usd_con "Value of the amount specified for the project (split per loc), constant 2014 USD"

ren ISO iso3c		

*gen oda / oof amounts 
gen usd_oda_con = usd_con if flow_class == "ODA-like"
gen usd_oof_con = usd_con if flow_class == "OOF-like" | flow_class == "Vague (Official Finance)"

*gen sector amounts
gen usd_soc_con=usd_con if crs_sector<200
gen usd_eco_con=usd_con if crs_sector>200 & crs_sector<300
gen usd_pro_con=usd_con if crs_sector>300 & crs_sector<400
gen usd_tra_con=usd_con if crs_sector==210
gen usd_ene_con=usd_con if crs_sector==230
gen usd_edu_con=usd_con if crs_sector==110
gen usd_hea_con=usd_con if crs_sector==120
gen usd_wat_con=usd_con if crs_sector==140
gen usd_non_con=usd_con if crs_sector==700 | crs_sector==420 | crs_sector==520 | crs_sector==920 | crs_sector==130 | crs_sector==510 | crs_sector==240


gen usd_lon_con=usd_con if transport_project_type=="urban roads"
replace usd_lon_con=usd_con if transport_project_type=="urban railways and tram lines"
gen usd_roa_con=usd_con if transport_project_type=="urban roads"
replace usd_roa_con=usd_con if transport_project_type=="long-distance roads"

* new transport types
gen usd_ntr_con=usd_con if transport_project_type=="urban roads"
replace usd_ntr_con=usd_con if transport_project_type=="long-distance roads" | ///
	transport_project_type=="urban railways and tram lines" | transport_project_type=="long-distance railways" |  transport_project_type=="bridges"

*gen spatial amounts
gen ones=1
bysort project_id: egen loc_count_mean=sum(ones)
bysort project_id ID_0 ID_1: egen loc_count_mean_adm1=sum(ones)
gen loc_count_max=loc_count_mean
gen loc_count_max_adm1=loc_count_mean_adm1

gen usd_nar_con=usd_con if loc_count_mean_adm1<2 & crs_sector==210
gen usd_bro_con=usd_con if loc_count_mean_adm1>=2 & crs_sector==210
gen usd_NAR_con=usd_con if loc_count_mean<2 & crs_sector==210
gen usd_BRO_con=usd_con if loc_count_mean>=2 & crs_sector==210

*a dummy for chinese projects
gen project_count = 1
lab var project_count "Dummy takes value 1 if there is a Chinese project in that year and adm1 region."

*a dummy for ODA chinese projects
gen oda_project_count = 1 if flow_class == "ODA-like"
lab var oda_project_count "Dummy takes value 1 if there is a ODA Chinese project in that year and adm1 region."

*a dummy for OOF chinese projects
gen oof_project_count = 1 if flow_class == "OOF-like" | flow_class == "Vague (Official Finance)"
lab var oof_project_count "Dummy takes value 1 if there is a OOF Chinese project in that year and adm1 region."

*a dummy for chinese projects by sector
gen soc_project_count = 1 if crs_sector<200
lab var soc_project_count "Dummy takes value 1 if there is a social Chinese project in that year and adm1 region."
gen eco_project_count = 1 if crs_sector>200 & crs_sector<300
lab var eco_project_count "Dummy takes value 1 if there is a economic Chinese project in that year and adm1 region."
gen pro_project_count = 1 if crs_sector>300 & crs_sector<400
lab var pro_project_count "Dummy takes value 1 if there is a production Chinese project in that year and adm1 region."
gen tra_project_count = 1 if crs_sector==210
lab var tra_project_count "Dummy takes value 1 if there is a transport Chinese project in that year and adm1 region."
gen ene_project_count = 1 if crs_sector==230
lab var ene_project_count "Dummy takes value 1 if there is a energy Chinese project in that year and adm1 region."
gen edu_project_count = 1 if crs_sector==110
lab var edu_project_count "Dummy takes value 1 if there is a education Chinese project in that year and adm1 region."
gen hea_project_count = 1 if crs_sector==120
lab var hea_project_count "Dummy takes value 1 if there is a health Chinese project in that year and adm1 region."
gen wat_project_count = 1 if crs_sector==140
lab var wat_project_count "Dummy takes value 1 if there is a water Chinese project in that year and adm1 region."
gen non_project_count = 1 if crs_sector==700 | crs_sector==420 | crs_sector==520 | crs_sector==920 | crs_sector==130 | crs_sector==510 | crs_sector==240
lab var non_project_count "Dummy takes value 1 if there is a non-steel Chinese project in that year and adm1 region."	
gen lon_project_count = 1 if transport_project_type=="urban railways and tram lines" | transport_project_type=="urban roads"
lab var lon_project_count "Dummy takes value 1 if there is a Chinese urban road/rail project in that year and adm1 region."
gen roa_project_count = 1 if transport_project_type=="urban roads" | transport_project_type=="long-distance roads"
lab var roa_project_count "Dummy takes value 1 if there is a Chinese road project in that year and adm1 region."

* new project types 
gen ntr_project_count = 1 if transport_project_type=="urban roads" | transport_project_type=="long-distance roads" | ///
	transport_project_type=="urban railways and tram lines" | transport_project_type=="long-distance railways" |  transport_project_type=="bridges"
lab var ntr_project_count "Dummy takes value 1 if there is a Chinese road, bridge or rail project in that year and adm1 region."	

*a dummy for chinese projects by spatial location
gen nar_project_count = 1 if loc_count_mean_adm1<2 & crs_sector==210
lab var nar_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations adm1)."
gen bro_project_count = 1 if loc_count_mean_adm1>=2 & crs_sector==210
lab var bro_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations adm1)."
gen NAR_project_count = 1 if loc_count_mean<2 & crs_sector==210
lab var NAR_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations project)."
gen BRO_project_count = 1 if loc_count_mean>=2 & crs_sector==210
lab var BRO_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations project)."

sort iso3c ID_1 year, stable

*STATS: Number of project-locations
sum

*STATS: Number of projects
codebook project_id

*STATS: Number of countries
codebook ID_0

*STATS: Number of ADM1 regions
*gen ID_01=ID_0+"_"+ID_1
*codebook ID_01

*STATS: Financial size by sector
egen SUMusd_con=sum(usd_con)
egen SUMusd_tra_con=sum(usd_tra_con)
egen SUMusd_eco_con=sum(usd_eco_con)
egen SUMusd_pro_con=sum(usd_pro_con)
egen SUMusd_soc_con=sum(usd_soc_con)

*STATS: Number of project-locations by sector
egen SUMproject_count=sum(project_count)
egen SUMtra_project_count=sum(tra_project_count) // 1215/4432
egen SUMeco_project_count=sum(eco_project_count) // 1906/4432
egen SUMpro_project_count=sum(pro_project_count) // 308/4432
egen SUMsoc_project_count=sum(soc_project_count) // 1843/4432
sum SUM*

*collapse to ADM1/2 levels
collapse (first) NAME_1 (sum) /*tra_*_project_count*/ usd_con project_count usd_oda_con oda_project_count usd_oof_con oof_project_count ///
	usd_soc_con soc_project_count usd_eco_con eco_project_count usd_pro_con pro_project_count ///
	usd_tra_con tra_project_count usd_ene_con ene_project_count usd_edu_con edu_project_count usd_hea_con hea_project_count usd_wat_con wat_project_count usd_non_con usd_lon_con usd_roa_con usd_ntr_con non_project_count lon_project_count roa_project_count  ntr_project_count ///
	usd_nar_con nar_project_count usd_bro_con bro_project_count usd_NAR_con NAR_project_count usd_BRO_con BRO_project_count ///
	(mean) loc_count_mean loc_count_mean_adm1 (max) loc_count_max loc_count_max_adm1, ///
	by(iso3c ID_1 year)

order iso3c NAME_* ID_*				

*label vars
lab var year "Year"
lab var iso3c "ISO3C country code"

lab var usd_con "Value of the amount specified for the project, constant 2014 USD"
lab var usd_oda_con "Value of the amount specified for the ODA project, constant 2014 USD"
lab var usd_oof_con "Value of the amount specified for the OOF project, constant 2014 USD"
lab var usd_soc_con "Value of the amount specified for the social project, constant 2014 USD"
lab var usd_eco_con "Value of the amount specified for the economic project, constant 2014 USD"
lab var usd_pro_con "Value of the amount specified for the production project, constant 2014 USD"
lab var usd_tra_con "Value of the amount specified for the transport project, constant 2014 USD"
lab var usd_ene_con "Value of the amount specified for the energy project, constant 2014 USD"
lab var usd_edu_con "Value of the amount specified for the education project, constant 2014 USD"
lab var usd_hea_con "Value of the amount specified for the health project, constant 2014 USD"
lab var usd_wat_con "Value of the amount specified for the water project, constant 2014 USD"
lab var usd_non_con "Value of the amount specified for the non-steel project, constant 2014 USD"
lab var usd_lon_con "Value of the amount specified for the urban project, constant 2014 USD"
lab var usd_roa_con "Value of the amount specified for the road project, constant 2014 USD"
lab var usd_ntr_con "Value of the amount specified for the road, bridge or rail project, constant 2014 USD"

lab var usd_nar_con "Value of the amount specified for narrowly dispersed projects, constant 2014 USD (#locations ADM1)"
lab var usd_bro_con "Value of the amount specified for broadly dispersed projects, constant 2014 USD (#locations ADM1)"
lab var usd_NAR_con "Value of the amount specified for narrowly dispersed projects, constant 2014 USD (#locations project)"
lab var usd_BRO_con "Value of the amount specified for broadly dispersed projects, constant 2014 USD (#locations project)"

lab var project_count "Count of Chinese aid project by adm1 and year"
lab var oda_project_count "Dummy takes value 1 if there is a ODA Chinese project in that year and adm1 region."
lab var oof_project_count "Dummy takes value 1 if there is a OOF Chinese project in that year and adm1 region."
lab var soc_project_count "Dummy takes value 1 if there is a social Chinese project in that year and adm1 region."
lab var eco_project_count "Dummy takes value 1 if there is a economic Chinese project in that year and adm1 region."
lab var pro_project_count "Dummy takes value 1 if there is a production Chinese project in that year and adm1 region."		
lab var tra_project_count "Dummy takes value 1 if there is a transport Chinese project in that year and adm1 region."
lab var ene_project_count "Dummy takes value 1 if there is a energy Chinese project in that year and adm1 region."
lab var edu_project_count "Dummy takes value 1 if there is a education Chinese project in that year and adm1 region."	
lab var hea_project_count "Dummy takes value 1 if there is a health Chinese project in that year and adm1 region."	
lab var wat_project_count "Dummy takes value 1 if there is a water Chinese project in that year and adm1 region."	
lab var non_project_count "Dummy takes value 1 if there is a non-steel Chinese project in that year and adm1 region."	
lab var lon_project_count "Dummy takes value 1 if there is a urban Chinese project in that year and adm1 region."
lab var roa_project_count "Dummy takes value 1 if there is a Chinese road project in that year and adm1 region."
lab var ntr_project_count "Dummy takes value 1 if there is a Chinese road, bridge or rail project in that year and adm1 region."	
lab var nar_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations adm1)"
lab var bro_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations adm1)"
lab var NAR_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations project)"
lab var BRO_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations project)"

*keep what's needed
sort iso3c ID_1 NAME_1 year
order iso3c  ID_1 NAME_1 year

keep NAME_1 iso3c ID_1 year ///
	usd_con usd_oda_con usd_oof_con usd_soc_con usd_eco_con usd_pro_con usd_tra_con usd_ene_con usd_edu_con usd_hea_con usd_wat_con usd_non_con usd_lon_con usd_roa_con usd_ntr_con ///
	project_count oda_project_count oof_project_count soc_project_count eco_project_count pro_project_count tra_project_count ene_project_count edu_project_count hea_project_count wat_project_count non_project_count lon_project_count roa_project_count ntr_project_count ///
	usd_nar_con nar_project_count usd_bro_con bro_project_count usd_NAR_con NAR_project_count usd_BRO_con BRO_project_count ///
	loc_* 

foreach var of varlist usd_con-BRO_project_count {
	replace `var'=. if `var'==0
	ren `var' chn_`var'
}

*save
sort iso3c ID_1 NAME_1 year
order iso3c  ID_1 NAME_1 year
rename ID_1 NAME_1, lower
saveold ./data/output/chn_aid_global_adm1.dta, replace


*** China: completed projects only
*load data
use ./data/output/chn_aid_gadm1.dta, clear // new with tranport coding

*minor adjustments
drop if year < 2000 | year > 2014
ren ad_sector_codes crs_sector

ren even_split_commitments usd_con
lab var usd_con "Value of the amount specified for the project (split per loc), constant 2014 USD"

ren ISO iso3c		

*gen oda / oof amounts 
gen usd_oda_con = usd_con if flow_class == "ODA-like"
gen usd_oof_con = usd_con if flow_class == "OOF-like" | flow_class == "Vague (Official Finance)"

*gen sector amounts
gen usd_soc_con=usd_con if crs_sector<200
gen usd_eco_con=usd_con if crs_sector>200 & crs_sector<300
gen usd_pro_con=usd_con if crs_sector>300 & crs_sector<400
gen usd_tra_con=usd_con if crs_sector==210
gen usd_ene_con=usd_con if crs_sector==230
gen usd_edu_con=usd_con if crs_sector==110
gen usd_hea_con=usd_con if crs_sector==120
gen usd_wat_con=usd_con if crs_sector==140
gen usd_non_con=usd_con if crs_sector==700 | crs_sector==420 | crs_sector==520 | crs_sector==920 | crs_sector==130 | crs_sector==510 | crs_sector==240
gen usd_lon_con=usd_con if transport_project_type=="urban railways and tram lines" | transport_project_type=="urban roads"
gen usd_roa_con=usd_con if transport_project_type=="urban roads" | transport_project_type=="long-distance roads"

* new 7/22 Baum-Snow's desired transport types
gen usd_ntr_con=usd_con if transport_project_type=="urban roads"
replace usd_ntr_con=usd_con if transport_project_type=="long-distance roads" | ///
	transport_project_type=="urban railways and tram lines" | transport_project_type=="long-distance railways" |  transport_project_type=="bridges"		

*gen spatial amounts
gen ones=1
bysort project_id: egen loc_count_mean=sum(ones)
bysort project_id ID_0 ID_1: egen loc_count_mean_adm1=sum(ones)
gen loc_count_max=loc_count_mean
gen loc_count_max_adm1=loc_count_mean_adm1

gen usd_nar_con=usd_con if loc_count_mean_adm1<2 & crs_sector==210
gen usd_bro_con=usd_con if loc_count_mean_adm1>=2 & crs_sector==210
gen usd_NAR_con=usd_con if loc_count_mean<2 & crs_sector==210
gen usd_BRO_con=usd_con if loc_count_mean>=2 & crs_sector==210

*prep status variable
drop if status == "Implementation"

*a dummy for chinese projects
gen project_count = 1
lab var project_count "Dummy takes value 1 if there is a Chinese project in that year and adm1 region."

*a dummy for ODA chinese projects
gen oda_project_count = 1 if flow_class == "ODA-like"
lab var oda_project_count "Dummy takes value 1 if there is a ODA Chinese project in that year and adm1 region."

*a dummy for OOF chinese projects
gen oof_project_count = 1 if flow_class == "OOF-like" | flow_class == "Vague (Official Finance)"
lab var oof_project_count "Dummy takes value 1 if there is a OOF Chinese project in that year and adm1 region."

*a dummy for chinese projects by sector
gen soc_project_count = 1 if crs_sector<200
lab var soc_project_count "Dummy takes value 1 if there is a social Chinese project in that year and adm1 region."
gen eco_project_count = 1 if crs_sector>200 & crs_sector<300
lab var eco_project_count "Dummy takes value 1 if there is a economic Chinese project in that year and adm1 region."
gen pro_project_count = 1 if crs_sector>300 & crs_sector<400
lab var pro_project_count "Dummy takes value 1 if there is a production Chinese project in that year and adm1 region."
gen tra_project_count = 1 if crs_sector==210
lab var tra_project_count "Dummy takes value 1 if there is a transport Chinese project in that year and adm1 region."
gen ene_project_count = 1 if crs_sector==230
lab var ene_project_count "Dummy takes value 1 if there is a energy Chinese project in that year and adm1 region."
gen edu_project_count = 1 if crs_sector==110
lab var edu_project_count "Dummy takes value 1 if there is a education Chinese project in that year and adm1 region."
gen hea_project_count = 1 if crs_sector==120
lab var hea_project_count "Dummy takes value 1 if there is a health Chinese project in that year and adm1 region."
gen wat_project_count = 1 if crs_sector==140
lab var wat_project_count "Dummy takes value 1 if there is a water Chinese project in that year and adm1 region."
gen non_project_count = 1 if crs_sector==700 | crs_sector==420 | crs_sector==520 | crs_sector==920 | crs_sector==130 | crs_sector==510 | crs_sector==240
lab var non_project_count "Dummy takes value 1 if there is a non-steel Chinese project in that year and adm1 region."
gen lon_project_count = 1 if transport_project_type=="urban railways and tram lines" | transport_project_type=="urban roads"
lab var lon_project_count "Dummy takes value 1 if there is a urban Chinese project in that year and adm1 region."
gen roa_project_count = 1 if transport_project_type=="urban roads" | transport_project_type=="long-distance roads"
lab var roa_project_count "Dummy takes value 1 if there is a road Chinese project in that year and adm1 region."	

* new project types 
gen ntr_project_count = 1 if transport_project_type=="urban roads" | transport_project_type=="long-distance roads" | ///
	transport_project_type=="urban railways and tram lines" | transport_project_type=="long-distance railways" |  transport_project_type=="bridges"
lab var ntr_project_count "Dummy takes value 1 if there is a Chinese road, bridge or rail project in that year and adm1 region."	


*a dummy for chinese projects by spatial location
gen nar_project_count = 1 if loc_count_mean_adm1<2 & crs_sector==210
lab var nar_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations adm1)"
gen bro_project_count = 1 if loc_count_mean_adm1>=2 & crs_sector==210
lab var bro_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations adm1)"
gen NAR_project_count = 1 if loc_count_mean<2 & crs_sector==210
lab var NAR_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations project)"
gen BRO_project_count = 1 if loc_count_mean>=2 & crs_sector==210
lab var BRO_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations project)"

sort iso3c ID_1 year, stable

*ren  ID_1 ID_1_str
*destring ID_1_str, gen(ID_1)
*drop ID_1_str


*collapse to ADM1/2 levels
collapse (first) NAME_1 (sum) usd_con project_count usd_oda_con oda_project_count usd_oof_con oof_project_count ///
	usd_soc_con soc_project_count usd_eco_con eco_project_count usd_pro_con pro_project_count ///
	usd_tra_con tra_project_count usd_ene_con ene_project_count usd_edu_con edu_project_count ///
	usd_hea_con hea_project_count usd_wat_con wat_project_count usd_non_con  usd_lon_con ///
	usd_roa_con usd_ntr_con non_project_count lon_project_count roa_project_count ntr_project_count ///
	usd_nar_con nar_project_count usd_bro_con bro_project_count usd_NAR_con NAR_project_count usd_BRO_con BRO_project_count ///
	(mean) loc_count_mean loc_count_mean_adm1 (max) loc_count_max loc_count_max_adm1, ///
	by(iso3c ID_1 year)

order iso3c NAME_* ID_*				

*label vars
lab var year "Year"
lab var iso3c "ISO3C country code"

lab var usd_con "Value of the amount specified for the project, constant 2014 USD"
lab var usd_oda_con "Value of the amount specified for the ODA project, constant 2014 USD"
lab var usd_oof_con "Value of the amount specified for the OOF project, constant 2014 USD"
lab var usd_soc_con "Value of the amount specified for the social project, constant 2014 USD"
lab var usd_eco_con "Value of the amount specified for the economic project, constant 2014 USD"
lab var usd_pro_con "Value of the amount specified for the production project, constant 2014 USD"
lab var usd_tra_con "Value of the amount specified for the transport project, constant 2014 USD"
lab var usd_ene_con "Value of the amount specified for the energy project, constant 2014 USD"
lab var usd_edu_con "Value of the amount specified for the education project, constant 2014 USD"
lab var usd_hea_con "Value of the amount specified for the health project, constant 2014 USD"
lab var usd_wat_con "Value of the amount specified for the water project, constant 2014 USD"
lab var usd_non_con "Value of the amount specified for the non-steel project, constant 2014 USD"
lab var usd_lon_con "Value of the amount specified for the urban project, constant 2014 USD"
lab var usd_roa_con "Value of the amount specified for the road project, constant 2014 USD"
lab var usd_nar_con "Value of the amount specified for narrowly dispersed projects, constant 2014 USD (#locations ADM1)"
lab var usd_bro_con "Value of the amount specified for broadly dispersed projects, constant 2014 USD (#locations ADM1)"
lab var usd_NAR_con "Value of the amount specified for narrowly dispersed projects, constant 2014 USD (#locations project)"
lab var usd_BRO_con "Value of the amount specified for broadly dispersed projects, constant 2014 USD (#locations project)"
lab var usd_ntr_con "Value of the amount specified for the road, bridge or rail project, constant 2014 USD"

lab var project_count "Count of Chinese aid project by adm1 and year"
lab var oda_project_count "Dummy takes value 1 if there is a ODA Chinese project in that year and adm1 region."
lab var oof_project_count "Dummy takes value 1 if there is a OOF Chinese project in that year and adm1 region."
lab var soc_project_count "Dummy takes value 1 if there is a social Chinese project in that year and adm1 region."
lab var eco_project_count "Dummy takes value 1 if there is a economic Chinese project in that year and adm1 region."
lab var pro_project_count "Dummy takes value 1 if there is a production Chinese project in that year and adm1 region."		
lab var tra_project_count "Dummy takes value 1 if there is a transport Chinese project in that year and adm1 region."
lab var ene_project_count "Dummy takes value 1 if there is a energy Chinese project in that year and adm1 region."	
lab var edu_project_count "Dummy takes value 1 if there is a education Chinese project in that year and adm1 region."	
lab var hea_project_count "Dummy takes value 1 if there is a health Chinese project in that year and adm1 region."	
lab var wat_project_count "Dummy takes value 1 if there is a water Chinese project in that year and adm1 region."	
lab var non_project_count "Dummy takes value 1 if there is a non-steel Chinese project in that year and adm1 region."
lab var lon_project_count "Dummy takes value 1 if there is a urban Chinese project in that year and adm1 region."
lab var roa_project_count "Dummy takes value 1 if there is a road Chinese project in that year and adm1 region."
lab var ntr_project_count "Dummy takes value 1 if there is a Chinese road, bridge or rail project in that year and adm1 region."	
lab var nar_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations adm1)"
lab var bro_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations adm1)"
lab var NAR_project_count "Dummy takes value 1 if there is a narrowly dispersed Chinese project in that year and adm1 region (#locations project)"
lab var BRO_project_count "Dummy takes value 1 if there is a broadly dispersed Chinese project in that year and adm1 region (#locations project)"

*keep what's needed
sort iso3c ID_1 NAME_1 year
order iso3c  ID_1 NAME_1 year

keep NAME_1 iso3c ID_1 year usd_con usd_oda_con usd_oof_con usd_soc_con usd_eco_con usd_pro_con usd_tra_con usd_ene_con usd_edu_con usd_hea_con usd_wat_con usd_non_con usd_lon_con usd_roa_con ///
	usd_ntr_con project_count oda_project_count oof_project_count soc_project_count eco_project_count pro_project_count tra_project_count ene_project_count edu_project_count hea_project_count ///
	non_project_count lon_project_count roa_project_count ntr_project_count ///
	usd_nar_con nar_project_count usd_bro_con bro_project_count usd_NAR_con NAR_project_count usd_BRO_con BRO_project_count ///
	loc_* 

foreach var of varlist usd_con-BRO_project_count {
	replace `var'=. if `var'==0
	ren `var' chn_comp_`var'
}


*save
sort iso3c ID_1 NAME_1 year
order iso3c  ID_1 NAME_1 year
rename ID_1 NAME_1, lower
saveold ./data/output/chn_aid_global_completedonly_adm1.dta, replace


*** World Bank

use ./data/intermediate/wb_aid_gadm1.dta, clear	

*minor adjustments
gen year = transactions_start_year
drop if year < 2000 | year > 2014
ren ad_sector_codes crs_sector_all

gen crs_sector = substr(crs_sector_all, 1, strpos(crs_sector_all, "|") - 1) 
tab crs_sector
destring crs_sector, replace
ren ad_sector_names crs_sector_name

ren even_split_commitments usd_con
lab var usd_con "Value of the amount specified for the project (split per loc), constant 2014 USD"

ren ISO iso3c		
ren ID_1 id_1
ren NAME_1 name_1

*gen sector amounts
gen usd_tra_con=usd_con if crs_sector==210

*a dummy for wb projects
gen project_count = 1 
lab var project_count "Dummy takes value 1 if there is a WB project in that year and adm`i' region."

gen tra_project_count = 1 if crs_sector==210
lab var tra_project_count "Dummy takes value 1 if there is a transport Chinese project in that year and adm1 region."

*"collapse" sums to ADM1/2 levels
foreach var of varlist usd_con project_count tra_project_count usd_tra_con {
	bysort iso3c id_1 year: egen n_`var' = total(`var'), missing
	replace `var' = n_`var' 
	drop n_`var'
}

bysort iso3c id_1 year: gen seq = _n
keep if seq == 1
drop seq

order iso3c id_1			

*label vars
lab var year "Year"
lab var iso3c "ISO3C country code"
lab var usd_con "Value of the disbursement amount specified for the project, constant 2014 USD"
lab var project_count "Count of WB aid project by adm1 and year"

*keep what's needed
sort iso3c id_1 name_1 year
order iso3c  id_1 name_1  year

keep name_1 iso3c id_1 year usd_con project_count  tra_project_count usd_tra_con


foreach var of varlist usd_con project_count usd_tra_con tra_project_count {
	ren `var' wb_`var'
}

*need D_wb_usd_tra_con2 D_wb_usd_con2
*wb_usd


*save
saveold ./data/intermediate/wb_aid_global_adm1.dta, replace	

*** all gadm centroids for table1 conley
import delimited ./data/input/gadm28_adm1_shp/gadm0_coords.csv, delimiter(comma) clear
saveold ./data/intermediate/gadm0_coords.dta, replace	

