## Mixed-Effects Models


Mixed-effects models account for both fixed effects (population-level parameters) and random effects (subject-specific deviations), making them essential for analyzing clustered, longitudinal, or hierarchical data.

**Key points:**

- Linear mixed-effects models use `lmer()` from the `lme4` package
- Random effects can include random intercepts, slopes, or both
- REML estimation is typically preferred over maximum likelihood
- Model specification requires careful consideration of correlation structures

The `lme4` package provides the primary implementation through `lmer()` for continuous outcomes and `glmer()` for generalized linear mixed models. Model specification uses formula notation where random effects are specified within parentheses: `(1|group)` for random intercepts, `(time|group)` for random intercepts and slopes.

Random effects capture within-cluster correlation that would violate independence assumptions in standard linear models. The correlation structure can be compound symmetry (random intercepts only) or more complex patterns (random slopes and intercepts).

Model fitting typically uses Restricted Maximum Likelihood (REML) estimation, which provides unbiased variance component estimates. The `summary()` function provides fixed effect estimates, random effect variances, and correlation parameters.

Model selection involves comparing nested models using likelihood ratio tests via `anova()`, though this requires ML rather than REML estimation. Information criteria (AIC, BIC) can compare non-nested models.

Alternative packages include `nlme` for more flexible correlation structures and `MCMCglmm` for Bayesian approaches. The `lmerTest` package adds p-values and degrees of freedom corrections to `lme4` output.

