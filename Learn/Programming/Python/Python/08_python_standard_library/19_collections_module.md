## `collections` Module


### Overview

The `collections` module provides specialized container datatypes that extend Python's built-in containers (dict, list, set, tuple). These containers offer additional functionality, better performance for specific use cases, and more convenient APIs for common patterns. The module includes both concrete implementations and abstract base classes for creating custom containers.

### Counter

A `Counter` is a dict subclass for counting hashable objects, essentially a multiset or bag implementation.

#### Basic Usage

```python
from collections import Counter

# Creating counters
c1 = Counter(['a', 'b', 'c', 'a', 'b', 'b'])
print(c1)  # Counter({'b': 3, 'a': 2, 'c': 1})

c2 = Counter({'red': 4, 'blue': 2})
print(c2)  # Counter({'red': 4, 'blue': 2})

c3 = Counter(cats=4, dogs=2)
print(c3)  # Counter({'cats': 4, 'dogs': 2})

# From string
c4 = Counter('hello world')
print(c4)  # Counter({'l': 3, 'o': 2, 'h': 1, 'e': 1, ' ': 1, 'w': 1, 'r': 1, 'd': 1})
```

#### Counter Methods

```python
c = Counter('abracadabra')

# Most common elements
print(c.most_common())     # [('a', 5), ('b', 2), ('r', 2), ('c', 1), ('d', 1)]
print(c.most_common(3))    # [('a', 5), ('b', 2), ('r', 2)]

# Elements (returns iterator over elements)
print(list(c.elements()))  # ['a', 'a', 'a', 'a', 'a', 'b', 'b', 'r', 'r', 'c', 'd']

# Update and subtract
c.update('aabbcc')
print(c)  # Counter({'a': 7, 'b': 4, 'c': 2, 'r': 2, 'd': 1})

c.subtract('abc')
print(c)  # Counter({'a': 6, 'b': 3, 'r': 2, 'c': 1, 'd': 1})

# Total count
print(c.total())  # 13 (sum of all counts)
```

#### Counter Arithmetic

```python
c1 = Counter(['a', 'b', 'c', 'a', 'b', 'b'])
c2 = Counter(['a', 'b', 'b', 'd'])

# Addition (combine counts)
print(c1 + c2)  # Counter({'b': 5, 'a': 3, 'c': 1, 'd': 1})

# Subtraction (subtract counts, keep positive)
print(c1 - c2)  # Counter({'b': 1, 'c': 1})

# Intersection (minimum counts)
print(c1 & c2)  # Counter({'a': 1, 'b': 2})

# Union (maximum counts)
print(c1 | c2)  # Counter({'b': 3, 'a': 2, 'c': 1, 'd': 1})
```

#### Practical Examples

```python
# Word frequency analysis
text = "the quick brown fox jumps over the lazy dog the fox"
word_freq = Counter(text.split())
print(word_freq.most_common(3))  # [('the', 2), ('fox', 2), ('quick', 1)]

# Character frequency in DNA sequence
dna = "ATCGATCGATCG"
nucleotide_count = Counter(dna)
gc_content = (nucleotide_count['G'] + nucleotide_count['C']) / len(dna)
print(f"GC Content: {gc_content:.2%}")

# Inventory management
inventory = Counter(apples=10, oranges=5, bananas=3)
sold = Counter(apples=3, oranges=2, bananas=1)
remaining = inventory - sold
print(f"Remaining inventory: {remaining}")
```

### defaultdict

A `defaultdict` is a dict subclass that calls a factory function to supply missing values.

#### Basic Usage

```python
from collections import defaultdict

# With list as default factory
dd_list = defaultdict(list)
dd_list['key1'].append('value1')
dd_list['key2'].append('value2')
print(dict(dd_list))  # {'key1': ['value1'], 'key2': ['value2']}

# With int as default factory (useful for counting)
dd_int = defaultdict(int)
for char in 'hello':
    dd_int[char] += 1
print(dict(dd_int))  # {'h': 1, 'e': 1, 'l': 2, 'o': 1}

# With set as default factory
dd_set = defaultdict(set)
dd_set['fruits'].add('apple')
dd_set['fruits'].add('banana')
print(dict(dd_set))  # {'fruits': {'apple', 'banana'}}
```

#### Custom Default Factories

```python
# Custom factory function
def default_value():
    return "N/A"

dd_custom = defaultdict(default_value)
print(dd_custom['missing_key'])  # "N/A"

# Lambda factory
dd_lambda = defaultdict(lambda: [0, 0])
dd_lambda['coordinates'][0] = 10
dd_lambda['coordinates'][1] = 20
print(dict(dd_lambda))  # {'coordinates': [10, 20]}

# Nested defaultdict
nested_dd = defaultdict(lambda: defaultdict(int))
nested_dd['user1']['score'] += 10
nested_dd['user1']['attempts'] += 1
nested_dd['user2']['score'] += 20
print(dict(nested_dd))  # {'user1': defaultdict(<class 'int'>, {'score': 10, 'attempts': 1}), 'user2': defaultdict(<class 'int'>, {'score': 20})}
```

#### Practical Examples

