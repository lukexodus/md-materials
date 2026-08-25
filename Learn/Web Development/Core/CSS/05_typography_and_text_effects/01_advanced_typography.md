## Advanced Typography


### Web Fonts and @font-face

Web fonts enable designers to use custom typefaces beyond the limited set of system fonts, providing greater creative control and brand consistency across different platforms.

#### Understanding @font-face

The `@font-face` rule allows you to define custom fonts for use in web pages by specifying font files and their properties.

**Basic @font-face syntax:**

```css
@font-face {
    font-family: 'CustomFont';
    src: url('customfont.woff2') format('woff2'),
         url('customfont.woff') format('woff'),
         url('customfont.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;
    font-display: swap;
}

/* Usage */
.custom-text {
    font-family: 'CustomFont', Arial, sans-serif;
}
```

#### Font Format Support and Optimization

**Font format hierarchy for browser support:**

```css
@font-face {
    font-family: 'OptimizedFont';
    src: url('font.woff2') format('woff2'),      /* Modern browsers - best compression */
         url('font.woff') format('woff'),        /* Good browser support */
         url('font.ttf') format('truetype'),     /* Fallback for older browsers */
         url('font.eot');                        /* IE8 and below */
    src: url('font.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
         url('font.woff2') format('woff2'),
         url('font.woff') format('woff'),
         url('font.ttf') format('truetype'),
         url('font.svg#FontName') format('svg'); /* Legacy iOS */
}
```

**Font subsetting for performance:**

```css
/* Latin character subset */
@font-face {
    font-family: 'SubsetFont';
    src: url('font-latin.woff2') format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}

/* Cyrillic subset */
@font-face {
    font-family: 'SubsetFont';
    src: url('font-cyrillic.woff2') format('woff2');
    unicode-range: U+0400-045F, U+0490-0491, U+04B0-04B1, U+2116;
}
```

#### Multiple Font Weights and Styles

**Defining font families with multiple weights:**

```css
/* Light weight */
@font-face {
    font-family: 'BrandFont';
    src: url('brandfont-light.woff2') format('woff2');
    font-weight: 300;
    font-style: normal;
    font-display: swap;
}

/* Regular weight */
@font-face {
    font-family: 'BrandFont';
    src: url('brandfont-regular.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
}

/* Bold weight */
@font-face {
    font-family: 'BrandFont';
    src: url('brandfont-bold.woff2') format('woff2');
    font-weight: 700;
    font-style: normal;
    font-display: swap;
}

/* Italic styles */
@font-face {
    font-family: 'BrandFont';
    src: url('brandfont-italic.woff2') format('woff2');
    font-weight: 400;
    font-style: italic;
    font-display: swap;
}

/* Usage */
.brand-text {
    font-family: 'BrandFont', system-ui, sans-serif;
}

.brand-text.light {
    font-weight: 300;
}

.brand-text.bold {
    font-weight: 700;
}

.brand-text.italic {
    font-style: italic;
}
```

#### Google Fonts Integration

**Traditional Google Fonts loading:**

```html
<!-- HTML head -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;700&family=Playfair+Display:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
```

```css
/* CSS usage */
body {
    font-family: 'Inter', system-ui, -apple-system, sans-serif;
}

.heading {
    font-family: 'Playfair Display', Georgia, serif;
}
```

**Self-hosted Google Fonts for better performance:**

```css
/* Download and host Google Fonts locally */
@font-face {
    font-family: 'Inter';
    src: url('./fonts/inter-v12-latin-regular.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
}

@font-face {
    font-family: 'Inter';
    src: url('./fonts/inter-v12-latin-700.woff2') format('woff2');
    font-weight: 700;
    font-style: normal;
    font-display: swap;
}
```

### Font Loading Strategies

Font loading strategies are crucial for optimizing performance and user experience, preventing layout shifts and ensuring content remains readable during font loading.

#### Font Loading Performance Issues

