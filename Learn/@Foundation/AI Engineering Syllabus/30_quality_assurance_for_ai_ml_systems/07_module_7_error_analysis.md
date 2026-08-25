## Module 7: Error Analysis


### 7.1 Error Analysis Fundamentals

- Purpose: Understand where and why model fails
- Goes beyond aggregate metrics
- Identifies patterns in errors
- Guides improvement directions
- Iterative process

### 7.2 Error Analysis Process

**Step 1: Collect Errors**

- Run model on test/validation set
- Identify misclassified examples
- Separate by error type
- Sample if too many errors (stratified sampling)

**Step 2: Categorize Errors**

- Group errors by characteristics
- Multiple categorization schemes possible
- Quantify each error category
- Prioritize by frequency and impact

**Step 3: Analyze Root Causes**

- Why did the model fail?
- Data issue vs model issue?
- Systematic patterns?
- Edge cases vs common cases?

**Step 4: Generate Insights**

- What can be improved?
- Data collection priorities
- Feature engineering ideas
- Architecture modifications
- Training procedure changes

**Step 5: Implement and Iterate**

- Apply fixes
- Measure impact
- Repeat analysis

### 7.3 Error Categorization Strategies

**By Error Type (Classification):**

- False Positives (FP) vs False Negatives (FN)
- Confusion between specific classes
- Multi-class: confusion matrix analysis
- Per-class error rates

**By Difficulty:**

- Easy errors (obvious mistakes)
- Hard errors (ambiguous cases)
- Adversarial errors (out-of-distribution)

**By Data Characteristics:**

- Image quality (blurry, low resolution)
- Object size (small, large, occluded)
- Text length (short, long)
- Rare vs common examples
- In-distribution vs out-of-distribution

**By Model Confidence:**

- High confidence errors (overconfident mistakes)
- Low confidence errors (uncertain predictions)
- Calibration issues

**By Feature Space:**

- Cluster errors in embedding space
- Identify problematic regions
- Find underrepresented areas

### 7.4 Classification Error Analysis

**Confusion Matrix Analysis:**

- Diagonal: correct predictions
- Off-diagonal: confusions
- Which classes are confused?
- Symmetric vs asymmetric confusions

**Per-Class Metrics:**

- Precision, recall, F1 per class
- Identify worst-performing classes
- Understand class-specific issues

**False Positive Analysis:**

- What triggers false alarms?
- Background vs object confusion
- Similar-looking classes
- Context misinterpretation

**False Negative Analysis:**

- What is missed by the model?
- Rare examples
- Partial occlusion
- Poor image quality
- Underrepresented in training

**Example Analysis Process:**

```
1. Generate confusion matrix
2. Identify most confused pairs (class A ↔ class B)
3. Sample 50 examples from each confusion
4. Manually inspect and categorize
5. Find common patterns
6. Document insights
```

### 7.5 Object Detection Error Analysis

**Localization Errors:**

- Bounding box too large/small
- Bounding box misaligned
- IoU distribution analysis

**Classification Errors:**

- Object detected but wrong class
- Similar object confusion

**Localization + Classification:**

- Both bbox and class wrong
- Separate analysis for each

**Missed Detections (False Negatives):**

- Small objects missed
- Occluded objects
- Truncated objects
- Rare classes

**False Detections (False Positives):**

- Background regions
- Duplicate detections
- Partial objects

**Error Analysis Tools:**

- IoU thresholding analysis
- Precision-recall curves per class
- Size-stratified analysis (small, medium, large)
- TIDE (Tool for Instance Detection Errors)

### 7.6 Segmentation Error Analysis

**Boundary Errors:**

- Rough boundaries
- Missing fine details
- Over/under-segmentation

**Semantic Errors:**

- Pixel misclassification
- Confusion between classes
- Context errors

**Instance Errors:**

- Merged instances
- Split instances
- Missed instances

**Metrics for Analysis:**

- Per-class IoU
- Boundary F1 score
- Pixel accuracy by region
- Error maps (visualizations)

### 7.7 Regression Error Analysis

**Residual Analysis:**

- Plot predicted vs actual
- Identify systematic bias
- Check for heteroscedasticity
- Outlier detection

**Error Distribution:**

- Histogram of errors
- Normal distribution assumption
- Skewness in errors

**Feature-Specific Analysis:**

- Errors by feature ranges
- High error regions
- Interaction effects

**Metrics:**

- MAE, MSE, RMSE by subgroups
- Quantile-based analysis
- Relative errors vs absolute

### 7.8 Error Analysis Techniques

**Manual Inspection:**

