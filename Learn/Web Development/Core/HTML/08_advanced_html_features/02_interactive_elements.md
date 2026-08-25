## Interactive Elements


### Modern HTML Interactive Components

HTML5 introduced several native interactive elements that provide built-in functionality without requiring JavaScript frameworks. These elements offer semantic meaning, accessibility features, and cross-browser compatibility while reducing development complexity and improving user experience.

### Details/Summary Disclosure Widgets

#### Understanding Disclosure Widgets

The `<details>` and `<summary>` elements create native disclosure widgets that allow users to show or hide content sections. This pattern is commonly used for FAQ sections, expandable content areas, and progressive disclosure interfaces.

#### Basic Structure and Functionality

```html
<details>
  <summary>What is our return policy?</summary>
  <p>You can return items within 30 days of purchase for a full refund. Items must be in original condition with tags attached.</p>
</details>
```

The `<summary>` element acts as the clickable header that toggles the visibility of the remaining content within `<details>`. Browsers automatically provide a disclosure triangle (arrow) indicator and handle the expand/collapse functionality.

#### Advanced Implementation Patterns

**Nested Disclosure Widgets:**

```html
<details>
  <summary>Account Settings</summary>
  <details>
    <summary>Profile Information</summary>
    <form>
      <label for="username">Username:</label>
      <input type="text" id="username" value="john_doe">
      <label for="email">Email:</label>
      <input type="email" id="email" value="john@example.com">
    </form>
  </details>
  <details>
    <summary>Privacy Settings</summary>
    <fieldset>
      <legend>Notification Preferences</legend>
      <label><input type="checkbox" checked> Email notifications</label>
      <label><input type="checkbox"> SMS notifications</label>
    </fieldset>
  </details>
</details>
```

**Accordion-Style Interface:**

```html
<div class="accordion">
  <details name="faq-group">
    <summary>How do I create an account?</summary>
    <p>Click the "Sign Up" button and fill out the registration form with your email address and preferred password.</p>
  </details>
  
  <details name="faq-group">
    <summary>Is my payment information secure?</summary>
    <p>Yes, we use industry-standard SSL encryption and never store your full credit card information on our servers.</p>
  </details>
  
  <details name="faq-group">
    <summary>How can I track my order?</summary>
    <p>After your order ships, you'll receive a tracking number via email. You can also check your order status in your account dashboard.</p>
  </details>
</div>
```

#### Styling and Customization

```css
/* Remove default disclosure triangle */
details > summary {
  list-style: none;
  cursor: pointer;
  padding: 12px 16px;
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-weight: 600;
}

/* Hide webkit default marker */
details > summary::-webkit-details-marker {
  display: none;
}

/* Custom disclosure indicator */
details > summary::before {
  content: "▶";
  margin-right: 8px;
  transition: transform 0.2s ease;
}

details[open] > summary::before {
  transform: rotate(90deg);
}

/* Content styling */
details > div,
details > p {
  padding: 16px;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 4px 4px;
  background: white;
}

/* Smooth animation */
details {
  overflow: hidden;
}

details > summary {
  transition: margin 0.2s ease;
}

details[open] > summary {
  margin-bottom: 0;
}
```

#### JavaScript Enhancement

```javascript
// Enhanced details functionality
class DetailsEnhancer {
  constructor(selector = 'details') {
    this.details = document.querySelectorAll(selector);
    this.init();
  }
  
  init() {
    this.details.forEach(detail => {
      // Add animation support
      detail.addEventListener('toggle', this.handleToggle.bind(this));
      
      // Add keyboard navigation
      const summary = detail.querySelector('summary');
      summary.addEventListener('keydown', this.handleKeydown.bind(this));
    });
  }
  
  handleToggle(event) {
    const detail = event.target;
    const content = detail.querySelector('summary').nextElementSibling;
    
    if (detail.open) {
      // Animate opening
      content.style.maxHeight = content.scrollHeight + 'px';
      detail.setAttribute('aria-expanded', 'true');
    } else {
      // Animate closing
      content.style.maxHeight = '0';
      detail.setAttribute('aria-expanded', 'false');
    }
  }
  
  handleKeydown(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      event.target.click();
    }
  }
}

// Initialize enhanced details
document.addEventListener('DOMContentLoaded', () => {
  new DetailsEnhancer();
});
```

#### Accessibility Considerations

The `<details>` element provides built-in accessibility features:

- Screen readers announce the expand/collapse state
- Keyboard navigation works automatically (Enter and Space keys)
- Focus management is handled natively
- ARIA attributes can enhance functionality:

```html
<details aria-expanded="false">
  <summary aria-controls="content-1" id="summary-1">
    Advanced Search Options
  </summary>
  <div id="content-1" role="region" aria-labelledby="summary-1">
    <!-- Search form content -->
  </div>
</details>
```

### Dialog Elements

#### Native Dialog Implementation

The `<dialog>` element provides a semantic way to create modal and non-modal dialogs with built-in accessibility features and focus management.

```html
<dialog id="confirmation-dialog">
  <form method="dialog">
    <h2>Confirm Action</h2>
    <p>Are you sure you want to delete this item? This action cannot be undone.</p>
    <div class="dialog-actions">
      <button value="cancel" type="button">Cancel</button>
      <button value="confirm" type="submit" class="danger">Delete</button>
    </div>
  </form>
</dialog>

<button onclick="document.getElementById('confirmation-dialog').showModal()">
  Delete Item
</button>
```

#### Modal vs Non-Modal Dialogs

```javascript
// Modal dialog (blocks interaction with background)
dialog.showModal();

// Non-modal dialog (allows background interaction)
dialog.show();

// Close dialog
dialog.close('returnValue');
```

#### Advanced Dialog Patterns

**Settings Dialog with Tabs:**

```html
<dialog id="settings-dialog" aria-labelledby="settings-title">
  <header>
    <h2 id="settings-title">Application Settings</h2>
    <button class="close-button" onclick="this.closest('dialog').close()"
            aria-label="Close settings">×</button>
  </header>
  
  <div class="dialog-content">
    <nav role="tablist" aria-label="Settings categories">
      <button role="tab" aria-selected="true" aria-controls="general-panel">General</button>
      <button role="tab" aria-selected="false" aria-controls="privacy-panel">Privacy</button>
      <button role="tab" aria-selected="false" aria-controls="notifications-panel">Notifications</button>
    </nav>
    
    <div role="tabpanel" id="general-panel" aria-labelledby="general-tab">
      <!-- General settings form -->
    </div>
    
    <div role="tabpanel" id="privacy-panel" aria-labelledby="privacy-tab" hidden>
      <!-- Privacy settings form -->
    </div>
    
    <div role="tabpanel" id="notifications-panel" aria-labelledby="notifications-tab" hidden>
      <!-- Notification settings form -->
    </div>
  </div>
  
  <footer class="dialog-actions">
    <button type="button" onclick="this.closest('dialog').close('cancel')">Cancel</button>
    <button type="button" onclick="saveSettings()">Save Changes</button>
  </footer>
</dialog>
```

#### Dialog JavaScript Management

```javascript
class DialogManager {
  constructor(dialogSelector) {
    this.dialog = document.querySelector(dialogSelector);
    this.previousFocus = null;
    this.init();
  }
  
  init() {
    if (!this.dialog) return;
    
    this.dialog.addEventListener('close', this.handleClose.bind(this));
    this.dialog.addEventListener('click', this.handleBackdropClick.bind(this));
    
    // Escape key handling
    this.dialog.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        this.close();
      }
    });
  }
  
  open(focusSelector = null) {
    this.previousFocus = document.activeElement;
    this.dialog.showModal();
    
    // Set focus to specific element or first focusable element
    const focusTarget = focusSelector 
      ? this.dialog.querySelector(focusSelector)
      : this.getFirstFocusableElement();
    
    if (focusTarget) {
      focusTarget.focus();
    }
  }
  
  close(returnValue = null) {
    if (returnValue) {
      this.dialog.close(returnValue);
    } else {
      this.dialog.close();
    }
  }
  
  handleClose() {
    // Return focus to element that opened dialog
    if (this.previousFocus) {
      this.previousFocus.focus();
    }
  }
  
  handleBackdropClick(event) {
    // Close dialog if user clicks backdrop
    if (event.target === this.dialog) {
      this.close('backdrop');
    }
  }
  
  getFirstFocusableElement() {
    const focusableElements = this.dialog.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    return focusableElements[0];
  }
}

// Usage
const confirmDialog = new DialogManager('#confirmation-dialog');
document.getElementById('delete-button').addEventListener('click', () => {
  confirmDialog.open('button[value="cancel"]');
});
```

