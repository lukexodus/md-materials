## Integrate MongoDB with Applications


### MongoDB Node.js Driver

The official MongoDB Node.js driver provides the foundational layer for connecting Node.js applications to MongoDB databases. This driver offers direct access to MongoDB's native operations and features.

**Key points:**

- Provides low-level database operations
- Supports all MongoDB features including transactions, aggregation, and GridFS
- Offers both callback and Promise-based APIs
- Includes connection pooling and automatic failover

The driver installation requires the mongodb package:

```javascript
npm install mongodb
```

Basic connection establishment uses the MongoClient class:

```javascript
const { MongoClient } = require('mongodb');

const client = new MongoClient('mongodb://localhost:27017');

async function connectToDatabase() {
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db('myDatabase');
    return db;
  } catch (error) {
    console.error('Connection failed:', error);
  }
}
```

CRUD operations through the native driver involve direct collection methods:

```javascript
async function performOperations(db) {
  const collection = db.collection('users');
  
  // Insert
  const insertResult = await collection.insertOne({
    name: 'John Doe',
    email: 'john@example.com',
    age: 30
  });
  
  // Find
  const user = await collection.findOne({ email: 'john@example.com' });
  
  // Update
  const updateResult = await collection.updateOne(
    { email: 'john@example.com' },
    { $set: { age: 31 } }
  );
  
  // Delete
  const deleteResult = await collection.deleteOne({ email: 'john@example.com' });
}
```

### Mongoose ODM

Mongoose serves as an Object Document Mapper (ODM) that provides a higher-level abstraction over the MongoDB driver, introducing schema validation, middleware, and model-based operations.

**Key points:**

- Enforces schema structure on documents
- Provides built-in validation and type casting
- Supports middleware for pre/post hooks
- Offers population for referencing documents

Installation and basic setup:

```javascript
npm install mongoose
```

Schema definition establishes document structure:

```javascript
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  age: {
    type: Number,
    min: 0,
    max: 120
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const User = mongoose.model('User', userSchema);
```

Connection management with Mongoose:

```javascript
async function connectWithMongoose() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myDatabase');
    console.log('Connected to MongoDB with Mongoose');
  } catch (error) {
    console.error('Mongoose connection failed:', error);
  }
}
```

Model operations provide intuitive document manipulation:

```javascript
async function userOperations() {
  // Create
  const newUser = new User({
    name: 'Jane Smith',
    email: 'jane@example.com',
    age: 28
  });
  await newUser.save();
  
  // Find
  const users = await User.find({ age: { $gte: 25 } });
  
  // Update
  const updatedUser = await User.findByIdAndUpdate(
    newUser._id,
    { age: 29 },
    { new: true }
  );
  
  // Delete
  await User.findByIdAndDelete(newUser._id);
}
```

Middleware enables custom logic execution:

```javascript
userSchema.pre('save', function(next) {
  if (this.isModified('email')) {
    this.email = this.email.toLowerCase();
  }
  next();
});

userSchema.post('save', function(doc) {
  console.log(`User ${doc.name} has been saved`);
});
```

### Express.js Integration

Express.js integration combines MongoDB operations with HTTP request handling, creating RESTful APIs and web applications that interact with MongoDB databases.

**Key points:**

- Separates database logic from route handlers
- Implements proper error handling and status codes
- Supports middleware for authentication and validation
- Enables CORS and request parsing

Basic Express setup with MongoDB:

```javascript
const express = require('express');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());

// Database connection
mongoose.connect('mongodb://localhost:27017/myDatabase');

// User model (from previous example)
const User = require('./models/User');
```

RESTful route implementation:

```javascript
// GET all users
app.get('/api/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET user by ID
app.get('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST new user
app.post('/api/users', async (req, res) => {
  try {
    const user = new User(req.body);
    await user.save();
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// PUT update user
app.put('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// DELETE user
app.delete('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

Middleware implementation for common functionality:

```javascript
// Validation middleware
const validateUser = (req, res, next) => {
  const { name, email } = req.body;
  if (!name || !email) {
    return res.status(400).json({ 
      error: 'Name and email are required' 
    });
  }
  next();
};

// Apply middleware to POST route
app.post('/api/users', validateUser, async (req, res) => {
  // Route handler code
});
```

### Async/Await Patterns

Modern JavaScript async/await patterns provide clean, readable code for handling MongoDB operations, replacing callback-based approaches with Promise-based syntax.

**Key points:**

- Eliminates callback hell and nested Promise chains
- Provides synchronous-style error handling with try/catch
- Enables sequential and parallel operation execution
- Supports proper error propagation

Basic async/await implementation:

```javascript
async function performDatabaseOperations() {
  try {
    // Sequential operations
    const user = await User.create({
      name: 'Alice Johnson',
      email: 'alice@example.com'
    });
    
    const savedUser = await user.save();
    const foundUser = await User.findById(savedUser._id);
    
    return foundUser;
  } catch (error) {
    console.error('Database operation failed:', error);
    throw error;
  }
}
```

Parallel operations using Promise.all():

```javascript
async function performParallelOperations() {
  try {
    const [users, totalCount, activeUsers] = await Promise.all([
      User.find().limit(10),
      User.countDocuments(),
      User.find({ status: 'active' })
    ]);
    
    return { users, totalCount, activeUsers };
  } catch (error) {
    console.error('Parallel operations failed:', error);
    throw error;
  }
}
```

Transaction handling with async/await:

```javascript
async function performTransaction() {
  const session = await mongoose.startSession();
  
  try {
    session.startTransaction();
    
    const user = await User.create([{
      name: 'Bob Wilson',
      email: 'bob@example.com'
    }], { session });
    
    await Account.create([{
      userId: user[0]._id,
      balance: 1000
    }], { session });
    
    await session.commitTransaction();
    return user[0];
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}
```

Error handling patterns:

```javascript
// Specific error handling
async function handleSpecificErrors() {
  try {
    const user = await User.findById(invalidId);
  } catch (error) {
    if (error.name === 'CastError') {
      throw new Error('Invalid user ID format');
    } else if (error.name === 'ValidationError') {
      throw new Error('User validation failed');
    } else {
      throw new Error('Database operation failed');
    }
  }
}

// Generic error wrapper
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Usage in Express routes
app.get('/api/users/:id', asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
}));
```

**Example** complete application structure:

```javascript
// app.js
const express = require('express');
const mongoose = require('mongoose');
const userRoutes = require('./routes/users');

const app = express();

// Middleware
app.use(express.json());
app.use('/api', userRoutes);

// Database connection
async function startServer() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myapp');
    console.log('Connected to MongoDB');
    
    app.listen(3000, () => {
      console.log('Server running on port 3000');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
```

**Conclusion:** MongoDB integration with JavaScript applications provides multiple approaches ranging from low-level native driver operations to high-level ODM abstractions. The choice between MongoDB driver and Mongoose depends on application requirements, with the driver offering maximum flexibility and Mongoose providing structure and validation. Express.js integration creates robust web APIs, while async/await patterns ensure maintainable, readable code. [Inference] Proper error handling and connection management are essential for production applications.

---

