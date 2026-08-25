## Linear, Relative, and Constraint Layouts


### LinearLayout

LinearLayout arranges child views in a single direction - either horizontally or vertically. It's one of the simplest and most predictable layouts, making it ideal for straightforward arrangements.

The layout uses the `android:orientation` attribute to determine direction and supports weight distribution through `android:layout_weight`, which allows children to proportionally share available space.

**Key Points:**

- Orientation can be "horizontal" or "vertical"
- Weight distribution enables flexible sizing
- Gravity controls alignment within available space
- Performance degrades with nested LinearLayouts

**Example:**

```xml
<LinearLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp">
    
    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="Header" />
    
    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:text="Action Button" />
</LinearLayout>
```

### RelativeLayout

RelativeLayout positions child views relative to each other or to the parent container. Each child view specifies its position using relationship attributes like `android:layout_below` or `android:layout_toRightOf`.

This layout provides flexibility for complex arrangements but can become difficult to maintain as relationships become intricate. It's particularly useful when you need precise control over positioning without nesting multiple LinearLayouts.

**Key Points:**

- Positions are defined through relationships, not absolute coordinates
- Can create complex layouts with a flat hierarchy
- Supports alignment relative to parent edges or other views
- May require multiple layout passes to resolve all relationships

**Example:**

```xml
<RelativeLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp">
    
    <TextView
        android:id="@+id/title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerHorizontal="true"
        android:text="Title" />
    
    <Button
        android:id="@+id/leftButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_below="@id/title"
        android:layout_alignParentStart="true"
        android:layout_marginTop="16dp"
        android:text="Left" />
    
    <Button
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_below="@id/title"
        android:layout_alignParentEnd="true"
        android:layout_marginTop="16dp"
        android:text="Right" />
</RelativeLayout>
```

### ConstraintLayout

ConstraintLayout represents the modern approach to Android layouts, combining the flexibility of RelativeLayout with improved performance and design-time tools. Each view is positioned using constraints that define relationships to other views, parent edges, or guidelines.

The layout uses a constraint-based system where each view must have at least one horizontal and one vertical constraint to determine its position. This approach enables complex layouts with a flat hierarchy while providing excellent performance characteristics.

**Key Points:**

- Requires at least one horizontal and one vertical constraint per view
- Supports chains, barriers, and guidelines for advanced layouts
- Optimized for performance with single layout pass [Inference]
- Integrated with Android Studio's Layout Editor for visual design

**Example:**

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="16dp">
    
    <TextView
        android:id="@+id/title"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="Constraint Layout Example"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />
    
    <Button
        android:id="@+id/button1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Button 1"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/title"
        android:layout_marginTop="16dp" />
    
    <Button
        android:id="@+id/button2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Button 2"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="@id/button1" />
    
</androidx.constraintlayout.widget.ConstraintLayout>
```

