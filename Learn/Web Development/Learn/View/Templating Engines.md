# EJS, Pug, and Handlebars

These three—**EJS, Pug, and Handlebars**—are all **templating engines** used mainly in Node.js (especially with Express.js) to generate dynamic HTML. But they differ a lot in philosophy and syntax.

---

## 🔹 1. EJS (Embedded JavaScript)

**Core idea:** Write HTML normally, sprinkle JavaScript inside.

#### Example

```ejs
<h1>Hello <%= user %></h1>

<% if (isAdmin) { %>
  <p>Welcome, admin!</p>
<% } %>
```

#### Key Traits

- Feels like **plain HTML + JS**
- Uses `<% %>` for logic, `<%= %>` for output
- Very flexible (you can run any JS)

#### Pros

- Easy to learn if you know HTML + JS
- No new syntax to memorize
- Full control with JavaScript

#### Cons

- Can become messy (mixing logic + markup)
- Harder to maintain in large apps
    

👉 **Best for:** Beginners, small projects, or when you want full JS power inside templates.

---

## 🔹 2. Pug (formerly Jade)

**Core idea:** Use a **clean, indentation-based syntax** instead of HTML.

#### Example

```pug
h1 Hello #{user}

if isAdmin
  p Welcome, admin!
```

#### Key Traits

- No closing tags
- Uses indentation like Python
- Very concise

#### Pros

- Super clean and minimal
- Less typing than HTML
- Great for structured layouts

#### Cons

- Learning curve (not HTML-like)
- Debugging can be tricky
- Whitespace-sensitive
    

👉 **Best for:** Developers who want **clean, DRY templates** and don’t mind new syntax.

---

## 🔹 3. Handlebars

**Core idea:** Logic-less (or minimal logic) templating.

#### Example

```handlebars
<h1>Hello {{user}}</h1>

{{#if isAdmin}}
  <p>Welcome, admin!</p>
{{/if}}
```

#### Key Traits

- Uses `{{ }}` expressions
- Separates logic from templates
- Encourages clean architecture

#### Pros

- Clean separation of concerns
- Safer (less arbitrary JS execution)
- Reusable components (partials/helpers)

#### Cons

- Limited logic inside templates
- Requires helpers for complex behavior
    

👉 **Best for:** Large apps where **maintainability and separation** matter.

---

## ⚖️ Quick Comparison

|Feature|EJS|Pug|Handlebars|
|---|---|---|---|
|Syntax style|HTML + JS|Indentation-based|HTML + placeholders|
|Logic capability|Full JS|Moderate|Limited|
|Learning curve|Easy|Medium|Easy–Medium|
|Maintainability|Medium|High|High|
|Flexibility|Very high|High|Controlled|

---

## 🧠 When to Choose What

- Pick **EJS** → if you want **freedom and simplicity**
- Pick **Pug** → if you want **clean, compact templates**
- Pick **Handlebars** → if you want **strict structure and scalability**

---