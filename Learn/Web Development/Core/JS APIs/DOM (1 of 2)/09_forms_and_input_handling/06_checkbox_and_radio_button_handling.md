## Checkbox and Radio Button Handling


### Checkbox State Management

Checkboxes maintain a binary state accessible through the `checked` property. Reading `element.checked` returns `true` or `false`. Setting `element.checked = true` or `element.checked = false` programmatically changes the state.

The `value` attribute defines what gets submitted with forms but does not reflect the checked state. The default value is "on" if not specified. The actual submitted data depends on the `checked` state, not the `value` alone.

```javascript
const checkbox = document.getElementById('myCheckbox');
checkbox.checked = true; // Check the box
const isChecked = checkbox.checked; // Read state
const submittedValue = checkbox.value; // Get the value attribute
```

### Radio Button Groups

Radio buttons sharing the same `name` attribute form a mutually exclusive group. Only one radio button within a group can be checked at any time. Checking one radio button automatically unchecks others in the same group.

```html
<input type="radio" name="choice" value="option1">
<input type="radio" name="choice" value="option2">
<input type="radio" name="choice" value="option3">
```

Radio buttons with different `name` attributes operate independently and do not affect each other.

### Accessing Checked Radio Button

Finding the selected radio button in a group requires querying all buttons with that name:

```javascript
const selectedRadio = document.querySelector('input[name="choice"]:checked');
const selectedValue = selectedRadio ? selectedRadio.value : null;
```

Alternatively, iterate through all radio buttons in the group:

```javascript
const radios = document.getElementsByName('choice');
let selectedValue;
for (let radio of radios) {
  if (radio.checked) {
    selectedValue = radio.value;
    break;
  }
}
```

Using `RadioNodeList` from forms:

```javascript
const form = document.getElementById('myForm');
const selectedValue = form.elements['choice'].value; // Returns checked radio's value
```

### Change Event Handling

The `change` event fires when a checkbox or radio button's state changes through user interaction. For checkboxes, this occurs on each toggle. For radio buttons, it fires when a new selection is made.

```javascript
checkbox.addEventListener('change', function(event) {
  console.log('Checked:', event.target.checked);
});

radioButton.addEventListener('change', function(event) {
  console.log('Selected value:', event.target.value);
});
```

The `change` event bubbles, allowing delegation:

```javascript
form.addEventListener('change', function(event) {
  if (event.target.type === 'checkbox') {
    // Handle checkbox change
  } else if (event.target.type === 'radio') {
    // Handle radio change
  }
});
```

### Click vs Change Events

The `click` event fires on every click, even if the state doesn't change (clicking an already-checked radio button triggers `click` but not `change`). The `change` event only fires when the checked state actually changes.

For radio buttons, `change` fires on the newly selected button but not on the previously selected button that gets unchecked. The `click` event fires on both.

### Input Event Behavior

The `input` event does not fire for checkboxes or radio buttons. Use `change` instead for detecting state changes.

### Indeterminate State

Checkboxes support an indeterminate (mixed) state distinct from checked or unchecked. This state must be set programmatically via the `indeterminate` property and does not persist through form submission.

```javascript
checkbox.indeterminate = true; // Visual indeterminate state
```

The `indeterminate` state is visual only. The underlying `checked` property remains either `true` or `false`. This state commonly represents partial selection in hierarchical lists where some but not all child items are selected.

Clicking an indeterminate checkbox clears the indeterminate state and toggles the checked property normally.

### Programmatic State Changes

Setting `checked` programmatically does not trigger `change` or `click` events. Events only fire from user interaction. To trigger handlers when programmatically changing state, dispatch events manually:

```javascript
checkbox.checked = true;
checkbox.dispatchEvent(new Event('change', { bubbles: true }));
```

### Form Submission Behavior

Checked checkboxes and the selected radio button submit their `value` attributes with the form. Unchecked checkboxes submit nothing. Radio button groups submit only the checked radio's value, or nothing if no radio is selected.

```html
<!-- If checked, submits: agree=yes -->
<input type="checkbox" name="agree" value="yes" checked>

<!-- Submits: choice=option2 -->
<input type="radio" name="choice" value="option1">
<input type="radio" name="choice" value="option2" checked>
<input type="radio" name="choice" value="option3">
```

### Getting All Checked Checkboxes

Retrieving multiple checked checkboxes from a group or form:

```javascript
const checkedBoxes = document.querySelectorAll('input[type="checkbox"]:checked');
const values = Array.from(checkedBoxes).map(cb => cb.value);
```

With a specific name:

```javascript
const checkedBoxes = document.querySelectorAll('input[name="options"]:checked');
```

### Default Checked State

The `defaultChecked` property reflects the presence of the `checked` attribute in HTML, while `checked` reflects the current state. Resetting to the original state:

```javascript
checkbox.checked = checkbox.defaultChecked;
```

Form reset operations restore inputs to their `defaultChecked` state automatically.

### Label Association

Clicking a `<label>` associated with a checkbox or radio button toggles the input. Association occurs through matching `for` attribute and `id`:

```html
<input type="checkbox" id="agree">
<label for="agree">I agree</label>
```

Or by nesting:

```html
<label>
  <input type="checkbox">
  I agree
</label>
```

Click events on labels propagate to their associated inputs. Stopping propagation on the label prevents the input from toggling.

### Accessibility Attributes

The `aria-checked` attribute can be used on custom checkbox implementations but is unnecessary on native inputs. Screen readers automatically announce the checked state of native checkboxes and radio buttons.

The `aria-describedby` and `aria-labelledby` attributes enhance accessibility by associating additional descriptive text:

```html
<input type="checkbox" id="terms" aria-describedby="terms-desc">
<span id="terms-desc">You must agree to continue</span>
```

### CSS Pseudo-Classes

The `:checked` pseudo-class selects checked checkboxes and radio buttons:

```css
input[type="checkbox"]:checked {
  /* Styles for checked checkboxes */
}

input[type="radio"]:checked + label {
  /* Styles for labels of checked radios */
}
```

The `:indeterminate` pseudo-class targets checkboxes in the indeterminate state.

### Validation

Required checkboxes and radio buttons use the `required` attribute. For checkboxes, `required` means the checkbox must be checked. For radio groups, at least one radio must be selected.

```html
<input type="checkbox" name="agree" required>
<input type="radio" name="choice" value="a" required>
<input type="radio" name="choice" value="b">
```

Checking validity programmatically:

```javascript
if (!checkbox.validity.valid) {
  console.log('Checkbox must be checked');
}

const radioGroup = document.getElementsByName('choice');
const isValid = Array.from(radioGroup).some(radio => radio.checked);
```

### Handling Radio Button Deselection

[Inference] Native radio buttons cannot be deselected by clicking the same button again. Implementing deselection requires custom JavaScript:

```javascript
let lastChecked = null;

radios.forEach(radio => {
  radio.addEventListener('click', function() {
    if (this === lastChecked) {
      this.checked = false;
      lastChecked = null;
    } else {
      lastChecked = this;
    }
  });
});
```

[Unverified] This pattern is not standard browser behavior and may conflict with user expectations for radio button interaction.

### Performance with Large Groups

For forms with many checkboxes or radio buttons, event delegation on a container element reduces memory overhead compared to individual listeners on each input:

```javascript
container.addEventListener('change', function(event) {
  if (event.target.type === 'checkbox' || event.target.type === 'radio') {
    // Handle state change
  }
});
```

### FormData API Integration

The FormData API automatically includes checked checkboxes and the selected radio button:

```javascript
const form = document.getElementById('myForm');
const formData = new FormData(form);

// Iterate entries
for (let [name, value] of formData.entries()) {
  console.log(name, value);
}
```

Unchecked checkboxes do not appear in FormData. Radio groups with no selection also do not appear.

### Custom Styling and Hidden Inputs

Custom-styled checkboxes and radio buttons typically hide the native input and style a sibling element:

```css
input[type="checkbox"] {
  position: absolute;
  opacity: 0;
}

input[type="checkbox"] + .custom-checkbox {
  /* Custom styles */
}

input[type="checkbox"]:checked + .custom-checkbox {
  /* Checked state styles */
}
```

The native input remains in the DOM for form submission and accessibility. Keyboard interaction and screen reader functionality continue working through the hidden native input.

### Keyboard Interaction

Native checkboxes toggle with the Space key. Radio buttons navigate with arrow keys (within the same name group) and toggle with Space or Enter. Tab key moves between different form controls.

[Inference] Custom implementations must replicate this keyboard behavior to maintain accessibility standards. Failing to do so creates barriers for keyboard-only users.

### State Synchronization Across Multiple Checkboxes

Implementing "select all" functionality with checkboxes:

```javascript
const selectAll = document.getElementById('selectAll');
const checkboxes = document.querySelectorAll('.item-checkbox');

selectAll.addEventListener('change', function() {
  checkboxes.forEach(cb => cb.checked = this.checked);
});

checkboxes.forEach(cb => {
  cb.addEventListener('change', function() {
    selectAll.checked = Array.from(checkboxes).every(cb => cb.checked);
    selectAll.indeterminate = Array.from(checkboxes).some(cb => cb.checked) && 
                              !Array.from(checkboxes).every(cb => cb.checked);
  });
});
```

### Storage and Persistence

Persisting checkbox and radio button states across page loads:

```javascript
// Save state
checkbox.addEventListener('change', function() {
  localStorage.setItem(this.id, this.checked);
});

// Restore state
const savedState = localStorage.getItem(checkbox.id);
if (savedState !== null) {
  checkbox.checked = savedState === 'true';
}
```

For radio groups:

```javascript
// Save
radioButton.addEventListener('change', function() {
  localStorage.setItem(this.name, this.value);
});

// Restore
const savedValue = localStorage.getItem('radioGroupName');
if (savedValue) {
  const radio = document.querySelector(`input[name="radioGroupName"][value="${savedValue}"]`);
  if (radio) radio.checked = true;
}
```

---

