## Introduction to Decision Making

### Overview

Decision making, in the context of modelling and simulation, refers to the formal analysis of choosing among alternative courses of action under conditions of uncertainty, competing objectives, or incomplete information. Simulation models are frequently built precisely to *support* decision making — generating performance estimates (queue lengths, costs, throughput, risk) that feed into a decision framework, rather than being useful as an end in themselves.

This topic introduces the conceptual and mathematical scaffolding — decision elements, decision environments, and decision criteria — that connects raw simulation output to an actual choice among alternatives.

### Elements of a Decision Problem

**Key Points**

Every formal decision problem can be decomposed into a common set of elements:

- **Decision maker**: the individual or entity choosing among alternatives.
- **Alternatives (actions)**: the set of choices available, denoted $a_1, a_2, \dots, a_n$.
- **States of nature**: the possible future conditions or events outside the decision maker's control, denoted $\theta_1, \theta_2, \dots, \theta_m$.
- **Outcomes**: the result of pairing a chosen alternative with a realized state of nature.
- **Payoff (or loss) function**: a numerical value $u(a_i, \theta_j)$ representing the desirability (or cost) of outcome $(a_i, \theta_j)$.
- **Decision criterion**: the rule used to select an alternative given the payoffs and any information about the states of nature.

These elements are typically organized into a **payoff table** (or payoff matrix), with alternatives as rows, states of nature as columns, and payoffs as entries.

### Decision Environments

**Key Points**

Decision problems are classified by how much is known about the states of nature:

- **Decision making under certainty**: the state of nature is known with certainty in advance. The problem reduces to simply selecting the alternative with the best payoff — no real "decision theory" is needed beyond optimization.
- **Decision making under risk**: the states of nature are unknown, but their probabilities $P(\theta_j)$ are known or can be estimated (e.g., from historical data or a simulation model's output distribution).
- **Decision making under uncertainty**: neither the states of nature nor their probabilities are known. This is the hardest and most conservative case, relying on structural criteria rather than probability-weighted averages.
- **Decision making under conflict**: outcomes depend not just on nature but on a rational adversary's choices — the domain of game theory, distinct from the other three environments.

Simulation is most commonly used to support decision making **under risk**: the simulation model generates an empirical distribution of outcomes for each alternative, which serves as the estimate of $P(\theta_j)$ or directly as a distribution of payoffs.

### Decision Criteria Under Uncertainty

**Key Points**

When probabilities of states of nature are unavailable, several classical criteria offer structurally different ways to choose:

- **Maximax (optimistic)**: choose the alternative whose *best possible* outcome is best overall.



  $$a^* = \arg\max_i \left( \max_j u(a_i, \theta_j) \right)$$
- **Maximin (pessimistic / Wald criterion)**: choose the alternative whose *worst possible* outcome is least bad.



  $$a^* = \arg\max_i \left( \min_j u(a_i, \theta_j) \right)$$
- **Minimax regret (Savage criterion)**: minimize the maximum possible "regret" — the difference between the payoff obtained and the best payoff that could have been obtained under that same state of nature.



  $$\text{Regret}(a_i, \theta_j) = \max_k u(a_k, \theta_j) - u(a_i, \theta_j)$$



  $$a^* = \arg\min_i \left( \max_j \text{Regret}(a_i, \theta_j) \right)$$
- **Hurwicz criterion**: a weighted compromise between maximax and maximin, using an optimism coefficient $\alpha \in [0,1]$:



  $$H(a_i) = \alpha \max_j u(a_i, \theta_j) + (1-\alpha) \min_j u(a_i, \theta_j)$$



  $$a^* = \arg\max_i H(a_i)$$
- **Laplace (principle of insufficient reason)**: when no information favors any state of nature over another, assume all states are equally likely and choose the alternative with the highest average payoff.



  $$a^* = \arg\max_i \left( \frac{1}{m}\sum_{j=1}^m u(a_i, \theta_j) \right)$$

**Example**

A facility manager is deciding server capacity for a queueing system, with payoff representing net benefit (revenue minus overprovisioning cost) under three demand states:

| Alternative | Low Demand | Medium Demand | High Demand |
| --- | --- | --- | --- |
| $c=1$ server | 40 | 40 | 20 |
| $c=2$ servers | 30 | 60 | 60 |
| $c=3$ servers | 10 | 45 | 90 |

- **Maximax**: best of each row's max → $c=3$ (90) wins.
- **Maximin**: worst of each row → $c=1$: 20, $c=2$: 30, $c=3$: 10 → $c=2$ wins (30 is the largest of the worst-case values).
- **Laplace**: row averages → $c=1$: 33.3, $c=2$: 50, $c=3$: 48.3 → $c=2$ wins narrowly.

Note that different criteria select different alternatives from the *same* payoff table — this is expected and reflects genuinely different attitudes toward risk, not an error in any one method.

### Decision Making Under Risk: Expected Value Criterion

**Key Points**

When probabilities $P(\theta_j)$ are known (or estimated from simulation output), the standard criterion is **Expected Monetary Value (EMV)**:

$$EMV(a_i) = \sum_{j=1}^{m} P(\theta_j) \, u(a_i, \theta_j)$$



$$a^* = \arg\max_i EMV(a_i)$$

**Example**

Using the payoff table above, suppose simulation-derived probabilities are $P(\text{Low})=0.3$, $P(\text{Medium})=0.5$, $P(\text{High})=0.2$:

$$EMV(c{=}1) = 0.3(40) + 0.5(40) + 0.2(20) = 12+20+4 = 36$$



$$EMV(c{=}2) = 0.3(30) + 0.5(60) + 0.2(60) = 9+30+12 = 51$$



$$EMV(c{=}3) = 0.3(10) + 0.5(45) + 0.2(90) = 3+22.5+18 = 43.5$$

$c=2$ servers maximizes expected value.

**Expected Value of Perfect Information (EVPI)** quantifies how much it would be worth to know the true state of nature in advance:

$$EVPI = \left[ \sum_j P(\theta_j) \max_i u(a_i,\theta_j) \right] - \max_i EMV(a_i)$$

Using the example: the "with perfect information" value is $0.3(40)+0.5(60)+0.2(90) = 12+30+18=60. So $EVPI = 60 - 51 = 9
. This represents the maximum amount rationally worth spending on additional forecasting or a more refined simulation study before committing to a capacity decision.

### Risk Attitude and Utility Theory

**Key Points**

EMV assumes the decision maker is risk-neutral — indifferent between a certain payoff and a gamble with the same expected value. This is often unrealistic, particularly for high-stakes decisions. **Utility theory** replaces raw monetary payoffs with a utility function $u(x)$ reflecting the decision maker's actual risk preference:

- **Risk-averse**: concave utility function; prefers a certain outcome over a gamble of equal expected value.
- **Risk-neutral**: linear utility function; EMV and expected utility give the same ranking.
- **Risk-seeking**: convex utility function; prefers the gamble over the certain equivalent.

Once payoffs are converted to utilities, the decision criterion becomes **Expected Utility**:

$$EU(a_i) = \sum_j P(\theta_j)\, u\big(x(a_i,\theta_j)\big)$$

[Inference] In practice, eliciting an individual decision maker's precise utility function is difficult and rarely done rigorously outside of specialized decision-analysis engagements, so most simulation-supported business decisions default to EMV with sensitivity analysis around it rather than full expected-utility modelling.

### Decision Trees

**Key Points**

Decision trees provide a graphical structure for sequential decision problems, where decisions and uncertain events alternate over time. Square nodes represent decision points (the decision maker chooses a branch); circular nodes represent chance events (nature "chooses" a branch according to probabilities).

Trees are solved by **backward induction** (also called "folding back"): starting from the terminal branches and working toward the root, compute the expected value at each chance node and select the maximum-value branch at each decision node.

### Decision Tree Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 320">
<text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Simple Capacity Decision Tree (svg_diagram)</text>
<rect x="40" y="140" width="30" height="30" fill="none" stroke="#333" stroke-width="2" />
<text x="55" y="130" text-anchor="middle" font-size="11" fill="#333">Decision</text>
<line x1="70" y1="150" x2="220" y2="80" stroke="#333" stroke-width="2" />
<text x="140" y="70" font-size="11" fill="#333">Add server</text>
<circle cx="230" cy="80" r="14" fill="none" stroke="#333" stroke-width="2" />
<line x1="70" y1="150" x2="220" y2="220" stroke="#333" stroke-width="2" />
<text x="140" y="235" font-size="11" fill="#333">Keep current</text>
<circle cx="230" cy="220" r="14" fill="none" stroke="#333" stroke-width="2" />
<line x1="244" y1="72" x2="400" y2="30" stroke="#333" stroke-width="1.5" />
<text x="300" y="20" font-size="10" fill="#555">High demand (0.2)</text>
<text x="420" y="34" font-size="11" fill="#333">Payoff: 60</text>
<line x1="244" y1="88" x2="400" y2="130" stroke="#333" stroke-width="1.5" />
<text x="300" y="120" font-size="10" fill="#555">Low demand (0.8)</text>
<text x="420" y="134" font-size="11" fill="#333">Payoff: 30</text>
<line x1="244" y1="213" x2="400" y2="180" stroke="#333" stroke-width="1.5" />
<text x="300" y="170" font-size="10" fill="#555">High demand (0.2)</text>
<text x="420" y="184" font-size="11" fill="#333">Payoff: 20</text>
<line x1="244" y1="227" x2="400" y2="280" stroke="#333" stroke-width="1.5" />
<text x="300" y="290" font-size="10" fill="#555">Low demand (0.8)</text>
<text x="420" y="284" font-size="11" fill="#333">Payoff: 40</text>
</svg>

### Sensitivity Analysis in Decision Models

**Key Points**

Because probabilities $P(\theta_j)$ and payoffs $u(a_i,\theta_j)$ are frequently estimates (often themselves derived from a simulation with its own sampling error), a robust decision analysis includes sensitivity analysis: systematically varying inputs to determine whether the optimal alternative changes.

A common technique is to plot EMV as a function of a single varying probability, identifying the **crossover point** where the optimal alternative switches — this crossover point indicates how much confidence the decision maker needs in the underlying probability estimate before committing to a given alternative.

### Connection to Simulation

**Key Points**

- Simulation models generate the empirical outcome distributions that populate $P(\theta_j)$ in a payoff table, particularly when states of nature correspond to complex, interacting system conditions that cannot be enumerated analytically.
- Comparing alternatives via simulation is itself a decision-making exercise: running multiple simulation configurations (e.g., different $c$ values in a queueing model) and comparing their output distributions using EMV or risk-adjusted criteria is a direct, practical application of this framework.
- **Ranking and selection procedures** (a distinct simulation-output-analysis topic) formalize this comparison statistically, addressing the fact that simulation-estimated payoffs carry sampling error that must be accounted for before declaring one alternative superior.

### Related Topics

- Decision Trees with Multi-Stage Sequential Decisions and Value of Information
- Utility Function Elicitation Methods
- Ranking and Selection Procedures for Comparing Simulated Alternatives
- Multi-Criteria Decision Analysis (MCDA) for Non-Monetary Objectives
- Bayesian Decision Theory and Updating Beliefs with New Data
- Sensitivity and Scenario Analysis in Simulation-Based Decision Support
- Game Theory and Decision Making Under Conflict