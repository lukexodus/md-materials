## Semantic HTML via JavaScript


### Dynamic Semantic Structure Creation

JavaScript enables programmatic generation of semantic HTML elements that maintain meaningful document structure. Use `document.createElement()` with appropriate semantic tags rather than generic containers:

```javascript
// Create semantic article structure
const article = document.createElement('article');
const header = document.createElement('header');
const h2 = document.createElement('h2');
const time = document.createElement('time');
time.setAttribute('datetime', '2025-12-15');
time.textContent = 'December 15, 2025';

header.appendChild(h2);
header.appendChild(time);
article.appendChild(header);
```

### Preserving Semantic Meaning in DOM Manipulation

When manipulating existing DOM structures, maintain semantic integrity by respecting document outline and hierarchy:

```javascript
// Maintain proper heading hierarchy
function insertSection(parentElement, level) {
  const section = document.createElement('section');
  const heading = document.createElement(`h${level}`);
  section.appendChild(heading);
  parentElement.appendChild(section);
  return section;
}
```

### ARIA Attributes and Roles Management

JavaScript manages ARIA attributes to enhance semantic meaning for assistive technologies:

```javascript
// Dynamic ARIA state management
const button = document.querySelector('[aria-expanded]');
button.addEventListener('click', () => {
  const expanded = button.getAttribute('aria-expanded') === 'true';
  button.setAttribute('aria-expanded', !expanded);
  
  const controls = document.getElementById(button.getAttribute('aria-controls'));
  controls.hidden = expanded;
});

// Live region updates
const status = document.querySelector('[role="status"]');
status.setAttribute('aria-live', 'polite');
status.textContent = 'Content updated';
```

### Semantic Navigation Patterns

Construct navigation structures that maintain semantic clarity:

```javascript
// Build semantic navigation
function createNavigation(items) {
  const nav = document.createElement('nav');
  nav.setAttribute('aria-label', 'Main navigation');
  
  const ul = document.createElement('ul');
  items.forEach(item => {
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = item.url;
    a.textContent = item.label;
    li.appendChild(a);
    ul.appendChild(li);
  });
  
  nav.appendChild(ul);
  return nav;
}
```

### Form Semantics and Validation

JavaScript enhances form semantics through proper labeling, fieldset grouping, and validation feedback:

```javascript
// Semantic form construction
function createFormField(config) {
  const wrapper = document.createElement('div');
  
  const label = document.createElement('label');
  label.setAttribute('for', config.id);
  label.textContent = config.labelText;
  
  const input = document.createElement('input');
  input.id = config.id;
  input.type = config.type;
  input.name = config.name;
  input.required = config.required;
  
  if (config.describedBy) {
    const description = document.createElement('span');
    description.id = `${config.id}-desc`;
    description.textContent = config.describedBy;
    input.setAttribute('aria-describedby', description.id);
    wrapper.appendChild(description);
  }
  
  wrapper.appendChild(label);
  wrapper.appendChild(input);
  return wrapper;
}

// Validation with semantic error messaging
function displayError(input, message) {
  const errorId = `${input.id}-error`;
  let errorElement = document.getElementById(errorId);
  
  if (!errorElement) {
    errorElement = document.createElement('span');
    errorElement.id = errorId;
    errorElement.setAttribute('role', 'alert');
    errorElement.className = 'error-message';
    input.parentElement.appendChild(errorElement);
  }
  
  input.setAttribute('aria-invalid', 'true');
  input.setAttribute('aria-describedby', errorId);
  errorElement.textContent = message;
}
```

### Landmark Regions and Document Structure

Programmatically establish landmark regions for improved navigation:

```javascript
// Create semantic page structure
function buildPageStructure() {
  const container = document.createElement('div');
  
  const header = document.createElement('header');
  header.setAttribute('role', 'banner');
  
  const main = document.createElement('main');
  main.setAttribute('role', 'main');
  main.id = 'main-content';
  
  const aside = document.createElement('aside');
  aside.setAttribute('role', 'complementary');
  aside.setAttribute('aria-label', 'Related content');
  
  const footer = document.createElement('footer');
  footer.setAttribute('role', 'contentinfo');
  
  container.append(header, main, aside, footer);
  return container;
}
```

### Lists and Grouping Elements

Maintain semantic list structures when adding dynamic content:

