## CSS Animations


### Understanding CSS Animations

CSS animations enable smooth transitions between different style states over time, creating dynamic visual effects without requiring JavaScript. Unlike CSS transitions that animate between two states, animations can define multiple keyframes with complex sequences, loops, and timing controls, providing powerful tools for enhancing user experience and visual storytelling.

### @keyframes Rule

The @keyframes rule defines the animation sequence by specifying styles at various points during the animation timeline. It serves as the blueprint for how properties should change over the animation duration.

**Key points:**

- Defines animation steps using percentage or keyword selectors
- Can animate multiple properties simultaneously
- Supports both percentage values (0% to 100%) and keywords (from, to)
- Reusable across multiple elements and animations

**Example:**

```css
@keyframes slideIn {
  from {
    transform: translateX(-100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(0, 123, 255, 0.7);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 20px rgba(0, 123, 255, 0);
  }
}
```

**Output:** slideIn creates a sliding entrance effect, while pulse creates a pulsing animation with expanding shadow effects.

### Multi-Step Keyframe Animations

Complex animations often require multiple keyframes to create sophisticated motion sequences.

**Example:**

```css
@keyframes bounceIn {
  0% {
    transform: scale(0.3) translateY(-100px);
    opacity: 0;
  }
  25% {
    transform: scale(1.05) translateY(0);
    opacity: 1;
  }
  50% {
    transform: scale(0.95) translateY(-10px);
  }
  75% {
    transform: scale(1.02) translateY(0);
  }
  100% {
    transform: scale(1) translateY(0);
  }
}

@keyframes rainbow {
  0% { color: red; }
  16.66% { color: orange; }
  33.33% { color: yellow; }
  50% { color: green; }
  66.66% { color: blue; }
  83.33% { color: indigo; }
  100% { color: violet; }
}
```

**Output:** bounceIn creates a bouncing entrance effect with multiple motion phases, while rainbow cycles through spectrum colors.

### Animation Properties Overview

CSS animation properties control how keyframe animations are applied to elements, providing precise control over timing, duration, repetition, and behavior.

### animation-name Property

The animation-name property specifies which @keyframes rule to apply to an element.

**Key points:**

- References the @keyframes rule name
- Multiple animations can be applied with comma separation
- Value of 'none' disables animation
- Case-sensitive naming

**Example:**

```css
.slide-element {
  animation-name: slideIn;
}

.complex-animation {
  animation-name: slideIn, pulse, fadeIn;
}

.no-animation {
  animation-name: none;
}
```

### animation-duration Property

The animation-duration property sets how long the animation takes to complete one cycle.

**Key points:**

- Accepts time values in seconds (s) or milliseconds (ms)
- Default value is 0s (no animation)
- Must be positive value
- Each animation in a list can have different durations

**Example:**

```css
.quick-animation {
  animation-name: slideIn;
  animation-duration: 0.3s;
}

.slow-animation {
  animation-name: pulse;
  animation-duration: 2s;
}

.multiple-durations {
  animation-name: slideIn, pulse, rotate;
  animation-duration: 0.5s, 1s, 3s;
}
```

**Output:** Elements animate at different speeds, with slideIn completing in 0.3 seconds, pulse in 2 seconds, and multiple animations having individual timing.

### animation-timing-function Property

The animation-timing-function property controls the acceleration curve of the animation, determining how intermediate values are calculated.

#### Built-in Timing Functions

**Example:**

```css
.linear { animation-timing-function: linear; }
.ease { animation-timing-function: ease; }
.ease-in { animation-timing-function: ease-in; }
.ease-out { animation-timing-function: ease-out; }
.ease-in-out { animation-timing-function: ease-in-out; }
```

#### Custom Cubic Bezier Functions

**Example:**

```css
.custom-ease {
  animation-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

.bounce-effect {
  animation-timing-function: cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
```

#### Step Functions

**Example:**

