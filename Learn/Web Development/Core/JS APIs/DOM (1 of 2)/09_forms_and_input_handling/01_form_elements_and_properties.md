## Form Elements and Properties


### HTMLFormElement

The `<form>` element provides the container and submission mechanism for user input controls.

**Core Properties**

```javascript
const form = document.getElementById('myForm');

// Form identification
form.name;              // String: form name attribute
form.id;                // String: form id attribute
form.action;            // String: URL for submission
form.method;            // String: "get" or "post" (lowercase)
form.enctype;           // String: encoding type
form.target;            // String: browsing context for response
form.acceptCharset;     // String: accepted character encodings
form.noValidate;        // Boolean: skip validation on submit
form.autocomplete;      // String: "on" or "off"
form.elements;          // HTMLFormControlsCollection: all form controls
form.length;            // Number: count of form controls
```

**enctype Values**

- `"application/x-www-form-urlencoded"` (default)
- `"multipart/form-data"` (required for file uploads)
- `"text/plain"` (rarely used, not recommended)

**Elements Collection**

```javascript
// Access by index
form.elements[0];

// Access by name attribute
form.elements['username'];
form.elements.username;

// RadioNodeList for same-named elements
form.elements['gender']; // Returns RadioNodeList for radio group

// Iterate all controls
for (let element of form.elements) {
  console.log(element.name, element.value);
}

// HTMLFormControlsCollection is live
console.log(form.elements.length); // Updates automatically
```

**Form Methods**

```javascript
// Programmatic submission
form.submit(); // Does NOT trigger submit event or validation

// Request submission with validation
form.requestSubmit(); // Triggers submit event and validation
form.requestSubmit(submitButton); // Simulate specific button click

// Reset to default values
form.reset(); // Triggers reset event

// Validation
form.checkValidity(); // Returns boolean, fires invalid events
form.reportValidity(); // Shows validation UI, returns boolean
```

**Form Submission Behavior**

```javascript
form.addEventListener('submit', (event) => {
  event.preventDefault(); // Prevent default submission
  
  // Custom submission logic
  const formData = new FormData(form);
  fetch(form.action, {
    method: form.method,
    body: formData
  });
});
```

**Named Access** Forms support named property access for controls:

```javascript
// If form has <input name="email">
form.email.value; // Direct access to input
form['email'].value; // Bracket notation

// Conflicts with form properties use elements
form.elements.action; // Access control named "action"
```

### Common Form Control Properties

Properties shared across `<input>`, `<textarea>`, `<select>`, and `<button>` elements.

**Identification and Association**

```javascript
const input = document.querySelector('input');

input.name;              // String: submitted field name
input.id;                // String: element id
input.form;              // HTMLFormElement: owner form (readonly)
input.labels;            // NodeList: associated <label> elements (readonly)
```

**Value and State**

```javascript
input.value;             // String: current value
input.defaultValue;      // String: initial value from HTML
input.valueAsNumber;     // Number: parsed numeric value (number/date inputs)
input.valueAsDate;       // Date: parsed date value (date inputs)

// Check if value changed from default
const isModified = input.value !== input.defaultValue;
```

**Validation States**

```javascript
input.validity;          // ValidityState object (readonly)
input.validationMessage; // String: validation error message (readonly)
input.willValidate;      // Boolean: participates in validation (readonly)

// Validity checks
input.checkValidity();   // Boolean: valid without UI
input.reportValidity();  // Boolean: valid with UI feedback
input.setCustomValidity('Custom error message'); // Set custom error
```

**Disabled and Readonly**

```javascript
input.disabled;          // Boolean: disabled state
input.readOnly;          // Boolean: readonly state (input/textarea only)

// disabled vs readonly differences:
// - disabled: not submitted, not focusable, not validatable
// - readonly: submitted, focusable, validatable
```

**Autocomplete**

```javascript
input.autocomplete;      // String: autocomplete hint
// Values: "on", "off", or token(s) like "email", "current-password", "cc-number"
```

### ValidityState Object

