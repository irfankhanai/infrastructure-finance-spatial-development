********************************************************************************
*** Merge data sets and create additional variables
********************************************************************************

* Open Chinese aid data
use ./data/output/chn_aid_global_adm1, clear
drop if iso3c=="CHN"
drop name_1 
compress

* Merge spatial inequality measures
merge 1:1 iso3c id_1 year using ./data/intermediate/within_gadm1.dta

* unmatched from master are only from extra year
tab _merge if year == 2014
drop if _merge==1
drop _merge

* Merge completed Chinese only data
merge 1:1 iso3c id_1 year using ./data/output/chn_aid_global_completedonly_adm1.dta
drop if _merge==2
drop _merge

* Merge in WB data (new version, old was in sf wb_projects)
merge 1:1 iso3c id_1 year using ./data/intermediate/wb_aid_global_adm1.dta
* alternative
*merge 1:1 iso3c id_1 year using ./spatial_ineq/wb_projects/wb_aid_global_adm1_ACTIVE.dta
drop if _merge==2

* set project vars to zero if there are no projects in ADM1 region
replace wb_project_count = 0 if _merge==1 & (year > 1999 & year < 2015)

foreach x in usd_con project_count usd_tra_con  tra_project_count /* usd_soc_con usd_eco_con usd_pro_con usd_tra_con usd_ene_con usd_edu_con usd_hea_con usd_wat_con soc_project_count eco_project_count pro_project_count tra_project_count ene_project_count edu_project_count hea_project_count wat_project_count */ {
replace wb_`x' = 0 if _merge==1 & (year > 1999 & year < 2015)
replace wb_`x' = 0 if wb_project_count!=. & wb_`x' == . & (year > 1999 & year < 2015)
}
gen wb_project_dum = (wb_project_count > 0) if (year > 1999 & year < 2015)

foreach var in tra /* soc eco pro  ene edu hea wat */ {
gen wb_`var'_project_dum = (wb_`var'_project_count > 0) if (year > 1999 & year < 2015)
}
drop _merge
sum wb_*

* Merge Chinese FDI data
merge m:1 year using  ./data/intermediate/fdiCHN_UNCTAD.dta, keep(1 3)
drop _merge

/*
* Merge country-year and time-series control variables
merge m:1 iso3c year using ./data/intermediate/controls.dta

tab iso3c if _merge==1 
drop if _merge==2 /* 1990, 1991, 2014, 2015, 2016 and countries/regions not in our geo-dataset */
drop _merge
*/
***** IF WB_INC is from growth paper it needs to go into raw/input

* Merge World Bank Income Classification
merge n:1 iso3c year using ./data/intermediate/wb_inc.dta, keep(1 3) /* Taken from growth paper */
tab iso3c if _merge==1 & year>=2000
drop _merge

*************************************************************************************************
* MERGE IN BETWEEN 2 IN ADM 1
*************************************************************************************************

*merge 1:1 iso3c id_1 year using ./data/intermediate/allginis/between_gadm2_in_adm1
*drop _merge

*************************************************************************************************
* Construct Variables
*************************************************************************************************

* Generate logged values

foreach VAR in chn_usd_con chn_usd_oda_con chn_usd_oof_con chn_usd_soc_con chn_usd_eco_con chn_usd_pro_con chn_usd_tra_con chn_usd_ene_con chn_usd_edu_con chn_usd_hea_con chn_usd_wat_con chn_usd_non_con chn_usd_lon_con chn_usd_roa_con chn_usd_ntr_con chn_usd_nar_con chn_usd_bro_con chn_usd_NAR_con chn_usd_BRO_con ///
				chn_comp_usd_con chn_comp_usd_oda_con chn_comp_usd_oof_con chn_comp_usd_soc_con chn_comp_usd_eco_con chn_comp_usd_pro_con chn_comp_usd_tra_con chn_comp_usd_ene_con chn_comp_usd_edu_con chn_comp_usd_hea_con chn_comp_usd_wat_con chn_comp_usd_non_con chn_comp_usd_nar_con chn_comp_usd_bro_con chn_comp_usd_NAR_con chn_comp_usd_BRO_con ///
				wb_usd_con wb_usd_tra_con {
	clonevar `VAR'_ln=`VAR'
	replace `VAR'_ln=ln(`VAR'+1)
}

