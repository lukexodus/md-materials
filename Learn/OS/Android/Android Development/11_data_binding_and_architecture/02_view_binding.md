## View Binding


View Binding provides a more lightweight alternative to data binding when you only need null-safe references to views without the overhead of data binding expressions.

**Key Points:**

- Generates binding classes for every XML layout file
- Provides null safety and type safety
- Faster build times compared to data binding
- No annotation processing required
- Direct replacement for findViewById()

**Setup and Usage:**

```kotlin
// Enable view binding
android {
    buildFeatures {
        viewBinding = true
    }
}

// Fragment implementation
class ProfileFragment : Fragment() {
    private var _binding: FragmentProfileBinding? = null
    private val binding get() = _binding!!
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentProfileBinding.inflate(inflater, container, false)
        return binding.root
    }
    
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        binding.nameTextView.text = "John Doe"
        binding.saveButton.setOnClickListener {
            // Handle click
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}

// Activity implementation
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        binding.toolbar.title = "My App"
    }
}
```

