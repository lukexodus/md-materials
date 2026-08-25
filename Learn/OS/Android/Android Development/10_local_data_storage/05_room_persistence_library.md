## Room Persistence Library


Room provides an abstraction layer over SQLite, offering compile-time verified SQL queries, automatic database schema generation, and seamless integration with other Architecture Components.

**Key points:**

- Provides compile-time SQL validation and query verification
- Generates boilerplate database code automatically
- Integrates with LiveData, Flow, and RxJava for reactive programming
- Supports database migrations with version management

### Entity Definitions

```kotlin
@Entity(
    tableName = "users",
    indices = [Index(value = ["username"], unique = true), Index(value = ["email"], unique = true)]
)
data class User(
    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "user_id")
    val id: Long = 0,
    
    @ColumnInfo(name = "username")
    val username: String,
    
    @ColumnInfo(name = "email")
    val email: String,
    
    @ColumnInfo(name = "created_at")
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(
    tableName = "notes",
    foreignKeys = [
        ForeignKey(
            entity = User::class,
            parentColumns = ["user_id"],
            childColumns = ["user_id"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["user_id"])]
)
data class Note(
    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "note_id")
    val id: Long = 0,
    
    @ColumnInfo(name = "title")
    val title: String,
    
    @ColumnInfo(name = "content")
    val content: String?,
    
    @ColumnInfo(name = "user_id")
    val userId: Long,
    
    @ColumnInfo(name = "updated_at")
    val updatedAt: Long = System.currentTimeMillis()
)

// Data class for complex queries
data class UserWithNotes(
    @Embedded val user: User,
    @Relation(
        parentColumn = "user_id",
        entityColumn = "user_id"
    )
    val notes: List<Note>
)
```

### Data Access Objects (DAOs)

```kotlin
@Dao
interface UserDao {
    
    @Query("SELECT * FROM users ORDER BY username ASC")
    fun getAllUsers(): Flow<List<User>>
    
    @Query("SELECT * FROM users WHERE user_id = :userId")
    suspend fun getUserById(userId: Long): User?
    
    @Query("SELECT * FROM users WHERE username = :username LIMIT 1")
    suspend fun getUserByUsername(username: String): User?
    
    @Insert(onConflict = OnConflictStrategy.ABORT)
    suspend fun insertUser(user: User): Long
    
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertUsers(users: List<User>): List<Long>
    
    @Update
    suspend fun updateUser(user: User): Int
    
    @Delete
    suspend fun deleteUser(user: User): Int
    
    @Query("DELETE FROM users WHERE user_id = :userId")
    suspend fun deleteUserById(userId: Long): Int
    
    // Complex queries
    @Transaction
    @Query("SELECT * FROM users")
    fun getUsersWithNotes(): Flow<List<UserWithNotes>>
    
    @Query("""
        SELECT u.*, COUNT(n.note_id) as note_count
        FROM users u
        LEFT JOIN notes n ON u.user_id = n.user_id
        GROUP BY u.user_id
        ORDER BY note_count DESC
    """)
    fun getUsersWithNoteCount(): Flow<List<UserWithNoteCount>>
    
    @Query("""
        SELECT * FROM users 
        WHERE created_at BETWEEN :startDate AND :endDate
        ORDER BY created_at DESC
    """)
    suspend fun getUsersCreatedBetween(startDate: Long, endDate: Long): List<User>
    
    @Query("SELECT COUNT(*) FROM users")
    fun getUserCount(): Flow<Int>
    
    @Query("""
        SELECT * FROM users 
        WHERE username LIKE :searchQuery OR email LIKE :searchQuery
        ORDER BY username ASC
    """)
    fun searchUsers(searchQuery: String): Flow<List<User>>
}

@Dao
interface NoteDao {
    
    @Query("SELECT * FROM notes ORDER BY updated_at DESC")
    fun getAllNotes(): Flow<List<Note>>
    
    @Query("SELECT * FROM notes WHERE user_id = :userId ORDER BY updated_at DESC")
    fun getNotesByUserId(userId: Long): Flow<List<Note>>
    
    @Query("SELECT * FROM notes WHERE note_id = :noteId")
    suspend fun getNoteById(noteId: Long): Note?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNote(note: Note): Long
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNotes(notes: List<Note>): List<Long>
    
    @Update
    suspend fun updateNote(note: Note): Int
    
    @Delete
    suspend fun deleteNote(note: Note): Int
    
    @Query("DELETE FROM notes WHERE note_id = :noteId")
    suspend fun deleteNoteById(noteId: Long): Int
    
    @Query("DELETE FROM notes WHERE user_id = :userId")
    suspend fun deleteNotesByUserId(userId: Long): Int
    
    // Full-text search
    @Query("""
        SELECT * FROM notes 
        WHERE title LIKE '%' || :query || '%' OR content LIKE '%' || :query || '%'
        ORDER BY updated_at DESC
    """)
    fun searchNotes(query: String): Flow<List<Note>>
    
    @Query("""
        SELECT * FROM notes 
        WHERE user_id = :userId AND (title LIKE '%' || :query || '%' OR content LIKE '%' || :query || '%')
        ORDER BY updated_at DESC
    """)
    fun searchUserNotes(userId: Long, query: String): Flow<List<Note>>
}

// Custom data class for complex query results
data class UserWithNoteCount(
    @Embedded val user: User,
    @ColumnInfo(name = "note_count") val noteCount: Int
)
```

