## Data Binding Library


The Android Data Binding Library eliminates the need for findViewById() calls by generating binding classes at compile time. It creates a direct connection between layout files and application code, enabling two-way data binding and expression evaluation within XML layouts.

**Key Points:**

- Generates binding classes automatically based on layout file names
- Supports two-way data binding with observable fields
- Enables null safety and type safety at compile time
- Reduces boilerplate code significantly
- Supports binding expressions directly in XML layouts

**Implementation Setup:**

```kotlin
// In module-level build.gradle
android {
    dataBinding {
        enabled = true
    }
}

// Or with newer syntax
android {
    buildFeatures {
        dataBinding = true
    }
}
```

**Basic Usage Example:**

```kotlin
// Layout file: activity_main.xml
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <data>
        <variable
            name="user"
            type="com.example.User" />
    </data>
    
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent">
        
        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@{user.firstName}" />
            
    </LinearLayout>
</layout>

// Activity
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val binding: ActivityMainBinding = 
            DataBindingUtil.setContentView(this, R.layout.activity_main)
        
        val user = User("John", "Doe")
        binding.user = user
    }
}
```

**Two-Way Data Binding:**

```kotlin
// Observable field in data class
class User : BaseObservable() {
    @get:Bindable
    var firstName: String = ""
        set(value) {
            field = value
            notifyPropertyChanged(BR.firstName)
        }
}

// XML with two-way binding
<EditText
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="@={user.firstName}" />
```

**Binding Expressions and Custom Attributes:**

```kotlin
// XML expressions
<TextView
    android:text="@{String.valueOf(user.age)}"
    android:visibility="@{user.isAdult ? View.VISIBLE : View.GONE}" />

// Custom binding adapter
@BindingAdapter("imageUrl")
fun loadImage(view: ImageView, url: String?) {
    Glide.with(view.context)
        .load(url)
        .into(view)
}

// Usage in XML
<ImageView
    android:layout_width="100dp"
    android:layout_height="100dp"
    app:imageUrl="@{user.profilePicture}" />
```

