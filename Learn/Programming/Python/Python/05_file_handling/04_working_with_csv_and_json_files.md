## Working with CSV and JSON Files  


Python provides built-in modules for handling CSV (`csv` module) and JSON (`json` module) files.  

### **Working with CSV Files**  

#### **Reading CSV Files**  
Use `csv.reader()` to read CSV files.  

```python
import csv

with open("data.csv", "r", newline="") as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)  # Each row is a list
```

#### **Reading CSV as Dictionary**  
Use `csv.DictReader()` to read CSV files into dictionaries.  

```python
with open("data.csv", "r", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        print(row["name"], row["age"])  # Access by column name
```

#### **Writing to CSV Files**  
Use `csv.writer()` to write lists to CSV files.  

```python
with open("data.csv", "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["Name", "Age"])
    writer.writerows([["Alice", 25], ["Bob", 30]])
```

#### **Writing Dictionary to CSV**  
Use `csv.DictWriter()` to write dictionaries.  

```python
data = [{"Name": "Alice", "Age": 25}, {"Name": "Bob", "Age": 30}]

with open("data.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=["Name", "Age"])
    writer.writeheader()
    writer.writerows(data)
```

### **Working with JSON Files**  

#### **Reading JSON Files**  
Use `json.load()` to read JSON data from a file.  

```python
import json

with open("data.json", "r") as file:
    data = json.load(file)
print(data)  # Dictionary or list
```

#### **Writing JSON Files**  
Use `json.dump()` to write data to a JSON file.  

```python
data = {"name": "Alice", "age": 25}

with open("data.json", "w") as file:
    json.dump(data, file, indent=4)  # Pretty-print JSON
```

#### **Converting Between JSON and Python Objects**  
Use `json.dumps()` and `json.loads()` to convert between JSON strings and Python objects.  

```python
json_string = json.dumps(data)  # Convert dictionary to JSON string
print(json_string)

python_dict = json.loads(json_string)  # Convert JSON string to dictionary
print(python_dict)
```

**Key Points**  
- Use `csv.reader()` and `csv.DictReader()` for reading CSV files.  
- Use `csv.writer()` and `csv.DictWriter()` for writing CSV files.  
- Use `json.load()` to read JSON files and `json.dump()` to write JSON files.  
- Use `json.dumps()` and `json.loads()` to convert between JSON and Python objects.

---

