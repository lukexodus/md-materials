## Integrating with UI Component Libraries

TanStack Form is headless — it owns no UI. Every visual element is supplied by the consuming application. This makes integration with component libraries straightforward in principle: you pass field state and handlers to whatever input component the library provides. The variation across libraries lies in how they surface their input APIs (controlled props, render props, ref-forwarding, compound components) and what adapter work is needed to bridge them.

---

### The Integration Model

Every integration follows the same pattern regardless of library:

```
field.state.value      →   value prop of the library component
field.handleChange     →   onChange handler (with adapter if needed)
field.handleBlur       →   onBlur handler
field.state.meta       →   error, disabled, loading props
```

The only variable is the shape of `onChange`. Some libraries pass the raw value directly; others pass a synthetic event; others pass an object. An adapter is a small function that normalizes the library's output into the scalar value TanStack Form expects.

---

### Controlled Input Contract

TanStack Form manages field values as controlled state. Any library component used must accept:

- A `value` prop (or equivalent) to display current state
- An `onChange` handler (or equivalent) to report changes
- Optionally `onBlur`, `disabled`, `name`, `id`, and error props

If the library component is uncontrolled only, you must use a `ref`-based approach and sync changes manually. This is uncommon in modern libraries.

---

### shadcn/ui

shadcn/ui components are thin wrappers around Radix UI primitives. They expose standard HTML-compatible props and work without adapters for text inputs.

```tsx
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

<form.Field
  name="email"
  validators={{ onChange: ({ value }) => !value ? 'Required' : undefined }}
>
  {(field) => (
    <div className="space-y-1">
      <Label htmlFor={field.name}>Email</Label>
      <Input
        id={field.name}
        name={field.name}
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
        aria-invalid={field.state.meta.errors.length > 0}
      />
      {field.state.meta.errors.map((err) => (
        <p key={err} className="text-sm text-destructive">{err}</p>
      ))}
    </div>
  )}
</form.Field>
```

**`Select` from shadcn/ui** passes the value directly (not via event), so no adapter is needed:

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'

<form.Field name="role">
  {(field) => (
    <Select value={field.state.value} onValueChange={field.handleChange}>
      <SelectTrigger onBlur={field.handleBlur}>
        <SelectValue placeholder="Select role" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="admin">Admin</SelectItem>
        <SelectItem value="viewer">Viewer</SelectItem>
      </SelectContent>
    </Select>
  )}
</form.Field>
```

`onValueChange` passes the value directly — `field.handleChange` is passed without wrapping.

---

### Radix UI (Primitives)

Radix primitives follow similar conventions to shadcn/ui. `Checkbox` is a notable case because it passes a `checked` state (boolean or `"indeterminate"`) rather than an event:

```tsx
import * as Checkbox from '@radix-ui/react-checkbox'

<form.Field name="acceptTerms">
  {(field) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <Checkbox.Root
        id={field.name}
        checked={!!field.state.value}
        onCheckedChange={(checked) => field.handleChange(checked === true)}
        onBlur={field.handleBlur}
      />
      <label htmlFor={field.name}>I accept the terms</label>
      {field.state.meta.errors.map((e) => <p key={e}>{e}</p>)}
    </div>
  )}
</form.Field>
```

`onCheckedChange` passes `true`, `false`, or `"indeterminate"`. The adapter `(checked) => field.handleChange(checked === true)` normalizes it to a boolean.

---

### Material UI (MUI)

MUI text inputs fire standard synthetic events, so no adapter is needed for `TextField`:

```tsx
import TextField from '@mui/material/TextField'

<form.Field name="username">
  {(field) => (
    <TextField
      id={field.name}
      name={field.name}
      label="Username"
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
      error={field.state.meta.errors.length > 0}
      helperText={field.state.meta.errors[0] ?? ''}
    />
  )}
</form.Field>
```

MUI's `Select` fires a synthetic event too:

```tsx
import { FormControl, InputLabel, Select, MenuItem } from '@mui/material'

<form.Field name="country">
  {(field) => (
    <FormControl error={field.state.meta.errors.length > 0}>
      <InputLabel>Country</InputLabel>
      <Select
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
        label="Country"
      >
        <MenuItem value="us">United States</MenuItem>
        <MenuItem value="uk">United Kingdom</MenuItem>
      </Select>
    </FormControl>
  )}
</form.Field>
```

**`Autocomplete`** is more complex — it passes `(event, value)` to `onChange`:

```tsx
import Autocomplete from '@mui/material/Autocomplete'

