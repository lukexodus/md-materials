## Authentication and Authorization


### JWT-Based Authentication

```go
package auth

import (
    "errors"
    "time"
    
    "github.com/golang-jwt/jwt/v5"
)

type Claims struct {
    UserID   int      `json:"user_id"`
    Username string   `json:"username"`
    Roles    []string `json:"roles"`
    jwt.RegisteredClaims
}

type JWTManager struct {
    secretKey     string
    tokenDuration time.Duration
}

func NewJWTManager(secretKey string, tokenDuration time.Duration) *JWTManager {
    return &JWTManager{
        secretKey:     secretKey,
        tokenDuration: tokenDuration,
    }
}

func (manager *JWTManager) Generate(userID int, username string, roles []string) (string, error) {
    claims := Claims{
        UserID:   userID,
        Username: username,
        Roles:    roles,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(manager.tokenDuration)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            NotBefore: jwt.NewNumericDate(time.Now()),
        },
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(manager.secretKey))
}

func (manager *JWTManager) Verify(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(
        tokenString,
        &Claims{},
        func(token *jwt.Token) (interface{}, error) {
            return []byte(manager.secretKey), nil
        },
    )
    
    if err != nil {
        return nil, err
    }
    
    claims, ok := token.Claims.(*Claims)
    if !ok || !token.Valid {
        return nil, errors.New("invalid token")
    }
    
    return claims, nil
}

// Authentication middleware
func (manager *JWTManager) AuthMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            http.Error(w, "Authorization header required", http.StatusUnauthorized)
            return
        }
        
        tokenString := strings.TrimPrefix(authHeader, "Bearer ")
        claims, err := manager.Verify(tokenString)
        if err != nil {
            http.Error(w, "Invalid token", http.StatusUnauthorized)
            return
        }
        
        // Add claims to context
        ctx := context.WithValue(r.Context(), "claims", claims)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

### Role-Based Authorization

```go
type Permission string

const (
    PermissionRead   Permission = "read"
    PermissionWrite  Permission = "write"
    PermissionDelete Permission = "delete"
    PermissionAdmin  Permission = "admin"
)

type Role struct {
    Name        string
    Permissions []Permission
}

var roles = map[string]Role{
    "user": {
        Name:        "user",
        Permissions: []Permission{PermissionRead},
    },
    "editor": {
        Name:        "user",
        Permissions: []Permission{PermissionRead, PermissionWrite},
    },
    "admin": {
        Name:        "admin",
        Permissions: []Permission{PermissionRead, PermissionWrite, PermissionDelete, PermissionAdmin},
    },
}

func RequirePermission(permission Permission) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            claims, ok := r.Context().Value("claims").(*Claims)
            if !ok {
                http.Error(w, "Unauthorized", http.StatusUnauthorized)
                return
            }
            
            if !hasPermission(claims.Roles, permission) {
                http.Error(w, "Forbidden", http.StatusForbidden)
                return
            }
            
            next.ServeHTTP(w, r)
        })
    }
}

func hasPermission(userRoles []string, required Permission) bool {
    for _, roleName := range userRoles {
        if role, exists := roles[roleName]; exists {
            for _, perm := range role.Permissions {
                if perm == required || perm == PermissionAdmin {
                    return true
                }
            }
        }
    }
    return false
}

// Usage
func setupProtectedRoutes() {
    // Public routes
    http.HandleFunc("/login", loginHandler)
    http.HandleFunc("/register", registerHandler)
    
    // Protected routes
    protectedMux := http.NewServeMux()
    protectedMux.Handle("/profile", RequirePermission(PermissionRead)(http.HandlerFunc(profileHandler)))
    protectedMux.Handle("/edit", RequirePermission(PermissionWrite)(http.HandlerFunc(editHandler)))
    protectedMux.Handle("/admin", RequirePermission(PermissionAdmin)(http.HandlerFunc(adminHandler)))
    
    http.Handle("/", jwtManager.AuthMiddleware(protectedMux))
}
```

**Key Points:**

- JWT tokens enable stateless authentication
- Role-based access control provides granular permissions
- Middleware chain enforces authentication and authorization
- Context passes user information through the request pipeline

