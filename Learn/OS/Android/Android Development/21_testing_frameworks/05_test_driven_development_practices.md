## Test-Driven Development Practices


Test-driven development (TDD) in Android involves writing tests before implementation, ensuring comprehensive coverage and driving better design decisions. This approach leads to more maintainable and reliable code.

**Red-Green-Refactor Cycle**

The TDD cycle consists of three phases: writing a failing test (Red), implementing minimal code to pass (Green), and improving the design (Refactor). This cycle ensures tests drive development decisions.

```kotlin
// Red Phase: Write failing test
@Test
fun `validateEmail should return false for invalid email format`() {
    val validator = EmailValidator()
    assertFalse(validator.validate("invalid-email"))
}

// Green Phase: Minimal implementation
class EmailValidator {
    fun validate(email: String): Boolean {
        return email.contains("@") && email.contains(".")
    }
}

// Refactor Phase: Improve implementation
class EmailValidator {
    private val emailPattern = Pattern.compile(
        "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    )
    
    fun validate(email: String): Boolean {
        return emailPattern.matcher(email).matches()
    }
}
```

**Testing Android Components with TDD**

TDD for Android components requires careful consideration of the Android lifecycle and framework dependencies. Start with business logic before adding Android-specific functionality.

```kotlin
// Test first: Define expected behavior
class UserProfileViewModelTest {
    
    @Test
    fun `loading user profile should show loading state`() {
        val viewModel = UserProfileViewModel(mockRepository)
        
        viewModel.loadUserProfile(1)
        
        assertTrue(viewModel.isLoading.value)
    }
    
    @Test
    fun `successful profile load should update user data`() = runTest {
        val expectedUser = User(1, "John", "john@test.com")
        coEvery { mockRepository.getUser(1) } returns expectedUser
        
        val viewModel = UserProfileViewModel(mockRepository)
        viewModel.loadUserProfile(1)
        
        assertEquals(expectedUser, viewModel.user.value)
        assertFalse(viewModel.isLoading.value)
    }
}

// Implementation driven by tests
class UserProfileViewModel(
    private val userRepository: UserRepository
) : ViewModel() {
    private val _user = MutableLiveData<User?>()
    val user: LiveData<User?> = _user
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    fun loadUserProfile(userId: Long) {
        _isLoading.value = true
        viewModelScope.launch {
            try {
                val user = userRepository.getUser(userId)
                _user.value = user
            } catch (e: Exception) {
                // Handle error
            } finally {
                _isLoading.value = false
            }
        }
    }
}
```

**Repository Pattern with TDD**

TDD helps design repository interfaces by first defining expected behavior through tests. This approach ensures repositories provide necessary functionality while maintaining clean abstractions.

```kotlin
// Define repository contract through tests
class UserRepositoryTest {
    
    @Test
    fun `getUserById should return cached user when available`() = runTest {
        val repository = UserRepositoryImpl(mockDao, mockApi)
        val cachedUser = User(1, "John", "john@test.com")
        
        coEvery { mockDao.getUserById(1) } returns cachedUser
        
        val result = repository.getUserById(1)
        
        assertEquals(cachedUser, result)
        coVerify(exactly = 0) { mockApi.getUser(any()) }
    }
    
    @Test
    fun `getUserById should fetch from API when not cached`() = runTest {
        val repository = UserRepositoryImpl(mockDao, mockApi)
        val apiUser = User(1, "John", "john@test.com")
        
        coEvery { mockDao.getUserById(1) } returns null
        coEvery { mockApi.getUser(1) } returns apiUser
        
        val result = repository.getUserById(1)
        
        assertEquals(apiUser, result)
        coVerify { mockDao.insert(apiUser) }
    }
}
```

**UI Testing with TDD**

TDD for UI components starts with defining user interactions and expected outcomes. This approach ensures UI components behave correctly under various conditions.

```kotlin
// Test-driven UI development
class LoginActivityTest {
    
    @get:Rule
    val activityRule = ActivityScenarioRule(LoginActivity::class.java)
    
    @Test
    fun `login button should be disabled with empty credentials`() {
        onView(withId(R.id.login_button))
            .check(matches(not(isEnabled())))
    }
    
    @Test
    fun `login button should be enabled with valid credentials`() {
        onView(withId(R.id.username_input))
            .perform(typeText("user@test.com"))
        
        onView(withId(R.id.password_input))
            .perform(typeText("password123"))
        
        onView(withId(R.id.login_button))
            .check(matches(isEnabled()))
    }
    
    @Test
    fun `error message should display for invalid credentials`() {
        onView(withId(R.id.username_input))
            .perform(typeText("invalid@test.com"))
        
        onView(withId(R.id.password_input))
            .perform(typeText("wrongpassword"))
        
        onView(withId(R.id.login_button))
            .perform(click())
        
        onView(withId(R.id.error_message))
            .check(matches(isDisplayed()))
            .check(matches(withText("Invalid credentials")))
    }
}
```