<form.Field name="tags">
  {(field) => (
    <Autocomplete
      multiple
      options={['React', 'TypeScript', 'Node']}
      value={field.state.value ?? []}
      onChange={(_, newValue) => field.handleChange(newValue)}
      onBlur={field.handleBlur}
      renderInput={(params) => (
        <TextField
          {...params}
          label="Tags"
          error={field.state.meta.errors.length > 0}
          helperText={field.state.meta.errors[0] ?? ''}
        />
      )}
    />
  )}
</form.Field>
```

The adapter `(_, newValue) => field.handleChange(newValue)` discards the event and passes the value array.

---

### Ant Design

Ant Design form components follow their own internal form context. When used outside of `Form.Item`'s auto-binding, they behave as standard controlled components:

```tsx
import { Input, Select } from 'antd'

<form.Field name="firstName">
  {(field) => (
    <div>
      <Input
        value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
        status={field.state.meta.errors.length > 0 ? 'error' : ''}
      />
      {field.state.meta.errors.map((e) => (
        <p key={e} style={{ color: 'red' }}>{e}</p>
      ))}
    </div>
  )}
</form.Field>
```

Ant Design's `Select` passes the value directly to `onChange`:

```tsx
<form.Field name="category">
  {(field) => (
    <Select
      value={field.state.value}
      onChange={field.handleChange}
      onBlur={field.handleBlur}
      options={[
        { value: 'design', label: 'Design' },
        { value: 'engineering', label: 'Engineering' },
      ]}
    />
  )}
</form.Field>
```

> [Inference] Ant Design's `DatePicker` and `RangePicker` pass a Day.js object (or `null`) to `onChange`. You will need to convert to/from your storage format (ISO string, timestamp, etc.) at the boundary.

```tsx
import { DatePicker } from 'antd'
import dayjs from 'dayjs'

<form.Field name="birthDate">
  {(field) => (
    <DatePicker
      value={field.state.value ? dayjs(field.state.value) : null}
      onChange={(date) => field.handleChange(date ? date.toISOString() : '')}
      onBlur={field.handleBlur}
    />
  )}
</form.Field>
```

---

### Mantine

Mantine components pass the value directly to `onChange` for most inputs, similar to shadcn/ui:

```tsx
import { TextInput } from '@mantine/core'

<form.Field name="email">
  {(field) => (
    <TextInput
      label="Email"
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
      error={field.state.meta.errors[0]}
    />
  )}
</form.Field>
```

Mantine's `Select` and `MultiSelect` pass the value or value array directly:

```tsx
import { MultiSelect } from '@mantine/core'

<form.Field name="skills">
  {(field) => (
    <MultiSelect
      label="Skills"
      data={['TypeScript', 'Rust', 'Go']}
      value={field.state.value ?? []}
      onChange={field.handleChange}
      onBlur={field.handleBlur}
      error={field.state.meta.errors[0]}
    />
  )}
</form.Field>
```

---

### Chakra UI

Chakra follows standard React event patterns for inputs:

```tsx
import { FormControl, FormLabel, Input, FormErrorMessage } from '@chakra-ui/react'

<form.Field name="username">
  {(field) => {
    const hasError = field.state.meta.errors.length > 0
    return (
      <FormControl isInvalid={hasError}>
        <FormLabel>Username</FormLabel>
        <Input
          value={field.state.value}
          onChange={(e) => field.handleChange(e.target.value)}
          onBlur={field.handleBlur}
        />
        <FormErrorMessage>{field.state.meta.errors[0]}</FormErrorMessage>
      </FormControl>
    )
  }}
</form.Field>
```

---

### Building a Reusable Field Wrapper

Repeating the same wiring pattern across many fields is error-prone and verbose. Extract a reusable wrapper component per library component type:

```tsx
// components/form/TextField.tsx
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import type { FieldApi } from '@tanstack/react-form'

interface TextFieldProps {
  field: FieldApi<any, any, any, any>
  label: string
}

export function TextField({ field, label }: TextFieldProps) {
  const hasError = field.state.meta.errors.length > 0

  return (
    <div className="space-y-1">
      <Label htmlFor={field.name}>{label}</Label>
      <Input
        id={field.name}
        name={field.name}
        value={field.state.value ?? ''}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur}
        aria-invalid={hasError}
        aria-describedby={hasError ? `${field.name}-error` : undefined}
      />
      {hasError && (
        <p id={`${field.name}-error`} className="text-sm text-destructive">
          {field.state.meta.errors[0]}
        </p>
      )}
    </div>
  )
}
```

Used as:

```tsx
<form.Field name="email">
  {(field) => <TextField field={field} label="Email" />}
