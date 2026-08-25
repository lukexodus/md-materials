## Server Setup


### Choosing a GraphQL server library

The GraphQL ecosystem offers multiple server libraries, each with distinct strengths, architectural patterns, and target use cases. Your choice significantly impacts development experience, performance characteristics, and long-term maintainability.

**Apollo Server** remains the most popular choice, providing comprehensive tooling and extensive ecosystem support. It offers built-in caching, metrics collection, schema federation capabilities, and seamless integration with Apollo Studio for monitoring and analytics. Apollo Server supports multiple frameworks including Express, Fastify, and serverless platforms, making it versatile for various deployment scenarios.

**GraphQL Yoga** focuses on developer experience with zero-configuration setup and modern GraphQL features out of the box. Built on top of Envelop and GraphQL Tools, it provides a plugin-based architecture that enables fine-grained customization. Yoga includes built-in support for subscriptions, file uploads, and GraphQL over WebSockets, making it ideal for real-time applications.

**Mercurius** is a high-performance GraphQL server for Fastify, emphasizing speed and low memory usage. It provides excellent TypeScript support, built-in caching mechanisms, and federation capabilities. Mercurius excels in scenarios requiring high throughput and minimal overhead.

**GraphQL Helix** offers a framework-agnostic approach, allowing you to integrate GraphQL into any HTTP server. It provides fine-grained control over request processing while maintaining simplicity and performance.

**Pothos** takes a code-first approach with excellent TypeScript integration, generating schemas from your resolver implementations. It provides type safety throughout the development process and reduces the likelihood of runtime errors.

**Key points** for selection criteria:

- **Performance requirements**: Mercurius for high-throughput, Apollo Server for balanced performance
- **TypeScript support**: Pothos and Mercurius offer superior TypeScript integration
- **Ecosystem**: Apollo Server has the largest ecosystem and community support
- **Learning curve**: GraphQL Yoga provides the gentlest introduction
- **Customization needs**: Yoga's plugin architecture vs Apollo Server's extensions

### Setting up a basic GraphQL server

A basic GraphQL server requires schema definition, resolver implementation, and HTTP server configuration. The setup process varies by library but follows common patterns.

**Apollo Server setup** with Express:

```javascript
const { ApolloServer } = require('apollo-server-express');
const express = require('express');
const { gql } = require('apollo-server-express');

const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Query {
    users: [User]
    user(id: ID!): User
  }

  type Mutation {
    createUser(name: String!, email: String!): User
  }
`;

const resolvers = {
  Query: {
    users: () => users,
    user: (parent, { id }) => users.find(user => user.id === id),
  },
  Mutation: {
    createUser: (parent, { name, email }) => {
      const user = { id: String(users.length + 1), name, email };
      users.push(user);
      return user;
    },
  },
};

async function startServer() {
  const server = new ApolloServer({ typeDefs, resolvers });
  await server.start();
  
  const app = express();
  server.applyMiddleware({ app });
  
  app.listen(4000, () => {
    console.log(`Server running at http://localhost:4000${server.graphqlPath}`);
  });
}

startServer();
```

**GraphQL Yoga setup** with modern syntax:

```javascript
import { createServer } from 'graphql-yoga';
import { createSchema } from 'graphql-yoga';

const schema = createSchema({
  typeDefs: `
    type User {
      id: ID!
      name: String!
      email: String!
    }

    type Query {
      users: [User]
      user(id: ID!): User
    }

    type Mutation {
      createUser(name: String!, email: String!): User
    }
  `,
  resolvers: {
    Query: {
      users: () => users,
      user: (parent, { id }) => users.find(user => user.id === id),
    },
    Mutation: {
      createUser: (parent, { name, email }) => {
        const user = { id: String(users.length + 1), name, email };
        users.push(user);
        return user;
      },
    },
  },
});

