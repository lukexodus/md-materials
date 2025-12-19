# DOM Interfaces/Classes Hierarchy Tree

## Core DOM Hierarchy

### EventTarget
- **Node**
  - **Document**
    - HTMLDocument
    - XMLDocument
    - SVGDocument
  - **DocumentFragment**
    - ShadowRoot
  - **DocumentType**
  - **Element**
    - **HTMLElement**
      - HTMLAnchorElement (`<a>`)
      - HTMLAreaElement (`<area>`)
      - HTMLAudioElement (`<audio>`)
      - HTMLBaseElement (`<base>`)
      - HTMLBodyElement (`<body>`)
      - HTMLBRElement (`<br>`)
      - HTMLButtonElement (`<button>`)
      - HTMLCanvasElement (`<canvas>`)
      - HTMLDataElement (`<data>`)
      - HTMLDataListElement (`<datalist>`)
      - HTMLDetailsElement (`<details>`)
      - HTMLDialogElement (`<dialog>`)
      - HTMLDirectoryElement (`<dir>`) [deprecated]
      - HTMLDivElement (`<div>`)
      - HTMLDListElement (`<dl>`)
      - HTMLEmbedElement (`<embed>`)
      - HTMLFieldSetElement (`<fieldset>`)
      - HTMLFontElement (`<font>`) [deprecated]
      - HTMLFormElement (`<form>`)
      - HTMLFrameElement (`<frame>`) [deprecated]
      - HTMLFrameSetElement (`<frameset>`) [deprecated]
      - HTMLHeadElement (`<head>`)
      - HTMLHeadingElement (`<h1>`-`<h6>`)
      - HTMLHRElement (`<hr>`)
      - HTMLHtmlElement (`<html>`)
      - HTMLIFrameElement (`<iframe>`)
      - HTMLImageElement (`<img>`)
      - HTMLInputElement (`<input>`)
      - HTMLLabelElement (`<label>`)
      - HTMLLegendElement (`<legend>`)
      - HTMLLIElement (`<li>`)
      - HTMLLinkElement (`<link>`)
      - HTMLMapElement (`<map>`)
      - HTMLMarqueeElement (`<marquee>`) [deprecated]
      - HTMLMediaElement
        - HTMLAudioElement (`<audio>`)
        - HTMLVideoElement (`<video>`)
      - HTMLMenuElement (`<menu>`)
      - HTMLMetaElement (`<meta>`)
      - HTMLMeterElement (`<meter>`)
      - HTMLModElement (`<ins>`, `<del>`)
      - HTMLObjectElement (`<object>`)
      - HTMLOListElement (`<ol>`)
      - HTMLOptGroupElement (`<optgroup>`)
      - HTMLOptionElement (`<option>`)
      - HTMLOutputElement (`<output>`)
      - HTMLParagraphElement (`<p>`)
      - HTMLParamElement (`<param>`) [deprecated]
      - HTMLPictureElement (`<picture>`)
      - HTMLPreElement (`<pre>`)
      - HTMLProgressElement (`<progress>`)
      - HTMLQuoteElement (`<blockquote>`, `<q>`)
      - HTMLScriptElement (`<script>`)
      - HTMLSelectElement (`<select>`)
      - HTMLSlotElement (`<slot>`)
      - HTMLSourceElement (`<source>`)
      - HTMLSpanElement (`<span>`)
      - HTMLStyleElement (`<style>`)
      - HTMLTableCaptionElement (`<caption>`)
      - HTMLTableCellElement (`<td>`, `<th>`)
      - HTMLTableColElement (`<col>`, `<colgroup>`)
      - HTMLTableElement (`<table>`)
      - HTMLTableRowElement (`<tr>`)
      - HTMLTableSectionElement (`<thead>`, `<tbody>`, `<tfoot>`)
      - HTMLTemplateElement (`<template>`)
      - HTMLTextAreaElement (`<textarea>`)
      - HTMLTimeElement (`<time>`)
      - HTMLTitleElement (`<title>`)
      - HTMLTrackElement (`<track>`)
      - HTMLUListElement (`<ul>`)
      - HTMLUnknownElement (unknown tags)
      - HTMLVideoElement (`<video>`)
    - **SVGElement**
      - SVGGraphicsElement
        - SVGGeometryElement
          - SVGCircleElement (`<circle>`)
          - SVGEllipseElement (`<ellipse>`)
          - SVGLineElement (`<line>`)
          - SVGPathElement (`<path>`)
          - SVGPolygonElement (`<polygon>`)
          - SVGPolylineElement (`<polyline>`)
          - SVGRectElement (`<rect>`)
        - SVGTextContentElement
          - SVGTextPositioningElement
            - SVGTextElement (`<text>`)
            - SVGTSpanElement (`<tspan>`)
            - SVGTextPathElement (`<textPath>`)
        - SVGGElement (`<g>`)
        - SVGUseElement (`<use>`)
        - SVGImageElement (`<image>`)
        - SVGSVGElement (`<svg>`)
        - SVGForeignObjectElement (`<foreignObject>`)
      - SVGAnimationElement
        - SVGAnimateElement (`<animate>`)
        - SVGAnimateMotionElement (`<animateMotion>`)
        - SVGAnimateTransformElement (`<animateTransform>`)
        - SVGSetElement (`<set>`)
      - SVGClipPathElement (`<clipPath>`)
      - SVGDefsElement (`<defs>`)
      - SVGDescElement (`<desc>`)
      - SVGFilterElement (`<filter>`)
      - SVGGradientElement
        - SVGLinearGradientElement (`<linearGradient>`)
        - SVGRadialGradientElement (`<radialGradient>`)
      - SVGMarkerElement (`<marker>`)
      - SVGMaskElement (`<mask>`)
      - SVGMetadataElement (`<metadata>`)
      - SVGPatternElement (`<pattern>`)
      - SVGScriptElement (`<script>`)
      - SVGStopElement (`<stop>`)
      - SVGStyleElement (`<style>`)
      - SVGSymbolElement (`<symbol>`)
      - SVGTitleElement (`<title>`)
      - SVGViewElement (`<view>`)
      - SVGComponentTransferFunctionElement
        - SVGFEFuncAElement
        - SVGFEFuncBElement
        - SVGFEFuncGElement
        - SVGFEFuncRElement
      - SVGFEBlendElement (`<feBlend>`)
      - SVGFEColorMatrixElement (`<feColorMatrix>`)
      - SVGFEComponentTransferElement (`<feComponentTransfer>`)
      - SVGFECompositeElement (`<feComposite>`)
      - SVGFEConvolveMatrixElement (`<feConvolveMatrix>`)
      - SVGFEDiffuseLightingElement (`<feDiffuseLighting>`)
      - SVGFEDisplacementMapElement (`<feDisplacementMap>`)
      - SVGFEDistantLightElement (`<feDistantLight>`)
      - SVGFEDropShadowElement (`<feDropShadow>`)
      - SVGFEFloodElement (`<feFlood>`)
      - SVGFEGaussianBlurElement (`<feGaussianBlur>`)
      - SVGFEImageElement (`<feImage>`)
      - SVGFEMergeElement (`<femerge>`)
      - SVGFEMergeNodeElement (`<feMergeNode>`)
      - SVGFEMorphologyElement (`<feMorphology>`)
      - SVGFEOffsetElement (`<feOffset>`)
      - SVGFEPointLightElement (`<fePointLight>`)
      - SVGFESpecularLightingElement (`<feSpecularLighting>`)
      - SVGFESpotLightElement (`<feSpotLight>`)
      - SVGFETileElement (`<feTile>`)
      - SVGFETurbulenceElement (`<feTurbulence>`)
    - **MathMLElement** (MathML elements)
  - **Attr** (attribute nodes)
  - **CharacterData**
    - **Text**
      - CDATASection
    - **Comment**
    - ProcessingInstruction
- **Window**
- **XMLHttpRequest**
- **FileReader**
- **MessagePort**
- **AudioNode** (Web Audio API)
- **IDBRequest** (IndexedDB)
- **Performance**
- **Animation** (Web Animations API)
- **AbortSignal**
- **BroadcastChannel**
- **MediaStream**
- **RTCPeerConnection**
- **WebSocket**
- **Worker**
  - SharedWorker
  - ServiceWorker

## Collection Interfaces

- **NodeList**
  - StaticNodeList
  - LiveNodeList
- **HTMLCollection** (live collection)
- **DOMTokenList** (classList, relList)
- **NamedNodeMap** (attributes)
- **DOMStringList**
- **RadioNodeList**
- **HTMLFormControlsCollection**
- **HTMLOptionsCollection**

## DOM Data Structures

- **DOMRect**
  - DOMRectReadOnly
- **DOMRectList**
- **DOMPoint**
  - DOMPointReadOnly
