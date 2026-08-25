## Encapsulation


Encapsulation is achieved by bundling the data (attributes) and methods (behaviors) that operate on the data into a single unit (class). Access specifiers control the access levels of class members.

**Implementation**

```cpp
class Car {
private:
    std::string brand; // Private member
    int year;          // Private member
public:
    void setBrand(std::string b) {
        brand = b;     // Accessible within the class
    }
    std::string getBrand() {
        return brand;  // Accessible within the class
    }
};

int main() {
    Car myCar;
    myCar.setBrand("Toyota");  // Public method accessing private member
    std::cout << "Brand: " << myCar.getBrand() << std::endl;  // Public method accessing private member
    return 0;
}
```

- **Private**: Members are accessible only within the class.
- **Public**: Members are accessible from outside the class.
- **Protected**: Members are accessible within the class and its derived classes.

---

