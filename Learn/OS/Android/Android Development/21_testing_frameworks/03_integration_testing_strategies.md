## Integration Testing Strategies


Integration testing validates interactions between multiple components, ensuring system-wide functionality works correctly. Android integration testing spans multiple layers from database interactions to network communications.

**Database Integration Testing**

Room database testing requires careful setup to ensure test isolation while maintaining realistic data scenarios. In-memory databases provide fast, isolated testing environments.

```kotlin
@RunWith(AndroidJUnit4::class)
class UserDatabaseTest {
    private lateinit var database: AppDatabase
    private lateinit var userDao: UserDao
    
    @Before
    fun setUp() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AppDatabase::class.java
        ).allowMainThreadQueries().build()
        
        userDao = database.userDao()
    }
    
    @Test
    fun insertAndRetrieveUser() = runTest {
        val user = User(1, "John Doe", "john@example.com")
        userDao.insert(user)
        
        val retrievedUser = userDao.getUserById(1)
        assertEquals(user.name, retrievedUser?.name)
        assertEquals(user.email, retrievedUser?.email)
    }
    
    @Test
    fun cascadeDeleteWorksCorrectly() = runTest {
        val user = User(1, "John Doe", "john@example.com")
        val profile = UserProfile(1, 1, "Software Engineer")
        
        userDao.insert(user)
        userDao.insertProfile(profile)
        userDao.deleteUser(user)
        
        assertNull(userDao.getProfileByUserId(1))
    }
    
    @After
    fun tearDown() {
        database.close()
    }
}
```

**Repository Pattern Testing**

Repository testing validates the integration between data sources, caching mechanisms, and business logic. This testing ensures data consistency across different scenarios.

```kotlin
@ExperimentalCoroutinesApi
class UserRepositoryIntegrationTest {
    
    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()
    
    private lateinit var repository: UserRepository
    private lateinit var database: AppDatabase
    private lateinit var mockApi: ApiService
    
    @Before
    fun setUp() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AppDatabase::class.java
        ).allowMainThreadQueries().build()
        
        mockApi = mockk()
        repository = UserRepository(database.userDao(), mockApi)
    }
    
    @Test
    fun `fetchUsers should cache data locally`() = runTest {
        val remoteUsers = listOf(
            User(1, "John", "john@test.com"),
            User(2, "Jane", "jane@test.com")
        )
        
        coEvery { mockApi.getUsers() } returns remoteUsers
        
        val result = repository.fetchUsers(forceRefresh = true)
        
        assertTrue(result is Result.Success)
        assertEquals(2, database.userDao().getAllUsers().size)
        coVerify { mockApi.getUsers() }
    }
    
    @Test
    fun `getUserById should return cached data when available`() = runTest {
        val user = User(1, "John", "john@test.com")
        database.userDao().insert(user)
        
        val result = repository.getUserById(1)
        
        assertEquals(user, result)
        coVerify(exactly = 0) { mockApi.getUserById(any()) }
    }
}
```

**End-to-End Testing**

End-to-end tests validate complete user workflows across multiple screens and components. These tests ensure the entire application functions correctly from the user's perspective.

```kotlin
@RunWith(AndroidJUnit4::class)
@LargeTest
class UserRegistrationE2ETest {
    
    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)
    
    @Test
    fun completeUserRegistrationFlow() {
        // Navigate to registration
        onView(withId(R.id.register_button)).perform(click())
        
        // Fill registration form
        onView(withId(R.id.username_input))
            .perform(typeText("newuser"), closeSoftKeyboard())
        
        onView(withId(R.id.email_input))
            .perform(typeText("newuser@test.com"), closeSoftKeyboard())
        
        onView(withId(R.id.password_input))
            .perform(typeText("SecurePass123"), closeSoftKeyboard())
        
        onView(withId(R.id.confirm_password_input))
            .perform(typeText("SecurePass123"), closeSoftKeyboard())
        
        // Submit registration
        onView(withId(R.id.submit_button)).perform(click())
        
        // Verify email verification screen
        onView(withId(R.id.verification_message))
            .check(matches(isDisplayed()))
            .check(matches(withText(containsString("verification email"))))
        
        // Simulate email verification (in real scenario, this might involve deep linking)
        onView(withId(R.id.verify_button)).perform(click())
        
        // Verify successful login
        onView(withId(R.id.dashboard_title))
            .check(matches(isDisplayed()))
            .check(matches(withText("Welcome, newuser!")))
    }
}
```

**Testing with External Dependencies**

Integration tests often require external services like APIs or third-party SDKs. Mock servers and dependency injection enable controlled testing environments.

```kotlin
class NetworkIntegrationTest {
    private lateinit var mockWebServer: MockWebServer
    private lateinit var apiService: ApiService
    
    @Before
    fun setUp() {
        mockWebServer = MockWebServer()
        mockWebServer.start()
        
        val retrofit = Retrofit.Builder()
            .baseUrl(mockWebServer.url("/"))
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        
        apiService = retrofit.create(ApiService::class.java)
    }
    
    @Test
    fun `api service handles server errors gracefully`() = runTest {
        mockWebServer.enqueue(
            MockResponse()
                .setResponseCode(500)
                .setBody("Internal Server Error")
        )
        
        try {
            apiService.getUsers()
            fail("Expected exception was not thrown")
        } catch (e: HttpException) {
            assertEquals(500, e.code())
        }
    }
    
    @After
    fun tearDown() {
        mockWebServer.shutdown()
    }
}
```

**Key Points:**

- Use in-memory databases for isolated database testing
- Test repository patterns with both local and remote data sources
- Implement end-to-end tests for critical user workflows
- Use mock servers for controlled network testing
- Ensure proper cleanup in integration test teardown methods

