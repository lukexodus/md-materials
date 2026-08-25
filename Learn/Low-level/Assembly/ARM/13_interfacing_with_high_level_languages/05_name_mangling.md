## Name Mangling


Name mangling (or name decoration) is the encoding of function names to support features like function overloading, namespaces, and type information in compiled object files.

**C language (no mangling):**

```c
// C source
int add(int a, int b) {
    return a + b;
}

void process_data(void);
```

```asm
; Assembly implementation
; C uses simple names - no mangling
.global add
.type add, %function
add:
    ADD W0, W0, W1              ; a + b
    RET

.global process_data
.type process_data, %function
process_data:
    ; Implementation
    RET

; Calling from assembly
call_c_function:
    MOV W0, #5
    MOV W1, #10
    BL add                      ; Direct call, no name mangling
    RET
```

**C++ language (mangled names):**

```cpp
// C++ source
int add(int a, int b) {
    return a + b;
}

float add(float a, float b) {
    return a + b;
}

namespace math {
    int multiply(int a, int b) {
        return a * b;
    }
}

class Calculator {
public:
    int subtract(int a, int b);
};
```

```asm
; Mangled names (GCC/Clang Itanium ABI)
; int add(int, int) -> _Z3addii
.global _Z3addii
.type _Z3addii, %function
_Z3addii:
    ADD W0, W0, W1
    RET

; float add(float, float) -> _Z3addff
.global _Z3addff
.type _Z3addff, %function
_Z3addff:
    FADD S0, S0, S1
    RET

; math::multiply(int, int) -> _ZN4math8multiplyEii
.global _ZN4math8multiplyEii
.type _ZN4math8multiplyEii, %function
_ZN4math8multiplyEii:
    MUL W0, W0, W1
    RET

; Calculator::subtract(int, int) -> _ZN10Calculator8subtractEii
.global _ZN10Calculator8subtractEii
.type _ZN10Calculator8subtractEii, %function
_ZN10Calculator8subtractEii:
    ; X0 = this pointer
    ; W1 = a, W2 = b
    SUB W0, W1, W2
    RET
```

**Extern "C" linkage:**

```cpp
// C++ header for assembly functions
extern "C" {
    int asm_add(int a, int b);
    void asm_process(void);
}

// C++ implementation calling assembly
int use_asm() {
    return asm_add(5, 10);
}
```

```asm
; Assembly with C linkage (no mangling)
.global asm_add
.type asm_add, %function
asm_add:
    ADD W0, W0, W1
    RET

.global asm_process
.type asm_process, %function
asm_process:
    ; Implementation
    RET

; Calling C++ function from assembly
; Must use mangled name
.extern _Z10use_asm_v              ; void use_asm()

call_cpp:
    BL _Z10use_asm_v
    RET
```

**Name mangling patterns (Itanium C++ ABI):**

```
Pattern: _Z + <function-name-length> + <function-name> + <parameter-types>

Basic types:
  v = void
  b = bool
  c = char
  a = signed char
  h = unsigned char
  s = short
  t = unsigned short
  i = int
  j = unsigned int
  l = long
  m = unsigned long
  x = long long
  y = unsigned long long
  f = float
  d = double
  e = long double

Pointer: P + <type>        (e.g., Pi = int*)
Reference: R + <type>      (e.g., Ri = int&)
Const: K + <type>          (e.g., Ki = const int)

Namespaces: N + <namespace-length> + <namespace-name> + ... + E

Examples:
  void func()                    -> _Z4funcv
  int func(int)                  -> _Z4funci
  int func(int, float)           -> _Z4funcif
  int func(int*)                 -> _Z4funcPi
  int func(const int&)           -> _Z4funcRKi
  ns::func(int)                  -> _ZN2ns4funcEi
  Class::method(int)             -> _ZN5Class6methodEi
  operator+(int, int)            -> _Zpl1ii
```

**Practical name mangling handling:**

```asm
; Method 1: Use extern "C" wrapper
; C++ header
extern "C" {
    void my_asm_function(int x);
}

; Assembly (no mangling needed)
.global my_asm_function
my_asm_function:
    ; W0 = x
    RET

; Method 2: Get mangled name from object file
; Compile C++ to object file, then inspect:
; nm -C myfile.o | grep function_name

; Method 3: Use assembly in C++ namespace
.global _ZN6MyCode12process_dataEi
_ZN6MyCode12process_dataEi:    ; MyCode::process_data(int)
    RET
```

