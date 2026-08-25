## Realtime with RLS


Row Level Security policies apply to Realtime subscriptions, ensuring users only receive database changes for data they're authorized to access.

**Key points:**

- RLS policies evaluated for each database change event
- Users only receive changes for rows matching their RLS policies
- Both SELECT and target operation policies checked (INSERT, UPDATE, DELETE)
- Anonymous users subject to RLS policies for anon role
- Authenticated users evaluated against auth.uid() in policies
- Filters and RLS policies combined (both must pass)
- RLS evaluation happens before message delivery

**Example:** Basic RLS policy for user-specific data

```sql
-- Users can only see their own messages
CREATE POLICY "Users can view own messages"
ON messages FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can see new messages they create
CREATE POLICY "Users can insert own messages"
ON messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

With this policy, users subscribing to message changes only receive events for their own messages:

```javascript
// User A (ID: user-a-123) subscribes
const channel = supabase
  .channel('my-messages')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'messages' },
    (payload) => {
      // Only receives events for messages where user_id = 'user-a-123'
      console.log('My message changed:', payload)
    }
  )
  .subscribe()
```

**Example:** Shared resource with role-based access

```sql
-- Team members can view messages in their team's rooms
CREATE POLICY "Team members see room messages"
ON messages FOR SELECT
TO authenticated
USING (
  room_id IN (
    SELECT room_id 
    FROM room_members 
    WHERE user_id = auth.uid()
  )
);
```

```javascript
// User receives messages from all rooms they're a member of
const channel = supabase
  .channel('team-messages')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    (payload) => {
      // Only receives if user is member of payload.new.room_id
      addMessageToUI(payload.new)
    }
  )
  .subscribe()
```

**Example:** Public and private data separation

```sql
-- Everyone can see public posts
CREATE POLICY "Anyone can view public posts"
ON posts FOR SELECT
TO authenticated, anon
USING (visibility = 'public');

-- Only author can see draft posts
CREATE POLICY "Authors can view own drafts"
ON posts FOR SELECT
TO authenticated
USING (visibility = 'draft' AND auth.uid() = author_id);
```

```javascript
// Anonymous user subscription
const publicChannel = supabase
  .channel('public-posts')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'posts' },
    (payload) => {
      // Only receives public posts (visibility = 'public')
      displayPost(payload.new)
    }
  )
  .subscribe()

// Authenticated user subscription
const myDraftsChannel = supabase
  .channel('my-drafts')
  .on('postgres_changes',
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'posts',
      filter: `author_id=eq.${currentUser.id}`
    },
    (payload) => {
      // Receives all updates to own posts (public and drafts)
      updatePostInUI(payload.new)
    }
  )
  .subscribe()
```

**Example:** Complex RLS with metadata checks

```sql
-- Users can see messages where they are participants
CREATE POLICY "Participants see conversation messages"
ON messages FOR SELECT
TO authenticated
USING (
  conversation_id IN (
    SELECT c.id 
    FROM conversations c
    WHERE (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
       OR c.participant_ids @> ARRAY[auth.uid()]::uuid[]
  )
);
```

**Important RLS considerations with Realtime:**

- [Inference: RLS evaluation adds latency to message delivery, though typically minimal]
- Complex RLS policies may impact Realtime performance at scale
- Policy changes require reconnection to take effect [Unverified: reconnection requirement]
- Testing RLS with Realtime requires authenticated sessions
- Broadcast and Presence respect channel-level authorization, not RLS

