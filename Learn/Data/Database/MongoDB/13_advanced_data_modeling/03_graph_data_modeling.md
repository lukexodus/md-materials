## Graph Data Modeling


### Representing Relationships

Graph data modeling in MongoDB involves structuring documents to represent nodes and edges, enabling complex relationship patterns through embedded documents, references, and hybrid approaches.

**Basic node-edge model:**

```javascript
// Users collection (nodes)
{
  _id: ObjectId("..."),
  username: "alice",
  name: "Alice Johnson",
  email: "alice@example.com",
  profile: {
    interests: ["photography", "travel", "technology"],
    location: "San Francisco"
  }
}

// Relationships collection (edges)
{
  _id: ObjectId("..."),
  from_user: ObjectId("alice_id"),
  to_user: ObjectId("bob_id"),
  relationship_type: "follows",
  created_at: ISODate("2024-01-15"),
  metadata: {
    mutual: false,
    strength: 0.7
  }
}
```

**Embedded relationships approach:**

```javascript
// User with embedded connections
{
  _id: ObjectId("..."),
  username: "alice",
  name: "Alice Johnson",
  following: [
    {
      user_id: ObjectId("bob_id"),
      username: "bob",
      followed_at: ISODate("2024-01-15"),
      relationship_strength: 0.8
    },
    {
      user_id: ObjectId("charlie_id"),
      username: "charlie",
      followed_at: ISODate("2024-01-20"),
      relationship_strength: 0.6
    }
  ],
  followers: [
    {
      user_id: ObjectId("david_id"),
      username: "david",
      followed_at: ISODate("2024-01-10")
    }
  ],
  stats: {
    following_count: 2,
    followers_count: 1
  }
}
```

**Hierarchical relationships:**

```javascript
// Organization structure
{
  _id: ObjectId("..."),
  employee_id: "EMP001",
  name: "John Manager",
  position: "Senior Manager",
  department: "Engineering",
  reports_to: ObjectId("ceo_id"),
  direct_reports: [
    ObjectId("dev1_id"),
    ObjectId("dev2_id"),
    ObjectId("lead_id")
  ],
  hierarchy_path: ["ceo_id", "vp_eng_id", "senior_mgr_id"],
  level: 3
}
```

**Weighted relationship model:**

```javascript
// Social network with interaction weights
{
  _id: ObjectId("..."),
  user_id: ObjectId("alice_id"),
  connections: [
    {
      connected_to: ObjectId("bob_id"),
      relationship_types: ["friend", "colleague"],
      interactions: {
        messages: 45,
        likes: 23,
        comments: 12,
        shared_events: 3
      },
      last_interaction: ISODate("2024-01-25"),
      connection_strength: 0.85
    }
  ]
}
```

**Multi-layer graph representation:**

```javascript
// Professional network with multiple relationship types
{
  _id: ObjectId("..."),
  person_id: ObjectId("alice_id"),
  professional_network: {
    colleagues: [
      {
        person_id: ObjectId("bob_id"),
        company: "TechCorp",
        collaboration_projects: ["ProjectA", "ProjectB"],
        endorsements: ["JavaScript", "MongoDB"]
      }
    ],
    mentorship: {
      mentoring: [ObjectId("junior_dev_id")],
      mentored_by: [ObjectId("senior_architect_id")]
    },
    professional_groups: [
      {
        group_id: ObjectId("js_developers_group"),
        role: "moderator",
        joined_date: ISODate("2023-06-01")
      }
    ]
  }
}
```

### Graph Traversal with $graphLookup

The `$graphLookup` aggregation stage performs recursive searches on collections, enabling complex graph traversals and relationship discovery.

**Basic $graphLookup syntax:**

```javascript
// Find all people in reporting hierarchy
db.employees.aggregate([
  {
    $match: { employee_id: "EMP001" }
  },
  {
    $graphLookup: {
      from: "employees",
      startWith: "$_id",
      connectFromField: "_id",
      connectToField: "reports_to",
      as: "subordinates",
      maxDepth: 10
    }
  }
])
```