```css
.pixelated-animation {
  animation-timing-function: steps(8, end);
}

.typewriter-effect {
  animation-timing-function: steps(20, end);
}
```

**Output:** Step functions create discrete jumps rather than smooth transitions, useful for sprite animations or typewriter effects.

### animation-delay Property

The animation-delay property specifies when the animation should start after being applied to an element.

**Key points:**

- Positive values delay animation start
- Negative values start animation partway through
- Can create staggered animation effects
- Accepts time values in seconds or milliseconds

**Example:**

```css
.staggered-item-1 {
  animation-name: slideIn;
  animation-duration: 0.5s;
  animation-delay: 0s;
}

.staggered-item-2 {
  animation-name: slideIn;
  animation-duration: 0.5s;
  animation-delay: 0.1s;
}

.staggered-item-3 {
  animation-name: slideIn;
  animation-duration: 0.5s;
  animation-delay: 0.2s;
}

.pre-started {
  animation-name: pulse;
  animation-duration: 2s;
  animation-delay: -1s; /* Starts halfway through */
}
```

**Output:** Creates staggered entrance effects where items animate sequentially, while pre-started begins mid-animation.

### animation-iteration-count Property

The animation-iteration-count property defines how many times the animation should repeat.

**Key points:**

- Accepts positive numbers or 'infinite'
- Decimal values create partial iterations
- Default value is 1 (single iteration)
- Can create looping animations

**Example:**

```css
.single-play {
  animation-iteration-count: 1;
}

.triple-play {
  animation-iteration-count: 3;
}

.infinite-loop {
  animation-iteration-count: infinite;
}

.partial-iteration {
  animation-iteration-count: 2.5;
}
```

**Output:** Animations play specified number of times, with infinite creating continuous loops and partial values stopping mid-animation.

### animation-direction Property

The animation-direction property controls whether animations play forward, backward, or alternate between directions.

#### Direction Values

**Example:**

```css
.normal-direction {
  animation-direction: normal; /* Default: forward */
}

.reverse-direction {
  animation-direction: reverse; /* Backward */
}

.alternate-direction {
  animation-direction: alternate; /* Forward, then backward */
}

.alternate-reverse {
  animation-direction: alternate-reverse; /* Backward, then forward */
}
```

#### Practical Direction Usage

**Example:**

```css
@keyframes pendulum {
  from { transform: rotate(-30deg); }
  to { transform: rotate(30deg); }
}

.pendulum-swing {
  animation-name: pendulum;
  animation-duration: 1s;
  animation-iteration-count: infinite;
  animation-direction: alternate;
  animation-timing-function: ease-in-out;
}
```

**Output:** Creates a realistic pendulum swinging motion by alternating between forward and reverse directions.

### animation-fill-mode Property

The animation-fill-mode property determines which styles are applied before and after animation execution.

#### Fill Mode Values

**Example:**

```css
.fill-none {
  animation-fill-mode: none; /* Default styles before/after */
}

.fill-forwards {
  animation-fill-mode: forwards; /* Retains end state */
}

.fill-backwards {
  animation-fill-mode: backwards; /* Applies start state during delay */
}

.fill-both {
  animation-fill-mode: both; /* Combines forwards and backwards */
}
```

#### Practical Fill Mode Usage

**Example:**

```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in-element {
  opacity: 0; /* Initial state */
  animation-name: fadeInUp;
  animation-duration: 0.6s;
  animation-fill-mode: forwards; /* Stays visible after animation */
  animation-delay: 0.5s;
}
```

**Output:** Element starts invisible, remains invisible during delay, then fades in and stays visible after animation completes.

### animation-play-state Property

The animation-play-state property controls whether animations are running or paused.

**Key points:**

- Values: running (default) or paused
- Can be controlled dynamically with JavaScript
- Useful for interactive animations
- Preserves animation position when paused

**Example:**

