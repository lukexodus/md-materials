## Mode Selection Strategy


### Thumb-2 as Default

[Inference] Modern ARM Cortex-M processors (M0, M3, M4, M7) only support Thumb-2, making it the only choice. Cortex-A processors support both ARM and Thumb-2 modes.

**General Recommendations:**

- **Default to Thumb-2** for most code (code density wins)
- **Consider ARM mode** for: compute-intensive kernels, tight inner loops requiring maximum performance, code with heavy use of high registers
- [Inference] Performance difference typically <5% for well-optimized Thumb-2

**Example** - Hybrid approach:**

```assembly
.thumb
main_function:
    ; Thumb-2 for most code
    PUSH {r4-r7, lr}
    ; ... setup ...
    
    ; Call ARM mode for performance-critical kernel
    LDR r0, =dsp_kernel
    BLX r0              ; Call ARM function
    
    ; Resume Thumb-2
    POP {r4-r7, pc}

.arm
dsp_kernel:
    ; Performance-critical DSP code in ARM mode
    ; Uses conditional execution heavily
    ; ... intensive computation ...
    BX lr               ; Return to Thumb-2
```

