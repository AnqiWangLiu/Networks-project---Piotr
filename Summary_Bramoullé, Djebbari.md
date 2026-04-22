# Peer Effects in Networks: A Survey - Bramoullé, Djebbari

### Identification of peer effects through networks

*If correlated effects have already been solved, can we still separately identify peer effects despite simultaneity?* i.e. if the observed characteristics and the network are exogeneous rel. to the outcome. $E(ε_i ∣ x,G)=0$.

Baseline model:

$y_i = \alpha + \gamma x_i + \delta \frac{1}{d_i} \sum_{j \in N_i} x_j + \beta \frac{1}{d_i} \sum_{j \in N_i} y_j + \varepsilon_i$
where: 

y_i: individual i’s outcome

x_i: individual i’s observed characteristic

N_i: i’s peers

d_i=∣N_i∣: number of peers 

γ: own-characteristic effect 

δ: contextual peer effect: my outcome changes bc peers have certain characteristics

β: endogenous peer effect: my outcome changes bc my pees' outcomes change.

But note that the peers' outcomes and my own outcomes are jointly determined.

---

*Main Identification Assumptions*
1. Exogeneity of characteristics and the network

$E(ε_i∣x,G)=0$ 
i.e. 
- no omitted variables correlated with both outcomes and peer structure
- no endogenous friendship formation affecting the error term
- no common shocks left in the residual that line up with the network

2. No isolated individuals: every individual has at least 1 peer
3. Non-degenerate parameter condition $\delta + \gamma \beta \neq 0$
   This rules out a knife-edge case where contextual and endogenous effects cancel each other out in the reduced form.

4. Network structure must be informative
   For identification, the network must have enough structure: the data must contain enough distinction between:
- own effects
- peer effects
- peer-of-peer effects

   
---

*Identification strategy*

In a network, a peer's peer who is not my peer can move my peer's outcome w/o moving mine.

If A and B are friends, B is friends with C and A is not friends with C. C characteristics can affect B outcome, B outcome affects A outcome. But C characteristics do not affect A if only direct peers matter. So C's characteristics is used as an excluded source of variation, as an IV.

If networks are completely transitive, we cannot use it as IV. So, identification exploits holes in the structure, the missing direct link that keeps C out of A's own outcome equation. It allows us to separate contextual effects from endogeneous effects.

The theorem intuitively:
- I: own effects
- G: direct peer effects
- $G^2$: Peer of peer structure
- $G^3$ = extra variation needed once community fixed effects are included

- model (1) is identified iff $I$, $G$, and $G^2$ are linearly independent
- with group fixed effects, model (2) is identified iff $I$, $G$, $G^2$, and $G^3$ are linearly independent
  
If these matrices are too similar, the model cannot separate the different channels.

---

*Reduced-form intuition*

The paper uses the expansion:

$$
(I - \beta G)^{-1} = I + \beta G + \beta^2 G^2 + \cdots
$$

This shows that expected outcomes depend on:

- peers’ characteristics
- peers’ peers’ characteristics
- peers’ peers’ peers’ characteristics
- and so on

Once $\beta \neq 0$, characteristics and shocks propagate through the network.

So someone two steps away affects me indirectly through my peers, making $G^2 x$ informative.

Logic:

- peers influence each other
- influence spreads through the network
- distance-2 variables trace that spread

The same basic logic can extend to models where:

- peer influence is nonlinear
- peer effects are heterogeneous
- outcomes are discrete
- multiple outcomes interact

Bottom line: 

> If only direct peers directly affect me, then variables attached to agents at distance 2 or more can be valid exclusion restrictions.

But there are added complications

- fixed-point multiplicity
- equilibrium selection problems
- stronger assumptions for estimation

---

**Group interactions: when things change**

*Inclusive averaging*

If everyone in a group affects everyone else and averages are computed over the whole group, then:

$$
G^2 = G
$$

In that case, peers-of-peers are just peers again: the network-IV logic disappears, and you cannot separately identify contextual and endogenous peer effects.

*Exclusive averaging*