**Multi-level friend discovery:**

```javascript
// Find friends of friends up to 3 degrees
db.users.aggregate([
  {
    $match: { username: "alice" }
  },
  {
    $graphLookup: {
      from: "relationships",
      startWith: "$_id",
      connectFromField: "to_user",
      connectToField: "from_user",
      as: "network",
      maxDepth: 2,
      restrictSearchWithMatch: {
        relationship_type: "follows"
      }
    }
  },
  {
    $addFields: {
      network_size: { $size: "$network" },
      direct_connections: {
        $filter: {
          input: "$network",
          cond: { $eq: ["$$this.depth", 0] }
        }
      },
      second_degree: {
        $filter: {
          input: "$network",
          cond: { $eq: ["$$this.depth", 1] }
        }
      }
    }
  }
])
```

**Circular reference detection:**

```javascript
// Detect potential circular reporting structures
db.employees.aggregate([
  {
    $graphLookup: {
      from: "employees",
      startWith: "$reports_to",
      connectFromField: "reports_to",
      connectToField: "_id",
      as: "management_chain",
      maxDepth: 20
    }
  },
  {
    $addFields: {
      has_circular_reference: {
        $in: ["$_id", "$management_chain._id"]
      }
    }
  },
  {
    $match: { has_circular_reference: true }
  }
])
```

**Path finding with conditions:**

```javascript
// Find shortest path between users through mutual connections
db.users.aggregate([
  {
    $match: { username: "alice" }
  },
  {
    $graphLookup: {
      from: "relationships",
      startWith: "$_id",
      connectFromField: "to_user",
      connectToField: "from_user",
      as: "path_to_target",
      maxDepth: 4,
      restrictSearchWithMatch: {
        relationship_type: { $in: ["friend", "close_friend"] },
        is_active: true
      },
      depthField: "connection_depth"
    }
  },
  {
    $unwind: "$path_to_target"
  },
  {
    $lookup: {
      from: "users",
      localField: "path_to_target.to_user",
      foreignField: "_id",
      as: "target_user"
    }
  },
  {
    $match: {
      "target_user.username": "target_username"
    }
  },
  {
    $group: {
      _id: "$path_to_target.to_user",
      shortest_path_depth: { $min: "$path_to_target.connection_depth" },
      paths: { $push: "$path_to_target" }
    }
  }
])
```

**Advanced traversal with data enrichment:**

```javascript
// Analyze influence propagation in social network
db.users.aggregate([
  {
    $match: { 
      influence_score: { $gte: 0.8 },
      account_type: "verified"
    }
  },
  {
    $graphLookup: {
      from: "relationships",
      startWith: "$_id",
      connectFromField: "to_user",
      connectToField: "from_user",
      as: "influence_network",
      maxDepth: 3,
      restrictSearchWithMatch: {
        relationship_strength: { $gte: 0.5 },
        relationship_type: { $in: ["follows", "friend"] }
      },
      depthField: "influence_depth"
    }
  },
  {
    $unwind: "$influence_network"
  },
  {
    $lookup: {
      from: "users",
      localField: "influence_network.to_user",
      foreignField: "_id",
      as: "influenced_user"
    }
  },
  {
    $unwind: "$influenced_user"
  },
  {
    $addFields: {
      influence_decay: {
        $divide: [
          "$influence_score",
          { $add: ["$influence_network.influence_depth", 1] }
        ]
      }
    }
  },
  {
    $group: {
      _id: "$influenced_user._id",
      username: { $first: "$influenced_user.username" },
      total_influence_received: { $sum: "$influence_decay" },
      influence_sources: {
        $push: {
          source_user: "$username",
          depth: "$influence_network.influence_depth",
          direct_influence: "$influence_decay"
        }
      }
    }
  },
  {
    $sort: { total_influence_received: -1 }
  }
])
```

