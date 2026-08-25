## Property Animations


Property animations, introduced in Android 3.0 (API level 11), provide a flexible framework for animating arbitrary object properties over time. Unlike view animations, property animations actually modify the underlying property values.

**ValueAnimator Foundation** ValueAnimator serves as the core animation engine, generating values between specified start and end points over a defined duration. It doesn't directly animate views but provides animated values that can be applied to any object property.

```kotlin
val animator = ValueAnimator.ofFloat(0f, 100f).apply {
    duration = 1000
    addUpdateListener { animation ->
        val value = animation.animatedValue as Float
        // Apply animated value to object property
        targetObject.customProperty = value
    }
}
```

**ObjectAnimator Convenience** ObjectAnimator extends ValueAnimator to automatically animate specific object properties using reflection. It requires the target object to have appropriate setter methods for the animated properties.

```kotlin
ObjectAnimator.ofFloat(targetView, "translationX", 0f, 200f).apply {
    duration = 500
    start()
}
```

**AnimatorSet Choreography** AnimatorSet coordinates multiple animations, supporting sequential, parallel, and complex timing relationships between individual animators. This enables sophisticated animation sequences.

**Interpolators and Timing** Interpolators define the rate of change during animations, controlling acceleration, deceleration, and easing effects. Android provides standard interpolators like AccelerateInterpolator, DecelerateInterpolator, and BounceInterpolator, while custom interpolators enable unique timing curves.

**Property Animation Listeners** Animation listeners provide callbacks for animation lifecycle events (start, end, cancel, repeat) and value updates. These callbacks enable coordination between animations and other application logic.

**Hardware Acceleration Considerations** Property animations benefit from hardware acceleration when animating properties that don't trigger layout recalculation. Properties like translationX, translationY, rotation, scaleX, scaleY, and alpha are typically hardware-accelerated.