**Common problems:**

- Flash of Invisible Text (FOIT)
- Flash of Unstyled Text (FOUT)
- Layout shifts when fonts load
- Slow font loading blocking page rendering

#### Preloading Critical Fonts

**Font preloading in HTML:**

```html
<head>
    <!-- Preload critical fonts -->
    <link rel="preload" href="fonts/primary-font.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="fonts/heading-font.woff2" as="font" type="font/woff2" crossorigin>
    
    <!-- Preconnect to external font services -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
</head>
```

**Resource hints for font optimization:**

```html
<!-- DNS prefetch for faster connection -->
<link rel="dns-prefetch" href="https://fonts.googleapis.com">

<!-- Preconnect for complete connection setup -->
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Preload specific font files -->
<link rel="preload" href="critical-font.woff2" as="font" type="font/woff2" crossorigin>
```

#### JavaScript Font Loading API

**Using the Font Loading API for better control:**

```javascript
// Check if Font Loading API is supported
if ('fonts' in document) {
    // Define fonts to load
    const fonts = [
        new FontFace('CustomFont', 'url(fonts/custom-regular.woff2)', {
            weight: '400',
            style: 'normal',
            display: 'swap'
        }),
        new FontFace('CustomFont', 'url(fonts/custom-bold.woff2)', {
            weight: '700',
            style: 'normal',
            display: 'swap'
        })
    ];
    
    // Load fonts and add to document
    Promise.all(fonts.map(font => font.load())).then(loadedFonts => {
        loadedFonts.forEach(font => {
            document.fonts.add(font);
        });
        
        // Add class to indicate fonts are loaded
        document.documentElement.classList.add('fonts-loaded');
    }).catch(error => {
        console.error('Font loading failed:', error);
        // Fallback handling
        document.documentElement.classList.add('fonts-failed');
    });
}
```

**CSS for progressive enhancement:**

```css
/* Base styles with system fonts */
body {
    font-family: system-ui, -apple-system, sans-serif;
    font-size: 16px;
    line-height: 1.5;
}

/* Enhanced styles when custom fonts load */
.fonts-loaded body {
    font-family: 'CustomFont', system-ui, sans-serif;
}

/* Fallback handling */
.fonts-failed body {
    font-family: Arial, sans-serif;
}
```

#### Critical Font Loading Strategy

**Inline critical fonts for instant loading:**