#### Dialog Styling

```css
dialog {
  border: none;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  padding: 0;
  max-width: 500px;
  width: 90vw;
}

dialog::backdrop {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(2px);
}

dialog[open] {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dialog-actions {
  padding: 16px 24px;
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  border-top: 1px solid #e0e0e0;
}
```

### Progress and Meter Elements

#### Progress Element for Dynamic Processes

The `<progress>` element represents the completion progress of a task, such as loading operations, form submissions, or file uploads.

```html
<!-- Indeterminate progress (loading) -->
<progress>Loading...</progress>

<!-- Determinate progress with specific value -->
<progress value="32" max="100">32%</progress>

<!-- With accessible labeling -->
<label for="file-progress">Upload Progress:</label>
<progress id="file-progress" value="0" max="100" aria-describedby="progress-text">
  <span id="progress-text">0% complete</span>
</progress>
```

#### Advanced Progress Implementations

**File Upload Progress:**

```html
<div class="upload-container">
  <input type="file" id="file-input" multiple>
  <div id="upload-progress-container" hidden>
    <h3>Uploading Files</h3>
    <div id="file-progress-list"></div>
    <div class="overall-progress">
      <label for="overall-progress">Overall Progress:</label>
      <progress id="overall-progress" value="0" max="100"></progress>
      <span id="overall-percentage">0%</span>
    </div>
  </div>
</div>
```

```javascript
class FileUploadProgress {
  constructor(inputSelector, containerSelector) {
    this.fileInput = document.querySelector(inputSelector);
    this.container = document.querySelector(containerSelector);
    this.progressList = document.getElementById('file-progress-list');
    this.overallProgress = document.getElementById('overall-progress');
    this.overallPercentage = document.getElementById('overall-percentage');
    
    this.init();
  }
  
  init() {
    this.fileInput.addEventListener('change', this.handleFileSelection.bind(this));
  }
  
  handleFileSelection(event) {
    const files = Array.from(event.target.files);
    if (files.length === 0) return;
    
    this.container.hidden = false;
    this.progressList.innerHTML = '';
    this.overallProgress.value = 0;
    
    files.forEach((file, index) => {
      this.createFileProgressItem(file, index);
      this.uploadFile(file, index);
    });
  }
  
  createFileProgressItem(file, index) {
    const item = document.createElement('div');
    item.className = 'file-progress-item';
    item.innerHTML = `
      <div class="file-info">
        <strong>${file.name}</strong>
        <span class="file-size">(${this.formatFileSize(file.size)})</span>
      </div>
      <progress id="progress-${index}" value="0" max="100"></progress>
      <span id="percentage-${index}">0%</span>
    `;
    this.progressList.appendChild(item);
  }
  
  async uploadFile(file, index) {
    const formData = new FormData();
    formData.append('file', file);
    
    const xhr = new XMLHttpRequest();
    const progressBar = document.getElementById(`progress-${index}`);
    const percentage = document.getElementById(`percentage-${index}`);
    
    xhr.upload.addEventListener('progress', (event) => {
      if (event.lengthComputable) {
        const percent = Math.round((event.loaded / event.total) * 100);
        progressBar.value = percent;
        percentage.textContent = `${percent}%`;
        this.updateOverallProgress();
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status === 200) {
        progressBar.parentElement.classList.add('completed');
        this.updateOverallProgress();
      }
    });
    
    xhr.open('POST', '/upload');
    xhr.send(formData);
  }
  
  updateOverallProgress() {
    const allProgress = Array.from(this.progressList.querySelectorAll('progress'));
    const totalProgress = allProgress.reduce((sum, progress) => sum + progress.value, 0);
    const averageProgress = Math.round(totalProgress / allProgress.length);
    
    this.overallProgress.value = averageProgress;
    this.overallPercentage.textContent = `${averageProgress}%`;
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}

// Initialize upload progress
new FileUploadProgress('#file-input', '#upload-progress-container');
```

#### Meter Element for Scalar Measurements

The `<meter>` element represents a scalar value within a known range, such as disk usage, temperature, or score values.

```html
<!-- Basic meter with value and range -->
<meter value="6" min="0" max="10">6 out of 10</meter>

<!-- Meter with optimal range -->
<meter value="0.6" min="0" max="1" optimum="0.8">60%</meter>

<!-- Battery level indicator -->
<div class="battery-status">
  <label for="battery-meter">Battery Level:</label>
  <meter id="battery-meter" value="45" min="0" max="100" 
         low="20" high="80" optimum="100">45%</meter>
  <span class="battery-text">45% remaining</span>
</div>
```

