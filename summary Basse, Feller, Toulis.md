# Randomization Tests of Causal Effects Under Interference

## Motivation

Classical causal inference often assumes **no interference**: the treatment assigned to one unit does not affect another unit's outcome. This is known as the Stable Unit Treatment Value Assumption, or SUTVA.

Eg. students in the same household, people in the same social network, firms in the same market, and individuals exposed to peer effects: In these settings, a unit's outcome may depend not only on its own treatment status, but also on the treatment status of nearby or related units.

This creates a problem for standard Fisher randomization tests. Under no interference, the sharp null hypothesis of no treatment effect lets us impute all missing potential outcomes. Under interference, many hypotheses are no longer sharp, because changing one unit's assignment can also change other units' exposure conditions.

## Core Idea

The paper develops a framework for valid randomization tests under interference using **conditioning mechanisms**.

The key question is:

> How can we run a valid randomization test when the null hypothesis does not determine every missing potential outcome?

We condition the test on carefully chosen information so that, within the conditioned set, the test statistic becomes imputable.

In practice, this means the method restricts attention to:

1. a subset of units, called **focal units**, and
2. a subset of treatment assignments,

such that $H_0$ provides enough information to compute the test statistic under the assignments being compared.

## Key Concepts

### Interference

Interference occurs when one unit's treatment assignment can affect another unit's outcome.

In a standard experiment, we often think of unit `i`'s outcome as depending only on its own treatment assignment, where $Y_i(Z_i)$.

Under interference, unit `i`'s outcome may depend on the full assignment vector, or $Y_i(Z)$.

Here, `Z` represents the treatment assignments for all units.

### Exposure Mapping

To make interference manageable, the paper uses an **exposure mapping**.

An exposure mapping summarizes the part of the treatment assignment that matters for a given unit, or $h_i(Z)$

For example, in a household experiment, a student's exposure may depend on:

- whether the student was directly treated,
- whether someone else in the household was treated.

Instead of tracking every detail of the full assignment vector, the exposure mapping tracks the treatment condition that is relevant for the causal question.

## Why Standard Randomization Tests Fail

In a classical randomized experiment, the sharp $H_0$ says every unit's outcome would be the same under treatment and control, so all missing potential outcomes are imputable.

With interference, a $H_0$ may only compare two exposure conditions. Some units may fall into other exposure conditions that are not part of the hypothesis.

The conditioning mechanism proposed in the paper can depend on the observed assignment. This allows the test to exclude uninformative units and focus on the units that matter.

In the paper's application, this leads to:

- more effective focal units,
- simpler permutation tests,
- higher statistical power,
- narrower confidence intervals.

## Conditioning Mechanisms

A conditioning mechanism chooses:

1. which units are included as focal units,
2. which treatment assignments are included in the randomization distribution.

The goal is to condition the test so that the outcomes needed for the test statistic can be inferred from the observed data under the $H_0$.

A valid conditioning mechanism ensures that, across the assignments used in the test, each focal unit either:

- stays within the exposure conditions being compared, or
- stays in an exposure condition that is unchanged and irrelevant to the contrast.

This preserves validity while allowing the test to focus on the units that are actually informative.

## Intuition

The intuition is simple:

> Only compare assignments where the outcomes needed for the test can be inferred from the observed experiment.

Instead of using every unit and every possible assignment, the method narrows the test to the part of the experiment where the null hypothesis gives enough information.

This is especially useful under interference because the observed assignment determines which units are informative for a given exposure contrast.

### Exposure Contrasts

The paper studies hypotheses that compare two exposure conditions.

For example, a spillover hypothesis may compare: test whether untreated individuals are affected by someone else in their household receiving treatment.

- $(0, 0)$: the unit is untreated and lives in an untreated household,
- $(0, 1)$: the unit is untreated and lives in a treated household.

The null hypothesis of no spillover says that these two exposure conditions lead to the same outcome, or $Y_i(0, 0) = Y_i(0, 1)$.

The proposed test works as follows:

1. Select one untreated focal unit from each household.
2. Compare outcomes between the two exposure groups.
3. Generate the randomization distribution by permuting the relevant exposures.
4. Compute the randomization p-value.

The important detail is that directly treated individuals are excluded from the focal set because they are not informative for the spillover contrast.


## Empirical Application

The authors apply the method to a randomized intervention targeting student absenteeism in Philadelphia.

The experiment involved multi-student households. In treated households, attendance information was sent to parents about one randomly selected student.

The researchers tested whether untreated students in treated households experienced spillover effects.

The proposed method found stronger evidence of spillovers than existing approaches. In the application:

- the existing method rejected the no-spillover null for 66% of sampled focal sets,
- the proposed method rejected it for 92% of sampled focal sets.

The estimated spillover effect was approximately a reduction of one school absence day.

## Main Takeaways

- Interference makes standard causal randomization tests difficult because many null hypotheses are not sharp.
- Exposure mappings help define meaningful treatment conditions under interference.
- Conditional randomization tests can remain valid if the conditioning mechanism is chosen carefully.
- Conditioning on the observed assignment can improve power.
- In two-stage experiments, the method can often be implemented as a simple permutation test.
- The approach is especially useful for testing spillover effects.

## Limitations

The method requires specification of an exposure mapping and a conditioning mechanism.

This means the validity and usefulness of the test depend on understanding the interference structure. In more complex networks, constructing a good conditioning mechanism may be difficult.

The paper also notes that conditioning mechanisms can produce a distribution of p-values across random focal sets, raising questions about interpretation and aggregation.
