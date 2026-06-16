## TanStack Form — Core Concepts — Form Submission Handling

---

### What Submission Handling Covers

Form submission in TanStack Form encompasses:

- Triggering the submit flow
- Running submit-time validation across all fields
- Executing the async or sync `onSubmit` handler
- Handling submission failures via `onSubmitInvalid`
- Tracking submission lifecycle state (`isSubmitting`, `isSubmitted`, `submitCount`)
- Preventing duplicate submissions
- Resetting after submission

TanStack Form treats submission as an async-first operation. Even synchronous submit handlers are wrapped in the same lifecycle.

---

### Wiring the Submit Trigger

The form's native `submit` event must be intercepted and routed through TanStack Form's `handleSubmit`.

tsx

```tsx
const form = useForm({
  defaultValues: { email: '', password: '' },
  onSubmit: async ({ value }) => {
    await submitToServer(value)
  },
})

return (
  <form
    onSubmit={(e) => {
      e.preventDefault()
      form.handleSubmit()
    }}
  >
    {/* fields */}
    <button type="submit">Submit</button>
  </form>
)
```

**Key Points:**

- `e.preventDefault()` is required — TanStack Form does not call it automatically
- `form.handleSubmit()` initiates the full submission pipeline: validation → `onSubmit`
- `handleSubmit` returns a Promise — you can `await` it if you need post-submit logic in the event handler [Inference: verify return type in current docs]
- Triggering `form.handleSubmit()` programmatically (e.g., from a button `onClick`) is also valid when a native `<form>` element is not used

---

### The `onSubmit` Handler

`onSubmit` is defined in `useForm` options. It receives a context object containing the current form values and the form API.

tsx

```tsx
const form = useForm({
  defaultValues: {
    username: '',
    email: '',
  },
  onSubmit: async ({ value, formApi }) => {
    // value — the current form values, typed to defaultValues shape
    // formApi — the full form instance
    await api.createUser(value)
  },
})
```

**Key Points:**

- `value` is a snapshot of `form.state.values` at submit time — it reflects the last `handleChange` call for each field
- `formApi` gives access to `form.reset()`, `form.setFieldValue()`, and other imperative methods from within the handler
- The handler is always `async`-safe — returning a Promise is fully supported and `isSubmitting` stays `true` until the Promise resolves or rejects
- Errors thrown inside `onSubmit` are not automatically caught by TanStack Form — wrap in `try/catch` for error handling [Inference: verify whether TanStack Form catches and surfaces thrown errors internally in current version]

---

### Submit-Time Validation

When `form.handleSubmit()` is called, TanStack Form runs all `onSubmit` validators defined on fields before executing the `onSubmit` handler. If any field fails its `onSubmit` validator, the handler is not called.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onSubmit: ({ value }) =>
      !value.includes('@') ? 'Valid email required' : undefined,
  }}
>
  {(field) => (
    <div>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
      />
      {field.state.meta.errors.length > 0 && (
        <p>{field.state.meta.errors[0]}</p>
      )}
    </div>
  )}
</form.Field>
```

**Key Points:**

- `onSubmit` validators fire only when the form is submitted — not during typing or blur
- They are additive with `onChange` and `onBlur` validators — all three can coexist on the same field
- If submit-time validation fails, `onSubmitInvalid` is called instead of `onSubmit`
- All fields' `onSubmit` validators run before the handler, even if the first field already fails [Inference: verify whether validation is short-circuited or exhaustive across all fields]

#### Async Submit-Time Validation

tsx

```tsx
<form.Field
  name="username"
  validators={{
    onSubmitAsync: async ({ value }) => {
      const taken = await checkUsernameTaken(value)
      return taken ? 'Username already taken' : undefined
    },
  }}
>
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

**Key Points:**

- `onSubmitAsync` runs at submit time and the form waits for it to resolve before proceeding
- `isSubmitting` remains `true` while async validators are pending
- Async validators on multiple fields may run concurrently [Inference: verify concurrency behavior in current docs]

---

### `onSubmitInvalid`

When submit-time validation fails, TanStack Form calls `onSubmitInvalid` instead of `onSubmit`. This is defined at the form level.

tsx

```tsx
const form = useForm({
  defaultValues: { email: '' },
  onSubmit: async ({ value }) => {
    await api.submit(value)
  },
  onSubmitInvalid: ({ value, formApi }) => {
    console.warn('Submission blocked — validation errors present', formApi.state.errors)
    // Scroll to first error, show a toast, etc.
  },
})
```

**Key Points:**

- `onSubmitInvalid` is optional — if omitted, failed validation simply prevents submission silently (errors remain visible in field state)
- It receives the same `{ value, formApi }` shape as `onSubmit`
- Common uses: scrolling to the first errored field, logging, showing a global error banner