### Social Network Patterns

Social networks require specialized data modeling patterns to handle friend relationships, content sharing, and community structures effectively.

**Bidirectional friendship model:**

```javascript
// Friendship with mutual acceptance
{
  _id: ObjectId("..."),
  user1: ObjectId("alice_id"),
  user2: ObjectId("bob_id"),
  status: "accepted", // pending, accepted, blocked
  initiated_by: ObjectId("alice_id"),
  created_at: ISODate("2024-01-15"),
  accepted_at: ISODate("2024-01-16"),
  interaction_history: {
    last_message: ISODate("2024-01-25"),
    total_messages: 45,
    shared_posts: 12,
    mutual_likes: 67
  }
}

// Query mutual friends
db.friendships.aggregate([
  {
    $match: {
      $or: [
        { user1: ObjectId("alice_id") },
        { user2: ObjectId("alice_id") }
      ],
      status: "accepted"
    }
  },
  {
    $addFields: {
      alice_friend: {
        $cond: {
          if: { $eq: ["$user1", ObjectId("alice_id")] },
          then: "$user2",
          else: "$user1"
        }
      }
    }
  },
  {
    $lookup: {
      from: "friendships",
      let: { friend_id: "$alice_friend" },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $or: [
                    { $eq: ["$user1", ObjectId("bob_id")] },
                    { $eq: ["$user2", ObjectId("bob_id")] }
                  ]
                },
                {
                  $or: [
                    { $eq: ["$user1", "$$friend_id"] },
                    { $eq: ["$user2", "$$friend_id"] }
                  ]
                },
                { $eq: ["$status", "accepted"] }
              ]
            }
          }
        }
      ],
      as: "mutual_connection"
    }
  },
  {
    $match: { mutual_connection: { $ne: [] } }
  }
])
```

**Activity feed and timeline:**

```javascript
// User activity for timeline generation
{
  _id: ObjectId("..."),
  user_id: ObjectId("alice_id"),
  activity_type: "post_created",
  content: {
    post_id: ObjectId("post123"),
    text: "Beautiful sunset today!",
    media: ["image1.jpg"],
    hashtags: ["sunset", "photography"],
    mentions: [ObjectId("bob_id")]
  },
  timestamp: ISODate("2024-01-25T18:30:00Z"),
  visibility: "friends", // public, friends, private
  engagement: {
    likes: 15,
    comments: 3,
    shares: 2
  }
}

// Generate personalized timeline
db.activities.aggregate([
  // Get user's friends
  {
    $lookup: {
      from: "friendships",
      let: { current_user: ObjectId("alice_id") },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $or: [
                    { $eq: ["$user1", "$$current_user"] },
                    { $eq: ["$user2", "$$current_user"] }
                  ]
                },
                { $eq: ["$status", "accepted"] }
              ]
            }
          }
        },
        {
          $addFields: {
            friend_id: {
              $cond: {
                if: { $eq: ["$user1", "$$current_user"] },
                then: "$user2",
                else: "$user1"
              }
            }
          }
        }
      ],
      as: "friendships"
    }
  },
  {
    $addFields: {
      friend_ids: "$friendships.friend_id"
    }
  },
  // Filter activities from friends
  {
    $match: {
      $or: [
        { user_id: { $in: "$friend_ids" } },
        { user_id: ObjectId("alice_id") }
      ],
      visibility: { $in: ["public", "friends"] },
      timestamp: { $gte: ISODate("2024-01-01") }
    }
  },
  {
    $sort: { timestamp: -1 }
  },
  {
    $limit: 50
  }
])
```

**Community and group modeling:**

