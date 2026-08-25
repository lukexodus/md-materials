## Control Flow in Rust


### If/Else Expressions

In Rust, if/else constructs are expressions rather than statements, meaning they can return values. This allows for concise conditional assignment.

**Key Points**

- Conditions don't need parentheses but blocks require curly braces
- All branches must return the same type when used as expressions
- The condition must be a boolean expression

```rust
let number = 6;

if number % 4 == 0 {
    println!("number is divisible by 4");
} else if number % 3 == 0 {
    println!("number is divisible by 3");
} else {
    println!("number is not divisible by 4 or 3");
}

// If as an expression
let condition = true;
let number = if condition { 5 } else { 6 };
```

### Match Expressions

Match expressions are powerful pattern matching constructs that compare a value against a series of patterns and execute code based on which pattern matches.

**Key Points**

- Match arms consist of a pattern and the code to run
- Matches are exhaustive - all possible values must be covered
- The underscore (_) wildcard pattern catches all remaining cases
- Can destructure enums, tuples, and structs

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

enum UsState {
    Alabama,
    Alaska,
    // ... other states
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}

// Match with Option<T>
let some_u8_value = Some(0u8);
match some_u8_value {
    Some(3) => println!("three"),
    Some(val) => println!("value: {}", val),
    None => println!("none"),
}
```

### Loops

Rust provides three types of loops for different use cases.

#### For Loop

**Key Points**

- Primarily used for iterating over collections
- Safe and prevents common errors like off-by-one errors
- Can iterate over ranges with the range syntax

```rust
// Iterating over a collection
let a = [10, 20, 30, 40, 50];
for element in a {
    println!("the value is: {}", element);
}

// Iterating over a range
for number in 1..4 {  // Exclusive range 1,2,3
    println!("{}!", number);
}

// Counting down with rev()
for number in (1..4).rev() {
    println!("{}!", number);
}
```

#### While Loop

**Key Points**

- Continues while a condition remains true
- Condition is evaluated before each iteration
- Cleaner than manual loop-and-break combinations

```rust
let mut number = 3;

while number != 0 {
    println!("{}!", number);
    number -= 1;
}

println!("LIFTOFF!!!");
```

#### Infinite Loop

**Key Points**

- Created with the `loop` keyword
- Runs indefinitely until explicitly broken
- Can return values from the loop

```rust
// Infinite loop with break
let mut counter = 0;

let result = loop {
    counter += 1;
    
    if counter == 10 {
        break counter * 2;  // Returns a value from the loop
    }
};

println!("The result is {}", result);  // Prints: The result is 20
```

### Loop Labels, Break, and Continue

**Key Points**

- Labels help manage nested loops
- `break` exits the current loop
- `continue` skips to the next iteration
- Labels allow breaking/continuing specific outer loops

```rust
// Using loop labels
'outer: for x in 0..5 {
    'inner: for y in 0..5 {
        if x == 3 && y == 3 {
            break 'outer;  // Break out of the outer loop
        }
        if y > x {
            continue 'outer;  // Skip to the next iteration of the outer loop
        }
        println!("x: {}, y: {}", x, y);
    }
}
```

**Example** A classic FizzBuzz implementation using loops and flow control:

```rust
for i in 1..=100 {
    if i % 3 == 0 && i % 5 == 0 {
        println!("FizzBuzz");
    } else if i % 3 == 0 {
        println!("Fizz");
    } else if i % 5 == 0 {
        println!("Buzz");
    } else {
        println!("{}", i);
    }
}
```

### Early Return with Return Keyword

Rust allows early returns from functions, which can simplify control flow and avoid deep nesting.

**Key Points**

- `return` immediately exits the function with a value
- Typically used for error handling or early success cases
- The last expression in a function is implicitly returned without `return`

```rust
fn find_divisible_by(needle: u32, haystack: &[u32]) -> Option<u32> {
    for &item in haystack {
        if item % needle == 0 {
            return Some(item);  // Early return on finding a match
        }
    }
    None  // Implicit return if no match is found
}

// Using early returns for error handling
fn parse_and_process(input: &str) -> Result<i32, String> {
    let number: i32 = match input.parse() {
        Ok(num) => num,
        Err(_) => return Err(String::from("Invalid number")),  // Early return on error
    };
    
    if number < 0 {
        return Err(String::from("Number must be positive"));  // Another early return
    }
    
    Ok(number * 2)  // Success case
}
```

**Conclusion** Rust's control flow mechanisms provide powerful tools for directing program execution. The expression-based nature of `if` and `match` allows for concise, functional-style code, while loops with labels offer fine-grained control over iteration. Early returns help simplify error handling and complex logic. These features, combined with Rust's other safety guarantees, enable writing robust programs with clear flow control.

### Related Topics

You might want to explore pattern matching in more depth, error handling with Result and Option types, or closures and iterators which provide functional programming approaches to control flow.

---