```css
.running-animation {
  animation-play-state: running;
}

.paused-animation {
  animation-play-state: paused;
}

.hover-controlled:hover {
  animation-play-state: paused;
}

.interactive-button {
  animation: pulse 1s infinite;
}

.interactive-button:hover {
  animation-play-state: paused;
}
```

**Output:** Animations can be controlled interactively, pausing on hover or other user interactions.

### Animation Shorthand Property

The animation shorthand property combines all animation properties into a single declaration.

#### Shorthand Syntax Order

```
animation: name duration timing-function delay iteration-count direction fill-mode play-state;
```

**Example:**

```css
.shorthand-animation {
  animation: slideIn 0.5s ease-out 0.2s 1 normal forwards running;
}

.multiple-animations {
  animation: 
    slideIn 0.5s ease-out 0s forwards,
    pulse 1s ease-in-out 0.5s infinite alternate,
    rotate 3s linear 1s infinite normal;
}

.simple-shorthand {
  animation: fadeIn 1s ease-in-out forwards;
}
```

**Output:** Shorthand provides concise animation definitions while supporting multiple simultaneous animations.

### Animation Timing and Easing

Sophisticated timing control creates natural-feeling animations that enhance user experience.

### Advanced Timing Functions

**Example:**

```css
@keyframes elasticEntry {
  0% {
    transform: scale(0) rotate(45deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.2) rotate(0deg);
    opacity: 1;
  }
  75% {
    transform: scale(0.9) rotate(0deg);
  }
  100% {
    transform: scale(1) rotate(0deg);
  }
}

.elastic-element {
  animation: elasticEntry 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}
```

### Performance Optimization

Certain properties animate more efficiently than others, impacting performance on lower-end devices.

#### GPU-Accelerated Properties

```css
/* Efficient animations - GPU accelerated */
.efficient-animation {
  animation: efficientMove 2s infinite;
}

@keyframes efficientMove {
  from {
    transform: translateX(0) scale(1);
    opacity: 1;
  }
  to {
    transform: translateX(100px) scale(1.1);
    opacity: 0.5;
  }
}

/* Less efficient - triggers layout/paint */
.inefficient-animation {
  animation: inefficientMove 2s infinite;
}

@keyframes inefficientMove {
  from {
    left: 0;
    width: 100px;
    background-color: red;
  }
  to {
    left: 100px;
    width: 200px;
    background-color: blue;
  }
}
```

**Key points:**

- Transform and opacity are GPU-accelerated
- Avoid animating layout properties (width, height, top, left)
- Use transform instead of position changes
- Use opacity instead of visibility changes

### Animation Events and Control

CSS animations trigger JavaScript events that enable programmatic control and coordination.

### Animation Event Types

#### animationstart Event

```javascript
element.addEventListener('animationstart', function(e) {
  console.log('Animation started:', e.animationName);
  // Initialize animation-dependent logic
});
```

#### animationend Event

```javascript
element.addEventListener('animationend', function(e) {
  console.log('Animation completed:', e.animationName);
  // Clean up or trigger next animation
  element.classList.remove('animated');
});
```

#### animationiteration Event

```javascript
element.addEventListener('animationiteration', function(e) {
  console.log('Animation iteration completed:', e.animationName);
  // Update counter or modify animation mid-loop
});
```

### Dynamic Animation Control

**Example:**

```javascript
class AnimationController {
  constructor(element) {
    this.element = element;
    this.setupEventListeners();
  }
  
  setupEventListeners() {
    this.element.addEventListener('animationend', (e) => {
      this.onAnimationEnd(e);
    });
  }
  
  startAnimation(animationName) {
    this.element.style.animationName = animationName;
    this.element.style.animationPlayState = 'running';
  }
  
  pauseAnimation() {
    this.element.style.animationPlayState = 'paused';
  }
  
  resetAnimation() {
    this.element.style.animation = 'none';
    // Force reflow
    this.element.offsetHeight;
    this.element.style.animation = '';
  }
  
  onAnimationEnd(event) {
    console.log(`${event.animationName} completed`);
    // Trigger next animation or cleanup
  }
}
```

