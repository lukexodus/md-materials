## Complex Animations


### Animation Sequencing

Animation sequencing involves orchestrating multiple animations to create cohesive, narrative experiences. Proper sequencing ensures animations feel intentional rather than chaotic, with careful timing and coordination between elements.

**Key points:**

- Use animation-delay to stagger element entrances and create rhythm
- Chain animations using animationend events for precise control
- Leverage CSS custom properties for dynamic timing adjustments
- Consider easing functions to create natural motion relationships

Sequential animations can be achieved through CSS delays, JavaScript promises, or animation libraries. The key is maintaining consistent timing relationships and ensuring each animation builds upon the previous one. Overlapping animations often feel more natural than strictly sequential ones.

**Example:**

```css
.card-sequence .card {
  opacity: 0;
  transform: translateY(50px);
  animation: cardEnter 0.6s ease-out forwards;
}

.card-sequence .card:nth-child(1) { animation-delay: 0.1s; }
.card-sequence .card:nth-child(2) { animation-delay: 0.2s; }
.card-sequence .card:nth-child(3) { animation-delay: 0.3s; }

@keyframes cardEnter {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Dynamic sequencing with custom properties */
.dynamic-sequence {
  --sequence-delay: 0s;
  animation-delay: var(--sequence-delay);
}
```

Complex sequences often require JavaScript for dynamic control, event coordination, and responsive timing adjustments based on user interactions or viewport changes.

### SVG Animations with CSS

SVG elements can be animated using CSS properties, offering scalable vector animations that maintain crisp quality at any size. CSS transforms, filters, and custom properties work seamlessly with SVG elements.

**Key points:**

- SVG elements support all CSS animation properties
- Use transform-origin to control rotation and scaling centers
- Animate SVG-specific properties like stroke-dasharray and stroke-dashoffset
- Combine CSS animations with SVG's inherent scalability for responsive designs

SVG path animations using stroke-dasharray create drawing effects, while transform animations enable complex motion paths. CSS filters applied to SVG elements can create sophisticated visual effects without JavaScript.

**Example:**

```css
/* Drawing animation */
.svg-path {
  stroke-dasharray: 1000;
  stroke-dashoffset: 1000;
  animation: draw 2s ease-in-out forwards;
}

@keyframes draw {
  to {
    stroke-dashoffset: 0;
  }
}

/* SVG icon bounce with transform-origin */
.svg-icon {
  transform-origin: center;
  animation: iconBounce 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

@keyframes iconBounce {
  0% { transform: scale(0) rotate(0deg); }
  50% { transform: scale(1.2) rotate(180deg); }
  100% { transform: scale(1) rotate(360deg); }
}

/* Color morphing with CSS custom properties */
.svg-morph {
  --color-start: #ff6b6b;
  --color-end: #4ecdc4;
  fill: var(--color-start);
  animation: colorMorph 3s infinite alternate;
}

@keyframes colorMorph {
  to {
    fill: var(--color-end);
  }
}
```

Advanced SVG animations can include morphing between different path shapes using CSS clip-path or combining multiple animated elements within a single SVG container.

### Scroll-Triggered Animations

Scroll-triggered animations respond to user scroll position, creating immersive experiences that reveal content progressively. These animations require careful performance consideration to maintain smooth scrolling.

**Key points:**

- Use Intersection Observer API for performance-optimized scroll detection
- Implement CSS scroll-driven animations for hardware-accelerated performance
- Consider scroll velocity and direction for more sophisticated triggers
- Debounce scroll events to prevent excessive animation triggering

Modern browsers support CSS scroll-driven animations using animation-timeline, eliminating JavaScript overhead for basic scroll animations. For complex scroll interactions, combining Intersection Observer with CSS custom properties provides optimal performance.

**Example:**

```css
/* CSS scroll-driven animation */
.scroll-reveal {
  animation: revealContent linear;
  animation-timeline: scroll();
  animation-range: entry 0% entry 100%;
}

@keyframes revealContent {
  from {
    opacity: 0;
    transform: translateY(100px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Parallax effect with scroll */
.parallax-bg {
  animation: parallaxMove linear;
  animation-timeline: scroll();
}

@keyframes parallaxMove {
  to {
    transform: translateY(-50%);
  }
}

/* JavaScript-enhanced scroll triggers */
.js-scroll-trigger {
  --scroll-progress: 0;
  opacity: calc(var(--scroll-progress));
  transform: translateX(calc((1 - var(--scroll-progress)) * 100px));
  transition: all 0.3s ease-out;
}
```

Scroll-triggered animations should respect user preferences for reduced motion and provide fallback experiences for users who prefer static content.

### Motion Design Principles

Motion design principles guide the creation of purposeful, delightful animations that enhance user experience rather than distract from it. These principles ensure animations feel natural and serve clear functional purposes.

**Key points:**

- Easing functions should mimic real-world physics with acceleration and deceleration
- Animation duration should match the complexity and distance of movement
- Consistent timing and easing across an interface creates cohesive experiences
- Respect user preferences for reduced motion accessibility

The twelve principles of animation from Disney apply to web animations: squash and stretch, anticipation, staging, straight ahead and pose-to-pose, follow through, slow in and slow out, arc, secondary action, timing, exaggeration, solid drawing, and appeal.

**Example:**

```css
/* Natural easing curves */
.natural-bounce {
  animation: naturalBounce 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

/* Anticipation before main action */
.anticipation-click {
  animation: anticipateClick 0.15s ease-in-out;
}

@keyframes anticipateClick {
  0% { transform: scale(1); }
  50% { transform: scale(0.95); }
  100% { transform: scale(1.05); }
}

/* Follow-through and overlapping action */
.card-flip {
  animation: cardFlip 0.6s ease-in-out;
}

@keyframes cardFlip {
  0% { transform: rotateY(0deg) scale(1); }
  50% { transform: rotateY(90deg) scale(0.8); }
  100% { transform: rotateY(180deg) scale(1); }
}

/* Respect reduced motion preferences */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

Effective motion design creates hierarchy through timing, establishes spatial relationships through movement, and provides feedback for user interactions. Animations should have clear beginnings, middles, and ends, with appropriate pause times between sequences.

**Conclusion:** Complex animations require balancing technical execution with design principles, ensuring performance optimization while creating engaging user experiences. The most successful complex animations feel effortless and purposeful, guiding users through interfaces with clarity and delight while respecting accessibility preferences and device capabilities.

---

