## Route Masking

Route masking in TanStack Router allows a route to display a different URL in the browser address bar than the one it actually renders. The real route handles the navigation and renders the component; the masked URL is what the user sees and what gets copied if they share the link. It is a presentation layer over the actual route structure.

---

### What Route Masking Is

When a route is masked, two URLs are involved:

- **The real route** — the route that actually matches and renders
- **The mask** — the URL displayed in the address bar

These are decoupled. The component, loader, and params all belong to the real route. The mask is purely cosmetic from the router's perspective but is what the browser history and address bar reflect.

A common use case is modal routes. A photo gallery at `/photos` opens a photo in a modal at `/photos/42` internally, but the address bar shows `/photos/42` while the background gallery remains visible — or alternatively, the modal opens over `/photos` and the URL stays as `/photos/42` for shareability while the modal content is the real rendered route.

---

### `mask` on `<Link>`

The `mask` option on `<Link>` specifies the URL to display instead of the real navigation target:

```tsx
<Link
  to="/photos/$photoId"
  params={{ photoId: photo.id }}
  mask={{
    to: '/photos',
  }}
>
  {photo.title}
</Link>
```

**Key Points:**
- The navigation target is `/photos/$photoId` — that route's loader and component execute
- The browser address bar shows `/photos`
- If the user refreshes, the browser navigates to `/photos` — the mask URL — not the real route
- Sharing the URL from the address bar shares `/photos`, not `/photos/42`

---

### `mask` on `router.navigate`

Programmatic navigation supports masking via the same `mask` option:

```ts
router.navigate({
  to: '/photos/$photoId',
  params: { photoId: '42' },
  mask: {
    to: '/photos',
  },
})
```

The behavior is identical to `<Link>` with `mask`.

---

### What Happens on Refresh

When the user refreshes the page, the browser loads the URL in the address bar — the mask URL, not the real route. The masked route is not stored in browser history as the real route.

This is intentional. Masking is designed for ephemeral overlay states where:
- The real route is not directly linkable in isolation
- The user should land on the background context if they reload or share the URL

```
User navigates via masked link:
  Real route: /photos/42     ← renders photo modal
  Address bar: /photos       ← mask

User refreshes:
  Browser loads: /photos     ← mask URL
  Modal is gone — user sees the gallery
```

---

### `unmaskOnReload`

To override the default refresh behavior and preserve the real route on reload, set `unmaskOnReload` on the router or per-navigation:

```ts
const router = createRouter({
  routeTree,
  unmaskOnReload: true,
})
```

Per-navigation:

```tsx
<Link
  to="/photos/$photoId"
  params={{ photoId: photo.id }}
  mask={{ to: '/photos' }}
  unmaskOnReload
>
  View photo
</Link>
```

**Key Points:**
- `unmaskOnReload: true` causes the real route URL to be restored in the address bar on page reload
- The user then sees `/photos/42` in the address bar after refresh and the real route renders directly
- Global and per-link settings are available; per-link takes precedence [Inference — verify precedence behavior in your version]

---

### Modal Route Pattern

The canonical use case for route masking is intercepted or overlaid modal routes. The pattern works as follows:

- A list page (`/photos`) renders normally when navigated to directly
- A detail route (`/photos/$photoId`) renders a modal over the list when navigated to from within the app
- The address bar shows `/photos/$photoId` for shareability, but the background list remains visible
- On refresh or direct navigation to `/photos/$photoId`, the detail renders as a full page — no background list

This requires the real route (`/photos/$photoId`) to render differently depending on whether it was reached via an in-app masked navigation or directly:

```tsx
// photos/$photoId.tsx component
function PhotoDetailComponent() {
  const isModal = /* detect if rendered as modal */ ...

  if (isModal) {
    return <PhotoModal />
  }

  return <PhotoFullPage />
}
```

TanStack Router does not provide a built-in `isModal` flag. [Inference] The common approach is to check router state or use a layout-based detection mechanism. Detection strategies vary by implementation.

---

### Detecting Masked Navigation State

The router's matched route state can be inspected to determine if the current render is the result of a masked navigation. The `router.state.maskedLocation` property holds the mask URL when active:

```ts
const router = useRouter()
const isMasked = !!router.state.maskedLocation
```

