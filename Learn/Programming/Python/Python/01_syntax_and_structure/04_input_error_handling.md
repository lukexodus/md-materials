## Input Error Handling


### **Handling Invalid Input**

User input can cause errors if not properly validated. The `try-except` block helps prevent crashes by handling exceptions.

**Example:**

```python
try:
    age = int(input("Enter your age: "))  # Might raise ValueError
    print(f"You are {age} years old.")
except ValueError:
    print("Invalid input! Please enter a valid number.")
```

### **Looping Until Valid Input**

To ensure valid input, use a loop that repeatedly asks the user until they enter correct data.

**Example:**

```python
while True:
    try:
        age = int(input("Enter your age: "))
        break  # Exit loop if input is valid
    except ValueError:
        print("Invalid input! Please enter a valid number.")

print(f"You entered: {age}")
```

### **Using `else` and `finally` in Error Handling**

- `else`: Executes if no exception occurs.
- `finally`: Executes regardless of whether an exception occurs.
    

**Example:**

```python
try:
    number = float(input("Enter a number: "))
except ValueError:
    print("Invalid input!")
else:
    print(f"Valid input: {number}")
finally:
    print("Execution completed.")
```

**Key Points**
- Use `try-except` to catch exceptions and prevent crashes.
- Use loops to repeatedly prompt the user until valid input is provided.
- `else` runs if no error occurs, and `finally` always executes.

---

