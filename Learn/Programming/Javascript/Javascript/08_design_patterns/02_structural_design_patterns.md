## Structural Design Patterns


### Introduction to Structural Patterns

Structural design patterns focus on how classes and objects are composed to form larger structures. They help ensure that when parts of a system change, the entire system doesn't need to change. These patterns simplify the design by identifying simple ways to realize relationships between entities.

### Adapter Pattern

The Adapter pattern allows objects with incompatible interfaces to collaborate. It acts as a bridge between two incompatible interfaces by wrapping an instance of one class into an adapter class that presents the interface expected by clients.

#### Structure

1. **Target Interface**: The interface that clients expect or use
2. **Adaptee**: The existing class with an incompatible interface
3. **Adapter**: The class that bridges the gap between Target and Adaptee

#### JavaScript Implementation

```javascript
// Target interface
class ModernPaymentProcessor {
  processPayment(amount) {
    console.log(`Processing modern payment of $${amount}`);
  }
}

// Adaptee (incompatible interface)
class LegacyPaymentSystem {
  makePayment(dollars, cents) {
    const total = dollars + cents/100;
    console.log(`Legacy system processing payment of $${total}`);
  }
}

// Adapter
class PaymentSystemAdapter extends ModernPaymentProcessor {
  constructor(legacySystem) {
    super();
    this.legacySystem = legacySystem;
  }
  
  processPayment(amount) {
    // Convert the interface
    const dollars = Math.floor(amount);
    const cents = Math.round((amount - dollars) * 100);
    this.legacySystem.makePayment(dollars, cents);
  }
}

// Client code
function clientCode(paymentProcessor) {
  paymentProcessor.processPayment(125.75);
}

// Usage
const modern = new ModernPaymentProcessor();
clientCode(modern); // "Processing modern payment of $125.75"

const legacy = new LegacyPaymentSystem();
const adapter = new PaymentSystemAdapter(legacy);
clientCode(adapter); // "Legacy system processing payment of $125.75"
```

#### Use Cases

- Integrating legacy systems with modern code
- Interfacing with third-party libraries
- Creating reusable code that depends on libraries outside of your control

### Bridge Pattern

The Bridge pattern separates an abstraction from its implementation so that both can vary independently. It's particularly useful when you need to avoid a permanent binding between an abstraction and its implementation.

#### Structure

1. **Abstraction**: High-level interface that delegates to the implementation
2. **Implementation**: Interface for implementation classes
3. **Refined Abstraction**: Extensions of the abstraction
4. **Concrete Implementation**: Specific implementations

#### JavaScript Implementation

```javascript
// Implementation interface
class DeviceImplementation {
  turnOn() {}
  turnOff() {}
  setChannel(channel) {}
  getChannel() {}
  setVolume(percent) {}
  getVolume() {}
}

// Concrete implementations
class TV extends DeviceImplementation {
  constructor() {
    super();
    this.channel = 1;
    this.volume = 50;
    this.on = false;
  }
  
  turnOn() {
    this.on = true;
    console.log('TV turned on');
  }
  
  turnOff() {
    this.on = false;
    console.log('TV turned off');
  }
  
  setChannel(channel) {
    this.channel = channel;
    console.log(`TV channel set to ${channel}`);
  }
  
  getChannel() {
    return this.channel;
  }
  
  setVolume(percent) {
    this.volume = percent;
    console.log(`TV volume set to ${percent}%`);
  }
  
  getVolume() {
    return this.volume;
  }
}

class Radio extends DeviceImplementation {
  constructor() {
    super();
    this.channel = 88.5; // FM frequency
    this.volume = 30;
    this.on = false;
  }
  
  turnOn() {
    this.on = true;
    console.log('Radio turned on');
  }
  
  turnOff() {
    this.on = false;
    console.log('Radio turned off');
  }
  
  setChannel(channel) {
    this.channel = channel;
    console.log(`Radio frequency set to ${channel} MHz`);
  }
  
  getChannel() {
    return this.channel;
  }
  
  setVolume(percent) {
    this.volume = percent;
    console.log(`Radio volume set to ${percent}%`);
  }
  
  getVolume() {
    return this.volume;
  }
}

// Abstraction
class RemoteControl {
  constructor(device) {
    this.device = device;
  }
  
  togglePower() {
    if (this.device.on) {
      this.device.turnOff();
    } else {
      this.device.turnOn();
    }
  }
  
  channelUp() {
    this.device.setChannel(this.device.getChannel() + 1);
  }
  
  channelDown() {
    this.device.setChannel(this.device.getChannel() - 1);
  }
  
  volumeUp() {
    this.device.setVolume(Math.min(100, this.device.getVolume() + 10));
  }
  
  volumeDown() {
    this.device.setVolume(Math.max(0, this.device.getVolume() - 10));
  }
}

// Refined abstraction
class AdvancedRemoteControl extends RemoteControl {
  constructor(device) {
    super(device);
  }
  
  mute() {
    this.device.setVolume(0);
  }
  
  goToChannel(channel) {
    this.device.setChannel(channel);
  }
}

// Usage
const tv = new TV();
const remote = new RemoteControl(tv);
remote.togglePower(); // "TV turned on"
remote.volumeUp(); // "TV volume set to 60%"
remote.channelUp(); // "TV channel set to 2"

const radio = new Radio();
const advancedRemote = new AdvancedRemoteControl(radio);
advancedRemote.togglePower(); // "Radio turned on"
advancedRemote.goToChannel(103.5); // "Radio frequency set to 103.5 MHz"
advancedRemote.mute(); // "Radio volume set to 0%"
```

