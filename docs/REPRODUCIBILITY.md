# Reproduction levels

## 1. Portable demonstration

Run `Rscript tests/test_panel.R` and `Rscript scripts/run_demo.R` from the root. Tests use base R; the model uses `fixest`. The synthetic data are generated in memory using a fixed seed. Outputs and `sessionInfo()` are saved under the ignored `results/generated/` directory. Package versions are not locked; record the session before comparing estimates across environments.

## 2. Local empirical panel

Install `haven` and provide a panel matching `docs/DATA.md` to `scripts/analyze_panel.R`. The input is read only. The script fits a common portable specification and writes newly named output files. It does not invoke the historical IV analysis, enforce the original population restrictions, or claim to match archived tables.

## 3. Historical working scripts

`legacy/R/` contains unchanged selected scripts from the supplied archive. Their filenames have been clarified; `docs/source-manifest.json` records original paths and content hashes. Dependencies include `tidyverse`, `haven`, `sf`, `readxl`, `data.table`, `countrycode`, `fixest`, `modelsummary`, and `kableExtra`, depending on the script. Some scripts install packages during execution, clear the workspace, use absolute paths, and expect previously generated data.

To investigate them, work in a separate copy of the original replication directory, install required packages, supply its licensed inputs, and adapt working-directory settings there. Keep the published archive files unchanged for provenance. The V04 build uses pre-existing instrument and outcome files and is not a self-contained replacement for all Stata stages.

## 4. Exact original-paper replication

Download the full original package and follow its README in a separate directory. This repository contains selected reference scripts only; it omits the full Stata ado environment, data, GIS files, and many table/figure scripts. Stata and source-specific inputs remain necessary for the original pipeline. Verify published table entries, sample sizes, instruments, and variance estimators before claiming replication success.