</form.Field>
```

---

### Adapter Pattern Reference

<svg viewBox="0 0 660 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
  <rect width="660" height="380" fill="#0f1117"/>

  <!-- TanStack Form -->
  <rect x="220" y="16" width="220" height="48" rx="6" fill="#1e2030" stroke="#4f6ef7" stroke-width="1.5"/>
  <text x="330" y="36" text-anchor="middle" fill="#4f6ef7" font-size="13">TanStack Form</text>
  <text x="330" y="54" text-anchor="middle" fill="#6b7280" font-size="10">field.state.value · field.handleChange</text>

  <!-- Down line -->
  <line x1="330" y1="64" x2="330" y2="96" stroke="#4f6ef7" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Adapter box -->
  <rect x="245" y="96" width="170" height="36" rx="5" fill="#1a1f2e" stroke="#f59e0b" stroke-width="1.2"/>
  <text x="330" y="110" text-anchor="middle" fill="#f59e0b" font-size="11">onChange Adapter</text>
  <text x="330" y="124" text-anchor="middle" fill="#6b7280" font-size="10">(libraryOutput) → scalar value</text>

  <!-- Down to branches -->
  <line x1="330" y1="132" x2="330" y2="158" stroke="#f59e0b" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="158" x2="90" y2="188" stroke="#6b7280" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="158" x2="210" y2="188" stroke="#6b7280" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="158" x2="330" y2="188" stroke="#6b7280" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="158" x2="450" y2="188" stroke="#6b7280" stroke-width="1" stroke-dasharray="4,3"/>
  <line x1="330" y1="158" x2="570" y2="188" stroke="#6b7280" stroke-width="1" stroke-dasharray="4,3"/>

  <!-- Library boxes -->
  <rect x="20" y="188" width="140" height="58" rx="5" fill="#1e2030" stroke="#22c55e" stroke-width="1.2"/>
  <text x="90" y="206" text-anchor="middle" fill="#22c55e" font-size="11">shadcn / Radix</text>
  <text x="90" y="221" text-anchor="middle" fill="#6b7280" font-size="10">Input: e.target.value</text>
  <text x="90" y="235" text-anchor="middle" fill="#6b7280" font-size="10">Select: value directly</text>

  <rect x="148" y="188" width="124" height="58" rx="5" fill="#1e2030" stroke="#22c55e" stroke-width="1.2"/>
  <text x="210" y="206" text-anchor="middle" fill="#22c55e" font-size="11">MUI</text>
  <text x="210" y="221" text-anchor="middle" fill="#6b7280" font-size="10">Input: e.target.value</text>
  <text x="210" y="235" text-anchor="middle" fill="#6b7280" font-size="10">Autocomplete: (_, v)</text>

  <rect x="270" y="188" width="120" height="58" rx="5" fill="#1e2030" stroke="#22c55e" stroke-width="1.2"/>
  <text x="330" y="206" text-anchor="middle" fill="#22c55e" font-size="11">Ant Design</text>
  <text x="330" y="221" text-anchor="middle" fill="#6b7280" font-size="10">Input: e.target.value</text>
  <text x="330" y="235" text-anchor="middle" fill="#6b7280" font-size="10">DatePicker: dayjs obj</text>

  <rect x="388" y="188" width="124" height="58" rx="5" fill="#1e2030" stroke="#22c55e" stroke-width="1.2"/>
  <text x="450" y="206" text-anchor="middle" fill="#22c55e" font-size="11">Mantine</text>
  <text x="450" y="221" text-anchor="middle" fill="#6b7280" font-size="10">Input: e.target.value</text>
  <text x="450" y="235" text-anchor="middle" fill="#6b7280" font-size="10">Select: value directly</text>

  <rect x="506" y="188" width="130" height="58" rx="5" fill="#1e2030" stroke="#22c55e" stroke-width="1.2"/>
  <text x="571" y="206" text-anchor="middle" fill="#22c55e" font-size="11">Chakra / MUI</text>
  <text x="571" y="221" text-anchor="middle" fill="#6b7280" font-size="10">Checkbox:</text>
  <text x="571" y="235" text-anchor="middle" fill="#6b7280" font-size="10">checked === true</text>

  <!-- Adapter labels below -->
  <text x="90" y="262" text-anchor="middle" fill="#f59e0b" font-size="10">no adapter needed</text>
  <text x="210" y="262" text-anchor="middle" fill="#f59e0b" font-size="10">discard event arg</text>
  <text x="330" y="262" text-anchor="middle" fill="#f59e0b" font-size="10">convert dayjs → ISO</text>
  <text x="450" y="262" text-anchor="middle" fill="#f59e0b" font-size="10">no adapter needed</text>
  <text x="571" y="262" text-anchor="middle" fill="#f59e0b" font-size="10">normalize to boolean</text>

  <!-- Legend -->
  <rect x="20" y="296" width="10" height="10" rx="2" fill="#4f6ef7"/>
  <text x="36" y="306" fill="#9ca3af" font-size="10">TanStack Form layer</text>
  <rect x="160" y="296" width="10" height="10" rx="2" fill="#f59e0b"/>
  <text x="176" y="306" fill="#9ca3af" font-size="10">Adapter (value normalization)</text>
  <rect x="360" y="296" width="10" height="10" rx="2" fill="#22c55e"/>
  <text x="376" y="306" fill="#9ca3af" font-size="10">Library component</text>

  <text x="330" y="345" text-anchor="middle" fill="#374151" font-size="10">All libraries reduce to: extract scalar → call field.handleChange(scalar)</text>
</svg>

---

### Handling `isTouched` and Error Display Timing

Library components vary in when they visually surface errors. A common convention is to show errors only after the field has been touched:

```tsx
{(field) => {
  const showError = field.state.meta.isTouched && field.state.meta.errors.length > 0
  return (
    <TextField
      error={showError}
      helperText={showError ? field.state.meta.errors[0] : ''}
      value={field.state.value}
      onChange={(e) => field.handleChange(e.target.value)}
      onBlur={field.handleBlur}
    />
  )
}}
```

After submission, show errors regardless of `isTouched`:

```tsx
const isSubmitted = form.useStore((s) => s.isSubmitted)

