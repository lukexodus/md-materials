## HyperLogLog


### PFADD, PFCOUNT, PFMERGE

HyperLogLog is a probabilistic data structure that provides approximate cardinality estimation for large datasets using minimal memory. Redis implements HyperLogLog with commands prefixed by "PF" in honor of Philippe Flajolet, one of the algorithm's creators.

#### PFADD (Probabilistic Add)

PFADD adds one or more elements to a HyperLogLog structure, updating the cardinality estimate without storing the actual elements.

**Syntax:** `PFADD key element [element ...]`

**Behavior:**

- Adds elements to the HyperLogLog without storing them
- Returns 1 if the approximated cardinality changed, 0 otherwise
- Creates the HyperLogLog if the key doesn't exist
- Multiple elements can be added in a single command
- Time complexity: O(1) for each element added

**Example:**

```
PFADD unique:visitors "user123"
# Returns: 1 (cardinality estimate changed)

PFADD unique:visitors "user456" "user789" "user123"
# Returns: 1 (cardinality estimate changed, user123 duplicate ignored)

PFADD unique:visitors "user123"
# Returns: 0 (cardinality estimate unchanged)

PFADD daily:page:views "session1" "session2" "session3"
PFADD daily:page:views "session4" "session5"
```

#### PFCOUNT (Probabilistic Count)

PFCOUNT returns the approximated cardinality of one or more HyperLogLog structures, providing near-instant counting regardless of dataset size.

**Syntax:** `PFCOUNT key [key ...]`

**Behavior:**

- Returns the approximate number of unique elements
- Can count multiple HyperLogLogs simultaneously (union operation)
- Returns 0 if the key doesn't exist
- Standard error rate of approximately 0.81%
- Time complexity: O(1) for single HyperLogLog, O(N) for multiple HyperLogLogs

**Example:**

```
PFCOUNT unique:visitors
# Returns: 3 (approximate count)

PFADD page:home:visitors "user1" "user2" "user3"
PFADD page:about:visitors "user2" "user3" "user4"

PFCOUNT page:home:visitors
# Returns: 3

PFCOUNT page:about:visitors
# Returns: 3

PFCOUNT page:home:visitors page:about:visitors
# Returns: 4 (union of both sets - user2 and user3 counted once)
```

#### PFMERGE (Probabilistic Merge)

PFMERGE merges multiple HyperLogLog structures into a destination HyperLogLog, combining their cardinality estimates.

**Syntax:** `PFMERGE destkey sourcekey [sourcekey ...]`

**Behavior:**

- Merges source HyperLogLogs into destination HyperLogLog
- Overwrites destination if it already exists
- Source HyperLogLogs remain unchanged
- Result represents union of all source cardinalities
- Time complexity: O(N) where N is the number of registers

**Example:**

```
PFADD monday:visitors "user1" "user2" "user3"
PFADD tuesday:visitors "user2" "user3" "user4"
PFADD wednesday:visitors "user3" "user4" "user5"

PFMERGE weekly:visitors monday:visitors tuesday:visitors wednesday:visitors

PFCOUNT weekly:visitors
# Returns: 5 (approximate unique visitors across all days)

PFCOUNT monday:visitors tuesday:visitors wednesday:visitors
# Returns: 5 (same result as merged HyperLogLog)
```

**Advanced merging patterns:**

```
# Incremental merging for real-time analytics
PFMERGE total:visitors today:visitors
PFMERGE total:visitors yesterday:visitors
PFMERGE total:visitors last:week:visitors

# Regional analytics merging
PFADD region:us:visitors "user1" "user2" "user3"
PFADD region:eu:visitors "user4" "user5" "user6"
PFADD region:asia:visitors "user7" "user8" "user9"

PFMERGE global:visitors region:us:visitors region:eu:visitors region:asia:visitors
PFCOUNT global:visitors
# Returns: 9 (approximate global unique visitors)
```

### Probabilistic Counting and Use Cases

#### Understanding Probabilistic Counting

