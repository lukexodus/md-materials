## Jetpack Compose Fundamentals


Jetpack Compose represents Android's modern toolkit for building native UI, replacing the traditional View system with a declarative approach. Unlike imperative UI frameworks where you manually manipulate UI elements, Compose uses a declarative paradigm where you describe what the UI should look like for any given state.

**Core Concepts**

Composable functions are the building blocks of Compose UI. These functions are annotated with `@Composable` and describe a portion of the user interface. They can call other composable functions and are executed during composition to build the UI tree.

```kotlin
@Composable
fun Greeting(name: String) {
    Text(text = "Hello $name!")
}
```

Composition is the process of building the UI tree by calling composable functions. During composition, Compose tracks which composables are called and builds an internal representation of the UI. Recomposition occurs when state changes, and Compose intelligently updates only the parts of the UI that need to change.

The Composition Local system provides a way to pass data down the composition tree implicitly. This is particularly useful for theming, providing ambient values like colors or typography that many composables might need.

**Compose Runtime**

The Compose runtime manages the composition process and handles state tracking. It uses a snapshot system to track state changes and determine when recomposition is necessary. The runtime is designed to be efficient, performing minimal work during recomposition by skipping composables whose inputs haven't changed.

