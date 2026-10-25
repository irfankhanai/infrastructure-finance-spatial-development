* clean slate
clear all

* load data
use ./data/output/chnineq_reg_ADM1.dta, clear

** COLUMN 1: WITHIN ADM1

** OLS
disp "1 tra aw_gini0_sqkm"
reghdfe d.aw_gini0_sqkm D_OFn_tra2 if iso3c!="CHN" & !missing(l3.detrendIV_tra), ///
	absorb(pid cy) vce(cluster cid) 
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf1.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(D_OFn_tra2) asterisk(se)  ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
	
** ac reg with conley
acreg d_aw_gini0_sqkm D_OFn_tra2 if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf1_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(D_OFn_tra2) bracket asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
drop esample

** reduced form
disp "2 tra aw_gini0_sqkm"
reghdfe d.aw_gini0_sqkm l3.detrendIV_tra if iso3c!="CHN" & !missing(D_OFn_tra2), /// 
	absorb(pid cy) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf2.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
	
** ac reg with conley
acreg d_aw_gini0_sqkm l3_detrendIV_tra if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf2_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
drop esample

**2SLS
disp "3 tra aw_gini0_sqkm"
ivreghdfe d.aw_gini0_sqkm (D_OFn_tra2 = l3.detrendIV_tra) if iso3c!="CHN", /// 
	absorb(pid cy) cluster(cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf3.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf)  policy(D_OFn_tra2) asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
	
** ac reg with conley
acreg d_aw_gini0_sqkm (D_OFn_tra2 = l3_detrendIV_tra)  if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf3_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(D_OFn_tra2) bracket asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
drop esample

** first stage
disp "4 tra fs"
reghdfe D_OFn_tra2 l3.detrendIV_tra if iso3c!="CHN" & !missing(d.aw_gini0_sqkm), /// 
	absorb(pid cy) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf4.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("First")
	
** ac reg with conley
acreg D_OFn_tra2 l3_detrendIV_tra if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf4_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	replace drop(o.*) sortvar(Policy chn_*) ctitle("First")
drop esample


** COLUMN 2: WITHIN ADM1 VALUES

** OLS
disp "1 tra aw_gini0_sqkm"
reghdfe d.aw_gini0_sqkm chn_usd_tra_con_ln2 if iso3c!="CHN" & !missing(l3.detrendIV_tra), absorb(pid cy) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf1.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(chn_usd_tra_con_ln2) asterisk(se)  ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
	