```css
/* Inline base64 encoded font for critical text */
@font-face {
    font-family: 'CriticalFont';
    src: url(data:font/woff2;base64,d09GMgABAAAAAAW8AAoAAAAABmwAAAVuAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAABmAAdjQKCwgAATYCJAMOBCAFhGcHSRu5BRGVnJ3IfiRMH1LgFhgAwqHmwsqNy7dITjl9gDGCr7V7+3Y/EDaHhEkO8MgxPgIFoKggBGCJRgW7TwBb3fOjAQjCCKRSGqcxNhzYdEfaJaQTNZFCfPy+78/9+X0gCgKGNrOBdY+6u6VxNzAmn0zJ7Z+o9cR7QOHPfRpPPVKKJIVgOq6YPOwmVrWojFWJ3bjKPkfaHXPKPadrK5iJ5nH3G2aKWvs5YZ9WmW8aXVUMBUYQ1FJTCCAKyLOmgLPfULJNAXNM/4o6DPJ/9dMhf6JrBLrE+j4APkjWYR7ooBFKWJmQykmNEqVU5KrEkFKRFa/VkLNEpSI1kbJKjBJqQrT8fSvZ4sNOArx0jVd8A4rQyGOEtlYQ4nWXGFJqYR7oqDH0hKkZf9QfN8oVxbwI8bpTzEGv7eQe9rOJwKOCTNbC4kTEq9uNGF1xAQHvGGDRnQHSo7ZJjRLqFURgzxNOBGcOEGmEwGQVjP7xfqVMSb9RxtWsQJ+wRyKILKFE6vAHmdNP0DOmUJdOXOWOKQxqGIjBIDDpKaKQD5sOA0RyYHp9mQeNrfJ8wYZGWZ9HrK+9pHJXYoAEWnWDJJnGS7xSRJRuJoG3LGQxl1AqOGlOyWF3ZtBXkSuylRU3OdZQwPg0+qUbVnJGvFaYOPbSfn1bLd1dFQ7MHjHhRLVA+VjFWVBHdVR1qFJlPQnKV8rn9wqOPVOzZnJ2+RmZBXnSPMHW0c5jt5wytgq6B0dWJx4KvgNl1nTmfCBRRa7vTF+bTt7qJqpaDmVRFZArnQGJOqOOINYqJqo8BSV/zOm+LrfqZGd3hzTW0u3tJNa0YQbLOvTOYh7oVvmTxZpTLNq7nSppjdY1iJnPSgLqMVRHxdxz1fDFuqVatc6xR3dHCp7rVG9oJDpuY7/9+6nV1+/O7u7nJUhTlZrGSd6+tqpqwJV8F0nUo97cKV1rT9F4q7vQy+5cXVfQwHgxjvlPNTFKfgVj0tUDyqfqK8jGzYUbfSGkTJRLvdYhW8rJHjVEKXLN6TmJxYSKl3rUINY8pLB8z5y3EElrO7eUXzUYU0NVz8v7JRkXjrv7dF/y3n7vLbvlz9/Y9rXMPNOtpZCQYXX7gZdj9UEfTVhJRJVDG+l5VVHlKGnvJ/nVqWOcXgHRPiefJUCLZdxIaLKRrQoY8RpgHOV5+nzJNg7pCiJRFOXgJy8vNT1gMdLLbPaXqGNjVaXFJcGh4ZGJkfLOUhVCvJWLJJPIjqjIlRqDzg48YrVgEPGcZJhCrIjzJGKxRt8/pKIiHi5CrICJGAk8/X4jGaQQj4+QGC/mKkCRQoIKWZICZ5z2hq6rqHKd3SjLmMqHW8cWzrjdHfZWGfZbr9KNOo7L8vJvNEZKWgNz9+VJR9xTfbwjqjEWGK/7s+2nAHfZ/a8sWR5rPKdyLUH75hYGF4dLd59A9JbLWoEhNRdOKzWrAi9aHhwJKW+lRLvutBcLPTnj/8lkjLZfCsrqFWxZaTQRhGGJKvIJr++/s/AktbG5AqJPJzO5C10KOJBzaXvztM+WwTqRVWqOx/msPCJVG3/EJINoxwDEIDTFiwHHcV5LWV/6yqTr/7qHvFe9VHOjXqSjKiQSjM5hBULI+DUcnKlULa+uOLdF/YcbEGKe3UhpLgGpOmEaKVUhFWlsqxQK6hJRUyaqJCKklqUh2s9WCpGdTzLgmBcDKIAqYWJUxkUE0hd3p5UJJ1zIqBGWGUhChGNI1QpiMASVHSQiBSUJLQnBAlOHvJQEFWEqhKkGpN8DESjihTU8QIQxcmNXZRe6qhRKpJIVnJjvHRiKgVKq1hUBhqeUJOOkfQGMNmOBrYjr6qP0IXbNAm9PFpRKuUbKnCjU5YsKpNJJiMtLTZGVOv/g9bF/tYAAA==) format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: block;
}

/* Use for critical above-the-fold content */
.hero-title {
    font-family: 'CriticalFont', system-ui, sans-serif;
}
```

### Font-display Property

The `font-display` property provides control over how fonts are displayed during the loading process, balancing performance and user experience.

#### Font-display Values

**Auto (default behavior):**

```css
@font-face {
    font-family: 'DefaultFont';
    src: url('font.woff2') format('woff2');
    font-display: auto; /* Browser decides the loading behavior */
}
```

