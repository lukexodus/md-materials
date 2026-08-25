## Strings  


### **Overview**  
A string is an immutable sequence of characters enclosed in single (`'`), double (`"`), or triple (`''' """`) quotes. Strings support indexing, slicing, and various built-in methods for manipulation.  

### **Creating Strings**  
```python
# Using single or double quotes
string1 = 'Hello'
string2 = "World"

# Using triple quotes for multiline strings
multiline = '''This is 
a multiline 
string'''

# Creating a string with the str() constructor
num_str = str(100)  # "100"
```

### **Accessing Characters**  
```python
text = "Python"
print(text[0])  # 'P' (first character)
print(text[-1])  # 'n' (last character)
```

### **Slicing Strings**  
```python
print(text[1:4])  # 'yth'
print(text[:3])  # 'Pyt'
print(text[::2])  # 'Pto' (every second character)
print(text[::-1])  # 'nohtyP' (reversed string)
```

### **String Concatenation and Repetition**  
```python
greeting = "Hello" + " " + "World"  # 'Hello World'
repeat = "Ha" * 3  # 'HaHaHa'
```

### **Checking Substrings**  
```python
print("Py" in text)  # True
print("Java" not in text)  # True
```

### **Modifying Strings**  
```python
text = "hello world"
print(text.upper())  # 'HELLO WORLD'
print(text.lower())  # 'hello world'
print(text.title())  # 'Hello World'
print(text.capitalize())  # 'Hello world'
print(text.swapcase())  # 'HELLO WORLD'
```

### **Trimming and Padding Strings**  
```python
text = "  Python  "
print(text.strip())  # 'Python' (removes spaces)
print(text.lstrip())  # 'Python  ' (removes left spaces)
print(text.rstrip())  # '  Python' (removes right spaces)

print(text.center(20, '-'))  # '-----  Python  -----'
print(text.ljust(20, '-'))  # '  Python  ---------'
print(text.rjust(20, '-'))  # '---------  Python  '
```

### **Replacing and Splitting Strings**  
```python
text = "Hello World"
print(text.replace("World", "Python"))  # 'Hello Python'

words = text.split()  # ['Hello', 'World']
csv_data = "apple,banana,grape"
print(csv_data.split(","))  # ['apple', 'banana', 'grape']
```

### **Joining Strings**  
```python
words = ["Hello", "World"]
print(" ".join(words))  # 'Hello World'

csv_list = ["apple", "banana", "grape"]
print(",".join(csv_list))  # 'apple,banana,grape'
```

### **Finding Substrings**  
```python
text = "Python programming"
print(text.find("pro"))  # 7 (first occurrence index)
print(text.rfind("o"))  # 9 (last occurrence index)
print(text.count("o"))  # 2 (number of occurrences)
```

### **Checking String Properties**  
```python
print("hello".isalpha())  # True (only letters)
print("123".isdigit())  # True (only digits)
print("hello123".isalnum())  # True (letters and digits)
print("   ".isspace())  # True (only spaces)
print("Hello World".istitle())  # True (each word capitalized)
```

### **Formatting Strings**  
```python
name = "Alice"
age = 25
print(f"My name is {name} and I am {age} years old.")  # f-string
print("My name is {} and I am {} years old.".format(name, age))  # format()
print("My name is %s and I am %d years old." % (name, age))  # Old-style formatting
```

### **Reversing a String**  
```python
text = "Python"
reversed_text = text[::-1]  # 'nohtyP'
print(''.join(reversed(text)))  # 'nohtyP'
```

**Key Points**  
- Strings are immutable and support indexing, slicing, and various built-in methods.  
- Use `+` for concatenation and `*` for repetition.  
- `strip()`, `lstrip()`, and `rstrip()` remove whitespace.  
- `find()`, `count()`, and `replace()` help in searching and modifying strings.  
- `join()` efficiently concatenates elements from an iterable.  
- `f-strings`, `format()`, and `%` formatting are used for dynamic string generation.

---

