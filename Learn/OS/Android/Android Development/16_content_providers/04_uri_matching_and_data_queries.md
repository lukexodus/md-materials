## URI Matching and Data Queries


Content URIs follow a specific structure: `content://authority/path/id`, where authority identifies the content provider, path specifies the data type, and id (optional) identifies a specific record. The `UriMatcher` class provides pattern matching capabilities using wildcards: `*` matches any string, `#` matches any number.

Query construction involves building selection criteria, projection arrays, and sort orders. The selection parameter functions like a SQL WHERE clause, supporting parameterized queries through selection arguments to prevent SQL injection attacks. Projection arrays specify which columns to return, improving performance by limiting data transfer.

The `ContentUris` utility class simplifies working with URIs that include numeric IDs. Methods like `parseId()` extract ID values from URIs, while `withAppendedId()` constructs URIs by appending ID values to base URIs.

Complex queries may require custom handling within the provider implementation. The provider can interpret special URI patterns or selection criteria to perform joins, aggregations, or other advanced database operations while maintaining the simple content provider interface.

MIME type handling through the `getType()` method allows applications to understand the data format they're requesting. Standard MIME types follow patterns like `vnd.android.cursor.dir/vnd.example.book` for collections and `vnd.android.cursor.item/vnd.example.book` for individual items.

**Example:** URI matching and query patterns in Kotlin:

```kotlin
class BookQueries(private val context: Context) {
    
    private val resolver = context.contentResolver
    
    companion object {
        const val AUTHORITY = "com.example.books.provider"
        val BASE_URI: Uri = Uri.parse("content://$AUTHORITY")
        val BOOKS_URI: Uri = Uri.withAppendedPath(BASE_URI, "books")
        val AUTHORS_URI: Uri = Uri.withAppendedPath(BASE_URI, "authors")
    }
    
    // Query all books
    fun queryAllBooks(): Cursor? {
        val projection = arrayOf("_id", "title", "author", "publication_year")
        val sortOrder = "title ASC"
        
        return resolver.query(BOOKS_URI, projection, null, null, sortOrder)
    }
    
    // Query books with parameters
    fun queryBooksByYear(year: Int): Cursor? {
        val projection = arrayOf("_id", "title", "author")
        val selection = "publication_year > ?"
        val selectionArgs = arrayOf(year.toString())
        val sortOrder = "title ASC"
        
        return resolver.query(BOOKS_URI, projection, selection, selectionArgs, sortOrder)
    }
    
    // Query specific book by ID
    fun queryBookById(bookId: Long): Cursor? {
        val uri = ContentUris.withAppendedId(BOOKS_URI, bookId)
        return resolver.query(uri, null, null, null, null)
    }
    
    // Query books by author (custom URI pattern)
    fun queryBooksByAuthor(authorId: Long): Cursor? {
        val uri = Uri.withAppendedPath(AUTHORS_URI, "$authorId/books")
        return resolver.query(uri, null, null, null, "publication_year DESC")
    }
    
    // Complex query with multiple conditions
    fun queryRecentBooksByGenre(genre: String, afterYear: Int): Cursor? {
        val selection = "genre = ? AND publication_year > ?"
        val selectionArgs = arrayOf(genre, afterYear.toString())
        val sortOrder = "publication_year DESC, title ASC"
        
        return resolver.query(BOOKS_URI, null, selection, selectionArgs, sortOrder)
    }
}

// Extension functions for easier cursor handling
fun Cursor.getStringOrNull(columnName: String): String? {
    val index = getColumnIndex(columnName)
    return if (index != -1 && !isNull(index)) getString(index) else null
}

fun Cursor.getLongOrNull(columnName: String): Long? {
    val index = getColumnIndex(columnName)
    return if (index != -1 && !isNull(index)) getLong(index) else null
}

// Data class for book representation
data class Book(
    val id: Long = 0,
    val title: String,
    val author: String,
    val genre: String? = null,
    val publicationYear: Int? = null
)

// Convert cursor to Book objects
fun Cursor.toBookList(): List<Book> {
    val books = mutableListOf<Book>()
    
    use {
        while (moveToNext()) {
            val book = Book(
                id = getLongOrNull("_id") ?: 0,
                title = getStringOrNull("title") ?: "",
                author = getStringOrNull("author") ?: "",
                genre = getStringOrNull("genre"),
                publicationYear = getLongOrNull("publication_year")?.toInt()
            )
            books.add(book)
        }
    }
    
    return books
}
```