```javascript
// Semantic list management
class SemanticList {
  constructor(type = 'ul') {
    this.list = document.createElement(type);
  }
  
  addItem(content, subItems = []) {
    const li = document.createElement('li');
    
    if (typeof content === 'string') {
      li.textContent = content;
    } else {
      li.appendChild(content);
    }
    
    if (subItems.length > 0) {
      const subList = document.createElement(this.list.tagName);
      subItems.forEach(subContent => {
        const subLi = document.createElement('li');
        subLi.textContent = subContent;
        subList.appendChild(subLi);
      });
      li.appendChild(subList);
    }
    
    this.list.appendChild(li);
  }
  
  getList() {
    return this.list;
  }
}

// Description list for key-value pairs
function createDescriptionList(data) {
  const dl = document.createElement('dl');
  
  Object.entries(data).forEach(([term, description]) => {
    const dt = document.createElement('dt');
    dt.textContent = term;
    
    const dd = document.createElement('dd');
    dd.textContent = description;
    
    dl.appendChild(dt);
    dl.appendChild(dd);
  });
  
  return dl;
}
```

### Tables with Proper Structure

Generate tables that maintain semantic relationships between headers and data:

```javascript
// Semantic table construction
function createSemanticTable(data, headers) {
  const table = document.createElement('table');
  
  // Caption for context
  const caption = document.createElement('caption');
  caption.textContent = data.title;
  table.appendChild(caption);
  
  // Table header
  const thead = document.createElement('thead');
  const headerRow = document.createElement('tr');
  headers.forEach(header => {
    const th = document.createElement('th');
    th.textContent = header.label;
    th.scope = 'col';
    if (header.abbr) th.setAttribute('abbr', header.abbr);
    headerRow.appendChild(th);
  });
  thead.appendChild(headerRow);
  table.appendChild(thead);
  
  // Table body
  const tbody = document.createElement('tbody');
  data.rows.forEach(row => {
    const tr = document.createElement('tr');
    row.forEach((cell, index) => {
      const td = document.createElement('td');
      td.textContent = cell;
      if (headers[index].id) {
        td.setAttribute('headers', headers[index].id);
      }
      tr.appendChild(td);
    });
    tbody.appendChild(tr);
  });
  table.appendChild(tbody);
  
  return table;
}
```

### Interactive Widgets and Components

Build accessible interactive components with proper semantic roles and states:

```javascript
// Accordion pattern
class SemanticAccordion {
  constructor(items) {
    this.element = document.createElement('div');
    this.element.className = 'accordion';
    
    items.forEach((item, index) => {
      const section = this.createAccordionItem(item, index);
      this.element.appendChild(section);
    });
  }
  
  createAccordionItem(item, index) {
    const heading = document.createElement('h3');
    
    const button = document.createElement('button');
    button.id = `accordion-btn-${index}`;
    button.setAttribute('aria-expanded', 'false');
    button.setAttribute('aria-controls', `accordion-panel-${index}`);
    button.textContent = item.title;
    
    const panel = document.createElement('div');
    panel.id = `accordion-panel-${index}`;
    panel.setAttribute('role', 'region');
    panel.setAttribute('aria-labelledby', button.id);
    panel.hidden = true;
    panel.innerHTML = item.content;
    
    button.addEventListener('click', () => {
      const expanded = button.getAttribute('aria-expanded') === 'true';
      button.setAttribute('aria-expanded', !expanded);
      panel.hidden = expanded;
    });
    
    heading.appendChild(button);
    
    const wrapper = document.createElement('div');
    wrapper.append(heading, panel);
    return wrapper;
  }
  
  getElement() {
    return this.element;
  }
}

// Tab interface
class SemanticTabs {
  constructor(tabs) {
    this.container = document.createElement('div');
    this.tablist = document.createElement('div');
    this.tablist.setAttribute('role', 'tablist');
    this.tablist.setAttribute('aria-label', 'Content tabs');
    
    this.panels = [];
    
    tabs.forEach((tab, index) => {
      this.createTab(tab, index);
    });
    
    this.container.appendChild(this.tablist);
    this.panels.forEach(panel => this.container.appendChild(panel));
  }
  
  createTab(tab, index) {
    const button = document.createElement('button');
    button.id = `tab-${index}`;
    button.setAttribute('role', 'tab');
    button.setAttribute('aria-selected', index === 0 ? 'true' : 'false');
    button.setAttribute('aria-controls', `panel-${index}`);
    button.textContent = tab.label;
    button.tabIndex = index === 0 ? 0 : -1;
    
    const panel = document.createElement('div');
    panel.id = `panel-${index}`;
    panel.setAttribute('role', 'tabpanel');
    panel.setAttribute('aria-labelledby', button.id);
    panel.hidden = index !== 0;
    panel.innerHTML = tab.content;
    
    button.addEventListener('click', () => this.selectTab(index));
    
    this.tablist.appendChild(button);
    this.panels.push(panel);
  }
  
  selectTab(index) {
    const buttons = this.tablist.querySelectorAll('[role="tab"]');
    buttons.forEach((btn, i) => {
      const selected = i === index;
      btn.setAttribute('aria-selected', selected);
      btn.tabIndex = selected ? 0 : -1;
      this.panels[i].hidden = !selected;
    });
  }
  
  getElement() {
    return this.container;
  }
}
```

