## UI Testing with Espresso


Espresso provides a comprehensive framework for Android UI testing with synchronization capabilities that handle asynchronous operations automatically. It enables reliable testing of user interactions and UI state verification.

**Basic Espresso Operations**

Espresso tests follow a view-action-assertion pattern using three main components: ViewMatchers for finding UI elements, ViewActions for performing interactions, and ViewAssertions for verifying results.

```kotlin
@RunWith(AndroidJUnit4::class)
class LoginActivityTest {
    
    @get:Rule
    val activityRule = ActivityScenarioRule(LoginActivity::class.java)
    
    @Test
    fun loginWithValidCredentials() {
        onView(withId(R.id.username_edit_text))
            .perform(typeText("testuser"), closeSoftKeyboard())
        
        onView(withId(R.id.password_edit_text))
            .perform(typeText("password123"), closeSoftKeyboard())
        
        onView(withId(R.id.login_button))
            .perform(click())
        
        onView(withId(R.id.welcome_message))
            .check(matches(isDisplayed()))
            .check(matches(withText("Welcome, testuser!")))
    }
}
```

**Custom Matchers**

Complex UI testing scenarios often require custom matchers for specific view properties or behaviors. Custom matchers enhance test readability and enable reusable testing logic.

```kotlin
fun withItemCount(count: Int): Matcher<View> {
    return object : BoundedMatcher<View, RecyclerView>(RecyclerView::class.java) {
        override fun describeTo(description: Description) {
            description.appendText("RecyclerView with item count: $count")
        }
        
        override fun matchesSafely(recyclerView: RecyclerView): Boolean {
            return recyclerView.adapter?.itemCount == count
        }
    }
}

@Test
fun recyclerViewDisplaysCorrectItemCount() {
    onView(withId(R.id.recycler_view))
        .check(matches(withItemCount(5)))
}
```

**Testing RecyclerViews**

RecyclerView testing requires specialized approaches for scrolling, item selection, and content verification. Espresso provides `RecyclerViewActions` for interacting with list items efficiently.

```kotlin
@Test
fun selectRecyclerViewItem() {
    onView(withId(R.id.recycler_view))
        .perform(
            RecyclerViewActions.actionOnItemAtPosition<RecyclerView.ViewHolder>(
                2, click()
            )
        )
    
    onView(withId(R.id.detail_text))
        .check(matches(withText(containsString("Item 3"))))
}

@Test
fun scrollToItemAndVerifyContent() {
    onView(withId(R.id.recycler_view))
        .perform(
            RecyclerViewActions.scrollToPosition<RecyclerView.ViewHolder>(10)
        )
    
    onView(withText("Item 11"))
        .check(matches(isDisplayed()))
}
```

**Idling Resources**

Asynchronous operations require proper synchronization to ensure test reliability. Idling resources provide Espresso with information about application state, preventing test flakiness due to timing issues.

```kotlin
class NetworkIdlingResource(private val networkManager: NetworkManager) : IdlingResource {
    private var callback: IdlingResource.ResourceCallback? = null
    
    override fun getName(): String = "NetworkIdlingResource"
    
    override fun isIdleNow(): Boolean {
        val idle = !networkManager.isLoading()
        if (idle) callback?.onTransitionToIdle()
        return idle
    }
    
    override fun registerIdleTransitionCallback(callback: IdlingResource.ResourceCallback?) {
        this.callback = callback
    }
}

@Test
fun testWithNetworkOperation() {
    val idlingResource = NetworkIdlingResource(networkManager)
    IdlingRegistry.getInstance().register(idlingResource)
    
    try {
        onView(withId(R.id.refresh_button)).perform(click())
        onView(withId(R.id.data_list)).check(matches(isDisplayed()))
    } finally {
        IdlingRegistry.getInstance().unregister(idlingResource)
    }
}
```

**Testing Navigation**

Navigation testing involves verifying correct screen transitions and back stack management. Espresso integrates with Navigation Component testing utilities for comprehensive navigation verification.

```kotlin
@Test
fun navigationToDetailScreen() {
    val navController = TestNavHostController(ApplicationProvider.getApplicationContext())
    
    launchFragmentInContainer<MainFragment> {
        navController.setGraph(R.navigation.nav_graph)
        Navigation.setViewNavController(requireView(), navController)
        MainFragment()
    }
    
    onView(withId(R.id.item_card)).perform(click())
    
    assertEquals(R.id.detailFragment, navController.currentDestination?.id)
}
```

**Key Points:**

- Use ActivityScenarioRule for proper activity lifecycle management
- Implement custom matchers for complex UI verification scenarios
- Handle asynchronous operations with idling resources
- Test RecyclerViews with specialized actions and matchers
- Verify navigation flows and back stack behavior

