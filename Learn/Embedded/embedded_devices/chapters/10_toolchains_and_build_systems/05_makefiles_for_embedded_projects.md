## Makefiles for Embedded Projects

### Overview

Make is a build automation tool that determines which files need rebuilding based on file modification timestamps and dependency relationships, then invokes the appropriate toolchain commands to rebuild only what's changed. In embedded development, Makefiles remain widely used — often preferred over more modern build systems for small-to-medium bare-metal projects — because the build itself is comparatively simple (no dynamic library resolution, no complex dependency-package ecosystem to manage) while still benefiting from Make's core value: avoiding a full rebuild of every source file on every invocation. This content assembles the toolchain invocation patterns from the prior GCC-toolchains, linker, and assembler content into a coherent, practical Makefile structure.

### Why Make (Still) Fits Embedded Bare-Metal Projects Well

**Key Points**

- Embedded firmware builds are typically single-target (one `.elf`/`.bin`/`.hex` output per build configuration), without the multi-package, multi-library dependency resolution that motivates more elaborate build systems in larger software ecosystems.
- The full toolchain invocation sequence (compile each `.c`/`.s` file to `.o`, link all `.o` files with the linker script, then `objcopy` to `.bin`/`.hex`, per the GCC-toolchains content) maps naturally onto Make's core model of file-to-file transformation rules.
- Vendor IDEs (STM32CubeIDE, MCUXpresso, and similar) frequently generate Makefiles (or Eclipse-managed builds that are Make-based underneath) as their actual build mechanism, making Makefile literacy directly useful even for developers who primarily work within an IDE.
- **[Inference]** For genuinely large, multi-target, or multi-platform embedded codebases, CMake (which can itself generate Makefiles, or use other backends) is increasingly common as a layer above raw Make specifically to manage that additional complexity — but for small-to-medium single-target firmware projects, hand-written Make often remains simpler and more transparent than introducing a CMake layer purely for its own sake.

### Basic Makefile Structure: Targets, Prerequisites, Recipes

```makefile
main.o: main.c
	arm-none-eabi-gcc -c main.c -o main.o
```

