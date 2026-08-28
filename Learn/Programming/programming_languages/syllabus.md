## Table of Contents: Programming Languages

### Evolution of the Major Programming Languages

- Pre-1950s computing and the need for symbolic notation
- Machine language and assembly language as first-generation tools
- Plankalkul and early language design attempts
- FORTRAN and the birth of high-level languages
- ALGOL and its influence on language structure
- COBOL and business-oriented computing
- Lisp and symbolic list processing
- BASIC and the democratization of programming
- PL/I and the attempt at a unified language
- SIMULA and the origins of object orientation
- C and the rise of systems programming
- Prolog and logic programming
- Smalltalk and pure object orientation
- Ada and government-mandated standardization
- C++ and hybrid object-oriented systems programming
- Java and platform independence
- Scripting languages and the web era
- Python and readability-focused design
- Functional language resurgence in mainstream computing
- Modern multi-paradigm and safety-focused languages

### Ada Programming Language

- Historical context and the US Department of Defense mandate
- Design goals and the language competition process
- Strong typing and compile-time safety philosophy
- Packages and modular program structure
- Generics and reusable components
- Tasking model and concurrent programming support
- Exception handling mechanisms
- Ada 83 to Ada 95 to Ada 2012 evolution
- Use in safety-critical and embedded systems

### COBOL Programming Language

- Origins and the CODASYL committee
- Business data processing design goals
- English-like syntax philosophy
- Division structure: identification, environment, data, procedure
- Record and file handling for business applications
- PICTURE clauses and data description
- Legacy system prevalence and modernization challenges
- COBOL's continued role in mainframe and financial systems

### Lisp Programming Language

- John McCarthy and the origins of symbolic computation
- S-expressions and homoiconicity
- Lists as the universal data structure
- Recursion as the primary control mechanism
- The eval-apply cycle
- Garbage collection introduction
- Dynamic versus lexical scoping debates
- Macros and code-as-data manipulation
- Dialects: Scheme, Common Lisp, Clojure
- Influence on functional programming and AI research

### Language Design Principles and Trade-offs

- Criteria for evaluating programming languages
- Readability versus writability tensions
- Reliability and the cost of language misuse
- Cost across the language life cycle
- Influence of computer architecture on language design
- Influence of programming methodologies on design
- Language categories: imperative, functional, logic, object-oriented
- Implementation methods: compilation, interpretation, hybrid

### Syntax and Semantics

- The general problem of describing syntax
- Formal languages and language generators versus recognizers
- Backus-Naur Form fundamentals
- Extended BNF notation
- Grammars and derivations
- Parse trees and ambiguity in grammars
- Attribute grammars and static semantics
- Operational semantics
- Denotational semantics
- Axiomatic semantics and program correctness

### Lexical Structure

- Lexemes and tokens
- Reserved words versus keywords
- Identifier naming rules across languages
- Whitespace and free-form versus layout-sensitive syntax
- Comment conventions
- Lexical analysis and the tokenization process
- Regular expressions and finite automata for lexers

### Names, Bindings, Type Checking and Scopes

- Design issues for names
- Variables: name, address, value, type, lifetime
- Binding and binding times
- Static versus dynamic binding
- Type binding and type inference
- Storage bindings and variable lifetime
- Static scope and lexical scoping rules
- Dynamic scope and its implications
- Scope and lifetime distinctions
- Referencing environments
- Named constants
- Type checking and type compatibility
- Strong typing versus weak typing

### Data Types

- Primitive data types
- Character string types
- Enumeration types
- Array types and subscript binding
- Associative arrays
- Record types and field access
- Tuple types
- Union types and type safety concerns
- Pointer and reference types
- Dangling pointers and memory safety
- Type theory and structural versus nominal typing

### Expressions and Assignment Statements

- Arithmetic expressions and operator precedence
- Operator associativity rules
- Type conversions: coercion and casting
- Relational and boolean expressions
- Short-circuit evaluation
- Assignment statements and their semantics
- Compound assignment operators
- Mixed-mode assignment
- Referential transparency in expressions

### Statement-Level Control Structures

- Selection statements: single-way and multi-way
- Nesting selectors and dangling else problems
- Iterative statements: counter-controlled loops
- Logically controlled loops
- User-located loop control mechanisms
- Unconditional branching and goto controversy
- Guarded commands
- Structured programming principles

### Subprograms

- Fundamentals of subprograms
- Parameter passing methods: by value, by reference, by result
- Parameter passing modes and semantics models
- Type checking of parameters
- Multidimensional array parameter handling
- Design issues for functions
- Overloaded subprograms
- Generic subprograms and parametric polymorphism
- Separate and independent compilation
- Design issues for functions returning values
- Coroutines