- **DOMMatrix**
  - DOMMatrixReadOnly
- **DOMQuad**
- **DOMStringMap** (dataset)
- **CSSStyleDeclaration**
- **StyleSheet**
  - CSSStyleSheet
- **StyleSheetList**
- **CSSRuleList**
- **CSSRule**
  - CSSStyleRule
  - CSSMediaRule
  - CSSImportRule
  - CSSFontFaceRule
  - CSSKeyframesRule
  - CSSKeyframeRule
  - CSSSupportsRule
  - CSSNamespaceRule
  - CSSPageRule

## Range and Selection

- **Range**
- **Selection**
- **StaticRange**

## Mutation and Observation

- **MutationObserver**
- **MutationRecord**
- **IntersectionObserver**
- **IntersectionObserverEntry**
- **ResizeObserver**
- **ResizeObserverEntry**
- **PerformanceObserver**

## Events Hierarchy

- **Event**
  - **UIEvent**
    - **MouseEvent**
      - DragEvent
      - PointerEvent
      - WheelEvent
    - **FocusEvent**
    - **KeyboardEvent**
    - **InputEvent**
    - **CompositionEvent**
    - **TouchEvent**
  - **CustomEvent**
  - **AnimationEvent**
  - **TransitionEvent**
  - **ClipboardEvent**
  - **MessageEvent**
  - **StorageEvent**
  - **PopStateEvent**
  - **HashChangeEvent**
  - **PageTransitionEvent**
  - **ProgressEvent**
  - **ErrorEvent**
  - **PromiseRejectionEvent**
  - **SecurityPolicyViolationEvent**
  - **SubmitEvent**
  - **FormDataEvent**
  - **BeforeUnloadEvent**

## Media and Graphics

- **CanvasRenderingContext2D**
- **WebGLRenderingContext**
  - WebGL2RenderingContext
- **ImageData**
- **ImageBitmap**
- **Path2D**
- **TextMetrics**
- **CanvasGradient**
- **CanvasPattern**

## File and Blob APIs

- **Blob**
  - File
- **FileList**
- **FileReader**
- **FormData**
- **DataTransfer**
- **DataTransferItem**
- **DataTransferItemList**

## URL and History

- **URL**
- **URLSearchParams**
- **Location**
- **History**

## Storage

- **Storage** (localStorage, sessionStorage)
- **StorageManager**

## Web Components

- **CustomElementRegistry**
- **ShadowRoot** (extends DocumentFragment)

## Miscellaneous

- **DOMParser**
- **XMLSerializer**
- **DOMImplementation**
- **NodeIterator**
- **TreeWalker**
- **ValidityState**
- **TimeRanges**
- **TextTrack**
- **TextTrackCue**
- **TextTrackList**
- **TextTrackCueList**
- **MediaError**
- **MediaQueryList**
- **Screen**
- **Navigator**
- **Plugin**
- **PluginArray**
- **MimeType**
- **MimeTypeArray**
- **Crypto**
- **SubtleCrypto**

## Abstract Interfaces (not directly instantiated)

- **NonElementParentNode** (mixin)
- **ParentNode** (mixin)
- **ChildNode** (mixin)
- **DocumentAndElementEventHandlers** (mixin)
- **GlobalEventHandlers** (mixin)
- **WindowEventHandlers** (mixin)
- **Slottable** (mixin)
- **ElementCSSInlineStyle** (mixin)
- **GeometryUtils** (mixin)
- **LinkStyle** (mixin)

---

**Note:** This hierarchy represents the standard DOM APIs as defined by W3C and WHATWG specifications. Some interfaces may vary across browser implementations, and newer APIs continue to be added to the DOM specification.

---


# NamedNodeMap

## What is NamedNodeMap?

`NamedNodeMap` is a collection of `Attr` (attribute) nodes that represents the attributes of an HTML element. It's returned by the `attributes` property of DOM elements.

## Key Characteristics

- **Live collection**: Changes to the element's attributes are automatically reflected in the NamedNodeMap
- **Indexed access**: You can access attributes by numeric index (0, 1, 2, etc.)
- **Named access**: You can access attributes by their name
- **Not an array**: While similar to arrays, NamedNodeMap doesn't have array methods like `forEach`, `map`, etc.

## Common Methods

```javascript
// Get an element's attributes
const element = document.getElementById('myElement');
const attrs = element.attributes; // Returns a NamedNodeMap

// Access by index
attrs[0]           // First attribute
attrs.item(0)      // Same as above

// Access by name
attrs.getNamedItem('class')      // Get the 'class' attribute
attrs['class']                    // Also works (shorthand)

// Get attribute name and value
attrs[0].name      // Attribute name
attrs[0].value     // Attribute value

// Length
attrs.length       // Number of attributes
```

## Example Usage

```javascript
const div = document.querySelector('div');
// <div id="test" class="container" data-value="123"></div>

const attributes = div.attributes;

console.log(attributes.length);              // 3
console.log(attributes[0].name);             // "id"
console.log(attributes.getNamedItem('id').value);  // "test"

// Iterate through attributes
for (let i = 0; i < attributes.length; i++) {
  console.log(`${attributes[i].name}: ${attributes[i].value}`);
}
```

## Converting to Array

Since `NamedNodeMap` isn't an array, you might want to convert it:

```javascript
const attrsArray = Array.from(element.attributes);
// or
const attrsArray = [...element.attributes];

// Now you can use array methods
attrsArray.forEach(attr => {
  console.log(attr.name, attr.value);
});
```

---

# DOMTokenList

## What is DOMTokenList?

`DOMTokenList` is a collection of space-separated tokens (strings) from an attribute. The most common example is the `classList` property, which represents an element's CSS classes.

## Key Characteristics

- **Live collection**: Changes automatically reflect in the DOMTokenList and vice versa
- **Array-like**: Has a `length` property and numeric indexing
- **Set-like behavior**: Each token appears only once (duplicates are automatically removed)
- **Space-separated**: Tokens are separated by spaces in the underlying attribute

## Common Properties Returning DOMTokenList

```javascript
element.classList        // CSS classes
element.relList         // rel attribute values (for <link>, <a>, etc.)
element.sandbox         // sandbox attribute (for <iframe>)
// ... and others
```

## Common Methods

```javascript
const element = document.getElementById('myElement');
const classes = element.classList; // Returns a DOMTokenList

// Add tokens
classes.add('active');
classes.add('highlight', 'large'); // Can add multiple

// Remove tokens
classes.remove('active');
classes.remove('highlight', 'large'); // Can remove multiple

// Toggle (add if absent, remove if present)
classes.toggle('active');          // Returns true if added, false if removed
classes.toggle('active', true);    // Force add
classes.toggle('active', false);   // Force remove

// Check if contains
classes.contains('active');        // Returns boolean

// Replace
classes.replace('old-class', 'new-class'); // Returns boolean (success)

// Access by index
classes[0];                        // First class
classes.item(0);                   // Same as above

// Length
classes.length;                    // Number of tokens

// Get all as string
classes.value;                     // Space-separated string
classes.toString();                // Same as above
```

## Example Usage

```javascript
const div = document.querySelector('div');
// <div class="container active"></div>

const classList = div.classList;

console.log(classList.length);           // 2
console.log(classList[0]);               // "container"
console.log(classList.contains('active')); // true

// Add multiple classes
classList.add('large', 'highlight');
// <div class="container active large highlight"></div>

// Toggle class
classList.toggle('active');              // Removes 'active'
classList.toggle('active');              // Adds 'active' back

// Replace class
classList.replace('container', 'wrapper');
// <div class="wrapper active large highlight"></div>
```

## Iteration

```javascript
// forEach (built-in)
classList.forEach(className => {
  console.log(className);
});

// for...of
for (let className of classList) {
  console.log(className);
}

// Convert to array
const classArray = [...classList];
// or
const classArray = Array.from(classList);
```

## Common Use Cases

```javascript
// Conditional styling
if (element.classList.contains('hidden')) {
  element.classList.remove('hidden');
  element.classList.add('visible');
}

// Toggle active state
button.addEventListener('click', () => {
  button.classList.toggle('active');
});

// Swap classes
element.classList.replace('loading', 'loaded');

// Remove all classes matching a pattern
[...element.classList]
  .filter(c => c.startsWith('temp-'))
  .forEach(c => element.classList.remove(c));
```

## Key Differences from NamedNodeMap

| Feature | DOMTokenList | NamedNodeMap |
|---------|--------------|--------------|
| Represents | Space-separated tokens | Element attributes |
| Common use | `classList` | `attributes` |
| Methods | add, remove, toggle, contains | getNamedItem, setNamedItem |
| Duplicates | Automatically removed | N/A |

---

# Computed Styles

## What are Computed Styles?

