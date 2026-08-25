## Advanced Type System


### Input Types and Custom Scalars

Input types in GraphQL define the structure of data that clients can send to your API through mutations and query arguments. Unlike output types, input types cannot have fields that resolve to other complex types - they can only contain scalars, enums, and other input types.

Input types provide type safety and validation for client-submitted data. They enable you to define exactly what shape of data your mutations expect, including nested objects and arrays, while maintaining clear boundaries between input and output data structures.

Custom scalars extend GraphQL's built-in scalar types (String, Int, Float, Boolean, ID) with domain-specific data types. They encapsulate validation, serialization, and parsing logic for specialized values like dates, emails, URLs, or monetary amounts.

Custom scalars provide better semantic meaning in your schema, enable client-side type generation, and centralize validation logic. They help prevent common errors by ensuring data conforms to expected formats before reaching your business logic.

**Key points:**

- Input types can only contain scalars, enums, and other input types
- Custom scalars encapsulate validation and parsing logic
- Input types provide type safety for mutations and query arguments
- Custom scalars improve schema semantics and client-side type generation
- Input types cannot reference output types or contain circular references

**Example of input types:**

```graphql
input CreateUserInput {
  email: EmailAddress!
  password: String!
  profile: CreateUserProfileInput!
  preferences: UserPreferencesInput
}

input CreateUserProfileInput {
  firstName: String!
  lastName: String!
  birthDate: Date
  avatar: Upload
  bio: String
}

input UserPreferencesInput {
  theme: Theme!
  language: Language!
  notifications: NotificationPreferencesInput!
}

input NotificationPreferencesInput {
  email: Boolean!
  push: Boolean!
  sms: Boolean!
}

input UpdatePostInput {
  title: String
  content: String
  tags: [String!]
  publishedAt: DateTime
  metadata: JSONObject
}
```

**Example of custom scalars:**

```graphql
scalar EmailAddress
scalar Date
scalar DateTime
scalar URL
scalar PhoneNumber
scalar Money
scalar JSONObject
scalar Upload

type User {
  id: ID!
  email: EmailAddress!
  createdAt: DateTime!
  profile: UserProfile!
}

type UserProfile {
  website: URL
  phone: PhoneNumber
  birthDate: Date
}

type Product {
  id: ID!
  price: Money!
  metadata: JSONObject
}
```

### Interfaces and Unions for Polymorphism

Interfaces in GraphQL define a contract that multiple types can implement. They specify a set of fields that implementing types must include, enabling polymorphic queries where you can request interface fields regardless of the concrete type.

Interfaces are ideal when you have related types that share common fields but have different additional properties. They allow clients to query shared fields while still being able to access type-specific fields using inline fragments.

Unions represent a type that could be one of several different types. Unlike interfaces, union types don't share any fields - they're purely a way to return different types from the same field based on runtime conditions.

Unions are perfect for representing heterogeneous data, search results, or response types that could be either success or error states. They provide type safety for scenarios where the actual type varies based on business logic.

**Key points:**

- Interfaces define shared fields that multiple types must implement
- Unions allow a field to return one of several different types
- Use interfaces when types share common fields and behavior
- Use unions when types are related but don't share fields
- Both require type resolvers to determine the concrete type at runtime

**Example of interfaces:**

```graphql
interface Node {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
}

interface Content {
  id: ID!
  title: String!
  author: User!
  publishedAt: DateTime
  tags: [String!]!
}

type Post implements Node & Content {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  title: String!
  author: User!
  publishedAt: DateTime
  tags: [String!]!
  content: String!
  comments: [Comment!]!
}

type Video implements Node & Content {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  title: String!
  author: User!
  publishedAt: DateTime
  tags: [String!]!
  duration: Int!
  videoUrl: URL!
  thumbnail: URL!
}

type Query {
  content(id: ID!): Content
  recentContent: [Content!]!
}
```

**Example of unions:**

```graphql
union SearchResult = Post | Video | User | Product

union NotificationContent = 
  | CommentNotification 
  | LikeNotification 
  | FollowNotification 
  | SystemNotification

union PaymentResult = PaymentSuccess | PaymentFailure

type PaymentSuccess {
  transactionId: String!
  amount: Money!
  confirmedAt: DateTime!
}

type PaymentFailure {
  errorCode: String!
  message: String!
  retryable: Boolean!
}

type Query {
  search(query: String!): [SearchResult!]!
  notifications: [NotificationContent!]!
}

type Mutation {
  processPayment(input: PaymentInput!): PaymentResult!
}
```

### Directives and Their Usage

Directives in GraphQL provide a way to modify the execution behavior of your schema. They're preceded by the `@` symbol and can be applied to various schema elements to add metadata, conditional logic, or processing instructions.

Built-in directives include `@include` and `@skip` for conditional field inclusion, `@deprecated` for marking fields as deprecated, and `@specifiedBy` for linking to scalar specifications. These directives control query execution and provide metadata to clients.

Custom directives extend GraphQL's capabilities by allowing you to define your own execution modifiers. They can implement cross-cutting concerns like authentication, authorization, caching, rate limiting, and data transformation.

Schema directives are applied during schema definition and can modify type definitions, field definitions, and other schema elements. They're processed during schema construction and can transform the schema structure or add execution logic.

**Key points:**

