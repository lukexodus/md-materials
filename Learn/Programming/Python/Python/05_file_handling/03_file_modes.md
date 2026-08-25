## File Modes  


Python’s `open()` function supports multiple file modes that determine how a file is accessed. The mode is specified as the second argument in `open(filename, mode)`.  

### **Text File Modes**  
- **`r`** – Read mode (default). The file must exist.  
- **`w`** – Write mode. Creates a new file or overwrites an existing file.  
- **`a`** – Append mode. Creates a file if it does not exist; otherwise, appends to it.  
- **`x`** – Exclusive creation mode. Fails if the file already exists.  

```python
# Reading a file
with open("example.txt", "r") as file:
    content = file.read()

# Writing to a file (overwrites existing content)
with open("example.txt", "w") as file:
    file.write("New content")

# Appending to a file
with open("example.txt", "a") as file:
    file.write("\nAdditional content")

# Creating a file (fails if it already exists)
with open("newfile.txt", "x") as file:
    file.write("This file was just created.")
```

### **Binary File Modes**  
Same as text modes but with **`b`** for binary data (e.g., images, videos).  
- **`rb`** – Read binary file.  
- **`wb`** – Write binary file.  
- **`ab`** – Append to a binary file.  
- **`xb`** – Create a new binary file.  

```python
# Writing binary data
with open("image.jpg", "wb") as file:
    file.write(b'\x89PNG\r\n')

# Reading binary data
with open("image.jpg", "rb") as file:
    data = file.read()
```

### **Read and Write Modes**  
- **`r+`** – Read and write. File must exist.  
- **`w+`** – Write and read. Overwrites existing content.  
- **`a+`** – Append and read. Creates file if it does not exist.  
- **`rb+`**, **`wb+`**, **`ab+`** – Binary versions of `r+`, `w+`, `a+`.  

```python
# Read and write (without truncating file)
with open("example.txt", "r+") as file:
    print(file.read())  # Read existing content
    file.write("\nNew line")  # Write additional content

# Write and read (overwrites file)
with open("example.txt", "w+") as file:
    file.write("Replaced content")
    file.seek(0)
    print(file.read())  # Read the new content
```

**Key Points**  
- Use **`r`** for reading (file must exist).  
- Use **`w`** for writing (erases existing content).  
- Use **`a`** to append (keeps existing content).  
- Use **`x`** to create a file (fails if it exists).  
- Append **`b`** for binary files.  
- Modes like **`r+`**, **`w+`**, and **`a+`** allow both reading and writing.

---

