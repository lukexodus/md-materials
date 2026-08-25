## Programmatic Positioning in Electron Menus


### Basic Positioning Attributes

Electron provides four attributes to control menu item placement: `id`, `before`, `after`, `beforeGroupContaining`, and `afterGroupContaining`.

### Using `before` and `after`

```javascript
const { Menu } = require('electron');

const template = [
  { id: '1', label: 'one', after: ['3'] },
  { id: '2', label: 'two', before: ['1'] },
  { id: '3', label: 'three' }
];

const menu = Menu.buildFromTemplate(template);
// Results in order: three, two, one
```

### How It Works

**Step 1:** Item ‘1’ says “place me after item ‘3’”

**Step 2:** Item ‘2’ says “place me before item ‘1’”

**Step 3:** Item ‘3’ has no positioning constraints

**Final order:** 3 → 2 → 1

### Multiple References

```javascript
const template = [
  { id: 'file', label: 'File' },
  { id: 'edit', label: 'Edit', after: ['file'] },
  { id: 'view', label: 'View', after: ['edit'] },
  { id: 'help', label: 'Help', after: ['view'] }
];

// Results in: File, Edit, View, Help
```

### Using Arrays for Multiple Positioning

```javascript
const template = [
  { id: 'save', label: 'Save' },
  { id: 'new', label: 'New', before: ['open', 'save'] },
  { id: 'open', label: 'Open' }
];

// 'new' will be placed before both 'open' and 'save'
// Results in: New, Open, Save
```

### Group Positioning with `beforeGroupContaining`

```javascript
const template = [
  { id: 'copy', label: 'Copy' },
  { id: 'paste', label: 'Paste' },
  { type: 'separator' },
  { id: 'selectAll', label: 'Select All' },
  { 
    id: 'undo', 
    label: 'Undo',
    beforeGroupContaining: ['copy']
  },
  { 
    id: 'redo', 
    label: 'Redo',
    after: ['undo']
  }
];

// Results in: Undo, Redo, [separator], Copy, Paste, [separator], Select All
```

### Group Positioning with `afterGroupContaining`

```javascript
const template = [
  { id: 'file1', label: 'File 1' },
  { id: 'file2', label: 'File 2' },
  { type: 'separator' },
  { id: 'edit1', label: 'Edit 1' },
  {
    id: 'recent',
    label: 'Recent Files',
    afterGroupContaining: ['file2']
  }
];

// 'recent' appears after the group containing 'file2'
// Results in: File 1, File 2, Recent Files, [separator], Edit 1
```

### Complex Example: Building an Edit Menu

```javascript
const template = [
  { id: 'cut', label: 'Cut' },
  { id: 'copy', label: 'Copy' },
  { id: 'paste', label: 'Paste' },
  { type: 'separator', id: 'sep1' },
  { id: 'selectAll', label: 'Select All' },
  
  // Insert undo/redo at the beginning
  { 
    id: 'undo', 
    label: 'Undo',
    beforeGroupContaining: ['cut']
  },
  { 
    id: 'redo', 
    label: 'Redo',
    after: ['undo']
  },
  
  // Insert delete after paste
  {
    id: 'delete',
    label: 'Delete',
    after: ['paste']
  }
];

const menu = Menu.buildFromTemplate(template);
// Results in:
// Undo
// Redo
// [separator]
// Cut
// Copy
// Paste
// Delete
// [separator]
// Select All
```

### Dynamic Menu with Positioning

```javascript
function buildFileMenu(recentFiles) {
  const template = [
    { id: 'new', label: 'New File' },
    { id: 'open', label: 'Open', after: ['new'] },
    { id: 'save', label: 'Save', after: ['open'] },
    { type: 'separator', id: 'sep1', after: ['save'] },
    { id: 'exit', label: 'Exit' }
  ];

  // Add recent files before exit
  recentFiles.forEach((file, index) => {
    template.push({
      id: `recent-${index}`,
      label: file,
      beforeGroupContaining: ['exit']
    });
  });

  return Menu.buildFromTemplate(template);
}

const menu = buildFileMenu(['file1.txt', 'file2.txt']);
// Results in:
// New File
// Open
// Save
// [separator]
// file1.txt
// file2.txt
// Exit
```

### Platform-Specific Positioning

```javascript
const { Menu } = require('electron');
const isMac = process.platform === 'darwin';

const template = [
  { id: 'file', label: 'File' },
  { id: 'edit', label: 'Edit', after: ['file'] },
  { id: 'view', label: 'View', after: ['edit'] },
  { id: 'window', label: 'Window', after: ['view'] }
];

// On macOS, add app menu at the beginning
if (isMac) {
  template.unshift({
    id: 'app',
    label: 'MyApp',
    beforeGroupContaining: ['file']
  });
}

const menu = Menu.buildFromTemplate(template);
```

### Inserting Items into Existing Submenus

```javascript
const template = [
  {
    label: 'Edit',
    submenu: [
      { id: 'cut', label: 'Cut' },
      { id: 'copy', label: 'Copy' },
      { id: 'paste', label: 'Paste' },
      { type: 'separator' },
      {
        id: 'find',
        label: 'Find',
        beforeGroupContaining: ['cut']  // Moves to top
      },
      {
        id: 'replace',
        label: 'Replace',
        after: ['find']
      }
    ]
  }
];

// Submenu results in:
// Find
// Replace
// [separator]
// Cut
// Copy
// Paste
```

### Debugging Position Issues

```javascript
const template = [
  { id: '1', label: 'First', after: ['2'] },
  { id: '2', label: 'Second', after: ['3'] },
  { id: '3', label: 'Third' }
];

const menu = Menu.buildFromTemplate(template);

// Access items to verify order
menu.items.forEach((item, index) => {
  console.log(`Position ${index}: ${item.label}`);
});
// Output:
// Position 0: Third
// Position 1: Second
// Position 2: First
```

### Key Points

- Items without positioning attributes appear in the order they’re defined
- `before` and `after` accept arrays to specify multiple reference points
- `beforeGroupContaining` and `afterGroupContaining` position relative to groups separated by separators
- All positioning is resolved when `Menu.buildFromTemplate()` is called
- If circular dependencies exist, Electron resolves them based on its internal algorithm (behavior in such cases is [Unverified])

---