---

### Submission Lifecycle State

TanStack Form exposes three flags that track submission progress:

| State | Type | Meaning |
| --- | --- | --- |
| `isSubmitting` | `boolean` | `true` while `onSubmit` (or async validators) are running |
| `isSubmitted` | `boolean` | `true` after the first completed submission attempt |
| `submitCount` | `number` | Increments on every `handleSubmit()` call |

tsx

```tsx
<form.Subscribe
  selector={(state) => ({
    isSubmitting: state.isSubmitting,
    isSubmitted:  state.isSubmitted,
    submitCount:  state.submitCount,
  })}
>
  {({ isSubmitting, isSubmitted, submitCount }) => (
    <div>
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting…' : 'Submit'}
      </button>
      {isSubmitted && <p>Submitted successfully ({submitCount} attempt(s)).</p>}
    </div>
  )}
</form.Subscribe>
```

**Key Points:**

- `isSubmitting` is the correct flag for disabling the submit button during async operations
- `submitCount` increments regardless of whether validation passed or failed [Inference: verify exact increment conditions — specifically whether a validation-blocked attempt increments `submitCount`]
- `isSubmitted` does not reset automatically on `form.reset()` in all versions [Unverified: verify reset behavior of `isSubmitted` in current docs]

---

### Preventing Duplicate Submissions

Disabling the submit button while `isSubmitting` is `true` is the standard approach.

tsx

```tsx
<form.Subscribe selector={(state) => state.isSubmitting}>
  {(isSubmitting) => (
    <button type="submit" disabled={isSubmitting}>
      {isSubmitting ? 'Please wait…' : 'Submit'}
    </button>
  )}
</form.Subscribe>
```

Alternatively, disable when either submitting or already submitted (for one-shot forms):

tsx

```tsx
<form.Subscribe
  selector={(state) => ({
    isSubmitting: state.isSubmitting,
    isSubmitted: state.isSubmitted,
  })}
>
  {({ isSubmitting, isSubmitted }) => (
    <button type="submit" disabled={isSubmitting || isSubmitted}>
      Submit
    </button>
  )}
</form.Subscribe>
```

---

### Resetting After Submission

After a successful submission, you may want to reset the form. `formApi` is available inside `onSubmit` for this purpose.

tsx

```tsx
const form = useForm({
  defaultValues: { message: '' },
  onSubmit: async ({ value, formApi }) => {
    await api.sendMessage(value.message)
    formApi.reset()
  },
})
```

Or reset to a new set of values (e.g., after a server round-trip that returns updated data):

tsx

```tsx
onSubmit: async ({ value, formApi }) => {
  const saved = await api.saveProfile(value)
  formApi.reset(saved)   // [Unverified: exact reset-with-values API — verify in current docs]
},
```

**Key Points:**

- `formApi.reset()` clears errors, touched, and dirty state and restores values to `defaultValues`
- Resetting inside `onSubmit` means the reset runs only on successful submission — errors and partial state are preserved if `onSubmit` throws before reaching `reset()`

---

### Programmatic Submission

`form.handleSubmit()` can be called from anywhere that has access to the form instance — not only from a native form submit event.

tsx

```tsx
// Triggered by a non-submit button
<button
  type="button"
  onClick={() => form.handleSubmit()}
>
  Save Draft
</button>

// Triggered by a keyboard shortcut
useEffect(() => {
  const handler = (e: KeyboardEvent) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
      e.preventDefault()
      form.handleSubmit()
    }
  }
  window.addEventListener('keydown', handler)
  return () => window.removeEventListener('keydown', handler)
}, [form])
```

**Key Points:**

- Programmatic submission runs the full pipeline — validators, `onSubmit` / `onSubmitInvalid`, lifecycle state — identically to native form submission
- When not using a native `<form>` element, there is no browser-level submit event — `form.handleSubmit()` is the only entry point

---

### Error Handling Inside `onSubmit`

TanStack Form does not automatically surface errors thrown inside `onSubmit` into form state. Handle them explicitly.

tsx

```tsx
onSubmit: async ({ value, formApi }) => {
  try {
    await api.submit(value)
  } catch (err) {
    // Option 1: set a form-level error message in component state
    setServerError(err.message)

    // Option 2: set a specific field error programmatically
    formApi.setFieldMeta('email', (meta) => ({
      ...meta,
      errors: ['This email is already registered'],
      errorMap: { ...meta.errorMap, onServer: 'This email is already registered' },
    }))
    // [Unverified: exact API for setting field errors programmatically — verify in current docs]
  }
},
```

**Key Points:**

- Server-side errors (e.g., duplicate email, failed auth) are outside TanStack Form's validation system — they require manual state management or programmatic field meta updates
- A common pattern is maintaining a separate `serverError` state alongside the form and rendering it above the submit button
- Some versions of TanStack Form may expose a dedicated server-error or field-error setter — check current API reference [Unverified]

