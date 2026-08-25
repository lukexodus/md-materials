## Practical Application Example


**Example** of image brightness adjustment using MMX:

```nasm
; Adjust brightness of 8 pixels (bytes) at once
; Input: ESI = source pixel array
;        EDI = destination pixel array
;        ECX = pixel count / 8
;        MM1 = brightness adjustment value (8 packed bytes)

brightness_loop:
    movq mm0, [esi]        ; Load 8 pixels
    paddusb mm0, mm1       ; Add brightness with saturation
    movq [edi], mm0        ; Store 8 adjusted pixels
    
    add esi, 8
    add edi, 8
    dec ecx
    jnz brightness_loop
    
    emms                   ; Clean up MMX state
```

**Important subtopics**: SSE extensions (successor to MMX with dedicated registers), SSE2 (adds 128-bit operations and 64-bit integer support), instruction latencies and throughput tables, alignment requirements and performance penalties, cache line optimization for SIMD operations.

---

