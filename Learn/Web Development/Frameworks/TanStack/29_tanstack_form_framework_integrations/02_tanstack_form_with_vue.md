## TanStack Form with Vue

TanStack Form's Vue adapter maps the framework-agnostic core onto Vue 3's Composition API. Form state is exposed as reactive refs, fields are rendered via a `Field` component with scoped slots, and all the same validation, subscription, and submission patterns from the React adapter are available with Vue-idiomatic equivalents.

---

### Installation

```bash
npm install @tanstack/vue-form
```

Vue 3 is required. Vue 2 is not supported by the Vue adapter.

---

### Creating a Form

Forms are created with `useForm` inside a `setup` function or `<script setup>` block.

```vue
<script setup>
import { useForm } from '@tanstack/vue-form'

const form = useForm({
  defaultValues: {
    name: '',
    email: '',
    age: 0,
  },
  onSubmit: async ({ value }) => {
    console.log('Submitted:', value)
  },
})
</script>

<template>
  <form @submit.prevent="form.handleSubmit()">
    <!-- fields -->
    <button type="submit">Submit</button>
  </form>
</template>
```

**Key Points**
- `@submit.prevent` replaces the React `e.preventDefault()` pattern — Vue's event modifier handles it
- `form.handleSubmit()` triggers validation and calls `onSubmit` if the form is valid
- `useForm` returns a `form` instance that is stable across renders [Inference]

---

### `useForm` Options

```ts
const form = useForm({
  defaultValues: { ... },

  onSubmit: async ({ value, formApi }) => { },

  onSubmitInvalid: ({ value, formApi }) => { },

  validators: {
    onChange: ({ value }) => /* string | undefined */,
    onSubmit: ({ value }) => /* string | undefined */,
  },
})
```

The options API is identical to the React adapter. Only the consumption layer differs.

---

### Rendering Fields with `form.Field`

`form.Field` is a renderless component that exposes the field API via a scoped slot. The default slot receives the `field` object.

```vue
<template>
  <form.Field name="email">
    <template #default="{ field }">
      <div>
        <label :for="field.name">Email</label>
        <input
          :id="field.name"
          :name="field.name"
          :value="field.state.value"
          @input="field.handleChange($event.target.value)"
          @blur="field.handleBlur()"
        />
        <p v-for="err in field.state.meta.errors" :key="err">{{ err }}</p>
      </div>
    </template>
  </form.Field>
</template>
```

**Key Points**
- The scoped slot syntax `#default="{ field }"` destructures the field API
- `@input` is used instead of `@change` for real-time value tracking on text inputs — `$event.target.value` extracts the string value from the native input event
- `field.state.value`, `field.state.meta`, and all handler methods match the React adapter's field API exactly

---

### Field API Reference

| Property / Method | Description |
|---|---|
| `field.name` | Field name string |
| `field.state.value` | Current field value (reactive) |
| `field.state.meta.errors` | Active error array |
| `field.state.meta.isTouched` | Whether field has been blurred |
| `field.state.meta.isDirty` | Whether value differs from default |
| `field.state.meta.isValidating` | Whether async validation is running |
| `field.handleChange(value)` | Update field value |
| `field.handleBlur()` | Mark field as touched |
| `field.setMeta(updater)` | Imperatively update field metadata |
| `field.validate(cause)` | Manually trigger validation |
| `field.form` | Reference to the parent form API |

---

### TypeScript with `<script setup>`

Pass the form value type as a generic to `useForm`. Field names and value types are then inferred:

```vue
<script setup lang="ts">
import { useForm } from '@tanstack/vue-form'

interface FormValues {
  username: string
  age: number
  tags: string[]
}

const form = useForm<FormValues>({
  defaultValues: {
    username: '',
    age: 0,
    tags: [],
  },
  onSubmit: async ({ value }) => {
    // value is typed as FormValues
  },
})
</script>
```

> [Inference] Type inference for field names inside `form.Field`'s `name` prop depends on the Vue adapter's generic support, which may vary by version. Verify against the installed version.

---

### Field Validation

Validators are passed as a prop to `form.Field`:

```vue
<form.Field
  name="email"
  :validators="{
    onChange: ({ value }) => !value.includes('@') ? 'Invalid email' : undefined,
    onBlur: ({ value }) => value.length < 3 ? 'Too short' : undefined,
    onSubmit: ({ value }) => !value ? 'Required' : undefined,
  }"
>
  <template #default="{ field }">
    <input
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
    <p v-for="err in field.state.meta.errors" :key="err">{{ err }}</p>
  </template>
</form.Field>
```

**Async validation:**

```vue
<form.Field
  name="username"
  :async-debounce-ms="400"
  :validators="{
    onChangeAsync: async ({ value }) => {
      const taken = await checkUsername(value)
      return taken ? 'Username already taken' : undefined
    },
  }"
>
  <template #default="{ field }">
    <input
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
    <span v-if="field.state.meta.isValidating">Checking…</span>
    <p v-for="err in field.state.meta.errors" :key="err">{{ err }}</p>
  </template>
</form.Field>
```

---

### Cross-field Validation

`onChangeListenTo` causes a field to re-validate when a named sibling field changes:

```vue
<form.Field
  name="confirmPassword"
  :on-change-listen-to="['password']"
  :validators="{
    onChange: ({ value, fieldApi }) => {
      const password = fieldApi.form.getFieldValue('password')
      return value !== password ? 'Passwords do not match' : undefined
    },
  }"
>
  <template #default="{ field }">
    <input
      type="password"
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
    <p v-for="err in field.state.meta.errors" :key="err">{{ err }}</p>
  </template>
</form.Field>
```

---

### Form-level Validation

Validators on `useForm` receive the complete values object:

```ts
const form = useForm({
  defaultValues: { startDate: '', endDate: '' },
  validators: {
    onChange: ({ value }) => {
      if (value.startDate && value.endDate) {
        return new Date(value.endDate) <= new Date(value.startDate)
          ? 'End date must be after start date'
          : undefined
      }
    },
  },
  onSubmit: async ({ value }) => { },
})
```

Display form-level errors by reading `errorMap` from the store:

```vue
<script setup>
const formErrors = form.useStore((s) => s.errorMap)
</script>

<template>
  <p v-if="formErrors.onChange" role="alert">
    {{ String(formErrors.onChange) }}
  </p>
</template>
```

---

### Accessing Form State with `form.useStore`

`form.useStore` returns a Vue `computed`-like ref that re-evaluates when the selected state slice changes:

```vue
<script setup>
const isSubmitting = form.useStore((s) => s.isSubmitting)
const isDirty = form.useStore((s) => s.isDirty)
const canSubmit = form.useStore((s) => s.canSubmit)
</script>

<template>
  <p v-if="isDirty">You have unsaved changes.</p>
  <button type="submit" :disabled="!canSubmit || isSubmitting">
    {{ isSubmitting ? 'Submitting…' : 'Submit' }}
  </button>
</template>
```

**Key Points**
- The return value of `form.useStore` is a Vue ref — access the value with `.value` in `<script setup>` and without `.value` in templates (Vue unwraps refs automatically in templates) [Inference — behavior follows Vue 3 ref conventions]
- The selector runs synchronously and re-evaluates on each store update where the selected slice changed

---

### Using `useField` Hook

For reusable field components, `useField` provides the field API without the render component:

```vue
<!-- components/EmailField.vue -->
<script setup lang="ts">
import { useField } from '@tanstack/vue-form'

const props = defineProps<{
  form: any
}>()

const field = useField({ form: props.form, name: 'email' })
</script>

<template>
  <div>
    <label :for="field.name">Email</label>
    <input
      :id="field.name"
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
    <p v-for="err in field.state.meta.errors" :key="err">{{ err }}</p>
  </div>
</template>
```

> [Inference] The `useField` hook must be called inside a component's `setup` context. It cannot be called conditionally or outside `setup`. Behavior may vary by version.

---

### Providing Form via `provide` / `inject`

To avoid prop-drilling the `form` instance into deep components, use Vue's `provide` / `inject`:

```vue
<!-- ParentForm.vue -->
<script setup>
import { provide } from 'vue'
import { useForm } from '@tanstack/vue-form'

const form = useForm({
  defaultValues: { name: '', email: '' },
  onSubmit: async ({ value }) => { },
})

provide('form', form)
</script>

<template>
  <form @submit.prevent="form.handleSubmit()">
    <DeepFieldComponent />
  </form>
</template>
```

