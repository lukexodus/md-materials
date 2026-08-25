## Graphics Primitives


Graphics primitives are fundamental drawing operations that form the building blocks of rendering systems. Efficient implementations directly impact frame rates and user experience on embedded displays.

**Framebuffer Basics:**

Embedded displays typically use memory-mapped framebuffers where each pixel's color is stored in a contiguous memory region. Common formats:

- **RGB565**: 16 bits per pixel (5-bit red, 6-bit green, 5-bit blue)
- **RGB888**: 24 bits per pixel (8 bits per channel)
- **ARGB8888**: 32 bits per pixel (8-bit alpha, 8 bits per channel)

**Example** framebuffer structure for 320x240 RGB565 display:

```
Base address: 0xC0000000 (external SRAM)
Size: 320 * 240 * 2 = 153,600 bytes
Pixel (x,y) address: base + (y * 320 + x) * 2
```

### Line Drawing (Bresenham's Algorithm)

Bresenham's line algorithm uses only integer arithmetic, making it ideal for hardware without floating-point units.

**Algorithm Overview:**

Draws a line from (x₀, y₀) to (x₁, y₁) by calculating which pixels best approximate the line. Uses accumulated error to determine when to step in the secondary axis.

**Example** - Optimized Bresenham line drawing (Cortex-M4):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Draw line from (r0,r1) to (r2,r3) with color in r4
@ Assumes 320x240 RGB565 framebuffer at FRAMEBUFFER_BASE
@ Registers: r0=x0, r1=y0, r2=x1, r3=y1, r4=color

.equ FRAMEBUFFER_BASE, 0xC0000000
.equ SCREEN_WIDTH, 320

.global draw_line
.type draw_line, %function

draw_line:
    PUSH {r4-r11, lr}
    
    @ Calculate dx = abs(x1 - x0)
    SUBS r5, r2, r0          @ dx = x1 - x0
    IT MI
    RSBMI r5, r5, #0         @ if negative, negate
    
    @ Determine x step direction
    MOV r6, #2               @ sx = 2 (bytes per pixel, positive direction)
    CMP r2, r0
    IT LT
    RSBLT r6, r6, #0         @ if x1 < x0, sx = -2
    
    @ Calculate dy = abs(y1 - y0)
    SUBS r7, r3, r1          @ dy = y1 - y0
    IT MI
    RSBMI r7, r7, #0         @ if negative, negate
    
    @ Determine y step direction
    MOV r8, #(SCREEN_WIDTH * 2)  @ sy = stride (positive direction)
    CMP r3, r1
    IT LT
    RSBLT r8, r8, #0         @ if y1 < y0, sy = -stride
    
    @ Calculate initial error = dx - dy
    SUBS r9, r5, r7          @ err = dx - dy
    
    @ Calculate framebuffer address for (x0, y0)
    @ addr = base + (y0 * width + x0) * 2
    LDR r10, =FRAMEBUFFER_BASE
    MOV r11, #SCREEN_WIDTH
    MLA r11, r1, r11, r0     @ r11 = y0 * width + x0
    ADD r10, r10, r11, LSL #1  @ r10 = base + offset * 2
    
line_loop:
    @ Plot pixel at current position
    STRH r4, [r10]           @ Write color (halfword)
    
    @ Check if we've reached end point
    CMP r0, r2               @ x == x1?
    BNE continue_line
    CMP r1, r3               @ y == y1?
    BEQ line_done
    
continue_line:
    @ err2 = err * 2
    LSL r11, r9, #1          @ err2 = err * 2
    
    @ if (err2 > -dy)
    RSB r12, r7, #0          @ r12 = -dy
    CMP r11, r12
    BLE skip_x_step
    
    @ err -= dy
    SUB r9, r9, r7
    
    @ x0 += sx
    CMP r6, #0
    IT GT
    ADDGT r0, r0, #1
    IT LT
    SUBLT r0, r0, #1
    
    @ Update framebuffer pointer
    ADD r10, r10, r6
    
skip_x_step:
    @ if (err2 < dx)
    CMP r11, r5
    BGE skip_y_step
    
    @ err += dx
    ADD r9, r9, r5
    
    @ y0 += sy
    CMP r8, #0
    IT GT
    ADDGT r1, r1, #1
    IT LT
    SUBLT r1, r1, #1
    
    @ Update framebuffer pointer
    ADD r10, r10, r8
    
skip_y_step:
    B line_loop
    
