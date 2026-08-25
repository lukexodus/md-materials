## Fragment Transactions and Management


Fragment transactions provide a way to add, remove, replace, and manipulate fragments within your app. They are atomic operations that can be committed, rolled back, and added to the back stack for navigation.

### FragmentManager and FragmentTransaction

FragmentManager handles the fragment back stack and executes fragment transactions. Each activity has a FragmentManager accessible through `supportFragmentManager`, and each fragment can access its child FragmentManager through `childFragmentManager`.

FragmentTransaction represents a set of changes to be applied to fragments. Transactions are created by FragmentManager and must be committed to take effect.

**Example** of basic fragment transactions:

```kotlin
class MainActivity : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // Add initial fragment if not restored from saved state
        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .add(R.id.fragment_container, HomeFragment(), "HOME_FRAGMENT")
                .commit()
        }
    }
    
    private fun navigateToProfile(userId: String) {
        val fragment = UserProfileFragment().apply {
            arguments = Bundle().apply {
                putString("user_id", userId)
            }
        }
        
        supportFragmentManager.beginTransaction()
            .replace(R.id.fragment_container, fragment, "PROFILE_FRAGMENT")
            .addToBackStack("profile")
            .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE)
            .commit()
    }
    
    private fun showDetailOverlay(itemId: String) {
        val fragment = DetailDialogFragment().apply {
            arguments = Bundle().apply {
                putString("item_id", itemId)
            }
        }
        
        // For dialog fragments or overlays
        supportFragmentManager.beginTransaction()
            .add(fragment, "DETAIL_DIALOG")
            .commit()
    }
    
    private fun clearBackStackToHome() {
        supportFragmentManager.popBackStack("HOME", FragmentManager.POP_BACK_STACK_INCLUSIVE)
    }
}
```

### Transaction Operations

Different transaction operations serve specific purposes in fragment management:

- `add()` - Adds a fragment to a container without removing existing fragments
- `replace()` - Removes all fragments from a container and adds a new one
- `remove()` - Removes a fragment from its container
- `hide()` and `show()` - Control visibility without destroying fragments
- `attach()` and `detach()` - Manage fragment lifecycle without removing from back stack

**Example** of advanced transaction management:

```kotlin
class FragmentNavigationManager(private val fragmentManager: FragmentManager) {
    
    private val fragmentStack = mutableListOf<String>()
    
    fun navigateToFragment(fragment: Fragment, tag: String, addToBackStack: Boolean = true) {
        val transaction = fragmentManager.beginTransaction()
        
        // Hide current fragment instead of replacing for better performance
        fragmentManager.fragments.lastOrNull()?.let { currentFragment ->
            transaction.hide(currentFragment)
        }
        
        val existingFragment = fragmentManager.findFragmentByTag(tag)
        if (existingFragment != null) {
            transaction.show(existingFragment)
        } else {
            transaction.add(R.id.fragment_container, fragment, tag)
        }
        
        if (addToBackStack) {
            transaction.addToBackStack(tag)
            fragmentStack.add(tag)
        }
        
        transaction.commit()
    }
    
    fun popFragment(): Boolean {
        return if (fragmentStack.isNotEmpty()) {
            fragmentManager.popBackStack()
            fragmentStack.removeLastOrNull()
            true
        } else {
            false
        }
    }
    
    fun clearAllFragments() {
        fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE)
        fragmentStack.clear()
    }
}
```

### Commit Methods and Timing

Fragment transactions offer different commit methods with varying execution characteristics:

- `commit()` - Schedules transaction for execution on main thread
- `commitNow()` - Executes transaction immediately (cannot be used with back stack)
- `commitAllowingStateLoss()` - Commits even after activity state loss (use carefully)

**Key Points:**

- Always commit transactions on the main thread
- Avoid committing after `onSaveInstanceState()` to prevent state loss
- Use `commitNow()` only when immediate execution is required and back stack isn't needed
- [Unverified] Transactions committed with `commitAllowingStateLoss()` may result in inconsistent UI state

