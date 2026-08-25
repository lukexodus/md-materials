## Dynamic Table Manipulation (DOM/JS)


### Direct DOM Methods for Table Manipulation

#### Accessing Table Elements

The DOM provides specialized interfaces for tables through `HTMLTableElement`, `HTMLTableSectionElement`, and `HTMLTableRowElement`.

```javascript
const table = document.querySelector('table');
const tbody = table.tBodies[0];
const thead = table.tHead;
const tfoot = table.tFoot;
```

The `rows` collection provides indexed access to all rows:

```javascript
// Access specific row
const firstRow = table.rows[0];
const lastRow = table.rows[table.rows.length - 1];

// Access cells within a row
const firstCell = firstRow.cells[0];
```

#### Inserting Rows

`insertRow()` creates and inserts a new row at the specified position:

```javascript
// Insert at end (-1 or omitted index)
const newRow = tbody.insertRow();

// Insert at specific position
const rowAtIndex = tbody.insertRow(2);

// Insert at beginning
const firstRow = tbody.insertRow(0);
```

The method returns the newly created `HTMLTableRowElement`.

#### Inserting Cells

`insertCell()` works similarly for cells within rows:

```javascript
const row = tbody.insertRow();
const cell1 = row.insertCell(0);
const cell2 = row.insertCell(1);
const cell3 = row.insertCell(); // Appends to end

cell1.textContent = 'Data';
cell2.innerHTML = '<strong>Bold Data</strong>';
```

#### Deleting Rows

`deleteRow()` removes a row at the specified index:

```javascript
// Delete specific row
table.deleteRow(0);

// Delete from tbody
tbody.deleteRow(2);

// Delete last row
table.deleteRow(-1);
```

#### Deleting Cells

`deleteCell()` removes cells from a row:

```javascript
const row = table.rows[0];
row.deleteCell(0); // Delete first cell
row.deleteCell(-1); // Delete last cell
```

### Building Tables Programmatically

#### Creating Complete Tables from Data

```javascript
function createTable(data, headers) {
  const table = document.createElement('table');
  
  // Create thead
  const thead = table.createTHead();
  const headerRow = thead.insertRow();
  headers.forEach(headerText => {
    const th = document.createElement('th');
    th.textContent = headerText;
    headerRow.appendChild(th);
  });
  
  // Create tbody
  const tbody = table.createTBody();
  data.forEach(rowData => {
    const row = tbody.insertRow();
    rowData.forEach(cellData => {
      const cell = row.insertCell();
      cell.textContent = cellData;
    });
  });
  
  return table;
}

const data = [
  ['John', 'Doe', '30'],
  ['Jane', 'Smith', '25']
];
const headers = ['First Name', 'Last Name', 'Age'];
const table = createTable(data, headers);
document.body.appendChild(table);
```

#### Creating Tables with Document Fragments

Document fragments improve performance when building large tables:

```javascript
function buildLargeTable(rowCount) {
  const table = document.createElement('table');
  const tbody = table.createTBody();
  const fragment = document.createDocumentFragment();
  
  for (let i = 0; i < rowCount; i++) {
    const row = document.createElement('tr');
    for (let j = 0; j < 5; j++) {
      const cell = document.createElement('td');
      cell.textContent = `Row ${i}, Cell ${j}`;
      row.appendChild(cell);
    }
    fragment.appendChild(row);
  }
  
  tbody.appendChild(fragment);
  return table;
}
```

### Modifying Table Content

#### Updating Cell Content

```javascript
// Direct text content
table.rows[0].cells[0].textContent = 'New Value';

// HTML content
table.rows[0].cells[1].innerHTML = '<em>Italic Text</em>';

// Setting attributes
const cell = table.rows[0].cells[2];
cell.setAttribute('data-value', '100');
cell.className = 'highlight';
```

#### Replacing Entire Rows

```javascript
function replaceRow(table, rowIndex, newData) {
  const row = table.rows[rowIndex];
  
  // Clear existing cells
  while (row.cells.length > 0) {
    row.deleteCell(0);
  }
  
  // Insert new cells
  newData.forEach(data => {
    const cell = row.insertCell();
    cell.textContent = data;
  });
}
```