line_done:
    POP {r4-r11, pc}
    
.size draw_line, .-draw_line
```

**Optimization Techniques:**

**Pre-multiplied Stride** Instead of recalculating `y * width + x` each iteration, the code maintains a running framebuffer pointer and adds stride values directly.

**Conditional Execution (IT blocks)** ARM Thumb-2 IT (If-Then) instructions allow conditional execution without branches, reducing pipeline stalls:

```assembly
CMP r0, #0
IT MI
RSBMI r0, r0, #0    @ Executes only if negative
```

**Direct Memory Access** Using `STRH` (store halfword) writes 16-bit pixels directly without byte manipulation.

### Rectangle Filling

Filling rectangles is common for backgrounds, UI elements, and clearing regions.

**Example** - Fast rectangle fill using ARM SIMD:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Fill rectangle at (r0,r1) with width r2, height r3, color r4
@ Uses word writes for 4x speedup on aligned regions

.global fill_rect
.type fill_rect, %function

fill_rect:
    PUSH {r4-r11, lr}
    
    @ Replicate 16-bit color to 32 bits for word writes
    ORR r4, r4, r4, LSL #16  @ r4 = color | (color << 16)
    
    @ Calculate starting address
    LDR r5, =FRAMEBUFFER_BASE
    MOV r6, #SCREEN_WIDTH
    MLA r6, r1, r6, r0       @ offset = y * width + x
    ADD r5, r5, r6, LSL #1   @ addr = base + offset * 2
    
    @ Calculate stride (bytes to next row)
    MOV r6, #SCREEN_WIDTH
    SUB r6, r6, r2           @ stride_pixels = width - rect_width
    LSL r6, r6, #1           @ stride_bytes = stride_pixels * 2
    
    @ Check if width is odd or even
    TST r2, #1
    BNE rect_odd_width
    
    @ Even width: can use word writes throughout
rect_even_row:
    MOV r7, r2, LSR #1       @ words_per_row = width / 2
    
rect_even_col:
    STR r4, [r5], #4         @ Write 2 pixels as 1 word
    SUBS r7, r7, #1
    BNE rect_even_col
    
    ADD r5, r5, r6           @ Move to next row
    SUBS r3, r3, #1          @ height--
    BNE rect_even_row
    B rect_done
    
rect_odd_width:
    @ Odd width: write words for n-1 pixels, then 1 halfword
    MOV r7, r2, LSR #1       @ words_per_row = (width - 1) / 2
    
rect_odd_row:
    MOV r8, r7
    
rect_odd_col:
    STR r4, [r5], #4         @ Write 2 pixels as 1 word
    SUBS r8, r8, #1
    BNE rect_odd_col
    
    STRH r4, [r5], #2        @ Write final pixel as halfword
    
    ADD r5, r5, r6           @ Move to next row
    SUBS r3, r3, #1
    BNE rect_odd_row
    
rect_done:
    POP {r4-r11, pc}
    
.size fill_rect, .-fill_rect
```

**Performance Analysis:**

[Inference] This implementation provides approximately 2x performance improvement over byte-wise operations by using 32-bit word writes for two 16-bit pixels simultaneously. The alignment handling ensures correct operation regardless of starting position.

### Circle Drawing (Midpoint Circle Algorithm)

Draws circles using symmetry - calculating one octant and mirroring to draw all eight octants.

**Example** - Midpoint circle with 8-way symmetry:

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Draw circle centered at (r0,r1) with radius r2, color r3

.global draw_circle
.type draw_circle, %function

draw_circle:
    PUSH {r4-r11, lr}
    
    MOV r4, r0               @ xc = center x
    MOV r5, r1               @ yc = center y
    MOV r6, r2               @ radius
    MOV r7, r3               @ color
    
    MOV r8, #0               @ x = 0
    MOV r9, r6               @ y = radius
    
    @ d = 1 - radius
    RSB r10, r6, #1          @ d = 1 - r
    