---

### Full Submission Flow Diagram

<svg viewBox="0 0 660 520" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Background -->
<rect width="660" height="520" fill="#0f1117" rx="12"/>
<!-- Title -->

<text x="330" y="34" text-anchor="middle" fill="`#e2e8f0`" font-size="15" font-weight="bold">TanStack Form — Submission Flow</text>

<!-- Step 1 -->
<rect x="220" y="54" width="220" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
<text x="330" y="77" text-anchor="middle" fill="#93c5fd">form.handleSubmit() called</text>
<!-- Arrow -->
<line x1="330" y1="92" x2="330" y2="112" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 2 -->
<rect x="200" y="112" width="260" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
<text x="330" y="135" text-anchor="middle" fill="#93c5fd">Run all onSubmit validators</text>
<!-- Arrow -->
<line x1="330" y1="150" x2="330" y2="170" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Decision diamond -->
<polygon points="330,170 470,210 330,250 190,210" fill="#1e293b" stroke="#facc15" stroke-width="1.5"/>
<text x="330" y="206" text-anchor="middle" fill="#fde68a">All fields</text>
<text x="330" y="222" text-anchor="middle" fill="#fde68a">valid?</text>
<!-- NO branch — left -->
<line x1="190" y1="210" x2="100" y2="210" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="144" y="202" text-anchor="middle" fill="#94a3b8" font-size="11">NO</text>
<rect x="20" y="188" width="80" height="44" rx="7" fill="#1e293b" stroke="#f87171" stroke-width="1.5"/>
<text x="60" y="207" text-anchor="middle" fill="#fca5a5" font-size="12">onSubmit</text>
<text x="60" y="223" text-anchor="middle" fill="#fca5a5" font-size="12">Invalid()</text>
<!-- YES branch — down -->
<line x1="330" y1="250" x2="330" y2="270" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<text x="342" y="264" fill="#94a3b8" font-size="11">YES</text>
<!-- Step 3: isSubmitting = true -->
<rect x="195" y="270" width="270" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
<text x="330" y="293" text-anchor="middle" fill="#93c5fd">isSubmitting = true</text>
<!-- Arrow -->
<line x1="330" y1="308" x2="330" y2="328" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 4: onSubmit -->
<rect x="210" y="328" width="240" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
<text x="330" y="351" text-anchor="middle" fill="#93c5fd">await onSubmit({ value, formApi })</text>
<!-- Arrow -->
<line x1="330" y1="366" x2="330" y2="386" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 5: isSubmitting = false -->
<rect x="195" y="386" width="270" height="38" rx="7" fill="#1e293b" stroke="#3b82f6" stroke-width="1.5"/>
<text x="330" y="409" text-anchor="middle" fill="#93c5fd">isSubmitting = false</text>
<!-- Arrow -->
<line x1="330" y1="424" x2="330" y2="444" stroke="#475569" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 6 -->
<rect x="175" y="444" width="310" height="38" rx="7" fill="#1e293b" stroke="#34d399" stroke-width="1.5"/>
<text x="330" y="467" text-anchor="middle" fill="#6ee7b7">isSubmitted = true | submitCount++</text>
<!-- Arrowhead marker -->
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#475569"/>
</marker>
</defs>
</svg>

---

### Summary of Key Submission APIs

| API | Location | Purpose |
| --- | --- | --- |
| `form.handleSubmit()` | Form instance | Initiates the full submission pipeline |
| `onSubmit` | `useForm` options | Async handler receiving validated values |
| `onSubmitInvalid` | `useForm` options | Called when any field fails submit-time validation |
| `validators.onSubmit` | `form.Field` props | Per-field validator that runs only on submit |
| `validators.onSubmitAsync` | `form.Field` props | Async per-field submit-time validator |
| `state.isSubmitting` | `form.state` | `true` while submission is in progress |
| `state.isSubmitted` | `form.state` | `true` after first completed submission |
| `state.submitCount` | `form.state` | Total submission attempts |
| `formApi.reset()` | Inside `onSubmit` | Resets form state after successful submission |

---

**Related Topics:**

- Async validation — `onChangeAsync`, `onBlurAsync`, debounce strategies
- Server error handling — mapping API errors back to specific field errors
- Form-level validators — cross-field validation at submit time
- `form.Subscribe` — subscribing to `isSubmitting` and `submitCount` for UI feedback
- Multi-step forms — orchestrating submission across form steps
- `formApi.setFieldValue` and `setFieldMeta` — programmatic state updates post-submit
- Optimistic UI patterns — updating UI before server confirmation
- Integration with React Router / TanStack Router — navigation after successful submission