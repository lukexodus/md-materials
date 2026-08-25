## Sets


### SADD, SREM, SMEMBERS, SCARD

Redis sets are unordered collections of unique strings that provide efficient membership testing and set operations. The fundamental commands for set manipulation enable adding, removing, and examining set contents.

#### SADD (Set Add)

SADD adds one or more members to a set, creating the set if it doesn't exist. The command returns the number of elements that were actually added to the set, excluding duplicates.

**Syntax:** `SADD key member [member ...]`

**Behavior:**

- Creates the set if the key doesn't exist
- Ignores members that already exist in the set
- Returns the count of newly added members
- Time complexity: O(1) for each element added

**Example:**

```
SADD users:online "user123"
SADD users:online "user456" "user789" "user123"  # Returns 2 (user123 already exists)
SADD preferences:user123 "sports" "technology" "music"
```

#### SREM (Set Remove)

SREM removes one or more members from a set, returning the number of members that were actually removed.

**Syntax:** `SREM key member [member ...]`

**Behavior:**

- Removes specified members from the set
- Ignores members that don't exist in the set
- Returns the count of successfully removed members
- Time complexity: O(N) where N is the number of members to remove

**Example:**

```
SREM users:online "user123"
SREM users:online "user456" "user999"  # Returns 1 if user999 wasn't in set
SREM preferences:user123 "sports" "gaming"
```

#### SMEMBERS (Set Members)

SMEMBERS returns all members of a set as an array. This operation should be used carefully with large sets as it returns the entire set contents.

**Syntax:** `SMEMBERS key`

**Behavior:**

- Returns all members in the set
- Order of returned members is not guaranteed
- Returns empty array if key doesn't exist
- Time complexity: O(N) where N is the set cardinality

**Example:**

```
SMEMBERS users:online
# Returns: ["user123", "user456", "user789"]

SMEMBERS preferences:user123
# Returns: ["technology", "music"]
```

#### SCARD (Set Cardinality)

SCARD returns the number of elements in a set, providing an efficient way to check set size without retrieving all members.

**Syntax:** `SCARD key`

**Behavior:**

- Returns the number of elements in the set
- Returns 0 if the key doesn't exist
- Time complexity: O(1)

**Example:**

```
SCARD users:online
# Returns: 3

SCARD preferences:user123
# Returns: 2

SCARD nonexistent:set
# Returns: 0
```

### Set Operations: SINTER, SUNION, SDIFF

Redis provides powerful set operations that enable complex data analysis and filtering without requiring client-side processing.

#### SINTER (Set Intersection)

SINTER returns the intersection of multiple sets, finding elements that exist in all specified sets.

**Syntax:** `SINTER key [key ...]`

**Behavior:**

- Returns members present in all specified sets
- Returns empty set if any input set is empty
- Can intersect multiple sets in one operation
- Time complexity: O(N*M) where N is the cardinality of the smallest set and M is the number of sets

**Example:**

```
SADD skills:frontend "javascript" "css" "html" "react"
SADD skills:backend "javascript" "python" "sql" "redis"
SADD skills:required "javascript" "css" "python"

SINTER skills:frontend skills:backend
# Returns: ["javascript"]

SINTER skills:frontend skills:required
# Returns: ["javascript", "css"]
```

#### SUNION (Set Union)

SUNION returns the union of multiple sets, combining all unique elements from the specified sets.

**Syntax:** `SUNION key [key ...]`

**Behavior:**

- Returns all unique members from all specified sets
- Duplicates are automatically removed
- Can union multiple sets in one operation
- Time complexity: O(N) where N is the total number of elements in all sets

**Example:**

```
SADD team:frontend "alice" "bob" "charlie"
SADD team:backend "david" "alice" "eve"
SADD team:mobile "bob" "frank" "grace"

SUNION team:frontend team:backend
# Returns: ["alice", "bob", "charlie", "david", "eve"]

SUNION team:frontend team:backend team:mobile
# Returns: ["alice", "bob", "charlie", "david", "eve", "frank", "grace"]
```

#### SDIFF (Set Difference)

