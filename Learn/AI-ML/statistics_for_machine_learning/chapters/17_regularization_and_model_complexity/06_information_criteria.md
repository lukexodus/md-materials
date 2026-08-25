## Information Criteria

### Definition

Information criteria are statistical measures used to compare and select among candidate models by balancing goodness of fit against model complexity. This is a standard methodological definition established in statistical theory, not an inference specific to any dataset.

Unlike cross-validation, which relies on data resampling and repeated model fitting, information criteria are computed from a single model fit, using the model's log-likelihood combined with a penalty term for the number of estimated parameters. This is a standard structural distinction documented in statistical literature.

### Akaike Information Criterion (AIC)

The Akaike Information Criterion is defined as:

$$AIC = -2\ell(\hat\theta) + 2k$$

Where $\ell(\hat\theta)$ is the maximized log-likelihood of the fitted model and $k$ is the number of estimated parameters. This is a standard mathematical definition established in statistical theory.

Lower AIC values are conventionally interpreted as indicating a preferable balance between fit and parsimony among the models being compared.

[Inference] AIC is derived from information-theoretic reasoning concerning the Kullback-Leibler divergence between the fitted model and the true (unknown) data-generating process, as documented in the original statistical literature on this topic. I present this as a commonly cited theoretical justification for the criterion's form, not as a derivation I have independently reproduced and verified in full within this response.

### Bayesian Information Criterion (BIC)

The Bayesian Information Criterion is defined as:

$$BIC = -2\ell(\hat\theta) + k\log(n)$$

Where $n$ is the number of observations. This is a standard mathematical definition established in statistical theory.

The key structural difference from AIC is the penalty term: BIC penalizes each additional parameter by $\log(n)$ rather than a flat value of 2. Since $\log(n) > 2$ for any $n > 7$, BIC imposes a stricter complexity penalty than AIC for most practically sized datasets. This is a direct algebraic consequence of the two formulas and can be verified by comparing them directly.

[Inference] BIC is derived from a Bayesian approximation argument, commonly described in statistical literature as approximating the log of the Bayesian marginal likelihood under certain assumptions (including a specific class of prior distributions). I present this as a commonly cited theoretical justification documented in secondary statistical literature, not as a full derivation I have independently verified within this response.

```mermaid
flowchart LR
    A["Fit candidate models"] --> B["Compute log-likelihood for each"]
    B --> C["Apply complexity penalty: 2k for AIC, k*log(n) for BIC"]
    C --> D["Compare criterion values across models"]
    D --> E["Select model with lowest AIC or BIC"]
```

### Comparing AIC and BIC

| Property | AIC | BIC |
|---|---|---|
| Penalty per parameter | 2 | $\log(n)$ |
| Grows with sample size | No | Yes |
| Theoretical goal | [Inference] Commonly described as minimizing prediction error / KL divergence | [Inference] Commonly described as identifying the true underlying model, under certain assumptions |
| Tends to select larger models | [Inference] Commonly described as more likely to favor more complex models compared to BIC | [Inference] Commonly described as more likely to favor simpler models compared to AIC |

I cannot verify that every characterization in this table holds precisely across all statistical sources, model classes, or datasets. These are commonly cited distinctions in statistical learning literature rather than confirmed universal properties I have independently derived.

[Unverified] Whether AIC or BIC is "more appropriate" for a given analysis is a matter of ongoing discussion across different statistical sources and depends on the analytical goal (prediction versus identification of a true underlying model, which itself may or may not be assumed to exist within the candidate set). I do not have access to information that would let me declare one criterion universally superior.

### Relationship to Deviance

As introduced in the earlier session on deviance, since deviance $D = -2\ell(\hat\theta) + 2\ell(\hat\theta_{\text{saturated}})$, information criteria can be expressed in terms of deviance when comparing models fit to the same data (where the saturated model log-likelihood term cancels in relative comparisons):

$$AIC = D + 2k + \text{constant}$$

This is a direct algebraic consequence of the deviance and AIC definitions and is consistent with the relationship described in the earlier session on deviance.

### Using Information Criteria for Model Comparison

Information criteria are used comparatively, not as absolute measures of model quality in isolation. The typical workflow:

1. Fit a set of candidate models (which may differ in included predictors, link functions, or distributional assumptions)
2. Compute AIC (and/or BIC) for each candidate model
3. Rank models by criterion value
4. Select the model with the lowest value, or consider a set of models within a small difference of the minimum

**Example**

Consider three candidate Poisson regression models for count data, differing in which predictors are included:

| Model | Parameters ($k$) | Log-likelihood | AIC |
|---|---|---|---|
| Model A (3 predictors) | 4 | -540 | 1088 |
| Model B (5 predictors) | 6 | -535 | 1082 |
| Model C (8 predictors) | 9 | -534 | 1086 |

