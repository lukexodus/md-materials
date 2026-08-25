## Gradle Configuration Management


Effective Gradle configuration is crucial for managing dependencies, build variants, and shared settings across modules in a modularized project.

**Key Points:**

- Centralized dependency management prevents version conflicts
- Build convention plugins reduce configuration duplication
- Proper dependency scopes optimize build performance
- Version catalogs provide single source of truth for dependencies

**Version Catalogs (gradle/libs.versions.toml):**

```toml
[versions]
kotlin = "1.9.10"
compose = "1.5.4"
lifecycle = "2.7.0"
hilt = "2.48"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "kotlin" }
androidx-lifecycle-viewmodel = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-ktx", version.ref = "lifecycle" }
compose-ui = { group = "androidx.compose.ui", name = "ui", version.ref = "compose" }
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }

[plugins]
android-application = { id = "com.android.application", version = "8.1.2" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
```

**Build Convention Plugins:**

```kotlin
// build-logic/convention/src/main/kotlin/AndroidLibraryConventionPlugin.kt
class AndroidLibraryConventionPlugin : Plugin<Project> {
    override fun apply(target: Project) {
        with(target) {
            with(pluginManager) {
                apply("com.android.library")
                apply("org.jetbrains.kotlin.android")
            }
            
            extensions.configure<LibraryExtension> {
                compileSdk = 34
                
                defaultConfig {
                    minSdk = 21
                    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
                }
                
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
                
                kotlinOptions {
                    jvmTarget = "11"
                }
            }
        }
    }
}
```

**Module Build Configuration:**

```kotlin
// feature-profile/build.gradle.kts
plugins {
    alias(libs.plugins.android.library.convention)
    alias(libs.plugins.hilt)
}

dependencies {
    implementation(project(":core"))
    implementation(project(":domain"))
    
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.viewmodel)
    implementation(libs.compose.ui)
    implementation(libs.hilt.android)
    
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.test.ext.junit)
}
```

**Dependency Management Strategies:**

- Use `api` for dependencies that need to be exposed to consuming modules
- Use `implementation` for internal dependencies that shouldn't leak
- Use `compileOnly` for dependencies provided at runtime
- Leverage `testImplementation` and `androidTestImplementation` for test-specific dependencies

**Build Performance Optimization:**

```kotlin
// gradle.properties
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
kotlin.code.style=official
kotlin.incremental=true
kotlin.incremental.useClasspathSnapshot=true
```

**Examples:** A typical modularized project structure might include:

```
app/                    # Main application module
├── feature-auth/       # Authentication feature
├── feature-home/       # Home screen feature  
├── feature-profile/    # User profile feature
├── core/              # Core utilities and base classes
├── network/           # Network layer
├── database/          # Local storage
├── domain/            # Business logic and models
└── design-system/     # UI components and theming
```

**Output:** [Inference] The modularization approach significantly improves development workflow and application architecture, though the optimal module structure depends on specific project requirements and team organization. Teams should consider factors like feature complexity, shared dependencies, and development team structure when designing their modular architecture.

---

