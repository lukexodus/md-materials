## Design Patterns in TypeScript


### Introduction to Design Patterns

Design patterns represent proven solutions to common software design problems. They provide reusable templates for solving issues that occur repeatedly in software development. In TypeScript, these patterns become even more powerful due to the language's static typing, interfaces, and object-oriented features.

### Creational Patterns

Creational design patterns focus on mechanisms of object creation, trying to create objects in a manner suitable to the situation.

### Singleton Pattern

The Singleton pattern ensures a class has only one instance and provides a global point of access to it.

**Key Points**

- Restricts instantiation of a class to a single instance
- Provides a global access point to that instance
- Particularly useful for database connections, logging, caching

```typescript
class Singleton {
  private static instance: Singleton;
  
  private constructor() {
    // Private constructor prevents direct construction calls
  }
  
  public static getInstance(): Singleton {
    if (!Singleton.instance) {
      Singleton.instance = new Singleton();
    }
    
    return Singleton.instance;
  }
  
  public someBusinessLogic() {
    // Business logic methods
  }
}

// Usage
const instance1 = Singleton.getInstance();
const instance2 = Singleton.getInstance();

console.log(instance1 === instance2); // Output: true
```

### Factory Pattern

The Factory pattern provides an interface for creating objects but allows subclasses to alter the type of objects that will be created.

**Key Points**

- Creates objects without exposing creation logic
- Uses a common interface to refer to created objects
- Allows flexibility to add new types without changing existing code

```typescript
interface Product {
  operation(): string;
}

class ConcreteProduct1 implements Product {
  public operation(): string {
    return 'Result of ConcreteProduct1';
  }
}

class ConcreteProduct2 implements Product {
  public operation(): string {
    return 'Result of ConcreteProduct2';
  }
}

abstract class Creator {
  public abstract factoryMethod(): Product;
  
  public someOperation(): string {
    const product = this.factoryMethod();
    return `Creator: The same creator's code has worked with ${product.operation()}`;
  }
}

class ConcreteCreator1 extends Creator {
  public factoryMethod(): Product {
    return new ConcreteProduct1();
  }
}

class ConcreteCreator2 extends Creator {
  public factoryMethod(): Product {
    return new ConcreteProduct2();
  }
}

// Usage
function clientCode(creator: Creator) {
  console.log(creator.someOperation());
}

clientCode(new ConcreteCreator1());
clientCode(new ConcreteCreator2());
```

### Observer Pattern

The Observer pattern defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.

**Key Points**

- Establishes a subscription mechanism
- Notifies multiple objects about events in the observed object
- Promotes loose coupling between objects

```typescript
interface Observer {
  update(subject: Subject): void;
}

interface Subject {
  attach(observer: Observer): void;
  detach(observer: Observer): void;
  notify(): void;
}

class ConcreteSubject implements Subject {
  private observers: Observer[] = [];
  private state: number = 0;
  
  public attach(observer: Observer): void {
    const isExist = this.observers.includes(observer);
    if (isExist) {
      return;
    }
    
    this.observers.push(observer);
  }
  
  public detach(observer: Observer): void {
    const observerIndex = this.observers.indexOf(observer);
    if (observerIndex === -1) {
      return;
    }
    
    this.observers.splice(observerIndex, 1);
  }
  
  public notify(): void {
    for (const observer of this.observers) {
      observer.update(this);
    }
  }
  
  public setState(state: number): void {
    this.state = state;
    this.notify();
  }
  
  public getState(): number {
    return this.state;
  }
}

class ConcreteObserverA implements Observer {
  public update(subject: Subject): void {
    if (subject instanceof ConcreteSubject && subject.getState() < 3) {
      console.log('ConcreteObserverA: Reacted to the event');
    }
  }
}

class ConcreteObserverB implements Observer {
  public update(subject: Subject): void {
    if (subject instanceof ConcreteSubject && (subject.getState() === 0 || subject.getState() >= 2)) {
      console.log('ConcreteObserverB: Reacted to the event');
    }
  }
}

// Usage
const subject = new ConcreteSubject();

const observer1 = new ConcreteObserverA();
subject.attach(observer1);

const observer2 = new ConcreteObserverB();
subject.attach(observer2);

subject.setState(1);
subject.setState(2);

subject.detach(observer2);
subject.setState(3);
```

### Structural Patterns

Structural patterns focus on how classes and objects are composed to form larger structures.

### Adapter Pattern

The Adapter pattern allows objects with incompatible interfaces to collaborate by wrapping an object in an adapter that conforms to another object's interface.

**Key Points**

- Converts one interface to another
- Enables classes to work together that couldn't otherwise
- Often used when integrating legacy code or third-party libraries

```typescript
// Target interface that client expects to work with
interface Target {
  request(): string;
}

