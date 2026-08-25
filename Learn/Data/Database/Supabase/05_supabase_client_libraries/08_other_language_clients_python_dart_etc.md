## Other language clients (Python, Dart, etc.)


Supabase provides official and community-maintained clients for multiple programming languages.

### Python client (supabase-py)

**Installation:**

```bash
pip install supabase
```

**Basic usage:**

```python
from supabase import create_client, Client

url: str = "https://your-project-ref.supabase.co"
key: str = "your-anon-key"
supabase: Client = create_client(url, key)

# Query data
response = supabase.table("profiles").select("*").execute()
print(response.data)

# Insert data
data = supabase.table("posts").insert({
    "title": "My Post",
    "content": "Content here"
}).execute()

# Update data
data = supabase.table("posts").update({
    "title": "Updated Title"
}).eq("id", 1).execute()

# Delete data
data = supabase.table("posts").delete().eq("id", 1).execute()
```

**Authentication:**

```python
# Sign up
user = supabase.auth.sign_up({
    "email": "user@example.com",
    "password": "password123"
})

# Sign in
session = supabase.auth.sign_in_with_password({
    "email": "user@example.com",
    "password": "password123"
})

# Get current user
user = supabase.auth.get_user()

# Sign out
supabase.auth.sign_out()
```

**Storage:**

```python
# Upload file
with open("file.pdf", "rb") as f:
    supabase.storage.from_("documents").upload("file.pdf", f)

# Download file
res = supabase.storage.from_("documents").download("file.pdf")

# List files
files = supabase.storage.from_("documents").list()

# Delete file
supabase.storage.from_("documents").remove(["file.pdf"])
```

### Dart/Flutter client (supabase-flutter)

**Installation:**

`pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

**Initialization:**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://your-project-ref.supabase.co',
    anonKey: 'your-anon-key',
  );
  
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

**Query data:**

```dart
final response = await supabase
  .from('profiles')
  .select()
  .eq('id', userId);

final profiles = response as List<dynamic>;
```

**Insert data:**

```dart
await supabase.from('posts').insert({
  'title': 'My Post',
  'content': 'Content here',
  'author_id': userId,
});
```

**Authentication:**

```dart
// Sign up
final AuthResponse res = await supabase.auth.signUp(
  email: 'email@example.com',
  password: 'password123',
);

// Sign in
final AuthResponse res = await supabase.auth.signInWithPassword(
  email: 'email@example.com',
  password: 'password123',
);

// Get current user
final User?
user = supabase.auth.currentUser;

// Sign out await supabase.auth.signOut();

// Listen to auth state changes supabase.auth.onAuthStateChange.listen((data) { final AuthChangeEvent event = data.event; final Session? session = data.session;

if (event == AuthChangeEvent.signedIn) { print('User signed in'); } });
````

**Realtime subscriptions:**
```dart
final channel = supabase
  .channel('public:posts')
  .on(
    RealtimeListenTypes.postgresChanges,
    ChannelFilter(
      event: 'INSERT',
      schema: 'public',
      table: 'posts',
    ),
    (payload, [ref]) {
      print('New post: ${payload}');
    },
  )
  .subscribe();

// Unsubscribe when done
await supabase.removeChannel(channel);
````

**Storage:**

```dart
// Upload file
final file = File('path/to/file.jpg');
await supabase.storage
  .from('avatars')
  .upload('public/avatar.jpg', file);

// Download file
final bytes = await supabase.storage
  .from('avatars')
  .download('public/avatar.jpg');

// Get public URL
final url = supabase.storage
  .from('avatars')
  .getPublicUrl('public/avatar.jpg');
```

### Kotlin client (supabase-kt)

**Installation (Gradle):**

```kotlin
dependencies {
    implementation("io.github.jan-tennert.supabase:postgrest-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:gotrue-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:storage-kt:VERSION")
    implementation("io.github.jan-tennert.supabase:realtime-kt:VERSION")
}
```

**Initialization:**

```kotlin
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.gotrue.GoTrue

val supabase = createSupabaseClient(
    supabaseUrl = "https://your-project-ref.supabase.co",
    supabaseKey = "your-anon-key"
) {
    install(Postgrest)
    install(GoTrue)
}
```

**Query data:**

```kotlin
@Serializable
data class Profile(
    val id: String,
    val username: String,
    val full_name: String?
)

val profiles = supabase.from("profiles")
    .select()
    .decodeList<Profile>()
```

**Insert data:**

```kotlin
@Serializable
data class PostInsert(
    val title: String,
    val content: String?,
    val author_id: String
)

supabase.from("posts").insert(
    PostInsert(
        title = "My Post",
        content = "Content",
        author_id = userId
    )
)
```

**Authentication:**

```kotlin
// Sign up
supabase.gotrue.signUpWith(Email) {
    email = "user@example.com"
    password = "password123"
}

// Sign in
supabase.gotrue.loginWith(Email) {
    email = "user@example.com"
    password = "password123"
}