HyperLogLog uses probabilistic algorithms to estimate cardinality by analyzing the distribution of hash values rather than storing actual elements. This approach trades perfect accuracy for significant memory savings and consistent performance.

**Algorithm fundamentals:**

- Elements are hashed using a uniform hash function
- Hash values are analyzed for specific bit patterns
- Leading zero patterns indicate cardinality estimates
- Multiple hash buckets reduce estimation variance
- Statistical averaging improves accuracy

**Accuracy characteristics:**

- Standard error: approximately 0.81%
- 95% confidence interval: ±1.62% of true cardinality
- Accuracy remains consistent regardless of dataset size
- Error rate is relative, not absolute (1% error on 1M is 10K elements)

#### Web Analytics Use Cases

**Unique visitor tracking:**

```
# Daily unique visitors across multiple pages
PFADD visitors:2024-01-15:home "ip1" "ip2" "ip3"
PFADD visitors:2024-01-15:about "ip2" "ip4" "ip5"
PFADD visitors:2024-01-15:contact "ip1" "ip5" "ip6"

# Total unique visitors for the day
PFCOUNT visitors:2024-01-15:home visitors:2024-01-15:about visitors:2024-01-15:contact
# Returns approximate unique visitors across all pages

# Weekly aggregation
PFMERGE visitors:week:3 visitors:2024-01-15 visitors:2024-01-16 visitors:2024-01-17
PFCOUNT visitors:week:3
```

**Session and event tracking:**

```
# Track unique sessions per feature
PFADD feature:search:sessions "session1" "session2" "session3"
PFADD feature:checkout:sessions "session2" "session4" "session5"
PFADD feature:profile:sessions "session1" "session3" "session6"

# Feature adoption analysis
PFCOUNT feature:search:sessions
PFCOUNT feature:checkout:sessions
PFCOUNT feature:profile:sessions

# Cross-feature usage
PFCOUNT feature:search:sessions feature:checkout:sessions
# Users who used both search and checkout
```

#### Real-time Analytics Applications

**Stream processing:**

```
# Real-time event stream processing
PFADD stream:events:minute:1640995200 "event1" "event2" "event3"
PFADD stream:events:minute:1640995260 "event4" "event5" "event6"
PFADD stream:events:minute:1640995320 "event7" "event8" "event9"

# Hourly aggregation
PFMERGE stream:events:hour:1640995200 stream:events:minute:1640995200 stream:events:minute:1640995260 stream:events:minute:1640995320
PFCOUNT stream:events:hour:1640995200
```

**Geographic distribution:**

```
# Track unique visitors by geographic region
PFADD geo:us:east:visitors "user1" "user2" "user3"
PFADD geo:us:west:visitors "user4" "user5" "user6"
PFADD geo:eu:visitors "user7" "user8" "user9"
PFADD geo:asia:visitors "user10" "user11" "user12"

# Regional analysis
PFCOUNT geo:us:east:visitors geo:us:west:visitors
# US total unique visitors

PFCOUNT geo:us:east:visitors geo:us:west:visitors geo:eu:visitors geo:asia:visitors
# Global unique visitors
```

#### Database and Application Monitoring

**Database query tracking:**

```
# Track unique queries executed
PFADD db:queries:table:users "SELECT * FROM users WHERE active=1"
PFADD db:queries:table:users "SELECT id,name FROM users WHERE created_at > '2024-01-01'"
PFADD db:queries:table:orders "SELECT * FROM orders WHERE status='pending'"

# Unique query patterns per table
PFCOUNT db:queries:table:users
PFCOUNT db:queries:table:orders

# Application-wide query diversity
PFCOUNT db:queries:table:users db:queries:table:orders db:queries:table:products
```

**Error and exception tracking:**

```
# Track unique error signatures
PFADD errors:application:critical "NullPointerException:UserService:line:142"
PFADD errors:application:warning "TimeoutException:DatabaseConnection:line:89"
PFADD errors:application:critical "IndexOutOfBoundsException:OrderProcessor:line:234"

# Error diversity analysis
PFCOUNT errors:application:critical
PFCOUNT errors:application:warning
PFCOUNT errors:application:critical errors:application:warning
```

