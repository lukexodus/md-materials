# Syllabus

## Module 1: Internationalization Fundamentals

- What is internationalization (i18n)
- What is localization (l10n)
- What is globalization (g11n)
- i18n vs l10n distinctions
- Business case for internationalization
- Common internationalization challenges
- Internationalization strategy planning
- Locale concept and definition

## Module 2: Unicode Standard

- Universal character encoding standard
- Unicode Consortium and governance
- Unicode versions and evolution (current: Unicode 16.0)
- Unicode character set structure
- Code points and code units
- Unicode planes (BMP, SMP, SIP, etc.)
- Unicode blocks and categories
- Unicode normalization forms (NFC, NFD, NFKC, NFKD)
- Grapheme clusters
- Combining characters
- Unicode equivalence
- Private Use Areas
- Variation selectors
- Unicode Technical Reports (UTR)
- Unicode Standard Annexes (UAX)

## Module 3: Character Encodings

- UTF-8 encoding (standard for web)
- UTF-16 encoding
- UTF-32 encoding
- ASCII and extended ASCII
- ISO-8859 family
- Windows code pages
- Legacy encodings
- Byte Order Mark (BOM)
- Encoding detection
- Encoding conversion
- Character set declaration in HTML
- HTTP charset parameter
- Encoding mismatches and mojibake

## Module 4: Language and Locale Identification

- IETF BCP 47 language tags
- RFC 5646 specification
- Language subtags
- Script subtags (ISO 15924)
- Region subtags (ISO 3166-1)
- Variant subtags
- Extension subtags
- Private use subtags
- Grandfathered tags
- Language tag canonicalization
- Language matching algorithms
- Locale identifiers (POSIX, CLDR)
- ISO 639 language codes
- ISO 3166 country codes

## Module 5: ICU (International Components for Unicode)

- ICU project overview
- ICU libraries (ICU4C, ICU4J)
- ICU data files
- ICU locale data
- ICU4X (modern Rust implementation)
- ICU services overview
- ICU version management
- ICU integration strategies
- Performance considerations

## Module 6: Text Direction and Bidirectionality

- Left-to-Right (LTR) scripts
- Right-to-Left (RTL) scripts
- Bidirectional text (bidi)
- Unicode Bidirectional Algorithm (UBA)
- Bidi control characters (LRE, RLE, PDF, LRO, RLO, LRI, RLI, FSI, PDI, ALM)
- HTML dir attribute
- CSS direction property
- CSS unicode-bidi property
- Logical vs physical properties
- RTL layout considerations
- Mixed directionality handling
- Bidi isolation
- Bidi override

## Module 7: Text Rendering and Typography

- Font selection and fallback
- Web fonts for international content
- Font subsetting strategies
- Variable fonts for multiple scripts
- OpenType features
- Ligatures across scripts
- Diacritics and combining marks
- Complex script rendering (Arabic, Indic, Thai)
- Text shaping engines (HarfBuzz)
- Vertical text layout
- Ruby annotations (East Asian)
- Line breaking rules
- Hyphenation
- Text justification
- Letter spacing considerations

## Module 8: JavaScript Internationalization API (Intl)

- Intl namespace overview
- Browser support and polyfills
- Intl.Collator for string comparison
- Intl.DateTimeFormat for date/time formatting
- Intl.NumberFormat for number formatting
- Intl.PluralRules for pluralization
- Intl.RelativeTimeFormat for relative time
- Intl.ListFormat for list formatting
- Intl.DisplayNames for language/region names
- Intl.Locale for locale information
- Intl.Segmenter for text segmentation
- Intl.DurationFormat (proposal)
- Options and configuration

## Module 9: Date and Time Internationalization

- Time zones and UTC
- IANA Time Zone Database (tzdata)
- Temporal API (TC39 proposal)
- Date formatting patterns
- Time formatting patterns
- 12-hour vs 24-hour formats
- Week start day variations
- Calendar systems (Gregorian, Islamic, Hebrew, Buddhist, Japanese)
- Era handling
- Date range formatting
- Relative time expressions
- Time zone name formatting
- Daylight saving time handling
- Date parsing considerations
- ISO 8601 standard

