## Table Relationships


Relationships define how tables connect to each other through foreign keys.

### One-to-One Relationship

One record in Table A relates to exactly one record in Table B.

**Example:** User and Profile

```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL
);

CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  avatar_url TEXT
);
```

The primary key of `profiles` is also the foreign key to `users`, ensuring one profile per user.

**Querying:**

```sql
SELECT u.email, p.bio
FROM users u
JOIN profiles p ON u.id = p.user_id;
```

### One-to-Many Relationship

One record in Table A relates to multiple records in Table B.

**Example:** Author and Posts

```sql
CREATE TABLE authors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  author_id UUID REFERENCES authors(id) ON DELETE CASCADE
);

CREATE INDEX idx_posts_author ON posts(author_id);
```

One author can have many posts, but each post has one author.

**Querying:**

```sql
-- Get author with all their posts
SELECT a.name, p.title, p.created_at
FROM authors a
LEFT JOIN posts p ON a.id = p.author_id
WHERE a.id = 'uuid-here'
ORDER BY p.created_at DESC;

-- Count posts per author
SELECT a.name, COUNT(p.id) as post_count
FROM authors a
LEFT JOIN posts p ON a.id = p.author_id
GROUP BY a.id, a.name;
```

### Many-to-Many Relationship

Multiple records in Table A relate to multiple records in Table B, implemented through a junction/join table.

**Example:** Students and Courses

```sql
CREATE TABLE students (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL
);

-- Junction table
CREATE TABLE enrollments (
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  grade TEXT,
  PRIMARY KEY (student_id, course_id)
);

CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
```

The junction table stores the relationship and can include additional attributes (like `enrolled_at` and `grade`).

**Querying:**

```sql
-- Get all courses for a student
SELECT c.title, e.enrolled_at, e.grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
WHERE s.id = 'uuid-here';

-- Get all students in a course
SELECT s.name, e.grade
FROM courses c
JOIN enrollments e ON c.id = e.course_id
JOIN students s ON e.student_id = s.id
WHERE c.id = 'uuid-here';

-- Find students enrolled in multiple specific courses
SELECT s.name, COUNT(e.course_id) as course_count
FROM students s
JOIN enrollments e ON s.id = e.student_id
WHERE e.course_id IN ('course-uuid-1', 'course-uuid-2')
GROUP BY s.id, s.name
HAVING COUNT(e.course_id) = 2;
```

**Self-referencing relationships:**

```sql
-- Users following other users
CREATE TABLE follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)  -- Prevent self-following
);

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
```

