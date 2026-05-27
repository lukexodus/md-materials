# Core Concepts

## Program Structure

```java
// Package Declaration (Optional)
package com.example.myapp;

// Import Statements (Optional)
import java.util.Scanner;

// Class Declaration
public class MyApp {

    // Main Method
    public static void main(String[] args) {
        
        // Program Logic
        System.out.println("Hello, World!");
        
    }

    // Additional Methods (Optional)
    // ...
}
```

1. **Package Declaration (Optional):**
    - Used to organize related classes into packages.
    - Helps prevent naming conflicts and provides better code organization.
    - Not mandatory, but recommended for larger projects.
2. **Import Statements (Optional):**
    - Used to import classes or entire packages from the Java standard library or external libraries.
    - Allows you to use classes and methods defined in the imported packages without fully qualifying their names.
    - Not necessary if you're only using classes from the `java.lang` package, as it is automatically imported.
3. **Class Declaration:**
    - Defines the blueprint for objects in the program.
    - Every Java program must contain at least one class.
    - The name of the class must match the filename (with the `.java` extension) where it is saved.
    - The `public` keyword indicates that the class can be accessed from outside the package.
4. **Main Method:**
    - The entry point of the Java program.
    - It has a specific signature: `public static void main(String[] args)`.
    - The `args` parameter is an array of strings containing command-line arguments passed to the program.
    - Program execution starts from the `main` method.
5. **Program Logic:**
    - Contains the statements and logic of the program.
    - This is where you write the code to perform the desired functionality of your application.
    - In the example, the program simply prints "Hello, World!" to the console.
6. **Additional Methods (Optional):**
    - You can define additional methods within the class to organize and modularize your code.
    - Methods can have their own logic and can be called from other methods within the class or from external classes.

***

## Packages

  
A package is a mechanism used for organizing classes into namespaces. It helps in avoiding naming conflicts, providing a way to encapsulate classes and interfaces into a single unit, and improving code reusability and maintainability. 
### 1. Package Declaration:

- At the top of each Java source file, there can be at most one package declaration statement. This statement informs the compiler to which package the classes in the file belong.

- Syntax:
```java
package com.example.myproject;
```

- Conventionally, package names are written in lowercase letters to avoid conflicts with class names.

### 2. Package Structure:

- Packages can be nested within each other to form a hierarchical structure, similar to directories in a file system.
- For example, `java.util` and `java.util.concurrent` represent packages where `java.util.concurrent` is a subpackage of `java.util`.


### 3. Package Benefits:

- **Encapsulation**: Packages encapsulate related classes and interfaces, preventing name clashes with classes from other packages.
- **Access Control**: Java provides access control mechanisms (`public`, `protected`, `default`, and `private`) to restrict access to classes and members based on package boundaries.
- **Code Organization**: Packages help organize code logically, making it easier to understand, maintain, and reuse.


### 4. Import Statements:

- To use classes from other packages, Java provides import statements. These statements inform the compiler about the classes or packages to be used in the current file.
    
- Syntax:
```java
import package.name.ClassName;
```
    
- You can use the wildcard character `*` to import all classes within a package:
```java
import java.util.*;
```

### 5. Commonly Used Packages:

- `java.lang`: Automatically imported by Java, contains fundamental classes such as `String`, `Integer`, and `System`.
- `java.util`: Contains utility classes like `ArrayList`, `HashMap`, and `LinkedList`.
- `java.io`: Provides classes for input and output operations, such as `FileInputStream` and `FileWriter`.
- `java.awt`, `javax.swing`: Packages for creating graphical user interfaces (GUI) in Java.

**Best Practices:**

1. Choose meaningful and descriptive package names.
2. Use package-private access control (default access) when classes or members are intended to be used within the same package only.
3. Avoid using `*` in import statements to prevent potential conflicts and improve code readability.

***

## Compilation and Execution

1. **Compile the Java Source File:**
    - To compile the Java source file, use the `javac` command followed by the name of the Java file you want to compile. For example:
        `javac MyApp.java`
    - If the compilation is successful, it will generate a `.class` file containing the bytecode representation of your Java program.
2. **Run the Java Program:**
    - Once the Java source file is compiled, you can run the program using the `java` command followed by the name of the class containing the `main` method (without the `.class` extension). For example:
        `java MyApp`
    - If everything is set up correctly, the Java Virtual Machine (JVM) will execute your program, and you should see the output in the command prompt or terminal.

**Note**:
- Make sure you have the Java Development Kit (JDK) installed on your system and the `javac` and `java` commands are available in your system's PATH.
- Always ensure that your Java source file and class file are in the same directory.
- Check for any compilation errors or runtime exceptions that may occur during program execution.

***

## The `main` Method

In Java, there should only be one `main` method per class. The `main` method is the entry point of a Java program, and it is where the execution of the program begins. However, a Java project or a folder can contain multiple classes, each with its own `main` method.

1. **One `main` Method per Class**: Each class that serves as an entry point to your program should have its own `main` method. This allows you to organize your code into separate classes with distinct functionalities.

2. **Multiple Classes with `main` Methods**: In a Java project or a folder, you can have multiple classes with `main` methods. This is common in larger projects where different classes represent different components or modules of the application.

3. **Launching the Program**: When you run a Java program, you specify the class name containing the `main` method that you want to execute. The Java Virtual Machine (JVM) looks for the `main` method in the specified class and starts executing the program from there.

4. **Main Class for Deployment**: Typically, one of the classes with a `main` method serves as the primary entry point or the main class for the deployment of the application. This class is often the one that orchestrates the initialization of various components of the application.

```java
// Class A with main method
public class A {
    public static void main(String[] args) {
        System.out.println("Main method of class A");
    }
}

// Class B with main method
public class B {
    public static void main(String[] args) {
        System.out.println("Main method of class B");
    }
}
```

In this example, both classes `A` and `B` have their own `main` methods. You can run either `A` or `B` to execute their respective `main` methods. However, at runtime, you need to specify which class's `main` method you want to execute.

To specify which `main` method to run in a Java program, you need to provide the fully qualified name of the class containing the `main` method as an argument to the `java` command when you execute your program from the command line.

Syntax:

```bash
java fully.qualified.ClassName
```


Example:

```java
// Class A with main method
public class A {
    public static void main(String[] args) {
        System.out.println("Main method of class A");
    }
}

// Class B with main method
public class B {
    public static void main(String[] args) {
        System.out.println("Main method of class B");
    }
}
```

To run the `main` method of class `A`, you would execute:

```bash
java A
```

To run the `main` method of class `B`, you would execute:

```bash
java B
```

The `java` command will look for the specified class name and execute the `main` method defined within that class. If the class is not found or does not contain a `main` method, the JVM will throw an error.

***
## Data Types

**Primitive Data Types:**
    - Java has eight primitive data types, which are stored directly in memory and have predefined values.
    - **byte:** 8 bits (1 byte)
        - Range: -128 to 127
    - **short:** 16 bits (2 bytes)
        - Range: -32,768 to 32,767
    - **int:** 32 bits (4 bytes)
        - Range: -2^31 to 2^31 - 1
    - **long:** 64 bits (8 bytes)
        - Range: -2^63 to 2^63 - 1
    - **float:** 32 bits (4 bytes)
        - Range: Approximately ±3.4E-38 to ±3.4E+38
        - Precision: 7 decimal digits
    - **double:** 64 bits (8 bytes)
        - Range: Approximately ±1.7E-308 to ±1.7E+308
        - Precision: 15 decimal digits
    - **char:** 16 bits (2 bytes)
        - Represents a single Unicode character.
        - Range: '\u0000' (0) to '\uffff' (65,535)
    - **boolean:** Size not precisely defined
        - Represents true or false values.

**Reference Types:
- Classes
- Arrays
- Interfaces
- Enumerations
- String

In Java, the memory allocated for primitive data types is fixed regardless of the platform (32-bit or 64-bit). However, the memory allocation for objects and arrays may vary based on the JVM implementation and the underlying hardware architecture.

**Key Differences:**

- Primitive types are predefined by the Java language and represent simple values, while reference types are instances of classes or arrays.
- Primitive types are stored directly in memory, while reference types store references to objects in memory.
- Primitive types have default values, while reference types default to `null` if not explicitly initialized.
- Primitive types are passed by value, while reference types are passed by reference.

***

## Number to String


### Using String.valueOf() Method:

```java
int number = 123;
String str = String.valueOf(number);
```

### Using Integer.toString() Method:

```java
int number = 123;
String str = Integer.toString(number);
```

### Using String.format() Method:

```java
int number = 123;
String str = String.format("%d", number);
```

### Using StringBuilder or StringBuffer:

```java
int number = 123;
String str = new StringBuilder().append(number).toString();
```

### Using Concatenation:

```java
int number = 123;
String str = "" + number;
```

### Using Double.toString() Method (for double values):

```java
double number = 123.45;
String str = Double.toString(number);
```


***

## `int` vs `Integer` (Wrapper Classes)

  
In Java, `int` and `Integer` are related data types, but they have different characteristics and purposes.

### int:

- `int` is a primitive data type in Java.
- It represents a 32-bit signed integer value.
- It cannot hold `null` values.
- It is used for storing integer values in a more memory-efficient manner compared to `Integer`.
- It cannot be used with collections or generics directly, as they require reference types.

Example:

```java
int number = 10;
```

### Integer:

- `Integer` is a wrapper class for the primitive type `int`.
- It wraps an `int` value into an object, allowing it to be used in contexts that require objects, such as collections and generics.
- It can hold `null` values.
- It provides utility methods for converting strings to integers, performing arithmetic operations, and more.

Example:

```java
Integer number = 10; // Autoboxing
```

### Autoboxing and Unboxing:

Java allows automatic conversion between primitive types and their corresponding wrapper classes through autoboxing and unboxing:

- **Autoboxing**: Conversion of a primitive type to its corresponding wrapper class automatically by the Java compiler. For example, assigning an `int` value to an `Integer` variable.
- **Unboxing**: Conversion of a wrapper class object to its corresponding primitive type automatically by the Java compiler. For example, using an `Integer` object in a context that requires an `int` value.

```java
Integer obj = 10; // Autoboxing
int value = obj;   // Unboxing
```

### When to Use int vs Integer:

- Use `int` for simple integer values when memory efficiency is crucial or when working with arithmetic operations.
- Use `Integer` when dealing with collections, generics, or situations that require an object representation of an integer, such as `null` values or utility methods provided by the `Integer` class.

## Wrapper Classes

There are wrapper classes for each of the primitive data types. These wrapper classes allow primitive data types to be treated as objects. Here are the wrapper classes for the primitive data types:

1. **Integer**: Wraps `int`.
2. **Long**: Wraps `long`.
3. **Short**: Wraps `short`.
4. **Byte**: Wraps `byte`.
5. **Float**: Wraps `float`.
6. **Double**: Wraps `double`.
7. **Character**: Wraps `char`.
8. **Boolean**: Wraps `boolean`.

The wrapper classes in Java (`Integer`, `Long`, `Short`, `Byte`, `Float`, `Double`, `Character`, and `Boolean`) provide a set of common and distinct methods to manipulate and work with the corresponding primitive data types. Here's a summary of the common and distinct methods for each wrapper class:

### Common Methods:

1. **valueOf()**: Converts a primitive data type to its corresponding wrapper class object.
2. **xxxValue()**: Returns the primitive value of the wrapper class object.
3. **toString()**: Returns a string representation of the wrapper class object.
4. **parseXxx()**: Parses the string argument as a primitive data type value.
5. **equals()**: Compares the object with another object for equality.

### Methods:

#### Numeric types (Integer, Long, Short, Byte):

- `compareTo(NumericType anotherNumber)`: Compares two numeric objects of the same type numerically.

#### Float:

- `compareTo(Float anotherFloat)`: Compares two `Float` objects numerically.
- `isNaN()`: Returns true if this `Float` value is Not-a-Number (NaN).

#### Double:

- `compareTo(Double anotherDouble)`: Compares two `Double` objects numerically.
- `isNaN()`: Returns true if this `Double` value is Not-a-Number (NaN).

#### Character:

- `isLetter()`: Determines if the specified character is a letter.
- `isDigit()`: Determines if the specified character is a digit.
- `isWhitespace()`: Determines if the specified character is white space according to Java.
- `isUpperCase()`: Determines if the specified character is an uppercase character.
- `isLowerCase()`: Determines if the specified character is a lowercase character.
- `toUpperCase()`: Converts the character argument to uppercase.
- `toLowerCase()`: Converts the character argument to lowercase.

#### Boolean:

- `compare(Boolean anotherBoolean)`: Compares two `Boolean` objects.

**Example Usage:**

```java
Integer num1 = Integer.valueOf(10);
int value1 = num1.intValue();

Long num2 = Long.valueOf(100L);
long value2 = num2.longValue();

String str = "123";
int parsedValue = Integer.parseInt(str);

boolean isEqual = num1.equals(Integer.valueOf(10));

// Distinct methods
int comparisonResult = num1.compareTo(Integer.valueOf(5));

Character ch = 'A';
boolean isLetter = Character.isLetter(ch);

Boolean bool = Boolean.valueOf(true);
boolean isSame = bool.compare(Boolean.valueOf(false));
```

***

## Variable Declaration

1. **Syntax:**
    `data_type variable_name;`

2. **Example:**
    `int age; double salary; String name;`

3. **Initialization:**
    - You can also initialize variables at the time of declaration:
    `data_type variable_name = initial_value;`

4. **Example with Initialization:**
	```java
int age; 
double salary;
String name;
	```

4. **Multiple Variable Declaration:**
    - You can declare multiple variables of the same type on a single line, separated by commas:
    `data_type variable1, variable2, variable3;`

4. **Example with Multiple Variables:**
```java
int num1, num2, num3;
```

5. **Variable Naming Rules:**
    - Variable names must begin with a letter (a-z or A-Z), underscore (_), or dollar sign ($).
    - Subsequent characters can be letters, digits (0-9), underscores, or dollar signs.
    - Variable names are case-sensitive.
    - Java keywords cannot be used as variable names.
6. **Variable Initialization:**
    - It's good practice to initialize variables before using them to avoid unexpected behavior.
    - Instance variables (variables declared outside methods) are automatically initialized with default values (0, false, null) if not explicitly initialized.

Example:

```java
public class VariableExample {
    public static void main(String[] args) {
        // Variable declaration
        int age;
        double salary;
        String name;

        // Variable initialization
        age = 30;
        salary = 50000.50;
        name = "John Doe";

        // Printing variable values
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
        System.out.println("Salary: $" + salary);
    }
}

```

***
## Operators

### Arithmetic Operators:

- Used for basic mathematical operations.
- Examples:
```java
int a = 10;
int b = 5;
int sum = a + b;        // Addition
int difference = a - b; // Subtraction
int product = a * b;    // Multiplication
int quotient = a / b;   // Division
int remainder = a % b;  // Modulus
```

### Relational Operators:

- Used to compare values and produce boolean results.
- Examples:
```java
int x = 10;
int y = 5;
boolean isEqual = (x == y);  // Equal to
boolean isNotEqual = (x != y); // Not equal to
boolean isGreaterThan = (x > y); // Greater than
boolean isLessThan = (x < y);    // Less than
boolean isGreaterOrEqual = (x >= y); // Greater than or equal to
boolean isLessOrEqual = (x <= y);   // Less than or equal to
```

### Logical Operators:

- Used to perform logical operations.
- Examples:
```java
boolean p = true;
boolean q = false;
boolean andResult = (p && q); // Logical AND
boolean orResult = (p || q);  // Logical OR
boolean notResult = !p;       // Logical NOT
```

### Assignment Operators:

- Used to assign values to variables.
- Examples:
```java
int x = 10;
int y = 5;
x += y; // Equivalent to x = x + y;
y -= x; // Equivalent to y = y - x;
```

### Increment and Decrement Operators:

- Used to increase or decrease the value of a variable by 1.
- Examples:
```java
int count = 0;
count++; // Increment count by 1 (post-increment)
++count; // Increment count by 1 (pre-increment)
count--; // Decrement count by 1 (post-decrement)
--count; // Decrement count by 1 (pre-decrement)
```

