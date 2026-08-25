## `csv` Module


The csv module provides functionality for reading and writing CSV (Comma-Separated Values) files, handling various CSV dialects and formats. It offers both high-level reader/writer interfaces and low-level control over CSV parsing and generation.

### Module Import and Basic Usage

```python
import csv

# Basic reading
with open('data.csv', 'r') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Reading CSV Files

### csv.reader()

Creates a reader object that iterates over rows in a CSV file.

```python
import csv

with open('employees.csv', 'r') as file:
    csv_reader = csv.reader(file)
    
    # Read header
    header = next(csv_reader)
    print(f"Headers: {header}")
    
    # Read data rows
    for row in csv_reader:
        print(f"Row: {row}")
        # Access individual fields
        name = row[0]
        age = row[1]
        department = row[2]
```

### csv.DictReader()

Creates a reader object that maps CSV rows to dictionaries using the first row as field names.

```python
with open('employees.csv', 'r') as file:
    dict_reader = csv.DictReader(file)
    
    # Access field names
    print(f"Field names: {dict_reader.fieldnames}")
    
    # Iterate through rows as dictionaries
    for row in dict_reader:
        print(f"Name: {row['name']}, Age: {row['age']}, Department: {row['department']}")
```

### Custom Field Names with DictReader

```python
with open('data.csv', 'r') as file:
    dict_reader = csv.DictReader(file, fieldnames=['col1', 'col2', 'col3'])
    for row in dict_reader:
        print(row['col1'])
```

### Writing CSV Files

### csv.writer()

Creates a writer object for writing CSV data to a file.

```python
import csv

data = [
    ['Name', 'Age', 'Department'],
    ['John Doe', 30, 'Engineering'],
    ['Jane Smith', 25, 'Marketing'],
    ['Bob Johnson', 35, 'Sales']
]

with open('output.csv', 'w', newline='') as file:
    csv_writer = csv.writer(file)
    
    # Write single row
    csv_writer.writerow(['Name', 'Age', 'Department'])
    
    # Write multiple rows
    csv_writer.writerows([
        ['John Doe', 30, 'Engineering'],
        ['Jane Smith', 25, 'Marketing']
    ])
```

### csv.DictWriter()

Creates a writer object that writes dictionaries to CSV format.

```python
employees = [
    {'name': 'John Doe', 'age': 30, 'department': 'Engineering'},
    {'name': 'Jane Smith', 'age': 25, 'department': 'Marketing'},
    {'name': 'Bob Johnson', 'age': 35, 'department': 'Sales'}
]

with open('employees_output.csv', 'w', newline='') as file:
    fieldnames = ['name', 'age', 'department']
    dict_writer = csv.DictWriter(file, fieldnames=fieldnames)
    
    # Write header
    dict_writer.writeheader()
    
    # Write single row
    dict_writer.writerow({'name': 'Alice Brown', 'age': 28, 'department': 'HR'})
    
    # Write multiple rows
    dict_writer.writerows(employees)
```

### CSV Dialects and Formatting

### Built-in Dialects

```python
# List available dialects
print(csv.list_dialects())  # ['excel', 'excel-tab', 'unix']

# Use specific dialect
with open('data.csv', 'r') as file:
    reader = csv.reader(file, dialect='excel')
    for row in reader:
        print(row)
```

### Custom Dialect Definition

```python
# Register custom dialect
csv.register_dialect('custom', 
                     delimiter='|',
                     quotechar='"',
                     quoting=csv.QUOTE_MINIMAL,
                     lineterminator='\n')

# Use custom dialect
with open('pipe_delimited.csv', 'w', newline='') as file:
    writer = csv.writer(file, dialect='custom')
    writer.writerow(['Name', 'Age', 'City'])
    writer.writerow(['John Doe', 30, 'New York'])
```

### Manual Parameter Setting

```python
with open('data.csv', 'r') as file:
    reader = csv.reader(file, 
                       delimiter=';',
                       quotechar='"',
                       skipinitialspace=True)
    for row in reader:
        print(row)
```

### Reader and Writer Parameters

### Common Parameters

```python
# delimiter: character used to separate fields
reader = csv.reader(file, delimiter=',')

# quotechar: character used to quote fields
reader = csv.reader(file, quotechar='"')

# quoting: controls when quotes are used
reader = csv.reader(file, quoting=csv.QUOTE_MINIMAL)

# skipinitialspace: ignore whitespace after delimiter
reader = csv.reader(file, skipinitialspace=True)

# lineterminator: string used to terminate lines
writer = csv.writer(file, lineterminator='\n')
```

### Quoting Options

```python
# QUOTE_MINIMAL: Quote only when necessary
csv.QUOTE_MINIMAL

