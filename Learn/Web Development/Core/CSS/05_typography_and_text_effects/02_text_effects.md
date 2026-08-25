## Text Effects


### Text-shadow

Text-shadow adds shadow effects to text elements, creating depth, emphasis, and visual appeal. The property accepts multiple shadow values, enabling complex layered effects. Each shadow is defined by horizontal offset, vertical offset, blur radius, and color values.

The basic syntax is: `text-shadow: offset-x offset-y blur-radius color`. Multiple shadows can be applied by separating each shadow definition with commas.

**Basic Text Shadows:**

```css
.simple-shadow {
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
    color: #333;
}

.glow-effect {
    text-shadow: 0 0 10px #00ff00, 0 0 20px #00ff00, 0 0 30px #00ff00;
    color: white;
    background-color: #000;
}

.embossed-text {
    text-shadow: 1px 1px 0px #fff, -1px -1px 0px #000;
    color: #666;
}

.outline-text {
    text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
    color: white;
    font-weight: bold;
}
```

**Advanced Shadow Effects:**

```css
.neon-text {
    color: #fff;
    text-shadow: 
        0 0 5px #00ffff,
        0 0 10px #00ffff,
        0 0 15px #00ffff,
        0 0 20px #00ffff,
        0 0 35px #00ffff,
        0 0 40px #00ffff;
    background-color: #000;
    font-family: 'Arial', sans-serif;
    font-weight: bold;
}

.fire-text {
    color: #ff6600;
    text-shadow: 
        0 0 5px #ff3300,
        0 0 10px #ff3300,
        0 0 15px #ff3300,
        0 0 20px #ff6600,
        0 0 35px #ff6600,
        0 0 40px #ff9900;
    font-weight: bold;
}

.retro-text {
    color: #ff00ff;
    text-shadow: 
        3px 3px 0px #00ffff,
        6px 6px 0px #ffff00,
        9px 9px 0px #ff0000;
    font-family: 'Courier New', monospace;
    font-weight: bold;
}

.inset-text {
    color: #a0a0a0;
    text-shadow: 
        1px 1px 0px #ffffff,
        -1px -1px 0px #666666;
    background-color: #e0e0e0;
}
```

**Responsive and Interactive Shadows:**

```css
.hover-shadow {
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
    transition: text-shadow 0.3s ease;
}

.hover-shadow:hover {
    text-shadow: 
        2px 2px 4px rgba(0, 0, 0, 0.4),
        0 0 8px rgba(0, 123, 255, 0.6);
}

@media (max-width: 768px) {
    .mobile-shadow {
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    }
}

@media (min-width: 769px) {
    .desktop-shadow {
        text-shadow: 
            2px 2px 4px rgba(0, 0, 0, 0.3),
            0 0 10px rgba(0, 0, 0, 0.1);
    }
}
```

**Key points:**

- Multiple shadows can be layered for complex effects
- Blur radius of 0 creates sharp, solid shadows
- Negative offsets move shadows in opposite directions
- RGBA colors allow for transparent shadows
- Text-shadow doesn't affect layout or text flow
- Performance impact increases with multiple complex shadows

### Text-overflow and Ellipsis

Text-overflow controls how overflowing text is displayed when it exceeds its container's boundaries. The ellipsis value replaces clipped text with three dots (...), providing a visual indicator that content continues beyond the visible area. This property requires specific conditions to work effectively.

**Basic Ellipsis Setup:**

```css
.single-line-ellipsis {
    width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    border: 1px solid #ccc;
    padding: 8px;
}

.flexible-ellipsis {
    max-width: 100%;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.card-title {
    max-width: 250px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    font-weight: bold;
    margin-bottom: 10px;
}
```

**Multi-line Ellipsis (Webkit-specific):**

```css
.multi-line-ellipsis {
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    line-height: 1.4;
    max-height: calc(1.4em * 3);
}

.multi-line-ellipsis-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
}
```

**Cross-browser Multi-line Solution:**

```css
.cross-browser-ellipsis {
    position: relative;
    line-height: 1.4em;
    max-height: 4.2em; /* 3 lines */
    overflow: hidden;
}

.cross-browser-ellipsis::after {
    content: "...";
    position: absolute;
    right: 0;
    bottom: 0;
    background: linear-gradient(to right, transparent, white 50%);
    padding-left: 20px;
}
```

**Interactive Ellipsis:**