```javascript
// Social groups with hierarchical roles
{
  _id: ObjectId("..."),
  group_name: "Photography Enthusiasts",
  description: "Share and discuss photography techniques",
  group_type: "public", // public, private, secret
  created_by: ObjectId("alice_id"),
  created_at: ISODate("2024-01-01"),
  members: [
    {
      user_id: ObjectId("alice_id"),
      role: "admin",
      joined_at: ISODate("2024-01-01"),
      permissions: ["post", "moderate", "invite", "manage"]
    },
    {
      user_id: ObjectId("bob_id"),
      role: "moderator",
      joined_at: ISODate("2024-01-05"),
      permissions: ["post", "moderate", "invite"]
    },
    {
      user_id: ObjectId("charlie_id"),
      role: "member",
      joined_at: ISODate("2024-01-10"),
      permissions: ["post"]
    }
  ],
  statistics: {
    member_count: 3,
    post_count: 45,
    active_members_30d: 2
  },
  settings: {
    posting_allowed: true,
    approval_required: false,
    invite_only: false
  }
}
```

### Recommendation Systems

Graph-based recommendation systems leverage relationship data and user behavior patterns to suggest connections, content, and products.

**Collaborative filtering model:**

```javascript
// User preferences and ratings
{
  _id: ObjectId("..."),
  user_id: ObjectId("alice_id"),
  item_interactions: [
    {
      item_id: ObjectId("book_123"),
      item_type: "book",
      interaction_type: "rating",
      value: 4.5,
      timestamp: ISODate("2024-01-15"),
      context: {
        genre: "sci-fi",
        author: "Isaac Asimov"
      }
    },
    {
      item_id: ObjectId("movie_456"),
      item_type: "movie",
      interaction_type: "watch_time",
      value: 0.85, // 85% completion
      timestamp: ISODate("2024-01-20"),
      context: {
        genre: "thriller",
        director: "Christopher Nolan"
      }
    }
  ],
  preferences: {
    genres: {
      "sci-fi": 0.9,
      "thriller": 0.8,
      "comedy": 0.6
    },
    authors: {
      "Isaac Asimov": 0.95,
      "Philip K. Dick": 0.85
    }
  }
}

// Generate book recommendations using collaborative filtering
db.user_preferences.aggregate([
  {
    $match: { user_id: ObjectId("alice_id") }
  },
  {
    $unwind: "$item_interactions"
  },
  {
    $match: {
      "item_interactions.item_type": "book",
      "item_interactions.value": { $gte: 4.0 }
    }
  },
  // Find users with similar preferences
  {
    $lookup: {
      from: "user_preferences",
      let: { 
        alice_item: "$item_interactions.item_id",
        alice_rating: "$item_interactions.value"
      },
      pipeline: [
        { $unwind: "$item_interactions" },
        {
          $match: {
            $expr: {
              $and: [
                { $eq: ["$item_interactions.item_id", "$$alice_item"] },
                { $gte: ["$item_interactions.value", 4.0] },
                { $ne: ["$user_id", ObjectId("alice_id")] }
              ]
            }
          }
        }
      ],
      as: "similar_users"
    }
  },
  {
    $unwind: "$similar_users"
  },
  // Calculate similarity score
  {
    $addFields: {
      similarity_score: {
        $subtract: [
          1,
          {
            $abs: {
              $subtract: [
                "$item_interactions.value",
                "$similar_users.item_interactions.value"
              ]
            }
          }
        ]
      }
    }
  },
  // Group by similar user and calculate average similarity
  {
    $group: {
      _id: "$similar_users.user_id",
      avg_similarity: { $avg: "$similarity_score" },
      common_items: { $sum: 1 }
    }
  },
  {
    $match: {
      avg_similarity: { $gte: 0.7 },
      common_items: { $gte: 3 }
    }
  },
  // Get recommendations from similar users
  {
    $lookup: {
      from: "user_preferences",
      localField: "_id",
      foreignField: "user_id",
      as: "similar_user_prefs"
    }
  },
  {
    $unwind: "$similar_user_prefs"
  },
  {
    $unwind: "$similar_user_prefs.item_interactions"
  },
  {
    $match: {
      "similar_user_prefs.item_interactions.item_type": "book",
      "similar_user_prefs.item_interactions.value": { $gte: 4.0 }
    }
  },
  // Check if Alice hasn't interacted with these items
  {
    $lookup: {
      from: "user_preferences",
      let: { recommend_item: "$similar_user_prefs.item_interactions.item_id" },
      pipeline: [
        {
          $match: {
            user_id: ObjectId("alice_id"),
            "item_interactions.item_id": "$$recommend_item"
          }
        }
      ],
      as: "alice_interaction"
    }
  },
  {
    $match: { alice_interaction: [] }
  },
  // Score recommendations
  {
    $addFields: {
      recommendation_score: {
        $multiply: [
          "$avg_similarity",
          "$similar_user_prefs.item_interactions.value"
        ]
      }
    }
  },
  {
    $group: {
      _id: "$similar_user_prefs.item_interactions.item_id",
      avg_score: { $avg: "$recommendation_score" },
      recommender_count: { $sum: 1 }
    }
  },
  {
    $sort: { avg_score: -1 }
  },
  {
    $limit: 10
  }
])
```