- Directives modify execution behavior and add metadata to schemas
- Built-in directives provide conditional logic and deprecation support
- Custom directives enable cross-cutting concerns and reusable logic
- Schema directives are processed during schema construction
- Directives can be applied to types, fields, arguments, and other schema elements

**Example of built-in directives:**

```graphql
type User {
  id: ID!
  email: String!
  username: String! @deprecated(reason: "Use email instead")
  profile: UserProfile!
  internalNotes: String @deprecated(reason: "For admin use only")
}

type Query {
  user(id: ID!): User
  users(
    limit: Int @deprecated(reason: "Use pagination instead")
    offset: Int @deprecated(reason: "Use pagination instead")
    pagination: PaginationInput
  ): [User!]!
}

# Client usage with conditional directives
query GetUser($includeProfile: Boolean!, $skipDeprecated: Boolean!) {
  user(id: "123") {
    id
    email
    profile @include(if: $includeProfile) {
      firstName
      lastName
    }
    username @skip(if: $skipDeprecated)
  }
}
```

**Example of custom directives:**

```graphql
directive @auth(requires: Role = USER) on FIELD_DEFINITION
directive @rateLimit(max: Int!, window: Int!) on FIELD_DEFINITION
directive @cache(maxAge: Int!) on FIELD_DEFINITION
directive @validate(format: String!) on ARGUMENT_DEFINITION
directive @transform(format: String!) on FIELD_DEFINITION

type User {
  id: ID!
  email: String!
  profile: UserProfile! @auth(requires: USER)
  adminNotes: String @auth(requires: ADMIN)
}

type Query {
  user(id: ID!): User @cache(maxAge: 300)
  search(
    query: String! @validate(format: "^[a-zA-Z0-9 ]+$")
  ): [SearchResult!]! @rateLimit(max: 10, window: 60)
}

type Mutation {
  createUser(
    email: String! @validate(format: "email")
    password: String! @validate(format: "password")
  ): User! @rateLimit(max: 5, window: 300)
}
```

### Non-Null Types and Error Handling

Non-null types in GraphQL enforce that a field must always return a value, providing compile-time guarantees about data availability. They're denoted by the `!` symbol and ensure that clients never receive `null` for these fields.

Non-null types create a contract between your schema and clients, indicating which fields are guaranteed to be present. This enables better client-side type generation and reduces the need for null checks in client code.

Error handling in GraphQL involves balancing non-null guarantees with the reality that operations can fail. When a non-null field encounters an error, GraphQL propagates null up the response tree until it reaches a nullable field or the top level.

Strategic use of non-null types requires careful consideration of your data model and error scenarios. Over-using non-null types can cause entire queries to fail when individual fields error, while under-using them provides less type safety.

**Key points:**

- Non-null types guarantee a field will never return null
- Errors in non-null fields propagate null up the response tree
- Balance type safety with graceful error handling
- Use non-null types for fields that logically must always have values
- Consider the impact of null propagation on query results

**Example of non-null type usage:**

```graphql
type User {
  id: ID!                    # Always present
  email: String!             # Always present
  firstName: String!         # Always present
  lastName: String!          # Always present
  middleName: String         # Optional
  avatar: String             # Optional
  bio: String                # Optional
  createdAt: DateTime!       # Always present
  lastLoginAt: DateTime      # Optional (might be null for new users)
  posts: [Post!]!            # Always returns array, never null posts
  followers: [User!]!        # Always returns array, might be empty
  profile: UserProfile       # Might be null if not created
}

type UserProfile {
  user: User!                # Back-reference always present
  website: URL               # Optional
  phone: PhoneNumber         # Optional
  birthDate: Date            # Optional
  isPublic: Boolean!         # Always present, defaults to true
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!              # Always present
  publishedAt: DateTime      # Might be null for drafts
  comments: [Comment!]!      # Always returns array
  viewCount: Int!            # Always present, defaults to 0
}
```

**Example of error handling strategies:**

```graphql
type Query {
  # Nullable user allows graceful handling of "not found"
  user(id: ID!): User
  
  # Non-null array with nullable items
  users(limit: Int!): [User]!
  
  # Completely non-null for guaranteed data
  currentUser: User!
  
  # Result wrapper for explicit error handling
  userResult(id: ID!): UserResult!
}

union UserResult = User | UserNotFound | UserAccessDenied

type UserNotFound {
  message: String!
  searchedId: ID!
}

type UserAccessDenied {
  message: String!
  requiredRole: Role!
}

# Alternative approach with explicit error types
type UserResponse {
  user: User
  error: UserError
}

type UserError {
  code: ErrorCode!
  message: String!
  field: String
}

enum ErrorCode {
  USER_NOT_FOUND
  ACCESS_DENIED
  INVALID_INPUT
  INTERNAL_ERROR
}
```

**Output considerations:**

- Non-null fields that error will cause null propagation to parent objects
- Use nullable wrapper types for operations that might fail
- Consider union types for explicit error handling
- Implement proper error boundaries to prevent cascading failures
- Balance type safety with graceful degradation in client applications

**Next steps:** Implement comprehensive error handling strategies that leverage both GraphQL's built-in error system and custom error types, establish clear patterns for when to use non-null vs nullable types, and create custom scalars and directives that encapsulate your domain's specific validation and processing requirements.

---

