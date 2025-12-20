## Comprehensive Pandas Mastery Syllabus

Here's a structured syllabus to help you learn and master pandas, the powerful data manipulation library for Python. This curriculum progresses from fundamentals to advanced techniques.

### Module 1: Pandas Fundamentals (2 weeks)

- **Introduction to pandas**
    - Installation and setup
    - pandas' role in the Python data ecosystem
    - Series and DataFrame objects
- **Basic Data Structures**
    - Creating Series and DataFrames
    - Data types and dtypes
    - Basic attributes and methods
- **Data Import/Export**
    - Reading/writing CSV, Excel, JSON
    - Database connections
    - Web data scraping with pandas
- **Initial Data Exploration**
    - head(), tail(), info(), describe()
    - Shape and dimensions
    - Data sampling

### Module 2: Data Selection and Manipulation (3 weeks)

- **Indexing and Selection**
    - loc and iloc
    - Boolean indexing
    - Query method
- **Data Cleaning**
    - Handling missing values
    - Duplicate removal
    - Data type conversion
- **Basic Transformations**
    - apply(), map(), applymap()
    - Adding/removing columns and rows
    - String manipulation methods
- **Reshaping Data**
    - melt and pivot
    - stack and unstack
    - Transposing data

	### Module 3: Data Analysis Techniques (3 weeks)

- **Aggregation Methods**
    - groupby() operations
    - agg() and transform()
    - Custom aggregation functions
- **Window Functions**
    - Rolling and expanding operations
    - Shifting and lagging data
    - Cumulative calculations
- **Time Series Analysis**
    - DatetimeIndex and PeriodIndex
    - Resampling and frequency conversion
    - Time zone handling
    - Rolling date windows
- **Categorical Data**
    - Categorical dtype
    - Category ordering and manipulation
    - Categorical codes and statistics

### Module 4: Advanced Topics (4 weeks)

- **Performance Optimization**
    - Memory usage analysis and reduction
    - Chunking large datasets
    - Optimizing pandas operations
- **MultiIndex and Advanced Indexing**
    - Creating and manipulating hierarchical indices
    - Cross-section and advanced selection
    - Index alignment and operations
- **Advanced Merging and Joining**
    - Complex merge operations
    - Concatenation techniques
    - Database-style joins with multiple conditions
- **Computational Methods**
    - Vectorized operations
    - Custom numpy functions with pandas
    - Optimizing with numba/cython
- **Text and Pattern Processing**
    - Advanced string operations
    - Regular expressions in pandas
    - Text extraction and cleaning

### Module 5: Visualization and Reporting (2 weeks)

- **Integrated Visualization**
    - Pandas built-in plotting
    - Integration with matplotlib
    - Statistical visualization
- **Advanced Visualization**
    - Interactive plots with plotly
    - Dashboards with pandas
    - Geographic visualization
- **Reporting and Exports**
    - Creating Excel reports
    - HTML and styled outputs
    - Integration with reporting systems

### Module 6: Real-world Applications (4 weeks)

- **Data Science Applications**
    - Feature engineering with pandas
    - Preprocessing for machine learning
    - Time series forecasting workflows
- **Finance and Economics**
    - Financial data analysis
    - Return calculations
    - Risk metrics
- **Business Intelligence**
    - KPI calculation and tracking
    - Customer segmentation
    - Sales analysis
- **Final Capstone Project**
    - Comprehensive data analysis project
    - Dataset cleaning, transformation, and analysis
    - Visualization and findings presentation

### Learning Resources:

- Official pandas documentation
- "Python for Data Analysis" by Wes McKinney
- "Pandas Cookbook" by Theodore Petrou
- pandas GitHub repository examples
- Kaggle competitions and datasets for practice
- DataCamp/Coursera pandas-focused courses

### Practice Recommendations:

- Start with small datasets while learning fundamentals
- Progress to larger real-world datasets as skills improve
- Regularly participate in data cleaning challenges
- Build a portfolio of pandas projects showcasing different skills
- Contribute to open-source projects using pandas

---

# Pandas Fundamentals

## Introduction to pandas

### Installation and setup

**Key points:**

- pandas is a powerful Python library for data manipulation and analysis
- Requirements: Python 3.8+ and NumPy
- Installation methods: pip, conda, or through Anaconda Distribution

pandas can be installed using several methods:

```python
# Using pip
pip install pandas

# Using conda
conda install pandas
```

For development environments, you may want to install additional dependencies:

```python
# Full installation with recommended packages
pip install pandas[all]
```

Verify your installation by importing pandas in Python:

```python
import pandas as pd
print(pd.__version__)  # Check installed version
```

### pandas' role in the Python data ecosystem

**Key points:**

- pandas bridges the gap between data storage and analysis
- Built on NumPy but adds domain-specific functionality
- Integrates with other Python libraries in the data science stack

pandas occupies a central position in the Python data ecosystem:

- **Data acquisition**: pandas provides tools to import data from various sources (CSV, Excel, SQL databases, JSON, etc.)
- **Data wrangling**: offers powerful functions for cleaning, transforming, and reshaping data
- **Data analysis**: includes statistical functions and aggregation capabilities
- **Visualization**: integrates with matplotlib and other visualization libraries
- **Machine learning integration**: prepares data for scikit-learn and other ML libraries

The pandas library works seamlessly with other key Python data science tools:

- **NumPy**: pandas is built on NumPy's ndarray, leveraging its performance for numerical operations
- **Matplotlib/Seaborn**: for visualization of pandas data structures
- **scikit-learn**: for machine learning using pandas-processed data
- **SciPy**: for scientific computing capabilities
- **SQLAlchemy**: for database connectivity
- **Dask**: for scaling pandas operations to larger-than-memory datasets

### Series and DataFrame objects

**Key points:**

- Series: one-dimensional labeled array capable of holding any data type
- DataFrame: two-dimensional labeled data structure with columns of potentially different types
- Both provide powerful indexing, selection, and data manipulation capabilities

#### Series

A Series is a one-dimensional labeled array capable of holding any data type:

```python
import pandas as pd
import numpy as np

# Create a Series from a list
s = pd.Series([1, 3, 5, np.nan, 6, 8])
print(s)
```

**Output:**

```
0    1.0
1    3.0
2    5.0
3    NaN
4    6.0
5    8.0
dtype: float64
```

Series objects have:

- Values accessible via the `.values` attribute
- Index accessible via the `.index` attribute
- Named axis (optional) via the `.name` attribute
- Support for vectorized operations
- Built-in handling of missing values

Creating Series with custom indices:

```python
# Create a Series with custom index
s = pd.Series([1, 2, 3, 4], index=['a', 'b', 'c', 'd'])
print(s)
```

**Output:**

```
a    1
b    2
c    3
d    4
dtype: int64
```

Series can also be created from dictionaries:

```python
# Create a Series from a dictionary
d = {'a': 1, 'b': 2, 'c': 3}
s = pd.Series(d)
print(s)
```

#### DataFrame

A DataFrame is a 2-dimensional labeled data structure with columns of potentially different types:

```python
# Create a DataFrame from a dictionary of Series
d = {
    'Name': pd.Series(['Alice', 'Bob', 'Charlie']),
    'Age': pd.Series([25, 30, 35]),
    'Score': pd.Series([90.5, 85.0, 92.3])
}
df = pd.DataFrame(d)
print(df)
```

**Output:**

```
      Name  Age  Score
0    Alice   25   90.5
1      Bob   30   85.0
2  Charlie   35   92.3
```

DataFrames can also be created from:

- Lists of dictionaries
- NumPy arrays
- Other DataFrames

```python
# Create a DataFrame from a list of dictionaries
data = [
    {'Name': 'Alice', 'Age': 25, 'City': 'New York'},
    {'Name': 'Bob', 'Age': 30, 'City': 'Chicago'},
    {'Name': 'Charlie', 'Age': 35, 'City': 'Los Angeles'}
]
df = pd.DataFrame(data)
print(df)
```

**Output:**

```
      Name  Age         City
0    Alice   25     New York
1      Bob   30      Chicago
2  Charlie   35  Los Angeles
```

DataFrames have:

- Column labels accessible via `.columns`
- Row labels (index) accessible via `.index`
- Each column is a Series
- Multiple columns can have different data types
- Support for hierarchical indexing
- Rich set of methods for data manipulation

Accessing basic DataFrame information:

```python
# Basic DataFrame information
print(df.shape)  # Dimensions (rows, columns)
print(df.dtypes)  # Data types of each column
print(df.info())  # Summary information
print(df.describe())  # Statistical summary
```

**Conclusion:** pandas provides flexible data structures that form the foundation for data analysis in Python. Series and DataFrames allow for intuitive data manipulation with labeled axes, making it easier to work with structured data. Learning these core concepts is essential for mastering pandas and unlocking its full potential for data science projects.

---

## Basic Data Structures

### Creating Series and DataFrames

**Key points:**

- Series is a one-dimensional labeled array
- DataFrame is a two-dimensional labeled data structure
- Both can be created from various data sources
- Flexible indexing options are available for both structures

#### Creating Series

Series objects can be created from various data structures:

```python
import pandas as pd
import numpy as np

# From a list
s1 = pd.Series([10, 20, 30, 40])

# From a NumPy array
s2 = pd.Series(np.array([10, 20, 30, 40]))

# From a dictionary
s3 = pd.Series({'a': 10, 'b': 20, 'c': 30, 'd': 40})

# With custom index
s4 = pd.Series([10, 20, 30, 40], index=['a', 'b', 'c', 'd'])

# With a scalar value
s5 = pd.Series(5, index=['a', 'b', 'c'])  # All values will be 5

# With date range as index
s6 = pd.Series([10, 20, 30], index=pd.date_range('20230101', periods=3))
```

**Output:**

```
# s1
0    10
1    20
2    30
3    40
dtype: int64

# s4
a    10
b    20
c    30
d    40
dtype: int64

# s5
a    5
b    5
c    5
dtype: int64

# s6
2023-01-01    10
2023-01-02    20
2023-01-03    30
Freq: D, dtype: int64
```

#### Creating DataFrames

DataFrames can be created from various sources:

```python
# From a dictionary of Series
data = {
    'Name': pd.Series(['Alice', 'Bob', 'Charlie', 'David']),
    'Age': pd.Series([25, 30, 35, 40]),
    'City': pd.Series(['New York', 'Boston', 'Chicago', 'Denver'])
}
df1 = pd.DataFrame(data)

# From a dictionary of lists
data = {
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Age': [25, 30, 35, 40],
    'City': ['New York', 'Boston', 'Chicago', 'Denver']
}
df2 = pd.DataFrame(data)

# From a list of dictionaries
data = [
    {'Name': 'Alice', 'Age': 25, 'City': 'New York'},
    {'Name': 'Bob', 'Age': 30, 'City': 'Boston'},
    {'Name': 'Charlie', 'Age': 35, 'City': 'Chicago'},
    {'Name': 'David', 'Age': 40, 'City': 'Denver'}
]
df3 = pd.DataFrame(data)

# From a 2D NumPy array
arr = np.array([['Alice', 25, 'New York'],
                ['Bob', 30, 'Boston'],
                ['Charlie', 35, 'Chicago'],
                ['David', 40, 'Denver']])
df4 = pd.DataFrame(arr, columns=['Name', 'Age', 'City'])

# From another DataFrame
df5 = pd.DataFrame(df1, columns=['Name', 'Age'])

# With custom index
df6 = pd.DataFrame(data, index=['a', 'b', 'c', 'd'])

# From a CSV file
# df7 = pd.read_csv('data.csv')

# Creating an empty DataFrame
df8 = pd.DataFrame()
```

**Output:**

```
# df2
      Name  Age      City
0    Alice   25  New York
1      Bob   30    Boston
2  Charlie   35   Chicago
3    David   40    Denver

# df6
      Name  Age      City
a    Alice   25  New York
b      Bob   30    Boston
c  Charlie   35   Chicago
d    David   40    Denver
```

### Data types and dtypes

**Key points:**

- pandas supports various data types from NumPy plus pandas-specific types
- dtypes can be specified during creation or converted later
- Understanding dtypes is crucial for memory efficiency and operations

#### Common pandas dtypes

```python
# Common pandas dtypes
df = pd.DataFrame({
    'Integer': [1, 2, 3, 4],
    'Float': [1.1, 2.2, 3.3, 4.4],
    'String': ['a', 'b', 'c', 'd'],
    'Boolean': [True, False, True, False],
    'Datetime': pd.date_range('20230101', periods=4),
    'Categorical': pd.Categorical(['Low', 'Medium', 'High', 'Low'])
})

print(df.dtypes)
```

**Output:**

```
Integer                int64
Float                float64
String                object
Boolean                 bool
Datetime      datetime64[ns]
Categorical        category
dtype: object
```

#### Special pandas dtypes

```python
# Int64 with NA support
s1 = pd.Series([1, 2, None, 4], dtype='Int64')

# String type
s2 = pd.Series(['a', 'b', None, 'd'], dtype='string')

# Boolean with NA support
s3 = pd.Series([True, False, None, True], dtype='boolean')

# Create categorical data
s4 = pd.Series(['Low', 'Medium', 'High', 'Low'])
s4_cat = s4.astype('category')

# Ordered categorical
s5 = pd.Series(['Low', 'Medium', 'High', 'Low'])
s5_cat = pd.Categorical(s5, categories=['Low', 'Medium', 'High'], ordered=True)

# Date ranges
s6 = pd.Series(pd.date_range('20230101', periods=4))

# Time deltas
s7 = pd.Series([pd.Timedelta(days=i) for i in range(4)])
```

#### Converting dtypes

```python
# Converting dtypes
df = pd.DataFrame({
    'A': [1, 2, 3, 4],
    'B': [1.1, 2.2, 3.3, 4.4],
    'C': ['1', '2', '3', '4']
})

# Convert single column
df['A'] = df['A'].astype('float64')
df['C'] = df['C'].astype('int64')

# Convert multiple columns at once
df = df.astype({'A': 'int32', 'B': 'float32'})

# Convert to most memory-efficient types
df = df.convert_dtypes()

# Add a categorical column
df['D'] = pd.Series(['Low', 'Medium', 'High', 'Low']).astype('category')
```

**Output:**

```
# Original dtypes
A     int64
B   float64
C    object
dtype: object

# After conversions
A      int32
B    float32
C      int64
D   category
dtype: object
```

#### Memory usage

```python
# Check memory usage
print(df.memory_usage())
print(df.memory_usage(deep=True))  # Include object dtypes' memory
```

### Basic attributes and methods

**Key points:**

- pandas objects have attributes for accessing metadata
- Common methods provide insight into data structure and content
- Understanding these basics is essential for effective data manipulation

#### Series attributes and methods

```python
s = pd.Series([10, 20, 30, 40], index=['a', 'b', 'c', 'd'], name='Numbers')

# Attributes
print(s.values)      # The underlying NumPy array
print(s.index)       # The index object
print(s.dtype)       # The data type
print(s.name)        # The name of the Series
print(s.shape)       # The shape (length)
print(s.size)        # Number of elements
print(s.ndim)        # Number of dimensions (always 1 for Series)

# Methods
print(s.head(2))     # First 2 elements
print(s.tail(2))     # Last 2 elements
print(s.describe())  # Statistical summary
print(s.unique())    # Unique values
print(s.count())     # Count non-NA values
print(s.value_counts())  # Count occurrences of each value
print(s.isnull())    # Check for NaN values
print(s.notnull())   # Check for non-NaN values
```

