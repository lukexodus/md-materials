## Form Validation System (DOM/JS)


### Validation Timing Strategies

#### On Submit Validation

Validates all fields when the form is submitted. Prevents submission if validation fails by calling `event.preventDefault()`. This approach minimizes interruptions during data entry but delays error feedback until the user attempts to submit.

```javascript
form.addEventListener('submit', (e) => {
  e.preventDefault();
  if (validateForm()) {
    form.submit();
  }
});
```

#### On Blur Validation

Validates individual fields when they lose focus. Provides immediate feedback after the user completes a field without interrupting active typing. Common pattern for progressive validation.

```javascript
input.addEventListener('blur', () => {
  validateField(input);
});
```

#### On Input Validation

Validates as the user types. Provides real-time feedback but can be intrusive. Often combined with debouncing to reduce validation frequency.

```javascript
input.addEventListener('input', debounce(() => {
  validateField(input);
}, 300));
```

#### Hybrid Approaches

Combines multiple timing strategies. Common pattern: validate on blur for initial feedback, then switch to on-input validation after first error to help user correct issues in real-time.

### Validation Rule Implementation

#### Built-in HTML5 Validation

Native browser validation using HTML attributes. Limited customization but zero JavaScript required.

```javascript
// Accessing validation state
input.validity.valueMissing // required field is empty
input.validity.typeMismatch // type doesn't match (email, url, etc.)
input.validity.patternMismatch // doesn't match pattern attribute
input.validity.tooLong // exceeds maxlength
input.validity.tooShort // below minlength
input.validity.rangeUnderflow // below min
input.validity.rangeOverflow // above max
input.validity.stepMismatch // doesn't match step attribute
input.validity.valid // overall validity
input.validationMessage // browser's error message
```

Disable default UI and handle manually:

```javascript
form.noValidate = true; // or <form novalidate> in HTML
```

#### Custom Validation Rules

Object-based validation configuration:

```javascript
const rules = {
  username: {
    required: true,
    minLength: 3,
    maxLength: 20,
    pattern: /^[a-zA-Z0-9_]+$/,
    custom: (value) => {
      if (value.includes('admin')) {
        return 'Username cannot contain "admin"';
      }
      return true;
    }
  },
  email: {
    required: true,
    type: 'email',
    custom: async (value) => {
      // [Inference] Async validation typically checks server-side constraints
      const available = await checkEmailAvailability(value);
      return available || 'Email already registered';
    }
  }
};
```

#### Validation Function Patterns

**Synchronous validation:**

```javascript
function validateField(input, rule) {
  const value = input.value.trim();
  
  if (rule.required && !value) {
    return { valid: false, message: 'This field is required' };
  }
  
  if (rule.minLength && value.length < rule.minLength) {
    return { 
      valid: false, 
      message: `Minimum ${rule.minLength} characters required` 
    };
  }
  
  if (rule.pattern && !rule.pattern.test(value)) {
    return { valid: false, message: 'Invalid format' };
  }
  
  if (rule.custom) {
    const result = rule.custom(value);
    if (result !== true) {
      return { valid: false, message: result };
    }
  }
  
  return { valid: true, message: '' };
}
```

**Asynchronous validation:**

```javascript
async function validateFieldAsync(input, rule) {
  const syncResult = validateField(input, rule);
  if (!syncResult.valid) return syncResult;
  
  if (rule.custom && rule.custom.constructor.name === 'AsyncFunction') {
    const result = await rule.custom(input.value);
    if (result !== true) {
      return { valid: false, message: result };
    }
  }
  
  return { valid: true, message: '' };
}
```

### Error Display Mechanisms

#### Inline Error Messages

Displays errors adjacent to the invalid field. Most common pattern for immediate, contextual feedback.

```javascript
function showError(input, message) {
  const errorElement = input.nextElementSibling;
  if (errorElement?.classList.contains('error-message')) {
    errorElement.textContent = message;
    errorElement.style.display = 'block';
  }
  input.classList.add('invalid');
  input.setAttribute('aria-invalid', 'true');
  input.setAttribute('aria-describedby', errorElement.id);
}

function clearError(input) {
  const errorElement = input.nextElementSibling;
  if (errorElement?.classList.contains('error-message')) {
    errorElement.textContent = '';
    errorElement.style.display = 'none';
  }
  input.classList.remove('invalid');
  input.removeAttribute('aria-invalid');
  input.removeAttribute('aria-describedby');
}
```