Computed styles are the **final, actual CSS property values** that the browser calculates and applies to an element after considering all CSS sources (inline styles, stylesheets, browser defaults, inheritance, etc.).

## How Styles are Determined

When rendering an element, the browser processes styles in this order:

1. **Browser default styles** (user agent stylesheet)
2. **External stylesheets** (`<link>` tags)
3. **Internal stylesheets** (`<style>` tags)
4. **Inline styles** (`style` attribute)
5. **CSS specificity and cascade rules**
6. **Inheritance** from parent elements
7. **Final computation** (converting relative units to absolute values)

The **computed style** is the result after all these steps.
MI'll help you understand the DOM and computed layout properties.

## Major Categories of Computed Layout Properties

**Box Model Properties:**
- `width`, `height` - Final dimensions including content
- `padding-top/right/bottom/left` - Inner spacing
- `border-width`, `border-style`, `border-color` - Border properties
- `margin-top/right/bottom/left` - Outer spacing

**Positioning Properties:**
- `position` - static, relative, absolute, fixed, sticky
- `top`, `right`, `bottom`, `left` - Offset values
- `z-index` - Stacking order

**Display & Layout:**
- `display` - block, inline, flex, grid, etc.
- `float` - left, right, none
- `clear` - both, left, right, none

**Flexbox Properties:**
- `flex-direction`, `flex-wrap`, `flex-flow`
- `justify-content`, `align-items`, `align-content`
- `flex-grow`, `flex-shrink`, `flex-basis`

**Grid Properties:**
- `grid-template-columns/rows`
- `grid-gap`, `column-gap`, `row-gap`
- `grid-auto-flow`

**Typography:**
- `font-size`, `font-family`, `font-weight`
- `line-height`, `letter-spacing`
- `text-align`, `text-transform`

**Visual Properties:**
- `color`, `background-color`, `background-image`
- `opacity`, `visibility`
- `transform`, `transform-origin`

**Overflow & Clipping:**
- `overflow`, `overflow-x`, `overflow-y`
- `clip`, `clip-path`

**Important Notes**

- Computed values are always in **absolute units** (px, not em or %)
- Colors are returned in **rgb()** or **rgba()** format
- Values include defaults and inherited properties
- These are **read-only** - to modify styles, use `element.style.property`

## Accessing Computed Styles

```javascript
const element = document.getElementById('myElement');

// Get computed styles
const computedStyle = window.getComputedStyle(element);

// Get specific property
const color = computedStyle.color;              // "rgb(255, 0, 0)"
const fontSize = computedStyle.fontSize;        // "16px"
const width = computedStyle.width;              // "200px"

// Alternative syntax
const padding = computedStyle.getPropertyValue('padding-left');

// For pseudo-elements
const beforeStyle = window.getComputedStyle(element, '::before');
const beforeContent = beforeStyle.content;
```

## Key Characteristics

### 1. **Always Absolute Values**

Relative values are converted to absolute:

```javascript
// CSS: font-size: 1.5em; (parent is 16px)
computedStyle.fontSize;  // "24px" (not "1.5em")

// CSS: width: 50%;
computedStyle.width;     // "400px" (not "50%")

// CSS: color: red;
computedStyle.color;     // "rgb(255, 0, 0)" (not "red")
```

### 2. **Read-Only**

You cannot modify computed styles directly:

```javascript
const computedStyle = window.getComputedStyle(element);
computedStyle.color = 'blue';  // No effect!

// To change styles, modify the element directly:
element.style.color = 'blue';  // This works
```

### 3. **Live Updates**

Computed styles reflect current state, including dynamic changes:

```javascript
const computedStyle = window.getComputedStyle(element);
console.log(computedStyle.color);  // "rgb(0, 0, 0)"

element.style.color = 'red';
console.log(computedStyle.color);  // "rgb(255, 0, 0)" (updated!)
```

## Computed vs. Inline Styles

```javascript
const element = document.getElementById('myElement');

// Inline styles (element.style)
element.style.color;              // Only returns inline styles
                                  // Returns "" if not set inline

// Computed styles (getComputedStyle)
window.getComputedStyle(element).color;  // Returns final computed value
                                          // Always has a value
```

### Example

```html
<style>
  .box { 
    color: blue; 
    width: 50%;
  }
</style>

<div id="myBox" class="box" style="font-size: 20px;"></div>
```

```javascript
const box = document.getElementById('myBox');

// Inline style (element.style)
box.style.fontSize;    // "20px" (set inline)
box.style.color;       // "" (not set inline)
box.style.width;       // "" (not set inline)

// Computed style (getComputedStyle)
const computed = window.getComputedStyle(box);
computed.fontSize;     // "20px"
computed.color;        // "rgb(0, 0, 255)"
computed.width;        // "400px" (if parent is 800px wide)
```

## Common Use Cases

### 1. **Getting Actual Dimensions**

```javascript
const element = document.getElementById('myElement');
const computed = window.getComputedStyle(element);

const width = parseFloat(computed.width);
const height = parseFloat(computed.height);
const paddingTop = parseFloat(computed.paddingTop);
```

### 2. **Checking Visibility**

```javascript
const computed = window.getComputedStyle(element);

if (computed.display === 'none') {
  console.log('Element is hidden');
}

if (computed.visibility === 'hidden') {
  console.log('Element is invisible but takes up space');
}
```

### 3. **Getting Colors**

```javascript
const computed = window.getComputedStyle(element);

const bgColor = computed.backgroundColor;    // "rgb(255, 255, 255)"
const textColor = computed.color;            // "rgb(0, 0, 0)"
```

### 4. **Detecting Animations/Transitions**

```javascript
const computed = window.getComputedStyle(element);

const transitionDuration = computed.transitionDuration;  // "0.3s"
const animationName = computed.animationName;            // "slideIn"
```

## Important Notes

### Shorthand Properties

[Inference] Shorthand properties may behave differently across browsers:

```javascript
const computed = window.getComputedStyle(element);

// Some browsers return empty string for shorthands
computed.margin;      // May return "" or full value

// Use longhand properties for reliability
computed.marginTop;   // "10px" (reliable)
computed.marginRight; // "10px" (reliable)
```

### Performance

```javascript
// Accessing computed styles can trigger reflow
const computed = window.getComputedStyle(element);

// Reading multiple properties - cache the object
const width = computed.width;
const height = computed.height;
const padding = computed.padding;

// Better than calling getComputedStyle() multiple times
```

## Pseudo-Elements

```html
<style>
  .box::before {
    content: "★";
    color: gold;
  }
</style>

<div class="box">Hello</div>
```

```javascript
const box = document.querySelector('.box');

// Get styles of pseudo-element
const beforeStyle = window.getComputedStyle(box, '::before');
const content = beforeStyle.content;        // '"★"'
const color = beforeStyle.color;            // "rgb(255, 215, 0)"
```

## Summary Table

| Aspect | `element.style` | `getComputedStyle()` |
|--------|----------------|---------------------|
| Source | Inline styles only | All CSS sources |
| Values | As written | Computed/absolute |
| Read/Write | Read and write | Read-only |
| Empty properties | Returns `""` | Returns computed value |
| Use case | Setting styles | Getting actual values |

---

# CSSStyleDeclaration

## What is CSSStyleDeclaration?

`CSSStyleDeclaration` is an object that represents CSS styles. It's the type of object returned by:
- `element.style` (inline styles)
- `window.getComputedStyle(element)` (computed styles)
- `stylesheet.cssRules[i].style` (styles from CSS rules)

## Key Characteristics

- **Array-like**: Has numeric indices and a `length` property
- **Property access**: Can access CSS properties via different naming conventions
- **Read/Write**: Can be read-only (computed styles) or read-write (inline styles)

## Accessing CSS Properties

There are multiple ways to access CSS properties:

```javascript
const element = document.getElementById('myElement');
const style = element.style;

// 1. camelCase (JavaScript property)
style.backgroundColor = 'red';
style.fontSize = '16px';
style.marginTop = '10px';

// 2. Hyphenated (CSS property name via methods)
style.setProperty('background-color', 'red');
style.getPropertyValue('background-color');

// 3. Bracket notation with camelCase
style['backgroundColor'] = 'red';

// 4. Bracket notation with hyphenated (CSS syntax)
style['background-color'] = 'red';  // Also works!
```

## Common Properties

```javascript
const style = element.style;

// Length - number of properties set
style.length;                    // e.g., 3

// cssText - all styles as a string
style.cssText;                   // "color: red; font-size: 16px;"
style.cssText = 'color: blue; background: white;';

// parentRule - the CSS rule this belongs to (if any)
style.parentRule;                // CSSStyleRule or null
```

## Common Methods

### setProperty()