### Coordinated Animation Sequences

**Example:**

```css
@keyframes sequence-step-1 {
  from { transform: translateX(-100px); opacity: 0; }
  to { transform: translateX(0); opacity: 1; }
}

@keyframes sequence-step-2 {
  from { transform: scale(1); }
  to { transform: scale(1.2); }
}

@keyframes sequence-step-3 {
  from { transform: scale(1.2); }
  to { transform: scale(1) rotate(360deg); }
}
```

```javascript
class SequenceAnimator {
  constructor(element) {
    this.element = element;
    this.currentStep = 0;
    this.sequence = ['sequence-step-1', 'sequence-step-2', 'sequence-step-3'];
    this.setupEvents();
  }
  
  setupEvents() {
    this.element.addEventListener('animationend', () => {
      this.nextStep();
    });
  }
  
  start() {
    this.playStep(this.sequence[0]);
  }
  
  playStep(animationName) {
    this.element.style.animationName = animationName;
  }
  
  nextStep() {
    this.currentStep++;
    if (this.currentStep < this.sequence.length) {
      this.playStep(this.sequence[this.currentStep]);
    } else {
      this.onSequenceComplete();
    }
  }
  
  onSequenceComplete() {
    console.log('Animation sequence completed');
    this.element.classList.add('sequence-complete');
  }
}
```

### Complex Animation Patterns

#### Staggered Animations

```css
.stagger-container .item {
  animation: slideInUp 0.6s ease-out forwards;
  opacity: 0;
}

.stagger-container .item:nth-child(1) { animation-delay: 0.1s; }
.stagger-container .item:nth-child(2) { animation-delay: 0.2s; }
.stagger-container .item:nth-child(3) { animation-delay: 0.3s; }
.stagger-container .item:nth-child(4) { animation-delay: 0.4s; }
.stagger-container .item:nth-child(5) { animation-delay: 0.5s; }

@keyframes slideInUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}
```

#### Infinite Loading Animations

```css
@keyframes spinner {
  to {
    transform: rotate(360deg);
  }
}

@keyframes dots {
  0%, 20% {
    color: transparent;
    text-shadow: 
      0.25em 0 0 transparent,
      0.5em 0 0 transparent;
  }
  40% {
    color: currentColor;
    text-shadow: 
      0.25em 0 0 transparent,
      0.5em 0 0 transparent;
  }
  60% {
    text-shadow: 
      0.25em 0 0 currentColor,
      0.5em 0 0 transparent;
  }
  80%, 100% {
    text-shadow: 
      0.25em 0 0 currentColor,
      0.5em 0 0 currentColor;
  }
}

.spinner {
  animation: spinner 1s linear infinite;
}

.loading-dots::after {
  content: "...";
  animation: dots 1.5s steps(5, end) infinite;
}
```

### Accessibility Considerations

Animations must respect user preferences and accessibility requirements.

#### Respecting Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01s !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01s !important;
  }
  
  .decorative-animation {
    animation: none !important;
  }
}

@media (prefers-reduced-motion: no-preference) {
  .enhanced-animation {
    animation: complexSequence 2s ease-in-out;
  }
}
```

#### Focus and Screen Reader Considerations

```css
.animated-element:focus {
  animation-play-state: paused;
  outline: 2px solid blue;
}

.screen-reader-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

**Conclusion:** CSS animations provide powerful tools for creating engaging, interactive experiences through the @keyframes rule and comprehensive animation properties. Understanding timing functions, iteration control, and event handling enables sophisticated animation systems that enhance user experience while maintaining performance and accessibility. Proper use of animation events allows for coordinated sequences and dynamic control, creating polished, professional web applications.

**Next steps:**

- Experiment with complex keyframe sequences and timing functions
- Implement animation event handling for interactive experiences
- Optimize animations for performance across different devices
- Explore CSS animation libraries and frameworks for rapid development
- Study motion design principles for more natural and engaging animations

---