#### Error Summary

Collects all errors at top of form. Useful for accessibility and long forms.

```javascript
function displayErrorSummary(errors) {
  const summary = document.getElementById('error-summary');
  summary.innerHTML = '<h3>Please correct the following errors:</h3>';
  
  const list = document.createElement('ul');
  errors.forEach(error => {
    const item = document.createElement('li');
    const link = document.createElement('a');
    link.href = `#${error.fieldId}`;
    link.textContent = error.message;
    link.addEventListener('click', (e) => {
      e.preventDefault();
      document.getElementById(error.fieldId).focus();
    });
    item.appendChild(link);
    list.appendChild(item);
  });
  
  summary.appendChild(list);
  summary.focus();
}
```

#### Tooltip/Popover Errors

Displays errors in floating tooltips. Reduces layout shift but can be obscured or clipped.

```javascript
function showTooltipError(input, message) {
  const tooltip = document.createElement('div');
  tooltip.className = 'error-tooltip';
  tooltip.textContent = message;
  tooltip.id = `${input.id}-error`;
  
  document.body.appendChild(tooltip);
  
  const rect = input.getBoundingClientRect();
  tooltip.style.position = 'absolute';
  tooltip.style.left = `${rect.left}px`;
  tooltip.style.top = `${rect.bottom + 5}px`;
  
  input.setAttribute('aria-describedby', tooltip.id);
}
```

### Validation State Management

#### Field-Level State

Tracks validation state per field:

```javascript
class FormValidator {
  constructor(formElement, rules) {
    this.form = formElement;
    this.rules = rules;
    this.fieldStates = new Map();
    this.touched = new Set();
  }
  
  initField(input) {
    this.fieldStates.set(input.name, {
      valid: true,
      errors: [],
      validated: false,
      validating: false
    });
  }
  
  markTouched(fieldName) {
    this.touched.add(fieldName);
  }
  
  isTouched(fieldName) {
    return this.touched.has(fieldName);
  }
  
  updateFieldState(fieldName, state) {
    const current = this.fieldStates.get(fieldName);
    this.fieldStates.set(fieldName, { ...current, ...state });
  }
  
  getFieldState(fieldName) {
    return this.fieldStates.get(fieldName);
  }
  
  isFormValid() {
    return Array.from(this.fieldStates.values())
      .every(state => state.valid);
  }
}
```

#### Validation Lifecycle

Manages async validation state to prevent race conditions:

```javascript
async function validateWithLoading(input, rule) {
  const fieldName = input.name;
  const validationId = Date.now();
  
  validator.updateFieldState(fieldName, {
    validating: true,
    currentValidationId: validationId
  });
  
  showLoadingIndicator(input);
  
  try {
    const result = await validateFieldAsync(input, rule);
    
    // Check if this is still the current validation
    const state = validator.getFieldState(fieldName);
    if (state.currentValidationId === validationId) {
      validator.updateFieldState(fieldName, {
        valid: result.valid,
        errors: result.valid ? [] : [result.message],
        validated: true,
        validating: false
      });
      
      displayValidationResult(input, result);
    }
  } catch (error) {
    hideLoadingIndicator(input);
    // [Inference] Network or server errors during validation
  }
}
```

### Debouncing and Throttling

#### Debounce Implementation

Delays validation until user stops typing:

```javascript
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

input.addEventListener('input', debounce((e) => {
  validateField(e.target);
}, 300));
```

#### Throttle Implementation

Limits validation frequency regardless of input rate:

```javascript
function throttle(func, limit) {
  let inThrottle;
  return function executedFunction(...args) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}
