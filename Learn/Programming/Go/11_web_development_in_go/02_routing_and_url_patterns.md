## Routing and URL Patterns


### Standard Library Routing

The `http.ServeMux` provides basic routing capabilities:

```go
func setupRoutes() *http.ServeMux {
    mux := http.NewServeMux()
    
    // Static routes
    mux.HandleFunc("/", homeHandler)
    mux.HandleFunc("/about", aboutHandler)
    
    // Path patterns
    mux.HandleFunc("/users/", usersHandler) // Matches /users/ and /users/anything
    mux.HandleFunc("/api/v1/", apiHandler)
    
    // Static file serving
    fileServer := http.FileServer(http.Dir("./static/"))
    mux.Handle("/static/", http.StripPrefix("/static/", fileServer))
    
    return mux
}

func usersHandler(w http.ResponseWriter, r *http.Request) {
    // Extract path segment
    path := strings.TrimPrefix(r.URL.Path, "/users/")
    if path == "" {
        // Handle /users/
        listUsers(w, r)
        return
    }
    
    // Handle /users/{id}
    userID, err := strconv.Atoi(path)
    if err != nil {
        http.Error(w, "Invalid user ID", http.StatusBadRequest)
        return
    }
    
    getUser(w, r, userID)
}
```

### Third-Party Routers

Popular routers like Gorilla Mux and Chi provide advanced routing features:

```go
// Gorilla Mux example
import "github.com/gorilla/mux"

func setupGorillaMux() *mux.Router {
    r := mux.NewRouter()
    
    // Path variables
    r.HandleFunc("/users/{id:[0-9]+}", getUserHandler).Methods("GET")
    r.HandleFunc("/users/{id:[0-9]+}", updateUserHandler).Methods("PUT")
    r.HandleFunc("/users", createUserHandler).Methods("POST")
    
    // Query parameters
    r.HandleFunc("/search", searchHandler).Queries("q", "{query}")
    
    // Subrouters
    api := r.PathPrefix("/api/v1").Subrouter()
    api.HandleFunc("/users", apiUsersHandler)
    api.HandleFunc("/posts", apiPostsHandler)
    
    // Middleware
    r.Use(loggingMiddleware)
    api.Use(authMiddleware)
    
    return r
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    userID, _ := strconv.Atoi(vars["id"])
    
    // Handle user retrieval
    user := getUserByID(userID)
    json.NewEncoder(w).Encode(user)
}
```

```go
// Chi router example
import "github.com/go-chi/chi/v5"

func setupChiRouter() chi.Router {
    r := chi.NewRouter()
    
    // Middleware stack
    r.Use(chi.Logger)
    r.Use(chi.Recoverer)
    r.Use(corsMiddleware)
    
    // Routes
    r.Get("/", homeHandler)
    r.Route("/users/{userID}", func(r chi.Router) {
        r.Use(userContextMiddleware) // Load user into context
        r.Get("/", getUser)          // GET /users/123
        r.Put("/", updateUser)       // PUT /users/123
        r.Delete("/", deleteUser)    // DELETE /users/123
        
        r.Route("/posts", func(r chi.Router) {
            r.Get("/", getUserPosts)    // GET /users/123/posts
            r.Post("/", createUserPost) // POST /users/123/posts
        })
    })
    
    // API versioning
    r.Route("/api", func(r chi.Router) {
        r.Route("/v1", func(r chi.Router) {
            r.Use(apiAuthMiddleware)
            r.Mount("/users", usersAPIRouter())
        })
    })
    
    return r
}
```

**Key Points:**

- Standard library routing is basic but sufficient for simple applications
- Third-party routers provide path parameters, middleware mounting, and advanced patterns
- Subrouters enable modular route organization
- Route patterns support regular expressions and constraints

