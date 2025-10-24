#### Single Responsibility
- Split monolithic components

#### Open/Close
- Design modules to be able to add functionality without having to
actually make changes to them.
- Extend a module to add to it, be that wrapping it or something else, but we should never modify it directly.
- Once a module is in use, it's locked, and this now reduces the chances of any new additions breaking your code.

#### Liskov Substitution
- We should only extend modules when we're absolutely sure that it's still the same type at heart.
- It should extend somethin that fits its design or become its own type instead.

#### Interface Segregation
- Our modules shouldn't need to know about functionality that they don't use.
- We need to split our modules into smaller abstractions, like interfaces, which we can then compose to form an exact set of functionality that the module requires.
- This becomes especially useful when testing, as it allows us to mock out only the functionality that each module needs.

#### Dependency Inversion
- Instead of talking to other parts of your code directly, we should always communicate abstractly, typically via the interfaces we define.
- Dependency Inversion breaks down any direct relationships between our code, and isolates our modules completely from one another, meaning we can swap out parts as we need to.
- Because they communicate with interfaces now, they don't need to know what implementation they are getting, only that they take certain inputs and return a valid output.