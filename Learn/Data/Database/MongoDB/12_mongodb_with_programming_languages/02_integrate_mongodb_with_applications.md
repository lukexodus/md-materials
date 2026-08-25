## Integrate MongoDB with Applications


### PyMongo Driver

PyMongo is the official MongoDB driver for Python, providing direct database access through a low-level API that closely mirrors MongoDB's native operations.

**Installation and setup:**

```python
pip install pymongo
from pymongo import MongoClient

# Connection
client = MongoClient('mongodb://localhost:27017/')
db = client['mydatabase']
collection = db['mycollection']
```

**Basic operations:**

```python
# Insert operations
document = {"name": "John", "age": 30, "city": "New York"}
result = collection.insert_one(document)
print(result.inserted_id)

# Multiple inserts
documents = [
    {"name": "Alice", "age": 25},
    {"name": "Bob", "age": 35}
]
collection.insert_many(documents)

# Query operations
user = collection.find_one({"name": "John"})
users = list(collection.find({"age": {"$gte": 25}}))

# Update operations
collection.update_one(
    {"name": "John"},
    {"$set": {"age": 31}}
)

# Delete operations
collection.delete_one({"name": "John"})
```

**Advanced features:**

```python
# Aggregation pipeline
pipeline = [
    {"$match": {"age": {"$gte": 25}}},
    {"$group": {"_id": "$city", "count": {"$sum": 1}}},
    {"$sort": {"count": -1}}
]
results = list(collection.aggregate(pipeline))

# Indexing
collection.create_index("name")
collection.create_index([("name", 1), ("age", -1)])

# Transactions
with client.start_session() as session:
    with session.start_transaction():
        collection.insert_one({"name": "Transaction Test"}, session=session)
        collection.update_one({"name": "Alice"}, {"$inc": {"age": 1}}, session=session)
```

### MongoEngine ODM

MongoEngine provides an Object Document Mapper (ODM) that offers Django-like model definitions and query syntax for MongoDB.

**Installation and configuration:**

```python
pip install mongoengine
import mongoengine
from mongoengine import Document, StringField, IntField, ListField, EmbeddedDocument

# Connection
mongoengine.connect('mydatabase', host='localhost', port=27017)
```

**Model definition:**

```python
class Address(EmbeddedDocument):
    street = StringField(required=True)
    city = StringField(required=True)
    state = StringField(max_length=2)
    zip_code = StringField()

class User(Document):
    username = StringField(required=True, unique=True, max_length=50)
    email = StringField(required=True)
    age = IntField(min_value=0, max_value=150)
    addresses = ListField(EmbeddedDocument(Address))
    tags = ListField(StringField(max_length=50))
    
    meta = {
        'collection': 'users',
        'indexes': ['username', 'email']
    }
    
    def __str__(self):
        return self.username
```

**CRUD operations:**

```python
# Create
user = User(
    username='johndoe',
    email='john@example.com',
    age=30,
    addresses=[Address(street='123 Main St', city='Anytown', state='CA')],
    tags=['developer', 'python']
)
user.save()

# Read
users = User.objects(age__gte=25)
user = User.objects(username='johndoe').first()

# Update
User.objects(username='johndoe').update(set__age=31)
user.update(push__tags='mongodb')

# Delete
User.objects(username='johndoe').delete()
user.delete()
```

**Advanced querying:**

```python
# Complex queries
users = User.objects(
    Q(age__gte=25) & Q(tags__in=['developer', 'python'])
).order_by('-age')

# Aggregation
pipeline = [
    {"$group": {"_id": "$tags", "count": {"$sum": 1}}},
    {"$sort": {"count": -1}}
]
results = User.objects.aggregate(pipeline)

# Reference fields
class Post(Document):
    title = StringField(required=True)
    author = ReferenceField(User, required=True)
    content = StringField()

# Query with references
posts = Post.objects(author__username='johndoe')
```

### Flask Integration

Flask applications can integrate MongoDB through both PyMongo and MongoEngine, with Flask-PyMongo providing additional convenience methods.

**Flask-PyMongo setup:**

```python
pip install Flask-PyMongo
from flask import Flask, request, jsonify
from flask_pymongo import PyMongo

app = Flask(__name__)
app.config["MONGO_URI"] = "mongodb://localhost:27017/myDatabase"
mongo = PyMongo(app)

@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user_id = mongo.db.users.insert_one(data).inserted_id
    return jsonify({'id': str(user_id)}), 201

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    from bson import ObjectId
    user = mongo.db.users.find_one({'_id': ObjectId(user_id)})
    if user:
        user['_id'] = str(user['_id'])
        return jsonify(user)
    return jsonify({'error': 'User not found'}), 404

@app.route('/users', methods=['GET'])
def get_users():
    users = []
    for user in mongo.db.users.find():
        user['_id'] = str(user['_id'])
        users.append(user)
    return jsonify(users)
```

**Flask with MongoEngine:**

```python
from flask import Flask
from flask_mongoengine import MongoEngine

app = Flask(__name__)
app.config['MONGODB_SETTINGS'] = {
    'db': 'mydatabase',
    'host': 'localhost',
    'port': 27017
}
db = MongoEngine(app)

# Models
class User(db.Document):
    username = db.StringField(required=True, unique=True)
    email = db.StringField(required=True)
    
# Routes
@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = User(**data)
    user.save()
    return jsonify({'id': str(user.id)}), 201

@app.route('/users', methods=['GET'])
def get_users():
    users = User.objects()
    return jsonify([{
        'id': str(user.id),
        'username': user.username,
        'email': user.email
    } for user in users])
```