Each rule has three parts: a **target** (the file to produce, `main.o`), **prerequisites** (files it depends on, `main.c` — if this file is newer than the target, or the target doesn't exist yet, the recipe runs), and a **recipe** (the command(s) to run, indented with a literal tab character — a frequent, easy-to-hit source of cryptic Make errors when a text editor substitutes spaces).

### Variables for Toolchain and Flag Configuration

Directly encoding the toolchain prefix and flag sets from the GCC-toolchains content as Make variables avoids repetition and centralizes configuration:

```makefile
TOOLCHAIN = arm-none-eabi-
CC        = $(TOOLCHAIN)gcc
OBJCOPY   = $(TOOLCHAIN)objcopy
SIZE      = $(TOOLCHAIN)size

MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS    = $(MCU_FLAGS) -Os -g -Wall -Wextra -ffunction-sections -fdata-sections
LDFLAGS   = $(MCU_FLAGS) -T linker_script.ld -Wl,--gc-sections -Wl,-Map=build/firmware.map

TARGET    = firmware
```

**[Inference]** Centralizing `MCU_FLAGS` as a single variable referenced by both `CFLAGS` and `LDFLAGS` directly addresses the multilib consistency concern raised in the GCC-toolchains content — since the same `-mcpu`/`-mfpu`/`-mfloat-abi` flags must be passed identically to every compile *and* link step, defining them once and referencing that single variable everywhere structurally prevents the kind of accidental flag-set mismatch between compile and link steps that risks the `eabi`-vs-`eabihf` hazard flagged repeatedly across this series.

### Pattern Rules: Avoiding Per-File Repetition

Writing an explicit rule for every single source file (as in the minimal example above) doesn't scale; Make's **pattern rules** express a single rule template applying to any file matching a pattern.

```makefile
build/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: src/%.s
	$(CC) $(MCU_FLAGS) -c $< -o $@
```

- `$<` expands to the rule's first prerequisite (the source file).
- `$@` expands to the rule's target (the object file being produced).
- `%` is Make's wildcard, matching any stem shared between the target and prerequisite patterns — `build/main.o` depends on `src/main.c`, `build/startup.o` depends on `src/startup.s`, and so on, without a separate explicit rule for each.

### Automatic Variable and Source-List Aggregation

```makefile
SRCS_C   = $(wildcard src/*.c)
SRCS_ASM = $(wildcard src/*.s)
OBJS     = $(SRCS_C:src/%.c=build/%.o) $(SRCS_ASM:src/%.s=build/%.o)

$(TARGET).elf: $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $@
	$(SIZE) $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

all: $(TARGET).bin

.PHONY: all clean
clean:
	rm -rf build/*.o $(TARGET).elf $(TARGET).bin
```

- `$(wildcard src/*.c)` collects every `.c` file in `src/` into a list at Make's parse time, avoiding manual maintenance of a source-file list as files are added or removed from the project.
- The `:src/%.c=build/%.o` substitution reference transforms that source-file list into the corresponding expected object-file list, feeding directly into the `$(TARGET).elf` rule's prerequisites — this is what causes Make to know it must (re)build every object file before attempting the link step, and to know the link step itself only needs to rerun if any object file (or the linker script, addressed below) changed.
- `.PHONY` declares `all` and `clean` as targets that don't correspond to actual files — without this, if a file literally named `clean` ever existed in the project directory, Make's default timestamp-based logic could incorrectly conclude the `clean` target is already "up to date" and skip running its recipe.

### The Dependency Problem: Header File Changes

The pattern rule `build/%.o: src/%.c` above has a real gap: if `main.c` includes `config.h`, and `config.h` changes, Make has no way to know `main.o` needs rebuilding — its prerequisite list only mentions `main.c`, not the headers `main.c` transitively includes. Without addressing this, a header-only change can silently fail to trigger the necessary recompilation, leaving stale object code linked into the final binary.

```makefile
CFLAGS += -MMD -MP
-include $(OBJS:.o=.d)
```

`-MMD` instructs GCC to generate a `.d` (dependency) file alongside each `.o` file, listing every header that particular compilation actually included — auto-discovered from the real `#include` graph rather than manually maintained. `-MP` adds a phony target for each header, preventing a Make error if a listed header is later deleted or renamed. The `-include` directive (the leading `-` suppresses an error if the `.d` files don't exist yet, e.g., on a completely clean build) pulls these generated dependency files back into the Makefile itself, extending each object file's real prerequisite list to include every header it actually depends on.

**[Inference]** This auto-dependency-generation pattern is generally considered close to mandatory for any non-trivial Makefile-based C/C++ project, embedded or otherwise, since without it, the extremely common "I changed a header, but my rebuild picked up stale behavior" class of bug becomes a real and recurring hazard rather than a theoretical edge case — a header change is one of the most frequent kinds of edit in a typical embedded project (adjusting a register definition, a config constant, a struct layout), making this specific dependency gap unusually costly to leave unaddressed.

### Linker Script as an Explicit Prerequisite

A subtler dependency gap: the `$(TARGET).elf` rule above lists `$(OBJS)` as prerequisites, but not `linker_script.ld` — meaning a linker-script-only edit (adjusting a `MEMORY` region size, adding a new custom section per the linker-scripts content) would not, by Make's own logic, trigger a relink, even though `LDFLAGS` (referenced in the recipe) includes `-T linker_script.ld`.

```makefile
$(TARGET).elf: $(OBJS) linker_script.ld
	$(CC) $(LDFLAGS) $(OBJS) -o $@
	$(SIZE) $@
```

**[Inference]** This is a specific instance of a general Make principle worth internalizing for embedded builds: Make's dependency tracking only knows about what's *explicitly listed* as a prerequisite — it has no inherent understanding that a flag referenced in a recipe (like `-T linker_script.ld` inside `$(LDFLAGS)`) implies a file dependency; every file genuinely consulted during a build step (linker scripts, configuration headers pulled in via flags rather than `#include`, and similar) needs to be listed as an explicit prerequisite for Make's incremental-rebuild logic to remain correct, or a subtle "stale build after this specific kind of edit" class of bug results.

### Directory Creation and Order-Only Prerequisites

Since object files are typically placed in a `build/` directory that may not yet exist on a clean checkout, the Makefile needs to ensure that directory exists before any compile rule attempts to write into it — but naively depending on the directory as an ordinary prerequisite causes every object file to be considered "out of date" whenever the directory's own modification time changes (e.g., whenever a new file is added to it), triggering unnecessary rebuilds.

```makefile
build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

build:
	mkdir -p build
```

The `|` separates ordinary prerequisites from **order-only prerequisites** — `build` must exist before the recipe runs, but the object file's up-to-date status is never reconsidered merely because `build`'s own timestamp changed, avoiding the unnecessary-rebuild problem while still guaranteeing directory existence.

### Multiple Build Configurations: Debug vs. Release

Directly connecting to the optimization-flags content's guidance about testing at the actual release optimization level, a Makefile commonly supports switching between debug and release configurations via a variable, rather than maintaining two entirely separate Makefiles.

```makefile
BUILD ?= release

ifeq ($(BUILD),debug)
    CFLAGS += -Og -DDEBUG
else
    CFLAGS += -Os -DNDEBUG
endif
```

`?=` assigns a default only if the variable isn't already set (e.g., via the command line or environment), allowing `make BUILD=debug` to override the default `release` configuration from the invocation itself, without editing the Makefile. **[Inference]** This directly operationalizes the compiler-optimization-flags content's recommendation to regularly build and test at the actual shipped optimization level: a single Makefile supporting both configurations, defaulting to `release`, makes it structurally easy to verify both configurations regularly (e.g., a debug build for active development, a release build run through the same test suite before any commit/merge) rather than the debug configuration silently becoming the only one anyone actually exercises day-to-day.

### Recursive vs. Non-Recursive Make for Larger Projects

For projects with genuinely separate subsystems (a driver library, an application layer, a third-party vendor SDK subdirectory), two general Makefile organization strategies exist:

- **Recursive Make**: each subdirectory has its own Makefile, invoked via `$(MAKE) -C subdirectory` from a parent Makefile — simple to reason about per-subdirectory but has well-documented weaknesses, notably that Make's incremental-rebuild correctness guarantees don't extend cleanly across the recursive boundary (a well-known critique, sometimes summarized as "recursive Make considered harmful," argues this structure makes it easy to under-specify cross-directory dependencies, similar in spirit to the linker-script-as-prerequisite gap discussed above but harder to fully close across separately-invoked Make processes).
- **Non-recursive (single, flat) Make**: one Makefile (potentially assembled via `include` from per-directory fragment files) manages the entire project's dependency graph in one Make invocation, allowing Make's own dependency resolution to correctly handle cross-directory relationships without the recursive-boundary gap — at the cost of a more complex single Makefile structure.

**[Inference]** For small-to-medium embedded projects (a single application plus a modest number of driver files), this distinction rarely matters in practice; it becomes a genuinely relevant architectural decision primarily once a project grows to include multiple substantial, semi-independent subsystems or a large vendor SDK tree, at which point the non-recursive approach's stronger cross-directory dependency correctness is more likely to be worth its added Makefile complexity.

### Complete Structural Overview

```makefile
TOOLCHAIN = arm-none-eabi-
CC        = $(TOOLCHAIN)gcc
OBJCOPY   = $(TOOLCHAIN)objcopy
SIZE      = $(TOOLCHAIN)size

MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
BUILD    ?= release

ifeq ($(BUILD),debug)
    OPT_FLAGS = -Og -DDEBUG
else
    OPT_FLAGS = -Os -DNDEBUG
endif

CFLAGS  = $(MCU_FLAGS) $(OPT_FLAGS) -g -Wall -Wextra \
          -ffunction-sections -fdata-sections -MMD -MP
LDFLAGS = $(MCU_FLAGS) -T linker_script.ld -Wl,--gc-sections \
          -Wl,-Map=build/firmware.map

TARGET   = firmware
SRCS_C   = $(wildcard src/*.c)
SRCS_ASM = $(wildcard src/*.s)
OBJS     = $(SRCS_C:src/%.c=build/%.o) $(SRCS_ASM:src/%.s=build/%.o)

.PHONY: all clean
all: build/$(TARGET).bin

build/$(TARGET).elf: $(OBJS) linker_script.ld
	$(CC) $(LDFLAGS) $(OBJS) -o $@
	$(SIZE) $@

build/$(TARGET).bin: build/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@

build/%.o: src/%.s | build
	$(CC) $(MCU_FLAGS) -c $< -o $@

build:
	mkdir -p build

clean:
	rm -rf build

-include $(OBJS:.o=.d)
```

### Makefile Dependency and Build Flow

===MERMAID_DIAGRAM===

flowchart TD

A["Source files (.c/.s)\n+ headers (.h)"] --> B{"Timestamp newer\nthan corresponding .o?"}

B -->|"Yes"| C["Recompile:\npattern rule invokes\n$(CC) $(CFLAGS)"]

B -->|"No"| D["Skip: .o\nalready up to date"]

C --> E["Generate .d file\n(-MMD -MP)\nauto header deps"]

E -.->|"included via\n-include *.d"| B

C --> F["Object files (build/*.o)"]

D --> F

F --> G{"Any .o or\nlinker_script.ld\nnewer than .elf?"}

G -->|"Yes"| H["Relink:\n$(CC) $(LDFLAGS)"]

G -->|"No"| I["Skip: .elf\nalready up to date"]

H --> J["firmware.elf"]

I --> J

J --> K["objcopy to\nfirmware.bin"]

**Related Topics**

- CMake as a generator layer above Make for larger or multi-target embedded projects
- Auto-dependency generation (`-MMD -MP`) mechanics and troubleshooting stale `.d` files
- Recursive vs. non-recursive Make organization for large embedded codebases with vendor SDKs
- Integrating flashing/programming targets (e.g., `make flash`) into the build Makefile
- Parallel builds (`make -j`) and ensuring Makefile correctness under parallel execution
- Continuous integration pipeline configuration for Makefile-based embedded builds
- Cross-compiling multiple build configurations (debug/release, multiple target boards) from one Makefile