# All About the Intl API

The **Intl API** (Internationalization API) is a built-in JavaScript namespace that provides language-sensitive string comparison, number formatting, date and time formatting, and other internationalization features. It's part of the ECMAScript Internationalization API specification and is available in all modern browsers and Node.js environments.

## Core Purpose

The Intl API helps developers create applications that work correctly across different languages, regions, and cultures by handling complex formatting rules that vary by locale. Instead of manually implementing formatting logic for different countries, you can rely on the browser's built-in support.

## Main Objects

### Intl.DateTimeFormat

Formats dates and times according to locale-specific conventions.

```javascript
// Basic usage
const date = new Date('2025-12-11');
const formatter = new Intl.DateTimeFormat('en-US');
console.log(formatter.format(date)); // "12/11/2025"

// With options
const longFormatter = new Intl.DateTimeFormat('en-US', {
  weekday: 'long',
  year: 'numeric',
  month: 'long',
  day: 'numeric'
});
console.log(longFormatter.format(date)); // "Thursday, December 11, 2025"

// Different locales
console.log(new Intl.DateTimeFormat('de-DE').format(date)); // "11.12.2025"
console.log(new Intl.DateTimeFormat('ja-JP').format(date)); // "2025/12/11"
```

### Intl.NumberFormat

Formats numbers, currencies, and percentages according to locale conventions.

```javascript
// Basic number formatting
const number = 1234567.89;
console.log(new Intl.NumberFormat('en-US').format(number)); // "1,234,567.89"
console.log(new Intl.NumberFormat('de-DE').format(number)); // "1.234.567,89"

// Currency formatting
const price = 42.50;
const usdFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
});
console.log(usdFormatter.format(price)); // "$42.50"

const eurFormatter = new Intl.NumberFormat('de-DE', {
  style: 'currency',
  currency: 'EUR'
});
console.log(eurFormatter.format(price)); // "42,50 €"

// Percentage formatting
const percent = 0.756;
const percentFormatter = new Intl.NumberFormat('en-US', {
  style: 'percent',
  minimumFractionDigits: 1
});
console.log(percentFormatter.format(percent)); // "75.6%"
```

### Intl.Collator

Provides language-sensitive string comparison for sorting.

```javascript
// Sorting with proper locale support
const names = ['Ärger', 'Apfel', 'Zähler'];

// Default sort (incorrect for German)
console.log(names.sort()); // ["Apfel", "Zähler", "Ärger"]

// Correct German sorting
const collator = new Intl.Collator('de-DE');
console.log(names.sort(collator.compare)); // ["Apfel", "Ärger", "Zähler"]

// Case-insensitive comparison
const caseInsensitiveCollator = new Intl.Collator('en-US', { 
  sensitivity: 'base' 
});
console.log(caseInsensitiveCollator.compare('a', 'A')); // 0 (equal)
```

### Intl.RelativeTimeFormat

Formats relative time descriptions like "3 days ago" or "in 2 months".

```javascript
const rtf = new Intl.RelativeTimeFormat('en-US', { numeric: 'auto' });

console.log(rtf.format(-1, 'day'));    // "yesterday"
console.log(rtf.format(0, 'day'));     // "today"
console.log(rtf.format(1, 'day'));     // "tomorrow"
console.log(rtf.format(-3, 'week'));   // "3 weeks ago"
console.log(rtf.format(2, 'month'));   // "in 2 months"

// Different locale
const rtfFr = new Intl.RelativeTimeFormat('fr-FR');
console.log(rtfFr.format(-1, 'day'));  // "il y a 1 jour"
```

### Intl.ListFormat

Formats lists of items according to locale conventions.

```javascript
const fruits = ['apples', 'oranges', 'bananas'];

// English conjunction
const enList = new Intl.ListFormat('en-US', { 
  style: 'long', 
  type: 'conjunction' 
});
console.log(enList.format(fruits)); // "apples, oranges, and bananas"

// Disjunction (or)
const enDisjunction = new Intl.ListFormat('en-US', { 
  type: 'disjunction' 
});
console.log(enDisjunction.format(fruits)); // "apples, oranges, or bananas"

// Different locale
const esList = new Intl.ListFormat('es-ES', { type: 'conjunction' });
console.log(esList.format(fruits)); // "apples, oranges y bananas"
```

