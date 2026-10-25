********************************************************************************
*** Get instrustments ready
********************************************************************************

* new/redownloaded data lives here
mata: _mkdir("./data/intermediate/instruments/")

import delimited ./data/input/instruments/IPN3311A2RN.csv, delimiter(comma) bindquote(strict) varnames(1) clear
gen year = substr(date,1,4)
destring year, replace
drop date
ren ipn3311a2rn us_steel_indx
save ./data/intermediate/instruments/us_steel, replace 

* china imports TM.VAL.MRCH.KD.WB NE.IMP.GNFS.CN   
* TM.VAL.MMTL.ZS.UN DMGSRMRCHNSKD
wbopendata, indicator(DMGSRMRCHNSKD) country(chn) year(1995:2013) long clear
*Imports Merchandise, Customs, constant US$, millions
ren  dmgsrmrchnskd merchimports_constUS
li

save ./data/intermediate/instruments/china_imports, replace 

* china GDP at constant LCU
wbopendata, indicator(NY.GDP.MKTP.KN) country(chn) year(1995:2013) long clear

ren ny_gdp_mktp_kn gdp_const_lcu
save ./data/intermediate/instruments/china_gdp, replace 

* mhm can't get most data before 1998, but we would need 1997 for 2 yr lag + 1 yr lag

* STEEL in 10 000 tons
quandl using A0E0H0Z_A, quandlcode(NBSC/A0E0H0Z_A) ///
	auth($quandlkey) freq(annual) clear replace

drop if year < 1998 
drop if year > 2013

*Source: http://www.stats.gov.cn/english/statisticaldata/yearlydata/YB1999e/m12e.htm
moreobs 3
replace year=1995 if _n==17
replace year=1996 if _n==18
replace year=1997 if _n==19

replace value=9535.99 if _n==17
replace value=10124.06 if _n==18
replace value=10894.17 if _n==19
*11559.00

rename value steel

save ./data/intermediate/instruments/A0E0H0Z_A, replace

* CEMENT in 10 000 tons
quandl using A0E0H0W_A, quandlcode(NBSC/A0E0H0W_A) freq(annual) clear replace
*quandl using A02080Q02_M, quandlcode(NBSC/A02080Q02_M) freq(annual) clear replace

drop if year < 1998 
drop if year > 2013

*Source: http://www.stats.gov.cn/english/statisticaldata/yearlydata/YB1999e/m12e.htm
moreobs 3
replace year=1995 if _n==17
replace year=1996 if _n==18
replace year=1997 if _n==19

replace value=47560.59 if _n==17
replace value=49118.90 if _n==18
replace value=51173.80 if _n==19
*53600.00

rename value cement
drop date
sort year
save ./data/intermediate/instruments/A0E0H0W_A, replace


* PIG IRON
quandl using A0E0H0Y_A, quandlcode(NBSC/A0E0H0Y_A) freq(annual) clear replace
drop if year < 1998
drop if year > 2013


*Source: http://www.stats.gov.cn/english/statisticaldata/yearlydata/YB1999e/m12e.htm
moreobs 3
replace year=1995 if _n==17
replace year=1996 if _n==18
replace year=1997 if _n==19

replace value=10529.27 if _n==17
replace value=10722.50 if _n==18
replace value=11511.41 if _n==19
*11863.67

rename value iron
drop date
sort year

save ./data/intermediate/instruments/A0E0H0Y_A, replace

* TIMBER in 10 000 cu.m
quandl using A0D0N01_A, quandlcode(NBSC/A0D0N01_A) freq(annual) clear replace

drop if year < 1998 
drop if year > 2013

*Source: http://www.stats.gov.cn/english/statisticaldata/yearlydata/YB1999e/m12e.htm
moreobs 3
replace year=1995 if _n==17
replace year=1996 if _n==18
replace year=1997 if _n==19

replace value=6766.86 if _n==17
replace value=6710.27 if _n==18
replace value=6394.79 if _n==19
*5966.20
*Only very minor deviation in 1998 value

rename value timber
drop date
sort year

save ./data/intermediate/instruments/A0D0N01_A, replace


* GLASS
quandl using A02080R02_M, quandlcode(NBSC/A02080R02_M) freq(annual) clear replace

drop if year < 1998 
drop if year > 2013

*Source: http://www.stats.gov.cn/english/statisticaldata/yearlydata/YB1999e/m12e.htm
moreobs 3
replace year=1995 if _n==17
replace year=1996 if _n==18
replace year=1997 if _n==19

replace value=15731.71 if _n==17
replace value=16069.37 if _n==18
replace value=16630.70 if _n==19
*17194.03

rename value glass
drop date
sort year

save ./data/intermediate/instruments/A02080R02_M, replace


*ALUMINUM

use ./data/input/instruments/usgs_alu, replace

* Convert into 10,000 tons
replace alu=alu/10
rename alu aluminum
drop if year < 1995
drop if year > 2013
save ./data/intermediate/instruments/alu, replace


*MERGE ALL
cd ./data/intermediate/instruments/

use A0E0H0Z_A, clear
merge 1:1 year using A0E0H0W_A
drop _merge
merge 1:1 year using A0E0H0Y_A
drop _merge
merge 1:1 year using A0D0N01_A
drop _merge
merge 1:1 year using A02080R02_M
drop _merge
merge 1:1 year using alu
drop _merge

merge 1:1 year using china_gdp
drop _merge
merge 1:1 year using china_imports
drop _merge
merge 1:1 year using us_steel
drop _merge
tsset year


* get logs
local allinputs steel cement iron timber glass aluminum

foreach x of varlist `allinputs' {
	gen ln_`x' = log(`x')
	label var ln_`x' "`x'"
}

foreach x of varlist `allinputs' {
	gen d_ln_`x' = d.ln_`x'
	label var d_ln_`x' "`x'"
}

gen ln_gdp_const_lcu = ln(gdp_const_lcu)

* subtract growth
foreach x of varlist `allinputs' {
	reg ln_`x' ln_gdp_const_lcu
	predict over1_ln_`x', res
	label var over1_ln_`x' "`x'"
}

* detrend
foreach x of varlist `allinputs' {
	reg ln_`x' year
	predict det_ln_`x', res
	label var det_ln_`x' "`x'"
}

* strongly corr'd
corr steel-aluminum


* hp filtered series
foreach x of varlist `allinputs' {
tsfilter hp hp_`x' = ln_`x', smooth(6.25)

}

* extract first factor
factor hp_steel-hp_aluminum 
predict hp_factor1, rotate

* extract first factor
factor over1_ln_* 
predict over_factor1 over_factor2, rotate

* extract first factor

* detrended
factor det_ln_steel-det_ln_aluminum
predict factor1 factor2, rotate

* levels
factor ln_steel-ln_aluminum
predict factor1_levs factor2_levs, rotate

* hp filtered
tsfilter hp althp_factor1_levs = factor1_levs, smooth(6.25)


drop date
cd ./../../../
save ./data/output/final_instruments, replace
