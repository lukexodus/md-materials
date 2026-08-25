## Shared Preferences


Shared Preferences provide a simple key-value storage mechanism for primitive data types, configuration settings, and user preferences that persist across application sessions.

**Key points:**

- Stores primitive data types (boolean, int, long, float, String, Set\<String>)
- Thread-safe for reads but requires careful handling for writes
- Automatically handles XML file creation and management
- Provides both synchronous (commit) and asynchronous (apply) write operations

### Basic Implementation

```kotlin
class PreferencesManager(private val context: Context) {
    private val sharedPreferences = context.getSharedPreferences(
        "app_preferences", 
        Context.MODE_PRIVATE
    )
    
    fun saveString(key: String, value: String) {
        sharedPreferences.edit()
            .putString(key, value)
            .apply() // Asynchronous write
    }
    
    fun getString(key: String, defaultValue: String = ""): String {
        return sharedPreferences.getString(key, defaultValue) ?: defaultValue
    }
    
    fun saveBoolean(key: String, value: Boolean) {
        sharedPreferences.edit()
            .putBoolean(key, value)
            .commit() // Synchronous write - blocks until completion
    }
    
    fun getBoolean(key: String, defaultValue: Boolean = false): Boolean {
        return sharedPreferences.getBoolean(key, defaultValue)
    }
    
    fun saveInt(key: String, value: Int) {
        sharedPreferences.edit()
            .putInt(key, value)
            .apply()
    }
    
    fun getInt(key: String, defaultValue: Int = 0): Int {
        return sharedPreferences.getInt(key, defaultValue)
    }
}
```

### Advanced Usage Patterns

```kotlin
class UserPreferences(context: Context) {
    private val prefs = context.getSharedPreferences("user_prefs", Context.MODE_PRIVATE)
    
    // Using property delegates for cleaner code
    var username: String
        get() = prefs.getString("username", "") ?: ""
        set(value) = prefs.edit().putString("username", value).apply()
    
    var isFirstLaunch: Boolean
        get() = prefs.getBoolean("first_launch", true)
        set(value) = prefs.edit().putBoolean("first_launch", value).apply()
    
    var themeMode: Int
        get() = prefs.getInt("theme_mode", AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM)
        set(value) = prefs.edit().putInt("theme_mode", value).apply()
    
    // Batch operations for better performance
    fun updateUserSettings(username: String, notifications: Boolean, theme: Int) {
        prefs.edit().apply {
            putString("username", username)
            putBoolean("notifications_enabled", notifications)
            putInt("theme_mode", theme)
            apply()
        }
    }
    
    // Listen for preference changes
    fun registerOnChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener) {
        prefs.registerOnSharedPreferenceChangeListener(listener)
    }
    
    fun unregisterOnChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener) {
        prefs.unregisterOnSharedPreferenceChangeListener(listener)
    }
}
```

### Complex Data Storage

```kotlin
// Storing complex objects using JSON serialization
class AppSettings(context: Context) {
    private val prefs = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
    private val gson = Gson()
    
    data class NotificationSettings(
        val emailEnabled: Boolean,
        val pushEnabled: Boolean,
        val soundEnabled: Boolean,
        val vibrationEnabled: Boolean
    )
    
    fun saveNotificationSettings(settings: NotificationSettings) {
        val json = gson.toJson(settings)
        prefs.edit().putString("notification_settings", json).apply()
    }
    
    fun getNotificationSettings(): NotificationSettings {
        val json = prefs.getString("notification_settings", null)
        return if (json != null) {
            gson.fromJson(json, NotificationSettings::class.java)
        } else {
            NotificationSettings(true, true, true, false) // Default settings
        }
    }
    
    // Storing string sets
    fun saveRecentSearches(searches: Set<String>) {
        prefs.edit().putStringSet("recent_searches", searches).apply()
    }
    
    fun getRecentSearches(): Set<String> {
        return prefs.getStringSet("recent_searches", emptySet()) ?: emptySet()
    }
}
```

