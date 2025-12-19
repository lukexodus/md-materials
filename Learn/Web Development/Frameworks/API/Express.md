# Syllabus

## Module 1: Express.js Fundamentals

- What is Express.js and Node.js ecosystem
- Express.js architecture and philosophy
- Installation and project setup
- Basic server creation and configuration
- Express.js vs other Node.js frameworks
- Development environment setup

## Module 2: Node.js Prerequisites

- JavaScript ES6+ features for backend
- Node.js runtime and event loop
- CommonJS and ES modules
- npm and package management
- Asynchronous programming patterns
- File system and path operations

## Module 3: Basic Routing

- Route definition and HTTP methods
- Route parameters and wildcards
- Query parameters and request parsing
- Route handlers and callback functions
- Basic response methods
- Route organization patterns

## Module 4: Middleware Fundamentals

- Middleware concept and execution flow
- Application-level middleware
- Router-level middleware
- Built-in middleware overview
- Third-party middleware integration
- Custom middleware creation

## Module 5: Request and Response Objects

- Request object properties and methods
- Response object properties and methods
- Request body parsing and validation
- File uploads and multipart data
- Response formatting and headers
- Cookie handling

## Module 6: Routing Advanced Patterns

- Route parameters and regular expressions
- Route handlers with multiple callbacks
- Router modules and modular routing
- Route validation and sanitization
- Dynamic route generation
- Route testing strategies

## Module 7: Template Engines

- Template engine integration (EJS, Pug, Handlebars)
- View rendering and data passing
- Layout and partial templates
- Template inheritance patterns
- Static file serving
- Asset management strategies

## Module 8: Middleware Deep Dive

- Error handling middleware
- Middleware execution order
- Conditional middleware application
- Middleware composition patterns
- Performance middleware considerations
- Security middleware implementation

## Module 9: Database Integration

- Database connection strategies
- SQL database integration (MySQL, PostgreSQL)
- NoSQL database integration (MongoDB)
- ORM and ODM integration (Sequelize, Mongoose)
- Connection pooling and management
- Database migration strategies

## Module 10: Authentication and Authorization

- Session-based authentication
- JWT (JSON Web Token) implementation
- OAuth integration patterns
- Passport.js middleware integration
- Role-based access control
- Authentication middleware chains

## Module 11: Security Best Practices

- HTTPS configuration and enforcement
- Cross-Site Request Forgery (CSRF) protection
- Cross-Origin Resource Sharing (CORS)
- Rate limiting and DDoS protection
- Input validation and sanitization
- Security headers and helmet.js

## Module 12: Error Handling

- Error handling middleware patterns
- Synchronous vs asynchronous error handling
- Custom error classes and types
- Error logging and monitoring
- Graceful error responses
- Development vs production error handling

## Module 13: File Operations and Uploads

- File upload handling with multer
- File validation and security
- File storage strategies (local, cloud)
- Image processing and optimization
- Stream handling for large files
- File download and serving

## Module 14: API Development

- RESTful API design principles
- API versioning strategies
- Request/response serialization
- API documentation with OpenAPI/Swagger
- Content negotiation
- API rate limiting and throttling

## Module 15: Data Validation and Serialization

- Input validation libraries (Joi, express-validator)
- Request schema validation
- Data transformation and serialization
- Response formatting standards
- Validation error handling
- Custom validation rules

## Module 16: Testing Express Applications

- Unit testing with Jest/Mocha
- Integration testing strategies
- API endpoint testing
- Middleware testing patterns
- Mock and stub implementations
- Test database management

## Module 17: Performance Optimization

- Application profiling and monitoring
- Caching strategies (in-memory, Redis)
- Response compression and optimization
- Database query optimization
- Memory leak detection and prevention
- Load testing and benchmarking

## Module 18: Logging and Monitoring

- Logging libraries and best practices
- Structured logging patterns
- Request/response logging middleware
- Application performance monitoring
- Health checks and status endpoints
- Log aggregation and analysis

## Module 19: Configuration Management

- Environment-based configuration
- Configuration file management
- Environment variables and secrets
- Feature flags and toggles
- Configuration validation
- Dynamic configuration updates

## Module 20: WebSocket Integration

- WebSocket server setup with Socket.IO
- Real-time communication patterns
- Room and namespace management
- WebSocket authentication
- Scaling WebSocket connections
- WebSocket testing strategies