#### Cloning Rows

```javascript
const originalRow = table.rows[0];
const clonedRow = originalRow.cloneNode(true); // Deep clone includes cells

// Modify cloned row before insertion
clonedRow.cells[0].textContent = 'Modified';

// Insert cloned row
tbody.appendChild(clonedRow);
```

### Sorting Tables

#### Basic Sorting Implementation

```javascript
function sortTable(table, columnIndex, ascending = true) {
  const tbody = table.tBodies[0];
  const rows = Array.from(tbody.rows);
  
  rows.sort((a, b) => {
    const aValue = a.cells[columnIndex].textContent.trim();
    const bValue = b.cells[columnIndex].textContent.trim();
    
    // Numeric comparison
    if (!isNaN(aValue) && !isNaN(bValue)) {
      return ascending ? aValue - bValue : bValue - aValue;
    }
    
    // String comparison
    return ascending 
      ? aValue.localeCompare(bValue)
      : bValue.localeCompare(aValue);
  });
  
  // Reorder rows in DOM
  rows.forEach(row => tbody.appendChild(row));
}
```

#### Sortable Table Headers

```javascript
function makeSortable(table) {
  const headers = table.querySelectorAll('th');
  
  headers.forEach((header, index) => {
    header.style.cursor = 'pointer';
    header.addEventListener('click', () => {
      const currentOrder = header.dataset.order || 'asc';
      const newOrder = currentOrder === 'asc' ? 'desc' : 'asc';
      
      // Remove order indicators from all headers
      headers.forEach(h => delete h.dataset.order);
      
      // Set new order
      header.dataset.order = newOrder;
      
      sortTable(table, index, newOrder === 'asc');
    });
  });
}
```

#### Multi-Column Sorting

```javascript
function sortTableMultiColumn(table, sortCriteria) {
  // sortCriteria: [{column: 0, ascending: true}, {column: 1, ascending: false}]
  const tbody = table.tBodies[0];
  const rows = Array.from(tbody.rows);
  
  rows.sort((a, b) => {
    for (let criterion of sortCriteria) {
      const aValue = a.cells[criterion.column].textContent.trim();
      const bValue = b.cells[criterion.column].textContent.trim();
      
      let comparison;
      if (!isNaN(aValue) && !isNaN(bValue)) {
        comparison = aValue - bValue;
      } else {
        comparison = aValue.localeCompare(bValue);
      }
      
      if (comparison !== 0) {
        return criterion.ascending ? comparison : -comparison;
      }
    }
    return 0;
  });
  
  rows.forEach(row => tbody.appendChild(row));
}
```

### Filtering Tables

#### Basic Row Filtering

```javascript
function filterTable(table, columnIndex, filterValue) {
  const rows = table.tBodies[0].rows;
  
  Array.from(rows).forEach(row => {
    const cellValue = row.cells[columnIndex].textContent.toLowerCase();
    const searchValue = filterValue.toLowerCase();
    
    if (cellValue.includes(searchValue)) {
      row.style.display = '';
    } else {
      row.style.display = 'none';
    }
  });
}
```

#### Multi-Column Search

```javascript
function searchTable(table, searchTerm) {
  const searchLower = searchTerm.toLowerCase();
  const rows = table.tBodies[0].rows;
  
  Array.from(rows).forEach(row => {
    const rowText = Array.from(row.cells)
      .map(cell => cell.textContent.toLowerCase())
      .join(' ');
    
    row.style.display = rowText.includes(searchLower) ? '' : 'none';
  });
}
```

#### Advanced Filtering with Multiple Criteria