// Get session
val session = supabase.gotrue.currentSessionOrNull()

// Sign out
supabase.gotrue.logout()
```

### Swift client (supabase-swift)

**Installation (Swift Package Manager):**

Add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0")
]
```

**Initialization:**

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://your-project-ref.supabase.co")!,
    supabaseKey: "your-anon-key"
)
```

**Query data:**

```swift
struct Profile: Codable {
    let id: UUID
    let username: String
    let fullName: String?
}

let profiles: [Profile] = try await supabase
    .from("profiles")
    .select()
    .execute()
    .value
```

**Insert data:**

```swift
struct PostInsert: Codable {
    let title: String
    let content: String?
    let authorId: UUID
}

try await supabase
    .from("posts")
    .insert(PostInsert(
        title: "My Post",
        content: "Content",
        authorId: userId
    ))
    .execute()
```

**Authentication:**

```swift
// Sign up
try await supabase.auth.signUp(
    email: "user@example.com",
    password: "password123"
)

// Sign in
try await supabase.auth.signIn(
    email: "user@example.com",
    password: "password123"
)

// Get session
let session = try await supabase.auth.session

// Sign out
try await supabase.auth.signOut()
```

### C# client (supabase-csharp)

**Installation (NuGet):**

```bash
dotnet add package supabase-csharp
```

**Initialization:**

```csharp
using Supabase;

var url = "https://your-project-ref.supabase.co";
var key = "your-anon-key";
var options = new SupabaseOptions
{
    AutoConnectRealtime = true
};

var supabase = new Supabase.Client(url, key, options);
await supabase.InitializeAsync();
```

**Query data:**

```csharp
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("profiles")]
public class Profile : BaseModel
{
    [PrimaryKey("id")]
    public Guid Id { get; set; }
    
    [Column("username")]
    public string Username { get; set; }
    
    [Column("full_name")]
    public string FullName { get; set; }
}

var response = await supabase
    .From<Profile>()
    .Get();

var profiles = response.Models;
```

**Insert data:**

```csharp
var newPost = new Post
{
    Title = "My Post",
    Content = "Content here",
    AuthorId = userId
};

await supabase.From<Post>().Insert(newPost);
```

**Authentication:**

```csharp
// Sign up
var session = await supabase.Auth.SignUp("user@example.com", "password123");

// Sign in
var session = await supabase.Auth.SignIn("user@example.com", "password123");

// Get current user
var user = supabase.Auth.CurrentUser;

// Sign out
await supabase.Auth.SignOut();
```

### Go client (supabase-go)

**Installation:**

```bash
go get github.com/supabase-community/supabase-go
```

**Initialization:**

```go
package main

import (
    "github.com/supabase-community/supabase-go"
)

func main() {
    client, err := supabase.NewClient(
        "https://your-project-ref.supabase.co",
        "your-anon-key",
        nil,
    )
    if err != nil {
        panic(err)
    }
}
```

**Query data:**

```go
type Profile struct {
    ID       string  `json:"id"`
    Username string  `json:"username"`
    FullName *string `json:"full_name"`
}

var profiles []Profile
err := client.DB.From("profiles").Select("*").Execute(&profiles)
if err != nil {
    panic(err)
}
```

**Insert data:**

```go
type PostInsert struct {
    Title    string  `json:"title"`
    Content  *string `json:"content"`
    AuthorID string  `json:"author_id"`
}

post := PostInsert{
    Title:    "My Post",
    Content:  stringPtr("Content here"),
    AuthorID: userID,
}

err := client.DB.From("posts").Insert(post).Execute(nil)
if err != nil {
    panic(err)
}
```

**Authentication:**

```go
// Sign up
user, err := client.Auth.SignUp(supabase.UserCredentials{
    Email:    "user@example.com",
    Password: "password123",
})

// Sign in
session, err := client.Auth.SignIn(supabase.UserCredentials{
    Email:    "user@example.com",
    Password: "password123",
})

// Sign out
err := client.Auth.SignOut(session.AccessToken)
```

### Ruby client (supabase-rb)

**Installation:**

```bash
gem install supabase
```

**Initialization:**

```ruby
require 'supabase'

supabase = Supabase::Client.new(
  supabase_url: 'https://your-project-ref.supabase.co',
  supabase_key: 'your-anon-key'
)
```

**Query data:**

```ruby
response = supabase
  .from('profiles')
  .select('*')
  .execute

profiles = response.body
```

**Insert data:**

```ruby
response = supabase
  .from('posts')
  .insert({
    title: 'My Post',
    content: 'Content here',
    author_id: user_id
  })
  .execute
```

**Authentication:**

```ruby
# Sign up
user = supabase.auth.sign_up(
  email: 'user@example.com',
  password: 'password123'
)

# Sign in
session = supabase.auth.sign_in(
  email: 'user@example.com',
  password: 'password123'
)

# Sign out
supabase.auth.sign_out(session['access_token'])
```

### PHP client (supabase-php)

**Installation (Composer):**

```bash
composer require supabase/supabase-php
```

**Initialization:**

```php
<?php
require 'vendor/autoload.php';