#### Use Cases

- When you want to avoid a permanent binding between an abstraction and its implementation
- When both the abstraction and implementation should be extensible through subclasses
- When changes in the implementation shouldn't impact the client code

### Composite Pattern

The Composite pattern lets you compose objects into tree structures to represent part-whole hierarchies. It allows clients to treat individual objects and compositions of objects uniformly.

#### Structure

1. **Component**: Common interface for all concrete classes
2. **Leaf**: Basic element with no sub-elements
3. **Composite**: Element that can contain other elements

#### JavaScript Implementation

```javascript
// Component
class FileSystemComponent {
  constructor(name) {
    this.name = name;
  }
  
  getSize() {}
  
  display(indent = '') {}
}

// Leaf
class File extends FileSystemComponent {
  constructor(name, size) {
    super(name);
    this.size = size;
  }
  
  getSize() {
    return this.size;
  }
  
  display(indent = '') {
    console.log(`${indent}File: ${this.name} (${this.size} bytes)`);
  }
}

// Composite
class Directory extends FileSystemComponent {
  constructor(name) {
    super(name);
    this.children = [];
  }
  
  add(component) {
    this.children.push(component);
    return this;
  }
  
  remove(component) {
    const index = this.children.indexOf(component);
    if (index > -1) {
      this.children.splice(index, 1);
    }
  }
  
  getSize() {
    return this.children.reduce((sum, child) => sum + child.getSize(), 0);
  }
  
  display(indent = '') {
    console.log(`${indent}Directory: ${this.name} (${this.getSize()} bytes)`);
    this.children.forEach(child => child.display(indent + '  '));
  }
}

// Usage
const root = new Directory('root');
const docs = new Directory('documents');
const music = new Directory('music');

const resume = new File('resume.pdf', 1024);
const coverletter = new File('cover.pdf', 2048);

const song1 = new File('song1.mp3', 4096);
const song2 = new File('song2.mp3', 4096);

docs.add(resume).add(coverletter);
music.add(song1).add(song2);
root.add(docs).add(music);

root.display();
// Directory: root (11264 bytes)
//   Directory: documents (3072 bytes)
//     File: resume.pdf (1024 bytes)
//     File: cover.pdf (2048 bytes)
//   Directory: music (8192 bytes)
//     File: song1.mp3 (4096 bytes)
//     File: song2.mp3 (4096 bytes)
```

#### Use Cases

- Representing part-whole hierarchies of objects
- When clients should be able to ignore the difference between compositions of objects and individual objects
- GUI component hierarchies, file systems, organization structures

### Decorator Pattern

The Decorator pattern lets you attach new behaviors to objects by placing them inside wrapper objects that contain these behaviors. It provides a flexible alternative to subclassing for extending functionality.

#### Structure

1. **Component**: Interface for objects that can have responsibilities added dynamically
2. **Concrete Component**: Base object that can be enhanced
3. **Decorator**: Abstract class that maintains a reference to a Component object
4. **Concrete Decorator**: Adds responsibilities to the component

#### JavaScript Implementation