Returned by the `validity` property on form controls.

```javascript
const validity = input.validity;

validity.valid;              // Boolean: all checks pass
validity.valueMissing;       // Boolean: required but empty
validity.typeMismatch;       // Boolean: doesn't match type (email, url, etc.)
validity.patternMismatch;    // Boolean: doesn't match pattern
validity.tooLong;            // Boolean: exceeds maxlength
validity.tooShort;           // Boolean: below minlength
validity.rangeUnderflow;     // Boolean: below min
validity.rangeOverflow;      // Boolean: above max
validity.stepMismatch;       // Boolean: doesn't match step
validity.badInput;           // Boolean: unparseable input
validity.customError;        // Boolean: custom error set via setCustomValidity()
```

**Validation Example**

```javascript
function validateInput(input) {
  const v = input.validity;
  
  if (v.valueMissing) return 'This field is required';
  if (v.typeMismatch) return 'Invalid format';
  if (v.tooShort) return `Minimum ${input.minLength} characters`;
  if (v.tooLong) return `Maximum ${input.maxLength} characters`;
  if (v.rangeUnderflow) return `Minimum value is ${input.min}`;
  if (v.rangeOverflow) return `Maximum value is ${input.max}`;
  if (v.patternMismatch) return 'Invalid format';
  if (v.customError) return input.validationMessage;
  
  return '';
}
```

### Input Element Specifics

**Type-Specific Properties**

Different `input.type` values expose different properties:

```javascript
// Text-based inputs (text, email, password, search, tel, url)
input.maxLength;         // Number: maximum character length
input.minLength;         // Number: minimum character length
input.size;              // Number: visible width in characters
input.pattern;           // String: regex pattern for validation
input.placeholder;       // String: placeholder text

// Number inputs
input.min;               // String: minimum value
input.max;               // String: maximum value
input.step;              // String: step increment
input.valueAsNumber;     // Number: numeric value or NaN

// Date/time inputs (date, datetime-local, time, month, week)
input.min;               // String: minimum date/time
input.max;               // String: maximum date/time
input.step;              // String: step in seconds
input.valueAsDate;       // Date: parsed date or null
input.valueAsNumber;     // Number: milliseconds since epoch

// Checkbox/radio
input.checked;           // Boolean: checked state
input.defaultChecked;    // Boolean: initial checked state from HTML
input.indeterminate;     // Boolean: indeterminate state (checkbox only, not submitted)

// File input
input.files;             // FileList: selected files (readonly)
input.accept;            // String: accepted file types
input.multiple;          // Boolean: allow multiple files

// Range input
input.min;               // String: minimum value
input.max;               // String: maximum value
input.step;              // String: step increment
input.value;             // String: current value (always valid)

// Hidden input
input.value;             // String: hidden value
```

**Input Type Property**

```javascript
input.type;              // String: input type (lowercase)

// Changing type
input.type = 'email';    // Changes input behavior and validation

// [Inference] Changing type may reset value in some browsers if incompatible
```

**Checkbox and Radio States**

```javascript
const checkbox = document.querySelector('input[type="checkbox"]');
checkbox.checked = true;
checkbox.indeterminate = true; // Visual only, not a third state for submission

const radio = document.querySelector('input[type="radio"][name="group"]');
radio.checked = true; // Unchecks other radios in same name group

// Get checked radio in group
const checked = document.querySelector('input[name="group"]:checked');
const value = form.elements['group'].value; // RadioNodeList.value
```

**File Input**

```javascript
const fileInput = document.querySelector('input[type="file"]');

fileInput.files;         // FileList (readonly)
fileInput.files[0];      // First File object
fileInput.files.length;  // Number of selected files

// Clear selection
fileInput.value = '';    // Only way to clear files

// Programmatically setting files (modern browsers)
const dt = new DataTransfer();
dt.items.add(fileObject);
fileInput.files = dt.files;

// File properties
const file = fileInput.files[0];
file.name;               // String: filename
file.size;               // Number: bytes
file.type;               // String: MIME type
file.lastModified;       // Number: timestamp
```

