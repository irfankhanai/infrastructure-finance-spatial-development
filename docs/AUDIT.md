# Archive audit and research engineering notes

Audit date: 2026-10-25. Findings refer to the local project supplied for this release, not to every version of the original published replication package.

## Verified local coverage

| Local artifact (excluded from Git) | Rows | Observed year coverage |
|---|---:|---|
| `chnineq_reg_ADM1_V04.dta` | 1,168 | 2001–2013 |
| `WB_corrected_analysis_v51.dta` | 2,097 | 2000–2013 |
| `world_bank_clean_2021.dta` | 60,030 | Transaction start: 1995–2014; transaction end: 1997–2025 |

These ranges were read directly with `pandas.read_stata(convert_categoricals=False)`. End dates after 2021 do not demonstrate inclusion of projects newly approved through 2021. No claim of completed 2021 replication is supported by this inspection alone.

## Findings and release response

| Finding | Consequence | Response |
|---|---|---|
| Absolute `/Users/R_project` paths | Scripts depend on the original workstation | Preserve legacy unchanged; provide root-relative portable commands |
| Explicit 2000–2014 project filters and 2000–2013 model filters | Newer inputs can be silently truncated | Document actual coverage; require aligned extension inputs |
| Row-based `lag`/`shift` | Gaps may yield incorrect calendar lags | New workflow uses region-year key matching; tests cover gaps |
| Repeated merge stages | Duplicate keys or spatial overlaps can multiply rows | New panel validator rejects duplicate region-years; raw spatial joins still require auditing |
| Missing exposure filled with zero in legacy builds | Unobserved coverage may be interpreted as no investment | Portable model retains missing exposure |
| Changed IV exposure and lag | R experiments do not reproduce the upstream IV construction | Explicit methods comparison; no validated WB causal claim |
| Historical table has 226 observations, versus 1,168 panel rows | Filtering, missingness, and fixed-effect removal matter | Preserve counts; do not infer an exact attrition breakdown without rerunning |
| Historical build skips some upstream stages | An R-only end-to-end replication is not established | Dependencies and limitations documented |

## Historical output interpretation

`results/archived/wb_models_v04.csv` is copied without edits. Both reported WB OLS and 2SLS transport-dummy confidence intervals cross zero. The archive contains multiple versions; this small table is retained as an example of the historical modeling record, not selected as a definitive result. Its `R2` column is populated by an adjusted-R-squared request in the archived analysis script; negative values should not be interpreted as an estimation failure by themselves.

## Verification boundaries

During packaging, file provenance, source hashes, local panel coverage, and publication payload are checked. R is not installed in the packaging workstation's discovered runtime locations, so neither the historical models nor the new R workflow were executed locally. GitHub Actions is configured to run the new validation tests and synthetic smoke test; its status must be inspected separately. No equality to published estimates is claimed.