```javascript
// setProperty(propertyName, value, priority)
style.setProperty('color', 'red');
style.setProperty('color', 'red', 'important');

// All these are equivalent:
style.setProperty('background-color', 'blue');
style.backgroundColor = 'blue';
style['background-color'] = 'blue';
```

### getPropertyValue()

```javascript
// Returns the value of a CSS property
const color = style.getPropertyValue('color');        // "red"
const bgColor = style.getPropertyValue('background-color');  // "blue"

// Returns empty string if not set
const margin = style.getPropertyValue('margin');      // "" (if not set)
```

### getPropertyPriority()

```javascript
// Check if a property has !important
style.setProperty('color', 'red', 'important');

style.getPropertyPriority('color');    // "important"
style.getPropertyPriority('fontSize'); // "" (not important)
```

### removeProperty()

```javascript
// Remove a property and return its value
const oldColor = style.removeProperty('color');  // Returns "red"

// Property is now removed
style.color;  // ""
```

### item()

```javascript
// Get property name by index
style.item(0);    // e.g., "color"
style.item(1);    // e.g., "font-size"

// Can also use bracket notation
style[0];         // "color"
style[1];         // "font-size"
```

## Inline Styles (element.style)

```html
<div id="myDiv" style="color: red; font-size: 16px;"></div>
```

```javascript
const div = document.getElementById('myDiv');
const style = div.style;

// Read inline styles
console.log(style.color);           // "red"
console.log(style.fontSize);        // "16px"
console.log(style.backgroundColor); // "" (not set inline)

// Modify inline styles
style.color = 'blue';
style.backgroundColor = 'yellow';

// Check length
console.log(style.length);          // 3

// Get cssText
console.log(style.cssText);         // "color: blue; font-size: 16px; background-color: yellow;"
```

## Computed Styles (getComputedStyle)

```javascript
const element = document.getElementById('myElement');
const computedStyle = window.getComputedStyle(element);

// computedStyle is a CSSStyleDeclaration
console.log(computedStyle instanceof CSSStyleDeclaration); // true

// Read-only - modifications have no effect
computedStyle.color = 'red';  // No effect!

// Can read values
const color = computedStyle.color;              // "rgb(255, 0, 0)"
const fontSize = computedStyle.fontSize;        // "16px"
const width = computedStyle.getPropertyValue('width');  // "200px"
```

## CSS Rule Styles (from stylesheets)

```javascript
// Access a stylesheet
const sheet = document.styleSheets[0];
const rule = sheet.cssRules[0];

// rule.style is a CSSStyleDeclaration
const ruleStyle = rule.style;

// Modify the rule (affects all matching elements)
ruleStyle.color = 'green';
ruleStyle.setProperty('font-size', '18px');
```

## Property Naming Conventions

```javascript
const style = element.style;

// CSS property → JavaScript property
// background-color → backgroundColor
// font-size → fontSize
// border-top-width → borderTopWidth
// -webkit-transform → WebkitTransform (vendor prefixes)

// Examples:
style.backgroundColor = 'red';    // ✓
style['background-color'] = 'red'; // ✓ Also works
style.background-color = 'red';   // ✗ Syntax error
```

## Working with !important

```javascript
const style = element.style;

// Set with !important
style.setProperty('color', 'red', 'important');

// Check if important
style.getPropertyPriority('color');  // "important"

// Remove !important by re-setting
style.setProperty('color', 'red');   // Without 'important'
style.getPropertyPriority('color');  // ""

// Note: Direct assignment doesn't support !important
style.color = 'blue';  // Cannot add !important this way
```

## Iterating Through Properties

```javascript
const style = element.style;

// Using length and item()
for (let i = 0; i < style.length; i++) {
  const propName = style.item(i);
  const propValue = style.getPropertyValue(propName);
  console.log(`${propName}: ${propValue}`);
}

// Using bracket notation
for (let i = 0; i < style.length; i++) {
  const propName = style[i];
  const propValue = style.getPropertyValue(propName);
  console.log(`${propName}: ${propValue}`);
}

// Convert to array
const props = Array.from(style);
props.forEach(propName => {
  console.log(`${propName}: ${style.getPropertyValue(propName)}`);
});
```

## cssText Property

```javascript
const style = element.style;

// Get all styles as string
const allStyles = style.cssText;
// "color: red; font-size: 16px; background-color: blue;"

// Set multiple styles at once
style.cssText = 'color: green; margin: 10px; padding: 5px;';

// Warning: This replaces ALL existing inline styles
style.cssText = 'color: blue;';  // All other styles are removed!

// To add without replacing, concatenate
style.cssText += '; font-weight: bold;';
```

## Practical Examples

### 1. **Clearing All Inline Styles**

```javascript
element.style.cssText = '';
// or
while (element.style.length > 0) {
  element.style.removeProperty(element.style[0]);
}
```

### 2. **Copying Styles Between Elements**

```javascript
const sourceStyle = sourceElement.style;
const targetStyle = targetElement.style;

for (let i = 0; i < sourceStyle.length; i++) {
  const propName = sourceStyle[i];
  const propValue = sourceStyle.getPropertyValue(propName);
  const priority = sourceStyle.getPropertyPriority(propName);
  targetStyle.setProperty(propName, propValue, priority);
}
```

