## MMX Data Types


MMX supports packed integer data types, allowing multiple smaller integers to be processed simultaneously within a single 64-bit register. Each data type determines how the 64-bit register is partitioned.

### Packed Byte (Byte Vector)

**Format**: Eight 8-bit integers per register

```
63    56 55    48 47    40 39    32 31    24 23    16 15     8 7      0
+-------+-------+-------+-------+-------+-------+-------+-------+
| Byte7 | Byte6 | Byte5 | Byte4 | Byte3 | Byte2 | Byte1 | Byte0 |
+-------+-------+-------+-------+-------+-------+-------+-------+
```

- **Designation**: Packed byte (PB)
- **Element count**: 8 elements
- **Element size**: 8 bits each
- **Range (unsigned)**: 0 to 255
- **Range (signed)**: -128 to 127
- **Use cases**: Pixel data, character operations, color channels

### Packed Word (Word Vector)

**Format**: Four 16-bit integers per register

```
63            48 47            32 31            16 15             0
+---------------+---------------+---------------+---------------+
|     Word3     |     Word2     |     Word1     |     Word0     |
+---------------+---------------+---------------+---------------+
```

- **Designation**: Packed word (PW)
- **Element count**: 4 elements
- **Element size**: 16 bits each
- **Range (unsigned)**: 0 to 65,535
- **Range (signed)**: -32,768 to 32,767
- **Use cases**: Audio samples, coordinate pairs, counters

### Packed Doubleword (Dword Vector)

**Format**: Two 32-bit integers per register

```
63                              32 31                              0
+---------------------------------+---------------------------------+
|            Dword1               |            Dword0               |
+---------------------------------+---------------------------------+
```

- **Designation**: Packed doubleword (PD)
- **Element count**: 2 elements
- **Element size**: 32 bits each
- **Range (unsigned)**: 0 to 4,294,967,295
- **Range (signed)**: -2,147,483,648 to 2,147,483,647
- **Use cases**: Accumulation, extended precision, pointer operations

### Quadword (Scalar)

**Format**: Single 64-bit integer per register

```
63                                                               0
+-----------------------------------------------------------------+
|                          Quadword                               |
+-----------------------------------------------------------------+
```

- **Designation**: Quadword (Q)
- **Element count**: 1 element
- **Element size**: 64 bits
- **Range (unsigned)**: 0 to 18,446,744,073,709,551,615
- **Range (signed)**: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
- **Use cases**: Data movement, bitwise operations, 64-bit arithmetic