## Module 10: Number and Currency Formatting

- Number formatting patterns
- Decimal separators
- Thousands separators
- Numbering systems (Arabic, Latin, others)
- Currency symbols and codes (ISO 4217)
- Currency placement
- Currency decimal places
- Accounting notation
- Compact notation (1K, 1M)
- Scientific notation
- Percentage formatting
- Unit formatting
- Significant digits
- Rounding modes
- Sign display options

## Module 11: Text Collation and Sorting

- Collation concept
- Unicode Collation Algorithm (UCA)
- Case sensitivity in sorting
- Accent sensitivity
- Numeric sorting
- Punctuation handling
- Locale-specific sorting rules
- Phonebook vs dictionary sorting
- Search vs sort collation
- String comparison performance
- Natural sort order
- Custom collation rules

## Module 12: Pluralization

- Plural rules across languages
- CLDR plural categories (zero, one, two, few, many, other)
- Ordinal numbers
- Cardinal numbers
- Plural rule selection
- Message formatting with plurals
- Nested pluralization
- Plural ranges
- Language-specific plural complexity
- Grammatical gender interaction

## Module 13: Translation Management

- Translation workflow
- Translation keys vs natural keys
- Namespacing strategies
- Context for translators
- Translation memory systems (TMS)
- Computer-Assisted Translation (CAT) tools
- Machine translation integration
- Translation Quality Assurance
- Pseudo-localization
- Translation file formats (JSON, XLIFF, PO, YAML)
- String interpolation
- Variable handling in translations
- Placeholder formats

## Module 14: Message Formatting

- ICU MessageFormat syntax
- Simple variable substitution
- Select format (gender, case)
- Plural format
- SelectOrdinal format
- Number formatting in messages
- Date formatting in messages
- Nested formats
- MessageFormat 2.0 (MFWG)
- Format.js library
- fluent-intl (Mozilla Fluent)
- Custom formatters

## Module 15: i18n Libraries and Frameworks

- i18next
- react-intl (Format.js)
- vue-i18n
- angular-i18n
- LinguiJS
- Globalize.js
- Polyglot.js
- Fluent (Mozilla)
- Jed (Gettext in JavaScript)
- ttag (ES6 template strings)
- Library comparison and selection
- Framework-specific considerations

## Module 16: CLDR (Common Locale Data Repository)

- CLDR project overview
- Unicode CLDR structure
- Locale data categories
- Date/time patterns in CLDR
- Number patterns in CLDR
- Currency data
- Language names
- Territory names
- Script names
- Calendar data
- Measurement systems
- First day of week
- CLDR JSON distribution
- CLDR updates and versioning

## Module 17: HTML Internationalization

- lang attribute
- hreflang attribute
- translate attribute
- Content-Language HTTP header
- Accept-Language HTTP header
- Meta charset declaration
- HTML entities
- Named character references
- Numeric character references
- Semantic HTML for i18n
- Ruby elements for annotations
- bdi and bdo elements
- Text-level semantics

## Module 18: CSS Internationalization

- :lang() pseudo-class
- :dir() pseudo-class
- Logical properties (inline-start, block-end)
- Writing modes (horizontal-tb, vertical-rl, vertical-lr)
- Text orientation
- Font-family stacks for multiple scripts
- Locale-specific styling
- CSS Custom Properties for i18n
- quotes property
- hanging-punctuation
- text-combine-upright
- Language-specific line breaking
- word-break property
- overflow-wrap property

## Module 19: Input Methods and Keyboards

- Input Method Editors (IME)
- Composition events
- IME mode considerations
- Virtual keyboards
- Keyboard layouts by locale
- Shortcut key localization
- Input validation across scripts
- Autocomplete considerations
- Search functionality for non-Latin scripts
- Voice input across languages

## Module 20: Accessibility and Internationalization

