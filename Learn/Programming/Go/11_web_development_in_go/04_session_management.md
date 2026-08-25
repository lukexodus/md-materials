## Session Management


### Cookie-Based Sessions

```go
package session

import (
    "crypto/rand"
    "encoding/base64"
    "net/http"
    "sync"
    "time"
)

type Session struct {
    ID      string
    Data    map[string]interface{}
    Created time.Time
    LastAccess time.Time
}

type SessionManager struct {
    sessions map[string]*Session
    mutex    sync.RWMutex
    timeout  time.Duration
}

func NewSessionManager(timeout time.Duration) *SessionManager {
    sm := &SessionManager{
        sessions: make(map[string]*Session),
        timeout:  timeout,
    }
    
    // Cleanup goroutine
    go sm.cleanup()
    
    return sm
}

func (sm *SessionManager) CreateSession(w http.ResponseWriter) *Session {
    sm.mutex.Lock()
    defer sm.mutex.Unlock()
    
    sessionID := sm.generateSessionID()
    session := &Session{
        ID:         sessionID,
        Data:       make(map[string]interface{}),
        Created:    time.Now(),
        LastAccess: time.Now(),
    }
    
    sm.sessions[sessionID] = session
    
    cookie := &http.Cookie{
        Name:     "session_id",
        Value:    sessionID,
        Path:     "/",
        HttpOnly: true,
        Secure:   true, // Set based on HTTPS
        SameSite: http.SameSiteLaxMode,
        MaxAge:   int(sm.timeout.Seconds()),
    }
    
    http.SetCookie(w, cookie)
    return session
}

func (sm *SessionManager) GetSession(r *http.Request) *Session {
    cookie, err := r.Cookie("session_id")
    if err != nil {
        return nil
    }
    
    sm.mutex.RLock()
    session, exists := sm.sessions[cookie.Value]
    sm.mutex.RUnlock()
    
    if !exists {
        return nil
    }
    
    // Check timeout
    if time.Since(session.LastAccess) > sm.timeout {
        sm.DestroySession(cookie.Value)
        return nil
    }
    
    // Update last access
    sm.mutex.Lock()
    session.LastAccess = time.Now()
    sm.mutex.Unlock()
    
    return session
}

func (sm *SessionManager) DestroySession(sessionID string) {
    sm.mutex.Lock()
    delete(sm.sessions, sessionID)
    sm.mutex.Unlock()
}

func (sm *SessionManager) generateSessionID() string {
    bytes := make([]byte, 32)
    rand.Read(bytes)
    return base64.URLEncoding.EncodeToString(bytes)
}

func (sm *SessionManager) cleanup() {
    ticker := time.NewTicker(time.Hour)
    for range ticker.C {
        sm.mutex.Lock()
        for id, session := range sm.sessions {
            if time.Since(session.LastAccess) > sm.timeout {
                delete(sm.sessions, id)
            }
        }
        sm.mutex.Unlock()
    }
}
```

### Session Middleware

```go
func (sm *SessionManager) SessionMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        session := sm.GetSession(r)
        
        // Create new session if none exists
        if session == nil {
            session = sm.CreateSession(w)
        }
        
        // Add session to context
        ctx := context.WithValue(r.Context(), "session", session)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

// Helper function to get session from context
func GetSession(r *http.Request) *Session {
    if session, ok := r.Context().Value("session").(*Session); ok {
        return session
    }
    return nil
}

// Usage in handlers
func loginHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method == http.MethodPost {
        username := r.FormValue("username")
        password := r.FormValue("password")
        
        if authenticateUser(username, password) {
            session := GetSession(r)
            session.Data["userID"] = getUserID(username)
            session.Data["username"] = username
            session.Data["authenticated"] = true
            
            http.Redirect(w, r, "/dashboard", http.StatusSeeOther)
            return
        }
        
        // Handle login failure
        renderLogin(w, "Invalid credentials")
        return
    }
    
    renderLogin(w, "")
}
```

**Key Points:**

- Session data is stored server-side with session ID in cookies
- Automatic cleanup prevents memory leaks from abandoned sessions
- Middleware pattern integrates sessions transparently
- Secure cookie settings protect against common attacks

