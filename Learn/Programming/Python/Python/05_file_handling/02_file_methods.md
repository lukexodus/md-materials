## File Methods  


Python provides various methods for working with files using the `file` object returned by `open()`.  

### **Opening a File**  
```python
file = open("example.txt", "r")  # Open a file in read mode
```

### **Reading Methods**  
#### **`read(size)`** – Reads the entire file or a specific number of bytes.  
```python
with open("example.txt", "r") as file:
    content = file.read(10)  # Reads first 10 characters
    print(content)
```

#### **`readline()`** – Reads a single line.  
```python
with open("example.txt", "r") as file:
    line = file.readline()
    print(line)  # Prints the first line
```

#### **`readlines()`** – Reads all lines into a list.  
```python
with open("example.txt", "r") as file:
    lines = file.readlines()
print(lines)  # ['Line 1\n', 'Line 2\n']
```

### **Writing Methods**  
#### **`write(string)`** – Writes a string to the file.  
```python
with open("example.txt", "w") as file:
    file.write("Hello, world!\n")
```

#### **`writelines(lines)`** – Writes a list of strings.  
```python
lines = ["Line 1\n", "Line 2\n"]
with open("example.txt", "w") as file:
    file.writelines(lines)
```

### **Cursor Positioning Methods**  
#### **`seek(offset, whence)`** – Moves the cursor.  
- `whence=0` (default) – Start of file  
- `whence=1` – Current position  
- `whence=2` – End of file  
```python
with open("example.txt", "r") as file:
    file.seek(5)  # Move to the 5th byte
    print(file.read(5))  # Read 5 bytes
```

#### **`tell()`** – Returns the current cursor position.  
```python
with open("example.txt", "r") as file:
    print(file.tell())  # 0 (start)
    file.read(5)
    print(file.tell())  # 5 (after reading 5 characters)
```

### **Flushing and Closing**  
#### **`flush()`** – Forces writing data to disk.  
```python
with open("example.txt", "w") as file:
    file.write("Data not yet saved.")
    file.flush()  # Ensures data is written immediately
```

#### **`close()`** – Closes the file.  
```python
file = open("example.txt", "r")
file.close()  # Release system resources
```

### **Checking File Properties**  
#### **`name`** – Returns the file name.  
```python
with open("example.txt", "r") as file:
    print(file.name)  # example.txt
```

#### **`mode`** – Returns the file mode.  
```python
with open("example.txt", "r") as file:
    print(file.mode)  # r
```

#### **`closed`** – Returns `True` if the file is closed.  
```python
file = open("example.txt", "r")
print(file.closed)  # False
file.close()
print(file.closed)  # True
```

**Key Points**  
- `read()`, `readline()`, and `readlines()` handle reading operations.  
- `write()` and `writelines()` allow writing strings and lists.  
- `seek()` and `tell()` manage file cursor positioning.  
- `flush()` ensures data is saved immediately.  
- `close()` releases file resources.  
- `name`, `mode`, and `closed` provide file metadata.

---