- WCAG internationalization requirements
- Screen reader language switching
- ARIA labels in multiple languages
- Alt text localization
- Language of parts (lang attribute on elements)
- Pronunciation guidance
- Accessible date pickers
- Form validation messages
- Error message localization
- Keyboard navigation across layouts

## Module 21: Search and Filtering

- Full-text search for international content
- Search index normalization
- Accent-insensitive search
- Case-insensitive search
- Phonetic matching
- Fuzzy matching
- Tokenization for different scripts
- CJK (Chinese, Japanese, Korean) tokenization
- Stop words by language
- Stemming and lemmatization
- Search result ranking
- Elasticsearch i18n features
- Algolia i18n features

## Module 22: Content Management

- Multi-language content storage
- Content translation workflow
- Translation status tracking
- Fallback language chains
- Content variants by locale
- Headless CMS i18n features
- Content synchronization
- Translation versioning
- Content approval workflows
- Translator permissions
- Machine translation integration
- Content localization beyond text

## Module 23: URL Internationalization

- URL structure strategies (subdomain, subdirectory, parameter)
- Internationalized Domain Names (IDN)
- Punycode encoding
- IRI (Internationalized Resource Identifier)
- URL slug localization
- SEO considerations
- hreflang implementation
- Canonical URLs for i18n
- Language detection and redirect
- URL routing patterns

## Module 24: SEO for International Sites

- hreflang tags
- x-default hreflang
- Alternate language versions
- Geographic targeting in Search Console
- Language meta tags
- Content duplication concerns
- International keyword research
- Local search optimization
- Structured data localization
- Sitemap internationalization
- robots.txt considerations
- Core Web Vitals across regions

## Module 25: Email Internationalization

- Email header encoding (RFC 2047)
- MIME encoding
- Subject line internationalization
- From/To name internationalization
- Internationalized email addresses (EAI)
- Email template localization
- RTL email layout
- Email client support variations
- Plain text vs HTML for i18n
- Multilingual email testing

## Module 26: API Internationalization

- Accept-Language header handling
- Content-Language response header
- REST API i18n patterns
- GraphQL i18n patterns
- Error message localization
- API documentation i18n
- Date/time in API responses
- Number formats in APIs
- Currency in API responses
- Locale parameter conventions
- API versioning for i18n

## Module 27: Mobile Internationalization

- iOS localization (NSLocalizedString)
- Android localization (strings.xml)
- React Native i18n
- Flutter internationalization
- Mobile-specific locale detection
- App Store localization
- Google Play localization
- In-app language switching
- Mobile keyboard considerations
- Push notification localization
- Deep link localization
- Mobile analytics for i18n

## Module 28: Images and Media Localization

- Image text alternatives
- Locale-specific images
- Icon localization (culturally appropriate)
- Color symbolism across cultures
- Image direction (RTL mirroring)
- Infographic localization
- Video subtitle formats (SRT, VTT, TTML)
- Audio description localization
- Voiceover localization
- Text in images (avoiding when possible)
- Responsive images for i18n

## Module 29: Forms and Validation

- Name format variations
- Address format variations
- Postal code formats
- Phone number formats (E.164, national)
- Email validation
- Date input formats
- Locale-specific input patterns
- Validation message localization
- Required field indicators
- Form label localization
- Placeholder text localization
- Error message strategies

## Module 30: Legal and Compliance

- GDPR multi-language requirements
- Terms of Service localization
- Privacy Policy localization
- Cookie consent localization
- Legal disclaimer localization
- Age verification by jurisdiction
- Content restrictions by region
- Data residency requirements
- Accessibility law compliance
- Copyright notices

## Module 31: Performance Optimization

- Lazy loading translations
- Translation bundle splitting
- CDN for locale-specific assets
- Caching strategies for i18n
- Reducing translation file size
- Compression techniques
- Critical translation loading
- Translation preloading
- Performance monitoring by locale
- Core Web Vitals impact

## Module 32: Testing Internationalization

