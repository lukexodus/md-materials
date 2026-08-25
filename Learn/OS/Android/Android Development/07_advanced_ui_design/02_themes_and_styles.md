## Themes and Styles


Android's theming system provides hierarchical styling through themes applied at application, activity, or view levels. Themes define default appearances for UI components, while styles offer reusable formatting for specific elements.

**Theme hierarchy flows from:**
- Application theme (defined in AndroidManifest.xml)
- Activity-specific themes
- View-level style attributes

Material themes provide comprehensive component styling through predefined attributes. The Material Components library offers several base themes:

```kotlin
// In themes.xml
<style name="Theme.MyApp" parent="Theme.Material3.DayNight">
    <item name="colorPrimary">@color/primary</item>
    <item name="colorSecondary">@color/secondary</item>
    <item name="colorTertiary">@color/tertiary</item>
    <item name="android:windowBackground">@color/background</item>
    <item name="textAppearanceHeadlineLarge">@style/TextAppearance.MyApp.HeadlineLarge</item>
</style>

<style name="TextAppearance.MyApp.HeadlineLarge" parent="TextAppearance.Material3.HeadlineLarge">
    <item name="fontFamily">@font/custom_font</item>
    <item name="android:textColor">?attr/colorOnSurface</item>
</style>
```

Dynamic theming enables runtime theme switching based on system settings or user preferences:

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Apply theme before setContentView
        when (getThemePreference()) {
            "light" -> setTheme(R.style.Theme_MyApp_Light)
            "dark" -> setTheme(R.style.Theme_MyApp_Dark)
            else -> {
                // Use system default (DayNight)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    DynamicColors.applyToActivityIfAvailable(this)
                }
            }
        }
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
```

