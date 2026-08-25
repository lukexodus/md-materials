## Basic Widgets


Basic widgets serve as the foundation of Android user interfaces, handling text display, user input, images, and basic interactions.

### TextView

TextView displays text content to users and supports various formatting options, styling, and interactive features like clickable links.

**Key points:**

- Supports HTML formatting and styled text
- Can handle clickable spans and links
- Offers extensive styling through XML attributes or programmatically
- Supports text selection and copy functionality

```kotlin
// XML implementation
<TextView
    android:id="@+id/textView"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Hello, Android!"
    android:textSize="18sp"
    android:textColor="#FF6200EE"
    android:textStyle="bold" />

// Programmatic implementation
val textView = findViewById<TextView>(R.id.textView)
textView.text = "Dynamic text content"
textView.setTextColor(ContextCompat.getColor(this, R.color.primary))
textView.textSize = 20f
```

### Button

Button components handle user tap interactions and can be styled extensively to match application design requirements.

**Key points:**

- Supports various button styles (Material Design, flat, raised)
- Can contain text, icons, or both
- Provides visual feedback through state changes
- Supports custom backgrounds and shapes

```kotlin
// XML implementation
<Button
    android:id="@+id/button"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Click Me"
    android:backgroundTint="#FF6200EE"
    android:textColor="#FFFFFF" />

// Event handling
val button = findViewById<Button>(R.id.button)
button.setOnClickListener {
    // Handle button click
    Toast.makeText(this, "Button clicked!", Toast.LENGTH_SHORT).show()
}

// Material Design button variations
<com.google.android.material.button.MaterialButton
    android:id="@+id/materialButton"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Material Button"
    app:icon="@drawable/ic_favorite"
    style="@style/Widget.MaterialComponents.Button.OutlinedButton" />
```

### EditText

EditText enables text input from users, supporting various input types, validation, and formatting options.

**Key points:**

- Supports multiple input types (text, number, email, password)
- Provides input validation and filtering
- Can display hints and error messages
- Supports text selection and clipboard operations

```kotlin
// XML implementation
<EditText
    android:id="@+id/editText"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:hint="Enter your name"
    android:inputType="textPersonName"
    android:maxLines="1" />

// Input validation example
val editText = findViewById<EditText>(R.id.editText)
editText.addTextChangedListener(object : TextWatcher {
    override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
    
    override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
        // Real-time validation
        if (s.isNullOrEmpty()) {
            editText.error = "This field is required"
        } else {
            editText.error = null
        }
    }
    
    override fun afterTextChanged(s: Editable?) {}
})
```

### ImageView

ImageView displays images from various sources including resources, files, or network URLs, with scaling and positioning options.

**Key points:**

- Supports multiple image sources (drawable resources, bitmaps, URIs)
- Provides scaling options (fitXY, centerCrop, centerInside)
- Can apply tinting and color filters
- Supports click interactions for image-based buttons

```kotlin
// XML implementation
<ImageView
    android:id="@+id/imageView"
    android:layout_width="200dp"
    android:layout_height="200dp"
    android:src="@drawable/sample_image"
    android:scaleType="centerCrop"
    android:contentDescription="Sample image" />

// Programmatic image loading
val imageView = findViewById<ImageView>(R.id.imageView)
imageView.setImageResource(R.drawable.new_image)

// Loading from URL (using Glide library)
Glide.with(this)
    .load("https://example.com/image.jpg")
    .placeholder(R.drawable.placeholder)
    .error(R.drawable.error_image)
    .into(imageView)
```