If peer averages are computed over **everyone else** in the group, then identification can come from **variation in group size**.

The intuition is:

- in small groups, excluding yourself from the average creates a mechanical negative relationship between your own characteristic and the peer average
- this changes outcome dispersion
- the strength of that effect varies with group size

That approach relies on assuming that:

- $\beta$
- $\gamma$
- $\delta$

do **not** vary with group size.

---

**Another strategy: Ientification through assumptions on the error terms**

Instead of using excluded network variables, impose assumptions on the residuals, such as uncorrelated errors. Then covariance restrictions can help identify peer effects.

Limitation: compared with the network-based IV logic, this approach is more fragile.

- residuals are likely correlated
- people sort into groups and networks endogenously

**Important: identifying peer effects is not the same as identifying mechanisms**

Even if you identify $\beta$ and $\delta$, you usually **do not identify the underlying mechanism**.

The same reduced-form equation could come from:

- complementarities
- conformity
- social learning
- status concerns
- risk sharing
- other behavioral motives

Thus:

- identifying the regression is not the same as identifying preferences
- identifying peer effects is not the same as identifying welfare effects

---

*Summary: Main strategy*

1. write the peer-effects model on the network
2. recognize that peers’ outcomes are endogenous
3. use characteristics of **peers of peers who are not peers** as instruments
4. these variables shift peers’ outcomes but are excluded from the individual’s equation
5. this separates:
   - contextual peer effects ($\delta$)
   - endogenous peer effects ($\beta$)

---

### Correlated effects and networks
How to identify peer effects when **networks may be endogenous and unobserved characteristics may be correlated across connected individuals**. 

The authors organize the literature into four strategies: **random peers, random shocks, structural endogeneity, and panel data**. 

**1. Random peers**
If peers are randomly assigned, then who you are connected to is exogenous. This is very useful for identifying endogenous peer effects in networks, because characteristics of peers-of-peers can serve as valid instruments for peers’ outcomes. But random assignment of peers does not necessarily identify the causal effect of a specific peer characteristic. For example, if being assigned a smoker lowers grades, that does not prove smoking itself is the cause: smokers may also differ in other relevant ways, such as ability, study habits, or drinking behavior. In that case, the estimated contextual effect of peer smoking mixes the effect of smoking with the effect of omitted peer characteristics. So random peers are strong for identifying the effect of peers’ outcomes, but weaker for cleanly isolating the causal effect of peers’ observed characteristics.

**2. Random shocks**

Instead of randomizing peers, researchers can randomize a **treatment or shock** that affects outcomes. In a linear-in-means framework, a randomized treatment can identify **both contextual and endogenous peer effects**, even when the network is endogenous, as long as the network itself is not changed by treatment. This is a particularly attractive strategy because it directly creates exogenous variation. 

**3. Structural endogeneity**

This literature models **network formation together with peer outcomes**. A common idea is that unobserved traits affect both who links to whom and how outcomes are generated, so researchers jointly estimate the network and the outcome equation. This can, in principle, correct for selection into networks. The paper sees this as promising and closely connected to the econometrics of network formation, but also notes that identification is less transparent and the approach is vulnerable to misspecification. 

The paper also mentions related approaches that do not fully model network formation, but instead impose structure on how unobservables correlate with observables. These can identify models under certain conditions, but they require strong knowledge about the correlation structure. 

**4. Panel data**

Panel data can help by introducing **individual fixed effects**, which absorb time-invariant unobserved heterogeneity. That should mitigate correlated effects. But the authors emphasize that this area is still **surprisingly underdeveloped** in network peer-effects research. Once the model is dynamic, complications multiply: the network may change over time, peer effects may be lagged, and peers’ time-invariant unobservables may still matter. 

---

### Imperfect knowledge of the network

In this section, we relax: that the relevant network is perfectly observed. The authors argue that this is often unrealistic because of **sampling, measurement error, and uncertainty about which network is actually relevant** for a given outcome. This matters because the identification strategy above relies on correct exclusion restrictions. If the observed network misses real ties, then a supposed “peer of a peer who is not a peer” may actually be a direct peer, making the instrument invalid. 

