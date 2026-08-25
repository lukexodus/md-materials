## Code Optimization Techniques


Effective code optimization combines algorithmic improvements, compiler optimizations, and hardware-aware programming.

**Compiler Optimization Flags**

```c
// optimization_example.c
#include <stdio.h>
#include <time.h>

volatile int global_counter = 0;  // volatile prevents optimization

void unoptimized_loop() {
    // This loop may be optimized away without volatile
    for (int i = 0; i < 1000000; i++) {
        global_counter++;
    }
}

// Function inlining candidate
inline int fast_multiply_by_power_of_2(int x, int power) {
    return x << power;  // Bit shift instead of multiplication
}

// Compiler optimization example
/*
Compilation flags for different optimization levels:
gcc -O0 program.c  # No optimization (debugging)
gcc -O1 program.c  # Basic optimization
gcc -O2 program.c  # Standard optimization (recommended)
gcc -O3 program.c  # Aggressive optimization
gcc -Os program.c  # Size optimization
gcc -Ofast program.c  # Speed optimization (may break standards compliance)
*/
```

**Data Structure Optimization**

```c
#include <stdio.h>
#include <stdint.h>

// Poor alignment - wastes memory
struct BadAlignment {
    char a;      // 1 byte
    int b;       // 4 bytes (3 bytes padding before this)
    char c;      // 1 byte (3 bytes padding after this)
    double d;    // 8 bytes
};  // Total: likely 24 bytes due to padding

// Good alignment - efficient memory usage
struct GoodAlignment {
    double d;    // 8 bytes
    int b;       // 4 bytes
    char a;      // 1 byte
    char c;      // 1 byte (2 bytes padding after this)
};  // Total: likely 16 bytes

// Bit fields for space optimization
struct StatusFlags {
    unsigned int flag1 : 1;
    unsigned int flag2 : 1;
    unsigned int flag3 : 1;
    unsigned int reserved : 5;
    unsigned int error_code : 8;
    unsigned int version : 16;
};  // Total: 4 bytes instead of separate integers

void demonstrate_struct_optimization() {
    printf("Structure size comparison:\n");
    printf("BadAlignment: %zu bytes\n", sizeof(struct BadAlignment));
    printf("GoodAlignment: %zu bytes\n", sizeof(struct GoodAlignment));
    printf("StatusFlags: %zu bytes\n", sizeof(struct StatusFlags));
}
```

**CPU-Friendly Code Patterns**

```c
#include <stdio.h>
#include <stdlib.h>

// Branch prediction friendly code
void branch_prediction_example(int *arr, int size, int threshold) {
    int count_above = 0;
    int count_below = 0;
    
    // Predictable branches - better performance
    // First pass: count elements
    for (int i = 0; i < size; i++) {
        if (arr[i] > threshold) count_above++;
        else count_below++;
    }
    
    // Alternative: branchless programming using ternary operator
    int branchless_count = 0;
    for (int i = 0; i < size; i++) {
        branchless_count += (arr[i] > threshold) ? 1 : 0;
    }
}

// Memory prefetching hints (GCC specific)
void memory_prefetch_example(int *data, int size) {
    for (int i = 0; i < size; i++) {
        // Hint to prefetch next cache line
        __builtin_prefetch(&data[i + 64], 0, 3);  // Read prefetch
        
        // Process current data
        data[i] = data[i] * 2 + 1;
    }
}

// SIMD-friendly data layout
typedef struct {
    float x[1000];  // Array of X coordinates
    float y[1000];  // Array of Y coordinates
    float z[1000];  // Array of Z coordinates
} SOA_Points;  // Structure of Arrays

typedef struct {
    float x, y, z;
} Point;

typedef struct {
    Point points[1000];  // Array of structures
} AOS_Points;  // Array of Structures

void demonstrate_data_layout() {
    printf("SOA vs AOS for SIMD optimization:\n");
    printf("SOA (Structure of Arrays): Better for vectorization\n");
    printf("AOS (Array of Structures): Better for object-oriented access\n");
    // [Inference] SIMD instructions can process SOA more efficiently
}
```

**Performance Measurement Framework**

```c
#include <stdio.h>
#include <time.h>
#include <sys/time.h>

typedef struct {
    struct timeval start;
    struct timeval end;
    const char *name;
} Timer;

void timer_start(Timer *timer, const char *name) {
    timer->name = name;
    gettimeofday(&timer->start, NULL);
}

void timer_end(Timer *timer) {
    gettimeofday(&timer->end, NULL);
    
    long seconds = timer->end.tv_sec - timer->start.tv_sec;
    long microseconds = timer->end.tv_usec - timer->start.tv_usec;
    double elapsed = seconds + microseconds / 1000000.0;
    
    printf("%s: %.6f seconds\n", timer->name, elapsed);
}

// Benchmark different approaches
void benchmark_example() {
    const int size = 1000000;
    int *data = malloc(size * sizeof(int));
    Timer timer;
    
    // Initialize data
    for (int i = 0; i < size; i++) {
        data[i] = i;
    }
    
    // Benchmark approach 1
    timer_start(&timer, "Sequential access");
    volatile long sum1 = 0;
    for (int i = 0; i < size; i++) {
        sum1 += data[i];
    }
    timer_end(&timer);
    
    // Benchmark approach 2 - unrolled loop
    timer_start(&timer, "Unrolled loop");
    volatile long sum2 = 0;
    int i;
    for (i = 0; i < size - 3; i += 4) {
        sum2 += data[i] + data[i+1] + data[i+2] + data[i+3];
    }
    for (; i < size; i++) {
        sum2 += data[i];
    }
    timer_end(&timer);
    
    free(data);
}

int main() {
    demonstrate_struct_optimization();
    benchmark_example();
    return 0;
}
```

**Key Points**

- Memory layout directly affects program performance and memory usage
- Stack memory is faster but limited; heap memory is flexible but requires manual management
- Algorithm choice has the greatest impact on performance - O(n) vs O(n²) matters more than micro-optimizations
- Profiling tools like gprof, valgrind, and perf help identify actual bottlenecks
- Modern compilers perform extensive optimizations; profile before manual optimization
- Cache-friendly data access patterns significantly improve performance
- Structure alignment and padding affect both memory usage and access speed
- Branch prediction and memory prefetching can provide substantial performance gains

**Output** of optimization efforts should always be measured and validated through profiling to ensure improvements are real and significant.

**Conclusion** Effective memory management and performance optimization require understanding both theoretical concepts and practical measurement techniques. Focus on algorithmic improvements first, then use profiling tools to identify specific bottlenecks before applying micro-optimizations.

**Next Steps** for advanced performance work include learning about specific CPU architectures, SIMD programming, parallel processing with threads, and advanced profiling techniques like hardware performance counters.

---

