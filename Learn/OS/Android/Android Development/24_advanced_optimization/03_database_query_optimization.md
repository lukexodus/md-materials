## Database Query Optimization


Database performance optimization focuses on query efficiency, indexing strategies, and minimizing I/O operations through proper schema design and query patterns.

**SQLite Query Optimization** Query performance depends on proper indexing, query structure, and database schema design. Understanding SQLite's query planner helps identify optimization opportunities.

```kotlin
// Inefficient query without proper indexing
fun getUsersByAge(db: SQLiteDatabase, minAge: Int): Cursor {
    return db.rawQuery(
        "SELECT * FROM users WHERE age > ? ORDER BY created_at DESC",
        arrayOf(minAge.toString())
    )
}

// Optimized with proper indexing and query structure
fun getUsersByAgeOptimized(db: SQLiteDatabase, minAge: Int): Cursor {
    // Ensure composite index: CREATE INDEX idx_users_age_created ON users(age, created_at DESC)
    return db.rawQuery(
        "SELECT user_id, name, email FROM users WHERE age > ? ORDER BY created_at DESC LIMIT 50",
        arrayOf(minAge.toString())
    )
}
```

**Room Database Optimization** Room provides compile-time query validation and optimization features including query result caching, prepared statements, and automatic index suggestions.

```kotlin
@Entity(
    indices = [
        Index(value = ["email"], unique = true),
        Index(value = ["created_at", "status"]) // Composite index for common queries
    ]
)
data class User(
    @PrimaryKey val id: Long,
    val name: String,
    val email: String,
    @ColumnInfo(name = "created_at") val createdAt: Long,
    val status: UserStatus
)

@Dao
interface UserDao {
    @Query("SELECT * FROM user WHERE status = :status ORDER BY created_at DESC LIMIT :limit")
    suspend fun getUsersByStatus(status: UserStatus, limit: Int): List<User>
    
    // Use LiveData for automatic UI updates without manual refresh
    @Query("SELECT COUNT(*) FROM user WHERE status = :status")
    fun getUserCountByStatus(status: UserStatus): LiveData<Int>
    
    // Batch operations for better performance
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUsers(users: List<User>)
}
```

**Query Result Caching** Implementing query result caching reduces database I/O for frequently accessed data, though cache invalidation strategies must be carefully managed.

```kotlin
class CachedUserRepository(private val userDao: UserDao) {
    private val queryCache = LruCache<String, List<User>>(50)
    
    suspend fun getUsersByStatus(status: UserStatus): List<User> {
        val cacheKey = "users_$status"
        
        return queryCache.get(cacheKey) ?: run {
            val users = userDao.getUsersByStatus(status, 100)
            queryCache.put(cacheKey, users)
            users
        }
    }
    
    fun invalidateCache() {
        queryCache.evictAll()
    }
}
```

**Database Connection Management** Proper connection pooling and transaction management improve database performance and prevent resource leaks in multi-threaded applications.

```kotlin
// Transaction optimization for batch operations
suspend fun performBatchUpdate(users: List<User>) {
    database.withTransaction {
        users.chunked(100).forEach { batch ->
            userDao.insertUsers(batch)
        }
    }
}

// Read-only operations don't require transactions
suspend fun getStatistics(): UserStatistics {
    return coroutineScope {
        val activeUsers = async { userDao.getActiveUserCount() }
        val totalUsers = async { userDao.getTotalUserCount() }
        val averageAge = async { userDao.getAverageUserAge() }
        
        UserStatistics(
            activeUsers = activeUsers.await(),
            totalUsers = totalUsers.await(),
            averageAge = averageAge.await()
        )
    }
}
```

**Pagination and Lazy Loading** Implementing efficient pagination reduces memory usage and improves perceived performance for large datasets.

```kotlin
@Dao
interface UserDao {
    @Query("SELECT * FROM user ORDER BY created_at DESC LIMIT :limit OFFSET :offset")
    suspend fun getUsersPaged(limit: Int, offset: Int): List<User>
}

class PaginatedUserLoader(private val userDao: UserDao) {
    private val pageSize = 20
    private var currentOffset = 0
    private val loadedUsers = mutableListOf<User>()
    
    suspend fun loadNextPage(): List<User> {
        val newUsers = userDao.getUsersPaged(pageSize, currentOffset)
        loadedUsers.addAll(newUsers)
        currentOffset += pageSize
        return newUsers
    }
}
```

