## Image and Media Optimization


### Advanced Responsive Image Techniques

Modern responsive images go far beyond simple CSS `max-width: 100%`. The `<picture>` element and `srcset` attribute provide precise control over which images load based on device characteristics, viewport size, and display density.

The `srcset` attribute allows browsers to choose the most appropriate image from multiple candidates. You can specify images based on width descriptors (`w`) or pixel density descriptors (`x`). Width descriptors work with the `sizes` attribute to inform the browser about the image's display size at different viewport widths.

```html
<img src="image-800.jpg" 
     srcset="image-400.jpg 400w,
             image-800.jpg 800w,
             image-1200.jpg 1200w,
             image-1600.jpg 1600w"
     sizes="(max-width: 600px) 100vw,
            (max-width: 1000px) 50vw,
            800px"
     alt="Responsive image example">
```

The `<picture>` element provides art direction capabilities, allowing completely different images for different contexts. This is essential when image composition needs to change dramatically across devices.

```html
<picture>
  <source media="(max-width: 600px)" 
          srcset="mobile-portrait.jpg">
  <source media="(max-width: 1000px)" 
          srcset="tablet-landscape.jpg">
  <img src="desktop-wide.jpg" alt="Art-directed image">
</picture>
```

**Key points**: Implement lazy loading with the `loading="lazy"` attribute for images below the fold. Use `decoding="async"` to prevent image decoding from blocking the main thread. Consider implementing intersection observer-based lazy loading for more control over loading behavior.

### WebP and Next-Gen Image Formats

WebP provides superior compression compared to JPEG and PNG, typically reducing file sizes by 25-50% while maintaining visual quality. AVIF offers even better compression but has limited browser support. Modern optimization strategies use format fallbacks through the `<picture>` element.

```html
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Next-gen format with fallbacks">
</picture>
```

Automated conversion workflows using tools like Sharp, ImageMagick, or cloud services ensure you generate multiple formats without manual intervention. Build processes should automatically create WebP and AVIF versions alongside traditional formats.

Quality settings require careful tuning. WebP typically performs well at 80-85% quality, while AVIF can maintain excellent visual quality at 50-60%. Progressive JPEG loading provides perceived performance benefits for slower connections.

**Key points**: Implement automated format detection and serving through server-side logic or CDN rules. Monitor Core Web Vitals metrics to ensure format optimizations improve real-world performance. Consider using CSS `image-set()` for background images to leverage next-gen formats.

### Video Optimization and Streaming

Video optimization encompasses multiple strategies: codec selection, bitrate optimization, adaptive streaming, and delivery methods. Modern web video relies heavily on H.264 for compatibility and H.265/VP9/AV1 for efficiency.

Adaptive bitrate streaming adjusts video quality based on network conditions and device capabilities. HTTP Live Streaming (HLS) and Dynamic Adaptive Streaming over HTTP (DASH) are the primary protocols. These segment videos into small chunks with multiple quality levels.

```html
<video controls preload="metadata" poster="video-poster.jpg">
  <source src="video.mp4" type="video/mp4">
  <source src="video.webm" type="video/webm">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
</video>
```

Video preloading strategies significantly impact performance. Use `preload="none"` for videos that might not be played, `preload="metadata"` for videos likely to be played, and `preload="auto"` sparingly for critical above-the-fold videos.

Compression settings balance file size and quality. Two-pass encoding provides better quality at the same bitrate compared to single-pass encoding. Target bitrates vary by resolution: 1080p typically needs 5-8 Mbps for high quality, 720p needs 2.5-4 Mbps.

**Key points**: Implement video lazy loading for videos below the fold. Use fade-in animations to mask loading states. Consider using intersection observers to start video preloading when videos enter the viewport vicinity.

### CDN Integration Strategies

Content Delivery Networks optimize media delivery through geographic distribution, edge caching, and on-the-fly optimization. Modern CDNs provide image and video transformation capabilities, eliminating the need for pre-generating multiple variants.

Smart CDN configuration includes setting appropriate cache headers, implementing cache invalidation strategies, and configuring origin shield layers for popular content. Time-to-live (TTL) settings should balance content freshness with cache efficiency.

```html
<!-- CDN with automatic optimization -->
<img src="https://cdn.example.com/image.jpg?w=800&f=webp&q=85" 
     alt="CDN-optimized image">
```

Edge computing capabilities enable real-time image resizing, format conversion, and quality optimization based on client hints and device characteristics. This approach reduces origin server load and improves response times globally.

Performance monitoring should track CDN metrics including cache hit ratios, origin response times, and edge response times. Geographic performance analysis helps identify regions needing additional edge locations or optimization.

**Key points**: Configure CDN purging strategies for content updates. Implement proper CORS headers for cross-origin media requests. Use CDN analytics to optimize cache policies and identify performance bottlenecks.

### Advanced Optimization Techniques

Client hints provide browsers with a mechanism to communicate device capabilities and network conditions to servers. The `Accept` header indicates supported image formats, while `DPR`, `Width`, and `Viewport-Width` headers provide device-specific information.

```html
<meta http-equiv="Accept-CH" content="DPR, Width, Viewport-Width">
```

Critical resource hints improve loading performance through `preload`, `prefetch`, and `preconnect` directives. Preloading hero images ensures they start downloading immediately, while prefetching likely-needed resources improves perceived performance.

```html
<link rel="preload" as="image" href="hero-image.webp" type="image/webp">
<link rel="preconnect" href="https://cdn.example.com">
```

Service workers enable sophisticated caching strategies for media assets. You can implement cache-first strategies for immutable assets, network-first for frequently updated content, and stale-while-revalidate for optimal perceived performance.

**Example**: A comprehensive media optimization strategy might combine responsive images with WebP/AVIF formats, CDN delivery, and service worker caching to achieve 90+ PageSpeed scores while maintaining visual quality.

**Conclusion**: Effective image and media optimization requires a holistic approach combining format selection, responsive delivery, CDN integration, and performance monitoring. The key is implementing automated workflows that optimize assets without requiring manual intervention for each piece of content.

---

