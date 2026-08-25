## Creating Custom Content Providers


Custom content providers require careful planning of the URI structure, data schema, and access patterns. The process begins with defining a content URI authority - typically using your application's package name in reverse domain format - and designing URI patterns that logically represent your data hierarchy.

The provider class must implement the six abstract methods from `ContentProvider`. The `onCreate()` method initializes the provider and typically sets up database connections or other resources. The `query()` method handles data retrieval requests and returns a `Cursor` object containing the results. Insert, update, and delete methods modify data and return appropriate values indicating success or failure.

URI design follows REST-like principles where collections are represented by base URIs (e.g., `content://com.example.app.provider/books`) and individual items append an ID (`content://com.example.app.provider/books/123`). The `UriMatcher` class helps parse incoming URIs and route them to appropriate handling logic.

Database integration typically involves creating a `SQLiteOpenHelper` subclass to manage database creation and upgrades. The provider methods then use this helper to perform database operations, translating content provider method calls into SQL queries.

Registration in the `AndroidManifest.xml` file is essential, specifying the provider class, authority, and any required permissions. The `android:exported` attribute controls whether other applications can access the provider directly.

**Example:** Basic content provider structure:

```kotlin
class BookProvider : ContentProvider() {
    
    companion object {
        private const val AUTHORITY = "com.example.books.provider"
        private const val BOOKS = 1
        private const val BOOK_ID = 2
        
        private val uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "books", BOOKS)
            addURI(AUTHORITY, "books/#", BOOK_ID)
        }
    }
    
    private lateinit var dbHelper: BookDatabaseHelper
    
    override fun onCreate(): Boolean {
        dbHelper = BookDatabaseHelper(context!!)
        return true
    }
    
    override fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): Cursor? {
        val db = dbHelper.readableDatabase
        
        return when (uriMatcher.match(uri)) {
            BOOKS -> db.query("books", projection, selection, selectionArgs, null, null, sortOrder)
            BOOK_ID -> {
                val bookId = ContentUris.parseId(uri)
                val newSelection = "_id = ?"
                val newSelectionArgs = arrayOf(bookId.toString())
                db.query("books", projection, newSelection, newSelectionArgs, null, null, sortOrder)
            }
            else -> null
        }
    }
    
    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        val db = dbHelper.writableDatabase
        
        return when (uriMatcher.match(uri)) {
            BOOKS -> {
                val id = db.insert("books", null, values)
                if (id != -1L) {
                    context?.contentResolver?.notifyChange(uri, null)
                    ContentUris.withAppendedId(uri, id)
                } else null
            }
            else -> null
        }
    }
    
    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<String>?
    ): Int {
        val db = dbHelper.writableDatabase
        
        val rowsUpdated = when (uriMatcher.match(uri)) {
            BOOKS -> db.update("books", values, selection, selectionArgs)
            BOOK_ID -> {
                val bookId = ContentUris.parseId(uri)
                val newSelection = "_id = ?"
                val newSelectionArgs = arrayOf(bookId.toString())
                db.update("books", values, newSelection, newSelectionArgs)
            }
            else -> 0
        }
        
        if (rowsUpdated > 0) {
            context?.contentResolver?.notifyChange(uri, null)
        }
        
        return rowsUpdated
    }
    
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int {
        val db = dbHelper.writableDatabase
        
        val rowsDeleted = when (uriMatcher.match(uri)) {
            BOOKS -> db.delete("books", selection, selectionArgs)
            BOOK_ID -> {
                val bookId = ContentUris.parseId(uri)
                val newSelection = "_id = ?"
                val newSelectionArgs = arrayOf(bookId.toString())
                db.delete("books", newSelection, newSelectionArgs)
            }
            else -> 0
        }
        
        if (rowsDeleted > 0) {
            context?.contentResolver?.notifyChange(uri, null)
        }
        
        return rowsDeleted
    }
    
    override fun getType(uri: Uri): String? {
        return when (uriMatcher.match(uri)) {
            BOOKS -> "vnd.android.cursor.dir/vnd.example.book"
            BOOK_ID -> "vnd.android.cursor.item/vnd.example.book"
            else -> null
        }
    }
}
```

