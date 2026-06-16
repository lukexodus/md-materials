## TanStack Form — Reset and Default Values

---

### Overview

Managing default values and reset behavior is foundational to building forms that behave predictably across creation, editing, and cancellation workflows. TanStack Form provides explicit, structured APIs for both setting initial state and restoring it on demand.

---

### Default Values

#### Setting `defaultValues`

Default values are passed at form initialization via the `defaultValues` option on `useForm`. They define the starting state of every field and serve as the reset target.

ts

```ts
const form = useForm({
  defaultValues: {
    username: '',
    email: '',
    age: 0,
    preferences: {
      newsletter: false,
      theme: 'light',
    },
  },
})
```

**Key Points:**

- `defaultValues` is typed against your form schema — TypeScript will infer field types from this object.
- Nested objects and arrays are supported.
- Fields not included in `defaultValues` will be `undefined` by default. [Inference: this may cause uncontrolled/controlled warnings in React depending on how fields are rendered; behavior may vary.]
- Default values are set once at initialization. Passing a new `defaultValues` object after mount does not automatically update field state unless a reset is triggered.

#### Lazy / Async Default Values

When editing an existing record, default values often come from an async source (e.g., an API fetch). TanStack Form supports passing `defaultValues` as a `Promise` or using an integration pattern where values are injected after the initial render.

ts

```ts
const form = useForm({
  defaultValues: async () => {
    const data = await fetchUser(userId)
    return {
      username: data.username,
      email: data.email,
    }
  },
})
```

**Key Points:**

- [Unverified] The exact async `defaultValues` signature may differ across TanStack Form versions. Confirm against the version in use. Behavior is not guaranteed to be identical across minor releases.
- A common alternative pattern is to initialize with empty defaults, then call `form.reset(fetchedValues)` once data resolves.

---

### Resetting the Form

#### `form.reset()`

The primary reset API. Calling `form.reset()` with no arguments restores all field values to `defaultValues` and clears validation state.

ts

```ts
<button type="button" onClick={() => form.reset()}>
  Cancel
</button>
```

#### `form.reset(values)` — Resetting to New Values

You can pass a new values object to `form.reset()` to both reset state and update what future resets target.

ts

```ts
const handleLoad = async () => {
  const data = await fetchUser(userId)
  form.reset({
    username: data.username,
    email: data.email,
  })
}
```

**Key Points:**

- After `form.reset(newValues)`, the new values become the baseline. A subsequent call to `form.reset()` (no args) will restore to `newValues`, not the original `defaultValues`. [Inference: this is consistent with how most form libraries handle reset targets; confirm against TanStack Form docs for your version.]
- This is the canonical pattern for populating an edit form after an async fetch.

#### What Reset Clears

When `form.reset()` is called:

| State | After Reset |
| --- | --- |
| Field values | Restored to default values |
| `isDirty` | `false` |
| `isTouched` | `false` |
| `isSubmitted` | `false` |
| Validation errors | Cleared |
| `submitCount` | [Unverified — may or may not reset; confirm per version] |

---

### Field-Level Defaults

Individual fields can also receive defaults directly via the `Field` component's `defaultValue` prop or through the parent `defaultValues`. The field-level prop takes precedence when both are provided. [Inference: standard composition behavior; verify against docs.]

tsx

```tsx
<form.Field
  name="role"
  defaultValue="viewer"
  children={(field) => (
    <select
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    >
      <option value="viewer">Viewer</option>
      <option value="editor">Editor</option>
    </select>
  )}
/>
```

---

### Reset in Edit Form Workflows

The canonical async edit pattern combines `useEffect` (or a query callback) with `form.reset()`:

ts

```ts
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

const form = useForm({
  defaultValues: {
    username: '',
    email: '',
  },
})

useEffect(() => {
  if (user) {
    form.reset({
      username: user.username,
      email: user.email,
    })
  }
}, [user])
```

**Key Points:**

- Initializing with empty strings avoids uncontrolled input warnings during the loading phase.
- `form.reset()` inside `useEffect` triggers a re-render to synchronize UI state with the fetched data.
- [Inference] If TanStack Query is used alongside TanStack Form, this pattern is the most straightforward integration path. Behavior may vary if the query refetches during active user editing.

---

### `isDirty` and Default Value Comparison

TanStack Form computes `isDirty` by comparing the current field values against `defaultValues`. This comparison is shallow by default for primitives and deep for objects/arrays. [Unverified: exact comparison strategy — deep vs. shallow — may vary; verify for nested structures in your version.]

ts

```ts
const isDirty = form.state.isDirty
```

This is useful for:

- Conditionally enabling a Save button
- Showing an unsaved-changes warning before navigation
- Disabling or enabling a Reset button based on whether anything has changed

tsx

```tsx
<button type="submit" disabled={!isDirty}>Save</button>
<button type="button" onClick={() => form.reset()} disabled={!isDirty}>Reset</button>
```

---

### Resetting Specific Fields

TanStack Form does not expose a built-in per-field reset API at the top-level `form` object in the same way as full form reset. [Unverified: a dedicated `field.reset()` method may exist in newer versions — confirm against current API docs.]

A common workaround is to use `form.setFieldValue` to restore a single field's default:

ts

```ts
form.setFieldValue('email', form.options.defaultValues?.email ?? '')
```

**Key Points:**

- This does not reset `isTouched` or `isDirty` at the field level on its own. [Inference]
- For full field-level state reset including meta (touched, errors), prefer the full `form.reset()` if acceptable in context.

---

### Controlling Reset Behavior with Options

[Unverified: The following reset option flags are present in some versions of TanStack Form but may not be stable across all releases. Verify against your installed version's changelog.]

Some form libraries expose options to `reset()` for finer control:

ts

```ts
form.reset(values, {
  keepDirty: false,
  keepTouched: false,
  keepErrors: false,
})
```

Check the TanStack Form release notes and API reference for which options are available in the version you are targeting, as this API surface has evolved.

---

### Mermaid Diagram — Reset Flow

No argsWith new valuesForm InitializeddefaultValues set asbaselineUser edits fieldsform.reset called?Restore to currentdefaultValues baselineUpdate baseline + restoreto new valuesisDirty = false, errorsclearedForm ready for nextinteraction

---

### Summary

| Concept | API / Pattern |
| --- | --- |
| Set initial state | `defaultValues` on `useForm` |
| Reset to defaults | `form.reset()` |
| Reset to new values | `form.reset(newValues)` |
| Async edit pattern | `useEffect` + `form.reset(fetchedData)` |
| Dirty check | `form.state.isDirty` |
| Single field restore | `form.setFieldValue(name, defaultVal)` |

---

**Related Topics:**

- `form.state` — full state shape and derived flags
- `isDirty`, `isTouched`, `isValid` — state flags in depth
- Validation on reset — whether validators re-run after reset
- TanStack Form + TanStack Query — async data integration patterns
- Array field defaults and reset behavior
- `form.reset()` in multi-step / wizard form flows