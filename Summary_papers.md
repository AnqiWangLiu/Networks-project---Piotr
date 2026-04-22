# Networks-project - Piotr

## Peer Effects in Networks: A Survey - Bramoullé, Djebbari**
*Identification of peer effects through networks*\\
*If correlated effects have already been solved, can we still separately identify peer effects despite simultaneity?* i.e. if the observed characteristics and the network are exogeneous rel. to the outcome. $E(ε_i ∣ x,G)=0$.
Baseline model: 
$y_i = \alpha + \gamma x_i + \delta \frac{1}{d_i} \sum_{j \in N_i} x_j + \beta \frac{1}{d_i} \sum_{j \in N_i} y_j + \varepsilon_i$
where: 
y_i: individual i’s outcome
x_i: individual i’s observed characteristic
N_i: i’s peers
d_i=∣N_i∣: number of peers
γ: own-characteristic effect
δ: contextual peer effect
β: endogenous peer effect


## Section 3 — Correlated effects and networks

This is the paper’s central methodological section. It asks how to identify peer effects when the hard problem is present: **networks may be endogenous and unobserved characteristics may be correlated across connected individuals**. The authors organize the literature into four strategies: **random peers, random shocks, structural endogeneity, and panel data**. 

### 3.1 Random peers

If peers are randomly assigned, then an individual’s observed and unobserved traits are uncorrelated with those of peers. In network settings, this lets researchers identify **endogenous peer effects** using a peers-of-peers logic. But the paper stresses an important limitation: **contextual peer effects may still be confounded by omitted variables**. Randomly being assigned a smoker as a peer does not isolate the effect of smoking itself if smokers differ in other ways that matter. So random peers are strong for identifying peer outcome effects, but weaker for cleanly identifying the causal effect of peer characteristics. 

### 3.2 Random shocks

Instead of randomizing peers, researchers can randomize a **treatment or shock** that affects outcomes. In a linear-in-means framework, a randomized treatment can identify **both contextual and endogenous peer effects**, even when the network is endogenous, as long as the network itself is not changed by treatment. This is a particularly attractive strategy because it directly creates exogenous variation. The section also notes a related literature on treatment spillovers that relaxes parametric assumptions, though then identification depends heavily on what spillover structure is assumed.

### 3.3 Structural endogeneity

This literature explicitly models **network formation together with peer outcomes**. A common idea is that unobserved traits affect both who links to whom and how outcomes are generated, so researchers jointly estimate the network and the outcome equation. This can, in principle, correct for selection into networks. The paper sees this as promising and closely connected to the econometrics of network formation, but also notes that identification is less transparent and the approach is vulnerable to misspecification. 

The paper also mentions related approaches that do not fully model network formation, but instead impose structure on how unobservables correlate with observables. These can identify models under certain conditions, but they require strong knowledge about the correlation structure. 

### 3.4 Panel data

Panel data can help by introducing **individual fixed effects**, which absorb time-invariant unobserved heterogeneity. That should mitigate correlated effects. But the authors emphasize that this area is still **surprisingly underdeveloped** in network peer-effects research. Once the model is dynamic, complications multiply: the network may change over time, peer effects may be lagged, and peers’ time-invariant unobservables may still matter. So panel data are powerful in principle, but the methods are not yet mature. 

## Section 4 — Imperfect knowledge of the network

Section 4 relaxes a foundational assumption of much of the previous literature: that the relevant network is perfectly observed. The authors argue that this is often unrealistic because of **sampling, measurement error, and uncertainty about which network is actually relevant** for a given outcome. For example, self-reported friendship may not be the true network governing academic outcomes.

This matters because the identification strategy in Section 2 relies on correct exclusion restrictions. If the observed network misses real ties, then a supposed “peer of a peer who is not a peer” may actually be a direct peer, making the instrument invalid. Because real social networks are often clustered and transitive, this is not a minor issue.

