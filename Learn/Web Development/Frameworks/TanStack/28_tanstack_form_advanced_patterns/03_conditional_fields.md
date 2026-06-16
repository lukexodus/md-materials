## Conditional Fields

### Overview

Conditional fields are form fields that appear, disappear, or change behavior based on the current state of other fields in the form. Common examples include showing a billing address section only when "same as shipping" is unchecked, revealing additional inputs when a user selects a specific option, or enabling a field only after a prerequisite field is filled.

TanStack Form does not provide a dedicated conditional field API. Conditional behavior is implemented through standard reactive patterns: reading field state, applying JavaScript conditionals in the render tree, and managing the lifecycle of fields that mount and unmount as conditions change.

---

### Core Concepts

#### Conditionality is a Render Concern

In TanStack Form, whether a field is rendered is determined by the component tree, not by form configuration. A field exists in the form state only when it is mounted. When a conditional field unmounts, its registration with the form is removed unless persistence is explicitly configured.

This means conditional logic is expressed as ordinary JSX conditionals (`&&`, ternary, early return) wrapping `form.Field` components.

#### Field Mount and Unmount Lifecycle

When a `form.Field` mounts, it registers itself with the form and initializes its state from `defaultValues` or a provided default. When it unmounts, by default its value is removed from the form state. [Inference: exact cleanup behavior may vary by adapter version; verify with current documentation.]

This has a direct consequence: if a conditional field is hidden and the user submits the form, the hidden field's value will not be present in the submitted data unless the field is still mounted or its value is explicitly preserved.

---

### Basic Conditional Rendering

The simplest pattern reads one field's value and conditionally renders another field.

tsx

```tsx
<form.Field name="hasShippingAddress">
  {(field) => (
    <label>
      <input
        type="checkbox"
        checked={field.state.value}
        onChange={(e) => field.handleChange(e.target.checked)}
      />
      Ship to a different address
    </label>
  )}
</form.Field>

<form.Subscribe
  selector={(state) => state.values.hasShippingAddress}
>
  {(hasShipping) =>
    hasShipping ? (
      <form.Field name="shippingAddress.street">
        {(field) => (
          <input
            value={field.state.value}
            onChange={(e) => field.handleChange(e.target.value)}
            placeholder="Shipping street"
          />
        )}
      </form.Field>
    ) : null
  }
</form.Subscribe>
```

**Key Points:**

- `form.Subscribe` is used to read form state outside of a field binding without causing the entire parent component to re-render
- The conditional field only exists in the form state while it is rendered
- Returning `null` when the condition is false unmounts the field and removes its value from state

---

### Using `form.Subscribe` for Conditional Logic

`form.Subscribe` is the canonical way to read form state in render logic without creating a field binding. It accepts a `selector` that extracts the relevant slice of state.

tsx

```tsx
<form.Subscribe
  selector={(state) => state.values.accountType}
>
  {(accountType) => (
    <>
      {accountType === 'business' && (
        <form.Field name="companyName">
          {(field) => (
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              placeholder="Company name"
            />
          )}
        </form.Field>
      )}

      {accountType === 'business' && (
        <form.Field name="taxId">
          {(field) => (
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              placeholder="Tax ID"
            />
          )}
        </form.Field>
      )}
    </>
  )}
</form.Subscribe>
```

**Key Points:**

- `selector` should be kept narrow — select only the state slice needed to drive the condition, minimizing re-renders
- Multiple conditional fields can be grouped inside a single `form.Subscribe` if they share the same condition

---

### Diagram: Conditional Field Lifecycle

truefalseyesnoControlling Field ChangesCondition EvaluatesConditional Field MountsField Registers with FormStateValue Initialized fromdefaultValuesConditional FieldUnmountsField Deregisters fromForm StatepreserveValue?Value Retained in FormStateValue Removed fromForm State

---

### Preserving Field Values on Unmount

By default, when a conditional field unmounts, its value is removed from the form state. To retain the value even when the field is not visible, use the `preserveValue` option on `form.Field`:

tsx

```tsx
<form.Field name="shippingAddress.street" preserveValue>
  {(field) => (
    <input
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
    />
  )}
</form.Field>
```

**Key Points:**

- `preserveValue` retains the field's last known value in form state even after unmount
- This is useful when a user toggles a condition back on and should see their previously entered data
- With `preserveValue`, the hidden field's value will also be present in the submitted form data even if the field is not currently visible — handle this explicitly in submit logic if needed [Inference: verify exact behavior with your adapter version]

---

### Conditional Validation

Fields that are conditionally rendered should generally not carry validators when they are not visible. Because an unmounted field is not present in form state by default, its validators do not run. If `preserveValue` is in use, validators on preserved-but-hidden fields may still execute. [Inference: validator lifecycle behavior on unmounted fields may vary; verify with current documentation.]

A common pattern is to apply conditional validation at the form level using `form.Subscribe` to read the controlling field, then derive whether validation should apply:

tsx

```tsx
<form.Field
  name="companyName"
  validators={{
    onChange: ({ value, fieldApi }) => {
      const accountType = fieldApi.form.getFieldValue('accountType');
      if (accountType !== 'business') return undefined;
      return !value ? 'Company name is required for business accounts' : undefined;
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

- `fieldApi.form.getFieldValue` reads another field's current value inside a validator [Inference: verify method availability in your adapter version]
- This approach allows the validator to gate itself based on the controlling field without requiring a separate subscription

---

### Conditional Field Groups

When multiple fields share the same condition, wrap them together in a single conditional block rather than repeating the condition for each field individually.

tsx

```tsx
<form.Subscribe selector={(state) => state.values.isEmployed}>
  {(isEmployed) =>
    isEmployed ? (
      <fieldset>
        <form.Field name="employer">
          {(field) => (
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              placeholder="Employer"
            />
          )}
        </form.Field>

        <form.Field name="jobTitle">
          {(field) => (
            <input
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
              placeholder="Job title"
            />
          )}
        </form.Field>

        <form.Field name="annualIncome">
          {(field) => (
            <input
              type="number"
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.valueAsNumber)}
              placeholder="Annual income"
            />
          )}
        </form.Field>
      </fieldset>
    ) : null
  }