```javascript
// Component Interface
class Coffee {
  getCost() {}
  getDescription() {}
}

// Concrete Component
class SimpleCoffee extends Coffee {
  getCost() {
    return 10;
  }
  
  getDescription() {
    return "Simple coffee";
  }
}

// Decorator
class CoffeeDecorator extends Coffee {
  constructor(coffee) {
    super();
    this.coffee = coffee;
  }
  
  getCost() {
    return this.coffee.getCost();
  }
  
  getDescription() {
    return this.coffee.getDescription();
  }
}

// Concrete Decorators
class MilkDecorator extends CoffeeDecorator {
  constructor(coffee) {
    super(coffee);
  }
  
  getCost() {
    return this.coffee.getCost() + 2;
  }
  
  getDescription() {
    return `${this.coffee.getDescription()}, milk`;
  }
}

class WhipDecorator extends CoffeeDecorator {
  constructor(coffee) {
    super(coffee);
  }
  
  getCost() {
    return this.coffee.getCost() + 5;
  }
  
  getDescription() {
    return `${this.coffee.getDescription()}, whip`;
  }
}

class VanillaDecorator extends CoffeeDecorator {
  constructor(coffee) {
    super(coffee);
  }
  
  getCost() {
    return this.coffee.getCost() + 3;
  }
  
  getDescription() {
    return `${this.coffee.getDescription()}, vanilla`;
  }
}

// Usage
let coffee = new SimpleCoffee();
console.log(`${coffee.getDescription()}: $${coffee.getCost()}`);
// Simple coffee: $10

coffee = new MilkDecorator(coffee);
console.log(`${coffee.getDescription()}: $${coffee.getCost()}`);
// Simple coffee, milk: $12

coffee = new WhipDecorator(coffee);
console.log(`${coffee.getDescription()}: $${coffee.getCost()}`);
// Simple coffee, milk, whip: $17

coffee = new VanillaDecorator(coffee);
console.log(`${coffee.getDescription()}: $${coffee.getCost()}`);
// Simple coffee, milk, whip, vanilla: $20
```

#### Use Cases

- Adding responsibilities to objects dynamically without affecting other objects
- For responsibilities that can be withdrawn
- When extension by subclassing is impractical
- Common in UI component libraries and middleware systems

### Facade Pattern

The Facade pattern provides a simplified interface to a complex subsystem of classes, library, or framework. It doesn't encapsulate the subsystem but provides a simplified interface to it.

#### Structure

1. **Facade**: Provides a simple interface to the complex subsystem
2. **Complex Subsystem**: Consists of numerous objects that work together

#### JavaScript Implementation

```javascript
// Complex subsystem classes
class AudioPlayer {
  constructor() {
    this.volume = 5;
    this.playing = false;
  }
  
  turnOn() {
    console.log("Audio player turning on");
  }
  
  turnOff() {
    console.log("Audio player turning off");
    this.playing = false;
  }
  
  play(track) {
    this.playing = true;
    console.log(`Playing audio track: ${track}`);
  }
  
  stop() {
    if (this.playing) {
      console.log("Stopping audio playback");
      this.playing = false;
    }
  }
  
  setVolume(level) {
    this.volume = level;
    console.log(`Volume set to ${level}`);
  }
}

class Screen {
  turnOn() {
    console.log("Screen turning on");
  }
  
  turnOff() {
    console.log("Screen turning off");
  }
  
  show(image) {
    console.log(`Displaying image: ${image}`);
  }
}

class StreamingService {
  constructor() {
    this.authorized = false;
  }
  
  login(username, password) {
    console.log(`Logging in as ${username}`);
    this.authorized = true;
  }
  
  logout() {
    console.log("Logging out");
    this.authorized = false;
  }
  
  streamMovie(movie) {
    if (this.authorized) {
      console.log(`Streaming movie: ${movie}`);
      return { audio: `${movie} soundtrack`, video: `${movie} visuals` };
    } else {
      console.log("Not authorized to stream");
      return null;
    }
  }
}

// Facade
class HomeTheaterFacade {
  constructor() {
    this.audioPlayer = new AudioPlayer();
    this.screen = new Screen();
    this.streamingService = new StreamingService();
  }
  
  watchMovie(username, password, movie) {
    console.log("=== Getting ready to watch a movie ===");
    this.screen.turnOn();
    this.audioPlayer.turnOn();
    this.streamingService.login(username, password);
    
    const content = this.streamingService.streamMovie(movie);
    if (content) {
      this.screen.show(content.video);
      this.audioPlayer.setVolume(10);
      this.audioPlayer.play(content.audio);
    }
    
    console.log("=== Enjoy your movie! ===");
  }
  
  endMovie() {
    console.log("=== Shutting down movie system ===");
    this.audioPlayer.stop();
    this.audioPlayer.turnOff();
    this.streamingService.logout();
    this.screen.turnOff();
    console.log("=== System shutdown complete ===");
  }
}

// Client code
const homeTheater = new HomeTheaterFacade();
homeTheater.watchMovie("user123", "password", "The Matrix");
// === Getting ready to watch a movie ===
// Screen turning on
// Audio player turning on
// Logging in as user123
// Streaming movie: The Matrix
// Displaying image: The Matrix visuals
// Volume set to 10
// Playing audio track: The Matrix soundtrack
// === Enjoy your movie! ===

homeTheater.endMovie();
// === Shutting down movie system ===
// Stopping audio playback
// Audio player turning off
// Logging out
// Screen turning off
// === System shutdown complete ===
```

