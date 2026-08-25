## RESTful API Design


### Resource-Based API Structure

```go
type APIResponse struct {
    Success bool        `json:"success"`
    Data    interface{} `json:"data,omitempty"`
    Error   string      `json:"error,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
}

type Meta struct {
    Page       int `json:"page"`
    PerPage    int `json:"per_page"`
    Total      int `json:"total"`
    TotalPages int `json:"total_pages"`
}

type UserAPI struct {
    userService *UserService
}

func NewUserAPI(service *UserService) *UserAPI {
    return &UserAPI{userService: service}
}

// GET /api/users
func (api *UserAPI) ListUsers(w http.ResponseWriter, r *http.Request) {
    page := getIntQuery(r, "page", 1)
    perPage := getIntQuery(r, "per_page", 20)
    
    users, total, err := api.userService.GetUsers(r.Context(), page, perPage)
    if err != nil {
        api.respondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    meta := &Meta{
        Page:       page,
        PerPage:    perPage,
        Total:      total,
        TotalPages: (total + perPage - 1) / perPage,
    }
    
    api.respondSuccess(w, users, meta)
}

// GET /api/users/{id}
func (api *UserAPI) GetUser(w http.ResponseWriter, r *http.Request) {
    userID := getUserIDFromPath(r)
    if userID == 0 {
        api.respondError(w, http.StatusBadRequest, "Invalid user ID")
        return
    }
    
    user, err := api.userService.GetUser(r.Context(), userID)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            api.respondError(w, http.StatusNotFound, "User not found")
            return
        }
        api.respondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    api.respondSuccess(w, user, nil)
}

// POST /api/users
func (api *UserAPI) CreateUser(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        api.respondError(w, http.StatusBadRequest, "Invalid request body")
        return
    }
    
    if err := req.Validate(); err != nil {
        api.respondError(w, http.StatusBadRequest, err.Error())
        return
    }
    
    user, err := api.userService.CreateUser(r.Context(), req)
    if err != nil {
        api.respondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Location", fmt.Sprintf("/api/users/%d", user.ID))
    w.WriteHeader(http.StatusCreated)
    api.respondSuccess(w, user, nil)
}

// PUT /api/users/{id}
func (api *UserAPI) UpdateUser(w http.ResponseWriter, r *http.Request) {
    userID := getUserIDFromPath(r)
    if userID == 0 {
        api.respondError(w, http.StatusBadRequest, "Invalid user ID")
        return
    }
    
    var req UpdateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        api.respondError(w, http.StatusBadRequest, "Invalid request body")
        return
    }
    
    user, err := api.userService.UpdateUser(r.Context(), userID, req)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            api.respondError(w, http.StatusNotFound, "User not found")
            return
        }
        api.respondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    api.respondSuccess(w, user, nil)
}