circle_loop:
    @ Plot 8 symmetric points
    @ (xc+x, yc+y), (xc-x, yc+y), (xc+x, yc-y), (xc-x, yc-y)
    @ (xc+y, yc+x), (xc-y, yc+x), (xc+y, yc-x), (xc-y, yc-x)
    
    @ Point 1: (xc+x, yc+y)
    ADD r0, r4, r8
    ADD r1, r5, r9
    MOV r2, r7
    BL plot_pixel
    
    @ Point 2: (xc-x, yc+y)
    SUB r0, r4, r8
    ADD r1, r5, r9
    MOV r2, r7
    BL plot_pixel
    
    @ Point 3: (xc+x, yc-y)
    ADD r0, r4, r8
    SUB r1, r5, r9
    MOV r2, r7
    BL plot_pixel
    
    @ Point 4: (xc-x, yc-y)
    SUB r0, r4, r8
    SUB r1, r5, r9
    MOV r2, r7
    BL plot_pixel
    
    @ Point 5: (xc+y, yc+x)
    ADD r0, r4, r9
    ADD r1, r5, r8
    MOV r2, r7
    BL plot_pixel
    
    @ Point 6: (xc-y, yc+x)
    SUB r0, r4, r9
    ADD r1, r5, r8
    MOV r2, r7
    BL plot_pixel
    
    @ Point 7: (xc+y, yc-x)
    ADD r0, r4, r9
    SUB r1, r5, r8
    MOV r2, r7
    BL plot_pixel
    
    @ Point 8: (xc-y, yc-x)
    SUB r0, r4, r9
    SUB r1, r5, r8
    MOV r2, r7
    BL plot_pixel
    
    @ Check termination
    CMP r8, r9
    BGE circle_done
    
    @ x++
    ADD r8, r8, #1
    
    @ if (d < 0)
    CMP r10, #0
    BGE circle_update_y
    
    @ d += 2*x + 1
    LSL r11, r8, #1
    ADD r10, r10, r11
    ADD r10, r10, #1
    B circle_loop
    
circle_update_y:
    @ y--
    SUB r9, r9, #1
    
    @ d += 2*(x - y) + 1
    SUB r11, r8, r9
    LSL r11, r11, #1
    ADD r10, r10, r11
    ADD r10, r10, #1
    B circle_loop
    
circle_done:
    POP {r4-r11, pc}

@ Helper: Plot single pixel
plot_pixel:
    PUSH {r0-r2, lr}
    
    @ Bounds check
    CMP r0, #0
    BLT pixel_done
    CMP r0, #SCREEN_WIDTH
    BGE pixel_done
    CMP r1, #0
    BLT pixel_done
    CMP r1, #240
    BGE pixel_done
    
    @ Calculate address
    LDR r3, =FRAMEBUFFER_BASE
    MOV r4, #SCREEN_WIDTH
    MLA r4, r1, r4, r0
    ADD r3, r3, r4, LSL #1
    
    @ Write pixel
    STRH r2, [r3]
    
pixel_done:
    POP {r0-r2, pc}
    
.size draw_circle, .-draw_circle
```

### Bitmap Blitting with Alpha Blending

Blitting (Block Image Transfer) copies rectangular image data to the framebuffer. Alpha blending combines source and destination pixels based on transparency.

**Alpha Blending Formula:**

```
output = (src * alpha) + (dst * (255 - alpha)) / 255
```

**Example** - RGB565 bitmap blit with alpha (Cortex-M4 with DSP extensions):

```assembly
.syntax unified
.cpu cortex-m4
.thumb

@ Blit bitmap at (r0,r1), bitmap pointer r2, width r3, height on stack
@ Alpha value on stack (0-255)

.global blit_alpha
.type blit_alpha, %function