**Block (prioritize custom font):**

```css
@font-face {
    font-family: 'BlockFont';
    src: url('font.woff2') format('woff2');
    font-display: block; /* Text invisible until font loads, then swap */
}

/* Use for critical branding elements */
.logo {
    font-family: 'BlockFont', serif;
}
```

**Swap (prioritize text visibility):**

```css
@font-face {
    font-family: 'SwapFont';
    src: url('font.woff2') format('woff2');
    font-display: swap; /* Show fallback immediately, swap when loaded */
}

/* Best for body text */
body {
    font-family: 'SwapFont', system-ui, sans-serif;
}
```

**Fallback (balance approach):**

```css
@font-face {
    font-family: 'FallbackFont';
    src: url('font.woff2') format('woff2');
    font-display: fallback; /* Brief invisible period, then fallback, swap if loads quickly */
}

/* Good for headings */
h1, h2, h3 {
    font-family: 'FallbackFont', Georgia, serif;
}
```

**Optional (performance first):**

```css
@font-face {
    font-family: 'OptionalFont';
    src: url('font.woff2') format('woff2');
    font-display: optional; /* Use only if already cached or loads very quickly */
}

/* For non-critical decorative elements */
.decorative-text {
    font-family: 'OptionalFont', cursive;
}
```

#### Strategic Font-display Usage

**Performance-optimized loading strategy:**

```css
/* Critical fonts - block for brand consistency */
@font-face {
    font-family: 'BrandFont';
    src: url('brand-font.woff2') format('woff2');
    font-display: block;
}

/* Body text - swap for readability */
@font-face {
    font-family: 'ReadingFont';
    src: url('reading-font.woff2') format('woff2');
    font-display: swap;
}

/* Decorative fonts - optional for performance */
@font-face {
    font-family: 'DecorativeFont';
    src: url('decorative-font.woff2') format('woff2');
    font-display: optional;
}

/* Usage */
.logo { font-family: 'BrandFont', serif; }
body { font-family: 'ReadingFont', system-ui, sans-serif; }
.accent { font-family: 'DecorativeFont', fantasy; }
```

### Variable Fonts

Variable fonts are a revolutionary font technology that allows a single font file to contain multiple variations of a typeface, reducing file sizes and providing unprecedented design flexibility.

#### Understanding Variable Fonts

Variable fonts use axes to define ranges of variation within a single font file:

**Standard axes:**

- **wght** (weight): thin to black
- **wdth** (width): condensed to expanded
- **ital** (italic): roman to italic
- **slnt** (slant): upright to slanted
- **opsz** (optical size): small to large

**Custom axes defined by font designers:**

- **GRAD** (grade): lighter to heavier appearance
- **YOPQ** (vertical stroke): thin to thick
- **XOPQ** (horizontal stroke): thin to thick

#### Variable Font Implementation

**Basic variable font declaration:**

```css
@font-face {
    font-family: 'VariableFont';
    src: url('variable-font.woff2') format('woff2-variations');
    font-weight: 100 900; /* Weight range */
    font-stretch: 75% 125%; /* Width range */
    font-style: oblique 0deg 12deg; /* Slant range */
    font-display: swap;
}
```

**Using font-variation-settings:**

```css
.variable-text {
    font-family: 'VariableFont', sans-serif;
    
    /* Standard axes using CSS properties */
    font-weight: 350;
    font-stretch: 110%;
    font-style: oblique 8deg;
    
    /* Custom axes using font-variation-settings */
    font-variation-settings: 
        "GRAD" 0,
        "YOPQ" 79,
        "XOPQ" 88;
}
```

#### Advanced Variable Font Techniques

**Responsive typography with variable fonts:**