```vue
<!-- DeepFieldComponent.vue -->
<script setup>
import { inject } from 'vue'

const form = inject('form')
</script>

<template>
  <form.Field name="name">
    <template #default="{ field }">
      <input
        :value="field.state.value"
        @input="field.handleChange($event.target.value)"
        @blur="field.handleBlur()"
      />
    </template>
  </form.Field>
</template>
```

For TypeScript safety, use a typed injection key:

```ts
import type { InjectionKey } from 'vue'
import type { FormApi } from '@tanstack/vue-form'

export const formKey: InjectionKey<FormApi<any, any>> = Symbol('form')
```

---

### Nested Object Fields

Dot-notation names resolve into nested `defaultValues` structure:

```vue
<form.Field name="address.street">
  <template #default="{ field }">
    <input
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
  </template>
</form.Field>

<form.Field name="address.city">
  <template #default="{ field }">
    <input
      :value="field.state.value"
      @input="field.handleChange($event.target.value)"
      @blur="field.handleBlur()"
    />
  </template>
</form.Field>
```

---

### Array Fields

```vue
<form.Field name="emails" :default-value="[]">
  <template #default="{ field: arrayField }">
    <div v-for="(_, index) in arrayField.state.value" :key="index">
      <form.Field :name="`emails[${index}]`">
        <template #default="{ field }">
          <input
            :value="field.state.value"
            @input="field.handleChange($event.target.value)"
          />
          <button type="button" @click="arrayField.removeValue(index)">
            Remove
          </button>
        </template>
      </form.Field>
    </div>
    <button type="button" @click="arrayField.pushValue('')">
      Add Email
    </button>
  </template>
</form.Field>
```

---

### Imperative Field Control

```ts
// Read
const email = form.getFieldValue('email')
const meta = form.getFieldMeta('email')

// Write
form.setFieldValue('email', 'user@example.com')
form.setFieldMeta('email', (prev) => ({ ...prev, isTouched: true }))

// Trigger validation
form.validateField('email', 'change')
form.validateAllFields('submit')

// Reset
form.reset()
form.reset({ name: '', email: '' })
```

These imperative APIs are identical across all TanStack Form adapters.

---

### Input Event Handling Reference

Vue distinguishes between `@input` (fires on every keystroke) and `@change` (fires on commit). For real-time validation, use `@input`:

| Input type | Recommended event | Value extraction |
|---|---|---|
| `<input type="text">` | `@input` | `$event.target.value` |
| `<input type="number">` | `@input` | `Number($event.target.value)` |
| `<input type="checkbox">` | `@change` | `$event.target.checked` |
| `<select>` | `@change` | `$event.target.value` |
| Library component | per-library | direct value or adapter |

```vue
<!-- Checkbox -->
<form.Field name="acceptTerms">
  <template #default="{ field }">
    <input
      type="checkbox"
      :checked="field.state.value"
      @change="field.handleChange($event.target.checked)"
      @blur="field.handleBlur()"
    />
  </template>
</form.Field>

<!-- Number input -->
<form.Field name="age">
  <template #default="{ field }">
    <input
      type="number"
      :value="field.state.value"
      @input="field.handleChange(Number($event.target.value))"
      @blur="field.handleBlur()"
    />
  </template>
</form.Field>
```

---

### Architecture: React vs Vue Adapter Comparison

```
Concern              React Adapter              Vue Adapter
─────────────────────────────────────────────────────────────────
Form creation        useForm()                  useForm()
Field rendering      form.Field + render prop   form.Field + scoped slot
State subscription   form.useStore() → value    form.useStore() → ref
Event prevention     e.preventDefault()         @submit.prevent
onChange input       onChange={e=>...}          @input="...($event.target.value)"
Context sharing      React.createContext        provide / inject
Reusable fields      useField hook              useField hook
```

---

### Full Example

