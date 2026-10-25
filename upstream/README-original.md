# README -- Data and Code for: 'Connective Financing: Chinese Infrastructure Projects and the Diffusion of Economic Activity in Developing Countries'

**Authors:**  
Richard Bluhm, Axel Dreher, Andreas Fuchs, Bradley C. Parks, Austin M. Strange, Michael J. Tierney  

**Date:**  
October 21, 2024

## Overview 

The code in this replication package processes the data for each data source, builds intermediate data sets, extracts the relevant information specifically for the project, combines it, and generates the results using R and Stata. The master file runs the code to generate the data and the exhibits in the main paper and the online appendix. The replicator should expect the code to run for about 1-3 hours, depending on the computing resources available. Most of the individual scripts are fast (a few seconds or minutes), but a few scripts require some time to run. 

## Description of Files and Folder Structure 

1. `Readme.Rmd` is a markdown file that generates `Readme.html`.
 
2. `Readme.html` provides the necessary information about the replication folder's structure, data sources and access, computational requirements, and how to replicate the results presented in the paper.

3. `/ado/` contains all user-written Stata packages to ensure the results replicate exactly (ados are platform independent)

4. `/code/` contains all scripts to clean, build, merge, prepare the data for analysis, and replicate the figures and tables in the paper and online appendix.

    a. `/code/build/` contains the scripts that clean the raw data in "./data/input/", save intermediate results in `/data/intermediate/`, and build the data sets used in the analysis, which are saved in `/data/output/`.
    b. `/code/analysis/` contains the Stata and R scripts that create all figures and tables in the paper and online appendix. 

5. `/data/` contains data in various formats: input, intermediate, and output data sets.

    a. `/data/input/` contains all raw data (e.g. Chinese-financed projects) and GIS-based geospatial data (ADM1 extracts).
    b. `/data/intermediate/` contains all intermediate files and will deleted at the end of `/code/masterfile.do`.
    c. `/data/analysis/` contains data sets containing the relevant variables for this project, sample creation, and merged panel for analysis.

6. `LICENSE.txt`: a text file with the license information for the data and code in this replication package.
    
### License for Data 