```python
# Group items by category
from collections import defaultdict

items = [
    ('apple', 'fruit'),
    ('carrot', 'vegetable'),
    ('banana', 'fruit'),
    ('broccoli', 'vegetable'),
    ('orange', 'fruit')
]

grouped = defaultdict(list)
for item, category in items:
    grouped[category].append(item)

print(dict(grouped))  # {'fruit': ['apple', 'banana', 'orange'], 'vegetable': ['carrot', 'broccoli']}

# Build adjacency list for graph
edges = [('A', 'B'), ('A', 'C'), ('B', 'D'), ('C', 'D')]
graph = defaultdict(set)
for src, dest in edges:
    graph[src].add(dest)
    graph[dest].add(src)  # Undirected graph

# Track student grades by subject
grades = [
    ('Alice', 'Math', 95),
    ('Bob', 'Math', 87),
    ('Alice', 'Science', 92),
    ('Bob', 'Science', 89)
]

student_grades = defaultdict(lambda: defaultdict(list))
for student, subject, grade in grades:
    student_grades[student][subject].append(grade)
```

### deque

A `deque` (double-ended queue) provides O(1) appends and pops from both ends, unlike lists which have O(n) operations for the beginning.

#### Basic Operations

```python
from collections import deque

# Creating deques
d1 = deque([1, 2, 3, 4, 5])
d2 = deque('hello')
d3 = deque(maxlen=3)  # Bounded deque

print(d1)  # deque([1, 2, 3, 4, 5])
print(d2)  # deque(['h', 'e', 'l', 'l', 'o'])
```

#### Deque Methods

```python
d = deque([1, 2, 3])

# Append operations
d.append(4)           # Add to right
d.appendleft(0)       # Add to left
print(d)              # deque([0, 1, 2, 3, 4])

# Pop operations
right = d.pop()       # Remove from right
left = d.popleft()    # Remove from left
print(f"Removed: {left}, {right}")  # Removed: 0, 4
print(d)              # deque([1, 2, 3])

# Extend operations
d.extend([4, 5])      # Extend right
d.extendleft([0, -1]) # Extend left (note: order reversed)
print(d)              # deque([-1, 0, 1, 2, 3, 4, 5])

# Rotation
d.rotate(2)           # Rotate right by 2
print(d)              # deque([4, 5, -1, 0, 1, 2, 3])

d.rotate(-3)          # Rotate left by 3
print(d)              # deque([0, 1, 2, 3, 4, 5, -1])
```

#### Bounded Deques

```python
# Fixed-size deque (LRU-like behavior)
recent_items = deque(maxlen=3)
for i in range(6):
    recent_items.append(i)
    print(f"Added {i}: {recent_items}")

# Output:
# Added 0: deque([0], maxlen=3)
# Added 1: deque([0, 1], maxlen=3)
# Added 2: deque([0, 1, 2], maxlen=3)
# Added 3: deque([1, 2, 3], maxlen=3)  # 0 was removed
# Added 4: deque([2, 3, 4], maxlen=3)  # 1 was removed
# Added 5: deque([3, 4, 5], maxlen=3)  # 2 was removed
```

#### Practical Examples

```python
# Sliding window maximum
def sliding_window_maximum(arr, k):
    from collections import deque
    dq = deque()
    result = []
    
    for i in range(len(arr)):
        # Remove elements outside window
        while dq and dq[0] <= i - k:
            dq.popleft()
        
        # Remove smaller elements from rear
        while dq and arr[dq[-1]] <= arr[i]:
            dq.pop()
        
        dq.append(i)
        
        # Add to result if window is complete
        if i >= k - 1:
            result.append(arr[dq[0]])
    
    return result

# Palindrome checker
def is_palindrome(s):
    d = deque(s.lower())
    while len(d) > 1:
        if d.popleft() != d.pop():
            return False
    return True

print(is_palindrome("racecar"))  # True
print(is_palindrome("hello"))    # False

# Breadth-first search
def bfs(graph, start):
    visited = set()
    queue = deque([start])
    result = []
    
    while queue:
        vertex = queue.popleft()
        if vertex not in visited:
            visited.add(vertex)
            result.append(vertex)
            queue.extend(neighbor for neighbor in graph[vertex] 
                        if neighbor not in visited)
    
    return result
```

### OrderedDict

An `OrderedDict` is a dict subclass that remembers insertion order. [Inference] While regular dicts in Python 3.7+ maintain insertion order, OrderedDict provides additional ordering-related methods and guarantees order preservation across all Python versions.

#### Basic Usage

```python
from collections import OrderedDict

# Regular dict vs OrderedDict
regular_dict = {'a': 1, 'b': 2, 'c': 3}
ordered_dict = OrderedDict([('a', 1), ('b', 2), ('c', 3)])

print(regular_dict)  # {'a': 1, 'b': 2, 'c': 3}
print(ordered_dict)  # OrderedDict([('a', 1), ('b', 2), ('c', 3)])
```

#### OrderedDict Methods

