## Virtual Environments


A **Python virtual environment** is an isolated workspace where you can install and manage dependencies separately from the global Python installation. This helps avoid conflicts between different projects.

---

### **Creating a Virtual Environment**

1. **Navigate to your project directory**:
    
    ```sh
    cd path/to/your/project
    ```
    
2. **Create the virtual environment**:
    
    ```sh
    python -m venv myenv
    ```
    
    - `myenv` is the folder where the virtual environment will be created.
        

---

### **Activating the Virtual Environment**

- **Windows (Command Prompt)**:
    
    ```sh
    myenv\Scripts\activate
    ```
    
- **Windows (PowerShell)**:
    
    ```sh
    myenv\Scripts\Activate.ps1
    ```
    
- **Mac/Linux**:
    
    ```sh
    source myenv/bin/activate
    ```
    

---

### **Installing Packages Inside the Virtual Environment**

Once activated, install dependencies using `pip`:

```sh
pip install package_name
```

Example:

```sh
pip install requests
```

To install multiple packages from a `requirements.txt` file:

```sh
pip install -r requirements.txt
```

---

### **Deactivating the Virtual Environment**

To exit the virtual environment:

```sh
deactivate
```

---

### **Deleting a Virtual Environment**

Simply delete the `myenv` folder:

```sh
rm -rf myenv  # Mac/Linux
rd /s /q myenv  # Windows
```

---

### **Checking Installed Packages**

To see installed dependencies within the virtual environment:

```sh
pip list
```

To save installed packages for reuse:

```sh
pip freeze > requirements.txt
```

---

### **Why Use a Virtual Environment?**

✅ **Avoid conflicts** between different projects  
✅ **Keep dependencies isolated**  
✅ **Ensure reproducibility** (especially for deployment)  
✅ **Work on different Python versions easily**


---