#### Post-increment (i++):

- In post-increment, the current value of the variable is used first, and then the value is incremented.
- The increment takes place after the value is used in the expression.
- Example:
```java
int x = 5;
int y = x++; // y = 5, x = 6 (value of x is used, then incremented)
```

#### Pre-increment (++i):

- In pre-increment, the value of the variable is incremented first, and then the updated value is used.
- The increment takes place before the value is used in the expression.
- Example:
```java
int a = 5;
int b = ++a; // b = 6, a = 6 (value of a is incremented first, then used)
```
    
### Conditional Operator (Ternary Operator):

- Used to make a decision based on a condition.
- Example:
```java
int a = 10;
int b = 5;
int max = (a > b) ? a : b; // If a is greater than b, max = a; otherwise, max = b;
```

***

## Type Casting (Conversion)

Type casting in Java refers to the process of converting a variable from one data type to another. There are two types of type casting in Java: implicit (automatic) casting and explicit (manual) casting.

### Implicit Casting:

- Implicit casting occurs when you assign a value of a smaller data type to a variable of a larger data type.
- Java performs implicit casting automatically, as it involves no loss of information.
- For example:
 ```java
 int numInt = 10;
double numDouble = numInt; // Implicit casting from int to double
```
    

### Explicit Casting:

- Explicit casting is required when you assign a value of a larger data type to a variable of a smaller data type.
- Java requires explicit casting because it may result in loss of information (precision or magnitude).
- Syntax: `(target_type) value`
- For example:
```java
double numDouble = 10.5;
int numInt = (int) numDouble; // Explicit casting from double to int
```

### Type Promotion:

- Type promotion is a specific case of implicit casting that occurs during arithmetic operations involving different data types.
- Java automatically promotes smaller data types to larger data types to perform the operation without loss of information.
- For example:
```java
int numInt = 10;
double numDouble = 20.5;
double result = numInt + numDouble; // numInt is implicitly promoted to double
```

### Widening Conversion:

- Widening conversion refers to implicit casting from a smaller data type to a larger data type.
- It occurs when no data loss is involved, so Java performs it automatically.
- Examples: byte → short → int → long → float → double

### Narrowing Conversion:

- Narrowing conversion refers to explicit casting from a larger data type to a smaller data type.
- It may result in loss of information, so explicit casting is required.
- Examples: double → float → long → int → short → byte

***
## Control Flow

Control flow in Java refers to the order in which statements are executed in a program. Java provides various control flow statements that enable you to define the flow of execution based on conditions, loops, and branching.

### 1. Conditional Statements:

Conditional statements allow you to execute code based on whether a condition is true or false.

- **if-else Statement**:

```java
if (condition) {
    // Code to execute if condition is true
} else {
    // Code to execute if condition is false
}
```

- **if-else-if Statement**:

```java
if (condition1) {
    // Code to execute if condition1 is true
} else if (condition2) {
    // Code to execute if condition2 is true
} else {
    // Code to execute if none of the conditions are true
}
```

- **switch Statement**:

```java
switch (expression) {
    case value1:
        // Code to execute if expression equals value1
        break;
    case value2:
        // Code to execute if expression equals value2
        break;
    default:
        // Code to execute if expression doesn't match any case
}
```

### 2. Looping Statements:

Looping statements allow you to execute a block of code repeatedly based on a condition.

- **for Loop**:
```java
for (initialization; condition; update) {
    // Code to execute repeatedly
}
```

- **while Loop**:
```java
while (condition) {
    // Code to execute repeatedly as long as condition is true
}

```

- **do-while Loop**:
```java
do {
    // Code to execute at least once, then repeatedly as long as condition is true
} while (condition);
```

### 3. Branching Statements:

Branching statements allow you to control the flow of execution by transferring control to another part of the program.

##### `break` Statement:

The `break` statement is used to terminate the loop immediately and transfer control to the statement following the loop.

```java
for (int i = 0; i < 10; i++) {
    if (i == 5) {
        break; // Exit the loop when i equals 5
    }
    System.out.println(i);
}
```

In this example, the loop will print numbers from 0 to 4 and then exit when `i` equals 5.

##### `continue` Statement:

The `continue` statement is used to skip the current iteration of the loop and proceed with the next iteration.

```java
for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) {
        continue; // Skip even numbers
    }
    System.out.println(i);
}
```

In this example, the loop will print only odd numbers because the `continue` statement skips even numbers and proceeds with the next iteration.

##### Nested Loops:

Both `break` and `continue` can be used in nested loops. When used in nested loops, `break` and `continue` statements affect only the innermost loop in which they are placed.

```java
outerLoop:
for (int i = 0; i < 5; i++) {
    for (int j = 0; j < 5; j++) {
        if (i * j == 6) {
            break outerLoop; // Exit both loops when i * j equals 6
        }
        System.out.println(i + " * " + j + " = " + (i * j));
    }
}
```

In this example, the `break outerLoop;` statement exits both the inner and outer loops when the condition `i * j == 6` is met.

##### `return` Statement:

###### Purpose:

- **Exiting the Method**: The `return` statement is used to exit a method prematurely. Once a `return` statement is encountered, the method execution stops, and control returns to the caller.

- **Returning a Value**: If the method has a return type other than `void`, the `return` statement is used to return a value of that type to the caller. The returned value can be used by the caller or ignored if not needed.

```java
return; // Used in methods with a void return type (no value returned)
return expression; // Used in methods with a non-void return type, where expression is the value to be returned
```

***
## Strings
### Creating Strings:

- You can create a `String` in Java using string literals or the `String` class constructor.
- Example:
```java
String str1 = "Hello, World!"; // Using string literal
String str2 = new String("Java Programming"); // Using String class constructor
```

### String Length:

- The `length()` method returns the length (number of characters) of the string.
- Example:
```java
int length = str1.length(); // length is 13
```

### String Concatenation:

- Strings can be concatenated using the `+` operator or the `concat()` method.
- Example:
```java
String concatStr = str1 + " " + str2; // "Hello, World! Java Programming"
String concatStr2 = str1.concat(" ").concat(str2); // Same result as above
```

### String Comparison:

- You can compare strings using the `equals()` method for content comparison and `compareTo()` method for lexicographical comparison.
- Example:
```java
boolean isEqual = str1.equals(str2); // false
int compareResult = str1.compareTo(str2); // Result depends on lexicographical order
```

### Substring:

- The `substring()` method returns a new string that is a substring of the original string.
- Example:
```java
String subStr = str1.substring(0, 5); // "Hello"
```

### Case Conversion:

- You can convert the case of a string using `toUpperCase()` and `toLowerCase()` methods.
- Example:
```java
String upperCaseStr = str1.toUpperCase(); // "HELLO, WORLD!"
String lowerCaseStr = str2.toLowerCase(); // "java programming"
```

### Searching and Indexing:

- Methods like `charAt()`, `indexOf()`, and `lastIndexOf()` help in searching and retrieving characters or substrings within a string.
- Example:
```java
char firstChar = str1.charAt(0); // 'H'
int index = str1.indexOf('o'); // Index of 'o' in str1 (returns 4)
int lastIndex = str1.lastIndexOf('o'); // Last index of 'o' in str1 (returns 8)
```

### Removing Whitespace:

- The `trim()` method removes leading and trailing whitespace from the string.
- Example:
```java
String strWithSpaces = "  Java Programming  ";
String trimmedStr = strWithSpaces.trim(); // "Java Programming"
```

### String Formatting:

- Java provides the `format()` method (from `String` class) and `printf()` method (from `PrintStream` and `PrintWriter` classes) for string formatting.
- Example:
```java
String formattedStr = String.format("Value: %d, Text: %s", 10, "Hello"); // "Value: 10, Text: Hello"
System.out.printf("Value: %d, Text: %s%n", 20, "World"); // Output: "Value: 20, Text: World"
```

#### Format Specifiers

1. **%s**: String Placeholder
    - `%s` is used to insert a string value.
    - Example: `String.format("Name: %s", name);`
2. **%d**: Decimal Integer Placeholder
    - `%d` is used to insert integer values.
    - Example: `String.format("Age: %d", age);`
3. **%f**: Floating Point Placeholder
    - `%f` is used to insert floating-point values.
    - Example: `String.format("Price: %.2f", price);`
4. **%c**: Character Placeholder
    - `%c` is used to insert a single character.
    - Example: `String.format("First letter: %c", firstLetter);`
5. **%b**: Boolean Placeholder
    - `%b` is used to insert boolean values.
    - Example: `String.format("Is valid: %b", isValid);`
6. **%n**: Line Separator
    - `%n` is used to insert the platform-specific line separator (newline character).
    - Example: `String.format("Line 1%nLine 2");`
7. **%%**: Literal %% Sign
    - `%%` is used to insert a literal % sign.
    - Example: `String.format("Value: %d%%", percentage);`
8. **Width and Precision**: You can also specify width and precision for numeric placeholders. For example, `%10s` specifies a minimum width of 10 characters for strings, and `%.2f` specifies two decimal places for floating-point numbers.

### `StringBuilder`

`StringBuilder` is a class in Java that provides an efficient way to manipulate strings. It is similar to `StringBuffer`, but `StringBuilder` is not synchronized, making it faster in single-threaded scenarios where thread safety is not a concern.

Here's how you can use `StringBuilder`:

1. **Initialization**:
   You can create a `StringBuilder` object using its default constructor or by passing an initial string as an argument.

   ```java
   StringBuilder sb = new StringBuilder(); // Empty StringBuilder
   StringBuilder sb = new StringBuilder("Initial String"); // StringBuilder with initial content
   ```

2. **Appending**:
   You can append various types of data to a `StringBuilder` using the `append()` method. This method converts the data to a string and adds it to the end of the current sequence.

   ```java
   StringBuilder sb = new StringBuilder();
   sb.append("Hello");
   sb.append("World");
   sb.append(123);
   ```

3. **Inserting**:
   You can insert data at a specific position in the `StringBuilder` using the `insert()` method.

   ```java
   StringBuilder sb = new StringBuilder("Hello");
   sb.insert(5, " ");
   sb.insert(6, "World");
   ```

4. **Deleting**:
   You can delete characters from the `StringBuilder` using the `delete()` method.

   ```java
   StringBuilder sb = new StringBuilder("HelloWorld");
   sb.delete(5, 10); // Deletes "World"
   ```

5. **Replacing**:
   You can replace characters in the `StringBuilder` using the `replace()` method.

   ```java
   StringBuilder sb = new StringBuilder("HelloWorld");
   sb.replace(5, 10, "Java"); // Replaces "World" with "Java"
   ```

6. **Converting to String**:
   You can convert a `StringBuilder` to a `String` using the `toString()` method.

   ```java
   StringBuilder sb = new StringBuilder("Hello");
   String result = sb.toString(); // Converts StringBuilder to String
   ```

`StringBuilder` is mutable, meaning you can modify its contents without creating a new object each time. It is particularly useful when you need to concatenate or modify strings frequently, as it avoids the overhead of creating multiple `String` objects. Use `StringBuilder` when you need mutable string manipulation in a single-threaded environment. If you require thread safety, consider using `StringBuffer`.

***

## Arrays

### Declaring Arrays:

- Arrays are declared using square brackets `[]`.
- Example:
```java
// Declaring an array of integers
int[] numbers;

// Initializing an array with size 5
numbers = new int[5];

// Declaring and initializing an array in one line
int[] numbers = new int[]{1, 2, 3, 4, 5};
```

### Accessing Array Elements:

- Array elements are accessed using zero-based indexing.
- Example:
```java
int[] numbers = {10, 20, 30, 40, 50};
int firstElement = numbers[0]; // Accessing the first element (10)
int thirdElement = numbers[2]; // Accessing the third element (30)
```

### Array Length:

- The `length` property returns the length (number of elements) of the array.
- Example:
```java
int[] numbers = {1, 2, 3, 4, 5};
int length = numbers.length; // length is 5
```
### Array Methods:

1. **`Arrays.copyOf(T[] original, int newLength)`**:
    * Function Prototype: `public static <T> T[] copyOf(T[] original, int newLength)`
    * Functionality: Copies the specified array, truncating or padding with nulls (if necessary) to obtain the specified length.
    * Return Value: Returns a new array containing the copied elements.
2. **`Arrays.toString(T[] array)`**:
    * Function Prototype: `public static String toString(Object[] array)`
    * Functionality: Returns a string representation of the contents of the specified array.
    * Return Value: Returns a string representation of the array.
3. **`Arrays.sort(T[] array)`**:
    * Function Prototype: `public static <T> void sort(T[] array)`
    * Functionality: Sorts the specified array into ascending order, according to the natural ordering of its elements.
    * Return Value: Returns void.
4. **`Arrays.binarySearch(T[] array, T key)`****:
    * Function Prototype: `public static <T> int binarySearch(T[] array, T key)`
    * Functionality: Searches the specified array for the specified object using the binary search algorithm.
    * Return Value: Returns the index of the search key, if it is contained in the array; otherwise, returns a negative number.
5. **`Arrays.equals(T[] array1, T[] array2)`**:
    * Function Prototype: `public static <T> boolean equals(T[] array1, T[] array2)`
    * Functionality: Returns true if the two specified arrays of objects are equal to one another.
    * Return Value: Returns true if the arrays are equal; otherwise, returns false.
6. **`Arrays.fill(T[] array, T value)`**:
    * Function Prototype: `public static <T> void fill(T[] array, T value)`
    * Functionality: Assigns the specified value to each element of the specified array.
    * Return Value: Returns void.
7. **`Arrays.asList(T... array)`**:
    * Function Prototype: `public static <T> List<T> asList(T... array)`
    * Functionality: Returns a fixed-size list backed by the specified array.
    * Return Value: Returns a List interface backed by the array.
8. **`Arrays.stream(T[] array)`**:
    * Function Prototype: `public static <T> Stream<T> stream(T[] array)`
    * Functionality: Returns a sequential Stream with the elements of the specified array as its source.
    * Return Value: Returns a Stream interface representing the elements of the array.
9. **`Arrays.parallelSort(T[] array)`**:
    * Function Prototype: `public static <T> void parallelSort(T[] array)`
    * Functionality: Sorts the specified array into ascending order, according to the natural ordering of its elements, using parallel sort.
    * Return Value: Returns void.
10. **`Arrays.copyOfRange(T[] original, int from, int to)`**:
    * Function Prototype: `public static <T> T[] copyOfRange(T[] original, int from, int to)`
    * Functionality: Copies the specified range of the specified array.
    * Return Value: Returns a new array containing the copied elements.

These additional array methods provide more functionality for manipulation, conversion, and stream processing of arrays in Java. They are commonly used in various scenarios to efficiently work with arrays and collections.

**Example Usage:**

```java
import java.util.Arrays;

public class ArrayExample {
    public static void main(String[] args) {
        int[] arr1 = {1, 2, 3, 4, 5};
        int[] arr2 = {1, 2, 3, 4, 5};

        // equals method
        boolean isEqual = Arrays.equals(arr1, arr2);

        // copyOf method
        int[] copiedArray = Arrays.copyOf(arr1, 3);

        // toString method
        String arrayString = Arrays.toString(arr1);

        // sort method
        Arrays.sort(arr1);

        // binarySearch method
        int index = Arrays.binarySearch(arr1, 3);
    }
}
```

### Iterating Arrays

#### Traditional for Loop:

```java
int[] numbers = {1, 2, 3, 4, 5};

for (int i = 0; i < numbers.length; i++) {
    System.out.println(numbers[i]);
}
```

#### Enhanced for Loop (for-each Loop):

```java
String[] names = {"Alice", "Bob", "Charlie"};

for (String name : names) {
    System.out.println(name);
}
```

In the for-each loop:

- `name` represents the current element in the array `names`.
- The loop automatically iterates over each element of the array.

#### Using Streams (Java 8 and later):

