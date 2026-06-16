## TanStack Form — Core Concepts — Controlled vs. Uncontrolled Fields

---

### What Controlled and Uncontrolled Mean

These terms describe where the source of truth for a field's value lives.

- **Controlled field:** The framework (React state, TanStack Form state) owns the value. Every keystroke updates state, and the input's displayed value is driven by that state.
- **Uncontrolled field:** The DOM owns the value. The framework reads it only when needed (e.g., on submit), without tracking every change.

In standard React, the distinction is explicit: a controlled input has `value` + `onChange`, an uncontrolled input uses a `ref` and `defaultValue`.

TanStack Form operates primarily in the **controlled** model — field state is managed reactively inside the form store. However, understanding the tradeoffs and how TanStack Form's design relates to the uncontrolled pattern is important for making informed architecture decisions.

---

### TanStack Form's Default Model: Controlled

When you register a field with `form.Field` and wire up `handleChange`, the field is fully controlled by TanStack Form's internal store.

tsx

```tsx
<form.Field name="email">
  {(field) => (
    <input
      value={field.state.value}        // store drives the DOM
      onChange={(e) => field.handleChange(e.target.value)}  // DOM updates the store
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

**Key Points:**

- `field.state.value` is the single source of truth
- Every `onChange` triggers a store update, which re-renders the field
- Validation, touched/dirty tracking, and derived state all depend on this reactive loop
- This is the intended, documented usage pattern of TanStack Form

---

### Why Controlled Fields Are Central to TanStack Form

TanStack Form's core features are built around reactive field state:

| Feature | Requires Controlled? |
| --- | --- |
| Per-keystroke validation | Yes |
| `touched` / `dirty` tracking | Yes |
| `field.state.meta.errors` display | Yes |
| `form.Subscribe` reactivity | Yes |
| Array field manipulation | Yes |
| Form-level `isValid`, `isDirty` | Yes |

If a field's value is not flowing through `handleChange`, the form store does not know its current value. Validation and metadata will be based on stale or initial state. [Inference: this is the expected consequence of bypassing the controlled pattern — verify against current docs for any explicit bypass support.]

---

### Uncontrolled Fields in TanStack Form

TanStack Form does not have a first-class uncontrolled mode analogous to React Hook Form's `register` approach (which attaches refs and reads DOM values on submit). [Unverified: as of the time of writing — verify against current TanStack Form docs for any uncontrolled or ref-based API that may have been added.]

However, you can approximate uncontrolled behavior by omitting `value` from the input and only calling `handleChange` on blur or submit — though this is not a recommended pattern and loses most of TanStack Form's reactive features.

tsx

```tsx
// Not recommended — approximates uncontrolled behavior
<form.Field name="notes">
  {(field) => (
    <textarea
      defaultValue={field.state.value}     // DOM owns display value
      onBlur={(e) => field.handleChange(e.target.value)}  // sync only on blur
    />
  )}
</form.Field>
```

**Key Points:**

- `defaultValue` sets the initial DOM value but React no longer controls it after mount
- The form store only learns the current value when `handleChange` is called (here, on blur)
- Per-keystroke validation does not work
- `field.state.meta.dirty` will not reflect intermediate typing
- This pattern is valid for low-interaction fields where reactivity is unnecessary [Inference]

---

### Performance Tradeoff: Controlled Re-renders

The primary argument for uncontrolled fields is performance: controlled inputs re-render on every keystroke. TanStack Form mitigates this through its store architecture.

TanStack Form uses a fine-grained subscription model. Only the component that renders a given `form.Field` re-renders when that field's state changes — not the entire form tree. This is different from naive `useState`-per-field approaches where lifting state causes wide re-renders.

tsx

```tsx
// form.Field is isolated — sibling fields do not re-render when this field changes
<form.Field name="firstName">
  {(field) => <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />}
</form.Field>

<form.Field name="lastName">
  {(field) => <input value={field.state.value} onChange={(e) => field.handleChange(e.target.value)} />}