## Module 21: Background Jobs and Task Queues

- Job queue implementation with Bull/Agenda
- Scheduled task management
- Background processing patterns
- Job retry and failure handling
- Queue monitoring and management
- Distributed job processing

## Module 22: Microservices Architecture

- Service decomposition strategies
- Inter-service communication patterns
- Service discovery and registration
- API gateway integration
- Distributed tracing and monitoring
- Service mesh integration

## Module 23: Docker and Containerization

- Dockerizing Express.js applications
- Multi-stage Docker builds
- Container orchestration basics
- Health checks and readiness probes
- Container security best practices
- Development vs production containers

## Module 24: Cloud Deployment

- Cloud platform deployment (AWS, GCP, Azure)
- Serverless deployment patterns
- Load balancer configuration
- Auto-scaling strategies
- Blue-green deployment
- Infrastructure as Code

## Module 25: CI/CD Integration

- Continuous Integration setup
- Automated testing pipelines
- Code quality checks and linting
- Security scanning integration
- Deployment automation
- Rollback strategies

## Module 26: GraphQL Integration

- GraphQL server setup with Apollo
- Schema definition and resolvers
- Query optimization and N+1 problem
- Authentication in GraphQL
- Subscription handling
- GraphQL testing strategies

## Module 27: Advanced Security

- API security best practices
- Input sanitization and XSS prevention
- SQL injection prevention
- Security audit and vulnerability scanning
- Secure coding practices
- Compliance and regulatory requirements

## Module 28: Scaling and Load Balancing

- Horizontal vs vertical scaling
- Load balancing strategies
- Session management in scaled environments
- Database scaling considerations
- Caching layers and CDN integration
- Performance monitoring at scale

## Module 29: Debugging and Troubleshooting

- Debugging tools and techniques
- Memory leak investigation
- Performance bottleneck identification
- Error tracking and alerting
- Log analysis and pattern recognition
- Production debugging strategies

## Module 30: Express.js Ecosystem

- Popular Express.js middleware libraries
- Framework alternatives and comparisons
- Community resources and contributions
- Express.js evolution and roadmap
- Migration strategies for major versions
- Best practices and patterns library

## Module 31: Advanced Patterns and Architecture

- Dependency injection patterns
- Event-driven architecture
- CQRS and Event Sourcing
- Clean architecture principles
- Domain-driven design integration
- Hexagonal architecture patterns

## Module 32: Real-World Projects

- E-commerce API development
- Social media application backend
- Content management system
- Real-time chat application
- Enterprise business application
- Multi-tenant SaaS platform

## Module 33: Code Quality and Maintenance

- Code style and linting configuration
- Refactoring strategies and techniques
- Technical debt management
- Documentation generation and maintenance
- Code review processes
- Legacy code modernization

## Module 34: Advanced Topics

- Custom Express.js extensions
- Performance profiling and optimization
- Memory management and garbage collection
- Clustering and process management
- Custom protocol implementations
- Advanced middleware patterns

## Module 35: Enterprise Integration

- Enterprise service bus integration
- Legacy system integration patterns
- API management platforms
- Enterprise security compliance
- Audit logging and compliance
- Enterprise monitoring and alerting

---

# Quick Guide

### Introduction

Express.js is a minimal, flexible, and unopinionated web application framework for Node.js that provides a robust set of features for building single-page, multi-page, and hybrid web applications. Since its initial release in 2010, it has become the de facto standard server framework for Node.js, powering numerous production applications around the world.

**Key Points**:

- Created by TJ Holowaychuk in 2010
- Minimalist philosophy with extensible middleware architecture
- Runs on Node.js and provides a thin layer of web application features
- Doesn't enforce specific project structures or patterns
- Open source and maintained by the OpenJS Foundation
- Powers many popular frameworks like NestJS, Sails.js, and LoopBack

### Core Features

#### Routing

Express provides a simple and powerful routing system to define how an application responds to client requests to specific endpoints (URIs) and HTTP methods.

```javascript
const express = require('express');
const app = express();

// Basic route
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Route with parameters
app.get('/users/:userId', (req, res) => {
  res.send(`User ID: ${req.params.userId}`);
});

// Route with query parameters
app.get('/search', (req, res) => {
  res.send(`Search term: ${req.query.term}`);
});

// POST route
app.post('/users', (req, res) => {
  // Create new user
  res.status(201).send('User created');
});
```

