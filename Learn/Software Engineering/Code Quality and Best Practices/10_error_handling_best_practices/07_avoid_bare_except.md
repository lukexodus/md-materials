## **Avoid "Bare Except"**


A "bare except" (or catching the base `Exception` class without re-raising) is widely considered an anti-pattern, sometimes called "Pokemon Exception Handling" ("Gotta catch 'em all!").

- **System Interrupts:** in many languages (like Python), a bare `except:` or `except BaseException:` catches _everything_, including system exit signals like `SystemExit` and `KeyboardInterrupt` (Ctrl+C). This prevents a user from stopping the program.
    
- **Hiding Bugs:** As shown in the section above, it swallows syntax errors, logic errors, and implementation bugs, making debugging nearly impossible. The system continues running in an undefined, potentially corrupt state.
    
- **Zombie Processes:** If a bare except swallows a critical failure (like `MemoryError`), the program might limp along in a broken state rather than crashing and restarting fresh.
    

The Golden Rule:

If you must use a broad exception handler (e.g., at the very top level of a web server to prevent a crash from taking down the whole app), always log the full stack trace using a logging framework so the error is not lost.

---

### **Related Topics**

- The "Fail Fast" Principle
    
- Custom Exception Classes
    
- Context Managers (`with` statement in Python)
    
- Tracebacks and Logging
    
- Idempotency in Error Handling

---

