## Extract Method

Extract Method is a fundamental refactoring technique that involves taking a code fragment and turning it into a separate method with a descriptive name. This refactoring improves code readability, reduces duplication, and makes the codebase easier to maintain by breaking down complex methods into smaller, well-named units.

### What is Extract Method?

Extract Method addresses the problem of long, complex methods that try to do too many things. When you identify a code fragment that can be grouped together and given a meaningful name, you extract it into its own method. The original location then calls this new method instead of containing the inline code.

The technique transforms code from:

- A long method doing multiple things
- Repeated code fragments
- Complex logic that's hard to understand

Into:

- Smaller, focused methods with clear purposes
- Self-documenting code through method names
- Reusable components

### When to Apply Extract Method

**Signs you need Extract Method:**

- Methods longer than 10-20 lines [Inference: this threshold varies by team standards]
- Code that requires comments to explain what it does
- Duplicate or near-duplicate code fragments
- Complex conditional logic or nested loops
- Difficulty understanding what a section of code does at a glance
- Methods mixing different levels of abstraction

**Benefits:**

- **Readability**: Well-named methods explain intent without comments
- **Reusability**: Extracted methods can be called from multiple places
- **Testability**: Smaller methods are easier to unit test in isolation
- **Maintainability**: Changes to specific functionality are localized
- **Reduced duplication**: Common code fragments become shared methods

### Basic Mechanics

The refactoring process typically follows these steps:

1. **Identify** the code fragment to extract
2. **Analyze** what local variables are used or modified
3. **Create** a new method with a descriptive name
4. **Copy** the extracted code into the new method
5. **Replace** the original code with a call to the new method
6. **Test** to ensure behavior hasn't changed

**Key Points:**

- The extracted method should do one thing well
- Method names should describe the intent, not the implementation
- Keep methods at consistent levels of abstraction
- Pass necessary parameters; return values as needed

### Example: Before Refactoring

```java
public void printOwing() {
    printBanner();
    
    // Print details
    System.out.println("name: " + name);
    System.out.println("amount: " + getOutstanding());
    
    // Calculate outstanding
    double outstanding = 0.0;
    for (Order order : orders) {
        outstanding += order.getAmount();
    }
    
    System.out.println("Total outstanding: " + outstanding);
}
```

This method has multiple responsibilities: printing a banner, printing details, calculating outstanding amounts, and formatting output.

### Example: After Refactoring

```java
public void printOwing() {
    printBanner();
    double outstanding = calculateOutstanding();
    printDetails(outstanding);
}

private double calculateOutstanding() {
    double result = 0.0;
    for (Order order : orders) {
        result += order.getAmount();
    }
    return result;
}

private void printDetails(double outstanding) {
    System.out.println("name: " + name);
    System.out.println("amount: " + getOutstanding());
    System.out.println("Total outstanding: " + outstanding);
}
```

**Improvements:**

- Main method now reads like a high-level summary
- Each extracted method has a single, clear responsibility
- `calculateOutstanding()` can be reused elsewhere
- Each method can be tested independently

### Handling Variables

Different scenarios require different approaches when dealing with variables:

#### No Local Variables

The simplest case - just extract the code:

```python
# Before
def print_report(self):
    print("=" * 40)
    print("Annual Report")
    print("=" * 40)
    print(f"Revenue: ${self.revenue}")
```

```python
# After
def print_report(self):
    self.print_header()
    print(f"Revenue: ${self.revenue}")

def print_header(self):
    print("=" * 40)
    print("Annual Report")
    print("=" * 40)
```

#### Variables Used But Not Modified

Pass them as parameters:

```javascript
// Before
function calculateTotal() {
    const basePrice = quantity * itemPrice;
    const discount = Math.max(0, quantity - 500) * itemPrice * 0.05;
    const shipping = Math.min(basePrice * 0.1, 100);
    return basePrice - discount + shipping;
}
```

```javascript
// After
function calculateTotal() {
    const basePrice = quantity * itemPrice;
    const discount = calculateDiscount(quantity, itemPrice);
    const shipping = calculateShipping(basePrice);
    return basePrice - discount + shipping;
}

function calculateDiscount(quantity, itemPrice) {
    return Math.max(0, quantity - 500) * itemPrice * 0.05;
}

function calculateShipping(basePrice) {
    return Math.min(basePrice * 0.1, 100);
}
```

#### Variables Modified

Return the modified value:

```csharp
// Before
public void ProcessOrder() {
    int total = 0;
    foreach (var item in items) {
        total += item.Price * item.Quantity;
    }
    
    if (total > 1000) {
        total = (int)(total * 0.9); // 10% discount
    }
    
    ApplyPayment(total);
}
```

```csharp
// After
public void ProcessOrder() {
    int total = CalculateTotal();
    total = ApplyDiscount(total);
    ApplyPayment(total);
}

private int CalculateTotal() {
    int total = 0;
    foreach (var item in items) {
        total += item.Price * item.Quantity;
    }
    return total;
}

private int ApplyDiscount(int total) {
    if (total > 1000) {
        return (int)(total * 0.9);
    }
    return total;
}
```

#### Multiple Values Need Returning

Consider returning an object or tuple:

```python
# Before
def analyze_data(self, data):
    count = 0
    total = 0
    for value in data:
        if value > 0:
            count += 1
            total += value
    average = total / count if count > 0 else 0
    print(f"Count: {count}, Average: {average}")
```

```python
# After
def analyze_data(self, data):
    stats = self.calculate_statistics(data)
    print(f"Count: {stats['count']}, Average: {stats['average']}")

def calculate_statistics(self, data):
    count = 0
    total = 0
    for value in data:
        if value > 0:
            count += 1
            total += value
    average = total / count if count > 0 else 0
    return {'count': count, 'average': average}
```

### Advanced Patterns

#### Extract Method Object

When a method has many local variables making extraction difficult, consider extracting to a class:

```java
// Before: Complex method with many local variables
public int calculateScore(Player player) {
    int baseScore = 0;
    int bonusMultiplier = 1;
    int streakBonus = 0;
    boolean hasAchievement = false;
    
    // 50+ lines of complex logic manipulating these variables
    // ...
    
    return finalScore;
}
```

```java
// After: Method Object pattern
public int calculateScore(Player player) {
    return new ScoreCalculator(player).calculate();
}

class ScoreCalculator {
    private Player player;
    private int baseScore;
    private int bonusMultiplier;
    private int streakBonus;
    private boolean hasAchievement;
    
    public ScoreCalculator(Player player) {
        this.player = player;
        this.baseScore = 0;
        this.bonusMultiplier = 1;
        this.streakBonus = 0;
        this.hasAchievement = false;
    }
    
    public int calculate() {
        calculateBaseScore();
        applyMultipliers();
        addBonuses();
        return getFinalScore();
    }
    
    private void calculateBaseScore() { /* ... */ }
    private void applyMultipliers() { /* ... */ }
    private void addBonuses() { /* ... */ }
    private int getFinalScore() { /* ... */ }
}
```

#### Compose Method Pattern

Build methods from other methods at the same level of abstraction:

```ruby
# High-level method composed of same-abstraction methods
def process_invoice(invoice)
  validate_invoice(invoice)
  calculate_totals(invoice)
  apply_discounts(invoice)
  generate_line_items(invoice)
  finalize_invoice(invoice)
end

# Each method contains methods at the next level down
def calculate_totals(invoice)
  invoice.subtotal = calculate_subtotal(invoice)
  invoice.tax = calculate_tax(invoice)
  invoice.total = calculate_final_total(invoice)
end
```

### Common Pitfalls

**Over-extraction:** Creating too many tiny methods can make code harder to follow [Inference: balance is needed between extraction and readability]:

```python
# Potentially over-extracted
def calculate_price(self):
    return self.add(self.get_base(), self.get_tax())

def add(self, a, b):
    return a + b

def get_base(self):
    return self.base

def get_tax(self):
    return self.tax
```

**Poor naming:** Method names that don't clearly indicate purpose:

```javascript
// Poor names
function doStuff() { }
function processData() { }
function handleIt() { }

// Better names
function calculateMonthlyInterest() { }
function validateEmailFormat() { }
function sendWelcomeEmail() { }
```

**Wrong abstraction level:** Mixing high and low-level operations:

```java
// Mixed abstraction levels
public void prepareReport() {
    loadData();  // High level
    for (int i = 0; i < data.length; i++) {  // Low level
        // Process each element...
    }
    formatOutput();  // High level
}

// Better: consistent abstraction
public void prepareReport() {
    loadData();
    processData();
    formatOutput();
}
```

**Breaking encapsulation:** Extracting methods that require too many parameters or expose internal state unnecessarily [Inference: this may suggest design issues]:

```csharp
// Requires many parameters - might indicate design problem
private void UpdateCustomer(string name, string email, string phone, 
                           string address, string city, string state) {
    // ...
}

// Consider if a Customer object would be more appropriate
private void UpdateCustomer(Customer customer) {
    // ...
}
```

### Tool Support

Modern IDEs provide automated Extract Method refactoring [Unverified: specific behavior depends on IDE version and configuration]:

**Typical IDE features:**

- Automatic parameter detection
- Return value inference
- Scope analysis
- Variable naming suggestions
- Conflict detection

**Disclaimer:** IDE refactoring tools attempt to preserve behavior but may not handle all edge cases correctly in complex scenarios. Always test after refactoring.

### Relationship to Design Patterns

Extract Method supports several design patterns:

**Template Method Pattern:** Extract Method helps identify steps in an algorithm that can become template methods:

```python
class DataProcessor:
    def process(self):
        self.load_data()      # Extracted method
        self.transform_data()  # Extracted method
        self.save_data()      # Extracted method
```

**Strategy Pattern:** Extracted methods can become strategies:

```java
// Extracted calculation methods become strategies
interface PricingStrategy {
    double calculate(Order order);
}

class RegularPricing implements PricingStrategy {
    public double calculate(Order order) {
        // Previously extracted method
    }
}
```

**Command Pattern:** Extracted methods can be transformed into command objects for more flexibility.

### Testing Considerations

Extract Method can improve testability [Inference: assuming proper design]:

**Before extraction:**

```python
def process_order(order):
    # 100 lines of code including validation, calculation, persistence
    pass

# Difficult to test individual parts
```

**After extraction:**

```python
def process_order(order):
    validate_order(order)
    total = calculate_total(order)
    apply_discounts(order, total)
    save_order(order)

# Each method can be tested independently
def test_calculate_total():
    order = create_test_order()
    total = calculate_total(order)
    assert total == expected_value
```

**Disclaimer:** While extracted methods may be easier to test individually, this doesn't guarantee that the overall system behavior is correct. Integration tests remain important.

### Step-by-Step Refactoring Process

**1. Identify the fragment:** Look for code blocks that:

- Have a clear purpose
- Are repeated
- Are commented to explain intent
- Break the flow of reading

**2. Check for dependencies:**

- What local variables does it read?
- What local variables does it modify?
- Does it access instance/class variables?
- Does it throw exceptions?

**3. Create the new method:**

- Choose a descriptive name based on what it does, not how
- Determine return type based on what's modified
- Add parameters for variables it needs

**4. Move the code:**

- Copy fragment to new method
- Adjust for parameter names
- Handle return values

**5. Replace original code:**

- Replace with method call
- Pass required arguments
- Capture return value if needed

**6. Compile and test:**

- Verify compilation
- Run all tests
- Check for unexpected behavior changes

**Disclaimer:** This process describes typical steps but actual implementation may vary based on language features, code complexity, and specific circumstances.

### **Key Points**

- Extract Method is one of the most frequently used refactorings
- Start with small, obvious extractions before tackling complex cases
- Good method names eliminate the need for comments [Inference: in most cases]
- Methods should be short enough to fit on one screen without scrolling
- Extract when you need to add a comment explaining what code does
- IDE support makes the mechanical parts safer and faster
- Balance between extraction and readability - not every line needs its own method
- Consistency in abstraction levels makes code easier to understand

### **Conclusion**

Extract Method is a cornerstone refactoring technique that transforms complex, monolithic methods into clear, maintainable code through decomposition. By creating well-named methods that encapsulate specific behaviors, you make code self-documenting, reusable, and easier to test.

The technique is most effective when applied judiciously - extract when it improves clarity, enables reuse, or simplifies testing, but avoid over-extraction that fragments logic unnecessarily. Combined with good naming practices and consistent abstraction levels, Extract Method helps create codebases that are easier to understand, modify, and extend over time.

### **Next Steps**

- Practice identifying extraction opportunities in your current codebase
- Use IDE refactoring tools to safely perform extractions
- Study related refactorings: Inline Method (the reverse), Extract Class, Replace Temp with Query
- Read "Refactoring" by Martin Fowler for comprehensive coverage of refactoring techniques
- Apply the Boy Scout Rule: leave code cleaner than you found it by extracting as you work

---

## Extract Class

Extract Class is a fundamental refactoring technique used to address the problem of classes that have grown too large and taken on too many responsibilities. This refactoring involves identifying a cohesive subset of data and behavior within an existing class and moving it into a new, separate class. The goal is to improve code organization, maintainability, and adherence to the Single Responsibility Principle.

### Core Concept

The Extract Class refactoring recognizes that classes often accumulate responsibilities over time as software evolves. When a class becomes bloated with multiple distinct concerns, it becomes harder to understand, test, and modify. Extract Class addresses this by:

1. Identifying a subset of fields and methods that naturally belong together
2. Creating a new class to house this related functionality
3. Moving the identified members to the new class
4. Establishing a relationship between the original and new class
5. Updating all references to use the new structure

This refactoring is the opposite of Inline Class, which merges a class back into another when it no longer carries its weight.

### When to Apply Extract Class

#### Symptoms Indicating Need for Extraction

**Large Class with Multiple Responsibilities**

When a class has grown to hundreds or thousands of lines, it likely handles multiple concerns. This makes the class difficult to understand and violates the Single Responsibility Principle.

```python
# Problem: User class doing too much
class User:
    def __init__(self):
        # User identity
        self.user_id = None
        self.username = None
        self.email = None
        
        # Address information
        self.street = None
        self.city = None
        self.state = None
        self.zip_code = None
        self.country = None
        
        # Payment information
        self.credit_card_number = None
        self.expiry_date = None
        self.cvv = None
        self.billing_address = None
        
        # Preferences
        self.theme = None
        self.language = None
        self.notifications_enabled = None
```

**Cohesive Subsets of Data**

When groups of fields are always used together, they form a natural candidate for extraction. If you frequently pass multiple fields to methods or constructors together, they likely belong in their own class.

**Subsets of Methods Operating on Specific Data**

When certain methods only interact with a specific subset of the class's fields, this indicates a separate responsibility that could be extracted.

**Difficulty Testing the Class**

Large classes with multiple responsibilities are harder to test comprehensively. If you find yourself writing complex setup code or mocking many dependencies, extraction may help create more focused, testable units.

**Frequent Changes to Unrelated Parts**

When changes to one aspect of the class require understanding unrelated aspects, this indicates poor cohesion. Extract Class helps isolate change impacts.

### Benefits of Extract Class

#### Improved Code Organization

Smaller, focused classes are easier to understand. Each class has a clear purpose, making the codebase more navigable and reducing cognitive load for developers.

#### Enhanced Testability

Smaller classes with focused responsibilities are easier to test in isolation. You can write more targeted unit tests with simpler setup and fewer dependencies.

#### Better Reusability

Extracted classes can often be reused in contexts where the original class would be too heavyweight. This promotes code reuse and reduces duplication.

#### Easier Maintenance

Changes to specific functionality are localized to the relevant class, reducing the risk of unintended side effects and making modifications safer.

#### Adherence to SOLID Principles

Extract Class directly supports the Single Responsibility Principle. It may also improve adherence to other SOLID principles by creating more cohesive abstractions.

### Step-by-Step Refactoring Process

#### Step 1: Identify Extraction Candidates

Analyze the existing class to find cohesive groups of fields and methods. Look for:

- Fields that are frequently accessed together
- Methods that primarily operate on a specific subset of fields
- Conceptual groupings that represent distinct responsibilities
- Data that has its own validation or business rules

#### Step 2: Create the New Class

Define a new class with an appropriate name that clearly describes its single responsibility. Consider the class's future role and potential for reuse.

```java
// Original bloated class
public class Order {
    private String orderId;
    private Date orderDate;
    
    // Customer information
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    
    // Shipping address
    private String shippingStreet;
    private String shippingCity;
    private String shippingState;
    private String shippingZip;
}

// Step 2: Create new class for address
public class Address {
    private String street;
    private String city;
    private String state;
    private String zipCode;
    
    public Address(String street, String city, String state, String zipCode) {
        this.street = street;
        this.city = city;
        this.state = state;
        this.zipCode = zipCode;
    }
    
    // Getters and setters
}
```

#### Step 3: Move Fields

Transfer the identified fields from the original class to the new class. Replace the individual fields in the original class with a reference to the new class.

```java
public class Order {
    private String orderId;
    private Date orderDate;
    
    // Customer information
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    
    // Shipping address now delegated
    private Address shippingAddress;
}
```

#### Step 4: Move Methods

Identify methods that primarily work with the extracted fields and move them to the new class. These methods typically:

- Validate the extracted data
- Format or transform the extracted data
- Perform calculations using only the extracted fields
- Implement business rules specific to the extracted concept

```java
public class Address {
    private String street;
    private String city;
    private String state;
    private String zipCode;
    
    // Constructor
    
    // Moved method - validates address completeness
    public boolean isComplete() {
        return street != null && !street.isEmpty() &&
               city != null && !city.isEmpty() &&
               state != null && !state.isEmpty() &&
               zipCode != null && !zipCode.isEmpty();
    }
    
    // Moved method - formats address for display
    public String formatForShipping() {
        return String.format("%s\n%s, %s %s", street, city, state, zipCode);
    }
    
    // Moved method - validates zip code format
    public boolean hasValidZipCode() {
        return zipCode != null && zipCode.matches("\\d{5}(-\\d{4})?");
    }
}
```

#### Step 5: Update References

Update all code that accessed the original fields to go through the new class. This may involve changing direct field access to method calls on the extracted class.

```java
// Before refactoring
public void printShippingLabel(Order order) {
    System.out.println(order.getShippingStreet());
    System.out.println(order.getShippingCity() + ", " + 
                      order.getShippingState() + " " + 
                      order.getShippingZip());
}

// After refactoring
public void printShippingLabel(Order order) {
    System.out.println(order.getShippingAddress().formatForShipping());
}
```

#### Step 6: Establish Proper Encapsulation

Ensure the new class properly encapsulates its data and provides a clean interface. Add necessary constructors, validation, and business logic methods.

```java
public class Address {
    private final String street;
    private final String city;
    private final String state;
    private final String zipCode;
    
    // Immutable design with validation
    public Address(String street, String city, String state, String zipCode) {
        if (street == null || street.trim().isEmpty()) {
            throw new IllegalArgumentException("Street cannot be empty");
        }
        if (city == null || city.trim().isEmpty()) {
            throw new IllegalArgumentException("City cannot be empty");
        }
        if (state == null || state.trim().isEmpty()) {
            throw new IllegalArgumentException("State cannot be empty");
        }
        if (!isValidZipCode(zipCode)) {
            throw new IllegalArgumentException("Invalid zip code format");
        }
        
        this.street = street;
        this.city = city;
        this.state = state;
        this.zipCode = zipCode;
    }
    
    private static boolean isValidZipCode(String zipCode) {
        return zipCode != null && zipCode.matches("\\d{5}(-\\d{4})?");
    }
    
    // Getters (no setters for immutable design)
    public String getStreet() { return street; }
    public String getCity() { return city; }
    public String getState() { return state; }
    public String getZipCode() { return zipCode; }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Address)) return false;
        Address address = (Address) o;
        return street.equals(address.street) &&
               city.equals(address.city) &&
               state.equals(address.state) &&
               zipCode.equals(address.zipCode);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(street, city, state, zipCode);
    }
}
```

### Common Patterns and Variations

#### Extract Value Object

When the extracted class represents a value rather than an entity, consider making it immutable and implementing value object semantics.

```typescript
// Before: Date range as primitive fields
class Report {
    private startDate: Date;
    private endDate: Date;
    
    constructor(startDate: Date, endDate: Date) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    isDateInRange(date: Date): boolean {
        return date >= this.startDate && date <= this.endDate;
    }
    
    getDurationInDays(): number {
        const diffTime = Math.abs(this.endDate.getTime() - this.startDate.getTime());
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }
}

// After: Extract DateRange value object
class DateRange {
    private readonly start: Date;
    private readonly end: Date;
    
    constructor(start: Date, end: Date) {
        if (start > end) {
            throw new Error("Start date must be before end date");
        }
        this.start = new Date(start.getTime()); // Defensive copy
        this.end = new Date(end.getTime());
    }
    
    contains(date: Date): boolean {
        return date >= this.start && date <= this.end;
    }
    
    getDurationInDays(): number {
        const diffTime = Math.abs(this.end.getTime() - this.start.getTime());
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }
    
    overlaps(other: DateRange): boolean {
        return this.start <= other.end && other.start <= this.end;
    }
    
    getStart(): Date {
        return new Date(this.start.getTime());
    }
    
    getEnd(): Date {
        return new Date(this.end.getTime());
    }
}

class Report {
    private dateRange: DateRange;
    
    constructor(dateRange: DateRange) {
        this.dateRange = dateRange;
    }
    
    isDateInRange(date: Date): boolean {
        return this.dateRange.contains(date);
    }
    
    getDurationInDays(): number {
        return this.dateRange.getDurationInDays();
    }
}
```

#### Extract Strategy Object

When the extracted functionality represents an algorithm or behavior that might vary, consider using the Strategy pattern.

```python
# Before: Payment logic embedded in Order
class Order:
    def __init__(self):
        self.items = []
        self.payment_type = None
        self.credit_card_number = None
        self.paypal_email = None
        self.crypto_wallet = None
    
    def process_payment(self, amount):
        if self.payment_type == "credit_card":
            # Credit card processing logic
            if not self.validate_credit_card():
                return False
            return self.charge_credit_card(amount)
        elif self.payment_type == "paypal":
            # PayPal processing logic
            if not self.validate_paypal_email():
                return False
            return self.charge_paypal(amount)
        elif self.payment_type == "crypto":
            # Cryptocurrency processing logic
            if not self.validate_crypto_wallet():
                return False
            return self.charge_crypto(amount)

# After: Extract payment strategies
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def process(self, amount: float) -> bool:
        pass
    
    @abstractmethod
    def validate(self) -> bool:
        pass

class CreditCardPayment(PaymentMethod):
    def __init__(self, card_number: str, expiry: str, cvv: str):
        self.card_number = card_number
        self.expiry = expiry
        self.cvv = cvv
    
    def validate(self) -> bool:
        # Credit card validation logic
        return (len(self.card_number) == 16 and 
                self.card_number.isdigit() and
                len(self.cvv) == 3)
    
    def process(self, amount: float) -> bool:
        if not self.validate():
            return False
        # Process credit card payment
        print(f"Processing ${amount} via credit card")
        return True

class PayPalPayment(PaymentMethod):
    def __init__(self, email: str):
        self.email = email
    
    def validate(self) -> bool:
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, self.email) is not None
    
    def process(self, amount: float) -> bool:
        if not self.validate():
            return False
        # Process PayPal payment
        print(f"Processing ${amount} via PayPal")
        return True

class Order:
    def __init__(self):
        self.items = []
        self.payment_method: PaymentMethod = None
    
    def set_payment_method(self, payment_method: PaymentMethod):
        self.payment_method = payment_method
    
    def process_payment(self, amount: float) -> bool:
        if self.payment_method is None:
            raise ValueError("Payment method not set")
        return self.payment_method.process(amount)
```

#### Extract Data Transfer Object

When a class is used primarily to transfer data between layers or systems, extract a dedicated DTO.

```csharp
// Before: Domain entity used for data transfer
public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime CreatedAt { get; set; }
    
    // Domain logic
    private List<Order> orders = new List<Order>();
    private CustomerStatus status;
    
    public void AddOrder(Order order) { /* ... */ }
    public decimal GetTotalPurchaseAmount() { /* ... */ }
    public void Activate() { /* ... */ }
    
    // Used for API responses - mixing concerns
    public string ToJson() { /* ... */ }
}

// After: Separate DTO for data transfer
public class CustomerDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Status { get; set; }
    public decimal TotalPurchases { get; set; }
    
    public static CustomerDto FromDomain(Customer customer)
    {
        return new CustomerDto
        {
            Id = customer.Id,
            Name = customer.Name,
            Email = customer.Email,
            CreatedAt = customer.CreatedAt,
            Status = customer.GetStatus().ToString(),
            TotalPurchases = customer.GetTotalPurchaseAmount()
        };
    }
}

// Domain entity stays focused on business logic
public class Customer
{
    public int Id { get; private set; }
    public string Name { get; private set; }
    public string Email { get; private set; }
    public DateTime CreatedAt { get; private set; }
    
    private List<Order> orders = new List<Order>();
    private CustomerStatus status;
    
    public void AddOrder(Order order)
    {
        orders.Add(order);
        UpdateStatus();
    }
    
    public decimal GetTotalPurchaseAmount()
    {
        return orders.Sum(o => o.GetTotal());
    }
    
    public CustomerStatus GetStatus()
    {
        return status;
    }
    
    public void Activate()
    {
        if (status == CustomerStatus.Inactive)
        {
            status = CustomerStatus.Active;
        }
    }
    
    private void UpdateStatus()
    {
        // Business logic for status updates
    }
}
```

#### Extract Dependency

When a class has methods and fields related to external dependencies, extract them to improve testability.

```java
// Before: HTTP client code mixed with business logic
public class UserService {
    private String apiBaseUrl = "https://api.example.com";
    private int timeout = 5000;
    
    public User getUserById(String userId) {
        // HTTP logic mixed with business logic
        HttpURLConnection conn = null;
        try {
            URL url = new URL(apiBaseUrl + "/users/" + userId);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(timeout);
            conn.setReadTimeout(timeout);
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                BufferedReader in = new BufferedReader(
                    new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder response = new StringBuilder();
                
                while ((inputLine = in.readLine()) != null) {
                    response.append(inputLine);
                }
                in.close();
                
                // Parse JSON and create User
                return parseUser(response.toString());
            }
            return null;
        } catch (IOException e) {
            throw new RuntimeException("Failed to fetch user", e);
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
    
    private User parseUser(String json) {
        // JSON parsing logic
    }
}

// After: Extract HTTP client
public interface HttpClient {
    String get(String url) throws IOException;
}

public class DefaultHttpClient implements HttpClient {
    private final String baseUrl;
    private final int timeout;
    
    public DefaultHttpClient(String baseUrl, int timeout) {
        this.baseUrl = baseUrl;
        this.timeout = timeout;
    }
    
    @Override
    public String get(String path) throws IOException {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(baseUrl + path);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(timeout);
            conn.setReadTimeout(timeout);
            
            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                throw new IOException("HTTP error code: " + responseCode);
            }
            
            BufferedReader in = new BufferedReader(
                new InputStreamReader(conn.getInputStream()));
            String inputLine;
            StringBuilder response = new StringBuilder();
            
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            
            return response.toString();
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
}

// Service now focuses on business logic
public class UserService {
    private final HttpClient httpClient;
    private final JsonParser jsonParser;
    
    public UserService(HttpClient httpClient, JsonParser jsonParser) {
        this.httpClient = httpClient;
        this.jsonParser = jsonParser;
    }
    
    public User getUserById(String userId) {
        try {
            String json = httpClient.get("/users/" + userId);
            return jsonParser.parseUser(json);
        } catch (IOException e) {
            throw new RuntimeException("Failed to fetch user", e);
        }
    }
}
```

### Considerations and Trade-offs

#### Increased Number of Classes

Extract Class increases the total number of classes in the codebase. While this typically improves organization, it can make navigation more complex if overdone or applied inappropriately.

[Inference] In codebases where developers frequently need to understand the full picture, having many small classes might require opening more files, though modern IDEs typically mitigate this concern with good navigation tools.

#### Dependency Management

Creating new classes introduces new dependencies between classes. Consider whether the relationship should be:

- **Composition**: The original class owns the extracted class
- **Aggregation**: The original class references a shared instance
- **Dependency**: The extracted class is passed as a parameter

```python
# Composition - Order owns Address
class Order:
    def __init__(self):
        self.shipping_address = Address()  # Order creates and owns

# Aggregation - Customer references shared Address
class Customer:
    def __init__(self, home_address: Address):
        self.home_address = home_address  # Shared reference

class Order:
    def __init__(self, customer: Customer):
        self.shipping_address = customer.home_address  # Same instance

# Dependency - Service receives extracted class
class OrderValidator:
    def validate_shipping(self, address: Address) -> bool:
        # Address passed in, not owned
        return address.is_complete()
```