// DELETE /api/users/{id}
func (api *UserAPI) DeleteUser(w http.ResponseWriter, r *http.Request) {
    userID := getUserIDFromPath(r)
    if userID == 0 {
        api.respondError(w, http.StatusBadRequest, "Invalid user ID")
        return
    }
    
    err := api.userService.DeleteUser(r.Context(), userID)
    if err != nil {
        if errors.Is(err, ErrUserNotFound) {
            api.respondError(w, http.StatusNotFound, "User not found")
            return
        }
        api.respondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.WriteHeader(http.StatusNoContent)
}

// Response helpers
func (api *UserAPI) respondSuccess(w http.ResponseWriter, data interface{}, meta *Meta) {
    response := APIResponse{
        Success: true,
        Data:    data,
        Meta:    meta,
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func (api *UserAPI) respondError(w http.ResponseWriter, status int, message string) {
    response := APIResponse{
        Success: false,
        Error:   message,
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(response)
}
```

### API Versioning and Content Negotiation

```go
type APIVersion string

const (
    V1 APIVersion = "v1"
    V2 APIVersion = "v2"
)

func versionMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        version := V1 // default
        
        // Check URL path
        if strings.HasPrefix(r.URL.Path, "/api/v2/") {
            version = V2
        } else if strings.HasPrefix(r.URL.Path, "/api/v1/") {
            version = V1
        }
        
        // Check Accept header
        accept := r.Header.Get("Accept")
        if strings.Contains(accept, "application/vnd.api+json;version=2") {
            version = V2
        }
        
        // Add version to context
        ctx := context.WithValue(r.Context(), "api_version", version)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

// Version-specific handlers
func (api *UserAPI) GetUserVersioned(w http.ResponseWriter, r *http.Request) {
    version := r.Context().Value("api_version").(APIVersion)
    
    userID := getUserIDFromPath(r)
    user, err := api.userService.GetUser(r.Context(), userID)
    if err != nil {
        api.handleError(w, err)
        return
    }
    
    switch version {
    case V1:
        api.respondV1User(w, user)
    case V2:
        api.respondV2User(w, user)
    }
}

func (api *UserAPI) respondV1User(w http.ResponseWriter, user *User) {
    response := struct {
        ID    int    `json:"id"`
        Name  string `json:"name"`
        Email string `json:"email"`
    }{
        ID:    user.ID,
        Name:  user.Name,
        Email: user.Email,
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func (api *UserAPI) respondV2User(w http.ResponseWriter, user *User) {
    response := struct {
        ID       int                    `json:"id"`
        Name     string                 `json:"name"`
        Email    string                 `json:"email"`
        Profile  map[string]interface{} `json:"profile"`
        Created  time.Time              `json:"created_at"`
        Modified time.Time              `json:"modified_at"`
        Links    map[string]string      `json:"_links"`
    }{
        ID:       user.ID,
        Name:     user.Name,
        Email:    user.Email,
        Profile:  user.Profile,
        Created:  user.CreatedAt,
        Modified: user.UpdatedAt,
        Links: map[string]string{
            "self":  fmt.Sprintf("/api/v2/users/%d", user.ID),
            "posts": fmt.Sprintf("/api/v2/users/%d/posts", user.ID),
        },
    }
    
    w.Header().Set("Content-Type", "application/vnd.api+json;version=2")
    json.NewEncoder(w).Encode(response)
}
```

### Request Validation and Filtering

```go
type CreateUserRequest struct {
    Name     string            `json:"name" validate:"required,min=2,max=100"`
    Email    string            `json:"email" validate:"required,email"`
    Password string            `json:"password" validate:"required,min=8"`
    Profile  map[string]string `json:"profile,omitempty"`
}

func (r *CreateUserRequest) Validate() error {
    validate := validator.New()
    if err := validate.Struct(r); err != nil {
        return formatValidationError(err)
    }
    
    // Custom validation
    if strings.Contains(r.Name, "@") {
        return errors.New("name cannot contain @ symbol")
    }
    
    return nil
}

type ListUsersRequest struct {
    Page     int               `json:"page"`
    PerPage  int               `json:"per_page"`
    Sort     string            `json:"sort"`
    Order    string            `json:"order"`
    Filters  map[string]string `json:"filters"`
    Search   string            `json:"search"`
}

func parseListUsersRequest(r *http.Request) *ListUsersRequest {
    req := &ListUsersRequest{
        Page:    getIntQuery(r, "page", 1),
        PerPage: getIntQuery(r, "per_page", 20),
        Sort:    r.URL.Query().Get("sort"),
        Order:   r.URL.Query().Get("order"),
        Search:  r.URL.Query().Get("search"),
        Filters: make(map[string]string),
    }
    
    // Parse filters from query parameters
    for key, values := range r.URL.Query() {
        if strings.HasPrefix(key, "filter[") && strings.HasSuffix(key, "]") {
            filterKey := key[7 : len(key)-1]
            if len(values) > 0 {
                req.Filters[filterKey] = values[0]
            }
        }
    }
    
    // Validate pagination
    if req.Page < 1 {
        req.Page = 1
    }
    if req.PerPage < 1 || req.PerPage > 100 {
        req.PerPage = 20
    }
    
    // Validate sort parameters
    allowedSorts := []string{"name", "email", "created_at", "updated_at"}
    if !contains(allowedSorts, req.Sort) {
        req.Sort = "created_at"
    }
    
    if req.Order != "asc" && req.Order != "desc" {
        req.Order = "desc"
    }
    
    return req
}
```

### Comprehensive API Router Setup

```go
func SetupAPIRoutes() http.Handler {
    userService := NewUserService()
    userAPI := NewUserAPI(userService)
    jwtManager := NewJWTManager("secret-key", 24*time.Hour)
    
    r := chi.NewRouter()
    
    // Global middleware
    r.Use(chi.Logger)
    r.Use(chi.Recoverer)
    r.Use(corsMiddleware)
    r.Use(versionMiddleware)
    
    // Health check
    r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        json.NewEncoder(w).Encode(map[string]string{
            "status": "healthy",
            "time":   time.Now().Format(time.RFC3339),
        })
    })
    
    // Public routes
    r.Route("/api", func(r chi.Router) {
        // Authentication endpoints
        r.Post("/login", loginHandler)
        r.Post("/register", registerHandler)
        r.Post("/refresh", refreshTokenHandler)
        
        // API versioning
        r.Route("/v1", func(r chi.Router) {
            r.Use(jwtManager.AuthMiddleware)
            
            // Users resource
            r.Route("/users", func(r chi.Router) {
                r.Get("/", userAPI.ListUsers)
                r.Post("/", RequirePermission(PermissionWrite)(http.HandlerFunc(userAPI.CreateUser)))
                
                r.Route("/{userID}", func(r chi.Router) {
                    r.Get("/", userAPI.GetUser)
                    r.Put("/", RequirePermission(PermissionWrite)(http.HandlerFunc(userAPI.UpdateUser)))
                    r.Delete("/", RequirePermission(PermissionDelete)(http.HandlerFunc(userAPI.DeleteUser)))
                    
                    // Nested resources
                    r.Route("/posts", func(r chi.Router) {
                        r.Get("/", userAPI.GetUserPosts)
                        r.Post("/", RequirePermission(PermissionWrite)(http.HandlerFunc(userAPI.CreateUserPost)))
                    })
                })
            })
            
            // Posts resource
            r.Route("/posts", func(r chi.Router) {
                r.Get("/", postAPI.ListPosts)
                r.Post("/", RequirePermission(PermissionWrite)(http.HandlerFunc(postAPI.CreatePost)))
                
                r.Route("/{postID}", func(r chi.Router) {
                    r.Get("/", postAPI.GetPost)
                    r.Put("/", RequirePermission(PermissionWrite)(http.HandlerFunc(postAPI.UpdatePost)))
                    r.Delete("/", RequirePermission(PermissionDelete)(http.HandlerFunc(postAPI.DeletePost)))
                    
                    // Comments sub-resource
                    r.Route("/comments", func(r chi.Router) {
                        r.Get("/", commentAPI.ListComments)
                        r.Post("/", RequirePermission(PermissionWrite)(http.HandlerFunc(commentAPI.CreateComment)))
                    })
                })
            })
        })
        
        // V2 routes with enhanced features
        r.Route("/v2", func(r chi.Router) {
            r.Use(jwtManager.AuthMiddleware)
            r.Use(rateLimitMiddleware)
            
            r.Route("/users", func(r chi.Router) {
                r.Get("/", userAPI.ListUsersV2)
                r.Post("/", RequirePermission(PermissionWrite)(http.HandlerFunc(userAPI.CreateUserV2)))
                
                r.Route("/{userID}", func(r chi.Router) {
                    r.Get("/", userAPI.GetUserVersioned)
                    r.Patch("/", RequirePermission(PermissionWrite)(http.HandlerFunc(userAPI.PatchUser)))
                    r.Delete("/", RequirePermission(PermissionDelete)(http.HandlerFunc(userAPI.DeleteUser)))
                })
            })
        })
    })
    
    // WebSocket endpoints
    r.Get("/ws", websocketHandler)
    
    return r
}

// Rate limiting middleware
func rateLimitMiddleware(next http.Handler) http.Handler {
    limiter := rate.NewLimiter(rate.Every(time.Minute), 60) // 60 requests per minute
    
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if !limiter.Allow() {
            http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
            return
        }
        next.ServeHTTP(w, r)
    })
}

// Helper functions
func getIntQuery(r *http.Request, key string, defaultValue int) int {
    if value := r.URL.Query().Get(key); value != "" {
        if i, err := strconv.Atoi(value); err == nil {
            return i
        }
    }
    return defaultValue
}

func getUserIDFromPath(r *http.Request) int {
    if userID := chi.URLParam(r, "userID"); userID != "" {
        if id, err := strconv.Atoi(userID); err == nil {
            return id
        }
    }
    return 0
}

func contains(slice []string, item string) bool {
    for _, s := range slice {
        if s == item {
            return true
        }
    }
    return false
}

func formatValidationError(err error) error {
    var errors []string
    for _, err := range err.(validator.ValidationErrors) {
        errors = append(errors, fmt.Sprintf("%s is %s", err.Field(), err.Tag()))
    }
    return fmt.Errorf("validation failed: %s", strings.Join(errors, ", "))
}
```

**Key Points:**

- RESTful APIs follow resource-based URL patterns with appropriate HTTP methods
- Consistent response formats improve API usability
- Version management supports API evolution without breaking existing clients
- Request validation ensures data integrity and security
- Middleware chains provide cross-cutting concerns like authentication, rate limiting, and logging
- Nested resources represent hierarchical relationships between entities
- Proper HTTP status codes communicate operation results clearly

**Examples** demonstrate comprehensive web development patterns in Go, from basic HTTP handling to sophisticated API architectures with authentication, authorization, and versioning capabilities.

Important related topics include WebSocket integration for real-time features, GraphQL implementation for flexible data querying, microservices architecture patterns, API documentation with OpenAPI/Swagger, and performance optimization techniques for high-traffic applications.

---

