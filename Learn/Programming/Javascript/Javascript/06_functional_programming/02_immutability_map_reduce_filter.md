## Immutability, Map/Reduce/Filter


### Understanding Immutability

Immutability refers to the principle that once a data structure is created, it cannot be changed. Instead of modifying existing data, immutable operations create new copies with the desired changes.

**Key Points:**

- Immutable data cannot be changed after creation
- Operations on immutable data return new data structures
- Immutability helps avoid side effects and unexpected behavior
- Simplifies debugging and reasoning about code
- Enables features like undo/redo and time-travel debugging
- Facilitates concurrency and pure functions

### Why Immutability Matters

Immutability offers several advantages in software development:

```javascript
// Mutability can lead to unexpected behavior
const user = { name: 'Alice', role: 'Admin' };
function processUser(user) {
  user.role = 'User'; // Side effect - modifies original object
  return user;
}
processUser(user);
console.log(user.role); // 'User' - Original object changed!

// Immutable approach
const user = { name: 'Alice', role: 'Admin' };
function processUser(user) {
  return { ...user, role: 'User' }; // Returns new object
}
const processedUser = processUser(user);
console.log(user.role); // 'Admin' - Original unchanged
console.log(processedUser.role); // 'User' - New object
```

### Implementing Immutability in JavaScript

JavaScript does not have built-in immutability, but provides several ways to work with immutable data:

### Primitive Immutability

JavaScript primitives (strings, numbers, booleans) are inherently immutable:

```javascript
let name = "Alice";
name.toUpperCase(); // Creates new string, doesn't modify original
console.log(name); // Still "Alice"

name = name.toUpperCase(); // Reassignment, not mutation
console.log(name); // "ALICE"
```

### Object Immutability Techniques

#### Object Spread Operator

```javascript
const user = { name: 'Alice', age: 30 };
const updatedUser = { ...user, age: 31 };
console.log(user.age); // 30
console.log(updatedUser.age); // 31
```

#### Object.assign()

```javascript
const user = { name: 'Bob', settings: { theme: 'dark' } };
const updatedUser = Object.assign({}, user, { name: 'Robert' });
console.log(user.name); // 'Bob'
console.log(updatedUser.name); // 'Robert'
```

#### Object.freeze()

```javascript
const config = Object.freeze({
  apiKey: 'abc123',
  endpoint: 'https://api.example.com'
});

// This will fail in strict mode or be silently ignored
config.apiKey = 'new-key';
console.log(config.apiKey); // Still 'abc123'
```

### Array Immutability Techniques

#### Array Spread Operator

```javascript
const numbers = [1, 2, 3];
const added = [...numbers, 4]; // [1, 2, 3, 4]
const inserted = [...numbers.slice(0, 1), 1.5, ...numbers.slice(1)]; // [1, 1.5, 2, 3]
```

#### Array Methods

Many array methods return new arrays rather than modifying the original:

```javascript
const numbers = [1, 2, 3];

// Non-mutating methods (return new arrays)
const doubled = numbers.map(n => n * 2); // [2, 4, 6]
const filtered = numbers.filter(n => n > 1); // [2, 3]
const summed = numbers.reduce((sum, n) => sum + n, 0); // 6
const sliced = numbers.slice(1); // [2, 3]
const concatenated = numbers.concat([4, 5]); // [1, 2, 3, 4, 5]

console.log(numbers); // Still [1, 2, 3]
```

### Deep Immutability

The techniques above only provide shallow immutability. For nested objects:

```javascript
const user = {
  name: 'Alice',
  address: {
    city: 'New York',
    zipcode: '10001'
  }
};

// Shallow copy with nested object mutation
const shallowCopy = { ...user };
shallowCopy.address.city = 'Boston';
console.log(user.address.city); // 'Boston' - Original was modified!

// Deep copy to maintain immutability
const deepCopy = {
  ...user,
  address: { ...user.address }
};
deepCopy.address.city = 'Boston';
console.log(user.address.city); // 'New York' - Original unchanged
```

### Immutability Libraries

For complex applications, immutability libraries can help:

- **Immer**: Uses a draft concept for intuitive immutable updates
- **Immutable.js**: Provides immutable data structures
- **Ramda**: Functional programming library with immutable operations