**Output:**

```
# s.values
[10 20 30 40]

# s.index
Index(['a', 'b', 'c', 'd'], dtype='object')

# s.head(2)
a    10
b    20
Name: Numbers, dtype: int64

# s.describe()
count     4.000000
mean     25.000000
std      12.909944
min      10.000000
25%      17.500000
50%      25.000000
75%      32.500000
max      40.000000
Name: Numbers, dtype: float64
```

#### DataFrame attributes and methods

```python
df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David'],
    'Age': [25, 30, 35, 40],
    'City': ['New York', 'Boston', 'Chicago', 'Denver']
}, index=['p1', 'p2', 'p3', 'p4'])

# Attributes
print(df.values)     # 2D NumPy array
print(df.columns)    # Column labels
print(df.index)      # Row labels
print(df.dtypes)     # Data types of each column
print(df.shape)      # (rows, columns)
print(df.size)       # Total number of elements
print(df.ndim)       # Number of dimensions (always 2 for DataFrame)
print(df.empty)      # Is the DataFrame empty?

# Access methods
print(df.head(2))    # First 2 rows
print(df.tail(2))    # Last 2 rows
print(df.info())     # Concise summary
print(df.describe()) # Statistical summary of numeric columns
print(df.T)          # Transpose
print(df.count())    # Count non-NA values
print(df.nunique())  # Count unique values in each column
print(df.isnull().sum())  # Count NaN values in each column
print(df.value_counts())  # Count unique combinations
```

**Output:**

```
# df.shape
(4, 3)

# df.head(2)
     Name  Age      City
p1  Alice   25  New York
p2    Bob   30    Boston

# df.info()
<class 'pandas.core.frame.DataFrame'>
Index: 4 entries, p1 to p4
Data columns (total 3 columns):
 #   Column  Non-Null Count  Dtype 
---  ------  --------------  ----- 
 0   Name    4 non-null      object
 1   Age     4 non-null      int64 
 2   City    4 non-null      object
dtypes: int64(1), object(2)
memory usage: 128.0+ bytes

# df.describe()
             Age
count   4.000000
mean   32.500000
std     6.454972
min    25.000000
25%    28.750000
50%    32.500000
75%    36.250000
max    40.000000
```

#### Basic data manipulation methods

```python
df = pd.DataFrame({
    'A': [1, 2, 3, 4],
    'B': [5, 6, 7, 8],
    'C': [9, 10, 11, 12]
})

# Copy the DataFrame
df_copy = df.copy()

# Getting specific column(s)
col_a = df['A']
subset = df[['A', 'C']]

# Adding new column
df['D'] = [13, 14, 15, 16]

# Dropping columns
df_no_b = df.drop('B', axis=1)
# axis:{0 or ‘index’, 1 or ‘columns’}, default 0

# Dropping rows
df_no_first = df.drop(0)

# Renaming columns
df_renamed = df.rename(columns={'A': 'Alpha', 'B': 'Beta'})

# Renaming index
df_reindexed = df.rename(index={0: 'row1', 1: 'row2'})

# Sorting values
df_sorted = df.sort_values('C', ascending=False)

# Sorting index
df_index_sorted = df.sort_index()

# Reset index
df_reset = df.reset_index()

# Set new index
df_set_index = df.set_index('A')
```

**Conclusion:** Understanding the basic data structures in pandas is fundamental to effective data analysis in Python. Series and DataFrames provide flexible containers for one-dimensional and two-dimensional data, respectively, with powerful indexing capabilities. Proper management of data types (dtypes) is crucial for memory efficiency and performance. The rich set of attributes and methods facilitates data exploration and manipulation, forming the foundation for more advanced pandas operations.

---

## Data Import/Export

### Reading/writing CSV, Excel, JSON

**Key points:**

- pandas provides versatile functions for reading and writing various file formats
- CSV operations are handled by read_csv() and to_csv()
- Excel operations use read_excel() and to_excel()
- JSON data can be processed with read_json() and to_json()
- Each function offers extensive parameters for customization

#### CSV Files

CSV (Comma-Separated Values) is one of the most common formats for tabular data. pandas provides robust support for reading and writing CSV files.

**Reading CSV files:**

```python
import pandas as pd

# Basic CSV reading
df = pd.read_csv('data.csv')

# Customizing CSV import
df = pd.read_csv('data.csv',
                 sep=',',                # Delimiter to use
                 header=0,               # Row to use as column names
                 index_col=0,            # Column to use as row labels
                 names=['A', 'B', 'C'],  # Column names to use
                 skiprows=2,             # Number of rows to skip
                 nrows=10,               # Number of rows to read
                 na_values=['NA', 'N/A'],# Additional NA/NaN strings
                 dtype={'A': 'float64', 'B': 'int32'},  # Column dtypes
                 parse_dates=['Date'],   # Parse columns as dates
                 date_format='%Y-%m-%d', # Date format
                 encoding='utf-8',       # File encoding
                 compression='gzip',     # For compressed files
                 thousands=',',          # Thousands separator
                 decimal='.',            # Decimal separator
                 comment='#',            # Comment character
                 quotechar='"',          # String quote character
                 escapechar='\\',        # Escape character
                 skip_blank_lines=True,  # Skip blank lines
                 usecols=['A', 'B', 'C'])# Use only these columns
```

**Writing CSV files:**

```python
# Basic CSV writing
df.to_csv('output.csv')

# Customizing CSV export
df.to_csv('output.csv',
          sep=',',                # Delimiter to use
          header=True,            # Write column names
          index=True,             # Write row names
          na_rep='NaN',           # String representation of NaN
          float_format='%.2f',    # Format for float numbers
          columns=['A', 'B'],     # Columns to write
          encoding='utf-8',       # File encoding
          compression='gzip',     # Compression type
          quoting=1,              # Quoting style
          quotechar='"',          # Character used to quote
          line_terminator='\n',   # Line terminator
          date_format='%Y-%m-%d', # Date format
          doublequote=True,       # Double quote handling
          escapechar='\\',        # Escape character
          decimal='.')            # Decimal separator
```

**Example with real data:**

```python
# Reading a CSV with various options
import io
import pandas as pd

# Sample CSV data
csv_data = """
date,item,price,quantity
2023-01-15,Apple,1.20,10
2023-01-15,Banana,0.50,20
2023-01-16,Orange,0.75,15
2023-01-17,Apple,1.25,8
"""

# Read from string buffer
df = pd.read_csv(io.StringIO(csv_data), 
                 parse_dates=['date'])

print(df.head())

# Write to CSV with formatting
df.to_csv('fruits.csv', 
          index=False, 
          float_format='%.2f',
          date_format='%Y-%m-%d')
```

**Output:**

```
        date    item  price  quantity
0 2023-01-15   Apple   1.20        10
1 2023-01-15  Banana   0.50        20
2 2023-01-16  Orange   0.75        15
3 2023-01-17   Apple   1.25         8
```

#### Excel Files

pandas uses the openpyxl, xlrd, and xlwt libraries for Excel file support.

**Reading Excel files:**

```python
# Basic Excel reading
df = pd.read_excel('data.xlsx')

# Customizing Excel import
df = pd.read_excel('data.xlsx',
                  sheet_name='Sheet1',    # Sheet to read (name, index, or list)
                  header=0,               # Row for header
                  names=['A', 'B', 'C'],  # Column names
                  index_col=0,            # Column(s) to use as index
                  usecols='A:C',          # Columns to read (range, list)
                  skiprows=2,             # Rows to skip
                  nrows=10,               # Number of rows to read
                  dtype={'A': float},     # Column data types
                  engine='openpyxl',      # Excel reader engine
                  na_values=['NA'],       # Values to consider as NaN
                  parse_dates=['Date'],   # Parse as datetime
                  date_parser=lambda x: pd.to_datetime(x, format='%Y/%m/%d'))

# Reading multiple sheets
xlsx = pd.ExcelFile('data.xlsx')
sheet_names = xlsx.sheet_names
df1 = pd.read_excel(xlsx, 'Sheet1')
df2 = pd.read_excel(xlsx, 'Sheet2')

# Read all sheets into a dictionary
all_dfs = pd.read_excel('data.xlsx', sheet_name=None)
```

**Writing Excel files:**

```python
# Basic Excel writing
df.to_excel('output.xlsx')

# Customizing Excel export
df.to_excel('output.xlsx',
           sheet_name='Sheet1',        # Sheet name
           na_rep='NA',                # NaN representation
           header=True,                # Include header
           index=True,                 # Include index
           startrow=0,                 # Starting row
           startcol=0,                 # Starting column
           float_format='%.2f',        # Float format
           freeze_panes=(1, 0),        # Freeze panes (rows, cols)
           engine='openpyxl',          # Excel writer engine
           date_format='yyyy-mm-dd')   # Date format

# Writing multiple sheets
with pd.ExcelWriter('output.xlsx', engine='openpyxl') as writer:
    df1.to_excel(writer, sheet_name='Sheet1')
    df2.to_excel(writer, sheet_name='Sheet2')
    
    # Adjust column widths
    for column in df1:
        column_width = max(df1[column].astype(str).map(len).max(), len(column))
        col_idx = df1.columns.get_loc(column)
        writer.sheets['Sheet1'].set_column(col_idx, col_idx, column_width)
```

**Example with real data:**

```python
# Creating two DataFrames
df1 = pd.DataFrame({
    'Date': pd.date_range('2023-01-01', periods=5),
    'Value1': [10, 20, 30, 40, 50],
    'Category': ['A', 'B', 'A', 'C', 'B']
})

df2 = pd.DataFrame({
    'Product': ['X', 'Y', 'Z'],
    'Price': [100, 200, 150],
    'Stock': [45, 32, 18]
})

# Write to multi-sheet Excel file
with pd.ExcelWriter('multi_sheet.xlsx', engine='openpyxl') as writer:
    df1.to_excel(writer, sheet_name='Sales', index=False)
    df2.to_excel(writer, sheet_name='Inventory', index=False)
```

#### JSON Files

JSON (JavaScript Object Notation) is a common format for web data and APIs.

**Reading JSON files:**

```python
# Basic JSON reading
df = pd.read_json('data.json')

# Customizing JSON import
df = pd.read_json('data.json',
                 orient='records',       # JSON structure format
                 typ='frame',            # Type of object to recover
                 dtype={'A': 'float64'}, # Column dtypes
                 convert_dates=['date'], # Columns to parse as dates
                 precise_float=True,     # Precise float parsing
                 date_unit='ns',         # Time unit for timestamp conversion
                 encoding='utf-8',       # File encoding
                 lines=False)            # Read as JSON Lines format

# Reading JSON Lines format (one JSON object per line)
df = pd.read_json('data.jsonl', lines=True)

# Reading nested JSON
df = pd.json_normalize(
    pd.read_json('data.json', typ='dict'),
    record_path=['records'],
    meta=['id', 'name'],
    meta_prefix='meta_',
    sep='_')
```

**Writing JSON files:**

```python
# Basic JSON writing
df.to_json('output.json')

# Customizing JSON export
df.to_json('output.json',
          orient='records',       # JSON structure format ('split', 'records', 'index', 'columns', 'values')
          date_format='iso',      # 'epoch', 'iso'
          double_precision=10,    # Float precision
          force_ascii=True,       # Encode non-ASCII as ASCII
          date_unit='ms',         # Time unit for timestamp conversion
          default_handler=str,    # Handler for non-serializable objects
          indent=4)               # Indentation level for pretty printing

# Writing JSON Lines format
df.to_json('output.jsonl', orient='records', lines=True)
```

**Example with real data:**

```python
# Sample JSON data
json_data = """
[
  {"date": "2023-01-15", "name": "John", "score": 85, "subjects": ["math", "physics"]},
  {"date": "2023-01-15", "name": "Mary", "score": 92, "subjects": ["biology", "chemistry"]},
  {"date": "2023-01-16", "name": "Bob", "score": 78, "subjects": ["history", "english"]}
]
"""

# Read JSON data
df = pd.read_json(io.StringIO(json_data), 
                 convert_dates=['date'])

print(df)

# Export with different orientations
print("\nOrient: records")
print(df.to_json(orient='records', indent=2))

print("\nOrient: index")
print(df.to_json(orient='index', indent=2))

print("\nOrient: columns")
print(df.to_json(orient='columns', indent=2))
```

**Output:**

```
        date  name  score              subjects
0 2023-01-15  John     85    [math, physics]
1 2023-01-15  Mary     92  [biology, chemistry]
2 2023-01-16   Bob     78  [history, english]

Orient: records
[
  {
    "date":1673740800000,
    "name":"John",
    "score":85,
    "subjects":["math","physics"]
  },
  {
    "date":1673740800000,
    "name":"Mary",
    "score":92,
    "subjects":["biology","chemistry"]
  },
  {
    "date":1673827200000,
    "name":"Bob",
    "score":78,
    "subjects":["history","english"]
  }
]
```

#### Other File Formats

pandas supports many other file formats:

```python
# Parquet files (columnar storage)
df.to_parquet('data.parquet', compression='snappy')
df = pd.read_parquet('data.parquet')

# HDF5 files (hierarchical data)
df.to_hdf('data.h5', key='df', mode='w')
df = pd.read_hdf('data.h5', key='df')

# Feather files (fast binary)
df.to_feather('data.feather')
df = pd.read_feather('data.feather')

# Pickle files (Python serialization)
df.to_pickle('data.pkl')
df = pd.read_pickle('data.pkl')

# HTML tables
df.to_html('data.html')
dfs = pd.read_html('data.html')  # Returns list of DataFrames

# Stata files
df.to_stata('data.dta')
df = pd.read_stata('data.dta')

# SAS files
df = pd.read_sas('data.sas7bdat')

# SPSS files
df = pd.read_spss('data.sav')
```

### Database connections

**Key points:**

- pandas can connect to SQL databases using sqlalchemy
- Supports reading queries directly into DataFrames
- Can write DataFrames back to database tables
- Handles connection management and SQL dialect differences

#### SQL Database Operations

pandas integrates with SQLAlchemy to connect to various databases like SQLite, PostgreSQL, MySQL, Oracle, and Microsoft SQL Server.

**Basic database operations:**

```python
import pandas as pd
from sqlalchemy import create_engine

# Create connection engine
# Format: dialect+driver://username:password@host:port/database
sqlite_engine = create_engine('sqlite:///database.db')
# postgres_engine = create_engine('postgresql://username:password@localhost:5432/mydatabase')
# mysql_engine = create_engine('mysql+pymysql://username:password@localhost:3306/mydatabase')

# Read data from SQL query
df = pd.read_sql_query('SELECT * FROM table_name WHERE column_name > 100', sqlite_engine)

# Read entire table
df = pd.read_sql_table('table_name', sqlite_engine)

# Read with SQL query as string
query = """
SELECT a.column1, b.column2
FROM table_a a
JOIN table_b b ON a.id = b.a_id
WHERE a.column3 > 100
ORDER BY a.column1
"""
df = pd.read_sql(query, sqlite_engine)

# Write DataFrame to SQL table
df.to_sql('table_name', sqlite_engine, 
          if_exists='replace',  # 'fail', 'replace', or 'append'
          index=False,          # Whether to include index
          schema='public',      # Database schema
          dtype={'column1': Integer()},  # Column data types
          chunksize=1000)       # Batch size for writing
```