#### Middleware

Middleware functions are functions that have access to the request object, the response object, and the next middleware function in the application's request-response cycle. They can:

- Execute any code
- Make changes to the request and response objects
- End the request-response cycle
- Call the next middleware function

```javascript
// Custom middleware example
const loggerMiddleware = (req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
};

// Use middleware
app.use(loggerMiddleware);

// Built-in middleware
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(express.static('public')); // Serve static files
```

#### Request Object

The `req` object represents the HTTP request and has properties for the request query string, parameters, body, headers, and more.

```javascript
app.get('/example', (req, res) => {
  console.log(req.query);     // Query parameters: ?name=value
  console.log(req.params);    // Route parameters: /users/:id
  console.log(req.body);      // Request body (requires body-parser)
  console.log(req.headers);   // Request headers
  console.log(req.cookies);   // Cookies (requires cookie-parser)
  console.log(req.path);      // Path part of URL
  console.log(req.ip);        // Client IP address
  console.log(req.method);    // HTTP method
  console.log(req.protocol);  // Request protocol (http/https)
  console.log(req.secure);    // Is connection secure
});
```

#### Response Object

The `res` object represents the HTTP response that an Express app sends when it gets an HTTP request.

```javascript
app.get('/response-examples', (req, res) => {
  // Different ways to send responses
  res.send('Hello World');             // Send text
  res.json({ message: 'Hello World' }); // Send JSON
  res.status(404).send('Not Found');   // Set status and send
  res.sendFile('/path/to/file.pdf');   // Send a file
  res.download('/report.pdf');         // Force download
  res.redirect('/new-page');           // Redirect
  res.render('index', { title: 'Hey' }); // Render view template (requires view engine)
  res.set('Content-Type', 'text/html'); // Set header
  res.cookie('name', 'value');         // Set cookie
  res.clearCookie('name');             // Clear cookie
  res.end();                           // End response without data
});
```

#### Error Handling

Express provides built-in error handling that can be extended with custom error handlers.

```javascript
// Custom 404 handler
app.use((req, res, next) => {
  res.status(404).send("Sorry, can't find that!");
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// Using try/catch in async handlers
app.get('/async', async (req, res, next) => {
  try {
    const result = await someAsyncOperation();
    res.json(result);
  } catch (error) {
    next(error); // Pass to Express error handler
  }
});
```

### Setting Up an Express Application

#### Basic Setup

```javascript
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Routes
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Start server
app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
```

#### Project Structure

Express doesn't enforce any specific project structure, but here's a common organization pattern:

```
project-root/
├── node_modules/
├── public/              # Static assets
│   ├── css/
│   ├── js/
│   └── images/
├── views/               # Template files
│   ├── partials/
│   └── pages/
├── routes/              # Route handlers
│   ├── index.js
│   └── users.js
├── controllers/         # Route logic
│   └── userController.js
├── models/              # Data models
│   └── User.js
├── middleware/          # Custom middleware
│   └── auth.js
├── config/              # Configuration files
│   └── database.js
├── utils/               # Utility functions
│   └── helpers.js
├── tests/               # Test files
├── app.js               # Application entry point
├── package.json
└── README.md
```

### Routing in Depth

#### Router Instance

The `express.Router` class creates modular, mountable route handlers.

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.send('Users list');
});

router.get('/:id', (req, res) => {
  res.send(`User: ${req.params.id}`);
});

router.post('/', (req, res) => {
  res.send('Create user');
});

module.exports = router;

// app.js
const usersRouter = require('./routes/users');
app.use('/users', usersRouter);
```

#### Route Methods

Express supports all HTTP methods:

```javascript
router.get('/resource', handler);      // GET
router.post('/resource', handler);     // POST
router.put('/resource', handler);      // PUT
router.delete('/resource', handler);   // DELETE
router.patch('/resource', handler);    // PATCH
router.options('/resource', handler);  // OPTIONS
router.head('/resource', handler);     // HEAD

// Handle multiple methods for the same path
router.route('/resource')
  .get((req, res) => {
    // Get resource
  })
  .post((req, res) => {
    // Create resource
  })
  .put((req, res) => {
    // Update resource
  });
