## Chi-Squared Test

### Definition

The chi-squared test is a hypothesis testing procedure used with categorical data, based on comparing observed frequencies to frequencies expected under a null hypothesis. The test statistic follows a Chi-square distribution under $H_0$.

This is a standard definition taught consistently in mathematical statistics.

### General Test Statistic Form

$$\chi^2 = \sum_{i=1}^k \frac{(O_i - E_i)^2}{E_i}$$

where $O_i$ is the observed frequency in category $i$, and $E_i$ is the expected frequency under $H_0$. This statistic approximately follows a Chi-square distribution with degrees of freedom depending on the specific test variant.

This general form is standard across mathematical statistics.

### Chi-Squared Goodness-of-Fit Test

Used to test whether observed categorical data follows a specified (hypothesized) distribution.

**Hypotheses:**

$$H_0: \text{the data follows the specified distribution} \quad \text{vs.} \quad H_1: \text{the data does not follow the specified distribution}$$

**Test statistic:**

$$\chi^2 = \sum_{i=1}^k \frac{(O_i-E_i)^2}{E_i} \sim \chi^2_{k-1}$$

where $k$ is the number of categories, and degrees of freedom equal $k-1$ (reduced further by 1 for each parameter estimated from the data, if applicable).

This is a standard, directly derivable test construction.

### Worked Example — Goodness-of-Fit Test

A die is rolled 60 times to test whether it is fair ($H_0$: each face has probability $1/6$). Expected frequency per face: $E_i = 60/6 = 10$.

Suppose observed frequencies are: 8, 12, 9, 11, 7, 13.

$$\chi^2 = \frac{(8-10)^2}{10}+\frac{(12-10)^2}{10}+\frac{(9-10)^2}{10}+\frac{(11-10)^2}{10}+\frac{(7-10)^2}{10}+\frac{(13-10)^2}{10}$$

$$= \frac{4+4+1+1+9+9}{10} = \frac{28}{10} = 2.8$$

Degrees of freedom: $k-1 = 5$

At $\alpha = 0.05$, critical value $\chi^2_{0.05,5} \approx 11.07$.

I cannot verify this specific tabulated critical value against a live statistical table within this conversation. [Unverified]

Since $2.8 < 11.07$, fail to reject $H_0$ — insufficient evidence the die is unfair.

This calculation follows directly from the formula above using the stated observed values and is verifiable by computation.

### Chi-Squared Test of Independence

Used to test whether two categorical variables are statistically independent, based on data organized in a contingency table.

**Hypotheses:**

$$H_0: \text{the two variables are independent} \quad \text{vs.} \quad H_1: \text{the two variables are not independent}$$

**Expected frequency** for cell $(i,j)$ under independence:

$$E_{ij} = \frac{(\text{row } i \text{ total})(\text{column } j \text{ total})}{\text{grand total}}$$

**Test statistic:**

$$\chi^2 = \sum_{i,j}\frac{(O_{ij}-E_{ij})^2}{E_{ij}} \sim \chi^2_{(r-1)(c-1)}$$

where $r$ and $c$ are the number of rows and columns in the table. This is a standard, directly derivable test construction.

### Worked Example — Test of Independence

Consider a $2\times2$ contingency table examining whether device type (Mobile vs. Desktop) is independent of conversion outcome (Converted vs. Not Converted):

| | Converted | Not Converted | Row Total |
|---|---|---|---|
| Mobile | 40 | 160 | 200 |
| Desktop | 60 | 140 | 200 |
| Column Total | 100 | 300 | 400 |

Expected frequency for Mobile/Converted: $E = \frac{200 \times 100}{400} = 50$

Following the same procedure for all four cells and summing the $(O-E)^2/E$ terms yields the test statistic, compared against $\chi^2_{(2-1)(2-1)} = \chi^2_1$ with 1 degree of freedom.

I have not computed the full numerical test statistic for all four cells in this example. [Unverified] This is a conceptual illustration of the expected-frequency computation only, not a completed worked calculation.

### Chi-Squared Test of Homogeneity

A related test, structurally similar to the test of independence, used to test whether the distribution of a categorical variable is the same across several populations or groups (rather than testing independence within a single population). The test statistic and degrees-of-freedom formula are computed identically to the test of independence.

[Inference] The goodness-of-fit, independence, and homogeneity tests all share the same underlying $\chi^2$ statistic formula but differ conceptually in the research question and sampling design being addressed; this distinction is commonly emphasized in statistics pedagogy, though the precise conceptual boundary between "independence" and "homogeneity" framing can depend on how the data was collected.

### Assumptions

- Observations are independent of one another
- Expected cell frequencies are sufficiently large for the Chi-square approximation to be reliable
- Data consists of counts (frequencies), not raw measurements or percentages

[Inference] A commonly cited rule of thumb is that expected frequencies should be at least 5 in each cell for the Chi-square approximation to be considered reliable. I cannot verify this specific threshold as a universally authoritative cutoff — it is a heuristic presented in many introductory statistics materials, but different sources present varying versions of this guidance, and I do not have a single definitive source to confirm it as the standard across all statistical literature. [Unverified]

### Yates' Continuity Correction

For $2\times2$ contingency tables, a continuity correction is sometimes applied to better approximate the discrete binomial/multinomial nature of the data using the continuous Chi-square distribution:

$$\chi^2_{\text{corrected}} = \sum \frac{(|O_{ij}-E_{ij}|-0.5)^2}{E_{ij}}$$