#### Performance Impact

Extract Class may introduce additional object allocations and method calls. In performance-critical code, measure the impact before and after refactoring.

[Inference] Modern JIT compilers and optimizers often inline small method calls, potentially mitigating performance concerns, though this behavior is not guaranteed across all platforms and scenarios.

#### Bidirectional Dependencies

Avoid creating circular dependencies where the extracted class needs to reference the original class. This typically indicates the extraction boundaries weren't chosen correctly.

```java
// Problematic: Circular dependency
public class Order {
    private OrderItems items;  // Extracted class
    
    public void addItem(Product product, int quantity) {
        items.addItem(product, quantity, this);  // Passing self
    }
}

public class OrderItems {
    private Order order;  // Reference back to Order - circular!
    private List<OrderItem> items;
    
    public void addItem(Product product, int quantity, Order order) {
        this.order = order;
        // Uses order reference...
    }
}

// Better: Redesign to avoid circular dependency
public class Order {
    private OrderItems items;
    
    public void addItem(Product product, int quantity) {
        OrderItem item = new OrderItem(product, quantity);
        items.add(item);
        updateTotal();  // Order handles its own state
    }
    
    private void updateTotal() {
        // Calculate based on items
    }
}

public class OrderItems {
    private List<OrderItem> items = new ArrayList<>();
    
    public void add(OrderItem item) {
        items.add(item);
    }
    
    public BigDecimal calculateSubtotal() {
        return items.stream()
            .map(OrderItem::getTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

#### Over-Extraction

Extracting too aggressively can create an excessive number of tiny classes that don't carry their weight. Balance is important.

[Inference] A class with a single field and getter/setter might be over-extraction unless it adds meaningful behavior or enforces important invariants. The decision depends on context and team preferences.

### Testing Considerations

#### Improved Test Focus

Extracted classes can be tested independently with focused unit tests.

```python
# Testing the extracted Address class independently
import pytest

class TestAddress:
    def test_address_validation_success(self):
        address = Address("123 Main St", "Springfield", "IL", "62701")
        assert address.is_complete()
    
    def test_address_validation_missing_street(self):
        with pytest.raises(ValueError, match="Street cannot be empty"):
            Address("", "Springfield", "IL", "62701")
    
    def test_address_validation_invalid_zip(self):
        with pytest.raises(ValueError, match="Invalid zip code"):
            Address("123 Main St", "Springfield", "IL", "invalid")
    
    def test_address_formatting(self):
        address = Address("123 Main St", "Springfield", "IL", "62701")
        formatted = address.format_for_shipping()
        assert "123 Main St" in formatted
        assert "Springfield, IL 62701" in formatted
    
    def test_address_equality(self):
        addr1 = Address("123 Main St", "Springfield", "IL", "62701")
        addr2 = Address("123 Main St", "Springfield", "IL", "62701")
        addr3 = Address("456 Oak Ave", "Springfield", "IL", "62702")
        
        assert addr1 == addr2
        assert addr1 != addr3

# Testing the Order class with extracted Address
class TestOrder:
    def test_order_with_valid_address(self):
        address = Address("123 Main St", "Springfield", "IL", "62701")
        order = Order(shipping_address=address)
        assert order.can_ship()
    
    def test_order_address_formatting(self):
        address = Address("123 Main St", "Springfield", "IL", "62701")
        order = Order(shipping_address=address)
        label = order.generate_shipping_label()
        assert "123 Main St" in label
```

#### Mock and Stub Opportunities

Extracted classes can be more easily mocked or stubbed in tests of the original class.

```java
// Testing Order without depending on real Address implementation
public class OrderTest {
    @Test
    public void testShippingCostCalculation() {
        // Mock the extracted Address class
        Address mockAddress = mock(Address.class);
        when(mockAddress.getState()).thenReturn("CA");
        when(mockAddress.isInternational()).thenReturn(false);
        
        Order order = new Order(mockAddress);
        order.addItem(new Product("Widget", 10.00), 2);
        
        BigDecimal shippingCost = order.calculateShippingCost();
        assertEquals(new BigDecimal("5.00"), shippingCost);
    }
    
    @Test
    public void testInternationalShipping() {
        Address mockAddress = mock(Address.class);
        when(mockAddress.isInternational()).thenReturn(true);
        
        Order order = new Order(mockAddress);
        order.addItem(new Product("Widget", 10.00), 1);
        
        BigDecimal shippingCost = order.calculateShippingCost();
        assertTrue(shippingCost.compareTo(new BigDecimal("15.00")) > 0);
    }
}
```

### Integration with Other Refactorings

#### Extract Class and Move Method

Often used together when methods need to follow the extracted data.

```ruby
# Before
class Report
  def initialize
    @data = []
    @chart_width = 800
    @chart_height = 600
    @chart_type = :bar
  end
  
  def generate_chart
    # Chart generation logic using @chart_* fields
  end
  
  def save_chart(filename)
    # Chart saving logic
  end
end

# After: Extract ChartSettings and move related methods
class ChartSettings
  attr_reader :width, :height, :type
  
  def initialize(width: 800, height: 600, type: :bar)
    @width = width
    @height = height
    @type = type
  end
  
  def aspect_ratio
    @width.to_f / @height
  end
end

class Chart
  def initialize(settings, data)
    @settings = settings
    @data = data
  end
  
  def generate
    # Uses @settings and @data
  end
  
  def save(filename)
    # Saving logic
  end
end

class Report
  def initialize
    @data = []
    @chart_settings = ChartSettings.new
  end
  
  def generate_chart
    chart = Chart.new(@chart_settings, @data)
    chart.generate
  end
end
```

#### Extract Class and Introduce Parameter Object

When extracted classes represent groups of parameters frequently passed together.

```typescript
// Before: Many parameters passed together
class ReportGenerator {
    generateReport(
        startDate: Date,
        endDate: Date,
        format: string,
        includeCharts: boolean,
        includeRawData: boolean
    ): Report {
        // Complex logic
    }
    
    sendReport(
        startDate: Date,
        endDate: Date,
        format: string,
        recipientEmail: string
    ): void {
        const report = this.generateReport(
            startDate, endDate, format, false, false
        );
        // Send logic
    }
}

// After: Extract parameter object
class ReportOptions {
    constructor(
        public readonly dateRange: DateRange,
        public readonly format: ReportFormat = ReportFormat.PDF,
        public readonly includeCharts: boolean = true,
        public readonly includeRawData: boolean = false
    ) {}
    
    static createDefault(startDate: Date, endDate: Date): ReportOptions {
        return new ReportOptions(
            new DateRange(startDate, endDate)
        );
    }
}

class ReportGenerator {
    generateReport(options: ReportOptions): Report {
        // Cleaner, more maintainable
    }
    
    sendReport(options: ReportOptions, recipientEmail: string): void {
        const report = this.generateReport(options);
        // Send logic
    }
}
```

#### Extract Class and Replace Data Value with Object

Transform primitive values into meaningful objects with behavior.

```csharp
// Before: Money as primitive
public class Product
{
    private decimal price;
    private string currency;
    
    public decimal GetPrice() { return price; }
    public string GetCurrency() { return currency; }
    
    public decimal ConvertPrice(string targetCurrency, decimal exchangeRate)
    {
        if (currency == targetCurrency)
            return price;
        return price * exchangeRate;
    }
}

// After: Extract Money class
public class Money
{
    private readonly decimal amount;
    private readonly Currency currency;
    
    public Money(decimal amount, Currency currency)
    {
        if (amount < 0)
            throw new ArgumentException("Amount cannot be negative");
        
        this.amount = amount;
        this.currency = currency;
    }
    
    public decimal Amount => amount;
    public Currency Currency => currency;
    
    public Money ConvertTo(Currency targetCurrency, decimal exchangeRate)
    {
        if (currency == targetCurrency)
            return this;
        
        return new Money(amount * exchangeRate, targetCurrency);
    }
    
    public Money Add(Money other)
    {
        if (currency != other.currency)
            throw new InvalidOperationException(
                "Cannot add money in different currencies");
        
        return new Money(amount + other.amount, currency);
    }
    
    public override string ToString()
    {
        return $"{currency.Symbol}{amount:F2}";
    }
}

public class Product
{
    private Money price;
    
    public Money GetPrice() { return price; }
    
    public Money GetPriceIn(Currency targetCurrency, decimal exchangeRate)
    {
        return price.ConvertTo(targetCurrency, exchangeRate);
    }
}
```

### Real-World Examples

#### E-commerce Order System

```python
# ============================================================
# Before: Monolithic Order class
# ============================================================

class Order:
    def __init__(self):
        # Order identification
        self.order_id = None
        self.order_date = None
        self.status = "pending"

        # Customer info
        self.customer_name = None
        self.customer_email = None
        self.customer_phone = None

        # Billing address
        self.billing_street = None
        self.billing_city = None
        self.billing_state = None
        self.billing_zip = None

        # Shipping address
        self.shipping_street = None
        self.shipping_city = None
        self.shipping_state = None
        self.shipping_zip = None
        self.shipping_method = None

        # Payment
        self.payment_method = None
        self.card_number = None
        self.card_expiry = None

        # Items
        self.items = []

        # Calculations
        self.subtotal = 0
        self.tax = 0
        self.shipping_cost = 0
        self.discount = 0
        self.total = 0

    def calculate_totals(self):
        self.subtotal = sum(
            item["price"] * item["quantity"] for item in self.items
        )
        self.tax = self.subtotal * 0.08
        self.shipping_cost = 10 if self.subtotal < 100 else 0
        self.total = (
            self.subtotal + self.tax + self.shipping_cost - self.discount
        )

    def validate_address(self, address_type):
        if address_type == "billing":
            return all(
                [
                    self.billing_street,
                    self.billing_city,
                    self.billing_state,
                    self.billing_zip,
                ]
            )
        elif address_type == "shipping":
            return all(
                [
                    self.shipping_street,
                    self.shipping_city,
                    self.shipping_state,
                    self.shipping_zip,
                ]
            )

    def process_payment(self):
        # Complex payment logic
        pass
````

#### User Authentication System

```java
// Before: God class handling everything
public class AuthenticationManager {
    private String username;
    private String passwordHash;
    private String salt;
    private int failedAttempts;
    private Date lastLoginTime;
    private Date accountCreatedDate;
    private boolean isLocked;
    private String sessionToken;
    private Date tokenExpiry;
    private List<String> permissions;
    private String email;
    private boolean emailVerified;
    private String phoneNumber;
    private boolean twoFactorEnabled;
    private String twoFactorSecret;
    
    public boolean authenticate(String password) {
        // Complex logic mixing concerns
    }
    
    public boolean validateToken(String token) {
        // Token validation
    }
    
    public void lockAccount() {
        // Account locking
    }
    
    public void sendVerificationEmail() {
        // Email logic
    }
}

// After: Extract multiple focused classes
public class Credentials {
    private final String username;
    private final String passwordHash;
    private final String salt;
    
    public Credentials(String username, String password) {
        this.username = username;
        this.salt = generateSalt();
        this.passwordHash = hashPassword(password, this.salt);
    }
    
    public boolean verifyPassword(String password) {
        String hash = hashPassword(password, this.salt);
        return MessageDigest.isEqual(
            hash.getBytes(),
            this.passwordHash.getBytes()
        );
    }
    
    private String hashPassword(String password, String salt) {
        // Hashing logic
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes());
            byte[] hashedBytes = md.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashedBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Hashing failed", e);
        }
    }
    
    private String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }
    
    public String getUsername() {
        return username;
    }
}

public class AccountSecurity {
    private int failedAttempts = 0;
    private boolean isLocked = false;
    private static final int MAX_ATTEMPTS = 5;
    
    public void recordFailedAttempt() {
        failedAttempts++;
        if (failedAttempts >= MAX_ATTEMPTS) {
            isLocked = true;
        }
    }
    
    public void resetFailedAttempts() {
        failedAttempts = 0;
    }
    
    public boolean isLocked() {
        return isLocked;
    }
    
    public void unlock() {
        isLocked = false;
        failedAttempts = 0;
    }
    
    public int getRemainingAttempts() {
        return Math.max(0, MAX_ATTEMPTS - failedAttempts);
    }
}

public class SessionToken {
    private final String token;
    private final Date expiry;
    private static final long VALIDITY_HOURS = 24;
    
    public SessionToken() {
        this.token = generateToken();
        this.expiry = calculateExpiry();
    }
    
    private String generateToken() {
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
    
    private Date calculateExpiry() {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.HOUR, (int) VALIDITY_HOURS);
        return cal.getTime();
    }
    
    public boolean isValid() {
        return new Date().before(expiry);
    }
    
    public String getToken() {
        return token;
    }
    
    public Date getExpiry() {
        return expiry;
    }
}

public class TwoFactorAuth {
    private final String secret;
    private boolean enabled;
    
    public TwoFactorAuth() {
        this.secret = generateSecret();
        this.enabled = false;
    }
    
    private String generateSecret() {
        // Generate TOTP secret
        SecureRandom random = new SecureRandom();
        byte[] bytes = new byte[20];
        random.nextBytes(bytes);
        return Base32.encode(bytes);
    }
    
    public void enable() {
        this.enabled = true;
    }
    
    public void disable() {
        this.enabled = false;
    }
    
    public boolean isEnabled() {
        return enabled;
    }
    
    public boolean verifyCode(String code) {
        if (!enabled) {
            return true; // Skip verification if not enabled
        }
        // TOTP verification logic
        return verifyTOTP(code, secret);
    }
    
    private boolean verifyTOTP(String code, String secret) {
        // Implementation of TOTP verification
        return true; // Simplified
    }
    
    public String getSecret() {
        return secret;
    }
}

public class UserProfile {
    private final String email;
    private final String phoneNumber;
    private boolean emailVerified;
    private final Date accountCreatedDate;
    private Date lastLoginTime;
    
    public UserProfile(String email, String phoneNumber) {
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.emailVerified = false;
        this.accountCreatedDate = new Date();
    }
    
    public void verifyEmail() {
        this.emailVerified = true;
    }
    
    public boolean isEmailVerified() {
        return emailVerified;
    }
    
    public void updateLastLogin() {
        this.lastLoginTime = new Date();
    }
    
    public String getEmail() {
        return email;
    }
    
    public Date getAccountAge() {
        return accountCreatedDate;
    }
}

// Refactored AuthenticationManager
public class AuthenticationManager {
    private final Credentials credentials;
    private final AccountSecurity security;
    private final UserProfile profile;
    private final TwoFactorAuth twoFactor;
    private SessionToken currentSession;
    
    public AuthenticationManager(
        Credentials credentials,
        UserProfile profile,
        TwoFactorAuth twoFactor
    ) {
        this.credentials = credentials;
        this.security = new AccountSecurity();
        this.profile = profile;
        this.twoFactor = twoFactor;
    }
    
    public AuthenticationResult authenticate(String password, String twoFactorCode) {
        if (security.isLocked()) {
            return AuthenticationResult.accountLocked();
        }
        
        if (!credentials.verifyPassword(password)) {
            security.recordFailedAttempt();
            return AuthenticationResult.invalidCredentials(
                security.getRemainingAttempts()
            );
        }
        
        if (!twoFactor.verifyCode(twoFactorCode)) {
            return AuthenticationResult.invalidTwoFactor();
        }
        
        security.resetFailedAttempts();
        profile.updateLastLogin();
        currentSession = new SessionToken();
        
        return AuthenticationResult.success(currentSession);
    }
    
    public boolean validateSession(String token) {
        return currentSession != null &&
               currentSession.getToken().equals(token) &&
               currentSession.isValid();
    }
    
    public void logout() {
        currentSession = null;
    }
}

// Result object for authentication
public class AuthenticationResult {
    private final boolean success;
    private final String message;
    private final SessionToken token;
    
    private AuthenticationResult(boolean success, String message, SessionToken token) {
        this.success = success;
        this.message = message;
        this.token = token;
    }
    
    public static AuthenticationResult success(SessionToken token) {
        return new AuthenticationResult(true, "Authentication successful", token);
    }
    
    public static AuthenticationResult invalidCredentials(int remainingAttempts) {
        return new AuthenticationResult(
            false,
            "Invalid credentials. " + remainingAttempts + " attempts remaining",
            null
        );
    }
    
    public static AuthenticationResult accountLocked() {
        return new AuthenticationResult(
            false,
            "Account is locked due to too many failed attempts",
            null
        );
    }
    
    public static AuthenticationResult invalidTwoFactor() {
        return new AuthenticationResult(
            false,
            "Invalid two-factor authentication code",
            null
        );
    }
    
    public boolean isSuccess() {
        return success;
    }
    
    public String getMessage() {
        return message;
    }
    
    public SessionToken getToken() {
        return token;
    }
}
````

**Key Points**

- Extract Class refactoring separates cohesive subsets of data and behavior from bloated classes into focused, single-responsibility classes
- Primary indicators for extraction include large classes with multiple responsibilities, cohesive data subsets, methods operating on specific fields, and testing difficulties
- The refactoring process involves identifying candidates, creating new classes, moving fields and methods, updating references, and establishing proper encapsulation
- Common patterns include extracting value objects, strategy objects, DTOs, and dependencies
- Benefits include improved organization, enhanced testability, better reusability, easier maintenance, and adherence to SOLID principles
- Trade-offs include increased class count, new dependency relationships, potential performance impacts (though often negligible), and the risk of over-extraction
- Extract Class often combines with other refactorings like Move Method, Introduce Parameter Object, and Replace Data Value with Object
- Proper extraction improves test focus by enabling independent testing of extracted classes with clearer assertions and easier mocking

**Example**

Here's a comprehensive example showing the complete refactoring of a file processing system:

```python
# Before: Monolithic FileProcessor class
import hashlib
import os
from datetime import datetime
from typing import List, Dict

class FileProcessor:
    """
    A problematic class handling too many responsibilities:
    - File validation
    - File metadata extraction
    - File content processing
    - Storage management
    - Logging and auditing
    """
    
    def __init__(self, storage_path: str):
        self.storage_path = storage_path
        self.processed_files: List[Dict] = []
        self.max_file_size = 10 * 1024 * 1024  # 10MB
        self.allowed_extensions = ['.txt', '.pdf', '.doc', '.docx']
        self.log_entries: List[str] = []
    
    def process_file(self, file_path: str) -> bool:
        """Process a file with all validation and storage logic mixed"""
        # Validation
        if not os.path.exists(file_path):
            self.log_entries.append(f"{datetime.now()}: File not found: {file_path}")
            return False
        
        file_size = os.path.getsize(file_path)
        if file_size > self.max_file_size:
            self.log_entries.append(f"{datetime.now()}: File too large: {file_path}")
            return False
        
        file_ext = os.path.splitext(file_path)[1].lower()
        if file_ext not in self.allowed_extensions:
            self.log_entries.append(f"{datetime.now()}: Invalid extension: {file_path}")
            return False
        
        # Metadata extraction
        file_name = os.path.basename(file_path)
        created_time = datetime.fromtimestamp(os.path.getctime(file_path))
        modified_time = datetime.fromtimestamp(os.path.getmtime(file_path))
        
        # Calculate hash
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        file_hash = hash_md5.hexdigest()
        
        # Check for duplicates
        for processed in self.processed_files:
            if processed['hash'] == file_hash:
                self.log_entries.append(f"{datetime.now()}: Duplicate file: {file_path}")
                return False
        
        # Storage
        dest_path = os.path.join(self.storage_path, file_name)
        counter = 1
        while os.path.exists(dest_path):
            name, ext = os.path.splitext(file_name)
            dest_path = os.path.join(self.storage_path, f"{name}_{counter}{ext}")
            counter += 1
        
        try:
            with open(file_path, 'rb') as src:
                with open(dest_path, 'wb') as dst:
                    dst.write(src.read())
        except Exception as e:
            self.log_entries.append(f"{datetime.now()}: Storage failed: {str(e)}")
            return False
        
        # Record processing
        self.processed_files.append({
            'name': file_name,
            'path': dest_path,
            'size': file_size,
            'hash': file_hash,
            'created': created_time,
            'modified': modified_time,
            'processed': datetime.now()
        })
        
        self.log_entries.append(f"{datetime.now()}: Successfully processed: {file_path}")
        return True
    
    def get_processed_count(self) -> int:
        return len(self.processed_files)
    
    def get_total_size(self) -> int:
        return sum(f['size'] for f in self.processed_files)
    
    def find_files_by_extension(self, extension: str) -> List[Dict]:
        return [f for f in self.processed_files 
                if f['name'].endswith(extension)]
    
    def get_logs(self) -> List[str]:
        return self.log_entries.copy()


# After: Extracted into focused, cohesive classes

# 1. Extract file validation logic
from dataclasses import dataclass
from typing import Set
from pathlib import Path

@dataclass(frozen=True)
class FileValidationRules:
    """Encapsulates validation rules for file processing"""
    max_size_bytes: int
    allowed_extensions: Set[str]
    
    @staticmethod
    def default_rules() -> 'FileValidationRules':
        return FileValidationRules(
            max_size_bytes=10 * 1024 * 1024,  # 10MB
            allowed_extensions={'.txt', '.pdf', '.doc', '.docx'}
        )
    
    def is_size_valid(self, size_bytes: int) -> bool:
        return size_bytes <= self.max_size_bytes
    
    def is_extension_valid(self, extension: str) -> bool:
        return extension.lower() in self.allowed_extensions


class FileValidator:
    """Handles file validation logic"""
    
    def __init__(self, rules: FileValidationRules):
        self.rules = rules
    
    def validate(self, file_path: Path) -> 'ValidationResult':
        if not file_path.exists():
            return ValidationResult.failure("File does not exist")
        
        if not file_path.is_file():
            return ValidationResult.failure("Path is not a file")
        
        size = file_path.stat().st_size
        if not self.rules.is_size_valid(size):
            max_mb = self.rules.max_size_bytes / (1024 * 1024)
            return ValidationResult.failure(
                f"File exceeds maximum size of {max_mb}MB"
            )
        
        extension = file_path.suffix
        if not self.rules.is_extension_valid(extension):
            allowed = ', '.join(self.rules.allowed_extensions)
            return ValidationResult.failure(
                f"Invalid file extension. Allowed: {allowed}"
            )
        
        return ValidationResult.success()


@dataclass(frozen=True)
class ValidationResult:
    """Result of file validation"""
    is_valid: bool
    error_message: str = ""
    
    @staticmethod
    def success() -> 'ValidationResult':
        return ValidationResult(is_valid=True)
    
    @staticmethod
    def failure(message: str) -> 'ValidationResult':
        return ValidationResult(is_valid=False, error_message=message)


# 2. Extract file metadata handling
from datetime import datetime
from dataclasses import dataclass