SDIFF returns the difference between the first set and all subsequent sets, showing elements that exist in the first set but not in any other.

**Syntax:** `SDIFF key [key ...]`

**Behavior:**

- Returns members of the first set that don't exist in subsequent sets
- Order of sets matters (not commutative)
- Returns empty set if first set is empty
- Time complexity: O(N) where N is the total number of elements in all sets

**Example:**

```
SADD all:users "user1" "user2" "user3" "user4" "user5"
SADD premium:users "user2" "user4"
SADD banned:users "user5"

SDIFF all:users premium:users
# Returns: ["user1", "user3", "user5"]

SDIFF all:users premium:users banned:users
# Returns: ["user1", "user3"]
```

**Advanced set operations:**

```
# Store results of set operations
SINTERSTORE result:intersection skills:frontend skills:backend
SUNIONSTORE result:union team:frontend team:backend
SDIFFSTORE result:difference all:users premium:users banned:users

# Multiple set operations
SINTER set1 set2 set3  # Intersection of three sets
SUNION set1 set2 set3 set4  # Union of four sets
```

### SPOP, SRANDMEMBER for Random Selections

Redis provides commands for randomly selecting elements from sets, useful for sampling, load balancing, and implementing random selection algorithms.

#### SPOP (Set Pop)

SPOP removes and returns one or more random members from a set, permanently altering the set contents.

**Syntax:** `SPOP key [count]`

**Behavior:**

- Removes and returns random members from the set
- Default count is 1 if not specified
- Returns nil if set is empty
- Time complexity: O(1) for single element, O(N) for multiple elements

**Example:**

```
SADD lottery:participants "alice" "bob" "charlie" "david" "eve"

SPOP lottery:participants
# Returns: "charlie" (and removes it from set)

SPOP lottery:participants 2
# Returns: ["alice", "eve"] (and removes both)

SMEMBERS lottery:participants
# Returns: ["bob", "david"] (remaining members)
```

#### SRANDMEMBER (Set Random Member)

SRANDMEMBER returns one or more random members from a set without removing them, preserving the original set.

**Syntax:** `SRANDMEMBER key [count]`

**Behavior:**

- Returns random members without removing them
- Default count is 1 if not specified
- Positive count returns unique elements (up to set size)
- Negative count allows duplicate returns
- Time complexity: O(1) for single element, O(N) for multiple elements

**Example:**

```
SADD available:servers "server1" "server2" "server3" "server4" "server5"

SRANDMEMBER available:servers
# Returns: "server3" (server remains in set)

SRANDMEMBER available:servers 2
# Returns: ["server1", "server4"] (unique selections)

SRANDMEMBER available:servers -3
# Returns: ["server2", "server1", "server2"] (may contain duplicates)
```

**Load balancing example:**

```
# Randomly select servers for load distribution
SRANDMEMBER load:balancer:pool 3
# Returns three random servers for request distribution

# Implement weighted random selection
SADD weighted:pool "server1" "server1" "server2" "server3" "server3" "server3"
SRANDMEMBER weighted:pool
# server3 has higher probability of selection
```

### Use Cases: Unique Visitors, Tagging Systems

#### Unique Visitors

Sets provide efficient tracking of unique visitors, users, or events without duplicates, enabling real-time analytics and user behavior analysis.

**Daily unique visitors:**

```
# Track unique visitors per day
SADD visitors:2024-01-15 "user123" "user456" "user789"
SADD visitors:2024-01-15 "user123"  # Duplicate ignored

# Get unique visitor count
SCARD visitors:2024-01-15
# Returns: 3

# Get all unique visitors
SMEMBERS visitors:2024-01-15
# Returns: ["user123", "user456", "user789"]
```

**Cross-day analytics:**

```
# Find visitors who visited both days
SINTER visitors:2024-01-15 visitors:2024-01-16

# Find all visitors across multiple days
SUNION visitors:2024-01-15 visitors:2024-01-16 visitors:2024-01-17

# Find visitors who visited day 1 but not day 2
SDIFF visitors:2024-01-15 visitors:2024-01-16
```

**Page-specific tracking:**