- Sample errors randomly
- Review systematically
- Take notes on patterns
- Quantify observed issues
- Time-consuming but insightful

**Automated Analysis:**

- Cluster errors in feature space
- Statistical tests for patterns
- Subgroup analysis
- Correlation with metadata

**Slice-Based Evaluation:**

- Define data slices (subpopulations)
- Evaluate model on each slice
- Example slices:
    - By demographics
    - By input characteristics
    - By data source
    - By time period

**Embedding Space Analysis:**

- Project errors into 2D/3D (t-SNE, UMAP)
- Visualize error distribution
- Identify problematic clusters
- Compare to correct predictions

**Attention/Saliency Analysis:**

- Where does model look?
- Grad-CAM, attention weights
- Correct vs incorrect attention patterns
- Spurious correlations

### 7.9 Error Analysis Tools and Frameworks

**Visualization Tools:**

- TensorBoard Projector
- Embedding visualization
- Confusion matrix visualizations
- Error distribution plots

**Analysis Frameworks:**

- Spotlight (Renumics) - interactive error analysis
- Evidently AI - data and model monitoring
- Manifold (Uber) - visual debugging
- Netron - model visualization
- Error Analysis (Microsoft) - interactive tool

**Statistical Tools:**

- Pandas for data manipulation
- Seaborn for visualizations
- Scipy for statistical tests
- Scikit-learn metrics

### 7.10 Example Error Analysis Workflow

**Image Classification Example:**

1. Generate predictions on validation set
2. Compute confusion matrix
3. Identify top 3 confused class pairs
4. Sample 100 errors for each pair
5. Manual inspection with notes
6. Categorization:
    - 40% similar visual appearance
    - 25% poor image quality
    - 20% mislabeled ground truth
    - 15% partial object view
7. Insights:
    - Collect more data for visually similar classes
    - Add data augmentation for image quality
    - Review labeling guidelines
    - Add context features for partial views
8. Implement changes and measure impact

### 7.11 Common Error Patterns and Solutions

**Data Quality Issues:**

- **Error:** Model performs poorly on specific subgroups
- **Analysis:** Identify underrepresented groups
- **Solution:** Collect more balanced data

**Overfitting:**

- **Error:** Low training error, high test error
- **Analysis:** Check train vs test performance gap
- **Solution:** Regularization, more data, simpler model

**Underfitting:**

- **Error:** High training and test error
- **Analysis:** Model too simple for task
- **Solution:** Increase capacity, better features

**Class Imbalance:**

- **Error:** Poor performance on minority classes
- **Analysis:** Per-class metrics
- **Solution:** Resampling, class weights, focal loss

**Data Leakage:**

- **Error:** Unrealistically high performance
- **Analysis:** Feature importance shows suspicious features
- **Solution:** Remove leaky features, fix data pipeline

**Distribution Shift:**

- **Error:** Performance degrades over time
- **Analysis:** Compare train/test distributions
- **Solution:** Regular retraining, domain adaptation

**Spurious Correlations:**

- **Error:** Model uses shortcuts
- **Analysis:** Attention analysis, feature importance
- **Solution:** Data augmentation, remove confounders

### 7.12 Documenting Error Analysis

**Error Analysis Report Structure:**

1. **Executive Summary**
    
    - Overall error rate
    - Key findings
    - Recommendations
2. **Methodology**
    
    - Dataset used
    - Sampling strategy
    - Analysis approach
3. **Quantitative Analysis**
    
    - Confusion matrix
    - Per-class metrics
    - Error category distribution
4. **Qualitative Analysis**
    
    - Example errors with images/text
    - Common patterns identified
    - Root cause hypotheses
5. **Recommendations**
    
    - Prioritized action items
    - Expected impact
    - Implementation complexity
6. **Appendix**
    
    - Additional visualizations
    - Statistical tests
    - Code snippets

### 7.13 Error Analysis Best Practices

- Perform error analysis early and often
- Use both quantitative and qualitative methods
- Involve domain experts in analysis
- Sample errors systematically
- Document insights immediately
- Track errors over iterations
- Share findings with team
- Connect errors to metrics that matter
- Don't just fix symptoms, find root causes
- Measure impact of fixes

### 7.14 Error Analysis for Fairness

- Analyze errors by demographic groups
- Check for disparate error rates
- Identify bias sources
- Intersectional analysis (multiple attributes)
- Balance fairness and overall performance
- Document fairness considerations

### 7.15 Continuous Error Analysis

- Monitor errors in production
- A/B test error patterns
- User feedback analysis
- Automated error detection pipelines
- Regular error analysis reviews
- Track error trends over time

---

