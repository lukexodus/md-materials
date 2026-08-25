## Arrays of Structures


Arrays of structures create collections of related records, enabling storage and manipulation of multiple instances of the same structure type. Declaration follows standard array syntax with the structure type replacing primitive types. Initialization can use nested brace notation with each array element containing its own structure initializer.

Access to array elements uses array indexing followed by member access operators. Iteration through structure arrays commonly uses loops to process each element. Functions can accept arrays of structures as parameters, following the same rules as arrays of primitive types.

Arrays of structures efficiently represent databases, tables, and collections of related objects. Common applications include student records, inventory items, coordinate points, and any scenario requiring multiple instances of the same data pattern.

**Key points:**

- Collections of structure instances
- Standard array syntax with structure type
- Nested brace initialization
- Array indexing plus member access
- Efficient for database-like collections

**Example:**

```c
#include <stdio.h>
#include <string.h>

struct Car {
    int year;
    char make[20];
    char model[25];
    double price;
    int mileage;
};

struct Point {
    double x;
    double y;
};

void print_car(struct Car c) {
    printf("%d %s %s - $%.2f (%d miles)\n", 
           c.year, c.make, c.model, c.price, c.mileage);
}

double calculate_distance(struct Point p1, struct Point p2) {
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;
    return sqrt(dx * dx + dy * dy);
}

struct Car* find_cheapest_car(struct Car cars[], int count) {
    struct Car* cheapest = &cars[0];
    for (int i = 1; i < count; i++) {
        if (cars[i].price < cheapest->price) {
            cheapest = &cars[i];
        }
    }
    return cheapest;
}

int main() {
    // Array of structures initialization
    struct Car inventory[] = {
        {2020, "Toyota", "Camry", 25000.0, 15000},
        {2019, "Honda", "Civic", 22000.0, 18000},
        {2021, "Ford", "Mustang", 32000.0, 8000},
        {2018, "Nissan", "Altima", 18000.0, 25000},
        {2022, "BMW", "X3", 45000.0, 5000}
    };
    
    int car_count = sizeof(inventory) / sizeof(inventory[0]);
    
    // Display all cars
    printf("Car Inventory:\n");
    for (int i = 0; i < car_count; i++) {
        printf("%d. ", i + 1);
        print_car(inventory[i]);
    }
    
    // Find and display cheapest car
    struct Car* cheapest = find_cheapest_car(inventory, car_count);
    printf("\nCheapest car: ");
    print_car(*cheapest);
    
    // Array of points for geometric calculations
    struct Point polygon[] = {
        {0.0, 0.0},
        {3.0, 0.0},
        {3.0, 4.0},
        {0.0, 4.0}
    };
    
    int point_count = sizeof(polygon) / sizeof(polygon[0]);
    
    printf("\nPolygon vertices:\n");
    for (int i = 0; i < point_count; i++) {
        printf("Point %d: (%.1f, %.1f)\n", i + 1, polygon[i].x, polygon[i].y);
    }
    
    // Calculate perimeter
    double perimeter = 0.0;
    for (int i = 0; i < point_count; i++) {
        int next = (i + 1) % point_count;
        perimeter += calculate_distance(polygon[i], polygon[next]);
    }
    printf("Polygon perimeter: %.2f\n", perimeter);
    
    // Modify array elements
    inventory[0].price -= 2000.0;  // Discount first car
    inventory[0].mileage += 1000;  // Update mileage
    
    printf("\nUpdated first car: ");
    print_car(inventory[0]);
    
    // Search for specific car
    printf("\nCars under $25,000:\n");
    for (int i = 0; i < car_count; i++) {
        if (inventory[i].price < 25000.0) {
            print_car(inventory[i]);
        }
    }
    
    return 0;
}
```