```

### Complex Field Dependencies

#### Cross-Field Validation

Validates fields that depend on other field values:

```javascript
function setupDependentValidation(form) {
  const password = form.querySelector('[name="password"]');
  const confirmPassword = form.querySelector('[name="confirmPassword"]');
  
  confirmPassword.addEventListener('input', () => {
    if (confirmPassword.value !== password.value) {
      showError(confirmPassword, 'Passwords must match');
    } else {
      clearError(confirmPassword);
    }
  });
  
  // Re-validate confirm when password changes
  password.addEventListener('input', () => {
    if (validator.isTouched('confirmPassword')) {
      confirmPassword.dispatchEvent(new Event('input'));
    }
  });
}
```

#### Conditional Validation Rules

Changes validation requirements based on other field values:

```javascript
function getConditionalRules(fieldName, formData) {
  const baseRules = rules[fieldName];
  
  if (fieldName === 'companyName') {
    // Only required if accountType is 'business'
    return {
      ...baseRules,
      required: formData.accountType === 'business'
    };
  }
  
  if (fieldName === 'vatNumber') {
    return {
      ...baseRules,
      required: formData.country === 'GB' && formData.accountType === 'business'
    };
  }
  
  return baseRules;
}
```

### Dynamic Field Validation

#### Adding/Removing Fields

Handles fields added or removed dynamically:

```javascript
class DynamicFormValidator extends FormValidator {
  observeForm() {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.matches('input, select, textarea')) {
            this.registerField(node);
          }
        });
        
        mutation.removedNodes.forEach((node) => {
          if (node.nodeType === 1 && node.matches('input, select, textarea')) {
            this.unregisterField(node);
          }
        });
      });
    });
    
    observer.observe(this.form, {
      childList: true,
      subtree: true
    });
  }
  
  registerField(input) {
    this.initField(input);
    this.attachListeners(input);
  }
  
  unregisterField(input) {
    this.fieldStates.delete(input.name);
    this.touched.delete(input.name);
  }
}
```

#### Repeating Field Groups

Validates repeated field sets (e.g., multiple addresses):

```javascript
function validateRepeatingGroup(container) {
  const groups = container.querySelectorAll('.address-group');
  const allValid = Array.from(groups).every((group, index) => {
    const fields = group.querySelectorAll('input, select');
    return Array.from(fields).every(field => {
      const fieldName = `${field.name}_${index}`;
      return validateField(field, rules[field.name]).valid;
    });
  });
  
  return allValid;
}
```

### Custom Validation Messages

#### Message Templating

Generates contextual error messages:

```javascript
const messageTemplates = {
  required: (fieldLabel) => `${fieldLabel} is required`,
  minLength: (fieldLabel, min) => `${fieldLabel} must be at least ${min} characters`,
  maxLength: (fieldLabel, max) => `${fieldLabel} cannot exceed ${max} characters`,
  pattern: (fieldLabel, format) => `${fieldLabel} must be a valid ${format}`,
  email: (fieldLabel) => `Please enter a valid email address`,
  custom: (fieldLabel, message) => message
};

function generateMessage(fieldName, validationType, ...params) {
  const fieldLabel = document.querySelector(`label[for="${fieldName}"]`)?.textContent || fieldName;
  return messageTemplates[validationType](fieldLabel, ...params);
}
```

#### Internationalization

Supports multiple languages for validation messages:

```javascript
const messages = {
  en: {
    required: 'This field is required',
    email: 'Please enter a valid email',
    minLength: 'Minimum {min} characters required'
  },
  es: {
    required: 'Este campo es obligatorio',
    email: 'Por favor, introduce un email válido',
    minLength: 'Se requieren mínimo {min} caracteres'
  }
};

function getMessage(key, params = {}, locale = 'en') {
  let message = messages[locale][key] || messages.en[key];
  Object.keys(params).forEach(param => {
    message = message.replace(`{${param}}`, params[param]);
  });
  return message;
}
```

### Accessibility Considerations

#### ARIA Attributes

Proper ARIA implementation for screen readers:

```javascript
function makeFieldAccessible(input, errorElement) {
  // Link error message to input
  errorElement.id = `${input.id}-error`;
  errorElement.setAttribute('role', 'alert');
  errorElement.setAttribute('aria-live', 'polite');
  
  // Mark input as invalid
  input.setAttribute('aria-invalid', 'true');
  input.setAttribute('aria-describedby', errorElement.id);
  
  // Add required indicator
  if (input.hasAttribute('required')) {
    input.setAttribute('aria-required', 'true');
  }
}

