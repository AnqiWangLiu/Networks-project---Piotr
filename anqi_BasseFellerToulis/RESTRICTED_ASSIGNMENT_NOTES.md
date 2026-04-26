# Restricted Assignment Variant

This note explains the intuition behind the restricted-assignment version of the BFT Add Health skeleton in [skeleton_restricted_assignment.R](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/skeleton_restricted_assignment.R:1).

## What changes relative to the benchmark model

The original benchmark model in [BFT_addhealth_skeleton.R](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/BFT_addhealth_skeleton.R:1) uses complete randomization:

- about 10% of students are treated
- any student in the community can be treated

The restricted-assignment version keeps the same:

- Add Health network data
- exposure mapping `h_i(Z) = (own treatment, any treated friend)`
- null hypothesis `Y_i(0,1) = Y_i(0,0)`
- BFT biclique decomposition and conditional randomization test
- benchmark workflow: screen at `R = 200`, rerun selected communities at `R = 1000`

The only design change is:

- treatment can be assigned only to a fixed eligible set of nodes

In the current implementation, the eligible set is the top-degree 25% of nodes in each community, with the treated count still equal to 10% of the full community.

## Intuition

The motivation for this variant is that the original unrestricted design made exposures change too chaotically across assignments. Under complete randomization, many different students can become treated in each reassignment, which makes it hard for the BFT procedure to retain a large comparable assignment set.

Restricting treatment eligibility is meant to impose more structure:

- only some students can ever move into treated states
- many students are guaranteed to remain untreated across all candidate assignments
- the untreated spillover contrast `d00` versus `d01` can become easier to compare conditionally

In short, this variant tries to stabilize the exposure process without changing the substantive null being tested.

## What the output files mean

The restricted workflow produced four CSV files:

- [benchmark_table_all_200_restricted.csv](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/output/benchmark_table_all_200_restricted.csv)
  Screen of all communities at `R = 200` under restricted assignment.
- [selected_top5_from_all_200_restricted.csv](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/output/selected_top5_from_all_200_restricted.csv)
  Top 5 communities selected from the restricted screen using the current ranking rule.
- [rerun_top5_table_1000_restricted.csv](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/output/rerun_top5_table_1000_restricted.csv)
  Rerun at `R = 1000` for the top 5 communities selected by the restricted screen.
- [rerun_original_top5_table_1000_restricted.csv](/c:/Users/anqiw/OneDrive/Documentos/Networks-project---Piotr/anqi_BasseFellerToulis/output/rerun_original_top5_table_1000_restricted.csv)
  Rerun at `R = 1000` for the top 5 communities selected under the original unrestricted benchmark, now re-estimated under restricted assignment for direct comparison.

## How to interpret the results

The p-value still has the same meaning as in the benchmark model:

- it is a conditional randomization-test p-value
- it tests the null `Y_i(0,1) = Y_i(0,0)`
- it does not estimate the spillover effect size directly

So a smaller p-value means stronger evidence against the no-spillover null among untreated units, not a larger estimated spillover effect.

The additional columns `n_eligible` and `eligible_frac` describe the restricted design:

- `n_eligible` is the number of nodes that were allowed to receive treatment
- `eligible_frac` is the fraction of the community designated as eligible

## Comparison with the benchmark model

This restricted version should be interpreted as a design experiment, not as a replacement of the original benchmark.

The main comparison is:

- benchmark model: unrestricted complete randomization
- restricted model: treatment limited to high-degree eligible nodes

Substantively, the restricted version asks whether a more structured intervention rule changes the behavior of the BFT test. In the current runs, it did:

- some communities moved closer to rejection under restricted assignment
- some did not change much
- one community moved away from rejection

For the original top 5 communities from the unrestricted benchmark, the rerun under restricted assignment showed:

- `comm_28`: p-value decreased from about `0.137` to `0.077`
- `comm_33`: p-value decreased slightly from about `0.180` to `0.170`
- `comm_57`: p-value decreased from about `0.161` to `0.059`
- `comm_68`: p-value decreased from about `0.477` to `0.082`
- `comm_69`: p-value increased from about `0.127` to `0.329`

So the restricted design did not uniformly strengthen the test, but it clearly changed the inferential behavior for several communities.

## Bottom line

The restricted-assignment variant is useful as a benchmark against the original model because it isolates one design choice:

- who is allowed to be treated

That makes it a good way to study whether the difficulty of rejecting the spillover null is driven partly by the randomness of the assignment mechanism rather than only by network size or the BFT algorithm itself.