@dataclass(frozen=True)
class FileMetadata:
    """Encapsulates file metadata"""
    name: str
    path: Path
    size_bytes: int
    hash_md5: str
    created_at: datetime
    modified_at: datetime
    
    @staticmethod
    def from_path(file_path: Path) -> 'FileMetadata':
        """Extract metadata from a file"""
        stats = file_path.stat()
        
        return FileMetadata(
            name=file_path.name,
            path=file_path,
            size_bytes=stats.st_size,
            hash_md5=FileMetadata._calculate_hash(file_path),
            created_at=datetime.fromtimestamp(stats.st_ctime),
            modified_at=datetime.fromtimestamp(stats.st_mtime)
        )
    
    @staticmethod
    def _calculate_hash(file_path: Path) -> str:
        """Calculate MD5 hash of file"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    
    def get_extension(self) -> str:
        return self.path.suffix.lower()
    
    def get_size_mb(self) -> float:
        return self.size_bytes / (1024 * 1024)


# 3. Extract storage management
import shutil

class FileStorage:
    """Handles file storage operations"""
    
    def __init__(self, storage_directory: Path):
        self.storage_directory = storage_directory
        self.storage_directory.mkdir(parents=True, exist_ok=True)
    
    def store(self, source_path: Path) -> Path:
        """Store a file and return its destination path"""
        destination = self._get_unique_path(source_path.name)
        shutil.copy2(source_path, destination)
        return destination
    
    def _get_unique_path(self, filename: str) -> Path:
        """Generate a unique path for the file"""
        destination = self.storage_directory / filename
        
        if not destination.exists():
            return destination
        
        # Handle name collisions
        name_stem = destination.stem
        extension = destination.suffix
        counter = 1
        
        while destination.exists():
            new_name = f"{name_stem}_{counter}{extension}"
            destination = self.storage_directory / new_name
            counter += 1
        
        return destination
    
    def exists(self, filename: str) -> bool:
        return (self.storage_directory / filename).exists()


# 4. Extract processed file records
from typing import List, Optional

@dataclass(frozen=True)
class ProcessedFile:
    """Record of a processed file"""
    metadata: FileMetadata
    stored_path: Path
    processed_at: datetime
    
    @staticmethod
    def create(metadata: FileMetadata, stored_path: Path) -> 'ProcessedFile':
        return ProcessedFile(
            metadata=metadata,
            stored_path=stored_path,
            processed_at=datetime.now()
        )


class ProcessedFileRegistry:
    """Maintains registry of processed files"""
    
    def __init__(self):
        self._files: List[ProcessedFile] = []
        self._hashes: Set[str] = set()
    
    def add(self, processed_file: ProcessedFile) -> None:
        """Add a processed file to the registry"""
        self._files.append(processed_file)
        self._hashes.add(processed_file.metadata.hash_md5)
    
    def is_duplicate(self, hash_md5: str) -> bool:
        """Check if a file with this hash was already processed"""
        return hash_md5 in self._hashes
    
    def get_all(self) -> List[ProcessedFile]:
        """Get all processed files"""
        return self._files.copy()
    
    def get_by_extension(self, extension: str) -> List[ProcessedFile]:
        """Get files by extension"""
        return [f for f in self._files 
                if f.metadata.get_extension() == extension.lower()]
    
    def get_total_count(self) -> int:
        """Get total number of processed files"""
        return len(self._files)
    
    def get_total_size(self) -> int:
        """Get total size of all processed files in bytes"""
        return sum(f.metadata.size_bytes for f in self._files)


# 5. Extract logging functionality
from enum import Enum

class LogLevel(Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"

@dataclass(frozen=True)
class LogEntry:
    """Single log entry"""
    timestamp: datetime
    level: LogLevel
    message: str
    
    def __str__(self) -> str:
        return f"[{self.timestamp}] {self.level.value}: {self.message}"


class ProcessingLogger:
    """Handles logging of file processing events"""
    
    def __init__(self):
        self._entries: List[LogEntry] = []
    
    def info(self, message: str) -> None:
        self._log(LogLevel.INFO, message)
    
    def warning(self, message: str) -> None:
        self._log(LogLevel.WARNING, message)
    
    def error(self, message: str) -> None:
        self._log(LogLevel.ERROR, message)
    
    def _log(self, level: LogLevel, message: str) -> None:
        entry = LogEntry(
            timestamp=datetime.now(),
            level=level,
            message=message
        )
        self._entries.append(entry)
    
    def get_entries(self) -> List[LogEntry]:
        return self._entries.copy()
    
    def get_entries_by_level(self, level: LogLevel) -> List[LogEntry]:
        return [e for e in self._entries if e.level == level]


# 6. Refactored FileProcessor using extracted classes
class FileProcessor:
    """
    Refactored file processor with clear separation of concerns.
    Now orchestrates specialized classes instead of doing everything itself.
    """
    
    def __init__(
        self,
        storage: FileStorage,
        validator: FileValidator,
        registry: ProcessedFileRegistry,
        logger: ProcessingLogger
    ):
        self.storage = storage
        self.validator = validator
        self.registry = registry
        self.logger = logger
    
    def process_file(self, file_path: str) -> bool:
        """Process a file using coordinated specialized classes"""
        path = Path(file_path)
        
        # Validate
        validation_result = self.validator.validate(path)
        if not validation_result.is_valid:
            self.logger.error(f"Validation failed: {validation_result.error_message}")
            return False
        
        # Extract metadata
        try:
            metadata = FileMetadata.from_path(path)
        except Exception as e:
            self.logger.error(f"Failed to extract metadata: {str(e)}")
            return False
        
        # Check for duplicates
        if self.registry.is_duplicate(metadata.hash_md5):
            self.logger.warning(f"Duplicate file detected: {metadata.name}")
            return False
        
        # Store file
        try:
            stored_path = self.storage.store(path)
        except Exception as e:
            self.logger.error(f"Storage failed: {str(e)}")
            return False
        
        # Record processing
        processed_file = ProcessedFile.create(metadata, stored_path)
        self.registry.add(processed_file)
        
        self.logger.info(f"Successfully processed: {metadata.name}")
        return True
    
    def get_statistics(self) -> Dict[str, any]:
        """Get processing statistics"""
        return {
            'total_files': self.registry.get_total_count(),
            'total_size_mb': self.registry.get_total_size() / (1024 * 1024),
            'processed_files': self.registry.get_all()
        }


# Usage example showing the improved design
def main():
    # Configure components
    storage = FileStorage(Path("./processed_files"))
    rules = FileValidationRules.default_rules()
    validator = FileValidator(rules)
    registry = ProcessedFileRegistry()
    logger = ProcessingLogger()
    
    # Create processor with injected dependencies
    processor = FileProcessor(storage, validator, registry, logger)
    
    # Process files
    files_to_process = ["document1.pdf", "data.txt", "report.doc"]
    
    for file_path in files_to_process:
        success = processor.process_file(file_path)
        if success:
            print(f"✓ Processed: {file_path}")
        else:
            print(f"✗ Failed: {file_path}")
    
    # Get statistics
    stats = processor.get_statistics()
    print(f"\nProcessed {stats['total_files']} files")
    print(f"Total size: {stats['total_size_mb']:.2f} MB")
    
    # Review logs
    print("\nProcessing Log:")
    for entry in logger.get_entries():
        print(f"  {entry}")
    
    # Find specific files
    pdf_files = registry.get_by_extension('.pdf')
    print(f"\nPDF files: {len(pdf_files)}")


if __name__ == "__main__":
    main()
```

**Output**

When running the refactored code:

```
✓ Processed: document1.pdf
✓ Processed: data.txt
✗ Failed: report.doc

Processed 2 files
Total size: 2.45 MB

Processing Log:
  [2025-01-15 10:30:15] INFO: Successfully processed: document1.pdf 
  [2025-01-15 10:30:16] INFO: Successfully processed: data.txt 
  [2025-01-15 10:30:17] ERROR: Validation failed: File does not exist

PDF files: 1
````

Testing the extracted classes independently:

```python
import pytest
from pathlib import Path

class TestFileValidator:
    def test_validates_existing_file(self, tmp_path):
        # Create test file
        test_file = tmp_path / "test.txt"
        test_file.write_text("content")
        
        rules = FileValidationRules.default_rules()
        validator = FileValidator(rules)
        
        result = validator.validate(test_file)
        assert result.is_valid
    
    def test_rejects_oversized_file(self, tmp_path):
        # Create large file
        test_file = tmp_path / "large.txt"
        test_file.write_bytes(b'x' * (11 * 1024 * 1024))  # 11MB
        
        rules = FileValidationRules(
            max_size_bytes=10 * 1024 * 1024,
            allowed_extensions={'.txt'}
        )
        validator = FileValidator(rules)
        
        result = validator.validate(test_file)
        assert not result.is_valid
        assert "exceeds maximum size" in result.error_message

class TestProcessedFileRegistry:
    def test_detects_duplicates(self):
        registry = ProcessedFileRegistry()
        
        metadata = FileMetadata(
            name="test.txt",
            path=Path("test.txt"),
            size_bytes=100,
            hash_md5="abc123",
            created_at=datetime.now(),
            modified_at=datetime.now()
        )
        
        processed = ProcessedFile.create(metadata, Path("stored/test.txt"))
        registry.add(processed)
        
        assert registry.is_duplicate("abc123")
        assert not registry.is_duplicate("different_hash")
    
    def test_filters_by_extension(self):
        registry = ProcessedFileRegistry()
        
        # Add different file types
        for ext in ['.pdf', '.txt', '.pdf']:
            metadata = FileMetadata(
                name=f"file{ext}",
                path=Path(f"file{ext}"),
                size_bytes=100,
                hash_md5=f"hash{ext}",
                created_at=datetime.now(),
                modified_at=datetime.now()
            )
            processed = ProcessedFile.create(metadata, Path(f"stored/file{ext}"))
            registry.add(processed)
        
        pdf_files = registry.get_by_extension('.pdf')
        assert len(pdf_files) == 2
````

**Conclusion**

Extract Class is a powerful refactoring technique that addresses code bloat and responsibility overload by creating focused, cohesive classes from monolithic ones. The refactoring improves code organization, maintainability, testability, and reusability while supporting SOLID principles, particularly the Single Responsibility Principle.

The process involves carefully identifying cohesive subsets of data and behavior, creating appropriately named classes, moving fields and methods, and establishing proper relationships between classes. Common patterns include extracting value objects, strategy objects, DTOs, and dependencies, each serving specific architectural needs.

[Inference] While Extract Class increases the number of classes and introduces new dependencies, these trade-offs typically result in net improvements to code quality, though the specific benefits may vary based on team preferences, codebase size, and domain complexity.

Success with Extract Class requires balancing thoroughness with pragmatism—extracting enough to achieve clear separation of concerns without creating excessive fragmentation. The refactoring works best when combined with comprehensive testing, clear naming conventions, and thoughtful consideration of class relationships and responsibilities.

**Next Steps**

1. **Audit your codebase** for large classes with multiple responsibilities using metrics like lines of code, number of methods, and cyclomatic complexity
2. **Start with clear cases** where extraction boundaries are obvious, such as address information or payment processing logic
3. **Write tests before refactoring** to ensure behavior remains unchanged during the extraction process
4. **Extract incrementally** by moving one cohesive group at a time rather than attempting large-scale refactoring in a single step
5. **Review SOLID principles** to better recognize when classes violate the Single Responsibility Principle
6. **Study your domain model** to identify natural boundaries where extraction would align with business concepts
7. **Use IDE refactoring tools** that automate parts of the extraction process while maintaining code correctness
8. **Document extracted classes** with clear explanations of their single responsibility and intended use cases
9. **Consider immutability** for extracted value objects to improve thread safety and reduce bugs
10. **Evaluate extraction candidates** during code reviews to build team consensus on appropriate class granularity

---

## Move Method

Move Method is a refactoring technique that relocates a method from one class to another when the method is more closely related to features or data in a different class than the one it currently resides in. This refactoring improves code organization by placing behavior closer to the data it operates on, resulting in better cohesion and reduced coupling.

### When to Apply Move Method

**Key Points:**

- A method uses features of another class more than its own class
- A method would fit better conceptually in another class
- Moving would reduce dependencies between classes
- The method accesses data from another class extensively
- Future changes to the method would likely require modifying the other class

### Benefits of Move Method

Moving methods to more appropriate classes provides several advantages:

- **Improved cohesion**: Classes become more focused on their core responsibilities
- **Reduced coupling**: Classes depend less on each other's internal details
- **Better encapsulation**: Data and behavior stay together
- **Easier maintenance**: Related functionality is located in one place
- **Clearer intent**: Class responsibilities become more obvious

### Mechanics of Moving a Method

The refactoring process involves several steps:

1. Examine all features used by the method in its current class
2. Check for other methods and fields that should move with it
3. Check subclasses and superclasses for other declarations of the method
4. Declare the method in the target class
5. Copy the code to the target class and adjust it to work in its new home
6. Determine how to reference the target object from the source
7. Turn the source method into a delegating method or remove it entirely
8. Compile and test

### Example

Consider an account management system where a method for calculating overdraft charges is misplaced:

```java
// Before refactoring
class Account {
    private AccountType type;
    private int daysOverdrawn;
    
    public double overdraftCharge() {
        if (type.isPremium()) {
            double result = 10;
            if (daysOverdrawn > 7) {
                result += (daysOverdrawn - 7) * 0.85;
            }
            return result;
        } else {
            return daysOverdrawn * 1.75;
        }
    }
    
    public double bankCharge() {
        double result = 4.5;
        if (daysOverdrawn > 0) {
            result += overdraftCharge();
        }
        return result;
    }
}

class AccountType {
    private boolean premium;
    
    public boolean isPremium() {
        return premium;
    }
}
```

The `overdraftCharge()` method uses the `type` object more than features of its own class. The calculation logic depends entirely on the account type. This indicates the method belongs in the `AccountType` class.

**After refactoring:**

```java
class Account {
    private AccountType type;
    private int daysOverdrawn;
    
    public double overdraftCharge() {
        return type.overdraftCharge(daysOverdrawn);
    }
    
    public double bankCharge() {
        double result = 4.5;
        if (daysOverdrawn > 0) {
            result += overdraftCharge();
        }
        return result;
    }
}

class AccountType {
    private boolean premium;
    
    public boolean isPremium() {
        return premium;
    }
    
    public double overdraftCharge(int daysOverdrawn) {
        if (isPremium()) {
            double result = 10;
            if (daysOverdrawn > 7) {
                result += (daysOverdrawn - 7) * 0.85;
            }
            return result;
        } else {
            return daysOverdrawn * 1.75;
        }
    }
}
```

The overdraft calculation now resides in `AccountType` where it belongs. The `Account` class delegates to this method, passing the necessary data. If we later remove all other references to `overdraftCharge()` in `Account`, we can eliminate the delegating method entirely.

### Alternative Approach: Complete Delegation Removal

If the moved method is only called from one place, we can inline the delegating method:

```java
class Account {
    private AccountType type;
    private int daysOverdrawn;
    
    public double bankCharge() {
        double result = 4.5;
        if (daysOverdrawn > 0) {
            result += type.overdraftCharge(daysOverdrawn);
        }
        return result;
    }
}
```

### Handling Different Scenarios

**Moving to a method parameter:**

When a method should move to one of its parameters:

```java
// Before
class Order {
    public double calculateTotal(Customer customer) {
        double discount = customer.getDiscountRate();
        // Complex discount calculation using customer data
        return basePrice * (1 - discount);
    }
}

// After
class Customer {
    public double calculateDiscount(double basePrice) {
        double discount = getDiscountRate();
        return basePrice * (1 - discount);
    }
}

class Order {
    public double calculateTotal(Customer customer) {
        return customer.calculateDiscount(basePrice);
    }
}
```

**Moving with field references:**

When the method needs data from its original class:

```java
// Before
class Project {
    private List<Task> tasks;
    
    public double calculateTotalEffort() {
        return tasks.stream()
            .mapToDouble(Task::getEffort)
            .sum();
    }
}

// After - if this calculation belongs to a TaskCollection class
class TaskCollection {
    private List<Task> tasks;
    
    public double calculateTotalEffort() {
        return tasks.stream()
            .mapToDouble(Task::getEffort)
            .sum();
    }
}

class Project {
    private TaskCollection tasks;
    
    public double calculateTotalEffort() {
        return tasks.calculateTotalEffort();
    }
}
```

### Common Patterns Leading to Move Method

**Feature Envy:**

A method that seems more interested in another class's data than its own:

```java
// Feature Envy example
class Invoice {
    public String generateCustomerReport(Customer customer) {
        StringBuilder report = new StringBuilder();
        report.append(customer.getName());
        report.append(customer.getAddress());
        report.append(customer.getPhoneNumber());
        report.append(customer.getEmail());
        // This method is envious of Customer's features
        return report.toString();
    }
}
```

This should likely be `Customer.generateReport()` instead.

**Misplaced Business Logic:**

Logic that belongs to a domain concept rather than a coordinator:

```java
// Before
class OrderProcessor {
    public boolean canShipOrder(Order order) {
        return order.getItems().size() > 0 
            && order.getPaymentStatus() == PaymentStatus.PAID
            && order.getShippingAddress() != null;
    }
}

// After - this is really about Order's state
class Order {
    public boolean canShip() {
        return items.size() > 0 
            && paymentStatus == PaymentStatus.PAID
            && shippingAddress != null;
    }
}
```

### Indicators You Should NOT Move a Method

[Inference] Some situations suggest keeping a method in its current location:

- The method uses many features from both classes equally
- The method represents a coordination or orchestration concern
- Moving would create circular dependencies
- The method is part of a stable public API
- The source class is the natural "home" for the operation conceptually

**Note:** [Inference] These indicators are based on common design principles, but specific project contexts may suggest different approaches.

### Testing During Move Method Refactoring

Maintain safety through testing:

1. **Before moving**: Ensure comprehensive tests exist for the method's behavior
2. **After copying**: Test the new method in isolation in the target class
3. **After delegation**: Verify the delegating method works correctly
4. **After removal**: Confirm all callers work with the new location

[Inference] Thorough testing at each step helps catch issues early, though it cannot guarantee all edge cases are covered in every scenario.

### Relationship to Other Refactorings

Move Method often works together with other refactorings:

- **Extract Method**: Often precedes Move Method to isolate movable code
- **Inline Method**: May follow Move Method to remove unnecessary delegation
- **Move Field**: Frequently accompanies Move Method when data and behavior move together
- **Extract Class**: May be the next step when multiple methods and fields should move together

### Real-World Considerations

**API Stability:**

When moving public methods, consider maintaining the old method temporarily:

```java
class Account {
    @Deprecated
    public double overdraftCharge() {
        // Maintain backward compatibility
        return type.overdraftCharge(daysOverdrawn);
    }
}
```

**Performance Impact:**

[Inference] Adding delegation layers may introduce minimal method call overhead, though modern JVMs typically optimize these calls effectively. Profile if performance is critical.

**Dependency Management:**

Moving methods may change package dependencies. Ensure the move doesn't introduce unwanted coupling between modules or packages.

### Automation Support

Many IDEs provide automated Move Method refactoring:

- **IntelliJ IDEA**: Right-click method → Refactor → Move
- **Eclipse**: Right-click method → Refactor → Move
- **Visual Studio**: Right-click method → Quick Actions → Move to [class]

[Inference] These tools generally handle most mechanical aspects reliably, though manual review of the results remains advisable for complex scenarios.

**Conclusion:**

Move Method is a foundational refactoring that keeps code organized around natural conceptual boundaries. By placing methods where they best belong, you create systems that are easier to understand, modify, and extend. The key is recognizing when a method's true allegiance lies with another class's data and responsibilities, then acting on that insight to improve your design.

---

## Inline Method

Inline Method is a refactoring technique that replaces a method call with the actual body of the method being called, then removes the now-unnecessary method. This refactoring simplifies code by eliminating unnecessary indirection when a method's body is as clear as its name, or when the method is too simple to justify its existence.

### Understanding Inline Method

Inline Method is the inverse of Extract Method. While Extract Method takes a code fragment and turns it into a method, Inline Method does the opposite—it takes a method and puts its code directly where it's being called.

This refactoring is particularly useful when:

- The method body is as self-explanatory as the method name
- You have excessive indirection and too many methods delegating to other methods
- The method contains only a single, simple statement
- You're reorganizing code and need to consolidate functionality before re-extracting it differently

### When to Apply Inline Method

**Appropriate scenarios:**

- **Overly simple methods**: When a method does nothing more than return a field or perform a trivial calculation
- **Misnamed methods**: When the method name doesn't accurately describe what it does, and inlining before re-extracting makes sense
- **Excessive delegation**: When you have chains of methods calling other methods with no added value
- **Refactoring preparation**: When restructuring code architecture and you need to inline before extracting differently
- **Performance considerations**: In performance-critical paths where method call overhead matters [though modern compilers often handle this automatically]

**When to avoid:**

- The method is overridden in subclasses (polymorphism would be lost)
- The method is referenced in multiple places and inlining would create duplication
- The method encapsulates complex logic that benefits from isolation
- The method name provides valuable documentation of intent
- The method is part of a public API

### Basic Mechanics

The refactoring process typically follows these steps:

1. Verify the method is not polymorphic (not overridden in subclasses)
2. Find all calls to the method
3. Replace each call with the method body
4. Adjust the inlined code for the calling context (rename variables, handle parameters)
5. Test after each replacement
6. Remove the method definition once all calls are replaced

### Simple Examples

**Example 1: Trivial Getter**

Before refactoring:

```python
class Order:
    def __init__(self, quantity, item_price):
        self._quantity = quantity
        self._item_price = item_price
    
    def get_base_price(self):
        return self._quantity * self._item_price
    
    def calculate_total(self):
        base_price = self.get_base_price()
        discount = 0.1 if base_price > 1000 else 0
        return base_price * (1 - discount)
```

After inlining `get_base_price()`:

```python
class Order:
    def __init__(self, quantity, item_price):
        self._quantity = quantity
        self._item_price = item_price
    
    def calculate_total(self):
        base_price = self._quantity * self._item_price
        discount = 0.1 if base_price > 1000 else 0
        return base_price * (1 - discount)
```

**Example 2: Single-Statement Method**

Before refactoring:

```java
public class Customer {
    private int numberOfOrders;
    
    public boolean moreThanFiveOrders() {
        return numberOfOrders > 5;
    }
    
    public String getRating() {
        return moreThanFiveOrders() ? "Premium" : "Standard";
    }
}
```

After inlining:

```java
public class Customer {
    private int numberOfOrders;
    
    public String getRating() {
        return (numberOfOrders > 5) ? "Premium" : "Standard";
    }
}
```

### Complex Example with Multiple Calls

**Example: Excessive Delegation**

Before refactoring:

```javascript
class ShippingCalculator {
    constructor(order) {
        this.order = order;
    }
    
    getBaseShippingCost() {
        return 5.00;
    }
    
    getWeightMultiplier() {
        return 0.5;
    }
    
    calculateWeightCost() {
        return this.order.weight * this.getWeightMultiplier();
    }
    
    calculateShipping() {
        const baseCost = this.getBaseShippingCost();
        const weightCost = this.calculateWeightCost();
        return baseCost + weightCost;
    }
}

// Usage
const calculator = new ShippingCalculator(order);
const shipping = calculator.calculateShipping();
```

After strategic inlining:

```javascript
class ShippingCalculator {
    constructor(order) {
        this.order = order;
    }
    
    calculateShipping() {
        const baseCost = 5.00;
        const weightCost = this.order.weight * 0.5;
        return baseCost + weightCost;
    }
}

// Usage
const calculator = new ShippingCalculator(order);
const shipping = calculator.calculateShipping();
```

**Key Points:**

- Eliminated three trivial methods that added no meaningful abstraction
- The final `calculateShipping()` method is now self-contained and easier to understand
- Constants could be extracted to class-level or configuration if they need to vary

### Handling Parameters and Return Values

When inlining methods with parameters, you must substitute the parameter references with the actual argument values.

**Example:**

Before refactoring:

```python
def calculate_discount(order):
    return get_discount_percentage(order.total) * order.total

def get_discount_percentage(total):
    if total > 1000:
        return 0.15
    elif total > 500:
        return 0.10
    else:
        return 0.05
```

After inlining:

```python
def calculate_discount(order):
    # Inlined get_discount_percentage with order.total as the parameter
    if order.total > 1000:
        discount_percentage = 0.15
    elif order.total > 500:
        discount_percentage = 0.10
    else:
        discount_percentage = 0.05
    
    return discount_percentage * order.total
```

### Working with Recursion

[Note: Inlining recursive methods is generally not advisable and may be impossible without fundamentally changing the algorithm structure]

Recursive methods typically should not be inlined because:

- The method calls itself, making complete inlining impossible
- Recursion provides a clear, elegant solution to certain problems
- Inlining would require converting to an iterative approach, which is a different refactoring

### Tool Support and Automation

Most modern IDEs provide automated Inline Method refactoring:

- **IntelliJ IDEA**: `Ctrl+Alt+N` (Windows/Linux) or `Cmd+Alt+N` (Mac)
- **Visual Studio**: Right-click → Quick Actions → Inline Method
- **VS Code**: With appropriate extensions (e.g., C# extension for .NET code)
- **Eclipse**: `Alt+Shift+I`
- **PyCharm**: `Ctrl+Alt+N` (Windows/Linux) or `Cmd+Alt+N` (Mac)

Automated tools handle:

- Finding all method call sites
- Substituting parameters correctly
- Preserving semantics
- Managing variable scoping issues

**Caution**: Always review automated inlining results, as tools may not account for side effects or contextual nuances.

### Potential Issues and Edge Cases

#### Side Effects and Order of Execution

**Example with side effects:**

```ruby
class Counter
  def initialize
    @count = 0
  end
  
  def increment
    @count += 1
  end
  
  def process
    value = increment + increment  # Side effect: modifies @count twice
    puts value
  end
end
```

Inlining `increment` naively could change behavior:

```ruby
def process
  value = (@count += 1) + (@count += 1)  # Order of evaluation matters!
  puts value
end
```

[Inference: The behavior may differ depending on the language's evaluation order guarantees]

#### Variable Name Conflicts

When inlining introduces variable names that conflict with existing variables in the calling scope:

```python
def outer():
    temp = 10
    result = calculate(5)  # calculate() also uses 'temp'
    return result + temp

def calculate(value):
    temp = value * 2
    return temp + 5
```

After inlining, you must rename variables to avoid conflicts:

```python
def outer():
    temp = 10
    # Inlined calculate(5) with renamed variable
    temp_calc = 5 * 2
    result = temp_calc + 5
    return result + temp
```

### Combining with Other Refactorings

Inline Method often works in conjunction with other refactoring techniques:

**Inline Method → Extract Method**: Inline existing methods, then extract new methods with better structure

**Example:**

```java
// Original with poor organization
class ReportGenerator {
    String generateHeader() { return "=== Report ==="; }
    String generateBody() { return fetchData(); }
    String generateFooter() { return "=== End ==="; }
    
    String createReport() {
        return generateHeader() + "\n" + 
               generateBody() + "\n" + 
               generateFooter();
    }
}

// After inlining all methods
class ReportGenerator {
    String createReport() {
        return "=== Report ===\n" + 
               fetchData() + "\n" + 
               "=== End ===";
    }
}

// Then re-extract with better structure
class ReportGenerator {
    String createReport() {
        return formatReport(fetchData());
    }
    
    private String formatReport(String data) {
        return "=== Report ===\n" + data + "\n=== End ===";
    }
}
```

### Performance Considerations

**Theoretical benefits:**

- Eliminates method call overhead
- Enables additional compiler optimizations (inlining at call site)
- Reduces stack frame allocation

**Practical reality:**

- Modern JIT compilers (Java HotSpot, .NET CLR, V8) automatically inline hot methods
- The readability trade-off usually outweighs micro-optimizations
- Premature optimization can harm maintainability

[Inference: Performance gains from manual inlining are typically negligible in modern managed languages with sophisticated JIT compilers]

**When performance matters:**

- Profile first to identify actual bottlenecks
- Consider inline method refactoring only for proven hot paths
- Language-specific features (e.g., C++ `inline` keyword, C# `MethodImpl(MethodImplOptions.AggressiveInlining)`) may be more appropriate

### Language-Specific Considerations

#### Python

Python's dynamic nature makes inlining straightforward syntactically, but consider:

- Decorators on methods may have side effects that are lost when inlining
- Methods may be monkey-patched at runtime

```python
class Example:
    @property
    def value(self):
        return self._value
    
    def get_doubled(self):
        return self.value * 2  # Inlining would lose property access benefits
```

#### Java/C#

Static typing helps catch errors during inlining:

- Method visibility (public/private/protected) considerations
- Generic type parameters must be substituted correctly
- Exception specifications may need adjustment

#### JavaScript/TypeScript

Dynamic typing requires extra caution:

- `this` binding may change when inlining
- Closure scoping must be preserved

```javascript
class Handler {
    constructor() {
        this.count = 0;
    }
    
    increment() {
        this.count++;
    }
    
    setupButton() {
        button.addEventListener('click', this.increment);  
        // Inlining would break 'this' binding!
    }
}
```

### Code Smells Indicating Inline Method

The following code smells suggest Inline Method might be beneficial:

1. **Speculative Generality**: Methods created "just in case" they might be needed
2. **Middle Man**: Classes that delegate most work to other classes
3. **Feature Envy**: Methods that seem more interested in other classes' data
4. **Lazy Class**: Classes that don't do enough to justify their existence

**Example of Middle Man:**

```csharp
class Person {
    private Department department;
    
    public Department GetDepartment() {
        return department;
    }
    
    public string GetDepartmentManager() {
        return GetDepartment().GetManager();  // Unnecessary delegation
    }
}

// After inlining GetDepartment():
class Person {
    private Department department;
    
    public string GetDepartmentManager() {
        return department.GetManager();
    }
}
```

### Testing Considerations

When performing Inline Method refactoring:

1. **Run existing tests**: Ensure behavior is preserved
2. **Consider test coverage**: If the inlined method had dedicated tests, those tests may need updating or removal
3. **Integration tests**: More valuable after inlining, as unit tests for trivial methods may no longer be necessary

**Example test evolution:**

Before:

```python
def test_get_base_price():
    order = Order(quantity=5, item_price=10)
    assert order.get_base_price() == 50

def test_calculate_total():
    order = Order(quantity=5, item_price=10)
    assert order.calculate_total() == 50
```

After inlining `get_base_price()`:

```python
def test_calculate_total():
    order = Order(quantity=5, item_price=10)
    assert order.calculate_total() == 50
    
def test_calculate_total_with_discount():
    order = Order(quantity=150, item_price=10)
    assert order.calculate_total() == 1350  # 1500 * 0.9
```

### Real-World Example: Refactoring a Validation Chain

**Before - Excessive method decomposition:**

```typescript
class UserValidator {
    private errors: string[] = [];
    
    validate(user: User): boolean {
        this.checkUsername(user);
        this.checkEmail(user);
        this.checkAge(user);
        return this.hasNoErrors();
    }
    
    private checkUsername(user: User): void {
        if (!this.isValidUsername(user.username)) {
            this.addError("Invalid username");
        }
    }
    
    private isValidUsername(username: string): boolean {
        return username.length >= 3;
    }
    
    private checkEmail(user: User): void {
        if (!this.isValidEmail(user.email)) {
            this.addError("Invalid email");
        }
    }
    
    private isValidEmail(email: string): boolean {
        return email.includes("@");
    }
    
    private checkAge(user: User): void {
        if (!this.isValidAge(user.age)) {
            this.addError("Invalid age");
        }
    }
    
    private isValidAge(age: number): boolean {
        return age >= 18;
    }
    
    private addError(message: string): void {
        this.errors.push(message);
    }
    
    private hasNoErrors(): boolean {
        return this.errors.length === 0;
    }
}
```

**After - Strategic inlining:**

```typescript
class UserValidator {
    private errors: string[] = [];
    
    validate(user: User): boolean {
        // Inlined simple validation checks
        if (user.username.length < 3) {
            this.errors.push("Invalid username");
        }
        
        if (!user.email.includes("@")) {
            this.errors.push("Invalid email");
        }
        
        if (user.age < 18) {
            this.errors.push("Invalid age");
        }
        
        return this.errors.length === 0;
    }
}
```

**Key Points:**

- Reduced from 10 methods to 1
- Logic is clearer and easier to follow
- No loss of functionality
- Less indirection makes debugging easier
- If validation rules become complex later, Extract Method can be reapplied

### Documentation Impact

When inlining methods:

- **Method-level documentation** may need to move to the call site or become inline comments
- **API documentation** must be updated if public methods are removed
- **Code comments** explaining the method's purpose should be preserved at the inline location

**Example:**

Before:

```java
/**
 * Calculates the customer's loyalty tier based on their purchase history.
 * Premium tier: > $10,000 lifetime value
 * Standard tier: $1,000 - $10,000
 * Basic tier: < $1,000
 */
private String calculateLoyaltyTier(double lifetimeValue) {
    if (lifetimeValue > 10000) return "Premium";
    if (lifetimeValue >= 1000) return "Standard";
    return "Basic";
}
```

After inlining, preserve the documentation:

```java
public String getCustomerTier() {
    // Loyalty tier based on lifetime value:
    // Premium: > $10,000, Standard: $1,000-$10,000, Basic: < $1,000
    if (customer.getLifetimeValue() > 10000) return "Premium";
    if (customer.getLifetimeValue() >= 1000) return "Standard";
    return "Basic";
}
```

### Anti-Pattern: Over-Inlining

Excessive inlining creates its own problems:

- **Long methods**: Methods become difficult to understand and test
- **Code duplication**: If the logic appears in multiple places, you've created maintenance burden
- **Loss of abstraction**: Meaningful concepts become buried in implementation details
- **Reduced reusability**: Code that could be shared is duplicated

**Example of over-inlining:**

```python
# Over-inlined - hard to understand
def process_order(order):
    if order.items:
        total = sum(item.price * item.quantity for item in order.items)
        if total > 1000:
            discount = 0.15
        elif total > 500:
            discount = 0.10
        else:
            discount = 0.05
        final_total = total * (1 - discount)
        
        if order.shipping_address.country == "US":
            if order.weight < 5:
                shipping = 5.00
            else:
                shipping = 5.00 + (order.weight - 5) * 1.50
        else:
            shipping = 25.00 + order.weight * 2.00
            
        grand_total = final_total + shipping
        
        if order.customer.loyalty_points > 1000:
            grand_total *= 0.95
            
        # ... more logic continues
```

**Better - balanced extraction:**

```python
def process_order(order):
    if not order.items:
        return 0
    
    subtotal = calculate_subtotal(order)
    discount = calculate_discount(subtotal)
    shipping = calculate_shipping(order)
    loyalty_adjustment = apply_loyalty_discount(order.customer, subtotal)
    
    return subtotal - discount + shipping - loyalty_adjustment
```

**Conclusion**

Inline Method is a valuable refactoring technique for simplifying code by removing unnecessary abstraction layers. It's most effective when applied to trivial methods that add complexity without meaningful benefits. However, it should be used judiciously—over-inlining can create long, complex methods that are difficult to maintain.

The key is finding the right balance between abstraction and simplicity. Methods should exist when they provide meaningful encapsulation, improve readability, or enable reuse. When they don't serve these purposes, inlining may be the right choice.

**Next Steps:**

- Review your codebase for trivial methods that could be inlined
- Practice using your IDE's automated inline refactoring tools
- Combine Inline Method with Extract Method to reorganize code structure
- Consider reading about related refactorings: Replace Temp with Query, Remove Middle Man, and Collapse Hierarchy

---

## Replace Conditional with Polymorphism

Replace Conditional with Polymorphism is a refactoring technique that eliminates complex conditional logic (if/else or switch statements) by distributing behavior across a class hierarchy. Instead of using conditionals to determine which code path to execute based on an object's type or state, each type gets its own class with its own implementation of the behavior.

### When to Apply This Refactoring

This refactoring is most valuable when you encounter:

- Repeated type-checking conditionals scattered across multiple methods
- Switch statements or if/else chains that check the same type field repeatedly
- Conditionals that grow longer as new types are added to the system
- Logic where each branch performs conceptually the same operation but with different implementations

[Inference] This refactoring typically improves maintainability when you have three or more conditional branches that represent distinct type-based behaviors.

### The Problem Pattern

Conditional logic based on type codes creates several maintenance challenges:

- **Duplication**: The same type-checking logic appears in multiple locations
- **Fragility**: Adding new types requires finding and modifying all related conditionals
- **Complexity**: Long conditional chains become difficult to understand and test
- **Violation of Open/Closed Principle**: The code must be modified rather than extended when adding new types

**Example**

```java
class Employee {
    private String type;
    private double salary;
    private double commission;
    private double bonus;
    
    public Employee(String type, double salary) {
        this.type = type;
        this.salary = salary;
    }
    
    public double calculatePay() {
        if (type.equals("ENGINEER")) {
            return salary;
        } else if (type.equals("SALESMAN")) {
            return salary + commission;
        } else if (type.equals("MANAGER")) {
            return salary + bonus;
        }
        throw new IllegalArgumentException("Invalid employee type");
    }
    
    public String getDescription() {
        if (type.equals("ENGINEER")) {
            return "Software Engineer";
        } else if (type.equals("SALESMAN")) {
            return "Sales Representative";
        } else if (type.equals("MANAGER")) {
            return "Department Manager";
        }
        throw new IllegalArgumentException("Invalid employee type");
    }
}
```

### Step-by-Step Refactoring Process

**1. Create the Base Class or Interface**

Define an abstract class or interface that declares the methods currently containing conditional logic.

```java
abstract class Employee {
    protected double salary;
    
    public Employee(double salary) {
        this.salary = salary;
    }
    
    public abstract double calculatePay();
    public abstract String getDescription();
}
```

**2. Create Subclasses for Each Conditional Branch**

Each branch of the original conditional becomes a concrete subclass.

```java
class Engineer extends Employee {
    public Engineer(double salary) {
        super(salary);
    }
    
    @Override
    public double calculatePay() {
        return salary;
    }
    
    @Override
    public String getDescription() {
        return "Software Engineer";
    }
}

class Salesman extends Employee {
    private double commission;
    
    public Salesman(double salary, double commission) {
        super(salary);
        this.commission = commission;
    }
    
    @Override
    public double calculatePay() {
        return salary + commission;
    }
    
    @Override
    public String getDescription() {
        return "Sales Representative";
    }
}

class Manager extends Employee {
    private double bonus;
    
    public Manager(double salary, double bonus) {
        super(salary);
        this.bonus = bonus;
    }
    
    @Override
    public double calculatePay() {
        return salary + bonus;
    }
    
    @Override
    public String getDescription() {
        return "Department Manager";
    }
}
```

**3. Replace Object Creation**

Update code that creates objects to instantiate the appropriate subclass instead of setting a type field.

```java
// Before
Employee emp = new Employee("ENGINEER", 80000);

// After
Employee emp = new Engineer(80000);
```

**4. Remove Conditionals**

Once all object creation uses the new classes, the conditional logic can be removed. The polymorphic method calls replace the conditionals.

```java
// Client code - no conditionals needed
Employee engineer = new Engineer(80000);
Employee salesman = new Salesman(60000, 15000);
Employee manager = new Manager(90000, 20000);

System.out.println(engineer.calculatePay());  // 80000.0
System.out.println(salesman.calculatePay());  // 75000.0
System.out.println(manager.calculatePay());   // 110000.0
```

### Handling State-Based Conditionals

When conditionals check object state rather than type, use the State pattern variant of this refactoring.

**Example**

```java
// Before: State-based conditional
class Order {
    private String state;
    
    public void processNext() {
        if (state.equals("NEW")) {
            // Validate order
            state = "VALIDATED";
        } else if (state.equals("VALIDATED")) {
            // Process payment
            state = "PAID";
        } else if (state.equals("PAID")) {
            // Ship order
            state = "SHIPPED";
        }
    }
}

// After: State pattern with polymorphism
interface OrderState {
    OrderState processNext(Order order);
}

class NewOrderState implements OrderState {
    @Override
    public OrderState processNext(Order order) {
        // Validate order
        return new ValidatedOrderState();
    }
}

class ValidatedOrderState implements OrderState {
    @Override
    public OrderState processNext(Order order) {
        // Process payment
        return new PaidOrderState();
    }
}

class PaidOrderState implements OrderState {
    @Override
    public OrderState processNext(Order order) {
        // Ship order
        return new ShippedOrderState();
    }
}

class Order {
    private OrderState state;
    
    public Order() {
        this.state = new NewOrderState();
    }
    
    public void processNext() {
        state = state.processNext(this);
    }
}
```

### Using Factory Pattern for Object Creation

A Factory can encapsulate the logic for creating the appropriate subclass, especially when creation depends on configuration or external data.

**Example**

```java
class EmployeeFactory {
    public static Employee createEmployee(String type, double salary, double extra) {
        switch (type) {
            case "ENGINEER":
                return new Engineer(salary);
            case "SALESMAN":
                return new Salesman(salary, extra);
            case "MANAGER":
                return new Manager(salary, extra);
            default:
                throw new IllegalArgumentException("Unknown employee type: " + type);
        }
    }
}

// Usage
Employee emp = EmployeeFactory.createEmployee("SALESMAN", 60000, 15000);
double pay = emp.calculatePay();  // No conditionals in client code
```

### Combining with Strategy Pattern

When the behavior varies but doesn't require different data structures, Strategy pattern offers a lighter alternative.

**Example**

```java
interface PaymentStrategy {
    double calculate(double salary, double extra);
}

class SalaryOnlyStrategy implements PaymentStrategy {
    @Override
    public double calculate(double salary, double extra) {
        return salary;
    }
}

class SalaryPlusCommissionStrategy implements PaymentStrategy {
    @Override
    public double calculate(double salary, double extra) {
        return salary + extra;
    }
}

class Employee {
    private double salary;
    private double extra;
    private PaymentStrategy paymentStrategy;
    
    public Employee(double salary, double extra, PaymentStrategy strategy) {
        this.salary = salary;
        this.extra = extra;
        this.paymentStrategy = strategy;
    }
    
    public double calculatePay() {
        return paymentStrategy.calculate(salary, extra);
    }
}
```

### Handling Null Objects

The Null Object pattern eliminates null-checking conditionals by providing a polymorphic "do-nothing" implementation.

**Example**

```java
// Before
public void processCustomer(Customer customer) {
    if (customer != null) {
        customer.sendWelcomeEmail();
        customer.applyDiscount();
    }
}

// After
interface Customer {
    void sendWelcomeEmail();
    void applyDiscount();
}

class RealCustomer implements Customer {
    @Override
    public void sendWelcomeEmail() {
        // Send actual email
    }
    
    @Override
    public void applyDiscount() {
        // Apply actual discount
    }
}

class NullCustomer implements Customer {
    @Override
    public void sendWelcomeEmail() {
        // Do nothing
    }
    
    @Override
    public void applyDiscount() {
        // Do nothing
    }
}

public void processCustomer(Customer customer) {
    customer.sendWelcomeEmail();
    customer.applyDiscount();
}
```

### Modern Language Features

Many modern languages provide features that support polymorphic behavior without explicit class hierarchies.

**Pattern Matching (Java 17+)**

```java
sealed interface Shape permits Circle, Rectangle, Triangle {}

record Circle(double radius) implements Shape {}
record Rectangle(double width, double height) implements Shape {}
record Triangle(double base, double height) implements Shape {}

double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> Math.PI * c.radius() * c.radius();
        case Rectangle r -> r.width() * r.height();
        case Triangle t -> 0.5 * t.base() * t.height();
    };
}
```

[Inference] Pattern matching provides compile-time exhaustiveness checking, which may reduce runtime errors compared to traditional polymorphism.

**Function Objects (JavaScript/TypeScript)**

```javascript
const paymentCalculators = {
    ENGINEER: (salary) => salary,
    SALESMAN: (salary, commission) => salary + commission,
    MANAGER: (salary, bonus) => salary + bonus
};

function calculatePay(type, salary, extra = 0) {
    return paymentCalculators[type](salary, extra);
}
```

### Trade-offs and Considerations

**Advantages:**

- **Extensibility**: New types can be added without modifying existing code
- **Clarity**: Each class has a single, focused responsibility
- **Testability**: Individual behaviors can be tested in isolation
- **Type Safety**: The compiler can verify that all required methods are implemented

**Disadvantages:**

- **Class Proliferation**: Creates more classes in the codebase
- **Indirection**: Behavior is distributed across multiple files
- **Overkill for Simple Cases**: Two-branch conditionals may not justify the added complexity

[Inference] This refactoring provides the most value when you expect the number of types or behaviors to grow over time.

### When Not to Apply

Avoid this refactoring when:

- The conditional has only two branches and is unlikely to grow
- The conditional logic is genuinely temporary or experimental
- The branches share significant common logic that would be duplicated across subclasses
- The conditional checks multiple orthogonal conditions rather than a single type
- Performance is critical and virtual method dispatch overhead matters

**Example of inappropriate use:**

```java
// Simple validation - conditional is clearer
if (age < 0) {
    throw new IllegalArgumentException("Age cannot be negative");
}

// Don't create polymorphic classes for this
```

### Testing Strategy

After applying this refactoring, testing becomes more modular:

```java
class EngineerTest {
    @Test
    void calculatePay_returnsBaseSalary() {
        Engineer engineer = new Engineer(80000);
        assertEquals(80000, engineer.calculatePay(), 0.01);
    }
}

class SalesmanTest {
    @Test
    void calculatePay_addsSalaryAndCommission() {
        Salesman salesman = new Salesman(60000, 15000);
        assertEquals(75000, salesman.calculatePay(), 0.01);
    }
}
```

**Note**: [Inference] Individual class tests may be simpler to write and maintain than testing all branches of a complex conditional, though this depends on the specific testing framework and codebase structure.

### Real-World Application Example

**Example**: Payment processing system

```java
// Before: Conditional-heavy payment processing
class PaymentProcessor {
    public void processPayment(Payment payment) {
        if (payment.getType().equals("CREDIT_CARD")) {
            // Validate card number
            // Check CVV
            // Process with payment gateway
            // Send receipt
        } else if (payment.getType().equals("PAYPAL")) {
            // Redirect to PayPal
            // Wait for callback
            // Verify transaction
            // Send receipt
        } else if (payment.getType().equals("BANK_TRANSFER")) {
            // Generate transfer instructions
            // Wait for bank confirmation
            // Verify deposit
            // Send receipt
        }
    }
}

// After: Polymorphic payment methods
interface PaymentMethod {
    void process();
    void validate();
    void sendReceipt();
}

class CreditCardPayment implements PaymentMethod {
    private String cardNumber;
    private String cvv;
    
    @Override
    public void process() {
        validate();
        // Process with payment gateway
        sendReceipt();
    }
    
    @Override
    public void validate() {
        // Validate card number and CVV
    }
    
    @Override
    public void sendReceipt() {
        // Send credit card receipt
    }
}

class PayPalPayment implements PaymentMethod {
    private String email;
    
    @Override
    public void process() {
        // Redirect to PayPal and handle callback
        sendReceipt();
    }
    
    @Override
    public void validate() {
        // Validate PayPal email
    }
    
    @Override
    public void sendReceipt() {
        // Send PayPal receipt
    }
}

class PaymentProcessor {
    public void processPayment(PaymentMethod payment) {
        payment.process();  // No conditionals needed
    }
}
```

### Migration Strategy for Large Codebases

When refactoring existing systems with extensive conditional logic:

1. **Identify all locations** where type-checking conditionals appear
2. **Create the class hierarchy** starting with the base abstraction
3. **Implement one subclass** and update one usage location
4. **Test thoroughly** before proceeding
5. **Incrementally replace** other conditional locations
6. **Deprecate the type field** once all conditionals are eliminated
7. **Remove deprecated code** after a transition period

[Inference] Incremental migration may reduce risk in production systems compared to attempting to refactor all conditionals simultaneously.

**Conclusion**

Replace Conditional with Polymorphism transforms type-checking logic into object-oriented structure. This refactoring distributes behavior across specialized classes, making code more extensible and maintainable. The technique is most valuable when dealing with multiple type-dependent operations that are likely to grow over time. While it introduces additional classes, the benefits of improved modularity and reduced coupling typically outweigh this cost in systems where type-based behavior is a central concern.

**Note**: The effectiveness of this refactoring depends on the specific context, code structure, and team familiarity with object-oriented principles. Results may vary based on these factors.

---

## Introduce Parameter Object

The Introduce Parameter Object refactoring technique replaces multiple related parameters with a single object that encapsulates them. When a method accepts numerous parameters that naturally belong together, grouping them into a cohesive object typically improves code readability and maintainability.

### What Is Introduce Parameter Object?

This refactoring addresses the problem of long parameter lists by creating a dedicated class or structure to hold related parameters. Instead of passing individual values, you pass a single object containing those values.

**Key Points:**

- Reduces the number of parameters in method signatures
- Groups related data into a cohesive unit
- Makes parameter relationships explicit
- Simplifies method calls when the same parameter groups appear repeatedly
- Can evolve into a more meaningful domain object over time

### When to Apply This Refactoring

Consider introducing a parameter object when:

- A method has more than 3-4 parameters
- The same group of parameters appears in multiple methods
- Parameters are logically related (e.g., coordinates, date ranges, configuration settings)
- You find yourself passing the same values together repeatedly
- Adding new related parameters would make the signature even longer

### Benefits

**Improved Readability** Method signatures become shorter and more descriptive. A well-named parameter object communicates intent better than a list of individual parameters.

**Reduced Coupling** [Inference: based on typical refactoring outcomes] Changes to parameter details only affect the parameter object class, not every method signature that uses those parameters. However, actual coupling reduction depends on implementation details.

**Enhanced Maintainability** Adding or modifying related parameters requires changes in fewer places. You update the parameter object class rather than every method signature.

**Better Encapsulation** Related data stays together, and you can add validation or behavior to the parameter object itself.

### Step-by-Step Process

### 1. Identify Parameter Groups

Examine your methods to find parameters that are consistently passed together:

```java
// Before: Multiple related parameters
public void createBooking(String customerName, String customerEmail, 
                         String customerPhone, LocalDate startDate, 
                         LocalDate endDate, int numberOfGuests) {
    // booking logic
}
```

### 2. Create the Parameter Object Class

Design a class that encapsulates the related parameters:

```java
public class BookingDetails {
    private final String customerName;
    private final String customerEmail;
    private final String customerPhone;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final int numberOfGuests;
    
    public BookingDetails(String customerName, String customerEmail,
                         String customerPhone, LocalDate startDate,
                         LocalDate endDate, int numberOfGuests) {
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.startDate = startDate;
        this.endDate = endDate;
        this.numberOfGuests = numberOfGuests;
    }
    
    // Getters
    public String getCustomerName() { return customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public String getCustomerPhone() { return customerPhone; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getEndDate() { return endDate; }
    public int getNumberOfGuests() { return numberOfGuests; }
}
```

### 3. Update Method Signatures

Replace the individual parameters with the parameter object:

```java
// After: Single parameter object
public void createBooking(BookingDetails details) {
    // Access values through the object
    String name = details.getCustomerName();
    String email = details.getCustomerEmail();
    // ... rest of booking logic
}
```

### 4. Update All Callers

Modify code that calls the method to create and pass the parameter object:

```java
// Before
bookingService.createBooking("John Doe", "john@example.com", 
    "555-0100", startDate, endDate, 2);

// After
BookingDetails details = new BookingDetails(
    "John Doe", "john@example.com", "555-0100",
    startDate, endDate, 2
);
bookingService.createBooking(details);
```

### Complete Example

**Example:**

Here's a complete before-and-after comparison for a graphics rendering system:

```java
// BEFORE: Long parameter list
public class GraphicsRenderer {
    public void drawRectangle(int x, int y, int width, int height,
                            String fillColor, String borderColor,
                            int borderWidth, double opacity) {
        // Drawing logic using individual parameters
        System.out.println("Drawing rectangle at (" + x + "," + y + ")");
        System.out.println("Size: " + width + "x" + height);
        System.out.println("Fill: " + fillColor + ", Border: " + borderColor);
        System.out.println("Border width: " + borderWidth + ", Opacity: " + opacity);
    }
    
    public void drawCircle(int centerX, int centerY, int radius,
                          String fillColor, String borderColor,
                          int borderWidth, double opacity) {
        // Drawing logic with similar parameters
        System.out.println("Drawing circle at (" + centerX + "," + centerY + ")");
        System.out.println("Radius: " + radius);
        System.out.println("Fill: " + fillColor + ", Border: " + borderColor);
        System.out.println("Border width: " + borderWidth + ", Opacity: " + opacity);
    }
}

// Usage
renderer.drawRectangle(10, 20, 100, 50, "#FF0000", "#000000", 2, 0.8);
renderer.drawCircle(150, 100, 30, "#00FF00", "#000000", 2, 0.8);
```

```java
// AFTER: With parameter objects
public class Position {
    private final int x;
    private final int y;
    
    public Position(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public int getX() { return x; }
    public int getY() { return y; }
}

public class DrawingStyle {
    private final String fillColor;
    private final String borderColor;
    private final int borderWidth;
    private final double opacity;
    
    public DrawingStyle(String fillColor, String borderColor,
                       int borderWidth, double opacity) {
        this.fillColor = fillColor;
        this.borderColor = borderColor;
        this.borderWidth = borderWidth;
        this.opacity = opacity;
    }
    
    public String getFillColor() { return fillColor; }
    public String getBorderColor() { return borderColor; }
    public int getBorderWidth() { return borderWidth; }
    public double getOpacity() { return opacity; }
}

public class GraphicsRenderer {
    public void drawRectangle(Position position, int width, int height,
                            DrawingStyle style) {
        System.out.println("Drawing rectangle at (" + 
            position.getX() + "," + position.getY() + ")");
        System.out.println("Size: " + width + "x" + height);
        System.out.println("Fill: " + style.getFillColor() + 
            ", Border: " + style.getBorderColor());
        System.out.println("Border width: " + style.getBorderWidth() + 
            ", Opacity: " + style.getOpacity());
    }
    
    public void drawCircle(Position center, int radius, DrawingStyle style) {
        System.out.println("Drawing circle at (" + 
            center.getX() + "," + center.getY() + ")");
        System.out.println("Radius: " + radius);
        System.out.println("Fill: " + style.getFillColor() + 
            ", Border: " + style.getBorderColor());
        System.out.println("Border width: " + style.getBorderWidth() + 
            ", Opacity: " + style.getOpacity());
    }
}

// Usage - more expressive and reusable
Position topLeft = new Position(10, 20);
Position center = new Position(150, 100);
DrawingStyle redStyle = new DrawingStyle("#FF0000", "#000000", 2, 0.8);
DrawingStyle greenStyle = new DrawingStyle("#00FF00", "#000000", 2, 0.8);

renderer.drawRectangle(topLeft, 100, 50, redStyle);
renderer.drawCircle(center, 30, greenStyle);

// Reusing styles becomes trivial
renderer.drawRectangle(new Position(200, 150), 75, 75, redStyle);
```

**Output:**

```
Drawing rectangle at (10,20)
Size: 100x50
Fill: #FF0000, Border: #000000
Border width: 2, Opacity: 0.8
Drawing circle at (150,100)
Radius: 30
Fill: #00FF00, Border: #000000
Border width: 2, Opacity: 0.8
Drawing rectangle at (200,150)
Size: 75x75
Fill: #FF0000, Border: #000000
Border width: 2, Opacity: 0.8
```

### Advanced Considerations

### Adding Behavior to Parameter Objects

Parameter objects can evolve beyond simple data containers. You can add methods that perform operations on the encapsulated data:

```java
public class DateRange {
    private final LocalDate startDate;
    private final LocalDate endDate;
    
    public DateRange(LocalDate startDate, LocalDate endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    
    public long getDurationInDays() {
        return ChronoUnit.DAYS.between(startDate, endDate);
    }
    
    public boolean includes(LocalDate date) {
        return !date.isBefore(startDate) && !date.isAfter(endDate);
    }
    
    public boolean overlaps(DateRange other) {
        return !this.endDate.isBefore(other.startDate) && 
               !other.endDate.isBefore(this.startDate);
    }
    
    // Getters
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getEndDate() { return endDate; }
}
```

### Validation in Parameter Objects

Encapsulating validation logic in the parameter object's constructor can help maintain invariants:

```java
public class PricingDetails {
    private final BigDecimal basePrice;
    private final BigDecimal discountPercentage;
    private final String currency;
    
    public PricingDetails(BigDecimal basePrice, BigDecimal discountPercentage,
                         String currency) {
        if (basePrice.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Base price cannot be negative");
        }
        if (discountPercentage.compareTo(BigDecimal.ZERO) < 0 || 
            discountPercentage.compareTo(new BigDecimal("100")) > 0) {
            throw new IllegalArgumentException(
                "Discount must be between 0 and 100");
        }
        if (currency == null || currency.trim().isEmpty()) {
            throw new IllegalArgumentException("Currency is required");
        }
        
        this.basePrice = basePrice;
        this.discountPercentage = discountPercentage;
        this.currency = currency;
    }
    
    public BigDecimal calculateFinalPrice() {
        BigDecimal discount = basePrice.multiply(discountPercentage)
            .divide(new BigDecimal("100"));
        return basePrice.subtract(discount);
    }
    
    // Getters
    public BigDecimal getBasePrice() { return basePrice; }
    public BigDecimal getDiscountPercentage() { return discountPercentage; }
    public String getCurrency() { return currency; }
}
```

### Builder Pattern Integration

For parameter objects with many fields or optional parameters, combining with the Builder pattern can improve usability:

```java
public class SearchCriteria {
    private final String keyword;
    private final String category;
    private final BigDecimal minPrice;
    private final BigDecimal maxPrice;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final int maxResults;
    
    private SearchCriteria(Builder builder) {
        this.keyword = builder.keyword;
        this.category = builder.category;
        this.minPrice = builder.minPrice;
        this.maxPrice = builder.maxPrice;
        this.startDate = builder.startDate;
        this.endDate = builder.endDate;
        this.maxResults = builder.maxResults;
    }
    
    public static class Builder {
        private String keyword;
        private String category;
        private BigDecimal minPrice;
        private BigDecimal maxPrice;
        private LocalDate startDate;
        private LocalDate endDate;
        private int maxResults = 10; // default value
        
        public Builder keyword(String keyword) {
            this.keyword = keyword;
            return this;
        }
        
        public Builder category(String category) {
            this.category = category;
            return this;
        }
        
        public Builder priceRange(BigDecimal min, BigDecimal max) {
            this.minPrice = min;
            this.maxPrice = max;
            return this;
        }
        
        public Builder dateRange(LocalDate start, LocalDate end) {
            this.startDate = start;
            this.endDate = end;
            return this;
        }
        
        public Builder maxResults(int max) {
            this.maxResults = max;
            return this;
        }
        
        public SearchCriteria build() {
            return new SearchCriteria(this);
        }
    }
    
    // Getters
    public String getKeyword() { return keyword; }
    public String getCategory() { return category; }
    public BigDecimal getMinPrice() { return minPrice; }
    public BigDecimal getMaxPrice() { return maxPrice; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getEndDate() { return endDate; }
    public int getMaxResults() { return maxResults; }
}

// Usage
SearchCriteria criteria = new SearchCriteria.Builder()
    .keyword("laptop")
    .category("electronics")
    .priceRange(new BigDecimal("500"), new BigDecimal("1500"))
    .maxResults(20)
    .build();

searchService.findProducts(criteria);
```

### Potential Drawbacks

### Increased Indirection

Parameter objects add a layer of indirection. Instead of directly accessing parameters, you must call getter methods. This can make simple operations slightly more verbose.

### Over-Engineering Risk

[Inference] Creating parameter objects for every method with multiple parameters may lead to unnecessary complexity. Use this refactoring when parameters are genuinely related and appear together frequently, not just because a method has several parameters.

### Object Creation Overhead

Each method call requires creating a new parameter object instance. For performance-critical code paths called millions of times, this overhead might be measurable, though modern JVMs typically optimize this well. [Inference based on typical JVM behavior; actual performance depends on specific implementation and usage patterns]

### Comparison with Related Techniques

### Introduce Parameter Object vs. Preserve Whole Object

**Preserve Whole Object** passes an existing object rather than extracting individual values from it. **Introduce Parameter Object** creates a new object specifically to group parameters.

Use Preserve Whole Object when:

- You're already extracting multiple values from an object to pass as parameters
- The source object is a meaningful domain entity

Use Introduce Parameter Object when:

- Parameters don't come from a single existing object
- You're grouping primitives or values from multiple sources

### Introduce Parameter Object vs. Extract Class

Both techniques create new classes to organize data. **Extract Class** breaks up an existing class that has too many responsibilities. **Introduce Parameter Object** groups method parameters.

The parameter object you create might later be extracted from a class that's accumulating too much functionality, showing how refactorings can work together.

### Language-Specific Considerations

### Java

Modern Java (14+) offers records, which are ideal for simple parameter objects:

```java
public record CustomerInfo(String name, String email, String phone) {}

// Usage
public void processOrder(CustomerInfo customer, OrderDetails order) {
    System.out.println("Processing order for " + customer.name());
}
```

### Python

Named tuples or dataclasses work well for parameter objects:

```python
from dataclasses import dataclass
from datetime import date

@dataclass
class BookingDetails:
    customer_name: str
    customer_email: str
    start_date: date
    end_date: date
    num_guests: int

def create_booking(details: BookingDetails):
    print(f"Booking for {details.customer_name}")
    print(f"From {details.start_date} to {details.end_date}")
```

### C#

C# records (C# 9+) or classes with init-only properties provide similar functionality:

```csharp
public record DrawingStyle(
    string FillColor,
    string BorderColor,
    int BorderWidth,
    double Opacity
);

public void DrawRectangle(Position position, Size size, DrawingStyle style)
{
    Console.WriteLine($"Drawing with {style.FillColor}");
}
```

### JavaScript/TypeScript

TypeScript interfaces or classes define parameter object shapes:

```typescript
interface SearchCriteria {
    keyword: string;
    category?: string;
    minPrice?: number;
    maxPrice?: number;
}

function searchProducts(criteria: SearchCriteria): Product[] {
    console.log(`Searching for ${criteria.keyword}`);
    // search logic
}
```

**Conclusion:**

Introduce Parameter Object is a valuable refactoring technique that improves code organization when multiple related parameters consistently appear together. By creating dedicated classes to encapsulate these parameters, you make method signatures clearer, enable better code reuse, and create opportunities for adding related behavior. Apply this refactoring judiciously when parameters are genuinely related, and consider evolving these objects into richer domain concepts as your understanding of the problem deepens.

**Next Steps:**

- Review your codebase for methods with 4+ parameters
- Identify parameter groups that appear in multiple methods
- Start with the most frequently used parameter combinations
- Consider adding validation and behavior to your parameter objects
- Explore combining this refactoring with the Builder pattern for complex objects

---

## Preserve Whole Object

Preserve Whole Object is a refactoring technique that involves passing an entire object as a parameter instead of extracting and passing individual data values from that object. This refactoring reduces parameter lists, improves code clarity, and creates more maintainable relationships between objects.

### Problem Context

Code often exhibits a pattern where multiple values are extracted from an object and passed individually to a method:

**Example**

```java
// Multiple parameters extracted from one object
int low = dayRange.getLow();
int high = dayRange.getHigh();
boolean withinPlan = plan.withinRange(low, high);
```

This approach has several drawbacks:

- Long parameter lists that are difficult to read and maintain
- Changes to the source object require updating all call sites
- The relationship between parameters and their source object becomes obscured
- Duplication of extraction logic across multiple call sites
- Method signature changes when additional values from the same object are needed

### Solution

Replace individual parameter extractions with a single parameter representing the whole object:

**Example**

```java
// Pass the entire object
boolean withinPlan = plan.withinRange(dayRange);
```

The receiving method accesses needed values directly from the passed object:

**Example**

```java
// Before refactoring
public boolean withinRange(int low, int high) {
    return (low >= this.low && high <= this.high);
}

// After refactoring
public boolean withinRange(DateRange range) {
    return (range.getLow() >= this.low && range.getHigh() <= this.high);
}
```

### When to Apply

**Appropriate Scenarios**

Apply Preserve Whole Object when:

- Multiple values come from the same source object
- The receiving method conceptually operates on the entity represented by the source object
- Parameter lists exceed 3-4 parameters from the same source
- The same extraction pattern appears in multiple locations
- Future requirements [Inference: are likely to] need additional values from the same object

**When to Avoid**

Do not apply this refactoring when:

- Passing the whole object creates unwanted dependencies between classes
- Only one or two primitive values are needed and the semantic relationship is clear
- The receiving object should not know about the source object's structure
- The goal is to maintain strict separation of concerns or architectural boundaries
- The source object is large and passing it incurs significant performance costs (though this is rare in modern systems, [Unverified: specific performance impact varies by language and runtime])

### Step-by-Step Refactoring Process

**Step 1: Identify the Pattern**

Find methods that receive multiple parameters extracted from the same object:

**Example**

```python
# Before: Multiple parameters from customer object
def calculate_discount(customer_type, years_member, total_purchases):
    if customer_type == "PREMIUM":
        if years_member > 5:
            return total_purchases * 0.15
        return total_purchases * 0.10
    return total_purchases * 0.05

# Usage
discount = calculate_discount(
    customer.get_type(),
    customer.get_years_member(),
    customer.get_total_purchases()
)
```

**Step 2: Add New Parameter for Whole Object**

Add a new parameter for the whole object while keeping existing parameters (temporary duplication):

**Example**

```python
def calculate_discount(customer, customer_type, years_member, total_purchases):
    if customer_type == "PREMIUM":
        if years_member > 5:
            return total_purchases * 0.15
        return total_purchases * 0.10
    return total_purchases * 0.05
```

**Step 3: Replace Parameter Usage**

Update the method body to use the whole object instead of individual parameters:

**Example**

```python
def calculate_discount(customer, customer_type, years_member, total_purchases):
    if customer.get_type() == "PREMIUM":
        if customer.get_years_member() > 5:
            return customer.get_total_purchases() * 0.15
        return customer.get_total_purchases() * 0.10
    return customer.get_total_purchases() * 0.05
```

**Step 4: Update All Call Sites**

Modify all callers to pass the whole object:

**Example**

```python
# Before
discount = calculate_discount(
    customer,
    customer.get_type(),
    customer.get_years_member(),
    customer.get_total_purchases()
)

# After
discount = calculate_discount(customer)
```

**Step 5: Remove Old Parameters**

Once all call sites are updated, remove the now-unused individual parameters:

**Example**

```python
def calculate_discount(customer):
    if customer.get_type() == "PREMIUM":
        if customer.get_years_member() > 5:
            return customer.get_total_purchases() * 0.15
        return customer.get_total_purchases() * 0.10
    return customer.get_total_purchases() * 0.05
```

### Real-World Examples

**Temperature Analysis**

**Example**

```javascript
// Before: Extracting multiple values from reading
class TemperatureAlert {
    checkAlert(temperature, humidity, timestamp) {
        if (temperature > 30 && humidity > 80) {
            return `High heat index at ${timestamp}`;
        }
        return null;
    }
}

// Usage
const alert = alertSystem.checkAlert(
    reading.getTemperature(),
    reading.getHumidity(),
    reading.getTimestamp()
);

// After: Passing whole reading object
class TemperatureAlert {
    checkAlert(reading) {
        if (reading.getTemperature() > 30 && reading.getHumidity() > 80) {
            return `High heat index at ${reading.getTimestamp()}`;
        }
        return null;
    }
}

// Usage
const alert = alertSystem.checkAlert(reading);
```

**Order Processing**

**Example**

```csharp
// Before: Multiple parameters from Order
public class ShippingCalculator
{
    public decimal CalculateShipping(
        decimal weight,
        string destination,
        bool isPriority,
        decimal orderValue)
    {
        decimal baseRate = weight * 0.5m;
        
        if (destination == "International")
        {
            baseRate *= 2.5m;
        }
        
        if (isPriority)
        {
            baseRate *= 1.5m;
        }
        
        // Free shipping for orders over $100
        if (orderValue > 100)
        {
            return 0;
        }
        
        return baseRate;
    }
}

// Usage
decimal shipping = calculator.CalculateShipping(
    order.GetWeight(),
    order.GetDestination(),
    order.IsPriority(),
    order.GetValue()
);

// After: Passing whole Order
public class ShippingCalculator
{
    public decimal CalculateShipping(Order order)
    {
        decimal baseRate = order.GetWeight() * 0.5m;
        
        if (order.GetDestination() == "International")
        {
            baseRate *= 2.5m;
        }
        
        if (order.IsPriority())
        {
            baseRate *= 1.5m;
        }
        
        // Free shipping for orders over $100
        if (order.GetValue() > 100)
        {
            return 0;
        }
        
        return baseRate;
    }
}

// Usage
decimal shipping = calculator.CalculateShipping(order);
```

### Benefits

**Reduced Parameter Lists**

Long parameter lists are difficult to understand and error-prone. Preserving whole objects creates cleaner method signatures that are easier to read and less likely to have parameter ordering mistakes.

**Better Change Resilience**

When the method needs additional data from the source object, no signature change is required. The method can simply access the new values from the object it already receives.

**Example**

```ruby
# Before: Adding timezone requires signature change
def format_appointment(date, time, duration)
  # Implementation
end

# New requirement needs timezone
def format_appointment(date, time, duration, timezone)
  # Implementation - all callers must update
end

# After: No signature change needed
def format_appointment(appointment)
  # Can now access appointment.timezone without changing signature
end
```

**Clearer Intent**

Passing a whole object makes the conceptual relationship more explicit. The method signature communicates that it operates on an entire entity rather than arbitrary values.

**Elimination of Duplication**

Extraction logic appears once in the method instead of being duplicated at every call site.

**Simplified Testing**

Tests become easier to write because test data can be encapsulated in objects rather than managed as multiple separate values:

**Example**

```python
# Before: Managing multiple test values
def test_discount_calculation():
    result = calculate_discount("PREMIUM", 6, 1000.0)
    assert result == 150.0
    
    result = calculate_discount("STANDARD", 2, 1000.0)
    assert result == 50.0

# After: Using test objects
def test_discount_calculation():
    premium_customer = Customer(type="PREMIUM", years=6, purchases=1000.0)
    result = calculate_discount(premium_customer)
    assert result == 150.0
    
    standard_customer = Customer(type="STANDARD", years=2, purchases=1000.0)
    result = calculate_discount(standard_customer)
    assert result == 50.0
```

### Dependency Considerations

**Creating New Dependencies**

Preserve Whole Object creates a dependency from the receiving class to the source object's class. Consider whether this dependency is appropriate for your architecture:

**Example**

```java
// Before: Presentation layer doesn't depend on domain model
public class ReportFormatter {
    public String formatSummary(String name, double value, String category) {
        return String.format("%s: $%.2f (%s)", name, value, category);
    }
}

// After: Creates dependency on domain model
public class ReportFormatter {
    public String formatSummary(Transaction transaction) {
        return String.format("%s: $%.2f (%s)", 
            transaction.getName(),
            transaction.getValue(),
            transaction.getCategory()
        );
    }
}
```

[Inference: This dependency may be undesirable] if you're trying to maintain strict architectural boundaries, such as keeping presentation logic independent of domain models.

**Solution: Introduce Parameter Object**

If the dependency is problematic, create a dedicated parameter object that contains only the needed data:

**Example**

```java
// New parameter object with no business logic
public class TransactionDisplayData {
    private final String name;
    private final double value;
    private final String category;
    
    public TransactionDisplayData(String name, double value, String category) {
        this.name = name;
        this.value = value;
        this.category = category;
    }
    
    // Getters
}

public class ReportFormatter {
    public String formatSummary(TransactionDisplayData data) {
        return String.format("%s: $%.2f (%s)", 
            data.getName(),
            data.getValue(),
            data.getCategory()
        );
    }
}
```

### Combining with Other Refactorings

**Introduce Parameter Object**

When values don't come from an existing object, first use Introduce Parameter Object to create a container, then apply the same principles:

**Example**

```typescript
// Before: Unrelated parameters
function createReport(
    title: string,
    startDate: Date,
    endDate: Date,
    includeCharts: boolean,
    format: string
) {
    // Implementation
}

// Step 1: Introduce Parameter Object
interface ReportConfig {
    title: string;
    startDate: Date;
    endDate: Date;
    includeCharts: boolean;
    format: string;
}

// Step 2: Use the parameter object
function createReport(config: ReportConfig) {
    // Implementation
}
```

**Replace Temp with Query**

After preserving whole object, you [Inference: may be able to] eliminate temporary variables:

**Example**

```python
# Before
def calculate_total(order):
    quantity = order.get_quantity()
    unit_price = order.get_unit_price()
    discount = order.get_discount()
    
    subtotal = quantity * unit_price
    total = subtotal - (subtotal * discount)
    return total

# After: Using object directly
def calculate_total(order):
    subtotal = order.get_quantity() * order.get_unit_price()
    return subtotal - (subtotal * order.get_discount())

# Or even better: Move calculation to Order
class Order:
    def calculate_total(self):
        subtotal = self.quantity * self.unit_price
        return subtotal - (subtotal * self.discount)
```

**Move Method**

Sometimes preserving whole object reveals that the method should belong to the object being passed:

**Example**

```java
// After Preserve Whole Object
public class PriceCalculator {
    public double calculateFinalPrice(Product product) {
        double base = product.getBasePrice();
        double discount = product.getDiscount();
        double tax = product.getTaxRate();
        
        return (base - discount) * (1 + tax);
    }
}

// Refactor: Move to Product class
public class Product {
    public double calculateFinalPrice() {
        double base = this.basePrice;
        double discount = this.discount;
        double tax = this.taxRate;
        
        return (base - discount) * (1 + tax);
    }
}
```

### Handling Null Objects

When preserving whole objects, consider how to handle null cases:

**Example**

```javascript
// Before: Null handling with primitives
function calculateDiscount(customerType, yearsActive) {
    if (customerType === null || yearsActive === null) {
        return 0;
    }
    
    if (customerType === 'PREMIUM' && yearsActive > 5) {
        return 0.15;
    }
    return 0.05;
}

// After: Null object handling
function calculateDiscount(customer) {
    if (customer === null) {
        return 0;
    }
    
    if (customer.getType() === 'PREMIUM' && customer.getYearsActive() > 5) {
        return 0.15;
    }
    return 0.05;
}

// Better: Use Null Object pattern or default values
class NullCustomer extends Customer {
    getType() { return 'STANDARD'; }
    getYearsActive() { return 0; }
}

function calculateDiscount(customer) {
    // No null check needed if using Null Object pattern
    if (customer.getType() === 'PREMIUM' && customer.getYearsActive() > 5) {
        return 0.15;
    }
    return 0.05;
}
```

### Performance Considerations

**Object Creation Overhead**

[Unverified: In most modern languages and runtimes], passing objects has negligible performance impact compared to passing multiple primitives. However, [Inference: in performance-critical code paths with high call frequency], measure actual impact before and after refactoring.

**Unnecessary Data Transfer**

[Speculation: In distributed systems or across process boundaries], passing large objects when only a few fields are needed [Inference: might increase] serialization overhead. In such cases, consider using Data Transfer Objects (DTOs) with only required fields.

**Example**

```java
// For remote service calls, a DTO might be more appropriate
public class CustomerDTO {
    private String type;
    private int yearsActive;
    
    // Only includes data needed for this operation
    // Full Customer object might include unnecessary fields
}

public interface DiscountService {
    double calculateDiscount(CustomerDTO customer);
}
```

### IDE and Tool Support

Most modern IDEs provide automated refactoring support for Preserve Whole Object:

- **IntelliJ IDEA**: Refactor → Change Signature → Add Parameter
- **Eclipse**: Refactor → Change Method Signature
- **Visual Studio**: Refactor → Extract Method / Change Signature
- **VS Code with extensions**: Various language-specific refactoring tools

[Unverified: Specific menu paths and features vary by IDE version and language plugins installed]

These tools typically:

- Automatically update all call sites
- Maintain type safety during the refactoring
- Allow preview of changes before applying
- Support undo operations

### Testing Strategy

When performing this refactoring, maintain test coverage throughout:

**Example**

```python
# Original tests still pass during refactoring
def test_discount_with_individual_params():
    result = calculate_discount("PREMIUM", 6, 1000.0)
    assert result == 150.0

# Add new tests using whole object
def test_discount_with_whole_object():
    customer = Customer(type="PREMIUM", years=6, purchases=1000.0)
    result = calculate_discount(customer)
    assert result == 150.0

# After refactoring complete, remove old parameter-based tests
# and keep only object-based tests
```

**Conclusion**

Preserve Whole Object is a valuable refactoring technique that simplifies method signatures, reduces duplication, and improves code maintainability. By passing complete objects instead of extracted values, code becomes more resilient to change and better expresses the conceptual relationships between components. Apply this refactoring when multiple parameters come from the same source object, but be mindful of the dependencies it creates and ensure they align with your architectural goals.

**Next Steps**

- Review your codebase for methods with 3+ parameters from the same source object
- Identify long parameter lists that obscure the method's purpose
- Apply the refactoring incrementally, one method at a time
- Run your test suite after each change to verify behavior is preserved
- Consider whether refactored methods should move to the object they now receive
- Evaluate whether new dependencies align with your system's architecture

---

## Replace Magic Number with Constant

Replace Magic Number with Constant is a refactoring technique that involves extracting literal numeric values from code and replacing them with named constants. This pattern improves code readability, maintainability, and reduces the likelihood of errors when values need to change.

### Pattern Definition

A magic number is a numeric literal that appears directly in code without explanation of its meaning or purpose. Replacing these with named constants provides context and creates a single source of truth for values used throughout the codebase.

### Problem Context

Magic numbers create several challenges in code:

**Unclear Intent**: Numeric literals provide no context about their purpose or meaning. A reader encountering `if (age > 18)` must infer that 18 represents a legal age threshold.

**Maintenance Difficulty**: When a value appears multiple times throughout code, updates require finding and changing each occurrence. Missing even one instance creates inconsistent behavior.

**Error Prone**: Typing the same number repeatedly increases the risk of transcription errors. Different occurrences might unintentionally use different values.

**Reduced Searchability**: Finding all uses of a specific value requires searching for the literal number, which may appear in unrelated contexts.

### Solution Structure

Extract the magic number into a named constant with a meaningful identifier that explains its purpose:

**Before:**

```csharp
public decimal CalculateDiscount(decimal amount)
{
    if (amount > 1000)
    {
        return amount * 0.15;
    }
    return amount * 0.05;
}
```

**After:**

```csharp
private const decimal LARGE_ORDER_THRESHOLD = 1000m;
private const decimal LARGE_ORDER_DISCOUNT_RATE = 0.15m;
private const decimal STANDARD_DISCOUNT_RATE = 0.05m;

public decimal CalculateDiscount(decimal amount)
{
    if (amount > LARGE_ORDER_THRESHOLD)
    {
        return amount * LARGE_ORDER_DISCOUNT_RATE;
    }
    return amount * STANDARD_DISCOUNT_RATE;
}
```

### When to Apply

**Meaningful Business Values**: Numbers representing business rules, thresholds, rates, or configuration values should typically become constants.

**Repeated Values**: Any number appearing more than once in related contexts is a strong candidate for extraction.

**Non-Obvious Meaning**: If a reader cannot immediately understand why a specific number is used, it should be named.

**Values That Might Change**: Numbers representing policies, limits, or configurations that could change based on business decisions or requirements.

### When Not to Apply

**Self-Evident Values**: Some numbers are universally understood in context and extraction adds no value:

```csharp
// Unnecessary constant extraction
private const int ARRAY_START_INDEX = 0;
for (int i = ARRAY_START_INDEX; i < array.Length; i++)

// Clear as written
for (int i = 0; i < array.Length; i++)
```

**Mathematical Constants**: Well-known mathematical values like 0, 1, 2, or -1 used in standard operations typically don't need extraction unless they represent domain-specific meaning.

**Unique Occurrences**: A number appearing only once with clear context may not benefit from extraction, though this depends on whether it represents a potentially changing business rule.

### Example

Consider a payment processing system with various magic numbers:

**Before:**

```java
public class PaymentProcessor {
    public boolean processPayment(Payment payment) {
        if (payment.getAmount() < 0.01) {
            throw new InvalidPaymentException("Amount too small");
        }
        
        if (payment.getAmount() > 10000) {
            return processLargePayment(payment);
        }
        
        double fee = payment.getAmount() * 0.029 + 0.30;
        double total = payment.getAmount() + fee;
        
        if (total > payment.getAccount().getBalance()) {
            return false;
        }
        
        payment.getAccount().deduct(total);
        return true;
    }
}
```

**After:**

```java
public class PaymentProcessor {
    private static final double MINIMUM_PAYMENT_AMOUNT = 0.01;
    private static final double LARGE_PAYMENT_THRESHOLD = 10000.00;
    private static final double TRANSACTION_FEE_RATE = 0.029;
    private static final double TRANSACTION_FEE_FIXED = 0.30;
    
    public boolean processPayment(Payment payment) {
        if (payment.getAmount() < MINIMUM_PAYMENT_AMOUNT) {
            throw new InvalidPaymentException("Amount too small");
        }
        
        if (payment.getAmount() > LARGE_PAYMENT_THRESHOLD) {
            return processLargePayment(payment);
        }
        
        double fee = payment.getAmount() * TRANSACTION_FEE_RATE + TRANSACTION_FEE_FIXED;
        double total = payment.getAmount() + fee;
        
        if (total > payment.getAccount().getBalance()) {
            return false;
        }
        
        payment.getAccount().deduct(total);
        return true;
    }
}
```

### Naming Conventions

**Descriptive Names**: Constant names should clearly communicate what the value represents, not just restate the number.

```csharp
// Poor: just restates the value
private const int EIGHTEEN = 18;

// Good: explains the meaning
private const int LEGAL_AGE_THRESHOLD = 18;
```

**Consistent Style**: Most languages and style guides recommend UPPER_SNAKE_CASE for constants, though conventions vary by language and team standards.

**Domain Language**: Use terminology from the business domain that developers and stakeholders recognize.

### Scope Considerations

**Class-Level Constants**: When a value is used only within a single class, define it as a private constant in that class.

**Shared Constants**: Values used across multiple classes should be defined in a dedicated constants class or configuration file.

**Example:**

```csharp
public static class PaymentConstants
{
    public const decimal TRANSACTION_FEE_RATE = 0.029m;
    public const decimal TRANSACTION_FEE_FIXED = 0.30m;
    public const decimal LARGE_PAYMENT_THRESHOLD = 10000m;
}
```

### Configuration vs Constants

Some values are better suited to configuration files rather than code constants:

**Code Constants**: Values that are fundamental to the system's logic and rarely change. Changes require code updates and redeployment.

**Configuration**: Values that vary between environments, change frequently based on business needs, or should be adjustable without code changes.

```json
// config.json
{
    "payment": {
        "transactionFeeRate": 0.029,
        "transactionFeeFixed": 0.30,
        "largePaymentThreshold": 10000
    }
}
```

[Inference] The choice between constants and configuration often depends on deployment practices and organizational requirements.

### Language-Specific Implementations

**Python:**

```python
# Constants typically defined at module level
MINIMUM_PASSWORD_LENGTH = 8
MAX_LOGIN_ATTEMPTS = 3
SESSION_TIMEOUT_SECONDS = 1800

def validate_password(password):
    return len(password) >= MINIMUM_PASSWORD_LENGTH
```

**JavaScript/TypeScript:**

```typescript
// TypeScript with const assertion
const PaymentConfig = {
    MINIMUM_AMOUNT: 0.01,
    LARGE_PAYMENT_THRESHOLD: 10000,
    TRANSACTION_FEE_RATE: 0.029,
    TRANSACTION_FEE_FIXED: 0.30
} as const;

export default PaymentConfig;
```

**C++:**

```cpp
// Header file
class PaymentProcessor {
private:
    static constexpr double TRANSACTION_FEE_RATE = 0.029;
    static constexpr double TRANSACTION_FEE_FIXED = 0.30;
    static constexpr double LARGE_PAYMENT_THRESHOLD = 10000.0;
};
```

### Refactoring Process

**Step 1: Identify Magic Numbers**: Review code for numeric literals that represent business rules or configuration values.

**Step 2: Determine Scope**: Decide whether the constant should be class-level, module-level, or shared across the system.

**Step 3: Create Named Constant**: Define the constant with a descriptive name in the appropriate location.

**Step 4: Replace Occurrences**: Substitute all occurrences of the magic number with the named constant.

**Step 5: Test**: Verify that behavior remains unchanged after refactoring.

### Related Patterns

**Replace Magic String with Constant**: The same principle applies to string literals representing status codes, categories, or identifiers.

**Introduce Parameter Object**: When multiple related constants are passed together, consider grouping them into a configuration object.

**Strategy Pattern**: Constants representing different algorithmic choices might indicate an opportunity to use strategy pattern for better extensibility.

### Testing Considerations

Constants should be easily changeable for testing purposes when appropriate:

```csharp
// Using dependency injection for testable constants
public interface IPaymentConfig
{
    decimal TransactionFeeRate { get; }
    decimal LargePaymentThreshold { get; }
}

public class PaymentProcessor
{
    private readonly IPaymentConfig _config;
    
    public PaymentProcessor(IPaymentConfig config)
    {
        _config = config;
    }
    
    public decimal CalculateFee(decimal amount)
    {
        return amount * _config.TransactionFeeRate;
    }
}
```

This approach allows tests to provide different values without modifying production code.

### Common Pitfalls

**Over-Extraction**: Creating constants for every number, including trivial values, can clutter code without adding clarity.

**Poor Naming**: Generic names like `CONSTANT_1` or `VALUE` defeat the purpose of extraction.

**Wrong Scope**: Defining constants too broadly (public when private would suffice) or too narrowly (duplicated across classes) creates maintenance issues.

**Incorrect Grouping**: Unrelated constants grouped together simply because they share the same numeric value creates false associations.

### Documentation Value

Well-named constants serve as inline documentation, making code self-explanatory:

```csharp
// The constant name documents the business rule
if (employee.YearsOfService >= RETIREMENT_ELIGIBILITY_YEARS)
{
    // Process retirement
}

// Versus the unclear magic number
if (employee.YearsOfService >= 20)
{
    // Why 20? What does this mean?
}
```

### Evolution and Maintenance

As systems evolve, constants may need to become more flexible:

```csharp
// Initial implementation with constant
private const int MAX_RETRIES = 3;

// Evolution to configuration
private readonly int _maxRetries = ConfigurationManager.GetValue<int>("MaxRetries");

// Further evolution to strategy
private readonly IRetryPolicy _retryPolicy;
```

[Inference] This progression typically occurs as requirements become more complex or variable across different contexts.

**Conclusion**

Replace Magic Number with Constant is a fundamental refactoring that significantly improves code quality with minimal effort. By providing meaningful names for numeric values, this pattern makes code more readable, maintainable, and less error-prone. While straightforward to apply, judicious use of this refactoring helps create self-documenting code that clearly communicates business rules and system constraints.

---

## Encapsulate Field

Encapsulate Field is a refactoring technique that replaces direct access to a field with getter and setter methods. This transformation converts public or protected fields into private fields accessed through controlled accessor methods, establishing a boundary between a class's internal representation and its public interface.

### Purpose and Context

Direct field access creates tight coupling between classes and exposes implementation details. When external code directly accesses fields, changing the field's type, name, or internal representation requires modifying all code that references it. Encapsulation through accessor methods provides an indirection layer that enables internal changes without affecting external code.

This refactoring is fundamental to object-oriented design, supporting information hiding and enabling future flexibility. It represents the transition from data-centric to behavior-centric design.

### Problem Being Addressed

**Direct Field Access Issues**

Code with public fields exhibits several problems:

```java
class Account {
    public String accountNumber;
    public double balance;
    public String status;
}

// Client code with direct access
Account account = new Account();
account.balance = 1000.0;  // No validation
account.status = "ACTIVE";  // No business rules enforced
account.balance = -500.0;   // Invalid state allowed

if (account.balance > 0) {
    // Direct dependency on field name and type
}
```

Problems with this approach:

- No validation or business rule enforcement
- Cannot change internal representation without breaking clients
- Cannot add behavior when fields are accessed or modified
- Difficult to debug field changes (no single modification point)
- Cannot make fields read-only or write-only selectively
- Violates encapsulation principle

### Refactoring Mechanics

**Basic Transformation**

The refactoring follows these steps:

1. Create getter and setter methods for the field
2. Change field visibility to private
3. Find all references to the field
4. Replace reads with getter calls
5. Replace writes with setter calls
6. Test after each change

**Example**

```java
// Before: Direct field access
class Person {
    public String name;
    public int age;
}

// Usage
Person person = new Person();
person.name = "John Doe";
person.age = 30;
String displayName = person.name;

// After: Encapsulated fields
class Person {
    private String name;
    private int age;
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public int getAge() {
        return age;
    }
    
    public void setAge(int age) {
        this.age = age;
    }
}

// Updated usage
Person person = new Person();
person.setName("John Doe");
person.setAge(30);
String displayName = person.getName();
```

### Variations and Approaches

**Read-Only Encapsulation**

Provide only a getter when the field should not be modifiable externally:

```java
class Order {
    private String orderId;
    private LocalDateTime createdAt;
    
    public Order(String orderId) {
        this.orderId = orderId;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getter only - no setter
    public String getOrderId() {
        return orderId;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
```

**Write-Only Encapsulation**

Provide only a setter when the field's value should not be readable externally (less common):

```java
class UserCredentials {
    private String passwordHash;
    
    // Setter only - no getter
    public void setPassword(String plainPassword) {
        this.passwordHash = hashPassword(plainPassword);
    }
    
    private String hashPassword(String plain) {
        // Hashing implementation
        return BCrypt.hashpw(plain, BCrypt.gensalt());
    }
    
    public boolean verifyPassword(String plainPassword) {
        return BCrypt.checkpw(plainPassword, passwordHash);
    }
}
```

**Computed Properties**

Fields don't always map directly to accessors. Getters can compute values:

```java
class Rectangle {
    private double width;
    private double height;
    
    public double getWidth() {
        return width;
    }
    
    public void setWidth(double width) {
        this.width = width;
    }
    
    public double getHeight() {
        return height;
    }
    
    public void setHeight(double height) {
        this.height = height;
    }
    
    // Computed property - no backing field
    public double getArea() {
        return width * height;
    }
    
    public double getPerimeter() {
        return 2 * (width + height);
    }
}
```

**Collection Encapsulation**

Collections require special handling to prevent external modification:

```java
class Team {
    private List<String> members;
    
    public Team() {
        this.members = new ArrayList<>();
    }
    
    // Return defensive copy to prevent external modification
    public List<String> getMembers() {
        return new ArrayList<>(members);
    }
    
    // Or return unmodifiable view
    public List<String> getMembersReadOnly() {
        return Collections.unmodifiableList(members);
    }
    
    // Provide specific modification methods
    public void addMember(String member) {
        if (member != null && !member.isEmpty()) {
            members.add(member);
        }
    }
    
    public void removeMember(String member) {
        members.remove(member);
    }
}
```

### Adding Validation

One primary benefit of encapsulation is the ability to add validation and business rules:

**Basic Validation**

```java
class BankAccount {
    private double balance;
    private String accountNumber;
    
    public double getBalance() {
        return balance;
    }
    
    public void setBalance(double balance) {
        if (balance < 0) {
            throw new IllegalArgumentException(
                "Balance cannot be negative: " + balance
            );
        }
        this.balance = balance;
    }
    
    public String getAccountNumber() {
        return accountNumber;
    }
    
    public void setAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Account number cannot be null or empty"
            );
        }
        if (!accountNumber.matches("\\d{10}")) {
            throw new IllegalArgumentException(
                "Account number must be 10 digits"
            );
        }
        this.accountNumber = accountNumber;
    }
}
```

**Cross-Field Validation**

```java
class DateRange {
    private LocalDate startDate;
    private LocalDate endDate;
    
    public LocalDate getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDate startDate) {
        if (startDate == null) {
            throw new IllegalArgumentException("Start date cannot be null");
        }
        if (endDate != null && startDate.isAfter(endDate)) {
            throw new IllegalArgumentException(
                "Start date must be before or equal to end date"
            );
        }
        this.startDate = startDate;
    }
    
    public LocalDate getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDate endDate) {
        if (endDate == null) {
            throw new IllegalArgumentException("End date cannot be null");
        }
        if (startDate != null && endDate.isBefore(startDate)) {
            throw new IllegalArgumentException(
                "End date must be after or equal to start date"
            );
        }
        this.endDate = endDate;
    }
}
```

### Language-Specific Implementations

**Java**

Traditional getter/setter pattern with naming conventions:

```java
class Product {
    private String name;
    private double price;
    private boolean available;
    
    // Getter for boolean uses 'is' prefix
    public boolean isAvailable() {
        return available;
    }
    
    public void setAvailable(boolean available) {
        this.available = available;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public double getPrice() {
        return price;
    }
    
    public void setPrice(double price) {
        this.price = price;
    }
}
```

**C# Properties**

C# provides syntactic sugar for encapsulation:

```csharp
class Product
{
    // Auto-implemented property
    public string Name { get; set; }
    
    // Property with backing field and validation
    private double _price;
    public double Price
    {
        get { return _price; }
        set 
        {
            if (value < 0)
                throw new ArgumentException("Price cannot be negative");
            _price = value;
        }
    }
    
    // Read-only property
    public DateTime CreatedAt { get; }
    
    // Computed property
    public double PriceWithTax => _price * 1.08;
    
    // Property with different access levels
    public string Id { get; private set; }
    
    public Product(string id)
    {
        Id = id;
        CreatedAt = DateTime.Now;
    }
}
```

**Python Properties**

Python uses the `@property` decorator:

```python
class BankAccount:
    def __init__(self, account_number):
        self._account_number = account_number
        self._balance = 0.0
    
    @property
    def account_number(self):
        """Read-only property"""
        return self._account_number
    
    @property
    def balance(self):
        return self._balance
    
    @balance.setter
    def balance(self, value):
        if value < 0:
            raise ValueError("Balance cannot be negative")
        self._balance = value
    
    # Computed property
    @property
    def formatted_balance(self):
        return f"${self._balance:.2f}"

# Usage
account = BankAccount("1234567890")
print(account.account_number)  # Works like field access
account.balance = 1000.0  # Calls setter with validation
print(account.formatted_balance)  # Computed value
```

**JavaScript/TypeScript**

```typescript
class User {
    private _email: string;
    private _createdAt: Date;
    
    constructor(email: string) {
        this._email = email;
        this._createdAt = new Date();
    }
    
    // Getter
    get email(): string {
        return this._email;
    }
    
    // Setter with validation
    set email(value: string) {
        if (!value.includes('@')) {
            throw new Error('Invalid email format');
        }
        this._email = value;
    }
    
    // Read-only property
    get createdAt(): Date {
        return this._createdAt;
    }
    
    // Computed property
    get emailDomain(): string {
        return this._email.split('@')[1];
    }
}

// Usage looks like field access
const user = new User('john@example.com');
console.log(user.email);
user.email = 'jane@example.com';
console.log(user.emailDomain);
```

**Kotlin**

Kotlin properties have built-in encapsulation:

```kotlin
class Person(
    // Property with default getter/setter
    var name: String,
    
    // Read-only property (val)
    val id: String
) {
    // Property with custom getter/setter
    var age: Int = 0
        set(value) {
            if (value < 0) {
                throw IllegalArgumentException("Age cannot be negative")
            }
            field = value
        }
    
    // Computed property
    val isAdult: Boolean
        get() = age >= 18
    
    // Property with private setter
    var email: String = ""
        private set
    
    fun updateEmail(newEmail: String) {
        // Business logic for email update
        email = newEmail
    }
}
```

### Enabling Future Changes

Encapsulation allows internal representation changes without affecting clients:

**Type Change**

```java
// Initial implementation
class Temperature {
    private double celsius;
    
    public double getCelsius() {
        return celsius;
    }
    
    public void setCelsius(double celsius) {
        this.celsius = celsius;
    }
    
    public double getFahrenheit() {
        return celsius * 9.0 / 5.0 + 32.0;
    }
}

// Later: Change internal representation without breaking clients
class Temperature {
    private double kelvin;  // Changed internal storage
    
    public double getCelsius() {
        return kelvin - 273.15;  // Convert on access
    }
    
    public void setCelsius(double celsius) {
        this.kelvin = celsius + 273.15;  // Convert on storage
    }
    
    public double getFahrenheit() {
        return getCelsius() * 9.0 / 5.0 + 32.0;
    }
    
    public double getKelvin() {
        return kelvin;
    }
}
```

**Lazy Initialization**

```java
class ReportGenerator {
    private Report cachedReport;
    private boolean reportGenerated = false;
    
    // External code doesn't know about caching
    public Report getReport() {
        if (!reportGenerated) {
            cachedReport = generateReport();
            reportGenerated = true;
        }
        return cachedReport;
    }
    
    private Report generateReport() {
        // Expensive operation
        return new Report(/* ... */);
    }
    
    public void invalidateCache() {
        reportGenerated = false;
        cachedReport = null;
    }
}
```

**Adding Logging and Debugging**

```java
class ShoppingCart {
    private List<Item> items = new ArrayList<>();
    private Logger logger = LoggerFactory.getLogger(ShoppingCart.class);
    
    public List<Item> getItems() {
        logger.debug("Accessing cart items, count: {}", items.size());
        return new ArrayList<>(items);
    }
    
    public void addItem(Item item) {
        logger.info("Adding item to cart: {}", item.getName());
        items.add(item);
        logger.debug("Cart now contains {} items", items.size());
    }
    
    public void removeItem(Item item) {
        logger.info("Removing item from cart: {}", item.getName());
        boolean removed = items.remove(item);
        if (removed) {
            logger.debug("Item removed successfully");
        } else {
            logger.warn("Item not found in cart: {}", item.getName());
        }
    }
}
```

### Migration Strategy

**Gradual Encapsulation**

For large codebases, encapsulate fields gradually:

```java
// Step 1: Add accessors while keeping field public
class Customer {
    @Deprecated
    public String name;  // Keep public temporarily
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
}

// Step 2: Update all client code to use accessors
// (This may take time across large codebase)

// Step 3: Make field private after all clients updated
class Customer {
    private String name;  // Now private
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
}
```

**IDE Support**

Modern IDEs automate much of this refactoring. [Inference: Specific features may vary by IDE and version]:

- **Generate accessors**: Automatically create getters/setters
- **Encapsulate fields**: Convert public fields to private with accessors
- **Inline field**: Opposite refactoring when encapsulation isn't needed
- **Change signature**: Update all usages when accessor signatures change

### Design Considerations

**When to Encapsulate**

Encapsulate fields when:

- Fields are part of a class's public API
- Validation or business rules apply to field values
- Future implementation changes are anticipated
- Field access needs logging, monitoring, or tracking
- Different access permissions are needed (read vs write)

**When Not to Encapsulate**

Consider not encapsulating when:

- Working with simple data transfer objects (DTOs) that only carry data
- Using value objects with immutable fields
- Working within private inner classes where encapsulation adds no value
- Performance-critical code where accessor overhead matters (rare)

**Data Transfer Objects**

DTOs often use public fields for simplicity:

```java
// DTO with public fields is acceptable
class UserDTO {
    public String id;
    public String name;
    public String email;
    
    // Constructor, equals, hashCode
}

// But domain objects should encapsulate
class User {
    private String id;
    private String name;
    private String email;
    
    // Getters, setters with validation
    // Business methods
}
```

### Combining with Other Refactorings

**Replace Setter with Method**

Sometimes setters should be replaced with more specific methods:

```java
// Before: Generic setter
class Order {
    private OrderStatus status;
    
    public void setStatus(OrderStatus status) {
        this.status = status;
    }
}

// After: Specific business methods
class Order {
    private OrderStatus status;
    
    public void ship() {
        if (status != OrderStatus.CONFIRMED) {
            throw new IllegalStateException("Cannot ship unconfirmed order");
        }
        this.status = OrderStatus.SHIPPED;
        // Additional shipping logic
    }
    
    public void cancel() {
        if (status == OrderStatus.DELIVERED) {
            throw new IllegalStateException("Cannot cancel delivered order");
        }
        this.status = OrderStatus.CANCELLED;
        // Additional cancellation logic
    }
}
```

**Self-Encapsulate Field**

Use accessors even within the class itself:

```java
class Employee {
    private double salary;
    
    public double getSalary() {
        return salary;
    }
    
    protected void setSalary(double salary) {
        if (salary < 0) {
            throw new IllegalArgumentException("Salary cannot be negative");
        }
        this.salary = salary;
    }
    
    // Use accessor internally to leverage validation
    public void giveRaise(double percentage) {
        setSalary(getSalary() * (1 + percentage / 100));
    }
    
    public void adjustSalary(double amount) {
        setSalary(getSalary() + amount);
    }
}
```

This pattern enforces validation even for internal modifications. [Inference: Whether to self-encapsulate is debated; some prefer direct field access within the class for clarity].

### Testing Implications

Encapsulation improves testability by providing controlled access points:

```java
class Account {
    private double balance;
    private List<Transaction> transactions;
    
    public Account() {
        this.balance = 0.0;
        this.transactions = new ArrayList<>();
    }
    
    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("Deposit amount must be positive");
        }
        balance += amount;
        transactions.add(new Transaction(TransactionType.DEPOSIT, amount));
    }
    
    public double getBalance() {
        return balance;
    }
    
    // Package-private for testing
    List<Transaction> getTransactions() {
        return new ArrayList<>(transactions);
    }
}

// Test
class AccountTest {
    @Test
    public void shouldRecordDepositTransaction() {
        Account account = new Account();
        account.deposit(100.0);
        
        assertEquals(100.0, account.getBalance(), 0.01);
        assertEquals(1, account.getTransactions().size());
        assertEquals(TransactionType.DEPOSIT, 
                     account.getTransactions().get(0).getType());
    }
}
```

### Common Pitfalls

**Anemic Domain Model**

Creating classes with only getters and setters without behavior:

```java
// Anti-pattern: Anemic model
class Order {
    private double total;
    private OrderStatus status;
    
    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }
    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) { this.status = status; }
}

// Better: Rich domain model
class Order {
    private double total;
    private OrderStatus status;
    
    public void addLineItem(LineItem item) {
        total += item.getPrice();
    }
    
    public void ship() {
        if (status != OrderStatus.CONFIRMED) {
            throw new IllegalStateException("Cannot ship unconfirmed order");
        }
        status = OrderStatus.SHIPPED;
    }
    
    public double getTotal() { return total; }
    public OrderStatus getStatus() { return status; }
}
```

**Exposing Mutable Collections**

```java
// Problem: Exposes internal collection
class Team {
    private List<Player> players = new ArrayList<>();
    
    // Dangerous - allows external modification
    public List<Player> getPlayers() {
        return players;
    }
}

// External code can break encapsulation
team.getPlayers().clear();  // Modifies internal state

// Solution: Return defensive copy or unmodifiable view
class Team {
    private List<Player> players = new ArrayList<>();
    
    public List<Player> getPlayers() {
        return Collections.unmodifiableList(players);
    }
    
    public void addPlayer(Player player) {
        players.add(player);
    }
}
```

**Validation in Getter**

Validation belongs in setters, not getters:

```java
// Anti-pattern: Validation in getter
class User {
    private String email;
    
    public String getEmail() {
        if (email == null || !email.contains("@")) {
            throw new IllegalStateException("Invalid email");
        }
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;  // No validation
    }
}

// Correct: Validation in setter
class User {
    private String email;
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        this.email = email;
    }
}
```

### Performance Considerations

Accessor methods introduce minimal overhead. [Inference: Modern JVM and compiler optimizations typically inline simple getters/setters, making performance differences negligible in most scenarios]:

```java
// The JVM typically inlines this
public int getValue() {
    return value;
}

// Equivalent to direct field access after optimization
```

For performance-critical scenarios, profile before optimizing. The benefits of encapsulation typically outweigh minor performance costs.

### Real-World Example

**E-commerce Product Class**

```java
// Before: Public fields
class Product {
    public String id;
    public String name;
    public double price;
    public int stockQuantity;
    public List<String> tags;
}

// Issues with direct access
Product product = new Product();
product.price = -10.0;  // Invalid price
product.stockQuantity = -5;  // Invalid stock
product.tags.add("invalid");  // Uncontrolled tag addition

// After: Encapsulated fields
class Product {
    private final String id;
    private String name;
    private double price;
    private int stockQuantity;
    private final List<String> tags;
    
    public Product(String id, String name, double price) {
        if (id == null || id.trim().isEmpty()) {
            throw new IllegalArgumentException("Product ID cannot be empty");
        }
        this.id = id;
        this.tags = new ArrayList<>();
        setName(name);
        setPrice(price);
        this.stockQuantity = 0;
    }
    
    public String getId() {
        return id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Product name cannot be empty");
        }
        this.name = name.trim();
    }
    
    public double getPrice() {
        return price;
    }
    
    public void setPrice(double price) {
        if (price < 0) {
            throw new IllegalArgumentException("Price cannot be negative: " + price);
        }
        this.price = price;
    }
    
    public int getStockQuantity() {
        return stockQuantity;
    }
    
    public boolean isInStock() {
        return stockQuantity > 0;
    }
    
    public void addStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        this.stockQuantity += quantity;
    }
    
    public void removeStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        if (quantity > stockQuantity) {
            throw new IllegalStateException(
                "Cannot remove more stock than available. " +
                "Requested: " + quantity + ", Available: " + stockQuantity
            );
        }
        this.stockQuantity -= quantity;
    }
    
    public List<String> getTags() {
        return Collections.unmodifiableList(tags);
    }
    
    public void addTag(String tag) {
        if (tag == null || tag.trim().isEmpty()) {
            throw new IllegalArgumentException("Tag cannot be empty");
        }
        String normalizedTag = tag.trim().toLowerCase();
        if (!tags.contains(normalizedTag)) {
            tags.add(normalizedTag);
        }
    }
    
    public void removeTag(String tag) {
        tags.remove(tag.trim().toLowerCase());
    }
    
    public void clearTags() {
        tags.clear();
    }
}
```

**Usage**

```java
// Valid operations
Product product = new Product("P001", "Laptop", 999.99);
product.addStock(50);
product.addTag("Electronics");
product.addTag("Computers");

System.out.println("Price: $" + product.getPrice());
System.out.println("In stock: " + product.isInStock());
System.out.println("Tags: " + product.getTags());

// Invalid operations are prevented
try {
    product.setPrice(-100);  // Throws exception
} catch (IllegalArgumentException e) {
    System.out.println("Error: " + e.getMessage());
}

try {
    product.removeStock(100);  // Throws exception (not enough stock)
} catch (IllegalStateException e) {
    System.out.println("Error: " + e.getMessage());
}
```

**Output**

```
Price: $999.99
In stock: true
Tags: [electronics, computers]
Error: Price cannot be negative: -100.0
Error: Cannot remove more stock than available. Requested: 100, Available: 50
```

### Benefits Summary

Encapsulate Field refactoring provides:

- **Validation**: Enforce business rules and invariants
- **Flexibility**: Change internal representation without affecting clients
- **Debugging**: Single point to monitor field changes
- **Access control**: Fine-grained read/write permissions
- **Computed properties**: Derive values without storing them
- **Consistency**: Maintain object invariants across operations
- **Documentation**: Accessor names communicate intent
- **Immutability**: Create read-only properties easily

### Conclusion

Encapsulate Field transforms public data exposure into controlled access through methods. This refactoring establishes a boundary between internal implementation and external interface, enabling validation, logging, and future changes without breaking client code. While it adds syntactic overhead, the benefits of information hiding, maintainability, and flexibility typically justify the transformation. [Inference: The value of this refactoring depends on the complexity of the domain and the likelihood of future changes to internal representation].

### Next Steps

To apply this refactoring effectively:

1. Identify public or protected fields in your codebase that should be encapsulated
2. Use IDE refactoring tools to generate getters and setters automatically
3. Add validation logic to setters where business rules apply
4. Consider which fields should be read-only or write-only
5. Replace setters with specific business methods when appropriate
6. Review DTOs and value objects to determine if encapsulation adds value
7. Update team coding standards to prefer private fields with accessors
8. Consider using language features (properties, decorators) that simplify encapsulation syntax

---

## Replace Type Code with Class

Replace Type Code with Class is a refactoring technique that transforms primitive type codes (integers, strings, enums) into dedicated class hierarchies. This refactoring improves type safety, enables polymorphism, and makes code more maintainable by encapsulating type-specific behavior within appropriate classes.

### Purpose and Context

Type codes appear frequently in codebases as simple indicators of object types or states—often represented as integers, string constants, or basic enums. While initially convenient, type codes lead to conditional logic scattered throughout the codebase, poor type safety, and difficulty adding new types.

This refactoring addresses these issues by creating explicit classes for each type, allowing the type system to enforce correctness and enabling object-oriented techniques like polymorphism.

### Problem: Code Smells with Type Codes

#### Scattered Conditional Logic

**Example:**

```java
public class Employee {
    public static final int ENGINEER = 0;
    public static final int SALESMAN = 1;
    public static final int MANAGER = 2;
    
    private int type;
    private int monthlySalary;
    private int commission;
    private int bonus;
    
    public Employee(int type) {
        this.type = type;
    }
    
    public int payAmount() {
        switch (type) {
            case ENGINEER:
                return monthlySalary;
            case SALESMAN:
                return monthlySalary + commission;
            case MANAGER:
                return monthlySalary + bonus;
            default:
                throw new RuntimeException("Invalid employee type");
        }
    }
    
    public String getTitle() {
        switch (type) {
            case ENGINEER:
                return "Software Engineer";
            case SALESMAN:
                return "Sales Representative";
            case MANAGER:
                return "Department Manager";
            default:
                throw new RuntimeException("Invalid employee type");
        }
    }
}
```

**Issues with this approach:**

- Type checking logic duplicated across multiple methods
- [Inference] Adding new employee types requires changes in multiple locations
- No compile-time safety preventing invalid type codes
- Behavior coupled to type codes rather than encapsulated in type-specific classes

### Refactoring Steps

#### Step 1: Create Type Class Hierarchy

Create an abstract base class and concrete subclasses for each type:

**Example:**

```java
public abstract class EmployeeType {
    public abstract int payAmount(Employee employee);
    public abstract String getTitle();
}

public class Engineer extends EmployeeType {
    @Override
    public int payAmount(Employee employee) {
        return employee.getMonthlySalary();
    }
    
    @Override
    public String getTitle() {
        return "Software Engineer";
    }
}

public class Salesman extends EmployeeType {
    @Override
    public int payAmount(Employee employee) {
        return employee.getMonthlySalary() + employee.getCommission();
    }
    
    @Override
    public String getTitle() {
        return "Sales Representative";
    }
}

public class Manager extends EmployeeType {
    @Override
    public int payAmount(Employee employee) {
        return employee.getMonthlySalary() + employee.getBonus();
    }
    
    @Override
    public String getTitle() {
        return "Department Manager";
    }
}
```

#### Step 2: Replace Type Code with Type Object

Modify the original class to use the type object instead of primitive code:

**Example:**

```java
public class Employee {
    private EmployeeType type;
    private int monthlySalary;
    private int commission;
    private int bonus;
    
    public Employee(EmployeeType type) {
        this.type = type;
    }
    
    public int payAmount() {
        return type.payAmount(this);
    }
    
    public String getTitle() {
        return type.getTitle();
    }
    
    // Getters
    public int getMonthlySalary() { return monthlySalary; }
    public int getCommission() { return commission; }
    public int getBonus() { return bonus; }
}
```

#### Step 3: Update Client Code

Update code that creates or uses type codes:

**Example:**

```java
// Before
Employee emp1 = new Employee(Employee.ENGINEER);
Employee emp2 = new Employee(Employee.SALESMAN);

// After
Employee emp1 = new Employee(new Engineer());
Employee emp2 = new Employee(new Salesman());
```

### Complete Before and After Comparison

#### Before Refactoring

**Example:**

```python
class BloodGroup:
    O = 0
    A = 1
    B = 2
    AB = 3

class Person:
    def __init__(self, name, blood_group_code):
        self.name = name
        self.blood_group_code = blood_group_code
    
    def can_donate_to(self, recipient):
        # Complex conditional logic based on type codes
        if self.blood_group_code == BloodGroup.O:
            return True  # Universal donor
        elif self.blood_group_code == BloodGroup.A:
            return recipient.blood_group_code in [BloodGroup.A, BloodGroup.AB]
        elif self.blood_group_code == BloodGroup.B:
            return recipient.blood_group_code in [BloodGroup.B, BloodGroup.AB]
        elif self.blood_group_code == BloodGroup.AB:
            return recipient.blood_group_code == BloodGroup.AB
        return False
    
    def get_compatibility_description(self):
        if self.blood_group_code == BloodGroup.O:
            return "Universal donor, can receive from O only"
        elif self.blood_group_code == BloodGroup.A:
            return "Can donate to A and AB, receive from O and A"
        elif self.blood_group_code == BloodGroup.B:
            return "Can donate to B and AB, receive from O and B"
        elif self.blood_group_code == BloodGroup.AB:
            return "Universal recipient, can donate to AB only"
        return "Unknown"

# Usage
person1 = Person("Alice", BloodGroup.O)
person2 = Person("Bob", BloodGroup.A)
print(person1.can_donate_to(person2))  # True
```

#### After Refactoring

**Example:**

```python
from abc import ABC, abstractmethod

class BloodGroup(ABC):
    @abstractmethod
    def can_donate_to(self, recipient_group):
        pass
    
    @abstractmethod
    def get_compatibility_description(self):
        pass

class BloodGroupO(BloodGroup):
    def can_donate_to(self, recipient_group):
        return True  # Universal donor
    
    def get_compatibility_description(self):
        return "Universal donor, can receive from O only"

class BloodGroupA(BloodGroup):
    def can_donate_to(self, recipient_group):
        return isinstance(recipient_group, (BloodGroupA, BloodGroupAB))
    
    def get_compatibility_description(self):
        return "Can donate to A and AB, receive from O and A"

class BloodGroupB(BloodGroup):
    def can_donate_to(self, recipient_group):
        return isinstance(recipient_group, (BloodGroupB, BloodGroupAB))
    
    def get_compatibility_description(self):
        return "Can donate to B and AB, receive from O and B"

class BloodGroupAB(BloodGroup):
    def can_donate_to(self, recipient_group):
        return isinstance(recipient_group, BloodGroupAB)
    
    def get_compatibility_description(self):
        return "Universal recipient, can donate to AB only"

class Person:
    def __init__(self, name, blood_group):
        self.name = name
        self.blood_group = blood_group
    
    def can_donate_to(self, recipient):
        return self.blood_group.can_donate_to(recipient.blood_group)
    
    def get_compatibility_description(self):
        return self.blood_group.get_compatibility_description()

# Usage
person1 = Person("Alice", BloodGroupO())
person2 = Person("Bob", BloodGroupA())
print(person1.can_donate_to(person2))  # True
```

**Key improvements:**

- Type-specific logic encapsulated in dedicated classes
- Polymorphism replaces conditional statements
- [Inference] Adding new blood groups requires creating a new class without modifying existing code
- Compile-time/runtime type checking prevents invalid types

### Advanced Patterns

#### Using Factory Pattern

Combine with Factory pattern to simplify object creation:

**Example:**

```typescript
abstract class DocumentType {
    abstract getFileExtension(): string;
    abstract getMimeType(): string;
    abstract createProcessor(): DocumentProcessor;
}

class PdfDocument extends DocumentType {
    getFileExtension(): string {
        return '.pdf';
    }
    
    getMimeType(): string {
        return 'application/pdf';
    }
    
    createProcessor(): DocumentProcessor {
        return new PdfProcessor();
    }
}

class WordDocument extends DocumentType {
    getFileExtension(): string {
        return '.docx';
    }
    
    getMimeType(): string {
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    
    createProcessor(): DocumentProcessor {
        return new WordProcessor();
    }
}

class DocumentTypeFactory {
    static fromExtension(extension: string): DocumentType {
        switch (extension.toLowerCase()) {
            case '.pdf':
                return new PdfDocument();
            case '.docx':
            case '.doc':
                return new WordDocument();
            default:
                throw new Error(`Unsupported document type: ${extension}`);
        }
    }
}

class Document {
    constructor(
        private filename: string,
        private type: DocumentType
    ) {}
    
    process(): void {
        const processor = this.type.createProcessor();
        processor.process(this.filename);
    }
    
    getMimeType(): string {
        return this.type.getMimeType();
    }
}

// Usage
const doc = new Document('report.pdf', DocumentTypeFactory.fromExtension('.pdf'));
doc.process();
```

#### State Pattern Integration

[Inference] This refactoring naturally leads to the State pattern when type codes represent states:

**Example:**

```csharp
// Before: Type code for order status
public class Order
{
    public const int PENDING = 0;
    public const int CONFIRMED = 1;
    public const int SHIPPED = 2;
    public const int DELIVERED = 3;
    public const int CANCELLED = 4;
    
    private int status;
    
    public void Confirm()
    {
        if (status == PENDING)
            status = CONFIRMED;
        else
            throw new InvalidOperationException("Cannot confirm order");
    }
    
    public void Ship()
    {
        if (status == CONFIRMED)
            status = SHIPPED;
        else
            throw new InvalidOperationException("Cannot ship order");
    }
}

// After: State classes with behavior
public abstract class OrderState
{
    public abstract void Confirm(Order order);
    public abstract void Ship(Order order);
    public abstract void Cancel(Order order);
    public abstract string GetStatusName();
}

public class PendingState : OrderState
{
    public override void Confirm(Order order)
    {
        order.SetState(new ConfirmedState());
    }
    
    public override void Ship(Order order)
    {
        throw new InvalidOperationException("Cannot ship pending order");
    }
    
    public override void Cancel(Order order)
    {
        order.SetState(new CancelledState());
    }
    
    public override string GetStatusName() => "Pending";
}

public class ConfirmedState : OrderState
{
    public override void Confirm(Order order)
    {
        // Already confirmed, do nothing or throw
    }
    
    public override void Ship(Order order)
    {
        order.SetState(new ShippedState());
    }
    
    public override void Cancel(Order order)
    {
        order.SetState(new CancelledState());
    }
    
    public override string GetStatusName() => "Confirmed";
}

public class Order
{
    private OrderState state;
    
    public Order()
    {
        state = new PendingState();
    }
    
    public void SetState(OrderState newState)
    {
        state = newState;
    }
    
    public void Confirm() => state.Confirm(this);
    public void Ship() => state.Ship(this);
    public void Cancel() => state.Cancel(this);
    public string GetStatus() => state.GetStatusName();
}
```

### When to Apply This Refactoring

#### Strong Indicators

Apply this refactoring when you observe:

- Multiple switch/if statements checking the same type code
- Type-specific behavior scattered across methods
- [Inference] Difficulty adding new types due to widespread changes needed
- Type codes that carry behavior, not just data classification
- String or integer "magic numbers" representing types

#### Example of Good Candidate

**Example:**

```ruby
class Vehicle
  BIKE = 1
  CAR = 2
  TRUCK = 3
  
  attr_accessor :type, :capacity
  
  def initialize(type, capacity)
    @type = type
    @capacity = capacity
  end
  
  def fuel_efficiency
    case @type
    when BIKE
      @capacity * 0.8
    when CAR
      @capacity * 0.5
    when TRUCK
      @capacity * 0.3
    end
  end
  
  def maintenance_cost
    case @type
    when BIKE
      100
    when CAR
      200
    when TRUCK
      500
    end
  end
  
  def registration_fee
    case @type
    when BIKE
      50
    when CAR
      150
    when TRUCK
      300
    end
  end
end
```

This is a strong candidate because:

- Same type code checked in multiple methods
- Each method contains type-specific calculations
- [Inference] Adding a new vehicle type requires modifying all methods

### When to Avoid This Refactoring

#### Keep Simple Type Codes When

**Key Points:**

- Type code is purely for data classification with no behavior
- Type checking occurs in only one location
- Types are stable and unlikely to change
- [Inference] The added complexity of classes outweighs benefits
- Performance is critical and method dispatch overhead matters

#### Example of Poor Candidate

**Example:**

```javascript
class DatabaseConfig {
    constructor(host, port, dbType) {
        this.host = host;
        this.port = port;
        this.dbType = dbType; // 'mysql', 'postgres', 'mongodb'
    }
    
    getConnectionString() {
        // Only place type is used, simple string formatting
        return `${this.dbType}://${this.host}:${this.port}`;
    }
}
```

[Inference] This scenario doesn't benefit from class hierarchy since the type code is used in a single location for simple string formatting.

### Variations and Related Refactorings

#### Replace Type Code with Subclasses

Instead of delegation, use inheritance directly:

**Example:**

```java
// Using delegation (composition)
public class Employee {
    private EmployeeType type;
    
    public int payAmount() {
        return type.payAmount(this);
    }
}

// Using inheritance (subclasses)
public abstract class Employee {
    public abstract int payAmount();
}

public class Engineer extends Employee {
    private int monthlySalary;
    
    @Override
    public int payAmount() {
        return monthlySalary;
    }
}

public class Salesman extends Employee {
    private int monthlySalary;
    private int commission;
    
    @Override
    public int payAmount() {
        return monthlySalary + commission;
    }
}
```

**Trade-offs:**

- Inheritance: Simpler structure, but less flexible
- Delegation: More flexible, allows runtime type changes, follows composition over inheritance principle

#### Replace Conditional with Polymorphism

This refactoring often follows Replace Type Code with Class:

**Example:**

```python
# After replacing type code, further refactor conditionals
class PaymentMethod:
    def process(self, amount):
        # Template method
        self.validate(amount)
        transaction_id = self.execute_payment(amount)
        self.log_transaction(transaction_id, amount)
        return transaction_id
    
    def validate(self, amount):
        if amount <= 0:
            raise ValueError("Amount must be positive")
    
    def execute_payment(self, amount):
        raise NotImplementedError()
    
    def log_transaction(self, transaction_id, amount):
        print(f"Transaction {transaction_id}: ${amount}")

class CreditCard(PaymentMethod):
    def __init__(self, card_number):
        self.card_number = card_number
    
    def execute_payment(self, amount):
        # Credit card specific logic
        return f"CC-{hash(self.card_number)}"

class PayPal(PaymentMethod):
    def __init__(self, email):
        self.email = email
    
    def execute_payment(self, amount):
        # PayPal specific logic
        return f"PP-{hash(self.email)}"

class BankTransfer(PaymentMethod):
    def __init__(self, account_number):
        self.account_number = account_number
    
    def execute_payment(self, amount):
        # Bank transfer specific logic
        return f"BT-{hash(self.account_number)}"
```

### Testing Considerations

#### Before Refactoring Tests

**Example:**

```java
@Test
public void testEngineerPay() {
    Employee emp = new Employee(Employee.ENGINEER);
    emp.setMonthlySalary(5000);
    assertEquals(5000, emp.payAmount());
}

@Test
public void testSalesmanPay() {
    Employee emp = new Employee(Employee.SALESMAN);
    emp.setMonthlySalary(3000);
    emp.setCommission(2000);
    assertEquals(5000, emp.payAmount());
}
```

#### After Refactoring Tests

**Example:**

```java
@Test
public void testEngineerPay() {
    Employee emp = new Employee(new Engineer());
    emp.setMonthlySalary(5000);
    assertEquals(5000, emp.payAmount());
}

@Test
public void testSalesmanPay() {
    Employee emp = new Employee(new Salesman());
    emp.setMonthlySalary(3000);
    emp.setCommission(2000);
    assertEquals(5000, emp.payAmount());
}

// New: Can test type classes independently
@Test
public void testEngineerTypeCalculation() {
    Engineer engineer = new Engineer();
    Employee emp = mock(Employee.class);
    when(emp.getMonthlySalary()).thenReturn(5000);
    
    assertEquals(5000, engineer.payAmount(emp));
}
```

### Benefits

**Key Points:**

- Eliminates duplicated conditional logic across methods
- Improves type safety by using the type system instead of primitives
- [Inference] Simplifies adding new types through class creation
- Enables polymorphism and cleaner abstractions
- Makes code more testable through isolated type classes
- [Inference] Reduces coupling between type-checking logic and business logic

### Drawbacks

**Key Points:**

- Increases number of classes in codebase
- [Inference] May introduce unnecessary complexity for simple cases
- [Inference] Can make code harder to trace through multiple classes
- [Inference] May have minor performance overhead from polymorphic dispatch
- Requires more initial design consideration

### Real-World Example: Shape Rendering System

**Example:**

```javascript
// Before: Type codes with conditionals
class Shape {
    constructor(type, params) {
        this.type = type; // 'circle', 'rectangle', 'triangle'
        this.params = params;
    }
    
    calculateArea() {
        switch(this.type) {
            case 'circle':
                return Math.PI * this.params.radius ** 2;
            case 'rectangle':
                return this.params.width * this.params.height;
            case 'triangle':
                return 0.5 * this.params.base * this.params.height;
            default:
                throw new Error('Unknown shape type');
        }
    }
    
    render(ctx) {
        switch(this.type) {
            case 'circle':
                ctx.beginPath();
                ctx.arc(this.params.x, this.params.y, this.params.radius, 0, 2 * Math.PI);
                ctx.stroke();
                break;
            case 'rectangle':
                ctx.strokeRect(this.params.x, this.params.y, 
                              this.params.width, this.params.height);
                break;
            case 'triangle':
                ctx.beginPath();
                ctx.moveTo(this.params.x1, this.params.y1);
                ctx.lineTo(this.params.x2, this.params.y2);
                ctx.lineTo(this.params.x3, this.params.y3);
                ctx.closePath();
                ctx.stroke();
                break;
        }
    }
}

// After: Class hierarchy with polymorphism
class Shape {
    calculateArea() {
        throw new Error('Subclass must implement calculateArea');
    }
    
    render(ctx) {
        throw new Error('Subclass must implement render');
    }
}

class Circle extends Shape {
    constructor(x, y, radius) {
        super();
        this.x = x;
        this.y = y;
        this.radius = radius;
    }
    
    calculateArea() {
        return Math.PI * this.radius ** 2;
    }
    
    render(ctx) {
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, 2 * Math.PI);
        ctx.stroke();
    }
}

class Rectangle extends Shape {
    constructor(x, y, width, height) {
        super();
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
    
    calculateArea() {
        return this.width * this.height;
    }
    
    render(ctx) {
        ctx.strokeRect(this.x, this.y, this.width, this.height);
    }
}

class Triangle extends Shape {
    constructor(x1, y1, x2, y2, x3, y3) {
        super();
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }
    
    calculateArea() {
        // Using coordinate formula
        return Math.abs((this.x1 * (this.y2 - this.y3) + 
                        this.x2 * (this.y3 - this.y1) + 
                        this.x3 * (this.y1 - this.y2)) / 2);
    }
    
    render(ctx) {
        ctx.beginPath();
        ctx.moveTo(this.x1, this.y1);
        ctx.lineTo(this.x2, this.y2);
        ctx.lineTo(this.x3, this.y3);
        ctx.closePath();
        ctx.stroke();
    }
}

// Usage
const shapes = [
    new Circle(100, 100, 50),
    new Rectangle(200, 200, 100, 60),
    new Triangle(300, 300, 350, 300, 325, 250)
];

shapes.forEach(shape => {
    console.log(`Area: ${shape.calculateArea()}`);
    shape.render(canvas.getContext('2d'));
});
```

**Output:**

```
Area: 7853.981633974483
Area: 6000
Area: 1250
```

### Migration Strategy

For large codebases, migrate incrementally:

1. **Identify all type code usage locations**
2. **Create type class hierarchy**
3. **Add new constructor accepting type object while keeping old one**
4. **Gradually migrate client code**
5. **Remove old type code constructor once migration complete**

**Example:**

```python
# Step 1: Support both approaches temporarily
class Employee:
    def __init__(self, type_param):
        if isinstance(type_param, EmployeeType):
            self.type = type_param
        elif isinstance(type_param, int):
            # Legacy support
            self.type = self._convert_code_to_type(type_param)
        else:
            raise ValueError("Invalid type parameter")
    
    def _convert_code_to_type(self, code):
        # Migration helper
        if code == 0:
            return Engineer()
        elif code == 1:
            return Salesman()
        elif code == 2:
            return Manager()
        raise ValueError(f"Unknown type code: {code}")

# Gradually update call sites
emp1 = Employee(0)  # Old way, still works
emp2 = Employee(Engineer())  # New way

# Eventually remove legacy support
```

**Conclusion:**

Replace Type Code with Class transforms primitive type indicators into rich object hierarchies, enabling polymorphism and improving maintainability. [Inference] This refactoring is most valuable when type codes govern behavior across multiple methods, as it centralizes type-specific logic and simplifies future extensions. However, [Inference] behavior may vary depending on implementation choices such as using inheritance versus composition, and the actual maintainability benefits depend on the complexity of type-specific logic in your system.

**Next Steps:**

- Identify type codes in your codebase that govern behavior across multiple methods
- Start with the type code that has the most scattered conditional logic
- Create abstract base class and concrete implementations for each type
- Write tests to verify behavior remains unchanged during refactoring
- Consider combining with Factory pattern for object creation
- Evaluate whether delegation or inheritance better fits your use case

---

## Replace Conditional with State/Strategy

Replace Conditional with State/Strategy is a refactoring technique that eliminates complex conditional logic by distributing behavior across polymorphic objects. This refactoring transforms code that uses conditionals to determine behavior into code where the behavior itself is encapsulated in separate classes, selected at runtime.

### Purpose and Context

When objects exhibit different behavior based on their state or type, conditional statements (if/else, switch/case) often proliferate throughout the codebase. This refactoring extracts each conditional branch into its own class, making the code more maintainable and extensible.

**Key benefits:**

- Eliminates duplicate conditional logic scattered across methods
- Makes adding new states/strategies easier without modifying existing code
- Improves testability by isolating each behavior variant
- Clarifies the relationship between state and behavior

### When to Apply This Refactoring

**Code smells indicating need:**

- Same conditional structure repeated in multiple methods
- Conditional logic based on type codes or state flags
- Behavior changes significantly based on object state
- Adding new cases requires changes in multiple locations
- Complex nested conditionals that obscure intent

**Appropriate scenarios:**

- Order processing with multiple statuses (pending, paid, shipped, delivered)
- Document editing with different states (draft, review, published)
- User accounts with varying permission levels
- Price calculations that vary by customer type or product category
- UI components that behave differently based on mode

### State Pattern vs. Strategy Pattern

Both patterns eliminate conditionals through polymorphism, but serve different purposes:

**State Pattern:**

- Models objects that change behavior when internal state changes
- State transitions may occur automatically within the object
- The object "is in" a particular state
- Example: TCP connection (listening, established, closed)

**Strategy Pattern:**

- Models interchangeable algorithms or behaviors
- Client code explicitly selects which strategy to use
- Strategies don't typically transition between each other
- Example: Sorting algorithms (quicksort, mergesort, heapsort)

[Inference] The choice between patterns depends on whether behavior changes represent internal state evolution (State) or external algorithm selection (Strategy). This distinction affects design but the refactoring mechanics are similar.

### Before: Conditional-Based Implementation

```java
public class Order {
    private String status; // "pending", "paid", "shipped", "delivered", "cancelled"
    private double amount;
    private String trackingNumber;
    
    public void processPayment(PaymentInfo payment) {
        if (status.equals("pending")) {
            // Process payment
            if (payment.isValid()) {
                status = "paid";
                System.out.println("Payment processed");
            }
        } else if (status.equals("paid")) {
            throw new IllegalStateException("Order already paid");
        } else if (status.equals("shipped") || status.equals("delivered")) {
            throw new IllegalStateException("Cannot pay shipped order");
        } else if (status.equals("cancelled")) {
            throw new IllegalStateException("Cannot pay cancelled order");
        }
    }
    
    public void ship(String trackingNum) {
        if (status.equals("pending")) {
            throw new IllegalStateException("Cannot ship unpaid order");
        } else if (status.equals("paid")) {
            this.trackingNumber = trackingNum;
            status = "shipped";
            System.out.println("Order shipped");
        } else if (status.equals("shipped")) {
            throw new IllegalStateException("Order already shipped");
        } else if (status.equals("delivered")) {
            throw new IllegalStateException("Order already delivered");
        } else if (status.equals("cancelled")) {
            throw new IllegalStateException("Cannot ship cancelled order");
        }
    }
    
    public void cancel() {
        if (status.equals("pending") || status.equals("paid")) {
            status = "cancelled";
            System.out.println("Order cancelled");
        } else if (status.equals("shipped") || status.equals("delivered")) {
            throw new IllegalStateException("Cannot cancel shipped order");
        } else if (status.equals("cancelled")) {
            throw new IllegalStateException("Order already cancelled");
        }
    }
    
    public void deliver() {
        if (status.equals("shipped")) {
            status = "delivered";
            System.out.println("Order delivered");
        } else {
            throw new IllegalStateException("Can only deliver shipped orders");
        }
    }
    
    public String getStatusDescription() {
        if (status.equals("pending")) {
            return "Order is pending payment";
        } else if (status.equals("paid")) {
            return "Order is paid, awaiting shipment";
        } else if (status.equals("shipped")) {
            return "Order shipped with tracking: " + trackingNumber;
        } else if (status.equals("delivered")) {
            return "Order has been delivered";
        } else if (status.equals("cancelled")) {
            return "Order was cancelled";
        }
        return "Unknown status";
    }
}
```

**Problems with this approach:**

- Conditional logic duplicated across all methods
- Adding a new status requires modifying multiple methods
- Each method must know about all possible states
- Easy to introduce inconsistencies when status transitions grow complex
- Testing requires covering all state combinations in one class

### Refactoring Steps

#### Step 1: Create State Interface

Define an interface representing all state-dependent operations:

```java
public interface OrderState {
    void processPayment(Order order, PaymentInfo payment);
    void ship(Order order, String trackingNumber);
    void cancel(Order order);
    void deliver(Order order);
    String getStatusDescription(Order order);
}
```

#### Step 2: Create Concrete State Classes

Extract each conditional branch into its own class:

```java
public class PendingOrderState implements OrderState {
    @Override
    public void processPayment(Order order, PaymentInfo payment) {
        if (payment.isValid()) {
            order.setState(new PaidOrderState());
            System.out.println("Payment processed");
        }
    }
    
    @Override
    public void ship(Order order, String trackingNumber) {
        throw new IllegalStateException("Cannot ship unpaid order");
    }
    
    @Override
    public void cancel(Order order) {
        order.setState(new CancelledOrderState());
        System.out.println("Order cancelled");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("Can only deliver shipped orders");
    }
    
    @Override
    public String getStatusDescription(Order order) {
        return "Order is pending payment";
    }
}

public class PaidOrderState implements OrderState {
    @Override
    public void processPayment(Order order, PaymentInfo payment) {
        throw new IllegalStateException("Order already paid");
    }
    
    @Override
    public void ship(Order order, String trackingNumber) {
        order.setTrackingNumber(trackingNumber);
        order.setState(new ShippedOrderState());
        System.out.println("Order shipped");
    }
    
    @Override
    public void cancel(Order order) {
        order.setState(new CancelledOrderState());
        System.out.println("Order cancelled");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("Can only deliver shipped orders");
    }
    
    @Override
    public String getStatusDescription(Order order) {
        return "Order is paid, awaiting shipment";
    }
}

public class ShippedOrderState implements OrderState {
    @Override
    public void processPayment(Order order, PaymentInfo payment) {
        throw new IllegalStateException("Cannot pay shipped order");
    }
    
    @Override
    public void ship(Order order, String trackingNumber) {
        throw new IllegalStateException("Order already shipped");
    }
    
    @Override
    public void cancel(Order order) {
        throw new IllegalStateException("Cannot cancel shipped order");
    }
    
    @Override
    public void deliver(Order order) {
        order.setState(new DeliveredOrderState());
        System.out.println("Order delivered");
    }
    
    @Override
    public String getStatusDescription(Order order) {
        return "Order shipped with tracking: " + order.getTrackingNumber();
    }
}

public class DeliveredOrderState implements OrderState {
    @Override
    public void processPayment(Order order, PaymentInfo payment) {
        throw new IllegalStateException("Cannot pay delivered order");
    }
    
    @Override
    public void ship(Order order, String trackingNumber) {
        throw new IllegalStateException("Order already delivered");
    }
    
    @Override
    public void cancel(Order order) {
        throw new IllegalStateException("Cannot cancel delivered order");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("Order already delivered");
    }
    
    @Override
    public String getStatusDescription(Order order) {
        return "Order has been delivered";
    }
}

public class CancelledOrderState implements OrderState {
    @Override
    public void processPayment(Order order, PaymentInfo payment) {
        throw new IllegalStateException("Cannot pay cancelled order");
    }
    
    @Override
    public void ship(Order order, String trackingNumber) {
        throw new IllegalStateException("Cannot ship cancelled order");
    }
    
    @Override
    public void cancel(Order order) {
        throw new IllegalStateException("Order already cancelled");
    }
    
    @Override
    public void deliver(Order order) {
        throw new IllegalStateException("Cannot deliver cancelled order");
    }
    
    @Override
    public String getStatusDescription(Order order) {
        return "Order was cancelled";
    }
}
```

#### Step 3: Refactor Context Class

Simplify the Order class to delegate to its current state:

```java
public class Order {
    private OrderState state;
    private double amount;
    private String trackingNumber;
    
    public Order() {
        this.state = new PendingOrderState();
    }
    
    public void processPayment(PaymentInfo payment) {
        state.processPayment(this, payment);
    }
    
    public void ship(String trackingNumber) {
        state.ship(this, trackingNumber);
    }
    
    public void cancel() {
        state.cancel(this);
    }
    
    public void deliver() {
        state.deliver(this);
    }
    
    public String getStatusDescription() {
        return state.getStatusDescription(this);
    }
    
    // Package-private method for states to transition
    void setState(OrderState newState) {
        this.state = newState;
    }
    
    // Getters and setters
    public String getTrackingNumber() {
        return trackingNumber;
    }
    
    void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }
    
    public double getAmount() {
        return amount;
    }
}
```

**Output:**

The refactored code eliminates all conditional logic from the Order class. Each state encapsulates its own behavior and valid transitions. Adding a new state (e.g., "returned") requires creating one new class without modifying existing code.

### Strategy Pattern Example

Unlike State, Strategy pattern models interchangeable algorithms selected by client code:

**Before:**

```python
class PriceCalculator:
    def calculate_price(self, base_price: float, customer_type: str) -> float:
        if customer_type == "regular":
            return base_price
        elif customer_type == "premium":
            return base_price * 0.9  # 10% discount
        elif customer_type == "vip":
            return base_price * 0.8  # 20% discount
        elif customer_type == "wholesale":
            if base_price > 1000:
                return base_price * 0.7  # 30% discount for bulk
            else:
                return base_price * 0.85  # 15% discount
        else:
            raise ValueError(f"Unknown customer type: {customer_type}")
    
    def apply_seasonal_discount(self, price: float, customer_type: str, 
                                season: str) -> float:
        if customer_type == "regular":
            if season == "summer":
                return price * 0.95
            return price
        elif customer_type == "premium":
            if season == "summer":
                return price * 0.93
            return price
        elif customer_type == "vip":
            return price  # VIPs already have max discount
        elif customer_type == "wholesale":
            return price  # Wholesale already has volume discount
        else:
            raise ValueError(f"Unknown customer type: {customer_type}")
```

**After refactoring to Strategy:**

```python
from abc import ABC, abstractmethod

class PricingStrategy(ABC):
    @abstractmethod
    def calculate_price(self, base_price: float) -> float:
        pass
    
    @abstractmethod
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        pass

class RegularPricingStrategy(PricingStrategy):
    def calculate_price(self, base_price: float) -> float:
        return base_price
    
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        if season == "summer":
            return price * 0.95
        return price

class PremiumPricingStrategy(PricingStrategy):
    def calculate_price(self, base_price: float) -> float:
        return base_price * 0.9  # 10% discount
    
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        if season == "summer":
            return price * 0.93
        return price

class VIPPricingStrategy(PricingStrategy):
    def calculate_price(self, base_price: float) -> float:
        return base_price * 0.8  # 20% discount
    
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        return price  # VIPs already have max discount

class WholesalePricingStrategy(PricingStrategy):
    def calculate_price(self, base_price: float) -> float:
        if base_price > 1000:
            return base_price * 0.7  # 30% discount for bulk
        else:
            return base_price * 0.85  # 15% discount
    
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        return price  # Wholesale already has volume discount

class PriceCalculator:
    def __init__(self, strategy: PricingStrategy):
        self.strategy = strategy
    
    def set_strategy(self, strategy: PricingStrategy):
        self.strategy = strategy
    
    def calculate_price(self, base_price: float) -> float:
        return self.strategy.calculate_price(base_price)
    
    def apply_seasonal_discount(self, price: float, season: str) -> float:
        return self.strategy.apply_seasonal_discount(price, season)

# Usage
regular_calculator = PriceCalculator(RegularPricingStrategy())
price = regular_calculator.calculate_price(100.0)  # 100.0

vip_calculator = PriceCalculator(VIPPricingStrategy())
price = vip_calculator.calculate_price(100.0)  # 80.0

# Can switch strategies dynamically
calculator = PriceCalculator(RegularPricingStrategy())
price = calculator.calculate_price(100.0)  # 100.0
calculator.set_strategy(PremiumPricingStrategy())
price = calculator.calculate_price(100.0)  # 90.0
```

### Handling Shared Logic

When states/strategies share common logic, extract it to avoid duplication:

```typescript
// Base class with shared logic
abstract class BaseOrderState implements OrderState {
    protected throwIfInvalidTransition(message: string): never {
        throw new IllegalStateError(message);
    }
    
    protected logStateChange(message: string): void {
        console.log(`[${new Date().toISOString()}] ${message}`);
    }
    
    // Default implementations that can be overridden
    processPayment(order: Order, payment: PaymentInfo): void {
        this.throwIfInvalidTransition("Cannot process payment in current state");
    }
    
    ship(order: Order, trackingNumber: string): void {
        this.throwIfInvalidTransition("Cannot ship order in current state");
    }
    
    cancel(order: Order): void {
        this.throwIfInvalidTransition("Cannot cancel order in current state");
    }
    
    deliver(order: Order): void {
        this.throwIfInvalidTransition("Cannot deliver order in current state");
    }
    
    abstract getStatusDescription(order: Order): string;
}

// Concrete states override only what they need
class PendingOrderState extends BaseOrderState {
    processPayment(order: Order, payment: PaymentInfo): void {
        if (payment.isValid()) {
            this.logStateChange("Payment processed");
            order.setState(new PaidOrderState());
        }
    }
    
    cancel(order: Order): void {
        this.logStateChange("Order cancelled");
        order.setState(new CancelledOrderState());
    }
    
    getStatusDescription(order: Order): string {
        return "Order is pending payment";
    }
}

class PaidOrderState extends BaseOrderState {
    ship(order: Order, trackingNumber: string): void {
        order.setTrackingNumber(trackingNumber);
        this.logStateChange("Order shipped");
        order.setState(new ShippedOrderState());
    }
    
    cancel(order: Order): void {
        this.logStateChange("Order cancelled");
        order.setState(new CancelledOrderState());
    }
    
    getStatusDescription(order: Order): string {
        return "Order is paid, awaiting shipment";
    }
}
```

### Testing Improvements

The refactored code is easier to test because each state/strategy is isolated:

```java
public class PaidOrderStateTest {
    private Order order;
    private PaidOrderState state;
    
    @Before
    public void setUp() {
        order = new Order();
        state = new PaidOrderState();
        order.setState(state);
    }
    
    @Test
    public void testShipTransitionsToPaidState() {
        state.ship(order, "TRACK123");
        
        assertEquals("TRACK123", order.getTrackingNumber());
        assertTrue(order.getState() instanceof ShippedOrderState);
    }
    
    @Test
    public void testCannotProcessPaymentWhenAlreadyPaid() {
        PaymentInfo payment = new PaymentInfo("1234");
        
        assertThrows(IllegalStateException.class, () -> {
            state.processPayment(order, payment);
        });
    }
    
    @Test
    public void testCancelTransitionsToCancelled() {
        state.cancel(order);
        
        assertTrue(order.getState() instanceof CancelledOrderState);
    }
}
```

Each state class can be tested independently without setting up complex conditional paths.

### State Persistence and Reconstruction

When persisting objects with state, store enough information to reconstruct the state:

```python
import json
from typing import Dict, Any

class Order:
    def __init__(self):
        self.state = PendingOrderState()
        self.amount = 0.0
        self.tracking_number = None
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'state_name': self.state.__class__.__name__,
            'amount': self.amount,
            'tracking_number': self.tracking_number
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Order':
        order = cls()
        order.amount = data['amount']
        order.tracking_number = data['tracking_number']
        
        # Reconstruct state from name
        state_name = data['state_name']
        state_class = globals()[state_name]
        order.state = state_class()
        
        return order
    
    def save_to_json(self, filename: str):
        with open(filename, 'w') as f:
            json.dump(self.to_dict(), f)
    
    @classmethod
    def load_from_json(cls, filename: str) -> 'Order':
        with open(filename, 'r') as f:
            data = json.load(f)
        return cls.from_dict(data)
```

[Inference] When reconstructing state objects from persistence, the code may need to re-establish relationships or validate that the persisted state is still valid in the current system version.

### Null Object Pattern Integration

Combine with Null Object pattern to handle missing strategies gracefully:

```java
public class NullPricingStrategy implements PricingStrategy {
    @Override
    public double calculatePrice(double basePrice) {
        return basePrice;  // No modification
    }
    
    @Override
    public double applySeasonalDiscount(double price, String season) {
        return price;  // No discount
    }
}

public class Customer {
    private PricingStrategy pricingStrategy;
    
    public Customer() {
        this.pricingStrategy = new NullPricingStrategy();
    }
    
    public void setPricingStrategy(PricingStrategy strategy) {
        this.pricingStrategy = strategy != null ? strategy : new NullPricingStrategy();
    }
    
    public double calculatePrice(double basePrice) {
        // No null check needed
        return pricingStrategy.calculatePrice(basePrice);
    }
}
```

### Performance Considerations

[Inference] The refactored code may create more objects than conditional logic, which could impact performance in extremely high-throughput scenarios. However, for most applications, the performance difference is negligible compared to the maintainability benefits.

**State object reuse:**

```java
// Singleton pattern for stateless states
public class PendingOrderState implements OrderState {
    private static final PendingOrderState INSTANCE = new PendingOrderState();
    
    private PendingOrderState() {}
    
    public static PendingOrderState getInstance() {
        return INSTANCE;
    }
    
    // ... state methods
}

// Usage
order.setState(PendingOrderState.getInstance());
```

[Inference] Reusing state instances reduces object allocation overhead when states don't maintain instance-specific data. This optimization is beneficial when state transitions occur frequently.

### Trade-offs and Considerations

**Advantages:**

- Single Responsibility: Each state/strategy class has one reason to change
- Open/Closed Principle: Easy to add new states/strategies without modifying existing code
- Eliminates conditional complexity from context class
- Each state/strategy is independently testable
- State transitions become explicit and visible

**Disadvantages:**

- Increases number of classes in the codebase
- State transition logic may become distributed across multiple classes
- Can be overkill for simple conditional logic (2-3 branches)
- Adds indirection that may make code flow harder to follow initially

**When not to apply [Inference]:**

- Conditional logic is genuinely simple (2-3 well-understood branches)
- Behavior variations are unlikely to change or expand
- The conditional is localized to a single method
- Performance is critical and object creation overhead matters

### Refactoring Process Recommendations

**Incremental approach:**

1. Start by refactoring one method at a time
2. Create state/strategy interface based on that method
3. Extract each conditional branch to a concrete class
4. Test thoroughly at each step
5. Gradually expand to other methods sharing the same conditional structure
6. Consolidate when multiple methods use the same states/strategies

**Identifying extraction candidates:**

- Look for the same conditional expression in multiple methods
- Find type codes or state flags that drive behavior
- Locate switch statements on type or enumeration values
- Search for deeply nested conditionals

**Conclusion**

Replace Conditional with State/Strategy transforms branching logic into polymorphic structures that are easier to understand, test, and extend. The State pattern handles objects whose behavior changes with internal state transitions, while the Strategy pattern encapsulates interchangeable algorithms. Both eliminate repetitive conditional logic and support the Open/Closed Principle by making new variations simple class additions rather than modifications to existing code.

[Inference] The pattern's suitability depends on code volatility and complexity. For stable, simple conditionals, the additional structure may not provide sufficient benefit. For evolving systems with growing behavioral variations, this refactoring typically improves long-term maintainability despite increasing class count.

**Next Steps**

- Identify classes in your codebase with repeated conditional structures
- Analyze whether behavior represents state transitions or algorithm selection
- Start with a small, well-understood example to practice the refactoring
- Establish naming conventions for state/strategy classes
- Consider using state machines or transition diagrams to document valid state transitions
- Review existing tests to ensure coverage of all state/strategy combinations

---

## Introduce Null Object

Introduce Null Object is a refactoring technique that eliminates null checks throughout your code by replacing null references with a special Null Object that provides default, do-nothing behavior. This object implements the same interface as real objects but performs neutral operations, allowing code to treat null and valid objects uniformly.

### Purpose and Context

This refactoring addresses the pervasive problem of null reference checking. When methods can return null or objects can be null, calling code must constantly check for null before invoking methods. These checks clutter the code, obscure the main logic, and create opportunities for NullPointerException or similar errors when checks are forgotten.

The Null Object pattern provides an alternative: instead of returning null, return an object that implements the expected interface but does nothing (or provides sensible defaults). Client code can then call methods on this object without null checks.

**Key Points:**

- Replaces null references with objects that provide neutral behavior
- Eliminates repetitive null checking throughout the codebase
- Implements the same interface as real objects
- Provides default or do-nothing implementations
- [Inference] Reduces the likelihood of null pointer exceptions by ensuring references are always valid objects

### When to Apply This Refactoring

Consider introducing a Null Object when:

- You have repeated null checks for the same type throughout your codebase
- Methods frequently return null to indicate "no object"
- Null checks obscure the primary logic of your methods
- You want to eliminate a category of potential runtime errors
- Default or neutral behavior makes sense for the absence of an object
- The cost of null checks (in terms of code clarity) outweighs the cost of maintaining a Null Object

### Mechanics of the Refactoring

The refactoring follows these steps:

1. **Identify the null checks:** Find code that repeatedly checks for null references
2. **Create a Null Object class:** Implement the same interface with neutral behavior
3. **Return Null Object instead of null:** Modify methods to return the Null Object
4. **Remove null checks:** Eliminate unnecessary null checks from client code
5. **Test thoroughly:** [Unverified] Ensure behavior remains correct—particularly that the Null Object provides appropriate defaults for your domain

### Before Refactoring: Code with Null Checks

```java
// Customer class that might be null
public class Customer {
    private String name;
    private String email;
    private int loyaltyPoints;
    
    public Customer(String name, String email, int loyaltyPoints) {
        this.name = name;
        this.email = email;
        this.loyaltyPoints = loyaltyPoints;
    }
    
    public String getName() {
        return name;
    }
    
    public String getEmail() {
        return email;
    }
    
    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }
    
    public void addLoyaltyPoints(int points) {
        this.loyaltyPoints += points;
    }
    
    public double getDiscount() {
        if (loyaltyPoints > 1000) {
            return 0.10;
        } else if (loyaltyPoints > 500) {
            return 0.05;
        }
        return 0.0;
    }
}

// Order processing with null checks
public class OrderProcessor {
    private CustomerRepository customerRepo;
    
    public OrderProcessor(CustomerRepository customerRepo) {
        this.customerRepo = customerRepo;
    }
    
    public void processOrder(String customerId, Order order) {
        Customer customer = customerRepo.findById(customerId);
        
        // Null check required
        if (customer != null) {
            double discount = customer.getDiscount();
            order.applyDiscount(discount);
            
            int points = calculatePoints(order.getTotal());
            customer.addLoyaltyPoints(points);
            
            sendConfirmation(customer.getEmail(), order);
        } else {
            // Handle null case
            order.applyDiscount(0.0);
            sendConfirmation("guest@example.com", order);
        }
    }
    
    public String getCustomerDisplay(String customerId) {
        Customer customer = customerRepo.findById(customerId);
        
        // Another null check
        if (customer != null) {
            return "Customer: " + customer.getName() + 
                   " (Points: " + customer.getLoyaltyPoints() + ")";
        } else {
            return "Guest Customer";
        }
    }
    
    public void sendPromotionalEmail(String customerId, String promotion) {
        Customer customer = customerRepo.findById(customerId);
        
        // Yet another null check
        if (customer != null) {
            emailService.send(customer.getEmail(), promotion);
        }
        // If null, simply don't send (silent failure)
    }
    
    private int calculatePoints(double total) {
        return (int) (total / 10);
    }
    
    private void sendConfirmation(String email, Order order) {
        // Email sending logic
    }
}
```

Notice the repetitive null checking pattern. Every time we retrieve a customer, we must check if it's null before using it.

### After Refactoring: With Null Object

```java
// Extract interface
public interface Customer {
    String getName();
    String getEmail();
    int getLoyaltyPoints();
    void addLoyaltyPoints(int points);
    double getDiscount();
    boolean isNull(); // Method to identify null objects
}

// Real customer implementation
public class RealCustomer implements Customer {
    private String name;
    private String email;
    private int loyaltyPoints;
    
    public RealCustomer(String name, String email, int loyaltyPoints) {
        this.name = name;
        this.email = email;
        this.loyaltyPoints = loyaltyPoints;
    }
    
    @Override
    public String getName() {
        return name;
    }
    
    @Override
    public String getEmail() {
        return email;
    }
    
    @Override
    public int getLoyaltyPoints() {
        return loyaltyPoints;
    }
    
    @Override
    public void addLoyaltyPoints(int points) {
        this.loyaltyPoints += points;
    }
    
    @Override
    public double getDiscount() {
        if (loyaltyPoints > 1000) {
            return 0.10;
        } else if (loyaltyPoints > 500) {
            return 0.05;
        }
        return 0.0;
    }
    
    @Override
    public boolean isNull() {
        return false;
    }
}

// Null Object implementation
public class NullCustomer implements Customer {
    @Override
    public String getName() {
        return "Guest";
    }
    
    @Override
    public String getEmail() {
        return "guest@example.com";
    }
    
    @Override
    public int getLoyaltyPoints() {
        return 0;
    }
    
    @Override
    public void addLoyaltyPoints(int points) {
        // Do nothing - guest customers don't accumulate points
    }
    
    @Override
    public double getDiscount() {
        return 0.0;
    }
    
    @Override
    public boolean isNull() {
        return true;
    }
}

// Simplified order processing - no null checks needed
public class OrderProcessor {
    private CustomerRepository customerRepo;
    
    public OrderProcessor(CustomerRepository customerRepo) {
        this.customerRepo = customerRepo;
    }
    
    public void processOrder(String customerId, Order order) {
        // Repository now returns NullCustomer instead of null
        Customer customer = customerRepo.findById(customerId);
        
        // No null check - works with both real and null customers
        double discount = customer.getDiscount();
        order.applyDiscount(discount);
        
        int points = calculatePoints(order.getTotal());
        customer.addLoyaltyPoints(points); // Safe even for NullCustomer
        
        sendConfirmation(customer.getEmail(), order);
    }
    
    public String getCustomerDisplay(String customerId) {
        Customer customer = customerRepo.findById(customerId);
        
        // No null check needed
        return "Customer: " + customer.getName() + 
               " (Points: " + customer.getLoyaltyPoints() + ")";
    }
    
    public void sendPromotionalEmail(String customerId, String promotion) {
        Customer customer = customerRepo.findById(customerId);
        
        // No null check - just use the customer
        emailService.send(customer.getEmail(), promotion);
    }
    
    private int calculatePoints(double total) {
        return (int) (total / 10);
    }
    
    private void sendConfirmation(String email, Order order) {
        // Email sending logic
    }
}

// Repository returns NullCustomer instead of null
public class CustomerRepository {
    private Map<String, Customer> customers = new HashMap<>();
    
    public Customer findById(String customerId) {
        Customer customer = customers.get(customerId);
        return customer != null ? customer : new NullCustomer();
    }
}
```

**Example Output:**

```
// With a real customer
processOrder("CUST001", order);
// Output: Order processed with 10% discount, points added to customer account

// With a null customer (guest)
processOrder("UNKNOWN", order);
// Output: Order processed with 0% discount, no points added (silently ignored)

getCustomerDisplay("CUST001");
// Output: "Customer: John Smith (Points: 1250)"

getCustomerDisplay("UNKNOWN");
// Output: "Customer: Guest (Points: 0)"
```

### Design Considerations for Null Objects

#### Providing Appropriate Default Behavior

The Null Object must provide behavior that makes sense for your domain. [Inference] This often means:

- Returning empty collections rather than null
- Returning zero or neutral values for numeric queries
- Performing no-op implementations for commands
- Returning sensible defaults for string values

```java
public interface Logger {
    void log(String message);
    void logError(String message);
    List<String> getRecentLogs();
}

public class FileLogger implements Logger {
    private List<String> logs = new ArrayList<>();
    
    @Override
    public void log(String message) {
        String entry = LocalDateTime.now() + ": " + message;
        logs.add(entry);
        writeToFile(entry);
    }
    
    @Override
    public void logError(String message) {
        String entry = LocalDateTime.now() + " ERROR: " + message;
        logs.add(entry);
        writeToFile(entry);
    }
    
    @Override
    public List<String> getRecentLogs() {
        return new ArrayList<>(logs);
    }
    
    private void writeToFile(String entry) {
        // File writing logic
    }
}

public class NullLogger implements Logger {
    @Override
    public void log(String message) {
        // Do nothing - logging is disabled
    }
    
    @Override
    public void logError(String message) {
        // Do nothing - error logging is disabled
    }
    
    @Override
    public List<String> getRecentLogs() {
        return Collections.emptyList(); // Return empty list, not null
    }
}
```

#### The isNull() Method Controversy

Including an `isNull()` method on the interface is debated:

**Arguments for including it:**

- Allows explicit null checks when genuinely needed
- Makes the pattern explicit and discoverable
- Useful for conditional logic that differs for null objects

**Arguments against including it:**

- Defeats the purpose if clients constantly call it
- Reintroduces the null-checking problem
- Violates the Liskov Substitution Principle [Inference]

```java
// With isNull() method - allows special handling when needed
public void processVIPOrder(String customerId, Order order) {
    Customer customer = customerRepo.findById(customerId);
    
    if (!customer.isNull() && customer.getLoyaltyPoints() > 5000) {
        order.applyVIPDiscount();
        assignPersonalShopper(customer);
    }
    
    // Continue with normal processing
    order.applyDiscount(customer.getDiscount());
}

// Alternative: Use specific types when null distinction matters
public void processVIPOrder(String customerId, Order order) {
    Customer customer = customerRepo.findById(customerId);
    
    if (customer instanceof RealCustomer) {
        RealCustomer realCustomer = (RealCustomer) customer;
        if (realCustomer.getLoyaltyPoints() > 5000) {
            order.applyVIPDiscount();
            assignPersonalShopper(realCustomer);
        }
    }
    
    order.applyDiscount(customer.getDiscount());
}
```

[Inference] The decision depends on your specific use case—if null distinction is rarely needed, omit `isNull()`. If checks are occasionally necessary, include it but use sparingly.

### Singleton vs. New Instance

You must decide whether to use a singleton Null Object or create new instances:

**Singleton approach:**

```java
public class NullCustomer implements Customer {
    // Singleton instance
    public static final NullCustomer INSTANCE = new NullCustomer();
    
    private NullCustomer() {} // Private constructor
    
    // Implementation methods...
}

// Usage
public Customer findById(String id) {
    Customer customer = customers.get(id);
    return customer != null ? customer : NullCustomer.INSTANCE;
}
```

**New instance approach:**

```java
public Customer findById(String id) {
    Customer customer = customers.get(id);
    return customer != null ? customer : new NullCustomer();
}
```

[Inference] Singleton is generally preferred when the Null Object is stateless, as it avoids unnecessary object creation and clearly communicates that all null customers are equivalent.

### Complex Example: File System Operations

```java
// Before refactoring - with null checks
public interface FileSystem {
    File findFile(String path);
}

public class File {
    private String name;
    private String content;
    private long size;
    
    public File(String name, String content) {
        this.name = name;
        this.content = content;
        this.size = content.length();
    }
    
    public String getName() {
        return name;
    }
    
    public String getContent() {
        return content;
    }
    
    public long getSize() {
        return size;
    }
    
    public void write(String newContent) {
        this.content = newContent;
        this.size = newContent.length();
    }
}

public class DocumentProcessor {
    private FileSystem fs;
    
    public String processDocument(String path) {
        File file = fs.findFile(path);
        
        if (file != null) {
            String content = file.getContent();
            String processed = content.toUpperCase();
            file.write(processed);
            return "Processed: " + file.getName();
        } else {
            return "File not found";
        }
    }
    
    public long getTotalSize(List<String> paths) {
        long total = 0;
        for (String path : paths) {
            File file = fs.findFile(path);
            if (file != null) {
                total += file.getSize();
            }
        }
        return total;
    }
    
    public void printFileInfo(String path) {
        File file = fs.findFile(path);
        
        if (file != null) {
            System.out.println("File: " + file.getName());
            System.out.println("Size: " + file.getSize() + " bytes");
            System.out.println("Content: " + file.getContent());
        } else {
            System.out.println("File not found at: " + path);
        }
    }
}
```

```java
// After refactoring - with Null Object
public interface File {
    String getName();
    String getContent();
    long getSize();
    void write(String content);
    boolean exists();
}

public class RealFile implements File {
    private String name;
    private String content;
    private long size;
    
    public RealFile(String name, String content) {
        this.name = name;
        this.content = content;
        this.size = content.length();
    }
    
    @Override
    public String getName() {
        return name;
    }
    
    @Override
    public String getContent() {
        return content;
    }
    
    @Override
    public long getSize() {
        return size;
    }
    
    @Override
    public void write(String newContent) {
        this.content = newContent;
        this.size = newContent.length();
    }
    
    @Override
    public boolean exists() {
        return true;
    }
}

public class NullFile implements File {
    private final String attemptedPath;
    
    public NullFile(String attemptedPath) {
        this.attemptedPath = attemptedPath;
    }
    
    @Override
    public String getName() {
        return "Not Found: " + attemptedPath;
    }
    
    @Override
    public String getContent() {
        return "";
    }
    
    @Override
    public long getSize() {
        return 0;
    }
    
    @Override
    public void write(String content) {
        // Silent no-op - writing to non-existent file does nothing
    }
    
    @Override
    public boolean exists() {
        return false;
    }
}

public class DocumentProcessor {
    private FileSystem fs;
    
    public String processDocument(String path) {
        File file = fs.findFile(path); // Never null
        
        if (file.exists()) {
            String content = file.getContent();
            String processed = content.toUpperCase();
            file.write(processed);
            return "Processed: " + file.getName();
        } else {
            return "File not found: " + file.getName();
        }
    }
    
    public long getTotalSize(List<String> paths) {
        long total = 0;
        for (String path : paths) {
            File file = fs.findFile(path);
            total += file.getSize(); // Returns 0 for NullFile
        }
        return total;
    }
    
    public void printFileInfo(String path) {
        File file = fs.findFile(path);
        
        // Can always call methods - no null check
        System.out.println("File: " + file.getName());
        System.out.println("Size: " + file.getSize() + " bytes");
        
        if (file.exists()) {
            System.out.println("Content: " + file.getContent());
        }
    }
}

public class FileSystemImpl implements FileSystem {
    private Map<String, File> files = new HashMap<>();
    
    @Override
    public File findFile(String path) {
        File file = files.get(path);
        return file != null ? file : new NullFile(path);
    }
}
```

**Example Output:**

```
// Real file processing
processDocument("/docs/report.txt");
// Output: "Processed: report.txt"

// Null file processing
processDocument("/docs/missing.txt");
// Output: "File not found: Not Found: /docs/missing.txt"

// Size calculation with mixed files
getTotalSize(Arrays.asList("/docs/file1.txt", "/docs/missing.txt", "/docs/file2.txt"));
// Output: 1250 (sum of existing files only, missing file contributes 0)
```

### Advantages of Introduce Null Object

**Eliminates Null Checks:** The primary benefit is removing repetitive null checking logic from client code.

**Reduces Errors:** [Inference] By eliminating null references, you remove an entire class of potential NullPointerException errors.

**Cleaner Code:** Client code focuses on business logic rather than defensive programming.

**Uniform Treatment:** Real and null objects can be used interchangeably through polymorphism.

**Explicit Defaults:** The Null Object makes default behavior explicit and centralized rather than scattered across null checks.

**Simplified Testing:** [Inference] Tests don't need to verify null handling in multiple places—the Null Object's behavior is tested once.

### Disadvantages and Limitations

**Hidden Failures:** Operations that silently do nothing may mask problems that should be detected.

```java
// This might hide a bug
public void updateCustomerEmail(String customerId, String newEmail) {
    Customer customer = customerRepo.findById(customerId);
    customer.setEmail(newEmail); // Silently fails for NullCustomer
}
```

**Inappropriate Defaults:** Not all scenarios have sensible default behavior. [Inference] Sometimes null genuinely means "missing required data" and should be handled explicitly.

**Interface Pollution:** If you add `isNull()` to the interface, you partially defeat the pattern's purpose and add a method that only makes sense for one implementation.

**Multiple Null Variants:** Complex domains might need different kinds of null behavior, leading to multiple Null Object classes.

**Performance Overhead:** Creating Null Objects (if not using singletons) adds object allocation overhead compared to null references.

**Debugging Difficulty:** [Inference] When problems occur, it may be harder to trace why a Null Object is being used instead of a real object.

### When Not to Use Null Object

This refactoring is inappropriate when:

**Null Means Error:** If null indicates an exceptional condition that should halt processing:

```java
// Bad use of Null Object
public User authenticate(String username, String password) {
    User user = userRepo.findByUsername(username);
    if (user.getPassword().equals(password)) {
        return user;
    }
    return new NullUser(); // Wrong! Authentication failure should be explicit
}

// Better approaches
public Optional<User> authenticate(String username, String password) {
    User user = userRepo.findByUsername(username);
    if (user != null && user.getPassword().equals(password)) {
        return Optional.of(user);
    }
    return Optional.empty();
}

// Or throw exception
public User authenticate(String username, String password) 
        throws AuthenticationException {
    // ...
}
```

**Different Null Contexts Need Different Behavior:** If the absence of an object should be handled differently in different contexts, a single Null Object won't work well.

**Null Carries Information:** If you need to distinguish between different reasons for absence, null (or Optional with different empty reasons) might be clearer.

**The Object Has Many Methods:** Creating meaningful null implementations for interfaces with many methods can be impractical.

### Comparison with Alternative Approaches

#### Optional Type

Modern languages provide Optional/Maybe types:

```java
// Using Optional instead of Null Object
public Optional<Customer> findById(String id) {
    return Optional.ofNullable(customers.get(id));
}

// Client code
public void processOrder(String customerId, Order order) {
    Optional<Customer> customerOpt = customerRepo.findById(customerId);
    
    double discount = customerOpt
        .map(Customer::getDiscount)
        .orElse(0.0);
    
    order.applyDiscount(discount);
    
    customerOpt.ifPresent(customer -> {
        int points = calculatePoints(order.getTotal());
        customer.addLoyaltyPoints(points);
    });
    
    String email = customerOpt
        .map(Customer::getEmail)
        .orElse("guest@example.com");
    
    sendConfirmation(email, order);
}
```

[Inference] Optional is generally preferred in modern codebases for optional values, while Null Object works better when default behavior should be transparent to clients.

#### Special Case Pattern

The Special Case pattern (from Martin Fowler's patterns) is essentially Null Object generalized to handle not just null, but any special case:

```java
// Multiple special cases
public interface Customer {
    double getDiscount();
    void addPoints(int points);
}

public class RegularCustomer implements Customer { /* ... */ }
public class VIPCustomer implements Customer { /* ... */ }
public class GuestCustomer implements Customer { /* Special case */ }
public class BannedCustomer implements Customer { /* Special case */ }
```

### Refactoring Steps in Detail

**Step 1: Identify the Null Context**

Find methods that return null and code that checks for null:

```java
// Methods returning null
public Customer findCustomer(String id) {
    return customers.get(id); // May return null
}

// Null checks scattered throughout
if (customer != null) {
    customer.doSomething();
}
```

**Step 2: Extract Interface (if needed)**

If your class isn't already behind an interface, extract one:

```java
// Before
public class Customer {
    public String getName() { ... }
    public void addPoints(int p) { ... }
}

// After
public interface Customer {
    String getName();
    void addPoints(int p);
}

public class RealCustomer implements Customer {
    public String getName() { ... }
    public void addPoints(int p) { ... }
}
```

**Step 3: Create Null Object Class**

Implement the interface with appropriate default behavior:

```java
public class NullCustomer implements Customer {
    @Override
    public String getName() {
        return "Guest";
    }
    
    @Override
    public void addPoints(int p) {
        // Do nothing
    }
}
```

**Step 4: Return Null Object Instead of Null**

Modify methods to return the Null Object:

```java
// Before
public Customer findCustomer(String id) {
    return customers.get(id); // Returns null if not found
}

// After
public Customer findCustomer(String id) {
    Customer customer = customers.get(id);
    return customer != null ? customer : new NullCustomer();
}
```

**Step 5: Remove Null Checks Gradually**

Systematically remove null checks from client code:

```java
// Before
if (customer != null) {
    String name = customer.getName();
    customer.addPoints(100);
}

// After
String name = customer.getName();
customer.addPoints(100);
```

**Step 6: Test Thoroughly**

[Unverified] Verify that all scenarios work correctly, especially edge cases where null was previously returned. Ensure default behaviors are appropriate for your domain.

### Real-World Application: Shopping Cart Discount Strategy

```java
// Before: Null checks everywhere
public interface DiscountStrategy {
    double calculateDiscount(double amount);
}

public class PercentageDiscount implements DiscountStrategy {
    private double percentage;
    
    public PercentageDiscount(double percentage) {
        this.percentage = percentage;
    }
    
    @Override
    public double calculateDiscount(double amount) {
        return amount * percentage;
    }
}

public class FixedAmountDiscount implements DiscountStrategy {
    private double fixedAmount;
    
    public FixedAmountDiscount(double fixedAmount) {
        this.fixedAmount = fixedAmount;
    }
    
    @Override
    public double calculateDiscount(double amount) {
        return Math.min(fixedAmount, amount);
    }
}

public class ShoppingCart {
    private List<Item> items = new ArrayList<>();
    private DiscountStrategy discount; // May be null
    
    public void setDiscount(DiscountStrategy discount) {
        this.discount = discount;
    }
    
    public double getTotal() {
        double subtotal = items.stream()
            .mapToDouble(Item::getPrice)
            .sum();
        
        // Null check required
        if (discount != null) {
            double discountAmount = discount.calculateDiscount(subtotal);
            return subtotal - discountAmount;
        }
        
        return subtotal;
    }
    
    public String getDiscountInfo() {
        // Another null check
        if (discount != null) {
            return "Discount applied";
        }
        return "No discount";
    }
    
    public void applyPromotion(Promotion promo) {
        // Yet another null check
        if (discount != null) {
            // Some logic
        } else {
            // Different logic
        }
    }
}
```

```java
// After: With Null Object
public interface DiscountStrategy {
    double calculateDiscount(double amount);
    String getDescription();
}

public class PercentageDiscount implements DiscountStrategy {
    private double percentage;
    
    public PercentageDiscount(double percentage) {
        this.percentage = percentage;
    }
    
    @Override
    public double calculateDiscount(double amount) {
        return amount * percentage;
    }
    
    @Override
    public String getDescription() {
        return String.format("%.0f%% discount", percentage * 100);
    }
}

public class FixedAmountDiscount implements DiscountStrategy {
    private double fixedAmount;
    
    public FixedAmountDiscount(double fixedAmount) {
        this.fixedAmount = fixedAmount;
    }
    
    @Override
    public double calculateDiscount(double amount) {
        return Math.min(fixedAmount, amount);
    }
    
    @Override
    public String getDescription() {
        return String.format("$%.2f off", fixedAmount);
    }
}

// Null Object - no discount
public class NoDiscount implements DiscountStrategy {
    public static final NoDiscount INSTANCE = new NoDiscount();
    
    private NoDiscount() {}
    
    @Override
    public double calculateDiscount(double amount) {
        return 0.0;
    }
    
    @Override
    public String getDescription() {
        return "No discount applied";
    }
}

public class ShoppingCart {
    private List<Item> items = new ArrayList<>();
    private DiscountStrategy discount = NoDiscount.INSTANCE; // Never null
    
    public void setDiscount(DiscountStrategy discount) {
        this.discount = discount != null ? discount : NoDiscount.INSTANCE;
    }
    
    public double getTotal() {
        double subtotal = items.stream()
            .mapToDouble(Item::getPrice)
            .sum();
        
        // No null check needed
        double discountAmount = discount.calculateDiscount(subtotal);
        return subtotal - discountAmount;
    }
    
    public String getDiscountInfo() {
        // No null check needed
        return discount.getDescription();
    }
    
    public void applyPromotion(Promotion promo) {
        // Work with discount directly - polymorphism handles the no-discount case
        DiscountStrategy newDiscount = promo.getDiscount();
        if (newDiscount.calculateDiscount(100) > discount.calculateDiscount(100)) {
            setDiscount(newDiscount);
        }
    }
}
```

**Example Output:**

```
ShoppingCart cart = new ShoppingCart();
cart.addItem(new Item("Book", 29.99));
cart.addItem(new Item("Pen", 2.99));

// No discount set - uses NoDiscount automatically
System.out.println(cart.getTotal()); // Output: 32.98
System.out.println(cart.getDiscountInfo()); // Output: "No discount applied"

// Apply percentage discount
cart.setDiscount(new PercentageDiscount(0.10));
System.out.println(cart.getTotal()); // Output: 29.68
System.out.println(cart.getDiscountInfo()); // Output: "10% discount"

// Apply fixed discount
cart.setDiscount(new FixedAmountDiscount(5.00));
System.out.println(cart.getTotal()); // Output: 27.98
System.out.println(cart.getDiscountInfo()); // Output: "$5.00 off"
```

### Testing Considerations

Null Objects should be tested like any other class:

```java
public class NullCustomerTest {
    @Test
    public void testGetName() {
        Customer customer = new NullCustomer();
        assertEquals("Guest", customer.getName());
    }
    
    @Test
    public void testAddPointsDoesNothing() {
        Customer customer = new NullCustomer();
        customer.addLoyaltyPoints(100);
        assertEquals(0, customer.getLoyaltyPoints());
    }
    
    @Test
    public void testGetDiscountReturnsZero() {
        Customer customer = new NullCustomer();
        assertEquals(0.0, customer.getDiscount(), 0.001);
    }
    
    @Test
    public void testIsNull() {
        Customer customer = new NullCustomer();
        assertTrue(customer.isNull());
    }
}
```

[Inference] Test that the Null Object provides appropriate defaults and that operations are safe (no exceptions thrown).

### Language-Specific Considerations

**Java:** Works well with interfaces. Consider using singleton pattern for stateless Null Objects. Java 8+ Optional provides an alternative approach.

**C#:** Similar to Java. Nullable reference types (C# 8.0+) provide compiler-checked null safety as an alternative.

**Python:** Duck typing makes this pattern very natural. Can also use None with careful handling or default parameters.

**JavaScript/TypeScript:** Works well, though undefined/null semantics differ. TypeScript's strict null checks provide compile-time safety.

**C++:** Can use pointers or references. Smart pointers (unique_ptr, shared_ptr) with custom deleters can implement this pattern.

### Relationship to Other Patterns

**Strategy Pattern:** Null Object is often a special case of Strategy, providing a "do nothing" strategy.

**Special Case Pattern:** Null Object is a specific instance of the more general Special Case pattern.

**State Pattern:** Null Object can represent a special state in state machines.

**Proxy Pattern:** [Inference] Both involve forwarding calls, but Proxy typically adds behavior while Null Object removes it.

**Conclusion:**

Introduce Null Object is a refactoring that trades null references for polymorphism. It eliminates repetitive null checking by providing objects that implement expected interfaces with neutral behavior. [Inference] This refactoring works best when default behavior is well-defined and consistent across your application. For scenarios requiring explicit handling of absence, consider alternatives like Optional types or exception handling.

The pattern significantly improves code readability and reduces error-prone null checks, but requires careful consideration of what constitutes appropriate default behavior in your domain. [Unverified] When applied judiciously, it can eliminate an entire category of bugs while making code more maintainable and easier to understand.

**Next Steps:**

- Audit your codebase for repetitive null checking patterns
- Identify types where default behavior is well-defined and consistent
- Start with low-risk refactorings in isolated modules
- Consider whether Optional types might be more appropriate for your use case
- Document the existence and purpose of Null Objects for future maintainers
- [Inference] Evaluate team familiarity with the pattern before widespread adoption

---

