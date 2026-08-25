## Behavioral Design Patterns


### Introduction to Behavioral Patterns

Behavioral design patterns focus on algorithms and the assignment of responsibilities between objects. They address how objects communicate with each other and how the flow of control moves through a system. These patterns help make complex communication between objects more manageable and flexible.

### Chain of Responsibility Pattern

The Chain of Responsibility pattern passes requests along a chain of handlers. Upon receiving a request, each handler decides either to process the request or pass it to the next handler in the chain.

#### Structure

1. **Handler**: Defines an interface for handling requests and maintaining a successor
2. **Concrete Handler**: Handles requests it's responsible for; passes others to successor
3. **Client**: Initiates the request to a handler in the chain

#### JavaScript Implementation

```javascript
// Handler interface
class SupportHandler {
  constructor() {
    this.nextHandler = null;
  }
  
  setNext(handler) {
    this.nextHandler = handler;
    return handler; // Return handler to allow chaining
  }
  
  handle(request) {
    if (this.nextHandler) {
      return this.nextHandler.handle(request);
    }
    return null;
  }
}

// Concrete handlers
class TechnicalSupportHandler extends SupportHandler {
  handle(request) {
    if (request.type === 'technical') {
      return `Technical support resolved issue: ${request.description}`;
    }
    return super.handle(request);
  }
}

class BillingSupportHandler extends SupportHandler {
  handle(request) {
    if (request.type === 'billing') {
      return `Billing department resolved issue: ${request.description}`;
    }
    return super.handle(request);
  }
}

class GeneralSupportHandler extends SupportHandler {
  handle(request) {
    return `General support addressed request: ${request.description}`;
  }
}

// Client code
const technical = new TechnicalSupportHandler();
const billing = new BillingSupportHandler();
const general = new GeneralSupportHandler();

// Set up the chain
technical.setNext(billing).setNext(general);

// Process requests
const requests = [
  { type: 'technical', description: 'My computer is not booting' },
  { type: 'billing', description: 'I was charged twice' },
  { type: 'general', description: 'How do I upgrade my account?' },
  { type: 'unknown', description: 'I found a bug in your software' }
];

requests.forEach(request => {
  console.log(technical.handle(request));
});

// Technical support resolved issue: My computer is not booting
// Billing department resolved issue: I was charged twice
// General support addressed request: How do I upgrade my account?
// General support addressed request: I found a bug in your software
```

#### Use Cases

- Processing a series of operations in sequence
- Building middleware chains (like in Express.js)
- Event handling systems
- Request handling in hierarchical systems

### Command Pattern

The Command pattern turns a request into a stand-alone object that contains all information about the request. This transformation allows for parameterization of clients with different requests, queue or log requests, and support undoable operations.

#### Structure

1. **Command**: Declares an interface for executing operations
2. **Concrete Command**: Implements the command interface
3. **Invoker**: Asks the command to execute the request
4. **Receiver**: Knows how to perform the operations
5. **Client**: Creates a command and sets its receiver

#### JavaScript Implementation

```javascript
// Receiver
class Light {
  constructor(location) {
    this.location = location;
    this.isOn = false;
  }
  
  turnOn() {
    this.isOn = true;
    console.log(`${this.location} light turned on`);
  }
  
  turnOff() {
    this.isOn = false;
    console.log(`${this.location} light turned off`);
  }
}

// Command interface
class Command {
  execute() {}
  undo() {}
}

// Concrete commands
class LightOnCommand extends Command {
  constructor(light) {
    super();
    this.light = light;
  }
  
  execute() {
    this.light.turnOn();
  }
  
  undo() {
    this.light.turnOff();
  }
}

class LightOffCommand extends Command {
  constructor(light) {
    super();
    this.light = light;
  }
  
  execute() {
    this.light.turnOff();
  }
  
  undo() {
    this.light.turnOn();
  }
}

// Invoker
class RemoteControl {
  constructor() {
    this.commands = {};
    this.history = [];
  }
  
  setCommand(buttonName, command) {
    this.commands[buttonName] = command;
  }
  
  pressButton(buttonName) {
    if (this.commands[buttonName]) {
      this.commands[buttonName].execute();
      this.history.push(this.commands[buttonName]);
    }
  }
  
  pressUndo() {
    const command = this.history.pop();
    if (command) {
      command.undo();
    }
  }
}

// Client code
const livingRoomLight = new Light('Living Room');
const kitchenLight = new Light('Kitchen');

const livingRoomLightOn = new LightOnCommand(livingRoomLight);
const livingRoomLightOff = new LightOffCommand(livingRoomLight);
const kitchenLightOn = new LightOnCommand(kitchenLight);
const kitchenLightOff = new LightOffCommand(kitchenLight);

const remote = new RemoteControl();
remote.setCommand('livingRoomLightOn', livingRoomLightOn);
remote.setCommand('livingRoomLightOff', livingRoomLightOff);
remote.setCommand('kitchenLightOn', kitchenLightOn);
remote.setCommand('kitchenLightOff', kitchenLightOff);

// Use the remote
remote.pressButton('livingRoomLightOn');  // Living Room light turned on
remote.pressButton('kitchenLightOn');     // Kitchen light turned on
remote.pressUndo();                       // Kitchen light turned off
remote.pressButton('livingRoomLightOff'); // Living Room light turned off
```

