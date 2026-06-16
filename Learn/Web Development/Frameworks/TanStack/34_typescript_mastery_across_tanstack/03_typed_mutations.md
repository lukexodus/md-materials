## Typed Mutations in TanStack Query

`useMutation` is the primary API for sending data-changing requests in TanStack Query. Unlike `useQuery`, mutations are triggered imperatively, which introduces distinct typing concerns around inputs, outputs, errors, and optimistic update context.

---

### `useMutation` Type Parameters

`useMutation` accepts four type parameters:

```ts
useMutation<TData, TError, TVariables, TContext>
```

| Parameter | Description |
|---|---|
| `TData` | The type returned by the mutation function on success |
| `TError` | The type of the error if the mutation fails |
| `TVariables` | The type of the argument passed to `mutate()` or `mutateAsync()` |
| `TContext` | The type of the value returned by `onMutate`, used for optimistic updates |

All four parameters are optional. When omitted, TypeScript infers them from the mutation function and callbacks where possible.

---

### Basic Inference from the Mutation Function

When the mutation function is typed, TanStack Query infers `TData` and `TVariables` automatically.

```ts
import { useMutation } from '@tanstack/react-query'

interface CreateUserInput {
  name: string
  email: string
}

interface User {
  id: number
  name: string
  email: string
}

async function createUser(input: CreateUserInput): Promise<User> {
  const res = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify(input),
    headers: { 'Content-Type': 'application/json' },
  })
  return res.json() as Promise<User>
}

function CreateUserForm() {
  const { mutate, data, isPending } = useMutation({
    mutationFn: createUser,
  })

  // mutate expects: CreateUserInput
  // data is:        User | undefined
}
```

**Key Points**
- `TData` is inferred as `User` from `createUser`'s return type
- `TVariables` is inferred as `CreateUserInput` from `createUser`'s parameter type
- `data` is `User | undefined` because it is absent before the mutation succeeds
- Inference quality depends on how precisely the mutation function is typed [Inference]

---

### Calling `mutate` and `mutateAsync`

#### `mutate` — fire and forget

```ts
const { mutate } = useMutation({ mutationFn: createUser })

// TypeScript enforces the variables type
mutate({ name: 'Ada', email: 'ada@example.com' })

// ❌ Type error: missing 'email'
mutate({ name: 'Ada' })
```

#### `mutateAsync` — returns a Promise

```ts
const { mutateAsync } = useMutation({ mutationFn: createUser })

async function handleSubmit() {
  try {
    const user = await mutateAsync({ name: 'Ada', email: 'ada@example.com' })
    // user: User  ← fully typed
    console.log(user.id)
  } catch (err) {
    // err: unknown by default
  }
}
```

**Key Points**
- `mutateAsync` resolves to `TData` directly, without `undefined`
- `mutate` does not return a value; use `onSuccess` or `onSettled` callbacks for post-mutation logic
- Errors thrown by `mutateAsync` are typed as `unknown` unless `TError` is explicitly provided or inferred [Important]

---

### Typing the Error

By default, `error` on the mutation result is typed as `Error | null` in TanStack Query v5, or `unknown | null` depending on configuration. Explicitly providing `TError` tightens this.

```ts
interface ApiError {
  status: number
  message: string
}

const { mutate, error } = useMutation<User, ApiError, CreateUserInput>({
  mutationFn: createUser,
})

if (error) {
  // error: ApiError
  console.log(error.status, error.message)
}
```

**Key Points**
- TanStack Query does not validate that thrown errors actually match `TError` at runtime — this is a type-level contract only [Important — runtime behavior is not affected by the type parameter]
- For reliable error shapes, normalize errors inside the mutation function or in a global error handler before they surface
- In v5, the global `defaultShouldDehydrateError` and `throwOnError` options affect how errors propagate, but not their TypeScript type

---

### Typing `onSuccess`, `onError`, `onSettled`

Callbacks receive fully typed arguments derived from the mutation's type parameters.

```ts
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: (data, variables, context) => {
    // data:      User
    // variables: CreateUserInput
    // context:   undefined  (no onMutate defined)
  },
  onError: (error, variables, context) => {
    // error:     Error  (default)
    // variables: CreateUserInput
    // context:   undefined
  },
  onSettled: (data, error, variables, context) => {
    // data:      User | undefined
    // error:     Error | null
    // variables: CreateUserInput
    // context:   undefined
  },
})
```

**Key Points**
- All callback parameters are inferred from the mutation function and `onMutate`
- `onSettled` receives `data` as `TData | undefined` and `error` as `TError | null`, because either may be present
- Explicit generic annotation on `useMutation` overrides inference when necessary

---

### Typing `onMutate` and the Optimistic Update Context

`onMutate` runs before the mutation function fires. Its return value becomes `TContext`, which is passed to `onError` and `onSettled` for rollback purposes.

