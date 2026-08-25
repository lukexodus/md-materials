## Memory Hierarchy Overview


Modern computer systems organize memory in a hierarchy based on speed, size, and cost:

```
CPU Registers         ~1 cycle        Bytes          Highest cost/byte
    ↓
L1 Cache             ~4 cycles       32-64 KB       
    ↓
L2 Cache             ~12 cycles      256-512 KB     
    ↓
L3 Cache             ~40 cycles      8-32 MB        
    ↓
Main Memory (RAM)    ~200 cycles     4-64 GB        
    ↓
SSD Storage          ~50,000 cycles  256 GB - 2 TB  
    ↓
HDD Storage          ~10M cycles     1-10 TB        Lowest cost/byte
```

**Access Time Disparity**: The performance gap between cache levels creates the fundamental motivation for cache optimization. A cache miss to main memory costs 50-100x more than an L1 hit, making cache behavior the dominant factor in memory-bound application performance.

**Principle of Locality**: Caches exploit two types of locality in program behavior:

**Temporal Locality**: Recently accessed data is likely to be accessed again soon. Caches retain recently-used data to satisfy subsequent accesses.

**Spatial Locality**: Data near recently accessed locations is likely to be accessed soon. Caches load entire cache lines (typically 64 bytes) rather than individual bytes.

```assembly
; Demonstrating temporal locality
temporal_example:
    mov eax, [data_value]       ; First access - cache miss
    add eax, 10
    mov ebx, [data_value]       ; Second access - cache hit (temporal)
    add ebx, 20
    ret

; Demonstrating spatial locality  
spatial_example:
    mov eax, [array]            ; Access array[0] - loads 64-byte cache line
    mov ebx, [array + 4]        ; Access array[1] - cache hit (spatial)
    mov ecx, [array + 8]        ; Access array[2] - cache hit (spatial)
    mov edx, [array + 12]       ; Access array[3] - cache hit (spatial)
    ret
; All 4 accesses hit same cache line if array is aligned
```

