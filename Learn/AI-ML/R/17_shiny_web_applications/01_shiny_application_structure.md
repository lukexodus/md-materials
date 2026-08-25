## Shiny Application Structure


Shiny applications follow a specific architecture that separates user interface definition from server-side logic, enabling interactive web applications directly from R code without requiring web development expertise.

**Key points:**

- Every Shiny app requires a UI object and server function
- Single-file apps use `app.R`, while multi-file apps separate `ui.R` and `server.R`
- The application lifecycle involves initialization, reactive execution, and session management
- Modular design improves maintainability and reusability

A basic Shiny application consists of two essential components: the User Interface (UI) and the Server. The UI defines the visual layout and input/output elements users interact with, while the Server contains the reactive logic that processes inputs and generates outputs.

Single-file applications place both components in `app.R` with the structure:

```r
ui <- fluidPage(...)
server <- function(input, output, session) {...}
shinyApp(ui = ui, server = server)
```

Multi-file applications separate concerns into `ui.R` containing the UI object and `server.R` containing the server function. This approach improves organization for complex applications and enables better collaboration.

The `global.R` file executes once when the application starts, making it ideal for loading libraries, sourcing helper functions, and preparing data that all sessions will use. This reduces redundant operations and improves performance.

Application initialization occurs when `shinyApp()` is called or when Shiny detects the required files. During execution, Shiny manages the reactive dependency graph, automatically updating outputs when their input dependencies change. Session management handles multiple concurrent users, maintaining separate environments for each connection.

Directory structure conventions include placing static files in a `www/` folder, R scripts in `R/`, and data in `data/`. This organization follows R package conventions and improves maintainability.