**Example with SQLite:**

```python
import pandas as pd
import numpy as np
from sqlalchemy import create_engine

# Create a sample DataFrame
df = pd.DataFrame({
    'id': range(1, 6),
    'value': np.random.normal(0, 1, 5),
    'category': np.random.choice(['A', 'B', 'C'], 5)
})

# Create SQLite database engine
engine = create_engine('sqlite:///example.db')

# Write to database
df.to_sql('sample_data', engine, if_exists='replace', index=False)

# Query the database
result = pd.read_sql_query("""
SELECT category, COUNT(*) as count, AVG(value) as avg_value
FROM sample_data
GROUP BY category
ORDER BY avg_value DESC
""", engine)

print(result)

# Read the entire table
full_table = pd.read_sql_table('sample_data', engine)
print("\nFull table:")
print(full_table)
```

**Output:**

```
  category  count  avg_value
0        B      2   0.584625
1        A      1   0.107773
2        C      2  -0.677129

Full table:
   id     value category
0   1  0.107773        A
1   2  0.955974        B
2   3 -0.876250        C
3   4  0.213277        B
4   5 -0.478008        C
```

#### Advanced SQL Operations

```python
# Parameterized queries (prevents SQL injection)
param_query = "SELECT * FROM table_name WHERE column_name = %(param_value)s"
df = pd.read_sql(param_query, engine, params={'param_value': 'my_value'})

# Working with database transactions
with engine.begin() as connection:
    df1.to_sql('table1', connection, if_exists='append')
    df2.to_sql('table2', connection, if_exists='append')
    # Both operations succeed or fail together

# Executing raw SQL
from sqlalchemy import text
with engine.connect() as connection:
    connection.execute(text("CREATE INDEX idx_column ON table_name (column_name)"))

# Chunked reading for large datasets
chunks = []
for chunk in pd.read_sql_query("SELECT * FROM large_table", engine, chunksize=10000):
    # Process each chunk
    chunks.append(chunk)
# Concatenate all chunks
df = pd.concat(chunks)
```

### Web data scraping with pandas

**Key points:**

- pandas provides tools to extract tabular data from HTML
- read_html() automatically parses HTML tables into DataFrames
- Can be combined with requests library for web scraping
- Works with static web content containing tables

#### Scraping HTML Tables

The `read_html()` function automatically finds and parses HTML tables into a list of DataFrames.

```python
import pandas as pd
import requests

# Scrape tables from a URL
url = 'https://en.wikipedia.org/wiki/List_of_countries_by_population'
tables = pd.read_html(url)

# The result is a list of DataFrames, one for each table on the page
print(f"Number of tables found: {len(tables)}")

# Usually, you'll select one table from the list
df = tables[0]  # First table
print(df.head())

# Customizing HTML table import
dfs = pd.read_html(url,
                  match='Country',     # Only tables containing this string
                  header=0,            # Row to use as header
                  index_col=0,         # Column to use as index
                  attrs={'class': 'wikitable'},  # HTML attributes to match
                  encoding='utf-8',    # File encoding
                  flavor='html5lib',   # Parser: 'bs4', 'html5lib', or 'lxml'
                  displayed_only=True) # Only visible tables
```

#### Combining with requests for authentication or dynamic content

```python
import pandas as pd
import requests

# For websites requiring authentication or cookies
session = requests.Session()
session.headers.update({
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
})

# Optional: Login first
login_data = {'username': 'user', 'password': 'pass'}
session.post('https://example.com/login', data=login_data)

# Now get the data
response = session.get('https://example.com/data_page')
dfs = pd.read_html(response.text)

# Or using a direct pass-through with 'requests'
url = 'https://example.com/table_page'
response = requests.get(url)
dfs = pd.read_html(response.text)
df = dfs[0]  # Select first table
```

#### Real example: Scraping COVID-19 statistics

```python
import pandas as pd

# Scrape COVID-19 data from Worldometer
url = 'https://www.worldometers.info/coronavirus/'
tables = pd.read_html(url)

# The main table is usually the first large one
covid_df = tables[0]

# Clean up the data
covid_df.columns = covid_df.columns.str.replace('\n', ' ')
covid_df = covid_df.iloc[:-1]  # Remove the 'Total:' row if present

# Display the top countries by cases
print(covid_df.head())
```

#### Working with HTML content from a file or string

```python
# From a local HTML file
df_list = pd.read_html('local_file.html')

# From a string containing HTML
html_str = """
<table>
    <tr>
        <th>Name</th>
        <th>Age</th>
    </tr>
    <tr>
        <td>John</td>
        <td>30</td>
    </tr>
    <tr>
        <td>Mary</td>
        <td>25</td>
    </tr>
</table>
"""
df_list = pd.read_html(html_str)
df = df_list[0]
print(df)
```

**Output:**

```
   Name  Age
0  John   30
1  Mary   25
```

#### Limitations and Alternative Approaches

While `read_html()` is convenient, it has limitations:

1. It only works with HTML tables (`<table>` elements)
2. It cannot handle JavaScript-rendered content
3. Limited customization for complex scraping needs

For more complex web scraping:

```python
# Using BeautifulSoup for more flexibility
import pandas as pd
import requests
from bs4 import BeautifulSoup

url = 'https://example.com/page'
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

# Extract data from a specific table
table = soup.find('table', {'id': 'data-table'})
rows = []

for tr in table.find_all('tr')[1:]:  # Skip header row
    row = [td.text.strip() for td in tr.find_all('td')]
    rows.append(row)

# Create DataFrame with custom column names
df = pd.DataFrame(rows, columns=['Column1', 'Column2', 'Column3'])
print(df)

# For JavaScript-rendered content, consider using Selenium
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

options = Options()
options.headless = True
driver = webdriver.Chrome(options=options)
driver.get('https://example.com/javascript-page')

# Wait for JavaScript to render
import time
time.sleep(2)

# Now parse the rendered HTML
html = driver.page_source
driver.quit()

dfs = pd.read_html(html)
df = dfs[0]
```

**Conclusion:** pandas provides comprehensive tools for data import and export across various formats, making it a versatile library for data manipulation. Its CSV, Excel, and JSON processing capabilities allow for fine-tuned control of data reading and writing operations. The SQLAlchemy integration enables seamless database connectivity, while the HTML parsing features facilitate web data extraction. Understanding these import/export mechanisms is essential for any data analysis workflow, as they form the foundation for bringing data into the pandas ecosystem and sharing processed results.

---

## Initial Data Exploration

### head(), tail(), info(), describe()

**Key points:**

- These methods provide quick insights into dataset structure and content
- head() and tail() show the first and last rows of the dataset
- info() provides metadata and memory usage information
- describe() generates statistical summaries of the data

#### head() and tail()

The `head()` and `tail()` methods allow you to quickly inspect the first and last records of a DataFrame or Series.

```python
import pandas as pd
import numpy as np

# Create a sample DataFrame
df = pd.DataFrame({
    'Name': ['Alice', 'Bob', 'Charlie', 'David', 'Eva', 'Frank', 'Grace', 'Hannah'],
    'Age': [24, 27, 22, 32, 29, 35, 19, 31],
    'City': ['New York', 'Boston', 'Chicago', 'Denver', 'Miami', 'Seattle', 'Austin', 'Portland'],
    'Salary': [65000, 72000, 59000, 83000, 67000, 91000, 48000, 76000],
    'Hire_Date': pd.date_range('2021-01-01', periods=8, freq='M')
})

# View the first 5 rows (default)
print("Default head():")
print(df.head())

# View the first 3 rows
print("\nhead(3):")
print(df.head(3))

# View the last 5 rows (default)
print("\nDefault tail():")
print(df.tail())

# View the last 2 rows
print("\ntail(2):")
print(df.tail(2))
```

**Output:**

```
Default head():
      Name  Age      City  Salary  Hire_Date
0    Alice   24  New York   65000 2021-01-31
1      Bob   27    Boston   72000 2021-02-28
2  Charlie   22   Chicago   59000 2021-03-31
3    David   32    Denver   83000 2021-04-30
4      Eva   29     Miami   67000 2021-05-31

head(3):
      Name  Age      City  Salary  Hire_Date
0    Alice   24  New York   65000 2021-01-31
1      Bob   27    Boston   72000 2021-02-28
2  Charlie   22   Chicago   59000 2021-03-31

Default tail():
      Name  Age      City  Salary  Hire_Date
3    David   32    Denver   83000 2021-04-30
4      Eva   29     Miami   67000 2021-05-31
5    Frank   35   Seattle   91000 2021-06-30
6    Grace   19    Austin   48000 2021-07-31
7   Hannah   31  Portland   76000 2021-08-31

tail(2):
      Name  Age      City  Salary  Hire_Date
6    Grace   19    Austin   48000 2021-07-31
7   Hannah   31  Portland   76000 2021-08-31
```

#### info()

The `info()` method provides a concise summary of a DataFrame, including:

- Index range
- Column names
- Non-null values count
- Data types
- Memory usage

```python
# Get DataFrame information
print("DataFrame info():")
df.info()

# With memory usage calculation for object dtypes
print("\nWith deep memory usage:")
df.info(memory_usage='deep')

# Get information for a subset of columns
print("\ninfo() for specific columns:")
df[['Name', 'Age']].info()

# Customize display
print("\nCustomized info display:")
df.info(verbose=True, show_counts=True, null_counts=True, max_cols=10)
```

**Output:**

```
DataFrame info():
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 8 entries, 0 to 7
Data columns (total 5 columns):
 #   Column     Non-Null Count  Dtype         
---  ------     --------------  -----         
 0   Name       8 non-null      object        
 1   Age        8 non-null      int64         
 2   City       8 non-null      object        
 3   Salary     8 non-null      int64         
 4   Hire_Date  8 non-null      datetime64[ns]
dtypes: datetime64[ns](1), int64(2), object(2)
memory usage: 448.0+ bytes

With deep memory usage:
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 8 entries, 0 to 7
Data columns (total 5 columns):
 #   Column     Non-Null Count  Dtype         
---  ------     --------------  -----         
 0   Name       8 non-null      object        
 1   Age        8 non-null      int64         
 2   City       8 non-null      object        
 3   Salary     8 non-null      int64         
 4   Hire_Date  8 non-null      datetime64[ns]
dtypes: datetime64[ns](1), int64(2), object(2)
memory usage: 1.1 KB
```

#### describe()

The `describe()` method generates descriptive statistics for numerical and object columns:

```python
# Statistical summary of numerical columns (default)
print("Default describe():")
print(df.describe())

# Include object columns
print("\ndescribe() with all columns:")
print(df.describe(include='all'))

# For specific column types
print("\ndescribe() for numeric columns only:")
print(df.describe(include=[np.number]))

print("\ndescribe() for object columns only:")
print(df.describe(include=['object']))

# Customize percentiles
print("\nCustomized percentiles:")
print(df.describe(percentiles=[0.1, 0.5, 0.9]))

# Transpose for better viewing
print("\nTransposed view:")
print(df.describe().T)
```

**Output:**

```
Default describe():
             Age        Salary
count   8.000000      8.00000
mean   27.375000  70125.00000
std     5.423261  13840.25446
min    19.000000  48000.00000
25%    23.500000  63000.00000
50%    28.000000  69500.00000
75%    31.250000  77000.00000
max    35.000000  91000.00000

describe() with all columns:
        Name        Age        City       Salary   Hire_Date
count      8   8.000000           8      8.00000          8
unique     8        NaN           8         NaN        NaN
top    Alice        NaN  New York         NaN        NaN
freq       1        NaN           1         NaN        NaN
mean     NaN  27.375000         NaN  70125.00000        NaN
std      NaN   5.423261         NaN  13840.25446        NaN
min      NaN  19.000000         NaN  48000.00000 2021-01-31
25%      NaN  23.500000         NaN  63000.00000 2021-02-28
50%      NaN  28.000000         NaN  69500.00000 2021-04-30
75%      NaN  31.250000         NaN  77000.00000 2021-06-30
max      NaN  35.000000         NaN  91000.00000 2021-08-31

Transposed view:
             count       mean        std     min      25%     50%      75%     max
Age           8.0  27.375000   5.423261    19.0    23.50    28.0    31.25    35.0
Salary        8.0  70125.000000  13840.254455  48000.0  63000.00  69500.0  77000.00  91000.0
```

### Shape and dimensions

**Key points:**

- shape attribute returns a tuple of (rows, columns)
- size attribute returns the total number of elements
- ndim attribute returns the number of dimensions
- axes attribute returns the row and column labels

```python
# Get dimensions
print(f"DataFrame shape: {df.shape}")  # (rows, columns)
print(f"Number of elements: {df.size}")  # rows × columns
print(f"Number of dimensions: {df.ndim}")  # Always 2 for DataFrames, 1 for Series

# DataFrame axes
print(f"DataFrame axes: {df.axes}")  # [row labels, column labels]

# Individual axis lengths
print(f"Number of rows: {len(df)}")
print(f"Number of rows: {df.shape[0]}")
print(f"Number of columns: {len(df.columns)}")
print(f"Number of columns: {df.shape[1]}")

# For a Series
series = df['Age']
print(f"\nSeries shape: {series.shape}")  # (n,)
print(f"Series size: {series.size}")  # number of elements
print(f"Series dimensions: {series.ndim}")  # Always 1
print(f"Series axes: {series.axes}")  # [index]
```

**Output:**

```
DataFrame shape: (8, 5)
Number of elements: 40
Number of dimensions: 2
DataFrame axes: [RangeIndex(start=0, stop=8, step=1), Index(['Name', 'Age', 'City', 'Salary', 'Hire_Date'], dtype='object')]
Number of rows: 8
Number of rows: 8
Number of columns: 5
Number of columns: 5

Series shape: (8,)
Series size: 8
Series dimensions: 1
Series axes: [RangeIndex(start=0, stop=8, step=1)]
```

#### Memory usage analysis

Understanding memory usage is important when working with large datasets:

```python
# Memory usage
print(f"DataFrame memory usage: {df.memory_usage()} bytes")

# Deep memory usage (account for object types)
print(f"\nDeep memory usage: {df.memory_usage(deep=True)} bytes")

# Total memory usage
print(f"\nTotal memory usage: {df.memory_usage().sum()} bytes")
print(f"Total deep memory usage: {df.memory_usage(deep=True).sum()} bytes")
```

**Output:**

```
DataFrame memory usage:
Index        128
Name          64
Age           64
City          64
Salary        64
Hire_Date     64
dtype: int64 bytes

Deep memory usage:
Index        128
Name         408
Age           64
City         536
Salary        64
Hire_Date     64
dtype: int64 bytes

Total memory usage: 448 bytes
Total deep memory usage: 1264 bytes
```

### Data sampling

**Key points:**

- pandas provides methods to sample data randomly
- Useful for working with subsets of large datasets
- Can sample with or without replacement
- Weights can be applied to control sampling probability

#### Random sampling