function clearAccessibilityAttributes(input) {
  input.setAttribute('aria-invalid', 'false');
  input.removeAttribute('aria-describedby');
}
```

#### Keyboard Navigation

Ensures keyboard users can navigate validation errors:

```javascript
function focusFirstError() {
  const firstError = document.querySelector('[aria-invalid="true"]');
  if (firstError) {
    firstError.focus();
    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}

form.addEventListener('submit', (e) => {
  if (!validateForm()) {
    e.preventDefault();
    focusFirstError();
  }
});
```

#### Live Regions

Announces validation changes to screen readers:

```javascript
function announceValidationChange(message) {
  const liveRegion = document.getElementById('validation-announcer');
  if (!liveRegion) {
    const region = document.createElement('div');
    region.id = 'validation-announcer';
    region.setAttribute('role', 'status');
    region.setAttribute('aria-live', 'polite');
    region.setAttribute('aria-atomic', 'true');
    region.className = 'sr-only'; // visually hidden
    document.body.appendChild(region);
  }
  
  liveRegion.textContent = message;
  
  // Clear after announcement
  setTimeout(() => {
    liveRegion.textContent = '';
  }, 1000);
}
```

### Performance Optimization

#### Validation Caching

Caches validation results to avoid redundant checks:

```javascript
class CachedValidator {
  constructor() {
    this.cache = new Map();
  }
  
  getCacheKey(fieldName, value, ruleHash) {
    return `${fieldName}:${value}:${ruleHash}`;
  }
  
  async validate(field, value, rule) {
    const ruleHash = JSON.stringify(rule);
    const cacheKey = this.getCacheKey(field.name, value, ruleHash);
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }
    
    const result = await validateFieldAsync(field, rule);
    this.cache.set(cacheKey, result);
    
    return result;
  }
  
  invalidateField(fieldName) {
    Array.from(this.cache.keys())
      .filter(key => key.startsWith(`${fieldName}:`))
      .forEach(key => this.cache.delete(key));
  }
}
```

#### Lazy Validation Loading

Defers expensive validations until necessary:

```javascript
const lazyRules = {
  username: {
    immediate: {
      required: true,
      pattern: /^[a-zA-Z0-9_]+$/
    },
    deferred: {
      async checkAvailability(value) {
        // Only runs if immediate validations pass
        return await fetch(`/api/check-username/${value}`);
      }
    }
  }
};

async function validateFieldLazy(input, rules) {
  // Run immediate validations first
  const immediateResult = validateField(input, rules.immediate);
  if (!immediateResult.valid) {
    return immediateResult;
  }
  
  // Only run deferred validations if immediate pass
  if (rules.deferred) {
    return await validateFieldAsync(input, rules.deferred);
  }
  
  return immediateResult;
}
```

#### Batch DOM Updates

Minimizes reflows by batching DOM operations:

```javascript
function updateValidationUI(validationResults) {
  // Read phase - gather all measurements
  const updates = validationResults.map(result => ({
    input: result.input,
    errorElement: result.input.nextElementSibling,
    message: result.message,
    valid: result.valid
  }));
  
  // Write phase - apply all DOM changes
  requestAnimationFrame(() => {
    updates.forEach(update => {
      if (update.valid) {
        update.input.classList.remove('invalid');
        update.errorElement.style.display = 'none';
      } else {
        update.input.classList.add('invalid');
        update.errorElement.textContent = update.message;
        update.errorElement.style.display = 'block';
      }
    });
  });
}
```

### Advanced Pattern Matching

#### Email Validation

Comprehensive email pattern (basic level):

```javascript
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// [Inference] More strict pattern following RFC 5322 simplified
const strictEmailPattern = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
```

#### Phone Number Validation

Flexible phone number patterns:

```javascript
const phonePatterns = {
  US: /^(\+1)?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}$/,
  UK: /^(\+44)?[\s]?[0-9]{4}[\s]?[0-9]{6}$/,
  international: /^\+?[1-9]\d{1,14}$/ // E.164 format
};

function validatePhone(value, country = 'international') {
  const pattern = phonePatterns[country] || phonePatterns.international;
  return pattern.test(value);
}
```

#### Credit Card Validation

Luhn algorithm implementation:

```javascript
function validateCreditCard(cardNumber) {
  const digits = cardNumber.replace(/\D/g, '');
  
  if (digits.length < 13 || digits.length > 19) {
    return false;
  }
  
  let sum = 0;
  let isEven = false;
  
  for (let i = digits.length - 1; i >= 0; i--) {
    let digit = parseInt(digits[i], 10);
    
    if (isEven) {
      digit *= 2;
      if (digit > 9) {
        digit -= 9;
      }
    }
    
    sum += digit;
    isEven = !isEven;
  }
  
  return sum % 10 === 0;
}
```

#### URL Validation

Validates URL structure:

```javascript
function validateURL(value) {
  try {
    const url = new URL(value);
    return ['http:', 'https:'].includes(url.protocol);
  } catch {
    return false;
  }
}

