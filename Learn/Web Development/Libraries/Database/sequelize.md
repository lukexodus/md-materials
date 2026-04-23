# Comprehensive Guide to Sequelize

Sequelize is a promise-based Node.js ORM (Object-Relational Mapper) for SQL databases including PostgreSQL, MySQL, MariaDB, SQLite, and Microsoft SQL Server.

---

## 1. Installation & Setup

```bash
npm install sequelize
# Install your database driver:
npm install pg pg-hstore       # PostgreSQL
npm install mysql2              # MySQL / MariaDB
npm install tedious             # SQL Server
npm install sqlite3             # SQLite
```

### Connecting to a Database

```javascript
const { Sequelize } = require('sequelize');

// Option A: Connection URI
const sequelize = new Sequelize('postgres://user:pass@localhost:5432/mydb');

// Option B: Explicit params
const sequelize = new Sequelize('database', 'username', 'password', {
  host: 'localhost',
  dialect: 'postgres', // 'mysql' | 'mariadb' | 'sqlite' | 'mssql'
  logging: false,       // disable SQL logging
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000,
  },
});

// Test the connection
(async () => {
  try {
    await sequelize.authenticate();
    console.log('Connection established.');
  } catch (err) {
    console.error('Unable to connect:', err);
  }
})();
```

---

## 2. Defining Models

```javascript
const { DataTypes, Model } = require('sequelize');

class User extends Model {}

User.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        isEmail: true,
      },
    },
    role: {
      type: DataTypes.ENUM('admin', 'user', 'guest'),
      defaultValue: 'user',
    },
    createdAt: DataTypes.DATE,
    updatedAt: DataTypes.DATE,
  },
  {
    sequelize,       // the connection instance
    modelName: 'User',
    tableName: 'users',  // optional: explicit table name
    timestamps: true,    // auto-manage createdAt / updatedAt
  }
);
```

### Common DataTypes

|Type|Usage|
|---|---|
|`DataTypes.STRING`|VARCHAR(255)|
|`DataTypes.TEXT`|Unlimited text|
|`DataTypes.INTEGER`|Integer|
|`DataTypes.FLOAT`|Float|
|`DataTypes.DECIMAL(p, s)`|Exact decimal|
|`DataTypes.BOOLEAN`|Boolean|
|`DataTypes.DATE`|Datetime with timezone|
|`DataTypes.DATEONLY`|Date only|
|`DataTypes.JSON`|JSON (PG/MySQL)|
|`DataTypes.UUID`|UUID|
|`DataTypes.ENUM(...)`|Enum values|

---

## 3. Sync & Migrations

### sync() — development only

```javascript
// Creates table if it doesn't exist
await sequelize.sync();

// Drops and recreates (destructive!)
await sequelize.sync({ force: true });

// Adds columns if missing, won't drop
await sequelize.sync({ alter: true });
```

> ⚠️ **Do not use `sync({ force: true })` in production.** Use migrations instead.

### Migrations with Sequelize CLI

```bash
npm install --save-dev sequelize-cli

npx sequelize-cli init             # creates folders
npx sequelize-cli migration:generate --name create-users
npx sequelize-cli db:migrate       # run pending
npx sequelize-cli db:migrate:undo  # rollback last
```

**Example migration file:**

```javascript
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('users', {
      id: { type: Sequelize.INTEGER, autoIncrement: true, primaryKey: true },
      username: { type: Sequelize.STRING, allowNull: false },
      createdAt: Sequelize.DATE,
      updatedAt: Sequelize.DATE,
    });
  },
  async down(queryInterface) {
    await queryInterface.dropTable('users');
  },
};
```

---

## 4. CRUD Operations

### Create

```javascript
// create() = build + save
const user = await User.create({ username: 'alice', email: 'alice@example.com' });

// build() then save()
const user2 = User.build({ username: 'bob', email: 'bob@example.com' });
await user2.save();

// Bulk create
await User.bulkCreate([
  { username: 'carol', email: 'carol@example.com' },
  { username: 'dave',  email: 'dave@example.com' },
]);
```

### Read

```javascript
// Find all
const users = await User.findAll();

// Find with conditions
const admins = await User.findAll({
  where: { role: 'admin' },
  attributes: ['id', 'username'], // SELECT specific columns
  order: [['createdAt', 'DESC']],
  limit: 10,
  offset: 20,
});

// Find one
const user = await User.findOne({ where: { username: 'alice' } });

// Find by PK
const user = await User.findByPk(1);

// Find or create
const [user, created] = await User.findOrCreate({
  where: { username: 'alice' },
  defaults: { email: 'alice@example.com' },
});
```

### Update

```javascript
// Instance update
const user = await User.findByPk(1);
user.username = 'alicia';
await user.save();

// Or:
await user.update({ username: 'alicia' });

// Bulk update
await User.update({ role: 'guest' }, { where: { role: 'user' } });
```

### Delete

```javascript
// Instance destroy
const user = await User.findByPk(1);
await user.destroy();

// Bulk destroy
await User.destroy({ where: { role: 'guest' } });
```

---

## 5. Querying — Operators

```javascript
const { Op } = require('sequelize');

await User.findAll({
  where: {
    age: { [Op.gte]: 18 },           // age >= 18
    username: { [Op.like]: 'a%' },   // LIKE 'a%'
    role: { [Op.in]: ['admin', 'user'] },
    [Op.or]: [
      { email: { [Op.like]: '%@gmail.com' } },
      { email: { [Op.like]: '%@yahoo.com' } },
    ],
  },
});
```