* Replace Chinese and WB aid data to be zero if missing 

foreach VAR in chn_usd_con chn_usd_oda_con chn_usd_oof_con chn_usd_soc_con chn_usd_eco_con chn_usd_pro_con chn_usd_tra_con chn_usd_ene_con chn_usd_edu_con chn_usd_hea_con chn_usd_wat_con chn_usd_non_con chn_usd_lon_con chn_usd_roa_con chn_usd_ntr_con ///
	chn_usd_con_ln chn_usd_oda_con_ln chn_usd_oof_con_ln chn_usd_soc_con_ln chn_usd_eco_con_ln chn_usd_pro_con_ln chn_usd_tra_con_ln chn_usd_ene_con_ln chn_usd_edu_con_ln chn_usd_hea_con_ln chn_usd_wat_con_ln chn_usd_non_con_ln chn_usd_lon_con_ln chn_usd_roa_con_ln chn_usd_ntr_con_ln ///
	chn_project_count chn_oda_project_count chn_oof_project_count chn_soc_project_count chn_eco_project_count chn_pro_project_count chn_tra_project_count chn_ene_project_count chn_edu_project_count chn_hea_project_count chn_wat_project_count chn_non_project_count chn_lon_project_count chn_roa_project_count chn_ntr_project_count ///
	chn_usd_nar_con_ln chn_usd_bro_con_ln chn_usd_NAR_con_ln chn_usd_BRO_con_ln chn_nar_project_count chn_bro_project_count chn_NAR_project_count chn_BRO_project_count ///
	chn_usd_con_ln chn_usd_oda_con_ln chn_usd_oof_con_ln chn_usd_soc_con_ln chn_usd_eco_con_ln chn_usd_pro_con_ln chn_usd_tra_con_ln chn_usd_ene_con_ln chn_usd_edu_con_ln chn_usd_hea_con_ln chn_usd_wat_con_ln chn_usd_non_con_ln chn_usd_lon_con_ln chn_usd_roa_con_ln chn_usd_ntr_con_ln ///
	chn_comp_project_count chn_comp_oda_project_count chn_comp_oof_project_count chn_comp_soc_project_count chn_comp_eco_project_count chn_comp_pro_project_count chn_comp_tra_project_count chn_comp_ene_project_count chn_comp_edu_project_count chn_comp_hea_project_count  chn_comp_non_project_count ///
	chn_comp_usd_nar_con_ln chn_comp_usd_bro_con_ln chn_comp_usd_NAR_con_ln chn_comp_usd_BRO_con_ln chn_comp_nar_project_count chn_comp_bro_project_count chn_comp_NAR_project_count chn_comp_BRO_project_count { 
	replace `VAR'= 0 if missing(`VAR') 
}

* Replace Chinese and WB aid data to be missing before 2000 and after 2014
foreach VAR in chn_usd_oda_con chn_usd_oof_con chn_usd_soc_con chn_usd_eco_con chn_usd_pro_con chn_usd_tra_con chn_usd_ene_con chn_usd_edu_con chn_usd_hea_con chn_usd_wat_con chn_usd_non_con chn_usd_lon_con chn_usd_roa_con chn_usd_ntr_con ///
	chn_usd_con_ln chn_usd_oda_con_ln chn_usd_oof_con_ln chn_usd_soc_con_ln chn_usd_eco_con_ln chn_usd_pro_con_ln chn_usd_tra_con_ln chn_usd_ene_con_ln chn_usd_edu_con_ln chn_usd_hea_con_ln chn_usd_wat_con_ln chn_usd_non_con_ln chn_usd_lon_con_ln chn_usd_roa_con_ln chn_usd_ntr_con_ln ///
	chn_project_count chn_oda_project_count chn_oof_project_count chn_soc_project_count chn_eco_project_count chn_pro_project_count chn_tra_project_count chn_ene_project_count chn_edu_project_count chn_hea_project_count chn_wat_project_count chn_non_project_count chn_lon_project_count chn_roa_project_count chn_ntr_project_count ///
	chn_usd_nar_con_ln chn_usd_bro_con_ln chn_usd_NAR_con_ln chn_usd_BRO_con_ln chn_nar_project_count chn_bro_project_count chn_NAR_project_count chn_BRO_project_count ///
	chn_comp_project_count chn_comp_oda_project_count chn_comp_oof_project_count chn_comp_soc_project_count chn_comp_eco_project_count chn_comp_pro_project_count chn_comp_tra_project_count chn_comp_ene_project_count chn_comp_edu_project_count chn_comp_hea_project_count  chn_comp_non_project_count ///
	chn_comp_usd_nar_con_ln chn_comp_usd_bro_con_ln chn_comp_usd_NAR_con_ln chn_comp_usd_BRO_con_ln chn_comp_nar_project_count chn_comp_bro_project_count chn_comp_NAR_project_count chn_comp_BRO_project_count { 
	
      replace `VAR'=. if year>2014
	  replace `VAR'=. if year<2000
  }

