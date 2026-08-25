## Implementation Best Practices


**Sensor Management:**

- Always unregister sensor listeners in `onPause()` to prevent battery drain
- Use appropriate sensor delays based on application needs
- Implement noise filtering for accelerometer and gyroscope data
- Check sensor availability before registration

**Location Services:**

- Request minimal location permissions required for functionality
- Use appropriate location accuracy settings to balance battery and precision
- Implement proper location caching to reduce API calls
- Handle location permission changes gracefully

**Bluetooth Connectivity:**

- Check Bluetooth availability and permissions before operations
- Implement proper device discovery and pairing workflows
- Handle Bluetooth state changes and connection failures
- Use appropriate scanning modes for BLE to optimize battery usage

**NFC Implementation:**

- Enable foreground dispatch only when needed
- Handle multiple NFC technologies appropriately
- Implement proper error handling for NFC operations
- Validate NFC data integrity and format

**Biometric Security:**

- Always use cryptographic objects with biometric authentication
- Handle biometric enrollment states appropriately
- Implement fallback authentication methods
- Validate biometric hardware availability

**Key Points:**

- Hardware sensors provide rich device interaction capabilities through standardized Android APIs
- Proper permission handling is crucial for location, Bluetooth, and biometric features
- Battery optimization requires careful sensor lifecycle management and appropriate sampling rates
- Security considerations are paramount, especially for biometric authentication and NFC data handling
- [Inference] Cross-device compatibility varies significantly, requiring robust feature detection and graceful degradation

**Related Topics:** Camera API, Audio Recording, Proximity Sensors, Light Sensors, Compass/Magnetometer, Barometer, Heart Rate Sensors, Step Counter, Android Keystore System, Hardware Abstraction Layer (HAL), Device Administration API.

---