```

#### Route Parameters

Route parameters are named URL segments used to capture values.

```javascript
// Required parameters
app.get('/users/:userId/books/:bookId', (req, res) => {
  // req.params: { "userId": "34", "bookId": "8989" }
  res.send(req.params);
});

// Optional parameters
app.get('/users/:userId?', (req, res) => {
  // userId is optional
  const userId = req.params.userId || 'all users';
  res.send(`Showing info for ${userId}`);
});

// Parameter middleware
app.param('userId', (req, res, next, id) => {
  // Load user by ID
  req.user = { id, name: 'Test User' };
  next();
});
```

#### Route Handlers

Route handlers can be single functions, a series of functions, or arrays of functions.

```javascript
// Single handler
app.get('/example', (req, res) => {
  res.send('Single handler');
});

// Multiple handlers as separate arguments
app.get('/example', 
  (req, res, next) => {
    console.log('First handler');
    next();
  },
  (req, res) => {
    res.send('Second handler');
  }
);

// Array of handlers
const validate = (req, res, next) => {
  // Validation logic
  next();
};

const loadData = (req, res, next) => {
  // Data loading logic
  next();
};

app.get('/example', [validate, loadData], (req, res) => {
  res.send('After middleware array');
});
```

### Middleware in Depth

#### Types of Middleware

Express applications can use several types of middleware:

1. Application-level middleware
2. Router-level middleware
3. Error-handling middleware
4. Built-in middleware
5. Third-party middleware

```javascript
// Application-level middleware
app.use((req, res, next) => {
  // Runs for every request
  next();
});

// Router-level middleware
router.use((req, res, next) => {
  // Runs for requests to this router only
  next();
});

// Path-specific middleware
app.use('/api', (req, res, next) => {
  // Runs only for paths starting with /api
  next();
});

// Method-specific middleware
app.get('*', (req, res, next) => {
  // Runs only for GET requests
  next();
});
```

#### Common Third-Party Middleware

```javascript
// Body parsers
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Cookie parser
const cookieParser = require('cookie-parser');
app.use(cookieParser());

// CORS
const cors = require('cors');
app.use(cors());

// Compression
const compression = require('compression');
app.use(compression());

// Helmet (security headers)
const helmet = require('helmet');
app.use(helmet());

// Morgan (logging)
const morgan = require('morgan');
app.use(morgan('dev'));

// Session management
const session = require('express-session');
app.use(session({
  secret: 'keyboard cat',
  resave: false,
  saveUninitialized: true
}));
```

#### Custom Middleware Best Practices

```javascript
// Middleware structure
function myMiddleware(options) {
  // Middleware initialization
  return function(req, res, next) {
    // Middleware logic
    next();
  };
}

// Error handling
function errorMiddleware(options) {
  return function(req, res, next) {
    try {
      // Risky operation
      next();
    } catch (error) {
      next(error);
    }
  };
}

// Async middleware
function asyncMiddleware(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next))
      .catch(next);
  };
}

app.get('/async', asyncMiddleware(async (req, res) => {
  const result = await someAsyncOperation();
  res.json(result);
}));
```

### Template Engines and Views

Express can be configured to use various template engines like EJS, Pug, Handlebars, etc.

```javascript
// Set up template engine
app.set('view engine', 'ejs');
app.set('views', './views');

// Render a view
app.get('/', (req, res) => {
  res.render('index', { 
    title: 'Express',
    message: 'Welcome to Express!'
  });
});
```

#### EJS Example

```javascript
// views/index.ejs
<!DOCTYPE html>
<html>
<head>
  <title><%= title %></title>
</head>
<body>
  <h1><%= message %></h1>
  <ul>
    <% items.forEach(function(item) { %>
      <li><%= item.name %></li>
    <% }); %>
  </ul>
</body>
</html>
```

#### Pug Example

```javascript
// views/index.pug
doctype html
html
  head
    title= title
  body
    h1= message
    ul
      each item in items
        li= item.name
```

#### Handlebars Example

```javascript
// views/index.handlebars
<!DOCTYPE html>
<html>
<head>
  <title>{{title}}</title>