ren chn_project_count chn_all_project_count
foreach var in all tra eco lon roa ntr soc pro ene /* oda oof soc eco pro tra ene edu hea wat non lon roa ntr nar bro NAR BRO */ {
gen D_OFn_`var' = 0
replace D_OFn_`var' = (chn_`var'_project_count>0) if !missing(chn_`var'_project_count)
replace D_OFn_`var' = . if missing(chn_`var'_project_count)
label var D_OFn_`var' "Chinese `var' project, dummy based on number"
}
*ren chn_all_project_count chn_project_count


* Same for completed projects
ren chn_comp_project_count chn_comp_all_project_count
foreach var in all tra /* oda oof soc eco pro tra ene edu hea non nar bro NAR BRO */ {
gen D_OFn_comp_`var' = 0
replace D_OFn_comp_`var' = (chn_comp_`var'_project_count>0) if !missing(chn_comp_`var'_project_count)
replace D_OFn_comp_`var' = . if missing(chn_comp_`var'_project_count)
label var D_OFn_comp_`var' "Chinese `var' project, dummy based on number completed"
}
*ren chn_comp_all_project_count chn_comp_project_count


gen ln_pop = ln(sum_pop) // kills unpopulated places, probably good
label var ln_pop "Log population size"

/*
* Calculate constant 2010 values for World Bank and UNCTAD data
foreach VAR in fdiCHN_UNCTAD {

gen double tmp1 = (`VAR'_cur/deflators_dac)*100  /* convert to constant 2015 US$ using DAC deflator for all donors*/
/* convert base year to 2010 (https://datahelpdesk.worldbank.org/knowledgebase/articles/114946-how-can-i-rescale-a-series-to-a-different-base-yea) */
gen double tmp2 = tmp1 if year==2010 /* keep new base year only */
bysort iso3c: egen double tmp3=mean(tmp2)
gen double tmp4 = tmp1/tmp3
gen double tmp5 = `VAR'_cur if year==2010 /* calculate current US$ value for base year 2010 */
bysort iso3c: egen double tmp6=mean(tmp5)
gen double `VAR'_con=tmp4*tmp6
replace `VAR'_con=0 if `VAR'_cur==0
drop tmp*
 }

*label var exportsCHN_con "Chinese exports (constant 2010 US$)"
label var fdiCHN_UNTAD_con "Chinese FDI (UNCTAD), outflows, millions constant 2010 US$"
label var fdiCHN_st_UNTAD_con "Chinese FDI (UNCTAD), outward stocks, millions constant 2010 US$"

*/
*************************************************************************************************
* Construct Steel Instrument
*************************************************************************************************

*Chinese official finance instrument based on ALL project numbers
egen sum1 = max(D_OFn_all), by(year) /* creates dummy for years with any Chinese aid */
egen sum_years = total(sum1), by(iso3c id_1) /* total number of years with positive Chinese aid*/

*gen steel_ln=ln(chinese_steel)

