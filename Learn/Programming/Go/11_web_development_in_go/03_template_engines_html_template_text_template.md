## Template Engines (html/template, text/template)


### HTML Templates

Go's `html/template` package provides secure template rendering with automatic escaping:

```go
package main

import (
    "html/template"
    "net/http"
    "time"
)

type PageData struct {
    Title       string
    User        User
    Posts       []Post
    CurrentTime time.Time
    IsLoggedIn  bool
}

type Post struct {
    ID      int
    Title   string
    Content string
    Author  string
    Created time.Time
}

// Template functions
var funcMap = template.FuncMap{
    "formatDate": func(t time.Time) string {
        return t.Format("January 2, 2006")
    },
    "truncate": func(s string, length int) string {
        if len(s) > length {
            return s[:length] + "..."
        }
        return s
    },
    "add": func(a, b int) int {
        return a + b
    },
}

// Template parsing and caching
var templates = template.Must(template.New("").Funcs(funcMap).ParseGlob("templates/*.html"))

func homeHandler(w http.ResponseWriter, r *http.Request) {
    data := PageData{
        Title:       "Welcome Home",
        User:        getCurrentUser(r),
        Posts:       getRecentPosts(),
        CurrentTime: time.Now(),
        IsLoggedIn:  isUserLoggedIn(r),
    }
    
    if err := templates.ExecuteTemplate(w, "home.html", data); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
}
```

Template files demonstrate Go's template syntax:

```html
<!-- templates/base.html -->
<!DOCTYPE html>
<html>
<head>
    <title>{{.Title}} - My App</title>
    <meta charset="utf-8">
    <link rel="stylesheet" href="/static/css/style.css">
</head>
<body>
    {{template "header" .}}
    
    <main>
        {{template "content" .}}
    </main>
    
    {{template "footer" .}}
</body>
</html>

<!-- templates/home.html -->
{{template "base.html" .}}

{{define "content"}}
<div class="welcome">
    {{if .IsLoggedIn}}
        <h1>Welcome back, {{.User.Name}}!</h1>
    {{else}}
        <h1>Welcome, Guest!</h1>
        <a href="/login">Login</a>
    {{end}}
</div>

<div class="posts">
    <h2>Recent Posts</h2>
    {{range .Posts}}
    <article class="post">
        <h3><a href="/posts/{{.ID}}">{{.Title}}</a></h3>
        <p>{{truncate .Content 150}}</p>
        <footer>
            By {{.Author}} on {{formatDate .Created}}
        </footer>
    </article>
    {{else}}
    <p>No posts available.</p>
    {{end}}
</div>
{{end}}

{{define "header"}}
<header>
    <nav>
        <a href="/">Home</a>
        {{if .IsLoggedIn}}
            <a href="/profile">Profile</a>
            <a href="/logout">Logout</a>
        {{else}}
            <a href="/login">Login</a>
            <a href="/register">Register</a>
        {{end}}
    </nav>
</header>
{{end}}

{{define "footer"}}
<footer>
    <p>&copy; {{.CurrentTime.Year}} My App. All rights reserved.</p>
</footer>
{{end}}
```

### Advanced Template Patterns

```go
// Template inheritance and composition
type TemplateRenderer struct {
    templates *template.Template
}

func NewTemplateRenderer(pattern string) (*TemplateRenderer, error) {
    templates := template.New("").Funcs(funcMap)
    templates, err := templates.ParseGlob(pattern)
    if err != nil {
        return nil, err
    }
    
    return &TemplateRenderer{templates: templates}, nil
}

func (tr *TemplateRenderer) Render(w http.ResponseWriter, name string, data interface{}) error {
    return tr.templates.ExecuteTemplate(w, name, data)
}

// Template with custom types
type SafeHTML string

func (s SafeHTML) String() string {
    return string(s)
}

// Form handling with templates
type FormData struct {
    Values map[string]string
    Errors map[string]string
    CSRF   string
}

func contactFormHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method == http.MethodPost {
        // Process form
        form := FormData{
            Values: map[string]string{
                "name":    r.FormValue("name"),
                "email":   r.FormValue("email"),
                "message": r.FormValue("message"),
            },
            Errors: make(map[string]string),
        }
        
        // Validation
        if form.Values["name"] == "" {
            form.Errors["name"] = "Name is required"
        }
        if form.Values["email"] == "" {
            form.Errors["email"] = "Email is required"
        }
        
        if len(form.Errors) == 0 {
            // Process successful submission
            http.Redirect(w, r, "/contact/success", http.StatusSeeOther)
            return
        }
        
        // Re-render with errors
        templates.ExecuteTemplate(w, "contact.html", form)
        return
    }
    
    // GET request - show empty form
    form := FormData{
        Values: make(map[string]string),
        Errors: make(map[string]string),
        CSRF:   generateCSRFToken(),
    }
    templates.ExecuteTemplate(w, "contact.html", form)
}
```

**Key Points:**

- HTML templates provide automatic XSS protection through escaping
- Template functions enable custom formatting and logic
- Template inheritance supports DRY principles
- Form handling integrates naturally with template rendering

