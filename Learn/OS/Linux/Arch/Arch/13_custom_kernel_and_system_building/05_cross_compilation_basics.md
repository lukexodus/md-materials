## Cross-Compilation Basics


### Cross-Compilation Overview

**Definition**: Compiling code on one platform (host) to run on another (target).[1]

**Use Cases**:[1]
- Compile for ARM on x86_64 
- Build for older/newer architectures 
- Embedded systems development 
- Test portability[1]

**Terminology** :
- **Host**: Machine doing compilation 
- **Target**: Machine running compiled code 
- **Build**: Intermediate system if three different 

### Architecture Identification

#### Supported Architectures

**Arch Linux** :
- `x86_64`: 64-bit Intel/AMD 
- `aarch64`: ARM 64-bit 
- `armv7h`: ARM 32-bit 

**Other Architectures** :
- `i686`: 32-bit x86 
- `riscv64`: RISC-V 64-bit 

#### Check Host Architecture

**Current System** :

```bash
uname -m
```

**Detailed** :

```bash
gcc -dumpmachine
```

### Cross-Compilation Toolchain

#### Toolchain Components

**Required** :
- Cross-compiler (gcc) 
- Cross-linker (ld) 
- Cross-assembler (as) 
- Cross-libraries (libc) 

**Installation** :

```bash
sudo pacman -S arm-none-eabi-gcc
sudo pacman -S aarch64-linux-gnu-gcc
sudo pacman -S armv7l-rpmfusion-linux-gnueabihf-gcc
```

#### Verify Toolchain

**Check Installation** :

```bash
which aarch64-linux-gnu-gcc
aarch64-linux-gnu-gcc --version
```

**Test Compilation** :

```bash
aarch64-linux-gnu-gcc --version
echo 'int main() { return 0; }' > test.c
aarch64-linux-gnu-gcc test.c -o test-arm
```

### Simple Cross-Compilation

#### Basic Example

**Source Code**: `hello.c` :

```c
#include <stdio.h>

int main() {
    printf("Hello from ARM!\n");
    return 0;
}
```

**Compile for ARM** :

```bash
aarch64-linux-gnu-gcc hello.c -o hello-arm64
```

**Verify Output** :

```bash
file hello-arm64
```

**Expected**: `ELF 64-bit LSB executable, ARM aarch64` .

#### Cross-Compile for Multiple Targets

**Script** :

```bash
#!/bin/bash

TARGETS=(
    "x86_64"
    "aarch64-linux-gnu"
    "arm-linux-gnueabihf"
)

for target in "${TARGETS[@]}"; do
    $target-gcc hello.c -o hello-$target
    file hello-$target
done
```

### Makefile Cross-Compilation

#### Traditional Makefile

**Basic Makefile** :

```makefile
CC = gcc
CFLAGS = -Wall -O2

all: program

program: main.o helper.o
	$(CC) $(CFLAGS) -o program main.o helper.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

helper.o: helper.c
	$(CC) $(CFLAGS) -c helper.c

clean:
	rm -f *.o program
```

**Cross-Compile** :

```bash
make CC=aarch64-linux-gnu-gcc
```

or

```bash
make CC=aarch64-linux-gnu-gcc CFLAGS="-Wall -O2"
```

#### Improved Makefile

**Support Multiple Targets** :

```makefile
ifeq ($(TARGET),arm)
    CC = arm-linux-gnueabihf-gcc
else ifeq ($(TARGET),arm64)
    CC = aarch64-linux-gnu-gcc
else
    CC = gcc
endif

CFLAGS = -Wall -O2

all: program

program: main.o
	$(CC) $(CFLAGS) -o program main.o

clean:
	rm -f *.o program
```

**Build** :

```bash
make TARGET=arm64
```

### CMake Cross-Compilation

#### Toolchain File

**Create Toolchain**: `aarch64-toolchain.cmake` :

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

#### Build with CMake

**Configure** :

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=aarch64-toolchain.cmake .
```

**Build** :

```bash
make
```

**Alternative Method** :

```bash
cmake \
    -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
    -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
    .
make
```

### Autotools Cross-Compilation

#### Configure Script

**Basic Configure** :

```bash
./configure --host=aarch64-linux-gnu
make
make install DESTDIR=/tmp/install
```

**With Options** :

```bash
./configure \
    --host=aarch64-linux-gnu \
    --prefix=/usr \
    --disable-shared \
    --enable-static
