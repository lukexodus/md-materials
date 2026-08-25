## Input Controls


Input controls provide users with various selection and input mechanisms beyond basic text entry.

### CheckBox

CheckBox allows users to select multiple options from a set of choices, maintaining independent state for each option.

**Key points:**

- Supports tri-state behavior (checked, unchecked, indeterminate)
- Can be grouped logically without mutual exclusion
- Provides compound drawable positioning
- Supports custom styling and animations

```kotlin
// XML implementation
<CheckBox
    android:id="@+id/checkBox"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Enable notifications"
    android:checked="true" />

// Handling state changes
val checkBox = findViewById<CheckBox>(R.id.checkBox)
checkBox.setOnCheckedChangeListener { _, isChecked ->
    if (isChecked) {
        // Enable notifications
    } else {
        // Disable notifications
    }
}

// Multiple checkboxes example
val preferences = mutableSetOf<String>()
val checkBoxes = listOf(
    findViewById<CheckBox>(R.id.emailNotifications),
    findViewById<CheckBox>(R.id.pushNotifications),
    findViewById<CheckBox>(R.id.smsNotifications)
)

checkBoxes.forEachIndexed { index, checkBox ->
    checkBox.setOnCheckedChangeListener { _, isChecked ->
        val preference = when (index) {
            0 -> "email"
            1 -> "push"
            2 -> "sms"
            else -> ""
        }
        if (isChecked) {
            preferences.add(preference)
        } else {
            preferences.remove(preference)
        }
    }
}
```

### RadioButton

RadioButton provides mutually exclusive selection within a RadioGroup, ensuring only one option can be selected at a time.

**Key points:**

- Must be contained within RadioGroup for proper behavior
- Automatically handles mutual exclusion within groups
- Supports custom styling and compound drawables
- Can be programmatically selected and monitored

```kotlin
// XML implementation
<RadioGroup
    android:id="@+id/radioGroup"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:orientation="vertical">
    
    <RadioButton
        android:id="@+id/radioOption1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Option 1" />
    
    <RadioButton
        android:id="@+id/radioOption2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Option 2" />
        
</RadioGroup>

// Handling selection changes
val radioGroup = findViewById<RadioGroup>(R.id.radioGroup)
radioGroup.setOnCheckedChangeListener { group, checkedId ->
    when (checkedId) {
        R.id.radioOption1 -> {
            // Handle option 1 selection
        }
        R.id.radioOption2 -> {
            // Handle option 2 selection
        }
    }
}

// Programmatic selection
radioGroup.check(R.id.radioOption1)
```

### Spinner

Spinner provides a dropdown selection interface, displaying a list of options when activated by user interaction.

**Key points:**

- Supports both array and database-backed data sources
- Provides customizable item layouts
- Can display prompt text for user guidance
- Supports selection event handling and validation

```kotlin
// XML implementation
<Spinner
    android:id="@+id/spinner"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:prompt="@string/choose_option" />

// Array-based spinner
val spinner = findViewById<Spinner>(R.id.spinner)
val options = arrayOf("Option 1", "Option 2", "Option 3", "Option 4")
val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, options)
adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
spinner.adapter = adapter

// Selection handling
spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
    override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        val selectedItem = options[position]
        // Handle selection
    }
    
    override fun onNothingSelected(parent: AdapterView<*>) {
        // Handle no selection
    }
}

// Custom adapter example
class CustomSpinnerAdapter(
    context: Context,
    private val items: List<String>
) : BaseAdapter() {
    
    override fun getCount(): Int = items.size
    override fun getItem(position: Int): Any = items[position]
    override fun getItemId(position: Int): Long = position.toLong()
    
    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        val view = convertView ?: LayoutInflater.from(parent?.context)
            .inflate(android.R.layout.simple_spinner_item, parent, false)
        
        view.findViewById<TextView>(android.R.id.text1).text = items[position]
        return view
    }
}
```

