## **Access Specifiers (public, private, protected)**


Access specifiers in **C++** determine the **visibility** and **accessibility** of class members (variables and functions). The three main access specifiers are:

1. **`public`** – Accessible **everywhere**.
2. **`private`** – Accessible **only inside the same class**.
3. **`protected`** – Accessible **inside the class** and **derived classes**.

---

### **1. `public` Access Specifier**

- Members declared as `public` can be accessed **from anywhere** (inside or outside the class).
- Used when you want data/functions to be **openly accessible**.

**Example:**

```cpp
#include <iostream>
using namespace std;

class Car {
public:
    string brand;
    
    void showBrand() {
        cout << "Car brand: " << brand << endl;
    }
};

int main() {
    Car myCar;
    myCar.brand = "Toyota";  // Accessible outside the class
    myCar.showBrand();       // Accessible outside the class
    return 0;
}
```

**Output:**

```
Car brand: Toyota
```

---

### **2. `private` Access Specifier**

- Members declared as `private` **cannot** be accessed directly outside the class.
- Only **member functions** of the **same class** can access them.
- Used to **hide sensitive data** and enforce **encapsulation**.

**Example:**

```cpp
#include <iostream>
using namespace std;

class BankAccount {
private:
    double balance;  // Private member

public:
    void setBalance(double amount) {
        balance = amount;  // Accessible inside the class
    }

    void showBalance() {
        cout << "Account balance: $" << balance << endl;
    }
};

int main() {
    BankAccount account;
    // account.balance = 500;  // ❌ Error: Cannot access private member
    account.setBalance(500);   // ✅ Allowed via public function
    account.showBalance();     // ✅ Allowed
    return 0;
}
```

**Output:**

```
Account balance: $500
```

---

### **3. `protected` Access Specifier**

- Similar to `private`, but **allows access in derived (child) classes**.
- Used when **inheritance** is involved.

**Example:**

```cpp
#include <iostream>
using namespace std;

class Animal {
protected:
    string type;  // Protected member

public:
    void setType(string t) {
        type = t;
    }
};

class Dog : public Animal {
public:
    void showType() {
        cout << "Animal type: " << type << endl;  // Accessible in derived class
    }
};

int main() {
    Dog myDog;
    myDog.setType("Mammal");
    myDog.showType();
    // myDog.type = "Bird";  // ❌ Error: 'type' is protected
    return 0;
}
```

**Output:**

```
Animal type: Mammal
```

---

### **Comparison Table**

|Access Specifier|Accessible Inside Class|Accessible in Derived Class|Accessible Outside Class|
|---|---|---|---|
|`public`|✅ Yes|✅ Yes|✅ Yes|
|`private`|✅ Yes|❌ No|❌ No|
|`protected`|✅ Yes|✅ Yes|❌ No|

---

### **When to Use Which?**

✅ **Use `private`** when:

- You want to **hide implementation details** and **protect data**.
- You **don’t want** direct modification of variables.

✅ **Use `public`** when:

- You want to **allow external access** to a function or variable.
- You need **getter/setter** methods.

✅ **Use `protected`** when:

- You are **designing an inheritance hierarchy**.
- You want to **allow derived classes to access** base class members **without exposing them** publicly.

---

