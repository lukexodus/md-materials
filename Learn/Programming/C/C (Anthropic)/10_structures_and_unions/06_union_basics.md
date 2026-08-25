## Union Basics


Unions are composite data types that allow different data types to share the same memory location. All union members occupy the same memory space, with the union size determined by its largest member. Only one member can contain a valid value at any given time, as storing a value in one member may overwrite values in other members.

Union declaration syntax resembles structures but uses the `union` keyword. Member access uses the same dot and arrow operators as structures. Unions provide memory efficiency when storing alternative data types, but require careful programming to track which member currently contains valid data.

Common applications include variant records, type-punning for low-level programming, and protocol handling where fields can represent different data types depending on context. Unions enable efficient memory usage in scenarios where multiple data representations are mutually exclusive.

**Key points:**

- Members share same memory location
- Size determined by largest member
- Only one member valid at a time
- Same access syntax as structures
- Efficient for alternative data types

**Example:**

```c
#include <stdio.h>
#include <string.h>

// Basic union definition
union Data {
    int integer;
    float floating;
    char character;
    char string[20];
};

// Union for type variant
union Number {
    int as_int;
    float as_float;
    double as_double;
};

// Union with enumeration for type tracking
enum DataType {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING
};

struct Variant {
    enum DataType type;
    union {
        int int_value;
        float float_value;
        char string_value[50];
    } data;
};

// Union for bit manipulation
union IntBytes {
    int value;
    unsigned char bytes[4];
};

int main() {
    // Basic union usage
    union Data d;
    
    printf("Union size: %zu bytes\n", sizeof(union Data));
    printf("Integer member size: %zu bytes\n", sizeof(d.integer));
    printf("Float member size: %zu bytes\n", sizeof(d.floating));
    printf("String member size: %zu bytes\n", sizeof(d.string));
    
    // Store different types (only one valid at a time)
    d.integer = 42;
    printf("\nStored integer: %d\n", d.integer);
    printf("Float interpretation: %f\n", d.floating);  // Invalid data
    
    d.floating = 3.14159f;
    printf("\nStored float: %f\n", d.floating);
    printf("Integer interpretation: %d\n", d.integer);  // Invalid data
    
    strcpy(d.string, "Hello");
    printf("\nStored string: %s\n", d.string);
    printf("Integer interpretation: %d\n", d.integer);  // Invalid data
    
    // Using union with type tracking
    struct Variant vars[3];
    
    // Store different types with proper tracking
    vars[0].type = TYPE_INT;
    vars[0].data.int_value = 100;
    
    vars[1].type = TYPE_FLOAT;
    vars[1].data.float_value = 2.718f;
    
    vars[2].type = TYPE_STRING;
    strcpy(vars[2].data.string_value, "World");
    
    // Access with type checking
    for (int i = 0; i < 3; i++) {
        printf("\nVariant %d: ", i + 1);
        switch (vars[i].type) {
            case TYPE_INT:
                printf("Integer = %d", vars[i].data.int_value);
                break;
            case TYPE_FLOAT:
                printf("Float = %.3f", vars[i].data.float_value);
                break;
            case TYPE_STRING:
                printf("String = %s", vars[i].data.string_value);
                break;
        }
        printf("\n");
    }
    
    // Union for bit manipulation and type punning
    union IntBytes int_bytes;
    int_bytes.value = 0x12345678;
    
    printf("\nInteger value: 0x%08X\n", int_bytes.value);
    printf("Individual bytes: ");
    for (int i = 0; i < 4; i++) {
        printf("0x%02X ", int_bytes.bytes[i]);
    }
    printf("\n");
    
    // Modify individual bytes
    int_bytes.bytes[0] = 0xFF;
    printf("After modifying first byte: 0x%08X\n", int_bytes.value);
    
    // Union in structures for flexible data
    struct Message {
        int type;
        union {
            struct {
                int x, y;
            } coordinates;
            struct {
                char text[30];
            } message;
            struct {
                float temperature;
                int humidity;
            } sensor_data;
        } payload;
    };
    
    struct Message msg1 = {1, .payload.coordinates = {10, 20}};
    struct Message msg2 = {2, .payload.message = {"System Alert"}};
    struct Message msg3 = {3, .payload.sensor_data = {23.5f, 65}};
    
    printf("\nMessage 1 (coordinates): (%d, %d)\n", 
           msg1.payload.coordinates.x, msg1.payload.coordinates.y);
    printf("Message 2 (text): %s\n", msg2.payload.message.text);
    printf("Message 3 (sensor): %.1f°C, %d%% humidity\n",
           msg3.payload.sensor_data.temperature, 
           msg3.payload.sensor_data.humidity);
    
    return 0;
}
```

