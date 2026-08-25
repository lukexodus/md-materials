## Typography and Iconography


Typography in Material Design follows a systematic scale that establishes visual hierarchy and readability across different screen densities. The type system defines roles for different text purposes rather than arbitrary font sizes.

**Material Design 3 type scale includes:**
- **Display**: Large, short text for hero sections
- **Headline**: High-emphasis text for primary content
- **Title**: Medium-emphasis text for section headers
- **Label**: Text for buttons, tabs, and other UI elements
- **Body**: Regular text for reading

```kotlin
// Define custom typography in themes.xml
<style name="Theme.MyApp" parent="Theme.Material3.DayNight">
    <item name="textAppearanceDisplayLarge">@style/TextAppearance.MyApp.DisplayLarge</item>
    <item name="textAppearanceHeadlineMedium">@style/TextAppearance.MyApp.HeadlineMedium</item>
    <item name="textAppearanceBodyLarge">@style/TextAppearance.MyApp.BodyLarge</item>
</style>

<style name="TextAppearance.MyApp.DisplayLarge" parent="TextAppearance.Material3.DisplayLarge">
    <item name="fontFamily">@font/roboto_condensed</item>
    <item name="android:textSize">57sp</item>
    <item name="android:lineHeight">64sp</item>
    <item name="android:letterSpacing">-0.0025em</item>
</style>
```

Font loading requires proper resource management to avoid blocking the UI thread:

```kotlin
class TypographyManager(private val context: Context) {
    
    private val fontCache = mutableMapOf<Int, Typeface>()
    
    fun loadFont(@FontRes fontRes: Int): Typeface? {
        return fontCache.getOrPut(fontRes) {
            try {
                ResourcesCompat.getFont(context, fontRes) ?: Typeface.DEFAULT
            } catch (e: Exception) {
                // [Unverified] Exception handling behavior may vary by device
                Log.w("TypographyManager", "Failed to load font resource: $fontRes", e)
                Typeface.DEFAULT
            }
        }
    }
}
```

Iconography follows Material Design's icon principles with consistent visual weight and optical sizing. Vector drawables provide scalability across different screen densities:

```xml
<!-- drawable/ic_favorite.xml -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,21.35l-1.45,-1.32C5.4,15.36 2,12.28 2,8.5 2,5.42 4.42,3 7.5,3c1.74,0 3.41,0.81 4.5,2.09C13.09,3.81 14.76,3 16.5,3 19.58,3 22,5.42 22,8.5c0,3.78 -3.4,6.86 -8.55,11.54L12,21.35z"/>
</vector>
```

Programmatic icon theming enables dynamic color application:

```kotlin
fun ImageView.applyThemedIcon(@DrawableRes iconRes: Int) {
    val drawable = ContextCompat.getDrawable(context, iconRes)
    val themedDrawable = DrawableCompat.wrap(drawable!!.mutate())
    
    val colorStateList = ColorStateList.valueOf(
        MaterialColors.getColor(this, R.attr.colorOnSurface)
    )
    DrawableCompat.setTintList(themedDrawable, colorStateList)
    
    setImageDrawable(themedDrawable)
}
```