```python
od = OrderedDict([('a', 1), ('b', 2), ('c', 3)])

# Move to end
od.move_to_end('a')
print(od)  # OrderedDict([('b', 2), ('c', 3), ('a', 1)])

# Move to beginning
od.move_to_end('c', last=False)
print(od)  # OrderedDict([('c', 3), ('b', 2), ('a', 1)])

# Pop last item (LIFO)
last_item = od.popitem(last=True)
print(f"Popped: {last_item}")  # Popped: ('a', 1)

# Pop first item (FIFO)
first_item = od.popitem(last=False)
print(f"Popped: {first_item}")  # Popped: ('c', 3)
print(od)  # OrderedDict([('b', 2)])
```

#### Practical Examples

```python
# LRU Cache implementation
class LRUCache:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = OrderedDict()
    
    def get(self, key):
        if key in self.cache:
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            return self.cache[key]
        return None
    
    def put(self, key, value):
        if key in self.cache:
            # Update existing key
            self.cache.move_to_end(key)
        elif len(self.cache) >= self.capacity:
            # Remove least recently used
            self.cache.popitem(last=False)
        self.cache[key] = value

# Configuration with ordered sections
config = OrderedDict()
config['database'] = {'host': 'localhost', 'port': 5432}
config['cache'] = {'host': 'redis', 'port': 6379}
config['logging'] = {'level': 'INFO', 'file': 'app.log'}

# Maintain order when iterating
for section, settings in config.items():
    print(f"[{section}]")
    for key, value in settings.items():
        print(f"{key} = {value}")
```

### namedtuple

`namedtuple` creates tuple subclasses with named fields, providing a lightweight way to create classes for storing data.

#### Basic Usage

```python
from collections import namedtuple

# Define a named tuple
Point = namedtuple('Point', ['x', 'y'])
p1 = Point(10, 20)
print(p1)        # Point(x=10, y=20)
print(p1.x, p1.y)  # 10 20

# Alternative field specification
Person = namedtuple('Person', 'name age city')
person1 = Person('Alice', 30, 'New York')
print(person1.name)  # Alice

# With defaults (Python 3.7+)
Employee = namedtuple('Employee', ['name', 'id', 'department'], defaults=['IT'])
emp1 = Employee('Bob', 123)
print(emp1)  # Employee(name='Bob', id=123, department='IT')
```

#### namedtuple Methods

```python
Point = namedtuple('Point', ['x', 'y', 'z'])
p = Point(1, 2, 3)

# _asdict() - convert to dictionary
print(p._asdict())  # {'x': 1, 'y': 2, 'z': 3}

# _replace() - create new instance with some fields changed
p2 = p._replace(x=10)
print(p2)  # Point(x=10, y=2, z=3)

# _fields - tuple of field names
print(Point._fields)  # ('x', 'y', 'z')

# _make() - create instance from iterable
coords = [4, 5, 6]
p3 = Point._make(coords)
print(p3)  # Point(x=4, y=5, z=6)

# Tuple operations still work
print(p[0])     # 1 (indexing)
print(len(p))   # 3 (length)
x, y, z = p     # unpacking
```

#### Practical Examples

```python
# Database record representation
Record = namedtuple('Record', ['id', 'name', 'email', 'created_at'])

def fetch_users():
    # Simulate database fetch
    raw_data = [
        (1, 'Alice', 'alice@example.com', '2023-01-01'),
        (2, 'Bob', 'bob@example.com', '2023-01-02')
    ]
    return [Record._make(row) for row in raw_data]

users = fetch_users()
for user in users:
    print(f"User {user.name} ({user.email}) created on {user.created_at}")

# RGB color representation
Color = namedtuple('Color', ['red', 'green', 'blue'])

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return Color(*[int(hex_color[i:i+2], 16) for i in (0, 2, 4)])

red = hex_to_rgb('#FF0000')
print(red)  # Color(red=255, green=0, blue=0)

# Geometric calculations
Point = namedtuple('Point', ['x', 'y'])

def distance(p1, p2):
    return ((p1.x - p2.x)**2 + (p1.y - p2.y)**2)**0.5

p1 = Point(0, 0)
p2 = Point(3, 4)
print(f"Distance: {distance(p1, p2)}")  # Distance: 5.0

# Configuration objects
Config = namedtuple('Config', ['host', 'port', 'timeout', 'retries'], defaults=['localhost', 8080, 30, 3])
config = Config(host='production.com', port=443)
print(config)  # Config(host='production.com', port=443, timeout=30, retries=3)
```

### ChainMap

`ChainMap` groups multiple dicts or mappings together to create a single, updateable view.

#### Basic Usage

```python
from collections import ChainMap

dict1 = {'a': 1, 'b': 2}
dict2 = {'b': 3, 'c': 4}
dict3 = {'c': 5, 'd': 6}

# Create chain map
cm = ChainMap(dict1, dict2, dict3)
print(cm)  # ChainMap({'a': 1, 'b': 2}, {'b': 3, 'c': 4}, {'c': 5, 'd': 6})

# Lookup (searches in order)
print(cm['a'])  # 1 (from dict1)
print(cm['b'])  # 2 (from dict1, not dict2)
print(cm['c'])  # 4 (from dict2, not dict3)
print(cm['d'])  # 6 (from dict3)

# List all keys
print(list(cm.keys()))    # ['d', 'c', 'b', 'a']
print(list(cm.values()))  # [6, 4, 2, 1]
```

#### ChainMap Methods