The paper reviews several responses. One is to combine **multiple network dimensions** so that the excluded nodes are more plausibly not direct contacts, such as combining family and neighborhood networks or spouse and coworker networks. Another is a growing theoretical literature showing that peer effects may still be identified with **very imperfect network information**, and in some panel cases even with no direct network data if the network is time-invariant. There is also work on cross-sectional estimation when the researcher can recover the probability distribution of the network rather than the network itself.

The section closes by highlighting **network sampling and measurement error** as major unresolved issues. Sampled networks can invalidate standard friends-of-friends instruments, and degree censoring can substantially bias estimates. The authors see this whole area as promising but still underresearched.

## Comparison and evaluation of the techniques and methodologies

Yes, the paper covers several distinct methods, and a big part of its value is comparing them.

### 1. Network-based identification via peers-of-peers

This is the paper’s foundational technique. It is elegant because it uses **structure already present in the network** rather than requiring an experiment. Its main strength is that it directly addresses the reflection problem. Its weakness is that it only works well once correlated effects are already under control, and it is fragile to **network mismeasurement**.

**Best when:** the network is well measured and plausibly exogenous, and there are enough intransitive links.

### 2. Group-size identification

This is a clever alternative in group settings. It shows that even without network holes, identification can come from **variation in group size** under exclusive averaging. Its strength is that it can work in more aggregated settings. Its weakness is that the identifying variation can be weak, especially in large groups, and it depends on a strong assumption that the structural parameters do not vary with group size. 

**Best when:** the data are organized in groups rather than networks, and group sizes vary meaningfully.

### 3. Error-restriction methods

These identify peer effects through assumptions on the covariance structure of unobservables. Their strength is that they can work even when characteristic-based instruments are weak or unavailable. Their weakness is obvious: the assumptions are often hard to justify empirically, especially when peer selection is endogenous. 

**Best when:** the setting is experimental or otherwise makes uncorrelated errors plausible.

### 4. Random peers

This is one of the cleaner causal strategies. It breaks the link between an individual and peers’ unobservables. The paper evaluates it positively for identifying **endogenous peer effects**, but critically for contextual effects because of omitted-variable concerns.

**Best when:** assignment to peers is truly random and the researcher’s main interest is peer outcomes rather than peer attributes.

### 5. Random shocks / randomized treatments

This is arguably the strongest empirical design in the survey. It creates exogenous variation directly and can identify both contextual and endogenous effects in linear-in-means settings, even with endogenous networks if treatment does not reshape the network. The tradeoff is that the result is **model-dependent** and may not generalize to other peer-effect specifications. 

**Best when:** there is a credible randomized intervention and the linear-in-means framework is reasonable.

### 6. Structural endogeneity models

These are the most ambitious methods. They try to model **how networks form and how outcomes are jointly produced**. Their strength is that they tackle the source of endogeneity head-on. Their weakness is complexity: they rely on stronger functional-form and behavioral assumptions, can be hard to identify transparently, and may be sensitive to misspecification.

**Best when:** the researcher has rich data and a strong theoretical reason to model network formation explicitly.

### 7. Panel-data approaches

These are attractive because fixed effects can remove stable omitted variables. The paper sees them as promising but underdeveloped. Their strength is control for time-invariant heterogeneity; their weakness is that dynamic networks and lagged interactions make the econometrics much harder. 

**Best when:** repeated observations are available and the researcher can plausibly model network and outcome dynamics.

### 8. Methods for imperfectly observed networks

This is the newest frontier in the survey. Its strength is realism: it acknowledges that network data are often incomplete or wrong. The paper is cautiously optimistic, but also clear that many standard instruments break under sampling and measurement error.

**Best when:** the network is noisy, incomplete, or only probabilistically observed.

## Bottom-line evaluation

The paper’s overall judgment is:

* **Most convincing for causal identification:** randomized designs, especially **random shocks**. 
* **Most conceptually important theoretical contribution:** the **network-structure/peers-of-peers** identification strategy that solves the reflection problem under intransitivity. 
* **Most ambitious but assumption-heavy:** **structural endogeneity** models.
* **Most promising but still immature:** **panel-data** methods and **imperfect-network** methods.