**Test Organization Strategies**

Effective test organization improves maintainability and execution efficiency. Group related tests logically and use appropriate test runners for different testing scenarios.

```kotlin
// Organized test structure
class UserServiceTestSuite {
    
    @Nested
    @DisplayName("User Creation Tests")
    inner class UserCreationTests {
        
        @Test
        fun `createUser with valid data should succeed`() {
            // Test implementation
        }
        
        @Test
        fun `createUser with duplicate email should fail`() {
            // Test implementation
        }
    }
    
    @Nested
    @DisplayName("User Validation Tests")
    inner class UserValidationTests {
        
        @Test
        fun `validateUser with complete profile should pass`() {
            // Test implementation
        }
        
        @Test
        fun `validateUser with missing required fields should fail`() {
            // Test implementation
        }
    }
}

// Test data builders for complex objects
class UserTestDataBuilder {
    private var id: Long = 1
    private var name: String = "Test User"
    private var email: String = "test@example.com"
    private var type: UserType = UserType.BASIC
    
    fun withId(id: Long) = apply { this.id = id }
    fun withName(name: String) = apply { this.name = name }
    fun withEmail(email: String) = apply { this.email = email }
    fun withType(type: UserType) = apply { this.type = type }
    
    fun build() = User(id, name, email, type)
}
```

**Continuous Integration Integration**

TDD practices should integrate seamlessly with continuous integration pipelines, ensuring tests run automatically and provide rapid feedback on code changes.

```kotlin
// Example test configuration for CI
class ContinuousIntegrationTest {
    
    @Test
    @Category(FastTest::class)
    fun `fast unit test for CI pipeline`() {
        // Quick test that runs in CI
    }
    
    @Test
    @Category(SlowTest::class)
    fun `comprehensive integration test`() {
        // Slower test for nightly builds
    }
}

// Custom test categories
interface FastTest
interface SlowTest
interface UITest
```

**Key Points:**

- Follow the Red-Green-Refactor cycle consistently
- Write tests that define component contracts and behavior
- Use test data builders for complex object creation
- Organize tests logically with nested classes and descriptive names
- Integrate TDD practices with continuous integration workflows

**Example** of comprehensive TDD implementation:

```kotlin
// Complete TDD example: Shopping Cart Feature
class ShoppingCartTest {
    private lateinit var cart: ShoppingCart
    private lateinit var priceCalculator: PriceCalculator
    
    @Before
    fun setUp() {
        priceCalculator = mockk()
        cart = ShoppingCart(priceCalculator)
    }
    
    @Test
    fun `empty cart should have zero total`() {
        assertEquals(0.0, cart.getTotal(), 0.01)
    }
    
    @Test
    fun `adding item should increase cart size`() {
        val item = CartItem("Product 1", 10.0, 1)
        
        cart.addItem(item)
        
        assertEquals(1, cart.getItemCount())
        assertTrue(cart.getItems().contains(item))
    }
    
    @Test
    fun `removing item should decrease cart size`() {
        val item = CartItem("Product 1", 10.0, 1)
        cart.addItem(item)
        
        cart.removeItem(item.id)
        
        assertEquals(0, cart.getItemCount())
        assertFalse(cart.getItems().contains(item))
    }
    
    @Test
    fun `cart total should be calculated correctly`() {
        val item1 = CartItem("Product 1", 10.0, 2)
        val item2 = CartItem("Product 2", 15.0, 1)
        
        every { priceCalculator.calculateTotal(any()) } returns 35.0
        
        cart.addItem(item1)
        cart.addItem(item2)
        
        assertEquals(35.0, cart.getTotal(), 0.01)
        verify { priceCalculator.calculateTotal(match { it.size == 2 }) }
    }
}
```

**Output** considerations for Android testing:

Testing strategies must account for device fragmentation, different Android versions, and varying hardware capabilities. Test execution should be optimized for continuous integration environments while maintaining comprehensive coverage of critical application functionality.

Performance testing becomes crucial for multimedia applications, network-dependent features, and data-intensive operations. Memory leak detection and resource cleanup verification ensure application stability across extended usage periods.

Security testing validates input sanitization, data encryption, and access control mechanisms. Privacy testing ensures compliance with data protection regulations and user consent management throughout the application lifecycle.

---

