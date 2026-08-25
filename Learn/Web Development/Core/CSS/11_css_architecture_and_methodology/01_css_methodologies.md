## CSS Methodologies


### BEM (Block Element Modifier)

BEM is a methodology that creates a clear, structured naming convention for CSS classes, making code more maintainable and predictable.

#### Core BEM Concepts

**Block:** A standalone entity that is meaningful on its own. Represents a component or widget.

```css
/* Block: A reusable component */
.menu {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
}

.card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
}

.search-form {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
```

**Element:** A part of a block that has no standalone meaning and is semantically tied to its block.

```css
/* Elements: Parts of the block */
.menu__item {
  margin-right: 1rem;
}

.menu__link {
  color: #333;
  text-decoration: none;
  padding: 0.5rem 1rem;
  display: block;
}

.card__header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
}

.card__title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.card__content {
  padding: 1rem;
}

.card__footer {
  padding: 1rem;
  background: #f8f9fa;
  border-top: 1px solid #eee;
}

.search-form__input {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.search-form__button {
  padding: 0.5rem 1rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```

**Modifier:** A flag on a block or element that changes appearance, behavior, or state.

```css
/* Block modifiers */
.menu--vertical {
  flex-direction: column;
}

.menu--dark {
  background: #333;
}

.card--featured {
  border: 2px solid #007bff;
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.15);
}

.card--compact {
  font-size: 0.875rem;
}

.search-form--inline {
  display: inline-flex;
  width: auto;
}

/* Element modifiers */
.menu__link--active {
  color: #007bff;
  font-weight: 600;
}

.menu__link--disabled {
  color: #999;
  cursor: not-allowed;
  pointer-events: none;
}

.card__title--large {
  font-size: 1.5rem;
}

.search-form__button--secondary {
  background: #6c757d;
}
```

#### Advanced BEM Patterns

**Nested elements:**

```css
/* Avoid deeply nested elements */
/* Instead of .block__element__subelement */
.article__content {
  padding: 1rem;
}

.article__paragraph {
  margin-bottom: 1rem;
  line-height: 1.6;
}

.article__link {
  color: #007bff;
  text-decoration: underline;
}
```

**Mix of blocks and elements:**

```css
/* HTML: <div class="header__logo site-logo"> */
.header__logo {
  margin-right: auto;
}

.site-logo {
  display: block;
  width: 120px;
  height: 40px;
}

.site-logo__image {
  width: 100%;
  height: auto;
}
```

**Boolean modifiers:**

```css
.modal--open {
  display: block;
}

.button--loading {
  pointer-events: none;
  opacity: 0.6;
}

.form__field--required .form__label::after {
  content: " *";
  color: #dc3545;
}
```

**Key-value modifiers:**

```css
.button--size-small {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.button--size-large {
  padding: 0.75rem 1.5rem;
  font-size: 1.125rem;
}

.grid--columns-3 {
  grid-template-columns: repeat(3, 1fr);
}

.grid--columns-4 {
  grid-template-columns: repeat(4, 1fr);
}
```

### SMACSS Principles

SMACSS (Scalable and Modular Architecture for CSS) categorizes CSS rules into five types, creating a systematic approach to organizing styles.

#### Base Rules

Base rules are the defaults for HTML elements and should not include class or ID selectors.

```css
/* Base rules - element selectors only */
html {
  box-sizing: border-box;
  font-size: 16px;
}

*,
*::before,
*::after {
  box-sizing: inherit;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
  color: #333;
  background: #fff;
}

h1, h2, h3, h4, h5, h6 {
  margin: 0 0 1rem 0;
  font-weight: 600;
  line-height: 1.2;
}

p {
  margin: 0 0 1rem 0;
}

a {
  color: #007bff;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

img {
  max-width: 100%;
  height: auto;
}

button {
  font-family: inherit;
  cursor: pointer;
}
```

#### Layout Rules

Layout rules divide the page into sections and hold one or more modules together.

