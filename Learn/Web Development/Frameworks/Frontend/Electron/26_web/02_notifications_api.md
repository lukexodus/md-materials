## Notifications API


### How Web Notifications Get Displayed

The Web Notifications API displays notifications at the **system level**, outside of the browser viewport and webpage context. When a notification is created, the browser hands it off to the operating system's native notification system, which then renders it according to the platform's UI conventions. [developer.mozilla](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API/Using_the_Notifications_API)

### Display Mechanism

When you create a notification using `new Notification(title, options)`, the browser performs several steps: [developer.mozilla](https://developer.mozilla.org/en-US/docs/Web/API/Notification)

- The browser checks if the user has granted notification permission
- If permission exists, the browser communicates with the OS notification center
- The OS renders the notification using native system UI components
- The notification appears in the same location and style as system notifications from other applications

This means notifications appear in different locations depending on the platform: Windows shows them in the Action Center, macOS in Notification Center, and Linux distributions in their respective notification daemons. [mdn2.netlify](https://mdn2.netlify.app/en-us/docs/web/api/notifications_api/)

### Notification Lifecycle Events

The API exposes four key events that track the notification's display lifecycle: [sitepoint](https://www.sitepoint.com/introduction-web-notifications-api/)

- **onshow**: Fired when the notification is displayed to the user
- **onclick**: Triggered when the user clicks the notification
- **onclose**: Fired when the user or browser closes the notification
- **onerror**: Fired if an error occurs during notification display

### Permission Requirement

Before any notification can be shown, the browser must request permission using `Notification.requestPermission()`. This displays a browser-level permission prompt, and only after the user grants permission can notifications be rendered through the OS notification system. The notification remains displayed according to system settings unless programmatically closed using the `close()` method or dismissed by the user. [sitepoint](https://www.sitepoint.com/browser-notification-api/)

---