```css
.responsive-heading {
    font-family: 'VariableFont', sans-serif;
    
    /* Mobile - lighter, condensed */
    font-weight: 300;
    font-stretch: 90%;
    font-variation-settings: "GRAD" -20;
}

@media (min-width: 768px) {
    .responsive-heading {
        /* Tablet - medium weight, normal width */
        font-weight: 450;
        font-stretch: 100%;
        font-variation-settings: "GRAD" 0;
    }
}

@media (min-width: 1024px) {
    .responsive-heading {
        /* Desktop - bolder, expanded */
        font-weight: 600;
        font-stretch: 105%;
        font-variation-settings: "GRAD" 15;
    }
}
```

**Animated variable font effects:**

```css
@keyframes fontMorph {
    0% {
        font-weight: 300;
        font-stretch: 75%;
        font-variation-settings: "GRAD" -50;
    }
    50% {
        font-weight: 800;
        font-stretch: 125%;
        font-variation-settings: "GRAD" 50;
    }
    100% {
        font-weight: 300;
        font-stretch: 75%;
        font-variation-settings: "GRAD" -50;
    }
}

.animated-text {
    font-family: 'VariableFont', sans-serif;
    animation: fontMorph 3s ease-in-out infinite;
}
```

**Interactive variable fonts:**

```css
.interactive-text {
    font-family: 'VariableFont', sans-serif;
    font-weight: 400;
    transition: font-weight 0.3s ease, font-variation-settings 0.3s ease;
}

.interactive-text:hover {
    font-weight: 700;
    font-variation-settings: "GRAD" 25, "YOPQ" 120;
}

.interactive-text:active {
    font-weight: 900;
    font-variation-settings: "GRAD" 50, "YOPQ" 140;
}
```

#### Variable Font Optimization

**Selective axis ranges for smaller files:**

```css
/* Instancing - creating specific instances from variable font */
@font-face {
    font-family: 'VariableFont-Light';
    src: url('variable-font.woff2') format('woff2-variations');
    font-weight: 200 400; /* Limited weight range */
    font-display: swap;
}

@font-face {
    font-family: 'VariableFont-Bold';
    src: url('variable-font.woff2') format('woff2-variations');
    font-weight: 600 900; /* Different weight range */
    font-display: swap;
}
```

**Feature queries for progressive enhancement:**

```css
/* Fallback for browsers without variable font support */
.enhanced-text {
    font-family: 'RegularFont', sans-serif;
    font-weight: 400;
}

/* Enhanced styles for variable font support */
@supports (font-variation-settings: normal) {
    .enhanced-text {
        font-family: 'VariableFont', sans-serif;
        font-variation-settings: "wght" 350, "GRAD" 0;
    }
}
```

**Performance considerations:**

```css
/* Efficient variable font usage */
:root {
    /* Define common variation settings as custom properties */
    --font-weight-light: 300;
    --font-weight-regular: 400;
    --font-weight-medium: 500;
    --font-weight-bold: 700;
    --font-grade-normal: 0;
    --font-grade-heavy: 25;
}

.optimized-text {
    font-family: 'VariableFont', sans-serif;
    font-weight: var(--font-weight-regular);
    font-variation-settings: "GRAD" var(--font-grade-normal);
}

.optimized-text.bold {
    font-weight: var(--font-weight-bold);
    font-variation-settings: "GRAD" var(--font-grade-heavy);
}
```

**Key points:**

- Variable fonts reduce the number of font files needed
- Single variable font file can replace multiple static font files
- Provide smooth interpolation between font variations
- Enable responsive typography that adapts to different contexts
- Require careful consideration of browser support and fallbacks
- Can create unique interactive and animated typography effects

**Conclusion:** Advanced typography techniques involving web fonts, strategic loading, and variable fonts are essential for modern web design. Proper implementation of `@font-face` rules, combined with thoughtful font loading strategies and the `font-display` property, ensures optimal performance and user experience. Variable fonts represent the future of web typography, offering unprecedented flexibility and efficiency while maintaining design consistency across different contexts and devices.

---