```css
/* Layout rules - major page sections */
.l-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: white;
  border-bottom: 1px solid #eee;
}

.l-navigation {
  display: flex;
  align-items: center;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.l-main {
  min-height: calc(100vh - 160px);
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.l-sidebar {
  width: 300px;
  padding: 1rem;
  background: #f8f9fa;
}

.l-content {
  flex: 1;
  padding: 1rem;
}

.l-footer {
  background: #333;
  color: white;
  padding: 2rem 1rem;
  text-align: center;
}

/* Grid layout system */
.l-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(12, 1fr);
}

.l-grid--2-columns {
  grid-template-columns: 1fr 300px;
}

.l-grid--3-columns {
  grid-template-columns: 200px 1fr 300px;
}
```

#### Module Rules

Module rules are the reusable, modular parts of the design. They are the meat of the page.

```css
/* Module rules - reusable components */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5rem 1rem;
  border: 2px solid transparent;
  border-radius: 4px;
  background: #007bff;
  color: white;
  font-size: 1rem;
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.15s ease;
}

.button:hover {
  background: #0056b3;
  transform: translateY(-1px);
}

.card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.navigation {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.navigation ul {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 1rem;
}

.navigation a {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  transition: background-color 0.15s ease;
}

.navigation a:hover {
  background: #f8f9fa;
}

.form-group {
  margin-bottom: 1rem;
}

.form-label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.form-input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 1rem;
}

.form-input:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}
```

#### State Rules

State rules describe how modules or layouts will look when in a particular state.

```css
/* State rules - dynamic states */
.is-hidden {
  display: none !important;
}

.is-visible {
  display: block !important;
}

.is-loading {
  pointer-events: none;
  opacity: 0.6;
  cursor: wait;
}

.is-loading::after {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 20px;
  height: 20px;
  margin: -10px 0 0 -10px;
  border: 2px solid #ccc;
  border-top-color: #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.is-active {
  background: #007bff;
  color: white;
}

.is-disabled {
  opacity: 0.5;
  pointer-events: none;
  cursor: not-allowed;
}

.is-error {
  border-color: #dc3545;
  background: #fff5f5;
}

.is-success {
  border-color: #28a745;
  background: #f0fff4;
}

.is-expanded {
  max-height: none;
  overflow: visible;
}

.is-collapsed {
  max-height: 0;
  overflow: hidden;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

#### Theme Rules

Theme rules describe how modules or layouts might look with different themes.

```css
/* Theme rules - visual variations */
.theme-dark {
  --bg-primary: #1a1a1a;
  --bg-secondary: #2d2d2d;
  --text-primary: #ffffff;
  --text-secondary: #b0b0b0;
  --border-color: #404040;
  --shadow: rgba(255, 255, 255, 0.1);
}

.theme-light {
  --bg-primary: #ffffff;
  --bg-secondary: #f8f9fa;
  --text-primary: #212529;
  --text-secondary: #6c757d;
  --border-color: #dee2e6;
  --shadow: rgba(0, 0, 0, 0.1);
}

.theme-high-contrast {
  --bg-primary: #000000;
  --bg-secondary: #ffffff;
  --text-primary: #ffffff;
  --text-secondary: #000000;
  --border-color: #ffffff;
  --focus-color: #ffff00;
}

