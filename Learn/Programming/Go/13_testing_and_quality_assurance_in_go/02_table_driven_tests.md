## Table-driven Tests


Table-driven tests are a Go idiom that allows testing multiple scenarios with the same test logic, improving maintainability and reducing code duplication.

**Key Points:**

- Define test cases as slices of structs containing input and expected output
- Single test function iterates through all cases
- Each test case can be run as a subtest for better isolation
- Easy to add new test cases without duplicating test logic
- Clear separation between test data and test execution logic

**Example:**

```go
package mathutils

import (
    "fmt"
    "testing"
)

func TestAddTableDriven(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed signs", -2, 3, 1},
        {"zero values", 0, 5, 5},
        {"large numbers", 1000000, 2000000, 3000000},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

func TestDivideTableDriven(t *testing.T) {
    tests := []struct {
        name      string
        a, b      float64
        expected  float64
        wantError bool
    }{
        {"normal division", 10.0, 2.0, 5.0, false},
        {"division by zero", 10.0, 0.0, 0.0, true},
        {"negative numbers", -10.0, -2.0, 5.0, false},
        {"fractional result", 7.0, 2.0, 3.5, false},
        {"very small numbers", 0.000001, 0.000001, 1.0, false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := Divide(tt.a, tt.b)
            
            if tt.wantError {
                if err == nil {
                    t.Errorf("Divide(%f, %f) should return an error", tt.a, tt.b)
                }
                return
            }
            
            if err != nil {
                t.Errorf("Divide(%f, %f) returned unexpected error: %v", tt.a, tt.b, err)
                return
            }
            
            if result != tt.expected {
                t.Errorf("Divide(%f, %f) = %f; want %f", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}

// Complex table-driven test with multiple validation steps
func TestStringProcessor(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        options  ProcessOptions
        expected ProcessResult
        wantErr  bool
    }{
        {
            name:  "uppercase conversion",
            input: "hello world",
            options: ProcessOptions{
                ToUpper:     true,
                TrimSpaces:  false,
                ReplaceChar: "",
            },
            expected: ProcessResult{
                Output:    "HELLO WORLD",
                ByteCount: 11,
                WordCount: 2,
            },
            wantErr: false,
        },
        {
            name:  "trim and replace",
            input: "  hello-world  ",
            options: ProcessOptions{
                ToUpper:     false,
                TrimSpaces:  true,
                ReplaceChar: "-",
            },
            expected: ProcessResult{
                Output:    "hello world",
                ByteCount: 11,
                WordCount: 2,
            },
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := ProcessString(tt.input, tt.options)
            
            if tt.wantErr {
                if err == nil {
                    t.Error("ProcessString() should return an error")
                }
                return
            }
            
            if err != nil {
                t.Errorf("ProcessString() returned unexpected error: %v", err)
                return
            }
            
            if result.Output != tt.expected.Output {
                t.Errorf("Output = %q; want %q", result.Output, tt.expected.Output)
            }
            
            if result.ByteCount != tt.expected.ByteCount {
                t.Errorf("ByteCount = %d; want %d", result.ByteCount, tt.expected.ByteCount)
            }
            
            if result.WordCount != tt.expected.WordCount {
                t.Errorf("WordCount = %d; want %d", result.WordCount, tt.expected.WordCount)
            }
        })
    }
}
```

Table-driven tests excel at testing functions with clear inputs and outputs, validation logic, and edge case scenarios. They provide excellent documentation of expected behavior and make regression testing straightforward.

