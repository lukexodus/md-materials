## Server Logic and Reactivity


The server function contains the application's computational logic, implementing reactive programming principles that automatically update outputs when inputs change without explicit event handling.

**Key points:**

- Reactive expressions create cached computations that update only when dependencies change
- Output objects render results for display in the UI
- Observer functions perform side effects without returning values
- The reactive dependency graph determines execution order automatically

Server functions receive three parameters: `input`, `output`, and `session`. The `input` object provides read-only access to UI input values, `output` stores rendered results for display, and `session` enables advanced server-side operations like updating inputs or managing user sessions.

Output objects are created by assigning render functions to `output` slots. Common render functions include `renderText()` for text output, `renderPlot()` for graphics, `renderTable()` for data frames, and `renderUI()` for dynamic UI generation. Each render function corresponds to specific output elements in the UI.

Reactive expressions, created with `reactive()`, perform computations that depend on reactive inputs and cache results until dependencies change. This caching mechanism improves performance by avoiding redundant calculations. Reactive expressions return values and can be called like functions within other reactive contexts.

Observers, created with `observe()` or `observeEvent()`, perform side effects such as writing files, sending emails, or updating databases. Unlike reactive expressions, observers don't return values and execute for their side effects. `observeEvent()` provides more control by specifying which inputs trigger execution.

Reactive values, created with `reactiveValues()`, store state that can trigger reactivity when modified. This enables creating custom reactive sources beyond UI inputs, useful for maintaining application state or creating reactive data structures.

Isolation functions like `isolate()` break reactive dependencies when needed, allowing access to reactive values without creating dependencies. This provides fine-grained control over when reactive expressions should invalidate and recalculate.