use Supabase\CreateClientOptions;
use Supabase\SupabaseClient;

$supabase = new SupabaseClient(
    'https://your-project-ref.supabase.co',
    'your-anon-key'
);
```

**Query data:**

```php
$response = $supabase
    ->from('profiles')
    ->select('*')
    ->execute();

$profiles = $response->data;
```

**Insert data:**

```php
$response = $supabase
    ->from('posts')
    ->insert([
        'title' => 'My Post',
        'content' => 'Content here',
        'author_id' => $userId
    ])
    ->execute();
```

**Authentication:**

```php
// Sign up
$user = $supabase->auth->signUp(
    'user@example.com',
    'password123'
);

// Sign in
$session = $supabase->auth->signInWithPassword(
    'user@example.com',
    'password123'
);

// Get user
$user = $supabase->auth->getUser($session->access_token);

// Sign out
$supabase->auth->signOut($session->access_token);
```

### Rust client (postgrest-rs)

**Installation (Cargo.toml):**

```toml
[dependencies]
postgrest = "1.0"
```

**Basic usage:**

```rust
use postgrest::Postgrest;

#[tokio::main]
async fn main() {
    let client = Postgrest::new("https://your-project-ref.supabase.co/rest/v1")
        .insert_header("apikey", "your-anon-key");

    let resp = client
        .from("profiles")
        .select("*")
        .execute()
        .await
        .unwrap();

    let body = resp.text().await.unwrap();
    println!("{}", body);
}
```

**Insert data:**

```rust
let resp = client
    .from("posts")
    .insert(r#"{"title": "My Post", "content": "Content"}"#)
    .execute()
    .await
    .unwrap();
```

### Community clients

**Elixir (supabase-elixir):**

```elixir
# mix.exs
defp deps do
  [
    {:supabase, "~> 0.3"}
  ]
end

# Usage
{:ok, response} = Supabase.init(%{
  base_url: "https://your-project-ref.supabase.co",
  api_key: "your-anon-key"
})
|> Supabase.from("profiles")
|> Supabase.select()
|> Supabase.execute()
```

**Deno (supabase-js):**

```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_ANON_KEY')!
)

const { data, error } = await supabase
  .from('profiles')
  .select('*')
```

### Client feature comparison

|Feature|JS/TS|Python|Dart|Swift|Kotlin|C#|Go|Ruby|PHP|
|---|---|---|---|---|---|---|---|---|---|
|Database queries|✓|✓|✓|✓|✓|✓|✓|✓|✓|
|Authentication|✓|✓|✓|✓|✓|✓|✓|✓|✓|
|Storage|✓|✓|✓|✓|✓|✓|Limited|Limited|Limited|
|Realtime|✓|✓|✓|✓|✓|✓|Limited|Limited|Limited|
|Edge Functions|✓|✓|✓|✓|✓|Limited|Limited|Limited|Limited|
|Type generation|✓|Manual|Manual|Manual|Manual|Manual|Manual|Manual|Manual|
|Official support|✓|✓|✓|Community|Community|Community|Community|Community|Community|

### Client selection criteria

**Choose JavaScript/TypeScript if:**

- Building web applications
- Need full feature support
- Want automatic type generation
- Official support and frequent updates

**Choose Python if:**

- Building data processing pipelines
- Backend services in Python
- Machine learning integrations
- Scripting and automation

**Choose Dart/Flutter if:**

- Building mobile apps (iOS/Android)
- Need cross-platform mobile solution
- Flutter ecosystem

**Choose Swift if:**

- Native iOS/macOS applications
- Need best iOS performance
- Apple platform integration

**Choose Kotlin if:**

- Native Android applications
- JVM-based backend services
- Kotlin multiplatform projects

**Choose C# if:**

- .NET/ASP.NET applications
- Unity game development
- Windows desktop applications

**Choose Go if:**

- High-performance backend services
- Microservices architecture
- CLI tools

**Choose Ruby if:**

- Ruby on Rails applications
- Existing Ruby infrastructure

**Choose PHP if:**

- Legacy PHP applications
- WordPress integrations
- Shared hosting environments

### Installation troubleshooting

**Common issues across clients:**

**Missing dependencies:** Ensure all peer dependencies are installed per client documentation.

**Authentication errors:** Verify API keys and project URL are correct.

**CORS errors (browser-based clients):** Configure CORS in Supabase dashboard (Authentication → URL Configuration).

**Network timeouts:** Check network connectivity and firewall settings.

**SSL certificate errors:** Ensure system certificates are up to date.

**Type mismatches (typed clients):** Regenerate types after schema changes.

For language-specific issues, consult the respective client repository's issue tracker and documentation.

Related topics: **Authentication (GoTrue)** for implementing user authentication, **Database Queries (CRUD Operations)** for data manipulation, **Row Level Security** for securing data access with policies, **Realtime** for implementing real-time features.

---