### Implementing Subprograms

- The general semantics of calls and returns
- Activation records
- Stack-based allocation implementation
- Dynamic local variable allocation
- Nested subprograms and static chains
- Blocks and dynamic scoping implementation
- Implementing dynamic scoping

### Abstract Data Types and Encapsulation

- The concept of abstraction
- Design issues for abstract data types
- Language examples of encapsulation constructs
- Parameterized abstract data types
- Encapsulation constructs
- Naming encapsulations

### Object-Oriented Programming

- Introduction to object orientation
- Design issues for object-oriented languages
- Inheritance mechanisms
- Dynamic binding and polymorphism
- Method overriding and virtual methods
- Abstract classes and interfaces
- Multiple inheritance and its complications
- Design issues for object-oriented languages compared
- Implementation of object-oriented constructs

### Concurrency

- Introduction to subprogram-level concurrency
- Fundamental concepts of concurrent execution
- Semaphores and mutual exclusion
- Monitors and structured synchronization
- Message passing models
- Threads and their language support
- Statement-level concurrency
- Actor model and modern concurrency approaches

### Exception Handling and Event Handling

- Introduction to exception handling concepts
- Exception handlers and their bindings
- Exception propagation
- Continuation and resumption models
- Event handling fundamentals
- Language examples of exception mechanisms

### Functional Programming Languages

- Mathematical functions and referential transparency
- Fundamentals of functional programming
- The first functional programming language
- Introduction to Scheme
- Common Lisp overview
- ML and static typing in functional languages
- Haskell and lazy evaluation
- F Sharp and functional programming on a managed runtime
- Support for functional programming in primarily imperative languages
- Comparing functional and imperative languages

### Logic Programming Languages

- Introduction to logic and logic programming
- Predicate calculus fundamentals
- Resolution and proof by contradiction
- Clausal form and Horn clauses
- Overview of logic programming
- The origins of Prolog
- Prolog terms and unification
- Inferencing process in Prolog
- Applications of logic programming
- Deficiencies of Prolog and logic programming

### Formal Methods of Language Semantics

- Uses of formal semantics
- Operational semantics revisited
- Denotational semantics revisited
- Axiomatic semantics and weakest preconditions
- Proof of program correctness

### Compiler and Interpreter Fundamentals

- The compilation process overview
- Lexical analysis phase
- Syntax analysis and parsing techniques
- Top-down and bottom-up parsing
- Semantic analysis
- Intermediate code generation
- Code optimization strategies
- Code generation
- Interpretation versus compilation trade-offs
- Just-in-time compilation
- Virtual machines and bytecode

### Memory Management Across Languages

- Static memory management
- Stack-based memory management
- Heap management strategies
- Manual memory management and its risks
- Garbage collection algorithms
- Reference counting
- Ownership and borrowing models
- Memory safety guarantees across language families

### Type Systems in Depth

- Static typing versus dynamic typing philosophies
- Type inference algorithms
- Parametric polymorphism
- Ad hoc polymorphism and overloading
- Subtype polymorphism
- Duck typing
- Gradual typing systems
- Dependent types
- Type soundness and safety proofs

### Programming Paradigms Compared

- Imperative paradigm characteristics
- Declarative paradigm characteristics
- Object-oriented paradigm characteristics
- Functional paradigm characteristics
- Logic paradigm characteristics
- Multi-paradigm language design
- Choosing paradigms for problem domains

### Scripting Languages

- Origins and purpose of scripting languages
- Perl and text processing heritage
- Python design philosophy and ecosystem
- Ruby and expressive object orientation
- JavaScript and the browser environment
- PHP and server-side web scripting
- Shell scripting fundamentals

### Modern Systems Programming Languages

- C and low-level control philosophy
- C++ evolution and modern standards
- Rust and ownership-based memory safety
- Go and simplicity-focused concurrency
- Zig and explicit systems programming
- Swift and safety in application development

### Language Interoperability and Ecosystems

- Foreign function interfaces
- Language bindings and wrappers
- Cross-language data serialization
- Virtual machine ecosystems: JVM and CLR
- WebAssembly as a compilation target
- Package management across language ecosystems

### Domain-Specific Languages

- Internal versus external DSLs
- Query languages and SQL
- Markup and configuration languages
- Regular expressions as a DSL
- Build and configuration DSLs
- Designing a domain-specific language

### History and Practice of Language Implementation

- Von Neumann architecture influence on imperative languages
- Historical language family trees
- Standardization bodies and language specifications
- Open source language development models
- Benchmarking and performance comparison methods
- Reading and evaluating language specification documents