#### Use Cases

- Menu items, buttons, and other UI elements
- Transaction processing (execute, rollback)
- Task scheduling and queuing
- Macro recording systems
- Multi-level undo/redo functionality

### Interpreter Pattern

The Interpreter pattern defines a grammar for a language and provides an interpreter to evaluate sentences in that language. This pattern is useful for parsing and evaluating expressions in a defined grammar.

#### Structure

1. **Abstract Expression**: Declares an interpret operation
2. **Terminal Expression**: Implements interpret for terminal symbols
3. **Non-terminal Expression**: Implements interpret for non-terminal symbols
4. **Context**: Contains global information for the interpreter
5. **Client**: Builds and interprets the abstract syntax tree

#### JavaScript Implementation

```javascript
// Context
class Context {
  constructor() {
    this.variables = {};
  }
  
  setVariable(name, value) {
    this.variables[name] = value;
  }
  
  getVariable(name) {
    return this.variables[name] || 0;
  }
}

// Abstract Expression
class Expression {
  interpret(context) {}
}

// Terminal expressions
class NumberExpression extends Expression {
  constructor(value) {
    super();
    this.value = value;
  }
  
  interpret(context) {
    return this.value;
  }
}

class VariableExpression extends Expression {
  constructor(name) {
    super();
    this.name = name;
  }
  
  interpret(context) {
    return context.getVariable(this.name);
  }
}

// Non-terminal expressions
class AddExpression extends Expression {
  constructor(left, right) {
    super();
    this.left = left;
    this.right = right;
  }
  
  interpret(context) {
    return this.left.interpret(context) + this.right.interpret(context);
  }
}

class SubtractExpression extends Expression {
  constructor(left, right) {
    super();
    this.left = left;
    this.right = right;
  }
  
  interpret(context) {
    return this.left.interpret(context) - this.right.interpret(context);
  }
}

class MultiplyExpression extends Expression {
  constructor(left, right) {
    super();
    this.left = left;
    this.right = right;
  }
  
  interpret(context) {
    return this.left.interpret(context) * this.right.interpret(context);
  }
}

// Client code (parser)
function parseExpression(expression) {
  const stack = [];
  
  for (const token of expression.split(' ')) {
    if (token === '+') {
      const right = stack.pop();
      const left = stack.pop();
      stack.push(new AddExpression(left, right));
    } else if (token === '-') {
      const right = stack.pop();
      const left = stack.pop();
      stack.push(new SubtractExpression(left, right));
    } else if (token === '*') {
      const right = stack.pop();
      const left = stack.pop();
      stack.push(new MultiplyExpression(left, right));
    } else if (!isNaN(token)) {
      stack.push(new NumberExpression(parseInt(token)));
    } else {
      stack.push(new VariableExpression(token));
    }
  }
  
  return stack.pop();
}

// Usage
const context = new Context();
context.setVariable('x', 10);
context.setVariable('y', 5);

// Reverse Polish Notation: x y + 5 *
const expression = parseExpression('x y + 5 *');
console.log(expression.interpret(context)); // (10 + 5) * 5 = 75
```

