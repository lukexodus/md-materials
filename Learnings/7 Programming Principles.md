## 1. Follow Standards
- Consistency and readability are essential.
- Follow programming standards for whitespace, file structure, etc.
- Shared expectations for working with others.

## 2. [[SOLID]]

## 3. Patterns
- **Creational Patterns.** Control object instances
	- Factory pattern
- **Structural Patterns**. Organize and manipulate objects
	- Adapter Pattern - Wrap a module and adapt its interface to one that another module needs.
- **Behavioral Pattens**. Handle code functions and communication
	- Observer Pattern

## 4. Name
- **Avoid encodings** such as type information, which make it harder to read code in a natural way. 
- **Expand abbreviations.**
- **Use clear distinction**. We should aim to use names that more accurately represent the nuances of the code we're working with.
- **No 'magic' values.** Use named constants instead of just variables. For example using `const PI = 3.14` instead of just using `3.14`.
- **Be descriptive**.

## 5. Test
- **End-to-end testing** (High-level). Test the system as if you were the end user.
- **Units Tests** (Low-level). Verify the operation of our modules in isolation.
- **Integration tests** (Low-level). examine the interaction between those modules.
- Unit tests and integration test focus more on behavior.

## 6. Time Management and Estimation
- Double or triple time estimates to account for unforeseen issues.
- Overestimate and deliver ahead of schedule to avoid missing deadlines.

## 7. Avoid Rushing and Focus on Quality
- Take time to think through long-term projects thoroughly.
- A solid foundation leads to easier maintenance and code improvements over time.
- You're likely to finish in less time regardless if you're not constantly battling decisions you can't easily fix because of poor architecture.
- We want projects that get easier with time, not harder.