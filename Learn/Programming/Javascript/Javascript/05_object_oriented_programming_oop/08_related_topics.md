## Related Topics


### TypeScript and Classes

TypeScript extends JavaScript's class syntax with additional features:

```typescript
// Access modifiers
class Employee {
  private id: number;
  protected salary: number;
  public name: string;
  
  constructor(id: number, name: string, salary: number) {
    this.id = id;
    this.name = name;
    this.salary = salary;
  }
  
  // Method overloads
  promote(): void;
  promote(amount: number): void;
  promote(amount?: number): void {
    if (amount) {
      this.salary += amount;
    } else {
      this.salary += 1000;
    }
  }
}

// Interfaces for classes
interface Workable {
  work(): void;
  takeBreak(): void;
}

class Developer extends Employee implements Workable {
  work() {
    console.log("Writing code");
  }
  
  takeBreak() {
    console.log("Coffee break");
  }
}
```

### Decorator Pattern

Decorators (available with TypeScript and as a stage 3 proposal for JavaScript) allow adding behaviors to classes:

```javascript
// Class decorator
function sealed(constructor) {
  Object.seal(constructor);
  Object.seal(constructor.prototype);
}

// Method decorator
function log(target, name, descriptor) {
  const original = descriptor.value;
  
  descriptor.value = function(...args) {
    console.log(`Calling ${name} with arguments: ${args}`);
    const result = original.apply(this, args);
    console.log(`Method ${name} returned: ${result}`);
    return result;
  };
  
  return descriptor;
}

// Property decorator
function readonly(target, name, descriptor) {
  descriptor.writable = false;
  return descriptor;
}

@sealed
class Example {
  @readonly
  version = '1.0.0';
  
  @log
  multiply(a, b) {
    return a * b;
  }
}
```

### JavaScript Module Systems and Classes

Classes work well with ES6 modules, allowing cleaner code organization:

```javascript
// shapes.js
export class Shape {
  constructor(color) {
    this.color = color;
  }
  
  getColor() {
    return this.color;
  }
}

export class Rectangle extends Shape {
  constructor(color, width, height) {
    super(color);
    this.width = width;
    this.height = height;
  }
  
  getArea() {
    return this.width * this.height;
  }
}

// main.js
import { Rectangle } from './shapes.js';

const rect = new Rectangle('blue', 10, 5);
console.log(rect.getColor()); // 'blue'
console.log(rect.getArea());  // 50
```

### Framework Context

Many modern JavaScript frameworks rely heavily on classes:

```javascript
// Angular component example
@Component({
  selector: 'app-user',
  template: '<h1>{{ user.name }}</h1>'
})
export class UserComponent implements OnInit {
  user: User;
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    this.user = this.userService.getCurrentUser();
  }
}

// React class component example
class Counter extends React.Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
  }
  
  increment = () => {
    this.setState({ count: this.state.count + 1 });
  }
  
  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.increment}>Increment</button>
      </div>
    );
  }
}
```

---