```python
dict1 = {'a': 1, 'b': 2}
dict2 = {'c': 3, 'd': 4}
cm = ChainMap(dict1, dict2)

# new_child() - add new dict at front
child_cm = cm.new_child({'e': 5})
print(child_cm)  # ChainMap({'e': 5}, {'a': 1, 'b': 2}, {'c': 3, 'd': 4})

# parents - all maps except the first
print(cm.parents)  # ChainMap({'c': 3, 'd': 4})

# maps - list of all mappings
print(cm.maps)  # [{'a': 1, 'b': 2}, {'c': 3, 'd': 4}]

# Updates affect only the first mapping
cm['a'] = 10  # Updates dict1
cm['f'] = 6   # Adds to dict1
print(dict1)  # {'a': 10, 'b': 2, 'f': 6}
print(dict2)  # {'c': 3, 'd': 4} (unchanged)
```

#### Practical Examples

```python
# Configuration hierarchy (command line > config file > defaults)
defaults = {'host': 'localhost', 'port': 8080, 'debug': False}
config_file = {'host': 'production.com', 'port': 443}
command_line = {'debug': True}

config = ChainMap(command_line, config_file, defaults)
print(f"Host: {config['host']}")      # production.com (from config_file)
print(f"Port: {config['port']}")      # 443 (from config_file)
print(f"Debug: {config['debug']}")    # True (from command_line)

# Nested scope simulation
def outer_function():
    outer_vars = {'x': 1, 'y': 2}
    
    def inner_function():
        inner_vars = {'y': 3, 'z': 4}
        # Simulate variable lookup: local -> outer -> global
        scope = ChainMap(inner_vars, outer_vars, globals())
        print(f"x: {scope.get('x', 'Not found')}")  # 1 (from outer)
        print(f"y: {scope.get('y', 'Not found')}")  # 3 (from inner)
        print(f"z: {scope.get('z', 'Not found')}")  # 4 (from inner)
    
    inner_function()

# Environment variable override
import os
app_defaults = {'timeout': 30, 'retries': 3, 'verbose': False}
app_config = ChainMap(os.environ, app_defaults)

# Use environment variable if set, otherwise use default
timeout = int(app_config.get('TIMEOUT', app_config['timeout']))
```

### UserDict, UserList, UserString

These are wrapper classes that provide a base for creating custom container types.

#### UserDict

```python
from collections import UserDict

class CaseInsensitiveDict(UserDict):
    def __setitem__(self, key, value):
        super().__setitem__(key.lower(), value)
    
    def __getitem__(self, key):
        return super().__getitem__(key.lower())
    
    def __contains__(self, key):
        return super().__contains__(key.lower())
    
    def __delitem__(self, key):
        super().__delitem__(key.lower())

# Usage
ci_dict = CaseInsensitiveDict()
ci_dict['Name'] = 'Alice'
ci_dict['AGE'] = 30

print(ci_dict['name'])  # Alice
print(ci_dict['age'])   # 30
print('NAME' in ci_dict)  # True

# Validation dictionary
class ValidatedDict(UserDict):
    def __init__(self, validator_func, *args, **kwargs):
        self.validator = validator_func
        super().__init__(*args, **kwargs)
    
    def __setitem__(self, key, value):
        if not self.validator(key, value):
            raise ValueError(f"Invalid value: {value} for key: {key}")
        super().__setitem__(key, value)

def validate_age(key, value):
    return key == 'age' and isinstance(value, int) and 0 <= value <= 150

age_dict = ValidatedDict(validate_age)
age_dict['age'] = 25  # OK
# age_dict['age'] = -5  # Would raise ValueError
```

#### UserList

```python
from collections import UserList

class UniqueList(UserList):
    def append(self, item):
        if item not in self.data:
            super().append(item)
    
    def extend(self, items):
        for item in items:
            self.append(item)
    
    def insert(self, index, item):
        if item not in self.data:
            super().insert(index, item)

# Usage
ul = UniqueList([1, 2, 3])
ul.append(2)  # Won't add duplicate
ul.extend([3, 4, 5])  # Only 4 and 5 will be added
print(ul)  # [1, 2, 3, 4, 5]

# Statistics list
class StatsList(UserList):
    @property
    def mean(self):
        return sum(self.data) / len(self.data) if self.data else 0
    
    @property
    def median(self):
        sorted_data = sorted(self.data)
        n = len(sorted_data)
        if n % 2 == 0:
            return (sorted_data[n//2 - 1] + sorted_data[n//2]) / 2
        return sorted_data[n//2]

stats = StatsList([1, 3, 5, 7, 9])
print(f"Mean: {stats.mean}")    # Mean: 5.0
print(f"Median: {stats.median}")  # Median: 5
```

### Abstract Base Classes

The collections.abc module provides abstract base classes for containers.

#### Common ABCs

```python
from collections.abc import Mapping, MutableMapping, Sequence, MutableSequence

# Check if object implements interface
print(isinstance({}, Mapping))           # True
print(isinstance([], Sequence))          # True
print(isinstance([], MutableSequence))   # True

# Custom container that implements ABC
class ReadOnlyDict(Mapping):
    def __init__(self, data):
        self._data = data
    
    def __getitem__(self, key):
        return self._data[key]
    
    def __iter__(self):
        return iter(self._data)
    
    def __len__(self):
        return len(self._data)

# Usage
rod = ReadOnlyDict({'a': 1, 'b': 2})
print(rod['a'])     # 1
print(len(rod))     # 2
print(list(rod))    # ['a', 'b']
# rod['c'] = 3      # Would work but we haven't implemented __setitem__
```

