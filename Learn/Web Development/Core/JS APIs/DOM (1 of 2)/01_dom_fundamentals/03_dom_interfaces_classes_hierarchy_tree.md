## DOM Interfaces/Classes Hierarchy Tree


### Core DOM Hierarchy

#### EventTarget
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

### Collection Interfaces

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

### DOM Data Structures

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

### Range and Selection

- **Range**
- **Selection**
- **StaticRange**

### Mutation and Observation

- **MutationObserver**
- **MutationRecord**
- **IntersectionObserver**
- **IntersectionObserverEntry**
- **ResizeObserver**
- **ResizeObserverEntry**
- **PerformanceObserver**

### Events Hierarchy

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

### Media and Graphics

- **CanvasRenderingContext2D**
- **WebGLRenderingContext**
  - WebGL2RenderingContext
- **ImageData**
- **ImageBitmap**
- **Path2D**
- **TextMetrics**
- **CanvasGradient**
- **CanvasPattern**

### File and Blob APIs

- **Blob**
  - File
- **FileList**
- **FileReader**
- **FormData**
- **DataTransfer**
- **DataTransferItem**
- **DataTransferItemList**

### URL and History

- **URL**
- **URLSearchParams**
- **Location**
- **History**

### Storage

- **Storage** (localStorage, sessionStorage)
- **StorageManager**

### Web Components

- **CustomElementRegistry**
- **ShadowRoot** (extends DocumentFragment)

### Miscellaneous

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

### Abstract Interfaces (not directly instantiated)

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