The data is licensed under a Creative Commons Attribution 4.0 International License. See [LICENSE.txt](LICENSE.txt) for details and [https://creativecommons.org/licenses/by/4.0/deed.en](https://creativecommons.org/licenses/by/4.0/deed.en) for a summary.

### Summary of Availability

GADM does not allow redistribution of the vector data. They can be downloaded here [https://biogeo.ucdavis.edu/data/gadm2.8/gadm28.shp.zip](https://biogeo.ucdavis.edu/data/gadm2.8/gadm28.shp.zip) and the ADM1 data has to be placed in `/data/input/gadm28_adm1_shp/`.

### Details on each Data Source 


* Geocoded Global Chinese Official Finance, 2000--2014:
    + data file(s): 
      - prejoined subnational locations & projects table: `/data/input/chn_projects/data/level_1a.csv`
      - projects ancillary table: `/data/input/chn_projects/data/projects_ancillary.csv` 
      - sub-categories of transport projects (coded for this paper): `/data/input/chn_projects/data/all_flows_transport_project_types_final.xlsx` 
    + source(s): China_GeocodedResearchRelease_Level1_v1.1, available  [here](https://www.aiddata.org/geoquery-datasets/chinatotal-geocodedresearchrelease-level1-v1-1-0)
    + unit(s): project locations, geocoded to various spatial entities
    * provided: yes

* Spatial Inequality Data, 1992--2013:
    + data file(s): 
      - data frame only: `/data/input/allginis/within_gadm1.csv`
    + source(s): Underlying nighttime lights raster data from Earth Observation Group, NOAA, available  [here](https://www.ngdc.noaa.gov/eog/dmsp/downloadV4composites.html)
    + unit(s): aggregated from cells to first-order administrative units (GADM)
    * provided: yes, aggregated
    
* Chinese domestic production (Steel, Cement, Pig Iron, Timber, Glass, Aluminum and GDP) 
    + data file(s): 
      - production inputs: downloaded via QUANDL API and extended with yearbooks
      - GDP: downloaded via wbopendata (code `NY.GDP.MKTP.KN`)
    + source(s): National Bureau of Statistics China, available  [here](https://www.stats.gov.cn/english/Statisticaldata/yearbook/), and World Bank (see above)
    + unit(s): yearly time-series
    * provided: yes, as downloaded on Jul 31, 2024, QUANDL has removed these series since then
    
* Geocoded information on 688 historical Chinese project locations in Africa, 1957--1987:
    + data file(s): 
      - geocoded data: `./data/input/bartke/bartke_geocoded_v0.2.csv`
      - geocoded data w/ updates: `./data/input/bartke/bartke_geocoded_v0.2_updated.xlsx`
    + source(s): Dreher, A., A. Fuchs, R. Hodler, B. C. Parks, P. A. Raschky, and M. J. Tierney (2021). Is Favoritism a Threat to Chinese Aid Effectiveness? A Subnational Analysis of Chinese Development Projects. World Development 139, 105291
    + unit(s): project location
    * provided: yes

* Case Study Files:
    + data file(s): 
      - Thika-Nairobi road vector: `/data/input/case_study/Thika_Road.gpkg`
      - Place names: `/data/input/case_study/names.gpkg`
      - GADM: `/data/input/case_study/KEN_adm1.rds`
      - DMSP images for Kenya:  `/data/input/case_study/F162008.tif` and `/data/input/case_study/F182013.tif`
    + source(s): OSM for Thika road and place names, GADM 2.8 for admin boundary of Nairobi, Earth Observation Group, NOAA, for nighttime lights, GADM data for Kenya needs to be dowloaded [here](https://biogeo.ucdavis.edu/data/gadm2.8/rds/KEN_adm1.rds)
    + unit(s): 30 arc seconds pixels
    * provided: yes, except GADM vector data

* Chinese Foreign Direct Investment, 1992--2013:
    + data file(s): 
      - raw UCTAD FDI panel: `/data/input/fdi_unctad/US_FdiFlowsStock_ST201909021702_v2.csv`
    + source(s): UNCTAD, Division on Investment and Enterprise, available at [link](https://unctadstat.unctad.org/datacentre/)
    + unit(s): country-year (by flow type)
    * provided: yes
    
* Global Administrative Boundaries (GADM):
    + data file(s): 
      - vector data: `/data/input/gadm28_adm1_shp/gadm28_adm1.shp`
    + source(s): GADM, available at [link](https://gadm.org/old_versions.html)
    + unit(s): first-order region
    * provided: no, see summary of availability above
    
* Geospatial extracts of travel time to cities, urbanization rate, road density, distance to coast, and major mineral deposits within first-order regions
    + data file(s): 
      - travel time, data frame only: `/data/input/zonalstats/Acess50k_GADM1.csv`
      - urbanization rate, data frame only: `/data/input/zonalstats/GHSL_Urbanization_GADM1,csv`
      - road density, data frame only: `/data/input/zonalstats/gRoads_Roaddensity_GADM1.csv`
      - distance to coast, data frame only: `/data/input/zonalstats/Dist2Coast_GADM1.csv`
      - mineral deposits, data frame only: `/data/input/zonalstats/majormines_ADM1.csv`
    + source(s): travel time from EU JRC, available  [here](https://forobs.jrc.ec.europa.eu/gam/download), urbanization rate from EU JRC/GHSL, available [here](https://data.jrc.ec.europa.eu/dataset/jrc-ghsl-ghs_smod_pop_globe_r2016a), road density from CIESIN/gRoads, available [here](https://sedac.ciesin.columbia.edu/data/set/groads-global-roads-open-access-v1), distance to coast via coastline data from Natural Earth, available [here](https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-coastline/), and major mineral deposits from USGS, available [here](https://mrdata.usgs.gov/major-deposits/)
    + unit(s): aggregated from cells to first-order administrative units (GADM)
    * provided: yes, aggregated

* IMF Direction of Trade Statistics (DOTS), 1992--2013:
    + data file(s): 
      - raw CIF panel: `/data/input/IMF_DOTS/TMG_CIF_USD_panel_1980_2013.csv`
      - raw FOB panel: `/data/input/IMF_DOTS/TXG_FOB_USD_panel_1980_2013`
    + source(s): IMF DOTS , available at [link](https://data.imf.org/DOT)
    + unit(s): country-partner-country (export/import type) panel
    * provided: yes
    
* WB Income Categories, 1987--2013:
    + data file(s): 
      - raw Excel with categories: `/data/input/income_levs_wb/OGHIST.xlsx`
      - raw CSV with GNI and cut-offs: `/data/input/income_levs_wb/GNI_Per_Capita_&_Income_Thresholds_data.csv`
    + source(s): World Bank , available at [link](https://databankfiles.worldbank.org/public/ddpext_download/site-content/OGHIST.xlsx) and [link](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups)
    + unit(s): country panel
    * provided: yes
  
* PETRODATA v1.2, oil fields, 1946--2003
    + data file(s): 
      - vector data for onshore deposits: `./data/input/petrodata/Petrodata_Onshore_V1.2.shp`
    + source(s): Lujala, Päivi; Jan Ketil Rød & Nadia Thieme, 2007. 'Fighting over Oil: Introducing A New Dataset', Conflict Management and Peace Science 24(3), 239-256, data available  [here](https://legacy.prio.org/data/11)
    + unit(s): deposit location as polygons
    * provided: yes
    
* World Bank projects, 1995--2014:
    + data file(s): 
      - prejoined subnational locations & projects table: `/data/input/wb_aid_v1.4.2/data/level_1a.csv`
    + source(s): WorldBank_GeocodedResearchRelease_Level1_v1.4.2, available  [here](https://www.aiddata.org/data/world-bank-geocoded-research-release-level-1-v1-4-2)
    + unit(s): project locations, geocoded to various spatial entities
    * provided: yes


## Computational requirements


### Software Requirements

- Stata (code was last run with version 17.0, version 15.0 or higher is required) with the many user-written packages installed. 
- `./code/masterfile.do` will set all relevant paths, globals and will add all the required user-written Stata packages to the run time path. 
- Replicators need to set the path to the replication folder.
- Replicators need to get and set FRED and QUANDL keys, and set their R installation directory for `rscript` to work properly.
- Replicators need to manually install the parallel package (`ssc install parallel`) as written in the masterfile, as this package makes system specific links.
- R code was last run with version 4.4.1. Note that replicators need to install a number of packages, see `install_r_deps.R` which gets called from  `./code/masterfile.do`.


### Memory and runtime requirements

The code was last run on an **AMD Ryzen Threadripper PRO 5965WX 24-Cores (48-Threads), 3.80GHz operating (4.5 GHz turbo) ; 256GB RAM; Ubuntu Linux 22.04.4 LTS**. 

### Description of programs/code

`/code/masterfile.do`:

- Processes the input data contained in `/data/input/` and saves them in `/data/intermediate/`.
- Assembles the main data sets from `/data/intermediate/` and saves them in `/data/output/`. 
- Reproduces all exhibits in the main paper and appendix. The table below shows which file reproduces which exhibit.

### License for Code 

The code is licensed under a Modified BSD License. See [LICENSE.txt](LICENSE.txt) for details.


### List of exhibits and programs 

|Exhibit   | Code in "/code/analyze" | Output in "/output/"   | Notes                                   |
|----------|-------------------------|------------------------|-----------------------------------------|
|          |                         |                        |                                         |
|Paper:    |                         |                        |                                         |
|          |                         |                        |                                         |
| Fig. 1   | Figure_1.R              | Figure_1.pdf           |                                         |
| Fig. 2   | Figure_2.R              | Figure_2.pdf           |                                         |
| Fig. 3   | Figure_3.R              | Figure_3.pdf           |                                         |
| Fig. 4   | Figure_4.do             | Figure_4_panel_a.pdf   |                                         |
|          |                         | Figure_4_panel_b.pdf   |                                         |
|          |                         | Figure_4_panel_c.pdf   |                                         |
|          |                         | Figure_4_panel_d.pdf   |                                         |
| Fig. 5   | Figure_5.do             | Figure_5.pdf           |                                         |
|          |                         |                        |                                         |
| Table 1  | Table_1.do              | Table1.tex/xml         |                                         |
|          |                         | Table1_conley.tex/xml  |                                         |
|          |                         | Table1_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 2  | Table_2.do              | Table2.tex/xml         |                                         |
|          |                         | Table2_conley.tex/xml  |                                         |
|          |                         | Table2_combined.tex    | Uses awk and sed on Linux, empty on Win  |
| Table 3  | Table_3.do              | Table3.tex/xml         |                                         |
|          |                         | Table3_conley.tex/xml  |                                         |
|          |                         | Table3_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 4  | Table_4.do              | Table4.tex/xml         |                                         |
|          |                         | Table4_conley.tex/xml  |                                         |
|          |                         | Table4_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 5  | Table_5.do              | Table5.tex/xml         |                                         |
|          |                         | Table5_conley.tex/xml  |                                         |
|          |                         | Table5_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 6  | Table_6.do              | Table6.tex/xml         |                                         |
|          |                         | Table6_conley.tex/xml  |                                         |
|          |                         | Table6_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 7  | Table_7.do              | Table7.tex/xml         |                                         |
|          |                         | Table7_conley.tex/xml  |                                         |
|          |                         | Table7_combined.tex    | Uses awk and sed on Linux, empty on Win |
| Table 8  | Table_8.do              | Table8.tex/xml         |                                         |
|          |                         | Table8_conley.tex/xml  |                                         |
|          |                         | Table8_combined.tex    | Uses awk and sed on Linux, empty on Win |
|          |                         |                        |                                         |
|Appendix: |                         |                        |                                         |
|          |                         |                        |                                         |
| Fig. A1  | Figure_A1.do            | Figure_A1_panel_a.pdf  |                                         |
|          |                         | Figure_A1_panel_b.pdf  |                                         |
| Fig. A2  | Figure_A2.do            | Figure_A2.pdf          |                                         |
|          |                         |                        |                                         |
| Table A1 | Table_A1_A3.do          | TableA1.tex            |                                         |
| Table A2 | Table_A2.do             | TableA2.tex            |                                         |
| Table A3 | Table_A1_A3.do          | TableA3.tex            |                                         |
| Table A4 | Table_A4.do             | TableA4.tex/xml        |                                         |
|          |                         | TableA4_conley.tex/xml |                                         |
|          |                         | TableA4_combined.tex   | Uses awk and sed on Linux, empty on Win |
| Table A5 | Table_A5.do             | TableA5.tex/xml        |                                         |
|          |                         | TableA5_conley.tex/xml |                                         |
|          |                         | TableA5_combined.tex   | Uses awk and sed on Linux, empty on Win |
| Table A6 | Table_A6.do             | TableA6.tex/xml        |                                         |
|          |                         | TableA6_conley.tex/xml |                                         |
|          |                         | TableA6_combined.tex   | Uses awk and sed on Linux, empty on Win |


Note: The do-files and R-files mentioned above generate "raw" versions of the tables in the paper, final style adjustments to headers and names were made manually using LaTeX.

