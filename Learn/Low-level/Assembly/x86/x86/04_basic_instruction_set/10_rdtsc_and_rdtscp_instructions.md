## RDTSC and RDTSCP Instructions


RDTSC (Read Time-Stamp Counter) reads the processor's time-stamp counter into EDX:EAX. The time-stamp counter increments with each clock cycle (on most modern processors, it increments at a constant rate regardless of frequency scaling).

`RDTSC` loads the lower 32 bits into EAX and the upper 32 bits into EDX, providing a 64-bit counter value. This is used for high-resolution timing measurements and performance monitoring.

RDTSC is not serializing, meaning instructions before and after it can execute out of order relative to RDTSC. For precise timing, surrounding instructions should include serializing instructions:

```
CPUID              ; Serialize
RDTSC              ; Read start time
MOV start_low, EAX
MOV start_high, EDX

; Code to measure

CPUID              ; Serialize
RDTSC              ; Read end time
MOV end_low, EAX
MOV end_high, EDX
```

RDTSCP (Read Time-Stamp Counter and Processor ID) is an improved version that reads the TSC and also returns the processor ID in ECX. RDTSCP is partially serializing - it waits for all previous instructions to complete but allows subsequent instructions to begin before RDTSCP finishes. This provides better behavior for timing measurements.

Access to RDTSC can be restricted by the operating system using the TSD (Time Stamp Disable) bit in CR4. When TSD=1, RDTSC execution at privilege levels other than ring 0 generates a general protection fault.

The TSC is useful for performance profiling, but [Inference] its reliability for absolute time measurements depends on several factors. Modern processors provide invariant TSC that increments at a constant rate, but older processors' TSC rates varied with CPU frequency changes. Multi-core systems may have TSC synchronization issues between cores, though modern systems generally maintain synchronized TSCs.

