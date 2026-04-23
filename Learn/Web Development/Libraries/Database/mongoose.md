# Mongoose: Comprehensive Guide

Mongoose is an **Object Data Modeling (ODM) library** for MongoDB and Node.js. It provides a schema-based solution to model your application data, with built-in type casting, validation, query building, and business logic hooks.

---

## 1. Installation & Setup

```bash
npm install mongoose
```

```javascript
const mongoose = require('mongoose');
// or ES Modules:
import mongoose from 'mongoose';

mongoose.connect('mongodb://localhost:27017/mydb')
  .then(() => console.log('Connected'))
  .catch(err => console.error(err));
```

### Connection Options

```javascript
mongoose.connect('mongodb://localhost:27017/mydb', {
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
});
```

### Connection Events

```javascript
mongoose.connection.on('connected', () => console.log('Connected'));
mongoose.connection.on('error',     err => console.error(err));
mongoose.connection.on('disconnected', () => console.log('Disconnected'));
```

---

## 2. Schema Definition

```javascript
const { Schema } = mongoose;

const userSchema = new Schema({
  name:      { type: String,  required: true, trim: true },
  email:     { type: String,  required: true, unique: true, lowercase: true },
  age:       { type: Number,  min: 0, max: 120 },
  role:      { type: String,  enum: ['user', 'admin', 'moderator'], default: 'user' },
  isActive:  { type: Boolean, default: true },
  createdAt: { type: Date,    default: Date.now },
  tags:      [String],
  address: {
    street: String,
    city:   String,
    zip:    String,
  },
}, {
  timestamps: true,   // auto-adds createdAt and updatedAt
  versionKey: false,  // disables __v field
});
```

### Schema Types

|Type|Notes|
|---|---|
|`String`||
|`Number`||
|`Boolean`||
|`Date`||
|`Buffer`|Binary data|
|`ObjectId`|`Schema.Types.ObjectId`|
|`Array`|`[String]`, `[Schema]`, etc.|
|`Map`|Key-value pairs|
|`Mixed`|`Schema.Types.Mixed` — any type|
|`Decimal128`|High-precision numbers|

---

## 3. Models

```javascript
const User = mongoose.model('User', userSchema);
// Mongoose will use the 'users' collection (pluralized, lowercased)
```

---

## 4. CRUD Operations

### Create

```javascript
// Method 1: new + save
const user = new User({ name: 'Alice', email: 'alice@example.com' });
await user.save();

// Method 2: Model.create
const user = await User.create({ name: 'Bob', email: 'bob@example.com' });

// Bulk insert
await User.insertMany([{ name: 'C' }, { name: 'D' }]);
```

### Read

```javascript
// Find all
const users = await User.find();

// Find with filter
const admins = await User.find({ role: 'admin' });

// Find one
const user = await User.findOne({ email: 'alice@example.com' });

// Find by ID
const user = await User.findById('64abc123...');

// Projection (select fields)
const users = await User.find({}, 'name email -_id');
```

### Update

```javascript
// findByIdAndUpdate (returns old doc by default)
const updated = await User.findByIdAndUpdate(
  id,
  { $set: { role: 'admin' } },
  { new: true, runValidators: true }  // new: true = return updated doc
);

// updateMany
await User.updateMany({ isActive: false }, { $set: { role: 'user' } });

// findOneAndUpdate
await User.findOneAndUpdate({ email: 'alice@example.com' }, { age: 30 });
```

### Delete

```javascript
await User.findByIdAndDelete(id);
await User.deleteOne({ email: 'alice@example.com' });
await User.deleteMany({ isActive: false });
```

---

## 5. Query Chaining & Operators

```javascript
const results = await User
  .find({ age: { $gte: 18, $lte: 65 } })
  .where('role').in(['admin', 'moderator'])
  .select('name email role')
  .sort({ createdAt: -1 })
  .skip(20)
  .limit(10)
  .lean();         // returns plain JS objects, faster for read-only
```

### Common Query Operators

```javascript
{ age: { $gt: 18 } }         // greater than
{ age: { $gte: 18 } }        // greater than or equal
{ age: { $lt: 65 } }         // less than
{ age: { $lte: 65 } }        // less than or equal
{ role: { $in: ['a','b'] } } // in array
{ role: { $nin: ['x'] } }    // not in array
{ name: { $regex: /alice/i } } // regex match
{ $or: [{ age: 18 }, { role: 'admin' }] }
{ $and: [{ isActive: true }, { age: { $gt: 21 } }] }
```

---

## 6. Validation

```javascript
const productSchema = new Schema({
  name:  {
    type: String,
    required: [true, 'Name is required'],
    minlength: [3, 'Too short'],
    maxlength: [100, 'Too long'],
  },
  price: {
    type: Number,
    required: true,
    validate: {
      validator: v => v >= 0,
      message: 'Price must be non-negative',
    },
  },
});
```

### Running Validation Manually

```javascript
try {
  await user.validate();
} catch (err) {
  console.error(err.errors);
}
```

---

## 7. Virtuals

Virtuals are computed properties not stored in MongoDB.

```javascript
userSchema.virtual('fullName').get(function () {
  return `${this.firstName} ${this.lastName}`;
});

// Include virtuals in JSON output:
const userSchema = new Schema({ ... }, { toJSON: { virtuals: true } });
```

---

## 8. Middleware (Hooks)

