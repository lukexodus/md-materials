## Handoff


In the context of macOS and Electron, **Handoff** is part of Apple’s **Continuity** features that allow an activity started on one device to continue on another, like Safari tabs, emails, or app actions. Electron doesn’t have built-in high-level support for Handoff, but you can work with it using the **`NSUserActivity` API** through a native macOS bridge (Objective-C/Swift) or a Node native module.

Here’s a structured explanation:

---

### 1. **Understanding Handoff / NSUserActivity**

* `NSUserActivity` represents an activity a user is doing (reading, editing, viewing, etc.).
* You assign it a **unique activity type**, a **title**, and optionally **user info** (metadata).
* Other devices detect this activity if they are signed into the same iCloud account, and they can continue the task.

Key properties:

* `activityType`: string identifier (e.g., `com.yourapp.edit-document`)
* `title`: user-facing description
* `userInfo`: dictionary with extra metadata
* `requiredUserInfoKeys`: keys that must be included for handoff
* `webpageURL`: optional, for linking Handoff to a web page

You also **call `becomeCurrent`** when the activity is active and `invalidate` when it’s done.

---

### 2. **Integrating with Electron**

Electron cannot directly access `NSUserActivity`, so you have to bridge native code:

**Options:**

1. **Native macOS module**

   * Create a small native macOS app module in Objective-C/Swift.
   * Expose a Node.js addon or CLI interface to Electron.
   * Example workflow:

     * Electron triggers a `startActivity(activityType, title, userInfo)` call.
     * Native code creates an `NSUserActivity` and calls `becomeCurrent`.
     * When done, call `invalidate`.

2. **Electron + AppleScript / Automator (simpler, limited)**

   * Use AppleScript to trigger macOS system activities.
   * Limited control and harder for dynamic activity data.

3. **Third-party modules**

   * There may be community Node modules for Handoff or NSUserActivity (though uncommon).
   * Usually require building a native macOS binary.

---

### 3. **Example: Conceptual Native Bridge**

**Swift (macOS app or framework)**

```swift
import Cocoa

@objc class HandoffBridge: NSObject {
    var activity: NSUserActivity?

    @objc func startActivity(type: String, title: String, info: [String: Any]) {
        activity = NSUserActivity(activityType: type)
        activity?.title = title
        activity?.userInfo = info
        activity?.becomeCurrent()
    }

    @objc func endActivity() {
        activity?.invalidate()
        activity = nil
    }
}
```

**Electron (Node.js call)**

```javascript
const { execFile } = require('child_process');

// Trigger native binary that starts NSUserActivity
execFile('/path/to/handoff-bridge', ['start', 'com.yourapp.view', 'Viewing Document', '{"docId":42}']);
```

---

### 4. **Listening on the Other Device**

* macOS devices automatically detect `NSUserActivity` over iCloud.
* When your app launches, you need to handle continuation:

```swift
func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == "com.yourapp.view-document" {
        let docId = userActivity.userInfo?["docId"]
        // Open the document in your app
    }
    return true
}
```

---

### 5. **Key Considerations**

* Handoff works only between Apple devices signed into the same iCloud account.
* Requires **App Sandbox** entitlements for macOS apps if distributed via the App Store.
* Electron’s `.app` bundle must include the native code in `Contents/Frameworks` or `Contents/Resources`.

---

