## I/O Operations


### **Input Operations**

Python uses the `input()` function to take user input. It returns a string by default.

**Example:**

```python
name = input("Enter your name: ")
print(f"Hello, {name}!")
```

#### Reading Numeric Input

Since `input()` returns a string, use type conversion to get numeric values.

```python
age = int(input("Enter your age: "))
height = float(input("Enter your height in meters: "))
```

#### Handling Input Errors

Use `try-except` to handle invalid inputs.

```python
try:
    num = int(input("Enter an integer: "))
except ValueError:
    print("Invalid input! Please enter a valid integer.")
```

### **Output Operations**

Python uses `print()` to display output.

**Example:**

```python
print("Hello, World!")
```

#### Printing Multiple Values

Use commas to separate multiple values.

```python
print("Name:", "Alice", "Age:", 25)
```

#### Formatting Output

Use `f-strings` for readable formatting.

```python
name = "Alice"
age = 25
print(f"My name is {name} and I am {age} years old.")
```

#### Controlling `print()` Behavior

- `sep` specifies a separator between values.
- `end` changes the default newline behavior.

```python
print("Python", "Java", "C++", sep=" | ")
print("Hello", end=" ")
print("World!")
```

### **File I/O**

Python provides built-in functions for reading and writing files.

#### Opening and Closing Files

Use `open()` to access a file and `close()` to release resources.

```python
file = open("example.txt", "r")  # Open file in read mode
file.close()
```

Using `with open()`, files are automatically closed.

```python
with open("example.txt", "r") as file:
    content = file.read()
```

#### Reading from Files

- `read()` reads the entire file.
- `readline()` reads one line at a time.
- `readlines()` returns all lines as a list.
    

```python
with open("example.txt", "r") as file:
    print(file.read())  # Read full file
```

```python
with open("example.txt", "r") as file:
    print(file.readline())  # Read first line
```

```python
with open("example.txt", "r") as file:
    print(file.readlines())  # Read all lines into a list
```

#### Writing to Files

- `w` (write mode) overwrites the file.
- `a` (append mode) adds content to the file.
    

```python
with open("example.txt", "w") as file:
    file.write("Hello, World!\n")
```

```python
with open("example.txt", "a") as file:
    file.write("Appending a new line.\n")
```

**Key Points**
- `input()` reads user input as a string; convert it for numeric values.
- Use `try-except` to handle input errors.
- `print()` can format output using `f-strings` and control separators.
- Use `open()` with `r`, `w`, or `a` modes for file operations.
- The `with` statement ensures files are properly closed.

---