// Existing functionality with incompatible interface
class Adaptee {
  public specificRequest(): string {
    return '.eetpadA eht fo roivaheb laicepS';
  }
}

// Adapter makes Adaptee compatible with Target
class Adapter implements Target {
  private adaptee: Adaptee;
  
  constructor(adaptee: Adaptee) {
    this.adaptee = adaptee;
  }
  
  public request(): string {
    const result = this.adaptee.specificRequest().split('').reverse().join('');
    return `Adapter: (TRANSLATED) ${result}`;
  }
}

// Client code
function clientCode(target: Target) {
  console.log(target.request());
}

// Usage
const adaptee = new Adaptee();
console.log('Adaptee:');
console.log(`Adaptee: ${adaptee.specificRequest()}`);

console.log('');

console.log('Client: I can work with the Target objects:');
const adapter = new Adapter(adaptee);
clientCode(adapter);
```

### Decorator Pattern

The Decorator pattern attaches additional responsibilities to objects dynamically, providing a flexible alternative to subclassing for extending functionality.

**Key Points**

- Adds behavior to objects without affecting other objects
- Follows the open/closed principle
- More flexible than inheritance
- Can be stacked to add multiple behaviors

```typescript
interface Component {
  operation(): string;
}

class ConcreteComponent implements Component {
  public operation(): string {
    return 'ConcreteComponent';
  }
}

class Decorator implements Component {
  protected component: Component;
  
  constructor(component: Component) {
    this.component = component;
  }
  
  public operation(): string {
    return this.component.operation();
  }
}

class ConcreteDecoratorA extends Decorator {
  public operation(): string {
    return `ConcreteDecoratorA(${super.operation()})`;
  }
}

class ConcreteDecoratorB extends Decorator {
  public operation(): string {
    return `ConcreteDecoratorB(${super.operation()})`;
  }
  
  public additionalOperation(): void {
    console.log('Additional operation from ConcreteDecoratorB');
  }
}

// Usage
const simple = new ConcreteComponent();
console.log('Client: I\'ve got a simple component:');
console.log(`Result: ${simple.operation()}`);

const decorator1 = new ConcreteDecoratorA(simple);
const decorator2 = new ConcreteDecoratorB(decorator1);
console.log('Client: Now I\'ve got a decorated component:');
console.log(`Result: ${decorator2.operation()}`);
```

### Behavioral Patterns

Behavioral patterns are concerned with algorithms and the assignment of responsibilities between objects.

### Strategy Pattern

The Strategy pattern defines a family of algorithms, encapsulates each one, and makes them interchangeable.

**Key Points**

- Defines algorithms independently from clients that use them
- Allows selecting algorithm at runtime
- Eliminates conditional statements

```typescript
interface Strategy {
  doAlgorithm(data: string[]): string[];
}

class Context {
  private strategy: Strategy;
  
  constructor(strategy: Strategy) {
    this.strategy = strategy;
  }
  
  public setStrategy(strategy: Strategy) {
    this.strategy = strategy;
  }
  
  public doSomeBusinessLogic(): void {
    const data = ['a', 'b', 'c', 'd', 'e'];
    const result = this.strategy.doAlgorithm(data);
    console.log(result.join(','));
  }
}

class ConcreteStrategyA implements Strategy {
  public doAlgorithm(data: string[]): string[] {
    return data.sort();
  }
}

class ConcreteStrategyB implements Strategy {
  public doAlgorithm(data: string[]): string[] {
    return data.reverse();
  }
}

// Usage
const context = new Context(new ConcreteStrategyA());
console.log('Client: Strategy is set to normal sorting.');
context.doSomeBusinessLogic();

console.log('Client: Strategy is set to reverse sorting.');
context.setStrategy(new ConcreteStrategyB());
context.doSomeBusinessLogic();
```

### Command Pattern

The Command pattern encapsulates a request as an object, allowing for parameterization of clients with different requests, queueing of requests, and logging of the operations.

**Key Points**

- Decouples sender from receiver
- Allows queueing of commands
- Supports undo operations
- Enables logging and auditing of operations

```typescript
interface Command {
  execute(): void;
}

class SimpleCommand implements Command {
  private payload: string;
  
  constructor(payload: string) {
    this.payload = payload;
  }
  
  public execute(): void {
    console.log(`SimpleCommand: I can do simple things like printing (${this.payload})`);
  }
}