**Content-based recommendations:**

```javascript
// Content similarity and user profile matching
db.items.aggregate([
  // Start with user's highly-rated items
  {
    $lookup: {
      from: "user_preferences",
      let: { item_id: "$_id" },
      pipeline: [
        {
          $match: {
            user_id: ObjectId("alice_id"),
            "item_interactions.item_id": "$$item_id",
            "item_interactions.value": { $gte: 4.0 }
          }
        }
      ],
      as: "user_liked"
    }
  },
  {
    $match: { user_liked: { $ne: [] } }
  },
  // Find similar items based on features
  {
    $lookup: {
      from: "items",
      let: { 
        source_genres: "$genres",
        source_tags: "$tags",
        source_author: "$author"
      },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                { $ne: ["$_id", "$$source_item_id"] },
                {
                  $or: [
                    { $setIsSubset: [["$$source_author"], ["$author"]] },
                    { $gt: [{ $size: { $setIntersection: ["$genres", "$$source_genres"] } }, 0] },
                    { $gt: [{ $size: { $setIntersection: ["$tags", "$$source_tags"] } }, 1] }
                  ]
                }
              ]
            }
          }
        },
        {
          $addFields: {
            similarity_score: {
              $add: [
                {
                  $cond: {
                    if: { $eq: ["$author", "$$source_author"] },
                    then: 0.4,
                    else: 0
                  }
                },
                {
                  $multiply: [
                    0.3,
                    {
                      $divide: [
                        { $size: { $setIntersection: ["$genres", "$$source_genres"] } },
                        { $size: { $setUnion: ["$genres", "$$source_genres"] } }
                      ]
                    }
                  ]
                },
                {
                  $multiply: [
                    0.3,
                    {
                      $divide: [
                        { $size: { $setIntersection: ["$tags", "$$source_tags"] } },
                        { $size: { $setUnion: ["$tags", "$$source_tags"] } }
                      ]
                    }
                  ]
                }
              ]
            }
          }
        },
        {
          $match: { similarity_score: { $gte: 0.3 } }
        }
      ],
      as: "similar_items"
    }
  },
  {
    $unwind: "$similar_items"
  },
  // Check if user hasn't interacted with recommended items
  {
    $lookup: {
      from: "user_preferences",
      let: { recommend_id: "$similar_items._id" },
      pipeline: [
        {
          $match: {
            user_id: ObjectId("alice_id"),
            "item_interactions.item_id": "$$recommend_id"
          }
        }
      ],
      as: "existing_interaction"
    }
  },
  {
    $match: { existing_interaction: [] }
  },
  {
    $group: {
      _id: "$similar_items._id",
      title: { $first: "$similar_items.title" },
      author: { $first: "$similar_items.author" },
      avg_similarity: { $avg: "$similar_items.similarity_score" },
      source_count: { $sum: 1 }
    }
  },
  {
    $sort: { avg_similarity: -1, source_count: -1 }
  },
  {
    $limit: 10
  }
])
```