#### Use Cases

- Providing a simple interface to a complex subsystem
- Creating a library that's easy to understand and use
- Decoupling subsystems from clients and other subsystems
- Defining entry points to each level of a layered software system

### Flyweight Pattern

The Flyweight pattern lets you fit more objects into the available amount of memory by sharing common parts of state between multiple objects instead of keeping all of the data in each object.

#### Structure

1. **Flyweight**: Interface through which flyweights can receive and act on extrinsic state
2. **Concrete Flyweight**: Implements the Flyweight interface and stores intrinsic state
3. **Flyweight Factory**: Creates and manages flyweight objects

#### JavaScript Implementation

```javascript
// Flyweight class
class TextCharacter {
  constructor(char, fontFamily, fontSize) {
    this.char = char;
    this.fontFamily = fontFamily; // Intrinsic state
    this.fontSize = fontSize;     // Intrinsic state
    // These properties are shared among many instances
  }
  
  render(x, y, color) { // Extrinsic state passed by client
    console.log(`Rendering "${this.char}" at (${x}, ${y}) in ${color} using ${this.fontFamily}, ${this.fontSize}px`);
  }
}

// Flyweight Factory
class CharacterFactory {
  constructor() {
    this.characters = {};
  }
  
  getCharacter(char, fontFamily, fontSize) {
    // Create a unique key based on the intrinsic state
    const key = `${char}-${fontFamily}-${fontSize}`;
    
    // If this character combination doesn't exist, create it
    if (!this.characters[key]) {
      console.log(`Creating new character flyweight for "${char}"`);
      this.characters[key] = new TextCharacter(char, fontFamily, fontSize);
    }
    
    return this.characters[key];
  }
  
  getCharacterCount() {
    return Object.keys(this.characters).length;
  }
}

// Client code that uses the flyweights
class TextEditor {
  constructor() {
    this.characters = [];
    this.factory = new CharacterFactory();
  }
  
  write(text, fontFamily, fontSize, startX, startY, color) {
    let x = startX;
    
    for (const char of text) {
      const textChar = this.factory.getCharacter(char, fontFamily, fontSize);
      
      // Store character and its extrinsic state
      this.characters.push({
        flyweight: textChar,
        x: x,
        y: startY,
        color: color
      });
      
      x += fontSize / 2; // Simple positioning logic
    }
  }
  
  render() {
    this.characters.forEach(char => {
      char.flyweight.render(char.x, char.y, char.color);
    });
  }
}

// Usage
const editor = new TextEditor();

editor.write("Hello", "Arial", 12, 10, 10, "black");
editor.write("World!", "Arial", 12, 60, 10, "red");
editor.write("Hello", "Times New Roman", 16, 10, 30, "blue");

console.log(`Total character flyweights created: ${editor.factory.getCharacterCount()}`);

editor.render();
// Creating new character flyweight for "H"
// Creating new character flyweight for "e"
// Creating new character flyweight for "l"
// Creating new character flyweight for "o"
// Creating new character flyweight for "W"
// Creating new character flyweight for "r"
// Creating new character flyweight for "d"
// Creating new character flyweight for "!"
// Creating new character flyweight for "H" (different font)
// Creating new character flyweight for "e" (different font)
// Creating new character flyweight for "l" (different font)
// Creating new character flyweight for "o" (different font)
// Total character flyweights created: 12
// Rendering "H" at (10, 10) in black using Arial, 12px
// Rendering "e" at (16, 10) in black using Arial, 12px
// ... (remaining render calls)
```