class ComplexCommand implements Command {
  private receiver: Receiver;
  private a: string;
  private b: string;
  
  constructor(receiver: Receiver, a: string, b: string) {
    this.receiver = receiver;
    this.a = a;
    this.b = b;
  }
  
  public execute(): void {
    console.log('ComplexCommand: Complex stuff should be done by a receiver object.');
    this.receiver.doSomething(this.a);
    this.receiver.doSomethingElse(this.b);
  }
}

class Receiver {
  public doSomething(a: string): void {
    console.log(`Receiver: Working on (${a}.)`);
  }
  
  public doSomethingElse(b: string): void {
    console.log(`Receiver: Also working on (${b}.)`);
  }
}

class Invoker {
  private onStart: Command;
  private onFinish: Command;
  
  public setOnStart(command: Command): void {
    this.onStart = command;
  }
  
  public setOnFinish(command: Command): void {
    this.onFinish = command;
  }
  
  public doSomethingImportant(): void {
    console.log('Invoker: Does anybody want something done before I begin?');
    if (this.onStart) {
      this.onStart.execute();
    }
    
    console.log('Invoker: ...doing something really important...');
    
    console.log('Invoker: Does anybody want something done after I finish?');
    if (this.onFinish) {
      this.onFinish.execute();
    }
  }
}

// Usage
const invoker = new Invoker();
invoker.setOnStart(new SimpleCommand('Say Hi!'));
const receiver = new Receiver();
invoker.setOnFinish(new ComplexCommand(receiver, 'Send email', 'Save report'));
invoker.doSomethingImportant();
```

### TypeScript-Specific Implementation Considerations

TypeScript offers several features that enhance design pattern implementations:

#### Generic Types

Using generic types can make patterns like Factory more flexible:

```typescript
class GenericFactory<T> {
  create(ctor: new () => T): T {
    return new ctor();
  }
}

class Product1 {}
class Product2 {}

const factory = new GenericFactory<Product1 | Product2>();
const p1 = factory.create(Product1);
const p2 = factory.create(Product2);
```

#### Decorators

TypeScript's experimental decorators can simplify the implementation of decorator patterns:

```typescript
function log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with arguments: ${JSON.stringify(args)}`);
    const result = originalMethod.apply(this, args);
    console.log(`Method ${propertyKey} returned: ${JSON.stringify(result)}`);
    return result;
  };
  
  return descriptor;
}

class Calculator {
  @log
  add(a: number, b: number): number {
    return a + b;
  }
}

// Usage
const calc = new Calculator();
calc.add(1, 2);
// Output:
// Calling add with arguments: [1,2]
// Method add returned: 3
```

#### Abstract Classes

TypeScript's abstract classes provide a powerful way to define templates for pattern implementations:

```typescript
abstract class AbstractFactory {
  abstract createProductA(): ProductA;
  abstract createProductB(): ProductB;
  
  produceProducts(): void {
    const productA = this.createProductA();
    const productB = this.createProductB();
    console.log(productA.operationA());
    console.log(productB.operationB());
  }
}

interface ProductA {
  operationA(): string;
}

interface ProductB {
  operationB(): string;
}

class ConcreteFactory1 extends AbstractFactory {
  createProductA(): ProductA {
    return new ConcreteProductA1();
  }
  
  createProductB(): ProductB {
    return new ConcreteProductB1();
  }
}

class ConcreteProductA1 implements ProductA {
  operationA(): string {
    return 'Product A1';
  }
}

class ConcreteProductB1 implements ProductB {
  operationB(): string {
    return 'Product B1';
  }
}
```

### Best Practices for Using Design Patterns in TypeScript

#### Pattern Selection Guidelines

**Key Points**

- Choose the simplest pattern that solves your problem
- Don't overengineer solutions by adding unnecessary patterns
- Consider maintenance and team understanding when selecting patterns
- Document pattern usage in your codebase for better maintainability

#### Anti-Patterns to Avoid

**Key Points**

- Singleton overuse - can create hidden dependencies
- God objects - violate single responsibility principle
- Deeply nested decorators - can make debugging difficult
- Premature pattern application - adding complexity before it's needed

#### Testing Design Patterns

**Example**

