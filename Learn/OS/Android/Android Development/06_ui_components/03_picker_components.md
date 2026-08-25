## Picker Components


Picker components provide specialized interfaces for selecting dates, times, and other structured data with user-friendly controls.

### DatePicker

DatePicker enables date selection through various interface modes, supporting different calendar systems and date ranges.

**Key points:**

- Supports calendar and spinner modes
- Provides date range restrictions (min/max dates)
- Can be embedded in layouts or displayed in dialogs
- Supports different calendar systems and localization

```kotlin
// XML implementation
<DatePicker
    android:id="@+id/datePicker"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:datePickerMode="calendar"
    android:calendarViewShown="true"
    android:spinnersShown="false" />

// Programmatic usage
val datePicker = findViewById<DatePicker>(R.id.datePicker)

// Set date restrictions
val calendar = Calendar.getInstance()
datePicker.maxDate = calendar.timeInMillis // Today as max date

calendar.add(Calendar.YEAR, -100)
datePicker.minDate = calendar.timeInMillis // 100 years ago as min date

// Get selected date
val selectedYear = datePicker.year
val selectedMonth = datePicker.month
val selectedDay = datePicker.dayOfMonth

// Date picker dialog
val datePickerDialog = DatePickerDialog(
    this,
    { _, year, month, dayOfMonth ->
        // Handle date selection
        val selectedDate = "$dayOfMonth/${month + 1}/$year"
    },
    2023, // Initial year
    0,    // Initial month (0-based)
    1     // Initial day
)
datePickerDialog.show()
```

### TimePicker

TimePicker provides time selection functionality with both 12-hour and 24-hour format support.

**Key points:**

- Supports both clock and spinner interfaces
- Can display 12-hour or 24-hour formats
- Provides minute interval customization [Inference]
- Integrates with dialog presentations

```kotlin
// XML implementation
<TimePicker
    android:id="@+id/timePicker"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:timePickerMode="clock"
    android:is24HourView="false" />

// Programmatic usage
val timePicker = findViewById<TimePicker>(R.id.timePicker)

// Set 24-hour format
timePicker.setIs24HourView(true)

// Get selected time
val selectedHour = timePicker.hour
val selectedMinute = timePicker.minute

// Time picker dialog
val timePickerDialog = TimePickerDialog(
    this,
    { _, hourOfDay, minute ->
        // Handle time selection
        val selectedTime = String.format("%02d:%02d", hourOfDay, minute)
    },
    12, // Initial hour
    0   // Initial minute
)
timePickerDialog.show()

// Set time programmatically
timePicker.hour = 14
timePicker.minute = 30
```