### Performance Comparisons

#### List vs Deque Performance

```python
import time
from collections import deque

# Comparing append/pop performance
def time_operations(container_type, n=100000):
    container = container_type()
    
    # Time appends
    start = time.time()
    for i in range(n):
        container.append(i)
    append_time = time.time() - start
    
    # Time pops from left (if supported)
    if hasattr(container, 'popleft'):
        start = time.time()
        while container:
            container.popleft()
        pop_time = time.time() - start
    else:
        start = time.time()
        while container:
            container.pop(0)  # Inefficient for lists
        pop_time = time.time() - start
    
    return append_time, pop_time

# [Inference] Deques are significantly faster for operations at both ends
list_append, list_pop = time_operations(list, 10000)
deque_append, deque_pop = time_operations(deque, 10000)

print(f"List - Append: {list_append:.4f}s, Pop from start: {list_pop:.4f}s")
print(f"Deque - Append: {deque_append:.4f}s, Pop from start: {deque_pop:.4f}s")
```

#### Counter vs Manual Counting

```python
import time
from collections import Counter

data = ['apple', 'banana', 'apple', 'cherry', 'banana', 'apple'] * 10000

# Manual counting
start = time.time()
manual_count = {}
for item in data:
    manual_count[item] = manual_count.get(item, 0) + 1
manual_time = time.time() - start

# Counter
start = time.time()
counter_count = Counter(data)
counter_time = time.time() - start

print(f"Manual counting: {manual_time:.4f}s")
print(f"Counter: {counter_time:.4f}s")
# [Inference] Counter is typically faster due to C implementation
```

### Memory Usage Considerations

#### namedtuple vs Class vs dict

```python
import sys
from collections import namedtuple

# Regular class
class RegularPoint:
    def __init__(self, x, y):
        self.x = x
        self.y = y

# namedtuple
NamedPoint = namedtuple('Point', ['x', 'y'])

# Compare memory usage
regular = RegularPoint(1, 2)
named = NamedPoint(1, 2)
dict_point = {'x': 1, 'y': 2}

print(f"Regular class: {sys.getsizeof(regular)} bytes")
print(f"namedtuple: {sys.getsizeof(named)} bytes")
print(f"dict: {sys.getsizeof(dict_point)} bytes")
# [Inference] namedtuples are typically more memory-efficient than dicts and regular classes
```

### Best Practices and Common Patterns

#### When to Use Each Container

**Key points:**

- **Counter**: Frequency counting, multiset operations, statistical analysis
- **defaultdict**: Grouping data, avoiding KeyError, building nested structures
- **deque**: Queue/stack operations, sliding windows, bounded collections
- **OrderedDict**: When insertion order matters and you need ordering methods
- **namedtuple**: Lightweight data containers, replacing simple classes
- **ChainMap**: Configuration hierarchies, scope simulation, layered lookups

#### Common Patterns

```python
# Pattern 1: Grouping with defaultdict
from collections import defaultdict
def group_by(iterable, key_func):
    groups = defaultdict(list)
    for item in iterable:
        groups[key_func(item)].append(item)
    return dict(groups)

# Pattern 2: Frequency analysis with Counter
def analyze_text(text):
    words = text.lower().split()
    word_freq = Counter(words)
    char_freq = Counter(text.lower().replace(' ', ''))
    return {
        'word_count': len(words),
        'unique_words': len(word_freq),
        'most_common_word': word_freq.most_common(1)[0] if word_freq else None,
        'char_distribution': dict(char_freq.most_common(5))
    }

# Pattern 3: LRU-like behavior with deque
def recent_items_tracker(maxsize=10):
    items = deque(maxlen=maxsize)
    def add_item(item):
        if item in items:
            items.remove(item)  # Remove old occurrence
        items.append(item)  # Add to end
        return list(items)
    return add_item

# Pattern 4: Configuration management with ChainMap
def create_config(*config_sources):
    """Create configuration from multiple sources (later sources have higher priority)"""
    return ChainMap(*reversed(config_sources))
```

### Error Handling and Edge Cases

#### Handling Missing Keys

```python
from collections import defaultdict, Counter

# defaultdict with None factory
dd = defaultdict(lambda: None)
print(dd['missing'])  # None (instead of KeyError)

# Counter with missing keys
c = Counter(['a', 'b', 'c'])
print(c['missing'])  # 0 (not KeyError)

# ChainMap with missing keys
from collections import ChainMap

cm = ChainMap({'a': 1}, {'b': 2})
print(cm.get('missing', 'default'))  # 'default'
# print(cm['missing'])  # Would raise KeyError
```

#### Thread Safety Considerations