#### Use Cases

- When your program must support a huge number of objects that barely fit into available RAM
- When objects can be separated into intrinsic (shared) and extrinsic (unique) state
- Text editors, graphics systems, and game development for things like particles

### Proxy Pattern

The Proxy pattern provides a surrogate or placeholder for another object to control access to it. This pattern adds a level of indirection when accessing an object.

#### Structure

1. **Subject**: Interface implemented by both the RealSubject and Proxy
2. **RealSubject**: The real object that the proxy represents
3. **Proxy**: Maintains a reference to the RealSubject and controls access to it

#### JavaScript Implementation

```javascript
// Subject interface
class ExpensiveAPI {
  getData(query) {}
}

// RealSubject
class RealExpensiveAPI extends ExpensiveAPI {
  getData(query) {
    console.log(`Performing expensive API call for query: ${query}`);
    // Simulating network delay
    return `Data for ${query}`;
  }
}

// Proxy
class CachingAPIProxy extends ExpensiveAPI {
  constructor(realAPI) {
    super();
    this.realAPI = realAPI;
    this.cache = {};
  }
  
  getData(query) {
    if (this.cache[query]) {
      console.log(`Returning cached result for query: ${query}`);
      return this.cache[query];
    }
    
    const result = this.realAPI.getData(query);
    this.cache[query] = result;
    
    return result;
  }
  
  clearCache() {
    console.log('Clearing cache');
    this.cache = {};
  }
}

// Usage
const realAPI = new RealExpensiveAPI();
const proxy = new CachingAPIProxy(realAPI);

// First call - will use the real API
console.log(proxy.getData("users")); 
// Performing expensive API call for query: users
// Data for users

// Second call - will use cached data
console.log(proxy.getData("users"));
// Returning cached result for query: users
// Data for users

// Different query - will use the real API
console.log(proxy.getData("products"));
// Performing expensive API call for query: products
// Data for products

// Clear cache and try again
proxy.clearCache();
// Clearing cache

console.log(proxy.getData("users"));
// Performing expensive API call for query: users
// Data for users
```

#### Types of Proxies

1. **Virtual Proxy**: Delays creating expensive objects until needed
2. **Protection Proxy**: Controls access to the original object
3. **Remote Proxy**: Represents objects in different address spaces
4. **Logging Proxy**: Keeps a log of access to the object
5. **Caching Proxy**: Stores results of expensive operations (shown above)

#### Use Cases

- Lazy initialization (virtual proxy)
- Access control (protection proxy)
- Local execution of remote service (remote proxy)
- Logging requests (logging proxy)
- Caching results (caching proxy)
- Smart reference counting

### Other Structural Patterns

#### Private Class Data Pattern

This pattern restricts accessor/mutator access to class data by encapsulating class data initialization.

```javascript
// Private Class Data implementation
class CircleData {
  constructor(radius) {
    this._radius = radius;
  }
  
  getRadius() {
    return this._radius;
  }
}

class Circle {
  constructor(radius) {
    // Store data in a separate object
    this._data = new CircleData(radius);
  }
  
  // Only expose necessary methods
  getArea() {
    return Math.PI * Math.pow(this._data.getRadius(), 2);
  }
  
  getCircumference() {
    return 2 * Math.PI * this._data.getRadius();
  }
  
  // No direct way to modify radius after construction!
}

// Usage
const circle = new Circle(5);
console.log(circle.getArea()); // ~78.54
console.log(circle.getCircumference()); // ~31.42
// circle._data._radius = 10; // Would work, but breaks encapsulation
```

### Conclusion

**Key Points**:

- Structural design patterns focus on how objects are composed to form larger structures
- These patterns help manage relationships between objects
- They enable flexibility in how objects are related and composed
- Each pattern addresses specific structural challenges in software design
- The right pattern can significantly simplify complex systems and improve maintainability
- Different structural patterns can be combined to solve complex design problems

### Related Topics

- Creational Design Patterns
- Behavioral Design Patterns
- Object-Oriented Programming Principles
- Component-Based Architecture
- SOLID Design Principles
- Microservice Architecture
- Module Systems and Dependencies

---