```vue
<script setup lang="ts">
import { useForm } from '@tanstack/vue-form'

interface SignupValues {
  username: string
  email: string
  password: string
}

const form = useForm<SignupValues>({
  defaultValues: { username: '', email: '', password: '' },
  onSubmit: async ({ value }) => {
    await registerUser(value)
  },
})

const canSubmit = form.useStore((s) => s.canSubmit)
const isSubmitting = form.useStore((s) => s.isSubmitting)
</script>

<template>
  <form @submit.prevent="form.handleSubmit()">

    <form.Field
      name="username"
      :validators="{ onChange: ({ value }) => !value ? 'Required' : undefined }"
    >
      <template #default="{ field }">
        <div>
          <label :for="field.name">Username</label>
          <input
            :id="field.name"
            :value="field.state.value"
            @input="field.handleChange($event.target.value)"
            @blur="field.handleBlur()"
          />
          <p v-if="field.state.meta.isTouched" v-for="err in field.state.meta.errors" :key="err">
            {{ err }}
          </p>
        </div>
      </template>
    </form.Field>

    <form.Field
      name="email"
      :validators="{
        onChange: ({ value }) => !value.includes('@') ? 'Invalid email' : undefined,
      }"
    >
      <template #default="{ field }">
        <div>
          <label :for="field.name">Email</label>
          <input
            :id="field.name"
            :value="field.state.value"
            @input="field.handleChange($event.target.value)"
            @blur="field.handleBlur()"
          />
          <p v-if="field.state.meta.isTouched" v-for="err in field.state.meta.errors" :key="err">
            {{ err }}
          </p>
        </div>
      </template>
    </form.Field>

    <form.Field
      name="password"
      :validators="{
        onChange: ({ value }) => value.length < 8 ? 'Minimum 8 characters' : undefined,
      }"
    >
      <template #default="{ field }">
        <div>
          <label :for="field.name">Password</label>
          <input
            :id="field.name"
            type="password"
            :value="field.state.value"
            @input="field.handleChange($event.target.value)"
            @blur="field.handleBlur()"
          />
          <p v-if="field.state.meta.isTouched" v-for="err in field.state.meta.errors" :key="err">
            {{ err }}
          </p>
        </div>
      </template>
    </form.Field>

    <button type="submit" :disabled="!canSubmit || isSubmitting">
      {{ isSubmitting ? 'Submitting…' : 'Sign Up' }}
    </button>

  </form>
</template>
```

---

### Common Mistakes

**Using `@change` instead of `@input` for text fields**

```vue
<!-- Fires only on commit — misses intermediate keystrokes for onChange validators -->
<input @change="field.handleChange($event.target.value)" />

<!-- Correct for real-time tracking -->
<input @input="field.handleChange($event.target.value)" />
```

**Passing the event object instead of the value**

```vue
<!-- Wrong — handleChange receives the Event object -->
<input @input="field.handleChange($event)" />

<!-- Correct -->
<input @input="field.handleChange($event.target.value)" />
```

**Accessing `form.useStore` return value without `.value` in script**

```vue
<script setup>
const isSubmitting = form.useStore((s) => s.isSubmitting)

// Wrong — isSubmitting is a ref; access .value in script context
if (isSubmitting) { }

// Correct in script
if (isSubmitting.value) { }

// In template — Vue unwraps automatically, no .value needed
// :disabled="isSubmitting"  ← correct in template
</script>
```

**Forgetting `@submit.prevent`**

```vue
<!-- Native form submission fires — page reloads -->
<form @submit="form.handleSubmit()">

<!-- Correct -->
<form @submit.prevent="form.handleSubmit()">
```

---

### Summary

The Vue adapter exposes TanStack Form's full feature set through Vue 3 Composition API conventions. `useForm` in `<script setup>`, `form.Field` with scoped slots, and `form.useStore` returning reactive refs are the three primary APIs. All validation, subscription, array field, and imperative control patterns from the core are available with only surface-level syntax differences from the React adapter. The mental model is identical; the idioms are Vue's.

**Related Topics**
- TanStack Form with React adapter — API comparison
- TanStack Form with Solid adapter
- Schema validation with Zod via `@tanstack/zod-form-adapter` in Vue
- Integrating with Vue UI libraries (PrimeVue, Vuetify, Naive UI)
- Form state persistence with Vue Router navigation guards
- Server-side validation and mapping API errors into field state