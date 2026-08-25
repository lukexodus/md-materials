## Module 7: Adversarial Testing


### 7.1 Adversarial Testing Fundamentals

- Threat models for ML systems
- Attack taxonomy (evasion, poisoning, model extraction, inference)
- White-box vs black-box attacks
- Adversarial robustness definitions
- Security vs robustness testing
- Attack success metrics

### 7.2 Evasion Attacks - Image Domain

- Fast Gradient Sign Method (FGSM)
- Basic Iterative Method (BIM)
- Projected Gradient Descent (PGD)
- Carlini & Wagner (C&W) attacks
- DeepFool
- Universal Adversarial Perturbations
- Adversarial patch attacks

### 7.3 Evasion Attacks - Text Domain

- Character-level perturbations
- Word substitution attacks (TextFooler, BERT-Attack)
- Sentence paraphrasing attacks
- Grammar-based attacks
- Semantic-preserving perturbations
- Context-aware attacks
- Backdoor trigger insertion

### 7.4 Evasion Attacks - Tabular Data

- Feature manipulation attacks
- Budget-constrained attacks
- Realistic constraint satisfaction
- SHAP-based adversarial examples
- Gradient-based attacks for tabular data
- Query-efficient black-box attacks

### 7.5 Poisoning Attacks

- Training data poisoning
- Label flipping attacks
- Backdoor poisoning
- Clean-label poisoning
- Feature poisoning
- Federated learning poisoning
- Gradient-based poisoning

### 7.6 Model Extraction Attacks

- Equation-solving attacks
- Path-finding attacks
- Functionally equivalent extraction
- Knowledge distillation as extraction
- API query-based extraction
- Membership inference preparation

### 7.7 Privacy Attacks

- Membership inference attacks
- Attribute inference attacks
- Model inversion attacks
- Dataset reconstruction attacks
- Property inference attacks
- Differential privacy violation tests

### 7.8 Physical World Adversarial Testing

- Robust physical perturbations
- Adversarial patches in real world
- 3D adversarial objects
- Adversarial lighting and viewpoints
- Environmental condition attacks
- Sensor fusion attacks
- Real-world attack evaluation

### 7.9 Robustness Testing Frameworks

- Cleverhans
- Foolbox
- Adversarial Robustness Toolbox (ART)
- TextAttack
- RobustBench
- AutoAttack
- Custom adversarial testing suites

### 7.10 Defense Validation

- Adversarial training effectiveness
- Certified defense verification
- Input transformation defense tests
- Detection-based defense evaluation
- Ensemble defense robustness
- Defense against adaptive attacks
- Gradient masking detection

### 7.11 Out-of-Distribution Testing

- Natural distribution shift testing
- Synthetic OOD data generation
- Corruption robustness (noise, blur, weather)
- Domain shift testing
- Anomaly detection capability
- Open-set recognition
- Failure prediction under distribution shift

### 7.12 Model Backdoor Detection

- Trigger pattern identification
- Activation clustering analysis
- Neural cleanse techniques
- Fine-pruning defense validation
- Model scanning for trojans
- Backdoor trigger inversion
- Clean accuracy preservation verification

---

