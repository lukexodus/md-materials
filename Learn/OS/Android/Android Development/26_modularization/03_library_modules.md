## Library Modules


Library modules contain reusable code that doesn't represent complete features but provides shared functionality across the application.

**Key Points:**

- Library modules should have minimal dependencies
- They provide utilities, extensions, or abstractions used by other modules
- Should be designed with clear APIs and well-defined contracts
- Can be published as separate artifacts for reuse across projects

**Common Library Module Types:**

- **Network Module**: HTTP clients, API definitions, network utilities
- **Database Module**: Room database, DAOs, database migrations
- **Analytics Module**: Event tracking, crash reporting integrations
- **Utils Module**: Extension functions, helper classes, constants
- **Testing Module**: Test utilities, mock factories, test rules

**Example Network Module:**

```kotlin
// network/src/main/kotlin/NetworkModule.kt
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    
    @Provides
    @Singleton
    fun provideHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }
    
    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
}
```

