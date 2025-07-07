# Installation

System Requirements:

-   [Node.js 18.17](https://nodejs.org/) or later.
-   macOS, Windows (including WSL), and Linux are supported.

## [Automatic Installation](https://nextjs.org/docs/getting-started/installation#automatic-installation)

We recommend starting a new Next.js app using [`create-next-app`](https://nextjs.org/docs/app/api-reference/create-next-app), which sets up everything automatically for you. To create a project, run:

```bash
npx create-next-app@latest
```

On installation, you'll see the following prompts:

```bash
What is your project named? my-app
Would you like to use TypeScript? No / Yes
Would you like to use ESLint? No / Yes
Would you like to use Tailwind CSS? No / Yes
Would you like to use `src/` directory? No / Yes
Would you like to use App Router? (recommended) No / Yes
Would you like to customize the default import alias (@/*)? No / Yes
What import alias would you like configured? @/*
```

After the prompts, `create-next-app` will create a folder with your project name and install the required dependencies.

> **Good to know**:
> 
> -   Next.js now ships with [TypeScript](https://nextjs.org/docs/app/building-your-application/configuring/typescript), [ESLint](https://nextjs.org/docs/app/building-your-application/configuring/eslint), and [Tailwind CSS](https://nextjs.org/docs/app/building-your-application/styling/tailwind-css) configuration by default.
> -   You can optionally use a [`src` directory](https://nextjs.org/docs/app/building-your-application/configuring/src-directory) in the root of your project to separate your application's code from configuration files.

## [Manual Installation](https://nextjs.org/docs/getting-started/installation#manual-installation)

To manually create a new Next.js app, install the required packages:

```shell
npm install next@latest react@latest react-dom@latest
```

Open your `package.json` file and add the following `scripts`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  }
}
```

These scripts refer to the different stages of developing an application:

-   `dev`: runs [`next dev`](https://nextjs.org/docs/app/api-reference/next-cli#development) to start Next.js in development mode.
-   `build`: runs [`next build`](https://nextjs.org/docs/app/api-reference/next-cli#build) to build the application for production usage.
-   `start`: runs [`next start`](https://nextjs.org/docs/app/api-reference/next-cli#production) to start a Next.js production server.
-   `lint`: runs [`next lint`](https://nextjs.org/docs/app/api-reference/next-cli#lint) to set up Next.js' built-in ESLint configuration.

### [Creating directories](https://nextjs.org/docs/getting-started/installation#creating-directories)

Next.js uses file-system routing, which means the routes in your application are determined by how you structure your files.

#### [The `app` directory](https://nextjs.org/docs/getting-started/installation#the-app-directory)

For new applications, we recommend using the [App Router](https://nextjs.org/docs/app). This router allows you to use React's latest features and is an evolution of the [Pages Router](https://nextjs.org/docs/pages) based on community feedback.

Create an `app/` folder, then add a `layout.tsx` and `page.tsx` file. These will be rendered when the user visits the root of your application (`/`).

![App Folder Structure](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fapp-getting-started.png&w=3840&q=75&dpl=dpl_Fr1VCq6W9RFeEuXYFe2L4sUmaW7a)

Create a [root layout](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#root-layout-required) inside `app/layout.tsx` with the required `<html>` and `<body>` tags:

```typescript
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
```

Finally, create a home page `app/page.tsx` with some initial content:

```typescript
export default function Page() {
  return <h1>Hello, Next.js!</h1>
}
```

> **Good to know**: If you forget to create `layout.tsx`, Next.js will automatically create this file when running the development server with `next dev`.

#### [The `public` folder (optional)](https://nextjs.org/docs/getting-started/installation#the-public-folder-optional)

Create a `public` folder to store static assets such as images, fonts, etc. Files inside `public` directory can then be referenced by your code starting from the base URL (`/`).

## [Run the Development Server](https://nextjs.org/docs/getting-started/installation#run-the-development-server)

1.  Run `npm run dev` to start the development server.
2.  Visit `http://localhost:3000` to view your application.
3.  Edit `app/page.tsx` (or `pages/index.tsx`) file and save it to see the updated result in your browser.

# Next.js Project Structure

## [Top-level folders](https://nextjs.org/docs/getting-started/project-structure#top-level-folders)

|||
|---|---|
|[`app`](https://nextjs.org/docs/app/building-your-application/routing)|App Router|
|[`pages`](https://nextjs.org/docs/pages/building-your-application/routing)|Pages Router|
|[`public`](https://nextjs.org/docs/app/building-your-application/optimizing/static-assets)|Static assets to be served|
|[`src`](https://nextjs.org/docs/app/building-your-application/configuring/src-directory)|Optional application source folder|

## [Top-level files](https://nextjs.org/docs/getting-started/project-structure#top-level-files)

|||
|---|---|
|**Next.js**||
|[`next.config.js`](https://nextjs.org/docs/app/api-reference/next-config-js)|Configuration file for Next.js|
|[`package.json`](https://nextjs.org/docs/getting-started/installation#manual-installation)|Project dependencies and scripts|
|[`instrumentation.ts`](https://nextjs.org/docs/app/building-your-application/optimizing/instrumentation)|OpenTelemetry and Instrumentation file|
|[`middleware.ts`](https://nextjs.org/docs/app/building-your-application/routing/middleware)|Next.js request middleware|
|[`.env`](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables)|Environment variables|
|[`.env.local`](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables)|Local environment variables|
|[`.env.production`](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables)|Production environment variables|
|[`.env.development`](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables)|Development environment variables|
|[`.eslintrc.json`](https://nextjs.org/docs/app/building-your-application/configuring/eslint)|Configuration file for ESLint|
|`.gitignore`|Git files and folders to ignore|
|`next-env.d.ts`|TypeScript declaration file for Next.js|
|`tsconfig.json`|Configuration file for TypeScript|
|`jsconfig.json`|Configuration file for JavaScript|

## [`app` Routing Conventions](https://nextjs.org/docs/getting-started/project-structure#app-routing-conventions)

### [Routing Files](https://nextjs.org/docs/getting-started/project-structure#routing-files)

||||
|---|---|---|
|[`layout`](https://nextjs.org/docs/app/api-reference/file-conventions/layout)|`.js` `.jsx` `.tsx`|Layout|
|[`page`](https://nextjs.org/docs/app/api-reference/file-conventions/page)|`.js` `.jsx` `.tsx`|Page|
|[`loading`](https://nextjs.org/docs/app/api-reference/file-conventions/loading)|`.js` `.jsx` `.tsx`|Loading UI|
|[`not-found`](https://nextjs.org/docs/app/api-reference/file-conventions/not-found)|`.js` `.jsx` `.tsx`|Not found UI|
|[`error`](https://nextjs.org/docs/app/api-reference/file-conventions/error)|`.js` `.jsx` `.tsx`|Error UI|
|[`global-error`](https://nextjs.org/docs/app/api-reference/file-conventions/error#global-errorjs)|`.js` `.jsx` `.tsx`|Global error UI|
|[`route`](https://nextjs.org/docs/app/api-reference/file-conventions/route)|`.js` `.ts`|API endpoint|
|[`template`](https://nextjs.org/docs/app/api-reference/file-conventions/template)|`.js` `.jsx` `.tsx`|Re-rendered layout|
|[`default`](https://nextjs.org/docs/app/api-reference/file-conventions/default)|`.js` `.jsx` `.tsx`|Parallel route fallback page|

### [Nested Routes](https://nextjs.org/docs/getting-started/project-structure#nested-routes)

|||
|---|---|
|[`folder`](https://nextjs.org/docs/app/building-your-application/routing#route-segments)|Route segment|
|[`folder/folder`](https://nextjs.org/docs/app/building-your-application/routing#nested-routes)|Nested route segment|

### [Dynamic Routes](https://nextjs.org/docs/getting-started/project-structure#dynamic-routes)

|||
|---|---|
|[`[folder]`](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes#convention)|Dynamic route segment|
|[`[...folder]`](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes#catch-all-segments)|Catch-all route segment|
|[`[[...folder]]`](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes#optional-catch-all-segments)|Optional catch-all route segment|

### [Route Groups and Private Folders](https://nextjs.org/docs/getting-started/project-structure#route-groups-and-private-folders)

|||
|---|---|
|[`(folder)`](https://nextjs.org/docs/app/building-your-application/routing/route-groups#convention)|Group routes without affecting routing|
|[`_folder`](https://nextjs.org/docs/app/building-your-application/routing/colocation#private-folders)|Opt folder and all child segments out of routing|

### [Parallel and Intercepted Routes](https://nextjs.org/docs/getting-started/project-structure#parallel-and-intercepted-routes)

|||
|---|---|
|[`@folder`](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes#slots)|Named slot|
|[`(.)folder`](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes#convention)|Intercept same level|
|[`(..)folder`](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes#convention)|Intercept one level above|
|[`(..)(..)folder`](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes#convention)|Intercept two levels above|
|[`(...)folder`](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes#convention)|Intercept from root|

### [Metadata File Conventions](https://nextjs.org/docs/getting-started/project-structure#metadata-file-conventions)

#### [App Icons](https://nextjs.org/docs/getting-started/project-structure#app-icons)

||||
|---|---|---|
|[`favicon`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons#favicon)|`.ico`|Favicon file|
|[`icon`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons#icon)|`.ico` `.jpg` `.jpeg` `.png` `.svg`|App Icon file|
|[`icon`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons#generate-icons-using-code-js-ts-tsx)|`.js` `.ts` `.tsx`|Generated App Icon|
|[`apple-icon`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons#apple-icon)|`.jpg` `.jpeg`, `.png`|Apple App Icon file|
|[`apple-icon`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons#generate-icons-using-code-js-ts-tsx)|`.js` `.ts` `.tsx`|Generated Apple App Icon|

#### [Open Graph and Twitter Images](https://nextjs.org/docs/getting-started/project-structure#open-graph-and-twitter-images)

||||
|---|---|---|
|[`opengraph-image`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image#opengraph-image)|`.jpg` `.jpeg` `.png` `.gif`|Open Graph image file|
|[`opengraph-image`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image#generate-images-using-code-js-ts-tsx)|`.js` `.ts` `.tsx`|Generated Open Graph image|
|[`twitter-image`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image#twitter-image)|`.jpg` `.jpeg` `.png` `.gif`|Twitter image file|
|[`twitter-image`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image#generate-images-using-code-js-ts-tsx)|`.js` `.ts` `.tsx`|Generated Twitter image|

#### [SEO](https://nextjs.org/docs/getting-started/project-structure#seo)

||||
|---|---|---|
|[`sitemap`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap#sitemap-files-xml)|`.xml`|Sitemap file|
|[`sitemap`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap#generating-a-sitemap-using-code-js-ts)|`.js` `.ts`|Generated Sitemap|
|[`robots`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots#static-robotstxt)|`.txt`|Robots file|
|[`robots`](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/robots#generate-a-robots-file)|`.js` `.ts`|Generated Robots file|

## [`pages` Routing Conventions](https://nextjs.org/docs/getting-started/project-structure#pages-routing-conventions)

### [Special Files](https://nextjs.org/docs/getting-started/project-structure#special-files)

||||
|---|---|---|
|[`_app`](https://nextjs.org/docs/pages/building-your-application/routing/custom-app)|`.js` `.jsx` `.tsx`|Custom App|
|[`_document`](https://nextjs.org/docs/pages/building-your-application/routing/custom-document)|`.js` `.jsx` `.tsx`|Custom Document|
|[`_error`](https://nextjs.org/docs/pages/building-your-application/routing/custom-error#more-advanced-error-page-customizing)|`.js` `.jsx` `.tsx`|Custom Error Page|
|[`404`](https://nextjs.org/docs/pages/building-your-application/routing/custom-error#404-page)|`.js` `.jsx` `.tsx`|404 Error Page|
|[`500`](https://nextjs.org/docs/pages/building-your-application/routing/custom-error#500-page)|`.js` `.jsx` `.tsx`|500 Error Page|

### [Routes](https://nextjs.org/docs/getting-started/project-structure#routes)

||||
|---|---|---|
|**Folder convention**|||
|[`index`](https://nextjs.org/docs/pages/building-your-application/routing/pages-and-layouts#index-routes)|`.js` `.jsx` `.tsx`|Home page|
|[`folder/index`](https://nextjs.org/docs/pages/building-your-application/routing/pages-and-layouts#index-routes)|`.js` `.jsx` `.tsx`|Nested page|
|**File convention**|||
|[`index`](https://nextjs.org/docs/pages/building-your-application/routing/pages-and-layouts#index-routes)|`.js` `.jsx` `.tsx`|Home page|
|[`file`](https://nextjs.org/docs/pages/building-your-application/routing/pages-and-layouts)|`.js` `.jsx` `.tsx`|Nested page|

### [Dynamic Routes](https://nextjs.org/docs/getting-started/project-structure#dynamic-routes-1)

||||
|---|---|---|
|**Folder convention**|||
|[`[folder]/index`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes)|`.js` `.jsx` `.tsx`|Dynamic route segment|
|[`[...folder]/index`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes#catch-all-segments)|`.js` `.jsx` `.tsx`|Catch-all route segment|
|[`[[...folder]]/index`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes#optional-catch-all-segments)|`.js` `.jsx` `.tsx`|Optional catch-all route segment|
|**File convention**|||
|[`[file]`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes)|`.js` `.jsx` `.tsx`|Dynamic route segment|
|[`[...file]`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes#catch-all-segments)|`.js` `.jsx` `.tsx`|Catch-all route segment|
|[`[[...file]]`](https://nextjs.org/docs/pages/building-your-application/routing/dynamic-routes#optional-catch-all-segments)|`.js` `.jsx` `.tsx`|Optional catch-all route segment|


# Routing

![Terminology for Component Tree](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fterminology-component-tree.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)

- **Tree:** A convention for visualizing a hierarchical structure. For example, a component tree with parent and children components, a folder structure, etc.
- **Subtree:** Part of a tree, starting at a new root (first) and ending at the leaves (last).
- **Root**: The first node in a tree or subtree, such as a root layout.
- **Leaf:** Nodes in a subtree that have no children, such as the last segment in a URL path.

![Terminology for URL Anatomy](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fterminology-url-anatomy.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)

- **URL Segment:** Part of the URL path delimited by slashes.
- **URL Path:** Part of the URL that comes after the domain (composed of segments).

## [The `app` Router](https://nextjs.org/docs/app/building-your-application/routing#the-app-router)

In version 13, Next.js introduced a new **App Router** built on [React Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components), which supports shared layouts, nested routing, loading states, error handling, and more.

The `app` directory works alongside the `pages` directory to allow for incremental adoption. This allows you to opt some routes of your application into the new behavior while keeping other routes in the `pages` directory for previous behavior.

> **Good to know**: The App Router takes priority over the Pages Router. Routes across directories should not resolve to the same URL path and will cause a build-time error to prevent a conflict.

![Next.js App Directory](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fnext-router-directories.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)

By default, components inside `app` are [React Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components). This is a performance optimization and allows you to easily adopt them, and you can also use [Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components).

## [Roles of Folders and Files](https://nextjs.org/docs/app/building-your-application/routing#roles-of-folders-and-files)

Next.js uses a file-system based router where:

- **Folders** are used to define routes. A route is a single path of nested folders, following the file-system hierarchy from the **root folder** down to a final **leaf folder** that includes a `page.js` file.
- **Files** are used to create UI that is shown for a route segment.


## [Route Segments](https://nextjs.org/docs/app/building-your-application/routing#route-segments)

Each folder in a route represents a **route segment**. Each route segment is mapped to a corresponding **segment** in a **URL path**.

![How Route Segments Map to URL Segments](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Froute-segments-to-path-segments.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)


## [Nested Routes](https://nextjs.org/docs/app/building-your-application/routing#nested-routes)

To create a nested route, you can nest folders inside each other. For example, you can add a new `/dashboard/settings` route by nesting two new folders in the `app` directory.

The `/dashboard/settings` route is composed of three segments:

- `/` (Root segment)
- `dashboard` (Segment)
- `settings` (Leaf segment)


## [File Conventions](https://nextjs.org/docs/app/building-your-application/routing#file-conventions)

Next.js provides a set of special files to create UI with specific behavior in nested routes:

|||
|---|---|
|[`layout`](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#layouts)|Shared UI for a segment and its children|
|[`page`](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#pages)|Unique UI of a route and make routes publicly accessible|
|[`loading`](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)|Loading UI for a segment and its children|
|[`not-found`](https://nextjs.org/docs/app/api-reference/file-conventions/not-found)|Not found UI for a segment and its children|
|[`error`](https://nextjs.org/docs/app/building-your-application/routing/error-handling)|Error UI for a segment and its children|
|[`global-error`](https://nextjs.org/docs/app/building-your-application/routing/error-handling)|Global Error UI|
|[`route`](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)|Server-side API endpoint|
|[`template`](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#templates)|Specialized re-rendered Layout UI|
|[`default`](https://nextjs.org/docs/app/api-reference/file-conventions/default)|Fallback UI for [Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)|

> **Good to know**: `.js`, `.jsx`, or `.tsx` file extensions can be used for special files.


## [Component Hierarchy](https://nextjs.org/docs/app/building-your-application/routing#component-hierarchy)

The React components defined in special files of a route segment are rendered in a specific hierarchy:

- `layout.js`
- `template.js`
- `error.js` (React error boundary)
- `loading.js` (React suspense boundary)
- `not-found.js` (React error boundary)
- `page.js` or nested `layout.js`

![Component Hierarchy for File Conventions](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Ffile-conventions-component-hierarchy.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)

In a nested route, the components of a segment will be nested **inside** the components of its parent segment.

![Nested File Conventions Component Hierarchy](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fnested-file-conventions-component-hierarchy.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)

## [Colocation](https://nextjs.org/docs/app/building-your-application/routing#colocation)

In addition to special files, you have the option to colocate your own files (e.g. components, styles, tests, etc) inside folders in the `app` directory.

This is because while folders define routes, only the contents returned by `page.js` or `route.js` are publicly addressable.

![An example folder structure with colocated files](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fproject-organization-colocation.png&w=3840&q=75&dpl=dpl_CuBnjibf5UovqmTZDknHLTGZcmYF)


## [Advanced Routing Patterns](https://nextjs.org/docs/app/building-your-application/routing#advanced-routing-patterns)

The App Router also provides a set of conventions to help you implement more advanced routing patterns. These include:

- [Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes): Allow you to simultaneously show two or more pages in the same view that can be navigated independently. You can use them for split views that have their own sub-navigation. E.g. Dashboards.
- [Intercepting Routes](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes): Allow you to intercept a route and show it in the context of another route. You can use these when keeping the context for the current page is important. E.g. Seeing all tasks while editing one task or expanding a photo in a feed.

These patterns allow you to build richer and more complex UIs, democratizing features that were historically complex for small teams and individual developers to implement.


# Defining Routes

## [Creating Routes](https://nextjs.org/docs/app/building-your-application/routing/defining-routes#creating-routes)

Next.js uses a file-system based router where **folders** are used to define routes.

Each folder represents a [**route** segment](https://nextjs.org/docs/app/building-your-application/routing#route-segments) that maps to a **URL** segment. To create a [nested route](https://nextjs.org/docs/app/building-your-application/routing#nested-routes), you can nest folders inside each other.

![Route segments to path segments](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Froute-segments-to-path-segments.png&w=3840&q=75&dpl=dpl_FPjuNCteF3SYqkbw9hUPFFWncHVa)

A special [`page.js` file](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#pages) is used to make route segments publicly accessible.

![Defining Routes](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fdefining-routes.png&w=3840&q=75&dpl=dpl_FPjuNCteF3SYqkbw9hUPFFWncHVa)

In this example, the `/dashboard/analytics` URL path is _not_ publicly accessible because it does not have a corresponding `page.js` file. This folder could be used to store components, stylesheets, images, or other colocated files.


# Pages and Layouts

## [Pages](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#pages)

A page is UI that is **unique** to a route. You can define pages by exporting a component from a `page.js` file. Use nested folders to [define a route](https://nextjs.org/docs/app/building-your-application/routing/defining-routes) and a `page.js` file to make the route publicly accessible.

Create your first page by adding a `page.js` file inside the `app` directory:

![page.js special file](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fpage-special-file.png&w=3840&q=75&dpl=dpl_FPjuNCteF3SYqkbw9hUPFFWncHVa)

app/page.tsx

```typescript
// `app/page.tsx` is the UI for the `/` URL
export default function Page() {
  return <h1>Hello, Home page!</h1>
}
```

app/dashboard/page.tsx

```typescript
// `app/dashboard/page.tsx` is the UI for the `/dashboard` URL
export default function Page() {
  return <h1>Hello, Dashboard Page!</h1>
}
```

> **Good to know**:
> - A page is always the [leaf](https://nextjs.org/docs/app/building-your-application/routing#terminology) of the [route subtree](https://nextjs.org/docs/app/building-your-application/routing#terminology).
> - `.js`, `.jsx`, or `.tsx` file extensions can be used for Pages.
> - A `page.js` file is required to make a route segment publicly accessible.
> - Pages are [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components) by default but can be set to a [Client Component](https://nextjs.org/docs/app/building-your-application/rendering/client-components).
> - Pages can fetch data.


## [Layouts](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#layouts)

A layout is UI that is **shared** between multiple pages. On navigation, layouts preserve state, remain interactive, and do not re-render. Layouts can also be [nested](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#nesting-layouts).

You can define a layout by `default` exporting a React component from a `layout.js` file. The component should accept a `children` prop that will be populated with a child layout (if it exists) or a child page during rendering.

![layout.js special file](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Flayout-special-file.png&w=3840&q=75&dpl=dpl_FPjuNCteF3SYqkbw9hUPFFWncHVa)

app/dashboard/layout.tsx

```typescript
export default function DashboardLayout({
  children, // will be a page or nested layout
}: {
  children: React.ReactNode
}) {
  return (
    <section>
      {/* Include shared UI here e.g. a header or sidebar */}
      <nav></nav>
 
      {children}
    </section>
  )
}
```

> **Good to know**:
> 
> - The top-most layout is called the [Root Layout](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#root-layout-required). This **required** layout is shared across all pages in an application. Root layouts must contain `html` and `body` tags.
> - Any route segment can optionally define its own [Layout](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#nesting-layouts). These layouts will be shared across all pages in that segment.
> - Layouts in a route are **nested** by default. Each parent layout wraps child layouts below it using the React `children` prop.
> - You can use [Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups) to opt specific route segments in and out of shared layouts.
> - Layouts are [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components) by default but can be set to a [Client Component](https://nextjs.org/docs/app/building-your-application/rendering/client-components).
> - Layouts can fetch data.
> - Passing data between a parent layout and its children is not possible. However, you can fetch the same data in a route more than once, and React will [automatically dedupe the requests](https://nextjs.org/docs/app/building-your-application/caching#request-memoization) without affecting performance.
> - Layouts do not have access to the route segments below itself. To access all route segments, you can use [`useSelectedLayoutSegment`](https://nextjs.org/docs/app/api-reference/functions/use-selected-layout-segment) or [`useSelectedLayoutSegments`](https://nextjs.org/docs/app/api-reference/functions/use-selected-layout-segments) in a Client Component.
> - `.js`, `.jsx`, or `.tsx` file extensions can be used for Layouts.
> - A `layout.js` and `page.js` file can be defined in the same folder. The layout will wrap the page.


### [Root Layout (Required)](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#root-layout-required)

The root layout is defined at the top level of the `app` directory and applies to all routes. This layout enables you to modify the initial HTML returned from the server.

app/layout.tsx

```typescript
export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
```

> **Good to know**:
> 
> - The `app` directory **must** include a root layout.
> - The root layout must define `<html>` and `<body>` tags since Next.js does not automatically create them.
> - You can use the [built-in SEO support](https://nextjs.org/docs/app/building-your-application/optimizing/metadata) to manage `<head>` HTML elements, for example, the `<title>` element.
> - You can use [route groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups) to create multiple root layouts. See an [example here](https://nextjs.org/docs/app/building-your-application/routing/route-groups#creating-multiple-root-layouts).


### [Nesting Layouts](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#nesting-layouts)

Layouts defined inside a folder (e.g. `app/dashboard/layout.js`) apply to specific route segments (e.g. `acme.com/dashboard`) and render when those segments are active. By default, layouts in the file hierarchy are **nested**, which means they wrap child layouts via their `children` prop.

![Nested Layout](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fnested-layout.png&w=3840&q=75&dpl=dpl_Fr1VCq6W9RFeEuXYFe2L4sUmaW7a)

app/dashboard/layout.tsx

```typescript
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <section>{children}</section>
}
```

> **Good to know**:
> 
> - Only the root layout can contain `<html>` and `<body>` tags.

If you were to combine the two layouts above, the root layout (`app/layout.js`) would wrap the dashboard layout (`app/dashboard/layout.js`), which would wrap route segments inside `app/dashboard/*`.

The two layouts would be nested as such:

![Nested Layouts](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Fnested-layouts-ui.png&w=3840&q=75&dpl=dpl_Fr1VCq6W9RFeEuXYFe2L4sUmaW7a)

You can use [Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups) to opt specific route segments in and out of shared layouts.


## [Templates](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#templates)

Templates are similar to layouts in that they wrap each child layout or page. Unlike layouts that persist across routes and maintain state, templates create a new instance for each of their children on navigation. This means that when a user navigates between routes that share a template, a new instance of the component is mounted, DOM elements are recreated, state is **not** preserved, and effects are re-synchronized.

There may be cases where you need those specific behaviors, and templates would be a more suitable option than layouts. For example:

- Features that rely on `useEffect` (e.g logging page views) and `useState` (e.g a per-page feedback form).
- To change the default framework behavior. For example, Suspense Boundaries inside layouts only show the fallback the first time the Layout is loaded and not when switching pages. For templates, the fallback is shown on each navigation.

A template can be defined by exporting a default React component from a `template.js` file. The component should accept a `children` prop.

![template.js special file](https://nextjs.org/_next/image?url=%2Fdocs%2Fdark%2Ftemplate-special-file.png&w=3840&q=75&dpl=dpl_Fr1VCq6W9RFeEuXYFe2L4sUmaW7a)

app/template.tsx

```typescript
export default function Template({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>
}
```

In terms of nesting, `template.js` is rendered between a layout and its children. Here's a simplified output:

Output

```jsx
<Layout>
  {/* Note that the template is given a unique key. */}
  <Template key={routeParam}>{children}</Template>
</Layout>
```

## [Modifying `<head>`](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#modifying-head)

In the `app` directory, you can modify the `<head>` HTML elements such as `title` and `meta` using the [built-in SEO support](https://nextjs.org/docs/app/building-your-application/optimizing/metadata).

Metadata can be defined by exporting a [`metadata` object](https://nextjs.org/docs/app/api-reference/functions/generate-metadata#the-metadata-object) or [`generateMetadata` function](https://nextjs.org/docs/app/api-reference/functions/generate-metadata#generatemetadata-function) in a [`layout.js`](https://nextjs.org/docs/app/api-reference/file-conventions/layout) or [`page.js`](https://nextjs.org/docs/app/api-reference/file-conventions/page) file.

app/page.tsx

```typescript
import { Metadata } from 'next'
 
export const metadata: Metadata = {
  title: 'Next.js',
}
 
export default function Page() {
  return '...'
}
```

> **Good to know**: You should **not** manually add `<head>` tags such as `<title>` and `<meta>` to root layouts. Instead, you should use the [Metadata API](https://nextjs.org/docs/app/api-reference/functions/generate-metadata) which automatically handles advanced requirements such as streaming and de-duplicating `<head>` elements.


# Linking and Navigating

There are four ways to navigate between routes in Next.js:

- Using the [`<Link>` Component](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#link-component)
- Using the [`useRouter` hook](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#userouter-hook) ([Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components))
- Using the [`redirect` function](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#redirect-function) ([Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components))
- Using the native [History API](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#using-the-native-history-api)


## [`<Link>` Component](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#link-component)

`<Link>` is a built-in component that extends the HTML `<a>` tag to provide [prefetching](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#2-prefetching) and client-side navigation between routes. It is the primary and recommended way to navigate between routes in Next.js.

You can use it by importing it from `next/link`, and passing a `href` prop to the component:

```typescript
import Link from 'next/link'
 
export default function Page() {
  return <Link href="/dashboard">Dashboard</Link>
}
```

There are other optional props you can pass to `<Link>`.

### [Examples](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#examples)

#### [Linking to Dynamic Segments](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#linking-to-dynamic-segments)

When linking to [dynamic segments](https://nextjs.org/docs/app/building-your-application/routing/dynamic-routes), you can use [template literals and interpolation](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Template_literals) to generate a list of links. For example, to generate a list of blog posts:

```typescript
import Link from 'next/link'
 
export default function PostList({ posts }) {
  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>
          <Link href={`/blog/${post.slug}`}>{post.title}</Link>
        </li>
      ))}
    </ul>
  )
}
```

#### [Checking Active Links](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#checking-active-links)

You can use [`usePathname()`](https://nextjs.org/docs/app/api-reference/functions/use-pathname) to determine if a link is active. For example, to add a class to the active link, you can check if the current `pathname` matches the `href` of the link:

app/components/links.tsx

```typescript
'use client'
 
import { usePathname } from 'next/navigation'
import Link from 'next/link'
 
export function Links() {
  const pathname = usePathname()
 
  return (
    <nav>
      <ul>
        <li>
          <Link className={`link ${pathname === '/' ? 'active' : ''}`} href="/">
            Home
          </Link>
        </li>
        <li>
          <Link
            className={`link ${pathname === '/about' ? 'active' : ''}`}
            href="/about"
          >
            About
          </Link>
        </li>
      </ul>
    </nav>
  )
}
```

#### [Scrolling to an `id`](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#scrolling-to-an-id)

The default behavior of the Next.js App Router is to scroll to the top of a new route or to maintain the scroll position for backwards and forwards navigation.

If you'd like to scroll to a specific `id` on navigation, you can append your URL with a `#` hash link or just pass a hash link to the `href` prop. This is possible since `<Link>` renders to an `<a>` element.

```jsx
<Link href="/dashboard#settings">Settings</Link>
 
// Output
<a href="/dashboard#settings">Settings</a>
```
#### [Disabling scroll restoration](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#disabling-scroll-restoration)

The default behavior of the Next.js App Router is to scroll to the top of a new route or to maintain the scroll position for backwards and forwards navigation. If you'd like to disable this behavior, you can pass `scroll={false}` to the `<Link>` component, or `scroll: false` to `router.push()` or `router.replace()`.

```jsx
// next/link
<Link href="/dashboard" scroll={false}>
  Dashboard
</Link>
```

```typescript
// useRouter
import { useRouter } from 'next/navigation'
 
const router = useRouter()
 
router.push('/dashboard', { scroll: false })
```

## [`useRouter()` hook](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#userouter-hook)

The `useRouter` hook allows you to programmatically change routes from [Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components).

```typescript
'use client'
 
import { useRouter } from 'next/navigation'
 
export default function Page() {
  const router = useRouter()
 
  return (
    <button type="button" onClick={() => router.push('/dashboard')}>
      Dashboard
    </button>
  )
}
```

> **Recommendation:** Use the `<Link>` component to navigate between routes unless you have a specific requirement for using `useRouter`.


## [`redirect` function](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#redirect-function)

For [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components), use the `redirect` function instead.

app/team/[id]/page.tsx

```typescript
import { redirect } from 'next/navigation'
 
async function fetchTeam(id: string) {
  const res = await fetch('https://...')
  if (!res.ok) return undefined
  return res.json()
}
 
export default async function Profile({ params }: { params: { id: string } }) {
  const team = await fetchTeam(params.id)
  if (!team) {
    redirect('/login')
  }
 
  // ...
}
```

> **Good to know**:
> 
> - `redirect` returns a 307 (Temporary Redirect) status code by default. When used in a Server Action, it returns a 303 (See Other), which is commonly used for redirecting to a success page as a result of a POST request.
> - `redirect` internally throws an error so it should be called outside of `try/catch` blocks.
> - `redirect` can be called in Client Components during the rendering process but not in event handlers. You can use the [`useRouter` hook](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#userouter-hook) instead.
> - `redirect` also accepts absolute URLs and can be used to redirect to external links.
> - If you'd like to redirect before the render process, use [`next.config.js`](https://nextjs.org/docs/app/building-your-application/routing/redirecting#redirects-in-nextconfigjs) or [Middleware](https://nextjs.org/docs/app/building-your-application/routing/redirecting#nextresponseredirect-in-middleware).

## [Using the native History API](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#using-the-native-history-api)

Next.js allows you to use the native [`window.history.pushState`](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState) and [`window.history.replaceState`](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState) methods to update the browser's history stack without reloading the page.

#### windows.history.pushState
##### [Syntax](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState#syntax)

```js
pushState(state, unused)
pushState(state, unused, url)
```

##### [Parameters](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState#parameters)

[`state`](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState#state)

The `state` object is a JavaScript object which is associated with the new history entry created by `pushState()`. Whenever the user navigates to the new `state`, a [`popstate`](https://developer.mozilla.org/en-US/docs/Web/API/Window/popstate_event "popstate") event is fired, and the `state` property of the event contains a copy of the history entry's `state` object.

The `state` object can be anything that can be serialized.

**Note:** Some browsers save `state` objects to the user's disk so they can be restored after the user restarts the browser, and impose a size limit on the serialized representation of a `state` object, and will throw an exception if you pass a `state` object whose serialized representation is larger than that size limit. So in cases where you want to ensure you have more space than what some browsers might impose, you're encouraged to use [`sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage "sessionStorage") and/or [`localStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage "localStorage").

[`unused`](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState#unused)

This parameter exists for historical reasons, and cannot be omitted; passing an empty string is safe against future changes to the method.

[`url`](https://developer.mozilla.org/en-US/docs/Web/API/History/pushState#url) Optional

The new history entry's URL. Note that the browser won't attempt to load this URL after a call to `pushState()`, but it may attempt to load the URL later, for instance, after the user restarts the browser. The new URL does not need to be absolute; if it's relative, it's resolved relative to the current URL. The new URL must be of the same [origin](https://developer.mozilla.org/en-US/docs/Glossary/Origin) as the current URL; otherwise, `pushState()` will throw an exception. If this parameter isn't specified, it's set to the document's current URL.
#### windows.history.replaceState

The **`replaceState()`** method of the [`History`](https://developer.mozilla.org/en-US/docs/Web/API/History) interface modifies the current history entry, replacing it with the state object and URL passed in the method parameters. This method is particularly useful when you want to update the state object or URL of the current history entry in response to some user action.

##### [Syntax](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState#syntax)

```js
replaceState(state, unused)
replaceState(state, unused, url)
```

##### [Parameters](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState#parameters)

[`state`](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState#state)

An object which is associated with the history entry passed to the `replaceState()` method. The state object can be `null`.

[`unused`](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState#unused)

This parameter exists for historical reasons, and cannot be omitted; passing the empty string is traditional, and safe against future changes to the method.

[`url`](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState#url) Optional

The URL of the history entry. The new URL must be of the same origin as the current URL; otherwise the `replaceState()` method throws an exception.

### [`window.history.pushState`](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#windowhistorypushstate)

Use it to add a new entry to the browser's history stack. The user can navigate back to the previous state. For example, to sort a list of products:

```typescript
'use client'
 
import { useSearchParams } from 'next/navigation'
 
export default function SortProducts() {
  const searchParams = useSearchParams()
 
  function updateSorting(sortOrder: string) {
    const params = new URLSearchParams(searchParams.toString())
    params.set('sort', sortOrder)
    window.history.pushState(null, '', `?${params.toString()}`)
  }
 
  return (
    <>
      <button onClick={() => updateSorting('asc')}>Sort Ascending</button>
      <button onClick={() => updateSorting('desc')}>Sort Descending</button>
    </>
  )
}
```

### [`window.history.replaceState`](https://nextjs.org/docs/app/building-your-application/routing/linking-and-navigating#windowhistoryreplacestate)

Use it to replace the current entry on the browser's history stack. The user is not able to navigate back to the previous state. For example, to switch the application's locale:

```typescript
'use client'
 
import { usePathname } from 'next/navigation'
 
export function LocaleSwitcher() {
  const pathname = usePathname()
 
  function switchLocale(locale: string) {
    // e.g. '/en/about' or '/fr/contact'
    const newPath = `/${locale}${pathname}`
    window.history.replaceState(null, '', newPath)
  }
 
  return (
    <>
      <button onClick={() => switchLocale('en')}>English</button>
      <button onClick={() => switchLocale('fr')}>French</button>
    </>
  )
}
```