#### Advanced Meter Implementations

**System Resource Monitor:**

```html
<div class="system-monitor">
  <div class="resource-item">
    <label for="cpu-usage">CPU Usage:</label>
    <meter id="cpu-usage" value="0" min="0" max="100" 
           low="30" high="70" optimum="0"></meter>
    <span id="cpu-text">0%</span>
  </div>
  
  <div class="resource-item">
    <label for="memory-usage">Memory Usage:</label>
    <meter id="memory-usage" value="0" min="0" max="100" 
           low="40" high="80" optimum="0"></meter>
    <span id="memory-text">0%</span>
  </div>
  
  <div class="resource-item">
    <label for="disk-usage">Disk Usage:</label>
    <meter id="disk-usage" value="0" min="0" max="100" 
           low="50" high="85" optimum="0"></meter>
    <span id="disk-text">0%</span>
  </div>
</div>
```

```javascript
class SystemMonitor {
  constructor() {
    this.meters = {
      cpu: document.getElementById('cpu-usage'),
      memory: document.getElementById('memory-usage'),
      disk: document.getElementById('disk-usage')
    };
    
    this.textElements = {
      cpu: document.getElementById('cpu-text'),
      memory: document.getElementById('memory-text'),
      disk: document.getElementById('disk-text')
    };
    
    this.startMonitoring();
  }
  
  startMonitoring() {
    setInterval(() => {
      this.updateMetrics();
    }, 2000);
  }
  
  async updateMetrics() {
    try {
      const response = await fetch('/api/system-metrics');
      const metrics = await response.json();
      
      Object.keys(metrics).forEach(key => {
        if (this.meters[key]) {
          this.meters[key].value = metrics[key];
          this.textElements[key].textContent = `${metrics[key]}%`;
          
          // Update ARIA label for screen readers
          this.meters[key].setAttribute('aria-label', 
            `${key.toUpperCase()} usage: ${metrics[key]}%`);
        }
      });
    } catch (error) {
      console.error('Failed to fetch system metrics:', error);
    }
  }
}

// Initialize system monitor
document.addEventListener('DOMContentLoaded', () => {
  new SystemMonitor();
});
```

#### Styling Progress and Meter Elements

```css
/* Progress element styling */
progress {
  appearance: none;
  width: 100%;
  height: 8px;
  border-radius: 4px;
  background-color: #e0e0e0;
}

progress::-webkit-progress-bar {
  background-color: #e0e0e0;
  border-radius: 4px;
}

progress::-webkit-progress-value {
  background: linear-gradient(90deg, #4caf50, #8bc34a);
  border-radius: 4px;
  transition: width 0.3s ease;
}

progress::-moz-progress-bar {
  background: linear-gradient(90deg, #4caf50, #8bc34a);
  border-radius: 4px;
}

/* Meter element styling */
meter {
  appearance: none;
  width: 200px;
  height: 12px;
  border-radius: 6px;
}

meter::-webkit-meter-bar {
  background: #e0e0e0;
  border-radius: 6px;
}

meter::-webkit-meter-optimum-value {
  background: #4caf50;
  border-radius: 6px;
}

meter::-webkit-meter-suboptimum-value {
  background: #ff9800;
  border-radius: 6px;
}

meter::-webkit-meter-even-less-good-value {
  background: #f44336;
  border-radius: 6px;
}

/* Resource monitor layout */
.system-monitor {
  display: grid;
  gap: 16px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.resource-item {
  display: grid;
  grid-template-columns: 120px 1fr auto;
  align-items: center;
  gap: 12px;
}

.resource-item label {
  font-weight: 600;
  color: #333;
}

.resource-item span {
  font-family: monospace;
  font-size: 14px;
  color: #666;
  min-width: 40px;
  text-align: right;
}
```

**Key points** for interactive elements: `<details>` and `<summary>` provide native disclosure functionality with built-in accessibility, `<dialog>` elements offer semantic modal and non-modal dialogs with proper focus management, `<progress>` elements should be used for dynamic processes with completion states, `<meter>` elements represent scalar values within known ranges with optimal value indicators, and all interactive elements benefit from progressive enhancement with JavaScript while maintaining core functionality without it.

---