** ac reg with conley
acreg d_aw_gini0_sqkm chn_usd_tra_con_ln2 if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf1_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(chn_usd_tra_con_ln2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
drop esample

** reduced form
disp "2 tra aw_gini0_sqkm"
reghdfe d.aw_gini0_sqkm l3.detrendIV_tra if iso3c!="CHN" & !missing(D_OFn_tra2), /// 
	absorb(pid cy) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf2.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
	
** ac reg with conley
acreg d_aw_gini0_sqkm l3_detrendIV_tra if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf2_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
drop esample

**2SLS
disp "3 tra aw_gini0_sqkm"
ivreghdfe d.aw_gini0_sqkm (chn_usd_tra_con_ln2 = l3.detrendIV_tra) if iso3c!="CHN", /// 
	absorb(pid cy) cluster(cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf3.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf)  policy(chn_usd_tra_con_ln2) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
	
** ac reg with conley
acreg d_aw_gini0_sqkm (chn_usd_tra_con_ln2 = l3_detrendIV_tra) if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf3_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(chn_usd_tra_con_ln2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
drop esample

** first stage
disp "4 tra fs"
reghdfe chn_usd_tra_con_ln2 l3.detrendIV_tra if iso3c!="CHN" & !missing(d.aw_gini0_sqkm), /// 
	absorb(pid cy) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf4.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("First")
	
** ac reg with conley
acreg chn_usd_tra_con_ln2 l3_detrendIV_tra if esample==1, ///
	hac id(pid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(cy) pfe2(pid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf4_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("First")
drop esample

*** COLUMN 3: BETWEEN ADM1 in ADM0 DUMMY

*** Load ADM0-level data
use ./data/output/chnineq_reg_ADM0.dta, clear

** OLS
disp "1 tra ADM1ctry_aw_gini0_sqkm"
reghdfe d.ADM1ctry_aw_gini0_sqkm D_OFn_tra2 ///
	if iso3c!="CHN" & !missing(l3.detrendIV_tra), absorb(cid year) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf1.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf)  policy(D_OFn_tra2) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm D_OFn_tra2 if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf1_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(D_OFn_tra2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
drop esample
	
** reduced form
disp "2 tra ADM1ctry_aw_gini0_sqkm"
reghdfe d.ADM1ctry_aw_gini0_sqkm l3.detrendIV_tra if iso3c!="CHN" & !missing(D_OFn_tra2), /// 
	absorb(cid year) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf2.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm l3_detrendIV_tra if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf2_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
drop esample

**2SLS
disp "3 tra ADM1ctry_aw_gini0_sqkm"
ivreghdfe d.ADM1ctry_aw_gini0_sqkm (D_OFn_tra2 = l3.detrendIV_tra) if iso3c!="CHN" /*& !missing(ADM1ctry_pw_gini_pc)*/, /// 
	absorb(cid year) cluster(cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf3.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(D_OFn_tra2) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm (D_OFn_tra2 = l3_detrendIV_tra) if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf3_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(D_OFn_tra2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
drop esample
	
** first stage
disp "4 tra fs"
reghdfe D_OFn_tra2 l3.detrendIV_tra if iso3c!="CHN" & !missing(d.ADM1ctry_aw_gini0_sqkm), /// 
	absorb(cid year) vce(cluster cid)
gen esample = e(sample)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf4.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.* ) sortvar(Policy chn_*) ctitle("First")
	
	
** ac reg with conley
acreg D_OFn_tra2 l3_detrendIV_tra if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf4_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("First")
	
*** COLUMN 4: Now with values

** OLS
disp "1 tra ADM1ctry_aw_gini0_sqkm"
reghdfe d.ADM1ctry_aw_gini0_sqkm chn_usd_tra_con_ln2 ///
	if esample==1, absorb(cid year) vce(cluster cid)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf1.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf)  policy(chn_usd_tra_con_ln2) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm chn_usd_tra_con_ln2 if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf1_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(chn_usd_tra_con_ln2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("OLS")
	
** reduced form
disp "2 tra ADM1ctry_aw_gini0_sqkm"
reghdfe d.ADM1ctry_aw_gini0_sqkm l3.detrendIV_tra if esample==1, ///
	absorb(cid year) vce(cluster cid)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf2.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm l3_detrendIV_tra if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf2_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("Reduced")

**2SLS
disp "3 tra ADM1ctry_aw_gini0_sqkm"
ivreghdfe d.ADM1ctry_aw_gini0_sqkm (chn_usd_tra_con_ln2 = l3.detrendIV_tra) ///
	if esample==1, absorb(cid year) vce(cluster cid)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf3.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(chn_usd_tra_con_ln2) asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")
	
** ac reg with conley
acreg d_ADM1ctry_aw_gini0_sqkm (chn_usd_tra_con_ln2 = l3_detrendIV_tra) if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf3_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(chn_usd_tra_con_ln2) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("2SLS")

** first stage
disp "4 tra fs"
reghdfe chn_usd_tra_con_ln2 l3.detrendIV_tra if esample==1, /// 
	absorb(cid year) vce(cluster cid)
mat A = e(dof_table)
local regions = A[1,1]
local countries = e(N_clust)
outreg2 using ./output/tables/mf4.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, e(N_clust), Observations, e(N)) ///
	dec(4) e(rkf) policy(l3.detrendIV_tra) asterisk(se) ///
	append drop(o.* ) sortvar(Policy chn_*) ctitle("First")
	
	
** ac reg with conley
acreg chn_usd_tra_con_ln2 l3_detrendIV_tra if esample==1, ///
	hac id(cid)  time(year) lag(1000)  dropsingletons /// 
	pfe1(year) pfe2(cid) spatial latitude(lat) longitude(lon) dist(500) bartlett
outreg2 using ./output/tables/mf4_b.txt, nocons noobs nonotes nor2  ///
	adds(Regions, `regions', Countries, `countries', Observations, e(N)) ///
	dec(4) e(widstat) policy(l3_detrendIV_tra) bracket asterisk(se) ///
	append drop(o.*) sortvar(Policy chn_*) ctitle("First")

**** OUTPUT

cd ./output/tables/

* only works on linux
cap !sed -i 's/Policy/ChnProject/g' mf1*.txt
cap !sed -i 's/Policy/Instrument/g' mf2*.txt
cap !sed -i 's/.0000/ /g' mf*.txt

panelout, save(Table1.xml) use(mf1.txt mf2.txt mf3.txt mf4.txt) ///
	excel replace dec(4)

panelout, save(Table1.tex) use(mf1.txt mf2.txt mf3.txt mf4.txt) ///
	tex replace dec(4)
	
panelout, save(Table1_conley.xml) use(mf1_b.txt mf2_b.txt mf3_b.txt mf4_b.txt) ///
	excel replace dec(4)

panelout, save(Table1_conley.tex) use(mf1_b.txt mf2_b.txt mf3_b.txt mf4_b.txt) ///
	tex replace dec(4)
	
** clean up	
foreach f in mf1.txt mf2.txt mf3.txt mf4.txt ///
	mf1_b.txt mf2_b.txt mf3_b.txt mf4_b.txt {
erase `f'
}	

* only works on linux
cap !sed -i 's/.0000/ /g' Table1*
cap !sed -i 's/VARIABLES/ /g' Table1*

cap !awk 'NR==FNR { conley_se[NR] = $0; next } ///
     /\([0-9.]+\)/ { print $0; print conley_se[FNR] } ///
     !/\([0-9.]+\)/ { print $0 }' Table1_conley.tex Table1.tex > Table1_combined.tex
   
cap !sed -i '/^rkf & \./d' Table1_combined.tex
cap !sed -i '/^ *rkf & \./d' Table1_combined.tex

cap !sed -i '0,/^ *rkf/s/^ *rkf/First stage F-stat/' Table1_combined.tex 
cap !awk '/^First stage F-stat/ { for (i=1; i<=NF; i++) if (\$i ~ /^[0-9.]+$/) printf "%.2f ", \$i; else printf \$i " "; printf "\n"; next }1' Table1_combined.tex > temp && mv temp Table1_combined.tex

* walk back
cd ./../../
