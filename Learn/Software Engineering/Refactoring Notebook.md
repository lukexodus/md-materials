# Replace Type Code with Class/Subclasses/State-Strategy

Type codes (integers or strings representing different categories) can often be replaced with class hierarchies or strategy patterns, enabling polymorphic behavior.

## Quick Example

**Before (Type Code):**
```python
class Employee:
    ENGINEER = 0
    SALESMAN = 1
    MANAGER = 2
    
    def __init__(self, name, type_code):
        self.name = name
        self.type_code = type_code
    
    def get_bonus(self):
        if self.type_code == self.ENGINEER:
            return 1000
        elif self.type_code == self.SALESMAN:
            return 1500
        elif self.type_code == self.MANAGER:
            return 2000
```

**After (Class Hierarchy):**
```python
class Employee:
    def __init__(self, name):
        self.name = name
    
    def get_bonus(self):
        raise NotImplementedError

class Engineer(Employee):
    def get_bonus(self):
        return 1000

class Salesman(Employee):
    def get_bonus(self):
        return 1500

class Manager(Employee):
    def get_bonus(self):
        return 2000
```

## When to Use

- Type code affects behavior (conditionals based on type)
- Multiple methods have type-dependent logic
- New types may be added in the future
- Type represents a fundamental variation in behavior

## When NOT to Use

- Type code is purely data (no behavioral differences)
- Type changes at runtime (consider State pattern instead)
- Simple cases with only 1-2 conditionals

## Three Approaches

### 1. Replace with Subclasses
Use when type is fixed at object creation.

```python
# Before
class Bird:
    EUROPEAN = 0
    AFRICAN = 1
    
    def __init__(self, bird_type):
        self.bird_type = bird_type
    
    def get_speed(self):
        if self.bird_type == self.EUROPEAN:
            return 35
        elif self.bird_type == self.AFRICAN:
            return 40

# After
class Bird:
    def get_speed(self):
        raise NotImplementedError

class EuropeanBird(Bird):
    def get_speed(self):
        return 35

class AfricanBird(Bird):
    def get_speed(self):
        return 40
```

### 2. Replace with State Pattern
Use when type can change during object lifetime.

```python
# Before
class Connection:
    DISCONNECTED = 0
    CONNECTING = 1
    CONNECTED = 2
    
    def __init__(self):
        self.state = self.DISCONNECTED
    
    def send_data(self, data):
        if self.state == self.DISCONNECTED:
            raise Exception("Not connected")
        elif self.state == self.CONNECTING:
            raise Exception("Still connecting")
        elif self.state == self.CONNECTED:
            # send data
            pass

# After
class ConnectionState:
    def send_data(self, data):
        raise NotImplementedError

class Disconnected(ConnectionState):
    def send_data(self, data):
        raise Exception("Not connected")

class Connecting(ConnectionState):
    def send_data(self, data):
        raise Exception("Still connecting")

class Connected(ConnectionState):
    def send_data(self, data):
        # send data
        pass

class Connection:
    def __init__(self):
        self.state = Disconnected()
    
    def send_data(self, data):
        self.state.send_data(data)
    
    def change_state(self, new_state):
        self.state = new_state
```

### 3. Replace with Strategy Pattern
Use when behavior varies but object identity doesn't change.

```python
# Before
class PaymentProcessor:
    CREDIT_CARD = 0
    PAYPAL = 1
    BITCOIN = 2
    
    def __init__(self, payment_type):
        self.payment_type = payment_type
    
    def process(self, amount):
        if self.payment_type == self.CREDIT_CARD:
            # credit card logic
            pass
        elif self.payment_type == self.PAYPAL:
            # PayPal logic
            pass
        elif self.payment_type == self.BITCOIN:
            # Bitcoin logic
            pass

# After
class PaymentStrategy:
    def process(self, amount):
        raise NotImplementedError

class CreditCardStrategy(PaymentStrategy):
    def process(self, amount):
        # credit card logic
        pass

class PayPalStrategy(PaymentStrategy):
    def process(self, amount):
        # PayPal logic
        pass

class BitcoinStrategy(PaymentStrategy):
    def process(self, amount):
        # Bitcoin logic
        pass

class PaymentProcessor:
    def __init__(self, strategy):
        self.strategy = strategy
    
    def process(self, amount):
        self.strategy.process(amount)
    
    def set_strategy(self, strategy):
        self.strategy = strategy
```

## Benefits

- **Eliminates conditionals**: Polymorphism replaces if/switch statements
- **Easier to extend**: New types = new classes (Open/Closed Principle)
- **Better encapsulation**: Type-specific behavior lives in type-specific classes
- **Clearer intent**: Class names convey meaning better than numeric codes

## Trade-offs

- More classes to manage
- Can be overkill for simple cases
- May require factory methods for object creation

---

