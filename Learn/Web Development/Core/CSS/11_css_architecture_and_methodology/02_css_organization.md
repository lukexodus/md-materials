## CSS Organization


### File Structure and Imports

Proper CSS organization starts with a well-structured file system that promotes maintainability, scalability, and team collaboration.

#### Modular Architecture

**Common folder structures:**

```
styles/
├── base/
│   ├── _reset.css
│   ├── _typography.css
│   └── _variables.css
├── components/
│   ├── _buttons.css
│   ├── _cards.css
│   └── _navigation.css
├── layouts/
│   ├── _header.css
│   ├── _footer.css
│   └── _grid.css
├── pages/
│   ├── _home.css
│   └── _contact.css
├── utilities/
│   ├── _helpers.css
│   └── _responsive.css
└── main.css
```

**Alternative atomic structure:**

```
styles/
├── atoms/
│   ├── _colors.css
│   ├── _typography.css
│   └── _spacing.css
├── molecules/
│   ├── _form-groups.css
│   └── _media-objects.css
├── organisms/
│   ├── _header.css
│   └── _product-grid.css
├── templates/
│   └── _page-layouts.css
└── pages/
    └── _specific-pages.css
```

#### CSS Import Methods

**Native CSS @import:**

```css
/* main.css */
@import url('base/variables.css');
@import url('base/reset.css');
@import url('base/typography.css');
@import url('components/buttons.css');
@import url('layouts/grid.css');
```

**Key points:**

- @import statements must come before all other CSS rules
- Each @import creates an additional HTTP request
- Imports are processed sequentially, affecting load times
- Modern bundlers often handle imports more efficiently

**HTML link method:**

```html
<link rel="stylesheet" href="styles/base/variables.css">
<link rel="stylesheet" href="styles/base/reset.css">
<link rel="stylesheet" href="styles/components/buttons.css">
```

**Build tool imports (Sass/Less):**

```scss
// main.scss
@import 'base/variables';
@import 'base/mixins';
@import 'base/reset';
@import 'components/buttons';
@import 'layouts/grid';
```

#### Import Order Best Practices

**Recommended order:**

1. CSS custom properties/variables
2. CSS resets/normalize
3. Base styles (typography, elements)
4. Layout styles
5. Component styles
6. Utility classes
7. Page-specific styles
8. Print styles

**Example:**

```css
/* Optimal import order */
@import url('base/variables.css');
@import url('base/reset.css');
@import url('base/typography.css');
@import url('layouts/grid.css');
@import url('layouts/header.css');
@import url('components/buttons.css');
@import url('components/forms.css');
@import url('utilities/helpers.css');
@import url('pages/home.css');
@import url('responsive/mobile.css');
```

### CSS Custom Properties for Theming

CSS custom properties (CSS variables) provide a powerful system for creating maintainable, themeable stylesheets.

#### Basic Custom Properties

**Declaration and usage:**

```css
:root {
  /* Color palette */
  --primary-color: #3498db;
  --secondary-color: #2ecc71;
  --accent-color: #e74c3c;
  --text-color: #2c3e50;
  --background-color: #ffffff;
  
  /* Typography */
  --font-family-primary: 'Inter', sans-serif;
  --font-family-secondary: 'Georgia', serif;
  --font-size-base: 16px;
  --line-height-base: 1.6;
  
  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;
}

.button {
  background-color: var(--primary-color);
  color: var(--background-color);
  padding: var(--spacing-sm) var(--spacing-md);
  font-family: var(--font-family-primary);
}
```

#### Advanced Theming Strategies

**Theme switching:**

```css
/* Light theme (default) */
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f8f9fa;
  --text-primary: #212529;
  --text-secondary: #6c757d;
  --border-color: #dee2e6;
}

/* Dark theme */
[data-theme="dark"] {
  --bg-primary: #1a1a1a;
  --bg-secondary: #2d2d2d;
  --text-primary: #ffffff;
  --text-secondary: #b0b0b0;
  --border-color: #404040;
}

/* Component using theme variables */
.card {
  background-color: var(--bg-secondary);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}
```

**Semantic color system:**