```python
# Sample 3 random rows (without replacement)
print("Random sample of 3 rows:")
print(df.sample(n=3))

# Sample with replacement (allows duplicates)
print("\nSample with replacement:")
print(df.sample(n=3, replace=True))

# Sample a fraction of the data
print("\nSample 50% of the data:")
print(df.sample(frac=0.5))

# Sample with weights (probability proportional to Age)
print("\nWeighted sample based on Age:")
print(df.sample(n=3, weights=df['Age']))

# Sampling with a random seed for reproducibility
print("\nSampling with random seed:")
print(df.sample(n=2, random_state=42))
```

**Output:**

```
Random sample of 3 rows:
     Name  Age     City  Salary  Hire_Date
5   Frank   35  Seattle   91000 2021-06-30
2  Charlie   22  Chicago   59000 2021-03-31
7  Hannah   31  Portland   76000 2021-08-31

Sample with replacement:
   Name  Age    City  Salary  Hire_Date
1   Bob   27  Boston   72000 2021-02-28
1   Bob   27  Boston   72000 2021-02-28
7  Hannah   31  Portland   76000 2021-08-31

Sample 50% of the data:
    Name  Age      City  Salary  Hire_Date
1    Bob   27    Boston   72000 2021-02-28
3  David   32    Denver   83000 2021-04-30
0  Alice   24  New York   65000 2021-01-31
6  Grace   19    Austin   48000 2021-07-31

Weighted sample based on Age:
    Name  Age     City  Salary  Hire_Date
5  Frank   35  Seattle   91000 2021-06-30
3  David   32   Denver   83000 2021-04-30
7  Hannah   31  Portland   76000 2021-08-31

Sampling with random seed:
   Name  Age   City  Salary  Hire_Date
3  David   32  Denver   83000 2021-04-30
4    Eva   29   Miami   67000 2021-05-31
```

#### Stratified sampling

For stratified sampling, you can group data first:

```python
# Create a new column for age groups
df['Age_Group'] = pd.cut(df['Age'], bins=[18, 25, 30, 40], labels=['Young', 'Middle', 'Senior'])

# Stratified sampling: equal representation from each group
stratified_sample = pd.DataFrame()

for group_name, group_df in df.groupby('Age_Group'):
    stratified_sample = pd.concat([stratified_sample, group_df.sample(n=1)])

print("Stratified sample (one from each age group):")
print(stratified_sample[['Name', 'Age', 'Age_Group']])
```

**Output:**

```
Stratified sample (one from each age group):
      Name  Age Age_Group
0    Alice   24     Young
1      Bob   27    Middle
5    Frank   35    Senior
```

#### Systematic sampling

```python
# Systematic sampling: take every nth row
n = 3  # Take every 3rd row
systematic_sample = df.iloc[::n]

print("Systematic sample (every 3rd row):")
print(systematic_sample[['Name', 'Age']])
```

**Output:**

```
Systematic sample (every 3rd row):
      Name  Age
0    Alice   24
3    David   32
6    Grace   19
```

### Advanced exploration techniques

#### Distribution visualization

```python
import matplotlib.pyplot as plt

# Distribution of Age
plt.figure(figsize=(10, 6))
df['Age'].plot(kind='hist', bins=10, title='Age Distribution')
plt.axvline(df['Age'].mean(), color='red', linestyle='dashed', linewidth=2, label=f'Mean: {df["Age"].mean():.1f}')
plt.axvline(df['Age'].median(), color='green', linestyle='dashed', linewidth=2, label=f'Median: {df["Age"].median():.1f}')
plt.legend()
plt.tight_layout()
plt.show()

# Box plot for Salary
plt.figure(figsize=(8, 6))
df.boxplot(column='Salary')
plt.title('Salary Distribution')
plt.tight_layout()
plt.show()
```

#### Correlation analysis

```python
# Correlation between numerical variables
correlation = df[['Age', 'Salary']].corr()
print("\nCorrelation matrix:")
print(correlation)

# Visualize correlation
plt.figure(figsize=(8, 6))
plt.imshow(correlation, cmap='coolwarm', interpolation='none', vmin=-1, vmax=1)
plt.colorbar()
plt.xticks(range(len(correlation.columns)), correlation.columns, rotation=45)
plt.yticks(range(len(correlation.columns)), correlation.columns)
plt.title('Correlation Matrix')
for i in range(len(correlation.columns)):
    for j in range(len(correlation.columns)):
        plt.text(i, j, f'{correlation.iloc[i, j]:.2f}', ha='center', va='center', color='black')
plt.tight_layout()
plt.show()
```

**Output:**

```
Correlation matrix:
          Age    Salary
Age  1.000000  0.889588
Salary  0.889588  1.000000
```

#### Aggregation by groups

```python
# Group by Age_Group
grouped = df.groupby('Age_Group')

# Aggregated statistics by group
print("\nAggregated statistics by age group:")
print(grouped[['Salary']].agg(['count', 'mean', 'min', 'max']))

# Multiple aggregations
print("\nCustom aggregations:")
aggregations = {
    'Age': ['mean', 'median', 'std'],
    'Salary': ['mean', 'median', 'min', 'max']
}
print(grouped.agg(aggregations))
```

**Output:**

```
Aggregated statistics by age group:
          Salary                    
          count       mean     min     max
Age_Group                               
Young        2  56500.000  48000   65000
Middle       3  69000.000  67000   72000
Senior       3  83333.333  76000   91000

Custom aggregations:
                Age                     Salary                        
               mean median       std     mean   median     min     max
Age_Group                                                             
Young      21.50000   21.5  3.535534  56500.0  56500.0  48000   65000
Middle     27.66667   27.0  1.154701  69000.0  67000.0  67000   72000
Senior     32.66667   32.0  2.081666  83333.3  83000.0  76000   91000
```

#### Missing values exploration

Let's add some missing values to our dataset to explore handling them:

```python
# Add some missing values to the DataFrame
df_with_na = df.copy()
df_with_na.loc[0, 'Salary'] = np.nan
df_with_na.loc[1, 'City'] = np.nan
df_with_na.loc[2, 'Age'] = np.nan
df_with_na.loc[3, 'Hire_Date'] = np.nan

# Count missing values per column
print("\nMissing values per column:")
print(df_with_na.isnull().sum())

# Percentage of missing values
print("\nPercentage of missing values per column:")
print((df_with_na.isnull().sum() / len(df_with_na)) * 100)

# Visualize missing data
plt.figure(figsize=(10, 6))
import seaborn as sns
sns.heatmap(df_with_na.isnull(), cbar=False, cmap='viridis', yticklabels=False)
plt.title('Missing Data')
plt.tight_layout()
plt.show()

# DataFrame with only rows containing missing values
print("\nRows with missing values:")
print(df_with_na[df_with_na.isnull().any(axis=1)])
```

**Output:**

```
Missing values per column:
Name         0
Age          1
City         1
Salary       1
Hire_Date    1
Age_Group    1
dtype: int64

Percentage of missing values per column:
Name         0.000000
Age         12.500000
City        12.500000
Salary      12.500000
Hire_Date   12.500000
Age_Group   12.500000
dtype: float64

Rows with missing values:
     Name   Age      City  Salary  Hire_Date Age_Group
0   Alice  24.0  New York     NaN 2021-01-31     Young
1     Bob  27.0      NaN  72000.0 2021-02-28    Middle
2  Charlie   NaN   Chicago  59000.0 2021-03-31      NaN
3    David  32.0    Denver  83000.0        NaN    Senior
```

#### Value counts and unique values

```python
# Count occurrences of each unique value in 'City' column
print("\nCity value counts:")
print(df['City'].value_counts())

# Unique values
print("\nUnique cities:")
print(df['City'].unique())

# Number of unique values
print(f"Number of unique cities: {df['City'].nunique()}")

# For categorical data
df['Income_Level'] = pd.cut(df['Salary'], 
                           bins=[0, 60000, 80000, 100000], 
                           labels=['Low', 'Medium', 'High'])

print("\nIncome level counts:")
print(df['Income_Level'].value_counts())
```

**Output:**

```
City value counts:
New York    1
Boston      1
Chicago     1
Denver      1
Miami       1
Seattle     1
Austin      1
Portland    1
Name: count, dtype: int64

Unique cities:
['New York' 'Boston' 'Chicago' 'Denver' 'Miami' 'Seattle' 'Austin' 'Portland']
Number of unique cities: 8

Income level counts:
Medium    4
Low       2
High      2
Name: count, dtype: int64
```

**Conclusion:** Initial data exploration is a critical first step in any data analysis project. pandas provides a rich set of tools for quickly gaining insights into dataset structure, content, and characteristics. The head() and tail() methods let you preview records, while info() offers metadata about the dataset structure. The describe() method generates comprehensive statistical summaries, while shape attributes reveal dimensionality. Sampling techniques allow working with manageable subsets of data. Together, these exploration tools form the foundation for making informed decisions about data cleaning, preprocessing, and analysis strategies.

---
# Data Selection and Manipulation

## Indexing and Selection

### loc and iloc

The `loc` and `iloc` accessors are fundamental tools for data selection and manipulation in pandas.

`loc` is label-based, which means it uses the labels of the index to select data. It can select both rows and columns with label-based indexing.

```python
# Basic selection with loc
df.loc[row_label, column_label]

# Select a single row by label
df.loc['row_1']

# Select multiple rows
df.loc[['row_1', 'row_3']]

# Select rows and columns
df.loc['row_1':'row_3', 'col_A':'col_C']

# Using boolean arrays with loc
df.loc[df['column'] > value]
```

`iloc` is integer position-based indexing. It selects data based on its numerical position in the DataFrame (starting from 0).

```python
# Basic selection with iloc
df.iloc[row_position, column_position]

# Select a single row by position
df.iloc[0]

# Select multiple rows
df.iloc[[0, 2]]

# Select rows and columns by position ranges
df.iloc[0:3, 0:3]

# Using combinations
df.iloc[-1, 0:5]  # Last row, first 5 columns
```

**Key Points**:

- `loc` uses labels/indices and is inclusive of both endpoints
- `iloc` uses integer positions and is inclusive of start, exclusive of end
- Both can be used with slices, lists, boolean arrays, or single values
- `loc` accepts column names directly, while `iloc` requires column positions

### Boolean Indexing

Boolean indexing allows you to filter DataFrames based on conditions, creating powerful and flexible selections.

```python
# Single condition
filtered_df = df[df['column'] > value]

# Multiple conditions using & (and) and | (or)
filtered_df = df[(df['column1'] > value1) & (df['column2'] < value2)]

# Using isin for membership tests
filtered_df = df[df['column'].isin(['value1', 'value2', 'value3'])]

# Using string methods
filtered_df = df[df['text_column'].str.contains('pattern')]

# Combining with loc
df.loc[df['column'] > value, ['col1', 'col2']]
```

**Example**:

```python
import pandas as pd

# Create a sample DataFrame
data = {
    'Name': ['John', 'Anna', 'Peter', 'Linda'],
    'Age': [28, 34, 29, 42],
    'City': ['New York', 'Paris', 'Berlin', 'London'],
    'Salary': [65000, 70000, 62000, 85000]
}
df = pd.DataFrame(data)

# Filter people who are older than 30 and earn more than 65000
result = df[(df['Age'] > 30) & (df['Salary'] > 65000)]

# Output
print(result)
```

**Output**:

```
    Name  Age    City  Salary
1   Anna   34   Paris   70000
3  Linda   42  London   85000
```

### Query Method

The `query()` method provides a concise way to filter DataFrames using a string syntax that's often more readable than boolean indexing.

```python
# Basic query
df.query('column > value')

# Multiple conditions
df.query('column1 > value1 and column2 < value2')

# Using variables from the outer scope with @
value = 30
df.query('column > @value')

# Working with string columns
df.query('column == "some_string"')

# Complex conditions
df.query('(column1 > column2) or (column3 in ["A", "B"])')
```

**Example**:

```python
import pandas as pd

data = {
    'Name': ['John', 'Anna', 'Peter', 'Linda'],
    'Age': [28, 34, 29, 42],
    'City': ['New York', 'Paris', 'Berlin', 'London'],
    'Salary': [65000, 70000, 62000, 85000]
}
df = pd.DataFrame(data)

# Using query to filter
min_age = 30
min_salary = 65000
result = df.query('Age > @min_age and Salary > @min_salary')

# Output
print(result)
```

**Output**:

```
    Name  Age    City  Salary
1   Anna   34   Paris   70000
3  Linda   42  London   85000
```

### Performance Considerations

Different indexing methods have varying performance characteristics depending on DataFrame size and operations:

- `loc` and `iloc` are generally faster for single row/column access
- Boolean indexing is versatile but can be memory-intensive for large DataFrames
- `query()` can be more efficient for complex filtering on large DataFrames as it leverages the numexpr library when available
- Chain operations can impact performance; it's often better to perform selections in fewer steps

### Advanced Techniques

#### Combining Multiple Selection Methods

```python
# Using loc with boolean indexing
df.loc[df['column'].between(10, 20), ['col1', 'col2']]

# Using query results with iloc
positions = df.query('condition').index
df.iloc[positions]
```

#### Cross-Section Selection

```python
# Select with xs for MultiIndex DataFrames
df.xs('level_value', level='level_name', axis=0)
```

#### Using at and iat for Single Cell Access

```python
# Fast scalar lookup by label
df.at[row_label, column_label]

# Fast scalar lookup by position
df.iat[row_position, column_position]
```

**Key Points**:

- `at` and `iat` are optimized for single value lookups and assignments
- They're significantly faster than `loc` and `iloc` for single value operations
- Should be used when repeatedly accessing individual values in performance-critical code

Related topics you might find useful: DataFrame creation and manipulation, MultiIndex handling, GroupBy operations, and data cleaning techniques in pandas.

---

## Data Cleaning

### Handling Missing Values

Missing values in pandas are typically represented as `NaN` (Not a Number) and can significantly impact data analysis and model performance. Pandas provides several methods to detect, analyze, and handle missing values effectively.

#### Detecting Missing Values

```python
# Check for missing values
df.isna()  # Returns a DataFrame of the same shape with boolean values
df.isnull()  # Alias for isna()

# Count missing values in each column
df.isna().sum()

# Get percentage of missing values
df.isna().mean() * 100

# Check if any value in a DataFrame is missing
df.isna().any()

# Check if any value in a specific column is missing
df['column'].isna().any()
```

#### Dropping Missing Values

```python
# Drop rows with any missing values
df.dropna()

# Drop rows where all values are missing
df.dropna(how='all')

# Drop rows with missing values in specific columns
df.dropna(subset=['column1', 'column2'])

# Drop columns with missing values
df.dropna(axis=1)

# Drop rows with at least N non-missing values
df.dropna(thresh=N)
```

#### Filling Missing Values

