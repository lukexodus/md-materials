## Custom Broadcasts


Applications can create and send custom broadcast messages to communicate between components or with other applications on the device.

**Creating Custom Broadcasts:**

```kotlin
// Sending implicit broadcast
val customIntent = Intent("com.example.CUSTOM_ACTION").apply {
    putExtra("data", "example_value")
}
sendBroadcast(customIntent)

// Sending explicit broadcast
val explicitIntent = Intent(this, MyBroadcastReceiver::class.java).apply {
    putExtra("message", "Hello")
}
sendBroadcast(explicitIntent)

// Sending ordered broadcast with result handling
sendOrderedBroadcast(
    customIntent,
    null,
    object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Handle final result
        }
    },
    null,
    Activity.RESULT_OK,
    null,
    null
)
```

**Custom Broadcast Types:**

- **Implicit Broadcasts**: Identified by action strings, any receiver with matching intent filter can receive
- **Explicit Broadcasts**: Target specific receiver classes directly
- **Ordered Custom Broadcasts**: Use `sendOrderedBroadcast()` for sequential delivery with priority handling

**Data Transmission:** Custom broadcasts support data transmission through Intent extras, allowing complex data structures using parceling mechanisms or serializable objects.

