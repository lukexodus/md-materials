## **Standard Exceptions**


C++ provides several **standard exceptions** in the `<exception>` header. These exceptions are derived from the **`std::exception`** class and are used to handle common runtime errors.

---

### **Hierarchy of Standard Exceptions**

All standard exceptions are derived from `std::exception`:

```
std::exception
│── std::logic_error
│   ├── std::domain_error
│   ├── std::invalid_argument
│   ├── std::length_error
│   ├── std::out_of_range
│── std::runtime_error
│   ├── std::overflow_error
│   ├── std::underflow_error
│   ├── std::range_error
│   ├── std::system_error
│── std::bad_alloc
│── std::bad_cast
│── std::bad_typeid
│── std::bad_exception
```

---

