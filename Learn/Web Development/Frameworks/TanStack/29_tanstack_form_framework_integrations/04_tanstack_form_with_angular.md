## TanStack Form with Angular

TanStack Form provides an Angular adapter that integrates with Angular's dependency injection system, reactive primitives, and template syntax. As of Angular 17+, the adapter leverages Angular Signals for fine-grained reactivity, aligning TanStack Form's state model with Angular's modern reactivity approach.

---

### Installation

```bash
npm install @tanstack/angular-form
```

**Key Points:**
- Requires Angular 17+ for full Signals-based integration
- `@tanstack/angular-form` includes the core form logic; no separate core package installation is needed
- Angular's `CommonModule` or standalone component imports are required depending on your project setup

---

### Architecture Overview

The Angular adapter differs structurally from the React and Solid adapters in several important ways:

- Form instances are created via `injectForm()` instead of a hook or `createForm()`
- Fields are rendered using the `tanstackField` directive applied to an `ng-container`
- Angular's `ChangeDetectionStrategy.OnPush` is compatible and [Inference] likely beneficial for performance, though behavior may vary by Angular version
- Form and field state is exposed as Angular Signals, accessed with `()` call syntax inside templates

```
┌─────────────────────────────────────┐
│           Angular Component         │
│                                     │
│  form = injectForm(...)             │
│                                     │
│  <ng-container [tanstackField]="form"│
│    name="email" #f="field">         │
│    <input [value]="f.api.state.value"│
│  </ng-container>                    │
└─────────────────────────────────────┘
```

---

### Basic Setup with `injectForm`

`injectForm` is the Angular-idiomatic entry point. It must be called within an injection context — typically in the component class body or within an `inject`-compatible factory.

```typescript
import { Component } from '@angular/core'
import { injectForm, TanStackField } from '@tanstack/angular-form'

@Component({
  selector: 'app-my-form',
  standalone: true,
  imports: [TanStackField],
  template: `
    <form (submit)="handleSubmit($event)">
      <!-- fields go here -->
      <button type="submit">Submit</button>
    </form>
  `,
})
export class MyFormComponent {
  form = injectForm({
    defaultValues: {
      username: '',
      email: '',
    },
    onSubmit: async ({ value }) => {
      console.log('Submitted:', value)
    },
  })

  handleSubmit(event: SubmitEvent) {
    event.preventDefault()
    event.stopPropagation()
    this.form.handleSubmit()
  }
}
```

**Key Points:**
- `injectForm` must be called in an injection context (component constructor scope or field initializer)
- `TanStackField` must be imported into the component's `imports` array when using standalone components
- `this.form.handleSubmit()` is called imperatively; it does not require the event object

---

### Registering Fields with the `tanstackField` Directive

Fields are declared in the template using the `tanstackField` structural directive on an `ng-container`. The directive exposes a template reference variable (conventionally `#f="field"`) used to access field state and handlers.

```html
<ng-container
  [tanstackField]="form"
  name="username"
  #f="field"
>
  <div>
    <label>Username</label>
    <input
      [value]="f.api.state.value"
      (blur)="f.api.handleBlur()"
      (input)="f.api.handleChange($any($event).target.value)"
    />
  </div>
</ng-container>
```

**Key Points:**
- `[tanstackField]="form"` binds the field to the form instance
- `name="username"` identifies the field within the form's value tree
- `#f="field"` creates a template reference to the field API
- `f.api` exposes the full field API: `state`, `handleChange`, `handleBlur`, etc.
- `f.api.state.value` reads the current value — in Angular's Signal-based model, `state` [Inference] may be a signal depending on adapter version; always verify with current documentation

---

### Field State and `f.api.state`

The field's reactive state is accessible via `f.api.state`:

```html
<ng-container [tanstackField]="form" name="email" #f="field">
  <input
    [value]="f.api.state.value"
    (blur)="f.api.handleBlur()"
    (input)="f.api.handleChange($any($event).target.value)"
  />
  @if (f.api.state.meta.isTouched && f.api.state.meta.errors.length > 0) {
    <span>{{ f.api.state.meta.errors[0] }}</span>
  }
</ng-container>
```

