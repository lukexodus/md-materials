## View Animations and Transitions


View animations encompass both the legacy animation framework and modern transition systems for creating smooth visual changes between UI states.

**Legacy View Animations** The original animation framework animates view presentation without modifying actual property values. These animations are defined through XML resources or programmatic Animation objects and include scale, rotation, translation, and alpha effects.

**Activity and Fragment Transitions** The transition framework, introduced in Android 5.0 (API level 21), provides sophisticated scene-based animations between activities and fragments. Transitions can animate shared elements between screens and automatically animate layout changes.

**Shared Element Transitions** Shared element transitions create visual continuity by animating common elements between different screens. Elements are matched by transition name and automatically animated between their positions in different layouts.

```kotlin
// In calling activity
val options = ActivityOptionsCompat.makeSceneTransitionAnimation(
    this, sharedElement, "shared_element_name"
)
startActivity(intent, options.toBundle())
```

**Layout Transitions** LayoutTransition automatically animates changes within ViewGroup containers when children are added, removed, or change visibility. This provides smooth animations for dynamic UI changes without manual animation code.

**Scene Transitions** The Scene and Transition classes enable complex animations between different UI states within the same activity. Scenes represent different layout configurations, while transitions define how to animate between them.

**Transition Types** Android provides built-in transition types including Fade, Slide, Explode, ChangeBounds, ChangeTransform, and ChangeImageTransform. Custom transitions can be created by extending the Transition class.

**Fragment Shared Element Transitions** Fragment transitions support shared elements and custom animations during fragment replacement operations. The framework automatically handles the complex timing required for seamless transitions.