foreach var in all tra eco lon roa ntr /*oda oof soc eco pro  ene edu hea non lon roa ntr nar bro NAR BRO */ {
egen sum2 = total(D_OFn_`var'), by(iso3c id_1)
gen probaid_PRC_OFn_`var' = sum2 / sum_years
drop sum2 

*gen steel_OFn_`var'_ln = steel_ln * probaid_PRC_OFn_`var'
}

egen sum2 = total(D_OFn_tra), by(iso3c id_1)

bys iso3c id_1 (year): gen sum_rolling =  sum(D_OFn_tra)
bys iso3c id_1 (year): gen sum_rolling_years =  sum(sum1)
gen probaid_PRC_OFn_tra_roll = sum_rolling/sum_rolling_years

sum sum_year sum2 sum_rolling sum_rolling_years

gen probaid_PRC_OFn_tra_jive = (sum2 - D_OFn_tra)/sum_years
xtset

gen probaid_PRC_OFn_tra_jive3 = (sum2 - D_OFn_tra - F.D_OFn_tra  - F1.D_OFn_tra  - F2.D_OFn_tra  - F3.D_OFn_tra)/sum_years

drop sum2 

egen sum2 = total(D_OFn_all), by(iso3c id_1)

egen sum3 = total(D_OFn_tra), by(iso3c id_1)

gen probaid_PRC_OFn_all_net_of_tra = (sum2-sum3)/sum_years

*drop sum3

*egen sum3 = total(D_OFn_ntr), by(iso3c id_1)

*gen probaid_PRC_OFn_all_net_of_ntr = (sum2-sum3)/sum_years

*gen probaid_PRC_OFn_ntr_jive = (sum3 - D_OFn_ntr)/sum_years


drop sum1 sum2 sum3 sum_years

/*
*************************************************************************************************
* Construct Trend Control
*************************************************************************************************

cap drop trend
gen trend=year-2000

foreach var in all oda oof soc eco pro tra ene edu hea non lon roa ntr nar bro NAR BRO {
gen t_OFn_`var' = trend * probaid_PRC_OFn_`var' /* interact trend with probability to receive `var' number */
}

*************************************************************************************************
* FDI and Trade controls interactions
*************************************************************************************************

foreach var in all oda oof soc eco pro tra ene edu hea non lon roa ntr nar bro NAR BRO {
*gen exports_OFn_`var'_ln = ln(exportsCHN_con) * probaid_PRC_OFn_`var'
gen fdiCHN_UNTAD_OFn_`var'_ln = ln(fdiCHN_UNTAD_con) * probaid_PRC_OFn_`var'
gen fdiCHN_st_UNTAD_OFn_`var'_ln = ln(fdiCHN_st_UNTAD_con) * probaid_PRC_OFn_`var'
gen exp_fob_con_`var'_ln = ln(exp_fob_con) * probaid_PRC_OFn_`var'
}

*/
*************************************************************************************************
* Construct Lagged Variables
*************************************************************************************************

xtset pid year