```css
.expandable-text {
    max-width: 300px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    cursor: pointer;
    transition: all 0.3s ease;
}

.expandable-text:hover,
.expandable-text.expanded {
    white-space: normal;
    max-width: none;
    background-color: #f8f9fa;
    padding: 8px;
    border-radius: 4px;
}

.tooltip-ellipsis {
    max-width: 200px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    position: relative;
}

.tooltip-ellipsis:hover::after {
    content: attr(data-full-text);
    position: absolute;
    top: 100%;
    left: 0;
    background-color: #333;
    color: white;
    padding: 5px 10px;
    border-radius: 4px;
    white-space: normal;
    z-index: 1000;
    max-width: 300px;
    font-size: 14px;
}
```

**Key points:**

- Requires white-space: nowrap, overflow: hidden for single-line ellipsis
- Multi-line ellipsis has limited cross-browser support
- Text-overflow only works with block-level or inline-block elements
- Custom ellipsis characters can be specified
- Consider accessibility when hiding content

### Word-wrap and Word-break

Word-wrap and word-break properties control how text breaks within containers, particularly important for handling long words, URLs, and different languages. These properties prevent text overflow and ensure readable layouts across various content types.

**Word-wrap (overflow-wrap):**

```css
.normal-wrap {
    word-wrap: normal; /* Default behavior */
    width: 200px;
    border: 1px solid #ccc;
    padding: 10px;
}

.break-word {
    word-wrap: break-word;
    width: 200px;
    border: 1px solid #ccc;
    padding: 10px;
}

.url-container {
    word-wrap: break-word;
    max-width: 100%;
    background-color: #f8f9fa;
    padding: 8px;
    border-radius: 4px;
    font-family: monospace;
}

.email-display {
    word-wrap: break-word;
    overflow-wrap: break-word; /* Modern syntax */
    max-width: 300px;
    border: 1px solid #ddd;
    padding: 8px;
}
```

**Word-break Property:**

```css
.break-all {
    word-break: break-all;
    width: 200px;
    border: 1px solid #ccc;
    padding: 10px;
}

.keep-all {
    word-break: keep-all;
    width: 200px;
    border: 1px solid #ccc;
    padding: 10px;
}

.break-word-modern {
    word-break: break-word;
    width: 200px;
    border: 1px solid #ccc;
    padding: 10px;
}

.cjk-text {
    word-break: keep-all;
    line-height: 1.6;
    text-align: justify;
}
```

**Practical Applications:**

```css
.code-block {
    word-wrap: break-word;
    word-break: break-all;
    background-color: #f4f4f4;
    padding: 15px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    white-space: pre-wrap;
    overflow-x: auto;
}

.chat-message {
    max-width: 70%;
    word-wrap: break-word;
    background-color: #e3f2fd;
    padding: 10px 15px;
    border-radius: 18px;
    margin-bottom: 8px;
}

.table-cell-wrap {
    word-wrap: break-word;
    word-break: break-word;
    max-width: 150px;
    padding: 8px;
}

.filename-display {
    word-break: break-all;
    max-width: 200px;
    background-color: #f8f9fa;
    padding: 5px 8px;
    border-radius: 3px;
    font-family: monospace;
    font-size: 0.9em;
}
```

**Responsive Text Breaking:**

```css
@media (max-width: 480px) {
    .mobile-text {
        word-break: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
    }
}

.responsive-container {
    word-wrap: break-word;
    overflow-wrap: break-word;
    word-break: break-word;
    hyphens: auto;
}

.long-url {
    word-break: break-all;
    overflow-wrap: break-word;
    max-width: 100%;
    color: #007bff;
    text-decoration: underline;
}
```

**Key points:**

- Word-wrap (overflow-wrap) breaks long words at arbitrary points
- Word-break controls breaking behavior more precisely
- Break-all can break words anywhere, affecting readability
- Keep-all prevents breaking in CJK languages
- Consider language-specific breaking rules

### Writing Modes and Text Orientation

Writing modes and text orientation control the direction and flow of text, supporting various languages and creative typography. These properties enable vertical text, right-to-left languages, and artistic text layouts.

**Writing Mode Property:**