### Intl.PluralRules

Determines which plural form to use for a given number in a specific locale.

```javascript
const pr = new Intl.PluralRules('en-US');

console.log(pr.select(0));   // "other"
console.log(pr.select(1));   // "one"
console.log(pr.select(2));   // "other"

// Ordinal numbers
const prOrdinal = new Intl.PluralRules('en-US', { type: 'ordinal' });
console.log(prOrdinal.select(1));   // "one"   (1st)
console.log(prOrdinal.select(2));   // "two"   (2nd)
console.log(prOrdinal.select(3));   // "few"   (3rd)
console.log(prOrdinal.select(4));   // "other" (4th)
```

### Intl.DisplayNames

Provides translations of language, region, script, and currency names.

```javascript
// Language names
const languageNames = new Intl.DisplayNames(['en-US'], { type: 'language' });
console.log(languageNames.of('fr'));    // "French"
console.log(languageNames.of('es'));    // "Spanish"

// Region names
const regionNames = new Intl.DisplayNames(['en-US'], { type: 'region' });
console.log(regionNames.of('US'));      // "United States"
console.log(regionNames.of('JP'));      // "Japan"

// Currency names
const currencyNames = new Intl.DisplayNames(['en-US'], { type: 'currency' });
console.log(currencyNames.of('USD'));   // "US Dollar"
console.log(currencyNames.of('EUR'));   // "Euro"
```

### Intl.Segmenter

Performs locale-sensitive text segmentation (breaking text into words, sentences, or graphemes).

```javascript
const segmenter = new Intl.Segmenter('en-US', { granularity: 'word' });
const text = "Hello world!";
const segments = segmenter.segment(text);

for (const segment of segments) {
  console.log(segment.segment, segment.isWordLike);
}
// Output:
// "Hello" true
// " " false
// "world" true
// "!" false
```

## Locale Strings

Locales are specified using BCP 47 language tags, which can include:

- Language code: `en`, `fr`, `de`, `ja`
- Region code: `en-US`, `en-GB`, `fr-FR`, `de-DE`
- Script: `zh-Hans` (Simplified Chinese), `zh-Hant` (Traditional Chinese)
- Extensions: `en-US-u-ca-buddhist` (Buddhist calendar)

You can provide an array of locales as fallbacks:

```javascript
const formatter = new Intl.DateTimeFormat(['fr-CA', 'fr-FR', 'fr']);
// Uses the first supported locale
```

## Common Options

Many Intl formatters share common options:

- `localeMatcher`: `"best fit"` (default) or `"lookup"`
- `numeric`: `"always"` or `"auto"` (for RelativeTimeFormat)
- `style`: `"long"`, `"short"`, or `"narrow"`

## Browser Support

The Intl API has excellent browser support. All modern browsers (Chrome, Firefox, Safari, Edge) and Node.js (v13+) support the core features. Some newer features like `Intl.Segmenter` have more limited support but are progressively being adopted.

[Unverified] You can check current browser support on caniuse.com or MDN for specific Intl objects.

## Performance Considerations

Creating Intl formatters can be expensive. For better performance, create formatter instances once and reuse them:

```javascript
// Less efficient
function formatPrice(price) {
  return new Intl.NumberFormat('en-US', { 
    style: 'currency', 
    currency: 'USD' 
  }).format(price);
}

// More efficient
const priceFormatter = new Intl.NumberFormat('en-US', { 
  style: 'currency', 
  currency: 'USD' 
});

function formatPrice(price) {
  return priceFormatter.format(price);
}
```

## Practical Use Cases

**E-commerce**: Format prices in local currencies with proper symbols and decimal separators.

**Date pickers**: Display dates in the user's preferred format.

**Sorting**: Sort names, addresses, or other text correctly for different languages.

**Localized content**: Show relative times ("2 hours ago"), formatted lists, and proper plural forms in user interfaces.

**Global applications**: Display language and country names in the user's language.

The Intl API removes the need for many third-party internationalization libraries and provides a standardized way to handle locale-specific formatting across different JavaScript environments.