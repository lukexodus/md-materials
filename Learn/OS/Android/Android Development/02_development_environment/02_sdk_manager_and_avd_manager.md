## SDK Manager and AVD Manager


The SDK Manager handles Android SDK components, platform versions, and development tools. It provides centralized management for all Android development dependencies and keeps components updated.

**SDK Manager Functionality** SDK Manager displays available and installed SDK platforms, build tools, system images, and additional components. Each Android API level requires separate platform installation. Build tools versions must align with project requirements and Gradle configurations. Additional components include Google Play services, support libraries, and hardware-specific tools.

**Platform Management** Different Android versions require corresponding SDK platforms for compilation and testing. Target SDK versions determine available APIs and features within applications. Minimum SDK versions affect device compatibility and market reach. [Inference] Balancing minimum and target SDK versions involves trade-offs between feature availability and device support.

**AVD Manager Overview** Android Virtual Device Manager creates and configures emulator instances for testing applications. Each AVD represents specific device configurations including screen size, RAM allocation, storage capacity, and Android version. Hardware profiles define device characteristics like CPU architecture, sensors, and input methods.

**AVD Configuration Options** System images determine Android version and processor architecture (x86, x86_64, ARM). Hardware acceleration through Intel HAXM or AMD significantly improves emulator performance. Memory allocation affects emulator responsiveness but consumes host system resources. Storage configuration includes internal storage size and SD card emulation.

**Key Points**

- SDK platforms must match project target and compile SDK versions
- System images with Google APIs provide access to Google Play Services
- Hardware acceleration is essential for acceptable emulator performance
- Multiple AVDs enable testing across different device configurations

