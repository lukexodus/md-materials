## Advanced Memory Access Patterns


NEON provides sophisticated memory access instructions for various data layouts and access patterns common in multimedia and signal processing.

### Structure Loads and Stores

**Single-Structure Loads**

VLD1 loads contiguous data into one or more registers.

**Example:**

```assembly
@ Load 64 bytes (four Q registers) contiguously
VLD1.8 {Q0, Q1, Q2, Q3}, [r0]

@ Load with post-increment
VLD1.32 {Q0}, [r0]!         @ Load 16 bytes, r0 += 16

@ Load with specific increment
MOV r1, #32
VLD1.16 {Q0}, [r0], r1      @ Load 16 bytes, r0 += 32
```

**Multi-Structure Loads**

VLD2/VLD3/VLD4 load interleaved data and separate into multiple registers.

**Example:**

```assembly
@ Stereo audio: LRLRLRLR... format
VLD2.16 {D0, D1}, [r0]!     @ D0 = LLLL (left channel)
                            @ D1 = RRRR (right channel)
                            @ Loads and deinterleaves 8 samples

@ RGB image data: RGBRGBRGB... format
VLD3.8 {D0, D1, D2}, [r0]!  @ D0 = RRRRRRRR (red channel)
                            @ D1 = GGGGGGGG (green channel)
                            @ D2 = BBBBBBBB (blue channel)

@ RGBA image data: RGBARGBARGBA... format
VLD4.8 {D0, D1, D2, D3}, [r0]! @ Separate R, G, B, A channels
```

**Lane-Specific Loads**

VLD1 with lane specifier loads a single element into a specific vector lane.

**Example:**

```assembly
@ Load single 32-bit value into specific lane
VLD1.32 {D0[0]}, [r0]       @ Load into D0 lane 0, preserve lane 1
VLD1.32 {D0[1]}, [r1]       @ Load into D0 lane 1, preserve lane 0

@ Useful for gathering non-contiguous data
```

**All-Lane Loads**

VLD1 with replication loads a single value into all lanes.

**Example:**

```assembly
@ Load and replicate across all lanes
VLD1.32 {D0[]}, [r0]        @ Load 32-bit value, broadcast to both lanes of D0
VLD1.16 {Q0[]}, [r1]        @ Load 16-bit value, broadcast to all 8 lanes of Q0
```

### Structure Stores

Store operations mirror load operations for interleaving during storage.

**Example:**

```assembly
@ Store interleaved stereo audio
@ D0 = left channel samples
@ D1 = right channel samples
VST2.16 {D0, D1}, [r0]!     @ Store as LRLRLRLR...

@ Store interleaved RGB
@ D0 = red, D1 = green, D2 = blue
VST3.8 {D0, D1, D2}, [r1]!  @ Store as RGBRGBRGB...

@ Store interleaved RGBA
VST4.8 {D0, D1, D2, D3}, [r2]! @ Store as RGBARGBARGBA...
```

### Alignment Specifications

Specifying alignment enables optimizations and may be required for certain instructions.

**Example:**

```assembly
@ Load with alignment specification
VLD1.32 {Q0}, [r0:128]      @ 128-bit (16-byte) aligned access
VLD1.64 {Q0}, [r0:256]      @ 256-bit (32-byte) aligned access (Q register pair)

@ Store with alignment
VST1.32 {Q0}, [r0:128]      @ 128-bit aligned store
```

### Gather Operations

[Inference: NEON lacks direct gather instructions (indexed loads from non-contiguous locations). Gathers must be implemented with scalar loads into individual lanes or computed indices with clever data arrangement].

**Example:**

```assembly
@ Manual gather using lane loads
@ r0 = base address, r1-r4 contain offsets
LDR r5, [r0, r1]            @ Load element at base + offset1
VMOV.32 D0[0], r5           @ Move to SIMD lane 0
LDR r5, [r0, r2]
VMOV.32 D0[1], r5           @ Move to SIMD lane 1
LDR r5, [r0, r3]
VMOV.32 D1[0], r5           @ Move to SIMD lane 2
LDR r5, [r0, r4]
VMOV.32 D1[1], r5           @ Move to SIMD lane 3
@ Q0 now contains gathered values
```