**Number Value Handling**

```javascript
const numberInput = document.querySelector('input[type="number"]');

numberInput.value = '42.5';
numberInput.valueAsNumber; // 42.5

numberInput.value = 'invalid';
numberInput.valueAsNumber; // NaN
numberInput.validity.badInput; // true

// Stepping
numberInput.stepUp();    // Increase by step
numberInput.stepUp(5);   // Increase by 5 * step
numberInput.stepDown();  // Decrease by step
numberInput.stepDown(3); // Decrease by 3 * step
```

**Date Value Handling**

```javascript
const dateInput = document.querySelector('input[type="date"]');

dateInput.value = '2025-12-15';
dateInput.valueAsDate;   // Date object in UTC
dateInput.valueAsNumber; // Milliseconds since epoch

// [Inference] valueAsDate may return null for invalid dates
// Time zones can be complex with date inputs
```

**Selection API (Text Inputs)**

```javascript
const textInput = document.querySelector('input[type="text"]');

textInput.selectionStart; // Number: start of selection
textInput.selectionEnd;   // Number: end of selection
textInput.selectionDirection; // String: "forward", "backward", "none"

// Methods
textInput.select();      // Select all text
textInput.setSelectionRange(0, 5); // Select first 5 characters
textInput.setSelectionRange(0, 5, 'forward'); // With direction
textInput.setRangeText('new', 0, 3); // Replace range with text
```

### Textarea Element

Shares most properties with text inputs, with specific differences:

```javascript
const textarea = document.querySelector('textarea');

textarea.value;          // String: current content
textarea.defaultValue;   // String: initial content (innerHTML)
textarea.textLength;     // Number: length of value (readonly)

// Dimensions
textarea.cols;           // Number: visible columns
textarea.rows;           // Number: visible rows

// Wrapping
textarea.wrap;           // String: "soft" (default), "hard", "off"
// "hard": line breaks included in submitted value
// "soft": line breaks for display only

// Selection API (same as text inputs)
textarea.selectionStart;
textarea.selectionEnd;
textarea.selectionDirection;
textarea.select();
textarea.setSelectionRange(start, end);
```

**Value vs innerHTML**

```javascript
// Setting value
textarea.value = 'Hello\nWorld'; // Correct way
textarea.textContent = 'Hello\nWorld'; // Also works
textarea.innerHTML = 'Hello<br>World'; // Incorrect, will show literal <br>

// Reading initial value
const initial = textarea.defaultValue; // Returns initial HTML content
```

### Select Element

```javascript
const select = document.querySelector('select');

select.value;            // String: value of selected option
select.selectedIndex;    // Number: index of selected option (-1 if none)
select.selectedOptions;  // HTMLCollection: selected <option> elements
select.options;          // HTMLOptionsCollection: all <option> elements
select.length;           // Number: number of options
select.multiple;         // Boolean: allow multiple selections
select.size;             // Number: visible options (0 = dropdown, >0 = listbox)

// Access options
select.options[0];
select.options.namedItem('optionName');
select.options.item(0);

// Selected option(s)
const selected = select.selectedOptions[0]; // First selected
const allSelected = [...select.selectedOptions]; // All selected (multiple)
```

**Option Manipulation**

```javascript
// Add option
const option = new Option('Text', 'value', false, true);
// Parameters: text, value, defaultSelected, selected
select.add(option);
select.add(option, index); // Insert at index
select.add(option, beforeOption); // Insert before another option

// Remove option
select.remove(index);
select.options[index].remove();
select.options[index] = null; // Legacy removal

// Clear all options
select.options.length = 0;
// or
while (select.options.length > 0) {
  select.remove(0);
}
```

**Multiple Selection**

```javascript
const multiSelect = document.querySelector('select[multiple]');

// Get all selected values
const values = [...multiSelect.selectedOptions].map(opt => opt.value);

// Set multiple selections
multiSelect.options[0].selected = true;
multiSelect.options[2].selected = true;
multiSelect.options[5].selected = true;

// Clear selections
[...multiSelect.options].forEach(opt => opt.selected = false);
```

