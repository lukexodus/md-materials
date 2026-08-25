## Unit Testing with JUnit


JUnit serves as the foundation for Android unit testing, providing the structure for testing individual components in isolation. Android Studio integrates JUnit 4 and JUnit 5 support with specialized testing configurations for Android-specific components.

**Basic Test Structure**

JUnit tests follow a consistent pattern using annotations to define test lifecycle and behavior. The `@Test` annotation marks test methods, while `@Before` and `@After` handle setup and cleanup operations.

```kotlin
class CalculatorTest {
    private lateinit var calculator: Calculator
    
    @Before
    fun setUp() {
        calculator = Calculator()
    }
    
    @Test
    fun `addition should return correct sum`() {
        val result = calculator.add(2, 3)
        assertEquals(5, result)
    }
    
    @Test
    fun `division by zero should throw exception`() {
        assertThrows<ArithmeticException> {
            calculator.divide(10, 0)
        }
    }
    
    @After
    fun tearDown() {
        // Cleanup if needed
    }
}
```

**Testing Android Components**

Android components require specialized testing approaches due to their dependency on the Android framework. Robolectric enables unit testing of Android components without requiring device emulation, significantly improving test execution speed.

```kotlin
@RunWith(RobolectricTestRunner::class)
class UserManagerTest {
    
    @Test
    fun `saveUser should store user preferences`() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val userManager = UserManager(context)
        
        userManager.saveUser("john_doe", "john@example.com")
        
        assertEquals("john_doe", userManager.getUsername())
        assertEquals("john@example.com", userManager.getEmail())
    }
}
```

**Parameterized Testing**

JUnit supports parameterized tests for testing multiple input combinations efficiently. This approach reduces code duplication while ensuring comprehensive coverage of edge cases and boundary conditions.

```kotlin
@RunWith(Parameterized::class)
class ValidationTest(
    private val input: String,
    private val expected: Boolean
) {
    companion object {
        @JvmStatic
        @Parameterized.Parameters
        fun data() = listOf(
            arrayOf("valid@email.com", true),
            arrayOf("invalid-email", false),
            arrayOf("", false),
            arrayOf("test@", false)
        )
    }
    
    @Test
    fun `email validation should return expected result`() {
        val validator = EmailValidator()
        assertEquals(expected, validator.isValid(input))
    }
}
```

**Testing Coroutines**

Kotlin coroutines require special testing considerations to handle asynchronous operations predictably. The `kotlinx-coroutines-test` library provides testing utilities for controlling coroutine execution and time manipulation.

```kotlin
@ExperimentalCoroutinesApi
class DataRepositoryTest {
    private val testDispatcher = UnconfinedTestDispatcher()
    private lateinit var repository: DataRepository
    
    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        repository = DataRepository()
    }
    
    @Test
    fun `fetchData should return success when api call succeeds`() = runTest {
        val result = repository.fetchData()
        assertTrue(result is Result.Success)
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }
}
```

**Key Points:**

- Use Robolectric for testing Android components without emulators
- Implement parameterized tests for comprehensive input validation
- Handle coroutine testing with appropriate test dispatchers
- Organize tests with clear setup and teardown procedures
- Follow naming conventions that describe test scenarios clearly