const server = createServer({ schema });
server.start(() => console.log('Server running on http://localhost:4000/graphql'));
```

**Project structure** for scalable applications:

```
src/
├── schema/
│   ├── typeDefs/
│   │   ├── user.graphql
│   │   └── index.js
│   └── resolvers/
│       ├── user.js
│       └── index.js
├── models/
│   └── User.js
├── utils/
│   └── database.js
└── server.js
```

**Schema-first approach** with separate files:

```javascript
// schema/typeDefs/user.graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post]
}

extend type Query {
  users: [User]
  user(id: ID!): User
}

extend type Mutation {
  createUser(input: CreateUserInput!): User
}

input CreateUserInput {
  name: String!
  email: String!
}
```

**Modular resolver organization**:

```javascript
// schema/resolvers/user.js
const User = require('../../models/User');

module.exports = {
  Query: {
    users: async () => await User.find(),
    user: async (parent, { id }) => await User.findById(id),
  },
  Mutation: {
    createUser: async (parent, { input }) => {
      const user = new User(input);
      return await user.save();
    },
  },
  User: {
    posts: async (user) => await Post.find({ authorId: user.id }),
  },
};
```

### Connecting to databases

Database integration in GraphQL servers requires careful consideration of query patterns, performance optimization, and data fetching strategies to avoid common pitfalls like the N+1 problem.

**MongoDB connection** with Mongoose:

```javascript
const mongoose = require('mongoose');

// Connection setup
mongoose.connect('mongodb://localhost:27017/graphql-app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// User model
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now },
  posts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Post' }]
});

const User = mongoose.model('User', userSchema);

// Post model
const postSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, required: true },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  createdAt: { type: Date, default: Date.now }
});

const Post = mongoose.model('Post', postSchema);
```

**PostgreSQL connection** with Prisma:

```javascript
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  name      String
  email     String   @unique
  createdAt DateTime @default(now())
  posts     Post[]
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String
  author    User     @relation(fields: [authorId], references: [id])
  authorId  String
  createdAt DateTime @default(now())
}
```

**DataLoader implementation** to solve N+1 queries:

```javascript
const DataLoader = require('dataloader');

// User loader
const userLoader = new DataLoader(async (userIds) => {
  const users = await User.find({ _id: { $in: userIds } });
  return userIds.map(id => users.find(user => user.id === id.toString()));
});

// Post loader
const postLoader = new DataLoader(async (authorIds) => {
  const posts = await Post.find({ author: { $in: authorIds } });
  return authorIds.map(id => posts.filter(post => post.author.toString() === id.toString()));
});

// Context setup
const context = ({ req }) => ({
  user: req.user,
  loaders: {
    user: userLoader,
    posts: postLoader,
  },
});
```

**Optimized resolvers** using DataLoader:

```javascript
const resolvers = {
  Query: {
    users: async () => await User.find(),
    user: async (parent, { id }, { loaders }) => await loaders.user.load(id),
  },
  User: {
    posts: async (user, args, { loaders }) => await loaders.posts.load(user.id),
  },
  Post: {
    author: async (post, args, { loaders }) => await loaders.user.load(post.authorId),
  },
};
```

**Connection pooling** for PostgreSQL:

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Query helper
const query = async (text, params) => {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log('Executed query', { text, duration, rows: res.rowCount });
  return res;
};
```

**Database abstraction layer**:

```javascript
class UserRepository {
  constructor(db) {
    this.db = db;
  }

  async findById(id) {
    if (this.db.constructor.name === 'Pool') {
      const result = await this.db.query('SELECT * FROM users WHERE id = $1', [id]);
      return result.rows[0];
    } else {
      return await this.db.User.findById(id);
    }
  }

  async findMany(filters = {}) {
    if (this.db.constructor.name === 'Pool') {
      const result = await this.db.query('SELECT * FROM users');
      return result.rows;
    } else {
      return await this.db.User.find(filters);
    }
  }
}
```

### Environment configuration and security basics

Proper environment configuration and security implementation are fundamental for production-ready GraphQL servers. These practices protect against common vulnerabilities and ensure reliable operation across different deployment environments.

