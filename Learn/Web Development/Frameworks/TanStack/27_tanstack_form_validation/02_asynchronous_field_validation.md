## TanStack Form — Asynchronous Field Validation

---

### Overview

Asynchronous validators extend the synchronous validation model to handle operations that require non-blocking work — server-side uniqueness checks, API lookups, debounced input evaluation, and similar patterns. TanStack Form treats async validation as a first-class concern with dedicated validator keys, built-in debounce support, and abort signal integration for cancellation.

---

### Async Validator Keys

Async validators follow the same event-trigger naming convention as sync validators, with an `Async` suffix:

| Key | Fires When |
| --- | --- |
| `onChangeAsync` | Field value changes (async) |
| `onBlurAsync` | Field loses focus (async) |
| `onSubmitAsync` | Form submit is invoked (async) |

These are defined alongside — and independently of — their sync counterparts:

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onChange: ({ value }) =>
      value.length < 3 ? 'Must be at least 3 characters' : undefined,
    onChangeAsync: async ({ value }) => {
      const taken = await checkUsernameAvailable(value)
      return taken ? 'Username is already taken' : undefined
    },
    onChangeAsyncDebounceMs: 500,
  }}
  children={(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.isValidating && <span>Checking...</span>}
      {field.state.meta.errors.length > 0 && (
        <span>{field.state.meta.errors[0]}</span>
      )}
    </div>
  )}
/>
```

**Key Points:**

- The async validator receives the same `{ value, fieldApi }` argument shape as sync validators.
- Return a string to signal an error; return `undefined` to signal valid — identical convention to sync.
- Sync and async validators for the same trigger run in sequence: sync first, then async. [Inference: if the sync validator returns an error, the async validator may still run depending on version — verify this behavior against current docs.]

---

### Debouncing with `onChangeAsyncDebounceMs`

Because `onChangeAsync` fires on every change event, running a network request per keystroke is rarely desirable. TanStack Form provides a built-in debounce option at the field level:

tsx

```tsx
validators={{
  onChangeAsync: async ({ value }) => {
    const result = await checkEmailExists(value)
    return result ? 'Email already registered' : undefined
  },
  onChangeAsyncDebounceMs: 400,
}}
```

**Key Points:**

- The debounce delay is in milliseconds.
- Each new change event resets the debounce timer. The async validator only fires after the user pauses for the specified duration.
- `onBlurAsync` and `onSubmitAsync` do not typically require debouncing — blur fires once per focus loss, and submit fires on demand.
- [Unverified: whether a global debounce option exists at the `useForm` level to apply across all fields — verify against current API docs.]

---

### Abort Signal and Cancellation

Each async validator call receives an `abortSignal` that is triggered when a newer validation supersedes the current one (e.g., the user types again before the previous async call resolves). This prevents stale responses from overwriting fresher validation state.

tsx

```tsx
validators={{
  onChangeAsync: async ({ value, signal }) => {
    const result = await fetch(`/api/check-username?q=${value}`, { signal })
    if (!result.ok) return 'Check failed'
    const data = await result.json()
    return data.taken ? 'Username is taken' : undefined
  },
  onChangeAsyncDebounceMs: 400,
}}
```

**Key Points:**

- `signal` is a standard `AbortSignal` compatible with the Fetch API and any library that accepts it (e.g., Axios via `cancelToken` adapter, TanStack Query's `signal` passthrough).
- When the signal is aborted, any in-flight `fetch` call throws an `AbortError`. This should be handled or allowed to propagate — TanStack Form [Inference] likely suppresses the error for aborted signals, but confirm for your version. Behavior is not guaranteed.
- If your async operation does not support abort signals natively, the signal can still be checked manually:

ts

```ts
onChangeAsync: async ({ value, signal }) => {
  await delay(200)
  if (signal.aborted) return undefined
  const taken = await checkUsernameAvailable(value)
  return taken ? 'Taken' : undefined
}
```

---

### `isValidating` — Indicating Pending State

While an async validator is in flight, `field.state.meta.isValidating` is `true`. Use this to show loading indicators:

tsx

```tsx
{field.state.meta.isValidating && (
  <span aria-live="polite">Checking availability…</span>
)}
```

**Key Points:**

- `isValidating` reflects the async validation lifecycle — it becomes `true` when the async call starts and `false` when it resolves or is aborted.
- Sync validators do not affect `isValidating` — it is exclusive to async operations. [Inference: confirm against your version.]
- This flag enables UX patterns like disabling the submit button while validation is pending:

tsx

```tsx
<button
  type="submit"
  disabled={form.state.isValidating || !form.state.canSubmit}