```ts
interface Todo {
  id: number
  title: string
  completed: boolean
}

const mutation = useMutation({
  mutationFn: (newTodo: Omit<Todo, 'id'>) =>
    fetchJson<Todo>('/api/todos', { method: 'POST', body: newTodo }),

  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

    queryClient.setQueryData<Todo[]>(['todos'], (old = []) => [
      ...old,
      { id: Date.now(), ...newTodo },
    ])

    return { previousTodos }
    // Return type inferred as: { previousTodos: Todo[] | undefined }
    // This becomes TContext
  },

  onError: (error, variables, context) => {
    // context: { previousTodos: Todo[] | undefined }
    if (context?.previousTodos) {
      queryClient.setQueryData(['todos'], context.previousTodos)
    }
  },

  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Key Points**
- `TContext` is inferred from `onMutate`'s return type — no manual annotation required if the function is typed
- If `onMutate` is not provided, `TContext` defaults to `undefined`
- `context` in `onError` and `onSettled` is `TContext | undefined` because `onMutate` may fail before returning

---

### Explicit Generic Annotation

When inference is insufficient, annotate generics directly.

```ts
const mutation = useMutation<User, ApiError, CreateUserInput, { previousUsers: User[] }>({
  mutationFn: createUser,
  onMutate: (variables) => {
    // variables: CreateUserInput
    const previousUsers = queryClient.getQueryData<User[]>(['users']) ?? []
    return { previousUsers }
  },
  onError: (error, _variables, context) => {
    // error:   ApiError
    // context: { previousUsers: User[] } | undefined
  },
})
```

Use explicit annotation when:
- The mutation function is from an external library with imprecise types
- You want to enforce a specific `TError` shape independent of what is thrown
- `onMutate`'s return type cannot be inferred cleanly

---

### Mutation Variables with Optional Fields

When some fields are optional, define the variables type explicitly to avoid inference ambiguity.

```ts
interface UpdateUserInput {
  id: number
  name?: string
  email?: string
}

const mutation = useMutation({
  mutationFn: (input: UpdateUserInput) =>
    fetchJson<User>(`/api/users/${input.id}`, {
      method: 'PATCH',
      body: input,
    }),
})

// mutate correctly accepts partial updates
mutation.mutate({ id: 42, name: 'Updated Name' })
```

---

### Reusing Mutation Definitions with `mutationOptions`

Similar to `queryOptions`, you can define reusable mutation option objects. As of TanStack Query v5, there is no built-in `mutationOptions` helper equivalent to `queryOptions`, but you can define a typed factory manually. [Inference — based on v5 API surface; verify against current documentation]

```ts
import type { MutationOptions } from '@tanstack/react-query'

function createUserMutationOptions(
  queryClient: QueryClient
): MutationOptions<User, ApiError, CreateUserInput> {
  return {
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  }
}

// In component
const mutation = useMutation(createUserMutationOptions(queryClient))
```

**Key Points**
- `MutationOptions` is the type to use for the options object shape
- This pattern colocates mutation logic and keeps components thin
- Reusing the same options object across components does not share state — each `useMutation` call creates an independent mutation instance [Important]

---

### Typing `mutate` Callbacks at the Call Site

`mutate` and `mutateAsync` accept optional per-call callbacks. These are also typed.

```ts
mutation.mutate(
  { name: 'Ada', email: 'ada@example.com' },
  {
    onSuccess: (data) => {
      // data: User
      navigate(`/users/${data.id}`)
    },
    onError: (error) => {
      // error: Error (or TError if annotated)
      toast.error(error.message)
    },
  }
)
```

**Key Points**
- Per-call callbacks run in addition to, not instead of, the callbacks defined on `useMutation`
- The types of `data` and `error` in per-call callbacks match the mutation's inferred or annotated type parameters
- Per-call `onSuccess` callbacks do not fire if the component unmounts before the mutation resolves [Important — runtime behavior, not type-level]

---

### Summary of Type Flow

```
mutationFn: (variables: TVariables) => Promise<TData>
                  │                          │
                  ▼                          ▼
        mutate(variables)            data / onSuccess(data)
        TVariables enforced          TData inferred

onMutate: (variables) => TContext
                               │
                               ▼
               onError(error, variables, context: TContext)
               onSettled(data, error, variables, context: TContext)
```

---

**Related Topics**
- Optimistic updates with full rollback typing
- Global mutation defaults and typed `MutationCache` observers
- Integrating Zod for runtime validation of mutation inputs and outputs
- Typing `useIsMutating` and mutation filters
- Combining `useMutation` with TanStack Form for end-to-end typed form submission
- Error normalization patterns for consistent `TError` shapes across mutations
- `mutateAsync` in server actions and TanStack Router action handlers