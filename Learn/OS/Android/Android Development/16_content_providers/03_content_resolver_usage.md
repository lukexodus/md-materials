## Content Resolver Usage


Client applications access content providers through the `ContentResolver`, which acts as a proxy that handles the communication with content providers. The resolver provides methods that mirror the content provider interface: `query()`, `insert()`, `update()`, and `delete()`.

The `ContentResolver` is obtained through the `Context.getContentResolver()` method and requires no explicit setup. All operations use content URIs to identify the target data, and the Android system automatically routes requests to the appropriate provider based on the URI authority.

Query operations return `Cursor` objects that must be properly managed to avoid memory leaks. The cursor provides methods to navigate through result sets and extract typed data from columns. Modern Android development often wraps cursor operations in try-with-resources blocks or uses cursor loaders for automatic lifecycle management.

Batch operations improve performance when performing multiple related operations. The `ContentResolver.applyBatch()` method accepts an array of `ContentProviderOperation` objects and executes them as a single transaction, ensuring data consistency and reducing overhead.

Content observers enable applications to monitor data changes in real-time. By registering a `ContentObserver` with the content resolver, applications can receive notifications when specific URIs are modified, enabling reactive UI updates.

**Example:** Using ContentResolver in Kotlin:

```kotlin
class BookRepository(private val context: Context) {
    
    private val resolver = context.contentResolver
    
    fun getAllBooks(): List<Book> {
        val books = mutableListOf<Book>()
        val uri = Uri.parse("content://com.example.books.provider/books")
        
        resolver.query(uri, null, null, null, "title ASC")?.use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(cursor.getColumnIndex("_id"))
                val title = cursor.getString(cursor.getColumnIndex("title"))
                val author = cursor.getString(cursor.getColumnIndex("author"))
                books.add(Book(id, title, author))
            }
        }
        
        return books
    }
    
    fun insertBook(book: Book): Uri? {
        val uri = Uri.parse("content://com.example.books.provider/books")
        val values = ContentValues().apply {
            put("title", book.title)
            put("author", book.author)
        }
        
        return resolver.insert(uri, values)
    }
    
    fun updateBook(bookId: Long, book: Book): Int {
        val uri = ContentUris.withAppendedId(
            Uri.parse("content://com.example.books.provider/books"), 
            bookId
        )
        val values = ContentValues().apply {
            put("title", book.title)
            put("author", book.author)
        }
        
        return resolver.update(uri, values, null, null)
    }
    
    fun deleteBook(bookId: Long): Int {
        val uri = ContentUris.withAppendedId(
            Uri.parse("content://com.example.books.provider/books"), 
            bookId
        )
        
        return resolver.delete(uri, null, null)
    }
    
    // Batch operations example
    fun batchInsertBooks(books: List<Book>): Boolean {
        val uri = Uri.parse("content://com.example.books.provider/books")
        val operations = books.map { book ->
            ContentProviderOperation.newInsert(uri)
                .withValue("title", book.title)
                .withValue("author", book.author)
                .build()
        }
        
        return try {
            val results = resolver.applyBatch("com.example.books.provider", operations.toTypedArray())
            results.all { it.uri != null }
        } catch (e: Exception) {
            false
        }
    }
}

// Content observer example
class BookContentObserver(
    private val handler: Handler,
    private val onDataChanged: () -> Unit
) : ContentObserver(handler) {
    
    override fun onChange(selfChange: Boolean, uri: Uri?) {
        super.onChange(selfChange, uri)
        onDataChanged()
    }
}

// Usage in Activity/Fragment
private fun setupContentObserver() {
    val handler = Handler(Looper.getMainLooper())
    val observer = BookContentObserver(handler) {
        // Refresh UI when data changes
        loadBooks()
    }
    
    val uri = Uri.parse("content://com.example.books.provider/books")
    contentResolver.registerContentObserver(uri, true, observer)
}
```

**Key Points:**

- Accessed through `Context.getContentResolver()` - no additional setup required
- All operations use content URIs to identify target data
- Cursors must be properly closed to prevent memory leaks (use `use` extension function)
- Batch operations provide transactional consistency and better performance
- Content observers enable real-time monitoring of data changes