```css
:root {
  /* Brand colors */
  --brand-primary: #007bff;
  --brand-secondary: #6c757d;
  --brand-success: #28a745;
  --brand-danger: #dc3545;
  --brand-warning: #ffc107;
  --brand-info: #17a2b8;
  
  /* Semantic mappings */
  --color-interactive: var(--brand-primary);
  --color-success: var(--brand-success);
  --color-error: var(--brand-danger);
  --color-warning: var(--brand-warning);
  
  /* Contextual variations */
  --color-interactive-hover: color-mix(in srgb, var(--color-interactive) 85%, black);
  --color-interactive-active: color-mix(in srgb, var(--color-interactive) 75%, black);
}
```

**Responsive custom properties:**

```css
:root {
  --container-width: 1200px;
  --grid-columns: 12;
  --grid-gap: 1rem;
}

@media (max-width: 768px) {
  :root {
    --container-width: 100%;
    --grid-columns: 6;
    --grid-gap: 0.5rem;
  }
}

.container {
  max-width: var(--container-width);
  display: grid;
  grid-template-columns: repeat(var(--grid-columns), 1fr);
  gap: var(--grid-gap);
}
```

#### Component-Level Theming

**Component-specific variables:**

```css
.button {
  /* Default button variables */
  --button-bg: var(--color-interactive);
  --button-color: white;
  --button-padding: var(--spacing-sm) var(--spacing-md);
  --button-border-radius: 4px;
  --button-font-size: var(--font-size-base);
  
  /* Apply variables */
  background-color: var(--button-bg);
  color: var(--button-color);
  padding: var(--button-padding);
  border-radius: var(--button-border-radius);
  font-size: var(--button-font-size);
}

/* Button variants */
.button--secondary {
  --button-bg: var(--color-secondary);
}

.button--large {
  --button-padding: var(--spacing-md) var(--spacing-lg);
  --button-font-size: 1.125rem;
}
```

### Naming Conventions

Consistent naming conventions improve code readability, maintainability, and team collaboration.

#### BEM (Block Element Modifier)

**Structure:**

```
.block {}
.block__element {}
.block--modifier {}
.block__element--modifier {}
```

**Example:**

```css
/* Block */
.card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
}

/* Elements */
.card__header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
}

.card__title {
  margin: 0;
  font-size: 1.25rem;
}

.card__content {
  padding: 1rem;
}

.card__footer {
  padding: 1rem;
  background: #f8f9fa;
}

/* Modifiers */
.card--featured {
  border-color: #007bff;
  box-shadow: 0 4px 8px rgba(0,123,255,0.1);
}

.card--compact {
  --card-padding: 0.5rem;
}

.card__title--large {
  font-size: 1.5rem;
}
```

#### Atomic CSS / Utility-First

**Structure:**

```css
/* Spacing utilities */
.m-0 { margin: 0; }
.m-1 { margin: 0.25rem; }
.m-2 { margin: 0.5rem; }
.p-0 { padding: 0; }
.p-1 { padding: 0.25rem; }

/* Typography utilities */
.text-sm { font-size: 0.875rem; }
.text-base { font-size: 1rem; }
.text-lg { font-size: 1.125rem; }
.font-bold { font-weight: bold; }

/* Color utilities */
.text-primary { color: var(--color-primary); }
.bg-primary { background-color: var(--color-primary); }
.border-primary { border-color: var(--color-primary); }
```

#### SMACSS (Scalable and Modular Architecture)

**Categories and prefixes:**

```css
/* Base rules - no prefixes */
body, h1, p, a {}

/* Layout rules - l- prefix */
.l-header {}
.l-sidebar {}
.l-content {}

/* Module rules - no prefix */
.navigation {}
.button {}
.card {}

/* State rules - is- prefix */
.is-active {}
.is-hidden {}
.is-loading {}

/* Theme rules - theme- prefix */
.theme-dark {}
.theme-light {}
```

#### Component-Driven Naming

**React/Vue style naming:**

```css
/* Component base */
.Button {}
.Card {}
.Navigation {}

/* Component variants */
.Button-primary {}
.Button-secondary {}
.Card-featured {}

/* Component states */
.Button-isLoading {}
.Card-isExpanded {}
.Navigation-isOpen {}
```