**Social recommendation system:**

```javascript
// Friend-based recommendations with social proof
db.users.aggregate([
  {
    $match: { _id: ObjectId("alice_id") }
  },
  // Get Alice's friends
  {
    $lookup: {
      from: "friendships",
      let: { alice_id: "$_id" },
      pipeline: [
        {
          $match: {
            $expr: {
              $and: [
                {
                  $or: [
                    { $eq: ["$user1", "$$alice_id"] },
                    { $eq: ["$user2", "$$alice_id"] }
                  ]
                },
                { $eq: ["$status", "accepted"] }
              ]
            }
          }
        },
        {
          $addFields: {
            friend_id: {
              $cond: {
                if: { $eq: ["$user1", "$$alice_id"] },
                then: "$user2",
                else: "$user1"
              }
            }
          }
        }
      ],
      as: "friendships"
    }
  },
  // Get friends' recent activities
  {
    $lookup: {
      from: "user_preferences",
      let: { friend_ids: "$friendships.friend_id" },
      pipeline: [
        {
          $match: {
            $expr: { $in: ["$user_id", "$$friend_ids"] }
          }
        },
        { $unwind: "$item_interactions" },
        {
          $match: {
            "item_interactions.value": { $gte: 4.0 },
            "item_interactions.timestamp": {
              $gte: ISODate("2024-01-01")
            }
          }
        },
        {
          $lookup: {
            from: "items",
            localField: "item_interactions.item_id",
            foreignField: "_id",
            as: "item_details"
          }
        },
        { $unwind: "$item_details" }
      ],
      as: "friend_recommendations"
    }
  },
  { $unwind: "$friend_recommendations" },
  // Check Alice hasn't interacted with these items
  {
    $lookup: {
      from: "user_preferences",
      let: { item_id: "$friend_recommendations.item_interactions.item_id" },
      pipeline: [
        {
          $match: {
            user_id: ObjectId("alice_id"),
            "item_interactions.item_id": "$$item_id"
          }
        }
      ],
      as: "alice_interaction"
    }
  },
  {
    $match: { alice_interaction: [] }
  },
  // Calculate social recommendation score
  {
    $addFields: {
      social_score: {
        $multiply: [
          "$friend_recommendations.item_interactions.value",
          {
            $divide: [
              "$friendships.interaction_history.total_messages",
              100
            ]
          }
        ]
      }
    }
  },
  {
    $group: {
      _id: "$friend_recommendations.item_interactions.item_id",
      item_details: { $first: "$friend_recommendations.item_details" },
      avg_friend_rating: { $avg: "$friend_recommendations.item_interactions.value" },
      friend_count: { $sum: 1 },
      recommending_friends: {
        $push: {
          user_id: "$friend_recommendations.user_id",
          rating: "$friend_recommendations.item_interactions.value",
          social_weight: "$social_score"
        }
      },
      total_social_score: { $sum: "$social_score" }
    }
  },
  {
    $match: {
      friend_count: { $gte: 2 },
      avg_friend_rating: { $gte: 4.0 }
    }
  },
  {
    $sort: { total_social_score: -1, friend_count: -1 }
  },
  {
    $limit: 15
  }
])
```

**Key points:**

- Graph modeling requires careful consideration of relationship cardinality and query patterns
- `$graphLookup` enables powerful recursive traversals but should be used with appropriate depth limits and restrictions
- Social network patterns benefit from denormalization for frequently accessed relationship data
- Recommendation systems combine multiple signals including collaborative filtering, content similarity, and social proof
- [Inference] Performance optimization through proper indexing on relationship fields is crucial for graph operations
- Hybrid approaches combining embedded and referenced relationships often provide the best balance of performance and flexibility

---

