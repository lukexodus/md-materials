## View and ViewGroup Hierarchy


The Android UI system follows a tree-based hierarchy where every UI element extends from the base View class. This hierarchy consists of two primary types of objects:

**Views** are the basic building blocks of the user interface - individual UI components like buttons, text fields, images, and other interactive elements. Each View occupies a rectangular area on the screen and handles drawing and event processing for that area.

**ViewGroups** serve as invisible containers that hold and organize other Views or ViewGroups. They define layout policies that determine how their child elements are positioned and sized. Common examples include LinearLayout, RelativeLayout, and ConstraintLayout.

The hierarchy starts with a root ViewGroup (typically the layout defined in your activity's XML file) and branches down through nested ViewGroups to individual Views. This structure allows for complex, nested layouts while maintaining clear organization and efficient rendering.

**Key Points:**

- Every View has exactly one parent ViewGroup (except the root)
- ViewGroups can contain any number of child Views or ViewGroups
- The hierarchy determines the order of drawing and event handling
- Deep nesting can impact performance due to multiple layout passes

**Example** of a simple hierarchy:

```kotlin
// Root ViewGroup (LinearLayout)
//   ├── TextView
//   ├── ViewGroup (RelativeLayout)
//   │     ├── Button
//   │     └── ImageView
//   └── RecyclerView
```

