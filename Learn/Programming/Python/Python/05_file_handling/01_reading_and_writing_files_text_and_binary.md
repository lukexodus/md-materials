## Reading and Writing Files (Text and Binary)  


Python provides built-in functions to handle file operations, including reading and writing text and binary files.  

### **Opening Files**  
Use the `open()` function with different modes:  
- **`r`** – Read (default)  
- **`w`** – Write (overwrites existing content)  
- **`a`** – Append (adds to the end of the file)  
- **`x`** – Create (fails if the file exists)  
- **`b`** – Binary mode  
- **`t`** – Text mode (default)  
- **`+`** – Read and write  

```python
file = open("example.txt", "r")  # Open for reading (default mode)
file.close()
```

### **Reading Text Files**  
#### **Reading the Entire File**  
```python
with open("example.txt", "r") as file:
    content = file.read()
print(content)
```

#### **Reading Line by Line**  
```python
with open("example.txt", "r") as file:
    for line in file:
        print(line.strip())  # Strip removes newline characters
```

#### **Reading as a List of Lines**  
```python
with open("example.txt", "r") as file:
    lines = file.readlines()
print(lines)  # ['Line 1\n', 'Line 2\n']
```

### **Writing to Text Files**  
#### **Overwriting a File (`w` mode)**  
```python
with open("example.txt", "w") as file:
    file.write("Hello, World!\n")
```

#### **Appending to a File (`a` mode)**  
```python
with open("example.txt", "a") as file:
    file.write("Appending a new line.\n")
```

### **Working with Binary Files**  
#### **Writing Binary Data**  
```python
with open("binary.dat", "wb") as file:
    file.write(b'\x00\xFF\x10')  # Writing raw bytes
```

#### **Reading Binary Data**  
```python
with open("binary.dat", "rb") as file:
    data = file.read()
print(data)  # Output: b'\x00\xff\x10'
```

### **Handling File Exceptions**  
```python
try:
    with open("nonexistent.txt", "r") as file:
        content = file.read()
except FileNotFoundError:
    print("File not found.")
except IOError:
    print("Error reading file.")
```


**Key Points**  
- Use `with open()` to ensure files are properly closed.  
- `read()`, `readline()`, and `readlines()` provide different ways to read files.  
- `write()` and `writelines()` allow writing text or binary data.  
- Handle exceptions using `try-except` to avoid errors.

---

