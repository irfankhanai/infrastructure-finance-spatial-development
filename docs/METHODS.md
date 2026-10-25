# Models, estimands, and identification

## Outcome and unit of analysis

The empirical unit is a first-order administrative region (ADM1) observed by year. `aw_gini0_sqkm` measures the spatial concentration of nighttime lights within a region. A reduction suggests a more even spatial distribution of light; it does not necessarily imply higher total output or faster GDP growth. A growth extension needs a separately defined and harmonized outcome.

## Portable association model

The release estimates:

```text
Gini[i,t] - Gini[i,t-1] = beta * WB_transport[i,t-2]
                         + region_FE[i] + country_year_FE[c,t] + error[i,t]
```

Standard errors are clustered by country. The workflow reconstructs calendar lags before dropping missing outcomes or treatments, excludes China, and reports input, eligible, and final estimation row counts. `fixest` may remove singleton observations. It does not apply all original population, income, and sample restrictions and is therefore a reusable association model rather than a replication of the paper's Table 1.

Country-year fixed effects absorb national annual shocks; region effects absorb time-invariant regional characteristics. Neither removes time-varying regional project selection, anticipation, reverse causality, or spatial spillovers. Few country clusters can also make conventional inference unreliable.

## Historical IV specifications

The included upstream `create_instruments.do` constructs a factor from detrended log production series for steel, cement, pig iron, timber, glass, and aluminum. It is more than a single steel-production series. In `build_adm1_merges.do`, the detrended factor is interacted with sector-specific regional project-receipt propensity. The upstream Table 1 uses the instrument at a three-year lag.

The archived R V04 build instead uses `factor1 * (1 + cum_chn)` and constructs a two-year lag. The archived model labels mention a three-year lag even while using `L2_detrendIV_tra`. These are substantive specification differences, not interchangeable names. The historical scripts are preserved unchanged to make this divergence inspectable.

The archive also experiments with Chinese projects as an instrument for World Bank exposure. Chinese investment can itself affect the regional outcome, making the exclusion restriction particularly difficult to defend. Cumulative project receipt may encode endogenous selection and trends.

## Requirements for a World Bank causal design

Before estimating or describing a WB effect as causal:

1. Specify a donor-side financing shock with a documented institutional mechanism affecting WB allocations.
2. Define exposure before the estimation window; discuss why exposure does not independently predict regional trends.
3. Align instrument timing with approvals, commitments, implementation, and plausible outcome response.
4. Assess direct effects, correlated donor responses, spillovers, and anticipatory allocation.
5. Estimate first-stage, reduced-form, and 2SLS models on the same eligible sample for each endogenous treatment.
6. Report clustered first-stage diagnostics, partial explanatory power, and weak-instrument-robust inference. A conventional F > 10 is not proof of identification.
7. Test sensitivity to trends, country composition, spatial dependence, treatment definitions, and placebo outcomes/timing.

This release proposes no validated WB instrument. The historical IV code is a research record; the portable entry point deliberately estimates an association model. A substantive IV design should be reviewed before new causal claims are made.

## Comparable investment measures

Keep project presence, distinct project counts, project-location counts, annual flows, and cumulative stocks separate. Multiple geocodes can duplicate a project or multiply its financial amount. Document the allocation rule and check project-level totals after aggregation. Distinguish approvals from active years and disbursements from commitments. Compare donors on common sector, price, location-precision, geography, and year definitions.
