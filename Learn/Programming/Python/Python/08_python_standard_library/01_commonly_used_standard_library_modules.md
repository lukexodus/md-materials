## **Commonly Used Standard Library Modules**  


### **1. `sys` – System-Specific Functions**  
Provides functions and variables for interacting with the Python runtime.  
```python
import sys
print(sys.version)   Python version
print(sys.platform)   OS platform
sys.exit(0)   Exit the program
```

### **2. `os` – Operating System Interface**  
Used for interacting with the operating system.  
```python
import os
print(os.name)   OS name
print(os.getcwd())   Current working directory
os.mkdir("new_folder")   Create a new directory
os.remove("file.txt")   Delete a file
```

### **3. `math` – Mathematical Functions**  
Provides mathematical operations and constants.  
```python
import math
print(math.sqrt(25))   Square root: 5.0
print(math.pi)   Pi value: 3.141592653589793
print(math.factorial(5))   Factorial: 120
```

### **4. `random` – Generating Random Numbers**  
Used for random number generation and shuffling.  
```python
import random
print(random.randint(1, 10))   Random integer between 1 and 10
print(random.choice(["apple", "banana", "cherry"]))   Random selection
random.shuffle([1, 2, 3, 4, 5])   Shuffle a list
```

### **5. `datetime` – Date and Time Handling**  
Handles dates, times, and time-based operations.  
```python
import datetime
now = datetime.datetime.now()
print(now)   Current date and time
print(now.strftime("%Y-%m-%d %H:%M:%S"))   Format date and time
```

### **6. `time` – Time-Related Functions**  
Provides functions for dealing with time.  
```python
import time
print(time.time())   Current time in seconds since epoch
time.sleep(2)   Pause execution for 2 seconds
```

### **7. `re` – Regular Expressions**  
Used for pattern matching and text processing.  
```python
import re
pattern = r"\d+"
text = "There are 3 apples and 5 oranges."
matches = re.findall(pattern, text)
print(matches)   Output: ['3', '5']
```

### **8. `json` – Working with JSON Data**  
Used to parse and generate JSON data.  
```python
import json
data = {"name": "Alice", "age": 25}
json_data = json.dumps(data)   Convert to JSON string
print(json_data)   Output: '{"name": "Alice", "age": 25}'
parsed_data = json.loads(json_data)   Convert back to dictionary
print(parsed_data["name"])   Output: Alice
```

### **9. `csv` – Handling CSV Files**  
Used for reading and writing CSV files.  
```python
import csv
with open("data.csv", mode="w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["Name", "Age"])
    writer.writerow(["Alice", 25])

with open("data.csv", mode="r") as file:
    reader = csv.reader(file)
    for row in reader:
        print(row)
```

### **10. `urllib` – Handling URLs and HTTP Requests**  
Used to fetch data from the web.  
```python
import urllib.request
response = urllib.request.urlopen("https://www.example.com")
print(response.read().decode("utf-8"))
```

### **11. `http` – HTTP Requests and Responses**  
Used to create HTTP servers and clients.  
```python
from http.server import SimpleHTTPRequestHandler, HTTPServer
server = HTTPServer(("localhost", 8000), SimpleHTTPRequestHandler)
print("Serving on port 8000...")
server.serve_forever()
```

### **12. `socket` – Network Communication**  
Used for creating network connections.  
```python
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("example.com", 80))
print("Connected to example.com")
s.close()
```

### **13. `hashlib` – Hashing Algorithms**  
Used for generating secure hash values.  
```python
import hashlib
hash_object = hashlib.sha256(b"hello world")
print(hash_object.hexdigest())   Output: Hash value
```

### **14. `threading` – Multithreading**  
Used for running multiple threads concurrently.  
```python
import threading
def print_hello():
    print("Hello from thread")

thread = threading.Thread(target=print_hello)
thread.start()
thread.join()
```

### **15. `multiprocessing` – Parallel Processing**  
Used to execute tasks in parallel across multiple CPU cores.  
```python
import multiprocessing
def worker():
    print("Worker process running")

process = multiprocessing.Process(target=worker)
process.start()
process.join()
```

### **16. `itertools` – Iterators and Combinatorics**  
Used for handling iteration-related tasks.  
```python
import itertools
numbers = [1, 2, 3]
combinations = itertools.combinations(numbers, 2)
print(list(combinations))   Output: [(1, 2), (1, 3), (2, 3)]
```

### **17. `functools` – Functional Programming Tools**  
Used for higher-order functions and optimization.  
```python
import functools
def multiply(a, b):
    return a * b

double = functools.partial(multiply, 2)
print(double(5))   Output: 10
```

### **18. `collections` – Specialized Data Structures**  
Provides additional container types beyond lists and dictionaries.  
```python
import collections
Counter = collections.Counter(["a", "b", "a", "c", "b", "a"])
print(Counter)   Output: Counter({'a': 3, 'b': 2, 'c': 1})
```

### **19. `logging` – Logging System**  
Used for debugging and application logging.  
```python
import logging
logging.basicConfig(level=logging.INFO)
logging.info("This is an info message")
```

### **20. `configparser` – Handling Configuration Files**  
Used for reading and writing `.ini` configuration files.  
```python
import configparser
config = configparser.ConfigParser()
config["DEFAULT"] = {"username": "admin", "password": "secret"}
with open("config.ini", "w") as configfile:
    config.write(configfile)
```

---

**Key Points**  
- **The Python Standard Library provides built-in modules for various tasks.**  
- **Modules like `sys`, `os`, `math`, and `random` offer system, OS, and mathematical utilities.**  
- **Networking and web-related tasks can be handled with `urllib`, `socket`, and `http`.**  
- **Concurrency is supported with `threading` and `multiprocessing`.**  
- **Data processing modules like `json`, `csv`, and `collections` simplify structured data handling.**  
- **Security-related modules include `hashlib` for hashing and `logging` for tracking program execution.**

---