[Unverified — verify the exact property name and structure for `maskedLocation` in your installed version; the API surface for mask state inspection has evolved across releases]

---

### `mask` with Search Params and Hash

The mask URL supports the full navigation options shape — search params, hash, and params:

```tsx
<Link
  to="/items/$itemId"
  params={{ itemId: item.id }}
  mask={{
    to: '/items',
    search: { category: item.category },
    hash: 'item-list',
  }}
>
  {item.name}
</Link>
```

The address bar shows `/items?category=electronics#item-list`. The real route `/items/42` renders.

---

### Masking Does Not Affect Loaders

The mask has no effect on which route loads or what data is fetched. The real route's `beforeLoad`, `loader`, and component all execute as normal. The mask is applied only to the browser history entry and address bar display.

**Key Points:**
- `context`, `params`, and `search` inside `beforeLoad` and `loader` reflect the real route — not the mask
- The mask URL's params and search are not passed to any hook or loader
- Type safety applies to the real route's param and search shapes

---

### Mask URL Validity

The mask URL does not need to correspond to a registered route. It can be an arbitrary string:

```tsx
<Link
  to="/internal/$id"
  params={{ id: '99' }}
  mask={{ to: '/external-looking-path' }}
>
  ...
</Link>
```

[Inference] If the mask URL does not match any route and the user refreshes, the router will attempt to match `/external-looking-path` and render a not-found state. Mask URLs should correspond to a valid, navigable route to avoid broken refresh behavior.

---

### Route Masking vs Redirects

| Concept | What it does | URL in address bar |
|---|---|---|
| Route masking | Renders real route, shows mask URL | Mask URL |
| Redirect | Navigates to a different route entirely | Destination URL |
| Alias [Unverified] | Multiple URLs render the same route | Real URL |

Masking and redirecting are distinct. A redirect changes both the rendered route and the address bar. A mask changes only the address bar — the rendered route is the real target.

---

### Route Masking and SSR

In SSR environments, the server renders the route corresponding to the URL it receives. If the mask URL is what the user shares or refreshes, the server renders that route — not the masked real route.

[Inference] Consistent SSR behavior requires that the mask URL corresponds to a valid server-renderable route. Modal content served only as a masked overlay may not have an SSR-appropriate render path if the mask URL points to the background page.

---

### Limitations and Considerations

**No native browser support**
Route masking is implemented entirely by TanStack Router's history management. It is not a browser primitive and does not interact with the History API in a standardized way. [Inference — behavior across unusual navigation patterns (session restore, tab duplication) may vary]

**Copy URL shares the mask**
Any mechanism that reads the address bar — copy link, browser share, bookmark — captures the mask URL. This is often the intent but should be considered explicitly.

**Devtools may show the real route**
TanStack Router DevTools reflect the actual matched route tree, not the mask. The address bar and the devtools may display different URLs simultaneously. [Inference — verify in current DevTools version]

---

### Full Example — Photo Gallery Modal

```tsx
// routes/photos/index.tsx
function PhotosComponent() {
  const photos = Route.useLoaderData()

  return (
    <div>
      <PhotoGrid>
        {photos.map((photo) => (
          <Link
            key={photo.id}
            to="/photos/$photoId"
            params={{ photoId: photo.id }}
            mask={{ to: '/photos' }}
          >
            <Thumbnail src={photo.thumb} />
          </Link>
        ))}
      </PhotoGrid>
      <Outlet /> {/* modal renders here when /photos/$photoId is active */}
    </div>
  )
}
```

```tsx
// routes/photos/$photoId.tsx
function PhotoDetailComponent() {
  const { photo } = Route.useLoaderData()
  const router = useRouter()
  const isMasked = !!router.state.maskedLocation

  if (isMasked) {
    return (
      <Modal onClose={() => router.history.back()}>
        <PhotoDetail photo={photo} />
      </Modal>
    )
  }

  return <PhotoFullPage photo={photo} />
}
```

---

**Related Topics:**
- `<Link>` mask option — full prop reference
- `router.navigate` mask option — programmatic masked navigation
- `unmaskOnReload` — preserving real route on page refresh
- Modal route patterns — implementing overlay routes with masking
- `router.state.maskedLocation` — detecting masked navigation in components
- History management — how TanStack Router interacts with the browser History API
- SSR and masked routes — server-side considerations for mask URLs