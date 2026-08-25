## Unit Testing with testing Package


Go's `testing` package provides the core infrastructure for writing and executing tests. The framework follows conventions that make tests discoverable and executable through standard tooling.

**Key Points:**

- Test files must end with `_test.go` and be in the same package as the code being tested
- Test functions must start with `Test` and accept `*testing.T` parameter
- Use `t.Error`, `t.Errorf`, `t.Fatal`, and `t.Fatalf` for test assertions
- Tests run in parallel by default unless explicitly serialized
- The `go test` command discovers and executes all tests in a package

**Example:**

```go
// mathutils.go
package mathutils

import "errors"

func Add(a, b int) int {
    return a + b
}

func Divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

func IsEven(n int) bool {
    return n%2 == 0
}
```

```go
// mathutils_test.go
package mathutils

import (
    "math"
    "testing"
)

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    expected := 5
    
    if result != expected {
        t.Errorf("Add(2, 3) = %d; want %d", result, expected)
    }
}

func TestDivide(t *testing.T) {
    // Test normal division
    result, err := Divide(10.0, 2.0)
    if err != nil {
        t.Errorf("Divide(10.0, 2.0) returned unexpected error: %v", err)
    }
    if result != 5.0 {
        t.Errorf("Divide(10.0, 2.0) = %f; want 5.0", result)
    }
    
    // Test division by zero
    _, err = Divide(10.0, 0.0)
    if err == nil {
        t.Error("Divide(10.0, 0.0) should return an error")
    }
}

func TestIsEven(t *testing.T) {
    if !IsEven(4) {
        t.Error("IsEven(4) should return true")
    }
    
    if IsEven(5) {
        t.Error("IsEven(5) should return false")
    }
}

// Subtests for organized testing
func TestMathOperations(t *testing.T) {
    t.Run("Addition", func(t *testing.T) {
        if Add(1, 2) != 3 {
            t.Error("1 + 2 should equal 3")
        }
    })
    
    t.Run("EvenNumbers", func(t *testing.T) {
        evens := []int{0, 2, 4, 6, 8}
        for _, num := range evens {
            t.Run(fmt.Sprintf("IsEven(%d)", num), func(t *testing.T) {
                if !IsEven(num) {
                    t.Errorf("IsEven(%d) should return true", num)
                }
            })
        }
    })
}
```

The testing framework integrates with Go's toolchain, providing detailed output, parallel execution, and integration with coverage analysis and benchmarking tools.