>
  Submit
</button>
```

---

### Form-Level `isValidating`

At the form level, `form.state.isValidating` aggregates the validating state across all fields. It is `true` if any field's async validator is currently running.

ts

```ts
const isAnyValidating = form.state.isValidating
```

This is useful for:

- Disabling the submit button during any pending validation
- Showing a form-wide loading indicator

---

### Error Access — Same API as Sync

Async validator errors are stored in the same `field.state.meta.errors` array and `field.state.meta.errorMap` object as sync errors. The trigger key in `errorMap` reflects the async variant:

ts

```ts
field.state.meta.errorMap.onChange    // sync onChange error
field.state.meta.errorMap.onChangeAsync  // [Unverified: key naming — verify exact errorMap keys for async triggers in your version]
```

In practice, most applications read from `errors` directly rather than keying into `errorMap` by trigger:

tsx

```tsx
{field.state.meta.errors.map((err, i) => (
  <span key={i}>{err}</span>
))}
```

---

### Combining Sync and Async Validators

Sync and async validators on the same trigger work together. The sync validator acts as a fast gate — if it fails, the async validator [Inference] may be skipped, avoiding unnecessary network calls. Confirm this short-circuit behavior against your version's docs, as it is not guaranteed.

tsx

```tsx
validators={{
  onChange: ({ value }) => {
    if (!value) return 'Required'
    if (value.length < 3) return 'Too short'
    return undefined
  },
  onChangeAsync: async ({ value, signal }) => {
    const taken = await checkUsernameAvailable(value, signal)
    return taken ? 'Already taken' : undefined
  },
  onChangeAsyncDebounceMs: 500,
}}
```

**Key Points:**

- This pattern prevents sending an API request for values that are already locally invalid.
- The sync validator gives immediate feedback; the async validator confirms server-side constraints after the debounce.

---

### Async Validation at Form Level

Form-level async validators follow the same pattern, operating on the full values object:

ts

```ts
const form = useForm({
  defaultValues: { email: '', code: '' },
  validators: {
    onSubmitAsync: async ({ value }) => {
      const valid = await verifyInviteCode(value.code, value.email)
      return valid ? undefined : 'Invalid invitation code for this email'
    },
  },
})
```

Form-level async errors are accessible via `form.state.errors`.

---

### Async Validation Flow

APIAsyncValidatorDebounceTimerFieldUserAPIAsyncValidatorDebounceTimerFieldUserisValidating = trueisValidating = falsetypes characterreset timer (onChangeAsyncDebounceMs)types another characterreset timer againdebounce elapsed — invokefetch with AbortSignalresponsereturn error string or undefinedrender error or clear

---

### Handling Async Errors Gracefully

Async validators that throw (e.g., network failure) should handle errors explicitly to avoid unresolved promise rejections:

ts

```ts
onChangeAsync: async ({ value, signal }) => {
  try {
    const taken = await checkUsernameAvailable(value, signal)
    return taken ? 'Username is taken' : undefined
  } catch (err) {
    if ((err as Error).name === 'AbortError') return undefined
    return 'Could not verify username. Try again.'
  }
}
```

**Key Points:**

- `AbortError` should be caught and returned as `undefined` — the call was intentionally cancelled, not failed.
- For genuine network errors, returning a user-facing string is preferable to letting the validator silently fail.
- [Inference] TanStack Form may not automatically surface thrown errors as field errors — an unhandled throw inside a validator could result in no error being displayed. Behavior is not guaranteed; verify for your version.

---

### Summary

| Concern | Mechanism |
| --- | --- |
| Define async validator | `onChangeAsync`, `onBlurAsync`, `onSubmitAsync` |
| Debounce change validation | `onChangeAsyncDebounceMs` (milliseconds) |
| Cancel stale requests | `signal` (`AbortSignal`) passed to validator |
| Indicate pending state | `field.state.meta.isValidating` |
| Form-wide pending state | `form.state.isValidating` |
| Access errors | `field.state.meta.errors` / `errorMap` |
| Gate async behind sync | Define both `onChange` + `onChangeAsync` |
| Handle thrown errors | `try/catch` inside the async function |

---

**Related Topics:**

- Validator adapters with async schemas (Zod `superRefine`, async `refine`)
- TanStack Query as the async validation transport layer
- `canSubmit` — how async validation state gates form submission
- Debounce strategies — per-field vs. shared utility debounce
- Race condition patterns in concurrent field validation
- Async form-level cross-field validation on submit