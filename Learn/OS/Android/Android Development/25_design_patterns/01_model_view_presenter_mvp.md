## Model-View-Presenter (MVP)


MVP is an architectural pattern that separates concerns by dividing the application into three interconnected components, providing better testability and maintainability compared to traditional MVC approaches.

**Key Points:**

- **Model**: Handles data operations, business logic, and network requests
- **View**: Manages UI components and user interactions (Activities, Fragments)
- **Presenter**: Acts as intermediary, contains presentation logic and coordinates between Model and View
- View and Model never communicate directly
- Presenter holds references to both View and Model
- Facilitates unit testing by allowing mock implementations

**Example:**

```kotlin
// Contract interface defining interactions
interface UserContract {
    interface View {
        fun showLoading()
        fun hideLoading()
        fun showUser(user: User)
        fun showError(message: String)
    }
    
    interface Presenter {
        fun loadUser(userId: String)
        fun onDestroy()
    }
}

// Model
class UserRepository {
    suspend fun getUser(userId: String): Result<User> {
        return try {
            val user = apiService.getUser(userId)
            Result.success(user)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

// Presenter
class UserPresenter(
    private val view: UserContract.View,
    private val repository: UserRepository
) : UserContract.Presenter {
    
    private val job = SupervisorJob()
    private val scope = CoroutineScope(Dispatchers.Main + job)
    
    override fun loadUser(userId: String) {
        view.showLoading()
        scope.launch {
            repository.getUser(userId)
                .onSuccess { user ->
                    view.hideLoading()
                    view.showUser(user)
                }
                .onFailure { error ->
                    view.hideLoading()
                    view.showError(error.message ?: "Unknown error")
                }
        }
    }
    
    override fun onDestroy() {
        job.cancel()
    }
}

// View (Activity)
class UserActivity : AppCompatActivity(), UserContract.View {
    private lateinit var presenter: UserPresenter
    private lateinit var binding: ActivityUserBinding
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityUserBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        val repository = UserRepository()
        presenter = UserPresenter(this, repository)
        
        presenter.loadUser("123")
    }
    
    override fun showLoading() {
        binding.progressBar.visibility = View.VISIBLE
    }
    
    override fun hideLoading() {
        binding.progressBar.visibility = View.GONE
    }
    
    override fun showUser(user: User) {
        binding.textViewName.text = user.name
        binding.textViewEmail.text = user.email
    }
    
    override fun showError(message: String) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
    
    override fun onDestroy() {
        presenter.onDestroy()
        super.onDestroy()
    }
}
```