### Database Configuration

```kotlin
@Database(
    entities = [User::class, Note::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    
    abstract fun userDao(): UserDao
    abstract fun noteDao(): NoteDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database"
                )
                .fallbackToDestructiveMigration() // Remove in production
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}

// Type converters for complex data types
class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }
    
    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }
    
    @TypeConverter
    fun fromStringList(value: List<String>?): String? {
        return value?.let { Gson().toJson(it) }
    }
    
    @TypeConverter
    fun toStringList(value: String?): List<String>? {
        return value?.let { 
            Gson().fromJson(it, object : TypeToken<List<String>>() {}.type)
        }
    }
}
```

### Repository Pattern Implementation

```kotlin
class UserRepository(private val userDao: UserDao, private val noteDao: NoteDao) {
    
    fun getAllUsers(): Flow<List<User>> = userDao.getAllUsers()
    
    fun getUsersWithNotes(): Flow<List<UserWithNotes>> = userDao.getUsersWithNotes()
    
    suspend fun getUserById(userId: Long): User? = userDao.getUserById(userId)
    
    suspend fun createUser(username: String, email: String): Result<Long> {
        return try {
            val user = User(username = username, email = email)
            val userId = userDao.insertUser(user)
            Result.success(userId)
        } catch (e: SQLiteConstraintException) {
            Result.failure(Exception("Username or email already exists"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun updateUser(user: User): Result<Boolean> {
        return try {
            val rowsAffected = userDao.updateUser(user)
            Result.success(rowsAffected > 0)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun deleteUser(userId: Long): Result<Boolean> {
        return try {
            val rowsAffected = userDao.deleteUserById(userId)
            Result.success(rowsAffected > 0)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun searchUsers(query: String): Flow<List<User>> {
        val searchQuery = "%$query%"
        return userDao.searchUsers(searchQuery)
    }
    
    // Bulk operations
    suspend fun importUsers(users: List<User>): Result<List<Long>> {
        return try {
            val userIds = userDao.insertUsers(users)
            Result.success(userIds)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

class NoteRepository(private val noteDao: NoteDao) {
    
    fun getAllNotes(): Flow<List<Note>> = noteDao.getAllNotes()
    
    fun getNotesByUserId(userId: Long): Flow<List<Note>> = noteDao.getNotesByUserId(userId)
    
    suspend fun getNoteById(noteId: Long): Note? = noteDao.getNoteById(noteId)
    
    suspend fun createNote(title: String, content: String?, userId: Long): Result<Long> {
        return try {
            val note = Note(title = title, content = content, userId = userId)
            val noteId = noteDao.insertNote(note)
            Result.success(noteId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun updateNote(note: Note): Result<Boolean> {
        return try {
            val updatedNote = note.copy(updatedAt = System.currentTimeMillis())
            val rowsAffected = noteDao.updateNote(updatedNote)
            Result.success(rowsAffected > 0)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    suspend fun deleteNote(noteId: Long): Result<Boolean> {
        return try {
            val rowsAffected = noteDao.deleteNoteById(noteId)
            Result.success(rowsAffected > 0)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun searchNotes(query: String): Flow<List<Note>> = noteDao.searchNotes(query)
    
    fun searchUserNotes(userId: Long, query: String): Flow<List<Note>> = 
        noteDao.searchUserNotes(userId, query)
}
```

### Database Migrations