| State Property | Type | Description |
|---|---|---|
| `state.value` | `T` | Current field value |
| `state.meta.isTouched` | `boolean` | True after blur event |
| `state.meta.isDirty` | `boolean` | True if value differs from default |
| `state.meta.isValidating` | `boolean` | True during async validation |
| `state.meta.errors` | `string[]` | Active validation error messages |
| `state.meta.errorMap` | `object` | Errors keyed by validation event |

---

### Accessing Form-Level State

To read form-level reactive state (e.g., submission status, overall validity), use `form.useStore` with a selector:

```typescript
export class MyFormComponent {
  form = injectForm({
    defaultValues: { name: '' },
    onSubmit: async ({ value }) => console.log(value),
  })

  canSubmit = this.form.useStore((state) => state.canSubmit)
  isSubmitting = this.form.useStore((state) => state.isSubmitting)
}
```

In the template:

```html
<button type="submit" [disabled]="!canSubmit()">
  {{ isSubmitting() ? 'Submitting...' : 'Submit' }}
</button>
```

**Key Points:**
- `form.useStore(selector)` returns an Angular Signal in the Angular adapter
- Signals must be called with `()` in the template to read their current value
- Only the selected slice of state is tracked, limiting unnecessary updates

---

### Validation

#### Synchronous Field Validation

Validators are passed as an object to the `[validators]` input on the `tanstackField` directive.

```html
<ng-container
  [tanstackField]="form"
  name="email"
  [validators]="{
    onChange: emailValidator
  }"
  #f="field"
>
  <input
    [value]="f.api.state.value"
    (blur)="f.api.handleBlur()"
    (input)="f.api.handleChange($any($event).target.value)"
  />
  @if (f.api.state.meta.errors[0]) {
    <span>{{ f.api.state.meta.errors[0] }}</span>
  }
</ng-container>
```

Define the validator in the component class:

```typescript
emailValidator = ({ value }: { value: string }) => {
  if (!value.includes('@')) return 'Must be a valid email'
  return undefined
}
```

**Key Points:**
- Validator functions are defined in the component class and referenced in the template
- Inline arrow functions in Angular template bindings can cause unnecessary re-evaluations; defining them as class properties is preferred

#### Async Field Validation

```typescript
usernameAsyncValidator = async ({ value }: { value: string }) => {
  await new Promise((r) => setTimeout(r, 300))
  if (value === 'taken') return 'Username already taken'
  return undefined
}
```

```html
<ng-container
  [tanstackField]="form"
  name="username"
  [validators]="{
    onChangeAsync: usernameAsyncValidator,
    onChangeAsyncDebounceMs: 400
  }"
  #f="field"
>
  <input
    [value]="f.api.state.value"
    (input)="f.api.handleChange($any($event).target.value)"
  />
  @if (f.api.state.meta.isValidating) {
    <span>Checking availability...</span>
  }
  @if (f.api.state.meta.errors[0]) {
    <span>{{ f.api.state.meta.errors[0] }}</span>
  }
</ng-container>
```

---

### Schema-Based Validation with Zod or Valibot

The framework-agnostic validator adapters work with the Angular integration.

```typescript
import { injectForm } from '@tanstack/angular-form'
import { zodValidator } from '@tanstack/zod-form-adapter'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'At least 8 characters'),
})

export class MyFormComponent {
  form = injectForm({
    defaultValues: { email: '', password: '' },
    validatorAdapter: zodValidator(),
    validators: {
      onChange: schema,
    },
    onSubmit: async ({ value }) => {
      console.log(value)
    },
  })
}
```

**Key Points:**
- `validatorAdapter` is set at the form level in `injectForm`
- The schema is passed to `validators.onChange` (or `onBlur`, `onSubmit`) at form or field level
- Field-level Zod schemas can be passed via the `[validators]` directive input in the template

---

### Nested Object Fields

Dot notation in the `name` attribute allows mapping to nested object structures in `defaultValues`.

```typescript
form = injectForm({
  defaultValues: {
    address: {
      street: '',
      city: '',
      postalCode: '',
    },
  },
  onSubmit: async ({ value }) => console.log(value),
})
```