**Form Association**

```javascript
// Select value in FormData
const formData = new FormData(form);
formData.get('selectName'); // Single value
formData.getAll('selectName'); // Array (for multiple select)
```

### Option Element

```javascript
const option = select.options[0];

option.value;            // String: submitted value
option.text;             // String: displayed text
option.label;            // String: label attribute or text
option.selected;         // Boolean: selected state
option.defaultSelected;  // Boolean: initial selected state (selected attribute)
option.disabled;         // Boolean: disabled state
option.index;            // Number: position in parent select (readonly)
option.form;             // HTMLFormElement: owner form (readonly)
```

**Option Constructor**

```javascript
// new Option(text, value, defaultSelected, selected)
const opt1 = new Option('Display Text', 'value1');
const opt2 = new Option('Text', 'value', false, true); // Selected
const opt3 = new Option('Text'); // value defaults to text

select.add(opt1);
```

### OptGroup Element

```javascript
const optgroup = document.querySelector('optgroup');

optgroup.label;          // String: group label
optgroup.disabled;       // Boolean: disables all options in group
```

**Structure**

```html
<select>
  <optgroup label="Group 1">
    <option value="a">Option A</option>
    <option value="b">Option B</option>
  </optgroup>
  <optgroup label="Group 2" disabled>
    <option value="c">Option C</option>
  </optgroup>
</select>
```

### Button Element

```javascript
const button = document.querySelector('button');

button.type;             // String: "submit" (default), "reset", "button"
button.value;            // String: submitted value (if type="submit")
button.name;             // String: field name for submission
button.disabled;         // Boolean: disabled state
button.form;             // HTMLFormElement: owner form (readonly)
button.formAction;       // String: override form action (submit buttons)
button.formEnctype;      // String: override form enctype
button.formMethod;       // String: override form method
button.formNoValidate;   // Boolean: override form novalidate
button.formTarget;       // String: override form target
```

**Button Type Behavior**

```javascript
// type="submit" (default)
// - Submits form when clicked
// - Triggers form validation
// - Can override form attributes

// type="reset"
// - Resets form to default values
// - Triggers reset event

// type="button"
// - No default behavior
// - Use for custom JavaScript functionality
```

**Submit Button Values**

```javascript
// Only clicked submit button's name/value is submitted
<button type="submit" name="action" value="save">Save</button>
<button type="submit" name="action" value="delete">Delete</button>

// FormData will include clicked button
form.addEventListener('submit', (e) => {
  const formData = new FormData(e.target);
  console.log(formData.get('action')); // "save" or "delete"
});
```

### Fieldset Element

```javascript
const fieldset = document.querySelector('fieldset');

fieldset.disabled;       // Boolean: disables all descendant form controls
fieldset.elements;       // HTMLFormControlsCollection: contained controls (readonly)
fieldset.form;           // HTMLFormElement: owner form (readonly)
fieldset.name;           // String: fieldset name
fieldset.type;           // String: always "fieldset" (readonly)
```

**Disabled Propagation**

```javascript
// Disabling fieldset disables all controls inside
fieldset.disabled = true;

// Except <legend> content
<fieldset disabled>
  <legend><button>Enabled</button></legend>
  <input> <!-- Disabled -->
</fieldset>
```

### Label Element

```javascript
const label = document.querySelector('label');

label.htmlFor;           // String: id of associated control (for attribute)
label.control;           // HTMLElement: associated form control (readonly)
label.form;              // HTMLFormElement: owner form (readonly)
```

**Label Association Methods**

```javascript
// Explicit association via for/id
<label for="username">Username</label>
<input id="username" name="username">

label.htmlFor = 'username';
label.control; // Returns the input element

// Implicit association (nesting)
<label>
  Username
  <input name="username">
</label>

// Clicking label focuses/activates control
label.addEventListener('click', () => {
  // This happens automatically before event reaches handler
  // label.control.focus() or label.control.click() already occurred
});
```

