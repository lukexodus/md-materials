# Institutional Design System on shadcn/ui

## A Production-Grade Implementation Handbook

> **Scope:** This handbook is the authoritative internal reference for building, extending, and maintaining a fully branded institutional design system on top of shadcn/ui. It is written for UI/UX designers, frontend developers, full-stack developers, AI coding assistants, and future maintainers. No prior design system experience is assumed.

---

## Table of Contents

1. [First Principles: What a Design System Is](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#1-first-principles)
2. [Overall Architecture](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#2-overall-architecture)
3. [How shadcn/ui Works Internally](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#3-how-shadcnui-works)
4. [Design Token Strategy](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#4-design-token-strategy)
5. [Brand Integration Process](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#5-brand-integration-process)
6. [Repository Structure](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#6-repository-structure)
7. [Documentation Standards](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#7-documentation-standards)
8. [Component Architecture](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#8-component-architecture)
9. [Theming Strategy](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#9-theming-strategy)
10. [Accessibility Requirements](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#10-accessibility-requirements)
11. [AI-Assisted Development](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#11-ai-assisted-development)
12. [Governance](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#12-governance)
13. [Migration Strategy](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#13-migration-strategy)
14. [Scaling Considerations](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#14-scaling-considerations)
15. [Deliverables & Reference](https://claude.ai/chat/1d26ef4b-9347-4b94-bdd8-e3095399d3ca#15-deliverables--reference)

---

## 1. First Principles

### 1.1 What is a Design System?

A design system is a **single source of truth** that contains all the decisions, assets, documentation, and tools required to design and build a product consistently across every surface, team, and point in time. It is not a Figma file. It is not a component library. It is a living agreement between design and engineering.

A design system answers three categories of questions:

|Category|Examples|
|---|---|
|**Visual decisions**|What colors do we use? What typography? What spacing scale?|
|**Behavioral decisions**|How does a modal close? What happens when a form fails validation?|
|**Governance decisions**|Who approves a new component? How is a breaking change communicated?|

Without a design system, these questions are answered **per feature, per developer, per sprint**, producing invisible fragmentation that compounds over time into an unmaintainable product.

### 1.2 Why Organizations Build Design Systems

The business case is not primarily about aesthetics. It is about **leverage**:

- **Consistency at scale.** Without a system, 10 developers produce 10 slightly different button styles. With one, they produce one.
- **Speed.** Teams stop solving the same solved problems repeatedly. A button does not need to be designed again for every new screen.
- **Accessibility by default.** Compliance is built into the component, not retrofitted per feature.
- **Onboarding.** New team members understand standards from documentation rather than oral tradition.
- **Trust.** Users build mental models of how the product behaves. Consistency deepens that trust.
- **Rebranding resilience.** When institutional branding changes, a token-based system means a controlled, scoped change rather than a codebase-wide search-and-replace.

### 1.3 Terminology: Clearing the Confusion

These terms are often used interchangeably in industry. They are not synonyms. Understanding the distinction is essential before building anything.

```
┌──────────────────────────────────────────────────────────────────┐
│  BRAND GUIDELINES                                                │
│  "Here is who we are visually."                                  │
│  Audience: Everyone. Legal, marketing, vendors, developers.     │
│  Contents: Logo rules, color palette, typography, tone of voice │
│  Format: PDF, brand portal                                       │
│  Example: "Primary color is Pantone 286 C (Navy Blue)"          │
├──────────────────────────────────────────────────────────────────┤
│  STYLE GUIDE                                                     │
│  "Here is how we write and present content."                     │
│  Audience: Writers, editors, content designers                  │
│  Contents: Grammar rules, formatting, voice and tone, icon use  │
│  Example: "Use sentence case in UI labels. Never ALL CAPS."      │
├──────────────────────────────────────────────────────────────────┤
│  DESIGN SYSTEM                                                   │
│  "Here is how we design and build the product."                  │
│  Audience: Designers + engineers (primary), all others secondar)│
│  Contents: Tokens, components, patterns, decision frameworks,   │
│            governance, documentation                            │
│  Example: This handbook.                                         │
├──────────────────────────────────────────────────────────────────┤
│  COMPONENT LIBRARY                                               │
│  "Here is the code for the reusable UI building blocks."         │
│  Audience: Developers                                            │
│  Contents: React/Vue/etc. components, hooks, utilities           │
│  Example: The /packages/ui directory in this monorepo.           │
├──────────────────────────────────────────────────────────────────┤
│  UI KIT                                                          │
│  "Here are the design files for the building blocks."            │
│  Audience: Designers                                             │
│  Contents: Figma component library, design tokens in Figma,     │
│            variant definitions                                  │
│  Example: The Figma team library linked in DESIGN.md.            │
└──────────────────────────────────────────────────────────────────┘
```

**The design system is the umbrella. The others are artifacts within it.**

A common institutional mistake is to confuse "we have a brand PDF" with "we have a design system." The brand PDF is input to the design system. It is not the system itself.

### 1.4 Why Design Tokens Exist

Before design tokens were formalized, component styling was hardcoded:

```css
/* ❌ Pre-token approach — fragile */
.button-primary {
  background-color: #1a3a6c;
  color: #ffffff;
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  border-radius: 4px;
}

.alert-info {
  background-color: #1a3a6c; /* same blue — but no shared reference */
  border-left: 3px solid #1a3a6c;
}
```

Problems with this approach:

1. The same color is duplicated in dozens of places with no shared reference.
2. Changing the primary brand color requires finding every hardcoded hex value.
3. There is no semantic distinction between "this is the brand primary" and "this is an informational accent."
4. Dark mode requires duplicating entire stylesheets.
5. Department-specific theming requires forking the entire CSS.

**Design tokens are named, purposeful references to design decisions.** They decouple the _decision_ from its _usage_.

```json
// ✅ Token-based approach
{
  "color-brand-primary": "#1a3a6c",
  "color-brand-primary-hover": "#152f5a"
}
```

```css
/* Usage via CSS custom properties */
.button-primary {
  background-color: var(--color-brand-primary);
}

.alert-info {
  border-left: 3px solid var(--color-brand-primary);
}
```

Now, changing the brand primary color is a **one-line change** in one place.

### 1.5 Why Semantic Tokens Matter

Raw tokens map a name to a value. Semantic tokens map a _purpose_ to a raw token.

```
Raw token:       --color-blue-700: #1a3a6c
Alias token:     --color-brand-primary: var(--color-blue-700)
Semantic token:  --color-interactive-default: var(--color-brand-primary)
```

This three-level indirection is the key architectural insight of a scalable design system.

**Why it matters:**

|Scenario|Without Semantic Tokens|With Semantic Tokens|
|---|---|---|
|Rebrand: primary color changes from navy to teal|Find every `--color-brand-primary` usage across all components|Change one raw token value|
|Dark mode|Duplicate every component's styles with color inversions|Remap semantic tokens to dark-mode raw values in a theme override|
|Department variant|Fork all components, change colors manually|Override alias layer; all components update automatically|
|Informational alerts switch from blue to purple|Find every component using blue for "info" semantics|Change `--color-status-info` to point to purple token|

**Semantic tokens enforce intent.** An engineer cannot accidentally use `--color-status-error` for a success badge because the name prohibits it. The token is self-documenting.

### 1.6 Why a Token-Based Architecture Scales Better Than Direct Component Customization

The alternative to tokens is **CSS class overrides** at the component level:

```tsx
// ❌ Direct class customization — anti-pattern
<Button className="bg-[#1a3a6c] hover:bg-[#152f5a] text-white rounded-sm">
  Submit
</Button>
```

This appears to work. At scale, it creates the following problems:

1. **Refactoring is impossible.** Every override is local to one callsite. Finding every place a color is used requires grep, not a token reference.
2. **Dark mode breaks.** Local overrides do not respond to theme changes.
3. **Inconsistency accumulates.** Different developers write different overrides for the same visual intent.
4. **AI-generated code regresses.** AI assistants without token context will generate hardcoded values, drifting from the system.
5. **Designer-developer sync fails.** Tokens are the shared language. Without them, Figma and code diverge.

Token-based architecture is not over-engineering. It is the **minimum viable structure** for a design system that will survive more than one year and one team.

---

## 2. Overall Architecture

### 2.1 The Layer Model

The design system is organized into six distinct layers. Each layer has a single responsibility and depends only on layers below it.

```
┌─────────────────────────────────────────────────────────┐
│  LAYER 6: Application Layer                             │
│  Feature-specific compositions of components            │
│  Owns: Pages, layouts, route-level patterns             │
├─────────────────────────────────────────────────────────┤
│  LAYER 5: Component Layer                               │
│  Reusable UI components with design system semantics    │
│  Owns: Buttons, forms, cards, navigation, feedback      │
├─────────────────────────────────────────────────────────┤
│  LAYER 4: Theme Layer                                   │
│  CSS variable overrides that configure semantic tokens  │
│  Owns: Light theme, dark theme, department themes       │
├─────────────────────────────────────────────────────────┤
│  LAYER 3: Semantic Token Layer                          │
│  Named purposes mapped to alias tokens                  │
│  Owns: interactive-default, surface-primary, text-muted │
├─────────────────────────────────────────────────────────┤
│  LAYER 2: Alias / Brand Token Layer                     │
│  Brand names mapped to raw palette values               │
│  Owns: color-brand-primary, color-brand-accent          │
├─────────────────────────────────────────────────────────┤
│  LAYER 1: Raw Token Layer                               │
│  Named, scale-based values with no semantic meaning     │
│  Owns: color-blue-700, space-4, radius-md               │
├─────────────────────────────────────────────────────────┤
│  LAYER 0: Brand Guidelines                              │
│  Institutional brand identity (non-code, external input)│
│  Owns: Pantone references, typography rules, logo usage │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Responsibilities of Each Layer

**Layer 0: Brand Guidelines**

This is not a code layer. It is the institutional source of truth produced by marketing, communications, or an external brand agency. It defines visual identity in terms that may not directly map to code (Pantone colors, print typography, logo exclusion zones). The design system team's job is to **translate** brand guidelines into tokens, not copy them verbatim.

**Layer 1: Raw Tokens**

Complete, exhaustive, scale-based palette values. A color raw token layer contains every possible step of every color scale. No value is omitted for being "unused now." The raw layer is agnostic to purpose.

```css
:root {
  --color-blue-50: #eff6ff;
  --color-blue-100: #dbeafe;
  /* ... */
  --color-blue-700: #1a3a6c;
  --color-blue-800: #152f5a;
  --color-blue-900: #0f2347;
}
```

**Layer 2: Alias / Brand Tokens**

Brand names assigned to raw values. This is where the institutional palette is named.

```css
:root {
  --color-brand-primary: var(--color-blue-700);
  --color-brand-primary-dark: var(--color-blue-800);
  --color-brand-secondary: var(--color-gold-500);
}
```

**Layer 3: Semantic Tokens**

Purpose-based names that consume alias tokens. Semantic tokens are the primary layer that components reference.

```css
:root {
  --color-interactive-default: var(--color-brand-primary);
  --color-interactive-hover: var(--color-brand-primary-dark);
  --color-surface-default: var(--color-neutral-0);
  --color-text-primary: var(--color-neutral-900);
  --color-text-muted: var(--color-neutral-500);
  --color-status-error: var(--color-red-600);
  --color-status-success: var(--color-green-600);
}
```

**Layer 4: Theme Layer**

CSS variable overrides scoped to a theme class. A theme does not introduce new tokens — it remaps existing semantic tokens to different raw or alias values.

```css
[data-theme="dark"] {
  --color-interactive-default: var(--color-blue-400);
  --color-surface-default: var(--color-neutral-900);
  --color-text-primary: var(--color-neutral-50);
}

[data-theme="engineering-dept"] {
  --color-brand-primary: var(--color-red-700);
  --color-brand-secondary: var(--color-orange-500);
}
```

**Layer 5: Component Layer**

UI components that consume semantic tokens only. A component **must never** reference raw or alias tokens directly.

```tsx
// ✅ Correct — semantic token reference
<button className="bg-interactive-default hover:bg-interactive-hover text-interactive-text">

// ❌ Incorrect — alias token reference
<button className="bg-brand-primary hover:bg-brand-primary-dark">

// ❌ Incorrect — raw token reference
<button className="bg-blue-700 hover:bg-blue-800">
```

This constraint is the enforcement mechanism for the entire architecture. If a component references semantic tokens only, it is automatically correct across all themes.

**Layer 6: Application Layer**

Page-level compositions that assemble components into user-facing features. The application layer does not define new tokens. It may compose, configure, and arrange components. It may define layout-level spacing using spacing tokens.

### 2.3 How Changes Flow Through the System

```
Change type: Institution rebrands primary color from navy to teal

Layer 0  →  Brand guidelines updated (external)
Layer 1  →  color-teal-700 added to raw palette (additive, no break)
Layer 2  →  color-brand-primary: var(--color-teal-700)  ← ONE CHANGE
Layer 3  →  No change (semantic tokens still reference alias tokens)
Layer 4  →  No change (themes still reference semantic tokens)
Layer 5  →  No change (components still reference semantic tokens)
Layer 6  →  No change

Result: Every component in the system updates from navy to teal.
Effort: One line of CSS.
```

```
Change type: New department theme required

Layer 0  →  Department brand guidelines provided
Layer 1  →  Raw tokens may be augmented if new colors needed
Layer 2  →  New alias tokens added for department palette
Layer 3  →  No change
Layer 4  →  New [data-theme="dept-name"] block added  ← ADDITIVE
Layer 5  →  No change
Layer 6  →  No change (or minimal: wrapping with theme provider)

Result: Department theme works across all components without touching any component code.
```

---

## 3. How shadcn/ui Works Internally

### 3.1 Philosophy

shadcn/ui is not a component library in the traditional sense. It is better understood as a **component distribution mechanism** — a CLI tool that copies battle-tested, accessible, Tailwind-styled React component source code directly into your project.

The philosophical distinction is critical:

|Traditional UI Library (e.g., MUI, Chakra)|shadcn/ui|
|---|---|
|Installed as a `node_modules` dependency|Source code copied into your project|
|Updated via `npm update`|Updated manually or via CLI re-copy|
|Customized through theme config or prop APIs|Customized by directly editing the source|
|Abstraction hides internals|No abstraction — you own every line|
|Breaking changes managed by library|Breaking changes are your responsibility|
|Bundle includes everything (tree-shaking varies)|Only copied components are included|

The shadcn/ui philosophy is: **"It is better to own 200 lines of readable code than to depend on a black box."**

### 3.2 Why Components Are Copied Into the Project

When you run `npx shadcn@latest add button`, it:

1. Downloads the Button component source from the shadcn/ui registry
2. Writes it to your configured component path (e.g., `src/components/ui/button.tsx`)
3. Installs any required dependencies (e.g., `@radix-ui/react-slot`, `class-variance-authority`)
4. Leaves you with **full ownership** of the file

This is an intentional design choice with significant implications:

**You can do anything to the component.** There is no override API to fight. No `sx` prop gymnastics. No `styled` wrapper with specificity battles. You edit the file directly.

**You are responsible for the component.** When shadcn/ui publishes an updated version of a component (e.g., improved accessibility, new variant), you do not automatically receive it. You must consciously re-copy or manually merge the changes.

**For a design system, this is the correct model.** The institutional design system team should own the component definitions. The team should not be blocked on an upstream library's release cycle to fix an accessibility issue or add an institution-specific variant.

### 3.3 Tailwind Integration

shadcn/ui is built on Tailwind CSS. Every component is styled using Tailwind utility classes rather than custom CSS. This has three consequences:

**1. The component's visual output is entirely determined by your Tailwind configuration.** If you change `tailwind.config.ts` to map `bg-primary` to a different value, every component using `bg-primary` changes automatically.

**2. Class Variance Authority (CVA) is the variant system.** shadcn/ui uses the `cva` function to define component variants (size, intent, state) as named Tailwind class combinations:

```tsx
import { cva } from 'class-variance-authority'

const buttonVariants = cva(
  // Base classes applied to all variants
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent",
        ghost: "hover:bg-accent hover:text-accent-foreground",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)
```

**3. The `cn()` utility is critical infrastructure.** The `cn` function (a wrapper around `clsx` and `tailwind-merge`) is used throughout all components to merge class names safely without Tailwind conflicts:

```tsx
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### 3.4 CSS Variable Architecture in shadcn/ui

shadcn/ui uses a CSS custom property system mapped to Tailwind via the `@theme` directive (Tailwind v4) or `theme.extend` (Tailwind v3). The default variable naming convention is:

```css
/* globals.css — default shadcn/ui variable definitions */
:root {
  --background: 0 0% 100%;       /* HSL, no hsl() wrapper */
  --foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 222.2 84% 4.9%;
  --radius: 0.5rem;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... dark mode overrides */
}
```

These variables are then registered in `tailwind.config.ts`:

```ts
// tailwind.config.ts
theme: {
  extend: {
    colors: {
      background: "hsl(var(--background))",
      foreground: "hsl(var(--foreground))",
      primary: {
        DEFAULT: "hsl(var(--primary))",
        foreground: "hsl(var(--primary-foreground))",
      },
      // ...
    }
  }
}
```

**Important:** The default shadcn/ui CSS variable names (`--primary`, `--background`, etc.) are intentionally terse and generic. For an institutional design system, these defaults will be **replaced** with a more structured semantic token architecture (see Section 4). The shadcn/ui variable system is the _mechanism_; the institutional token system is the _content_.

### 3.5 Component Ownership Model

The ownership model has specific implications for design system teams:

```
┌────────────────────────────────────────────────────────────────┐
│  UPSTREAM (shadcn/ui registry)                                │
│  Source of initial component implementations                  │
│  Radix UI primitives for accessibility behaviors             │
│  CVA for variant systems                                      │
│  Tailwind for utility styling                                 │
├────────────────────────────────────────────────────────────────┤
│  INSTITUTION-OWNED (your /packages/ui directory)              │
│  Copied component source files                               │
│  Institution-specific variants added to CVA definitions      │
│  Token-based Tailwind classes replacing generic ones         │
│  Wrapper components for institution-specific compositions    │
│  Additional components not in shadcn/ui                      │
└────────────────────────────────────────────────────────────────┘
```

The institution-owned layer is where design system work happens. The upstream layer is the starting point, not the ongoing dependency.

### 3.6 Benefits and Tradeoffs

**Benefits for institutional design systems:**

- Full component ownership means accessibility fixes are never blocked on upstream
- Direct source access makes deep customization straightforward
- No runtime library overhead; components are bundled like local code
- Tailwind CSS variables create a natural token integration point
- Radix UI primitives provide accessible behavior foundations

**Tradeoffs to plan for:**

- Upstream improvements require manual adoption; must establish a review cadence
- Teams unfamiliar with "copy the source" model may attempt to import from shadcn/ui directly (which does not work — establish this in onboarding)
- Large teams may inadvertently diverge component implementations if governance is weak
- The default variable naming (terse, generic) must be replaced for multi-theme support

---

## 4. Design Token Strategy

### 4.1 Token Categories

The institutional design token system is organized into eight categories. Every visual decision in the system belongs to one of these categories.

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│     COLOR       │  │   TYPOGRAPHY    │  │    SPACING      │
│  Raw palette    │  │  Font families  │  │  Scale (4px)    │
│  Brand aliases  │  │  Size scale     │  │  Named steps    │
│  Semantic roles │  │  Weight scale   │  │  Semantic roles │
└─────────────────┘  │  Line heights   │  └─────────────────┘
                     │  Letter spacing │
┌─────────────────┐  └─────────────────┘  ┌─────────────────┐
│     RADIUS      │                       │   ELEVATION     │
│  None/sm/md/lg  │  ┌─────────────────┐  │  Shadow scale   │
│  Full (pill)    │  │    MOTION       │  │  Depth semantic │
└─────────────────┘  │  Duration scale │  └─────────────────┘
                     │  Easing curves  │
┌─────────────────┐  │  Semantic roles │  ┌─────────────────┐
│    Z-INDEX      │  └─────────────────┘  │     LAYOUT      │
│  Named layers   │                       │  Breakpoints    │
│  No magic nums  │                       │  Container max  │
└─────────────────┘                       │  Column grids   │
                                          └─────────────────┘
```

### 4.2 Color Tokens

#### Raw Color Tokens

Define a full scale for every hue the institution uses. The scale uses numeric steps: `50` (lightest) to `950` (darkest). Include neutral, brand, and semantic hues.

```css
/* tokens/raw/colors.css */
:root {
  /* Neutral scale */
  --raw-color-neutral-0:   #ffffff;
  --raw-color-neutral-50:  #f8fafc;
  --raw-color-neutral-100: #f1f5f9;
  --raw-color-neutral-200: #e2e8f0;
  --raw-color-neutral-300: #cbd5e1;
  --raw-color-neutral-400: #94a3b8;
  --raw-color-neutral-500: #64748b;
  --raw-color-neutral-600: #475569;
  --raw-color-neutral-700: #334155;
  --raw-color-neutral-800: #1e293b;
  --raw-color-neutral-900: #0f172a;
  --raw-color-neutral-950: #020617;

  /* Brand Blue scale (example: Batac City institutional navy) */
  --raw-color-blue-50:  #eff6ff;
  --raw-color-blue-100: #dbeafe;
  --raw-color-blue-200: #bfdbfe;
  --raw-color-blue-300: #93c5fd;
  --raw-color-blue-400: #60a5fa;
  --raw-color-blue-500: #3b82f6;
  --raw-color-blue-600: #2563eb;
  --raw-color-blue-700: #1a3a6c;   /* Institutional primary */
  --raw-color-blue-800: #152f5a;
  --raw-color-blue-900: #0f2347;
  --raw-color-blue-950: #0a1a36;

  /* Brand Gold scale (example: institutional accent) */
  --raw-color-gold-50:  #fffbeb;
  --raw-color-gold-100: #fef3c7;
  --raw-color-gold-200: #fde68a;
  --raw-color-gold-300: #fcd34d;
  --raw-color-gold-400: #fbbf24;
  --raw-color-gold-500: #b8860b;   /* Institutional gold */
  --raw-color-gold-600: #92700a;
  --raw-color-gold-700: #6d5008;
  --raw-color-gold-800: #453206;
  --raw-color-gold-900: #231904;

  /* Status scales */
  --raw-color-red-50:   #fef2f2;
  --raw-color-red-100:  #fee2e2;
  --raw-color-red-500:  #ef4444;
  --raw-color-red-600:  #dc2626;
  --raw-color-red-700:  #b91c1c;

  --raw-color-green-50:  #f0fdf4;
  --raw-color-green-100: #dcfce7;
  --raw-color-green-500: #22c55e;
  --raw-color-green-600: #16a34a;
  --raw-color-green-700: #15803d;

  --raw-color-yellow-50:  #fefce8;
  --raw-color-yellow-100: #fef9c3;
  --raw-color-yellow-500: #eab308;
  --raw-color-yellow-600: #ca8a04;

  --raw-color-orange-50:  #fff7ed;
  --raw-color-orange-500: #f97316;
  --raw-color-orange-600: #ea580c;
}
```

#### Alias (Brand) Color Tokens

```css
/* tokens/alias/brand-colors.css */
:root {
  --color-brand-primary:          var(--raw-color-blue-700);
  --color-brand-primary-light:    var(--raw-color-blue-600);
  --color-brand-primary-dark:     var(--raw-color-blue-800);
  --color-brand-primary-subtle:   var(--raw-color-blue-100);
  --color-brand-primary-emphasis: var(--raw-color-blue-900);

  --color-brand-secondary:        var(--raw-color-gold-500);
  --color-brand-secondary-light:  var(--raw-color-gold-400);
  --color-brand-secondary-dark:   var(--raw-color-gold-600);
  --color-brand-secondary-subtle: var(--raw-color-gold-100);

  --color-neutral-surface:        var(--raw-color-neutral-0);
  --color-neutral-subtle:         var(--raw-color-neutral-50);
  --color-neutral-muted:          var(--raw-color-neutral-100);
  --color-neutral-text:           var(--raw-color-neutral-900);
  --color-neutral-text-secondary: var(--raw-color-neutral-600);
  --color-neutral-text-disabled:  var(--raw-color-neutral-400);
  --color-neutral-border:         var(--raw-color-neutral-200);
  --color-neutral-border-strong:  var(--raw-color-neutral-300);
}
```

#### Semantic Color Tokens

```css
/* tokens/semantic/colors.css */
:root {
  /* Interactive elements (buttons, links, interactive states) */
  --color-interactive-default:    var(--color-brand-primary);
  --color-interactive-hover:      var(--color-brand-primary-dark);
  --color-interactive-active:     var(--color-brand-primary-emphasis);
  --color-interactive-disabled:   var(--color-neutral-text-disabled);
  --color-interactive-text:       var(--raw-color-neutral-0);
  --color-interactive-focus-ring: var(--color-brand-primary);

  /* Surface (backgrounds at different elevations) */
  --color-surface-page:           var(--color-neutral-surface);
  --color-surface-default:        var(--color-neutral-surface);
  --color-surface-raised:         var(--raw-color-neutral-0);
  --color-surface-overlay:        var(--raw-color-neutral-0);
  --color-surface-subtle:         var(--color-neutral-subtle);
  --color-surface-inverse:        var(--color-brand-primary);

  /* Text */
  --color-text-default:           var(--color-neutral-text);
  --color-text-secondary:         var(--color-neutral-text-secondary);
  --color-text-disabled:          var(--color-neutral-text-disabled);
  --color-text-inverse:           var(--raw-color-neutral-0);
  --color-text-link:              var(--color-brand-primary);
  --color-text-link-hover:        var(--color-brand-primary-dark);

  /* Border */
  --color-border-default:         var(--color-neutral-border);
  --color-border-strong:          var(--color-neutral-border-strong);
  --color-border-interactive:     var(--color-brand-primary);
  --color-border-focus:           var(--color-brand-primary);

  /* Status */
  --color-status-error:           var(--raw-color-red-600);
  --color-status-error-surface:   var(--raw-color-red-50);
  --color-status-error-text:      var(--raw-color-red-700);
  --color-status-warning:         var(--raw-color-yellow-600);
  --color-status-warning-surface: var(--raw-color-yellow-50);
  --color-status-warning-text:    var(--raw-color-yellow-600);
  --color-status-success:         var(--raw-color-green-600);
  --color-status-success-surface: var(--raw-color-green-50);
  --color-status-success-text:    var(--raw-color-green-700);
  --color-status-info:            var(--color-brand-primary);
  --color-status-info-surface:    var(--color-brand-primary-subtle);
  --color-status-info-text:       var(--color-brand-primary-dark);

  /* Accent / brand highlight */
  --color-accent-default:         var(--color-brand-secondary);
  --color-accent-text:            var(--raw-color-neutral-900);
}
```

### 4.3 Typography Tokens

```css
/* tokens/raw/typography.css */
:root {
  /* Font Families */
  --font-family-display:   'Playfair Display', 'Georgia', serif;
  --font-family-body:      'Inter', 'Helvetica Neue', sans-serif;
  --font-family-mono:      'JetBrains Mono', 'Fira Code', monospace;
  --font-family-ui:        var(--font-family-body);

  /* Type Scale (Major Third — 1.250 ratio) */
  --font-size-2xs:  0.64rem;   /* 10.24px */
  --font-size-xs:   0.75rem;   /* 12px    */
  --font-size-sm:   0.875rem;  /* 14px    */
  --font-size-base: 1rem;      /* 16px    */
  --font-size-lg:   1.125rem;  /* 18px    */
  --font-size-xl:   1.25rem;   /* 20px    */
  --font-size-2xl:  1.563rem;  /* 25px    */
  --font-size-3xl:  1.953rem;  /* 31.25px */
  --font-size-4xl:  2.441rem;  /* 39px    */
  --font-size-5xl:  3.052rem;  /* 48.8px  */

  /* Font Weights */
  --font-weight-regular:   400;
  --font-weight-medium:    500;
  --font-weight-semibold:  600;
  --font-weight-bold:      700;
  --font-weight-extrabold: 800;

  /* Line Heights */
  --line-height-tight:    1.25;
  --line-height-snug:     1.375;
  --line-height-normal:   1.5;
  --line-height-relaxed:  1.625;
  --line-height-loose:    2;

  /* Letter Spacing */
  --letter-spacing-tight:   -0.025em;
  --letter-spacing-normal:   0;
  --letter-spacing-wide:     0.025em;
  --letter-spacing-wider:    0.05em;
  --letter-spacing-widest:   0.1em;
  --letter-spacing-display:  -0.04em;  /* Use for large display headings */
}

/* tokens/semantic/typography.css */
:root {
  /* Semantic text style mappings */
  --text-display-font:        var(--font-family-display);
  --text-display-size:        var(--font-size-4xl);
  --text-display-weight:      var(--font-weight-bold);
  --text-display-line-height: var(--line-height-tight);
  --text-display-spacing:     var(--letter-spacing-display);

  --text-heading-1-font:      var(--font-family-display);
  --text-heading-1-size:      var(--font-size-3xl);
  --text-heading-1-weight:    var(--font-weight-bold);

  --text-heading-2-font:      var(--font-family-display);
  --text-heading-2-size:      var(--font-size-2xl);
  --text-heading-2-weight:    var(--font-weight-semibold);

  --text-heading-3-font:      var(--font-family-body);
  --text-heading-3-size:      var(--font-size-xl);
  --text-heading-3-weight:    var(--font-weight-semibold);

  --text-body-font:           var(--font-family-body);
  --text-body-size:           var(--font-size-base);
  --text-body-weight:         var(--font-weight-regular);
  --text-body-line-height:    var(--line-height-normal);

  --text-ui-font:             var(--font-family-ui);
  --text-ui-size:             var(--font-size-sm);
  --text-ui-weight:           var(--font-weight-medium);

  --text-label-font:          var(--font-family-ui);
  --text-label-size:          var(--font-size-xs);
  --text-label-weight:        var(--font-weight-semibold);
  --text-label-spacing:       var(--letter-spacing-wider);

  --text-code-font:           var(--font-family-mono);
  --text-code-size:           var(--font-size-sm);
}
```

### 4.4 Spacing Tokens

The spacing system is based on a 4px base unit. Every spacing value is a multiple of 4px, creating a consistent rhythmic grid.

```css
/* tokens/raw/spacing.css */
:root {
  --space-px:   1px;
  --space-0:    0;
  --space-0-5:  0.125rem;  /* 2px  */
  --space-1:    0.25rem;   /* 4px  */
  --space-1-5:  0.375rem;  /* 6px  */
  --space-2:    0.5rem;    /* 8px  */
  --space-2-5:  0.625rem;  /* 10px */
  --space-3:    0.75rem;   /* 12px */
  --space-4:    1rem;      /* 16px */
  --space-5:    1.25rem;   /* 20px */
  --space-6:    1.5rem;    /* 24px */
  --space-7:    1.75rem;   /* 28px */
  --space-8:    2rem;      /* 32px */
  --space-10:   2.5rem;    /* 40px */
  --space-12:   3rem;      /* 48px */
  --space-14:   3.5rem;    /* 56px */
  --space-16:   4rem;      /* 64px */
  --space-20:   5rem;      /* 80px */
  --space-24:   6rem;      /* 96px */
  --space-32:   8rem;      /* 128px */
}

/* tokens/semantic/spacing.css */
:root {
  /* Component internal spacing */
  --space-component-xs:  var(--space-1);    /* 4px  */
  --space-component-sm:  var(--space-2);    /* 8px  */
  --space-component-md:  var(--space-3);    /* 12px */
  --space-component-lg:  var(--space-4);    /* 16px */
  --space-component-xl:  var(--space-6);    /* 24px */

  /* Layout section spacing */
  --space-section-sm:    var(--space-8);    /* 32px  */
  --space-section-md:    var(--space-12);   /* 48px  */
  --space-section-lg:    var(--space-16);   /* 64px  */
  --space-section-xl:    var(--space-24);   /* 96px  */

  /* Inline (horizontal) element spacing */
  --space-inline-xs:     var(--space-1);
  --space-inline-sm:     var(--space-2);
  --space-inline-md:     var(--space-3);
  --space-inline-lg:     var(--space-4);

  /* Stack (vertical) element spacing */
  --space-stack-xs:      var(--space-1);
  --space-stack-sm:      var(--space-2);
  --space-stack-md:      var(--space-4);
  --space-stack-lg:      var(--space-6);
  --space-stack-xl:      var(--space-8);
}
```

### 4.5 Radius Tokens

```css
/* tokens/raw/radius.css */
:root {
  --radius-none:  0;
  --radius-xs:    0.125rem;  /* 2px  */
  --radius-sm:    0.25rem;   /* 4px  */
  --radius-md:    0.375rem;  /* 6px  */
  --radius-lg:    0.5rem;    /* 8px  */
  --radius-xl:    0.75rem;   /* 12px */
  --radius-2xl:   1rem;      /* 16px */
  --radius-3xl:   1.5rem;    /* 24px */
  --radius-full:  9999px;    /* pill */
}

/* tokens/semantic/radius.css */
:root {
  --radius-button:   var(--radius-md);   /* Override per brand: sm=angular, lg=rounded */
  --radius-card:     var(--radius-lg);
  --radius-input:    var(--radius-md);
  --radius-badge:    var(--radius-full);
  --radius-tooltip:  var(--radius-md);
  --radius-dialog:   var(--radius-xl);
  --radius-dropdown: var(--radius-lg);
  --radius-avatar:   var(--radius-full);
}
```

### 4.6 Elevation Tokens

```css
/* tokens/raw/elevation.css */
:root {
  --shadow-none:   none;
  --shadow-xs:     0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-sm:     0 1px 3px 0 rgb(0 0 0 / 0.10), 0 1px 2px -1px rgb(0 0 0 / 0.10);
  --shadow-md:     0 4px 6px -1px rgb(0 0 0 / 0.10), 0 2px 4px -2px rgb(0 0 0 / 0.10);
  --shadow-lg:     0 10px 15px -3px rgb(0 0 0 / 0.10), 0 4px 6px -4px rgb(0 0 0 / 0.10);
  --shadow-xl:     0 20px 25px -5px rgb(0 0 0 / 0.10), 0 8px 10px -6px rgb(0 0 0 / 0.10);
  --shadow-2xl:    0 25px 50px -12px rgb(0 0 0 / 0.25);
  --shadow-inner:  inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
}

/* tokens/semantic/elevation.css */
:root {
  --elevation-base:       var(--shadow-none);   /* Flat elements, table rows */
  --elevation-raised:     var(--shadow-sm);     /* Cards, panels */
  --elevation-floating:   var(--shadow-md);     /* Dropdowns, popovers */
  --elevation-overlay:    var(--shadow-lg);     /* Modals, drawers */
  --elevation-sticky:     var(--shadow-md);     /* Sticky headers */
  --elevation-focus:      0 0 0 2px var(--color-interactive-focus-ring); /* Focus rings */
}
```

### 4.7 Motion Tokens

```css
/* tokens/raw/motion.css */
:root {
  /* Duration */
  --duration-instant:   0ms;
  --duration-fast:      100ms;
  --duration-normal:    200ms;
  --duration-slow:      300ms;
  --duration-slower:    400ms;
  --duration-slowest:   500ms;

  /* Easing */
  --ease-linear:        linear;
  --ease-in:            cubic-bezier(0.4, 0, 1, 1);
  --ease-out:           cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out:        cubic-bezier(0.4, 0, 0.2, 1);
  --ease-spring:        cubic-bezier(0.34, 1.56, 0.64, 1);
  --ease-bounce:        cubic-bezier(0.68, -0.6, 0.32, 1.6);
}

/* tokens/semantic/motion.css */
:root {
  /* Semantic roles */
  --transition-interactive: var(--duration-normal) var(--ease-in-out);
  --transition-enter:       var(--duration-slow) var(--ease-out);
  --transition-exit:        var(--duration-fast) var(--ease-in);
  --transition-fade:        var(--duration-normal) var(--ease-in-out);
  --transition-expand:      var(--duration-slow) var(--ease-spring);
}

/* Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  :root {
    --duration-fast:    0ms;
    --duration-normal:  0ms;
    --duration-slow:    0ms;
    --duration-slower:  0ms;
    --duration-slowest: 0ms;
  }
}
```

### 4.8 Z-Index Tokens

```css
/* tokens/semantic/z-index.css */
:root {
  --z-index-below:      -1;     /* Content behind default layer */
  --z-index-base:        0;     /* Default document flow */
  --z-index-raised:      10;    /* Slightly elevated (sticky table headers) */
  --z-index-sticky:      20;    /* Sticky navigation, fixed sidebars */
  --z-index-dropdown:    30;    /* Dropdown menus, context menus */
  --z-index-overlay:     40;    /* Modal overlays, backdrops */
  --z-index-modal:       50;    /* Modal dialogs */
  --z-index-popover:     60;    /* Tooltips, popovers above modals */
  --z-index-toast:       70;    /* Notification toasts */
  --z-index-spotlight:   80;    /* Command palette, global search */
}
```

**Why named z-index tokens matter:** Without them, magic numbers like `z-index: 9999` appear in codebases, leading to z-index wars. Named tokens enforce a strict stacking context hierarchy and make it immediately clear whether a toast should be above or below a modal.

### 4.9 Layout Tokens

```css
/* tokens/semantic/layout.css */
:root {
  /* Breakpoints (used in Tailwind config, not directly in CSS vars) */
  /* sm: 640px | md: 768px | lg: 1024px | xl: 1280px | 2xl: 1536px */

  /* Container max widths */
  --container-xs:   20rem;    /* 320px  — narrow forms */
  --container-sm:   24rem;    /* 384px  — card max width */
  --container-md:   28rem;    /* 448px  — dialog max width */
  --container-lg:   32rem;    /* 512px  — content column */
  --container-xl:   42rem;    /* 672px  — wide content */
  --container-2xl:  56rem;    /* 896px  — dashboard panel */
  --container-3xl:  64rem;    /* 1024px — page max */
  --container-full: 80rem;    /* 1280px — full layout */

  /* Grid */
  --grid-columns-default: 12;
  --grid-gutter-sm:       var(--space-4);
  --grid-gutter-md:       var(--space-6);
  --grid-gutter-lg:       var(--space-8);

  /* Sidebar widths */
  --sidebar-width-collapsed: 4rem;
  --sidebar-width-default:   16rem;
  --sidebar-width-wide:      20rem;

  /* Header height */
  --header-height: 4rem;
}
```

### 4.10 Token Naming Conventions

Follow a strict naming convention for all tokens. Inconsistency in token naming is a primary source of design system entropy.

**Pattern:** `[category]-[subcategory]-[variant]-[state]`

|Segment|Purpose|Examples|
|---|---|---|
|`category`|Token type|`color`, `font`, `space`, `radius`, `shadow`, `z-index`|
|`subcategory`|Semantic role or raw name|`interactive`, `surface`, `text`, `border`, `status`, `brand`|
|`variant`|Specific member of category|`default`, `hover`, `primary`, `secondary`, `error`|
|`state`|Optional state modifier|`hover`, `active`, `disabled`, `focus`, `checked`|

**Examples:**

```
color-interactive-default       ✅ color / interactive / default
color-interactive-hover         ✅ color / interactive / hover
color-status-error              ✅ color / status / error
color-status-error-surface      ✅ color / status / error / surface
font-size-lg                    ✅ font-size / lg
space-component-md              ✅ space / component / md
radius-button                   ✅ radius / button
z-index-modal                   ✅ z-index / modal

btn-blue                        ❌ — not categorical
primaryHoverBg                  ❌ — camelCase, ambiguous category
blue-700-hover                  ❌ — raw token used as semantic name
```

---

## 5. Brand Integration Process

### 5.1 Step 1: Audit the Brand Guidelines

Before writing a single token, conduct a systematic audit of the institutional brand guidelines.

**Brand Audit Checklist:**

```
[ ] Primary color(s) — Pantone/CMYK/RGB/HEX values
[ ] Secondary color(s) — same
[ ] Neutral palette — are grays warm, cool, or pure?
[ ] Status colors — are they specified or should we infer?
[ ] Primary typeface(s) — what formats are available (woff2, variable)?
[ ] Secondary/display typeface(s)
[ ] Monospace typeface (if specified)
[ ] Spacing/density preference — compact government UI or spacious?
[ ] Corner radius preference — sharp (government/formal) or rounded (approachable)?
[ ] Logo exclusion zones — affects header/nav spacing tokens
[ ] Motion preference — conservative or expressive?
[ ] Dark mode — is it required? Preferred?
[ ] Department sub-brands — color variations? Separate logos?
[ ] Accessibility requirements — WCAG AA minimum? AAA preferred?
[ ] Print/digital distinction — some tokens may be digital-only
```

### 5.2 Step 2: Convert Brand Colors to Raw Tokens

Brand guidelines provide colors in Pantone, CMYK, or spot colors. Convert to digital-first full-scale palettes.

**Conversion process:**

1. Obtain the HEX equivalent from the brand PDF.
2. Use a palette generator (e.g., [Radix Colors](https://www.radix-ui.com/colors), [Tailwind palette generator](https://www.tailwindshades.com/)) to generate a full 50–950 scale centered on the brand color.
3. **Manually verify accessibility** — generated scales may not have sufficient contrast at the steps needed for interactive elements. Adjust the 600–800 range as needed.
4. Record the official brand hex alongside the scale for documentation.

```css
/* Document the official brand color in a comment */
/* Official Batac City Primary: Pantone 288 C | CMYK 100/66/0/27 | HEX #1a3a6c */
--raw-color-blue-700: #1a3a6c;
```

### 5.3 Step 3: Verify Contrast on the Alias Layer

Before defining semantic tokens, verify that the brand primary color meets WCAG 2.1 AA contrast requirements (4.5:1 for normal text, 3:1 for large text and UI components) against intended backgrounds.

**Required contrast checks:**

|Combination|Minimum Ratio|Use Case|
|---|---|---|
|Brand Primary on White|4.5:1|Body text on white bg|
|Brand Primary on White|3:1|Large heading, button text|
|White on Brand Primary|4.5:1|Inverted button text|
|Brand Primary on Surface|4.5:1|Links on default background|

If the brand primary fails these checks, do not adjust the brand primary in the brand alias token. Instead, create a dedicated accessible variant:

```css
--color-brand-primary:            #1a3a6c;  /* Official brand color */
--color-brand-primary-accessible: #152f5a;  /* Passes 4.5:1 on white */
```

Then define semantic tokens to use the accessible variant for text-over-background contexts:

```css
--color-text-link: var(--color-brand-primary-accessible);
```

### 5.4 Step 4: Map Brand to Tailwind Configuration

The Tailwind configuration is the bridge between CSS custom properties and Tailwind utility classes. Map semantic tokens to Tailwind color names.

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        // Interactive
        interactive: {
          DEFAULT:  'var(--color-interactive-default)',
          hover:    'var(--color-interactive-hover)',
          active:   'var(--color-interactive-active)',
          disabled: 'var(--color-interactive-disabled)',
          text:     'var(--color-interactive-text)',
        },
        // Surface
        surface: {
          page:    'var(--color-surface-page)',
          DEFAULT: 'var(--color-surface-default)',
          raised:  'var(--color-surface-raised)',
          overlay: 'var(--color-surface-overlay)',
          subtle:  'var(--color-surface-subtle)',
          inverse: 'var(--color-surface-inverse)',
        },
        // Text
        text: {
          DEFAULT:   'var(--color-text-default)',
          secondary: 'var(--color-text-secondary)',
          disabled:  'var(--color-text-disabled)',
          inverse:   'var(--color-text-inverse)',
          link:      'var(--color-text-link)',
        },
        // Border
        border: {
          DEFAULT:     'var(--color-border-default)',
          strong:      'var(--color-border-strong)',
          interactive: 'var(--color-border-interactive)',
          focus:       'var(--color-border-focus)',
        },
        // Status
        status: {
          error:           'var(--color-status-error)',
          'error-surface': 'var(--color-status-error-surface)',
          'error-text':    'var(--color-status-error-text)',
          warning:         'var(--color-status-warning)',
          success:         'var(--color-status-success)',
          info:            'var(--color-status-info)',
        },
        // Brand (available for intentional brand expressions, NOT for component defaults)
        brand: {
          primary:  'var(--color-brand-primary)',
          secondary: 'var(--color-brand-secondary)',
        },
        // Accent
        accent: {
          DEFAULT: 'var(--color-accent-default)',
          text:    'var(--color-accent-text)',
        },
      },
      fontFamily: {
        display: 'var(--font-family-display)',
        body:    'var(--font-family-body)',
        mono:    'var(--font-family-mono)',
        ui:      'var(--font-family-ui)',
      },
      fontSize: {
        '2xs': ['var(--font-size-2xs)', { lineHeight: 'var(--line-height-normal)' }],
        xs:    ['var(--font-size-xs)',   { lineHeight: 'var(--line-height-normal)' }],
        sm:    ['var(--font-size-sm)',   { lineHeight: 'var(--line-height-normal)' }],
        base:  ['var(--font-size-base)', { lineHeight: 'var(--line-height-normal)' }],
        lg:    ['var(--font-size-lg)',   { lineHeight: 'var(--line-height-snug)'   }],
        xl:    ['var(--font-size-xl)',   { lineHeight: 'var(--line-height-snug)'   }],
        '2xl': ['var(--font-size-2xl)',  { lineHeight: 'var(--line-height-tight)'  }],
        '3xl': ['var(--font-size-3xl)',  { lineHeight: 'var(--line-height-tight)'  }],
        '4xl': ['var(--font-size-4xl)',  { lineHeight: 'var(--line-height-tight)'  }],
        '5xl': ['var(--font-size-5xl)',  { lineHeight: 'var(--line-height-tight)'  }],
      },
      spacing: {
        // Expose spacing tokens as Tailwind spacing values
        // (can also use the default scale; listed here for documentation clarity)
      },
      borderRadius: {
        none: 'var(--radius-none)',
        xs:   'var(--radius-xs)',
        sm:   'var(--radius-sm)',
        md:   'var(--radius-md)',
        DEFAULT: 'var(--radius-md)',
        lg:   'var(--radius-lg)',
        xl:   'var(--radius-xl)',
        '2xl': 'var(--radius-2xl)',
        full: 'var(--radius-full)',
      },
      boxShadow: {
        none:    'var(--shadow-none)',
        xs:      'var(--shadow-xs)',
        sm:      'var(--shadow-sm)',
        DEFAULT: 'var(--shadow-md)',
        md:      'var(--shadow-md)',
        lg:      'var(--shadow-lg)',
        xl:      'var(--shadow-xl)',
        '2xl':   'var(--shadow-2xl)',
        inner:   'var(--shadow-inner)',
        focus:   'var(--elevation-focus)',
      },
      transitionDuration: {
        instant: 'var(--duration-instant)',
        fast:    'var(--duration-fast)',
        normal:  'var(--duration-normal)',
        slow:    'var(--duration-slow)',
      },
      zIndex: {
        below:     'var(--z-index-below)',
        base:      'var(--z-index-base)',
        raised:    'var(--z-index-raised)',
        sticky:    'var(--z-index-sticky)',
        dropdown:  'var(--z-index-dropdown)',
        overlay:   'var(--z-index-overlay)',
        modal:     'var(--z-index-modal)',
        popover:   'var(--z-index-popover)',
        toast:     'var(--z-index-toast)',
        spotlight: 'var(--z-index-spotlight)',
      },
    },
  },
}

export default config
```

### 5.5 Handling Multiple Departments

Department themes are additive. They do not fork the system — they override the alias token layer within a scoped theme class.

**Approach: Theme Provider Component**

```tsx
// packages/ui/src/components/theme-provider.tsx
import { type ReactNode } from 'react'

type DepartmentTheme =
  | 'default'
  | 'engineering'
  | 'finance'
  | 'health'
  | 'education'
  | 'legal'

interface ThemeProviderProps {
  department?: DepartmentTheme
  colorMode?: 'light' | 'dark' | 'system'
  children: ReactNode
}

export function ThemeProvider({
  department = 'default',
  colorMode = 'light',
  children,
}: ThemeProviderProps) {
  return (
    <div
      data-theme={colorMode === 'dark' ? 'dark' : undefined}
      data-department={department !== 'default' ? department : undefined}
      className="contents"
    >
      {children}
    </div>
  )
}
```

```css
/* tokens/themes/departments.css */
[data-department="engineering"] {
  --color-brand-primary:        var(--raw-color-red-700);
  --color-brand-primary-dark:   var(--raw-color-red-800);
  --color-brand-primary-subtle: var(--raw-color-red-100);
  --color-brand-secondary:      var(--raw-color-orange-500);
}

[data-department="health"] {
  --color-brand-primary:        var(--raw-color-green-700);
  --color-brand-primary-dark:   var(--raw-color-green-800);
  --color-brand-primary-subtle: var(--raw-color-green-100);
  --color-brand-secondary:      var(--raw-color-blue-400);
}

[data-department="finance"] {
  --color-brand-primary:        var(--raw-color-neutral-800);
  --color-brand-primary-dark:   var(--raw-color-neutral-900);
  --color-brand-primary-subtle: var(--raw-color-neutral-100);
  --color-brand-secondary:      var(--raw-color-gold-500);
}
```

All components update automatically when wrapped in a department ThemeProvider because they reference semantic tokens, which cascade from alias tokens, which are overridden at the department level.

### 5.6 Handling Future Rebranding

The token architecture's primary value is rebranding resilience. When a rebrand occurs, the following and only the following files change:

1. `tokens/raw/colors.css` — new palette values added
2. `tokens/alias/brand-colors.css` — alias tokens re-pointed to new values
3. Optionally: `tokens/raw/typography.css` — new typeface definitions

Zero component files change. This is the architectural guarantee.

**To validate rebrand readiness:**

```bash
# Run this check — if any component file contains a raw color hex, it is NOT rebrand-ready
grep -rn '#[0-9a-fA-F]\{6\}' packages/ui/src/components/
```

Any matches are violations of the token contract and should be fixed before the rebrand is initiated.

---

## 6. Repository Structure

### 6.1 Top-Level Structure

```
institution-design-system/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Lint, type-check, test on PR
│   │   ├── chromatic.yml             # Visual regression via Storybook/Chromatic
│   │   └── release.yml               # Semantic versioning and changelog
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS                    # Token changes require design team review
│
├── apps/
│   ├── docs/                         # Documentation site (Next.js)
│   │   ├── pages/                    # Component docs, guidelines, examples
│   │   └── public/                   # Static assets for docs
│   └── storybook/                    # Storybook instance
│       ├── .storybook/               # Storybook configuration
│       └── stories/                  # Story files (can also co-locate in packages/ui)
│
├── packages/
│   ├── tokens/                       # ← Design token source of truth
│   │   ├── src/
│   │   │   ├── raw/
│   │   │   │   ├── colors.css
│   │   │   │   ├── typography.css
│   │   │   │   ├── spacing.css
│   │   │   │   ├── radius.css
│   │   │   │   ├── elevation.css
│   │   │   │   ├── motion.css
│   │   │   │   └── z-index.css
│   │   │   ├── alias/
│   │   │   │   ├── brand-colors.css
│   │   │   │   └── brand-typography.css
│   │   │   ├── semantic/
│   │   │   │   ├── colors.css
│   │   │   │   ├── typography.css
│   │   │   │   ├── spacing.css
│   │   │   │   ├── radius.css
│   │   │   │   ├── elevation.css
│   │   │   │   ├── motion.css
│   │   │   │   ├── z-index.css
│   │   │   │   └── layout.css
│   │   │   └── themes/
│   │   │       ├── dark.css
│   │   │       └── departments.css
│   │   ├── index.css                 # Aggregates and exports all token CSS
│   │   └── package.json
│   │
│   ├── ui/                           # ← Component library
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── primitives/       # shadcn/ui base components (copied + adapted)
│   │   │   │   │   ├── button/
│   │   │   │   │   │   ├── button.tsx
│   │   │   │   │   │   ├── button.test.tsx
│   │   │   │   │   │   └── index.ts
│   │   │   │   │   ├── input/
│   │   │   │   │   ├── select/
│   │   │   │   │   ├── dialog/
│   │   │   │   │   ├── table/
│   │   │   │   │   ├── badge/
│   │   │   │   │   ├── card/
│   │   │   │   │   └── ...
│   │   │   │   ├── composite/        # Combinations of primitives
│   │   │   │   │   ├── search-input/
│   │   │   │   │   ├── data-table/
│   │   │   │   │   ├── form-field/
│   │   │   │   │   ├── confirmation-dialog/
│   │   │   │   │   └── ...
│   │   │   │   └── patterns/         # Institution-specific feature patterns
│   │   │   │       ├── document-status-badge/
│   │   │   │       ├── approval-workflow-timeline/
│   │   │   │       └── ...
│   │   │   ├── hooks/
│   │   │   │   ├── use-theme.ts
│   │   │   │   ├── use-media-query.ts
│   │   │   │   └── ...
│   │   │   ├── utils/
│   │   │   │   ├── cn.ts             # clsx + tailwind-merge utility
│   │   │   │   └── ...
│   │   │   └── index.ts              # Public API exports
│   │   ├── tailwind.config.ts
│   │   └── package.json
│   │
│   ├── icons/                        # Institution icon set
│   │   ├── src/
│   │   │   └── components/           # SVG-to-React compiled icons
│   │   └── package.json
│   │
│   └── config/                       # Shared tooling config
│       ├── eslint/
│       ├── typescript/
│       └── tailwind/
│
├── docs/                             # Markdown documentation
│   ├── DESIGN.md
│   ├── BRAND.md
│   ├── DESIGN-HANDOFF.md
│   ├── COMPONENT-GUIDELINES.md
│   ├── ACCESSIBILITY.md
│   ├── THEMING.md
│   ├── CONTRIBUTING.md
│   ├── GOVERNANCE.md
│   ├── MIGRATION.md
│   └── AI-CONTEXT.md
│
├── scripts/
│   ├── token-validator.ts            # Validates no hardcoded values in components
│   ├── contrast-checker.ts           # WCAG contrast audit on token pairs
│   └── component-audit.ts            # Checks components follow naming conventions
│
├── package.json                      # Monorepo root (pnpm workspaces / Turborepo)
├── pnpm-workspace.yaml
├── turbo.json
└── README.md
```

### 6.2 Why This Structure

**`packages/tokens` is separate from `packages/ui`** because tokens change on a different cadence than components. Token changes trigger visual regression tests across all components. This separation makes that dependency explicit.

**Component subdirectory per component** (not per category) because colocation of the component file, its tests, its stories, and its types reduces navigation overhead and makes deletion safe.

**`primitives/`, `composite/`, `patterns/` hierarchy** maps directly to the component architecture (Section 8), making it immediately clear what each component's abstraction level is.

**`docs/` at root level** ensures documentation is peer-to-code, not nested inside a package where it becomes invisible.

**`scripts/`** contains enforcement tooling. Design system governance enforced only by convention eventually fails. Automate the checks.

---

## 7. Documentation Standards

Documentation is a first-class deliverable of the design system. Undocumented components do not exist from the perspective of downstream teams, AI assistants, and future maintainers.

### 7.1 DESIGN.md — System Overview

**Purpose:** Single-entry-point overview of the entire design system.

**Audience:** All contributors — designers, developers, AI assistants, new team members.

**Required Sections:**

```markdown
# [Institution] Design System

## Overview
What this system is, what it powers, why it exists.

## Quick Start
Installation, setup commands, minimal working example.

## Architecture
Layer diagram (see Section 2), brief description of each layer.

## Token System
Link to token reference docs. Explain the three-tier model.

## Component Library
Link to Storybook. List of available components.

## Theming
How to apply themes. Available themes.

## Contributing
Link to CONTRIBUTING.md.

## Governance
Who owns what. How to propose changes.

## Changelog
Link to CHANGELOG.md. Summary of major versions.
```

### 7.2 BRAND.md — Brand Integration Reference

**Purpose:** Documents how institutional brand guidelines were translated into design tokens. Provides the audit trail.

**Audience:** Designers, brand reviewers, future rebranding teams.

**Required Sections:**

```markdown
# Brand Integration Reference

## Source Brand Guidelines
Version, date, owner, link to official brand PDF.

## Color Translation
For each brand color:
- Official name and Pantone reference
- CMYK, RGB, HEX values from brand guidelines
- Corresponding raw token name
- Contrast ratios verified

## Typography Translation
For each typeface:
- Official name and usage guidelines from brand
- License status and source URL
- Corresponding font-family token
- Loading strategy (Google Fonts, local, variable font)

## Deviations from Brand Guidelines
If any digital token values deviate from print brand guidelines
(e.g., color shifted slightly for WCAG compliance), document them here
with the rationale. This is critical for brand review conversations.

## Accessibility Notes
WCAG compliance status per color combination.
```

### 7.3 DESIGN-HANDOFF.md — Designer–Developer Contract

**Purpose:** Specifies exactly what designers must provide when handing off a component design, and what developers are responsible for implementing.

**Audience:** Designers, developers, AI assistants.

**Required Sections:**

```markdown
# Design Handoff Protocol

## What Designers Provide
- Figma component link
- Token annotations (which semantic tokens are used, not hex values)
- All states: default, hover, focus, active, disabled, error
- All breakpoints (mobile-first)
- Accessibility notes (ARIA labels, roles if non-standard)
- Copy/content specifications

## What Developers Implement
- Component using semantic tokens only (no hardcoded values)
- All documented states
- Keyboard interaction model
- ARIA roles and attributes
- Tests (unit + visual regression)
- Storybook story with all states visible

## Token Annotation Convention
Figma layers should be annotated with CSS variable names, not hex values.
Example: Fill → --color-interactive-default (not #1a3a6c)

## Figma–Code Token Mapping
| Figma Style Name        | CSS Variable                     |
|-------------------------|----------------------------------|
| Brand/Primary           | --color-interactive-default      |
| Text/Default            | --color-text-default             |
| Surface/Default         | --color-surface-default          |
...

## Approval Checklist
Before development begins:
[ ] All states designed
[ ] Tokens annotated (not hex values)
[ ] Mobile viewport designed
[ ] Accessibility notes provided
[ ] Copy finalized
```

### 7.4 COMPONENT-GUIDELINES.md — Component Authoring Rules

**Purpose:** The authoritative rules for writing and extending components in this system.

**Audience:** Developers, AI coding assistants.

**Required Sections:**

```markdown
# Component Guidelines

## Rules (Non-Negotiable)
1. Reference semantic tokens only in component Tailwind classes.
2. Never use arbitrary Tailwind values in component files.
3. Export the component and its props type from the package index.
4. Every exported component must have a Storybook story.
5. Variants are defined using CVA, not conditional className logic.
6. Accessibility attributes are required, not optional.

## File Naming
- Component files: PascalCase.tsx (Button.tsx, not button.tsx)
- Test files: ComponentName.test.tsx
- Story files: ComponentName.stories.tsx
- Index file: index.ts (re-exports only)

## Component API Patterns
- Always extend HTML element props via ComponentPropsWithoutRef<'element'>
- Always forward refs via forwardRef
- Always use the cn() utility for className merging

## Adding Variants
Use CVA. Never use string concatenation for conditional classes.

## Styling Primitives vs. Wrappers
Primitives own their internal styles via CVA.
Wrappers use className prop to configure the primitive.
Compositions use className prop on their internal elements.

## Deprecation
See GOVERNANCE.md for the deprecation workflow.
```

### 7.5 ACCESSIBILITY.md — A11y Standards

**Purpose:** Define the accessibility requirements that every component must meet.

**Audience:** Developers, QA, auditors.

**Required Sections:**

```markdown
# Accessibility Standards

## Compliance Target
WCAG 2.1 Level AA minimum. Level AAA for government-mandated contexts.
Relevant Philippine laws: RA 7277 (Magna Carta for Disabled Persons),
RA 10173 data sensitivity requirements.

## Color Contrast Requirements
| Context                      | Minimum Ratio |
|------------------------------|---------------|
| Normal text (< 18pt)         | 4.5:1         |
| Large text (≥ 18pt or 14pt bold) | 3:1       |
| UI components, focus rings   | 3:1           |
| Decorative elements          | No requirement|

## Keyboard Navigation
All interactive elements must be keyboard-operable.
Tab order must follow visual reading order.
Focus must never be trapped outside intended modal contexts.
Escape must close overlays, modals, dropdowns.

## Focus Indicators
All focusable elements must have a visible focus indicator.
Focus ring: 2px solid var(--color-interactive-focus-ring),
  2px offset.
Never remove default outline without replacing it.

## Screen Reader Support
Semantic HTML elements preferred over generic div/span.
ARIA roles only when semantic HTML is insufficient.
Live regions (aria-live) for dynamic content updates.
Meaningful alt text for all non-decorative images.

## Motion and Animation
All animations must respect prefers-reduced-motion.
Motion tokens set to 0ms when reduced motion is preferred (see token config).

## Testing Requirements
Automated: axe-core integration in tests and CI.
Manual: Regular keyboard navigation audit.
Screen reader: NVDA (Windows), VoiceOver (macOS/iOS) compatibility.
```

### 7.6 THEMING.md — Theme Configuration Reference

**Purpose:** How to configure, apply, extend, and create themes.

```markdown
# Theming Reference

## Architecture
Three-tier CSS custom property cascade:
Raw tokens → Alias tokens → Semantic tokens → Theme overrides

## Available Themes
| Theme Key         | Selector              | Description            |
|-------------------|-----------------------|------------------------|
| light (default)   | :root                 | Default light theme    |
| dark              | [data-theme="dark"]   | Dark mode override     |
| engineering       | [data-department="engineering"] | Dept. variant |
| health            | [data-department="health"]      | Dept. variant |

## Applying a Theme
<ThemeProvider department="health" colorMode="dark">
  <App />
</ThemeProvider>

## Creating a Department Theme
1. Add alias token overrides in tokens/themes/departments.css
2. Add the theme key to the DepartmentTheme type in theme-provider.tsx
3. Document in this file
4. Verify accessibility of new color combinations

## Token Override Rules
- Themes override the alias layer only.
- Themes must not introduce new semantic token names.
- All overrides must pass the same contrast requirements.
```

### 7.7 CONTRIBUTING.md

**Purpose:** How to contribute to the design system, from idea to merged PR.

```markdown
# Contributing to the Design System

## Types of Contributions
- Bug fix in existing component
- New variant on existing component
- New component proposal
- Token change or addition
- Documentation improvement
- Accessibility fix

## Workflow for Each Type

### Bug Fix
1. Open issue with reproduction
2. Get acknowledgment from maintainer
3. PR with fix and test update

### New Component
1. Open RFC (Request for Comment) issue using RFC template
2. Design review (one week open comment period)
3. Implementation in feature branch
4. Storybook story required before review
5. Accessibility review
6. Merge approval requires 2 maintainer reviews

### Token Change
CAUTION: Token changes may affect every component.
1. Contrast audit required before any color token change
2. Visual regression diff review required
3. No token removals without a deprecation period

## Pull Request Checklist
See .github/PULL_REQUEST_TEMPLATE.md
```

---

## 8. Component Architecture

### 8.1 The Three-Tier Component Hierarchy

```
┌──────────────────────────────────────────────────────────────┐
│  TIER 3: PATTERN COMPONENTS                                  │
│  Institution-specific, domain-aware compositions            │
│  Examples: DocumentStatusBadge, ApprovalWorkflowTimeline    │
│  Depends on: Composite components                           │
│  Exports: Full composition, not configurable building blocks│
├──────────────────────────────────────────────────────────────┤
│  TIER 2: COMPOSITE COMPONENTS                               │
│  Institution-specific combinations of primitives            │
│  Examples: SearchInput, FormField, ConfirmationDialog       │
│  Depends on: Primitive components                           │
│  Exports: Configurable component with institution defaults  │
├──────────────────────────────────────────────────────────────┤
│  TIER 1: PRIMITIVE COMPONENTS                               │
│  shadcn/ui base components, institution-styled              │
│  Examples: Button, Input, Badge, Table, Dialog              │
│  Depends on: Design tokens (Tailwind) + Radix UI            │
│  Exports: Flexible, low-level building blocks               │
└──────────────────────────────────────────────────────────────┘
```

### 8.2 Primitive Components

Primitives are the direct descendants of shadcn/ui components. They are copied into the project, then adapted to use the institutional token system.

**Standard primitive component structure:**

```tsx
// packages/ui/src/components/primitives/button/button.tsx
import * as React from 'react'
import { Slot } from '@radix-ui/react-slot'
import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from '@/utils/cn'

// CVA definition — all variants use semantic tokens only
const buttonVariants = cva(
  // Base: applies to every variant
  [
    'inline-flex items-center justify-center gap-2',
    'font-ui font-medium text-sm',
    'rounded-button',
    'transition-colors duration-normal',
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-border-focus focus-visible:ring-offset-2',
    'disabled:pointer-events-none disabled:opacity-50',
    'select-none',
  ].join(' '),
  {
    variants: {
      variant: {
        // Primary: the institution's main action button
        primary: [
          'bg-interactive text-interactive-text',
          'hover:bg-interactive-hover',
          'active:bg-interactive-active',
          'border border-transparent',
        ].join(' '),

        // Secondary: lower visual weight, still actionable
        secondary: [
          'bg-surface-subtle text-text',
          'hover:bg-surface-raised',
          'border border-border',
        ].join(' '),

        // Outline: border only, no fill
        outline: [
          'bg-transparent text-interactive',
          'hover:bg-surface-subtle',
          'border border-interactive',
        ].join(' '),

        // Ghost: no border, minimal presence
        ghost: [
          'bg-transparent text-text',
          'hover:bg-surface-subtle',
          'border border-transparent',
        ].join(' '),

        // Destructive: error/danger actions
        destructive: [
          'bg-status-error text-interactive-text',
          'hover:bg-status-error/90',
          'border border-transparent',
        ].join(' '),

        // Link: text-only, anchor-like appearance
        link: [
          'bg-transparent text-text-link underline-offset-4',
          'hover:underline hover:text-text-link-hover',
          'border border-transparent p-0 h-auto',
        ].join(' '),
      },
      size: {
        xs: 'h-7 px-2.5 text-xs',
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-11 px-6 text-base',
        xl: 'h-12 px-8 text-base',
        icon: 'h-10 w-10 p-0',
        'icon-sm': 'h-8 w-8 p-0',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
)

// Props type extends native button element
export interface ButtonProps
  extends React.ComponentPropsWithoutRef<'button'>,
    VariantProps<typeof buttonVariants> {
  /**
   * When true, renders as child component (Radix UI Slot pattern).
   * Use when you want button styling on a Link component.
   */
  asChild?: boolean
  /** Loading state — shows spinner and disables interaction */
  isLoading?: boolean
}

// Forward ref is required for compatibility with Radix UI
const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, isLoading, disabled, children, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button'
    return (
      <Comp
        ref={ref}
        className={cn(buttonVariants({ variant, size, className }))}
        disabled={disabled || isLoading}
        aria-disabled={disabled || isLoading}
        {...props}
      >
        {isLoading && (
          <svg
            className="h-4 w-4 animate-spin"
            aria-hidden="true"
            viewBox="0 0 24 24"
            fill="none"
          >
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
          </svg>
        )}
        {children}
      </Comp>
    )
  }
)
Button.displayName = 'Button'

export { Button, buttonVariants }
```

### 8.3 Composite Components

Composites combine primitives into purpose-built patterns that appear frequently across the institution's interfaces.

```tsx
// packages/ui/src/components/composite/form-field/form-field.tsx
import * as React from 'react'
import { cn } from '@/utils/cn'

interface FormFieldProps {
  label: string
  htmlFor: string
  error?: string
  hint?: string
  required?: boolean
  className?: string
  children: React.ReactNode
}

/**
 * FormField: Standard labeled form control wrapper.
 * Provides consistent label, error, and hint rendering for all form inputs.
 *
 * Usage:
 * <FormField label="Document Title" htmlFor="doc-title" required error={errors.title}>
 *   <Input id="doc-title" {...register('title')} />
 * </FormField>
 */
export function FormField({
  label,
  htmlFor,
  error,
  hint,
  required,
  className,
  children,
}: FormFieldProps) {
  const errorId = error ? `${htmlFor}-error` : undefined
  const hintId = hint ? `${htmlFor}-hint` : undefined

  return (
    <div className={cn('flex flex-col gap-1.5', className)}>
      <label
        htmlFor={htmlFor}
        className="text-sm font-medium text-text leading-none"
      >
        {label}
        {required && (
          <span className="ml-1 text-status-error" aria-hidden="true">
            *
          </span>
        )}
        {required && (
          <span className="sr-only">(required)</span>
        )}
      </label>

      {/* Clone children to inject aria-describedby */}
      {React.cloneElement(children as React.ReactElement, {
        'aria-describedby': [hintId, errorId].filter(Boolean).join(' ') || undefined,
        'aria-invalid': error ? true : undefined,
      })}

      {hint && !error && (
        <p id={hintId} className="text-xs text-text-secondary">
          {hint}
        </p>
      )}

      {error && (
        <p id={errorId} role="alert" className="text-xs text-status-error-text flex items-center gap-1">
          <span aria-hidden="true">⚠</span>
          {error}
        </p>
      )}
    </div>
  )
}
```

### 8.4 When to Extend vs. Wrap vs. Fork

**The decision framework:**

```
┌─────────────────────────────────────────────────────────────────┐
│  Does the change require modifying the component's behavior    │
│  (not just appearance)?                                        │
│                    YES ──────────── WRAP or FORK              │
│                    NO                                          │
│                    ↓                                           │
│  Is the change a new variant that belongs in the design system?│
│                    YES ──────────── EXTEND (add CVA variant)   │
│                    NO                                          │
│                    ↓                                           │
│  Is the change application-specific (not reusable)?           │
│                    YES ──────────── Use className prop locally │
│                    NO                                          │
│                    ↓                                           │
│  Does the change require internal DOM structure changes?       │
│                    YES ──────────── FORK                       │
│                    NO ──────────── WRAP                        │
└─────────────────────────────────────────────────────────────────┘
```

**Extend:** Add a new variant to the CVA definition. Use when the variant is reusable across the system and belongs conceptually to the component.

```tsx
// Adding an "institution-accent" button variant to the CVA
variant: {
  'accent': [
    'bg-accent text-accent-text',
    'hover:bg-accent/90',
    'border border-transparent',
  ].join(' '),
}
```

**Wrap:** Create a new component that renders the primitive with specific props. Use when you want a semantic alias (e.g., `SubmitButton` is always a `primary lg` Button) that does not need internal access.

```tsx
// Composite wrapper
export function SubmitButton({ isLoading, children, ...props }: Omit<ButtonProps, 'variant' | 'size'>) {
  return (
    <Button variant="primary" size="lg" isLoading={isLoading} type="submit" {...props}>
      {children}
    </Button>
  )
}
```

**Fork:** Edit the primitive's source file directly. Use only when Radix UI's behavior or the component's DOM structure needs to change. Document the fork reason in a comment at the top of the file. Schedule a review of whether upstream shadcn/ui has since resolved the issue.

```tsx
// Button.tsx — FORKED from shadcn/ui
// Fork reason: Added isLoading prop with spinner (not available upstream as of 2025-09)
// Review: Check shadcn/ui changelog in Jan 2026
```

---

## 9. Theming Strategy

### 9.1 Light Mode

Light mode is the default. All semantic tokens are defined in `:root` for light mode. No special class or attribute is required.

### 9.2 Dark Mode

Dark mode is implemented as a CSS variable override scoped to `[data-theme="dark"]`. This approach (vs. the `.dark` class) allows dark mode to be applied to specific subtrees rather than only the entire page.

```css
/* tokens/themes/dark.css */
[data-theme="dark"] {
  /* Surface */
  --color-surface-page:    var(--raw-color-neutral-950);
  --color-surface-default: var(--raw-color-neutral-900);
  --color-surface-raised:  var(--raw-color-neutral-800);
  --color-surface-overlay: var(--raw-color-neutral-800);
  --color-surface-subtle:  var(--raw-color-neutral-800);
  --color-surface-inverse: var(--raw-color-neutral-100);

  /* Text */
  --color-text-default:    var(--raw-color-neutral-50);
  --color-text-secondary:  var(--raw-color-neutral-400);
  --color-text-disabled:   var(--raw-color-neutral-600);
  --color-text-inverse:    var(--raw-color-neutral-900);
  --color-text-link:       var(--raw-color-blue-400);
  --color-text-link-hover: var(--raw-color-blue-300);

  /* Border */
  --color-border-default:  var(--raw-color-neutral-700);
  --color-border-strong:   var(--raw-color-neutral-600);

  /* Interactive — slightly lighter for dark background contrast */
  --color-interactive-default: var(--raw-color-blue-400);
  --color-interactive-hover:   var(--raw-color-blue-300);
  --color-interactive-text:    var(--raw-color-neutral-900);

  /* Elevation — darker shadows are invisible in dark mode */
  --shadow-sm:  0 1px 3px 0 rgb(0 0 0 / 0.30);
  --shadow-md:  0 4px 6px -1px rgb(0 0 0 / 0.30);
  --shadow-lg:  0 10px 15px -3px rgb(0 0 0 / 0.30);
}
```

### 9.3 Runtime Theme Switching

Implement a `useTheme` hook that manages the `data-theme` attribute on the root element and persists preference to localStorage.

```tsx
// packages/ui/src/hooks/use-theme.ts
import { useEffect, useState, useCallback } from 'react'

type ColorMode = 'light' | 'dark' | 'system'

const STORAGE_KEY = 'institution-color-mode'

export function useTheme() {
  const [colorMode, setColorModeState] = useState<ColorMode>('system')

  // Initialize from storage on mount
  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY) as ColorMode | null
    if (stored) setColorModeState(stored)
  }, [])

  // Resolve 'system' to actual mode based on OS preference
  const resolvedMode = colorMode === 'system'
    ? window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    : colorMode

  // Apply resolved mode to root element
  useEffect(() => {
    const root = document.documentElement
    if (resolvedMode === 'dark') {
      root.setAttribute('data-theme', 'dark')
    } else {
      root.removeAttribute('data-theme')
    }
  }, [resolvedMode])

  const setColorMode = useCallback((mode: ColorMode) => {
    setColorModeState(mode)
    localStorage.setItem(STORAGE_KEY, mode)
  }, [])

  return { colorMode, resolvedMode, setColorMode }
}
```

### 9.4 Multiple Themes at Runtime

For applications serving multiple departments from a single deployment, apply department themes at the page or section level:

```tsx
// Page-level department theme
export function DepartmentPage({ department, children }: { department: string, children: React.ReactNode }) {
  return (
    <div data-department={department} className="min-h-screen bg-surface-page text-text">
      {children}
    </div>
  )
}
```

This allows a single application to show the health department's green palette on `/health/*` routes and the engineering department's red palette on `/engineering/*` routes, with all shared components updating automatically.

### 9.5 Scalability Concerns

As the number of themes grows, be alert to:

1. **Token explosion:** Each new theme adds a CSS override block. Performance is generally fine up to ~20 themes, but audit CSS bundle size at scale.
2. **Accessibility drift:** Each department theme must be independently verified for contrast compliance. Automate this with the contrast-checker script.
3. **Inconsistency between themes:** If department A changes their alias tokens and department B's team is unaware, shared semantic tokens may diverge from intent. Governance process must include cross-department token review.

---

## 10. Accessibility Requirements

### 10.1 Compliance Standard

The system targets **WCAG 2.1 Level AA** as the minimum for all components and **WCAG 2.1 Level AAA** for critical government service interfaces (forms, document status, citizen-facing workflows).

Relevant Philippine legal context:

- **RA 7277** (Magna Carta for Disabled Persons): requires accessible government digital services
- **RA 11032** (Ease of Doing Business Act): efficiency requirements that include digital accessibility
- **PWD ID Act**: specific documentation services must be accessible to persons with disabilities

### 10.2 Color Contrast Enforcement

**At the token level:** Every semantic color token pair used for text-over-background must be documented with its contrast ratio. This is enforced by `scripts/contrast-checker.ts`, which runs in CI.

```ts
// scripts/contrast-checker.ts (simplified)
// Checks all declared text/surface token combinations against WCAG ratios
const requiredPairs = [
  { text: '--color-text-default',    bg: '--color-surface-default',  minRatio: 4.5, label: 'Body text' },
  { text: '--color-text-secondary',  bg: '--color-surface-default',  minRatio: 4.5, label: 'Secondary text' },
  { text: '--color-interactive-text', bg: '--color-interactive-default', minRatio: 4.5, label: 'Button text' },
  { text: '--color-text-link',       bg: '--color-surface-default',  minRatio: 4.5, label: 'Link text' },
  { text: '--color-status-error-text', bg: '--color-status-error-surface', minRatio: 4.5, label: 'Error message' },
  // ... all token combinations
]
```

**At the component level:** Components must never set `opacity` on text that results in a failing contrast ratio.

### 10.3 Focus States

All interactive elements must have a visible focus indicator that meets the WCAG 2.2 focus appearance requirements (minimum 2px outline, minimum 3:1 contrast against adjacent colors).

**Standard focus ring CSS:**

```css
/* Defined in tailwind.config.ts as focus-visible plugin */
.focus-visible\:ring-2:focus-visible {
  box-shadow:
    0 0 0 2px var(--color-surface-default),
    0 0 0 4px var(--color-interactive-focus-ring);
}
```

**Non-negotiable rules:**

- `outline: none` or `outline: 0` is **never** acceptable without a custom focus indicator
- Focus indicators must be visible in both light and dark mode
- Focus must be visible on all backgrounds the component could appear on

### 10.4 Keyboard Navigation

|Pattern|Required Behavior|
|---|---|
|Dialog/Modal|Tab stays within dialog; Escape closes|
|Dropdown Menu|Arrow keys navigate items; Enter selects; Escape closes|
|Tab Panel|Left/Right arrows switch tabs; Focus moves to panel|
|Tree View|Arrow keys navigate; Enter expands/selects|
|Table|Arrow keys navigate cells; tab moves to next focusable element|
|Combobox|Arrow keys navigate options; Enter selects; Escape closes|

Radix UI primitives implement these patterns correctly. Do not replace Radix UI keyboard behavior with custom implementations unless the behavior is demonstrably incorrect.

### 10.5 Screen Reader Support

**ARIA usage policy:** Use semantic HTML elements first. Use ARIA attributes only when semantic HTML is insufficient or when augmenting existing semantics.

```tsx
// ✅ Correct: Semantic HTML, no extra ARIA needed
<nav aria-label="Main navigation">
  <a href="/documents">Documents</a>
</nav>

// ❌ Incorrect: ARIA substituting for semantic HTML
<div role="navigation" aria-label="Main navigation">
  <span role="link" tabIndex={0} onClick={...}>Documents</span>
</div>

// ✅ Correct: ARIA augmenting semantic HTML for dynamic content
<button aria-expanded={isOpen} aria-controls="menu-list">
  Menu
</button>
<ul id="menu-list" hidden={!isOpen}>...</ul>
```

**Live regions for dynamic content:**

```tsx
// Status messages, loading states, and notifications must use live regions
<div aria-live="polite" aria-atomic="true" className="sr-only" role="status">
  {statusMessage}
</div>
```

### 10.6 Enforcing Accessibility in CI

```yaml
# .github/workflows/ci.yml (accessibility section)
- name: Run axe accessibility audit
  run: |
    npx storybook build
    npx axe-storybook --exit-zero-on-error=false
```

Additionally, integrate `jest-axe` into component tests:

```tsx
// Button.test.tsx
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

it('has no accessibility violations', async () => {
  const { container } = render(<Button variant="primary">Submit</Button>)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

---

## 11. AI-Assisted Development

### 11.1 The Problem

AI coding assistants — Claude, Cursor, Copilot, ChatGPT — generate code by pattern-matching on training data and context. Without explicit design system context, they will:

- Use hardcoded hex values instead of tokens
- Use generic Tailwind classes (`bg-blue-600`) instead of semantic tokens (`bg-interactive`)
- Generate shadcn/ui import statements instead of local component imports
- Invent component APIs that do not match the established interface
- Create inline styles instead of using the token system

The solution is **context engineering**: providing AI assistants with the precise information they need to generate conformant code.

### 11.2 AI-CONTEXT.md — The AI-Specific Reference Document

Create a dedicated `docs/AI-CONTEXT.md` that is purpose-built for AI assistant consumption. This document should be dense, unambiguous, and direct.

````markdown
# AI Coding Context: [Institution] Design System

## CRITICAL RULES
These rules are absolute. Do not generate code that violates them.

1. NEVER import from 'shadcn/ui' or '@shadcn/ui'. All components are local.
2. ALWAYS import from '@institution/ui' or relative paths within the monorepo.
3. NEVER use hardcoded color hex values (#ffffff, #000000, etc.) in component files.
4. NEVER use arbitrary Tailwind values (bg-[#1a3a6c], text-[14px]).
5. ALWAYS use semantic token Tailwind classes.
6. NEVER use the Tailwind 'blue-*', 'red-*', 'green-*' color palette directly in components.
7. ALWAYS use 'cn()' utility for className merging.
8. ALWAYS forward refs on all primitive components.
9. ALWAYS export ComponentNameProps type alongside the component.
10. ALL variants use CVA. No conditional className string concatenation.

## Import Paths
```ts
// Correct component imports
import { Button } from '@institution/ui/button'
import { Input } from '@institution/ui/input'
import { cn } from '@institution/ui/utils'
import { FormField } from '@institution/ui/composite/form-field'

// Incorrect — DO NOT generate
import { Button } from '@/components/ui/button' // (unless that IS the local path)
import { Button } from 'shadcn-ui'              // never
````

## Semantic Color Tokens (Use These — NEVER use raw color names)

- Interactive/Button background: `bg-interactive` hover: `hover:bg-interactive-hover`
- Text on interactive bg: `text-interactive-text`
- Page background: `bg-surface-page`
- Card/panel background: `bg-surface-default`
- Elevated surface: `bg-surface-raised`
- Default text: `text-text`
- Secondary/muted text: `text-text-secondary`
- Disabled text: `text-text-disabled`
- Link color: `text-text-link`
- Default border: `border-border`
- Strong border: `border-border-strong`
- Error state: `bg-status-error text-interactive-text`
- Error surface: `bg-status-error-surface text-status-error-text`
- Success: `bg-status-success text-interactive-text`
- Warning: `bg-status-warning text-interactive-text`
- Info: `bg-status-info-surface text-status-info-text`

## Available Components (import from @institution/ui)

Primitives: Button, Input, Select, Textarea, Checkbox, Radio, Switch, Badge, Card, Dialog, Drawer, DropdownMenu, Popover, Tooltip, Table, Tabs, Accordion, Alert, Avatar, Breadcrumb, Separator

Composite: FormField, SearchInput, DataTable, ConfirmationDialog, PageHeader

## Component API Patterns

```tsx
// Correct primitive component shape
import { forwardRef, type ComponentPropsWithoutRef } from 'react'
import { cva, type VariantProps } from 'class-variance-authority'

const myVariants = cva('base-classes', {
  variants: { variant: { default: 'semantic-token-classes' } },
  defaultVariants: { variant: 'default' }
})

interface MyComponentProps
  extends ComponentPropsWithoutRef<'div'>,
    VariantProps<typeof myVariants> {}

const MyComponent = forwardRef<HTMLDivElement, MyComponentProps>(
  ({ className, variant, ...props }, ref) => (
    <div ref={ref} className={cn(myVariants({ variant, className }))} {...props} />
  )
)
MyComponent.displayName = 'MyComponent'
export { MyComponent, type MyComponentProps }
```

## Focus Ring Pattern

All interactive elements: `focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-border-focus focus-visible:ring-offset-2`

## Radius Pattern

Use semantic radius tokens: `rounded-button` (buttons), `rounded-card` (cards), `rounded-input` (inputs), `rounded-badge` (badges), `rounded-dialog` (modals). NEVER: `rounded`, `rounded-lg`, `rounded-md` (these are raw, not semantic).

## Typography Pattern

Font families: `font-display` (headings), `font-body` (prose), `font-ui` (UI labels), `font-mono` (code) NEVER use font-sans, font-serif from default Tailwind.

## Z-Index Pattern

Use named z-index tokens: `z-dropdown`, `z-overlay`, `z-modal`, `z-toast`, `z-popover`. NEVER use numeric z-index values.

## Motion/Transition Pattern

`transition-colors duration-normal` for color transitions. `transition-all duration-slow ease-spring` for layout transitions. NEVER: `transition-all duration-200` (numeric duration not allowed).

```

### 11.3 Cursor / Windsurf Rules Files

Create `.cursorrules` (Cursor) and `.windsurfrules` (Windsurf) at the repository root. These files are automatically loaded by the respective editors.

```

# .cursorrules

You are working in the [Institution] Design System monorepo.

MANDATORY RULES:

- All components must use semantic token Tailwind classes from the token system.
- See docs/AI-CONTEXT.md for the complete token reference and component API patterns.
- Never import from shadcn/ui directly. All UI components are local in packages/ui.
- Never hardcode hex color values or numeric z-index values.
- Always forward refs on primitive components.
- All variants defined using class-variance-authority (CVA), never inline conditionals.
- Read COMPONENT-GUIDELINES.md before writing any new component.

```

### 11.4 Claude Project Knowledge

For teams using Claude Projects, load the following documents into project knowledge:

1. `docs/AI-CONTEXT.md` (highest priority)
2. `docs/COMPONENT-GUIDELINES.md`
3. `docs/ACCESSIBILITY.md`
4. Full token reference (from `packages/tokens/src/`)
5. Example component implementations (Button, FormField)

The project system prompt should include:

```

You are assisting with development on the [Institution] Design System. Always read and follow the rules in AI-CONTEXT.md before writing any code. When generating components, use only semantic tokens, local imports, and CVA patterns. When uncertain about a token name, ask rather than guess or use a raw value.

````

### 11.5 Detecting AI-Generated Non-Conformant Code

Run this check in CI to catch code that does not follow design system conventions:

```bash
# Detect hardcoded hex colors in component files
echo "=== Checking for hardcoded hex values ==="
grep -rn --include="*.tsx" --include="*.ts" '#[0-9a-fA-F]\{3,8\}' packages/ui/src/components/ && exit 1 || echo "Clean."

# Detect shadcn/ui direct imports
echo "=== Checking for shadcn/ui direct imports ==="
grep -rn "from 'shadcn" packages/ && exit 1 || echo "Clean."

# Detect numeric z-index values
echo "=== Checking for numeric z-index values ==="
grep -rn "z-index: [0-9]" packages/ui/src/ && exit 1 || echo "Clean."

# Detect arbitrary Tailwind values
echo "=== Checking for arbitrary Tailwind values ==="
grep -rn '\[#[0-9a-fA-F]' packages/ui/src/ && exit 1 || echo "Clean."
````

---

## 12. Governance

### 12.1 Ownership Model

```
┌─────────────────────────────────────────────────────────────────┐
│  DESIGN SYSTEM MAINTAINERS (2-3 people)                        │
│  Responsibility: Tokens, architecture, breaking changes,        │
│    release management, governance enforcement                   │
│  Approval authority: All token changes, new components          │
├─────────────────────────────────────────────────────────────────┤
│  DESIGN SYSTEM CONTRIBUTORS (all frontend developers)           │
│  Responsibility: Bug fixes, variant additions, documentation    │
│  Approval authority: None unilateral — all PRs require review  │
├─────────────────────────────────────────────────────────────────┤
│  DESIGN REVIEWERS (1-2 UI/UX designers)                        │
│  Responsibility: Visual review of new components and variants   │
│  Approval authority: Visual correctness, brand compliance       │
└─────────────────────────────────────────────────────────────────┘
```

### 12.2 New Component Proposal Workflow

```
1. DISCOVERY
   Developer identifies a repeated UI pattern not in the system.
   Opens a GitHub Issue using the "Component Proposal" template.
   Template requires: use cases (≥2), proposed API, token needs.

2. DESIGN REVIEW (1 week)
   Design reviewer creates Figma mockup with full state coverage.
   Open comment period for team feedback.
   Async approval/rejection with written rationale.

3. RFC (Request for Comment) (optional for large components)
   Post proposed API as a PR with only the type definitions.
   No implementation — API review only.

4. IMPLEMENTATION
   Feature branch: feat/component-name
   Component + tests + Storybook story (all states).
   Follows COMPONENT-GUIDELINES.md.

5. REVIEW
   2 maintainer approvals required.
   Design reviewer visual approval required.
   Accessibility review (axe + manual keyboard check).

6. DOCUMENTATION
   README in component directory.
   Story documents all variants and states.
   CHANGELOG.md entry.

7. RELEASE
   Included in next minor version (semver).
   Announcement in team channel.
```

### 12.3 Token Change Workflow

Token changes carry higher risk than component changes because they affect every component simultaneously.

```
TOKEN CHANGE RISK LEVELS:

LOW RISK (semantic patch):
  Adding a new semantic token with no existing equivalent.
  Action: PR + 1 maintainer review + contrast check.

MEDIUM RISK (semantic change):
  Changing which raw/alias token a semantic token maps to.
  Action: PR + 2 maintainer reviews + visual regression review.
  Requires: Before/after screenshots of all affected components.

HIGH RISK (alias or raw change):
  Changing the value of a raw or alias token.
  Action: RFC issue + full team discussion + visual regression suite.
  Requires: Contrast audit of all affected token pairs.
  May require: Design review meeting.

CRITICAL RISK (token removal):
  Removing any token.
  Action: Deprecation period (2 releases minimum) + migration guide.
  Forbidden: Removal of semantic tokens used in any component.
```

### 12.4 Versioning

Follow [Semantic Versioning](https://semver.org/):

|Change Type|Version Bump|Examples|
|---|---|---|
|Bug fix, accessibility fix|Patch (0.0.X)|Focus ring color fixed, ARIA label corrected|
|New component, new variant|Minor (0.X.0)|New Badge variant, new FormField component|
|Token change, breaking API|Major (X.0.0)|Token renamed, prop removed, behavior changed|

**CHANGELOG.md entries are required** for every release. Use the [Keep a Changelog](https://keepachangelog.com/) format.

### 12.5 Deprecation Policy

Components and tokens are never silently removed. The deprecation lifecycle:

```
PHASE 1: DEPRECATED (minimum 2 releases)
  - Add @deprecated JSDoc comment to component/token
  - Log console.warn in development when deprecated component is used
  - Document migration path in CHANGELOG.md
  - Emit lint rule warning if possible

PHASE 2: REMOVAL
  - Remove in a major version only
  - Migration guide in CHANGELOG.md and docs
  - Announce in team channel 2 weeks before release
```

```tsx
/**
 * @deprecated Use `<Badge variant="status">` instead.
 * Will be removed in v3.0.0. See migration guide: https://...
 */
export function StatusBadge(props: StatusBadgeProps) {
  if (process.env.NODE_ENV === 'development') {
    console.warn('[DesignSystem] StatusBadge is deprecated. Use Badge with variant="status".')
  }
  return <Badge variant="status" {...props} />
}
```

---

## 13. Migration Strategy

### 13.1 Migrating an Existing shadcn/ui Project

If the team has already used shadcn/ui directly and now wants to adopt the design system, follow this staged approach.

**Phase 1: Install the token layer without breaking anything**

```bash
# Install the tokens package
pnpm add @institution/tokens

# Add token CSS to globals.css (above existing shadcn variables)
# packages/tokens/index.css BEFORE the shadcn variable block
```

At this point, the token CSS is loaded but nothing uses it. Existing components continue to use the old shadcn variables. No visual breakage.

**Phase 2: Map old shadcn variables to new semantic tokens**

Create a compatibility shim that maps the old terse shadcn variable names to the new semantic tokens. This makes old components automatically pick up token values without modification.

```css
/* compatibility/shadcn-shim.css */
/* This file is TEMPORARY. Remove when migration is complete. */
:root {
  /* Map legacy shadcn vars to new semantic tokens */
  --background:            var(--color-surface-default);
  --foreground:            var(--color-text-default);
  --primary:               var(--color-interactive-default);
  --primary-foreground:    var(--color-interactive-text);
  --secondary:             var(--color-surface-subtle);
  --secondary-foreground:  var(--color-text-default);
  --muted:                 var(--color-surface-subtle);
  --muted-foreground:      var(--color-text-secondary);
  --accent:                var(--color-accent-default);
  --accent-foreground:     var(--color-accent-text);
  --destructive:           var(--color-status-error);
  --destructive-foreground: var(--color-interactive-text);
  --border:                var(--color-border-default);
  --input:                 var(--color-border-default);
  --ring:                  var(--color-border-focus);
  --radius:                var(--radius-md);
}
```

With this shim, all existing shadcn/ui components immediately reflect the institutional tokens.

**Phase 3: Replace shadcn components with design system components (component by component)**

Prioritize by frequency of use. Replace the highest-frequency components first. Track progress with a migration spreadsheet.

```
Component     | Usages | Status     | Owner    | Target
Button        | 847    | ✅ Done    | @dev1    | v1.0
Input         | 512    | ✅ Done    | @dev2    | v1.0
Badge         | 231    | 🔄 In Prog | @dev3    | v1.1
Table         | 198    | ⬜ Pending | -        | v1.2
```

**Phase 4: Remove the shim when migration is complete**

Delete `compatibility/shadcn-shim.css`. Run the full application. Remaining failures indicate components that still reference the old variable names directly.

### 13.2 Migrating a Legacy React Application

Legacy React apps may use inline styles, CSS modules, styled-components, or Emotion. The migration is more complex.

**Strategy: Incremental parallel introduction**

Do not attempt a big-bang rewrite. Instead:

1. Install the design system package alongside existing styles.
2. Apply `ThemeProvider` at the root level (it is `className="contents"` — zero visual impact until tokens are used).
3. Replace components by page, not by component type. Start with a low-traffic page to validate approach.
4. Keep legacy styles active until a page is fully migrated.
5. Remove legacy style files as pages complete migration.

**CSS Module migration:**

```css
/* Before: colors.module.css */
.button { background-color: #1a3a6c; color: white; }

/* After: delete this file. Use the Button component instead.
   If the custom class is truly needed, use semantic tokens: */
.custom-button { background-color: var(--color-interactive-default); }
```

**Styled-components migration:**

```tsx
// Before
const StyledButton = styled.button`
  background-color: #1a3a6c;
  color: white;
  border-radius: 4px;
`

// After
import { Button } from '@institution/ui/button'
// Replace <StyledButton> with <Button variant="primary">
```

### 13.3 Inconsistent Component Library Migration

If the existing codebase has multiple ad-hoc component implementations of the same UI pattern (e.g., three different "button" components):

1. **Audit first.** Run a codebase scan to find all button-like implementations.
2. **Unify to one.** Choose the most complete implementation as the migration target.
3. **Introduce the design system button.** Do not modify the existing implementations yet.
4. **Create a migration codemods script** using `jscodeshift` or `ast-grep` to automate the replacement of common patterns.
5. **Deprecate the old implementations** with console.warn.
6. **Delete after a sprint.**

---

## 14. Scaling Considerations

### 14.1 Enterprise and Government Applications

Government design systems have specific scaling requirements:

**Multi-agency deployment:** A central government design system may be adopted by dozens of agencies with minimal local customization authority. The token layer is the control surface. Agencies can override alias tokens (their department color) but not semantic tokens or component structures. Enforce this with published policy, not just convention.

**Compliance auditing:** Government accessibility requirements may require a formal audit trail. Document every accessibility-related token value (contrast ratios) and every accessibility-related component decision (ARIA patterns). Store this in `ACCESSIBILITY.md` with signed-off dates and versions.

**Security review:** Government applications may require a component security review (checking for XSS vectors in dynamic content rendering). Design system components should never use `dangerouslySetInnerHTML`. Document this explicitly in COMPONENT-GUIDELINES.md.

**Offline and low-bandwidth:** Philippine government deployments may serve areas with limited connectivity. Design tokens are CSS variables — they load as a single CSS file, which is efficiently cached. Component bundle sizes should be audited regularly. Prefer tree-shaking over barrel exports.

### 14.2 Multi-Team Development

When multiple development teams use the same design system:

**Token ownership matrix:**

```
Token Layer       | Owner           | Can Others Override?
Raw tokens        | DS Maintainers  | No — change requires RFC
Alias tokens      | DS Maintainers  | No — change requires RFC
Semantic tokens   | DS Maintainers  | No — change requires RFC
Theme overrides   | Department leads | Yes — within published constraints
```

**Component ownership matrix:**

```
Component Type    | Owns Source  | Can Add Variants?  | Can Fork?
Primitives        | DS Team      | Via PR to DS repo  | No (use wrap)
Composite         | DS Team      | Via PR to DS repo  | No (use wrap)
Patterns          | Feature teams | Via local creation | Yes — local only
```

**Monorepo boundary enforcement:** If teams use Turborepo, configure `turbo.json` so that no application can directly import from `packages/tokens` — they must go through `packages/ui` which re-exports tokens in a controlled way. This prevents applications from coupling to internal token names that may change.

### 14.3 Long-Term Maintenance

**Token stability guarantee:** Once a semantic token is published in a major version, its _name_ is guaranteed stable for the life of that major version. Its _value_ may change (for rebrands), but consumers can rely on the name.

**Component stability guarantee:** Published component props are stable within a major version. New optional props may be added in minor versions (non-breaking). Required props may not be added without a major bump.

**Dependency management:**

```
Radix UI          → Update quarterly; review release notes for behavioral changes
class-variance-authority → Pin to minor version; update with testing
Tailwind CSS      → Update carefully; v3→v4 requires migration effort
React             → Pin to major version; upgrade as a coordinated project
```

**Design system health metrics to track:**

- Component adoption rate (% of product UI using DS components vs. ad-hoc)
- Token compliance rate (% of UI code using semantic tokens, not raw values)
- Storybook coverage (% of components with complete stories)
- Accessibility audit pass rate
- Average time from proposal to merged component
- Outdated component count (shadcn/ui upstream divergence)

---

## 15. Deliverables & Reference

### 15.1 Common Mistakes and Anti-Patterns

**Anti-pattern 1: Using raw/alias tokens in components**

```tsx
// ❌ Anti-pattern — references alias token (brittle to rebrand)
<div className="bg-brand-primary text-white">

// ✅ Correct — references semantic token (rebrand-safe)
<div className="bg-interactive text-interactive-text">
```

**Anti-pattern 2: Arbitrarily extending CVA in component callsites**

```tsx
// ❌ Anti-pattern — overriding internal component styling externally
<Button className="bg-red-600 hover:bg-red-700 rounded-none text-xs px-2">

// ✅ Correct — using variant system or requesting a new variant
<Button variant="destructive" size="xs">
// (if custom radius is needed, propose a variant to the DS team)
```

**Anti-pattern 3: Creating a "God component" with too many variants**

A Button with 15 variants is a sign that some of those variants should be separate composite components. If the variant count exceeds 8, consider splitting.

**Anti-pattern 4: Skipping the token layer for "one-off" values**

```tsx
// ❌ Anti-pattern — "this banner only appears once so I'll hardcode it"
<div style={{ backgroundColor: '#e8f4f8', padding: '20px' }}>

// ✅ Correct — use the nearest existing semantic token
<div className="bg-status-info-surface p-5">
```

One-off hardcoded values are how design debt accumulates. The cost of using a semantic token is zero. The cost of finding and fixing 40 hardcoded values during a rebrand is significant.

**Anti-pattern 5: Treating the design system as "someone else's job"**

Every developer who writes frontend code is a contributor to the design system's health. When inconsistencies are noticed, they should be reported or fixed. When a pattern is repeated more than twice, it should be proposed as a component.

**Anti-pattern 6: Building a component without a Storybook story**

A component without a story does not exist for downstream teams, AI assistants, designers, or future maintainers. Stories are not optional documentation — they are the component's contract.

**Anti-pattern 7: Dark mode as an afterthought**

Dark mode is a theme, not a feature. If the semantic token layer is built correctly, dark mode is a day-one capability that requires only defining the dark theme's semantic token overrides. If dark mode is added later to a system without semantic tokens, it requires touching every component.

**Anti-pattern 8: Using semantic HTML for layout, not semantics**

```tsx
// ❌ Anti-pattern — using <section> because "it looks like a card"
<section className="bg-surface-raised p-4 rounded-card">

// ✅ Correct — use semantic elements for their semantic role
<div className="bg-surface-raised p-4 rounded-card" role="region" aria-labelledby="section-heading">
// or use the <Card> component
<Card>
```

### 15.2 Implementation Roadmap

```
PHASE 0: FOUNDATIONS (Weeks 1-2)
───────────────────────────────────
Goal: Token system and project scaffolding.

Deliverables:
- Monorepo initialized (pnpm workspaces + Turborepo)
- packages/tokens: all raw, alias, and semantic token CSS files
- tailwind.config.ts with full token mapping
- globals.css with token CSS imported
- contrast-checker.ts script passing on all token pairs
- DESIGN.md, BRAND.md, ACCESSIBILITY.md (initial drafts)

Definition of Done:
- `pnpm dev` works
- Token CSS loads in browser
- All documented color pairs pass WCAG AA contrast check

PHASE 1: PRIMITIVE COMPONENTS (Weeks 3-5)
────────────────────────────────────────────
Goal: Core primitives shipped with full Storybook coverage.

Components: Button, Input, Select, Textarea, Checkbox, Radio, Switch,
  Badge, Card, Separator, Avatar, Tooltip, Breadcrumb

Deliverables:
- All components using semantic tokens only
- All states covered in Storybook
- jest-axe passing on all components
- COMPONENT-GUIDELINES.md published
- AI-CONTEXT.md published (initial version)

Definition of Done:
- No hardcoded hex values in packages/ui (validated by script)
- All components have complete Storybook stories
- Chromatic/visual regression baseline established

PHASE 2: COMPOSITE COMPONENTS (Weeks 6-8)
────────────────────────────────────────────
Goal: High-frequency compositions for form and data interfaces.

Components: FormField, SearchInput, DataTable, ConfirmationDialog,
  PageHeader, Pagination, EmptyState, LoadingState

Deliverables:
- Composite components published
- DESIGN-HANDOFF.md finalized
- Migration guide for existing shadcn/ui components

Definition of Done:
- Composite components documented with usage examples
- At least one application page migrated to use design system

PHASE 3: THEMING AND MULTI-DEPARTMENT (Weeks 9-11)
───────────────────────────────────────────────────
Goal: Dark mode and department themes operational.

Deliverables:
- Dark mode theme CSS complete and verified accessible
- Department themes for all known departments
- ThemeProvider component
- useTheme hook with localStorage persistence
- THEMING.md published

Definition of Done:
- Visual regression suite passes in both light and dark mode
- All department themes pass contrast audit
- Theme switching works in Storybook

PHASE 4: GOVERNANCE AND DOCUMENTATION (Weeks 12-13)
────────────────────────────────────────────────────
Goal: System is self-sustaining with documented processes.

Deliverables:
- CONTRIBUTING.md published
- GOVERNANCE.md published
- GitHub CI workflows (lint, axe, contrast check, visual regression)
- CODEOWNERS file
- Component proposal issue template
- Team onboarding session/recording

Definition of Done:
- CI passes on PR without manual steps
- At least 2 non-maintainer contributors have opened PRs using the workflow
- AI assistants (Claude, Cursor) generating conformant components using AI-CONTEXT.md

PHASE 5: PATTERN COMPONENTS AND SCALE (Weeks 14+)
───────────────────────────────────────────────────
Goal: Institution-specific domain patterns and system refinement.

Deliverables:
- Domain-specific pattern components (DocumentStatusBadge, etc.)
- Performance audit of CSS bundle size
- Full application migration from legacy styles
- v1.0.0 stable release

Definition of Done:
- All new feature work uses design system components by default
- No net-new hardcoded style values introduced in the preceding 4 sprints
- Design system adoption rate ≥ 80% across measured UI surfaces
```

---

## Appendix A: Token Quick Reference

|Token|Class|Usage|
|---|---|---|
|`--color-interactive-default`|`bg-interactive`|Primary button background|
|`--color-interactive-hover`|`hover:bg-interactive-hover`|Button hover state|
|`--color-interactive-text`|`text-interactive-text`|Text on interactive bg|
|`--color-surface-page`|`bg-surface-page`|Page background|
|`--color-surface-default`|`bg-surface-default`|Default surface|
|`--color-surface-raised`|`bg-surface-raised`|Card, panel|
|`--color-surface-overlay`|`bg-surface-overlay`|Modal background|
|`--color-surface-subtle`|`bg-surface-subtle`|Subtle hover bg|
|`--color-text-default`|`text-text`|Default text|
|`--color-text-secondary`|`text-text-secondary`|Supporting text|
|`--color-text-disabled`|`text-text-disabled`|Disabled text|
|`--color-text-link`|`text-text-link`|Link text|
|`--color-border-default`|`border-border`|Default border|
|`--color-border-focus`|`ring-border-focus`|Focus ring|
|`--color-status-error`|`bg-status-error`|Error bg|
|`--color-status-error-surface`|`bg-status-error-surface`|Error info bg|
|`--color-status-success`|`bg-status-success`|Success bg|
|`--color-status-warning`|`bg-status-warning`|Warning bg|
|`--color-status-info`|`bg-status-info`|Info accent bg|

## Appendix B: Component Authoring Checklist

Before marking a component as ready for review:

```
Component Structure
[ ] TypeScript types: ComponentNameProps extends native HTML element props
[ ] forwardRef wrapper
[ ] displayName set
[ ] Named export of component and props type

Styling
[ ] All Tailwind classes use semantic tokens (no raw color names, no hex)
[ ] CVA used for all variants
[ ] cn() used for className merging
[ ] No arbitrary Tailwind values ([value])
[ ] No hardcoded hex values

States
[ ] default
[ ] hover
[ ] focus (focus-visible ring)
[ ] active
[ ] disabled
[ ] error (if applicable)
[ ] loading (if applicable)

Accessibility
[ ] Semantic HTML element used where possible
[ ] ARIA attributes correct and complete
[ ] Keyboard navigation tested manually
[ ] jest-axe passes in test file
[ ] Screen reader tested (at minimum, VoiceOver)

Documentation
[ ] JSDoc comment on component and key props
[ ] Storybook story with all variants visible
[ ] Storybook story with all states visible
[ ] README.md in component directory

Tests
[ ] Unit test file exists
[ ] axe accessibility test
[ ] Key interaction tests (click, keyboard)
```

---

_This handbook is a living document. It should be updated whenever a governance decision is made, a new pattern is established, or a standard changes. The current version should always be in `docs/DESIGN.md`._

_Last structural revision: refer to git history._ _Owner: Design System Maintainers_ _Review cadence: Quarterly, or after any major architectural change_