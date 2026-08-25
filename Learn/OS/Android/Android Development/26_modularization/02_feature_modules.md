## Feature Modules


Feature modules encapsulate complete user-facing features, including UI, business logic, and feature-specific dependencies. They represent vertical slices of functionality.

**Key Points:**

- Each feature module should be self-contained and focused on a single responsibility
- Features can depend on core modules but should avoid dependencies on other features
- Navigation between features should be handled through abstraction layers
- Feature modules can be developed and tested independently

**Structure Example:**

```
feature-profile/
├── src/main/kotlin/
│   ├── ProfileActivity.kt
│   ├── ProfileViewModel.kt
│   ├── ProfileRepository.kt
│   └── di/ProfileModule.kt
├── src/test/kotlin/
└── build.gradle.kts
```

**Implementation Pattern:**

```kotlin
// feature-profile/src/main/kotlin/ProfileViewModel.kt
class ProfileViewModel(
    private val profileRepository: ProfileRepository,
    private val analyticsTracker: AnalyticsTracker
) : ViewModel() {
    
    private val _profileState = MutableLiveData<ProfileState>()
    val profileState: LiveData<ProfileState> = _profileState
    
    fun loadProfile(userId: String) {
        viewModelScope.launch {
            try {
                val profile = profileRepository.getProfile(userId)
                _profileState.value = ProfileState.Success(profile)
                analyticsTracker.track("profile_loaded")
            } catch (e: Exception) {
                _profileState.value = ProfileState.Error(e.message)
            }
        }
    }
}
```