#### Use Cases

- DSL (Domain Specific Language) interpreters
- SQL parsers
- Regular expression engines
- Mathematical expression evaluators
- Configuration parsers

### Iterator Pattern

The Iterator pattern provides a way to access elements of an aggregate object sequentially without exposing its underlying representation.

#### Structure

1. **Iterator**: Interface for accessing and traversing elements
2. **Concrete Iterator**: Implements the Iterator interface
3. **Aggregate**: Interface for creating an Iterator
4. **Concrete Aggregate**: Implements the Aggregate interface

#### JavaScript Implementation

```javascript
// Iterator
class Iterator {
  hasNext() {}
  next() {}
}

// Concrete Iterator
class ArrayIterator extends Iterator {
  constructor(collection) {
    super();
    this.collection = collection;
    this.index = 0;
  }
  
  hasNext() {
    return this.index < this.collection.length;
  }
  
  next() {
    return this.hasNext() ? this.collection[this.index++] : null;
  }
}

// Concrete Iterator with Filter
class EvenNumberIterator extends Iterator {
  constructor(collection) {
    super();
    this.collection = collection;
    this.index = 0;
  }
  
  hasNext() {
    while (this.index < this.collection.length) {
      if (this.collection[this.index] % 2 === 0) {
        return true;
      }
      this.index++;
    }
    return false;
  }
  
  next() {
    if (this.hasNext()) {
      return this.collection[this.index++];
    }
    return null;
  }
}

// Aggregate
class Collection {
  getIterator() {}
}

// Concrete Aggregate
class NumberCollection extends Collection {
  constructor() {
    super();
    this.numbers = [];
  }
  
  add(number) {
    this.numbers.push(number);
  }
  
  getIterator() {
    return new ArrayIterator(this.numbers);
  }
  
  getEvenNumberIterator() {
    return new EvenNumberIterator(this.numbers);
  }
}

// Client code
const numbers = new NumberCollection();
numbers.add(1);
numbers.add(2);
numbers.add(3);
numbers.add(4);
numbers.add(5);
numbers.add(6);

// Using regular iterator
const iterator = numbers.getIterator();
console.log("All numbers:");
while (iterator.hasNext()) {
  console.log(iterator.next());
}
// 1, 2, 3, 4, 5, 6

// Using filtered iterator
const evenIterator = numbers.getEvenNumberIterator();
console.log("Even numbers:");
while (evenIterator.hasNext()) {
  console.log(evenIterator.next());
}
// 2, 4, 6
```

#### JavaScript Built-in Iterators

JavaScript provides built-in iterator support via the Iterable protocol:

```javascript
class CustomCollection {
  constructor() {
    this.items = [];
  }
  
  add(item) {
    this.items.push(item);
  }
  
  // Implementing the iterable protocol
  [Symbol.iterator]() {
    let index = 0;
    const items = this.items;
    
    return {
      next() {
        return index < items.length
          ? { value: items[index++], done: false }
          : { done: true };
      }
    };
  }
}

// Usage with built-in iteration
const collection = new CustomCollection();
collection.add('apple');
collection.add('banana');
collection.add('cherry');

// Using for...of loop with our iterable
for (const item of collection) {
  console.log(item);
}
// apple, banana, cherry

// Using spread operator
console.log([...collection]); // ['apple', 'banana', 'cherry']
```

#### Use Cases

- Sequential access to elements in collections
- Decoupling traversal from underlying data structure
- Supporting multiple traversal strategies
- Providing a uniform interface for traversing different structures

### Mediator Pattern

The Mediator pattern defines an object that encapsulates how a set of objects interact. It promotes loose coupling by keeping objects from referring to each other explicitly, allowing them to interact indirectly through the mediator.

#### Structure

1. **Mediator**: Defines an interface for communicating with colleague objects
2. **Concrete Mediator**: Implements the mediator interface
3. **Colleague**: Objects that communicate through the mediator
4. **Concrete Colleague**: Implements the colleague interface

#### JavaScript Implementation

