## TanStack Form

TanStack Form is a headless, framework-agnostic form state management library. It handles the logic of managing form values, validation, submission, and field state without imposing any UI or styling — you supply the markup, it manages the state.

---

### Core Design Philosophy

TanStack Form is built around several guiding principles:

- **Headless** — No built-in UI components. You control all rendering.
- **Framework-agnostic** — Core logic is framework-independent, with official adapters for React, Vue, Solid, Angular, and Svelte
- **Type-safe** — Designed with TypeScript first; field types are inferred from the form's default values
- **Granular reactivity** — Only the components that depend on changed state re-render, rather than the entire form
- **Validation flexibility** — Supports synchronous, asynchronous, and schema-based validation (e.g., Zod, Valibot, ArkType)

---

### What It Manages

TanStack Form tracks:

- Field values
- Touched and dirty state per field
- Validation errors per field and at the form level
- Submission state (`isSubmitting`, `isSubmitted`)
- Form-level validity

---

### Basic Example (React)

tsx

```tsx
import { useForm } from '@tanstack/react-form';

function MyForm() {
  const form = useForm({
    defaultValues: {
      name: '',
      email: '',
    },
    onSubmit: async ({ value }) => {
      console.log(value); // { name: string, email: string }
    },
  });

  return (
    <form onSubmit={(e) => { e.preventDefault(); form.handleSubmit(); }}>
      <form.Field name="name">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            onBlur={field.handleBlur}
          />
        )}
      </form.Field>

      <form.Field name="email">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            onBlur={field.handleBlur}
          />
        )}
      </form.Field>

      <button type="submit">Submit</button>
    </form>
  );
}
```

**Key Points:**

- `useForm` initializes the form with default values and a submit handler
- `form.Field` renders a field using a render prop pattern, scoping field state to that component
- Field state (`value`, `meta.errors`, `meta.isTouched`) is accessed via the `field` argument
- Type inference flows from `defaultValues` — `name` and `email` are typed as `string` automatically

---

### Where It Fits in the TanStack Ecosystem

TanStack Form is a standalone library. It does not depend on TanStack Query, TanStack Table, or TanStack Router, but it is commonly used alongside them — for example, using TanStack Query to submit form data to a server, or TanStack Router for navigation after submission.

---

### How It Differs from Other Form Libraries

| Aspect | TanStack Form | React Hook Form | Formik |
| --- | --- | --- | --- |
| Framework support | Multi-framework | React only | React only |
| Reactivity model | Granular (field-level) | Ref-based (minimal re-renders) | Component-level |
| TypeScript | First-class | Good | Moderate |
| Validation | Sync, async, schema | Schema + manual | Schema + manual |
| UI | Fully headless | Fully headless | Fully headless |
| Bundle size | Small core | Small | Larger |

> [Inference] Bundle size and performance comparisons are approximate and may shift with version updates. Verify current benchmarks against your target version.

---

### Key Concepts to Learn Next

The major areas of TanStack Form are:

- **Form initialization** — `useForm`, `defaultValues`, `onSubmit`
- **Field API** — `form.Field`, `field.state`, `field.handleChange`, `field.handleBlur`
- **Validation** — per-field validators, form-level validators, async validation, schema adapters
- **Array fields** — dynamic lists of fields using `field.pushValue`, `field.removeValue`
- **Form state** — `form.state.isSubmitting`, `form.state.isValid`, `form.state.errors`
- **Side effects** — `listeners` for reacting to field changes without validation

---

**Related Topics:**

- `useForm` API — initialization options, default values, submit handler
- `form.Field` and the field render prop pattern
- Validation strategies — sync, async, on-blur, on-change, on-submit
- Schema validation adapters — Zod, Valibot, ArkType integration
- Array and dynamic fields
- Form and field subscribers — granular reactivity model
- TanStack Form with TanStack Query — coordinating server submission and loading state
- Framework adapters — Vue, Solid, Svelte, Angular usage