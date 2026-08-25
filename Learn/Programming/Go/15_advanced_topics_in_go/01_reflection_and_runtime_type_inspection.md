## Reflection and Runtime Type Inspection


Go's reflection capabilities enable runtime type inspection, value manipulation, and dynamic code execution through the `reflect` package.

### Basic Reflection Operations

```go
package main

import (
    "fmt"
    "reflect"
    "unsafe"
)

type User struct {
    ID       int    `json:"id" db:"user_id" validate:"required"`
    Name     string `json:"name" db:"username" validate:"required,min=2"`
    Email    string `json:"email" db:"email_addr" validate:"required,email"`
    IsActive bool   `json:"is_active" db:"active"`
    profile  string // unexported field
}

func (u User) GetDisplayName() string {
    return fmt.Sprintf("%s (%s)", u.Name, u.Email)
}

func (u *User) SetName(name string) {
    u.Name = name
}

func basicReflection() {
    user := User{
        ID:       1,
        Name:     "John Doe",
        Email:    "john@example.com",
        IsActive: true,
    }
    
    // Get type and value
    userType := reflect.TypeOf(user)
    userValue := reflect.ValueOf(user)
    
    fmt.Printf("Type: %s, Kind: %s\n", userType.Name(), userType.Kind())
    fmt.Printf("NumField: %d, NumMethod: %d\n", userType.NumField(), userType.NumMethod())
    
    // Inspect fields
    for i := 0; i < userType.NumField(); i++ {
        field := userType.Field(i)
        value := userValue.Field(i)
        
        fmt.Printf("Field %d: %s (type: %s, exported: %t)\n",
            i, field.Name, field.Type, field.PkgPath == "")
        
        if value.CanInterface() {
            fmt.Printf("  Value: %v\n", value.Interface())
        }
        
        // Inspect tags
        if tag := field.Tag; tag != "" {
            fmt.Printf("  JSON tag: %s\n", tag.Get("json"))
            fmt.Printf("  DB tag: %s\n", tag.Get("db"))
            fmt.Printf("  Validation tag: %s\n", tag.Get("validate"))
        }
    }
    
    // Inspect methods
    for i := 0; i < userType.NumMethod(); i++ {
        method := userType.Method(i)
        fmt.Printf("Method %d: %s (type: %s)\n", i, method.Name, method.Type)
    }
}
```

### Dynamic Value Manipulation

```go
func dynamicManipulation() {
    user := User{ID: 1, Name: "Jane", Email: "jane@example.com"}
    userValue := reflect.ValueOf(&user).Elem() // Get addressable value
    
    // Modify fields dynamically
    nameField := userValue.FieldByName("Name")
    if nameField.IsValid() && nameField.CanSet() {
        nameField.SetString("Jane Smith")
    }
    
    idField := userValue.FieldByName("ID")
    if idField.IsValid() && idField.CanSet() {
        idField.SetInt(42)
    }
    
    // Access unexported fields (requires unsafe operations)
    profileField := userValue.FieldByName("profile")
    if profileField.IsValid() {
        // Cannot set directly, need unsafe
        profilePtr := unsafe.Pointer(profileField.UnsafeAddr())
        *(*string)(profilePtr) = "secret profile"
    }
    
    fmt.Printf("Modified user: %+v\n", user)
}
```

### Method Invocation

```go
func methodInvocation() {
    user := User{ID: 1, Name: "Bob", Email: "bob@example.com"}
    userValue := reflect.ValueOf(&user)
    
    // Call method with pointer receiver
    setNameMethod := userValue.MethodByName("SetName")
    if setNameMethod.IsValid() {
        args := []reflect.Value{reflect.ValueOf("Bob Johnson")}
        setNameMethod.Call(args)
    }
    
    // Call method with value receiver
    userValue = reflect.ValueOf(user)
    getDisplayMethod := userValue.MethodByName("GetDisplayName")
    if getDisplayMethod.IsValid() {
        results := getDisplayMethod.Call(nil)
        if len(results) > 0 {
            fmt.Printf("Display name: %s\n", results[0].String())
        }
    }
}
```

### Generic Reflection Utilities

```go
// Generic field mapper using reflection
func MapFields(src, dst interface{}) error {
    srcValue := reflect.ValueOf(src)
    dstValue := reflect.ValueOf(dst)
    
    if srcValue.Kind() == reflect.Ptr {
        srcValue = srcValue.Elem()
    }
    if dstValue.Kind() != reflect.Ptr || dstValue.Elem().Kind() != reflect.Struct {
        return fmt.Errorf("dst must be a pointer to struct")
    }
    
    dstValue = dstValue.Elem()
    srcType := srcValue.Type()
    dstType := dstValue.Type()
    
    for i := 0; i < dstType.NumField(); i++ {
        dstField := dstType.Field(i)
        dstFieldValue := dstValue.Field(i)
        
        if !dstFieldValue.CanSet() {
            continue
        }
        
        // Find matching field in source
        srcFieldValue, found := findField(srcValue, srcType, dstField.Name)
        if !found {
            continue
        }
        
        if srcFieldValue.Type().AssignableTo(dstFieldValue.Type()) {
            dstFieldValue.Set(srcFieldValue)
        }
    }
    
    return nil
}

func findField(structValue reflect.Value, structType reflect.Type, fieldName string) (reflect.Value, bool) {
    for i := 0; i < structType.NumField(); i++ {
        field := structType.Field(i)
        if field.Name == fieldName {
            return structValue.Field(i), true
        }
    }
    return reflect.Value{}, false
}

// JSON-like serialization using reflection
func SerializeToMap(v interface{}) map[string]interface{} {
    result := make(map[string]interface{})
    value := reflect.ValueOf(v)
    
    if value.Kind() == reflect.Ptr {
        value = value.Elem()
    }
    
    if value.Kind() != reflect.Struct {
        return result
    }
    
    valueType := value.Type()
    for i := 0; i < valueType.NumField(); i++ {
        field := valueType.Field(i)
        fieldValue := value.Field(i)
        
        if !fieldValue.CanInterface() {
            continue
        }
        
        key := field.Name
        if jsonTag := field.Tag.Get("json"); jsonTag != "" && jsonTag != "-" {
            key = strings.Split(jsonTag, ",")[0]
        }
        
        result[key] = fieldValue.Interface()
    }
    
    return result
}
```

**Key Points:**

- Reflection enables runtime type inspection and value manipulation
- Performance overhead makes reflection unsuitable for performance-critical code
- `reflect.Value.CanSet()` determines if values can be modified
- Method calls require proper receiver types and argument matching