### Django Integration

Django integrates with MongoDB through Djongo or MongoEngine, requiring specific configuration for non-relational database operations.

**Djongo setup:**

```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'djongo',
        'NAME': 'mydatabase',
        'CLIENT': {
            'host': 'mongodb://localhost:27017',
        }
    }
}
```

**Django models with Djongo:**

```python
from djongo import models

class Address(models.Model):
    street = models.CharField(max_length=100)
    city = models.CharField(max_length=50)
    state = models.CharField(max_length=2)
    
    class Meta:
        abstract = True

class User(models.Model):
    username = models.CharField(max_length=50, unique=True)
    email = models.EmailField()
    age = models.IntegerField()
    address = models.EmbeddedField(model_container=Address)
    tags = models.JSONField(default=list)
    
    def __str__(self):
        return self.username
```

**Django with MongoEngine:**

```python
# settings.py
import mongoengine
mongoengine.connect('mydatabase')

# models.py
from mongoengine import Document, StringField, IntField

class User(Document):
    username = StringField(required=True, unique=True)
    email = StringField(required=True)
    age = IntField()

# views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def user_list(request):
    if request.method == 'GET':
        users = User.objects()
        return JsonResponse([{
            'id': str(user.id),
            'username': user.username,
            'email': user.email
        } for user in users], safe=False)
    
    elif request.method == 'POST':
        data = json.loads(request.body)
        user = User(**data)
        user.save()
        return JsonResponse({'id': str(user.id)})
```

### Async Programming with Motor

Motor provides asynchronous MongoDB operations for Python, essential for high-performance applications using asyncio.

**Installation and setup:**

```python
pip install motor
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def main():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client.mydatabase
    collection = db.mycollection
```

**Basic async operations:**

```python
async def crud_operations():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client.mydatabase
    collection = db.users
    
    # Insert
    result = await collection.insert_one({
        "name": "Alice",
        "email": "alice@example.com",
        "age": 28
    })
    print(f"Inserted ID: {result.inserted_id}")
    
    # Find one
    user = await collection.find_one({"name": "Alice"})
    print(f"Found user: {user}")
    
    # Find many
    cursor = collection.find({"age": {"$gte": 25}})
    users = await cursor.to_list(length=100)
    
    # Update
    await collection.update_one(
        {"name": "Alice"},
        {"$set": {"age": 29}}
    )
    
    # Delete
    await collection.delete_one({"name": "Alice"})
    
    client.close()

# Run async function
asyncio.run(crud_operations())
```

**FastAPI integration:**

```python
from fastapi import FastAPI, HTTPException
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel
from bson import ObjectId

app = FastAPI()
client = AsyncIOMotorClient('mongodb://localhost:27017')
db = client.mydatabase

class User(BaseModel):
    name: str
    email: str
    age: int

@app.on_event("startup")
async def startup_event():
    # Initialize indexes or other startup tasks
    await db.users.create_index("email", unique=True)

@app.post("/users/")
async def create_user(user: User):
    result = await db.users.insert_one(user.dict())
    return {"id": str(result.inserted_id)}

@app.get("/users/{user_id}")
async def get_user(user_id: str):
    try:
        user = await db.users.find_one({"_id": ObjectId(user_id)})
        if user:
            user["_id"] = str(user["_id"])
            return user
        raise HTTPException(status_code=404, detail="User not found")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid user ID")

@app.get("/users/")
async def get_users(skip: int = 0, limit: int = 10):
    cursor = db.users.find().skip(skip).limit(limit)
    users = await cursor.to_list(length=limit)
    for user in users:
        user["_id"] = str(user["_id"])
    return users
```

**Advanced async patterns:**

```python
async def batch_operations():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client.mydatabase
    collection = db.users
    
    # Bulk operations
    operations = [
        InsertOne({"name": f"User{i}", "age": 20 + i})
        for i in range(1000)
    ]
    result = await collection.bulk_write(operations)
    
    # Aggregation
    pipeline = [
        {"$match": {"age": {"$gte": 25}}},
        {"$group": {"_id": None, "avg_age": {"$avg": "$age"}}},
    ]
    async for doc in collection.aggregate(pipeline):
        print(doc)
    
    # Concurrent operations
    tasks = [
        collection.find_one({"name": f"User{i}"})
        for i in range(1, 11)
    ]
    results = await asyncio.gather(*tasks)
    
    client.close()

# Connection pooling and error handling
async def robust_connection():
    client = AsyncIOMotorClient(
        'mongodb://localhost:27017',
        maxPoolSize=10,
        minPoolSize=5,
        maxIdleTimeMS=30000,
        serverSelectionTimeoutMS=5000
    )
    
    try:
        # Test connection
        await client.admin.command('ping')
        print("Connected to MongoDB")
        
        db = client.mydatabase
        collection = db.users
        
        # Your operations here
        
    except Exception as e:
        print(f"Connection error: {e}")
    finally:
        client.close()
```

**Key points:**

- PyMongo offers direct, low-level access to MongoDB with maximum flexibility
- MongoEngine provides Django-like ORM functionality with schema validation
- Flask integration supports both PyMongo and MongoEngine approaches
- Django requires Djongo or MongoEngine for MongoDB compatibility
- Motor enables high-performance async operations for modern Python applications
- Connection pooling and error handling are crucial for production deployments
- Each approach has specific use cases depending on application requirements and existing technology stack

---