```java
import java.util.Arrays;

int[] numbers = {1, 2, 3, 4, 5};

Arrays.stream(numbers).forEach(System.out::println);
```

Here, `Arrays.stream(numbers)` converts the array `numbers` into a stream, and `forEach()` iterates over each element of the stream, printing it to the console.

***

## Functions/Methods

In Java, methods are a fundamental concept used to define behavior within classes. They encapsulate functionality and allow for code reuse.

### 1. Method Declaration:

A method declaration consists of several components:

- **Access Modifier**: Specifies the visibility of the method (e.g., `public`, `private`, `protected`, or default).
- **Return Type**: Specifies the data type of the value returned by the method (`void` if the method does not return a value).
- **Method Name**: Specifies the name of the method.
- **Parameters**: Specifies the input values passed to the method (optional).
- **Method Body**: Contains the statements that define the behavior of the method.

```java
public returnType methodName(parameter1Type parameter1, parameter2Type parameter2, ...) {
    // Method body
}
```

### 2. Method Signature:

A method's signature consists of its name and parameter types. The return type is not part of the signature.


### 3. Method Invocation:

You invoke a method by calling its name followed by parentheses `()`. If the method requires arguments, you pass them within the parentheses.

```java
MyClass obj = new MyClass();
int sum = obj.add(3, 5);
```

### 4. Return Statement:

The `return` statement is used to exit a method and optionally return a value. If the method has a return type other than `void`, it must return a value of that type.

```java
public int add(int a, int b) {
    return a + b;
}
```

### 5. Void Methods:

Methods with a `void` return type do not return a value. They are used to perform actions or operations without returning anything.

```java
public void displayMessage() {
    System.out.println("Hello, World!");
}
```

### 6. Method Overloading:

Java supports method overloading, which means you can define multiple methods with the same name but different parameter lists within the same class. The compiler determines which method to call based on the arguments provided.

#### Example of Method Overloading:

```java
public class MathUtils {
    // Method to add two integers
    public static int add(int a, int b) {
        return a + b;
    }

    // Method to add two doubles
    public static double add(double a, double b) {
        return a + b;
    }
}
```

#### Calling Overloaded Methods:

```java
public class Main {
    public static void main(String[] args) {
        // Call the add method with integers
        int sumInt = MathUtils.add(5, 3);
        System.out.println("Sum (int): " + sumInt); // Output: Sum (int): 8

        // Call the add method with doubles
        double sumDouble = MathUtils.add(2.5, 3.5);
        System.out.println("Sum (double): " + sumDouble); // Output: Sum (double): 6.0
    }
}
```

### 7. Static Methods:

Static methods belong to the class rather than an instance of the class. They can be invoked using the class name without creating an object.

```java
public class MyClass {
    public static int add(int a, int b) {
        return a + b;
    }
}
```

### 8. Access Modifiers:

Java provides access modifiers to control the accessibility of methods. They include `public`, `private`, `protected`, and default (no modifier).

### 9. Recursion:

A method can call itself, a concept known as recursion. Recursion is useful for solving problems that can be broken down into smaller, similar subproblems.

```java
public class Fibonacci {

    // Recursive method to calculate the nth Fibonacci number
    public static int fibonacci(int n) {
        // Base case: Return 0 for fibonacci(0) and 1 for fibonacci(1)
        if (n == 0) {
            return 0;
        } else if (n == 1) {
            return 1;
        }
        // Recursive case: Calculate fibonacci(n) as the sum of fibonacci(n-1) and fibonacci(n-2)
        else {
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
    }

    public static void main(String[] args) {
        int n = 10; // Calculate the 10th Fibonacci number
        int result = fibonacci(n);
        System.out.println("The " + n + "th Fibonacci number is: " + result);
    }
}
```

Explanation:

- In the `fibonacci` method, we have a base case for `n = 0` and `n = 1`, as the Fibonacci sequence starts with 0 and 1.
- For `n > 1`, we use recursion to calculate `fibon/acci(n)` as the sum of `fibonacci(n-1)` and `fibonacci(n-2)`.
- In the `main` method, we call `fibonacci(10)` to calculate the 10th Fibonacci number and print the result.

***

## Passing Primitive Types vs Reference Type Parameters

In Java, when you pass parameters to methods, whether they are primitive types or reference types, the behavior differs slightly. Understanding these differences is crucial for writing efficient and effective Java code.

### 1. Passing Primitive Type Parameters:

When you pass a primitive type parameter to a method, you're passing a copy of the value stored in the variable. Changes made to the parameter inside the method do not affect the original variable outside the method.

#### Example:

```java
public class Main {
    public static void main(String[] args) {
        int num = 10;
        modifyPrimitive(num);
        System.out.println(num); // Output: 10
    }

    public static void modifyPrimitive(int value) {
        value = 20; // Changes are local to the method
    }
}
```

### 2. Passing Reference Type Parameters:

When you pass a reference type (object) parameter to a method, you're passing a copy of the reference to the object, not the object itself. This means that changes made to the object's state inside the method are reflected in the original object outside the method.

#### Example:

```java
class MyClass {
    int num;
    
    MyClass(int num) {
        this.num = num;
    }
}

public class Main {
    public static void main(String[] args) {
        MyClass obj = new MyClass(10);
        modifyReference(obj);
        System.out.println(obj.num); // Output: 20
    }

    public static void modifyReference(MyClass obj) {
        obj.num = 20; // Changes are reflected in the original object
    }
}
```

**Key Points:**

- Primitive type parameters are passed by value, meaning changes made to them inside the method are local and do not affect the original variable.
- Reference type parameters are passed by reference, meaning changes made to the object's state inside the method affect the original object outside the method.

***

## Error and Exception Handling

Error and exception handling is a crucial aspect of Java programming, allowing developers to anticipate and manage unexpected situations that may occur during program execution.

### 1. **Errors vs. Exceptions:**

- **Errors:** Represent serious, unrecoverable issues that typically occur at runtime and are beyond the control of the application. Examples include `OutOfMemoryError` and `StackOverflowError`.
- **Exceptions:** Represent exceptional conditions that can be anticipated and handled by the application. Exceptions are subclasses of the `Exception` class and its subclasses like `RuntimeException`.

### 2. **Java Exception Hierarchy:**

- Java exceptions are organized into a hierarchy with the `Throwable` class at the top.
- `Throwable` has two main subclasses: `Error` and `Exception`.
- `Exception` further divides into checked exceptions (subclass of `Exception` excluding `RuntimeException`) and unchecked exceptions (`RuntimeException` and its subclasses).

### 3. **Exception Handling Constructs:**

- **try-catch Block:**
```java
try {
    // Code that may throw an exception
} catch (ExceptionType1 ex1) {
    // Handling for ExceptionType1
} catch (ExceptionType2 ex2) {
    // Handling for ExceptionType2
} finally {
    // Optional block, executed regardless of whether an exception occurs or not
}
```

- **throw Statement:** Used to explicitly throw an exception within the code.
```java
throw new SomeException("Error message");
```

- **throws Clause:** Used in method signature to declare the exceptions that the method might throw.
```java
void method() throws SomeException {
    // Method code
}
```

**Example:**
```java
try {
    int result = divide(10, 0);
    System.out.println("Result: " + result);
} catch (ArithmeticException ex) {
    System.out.println("Error: Division by zero");
} catch (NumberFormatException ex) {
    System.out.println("Error: Invalid number format");
}

// Function that may throw multiple exceptions
public static int divide(int dividend, int divisor) throws ArithmeticException, NumberFormatException {
    if (divisor == 0) {
        throw new ArithmeticException("Division by zero");
    }
    return dividend / divisor;
}
```

### 4. **Best Practices:**

- **Handle Exceptions Appropriately:**
    - Catch only the exceptions you can handle.
    - Use multiple catch blocks to handle different types of exceptions appropriately.
- **Provide Meaningful Error Messages:**
    - Include relevant information in error messages to aid debugging.
- **Use Finally Block:**
    - Use the `finally` block for resource cleanup (closing files, releasing database connections, etc.).
- **Avoid Catching Throwable:**
    - Avoid catching `Throwable` unless absolutely necessary, as it may include errors like `OutOfMemoryError` that you may not be able to handle.

### 5. **Common Exception Classes:**

- `NullPointerException`
- `ArrayIndexOutOfBoundsException`
- `NumberFormatException`
- `FileNotFoundException`
- `IOException`
- `SQLException`
- `RuntimeException` and its subclasses (e.g., `ArithmeticException`, `IllegalArgumentException`)

### 6. **Custom Exception Handling:**

- Create custom exception classes by extending `Exception` or its subclasses.
- Use custom exceptions to represent application-specific error conditions.

	##### Creating a Custom Exception Class:
	```java
	public class CustomException extends Exception {
	    public CustomException() {
	        super("CustomException occurred");
	    }
	
	    public CustomException(String message) {
	        super(message);
	    }
	}
	```
	
	In the above example:
	
	- We create a class named `CustomException` that extends the `Exception` class.
	- We provide constructors to create instances of `CustomException` with and without a custom error message.
	
	##### Throwing Custom Exceptions:
	
	You can throw instances of your custom exception class using the `throw` keyword.
	
	```java
	public class TestCustomException {
	    public static void main(String[] args) {
	        try {
	            throw new CustomException("This is a custom exception");
	        } catch (CustomException e) {
	            System.out.println(e.getMessage());
	        }
	    }
	}
	```
	
	In the `main` method:
	
	- We throw a new instance of `CustomException` with a custom error message.
	- We catch the `CustomException` and print the error message.
	
	##### Using Custom Exceptions in Methods:
	
	You can define methods that declare custom exceptions in their `throws` clause.
	
	```java
	public class CustomExceptionExample {
	    public void doSomething() throws CustomException {
	        // Some logic that may lead to throwing CustomException
	        throw new CustomException("CustomException occurred in doSomething method");
	    }
	}
```

***

## Input

### Using `Scanner` Class:

The `Scanner` class is a simple and versatile way to accept input from the user.

**Example:**
```java
import java.util.Scanner;

public class InputExample {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter your name: ");
        String name = scanner.nextLine();

        System.out.print("Enter your age: ");
        int age = scanner.nextInt();

        System.out.println("Name: " + name);
        System.out.println("Age: " + age);

        scanner.close(); // Closing the scanner
    }
}
```

1. **`next()`**:
    - Reads the next token (word) from the input.
2. **`nextLine()`**:
    - Reads the entire line from the input.
3. **`nextBoolean()`**:
    - Reads the next token as a boolean value.
4. **`nextByte()`**:
    - Reads the next token as a byte.
5. **`nextShort()`**:
    - Reads the next token as a short.
6. **`nextInt()`**:
    - Reads the next token as an integer.
7. **`nextLong()`**:
    - Reads the next token as a long.
8. **`nextFloat()`**:
    - Reads the next token as a float.
9. **`nextDouble()`**:
    - Reads the next token as a double.
10. **`nextBigInteger()`**:
    - Reads the next token as a `BigInteger`.
11. **`nextBigDecimal()`**:
    - Reads the next token as a `BigDecimal`.
### Using `BufferedReader`, `InputStreamReader`, and `FileReader`:

This method is typically used when you need to read input character by character or when you want to read input from sources other than the console.