```javascript
// Mediator interface
class ChatMediator {
  sendMessage(message, sender) {}
  addUser(user) {}
}

// Concrete Mediator
class ChatRoom extends ChatMediator {
  constructor() {
    super();
    this.users = [];
  }
  
  addUser(user) {
    this.users.push(user);
  }
  
  sendMessage(message, sender) {
    // Broadcast the message to all users except the sender
    this.users.forEach(user => {
      if (user !== sender) {
        user.receiveMessage(message, sender);
      }
    });
  }
}

// Colleague interface
class User {
  constructor(name, mediator) {
    this.name = name;
    this.mediator = mediator;
  }
  
  sendMessage(message) {}
  receiveMessage(message, sender) {}
}

// Concrete Colleagues
class ChatUser extends User {
  constructor(name, mediator) {
    super(name, mediator);
    this.mediator.addUser(this);
  }
  
  sendMessage(message) {
    console.log(`${this.name} sends: ${message}`);
    this.mediator.sendMessage(message, this);
  }
  
  receiveMessage(message, sender) {
    console.log(`${this.name} receives from ${sender.name}: ${message}`);
  }
}

// Client code
const chatroom = new ChatRoom();

const alice = new ChatUser('Alice', chatroom);
const bob = new ChatUser('Bob', chatroom);
const charlie = new ChatUser('Charlie', chatroom);

alice.sendMessage('Hello everyone!');
// Alice sends: Hello everyone!
// Bob receives from Alice: Hello everyone!
// Charlie receives from Alice: Hello everyone!

bob.sendMessage('Hi Alice!');
// Bob sends: Hi Alice!
// Alice receives from Bob: Hi Alice!
// Charlie receives from Bob: Hi Alice!
```

#### Use Cases

- Coordinating interactions between multiple objects
- Centralizing complex communications
- Reducing complexity in object interactions
- UI components that need to communicate with each other
- Air traffic control systems
- Chat applications

### Memento Pattern

The Memento pattern captures and externalizes an object's internal state so that the object can be restored to this state later, without violating encapsulation.

#### Structure

1. **Originator**: Creates a memento containing a snapshot of its current state
2. **Memento**: Stores the internal state of the Originator
3. **Caretaker**: Keeps track of the mementos but never modifies them

#### JavaScript Implementation

```javascript
// Memento
class EditorMemento {
  constructor(content, cursorPosition) {
    this._content = content;
    this._cursorPosition = cursorPosition;
  }
  
  // Only the originator can access these methods
  _getContent() {
    return this._content;
  }
  
  _getCursorPosition() {
    return this._cursorPosition;
  }
}

// Originator
class TextEditor {
  constructor() {
    this.content = '';
    this.cursorPosition = 0;
  }
  
  type(text) {
    this.content = this.content.slice(0, this.cursorPosition) + 
                   text + 
                   this.content.slice(this.cursorPosition);
    this.cursorPosition += text.length;
    console.log(`Content: "${this.content}", Cursor at: ${this.cursorPosition}`);
  }
  
  delete(chars) {
    if (this.cursorPosition >= chars) {
      this.content = this.content.slice(0, this.cursorPosition - chars) + 
                     this.content.slice(this.cursorPosition);
      this.cursorPosition -= chars;
      console.log(`Content: "${this.content}", Cursor at: ${this.cursorPosition}`);
    }
  }
  
  moveCursor(position) {
    if (position >= 0 && position <= this.content.length) {
      this.cursorPosition = position;
      console.log(`Cursor moved to: ${this.cursorPosition}`);
    }
  }
  
  // Create a memento
  save() {
    return new EditorMemento(this.content, this.cursorPosition);
  }
  
  // Restore from memento
  restore(memento) {
    this.content = memento._getContent();
    this.cursorPosition = memento._getCursorPosition();
    console.log(`Restored to: "${this.content}", Cursor at: ${this.cursorPosition}`);
  }
}

// Caretaker
class EditorHistory {
  constructor() {
    this.states = [];
    this.currentIndex = -1;
  }
  
  push(state) {
    // Remove any future states if we're in the middle of the history
    if (this.currentIndex < this.states.length - 1) {
      this.states = this.states.slice(0, this.currentIndex + 1);
    }
    
    this.states.push(state);
    this.currentIndex++;
  }
  
  undo() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      return this.states[this.currentIndex];
    }
    return null;
  }
  
  redo() {
    if (this.currentIndex < this.states.length - 1) {
      this.currentIndex++;
      return this.states[this.currentIndex];
    }
    return null;
  }
}

// Client code
const editor = new TextEditor();
const history = new EditorHistory();

// Initial state
history.push(editor.save());

// Make some changes
editor.type('Hello');  // Content: "Hello", Cursor at: 5
history.push(editor.save());

editor.type(' world');  // Content: "Hello world", Cursor at: 11
history.push(editor.save());

editor.delete(5);  // Content: "Hello ", Cursor at: 6
history.push(editor.save());

// Undo changes
let previousState = history.undo();
editor.restore(previousState);  // Restored to: "Hello world", Cursor at: 11

previousState = history.undo();
editor.restore(previousState);  // Restored to: "Hello", Cursor at: 5

// Redo
let nextState = history.redo();
editor.restore(nextState);  // Restored to: "Hello world", Cursor at: 11
```