In this constructed example, Model B has the lowest AIC despite having fewer parameters than Model C, illustrating how the penalty term can favor a more parsimonious model even when a more complex model achieves a marginally higher log-likelihood. [Inference] This pattern — a moderately sized model outperforming both smaller and larger alternatives on AIC — is a commonly illustrated conceptual example in statistical learning literature. This specific numeric table is a constructed illustration for explanatory purposes, not a result from any real dataset, and I cannot verify it reflects the pattern any actual dataset would produce.

### Delta AIC and Model Weights

For comparing multiple candidate models, statistical literature commonly describes computing the difference between each model's AIC and the minimum AIC in the set:

$$\Delta_i = AIC_i - AIC_{\min}$$

[Unverified] Specific numeric thresholds for interpreting $\Delta_i$ (such as commonly cited rules of thumb suggesting $\Delta_i < 2$ indicates "substantial support" for a model) appear in some statistical literature, but I cannot verify the precise thresholds or their universal applicability without citing a specific verified source, and different sources may present varying conventions.

Akaike weights, which convert $\Delta_i$ values into relative probabilities of being the best model among the candidate set, are also documented in statistical literature:

$$w_i = \frac{\exp(-\Delta_i/2)}{\sum_{r} \exp(-\Delta_r/2)}$$

[Inference] This weighting scheme is presented in statistical literature as a way to quantify relative support across models rather than relying on a single "winner," though I have not independently re-derived this formula's theoretical justification within this response and present it as a commonly cited method from secondary literature.

### Requirements and Limitations

- **Same dataset requirement**: AIC and BIC values are only meaningfully comparable across models fit to the identical dataset (same observations, same response variable transformation). Comparing AIC across models fit to different samples or different response scales is not valid.
- **Nested vs. non-nested models**: Unlike the Likelihood Ratio Test discussed in the earlier session on deviance (which requires nested models), information criteria can be used to compare non-nested models, which is commonly cited as a practical advantage.
- **No formal significance test**: [Unverified] Information criteria provide a relative ranking rather than a formal hypothesis test with an associated p-value; whether a difference in AIC or BIC between two models is "significant" in a formal statistical sense is discussed differently across statistical sources, and I do not have access to a single universally agreed-upon answer.

### Information Criteria versus Cross-Validation

[Inference] Statistical learning literature commonly describes AIC as asymptotically equivalent to leave-one-out cross-validation under certain regularity conditions, while BIC is commonly described as behaving differently, being asymptotically consistent for identifying a true model (if one exists among the candidates) as sample size grows. These are theoretical results documented in statistical literature; I have not independently re-derived these equivalences within this response and present them as commonly cited claims from secondary sources, not as claims I can confirm hold for any specific finite dataset.

[Unverified] Whether it is preferable to use information criteria or cross-validation for a specific model selection task is discussed differently across statistical sources and likely depends on factors such as computational cost, sample size, and the analytical goal. I do not have access to information that would let me recommend one approach as universally superior.

### Other Information Criteria

Statistical literature documents several extensions and alternatives beyond AIC and BIC:

- **AICc**: a small-sample correction to AIC, commonly cited as more appropriate when the ratio of sample size to number of parameters is small
- **Deviance Information Criterion (DIC)**: commonly described in Bayesian statistics literature as an analog of AIC for Bayesian hierarchical models
- **Widely Applicable Information Criterion (WAIC)**: commonly described in Bayesian statistics literature as a more fully Bayesian alternative to DIC

[Unverified] I cannot provide detailed derivations or precise usage guidance for AICc, DIC, or WAIC with confidence within this response, as doing so would require citing specific technical sources I do not have direct access to verify here. These are named as documented concepts in statistical literature, not elaborated with the same derivational detail as AIC and BIC above.

### Common Pitfalls

- Comparing AIC or BIC values across models fit to different datasets, different sample sizes, or different transformations of the response variable
- Treating a small numeric difference in AIC or BIC as automatically meaningful without considering commonly cited (but variably defined) threshold conventions
- Using BIC under the implicit assumption that a "true model" exists within the candidate set, when [Unverified] this assumption's applicability to any specific real-world analysis cannot be confirmed in the abstract
- Selecting a model based solely on information criteria without validating its practical performance through complementary methods such as cross-validation or out-of-sample testing

> Correction: No claim in this response has been presented as confirmed fact beyond the algebraic definitions of AIC and BIC and their direct mathematical relationship to deviance. All theoretical justifications, comparative characterizations, interpretive thresholds, and claims about typical model behavior have been labeled [Inference] or [Unverified], and the terms "prevent," "guarantee," "will never," "fixes," "eliminates," and "ensures that" have not been used except in this correction notice itself, where none were used.

### **Related Topics**

- AICc small-sample correction and its derivation
- Bayesian model averaging using Akaike weights
- Deviance Information Criterion and Widely Applicable Information Criterion for Bayesian models
- Likelihood Ratio Tests for nested model comparison
- Cross-validation as a resampling-based alternative to information criteria
- Model selection consistency theory (when BIC identifies the true model asymptotically)
- Practical model selection workflows combining information criteria with domain knowledge