make
```

#### Find Dependencies

**Check Requirements** :

```bash
./configure --help | grep -i arm
```

**Set Paths** :

```bash
export CFLAGS="-march=armv8-a"
export LDFLAGS="-L/usr/aarch64-linux-gnu/lib"
./configure --host=aarch64-linux-gnu
```

### Cross-Compiling Libraries

#### Static Library

**Compile for ARM** :

```bash
aarch64-linux-gnu-gcc -c library.c -o library.o
aarch64-linux-gnu-ar rcs libmylibrary.a library.o
```

**Verify** :

```bash
file libmylibrary.a
aarch64-linux-gnu-nm libmylibrary.a
```

#### Dynamic Library

**Compile Shared** :

```bash
aarch64-linux-gnu-gcc -fPIC -c library.c -o library.o
aarch64-linux-gnu-gcc -shared -o libmylibrary.so library.o
```

**Verify** :

```bash
file libmylibrary.so
aarch64-linux-gnu-nm libmylibrary.so
```

#### Link Against Library

**Program** :

```bash
aarch64-linux-gnu-gcc program.c -L. -lmylibrary -o program
```

### PKG-CONFIG for Cross-Compilation

#### Create .pc Files

**Example**: `mylib.pc` :

```
prefix=/usr/aarch64-linux-gnu
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: MyLibrary
Description: Custom library
Version: 1.0
Libs: -L${libdir} -lmylibrary
Cflags: -I${includedir}
```

#### Use in Build

**Configure** :

```bash
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig
./configure --host=aarch64-linux-gnu
```

### Testing Cross-Compiled Binaries

#### QEMU Emulation

**Install QEMU** :

```bash
sudo pacman -S qemu-system-aarch64 qemu-user-static
```

**Run Binary** :

```bash
qemu-aarch64-static ./program
```

**System Mode** :

```bash
qemu-system-aarch64 -m 1G -hda rootfs.img
```

#### Verification

**Check Binary** :

```bash
file program
ldd program  # May not work for different arch
aarch64-linux-gnu-readelf -h program
```

**Disassemble** :

```bash
aarch64-linux-gnu-objdump -d program | head -20
```

### Real-World Example: Cross-Compile ncurses

#### Build Process

**Download Source** :

```bash
wget https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.4.tar.gz
tar -xzf ncurses-6.4.tar.gz
cd ncurses-6.4
```

**Configure for ARM** :

```bash
./configure \
    --host=aarch64-linux-gnu \
    --prefix=/opt/ncurses-arm64 \
    --disable-stripping
```

**Build** :

```bash
make -j$(nproc)
make install
```

**Verify Installation** :

```bash
ls -la /opt/ncurses-arm64/lib/
file /opt/ncurses-arm64/lib/libncurses.so
```

### Cross-Compilation for Embedded Systems

#### ARM Bare Metal

**Target Compiler** :

```bash
sudo pacman -S arm-none-eabi-gcc
```

**Simple Program** :

```c
void main(void) {
    // Bare metal code
    while(1);
}
```

**Compile** :

```bash
arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb program.c -o program.elf
```

#### Create Binary

**Extract Binary** :

```bash
arm-none-eabi-objcopy -O binary program.elf program.bin
```

**Verify** :

```bash
file program.bin
hexdump -C program.bin | head
```

### Troubleshooting Cross-Compilation

#### Cannot Find Headers

**Error** :

```
fatal error: stdio.h: No such file or directory
```

**Solution** :

```bash
export CFLAGS="-I/usr/aarch64-linux-gnu/include"
```

or

```bash
./configure --with-sysroot=/usr/aarch64-linux-gnu
```

#### Library Not Found

**Error** :

```
cannot find -lc
```

**Solution** :

```bash
export LDFLAGS="-L/usr/aarch64-linux-gnu/lib"
```

**Install Libraries** :

```bash
sudo pacman -S aarch64-linux-gnu-glibc
```

#### Architecture Mismatch

**Verify** :

```bash
file program
# Should show correct architecture
```

**Rebuild** :

Check toolchain and recompile .

### Best Practices

**Start Simple**: Test with hello world .

**Verify Toolchain**: Ensure correct compiler installed .

**Use Version Control**: Track configuration .

**Document Setup**: Record toolchain installation .

**Test Binaries**: Verify with emulation .

**Handle Endianness**: Check byte order compatibility .

**Match ABIs**: Ensure binary compatibility .

***

This comprehensive guide on cross-compilation basics completes the entire Arch Linux system administration documentation, providing users with knowledge to compile software for different architectures and embedded systems, expanding their ability to work with diverse platforms and hardware configurations.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