// Pattern-based alternative
const urlPattern = /^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$/;
```

### File Input Validation

#### File Type Validation

Validates file extensions and MIME types:

```javascript
function validateFileType(file, allowedTypes) {
  // Check extension
  const extension = file.name.split('.').pop().toLowerCase();
  const allowedExtensions = allowedTypes.map(type => type.split('/')[1]);
  
  if (!allowedExtensions.includes(extension)) {
    return {
      valid: false,
      message: `Only ${allowedExtensions.join(', ')} files are allowed`
    };
  }
  
  // Check MIME type
  if (!allowedTypes.includes(file.type)) {
    return {
      valid: false,
      message: 'Invalid file type'
    };
  }
  
  return { valid: true };
}

fileInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  if (file) {
    const result = validateFileType(file, ['image/jpeg', 'image/png', 'application/pdf']);
    if (!result.valid) {
      showError(fileInput, result.message);
    }
  }
});
```

#### File Size Validation

Checks file size constraints:

```javascript
function validateFileSize(file, maxSizeMB) {
  const maxSizeBytes = maxSizeMB * 1024 * 1024;
  
  if (file.size > maxSizeBytes) {
    return {
      valid: false,
      message: `File size must not exceed ${maxSizeMB}MB`
    };
  }
  
  return { valid: true };
}
```

#### Image Dimension Validation

Validates image dimensions:

```javascript
function validateImageDimensions(file, constraints) {
  return new Promise((resolve) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    
    img.onload = () => {
      URL.revokeObjectURL(url);
      
      const { minWidth, maxWidth, minHeight, maxHeight, aspectRatio } = constraints;
      
      if (minWidth && img.width < minWidth) {
        resolve({ valid: false, message: `Width must be at least ${minWidth}px` });
        return;
      }
      
      if (maxWidth && img.width > maxWidth) {
        resolve({ valid: false, message: `Width cannot exceed ${maxWidth}px` });
        return;
      }
      
      if (minHeight && img.height < minHeight) {
        resolve({ valid: false, message: `Height must be at least ${minHeight}px` });
        return;
      }
      
      if (maxHeight && img.height > maxHeight) {
        resolve({ valid: false, message: `Height cannot exceed ${maxHeight}px` });
        return;
      }
      
      if (aspectRatio) {
        const ratio = img.width / img.height;
        const tolerance = 0.01;
        if (Math.abs(ratio - aspectRatio) > tolerance) {
          resolve({ 
            valid: false, 
            message: `Image must have ${aspectRatio}:1 aspect ratio` 
          });
          return;
        }
      }
      
      resolve({ valid: true });
    };
    
    img.onerror = () => {
      URL.revokeObjectURL(url);
      resolve({ valid: false, message: 'Invalid image file' });
    };
    
    img.src = url;
  });
}
```

### Server-Side Validation Integration

#### Async Server Validation

Validates against server-side constraints:

```javascript
async function validateServerSide(fieldName, value) {
  try {
    const response = await fetch('/api/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ field: fieldName, value })
    });
    
    const result = await response.json();
    
    return {
      valid: result.valid,
      message: result.message || ''
    };
  } catch (error) {
    return {
      valid: true, // Fail open on network error
      message: ''
    };
  }
}
```

#### Form Submission with Server Validation

Handles server-side validation on submit:

```javascript
async function submitForm(form) {
  // Client-side validation first
  if (!validateForm()) {
    focusFirstError();
    return;
  }
  
  const formData = new FormData(form);
  const submitButton = form.querySelector('[type="submit"]');
  
  submitButton.disabled = true;
  submitButton.textContent = 'Submitting...';
  
  try {
    const response = await fetch(form.action, {
      method: 'POST',
      body: formData
    });
    
    const result = await response.json();
    
    if (response.ok) {
      // Success handling
      window.location.href = result.redirectUrl;
    } else {
      // Server validation errors
      displayServerErrors(result.errors);
    }
  } catch (error) {
    showError(form, 'An error occurred. Please try again.');
  } finally {
    submitButton.disabled = false;
    submitButton.textContent = 'Submit';
  }
}