```css
.horizontal-tb {
    writing-mode: horizontal-tb; /* Default */
    border: 1px solid #ccc;
    padding: 10px;
    width: 200px;
}

.vertical-rl {
    writing-mode: vertical-rl;
    height: 200px;
    width: 100px;
    border: 1px solid #ccc;
    padding: 10px;
}

.vertical-lr {
    writing-mode: vertical-lr;
    height: 200px;
    width: 100px;
    border: 1px solid #ccc;
    padding: 10px;
}

.sideways-rl {
    writing-mode: sideways-rl;
    height: 200px;
    width: 100px;
    border: 1px solid #ccc;
    padding: 10px;
}
```

**Text Orientation:**

```css
.mixed-orientation {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    height: 300px;
    width: 80px;
    border: 1px solid #ccc;
    padding: 10px;
}

.upright-orientation {
    writing-mode: vertical-rl;
    text-orientation: upright;
    height: 300px;
    width: 100px;
    border: 1px solid #ccc;
    padding: 10px;
}

.sideways-orientation {
    writing-mode: vertical-rl;
    text-orientation: sideways;
    height: 300px;
    width: 60px;
    border: 1px solid #ccc;
    padding: 10px;
}
```

**Practical Applications:**

```css
.book-spine {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    background-color: #8B4513;
    color: white;
    padding: 20px 10px;
    height: 300px;
    width: 40px;
    text-align: center;
    font-weight: bold;
}

.asian-poetry {
    writing-mode: vertical-rl;
    text-orientation: upright;
    font-family: "Noto Sans CJK JP", serif;
    line-height: 2;
    padding: 20px;
    background-color: #f9f9f9;
    border: 2px solid #8B4513;
}

.sidebar-label {
    writing-mode: vertical-lr;
    text-orientation: mixed;
    background-color: #007bff;
    color: white;
    padding: 10px 5px;
    font-weight: bold;
    letter-spacing: 2px;
}

.table-header-vertical {
    writing-mode: vertical-rl;
    text-orientation: mixed;
    height: 120px;
    width: 30px;
    background-color: #f8f9fa;
    text-align: center;
    font-weight: bold;
    font-size: 12px;
}
```

**Direction and BiDi Support:**

```css
.rtl-text {
    direction: rtl;
    text-align: right;
    unicode-bidi: bidi-override;
}

.ltr-text {
    direction: ltr;
    text-align: left;
    unicode-bidi: bidi-override;
}

.mixed-direction {
    unicode-bidi: embed;
}

.arabic-text {
    direction: rtl;
    font-family: "Noto Sans Arabic", sans-serif;
    text-align: right;
    line-height: 1.8;
}

.hebrew-text {
    direction: rtl;
    font-family: "Noto Sans Hebrew", sans-serif;
    text-align: right;
    line-height: 1.6;
}
```

**Creative Typography:**

```css
.vertical-menu {
    writing-mode: vertical-lr;
    text-orientation: sideways;
    display: flex;
    height: 400px;
}

.vertical-menu-item {
    padding: 20px 10px;
    background-color: #333;
    color: white;
    text-decoration: none;
    border-right: 1px solid #555;
    transition: background-color 0.3s ease;
}

.vertical-menu-item:hover {
    background-color: #007bff;
}

.artistic-title {
    writing-mode: vertical-rl;
    text-orientation: upright;
    font-size: 3em;
    font-weight: bold;
    background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}
```

**Responsive Writing Modes:**

```css
.responsive-vertical {
    writing-mode: horizontal-tb;
}

@media (min-width: 768px) {
    .responsive-vertical {
        writing-mode: vertical-rl;
        text-orientation: mixed;
        height: 400px;
        width: 100px;
    }
}

@media (orientation: portrait) {
    .portrait-vertical {
        writing-mode: vertical-lr;
        text-orientation: sideways;
    }
}
```

**Key points:**

- Writing-mode changes the block and inline directions
- Text-orientation only works with vertical writing modes
- Consider font support for vertical layouts
- RTL languages require direction property
- Vertical text affects layout calculations and sizing
- Browser support varies for advanced writing mode features

**Conclusion:** Text effects provide powerful tools for enhancing typography and creating engaging visual experiences. Text-shadow enables depth and emphasis through layered shadow effects, text-overflow with ellipsis ensures content fits within constraints while maintaining readability, word-wrap and word-break handle challenging content like URLs and multilingual text, and writing modes support diverse languages and creative layouts. Mastering these properties allows developers to create sophisticated, accessible, and internationally-aware text presentations that work across different devices and languages.

---