```
# Track unique visitors per page
SADD page:home:visitors "user123" "user456"
SADD page:about:visitors "user456" "user789"
SADD page:contact:visitors "user123" "user789"

# Find users who visited both home and about pages
SINTER page:home:visitors page:about:visitors
# Returns: ["user456"]

# Find users who visited home but not contact
SDIFF page:home:visitors page:contact:visitors
# Returns: ["user456"]
```

**Geographic and demographic analytics:**

```
# Track visitors by region
SADD visitors:region:us "user123" "user456"
SADD visitors:region:eu "user789" "user101"
SADD visitors:region:asia "user456" "user202"

# Find global visitors (visited from multiple regions)
SINTER visitors:region:us visitors:region:eu visitors:region:asia
# Returns users who visited from all regions
```

#### Tagging Systems

Sets excel at implementing flexible tagging systems for content organization, user preferences, and content recommendation engines.

**Article tagging system:**

```
# Tag articles with categories
SADD article:123:tags "technology" "programming" "tutorial"
SADD article:456:tags "technology" "database" "redis"
SADD article:789:tags "programming" "python" "tutorial"

# Find articles with specific tags
SINTER article:123:tags article:789:tags
# Returns: ["programming", "tutorial"]

# Find all unique tags in the system
SUNION article:123:tags article:456:tags article:789:tags
# Returns: ["technology", "programming", "tutorial", "database", "redis", "python"]
```

**User preference matching:**

```
# User interests and preferences
SADD user:alice:interests "technology" "programming" "music"
SADD user:bob:interests "technology" "database" "sports"
SADD user:charlie:interests "programming" "music" "travel"

# Find common interests between users
SINTER user:alice:interests user:bob:interests
# Returns: ["technology"]

SINTER user:alice:interests user:charlie:interests
# Returns: ["programming", "music"]

# Content recommendation based on interests
SADD content:article1:tags "technology" "programming"
SADD content:article2:tags "database" "technology"
SADD content:article3:tags "music" "entertainment"

# Find content matching user interests
SINTER user:alice:interests content:article1:tags
# Returns: ["technology", "programming"] - high relevance

SINTER user:alice:interests content:article3:tags
# Returns: ["music"] - medium relevance
```

**Product categorization:**

```
# Product tags for e-commerce
SADD product:laptop:tags "electronics" "computer" "portable" "work"
SADD product:phone:tags "electronics" "mobile" "portable" "communication"
SADD product:tablet:tags "electronics" "portable" "entertainment" "work"

# Find products by category intersection
SINTER product:laptop:tags product:tablet:tags
# Returns: ["electronics", "portable", "work"]

# Category-based filtering
SADD filter:portable "portable"
SADD filter:work "work"

# Find products matching multiple filters
SINTER product:laptop:tags filter:portable filter:work
# Returns products that are both portable and work-related
```

**Social media hashtag system:**

```
# Post hashtags
SADD post:123:hashtags "redis" "database" "performance"
SADD post:456:hashtags "redis" "tutorial" "beginners"
SADD post:789:hashtags "database" "optimization" "performance"

# Find trending hashtags (hashtags appearing in multiple posts)
SINTER post:123:hashtags post:456:hashtags
# Returns: ["redis"]

SINTER post:123:hashtags post:789:hashtags
# Returns: ["database", "performance"]

# Random hashtag selection for suggestions
SUNION post:123:hashtags post:456:hashtags post:789:hashtags
SRANDMEMBER hashtags:all 3
# Returns 3 random hashtags for suggestions
```

**Key points:**

- Sets automatically handle uniqueness, eliminating duplicate tracking logic
- Set operations enable complex analytics without client-side processing
- Random selection commands support load balancing and sampling algorithms
- Tagging systems benefit from set intersection and union operations
- Memory efficiency through Redis's optimized set implementations

**Output:** Redis sets provide a powerful foundation for implementing unique tracking, tagging systems, and complex data relationships. The combination of membership operations, set mathematics, and random selection makes sets ideal for analytics, recommendation engines, and content organization systems where uniqueness and set relationships are crucial.

---