```typescript
// Testing a Singleton
describe('Singleton', () => {
  it('should return the same instance', () => {
    const instance1 = Singleton.getInstance();
    const instance2 = Singleton.getInstance();
    
    expect(instance1).toBe(instance2);
  });
});

// Testing a Strategy pattern
describe('Strategy Pattern', () => {
  it('should sort in ascending order with strategy A', () => {
    const context = new Context(new ConcreteStrategyA());
    const data = ['e', 'a', 'c', 'b', 'd'];
    const result = context.executeStrategy(data);
    
    expect(result).toEqual(['a', 'b', 'c', 'd', 'e']);
  });
  
  it('should sort in descending order with strategy B', () => {
    const context = new Context(new ConcreteStrategyB());
    const data = ['e', 'a', 'c', 'b', 'd'];
    const result = context.executeStrategy(data);
    
    expect(result).toEqual(['e', 'd', 'c', 'b', 'a']);
  });
});
```

### Real-World Applications

#### UI Component Libraries

Many UI libraries use patterns like Composite for component trees, Observer for state management, and Decorator for component enhancement.

**Example**

```typescript
// Simple React-like Component system using Composite pattern
interface Component {
  render(): string;
}

class Text implements Component {
  private content: string;
  
  constructor(content: string) {
    this.content = content;
  }
  
  render(): string {
    return this.content;
  }
}

class Container implements Component {
  private children: Component[] = [];
  
  add(child: Component): void {
    this.children.push(child);
  }
  
  render(): string {
    return `<div>${this.children.map(child => child.render()).join('')}</div>`;
  }
}

// Usage
const page = new Container();
const header = new Container();
header.add(new Text('Header Text'));
page.add(header);

const content = new Container();
content.add(new Text('Main content goes here'));
page.add(content);

console.log(page.render());
```

#### State Management

The Observer pattern is commonly used in state management libraries.

```typescript
class Store {
  private state: any;
  private listeners: Function[] = [];
  
  constructor(initialState: any) {
    this.state = initialState;
  }
  
  getState(): any {
    return this.state;
  }
  
  setState(newState: any): void {
    this.state = { ...this.state, ...newState };
    this.notify();
  }
  
  subscribe(listener: Function): Function {
    this.listeners.push(listener);
    
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }
  
  private notify(): void {
    this.listeners.forEach(listener => listener(this.state));
  }
}

// Usage
const store = new Store({ user: null, isLoading: false });

const unsubscribe = store.subscribe((state) => {
  console.log('State changed:', state);
});

store.setState({ isLoading: true });
store.setState({ user: { name: 'John' }, isLoading: false });

unsubscribe();
```

### Advanced Pattern Combinations

Patterns often work best when combined strategically:

**Example**

```typescript
// Combining Factory and Singleton
class ConfigurationManager {
  private static instance: ConfigurationManager;
  private config: Record<string, any> = {};
  
  private constructor() {}
  
  public static getInstance(): ConfigurationManager {
    if (!ConfigurationManager.instance) {
      ConfigurationManager.instance = new ConfigurationManager();
    }
    
    return ConfigurationManager.instance;
  }
  
  public get(key: string): any {
    return this.config[key];
  }
  
  public set(key: string, value: any): void {
    this.config[key] = value;
  }
}

interface ApiService {
  fetchData(): Promise<any>;
}

class MockApiService implements ApiService {
  fetchData(): Promise<any> {
    return Promise.resolve({ mock: true, data: [1, 2, 3] });
  }
}

class ProductionApiService implements ApiService {
  fetchData(): Promise<any> {
    return fetch('https://api.example.com/data').then(res => res.json());
  }
}

class ApiServiceFactory {
  static createApiService(): ApiService {
    const config = ConfigurationManager.getInstance();
    const environment = config.get('environment');
    
    if (environment === 'development') {
      return new MockApiService();
    } else {
      return new ProductionApiService();
    }
  }
}

// Usage
const config = ConfigurationManager.getInstance();
config.set('environment', 'development');

const apiService = ApiServiceFactory.createApiService();
apiService.fetchData().then(data => console.log(data));
```

### Conclusion

Design patterns in TypeScript offer a powerful way to solve common software design problems. By leveraging TypeScript's static typing, interfaces, and object-oriented features, developers can implement these patterns more safely and with better tooling support. Understanding when and how to apply these patterns—whether Singleton, Factory, Observer, Adapter, or Decorator—is a critical skill for writing maintainable, flexible code.

The examples provided demonstrate how TypeScript enhances classic design patterns with type safety and modern language features. As you implement these patterns in your projects, remember to balance pattern usage with simplicity and maintainability, avoiding unnecessary complexity while maximizing the benefits of structured, reusable solutions.

### Related Topics

- Advanced TypeScript Types and Pattern Implementation
- Functional Programming Patterns in TypeScript
- Dependency Injection in TypeScript Applications
- Building Scalable Architecture with TypeScript and Design Patterns
- Testing Design Pattern Implementations with TypeScript Testing Tools

---

