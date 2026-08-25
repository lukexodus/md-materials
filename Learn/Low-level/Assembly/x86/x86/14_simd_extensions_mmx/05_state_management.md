## State Management


**EMMS** - Empty MMX State

```nasm
emms                  ; Mark FPU registers as empty
```

This instruction must be called before transitioning from MMX code back to x87 FPU operations. EMMS sets all FPU tag word bits to empty (11b), restoring normal FPU operation. Failure to call EMMS results in FPU exceptions or incorrect calculations.

