## GraphQL Language Basics


### Schema Definition Language (SDL)

The Schema Definition Language is GraphQL's type system definition language that allows developers to define the structure, capabilities, and contracts of a GraphQL API. SDL serves as the blueprint for your GraphQL service, describing what data can be queried and how it's organized.

SDL uses a human-readable syntax that resembles JSON but focuses on type definitions rather than data values. The schema acts as a contract between the client and server, explicitly defining what operations are available and what data structure to expect.

**Key points:**

- SDL defines the API's structure using type definitions
- It's language-agnostic and can be implemented in any programming language
- The schema serves as documentation and validation for both clients and servers
- It enables powerful tooling like code generation and IDE support

**Example:**

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  publishedAt: DateTime
}

type Query {
  user(id: ID!): User
  posts(limit: Int = 10): [Post!]!
}
```

### Types: Scalar, Object, Interface, Union, Enum

#### Scalar Types

Scalar types represent primitive data values that resolve to concrete data. GraphQL includes five built-in scalar types: `String`, `Int`, `Float`, `Boolean`, and `ID`. Custom scalar types can be defined for specific data formats like dates, URLs, or JSON.

**Key points:**

- Scalar types are the leaves of the GraphQL type system
- They cannot have sub-selections in queries
- Custom scalars require serialization and parsing logic
- They provide type safety for primitive values

**Example:**

```graphql
scalar DateTime
scalar URL
scalar JSON

type User {
  id: ID!
  name: String!
  age: Int!
  isActive: Boolean!
  lastLoginAt: DateTime
  profilePicture: URL
  metadata: JSON
}
```

#### Object Types

Object types define the shape of objects that can be fetched from your service. They contain fields that can be scalars, other objects, or lists. Object types are the most common type in GraphQL schemas and represent the entities in your domain.

**Key points:**

- Object types define the structure of complex data
- Fields can have arguments and return various types
- They support nested selections in queries
- Each field can have its own resolver function

**Example:**

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts(status: PostStatus, limit: Int = 10): [Post!]!
  followers: [User!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  tags: [String!]!
  likes: Int!
  publishedAt: DateTime
}
```

#### Interface Types

Interface types define a common set of fields that multiple object types can implement. They enable polymorphic queries where you can request fields that exist across different types while still being able to access type-specific fields through inline fragments.

**Key points:**

- Interfaces define shared fields across multiple types
- Implementing types must include all interface fields
- They enable polymorphic queries and type abstraction
- Useful for modeling hierarchical or categorized data

**Example:**

```graphql
interface Node {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
}

interface Content {
  title: String!
  author: User!
  publishedAt: DateTime
}

type Article implements Node & Content {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  title: String!
  author: User!
  publishedAt: DateTime
  content: String!
  wordCount: Int!
}

type Video implements Node & Content {
  id: ID!
  createdAt: DateTime!
  updatedAt: DateTime!
  title: String!
  author: User!
  publishedAt: DateTime
  duration: Int!
  resolution: String!
}
```

#### Union Types

Union types represent objects that could be one of several types but don't necessarily share common fields. Unlike interfaces, unions don't define any common fields. They're useful for representing heterogeneous collections or polymorphic return types.

**Key points:**

- Union types represent a choice between multiple object types
- They don't define common fields like interfaces
- Require inline fragments or fragment spreads in queries
- Useful for search results or notification systems

**Example:**

```graphql
union SearchResult = User | Post | Comment

union NotificationContent = LikeNotification | CommentNotification | FollowNotification

type LikeNotification {
  id: ID!
  user: User!
  post: Post!
  createdAt: DateTime!
}

type CommentNotification {
  id: ID!
  user: User!
  comment: Comment!
  createdAt: DateTime!
}

type Query {
  search(query: String!): [SearchResult!]!
  notifications: [NotificationContent!]!
}
```

#### Enum Types

Enum types define a finite set of possible values for a field. They provide type safety by restricting values to a predefined list and are useful for representing categories, statuses, or configuration options.

**Key points:**

- Enums define a fixed set of possible values
- They provide type safety and documentation
- Can be used as field types or input arguments
- Help prevent invalid values in your API

**Example:**

```graphql
enum PostStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
  DELETED
}

enum UserRole {
  ADMIN
  MODERATOR
  USER
  GUEST
}

enum SortDirection {
  ASC
  DESC
}

type Post {
  id: ID!
  title: String!
  status: PostStatus!
  author: User!
}

type User {
  id: ID!
  name: String!
  role: UserRole!
}

type Query {
  posts(status: PostStatus, sortBy: String, sortDirection: SortDirection): [Post!]!
}
```

### Fields, Arguments, and Aliases

#### Fields

Fields are the fundamental building blocks of GraphQL queries. They represent the specific pieces of data you want to retrieve from an object. Fields can be scalar values, other objects, or lists, and they form the hierarchical structure of your query.

**Key points:**

- Fields define what data to fetch from an object
- They can be nested to traverse object relationships
- Each field can have its own resolver function
- Fields are selected explicitly in queries

**Example:**

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  profile: UserProfile
}

type UserProfile {
  bio: String
  website: URL
  location: String
  joinedAt: DateTime!
}