# QUOTE_ALL: Quote all fields
csv.QUOTE_ALL

# QUOTE_NONNUMERIC: Quote non-numeric fields
csv.QUOTE_NONNUMERIC

# QUOTE_NONE: Never quote fields
csv.QUOTE_NONE
```

### **Example** of different quoting styles:

```python
data = [['Name', 'Age', 'Comment'],
        ['John', 25, 'Says "Hello"'],
        ['Jane', 30, 'Normal text']]

# QUOTE_MINIMAL
with open('minimal.csv', 'w', newline='') as file:
    writer = csv.writer(file, quoting=csv.QUOTE_MINIMAL)
    writer.writerows(data)

# QUOTE_ALL
with open('all.csv', 'w', newline='') as file:
    writer = csv.writer(file, quoting=csv.QUOTE_ALL)
    writer.writerows(data)
```

### Error Handling and Validation

### Handling Malformed CSV

```python
import csv

def read_csv_safely(filename):
    try:
        with open(filename, 'r') as file:
            reader = csv.reader(file)
            rows = []
            for line_num, row in enumerate(reader, 1):
                try:
                    # Process row
                    rows.append(row)
                except csv.Error as e:
                    print(f"Error on line {line_num}: {e}")
                    continue
            return rows
    except FileNotFoundError:
        print(f"File {filename} not found")
        return []
    except PermissionError:
        print(f"Permission denied to read {filename}")
        return []
```

### Field Validation

```python
def validate_csv_row(row, expected_fields):
    if len(row) != expected_fields:
        raise ValueError(f"Expected {expected_fields} fields, got {len(row)}")
    
    # Additional validation
    if not row[0]:  # Name field
        raise ValueError("Name field cannot be empty")
    
    try:
        age = int(row[1])
        if age < 0 or age > 150:
            raise ValueError("Age must be between 0 and 150")
    except ValueError:
        raise ValueError("Age must be a valid integer")
```

### Advanced Usage

### Reading CSV with Different Encodings

```python
import csv

# UTF-8 encoding
with open('utf8_data.csv', 'r', encoding='utf-8') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)

# Latin-1 encoding
with open('latin1_data.csv', 'r', encoding='latin-1') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Handling Large CSV Files

```python
def process_large_csv(filename, chunk_size=1000):
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        header = next(reader)
        
        chunk = []
        for row in reader:
            chunk.append(row)
            
            if len(chunk) >= chunk_size:
                # Process chunk
                process_chunk(chunk)
                chunk = []
        
        # Process remaining rows
        if chunk:
            process_chunk(chunk)

def process_chunk(chunk):
    # Process the chunk of rows
    for row in chunk:
        # Perform operations on each row
        pass
```

### CSV with Complex Data Types

```python
import csv
import json
from datetime import datetime

def write_complex_csv():
    data = [
        {
            'name': 'John Doe',
            'birth_date': datetime(1990, 5, 15),
            'skills': ['Python', 'Java', 'SQL'],
            'address': {'street': '123 Main St', 'city': 'New York'}
        }
    ]
    
    with open('complex_data.csv', 'w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=['name', 'birth_date', 'skills', 'address'])
        writer.writeheader()
        
        for record in data:
            # Convert complex types to strings
            record['birth_date'] = record['birth_date'].isoformat()
            record['skills'] = json.dumps(record['skills'])
            record['address'] = json.dumps(record['address'])
            writer.writerow(record)

def read_complex_csv():
    with open('complex_data.csv', 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Convert strings back to complex types
            row['birth_date'] = datetime.fromisoformat(row['birth_date'])
            row['skills'] = json.loads(row['skills'])
            row['address'] = json.loads(row['address'])
            print(row)
```

### CSV Data Transformation

### Filtering and Transforming Data

```python
def filter_and_transform_csv(input_file, output_file, min_age=18):
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=['name', 'age', 'department', 'status'])
        writer.writeheader()
        
        for row in reader:
            age = int(row['age'])
            if age >= min_age:
                # Transform data
                row['status'] = 'Adult' if age >= 18 else 'Minor'
                writer.writerow(row)
```

### Merging CSV Files

```python
def merge_csv_files(file_list, output_file):
    with open(output_file, 'w', newline='') as outfile:
        writer = None
        
        for filename in file_list:
            with open(filename, 'r') as infile:
                reader = csv.DictReader(infile)
                
                if writer is None:
                    # Initialize writer with fieldnames from first file
                    writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
                    writer.writeheader()
                
                for row in reader:
                    writer.writerow(row)
```

### CSV Statistics and Analysis

### Basic Statistics

