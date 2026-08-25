## Application Components


Android applications are constructed from four fundamental component types, each serving distinct purposes and having specific lifecycles.

**Activities** represent single screens with user interfaces. Each activity is implemented as a subclass of the Activity class and manages user interactions for a particular screen. Activities have well-defined lifecycle methods including onCreate(), onStart(), onResume(), onPause(), onStop(), and onDestroy() that the system calls as the activity transitions between states.

**Services** perform long-running operations in the background without providing a user interface. Services come in three types: foreground services for tasks noticeable to users, background services for tasks not directly noticed by users, and bound services that provide a client-server interface to other components.

**Broadcast Receivers** respond to system-wide broadcast announcements or custom application broadcasts. These components can receive broadcasts even when the application is not running, making them useful for responding to system events like device boot completion or network connectivity changes.

**Content Providers** manage access to structured data sets and provide a standard interface for accessing data across application boundaries. They encapsulate data and provide mechanisms for defining data security, supporting operations like query, insert, update, and delete.

