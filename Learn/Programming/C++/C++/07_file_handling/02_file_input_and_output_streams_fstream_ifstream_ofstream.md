## **File Input and Output Streams (fstream, ifstream, ofstream)**


C++ provides **file handling** through the `<fstream>` library, which allows reading from and writing to files using **streams**.

### **Types of File Streams**

✔️ `ifstream` (input file stream) → **Reads from files**.  
✔️ `ofstream` (output file stream) → **Writes to files**.  
✔️ `fstream` (file stream) → **Reads and writes to files**.

---

### **Writing to a File (`ofstream`)**

Use `ofstream` to create and write to a file.

**Example: Writing Data to a File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    ofstream file("example.txt");  // Open file for writing
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }
    
    file << "Hello, C++ File I/O!\n";  // Write to file
    file << "This is a second line.\n";

    file.close();  // Close file
    cout << "Data written successfully." << endl;
}
```

**Creates `example.txt` with:**

```
Hello, C++ File I/O!
This is a second line.
```

---

### **Reading from a File (`ifstream`)**

Use `ifstream` to read data from a file.

**Example: Reading a File Line by Line**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    ifstream file("example.txt");  // Open file for reading
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    string line;
    while (getline(file, line)) {  // Read line by line
        cout << line << endl;
    }

    file.close();  // Close file
}
```

**Output (if `example.txt` exists):**

```
Hello, C++ File I/O!
This is a second line.
```

---

### **Reading and Writing (`fstream`)**

Use `fstream` for both **reading and writing**.

**Example: Appending Text to a File**

```cpp
#include <iostream>
#include <fstream>
using namespace std;

int main() {
    fstream file("example.txt", ios::in | ios::out | ios::app);  // Open for read & append
    if (!file) {
        cout << "Error opening file!" << endl;
        return 1;
    }

    file << "Appending new data.\n";  // Append new text
    file.seekg(0);  // Move to beginning to read

    string line;
    cout << "Updated file contents:\n";
    while (getline(file, line)) {
        cout << line << endl;
    }

    file.close();  // Close file
}
```

**Updated `example.txt`:**

```
Hello, C++ File I/O!
This is a second line.
Appending new data.
```

---

### **File Open Modes (`ios::` Flags)**

You can control file operations using **modes**:  
✔️ `ios::in` → Open for reading.  
✔️ `ios::out` → Open for writing (overwrites existing content).  
✔️ `ios::app` → Append to file without overwriting.  
✔️ `ios::trunc` → Truncate (delete existing content).  
✔️ `ios::binary` → Open file in binary mode.

**Example: Writing Without Overwriting**

```cpp
ofstream file("data.txt", ios::app);  // Append mode
```

---

### **Checking File Status**

Use `.fail()` or `.is_open()` to check if a file opened successfully.

**Example: Checking if a File Exists Before Opening**

```cpp
ifstream file("missing.txt");
if (!file.is_open()) {
    cout << "File does not exist!" << endl;
}
```

---

### **Key Points**

✅ **`ofstream` writes**, **`ifstream` reads**, **`fstream` does both**.  
✅ Always **close files** after use with `.close()`.  
✅ Use **`ios::app`** to prevent overwriting files.  
✅ Use **`.fail()` or `.is_open()`** to check if a file exists.

***