```kotlin
// Migration from version 1 to 2
val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(database: SupportSQLiteDatabase) {
        // Add new column to users table
        database.execSQL("ALTER TABLE users ADD COLUMN phone TEXT")
        
        // Create new table
        database.execSQL("""
            CREATE TABLE categories (
                category_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                name TEXT NOT NULL,
                color TEXT NOT NULL DEFAULT '#000000'
            )
        """.trimIndent())
        
        // Add foreign key to notes table
        database.execSQL("ALTER TABLE notes ADD COLUMN category_id INTEGER")
        database.execSQL("""
            CREATE INDEX index_notes_category_id ON notes(category_id)
        """.trimIndent())
    }
}

// Migration from version 2 to 3
val MIGRATION_2_3 = object : Migration(2, 3) {
    override fun migrate(database: SupportSQLiteDatabase) {
        // Create temporary table with new schema
        database.execSQL("""
            CREATE TABLE users_new (
                user_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                username TEXT NOT NULL,
                email TEXT NOT NULL,
                phone TEXT,
                full_name TEXT,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
            )
        """.trimIndent())
        
        // Copy data from old table to new table
        database.execSQL("""
            INSERT INTO users_new (user_id, username, email, phone, created_at, updated_at)
            SELECT user_id, username, email, phone, created_at, created_at
            FROM users
        """.trimIndent())
        
        // Drop old table and rename new table
        database.execSQL("DROP TABLE users")
        database.execSQL("ALTER TABLE users_new RENAME TO users")
        
        // Recreate indices
        database.execSQL("CREATE UNIQUE INDEX index_users_username ON users(username)")
        database.execSQL("CREATE UNIQUE INDEX index_users_email ON users(email)")
    }
}

// Update database configuration
@Database(
    entities = [User::class, Note::class],
    version = 3,
    exportSchema = true
)
abstract class AppDatabase : RoomDatabase() {
    // ... DAOs
    
    companion object {
        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database"
                )
                .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
```

### Advanced Room Features

```kotlin
// Prepopulated database
class DatabaseInitializer {
    companion object {
        fun populateDatabase(database: AppDatabase) {
            // This runs on a background thread
            val userDao = database.userDao()
            val noteDao = database.noteDao()
            
            GlobalScope.launch {
                // Insert default users
                val defaultUsers = listOf(
                    User(username = "admin", email = "admin@app.com"),
                    User(username = "demo", email = "demo@app.com")
                )
                userDao.insertUsers(defaultUsers)
                
                // Insert sample notes
                val sampleNotes = listOf(
                    Note(title = "Welcome", content = "Welcome to the app!", userId = 1),
                    Note(title = "Demo Note", content = "This is a demo note.", userId = 2)
                )
                noteDao.insertNotes(sampleNotes)
            }
        }
    }
}

// Database with preprocessing callback
fun getDatabaseWithCallback(context: Context): AppDatabase {
    return Room.databaseBuilder(context, AppDatabase::class.java, "app_database")
        .addCallback(object : RoomDatabase.Callback() {
            override fun onCreate(db: SupportSQLiteDatabase) {
                super.onCreate(db)
                // Database created for the first time
            }
            
            override fun onOpen(db: SupportSQLiteDatabase) {
                super.onOpen(db)
                // Database opened
            }
        })
        .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
        .build()
}

// Custom query with raw SQL
@Dao
interface AnalyticsDao {
    
    @RawQuery
    suspend fun executeCustomQuery(query: SupportSQLiteQuery): Cursor
    
    // Dynamic query building
    suspend fun getNotesWithDynamicFilters(
        userId: Long?,
        dateFrom: Long?,
        dateTo: Long?,
        searchTerm: String?
    ): List<Note> {
        val queryBuilder = StringBuilder("SELECT * FROM notes WHERE 1=1")
        val args = mutableListOf<Any>()
        
        userId?.let {
            queryBuilder.append(" AND user_id = ?")
            args.add(it)
        }
        
        dateFrom?.let {
            queryBuilder.append(" AND updated_at >= ?")
            args.add(it)
        }
        
        dateTo?.let {
            queryBuilder.append(" AND updated_at <= ?")
            args.add(it)
        }
        
        searchTerm?.let {
            queryBuilder.append(" AND (title LIKE ? OR content LIKE ?)")
            args.add("%$it%")
            args.add("%$it%")
        }
        
        queryBuilder.append(" ORDER BY updated_at DESC")
        
        val query = SimpleSQLiteQuery(queryBuilder.toString(), args.toTypedArray())
        return executeCustomQuery(query).use { cursor ->
            val notes = mutableListOf<Note>()
            while (cursor.moveToNext()) {
                notes.add(
                    Note(
                        id = cursor.getLong(cursor.getColumnIndexOrThrow("note_id")),
                        title = cursor.getString(cursor.getColumnIndexOrThrow("title")),
                        content = cursor.getString(cursor.getColumnIndexOrThrow("content")),
                        userId = cursor.getLong(cursor.getColumnIndexOrThrow("user_id")),
                        updatedAt = cursor.getLong(cursor.getColumnIndexOrThrow("updated_at"))
                    )
                )
            }
            notes
        }
    }
}
```

**Key points:**

- Room eliminates boilerplate SQLite code while maintaining SQL flexibility
- Provides compile-time query validation preventing runtime SQL errors [Unverified]
- Integrates seamlessly with Kotlin coroutines and Flow for reactive programming
- Supports complex relationships, migrations, and custom type converters
- Offers better performance than raw SQLite through query optimization [Inference]

**Next steps:** Understanding database testing strategies, implementing offline-first architectures with synchronization, exploring advanced querying techniques with FTS (Full-Text Search), and integrating with dependency injection frameworks are crucial for mastering local data persistence in Android applications.

---

