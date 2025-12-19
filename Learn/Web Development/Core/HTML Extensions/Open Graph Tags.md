# Open Graph Tags

Open Graph tags are meta tags that control how URLs are displayed when shared on social media platforms. Created by Facebook in 2010, they've become a web standard used across many platforms including LinkedIn, Twitter (which has its own similar tags), Pinterest, and messaging apps.

## Purpose

When you share a link on social media, Open Graph tags tell the platform what title, description, image, and other metadata to display in the preview card. Without these tags, platforms make their best guess at what content to show, often with poor results.

## Basic Structure

Open Graph tags are placed in the `<head>` section of an HTML document and use the `property` attribute:

```html
<meta property="og:title" content="Your Page Title" />
<meta property="og:description" content="A brief description of your page" />
<meta property="og:image" content="https://example.com/image.jpg" />
<meta property="og:url" content="https://example.com/page" />
```

## Essential Tags

**og:title** – The title that appears in the share preview (typically 60-90 characters recommended)

**og:description** – A brief description of the content (typically 155-200 characters recommended)

**og:image** – URL to an image that represents the content. This is crucial for engagement. Recommended minimum size is 1200×630 pixels for most platforms.

**og:url** – The canonical URL of the page

**og:type** – The type of content (e.g., "website", "article", "video.movie", "music.song")

## Additional Common Tags

**og:site_name** – The name of your overall website

**og:locale** – The language/locale of the content (e.g., "en_US")

**og:video** – URL to a video file

**og:audio** – URL to an audio file

**og:determiner** – The word that appears before the title (e.g., "the", "a", "an")

## Article-Specific Tags

For blog posts and articles:

```html
<meta property="article:published_time" content="2024-01-15T08:00:00+00:00" />
<meta property="article:modified_time" content="2024-01-16T10:30:00+00:00" />
<meta property="article:author" content="Author Name" />
<meta property="article:section" content="Technology" />
<meta property="article:tag" content="web development" />
```

## Image Specifications

**og:image:url** – Same as og:image, sometimes used for clarity

**og:image:secure_url** – HTTPS version of the image URL

**og:image:type** – MIME type of the image (e.g., "image/jpeg")

**og:image:width** – Image width in pixels

**og:image:height** – Image height in pixels

**og:image:alt** – Alt text for the image

## Platform-Specific Variations

**Twitter Cards** – Twitter uses its own tags alongside Open Graph:
```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:site" content="@username" />
<meta name="twitter:creator" content="@username" />
```

Twitter will fall back to Open Graph tags if Twitter-specific tags aren't present.

## Testing and Validation

You can test how your Open Graph tags will appear using:

- Facebook Sharing Debugger (developers.facebook.com/tools/debug/)
- Twitter Card Validator
- LinkedIn Post Inspector
- Open Graph Check tools (various third-party options)

These tools also help clear cached versions when you update your tags.

## Best Practices

1. **Always include** og:title, og:description, og:image, and og:url at minimum
2. **Use high-quality images** – larger images (1200×630px) get better engagement
3. **Keep titles concise** – they may be truncated on different platforms
4. **Use absolute URLs** – always include the full URL including https://
5. **Test on multiple platforms** – different services may interpret tags differently
6. **Update when content changes** – especially important for news sites and blogs
7. **Use unique images per page** – avoid reusing the same image across your entire site

## Example Complete Implementation

```html
<head>
  <meta property="og:title" content="Complete Guide to Open Graph Tags" />
  <meta property="og:description" content="Learn how to optimize your website's appearance on social media with Open Graph meta tags." />
  <meta property="og:image" content="https://example.com/images/og-guide.jpg" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:url" content="https://example.com/guides/open-graph" />
  <meta property="og:type" content="article" />
  <meta property="og:site_name" content="Example Website" />
  <meta property="og:locale" content="en_US" />
  
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@example" />
</head>
```

## Common Issues

**Images not showing** – Check that the image URL is publicly accessible, uses https://, and meets minimum size requirements

**Outdated previews** – Use platform debugging tools to clear cache

**Content truncated** – Shorten titles and descriptions to recommended character limits

**Wrong content showing** – Ensure og:url points to the correct canonical URL

Open Graph tags are a straightforward way to significantly improve how your content appears when shared, potentially increasing click-through rates and engagement.

## Reference

### `og:type`

Open Graph supports a variety of `og:type` values that categorize your content. Here are the main types:

**Basic Types**

`website` – Default for general websites and pages
`article` – Blog posts, news articles, written content
`book` – Books and publications
`profile` – Personal profiles or user pages

**Music Types**

`music.song` – Individual songs
`music.album` – Music albums
`music.playlist` – Curated playlists
`music.radio_station` – Radio stations

**Video Types**

`video.movie` – Films and movies
`video.episode` – TV episodes or web series episodes
`video.tv_show` – TV shows
`video.other` – Other video content

**Additional Structured Types**

`product` – Products in e-commerce
`restaurant` – Restaurant pages
`bar` – Bar or pub pages
`company` – Company/business pages
`cafe` – Cafe pages
`hotel` – Hotel pages
`place` – General location pages
`city` – City pages
`country` – Country pages
`game` – Video games
`sport` – Sports content
`fitness.course` – Fitness courses

Each type can have associated properties. For example:

`article` type supports: `article:published_time`, `article:modified_time`, `article:author`, `article:section`, `article:tag`, `article:expiration_time`

`profile` type supports: `profile:first_name`, `profile:last_name`, `profile:username`, `profile:gender`

`music.song` type supports: `music:duration`, `music:album`, `music:musician`

`video.movie` type supports: `video:actor`, `video:director`, `video:writer`, `video:duration`, `video:release_date`, `video:tag`

`book` type supports: `book:author`, `book:isbn`, `book:release_date`, `book:tag`

If you don't specify a type, platforms typically default to `website`. The most commonly used types are `website`, `article`, `video.movie`, and `music.song`.

[Unverified] – While these are the documented Open Graph types, not all platforms support all types equally. Facebook has the most comprehensive support since they created the protocol. Testing on your target platforms is recommended to ensure the type you choose displays as expected.