### Output Element

```javascript
const output = document.querySelector('output');

output.value;            // String: current value
output.defaultValue;     // String: initial value
output.htmlFor;          // DOMTokenList: ids of related form controls
output.form;             // HTMLFormElement: owner form (readonly)
output.name;             // String: field name
output.type;             // String: always "output" (readonly)
output.labels;           // NodeList: associated labels (readonly)
```

**Usage Pattern**

```javascript
<input type="number" id="a" value="5">
<input type="number" id="b" value="3">
<output for="a b" name="result"></output>

const a = document.getElementById('a');
const b = document.getElementById('b');
const output = document.querySelector('output');

function calculate() {
  output.value = Number(a.value) + Number(b.value);
}

a.addEventListener('input', calculate);
b.addEventListener('input', calculate);
calculate();
```

### FormData API

Interface for constructing and manipulating form data:

```javascript
// Create from form
const formData = new FormData(form);

// Create empty
const formData = new FormData();

// Methods
formData.append('key', 'value');
formData.append('file', fileObject);
formData.set('key', 'value');    // Replaces existing
formData.get('key');             // First value
formData.getAll('key');          // All values as array
formData.has('key');             // Boolean
formData.delete('key');

// Iteration
for (let [key, value] of formData.entries()) {
  console.log(key, value);
}

for (let key of formData.keys()) {
  console.log(key);
}

for (let value of formData.values()) {
  console.log(value);
}
```

**Successful Controls**

Only certain form controls are included in FormData:

```javascript
// Included:
// - <input> (except type="image" without click, file inputs with files)
// - <textarea>
// - <select>
// - <button type="submit"> that was clicked

// Excluded:
// - Disabled controls
// - Unchecked checkboxes/radios
// - Buttons not clicked
// - Controls without name attribute
// - <input type="image"> (special handling)
```

**File Handling**

```javascript
// Single file
formData.append('avatar', fileInput.files[0]);

// Multiple files
for (let file of fileInput.files) {
  formData.append('photos[]', file);
}

// Blob with filename
formData.append('data', blob, 'filename.json');
```

### Input Modes

The `inputmode` attribute provides hints for virtual keyboards:

```javascript
input.inputMode;         // String: input mode hint

// Values:
// "none" - No virtual keyboard
// "text" - Standard keyboard
// "decimal" - Decimal numeric keyboard
// "numeric" - Numeric keyboard
// "tel" - Telephone keypad
// "search" - Search-optimized keyboard
// "email" - Email-optimized keyboard
// "url" - URL-optimized keyboard
```

**[Inference]** Input mode suggestions:

```javascript
<input type="text" inputmode="numeric"> // Numbers in text field
<input type="tel"> // Phone numbers (automatically suggests numeric keyboard)
<input type="number" inputmode="decimal"> // Decimals with number validation
```

### Autofill Tokens

The `autocomplete` attribute uses standardized tokens:

```javascript
input.autocomplete = 'email';
input.autocomplete = 'current-password';
input.autocomplete = 'new-password';
input.autocomplete = 'cc-number';
input.autocomplete = 'cc-exp';
input.autocomplete = 'shipping street-address';
input.autocomplete = 'section-blue shipping name';

// Common tokens:
// Personal: name, given-name, family-name, email, username, tel, bday
// Address: street-address, address-line1, address-line2, city, postal-code, country
// Payment: cc-name, cc-number, cc-exp, cc-csc
// Authentication: current-password, new-password, one-time-code
// Modifiers: shipping, billing, section-*
```

### Form Validation Events

