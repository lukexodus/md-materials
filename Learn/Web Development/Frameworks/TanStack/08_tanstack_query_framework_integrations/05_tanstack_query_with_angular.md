## TanStack Query with Angular

TanStack Query provides an Angular adapter — `@tanstack/angular-query-experimental` — that integrates with Angular's dependency injection system, signals, and change detection. As the package name indicates, the Angular adapter is currently marked experimental. The API surface is functional and usable in production applications, but breaking changes are more likely than in the stable React adapter. [Unverified: the experimental designation may have changed in recent releases — verify the current package name and stability status before adopting.]

---

### Installation

```bash
npm install @tanstack/angular-query-experimental
```

For DevTools:

```bash
npm install @tanstack/angular-query-devtools-experimental
```

---

### Initial Setup

Angular's adapter uses Angular's dependency injection (DI) system rather than a component tree provider. The `QueryClient` is provided at the application level.

#### Standalone Application Setup (Angular 17+)

```ts
// main.ts
import { bootstrapApplication } from '@angular/platform-browser'
import { provideHttpClient } from '@angular/common/http'
import { QueryClient, provideAngularQuery } from '@tanstack/angular-query-experimental'
import { AppComponent } from './app/app.component'

bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient(),
    provideAngularQuery(new QueryClient()),
  ],
})
```

#### NgModule Setup

```ts
// app.module.ts
import { NgModule } from '@angular/core'
import { BrowserModule } from '@angular/platform-browser'
import { QueryClient, provideAngularQuery } from '@tanstack/angular-query-experimental'
import { AppComponent } from './app.component'

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule],
  providers: [
    provideAngularQuery(new QueryClient()),
  ],
  bootstrap: [AppComponent],
})
export class AppModule {}
```

**Key Points:**
- `provideAngularQuery` registers the `QueryClient` as an Angular provider — it is available for injection throughout the application.
- No wrapper component (`QueryClientProvider`) is needed — DI replaces the context pattern used in React and Svelte.
- `provideHttpClient()` is not required by TanStack Query itself, but is typically needed alongside it for HTTP requests.

---

### Core Difference: Angular Signals

The Angular adapter is built on **Angular Signals** (introduced in Angular 16, stabilized in Angular 17). Returned query and mutation results are signals — you read them by calling them as functions.

```ts
// React adapter — plain value
const { data, isPending } = useQuery(...)
console.log(data)

// Angular adapter — signal
const query = injectQuery(...)
console.log(query().data)       // Call the signal to read its value
```

In templates, Angular's signal syntax is the same:

```html
<!-- Angular template -->
@if (query().isPending) {
  <p>Loading...</p>
}
<p>{{ query().data?.name }}</p>
```

**Key Points:**
- Every access to query state — `query().data`, `query().isPending`, `query().isError` — requires the function-call syntax.
- Signal reads inside Angular's template or `computed()` automatically establish reactive dependencies without manual subscription.
- Angular's change detection integrates with signals natively in Angular 17+ (`zoneless` and `OnPush` strategies both work correctly). [Inference: behavior with legacy Zone.js-based change detection may differ — verify for your Angular version.]

---

### injectQuery — Fetching Data

The Angular equivalent of `useQuery` is `injectQuery`. It must be called in an **injection context** — typically the constructor body or a field initializer in a component or service.

```ts
import { Component, inject } from '@angular/core'
import { injectQuery } from '@tanstack/angular-query-experimental'
import { HttpClient } from '@angular/common/http'
import { firstValueFrom } from 'rxjs'

@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `
    @if (query().isPending) {
      <p>Loading...</p>
    } @else if (query().isError) {
      <p>Error: {{ query().error?.message }}</p>
    } @else {
      <p>{{ query().data?.name }}</p>
    }
  `,
})
export class UserProfileComponent {
  private http = inject(HttpClient)

  query = injectQuery(() => ({
    queryKey: ['user', '123'],
    queryFn: () =>
      firstValueFrom(this.http.get<User>('/api/users/123')),
  }))
}
```

