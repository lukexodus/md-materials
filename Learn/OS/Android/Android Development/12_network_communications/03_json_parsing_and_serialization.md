## JSON Parsing and Serialization


JSON remains the primary data exchange format for REST APIs, requiring efficient parsing and serialization mechanisms in Android applications.

### Gson Integration

Gson provides automatic JSON serialization/deserialization with minimal configuration and powerful customization options.

```kotlin
data class User(
    @SerializedName("id") val id: Int,
    @SerializedName("username") val username: String,
    @SerializedName("email") val email: String,
    @SerializedName("created_at") val createdAt: String,
    @SerializedName("profile") val profile: Profile?
)

data class Profile(
    @SerializedName("first_name") val firstName: String,
    @SerializedName("last_name") val lastName: String,
    @SerializedName("avatar_url") val avatarUrl: String?
)

class DateDeserializer : JsonDeserializer<Date> {
    override fun deserialize(
        json: JsonElement?,
        typeOfT: Type?,
        context: JsonDeserializationContext?
    ): Date {
        return SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US)
            .parse(json?.asString ?: "")
    }
}

val gson = GsonBuilder()
    .registerTypeAdapter(Date::class.java, DateDeserializer())
    .create()
```

### Moshi Alternative

Moshi offers better performance and Kotlin support compared to Gson, with built-in null safety and reflection-free operation.

```kotlin
@JsonClass(generateAdapter = true)
data class ApiResponse<T>(
    @Json(name = "data") val data: T?,
    @Json(name = "message") val message: String,
    @Json(name = "success") val success: Boolean
)

@JsonClass(generateAdapter = true)
data class User(
    @Json(name = "id") val id: Int,
    @Json(name = "username") val username: String,
    @Json(name = "email") val email: String
)

val moshi = Moshi.Builder()
    .addLast(KotlinJsonAdapterFactory())
    .build()
```

