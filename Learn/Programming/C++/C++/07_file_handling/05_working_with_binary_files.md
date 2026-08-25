## **Working with Binary Files**


Binary files store data in **raw binary format**, making them **faster and more efficient** than text files. C++ provides **`fstream`**, **`ifstream`**, and **`ofstream`** for handling binary files using **`ios::binary`** mode.

---

### **Writing to a Binary File**

Use `ofstream` with `ios::binary` to write raw data.

**Example: Writing a Structure to a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp = {"John Doe", 30, 55000.75};

    ofstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));  // Write binary data
    file.close();

    cout << "Data written to binary file." << endl;
}
```

**Creates `employee.dat` containing binary data.**

---

### **Reading from a Binary File**

Use `ifstream` with `ios::binary` to read raw data.

**Example: Reading a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp;

    ifstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.read(reinterpret_cast<char*>(&emp), sizeof(emp));  // Read binary data
    file.close();

    cout << "Name: " << emp.name << "\nAge: " << emp.age << "\nSalary: " << emp.salary << endl;
}
```

**Output:**

```
Name: John Doe
Age: 30
Salary: 55000.75
```

---

### **Appending Data to a Binary File**

Use `ios::app | ios::binary` to add new data **without overwriting**.

**Example: Appending Another Employee Record**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp = {"Jane Smith", 28, 62000.50};

    ofstream file("employee.dat", ios::app | ios::binary);  // Append mode
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));
    file.close();

    cout << "Data appended to binary file." << endl;
}
```

---

### **Reading Multiple Records from a Binary File**

Since binary files store **raw memory data**, we must read multiple records in a loop.

**Example: Reading All Employees from a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    Employee emp;

    ifstream file("employee.dat", ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    while (file.read(reinterpret_cast<char*>(&emp), sizeof(emp))) {  // Read each record
        cout << "Name: " << emp.name << "\nAge: " << emp.age << "\nSalary: " << emp.salary << endl;
        cout << "-----------------------------" << endl;
    }

    file.close();
}
```

---

### **Random Access in Binary Files**

✔️ **Seek to a specific position** using `.seekg()` (for reading) or `.seekp()` (for writing).  
✔️ **Tell the current position** using `.tellg()` (for reading) or `.tellp()` (for writing).

**Example: Modifying a Specific Record in a Binary File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

struct Employee {
    char name[50];
    int age;
    double salary;
};

int main() {
    fstream file("employee.dat", ios::in | ios::out | ios::binary);
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    int recordNum = 1;  // Modify the second record (0-based index)
    Employee emp = {"Alice Brown", 35, 75000.00};

    file.seekp(recordNum * sizeof(Employee), ios::beg);  // Move to specific record
    file.write(reinterpret_cast<char*>(&emp), sizeof(emp));

    file.close();
    cout << "Record updated successfully." << endl;
}
```

---

### **Key Points**

✅ **Binary files store raw data** → Faster and more efficient.  
✅ Use `ios::binary` mode with `ifstream`, `ofstream`, or `fstream`.  
✅ `write()` and `read()` handle binary data.  
✅ `seekg()`, `seekp()` for **random access**.  
✅ Suitable for **structured data storage** like records, game saves, and serialized objects. 🚀

***