```python
# Fill all missing values with a specific value
df.fillna(value)

# Fill missing values with different values for each column
df.fillna({'column1': value1, 'column2': value2})

# Fill with forward fill method (use previous valid value)
df.fillna(method='ffill') 
# or
df.fillna(method='pad')

# Fill with backward fill method (use next valid value)
df.fillna(method='bfill')
# or
df.fillna(method='backfill')

# Limit the number of consecutive fills
df.fillna(method='ffill', limit=3)

# Fill with column mean/median/mode
df['column'].fillna(df['column'].mean())
df['column'].fillna(df['column'].median())
df['column'].fillna(df['column'].mode()[0])
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create a sample DataFrame with missing values
data = {
    'A': [1, 2, np.nan, 4, 5],
    'B': [np.nan, 2, 3, 4, 5],
    'C': [1, 2, 3, np.nan, 5]
}
df = pd.DataFrame(data)

# Fill missing values with column means
df_filled = df.copy()
for column in df_filled.columns:
    df_filled[column].fillna(df_filled[column].mean(), inplace=True)

# Output
print("Original DataFrame:")
print(df)
print("\nDataFrame with filled values:")
print(df_filled)
```

**Output**:

```
Original DataFrame:
     A    B    C
0  1.0  NaN  1.0
1  2.0  2.0  2.0
2  NaN  3.0  3.0
3  4.0  4.0  NaN
4  5.0  5.0  5.0

DataFrame with filled values:
     A    B    C
0  1.0  3.5  1.0
1  2.0  2.0  2.0
2  3.0  3.0  3.0
3  4.0  4.0  2.75
4  5.0  5.0  5.0
```

#### Interpolation

```python
# Linear interpolation
df.interpolate()

# Different interpolation methods
df.interpolate(method='linear')  # Default
df.interpolate(method='time')  # For time series data
df.interpolate(method='polynomial', order=2)  # Polynomial interpolation
df.interpolate(method='spline', order=3)  # Spline interpolation
```

**Key Points**:

- Consider your data's context when deciding how to handle missing values
- Dropping can lose valuable information but may be necessary for completely random missing data
- Imputation methods should align with the data's nature (time series vs cross-sectional)
- Document any changes to maintain data provenance

### Duplicate Removal

Duplicates in datasets can skew analysis results and waste computational resources. Pandas offers efficient ways to identify and handle duplicate records.

#### Identifying Duplicates

```python
# Check for duplicate rows based on all columns
df.duplicated()  # Returns a boolean Series

# Check for duplicates based on specific columns
df.duplicated(subset=['column1', 'column2'])

# Count number of duplicates
df.duplicated().sum()

# View duplicate rows
df[df.duplicated()]

# View rows that are duplicated (including first occurrence)
df[df.duplicated(keep=False)]
```

#### Removing Duplicates

```python
# Remove duplicate rows (keeps first occurrence by default)
df.drop_duplicates()

# Remove duplicates based on specific columns
df.drop_duplicates(subset=['column1', 'column2'])

# Keep last occurrence instead of first
df.drop_duplicates(keep='last')

# Discard all duplicates (including first occurrence)
df.drop_duplicates(keep=False)

# Modify the DataFrame in place
df.drop_duplicates(inplace=True)
```

**Example**:

```python
import pandas as pd

# Create a DataFrame with duplicates
data = {
    'Name': ['John', 'Anna', 'John', 'Peter', 'Anna'],
    'Age': [28, 34, 28, 29, 34],
    'City': ['New York', 'Paris', 'New York', 'Berlin', 'London']
}
df = pd.DataFrame(data)

# Identify duplicates based on Name and Age
duplicates = df.duplicated(subset=['Name', 'Age'], keep=False)

# Remove duplicates keeping only the first occurrence
df_unique = df.drop_duplicates(subset=['Name', 'Age'])

# Output
print("Original DataFrame:")
print(df)
print("\nDuplicate rows (based on Name and Age):")
print(df[duplicates])
print("\nDataFrame with duplicates removed:")
print(df_unique)
```

**Output**:

```
Original DataFrame:
    Name  Age      City
0   John   28  New York
1   Anna   34     Paris
2   John   28  New York
3  Peter   29    Berlin
4   Anna   34    London

Duplicate rows (based on Name and Age):
    Name  Age      City
0   John   28  New York
1   Anna   34     Paris
2   John   28  New York
4   Anna   34    London

DataFrame with duplicates removed:
    Name  Age      City
0   John   28  New York
1   Anna   34     Paris
3  Peter   29    Berlin
```

**Key Points**:

- Consider which columns define a duplicate (sometimes not all columns are relevant)
- Decide whether to keep first, last, or no occurrences depending on data quality
- Duplicate removal can significantly reduce dataset size and processing time
- Check for "near duplicates" that might need additional preprocessing

### Data Type Conversion

Proper data types ensure efficient memory usage, correct mathematical operations, and meaningful analysis. Pandas provides extensive functionality for type conversion.

#### Checking Data Types

```python
# Check data types of all columns
df.dtypes

# Get detailed information including data types
df.info()

# Memory usage statistics
df.memory_usage(deep=True)
```

#### Basic Type Conversion

```python
# Convert a column to a specific type
df['column'] = df['column'].astype('int64')
df['column'] = df['column'].astype('float64')
df['column'] = df['column'].astype('str')
df['column'] = df['column'].astype('category')
df['column'] = df['column'].astype('bool')

# Convert multiple columns at once
df = df.astype({'column1': 'int64', 'column2': 'float64'})

# Safe conversion that handles errors
df['column'] = pd.to_numeric(df['column'], errors='coerce')  # Invalid values become NaN
```

#### Date and Time Conversion

```python
# Convert to datetime
df['date_column'] = pd.to_datetime(df['date_column'])

# Specify format
df['date_column'] = pd.to_datetime(df['date_column'], format='%Y-%m-%d')

# Handle errors
df['date_column'] = pd.to_datetime(df['date_column'], errors='coerce')

# Extract date components
df['year'] = df['date_column'].dt.year
df['month'] = df['date_column'].dt.month
df['day'] = df['date_column'].dt.day
df['weekday'] = df['date_column'].dt.day_name()
```

#### Categorical Conversion

```python
# Convert string column to categorical type
df['category_column'] = df['category_column'].astype('category')

# Convert with ordered categories
df['rating'] = pd.Categorical(df['rating'], 
                             categories=['Poor', 'Average', 'Good', 'Excellent'],
                             ordered=True)

# Convert back from categorical to codes (integers)
df['category_codes'] = df['category_column'].cat.codes
```

**Example**:

```python
import pandas as pd

# Create a sample DataFrame with mixed types
data = {
    'ID': ['1', '2', '3', '4', '5'],
    'Value': ['10.5', '20.3', '30.1', 'Invalid', '50.7'],
    'Date': ['2023-01-15', '2023-02-28', '2023-03-10', '23/04/2023', '2023-05-20'],
    'Category': ['A', 'B', 'A', 'C', 'B']
}
df = pd.DataFrame(data)

# Convert types appropriately
# Convert ID to integer
df['ID'] = df['ID'].astype('int64')

# Convert Value to numeric, coercing errors to NaN
df['Value'] = pd.to_numeric(df['Value'], errors='coerce')

# Convert Date to datetime, handling different formats
df['Date'] = pd.to_datetime(df['Date'], errors='coerce')

# Convert Category to categorical
df['Category'] = df['Category'].astype('category')

# Output
print("Original data types:")
print(df.dtypes)
print("\nConverted DataFrame:")
print(df)
print("\nMemory usage per column:")
print(df.memory_usage(deep=True))
```

**Output**:

```
Original data types:
ID          object
Value       object
Date        object
Category    object
dtype: object

Converted DataFrame:
   ID  Value       Date Category
0   1   10.5 2023-01-15        A
1   2   20.3 2023-02-28        B
2   3   30.1 2023-03-10        A
3   4    NaN 2023-04-23        C
4   5   50.7 2023-05-20        B

Memory usage per column:
Index        128
ID           40
Value        40
Date         40
Category     40
dtype: int64
```

#### Memory Optimization

```python
# Downcast numeric columns to smallest possible type
df['int_column'] = pd.to_numeric(df['int_column'], downcast='integer')
df['float_column'] = pd.to_numeric(df['float_column'], downcast='float')

# Use sparse types for data with many repeated values
df['sparse_column'] = df['column'].astype('Sparse')

# Use category type for string columns with few unique values
if df['string_column'].nunique() / len(df['string_column']) < 0.5:
    df['string_column'] = df['string_column'].astype('category')
```

**Key Points**:

- Proper data types improve memory usage and computation speed
- Date/time objects enable time-based operations and analyses
- Categorical data is memory-efficient for columns with few unique values
- Data type conversion should be done early in the data preparation pipeline
- Handle conversion errors explicitly to avoid silent failures

### Advanced Data Cleaning Techniques

#### String Cleaning

```python
# Strip whitespace
df['text'] = df['text'].str.strip()

# Convert case
df['text'] = df['text'].str.lower()
df['text'] = df['text'].str.upper()
df['text'] = df['text'].str.title()

# Replace patterns
df['text'] = df['text'].str.replace('old', 'new')
df['text'] = df['text'].str.replace(r'[^\w\s]', '', regex=True)  # Remove punctuation
```

#### Outlier Detection and Handling

```python
# Z-score method
from scipy import stats
z_scores = stats.zscore(df['column'])
abs_z_scores = np.abs(z_scores)
filtered_entries = (abs_z_scores < 3)  # Keep entries with z-score less than 3
df = df[filtered_entries]

# IQR method
Q1 = df['column'].quantile(0.25)
Q3 = df['column'].quantile(0.75)
IQR = Q3 - Q1
df = df[~((df['column'] < (Q1 - 1.5 * IQR)) | (df['column'] > (Q3 + 1.5 * IQR)))]
```

#### Data Normalization and Standardization

```python
# Min-Max scaling
df['scaled'] = (df['column'] - df['column'].min()) / (df['column'].max() - df['column'].min())

# Z-score standardization
df['standardized'] = (df['column'] - df['column'].mean()) / df['column'].std()
```

**Conclusion**: Effective data cleaning is crucial for reliable analysis and modeling. Pandas offers a comprehensive suite of tools for handling missing values, removing duplicates, and converting data types. The choice of methods depends on the specific dataset characteristics and analysis requirements. Always document your cleaning steps to ensure reproducibility and maintain data provenance. Regular data quality checks throughout the analysis pipeline can help identify issues early and prevent downstream problems.

---

## Basic Transformations

### apply(), map(), applymap()

These functions are powerful tools for applying transformations to pandas DataFrames and Series.

#### map()

The `map()` function applies a transformation to each element of a Series. It can use a dictionary, a function, or a Series for mapping values.

```python
# Using a dictionary to map values
df['category'] = df['category'].map({'A': 'Group 1', 'B': 'Group 2', 'C': 'Group 3'})

# Using a function
df['value'] = df['value'].map(lambda x: x*2)

# Using another Series
mapping_series = pd.Series(['Group 1', 'Group 2', 'Group 3'], index=['A', 'B', 'C'])
df['category'] = df['category'].map(mapping_series)
```

**Key Points**:

- Works only on Series (single columns), not DataFrames
- Missing values in the mapping will result in NaN by default
- Can specify a value for unmapped elements with `.map(mapping, na_action=None)`
- Efficient for element-wise operations where each input has exactly one output

**Example**:

```python
import pandas as pd

# Create a sample dataframe
df = pd.DataFrame({
    'fruit': ['apple', 'banana', 'orange', 'grape', 'apple'],
    'count': [5, 3, 8, 2, 4]
})

# Create a mapping dictionary for fruit prices
fruit_prices = {'apple': 1.2, 'banana': 0.5, 'orange': 0.8, 'grape': 2.1}

# Apply the mapping
df['price'] = df['fruit'].map(fruit_prices)
df['total_value'] = df['count'] * df['price']

print(df)
```

**Output**:

```
    fruit  count  price  total_value
0   apple      5    1.2         6.0
1  banana      3    0.5         1.5
2  orange      8    0.8         6.4
3   grape      2    2.1         4.2
4   apple      4    1.2         4.8
```

#### apply()

The `apply()` function operates on either rows or columns of a DataFrame, or on elements of a Series. It applies a function along a specified axis.

```python
# Apply to columns (axis=0)
df.apply(np.sum, axis=0)  # Sum of each column

# Apply to rows (axis=1)
df.apply(lambda row: row.max() - row.min(), axis=1)  # Range of each row

# Apply to a Series
df['column'].apply(lambda x: x.upper() if isinstance(x, str) else x)

# Apply with additional arguments
df.apply(custom_function, axis=1, args=(arg1, arg2))
```

**Key Points**:

- More flexible than `map()` as it can handle complex operations
- Can return scalars, Series, or DataFrames from the applied function
- Slower than vectorized operations or `map()` for simple transformations
- Allows passing additional arguments to the applied function

**Example**:

```python
import pandas as pd
import numpy as np

# Create a sample dataframe
df = pd.DataFrame({
    'A': [1, 2, 3, 4, 5],
    'B': [10, 20, 30, 40, 50],
    'C': [100, 200, 300, 400, 500]
})

# Calculate row sums using apply
df['row_sum'] = df.apply(np.sum, axis=1)

# Create a custom function for column operations
def normalize(column):
    return (column - column.min()) / (column.max() - column.min())

# Apply the normalization to each column
df_normalized = df[['A', 'B', 'C']].apply(normalize)

print("Original DataFrame with row sums:")
print(df)
print("\nNormalized DataFrame:")
print(df_normalized)
```

**Output**:

```
Original DataFrame with row sums:
   A   B    C  row_sum
0  1  10  100      111
1  2  20  200      222
2  3  30  300      333
3  4  40  400      444
4  5  50  500      555

Normalized DataFrame:
     A    B    C
0  0.0  0.0  0.0
1  0.25 0.25 0.25
2  0.5  0.5  0.5
3  0.75 0.75 0.75
4  1.0  1.0  1.0
```

#### applymap()

The `applymap()` function applies a function to every individual element in a DataFrame. It's similar to `map()` but works on the entire DataFrame.

```python
# Apply function to every element
df = df.applymap(lambda x: round(x, 2) if isinstance(x, (int, float)) else x)

# Replace specific values
df = df.applymap(lambda x: 'N/A' if pd.isna(x) else x)
```

**Key Points**:

- Works on entire DataFrames, applying the function to each element
- Useful for element-wise operations that need to be applied to all values
- Generally slower than vectorized operations
- Returns a DataFrame with the same shape as the original

**Example**:

```python
import pandas as pd
import numpy as np

# Create a sample dataframe with different data types
df = pd.DataFrame({
    'A': [1.234, 2.567, 3.891, 4.123, 5.456],
    'B': [10.11, 20.22, np.nan, 40.44, 50.55],
    'C': ['abc', 'def', 'ghi', None, 'mno']
})

# Define a function to format our data
def format_element(x):
    if isinstance(x, float) and not pd.isna(x):
        return round(x, 1)
    elif pd.isna(x):
        return 'Missing'
    else:
        return x

# Apply the function to every element
formatted_df = df.applymap(format_element)

print("Original DataFrame:")
print(df)
print("\nFormatted DataFrame:")
print(formatted_df)
```

**Output**:

```
Original DataFrame:
       A      B     C
0  1.234  10.11   abc
1  2.567  20.22   def
2  3.891    NaN   ghi
3  4.123  40.44  None
4  5.456  50.55   mno

Formatted DataFrame:
      A        B        C
0   1.2     10.1      abc
1   2.6     20.2      def
2   3.9  Missing      ghi
3   4.1     40.4  Missing
4   5.5     50.6      mno
```

### Adding/removing columns and rows

