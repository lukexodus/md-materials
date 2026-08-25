## Survival Analysis


Survival analysis examines time-to-event data, handling censored observations where the event of interest hasn't occurred by the study's end. R's survival analysis ecosystem centers around the `survival` package.

**Key points:**

- Survival objects are created using `Surv()` function
- Kaplan-Meier estimator provides non-parametric survival curve estimation
- Cox proportional hazards model is the most common regression approach
- Censoring mechanisms must be properly specified and understood

The `Surv()` function creates survival objects, specifying time and event status. Right censoring is most common, but left and interval censoring are also supported. The `survfit()` function implements Kaplan-Meier estimation, producing survival curves that can be visualized with `plot()` or enhanced plotting through `survminer` package.

Cox proportional hazards regression, implemented via `coxph()`, models the hazard ratio without specifying the baseline hazard distribution. The proportional hazards assumption can be tested using `cox.zph()`. Stratified Cox models handle violations of this assumption.

Parametric survival models assume specific distributions for survival times. The `survreg()` function fits accelerated failure time models using distributions like Weibull, exponential, or log-normal. Model comparison uses AIC or likelihood ratio tests.

Advanced topics include competing risks analysis through `cmprsk` package, frailty models for clustered data, and time-varying covariates. The `survminer` package enhances visualization capabilities significantly.