</head>
<body>
  <h1>{{message}}</h1>
  <ul>
    {{#each items}}
      <li>{{this.name}}</li>
    {{/each}}
  </ul>
</body>
</html>
```

### Database Integration

Express can work with any database that has Node.js drivers. Here are some examples:

#### MongoDB with Mongoose

```javascript
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/myapp', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Define schema
const userSchema = new mongoose.Schema({
  name: String,
  email: { type: String, required: true, unique: true },
  age: Number,
  createdAt: { type: Date, default: Date.now }
});

// Create model
const User = mongoose.model('User', userSchema);

// Use in routes
app.get('/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

app.post('/users', async (req, res) => {
  const user = new User(req.body);
  try {
    const newUser = await user.save();
    res.status(201).json(newUser);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});
```

#### SQL with Sequelize (ORM)

```javascript
const { Sequelize, DataTypes } = require('sequelize');
const sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhost',
  dialect: 'mysql' // or 'postgres', 'sqlite', 'mssql'
});

// Define model
const User = sequelize.define('User', {
  name: {
    type: DataTypes.STRING
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  age: {
    type: DataTypes.INTEGER
  }
});

// Use in routes
app.get('/users', async (req, res) => {
  try {
    const users = await User.findAll();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
```

### Authentication

Express doesn't include authentication out of the box, but it's easy to implement with middleware.

#### JWT Authentication

```javascript
const jwt = require('jsonwebtoken');
const SECRET_KEY = 'your-secret-key';

// Authentication middleware
function authenticate(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, SECRET_KEY);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Invalid token' });
  }
}

// Login route
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  // Authenticate user (implementation depends on your DB)
  const user = await findUserByCredentials(username, password);
  
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  
  // Generate token
  const token = jwt.sign(
    { id: user.id, username: user.username },
    SECRET_KEY,
    { expiresIn: '1h' }
  );
  
  res.json({ token });
});

// Protected route
app.get('/protected', authenticate, (req, res) => {
  res.json({ message: 'Protected data', user: req.user });
});
```

#### Passport.js Integration

```javascript
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;

// Set up passport
app.use(passport.initialize());
app.use(passport.session());

passport.use(new LocalStrategy(
  async (username, password, done) => {
    try {
      const user = await User.findOne({ username });
      
      if (!user) {
        return done(null, false, { message: 'Incorrect username' });
      }
      
      const isValid = await user.validatePassword(password);
      
      if (!isValid) {
        return done(null, false, { message: 'Incorrect password' });
      }
      
      return done(null, user);
    } catch (err) {
      return done(err);
    }
  }
));

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (err) {
    done(err);
  }
});

// Login route
app.post('/login', passport.authenticate('local'), (req, res) => {
  res.json({ message: 'Logged in successfully', user: req.user });
});

// Logout route
app.get('/logout', (req, res) => {
  req.logout();
  res.json({ message: 'Logged out successfully' });
});

// Protected route
app.get('/profile', isAuthenticated, (req, res) => {
  res.json({ user: req.user });
});

function isAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return next();
  }
  res.status(401).json({ message: 'Not authenticated' });
}
```

### REST API Development

Express is commonly used to build RESTful APIs. Here's a complete example:

```javascript
const express = require('express');
const router = express.Router();