### Memory Usage vs Accuracy Trade-offs

#### Memory Efficiency

HyperLogLog provides exceptional memory efficiency compared to exact counting methods, using a fixed amount of memory regardless of dataset size.

**Memory usage characteristics:**

- Fixed memory footprint: 12KB per HyperLogLog
- Memory usage independent of cardinality
- Scales to billions of unique elements
- 16,384 registers with 6 bits each
- Constant memory usage regardless of input size

**Comparison with exact methods:**

```
# Exact counting with sets
SADD exact:visitors "user1" "user2" "user3" ... "user1000000"
MEMORY USAGE exact:visitors
# Returns: ~64MB for 1 million unique users

# HyperLogLog approximate counting
PFADD approx:visitors "user1" "user2" "user3" ... "user1000000"
MEMORY USAGE approx:visitors
# Returns: ~12KB regardless of user count
```

#### Accuracy Analysis

The accuracy of HyperLogLog depends on the true cardinality and follows predictable statistical patterns.

**Error characteristics:**

- Standard error: 1.04/√m where m is the number of registers (16,384)
- Standard error: approximately 0.81%
- Error decreases as cardinality increases
- 95% confidence interval: ±1.62% of true value
- 99% confidence interval: ±2.13% of true value

**Accuracy examples:**

```
# Small cardinalities (100 elements)
True count: 100
HyperLogLog estimate: 98-102 (±2% typical)

# Medium cardinalities (10,000 elements)
True count: 10,000
HyperLogLog estimate: 9,920-10,080 (±0.8% typical)

# Large cardinalities (1,000,000 elements)
True count: 1,000,000
HyperLogLog estimate: 992,000-1,008,000 (±0.8% typical)

# Very large cardinalities (100,000,000 elements)
True count: 100,000,000
HyperLogLog estimate: 99,200,000-100,800,000 (±0.8% typical)
```

#### When to Use HyperLogLog vs Exact Counting

**Use HyperLogLog when:**

- Cardinality is more important than exact membership
- Memory usage must be predictable and minimal
- Dealing with very large datasets (millions to billions of elements)
- Real-time analytics require consistent performance
- Approximate results are acceptable for business decisions

**Use exact counting (Sets) when:**

- Exact cardinality is required
- Need to retrieve actual elements
- Small to medium datasets (under 100,000 elements)
- Memory usage is not a primary concern
- Set operations (intersection, union, difference) are needed

**Hybrid approaches:**

```
# Use both for different purposes
PFADD approx:daily:visitors "user123"  # Fast cardinality estimation
SADD exact:premium:visitors "user123"   # Exact tracking for premium users

# Sample exact counting for validation
SRANDMEMBER all:visitors 1000
# Use sample to validate HyperLogLog accuracy
```

**Performance considerations:**

```
# HyperLogLog performance characteristics
PFADD key element        # O(1) - constant time
PFCOUNT key             # O(1) - constant time
PFMERGE dest src1 src2  # O(N) - N registers, not elements

# Set performance for comparison
SADD key element        # O(1) - constant time
SCARD key              # O(1) - constant time
SUNION key1 key2       # O(N) - N total elements
```

**Key points:**

- HyperLogLog provides 99%+ accuracy with 12KB memory usage
- Ideal for large-scale analytics and real-time cardinality estimation
- Memory usage remains constant regardless of dataset size
- Standard error of 0.81% applies to all cardinality ranges
- Best suited for use cases where approximate counting is acceptable

**Output:** HyperLogLog represents a powerful compromise between memory efficiency and accuracy, enabling cardinality estimation for massive datasets using minimal resources. The consistent 12KB memory footprint and sub-1% error rate make it ideal for real-time analytics, unique visitor tracking, and large-scale data analysis where exact precision is less important than scalability and performance.

---

