## SQLite Database Fundamentals


SQLite provides a lightweight, embedded relational database solution for structured data storage with ACID compliance and SQL query capabilities.

### Database Helper Implementation

```kotlin
class DatabaseHelper(context: Context) : SQLiteOpenHelper(
    context,
    DATABASE_NAME,
    null,
    DATABASE_VERSION
) {
    companion object {
        const val DATABASE_NAME = "app_database.db"
        const val DATABASE_VERSION = 1
        
        // User table
        const val TABLE_USERS = "users"
        const val COLUMN_USER_ID = "user_id"
        const val COLUMN_USERNAME = "username"
        const val COLUMN_EMAIL = "email"
        const val COLUMN_CREATED_AT = "created_at"
        
        // Notes table
        const val TABLE_NOTES = "notes"
        const val COLUMN_NOTE_ID = "note_id"
        const val COLUMN_TITLE = "title"
        const val COLUMN_CONTENT = "content"
        const val COLUMN_USER_ID_FK = "user_id"
        const val COLUMN_UPDATED_AT = "updated_at"
    }
    
    override fun onCreate(db: SQLiteDatabase) {
        val createUsersTable = """
            CREATE TABLE $TABLE_USERS (
                $COLUMN_USER_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_USERNAME TEXT NOT NULL UNIQUE,
                $COLUMN_EMAIL TEXT NOT NULL UNIQUE,
                $COLUMN_CREATED_AT TEXT NOT NULL
            )
        """.trimIndent()
        
        val createNotesTable = """
            CREATE TABLE $TABLE_NOTES (
                $COLUMN_NOTE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
                $COLUMN_TITLE TEXT NOT NULL,
                $COLUMN_CONTENT TEXT,
                $COLUMN_USER_ID_FK INTEGER,
                $COLUMN_UPDATED_AT TEXT NOT NULL,
                FOREIGN KEY($COLUMN_USER_ID_FK) REFERENCES $TABLE_USERS($COLUMN_USER_ID)
                    ON DELETE CASCADE
            )
        """.trimIndent()
        
        val createNotesIndex = """
            CREATE INDEX idx_notes_user_id ON $TABLE_NOTES($COLUMN_USER_ID_FK)
        """.trimIndent()
        
        db.execSQL(createUsersTable)
        db.execSQL(createNotesTable)
        db.execSQL(createNotesIndex)
    }
    
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        when {
            oldVersion < 2 && newVersion >= 2 -> {
                // Add new column example
                db.execSQL("ALTER TABLE $TABLE_USERS ADD COLUMN phone TEXT")
            }
            oldVersion < 3 && newVersion >= 3 -> {
                // Create new table example
                db.execSQL("""
                    CREATE TABLE categories (
                        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
                        name TEXT NOT NULL UNIQUE
                    )
                """.trimIndent())
            }
        }
    }
    
    override fun onConfigure(db: SQLiteDatabase) {
        super.onConfigure(db)
        db.setForeignKeyConstraintsEnabled(true)
    }
}
```

### Data Access Operations

```kotlin
data class User(
    val id: Long = 0,
    val username: String,
    val email: String,
    val createdAt: String
)

data class Note(
    val id: Long = 0,
    val title: String,
    val content: String?,
    val userId: Long,
    val updatedAt: String
)

class UserDao(context: Context) {
    private val dbHelper = DatabaseHelper(context)
    
    fun insertUser(user: User): Long {
        val db = dbHelper.writableDatabase
        val values = ContentValues().apply {
            put(DatabaseHelper.COLUMN_USERNAME, user.username)
            put(DatabaseHelper.COLUMN_EMAIL, user.email)
            put(DatabaseHelper.COLUMN_CREATED_AT, user.createdAt)
        }
        
        return try {
            db.insertOrThrow(DatabaseHelper.TABLE_USERS, null, values)
        } catch (e: SQLiteConstraintException) {
            -1L // Username or email already exists
        } finally {
            db.close()
        }
    }
    
    fun getUserById(userId: Long): User? {
        val db = dbHelper.readableDatabase
        val cursor = db.query(
            DatabaseHelper.TABLE_USERS,
            arrayOf(
                DatabaseHelper.COLUMN_USER_ID,
                DatabaseHelper.COLUMN_USERNAME,
                DatabaseHelper.COLUMN_EMAIL,
                DatabaseHelper.COLUMN_CREATED_AT
            ),
            "${DatabaseHelper.COLUMN_USER_ID} = ?",
            arrayOf(userId.toString()),
            null,
            null,
            null
        )
        
        return cursor.use {
            if (it.moveToFirst()) {
                User(
                    id = it.getLong(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USER_ID)),
                    username = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USERNAME)),
                    email = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_EMAIL)),
                    createdAt = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_CREATED_AT))
                )
            } else {
                null
            }
        }.also { db.close() }
    }
    
    fun getAllUsers(): List<User> {
        val db = dbHelper.readableDatabase
        val users = mutableListOf<User>()
        val cursor = db.query(
            DatabaseHelper.TABLE_USERS,
            null,
            null,
            null,
            null,
            null,
            DatabaseHelper.COLUMN_USERNAME
        )
        
        cursor.use {
            while (it.moveToNext()) {
                users.add(
                    User(
                        id = it.getLong(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USER_ID)),
                        username = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USERNAME)),
                        email = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_EMAIL)),
                        createdAt = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_CREATED_AT))
                    )
                )
            }
        }
        db.close()
        return users
    }
    
    fun updateUser(user: User): Boolean {
        val db = dbHelper.writableDatabase
        val values = ContentValues().apply {
            put(DatabaseHelper.COLUMN_USERNAME, user.username)
            put(DatabaseHelper.COLUMN_EMAIL, user.email)
        }
        
        val rowsAffected = db.update(
            DatabaseHelper.TABLE_USERS,
            values,
            "${DatabaseHelper.COLUMN_USER_ID} = ?",
            arrayOf(user.id.toString())
        )
        db.close()
        return rowsAffected > 0
    }
    
    fun deleteUser(userId: Long): Boolean {
        val db = dbHelper.writableDatabase
        val rowsAffected = db.delete(
            DatabaseHelper.TABLE_USERS,
            "${DatabaseHelper.COLUMN_USER_ID} = ?",
            arrayOf(userId.toString())
        )
        db.close()
        return rowsAffected > 0
    }
    
    // Complex query example
    fun getUsersWithNoteCount(): List<Pair<User, Int>> {
        val db = dbHelper.readableDatabase
        val query = """
            SELECT u.${DatabaseHelper.COLUMN_USER_ID},
                   u.${DatabaseHelper.COLUMN_USERNAME},
                   u.${DatabaseHelper.COLUMN_EMAIL},
                   u.${DatabaseHelper.COLUMN_CREATED_AT},
                   COUNT(n.${DatabaseHelper.COLUMN_NOTE_ID}) as note_count
            FROM ${DatabaseHelper.TABLE_USERS} u
            LEFT JOIN ${DatabaseHelper.TABLE_NOTES} n ON u.${DatabaseHelper.COLUMN_USER_ID} = n.${DatabaseHelper.COLUMN_USER_ID_FK}
            GROUP BY u.${DatabaseHelper.COLUMN_USER_ID}
            ORDER BY note_count DESC
        """.trimIndent()
        
        val results = mutableListOf<Pair<User, Int>>()
        val cursor = db.rawQuery(query, null)
        
        cursor.use {
            while (it.moveToNext()) {
                val user = User(
                    id = it.getLong(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USER_ID)),
                    username = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_USERNAME)),
                    email = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_EMAIL)),
                    createdAt = it.getString(it.getColumnIndexOrThrow(DatabaseHelper.COLUMN_CREATED_AT))
                )
                val noteCount = it.getInt(it.getColumnIndexOrThrow("note_count"))
                results.add(Pair(user, noteCount))
            }
        }
        db.close()
        return results
    }
}
```