</form.Subscribe>
```

**Key Points:**

- All three fields mount and unmount together as a unit
- A `<fieldset>` is semantically appropriate for grouped conditional inputs
- A single `form.Subscribe` drives the entire group, avoiding redundant state reads

---

### Multi-Step Conditional Logic

Some forms require chained conditions — field B is conditional on field A, and field C is conditional on both field A and field B.

tsx

```tsx
<form.Subscribe selector={(state) => state.values.category}>
  {(category) =>
    category === 'vehicle' ? (
      <>
        <form.Field name="vehicleType">
          {(field) => (
            <select
              value={field.state.value}
              onChange={(e) => field.handleChange(e.target.value)}
            >
              <option value="">Select type</option>
              <option value="car">Car</option>
              <option value="motorcycle">Motorcycle</option>
            </select>
          )}
        </form.Field>

        <form.Subscribe selector={(state) => state.values.vehicleType}>
          {(vehicleType) =>
            vehicleType === 'car' ? (
              <form.Field name="numberOfDoors">
                {(field) => (
                  <input
                    type="number"
                    value={field.state.value}
                    onChange={(e) => field.handleChange(e.target.valueAsNumber)}
                    placeholder="Number of doors"
                  />
                )}
              </form.Field>
            ) : null
          }
        </form.Subscribe>
      </>
    ) : null
  }
</form.Subscribe>
```

**Key Points:**

- Nested `form.Subscribe` components each select only their relevant slice of state
- Each level of conditionality is independently reactive
- Avoid deeply chaining more than two or three levels — consider restructuring the form or using a step-based layout beyond that depth

---

### Conditional Default Values

When a conditional field mounts for the first time, it initializes from `defaultValues`. If the field was not included in the initial `defaultValues` object, it initializes to `undefined`. Explicitly include conditional fields in `defaultValues` with appropriate empty values to avoid `undefined` state:

typescript

```typescript
const form = useForm<FormValues>({
  defaultValues: {
    accountType: 'personal',
    companyName: '',
    taxId: '',
    hasShippingAddress: false,
    shippingAddress: {
      street: '',
      city: '',
      zip: '',
    },
  },
});
```

Including all fields in `defaultValues` — even those that start hidden — avoids uncontrolled-to-controlled input transitions and ensures validators have a defined initial value to evaluate against.

---

### Conditional Fields and Form Submission

On submit, `form.handleSubmit` receives only the currently registered field values unless `preserveValue` is set. Conditional fields that are not mounted are absent from the submitted data.

Handle this in submit logic explicitly:

typescript

```typescript
form.handleSubmit((values) => {
  const payload = {
    accountType: values.accountType,
    ...(values.accountType === 'business' && {
      companyName: values.companyName,
      taxId: values.taxId,
    }),
  };

  submitToApi(payload);
});
```

This ensures the submitted payload is structurally consistent regardless of which conditional fields were active at the time of submission.

---

### Conditional Field Accessibility

When fields are conditionally hidden, ensure the surrounding layout does not leave orphaned labels, error messages, or focus traps. Use `null` returns rather than CSS `display: none` to fully remove hidden fields from the DOM, which keeps screen reader output clean and prevents hidden fields from receiving focus.

---

### Common Pitfalls

#### Reading Field State Outside `form.Subscribe`

Reading `form.getFieldValue` directly in the render body of a parent component can cause that component to not re-render when the controlling field changes, since the subscription is not registered. Use `form.Subscribe` with a selector to ensure reactivity.

#### Submit Receiving Unexpected Undefined Values

If a conditional field was never mounted (never appeared in the render tree), its value may be `undefined` in submitted data even if it was included in `defaultValues`. Confirm field mount behavior in your specific scenario. [Inference: this may depend on whether `form.Field` was rendered at any point during the component's lifetime.]

#### Validators Running on Hidden Fields with `preserveValue`

When `preserveValue` is set, a field's validators may run even when the field is hidden, producing errors on fields the user cannot see or correct. Guard validators internally using `fieldApi.form.getFieldValue` to check whether the condition is active before returning an error.

#### Controlled Input Warnings on First Mount

If a conditional field mounts with `value={undefined}` because it was absent from `defaultValues`, React may warn about switching from uncontrolled to controlled. Initialize all fields in `defaultValues` to avoid this.

---

### Summary

Conditional fields in TanStack Form are implemented through standard JSX conditionals in the render tree. `form.Subscribe` provides reactive access to form state for driving conditional logic without unnecessary re-renders. Fields unmount when their condition is false, removing their values from form state by default; `preserveValue` retains values across unmounts. Validators on conditional fields should gate themselves using the controlling field's value to avoid errors surfacing on hidden inputs. Submit logic must account for the presence or absence of conditional field values in the submitted data.

---

**Next Steps**

- Conditional required validation driven by another field's value
- Conditional field groups in multi-step or wizard forms
- Resetting conditional fields when their controlling condition changes
- Combining conditional fields with schema-level validation (Zod discriminated unions)
- Conditional field visibility vs. conditional field disabling
- Using `form.Subscribe` selector memoization for performance
- Conditional async validation triggered by a controlling field