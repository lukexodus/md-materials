## Array Fields and Dynamic Field Lists

### Overview

TanStack Form provides first-class support for array fields — form fields that represent a list of values, where items can be added, removed, or reordered dynamically. This is a common pattern in forms that manage collections: line items, contact entries, tag lists, multi-step participants, and similar use cases.

Array fields in TanStack Form are managed through the `useFieldArray` pattern (or its framework-specific equivalent), where a parent field owns a list and child fields are derived from individual indices.

---

### Core Concepts

#### The Field Array Mental Model

An array field is a field whose value is a JavaScript array. Each element of that array is itself a sub-value — either a primitive or an object — that can be bound to one or more child fields.

TanStack Form tracks:

- The array value itself as a field in the form state
- Each element at a given index as a child field
- Mutations to the array (push, remove, move, insert, swap) as state updates that trigger re-renders and validation

Because TanStack Form uses a reactive, fine-grained subscription model, only the affected fields re-render when the array changes. [Inference: this is consistent with TanStack Form's design goals; actual render behavior may vary depending on framework adapter and version.]

#### Array Field Identity and Keys

When items are added, removed, or reordered, React (and other frameworks) need stable keys to track elements across renders. TanStack Form assigns internal identifiers to array items to maintain stability. Avoid using the array index as a React `key` when items can be reordered — use the internal key provided by TanStack Form instead. [Inference: behavior may vary; verify with your framework adapter version.]

---

### Setting Up an Array Field

#### Defining the Schema

The form's type definition must declare the array field explicitly.

typescript

```typescript
type FormValues = {
  tags: string[];
};

type ComplexFormValues = {
  contacts: {
    name: string;
    email: string;
  }[];
};
```

#### Initializing the Form

typescript

```typescript
import { useForm } from '@tanstack/react-form';

const form = useForm<FormValues>({
  defaultValues: {
    tags: [''],
  },
});
```

---

### Rendering Array Fields

#### Using `form.Field` with an Array Path

TanStack Form uses a nested `Field` component approach. The parent field binds to the array; child fields bind to individual indices.

tsx

```tsx
<form.Field name="tags" mode="array">
  {(field) => (
    <div>
      {field.state.value.map((_, index) => (
        <form.Field key={index} name={`tags[${index}]`}>
          {(itemField) => (
            <input
              value={itemField.state.value}
              onChange={(e) => itemField.handleChange(e.target.value)}
            />
          )}
        </form.Field>
      ))}
    </div>
  )}
</form.Field>
```

**Key Points:**

- `mode="array"` is required on the parent field to enable array-aware subscriptions
- Child fields are addressed via bracket notation: `tags[0]`, `tags[1]`, etc.
- The index is used for both addressing and rendering, but avoid using index alone as a React `key` when supporting reorder operations

---

### Mutating the Array

#### Adding Items

Mutations are performed via `field.pushValue()`:

tsx

```tsx
<button
  type="button"
  onClick={() => field.pushValue('')}
>
  Add Tag
</button>
```

For object arrays:

tsx

```tsx
onClick={() =>
  field.pushValue({ name: '', email: '' })
}
```

#### Removing Items

Use `field.removeValue(index)`:

tsx

```tsx
<button
  type="button"
  onClick={() => field.removeValue(index)}
>
  Remove
</button>
```

#### Inserting at a Position

Use `field.insertValue(index, value)`:

tsx

```tsx
field.insertValue(2, '');
```

#### Moving Items

Use `field.moveValue(fromIndex, toIndex)`:

tsx

```tsx
field.moveValue(1, 0); // Move item at index 1 to index 0
```

#### Swapping Items

Use `field.swapValues(indexA, indexB)`:

tsx

```tsx
field.swapValues(0, 2);
```

---

### Object Array Fields

When each array item is an object with multiple properties, child fields are addressed by both index and property name.

tsx

```tsx
<form.Field name="contacts" mode="array">
  {(field) => (
    <div>
      {field.state.value.map((_, index) => (
        <div key={index}>
          <form.Field name={`contacts[${index}].name`}>
            {(nameField) => (
              <input
                value={nameField.state.value}
                onChange={(e) => nameField.handleChange(e.target.value)}
                placeholder="Name"
              />
            )}
          </form.Field>

          <form.Field name={`contacts[${index}].email`}>
            {(emailField) => (
              <input
                value={emailField.state.value}
                onChange={(e) => emailField.handleChange(e.target.value)}
                placeholder="Email"
              />
            )}
          </form.Field>

          <button
            type="button"
            onClick={() => field.removeValue(index)}
          >
            Remove
          </button>
        </div>
      ))}

      <button
        type="button"
        onClick={() => field.pushValue({ name: '', email: '' })}
      >
        Add Contact
      </button>
    </div>
  )}
</form.Field>
```

---

### Validation on Array Fields

#### Array-Level Validation

Validators can be attached to the parent array field itself, targeting the array as a whole:

tsx

```tsx
<form.Field
  name="tags"
  mode="array"
  validators={{
    onChange: ({ value }) =>
      value.length === 0 ? 'At least one tag is required' : undefined,
  }}
>
  {(field) => (
    <>
      {/* render array items */}
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

#### Item-Level Validation

Each child field can carry its own validators independently:

tsx

```tsx
<form.Field
  name={`contacts[${index}].email`}
  validators={{
    onChange: ({ value }) =>
      !value.includes('@') ? 'Invalid email' : undefined,
  }}
>
  {(emailField) => (
    <>
      <input
        value={emailField.state.value}
        onChange={(e) => emailField.handleChange(e.target.value)}
      />
      {emailField.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

#### Cross-Item Validation

Cross-item rules (e.g., "no duplicate emails") are best implemented at the array-level validator, which receives the full array value:

tsx

```tsx
validators={{
  onChange: ({ value }) => {
    const emails = value.map((c) => c.email);
    const unique = new Set(emails);
    return unique.size !== emails.length
      ? 'Duplicate emails are not allowed'
      : undefined;
  },
}}
```

---

### Diagram: Array Field State Structure

Form Statecontacts (array field)contacts[0] (object)contacts[1] (object)contacts[n] (object)contacts[0].namecontacts[0].emailcontacts[1].namecontacts[1].email

---

### Handling Empty Arrays

An array field with no items is valid state. Handle it explicitly in the render path:

tsx

```tsx
{field.state.value.length === 0 && (
  <p>No items added yet.</p>
)}
```

Avoid rendering a map over an empty array without a fallback, as empty forms can be confusing to users without visual feedback.

---

### Preserving Field State During Reorder

When items are reordered using `moveValue` or `swapValues`, TanStack Form updates the underlying array state. [Inference: if child fields are keyed by index, React may reuse DOM nodes incorrectly during reorder; use TanStack Form's internal item identifiers as keys if exposed by your adapter version. Verify with current documentation.]

---

### Nested Array Fields

Arrays can contain objects that themselves contain arrays (nested arrays). Address them by extending the path notation:

typescript

```typescript
type FormValues = {
  sections: {
    title: string;
    items: string[];
  }[];
};
```

tsx

```tsx
<form.Field name={`sections[${sectionIndex}].items`} mode="array">
  {(itemsField) => (
    <>
      {itemsField.state.value.map((_, itemIndex) => (
        <form.Field
          key={itemIndex}
          name={`sections[${sectionIndex}].items[${itemIndex}]`}
        >
          {(itemField) => (
            <input
              value={itemField.state.value}
              onChange={(e) => itemField.handleChange(e.target.value)}
            />
          )}
        </form.Field>
      ))}
    </>
  )}
</form.Field>
```

**Key Points:**

- Nesting depth is theoretically unbounded [Inference], but deep nesting increases path complexity and can make validation logic harder to maintain
- Each level requires its own `mode="array"` declaration on the parent field

---

### Accessing the Full Array Value on Submit

The submitted form values include the full resolved array:

typescript

```typescript
form.handleSubmit((values) => {
  console.log(values.contacts);
  // [{ name: 'Alice', email: 'alice@example.com' }, ...]
});
```

No special deserialization is needed — the array structure mirrors the form's `defaultValues` shape.

---

### Common Pitfalls

#### Using Index as React Key with Reorderable Lists

If items can be reordered, using the array index as `key` causes React to reuse components incorrectly. Prefer stable IDs. If your adapter exposes an internal item key, use that instead.

#### Forgetting `mode="array"` on the Parent Field

Without `mode="array"`, the parent field may not subscribe to array-level mutations, causing stale renders. [Inference: this depends on adapter internals; verify behavior in your version.]

#### Mutating State Directly

Avoid mutating `field.state.value` directly (e.g., `field.state.value.push(...)`). Always use the provided mutation methods (`pushValue`, `removeValue`, etc.) so TanStack Form can track changes correctly.

#### Validation Timing on Removed Items

When an item is removed, its field is unmounted. Validate array-level constraints (like minimum length) at the array field level, not at the item field level, to avoid validation state becoming orphaned.

---

### Summary

Array fields in TanStack Form allow fully reactive management of dynamic lists. The pattern follows a consistent structure: a parent field owns the array with `mode="array"`, child fields are addressed by index and optional property path, and mutations use dedicated methods (`pushValue`, `removeValue`, `insertValue`, `moveValue`, `swapValues`). Validation can be applied at both the array level and the individual item level, with cross-item rules handled at the parent.

---

**Next Steps**

- Implementing drag-and-drop reorder with array fields
- Conditionally required fields inside array items
- Async validation on individual array items
- Using Zod or Valibot schemas with array field validation
- Controlled vs. uncontrolled array field initialization
- Performance optimization for large dynamic lists
- Field array integration with TanStack Form's `FormApi` directly