```javascript
// Pre-save: hash password before saving
userSchema.pre('save', async function (next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

// Post-save
userSchema.post('save', function (doc) {
  console.log('Saved:', doc._id);
});

// Pre-find
userSchema.pre('find', function () {
  this.where({ isActive: true });
});

// Pre-delete
userSchema.pre('findOneAndDelete', async function (next) {
  const doc = await this.model.findOne(this.getFilter());
  await RelatedModel.deleteMany({ userId: doc._id });
  next();
});
```

Available hook types: `save`, `validate`, `remove`, `find`, `findOne`, `findOneAndUpdate`, `findOneAndDelete`, `aggregate`, etc.

---

## 9. Populate (References)

```javascript
const postSchema = new Schema({
  title:  String,
  author: { type: Schema.Types.ObjectId, ref: 'User' },
  tags:   [{ type: Schema.Types.ObjectId, ref: 'Tag' }],
});

// Populate on query
const posts = await Post.find()
  .populate('author', 'name email')   // select only name & email
  .populate('tags');

// Nested populate
await Post.find().populate({
  path: 'author',
  populate: { path: 'friends' },
});
```

---

## 10. Indexes

```javascript
userSchema.index({ email: 1 }, { unique: true });
userSchema.index({ name: 1, createdAt: -1 });   // compound
userSchema.index({ location: '2dsphere' });      // geospatial
userSchema.index({ bio: 'text' });               // text search

// Or inline in field definition:
email: { type: String, index: true, unique: true }
```

---

## 11. Aggregation Pipeline

```javascript
const result = await Order.aggregate([
  { $match:   { status: 'completed' } },
  { $group:   { _id: '$userId', total: { $sum: '$amount' } } },
  { $sort:    { total: -1 } },
  { $limit:   10 },
  { $lookup:  {
      from: 'users',
      localField: '_id',
      foreignField: '_id',
      as: 'user',
  }},
  { $unwind:  '$user' },
  { $project: { 'user.name': 1, total: 1 } },
]);
```

---

## 12. Transactions

Requires a MongoDB replica set or Atlas cluster.

```javascript
const session = await mongoose.startSession();
session.startTransaction();

try {
  await Account.updateOne({ _id: fromId }, { $inc: { balance: -amount } }, { session });
  await Account.updateOne({ _id: toId   }, { $inc: { balance: +amount } }, { session });
  await session.commitTransaction();
} catch (err) {
  await session.abortTransaction();
  throw err;
} finally {
  session.endSession();
}
```

---

## 13. Static & Instance Methods

```javascript
// Instance method
userSchema.methods.isAdult = function () {
  return this.age >= 18;
};

// Static method
userSchema.statics.findByEmail = function (email) {
  return this.findOne({ email });
};

// Query helper
userSchema.query.active = function () {
  return this.where({ isActive: true });
};

// Usage:
const user = await User.findByEmail('alice@example.com');
console.log(user.isAdult());
const activeUsers = await User.find().active();
```

---

## 14. Plugins

```javascript
// Reusable plugin
function timestampPlugin(schema) {
  schema.add({ createdAt: Date, updatedAt: Date });
  schema.pre('save', function (next) {
    this.updatedAt = new Date();
    if (!this.createdAt) this.createdAt = new Date();
    next();
  });
}

userSchema.plugin(timestampPlugin);

// Apply globally
mongoose.plugin(timestampPlugin);
```

---

## 15. Common Patterns & Best Practices

### Separate Connection Logic

```javascript
// db.js
let isConnected = false;

export const connectDB = async () => {
  if (isConnected) return;
  await mongoose.connect(process.env.MONGO_URI);
  isConnected = true;
};
```

### Use `.lean()` for Read-Only Queries

```javascript
// Returns plain objects — faster, lower memory
const users = await User.find().lean();
```

### Error Handling

```javascript
try {
  await user.save();
} catch (err) {
  if (err.code === 11000) {
    // Duplicate key error (unique constraint)
  }
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map(e => e.message);
  }
}
```

### Pagination

```javascript
const paginate = async (model, filter, page = 1, limit = 10) => {
  const [data, total] = await Promise.all([
    model.find(filter).skip((page - 1) * limit).limit(limit).lean(),
    model.countDocuments(filter),
  ]);
  return { data, total, pages: Math.ceil(total / limit), page };
};
```

---

## 16. Environment & Security Notes

- Store your MongoDB URI in environment variables, never hardcoded.
- Use `runValidators: true` on update operations — validators do not run on updates by default.
- Use `session` for multi-document operations that need atomicity.
- Avoid `Schema.Types.Mixed` where possible — it bypasses type safety.
- Index fields you query frequently, but avoid over-indexing (write overhead).

---

## Quick Reference

|Method|Purpose|
|---|---|
|`Model.find()`|Query multiple docs|
|`Model.findOne()`|Query single doc|
|`Model.findById()`|Find by `_id`|
|`Model.create()`|Create and save|
|`Model.insertMany()`|Bulk insert|
|`Model.updateOne/Many()`|Update without returning|
|`Model.findByIdAndUpdate()`|Update and return doc|
|`Model.deleteOne/Many()`|Delete without returning|
|`Model.findByIdAndDelete()`|Delete and return doc|
|`Model.aggregate()`|Run aggregation pipeline|
|`Model.countDocuments()`|Count matching docs|
|`.lean()`|Return plain JS objects|
|`.populate()`|Join referenced documents|
|`.select()`|Choose fields to return|
|`.sort()`|Order results|
|`.skip()` / `.limit()`|Pagination|