The paper reviews several responses. One is to combine **multiple network dimensions** so that the excluded nodes are more likely that are not direct contacts, such as combining family and neighborhood networks. This makes the peers-of-peers instrument more credible because the indirect contact is less likely to also affect the person directly. Another is a growing theoretical literature showing that peer effects may still be identified with **very imperfect network information**, and in some panel cases even with no direct network data if the network is time-invariant. There is also work on cross-sectional estimation when the researcher can recover the probability distribution of the network rather than the network itself.

Major unsolved issues: **network sampling and measurement error**. Sampled networks can invalidate standard friends-of-friends instruments, and degree censoring can substantially bias estimates.

---

### Summary: Comparison and evaluation of the techniques and methodologies

**1. Network-based identification via peers-of-peers**

This is the paper’s foundational technique. It is elegant because it uses **structure already present in the network** rather than requiring an experiment. Its main strength is that it directly addresses the reflection problem. Its weakness is that it only works well once correlated effects are already under control, and it is fragile to **network mismeasurement**.

**Best when:** the network is well measured and plausibly exogenous, and there are enough intransitive links.

**2. Group-size identification**

Alternative for group settings: It shows that even without network holes, identification can come from **variation in group size** under exclusive averaging. Its strength is that it can work in more aggregated settings. Its weakness is that the identifying variation can be weak, especially in large groups, and it depends on a strong assumption that the structural parameters do not vary with group size. 

**Best when:** the data are organized in groups rather than networks, and group sizes vary meaningfully.-

**3. Error-restriction methods**

These identify peer effects through assumptions on the covariance structure of unobservables. Their strength is that they can work even when characteristic-based instruments are weak or unavailable. Their weakness is obvious: the assumptions are often hard to justify empirically, especially when peer selection is endogenous. 

**Best when:** the setting is experimental or otherwise makes uncorrelated errors plausible.

**4. Random peers**

It breaks the link between an individual and peers’ unobservables. The paper evaluates it positively for identifying **endogenous peer effects**, but critically for contextual effects because of omitted-variable concerns.

**Best when:** assignment to peers is truly random and the researcher’s main interest is peer outcomes rather than peer attributes.

**5. Random shocks / randomized treatments**

It creates exogenous variation directly and can identify both contextual and endogenous effects in linear-in-means settings, even with endogenous networks if treatment does not reshape the network. The tradeoff is that the result is **model-dependent** and may not generalize to other peer-effect specifications. 

**Best when:** there is a credible randomized intervention and the linear-in-means framework is reasonable.

**6. Structural endogeneity models**

They try to model **how networks form and how outcomes are jointly produced**. Their strength is that they tackle the source of endogeneity head-on. Their weakness is complexity: they rely on stronger functional-form and behavioral assumptions, can be hard to identify transparently, and may be sensitive to misspecification.

**Best when:** the researcher has rich data and a strong theoretical reason to model network formation explicitly.

**7. Panel-data approaches**

Fixed effects can remove stable omitted variables. The paper sees them as promising but underdeveloped. Their strength is control for time-invariant heterogeneity; their weakness is that dynamic networks and lagged interactions make the econometrics much harder. 

**Best when:** repeated observations are available and the researcher can plausibly model network and outcome dynamics.

**8. Methods for imperfectly observed networks**

Frontier methods. Its strength is realism: it acknowledges that network data are often incomplete or wrong. The paper is cautiously optimistic, but also clear that many standard instruments break under sampling and measurement error.

**Best when:** the network is noisy, incomplete, or only probabilistically observed.

---

### Bottom-line evaluation

The paper’s overall judgment is:

* **Most convincing for causal identification:** randomized designs, especially **random shocks**. 
* **Most conceptually important theoretical contribution:** the **network-structure/peers-of-peers** identification strategy that solves the reflection problem under intransitivity. 
* **Most ambitious but assumption-heavy:** **structural endogeneity** models.
* **Most promising but still immature:** **panel-data** methods and **imperfect-network** methods.

