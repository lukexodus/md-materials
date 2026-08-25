## Resource Embedding


Resource embedding allows fetching related data in a single request through foreign key relationships, eliminating N+1 query problems.

**Basic embedding syntax:**

```
GET /rest/v1/posts?select=*,author:users(*)
```

Returns posts with nested author objects:

```json
[
  {
    "id": 1,
    "title": "Post Title",
    "author": {
      "id": 5,
      "name": "Jane Smith",
      "email": "jane@example.com"
    }
  }
]
```

**Selecting embedded columns:**

```
?select=id,title,author:users(id,name)
```

Returns only specified columns from the related resource.

**Multiple relationships:**

```
?select=*,author:users(*),comments(*),category:categories(*)
```

**Deep nesting:**

```
?select=*,comments(*,author:users(*))
```

Embeds comments with each comment's author nested within.

**Many-to-many relationships:** For junction tables (e.g., `posts_tags` linking `posts` and `tags`):

```
?select=*,tags:posts_tags(tag:tags(*))
```

**Filtering embedded resources:**

```
?select=*,comments(*)&comments.status=eq.approved
```

Shows only approved comments within posts.

**Embedding parent resources (reverse direction):**

```
GET /rest/v1/users?select=*,posts(*)
```

Returns users with all their posts embedded.

**Limitations:**

- [Inference: Deep nesting can impact performance; typically limited to 2-3 levels is recommended based on common database query optimization practices]
- Requires proper foreign key constraints in database schema
- RLS policies apply to embedded resources independently

