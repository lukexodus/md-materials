## Android Debug Bridge (ADB)


ADB serves as the command-line interface for communicating with Android devices and emulators, providing essential debugging capabilities and device management functions.

**ADB Architecture** ADB operates through a client-server architecture consisting of three components: the ADB client running on the development machine, the ADB daemon (adbd) running on each Android device, and the ADB server that manages communication between clients and devices.

**Device Connection and Management** ADB supports multiple connection methods including USB, TCP/IP wireless debugging, and emulator connections. Device authorization through RSA key pairs ensures secure debugging sessions.

```kotlin
// Common ADB commands for device management
adb devices // List connected devices
adb connect 192.168.1.100:5555 // Wireless debugging
adb -s device_serial_number shell // Target specific device
```

**Application Installation and Management** ADB handles application lifecycle operations including installation, uninstallation, and package management. The tool supports split APKs, instant apps, and various installation modes.

```kotlin
// Application management commands
adb install -r app-debug.apk // Reinstall existing app
adb uninstall com.example.package // Remove application
adb shell pm list packages // List installed packages
adb shell am start -n com.example/.MainActivity // Launch activity
```

**Shell Access and System Interaction** The ADB shell provides direct access to the Android Linux environment, enabling file system operations, process management, and system configuration inspection.

```kotlin
// File system and process operations
adb shell ls /data/data/com.example.app/
adb shell ps | grep com.example.app
adb shell dumpsys activity activities // Activity stack
adb shell input tap 500 1000 // Simulate touch input
```

**Log Management** Logcat integration through ADB provides real-time system and application log monitoring with filtering capabilities based on priority levels, tags, and process IDs.

```kotlin
// Logcat filtering and management
adb logcat -s MyApp:D *:E // Filter by tag and priority
adb logcat -c // Clear log buffer
adb logcat --pid=12345 // Filter by process ID
adb logcat > debug.log // Save logs to file
```

**Port Forwarding and Tunneling** ADB enables network port forwarding between the development machine and Android device, facilitating debugging tools that require network communication.

```kotlin
// Network debugging setup
adb forward tcp:8080 tcp:8080 // Port forwarding
adb reverse tcp:3000 tcp:3000 // Reverse port forwarding
```

**Database and Preference Inspection** ADB provides access to application databases and shared preferences for debugging data-related issues, though this requires debuggable applications or root access.

**Broadcast and Intent Testing** The activity manager (am) command enables sending broadcasts and starting activities with specific intent parameters for testing application behavior.

```kotlin
// Intent and broadcast testing
adb shell am broadcast -a com.example.CUSTOM_ACTION
adb shell am start -a android.intent.action.VIEW -d "https://example.com"
```

