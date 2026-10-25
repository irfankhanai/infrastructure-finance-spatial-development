# Infrastructure Finance and Spatial Development

### A research software case study of Chinese and World Bank investment

[![R checks](https://github.com/irfankhanai/infrastructure-finance-spatial-development/actions/workflows/checks.yml/badge.svg)](https://github.com/irfankhanai/infrastructure-finance-spatial-development/actions/workflows/checks.yml)
![Language](https://img.shields.io/badge/language-R-276DC3)
![Methods](https://img.shields.io/badge/methods-spatial_panel_%7C_fixed_effects_%7C_IV-17594A)

**Research focus:** Where is development infrastructure located, and how is investment associated with the spatial distribution of economic activity?

This repository curates an applied research project extending the workflow of *Connective Financing: Chinese Infrastructure Projects and the Diffusion of Economic Activity in Developing Countries*. It combines historical R extensions, selected upstream Stata reference code, an audit of replication differences, and a portable R modeling workflow.

The contribution is research implementation: spatial data harmonization, panel construction, model translation, specification comparison, and reproducibility diagnostics. The published paper and its identification strategy belong to the original authors. This is an independent portfolio and research-software release, not an official replication package.

> **Evidence status:** The inspected analysis panels cover years through **2013**. A complete extension through 2021 is **not verified** in this archive. Historical World Bank IV specifications are exploratory and do **not** establish a validated causal effect. The primary outcome is the within-region nighttime-light Gini, a measure of spatial concentration, not a direct GDP-growth measure.

## Research questions

| Question | Approach | Interpretation |
|---|---|---|
| Where did China and the World Bank invest? | Geocoded projects joined to ADM1 regions; comparable regional exposure measures | Descriptive allocation patterns |
| How does investment relate to spatial development? | Region and country-year fixed effects; lagged transport exposure | Conditional association |
| Does timing matter? | Contemporaneous, one-year, and two-year lag comparisons | Specification sensitivity |
| Can an external funding factor identify an effect? | Historical first-stage, reduced-form, and 2SLS experiments | Requires a defensible donor-specific exclusion restriction |

## What this project demonstrates

- **Geospatial engineering:** coordinate filtering, ADM1 matching, and harmonization of project and ancillary records using `sf`.
- **Panel econometrics:** regional fixed effects, country-year fixed effects, country-clustered uncertainty, and treatment-timing comparisons with `fixest`.
- **Replication debugging:** identifying year truncation, inconsistent instrument lags, changes in exposure definitions, and missing-data assumptions.
- **Research software:** a portable entry point, calendar-aware lag construction, duplicate-key validation, a synthetic demonstration, and automated checks.

The historical scripts document work already present in the supplied project. The portable workflow and tests were added for this public release; they do not silently replace the historical estimates.

## Quick start

Install R (4.3 or later recommended), then run from the repository root:

```r
install.packages(c("fixest", "haven"), repos = "https://cloud.r-project.org")
```

```sh
Rscript tests/test_panel.R
Rscript scripts/run_demo.R
```

The demo generates synthetic data in memory, fits a fixed-effects association model, and writes coefficients and session information to `results/generated/`. **Synthetic coefficients are not empirical findings.**

To analyze a locally held panel with the required variables:

```sh
Rscript scripts/analyze_panel.R /path/to/chnineq_reg_ADM1_V04.dta
```

See [data requirements](docs/DATA.md) for the schema and [reproduction instructions](docs/REPRODUCIBILITY.md) for historical dependencies. The portable model uses calendar lags and its own complete-case sample, so it is not expected to reproduce legacy coefficients exactly.

## Repository guide

```text
R/                     Portable validation and calendar-lag functions
scripts/               Synthetic demo and empirical OLS entry point
tests/                 Panel-integrity and lag tests
legacy/R/              Selected historical working scripts, unchanged
upstream/              Attributed reference code and original license
results/archived/      Small historical regression table
docs/                  Methods, audit, data access, provenance, CV wording
```

Raw project records, shapefiles, rasters, intermediate panels, private reports, and unrelated files are excluded. No Git LFS download is required.

## Results and methodological limits

The archived V04 table reports 226 observations. Its WB transport-dummy OLS coefficient is -0.0070 (SE 0.0214); its exploratory 2SLS coefficient is 0.0453 (SE 0.3038). These are **historical outputs, not independently reproduced estimates**. The wide IV interval provides no precise evidence of an effect, and instrument validity cannot be inferred from significance or a first-stage statistic.

Read the [methods and IV assessment](docs/METHODS.md) and [audit](docs/AUDIT.md) before interpreting or reusing these outputs. A credible 2021 extension requires aligned outcome coverage, covariates, boundaries, project classifications, and supply-factor series; changing a date filter is insufficient.

## Attribution and reuse

Original study: Richard Bluhm, Axel Dreher, Andreas Fuchs, Bradley C. Parks, Austin M. Strange, and Michael J. Tierney (2024), *Connective Financing: Chinese Infrastructure Projects and the Diffusion of Economic Activity in Developing Countries*, **Journal of Urban Economics**.

[Original replication package](https://doi.org/10.17632/235v7ksk8y.1) · [Source manifest](docs/source-manifest.json) · [Contribution guide](CONTRIBUTING.md)

New release code is available under the BSD 3-Clause license. Inherited code retains the original authors' license and attribution. Original documentation and tables retain their CC BY 4.0 terms; third-party datasets retain their own terms. See [LICENSE](LICENSE) and [NOTICE](NOTICE.md).
