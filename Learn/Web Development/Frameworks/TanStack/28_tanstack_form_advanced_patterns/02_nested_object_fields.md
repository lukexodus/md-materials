## Nested Object Fields

### Overview

TanStack Form supports fields whose values are nested objects — structured sub-values within the form state that group related properties under a common key. This is distinct from array fields in that the shape is fixed at definition time rather than dynamically sized. Nested object fields are common in forms that model addresses, profiles, settings blocks, or any domain entity with a known set of sub-properties.

---

### Core Concepts

#### Nested Fields as Path Expressions

TanStack Form addresses nested values using dot notation path strings. A field bound to `address.city` reads and writes the `city` property inside the `address` object in form state. There is no special "object field" API distinct from regular fields — nesting is expressed entirely through the path.

typescript

```typescript
type FormValues = {
  address: {
    street: string;
    city: string;
    zip: string;
  };
};
```

The fields `address.street`, `address.city`, and `address.zip` are each independent field bindings into the same nested object.

#### Shallow vs. Deep State Subscriptions

Each field subscribes only to its own slice of state. A change to `address.city` does not trigger a re-render in a component subscribed only to `address.street`. [Inference: this is consistent with TanStack Form's fine-grained reactivity model; actual subscription behavior may vary by adapter version.]

---

### Defining Nested Default Values

Default values must be fully initialized, including all nested objects. Partial initialization can produce `undefined` reads on first render.

typescript

```typescript
const form = useForm<FormValues>({
  defaultValues: {
    address: {
      street: '',
      city: '',
      zip: '',
    },
  },
});
```

Avoid initializing nested objects as `undefined` unless your field logic explicitly handles that case.

---

### Binding Child Fields with Dot Notation

Each nested property is bound using its full dot-separated path:

tsx

```tsx
<form.Field name="address.street">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      placeholder="Street"
    />
  )}
</form.Field>

<form.Field name="address.city">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      placeholder="City"
    />
  )}
</form.Field>

<form.Field name="address.zip">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      placeholder="ZIP"
    />
  )}
</form.Field>
```

**Key Points:**

- Each path binds independently — no parent field wrapper is required for simple object fields
- Type inference follows the path, so `field.state.value` is typed to the correct leaf type

---

### Parent Field Scoping with Nested Objects

When a group of child fields share a common object prefix, a parent `form.Field` binding can scope child fields. This is useful for encapsulating a reusable fieldset component.

tsx

```tsx
<form.Field name="address">
  {(addressField) => (
    <div>
      <form.Field name="address.street">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        )}
      </form.Field>

      <form.Field name="address.city">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
          />
        )}
      </form.Field>
    </div>
  )}
</form.Field>
```

**Key Points:**

- The parent `address` field binding gives access to `addressField.state.value` as the full object `{ street, city, zip }`
- Child field paths must still be fully qualified — relative paths are not supported [Inference: verify with current adapter documentation]
- The parent field can carry its own validators targeting the object as a whole

---

### Validation on Nested Object Fields

#### Leaf-Level Validation

Each leaf field validates its own value independently:

tsx

```tsx
<form.Field
  name="address.zip"
  validators={{
    onChange: ({ value }) =>
      !/^\d{5}$/.test(value) ? 'ZIP must be 5 digits' : undefined,
  }}
>
  {(field) => (
    <>
      <input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
      />
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

#### Object-Level Validation

A validator on the parent object field receives the entire nested object as its value, enabling cross-property rules:

tsx

```tsx
<form.Field
  name="address"
  validators={{
    onChange: ({ value }) => {
      if (!value.street && !value.city) {
        return 'At least street or city must be provided';
      }
      return undefined;
    },
  }}
>
  {(field) => (
    <>
      {/* child field renders */}
      {field.state.meta.errors.map((err) => (
        <span key={err}>{err}</span>
      ))}
    </>
  )}
</form.Field>
```

**Key Points:**

- Object-level errors surface on the parent field's `meta.errors`, not on the child fields
- Child field errors surface only on their own `meta.errors`
- These two error surfaces are independent and must be rendered separately if both are needed

---

### Diagram: Nested Object Field State Structure

Form Stateaddressaddress.streetaddress.cityaddress.zipprofileprofile.firstNameprofile.lastName

---

### Deeply Nested Objects

Nesting depth is not inherently limited by TanStack Form — paths simply extend with additional dot segments. [Inference: deep nesting increases path string complexity and type inference load; verify TypeScript performance at extreme depths.]

typescript

```typescript
type FormValues = {
  user: {
    profile: {
      address: {
        city: string;
      };
    };
  };
};
```

tsx

```tsx
<form.Field name="user.profile.address.city">
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

The path `user.profile.address.city` is a valid field name and will be typed correctly if the `FormValues` type is properly defined.

---

### Reusable Nested Field Components

A common pattern is to extract a group of related nested fields into a standalone component, accepting the field name prefix as a prop.

tsx

```tsx
type AddressFieldsProps = {
  prefix: 'shippingAddress' | 'billingAddress';
  form: typeof myForm;
};

function AddressFields({ prefix, form }: AddressFieldsProps) {
  return (
    <div>
      <form.Field name={`${prefix}.street`}>
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            placeholder="Street"
          />
        )}
      </form.Field>

      <form.Field name={`${prefix}.city`}>
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            placeholder="City"
          />
        )}
      </form.Field>
    </div>
  );
}
```

**Usage:**

tsx

```tsx
<AddressFields prefix="shippingAddress" form={form} />
<AddressFields prefix="billingAddress" form={form} />
```

**Key Points:**

- The `form` instance is passed directly to the reusable component so it can create `form.Field` bindings
- TypeScript will enforce valid prefix values if the union type is correctly defined
- This pattern avoids duplicating field render logic for symmetrical nested structures

---

### Nested Objects Inside Arrays

Nested object fields compose naturally with array fields. Each array item may itself be an object with dot-accessible properties.

typescript

```typescript
type FormValues = {
  contacts: {
    name: string;
    address: {
      city: string;
    };
  }[];
};
```

tsx

```tsx
<form.Field name={`contacts[${index}].address.city`}>
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

The path combines bracket notation for array indexing with dot notation for object property access. Both syntaxes are valid within the same path string.

---

### Reading the Full Nested Object Value

The parent field binding exposes the full object value at `field.state.value`:

tsx

```tsx
<form.Field name="address">
  {(field) => {
    console.log(field.state.value);
    // { street: '123 Main St', city: 'Springfield', zip: '62701' }
    return null;
  }}
</form.Field>
```

This can be used for derived displays, summaries, or conditional rendering based on the object's current state.

---

### Programmatic Updates to Nested Fields

The `form.setFieldValue` method accepts a dot-notation path and updates only the targeted field:

typescript

```typescript
form.setFieldValue('address.city', 'Chicago');
```

To replace the entire nested object at once:

typescript

```typescript
form.setFieldValue('address', {
  street: '456 Oak Ave',
  city: 'Chicago',
  zip: '60601',
});
```

**Key Points:**

- Replacing the entire object at once updates all child field states simultaneously
- Individual `setFieldValue` calls on leaf paths update only the targeted property [Inference: verify merge vs. replace semantics in your adapter version]

---

### Common Pitfalls

#### Uninitialized Nested Objects

If `defaultValues` does not include the nested object, child fields will attempt to read properties from `undefined`, causing runtime errors. Always initialize nested objects, even with empty string values.

#### Stale Object References in Validators

Object-level validators receive the current snapshot of the nested object. Avoid capturing stale closures over the outer form state inside object validators — use the `value` argument provided to the validator function.

#### Forgetting to Render Object-Level Errors

Because object-level and leaf-level errors surface on different fields, it is easy to render child field errors while omitting the parent field's error display. If cross-property validation is in use, ensure the parent field's `meta.errors` is rendered somewhere visible.

#### Type Narrowing at Deep Paths

TypeScript's inference over deeply nested path strings has practical limits. At sufficient depth, the inferred type of `field.state.value` may fall back to a broader type. [Inference: this is a general TypeScript constraint, not specific to TanStack Form; verify behavior at your nesting depth.]

---

### Summary

Nested object fields in TanStack Form are addressed through dot-notation path strings with no special API beyond the standard `form.Field` binding. Default values must fully initialize all nested objects. Validation can be applied at the leaf level for individual properties or at the parent level for cross-property rules, with each error surface being independent. Reusable fieldset components accept a path prefix and the form instance, enabling symmetric nested structures without duplication.

---

**Next Steps**

- Conditional nested object initialization (optional sub-objects)
- Schema-level validation of nested objects with Zod or Valibot
- Resetting individual nested object groups without resetting the full form
- Nested objects with discriminated union types
- Combining nested objects and array fields at multiple depths
- Performance characteristics of deep path subscriptions
- Abstracting nested field groups into context-based sub-form patterns