### Transaction Management

```kotlin
class DatabaseTransactionManager(context: Context) {
    private val dbHelper = DatabaseHelper(context)
    
    fun performBulkInsert(users: List<User>, notes: List<Note>): Boolean {
        val db = dbHelper.writableDatabase
        db.beginTransaction()
        
        return try {
            // Insert users first
            val userIdMap = mutableMapOf<Long, Long>() // original ID to new ID
            users.forEach { user ->
                val values = ContentValues().apply {
                    put(DatabaseHelper.COLUMN_USERNAME, user.username)
                    put(DatabaseHelper.COLUMN_EMAIL, user.email)
                    put(DatabaseHelper.COLUMN_CREATED_AT, user.createdAt)
                }
                val newUserId = db.insertOrThrow(DatabaseHelper.TABLE_USERS, null, values)
                userIdMap[user.id] = newUserId
            }
            
            // Insert notes with updated user IDs
            notes.forEach { note ->
                val newUserId = userIdMap[note.userId] ?: throw IllegalStateException("User ID not found")
                val values = ContentValues().apply {
                    put(DatabaseHelper.COLUMN_TITLE, note.title)
                    put(DatabaseHelper.COLUMN_CONTENT, note.content)
                    put(DatabaseHelper.COLUMN_USER_ID_FK, newUserId)
                    put(DatabaseHelper.COLUMN_UPDATED_AT, note.updatedAt)
                }
                db.insertOrThrow(DatabaseHelper.TABLE_NOTES, null, values)
            }
            
            db.setTransactionSuccessful()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        } finally {
            db.endTransaction()
            db.close()
        }
    }
    
    fun transferNotesToUser(fromUserId: Long, toUserId: Long): Boolean {
        val db = dbHelper.writableDatabase
        db.beginTransaction()
        
        return try {
            // Verify both users exist
            val fromUserExists = checkUserExists(db, fromUserId)
            val toUserExists = checkUserExists(db, toUserId)
            
            if (!fromUserExists || !toUserExists) {
                throw IllegalArgumentException("One or both users do not exist")
            }
            
            // Transfer notes
            val values = ContentValues().apply {
                put(DatabaseHelper.COLUMN_USER_ID_FK, toUserId)
                put(DatabaseHelper.COLUMN_UPDATED_AT, System.currentTimeMillis().toString())
            }
            
            db.update(
                DatabaseHelper.TABLE_NOTES,
                values,
                "${DatabaseHelper.COLUMN_USER_ID_FK} = ?",
                arrayOf(fromUserId.toString())
            )
            
            db.setTransactionSuccessful()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        } finally {
            db.endTransaction()
            db.close()
        }
    }
    
    private fun checkUserExists(db: SQLiteDatabase, userId: Long): Boolean {
        val cursor = db.query(
            DatabaseHelper.TABLE_USERS,
            arrayOf(DatabaseHelper.COLUMN_USER_ID),
            "${DatabaseHelper.COLUMN_USER_ID} = ?",
            arrayOf(userId.toString()),
            null, null, null
        )
        
        return cursor.use { it.count > 0 }
    }
}
```