/* Theme-aware components */
.card {
  background: var(--bg-primary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
  box-shadow: 0 2px 4px var(--shadow);
}

.button {
  background: var(--text-primary);
  color: var(--bg-primary);
  border: 2px solid var(--text-primary);
}
```

### Atomic CSS Concepts

Atomic CSS is a methodology where each CSS class has a single, specific purpose, creating a utility-first approach to styling.

#### Utility Classes Structure

**Spacing utilities:**

```css
/* Margin utilities */
.m-0 { margin: 0; }
.m-1 { margin: 0.25rem; }
.m-2 { margin: 0.5rem; }
.m-3 { margin: 0.75rem; }
.m-4 { margin: 1rem; }
.m-5 { margin: 1.25rem; }
.m-6 { margin: 1.5rem; }
.m-8 { margin: 2rem; }
.m-10 { margin: 2.5rem; }
.m-12 { margin: 3rem; }

/* Directional margins */
.mt-0 { margin-top: 0; }
.mt-1 { margin-top: 0.25rem; }
.mt-2 { margin-top: 0.5rem; }
.mr-0 { margin-right: 0; }
.mr-1 { margin-right: 0.25rem; }
.mb-0 { margin-bottom: 0; }
.ml-0 { margin-left: 0; }

/* Padding utilities */
.p-0 { padding: 0; }
.p-1 { padding: 0.25rem; }
.p-2 { padding: 0.5rem; }
.p-3 { padding: 0.75rem; }
.p-4 { padding: 1rem; }

/* Directional padding */
.pt-1 { padding-top: 0.25rem; }
.pr-1 { padding-right: 0.25rem; }
.pb-1 { padding-bottom: 0.25rem; }
.pl-1 { padding-left: 0.25rem; }

/* Axis padding */
.px-1 { padding-left: 0.25rem; padding-right: 0.25rem; }
.py-1 { padding-top: 0.25rem; padding-bottom: 0.25rem; }
```

**Typography utilities:**

```css
/* Font sizes */
.text-xs { font-size: 0.75rem; line-height: 1rem; }
.text-sm { font-size: 0.875rem; line-height: 1.25rem; }
.text-base { font-size: 1rem; line-height: 1.5rem; }
.text-lg { font-size: 1.125rem; line-height: 1.75rem; }
.text-xl { font-size: 1.25rem; line-height: 1.75rem; }
.text-2xl { font-size: 1.5rem; line-height: 2rem; }
.text-3xl { font-size: 1.875rem; line-height: 2.25rem; }

/* Font weights */
.font-thin { font-weight: 100; }
.font-light { font-weight: 300; }
.font-normal { font-weight: 400; }
.font-medium { font-weight: 500; }
.font-semibold { font-weight: 600; }
.font-bold { font-weight: 700; }
.font-extrabold { font-weight: 800; }

/* Text alignment */
.text-left { text-align: left; }
.text-center { text-align: center; }
.text-right { text-align: right; }
.text-justify { text-align: justify; }

/* Text decoration */
.underline { text-decoration: underline; }
.line-through { text-decoration: line-through; }
.no-underline { text-decoration: none; }

/* Text transform */
.uppercase { text-transform: uppercase; }
.lowercase { text-transform: lowercase; }
.capitalize { text-transform: capitalize; }
.normal-case { text-transform: none; }
```

**Layout utilities:**

```css
/* Display utilities */
.block { display: block; }
.inline-block { display: inline-block; }
.inline { display: inline; }
.flex { display: flex; }
.inline-flex { display: inline-flex; }
.grid { display: grid; }
.inline-grid { display: inline-grid; }
.hidden { display: none; }

/* Flexbox utilities */
.flex-row { flex-direction: row; }
.flex-col { flex-direction: column; }
.flex-wrap { flex-wrap: wrap; }
.flex-nowrap { flex-wrap: nowrap; }
.items-start { align-items: flex-start; }
.items-center { align-items: center; }
.items-end { align-items: flex-end; }
.items-stretch { align-items: stretch; }
.justify-start { justify-content: flex-start; }
.justify-center { justify-content: center; }
.justify-end { justify-content: flex-end; }
.justify-between { justify-content: space-between; }
.justify-around { justify-content: space-around; }

/* Position utilities */
.static { position: static; }
.fixed { position: fixed; }
.absolute { position: absolute; }
.relative { position: relative; }
.sticky { position: sticky; }

/* Width and height utilities */
.w-0 { width: 0; }
.w-1 { width: 0.25rem; }
.w-2 { width: 0.5rem; }
.w-4 { width: 1rem; }
.w-8 { width: 2rem; }
.w-16 { width: 4rem; }
.w-32 { width: 8rem; }
.w-64 { width: 16rem; }
.w-auto { width: auto; }
.w-full { width: 100%; }
.w-screen { width: 100vw; }

.h-0 { height: 0; }
.h-1 { height: 0.25rem; }
.h-2 { height: 0.5rem; }
.h-4 { height: 1rem; }
.h-8 { height: 2rem; }
.h-16 { height: 4rem; }
.h-32 { height: 8rem; }
.h-64 { height: 16rem; }
.h-auto { height: auto; }
.h-full { height: 100%; }
.h-screen { height: 100vh; }
```

**Color utilities:**

```css
/* Text colors */
.text-black { color: #000000; }
.text-white { color: #ffffff; }
.text-gray-100 { color: #f7fafc; }
.text-gray-200 { color: #edf2f7; }
.text-gray-300 { color: #e2e8f0; }
.text-gray-400 { color: #cbd5e0; }
.text-gray-500 { color: #a0aec0; }
.text-gray-600 { color: #718096; }
.text-gray-700 { color: #4a5568; }
.text-gray-800 { color: #2d3748; }
.text-gray-900 { color: #1a202c; }

.text-red-500 { color: #f56565; }
.text-blue-500 { color: #4299e1; }
.text-green-500 { color: #48bb78; }
.text-yellow-500 { color: #ed8936; }
.text-purple-500 { color: #9f7aea; }

/* Background colors */
.bg-black { background-color: #000000; }
.bg-white { background-color: #ffffff; }
.bg-gray-100 { background-color: #f7fafc; }
.bg-gray-200 { background-color: #edf2f7; }
.bg-red-500 { background-color: #f56565; }
.bg-blue-500 { background-color: #4299e1; }
.bg-green-500 { background-color: #48bb78; }
.bg-transparent { background-color: transparent; }

/* Border colors */
.border-black { border-color: #000000; }
.border-white { border-color: #ffffff; }
.border-gray-200 { border-color: #edf2f7; }
.border-gray-300 { border-color: #e2e8f0; }
.border-red-500 { border-color: #f56565; }
.border-blue-500 { border-color: #4299e1; }
```

#### Responsive Atomic Classes

**Breakpoint prefixes:**

```css
/* Small screens and up */
@media (min-width: 640px) {
  .sm\:block { display: block; }
  .sm\:flex { display: flex; }
  .sm\:hidden { display: none; }
  .sm\:text-left { text-align: left; }
  .sm\:text-center { text-align: center; }
  .sm\:w-1\/2 { width: 50%; }
  .sm\:w-full { width: 100%; }
}

/* Medium screens and up */
@media (min-width: 768px) {
  .md\:block { display: block; }
  .md\:flex { display: flex; }
  .md\:grid { display: grid; }
  .md\:w-1\/3 { width: 33.333333%; }
  .md\:w-2\/3 { width: 66.666667%; }
  .md\:p-8 { padding: 2rem; }
}

/* Large screens and up */
@media (min-width: 1024px) {
  .lg\:block { display: block; }
  .lg\:flex { display: flex; }
  .lg\:w-1\/4 { width: 25%; }
  .lg\:w-3\/4 { width: 75%; }
  .lg\:text-xl { font-size: 1.25rem; line-height: 1.75rem; }
}
```

### Component-Based Architecture

Component-based architecture treats UI elements as independent, reusable components with their own styles and behavior.

#### Component Structure

**Base component definition:**

```css
/* Button component */
.Button {
  /* Base styles */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 2px solid transparent;
  border-radius: var(--border-radius, 4px);
  padding: var(--button-padding, 0.5rem 1rem);
  font-family: inherit;
  font-size: var(--button-font-size, 1rem);
  font-weight: var(--button-font-weight, 500);
  line-height: 1;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.15s ease;
  
  /* Default theme */
  --button-bg: #007bff;
  --button-color: white;
  --button-border: transparent;
  
  background-color: var(--button-bg);
  color: var(--button-color);
  border-color: var(--button-border);
}

.Button:hover {
  --button-bg: #0056b3;
  transform: translateY(-1px);
}

.Button:active {
  --button-bg: #004085;
  transform: translateY(0);
}

.Button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.25);
}

.Button:disabled {
  --button-bg: #e9ecef;
  --button-color: #6c757d;
  cursor: not-allowed;
  transform: none;
}
```

**Component variants:**

```css
/* Primary variant */
.Button--primary {
  --button-bg: #007bff;
  --button-color: white;
}

/* Secondary variant */
.Button--secondary {
  --button-bg: #6c757d;
  --button-color: white;
}

/* Outlined variant */
.Button--outlined {
  --button-bg: transparent;
  --button-color: #007bff;
  --button-border: #007bff;
}

.Button--outlined:hover {
  --button-bg: #007bff;
  --button-color: white;
}

/* Ghost variant */
.Button--ghost {
  --button-bg: transparent;
  --button-color: #007bff;
  --button-border: transparent;
}

.Button--ghost:hover {
  --button-bg: rgba(0, 123, 255, 0.1);
}
```

**Component sizes:**

```css
/* Size variants */
.Button--small {
  --button-padding: 0.25rem 0.5rem;
  --button-font-size: 0.875rem;
  --border-radius: 3px;
}

.Button--large {
  --button-padding: 0.75rem 1.5rem;
  --button-font-size: 1.125rem;
  --border-radius: 6px;
}

.Button--block {
  width: 100%;
}
```

**Component states:**

```css
/* State variants */
.Button--loading {
  pointer-events: none;
  position: relative;
}

.Button--loading::after {
  content: "";
  position: absolute;
  width: 16px;
  height: 16px;
  border: 2px solid currentColor;
  border-top-color: transparent;
  border-radius: 50%;
  animation: button-spin 0.8s linear infinite;
}

@keyframes button-spin {
  to { transform: rotate(360deg); }
}

.Button--success {
  --button-bg: #28a745;
  --button-color: white;
}

.Button--danger {
  --button-bg: #dc3545;
  --button-color: white;
}

.Button--warning {
  --button-bg: #ffc107;
  --button-color: #212529;
}
```

#### Advanced Component Patterns

**Compound components:**

```css
/* Card compound component */
.Card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.Card-header {
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e2e8f0;
  background: #f8f9fa;
}

.Card-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1a202c;
}

.Card-subtitle {
  margin: 0.25rem 0 0 0;
  font-size: 0.875rem;
  color: #718096;
}

.Card-body {
  padding: 1.5rem;
}

.Card-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e2e8f0;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* Card variants */
.Card--elevated {
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.Card--bordered {
  border: 2px solid #e2e8f0;
}

.Card--interactive {
  cursor: pointer;
  transition: all 0.2s ease;
}

.Card--interactive:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}
```

**Component composition:**

```css
/* Form component system */
.Form {
  max-width: 600px;
}

.Form-group {
  margin-bottom: 1.5rem;
}

.Form-label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #374151;
}

.Form-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.15s ease;
}

.Form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.Form-input--error {
  border-color: #ef4444;
}

.Form-input--error:focus {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.Form-error {
  margin-top: 0.5rem;
  font-size: 0.875rem;
  color: #ef4444;
}

.Form-help {
  margin-top: 0.5rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.Form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
}
```

**Key points:**

- Each methodology serves different project needs and team preferences
- BEM provides clear naming conventions and component boundaries
- SMACSS offers systematic organization and categorization
- Atomic CSS maximizes reusability and reduces CSS file size
- Component-based architecture aligns with modern frontend frameworks
- Mix methodologies based on project requirements and team workflow
- Consistency within chosen methodology is more important than the methodology itself

**Conclusion:** CSS methodologies provide structured approaches to writing maintainable, scalable stylesheets. The choice between BEM, SMACSS, Atomic CSS, and component-based architecture depends on project requirements, team preferences, and existing infrastructure. Understanding these methodologies enables developers to make informed decisions about CSS organization and create more maintainable codebases.

---