```html
<ng-container [tanstackField]="form" name="address.street" #f="field">
  <input
    [value]="f.api.state.value"
    (input)="f.api.handleChange($any($event).target.value)"
  />
</ng-container>

<ng-container [tanstackField]="form" name="address.city" #f="field">
  <input
    [value]="f.api.state.value"
    (input)="f.api.handleChange($any($event).target.value)"
  />
</ng-container>
```

---

### Array Fields

Dynamic array fields use `mode="array"` on the directive, with `f.api.state.value` iterated using `@for` and sub-fields registered with bracket notation.

```typescript
form = injectForm({
  defaultValues: {
    tags: [''],
  },
  onSubmit: async ({ value }) => console.log(value),
})
```

```html
<ng-container
  [tanstackField]="form"
  name="tags"
  mode="array"
  #tagsField="field"
>
  @for (
    tag of tagsField.api.state.value;
    track $index
  ) {
    <ng-container
      [tanstackField]="form"
      [name]="'tags[' + $index + ']'"
      #tagField="field"
    >
      <input
        [value]="tagField.api.state.value"
        (input)="tagField.api.handleChange($any($event).target.value)"
      />
      <button
        type="button"
        (click)="tagsField.api.removeValue($index)"
      >
        Remove
      </button>
    </ng-container>
  }

  <button type="button" (click)="tagsField.api.pushValue('')">
    Add Tag
  </button>
</ng-container>
```

**Key Points:**
- `mode="array"` is passed as a plain attribute (not bound) on the parent field directive
- `tagsField.api.pushValue(value)` appends a new entry
- `tagsField.api.removeValue(index)` removes an entry at the given index
- Angular's `@for` with `track $index` is used to iterate array items

---

### Reusable Field Components

In Angular, reusable field wrappers can be built as standalone components that accept a form instance and field name as inputs.

```typescript
import { Component, Input } from '@angular/core'
import { TanStackField } from '@tanstack/angular-form'

@Component({
  selector: 'app-text-field',
  standalone: true,
  imports: [TanStackField],
  template: `
    <ng-container
      [tanstackField]="form"
      [name]="name"
      #f="field"
    >
      <div>
        <label>{{ label }}</label>
        <input
          [value]="f.api.state.value"
          (blur)="f.api.handleBlur()"
          (input)="f.api.handleChange($any($event).target.value)"
        />
        @if (f.api.state.meta.errors[0]) {
          <span>{{ f.api.state.meta.errors[0] }}</span>
        }
      </div>
    </ng-container>
  `,
})
export class TextFieldComponent {
  @Input() form!: ReturnType<typeof injectForm>
  @Input() name!: string
  @Input() label: string = ''
}
```

Usage in a parent component:

```html
<app-text-field [form]="form" name="username" label="Username" />
<app-text-field [form]="form" name="email" label="Email" />
```

**Key Points:**
- `ReturnType<typeof injectForm>` provides type safety for the `form` input
- Validators can optionally be added as additional `@Input()` properties and bound to the directive's `[validators]` input

---

### Using `ChangeDetectionStrategy.OnPush`

Because TanStack Form's Angular adapter exposes state as Signals, it is [Inference] compatible with `OnPush` change detection, which should — but is not guaranteed to — improve rendering performance.

```typescript
@Component({
  selector: 'app-my-form',
  standalone: true,
  imports: [TanStackField],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`,
})
export class MyFormComponent {
  form = injectForm({ ... })
}
```

> [Inference] Angular's Signal integration with `OnPush` means only components that read a changed Signal should be marked for re-check. Actual behavior depends on Angular version and how Signals are consumed in the template. This is not guaranteed.

---

### Full Working Example

```typescript
import { Component } from '@angular/core'
import { injectForm, TanStackField } from '@tanstack/angular-form'
import { ChangeDetectionStrategy } from '@angular/core'