**Common Operators:**

|Operator|SQL equivalent|
|---|---|
|`Op.eq`|`=`|
|`Op.ne`|`!=`|
|`Op.gt / Op.gte`|`> / >=`|
|`Op.lt / Op.lte`|`< / <=`|
|`Op.in`|`IN (...)`|
|`Op.notIn`|`NOT IN (...)`|
|`Op.like`|`LIKE`|
|`Op.between`|`BETWEEN`|
|`Op.and / Op.or`|`AND / OR`|
|`Op.is`|`IS NULL`|

---

## 6. Associations

```javascript
// One-to-Many
User.hasMany(Post, { foreignKey: 'userId' });
Post.belongsTo(User, { foreignKey: 'userId' });

// Many-to-Many
Post.belongsToMany(Tag, { through: 'PostTags' });
Tag.belongsToMany(Post, { through: 'PostTags' });

// One-to-One
User.hasOne(Profile, { foreignKey: 'userId' });
Profile.belongsTo(User, { foreignKey: 'userId' });
```

### Eager Loading (JOINs)

```javascript
const posts = await Post.findAll({
  include: [
    {
      model: User,
      attributes: ['username'],
    },
    {
      model: Tag,
      through: { attributes: [] }, // exclude junction table columns
    },
  ],
});
```

### Lazy Loading

```javascript
const user = await User.findByPk(1);
const posts = await user.getPosts(); // getter auto-generated by hasMany
```

---

## 7. Transactions

```javascript
// Managed (auto-commit / rollback)
await sequelize.transaction(async (t) => {
  const user = await User.create({ username: 'eve' }, { transaction: t });
  await Post.create({ title: 'Hello', userId: user.id }, { transaction: t });
  // rolls back automatically if an error is thrown
});

// Unmanaged
const t = await sequelize.transaction();
try {
  await User.create({ username: 'frank' }, { transaction: t });
  await t.commit();
} catch (err) {
  await t.rollback();
}
```

---

## 8. Hooks (Lifecycle Callbacks)

```javascript
User.beforeCreate(async (user) => {
  user.password = await bcrypt.hash(user.password, 10);
});

User.afterCreate((user) => {
  console.log(`New user created: ${user.username}`);
});
```

**Common hooks:** `beforeCreate`, `afterCreate`, `beforeUpdate`, `afterUpdate`, `beforeDestroy`, `afterDestroy`, `beforeBulkCreate`, `beforeValidate`

---

## 9. Validations

```javascript
username: {
  type: DataTypes.STRING,
  validate: {
    len: [3, 30],
    isAlphanumeric: true,
    notNull: { msg: 'Username is required' },
  },
},
email: {
  type: DataTypes.STRING,
  validate: {
    isEmail: { msg: 'Must be a valid email' },
  },
},
age: {
  type: DataTypes.INTEGER,
  validate: {
    min: 0,
    max: 150,
    isInt: true,
  },
},
```

Validations run on `save()`, `create()`, and `update()`. They throw a `ValidationError` on failure.

---

## 10. Raw Queries

```javascript
// Raw SQL
const [results] = await sequelize.query(
  'SELECT * FROM users WHERE role = :role',
  {
    replacements: { role: 'admin' },
    type: sequelize.QueryTypes.SELECT,
  }
);
```

---

## 11. Scopes

```javascript
User.init({ ... }, {
  sequelize,
  scopes: {
    admins: { where: { role: 'admin' } },
    active: { where: { active: true } },
    withEmail(email) {
      return { where: { email } };
    },
  },
});

// Usage
await User.scope('admins').findAll();
await User.scope(['admins', 'active']).findAll();
await User.scope({ method: ['withEmail', 'a@b.com'] }).findOne();
```

---

## 12. Indexes & Performance Tips

```javascript
User.init({ ... }, {
  sequelize,
  indexes: [
    { unique: true, fields: ['email'] },
    { fields: ['role', 'createdAt'] },
  ],
});
```

**General tips:**

- Use `attributes` to select only needed columns
- Use `raw: true` for read-only queries to skip model instantiation
- Use `limit` / `offset` or cursor-based pagination for large datasets
- Avoid N+1 queries — prefer `include` (eager loading) over loops of lazy loads
- Use `logging: false` in production or route to a proper logger

---

## 13. Common Patterns

### Repository pattern

```javascript
class UserRepository {
  async findById(id) {
    return User.findByPk(id);
  }
  async create(data) {
    return User.create(data);
  }
}
```

### Soft deletes with `paranoid`

```javascript
User.init({ ... }, {
  sequelize,
  paranoid: true, // adds deletedAt; destroy() sets it instead of deleting the row
});

await user.destroy();          // sets deletedAt
await user.restore();          // clears deletedAt
await User.findAll({           // includes soft-deleted rows
  paranoid: false,
});
```

---

## Quick Reference

|Task|Method|
|---|---|
|Create record|`Model.create()`|
|Find all|`Model.findAll()`|
|Find one|`Model.findOne()`|
|Find by PK|`Model.findByPk()`|
|Update instance|`instance.update()`|
|Bulk update|`Model.update()`|
|Delete instance|`instance.destroy()`|
|Bulk delete|`Model.destroy()`|
|Raw SQL|`sequelize.query()`|
|Transaction|`sequelize.transaction()`|