```python
def csv_statistics(filename):
    with open(filename, 'r') as file:
        reader = csv.DictReader(file)
        
        ages = []
        departments = {}
        
        for row in reader:
            age = int(row['age'])
            ages.append(age)
            
            dept = row['department']
            departments[dept] = departments.get(dept, 0) + 1
        
        # Calculate statistics
        avg_age = sum(ages) / len(ages)
        min_age = min(ages)
        max_age = max(ages)
        
        print(f"Average age: {avg_age:.2f}")
        print(f"Age range: {min_age} - {max_age}")
        print(f"Department distribution: {departments}")
```

### Data Aggregation

```python
def aggregate_csv_data(filename):
    from collections import defaultdict
    
    department_data = defaultdict(lambda: {'count': 0, 'total_age': 0})
    
    with open(filename, 'r') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            dept = row['department']
            age = int(row['age'])
            
            department_data[dept]['count'] += 1
            department_data[dept]['total_age'] += age
    
    # Calculate averages
    for dept, data in department_data.items():
        avg_age = data['total_age'] / data['count']
        print(f"{dept}: {data['count']} employees, avg age: {avg_age:.2f}")
```

### Working with Different CSV Formats

### Tab-Separated Values

```python
# Reading TSV files
with open('data.tsv', 'r') as file:
    reader = csv.reader(file, delimiter='\t')
    for row in reader:
        print(row)

# Writing TSV files
with open('output.tsv', 'w', newline='') as file:
    writer = csv.writer(file, delimiter='\t')
    writer.writerow(['Name', 'Age', 'Department'])
    writer.writerow(['John Doe', 30, 'Engineering'])
```

### Semicolon-Separated Values

```python
# Common in European CSV files
with open('european.csv', 'r') as file:
    reader = csv.reader(file, delimiter=';')
    for row in reader:
        print(row)
```

### CSV with Different Line Endings

```python
# Handle different line endings
with open('data.csv', 'r', newline='') as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### Performance Optimization

### Memory-Efficient Processing

```python
def process_csv_memory_efficient(filename):
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        header = next(reader)
        
        # Process one row at a time
        for row in reader:
            # Process row immediately without storing
            process_row(row)
            # Row is garbage collected after processing

def process_row(row):
    # Perform operations on the row
    pass
```

### Bulk Operations

```python
def bulk_write_csv(filename, data_generator):
    with open(filename, 'w', newline='') as file:
        writer = csv.writer(file)
        
        # Write header
        writer.writerow(['Name', 'Age', 'Department'])
        
        # Write data in batches
        batch = []
        batch_size = 1000
        
        for record in data_generator:
            batch.append(record)
            
            if len(batch) >= batch_size:
                writer.writerows(batch)
                batch = []
        
        # Write remaining records
        if batch:
            writer.writerows(batch)
```

### Common Patterns and Best Practices

### Safe File Operations

```python
def safe_csv_operation(input_file, output_file):
    try:
        with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
            reader = csv.DictReader(infile)
            writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
            writer.writeheader()
            
            for row in reader:
                # Process and write row
                writer.writerow(row)
                
    except FileNotFoundError:
        print(f"Input file {input_file} not found")
    except PermissionError:
        print(f"Permission denied")
    except csv.Error as e:
        print(f"CSV error: {e}")
```

### Data Validation Pipeline

```python
def validate_and_clean_csv(input_file, output_file, error_file):
    with open(input_file, 'r') as infile, \
         open(output_file, 'w', newline='') as outfile, \
         open(error_file, 'w', newline='') as errfile:
        
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
        error_writer = csv.DictWriter(errfile, fieldnames=reader.fieldnames + ['error'])
        
        writer.writeheader()
        error_writer.writeheader()
        
        for row in reader:
            try:
                # Validate row
                validate_row(row)
                # Clean row
                cleaned_row = clean_row(row)
                writer.writerow(cleaned_row)
            except ValueError as e:
                row['error'] = str(e)
                error_writer.writerow(row)

def validate_row(row):
    if not row['name']:
        raise ValueError("Name cannot be empty")
    if not row['age'].isdigit():
        raise ValueError("Age must be numeric")

def clean_row(row):
    # Clean and normalize data
    row['name'] = row['name'].strip().title()
    row['age'] = int(row['age'])
    return row
```

**Key points**: The csv module provides robust CSV handling with reader/writer classes, dialect support, and error handling. DictReader and DictWriter offer dictionary-based access to CSV data, while various parameters control formatting and parsing behavior.

**Conclusion**: The csv module is essential for working with CSV files in Python, offering both simple and advanced features for reading, writing, and processing CSV data. Its flexibility in handling different CSV formats and dialects makes it suitable for various data processing tasks.

---

