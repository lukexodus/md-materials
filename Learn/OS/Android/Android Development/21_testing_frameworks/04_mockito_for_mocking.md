## Mockito for Mocking


Mockito enables creation of mock objects for testing components in isolation. It provides powerful stubbing and verification capabilities essential for unit testing complex dependencies.

**Basic Mocking Concepts**

Mockito creates mock objects that simulate real dependencies while allowing complete control over their behavior. This enables testing components without relying on external systems or complex setup procedures.

```kotlin
class UserServiceTest {
    
    @Mock
    private lateinit var userRepository: UserRepository
    
    @Mock
    private lateinit var emailService: EmailService
    
    @InjectMocks
    private lateinit var userService: UserService
    
    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)
    }
    
    @Test
    fun `createUser should save user and send welcome email`() {
        val newUser = User(0, "John Doe", "john@test.com")
        val savedUser = User(1, "John Doe", "john@test.com")
        
        `when`(userRepository.save(newUser)).thenReturn(savedUser)
        
        val result = userService.createUser("John Doe", "john@test.com")
        
        assertEquals(savedUser.id, result.id)
        verify(userRepository).save(newUser)
        verify(emailService).sendWelcomeEmail("john@test.com")
    }
}
```

**Advanced Stubbing Techniques**

Mockito supports sophisticated stubbing scenarios including conditional returns, exception throwing, and argument capturing. These capabilities enable testing complex business logic thoroughly.

```kotlin
@Test
fun `getUserProfile should handle different user types`() {
    val premiumUser = User(1, "Premium User", "premium@test.com", UserType.PREMIUM)
    val basicUser = User(2, "Basic User", "basic@test.com", UserType.BASIC)
    
    `when`(userRepository.findById(1)).thenReturn(premiumUser)
    `when`(userRepository.findById(2)).thenReturn(basicUser)
    
    `when`(profileService.getPremiumProfile(any())).thenReturn(PremiumProfile())
    `when`(profileService.getBasicProfile(any())).thenReturn(BasicProfile())
    
    val premiumProfile = userService.getUserProfile(1)
    val basicProfile = userService.getUserProfile(2)
    
    assertTrue(premiumProfile is PremiumProfile)
    assertTrue(basicProfile is BasicProfile)
    
    verify(profileService).getPremiumProfile(premiumUser)
    verify(profileService).getBasicProfile(basicUser)
}

@Test
fun `processPayment should retry on temporary failures`() {
    val payment = Payment(100.0, "USD")
    
    `when`(paymentGateway.processPayment(payment))
        .thenThrow(TemporaryFailureException())
        .thenThrow(TemporaryFailureException())
        .thenReturn(PaymentResult.SUCCESS)
    
    val result = paymentService.processPayment(payment)
    
    assertEquals(PaymentResult.SUCCESS, result)
    verify(paymentGateway, times(3)).processPayment(payment)
}
```

**Argument Captor Usage**

ArgumentCaptor enables capturing and verifying arguments passed to mock methods, particularly useful for testing complex object interactions and transformations.

```kotlin
@Test
fun `sendNotification should format message correctly`() {
    val user = User(1, "John Doe", "john@test.com")
    val event = UserRegistrationEvent(user, Date())
    
    notificationService.handleRegistration(event)
    
    val messageCaptor = ArgumentCaptor.forClass(NotificationMessage::class.java)
    verify(notificationSender).send(messageCaptor.capture())
    
    val capturedMessage = messageCaptor.value
    assertEquals("Welcome John Doe!", capturedMessage.title)
    assertEquals("john@test.com", capturedMessage.recipient)
    assertTrue(capturedMessage.content.contains("registration successful"))
}
```

**Spy Objects**

Spy objects combine real object functionality with selective mocking, enabling partial mocking scenarios where only specific methods need stubbing.

```kotlin
@Test
fun `calculateDiscount should use real calculation with mocked validation`() {
    val discountCalculator = spy(DiscountCalculator())
    
    // Mock only the validation method
    `when`(discountCalculator.isValidCustomer(any())).thenReturn(true)
    
    val customer = Customer("premium", 1000.0)
    val discount = discountCalculator.calculateDiscount(customer, 500.0)
    
    // Real calculation logic is used
    assertEquals(50.0, discount, 0.01)
    
    // Verify mock was called
    verify(discountCalculator).isValidCustomer(customer)
}
```

**MockK for Kotlin**

MockK provides Kotlin-native mocking capabilities with better support for Kotlin language features including coroutines, extension functions, and data classes.

```kotlin
class CoroutineServiceTest {
    private val repository = mockk<DataRepository>()
    private val service = DataService(repository)
    
    @Test
    fun `fetchData should handle coroutine suspension`() = runTest {
        coEvery { repository.getData() } returns "test data"
        
        val result = service.fetchData()
        
        assertEquals("test data", result)
        coVerify { repository.getData() }
    }
    
    @Test
    fun `extension function mocking works correctly`() {
        val user = mockk<User>()
        
        every { user.getDisplayName() } returns "John Doe"
        
        assertEquals("John Doe", user.getDisplayName())
        verify { user.getDisplayName() }
    }
}
```

**Key Points:**

- Use `@Mock` and `@InjectMocks` annotations for clean test setup
- Implement argument captors for verifying complex method arguments
- Leverage spy objects for partial mocking scenarios
- Consider MockK for enhanced Kotlin language support
- Verify mock interactions to ensure proper component communication