```python
import threading
from collections import defaultdict, deque, Counter

# [Unverified] Most collections types are not thread-safe for modifications
# Use locks for concurrent access
lock = threading.Lock()
shared_counter = Counter()

def thread_safe_count(items):
    with lock:
        shared_counter.update(items)

# For deque, some operations are atomic, but complex operations need locks
shared_deque = deque()

def safe_deque_operation():
    with lock:
        if shared_deque:  # Check and pop atomically
            return shared_deque.popleft()
    return None
```

#### Handling Large Data Sets

```python
# Memory-efficient processing with generators
def process_large_file(filename):
    word_count = Counter()
    
    def word_generator():
        with open(filename, 'r') as f:
            for line in f:
                for word in line.strip().split():
                    yield word.lower()
    
    # Process in chunks to avoid memory issues
    chunk_size = 10000
    words = word_generator()
    while True:
        chunk = []
        try:
            for _ in range(chunk_size):
                chunk.append(next(words))
        except StopIteration:
            if chunk:
                word_count.update(chunk)
            break
        word_count.update(chunk)
    
    return word_count

# Bounded collections for streaming data
class BoundedDefaultDict(defaultdict):
    def __init__(self, default_factory, max_size):
        super().__init__(default_factory)
        self.max_size = max_size
    
    def __setitem__(self, key, value):
        if len(self) >= self.max_size and key not in self:
            # Remove oldest item (simple LRU-like behavior)
            oldest_key = next(iter(self))
            del self[oldest_key]
        super().__setitem__(key, value)
```

### Advanced Use Cases

#### Custom Collection Combinations

```python
from collections import defaultdict, Counter, deque

class MultiLevelCounter:
    """Counter that tracks items at multiple hierarchy levels"""
    def __init__(self):
        self.counters = defaultdict(Counter)
    
    def add(self, category, item):
        self.counters[category][item] += 1
        self.counters['_total'][item] += 1
    
    def get_category_stats(self, category):
        return dict(self.counters[category])
    
    def get_global_stats(self):
        return dict(self.counters['_total'])
    
    def most_common_global(self, n=None):
        return self.counters['_total'].most_common(n)

# Usage
mlc = MultiLevelCounter()
mlc.add('fruits', 'apple')
mlc.add('fruits', 'banana')
mlc.add('vegetables', 'carrot')
mlc.add('fruits', 'apple')

print(mlc.get_category_stats('fruits'))  # {'apple': 2, 'banana': 1}
print(mlc.most_common_global())          # [('apple', 2), ('banana', 1), ('carrot', 1)]

class TimestampedDeque:
    """Deque with automatic timestamping"""
    def __init__(self, maxlen=None):
        self.items = deque(maxlen=maxlen)
        self.timestamps = deque(maxlen=maxlen)
    
    def append(self, item):
        import time
        self.items.append(item)
        self.timestamps.append(time.time())
    
    def get_recent(self, seconds):
        import time
        cutoff = time.time() - seconds
        recent_items = []
        for item, timestamp in zip(self.items, self.timestamps):
            if timestamp >= cutoff:
                recent_items.append((item, timestamp))
        return recent_items
    
    def __len__(self):
        return len(self.items)
    
    def __iter__(self):
        return zip(self.items, self.timestamps)

# Usage
td = TimestampedDeque(maxlen=100)
td.append('event1')
import time; time.sleep(1)
td.append('event2')
recent = td.get_recent(0.5)  # Get events from last 0.5 seconds
```

#### Data Processing Pipelines

```python
from collections import defaultdict, Counter, deque
from functools import reduce
import operator

class DataPipeline:
    """Process data through multiple collection-based stages"""
    def __init__(self):
        self.stages = []
    
    def add_grouping_stage(self, key_func):
        def group_stage(data):
            grouped = defaultdict(list)
            for item in data:
                grouped[key_func(item)].append(item)
            return dict(grouped)
        self.stages.append(group_stage)
        return self
    
    def add_counting_stage(self):
        def count_stage(data):
            if isinstance(data, dict):
                return {k: Counter(v) for k, v in data.items()}
            return Counter(data)
        self.stages.append(count_stage)
        return self
    
    def add_filtering_stage(self, predicate):
        def filter_stage(data):
            if isinstance(data, dict):
                return {k: [item for item in v if predicate(item)] 
                       for k, v in data.items()}
            return [item for item in data if predicate(item)]
        self.stages.append(filter_stage)
        return self
    
    def process(self, data):
        return reduce(lambda d, stage: stage(d), self.stages, data)

# Example usage
transactions = [
    {'type': 'purchase', 'amount': 100, 'category': 'food'},
    {'type': 'purchase', 'amount': 50, 'category': 'transport'},
    {'type': 'refund', 'amount': 25, 'category': 'food'},
    {'type': 'purchase', 'amount': 75, 'category': 'food'},
]

pipeline = (DataPipeline()
           .add_grouping_stage(lambda x: x['type'])
           .add_filtering_stage(lambda x: x['amount'] > 30)
           .add_counting_stage())

result = pipeline.process(transactions)
print(result)
```

#### Caching and Memoization Patterns

