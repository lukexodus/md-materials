# Font Features

Font features are typographic enhancements built into modern fonts that allow for refined control over text appearance. Here's an overview:

## What Are Font Features?

Font features are optional typographic refinements embedded in OpenType fonts. They control how characters are displayed and can include alternatives for letters, number styles, spacing adjustments, and more.

## Common Font Features

**Ligatures**
- Standard ligatures combine characters like "fi" and "fl" to prevent collisions
- Discretionary ligatures offer stylistic combinations like "ct" or "st"

**Number Styles**
- Lining figures: uniform height numbers (1234567890)
- Old-style figures: numbers with ascenders and descenders that vary in height
- Tabular figures: fixed-width numbers for tables
- Proportional figures: variable-width numbers for body text

**Case Variants**
- Small caps: lowercase letters designed as capitals
- All small caps: both upper and lowercase rendered as small capitals
- Case-sensitive forms: punctuation that aligns better with capitals

**Positional Forms**
- Superscript and subscript
- Numerators and denominators for fractions
- Ordinals (1st, 2nd, 3rd)

**Stylistic Alternatives**
- Stylistic sets: alternate character designs
- Contextual alternates: characters that change based on surrounding letters
- Swashes: decorative flourishes

## How to Access Font Features

**In Design Software**
- Adobe applications: Character panel or OpenType panel
- Figma: Typography settings in the design panel
- Sketch: Typeface options in the inspector

**In CSS**
```css
font-feature-settings: "liga" 1, "dlig" 1;
font-variant-numeric: oldstyle-nums;
```

**In Word Processors**
- Microsoft Word: Font dialog > Advanced tab
- Google Docs: Limited support for basic features

## Why Font Features Matter

They allow designers and typographers to achieve professional-quality typography by accessing the full range of characters and refinements that type designers built into their fonts. Not all fonts include all features—quality varies by typeface.

