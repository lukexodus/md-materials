## Recursion


Recursion occurs when a function calls itself directly or indirectly. Recursive solutions require a base case to terminate recursion and a recursive case that progresses toward the base case. Each recursive call creates a new stack frame with its own set of local variables and parameters.

The call stack grows with each recursive call and shrinks as functions return. Deep recursion can exhaust stack memory, causing stack overflow. Tail recursion, where the recursive call is the last operation, can be optimized by some compilers but C does not guarantee tail call optimization.

Recursive solutions often provide elegant implementations for problems with recursive mathematical definitions, such as factorial calculation, Fibonacci sequences, tree traversal, and divide-and-conquer algorithms. However, recursive solutions may have higher time and space complexity compared to iterative approaches.

**Key points:**

- Function calls itself directly or indirectly
- Requires base case for termination
- Each call creates new stack frame
- Can exhaust stack memory if too deep
- Often elegant for naturally recursive problems

**Example:**

```c
#include <stdio.h>

// Simple recursion: factorial
long factorial(int n) {
    if (n <= 1) {
        return 1;  // Base case
    }
    return n * factorial(n - 1);  // Recursive case
}

// Fibonacci sequence
long fibonacci(int n) {
    if (n <= 1) {
        return n;  // Base cases: fib(0)=0, fib(1)=1
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// Binary search (recursive)
int binary_search(int arr[], int left, int right, int target) {
    if (left > right) {
        return -1;  // Base case: not found
    }
    
    int mid = left + (right - left) / 2;
    
    if (arr[mid] == target) {
        return mid;  // Base case: found
    }
    
    if (arr[mid] > target) {
        return binary_search(arr, left, mid - 1, target);
    } else {
        return binary_search(arr, mid + 1, right, target);
    }
}

// Tower of Hanoi
void hanoi(int n, char from, char to, char aux) {
    if (n == 1) {
        printf("Move disk 1 from %c to %c\n", from, to);
        return;
    }
    
    hanoi(n - 1, from, aux, to);
    printf("Move disk %d from %c to %c\n", n, from, to);
    hanoi(n - 1, aux, to, from);
}

// Mutual recursion example
int is_even(int n);
int is_odd(int n);

int is_even(int n) {
    if (n == 0) return 1;
    return is_odd(n - 1);
}

int is_odd(int n) {
    if (n == 0) return 0;
    return is_even(n - 1);
}

int main() {
    // Factorial demonstration
    printf("Factorial of 5: %ld\n", factorial(5));
    
    // Fibonacci demonstration
    printf("Fibonacci sequence: ");
    for (int i = 0; i < 10; i++) {
        printf("%ld ", fibonacci(i));
    }
    printf("\n");
    
    // Binary search demonstration
    int sorted_array[] = {1, 3, 5, 7, 9, 11, 13, 15};
    int size = sizeof(sorted_array) / sizeof(sorted_array[0]);
    int index = binary_search(sorted_array, 0, size - 1, 7);
    printf("Binary search for 7: found at index %d\n", index);
    
    // Tower of Hanoi
    printf("Tower of Hanoi for 3 disks:\n");
    hanoi(3, 'A', 'C', 'B');
    
    // Mutual recursion
    printf("Is 8 even? %s\n", is_even(8) ? "Yes" : "No");
    printf("Is 7 odd? %s\n", is_odd(7) ? "Yes" : "No");
    
    return 0;
}
```