@Component({
  selector: 'app-registration-form',
  standalone: true,
  imports: [TanStackField],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <form (submit)="handleSubmit($event)">

      <ng-container
        [tanstackField]="form"
        name="username"
        [validators]="{ onChange: usernameValidator }"
        #username="field"
      >
        <div>
          <label>Username</label>
          <input
            [value]="username.api.state.value"
            (blur)="username.api.handleBlur()"
            (input)="username.api.handleChange($any($event).target.value)"
          />
          @if (username.api.state.meta.isTouched &&
               username.api.state.meta.errors[0]) {
            <span>{{ username.api.state.meta.errors[0] }}</span>
          }
        </div>
      </ng-container>

      <ng-container
        [tanstackField]="form"
        name="email"
        [validators]="{ onChange: emailValidator }"
        #email="field"
      >
        <div>
          <label>Email</label>
          <input
            type="email"
            [value]="email.api.state.value"
            (blur)="email.api.handleBlur()"
            (input)="email.api.handleChange($any($event).target.value)"
          />
          @if (email.api.state.meta.isTouched &&
               email.api.state.meta.errors[0]) {
            <span>{{ email.api.state.meta.errors[0] }}</span>
          }
        </div>
      </ng-container>

      <button type="submit" [disabled]="!canSubmit()">
        {{ isSubmitting() ? 'Submitting...' : 'Register' }}
      </button>

    </form>
  `,
})
export class RegistrationFormComponent {
  form = injectForm({
    defaultValues: {
      username: '',
      email: '',
    },
    onSubmit: async ({ value }) => {
      alert(JSON.stringify(value, null, 2))
    },
  })

  canSubmit = this.form.useStore((s) => s.canSubmit)
  isSubmitting = this.form.useStore((s) => s.isSubmitting)

  usernameValidator = ({ value }: { value: string }) =>
    value.length < 3 ? 'At least 3 characters' : undefined

  emailValidator = ({ value }: { value: string }) =>
    !value.includes('@') ? 'Invalid email' : undefined

  handleSubmit(event: SubmitEvent) {
    event.preventDefault()
    event.stopPropagation()
    this.form.handleSubmit()
  }
}
```

---

### Key Differences from React and Solid Adapters

| Feature | React | Solid | Angular |
|---|---|---|---|
| Form initializer | `useForm(config)` | `createForm(() => config)` | `injectForm(config)` |
| Field registration | `<form.Field>` render prop | `<form.Field>` with accessor | `tanstackField` directive |
| Field API access | `field` object | `field()` signal | `f.api` via template ref |
| State subscription | `form.useStore()` → value | `form.useStore()` → accessor | `form.useStore()` → Signal |
| Signal read syntax | N/A | `signal()` | `signal()` in template |
| Config location | `useForm` call | `createForm` factory fn | `injectForm` in class body |
| Reusability pattern | Custom hook or component | Wrapped component | Standalone Angular component |

---

### Common Pitfalls

**1. Using inline functions in `[validators]` template bindings**

```html
<!-- Risky — new function reference on every change detection cycle -->
[validators]="{ onChange: ({ value }) => value.length < 3 ? 'Too short' : undefined }"

<!-- Preferred — stable reference defined in class -->
[validators]="{ onChange: usernameValidator }"
```

**2. Forgetting to import `TanStackField`**

```typescript
// Missing this causes the directive to be unrecognized
imports: [TanStackField]
```

**3. Calling `injectForm` outside an injection context**

```typescript
// Wrong — called in a lifecycle hook, outside injection context
ngOnInit() {
  this.form = injectForm({ ... }) // throws error
}

// Correct — called as a class field initializer
form = injectForm({ ... })
```

**4. Not using `$any()` for event targets in strict templates**

```html
<!-- May cause type error in strict mode -->
(input)="f.api.handleChange($event.target.value)"

<!-- Correct for strict mode -->
(input)="f.api.handleChange($any($event).target.value)"
```

---

**Related Topics:**
- TanStack Form with Vue — Composition API and `useForm` patterns
- Angular Signals deep dive — `signal()`, `computed()`, `effect()` integration with forms
- Form validation with Angular Reactive Forms vs. TanStack Form — comparison
- `ControlValueAccessor` and TanStack Form — integrating with Angular's native form control protocol
- TanStack Form type safety with TypeScript in Angular — generics and `injectForm` typing
- Server-side validation patterns in Angular with TanStack Form