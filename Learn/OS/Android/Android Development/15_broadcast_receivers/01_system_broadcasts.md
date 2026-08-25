## System Broadcasts


Android system generates numerous broadcast messages to notify applications about system state changes and events. These broadcasts cover device status, connectivity changes, power events, and user actions.

**Common System Broadcasts:**

- `ACTION_BOOT_COMPLETED`: Fired when device finishes booting
- `ACTION_BATTERY_LOW` / `ACTION_BATTERY_OKAY`: Battery level notifications
- `ACTION_POWER_CONNECTED` / `ACTION_POWER_DISCONNECTED`: Charging state changes
- `ACTION_AIRPLANE_MODE_CHANGED`: Airplane mode toggle
- `CONNECTIVITY_ACTION`: Network connectivity changes
- `ACTION_SCREEN_ON` / `ACTION_SCREEN_OFF`: Screen state changes
- `ACTION_LOCALE_CHANGED`: System language/locale modifications
- `ACTION_TIMEZONE_CHANGED`: Timezone updates
- `ACTION_DATE_CHANGED`: System date changes
- `ACTION_PACKAGE_ADDED` / `ACTION_PACKAGE_REMOVED`: App installation/removal

**Protected Broadcasts:** System broadcasts are protected and can only be sent by the Android system itself. Applications cannot send these broadcasts, ensuring system integrity and preventing malicious behavior.

**Broadcast Categories:**

- **Ordered Broadcasts**: Delivered sequentially to receivers based on priority, allowing modification or cancellation
- **Sticky Broadcasts**: Remain accessible after being sent (deprecated in API 21+)
- **Standard Broadcasts**: Delivered asynchronously to all registered receivers