### Dialog and Modal Patterns

Create modal dialogs that maintain semantic focus management:

```javascript
// Semantic modal dialog
class SemanticDialog {
  constructor(config) {
    this.dialog = document.createElement('div');
    this.dialog.setAttribute('role', 'dialog');
    this.dialog.setAttribute('aria-modal', 'true');
    this.dialog.setAttribute('aria-labelledby', 'dialog-title');
    this.dialog.hidden = true;
    
    const title = document.createElement('h2');
    title.id = 'dialog-title';
    title.textContent = config.title;
    
    const content = document.createElement('div');
    content.innerHTML = config.content;
    
    const actions = document.createElement('div');
    actions.setAttribute('role', 'group');
    actions.setAttribute('aria-label', 'Dialog actions');
    
    const closeBtn = document.createElement('button');
    closeBtn.textContent = 'Close';
    closeBtn.addEventListener('click', () => this.close());
    actions.appendChild(closeBtn);
    
    this.dialog.append(title, content, actions);
    this.previousFocus = null;
  }
  
  open() {
    this.previousFocus = document.activeElement;
    this.dialog.hidden = false;
    
    // Focus first focusable element
    const focusable = this.dialog.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
    if (focusable) focusable.focus();
    
    // Trap focus
    this.dialog.addEventListener('keydown', this.trapFocus.bind(this));
  }
  
  close() {
    this.dialog.hidden = true;
    if (this.previousFocus) {
      this.previousFocus.focus();
    }
  }
  
  trapFocus(e) {
    if (e.key !== 'Tab') return;
    
    const focusable = Array.from(
      this.dialog.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    );
    
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }
  
  getElement() {
    return this.dialog;
  }
}
```

### Progressive Enhancement Strategies

Layer semantic HTML with JavaScript enhancements while preserving baseline functionality:

```javascript
// Progressive enhancement pattern
function enhanceElement(element) {
  // Check if already enhanced
  if (element.dataset.enhanced === 'true') return;
  
  // Preserve semantic HTML baseline
  const baseContent = element.cloneNode(true);
  
  // Add enhancements
  if (element.matches('[data-enhance="accordion"]')) {
    enhanceAsAccordion(element);
  } else if (element.matches('[data-enhance="tabs"]')) {
    enhanceAsTabs(element);
  }
  
  element.dataset.enhanced = 'true';
  
  // Store baseline for fallback
  element.dataset.baseline = baseContent.outerHTML;
}

function enhanceAsAccordion(element) {
  const sections = element.querySelectorAll('section');
  sections.forEach((section, index) => {
    const heading = section.querySelector('h2, h3, h4, h5, h6');
    if (!heading) return;
    
    const button = document.createElement('button');
    button.textContent = heading.textContent;
    button.setAttribute('aria-expanded', 'false');
    button.setAttribute('aria-controls', `section-${index}`);
    
    const content = document.createElement('div');
    content.id = `section-${index}`;
    content.innerHTML = section.innerHTML.replace(heading.outerHTML, '');
    content.hidden = true;
    
    section.innerHTML = '';
    heading.innerHTML = '';
    heading.appendChild(button);
    section.append(heading, content);
    
    button.addEventListener('click', () => {
      const expanded = button.getAttribute('aria-expanded') === 'true';
      button.setAttribute('aria-expanded', !expanded);
      content.hidden = expanded;
    });
  });
}
```

