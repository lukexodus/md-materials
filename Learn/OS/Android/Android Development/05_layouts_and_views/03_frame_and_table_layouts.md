## Frame and Table Layouts


### FrameLayout

FrameLayout is designed to hold a single child view, though it can contain multiple children that will be stacked on top of each other. The most recently added child appears on top, and positioning is limited to gravity-based alignment.

This layout is commonly used as a container for fragments, as a placeholder for dynamic content, or when you need to overlay views. It's also frequently used with the `<merge>` tag to eliminate unnecessary view hierarchy levels.

**Key Points:**

- Primarily designed for single child scenarios
- Multiple children stack in z-order (last added on top)
- Positioning limited to gravity settings
- Minimal layout overhead makes it very performant

**Example:**

```xml
<FrameLayout
    android:layout_width="200dp"
    android:layout_height="200dp"
    android:background="#CCCCCC">
    
    <ImageView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:src="@drawable/background_image"
        android:scaleType="centerCrop" />
    
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal"
        android:background="#80000000"
        android:text="Overlay Text"
        android:textColor="#FFFFFF"
        android:padding="8dp" />
</FrameLayout>
```

### TableLayout

TableLayout arranges children in rows and columns, similar to HTML tables. Each TableRow represents a row, and views within each TableRow become columns. The layout automatically sizes columns based on their content and provides options for stretching, shrinking, or collapsing columns.

While TableLayout can create structured, grid-like layouts, it has largely been superseded by more flexible options like GridLayout or ConstraintLayout for most use cases.

**Key Points:**

- Organizes content in rows and columns
- Automatic column sizing based on content
- Support for column stretching, shrinking, and collapsing
- Less flexible than modern alternatives like GridLayout

**Example:**

```xml
<TableLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:stretchColumns="1">
    
    <TableRow>
        <TextView
            android:text="Name:"
            android:padding="8dp" />
        <EditText
            android:hint="Enter name"
            android:padding="8dp" />
    </TableRow>
    
    <TableRow>
        <TextView
            android:text="Email:"
            android:padding="8dp" />
        <EditText
            android:hint="Enter email"
            android:inputType="textEmailAddress"
            android:padding="8dp" />
    </TableRow>
    
    <TableRow>
        <View /> <!-- Empty cell -->
        <Button
            android:text="Submit"
            android:padding="8dp" />
    </TableRow>
    
</TableLayout>
```

