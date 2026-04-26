# BFT Add Health Skeleton

This folder contains a skeleton implementation of a Basse-Feller-Toulis
(BFT) conditional randomization test on the Add Health network data using the
`BicliqueRT` package.

The main script is:

- [BFT_addhealth_skeleton.R](./BFT_addhealth_skeleton.R)

## What the script does

The script builds a network-based spillover test with the following pieces:

1. Loads one Add Health community network from `networkdata::addhealth`.
2. Symmetrizes the adjacency matrix and drops isolated nodes.
3. Simulates treatment under complete randomization with a fixed treated share.
4. Defines exposure for each unit as:
   - own treatment status
   - whether the unit has at least one treated friend
5. Tests the null:
   - `Y(0,1) = Y(0,0)`
   - interpretation: no spillover effect among untreated units
6. Uses `BicliqueRT::biclique.decompose()` and `BicliqueRT::clique_test()`
   to run the BFT conditional randomization test.

## Exposure mapping

The script uses four exposure labels:

- `d00`: untreated, no treated friend
- `d01`: untreated, at least one treated friend
- `d10`: treated, no treated friend
- `d11`: treated, at least one treated friend

The tested null only compares `d00` and `d01`.

## Main functions

### Single-community run

- `run_bft_addhealth(...)`

Runs one BFT test on a chosen community and returns:

- network settings
- observed treatment vector
- observed outcomes
- observed exposures
- biclique decomposition object
- BFT test output

- `summarize_bft_result(result)`

Converts one run into a compact one-row summary table with:

- `community`
- `N`
- `n_treated`
- `p_value`
- `statistic`
- `focal_assignments`
- exposure counts `d00`, `d01`, `d10`, `d11`

### Benchmark workflow

- `benchmark_bft_communities(...)`

Runs one screened BFT test per community in a user-supplied list and returns:

- `benchmark_table`
- `benchmark_results`

- `select_best_benchmark_communities(...)`

Ranks benchmarked communities using the current rule:

1. valid p-value
2. larger `focal_assignments`
3. larger `N`

Runtime is recorded in the benchmark table but is not used for ranking.

- `rerun_selected_benchmark_communities(...)`

Reruns a selected subset of communities with stronger settings, for example a
larger number of candidate assignments.

- `run_bft_benchmark_workflow(...)`

Runs the full two-stage workflow:

1. benchmark a set of communities at lighter settings
2. select the top `k`
3. rerun the selected communities at stronger settings

## Important tuning parameters

- `treated_frac`
  Share of units treated under complete randomization.

- `num_randomizations`
  Number of candidate treatment assignments generated for the biclique search.
  The observed assignment is also included, so the total candidate pool is
  `num_randomizations + 1`.

- `mina`
  Minimum number of assignment columns targeted by the greedy biclique
  decomposition.

## How to use

### Example: one run

```r
source("anqi_BasseFellerToulis/BFT_addhealth_skeleton.R")

out <- run_bft_addhealth(
  comm_name = "comm_82",
  treated_frac = 0.10,
  num_randomizations = 1000,
  mina = 10,
  seed = 123,
  direct_effect = 0.5,
  spillover_effect = 1.0,
  noise_sd = 1.0
)

summarize_bft_result(out)
```

### Example: benchmark several communities

```r
source("anqi_BasseFellerToulis/BFT_addhealth_skeleton.R")

benchmark_out <- benchmark_bft_communities(
  comm_names = benchmark_comm_tiers,
  num_randomizations = 200,
  mina = 10
)

benchmark_out$benchmark_table
select_best_benchmark_communities(benchmark_out$benchmark_table, top_k = 5)
```

### Example: run the prepared workflow

```r
source("anqi_BasseFellerToulis/BFT_addhealth_skeleton.R")

workflow_out <- run_bft_benchmark_workflow(
  benchmark_comm_names = benchmark_comm_tiers,
  top_k = 5,
  benchmark_num_randomizations = 200,
  rerun_num_randomizations = 1000,
  mina = 10
)

workflow_out$benchmark_table
workflow_out$selected_table
workflow_out$rerun_table
```

## Interpreting the output

- `p_value`
  Conditional randomization-test p-value for the null of no spillover among
  untreated units.

- `focal_assignments`
  Number of assignment columns retained in the final conditional clique.
  Small values do not invalidate the test, but they often indicate a tight
  conditional randomization set and limited power.

- `statistic`
  Absolute difference in mean outcomes between focal units with exposure `d01`
  and focal units with exposure `d00`.

## Current limitations

- The current setup uses complete randomization on a general friendship
  network, which often leads to small conditional assignment sets.
- The null is narrow, comparing only `d00` and `d01`.
- Because of those two features, the BFT test can be valid but conservative and
  underpowered in some communities.