#### Use Cases

- Implementing undo/redo operations
- Providing transaction rollbacks
- Saving and restoring application state
- Creating snapshots for later restoration
- Game save systems

### Observer Pattern

The Observer pattern defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically.

#### Structure

1. **Subject**: Maintains a list of observers and provides methods to add/remove them
2. **Observer**: Defines an update interface for objects that should be notified
3. **Concrete Subject**: Broadcasts notifications to observers when state changes
4. **Concrete Observer**: Implements the update interface to respond to subject changes

#### JavaScript Implementation

```javascript
// Observer interface
class Observer {
  update(subject) {}
}

// Subject
class Subject {
  constructor() {
    this.observers = [];
  }
  
  addObserver(observer) {
    this.observers.push(observer);
  }
  
  removeObserver(observer) {
    const index = this.observers.indexOf(observer);
    if (index !== -1) {
      this.observers.splice(index, 1);
    }
  }
  
  notify() {
    this.observers.forEach(observer => observer.update(this));
  }
}

// Concrete Subject
class WeatherStation extends Subject {
  constructor() {
    super();
    this.temperature = 0;
    this.humidity = 0;
    this.pressure = 0;
  }
  
  setMeasurements(temperature, humidity, pressure) {
    this.temperature = temperature;
    this.humidity = humidity;
    this.pressure = pressure;
    this.notify();
  }
  
  getTemperature() {
    return this.temperature;
  }
  
  getHumidity() {
    return this.humidity;
  }
  
  getPressure() {
    return this.pressure;
  }
}

// Concrete Observer
class Display extends Observer {
  constructor(name) {
    super();
    this.name = name;
  }
  
  update(subject) {
    const temperature = subject.getTemperature();
    const humidity = subject.getHumidity();
    const pressure = subject.getPressure();
    
    console.log(`${this.name} Display: Temperature ${temperature}°C, Humidity ${humidity}%, Pressure ${pressure}hPa`);
  }
}

// Client code
const weatherStation = new WeatherStation();

const phoneDisplay = new Display('Phone');
const computerDisplay = new Display('Computer');
const tabletDisplay = new Display('Tablet');

weatherStation.addObserver(phoneDisplay);
weatherStation.addObserver(computerDisplay);
weatherStation.addObserver(tabletDisplay);

weatherStation.setMeasurements(22, 65, 1013);
// Phone Display: Temperature 22°C, Humidity 65%, Pressure 1013hPa
// Computer Display: Temperature 22°C, Humidity 65%, Pressure 1013hPa
// Tablet Display: Temperature 22°C, Humidity 65%, Pressure 1013hPa

// Remove one observer
weatherStation.removeObserver(tabletDisplay);

weatherStation.setMeasurements(23, 70, 1015);
// Phone Display: Temperature 23°C, Humidity 70%, Pressure 1015hPa
// Computer Display: Temperature 23°C, Humidity 70%, Pressure 1015hPa
```

#### JavaScript's Event System

JavaScript has built-in support for the Observer pattern through the Event system:

```javascript
// Simple event system
class EventEmitter {
  constructor() {
    this.events = {};
  }
  
  on(eventName, listener) {
    if (!this.events[eventName]) {
      this.events[eventName] = [];
    }
    this.events[eventName].push(listener);
    return this; // For chaining
  }
  
  off(eventName, listener) {
    if (this.events[eventName]) {
      this.events[eventName] = this.events[eventName].filter(l => l !== listener);
    }
    return this;
  }
  
  emit(eventName, ...args) {
    if (this.events[eventName]) {
      this.events[eventName].forEach(listener => listener(...args));
    }
    return this;
  }
}

// Usage
const thermostat = new EventEmitter();

function temperatureListener(temperature) {
  console.log(`Temperature changed to ${temperature}°C`);
}

function alertListener(temperature) {
  if (temperature > 30) {
    console.log('ALERT: Temperature too high!');
  }
}

thermostat.on('temperatureChange', temperatureListener);
thermostat.on('temperatureChange', alertListener);

thermostat.emit('temperatureChange', 25); // Temperature changed to 25°C
thermostat.emit('temperatureChange', 32); // Temperature changed to 32°C, ALERT: Temperature too high!

thermostat.off('temperatureChange', alertListener);
thermostat.emit('temperatureChange', 35); // Temperature changed to 35°C (no alert)
```

#### Use Cases

- Implementing distributed event handling systems
- Implementing MVC pattern (Model-View-Controller)
- Implementing subscription features in applications
- Broadcasting changes to multiple dependent objects
- Real-time data monitoring systems

### State Pattern

The State pattern allows an object to alter its behavior when its internal state changes. The object will appear to change its class.

#### Structure

1. **Context**: Maintains an instance of a ConcreteState subclass
2. **State**: Defines an interface for encapsulating behavior associated with a state
3. **Concrete State**: Implements behavior associated with a state of the context

#### JavaScript Implementation

```javascript
// State interface
class State {
  constructor(player) {
    this.player = player;
  }
  
  play() {}
  pause() {}
  stop() {}
  nextTrack() {}
  previousTrack() {}
}

// Concrete States
class PlayingState extends State {
  constructor(player) {
    super(player);
    console.log('Player is in Playing state');
  }
  
  play() {
    console.log('Already playing');
  }
  
  pause() {
    console.log('Pausing');
    this.player.setState(this.player.pausedState);
  }
  
  stop() {
    console.log('Stopping');
    this.player.setState(this.player.stoppedState);
  }
  
  nextTrack() {
    console.log('Moving to next track');
  }
  
  previousTrack() {
    console.log('Moving to previous track');
  }
}

class PausedState extends State {
  constructor(player) {
    super(player);
    console.log('Player is in Paused state');
  }
  
  play() {
    console.log('Resuming playback');
    this.player.setState(this.player.playingState);
  }
  
  pause() {
    console.log('Already paused');
  }
  
  stop() {
    console.log('Stopping');
    this.player.setState(this.player.stoppedState);
  }
  
  nextTrack() {
    console.log('Cannot change track while paused');
  }
  
  previousTrack() {
    console.log('Cannot change track while paused');
  }
}

class StoppedState extends State {
  constructor(player) {
    super(player);
    console.log('Player is in Stopped state');
  }
  
  play() {
    console.log('Starting playback');
    this.player.setState(this.player.playingState);
  }
  
  pause() {
    console.log('Cannot pause when stopped');
  }
  
  stop() {
    console.log('Already stopped');
  }
  
  nextTrack() {
    console.log('Cannot change track when stopped');
  }
  
  previousTrack() {
    console.log('Cannot change track when stopped');
  }
}

// Context
class MusicPlayer {
  constructor() {
    this.playingState = new PlayingState(this);
    this.pausedState = new PausedState(this);
    this.stoppedState = new StoppedState(this);
    
    // Initial state
    this.state = this.stoppedState;
  }
  
  setState(state) {
    this.state = state;
  }
  
  play() {
    this.state.play();
  }
  
  pause() {
    this.state.pause();
  }
  
  stop() {
    this.state.stop();
  }
  
  nextTrack() {
    this.state.nextTrack();
  }
  
  previousTrack() {
    this.state.previousTrack();
  }
}

// Client code
const player = new MusicPlayer();
// Player is in Stopped state

player.play();
// Starting playback
// Player is in Playing state

player.nextTrack();
// Moving to next track

player.pause();
// Pausing
// Player is in Paused state

player.nextTrack();
// Cannot change track while paused

player.play();
// Resuming playback
// Player is in Playing state

player.stop();
// Stopping
// Player is in Stopped state
```