Pandas provides various methods to add or remove columns and rows from DataFrames.

#### Adding Columns

```python
# Add a new column with a scalar value
df['new_column'] = 10

# Add a column with a list or array (must be same length as DataFrame)
df['new_column'] = [1, 2, 3, 4, 5]

# Add a column based on existing columns
df['sum'] = df['A'] + df['B']

# Add multiple columns at once using assign()
df = df.assign(col1=10, col2=lambda x: x['A'] * 2)

# Insert a column at a specific position
df.insert(1, 'inserted', values)  # Insert at position 1
```

#### Removing Columns

```python
# Drop a single column
df = df.drop('column', axis=1)

# Drop multiple columns
df = df.drop(['column1', 'column2'], axis=1)

# Drop columns in-place
df.drop('column', axis=1, inplace=True)

# Drop columns by position
df = df.drop(df.columns[1], axis=1)  # Drop second column
```

#### Adding Rows

```python
# Append a single row as a dictionary
new_row = {'A': 6, 'B': 60, 'C': 600}
df = df._append(new_row, ignore_index=True)

# Append multiple rows from another DataFrame
df = df._append(other_df, ignore_index=True)

# Add rows at specific positions using loc with a new index
df.loc[len(df)] = [6, 60, 600]  # Add to end
df.loc[2.5] = [3.5, 35, 350]    # Add between indices 2 and 3 (if using numeric index)

# concat method for more control
df = pd.concat([df, new_rows], ignore_index=True)
```

#### Removing Rows

```python
# Drop rows by index
df = df.drop([0, 2])  # Drop rows with index 0 and 2

# Drop rows by condition
df = df[df['A'] > 2]  # Keep only rows where A > 2
df = df.drop(df[df['A'] < 2].index)  # Drop rows where A < 2

# Drop rows with missing values
df = df.dropna()

# Reset index after dropping rows
df = df.reset_index(drop=True)
```

**Example**:

```python
import pandas as pd

# Create a sample dataframe
df = pd.DataFrame({
    'A': [1, 2, 3, 4],
    'B': [10, 20, 30, 40]
})

# Add a new column
df['C'] = df['A'] * df['B']

# Add a row
df.loc[len(df)] = [5, 50, 250]

# Drop a row where A is 2
df = df[df['A'] != 2]

# Drop column B
df = df.drop('B', axis=1)

# Reset index
df = df.reset_index(drop=True)

print(df)
```

**Output**:

```
   A    C
0  1   10
1  3   90
2  4  160
3  5  250
```

**Key Points**:

- When adding rows, make sure the new data has the same columns as the DataFrame
- `_append()` method is often more efficient than repeatedly using `.loc[len(df)]`
- `concat()` is more flexible than `_append()` for complex joining operations
- Always reset index after dropping rows if you want continuous indices
- Use `inplace=True` to modify the DataFrame without reassignment

### String Manipulation Methods

Pandas provides powerful string manipulation capabilities through the `.str` accessor on Series objects.

#### Basic String Operations

```python
# Convert case
df['text'] = df['text'].str.lower()
df['text'] = df['text'].str.upper()
df['text'] = df['text'].str.title()
df['text'] = df['text'].str.capitalize()

# Remove whitespace
df['text'] = df['text'].str.strip()
df['text'] = df['text'].str.lstrip()  # Left strip
df['text'] = df['text'].str.rstrip()  # Right strip

# Check string patterns
contains_pattern = df['text'].str.contains('pattern')
starts_with = df['text'].str.startswith('prefix')
ends_with = df['text'].str.endswith('suffix')

# Accessing parts of strings
df['first_char'] = df['text'].str[0]
df['first_three'] = df['text'].str[:3]
```

#### String Extraction and Replacement

```python
# Replace text
df['text'] = df['text'].str.replace('old', 'new')

# Replace using regex
df['text'] = df['text'].str.replace(r'\d+', 'NUM', regex=True)

# Extract text matching a pattern
df['extracted'] = df['text'].str.extract(r'(\d+)')  # Extract first number

# Extract all matches
df['all_numbers'] = df['text'].str.findall(r'\d+')

# Split strings
df['split'] = df['text'].str.split(',')

# Access elements after splitting
df['first_part'] = df['text'].str.split(',').str[0]
```

#### Advanced String Operations

```python
# Pad strings
df['padded'] = df['text'].str.pad(10, side='left', fillchar='0')

# Count occurrences of a pattern
df['count'] = df['text'].str.count('pattern')

# Replace by position
df['replaced'] = df['text'].str.slice_replace(start=1, stop=4, repl='XXX')

# Join list elements
df['joined'] = df['list_column'].str.join(', ')

# Get string length
df['length'] = df['text'].str.len()
```

**Example**:

```python
import pandas as pd

# Create a sample dataframe with text data
df = pd.DataFrame({
    'product_id': ['AB-123-XYZ', 'CD-456-XYZ', 'EF-789-XYZ', 'GH-101-XYZ', 'IJ-202-XYZ'],
    'description': ['Premium product (red)', 'Standard item [blue]', 'Economy version {green}', 'Deluxe model #silver#', 'Basic type /yellow/'],
    'tags': ['new,featured,sale', 'used,clearance', 'new,budget', 'premium,limited', 'standard']
})

# Extract product code (3 digits)
df['product_code'] = df['product_id'].str.extract(r'-(\d+)-')

# Convert description to lowercase and remove special characters
df['clean_desc'] = df['description'].str.lower().str.replace(r'[\(\)\[\]\{\}\#\/]', '', regex=True)

# Split tags into lists
df['tag_list'] = df['tags'].str.split(',')

# Count number of tags
df['tag_count'] = df['tags'].str.count(',') + 1

# Get first tag
df['primary_tag'] = df['tags'].str.split(',').str[0]

print(df)
```

**Output**:

```
    product_id           description               tags product_code     clean_desc             tag_list  tag_count primary_tag
0  AB-123-XYZ    Premium product (red)  new,featured,sale          123    premium product red  [new, featured, sale]          3         new
1  CD-456-XYZ    Standard item [blue]     used,clearance          456    standard item blue       [used, clearance]          2        used
2  EF-789-XYZ  Economy version {green}        new,budget          789  economy version green         [new, budget]          2         new
3  GH-101-XYZ   Deluxe model #silver#    premium,limited          101   deluxe model silver     [premium, limited]          2     premium
4  IJ-202-XYZ   Basic type /yellow/           standard          202   basic type yellow            [standard]          1    standard
```

**Key Points**:

- String methods apply only to string values; use `.astype(str)` first if needed
- Most string methods support regex patterns with `regex=True`
- String operations on missing values (NaN) result in NaN
- String methods are vectorized but still slower than native NumPy operations
- For complex text analysis, consider specialized libraries like NLTK or spaCy

### Combining Transformations

Often, multiple transformation techniques are needed together to achieve the desired data preparation:

```python
# Chain multiple operations
df['clean_column'] = (df['text']
                      .str.lower()
                      .str.replace(r'[^\w\s]', '', regex=True)
                      .str.strip())

# Combine apply and string operations
df['processed'] = df['text'].apply(lambda x: x.upper() if x.startswith('A') else x.lower())

# Use map for categorical and apply for calculations
df['category_code'] = df['category'].map({'Low': 1, 'Medium': 2, 'High': 3})
df['weighted_score'] = df.apply(lambda row: row['score'] * row['category_code'], axis=1)
```

**Conclusion**: These basic transformation methods in pandas form the foundation for data manipulation workflows. The `map()`, `apply()`, and `applymap()` functions provide flexible ways to transform data at different levels of granularity. Adding and removing columns and rows allows restructuring datasets to fit analytical needs. String manipulation methods enable powerful text processing capabilities directly within pandas. Mastering these transformations is essential for efficient data preparation and analysis.

---

## Reshaping Data

### melt and pivot

These functions transform data between "wide" and "long" formats, essential for different types of analysis.

#### melt

The `melt()` function converts wide-format data to long format, unpivoting a DataFrame from wide to long format.

```python
# Basic melt
pd.melt(df)

# Specifying identifier variables
pd.melt(df, id_vars=['id', 'name'])

# Specifying columns to unpivot
pd.melt(df, id_vars=['id'], value_vars=['col1', 'col2'])

# Naming the resulting variable and value columns
pd.melt(df, id_vars=['id'], var_name='measurement', value_name='result')

# Using as DataFrame method
df.melt(id_vars=['id'], var_name='measurement', value_name='result')
```

**Example**:

```python
import pandas as pd

# Create a wide-format DataFrame (each subject has multiple measurements in separate columns)
wide_df = pd.DataFrame({
    'subject_id': [1, 2, 3, 4],
    'name': ['John', 'Jane', 'Tom', 'Lisa'],
    'math_score': [85, 92, 78, 96],
    'science_score': [92, 88, 85, 91],
    'english_score': [75, 95, 80, 85]
})

# Melt to long format (each row is one subject-test combination)
long_df = wide_df.melt(
    id_vars=['subject_id', 'name'],
    value_vars=['math_score', 'science_score', 'english_score'],
    var_name='test',
    value_name='score'
)

print("Original wide-format DataFrame:")
print(wide_df)
print("\nMelted long-format DataFrame:")
print(long_df)
```

**Output**:

```
Original wide-format DataFrame:
   subject_id  name  math_score  science_score  english_score
0           1  John          85             92             75
1           2  Jane          92             88             95
2           3   Tom          78             85             80
3           4  Lisa          96             91             85

Melted long-format DataFrame:
    subject_id  name           test  score
0            1  John    math_score     85
1            2  Jane    math_score     92
2            3   Tom    math_score     78
3            4  Lisa    math_score     96
4            1  John  science_score     92
5            2  Jane  science_score     88
6            3   Tom  science_score     85
7            4  Lisa  science_score     91
8            1  John  english_score     75
9            2  Jane  english_score     95
10           3   Tom  english_score     80
11           4  Lisa  english_score     85
```

#### pivot

The `pivot()` function reshapes long-format data to wide format, using unique values from one column as the new column names.

```python
# Basic pivot
df.pivot(index='id', columns='variable', values='value')

# Multiple value columns
df.pivot(index='id', columns='variable')

# Reset index after pivoting
pivoted = df.pivot(index='id', columns='variable', values='value').reset_index()
```

**Example**:

```python
import pandas as pd

# Create a long-format DataFrame (each row is one observation)
long_df = pd.DataFrame({
    'country': ['USA', 'USA', 'USA', 'Germany', 'Germany', 'Germany', 'Japan', 'Japan', 'Japan'],
    'year': [2020, 2021, 2022, 2020, 2021, 2022, 2020, 2021, 2022],
    'gdp': [20.9, 22.4, 23.0, 3.8, 4.2, 4.1, 5.0, 5.2, 5.3]
})

# Pivot to wide format (each row is one country, columns are years)
wide_df = long_df.pivot(index='country', columns='year', values='gdp')

# Reset index to make country a regular column
wide_df = wide_df.reset_index()

print("Original long-format DataFrame:")
print(long_df)
print("\nPivoted wide-format DataFrame:")
print(wide_df)
```

**Output**:

```
Original long-format DataFrame:
   country  year   gdp
0      USA  2020  20.9
1      USA  2021  22.4
2      USA  2022  23.0
3  Germany  2020   3.8
4  Germany  2021   4.2
5  Germany  2022   4.1
6    Japan  2020   5.0
7    Japan  2021   5.2
8    Japan  2022   5.3

Pivoted wide-format DataFrame:
   country  2020  2021  2022
0  Germany   3.8   4.2   4.1
1    Japan   5.0   5.2   5.3
2      USA  20.9  22.4  23.0
```

#### pivot_table

`pivot_table()` is a more flexible version of `pivot()` that can handle duplicate values by applying aggregation functions.

```python
# Basic pivot table with aggregation
df.pivot_table(index='id', columns='variable', values='value', aggfunc='mean')

# Multiple aggregation functions
df.pivot_table(index='id', columns='variable', values='value', aggfunc=['mean', 'sum', 'count'])

# Multiple index levels
df.pivot_table(index=['region', 'country'], columns='year', values='value')

# Fill missing values
df.pivot_table(index='id', columns='variable', values='value', fill_value=0)

# Include row and column totals
df.pivot_table(index='id', columns='variable', values='value', margins=True)
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create a DataFrame with duplicate combinations (multiple sales per store per day)
sales_df = pd.DataFrame({
    'date': pd.date_range('2023-01-01', periods=20, freq='D').repeat(3),
    'store': np.tile(['A', 'B', 'C'], 20),
    'product': np.random.choice(['Widget', 'Gadget', 'Tool'], 60),
    'sales': np.random.randint(5, 50, 60),
    'units': np.random.randint(1, 10, 60)
})

# Create pivot table summing sales by store and date
sales_pivot = sales_df.pivot_table(
    index='date', 
    columns='store', 
    values='sales',
    aggfunc='sum'
)

# Multi-level pivot table 
detailed_pivot = sales_df.pivot_table(
    index=['date', 'product'], 
    columns='store', 
    values=['sales', 'units'],
    aggfunc={'sales': 'sum', 'units': 'mean'},
    fill_value=0
)

print("Sample of raw sales data:")
print(sales_df.head(6))
print("\nPivot table of total sales by date and store:")
print(sales_pivot.head())
print("\nSample of multi-level pivot table:")
print(detailed_pivot.head(3))
```

**Output**:

```
Sample of raw sales data:
        date store product  sales  units
0 2023-01-01     A  Widget     12      4
1 2023-01-01     B  Gadget     31      7
2 2023-01-01     C    Tool     18      2
3 2023-01-02     A    Tool     42      3
4 2023-01-02     B  Widget     25      5
5 2023-01-02     C  Gadget     10      8

Pivot table of total sales by date and store:
            store         
              A     B     C
date                       
2023-01-01  12.0  31.0  18.0
2023-01-02  42.0  25.0  10.0
2023-01-03  21.0  19.0  36.0
2023-01-04  15.0  27.0  22.0
2023-01-05  33.0  14.0  29.0

Sample of multi-level pivot table:
                     sales              units          
store                    A     B     C      A    B    C
date       product                                     
2023-01-01 Gadget         0    31     0    0.0  7.0  0.0
           Tool           0     0    18    0.0  0.0  2.0
           Widget        12     0     0    4.0  0.0  0.0
```

**Key Points**:

- `melt()` is useful for converting data from wide to long format for analysis tools that require long format
- `pivot()` works only with data that has unique index-column combinations
- Use `pivot_table()` when you have duplicate values that need to be aggregated
- Missing values are filled with NaN by default but can be customized

### stack and unstack

These methods reshape data by pivoting a level of the index to columns or vice versa.

#### stack

`stack()` pivots the innermost column level to become the innermost row index level.

```python
# Basic stacking (column labels become row labels)
stacked = df.stack()

# Stack specific levels
stacked = df.stack(level=1)

# Handling missing values
stacked = df.stack(dropna=False)
```

#### unstack

`unstack()` pivots the innermost row index level to become the innermost column level.