```javascript
function advancedFilter(table, filters) {
  // filters: {columnIndex: {operator: 'equals|contains|greater|less', value: '...'}}
  const rows = table.tBodies[0].rows;
  
  Array.from(rows).forEach(row => {
    let shouldShow = true;
    
    for (let [columnIndex, filter] of Object.entries(filters)) {
      const cellValue = row.cells[columnIndex].textContent.trim();
      
      switch (filter.operator) {
        case 'equals':
          shouldShow = shouldShow && (cellValue === filter.value);
          break;
        case 'contains':
          shouldShow = shouldShow && cellValue.includes(filter.value);
          break;
        case 'greater':
          shouldShow = shouldShow && (parseFloat(cellValue) > parseFloat(filter.value));
          break;
        case 'less':
          shouldShow = shouldShow && (parseFloat(cellValue) < parseFloat(filter.value));
          break;
      }
      
      if (!shouldShow) break;
    }
    
    row.style.display = shouldShow ? '' : 'none';
  });
}
```

### Pagination

#### Client-Side Pagination

```javascript
class TablePaginator {
  constructor(table, rowsPerPage = 10) {
    this.table = table;
    this.tbody = table.tBodies[0];
    this.rowsPerPage = rowsPerPage;
    this.allRows = Array.from(this.tbody.rows);
    this.currentPage = 1;
    this.totalPages = Math.ceil(this.allRows.length / rowsPerPage);
  }
  
  showPage(pageNumber) {
    this.currentPage = Math.max(1, Math.min(pageNumber, this.totalPages));
    const start = (this.currentPage - 1) * this.rowsPerPage;
    const end = start + this.rowsPerPage;
    
    this.allRows.forEach((row, index) => {
      row.style.display = (index >= start && index < end) ? '' : 'none';
    });
  }
  
  nextPage() {
    this.showPage(this.currentPage + 1);
  }
  
  prevPage() {
    this.showPage(this.currentPage - 1);
  }
  
  goToPage(page) {
    this.showPage(page);
  }
}

// Usage
const paginator = new TablePaginator(table, 10);
paginator.showPage(1);
```

#### Dynamic Pagination Controls

```javascript
function createPaginationControls(paginator, container) {
  container.innerHTML = '';
  
  const prevBtn = document.createElement('button');
  prevBtn.textContent = 'Previous';
  prevBtn.disabled = paginator.currentPage === 1;
  prevBtn.onclick = () => {
    paginator.prevPage();
    updateControls();
  };
  
  const pageInfo = document.createElement('span');
  pageInfo.textContent = ` Page ${paginator.currentPage} of ${paginator.totalPages} `;
  
  const nextBtn = document.createElement('button');
  nextBtn.textContent = 'Next';
  nextBtn.disabled = paginator.currentPage === paginator.totalPages;
  nextBtn.onclick = () => {
    paginator.nextPage();
    updateControls();
  };
  
  function updateControls() {
    prevBtn.disabled = paginator.currentPage === 1;
    nextBtn.disabled = paginator.currentPage === paginator.totalPages;
    pageInfo.textContent = ` Page ${paginator.currentPage} of ${paginator.totalPages} `;
  }
  
  container.appendChild(prevBtn);
  container.appendChild(pageInfo);
  container.appendChild(nextBtn);
}
```

### Editable Tables

#### Making Cells Editable

```javascript
function makeCellEditable(cell) {
  cell.addEventListener('dblclick', function() {
    const originalValue = this.textContent;
    const input = document.createElement('input');
    input.value = originalValue;
    input.type = 'text';
    
    input.addEventListener('blur', function() {
      cell.textContent = this.value;
    });
    
    input.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        this.blur();
      } else if (e.key === 'Escape') {
        cell.textContent = originalValue;
      }
    });
    
    this.textContent = '';
    this.appendChild(input);
    input.focus();
  });
}

// Make all cells in tbody editable
Array.from(table.tBodies[0].rows).forEach(row => {
  Array.from(row.cells).forEach(cell => makeCellEditable(cell));
});
```

#### Inline Row Editing

