## Color Resources and Theming


Color management in modern Android development leverages semantic color tokens rather than fixed hex values. This approach ensures consistency across themes and enables dynamic color adaptation.

Material Design 3 defines color roles through semantic naming:
- **Primary**: Brand colors for key components
- **Secondary**: Supporting accent colors
- **Tertiary**: Additional accent colors for variety
- **Error**: Colors for error states and warnings
- **Surface**: Background colors for components
- **Outline**: Border and divider colors

```kotlin
// colors.xml for light theme
<resources>
    <color name="seed">@android:color/holo_blue_bright</color>
    
    <!-- Primary colors -->
    <color name="primary">#1976D2</color>
    <color name="on_primary">#FFFFFF</color>
    <color name="primary_container">#BBDEFB</color>
    <color name="on_primary_container">#0D47A1</color>
    
    <!-- Surface colors -->
    <color name="surface">#FFFBFE</color>
    <color name="on_surface">#1C1B1F</color>
    <color name="surface_variant">#E7E0EC</color>
    <color name="on_surface_variant">#49454F</color>
</resources>
```

Dynamic color extraction from wallpapers requires API level 31+:

```kotlin
@RequiresApi(Build.VERSION_CODES.S)
fun applyDynamicColorsToActivity(activity: Activity) {
    DynamicColors.applyToActivityIfAvailable(activity) { context, _ ->
        // Optional: Custom fallback theme if dynamic colors unavailable
        R.style.Theme_MyApp_Fallback
    }
}
```

Color state lists enable responsive color behavior:

```xml
<!-- color/button_text_color.xml -->
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_enabled="false" android:color="?attr/colorOnSurface" android:alpha="0.38"/>
    <item android:state_pressed="true" android:color="?attr/colorPrimary"/>
    <item android:color="?attr/colorOnPrimary"/>
</selector>
```

