## CSS Subgrid


### Subgrid Syntax and Use Cases

CSS Subgrid allows grid items to participate in the grid layout of their parent container, enabling complex layouts that maintain alignment across multiple levels of nesting. This powerful feature extends CSS Grid's capabilities by allowing child grids to inherit and contribute to their parent's grid structure.

#### Basic Subgrid Syntax

**Fundamental syntax:**

```css
.parent-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(3, 100px);
  gap: 1rem;
}

.child-subgrid {
  display: grid;
  grid-column: 1 / 4; /* Spans 3 columns of parent */
  grid-row: 1 / 3;    /* Spans 2 rows of parent */
  
  /* Inherit parent's column structure */
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
}
```

**Selective inheritance:**

```css
.mixed-subgrid {
  display: grid;
  grid-column: 1 / -1; /* Full width */
  grid-row: 2 / 4;     /* Spans specific rows */
  
  /* Inherit columns, define own rows */
  grid-template-columns: subgrid;
  grid-template-rows: 80px 120px;
  gap: 0.5rem; /* Can override parent's gap */
}
```

#### Card Layout with Subgrid

**Aligned card components:**

```css
.card-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  grid-template-rows: auto;
  gap: 1.5rem;
  padding: 1rem;
}

.card {
  display: grid;
  grid-template-rows: subgrid;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card__image {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card__content {
  padding: 1rem;
  display: grid;
  grid-template-rows: subgrid;
  gap: 0.5rem;
}

.card__title {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0;
}

.card__description {
  color: #6b7280;
  line-height: 1.5;
  margin: 0;
}

.card__actions {
  padding: 1rem;
  border-top: 1px solid #f3f4f6;
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}
```

#### Form Layout with Subgrid

**Complex form alignment:**

```css
.form-container {
  display: grid;
  grid-template-columns: 200px 1fr 200px;
  grid-template-rows: repeat(auto-fit, minmax(60px, auto));
  gap: 1rem;
  max-width: 800px;
}

.form-section {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 1rem;
}

.form-section__header {
  grid-column: 1 / -1;
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 0.5rem;
}

.form-field {
  display: grid;
  grid-template-columns: subgrid;
  align-items: center;
  gap: 0.5rem;
}

.form-field__label {
  font-weight: 500;
  color: #374151;
}

.form-field__input {
  padding: 0.5rem;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  font-size: 1rem;
}

.form-field__input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
}

.form-field__help {
  font-size: 0.875rem;
  color: #6b7280;
}
```

#### Navigation with Subgrid

**Multi-level navigation alignment:**

```css
.navigation {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  grid-template-rows: 60px auto;
  background: #1f2937;
  color: white;
}

.nav-primary {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  align-items: center;
  padding: 0 1rem;
}

.nav-logo {
  grid-column: 1 / 2;
  font-size: 1.5rem;
  font-weight: bold;
}

.nav-links {
  grid-column: 2 / 5;
  display: flex;
  gap: 2rem;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-actions {
  grid-column: 5 / -1;
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.nav-secondary {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  background: #374151;
  padding: 0.5rem 1rem;
}

.nav-breadcrumbs {
  grid-column: 1 / 4;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-search {
  grid-column: 4 / -1;
  display: flex;
  justify-content: flex-end;
}
```

### Inheriting Grid Structure

Subgrid inheritance allows child elements to participate in their parent's grid system while maintaining their own internal layout structure.

#### Column Inheritance

**Inheriting parent columns:**

```css
.magazine-layout {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-template-rows: auto;
  gap: 1rem;
  max-width: 1200px;
  margin: 0 auto;
}

.article-header {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  align-items: center;
  padding: 1rem 0;
  border-bottom: 2px solid #e5e7eb;
}

.article-title {
  grid-column: 1 / 9;
  font-size: 2rem;
  font-weight: 700;
  margin: 0;
}

.article-meta {
  grid-column: 9 / -1;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.25rem;
}

.article-content {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  gap: 1rem;
}

.article-text {
  grid-column: 1 / 8;
  line-height: 1.8;
  font-size: 1.1rem;
}

.article-sidebar {
  grid-column: 8 / -1;
  background: #f9fafb;
  padding: 1rem;
  border-radius: 6px;
}
```

#### Row Inheritance

**Inheriting parent rows:**

```css
.dashboard-layout {
  display: grid;
  grid-template-columns: 250px 1fr;
  grid-template-rows: 60px 1fr 40px;
  height: 100vh;
  gap: 0;
}

.dashboard-header {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  align-items: center;
  background: #1f2937;
  color: white;
  padding: 0 1rem;
}

.dashboard-logo {
  grid-column: 1;
  font-weight: bold;
}

.dashboard-nav {
  grid-column: 2;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.dashboard-main {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
  overflow: hidden;
}

.dashboard-sidebar {
  grid-column: 1;
  background: #f3f4f6;
  padding: 1rem;
  overflow-y: auto;
}

.dashboard-content {
  grid-column: 2;
  padding: 1rem;
  overflow-y: auto;
}
```