```python
from collections import OrderedDict
from functools import wraps

class TTLCache:
    """Time-to-live cache using OrderedDict"""
    def __init__(self, maxsize=128, ttl=300):
        self.maxsize = maxsize
        self.ttl = ttl
        self.cache = OrderedDict()
        self.timestamps = {}
    
    def _is_expired(self, key):
        import time
        return time.time() - self.timestamps.get(key, 0) > self.ttl
    
    def get(self, key):
        if key in self.cache and not self._is_expired(key):
            # Move to end (LRU behavior)
            self.cache.move_to_end(key)
            return self.cache[key]
        elif key in self.cache:
            # Remove expired item
            del self.cache[key]
            del self.timestamps[key]
        return None
    
    def set(self, key, value):
        import time
        if key in self.cache:
            self.cache.move_to_end(key)
        elif len(self.cache) >= self.maxsize:
            # Remove oldest
            oldest = next(iter(self.cache))
            del self.cache[oldest]
            del self.timestamps[oldest]
        
        self.cache[key] = value
        self.timestamps[key] = time.time()

def ttl_memoize(ttl=300, maxsize=128):
    """Decorator for TTL memoization"""
    def decorator(func):
        cache = TTLCache(maxsize, ttl)
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key
            key = str(args) + str(sorted(kwargs.items()))
            
            result = cache.get(key)
            if result is not None:
                return result
            
            result = func(*args, **kwargs)
            cache.set(key, result)
            return result
        
        wrapper.cache_info = lambda: {
            'size': len(cache.cache),
            'maxsize': cache.maxsize,
            'ttl': cache.ttl
        }
        wrapper.cache_clear = lambda: cache.cache.clear()
        
        return wrapper
    return decorator

# Usage
@ttl_memoize(ttl=60, maxsize=100)
def expensive_calculation(n):
    import time
    time.sleep(1)  # Simulate expensive operation
    return n ** 2

result = expensive_calculation(5)  # Takes 1 second
result = expensive_calculation(5)  # Returns immediately from cache
```

### Integration with Other Modules

#### JSON Serialization

```python
import json
from collections import OrderedDict, namedtuple, Counter

# OrderedDict with JSON
data = OrderedDict([('name', 'Alice'), ('age', 30), ('city', 'NYC')])
json_str = json.dumps(data)
loaded = json.loads(json_str, object_pairs_hook=OrderedDict)
print(type(loaded))  # <class 'collections.OrderedDict'>

# namedtuple with JSON
Person = namedtuple('Person', ['name', 'age', 'city'])
person = Person('Bob', 25, 'LA')

# Convert to dict for JSON serialization
person_dict = person._asdict()
json_str = json.dumps(person_dict)

# Load back as namedtuple
loaded_dict = json.loads(json_str)
loaded_person = Person(**loaded_dict)

# Counter with JSON
counter = Counter(['a', 'b', 'a', 'c', 'b', 'a'])
counter_json = json.dumps(dict(counter))
loaded_counter = Counter(json.loads(counter_json))
```

#### Pickle Support

```python
import pickle
from collections import defaultdict, deque, Counter

# Most collections types are pickle-able
dd = defaultdict(list)
dd['key'].append('value')

pickled = pickle.dumps(dd)
unpickled = pickle.loads(pickled)
print(type(unpickled))  # <class 'collections.defaultdict'>
print(unpickled.default_factory)  # <class 'list'>

# Custom collections need special handling
class CustomCounter(Counter):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.creation_time = __import__('time').time()
    
    def __reduce__(self):
        # Custom pickle support
        return (self.__class__, (dict(self),))

cc = CustomCounter(['a', 'b', 'a'])
pickled_cc = pickle.dumps(cc)
unpickled_cc = pickle.loads(pickled_cc)
```

#### Database Integration

```python
from collections import namedtuple, defaultdict
import sqlite3

# Using namedtuple for database records
def fetch_users_as_namedtuple():
    conn = sqlite3.connect(':memory:')
    conn.execute('CREATE TABLE users (id INTEGER, name TEXT, email TEXT)')
    conn.execute("INSERT INTO users VALUES (1, 'Alice', 'alice@example.com')")
    conn.execute("INSERT INTO users VALUES (2, 'Bob', 'bob@example.com')")
    
    User = namedtuple('User', ['id', 'name', 'email'])
    cursor = conn.execute('SELECT * FROM users')
    
    users = [User(*row) for row in cursor.fetchall()]
    conn.close()
    return users

# Grouping database results
def group_users_by_domain():
    users = fetch_users_as_namedtuple()
    by_domain = defaultdict(list)
    
    for user in users:
        domain = user.email.split('@')[1]
        by_domain[domain].append(user)
    
    return dict(by_domain)

users_by_domain = group_users_by_domain()
print(users_by_domain)
```

### Testing Collections-Based Code

