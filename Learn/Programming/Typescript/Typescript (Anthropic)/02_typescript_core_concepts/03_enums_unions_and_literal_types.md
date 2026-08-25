## Enums, Unions, and Literal Types


### Enum Types

**Key Points**

- Enums create named constants with descriptive labels
- Numeric enums auto-increment by default, starting at 0
- String enums require explicit values for each member
- Const enums are completely removed during compilation for performance

Enums in TypeScript define a set of named constants, providing a way to document intent and create a set of distinct cases:

```typescript
// Numeric enum (values auto-increment starting from 0)
enum Direction {
  North,  // 0
  East,   // 1
  South,  // 2
  West    // 3
}

let myDirection: Direction = Direction.North;
console.log(myDirection);  // 0

// Numeric enum with custom starting value
enum HttpStatus {
  OK = 200,
  Created = 201,
  BadRequest = 400,
  Unauthorized = 401,
  NotFound = 404,
  ServerError = 500
}

function handleResponse(status: HttpStatus) {
  if (status === HttpStatus.OK) {
    console.log("Request succeeded");
  }
}
```

String enums provide more meaningful values when debugging:

```typescript
// String enum (requires explicit values)
enum Color {
  Red = "RED",
  Green = "GREEN",
  Blue = "BLUE"
}

let favoriteColor: Color = Color.Blue;
console.log(favoriteColor);  // "BLUE"

// Heterogeneous enum (mixed string and numeric values)
enum BooleanLike {
  No = 0,
  Yes = "YES"
}
```

Const enums are optimized away during compilation:

```typescript
// Const enum (inlined during compilation)
const enum Planet {
  Mercury = 1,
  Venus,
  Earth,
  Mars
}

let homePlanet = Planet.Earth;
// Compiles to: let homePlanet = 3;
```

Enum best practices:

1. Use PascalCase for enum names and members
2. Use const enums for better performance when possible
3. Consider string enums for better debugging experience
4. For simple cases, consider using union of literal types instead

### Union Types

**Key Points**

- Union types allow a value to be one of several types
- Denoted with the pipe symbol (`|`)
- Only operations valid for all possible types are allowed without narrowing
- Useful for function parameters that accept different types

Union types allow a variable to have more than one possible type:

```typescript
// Simple union type
let id: string | number;
id = 123;     // Valid
id = "abc";   // Valid
// id = true; // Error: Type 'boolean' is not assignable to type 'string | number'

// Union type with function parameters
function formatValue(value: string | number): string {
  if (typeof value === "string") {
    return value.toUpperCase();
  }
  return value.toFixed(2);
}

formatValue("hello");  // "HELLO"
formatValue(42.325);   // "42.33"

// Union with null for optional values
let username: string | null = null;
username = "john_doe";

// Array of union types
let mixed: (string | number)[] = ["hello", 42, "world", 100];
```

Union types restrict access to properties and methods to only those common to all possible types:

```typescript
// Only operations valid on ALL potential types are allowed without narrowing
function printId(id: string | number) {
  console.log(id.toString());  // OK: both string and number have toString()
  
  // Error: Property 'toUpperCase' doesn't exist on type 'number'
  // console.log(id.toUpperCase());
  
  // With type narrowing, we can access type-specific methods
  if (typeof id === "string") {
    console.log(id.toUpperCase());  // Now OK
  } else {
    console.log(id.toFixed(2));     // Now OK
  }
}
```

### Intersection Types

**Key Points**

- Intersection types combine multiple types into one
- Denoted with the ampersand symbol (`&`)
- The resulting type has all properties from all constituent types
- Often used with object types to merge their properties

Intersection types combine multiple types into one:

```typescript
// Basic intersection of object types
type Employee = {
  id: number;
  name: string;
};

type Manager = {
  managerId: number;
  team: string[];
};

// Combined type has all properties from both types
type TeamManager = Employee & Manager;

const engineering: TeamManager = {
  id: 1,
  name: "Alice Smith",
  managerId: 101,
  team: ["Bob", "Charlie", "Dave"]
};

// Missing any property would cause an error
// const incomplete: TeamManager = { 
//   id: 2,
//   name: "John Doe",
//   managerId: 102
//   // Error: Property 'team' is missing
// };
```

Intersection types can combine interfaces as well:

```typescript
interface Printable {
  print(): void;
}

interface Loggable {
  log(): void;
}

// Create a type that can both print and log
type PrintableLogger = Printable & Loggable;

class Report implements PrintableLogger {
  print() {
    console.log("Printing report...");
  }
  
  log() {
    console.log("Logging report activity...");
  }
}
```

Combining incompatible types creates a never type:

```typescript
// Intersection of incompatible primitives results in never
type ImpossibleType = string & number;
// No value can ever be both a string and a number

// But this works fine for object types that don't conflict
type HasName = { name: string };
type HasAge = { age: number };
type Person = HasName & HasAge;  // { name: string; age: number }
```

### Literal Types

**Key Points**

- Literal types are exact values, not just types
- String, number, and boolean literals are supported
- They work well with union types to create type-safe enumerations
- More flexible than enums in some cases

Literal types represent exact values, not just the broader type:

```typescript
// String literal types
type Direction = "north" | "east" | "south" | "west";
let heading: Direction = "north";  // Valid
// heading = "northeast";  // Error: Type '"northeast"' is not assignable to type 'Direction'

// Number literal types
type DiceRoll = 1 | 2 | 3 | 4 | 5 | 6;
let roll: DiceRoll = 6;  // Valid
// let invalidRoll: DiceRoll = 7;  // Error

// Boolean literal type (rarely used alone)
type True = true;
let isEnabled: True = true;
// isEnabled = false;  // Error

// Combining literal types with other types
type Status = "pending" | "processing" | "success" | "error" | number;
let orderStatus: Status = "processing";  // Valid
orderStatus = 404;  // Also valid
// orderStatus = true;  // Error
```

Literal types are especially useful for function parameters that accept specific values:

```typescript
// Function accepting specific string literals
function setAlignment(align: "left" | "center" | "right"): void {
  // Implementation
}

setAlignment("left");    // Valid
// setAlignment("top");  // Error

// Object with literal properties
type Options = {
  method: "GET" | "POST" | "PUT" | "DELETE";
  timeout: 1000 | 2000 | 5000;
};

const request: Options = {
  method: "POST",
  timeout: 1000
};
```

Literal types can create powerful type-safe APIs:

```typescript
// Configuration object with specific allowed values
type Config = {
  theme: "light" | "dark" | "system";
  notifications: "all" | "important" | "none";
  fontSize: 12 | 14 | 16 | 18 | 20;
};

// Function that validates configuration
function updateConfig(settings: Partial<Config>) {
  // Implementation
}

updateConfig({ theme: "dark", fontSize: 16 });  // Valid
// updateConfig({ theme: "blue" });  // Error
```

### Type Narrowing

**Key Points**

- Type narrowing refines types from broader to more specific
- Common narrowing techniques include type guards, equality checks, and truthiness checks
- The `in` operator and instanceof checks work for objects
- Type predicates allow for custom type guards

Type narrowing is the process of refining types to more specific versions within conditional blocks:

```typescript
// Basic typeof type guard
function process(value: string | number) {
  if (typeof value === "string") {
    // In this block, TypeScript treats value as string
    return value.toUpperCase();
  } else {
    // In this block, TypeScript treats value as number
    return value.toFixed(2);
  }
}

// Equality narrowing
function example(x: string | number, y: string | boolean) {
  if (x === y) {
    // Here, x and y must both be strings
    console.log(x.toUpperCase());
    console.log(y.toLowerCase());
  } else {
    // x is string | number
    // y is string | boolean
  }
}
```

Truthiness checks can narrow types too:

```typescript
// Truthiness narrowing
function printValue(value: string | number | null | undefined) {
  // Removes null and undefined from the type
  if (value) {
    // Here, value is string | number
    console.log("Value:", value);
  } else {
    // Here, value might be empty string, 0, null, or undefined
    console.log("No value");
  }
}

// Specific null check
function greet(name: string | null) {
  if (name !== null) {
    // Here name is just string
    console.log(`Hello, ${name.toUpperCase()}`);
  }
}
```

For objects, use the `in` operator, instanceof, and property existence checks:

```typescript
// in operator narrowing
type Fish = { swim: () => void };
type Bird = { fly: () => void };

function move(animal: Fish | Bird) {
  if ("swim" in animal) {
    // Here, animal is Fish
    animal.swim();
  } else {
    // Here, animal is Bird
    animal.fly();
  }
}

// instanceof narrowing
class Car {
  drive() { console.log("Driving car..."); }
}

class Motorcycle {
  ride() { console.log("Riding motorcycle..."); }
}

function useVehicle(vehicle: Car | Motorcycle) {
  if (vehicle instanceof Car) {
    vehicle.drive();
  } else {
    vehicle.ride();
  }
}
```

Custom type guards with type predicates provide reusable type narrowing:

```typescript
// Type predicate (custom type guard)
interface Student {
  name: string;
  studentId: string;
}

interface Employee {
  name: string;
  employeeId: string;
  department: string;
}

// Type predicate function
function isStudent(person: Student | Employee): person is Student {
  return "studentId" in person;
}

function processSchoolMember(person: Student | Employee) {
  if (isStudent(person)) {
    // TypeScript knows person is Student here
    console.log(`Student: ${person.studentId}`);
  } else {
    // TypeScript knows person is Employee here
    console.log(`Employee: ${person.employeeId}, Dept: ${person.department}`);
  }
}
```

Discriminated unions provide another powerful way to narrow types:

```typescript
// Discriminated union with a "kind" property
type Shape = 
  | { kind: "circle"; radius: number }
  | { kind: "square"; sideLength: number }
  | { kind: "rectangle"; width: number; height: number };

function calculateArea(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      // TypeScript knows shape is the circle variant
      return Math.PI * shape.radius ** 2;
    case "square":
      // TypeScript knows shape is the square variant
      return shape.sideLength ** 2;
    case "rectangle":
      // TypeScript knows shape is the rectangle variant
      return shape.width * shape.height;
  }
}
```

**Conclusion**

TypeScript's enums, unions, intersections, and literal types provide powerful tools for modeling data and ensuring type safety. Enums offer named constants, union types allow variables to have multiple potential types, intersection types combine types, and literal types create precise restrictions to specific values.

Type narrowing is essential when working with these advanced types, allowing TypeScript to understand the specific type of a variable within conditional blocks. The various narrowing techniques—type guards, equality checks, truthiness checks, and custom type predicates—empower developers to write type-safe code with complex data structures.

These features are the building blocks for creating expressive, maintainable TypeScript code that prevents bugs through compile-time type checking while supporting complex type relationships and constraints.

---