const showError =
  (field.state.meta.isTouched || isSubmitted) &&
  field.state.meta.errors.length > 0
```

---

### Integrating Rich Input Components

**Rich text editors** (e.g. TipTap, Quill) manage their own internal state and emit content via callbacks. Treat them as value-direct components:

```tsx
import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'

<form.Field name="body">
  {(field) => {
    const editor = useEditor({
      extensions: [StarterKit],
      content: field.state.value,
      onUpdate: ({ editor }) => {
        field.handleChange(editor.getHTML())
      },
    })

    return <EditorContent editor={editor} onBlur={field.handleBlur} />
  }}
</form.Field>
```

> [Inference] Using `useEditor` inside a render prop may cause the editor to reinitialize on parent re-renders. Consider lifting the editor instance outside the render prop or using `useMemo`. Behavior is not guaranteed.

**File inputs** are uncontrolled by nature. Read the `FileList` from the event:

```tsx
<form.Field name="avatar">
  {(field) => (
    <input
      type="file"
      accept="image/*"
      onBlur={field.handleBlur}
      onChange={(e) => {
        const file = e.target.files?.[0] ?? null
        field.handleChange(file)
      }}
    />
  )}
</form.Field>
```

---

### Common Mistakes

**Passing `field.handleChange` directly to an event-based onChange**

```tsx
// Wrong — handleChange receives the event object, not the value
<Input onChange={field.handleChange} />

// Correct
<Input onChange={(e) => field.handleChange(e.target.value)} />
```

**Forgetting `onBlur` on library components**

```tsx
// isTouched never becomes true — validation on blur won't fire
<Select value={field.state.value} onValueChange={field.handleChange} />

// Correct
<Select
  value={field.state.value}
  onValueChange={field.handleChange}
  onOpenChange={(open) => { if (!open) field.handleBlur() }}
/>
```

> [Inference] Some library components (like Radix `Select`) do not expose an `onBlur` prop directly. Using `onOpenChange` to detect close is a common workaround but is not an official pattern. Behavior may vary.

**Using `defaultValue` instead of `value` on controlled components**

```tsx
// Uncontrolled — TanStack Form cannot sync its state
<Input defaultValue={field.state.value} />

// Controlled — correct
<Input value={field.state.value} />
```

---

### Summary

TanStack Form's headless design means integration with any component library reduces to a consistent pattern: bind `value`, adapt `onChange` to pass a scalar, wire `onBlur`, and map error state to the library's error props. The only variation per library is the shape of `onChange` output. Building small reusable wrapper components per field type eliminates repetition and standardizes the adapter layer across the codebase.

**Related Topics**
- Building a custom field component library on top of TanStack Form
- Accessibility wiring (`aria-invalid`, `aria-describedby`) in form fields
- Error display strategies — touched, submitted, and always-on modes
- Integrating file and rich-text inputs with array field patterns
- Form field wrappers with TypeScript generics for type-safe `name` props
- Controller pattern comparison: TanStack Form vs React Hook Form