```javascript
// Using Immer
import produce from 'immer';

const state = {
  users: [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' }
  ]
};

const nextState = produce(state, draft => {
  draft.users[0].name = 'Alicia';
  draft.users.push({ id: 3, name: 'Charlie' });
});

// state is unchanged, nextState contains the updates
```

### Map, Filter, and Reduce

These three higher-order functions are fundamental to functional programming and working with collections immutably.

### Map

The `map()` method creates a new array by applying a function to every element in the original array.

**Key Points:**

- Returns a new array of the same length
- Does not modify the original array
- Transforms each element individually
- Maintains the array indices

```javascript
const numbers = [1, 2, 3, 4, 5];

// Doubling each number
const doubled = numbers.map(num => num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]

// Transforming objects
const users = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' }
];

const usernames = users.map(user => user.name);
console.log(usernames); // ['Alice', 'Bob']

const formattedUsers = users.map(user => ({
  ...user,
  name: user.name.toUpperCase(),
  createdAt: new Date()
}));
```

### Filter

The `filter()` method creates a new array containing only elements that pass a test function.

**Key Points:**

- Returns a new array (possibly shorter than original)
- Does not modify the original array
- Includes elements for which the callback returns true
- Maintains the relative order of elements

```javascript
const numbers = [1, 2, 3, 4, 5, 6];

// Get even numbers
const evens = numbers.filter(num => num % 2 === 0);
console.log(evens); // [2, 4, 6]

// Filter objects based on properties
const users = [
  { id: 1, name: 'Alice', active: true },
  { id: 2, name: 'Bob', active: false },
  { id: 3, name: 'Charlie', active: true }
];

const activeUsers = users.filter(user => user.active);
console.log(activeUsers.length); // 2

// Combine filter and map
const activeUsernames = users
  .filter(user => user.active)
  .map(user => user.name);
console.log(activeUsernames); // ['Alice', 'Charlie']
```

### Reduce

The `reduce()` method executes a reducer function on each element, resulting in a single output value.

**Key Points:**

- Returns a single value of any type (number, string, object, array)
- Uses an accumulator to track the running result
- Can specify an initial value for the accumulator
- Extremely versatile - can implement map and filter with reduce

```javascript
const numbers = [1, 2, 3, 4, 5];

// Sum all numbers
const sum = numbers.reduce((accumulator, current) => accumulator + current, 0);
console.log(sum); // 15

// Find maximum value
const max = numbers.reduce((max, current) => 
  current > max ? current : max, numbers[0]);
console.log(max); // 5

// Build an object from an array
const users = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' }
];

const userMap = users.reduce((acc, user) => {
  acc[user.id] = user;
  return acc;
}, {});

console.log(userMap);
// { 
//   1: { id: 1, name: 'Alice' }, 
//   2: { id: 2, name: 'Bob' } 
// }
```

### Advanced Reduce Examples

```javascript
// Grouping by a property
const people = [
  { name: 'Alice', city: 'New York' },
  { name: 'Bob', city: 'Boston' },
  { name: 'Charlie', city: 'New York' }
];

const groupedByCity = people.reduce((groups, person) => {
  const city = person.city;
  if (!groups[city]) {
    groups[city] = [];
  }
  groups[city].push(person);
  return groups;
}, {});

console.log(groupedByCity);
// {
//   'New York': [
//     { name: 'Alice', city: 'New York' },
//     { name: 'Charlie', city: 'New York' }
//   ],
//   'Boston': [{ name: 'Bob', city: 'Boston' }]
// }

// Implementing map with reduce
const mapWithReduce = (array, fn) => {
  return array.reduce((acc, item, index, arr) => {
    acc.push(fn(item, index, arr));
    return acc;
  }, []);
};

// Implementing filter with reduce
const filterWithReduce = (array, fn) => {
  return array.reduce((acc, item, index, arr) => {
    if (fn(item, index, arr)) {
      acc.push(item);
    }
    return acc;
  }, []);
};
```

### Method Chaining

One of the most powerful aspects of map/filter/reduce is the ability to chain them:

```javascript
const data = [
  { id: 1, name: 'Alice', age: 25, active: true },
  { id: 2, name: 'Bob', age: 17, active: false },
  { id: 3, name: 'Charlie', age: 30, active: true },
  { id: 4, name: 'David', age: 22, active: true }
];

const result = data
  .filter(user => user.active)
  .filter(user => user.age >= 18)
  .map(user => ({
    id: user.id,
    name: user.name.toUpperCase()
  }))
  .reduce((acc, user) => {
    acc[user.id] = user;
    return acc;
  }, {});

console.log(result);
// {
//   1: { id: 1, name: 'ALICE' },
//   3: { id: 3, name: 'CHARLIE' },
//   4: { id: 4, name: 'DAVID' }
// }
```

### Performance Considerations

Working with immutable data and transformations can have performance implications:

**Key Points:**

- Creating new objects/arrays has memory overhead
- Long chains of operations create intermediate arrays
- For large datasets, consider performance optimizations
- Memoization can help avoid redundant calculations
- Modern JavaScript engines optimize many common patterns

```javascript
// Potentially inefficient with large arrays
const result = hugeArray
  .map(expensive1)
  .filter(expensive2)
  .map(expensive3);

// More efficient - single pass with reduce
const efficientResult = hugeArray.reduce((acc, item) => {
  const transformed1 = expensive1(item);
  if (expensive2(transformed1)) {
    acc.push(expensive3(transformed1));
  }
  return acc;
}, []);
```

### Real-world Applications

#### State Management

```javascript
// React Redux-style reducer
function userReducer(state = initialState, action) {
  switch (action.type) {
    case 'ADD_USER':
      return {
        ...state,
        users: [...state.users, action.payload]
      };
    case 'REMOVE_USER':
      return {
        ...state,
        users: state.users.filter(user => user.id !== action.payload.id)
      };
    case 'UPDATE_USER':
      return {
        ...state,
        users: state.users.map(user => 
          user.id === action.payload.id 
            ? { ...user, ...action.payload.updates }
            : user
        )
      };
    default:
      return state;
  }
}
```

#### Data Processing

```javascript
// Processing CSV data
const csvRows = csvString.split('\n');
const headers = csvRows[0].split(',');

const processedData = csvRows
  .slice(1) // Skip header row
  .filter(row => row.trim() !== '') // Remove empty rows
  .map(row => {
    const values = row.split(',');
    return headers.reduce((obj, header, index) => {
      obj[header] = values[index];
      return obj;
    }, {});
  })
  .filter(rowObj => rowObj.active === 'true') // Filter active records
  .map(rowObj => ({
    ...rowObj,
    age: parseInt(rowObj.age, 10) // Convert string to number
  }));
```

### Immutability with Modern JavaScript Features

#### Object Rest/Spread

```javascript
const user = { id: 1, name: 'Alice', role: 'admin', active: true };

// Update properties immutably
const updatedUser = { 
  ...user,
  role: 'user',
  lastLogin: new Date()
};

// Remove properties immutably
const { active, ...inactiveUser } = user;
```

#### Array Rest/Spread

```javascript
const numbers = [1, 2, 3, 4, 5];

// Add items immutably
const withExtra = [...numbers, 6, 7];

// Insert at specific position
const withInserted = [
  ...numbers.slice(0, 2),
  42,
  ...numbers.slice(2)
];

// Remove item at index immutably
const index = 2;
const withoutItem = [
  ...numbers.slice(0, index),
  ...numbers.slice(index + 1)
];
```

### Functional Programming with Map/Filter/Reduce

```javascript
// Function composition
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);

const double = x => x * 2;
const square = x => x * x;
const addOne = x => x + 1;

const computation = compose(addOne, square, double);
console.log(computation(3)); // 37 (double: 6, square: 36, addOne: 37)

// Creating reusable transformations
const byAge = age => user => user.age >= age;
const byActive = user => user.active;
const getName = user => user.name;
const uppercase = str => str.toUpperCase();

const getActiveAdultNames = users => users
  .filter(byAge(18))
  .filter(byActive)
  .map(getName)
  .map(uppercase);
```

**Conclusion**  

Immutability combined with map/filter/reduce creates a powerful paradigm for data manipulation in JavaScript. This approach enables more predictable code, better testability, and facilitates parallel processing. The functional programming style that emerges from these concepts has become increasingly prevalent in modern JavaScript development, from React's component model to Redux's state management, and beyond.

---