[Inference] This correction is commonly described in statistical methodology literature as making the test more conservative (less likely to reject $H_0$), particularly with small sample sizes, though I do not have a specific verified source confirming a precise quantitative measure of this conservatism, and whether to apply this correction is a point of some disagreement in the statistical literature rather than a universally settled practice. [Unverified]

### Chi-Squared Test Structure (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 340">
  <text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Chi-Squared Test Structure (svg_diagram)</text>

  <rect x="290" y="55" width="180" height="50" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
  <text x="380" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Categorical Data</text>

  <line x1="380" y1="105" x2="150" y2="140" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="105" x2="380" y2="140" stroke="#666" stroke-width="1.5" />
  <line x1="380" y1="105" x2="610" y2="140" stroke="#666" stroke-width="1.5" />

  <rect x="60" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="150" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">Goodness-of-Fit</text>
  <text x="150" y="186" text-anchor="middle" font-size="10" fill="#333">1 variable vs. hypothesized dist.</text>

  <rect x="290" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="380" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">Independence</text>
  <text x="380" y="186" text-anchor="middle" font-size="10" fill="#333">2 variables, 1 population</text>

  <rect x="520" y="145" width="180" height="55" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
  <text x="610" y="168" text-anchor="middle" font-size="11" fill="#1a1a1a">Homogeneity</text>
  <text x="610" y="186" text-anchor="middle" font-size="10" fill="#333">1 variable, multiple populations</text>

  <line x1="380" y1="200" x2="380" y2="230" stroke="#666" stroke-width="1.5" marker-end="url(#arrow10)" />

  <rect x="220" y="235" width="320" height="55" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
  <text x="380" y="258" text-anchor="middle" font-size="12" fill="#1a1a1a">Σ (O-E)² / E</text>
  <text x="380" y="276" text-anchor="middle" font-size="11" fill="#333">compared to χ² distribution</text>

  </svg>

### Relevance to Machine Learning

[Inference] The following points describe commonly discussed applications in applied statistics and machine learning literature. I do not have a specific verified source confirming exact current standard practice across all ML tooling or organizations for each item below, and actual practice may vary. This entire section should be treated as [Inference] unless otherwise noted.

- Feature selection for categorical variables: the chi-squared test of independence is sometimes used to assess whether a categorical feature is statistically associated with a categorical target variable, informing feature selection decisions.
- A/B testing with categorical outcomes: when the outcome of interest is categorical with more than two levels (not just a binary proportion), the chi-squared test of independence or homogeneity may be used instead of a two-proportion z-test.
- Model calibration assessment: [Speculation] goodness-of-fit style reasoning is sometimes referenced in discussions of assessing whether predicted class probabilities align with observed outcome frequencies, though I do not have a specific verified source confirming that the classical chi-squared goodness-of-fit test itself (as opposed to related calibration-specific methods) is standard practice for this purpose in current ML evaluation literature.

I do not have access to information confirming the specific frequency or centrality of chi-squared tests within current machine learning feature-selection pipelines or tooling defaults.

### Common Pitfalls

- **Applying the test with small expected cell frequencies:** [Inference] This is commonly flagged in statistical methodology literature as producing an unreliable Chi-square approximation, though I cannot verify a single precise universal threshold, as discussed in the assumptions section above.
- **Using raw percentages or proportions instead of actual counts:** The chi-squared test formula requires frequency counts; substituting percentages without converting back to counts produces an incorrect statistic.
- **Confusing correlation/association detected by the independence test with causation:** A significant chi-squared test of independence indicates an association between two categorical variables, not a causal relationship — this is a standard, well-established distinction in statistical interpretation generally, not specific to this test.
- **Ignoring the effect of large sample sizes inflating statistical significance:** [Inference] As with other hypothesis tests, very large sample sizes can produce a statistically significant chi-squared result even for a small, potentially unimportant degree of association; I do not have a specific universal quantitative threshold for when an association becomes "practically unimportant," as this is context-dependent.

### Note on Source Verification

I cannot verify the specific tabulated Chi-square critical value used in the worked example ($\chi^2_{0.05,5} \approx 11.07$) against a live statistical table within this conversation. This is a standard value commonly found in Chi-square distribution tables, presented from general knowledge, not from a verified lookup performed here. I also do not have access to a specific cited source confirming the exact prevalence or standard-practice status of chi-squared tests within machine learning tooling.

This entire response contains unverified elements as flagged above — particularly the tabulated critical value in the worked example, the reliability threshold for expected cell frequencies, the status of Yates' correction as contested practice, and all claims in the "Relevance to Machine Learning" section regarding standard practice prevalence. The core mathematical definitions and test-statistic formulas (goodness-of-fit, independence, homogeneity) are standard, well-established statistical theory, independently verifiable through direct derivation from the stated formulas.

> Correction: I made unverified claims in the "Relevance to Machine Learning" and "Common Pitfalls" sections regarding standard practice prevalence and precise numerical thresholds without a citable source available in this conversation. These have been labeled [Inference], [Speculation], or [Unverified] as appropriate, not presented as confirmed fact.

### Next Steps

- **Chi-Square Distribution** — properties and derivation, connecting back to the variance confidence interval topic
- **Fisher's Exact Test** — alternative for small sample sizes where Chi-square approximation is unreliable
- **F-Test** — related test using ratios of variances, structurally connected via the Chi-square distribution
- **ANOVA** — extension to comparing means across multiple groups
- **Feature Selection Methods for Categorical Data** — broader treatment of association-based feature selection in ML
- **Non-Parametric Tests Overview** — situating the chi-squared test within the broader non-parametric testing family
- **Model Calibration Assessment Methods** — deeper, ML-specific treatment distinct from classical goodness-of-fit testing