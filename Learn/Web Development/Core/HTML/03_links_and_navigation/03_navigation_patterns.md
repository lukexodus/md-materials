## Navigation Patterns


### Navigation Lists

Navigation lists form the backbone of website navigation, providing structured pathways for users to move through content. Proper semantic markup using lists ensures accessibility and maintainability.

#### Basic Navigation Structure

The `<nav>` element should contain navigation links, typically structured as unordered lists for semantic clarity:

```html
<nav aria-label="Main navigation">
    <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
        <li><a href="/services">Services</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
</nav>
```

The `aria-label` attribute helps screen readers identify the navigation's purpose when multiple navigation sections exist on a page.

#### Nested Navigation Menus

Complex navigation structures can include nested lists for dropdown or hierarchical menus:

```html
<nav aria-label="Main navigation">
    <ul>
        <li><a href="/products">Products</a>
            <ul>
                <li><a href="/products/software">Software</a></li>
                <li><a href="/products/hardware">Hardware</a></li>
                <li><a href="/products/services">Services</a></li>
            </ul>
        </li>
        <li><a href="/support">Support</a>
            <ul>
                <li><a href="/support/documentation">Documentation</a></li>
                <li><a href="/support/contact">Contact Support</a></li>
            </ul>
        </li>
    </ul>
</nav>
```

#### Current Page Indication

Marking the current page helps users understand their location within the site structure:

```html
<nav aria-label="Main navigation">
    <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about" aria-current="page">About</a></li>
        <li><a href="/services">Services</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
</nav>
```

The `aria-current="page"` attribute indicates the current page to assistive technologies, while CSS can style the current link differently.

#### Mobile Navigation Patterns

Responsive navigation often requires different approaches for mobile devices:

```html
<nav aria-label="Main navigation">
    <button class="menu-toggle" aria-expanded="false" aria-controls="main-menu">
        Menu
    </button>
    <ul id="main-menu" class="menu" hidden>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
        <li><a href="/services">Services</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
</nav>
```

### Breadcrumbs

Breadcrumb navigation shows users their current location within a website's hierarchy and provides easy navigation back to parent pages.

#### Basic Breadcrumb Structure

Breadcrumbs should be implemented as ordered lists since the sequence matters:

```html
<nav aria-label="Breadcrumb">
    <ol class="breadcrumb">
        <li><a href="/">Home</a></li>
        <li><a href="/products">Products</a></li>
        <li><a href="/products/electronics">Electronics</a></li>
        <li aria-current="page">Smartphones</li>
    </ol>
</nav>
```

#### Structured Data for Breadcrumbs

Adding structured data helps search engines understand the breadcrumb hierarchy:

```html
<nav aria-label="Breadcrumb">
    <ol class="breadcrumb" itemscope itemtype="https://schema.org/BreadcrumbList">
        <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a itemprop="item" href="/">
                <span itemprop="name">Home</span>
            </a>
            <meta itemprop="position" content="1" />
        </li>
        <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <a itemprop="item" href="/products">
                <span itemprop="name">Products</span>
            </a>
            <meta itemprop="position" content="2" />
        </li>
        <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
            <span itemprop="name">Smartphones</span>
            <meta itemprop="position" content="3" />
        </li>
    </ol>
</nav>
```

#### Visual Breadcrumb Separators

Separators between breadcrumb items can be added with CSS pseudo-elements or Unicode characters:

```html
<nav aria-label="Breadcrumb">
    <ol class="breadcrumb">
        <li><a href="/">Home</a></li>
        <li><a href="/category">Category</a></li>
        <li><a href="/category/subcategory">Subcategory</a></li>
        <li aria-current="page">Current Page</li>
    </ol>
</nav>
```

### Skip Links for Accessibility

Skip links allow keyboard and screen reader users to bypass repetitive navigation and jump directly to main content.

#### Basic Skip Link Implementation

Skip links should be the first focusable element on the page:

```html
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
    <a href="#main-navigation" class="skip-link">Skip to navigation</a>
    
    <nav id="main-navigation" aria-label="Main navigation">
        <!-- Navigation content -->
    </nav>
    
    <main id="main-content">
        <!-- Main content -->
    </main>
</body>
```

#### Skip Link Styling

Skip links are typically hidden by default and appear when focused:

```css
.skip-link {
    position: absolute;
    top: -40px;
    left: 6px;
    background: #000;
    color: #fff;
    padding: 8px;
    text-decoration: none;
    z-index: 1000;
}

.skip-link:focus {
    top: 6px;
}
```

#### Multiple Skip Links

For complex pages, multiple skip links can help users navigate to different sections:

```html
<div class="skip-links">
    <a href="#main-content" class="skip-link">Skip to main content</a>
    <a href="#sidebar" class="skip-link">Skip to sidebar</a>
    <a href="#footer" class="skip-link">Skip to footer</a>
</div>
```

### Link Relationships

The `rel` attribute defines the relationship between the current document and the linked resource, providing semantic meaning for browsers and search engines.

#### Navigation Relationships

```html
<link rel="prev" href="/page-1">
<link rel="next" href="/page-3">
<link rel="first" href="/page-1">
<link rel="last" href="/page-10">
```

These relationships help with pagination and sequential navigation.

#### Content Relationships

```html
<link rel="canonical" href="https://example.com/preferred-url">
<link rel="alternate" href="https://example.com/mobile" media="handheld">
<link rel="alternate" href="/feed.xml" type="application/rss+xml">
```

#### External Resource Relationships

```html
<link rel="stylesheet" href="styles.css">
<link rel="icon" href="favicon.ico">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="dns-prefetch" href="//external-api.com">
```

#### Link Relationships in Anchor Tags

The `rel` attribute also works with anchor tags to describe the relationship to external links:

```html
<a href="https://external-site.com" rel="external">External Link</a>
<a href="https://sponsor.com" rel="sponsored">Sponsored Link</a>
<a href="download.pdf" rel="download">Download PDF</a>
<a href="mailto:contact@example.com" rel="author">Contact Author</a>
```

#### Security Relationships

For external links, security-related `rel` values prevent potential security issues:

```html
<a href="https://untrusted-site.com" rel="nofollow noopener noreferrer">
    External Link
</a>
```

### Advanced Navigation Patterns

#### Landmark Navigation

Using ARIA landmarks to create a navigation structure for assistive technologies:

```html
<nav role="navigation" aria-label="Main navigation">
    <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
    </ul>
</nav>

<nav role="navigation" aria-label="Secondary navigation">
    <ul>
        <li><a href="/login">Login</a></li>
        <li><a href="/register">Register</a></li>
    </ul>
</nav>
```

#### Pagination Navigation

Structured pagination with proper accessibility attributes:

```html
<nav aria-label="Pagination">
    <ul class="pagination">
        <li><a href="/page/1" rel="prev" aria-label="Previous page">‹ Previous</a></li>
        <li><a href="/page/1">1</a></li>
        <li><a href="/page/2" aria-current="page">2</a></li>
        <li><a href="/page/3">3</a></li>
        <li><a href="/page/4">4</a></li>
        <li><a href="/page/3" rel="next" aria-label="Next page">Next ›</a></li>
    </ul>
</nav>
```

**Key points** for navigation patterns include using semantic HTML elements like nav and lists for structure, implementing proper ARIA attributes for accessibility, providing skip links as the first focusable elements, using appropriate rel attributes to define link relationships, indicating current page or section with aria-current, ensuring keyboard navigation works properly throughout all navigation elements, and testing navigation with screen readers to verify accessibility.

**Example** of comprehensive navigation implementation:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Navigation Example</title>
    <link rel="canonical" href="https://example.com/products/smartphones">
    <link rel="prev" href="https://example.com/products/tablets">
    <link rel="next" href="https://example.com/products/laptops">
</head>
<body>
    <a href="#main-content" class="skip-link">Skip to main content</a>
    
    <nav aria-label="Breadcrumb">
        <ol class="breadcrumb">
            <li><a href="/">Home</a></li>
            <li><a href="/products">Products</a></li>
            <li aria-current="page">Smartphones</li>
        </ol>
    </nav>
    
    <nav aria-label="Main navigation">
        <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/products" aria-current="page">Products</a>
                <ul>
                    <li><a href="/products/smartphones">Smartphones</a></li>
                    <li><a href="/products/tablets">Tablets</a></li>
                    <li><a href="/products/laptops">Laptops</a></li>
                </ul>
            </li>
            <li><a href="/support">Support</a></li>
            <li><a href="/contact">Contact</a></li>
        </ul>
    </nav>
    
    <main id="main-content">
        <h1>Smartphones</h1>
        <!-- Main content -->
    </main>
    
    <nav aria-label="Pagination">
        <ul class="pagination">
            <li><a href="/products/smartphones?page=1" rel="prev">‹ Previous</a></li>
            <li><a href="/products/smartphones?page=1">1</a></li>
            <li><a href="/products/smartphones?page=2" aria-current="page">2</a></li>
            <li><a href="/products/smartphones?page=3">3</a></li>
            <li><a href="/products/smartphones?page=3" rel="next">Next ›</a></li>
        </ul>
    </nav>
</body>
</html>
```

These navigation patterns create intuitive, accessible user experiences that work across all devices and assistive technologies while providing clear semantic meaning for search engines and other automated systems.

---