#### Use Cases

- Implementing state machines
- Simplifying complex conditional logic based on object state
- Implementing workflows with different stages
- UI element behavior based on its state
- Game character behavior based on current state (idle, walking, running)

### Strategy Pattern

The Strategy pattern defines a family of algorithms, encapsulates each one, and makes them interchangeable. This pattern lets the algorithm vary independently from clients that use it.

#### Structure

1. **Strategy**: Declares an interface common to all supported algorithms
2. **Concrete Strategy**: Implements the algorithm using the Strategy interface
3. **Context**: Maintains a reference to a Strategy object and delegates algorithm execution to it

#### JavaScript Implementation

```javascript
// Strategy interface
class PaymentStrategy {
  pay(amount) {}
  validate() {}
}

// Concrete Strategies
class CreditCardStrategy extends PaymentStrategy {
  constructor(name, cardNumber, cvv, expirationDate) {
    super();
    this.name = name;
    this.cardNumber = cardNumber;
    this.cvv = cvv;
    this.expirationDate = expirationDate;
  }
  
  pay(amount) {
    console.log(`Paid ${amount} using Credit Card`);
    return true;
  }
  
  validate() {
    // Simplified validation
    if (this.cardNumber.length !== 16) {
      throw new Error('Invalid card number');
    }
    if (this.cvv.length !== 3) {
      throw new Error('Invalid CVV');
    }
    return true;
  }
}

class PayPalStrategy extends PaymentStrategy {
  constructor(email, password) {
    super();
    this.email = email;
    this.password = password;
  }
  
  pay(amount) {
    console.log(`Paid ${amount} using PayPal`);
    return true;
  }
  
  validate() {
    // Simplified validation
    if (!this.email.includes('@')) {
      throw new Error('Invalid email');
    }
    return true;
  }
}

class BankTransferStrategy extends PaymentStrategy {
  constructor(accountName, routingNumber, accountNumber) {
    super();
    this.accountName = accountName;
    this.routingNumber = routingNumber;
    this.accountNumber = accountNumber;
  }
  
  pay(amount) {
    console.log(`Paid ${amount} via Bank Transfer`);
    return true;
  }

  validate() {
    if (!this.routingNumber || !this.accountNumber) {
      throw new Error('Bank details are incomplete');
    }
    return true;
  }
}
```

---

#### **Context Class**

```javascript
class PaymentContext {
  constructor(strategy) {
    this.strategy = strategy;
  }

  setStrategy(strategy) {
    this.strategy = strategy;
  }

  executePayment(amount) {
    this.strategy.validate();
    return this.strategy.pay(amount);
  }
}
```

---

**Example**

```javascript
const creditCard = new CreditCardStrategy("Alice", "1234567812345678", "123", "12/26");
const paypal = new PayPalStrategy("alice@example.com", "securePassword");
const bankTransfer = new BankTransferStrategy("Alice", "021000021", "123456789");

const payment = new PaymentContext(creditCard);
payment.executePayment(100); // Output: Paid 100 using Credit Card

payment.setStrategy(paypal);
payment.executePayment(50); // Output: Paid 50 using PayPal

payment.setStrategy(bankTransfer);
payment.executePayment(200); // Output: Paid 200 via Bank Transfer
```

---

**Key Points**

- Encapsulates different algorithms (payment methods) and enables switching between them at runtime.
- Follows **Open/Closed Principle**: You can add new strategies without modifying the context.
- Promotes **composition over inheritance** by injecting behavior into objects.

---

#### **Advantages**

- Makes code flexible and reusable by separating concerns.
- Easy to add new algorithms (strategies) without changing existing code.
- Clients are not dependent on concrete strategy implementations.

---

#### **Disadvantages**

- More classes and complexity: Each strategy requires a separate class or function.
- Clients must be aware of different strategies to choose the appropriate one.

---

**Conclusion**

The Strategy Pattern enables dynamic selection of algorithms at runtime, promoting clean separation of behaviors and high flexibility. It is ideal when multiple interchangeable behaviors are needed without modifying the consuming code.

---