- Unit testing i18n functionality
- Visual regression testing
- Screenshot testing for layouts
- RTL testing strategies
- Pseudo-localization testing
- Translation completeness testing
- Locale switching testing
- Character encoding testing
- Browser/device matrix testing
- Automation for i18n testing
- Crowdsourced testing
- Linguistic QA

## Module 33: Geolocation and Localization

- Geolocation API
- IP geolocation
- User locale preference detection
- Browser language detection
- Language negotiation
- Automatic locale selection
- Manual language switcher
- Remembering user preference
- Cookie vs localStorage for locale
- Session-based locale

## Module 34: Cultural Considerations

- Date format preferences (MM/DD/YYYY vs DD/MM/YYYY)
- Color symbolism
- Iconography appropriateness
- Imagery cultural sensitivity
- Gesture meanings
- Number symbolism (lucky/unlucky)
- Formality levels in language
- Honorifics and titles
- Name order (given name vs surname first)
- Measurement units (metric vs imperial)
- Paper sizes (A4, Letter)
- Cultural taboos and sensitivities

## Module 35: E-commerce Internationalization

- Multi-currency support
- Currency conversion
- Tax calculation by region
- Shipping address formats
- Payment method localization
- Price display conventions
- Checkout flow localization
- Invoice localization
- Return policy localization
- Product description translation
- Size chart localization
- Customer service in multiple languages

## Module 36: Analytics and Metrics

- Tracking by locale
- Conversion rates by language
- User engagement by region
- A/B testing across locales
- Translation quality metrics
- Page load time by region
- Bounce rate by language
- Revenue by currency/region
- Customer support tickets by language
- Search queries by locale
- Heatmaps for RTL layouts

## Module 37: Build Tools and Automation

- Webpack i18n plugins
- Vite i18n configuration
- Babel plugins for i18n
- ESLint rules for i18n
- Automated translation extraction
- CI/CD for translations
- Translation file validation
- Automated pseudo-localization
- Translation coverage reports
- Build-time translation compilation
- Static site generation with i18n

## Module 38: Server-Side Internationalization

- Node.js i18n libraries
- Express.js middleware for i18n
- Next.js internationalization
- Nuxt.js i18n module
- Server-side locale detection
- HTTP content negotiation
- Server-side rendering (SSR) considerations
- Edge rendering for i18n
- API-driven translations
- Backend translation services

## Module 39: Cloud and Infrastructure

- CDN configuration for i18n
- Regional server deployment
- Edge computing for locale detection
- Cloud storage for translations
- Translation API services (Google, DeepL, Azure)
- Serverless functions for i18n
- Database locale columns
- Multi-region databases
- Backup strategies for translation data
- Disaster recovery for i18n assets

## Module 40: Emerging Standards and Technologies

- Temporal API for date/time (TC39 Stage 3)
- MessageFormat 2.0 (Unicode MFWG)
- Intl.Segmenter adoption
- WebAssembly for i18n libraries
- AI/ML for translation
- Neural machine translation
- Real-time translation
- Voice-to-voice translation
- AR/VR internationalization
- Web3 and blockchain i18n
- Metaverse localization considerations

## Module 41: Documentation and Team Collaboration

- Developer documentation for i18n
- Translation guidelines for teams
- Style guides by language
- Glossary management
- Translation memory sharing
- Code comments for translators
- Context documentation
- Change management process
- Translator onboarding
- Cross-functional collaboration
- Version control for translations

## Module 42: Real-World Case Studies

- Large-scale i18n implementations
- Migration from monolingual to multilingual
- RTL implementation challenges
- CJK implementation lessons
- Simultaneous multi-market launch
- Post-launch optimization
- Translation cost optimization
- Performance optimization case studies
- Failed i18n projects (lessons learned)
- Success stories and best practices

## Module 43: Project Implementations

- Multi-language blog
- E-commerce site with currency switching
- SaaS application with full i18n
- Social media platform localization
- Real-time chat with translation
- Documentation site (multiple languages)
- Marketing landing pages (A/B tested by locale)
- Mobile app with 10+ languages
- Dashboard with RTL support
- Government website (accessibility + i18n)
- Game localization
- Streaming platform with subtitles