function displayServerErrors(errors) {
  Object.keys(errors).forEach(fieldName => {
    const input = document.querySelector(`[name="${fieldName}"]`);
    if (input) {
      showError(input, errors[fieldName]);
    }
  });
  
  focusFirstError();
}
```

### Form State Persistence

#### localStorage Integration

Saves form state to prevent data loss:

```javascript
class FormStatePersistence {
  constructor(formId) {
    this.formId = formId;
    this.storageKey = `form_state_${formId}`;
  }
  
  save(formData) {
    localStorage.setItem(this.storageKey, JSON.stringify({
      data: formData,
      timestamp: Date.now()
    }));
  }
  
  load() {
    const stored = localStorage.getItem(this.storageKey);
    if (!stored) return null;
    
    const state = JSON.parse(stored);
    const maxAge = 24 * 60 * 60 * 1000; // 24 hours
    
    if (Date.now() - state.timestamp > maxAge) {
      this.clear();
      return null;
    }
    
    return state.data;
  }
  
  clear() {
    localStorage.removeItem(this.storageKey);
  }
}

// Auto-save on input
const persistence = new FormStatePersistence('checkout-form');

form.addEventListener('input', debounce(() => {
  const formData = Object.fromEntries(new FormData(form));
  persistence.save(formData);
}, 1000));

// Restore on page load
window.addEventListener('DOMContentLoaded', () => {
  const savedData = persistence.load();
  if (savedData) {
    Object.keys(savedData).forEach(name => {
      const input = form.querySelector(`[name="${name}"]`);
      if (input) {
        input.value = savedData[name];
      }
    });
  }
});

// Clear on successful submit
form.addEventListener('submit', () => {
  persistence.clear();
});
```

### Complete Validation System Example

Integrated system combining multiple concepts:

```javascript
class ComprehensiveFormValidator {
  constructor(form, config) {
    this.form = form;
    this.rules = config.rules;
    this.messages = config.messages || {};
    this.fieldStates = new Map();
    this.touched = new Set();
    this.validationCache = new Map();
    
    this.init();
  }
  
  init() {
    this.form.noValidate = true;
    
    this.form.querySelectorAll('input, select, textarea').forEach(input => {
      this.initField(input);
      this.attachListeners(input);
    });
    
    this.form.addEventListener('submit', (e) => this.handleSubmit(e));
  }
  
  initField(input) {
    this.fieldStates.set(input.name, {
      valid: true,
      errors: [],
      validated: false,
      validating: false
    });
  }
  
