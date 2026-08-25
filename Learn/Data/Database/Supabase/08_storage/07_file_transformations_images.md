## File Transformations (Images)


Supabase Storage provides on-the-fly image transformations for resizing, formatting, and optimizing images without storing multiple versions.

Basic resize transformation:

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('avatar.png', {
    transform: {
      width: 200,
      height: 200
    }
  });
```

Resize with quality control:

```javascript
const { data } = supabase
  .storage
  .from('photos')
  .getPublicUrl('photo.jpg', {
    transform: {
      width: 800,
      height: 600,
      resize: 'cover', // or 'contain', 'fill'
      quality: 80
    }
  });
```

Format conversion:

```javascript
const { data } = supabase
  .storage
  .from('images')
  .getPublicUrl('image.png', {
    transform: {
      format: 'webp'
    }
  });
```

Available transformation options:

- `width`: Target width in pixels
- `height`: Target height in pixels
- `resize`: Fit mode (`cover`, `contain`, `fill`)
- `quality`: Output quality (1-100)
- `format`: Output format (`webp`, `jpeg`, `png`, `avif`)

Transformation resize modes:

**cover** - Resizes to fill dimensions, cropping excess:

```javascript
transform: { width: 400, height: 300, resize: 'cover' }
```

**contain** - Resizes to fit within dimensions, maintaining aspect ratio:

```javascript
transform: { width: 400, height: 300, resize: 'contain' }
```

**fill** - Resizes to exact dimensions, potentially distorting:

```javascript
transform: { width: 400, height: 300, resize: 'fill' }
```

Signed URLs with transformations:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-photos')
  .createSignedUrl('photo.jpg', 3600, {
    transform: {
      width: 500,
      height: 500,
      resize: 'cover'
    }
  });
```

Responsive image generation:

```javascript
const sizes = [400, 800, 1200];
const urls = sizes.map(width => {
  const { data } = supabase
    .storage
    .from('photos')
    .getPublicUrl('hero.jpg', {
      transform: { width, quality: 85 }
    });
  return data.publicUrl;
});
```

**[Unverified]** Transformation performance and caching behavior may vary based on image size, format, and CDN configuration.

