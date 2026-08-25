## Storage Buckets Creation and Management


Buckets are containers that organize and isolate files. Each bucket maintains its own security policies and configuration settings.

Creating a bucket via SQL:

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
```

Creating a bucket via JavaScript client:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('avatars', {
    public: false,
    fileSizeLimit: 1048576, // 1MB in bytes
    allowedMimeTypes: ['image/png', 'image/jpeg']
  });
```

Retrieving bucket details:

```javascript
const { data, error } = await supabase
  .storage
  .getBucket('avatars');
```

Updating bucket configuration:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('avatars', {
    public: false,
    fileSizeLimit: 2097152 // 2MB
  });
```

Deleting a bucket:

```javascript
const { data, error } = await supabase
  .storage
  .deleteBucket('avatars');
```

Listing all buckets:

```javascript
const { data, error } = await supabase
  .storage
  .listBuckets();
```

Emptying a bucket (removing all files):

```javascript
const { data, error } = await supabase
  .storage
  .emptyBucket('avatars');
```

Bucket naming constraints follow object storage conventions: lowercase alphanumeric characters, hyphens, and underscores only.

