## Interactive Elements


### Custom Form Styling

Modern form styling requires overriding default browser styles while maintaining accessibility and usability across different input types and states.

```css
/* Reset default form styles */
.form-field {
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  border: none;
  outline: none;
  background: transparent;
  font-family: inherit;
  font-size: inherit;
}

/* Custom text input styling */
.text-input {
  width: 100%;
  padding: 1rem 1.5rem;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: #ffffff;
  transition: all 0.2s ease;
  font-size: 1rem;
  line-height: 1.5;
}

.text-input:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  background: #fefefe;
}

.text-input:invalid:not(:placeholder-shown) {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}
```

Advanced checkbox and radio button customization:

```css
/* Hide default checkbox/radio */
.custom-checkbox,
.custom-radio {
  position: absolute;
  opacity: 0;
  cursor: pointer;
}

/* Custom checkbox container */
.checkbox-container {
  position: relative;
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
}

/* Custom checkbox appearance */
.checkbox-container::before {
  content: '';
  width: 20px;
  height: 20px;
  border: 2px solid #d1d5db;
  border-radius: 4px;
  margin-right: 0.75rem;
  transition: all 0.2s ease;
  background: white;
  flex-shrink: 0;
}

/* Checked state */
.custom-checkbox:checked + .checkbox-container::before {
  background: #3b82f6;
  border-color: #3b82f6;
}

/* Checkmark */
.custom-checkbox:checked + .checkbox-container::after {
  content: '';
  position: absolute;
  left: 7px;
  top: 3px;
  width: 6px;
  height: 10px;
  border: solid white;
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}

/* Focus styles */
.custom-checkbox:focus + .checkbox-container::before {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}
```

Custom select dropdown styling:

```css
.select-container {
  position: relative;
  display: inline-block;
  width: 100%;
}

.custom-select {
  width: 100%;
  padding: 1rem 3rem 1rem 1.5rem;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
}

/* Custom dropdown arrow */
.select-container::after {
  content: '';
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 6px solid #6b7280;
  pointer-events: none;
  transition: transform 0.2s ease;
}

.custom-select:focus + .select-container::after {
  transform: translateY(-50%) rotate(180deg);
}
```

Range slider customization:

```css
.range-slider {
  -webkit-appearance: none;
  width: 100%;
  height: 8px;
  border-radius: 4px;
  background: #e2e8f0;
  outline: none;
  cursor: pointer;
}

/* WebKit thumb */
.range-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
  transition: all 0.2s ease;
}

.range-slider::-webkit-slider-thumb:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* Firefox thumb */
.range-slider::-moz-range-thumb {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #3b82f6;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}
```

### Advanced Hover Effects

Sophisticated hover effects enhance user interaction through layered animations, transforms, and state transitions.

```css
/* Multi-layer card hover effect */
.hover-card {
  position: relative;
  background: white;
  border-radius: 16px;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  cursor: pointer;
}

.hover-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(147, 51, 234, 0.1));
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: 1;
}

.hover-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
}

.hover-card:hover::before {
  opacity: 1;
}

/* Content scaling on hover */
.hover-card .card-content {
  position: relative;
  padding: 2rem;
  z-index: 2;
  transition: transform 0.3s ease;
}

.hover-card:hover .card-content {
  transform: scale(1.05);
}
```

Advanced image hover effects:

```css
.image-hover-container {
  position: relative;
  overflow: hidden;
  border-radius: 12px;
}

.hover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.image-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(45deg, rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.3));
  opacity: 0;
  transition: all 0.4s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.image-hover-container:hover .hover-image {
  transform: scale(1.15) rotate(2deg);
}

.image-hover-container:hover .image-overlay {
  opacity: 1;
}

/* Overlay content animation */
.overlay-content {
  text-align: center;
  color: white;
  transform: translateY(30px);
  transition: transform 0.4s ease 0.1s;
}

.image-hover-container:hover .overlay-content {
  transform: translateY(0);
}
```

Complex button hover interactions:

```css
.interactive-button {
  position: relative;
  padding: 1rem 2rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s ease;
}

/* Ripple effect */
.interactive-button::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  transition: width 0.6s ease, height 0.6s ease;
}

.interactive-button:hover::before {
  width: 300px;
  height: 300px;
}

/* Sliding background */
.interactive-button::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s ease;
}

.interactive-button:hover::after {
  left: 100%;
}

/* Text effects */
.button-text {
  position: relative;
  z-index: 2;
  transition: transform 0.2s ease;
}

.interactive-button:hover .button-text {
  transform: scale(1.05);
}
```

### CSS-Only Interactive Components

Complex interactive elements built entirely with CSS using pseudo-elements, transitions, and form states.

```css
/* Accordion component */
.accordion-item {
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin-bottom: 0.5rem;
  overflow: hidden;
}

.accordion-input {
  display: none;
}

.accordion-header {
  display: block;
  padding: 1.5rem;
  background: #f8fafc;
  cursor: pointer;
  position: relative;
  transition: background-color 0.2s ease;
  user-select: none;
}

.accordion-header:hover {
  background: #f1f5f9;
}

/* Arrow indicator */
.accordion-header::after {
  content: '';
  position: absolute;
  right: 1.5rem;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 6px solid #6b7280;
  transition: transform 0.3s ease;
}

.accordion-input:checked + .accordion-header::after {
  transform: translateY(-50%) rotate(180deg);
}

/* Content panel */
.accordion-content {
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease;
}

.accordion-input:checked ~ .accordion-content {
  max-height: 1000px;
}

.accordion-body {
  padding: 1.5rem;
  background: white;
}
```

CSS-only modal dialog:

```css
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
  z-index: 1000;
}

.modal-trigger:checked ~ .modal-overlay {
  opacity: 1;
  visibility: visible;
}

.modal-content {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  max-width: 500px;
  width: 90%;
  transform: scale(0.8) translateY(-50px);
  transition: transform 0.3s ease;
  position: relative;
}

.modal-trigger:checked ~ .modal-overlay .modal-content {
  transform: scale(1) translateY(0);
}

/* Close button */
.modal-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 32px;
  height: 32px;
  cursor: pointer;
  opacity: 0.7;
  transition: opacity 0.2s ease;
}

.modal-close:hover {
  opacity: 1;
}

.modal-close::before,
.modal-close::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 20px;
  height: 2px;
  background: #6b7280;
  transform: translate(-50%, -50%) rotate(45deg);
}

.modal-close::after {
  transform: translate(-50%, -50%) rotate(-45deg);
}
```

Pure CSS tabs component:

```css
.tabs-container {
  width: 100%;
  max-width: 600px;
}

.tab-input {
  display: none;
}

.tab-labels {
  display: flex;
  border-bottom: 2px solid #e2e8f0;
}

.tab-label {
  flex: 1;
  padding: 1rem;
  text-align: center;
  cursor: pointer;
  background: #f8fafc;
  border: none;
  position: relative;
  transition: all 0.2s ease;
  user-select: none;
}

.tab-label:hover {
  background: #f1f5f9;
}

/* Active tab indicator */
.tab-label::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 100%;
  height: 2px;
  background: #3b82f6;
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.tab-input:checked + .tab-label {
  background: white;
  color: #3b82f6;
}

.tab-input:checked + .tab-label::after {
  transform: scaleX(1);
}

/* Tab content panels */
.tab-content {
  display: none;
  padding: 2rem;
  background: white;
}

.tab-input:checked ~ .tab-content {
  display: block;
}
```

### Accessibility in Animations

Implementing animations that respect user preferences and accessibility requirements while maintaining visual appeal.

```css
/* Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

/* Safe default animations */
.fade-in {
  opacity: 0;
  animation: fadeIn 0.5s ease forwards;
}

@keyframes fadeIn {
  to {
    opacity: 1;
  }
}

/* Reduced motion alternative */
@media (prefers-reduced-motion: reduce) {
  .fade-in {
    animation: none;
    opacity: 1;
  }
}
```

Focus-visible animations for keyboard navigation:

```css
.interactive-element {
  position: relative;
  transition: all 0.2s ease;
  outline: none;
}

/* Focus ring animation */
.interactive-element:focus-visible {
  outline: 2px solid #3b82f6;
  outline-offset: 2px;
}

.interactive-element:focus-visible::before {
  content: '';
  position: absolute;
  top: -4px;
  left: -4px;
  right: -4px;
  bottom: -4px;
  border: 2px solid #3b82f6;
  border-radius: 8px;
  opacity: 0;
  animation: focusRing 0.3s ease forwards;
}

@keyframes focusRing {
  0% {
    opacity: 0;
    transform: scale(0.95);
  }
  100% {
    opacity: 0.3;
    transform: scale(1);
  }
}

/* Disable focus ring animation for reduced motion */
@media (prefers-reduced-motion: reduce) {
  .interactive-element:focus-visible::before {
    animation: none;
    opacity: 0.3;
    transform: scale(1);
  }
}
```

High contrast mode considerations:

```css
/* High contrast mode support */
@media (prefers-contrast: high) {
  .subtle-animation {
    /* Increase contrast for better visibility */
    border: 2px solid currentColor;
    background: transparent;
  }
  
  .hover-effect:hover {
    /* Ensure sufficient contrast in hover states */
    background: currentColor;
    color: Canvas;
  }
}

/* Forced colors mode */
@media (forced-colors: active) {
  .custom-focus-ring {
    /* Use system colors in forced colors mode */
    outline: 2px solid Highlight;
    outline-offset: 2px;
  }
  
  .interactive-button {
    border: 1px solid ButtonText;
    background: ButtonFace;
    color: ButtonText;
  }
  
  .interactive-button:hover {
    background: Highlight;
    color: HighlightText;
  }
}
```

Animation timing and easing for accessibility:

```css
/* Gentle, accessible animations */
.accessible-transition {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Avoid rapid flashing */
.pulse-animation {
  animation: gentlePulse 2s ease-in-out infinite;
}

@keyframes gentlePulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

/* Ensure animations don't interfere with screen readers */
.sr-safe-animation {
  animation: slideIn 0.5s ease;
}

@keyframes slideIn {
  from {
    transform: translateX(-20px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

/* Pause animations when user is interacting */
.pausable-animation {
  animation-play-state: running;
}

.pausable-animation:hover,
.pausable-animation:focus {
  animation-play-state: paused;
}
```

**Key points:**

- Always test with keyboard navigation and screen readers
- Provide immediate feedback for all interactive states
- Use semantic HTML structure beneath CSS styling
- Implement proper ARIA attributes where needed
- Test with various accessibility tools and user preferences

**Example** comprehensive accessible button:

```css
.accessible-button {
  /* Base styles */
  padding: 0.75rem 1.5rem;
  border: 2px solid #3b82f6;
  background: #3b82f6;
  color: white;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
  
  /* Ensure minimum touch target */
  min-height: 44px;
  min-width: 44px;
}

/* Hover state */
.accessible-button:hover {
  background: #2563eb;
  border-color: #2563eb;
  transform: translateY(-1px);
}

/* Focus state */
.accessible-button:focus-visible {
  outline: 2px solid #f59e0b;
  outline-offset: 2px;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}

/* Active state */
.accessible-button:active {
  transform: translateY(0);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Disabled state */
.accessible-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

/* High contrast mode */
@media (forced-colors: active) {
  .accessible-button {
    border: 1px solid ButtonText;
  }
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .accessible-button {
    transition: none;
    transform: none;
  }
  
  .accessible-button:hover,
  .accessible-button:active {
    transform: none;
  }
}
```

**Conclusion:** Interactive elements require careful balance between visual appeal and accessibility. Modern CSS provides powerful tools for creating engaging interfaces while respecting user preferences and accessibility requirements.

**Next steps:**

- Implement comprehensive testing with assistive technologies
- Create a design system component library with built-in accessibility
- Establish animation guidelines that consider motion sensitivity
- Set up automated accessibility testing in your development workflow

---
