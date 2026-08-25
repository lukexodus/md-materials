## Storing Functions in Data Structures


Functions can be elements in arrays, values in maps, or fields in objects, enabling lookup tables, command patterns, and state machines implemented functionally.

```javascript
// Functions in arrays
const operations = [
    x => x + 1,
    x => x * 2,
    x => x * x,
    x => Math.sqrt(x)
];

// Apply all operations to a value
const applyAll = (value, ops) => {
    return ops.map(op => op(value));
};

console.log(applyAll(4, operations));
// [5, 8, 16, 2]

// Functions in objects (dispatch table)
const calculator = {
    add: (a, b) => a + b,
    subtract: (a, b) => a - b,
    multiply: (a, b) => a * b,
    divide: (a, b) => a / b,
    power: (a, b) => Math.pow(a, b)
};

const compute = (operation, a, b) => {
    return calculator[operation](a, b);
};

console.log(compute('multiply', 5, 3));  // 15
console.log(compute('power', 2, 8));     // 256
```

This pattern eliminates long switch statements and if-else chains, replacing them with data-driven dispatch. It's particularly useful for implementing command patterns, event handlers, and parsers.

```python
# State machine using function lookup
def state_idle(event):
    if event == 'start':
        return 'running', state_running
    return 'idle', state_idle

def state_running(event):
    if event == 'pause':
        return 'paused', state_paused
    if event == 'stop':
        return 'idle', state_idle
    return 'running', state_running

def state_paused(event):
    if event == 'resume':
        return 'running', state_running
    if event == 'stop':
        return 'idle', state_idle
    return 'paused', state_paused

# State machine executor
class StateMachine:
    def __init__(self, initial_state, initial_handler):
        self.state = initial_state
        self.handler = initial_handler
    
    def process_event(self, event):
        self.state, self.handler = self.handler(event)
        return self.state

# Usage
sm = StateMachine('idle', state_idle)
sm.process_event('start')   # 'running'
sm.process_event('pause')   # 'paused'
sm.process_event('resume')  # 'running'
```

**Key Points:**

- Enables data-driven program logic
- Replaces conditional logic with lookup operations
- Facilitates plugin architectures and extensibility
- Supports strategy pattern and command pattern implementations

**Example:**

```clojure
;; Clojure: Functions in collections
(def validators
  [(fn [x] (> x 0))           ; positive?
   (fn [x] (< x 100))         ; less than 100?
   (fn [x] (integer? x))      ; integer?
   (fn [x] (even? x))])       ; even?

(defn validate-all [value validators]
  (every? #(% value) validators))

(validate-all 42 validators)   ;; true
(validate-all -5 validators)   ;; false
(validate-all 42.5 validators) ;; false

;; Function map for different strategies
(def strategies
  {:aggressive (fn [x] (* x 1.5))
   :conservative (fn [x] (* x 0.8))
   :moderate (fn [x] x)})

(defn apply-strategy [strategy-name value]
  ((strategies strategy-name) value))

(apply-strategy :aggressive 100)    ;; 150
(apply-strategy :conservative 100)  ;; 80
```

**Conclusion:** Treating functions as first-class citizens fundamentally changes how programs are structured. Instead of building complex class hierarchies and inheritance chains, functional programs compose behavior by passing, returning, and storing functions. This leads to more flexible, reusable, and testable code with less boilerplate.