```python
# Basic unstacking (row labels become column labels)
unstacked = df.unstack()

# Unstack specific levels
unstacked = df.unstack(level=0)

# Fill missing values when unstacking
unstacked = df.unstack(fill_value=0)
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create a multi-index DataFrame
index = pd.MultiIndex.from_tuples([
    ('A', 2021), ('A', 2022), ('A', 2023),
    ('B', 2021), ('B', 2022), ('B', 2023)
], names=['region', 'year'])

df = pd.DataFrame({
    'Q1': [100, 110, 120, 200, 210, 220],
    'Q2': [105, 115, 125, 205, 215, 225],
    'Q3': [110, 120, 130, 210, 220, 230],
    'Q4': [115, 125, 135, 215, 225, 235]
}, index=index)

# Stack quarters to move them from columns to index
stacked = df.stack()

# Unstack years to move them from index to columns
unstacked = stacked.unstack(level='year')

print("Original DataFrame:")
print(df)
print("\nStacked DataFrame (quarters moved to index):")
print(stacked.head(8))
print("\nUnstacked DataFrame (years moved to columns):")
print(unstacked.head())
```

**Output**:

```
Original DataFrame:
              Q1   Q2   Q3   Q4
region year                    
A      2021  100  105  110  115
       2022  110  115  120  125
       2023  120  125  130  135
B      2021  200  205  210  215
       2022  210  215  220  225
       2023  220  225  230  235

Stacked DataFrame (quarters moved to index):
region  year               
A       2021  Q1    100
              Q2    105
              Q3    110
              Q4    115
        2022  Q1    110
              Q2    115
              Q3    120
              Q4    125
dtype: int64

Unstacked DataFrame (years moved to columns):
              2021  2022  2023
region                        
A       Q1    100   110   120
        Q2    105   115   125
        Q3    110   120   130
        Q4    115   125   135
```

**Key Points**:

- `stack()` and `unstack()` are particularly useful for working with hierarchical indices
- They provide a way to reshape data without explicitly calling pivot functions
- These methods preserve the hierarchical structure of the data
- By default, they drop missing values but can be configured to keep them

### Transposing Data

Transposing swaps rows and columns, changing the orientation of a DataFrame.

```python
# Basic transpose
df_transposed = df.T

# Transpose and reset index
df_transposed = df.T.reset_index()

# Transpose specific portions
df_transposed = df[['col1', 'col2', 'col3']].T
```

**Example**:

```python
import pandas as pd

# Create a sample DataFrame
df = pd.DataFrame({
    'product': ['A', 'B', 'C'],
    'price': [10, 15, 20],
    'stock': [100, 150, 200],
    'rating': [4.5, 4.0, 4.8]
})

# Set product as index before transposing
df_indexed = df.set_index('product')

# Transpose the DataFrame
df_transposed = df_indexed.T

print("Original DataFrame:")
print(df)
print("\nDataFrame with product as index:")
print(df_indexed)
print("\nTransposed DataFrame:")
print(df_transposed)
```

**Output**:

```
Original DataFrame:
  product  price  stock  rating
0       A     10    100     4.5
1       B     15    150     4.0
2       C     20    200     4.8

DataFrame with product as index:
        price  stock  rating
product                     
A          10    100     4.5
B          15    150     4.0
C          20    200     4.8

Transposed DataFrame:
product      A      B      C
price     10.0   15.0   20.0
stock    100.0  150.0  200.0
rating     4.5    4.0    4.8
```

**Key Points**:

- Transposing is useful when you need to operate on rows as if they were columns
- Often used in data analysis when comparing across categories
- Column datatypes may change after transposing
- Indices become columns and columns become indices

### Advanced Reshaping Techniques

#### Cross Tabulation

The `crosstab()` function computes a frequency table of factors.

```python
# Basic cross tabulation
pd.crosstab(df['A'], df['B'])

# Adding marginal sums (row and column totals)
pd.crosstab(df['A'], df['B'], margins=True)

# Normalize by rows or columns
pd.crosstab(df['A'], df['B'], normalize='index')  # Row percentages
pd.crosstab(df['A'], df['B'], normalize='columns')  # Column percentages

# Adding values from another column
pd.crosstab(df['A'], df['B'], values=df['C'], aggfunc='sum')
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample data
data = {
    'gender': np.random.choice(['Male', 'Female'], 100),
    'age_group': np.random.choice(['<25', '25-40', '40+'], 100),
    'product': np.random.choice(['A', 'B', 'C', 'D'], 100),
    'amount': np.random.randint(10, 100, 100)
}
df = pd.DataFrame(data)

# Create a basic cross tabulation of gender and product
basic_cross = pd.crosstab(df['gender'], df['product'])

# Cross tabulation with amount as values
value_cross = pd.crosstab(
    df['gender'], 
    df['product'],
    values=df['amount'],
    aggfunc='sum'
)

# Normalized cross tabulation (row percentages)
normalized_cross = pd.crosstab(
    df['gender'], 
    df['product'],
    normalize='index'
)

print("Basic cross tabulation (counts):")
print(basic_cross)
print("\nCross tabulation with amount values:")
print(value_cross)
print("\nNormalized cross tabulation (row percentages):")
print(normalized_cross)
```

**Output**:

```
Basic cross tabulation (counts):
product   A   B   C   D
gender               
Female   14  13  10  10
Male     13  15  16   9

Cross tabulation with amount values:
product     A     B     C     D
gender                         
Female   727.0 694.0 454.0 421.0
Male     680.0 780.0 834.0 435.0

Normalized cross tabulation (row percentages):
product         A         B         C         D
gender                                         
Female   0.297872  0.276596  0.212766  0.212766
Male     0.245283  0.283019  0.301887  0.169811
```

#### explode

The `explode()` function transforms each element of a list-like to a row.

```python
# Explode a column with list-like elements
df_exploded = df.explode('list_column')
```

**Example**:

```python
import pandas as pd

# Create sample data with list elements
df = pd.DataFrame({
    'id': [1, 2, 3],
    'name': ['John', 'Lisa', 'Mark'],
    'tags': [['tall', 'adult', 'male'], ['short', 'adult', 'female'], ['tall', 'teen', 'male']]
})

# Explode the tags column
exploded_df = df.explode('tags')

print("Original DataFrame with list elements:")
print(df)
print("\nExploded DataFrame:")
print(exploded_df)
```

**Output**:

```
Original DataFrame with list elements:
   id  name                    tags
0   1  John      [tall, adult, male]
1   2  Lisa    [short, adult, female]
2   3  Mark       [tall, teen, male]

Exploded DataFrame:
   id  name    tags
0   1  John    tall
0   1  John   adult
0   1  John    male
1   2  Lisa   short
1   2  Lisa   adult
1   2  Lisa  female
2   3  Mark    tall
2   3  Mark    teen
2   3  Mark    male
```

#### wide_to_long

A specialized function for reshaping wide-format data with stub column names.

```python
# Wide to long format
pd.wide_to_long(df, 
                stubnames=['prefix'], 
                i=['id_col'], 
                j='variable_name', 
                sep='_', 
                suffix=r'\w+')
```

**Example**:

```python
import pandas as pd

# Create wide format data with stub column names
data = {
    'id': [1, 2, 3],
    'name': ['John', 'Jane', 'Mark'],
    'score_math': [85, 92, 78],
    'score_science': [92, 88, 85],
    'score_english': [75, 95, 80],
    'grade_math': 'B A C'.split(),
    'grade_science': 'A B B'.split(),
    'grade_english': 'C A B'.split()
}
wide_df = pd.DataFrame(data)

# Transform to long format
long_df = pd.wide_to_long(
    wide_df,
    stubnames=['score', 'grade'],
    i=['id', 'name'],
    j='subject',
    sep='_',
    suffix=r'\w+'
)

print("Original wide DataFrame:")
print(wide_df)
print("\nReshaped long DataFrame:")
print(long_df)
```

**Output**:

```
Original wide DataFrame:
   id  name  score_math  score_science  score_english grade_math grade_science grade_english
0   1  John          85             92             75          B             A             C
1   2  Jane          92             88             95          A             B             A
2   3  Mark          78             85             80          C             B             B

Reshaped long DataFrame:
                 score grade
id name subject             
1  John math        85     B
       science      92     A
       english      75     C
2  Jane math        92     A
       science      88     B
       english      95     A
3  Mark math        78     C
       science      85     B
       english      80     B
```

**Conclusion**: Reshaping data is a fundamental skill in data analysis that allows analysts to transform data between different structures to suit specific analytical needs. `melt()` and `pivot()` functions convert between wide and long formats, while `stack()` and `unstack()` work with multi-level indices to restructure data. Transposing swaps rows and columns for a completely different perspective. Advanced reshaping techniques like cross tabulation, exploding list elements, and specialized wide-to-long transformations provide additional tools for handling complex data structures. Mastering these reshaping techniques is essential for effective data preparation and analysis in pandas.

---

# Data Analysis Techniques

## Aggregation Methods

### groupby() operations

The `groupby()` function is a fundamental tool for data aggregation in pandas, allowing you to split data into groups and apply operations on each group independently.

#### Basic groupby syntax

```python
# Group by a single column
grouped = df.groupby('column')

# Group by multiple columns
grouped = df.groupby(['column1', 'column2'])

# Access a specific column after grouping
grouped_column = df.groupby('group_column')['value_column']

# Chain aggregation operations
result = df.groupby('group_column')['value_column'].mean()
```

#### Common aggregation methods

```python
# Calculate mean of each group
df.groupby('group_column').mean()

# Calculate sum of each group
df.groupby('group_column').sum()

# Calculate count of each group
df.groupby('group_column').count()

# Calculate multiple aggregations
df.groupby('group_column').agg(['count', 'sum', 'mean', 'min', 'max'])

# Apply specific aggregations to specific columns
df.groupby('group_column').agg({
    'numeric_column1': 'sum',
    'numeric_column2': ['min', 'max', 'mean'],
    'string_column': 'count'
})
```

#### Iterating through groups

```python
# Iterate through groups
for name, group in df.groupby('group_column'):
    print(f"Group: {name}")
    print(group)
    
# Get a specific group
group_data = df.groupby('group_column').get_group('group_name')
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample sales data
data = {
    'date': pd.date_range('2023-01-01', periods=20),
    'store': np.random.choice(['Store A', 'Store B', 'Store C'], 20),
    'product': np.random.choice(['Widget', 'Gadget', 'Tool'], 20),
    'sales': np.random.randint(100, 1000, 20),
    'units': np.random.randint(10, 100, 20)
}
sales_df = pd.DataFrame(data)

# Group by store and calculate total sales
store_sales = sales_df.groupby('store')['sales'].sum().reset_index()

# Group by store and product, calculate multiple aggregations
product_analysis = sales_df.groupby(['store', 'product']).agg({
    'sales': ['sum', 'mean'],
    'units': ['sum', 'mean']
}).reset_index()

print("Sample sales data:")
print(sales_df.head())
print("\nTotal sales by store:")
print(store_sales)
print("\nProduct analysis by store:")
print(product_analysis)
```

**Output**:

```
Sample sales data:
        date    store product  sales  units
0 2023-01-01  Store A  Widget    345     25
1 2023-01-02  Store C  Gadget    512     37
2 2023-01-03  Store B  Widget    731     65
3 2023-01-04  Store A    Tool    893     48
4 2023-01-05  Store C    Tool    267     19

Total sales by store:
     store  sales
0  Store A   3481
1  Store B   2653
2  Store C   2704

Product analysis by store:
       store product sales       units      
                      sum   mean   sum  mean
0   Store A  Gadget  1023  341.0    92  30.7
1   Store A    Tool   893  893.0    48  48.0
2   Store A  Widget  1565  521.7   107  35.7
3   Store B  Gadget   687  687.0    56  56.0
4   Store B    Tool   735  367.5    73  36.5
5   Store B  Widget  1231  615.5   120  60.0
6   Store C  Gadget   789  394.5    67  33.5
7   Store C    Tool  1126  563.0    87  43.5
8   Store C  Widget   789  789.0    38  38.0
```

#### Groupby with time series data

```python
# Group by date parts
df.groupby(df['date'].dt.year).sum()
df.groupby(df['date'].dt.month).mean()
df.groupby([df['date'].dt.year, df['date'].dt.month]).sum()

# Group by time periods
df.groupby(pd.Grouper(key='date', freq='M')).sum()  # Monthly
df.groupby(pd.Grouper(key='date', freq='Q')).sum()  # Quarterly
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample time series data
dates = pd.date_range('2023-01-01', '2023-12-31', freq='D')
data = {
    'date': dates,
    'sales': np.random.randint(100, 1000, len(dates)),
    'expenses': np.random.randint(50, 500, len(dates))
}
financial_df = pd.DataFrame(data)

# Monthly aggregation
monthly_data = financial_df.groupby(pd.Grouper(key='date', freq='M')).sum().reset_index()

# Quarterly aggregation
quarterly_data = financial_df.groupby(pd.Grouper(key='date', freq='Q')).agg({
    'sales': 'sum',
    'expenses': 'sum'
}).reset_index()

# Calculate profit
quarterly_data['profit'] = quarterly_data['sales'] - quarterly_data['expenses']

print("Monthly aggregation:")
print(monthly_data.head(3))
print("\nQuarterly aggregation with profit:")
print(quarterly_data)
```

**Output**:

```
Monthly aggregation:
        date  sales  expenses
0 2023-01-31  16730     8402
1 2023-02-28  14837     7326
2 2023-03-31  16294     7953

Quarterly aggregation with profit:
        date  sales  expenses  profit
0 2023-03-31  47861    23681   24180
1 2023-06-30  45576    22867   22709
2 2023-09-30  48133    23451   24682
3 2023-12-31  47315    23914   23401
```

**Key Points**:

- `groupby()` creates a special GroupBy object that does not contain actual data until an aggregation function is applied
- Multiple aggregation functions can be applied to different columns
- `as_index=False` parameter can be used to return a DataFrame with the groupby columns as data columns instead of an index
- After grouping, you can access specific groups using `.get_group()`

### agg() and transform()

The `agg()` and `transform()` methods provide advanced aggregation capabilities beyond basic functions.

#### agg() method

The `agg()` method allows you to apply multiple functions to different columns in a GroupBy object.

```python
# Apply different functions to different columns
df.groupby('group_column').agg({
    'column1': 'sum',
    'column2': 'mean',
    'column3': ['min', 'max']
})

# Apply custom functions
df.groupby('group_column').agg({
    'column1': lambda x: x.max() - x.min(),
    'column2': lambda x: (x > x.mean()).sum()
})

# Named aggregations
df.groupby('group_column').agg(
    total=('column1', 'sum'),
    average=('column2', 'mean'),
    range_=('column3', lambda x: x.max() - x.min())
)
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample employee data
data = {
    'department': ['Sales', 'Sales', 'Sales', 'Marketing', 'Marketing', 
                   'IT', 'IT', 'IT', 'IT', 'HR'],
    'employee': ['Alice', 'Bob', 'Charlie', 'Diana', 'Edward', 
                'Frank', 'Grace', 'Hannah', 'Ian', 'Jane'],
    'salary': [72000, 65000, 70000, 80000, 85000, 
               92000, 90000, 88000, 95000, 60000],
    'years_experience': [3, 2, 5, 7, 9, 6, 5, 3, 8, 4],
    'performance': [4.2, 3.8, 4.5, 4.7, 4.0, 4.8, 4.3, 3.9, 4.6, 4.1]
}
employees = pd.DataFrame(data)

# Traditional agg with dictionary
dept_stats1 = employees.groupby('department').agg({
    'salary': ['mean', 'median', 'std'],
    'years_experience': ['mean', 'max'],
    'performance': ['mean', 'min']
})

# Named aggregations
dept_stats2 = employees.groupby('department').agg(
    avg_salary=('salary', 'mean'),
    salary_range=('salary', lambda x: x.max() - x.min()),
    avg_experience=('years_experience', 'mean'),
    avg_performance=('performance', 'mean')
)

print("Employee data sample:")
print(employees.head())
print("\nDepartment statistics (traditional):")
print(dept_stats1)
print("\nDepartment statistics (named):")
print(dept_stats2)
```