### Documentation Strategies

Comprehensive documentation ensures CSS codebases remain maintainable and accessible to team members.

#### Inline Documentation

**Comment structure:**

```css
/**
 * Button Component
 * 
 * A flexible button component with multiple variants and states.
 * 
 * @example
 *   <button class="button button--primary">Primary Button</button>
 *   <button class="button button--secondary">Secondary Button</button>
 */
.button {
  /* Base button styles */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--button-padding, 0.5rem 1rem);
  border: 2px solid transparent;
  border-radius: var(--button-border-radius, 4px);
  background-color: var(--button-bg, #007bff);
  color: var(--button-color, white);
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

/**
 * Primary button variant
 * Used for main call-to-action buttons
 */
.button--primary {
  --button-bg: var(--color-primary);
  --button-color: white;
}

/**
 * Secondary button variant
 * Used for secondary actions
 */
.button--secondary {
  --button-bg: transparent;
  --button-color: var(--color-primary);
  border-color: var(--color-primary);
}
```

#### Section Organization

**File header documentation:**

```css
/**
 * ==========================================================================
 * BUTTON COMPONENT
 * ==========================================================================
 * 
 * Table of Contents:
 * 1. Base button styles
 * 2. Button variants
 * 3. Button sizes
 * 4. Button states
 * 5. Button groups
 * 
 * Dependencies:
 * - CSS custom properties from variables.css
 * - Reset styles from reset.css
 * 
 * Browser Support: IE11+, Modern browsers
 * Last Updated: 2024-01-15
 * Author: Design System Team
 */

/* ==========================================================================
   1. BASE BUTTON STYLES
   ========================================================================== */

.button {
  /* Base implementation */
}

/* ==========================================================================
   2. BUTTON VARIANTS
   ========================================================================== */

.button--primary {
  /* Primary variant */
}
```

#### Living Style Guides

**CSS documentation with examples:**

```css
/**
 * Color Palette
 * 
 * Primary Colors:
 * - Primary: #007bff (Use for main actions, links)
 * - Secondary: #6c757d (Use for secondary actions)
 * - Success: #28a745 (Use for positive feedback)
 * - Danger: #dc3545 (Use for errors, destructive actions)
 * 
 * Usage Guidelines:
 * - Always use CSS custom properties
 * - Maintain minimum contrast ratio of 4.5:1
 * - Test with color blindness simulators
 * 
 * @example
 *   .primary-text { color: var(--color-primary); }
 *   .success-bg { background-color: var(--color-success); }
 */
:root {
  --color-primary: #007bff;
  --color-secondary: #6c757d;
  --color-success: #28a745;
  --color-danger: #dc3545;
}
```

#### Automated Documentation

**CSS documentation tools integration:**

```css
/**
 * @name Button
 * @description A flexible button component
 * @markup
 *   <button class="button">Default Button</button>
 *   <button class="button button--primary">Primary Button</button>
 * @modifiers
 *   .button--primary - Primary button style
 *   .button--secondary - Secondary button style
 *   .button--large - Large button size
 */
.button {
  /* Implementation */
}
```

#### Maintenance Documentation

**Change log and versioning:**

```css
/**
 * CHANGELOG
 * 
 * v2.1.0 (2024-01-15)
 * - Added support for CSS custom properties
 * - Improved accessibility with focus states
 * - Added new button variants
 * 
 * v2.0.0 (2023-12-01)
 * - Breaking: Removed legacy button classes
 * - Restructured modifier naming convention
 * - Added dark theme support
 * 
 * BREAKING CHANGES:
 * - .btn-primary renamed to .button--primary
 * - Removed .btn-outline-* classes
 */
```

**Key points:**

- Use consistent comment formatting across all files
- Document browser support requirements and known issues
- Include usage examples and implementation guidelines
- Maintain changelogs for major component updates
- Document dependencies and relationships between files
- Provide accessibility notes and considerations

**Conclusion:** Effective CSS organization requires careful planning of file structure, thoughtful use of custom properties for theming, consistent naming conventions, and comprehensive documentation. These practices create maintainable, scalable stylesheets that facilitate team collaboration and long-term project success.

---