</form.Field>
```

**Key Points:**

- Each `form.Field` render prop is independently subscribed to its slice of form state
- Typing in `firstName` does not re-render `lastName` [Inference: based on TanStack Form's stated design goals — actual render behavior may vary depending on React version, component tree, and internal implementation details; behavior is not guaranteed]
- For forms with hundreds of fields, re-render isolation is meaningful — for typical forms, the distinction rarely matters in practice

---

### `form.Subscribe` and Selective Reactivity

Even within the controlled model, you can reduce reactivity scope using `form.Subscribe`. This lets you read form state without causing re-renders on unrelated field changes.

tsx

```tsx
// Only re-renders when `values.plan` changes — not on every field change
<form.Subscribe selector={(state) => state.values.plan}>
  {(plan) => (
    plan === 'enterprise' && (
      <form.Field name="companySize">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        )}
      </form.Field>
    )
  )}
</form.Subscribe>
```

This pattern lets you conditionally register fields while keeping the overall form controlled, without incurring re-renders from unrelated fields.

---

### Comparison Table

| Dimension | Controlled (TanStack Form default) | Approximated Uncontrolled |
| --- | --- | --- |
| Source of truth | Form store | DOM |
| Per-keystroke reactivity | Yes | No |
| Validation on change | Yes | Blur/submit only |
| `touched` / `dirty` accuracy | Full | Partial |
| `field.state.value` accuracy | Always current | Stale until sync |
| Re-render on each keystroke | Yes (isolated per field) | No |
| Recommended for TanStack Form | Yes | Only for specific edge cases |

---

### When Uncontrolled Behavior Might Be Intentional

There are narrow scenarios where deferring value sync makes sense:

- **Rich text editors** (e.g., ProseMirror, Tiptap) that manage their own internal state — you sync to TanStack Form only on content change events, not DOM input events
- **File inputs** — file inputs cannot be controlled via `value` in React; you read `e.target.files` in `onChange` and store it in the form
- **Third-party date pickers or sliders** that expose only an `onChange` callback and no `value` prop — you pass `handleChange` to their callback

tsx

```tsx
// File input — inherently uncontrolled by React design
<form.Field name="avatar">
  {(field) => (
    <input
      type="file"
      onChange={(e) => field.handleChange(e.target.files?.[0] ?? null)}
    />
  )}
</form.Field>
```

**Key Points:**

- File inputs are an exception enforced by the browser/React — not a TanStack Form design choice
- For third-party components, the controlled/uncontrolled distinction applies to how that component works internally, not to how TanStack Form tracks the value
- As long as `handleChange` is called with the correct value at some point, TanStack Form's store remains accurate

---

### Mixing Controlled and Uncontrolled in One Form

You can have some fields fully controlled (syncing on every keystroke) and others syncing only on blur, within the same form instance. TanStack Form does not enforce uniformity.

tsx

```tsx
// Controlled — per-keystroke sync
<form.Field name="title">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>

// Blur-only sync — less reactive
<form.Field name="bio">
  {(field) => (
    <textarea
      defaultValue={field.state.value}
      onBlur={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

**Key Points:**

- This is valid but requires awareness: `bio`'s value in the store will lag behind user input until blur
- If `bio` is involved in cross-field validation or derived state, the lag may cause incorrect validation results mid-edit [Inference]
- Validation mode (`onChange` vs `onBlur` vs `onSubmit`) should align with how the field syncs its value

---

### Validation Mode Alignment

TanStack Form supports field-level validation modes. These should align with how the field is wired.

tsx

```tsx
<form.Field
  name="email"
  validators={{
    onChange: ({ value }) => (!value.includes('@') ? 'Invalid email' : undefined),
    onBlur: ({ value }) => (value.length < 3 ? 'Too short' : undefined),
  }}
>
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

If a field uses `defaultValue` + blur-only sync but declares an `onChange` validator, the `onChange` validator will never fire during typing — only when `handleChange` is called manually. [Inference: this is the expected consequence of the sync timing mismatch — actual behavior depends on internal validator invocation logic.]

---

**Related Topics:**

- Validation modes — `onChange`, `onBlur`, `onSubmit`, `onMount` validators
- `form.Subscribe` — fine-grained reactive subscriptions without field registration
- Async validators — debounced `onChangeAsync` for server-side validation
- Third-party input integration — wiring rich text editors, date pickers, and sliders to `handleChange`
- File input handling in TanStack Form
- Re-render optimization — understanding TanStack Form's store subscription model
- Field metadata — `touched`, `dirty`, `validating`, `errors` and when they update
- Array fields — controlled patterns for dynamic field lists