**Loop approach:**
- Preserves `!important` priorities correctly via `getPropertyPriority()`
- Copies only **inline styles** from the source
- **Adds** to existing styles on the target (doesn't clear them first)

**`cssText` assignment:**
- Also copies only inline styles
- **Replaces all** existing inline styles on the target (clears them first)
- [Inference] May not preserve `!important` priorities consistently across all browsers in older implementations, though modern browsers should handle this correctly

**Practical Impact**

If the target element has no existing inline styles you want to keep, `cssText` is simpler and faster:

```javascript
targetElement.style.cssText = sourceElement.style.cssText;
```

If you need to:
- **Merge** styles (keep existing + add new)
- Guarantee `!important` preservation across all browsers

Then the loop approach is more reliable.

### 3. **Checking if Style is Set**

```javascript
// For inline styles
if (element.style.color) {
  console.log('Color is set inline');
}

// More reliable check
if (element.style.getPropertyValue('color')) {
  console.log('Color is set inline');
}

// Check in computed styles
const computed = window.getComputedStyle(element);
const hasColor = computed.getPropertyValue('color') !== '';
```

### 4. **Toggling Styles**

```javascript
// Toggle display
if (element.style.display === 'none') {
  element.style.display = 'block';
} else {
  element.style.display = 'none';
}

// More robust with computed styles
const computed = window.getComputedStyle(element);
if (computed.display === 'none') {
  element.style.display = 'block';
} else {
  element.style.display = 'none';
}
```

## Key Differences Summary

| Context | Read/Write | Values | Use Case |
|---------|------------|--------|----------|
| `element.style` | Read-write | As set inline | Modify inline styles |
| `getComputedStyle()` | Read-only | Computed/absolute | Get final rendered values |
| `rule.style` | Read-write | As defined in rule | Modify stylesheet rules |

## Common Gotchas

### 1. **Hyphenated vs camelCase**

```javascript
// These work:
style.backgroundColor = 'red';
style['background-color'] = 'red';
style.setProperty('background-color', 'red');

// This doesn't:
style.background-color = 'red';  // Syntax error
```

### 2. **Shorthand Properties**

```javascript
// Setting shorthand
style.margin = '10px 20px';

// Reading shorthand may not work as expected
console.log(style.margin);  // May be "" in some browsers

// Better to use longhand
console.log(style.marginTop);     // "10px"
console.log(style.marginRight);   // "20px"
```

### 3. **Units Required**

```javascript
// Wrong - no effect
style.width = 100;

// Correct - include units
style.width = '100px';
style.width = '50%';
style.width = '10em';
```

---

# CSS Rules

## What are CSS Rules?

A **CSS rule** is a complete style declaration that consists of:
1. **Selector** - which elements to style (e.g., `.class`, `#id`, `div`)
2. **Declaration block** - the CSS properties and values inside `{}`

```css
/* This entire block is a CSS rule */
.my-class {
  color: red;
  font-size: 16px;
}
```

## Accessing CSS Rules via JavaScript

CSS rules are stored in `CSSStyleSheet` objects, which you access through `document.styleSheets`.

```javascript
// Get all stylesheets
const stylesheets = document.styleSheets;

// Get a specific stylesheet
const sheet = document.styleSheets[0];

// Get all rules from a stylesheet
const rules = sheet.cssRules;  // or sheet.rules (older browsers)

// Get a specific rule
const rule = rules[0];
```

## CSSRule Types

There are different types of CSS rules:

```javascript
const rule = sheet.cssRules[0];

// Check the type
console.log(rule.type);

// Common types:
// CSSRule.STYLE_RULE = 1          (normal style rule)
// CSSRule.IMPORT_RULE = 3         (@import)
// CSSRule.MEDIA_RULE = 4          (@media)
// CSSRule.FONT_FACE_RULE = 5      (@font-face)
// CSSRule.KEYFRAMES_RULE = 7      (@keyframes)
// CSSRule.KEYFRAME_RULE = 8       (single keyframe)
```

## CSSStyleRule (Most Common)

This is the standard CSS rule type:

```javascript
const sheet = document.styleSheets[0];
const rule = sheet.cssRules[0];

// Properties of a CSSStyleRule:

// 1. type - the rule type
console.log(rule.type);  // 1 (STYLE_RULE)

// 2. selectorText - the selector
console.log(rule.selectorText);  // ".my-class"
rule.selectorText = ".new-class";  // Can modify

// 3. style - CSSStyleDeclaration object
console.log(rule.style);  // CSSStyleDeclaration
rule.style.color = 'blue';  // Modify styles

// 4. cssText - entire rule as text
console.log(rule.cssText);
// ".my-class { color: red; font-size: 16px; }"

// 5. parentStyleSheet - reference to containing stylesheet
console.log(rule.parentStyleSheet);

// 6. parentRule - parent rule (for nested rules)
console.log(rule.parentRule);  // null (if not nested)
```

## Working with Stylesheets

### Getting Stylesheets

```javascript
// All stylesheets on the page
const sheets = document.styleSheets;

// Iterate through stylesheets
for (let i = 0; i < sheets.length; i++) {
  console.log(sheets[i].href);  // URL (or null for <style> tags)
}

// Get stylesheet by href
function getStyleSheetByHref(href) {
  for (let sheet of document.styleSheets) {
    if (sheet.href && sheet.href.includes(href)) {
      return sheet;
    }
  }
  return null;
}

// Get stylesheet from <style> element
const styleElement = document.querySelector('style');
const sheet = styleElement.sheet;
```

### Stylesheet Properties

```javascript
const sheet = document.styleSheets[0];

// href - URL of external stylesheet (null for <style>)
console.log(sheet.href);  // "https://example.com/styles.css"

// disabled - enable/disable stylesheet
sheet.disabled = true;   // Disable
sheet.disabled = false;  // Enable

// cssRules - collection of rules
console.log(sheet.cssRules);

// ownerNode - the <link> or <style> element
console.log(sheet.ownerNode);

// media - media query list
console.log(sheet.media);  // MediaList object
```

## Finding Specific Rules

```javascript
// Find rule by selector
function findRule(selector) {
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        if (rule.selectorText === selector) {
          return rule;
        }
      }
    } catch (e) {
      // Cross-origin stylesheets throw SecurityError
      console.warn('Cannot access stylesheet:', sheet.href);
    }
  }
  return null;
}

// Usage
const rule = findRule('.my-class');
if (rule) {
  rule.style.color = 'red';
}
```

## Modifying Existing Rules

```javascript
const sheet = document.styleSheets[0];
const rule = sheet.cssRules[0];

// Modify the selector
rule.selectorText = '.new-selector';

// Modify styles
rule.style.color = 'blue';
rule.style.setProperty('font-size', '18px');
rule.style.setProperty('margin', '10px', 'important');

// Modify entire rule text
rule.cssText = '.new-class { color: green; background: white; }';

// Remove a property
rule.style.removeProperty('color');
```

## Adding New Rules

```javascript
const sheet = document.styleSheets[0];

// insertRule(rule, index)
// Returns the index of the inserted rule

// Add at the end
const index = sheet.insertRule('.new-class { color: red; }', sheet.cssRules.length);

// Add at the beginning
sheet.insertRule('.first-rule { margin: 0; }', 0);

// Add at specific position
sheet.insertRule('.mid-rule { padding: 10px; }', 5);

// Example: Add a hover rule
sheet.insertRule('.btn:hover { background: blue; }', sheet.cssRules.length);

// Example: Add a media query
sheet.insertRule('@media (max-width: 768px) { .mobile { display: block; } }', 0);
```

## Deleting Rules

```javascript
const sheet = document.styleSheets[0];

// deleteRule(index)
sheet.deleteRule(0);  // Delete first rule

// Delete by selector
function deleteRuleBySe(selector) {
  for (let sheet of document.styleSheets) {
    try {
      for (let i = sheet.cssRules.length - 1; i >= 0; i--) {
        if (sheet.cssRules[i].selectorText === selector) {
          sheet.deleteRule(i);
          return true;
        }
      }
    } catch (e) {
      console.warn('Cannot modify stylesheet:', sheet.href);
    }
  }
  return false;
}

// Usage
deleteRuleBySe('.unwanted-class');
```

## Creating New Stylesheets

```javascript
// Method 1: Create <style> element
const styleEl = document.createElement('style');
document.head.appendChild(styleEl);
const sheet = styleEl.sheet;

// Add rules to new stylesheet
sheet.insertRule('.dynamic { color: purple; }', 0);

// Method 2: Create via CSSStyleSheet constructor (modern browsers)
const sheet = new CSSStyleSheet();
sheet.insertRule('.new-class { color: blue; }');

// Adopt the stylesheet (for Shadow DOM)
document.adoptedStyleSheets = [sheet];
```

## Working with @media Rules

```javascript
const sheet = document.styleSheets[0];

// Find @media rule
for (let rule of sheet.cssRules) {
  if (rule.type === CSSRule.MEDIA_RULE) {
    console.log(rule.media.mediaText);  // "(max-width: 768px)"
    
    // Access rules inside @media
    const innerRules = rule.cssRules;
    for (let innerRule of innerRules) {
      console.log(innerRule.selectorText);
      console.log(innerRule.style.cssText);
    }
    
    // Add rule inside @media
    rule.insertRule('.new-mobile { display: block; }', 0);
  }
}
```

## Working with @keyframes

```javascript
const sheet = document.styleSheets[0];

// Find @keyframes rule
for (let rule of sheet.cssRules) {
  if (rule.type === CSSRule.KEYFRAMES_RULE) {
    console.log(rule.name);  // "slideIn"
    
    // Access keyframes
    const keyframes = rule.cssRules;
    for (let keyframe of keyframes) {
      console.log(keyframe.keyText);    // "0%", "50%", "100%"
      console.log(keyframe.style.cssText);
    }
    
    // Modify keyframe
    keyframes[0].style.opacity = '0';
    
    // Add new keyframe
    rule.appendRule('75% { transform: scale(1.2); }');
  }
}

// Add new @keyframes
sheet.insertRule(`
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
`, sheet.cssRules.length);
```

```css
@keyframes fadeIn {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  
  50% {
    opacity: 0.5;
  }
  
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Usage example */
.element {
  animation: fadeIn 1s ease-in-out;
}
```

```css
@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  
  to {
    transform: rotate(360deg);
  }
}

.spinner {
  animation: spin 2s linear infinite;
}
```

## Practical Examples

### 1. **Dynamic Theme Switching**

```javascript
function setTheme(primaryColor, bgColor) {
  const sheet = document.styleSheets[0];
  
  // Remove old theme rules
  for (let i = sheet.cssRules.length - 1; i >= 0; i--) {
    if (sheet.cssRules[i].selectorText?.startsWith('.theme-')) {
      sheet.deleteRule(i);
    }
  }
  
  // Add new theme rules
  sheet.insertRule(`.theme-primary { color: ${primaryColor}; }`, 0);
  sheet.insertRule(`.theme-bg { background: ${bgColor}; }`, 0);
}

setTheme('#3498db', '#ecf0f1');
```

This function dynamically changes the theme colors of a webpage by manipulating the CSS stylesheet directly. Here's what it does:

**Step by step:**

1. **Gets the first stylesheet** - `document.styleSheets[0]` accesses the first `<style>` or `<link>` stylesheet on the page

2. **Removes old theme rules** - Loops backward through all CSS rules and deletes any that start with `.theme-` (the backward loop prevents index shifting issues when deleting)

3. **Adds new theme rules** - Inserts two new CSS rules at the beginning of the stylesheet:
   - `.theme-primary { color: #3498db; }` - Sets text color for elements with class `theme-primary`
   - `.theme-bg { background: #ecf0f1; }` - Sets background color for elements with class `theme-bg`

4. **Applies the theme** - The function call sets primary color to blue (`#3498db`) and background to light gray (`#ecf0f1`)

**Usage example:**
```html
<div class="theme-bg">
  <h1 class="theme-primary">This text will be blue</h1>
</div>
```

**Note:** [Inference] This approach modifies the CSSOM (CSS Object Model) directly, which means the changes won't persist on page reload. Also, `document.styleSheets[0]` might fail if the first stylesheet is from a different origin (CORS restrictions).

### 2. **Modify All Rules Matching Pattern**

```javascript
function modifyMatchingRules(pattern, property, value) {
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        if (rule.selectorText && rule.selectorText.includes(pattern)) {
          rule.style.setProperty(property, value);
        }
      }
    } catch (e) {
      console.warn('Cannot access stylesheet:', sheet.href);
    }
  }
}

// Make all buttons bigger
modifyMatchingRules('.btn', 'font-size', '18px');
```

### 3. **Export Stylesheet as Text**

```javascript
function exportStylesheet(sheetIndex = 0) {
  const sheet = document.styleSheets[sheetIndex];
  let cssText = '';
  
  try {
    for (let rule of sheet.cssRules) {
      cssText += rule.cssText + '\n\n';
    }
  } catch (e) {
    console.error('Cannot export stylesheet:', e);
  }
  
  return cssText;
}

console.log(exportStylesheet(0));
```

### 4. **Live CSS Editor**

```javascript
function createLiveCSSEditor() {
  // Create new stylesheet for live edits
  const styleEl = document.createElement('style');
  styleEl.id = 'live-editor';
  document.head.appendChild(styleEl);
  const sheet = styleEl.sheet;
  
  return {
    addRule(selector, styles) {
      const css = `${selector} { ${styles} }`;
      sheet.insertRule(css, sheet.cssRules.length);
    },
    
    clear() {
      while (sheet.cssRules.length > 0) {
        sheet.deleteRule(0);
      }
    },
    
    export() {
      let css = '';
      for (let rule of sheet.cssRules) {
        css += rule.cssText + '\n';
      }
      return css;
    }
  };
}

const editor = createLiveCSSEditor();
editor.addRule('.highlight', 'background: yellow; color: black;');
editor.addRule('p', 'line-height: 1.6;');
console.log(editor.export());
```

## Cross-Origin Restrictions

```javascript
// Accessing rules from external stylesheets can throw errors
// if they're from a different origin

function safelyAccessRules(sheet) {
  try {
    const rules = sheet.cssRules;
    return Array.from(rules);
  } catch (e) {
    if (e.name === 'SecurityError') {
      console.warn('Cannot access cross-origin stylesheet:', sheet.href);
    }
    return [];
  }
}

// Usage
for (let sheet of document.styleSheets) {
  const rules = safelyAccessRules(sheet);
  rules.forEach(rule => {
    console.log(rule.cssText);
  });
}
```

## Performance Considerations

```javascript
// Modifying rules affects ALL matching elements
// Can cause reflow/repaint

// BAD: Multiple rule modifications
function badApproach() {
  const rule = findRule('.my-class');
  rule.style.color = 'red';        // Reflow
  rule.style.fontSize = '16px';    // Reflow
  rule.style.margin = '10px';      // Reflow
}

// BETTER: Batch changes
function betterApproach() {
  const rule = findRule('.my-class');
  rule.style.cssText = 'color: red; font-size: 16px; margin: 10px;';
}

// BEST: Use classes when possible
function bestApproach() {
  // Add class to elements instead of modifying rules
  elements.forEach(el => el.classList.add('styled'));
}
```

## Summary

| Task | Method |
|------|--------|
| Access stylesheets | `document.styleSheets` |
| Access rules | `sheet.cssRules` or `sheet.rules` |
| Add rule | `sheet.insertRule(rule, index)` |
| Delete rule | `sheet.deleteRule(index)` |
| Modify rule | `rule.style.property = value` |
| Change selector | `rule.selectorText = 'new'` |
| Get rule text | `rule.cssText` |

---

# CSSStyleRule

## What is CSSStyleRule?

`CSSStyleRule` represents a single CSS style rule with a selector and declaration block. It's what you get when you access most rules from a stylesheet.

```css
/* This becomes a CSSStyleRule object */
.my-class {
  color: red;
  font-size: 16px;
}
```

## Interface Definition

```javascript
interface CSSStyleRule : CSSRule {
  attribute DOMString selectorText;
  readonly attribute CSSStyleDeclaration style;
}
```

## Properties

### 1. **type**

Inherited from `CSSRule`. Always `1` for style rules.

```javascript
const rule = sheet.cssRules[0];
console.log(rule.type);  // 1
console.log(rule.type === CSSRule.STYLE_RULE);  // true
```

### 2. **selectorText** (Read/Write)

The selector part of the rule.

```javascript
const rule = sheet.cssRules[0];

// Read selector
console.log(rule.selectorText);  // ".my-class"

// Modify selector
rule.selectorText = ".new-class";
rule.selectorText = "#my-id";
rule.selectorText = "div.container > p";

// Complex selectors
rule.selectorText = ".class1, .class2, .class3";
rule.selectorText = "button:hover";
rule.selectorText = "[data-active='true']";
```

#### Selector Normalization

[Inference] Browsers may normalize selectors:

```javascript
// You set:
rule.selectorText = ".Class";

// Browser might return:
console.log(rule.selectorText);  // ".class" (lowercase)

// Whitespace normalization
rule.selectorText = "div   >   p";
console.log(rule.selectorText);  // "div > p" (normalized spacing)
```

### 3. **style** (Read-only)

A `CSSStyleDeclaration` object for modifying the rule's styles.

```javascript
const rule = sheet.cssRules[0];
const style = rule.style;

// Modify properties
style.color = 'blue';
style.fontSize = '18px';
style.setProperty('margin', '10px');

// Read properties
console.log(style.color);           // "blue"
console.log(style.getPropertyValue('font-size'));  // "18px"

// cssText
console.log(style.cssText);         // "color: blue; font-size: 18px;"
style.cssText = 'background: red;'; // Replace all styles
```

### 4. **cssText** (Read/Write)

The complete rule as a string.

```javascript
const rule = sheet.cssRules[0];

// Read entire rule
console.log(rule.cssText);
// ".my-class { color: red; font-size: 16px; }"

// Replace entire rule
rule.cssText = '.new-class { background: blue; padding: 20px; }';

// This changes both selector AND styles
console.log(rule.selectorText);  // ".new-class"
console.log(rule.style.cssText); // "background: blue; padding: 20px;"
```

### 5. **parentRule** (Read-only)

The containing rule (for nested rules), or `null` if not nested.

```javascript
// For a top-level rule
const rule = sheet.cssRules[0];
console.log(rule.parentRule);  // null

// For nested rules (e.g., inside @media)
const mediaRule = sheet.cssRules[1];  // @media rule
const nestedRule = mediaRule.cssRules[0];
console.log(nestedRule.parentRule === mediaRule);  // true
```

### 6. **parentStyleSheet** (Read-only)

Reference to the containing stylesheet.

```javascript
const rule = sheet.cssRules[0];
console.log(rule.parentStyleSheet === sheet);  // true

// Access other rules in same stylesheet
const allRules = rule.parentStyleSheet.cssRules;
```

## Accessing CSSStyleRule

### Method 1: Through Stylesheets

```javascript
// Get all stylesheets
const sheets = document.styleSheets;

// Get a specific stylesheet
const sheet = sheets[0];

// Get rules
const rules = sheet.cssRules;

// Get a specific rule
const rule = rules[0];

if (rule instanceof CSSStyleRule) {
  console.log('This is a style rule');
  console.log(rule.selectorText);
}
```

### Method 2: Find by Selector

```javascript
function findStyleRule(selector) {
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        if (rule instanceof CSSStyleRule && 
            rule.selectorText === selector) {
          return rule;
        }
      }
    } catch (e) {
      // Cross-origin stylesheet
      console.warn('Cannot access:', sheet.href);
    }
  }
  return null;
}

// Usage
const rule = findStyleRule('.my-class');
if (rule) {
  rule.style.color = 'red';
}
```

### Method 3: Find by Pattern

```javascript
function findStyleRulesMatching(pattern) {
  const matches = [];
  
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        if (rule instanceof CSSStyleRule && 
            rule.selectorText.includes(pattern)) {
          matches.push(rule);
        }
      }
    } catch (e) {
      console.warn('Cannot access:', sheet.href);
    }
  }
  
  return matches;
}

// Find all button rules
const buttonRules = findStyleRulesMatching('button');
buttonRules.forEach(rule => {
  console.log(rule.selectorText, rule.style.cssText);
});
```

## Modifying CSSStyleRule

### Changing the Selector

```javascript
const rule = findStyleRule('.old-class');

if (rule) {
  // Change selector
  rule.selectorText = '.new-class';
  
  // Now affects different elements
  // Elements with .old-class lose the styles
  // Elements with .new-class gain the styles
}
```

### Modifying Styles

```javascript
const rule = findStyleRule('.my-class');

if (rule) {
  // Method 1: Direct property assignment
  rule.style.color = 'blue';
  rule.style.fontSize = '18px';
  
  // Method 2: setProperty()
  rule.style.setProperty('background-color', 'yellow');
  rule.style.setProperty('margin', '10px', 'important');
  
  // Method 3: cssText (replaces all styles)
  rule.style.cssText = 'color: green; padding: 15px;';
  
  // Method 4: Modify entire rule
  rule.cssText = '.my-class { border: 1px solid red; }';
}
```

### Adding Properties

```javascript
const rule = findStyleRule('.my-class');

if (rule) {
  // Add new properties (keeps existing ones)
  rule.style.boxShadow = '0 2px 4px rgba(0,0,0,0.1)';
  rule.style.transition = 'all 0.3s ease';
}
```

### Removing Properties

```javascript
const rule = findStyleRule('.my-class');

if (rule) {
  // Remove specific property
  rule.style.removeProperty('color');
  
  // Set to empty string also removes
  rule.style.fontSize = '';
  
  // Remove all properties
  rule.style.cssText = '';
}
```

## Working with Different Selector Types

### Simple Selectors

```javascript
// Class selector
const rule1 = findStyleRule('.my-class');

// ID selector
const rule2 = findStyleRule('#my-id');

// Element selector
const rule3 = findStyleRule('div');

// Attribute selector
const rule4 = findStyleRule('[data-active]');
```

### Pseudo-classes and Pseudo-elements

```javascript
// Pseudo-class
const hoverRule = findStyleRule('button:hover');
if (hoverRule) {
  hoverRule.style.backgroundColor = 'blue';
}

// Pseudo-element
const beforeRule = findStyleRule('.icon::before');
if (beforeRule) {
  beforeRule.style.content = '"★"';
  beforeRule.style.color = 'gold';
}

// Multiple pseudo-classes
const activeHover = findStyleRule('a:hover:active');
```

### Complex Selectors

```javascript
// Descendant combinator
const descendant = findStyleRule('.container p');

// Child combinator
const child = findStyleRule('ul > li');

// Adjacent sibling
const adjacent = findStyleRule('h1 + p');

// General sibling
const sibling = findStyleRule('h1 ~ p');

// Multiple selectors
const multiple = findStyleRule('.class1, .class2, .class3');
```

## Checking Rule Properties

```javascript
const rule = sheet.cssRules[0];

// Check if it's a CSSStyleRule
if (rule instanceof CSSStyleRule) {
  console.log('Style rule');
}

// Alternative check
if (rule.type === CSSRule.STYLE_RULE) {
  console.log('Style rule');
}

// Check if selector matches
if (rule.selectorText === '.my-class') {
  console.log('Found the rule');
}

// Check if property exists
if (rule.style.color) {
  console.log('Color is set:', rule.style.color);
}

// Get property priority
const priority = rule.style.getPropertyPriority('color');
if (priority === 'important') {
  console.log('Color has !important');
}
```

## Practical Examples

### 1. **Dynamic Dark Mode**

```javascript
function toggleDarkMode(enable) {
  // Find body rule
  const bodyRule = findStyleRule('body');
  
  if (bodyRule) {
    if (enable) {
      bodyRule.style.backgroundColor = '#1a1a1a';
      bodyRule.style.color = '#ffffff';
    } else {
      bodyRule.style.backgroundColor = '#ffffff';
      bodyRule.style.color = '#000000';
    }
  }
  
  // Update all other relevant rules
  const rules = findStyleRulesMatching('.card');
  rules.forEach(rule => {
    if (enable) {
      rule.style.backgroundColor = '#2a2a2a';
      rule.style.borderColor = '#444';
    } else {
      rule.style.backgroundColor = '#fff';
      rule.style.borderColor = '#ddd';
    }
  });
}
```

### 2. **Live Style Inspector**

```javascript
function inspectRule(selector) {
  const rule = findStyleRule(selector);
  
  if (!rule) {
    console.log('Rule not found');
    return;
  }
  
  console.log('Selector:', rule.selectorText);
  console.log('Stylesheet:', rule.parentStyleSheet.href || '<style>');
  console.log('Styles:');
  
  const style = rule.style;
  for (let i = 0; i < style.length; i++) {
    const prop = style[i];
    const value = style.getPropertyValue(prop);
    const priority = style.getPropertyPriority(prop);
    console.log(`  ${prop}: ${value}${priority ? ' !' + priority : ''}`);
  }
}

// Usage
inspectRule('.my-class');
```

### 3. **Batch Style Updates**

```javascript
function updateStyles(selector, styles) {
  const rule = findStyleRule(selector);
  
  if (!rule) {
    console.warn('Rule not found:', selector);
    return false;
  }
  
  // Apply all styles
  for (let prop in styles) {
    const cssProp = prop.replace(/([A-Z])/g, '-$1').toLowerCase();
    rule.style.setProperty(cssProp, styles[prop]);
  }
  
  return true;
}

// Usage
updateStyles('.button', {
  backgroundColor: '#3498db',
  color: 'white',
  padding: '10px 20px',
  borderRadius: '5px',
  border: 'none'
});
```

### 4. **Rule Cloner**

```javascript
function cloneRule(sourceSelector, targetSelector) {
  const sourceRule = findStyleRule(sourceSelector);
  
  if (!sourceRule) {
    console.error('Source rule not found');
    return null;
  }
  
  // Get the stylesheet
  const sheet = sourceRule.parentStyleSheet;
  
  // Create new rule with same styles
  const newRuleCss = `${targetSelector} { ${sourceRule.style.cssText} }`;
  const index = sheet.insertRule(newRuleCss, sheet.cssRules.length);
  
  return sheet.cssRules[index];
}

// Usage
cloneRule('.original', '.copy');
```

### 5. **Responsive Style Modifier**

```javascript
function modifyResponsiveRules(breakpoint, selector, styles) {
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        // Find @media rule
        if (rule.type === CSSRule.MEDIA_RULE) {
          if (rule.media.mediaText.includes(breakpoint)) {
            // Find style rule inside @media
            for (let innerRule of rule.cssRules) {
              if (innerRule instanceof CSSStyleRule && 
                  innerRule.selectorText === selector) {
                // Apply styles
                for (let prop in styles) {
                  innerRule.style[prop] = styles[prop];
                }
              }
            }
          }
        }
      }
    } catch (e) {
      console.warn('Cannot access stylesheet');
    }
  }
}

// Usage
modifyResponsiveRules('768px', '.mobile-menu', {
  display: 'block',
  fontSize: '14px'
});
```

### 6. **Style Inheritance Tracker**

```javascript
function getStyleRuleChain(selector) {
  const rules = [];
  
  for (let sheet of document.styleSheets) {
    try {
      for (let rule of sheet.cssRules) {
        if (rule instanceof CSSStyleRule) {
          // Check if selector matches or is more specific
          if (selector.includes(rule.selectorText) || 
              rule.selectorText.includes(selector)) {
            rules.push({
              selector: rule.selectorText,
              specificity: calculateSpecificity(rule.selectorText),
              styles: rule.style.cssText,
              sheet: sheet.href || '<inline>'
            });
          }
        }
      }
    } catch (e) {
      console.warn('Cannot access stylesheet');
    }
  }
  
  // Sort by specificity
  return rules.sort((a, b) => a.specificity - b.specificity);
}

function calculateSpecificity(selector) {
  // [Inference] Simplified specificity calculation
  let score = 0;
  score += (selector.match(/#/g) || []).length * 100;  // IDs
  score += (selector.match(/\./g) || []).length * 10;  // Classes
  score += (selector.match(/\w+/g) || []).length * 1;  // Elements
  return score;
}

// Usage
console.log(getStyleRuleChain('.button'));
```

## Performance Considerations

```javascript
// Modifying rules affects ALL matching elements

// SLOW: Find and modify rule repeatedly
function slowApproach() {
  for (let i = 0; i < 100; i++) {
    const rule = findStyleRule('.item');
    rule.style.color = 'red';  // Causes reflow each time
  }
}

// FAST: Find once, cache reference
function fastApproach() {
  const rule = findStyleRule('.item');
  if (rule) {
    rule.style.color = 'red';  // Only one reflow
  }
}

// FASTER: Batch changes
function fasterApproach() {
  const rule = findStyleRule('.item');
  if (rule) {
    rule.style.cssText = 'color: red; font-size: 16px; margin: 10px;';
  }
}
```

## Common Patterns

### Safe Rule Access

```javascript
function safelyModifyRule(selector, callback) {
  try {
    const rule = findStyleRule(selector);
    if (rule instanceof CSSStyleRule) {
      callback(rule);
      return true;
    }
  } catch (e) {
    console.error('Error modifying rule:', e);
  }
  return false;
}

// Usage
safelyModifyRule('.my-class', rule => {
  rule.style.color = 'blue';
  rule.style.fontSize = '18px';
});
```

### Rule Existence Check

```javascript
function ensureRule(selector, defaultStyles = {}) {
  let rule = findStyleRule(selector);
  
  if (!rule) {
    // Create rule if it doesn't exist
    const sheet = document.styleSheets[0];
    const cssText = Object.entries(defaultStyles)
      .map(([k, v]) => `${k}: ${v}`)
      .join('; ');
    
    const index = sheet.insertRule(
      `${selector} { ${cssText} }`, 
      sheet.cssRules.length
    );
    rule = sheet.cssRules[index];
  }
  
  return rule;
}

// Usage
const rule = ensureRule('.dynamic-class', {
  color: 'red',
  'font-size': '16px'
});
```

## Summary

`CSSStyleRule` is the primary interface for working with CSS rules. It provides:

- **selectorText**: Read/write selector
- **style**: CSSStyleDeclaration for properties
- **cssText**: Complete rule as string
- **parentRule**: Containing rule (if nested)
- **parentStyleSheet**: Containing stylesheet

Key points:
- Most common rule type (type = 1)
- Modifications affect ALL matching elements
- Cross-origin restrictions apply
- Can be nested (inside @media, etc.)

---

# CSSStyleSheet

A `CSSStyleSheet` object represents a stylesheet in the document. It provides methods to inspect and modify CSS rules programmatically.

## Accessing CSSStyleSheets

```javascript
// From <style> or <link> elements
const styleElement = document.querySelector('style');
const sheet = styleElement.sheet; // Returns CSSStyleSheet

// From document.styleSheets collection
const firstSheet = document.styleSheets[0];
const allSheets = Array.from(document.styleSheets);
```

## Key Properties

```javascript
// Read-only properties
sheet.cssRules;        // CSSRuleList of all rules
sheet.ownerNode;       // The <style> or <link> element
sheet.href;            // URL for external stylesheets (null for <style>)
sheet.disabled;        // Boolean: enable/disable entire stylesheet

// Modify
sheet.disabled = true; // Disables the stylesheet
```

## Modifying Rules

```javascript
// Insert a new rule
const index = sheet.insertRule('.myClass { color: red; }', 0);
// Returns the index where rule was inserted

// Delete a rule by index
sheet.deleteRule(index);

// Replace all rules (modern browsers)
sheet.replaceSync('.newRule { color: blue; }');

// Async version
await sheet.replace('.newRule { color: blue; }');
```

## Iterating Through Rules

```javascript
for (let i = 0; i < sheet.cssRules.length; i++) {
  const rule = sheet.cssRules[i];
  
  if (rule instanceof CSSStyleRule) {
    console.log(rule.selectorText); // e.g., ".myClass"
    console.log(rule.style.color);  // Access specific property
    rule.style.color = 'green';     // Modify property
  }
}
```

## CORS Restrictions

[Unverified] External stylesheets from different origins may throw security errors when accessing `cssRules`:

```javascript
try {
  const rules = sheet.cssRules;
} catch (e) {
  console.log('Cannot access cross-origin stylesheet');
}
```

## Constructed Stylesheets (Modern)

```javascript
// Create new stylesheet programmatically
const sheet = new CSSStyleSheet();
sheet.replaceSync('.dynamic { background: yellow; }');

// Adopt into document or shadow DOM
document.adoptedStyleSheets = [sheet];

// For shadow DOM
shadowRoot.adoptedStyleSheets = [sheet];
```

## Common Use Cases

**Dynamic theming:**
```javascript
const themeSheet = document.styleSheets[0];
const ruleIndex = themeSheet.insertRule(':root { --primary: blue; }', 0);
```

**Disabling specific rules:**
```javascript
for (let rule of sheet.cssRules) {
  if (rule.selectorText === '.old-class') {
    rule.style.display = 'none';
  }
}
```

---

# MediaList

A `MediaList` object represents a collection of media queries associated with a stylesheet or CSS rule. It's accessed through the `media` property of `CSSStyleSheet` or `CSSMediaRule`.

## Accessing MediaList

```javascript
// From a stylesheet
const styleElement = document.querySelector('style');
const mediaList = styleElement.sheet.media;

// From a <link> element
const linkElement = document.querySelector('link');
const linkMedia = linkElement.sheet.media;

// From a @media rule
const mediaRule = sheet.cssRules[0]; // assuming it's a CSSMediaRule
const ruleMedia = mediaRule.media;
```

## Properties

```javascript
mediaList.length;        // Number of media queries
mediaList.mediaText;     // String of all queries: "screen and (min-width: 768px)"
```

## Reading Media Queries

```javascript
// Access by index
const firstQuery = mediaList[0];      // e.g., "screen"
const secondQuery = mediaList.item(1); // Alternative method

// Iterate through all queries
for (let i = 0; i < mediaList.length; i++) {
  console.log(mediaList[i]);
}

// Or use Array methods
Array.from(mediaList).forEach(query => {
  console.log(query);
});
```

## Modifying Media Queries

```javascript
// Add a media query
mediaList.appendMedium('print');
mediaList.appendMedium('(max-width: 600px)');

// Remove a media query
mediaList.deleteMedium('screen');

// Replace all queries
mediaList.mediaText = 'screen and (min-width: 1024px)';
```

## Examples

**Check if stylesheet applies to current media:**
```javascript
const sheet = document.styleSheets[0];
if (sheet.media.mediaText === '' || 
    window.matchMedia(sheet.media.mediaText).matches) {
  console.log('Stylesheet applies to current viewport');
}
```

**Modify media query dynamically:**
```javascript
const style = document.createElement('style');
style.media = 'screen';
document.head.appendChild(style);

// Later, change to print
style.sheet.media.mediaText = 'print';
```

**Working with @media rules:**
```javascript
const sheet = document.styleSheets[0];

for (let rule of sheet.cssRules) {
  if (rule instanceof CSSMediaRule) {
    console.log('Media query:', rule.media.mediaText);
    
    // Modify the media query
    rule.media.mediaText = 'screen and (min-width: 768px)';
    
    // Add another condition
    rule.media.appendMedium('(orientation: landscape)');
  }
}
```

## Empty MediaList

An empty `MediaList` (length 0, mediaText '') means the stylesheet applies to all media types:

```javascript
if (sheet.media.length === 0) {
  console.log('Applies to all media types');
}
```

## Legacy Methods

[Unverified] Older browsers may have different method names or behavior:
- Some implementations use `item()` method exclusively
- Direct array-style access (`mediaList[0]`) is widely supported in modern browsers

---

# DTD

### What is a DTD?

A **Document Type Declaration (DTD)** is a set of rules or a schema that defines the structure, elements, attributes, and the legal building blocks of an XML or HTML document. It ensures that documents conform to a specific structure and standards.

---

### Purpose of DTD

- **Validation:** Ensures that the document adheres to predefined rules.
- **Standardization:** Provides a consistent structure across documents.
- **Parsing:** Helps parsers understand the structure and meaning of the document.

---

### Types of DTDs

1. **Internal DTD:** Defined within the same document, usually inside the `<DOCTYPE>` declaration.
2. **External DTD:** Stored separately in an external file, linked via the `DOCTYPE` declaration.

---

### Basic Syntax of a DTD

In an XML document, the DTD is declared at the very beginning:

```xml
<!DOCTYPE root-element SYSTEM "filename.dtd">
```

or for internal subset:

```xml
<!DOCTYPE root-element [
  <!-- DTD declarations go here -->
]>
```

### Example of an Internal DTD

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE note [
  <!ELEMENT note (to, from, heading, body)>
  <!ELEMENT to (#PCDATA)>
  <!ELEMENT from (#PCDATA)>
  <!ELEMENT heading (#PCDATA)>
  <!ELEMENT body (#PCDATA)>
]>
<note>
  <to>John</to>
  <from>Jane</from>
  <heading>Reminder</heading>
  <body>Don't forget our meeting!</body>
</note>
```

### Example of an External DTD

Suppose you have a separate file `note.dtd`:

```dtd
<!ELEMENT note (to, from, heading, body)>
<!ELEMENT to (#PCDATA)>
<!ELEMENT from (#PCDATA)>
<!ELEMENT heading (#PCDATA)>
<!ELEMENT body (#PCDATA)>
```

And your XML document:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE note SYSTEM "note.dtd">
<note>
  <to>John</to>
  <from>Jane</from>
  <heading>Reminder</heading>
  <body>Don't forget our meeting!</body>
</note>
```

---

### Key Components of DTD

- **Elements:** Define what tags are allowed and their content models (`<!ELEMENT>`).
- **Attributes:** Define attributes for elements (`<!ATTLIST>`).
- **Entities:** Define shortcuts or special characters (`<!ENTITY>`).

---

### Summary

- DTDs specify the legal structure of an XML or HTML document.
- They can be internal or external.
- They help validate document correctness and consistency.

