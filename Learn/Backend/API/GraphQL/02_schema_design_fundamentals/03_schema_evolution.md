## Schema Evolution


### Versioning strategies

GraphQL's approach to versioning differs fundamentally from REST APIs. Instead of creating new API versions, GraphQL emphasizes continuous schema evolution through additive changes and graceful deprecation.

**Schema-first evolution** maintains backward compatibility by treating the schema as a living contract. New fields, types, and arguments can be added without breaking existing clients. This approach allows teams to iterate quickly while maintaining stability for consumers.

**Semantic versioning** can still apply to GraphQL schemas, but with different implications:

- **Major versions** indicate breaking changes that require client updates
- **Minor versions** introduce new features and fields
- **Patch versions** fix bugs or improve documentation

**Federation versioning** becomes complex in distributed systems where multiple services contribute to a single schema. Each service can evolve independently, but the gateway must handle schema composition and version compatibility.

**Client-driven evolution** allows different clients to request different schema versions through custom directives or headers. This enables gradual migration and A/B testing of new features.

**Example** of version-aware schema design:

```graphql
type User {
  name: String!
  email: String!
  profile: UserProfile @since(version: "2.0")
  legacyData: String @deprecated(reason: "Use profile instead")
}
```

**Key points** for effective versioning:

- Favor additive changes over breaking changes
- Use feature flags to control new functionality rollout
- Implement schema validation in CI/CD pipelines
- Maintain clear documentation of schema changes
- Consider client capabilities when planning evolution

### Deprecation patterns

Deprecation in GraphQL provides a structured way to signal that fields, arguments, or entire types will be removed in future versions while maintaining current functionality.

**Field deprecation** uses the `@deprecated` directive with clear reasoning:

```graphql
type Product {
  name: String!
  price: Float! @deprecated(reason: "Use pricing.amount instead")
  pricing: PricingInfo!
}

type PricingInfo {
  amount: Float!
  currency: String!
}
```

**Argument deprecation** follows similar patterns:

```graphql
type Query {
  users(
    limit: Int
    first: Int @deprecated(reason: "Use limit instead")
  ): [User]
}
```

**Type deprecation** requires more careful planning since types often have complex relationships:

```graphql
type LegacyUser @deprecated(reason: "Use User type instead") {
  id: ID!
  name: String!
}

type User {
  id: ID!
  name: String!
  profile: UserProfile
}
```

**Enum value deprecation** maintains backward compatibility while guiding clients toward new values:

```graphql
enum Status {
  ACTIVE
  INACTIVE
  PENDING @deprecated(reason: "Use ACTIVE with additional checks")
}
```

**Progressive deprecation** involves multiple phases:

1. **Warning phase**: Add deprecation notices without breaking functionality
2. **Migration phase**: Provide migration tools and documentation
3. **Removal phase**: Remove deprecated elements in major version updates

**Monitoring deprecation usage** helps teams understand impact:

```graphql
# Custom directive for tracking usage
directive @track(
  feature: String!
  deprecated: Boolean = false
) on FIELD_DEFINITION

type User {
  name: String! @track(feature: "user_name")
  email: String! @track(feature: "user_email", deprecated: true)
}
```

**Communication strategies** ensure smooth transitions:

- Maintain changelog with deprecation timelines
- Use schema documentation to explain alternatives
- Provide migration guides with code examples
- Send notifications to API consumers about upcoming changes

### Schema stitching concepts

Schema stitching combines multiple GraphQL schemas into a unified API surface, enabling microservices architecture while maintaining a single GraphQL endpoint for clients.

**Basic stitching** merges schemas from different services:

```graphql
# Service A - Users
type User {
  id: ID!
  name: String!
  email: String!
}

# Service B - Posts
type Post {
  id: ID!
  title: String!
  authorId: ID!
}

# Stitched Schema
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post] # Resolved through stitching
}

type Post {
  id: ID!
  title: String!
  authorId: ID!
  author: User # Resolved through stitching
}
```

**Type extensions** allow services to add fields to types defined elsewhere:

```graphql
# User service defines base User type
type User {
  id: ID!
  name: String!
}

# Profile service extends User type
extend type User {
  profile: UserProfile
}

# Analytics service extends User type
extend type User {
  analytics: UserAnalytics
}
```

**Delegation patterns** handle cross-service field resolution:

```graphql
const resolvers = {
  User: {
    posts: {
      fragment: '... on User { id }',
      resolve: (user, args, context, info) => {
        return info.mergeInfo.delegateToSchema({
          schema: postsSchema,
          operation: 'query',
          fieldName: 'postsByAuthor',
          args: { authorId: user.id },
          context,
          info
        })
      }
    }
  }
}
```

**Schema composition** strategies include:

- **Merge**: Combine schemas directly
- **Extend**: Add fields to existing types
- **Wrap**: Modify existing schemas before merging
- **Transform**: Apply transformations during composition

**Apollo Federation** provides advanced stitching capabilities:

```graphql
# User service
type User @key(fields: "id") {
  id: ID!
  name: String!
  email: String!
}

# Posts service
type Post @key(fields: "id") {
  id: ID!
  title: String!
  author: User @external
}

extend type User @key(fields: "id") {
  posts: [Post]
}
```

**Key points** for successful schema stitching:

- Plan service boundaries carefully
- Handle authentication across services
- Implement proper error handling
- Consider performance implications of cross-service calls
- Use batching and caching strategies

### Breaking vs non-breaking changes

Understanding the distinction between breaking and non-breaking changes is crucial for maintaining API stability while enabling evolution.

**Non-breaking changes** that can be safely deployed:

- Adding new fields to existing types
- Adding new types to the schema
- Adding new optional arguments to fields
- Adding new enum values
- Adding new directives
- Making required arguments optional
- Changing field descriptions

**Example** of safe additive changes:

```graphql
# Before
type User {
  name: String!
  email: String!
}

# After - Non-breaking
type User {
  name: String!
  email: String!
  profile: UserProfile  # New field added
  createdAt: DateTime   # New field added
}

type UserProfile {      # New type added
  bio: String
  avatar: String
}
```

**Breaking changes** that require careful coordination:

- Removing fields or types
- Changing field types
- Adding required arguments
- Removing enum values
- Changing argument types
- Modifying field nullability (nullable to non-nullable)

**Example** of breaking changes:

```graphql
# Before
type User {
  name: String!
  email: String!
  age: Int
}

# After - Breaking changes
type User {
  name: String!
  email: String!
  # age: Int  <- Removed (breaking)
  birthDate: Date!  # Different type/concept (breaking)
}
```

**Nullability changes** require special attention:

```graphql
# Non-breaking: Non-null to nullable
type User {
  name: String  # Was String!, now nullable
}

# Breaking: Nullable to non-null
type User {
  name: String!  # Was String, now required
}
```

**Argument changes** impact client compatibility:

```graphql
# Non-breaking: Adding optional argument
type Query {
  users(limit: Int, filter: String): [User]
}

# Breaking: Adding required argument
type Query {
  users(limit: Int, apiKey: String!): [User]
}
```

**Union and interface changes** follow specific rules:

```graphql
# Non-breaking: Adding union members
union SearchResult = User | Post | Comment

# Breaking: Removing union members
union SearchResult = User | Post
```

**Best practices** for managing changes:

- Use schema validation tools in CI/CD
- Implement breaking change detection
- Maintain comprehensive test suites
- Document all changes with clear timelines
- Provide migration tools for breaking changes
- Use feature flags for gradual rollouts

**Impact assessment** helps evaluate change safety:

- Analyze query logs to understand field usage
- Monitor deprecated field usage metrics
- Communicate with API consumers before breaking changes
- Provide adequate migration time for breaking changes

**Conclusion**

Schema evolution requires balancing innovation with stability. Non-breaking changes enable continuous improvement, while breaking changes need careful planning and communication. Effective deprecation patterns and schema stitching strategies support complex architectures while maintaining clean, evolvable APIs.

---