**Output**:

```
Employee data sample:
   department employee  salary  years_experience  performance
0       Sales    Alice   72000                 3          4.2
1       Sales      Bob   65000                 2          3.8
2       Sales  Charlie   70000                 5          4.5
3   Marketing    Diana   80000                 7          4.7
4   Marketing   Edward   85000                 9          4.0

Department statistics (traditional):
           salary             years_experience performance      
            mean median       std        mean max       mean min
department                                                      
HR         60000  60000        NaN        4.0   4        4.1 4.1
IT         91250  91000  2986.079        5.5   8        4.4 3.9
Marketing  82500  82500  3535.534        8.0   9        4.35 4.0
Sales      69000  70000  3605.551        3.3   5        4.17 3.8

Department statistics (named):
            avg_salary  salary_range  avg_experience  avg_performance
department                                                           
HR              60000             0            4.00             4.10
IT              91250          7000            5.50             4.40
Marketing       82500          5000            8.00             4.35
Sales           69000          7000            3.33             4.17
```

#### transform() method

The `transform()` method returns a DataFrame with the same shape as the input, where each value is transformed according to the group it belongs to.

```python
# Apply a function that returns a scalar to each group, then broadcast the result
df['mean_by_group'] = df.groupby('group_column')['value_column'].transform('mean')

# Calculate the difference from the group mean
df['diff_from_mean'] = df['value_column'] - df.groupby('group_column')['value_column'].transform('mean')

# Calculate percentage of group total
df['pct_of_group'] = df['value_column'] / df.groupby('group_column')['value_column'].transform('sum') * 100

# Multiple transformations
df[['mean', 'median', 'std']] = df.groupby('group_column')['value_column'].transform(['mean', 'median', 'std'])
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample test score data
data = {
    'student': ['Alice', 'Bob', 'Charlie', 'Diana', 'Edward', 
                'Frank', 'Grace', 'Hannah', 'Ian', 'Jane',
                'Alice', 'Bob', 'Charlie', 'Diana', 'Edward'],
    'subject': ['Math', 'Math', 'Math', 'Math', 'Math',
                'Science', 'Science', 'Science', 'Science', 'Science',
                'English', 'English', 'English', 'English', 'English'],
    'score': [85, 70, 90, 75, 80, 92, 78, 88, 95, 82, 78, 85, 92, 76, 88]
}
scores_df = pd.DataFrame(data)

# Calculate subject mean, student mean, and differences
scores_df['subject_mean'] = scores_df.groupby('subject')['score'].transform('mean')
scores_df['student_mean'] = scores_df.groupby('student')['score'].transform('mean')

# Calculate percentile within subject
scores_df['subject_percentile'] = scores_df.groupby('subject')['score'].transform(
    lambda x: 100 * (x.rank(pct=True))
)

# Calculate relative performance (difference from subject mean)
scores_df['relative_performance'] = scores_df['score'] - scores_df['subject_mean']

print("Student scores with subject and student means:")
print(scores_df.head(10))
print("\nPercentile and relative performance metrics:")
print(scores_df[['student', 'subject', 'score', 'subject_percentile', 'relative_performance']].head(10))
```

**Output**:

```
Student scores with subject and student means:
   student  subject  score  subject_mean  student_mean
0    Alice     Math     85          80.0     81.666667
1      Bob     Math     70          80.0     77.666667
2  Charlie     Math     90          80.0     90.666667
3    Diana     Math     75          80.0     75.666667
4   Edward     Math     80          80.0     84.000000
5    Frank  Science     92          87.0     92.000000
6    Grace  Science     78          87.0     78.000000
7   Hannah  Science     88          87.0     88.000000
8      Ian  Science     95          87.0     95.000000
9     Jane  Science     82          87.0     82.000000

Percentile and relative performance metrics:
   student  subject  score  subject_percentile  relative_performance
0    Alice     Math     85              80.0                    5.0
1      Bob     Math     70              20.0                  -10.0
2  Charlie     Math     90             100.0                   10.0
3    Diana     Math     75              40.0                   -5.0
4   Edward     Math     80              60.0                    0.0
5    Frank  Science     92              80.0                    5.0
6    Grace  Science     78              20.0                   -9.0
7   Hannah  Science     88              60.0                    1.0
8      Ian  Science     95             100.0                    8.0
9     Jane  Science     82              40.0                   -5.0
```

**Key Points**:

- `transform()` preserves the original DataFrame structure, allowing for easy comparison with original values
- Useful for calculating percentages, percentiles, and deviations from group statistics
- Can be combined with `agg()` for comprehensive analysis
- Multiple transformations can be applied in a single operation

### Custom aggregation functions

You can create custom aggregation functions to perform complex calculations on grouped data.

#### Basic custom aggregation

```python
# Define a custom function
def custom_agg(series):
    # Perform calculations
    result = some_calculation(series)
    return result

# Apply custom function
df.groupby('group_column')['value_column'].agg(custom_agg)
```

#### Custom aggregation with multiple returns

```python
# Function returning multiple values
def multiple_stats(series):
    return {
        'range': series.max() - series.min(),
        'coefficient_of_variation': series.std() / series.mean() * 100,
        'median_to_mean_ratio': series.median() / series.mean()
    }

# Apply to GroupBy object
df.groupby('group_column')['value_column'].apply(multiple_stats)
```

#### Custom aggregation with multiple input columns

```python
# Function accepting multiple columns
def profit_margin(group):
    return (group['revenue'].sum() - group['cost'].sum()) / group['revenue'].sum() * 100

# Apply to entire groups
df.groupby('group_column').apply(profit_margin)
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create sample sales data
np.random.seed(42)
data = {
    'product': np.repeat(['A', 'B', 'C', 'D'], 10),
    'region': np.random.choice(['North', 'South', 'East', 'West'], 40),
    'sales': np.random.randint(1000, 10000, 40),
    'cost': np.random.randint(500, 5000, 40),
    'units': np.random.randint(50, 500, 40)
}
sales_df = pd.DataFrame(data)

# Custom function for profit calculation
def profit_metrics(group):
    profit = group['sales'].sum() - group['cost'].sum()
    margin = profit / group['sales'].sum() * 100
    profit_per_unit = profit / group['units'].sum()
    return pd.Series({
        'total_sales': group['sales'].sum(),
        'total_cost': group['cost'].sum(),
        'profit': profit,
        'margin_pct': margin,
        'profit_per_unit': profit_per_unit
    })

# Apply custom function to product groups
product_profit = sales_df.groupby('product').apply(profit_metrics)

# Custom function for sales distribution analysis
def sales_distribution(group):
    q1, q3 = np.percentile(group['sales'], [25, 75])
    iqr = q3 - q1
    skewness = ((group['sales'] - group['sales'].mean()) ** 3).mean() / (group['sales'].std() ** 3)
    return pd.Series({
        'median': group['sales'].median(),
        'iqr': iqr,
        'skewness': skewness,
        'coefficient_of_variation': group['sales'].std() / group['sales'].mean() * 100
    })

# Apply to region groups
region_sales = sales_df.groupby('region').apply(sales_distribution)

print("Product profit metrics:")
print(product_profit)
print("\nRegion sales distribution:")
print(region_sales)
```

**Output**:

```
Product profit metrics:
          total_sales  total_cost     profit  margin_pct  profit_per_unit
product                                                                  
A            51419      23553     27866.0   54.193973        9.098046
B            43961      21729     22232.0   50.572098        7.147587
C            47041      26229     20812.0   44.242045        6.318182
D            43851      21682     22169.0   50.555974        7.389667

Region sales distribution:
        median       iqr  skewness  coefficient_of_variation
region                                                      
East    4797.0  4126.75  0.082069                 38.970633
North   4825.0  2994.50  0.168254                 36.271397
South   3944.0  2869.25 -0.176337                 35.839071
West    4963.5  4302.25  0.124607                 45.012389
```

#### Complex aggregations with lambda functions

```python
# Inline custom functions
df.groupby('group_column').agg({
    'column1': lambda x: sum(x) / len(x),
    'column2': lambda x: np.sqrt(sum(x**2)),
    'column3': lambda x: '-'.join(x.astype(str))
})
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create student assessment data
data = {
    'class': ['A', 'A', 'A', 'B', 'B', 'B', 'C', 'C', 'C', 'C'],
    'student': ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10'],
    'math': [88, 75, 92, 65, 78, 82, 91, 86, 79, 94],
    'physics': [92, 81, 85, 72, 76, 85, 90, 82, 78, 88],
    'chemistry': [85, 72, 88, 69, 73, 79, 84, 80, 75, 90]
}
grades_df = pd.DataFrame(data)

# Complex aggregation with lambda functions
class_stats = grades_df.groupby('class').agg({
    'math': [
        ('average', 'mean'),
        ('top_score', 'max'), 
        ('fail_count', lambda x: sum(x < 70))
    ],
    'physics': [
        ('average', 'mean'),
        ('pass_rate', lambda x: sum(x >= 70) / len(x) * 100)
    ],
    'chemistry': [
        ('average', 'mean'),
        ('median', 'median'),
        ('score_range', lambda x: x.max() - x.min())
    ]
})

print("Class statistics with custom aggregations:")
print(class_stats)
```

**Output**:

```
Class statistics with custom aggregations:
      math              physics            chemistry                    
   average top_score fail_count  average pass_rate  average median score_range
class                                                                         
A      85.0        92          0     86.0    100.0     81.67     85          16
B      75.0        82          1     77.67    100.0     73.67     73          10
C      87.5        94          0     84.5     100.0     82.25     82          15
```

**Key Points**:

- Custom functions can access any Python functionality including statistics libraries
- Lambda functions are great for simple calculations
- Named functions are better for complex logic or reusable aggregations
- `apply()` provides maximum flexibility but may be slower than built-in functions

### Advanced Aggregation Techniques

#### Filter

The `filter()` method allows you to select groups based on the group properties.

```python
# Keep groups with more than 10 observations
df.groupby('group_column').filter(lambda x: len(x) > 10)

# Keep groups with specific statistics
df.groupby('group_column').filter(lambda x: x['value'].mean() > 100)
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create products data
products = pd.DataFrame({
    'category': ['Electronics', 'Electronics', 'Clothing', 'Clothing', 
                 'Furniture', 'Electronics', 'Clothing', 'Furniture'],
    'product': ['TV', 'Laptop', 'Shirt', 'Pants', 'Table', 'Phone', 'Dress', 'Chair'],
    'price': [1200, 1500, 50, 70, 350, 800, 120, 180],
    'stock': [15, 10, 100, 85, 20, 30, 75, 25],
    'sales': [25, 30, 120, 95, 15, 40, 60, 22]
})

# Filter categories with high average price
expensive_categories = products.groupby('category').filter(lambda x: x['price'].mean() > 300)

# Filter categories with high sales to stock ratio
high_turnover = products.groupby('category').filter(
    lambda x: (x['sales'].sum() / x['stock'].sum()) > 0.8
)

print("Original products data:")
print(products)
print("\nExpensive categories (avg price > 300):")
print(expensive_categories)
print("\nHigh turnover categories (sales/stock > 0.8):")
print(high_turnover)
```

**Output**:

```
Original products data:
      category product  price  stock  sales
0  Electronics      TV   1200     15     25
1  Electronics  Laptop   1500     10     30
2     Clothing   Shirt     50    100    120
3     Clothing   Pants     70     85     95
4    Furniture   Table    350     20     15
5  Electronics   Phone    800     30     40
6     Clothing   Dress    120     75     60
7    Furniture   Chair    180     25     22

Expensive categories (avg price > 300):
      category product  price  stock  sales
0  Electronics      TV   1200     15     25
1  Electronics  Laptop   1500     10     30
4    Furniture   Table    350     20     15
5  Electronics   Phone    800     30     40
7    Furniture   Chair    180     25     22

High turnover categories (sales/stock > 0.8):
     category product  price  stock  sales
2    Clothing   Shirt     50    100    120
3    Clothing   Pants     70     85     95
6    Clothing   Dress    120     75     60
```

#### pipe

The `pipe()` method allows you to chain custom functions that operate on the entire GroupBy object.

```python
def custom_pipe_function(grouped):
    # Process the grouped object
    result = some_processing(grouped)
    return result

# Apply the function to the GroupBy object
df.groupby('group_column').pipe(custom_pipe_function)
```

#### Aggregating with Categoricals

```python
# Create ordered categories
df['grade'] = pd.Categorical(df['grade'], 
                           categories=['F', 'D', 'C', 'B', 'A'], 
                           ordered=True)

# Group by categorical
df.groupby('grade').agg({'score': 'mean'})
```

**Example**:

```python
import pandas as pd
import numpy as np

# Create student grades data
data = {
    'student': ['Alice', 'Bob', 'Charlie', 'Diana', 'Edward', 
                'Frank', 'Grace', 'Hannah', 'Ian', 'Jane'],
    'course': ['Math', 'Math', 'Math', 'Physics', 'Physics', 
               'Physics', 'Chemistry', 'Chemistry', 'Chemistry', 'Math'],
    'score': [92, 78, 85, 90, 67, 73, 88, 95, 82, 79],
    'grade': ['A', 'C', 'B', 'A', 'D', 'C', 'B', 'A', 'B', 'C']
}
grades = pd.DataFrame(data)

# Convert grade to ordered categorical
grades['grade'] = pd.Categorical(grades['grade'], 
                                categories=['F', 'D', 'C', 'B', 'A'], 
                                ordered=True)

# Group by grade (will be sorted by category order)
grade_stats = grades.groupby('grade').agg({
    'score': ['mean', 'count'],
    'student': 'count'
})

# Group by grade and course
course_grade = grades.groupby(['course', 'grade']).size().unstack(fill_value=0)

print("Grade statistics:")
print(grade_stats)
print("\nCourse grade distribution:")
print(course_grade)
```

**Output**:

```
Grade statistics:
      score        student
       mean count    count
grade                     
D      67.0     1        1
C      76.7     3        3
B      85.0     3        3
A      92.3     3        3

Course grade distribution:
grade      D  C  B  A
course                
Chemistry  0  0  2  1
Math       0  2  1  1
Physics    1  1  0  1
```

**Conclusion**: Aggregation methods in pandas provide powerful tools for analyzing grouped data. The `groupby()` function creates the foundation for splitting data into meaningful subsets. From there, `agg()` and `transform()` allow you to calculate statistics and transform values based on group properties. Custom aggregation functions extend these capabilities further, enabling complex analyses tailored to specific needs. By mastering these aggregation techniques, you can efficiently summarize, analyze, and extract insights from structured data.

---

