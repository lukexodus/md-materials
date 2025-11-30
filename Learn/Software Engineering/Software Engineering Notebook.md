# Principles

## CUPID

CUPID is a software engineering framework created by **Daniel Terhorst-North** that prioritizes designing joyful, maintainable code by focusing on properties rather than prescriptive principles.  It serves as a modern alternative to the SOLID principles, emphasizing characteristics that make code a pleasure to work with.[1][2]

CUPID comprises five core properties that guide software design:[3]

### **Composable**
– Plays well with others, featuring a small surface area, clear intentions, and minimal dependencies.  This property encourages designing software as small, independent modules that integrate seamlessly with other components, promoting reusability and scalability.[4][5]

### **Unix Philosophy** 
– Does one thing well, emphasizing that each component should have a focused responsibility.  This draws from the Unix philosophy of simplicity and clarity, distinguishing between single-purpose functionality and broader responsibility.[5][4]

### **Predictable**
– Does what you expect, with deterministic behavior and strong observability.  Software should behave as anticipated, allowing developers to reason about outcomes based on inputs without surprises.[4][5]

### **Idiomatic** 
– Feels natural, conforming to the conventions and established patterns of the programming language or framework being used.  This reduces cognitive load by following language idioms and local conventions that developers recognize and understand.[5][4]

### **Domain-Based**
– Aligns the solution domain with the problem domain through matching language and structure.  The software's design should mirror real-world entities and interactions, making it intuitive for developers familiar with the problem domain.[4][5]

**Properties Over Principles**

A key distinction of CUPID is its shift from prescriptive design principles to descriptive properties.  Rather than rigid rules to follow, properties define goals or centers to move toward, allowing code to be closer or further from the ideal without achieving absolute success or failure.  Developers can use properties as lenses to assess their code and decide which aspects to address next.[2][1][5]

**Design for Joy**

CUPID's foundational philosophy centers on making code joyful to work with, building on Martin Fowler's concept that "good programmers write code that humans can understand."  The framework emphasizes habitability—the characteristic that enables developers to understand a codebase's construction and intentions while changing it comfortably and confidently.[2][5]

Sources
[1] CUPID: for joyful coding | Dan North & Associates Limited https://dannorth.net/blog/cupid-for-joyful-coding/
[2] CUPID Method Explained by Daniel Terhorst-North https://gotopia.tech/articles/250/exploring-the-cupid-method-by-daniel-terhorst-north
[3] CUPID—for joyful coding [alternative to SOLID; 2022] https://www.reddit.com/r/programming/comments/184acow/cupidfor_joyful_coding_alternative_to_solid_2022/
[4] CUPID - Code with Love - by Thiago Bomfim https://devjava.substack.com/p/cupid-code-with-love
[5] Unpacking Dan North's CUPID properties for joyful coding https://infrastructure-as-code.com/posts/cupid-for-infrastructure.html
[6] SOLID, CUPID, GRASP Principles of Object-Oriented Design https://www.boldare.com/blog/solid-cupid-grasp-principles-object-oriented-design/
[7] Why We Need Design Principles Like SOLID, CUPID & ... https://gokhul.hashnode.dev/the-building-blocks-of-software-why-we-need-design-principles-like-solid-cupid-grasp
[8] CUPID - Why every single element of SOLID is wrong https://dev.to/llotz/cupid-why-every-single-element-of-solid-is-wrong-1f6
[9] CUPID — For Joyful Coding in 7 Minutes • Daniel Terhorst- ... https://www.youtube.com/watch?v=sV6UptcmSRA
[10] Why You Should Start Using CUPID and Not SOLID https://dzone.com/articles/why-you-should-start-using-cupid-and-not-solid-to

## SOLID

### **Single Responsibility Principle (SRP)**
– A class should have only one reason to change, meaning it should have a single responsibility or job.  This makes code easier to understand, test, and maintain, as each class focuses on one specific task.[3][4]

### **Open-Closed Principle (OCP)**
– Software entities should be open for extension but closed for modification.  This means you should be able to add new functionality without changing existing code, typically using abstractions like inheritance or interfaces.[3]

### **Liskov Substitution Principle (LSP)**
– Subtypes must be substitutable for their base types without breaking the application. This principle ensures that derived classes can be used interchangeably with their parent classes without causing unexpected behavior.[5][3]

### **Interface Segregation Principle (ISP)**
– Clients should not be forced to depend on interfaces they do not use.  This principle encourages creating smaller, more specific interfaces rather than one large, general-purpose interface.[5][3]

### **Dependency Inversion Principle (DIP)** 
– High-level modules should not depend on low-level modules; both should depend on abstractions.  This decouples components and makes code more flexible and testable.[3][5]

**Purpose and Benefits**

SOLID principles seek to reduce dependencies so that changes in one area of software do not impact others.  They make software more understandable, flexible, scalable, and maintainable over time.  While following SOLID principles may lead to longer and more complex code during development, the investment pays off through easier maintenance, testing, and extension in the long run.[5][3]

Sources
[1] SOLID https://en.wikipedia.org/wiki/SOLID
[2] The SOLID Principles of Object-Oriented Programming ... https://www.freecodecamp.org/news/solid-principles-explained-in-plain-english/
[3] SOLID Principles in Object Oriented Design https://www.bmc.com/blogs/solid-design-principles/
[4] What are SOLID Principles? https://contabo.com/blog/what-are-solid-principles/
[5] What Are SOLID Design Principles https://dev.to/ggorantala/what-are-solid-design-principles-1n22
[6] SOLID Design Principles Explained: Building Better ... https://www.digitalocean.com/community/conceptual-articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design
[7] SOLID Design Principles in Software Development https://www.freecodecamp.org/news/solid-design-principles-in-software-development/
[8] The SOLID Principles in Software Development https://codefinity.com/blog/The-SOLID-Principles-in-Software-Development
[9] SOLID Design Principles: The Single Responsibility ... https://stackify.com/solid-design-principles/
[10] A Solid Guide to SOLID Principles https://www.baeldung.com/solid-principles