```python
import unittest
from collections import Counter, defaultdict, deque

class TestCollections(unittest.TestCase):
    def test_counter_operations(self):
        c1 = Counter(['a', 'b', 'c', 'a'])
        c2 = Counter(['a', 'b', 'b'])
        
        # Test arithmetic operations
        result = c1 + c2
        expected = Counter({'a': 3, 'b': 3, 'c': 1})
        self.assertEqual(result, expected)
        
        # Test most_common
        self.assertEqual(c1.most_common(2), [('a', 2), ('b', 1)])
    
    def test_defaultdict_behavior(self):
        dd = defaultdict(list)
        dd['key'].append('value')
        
        # Test that missing keys create default values
        self.assertEqual(dd['missing'], [])
        self.assertIsInstance(dd['missing'], list)
    
    def test_deque_performance(self):
        d = deque(maxlen=3)
        
        # Test bounded behavior
        for i in range(5):
            d.append(i)
        
        self.assertEqual(len(d), 3)
        self.assertEqual(list(d), [2, 3, 4])
    
    def test_custom_collections(self):
        # Test custom collection behavior
        class ValidatedList(list):
            def append(self, item):
                if not isinstance(item, int):
                    raise TypeError("Only integers allowed")
                super().append(item)
        
        vl = ValidatedList([1, 2, 3])
        vl.append(4)
        self.assertEqual(vl, [1, 2, 3, 4])
        
        with self.assertRaises(TypeError):
            vl.append('string')

if __name__ == '__main__':
    unittest.main()
```

### Performance Optimization Tips

#### Choosing the Right Collection

```python
import timeit
from collections import deque, defaultdict, Counter

# Benchmark different approaches
def benchmark_counting():
    data = ['apple', 'banana', 'apple'] * 1000
    
    # Method 1: Manual dictionary
    def manual_count():
        counts = {}
        for item in data:
            counts[item] = counts.get(item, 0) + 1
        return counts
    
    # Method 2: defaultdict
    def defaultdict_count():
        counts = defaultdict(int)
        for item in data:
            counts[item] += 1
        return dict(counts)
    
    # Method 3: Counter
    def counter_count():
        return Counter(data)
    
    # [Inference] Counter is typically fastest for this use case
    manual_time = timeit.timeit(manual_count, number=1000)
    defaultdict_time = timeit.timeit(defaultdict_count, number=1000)
    counter_time = timeit.timeit(counter_count, number=1000)
    
    print(f"Manual: {manual_time:.4f}s")
    print(f"defaultdict: {defaultdict_time:.4f}s")
    print(f"Counter: {counter_time:.4f}s")

# Memory usage optimization
def memory_efficient_grouping(items, key_func):
    """Group items without storing all in memory at once"""
    # Instead of defaultdict(list) which stores all items
    # Use generator-based approach for large datasets
    sorted_items = sorted(items, key=key_func)
    
    from itertools import groupby
    for key, group in groupby(sorted_items, key=key_func):
        yield key, list(group)
```

### Common Antipatterns and Solutions

#### Avoiding Performance Pitfalls

```python
# ANTIPATTERN: Using list for frequent left operations
def bad_queue():
    queue = []
    for i in range(1000):
        queue.append(i)
    
    # This is O(n) for each operation!
    while queue:
        item = queue.pop(0)  # Bad!

# SOLUTION: Use deque
def good_queue():
    from collections import deque
    queue = deque()
    for i in range(1000):
        queue.append(i)
    
    # This is O(1) for each operation
    while queue:
        item = queue.popleft()  # Good!

# ANTIPATTERN: Manual grouping when defaultdict is available
def bad_grouping(items):
    groups = {}
    for item in items:
        key = item['category']
        if key not in groups:
            groups[key] = []  # Manual check
        groups[key].append(item)
    return groups

# SOLUTION: Use defaultdict
def good_grouping(items):
    from collections import defaultdict
    groups = defaultdict(list)
    for item in items:
        groups[item['category']].append(item)  # No manual check needed
    return dict(groups)
```

#### Avoiding Memory Leaks

```python
# ANTIPATTERN: Keeping references in collections
class DataProcessor:
    def __init__(self):
        self.cache = {}  # Can grow indefinitely
    
    def process(self, data):
        result = expensive_operation(data)
        self.cache[id(data)] = result  # Memory leak!
        return result

# SOLUTION: Use bounded collections
class BetterDataProcessor:
    def __init__(self, cache_size=1000):
        from collections import OrderedDict
        self.cache = OrderedDict()
        self.cache_size = cache_size
    
    def process(self, data):
        cache_key = hash(str(data))  # Better key
        
        if cache_key in self.cache:
            self.cache.move_to_end(cache_key)
            return self.cache[cache_key]
        
        result = expensive_operation(data)
        
        if len(self.cache) >= self.cache_size:
            self.cache.popitem(last=False)  # Remove oldest
        
        self.cache[cache_key] = result
        return result

def expensive_operation(data):
    # Placeholder for expensive operation
    return data * 2
```

**Key points:**

- Collections module provides specialized containers optimized for specific use cases
- Counter excels at frequency analysis and multiset operations
- defaultdict eliminates KeyError handling and simplifies grouping operations
- deque provides O(1) operations at both ends, perfect for queues and stacks
- OrderedDict maintains insertion order with additional ordering methods
- namedtuple creates lightweight, immutable record types
- ChainMap enables layered lookups across multiple mappings
- UserDict, UserList, UserString provide bases for custom container types
- [Inference] Most collections types are implemented in C for optimal performance
- Choose the right collection type based on your specific access patterns and requirements
- Be mindful of memory usage with unbounded collections
- Thread safety requires explicit synchronization for most collection operations
- Integration with JSON, pickle, and databases is straightforward for most types

The collections module is essential for writing efficient, readable Python code that handles complex data structures and access patterns elegantly.

---