#### Partial Inheritance

**Mixing subgrid with explicit sizing:**

```css
.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(auto-fit, 300px);
  gap: 1rem;
}

.featured-product {
  display: grid;
  grid-column: 1 / 3; /* Spans 2 columns */
  grid-row: 1 / 3;    /* Spans 2 rows */
  
  /* Inherit columns, define custom rows */
  grid-template-columns: subgrid;
  grid-template-rows: 200px 1fr 60px;
  
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.product-image {
  grid-column: 1 / -1;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-details {
  grid-column: 1 / -1;
  padding: 1rem;
  display: grid;
  grid-template-columns: subgrid;
  gap: 0.5rem;
}

.product-title {
  grid-column: 1 / -1;
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0;
}

.product-price {
  grid-column: 1;
  font-size: 1.5rem;
  font-weight: 700;
  color: #059669;
}

.product-rating {
  grid-column: 2;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.25rem;
}

.product-actions {
  grid-column: 1 / -1;
  padding: 1rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  gap: 0.5rem;
}
```

#### Advanced Inheritance Patterns

**Nested subgrid hierarchies:**

```css
.layout-container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-template-rows: auto 1fr auto;
  min-height: 100vh;
  gap: 1rem;
}

.page-header {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  background: #1f2937;
  color: white;
  padding: 1rem;
}

.page-content {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  gap: 1rem;
}

.content-main {
  display: grid;
  grid-column: 1 / 9;
  grid-template-columns: subgrid;
  gap: 1rem;
}

.article-grid {
  display: grid;
  grid-column: 1 / -1;
  grid-template-columns: subgrid;
  gap: 1rem;
}

.article-item {
  display: grid;
  grid-column: span 4;
  grid-template-columns: subgrid;
  grid-template-rows: 200px 1fr;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.article-thumbnail {
  grid-column: 1 / -1;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.article-content {
  grid-column: 1 / -1;
  padding: 1rem;
  display: grid;
  grid-template-columns: subgrid;
  gap: 0.5rem;
}

.content-sidebar {
  grid-column: 9 / -1;
  background: #f9fafb;
  padding: 1rem;
  border-radius: 8px;
}
```

#### Responsive Subgrid Patterns

**Adaptive subgrid layouts:**

```css
.responsive-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.responsive-card {
  display: grid;
  grid-template-rows: auto 1fr auto;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

@media (min-width: 768px) {
  .responsive-grid {
    grid-template-columns: repeat(12, 1fr);
  }
  
  .responsive-card {
    grid-template-columns: subgrid;
  }
  
  .card-content {
    display: grid;
    grid-template-columns: subgrid;
    gap: 1rem;
  }
  
  .card-text {
    grid-column: 1 / 8;
  }
  
  .card-meta {
    grid-column: 8 / -1;
  }
}
```

#### Subgrid with Named Lines

**Inheriting named grid lines:**

```css
.main-grid {
  display: grid;
  grid-template-columns: 
    [full-start] 1fr 
    [content-start] repeat(8, 1fr) [content-end] 
    1fr [full-end];
  grid-template-rows: 
    [header-start] auto [header-end]
    [main-start] 1fr [main-end]
    [footer-start] auto [footer-end];
  gap: 1rem;
  min-height: 100vh;
}

.page-section {
  display: grid;
  grid-column: full-start / full-end;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
}

.section-header {
  grid-column: content-start / content-end;
  padding: 2rem 0;
  text-align: center;
}

.section-content {
  display: grid;
  grid-column: content-start / content-end;
  grid-template-columns: subgrid;
  gap: 1rem;
}

.content-block {
  grid-column: span 2;
  background: white;
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

#### Performance Considerations

**Optimizing subgrid layouts:**

```css
/* Minimize layout recalculations */
.efficient-subgrid {
  display: grid;
  grid-template-columns: subgrid;
  grid-template-rows: subgrid;
  
  /* Use transforms for animations instead of changing grid properties */
  transition: transform 0.2s ease;
}

.efficient-subgrid:hover {
  transform: translateY(-2px);
}

/* Avoid deep nesting when possible */
.shallow-subgrid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  grid-template-rows: auto;
}

.shallow-subgrid > .direct-child {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: span 3;
}
```

**Key points:**

- Subgrid enables complex layouts while maintaining alignment across nested elements
- Inheritance can be selective - columns only, rows only, or both
- Named grid lines are preserved through subgrid inheritance
- Gap values can be overridden in subgrid children
- Subgrid works seamlessly with responsive design patterns
- Performance is generally excellent due to browser optimizations
- Browser support is modern (Firefox, Safari, Chrome 117+)

**Conclusion:** CSS Subgrid represents a significant advancement in web layout capabilities, allowing developers to create sophisticated, aligned layouts that were previously difficult or impossible to achieve. By inheriting parent grid structures while maintaining flexibility for custom internal layouts, subgrid enables the creation of complex, maintainable designs that scale across different screen sizes and content variations.

---

