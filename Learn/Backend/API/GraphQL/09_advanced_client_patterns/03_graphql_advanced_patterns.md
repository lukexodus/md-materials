## GraphQL Advanced Patterns


### Fragment Composition

Fragment composition is a powerful technique for building reusable, modular GraphQL queries by breaking them into smaller, composable pieces. This approach promotes code reuse, maintainability, and consistency across your application.

Fragments allow you to define reusable units of fields that can be included in multiple queries or mutations. When composing fragments, you can create a hierarchy where base fragments contain common fields and specialized fragments extend or combine them for specific use cases.

**Key points:**

- Fragments reduce duplication by centralizing field definitions
- They enable consistent data fetching patterns across components
- Fragment composition supports inheritance-like patterns
- Changes to fragment definitions automatically propagate to all consuming queries

**Example:**

```graphql
fragment UserBasicInfo on User {
  id
  name
  email
}

fragment UserProfile on User {
  ...UserBasicInfo
  avatar
  bio
  createdAt
}

fragment UserWithPosts on User {
  ...UserProfile
  posts {
    id
    title
    publishedAt
  }
}

query GetUserDashboard($userId: ID!) {
  user(id: $userId) {
    ...UserWithPosts
    followers {
      ...UserBasicInfo
    }
  }
}
```

Advanced composition techniques include conditional fragments using type conditions, fragment variables for dynamic field selection, and co-location patterns where fragments are defined near the components that use them.

### Code Generation Tools

Code generation tools transform GraphQL schemas and operations into type-safe code, dramatically improving developer experience and reducing runtime errors. These tools analyze your GraphQL schema and generate TypeScript types, React hooks, and other language-specific artifacts.

Popular tools include GraphQL Code Generator, Apollo CLI, and Relay Compiler. Each offers different approaches to code generation, from simple type generation to full-featured client code with optimizations.

**Key points:**

- Generates TypeScript types from GraphQL schemas automatically
- Creates type-safe hooks and utilities for frontend frameworks
- Provides compile-time validation of queries against schemas
- Supports custom plugins for specialized code generation needs

**Example:**

```yaml
# codegen.yml
overwrite: true
schema: "http://localhost:4000/graphql"
documents: "src/**/*.graphql"
generates:
  src/generated/graphql.ts:
    plugins:
      - typescript
      - typescript-operations
      - typescript-react-apollo
    config:
      withHooks: true
      withHOC: false
      withComponent: false
```

**Output:**

```typescript
export type GetUserQueryVariables = Exact<{
  userId: Scalars['ID'];
}>;

export type GetUserQuery = {
  user?: {
    id: string;
    name: string;
    email: string;
    posts: Array<{
      id: string;
      title: string;
      publishedAt: string;
    }>;
  };
};

export function useGetUserQuery(
  baseOptions: Apollo.QueryHookOptions<GetUserQuery, GetUserQueryVariables>
) {
  return Apollo.useQuery<GetUserQuery, GetUserQueryVariables>(
    GetUserDocument,
    baseOptions
  );
}
```

### Type-Safe Operations

Type-safe operations ensure that GraphQL queries, mutations, and subscriptions are validated at compile time, preventing runtime errors and improving code reliability. This involves leveraging TypeScript's type system to validate query variables, response shapes, and field selections.

Modern GraphQL clients provide sophisticated type inference that can detect mismatches between your queries and schema, invalid field selections, and incorrect variable types before your code runs.

**Key points:**

- Compile-time validation prevents runtime GraphQL errors
- IDE support includes autocomplete and error highlighting
- Type narrowing enables safe field access in response handlers
- Generic utilities can be created for common operation patterns

**Example:**

```typescript
// Type-safe query with proper error handling
const useUserProfile = (userId: string) => {
  const { data, loading, error } = useGetUserQuery({
    variables: { userId },
    errorPolicy: 'all'
  });

  // TypeScript knows the exact shape of data
  const user = data?.user;
  
  return {
    user,
    loading,
    error,
    hasProfile: user?.bio !== null,
    postCount: user?.posts?.length ?? 0
  };
};

// Type-safe mutation with proper variable typing
const useUpdateUser = () => {
  const [updateUserMutation] = useUpdateUserMutation();

  return useCallback(async (input: UpdateUserInput) => {
    try {
      const { data } = await updateUserMutation({
        variables: { input },
        update: (cache, { data }) => {
          if (data?.updateUser) {
            cache.writeFragment({
              id: cache.identify(data.updateUser),
              fragment: UserProfileFragmentDoc,
              data: data.updateUser
            });
          }
        }
      });
      return data?.updateUser;
    } catch (error) {
      // Error handling with proper typing
      throw new Error(`Failed to update user: ${error.message}`);
    }
  }, [updateUserMutation]);
};
```

### Custom Hooks and Utilities

Custom hooks and utilities encapsulate complex GraphQL operations, caching logic, and state management patterns into reusable abstractions. They provide higher-level APIs that hide implementation details and promote consistent usage patterns across your application.

These custom abstractions can handle common scenarios like pagination, optimistic updates, error handling, and cache management while maintaining type safety and providing clean APIs for components.

**Key points:**

- Abstract complex GraphQL operations into simple, reusable interfaces
- Encapsulate caching strategies and error handling logic
- Provide consistent APIs for common data fetching patterns
- Enable easier testing and mocking of GraphQL operations

**Example:**

```typescript
// Custom hook for paginated data fetching
const usePaginatedPosts = (filters: PostFilters) => {
  const { data, loading, error, fetchMore } = useGetPostsQuery({
    variables: { 
      first: 10, 
      filters 
    },
    notifyOnNetworkStatusChange: true
  });

  const loadMore = useCallback(async () => {
    if (!data?.posts.pageInfo.hasNextPage) return;

    await fetchMore({
      variables: {
        after: data.posts.pageInfo.endCursor
      },
      updateQuery: (prev, { fetchMoreResult }) => {
        if (!fetchMoreResult) return prev;
        return {
          posts: {
            ...fetchMoreResult.posts,
            edges: [
              ...prev.posts.edges,
              ...fetchMoreResult.posts.edges
            ]
          }
        };
      }
    });
  }, [data, fetchMore]);

  return {
    posts: data?.posts.edges.map(edge => edge.node) ?? [],
    loading,
    error,
    loadMore,
    hasMore: data?.posts.pageInfo.hasNextPage ?? false
  };
};

// Custom utility for optimistic updates
const useOptimisticMutation = <TData, TVariables>(
  mutation: DocumentNode,
  options: {
    optimisticResponse: (variables: TVariables) => TData;
    update: MutationUpdaterFunction<TData, TVariables>;
  }
) => {
  const [mutate, { loading, error }] = useMutation<TData, TVariables>(
    mutation,
    {
      optimisticResponse: options.optimisticResponse,
      update: options.update,
      errorPolicy: 'all'
    }
  );

  const safeMutate = useCallback(async (variables: TVariables) => {
    try {
      const result = await mutate({ variables });
      return result.data;
    } catch (err) {
      // Handle optimistic update rollback
      console.error('Mutation failed, rolling back optimistic update:', err);
      throw err;
    }
  }, [mutate]);

  return { mutate: safeMutate, loading, error };
};
```

These advanced patterns work together to create robust, maintainable GraphQL applications. Fragment composition provides the foundation for reusable queries, code generation ensures type safety, and custom hooks abstract complex operations into clean APIs.

**Related topics:** GraphQL caching strategies, schema federation patterns, real-time subscriptions with GraphQL, GraphQL security best practices, and performance optimization techniques.

---