// GET all resources
router.get('/api/resources', async (req, res) => {
  try {
    const resources = await Resource.find();
    res.json(resources);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET a single resource
router.get('/api/resources/:id', getResource, (req, res) => {
  res.json(res.resource);
});

// POST a new resource
router.post('/api/resources', async (req, res) => {
  const resource = new Resource(req.body);
  
  try {
    const newResource = await resource.save();
    res.status(201).json(newResource);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// PUT (update) a resource
router.put('/api/resources/:id', getResource, async (req, res) => {
  Object.assign(res.resource, req.body);
  
  try {
    const updatedResource = await res.resource.save();
    res.json(updatedResource);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// PATCH (partial update) a resource
router.patch('/api/resources/:id', getResource, async (req, res) => {
  if (req.body.name != null) {
    res.resource.name = req.body.name;
  }
  // ... other fields
  
  try {
    const updatedResource = await res.resource.save();
    res.json(updatedResource);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE a resource
router.delete('/api/resources/:id', getResource, async (req, res) => {
  try {
    await res.resource.remove();
    res.json({ message: 'Resource deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get resource by ID
async function getResource(req, res, next) {
  try {
    const resource = await Resource.findById(req.params.id);
    
    if (resource == null) {
      return res.status(404).json({ message: 'Resource not found' });
    }
    
    res.resource = resource;
    next();
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
}
```

### Performance Optimization

#### Compression

```javascript
const compression = require('compression');

// Use compression middleware
app.use(compression());
```

#### Response Caching

```javascript
// Using cache-control headers
app.get('/api/data', (req, res) => {
  res.set('Cache-Control', 'public, max-age=300'); // Cache for 5 minutes
  res.json(data);
});

// Using memory-cache
const mcache = require('memory-cache');

const cache = (duration) => {
  return (req, res, next) => {
    const key = '__express__' + req.originalUrl || req.url;
    const cachedBody = mcache.get(key);
    
    if (cachedBody) {
      res.send(cachedBody);
      return;
    }
    
    res.sendResponse = res.send;
    res.send = (body) => {
      mcache.put(key, body, duration * 1000);
      res.sendResponse(body);
    };
    
    next();
  };
};

app.get('/api/data', cache(30), (req, res) => {
  // This response will be cached for 30 seconds
  res.json(data);
});
```

#### Clustering

```javascript
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  console.log(`Master ${process.pid} is running`);

  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork(); // Replace the dead worker
  });
} else {
  // Workers share the TCP connection
  const express = require('express');
  const app = express();
  
  app.get('/', (req, res) => {
    res.send(`Worker ${process.pid} responded`);
  });
  
  app.listen(3000, () => {
    console.log(`Worker ${process.pid} started`);
  });
}
```

### Testing Express Applications

#### Unit Testing with Jest and Supertest

```javascript
// app.js (for testing)
const express = require('express');
const app = express();

app.use(express.json());

app.get('/api/users', (req, res) => {
  res.json([{ id: 1, name: 'John' }, { id: 2, name: 'Jane' }]);
});

app.post('/api/users', (req, res) => {
  const { name } = req.body;
  if (!name) {
    return res.status(400).json({ message: 'Name is required' });
  }
  res.status(201).json({ id: 3, name });
});

module.exports = app;

// app.test.js
const request = require('supertest');
const app = require('./app');

describe('User API', () => {
  test('GET /api/users should return all users', async () => {
    const response = await request(app).get('/api/users');
    
    expect(response.status).toBe(200);
    expect(response.body).toHaveLength(2);
    expect(response.body[0]).toHaveProperty('name');
  });
  
  test('POST /api/users should create a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'Test User' })
      .set('Accept', 'application/json');
    
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe('Test User');
  });
  
  test('POST /api/users without name should return 400', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({})
      .set('Accept', 'application/json');
    
    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('message');
  });
});
```

### Deployment

#### Environment Configuration

```javascript
// config.js
require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/myapp',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key'
};

// app.js
const config = require('./config');
const express = require('express');
const app = express();

// Development-specific middleware
if (config.nodeEnv === 'development') {
  const morgan = require('morgan');
  app.use(morgan('dev'));
}

// Production-specific settings
if (config.nodeEnv === 'production') {
  app.set('trust proxy', 1); // Trust first proxy
}

app.listen(config.port, () => {
  console.log(`Server running in ${config.nodeEnv} mode on port ${config.port}`);
});
```

#### Docker Deployment

```dockerfile
# Dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

ENV PORT=3000
ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "app.js"]
```

```yaml
# docker-compose.yml
version: '3'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - MONGO_URI=mongodb://mongo:27017/myapp
      - NODE_ENV=production
      - JWT_SECRET=your-secret-key
    depends_on:
      - mongo
  
  mongo:
    image: mongo
    volumes:
      - mongo-data:/data/db
    ports:
      - "27017:27017"

volumes:
  mongo-data:
```

### Security Best Practices

1. **Use security middleware:**

```javascript
const helmet = require('helmet');
app.use(helmet()); // Sets various HTTP headers for security
```

2. **Implement rate limiting:**

```javascript
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again after 15 minutes'
});

app.use('/api/', apiLimiter);
```

3. **Validate and sanitize inputs:**

```javascript
const { check, validationResult } = require('express-validator');

app.post('/api/users',
  [
    check('email').isEmail().normalizeEmail(),
    check('password').isLength({ min: 8 }),
    check('name').trim().escape()
  ],
  (req, res) => {
    const errors = validationResult(req);
    
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    // Process valid input
  }
);
```

4. **Use CORS properly:**

```javascript
const cors = require('cors');

// Basic usage (allows all origins)
app.use(cors());

// Configuring specific options
app.use(cors({
  origin: 'https://example.com',
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
```

5. **Set secure cookies:**

```javascript
const session = require('express-session');

app.use(session({
  secret: 'your-secret-key',
  name: 'sessionId', // Don't use the default name
  cookie: {
    secure: true, // Only transmit over HTTPS
    httpOnly: true, // Prevents client-side JS from reading the cookie
    sameSite: 'strict', // CSRF protection
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  },
  resave: false,
  saveUninitialized: false
}));
```

### Express vs. Other Frameworks

|Framework|Pros|Cons|
|---|---|---|
|Express.js|Minimalist, flexible, mature ecosystem, middleware system|Requires more setup for large applications|
|Koa.js|Modern async/await support, cleaner middleware|Smaller ecosystem, steeper learning curve|
|Fastify|Extremely fast performance, schema validation|Smaller ecosystem, different plugin system|
|NestJS|Structured architecture, TypeScript first, Angular-like|More opinionated, heavier|
|Hapi.js|Configuration over code, built-in validation|More verbose, less middleware-focused|
|Sails.js|Full MVC framework, auto-generated REST APIs|More opinionated, steeper learning curve|

### Modern Express Best Practices

#### Async/Await Pattern  
The async/await pattern in Express improves readability and error handling. Wrapping asynchronous route handlers in a helper function avoids repetitive try/catch blocks while passing errors to Express’s error middleware.

```javascript
const asyncHandler = fn => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

app.get('/users', asyncHandler(async (req, res) => {
  const users = await User.find();
  res.json(users);
}));
```

---

#### TypeScript Integration  
Integrating TypeScript with Express enables static type-checking and improved IDE support. Defining interfaces for request data and using typed middleware provides safer and more maintainable code.

```typescript
import express, { Request, Response, NextFunction } from 'express';

interface User {
  id: number;
  name: string;
  email: string;
}

app.get('/users', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const users: User[] = await getUsers();
    res.json(users);
  } catch (error) {
    next(error);
  }
});
```

---

#### API Versioning

##### Path Versioning  
Organize routes using a versioned path, which segregates API endpoints by version and simplifies deprecation of older versions.

```javascript
app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);
```

##### Header Versioning  
Switch routing based on version information provided in request headers. This approach decouples API versions from the URL structure.

```javascript
app.use('/api', (req, res, next) => {
  const version = req.headers['accept-version'];
  if (version === '2.0') {
    v2Router(req, res, next);
  } else {
    v1Router(req, res, next);
  }
});
```

---

#### Security & Performance Enhancements  
Modern Express applications enhance security and performance by incorporating middleware and best practices.

- **Helmet** helps secure Express apps by setting various HTTP headers.
- **Rate Limiting** prevents abuse by limiting the number of requests per client.
- **CORS Middleware** ensures controlled cross-origin resource sharing.

```javascript
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import cors from 'cors';

app.use(helmet());
app.use(cors());
app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
}));
```

---

#### Error Handling and Logging  
Centralized error handling ensures that unexpected issues are properly logged and reported. Custom error middleware captures errors from asynchronous operations and logs them for further analysis.

```javascript
app.use((err, req, res, next) => {
  console.error(err.stack);  // Log detailed error stack for debugging
  res.status(500).json({ error: 'Something went wrong!' });
});
```

Using logging libraries such as **Winston** or **Morgan** provides advanced logging capabilities, including log rotation and external log management integration.

```javascript
import morgan from 'morgan';
app.use(morgan('combined'));
```

---

#### Environment Configuration  
Utilizing environment variables for configuration increases application flexibility and security. Tools like **dotenv** allow sensitive data such as API keys and database credentials to be stored securely outside the codebase.

```javascript
import dotenv from 'dotenv';
dotenv.config();

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Server running on port ${port}`));
```

---

**Conclusion**  
Modern Express best practices leverage async/await for cleaner asynchronous code, strong TypeScript integration for maintainability, and flexible API versioning strategies. Further practices include robust security measures, centralized error handling, and comprehensive logging. These techniques contribute to scalable, secure, and maintainable Express applications.

---