```javascript
function enableRowEditing(table) {
  const tbody = table.tBodies[0];
  
  Array.from(tbody.rows).forEach(row => {
    const editBtn = document.createElement('button');
    editBtn.textContent = 'Edit';
    
    const saveBtn = document.createElement('button');
    saveBtn.textContent = 'Save';
    saveBtn.style.display = 'none';
    
    const cancelBtn = document.createElement('button');
    cancelBtn.textContent = 'Cancel';
    cancelBtn.style.display = 'none';
    
    const actionCell = row.insertCell();
    actionCell.appendChild(editBtn);
    actionCell.appendChild(saveBtn);
    actionCell.appendChild(cancelBtn);
    
    let originalValues = [];
    
    editBtn.onclick = () => {
      originalValues = [];
      Array.from(row.cells).slice(0, -1).forEach(cell => {
        originalValues.push(cell.textContent);
        const input = document.createElement('input');
        input.value = cell.textContent;
        cell.textContent = '';
        cell.appendChild(input);
      });
      
      editBtn.style.display = 'none';
      saveBtn.style.display = '';
      cancelBtn.style.display = '';
    };
    
    saveBtn.onclick = () => {
      Array.from(row.cells).slice(0, -1).forEach(cell => {
        const input = cell.querySelector('input');
        if (input) {
          cell.textContent = input.value;
        }
      });
      
      resetButtons();
    };
    
    cancelBtn.onclick = () => {
      Array.from(row.cells).slice(0, -1).forEach((cell, index) => {
        cell.textContent = originalValues[index];
      });
      
      resetButtons();
    };
    
    function resetButtons() {
      editBtn.style.display = '';
      saveBtn.style.display = 'none';
      cancelBtn.style.display = 'none';
    }
  });
}
```

### Row Selection

#### Single Row Selection

```javascript
function enableRowSelection(table) {
  const tbody = table.tBodies[0];
  let selectedRow = null;
  
  Array.from(tbody.rows).forEach(row => {
    row.style.cursor = 'pointer';
    
    row.addEventListener('click', function() {
      if (selectedRow) {
        selectedRow.classList.remove('selected');
      }
      
      this.classList.add('selected');
      selectedRow = this;
    });
  });
}
```

#### Multiple Row Selection with Checkboxes

```javascript
function addRowCheckboxes(table) {
  const thead = table.tHead;
  const tbody = table.tBodies[0];
  
  // Add header checkbox
  const headerRow = thead.rows[0];
  const checkboxHeaderCell = document.createElement('th');
  const headerCheckbox = document.createElement('input');
  headerCheckbox.type = 'checkbox';
  checkboxHeaderCell.appendChild(headerCheckbox);
  headerRow.insertBefore(checkboxHeaderCell, headerRow.firstChild);
  
  // Add row checkboxes
  Array.from(tbody.rows).forEach(row => {
    const checkboxCell = row.insertCell(0);
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkboxCell.appendChild(checkbox);
    
    checkbox.addEventListener('change', updateHeaderCheckbox);
  });
  
  // Header checkbox selects/deselects all
  headerCheckbox.addEventListener('change', function() {
    const checkboxes = tbody.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(cb => cb.checked = this.checked);
  });
  
  function updateHeaderCheckbox() {
    const checkboxes = Array.from(tbody.querySelectorAll('input[type="checkbox"]'));
    const allChecked = checkboxes.every(cb => cb.checked);
    const someChecked = checkboxes.some(cb => cb.checked);
    
    headerCheckbox.checked = allChecked;
    headerCheckbox.indeterminate = someChecked && !allChecked;
  }
}

// Get selected rows
function getSelectedRows(table) {
  const tbody = table.tBodies[0];
  return Array.from(tbody.rows).filter(row => {
    const checkbox = row.querySelector('input[type="checkbox"]');
    return checkbox && checkbox.checked;
  });
}
```

### Drag and Drop Row Reordering

#### Basic Drag and Drop Implementation