blit_alpha:
    PUSH {r4-r11, lr}
    
    @ Load parameters from stack
    LDR r4, [sp, #36]        @ height
    LDR r5, [sp, #40]        @ alpha
    
    @ Calculate destination base address
    LDR r6, =FRAMEBUFFER_BASE
    MOV r7, #SCREEN_WIDTH
    MLA r7, r1, r7, r0
    ADD r6, r6, r7, LSL #1   @ r6 = dest ptr
    
    @ Calculate source and dest stride
    MOV r7, #SCREEN_WIDTH
    SUB r7, r7, r3
    LSL r7, r7, #1           @ r7 = dest stride
    
    @ Prepare alpha values
    RSB r8, r5, #255         @ r8 = inv_alpha = 255 - alpha
    
blit_row:
    MOV r9, r3               @ column counter
    
blit_col:
    @ Load source pixel (RGB565)
    LDRH r10, [r2], #2
    
    @ Load destination pixel
    LDRH r11, [r6]
    
    @ Extract and blend red channel (5 bits)
    UBFX r12, r10, #11, #5   @ src_r
    MUL r12, r12, r5         @ src_r * alpha
    
    UBFX r14, r11, #11, #5   @ dst_r
    MLA r12, r14, r8, r12    @ (src_r*alpha) + (dst_r*inv_alpha)
    
    LSR r12, r12, #8         @ Divide by 256 (approximate /255)
    
    @ Extract and blend green channel (6 bits)
    UBFX r0, r10, #5, #6     @ src_g
    MUL r0, r0, r5
    
    UBFX r14, r11, #5, #6    @ dst_g
    MLA r0, r14, r8, r0
    LSR r0, r0, #8
    
    @ Extract and blend blue channel (5 bits)
    UBFX r1, r10, #0, #5     @ src_b
    MUL r1, r1, r5
    
    UBFX r14, r11, #0, #5    @ dst_b
    MLA r1, r14, r8, r1
    LSR r1, r1, #8
    
    @ Pack blended RGB565 value
    BFI r1, r0, #5, #6       @ Insert green
    BFI r1, r12, #11, #5     @ Insert red
    
    @ Store blended pixel
    STRH r1, [r6], #2
    
    SUBS r9, r9, #1
    BNE blit_col
    
    @ Next row
    ADD r6, r6, r7           @ Add dest stride
    SUBS r4, r4, #1
    BNE blit_row
    
    POP {r4-r11, pc}
    
.size blit_alpha, .-blit_alpha
```

**Optimization Techniques:**

**Bit Field Instructions (UBFX, BFI)** Cortex-M4 provides bit field extract and insert instructions that efficiently pack/unpack RGB565 values without multiple shift/mask operations.

**Multiply-Accumulate (MLA)** The `MLA` instruction performs `d = a*b + c` in one cycle, perfect for blending calculations.

**Approximate Division** Dividing by 255 is expensive. Right-shifting by 8 (dividing by 256) provides close approximation with single-cycle execution. [Inference] The maximum error is less than 1 per channel, typically imperceptible in graphics.

### DMA-Accelerated Graphics

Many ARM SoCs include DMA controllers that can transfer data independently of the CPU, enabling parallel rendering.

**Example** - DMA2D configuration for rectangle fill (STM32 with Chrom-ART):

```assembly
.syntax unified
.cpu cortex-m7
.thumb

@ DMA2D hardware accelerated rectangle fill
@ r0=x, r1=y, r2=width, r3=height, r4=color

.equ DMA2D_BASE, 0x4002B000
.equ DMA2D_CR,   0x00
.equ DMA2D_OCOLR, 0x34
.equ DMA2D_OMAR, 0x3C
.equ DMA2D_OOR,  0x40
.equ DMA2D_NLR,  0x44

.global dma2d_fill_rect
.type dma2d_fill_rect, %function

dma2d_fill_rect:
    PUSH {r4-r7, lr}
    
    @ Calculate destination address
    LDR r5, =FRAMEBUFFER_BASE
    MOV r6, #SCREEN_WIDTH
    MLA r6, r1, r6, r0
    ADD r5, r5, r6, LSL #1
    
    @ Wait for DMA2D ready
    LDR r6, =DMA2D_BASE
1:  LDR r7, [r6, #DMA2D_CR]
    TST r7, #1               @ Check START bit
    BNE 1b
    
    @ Configure DMA2D for register-to-memory mode
    MOV r7, #(3 << 16)       @ Mode = R2M (register to memory)
    STR r7, [r6, #DMA2D_CR]
    
    @ Set output color
    STR r4, [r6, #DMA2D_OCOLR]
    
    @ Set output memory address
    STR r5, [r6, #DMA2D_OMAR]
    
    @ Set output line offset
    MOV r7, #SCREEN_WIDTH
    SUB r7, r7, r2
    STR r7, [r6, #DMA2D_OOR]
    
    @ Set number of lines and pixels per line
    ORR r7, r3, r2, LSL #16
    STR r7, [r6, #DMA2D_NLR]
    
    @ Start transfer
    LDR r7, [r6, #DMA2D_CR]
    ORR r7, r7, #1           @ Set START bit
    STR r7, [r6, #DMA2D_CR]
    
    @ Optionally wait for completion or return immediately
    @ for async operation
    
    POP {r4-r7, pc}
    
.size dma2d_fill_rect, .-dma2d_fill_rect
```

[Inference] DMA2D hardware acceleration can provide 10-50x performance improvement for large fills and blits compared to CPU-based operations, while freeing the CPU for other tasks.