# Query example
query {
  user(id: "123") {
    name
    email
    profile {
      bio
      location
    }
    posts {
      title
      publishedAt
    }
  }
}
```

#### Arguments

Arguments allow you to pass parameters to fields, enabling filtering, sorting, pagination, and customization of field behavior. Arguments can be required or optional, with default values, and they provide a way to make fields more dynamic and flexible.

**Key points:**

- Arguments parameterize field behavior
- They can be required (!) or optional with defaults
- Support various input types including scalars, enums, and input objects
- Enable filtering, sorting, and pagination

**Example:**

```graphql
type Query {
  users(
    limit: Int = 10
    offset: Int = 0
    role: UserRole
    active: Boolean = true
    search: String
  ): [User!]!
  
  user(id: ID!): User
  
  posts(
    authorId: ID
    status: PostStatus = PUBLISHED
    sortBy: PostSortField = CREATED_AT
    sortDirection: SortDirection = DESC
    first: Int
    after: String
  ): PostConnection!
}

enum PostSortField {
  CREATED_AT
  UPDATED_AT
  TITLE
  LIKES
}

input PostFilter {
  status: PostStatus
  authorId: ID
  tags: [String!]
  dateRange: DateRange
}

input DateRange {
  start: DateTime!
  end: DateTime!
}
```

#### Aliases

Aliases allow you to rename fields in your query results, enabling you to fetch the same field multiple times with different arguments or to provide more meaningful names for your client application.

**Key points:**

- Aliases rename fields in query results
- Enable fetching the same field multiple times with different arguments
- Useful for avoiding naming conflicts
- Improve query readability and client-side data handling

**Example:**

```graphql
query {
  user(id: "123") {
    id
    username: name
    publicEmail: email
    
    # Fetch posts with different statuses
    publishedPosts: posts(status: PUBLISHED, limit: 5) {
      id
      title
      publishedAt
    }
    
    draftPosts: posts(status: DRAFT, limit: 3) {
      id
      title
      updatedAt
    }
    
    # Fetch follower counts
    followerCount: followers {
      id
    }
    
    followingCount: following {
      id
    }
  }
}
```

### Introspection System

The introspection system is a powerful GraphQL feature that allows clients to query the schema itself, discovering available types, fields, arguments, and their relationships. This enables dynamic tooling, documentation generation, and runtime schema exploration.

#### Core Introspection Types

GraphQL provides several built-in types for introspection:

**Key points:**

- `__Schema`: The root introspection type containing all schema information
- `__Type`: Represents any type in the schema with detailed metadata
- `__Field`: Describes individual fields with their types and arguments
- `__InputValue`: Represents arguments and input object fields
- `__EnumValue`: Describes enum values with names and descriptions
- `__Directive`: Information about schema directives

**Example:**

```graphql
# Basic schema introspection
query {
  __schema {
    queryType {
      name
      fields {
        name
        type {
          name
          kind
        }
      }
    }
    mutationType {
      name
    }
    subscriptionType {
      name
    }
    types {
      name
      kind
      description
    }
  }
}

# Detailed type introspection
query {
  __type(name: "User") {
    name
    kind
    description
    fields {
      name
      type {
        name
        kind
        ofType {
          name
          kind
        }
      }
      args {
        name
        type {
          name
          kind
        }
        defaultValue
      }
    }
    interfaces {
      name
    }
  }
}
```

#### Practical Applications

Introspection enables powerful tooling and development workflows:

**Key points:**

- **Schema Documentation**: Automatically generate API documentation
- **IDE Support**: Enable autocomplete, validation, and syntax highlighting
- **Code Generation**: Generate type-safe client code
- **Schema Validation**: Ensure schema compatibility across versions
- **Dynamic Queries**: Build query builders and form generators

**Example:**

```graphql
# Query for building a dynamic form
query GetUserInputFields {
  __type(name: "UserInput") {
    inputFields {
      name
      type {
        name
        kind
        ofType {
          name
          kind
        }
      }
      defaultValue
    }
  }
}

# Query for API documentation
query GetAllTypes {
  __schema {
    types {
      name
      kind
      description
      fields {
        name
        description
        type {
          name
          kind
        }
        args {
          name
          description
          type {
            name
          }
          defaultValue
        }
      }
    }
  }
}
```

#### Security Considerations

While introspection is valuable for development, it can expose sensitive schema information in production:

**Key points:**

- Consider disabling introspection in production environments
- Implement query depth limiting to prevent abuse
- Use field-level permissions to control access
- Monitor introspection queries for unusual patterns

**Example:**

```graphql
# Introspection can reveal sensitive information
query {
  __schema {
    types {
      name
      fields {
        name
        # This might reveal internal field names
        # or sensitive data structures
      }
    }
  }
}
```

**Conclusion:** GraphQL's language basics provide a robust foundation for building type-safe, self-documenting APIs. The Schema Definition Language creates clear contracts between clients and servers, while the comprehensive type system enables precise data modeling. Fields, arguments, and aliases offer flexible querying capabilities, and the introspection system empowers dynamic tooling and documentation. Understanding these fundamentals is essential for effectively leveraging GraphQL's strengths in API development.

**Next steps:**

- Explore GraphQL query execution and resolvers
- Learn about GraphQL mutations and subscriptions
- Investigate schema design patterns and best practices
- Study GraphQL federation for microservices architectures

---