```javascript
function enableRowDragDrop(table) {
  const tbody = table.tBodies[0];
  
  Array.from(tbody.rows).forEach(row => {
    row.draggable = true;
    
    row.addEventListener('dragstart', function(e) {
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/html', this.innerHTML);
      this.classList.add('dragging');
    });
    
    row.addEventListener('dragend', function() {
      this.classList.remove('dragging');
    });
    
    row.addEventListener('dragover', function(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      
      const draggingRow = tbody.querySelector('.dragging');
      if (draggingRow && draggingRow !== this) {
        const rect = this.getBoundingClientRect();
        const midpoint = rect.top + rect.height / 2;
        
        if (e.clientY < midpoint) {
          tbody.insertBefore(draggingRow, this);
        } else {
          tbody.insertBefore(draggingRow, this.nextSibling);
        }
      }
    });
  });
}
```

#### Drag Handle Implementation

```javascript
function addDragHandles(table) {
  const tbody = table.tBodies[0];
  
  Array.from(tbody.rows).forEach(row => {
    const handleCell = row.insertCell(0);
    handleCell.innerHTML = '☰';
    handleCell.className = 'drag-handle';
    handleCell.style.cursor = 'grab';
    
    handleCell.addEventListener('mousedown', function() {
      row.draggable = true;
    });
    
    handleCell.addEventListener('mouseup', function() {
      row.draggable = false;
    });
    
    row.addEventListener('dragstart', function(e) {
      if (!row.draggable) {
        e.preventDefault();
        return;
      }
      this.classList.add('dragging');
    });
    
    row.addEventListener('dragend', function() {
      this.classList.remove('dragging');
      row.draggable = false;
    });
    
    row.addEventListener('dragover', function(e) {
      e.preventDefault();
      const draggingRow = tbody.querySelector('.dragging');
      
      if (draggingRow && draggingRow !== this) {
        const rect = this.getBoundingClientRect();
        const midpoint = rect.top + rect.height / 2;
        
        if (e.clientY < midpoint) {
          tbody.insertBefore(draggingRow, this);
        } else {
          tbody.insertBefore(draggingRow, this.nextSibling);
        }
      }
    });
  });
}
```

### Column Operations

#### Adding Columns Dynamically

```javascript
function addColumn(table, headerText, defaultValue = '') {
  // Add header
  const thead = table.tHead;
  if (thead) {
    const headerRow = thead.rows[0];
    const th = document.createElement('th');
    th.textContent = headerText;
    headerRow.appendChild(th);
  }
  
  // Add cells to all rows
  const tbody = table.tBodies[0];
  Array.from(tbody.rows).forEach(row => {
    const cell = row.insertCell();
    cell.textContent = defaultValue;
  });
}
```

#### Removing Columns

```javascript
function removeColumn(table, columnIndex) {
  // Remove header
  const thead = table.tHead;
  if (thead) {
    const headerRow = thead.rows[0];
    headerRow.deleteCell(columnIndex);
  }
  
  // Remove cells from all rows
  const tbody = table.tBodies[0];
  Array.from(tbody.rows).forEach(row => {
    if (row.cells[columnIndex]) {
      row.deleteCell(columnIndex);
    }
  });
}
```

#### Hiding/Showing Columns

```javascript
function toggleColumn(table, columnIndex, visible) {
  const display = visible ? '' : 'none';
  
  // Hide/show header
  const thead = table.tHead;
  if (thead) {
    const headerRow = thead.rows[0];
    if (headerRow.cells[columnIndex]) {
      headerRow.cells[columnIndex].style.display = display;
    }
  }
  
  // Hide/show cells in all rows
  Array.from(table.tBodies).forEach(tbody => {
    Array.from(tbody.rows).forEach(row => {
      if (row.cells[columnIndex]) {
        row.cells[columnIndex].style.display = display;
      }
    });
  });
}

function createColumnToggleControls(table, container) {
  const thead = table.tHead;
  if (!thead) return;
  
  const headers = Array.from(thead.rows[0].cells);
  
  headers.forEach((header, index) => {
    const label = document.createElement('label');
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = true;
    
    checkbox.addEventListener('change', function() {
      toggleColumn(table, index, this.checked);
    });
    
    label.appendChild(checkbox);
    label.appendChild(document.createTextNode(' ' + header.textContent));
    container.appendChild(label);
    container.appendChild(document.createElement('br'));
  });
}
```