**Environment configuration** using dotenv:

```javascript
require('dotenv').config();

const config = {
  server: {
    port: process.env.PORT || 4000,
    host: process.env.HOST || 'localhost',
    cors: {
      origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
      credentials: true,
    },
  },
  database: {
    url: process.env.DATABASE_URL,
    options: {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: parseInt(process.env.DB_POOL_SIZE) || 10,
    },
  },
  auth: {
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiration: process.env.JWT_EXPIRATION || '7d',
  },
  security: {
    rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX) || 100,
    rateLimitWindow: parseInt(process.env.RATE_LIMIT_WINDOW) || 15 * 60 * 1000,
    queryDepthLimit: parseInt(process.env.QUERY_DEPTH_LIMIT) || 10,
    queryComplexityLimit: parseInt(process.env.QUERY_COMPLEXITY_LIMIT) || 1000,
  },
};
```

**Authentication middleware**:

```javascript
const jwt = require('jsonwebtoken');

const authMiddleware = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.userId);
    next();
  } catch (error) {
    req.user = null;
    next();
  }
};

app.use(authMiddleware);
```

**Query complexity analysis**:

```javascript
const { costAnalysis } = require('graphql-cost-analysis');
const { createComplexityLimitRule } = require('graphql-query-complexity');

const server = new ApolloServer({
  typeDefs,
  resolvers,
  plugins: [
    costAnalysis({
      onComplete: (cost) => {
        console.log(`Query cost: ${cost}`);
      },
    }),
  ],
  validationRules: [
    createComplexityLimitRule(1000, {
      createError: (max, actual) => {
        return new Error(`Query complexity ${actual} exceeds limit of ${max}`);
      },
    }),
  ],
});
```

**Rate limiting implementation**:

```javascript
const { RateLimiterMemory } = require('rate-limiter-flexible');

const rateLimiter = new RateLimiterMemory({
  keyPrefix: 'graphql',
  points: 100,
  duration: 60,
});

const rateLimitMiddleware = async (req, res, next) => {
  try {
    await rateLimiter.consume(req.ip);
    next();
  } catch (rejRes) {
    res.status(429).json({
      error: 'Rate limit exceeded',
      resetTime: new Date(Date.now() + rejRes.msBeforeNext),
    });
  }
};
```

**Query depth limiting**:

```javascript
const depthLimit = require('graphql-depth-limit');

const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [depthLimit(10)],
  formatError: (error) => {
    if (error.extensions?.code === 'GRAPHQL_VALIDATION_FAILED') {
      return new Error('Query depth limit exceeded');
    }
    return error;
  },
});
```

**Input validation and sanitization**:

```javascript
const Joi = require('joi');

const validateCreateUser = (input) => {
  const schema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required(),
  });

  return schema.validate(input);
};

const resolvers = {
  Mutation: {
    createUser: async (parent, { input }) => {
      const { error, value } = validateCreateUser(input);
      if (error) {
        throw new Error(`Validation error: ${error.details[0].message}`);
      }
      
      const hashedPassword = await bcrypt.hash(value.password, 10);
      const user = await User.create({ ...value, password: hashedPassword });
      return user;
    },
  },
};
```

**CORS configuration**:

```javascript
const cors = require('cors');

app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL 
    : 'http://localhost:3000',
  credentials: true,
  optionsSuccessStatus: 200,
}));
```

**Helmet for security headers**:

```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
}));
```

**Key points** for production security:

- Never expose GraphQL playground in production
- Implement query timeout limits
- Use HTTPS in production environments
- Sanitize all user inputs
- Log security events and monitor for suspicious activity
- Implement proper error handling to avoid information leakage
- Use environment-specific configuration files
- Regularly update dependencies and scan for vulnerabilities

A properly configured GraphQL server balances developer experience with security requirements, providing a robust foundation for scalable applications while protecting against common attack vectors and operational issues.

---

