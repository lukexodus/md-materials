## Compose UI Development


Building user interfaces in Compose involves understanding layouts, modifiers, and the component ecosystem. Compose provides a rich set of built-in composables and a powerful modifier system for customizing appearance and behavior.

**Layout System**

Compose uses a different layout system than traditional Android views. The fundamental layout composables include Column, Row, and Box, which handle vertical, horizontal, and stacked arrangements respectively.

```kotlin
@Composable
fun ProfileScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(id = R.drawable.profile),
            contentDescription = "Profile picture",
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "John Doe",
            style = MaterialTheme.typography.headlineMedium
        )
    }
}
```

**Modifier System**

Modifiers are used to decorate or add behavior to composables. They can change appearance, add padding or margins, handle gestures, or apply transformations. Modifiers are chainable and are applied in the order they're specified.

```kotlin
@Composable
fun StylizedButton() {
    Button(
        onClick = { /* Handle click */ },
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .background(
                brush = Brush.horizontalGradient(
                    colors = listOf(Color.Blue, Color.Cyan)
                ),
                shape = RoundedCornerShape(8.dp)
            )
            .clickable { /* Additional click handling */ }
    ) {
        Text("Gradient Button")
    }
}
```

**Material Design Integration**

Compose provides comprehensive Material Design support through Material3 components. The theming system allows customization of colors, typography, and shapes throughout the application.

```kotlin
@Composable
fun ThemedApp() {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = Color(0xFF6200EE),
            secondary = Color(0xFF03DAC6)
        ),
        typography = Typography(
            headlineLarge = TextStyle(
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold
            )
        )
    ) {
        // App content
    }
}
```

