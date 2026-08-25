## Task and Back Stack Management


Android manages activities in tasks, which are collections of activities arranged in a stack (the back stack) in the order they were opened.

### Task Fundamentals

A task is a collection of activities that users interact with when performing a certain job. Activities are arranged in a stack in the order in which each activity is opened.

### Back Stack Behavior

When the user presses the Back button, the current activity is destroyed and the previous activity resumes. When all activities are removed from the stack, the task no longer exists.

### Managing the Back Stack

```kotlin
class TaskManagementActivity : AppCompatActivity() {
    
    private fun navigateToNextActivity() {
        val intent = Intent(this, NextActivity::class.java)
        // Standard navigation - adds to back stack
        startActivity(intent)
    }
    
    private fun navigateAndClearStack() {
        val intent = Intent(this, HomeActivity::class.java)
        // Clear all activities from back stack
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }
    
    private fun navigateWithoutHistory() {
        val intent = Intent(this, TemporaryActivity::class.java)
        // Don't add to back stack
        intent.flags = Intent.FLAG_ACTIVITY_NO_HISTORY
        startActivity(intent)
    }
    
    override fun onBackPressed() {
        // Custom back button behavior
        if (shouldPreventBack()) {
            showConfirmationDialog()
        } else {
            super.onBackPressed()
        }
    }
    
    private fun shouldPreventBack(): Boolean {
        // [Inference] Custom logic to determine if back should be prevented
        return hasUnsavedChanges()
    }
}
```