```javascript
// invalid - Fired on individual controls during validation
input.addEventListener('invalid', (event) => {
  event.preventDefault(); // Prevent default validation UI
  // Custom validation display
});

// submit - Fired on form before submission
form.addEventListener('submit', (event) => {
  if (!form.checkValidity()) {
    event.preventDefault();
    // Handle validation errors
  }
});

// reset - Fired on form when reset
form.addEventListener('reset', (event) => {
  // Can prevent reset
  if (unsavedChanges) {
    event.preventDefault();
  }
});

// change - Fired on select, checkbox, radio when value commits
input.addEventListener('change', (event) => {
  console.log('Value changed to:', event.target.value);
});

// input - Fired during text input
input.addEventListener('input', (event) => {
  console.log('Current value:', event.target.value);
});
```

### Input Event Properties

```javascript
input.addEventListener('input', (event) => {
  event.inputType;       // String: type of input action
  event.data;            // String: inserted data or null
  event.dataTransfer;    // DataTransfer: for paste/drop or null
  event.isComposing;     // Boolean: during IME composition
  
  // inputType values include:
  // "insertText", "deleteContentBackward", "insertFromPaste",
  // "insertFromDrop", "deleteByCut", etc.
});
```

### Custom Validation Patterns

```javascript
// Custom validation message
input.setCustomValidity('Username already taken');
input.reportValidity(); // Show error

// Clear custom error
input.setCustomValidity('');

// Async validation pattern
async function validateAsync(input) {
  const value = input.value;
  
  try {
    const available = await checkAvailability(value);
    if (!available) {
      input.setCustomValidity('This username is taken');
    } else {
      input.setCustomValidity('');
    }
  } catch (error) {
    input.setCustomValidity('Unable to verify availability');
  }
  
  input.reportValidity();
}

input.addEventListener('blur', () => validateAsync(input));
```

### Form Submission via JavaScript

```javascript
// Method 1: Traditional form submission (full page load)
form.submit(); // Does NOT fire submit event or validate

// Method 2: Request submission (with validation)
form.requestSubmit(); // Fires submit event, validates

// Method 3: Fetch API
form.addEventListener('submit', async (event) => {
  event.preventDefault();
  
  const formData = new FormData(form);
  
  try {
    const response = await fetch(form.action, {
      method: form.method,
      body: formData
    });
    
    if (response.ok) {
      // Handle success
    }
  } catch (error) {
    // Handle error
  }
});

// Method 4: URLSearchParams (for URL-encoded data)
const params = new URLSearchParams(new FormData(form));
fetch(form.action, {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: params
});
```

### Constraint Validation API Summary

```javascript
// Check validity
element.checkValidity();    // Boolean, fires invalid event
element.reportValidity();   // Boolean, shows UI

// Validation state
element.validity;           // ValidityState object
element.validationMessage;  // String (readonly)
element.willValidate;       // Boolean (readonly)

// Custom validation
element.setCustomValidity('Error message');
element.setCustomValidity(''); // Clear

// Form-level validation
form.checkValidity();       // Checks all controls
form.reportValidity();      // Checks and shows UI for all controls
```

### Disabled vs Readonly Comparison

```javascript
// disabled
input.disabled = true;
// - Not submitted in form data
// - Cannot receive focus
// - Not validated
// - Typically styled differently (grayed out)
// - Applies to all form controls

// readonly
input.readOnly = true;
// - IS submitted in form data
// - CAN receive focus
// - IS validated
// - Can be styled normally
// - Only applies to input and textarea
// - User cannot modify but scripts can
```

### Browser Inconsistencies

**[Inference]** Common cross-browser issues:

**File Input**

- Clearing files: only `input.value = ''` is reliable
- Setting files programmatically: DataTransfer support varies
- File paths: never exposed for security reasons

**Date Inputs**

- Safari has limited date input support (older versions)
- Different default formats displayed to users
- `valueAsDate` time zone handling differs

**Number Inputs**

- Spinner button styling varies significantly
- Scientific notation handling differs
- Locale-specific decimal separators may cause issues

**Validation UI**

- Browser-native validation bubbles styled differently
- Positioning and timing varies
- Some mobile browsers show different validation approaches

**Form Submission**

- Implicit submission (pressing Enter) behavior varies slightly
- Multiple submit buttons with same name handled differently in edge cases

---

