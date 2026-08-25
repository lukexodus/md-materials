## Callback Functions


Callback functions are functions passed as arguments to other functions, enabling event-driven programming and customizable behavior.

**Event Handler Example**

```c
#include <stdio.h>

typedef void (*EventCallback)(int event_data);

void button_clicked(int button_id) {
    printf("Button %d was clicked\n", button_id);
}

void key_pressed(int key_code) {
    printf("Key with code %d was pressed\n", key_code);
}

void register_callback(EventCallback callback, int data) {
    // Simulate event occurrence
    printf("Event triggered: ");
    callback(data);
}

int main() {
    register_callback(button_clicked, 1);
    register_callback(key_pressed, 65); // ASCII 'A'
    
    return 0;
}
```

**Generic Sorting with Callback**

```c
#include <stdio.h>
#include <stdlib.h>

typedef int (*CompareFunc)(const void *a, const void *b);

int compare_int_asc(const void *a, const void *b) {
    int ia = *(const int*)a;
    int ib = *(const int*)b;
    return (ia > ib) - (ia < ib);
}

int compare_int_desc(const void *a, const void *b) {
    return compare_int_asc(b, a);
}

void print_array(int arr[], int size) {
    for (int i = 0; i < size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}

int main() {
    int numbers[] = {64, 34, 25, 12, 22, 11, 90};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    
    printf("Original: ");
    print_array(numbers, size);
    
    qsort(numbers, size, sizeof(int), compare_int_asc);
    printf("Ascending: ");
    print_array(numbers, size);
    
    qsort(numbers, size, sizeof(int), compare_int_desc);
    printf("Descending: ");
    print_array(numbers, size);
    
    return 0;
}
```