* Generate lagged values
foreach VAR in chn_usd_con chn_usd_tra_con  chn_usd_lon_con chn_usd_roa_con chn_usd_ntr_con  wb_usd_con wb_usd_tra_con {
/*					
foreach VAR in chn_usd_con chn_usd_oda_con chn_usd_oof_con chn_usd_soc_con chn_usd_eco_con chn_usd_pro_con chn_usd_tra_con chn_usd_ene_con chn_usd_edu_con chn_usd_hea_con chn_usd_wat_con chn_usd_non_con chn_usd_lon_con chn_usd_roa_con chn_usd_ntr_con chn_usd_nar_con chn_usd_bro_con chn_usd_NAR_con chn_usd_BRO_con ///
				wb_usd_con wb_usd_tra_con /* wb_usd_soc_con wb_usd_eco_con wb_usd_pro_con wb_usd_tra_con	wb_usd_ene_con wb_usd_edu_con wb_usd_hea_con wb_usd_wat_con*/ {
*/
 	clonevar `VAR'1=`VAR'
	  clonevar `VAR'2=`VAR'
	  clonevar `VAR'3=`VAR'
	  clonevar `VAR'4=`VAR'
	  clonevar `VAR'5=`VAR'
	  clonevar `VAR'6=`VAR'
	  clonevar `VAR'7=`VAR'
      clonevar `VAR'_ln1=`VAR'_ln
	  clonevar `VAR'_ln2=`VAR'_ln
	  clonevar `VAR'_ln3=`VAR'_ln
	  clonevar `VAR'_ln4=`VAR'_ln
	  clonevar `VAR'_ln5=`VAR'_ln
	  clonevar `VAR'_ln6=`VAR'_ln
	  clonevar `VAR'_ln7=`VAR'_ln
	  
	  replace `VAR'1=l.`VAR'
	  replace `VAR'2=l2.`VAR'
	  replace `VAR'3=l3.`VAR'
	  replace `VAR'4=l4.`VAR'
	  replace `VAR'5=l5.`VAR'
	  replace `VAR'6=l6.`VAR'
	  replace `VAR'7=l7.`VAR'
	  
      replace `VAR'_ln1=l.`VAR'_ln
	  replace `VAR'_ln2=l2.`VAR'_ln
	  replace `VAR'_ln3=l3.`VAR'_ln
	  replace `VAR'_ln4=l4.`VAR'_ln
	  replace `VAR'_ln5=l5.`VAR'_ln
	  replace `VAR'_ln4=l6.`VAR'_ln
	  replace `VAR'_ln5=l7.`VAR'_ln
  }
  
  * Why on earth do we have exports and FDI for each Chinese transport project category?
  
  /*
foreach VAR in steel_OFn_all_ln steel_OFn_oda_ln steel_OFn_oof_ln steel_OFn_soc_ln steel_OFn_eco_ln steel_OFn_pro_ln steel_OFn_tra_ln steel_OFn_ene_ln steel_OFn_edu_ln steel_OFn_hea_ln steel_OFn_non_ln steel_OFn_lon_ln steel_OFn_roa_ln steel_OFn_ntr_ln ///
	chn_comp_usd_con chn_comp_usd_oda_con chn_comp_usd_oof_con chn_comp_usd_soc_con chn_comp_usd_eco_con chn_comp_usd_pro_con chn_comp_usd_tra_con chn_comp_usd_ene_con chn_comp_usd_edu_con chn_comp_usd_hea_con chn_comp_usd_wat_con chn_comp_usd_non_con chn_comp_usd_nar_con chn_comp_usd_bro_con chn_comp_usd_NAR_con chn_comp_usd_BRO_con ///
	steel_OFn_nar_ln steel_OFn_NAR_ln steel_OFn_bro_ln steel_OFn_BRO_ln ///
	ida_c_probaid_WB ibrd_c_probaid_WB ida_d_probaid_WB ibrd_d_probaid_WB ida_c_ln_probaid_WB ibrd_c_ln_probaid_WB ida_d_ln_probaid_WB ibrd_d_ln_probaid_WB  ///
	wb_c_ln_probaid_WB wb_d_ln_probaid_WB wb_c_probaid_WB wb_d_probaid_WB ///
	fdiCHN_UNTAD_OFn_all_ln exp_fob_con_all_ln fdiCHN_UNTAD_OFn_oda_ln exp_fob_con_oda_ln fdiCHN_UNTAD_OFn_oof_ln exp_fob_con_oof_ln fdiCHN_UNTAD_OFn_soc_ln exp_fob_con_soc_ln fdiCHN_UNTAD_OFn_eco_ln exp_fob_con_eco_ln fdiCHN_UNTAD_OFn_pro_ln exp_fob_con_pro_ln fdiCHN_UNTAD_OFn_tra_ln exp_fob_con_tra_ln fdiCHN_UNTAD_OFn_ene_ln fdiCHN_UNTAD_OFn_edu_ln fdiCHN_UNTAD_OFn_hea_ln  fdiCHN_UNTAD_OFn_non_ln fdiCHN_UNTAD_OFn_lon_ln fdiCHN_UNTAD_OFn_roa_ln fdiCHN_UNTAD_OFn_ntr_ln exp_fob_con_ene_ln exp_fob_con_edu_ln exp_fob_con_hea_ln  exp_fob_con_non_ln exp_fob_con_lon_ln exp_fob_con_roa_ln exp_fob_con_ntr_ln fdiCHN_UNTAD_OFn_nar_ln exp_fob_con_nar_ln fdiCHN_UNTAD_OFn_NAR_ln exp_fob_con_NAR_ln fdiCHN_UNTAD_OFn_bro_ln exp_fob_con_bro_ln fdiCHN_UNTAD_OFn_BRO_ln exp_fob_con_BRO_ln  ///
	aw_gini_sqkm  pw_gini_pc pw_gini_sl ln_pop wb_project_dum wb_project_count ida_fpos_probaid_WB ibrd_rat_probaid_WB ibrd_rat_probaid_WB_tra /* ibrd_rat_probaid_WB_soc ibrd_rat_probaid_WB_eco ibrd_rat_probaid_WB_pro  ibrd_rat_probaid_WB_ene ibrd_rat_probaid_WB_edu ibrd_rat_probaid_WB_hea ibrd_rat_probaid_WB_wat */   ///
	 wb_tra_project_dum wb_tra_project_count /// /* wb_soc_project_dum wb_soc_project_count wb_eco_project_dum wb_eco_project_count wb_pro_project_dum wb_pro_project_count wb_tra_project_dum wb_tra_project_count wb_ene_project_dum wb_ene_project_count wb_edu_project_dum wb_edu_project_count wb_hea_project_dum wb_hea_project_count wb_wat_project_dum wb_wat_project_count */
	D_OFn_all D_OFn_oda D_OFn_oof D_OFn_soc D_OFn_eco D_OFn_pro D_OFn_tra D_OFn_ene D_OFn_edu D_OFn_hea  D_OFn_non D_OFn_lon D_OFn_roa D_OFn_ntr D_OFn_nar D_OFn_NAR D_OFn_bro D_OFn_BRO ///
	D_OFn_comp_all D_OFn_comp_oda D_OFn_comp_oof D_OFn_comp_soc D_OFn_comp_eco D_OFn_comp_pro D_OFn_comp_tra D_OFn_comp_ene D_OFn_comp_edu D_OFn_comp_hea D_OFn_comp_non D_OFn_comp_nar D_OFn_comp_NAR D_OFn_comp_bro D_OFn_comp_BRO ///
	chn_all_project_count chn_oda_project_count chn_oof_project_count chn_soc_project_count chn_eco_project_count chn_pro_project_count chn_tra_project_count chn_ene_project_count chn_edu_project_count chn_hea_project_count chn_wat_project_count chn_non_project_count chn_lon_project_count chn_roa_project_count chn_ntr_project_count chn_nar_project_count chn_bro_project_count chn_NAR_project_count chn_BRO_project_count {
		
		*/
foreach VAR in D_OFn_all D_OFn_tra D_OFn_eco D_OFn_lon D_OFn_roa D_OFn_ntr D_OFn_soc D_OFn_pro D_OFn_ene D_OFn_comp_all D_OFn_comp_tra chn_all_project_count chn_tra_project_count chn_eco_project_count chn_lon_project_count  chn_roa_project_count chn_ntr_project_count chn_comp_usd_con chn_comp_usd_tra_con      {
      clonevar `VAR'1=`VAR'
	  clonevar `VAR'2=`VAR'
	  clonevar `VAR'3=`VAR'
	  clonevar `VAR'4=`VAR'
	  clonevar `VAR'5=`VAR'
	  clonevar `VAR'6=`VAR'
	  
      replace `VAR'1=l.`VAR'
	  replace `VAR'2=l2.`VAR'
	  replace `VAR'3=l3.`VAR'
	  replace `VAR'4=l4.`VAR'
	  replace `VAR'5=l5.`VAR'
	  replace `VAR'6=l6.`VAR'
  }

encode iso3c, gen(cid)

* country year effects 
egen cy = group(iso3c year)

*************************************************************************************************
* Construct New Factor based IVs
*************************************************************************************************

merge m:1 year using ./data/output/final_instruments, /// 
keepusing(factor1_levs factor1 factor2 over_factor1 hp_factor1 althp_factor1_levs merchimports_constUS us_steel_indx det_ln_*)

*merge m:1 year using ./data/intermediate/quandl/test_instruments, /// 
keepusing(factor1_levs factor1 factor2 over_factor1 hp_factor1 althp_factor1_levs merchimports_constUS us_steel_indx det_ln_*)
drop _merge

xtset

* use factor1_levs for base, added alternatives
foreach var in all tra eco lon roa ntr /* oda oof soc eco pro tra ene edu hea non lon roa ntr nar bro NAR BRO */ {
	gen factorIV_`var' = factor1_levs * probaid_PRC_OFn_`var'
	gen detrendIV_`var' = factor1 * probaid_PRC_OFn_`var'
	gen overIV_`var' = over_factor1 * probaid_PRC_OFn_`var'
	gen hpIV_`var' = hp_factor1 * probaid_PRC_OFn_`var'
	gen althpIV_`var' = althp_factor1_levs * probaid_PRC_OFn_`var'

}

foreach var in all tra eco lon roa ntr /* oda oof soc eco pro tra ene edu hea wat non lon roa ntr nar bro NAR BRO */ {
ren chn_`var'_project_count OFn_`var'
ren chn_`var'_project_count1 OFn_`var'1
ren chn_`var'_project_count2 OFn_`var'2
ren chn_`var'_project_count3 OFn_`var'3
ren chn_`var'_project_count4 OFn_`var'4
ren chn_`var'_project_count5 OFn_`var'5
ren chn_`var'_project_count6 OFn_`var'6
}


* light density for growth regressions
gen ln_aw_mean_sqkm =  ln(aw_mean_sqkm + 0.01)

* should be controlling for density everywhere
gen ln_popdens = ln(sum_pop/land_area + 0.01)

* rename
ren chn_usd_con chn_usd_all_con
ren chn_usd_con_ln chn_usd_all_con_ln

forvalues i=2/3 {
ren chn_usd_con`i' chn_usd_all_con`i'
}


* get regions
kountry iso3c , from(iso3c) geo(un) marker
* only islands and montenegro not matched
tab iso3c if GEO==""

tab GEO D_OFn_all


*** THIS SHOULD BE REPLACED BY OUR USUAL WDI CRITERION FROM THE TABLE FILES

keep if wb_inc~="H" /* drops High Income Countries according to the World Bank's classification */
drop if iso3c=="PSE" /* exclude Palestine */

* Exclude "countries" that have not been in the masterfile - due to replacing missing with zeroes they will otherwise be included in the OLS regressions, but not 2SLS
drop if iso3c=="ALA" | iso3c=="ATF" | iso3c=="BES" | iso3c=="ESH" | iso3c=="GGY" | iso3c=="JEY" | iso3c=="SHN" | iso3c=="SPM"  ///
	| iso3c=="TKL" | iso3c=="TWN" | iso3c=="XAD" | iso3c=="XKO" | iso3c=="XNC" 

	
*** add this to merges
**********************************************************************************

*** merge exports 
merge m:1 iso3c year  using ./data/intermediate/TXG_FOB_USD_panel_1995_2013
* merge == 2 are developed countries. already gone.
drop if _merge==2
drop _merge

*** merge imports )
merge m:1 iso3c year  using ./data/intermediate/TMG_CIF_USD_panel_1995_2013
* merge == 2 are developed countries. already gone.
drop if _merge==2
drop _merge

*** merge in xsection with lat lon
merge m:1 iso3c id_1  using ./data/intermediate/all_xsectionvars_GADM1, update replace
drop _merge


drop if year == .
**** get new Ginis with 0s
merge 1:1 iso3c id_1 year using  ./data/intermediate/within_gadm1.dta, update replace
drop _merge

*** remove tiny countries in 2000
merge m:1 iso3c using ./data/intermediate/wdi.dta, keep(3)
drop _merge

* No WDI data for GLP, GUF, MTQ, REU and WLF
drop if wdi_pop < 1000000
xtset

* bartke
merge m:1 iso3c id_1 using ./data/intermediate/cw_probs_ADM1.dta
replace cw_prob = 0 if missing(cw_prob) & GEO == "Africa"
replace cw_prob_tra = 0 if missing(cw_prob_tra) & GEO == "Africa"
drop _merge
drop if year == .

merge m:1 iso3c using ./data/intermediate/inc_levs_wb_2000.dta, keep(3) 
drop _merge

merge m:1 iso3c id_1 using ./data/intermediate/onshore_petroleum_ADM1.dta
drop if _merge==2
drop _merge

* legacy steel series is used, FRED updated this in the BG, qual. results the same
merge m:1 year  using ./data/output/us_steel_cons_avg, update replace
//merge m:1 year  using ./data/intermediate/instruments/us_steel_cons_avg, update replace
drop _merge


xtset

* needed for conley
gen l3_detrendIV_tra =  l3.detrendIV_tra
gen l3_detrendIV_all =  l3.detrendIV_all
gen l3_detrendIV_lon =  l3.detrendIV_lon
gen l3_detrendIV_roa =  l3.detrendIV_roa
gen l3_detrendIV_ntr =  l3.detrendIV_ntr
gen d_aw_gini0_sqkm = d.aw_gini0_sqkm
drop if pid==.
drop if lat ==. 

**********************************************************************************
		
save ./data/output/chnineq_reg_ADM1.dta, replace