### Data Attributes for Semantic Context

Use data attributes to maintain semantic relationships in dynamic content:

```javascript
// Semantic data relationships
function createRelatedContent(mainContent, related) {
  const article = document.createElement('article');
  article.id = mainContent.id;
  article.dataset.contentType = mainContent.type;
  article.dataset.published = mainContent.date;
  
  const header = document.createElement('header');
  const h2 = document.createElement('h2');
  h2.textContent = mainContent.title;
  header.appendChild(h2);
  
  const content = document.createElement('div');
  content.innerHTML = mainContent.body;
  
  article.append(header, content);
  
  if (related.length > 0) {
    const aside = document.createElement('aside');
    aside.setAttribute('aria-labelledby', 'related-heading');
    aside.dataset.relatesTo = mainContent.id;
    
    const heading = document.createElement('h3');
    heading.id = 'related-heading';
    heading.textContent = 'Related Articles';
    
    const list = document.createElement('ul');
    related.forEach(item => {
      const li = document.createElement('li');
      const a = document.createElement('a');
      a.href = item.url;
      a.dataset.relationType = 'related';
      a.textContent = item.title;
      li.appendChild(a);
      list.appendChild(li);
    });
    
    aside.append(heading, list);
    article.appendChild(aside);
  }
  
  return article;
}
```

### Figure and Media Elements

Properly structure media content with semantic associations:

```javascript
// Semantic media handling
function createFigure(config) {
  const figure = document.createElement('figure');
  
  if (config.type === 'image') {
    const img = document.createElement('img');
    img.src = config.src;
    img.alt = config.alt;
    if (config.width) img.width = config.width;
    if (config.height) img.height = config.height;
    figure.appendChild(img);
  } else if (config.type === 'video') {
    const video = document.createElement('video');
    video.controls = true;
    video.preload = 'metadata';
    
    const source = document.createElement('source');
    source.src = config.src;
    source.type = config.mimeType;
    video.appendChild(source);
    
    if (config.tracks) {
      config.tracks.forEach(track => {
        const trackEl = document.createElement('track');
        trackEl.kind = track.kind;
        trackEl.src = track.src;
        trackEl.srclang = track.lang;
        trackEl.label = track.label;
        if (track.default) trackEl.default = true;
        video.appendChild(trackEl);
      });
    }
    
    figure.appendChild(video);
  }
  
  if (config.caption) {
    const figcaption = document.createElement('figcaption');
    figcaption.textContent = config.caption;
    figure.appendChild(figcaption);
  }
  
  return figure;
}
```

### Breadcrumb Navigation

Construct semantic breadcrumb trails:

```javascript
// Semantic breadcrumbs
function createBreadcrumbs(path) {
  const nav = document.createElement('nav');
  nav.setAttribute('aria-label', 'Breadcrumb');
  
  const ol = document.createElement('ol');
  ol.setAttribute('role', 'list'); // Some screen readers need explicit role
  
  path.forEach((item, index) => {
    const li = document.createElement('li');
    
    if (index < path.length - 1) {
      const a = document.createElement('a');
      a.href = item.url;
      a.textContent = item.label;
      li.appendChild(a);
    } else {
      const span = document.createElement('span');
      span.setAttribute('aria-current', 'page');
      span.textContent = item.label;
      li.appendChild(span);
    }
    
    ol.appendChild(li);
  });
  
  nav.appendChild(ol);
  return nav;
}
```

### Search Interface Pattern

Build semantic search functionality:

```javascript
// Semantic search component
class SemanticSearch {
  constructor(config) {
    this.container = document.createElement('div');
    this.container.setAttribute('role', 'search');
    
    const form = document.createElement('form');
    form.setAttribute('role', 'search');
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      this.performSearch();
    });
    
    const label = document.createElement('label');
    label.setAttribute('for', 'search-input');
    label.textContent = config.label || 'Search';
    
    const input = document.createElement('input');
    input.id = 'search-input';
    input.type = 'search';
    input.name = 'q';
    input.setAttribute('aria-describedby', 'search-desc');
    input.autocomplete = 'off';
    
    const description = document.createElement('span');
    description.id = 'search-desc';
    description.className = 'visually-hidden';
    description.textContent = 'Enter search terms';
    
    const button = document.createElement('button');
    button.type = 'submit';
    button.textContent = 'Search';
    
    this.resultsContainer = document.createElement('div');
    this.resultsContainer.id = 'search-results';
    this.resultsContainer.setAttribute('role', 'region');
    this.resultsContainer.setAttribute('aria-live', 'polite');
    this.resultsContainer.setAttribute('aria-atomic', 'false');
    
    form.append(label, input, description, button);
    this.container.append(form, this.resultsContainer);
    
    this.input = input;
    this.onSearch = config.onSearch;
  }
  
  async performSearch() {
    const query = this.input.value.trim();
    if (!query) return;
    
    this.resultsContainer.innerHTML = '<p>Searching...</p>';
    
    const results = await this.onSearch(query);
    this.displayResults(results, query);
  }
  
  displayResults(results, query) {
    if (results.length === 0) {
      this.resultsContainer.innerHTML = `<p>No results found for "${query}"</p>`;
      return;
    }
    
    const heading = document.createElement('h2');
    heading.textContent = `${results.length} result${results.length !== 1 ? 's' : ''} for "${query}"`;
    
    const list = document.createElement('ul');
    results.forEach(result => {
      const li = document.createElement('li');
      
      const article = document.createElement('article');
      
      const h3 = document.createElement('h3');
      const link = document.createElement('a');
      link.href = result.url;
      link.textContent = result.title;
      h3.appendChild(link);
      
      const snippet = document.createElement('p');
      snippet.textContent = result.snippet;
      
      article.append(h3, snippet);
      li.appendChild(article);
      list.appendChild(li);
    });
    
    this.resultsContainer.innerHTML = '';
    this.resultsContainer.append(heading, list);
  }
  
  getElement() {
    return this.container;
  }
}
```

### Address and Contact Information

Format contact details semantically:

```javascript
// Semantic contact information
function createContactInfo(contact) {
  const address = document.createElement('address');
  
  if (contact.name) {
    const name = document.createElement('strong');
    name.textContent = contact.name;
    address.appendChild(name);
    address.appendChild(document.createElement('br'));
  }
  
  if (contact.street) {
    address.appendChild(document.createTextNode(contact.street));
    address.appendChild(document.createElement('br'));
  }
  
  if (contact.city || contact.state || contact.zip) {
    address.appendChild(document.createTextNode(
      `${contact.city}, ${contact.state} ${contact.zip}`
    ));
    address.appendChild(document.createElement('br'));
  }
  
  if (contact.email) {
    const email = document.createElement('a');
    email.href = `mailto:${contact.email}`;
    email.textContent = contact.email;
    address.appendChild(email);
    address.appendChild(document.createElement('br'));
  }
  
  if (contact.phone) {
    const phone = document.createElement('a');
    phone.href = `tel:${contact.phone.replace(/\D/g, '')}`;
    phone.textContent = contact.phone;
    address.appendChild(phone);
  }
  
  return address;
}
```

### Citation and Quotation Elements

Handle citations semantically:

```javascript
// Semantic citations
function createBlockquote(config) {
  const blockquote = document.createElement('blockquote');
  
  if (config.cite) {
    blockquote.cite = config.cite;
  }
  
  const p = document.createElement('p');
  p.textContent = config.quote;
  blockquote.appendChild(p);
  
  if (config.source || config.author) {
    const footer = document.createElement('footer');
    
    if (config.author) {
      footer.appendChild(document.createTextNode('— '));
      const cite = document.createElement('cite');
      cite.textContent = config.author;
      footer.appendChild(cite);
    }
    
    if (config.source) {
      if (config.author) {
        footer.appendChild(document.createTextNode(', '));
      }
      const sourceLink = document.createElement('a');
      sourceLink.href = config.cite || '#';
      sourceLink.textContent = config.source;
      footer.appendChild(sourceLink);
    }
    
    blockquote.appendChild(footer);
  }
  
  return blockquote;
}

function createInlineQuote(text, cite) {
  const q = document.createElement('q');
  q.textContent = text;
  if (cite) {
    q.cite = cite;
  }
  return q;
}
```

### Measurement and Technical Data

Format technical values semantically:

```javascript
// Semantic data representation
function createDataDisplay(label, value, unit) {
  const dl = document.createElement('dl');
  
  const dt = document.createElement('dt');
  dt.textContent = label;
  
  const dd = document.createElement('dd');
  
  const data = document.createElement('data');
  data.value = value;
  data.textContent = `${value} ${unit}`;
  
  dd.appendChild(data);
  dl.append(dt, dd);
  
  return dl;
}

function createMeasurement(value, unit) {
  const span = document.createElement('span');
  span.textContent = `${value} `;
  
  const abbr = document.createElement('abbr');
  abbr.title = getFullUnit(unit); // [Inference] Assumes helper function exists
  abbr.textContent = unit;
  
  span.appendChild(abbr);
  return span;
}
```

### Template Elements and Cloning

Use template elements for reusable semantic structures:

```javascript
// Template-based semantic content
class SemanticTemplate {
  constructor(templateId) {
    this.template = document.getElementById(templateId);
    if (!this.template || this.template.tagName !== 'TEMPLATE') {
      throw new Error('Invalid template element');
    }
  }
  
  create(data) {
    const clone = this.template.content.cloneNode(true);
    
    // Populate semantic elements
    Object.entries(data).forEach(([key, value]) => {
      const element = clone.querySelector(`[data-field="${key}"]`);
      if (!element) return;
      
      if (element.matches('img')) {
        element.src = value;
      } else if (element.matches('a')) {
        element.href = value;
      } else if (element.matches('time')) {
        element.setAttribute('datetime', value);
        element.textContent = new Date(value).toLocaleDateString();
      } else {
        element.textContent = value;
      }
    });
    
    return clone;
  }
}

// Usage with semantic template
// <template id="article-template">
//   <article>
//     <header>
//       <h3 data-field="title"></h3>
//       <time data-field="published"></time>
//     </header>
//     <p data-field="excerpt"></p>
//   </article>
// </template>

const articleTemplate = new SemanticTemplate('article-template');
const article = articleTemplate.create({
  title: 'Article Title',
  published: '2025-12-15',
  excerpt: 'Article excerpt text'
});
```

### Skip Links and Keyboard Navigation

Implement navigation aids programmatically:

```javascript
// Skip links for accessibility
function createSkipLinks(targets) {
  const nav = document.createElement('nav');
  nav.className = 'skip-links';
  nav.setAttribute('aria-label', 'Skip links');
  
  const list = document.createElement('ul');
  
  targets.forEach(target => {
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = `#${target.id}`;
    a.textContent = target.label;
    a.className = 'skip-link';
    li.appendChild(a);
    list.appendChild(li);
  });
  
  nav.appendChild(list);
  
  // Insert at beginning of body
  document.body.insertBefore(nav, document.body.firstChild);
}

// Add skip targets
function makeSkipTarget(element, label) {
  if (!element.id) {
    element.id = `skip-${label.toLowerCase().replace(/\s+/g, '-')}`;
  }
  element.setAttribute('tabindex', '-1'); // Allow programmatic focus
}
```

### Microdata and Schema.org Integration

Enhance semantic meaning with structured data:

```javascript
// Schema.org structured data
function createProductMarkup(product) {
  const article = document.createElement('article');
  article.setAttribute('itemscope', '');
  article.setAttribute('itemtype', 'https://schema.org/Product');
  
  const name = document.createElement('h2');
  name.setAttribute('itemprop', 'name');
  name.textContent = product.name;
  
  const description = document.createElement('p');
  description.setAttribute('itemprop', 'description');
  description.textContent = product.description;
  
  const offer = document.createElement('div');
  offer.setAttribute('itemprop', 'offers');
  offer.setAttribute('itemscope', '');
  offer.setAttribute('itemtype', 'https://schema.org/Offer');
  
  const price = document.createElement('span');
  price.setAttribute('itemprop', 'price');
  price.setAttribute('content', product.price);
  price.textContent = `$${product.price}`;
  
  const currency = document.createElement('meta');
  currency.setAttribute('itemprop', 'priceCurrency');
  currency.content = 'USD';
  
  offer.append(price, currency);
  article.append(name, description, offer);
  
  return article;
}
```

This comprehensive coverage focuses on practical implementation patterns for maintaining semantic HTML integrity when building or manipulating DOM structures with JavaScript.

---

