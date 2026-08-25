## Data Movement Instructions


**MOVQ** - Move Quadword

```nasm
movq mm0, [memory]    ; Load 64 bits from memory
movq [memory], mm0    ; Store 64 bits to memory
movq mm0, mm1         ; Register to register move
```

**MOVD** - Move Doubleword

```nasm
movd mm0, eax         ; Load 32 bits from GP register (zero-extend)
movd eax, mm0         ; Store low 32 bits to GP register
movd mm0, [memory]    ; Load 32 bits from memory
```