### Performance Optimization

#### Virtual Scrolling for Large Tables

```javascript
class VirtualTable {
  constructor(container, data, columns, rowHeight = 40) {
    this.container = container;
    this.data = data;
    this.columns = columns;
    this.rowHeight = rowHeight;
    this.visibleRows = Math.ceil(container.clientHeight / rowHeight) + 1;
    this.startIndex = 0;
    
    this.setupContainer();
    this.render();
    
    this.container.addEventListener('scroll', () => this.handleScroll());
  }
  
  setupContainer() {
    this.container.style.overflow = 'auto';
    this.container.style.position = 'relative';
    
    this.table = document.createElement('table');
    this.thead = this.table.createTHead();
    this.tbody = this.table.createTBody();
    
    // Create header
    const headerRow = this.thead.insertRow();
    this.columns.forEach(col => {
      const th = document.createElement('th');
      th.textContent = col;
      headerRow.appendChild(th);
    });
    
    // Create spacer for scrolling
    this.spacer = document.createElement('div');
    this.spacer.style.height = `${this.data.length * this.rowHeight}px`;
    
    this.container.appendChild(this.spacer);
    this.container.appendChild(this.table);
  }
  
  render() {
    this.tbody.innerHTML = '';
    const endIndex = Math.min(this.startIndex + this.visibleRows, this.data.length);
    
    for (let i = this.startIndex; i < endIndex; i++) {
      const row = this.tbody.insertRow();
      this.data[i].forEach(cellData => {
        const cell = row.insertCell();
        cell.textContent = cellData;
      });
    }
    
    this.table.style.transform = `translateY(${this.startIndex * this.rowHeight}px)`;
  }
  
  handleScroll() {
    const scrollTop = this.container.scrollTop;
    const newStartIndex = Math.floor(scrollTop / this.rowHeight);
    
    if (newStartIndex !== this.startIndex) {
      this.startIndex = newStartIndex;
      this.render();
    }
  }
}
```

#### Batch DOM Updates

```javascript
function batchUpdateRows(table, updates) {
  // updates: [{rowIndex: 0, columnIndex: 1, value: 'New Value'}, ...]
  
  // Detach table from DOM during updates
  const parent = table.parentNode;
  const nextSibling = table.nextSibling;
  parent.removeChild(table);
  
  // Apply all updates
  updates.forEach(update => {
    const row = table.rows[update.rowIndex];
    if (row && row.cells[update.columnIndex]) {
      row.cells[update.columnIndex].textContent = update.value;
    }
  });
  
  // Reattach table
  parent.insertBefore(table, nextSibling);
}
```

#### Debounced Search/Filter

```javascript
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

const debouncedSearch = debounce((table, searchTerm) => {
  searchTable(table, searchTerm);
}, 300);

// Usage
searchInput.addEventListener('input', (e) => {
  debouncedSearch(table, e.target.value);
});
```

### Export Functionality

#### Export to CSV

```javascript
function exportTableToCSV(table, filename = 'table.csv') {
  const rows = [];
  
  // Get headers
  if (table.tHead) {
    const headerRow = Array.from(table.tHead.rows[0].cells)
      .map(cell => cell.textContent);
    rows.push(headerRow);
  }
  
  // Get data rows
  Array.from(table.tBodies[0].rows).forEach(row => {
    const rowData = Array.from(row.cells)
      .map(cell => {
        let text = cell.textContent;
        // Escape quotes and wrap in quotes if contains comma
        if (text.includes(',') || text.includes('"') || text.includes('\n')) {
          text = '"' + text.replace(/"/g, '""') + '"';
        }
        return text;
      });
    rows.push(rowData);
  });
  
  const csvContent = rows.map(row => row.join(',')).join('\n');
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  
  link.setAttribute('href', url);
  link.setAttribute('download', filename);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
```

#### Export to JSON

