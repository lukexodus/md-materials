## Structured Arrays and Record Arrays


Structured arrays enable heterogeneous data storage within single NumPy arrays, similar to database records or C structures.

**Structured Array Creation** Data types are defined using dtype specifications that name fields and specify their types. Fields can be accessed individually or collectively, providing flexible data organization. Complex dtype definitions support nested structures and arrays within fields.

**Field Access Patterns** Individual fields are accessed using string indexing, returning views of the underlying data. Multiple fields can be accessed simultaneously, creating arrays with subset dtypes. Field assignment maintains the structured organization while allowing selective updates.

**Record Arrays** Record arrays provide attribute-style access to structured array fields, offering more intuitive syntax for data manipulation. The `numpy.rec` module provides specialized record array creation and manipulation functions.

**Applications** Structured arrays excel in scenarios requiring heterogeneous data with fixed schemas: scientific datasets with multiple measurements, time series with various data types, and interfacing with external data formats.

**Examples**

```python
# Structured array definition
dtype = [('name', 'U10'), ('age', 'i4'), ('salary', 'f8')]
employees = np.array([('Alice', 25, 55000.0), ('Bob', 30, 65000.0)], dtype=dtype)

# Field access
names = employees['name']  # Array of names
ages = employees['age']    # Array of ages

# Record array creation
rec_employees = np.rec.fromarrays([names, ages], names=['name', 'age'])
first_name = rec_employees.name[0]  # Attribute access
```