  attachListeners(input) {
    input.addEventListener('blur', () => {
      this.touched.add(input.name);
      this.validateField(input);
    });
    
    input.addEventListener('input', debounce(() => {
      if (this.touched.has(input.name)) {
        this.validateField(input);
      }
    }, 300));
  }
  
async validateField(input) {
    const rule = this.rules[input.name];
    if (!rule) return { valid: true };

    const value = input.value.trim();
    const errors = [];

    // Required validation
    if (rule.required && !value) {
        errors.push(this.getMessage('required', input));
    }

    if (value) {
        // Length validation
        if (rule.minLength && value.length < rule.minLength) {
            errors.push(this.getMessage('minLength', input, rule.minLength));
        }

        if (rule.maxLength && value.length > rule.maxLength) {
            errors.push(this.getMessage('maxLength', input, rule.maxLength));
        }

        // Pattern validation
        if (rule.pattern && !rule.pattern.test(value)) {
            errors.push(this.getMessage('pattern', input));
        }

        // Custom validation
        if (rule.custom) {
            this.fieldStates.get(input.name).validating = true;
            this.showLoadingIndicator(input);

            try {
                const result = await rule.custom(value);
                if (result !== true) {
                    errors.push(result);
                }
            } catch (error) {
                errors.push('Validation failed');
            } finally {
                this.fieldStates.get(input.name).validating = false;
                this.hideLoadingIndicator(input);
            }
        }
    }

    const result = {
        valid: errors.length === 0,
        errors,
    };

    this.fieldStates.set(input.name, {
        ...this.fieldStates.get(input.name),
        valid: result.valid,
        errors: result.errors,
        validated: true,
    });

    this.displayValidationResult(input, result);

    return result;
}

async validateAllFields() {
    const inputs = Array.from(
        this.form.querySelectorAll('input, select, textarea')
    );

    const results = await Promise.all(
        inputs.map(input => this.validateField(input))
    );

    return results.every(result => result.valid);
}

async handleSubmit(e) {
    e.preventDefault();

    // Mark all fields as touched
    this.form
        .querySelectorAll('input, select, textarea')
        .forEach(input => this.touched.add(input.name));

    const isValid = await this.validateAllFields();

    if (isValid) {
        this.form.submit();
    } else {
        this.focusFirstError();
        announceValidationChange(
            'Form has errors. Please correct them and try again.'
        );
    }
}

displayValidationResult(input, result) {
    const errorElement = this.getErrorElement(input);

    if (result.valid) {
        input.classList.remove('invalid');
        input.classList.add('valid');
        input.setAttribute('aria-invalid', 'false');
        errorElement.textContent = '';
        errorElement.style.display = 'none';
    } else {
        input.classList.remove('valid');
        input.classList.add('invalid');
        input.setAttribute('aria-invalid', 'true');
        input.setAttribute('aria-describedby', errorElement.id);
        errorElement.textContent = result.errors[0];
        errorElement.style.display = 'block';
    }
}

getErrorElement(input) {
    let errorElement = input.nextElementSibling;

    if (!errorElement?.classList.contains('error-message')) {
        errorElement = document.createElement('span');
        errorElement.className = 'error-message';
        errorElement.id = `${input.id}-error`;
        errorElement.setAttribute('role', 'alert');
        input.parentNode.insertBefore(errorElement, input.nextSibling);
    }

    return errorElement;
}

getMessage(type, input, param) {
    const fieldLabel = this.getFieldLabel(input);
    const customMessage = this.messages[input.name]?.[type];

    if (customMessage) return customMessage;

    const defaultMessages = {
        required: `${fieldLabel} is required`,
        minLength: `${fieldLabel} must be at least ${param} characters`,
        maxLength: `${fieldLabel} cannot exceed ${param} characters`,
        pattern: `${fieldLabel} has an invalid format`,
    };

    return defaultMessages[type] || 'Invalid value';
}

getFieldLabel(input) {
    const label = this.form.querySelector(
        `label[for="${input.id}"]`
    );

    return (
        label?.textContent.replace('*', '').trim() || input.name
    );
}

focusFirstError() {
    const firstInvalid = this.form.querySelector(
        '[aria-invalid="true"]'
    );

    if (firstInvalid) {
        firstInvalid.focus();
        firstInvalid.scrollIntoView({
            behavior: 'smooth',
            block: 'center',
        });
    }
}

showLoadingIndicator(input) {
    input.classList.add('validating');
}

hideLoadingIndicator(input) {
    input.classList.remove('validating');
}

reset() {
    this.fieldStates.clear();
    this.touched.clear();
    this.validationCache.clear();

    this.form
        .querySelectorAll('input, select, textarea')
        .forEach(input => {
            input.classList.remove(
                'valid',
                'invalid',
                'validating'
            );
            input.removeAttribute('aria-invalid');
            input.removeAttribute('aria-describedby');

            const errorElement = this.getErrorElement(input);
            errorElement.textContent = '';
            errorElement.style.display = 'none';
        });
}

// Usage
const validator = new ComprehensiveFormValidator(
    document.getElementById('my-form'),
    {
        rules: {
            username: {
                required: true,
                minLength: 3,
                maxLength: 20,
                pattern: /^[a-zA-Z0-9_]+$/,
                custom: async value => {
                    const response = await fetch(
                        `/api/check-username/${value}`
                    );
                    const result = await response.json();
                    return (
                        result.available ||
                        'Username already taken'
                    );
                },
            },
            email: {
                required: true,
                pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
            },
            password: {
                required: true,
                minLength: 8,
                custom: value => {
                    if (!/[A-Z]/.test(value))
                        return 'Must contain uppercase letter';
                    if (!/[a-z]/.test(value))
                        return 'Must contain lowercase letter';
                    if (!/[0-9]/.test(value))
                        return 'Must contain number';
                    return true;
                },
            },
        },
        messages: {
            email: {
                pattern: 'Please enter a valid email address',
            },
        },
    }
);
```


This validation system provides comprehensive client-side form validation with proper error handling, accessibility support, and extensibility for various validation requirements.

---