**Input From User Example:**

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class InputExample {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        System.out.print("Enter your name: ");
        String name = reader.readLine();

        System.out.print("Enter your age: ");
        int age = Integer.parseInt(reader.readLine());

        System.out.println("Name: " + name);
        System.out.println("Age: " + age);

        reader.close(); // Closing the BufferedReader
    }
}
```

**Input From File Example:**

```java
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class ReadFileExample {
    public static void main(String[] args) {
        String fileName = "example.txt"; // Name of the file to read

        try (BufferedReader reader = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = reader.readLine()) != null) {
                // Process each line of the file here
                System.out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

1. **`read()`**:
    - Reads a single character.
2. **`read(char[] cbuf)`**:
    - Reads characters into an array.
3. **`readLine()`**:
    - Reads a line of text. Returns `null` if the end of the stream has been reached.
4. **`lines()`**:
    - Returns a stream of lines from the BufferedReader.

### Using Command-Line Arguments:

You can pass arguments to your Java program from the command line when invoking it.

**Example:**

```java
public class CommandLineArgsExample {
    public static void main(String[] args) {
        String name = args[0];
        int age = Integer.parseInt(args[1]);

        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
    }
}
```

Invocation:

`java CommandLineArgsExample John 25`

***

## Output

### Output to Console
#### Using `System.out.println()`:

This method prints the string representation of the given argument to the console and moves the cursor to the next line.

```java
System.out.println("Hello, World!");
```

#### Using `System.out.print()`:

This method prints the string representation of the given argument to the console without moving the cursor to the next line.

```java
System.out.print("Hello, ");
System.out.print("World!");
```

#### Using `System.out.printf()`:

This method allows you to format and print data to the console using format specifiers.

```java
int intValue = 10;
double doubleValue = 3.14159;
String stringValue = "Java";

// Printing integers and strings
System.out.printf("Integer: %d, Double: %f, String: %s%n", intValue, doubleValue, stringValue);

// Specifying width and precision
System.out.printf("Double with width and precision: %8.2f%n", doubleValue);

// Formatting date/time
System.out.printf("Current time: %tT%n", System.currentTimeMillis());

// Formatting boolean values
boolean isJavaCool = true;
System.out.printf("Is Java cool? %b%n", isJavaCool);

// Thousands separator
int number = 1234567;
System.out.printf("Number with thousands separator: %,d%n", number);
```

**Output:**

```s
Integer: 10, Double: 3.141590, String: Java
Double with width and precision:     3.14
Current time: 18:15:02
Is Java cool? true
Number with thousands separator: 1,234,567
```

#### Using `PrintStream`:

You can create a `PrintStream` object and use its methods to print data to the console.

```java
import java.io.PrintStream;

PrintStream ps = new PrintStream(System.out);
ps.println("Hello, World!");
ps.print("This is a "); 
ps.println("test message."); 
ps.printf("Value: %d\n", 10);
```

### Output to File

#### Using `FileOutputStream`:

This class is used to write raw bytes to a file.

```java
import java.io.FileOutputStream; 
import java.io.IOException;

try (FileOutputStream fos = new FileOutputStream("output.txt")) {
    String data = "Hello, World!";
    byte[] bytes = data.getBytes();
    fos.write(bytes);
} catch (IOException e) {
    e.printStackTrace();
}
```

#### Using `FileWriter`:

This class is used to write character data to a file.

```java
import java.io.FileWriter;
import java.io.IOException;

try (FileWriter writer = new FileWriter("output.txt")) {
    writer.write("Hello, World!");
} catch (IOException e) {
    e.printStackTrace();
}
```
#### Using `BufferedWriter` with `FileWriter`:

This approach improves performance by buffering data before writing it to the file.

```java
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

try (BufferedWriter writer = new BufferedWriter(new FileWriter("output.txt"))) {
    writer.write("Hello, World!");
} catch (IOException e) {
    e.printStackTrace();
}
```

#### Using `PrintWriter`:

This class allows you to write formatted text to a file.

```java
import java.io.PrintWriter;
import java.io.FileNotFoundException;

try (PrintWriter writer = new PrintWriter("output.txt")) {
    writer.println("Hello, World!");
} catch (FileNotFoundException e) {
    e.printStackTrace();
}
```

### Notes:

- In all examples, the file named `"output.txt"` is created or overwritten in the current directory.
- Use try-with-resources statement (`try (...) {...}`) to automatically close the resources after use.
- `FileOutputStream`, `FileWriter`, and `BufferedWriter` are low-level classes, while `PrintWriter` provides higher-level abstractions.
- The `Files` class provides convenient methods for file operations introduced in Java 7.
- Make sure to handle `IOException` properly to deal with potential errors during file output operations.

***

## Enumerations (`enum`)
  
In Java, enums (enumerations) are a special type that consists of a fixed set of constants. Enums provide a way to define a collection of related constants as a data type.

### 1. Declaring Enums:

To declare an enum, you use the `enum` keyword followed by the name of the enum type. Inside the enum body, you list the constants separated by commas.

**Syntax:**

```java
enum EnumName {
    CONSTANT1, CONSTANT2, CONSTANT3, ...
}
```

**Example:**

```java
enum Day {
    SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY
}
```

### 2. Accessing Enums:

You can access enum constants using the dot notation (`EnumName.CONSTANT`).

**Example:**

```java
Day today = Day.MONDAY;
System.out.println(today); // Output: MONDAY
```

### 3. Methods in Enums:

Enums can have methods, just like regular classes. You can define behavior associated with each enum constant.

**Example:**

```java
enum Day {
    SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY;

    public boolean isWeekend() {
        return this == SATURDAY || this == SUNDAY;
    }
}
```

### 4. Switch Statements with Enums:

Enums are often used in switch statements for better readability and type safety.

**Example:**

```java
Day today = Day.MONDAY;
switch (today) {
    case MONDAY:
        System.out.println("It's Monday.");
        break;
    case TUESDAY:
        System.out.println("It's Tuesday.");
        break;
    // other cases...
}
```

### 5. Enum Constructors and Fields:

Enums can have constructors and fields, just like regular classes.

**Example:**

```java
enum Planet {
    MERCURY(3.303e+23, 2.4397e6),
    VENUS(4.869e+24, 6.0518e6),
    EARTH(5.976e+24, 6.37814e6);

    private final double mass; // in kilograms
    private final double radius; // in meters

    Planet(double mass, double radius) {
        this.mass = mass;
        this.radius = radius;
    }

    public double getMass() {
        return mass;
    }

    public double getRadius() {
        return radius;
    }
}
```

#### Usage of the Enum:

##### Accessing Enum Constants:

```java
Planet earth = Planet.EARTH;
Planet mercury = Planet.MERCURY;
```

##### Accessing Mass and Radius Properties:

```java
double earthMass = earth.getMass(); // Returns the mass of Earth
double mercuryRadius = mercury.getRadius(); // Returns the radius of Mercury
```

##### Iterating Over Enum Constants:

```java
for (Planet planet : Planet.values()) {
    System.out.println(planet.name() + ": Mass - " + planet.getMass() + " kg, Radius - " + planet.getRadius() + " m");
}
```

##### Using Enums in Switch Statements:

```java
switch (earth) {
    case MERCURY:
        System.out.println("Mercury's mass: " + mercury.getMass() + " kg");
        break;
    case VENUS:
        System.out.println("Venus's radius: " + mercury.getRadius() + " m");
        break;
    case EARTH:
        System.out.println("Earth's mass: " + earth.getMass() + " kg");
        break;
}
```

### 6. Benefits of Enums:

- **Type Safety**: Enums provide type safety, preventing you from using invalid values.
- **Readability**: Enums make your code more readable by providing meaningful names for constants.
- **Maintainability**: Enums make it easier to maintain your code by grouping related constants together.

***

## Passsing Arrays, Enums, and Objects as Parameters

In Java, you can pass various types of parameters to functions, including arrays, enums, objects, and other data types.

### 1. Passing Arrays:

Arrays are passed to functions just like any other data type. You can define a function that takes an array as a parameter, and then you can pass an array to that function.

#### Example:

```java
public void processArray(int[] arr) {
    // Process the array elements
}

public static void main(String[] args) {
    int[] myArray = {1, 2, 3, 4, 5};
    processArray(myArray); // Passing the array to the function
}
```

### 2. Passing Enums:

Enums can be passed as parameters to functions in the same way as other data types. You define the function parameter type as the enum type, and then you can pass an enum constant to that function.

#### Example:

```java
enum Day { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }

public void printDay(Day day) {
    System.out.println("Today is " + day);
}

public static void main(String[] args) {
    printDay(Day.MONDAY); // Passing an enum constant to the function
}
```

### 3. Passing Objects:

Objects of classes can also be passed as parameters to functions. You define the function parameter type as the class type, and then you can pass an object of that class to the function.

#### Example:

```java
class Person {
    String name;
    int age;
    // Constructor, methods, etc.
}

public void displayPerson(Person person) {
    System.out.println("Name: " + person.name + ", Age: " + person.age);
}

public static void main(String[] args) {
    Person myPerson = new Person("John", 30);
    displayPerson(myPerson); // Passing an object to the function
}
```

***

## `final` keyword

The `final` keyword in Java is used to apply restrictions on classes, methods, and variables. It ensures that they cannot be changed or overridden after their initialization.

### 1. Final Variables:

When applied to a variable:

- For primitive data types, it makes the value of the variable immutable.
- For reference data types, it makes the reference immutable, but the state of the object it refers to can still be changed.

**Example:**

```java
final int MAX_VALUE = 100;
final String NAME = "John";
```

### 2. Final Methods:

When applied to a method:

- It prevents the method from being overridden by subclasses.

**Example:**

```java
class Parent {
    final void display() {
        System.out.println("Parent's display method");
    }
}

class Child extends Parent {
    // This will cause a compilation error
    // void display() { }
}
```

### 3. Final Classes:

When applied to a class:

- It prevents the class from being subclassed.

**Example:**

```java
final class FinalClass {
    // Class definition
}
```

### 4. Final Arguments:

When applied to method parameters:

- It ensures that the value of the parameter cannot be modified within the method.

**Example:**

```java
void printMessage(final String message) {
    // Cannot reassign message: message = "New Message"; // Compilation error
    System.out.println(message);
}
```

### 5. Final Fields:

When applied to class fields:

- It makes the fields immutable after initialization.
- If the field is a reference to an object, it prevents the reference from being changed to point to another object.

**Example:**

```java
class MyClass {
    final int value = 10; // Immutable field
    final List<String> list = new ArrayList<>(); // Reference is final, but contents can be modified
}
```

**Benefits of Using `final`:**

1. **Immutable State**: Helps in creating immutable objects, enhancing thread safety and preventing unintended modifications.
2. **Method Safety**: Ensures that critical methods cannot be overridden, maintaining expected behavior.
3. **Class Integrity**: Secures class hierarchies by preventing inheritance or subclassing where not intended.
4. **Code Clarity**: Communicates intent clearly to other developers by indicating that the element should not be modified.

## Command Line Arguments

You can pass command-line arguments to a Java program when you run it from the command line. These arguments allow you to customize the behavior of your program without modifying its source code. Here's how you can access command-line arguments in a Java program:

1. **Accessing Command-Line Arguments**:
    * Command-line arguments are passed to the `main` method of your Java program as an array of strings.
    * You can access these arguments using the `args` parameter of the `main` method.
2. **Syntax**:
    
    ```java
public class MyClass {
	public static void main(String[] args) {
		// Access and process command-line arguments
		// args is an array containing the command-line arguments
	}
}
    ```
    
3. **Example**: Suppose you have a Java program called `MyProgram.java` that expects two command-line arguments: `name` and `age`. You can run the program and pass these arguments as follows:
    
```
java MyProgram John 30
```
    
    In this example, `John` and `30` are the command-line arguments.
    
4. **Accessing Command-Line Arguments**: Inside the `main` method, you can access the command-line arguments through the `args` array:
    
    ```java
    public static void main(String[] args) {
        // Access command-line arguments
        String name = args[0]; // Access the first argument
        int age = Integer.parseInt(args[1]); // Access the second argument and convert it to an integer
        System.out.println("Name: " + name);
        System.out.println("Age: " + age);
    }
    ```
    
5. **Handling Array Bounds**:
    
    * Remember to handle array bounds carefully, especially if the number of expected arguments may vary. Always check the length of the `args` array before accessing its elements to avoid `ArrayIndexOutOfBoundsException`.
6. **Passing Command-Line Arguments with Spaces**:
    
    * If an argument contains spaces, enclose it in double quotes. For example:
```arduino
java MyProgram "John Doe" 30
```

By using command-line arguments, you can make your Java programs more flexible and configurable, allowing users to provide input or specify options when running the program from the command line.

***

# Object-Oriented Programming

## Classes and Objects

1. **Classes:**

- **Definition**: A class is a blueprint or template for creating objects. It defines the properties (fields) and behaviors (methods) that objects of that class will have.

- **Syntax**:
```java
public class ClassName {
    // Fields (variables)
    // Constructors
    // Methods
}
```

- **Example**:
```java
public class Car {
    // Fields
    String brand;
    String model;
    int year;

    // Constructor
    public Car(String brand, String model, int year) {
        this.brand = brand;
        this.model = model;
        this.year = year;
    }

    // Method
    public void displayInfo() {
        System.out.println("Brand: " + brand);
        System.out.println("Model: " + model);
        System.out.println("Year: " + year);
    }
}
```


2. **Objects:**

- **Definition**: An object is an instance of a class. It represents a specific entity with its own state (values of fields) and behavior (methods).

- **Instantiation**: To create an object of a class, you use the `new` keyword followed by the class constructor.

- **Example**:
```java
public class Main {
    public static void main(String[] args) {
        // Create objects of the Car class
        Car car1 = new Car("Toyota", "Camry", 2022);
        Car car2 = new Car("Honda", "Accord", 2021);

        // Access fields and methods of objects
        car1.displayInfo();
        car2.displayInfo();
    }
}
```


In the example above:

- We define a `Car` class with fields (brand, model, year), a constructor to initialize objects, and a method `displayInfo()` to print information about the car.
- In the `Main` class, we create two `Car` objects (`car1` and `car2`) using the `new` keyword and the class constructor.
- We then call the `displayInfo()` method on each object to print their information.

***

## `instanceof` Keyword

In Java, the `instanceof` operator is used to test whether an object is an instance of a particular class or interface. It also checks whether an object is an instance of a class that is a subclass of a specified class. Here's a detailed explanation of the `instanceof` operator:

**Syntax:**

```java
object instanceof ClassName
```

- `object`: The object whose type is to be checked.
- `ClassName`: The class or interface to be tested against.

**Usage:**

- The `instanceof` operator returns `true` if the object on the left-hand side is an instance of the class or interface on the right-hand side.
- If the object is not an instance of the specified class or interface, it returns `false`.
- It also returns `false` if the object is `null`.

**Example:**

```java
class Animal {}

class Dog extends Animal {}

class Cat extends Animal {}

public class Main {
    public static void main(String[] args) {
        Animal animal = new Dog();
        
        // Check if 'animal' is an instance of Animal class
        System.out.println(animal instanceof Animal); // true
        
        // Check if 'animal' is an instance of Dog class
        System.out.println(animal instanceof Dog); // true
        
        // Check if 'animal' is an instance of Cat class
        System.out.println(animal instanceof Cat); // false
    }
}
```

In the example above, `animal instanceof Animal` returns `true` because `animal` is an instance of the `Animal` class. Similarly, `animal instanceof Dog` returns `true` because `animal` is an instance of the `Dog` class. However, `animal instanceof Cat` returns `false` because `animal` is not an instance of the `Cat` class.

**Use Cases:**

- **Type Checking**: `instanceof` is commonly used to determine the type of an object before performing type-specific operations.
- **Downcasting**: It is often used in downcasting to check if an object is an instance of a particular subclass before casting it.

**Note:**

- Overuse of `instanceof` can indicate a flaw in the design of your program, as it can lead to tight coupling and violate principles of object-oriented design.
- In many cases, polymorphism and proper class hierarchy design can eliminate the need for excessive use of `instanceof`.


***

## Fields

In Java, fields represent the data members of a class, defining the state of objects created from that class. They can have different access levels and can be declared as static or non-static

### Access Levels:

- Java provides four access levels (modifiers) to restrict the visibility of classes, methods, and fields:
    1. **private**: Accessible only within the same class.
    2. **default (no modifier)**: Accessible within the same package.
    3. **protected**: Accessible within the same package and by subclasses (even if they are in different packages).
    4. **public**: Accessible from any other class.
- **Example**:
```java
public class Car {
    private String brand; // Private access level
    int year; // Default access level

    // Constructor, methods
}
```


### Static vs. Non-Static Fields:

- **Static Fields (Class Variables)**:
    - Belongs to the class itself rather than to instances of the class.
    - Only one copy of a static field exists, shared by all instances of the class.
    - Accessed using the class name, not through object references.
- **Non-Static Fields (Instance Variables)**:
    - Each instance of the class has its own copy of non-static fields.
    - Accessed using object references (`this` keyword).

**Static Field Example**:

```java
public class Car {
    private static int numberOfCars; // Static field
    private String brand; // Non-static field

    // Constructor, methods
}
```

**Static Field Example 2:** 

```java
public class MyClass {
    // Static field
    private static int count = 0;

    // Constructor
    public MyClass() {
        count++; // Increment the static field on each object creation
    }

    // Static method to access the static field
    public static int getCount() {
        return count;
    }
}

public class Main {
    public static void main(String[] args) {
        // Accessing the static field directly using the class name
        System.out.println("Initial count: " + MyClass.getCount());

        // Creating objects of MyClass
        MyClass obj1 = new MyClass();
        MyClass obj2 = new MyClass();
        MyClass obj3 = new MyClass();

        // Accessing the static field after object creations
        System.out.println("Count after object creations: " + MyClass.getCount());

        // Modifying the static field directly (not recommended)
        MyClass.count = 100;

        // Accessing the static field after modification
        System.out.println("Count after direct modification: " + MyClass.getCount());
    }
}
```

**Best Practices:**

- Encapsulate fields using accessors (getters) and mutators (setters) to control access and maintain data integrity.
- Use appropriate access levels to balance encapsulation and flexibility.
- Limit the use of static fields to shared data that applies to all instances of the class.
- Prefer non-static fields for instance-specific data.

***

## Setter and Getter Methods

Setter and getter methods, also known as accessor and mutator methods, are used to access and modify the private fields of a class, respectively. They facilitate encapsulation by providing controlled access to the class's data. Here's how they are typically implemented in Java:

**Setter Methods:**

Setter methods are used to set the values of private fields within a class.

```java
public class MyClass {
    private int myField;

    // Setter method for myField
    public void setMyField(int newValue) {
        myField = newValue;
    }
}
```

**Getter Methods:**

Getter methods are used to retrieve the values of private fields from a class.

```java
public class MyClass {
    private int myField;

    // Getter method for myField
    public int getMyField() {
        return myField;
    }
}
```

**Example Usage:**

Here's how you would use setter and getter methods:

```java
public class Main {
    public static void main(String[] args) {
        MyClass obj = new MyClass();

        // Set the value of myField using the setter method
        obj.setMyField(10);

        // Get the value of myField using the getter method
        int value = obj.getMyField();
        System.out.println("Value of myField: " + value);
    }
}
```

**Benefits of Setter and Getter Methods:**

1. **Encapsulation**: They hide the internal state of an object and provide controlled access to it.
2. **Data Validation**: Setter methods can enforce validation rules before assigning values to fields.
3. **Flexibility**: They allow for changes to the internal representation of data without affecting the external interface.
4. **Readability**: They improve code readability by providing a consistent way to access and modify fields.

**Best Practices:**

1. Use descriptive names for setter and getter methods that clearly indicate the purpose of the operation.
2. Follow the JavaBeans naming convention for setter and getter methods (e.g., `setPropertyName` and `getPropertyName`).
3. Ensure that setter and getter methods do not have side effects beyond setting or getting the value of a field.

***

## Constructors

In Java, constructors are special methods used for initializing objects of a class. They have the same name as the class and are invoked automatically when an object of the class is created using the `new` keyword. Here's a detailed explanation of constructors in Java:

1. **Purpose of Constructors:**

- Constructors initialize the state of objects by assigning initial values to instance variables.
- They are invoked automatically when an object is created.
- Constructors ensure that objects are in a valid state upon creation.

2. **Types of Constructors:**

**a. Default Constructor:**

- If a class does not explicitly define any constructors, Java provides a default constructor.
- The default constructor initializes instance variables to default values (0, null, false, etc.).
- It has no parameters.

**b. Parameterized Constructor:**

- A parameterized constructor is explicitly defined by the programmer.
- It accepts parameters to initialize instance variables with specified values.
- Allows for different ways of creating objects with various initial states.

3. **Constructor Syntax:**

```java
public class ClassName {
    // Instance variables

    // Default constructor
    public ClassName() {
        // Initialization code
    }

    // Parameterized constructor
    public ClassName(Type1 parameter1, Type2 parameter2, ...) {
        // Initialization code using parameters
    }
}
```

4. **Constructor Overloading:**

- Like methods, constructors can be overloaded, allowing multiple constructors with different parameter lists in the same class.
- Overloaded constructors provide flexibility in object initialization.

**Example of Constructors:**

```java
public class Car {
    private String brand;
    private String model;
    private int year;

    // Default constructor
    public Car() {
        brand = "Unknown";
        model = "Unknown";
        year = 0;
    }

    // Parameterized constructor
    public Car(String brand, String model, int year) {
        this.brand = brand;
        this.model = model;
        this.year = year;
    }

    // Getter and setter methods
}
```

**Using Constructors:**

```java
public class Main {
    public static void main(String[] args) {
        // Create objects using constructors
        Car car1 = new Car(); // Default constructor
        Car car2 = new Car("Toyota", "Camry", 2022); // Parameterized constructor

        // Access fields of objects
        System.out.println("Car 1: " + car1.getBrand() + " " + car1.getModel() + " " + car1.getYear());
        System.out.println("Car 2: " + car2.getBrand() + " " + car2.getModel() + " " + car2.getYear());
    }
}
```

**Benefits of Constructors:**

- Ensure that objects are initialized properly.
- Provide a clean and standardized way to create objects.
- Support different initialization scenarios through constructor overloading.


***

## Abstract Classes and Methods

In Java, abstract classes and methods are used to define blueprints for other classes to inherit from and implement. Here's a breakdown of abstract classes and methods:

### Abstract Classes:

- An abstract class is a class that cannot be instantiated directly. It serves as a template for other classes.
- Abstract classes may contain both abstract and non-abstract methods.
- Abstract classes can have constructors, fields, and regular methods.
- A class can extend only one abstract class, but it can implement multiple interfaces.
- To declare an abstract class, use the `abstract` keyword before the class declaration.

**Syntax:**

```java
public abstract class AbstractClass {
    // Abstract methods, regular methods, fields, constructors, etc.
}
```

**Example:**

```java
public abstract class Shape {
    // Abstract method to calculate area
    public abstract double calculateArea();

    // Regular method
    public void display() {
        System.out.println("This is a shape.");
    }
}
```

### Abstract Methods:

- An abstract method is a method declared without an implementation.
- Abstract methods are declared using the `abstract` keyword and do not have a method body.
- Abstract methods must be implemented by concrete (non-abstract) subclasses.
- Abstract methods are used to define a protocol or contract that concrete subclasses must adhere to.

**Syntax:**

```java
public abstract returnType methodName(parameterList);
```

**Example:**

```java
public abstract class Animal {
    // Abstract method to make the animal sound
    public abstract void makeSound();
}
```

### Implementing Abstract Classes and Methods:

To use an abstract class, you must extend it and provide implementations for all its abstract methods. If a subclass fails to provide implementations for all abstract methods, it must also be declared as abstract.

**Example:**

```java
public class Circle extends Shape {
    private double radius;

    // Constructor
    public Circle(double radius) {
        this.radius = radius;
    }

    // Implementing the abstract method to calculate area
    @Override
    public double calculateArea() {
        return Math.PI * radius * radius;
    }
}
```

**Benefits of Abstract Classes and Methods:**

1. **Code Reusability**: Abstract classes allow you to define common functionality once and reuse it across multiple subclasses.
2. **Polymorphism**: Abstract classes and methods facilitate polymorphism, allowing different subclasses to be treated uniformly through common interfaces.
3. **Enforce Structure**: Abstract classes and methods help enforce a consistent structure and behavior across related classes.

***

## Inheritance

Inheritance is a fundamental concept in object-oriented programming (OOP) that allows a class to inherit properties and behaviors (methods) from another class, known as the superclass or parent class. Here's a detailed explanation of inheritance in Java:

1. **Superclass and Subclass:**

- **Superclass**: Also known as the parent class or base class, a superclass is the class from which properties and behaviors are inherited.
- **Subclass**: Also known as the child class or derived class, a subclass is a class that inherits properties and behaviors from a superclass.

2. **Syntax of Inheritance:**

```java
class Superclass {
    // Superclass members (fields and methods)
}

class Subclass extends Superclass {
    // Subclass members (fields and methods)
}
```

- The `extends` keyword is used to indicate that a class inherits from another class.

3. **Access Modifiers and Inheritance:**

- In Java, the access modifiers (`public`, `protected`, default, and `private`) control the visibility of fields, methods, and constructors in both superclass and subclass.
- Subclasses inherit all accessible members of the superclass, except for `private` members, which are not accessible in subclasses.

4. **Constructors in Inheritance:**

- Constructors are not inherited by subclasses but are invoked implicitly or explicitly during the creation of subclass objects.
- If a superclass has parameterized constructors, the subclass must invoke one of them using the `super()` keyword in its constructor.

5. **Method Overriding:**

- Subclasses can provide their own implementation of a method that is already defined in the superclass. This is known as method overriding.
- Method overriding allows for runtime polymorphism, where the method to be executed is determined at runtime based on the object type.

6. **`super` Keyword:**

- The `super` keyword is used to refer to the superclass's members (fields, methods, and constructors) from within the subclass.
- It is also used to explicitly call the superclass's constructor from the subclass constructor.

**Example of Inheritance:**

```java
class Animal {
    protected String name;

    public Animal(String name) {
        this.name = name;
    }

    public void eat() {
        System.out.println(name + " is eating.");
    }
}

class Dog extends Animal {
    public Dog(String name) {
        super(name);
    }

    public void bark() {
        System.out.println(name + " is barking.");
    }
}

public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog("Buddy");
        dog.eat(); // Inherited from Animal
        dog.bark(); // Specific to Dog
    }
}
```

***

## `super` Keyword

In Java, the `super` keyword is a reference variable that is used to refer to the immediate parent class object. It is primarily used to differentiate between superclass members and subclass members that have the same name.

### 1. Accessing Superclass Members:

- In a subclass, you can use the `super` keyword to access members (fields, methods, and constructors) of the superclass.
- If a subclass has overridden a method from its superclass, you can use `super` to invoke the superclass's method.

### 2. Invoking Superclass Constructors:

- In a subclass constructor, the `super()` statement is used to call the constructor of the superclass.
- If a superclass constructor with arguments is called, it must be explicitly invoked using `super(arguments)`.

### 3. Using `super` for Method Invocation:

- When a method is invoked using `super.methodName()`, Java searches for the method in the superclass.
- It allows you to explicitly call the superclass implementation of a method that has been overridden in the subclass.

**Example of `super` Keyword Usage:**

```java
class Animal {
    String name;

    Animal(String name) {
        this.name = name;
    }

    void display() {
        System.out.println("I am an animal.");
    }
}

class Dog extends Animal {
    String breed;

    Dog(String name, String breed) {
        super(name); // Call superclass constructor
        this.breed = breed;
    }

    void display() {
        super.display(); // Call superclass method
        System.out.println("I am a " + breed + " dog.");
    }
}

public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog("Buddy", "Golden Retriever");
        dog.display();
    }
}
```

In the above example:

- The `Animal` class has a constructor and a method `display()`.
- The `Dog` class extends `Animal` and has its constructor.
- In the `Dog` constructor, `super(name)` calls the superclass constructor.
- In the `display()` method of `Dog`, `super.display()` calls the superclass method.

**Key Points:**

- `super` keyword can be used to access superclass members and invoke superclass constructors.
- It is especially useful when dealing with method overriding and constructor chaining in inheritance hierarchies.
- `super()` must be the first statement in a subclass constructor if used to call a superclass constructor.

***

## `this` Keyword

In Java, the `this` keyword is a reference to the current object within an instance method or constructor. It can be used to refer to instance variables, call other constructors in the same class, or pass the current object as a parameter to other methods. Here's a breakdown of its usage:

### 1. Referring to Instance Variables:

The `this` keyword is used to differentiate between local variables and instance variables when they have the same name. It helps in accessing or modifying instance variables within methods or constructors.

```java
public class MyClass {
    private int x;

    public void setX(int x) {
        this.x = x; // Refers to the instance variable x
    }
}
```

### 2. Calling Other Constructors:

The `this` keyword can be used to call other constructors in the same class. This is particularly useful for constructor chaining, where one constructor calls another to initialize the object.

```java
public class MyClass {
    private int x;

    public MyClass() {
        this(0); // Calls the parameterized constructor
    }

    public MyClass(int x) {
        this.x = x;
    }
}
```

### 3. Passing the Current Object as a Parameter:

The `this` keyword can be passed as an argument to another method. This is useful for passing the current object's reference to other methods, such as event handlers or utility methods.

```java
public class MyClass {
    private int x;

    public void doSomething() {
        HelperClass.process(this); // Passes the current object reference to HelperClass
    }
}
```

### 4. Returning the Current Object:

Methods can return the current object using the `this` keyword. This allows for method chaining, where multiple method calls can be chained together in a single statement.

```java
public class MyClass {
    private int x;

    public MyClass setX(int x) {
        this.x = x;
        return this; // Returns the current object
    }
}
```

**Benefits of Using `this`:**

- **Clarity**: It helps in distinguishing between instance variables and local variables within methods or constructors.
- **Constructor Chaining**: Allows constructors to call other constructors in the same class, reducing code duplication.
- **Method Chaining**: Enables fluent interfaces and concise method chaining by returning the current object.

***

# Language

## Generics

Generics in Java provide a way to create classes, interfaces, and methods that operate on objects of various types while providing compile-time type safety. Let me break it down for you with an analogy:

### Generics in Classes

**Analogy: Tupperware Containers**

Imagine you have a set of containers, but instead of being labeled for specific types of food, they are labeled with a generic term like "Food Container." These containers can hold any type of food: fruits, vegetables, or even leftovers. This flexibility allows you to store different types of food without worrying about mixing them up or causing a mess in your refrigerator.

**Java Generics Explanation:**

1. **Type Safety**: Generics ensure type safety by allowing you to specify the type of objects that a collection or class can contain or operate on. This prevents runtime errors like ClassCastException by catching type mismatches at compile time.

2. **Reusability and Flexibility**: With generics, you can create classes, interfaces, and methods that can work with any data type. This makes your code more reusable and adaptable to different scenarios.

3. **Compile-Time Checking**: When you use generics, the compiler performs type checking at compile time to ensure type compatibility, which helps in identifying errors early in the development process.


**Example: Generic Box Class**

Let's create a generic `Box` class that can hold objects of any type:

```java
public class Box<T> {
    private T item;

    public void setItem(T item) {
        this.item = item;
    }

    public T getItem() {
        return item;
    }
}
```

In this example:

- `T` is a placeholder for the type of object the `Box` will hold.
- You can create a `Box` of any type by specifying the type within angle brackets (`<>`).
- The `setItem` and `getItem` methods can work with objects of type `T`.

**Usage:**

```java
public class Main {
    public static void main(String[] args) {
        // Create a Box for String
        Box<String> stringBox = new Box<>();
        stringBox.setItem("Hello, Generics!");

        // Create a Box for Integer
        Box<Integer> integerBox = new Box<>();
        integerBox.setItem(123);

        // Retrieve items
        String message = stringBox.getItem();
        int number = integerBox.getItem();

        System.out.println(message);
        System.out.println(number);
    }
}
```

**Output:**

`Hello, Generics! 123`

### Generic Methods

Generic methods in Java allow you to write methods that can work with any data type. They provide flexibility and type safety similar to generic classes. Let's use an analogy to understand generic methods:

**Analogy: Universal Tool**

Imagine you have a universal tool that can adapt to different tasks based on the object it operates on. For example, if you hand it a screw, it behaves like a screwdriver; if you hand it a nail, it functions like a hammer. This tool remains versatile and adaptable, making it useful in various situations without the need for specialized tools.

**Java Generic Methods Explanation:**

1. **Type Parameter**: Like generic classes, generic methods introduce a type parameter, denoted by angle brackets (`<T>`), which represents the type of data the method will operate on.

2. **Method Flexibility**: Generic methods can work with any data type, allowing you to write reusable code that adapts to different scenarios without sacrificing type safety.

3. **Type Inference**: In many cases, Java's compiler can infer the type parameter based on the arguments passed to the method, reducing the need for explicit type declarations.


**Example: Generic Utility Method**

Let's create a generic utility method that compares two objects of the same type and returns the maximum of the two:

```java
public class GenericMethodExample {
    public static <T extends Comparable<T>> T maximum(T x, T y) {
        return x.compareTo(y) > 0 ? x : y;
    }
}
```

In this example:

- `<T extends Comparable<T>>` denotes that the type parameter `T` must implement the `Comparable` interface, ensuring that the objects passed to the method can be compared.
- The method `maximum` takes two parameters of type `T` and returns the maximum of the two based on their natural ordering.

**Usage:**

```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Maximum of 10 and 20: " + GenericMethodExample.maximum(10, 20));
        System.out.println("Maximum of 'hello' and 'world': " + GenericMethodExample.maximum("hello", "world"));
    }
}
```

**Output:**

```arduino
Maximum of 10 and 20: 20
Maximum of 'hello' and 'world': world
```

In this example, the `maximum` method is generic, allowing it to compare and return the maximum of two objects of any comparable type. Just like the universal tool in our analogy, generic methods in Java provide a versatile approach to writing methods that can handle various data types safely and efficiently.

***

## Interfaces

An interface in Java is a reference type that defines a set of method signatures without providing the implementation. Classes that implement interfaces promise to provide the implementation for all methods declared in the interface.

**Implementing Interfaces:**

To implement an interface in Java, a class uses the `implements` keyword followed by the interface's name. The class must provide concrete implementations for all methods declared in the interface.

**Example:**

Let's say we have an interface called `Shape`:

```java
public interface Shape {
    double area();
    double perimeter();
}
```

Now, let's implement this interface in two classes: `Circle` and `Rectangle`:

```java
public class Circle implements Shape {
    private double radius;

    public Circle(double radius) {
        this.radius = radius;
    }

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }

    @Override
    public double perimeter() {
        return 2 * Math.PI * radius;
    }
}

public class Rectangle implements Shape {
    private double width;
    private double height;

    public Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public double area() {
        return width * height;
    }

    @Override
    public double perimeter() {
        return 2 * (width + height);
    }
}
```

In the above example:

- Both `Circle` and `Rectangle` classes implement the `Shape` interface.
- They provide their own implementations for the `area()` and `perimeter()` methods declared in the `Shape` interface.
- The `@Override` annotation indicates that the methods in the implementing classes override the methods declared in the interface.

**Usage:**

```java
public class Main {
    public static void main(String[] args) {
        Shape circle = new Circle(5);
        Shape rectangle = new Rectangle(4, 6);

        System.out.println("Circle Area: " + circle.area());
        System.out.println("Circle Perimeter: " + circle.perimeter());

        System.out.println("Rectangle Area: " + rectangle.area());
        System.out.println("Rectangle Perimeter: " + rectangle.perimeter());
    }
}
```

**Output:**

```mathematica
Circle Area: 78.53981633974483
Circle Perimeter: 31.41592653589793
Rectangle Area: 24.0
Rectangle Perimeter: 20.0
```

In this example, `Circle` and `Rectangle` classes provide their own implementations for the `Shape` interface, allowing them to calculate area and perimeter differently based on their shapes. This illustrates how Java types can implement interfaces to provide specific behaviors defined by those interfaces.

***

## List

In Java, a `List` is an interface that extends the `Collection` interface. It represents an ordered collection of elements that allows duplicate elements. Lists are one of the most commonly used data structures in Java due to their flexibility and the variety of operations they support.

Key Characteristics of Lists:

1. **Ordered Collection**: Lists maintain the order of elements as they are inserted.
2. **Allows Duplicates**: Lists can contain duplicate elements.
3. **Indexed Access**: Elements in a list can be accessed by their index.
4. **Dynamic Size**: Lists can grow or shrink dynamically as elements are added or removed.
5. **Implementations**: Java provides several implementations of the `List` interface, such as `ArrayList`, `LinkedList`, and `Vector`.

***

## ArrayList

`ArrayList` is one of the most commonly used implementations of the `List` interface in Java. It is part of the `java.util` package and provides dynamic arrays that can grow or shrink in size dynamically.

Key Features of ArrayList:

1. **Dynamic Size**: ArrayLists can dynamically resize themselves as elements are added or removed.
2. **Random Access**: Elements in an ArrayList can be accessed using their index, providing O(1) time complexity for retrieval.
3. **Allows Duplicates**: ArrayLists can contain duplicate elements.
4. **Not Synchronized**: ArrayLists are not synchronized, meaning they are not thread-safe by default.
5. **Resizable Array**: Internally, an ArrayList uses an array to store elements, and when the capacity of the array is exceeded, it automatically grows by allocating a new array and copying elements.

### ArrayList Methods:

### 1. `add(E element)`:

Adds the specified element to the end of the ArrayList.

```java
ArrayList<Integer> numbers = new ArrayList<>();
numbers.add(10);
numbers.add(20);
numbers.add(30);
```

### 2. `get(int index)`:

Returns the element at the specified index in the ArrayList.

```java
int firstElement = numbers.get(0); // Returns 10
```

### 3. `remove(int index)`:

Removes the element at the specified index from the ArrayList.

```java
int firstElement = numbers.get(0); // Returns 10
```

### 4. `size()`:

Returns the number of elements in the ArrayList.

```java
int size = numbers.size(); // Returns the size of the ArrayList
```

### 5. `isEmpty()`:

Returns `true` if the ArrayList is empty; otherwise, returns `false`.

```java
boolean empty = numbers.isEmpty(); // Returns false if ArrayList is not empty
```

### 6. `contains(Object o)`:

Returns `true` if the ArrayList contains the specified element; otherwise, returns `false`.

```java
boolean contains = numbers.contains(20); // Returns true if 20 is in the ArrayList
```

### 7. `set(int index, E element)`:

Replaces the element at the specified index in the ArrayList with the specified element.

```java
numbers.set(0, 100); // Replaces the element at index 0 with 100
```

### 8. `clear()`:

Removes all elements from the ArrayList.

```java
numbers.clear(); // Removes all elements from the ArrayList
```

### 9. `addAll(Collection<? extends E> c)`:

Adds all the elements of the specified collection `c` to the end of the ArrayList.

```java
ArrayList<Integer> numbers = new ArrayList<>();
ArrayList<Integer> additionalNumbers = new ArrayList<>();
additionalNumbers.add(40);
additionalNumbers.add(50);
numbers.addAll(additionalNumbers); // Adds all elements from additionalNumbers to numbers
```

### 10. `remove(Object o)`:

Removes the first occurrence of the specified element from the ArrayList, if it is present.

```java
numbers.remove(Integer.valueOf(40)); // Removes the element 40 from the ArrayList
```
### 11. `indexOf(Object o)`:

Returns the index of the first occurrence of the specified element in the ArrayList, or -1 if the element is not found.

```java
int lastIndex = numbers.lastIndexOf(50); // Returns the last index of element 50 in the ArrayList
```

### 12. `lastIndexOf(Object o)`:

Returns the index of the last occurrence of the specified element in the ArrayList, or -1 if the element is not found.

```java
int lastIndex = numbers.lastIndexOf(50); // Returns the last index of element 50 in the ArrayList
```

### 13. `toArray()`:

Returns an array containing all the elements in the ArrayList.

```java
Object[] array = numbers.toArray(); // Converts the ArrayList to an array
```

### 14. `subList(int fromIndex, int toIndex)`:

Returns a view of the portion of the ArrayList between the specified `fromIndex` (inclusive) and `toIndex` (exclusive).

```java
List<Integer> sublist = numbers.subList(0, 2); // Returns elements from index 0 to 1
```

### 15. `equals(Object o)`:

Compares the specified object with the ArrayList for equality.

```java
ArrayList<Integer> anotherList = new ArrayList<>();
anotherList.add(10);
anotherList.add(20);
boolean isEqual = numbers.equals(anotherList); // Returns true if both lists are equal
```

### 16. `containsAll(Collection<?> c)`:

Returns `true` if the ArrayList contains all the elements of the specified collection `c`.

```java
ArrayList<Integer> testList = new ArrayList<>();
testList.add(10);
testList.add(20);
boolean containsAll = numbers.containsAll(testList); // Returns true if numbers contains all elements of testList
```

### 17. `addAll(int index, Collection<? extends E> c)`:

Adds all the elements of the specified collection `c` starting from the specified index in the ArrayList.

```java
ArrayList<Integer> additionalNumbers = new ArrayList<>();
additionalNumbers.add(40);
additionalNumbers.add(50);
numbers.addAll(2, additionalNumbers); // Adds elements from additionalNumbers starting at index 2
```

### 18. `removeAll(Collection<?> c)`:

```java
ArrayList<Integer> toRemove = new ArrayList<>();
toRemove.add(40);
toRemove.add(50);
numbers.removeAll(toRemove); // Removes elements 40 and 50 from the ArrayList
```

### 18. `trimToSize()`:

Trims the capacity of an ArrayList instance to be the list's current size.

```java
numbers.trimToSize());
```

### When to Use ArrayList:

- Use ArrayList when you need a dynamically resizable array-like structure that allows efficient random access to elements.
- ArrayList is suitable for situations where you frequently add or remove elements, and the order of elements matters.

### Limitations of ArrayList:

- ArrayLists are not synchronized, so they are not thread-safe for concurrent access.
- Inserting or removing elements in the middle of an ArrayList can be inefficient, as it requires shifting elements to maintain the order.

***

## LinkedList

The `LinkedList` class in Java implements the `List` interface and represents a doubly linked list. Unlike arrays, linked lists do not store elements in contiguous memory locations. Instead, each element in a linked list is stored in a separate node, and each node contains a reference to the next and previous nodes in the sequence.

**Key Features of LinkedList:**

1. **Dynamic Size**: LinkedLists can grow or shrink dynamically as elements are added or removed.
2. **Sequential Access**: Elements in a LinkedList are accessed sequentially, as each element contains a reference to the next and previous elements.
3. **Insertion and Deletion**: Insertion and deletion operations are efficient in LinkedLists, especially in the middle of the list, as they involve updating references.
4. **Not Synchronized**: LinkedLists are not synchronized, meaning they are not thread-safe by default.

**Example Usage of LinkedList:**

```java
import java.util.LinkedList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        // Creating a LinkedList of strings
        List<String> names = new LinkedList<>();

        // Adding elements to the LinkedList
        names.add("Alice");
        names.add("Bob");
        names.add("Charlie");

        // Accessing elements by index
        String firstElement = names.get(0); // "Alice"

        // Removing an element by index
        names.remove(1); // Removes the element at index 1

        // Iterating through the LinkedList
        for (String name : names) {
            System.out.println(name);
        }
    }
}
```

**When to Use LinkedList:**

- Use LinkedList when you frequently need to insert or delete elements in the middle of the list, as it provides efficient insertion and deletion operations.
- LinkedList is suitable for scenarios where you need to maintain a sequence of elements and the order of elements matters.

**Limitations of LinkedList:**

- LinkedLists have slower random access time compared to ArrayLists, as accessing elements by index requires traversing the list from the beginning or end.
- LinkedLists consume more memory per element compared to ArrayLists, as each element in a LinkedList requires additional memory for maintaining references.

**Methods Common to Both ArrayList and LinkedList:**

1. `add(E element)`: Adds the specified element to the end of the list.
2. `add(int index, E element)`: Inserts the specified element at the specified position in the list.
3. `get(int index)`: Returns the element at the specified index in the list.
4. `set(int index, E element)`: Replaces the element at the specified position in the list with the specified element.
5. `remove(int index)`: Removes the element at the specified index from the list.
6. `size()`: Returns the number of elements in the list.
7. `isEmpty()`: Returns `true` if the list is empty; otherwise, returns `false`.
8. `contains(Object o)`: Returns `true` if the list contains the specified element; otherwise, returns `false`.
9. `indexOf(Object o)`: Returns the index of the first occurrence of the specified element in the list, or -1 if the element is not found.
10. `lastIndexOf(Object o)`: Returns the index of the last occurrence of the specified element in the list, or -1 if the element is not found.
11. `clear()`: Removes all elements from the list.

**Methods Present in ArrayList But Not in LinkedList:**

1. `trimToSize()`: Trims the capacity of the ArrayList instance to be the list's current size.
2. `ensureCapacity(int minCapacity)`: Increases the capacity of the ArrayList instance, if necessary, to ensure that it can hold at least the number of elements specified by the minimum capacity argument.

**Methods Present in LinkedList But Not in ArrayList:**

### 1. `offer(E e)`:

Adds the specified element as the tail (last element) of the deque (LinkedList) if it is possible to do so immediately without violating capacity restrictions.

```java
LinkedList<Integer> linkedList = new LinkedList<>();
linkedList.offer(10); // Adds 10 to the end of the LinkedList
```

### 2. `offerFirst(E e)`:

Inserts the specified element at the front (head) of the deque (LinkedList) if it is possible to do so immediately without violating capacity restrictions.

```java
linkedList.offerFirst(5); // Inserts 5 at the beginning of the LinkedList
```

### 3. `offerLast(E e)`:

Inserts the specified element at the end (tail) of the deque (LinkedList) if it is possible to do so immediately without violating capacity restrictions.

```java
linkedList.offerLast(15); // Inserts 15 at the end of the LinkedList
```

### 4. `poll()`:

Retrieves and removes the head (first element) of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer firstElement = linkedList.poll(); // Retrieves and removes the first element
```

### 5. `pollFirst()`:

Retrieves and removes the first element of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer firstElement = linkedList.pollFirst(); // Retrieves and removes the first element
```

### 6. `pollLast()`:

Retrieves and removes the last element of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer lastElement = linkedList.pollLast(); // Retrieves and removes the last element
```

### 7. `peek()`:

Retrieves, but does not remove, the head (first element) of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer firstElement = linkedList.peek(); // Retrieves the first element without removing it
```

### 8. `peekFirst()`:

Retrieves, but does not remove, the first element of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer firstElement = linkedList.peekFirst(); // Retrieves the first element without removing it
```

### 9. `peekLast()`:

Retrieves, but does not remove, the last element of the deque (LinkedList), or returns null if the deque is empty.

```java
Integer lastElement = linkedList.peekLast(); // Retrieves the last element without removing it
```

### 10. `removeFirst()`

Removes and returns the first element from the list.

```java
Integer lastElement = linkedList.removeLast(); // Removes and returns the last element
```

### 11. `removeLast()`

Removes and returns the last element from the list.

```java
boolean removed = linkedList.removeFirstOccurrence(10); // Removes the first occurrence of 10
```

### 12. `removeFirstOccurrence(Object o)`

Removes the first occurrence of the specified element from the list, if it is present.

`boolean removed = linkedList.removeFirstOccurrence(10); // Removes the first occurrence of 10`

### 13. `removeLastOccurrence(Object o)`

Removes the last occurrence of the specified element from the list, if it is present.

```java
boolean removed = linkedList.removeLastOccurrence(10); // Removes the last occurrence of 10
```

### 14. `addLast(E e)`

Adds the specified element as the tail (last element) of the list.

```java
linkedList.addLast(20); // Adds 20 to the end of the list
```

***

## Array vs ArrayList vs LinkedList

**Array:**

- **Fixed Size**: Arrays have a fixed size, which means you need to know the size of the array when you declare it.
- **Fast Access**: Arrays provide fast random access to elements by index.
- **Static Data Structure**: Once created, the size of an array cannot be changed.
- **Efficient Memory Usage**: Arrays generally consume less memory than ArrayList or LinkedList since they don't require additional overhead.

Use Arrays when:

- You have a fixed number of elements.
- You need fast random access to elements by index.
- Memory usage is a concern and the size of the collection is known in advance.

**ArrayList:**

- **Dynamic Size**: ArrayLists can grow or shrink dynamically as elements are added or removed.
- **Fast Random Access**: ArrayList provides fast random access to elements by index.
- **Backed by Array**: Internally, ArrayLists use arrays to store elements, allowing for efficient random access.
- **More Memory Overhead**: ArrayLists have more memory overhead compared to arrays due to additional bookkeeping information.

Use ArrayList when:

- You need a dynamic collection that can grow or shrink.
- Random access to elements by index is important.
- You don't need to frequently insert or remove elements from the middle of the collection.

**LinkedList:**

- **Dynamic Size**: LinkedLists can grow or shrink dynamically as elements are added or removed.
- **Efficient Insertion and Deletion**: LinkedLists provide efficient insertion and deletion operations, especially in the middle of the list.
- **No Random Access**: LinkedLists don't provide efficient random access to elements by index compared to arrays and ArrayLists.
- **Memory Overhead**: LinkedLists have more memory overhead compared to arrays and ArrayLists due to each element being stored in a separate node.

Use LinkedList when:

- You need frequent insertion or deletion operations, especially in the middle of the list.
- Random access to elements by index is not a requirement.
- Memory usage is not a critical concern, and the benefits of efficient insertion and deletion outweigh the memory overhead.

**Summary:**

- Use Arrays for fixed-size collections with fast random access.
- Use ArrayList when you need a dynamic collection with fast random access and don't frequently insert or remove elements from the middle.
- Use LinkedList when you need efficient insertion and deletion operations, especially in the middle of the list, and random access is not important.

***

## Passing Lists to Methods

In Java, you can pass ArrayLists or LinkedLists as parameters to methods just like any other object.

### Passing ArrayList as a Parameter:

```java
import java.util.ArrayList;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        ArrayList<Integer> numbers = new ArrayList<>();
        numbers.add(1);
        numbers.add(2);
        numbers.add(3);
        
        processArrayList(numbers);
    }

    public static void processArrayList(ArrayList<Integer> list) {
        // Process the ArrayList here
        for (Integer num : list) {
            System.out.println(num);
        }
    }
}
```

### Passing LinkedList as a Parameter:

```java
import java.util.LinkedList;

public class Main {
    public static void main(String[] args) {
        LinkedList<String> names = new LinkedList<>();
        names.add("Alice");
        names.add("Bob");
        names.add("Charlie");
        
        processLinkedList(names);
    }

    public static void processLinkedList(LinkedList<String> list) {
        // Process the LinkedList here
        for (String name : list) {
            System.out.println(name);
        }
    }
}
```

### Passing List Interface as a Parameter:

You can also pass the `List` interface as a parameter, which allows you to accept any implementation of the List interface, including ArrayList and LinkedList.

```java
import java.util.List;

public class Main {
    public static void main(String[] args) {
        ArrayList<Integer> numbers = new ArrayList<>();
        numbers.add(1);
        numbers.add(2);
        numbers.add(3);
        
        processList(numbers);
    }

    public static void processList(List<Integer> list) {
        // Process the List here
        for (Integer num : list) {
            System.out.println(num);
        }
    }
}
```

Passing the List interface as a parameter provides flexibility because you can switch between ArrayList and LinkedList implementations without changing the method signature. This is an example of programming to an interface rather than to an implementation, which is a good practice in Java programming.

## HashMap

A `HashMap` is a fundamental data structure in computer science used for storing key-value pairs. Think of it like a dictionary in the real world, where you have words (keys) and their corresponding definitions (values). 

Here's a breakdown:

- **Key:** Think of the key as the word you want to look up in the dictionary. It's unique and helps you find the associated value quickly.
- **Value:** This is what you get when you look up the key. It's the definition of the word in our dictionary analogy.

Now, imagine you have a massive library with thousands of books. Each book represents a bucket, and each bucket can hold multiple key-value pairs. When you want to look up a word in your dictionary (or `HashMap`), you first calculate its "address" (which bucket it should be in), then go directly to that bucket to find the definition (or value).

In programming, `HashMaps` are incredibly efficient for lookups, insertions, and deletions, especially when you have a large amount of data. They are often used when you need to associate one piece of data with another and require fast access.

In Java, for example, the `HashMap` class is part of the Java Collections Framework and allows you to store key-value pairs. Here's a simple example of how you might use it:

```java
import java.util.HashMap;

public class Main {
    public static void main(String[] args) {
        // Creating a HashMap
        HashMap<String, Integer> ageMap = new HashMap<>();

        // Adding key-value pairs
        ageMap.put("Alice", 30);
        ageMap.put("Bob", 25);
        ageMap.put("Charlie", 40);

        // Accessing values
        System.out.println("Bob's age is: " + ageMap.get("Bob")); // Output: Bob's age is: 25
    }
}
```

Output:
```
Bob's age is: 25
```

Updated information:
In newer versions of Java, starting from Java 8, the `HashMap` class has been enhanced with additional functionalities and optimizations. For example, Java 8 introduced the `computeIfAbsent()` and `forEach()` methods, among others, which provide more convenient ways to work with `HashMaps`. Additionally, Java 9 introduced various improvements related to performance and memory management in `HashMap` implementations.

**Methods**

1. `put(key, value)`: Adds a new key-value pair to the `HashMap`, or updates the value if the key already exists.
   
   ```java
   HashMap<String, Integer> ages = new HashMap<>();
   ages.put("Alice", 30);
   ages.put("Bob", 25);
   ```

2. `get(key)`: Retrieves the value associated with the specified key, or returns `null` if the key is not found.
   
   ```java
   Integer aliceAge = ages.get("Alice"); // returns 30
   ```

3. `containsKey(key)`: Checks if the `HashMap` contains a specific key.
   
   ```java
   boolean containsBob = ages.containsKey("Bob"); // returns true
   ```

4. `containsValue(value)`: Checks if the `HashMap` contains a specific value.
   
   ```java
   boolean containsTwentyFive = ages.containsValue(25); // returns true
   ```

5. `remove(key)`: Removes the key-value pair associated with the specified key from the `HashMap`.
   
   ```java
   ages.remove("Alice");
   ```

6. `size()`: Returns the number of key-value pairs in the `HashMap`.
   
   ```java
   int numberOfEntries = ages.size(); // returns 1
   ```

7. `isEmpty()`: Checks if the `HashMap` is empty.
   
   ```java
   boolean isMapEmpty = ages.isEmpty(); // returns false
   ```

8. `clear()`: Removes all key-value pairs from the `HashMap`.
   
   ```java
   ages.clear();
   ```

9. `keySet()`: Returns a `Set` view of the keys contained in the `HashMap`.
   
   ```java
   Set<String> keys = ages.keySet();
   ```

10. `values()`: Returns a `Collection` view of the values contained in the `HashMap`.
   
    ```java
    Collection<Integer> ageValues = ages.values();
    ```

11. `entrySet()`: Returns a `Set` view of the key-value pairs contained in the `HashMap`.
    
    ```java
    Set<Map.Entry<String, Integer>> entries = ages.entrySet();
    ```

12. `putIfAbsent(key, value)`: Adds a new key-value pair to the `HashMap` only if the key does not already exist.
    
    ```java
    ages.putIfAbsent("Alice", 30); // won't add anything since "Alice" key already exists
    ages.putIfAbsent("Charlie", 40); // will add "Charlie" key with value 40
    ```

13. `replace(key, newValue)`: Replaces the value associated with the specified key with the given new value.
    
    ```java
    ages.replace("Alice", 31); // updates Alice's age to 31
    ```

14. `compute(key, biFunction)`: Computes a new value for the specified key using the given mapping function, or removes the key if the function returns `null`.
    
    ```java
    ages.compute("Alice", (k, v) -> v + 1); // increments Alice's age by 1
    ```

15. `forEach(biConsumer)`: Performs the given action for each key-value pair in the `HashMap`.
    
    ```java
    ages.forEach((k, v) -> System.out.println(k + ": " + v)); // prints each key-value pair
    ```

16. `merge(key, value, remappingFunction)`: Combines the value with the existing value associated with the specified key using the provided remapping function, or adds the key-value pair if the key is not already present.
   
    ```java
    ages.merge("Alice", 1, Integer::sum); // adds 1 to Alice's age
    ```

17. `replaceAll(function)`: Replaces each value in the `HashMap` with the result of applying the given function to the corresponding key-value pair.
   
    ```java
    ages.replaceAll((k, v) -> v + 1); // increments each age by 1
    ```

18. `computeIfAbsent(key, function)`: Computes a new value for the specified key using the given function if the key is not already associated with a value.
    
    ```java
    ages.computeIfAbsent("Charlie", k -> 40); // adds "Charlie" key with value 40 if not present
    ```

19. `computeIfPresent(key, function)`: Computes a new value for the specified key using the given function if the key is already associated with a value.
    
    ```java
    ages.computeIfPresent("Alice", (k, v) -> v + 1); // increments Alice's age by 1 if present
    ```

20. `getOrDefault(key, defaultValue)`: Returns the value associated with the specified key, or a default value if the key is not found.
    
    ```java
    int bobAge = ages.getOrDefault("Bob", 0); // returns Bob's age or 0 if key not found
    ```


## LinkedHashMap

A `LinkedHashMap` is another implementation of the `Map` interface in Java, just like `HashMap`. However, unlike `HashMap`, a `LinkedHashMap` maintains a predictable iteration order. 

Here's a breakdown:

- **Predictable iteration order:** When you iterate over a `LinkedHashMap`, the order in which elements were inserted is preserved. This means that if you insert key-value pairs in a certain order, you can expect to iterate over them in the same order.

- **Linked list:** Internally, a `LinkedHashMap` maintains a doubly-linked list of entries alongside the hash table. This linked list helps maintain the order of insertion and enables faster iteration.

Imagine you have a list of tasks you need to complete, and you want to maintain the order in which you added them. Using a `LinkedHashMap`, you could associate each task with a priority level and easily iterate over them in the order they were added.

In terms of usage, `LinkedHashMap` provides the same methods as `HashMap`, but with the additional guarantee of maintaining insertion order during iteration.

Here's a simple example of how you might use a `LinkedHashMap`:

```java
import java.util.LinkedHashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) {
        // Creating a LinkedHashMap with insertion order preserved
        LinkedHashMap<String, Integer> ages = new LinkedHashMap<>();

        // Adding key-value pairs
        ages.put("Alice", 30);
        ages.put("Bob", 25);
        ages.put("Charlie", 40);

        // Iterating over the entries
        for (Map.Entry<String, Integer> entry : ages.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
    }
}
```

Output:
```
Alice: 30
Bob: 25
Charlie: 40
```

In this example, you can see that the order of insertion is preserved when iterating over the entries of the `LinkedHashMap`. This feature can be useful in scenarios where maintaining insertion order is important, such as implementing a cache or processing tasks in a specific sequence.

Updated information:
In newer versions of Java, the `LinkedHashMap` class remains largely unchanged in terms of its functionality and usage. However, it's important to note that enhancements and optimizations to the Java Collections Framework, introduced in newer Java versions, also benefit `LinkedHashMap` implementations.

## Set

In Java, a `Set` is a collection that does not allow duplicate elements. It models the mathematical concept of a set, and it provides several methods for adding, removing, and querying elements. Java provides several implementations of the `Set` interface, each with its own characteristics and use cases.

Here are some common implementations of the `Set` interface in Java:

1. **HashSet**: 
   - Uses a hash table for storage.
   - Provides constant-time performance for basic operations (add, remove, contains).
   - Does not guarantee the order of its elements.
   - Best suited for general-purpose usage when you don't need to maintain order or have specific performance requirements.

2. **TreeSet**: 
   - Implemented as a red-black tree.
   - Maintains elements in sorted order (ascending by default).
   - Provides logarithmic-time performance for most operations.
   - Suitable for applications requiring sorted sets or when you need to iterate over elements in sorted order.

3. **LinkedHashSet**: 
   - Implemented as a hash table with a linked list running through it.
   - Maintains insertion order of elements, in addition to uniqueness.
   - Provides performance similar to `HashSet` for basic operations.
   - Useful when you need predictable iteration order, along with the benefits of a `HashSet`.

Here's a basic example demonstrating the usage of a `HashSet`:

```java
import java.util.HashSet;
import java.util.Set;

public class Main {
    public static void main(String[] args) {
        // Create a HashSet
        Set<String> set = new HashSet<>();

        // Add elements
        set.add("apple");
        set.add("banana");
        set.add("orange");
        set.add("apple"); // Adding duplicate element

        // Print elements
        System.out.println("Set: " + set);
    }
}
```

Output:
```
Set: [orange, banana, apple]
```

In this example, the `HashSet` automatically removes the duplicate `"apple"` element when added again.

You can choose the appropriate implementation based on your requirements regarding uniqueness, order, and performance characteristics.

### HashSet

In Java, a `HashSet` is an implementation of the `Set` interface that uses a hash table for storage. It does not allow duplicate elements, and it provides constant-time performance for basic operations like adding, removing, and querying elements. Here's an overview of `HashSet`:

- **No Duplicates**: `HashSet` does not allow duplicate elements. If you try to add an element that already exists in the set, the operation will have no effect.

- **Order**: The order of elements in a `HashSet` is not guaranteed. It means that the order in which elements are stored in the set may not be the same as the order in which they were inserted.

- **Performance**: `HashSet` provides constant-time performance (O(1)) for basic operations such as `add`, `remove`, and `contains`. This makes it efficient for storing and retrieving elements, especially when dealing with large collections.

Here's a simple example demonstrating the usage of a `HashSet`:

```java
import java.util.HashSet;
import java.util.Set;

public class Main {
    public static void main(String[] args) {
        // Create a HashSet
        Set<String> set = new HashSet<>();

        // Add elements
        set.add("apple");
        set.add("banana");
        set.add("orange");
        set.add("apple"); // Adding duplicate element

        // Print elements
        System.out.println("Set: " + set);
    }
}
```

Output:
```
Set: [orange, banana, apple]
```

In this example, the `HashSet` automatically removes the duplicate `"apple"` element when added again.

`HashSet` is a versatile and efficient choice for storing unique elements when you do not require specific ordering. It's commonly used in various applications, such as data processing, caching, and implementing set operations.

**Methods**

1. **add(element)**: Adds the specified element to the set if it is not already present.

   ```java
   HashSet<String> set = new HashSet<>();
   set.add("apple");
   set.add("banana");
   ```

2. **remove(element)**: Removes the specified element from the set if it is present.

   ```java
   set.remove("apple");
   ```

3. **contains(element)**: Checks if the set contains the specified element.

   ```java
   boolean containsBanana = set.contains("banana"); // returns true
   ```

4. **size()**: Returns the number of elements in the set.

   ```java
   int setSize = set.size(); // returns 1
   ```

5. **isEmpty()**: Checks if the set is empty.

   ```java
   boolean isSetEmpty = set.isEmpty(); // returns false
   ```

6. **clear()**: Removes all elements from the set.

   ```java
   set.clear();
   ```

7. **iterator()**: Returns an iterator over the elements in the set.

   ```java
   Iterator<String> iterator = set.iterator();
   while (iterator.hasNext()) {
       System.out.println(iterator.next());
   }
   ```

8. **addAll(collection)**: Adds all elements from the specified collection to the set.

   ```java
   Set<String> fruits = new HashSet<>();
   fruits.add("apple");
   fruits.add("banana");
   set.addAll(fruits);
   ```

9. **removeAll(collection)**: Removes all elements from the set that are present in the specified collection.

   ```java
   set.removeAll(fruits);
   ```

10. **retainAll(collection)**: Retains only the elements in the set that are present in the specified collection.

    ```java
    set.retainAll(fruits);
    ```

11. **toArray()**: Returns an array containing all of the elements in the set.

    ```java
    Object[] array = set.toArray();
    ```

12. **toArray(array)**: Returns an array containing all of the elements in the set; the runtime type of the returned array is that of the specified array.

    ```java
    String[] array = new String[set.size()];
    array = set.toArray(array);
    ```

13. **containsAll(collection)**: Checks if the set contains all of the elements in the specified collection.

    ```java
    Set<String> otherSet = new HashSet<>();
    otherSet.add("apple");
    otherSet.add("banana");
    boolean containsAll = set.containsAll(otherSet); // returns true
    ```

14. **iterator()**: Returns an iterator over the elements in the set.

    ```java
    Iterator<String> iterator = set.iterator();
    while (iterator.hasNext()) {
        System.out.println(iterator.next());
    }
    ```

15. **spliterator()**: Creates a late-binding and fail-fast spliterator over the elements in the set.

    ```java
    Spliterator<String> spliterator = set.spliterator();
    ```

16. **stream()**: Returns a sequential stream with the elements of the set as its source.

    ```java
    Stream<String> stream = set.stream();
    ```

### TreeSet

In Java, a `TreeSet` is an implementation of the `SortedSet` interface, which extends the `Set` interface. It uses a self-balancing binary search tree (specifically, a red-black tree) for storage. Here's an overview of `TreeSet`:

- **Sorted Order**: Unlike `HashSet`, a `TreeSet` maintains its elements in sorted order. By default, elements are sorted in natural order (ascending order for numeric types, lexicographic order for strings). You can also provide a custom `Comparator` to define the sorting order.

- **No Duplicates**: Like other `Set` implementations, a `TreeSet` does not allow duplicate elements. If you try to add an element that already exists in the set, the operation will have no effect.

- **Performance**: `TreeSet` provides logarithmic-time performance (O(log n)) for most operations like `add`, `remove`, and `contains`. This makes it efficient for storing and retrieving elements, especially when dealing with large collections.

Here's a simple example demonstrating the usage of a `TreeSet`:

```java
import java.util.TreeSet;
import java.util.Set;

public class Main {
    public static void main(String[] args) {
        // Create a TreeSet
        Set<String> set = new TreeSet<>();

        // Add elements
        set.add("banana");
        set.add("apple");
        set.add("orange");
        set.add("apple"); // Adding duplicate element

        // Print elements
        System.out.println("Set: " + set);
    }
}
```

Output:
```
Set: [apple, banana, orange]
```

In this example, the `TreeSet` automatically sorts the elements in natural order (lexicographic order for strings) and removes the duplicate `"apple"` element when added again.

`TreeSet` is a suitable choice when you need elements to be sorted and uniqueness to be enforced. It's commonly used in applications where sorted sets are required, such as implementing ordered collections, sorted views of data, or managing elements based on a specific order.

**Methods**

1. **add(element)**: Adds the specified element to the set if it is not already present.

   ```java
   TreeSet<String> set = new TreeSet<>();
   set.add("banana");
   set.add("apple");
   ```

2. **remove(element)**: Removes the specified element from the set if it is present.

   ```java
   set.remove("banana");
   ```

3. **contains(element)**: Checks if the set contains the specified element.

   ```java
   boolean containsApple = set.contains("apple"); // returns true
   ```

4. **size()**: Returns the number of elements in the set.

   ```java
   int setSize = set.size(); // returns 1
   ```

5. **isEmpty()**: Checks if the set is empty.

   ```java
   boolean isSetEmpty = set.isEmpty(); // returns false
   ```

6. **clear()**: Removes all elements from the set.

   ```java
   set.clear();
   ```

7. **iterator()**: Returns an iterator over the elements in the set.

   ```java
   Iterator<String> iterator = set.iterator();
   while (iterator.hasNext()) {
       System.out.println(iterator.next());
   }
   ```

8. **first()**: Returns the first (lowest) element currently in the set.

   ```java
   String firstElement = set.first();
   ```

9. **last()**: Returns the last (highest) element currently in the set.

   ```java
   String lastElement = set.last();
   ```

10. **pollFirst()**: Retrieves and removes the first (lowest) element, or returns null if the set is empty.

    ```java
    String firstElement = set.pollFirst();
    ```

11. **pollLast()**: Retrieves and removes the last (highest) element, or returns null if the set is empty.

    ```java
    String lastElement = set.pollLast();
    ```

12. **lower(element)**: Returns the greatest element in the set strictly less than the given element, or null if there is no such element.

    ```java
    String lowerElement = set.lower("banana");
    ```

13. **higher(element)**: Returns the least element in the set strictly greater than the given element, or null if there is no such element.

    ```java
    String higherElement = set.higher("apple");
    ```

14. **floor(element)**: Returns the greatest element in the set less than or equal to the given element, or null if there is no such element.

    ```java
    String floorElement = set.floor("banana");
    ```

15. **ceiling(element)**: Returns the least element in the set greater than or equal to the given element, or null if there is no such element.

    ```java
    String ceilingElement = set.ceiling("apple");
    ```

16. **headSet(toElement)**: Returns a view of the portion of the set strictly less than the specified element.

    ```java
    SortedSet<String> headSet = set.headSet("banana");
    ```

17. **tailSet(fromElement)**: Returns a view of the portion of the set greater than or equal to the specified element.

    ```java
    SortedSet<String> tailSet = set.tailSet("banana");
    ```

18. **subSet(fromElement, toElement)**: Returns a view of the portion of the set between the specified elements.

    ```java
    SortedSet<String> subSet = set.subSet("apple", "orange");
    ```

19. **descendingSet()**: Returns a reverse order view of the elements contained in this set.

    ```java
    NavigableSet<String> descendingSet = set.descendingSet();
    ```

20. **descendingIterator()**: Returns an iterator over the elements in the set in descending order.

    ```java
    Iterator<String> descendingIterator = set.descendingIterator();
    ```

21. **headSet(toElement, inclusive)**: Returns a view of the portion of the set strictly less than (or equal to, if inclusive is true) the specified element.

    ```java
    SortedSet<String> headSet = set.headSet("banana", true);
    ```

22. **tailSet(fromElement, inclusive)**: Returns a view of the portion of the set greater than or equal to (or strictly greater than, if inclusive is false) the specified element.

    ```java
    SortedSet<String> tailSet = set.tailSet("banana", false);
    ```

23. **subSet(fromElement, fromInclusive, toElement, toInclusive)**: Returns a view of the portion of the set between the specified elements, optionally including the specified elements.

    ```java
    SortedSet<String> subSet = set.subSet("apple", true, "orange", false);
    ```

24. **comparator()**: Returns the comparator used to order the elements in this set, or null if this set uses the natural ordering of its elements.

    ```java
    Comparator<String> comparator = set.comparator();
    ```

### LinkedHashedSet

In Java, a `LinkedHashSet` is an implementation of the `Set` interface that combines the features of a `HashSet` and a `LinkedHashMap`. It maintains a linked list of the entries in the set, which provides a predictable iteration order (the order in which elements were inserted) while also ensuring that the set does not contain duplicate elements. Here's an overview of `LinkedHashSet`:

- **Order**: Unlike `HashSet`, a `LinkedHashSet` maintains the order of elements as they were inserted into the set. When iterating over a `LinkedHashSet`, the elements are returned in the same order they were added.

- **No Duplicates**: Similar to other `Set` implementations, a `LinkedHashSet` does not allow duplicate elements. If you try to add an element that already exists in the set, the operation will have no effect.

- **Performance**: `LinkedHashSet` provides constant-time performance (O(1)) for basic operations like `add`, `remove`, and `contains`, assuming a good hash function. Additionally, iteration over the set is guaranteed to be in the order of insertion.

Here's a simple example demonstrating the usage of a `LinkedHashSet`:

```java
import java.util.LinkedHashSet;
import java.util.Set;

public class Main {
    public static void main(String[] args) {
        // Create a LinkedHashSet
        Set<String> set = new LinkedHashSet<>();

        // Add elements
        set.add("banana");
        set.add("apple");
        set.add("orange");
        set.add("apple"); // Adding duplicate element

        // Print elements
        System.out.println("Set: " + set);
    }
}
```

Output:
```
Set: [banana, apple, orange]
```

In this example, the `LinkedHashSet` maintains the order of elements as they were inserted, and it automatically removes the duplicate `"apple"` element when added again.

`LinkedHashSet` is a suitable choice when you need predictable iteration order along with the benefits of a `HashSet`, such as constant-time performance for basic operations and uniqueness enforcement. It's commonly used in applications where the order of elements matters, such as maintaining insertion order or processing elements in a specific sequence.

**Methods**

1. **add(element)**: Adds the specified element to the set if it is not already present.

   ```java
   LinkedHashSet<String> set = new LinkedHashSet<>();
   set.add("banana");
   set.add("apple");
   ```

2. **remove(element)**: Removes the specified element from the set if it is present.

   ```java
   set.remove("banana");
   ```

3. **contains(element)**: Checks if the set contains the specified element.

   ```java
   boolean containsApple = set.contains("apple"); // returns true
   ```

4. **size()**: Returns the number of elements in the set.

   ```java
   int setSize = set.size(); // returns 1
   ```

5. **isEmpty()**: Checks if the set is empty.

   ```java
   boolean isSetEmpty = set.isEmpty(); // returns false
   ```

6. **clear()**: Removes all elements from the set.

   ```java
   set.clear();
   ```

7. **iterator()**: Returns an iterator over the elements in the set.

   ```java
   Iterator<String> iterator = set.iterator();
   while (iterator.hasNext()) {
       System.out.println(iterator.next());
   }
   ```

8. **clone()**: Returns a shallow copy of this `LinkedHashSet` instance.

   ```java
   LinkedHashSet<String> clonedSet = (LinkedHashSet<String>) set.clone();
   ```

9. **toArray()**: Returns an array containing all of the elements in the set.

   ```java
   Object[] array = set.toArray();
   ```

10. **addAll(collection)**: Adds all of the elements in the specified collection to the set.

    ```java
    Set<String> otherSet = new HashSet<>();
    otherSet.add("orange");
    otherSet.add("grape");
    set.addAll(otherSet);
    ```

11. **removeAll(collection)**: Removes from the set all of its elements that are contained in the specified collection.

    ```java
    set.removeAll(otherSet);
    ```

12. **retainAll(collection)**: Retains only the elements in the set that are contained in the specified collection.

    ```java
    set.retainAll(otherSet);
    ```

13. **equals(object)**: Compares the specified object with this set for equality.

    ```java
    boolean isEqual = set.equals(otherSet);
    ```

14. **hashCode()**: Returns the hash code value for this set.

    ```java
    int hashCodeValue = set.hashCode();
    ```

15. **spliterator()**: Creates a late-binding and fail-fast Spliterator over the elements in the set.

    ```java
    Spliterator<String> spliterator = set.spliterator();
    ```


***

## Synchronized vs Unsynchronized

In Java, "synchronized" and "not synchronized" refer to whether an object or a block of code is thread-safe or not with respect to concurrent access by multiple threads.

### Synchronized:

- In Java, the `synchronized` keyword is used to control access to critical sections of code, ensuring that only one thread can access the synchronized block or method at a time.
- When a method or block is synchronized, Java ensures that only one thread can execute that code block at any given time.
- Synchronization prevents race conditions and ensures data integrity in concurrent environments where multiple threads access shared resources.
- Examples of synchronized constructs include synchronized methods, synchronized blocks, and synchronized collections.

### Not Synchronized (Unsynchronized):

- When code is not synchronized, it means that multiple threads can access and modify shared resources concurrently without any protection mechanisms.
- In unsynchronized code, race conditions and thread interference can occur if multiple threads modify shared data without proper synchronization.
- While unsynchronized code may offer better performance in single-threaded or low-concurrency scenarios, it can lead to data corruption and inconsistent behavior in multi-threaded environments.
- Many of the Java Collections Framework classes, such as `ArrayList`, `HashMap`, and `HashSet`, are not synchronized by default. This means that they are not thread-safe and require external synchronization if used in concurrent environments.

Example of Synchronized Method:

```java
public synchronized void synchronizedMethod() {
    // Synchronized method body
}
```

In this example, the `synchronized` keyword ensures that only one thread can execute the `synchronizedMethod()` at a time, preventing concurrent access issues.

Example of Unsynchronized Code:

```java
List<String> list = new ArrayList<>();
```

In this example, the `ArrayList` instance `list` is not synchronized by default. If multiple threads access and modify the `list` concurrently, it can lead to data corruption or inconsistent behavior unless proper synchronization mechanisms are applied externally.

---

## Java Decorators

### Overview

Java doesn't have built-in decorator syntax like Python's `@decorator`. However, the term "decorator" in Java can refer to two distinct concepts:

1. **The Decorator Design Pattern** - A structural pattern for adding behavior to objects
2. **Annotations** - Metadata markers (often called "decorators" colloquially, though technically different)

### The Decorator Design Pattern

The Decorator pattern allows you to add new functionality to objects dynamically by wrapping them in decorator classes.

#### Key Components

- **Component Interface** - Defines the interface for objects that can have responsibilities added
- **Concrete Component** - The original object being decorated
- **Decorator** - Abstract class that implements the component interface and contains a reference to a component
- **Concrete Decorators** - Specific implementations that add behavior

#### Example Implementation

```java
// Component interface
interface Coffee {
    double getCost();
    String getDescription();
}

// Concrete component
class SimpleCoffee implements Coffee {
    @Override
    public double getCost() {
        return 2.0;
    }
    
    @Override
    public String getDescription() {
        return "Simple coffee";
    }
}

// Decorator base class
abstract class CoffeeDecorator implements Coffee {
    protected Coffee decoratedCoffee;
    
    public CoffeeDecorator(Coffee coffee) {
        this.decoratedCoffee = coffee;
    }
    
    @Override
    public double getCost() {
        return decoratedCoffee.getCost();
    }
    
    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription();
    }
}

// Concrete decorators
class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }
    
    @Override
    public double getCost() {
        return super.getCost() + 0.5;
    }
    
    @Override
    public String getDescription() {
        return super.getDescription() + ", milk";
    }
}

class SugarDecorator extends CoffeeDecorator {
    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }
    
    @Override
    public double getCost() {
        return super.getCost() + 0.2;
    }
    
    @Override
    public String getDescription() {
        return super.getDescription() + ", sugar";
    }
}

// Usage
Coffee coffee = new SimpleCoffee();
coffee = new MilkDecorator(coffee);
coffee = new SugarDecorator(coffee);

System.out.println(coffee.getDescription()); // "Simple coffee, milk, sugar"
System.out.println(coffee.getCost());        // 2.7
```

### Java Annotations

Annotations are metadata tags that provide information about the code. They're sometimes called "decorators" colloquially because they "decorate" code elements.

#### Built-in Annotations

```java
@Override
public void method() { }

@Deprecated
public void oldMethod() { }

@SuppressWarnings("unchecked")
public void method() { }

@FunctionalInterface
interface MyFunction {
    void execute();
}
```

#### Custom Annotations

```java
// Define custom annotation
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface LogExecutionTime {
    String value() default "";
}

// Use the annotation
public class MyService {
    @LogExecutionTime("database query")
    public void performQuery() {
        // method implementation
    }
}

// Process annotation at runtime using reflection
public class AnnotationProcessor {
    public static void processAnnotations(Object obj) throws Exception {
        Method[] methods = obj.getClass().getDeclaredMethods();
        
        for (Method method : methods) {
            if (method.isAnnotationPresent(LogExecutionTime.class)) {
                LogExecutionTime annotation = method.getAnnotation(LogExecutionTime.class);
                
                long startTime = System.currentTimeMillis();
                method.invoke(obj);
                long endTime = System.currentTimeMillis();
                
                System.out.println(annotation.value() + " took " + 
                    (endTime - startTime) + "ms");
            }
        }
    }
}
```

### Common Use Cases

#### IO Streams (Real-world Decorator Pattern)

Java's IO classes extensively use the decorator pattern:

```java
InputStream input = new FileInputStream("file.txt");
input = new BufferedInputStream(input);
input = new DataInputStream(input);
```

#### Spring Framework Annotations

```java
@Component
@Service
@Repository
@Controller
@RestController
@Autowired
@RequestMapping("/api")
```

#### Validation Annotations (Bean Validation)

```java
public class User {
    @NotNull
    @Size(min = 2, max = 30)
    private String name;
    
    @Email
    private String email;
    
    @Min(18)
    private int age;
}
```

### Comparison with Python Decorators

Unlike Python's `@decorator` syntax which wraps functions at definition time, Java requires either:
- Explicit wrapping with the Decorator pattern
- Annotations processed via reflection or compile-time processors
- Frameworks like Spring that use annotations to generate proxy objects with additional behavior

***
# Syllabus

### Core Java Concepts:

1. **Introduction to Java:**
    - History and evolution of Java.
    - Features and advantages of Java.
2. **Setting Up Development Environment:**
    - Installing JDK (Java Development Kit).
    - Setting up IDE (Integrated Development Environment) like IntelliJ IDEA, Eclipse, or NetBeans.
3. **Basic Syntax and Structure:**
    - Understanding Java source file structure.
    - Data types, variables, and constants.
    - Operators and expressions.
    - Control flow statements (if, switch, loops).
4. **Object-Oriented Programming (OOP):**
    - Classes and objects.
    - Encapsulation, inheritance, and polymorphism.
    - Abstraction and interfaces.
    - Packages and access modifiers.
5. **Exception Handling:**
    - Handling exceptions using try-catch blocks.
    - Using `throw` and `throws` keywords.
    - Creating custom exceptions.
6. **Collections Framework:**
    - Understanding collections: List, Set, Map.
    - Iteration and manipulation of collections.
    - Sorting and searching algorithms.
7. **Generics:**
    - Understanding generic classes and methods.
    - Using generic collections.
8. **Input/Output (I/O) Operations:**
    - Reading and writing files using `FileInputStream`, `FileOutputStream`, `BufferedReader`, `BufferedWriter`, etc.
    - Working with streams and readers/writers.

### Advanced Java Concepts:

9. **Concurrency and Multithreading:**
    - Creating and managing threads.
    - Synchronization and thread safety.
    - Concurrent data structures.
10. **Java Database Connectivity (JDBC):**
    - Connecting to databases using JDBC.
    - Executing SQL queries and processing results.
11. **JavaFX (or Swing):**
    - GUI application development.
    - Designing user interfaces using JavaFX (or Swing).
12. **Networking and Socket Programming:**
    - Client-server communication.
    - Implementing network protocols using sockets.

### Java Development Tools and Best Practices:

13. **Version Control:**
    - Using Git for version control.
    - Collaborating on projects with Git.
14. **Testing and Debugging:**
    - Writing unit tests using JUnit.
    - Debugging techniques and tools.
15. **Build Tools:**
    - Understanding build automation tools like Maven or Gradle.
    - Building, packaging, and managing dependencies.
16. **Code Quality and Style:**
    - Writing clean and maintainable code.
    - Understanding code conventions and best practices.
17. **Documentation:**
    - Writing code documentation using Javadoc.
    - Generating and publishing documentation.

### Java EE (Enterprise Edition) and Web Development:

18. **Servlets and JSP (JavaServer Pages):**
    - Handling HTTP requests and responses.
    - Dynamic web content generation using JSP.
19. **Spring Framework:**
    - Dependency Injection and Inversion of Control (IoC).
    - Spring MVC for web application development.
    - Spring Boot for rapid application development.
20. **Hibernate (or JPA):**
    - Object-relational mapping (ORM).
    - Database persistence using Hibernate (or Java Persistence API).

### Additional Topics:

21. **Java Security:**
    - Secure coding practices.
    - Authentication and authorization.
22. **Microservices and RESTful Web Services:**
    - Creating REST APIs using Spring Boot.
    - Implementing microservices architecture.
23. **Cloud Computing and Deployment:**
    - Deploying Java applications on cloud platforms like AWS, Azure, or Google Cloud.
24. **Containerization and DevOps:**
    - Docker containers for application deployment.
    - CI/CD pipelines and automation.
25. **Learning Resources and Community Engagement:**
    - Books, tutorials, online courses, and documentation.
    - Engaging with Java communities, forums, and user groups.