```javascript
function exportTableToJSON(table) {
  const headers = Array.from(table.tHead.rows[0].cells)
    .map(cell => cell.textContent);
  
  const data = Array.from(table.tBodies[0].rows).map(row => {
    const rowData = {};
    Array.from(row.cells).forEach((cell, index) => {
      rowData[headers[index]] = cell.textContent;
    });
    return rowData;
  });
  
  return JSON.stringify(data, null, 2);
}
```

### State Management

#### Saving Table State

```javascript
class TableStateManager {
  constructor(table, storageKey) {
    this.table = table;
    this.storageKey = storageKey;
  }
  
  saveState() {
    const state = {
      data: this.getTableData(),
      sortColumn: this.table.dataset.sortColumn,
      sortDirection: this.table.dataset.sortDirection,
      hiddenColumns: this.getHiddenColumns(),
      pageSize: this.table.dataset.pageSize
    };
    
    localStorage.setItem(this.storageKey, JSON.stringify(state));
  }
  
  loadState() {
    const stateJson = localStorage.getItem(this.storageKey);
    if (!stateJson) return null;
    
    return JSON.parse(stateJson);
  }
  
  getTableData() {
    const data = [];
    const tbody = this.table.tBodies[0];
    
    Array.from(tbody.rows).forEach(row => {
      const rowData = Array.from(row.cells).map(cell => cell.textContent);
      data.push(rowData);
    });
    
    return data;
  }
  
  getHiddenColumns() {
    const hidden = [];
    const headerRow = this.table.tHead.rows[0];
    
    Array.from(headerRow.cells).forEach((cell, index) => {
      if (cell.style.display === 'none') {
        hidden.push(index);
      }
    });
    
    return hidden;
  }
  
  restoreState(state) {
    if (!state) return;
    
    // Restore hidden columns
    if (state.hiddenColumns) {
      state.hiddenColumns.forEach(index => {
        toggleColumn(this.table, index, false);
      });
    }
    
    // Restore sort
    if (state.sortColumn !== undefined) {
      sortTable(this.table, state.sortColumn, state.sortDirection === 'asc');
    }
  }
}
```

### Event Delegation for Dynamic Tables

```javascript
function setupTableEventDelegation(table) {
  table.addEventListener('click', function(e) {
    const target = e.target;
    const cell = target.closest('td');
    const row = target.closest('tr');
    
    // Handle cell clicks
    if (cell) {
      console.log('Cell clicked:', cell.cellIndex, cell.textContent);
    }
    
	// Handle button clicks
	if (target.matches('button.delete-btn')) {
	    e.stopPropagation();
	    const rowIndex = row.rowIndex;
	    table.deleteRow(rowIndex);
	}
	
	if (target.matches('button.edit-btn')) {
	    e.stopPropagation();
	    // Edit logic
	}
	});
	
	// Handle input changes
	table.addEventListener('change', function (e) {
	    if (e.target.matches('input[type="checkbox"]')) {
	        const row = e.target.closest('tr');
	        row.classList.toggle('selected', e.target.checked);
	    }
	});
}
````

### Responsive Tables

#### Horizontal Scrolling Wrapper

```javascript
function makeTableResponsive(table) {
  const wrapper = document.createElement('div');
  wrapper.className = 'table-responsive';
  wrapper.style.overflowX = 'auto';
  wrapper.style.webkitOverflowScrolling = 'touch';
  
  table.parentNode.insertBefore(wrapper, table);
  wrapper.appendChild(table);
}
````

#### Collapsible Columns for Mobile

```javascript
function makeTableCollapsible(table, priorityColumns) {
  // priorityColumns: array of column indices that should always be visible
  const mediaQuery = window.matchMedia('(max-width: 768px)');
  
  function handleResize(e) {
    const headerRow = table.tHead.rows[0];
    
    Array.from(headerRow.cells).forEach((cell, index) => {
      const isVisible = e.matches ? priorityColumns.includes(index) : true;
      toggleColumn(table, index, isVisible);
    });
  }
  
  mediaQuery.addListener(handleResize);
  handleResize(mediaQuery);
}
```

---