**Key Points:**
- `injectQuery` takes a **function** returning the options object — same reactive pattern as the Solid and Svelte 5 adapters.
- The options function is a reactive computation. Signal reads inside it (such as component signals or injected services) establish reactive dependencies.
- `injectQuery` must be called in an injection context. Calling it inside a method that runs after construction will throw an error. [Inference: Angular's `runInInjectionContext` utility can work around this in some cases — verify for your use case.]
- Angular's `HttpClient` returns Observables. `firstValueFrom` (from RxJS) converts them to promises, which `queryFn` requires.

---

### RxJS Interop

Angular applications typically use RxJS Observables for HTTP. TanStack Query requires promises. The standard bridge is `firstValueFrom` or `lastValueFrom` from RxJS.

```ts
import { firstValueFrom, lastValueFrom } from 'rxjs'

// firstValueFrom — resolves when the Observable emits its first value
queryFn: () => firstValueFrom(this.http.get<User>('/api/users/123'))

// lastValueFrom — resolves when the Observable completes
queryFn: () => lastValueFrom(this.http.get<User>('/api/users/123'))
```

**Key Points:**
- `HttpClient` observables complete after emitting one value, so `firstValueFrom` and `lastValueFrom` are equivalent for standard HTTP calls.
- `firstValueFrom` rejects if the Observable completes without emitting — handle this if using filtered or conditional streams. [Inference: for standard `HttpClient` GET/POST calls this is not a practical concern.]
- Do not pass an Observable directly as `queryFn` — it must return a Promise.

---

### Dynamic Query Keys with Signals

Signals are the natural way to make query keys reactive to component state.

```ts
import { Component, signal, inject } from '@angular/core'
import { injectQuery } from '@tanstack/angular-query-experimental'
import { HttpClient } from '@angular/common/http'
import { firstValueFrom } from 'rxjs'

@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `
    <button (click)="userId.set('456')">Switch User</button>

    @if (query().isPending) {
      <p>Loading...</p>
    } @else {
      <p>{{ query().data?.name }}</p>
    }
  `,
})
export class UserProfileComponent {
  private http = inject(HttpClient)

  userId = signal('123')

  query = injectQuery(() => ({
    queryKey: ['user', this.userId()],
    queryFn: () =>
      firstValueFrom(
        this.http.get<User>(`/api/users/${this.userId()}`)
      ),
  }))
}
```

**Key Points:**
- `this.userId()` is read inside the reactive options function. When the signal changes, the options function re-runs, updating the query key and triggering a new fetch.
- Both the `queryKey` and `queryFn` should reference `this.userId()` consistently to avoid stale closure bugs.

---

### injectQuery Options

All standard TanStack Query options are supported inside the reactive options function.

```ts
query = injectQuery(() => ({
  queryKey: ['todos', this.filters()],
  queryFn: () => firstValueFrom(this.http.get<Todo[]>('/api/todos')),

  staleTime: 1000 * 60 * 5,
  gcTime: 1000 * 60 * 10,
  refetchOnWindowFocus: true,
  retry: 3,
  enabled: !!this.userId(),
  select: (data) => data.filter(todo => !todo.completed),
  placeholderData: keepPreviousData,
}))
```

#### The `enabled` Option with Signals

```ts
userId = signal<string | null>(null)

query = injectQuery(() => ({
  queryKey: ['user', this.userId()],
  queryFn: () =>
    firstValueFrom(this.http.get<User>(`/api/users/${this.userId()}`)),
  enabled: !!this.userId(),
}))
```

**Key Points:**
- `enabled: !!this.userId()` reads the signal inside the reactive options function — when `userId` becomes non-null, `enabled` becomes `true` and the query fires automatically.
- This is the standard pattern for dependent queries in the Angular adapter.

---

### Dependent Queries

```ts
@Component({
  selector: 'app-user-projects',
  standalone: true,
  template: `
    @if (projectsQuery().isPending) {
      <p>Loading projects...</p>
    } @else {
      @for (project of projectsQuery().data ?? []; track project.id) {
        <p>{{ project.name }}</p>
      }
    }
  `,
})
export class UserProjectsComponent {
  private http = inject(HttpClient)

  userQuery = injectQuery(() => ({
    queryKey: ['user'],
    queryFn: () => firstValueFrom(this.http.get<User>('/api/me')),
  }))

  projectsQuery = injectQuery(() => ({
    queryKey: ['projects', this.userQuery().data?.id],
    queryFn: () =>
      firstValueFrom(
        this.http.get<Project[]>(`/api/projects/${this.userQuery().data!.id}`)
      ),
    enabled: !!this.userQuery().data?.id,
  }))
}
```

**Key Points:**
- `this.userQuery().data?.id` reads the signal inside the reactive options function, establishing a dependency on `userQuery`'s result.
- When `userQuery` resolves and `data.id` becomes available, `projectsQuery` automatically reconfigures and fires.

---

### injectMutation — Writing Data

The Angular equivalent of `useMutation` is `injectMutation`.

```ts
import { Component, inject } from '@angular/core'
import { injectMutation, injectQueryClient } from '@tanstack/angular-query-experimental'
import { HttpClient } from '@angular/common/http'
import { firstValueFrom } from 'rxjs'

@Component({
  selector: 'app-add-todo',
  standalone: true,
  template: `
    <button
      (click)="addTodo()"
      [disabled]="mutation().isPending"
    >
      {{ mutation().isPending ? 'Adding...' : 'Add Todo' }}
    </button>
  `,
})
export class AddTodoComponent {
  private http = inject(HttpClient)
  private queryClient = injectQueryClient()

  mutation = injectMutation(() => ({
    mutationFn: (newTodo: { title: string }) =>
      firstValueFrom(
        this.http.post<Todo>('/api/todos', newTodo)
      ),

    onSuccess: () => {
      this.queryClient.invalidateQueries({ queryKey: ['todos'] })
    },

    onError: (error) => {
      console.error('Mutation failed:', error)
    },
  }))

  addTodo() {
    this.mutation().mutate({ title: 'New Task' })
  }
}
```

**Key Points:**
- `injectMutation` takes a function returning the options object — same pattern as `injectQuery`.
- `mutation()` is a signal — call it to read the current mutation state before accessing `.isPending`, `.mutate()`, etc.
- `injectQueryClient()` is the Angular DI equivalent of `useQueryClient()`.
- `this.mutation().mutate()` calls the mutation imperatively from an event handler.

---

### injectQueryClient

`injectQueryClient` retrieves the `QueryClient` registered via `provideAngularQuery`.

```ts
import { injectQueryClient } from '@tanstack/angular-query-experimental'

@Component({ ... })
export class MyComponent {
  private queryClient = injectQueryClient()

  refresh() {
    this.queryClient.invalidateQueries({ queryKey: ['todos'] })
  }

  readCache() {
    return this.queryClient.getQueryData(['todos'])
  }

  writeCache(data: Todo[]) {
    this.queryClient.setQueryData(['todos'], data)
  }
}
```

**Key Points:**
- `injectQueryClient` must be called in an injection context — typically a field initializer or constructor.
- The returned `QueryClient` is the same instance registered at application startup.

---

### Optimistic Updates

```ts
mutation = injectMutation(() => ({
  mutationFn: (updatedTodo: Todo) =>
    firstValueFrom(
      this.http.put<Todo>(`/api/todos/${updatedTodo.id}`, updatedTodo)
    ),

  onMutate: async (updatedTodo) => {
    await this.queryClient.cancelQueries({ queryKey: ['todos'] })

    const previousTodos = this.queryClient.getQueryData<Todo[]>(['todos'])

    this.queryClient.setQueryData<Todo[]>(['todos'], (old = []) =>
      old.map(todo =>
        todo.id === updatedTodo.id ? { ...todo, ...updatedTodo } : todo
      )
    )

    return { previousTodos }
  },

  onError: (_err, _vars, context) => {
    this.queryClient.setQueryData(['todos'], context?.previousTodos)
  },

  onSettled: () => {
    this.queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
}))
```

---

### Pagination

```ts
@Component({
  selector: 'app-paginated-list',
  standalone: true,
  template: `
    @if (query().isPending) {
      <p>Loading...</p>
    } @else {
      @for (item of query().data?.items ?? []; track item.id) {
        <p>{{ item.name }}</p>
      }
    }

    <button (click)="prevPage()" [disabled]="page() === 1">Previous</button>
    <button
      (click)="nextPage()"
      [disabled]="query().isPlaceholderData || !query().data?.hasMore"
    >
      Next
    </button>
  `,
})
export class PaginatedListComponent {
  private http = inject(HttpClient)

  page = signal(1)

  query = injectQuery(() => ({
    queryKey: ['items', this.page()],
    queryFn: () =>
      firstValueFrom(
        this.http.get<PagedResult>(`/api/items?page=${this.page()}`)
      ),
    placeholderData: keepPreviousData,
  }))

  prevPage() { this.page.update(p => p - 1) }
  nextPage() { this.page.update(p => p + 1) }
}
```

**Key Points:**
- `this.page()` is a signal read inside the reactive options function — when it changes, the query key updates and a new fetch fires.
- `query().isPlaceholderData` is `true` while transitioning to a new page, useful for disabling the Next button.
- `signal.update()` is the Angular Signals mutation helper.

---

### Infinite Queries

```ts
@Component({
  selector: 'app-infinite-list',
  standalone: true,
  template: `
    @for (page of query().data?.pages ?? []; track $index) {
      @for (item of page.items; track item.id) {
        <div>{{ item.name }}</div>
      }
    }

    <button
      (click)="query().fetchNextPage()"
      [disabled]="!query().hasNextPage || query().isFetchingNextPage"
    >
      {{ query().isFetchingNextPage ? 'Loading more...' : 'Load More' }}
    </button>
  `,
})
export class InfiniteListComponent {
  private http = inject(HttpClient)

  query = injectInfiniteQuery(() => ({
    queryKey: ['items'],
    queryFn: ({ pageParam }) =>
      firstValueFrom(
        this.http.get<PagedResult>(`/api/items?cursor=${pageParam}`)
      ),
    initialPageParam: 0,
    getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
  }))
}
```

**Key Points:**
- `injectInfiniteQuery` is the Angular equivalent of `useInfiniteQuery`.
- `query().fetchNextPage()` is called through the signal — remember the function-call syntax.
- `data?.pages` may be `undefined` before the first fetch — guard with `?? []`.

---

### Error Handling

#### Per-Query

```html
@if (query().isError) {
  <p>Error: {{ query().error?.message }}</p>
}
```

#### Global via QueryClient Configuration

```ts
bootstrapApplication(AppComponent, {
  providers: [
    provideAngularQuery(
      new QueryClient({
        queryCache: new QueryCache({
          onError: (error, query) => {
            console.error(`Query failed:`, error)
          },
        }),
        mutationCache: new MutationCache({
          onError: (error) => {
            console.error(`Mutation failed:`, error)
          },
        }),
      })
    ),
  ],
})
```

---

### TypeScript Integration

Type inference flows from `queryFn` as in all other adapters.

```ts
type User = { id: string; name: string }

// query().data inferred as User | undefined
query = injectQuery(() => ({
  queryKey: ['user', this.userId()],
  queryFn: (): Promise<User> =>
    firstValueFrom(this.http.get<User>(`/api/users/${this.userId()}`)),
}))

// Explicit error typing
query = injectQuery<User, HttpErrorResponse>(() => ({
  queryKey: ['user', this.userId()],
  queryFn: () =>
    firstValueFrom(this.http.get<User>(`/api/users/${this.userId()}`)),
}))
// query().error is typed as HttpErrorResponse | null
```

**Key Points:**
- Angular's `HttpClient` uses `HttpErrorResponse` as its error type — a useful explicit type parameter for the second generic.
- TypeScript strict mode is recommended and fully supported.

---

### Using injectQuery in Services

Because `injectQuery` works in any injection context, queries can be encapsulated in Angular services — a clean separation-of-concerns pattern.

```ts
// user.service.ts
import { Injectable, inject, signal } from '@angular/core'
import { injectQuery } from '@tanstack/angular-query-experimental'
import { HttpClient } from '@angular/common/http'
import { firstValueFrom } from 'rxjs'

@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient)

  private userId = signal('123')

  userQuery = injectQuery(() => ({
    queryKey: ['user', this.userId()],
    queryFn: () =>
      firstValueFrom(this.http.get<User>(`/api/users/${this.userId()}`)),
  }))

  setUserId(id: string) {
    this.userId.set(id)
  }
}
```

```ts
// user-profile.component.ts
@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `
    <p>{{ userService.userQuery().data?.name }}</p>
  `,
})
export class UserProfileComponent {
  userService = inject(UserService)
}
```

**Key Points:**
- Services are valid injection contexts — `injectQuery`, `injectMutation`, and `injectQueryClient` can all be called in service field initializers.
- This pattern centralizes query logic and makes it reusable across multiple components.
- [Inference] Since the service is `providedIn: 'root'`, the query is shared across all consumers — cache and state are global. Scoped providers behave differently.

---

### DevTools

```ts
// app.component.ts
import { Component } from '@angular/core'
import { AngularQueryDevtools } from '@tanstack/angular-query-devtools-experimental'

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [AngularQueryDevtools],
  template: `
    <router-outlet />
    <angular-query-devtools initialIsOpen="false" />
  `,
})
export class AppComponent {}
```

**Key Points:**
- `AngularQueryDevtools` is an Angular-native component imported as a standalone component.
- It is registered in the `imports` array of the component that hosts it, typically the root `AppComponent`.
- [Inference] Excluding DevTools from production builds depends on your bundler configuration — verify this for your setup.

---

### Framework Adapter Comparison

| Concern | React | Solid | Svelte 5 | Angular |
|---|---|---|---|---|
| Primitive name | `useQuery` | `createQuery` | `createQuery` | `injectQuery` |
| Setup mechanism | `QueryClientProvider` | `QueryClientProvider` | `QueryClientProvider` | `provideAngularQuery` |
| Options argument | Plain object | Reactive function | Reactive function | Reactive function |
| Return type | Plain values | Reactive properties | Reactive object | Signal |
| Read syntax | `data` | `query.data` | `query.data` | `query().data` |
| QueryClient access | `useQueryClient()` | `useQueryClient()` | `useQueryClient()` | `injectQueryClient()` |
| Mutation primitive | `useMutation` | `createMutation` | `createMutation` | `injectMutation` |
| Reactivity model | Re-render | Signals | Runes | Angular Signals |
| HTTP interop | Native promises / fetch | Native promises / fetch | Native promises / fetch | RxJS → Promise |

---

**Related Topics:**
- Angular Signals deep dive — `signal`, `computed`, `effect`
- RxJS interop — `firstValueFrom`, `lastValueFrom`, `toSignal`
- TanStack Query with Angular SSR and Angular Universal
- Using `injectQuery` in Angular route resolvers
- `OnPush` change detection and zoneless Angular with TanStack Query
- Testing `injectQuery` with Angular Testing Library and `TestBed`
- TanStack Query with Vue (`@tanstack/vue-query`)
- Comparing TanStack Query with NgRx and Akita for server state management