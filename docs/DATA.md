# Data access and schema

## Sources

- Original replication data and documentation: https://doi.org/10.17632/235v7ksk8y.1
- AidData project releases: https://www.aiddata.org/ — select and record the precise release, temporal coverage, geocoding method, and license.
- World Bank projects: https://projects.worldbank.org/ — record the source vintage and linkage to any separately obtained geocoded locations.
- GADM boundaries: https://gadm.org/ — the historical code expects GADM 2.8. Acquire locally under the applicable terms; boundary files are not redistributed here.

See `upstream/README-original.md` for the historical input inventory. No new 2021 geocoded release is bundled or implicitly substituted for those sources.

## Portable panel contract

| Column | Type | Meaning |
|---|---|---|
| `iso3c` | character | Country identifier used for clustering and country-year effects |
| `id_1` | character or numeric | ADM1 identifier within country |
| `year` | integer | Calendar year |
| `aw_gini0_sqkm` | numeric or missing | Within-region nighttime-light Gini; verify scale from source metadata |
| `wb_tra_project_dum` | 0, 1, or missing | World Bank transport exposure for that year |

One row per country–region–year is required. Keys cannot be missing. Missing exposures are not changed to zero. Additional columns are allowed. The portable workflow accepts CSV and Stata files and reconstructs its own outcome differences and treatment lags.

## Extending through 2021

Build an input manifest with release IDs, download dates, licenses, and checksums. Confirm that the project approval/commitment series actually reaches 2021. Establish comparable outcomes through 2021, including documented harmonization if transitioning from DMSP to VIIRS nighttime lights. Harmonize region boundaries and crosswalks; audit project IDs, transport categories, currency/price basis, and geocoding precision. Update covariates and any donor-side factor series independently. Validate common coverage and describe sample attrition before estimating.

An extended project end date, a filename containing `2021`, or a relaxed year filter is not evidence of a completed extension.
