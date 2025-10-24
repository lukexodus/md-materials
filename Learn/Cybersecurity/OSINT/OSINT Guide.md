# Syllabus

## Module 1: Foundations

- Introduction to OSINT
- OSINT framework and methodology
- Legal and ethical considerations
- Privacy laws and boundaries
- Documentation and note-taking systems

## Module 2: Search Engine Intelligence

- Advanced Google dorking
- Alternative search engines
- Cached and archived content
- Reverse image search techniques
- Custom search operators

## Module 3: Social Media Intelligence

- Platform-specific OSINT (Twitter/X, Facebook, Instagram, LinkedIn, TikTok)
- Username enumeration
- Profile analysis techniques
- Social network mapping
- Geolocation from social media

## Module 4: Image and Video Analysis

- Metadata extraction (EXIF, XMP)
- Reverse image searching
- Image manipulation detection
- Geolocation from visual clues
- Video frame analysis
- Facial recognition tools

## Module 5: Domain and IP Intelligence

- WHOIS lookups
- DNS enumeration
- Subdomain discovery
- Certificate transparency logs
- IP geolocation
- ASN lookups
- Historical domain data

## Module 6: Email Intelligence

- Email header analysis
- Email validation and verification
- Breach database searches
- Email tracking and tracing
- Disposable email detection

## Module 7: Username and Identity Intelligence

- Username correlation across platforms
- Identity linking techniques
- People search engines
- Public records databases
- Background check resources

## Module 8: Geolocation Techniques

- GPS coordinate analysis
- Landmark identification
- Flora and fauna analysis
- Architecture and infrastructure recognition
- Timezone analysis
- Language and signage clues
- Shadow analysis
- Weather correlation

## Module 9: Document Intelligence

- Document metadata analysis
- PDF forensics
- Document dating techniques
- Authorship attribution
- Document format analysis

## Module 10: Web Archives and Historical Data

- Wayback Machine techniques
- Archive.today usage
- Historical website analysis
- Cached content recovery
- Timeline reconstruction

## Module 11: Dark Web and Hidden Services

- Tor network basics
- .onion site discovery
- Dark web search engines
- Paste site monitoring
- Anonymous communication analysis

## Module 12: Cryptography in OSINT

- Basic encoding schemes (Base64, Hex, etc.)
- Hash identification
- Steganography detection
- PGP key analysis
- Blockchain analysis basics

## Module 13: Network Analysis

- Open port scanning ethics and techniques
- Network mapping
- WiFi geolocation
- MAC address analysis
- Network device fingerprinting

## Module 14: Mobile and App Intelligence

- Mobile OSINT techniques
- App permission analysis
- Mobile device tracking
- Bluetooth tracking
- Mobile metadata

## Module 15: Automation and Tooling

- Python for OSINT automation
- API integration
- Web scraping fundamentals
- Custom tool development
- Workflow automation

## Module 16: Data Analysis and Visualization

- Link analysis
- Timeline creation
- Relationship mapping
- Graph databases
- Data correlation techniques

## Module 17: Specialized OSINT

- Aviation tracking
- Maritime tracking
- Satellite imagery analysis
- Radio frequency analysis
- Financial intelligence

## Module 18: CTF-Specific Techniques

- Common CTF challenge types
- Flag format recognition
- Puzzle-solving approaches
- Time management strategies
- Collaboration in team CTFs

## Module 19: Verification and Validation

- Source credibility assessment
- Cross-referencing techniques
- Fact-checking methodologies
- Misinformation detection
- Deepfake detection

## Module 20: Operational Security

- Protecting your identity during OSINT
- VPN and proxy usage
- Browser fingerprinting prevention
- Secure research environments
- Digital footprint minimization

---

# Foundations

## Introduction to OSINT

Open Source Intelligence (OSINT) involves collecting, analyzing, and exploiting publicly available information to achieve intelligence objectives. In CTF contexts, OSINT challenges require extracting actionable data from publicly accessible sources without unauthorized system access.

**Core OSINT Principles:**

- **Passive reconnaissance**: Gathering information without direct target interaction
- **Public data exploitation**: Leveraging legally accessible information sources
- **Information correlation**: Connecting disparate data points to form intelligence
- **Digital footprint analysis**: Mapping target presence across platforms

**CTF OSINT Categories:**

- **Personnel intelligence**: Individual identification, social media profiling, credential discovery
- **Infrastructure intelligence**: Domain enumeration, network mapping, service identification
- **Corporate intelligence**: Organization structure, business relationships, technology stacks
- **Geospatial intelligence**: Location data, metadata extraction, physical asset mapping
- **Temporal intelligence**: Historical data, archived content, timeline reconstruction

**Key Difference from Active Reconnaissance:** OSINT maintains passive interaction—you observe but don't probe. Active reconnaissance (port scanning, vulnerability testing) generates target-detectable traffic. CTF OSINT challenges typically prohibit direct target engagement.

## OSINT Framework and Methodology

### Intelligence Cycle

**1. Planning and Direction**

- Define intelligence requirements (PIRs - Priority Intelligence Requirements)
- Establish collection objectives
- Identify constraint boundaries (legal, temporal, scope)
- Document success criteria

**2. Collection**

- Execute source enumeration
- Apply specialized tools and techniques
- Maintain operational security during collection
- Preserve evidence chain and metadata

**3. Processing**

- Normalize collected data formats
- Extract relevant information from raw data
- Tag and categorize findings
- Remove duplicates and noise

**4. Analysis**

- Correlate data points across sources
- Identify patterns and anomalies
- Validate information authenticity
- Generate hypotheses and test them

**5. Dissemination**

- Document findings with evidence
- Present actionable intelligence
- Format for technical and non-technical audiences
- Archive for future reference

**6. Feedback**

- Evaluate collection effectiveness
- Refine search parameters
- Identify intelligence gaps
- Iterate methodology

### OSINT Collection Layers

**Layer 1: Surface Web**

- Search engines (Google, Bing, DuckDuckGo, Yandex)
- Public websites and web applications
- Social media platforms
- Public databases and repositories

**Layer 2: Deep Web**

- Authenticated platforms (LinkedIn, specialized databases)
- Paywalled content
- Dynamic web applications
- Member-only forums

**Layer 3: Technical Infrastructure**

- DNS records and WHOIS data
- Certificate transparency logs
- Network routing information
- Public code repositories

**Layer 4: Archived Content**

- Web archives (Wayback Machine)
- Cached pages
- Historical snapshots
- Deleted or modified content

### Structured Collection Methodology

**Source Prioritization Matrix:**

- **Reliability**: Assess source credibility and accuracy history
- **Relevance**: Measure information pertinence to objectives
- **Timeliness**: Evaluate data freshness and validity period
- **Accessibility**: Consider collection difficulty and resource requirements

**Data Validation Framework:**

- **Primary source verification**: Confirm information at origin
- **Cross-source corroboration**: Validate across independent sources (minimum 3 sources recommended)
- **Metadata analysis**: Examine creation dates, authors, modification history
- **Logical consistency**: Check for internal contradictions

## Legal and Ethical Considerations

### Legal Framework

**Computer Fraud and Abuse Act (CFAA) - US**

- Prohibits unauthorized access to computer systems
- OSINT compliance: Only access publicly available information
- Violation risk: Bypassing authentication, exploiting vulnerabilities during reconnaissance
- CTF context: Competition rules supersede external laws within sandboxed environments

**General Data Protection Regulation (GDPR) - EU**

- Regulates personal data processing
- OSINT impact: Limits collection and storage of EU resident data
- Compliance: Document legitimate interest, respect data subject rights
- [Unverified]: Specific GDPR applicability to CTF scenarios depends on competition jurisdiction and data handling

**Computer Misuse Act 1990 - UK**

- Criminalizes unauthorized computer access
- OSINT boundaries: No unauthorized access, no modification attempts
- Relevant sections: Section 1 (unauthorized access), Section 3 (unauthorized modification)

**Country-Specific Variations:** Different jurisdictions define "public" differently. German law treats public social media profiles differently than US law. Australian Cybercrime Act 2001 has specific provisions about reconnaissance activities.

[Unverified]: Specific legal outcomes depend on jurisdiction, prosecution discretion, and case circumstances. Consult legal counsel for operational deployments.

### Ethical Guidelines

**Core Ethical Principles:**

**1. Proportionality**

- Collection scope matches legitimate objectives
- Avoid excessive information gathering
- Minimize collateral information exposure

**2. Transparency**

- Document collection methods
- Disclose capabilities to stakeholders
- Operate within declared boundaries

**3. Privacy Respect**

- Minimize personal information collection
- Avoid doxing or personal harassment
- Consider information sensitivity context

**4. Non-maleficence**

- Don't cause harm through information disclosure
- Avoid enabling harassment or violence
- Consider downstream consequences

**5. Accountability**

- Maintain audit trails
- Accept responsibility for collection actions
- Report misuse or ethical violations

### CTF-Specific Considerations

**Authorized Scope:**

- Competition rules define legal boundaries
- Sandboxed environments create safe testing spaces
- Out-of-scope targets remain legally protected
- Written authorization doesn't negate criminal statutes in some jurisdictions

**Common Ethical Dilemmas:**

_Scenario: Personal information discovered during challenge_

- Ethical response: Extract only competition-relevant data
- Avoid: Sharing, storing, or exploiting personal information beyond challenge requirements

_Scenario: Vulnerable third-party service discovered_

- Ethical response: Report to competition organizers
- Avoid: Exploiting vulnerability, accessing unauthorized systems

_Scenario: Real credentials found in misconfigured repository_

- Ethical response: Notify affected party through responsible disclosure
- Avoid: Testing credentials, accessing accounts, sharing credentials

## Privacy Laws and Boundaries

### Information Classification

**Public Information:**

- Intentionally published without access restrictions
- Accessible through standard web browsers
- No authentication required
- Examples: Public social media posts, company websites, public registries

**Semi-Public Information:**

- Requires basic authentication (free account)
- Published with limited distribution intent
- Examples: LinkedIn profiles (require account), forum posts (registration required)

**Private Information:**

- Requires specific authorization or payment
- Protected by access controls
- Examples: Private repositories, authenticated APIs, paywalled databases

**OSINT Compliance**: Operate within public and semi-public boundaries. Private information access without authorization violates CFAA and equivalent laws.

### Privacy Law Intersection

**Personally Identifiable Information (PII):**

- **Direct identifiers**: Name, SSN, email, phone, physical address
- **Indirect identifiers**: IP address, device ID, location history, biometrics
- **Sensitive categories**: Health data, financial information, biometric data, children's data

**Collection Limitations:**

GDPR Article 6 requires lawful basis:

- Consent (explicit for OSINT: rare)
- Legitimate interest (must document and balance)
- Legal obligation
- Vital interests
- Public task
- Contract performance

**California Consumer Privacy Act (CCPA):**

- Applies to California residents
- Grants deletion, access, and opt-out rights
- Business definitions may include CTF organizations [Unverified]

**Health Insurance Portability and Accountability Act (HIPAA) - US:**

- Protects health information
- Applies to covered entities (healthcare providers, insurers)
- OSINT impact: Publicly available health information isn't HIPAA-protected, but ethical concerns remain

### Operational Boundaries

**Red Lines - Never Cross:**

- Unauthorized system access (even if misconfigured)
- Authentication bypass or credential stuffing
- Exploitation of vulnerabilities for access
- Social engineering for credential harvesting
- Intercepting private communications
- Accessing private accounts or databases

**Gray Zones - Exercise Caution:**

- Automated scraping (check Terms of Service, robots.txt)
- Public API abuse (respect rate limits, intended use)
- Archived private content (was it legitimately public?)
- Aggregating public data to reveal sensitive patterns
- Accessing misconfigured but not intentionally public resources

**Best Practices:**

- Check `robots.txt` before automated collection
- Review Terms of Service for platforms
- Respect rate limiting and anti-scraping measures
- Document access method and timestamp
- If uncertain, assume restricted

## Documentation and Note-Taking Systems

### Why Documentation Matters

**Evidence Chain:**

- Validate findings with reproducible evidence
- Support report credibility with source attribution
- Enable technique replication
- Defend against disputes or challenges

**Knowledge Management:**

- Track collection progress
- Prevent duplicate effort
- Enable collaboration
- Support post-operation analysis

**Legal Protection:**

- Demonstrate authorized scope compliance
- Prove ethical collection methods
- Establish timeline of activities
- Document reasonable care

### Documentation Framework

**Minimum Information Requirements:**

**For Each Finding:**

- **What**: Specific information discovered
- **Where**: Source URL, platform, location
- **When**: Collection timestamp (UTC recommended)
- **How**: Collection method and tools used
- **Evidence**: Screenshot, raw data, archive link

**Recommended Additional Fields:**

- Source reliability assessment
- Cross-reference to related findings
- Verification status
- Sensitivity classification
- Follow-up actions needed

### Note-Taking Tools

**Structured Options:**

**CherryTree**

- Hierarchical note organization
- Syntax highlighting for code/commands
- Screenshot embedding
- Encryption support
- Export: HTML, PDF, plain text
- Best for: Detailed technical documentation with code snippets

**Obsidian**

- Markdown-based linking
- Graph view for relationship visualization
- Plugin ecosystem for CTF workflows
- Local storage with optional sync
- Best for: Connection-focused intelligence analysis

**Joplin**

- Open-source Evernote alternative
- Markdown support
- End-to-end encryption
- Multi-device synchronization
- Web clipper browser extension
- Best for: Cross-platform synchronized collection

**Notion**

- Database-driven organization
- Collaborative features
- Template support
- API for automation
- Cloud-based storage [Privacy consideration]
- Best for: Team-based CTF operations

**Specialized OSINT Tools:**

**Maltego**

- Graph-based visualization
- Entity relationship mapping
- Transform automation
- Evidence linking
- Export: Graph images, CSV, XML
- Best for: Complex relationship analysis

**Hunchly**

- Browser-based automatic capture
- Timeline reconstruction
- Full-page archiving
- Keyword tagging
- Best for: Web-based investigation documentation

**Recon-ng**

- Command-line framework
- Modular data collection
- Automatic database storage
- Report generation
- Best for: Automated reconnaissance documentation

### Documentation Templates

**Basic Finding Template:**

```
Title: [Descriptive finding name]
Date/Time: [ISO 8601 format: 2025-10-20T14:30:00Z]
Source: [Full URL or platform identifier]
Collection Method: [Tool/technique used]
Reliability: [High/Medium/Low + justification]
Verification: [Corroborated/Uncorroborated]

Content:
[Actual information discovered]

Evidence:
[Screenshot filename/path or archived URL]

Related Findings:
[Links to connected discoveries]

Notes:
[Context, analysis, follow-up needed]
```

**Investigation Log Template:**

```
Operation: [CTF Challenge Name]
Date Range: [Start - End]
Scope: [Defined boundaries]

Timeline:
[HH:MM] - Action taken
[HH:MM] - Finding discovered
[HH:MM] - Dead end / pivot point

Sources Checked:
- [Source 1] - [Result]
- [Source 2] - [Result]

Key Findings:
1. [Finding with evidence reference]
2. [Finding with evidence reference]

Next Steps:
- [Action item 1]
- [Action item 2]
```

### Screenshot and Evidence Management

**Screenshot Best Practices:**

- Capture full page including URL bar
- Include timestamp (system time visible)
- Show source URL clearly
- Capture before interaction (prove initial state)
- Use annotation tools to highlight relevant sections
- Save in lossless format (PNG preferred)

**File Naming Convention:**

```
[Date]_[Source]_[Description].[ext]
Example: 20251020_LinkedIn_JohnDoe_Employment.png
```

**Archive Strategy:**

- Save web pages with browser "Save As Complete"
- Use archive.org Wayback Machine for persistence
- Screenshot dynamic content (may not archive properly)
- Export social media posts (screenshots + HTML source)
- Store raw API responses when applicable

**Evidence Storage:**

- Organized directory structure by challenge/target
- Encrypted container for sensitive findings
- Cloud backup with access controls
- Version control for evolving investigations (Git for text-based notes)

### Operational Security in Documentation

**Information Sensitivity:**

- Mark sensitive findings appropriately
- Encrypt notes containing credentials or PII
- Sanitize screenshots before sharing
- Redact non-essential personal information

**Tool Selection Considerations:**

- Local vs. cloud storage (privacy/availability tradeoff)
- Encryption at rest and in transit
- Access control capabilities
- Audit logging for team environments

**Common Mistakes:**

- Documenting without timestamps (loses temporal context)
- Missing source attribution (evidence becomes unverifiable)
- Storing only screenshots without URLs (prevents verification)
- Insufficient context (findings make no sense later)
- No backup strategy (single point of failure)

---

**Important Related Topics:**

- **Search Engine Operators**: Advanced Google dorking, specialized search engines, query optimization
- **Metadata Analysis**: EXIF data extraction, document metadata, timestamp forensics

- **Social Media Intelligence (SOCMINT)**: Platform-specific techniques, relationship mapping, 
- temporal analysis

---

# Search Engine Intelligence

## Advanced Google Dorking

Google dorking uses specialized search operators to uncover information not easily accessible through standard searches. These operators filter results by file types, domains, URL structures, and page content.

### Core Search Operators

**site:** - Restricts results to specific domain or TLD

```
site:example.com password
site:gov filetype:pdf
site:.edu inurl:admin
```

**filetype:** or **ext:** - Searches for specific file extensions

```
filetype:pdf "confidential"
filetype:sql "INSERT INTO"
filetype:log inurl:access
ext:txt inurl:passwords
```

**inurl:** - Searches for terms in URL

```
inurl:admin
inurl:/wp-admin/ inurl:login
inurl:"/view/index.shtml"
```

**intext:** - Searches for terms in page body

```
intext:"Index of /" "parent directory"
intext:"SQL syntax" mysql
```

**intitle:** - Searches for terms in page title

```
intitle:"index of" "parent directory"
intitle:"login" intitle:"admin"
```

**cache:** - Shows Google's cached version

```
cache:example.com
```

**allintitle:** - All terms must appear in title

```
allintitle:admin panel login
```

**allinurl:** - All terms must appear in URL

```
allinurl:admin config
```

**allintext:** - All terms must appear in body

```
allintext:username password email
```

### Combining Operators

Operators can be chained for precision targeting:

```
site:example.com filetype:pdf confidential
site:*.example.com inurl:admin -inurl:public
inurl:login filetype:php site:gov
intitle:"index of" "backup" filetype:sql
```

### Exclusion Operator

The minus sign (-) excludes terms:

```
site:example.com -www
"password" -reset -forgot
filetype:pdf -site:example.com
```

### Wildcard Operator

Asterisk (*) acts as wildcard:

```
"admin * password"
site:*.gov "internal use only"
```

### CTF-Relevant Dork Patterns

**Configuration Files**

```
filetype:env "DB_PASSWORD"
filetype:config inurl:web.config
ext:xml inurl:web.config
filetype:ini inurl:config
```

**Database Files**

```
filetype:sql "CREATE TABLE"
filetype:sql "INSERT INTO" "VALUES"
ext:db | ext:sql | ext:sqlite
```

**Log Files**

```
filetype:log inurl:access.log
ext:log "username" "password"
allintext:error log "line" "syntax"
```

**Backup Files**

```
filetype:bak inurl:backup
filetype:old | filetype:backup
intitle:"index of" "backup"
ext:tar | ext:zip | ext:tgz backup
```

**Exposed Directories**

```
intitle:"Index of /" +.htaccess
intitle:"index of" "parent directory"
"Index of /" +apache +port +server
```

**Login Pages**

```
inurl:login | inurl:signin | inurl:admin
intitle:"Login" "admin panel"
inurl:wp-admin | inurl:administrator
```

**Configuration Interfaces**

```
inurl:"/cgi-bin/" ext:cgi
intitle:"Apache Status" "Apache Server Status"
intitle:"phpMyAdmin" "Welcome to phpMyAdmin"
```

**API Keys and Credentials**

```
"api_key" | "apikey" filetype:json
"private_key" filetype:pem
filename:credentials filetype:yml
```

**Version Disclosure**

```
intitle:"Apache2 Ubuntu Default Page"
"powered by" "version"
inurl:readme.txt "version"
```

## Alternative Search Engines

While Google is dominant, alternative search engines provide different indexing, privacy features, and specialized capabilities useful for OSINT.

### Bing

Microsoft's search engine with unique indexing and operators.

**Unique Operators:**

```
ip:192.168.1.1 - Find pages on specific IP
feed:example.com - Find RSS feeds
hasfeed:example.com - Sites with RSS feeds
url:example.com - Pages from specific domain
```

**Standard Operators:**

```
site:example.com
filetype:pdf
inurl:admin
intitle:login
```

Bing often indexes different content than Google and may reveal pages Google has deindexed.

### DuckDuckGo

Privacy-focused search with !bang syntax for direct searches.

**!bangs (shortcuts to other sites):**

```
!gi search term - Google Images
!gh search term - GitHub
!w search term - Wikipedia
!so search term - Stack Overflow
```

**Standard Operators:**

```
site:example.com
filetype:pdf
intitle:
```

[Inference] DuckDuckGo's lack of personalization may provide more neutral results, though this is not independently verified for all query types.

### Yandex

Russian search engine with strong image recognition and Eastern European content coverage.

**Advantages:**

- Extensive indexing of Russian and CIS websites
- Powerful reverse image search
- Different crawling patterns from Western engines

**Operators:**

```
site:example.com
mime:pdf
inurl:admin
title:login
```

### Baidu

Chinese search engine essential for Chinese website reconnaissance.

**Use cases:**

- Chinese language content
- .cn domain research
- Content blocked by Great Firewall
- Chinese social media platforms

**Note:** Interface primarily in Chinese; translation tools helpful.

### Shodan

Search engine for Internet-connected devices and services.

**Basic Queries:**

```
apache
port:22
country:US
city:"San Francisco"
hostname:example.com
```

**Combined Queries:**

```
apache country:US
port:3389 city:London
"default password" port:23
```

**Filters:**

```
port: - Specific port number
net: - Network range (CIDR)
city: - Geographic location
country: - Country code
os: - Operating system
hostname: - Hostname search
org: - Organization name
product: - Product name
version: - Product version
before/after: - Date range
```

**CTF Examples:**

```
hostname:ctf.example.com
"HTTP/1.1 200 OK" port:8080
"Server: nginx" country:US
```

**Access:** Requires account; basic searches free, advanced features require paid membership.

### Censys

Internet-wide scanning platform similar to Shodan with certificate focus.

**Query Syntax:**

```
services.service_name: http
autonomous_system.asn: 15169
location.country: "United States"
protocols: ("443/https")
```

**Certificate Searches:**

```
parsed.subject.common_name: example.com
parsed.extensions.subject_alt_name.dns_names: *.example.com
```

**Access:** Free tier available; requires account.

### ZoomEye

Chinese alternative to Shodan with device and web service search.

**Search Types:**

- Host search (devices)
- Web search (websites)

**Filters:**

```
app:
ver:
os:
country:
city:
port:
```

### FOFA

Search engine for cyberspace mapping, popular in Chinese security community.

**Search Syntax:**

```
domain="example.com"
host="192.168.1.1"
port="80"
protocol="http"
country="CN"
```

### Wayback Machine (Archive.org)

Not a traditional search engine but critical for historical content.

**Access Methods:**

```
web.archive.org/web/*/example.com
```

**CDX Server API:**

```
web.archive.org/cdx/search/cdx?url=example.com&output=json
```

**Parameters:**

- url: target URL
- matchType: exact, prefix, host, domain
- from/to: timestamp range (YYYYMMDD)
- output: json, csv
- fl: field list (timestamp, original, mimetype)

## Cached and Archived Content

Cached and archived versions preserve historical states of web content, revealing deleted information, previous configurations, and timeline changes.

### Google Cache

Google stores snapshots of crawled pages.

**Access Methods:**

Direct URL:

```
webcache.googleusercontent.com/search?q=cache:example.com
```

Search operator:

```
cache:example.com
```

**Limitations:**

- Cache age varies (days to weeks)
- Not all pages cached
- JavaScript-heavy sites may render incompletely

**Text-only cache** often reveals content hidden by CSS/JavaScript.

### Bing Cache

Similar to Google but different crawl schedule.

**Access:** Click arrow next to search result → Cached page

### Wayback Machine (Internet Archive)

Most comprehensive web archival service with historical snapshots dating to 1996.

**Manual Access:**

```
https://web.archive.org/web/*/example.com
```

**Calendar Interface** shows all available snapshots by date.

**Wayback Machine API:**

```bash
# Get availability
curl "http://archive.org/wayback/available?url=example.com"

# CDX API - List all captures
curl "http://web.archive.org/cdx/search/cdx?url=example.com&output=json"

# Specific timestamp
curl "http://web.archive.org/web/20200101000000/example.com"
```

**CDX API Parameters:**

- `url`: target URL
- `matchType`: exact, prefix, host, domain
- `from`: start timestamp (YYYYMMDDhhmmss)
- `to`: end timestamp
- `filter`: filter results (e.g., `statuscode:200`)
- `collapse`: collapse similar results
- `output`: json, csv, text
- `fl`: fields to return (timestamp, original, mimetype, statuscode, digest, length)

**Example - Find all PDFs:**

```bash
curl "http://web.archive.org/cdx/search/cdx?url=example.com/*&output=json&filter=mimetype:application/pdf"
```

### Archive.today (archive.is/archive.ph)

On-demand archival service providing permanent snapshots.

**Features:**

- User-submitted archives
- Bypasses some paywalls
- Captures JavaScript-rendered content
- Provides screenshot

**Access:**

```
https://archive.today/example.com
```

Shows all archived versions if they exist.

**Create archive:** Submit URL through archive.today homepage.

### Cached View

Aggregator showing cached versions from multiple sources.

**URL:**

```
cachedview.com
```

Checks Google Cache, Wayback Machine, and others simultaneously.

### Tools for Automated Archive Retrieval

**waybackpack** - Download Wayback Machine archives:

```bash
pip install waybackpack

# Download all versions
waybackpack example.com -d ./output

# Specific date range
waybackpack example.com --from-date 20200101 --to-date 20201231

# Specific URL
waybackpack example.com/admin --raw
```

**waybackurls** - Extract archived URLs:

```bash
go install github.com/tomnomnom/waybackurls@latest

# Get all URLs
echo "example.com" | waybackurls

# Filter for specific paths
echo "example.com" | waybackurls | grep -i admin
```

**gau (GetAllUrls)** - Fetch URLs from multiple sources:

```bash
go install github.com/lc/gau/v2/cmd/gau@latest

# Get URLs from Wayback, Common Crawl, etc.
gau example.com

# Filter by extension
gau example.com | grep -E "\.(php|asp|aspx|jsp)$"
```

### CTF Application Strategies

**Deleted Content Recovery:** Check archives for:

- Removed admin panels
- Deleted credential files
- Previous configuration files
- Old API endpoints

**Timeline Analysis:** Compare versions to identify:

- When specific content appeared/disappeared
- Configuration changes
- Exposed credentials in earlier versions

**Subdomain Discovery:**

```bash
waybackurls example.com | unfurl domains | sort -u
```

**Parameter Discovery:**

```bash
waybackurls example.com | grep "?" | cut -d "?" -f 2 | cut -d "=" -f 1 | sort -u
```

**JavaScript File Analysis:** Old JavaScript files may contain:

- Commented-out API keys
- Previous API endpoints
- Debug information
- Source maps

## Reverse Image Search Techniques

Reverse image search identifies image sources, related images, and metadata to reveal context, origin, and modifications.

### Google Images Reverse Search

**Methods:**

1. Upload image at images.google.com → camera icon
2. Right-click image in browser → "Search image with Google"
3. Direct URL:

```
https://images.google.com/searchbyimage?image_url=URL_HERE
```

**Use Cases:**

- Identify location from photo
- Find original unmodified image
- Discover source website
- Find higher resolution versions

### Bing Visual Search

**Access:** bing.com/visualsearch → upload or paste URL

**Features:**

- Similar images
- Related content
- Shopping results (for products)

### Yandex Images

**Particularly effective for:**

- Face recognition
- Eastern European content
- Cyrillic text in images

**Access:** yandex.com/images → camera icon

[Inference] Yandex's facial recognition appears more aggressive than Western alternatives, though comparative accuracy metrics are not independently verified.

### TinEye

Specialized reverse image search focusing on exact and modified matches.

**Features:**

- Oldest/newest instances
- Most changed/edited versions
- Color search
- API access

**URL:**

```
https://tineye.com
```

**TinEye API (requires paid account):**

```bash
curl "https://api.tineye.com/rest/search/?image_url=URL&api_key=KEY&api_sig=SIG"
```

### Specialized Reverse Image Tools

**PimEyes** - Face recognition search:

- Searches faces across web
- Requires account for full results
- Privacy concerns noted

**Social Catfish** - Social media image search:

- Focuses on dating/social media profiles
- Paid service

**Baidu Images** - Chinese content:

- Strong for Chinese websites
- Interface in Chinese

### Metadata Extraction

Before or alongside reverse search, extract metadata.

**ExifTool:**

```bash
exiftool image.jpg

# Extract GPS coordinates
exiftool -GPS* image.jpg

# Extract all metadata to text
exiftool -a image.jpg > metadata.txt

# Extract specific fields
exiftool -Make -Model -DateTimeOriginal image.jpg
```

**Common Metadata:**

- GPS coordinates (latitude/longitude)
- Camera make/model
- Software used
- Creation/modification dates
- Author/copyright info
- Original filename

### OSINT Techniques with Images

**Geolocation from Images:**

1. **EXIF GPS Data:**

```bash
exiftool -GPS* image.jpg
```

2. **Visual Landmarks:**

- Architecture style
- Street signs/language
- Vegetation/landscape
- Vehicle types/license plates
- Business names

3. **Sun Position Analysis:** Tools like SunCalc can determine time/location from shadows.
    
4. **Reverse Search Landmarks:** Crop distinctive features → reverse search
    

**Timestamp Verification:**

Compare EXIF timestamps with claimed dates:

```bash
exiftool -DateTimeOriginal -CreateDate -ModifyDate image.jpg
```

**Modification Detection:**

**Error Level Analysis (ELA):**

```bash
# Using ImageMagick
convert image.jpg -quality 90 resaved.jpg
composite -compose difference resaved.jpg image.jpg difference.png
convert difference.png -auto-level ela_result.png
```

Online tools: fotoforensics.com

**Reverse Search Workflow:**

1. Extract metadata
2. Search across multiple engines:
    - Google Images
    - Yandex
    - TinEye
    - Bing
3. Compare results for discrepancies
4. Search visual elements separately (crop sections)
5. Translate foreign text found
6. Check social media platforms directly

### Social Media Image Search

**Google Images with site operator:**

```
site:facebook.com "photo ID"
site:instagram.com username
```

**Direct Platform Search:**

- Twitter: Search tweets → Photos filter
- Instagram: Location/hashtag search
- VK (Russian): vk.com search

### Command-Line Tools

**reverse-image-search (Python):**

```bash
pip install reverse-image-search

reverse-image-search search -i image.jpg
```

**search-that-hash (includes image search):**

```bash
pip install search-that-hash

sth --image image.jpg
```

### Image Manipulation for Better Results

**Crop to focus:** Remove irrelevant portions to focus on key elements.

**Adjust quality:** Lower quality can sometimes match compressed versions.

**Rotate/flip:** Try different orientations.

**Color adjustment:** Normalize lighting for better matches.

## Custom Search Operators

Custom search operators extend beyond standard syntax for specialized reconnaissance.

### Google Advanced Search Features

**Numeric Ranges:**

```
site:example.com 2020..2024
price:100..500
"serial number" 1000..9999
```

**Location-Based:**

```
location:london
near:newyork
```

**Date Range:**

```
before:2024-01-01
after:2023-01-01
```

**Related Sites:**

```
related:example.com
```

**Link Search:**

```
link:example.com
```

[Unverified] - This operator's functionality varies and may not return comprehensive results consistently.

### Combining Multiple Operators for Precision

**Multi-domain search:**

```
(site:gov OR site:mil) filetype:pdf "classified"
```

**Boolean operators:**

```
site:example.com (admin OR administrator OR login)
"password" AND ("database" OR "db") filetype:sql
```

**Exclusion chains:**

```
site:example.com -www -blog -shop -forum
```

**Pattern matching:**

```
inurl:user/*/posts
inurl:id=[0-9]
```

### Regular Expression Patterns (Limited)

Google doesn't support full regex, but patterns work:

```
"admin" inurl:id=*
inurl:page=*.php
"user-" intitle:profile
```

### Custom Search Engines (CSE)

Google Custom Search Engine allows creating targeted search tools.

**Use Cases:**

- Search only security-related sites
- Search specific document repositories
- Create CTF-specific search engines

**Creation:**

1. programmablesearchengine.google.com
2. Add target sites
3. Configure search features
4. Generate embed code or API key

**API Access:**

```bash
curl "https://www.googleapis.com/customsearch/v1?key=API_KEY&cx=SEARCH_ENGINE_ID&q=query"
```

### Search Engine Automation

**googler** - Command-line Google search:

```bash
# Install
pip install googler

# Basic search
googler "example query"

# Site-specific
googler "site:example.com admin"

# Filter by time
googler --time d7 "news query"

# JSON output
googler --json "query" > results.json
```

**Bing-ip2hosts** - Find virtual hosts on IP:

```bash
# Install
pip install bing-ip2hosts

# Search
bing-ip2hosts 192.168.1.1
```

### CTF-Specific Operator Combinations

**Hidden Admin Panels:**

```
site:target.com (inurl:admin | inurl:administrator | inurl:login | inurl:dashboard) -inurl:wp-admin
```

**Configuration Exposure:**

```
site:target.com (filetype:env | filetype:config | filetype:ini | filetype:yml) (password | secret | key)
```

**Backup Files:**

```
site:target.com (ext:bak | ext:old | ext:backup | ext:zip | ext:tar.gz) (config | database | sql)
```

**Directory Listings:**

```
site:target.com intitle:"index of" -(apache | nginx default page)
```

**Git Exposure:**

```
site:target.com (inurl:.git | inurl:git/config)
```

**Database Dumps:**

```
site:target.com (filetype:sql | filetype:db | filetype:sqlite) (INSERT | CREATE TABLE)
```

**API Documentation:**

```
site:target.com (inurl:api | inurl:swagger | inurl:docs) (json | endpoint)
```

**Credentials in Files:**

```
site:target.com (filetype:txt | filetype:log) (username | password | login)
```

### Advanced Filter Combinations

**Time-sensitive searches:**

```
site:target.com after:2024-01-01 before:2024-12-31 "update"
```

**Multiple file types:**

```
site:target.com (ext:doc | ext:docx | ext:xls | ext:xlsx | ext:ppt | ext:pptx) confidential
```

**Nested exclusions:**

```
site:*.target.com -site:www.target.com -site:blog.target.com inurl:admin
```

### Search Result Scraping

**hakrawler** - Web crawler discovering endpoints:

```bash
go install github.com/hakluke/hakrawler@latest

echo "https://example.com" | hakrawler -depth 3
```

**gospider** - Fast web spider:

```bash
go install github.com/jaeles-project/gospider@latest

gospider -s "https://example.com" -d 2 -c 10
```

---

**Important Related Topics:**

- **DNS Enumeration** - Complements search engine intel for subdomain discovery
- **Metadata Analysis** - Deep dive into file metadata beyond basic EXIF
- **Domain Intelligence** - WHOIS, certificate transparency, DNS records
- **Social Media OSINT** - Platform-specific search techniques and scraping

---

# Social Media Intelligence

Social media platforms contain vast amounts of personal, organizational, and contextual information that can be leveraged during OSINT operations. This module covers systematic approaches to extracting, analyzing, and correlating social media data.

## Platform-Specific OSINT

### Twitter/X Intelligence

**Account Enumeration and Discovery**

Twitter's API restrictions have increased, but several methods remain effective:

```bash
# Using twint (archived tool, may have limitations)
twint -u username --since "2024-01-01"
twint -s "keyword" -g "40.7128,-74.0060,10km"
twint --email email@domain.com

# Alternative: Social-Analyzer
social-analyzer -u "username" -p "twitter"
```

**Advanced Search Operators**

Twitter's search syntax allows precise queries:

```
from:username since:2024-01-01 until:2024-12-31
to:username filter:replies
"exact phrase" min_faves:100
geocode:40.7128,-74.0060,10km
filter:media -filter:retweets
```

**Tweet Metadata Extraction**

Access tweet metadata through various methods:

```bash
# Using nitter instances (privacy-focused Twitter frontend)
# Format: https://nitter.net/username/status/tweet_id

# Extract embedded location data
curl -s "https://api.twitter.com/2/tweets/TWEET_ID?tweet.fields=geo" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**[Inference]** Deleted tweets may be accessible through archive services like Wayback Machine or specialized tweet archive tools.

### Facebook Intelligence

**Profile Discovery Without Authentication**

```bash
# Graph Search (limited since privacy updates)
https://www.facebook.com/search/str/KEYWORD/keywords_users
https://www.facebook.com/search/str/KEYWORD/keywords_pages

# Direct profile access patterns
https://www.facebook.com/profile.php?id=NUMERIC_ID
https://www.facebook.com/USERNAME
```

**Photo Metadata and Location Intelligence**

Facebook strips EXIF data from uploaded photos, but location information may persist in:

- Check-in data embedded in posts
- Tagged locations in photos
- Event attendance records
- Group memberships with geographic focus

**Graph API Enumeration** (requires authentication)

```bash
# Basic profile information
curl "https://graph.facebook.com/v18.0/USER_ID?fields=id,name,picture&access_token=TOKEN"

# Friends list (if permissions allow)
curl "https://graph.facebook.com/v18.0/USER_ID/friends?access_token=TOKEN"
```

### Instagram Intelligence

**Username and Profile Analysis**

```bash
# Instalooter - download posts and metadata
instalooter user USERNAME DESTINATION --metadata

# Instaloader - comprehensive profile scraping
instaloader profile USERNAME
instaloader --login=YOUR_USERNAME --fast-update USERNAME

# Extract follower/following lists
instaloader --login=YOUR_USERNAME --followers USERNAME
instaloader --login=YOUR_USERNAME --followees USERNAME
```

**Story and Highlight Extraction**

```bash
# Download stories (must be done within 24h)
instaloader --login=YOUR_USERNAME --stories USERNAME

# Download highlights
instaloader --login=YOUR_USERNAME --highlights USERNAME
```

**Hashtag and Location Intelligence**

```bash
# Posts by hashtag
instaloader "#hashtag"

# Posts from location
instaloader --location LOCATION_ID

# Find location ID from coordinates
# Use tools like instagram-scraper or manual inspection
```

**[Unverified]** Some third-party tools claim to identify private account followers without authentication, but these typically violate platform ToS and may not function reliably.

### LinkedIn Intelligence

**Company and Employee Enumeration**

LinkedIn actively blocks scraping, but techniques include:

```bash
# theHarvester - email and employee enumeration
theHarvester -d company.com -b linkedin

# LinkedIn search syntax
site:linkedin.com/in/ "Company Name" "Job Title"
site:linkedin.com/in/ "Company Name" "Location"

# Using Google dorks
site:linkedin.com intitle:"Company Name" "Current Position"
```

**Sales Navigator Patterns** (requires subscription)

Advanced search filters provide:

- Company size and growth
- Technology stack indicators
- Job posting timelines
- Employee movement patterns

**Profile OSINT Without Connection**

Observable without authentication:

- Profile headline and summary
- Current position and company
- Education history
- Featured content and articles
- Skill endorsements (partial)

### TikTok Intelligence

**User Profile Analysis**

```bash
# TikTok Scraper
tiktok-scraper user USERNAME -d -n 50

# Download user videos with metadata
tiktok-scraper user USERNAME --filepath DESTINATION --download

# Hashtag monitoring
tiktok-scraper hashtag "HASHTAG" -d -n 100
```

**Sound and Music Tracking**

TikTok's audio fingerprinting enables:

- Finding all videos using specific sounds
- Identifying original audio creators
- Tracking viral sound propagation

```bash
# Music/sound ID extraction
tiktok-scraper music MUSIC_ID -d
```

**Geolocation Indicators**

TikTok location data comes from:

- Explicit location tags
- Background visual analysis
- Audio cues (language, accents, ambient sounds)
- Hashtag patterns with geographic significance

## Username Enumeration

### Cross-Platform Username Search

**Sherlock - Multi-Platform Username Checker**

```bash
# Install
git clone https://github.com/sherlock-project/sherlock.git
cd sherlock
pip install -r requirements.txt

# Basic search
python3 sherlock USERNAME

# Search specific sites
python3 sherlock USERNAME --site Twitter --site GitHub

# Output to file
python3 sherlock USERNAME --output results.txt --csv
```

**WhatsMyName - Web-Based Username Enumeration**

```bash
git clone https://github.com/WebBreacher/WhatsMyName
cd WhatsMyName
python3 whatsmyname.py -u USERNAME
```

**Maigret - Advanced OSINT Username Search**

```bash
# Install
pip3 install maigret

# Comprehensive search
maigret USERNAME

# With Tor for anonymity
maigret USERNAME --tor

# Generate HTML report
maigret USERNAME --html
```

**Namechk and KnowEm Alternatives**

Web-based services for bulk checking:

- https://namechk.com
- https://knowem.com
- https://namecheckr.com

### Email-Based Username Discovery

**Email Pattern Recognition**

Common corporate email patterns:

```
first.last@company.com
firstlast@company.com
first_last@company.com
f.last@company.com
flast@company.com
```

**Email Verification Tools**

```bash
# theHarvester
theHarvester -d company.com -b all

# Hunter.io CLI
# Requires API key
curl "https://api.hunter.io/v2/domain-search?domain=company.com&api_key=YOUR_KEY"

# Email verification
curl "https://api.hunter.io/v2/email-verifier?email=test@company.com&api_key=YOUR_KEY"
```

## Profile Analysis Techniques

### Metadata Extraction from Posts

**Image Metadata Analysis**

```bash
# ExifTool - comprehensive metadata extraction
exiftool image.jpg
exiftool -a -G1 -s image.jpg  # Verbose output

# Extract GPS coordinates
exiftool -gpslatitude -gpslongitude -n image.jpg

# Strip metadata for comparison
exiftool -all= -o clean.jpg original.jpg
```

**Document Metadata**

```bash
# PDF metadata
exiftool document.pdf
pdfinfo document.pdf

# Office documents
exiftool document.docx
```

### Behavioral Pattern Analysis

**Posting Time Analysis**

Posting patterns reveal:

- Likely timezone and working hours
- Sleep patterns (local time inference)
- Travel and location changes
- Organizational work schedules

**Language and Lexical Analysis**

Tools for linguistic profiling:

```python
# Basic sentiment and language detection
from textblob import TextBlob
text = "Sample social media post"
analysis = TextBlob(text)
print(analysis.sentiment)
print(analysis.detect_language())
```

**Content Theme Classification**

Categorize posts by:

- Professional vs. personal content ratio
- Interest areas and hobbies
- Political/ideological indicators
- Technical skill level indicators

### Profile Completeness Assessment

**Information Hierarchy**

Rank profiles by intelligence value:

1. Complete profiles with verified information
2. Active profiles with regular posting
3. Dormant profiles with historical data
4. Incomplete or abandoned profiles

**Cross-Reference Validation**

Verify claims across platforms:

- Employment history consistency
- Location history alignment
- Educational credential verification
- Professional certification validation

## Social Network Mapping

### Graph Construction

**Relationship Mapping Tools**

```bash
# Maltego - commercial graph analysis
# Community edition available
# Import: Social media profiles, email addresses
# Transforms: Find connections, mutual friends, shared interests

# SpiderFoot - automated OSINT framework
spiderfoot -s TARGET -t IP/domain/email
```

**First-Degree Connections**

Direct relationships observable through:

- Friend/follower lists
- Tagged photos and posts
- Comment interactions
- Shared group memberships

**Second and Third-Degree Analysis**

```bash
# Using NetworkX for graph analysis (Python)
import networkx as nx

G = nx.Graph()
G.add_edges_from([('User1', 'User2'), ('User2', 'User3')])

# Find shortest path
nx.shortest_path(G, source='User1', target='User3')

# Centrality measures
nx.degree_centrality(G)
nx.betweenness_centrality(G)
```

### Organizational Mapping

**Employee Network Discovery**

LinkedIn company page analysis reveals:

- Organizational structure
- Department sizes and functions
- Recent hires and departures
- Internal project teams

**Communication Pattern Analysis**

Interaction frequency indicates:

- Close working relationships
- Formal vs. informal connections
- Hierarchical structures
- Cross-functional teams

### Temporal Network Evolution

**Timeline Construction**

Track network changes:

```python
# Pseudo-code for temporal analysis
timeline = {}
for post in posts:
    timestamp = post.created_at
    connections = extract_connections(post)
    timeline[timestamp] = connections

# Identify relationship formation/dissolution
```

**Event-Driven Clustering**

Networks cluster around:

- Conferences and professional events
- Educational institutions
- Geographic relocations
- Project collaborations

## Geolocation from Social Media

### Explicit Location Data

**Geotagged Content Extraction**

```bash
# Extract coordinates from Twitter
twint -u USERNAME -g "LAT,LONG,RADIUS" --json

# Instagram location data
instaloader --login=USER profile TARGET_USER
# Parse JSON for location_id and coordinates

# Facebook check-in extraction
# Manual inspection or authenticated API calls required
```

**Check-in Pattern Analysis**

Frequent locations reveal:

- Home address (morning/evening posts)
- Workplace (weekday daytime patterns)
- Regular venues (gyms, cafes, restaurants)
- Travel destinations

### Visual Geolocation

**Landmark Identification**

Techniques:

1. Reverse image search (Google, Yandex, TinEye)
2. Architectural style analysis
3. Signage and text in images
4. License plate formats
5. Flora and fauna identification

**Tools for Visual OSINT**

```bash
# Google Earth Pro
# Cross-reference visual elements with satellite imagery

# Using GeoGuessr techniques:
# - Sun position and shadows
# - Vegetation types
# - Infrastructure characteristics
# - Vehicle types and traffic patterns
```

**Shadow Analysis for Time/Location**

Calculate sun position:

```
# SunCalc.org
# Input: Date, time, coordinates
# Output: Sun azimuth and elevation

# Verify timestamp authenticity
# Detect location spoofing
```

### Network-Based Geolocation

**IP Address Inference**

[Unverified] Social media platforms typically strip IP metadata from public posts, but patterns may emerge through:

- VPN/proxy detection in posting behavior
- Network change indicators (different ISPs)
- Mobile vs. fixed network patterns

**WiFi and Bluetooth Beacons**

Background elements may reveal:

- WiFi network SSIDs in screenshots
- Bluetooth device names
- QR codes with location data

**Cellular Network Indicators**

Observable in images:

- Cell tower structures
- Signal strength indicators
- Carrier branding on devices

### Temporal Geolocation

**Time Zone Analysis**

```python
# Calculate probable timezone from posting patterns
from collections import Counter
import pytz

post_times = [...]  # List of UTC timestamps
local_hours = [t.hour for t in post_times]
peak_hours = Counter(local_hours).most_common(5)

# Infer timezone from activity patterns
# Typical activity: 7am-11pm local time
```

**Travel Timeline Reconstruction**

Build movement history:

1. Collect all geotagged posts chronologically
2. Identify location transitions
3. Calculate travel time feasibility
4. Note mode of transportation clues
5. Cross-reference with event attendance

### Correlation and Triangulation

**Multi-Source Fusion**

Combine intelligence from:

- Direct geotags
- Visual landmarks
- Social connections' locations
- Event attendance
- Ambient environmental cues

**Verification Techniques**

Validate location claims:

- Weather conditions match reported location
- Daylight hours align with timezone
- Local events/holidays consistent
- Language and signage appropriate

**[Inference]** When multiple location indicators converge, confidence in geolocation increases, but absolute certainty requires explicit confirmation.

## Operational Considerations

**Platform Terms of Service**

[Unverified] Many scraping tools violate platform ToS and may result in:

- Account suspension
- IP blocking
- Legal action in extreme cases

**Rate Limiting and Detection**

Implement operational security:

```bash
# Use Tor for anonymity
torify python3 sherlock.py USERNAME

# Rotate user agents
curl -A "Mozilla/5.0 ..." URL

# Implement delays between requests
sleep 5 && curl URL
```

**Data Retention and Privacy**

Ethical considerations:

- Store only necessary information
- Respect privacy laws (GDPR, CCPA)
- Avoid targeting minors
- Maintain data security

**Attribution and Evidence**

Document findings:

- Timestamp all discoveries
- Capture screenshots with metadata
- Archive pages (archive.org, archive.is)
- Maintain chain of custody

---

# Image and Video Analysis

## Metadata Extraction (EXIF, XMP)

### EXIF Data Fundamentals

EXIF (Exchangeable Image File Format) stores camera settings, GPS coordinates, timestamps, and device information within JPEG files. This metadata often reveals geolocation, device models, and timing information critical for CTF flags.

**ExifTool (Primary Method)**

ExifTool is the industry standard for comprehensive metadata extraction across all image formats.

```bash
# Extract all metadata
exiftool image.jpg

# Extract specific tags
exiftool -GPS* image.jpg
exiftool -n image.jpg | grep -i gps

# Extract GPS in decimal format for mapping
exiftool -n -GPS* image.jpg

# Write metadata to JSON
exiftool -j image.jpg > metadata.json

# Remove all metadata (useful for analysis comparison)
exiftool -all= image.jpg

# Extract to specific format
exiftool -s image.jpg
exiftool -S image.jpg  # compact format

# Batch process directory
exiftool -r /path/to/images/
exiftool -r -csv /path/to/images/ > metadata.csv
```

**Common CTF-Relevant Tags**

- `Make` / `Model`: Camera manufacturer and device
- `DateTime`: Original photo timestamp (vulnerable to manipulation)
- `GPSLatitude` / `GPSLongitude`: Precise geolocation
- `GPSAltitude`: Elevation data
- `Artist` / `Copyright`: Author metadata
- `Software`: Processing software (may reveal tool versions)
- `UserComment`: Hidden text data
- `Orientation`: Image rotation (metadata vs. pixel data)

### XMP Data Extraction

XMP (Extensible Metadata Platform) stores structured data in XML format, commonly used by Adobe products and modern cameras.

```bash
# Extract XMP-specific data
exiftool -XMP:* image.jpg

# View XMP structure
exiftool -xmp image.jpg

# Search XMP for specific keywords
exiftool -XMP:* image.jpg | grep -i "keyword\|subject\|description"
```

**XMP Common Fields in CTF Context**

- `xmp:CreatorContactInfo`: Author contact information
- `xmp:Location`: Geographic location
- `xmp:Keywords`: Searchable keywords and tags
- `xmp:Description`: Extended descriptions
- `xmp:Subject`: Subject categories

### Alternative Metadata Tools

**ImageMagick (identify)**

```bash
identify -verbose image.jpg | grep -i "geometry\|colorspace\|resolution"
```

**MediaInfo (video/multimedia)**

```bash
mediainfo --Inform="Image" video.mp4
mediainfo video.mp4 | grep -i "duration\|codec\|creation"
```

**Metadata Anonymization Toolkit (MAT2)**

```bash
mat2 image.jpg  # display removable metadata
mat2 -s image.jpg  # dry run
mat2 image.jpg  # actually remove metadata
```

### GPS Coordinate Conversion and Mapping

```bash
# Extract GPS to decimal degrees
exiftool -n -GPS* image.jpg

# Convert to DMS (Degrees, Minutes, Seconds)
exiftool -a -G1 -s image.jpg | grep GPS

# Google Maps URL construction
# Format: https://maps.google.com/?q=LATITUDE,LONGITUDE
# Example: https://maps.google.com/?q=40.7128,-74.0060
```

---

## Reverse Image Searching

### Google Images (Programmatic Access)

Google's reverse image search is the most comprehensive but requires browser-based interaction for most effective results.

**Automated Methods**

```bash
# Using curl with Google Images (limited effectiveness - requires cookies/headers)
curl -A "Mozilla/5.0" "https://www.google.com/searchbyimage?image_url=https://example.com/image.jpg"

# More reliable: Use Python selenium for browser automation
```

**Python Automation Script**

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

driver = webdriver.Chrome()
image_url = "https://example.com/image.jpg"

# Google Images reverse search
driver.get(f"https://images.google.com/")
search_box = driver.find_element(By.CLASS_NAME, "aLK")
search_box.send_keys(image_url)
search_box.submit()

# Wait for results and extract URLs
WebDriverWait(driver, 10).until(
    EC.presence_of_all_elements_located((By.TAG_NAME, "img"))
)

results = driver.find_elements(By.TAG_NAME, "img")
for result in results[:10]:
    print(result.get_attribute("src"))

driver.quit()
```

### Yandex Images (Specialized Search)

Yandex often finds different results, particularly for images distributed in non-English regions.

```bash
# Web interface: https://yandex.com/images/
# API-based approach (requires API key for production)
curl -X POST "https://yandex.com/images-api/v1/searchmap" \
  -H "Content-Type: application/json" \
  -d '{"image_url":"https://example.com/image.jpg"}'
```

### TinEye (Specialized Commercial Service)

TinEye specializes in image matching and version history tracking.

**TinEye API (Requires API Key)**

```bash
# API endpoint
curl "https://api.tineye.com/api/request/match/" \
  -H "Authorization: YOUR_API_KEY" \
  -F "image=@image.jpg"
```

**TinEye CLI Alternative**

```bash
# Web-based interface: https://tineye.com
# Upload image directly for manual reverse search
```

### IQDB (Specialized for Anime/Artwork)

```bash
# Web interface: http://iqdb.org/
# Useful for artwork, illustrations, and anime screenshots
# No programmatic API, browser-only
```

### Specialized Reverse Search Tools

**Bing Visual Search**

```bash
# Web interface: https://www.bing.com/visualsearch
```

**Multi-Engine Search with Python**

```python
import os
from selenium import webdriver
from bing_image_downloader import bing_image_downloader

query = "image_url:https://example.com/image.jpg"

# Search across multiple services
services = {
    "google": f"https://www.google.com/searchbyimage?image_url=https://example.com/image.jpg",
    "yandex": "https://yandex.com/images/",
    "bing": "https://www.bing.com/visualsearch"
}

for service, url in services.items():
    print(f"[+] Searching {service}: {url}")
```

---

## Image Manipulation Detection

### Hash-Based Detection (Fast Comparison)

Cryptographic hashing identifies exact duplicates and detects pixel-level modifications.

**MD5 / SHA-256 Hashing**

```bash
# Calculate MD5 (demonstrates tampering when compared to known original)
md5sum image.jpg
sha256sum image.jpg

# Compare two images
md5sum image1.jpg image2.jpg
# Different hashes = at least one bit differs

# Batch hash verification
sha256sum -c checksums.txt
```

### Perceptual Hashing (Detects Similar Images)

Perceptual hashing identifies manipulated versions of the same image by comparing visual similarity rather than exact byte matches.

**pHash (Perceptual Hash)**

```bash
# Install pHash library
pip install imagehash Pillow

# Python perceptual hashing script
python3 << 'EOF'
import imagehash
from PIL import Image

img1 = Image.open('original.jpg')
img2 = Image.open('modified.jpg')

# Calculate pHash
hash1 = imagehash.phash(img1)
hash2 = imagehash.phash(img2)

# Compare (hamming distance, 0 = identical, higher = more different)
distance = hash1 - hash2
print(f"Hamming Distance: {distance}")
print(f"Similarity: {(64-distance)/64 * 100:.2f}%")  # 64 bits for pHash

# Other hash methods
dhash = imagehash.dhash(img1)  # Difference hash
ahash = imagehash.average_hash(img1)  # Average hash
whash = imagehash.whash(img1)  # Wavelet hash
EOF
```

**Command-Line pHash Tools**

```bash
# Using phash command-line tools
# Installation: apt-get install phash

phash -h image1.jpg image2.jpg
```

### Metadata Inconsistency Detection

```bash
# Extract metadata and compare timestamps
exiftool -DateTime original.jpg modified.jpg

# Compare creation vs. modification times
exiftool -FileModifyDate -CreateDate image.jpg

# Check for conflicting EXIF timestamps
exiftool -a image.jpg | grep -i "date\|time"
```

### JPEG Compression Artifact Analysis

JPEG compression leaves distinctive patterns. Re-compression or editing creates visible compression discontinuities.

**Identifying JPEG Quality and Recompression**

```bash
# JPEGSnoop (Windows tool, but Linux equivalent exists)
# Linux equivalent: analyze JPEG structure

python3 << 'EOF'
from PIL import Image
import io

img = Image.open('image.jpg')

# Extract JPEG quality information
try:
    # Attempt to determine JPEG quality
    quality_info = img.info.get('progressive')
    subsampling = img.info.get('subsampling')
    print(f"Progressive: {quality_info}")
    print(f"Subsampling: {subsampling}")
except:
    pass

# Re-save at different qualities and compare file sizes
for q in [75, 85, 95]:
    img.save(f'test_q{q}.jpg', quality=q)
    import os
    print(f"Quality {q}: {os.path.getsize(f'test_q{q}.jpg')} bytes")
EOF
```

### Clone Detection (Identifying Copy-Pasted Regions)

Clone detection identifies when a region of an image has been copied from elsewhere in the same image.

**Error Level Analysis (ELA)**

```python
python3 << 'EOF'
from PIL import Image
import numpy as np

img = Image.open('image.jpg')

# Save at lower quality and compare
temp = Image.new('RGB', img.size)
temp.save('temp.jpg', quality=90)
temp = Image.open('temp.jpg')

# Calculate pixel-level differences
original_array = np.array(img, dtype=np.uint8)
recompressed_array = np.array(temp, dtype=np.uint8)

error_level = np.abs(original_array.astype(int) - recompressed_array.astype(int))

# Visualize error levels
error_image = Image.fromarray(error_level.astype(np.uint8))
error_image.save('error_level_analysis.jpg')
print("[+] Error level analysis saved to error_level_analysis.jpg")
EOF
```

**Copy-Move Forgery Detection (CMFD)**

```python
pip install opencv-python numpy scipy

python3 << 'EOF'
import cv2
import numpy as np
from scipy.signal import correlate2d

img = cv2.imread('image.jpg', 0)

# Split image into overlapping blocks
block_size = 16
stride = 8

blocks = []
positions = []

for y in range(0, img.shape[0] - block_size, stride):
    for x in range(0, img.shape[1] - block_size, stride):
        block = img[y:y+block_size, x:x+block_size]
        blocks.append(block.flatten())
        positions.append((x, y))

# Compare blocks for similarity
blocks = np.array(blocks)
distances = np.linalg.norm(blocks[:, np.newaxis] - blocks[np.newaxis, :], axis=2)

# Find potential matches (low distance = copied region)
threshold = 5000
matches = np.where((distances < threshold) & (distances > 0))

for i, j in zip(matches[0], matches[1]):
    if i < j:  # Avoid duplicates
        print(f"[!] Potential copy-paste detected:")
        print(f"    Region 1: {positions[i]} -> Region 2: {positions[j]}")
EOF
```

### Splicing Detection (Identifying Combined Images)

Splicing involves combining multiple images. Detection focuses on boundary artifacts and inconsistent lighting/compression.

**Boundary Artifact Detection**

```python
python3 << 'EOF'
import cv2
import numpy as np

img = cv2.imread('image.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Compute Laplacian (emphasizes edges/boundaries)
laplacian = cv2.Laplacian(gray, cv2.CV_64F)

# High variance in Laplacian indicates potential splicing boundaries
cv2.imwrite('laplacian_analysis.jpg', np.abs(laplacian))

print("[+] Laplacian analysis computed")
print(f"[+] Variance: {np.var(laplacian):.2f}")
EOF
```

### Video Frame Extraction and Analysis

```bash
# Extract frames from video
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg

# Analyze specific frame ranges
ffmpeg -i video.mp4 -ss 00:01:00 -to 00:02:00 -vf fps=1 frame_%04d.jpg

# Extract metadata from video
mediainfo video.mp4
exiftool video.mp4
ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1:noprint_sections=1 video.mp4
```

### Metadata Timeline Construction

```bash
# Build comprehensive metadata timeline
exiftool -r -csv /path/to/evidence/ | sort -t',' -k3,3 > timeline.csv

# Extract timestamps for all media
find /path/to/evidence/ -type f \( -iname "*.jpg" -o -iname "*.mp4" \) -exec exiftool -FileModifyDate {} \; | sort
```

---

## CTF-Specific Methodology

**Metadata Extraction → GPS Mapping → Reverse Image Search → Manipulation Detection**

1. Extract all metadata using ExifTool
2. Convert GPS coordinates to map URLs
3. Perform reverse image search across multiple services
4. Calculate cryptographic and perceptual hashes
5. Analyze JPEG compression artifacts and error levels
6. Check for splicing and clone detection indicators
7. Cross-reference timeline data with contextual information

**Flag Locations in Image OSINT**

- Hidden in EXIF comments or artist fields
- Encoded in GPS coordinates (latitude/longitude decimal values)
- Found through reverse image search result metadata
- Embedded in XMP keywords or descriptions
- Revealed through image manipulation detection (watermarks, embedded text)

---

## Geolocation from Visual Clues

### Landmark and Architecture Recognition

Visual geolocation relies on identifying distinctive architectural features, signage, landscape characteristics, and infrastructure that pinpoint specific locations.

**Google Lens (Web Interface)**

```bash
# No direct CLI, browser-based
# https://lens.google.com/
# Upload image or provide URL for landmark identification
```

**TensorFlow-Based Landmark Detection (Programmatic)**

```bash
pip install tensorflow tensorflow-hub pillow numpy opencv-python

python3 << 'EOF'
import tensorflow as tf
import tensorflow_hub as hub
from PIL import Image
import numpy as np

# Load pre-trained landmark detection model
detector = hub.load('https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_asia_V1/1')

img = Image.open('image.jpg')
img_array = tf.image.resize(tf.constant(np.array(img)), [321, 321])
img_tensor = tf.cast(img_array, tf.uint8)[tf.newaxis, ...]

# Run inference
results = detector(img_tensor)

# Parse results
logits = results['logits'][0].numpy()
landmarks = results.get('labels', [])

print("[+] Detected landmarks:")
for idx, score in enumerate(sorted(enumerate(logits), key=lambda x: x[1], reverse=True)[:5]):
    print(f"    Confidence: {score[1]:.2%}")
EOF
```

**YOLO + Custom Training (Advanced)**

```bash
pip install ultralytics opencv-python pillow

python3 << 'EOF'
from ultralytics import YOLO

# Load YOLOv8 model
model = YOLO('yolov8n.pt')

# Detect objects and architectural features
results = model.predict('image.jpg', conf=0.5)

# Extract detection classes
for result in results:
    for box in result.boxes:
        class_id = int(box.cls[0])
        confidence = box.conf[0]
        # Map class_id to architecture terms (columns, domes, spires, etc.)
        print(f"Feature detected: {result.names[class_id]} ({confidence:.2%})")

# Run segmentation for precise region identification
results_seg = model.segment('image.jpg')
EOF
```

### Street Sign and License Plate Analysis

Text visible on signs, license plates, and infrastructure reveals geographic regions through language, formatting, and numbering systems.

**OCR with Tesseract**

```bash
# Install Tesseract
apt-get install tesseract-ocr
pip install pytesseract pillow

python3 << 'EOF'
import pytesseract
from PIL import Image

img = Image.open('image.jpg')
text = pytesseract.image_to_string(img)

# Extract regional indicators
regional_indicators = {
    'Cyrillic': 'Russia/Eastern Europe',
    '日本語': 'Japan',
    '中文': 'China',
    'العربية': 'Arabic-speaking region',
    'ελληνικά': 'Greece'
}

print("[+] Extracted text:")
print(text)
print("\n[+] Regional analysis:")
for script, region in regional_indicators.items():
    if script in text:
        print(f"    Possible region: {region}")
EOF
```

**EasyOCR (Modern Alternative)**

```bash
pip install easyocr

python3 << 'EOF'
import easyocr
import cv2

reader = easyocr.Reader(['en', 'ru', 'ja', 'ar', 'el', 'ko'])
result = reader.readtext('image.jpg')

print("[+] OCR Results with coordinates:")
for (bbox, text, confidence) in result:
    print(f"    Text: {text} | Confidence: {confidence:.2%}")
    print(f"    Position: {bbox}")
EOF
```

**License Plate Recognition (LPR)**

```bash
pip install python-openalpr

python3 << 'EOF'
from openalpr import Alpr

# Initialize with region-specific configuration
alpr = Alpr('us', '/etc/openalpr/openalpr.conf', '/usr/share/openalpr/runtime_data/')

if not alpr.is_loaded():
    print("[-] OpenALPR failed to load")
else:
    results = alpr.recognize_file('image.jpg')
    
    for plate in results['results']:
        print(f"[+] License Plate: {plate['plate']}")
        print(f"    Confidence: {plate['confidence']:.2%}")
        print(f"    Region: {plate['region']}")
        print(f"    Candidates: {[c['plate'] for c in plate['candidates'][:3]]}")
EOF
```

**License Plate Format Analysis (Manual)**

```bash
python3 << 'EOF'
import re

# Format patterns by region
formats = {
    'UK': r'^[A-Z]{2}\d{2}\s?[A-Z]{3}$',  # AB12 CDE
    'USA': r'^\d{3}-\d{3}-\d{4}$|^[A-Z]{1,3}\d{1,5}$',  # Format varies by state
    'Germany': r'^[A-Z]{1,3}-[A-Z]{1,2}\d{1,4}$',  # B-AB 1234
    'France': r'^[A-Z]{2}-\d{3}-[A-Z]{2}$',  # AB-123-CD
    'Japan': r'^\d{1,4}[\u3000-\u303f]*[ぁ-ん]*\d{1,4}$',  # 1234 あ 1234
    'Russia': r'^[А-Я]\d{3}[А-Я]{2}\d{2,3}$'  # А123БВ78 (Cyrillic)
}

plate = "BC-AB 1234"
for region, pattern in formats.items():
    if re.match(pattern, plate):
        print(f"[+] Likely region: {region}")
EOF
```

### Environmental and Seasonal Analysis

Weather patterns, vegetation, and seasonal indicators narrow geographic possibilities.

**Vegetation Recognition**

```python
python3 << 'EOF'
import cv2
import numpy as np
from PIL import Image

img = cv2.imread('image.jpg')
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

# Define green color range (vegetation)
lower_green = np.array([35, 40, 40])
upper_green = np.array([90, 255, 255])

# Create mask for green pixels
mask = cv2.inRange(hsv, lower_green, upper_green)

# Calculate vegetation percentage
vegetation_percent = (cv2.countNonZero(mask) / mask.size) * 100

print(f"[+] Vegetation coverage: {vegetation_percent:.1f}%")

# Additional climate indicators
lower_brown = np.array([10, 50, 50])  # Desert/dry regions
upper_brown = np.array([20, 255, 255])
mask_brown = cv2.inRange(hsv, lower_brown, upper_brown)
brown_percent = (cv2.countNonZero(mask_brown) / mask_brown.size) * 100

print(f"[+] Brown/dry coverage: {brown_percent:.1f}%")

if vegetation_percent > 40:
    print("    Climate: Tropical or temperate with significant vegetation")
elif brown_percent > 30:
    print("    Climate: Arid or semi-arid region")
EOF
```

### Shadow and Sun Angle Analysis

Sun position analysis determines latitude and time of year. Shadow length indicates solar elevation angle.

```python
python3 << 'EOF'
import cv2
import numpy as np
from datetime import datetime
import math

img = cv2.imread('image.jpg')
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

# Detect shadows (darker regions)
_, shadow_mask = cv2.threshold(gray, 100, 255, cv2.THRESH_BINARY_INV)

# Find shadow direction through contours
contours, _ = cv2.findContours(shadow_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

if contours:
    largest_shadow = max(contours, key=cv2.contourArea)
    M = cv2.moments(largest_shadow)
    
    # Calculate shadow centroid and dominant direction
    cx = int(M['m10'] / M['m00'])
    cy = int(M['m01'] / M['m00'])
    
    # Fit line to shadow contour
    [vx, vy, x, y] = cv2.fitLine(largest_shadow, cv2.DIST_L2, 0, 0.01, 0.01)
    
    # Calculate angle (0° = north, 90° = east, 180° = south, 270° = west)
    angle = math.degrees(math.atan2(vy, vx))
    if angle < 0:
        angle += 360
    
    print(f"[+] Shadow direction: {angle:.1f}° from north")
    print(f"[+] Sun position: {(angle + 180) % 360:.1f}° (opposite to shadow)")
    
    # Rough latitude estimation based on shadow length
    # [Inference] Shadow length relates to solar elevation, which varies by latitude and time
    # This is approximation only
    print("[+] Sun altitude analysis available with known object height")
EOF
```

### Utility Pole and Infrastructure Analysis

Power line systems, utility poles, and infrastructure design vary by region and provide localization clues.

**Power Line Type Recognition**

```bash
python3 << 'EOF'
# Characteristics by region:
# - Double stacked transformers: Primarily North America
# - Porcelain insulators in specific colors: Region-dependent
# - Wooden vs. concrete poles: Regional standards
# - Pole markings and numbering: Often contain location data

# Manual analysis framework:
power_line_indicators = {
    'North America': ['Wooden poles', 'Thick ceramic insulators', 'Crossarm design'],
    'Europe': ['Concrete or metal poles', 'Smaller insulators', 'Different crossarm patterns'],
    'Asia': ['Varied pole types', 'Porcelain insulators', 'Dense networks in urban areas'],
    'Middle East/Africa': ['Metal poles', 'Simpler designs', 'Wider pole spacing']
}

print("[+] Infrastructure type matching:")
for region, features in power_line_indicators.items():
    print(f"    {region}: {', '.join(features)}")
EOF
```

### Google Street View Integration

Street View provides reference imagery for comparison and verification.

```bash
# Construct Street View URLs for specific coordinates
# Format: https://www.google.com/maps/@LAT,LON,3a,75y,HEADING,PITCH/data=!3m6!1e1!3m4!1sSTREET_VIEW_ID!2e0!7i16384!8i8192

# Example with known GPS coordinates from EXIF
LAT="40.7128"
LON="-74.0060"
echo "https://www.google.com/maps/@${LAT},${LON},3a,75y,0,0/data=!3m6!1e1!3m4!1s!2e0!7i16384!8i8192"

# Street View API (requires API key)
curl "https://maps.googleapis.com/maps/api/streetview?size=400x400&location=${LAT},${LON}&key=YOUR_API_KEY"
```

---

## Video Frame Analysis

### Frame Extraction and Timeline Construction

```bash
# Extract all frames at specified interval
ffmpeg -i video.mp4 -vf fps=1 frames/frame_%06d.jpg

# Extract frames at specific time intervals
ffmpeg -i video.mp4 -vf fps=0.5 frames/frame_%06d.jpg  # Every 2 seconds

# Extract single frame at timestamp
ffmpeg -i video.mp4 -ss 00:01:30 -vf "select=eq(n\,0)" -q:v 3 frame_at_90s.jpg

# Extract keyframes only (reduces redundancy)
ffmpeg -i video.mp4 -vf "select='eq(pict_type\,I)'" -vsync vfr frames/keyframe_%06d.jpg

# Extract frames with timestamp overlay (for reference)
ffmpeg -i video.mp4 -vf "fps=1,drawtext=text='%{pts\\:hms}':x=10:y=10:fontsize=24:fontcolor=white" frames/frame_%06d.jpg
```

### Motion Detection and Anomaly Identification

```bash
pip install opencv-python numpy scipy

python3 << 'EOF'
import cv2
import numpy as np
from scipy import stats

video_path = 'video.mp4'
cap = cv2.VideoCapture(video_path)

# Initialize background subtraction
fgbg = cv2.createBackgroundSubtractorMOG2(detectShadows=True)

frame_count = 0
motion_scores = []
significant_frames = []

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    
    # Apply background subtraction
    fgmask = fgbg.apply(frame)
    
    # Calculate motion magnitude
    motion_pixels = cv2.countNonZero(fgmask)
    motion_percentage = (motion_pixels / fgmask.size) * 100
    motion_scores.append(motion_percentage)
    
    # Flag frames with significant motion
    if motion_percentage > np.mean(motion_scores) + 2 * np.std(motion_scores):
        significant_frames.append(frame_count)
        print(f"[!] High motion at frame {frame_count}: {motion_percentage:.2f}%")

cap.release()

print(f"\n[+] Motion analysis complete")
print(f"[+] Average motion: {np.mean(motion_scores):.2f}%")
print(f"[+] Frames with anomalies: {len(significant_frames)}")
print(f"[+] Anomaly frames: {significant_frames[:10]}...")
EOF
```

### Object Tracking Across Frames

```bash
pip install ultralytics opencv-python

python3 << 'EOF'
from ultralytics import YOLO
import cv2

model = YOLO('yolov8n.pt')
video_path = 'video.mp4'
cap = cv2.VideoCapture(video_path)

# Track objects across frames
results = model.track(video_path, persist=True, verbose=False)

tracked_objects = {}

for result in results:
    if result.boxes.id is not None:
        for box, track_id in zip(result.boxes, result.boxes.id):
            obj_id = int(track_id)
            class_id = int(box.cls[0])
            
            if obj_id not in tracked_objects:
                tracked_objects[obj_id] = {
                    'class': result.names[class_id],
                    'frames': [],
                    'positions': []
                }
            
            # Store frame number and position
            tracked_objects[obj_id]['frames'].append(result.frame_num)
            tracked_objects[obj_id]['positions'].append(box.xyxy[0].tolist())

# Analyze tracking data
print("[+] Object tracking summary:")
for obj_id, data in tracked_objects.items():
    duration = len(data['frames'])
    if duration > 5:  # Only report objects visible for >5 frames
        print(f"    Object {obj_id} ({data['class']}): {duration} frames")
EOF
```

### Scene Change Detection

```bash
python3 << 'EOF'
import cv2
import numpy as np

video_path = 'video.mp4'
cap = cv2.VideoCapture(video_path)

ret, prev_frame = cap.read()
prev_gray = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)

frame_count = 1
scene_changes = []
threshold = 25.0  # Adjust sensitivity

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    curr_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # Calculate frame difference
    diff = cv2.absdiff(prev_gray, curr_gray)
    mean_diff = np.mean(diff)
    
    # Detect scene cuts
    if mean_diff > threshold:
        scene_changes.append((frame_count, mean_diff))
        print(f"[!] Scene change at frame {frame_count}: difference={mean_diff:.2f}")
    
    prev_gray = curr_gray

cap.release()

print(f"\n[+] Total scene changes detected: {len(scene_changes)}")
print(f"[+] Scene cut timestamps:")
for frame_num, diff in scene_changes[:10]:
    # Convert frame number to timestamp (assuming 30fps)
    timestamp = frame_num / 30
    print(f"    Frame {frame_num} ({timestamp:.2f}s): {diff:.2f}")
EOF
```

### Text/Overlay Detection in Video

```bash
pip install easyocr

python3 << 'EOF'
import easyocr
import cv2
import numpy as np

reader = easyocr.Reader(['en'])
video_path = 'video.mp4'
cap = cv2.VideoCapture(video_path)

frame_count = 0
extracted_text_timeline = {}

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    if frame_count % 10 != 0:  # Process every 10th frame for speed
        continue
    
    # OCR frame
    results = reader.readtext(frame)
    
    if results:
        text_list = [text[1] for text in results]
        extracted_text_timeline[frame_count] = text_list
        print(f"[+] Frame {frame_count}: {', '.join(text_list)}")

cap.release()

print(f"\n[+] Text extraction complete from {frame_count} frames")
EOF
```

### Video Metadata Extraction

```bash
# Extract comprehensive video metadata
ffprobe -v error -show_format -show_streams video.mp4

# Parse specific metadata
ffprobe -v error -select_streams v:0 -show_entries format=creation_time,duration -of csv=p=0 video.mp4

# Extract codec information
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate,duration -of csv=p=0 video.mp4

# Extract all available metadata as JSON
ffprobe -v error -print_format json -show_format -show_streams video.mp4 > metadata.json
```

**MediaInfo Alternative**

```bash
mediainfo video.mp4
mediainfo --Inform="General;Duration: %Duration/1000% seconds" video.mp4
```

### Thumbnail and Poster Frame Generation

```bash
# Generate grid of key frames
ffmpeg -i video.mp4 -vf "fps=1/10,scale=320:-1,tile=4x3" poster_grid.jpg

# Extract middle frame as poster
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4)
MIDDLE=$(echo "$DURATION / 2" | bc)
ffmpeg -i video.mp4 -ss $MIDDLE -vf "scale=320:-1" -q:v 3 -vframes 1 poster.jpg
```

---

## Facial Recognition Tools

### DeepFace (Easiest Implementation)

DeepFace provides pre-trained models requiring minimal setup.

```bash
pip install deepface opencv-python

python3 << 'EOF'
from deepface import DeepFace
import cv2

# Face detection and embedding extraction
image_path = 'image.jpg'

# Detect faces
try:
    detections = DeepFace.extract_faces(img_path=image_path, detector_backend='yolov8', 
                                        enforce_detection=False)
    
    print(f"[+] Faces detected: {len(detections)}")
    
    for idx, face in enumerate(detections):
        print(f"\n[+] Face {idx + 1}:")
        print(f"    Confidence: {face['confidence']:.4f}")
        print(f"    Bounding box: {face['facial_area']}")
    
    # Extract face embeddings for comparison
    embeddings = []
    for img_path in ['face1.jpg', 'face2.jpg']:
        embedding = DeepFace.represent(img_path=img_path, model_name='Facenet512')
        embeddings.append(embedding)
    
    # Compare two faces
    result = DeepFace.verify(img1_path='face1.jpg', img2_path='face2.jpg')
    print(f"\n[+] Face comparison result: {result['verified']}")
    print(f"    Distance: {result['distance']:.4f}")
    
except Exception as e:
    print(f"[-] Error: {e}")
EOF
```

### OpenCV DNN Face Detection

```bash
python3 << 'EOF'
import cv2
import numpy as np

# Load pre-trained Caffe model
proto_path = 'opencv_face_detector.pbtxt'
model_path = 'opencv_face_detector_uint8.pb'

# Download if not present:
# wget https://raw.githubusercontent.com/opencv/opencv_3rdparty/dnn_samples_face_detector_20170830/opencv_face_detector.pbtxt
# wget https://raw.githubusercontent.com/opencv/opencv_3rdparty/dnn_samples_face_detector_20170830/opencv_face_detector_uint8.pb

net = cv2.dnn.readNetFromTensorflow(model_path, proto_path)

image = cv2.imread('image.jpg')
h, w = image.shape[:2]

# Create blob
blob = cv2.dnn.blobFromImage(image, 1.0, (300, 300), [104, 117, 123], False, False)

# Detect faces
net.setInput(blob)
detections = net.forward()

# Parse detections
for i in range(detections.shape[2]):
    confidence = detections[0, 0, i, 2]
    
    if confidence > 0.5:  # Confidence threshold
        box = detections[0, 0, i, 3:7] * np.array([w, h, w, h])
        (startX, startY, endX, endY) = box.astype("int")
        
        print(f"[+] Face detected at ({startX}, {startY}) - ({endX}, {endY})")
        print(f"    Confidence: {confidence:.2%}")
        
        # Draw rectangle
        cv2.rectangle(image, (startX, startY), (endX, endY), (0, 255, 0), 2)

cv2.imwrite('faces_detected.jpg', image)
EOF
```

### MTCNN (Multi-task Cascaded Convolutional Networks)

MTCNN provides superior accuracy for multi-face scenarios with pose variation.

```bash
pip install mtcnn tensorflow

python3 << 'EOF'
from mtcnn import MTCNN
import cv2
import matplotlib.pyplot as plt

detector = MTCNN()
image = cv2.imread('image.jpg')
image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

# Detect faces
detections = detector.detect_faces(image_rgb)

print(f"[+] Faces detected: {len(detections)}")

for idx, face in enumerate(detections):
    print(f"\n[+] Face {idx + 1}:")
    print(f"    Bounding box: {face['box']}")
    print(f"    Confidence: {face['confidence']:.4f}")
    
    # Extract landmarks (eyes, nose, mouth)
    landmarks = face['keypoints']
    print(f"    Keypoints: {landmarks}")
    
    # Draw face box and landmarks
    x, y, w, h = face['box']
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 255, 0), 2)
    
    for name, (px, py) in landmarks.items():
        cv2.circle(image, (px, py), 3, (0, 0, 255), -1)

cv2.imwrite('faces_with_landmarks.jpg', image)
EOF
```

### Face Recognition (Face_Recognition Library)

```bash
pip install face_recognition opencv-python

python3 << 'EOF'
import face_recognition
import cv2
import numpy as np
import os

# Load reference image and extract encoding
reference_image = face_recognition.load_image_file('reference_face.jpg')
reference_encoding = face_recognition.face_encodings(reference_image)[0]

# Search for matches in directory
match_results = []

for filename in os.listdir('faces_directory'):
    if filename.endswith(('.jpg', '.png')):
        test_image = face_recognition.load_image_file(f'faces_directory/{filename}')
        test_encodings = face_recognition.face_encodings(test_image)
        
        if test_encodings:
            test_encoding = test_encodings[0]
            
            # Compare faces
            distance = face_recognition.face_distance([reference_encoding], test_encoding)[0]
            match = distance < 0.6  # Threshold for match
            
            print(f"[+] {filename}: {'MATCH' if match else 'NO MATCH'} (distance: {distance:.4f})")
            
            if match:
                match_results.append((filename, distance))

print(f"\n[+] Total matches found: {len(match_results)}")
for filename, distance in sorted(match_results, key=lambda x: x[1]):
    print(f"    {filename}: {distance:.4f}")
EOF
```

### Facial Analysis (Age, Gender, Emotion)

```bash
pip install deepface

python3 << 'EOF'
from deepface import DeepFace
import json

image_path = 'image.jpg'

# Analyze facial attributes
try:
    analysis = DeepFace.analyze(img_path=image_path, 
                               actions=['age', 'gender', 'race', 'emotion'],
                               enforce_detection=True)
    
    for face_data in analysis:
        print("[+] Facial Analysis Results:")
        print(f"    Age: {face_data['age']}")
        print(f"    Gender: {face_data['gender']}")
        print(f"    Race: {face_data['dominant_race']}")
        print(f"    Emotion: {face_data['dominant_emotion']}")
        print(f"\n[+] Emotion breakdown:")
        for emotion, score in face_data['emotion'].items():
            print(f"    {emotion}: {score:.2f}%")
        
except Exception as e:
    print(f"[-] Error: {e}")
EOF
```

### Reverse Face Search (Web Integration)

[Unverified] - Limited public APIs available for commercial reverse face search.

```bash
# Google Images can be used for reverse image search:
https://images.google.com/

# PimEyes (specialized facial search - subscription required):
https://pimeyes.com/

# Law enforcement tools (not publicly accessible):
# FBI's NGIC, Interpol facial recognition databases
```

**Approximate Face Search Workflow**

```bash
python3 << 'EOF'
from selenium import webdriver
from selenium.webdriver.common.by import By
import time

# Browser automation for reverse image search
driver = webdriver.Chrome()

image_url = "https://example.com/face.jpg"

# Google Images reverse search
driver.get(f"https://images.google.com/searchbyimage?image_url={image_url}")

time.sleep(3)

# Extract similar images (limited accuracy for faces without specialized service)
similar_results = driver.find_elements(By.CSS_SELECTOR, "img.rg_i")

print(f"[+] Similar results found: {len(similar_results)}")

driver.quit()
EOF
```

### Batch Face Detection and Extraction

```bash
python3 << 'EOF'
import os
import cv2
from mtcnn import MTCNN
import numpy as np

detector = MTCNN()
input_dir = 'videos_frames/'
output_dir = 'extracted_faces/'

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

face_count = 0

for filename in os.listdir(input_dir):
    if filename.endswith(('.jpg', '.png')):
        image_path = os.path.join(input_dir, filename)
        image = cv2.imread(image_path)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Detect faces
        detections = detector.detect_faces(image_rgb)
        
        if detections:
            print(f"[+] {filename}: {len(detections)} faces detected")
            
            for idx, face in enumerate(detections):
                x, y, w, h = face['box']
                
                # Extract face region with padding
                padding = 20
                x1 = max(0, x - padding)
                y1 = max(0, y - padding)
                x2 = min(image.shape[1], x + w + padding)
                y2 = min(image.shape[0], y + h + padding)
                
                face_image = image[y1:y2, x1:x2]
                
                # Save extracted face
                output_path = os.path.join(output_dir, f'{face_count:06d}_face.jpg')
                cv2.imwrite(output_path, face_image)
                face_count += 1

print(f"\n[+] Total faces extracted: {face_count}")
EOF
```

### Face Clustering and Database Building

Group multiple faces across multiple images/videos to identify repeat individuals.

```bash
python3 << 'EOF'
import os
import face_recognition
import numpy as np
from scipy.cluster.hierarchy import fclusterdata
import pickle

# Load all face images and extract encodings
face_encodings = []
face_files = []
encodings_dir = 'faces_directory/'

for filename in os.listdir(encodings_dir):
    if filename.endswith(('.jpg', '.png')):
        try:
            image = face_recognition.load_image_file(os.path.join(encodings_dir, filename))
            encodings = face_recognition.face_encodings(image)
            
            if encodings:
                face_encodings.append(encodings[0])
                face_files.append(filename)
        except:
            continue

# Cluster faces (group similar individuals)
if len(face_encodings) > 1:
    # Use hierarchical clustering
    clusters = fclusterdata(face_encodings, t=0.6, criterion='distance', method='complete')
    
    print(f"[+] Total faces: {len(face_encodings)}")
    print(f"[+] Unique individuals (estimated): {len(np.unique(clusters))}")
    
    # Group by cluster
    cluster_dict = {}
    for idx, cluster_id in enumerate(clusters):
        if cluster_id not in cluster_dict:
            cluster_dict[cluster_id] = []
        cluster_dict[cluster_id].append(face_files[idx])
    
    # Print clustering results
    for cluster_id, files in sorted(cluster_dict.items()):
        print(f"\n[+] Individual {cluster_id}: {len(files)} occurrences")
        for f in files:
            print(f"    - {f}")
    
    # Save encodings database for future matching
    with open('face_encodings_db.pkl', 'wb') as f:
        pickle.dump({
            'encodings': face_encodings,
            'files': face_files,
            'clusters': clusters
        }, f)
EOF
```

### Facial Attribute Timeline Construction

```bash
python3 << 'EOF'
from deepface import DeepFace
import cv2
import json
from collections import defaultdict

video_path = 'video.mp4'
cap = cv2.VideoCapture(video_path)

fps = cap.get(cv2.CAP_PROP_FPS)
frame_count = 0
timeline = defaultdict(list)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    
    # Process every Nth frame (e.g., every 30 frames = 1 second at 30fps)
    if frame_count % int(fps) != 0:
        continue
    
    timestamp = frame_count / fps
    
    try:
        # Analyze facial attributes
        analysis = DeepFace.analyze(img_path=frame, 
                                   actions=['age', 'gender', 'emotion'],
                                   enforce_detection=False)
        
        if analysis:
            face_data = analysis[0]
            timeline[timestamp] = {
                'age': face_data['age'],
                'gender': face_data['gender'],
                'emotion': face_data['dominant_emotion'],
                'confidence': face_data
            }
            
            print(f"[+] {timestamp:.1f}s - {face_data['dominant_emotion']} | Age: {face_data['age']} | Gender: {face_data['gender']}")
    except:
        pass

cap.release()

# Export timeline
with open('facial_timeline.json', 'w') as f:
    json.dump(dict(timeline), f, indent=2)

print(f"\n[+] Facial attribute timeline saved to facial_timeline.json")
EOF
```

### Advanced: Face Verification Against Known Individuals

```bash
python3 << 'EOF'
import os
import face_recognition
import json

# Load reference faces database
known_faces = {}

references_dir = 'known_faces/'
for person_dir in os.listdir(references_dir):
    person_path = os.path.join(references_dir, person_dir)
    if os.path.isdir(person_path):
        known_faces[person_dir] = []
        
        for filename in os.listdir(person_path):
            if filename.endswith(('.jpg', '.png')):
                try:
                    image = face_recognition.load_image_file(os.path.join(person_path, filename))
                    encodings = face_recognition.face_encodings(image)
                    if encodings:
                        known_faces[person_dir].append(encodings[0])
                except:
                    continue

# Test image
test_image = face_recognition.load_image_file('test_image.jpg')
test_encodings = face_recognition.face_encodings(test_image)

results = {}

for test_encoding in test_encodings:
    for person_name, person_encodings in known_faces.items():
        # Compare against all reference images
        distances = face_recognition.face_distance(person_encodings, test_encoding)
        best_match_distance = min(distances)
        
        if best_match_distance < 0.6:  # Match threshold
            if person_name not in results:
                results[person_name] = []
            results[person_name].append(best_match_distance)

# Report findings
print("[+] Face Verification Results:")
for person, distances in sorted(results.items(), key=lambda x: min(x[1])):
    avg_distance = sum(distances) / len(distances)
    print(f"    {person}: {avg_distance:.4f} (Likely Match)")

if not results:
    print("    No matches found in known faces database")
EOF
```

### DeepFace Model Comparison

Different models provide varying speed/accuracy tradeoffs:

```bash
python3 << 'EOF'
import time
from deepface import DeepFace

# Available embedding models (compare performance)
models = ['VGG-Face', 'Facenet', 'Facenet512', 'OpenFace', 'DeepFace', 'ArcFace', 'SFace']

image_path = 'image.jpg'

print("[+] Model performance comparison:")
for model in models:
    start = time.time()
    try:
        embedding = DeepFace.represent(img_path=image_path, model_name=model, enforce_detection=False)
        elapsed = time.time() - start
        embedding_size = len(embedding[0]['embedding'])
        print(f"    {model:15s}: {elapsed:.3f}s | Embedding size: {embedding_size}")
    except Exception as e:
        print(f"    {model:15s}: ERROR - {str(e)[:40]}")

# [Inference] - Facenet512 offers best accuracy for CTF scenarios
# ArcFace and SFace provide faster alternatives with slight accuracy loss
EOF
```

### CTF-Specific Face Recognition Methodology

1. Extract frames from video at 1-second intervals using FFmpeg
2. Detect all faces using MTCNN for maximum accuracy with pose variation
3. Extract facial embeddings using Facenet512 (best accuracy) or ArcFace (faster)
4. Compare against reference image or build clustering database
5. Analyze facial attributes (age, gender, emotion) for temporal patterns
6. Construct facial attribute timeline synchronized with other video events
7. Cross-reference facial matches with metadata timestamps and geolocation data
8. Build individual identity profiles across multiple sources

**Flag Locations in Facial Recognition Tasks**

- Face matching to specific identity database reveals person ID/location
- Facial attribute patterns (emotion sequence, age consistency) may encode data
- Timestamp correlations between video frames and metadata
- Clustering results showing repeat individuals across multiple frames
- Facial landmark coordinates or distances between keypoints may contain encoded values
- Person identification count or specific individual sequence may form flag

---

## Advanced Multi-Modal Integration

### Synchronized Geolocation + Face + Metadata Timeline

```bash
python3 << 'EOF'
import json
from datetime import datetime
import cv2
import face_recognition
from PIL import Image
from PIL.ExifTags import TAGS

# Integrate multiple OSINT data sources
timeline_data = []

# 1. Extract video metadata
video_info = {
    'source': 'video.mp4',
    'creation_time': '2024-01-15T14:32:00',
    'duration': 300  # seconds
}

# 2. Extract EXIF from thumbnail
img = Image.open('thumbnail.jpg')
exif_data = img._getexif()
gps_info = None

if exif_data:
    for tag_id, value in exif_data.items():
        tag = TAGS.get(tag_id, tag_id)
        if tag == 'GPSInfo':
            gps_info = value

# 3. Extract faces from keyframes
cap = cv2.VideoCapture('video.mp4')
face_detections = {}

frame_num = 0
while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    if frame_num % 30 == 0:  # Keyframes every second at 30fps
        try:
            encodings = face_recognition.face_encodings(frame)
            if encodings:
                timestamp = frame_num / 30
                face_detections[timestamp] = {
                    'count': len(encodings),
                    'frame': frame_num
                }
        except:
            pass
    
    frame_num += 1

cap.release()

# 4. Combine into unified timeline
unified_timeline = {
    'video_metadata': video_info,
    'geolocation': gps_info,
    'face_events': face_detections,
    'timestamp': datetime.now().isoformat()
}

# Save integrated analysis
with open('integrated_osint_timeline.json', 'w') as f:
    json.dump(unified_timeline, f, indent=2)

print("[+] Integrated OSINT timeline created")
print(json.dumps(unified_timeline, indent=2)[:500] + "...")
EOF
```

### Cross-Reference Framework

```bash
python3 << 'EOF'
import json

# Template for correlating multiple data sources in CTF
correlation_framework = {
    'events': [],
    'geolocation_matches': [],
    'face_matches': [],
    'metadata_correlations': []
}

# Example correlation
example_event = {
    'timestamp': '2024-01-15T14:32:45',
    'video_frame': 1345,
    'geolocation': {'latitude': 40.7128, 'longitude': -74.0060, 'location': 'New York City'},
    'face_detected': {'count': 1, 'confidence': 0.98, 'age': 28, 'gender': 'male'},
    'metadata': {'camera_model': 'Canon EOS 5D', 'exif_datetime': '2024-01-15T14:32:40'},
    'flag_segment': 'NYC_28M_140132'  # Potential flag construction
}

correlation_framework['events'].append(example_event)

print("[+] CTF Correlation Framework:")
print(json.dumps(correlation_framework, indent=2))
EOF
```

---

## Common CTF Patterns and Solutions

### Pattern: Hidden Location in Video

**Challenge**: Video contains faces and background scenery. Flag is location identifier.

**Solution Approach**:

1. Extract keyframes: `ffmpeg -i video.mp4 -vf "select='eq(pict_type\,I)'" -vsync vfr frames/frame_%06d.jpg`
2. Analyze landmarks: Google Lens + TensorFlow landmark detection
3. Identify faces: MTCNN face detection
4. Cross-reference: Reverse image search on background elements
5. Extract metadata: `exiftool -GPS* video.mp4`

### Pattern: Person Identification

**Challenge**: Video shows specific individual. Flag is person's identity/associated metadata.

**Solution Approach**:

1. Extract unique faces: Batch face extraction via MTCNN
2. Build reference database: Known public figures or database
3. Compare embeddings: DeepFace matching
4. Analyze attributes: Facial age/gender for verification
5. Cluster appearances: Track same individual across frames

### Pattern: Temporal Correlation

**Challenge**: Multiple media with timestamps. Flag requires aligning events.

**Solution Approach**:

1. Extract all timestamps: EXIF, FFMPEG metadata, file modification times
2. Create unified timeline: JSON structure correlating all sources
3. Identify coincident events: Faces appearing + GPS changes + metadata shifts
4. Calculate deltas: Time differences between events may encode data

### Pattern: Visual Encoding

**Challenge**: Attribute values (age, emotion, coordinates) encode flag segments.

**Solution Approach**:

1. Extract all facial attributes: DeepFace analysis pipeline
2. Note exact values: Age (integer), emotion (string), coordinates (float)
3. Convert to characters: Numeric values to ASCII/letters
4. Concatenate in sequence: Order determined by frame timestamp or position

**Example CTF Solution Workflow**

```bash
# Complete extraction pipeline
#!/bin/bash

VIDEO="challenge.mp4"
FRAMES_DIR="frames"
FACES_DIR="faces"

# 1. Extract frames
ffmpeg -i "$VIDEO" -vf fps=1 "$FRAMES_DIR/frame_%06d.jpg"

# 2. Detect and extract faces
python3 << 'PYTHON'
from mtcnn import MTCNN
import cv2
import os

detector = MTCNN()
for img_file in os.listdir('frames'):
    img = cv2.imread(f'frames/{img_file}')
    detections = detector.detect_faces(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    for idx, det in enumerate(detections):
        x, y, w, h = det['box']
        face = img[y:y+h, x:x+w]
        cv2.imwrite(f'faces/{img_file[:-4]}_face_{idx}.jpg', face)
PYTHON

# 3. Analyze attributes
python3 << 'PYTHON'
from deepface import DeepFace
import json
import os

results = {}
for face_file in os.listdir('faces'):
    path = f'faces/{face_file}'
    analysis = DeepFace.analyze(path, actions=['age', 'gender', 'emotion'])
    results[face_file] = analysis[0]

# Export results
with open('analysis.json', 'w') as f:
    json.dump(results, f)
PYTHON

# 4. Extract metadata and create timeline
exiftool -r -csv frames/ > metadata.csv

echo "[+] Analysis complete - check analysis.json and metadata.csv"
```

---

# Domain and IP Intelligence

## WHOIS Lookups

WHOIS is a query/response protocol providing registration information about domain names, IP addresses, and autonomous systems. WHOIS data reveals registrant details, administrative contacts, registration dates, and nameserver configurations.

**Core Information Retrieved:**

- **Registrant data**: Organization name, contact email, phone numbers
- **Registration dates**: Creation, expiration, last update timestamps
- **Nameservers**: DNS servers authoritative for the domain
- **Registrar information**: Company managing the registration
- **Status codes**: Domain lock status, transfer restrictions
- **DNSSEC**: Security extension implementation status

### Command-Line WHOIS Tools

**Standard WHOIS Client:**

```bash
whois example.com
whois 8.8.8.8
whois AS15169
```

**Linux/macOS native tool, available by default on most systems.**

**Key Parameters:**

```bash
whois -h whois.server.com domain.com    # Specify WHOIS server
whois -p 43 domain.com                  # Specify port (43 is default)
whois -H domain.com                     # Omit legal disclaimers (some servers)
```

**Parsing WHOIS Output:**

```bash
whois example.com | grep -i "registrar"
whois example.com | grep -i "creation date"
whois example.com | grep -i "name server"
whois example.com | awk '/Registrant Email/ {print $3}'
```

**WHOIS for IP Addresses:**

```bash
whois 1.2.3.4
```

Returns Regional Internet Registry (RIR) information: ARIN (North America), RIPE (Europe), APNIC (Asia-Pacific), LACNIC (Latin America), AFRINIC (Africa).

**ASN WHOIS:**

```bash
whois -h whois.radb.net AS15169
whois AS15169 | grep -i "OrgName"
```

### Web-Based WHOIS Services

**ICANN WHOIS Lookup:**

- URL: `https://lookup.icann.org/`
- Authoritative source for gTLD data
- No rate limiting concerns
- Clean interface for manual queries

**DomainTools WHOIS:**

- URL: `https://whois.domaintools.com/`
- Historical WHOIS data (premium feature)
- Reverse WHOIS (find domains by registrant)
- Additional context and risk scoring

**ViewDNS.info:**

- URL: `https://viewdns.info/whois/`
- Multiple lookup tools in one platform
- No registration required
- Includes IP/domain correlation tools

### WHOIS Privacy and GDPR Impact

**Post-GDPR Changes:** Since GDPR implementation (2018), registrant personal information is often redacted for EU residents. Typical redactions include:

- Personal names replaced with "REDACTED FOR PRIVACY"
- Email addresses hidden or proxied
- Physical addresses removed
- Phone numbers masked

**Information Still Available:**

- Registrar details (always public)
- Registration/expiration dates (typically public)
- Nameservers (always public)
- Administrative contact (often redacted)
- Technical contact (often redacted)

**Privacy Protection Services:** Common proxy services mask real registrant data:

- **WhoisGuard** (Namecheap)
- **Domain Privacy** (GoDaddy)
- **Private Registration** (various registrars)

Detection indicators:

```
Registrant Organization: Privacy Protection Service
Registrant Email: proxy@privacyprotect.org
```

### Specialized WHOIS Tools

**whoxy (API Service):**

```bash
curl "http://api.whoxy.com/?key=API_KEY&whois=example.com"
```

- Structured JSON output
- Historical WHOIS data
- Reverse WHOIS capabilities
- Rate limits apply (varies by plan)

**amass (includes WHOIS module):**

```bash
amass intel -d example.com -whois
```

Integrates WHOIS data into broader reconnaissance framework.

**RegEx Parsing for Automation:**

```python
import subprocess
import re

def parse_whois(domain):
    result = subprocess.run(['whois', domain], capture_output=True, text=True)
    whois_data = result.stdout
    
    registrar = re.search(r'Registrar:\s*(.+)', whois_data)
    created = re.search(r'Creation Date:\s*(.+)', whois_data)
    nameservers = re.findall(r'Name Server:\s*(.+)', whois_data)
    
    return {
        'registrar': registrar.group(1) if registrar else None,
        'created': created.group(1) if created else None,
        'nameservers': nameservers
    }
```

[Inference]: Regex patterns may need adjustment based on WHOIS server response format variations.

### CTF WHOIS Techniques

**Reverse WHOIS Enumeration:** Find all domains registered to the same entity:

```bash
# Using DomainTools (web interface)
# Search by: Registrant name, email, organization

# Using whoxy API
curl "http://api.whoxy.com/?key=API_KEY&reverse=whois&email=contact@example.com"
```

**Historical Analysis:** Compare current and historical WHOIS to identify:

- Ownership changes (acquisition indicators)
- Infrastructure changes (nameserver modifications)
- Expired domains (potential takeover targets)

**Nameserver Correlation:** Find domains sharing nameservers:

```bash
# All domains using ns1.example.com
# Typically requires specialized tools or APIs
```

**Common CTF Scenarios:**

- Flag hidden in registrant email or organization field
- Historical WHOIS reveals previous owner/contact with clues
- Registration date correlates with event timeline
- Nameservers point to infrastructure revealing additional targets
- Registrar information provides geographic or organizational context

### Rate Limiting and Best Practices

**WHOIS Server Rate Limits:** Most WHOIS servers implement rate limiting:

- Typical limits: 50-100 queries per day per IP
- Exceeded limits result in temporary IP blocks
- No standardized rate limit across servers

**Mitigation Strategies:**

```bash
# Add delays between queries
for domain in $(cat domains.txt); do
    whois $domain
    sleep 5
done

# Rotate through different WHOIS servers
whois -h whois.verisign-grs.com example.com
whois -h whois.markmonitor.com example.com
```

**Caching Results:** Store WHOIS output to avoid repeated queries:

```bash
domain="example.com"
if [ ! -f "whois_${domain}.txt" ]; then
    whois $domain > "whois_${domain}.txt"
fi
cat "whois_${domain}.txt"
```

## DNS Enumeration

DNS enumeration reveals a domain's DNS records, exposing subdomains, mail servers, IP addresses, and infrastructure configuration. DNS queries are passive reconnaissance—queries to public DNS servers generate normal traffic.

**DNS Record Types:**

|Record|Purpose|CTF Value|
|---|---|---|
|A|IPv4 address|Primary target IPs|
|AAAA|IPv6 address|IPv6 infrastructure|
|CNAME|Canonical name (alias)|Service identification, subdomain relationships|
|MX|Mail exchange|Email infrastructure, org discovery|
|NS|Nameserver|Authoritative DNS servers|
|TXT|Text records|SPF, DKIM, verification tokens, hidden flags|
|SOA|Start of authority|Zone configuration, serial numbers|
|PTR|Reverse DNS|IP to hostname mapping|
|SRV|Service locator|Specific service discovery (XMPP, SIP)|
|CAA|Certificate authority authorization|Permitted CAs for domain|

### Basic DNS Query Tools

**dig (Domain Information Groper):**

```bash
# Basic A record lookup
dig example.com

# Specific record type
dig example.com MX
dig example.com TXT
dig example.com NS
dig example.com AAAA

# Query specific nameserver
dig @8.8.8.8 example.com

# Short output (answer only)
dig +short example.com
dig +short example.com MX

# All records (ANY query - often restricted)
dig example.com ANY

# Reverse DNS lookup
dig -x 1.2.3.4

# Trace DNS resolution path
dig +trace example.com
```

**nslookup:**

```bash
# Basic lookup
nslookup example.com

# Specific record type
nslookup -query=MX example.com
nslookup -query=TXT example.com

# Query specific server
nslookup example.com 8.8.8.8

# Interactive mode
nslookup
> set type=MX
> example.com
> set type=TXT
> example.com
> exit
```

**host:**

```bash
# Simple lookup
host example.com

# All records
host -a example.com

# Specific record
host -t MX example.com
host -t TXT example.com

# Reverse lookup
host 1.2.3.4
```

### DNS Zone Transfers

Zone transfers (AXFR) replicate entire DNS zone data between nameservers. Misconfigured servers may allow unauthorized transfers, exposing all subdomains.

**Testing for Zone Transfer:**

```bash
# Identify nameservers
dig NS example.com +short

# Attempt zone transfer on each nameserver
dig @ns1.example.com example.com AXFR
dig @ns2.example.com example.com AXFR

# Using host
host -l example.com ns1.example.com
```

**Successful AXFR Output:**

```
example.com.     86400   IN   SOA   ns1.example.com. admin.example.com. ...
example.com.     86400   IN   NS    ns1.example.com.
example.com.     86400   IN   NS    ns2.example.com.
www.example.com. 86400   IN   A     192.0.2.1
mail.example.com. 86400  IN   A     192.0.2.2
dev.example.com.  86400  IN   A     192.0.2.3
...
```

**Denied AXFR Output:**

```
; Transfer failed.
; communications error: connection refused
```

[Unverified]: Modern DNS servers rarely allow unauthorized zone transfers. Finding open AXFR in CTFs typically indicates intentional misconfiguration for challenge purposes.

### Automated DNS Enumeration Tools

**dnsenum:**

```bash
# Basic enumeration
dnsenum example.com

# Specify DNS server
dnsenum --dnsserver 8.8.8.8 example.com

# Include WHOIS queries
dnsenum --enum example.com

# Attempt zone transfer
dnsenum --noreverse example.com

# Specify wordlist for subdomain brute-force
dnsenum --subfile subdomains.txt example.com

# Save output to file
dnsenum -o output.xml example.com
```

**fierce:**

```bash
# Basic DNS reconnaissance
fierce --domain example.com

# Specify DNS servers
fierce --domain example.com --dns-servers 8.8.8.8,1.1.1.1

# Custom subdomain wordlist
fierce --domain example.com --subdomain-file wordlist.txt

# Delay between queries (avoid rate limiting)
fierce --domain example.com --delay 2

# Wide scan (broader IP ranges)
fierce --domain example.com --wide
```

**dnsrecon:**

```bash
# Standard enumeration
dnsrecon -d example.com

# Zone transfer test
dnsrecon -d example.com -t axfr

# Subdomain brute force
dnsrecon -d example.com -t brt -D subdomains.txt

# Reverse lookup on IP range
dnsrecon -r 192.0.2.0/24

# Google enumeration (search for subdomains)
dnsrecon -d example.com -t goo

# Cache snooping
dnsrecon -t snoop -D domains.txt -n 8.8.8.8

# Export to XML/JSON
dnsrecon -d example.com -x output.xml
dnsrecon -d example.com -j output.json
```

**Example Output Parsing:**

```bash
# Extract A records
dnsrecon -d example.com | grep "A " | awk '{print $3,$5}'

# Find subdomains only
dnsrecon -d example.com -t brt -D wordlist.txt | grep "A " | cut -d' ' -f3 | sort -u
```

### DNS Reconnaissance Techniques

**TXT Record Intelligence:** TXT records often contain verification tokens, SPF records, DKIM keys, and hidden information:

```bash
dig example.com TXT +short
```

Common TXT record findings:

- **SPF records**: `v=spf1 include:_spf.google.com ~all` (reveals email providers)
- **DKIM keys**: `v=DKIM1; k=rsa; p=MIGfMA0GCS...` (cryptographic keys)
- **Verification tokens**: `google-site-verification=abc123...` (service integrations)
- **Custom data**: CTF flags, hints, encoded messages

**MX Record Analysis:**

```bash
dig example.com MX +short
```

Reveals email infrastructure:

- Google Workspace: `aspmx.l.google.com`
- Microsoft 365: `*.mail.protection.outlook.com`
- ProtonMail: `mail.protonmail.ch`
- Self-hosted: Custom domain MX records

**NS Record Interrogation:**

```bash
dig example.com NS +short
```

Nameserver patterns indicate hosting providers:

- AWS Route 53: `ns-###.awsdns-##.{com,net,org,co.uk}`
- Cloudflare: `*.ns.cloudflare.com`
- DigitalOcean: `ns#.digitalocean.com`
- Custom infrastructure: Branded nameservers

**CAA Record Inspection:**

```bash
dig example.com CAA +short
```

Identifies authorized certificate authorities:

```
0 issue "letsencrypt.org"
0 issuewild "letsencrypt.org"
0 iodef "mailto:security@example.com"
```

**SRV Record Discovery:**

```bash
# Common SRV record patterns
dig _xmpp._tcp.example.com SRV
dig _sip._tcp.example.com SRV
dig _ldap._tcp.example.com SRV
dig _minecraft._tcp.example.com SRV
```

Reveals specific services and their locations.

### DNS Cache Snooping

DNS cache snooping queries a DNS server's cache to determine previously resolved domains, potentially revealing targets' browsing history or infrastructure.

**Technique:**

```bash
# Non-recursive query to check cache
dig @8.8.8.8 target.com +norecurs

# If cached, returns answer
# If not cached, returns no answer (but doesn't fetch)
```

**Ethical Consideration:** Cache snooping on public resolvers is generally acceptable. Snooping on organizational DNS servers without authorization may violate policies.

### DNS Tunneling Detection (Defensive Context)

While not typically used for CTF OSINT, understanding DNS tunneling helps identify covert channels:

**Indicators:**

- Unusually long subdomain labels
- High volume of queries to single domain
- Random-appearing subdomain patterns
- TXT record queries with large responses

**Detection Tools:**

```bash
# Monitor DNS traffic patterns
tcpdump -i eth0 -n port 53

# Analyze query patterns
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | sort | uniq -c | sort -rn
```

## Subdomain Discovery

Subdomain enumeration exposes additional attack surface by revealing development servers, administrative panels, forgotten applications, and segmented infrastructure.

**Discovery Methodology:**

1. **Passive enumeration**: Query external sources
2. **Active brute-forcing**: Test subdomain wordlists
3. **Permutation generation**: Derive subdomains from known patterns
4. **Recursive discovery**: Enumerate discovered subdomains

### Passive Subdomain Discovery

**Certificate Transparency Logs** (covered in detail in next section):

```bash
# crt.sh query
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Parsing multiple subdomains from certificates
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u
```

**Search Engine Enumeration:**

Google dorking for subdomains:

```
site:example.com -www
site:*.example.com
```

**Subfinder (Passive Tool):**

```bash
# Basic enumeration
subfinder -d example.com

# Silent mode (output only)
subfinder -d example.com -silent

# Output to file
subfinder -d example.com -o subdomains.txt

# Specify sources
subfinder -d example.com -sources censys,virustotal

# All available sources
subfinder -d example.com -all

# Verbose output
subfinder -d example.com -v

# Multiple domains
subfinder -dL domains.txt -o results.txt
```

Subfinder queries:

- Certificate Transparency logs
- VirusTotal
- Censys
- Shodan
- ThreatCrowd
- DNSdumpster
- SecurityTrails (API key recommended)

**Amass (Comprehensive Framework):**

```bash
# Passive enumeration only
amass enum -passive -d example.com

# Active enumeration (includes brute-force)
amass enum -d example.com

# Output formats
amass enum -d example.com -o subdomains.txt
amass enum -d example.com -json output.json

# Config file for API keys
amass enum -config config.ini -d example.com

# Visualization (requires additional setup)
amass viz -d3 -dir ./amass_output

# Specific techniques
amass enum -d example.com -src -brute

# Multiple domains
amass enum -df domains.txt
```

**Amass Data Sources:**

- Passive: TLS certificates, search engines, APIs
- Active: DNS brute-forcing, zone transfers, alterations
- Archived: Wayback Machine, CommonCrawl

**Configuration File Example (config.ini):**

```ini
[data_sources.Censys]
[data_sources.Censys.Credentials]
apikey = YOUR_API_KEY
secret = YOUR_SECRET

[data_sources.SecurityTrails]
[data_sources.SecurityTrails.Credentials]
apikey = YOUR_API_KEY

[data_sources.Shodan]
[data_sources.Shodan.Credentials]
apikey = YOUR_API_KEY
```

### Active Subdomain Brute-Forcing

**Gobuster (DNS Mode):**

```bash
# Basic DNS brute-force
gobuster dns -d example.com -w subdomains.txt

# Show CNAME records
gobuster dns -d example.com -w subdomains.txt -c

# Specify resolver
gobuster dns -d example.com -w subdomains.txt -r 8.8.8.8

# Increase threads
gobuster dns -d example.com -w subdomains.txt -t 50

# Timeout per query
gobuster dns -d example.com -w subdomains.txt --timeout 3s

# Output to file
gobuster dns -d example.com -w subdomains.txt -o results.txt

# Wildcard handling (automatically detects)
gobuster dns -d example.com -w subdomains.txt --wildcard
```

**ffuf (DNS Mode):**

```bash
# Basic fuzzing
ffuf -w subdomains.txt -u http://FUZZ.example.com

# DNS mode with specific server
ffuf -w subdomains.txt -u http://FUZZ.example.com -mode dns

# Filter by status code
ffuf -w subdomains.txt -u http://FUZZ.example.com -fc 404

# Match response size
ffuf -w subdomains.txt -u http://FUZZ.example.com -ms 1234

# Rate limiting
ffuf -w subdomains.txt -u http://FUZZ.example.com -rate 100

# Output formats
ffuf -w subdomains.txt -u http://FUZZ.example.com -o results.json -of json
```

**massdns (High-Performance Resolution):**

```bash
# Generate subdomain list with base domain
sed 's/$/.example.com/' subdomains.txt > targets.txt

# Resolve with massdns
massdns -r resolvers.txt -t A targets.txt -o S -w results.txt

# Filter successful resolutions
cat results.txt | grep -E ' A ' | cut -d' ' -f1 | sed 's/\.$//' | sort -u

# Using with permutation
./subbrute.py example.com | massdns -r resolvers.txt -t A -o S -w resolved.txt
```

Resolver lists: `/usr/share/massdns/lists/resolvers.txt` or custom curated lists.

**puredns (Combines Massdns + Wildcard Filtering):**

```bash
# Basic resolution
puredns resolve subdomains.txt -r resolvers.txt

# Brute force with wordlist
puredns bruteforce wordlist.txt example.com -r resolvers.txt

# Rate limiting
puredns resolve subdomains.txt -r resolvers.txt --rate-limit 500

# Wildcard detection and filtering
puredns bruteforce wordlist.txt example.com -r resolvers.txt --wildcard-tests 10
```

### Subdomain Wordlists

**Common Wordlist Locations:**

```bash
# SecLists (most comprehensive)
/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt
/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt
/usr/share/seclists/Discovery/DNS/fierce-hostlist.txt

# Sublist3r
/usr/share/sublist3r/subdomains.txt

# Custom generation
```

**Dynamic Wordlist Generation:**

```bash
# Common patterns
echo -e "www\nmail\nftp\ntest\ndev\nstaging\napi\nadmin\nportal" > custom.txt

# Permutations with alterx
echo "example.com" | alterx -p "admin-{{word}},{{word}}-admin,{{word}}01,old-{{word}}"

# Combine multiple wordlists
cat wordlist1.txt wordlist2.txt | sort -u > combined.txt
```

### Subdomain Permutation and Alteration

**altdns (Permutation Generation):**

```bash
# Generate permutations
altdns -i subdomains.txt -o permutations.txt -w words.txt

# Resolve permutations
altdns -i subdomains.txt -o permutations.txt -w words.txt -r -s results.txt

# Custom permutation file
altdns -i subdomains.txt -o permutations.txt -w words.txt
```

Common permutation patterns:

- Prepend: `dev-`, `staging-`, `test-`
- Append: `-01`, `-prod`, `-backup`
- Insert: `api.v1.`, `admin.internal.`
- Replace: `www` → `www2`, `mail` → `mail2`

**gotator (Permutation Engine):**

```bash
# Generate combinations
gotator -sub subdomains.txt -perm permutations.txt -depth 3 -numbers 10 -md

# Output to file
gotator -sub subdomains.txt -perm permutations.txt > generated.txt

# Minify output (remove duplicates)
gotator -sub subdomains.txt -perm permutations.txt -md
```

**dnsgen (Advanced Permutations):**

```bash
# Generate from known subdomains
cat subdomains.txt | dnsgen -

# Specify wordlist
cat subdomains.txt | dnsgen -w wordlist.txt -

# Save output
cat subdomains.txt | dnsgen - > generated.txt

# Pipe to resolution
cat subdomains.txt | dnsgen - | massdns -r resolvers.txt -t A -o S
```

### Wildcard Detection and Handling

Wildcard DNS responds with valid answers for any subdomain query, creating false positives.

**Detection:**

```bash
# Test random subdomain
dig thisdoesnotexist12345.example.com

# If returns A record, wildcard is configured
```

**Manual Filtering:**

```bash
# Query wildcard baseline
wildcard_ip=$(dig randomstring12345.example.com +short | head -n1)

# Filter results matching wildcard
dig subdomain.example.com +short | grep -v "$wildcard_ip"
```

**Tool-Based Handling:** Most modern tools automatically detect and filter wildcards:

- `puredns`: Built-in wildcard detection
- `gobuster`: `--wildcard` flag
- `massdns`: Requires post-processing

### Integration and Workflow

**Complete Enumeration Workflow:**

```bash
#!/bin/bash
domain=$1

# Passive enumeration
echo "[*] Running passive enumeration..."
subfinder -d $domain -silent -o passive.txt
amass enum -passive -d $domain -o amass_passive.txt

# Certificate transparency
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sort -u > crtsh.txt

# Combine results
cat passive.txt amass_passive.txt crtsh.txt | sort -u > all_passive.txt

# Active brute-force
echo "[*] Running active brute-force..."
gobuster dns -d $domain -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -o gobuster.txt -q

# Combine and resolve
cat all_passive.txt gobuster.txt | sort -u > all_subdomains.txt
puredns resolve all_subdomains.txt -r resolvers.txt > resolved.txt

# Generate permutations
cat resolved.txt | dnsgen - | puredns resolve -r resolvers.txt >> resolved.txt

# Final deduplication
sort -u resolved.txt > final_subdomains.txt

echo "[+] Found $(wc -l < final_subdomains.txt) subdomains"
```

### Subdomain Takeover Identification

After discovery, identify subdomains vulnerable to takeover (dangling DNS records pointing to unclaimed services).

**Manual Checking:**

```bash
# Check CNAME
dig subdomain.example.com CNAME +short

# If points to external service (e.g., GitHub Pages, AWS S3)
# Verify if service is claimed
```

**Automated Tools:**

**subjack:**

```bash
# Check subdomain list
subjack -w subdomains.txt -t 100 -timeout 30 -o results.txt -ssl

# Verbose mode
subjack -w subdomains.txt -v

# Specific provider patterns
subjack -w subdomains.txt -c fingerprints.json
```

**SubOver:**

```bash
# Check for takeovers
subover -l subdomains.txt

# Verbose output
subover -l subdomains.txt -v

# Threads
subover -l subdomains.txt -t 50
```

Common takeover services:

- GitHub Pages: `*.github.io`
- AWS S3: `*.s3.amazonaws.com`
- Azure: `*.azurewebsites.net`
- Heroku: `*.herokuapp.com`
- Shopify: `shops.myshopify.com`

## Certificate Transparency Logs

Certificate Transparency (CT) is a public logging system for TLS/SSL certificates. All certificates issued by participating CAs are logged in public, append-only logs, exposing domain and subdomain information.

**Why CT Logs Matter for OSINT:**

- Reveals all subdomains with issued certificates (including internal/forgotten ones)
- Passive technique (no direct target interaction)
- Historical certificate data available
- Wildcard certificates expose parent domains
- Timestamps indicate infrastructure changes

### CT Log Structure

**Certificate Components Exposed:**

- **Common Name (CN)**: Primary domain
- **Subject Alternative Names (SANs)**: All domains/subdomains covered
- **Issuer**: Certificate authority
- **Validity period**: Not before / not after dates
- **Serial number**: Unique certificate identifier
- **Fingerprint**: Certificate hash

### Web-Based CT Log Search

**crt.sh (Most Popular):**

```
URL: https://crt.sh/
Query: example.com
Wildcard query: %.example.com
```

**Advanced crt.sh Queries:**

```
# Specific domain (no wildcards)
https://crt.sh/?q=example.com

# All subdomains
https://crt.sh/?q=%.example.com

# Exclude wildcards from results
https://crt.sh/?q=%.example.com&exclude=expired

# Specific organization
https://crt.sh/?O=Example%20Organization

# Identity search
https://crt.sh/?id=1234567890

# JSON output
https://crt.sh/?q=%.example.com&output=json
```

**Parsing JSON Output:**

```bash
# Basic extraction
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Remove wildcards
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u

# Extract unique domains
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u | grep -v '*'

# Get certificate IDs and domains
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[] | "\(.id) \(.name_value)"'

# Filter by issuer
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[] | select(.issuer_name | contains("Let")) | .name_value' | sort -u
```

**Censys (Certificate Search):**

```
URL: https://search.censys.io/certificates
Query: parsed.names: example.com
```

Censys provides:

- Advanced filtering by certificate attributes
- Historical certificate data
- Integration with host search
- API access for automation

**Google CT Search:**

```
URL: https://transparencyreport.google.com/https/certificates
```

Google's interface provides visualization and detailed certificate inspection.

### Command-Line CT Tools

**ctfr (Certificate Transparency Finder):**

```bash
# Install
pip3 install ctfr

# Basic usage
ctfr -d example.com

# Save to file
ctfr -d example.com -o subdomains.txt

# Output format options
ctfr -d example.com -o results.json
```

**crt.sh via curl (scripted):**

```bash
#!/bin/bash
domain=$1

# Fetch and parse
curl -s "https://crt.sh/?q=%25.${domain}&output=json" | \
jq -r '.[].name_value' | \
sed 's/\*\.//g' | \
sort -u | \
grep -v '@'  # Remove email addresses sometimes included

# Alternative: single-line extraction
curl -s "https://crt.sh/?q=%25.${domain}&output=json" | jq -r '.[].name_value' | sort -u | tee crt_subdomains.txt
```

**certspotter (Automated Monitoring):**

```bash
# Install
go install github.com/SSLMate/certspotter/cmd/certspotter@latest

# Search for domain
certspotter -domain example.com

# Output JSON
certspotter -domain example.com -json

# Save logs
certspotter -domain example.com -logs -o results.json
```

**Amass with CT Integration:**

```bash
# Amass automatically queries CT logs
amass enum -passive -d example.com

# Verbose to see CT sources
amass enum -passive -d example.com -v
```

### Advanced CT Techniques

**Historical Certificate Analysis:**

Certificates change over time due to:

- Infrastructure expansion (new subdomains)
- Service migrations (hosting provider changes)
- Security incidents (emergency reissuance)
- Domain transfers (ownership changes)

**Tracking Certificate History:**

```bash
# Query all certificates for domain (not just latest)
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | "\(.entry_timestamp) \(.name_value)"' | \
sort | \
uniq

# Group by issuance date
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | "\(.not_before) \(.name_value)"' | \
sort -k1

# Find recently added subdomains (last 30 days)
recent_date=$(date -d "30 days ago" +%Y-%m-%d)
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r --arg date "$recent_date" '.[] | select(.not_before > $date) | .name_value' | \
sort -u
```

**Wildcard Certificate Intelligence:**

Wildcard certificates (`*.example.com`) indicate:

- Infrastructure at scale
- Potential for additional undiscovered subdomains
- Automated certificate management (likely Let's Encrypt or similar)

```bash
# Find wildcard certificates
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | select(.name_value | contains("*")) | .name_value' | \
sort -u

# Extract base domains from wildcards
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | .name_value' | \
grep '^\*\.' | \
sed 's/^\*\.//' | \
sort -u
```

**Multi-Level Subdomain Discovery:**

CT logs reveal nested subdomains that brute-forcing might miss:

```
api.prod.internal.example.com
v2.staging.app.example.com
db1.us-east.infra.example.com
```

**Extraction Pattern:**

```bash
# Extract all subdomain levels
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[].name_value' | \
sed 's/\*\.//g' | \
sort -u | \
awk -F. '{print NF-1 " " $0}' | \
sort -rn | \
cut -d' ' -f2-

# Find third-level and deeper subdomains
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[].name_value' | \
grep -E '^[^.]+\.[^.]+\.[^.]+\.example\.com$'
```

**Certificate Issuer Analysis:**

Issuer patterns reveal infrastructure choices:

```bash
# Group by issuer
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | .issuer_name' | \
sort | \
uniq -c | \
sort -rn

# Common issuer interpretations:
# - Let's Encrypt: Automated certificate management, likely modern infrastructure
# - DigiCert/Sectigo: Enterprise/commercial service
# - Internal CA: Corporate infrastructure, potentially interesting for lateral movement
```

**SAN Analysis:**

Subject Alternative Names list all domains covered by a single certificate:

```bash
# Extract all SANs
curl -s "https://crt.sh/?q=example.com&output=json" | \
jq -r '.[].name_value' | \
sort -u

# SANs often reveal:
# - Related domains (acquisitions, subsidiaries)
# - Service relationships (CDN, email providers)
# - Infrastructure sharing (multi-tenant systems)
```

### CT Log API Integration

**Censys API:**

```bash
# Setup
export CENSYS_API_ID="your-api-id"
export CENSYS_API_SECRET="your-api-secret"

# Search certificates
curl -u "$CENSYS_API_ID:$CENSYS_API_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"query":"parsed.names: example.com", "per_page": 100}' \
  "https://search.censys.io/api/v2/certificates/search"

# Extract domains from response
curl -u "$CENSYS_API_ID:$CENSYS_API_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"query":"parsed.names: example.com"}' \
  "https://search.censys.io/api/v2/certificates/search" | \
jq -r '.result.hits[].parsed.names[]' | \
sort -u
```

**SecurityTrails API:**

```bash
# Search subdomains via CT logs
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/domain/example.com/subdomains"

# Historical DNS records
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/example.com/dns/a"
```

**Facebook CT Monitor API** [Unverified]:

```bash
# Endpoint access may require specific registration
curl "https://graph.facebook.com/certificates?query=%.example.com"
```

### CT Log Limitations and Considerations

**Coverage Gaps:**

- Not all CAs participate in CT logging (though major ones do)
- Self-signed certificates not logged
- Internal CAs typically not logged
- Pre-2013 certificates may not be logged

**False Positives:**

- Expired certificates still appear in logs
- Certificates may be issued but never deployed
- Test/staging certificates issued then discarded
- Misissued certificates (typos, mistakes)

**Verification Workflow:**

```bash
# Extract subdomains from CT logs
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[].name_value' | \
sed 's/\*\.//g' | \
sort -u > ct_subdomains.txt

# Verify they resolve
cat ct_subdomains.txt | \
while read subdomain; do
  if host "$subdomain" >/dev/null 2>&1; then
    echo "$subdomain"
  fi
done > live_subdomains.txt

# Or use puredns for bulk resolution
puredns resolve ct_subdomains.txt -r resolvers.txt > verified_subdomains.txt
```

**Rate Limiting:**

- crt.sh: Generally permissive, but excessive automated queries may be throttled
- Censys: API rate limits based on account tier
- Google CT: Web interface rate limits apply

### CTF-Specific CT Techniques

**Finding Hidden Flags:**

```bash
# Search for unusual patterns in certificate fields
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | .common_name, .issuer_name' | \
grep -i 'flag\|ctf\|key'

# Check for base64-encoded data in certificate fields
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[].name_value' | \
grep -E '^[A-Za-z0-9+/=]{20,}$'
```

**Timeline Reconstruction:**

```bash
# Build infrastructure timeline
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | "\(.not_before) | \(.name_value)"' | \
sort | \
uniq

# Identify infrastructure events:
# - Sudden increase in certificates = expansion
# - New subdomain patterns = service launch
# - Certificate authority change = policy/provider change
```

**Related Domain Discovery:**

```bash
# Find certificates with multiple unrelated domains (shared infrastructure)
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | select(.name_value | contains("\n")) | .name_value' | \
tr '\n' ' ' | \
grep -v "example.com" | \
head -20

# This reveals:
# - Shared hosting environments
# - Related organizations
# - Reseller/MSP relationships
```

## IP Geolocation

IP geolocation maps IP addresses to physical locations, revealing server hosting locations, organizational infrastructure distribution, and geographic targeting patterns.

**Geolocation Data Types:**

- **Country**: High accuracy (95%+)
- **Region/State**: Moderate accuracy (80-90%)
- **City**: Variable accuracy (60-80% for major cities)
- **Coordinates**: Approximate (often city center, not exact location)
- **ISP/Organization**: High accuracy
- **AS Number**: Definitive

**Accuracy Limitations:**

- VPN/Proxy endpoints: Show VPN location, not user location
- CDN nodes: Reflect content distribution, not origin server
- Anycast IPs: Single IP serves multiple geographic locations
- Private/Internal IPs: No public geolocation data
- Mobile networks: Dynamic assignment makes location variable

[Unverified]: Coordinate accuracy claims vary by provider. Exact coordinates typically represent ISP/data center locations, not physical server positions.

### Command-Line Geolocation Tools

**geoiplookup (GeoIP Legacy):**

```bash
# Install
apt-get install geoip-bin geoip-database

# Basic lookup
geoiplookup 8.8.8.8

# IPv6 support
geoiplookup6 2001:4860:4860::8888

# City database (requires separate download)
geoiplookup -f /usr/share/GeoIP/GeoIPCity.dat 8.8.8.8
```

**mmdb-inspect (MaxMind DB):**

```bash
# Install
pip3 install maxminddb

# Lookup in Python
python3 << EOF
import maxminddb
reader = maxminddb.open_database('/path/to/GeoLite2-City.mmdb')
print(reader.get('8.8.8.8'))
reader.close()
EOF
```

**geoip2 (MaxMind CLI):**

```bash
# Install
pip3 install geoip2

# Python script
python3 << EOF
import geoip2.database

reader = geoip2.database.Reader('/path/to/GeoLite2-City.mmdb')
response = reader.city('8.8.8.8')

print(f"Country: {response.country.name}")
print(f"City: {response.city.name}")
print(f"Coordinates: {response.location.latitude}, {response.location.longitude}")
print(f"Postal Code: {response.postal.code}")
print(f"Timezone: {response.location.time_zone}")

reader.close()
EOF
```

**curl + ip-api.com:**

```bash
# Basic lookup (no API key required)
curl "http://ip-api.com/json/8.8.8.8"

# Formatted output
curl -s "http://ip-api.com/json/8.8.8.8" | jq

# Specific fields
curl -s "http://ip-api.com/json/8.8.8.8?fields=status,country,city,lat,lon,isp,as"

# Batch lookup
curl -X POST -H "Content-Type: application/json" \
  -d '[{"query":"8.8.8.8"},{"query":"1.1.1.1"}]' \
  "http://ip-api.com/batch"

# Rate limit: 45 requests per minute (free tier)
```

**curl + ipinfo.io:**

```bash
# Basic lookup
curl "https://ipinfo.io/8.8.8.8"

# JSON format
curl "https://ipinfo.io/8.8.8.8/json"

# Specific field
curl "https://ipinfo.io/8.8.8.8/city"
curl "https://ipinfo.io/8.8.8.8/org"

# With API token (higher limits)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "https://ipinfo.io/8.8.8.8/json"

# Bulk lookup
curl -X POST -H "Content-Type: application/json" \
  -d '["8.8.8.8","1.1.1.1","1.0.0.1"]' \
  "https://ipinfo.io/batch?token=YOUR_TOKEN"
```

**shodan CLI:**

```bash
# Initialize with API key
shodan init YOUR_API_KEY

# Host lookup (includes geolocation)
shodan host 8.8.8.8

# Extract geolocation
shodan host 8.8.8.8 | grep -E 'City:|Country:|Coordinates:'

# Multiple IPs
cat ips.txt | while read ip; do shodan host $ip; done
```

### Web-Based Geolocation Services

**MaxMind GeoIP Demo:**

```
URL: https://www.maxmind.com/en/geoip-demo
```

Provides detailed city-level geolocation with coordinates and ISP information.

**IPinfo.io:**

```
URL: https://ipinfo.io/8.8.8.8
```

Clean interface, includes ASN, organization, and abuse contact information.

**IP2Location:**

```
URL: https://www.ip2location.com/demo
```

Detailed geolocation with timezone, weather station, and ZIP code data.

**DB-IP:**

```
URL: https://db-ip.com/8.8.8.8
```

Free geolocation with ISP and usage type (hosting, mobile, etc.) classification.

**Shodan:**

```
URL: https://www.shodan.io/host/8.8.8.8
```

Comprehensive view including open ports, services, vulnerabilities, and geolocation.

**IPGeolocation.io:**

```
URL: https://ipgeolocation.io/ip-location
API: https://api.ipgeolocation.io/ipgeo?apiKey=YOUR_KEY&ip=8.8.8.8
```

### Bulk Geolocation Processing

**Scripted Bulk Lookup:**

```bash
#!/bin/bash
# Bulk IP geolocation using ip-api.com

input_file="ips.txt"
output_file="geolocations.csv"

# Create CSV header
echo "IP,Country,Region,City,ISP,Lat,Lon" > "$output_file"

# Process each IP with rate limiting
while IFS= read -r ip; do
  data=$(curl -s "http://ip-api.com/json/${ip}?fields=status,country,regionName,city,isp,lat,lon")
  
  if echo "$data" | jq -e '.status == "success"' > /dev/null; then
    country=$(echo "$data" | jq -r '.country')
    region=$(echo "$data" | jq -r '.regionName')
    city=$(echo "$data" | jq -r '.city')
    isp=$(echo "$data" | jq -r '.isp')
    lat=$(echo "$data" | jq -r '.lat')
    lon=$(echo "$data" | jq -r '.lon')
    
    echo "${ip},${country},${region},${city},${isp},${lat},${lon}" >> "$output_file"
  fi
  
  # Rate limiting (45 req/min = ~1.3s delay)
  sleep 1.5
done < "$input_file"

echo "[+] Geolocation complete: $output_file"
```

**Python Bulk Processing with MaxMind:**

```python
import geoip2.database
import csv

def geolocate_ips(ip_list, db_path, output_csv):
    reader = geoip2.database.Reader(db_path)
    
    with open(output_csv, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['IP', 'Country', 'City', 'Latitude', 'Longitude', 'ISP', 'ASN'])
        
        for ip in ip_list:
            try:
                response = reader.city(ip)
                writer.writerow([
                    ip,
                    response.country.name or 'N/A',
                    response.city.name or 'N/A',
                    response.location.latitude or 'N/A',
                    response.location.longitude or 'N/A',
                    response.traits.isp or 'N/A',
                    response.traits.autonomous_system_number or 'N/A'
                ])
            except Exception as e:
                writer.writerow([ip, 'Error', str(e), '', '', '', ''])
    
    reader.close()

# Usage
with open('ips.txt', 'r') as f:
    ips = [line.strip() for line in f]

geolocate_ips(ips, '/path/to/GeoLite2-City.mmdb', 'results.csv')
```

### Geolocation Intelligence Analysis

**Infrastructure Mapping:**

```bash
# Map infrastructure distribution
cat resolved_subdomains.txt | while read subdomain; do
  ip=$(dig +short "$subdomain" A | head -n1)
  if [ ! -z "$ip" ]; then
    location=$(curl -s "http://ip-api.com/json/${ip}?fields=country,city" | jq -r '"\(.country) - \(.city)"')
    echo "$subdomain | $ip | $location"
  fi
  sleep 1.5
done
```

**Identifying Hosting Patterns:**

- All servers in single country: Likely single provider/region
- Geographic distribution: CDN or multi-region deployment
- Unexpected locations: Third-party services or compromised infrastructure
- Hosting provider mismatch: Acquired infrastructure or reseller hosting

**Regulatory Compliance Inference:**

- EU servers: Likely GDPR compliance concern
- China servers: Subject to Chinese data laws
- US servers: PATRIOT Act and CLOUD Act considerations
- Russia servers: Data localization requirements

[Inference]: Server location alone doesn't confirm compliance—legal jurisdiction depends on entity structure, data flow, and specific regulations.

### Advanced Geolocation Techniques

**Historical Geolocation Changes:**

Track IP geolocation changes over time to identify:

- Infrastructure migrations
- Hosting provider changes
- Geographic expansion
- Service degradation (moving to budget providers)

```bash
# Using SecurityTrails API
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/8.8.8.8/dns/a"
```

**Passive DNS + Geolocation Correlation:**

```bash
# Find all IPs for domain over time
# Geolocate each to track infrastructure movement

domain="example.com"

# Get current IP
current_ip=$(dig +short "$domain" A)

# Geolocate
curl -s "http://ip-api.com/json/${current_ip}" | jq
```

**ASN-Based Geolocation Verification:**

ASN provides authoritative hosting information:

```bash
# Get ASN
whois -h whois.cymru.com " -v 8.8.8.8"

# ASN WHOIS provides:
# - Owning organization
# - Network range
# - Allocation date
# - Geographic region (RIR)
```

### Geolocation Privacy Considerations

**VPN/Proxy Detection:**

Many IPs resolve to VPN/proxy services rather than actual user locations:

```bash
# Check if IP is known VPN
curl -s "http://ip-api.com/json/1.2.3.4?fields=proxy" | jq '.proxy'

# Specialized VPN detection APIs
curl "https://vpnapi.io/api/1.2.3.4?key=YOUR_KEY"
```

**Tor Exit Node Detection:**

```bash
# Check Tor exit list
curl -s "https://check.torproject.org/exit-addresses" | grep "1.2.3.4"

# Dan.me.uk Tor exit list
curl -s "https://www.dan.me.uk/torlist/" | grep "1.2.3.4"
```

**Geolocation Spoofing Indicators:**

- IP geolocation contradicts other intelligence (timezone, language, services)
- Datacenter IPs presenting as residential
- Impossible travel times between connection events
- ASN mismatch with claimed location

## ASN Lookups

Autonomous System Numbers (ASNs) identify networks on the internet. ASN intelligence reveals network ownership, infrastructure relationships, routing policies, and organizational structure.

**ASN Components:**

- **AS Number**: Unique identifier (e.g., AS15169)
- **AS Name**: Organization name (e.g., GOOGLE)
- **Network Ranges**: IP prefixes owned (CIDR notation)
- **Registry**: Regional Internet Registry (ARIN, RIPE, APNIC, etc.)
- **Country**: Primary operating country

**Intelligence Value:**

- Identify organization infrastructure scope
- Discover related IP ranges
- Map organizational relationships (subsidiaries, acquisitions)
- Understand routing relationships (peering, transit)
- Historical ASN changes indicate ownership transfers

### ASN Lookup Tools

**WHOIS ASN Query:**

```bash
# Direct ASN lookup
whois -h whois.radb.net AS15169

# IP to ASN mapping
whois -h whois.cymru.com " -v 8.8.8.8"

# Bulk IP to ASN (Team Cymru)
echo "begin
8.8.8.8
1.1.1.1
end" | nc whois.cymru.com 43

# Alternative format
whois -h whois.cymru.com " -f 8.8.8.8"
```

**Output Interpretation:**

```
AS      | IP               | BGP Prefix          | CC | Registry | Allocated
15169   | 8.8.8.8         | 8.8.8.0/24          | US | arin     | 1992-12-01
```

**asnlookup Tool:**

```bash
# Install
pip3 install asnlookup

# Lookup by domain
asnlookup -d google.com

# Lookup by IP
asnlookup -i 8.8.8.8

# Lookup by ASN
asnlookup -a AS15169

# Organization search
asnlookup -o "Google LLC"

# JSON output
asnlookup -d google.com -j
```

**amass intel (ASN Enumeration):**

```bash
# Reverse lookup: find all IPs in ASN
amass intel -asn 15169

# Organization to ASN mapping
amass intel -org "Google LLC"

# CIDR to ASN
amass intel -cidr 8.8.8.0/24

# Output to file
amass intel -asn 15169 -o google_ips.txt
```

**bgpview CLI:**

```bash
# Web interface
# https://bgpview.io/asn/15169

# API access
curl -s "https://api.bgpview.io/asn/15169" | jq

# Get prefixes for ASN
curl -s "https://api.bgpview.io/asn/15169/prefixes" | jq '.data.ipv4_prefixes[]'

# Get peers
curl -s "https://api.bgpview.io/asn/15169/peers" | jq

# Get upstreams
curl -s "https://api.bgpview.io/asn/15169/upstreams" | jq

# Get downstreams
curl -s "https://api.bgpview.io/asn/15169/downstreams" | jq
```

**Hurricane Electric BGP Toolkit:**

```
URL: https://bgp.he.net/AS15169
```

Provides comprehensive ASN intelligence:

- IP prefix listings
- Peering relationships
- Geographic distribution
- Network growth history
- Contact information

### ASN-Based Infrastructure Discovery

**Enumerate All IPs in ASN:**

```bash
# Using amass
amass intel -asn 15169 | tee google_asn_ips.txt

# Using BGP data
curl -s "https://api.bgpview.io/asn/15169/prefixes" | \
jq -r '.data.ipv4_prefixes[].prefix' | \
tee google_prefixes.txt

# Expand CIDR ranges to individual IPs (small ranges only)
# For /24: Use nmap or custom script
nmap -sL -n 8.8.8.0/24 | awk '/scan report/{print $5}'
```

**ASN to Domain Mapping:**

```bash
# Find domains resolving to ASN
# Method 1: Reverse DNS on IP ranges
for ip in $(cat asn_ips.txt); do
  host $ip | grep "domain name pointer"
done

# Method 2: Using Shodan
shodan search "asn:AS15169" --fields ip_str,hostnames | tee asn_domains.txt

# Method 3: Censys
# Web: https://search.censys.io/
# Query: autonomous_system.asn: 15169
```

**Related ASN Discovery:**

```bash
# Find organization's multiple ASNs
whois -h whois.radb.net "Google LLC" | grep "^aut-num:"

# Parent/subsidiary relationships
curl -s "https://api.bgpview.io/asn/15169/downstreams" | \
jq -r '.data[]|"\(.asn) - \(.name)"'
```

### ASN Intelligence Analysis

**Network Topology Mapping:**

**Peer Relationships:**

```bash
# Identify peering partners
curl -s "https://api.bgpview.io/asn/15169/peers" | \
jq -r '.data[] | "\(.asn) \(.name) \(.country_code)"'

# Large peer counts indicate:
# - Tier 1 or major content provider
# - Extensive global presence
# - Direct peering strategy (reduces transit costs)
```

**Upstream Providers:**

```bash
# Find transit providers
curl -s "https://api.bgpview.io/asn/15169/upstreams" | jq

# Zero upstreams = Tier 1 provider or self-sufficient network
# Multiple upstreams = redundancy, not Tier 1
```

**Downstream Customers:**

```bash
# Find customers buying transit
curl -s "https://api.bgpview.io/asn/15169/downstreams" | jq

# Large downstream counts indicate:
# - Transit provider (selling connectivity)
# - ISP or hosting company
# - Potential related organizations
```

**Geographic Distribution:**

```bash
# Map ASN's geographic presence
curl -s "https://api.bgpview.io/asn/15169/prefixes" | \
jq -r '.data.ipv4_prefixes[] | "\(.prefix) \(.name) \(.country_code)"' | \
awk '{print $3}' | sort | uniq -c | sort -rn

# Analysis insights:
# - Single country: Local/regional focus
# - Multiple countries: International presence
# - Specific regions: Regulatory or business strategy
```

### Historical ASN Data

**Tracking ASN Changes:**

**WHOIS History (Registration Changes):**

```bash
# Using SecurityTrails API
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/example.com/dns/a" | \
jq '.records[] | {first_seen, last_seen, values}'

# Correlate IP changes with ASN lookups
```

**BGP Route Changes:**

**RouteViews Project:**

```
URL: http://www.routeviews.org/
```

Historical BGP routing data for:

- Prefix announcements/withdrawals
- AS path changes
- Route hijacking detection
- Network instability analysis

**RIPEstat:**

```
URL: https://stat.ripe.net/AS15169
```

Provides historical:

- Routing information
- Prefix announcements
- BGP updates
- Abuse reports
- Network connectivity issues

### ASN-Based CTF Techniques

**Finding Hidden Infrastructure:**

```bash
# Organization owns ASN but not all IPs resolve to known domains
# Enumerate entire ASN address space

asn="AS15169"

# Get all prefixes
curl -s "https://api.bgpview.io/asn/15169/prefixes" | \
jq -r '.data.ipv4_prefixes[].prefix' > prefixes.txt

# Scan for web servers
cat prefixes.txt | while read prefix; do
  masscan -p80,443,8080,8443 "$prefix" --rate 1000 -oL masscan_results.txt
done

# Identify interesting hosts
cat masscan_results.txt | grep "open" | awk '{print $4}' | \
while read ip; do
  curl -sk -I "http://${ip}" | head -5
done
```

**Supply Chain Mapping:**

```bash
# Identify third-party services by ASN
# Example: Target uses AWS, Azure, Cloudflare

# Known service ASNs:
# AWS: AS16509, AS14618
# Azure: AS8075
# Cloudflare: AS13335
# Google Cloud: AS15169, AS396982

# Find target infrastructure on these ASNs
amass intel -asn 16509 | while read ip; do
  host $ip | grep "target.com"
done
```

**Acquisition Discovery:**

```bash
# ASN transfers indicate company acquisitions
# Historical WHOIS shows ASN ownership changes

whois -h whois.radb.net AS12345 | grep -E "changed:|mnt-by:"

# Check multiple dates via archived WHOIS data (requires paid service or manual collection)
```

## Historical Domain Data

Historical domain intelligence reveals past configurations, deleted content, infrastructure changes, and operational patterns through time-based analysis.

**Data Sources:**

- Web archives (content snapshots)
- DNS history (resolution changes)
- WHOIS history (ownership changes)
- Certificate logs (SSL/TLS evolution)
- Search engine caches (recent changes)

**Intelligence Value:**

- Recover deleted/modified content
- Track infrastructure evolution
- Identify security incidents (emergency changes)
- Map organizational changes (mergers, acquisitions)
- Find forgotten subdomains and services
- Reconstruct timelines for investigations

### Web Archive Services

**Wayback Machine (Internet Archive):**

```
URL: https://web.archive.org/
```

**Manual Interface:**

- Enter URL: `https://web.archive.org/web/*/example.com`
- View calendar of available snapshots
- Browse historical versions

**API Access:**

```bash
# Check if URL is archived
curl -s "http://archive.org/wayback/available?url=example.com" | jq

# Get all snapshots
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com&output=json" | jq

# Filter by date range
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com&from=20200101&to=20201231&output=json"

# Get specific snapshot
curl "https://web.archive.org/web/20200101000000/https://example.com"

# Download archived page
wget "https://web.archive.org/web/20200101000000/https://example.com"
```

**Waybackurls Tool:**

```bash
# Install
go install github.com/tomnomnom/waybackurls@latest

# Extract all archived URLs for domain
echo "example.com" | waybackurls

# Save to file
echo "example.com" | waybackurls > archived_urls.txt

# Find specific file types
echo "example.com" | waybackurls | grep -E '\.(pdf|doc|xls|txt|xml|json)$'

# Find sensitive paths
echo "example.com" | waybackurls | grep -E '(admin|login|backup|config|api)'

# Combine with other tools
echo "example.com" | waybackurls | grep "\.js$" | sort -u
```

**gau (GetAllUrls):**

```bash
# Install
go install github.com/lc/gau/v2/cmd/gau@latest

# Fetch URLs from multiple sources
gau example.com

# Specify providers
gau --providers wayback,commoncrawl,otx,urlscan example.com

# Include subdomains

gau --subs example.com

# Filter by blacklist

gau --blacklist png,jpg,gif,css example.com

# Output to file

gau example.com > all_urls.txt

# Combine with filtering

gau example.com | grep -E '.(js|json|xml|txt)$' | sort -u

# Time range filtering

gau --from 202001 --to 202012 example.com

```

**Archive.today (archive.is):**
```

URL: https://archive.today/ Manual: https://archive.today/example.com

```

Features:
- User-submitted snapshots
- Preserves dynamic content better than Wayback
- Bypasses some paywalls
- No official API [Unverified: third-party scrapers exist]

**CommonCrawl:**
```

URL: https://commoncrawl.org/ Index: https://index.commoncrawl.org/

````

Massive web crawl archive (petabytes):
```bash
# Search CommonCrawl index
curl -s "https://index.commoncrawl.org/CC-MAIN-2024-10-index?url=example.com&output=json"

# Get specific page
# Requires parsing CDX output for WARC file location
````

### Historical DNS Data

**SecurityTrails:**

```bash
# Historical DNS records (API required)
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/example.com/dns/a"

# WHOIS history
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/example.com/whois"

# Historical subdomains
curl -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/domain/example.com/subdomains"
```

**Output Analysis:**

```bash
# Track IP changes over time
curl -s -H "APIKEY: your-api-key" \
  "https://api.securitytrails.com/v1/history/example.com/dns/a" | \
jq -r '.records[] | "\(.first_seen) -> \(.last_seen): \(.values[].ip)"'

# Identify hosting migrations
# Sudden IP changes indicate:
# - Provider changes
# - Infrastructure upgrades
# - Security incidents (DDoS mitigation, breach response)
# - Organizational changes
```

**DNSHistory.org:**

```
URL: https://dnshistory.org/
```

Free historical DNS lookup:

- A, AAAA, MX, NS, TXT records
- Timeline visualization
- Limited history depth (varies by domain)

**Passive DNS Databases:**

**CIRCL Passive DNS:**

```bash
# Query (requires API access)
curl -s "https://www.circl.lu/pdns/query/example.com" | jq

# Returns historical DNS resolutions collected from sensors
```

**RiskIQ (PassiveTotal):**

```
URL: https://community.riskiq.com/
```

Community edition provides:

- Historical DNS records
- WHOIS history
- SSL certificate history
- Tracker/component analysis

**VirusTotal:**

```bash
# Historical DNS (requires API key)
curl -H "x-apikey: YOUR_API_KEY" \
  "https://www.virustotal.com/api/v3/domains/example.com/resolutions"

# Output includes resolution history
curl -s -H "x-apikey: YOUR_API_KEY" \
  "https://www.virustotal.com/api/v3/domains/example.com/resolutions" | \
jq -r '.data[] | "\(.attributes.date) \(.attributes.ip_address)"'
```

### Historical WHOIS Data

**DomainTools Historical WHOIS:**

```
URL: https://whois.domaintools.com/example.com/history
```

Tracks changes in:

- Registrant information
- Nameservers
- Registration dates
- Administrative contacts
- Email addresses

**WhoisXML API:**

```bash
# Historical WHOIS records (paid API)
curl "https://www.whoisxmlapi.com/whoisserver/WhoisService?apiKey=YOUR_KEY&domainName=example.com&outputFormat=JSON&da=2"

# Parse historical changes
# Reveals ownership transfers, contact changes, infrastructure modifications
```

**Manual Historical WHOIS Collection:**

```bash
# No free comprehensive source exists
# Strategy: Collect current WHOIS regularly, build own database

# Automated collection script
#!/bin/bash
domain=$1
date=$(date +%Y%m%d)
whois $domain > "whois_${domain}_${date}.txt"

# Schedule via cron for long-term tracking
# 0 0 * * 0 /path/to/whois_collect.sh example.com
```

### Search Engine Caches

**Google Cache:**

```
URL: cache:example.com
Search: site:example.com cache:
```

Access cached version:

```
https://webcache.googleusercontent.com/search?q=cache:example.com
```

**Limitations:**

- Only stores recent snapshot (days to weeks)
- Not all pages cached
- Google removes cache links from search results (direct URL still works)

**Bing Cache:**

```
Search operator: site:example.com
Click dropdown arrow next to result → "Cached"
```

**Alternative: Google Cache Checker:**

```bash
# Check if cached version exists
curl -s "https://webcache.googleusercontent.com/search?q=cache:example.com" | grep -q "about this page"
```

### Historical Certificate Data

Already covered in CT Logs section, but temporal analysis:

**Certificate Issuance Timeline:**

```bash
# Track certificate changes over time
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | "\(.not_before) \(.not_after) \(.name_value)"' | \
sort

# Identify patterns:
# - Regular renewal cycles (automated management)
# - Emergency reissuance (key compromise, security incident)
# - Infrastructure expansion (new subdomains appear)
# - Service deprecation (certificates expire without renewal)
```

**Certificate Authority Changes:**

```bash
# Track CA changes (indicates policy/provider changes)
curl -s "https://crt.sh/?q=%.example.com&output=json" | \
jq -r '.[] | "\(.not_before) \(.issuer_name)"' | \
sort -k1

# CA migration timeline reveals:
# - Move to Let's Encrypt: Automation adoption
# - Move to paid CA: Compliance/warranty requirements
# - Multiple CAs: Large organization, different teams/policies
```

### Deleted Content Recovery

**Finding Deleted Pages:**

```bash
# Method 1: Wayback Machine
echo "example.com" | waybackurls | grep "/deleted-page"

# Method 2: Google cache (if recently deleted)
# Google: site:example.com "deleted page title"

# Method 3: Search engine snippets
# Even if page deleted, search results may preserve descriptions
```

**Recovering Deleted Files:**

```bash
# Find archived versions of specific file
echo "example.com" | waybackurls | grep "sensitive_document.pdf"

# Download archived file
wget "https://web.archive.org/web/20200101000000/https://example.com/sensitive_document.pdf"

# Extract archived directories
echo "example.com" | waybackurls | grep "/backup/" | sort -u
```

**robots.txt Historical Analysis:**

```bash
# Fetch historical robots.txt
echo "example.com/robots.txt" | waybackurls

# Download specific snapshot
curl "https://web.archive.org/web/20200101000000/https://example.com/robots.txt"

# Analysis reveals:
# - Previously disallowed paths (interesting targets)
# - Deleted admin panels
# - Forgotten API endpoints
# - Staging/development environments
```

### Timeline Reconstruction

**Comprehensive Domain Timeline:**

```bash
#!/bin/bash
domain=$1

echo "=== WHOIS Timeline ==="
whois $domain | grep -E "Creation Date|Updated Date|Expiry Date"

echo -e "\n=== DNS History ==="
curl -s -H "APIKEY: $ST_KEY" \
  "https://api.securitytrails.com/v1/history/${domain}/dns/a" | \
jq -r '.records[] | "\(.first_seen) -> \(.last_seen): \(.values[].ip)"'

echo -e "\n=== Certificate Timeline ==="
curl -s "https://crt.sh/?q=%.${domain}&output=json" | \
jq -r '.[] | "\(.not_before) \(.name_value)"' | \
sort -u | head -20

echo -e "\n=== Archive Snapshot Dates ==="
curl -s "http://web.archive.org/cdx/search/cdx?url=${domain}&output=json&limit=10" | \
jq -r '.[] | .[1]' | grep -v "timestamp"

echo -e "\n=== Content Changes ==="
echo "$domain" | waybackurls | wc -l
echo "Total archived URLs found"
```

**Event Correlation:**

```bash
# Combine timeline sources to identify:
# - IP change + certificate reissue = Infrastructure migration
# - WHOIS update + DNS change = Ownership transfer
# - Multiple certificate reissues in short time = Security incident
# - Sudden wayback snapshot increase = Major site redesign
# - Gap in archives = Site downtime or blocking archival
```

### CTF Historical Data Techniques

**Flag Archaeology:**

```bash
# Flags often hidden in historical content
echo "ctf-challenge.com" | waybackurls | grep -iE 'flag|key|secret|token'

# Download all historical versions of specific page
curl -s "http://web.archive.org/cdx/search/cdx?url=ctf-challenge.com/flag.txt&output=json" | \
jq -r '.[] | "https://web.archive.org/web/\(.[1])/\(.[2])"' | \
while read url; do
  curl -s "$url"
  echo "---"
done
```

**Configuration File Discovery:**

```bash
# Historical config files may contain credentials
echo "target.com" | waybackurls | grep -E '\.(xml|json|yaml|yml|conf|config|ini|env)$'

# Common targets:
# - .env files
# - config.php
# - web.config
# - settings.xml
# - database.yml
```

**API Endpoint Discovery:**

```bash
# Find historical API endpoints
echo "api.target.com" | waybackurls | grep -E '/api/|/v[0-9]+/' | sort -u

# Identify deprecated endpoints (may have weaker security)
# Test historical endpoints against current infrastructure
```

**Email Harvesting from History:**

```bash
# Extract emails from archived content
echo "target.com" | waybackurls | \
while read url; do
  curl -s "$url" | grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
done | sort -u

# Historical contact information reveals:
# - Personnel changes
# - Organizational structure
# - Valid email format patterns
```

**Subdomain Discovery from Archives:**

```bash
# Extract subdomains from archived links
echo "target.com" | waybackurls | \
grep -Eo 'https?://[a-zA-Z0-9.-]+\.target\.com' | \
sed 's|https\?://||' | \
sort -u

# Many subdomains no longer linked may still be active
# Verify with DNS resolution
```

### Historical Data Correlation

**Multi-Source Intelligence Fusion:**

```bash
#!/bin/bash
domain=$1

# Collect from all sources
echo "[*] Collecting wayback URLs..."
echo "$domain" | waybackurls > wayback.txt

echo "[*] Collecting DNS history..."
curl -s -H "APIKEY: $ST_KEY" \
  "https://api.securitytrails.com/v1/history/${domain}/dns/a" > dns_hist.json

echo "[*] Collecting certificates..."
curl -s "https://crt.sh/?q=%.${domain}&output=json" > certs.json

echo "[*] Collecting current subdomains..."
subfinder -d $domain -silent > current_subs.txt

# Find subdomains that existed historically but not currently
cat wayback.txt | grep -Eo '[a-zA-Z0-9.-]+\.'${domain} | sort -u > historical_subs.txt
comm -23 historical_subs.txt current_subs.txt > forgotten_subs.txt

echo "[+] Found $(wc -l < forgotten_subs.txt) forgotten subdomains"
cat forgotten_subs.txt

# Test if forgotten subdomains still resolve
cat forgotten_subs.txt | while read sub; do
  if host "$sub" >/dev/null 2>&1; then
    echo "[!] Still active: $sub"
  fi
done
```

**Change Detection Monitoring:**

```bash
# Periodic monitoring for changes
#!/bin/bash
domain=$1
baseline="baseline_${domain}.txt"
current="current_${domain}.txt"

# Create baseline if doesn't exist
if [ ! -f "$baseline" ]; then
  dig $domain A +short > "$baseline"
  echo "[*] Baseline created"
  exit 0
fi

# Check current state
dig $domain A +short > "$current"

# Compare
if ! diff -q "$baseline" "$current" > /dev/null; then
  echo "[!] Change detected for $domain"
  diff "$baseline" "$current"
  
  # Log change
  echo "$(date) - Change detected" >> "changes_${domain}.log"
  
  # Update baseline
  mv "$current" "$baseline"
else
  echo "[*] No changes for $domain"
  rm "$current"
fi
```

### Rate Limiting and Ethical Considerations

**Archive.org Rate Limits:**

- Wayback Machine API: No strict documented limits, but rate limiting occurs with excessive requests
- CDX API: More permissive, but still subject to abuse prevention
- Best practice: 1-2 second delays between requests

**Ethical Archive Access:**

```bash
# Respect robots.txt (even for archives)
# Some organizations request archive exclusion

# Check current robots.txt
curl -s "https://example.com/robots.txt" | grep -i "archive"

# If blocked, respect the exclusion
# Wayback honors robots.txt retroactively for some cases
```

**Cache Behavior:**

- Search engine caches are temporary
- Accessing cache doesn't notify target
- Cache may contain sensitive data unintentionally exposed
- If sensitive data found, consider responsible disclosure

---

**Important Related Topics:**

- **Google Dorking**: Advanced search operators for OSINT
- **Shodan/Censys**: Internet-wide scanning and historical data
- **OSINT Automation**: Scripting reconnaissance workflows
- **Social Media Intelligence**: Platform-specific techniques
- **Passive DNS**: Real-time and historical DNS monitoring

---

# Email Intelligence

## Email Header Analysis

Email headers contain routing information, authentication records, and metadata revealing sender identity, infrastructure, and message path. Headers are critical for tracing email origin, detecting spoofing, and identifying malicious sources.

### Accessing Email Headers

**Gmail:**

- Open email → Three dots menu → "Show original"
- Displays full headers and original message

**Outlook (Web):**

- Open email → Three dots → "View" → "View message details"

**Outlook (Desktop):**

- Open email → File → Properties → Internet headers

**Apple Mail:**

- View → Message → All Headers

**Thunderbird:**

- View → Message Source (Ctrl+U)

**Raw Header Format:** Headers appear in reverse chronological order (most recent first).

### Critical Header Fields

**From:** - Displayed sender address

```
From: user@example.com
```

[Unverified] This field can be easily spoofed and should not be trusted without supporting authentication headers.

**Return-Path:** - Actual sender/bounce address

```
Return-Path: <actual-sender@example.com>
```

This is more reliable than From: for identifying true sender.

**Reply-To:** - Response destination

```
Reply-To: different@example.com
```

Often differs from From: in phishing attempts.

**Received:** - Server routing chain

```
Received: from mail.example.com (mail.example.com [192.168.1.1])
    by mx.recipient.com (Postfix) with ESMTPS id ABC123
    for <recipient@example.com>; Mon, 20 Oct 2025 10:15:30 +0000 (UTC)
```

Each mail server adds a Received: header. Read **bottom-to-top** to trace message path from origin to destination.

**Key elements:**

- `from` - Sending server hostname/IP
- `by` - Receiving server
- Transport protocol (SMTP, ESMTP, ESMTPS)
- Timestamp
- Message ID

**Message-ID:** - Unique identifier

```
Message-ID: <abc123.def456@example.com>
```

Format often reveals sending system/software.

**X-Originating-IP:** - Sender's IP (when available)

```
X-Originating-IP: [203.0.113.45]
```

Not always present; depends on mail server configuration.

**X-Mailer:** or **User-Agent:** - Sending client software

```
X-Mailer: Microsoft Outlook 16.0
User-Agent: Mozilla/5.0 (compatible; MSIE 9.0)
```

**Content-Type:** - Message format and encoding

```
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64
```

**MIME-Version:** - MIME protocol version

```
MIME-Version: 1.0
```

### Authentication Headers

**SPF (Sender Policy Framework):**

```
Received-SPF: pass (google.com: domain of sender@example.com designates 192.168.1.1 as permitted sender)
```

**Results:**

- `pass` - IP authorized to send
- `fail` - IP not authorized (likely spoofed)
- `softfail` - IP not explicitly authorized (~all in SPF)
- `neutral` - No policy statement (?all)
- `none` - No SPF record exists

**DKIM (DomainKeys Identified Mail):**

```
DKIM-Signature: v=1; a=rsa-sha256; d=example.com; s=selector;
    h=from:to:subject:date;
    bh=base64hash;
    b=signaturehash
```

**Authentication-Results:**

```
Authentication-Results: mx.google.com;
    spf=pass smtp.mailfrom=example.com;
    dkim=pass header.d=example.com;
    dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=example.com
```

Combined authentication verdict:

- `spf=pass/fail`
- `dkim=pass/fail`
- `dmarc=pass/fail`

**DMARC (Domain-based Message Authentication):**

```
dmarc=pass (p=REJECT sp=REJECT dis=NONE)
```

Policy (p=):

- `none` - Monitor only
- `quarantine` - Send to spam
- `reject` - Reject message

### Header Analysis Workflow

**1. Verify Sender Authenticity:**

- Check SPF, DKIM, DMARC results
- Compare From: with Return-Path:
- Verify domain matches expected sender

**2. Trace Message Path:**

- Read Received: headers bottom-to-top
- Extract all IP addresses
- Note timestamp progression
- Identify delays or unusual hops

**3. Identify Sending Infrastructure:**

- X-Originating-IP
- First Received: header IP
- Message-ID domain
- X-Mailer information

**4. Check for Red Flags:**

- Authentication failures
- Mismatched From:/Return-Path:
- Suspicious Reply-To:
- Generic Message-ID format
- Missing expected headers
- IP geolocation mismatches

### Header Analysis Tools

**MXToolbox Header Analyzer:**

```
https://mxtoolbox.com/EmailHeaders.aspx
```

- Paste headers for automated analysis
- Shows authentication results
- Displays routing path
- Identifies delays

**Google Admin Toolbox:**

```
https://toolbox.googleapps.com/apps/messageheader/
```

- Visualizes message path
- Highlights authentication
- Shows timeline

**mail-parser (Python):**

```bash
pip install mail-parser

# Parse EML file
mail-parser -f email.eml

# Extract to JSON
mail-parser -f email.eml -j > output.json
```

```python
import mailparser

mail = mailparser.parse_from_file('email.eml')

print(mail.from_)
print(mail.to)
print(mail.subject)
print(mail.date)
print(mail.body)
print(mail.headers)
print(mail.received)

# Extract IPs from Received headers
for received in mail.received:
    print(received['from'])
    if 'ip' in received:
        print(received['ip'])
```

**emailrep.io API:**

```bash
curl "https://emailrep.io/query/email@example.com"
```

Returns reputation data:

- Reputation score
- Known malicious activity
- Data breach involvement
- Associated domains

### IP and Domain Analysis from Headers

**Extract IPs from Received: headers:**

```bash
# Using grep
grep "Received:" headers.txt | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"
```

**WHOIS Lookup:**

```bash
whois 203.0.113.45
```

**Geolocation:**

```bash
curl "http://ip-api.com/json/203.0.113.45"
```

**Reverse DNS:**

```bash
dig -x 203.0.113.45 +short
host 203.0.113.45
```

**Check IP Reputation:**

- AbuseIPDB: abuseipdb.com
- IPVoid: ipvoid.com
- Talos Intelligence: talosintelligence.com

### Timestamp Analysis

Extract all timestamps from Received: headers:

```bash
grep "Received:" headers.txt | grep -oE "[0-9]{1,2} [A-Z][a-z]{2} [0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}"
```

**Red flags:**

- Timestamps out of sequence
- Large gaps between hops
- Future timestamps
- Timezone inconsistencies

### Advanced Header Examination

**X-Headers (Custom headers):** Many organizations add custom headers:

```
X-Spam-Score: 5.2
X-Spam-Status: Yes
X-Virus-Scanned: ClamAV
X-Priority: 1 (Highest)
X-MS-Exchange-Organization-AuthAs: Internal
X-Forwarded-For: 10.0.0.1
```

**Boundary Strings in Multipart Messages:**

```
Content-Type: multipart/mixed; boundary="----=_Part_12345"
```

Unique boundaries can fingerprint sending systems.

**List Headers:** For mailing lists:

```
List-Unsubscribe: <mailto:unsubscribe@example.com>
List-Id: <list.example.com>
```

### CTF Application

**Flag Hiding in Headers:**

- Custom X-headers: `X-CTF-Flag: flag{...}`
- Message-ID domain clues
- Encoded in Received: comments
- Base64 in DKIM signatures (fake)

**Sender Identification:**

- Trace to specific IP/domain
- Correlate with other OSINT data
- Identify mail server software versions

**Timeline Reconstruction:** Establish when email was actually sent vs. claimed time.

## Email Validation and Verification

Email validation confirms address format correctness; verification checks if an address actually exists and can receive mail.

### Syntax Validation

**RFC 5321/5322 Format:**

```
local-part@domain
```

**Basic regex pattern:**

```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

[Unverified] This regex covers common cases but doesn't fully implement RFC 5322, which allows complex quoted strings and comments.

**Python validation:**

```python
import re

def validate_email_syntax(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None
```

**Using email-validator library:**

```bash
pip install email-validator
```

```python
from email_validator import validate_email, EmailNotValidError

try:
    validated = validate_email("user@example.com")
    email = validated.email  # Normalized form
    print(f"Valid: {email}")
except EmailNotValidError as e:
    print(f"Invalid: {str(e)}")
```

### DNS-Based Verification

**MX Record Lookup:**

Verify domain has mail servers configured:

```bash
# Using dig
dig MX example.com +short

# Using host
host -t MX example.com

# Using nslookup
nslookup -type=MX example.com
```

**Python DNS check:**

```python
import dns.resolver

def check_mx_record(domain):
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        return [(r.preference, str(r.exchange)) for r in mx_records]
    except:
        return None

# Usage
mx = check_mx_record('example.com')
if mx:
    print(f"MX records found: {mx}")
else:
    print("No MX records")
```

### SMTP Verification

**SMTP VRFY command:**

[Unverified] Most modern mail servers disable VRFY to prevent email harvesting, so this method has limited effectiveness.

```bash
telnet mail.example.com 25
HELO test.com
VRFY user@example.com
QUIT
```

Responses:

- `250` - User exists
- `550` - User not found
- `252` - Cannot verify (most common, for privacy)

**SMTP RCPT TO check:**

More reliable than VRFY:

```bash
telnet mail.example.com 25
HELO test.com
MAIL FROM: <verify@test.com>
RCPT TO: <user@example.com>
QUIT
```

Responses:

- `250` - Accepted
- `550` - Mailbox unavailable
- `450/451` - Temporary error

**Limitations:**

- Greylisting may cause false negatives
- Catch-all domains accept all addresses
- Rate limiting blocks bulk checks

### Email Verification Services

**hunter.io Email Verifier:**

```bash
curl "https://api.hunter.io/v2/email-verifier?email=user@example.com&api_key=YOUR_API_KEY"
```

Returns:

- Status (valid/invalid/accept_all/unknown)
- Score (0-100)
- SMTP check results
- MX records
- Disposable status

**NeverBounce API:**

```bash
curl -X POST "https://api.neverbounce.com/v4/single/check" \
  -d "key=YOUR_API_KEY" \
  -d "email=user@example.com"
```

**ZeroBounce API:**

```bash
curl "https://api.zerobounce.net/v2/validate?api_key=YOUR_API_KEY&email=user@example.com"
```

**EmailListVerify API:**

```bash
curl "https://apps.emaillistverify.com/api/verifyEmail?secret=YOUR_KEY&email=user@example.com"
```

**Limitations of verification services:**

- Paid services (limited free tiers)
- Rate limits
- Privacy concerns (they see addresses you check)
- [Inference] Accuracy varies by provider and target domain

### Catch-All Domain Detection

Catch-all domains accept email to any address:

```bash
# Test with random address
user12345xyz@example.com
```

If accepted, likely catch-all. Makes verification uncertain.

### Role-Based Email Detection

Common role addresses:

```
admin@
support@
info@
sales@
contact@
postmaster@
webmaster@
noreply@
```

These often exist but may route to groups/queues rather than individuals.

### Bulk Email Verification Tools

**email-verify (npm package):**

```bash
npm install -g email-verify

email-verify user@example.com
```

**verify-email (Python):**

```bash
pip install verify-email
```

```python
from verify_email import verify_email

result = verify_email('user@example.com')
print(result)  # True/False
```

**holehe (checks account existence on platforms):**

```bash
pip install holehe

holehe user@example.com
```

Checks if email is registered on:

- Twitter, Instagram, Facebook
- GitHub, GitLab
- Adobe, Spotify, Netflix
- Many other platforms

### CTF Applications

**Username Enumeration:**

- Verify target addresses exist
- Identify valid vs. invalid accounts
- Map organizational structure from email patterns

**Domain Intelligence:**

- MX records reveal mail infrastructure
- SPF records show authorized sending IPs
- DMARC policies indicate security posture

**Pattern Detection:**

```
firstname.lastname@example.com
f.lastname@example.com
firstnamelastname@example.com
```

Generate and verify patterns to find valid addresses.

## Breach Database Searches

Breach databases contain credentials from data breaches. Searching these reveals compromised accounts, password patterns, and associated user information.

### Have I Been Pwned (HIBP)

Most comprehensive public breach database.

**Web Interface:**

```
https://haveibeenpwned.com
```

**API v3:**

Requires API key (free for rate-limited use):

```bash
# Check email
curl "https://haveibeenpwned.com/api/v3/breachedaccount/user@example.com" \
  -H "hibp-api-key: YOUR_API_KEY"

# Get breach details
curl "https://haveibeenpwned.com/api/v3/breach/Adobe"

# Check all breaches
curl "https://haveibeenpwned.com/api/v3/breaches"

# Check password (Pwned Passwords)
# SHA-1 hash first 5 chars
echo -n 'password' | sha1sum | cut -c1-5
curl "https://api.pwnedpasswords.com/range/5BAA6"
```

**Pwned Passwords:**

k-Anonymity API - only sends first 5 hash chars:

```python
import hashlib
import requests

def check_pwned_password(password):
    sha1 = hashlib.sha1(password.encode()).hexdigest().upper()
    prefix, suffix = sha1[:5], sha1[5:]
    
    response = requests.get(f"https://api.pwnedpasswords.com/range/{prefix}")
    hashes = (line.split(':') for line in response.text.splitlines())
    
    for hash_suffix, count in hashes:
        if hash_suffix == suffix:
            return int(count)
    return 0

count = check_pwned_password("password123")
print(f"Found {count} times in breaches")
```

**API Response Data:**

- Breach name
- Breach date
- Compromised data types (emails, passwords, credit cards, etc.)
- Number of affected accounts

### DeHashed

Search engine for breached data (paid service with API).

```bash
curl "https://api.dehashed.com/search?query=email:user@example.com" \
  -u "email@example.com:API_KEY"
```

Returns:

- Plain-text passwords (when available)
- Hashed passwords
- Associated usernames
- IP addresses
- Phone numbers
- Names

### LeakCheck

Breach search service (paid).

**API:**

```bash
curl "https://leakcheck.io/api/public?key=YOUR_KEY&check=user@example.com&type=email"
```

### Snusbase

Breach database search (paid).

**Search types:**

- Email
- Username
- Password
- IP address
- Name

### Intelligence X

OSINT search engine including breach data (paid with limited free).

```bash
curl "https://2.intelx.io/phonebook/search?k=API_KEY&term=user@example.com&buckets=&lookuplevel=0&maxresults=100&media=0&target=0"
```

### WeLeakInfo Alternative Sources

After WeLeakInfo seizure, alternatives emerged:

**Breach Forums/RaidForums archives:**

- Historical dumps sometimes shared
- Requires careful vetting (many scams)
- Legal/ethical concerns

[Unverified] Accessing and using stolen credential data may violate laws in many jurisdictions, including computer fraud and unauthorized access statutes.

### Self-Hosted Breach Searching

**breach-parse:**

```bash
git clone https://github.com/hmaverickadams/breach-parse
cd breach-parse

# Search email
./breach-parse.sh user@example.com breaches.txt
```

**grep through local dumps:**

```bash
# Search for email
grep -r "user@example.com" /path/to/breach/dumps/

# Search for domain
grep -r "@example.com" /path/to/breach/dumps/ | cut -d: -f2 | sort -u
```

### Password Analysis from Breaches

**hashcat for hash cracking:**

```bash
# MD5
hashcat -m 0 -a 0 hashes.txt wordlist.txt

# SHA-1
hashcat -m 100 -a 0 hashes.txt wordlist.txt

# bcrypt
hashcat -m 3200 -a 0 hashes.txt wordlist.txt
```

**Pattern extraction:**

```bash
# Extract email domains
cat emails.txt | cut -d@ -f2 | sort | uniq -c | sort -rn

# Common passwords from plain-text leaks
cat passwords.txt | sort | uniq -c | sort -rn | head -20
```

### Ethical and Legal Considerations

**Important warnings:**

1. Accessing breach databases containing stolen credentials may violate:
    
    - Computer Fraud and Abuse Act (CFAA) in US
    - Computer Misuse Act in UK
    - Similar laws in other jurisdictions
2. Using breached credentials to access accounts is illegal unauthorized access
    
3. Ethical use cases:
    
    - Checking your own accounts
    - Authorized penetration testing
    - Defensive security research
    - CTF competitions with explicit permissions
4. HIBP API specifically designed for legitimate defensive use
    

### CTF Applications

**Credential Stuffing Detection:** Check if target email/username appears in breaches with known passwords.

**Password Pattern Analysis:** Identify common patterns used by target organization.

**Email Correlation:** Link email addresses to usernames, real names, other identifiers.

**Timeline Analysis:** Determine when account was active based on breach dates.

**Related Account Discovery:** Find other accounts using same email from different breaches.

## Email Tracking and Tracing

Email tracking monitors recipient behavior (opens, clicks, location). Email tracing identifies sender infrastructure and message path.

### Email Tracking Mechanisms

**Tracking Pixels:**

Invisible 1x1 pixel images embedded in HTML emails:

```html
<img src="https://tracking.example.com/pixel.gif?id=UNIQUE_ID" width="1" height="1" />
```

When email opens, browser requests image, logging:

- Open timestamp
- IP address
- User agent
- Approximate location (from IP)

**Link Tracking:**

URLs rewritten to pass through tracking server:

Original:

```
https://example.com/page
```

Tracked:

```
https://tracking.example.com/click?id=UNIQUE_ID&url=https://example.com/page
```

Logs click time, IP, redirect chain.

**Read Receipts:**

**MDN (Message Disposition Notification):**

```
Disposition-Notification-To: sender@example.com
```

Recipient's client may send automated read receipt.

[Unverified] Most modern email clients disable automatic read receipts by default for privacy reasons.

### Email Tracking Services

**Mailtrack (Gmail):**

- Browser extension
- Double checkmarks for read status
- Free tier available

**Streak:**

- Gmail CRM with tracking
- Open/click tracking
- Email scheduling

**Yesware:**

- Sales email tracking
- Open/click/reply tracking
- Templates and campaigns

**HubSpot:**

- Marketing email tracking
- Detailed analytics
- Link performance

**MailChimp, SendGrid, etc.:** Commercial email platforms with built-in tracking.

### Detecting Email Tracking

**Manual inspection:**

View HTML source:

```html
<!-- Look for tracking pixels -->
<img src="https://track.example.com/..." height="1" width="1">

<!-- Look for redirect URLs -->
<a href="https://click.example.com/redirect?...">
```

**Tracking domains:** Common tracking services:

```
mandrillapp.com/track
mailgun.org/o/
sendgrid.net/wf/
ct.sendgrid.net/
mailchimp.com/track
```

**Browser extensions:**

**Ugly Email (Chrome/Firefox):**

- Detects tracking pixels
- Shows tracking icon

**PixelBlock (Chrome):**

- Blocks tracking pixels in Gmail
- Shows which emails have trackers

**Privacy Badger:**

- Blocks third-party trackers
- Works in email HTML views

### Preventing Email Tracking

**Client-side blocking:**

**Disable image loading:**

- Gmail: Settings → Images → "Ask before displaying external images"
- Outlook: File → Options → Trust Center → Automatic Download → Uncheck images

**Use plain-text email:** Tracking pixels require HTML.

**Email clients with protection:**

- ProtonMail (blocks tracking by default)
- Tutanota
- Apple Mail Privacy Protection (iOS 15+, macOS 12+)

**Apple Mail Privacy Protection:** Loads images through proxy, masking real IP and caching results.

### Email Tracing Techniques

**Header analysis:** (Covered in detail in Email Header Analysis section)

Key steps:

1. Extract all Received: headers
2. Identify originating IP
3. Perform WHOIS/geolocation
4. Check authentication results

**Message-ID analysis:**

```
Message-ID: <abc123.def456@mail.example.com>
```

Domain often reveals actual sending infrastructure.

**X-Originating-IP extraction:**

```bash
grep -i "X-Originating-IP" headers.txt
```

**Return-Path analysis:**

```
Return-Path: <bounce-12345@example.com>
```

Bounce address domain shows sending infrastructure.

### Link Analysis in Emails

**URL extraction:**

```bash
# From HTML email
grep -oP 'href="\K[^"]+' email.html

# More sophisticated parsing
cat email.html | grep -o 'http[s]*://[^"]*' | sort -u
```

**URL expansion:**

For shortened URLs:

```bash
curl -sIL "http://bit.ly/XXXXX" | grep -i location

# Python
import requests
response = requests.head("http://bit.ly/XXXXX", allow_redirects=True)
print(response.url)
```

**unshorten.me API:**

```bash
curl "https://unshorten.me/api/v2/unshorten?url=http://bit.ly/XXXXX"
```

**Check URL reputation:**

```bash
# VirusTotal API
curl "https://www.virustotal.com/api/v3/urls/URL_ID" \
  -H "x-apikey: YOUR_API_KEY"

# URLScan.io
curl "https://urlscan.io/api/v1/search/?q=domain:example.com"
```

### Attachment Analysis

**Extract attachments:**

```bash
# Using munpack
munpack email.eml

# Using ripmime
ripmime -i email.eml -d output_dir
```

**File hash analysis:**

```bash
# Calculate hashes
md5sum attachment.exe
sha256sum attachment.exe

# Check VirusTotal
curl "https://www.virustotal.com/api/v3/files/SHA256_HASH" \
  -H "x-apikey: YOUR_API_KEY"
```

### Email Journey Visualization

**Google Admin Toolbox:** Visualizes message path with timeline.

**MXToolbox:** Shows hop-by-hop progression with delays.

**Manual timeline extraction:**

```python
import email
import dateutil.parser

with open('email.eml', 'r') as f:
    msg = email.message_from_file(f)

# Extract Received headers with timestamps
received = msg.get_all('Received', [])
for r in received:
    # Parse timestamp
    if '; ' in r:
        timestamp_str = r.split('; ')[-1]
        try:
            timestamp = dateutil.parser.parse(timestamp_str)
            print(f"{timestamp}: {r.split()[1]}")
        except:
            pass
```

### Sender Reputation Analysis

**SenderScore:**

```
https://senderscore.org
```

Checks IP reputation (0-100 score).

**Talos Intelligence:**

```bash
# Check IP reputation
curl "https://talosintelligence.com/reputation_center/lookup?search=IP_ADDRESS"
```

**Spamhaus:**

```bash
# Check if IP is blacklisted
host IP_ADDRESS.zen.spamhaus.org
```

Returns non-zero if blacklisted.

**MXToolbox Blacklist Check:**

```bash
# Check multiple blacklists
curl "https://mxtoolbox.com/api/v1/lookup/blacklist/IP_ADDRESS"
```

### CTF Applications

**Hidden Tracking IDs:** Unique identifiers in tracking URLs may reveal:

- Sequential patterns
- Encoded user information
- Flags in hex/base64

**Infrastructure Mapping:** Trace emails to identify sending servers, correlate with other challenges.

**Timeline Forensics:** Reconstruct event timeline from email timestamps.

**Social Engineering Detection:** Identify spoofed/tracked phishing emails.

## Disposable Email Detection

Disposable (temporary) email services provide short-lived addresses for avoiding spam or protecting identity. Detection identifies these addresses, which may indicate:

- Fake registrations
- Abuse/spam accounts
- Privacy-conscious users
- CTF participants hiding identity

### Common Disposable Email Providers

**Popular services:**

- 10minutemail.com
- Guerrilla Mail
- Temp Mail
- Mailinator
- Throwaway Mail
- YOPmail
- TempInbox
- DisposableMail

**Characteristics:**

- No registration required
- Public/shared inboxes (sometimes)
- Short lifespan (minutes to hours)
- Multiple domain aliases

### Detection Methods

**Domain Blacklists:**

Maintain list of known disposable domains:

```
10minutemail.com
guerrillamail.com
mailinator.com
tempmail.com
throwam.com
yopmail.com
```

**Check against list:**

```python
disposable_domains = ['10minutemail.com', 'guerrillamail.com', 'mailinator.com']

def is_disposable(email):
    domain = email.split('@')[1]
    return domain in disposable_domains
```

**Community-maintained lists:**

**disposable-email-domains (GitHub):**

```bash
git clone https://github.com/disposable-email-domains/disposable-email-domains
```

Contains 60,000+ domains (text file).

```python
# Load list
with open('disposable_email_domains/disposable_email_blocklist.conf') as f:
    disposable = set(line.strip() for line in f)

def check_email(email):
    domain = email.split('@')[1].lower()
    return domain in disposable
```

**FGRibreau list:**

```bash
curl "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.txt"
```

### Detection APIs

**Mailcheck.ai:**

```bash
curl "https://api.mailcheck.ai/email/user@example.com"
```

Returns:

- Disposable status
- Domain validity
- MX records
- SMTP check

**Abstract Email Validation API:**

```bash
curl "https://emailvalidation.abstractapi.com/v1/?api_key=YOUR_KEY&email=user@example.com"
```

Returns:

```json
{
  "email": "user@example.com",
  "is_disposable_email": {
    "value": false
  }
}
```

**Kickbox API:**

```bash
curl "https://api.kickbox.com/v2/verify?email=user@example.com&apikey=YOUR_KEY"
```

Returns disposable status in response.

**EmailListVerify:**

```bash
curl "https://apps.emaillistverify.com/api/verifyEmail?secret=YOUR_KEY&email=user@example.com"
```

**MailboxValidator:**

```bash
curl "https://api.mailboxvalidator.com/v1/validation/single?key=YOUR_KEY&email=user@example.com&format=json"
```

### Python Libraries

**email-validator with disposable check:**

```bash
pip install email-validator
```

```python
from email_validator import validate_email, EmailNotValidError

try:
    v = validate_email("user@tempmail.com", check_deliverability=True)
    # Additional disposable check needed separately
except EmailNotValidError as e:
    print(str(e))
```

**disposable-email-checker:**

```bash
pip install disposable-email-checker
```

```python
from disposable_email_checker import is_disposable

result = is_disposable("user@10minutemail.com")
print(result)  # True/False
```

### Heuristic Detection

**Pattern analysis:**

Some disposable services use predictable patterns:

```python
import re

def heuristic_check(email):
    domain = email.split('@')[1].lower()
    
    # Common patterns
    patterns = [
        r'temp.*mail',
        r'throw.*away',
        r'\d+min.*mail',
        r'.*disposable.*',
        r'.*trash.*',
        r'.*fake.*',
    ]
    
    for pattern in patterns:
        if re.search(pattern, domain):
            return True
    return False
```

**MX record analysis:**

[Inference] Some disposable services may use specific mail server patterns, though this method is not reliably documented across providers.

```python
import dns.resolver

def check_mx_disposable(domain):
    try:
        mx_records = dns.resolver.resolve(domain, 'MX')
        for mx in mx_records:
            mx_str = str(mx.exchange).lower()
            # Check for disposable service patterns
            if 'mailinator' in mx_str or 'guerrillamail' in mx_str:
                return True
    except:
        pass
    return False
```

**Domain age check:**

[Inference] Disposable services often use recently registered domains, though legitimate services also use new domains.

WHOIS lookup for registration date:

```python
import whois

def check_domain_age(domain):
    try:
        w = whois.whois(domain)
        if w.creation_date:
            # Handle both single date and list of dates
            creation = w.creation_date[0] if isinstance(w.creation_date, list) else w.creation_date
            age_days = (datetime.now() - creation).days
            return age_days
    except:
        return None
```

### Advanced Detection Techniques

**SPF/DMARC Policy Analysis:**

Disposable services often lack strict email policies:

```python
import dns.resolver

def check_email_policies(domain):
    policies = {}
    
    # Check SPF
    try:
        spf = dns.resolver.resolve(domain, 'TXT')
        for txt in spf:
            if 'v=spf1' in str(txt):
                policies['spf'] = str(txt)
    except:
        policies['spf'] = None
    
    # Check DMARC
    try:
        dmarc = dns.resolver.resolve(f'_dmarc.{domain}', 'TXT')
        for txt in dmarc:
            if 'v=DMARC1' in str(txt):
                policies['dmarc'] = str(txt)
    except:
        policies['dmarc'] = None
    
    # Weak or missing policies may indicate disposable
    return policies
```

**Public Inbox Detection:**

Some disposable services have publicly accessible inboxes:

```bash
# Try accessing common inbox URLs
curl "https://www.mailinator.com/v4/public/inboxes.jsp?to=testuser"
curl "https://temp-mail.org/en/view/testuser"
```

If inbox accessible without authentication, likely disposable/public service.

**Catch-All Testing:**

Disposable services often accept all addresses:

```python
import random
import string

def test_catch_all(domain):
    # Generate random local part
    random_user = ''.join(random.choices(string.ascii_lowercase, k=20))
    test_email = f"{random_user}@{domain}"
    
    # Verify if accepted (using SMTP check)
    # If random address validates, likely catch-all disposable
    return verify_email_smtp(test_email)
```

### Real-Time Detection Services

**Block-Disposable-Email (API):**

```bash
curl "https://block-disposable-email.com/api/check?email=user@tempmail.com"
```

**Debounce.io:**

```bash
curl "https://api.debounce.io/v1/?api=YOUR_KEY&email=user@example.com"
```

**IPQualityScore:**

```bash
curl "https://ipqualityscore.com/api/json/email/YOUR_KEY/user@example.com"
```

Returns comprehensive data:

- Disposable status
- Fraud score
- Recent abuse
- Domain age
- Deliverability

### Bypass Detection (For Testing)

**Custom domain disposables:**

Services that allow custom domains:

- SimpleLogin
- AnonAddy
- Firefox Relay
- DuckDuckGo Email Protection

These use legitimate-looking domains, harder to detect as disposable.

**Plus addressing:**

```
user+tag@gmail.com
user+anything@gmail.com
```

Gmail ignores everything after "+", all deliver to same inbox. Not technically disposable but can identify abuse.

**Dot addressing (Gmail):**

```
user@gmail.com = u.ser@gmail.com = us.er@gmail.com
```

Gmail ignores dots in local part.

### Database Maintenance

**Update disposable lists regularly:**

```bash
# Automated update from GitHub
#!/bin/bash

cd /path/to/disposable-lists
git pull origin master

# Or download latest
curl -O "https://raw.githubusercontent.com/disposable-email-domains/disposable-email-domains/master/disposable_email_blocklist.conf"
```

**Cron job for updates:**

```bash
# Update daily at 2 AM
0 2 * * * cd /path/to/lists && git pull
```

### False Positives

**Legitimate services sometimes flagged:**

- Privacy-focused services (ProtonMail, Tutanota)
- Regional email providers
- Newly registered business domains
- Custom domain email forwarding services

**Mitigation:**

- Whitelist known legitimate services
- Use multiple detection methods
- Manual review for edge cases
- Allow user verification/appeals

### CTF Applications

**Account Enumeration:**

- Identify disposable registrations
- Focus on legitimate-looking accounts
- Filter noise in user databases

**Anti-Automation:** Disposable detection can identify:

- Bot registrations
- Mass account creation
- Spam patterns

**Pattern Analysis:** Correlate disposable email domains to identify coordinated activity.

**Challenge Design:** CTF challenges may require:

- Bypassing disposable detection
- Detecting hidden disposable patterns
- Analyzing email validation logic

### Comprehensive Detection Script

```python
import dns.resolver
import requests
import re

class DisposableEmailDetector:
    def __init__(self):
        # Load blocklist
        self.disposable_domains = self.load_blocklist()
    
    def load_blocklist(self):
        # Load from local file or URL
        url = "https://raw.githubusercontent.com/disposable-email-domains/disposable-email-domains/master/disposable_email_blocklist.conf"
        response = requests.get(url)
        return set(response.text.splitlines())
    
    def check_blocklist(self, email):
        domain = email.split('@')[1].lower()
        return domain in self.disposable_domains
    
    def check_mx_records(self, email):
        domain = email.split('@')[1]
        try:
            mx_records = dns.resolver.resolve(domain, 'MX')
            if not mx_records:
                return True  # No MX = suspicious
            
            # Check for known disposable MX patterns
            for mx in mx_records:
                mx_str = str(mx.exchange).lower()
                if any(pattern in mx_str for pattern in ['mailinator', 'guerrilla', 'tempmail']):
                    return True
            return False
        except:
            return True  # DNS resolution failed
    
    def check_pattern(self, email):
        domain = email.split('@')[1].lower()
        suspicious_patterns = [
            r'temp.*mail',
            r'throw.*away',
            r'\d+min',
            r'disposable',
            r'trash.*mail',
            r'fake.*mail',
        ]
        
        for pattern in suspicious_patterns:
            if re.search(pattern, domain):
                return True
        return False
    
    def is_disposable(self, email):
        # Multi-factor check
        checks = {
            'blocklist': self.check_blocklist(email),
            'mx_records': self.check_mx_records(email),
            'pattern': self.check_pattern(email),
        }
        
        # Return True if any check flags as disposable
        return any(checks.values()), checks

# Usage
detector = DisposableEmailDetector()
result, details = detector.is_disposable("user@10minutemail.com")
print(f"Disposable: {result}")
print(f"Details: {details}")
```

### Integration with Validation Workflow

**Complete email validation + disposable check:**

```python
from email_validator import validate_email, EmailNotValidError
import dns.resolver

def validate_email_complete(email):
    results = {
        'valid': False,
        'deliverable': False,
        'disposable': False,
        'errors': []
    }
    
    # Syntax validation
    try:
        v = validate_email(email, check_deliverability=False)
        results['valid'] = True
    except EmailNotValidError as e:
        results['errors'].append(f"Syntax: {str(e)}")
        return results
    
    # MX check
    domain = email.split('@')[1]
    try:
        mx = dns.resolver.resolve(domain, 'MX')
        results['deliverable'] = bool(mx)
    except:
        results['errors'].append("No MX records")
    
    # Disposable check
    detector = DisposableEmailDetector()
    is_disp, details = detector.is_disposable(email)
    results['disposable'] = is_disp
    results['disposable_details'] = details
    
    return results

# Usage
result = validate_email_complete("user@tempmail.com")
print(result)
```

### Rate Limiting Considerations

When checking large lists:

```python
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

def check_emails_bulk(emails, max_workers=5, delay=0.5):
    results = {}
    
    def check_with_delay(email):
        time.sleep(delay)  # Rate limiting
        return email, validate_email_complete(email)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(check_with_delay, email): email for email in emails}
        
        for future in as_completed(futures):
            email, result = future.result()
            results[email] = result
    
    return results
```

### Disposable Email Honeypots

**Creating honeypot addresses:**

```python
def generate_honeypot_email(domain):
    # Generate address that looks real but detects disposable usage
    import uuid
    unique_id = str(uuid.uuid4())[:8]
    return f"verify-{unique_id}@{domain}"

# Monitor if address appears in breach databases or spam lists
# Indicates possible disposable service abuse
```

### Privacy Considerations

**Legitimate use cases for disposable emails:**

- Privacy protection
- Avoiding marketing spam
- Testing/development
- One-time registrations

**Ethical implementation:**

- Clearly communicate policies
- Allow alternative verification methods
- Don't assume malicious intent
- Consider legitimate privacy needs

---

**Important Related Topics:**

- **Domain Intelligence (WHOIS, DNS)** - Essential for comprehensive email domain analysis
- **Social Media OSINT** - Cross-reference email addresses with social profiles
- **Phone Number Intelligence** - Often paired with email in account creation
- **Credential Intelligence** - Password analysis and authentication method detection
- **People Search & Identity Verification** - Linking email addresses to real identities

---

# Username and Identity Intelligence

Username and identity intelligence involves correlating digital identities across platforms, linking disparate data sources, and constructing comprehensive profiles from fragmented public information. This module covers systematic approaches to identity resolution and verification.

## Username Correlation Across Platforms

### Automated Username Enumeration

**Sherlock - Comprehensive Platform Search**

```bash
# Basic enumeration
sherlock username --timeout 10

# Exclude specific sites with high false positives
sherlock username --exclude Instagram --exclude Pinterest

# JSON output for parsing
sherlock username --json --output results.json

# Parallel processing for speed
sherlock username --parallel 20

# Print only found accounts
sherlock username --print-found
```

**Maigret - Extended Database**

```bash
# Standard search with tags
maigret username --tags social,dating,finance

# Extract additional information
maigret username --info

# Use cookies for authenticated searches
maigret username --cookies cookies.txt

# Generate visual graph
maigret username --graph --html
```

**WhatsMyName - Custom Site Lists**

```bash
# Clone repository
git clone https://github.com/WebBreacher/WhatsMyName
cd WhatsMyName

# Basic search
python3 whatsmyname.py -u username

# Use specific category
python3 whatsmyname.py -u username --category social

# Output formats
python3 whatsmyname.py -u username --output json
```

**Social-Analyzer - Deep Platform Analysis**

```bash
# Install
pip3 install social-analyzer

# Comprehensive search
social-analyzer -u "username" --metadata

# Multiple usernames
social-analyzer -u "user1,user2,user3"

# Extract profile information
social-analyzer -u "username" --extract

# Generate report
social-analyzer -u "username" --output report.html
```

### Username Pattern Analysis

**Common Username Patterns**

Identify variations:

```
Base: johnsmith
Variations:
- johnsmith123
- john_smith
- john.smith
- jsmith
- smithjohn
- johnsmith1985 (birth year)
- johnsmithNYC (location)
- iamjohnsmith
- johnsmithofficial
```

**Year and Number Suffix Analysis**

```python
# Generate probable variations
base_username = "johnsmith"
years = range(1960, 2010)  # Reasonable birth year range

variations = [
    f"{base_username}{year}" for year in years
]

# Common number patterns
common_numbers = ['123', '1', '12', '007', '420', '69', '666']
variations += [f"{base_username}{num}" for num in common_numbers]
```

**Platform-Specific Naming Conventions**

Different platforms have different constraints:

- **Twitter/X**: 15 character limit, alphanumeric + underscore
- **Instagram**: 30 character limit, alphanumeric + underscore + period
- **TikTok**: 24 character limit, alphanumeric + underscore + period
- **LinkedIn**: Custom URL slugs, typically name-based
- **Reddit**: 20 character limit, case-insensitive

### Cross-Platform Correlation Techniques

**Unique Identifier Discovery**

Look for consistent elements across profiles:

- Profile photos (reverse image search)
- Bio/description text patterns
- URL patterns in bios
- Contact information
- Location information
- Join dates and account age

**Profile Photo Analysis**

```bash
# Download profile images from found accounts
# Then perform reverse image search

# Using PimEyes (web-based face search)
# Upload photo at pimeyes.com

# Using Google Images
curl -X POST "https://images.google.com/searchbyimage/upload" \
  -F "encoded_image=@profile.jpg"

# Using Yandex (often better for faces)
# Navigate to yandex.com/images and upload

# TinEye reverse search
curl "https://tineye.com/search" -F "image=@profile.jpg"
```

**Bio and Description Text Matching**

```python
# Compare bio text across platforms
from difflib import SequenceMatcher

bio1 = "Software developer | Coffee enthusiast | NYC"
bio2 = "Software engineer. Coffee lover. Based in New York"

similarity = SequenceMatcher(None, bio1, bio2).ratio()
print(f"Similarity: {similarity * 100:.2f}%")

# Extract common elements
import re

def extract_keywords(text):
    # Remove common words
    stopwords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at'}
    words = re.findall(r'\w+', text.lower())
    return set(w for w in words if w not in stopwords)

common = extract_keywords(bio1) & extract_keywords(bio2)
```

**Creation Date Timeline**

```python
# Build account creation timeline
accounts = {
    'Twitter': '2015-03-15',
    'Instagram': '2015-04-20',
    'GitHub': '2015-05-01',
    'Reddit': '2015-03-10'
}

# Earlier accounts may be primary
# Cluster of accounts created around same time suggests authenticity
```

### Email Address Recovery

**Email Pattern Enumeration**

```bash
# theHarvester - comprehensive email discovery
theHarvester -d domain.com -b all -l 500

# Specific sources
theHarvester -d domain.com -b google,bing,linkedin,twitter

# Hunter.io API
curl "https://api.hunter.io/v2/domain-search?domain=company.com&api_key=API_KEY" | jq

# EmailHippo validation
curl -X POST "https://api.emailhippo.com/v3/verify" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","apiKey":"YOUR_KEY"}'
```

**Email Breach Database Search**

```bash
# Have I Been Pwned API
curl "https://haveibeenpwned.com/api/v3/breachedaccount/email@example.com" \
  -H "hibp-api-key: YOUR_API_KEY"

# DeHashed (requires subscription)
# Search for email in leaked databases
curl "https://api.dehashed.com/search?query=email:target@example.com" \
  -u "email:api_key"

# Leaked password databases (for research only)
# Check: WeLeakInfo mirrors, data breach compilations
```

**Email Permutation Generation**

```python
# Generate email variations
first_name = "john"
last_name = "smith"
domain = "company.com"

patterns = [
    f"{first_name}.{last_name}@{domain}",
    f"{first_name}{last_name}@{domain}",
    f"{first_name}_{last_name}@{domain}",
    f"{first_name[0]}{last_name}@{domain}",
    f"{first_name}{last_name[0]}@{domain}",
    f"{last_name}.{first_name}@{domain}",
    f"{last_name}{first_name}@{domain}"
]

# Verify using email validation API
```

### Phone Number Correlation

**Phone Number OSINT**

```bash
# PhoneInfoga - phone number information gathering
phoneinfoga scan -n +1234567890

# Truecaller lookup (requires account)
# Web interface or API

# Reverse phone lookup services
# - whitepages.com
# - truepeoplesearch.com
# - fastpeoplesearch.com
```

**Phone Number Format Analysis**

```python
import phonenumbers
from phonenumbers import geocoder, carrier

# Parse number
number = phonenumbers.parse("+14155552671", None)

# Get location
location = geocoder.description_for_number(number, "en")

# Get carrier
carrier_name = carrier.name_for_number(number, "en")

# Check if valid
is_valid = phonenumbers.is_valid_number(number)
```

## Identity Linking Techniques

### Multi-Source Data Fusion

**OSINT Framework Approach**

Systematic data collection from:

1. Social media platforms
2. Professional networks
3. Public records
4. Data breaches
5. Domain registrations
6. Forum posts
7. Code repositories
8. Archive services

**SpiderFoot - Automated Correlation**

```bash
# Install SpiderFoot
git clone https://github.com/smicallef/spiderfoot.git
cd spiderfoot
pip3 install -r requirements.txt

# Run web interface
python3 sf.py -l 127.0.0.1:5001

# Command line scan
python3 sfcli.py -s "target@email.com" -t EMAIL_ADDRESS -u all

# Scan with specific modules
python3 sfcli.py -s "target.com" -t DOMAIN_NAME -m sfp_dnsresolve,sfp_whois
```

**Maltego - Visual Intelligence**

```bash
# Maltego transforms for identity linking
# Free community edition available

# Key transforms:
# - Email to Person
# - Person to Social Media
# - Phone to Person
# - Domain to Email Addresses
# - Alias to Alias (username correlation)

# Custom transform development
# Python: https://github.com/MaltegoTech/maltego-trx
```

**Recon-ng - Modular OSINT Framework**

```bash
# Install and setup
git clone https://github.com/lanmaster53/recon-ng.git
cd recon-ng
pip3 install -r REQUIREMENTS

# Launch framework
./recon-ng

# Create workspace
workspaces create target_name

# Add target
db insert domains
domain: target.com

# Load and run modules
marketplace install all
modules load recon/domains-contacts/whois_pocs
run

# Module categories:
# - recon/profiles-profiles/* (username correlation)
# - recon/contacts-profiles/* (email to social)
# - recon/profiles-contacts/* (social to contact info)
```

### Behavioral Fingerprinting

**Writing Style Analysis**

```python
# Stylometry - authorship attribution
from textstat import textstat

text1 = "Sample text from one source..."
text2 = "Sample text from another source..."

# Readability metrics
flesch_reading_ease = textstat.flesch_reading_ease(text1)
flesch_kincaid_grade = textstat.flesch_kincaid_grade(text1)

# Lexical diversity
def lexical_diversity(text):
    words = text.lower().split()
    return len(set(words)) / len(words)

# Sentence length patterns
import re
sentences = re.split(r'[.!?]+', text1)
avg_sentence_length = sum(len(s.split()) for s in sentences) / len(sentences)
```

**Temporal Activity Patterns**

```python
# Analyze posting time patterns across platforms
from collections import Counter
from datetime import datetime

# Assuming posts is list of timestamps
posts = [datetime(...), datetime(...), ...]

# Extract hour of day
hours = [p.hour for p in posts]
hour_distribution = Counter(hours)

# Peak activity hours
peak_hours = hour_distribution.most_common(3)

# [Inference] Consistent activity patterns across platforms suggest same individual
# Active hours typically indicate timezone and lifestyle
```

**Interest and Topic Correlation**

```python
# Topic extraction and comparison
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Combine posts from different platforms
platform1_posts = "..."
platform2_posts = "..."

corpus = [platform1_posts, platform2_posts]
vectorizer = TfidfVectorizer(max_features=100, stop_words='english')
tfidf_matrix = vectorizer.fit_transform(corpus)

# Calculate similarity
similarity = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:2])
print(f"Content similarity: {similarity[0][0]:.2f}")

# [Inference] High topic similarity (>0.7) suggests same person or closely related individuals
```

### Digital Artifact Correlation

**PGP Key Analysis**

```bash
# Search PGP key servers
gpg --keyserver keyserver.ubuntu.com --search-keys email@example.com
gpg --keyserver keys.openpgp.org --search-keys "John Smith"

# Export key information
gpg --list-keys --with-colons | grep uid

# Key fingerprint analysis
# Fingerprints are unique identifiers linking identities
```

**SSH Key Fingerprints**

```bash
# GitHub SSH keys
curl https://github.com/username.keys

# GitLab SSH keys
curl https://gitlab.com/username.keys

# Compare fingerprints
ssh-keygen -lf id_rsa.pub
```

**Bitcoin/Cryptocurrency Addresses**

```bash
# Blockchain explorer lookups
# - blockchain.com/btc/address/ADDRESS
# - blockchair.com/bitcoin/address/ADDRESS

# Link addresses to identities
# Check forums, social media for address mentions
grep -r "bitcoin:" social_media_archives/

# [Unverified] Cryptocurrency addresses alone do not confirm identity without additional context
```

**Code Repository Analysis**

```bash
# Git commit analysis
git log --author="John Smith" --all --pretty=format:"%an <%ae> %ai"

# GitHub user OSINT
curl https://api.github.com/users/username
curl https://api.github.com/users/username/repos
curl https://api.github.com/users/username/events/public

# Check commit email addresses
git log --format="%ae" | sort -u

# GitLab similar queries
curl https://gitlab.com/api/v4/users?username=target
```

### Image and Media Fingerprinting

**Reverse Image Search Workflow**

```bash
# Google Images
# Manual: images.google.com -> camera icon

# Bing Visual Search
# Manual: bing.com/visualsearch

# Yandex (best for faces)
# Manual: yandex.com/images

# TinEye (best for exact matches)
curl -X POST https://tineye.com/search \
  -F "image=@photo.jpg" \
  -F "sort=score"

# PimEyes (face-specific, paid)
# Web interface: pimeyes.com
```

**EXIF Data Cross-Reference**

```bash
# Extract camera/device information
exiftool -Make -Model -Software image.jpg

# Extract unique identifiers
exiftool -SerialNumber -LensSerialNumber image.jpg

# [Inference] Same camera serial number across images suggests common photographer
# [Unverified] Social media platforms typically strip EXIF data, but original files may exist elsewhere
```

**Video Analysis**

```bash
# Extract video metadata
ffprobe -v quiet -print_format json -show_format video.mp4

# Voice analysis for speaker identification
# [Unverified] Audio fingerprinting requires specialized tools and may not be reliable for identification

# Frame extraction for image analysis
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.jpg
```

## People Search Engines

### Free People Search Services

**TruePeopleSearch**

```
URL: truepeoplesearch.com
Data provided:
- Current and past addresses
- Phone numbers
- Age and relatives
- Associated individuals

Search methods:
- Name + State
- Phone number
- Address lookup
```

**FastPeopleSearch**

```
URL: fastpeoplesearch.com
Similar to TruePeopleSearch
Data sources: Public records aggregation

[Inference] Free services aggregate public records but may have outdated or incomplete information
```

**WhitePages**

```
URL: whitepages.com
Free tier:
- Basic contact information
- Location history

Premium tier:
- More detailed reports
- Background information
- Property records
```

**That'sThem**

```
URL: thatsthem.com
Features:
- Name search
- Phone reverse lookup
- Email search
- Address search
- License plate search (some states)
```

**Spokeo**

```
URL: spokeo.com
Freemium model
Basic information visible without account
Full reports require payment

Data includes:
- Social media profiles
- Photos
- Relatives
- Court records
```

### Specialized People Search

**Pipl (Deprecated for Public Use)**

[Unverified] Pipl transitioned to B2B services and is no longer publicly accessible for individual searches.

**BeenVerified**

```
URL: beenverified.com
Subscription-based
Includes:
- Contact information
- Criminal records
- Property records
- Social media
- Email addresses
```

**Intelius**

```
URL: intelius.com
Paid service
Comprehensive reports including:
- Background checks
- Reverse phone lookup
- Property records
- Relatives and associates
```

### Professional and Business Search

**LinkedIn People Search**

```bash
# Google dork method
site:linkedin.com/in/ "John Smith" "New York"
site:linkedin.com/in/ "Company Name" "Job Title"

# Advanced search (requires LinkedIn account)
# Filters: Location, Company, School, Industry

# Sales Navigator (premium)
# Advanced filters and lead generation
```

**ZoomInfo**

```
URL: zoominfo.com
B2B contact database
Includes:
- Business email addresses
- Direct phone numbers
- Job titles and roles
- Company information

[Unverified] Accuracy varies; requires premium subscription for full access
```

**RocketReach**

```
URL: rocketreach.co
Find professional email addresses and phone numbers
Verification status indicators
Chrome extension available
```

**Hunter.io People Search**

```bash
# Find people at a company
curl "https://api.hunter.io/v2/domain-search?domain=company.com&api_key=KEY"

# Find specific person's email
curl "https://api.hunter.io/v2/email-finder?domain=company.com&first_name=John&last_name=Smith&api_key=KEY"
```

## Public Records Databases

### Government Record Access

**Vital Records**

State and county level records:

- Birth records (restricted)
- Marriage records
- Divorce records
- Death records

Access methods:

- County clerk websites
- State vital records offices
- Third-party aggregators

Example search:

```
site:gov "John Smith" marriage
site:.us "vital records" "search"
```

**Court Records**

**PACER (Federal Courts)**

```
URL: pacer.gov
Federal court records including:
- Criminal cases
- Civil cases
- Bankruptcy filings

Costs: $0.10 per page
Registration required
```

**State Court Records**

```
Varies by state and county
Examples:
- California: courts.ca.gov
- New York: nycourts.gov
- Texas: txcourts.gov

Search methods:
- Party name
- Case number
- Attorney name
```

**Unified Judicial System Searches**

Some states offer centralized search:

```
Examples:
- Florida: myflcourtaccess.com
- Indiana: mycase.in.gov
- Colorado: cocourts.com
```

### Property Records

**County Assessor Databases**

```bash
# Property records typically available at county level
# Examples:

# Los Angeles County
# https://assessor.lacounty.gov/

# Cook County (Chicago)
# https://www.cookcountyassessor.com/

# Miami-Dade County
# https://www.miamidade.gov/pa/

# Search by:
# - Owner name
# - Property address
# - Parcel number

# Data typically includes:
# - Assessed value
# - Sale history
# - Property characteristics
# - Tax information
```

**Zillow and Redfin**

```bash
# Zillow API (limited free tier)
curl "https://www.zillow.com/search/GetSearchPageState.htm?searchQueryState={search_params}"

# Property history and owner information visible on listings
# Cross-reference with county records for verification
```

**NETR Online**

```
URL: publicrecords.netronline.com
Aggregates property records from multiple counties
Free access to basic information
Links to official county sites
```

### Business and Corporate Records

**Secretary of State Databases**

```bash
# Business entity searches by state
# Examples:

# Delaware (popular incorporation state)
# https://icis.corp.delaware.gov/Ecorp/EntitySearch/NameSearch.aspx

# California
# https://businesssearch.sos.ca.gov/

# New York
# https://appext20.dos.ny.gov/corp_public/corpsearch.entity_search_entry

# Search fields:
# - Entity name
# - File number
# - Registered agent
# - Officers/directors (some states)
```

**EDGAR (SEC Filings)**

```bash
# Search public company filings
curl "https://www.sec.gov/cgi-bin/browse-edgar?company=COMPANY_NAME&action=getcompany"

# Full text search
curl "https://www.sec.gov/cgi-bin/srch-edgar?text=SEARCH_TERM"

# Parse 10-K, 10-Q, DEF 14A for:
# - Executive compensation
# - Board members
# - Related party transactions
# - Risk factors
```

**OpenCorporates**

```bash
# Global corporate database
curl "https://api.opencorporates.com/v0.4/companies/search?q=company_name"

# Get company details
curl "https://api.opencorporates.com/v0.4/companies/{jurisdiction_code}/{company_number}"

# Find officers
curl "https://api.opencorporates.com/v0.4/officers/search?q=John+Smith"
```

### Professional Licenses

**State Licensing Boards**

Medical licenses:

```
- American Medical Association Doctor Finder
- State medical boards (searchable by name)
- National Provider Identifier (NPI) Registry: nppes.cms.hhs.gov
```

Legal licenses:

```
- State bar associations
- Martindale-Hubbell lawyer directory
- Avvo attorney search
```

Professional certifications:

```
- CPA licenses (state accountancy boards)
- Real estate licenses (state DRE databases)
- Contractor licenses (state licensing boards)
```

### Voter Registration Records

**State Voter Files**

[Unverified] Accessibility varies significantly by state. Some states provide limited public access while others restrict access to campaigns and researchers.

Example states with searchable databases:

- Florida (requires account)
- North Carolina (limited info)
- Colorado (some counties)

Data typically includes:

- Full name
- Address
- Date of birth
- Party affiliation
- Voting history (dates, not choices)

### Criminal Records

**State and County Resources**

```
Access methods:
1. County sheriff websites
2. State Department of Corrections
3. Court record systems
4. Third-party background check services

Example: Florida Department of Corrections
URL: dc.state.fl.us/OffenderSearch/

Searchable by:
- Name and DOB
- Inmate number
- Status (active, released)
```

**Sex Offender Registries**

```
National: nsopw.gov (National Sex Offender Public Website)

State registries are publicly searchable
Information includes:
- Photo
- Address
- Offense details
- Physical description
```

**FBI Most Wanted**

```
URL: fbi.gov/wanted
Categories:
- Ten Most Wanted
- Terrorism
- Kidnappings/Missing Persons
- Cyber crimes
- Violent crimes
```

## Background Check Resources

### Comprehensive Background Check Services

**Commercial Services**

**CheckPeople**

```
URL: checkpeople.com
Includes:
- Criminal records
- Contact information
- Relatives and associates
- Social media profiles
- Property records

Subscription model with unlimited searches
```

**InstantCheckmate**

```
URL: instantcheckmate.com
Features:
- Criminal background
- Traffic violations
- Arrest records
- Weapon permits
- Sex offender status

Mobile app available
```

**TruthFinder**

```
URL: truthfinder.com
Comprehensive reports:
- Dark web monitoring
- Criminal records
- Online profiles
- Education verification
- Employment history

[Inference] Accuracy depends on data source freshness and completeness
```

### Employment Verification

**National Student Clearinghouse**

```
URL: studentclearinghouse.org
Educational verification for:
- Degree verification
- Enrollment confirmation
- Transcript requests

Used by employers and background check companies
```

**The Work Number**

```
Operated by Equifax
Employment and income verification
Used by lenders and background check services
Employer participation varies
```

### Credit and Financial Records

**Credit Report Monitoring**

[Unverified] Personal credit reports are protected by law and not publicly accessible without consent.

Bankruptcy records (public):

```
- PACER: pacer.gov (federal bankruptcies)
- County court records (some states)
- Third-party aggregators
```

**Liens and Judgments**

```
UCC filings (Uniform Commercial Code):
- State Secretary of State offices
- County recorder offices

Tax liens:
- County recorder offices
- IRS public records (limited)

Judgments:
- Court records (PACER or state courts)
```

### International Resources

**Interpol Wanted Persons**

```
URL: interpol.int/en/How-we-work/Notices/Red-Notices
Red Notices (wanted persons)
Yellow Notices (missing persons)
Searchable database
```

**European Business Registry**

```
URL: ebr.org
Pan-European business information
Company registration data across EU member states
```

**UK Companies House**

```bash
# Search UK companies
curl "https://api.company-information.service.gov.uk/search/companies?q=COMPANY_NAME" \
  -H "Authorization: YOUR_API_KEY"

# Get company officers
curl "https://api.company-information.service.gov.uk/company/COMPANY_NUMBER/officers"
```

## Data Verification and Validation

### Cross-Reference Methodology

**Multi-Source Confirmation**

Best practices:

1. Verify information across minimum 3 independent sources
2. Check primary sources when possible (official records)
3. Note discrepancies and date stamps
4. Assess source credibility

**Temporal Validation**

```python
# Check for logical consistency in timeline
events = {
    'Birth': 1985,
    'High School Graduation': 2003,
    'College Graduation': 2007,
    'First Job': 2007,
    'Marriage': 2010
}

# Validate age-appropriate progression
def validate_timeline(events):
    birth_year = events.get('Birth')
    for event, year in events.items():
        if event != 'Birth':
            age_at_event = year - birth_year
            # Check if reasonable
            if event == 'High School Graduation' and (age_at_event < 16 or age_at_event > 20):
                print(f"[Warning] Unusual age for {event}: {age_at_event}")
```

**Geographic Consistency**

[Inference] Employment locations, addresses, and social media check-ins should show logical geographic progression unless explained by remote work or frequent travel.

### Data Quality Assessment

**Source Credibility Hierarchy**

Tier 1 (Most reliable):

- Government databases
- Court records
- Property records
- Professional licensing boards

Tier 2 (Moderately reliable):

- Established background check services
- News articles from reputable sources
- LinkedIn (self-reported, but generally accurate for professional info)

Tier 3 (Least reliable):

- Social media posts (unverified)
- Third-party aggregators (may be outdated)
- Forum posts
- Crowdsourced databases

**Staleness Indicators**

Check for:

- Last updated timestamps
- Database refresh dates
- Archived vs. live content
- Historical data vs. current data

### Privacy and Legal Considerations

**Fair Credit Reporting Act (FCRA)**

[Unverified] FCRA regulates use of consumer information for employment, credit, and insurance purposes. Background checks for these purposes require consent and must comply with FCRA requirements.

**GDPR and International Privacy**

European Union data protection:

- Right to be forgotten
- Data access restrictions
- Processing limitations

**Ethical Guidelines**

Recommended practices:

- Only collect necessary information
- Respect opt-out requests
- Avoid targeting protected classes
- Do not use information for harassment or discrimination
- Maintain data security

## Operational Workflow

### Systematic Identity Investigation

**Phase 1: Initial Discovery**

1. Start with known identifier (username, email, name)
2. Run automated enumeration tools
3. Document all discovered profiles
4. Capture timestamps and screenshots

**Phase 2: Expansion**

1. Extract additional identifiers from profiles
2. Cross-reference new identifiers
3. Build relationship map
4. Identify primary vs. secondary accounts

**Phase 3: Public Records**

1. Search appropriate databases based on jurisdiction
2. Verify identity match using multiple data points
3. Document official records
4. Note any discrepancies

**Phase 4: Validation**

1. Cross-reference all findings
2. Assess confidence level for each data point
3. Identify information gaps
4. Prepare final intelligence report

### Documentation Standards

**Evidence Collection**

```bash
# Screenshot automation
# Using scrot (Linux)
scrot -u -q 100 screenshot_%Y%m%d_%H%M%S.png

# Using Firefox headless
firefox --screenshot=page.png --window-size=1920,1080 https://example.com

# Web archiving
curl -X POST "https://web.archive.org/save/https://target-url.com"
```

**Chain of Custody**

Maintain records including:

- Date and time of discovery
- Source URL or database
- Method of access
- Original vs. modified content
- Analyst notes

### Reporting Format

**Intelligence Report Structure**

```
1. Executive Summary
   - Subject identification
   - Key findings
   - Confidence assessment

2. Known Identifiers
   - Primary name(s)
   - Aliases and usernames
   - Contact information
   - Account inventory

3. Digital Footprint
   - Social media presence
   - Professional profiles
   - Online activity summary

4. Public Records
   - Legal records
   - Property ownership
   - Business affiliations
   - Professional licenses

5. Associations
   - Known relatives
   - Business partners
   - Social connections
   - Organizational memberships

6. Timeline
   - Key events
   - Location history
   - Employment history

7. Source Documentation
   - All sources cited
   - Confidence ratings
   - Verification status
   - Access methods

8. Intelligence Gaps
   - Unknown information
   - Contradictory data
   - Recommended follow-up
```

[Unverified] This module represents common OSINT practices; legal requirements and ethical standards vary by jurisdiction and use case. Always ensure compliance with applicable laws and organizational policies.

---

# Geolocation Techniques

## GPS Coordinate Analysis

### Coordinate Extraction and Validation

GPS coordinates appear in EXIF metadata, text overlays, image filenames, and embedded comments. Extracting and validating these coordinates is the foundation of geolocation analysis.

**ExifTool GPS Extraction**

```bash
# Extract raw GPS data
exiftool -GPS* image.jpg

# Extract in decimal degrees format (most useful for mapping)
exiftool -n -GPS* image.jpg

# Extract GPS reference (N/S, E/W indicators)
exiftool -GPSLatitudeRef -GPSLongitudeRef image.jpg

# Extract GPS altitude
exiftool -GPSAltitude image.jpg

# Batch extract GPS from directory to CSV
exiftool -r -csv /path/to/images/ | grep -v "^-" > gps_data.csv

# Extract only images with GPS data
exiftool -r -if '$GPSLatitude' /path/to/images/ | grep -i "filename\|gps"
```

**Coordinate Conversion and Normalization**

```python
python3 << 'EOF'
from PIL.Image import open as img_open
from PIL.ExifTags import TAGS, GPSTAGS
from fractions import Fraction

def convert_to_degrees(value):
    """Convert GPS coordinates from DMS (Degrees, Minutes, Seconds) to decimal degrees"""
    d, m, s = value
    return d + (m / 60.0) + (s / 3600.0)

def get_gps_data(image_path):
    """Extract and convert GPS coordinates from image"""
    image = img_open(image_path)
    exif_data = image._getexif()
    
    if not exif_data:
        return None
    
    gps_data = {}
    
    for tag_id, value in exif_data.items():
        tag = TAGS.get(tag_id, tag_id)
        
        if tag == "GPSInfo":
            for gps_tag_id, gps_value in value.items():
                gps_tag = GPSTAGS.get(gps_tag_id, gps_tag_id)
                gps_data[gps_tag] = gps_value
    
    if not gps_data:
        return None
    
    # Convert to decimal degrees
    try:
        latitude = convert_to_degrees(gps_data['GPSLatitude'])
        longitude = convert_to_degrees(gps_data['GPSLongitude'])
        
        # Apply N/S and E/W references
        if gps_data['GPSLatitudeRef'] == 'S':
            latitude = -latitude
        if gps_data['GPSLongitudeRef'] == 'W':
            longitude = -longitude
        
        return {
            'latitude': latitude,
            'longitude': longitude,
            'altitude': float(gps_data.get('GPSAltitude', [0])[0]) if 'GPSAltitude' in gps_data else None,
            'timestamp': gps_data.get('GPSDateStamp'),
            'decimal_string': f"{latitude},{longitude}",
            'google_maps_url': f"https://maps.google.com/?q={latitude},{longitude}",
            'raw': gps_data
        }
    except Exception as e:
        print(f"[-] Error converting coordinates: {e}")
        return None

# Example usage
result = get_gps_data('image.jpg')
if result:
    print("[+] GPS Coordinates Found:")
    print(f"    Latitude: {result['latitude']:.6f}")
    print(f"    Longitude: {result['longitude']:.6f}")
    print(f"    Altitude: {result['altitude']}m")
    print(f"    Google Maps: {result['google_maps_url']}")
EOF
```

### Coordinate Accuracy and Precision Analysis

GPS precision depends on decimal places:

```python
python3 << 'EOF'
# GPS coordinate precision levels:
precision_levels = {
    '1 decimal place': '~11 km precision (city level)',
    '2 decimal places': '~1.1 km precision (neighborhood)',
    '3 decimal places': '~111 m precision (street)',
    '4 decimal places': '~11 m precision (building)',
    '5 decimal places': '~1.1 m precision (tree)',
    '6 decimal places': '~0.11 m precision (person)',
    '7 decimal places': '~0.011 m precision (hand)',
    '8 decimal places': '~0.001 m precision (millimeters)'
}

coords = "40.712776,-74.005974"
lat, lon = coords.split(',')

print(f"[+] Coordinate: {coords}")
print(f"[+] Precision: {len(lat.split('.')[1])} decimal places")
print(f"[+] Precision level: {precision_levels[f'{len(lat.split(\".\")[1])} decimal places']}")

# Flag CTF extraction example:
# If coordinates are: 40.123456,-74.123456
# Extracting only precision difference might reveal pattern:
# Round to different precision levels
for places in range(1, 8):
    rounded_lat = round(float(lat), places)
    rounded_lon = round(float(lon), places)
    print(f"    Precision {places}: {rounded_lat},{rounded_lon}")
EOF
```

### Distance Calculation and Coordinate Ranges

```python
python3 << 'EOF'
import math

def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculate distance between two GPS coordinates in kilometers"""
    R = 6371  # Earth radius in km
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    
    return R * c

def bounding_box(lat, lon, distance_km):
    """Generate bounding box around coordinate"""
    lat_change = distance_km / 111.0  # ~111 km per degree latitude
    lon_change = distance_km / (111.0 * math.cos(math.radians(lat)))  # Longitude varies by latitude
    
    return {
        'north': lat + lat_change,
        'south': lat - lat_change,
        'east': lon + lon_change,
        'west': lon - lon_change
    }

# Example: Distance between two locations
dist = haversine_distance(40.7128, -74.0060, 40.7580, -73.9855)
print(f"[+] Distance: {dist:.2f} km")

# Bounding box within 5km
bbox = bounding_box(40.7128, -74.0060, 5)
print(f"\n[+] Bounding box (5km radius):")
print(f"    North: {bbox['north']:.6f}")
print(f"    South: {bbox['south']:.6f}")
print(f"    East: {bbox['east']:.6f}")
print(f"    West: {bbox['west']:.6f}")
EOF
```

### Coordinate Verification Against Map Services

```bash
pip install googlemaps geopy

python3 << 'EOF'
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut

def reverse_geocode(latitude, longitude):
    """Convert GPS coordinates to address"""
    geolocator = Nominatim(user_agent="ctf_osint")
    try:
        location = geolocator.reverse(f"{latitude}, {longitude}", language='en')
        return location
    except GeocoderTimedOut:
        return None

# Example
lat, lon = 40.7128, -74.0060
location = reverse_geocode(lat, lon)

if location:
    print(f"[+] Location: {location.address}")
    print(f"[+] Raw: {location.raw}")

# Batch reverse geocoding
coordinates = [
    (40.7128, -74.0060),
    (51.5074, -0.1278),
    (48.8566, 2.3522)
]

print("\n[+] Batch reverse geocoding:")
for lat, lon in coordinates:
    location = reverse_geocode(lat, lon)
    if location:
        print(f"    {lat},{lon} -> {location.address[:50]}")
EOF
```

### GPS Spoofing and Accuracy Verification

```bash
python3 << 'EOF'
import math

def verify_gps_consistency(coordinates_list):
    """Check for GPS spoofing indicators"""
    if len(coordinates_list) < 2:
        return {'status': 'insufficient_data'}
    
    # Calculate distances and speeds between consecutive points
    issues = {
        'impossible_speed': [],
        'teleportation': [],
        'altitude_anomalies': []
    }
    
    for i in range(len(coordinates_list) - 1):
        lat1, lon1, alt1, time1 = coordinates_list[i]
        lat2, lon2, alt2, time2 = coordinates_list[i + 1]
        
        # Calculate distance
        R = 6371000  # Earth radius in meters
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        distance_m = R * c
        
        # Calculate time difference
        time_diff = (time2 - time1).total_seconds()
        
        if time_diff > 0:
            speed_ms = distance_m / time_diff
            speed_kmh = speed_ms * 3.6
            
            # [Inference] Human-realistic speeds: walking (1-2 m/s), car (15-30 m/s), plane (250 m/s)
            if speed_ms > 300:  # >1080 kmh = likely spoofing
                issues['impossible_speed'].append({
                    'index': i,
                    'speed_kmh': speed_kmh,
                    'distance_m': distance_m
                })
            
            # Teleportation: >1000km instantaneously
            if distance_m > 1000000 and time_diff < 60:
                issues['teleportation'].append({
                    'index': i,
                    'distance_km': distance_m / 1000
                })
        
        # Altitude anomalies
        if alt1 and alt2:
            alt_change = abs(alt2 - alt1)
            if alt_change > 1000 and time_diff < 5:  # >1000m in <5 seconds
                issues['altitude_anomalies'].append({
                    'index': i,
                    'altitude_change': alt_change
                })
    
    return issues

# Example with sample data
from datetime import datetime, timedelta

sample_coords = [
    (40.7128, -74.0060, 10, datetime.now()),
    (40.7130, -74.0055, 12, datetime.now() + timedelta(seconds=10)),
    (51.5074, -0.1278, 5, datetime.now() + timedelta(seconds=11)),  # Teleportation
]

result = verify_gps_consistency(sample_coords)
print("[+] GPS Verification Results:")
for issue_type, issues in result.items():
    if issues:
        print(f"    {issue_type}: {len(issues)} detected")
EOF
```

---

## Landmark Identification

### Deep Learning-Based Landmark Detection

TensorFlow Hub provides pre-trained models for landmark recognition across world regions.

```bash
pip install tensorflow tensorflow-hub pillow

python3 << 'EOF'
import tensorflow_hub as hub
import tensorflow as tf
from PIL import Image
import numpy as np

# Load landmark detector
# Available models: Asia, Africa, Europe, Americas
detector = hub.load('https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_asia_V1/1')

def detect_landmarks(image_path, top_k=5):
    """Detect landmarks in image"""
    img = Image.open(image_path).convert('RGB')
    img_array = tf.image.resize(tf.constant(np.array(img)), [321, 321])
    img_tensor = tf.cast(img_array, tf.uint8)[tf.newaxis, ...]
    
    # Run inference
    results = detector(img_tensor)
    
    logits = results['logits'][0].numpy()
    
    # Get top predictions
    top_indices = np.argsort(logits)[::-1][:top_k]
    
    return [
        {
            'confidence': float(logits[idx]),
            'index': int(idx)
        }
        for idx in top_indices
    ]

# Example
landmarks = detect_landmarks('image.jpg')
print("[+] Detected landmarks:")
for idx, landmark in enumerate(landmarks):
    print(f"    {idx+1}. Confidence: {landmark['confidence']:.2%}")
EOF
```

### Google Lens Integration (Browser Automation)

```bash
pip install selenium pillow

python3 << 'EOF'
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def google_lens_search(image_path):
    """Search for landmark using Google Lens via Selenium"""
    driver = webdriver.Chrome()
    
    try:
        # Open Google Images
        driver.get('https://images.google.com/')
        time.sleep(2)
        
        # Click camera icon for upload
        camera_button = driver.find_element(By.CSS_SELECTOR, '[aria-label="Search by image"]')
        camera_button.click()
        
        # Wait for upload tab
        upload_tab = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, '[aria-label="Upload an image"]'))
        )
        upload_tab.click()
        
        # Upload file
        file_input = driver.find_element(By.CSS_SELECTOR, 'input[type="file"]')
        file_input.send_keys(image_path)
        
        time.sleep(3)
        
        # Extract results
        results = []
        try:
            # Get suggested searches (landmark names often appear here)
            suggested_items = driver.find_elements(By.CSS_SELECTOR, '[data-query-name]')
            for item in suggested_items[:5]:
                results.append(item.text)
        except:
            pass
        
        return results
    
    finally:
        driver.quit()

# Example
results = google_lens_search('landmark_image.jpg')
print("[+] Google Lens results:")
for result in results:
    print(f"    - {result}")
EOF
```

### Manual Landmark Recognition Framework

Architectural elements and distinctive features enable manual identification when automated methods fail.

```bash
python3 << 'EOF'
landmark_database = {
    'Eiffel Tower': {
        'location': 'Paris, France',
        'coordinates': (48.8584, 2.2945),
        'characteristics': ['Iron lattice structure', 'Triangular base', 'Built 1889'],
        'visual_identifiers': ['Distinctive pyramidal shape', 'Metal framework', 'Lights at night']
    },
    'Statue of Liberty': {
        'location': 'New York, USA',
        'coordinates': (40.6892, -74.0445),
        'characteristics': ['Copper statue', 'Green patina', '151 feet tall'],
        'visual_identifiers': ['Torch raised', 'Crown', 'Pedestal base']
    },
    'Christ the Redeemer': {
        'location': 'Rio de Janeiro, Brazil',
        'coordinates': (-22.9519, -43.2105),
        'characteristics': ['Art Deco style', 'Arms outstretched', 'Mountain location'],
        'visual_identifiers': ['White concrete statue', 'Arms extended', 'Overlooking city']
    },
    'Big Ben': {
        'location': 'London, England',
        'coordinates': (51.4975, -0.1357),
        'characteristics': ['Clock tower', 'Neo-Gothic', 'Houses Parliament'],
        'visual_identifiers': ['Ornate architecture', 'Large clock faces', 'Golden hue']
    },
    'Taj Mahal': {
        'location': 'Agra, India',
        'coordinates': (27.1751, 78.0421),
        'characteristics': ['White marble', 'Symmetrical', 'Mughal architecture'],
        'visual_identifiers': ['Domed roof', 'Minarets', 'Reflecting pool']
    }
}

# Matching framework
def identify_landmark(visual_features):
    """Match observed features to landmark database"""
    matches = {}
    
    for landmark, data in landmark_database.items():
        matching_characteristics = [
            char for char in data['characteristics']
            if any(feature.lower() in char.lower() for feature in visual_features)
        ]
        
        if matching_characteristics:
            matches[landmark] = {
                'location': data['location'],
                'coordinates': data['coordinates'],
                'matched_features': matching_characteristics,
                'confidence': len(matching_characteristics) / len(data['characteristics'])
            }
    
    return sorted(matches.items(), key=lambda x: x[1]['confidence'], reverse=True)

# Example usage
observed_features = ['white marble', 'domed roof', 'symmetrical', 'minarets']
results = identify_landmark(observed_features)

print("[+] Landmark matching results:")
for landmark, data in results:
    print(f"    {landmark} (Confidence: {data['confidence']:.0%})")
    print(f"      Location: {data['location']}")
    print(f"      Coordinates: {data['coordinates']}")
EOF
```

### Reverse Image Search for Landmark Context

```bash
python3 << 'EOF'
import requests
from datetime import datetime

def tineye_search(image_url):
    """Query TinEye for landmark image occurrences"""
    # [Unverified] - TinEye API requires subscription key
    # Manual web interface: https://tineye.com/
    pass

def wikipedia_landmark_search(landmark_name):
    """Search Wikipedia for landmark information"""
    import requests
    
    url = "https://en.wikipedia.org/w/api.php"
    params = {
        'action': 'query',
        'format': 'json',
        'titles': landmark_name,
        'prop': 'extracts|pageimages',
        'exintro': True,
        'explaintext': True,
        'piprop': 'thumbnail',
        'pithumbsize': 500
    }
    
    response = requests.get(url, params=params)
    data = response.json()
    
    pages = data['query']['pages']
    
    for page_id, page in pages.items():
        if 'extract' in page:
            return {
                'title': page['title'],
                'extract': page['extract'][:200],
                'image': page.get('thumbnail', {}).get('source'),
                'url': f"https://en.wikipedia.org/wiki/{page['title'].replace(' ', '_')}"
            }
    
    return None

# Example
landmark_info = wikipedia_landmark_search('Eiffel Tower')
if landmark_info:
    print("[+] Landmark Information:")
    print(f"    Title: {landmark_info['title']}")
    print(f"    Extract: {landmark_info['extract']}...")
    print(f"    URL: {landmark_info['url']}")
EOF
```

---

## Flora and Fauna Analysis

### Plant Species Identification

Plant species distribution patterns narrow geographic locations. Specific flora indicates climate zones and regions.

```bash
pip install tensorflow tensorflow-hub pillow

python3 << 'EOF'
import tensorflow_hub as hub
import tensorflow as tf
from PIL import Image
import numpy as np
import requests

# Load plant identification model
classifier = hub.load('https://tfhub.dev/google/on_device_vision/classifier/plants_V1/1')

def identify_plant(image_path):
    """Identify plant species in image"""
    img = Image.open(image_path).convert('RGB')
    img_array = tf.image.resize(tf.constant(np.array(img)), [224, 224])
    img_tensor = tf.cast(img_array, tf.uint8)[tf.newaxis, ...]
    
    # Run inference
    results = classifier(img_tensor)
    
    logits = results['logits'][0].numpy()
    top_indices = np.argsort(logits)[::-1][:5]
    
    return [
        {
            'index': int(idx),
            'confidence': float(logits[idx])
        }
        for idx in top_indices
    ]

# Example
plants = identify_plant('plant_image.jpg')
print("[+] Identified plants:")
for idx, plant in enumerate(plants):
    print(f"    {idx+1}. Confidence: {plant['confidence']:.2%}")
EOF
```

### Flora Distribution Database

```bash
python3 << 'EOF'
flora_distribution = {
    'Coconut Palm': {
        'scientific_name': 'Cocos nucifera',
        'regions': ['Tropical zones', '23.5°N - 23.5°S'],
        'countries': ['Philippines', 'Indonesia', 'India', 'Brazil'],
        'climate': 'Tropical, warm all year',
        'altitude': '0-500m'
    },
    'Alpine Edelweiss': {
        'scientific_name': 'Leontopodium nivale',
        'regions': ['Alpine zones', 'Mountain ranges above 1500m'],
        'countries': ['Switzerland', 'Austria', 'Germany', 'France'],
        'climate': 'Alpine, cold winters, short summers',
        'altitude': '1500-3500m'
    },
    'Saguaro Cactus': {
        'scientific_name': 'Carnegiea gigantea',
        'regions': ['Sonoran Desert'],
        'countries': ['USA (Arizona)', 'Mexico (Sonora)'],
        'climate': 'Hot desert, <250mm rainfall/year',
        'altitude': '300-1200m'
    },
    'Giant Sequoia': {
        'scientific_name': 'Sequoiadendron giganteum',
        'regions': ['Sierra Nevada mountains'],
        'countries': ['USA (California)'],
        'climate': 'Mediterranean, mild winters',
        'altitude': '1400-2400m'
    },
    'Baobab Tree': {
        'scientific_name': 'Adansonia',
        'regions': ['African savanna'],
        'countries': ['Senegal', 'Mali', 'Kenya', 'Tanzania'],
        'climate': 'Savanna, tropical dry',
        'altitude': '0-1500m'
    }
}

def geolocate_by_flora(observed_species):
    """Narrow geographic location based on plant species"""
    potential_regions = {}
    
    for species, data in flora_distribution.items():
        if species.lower() in observed_species.lower():
            for country in data['countries']:
                if country not in potential_regions:
                    potential_regions[country] = []
                potential_regions[country].append({
                    'species': species,
                    'climate': data['climate'],
                    'altitude': data['altitude']
                })
    
    return potential_regions

# Example: If Saguaro Cactus observed
observed = "Saguaro Cactus"
locations = geolocate_by_flora(observed)

print("[+] Possible locations based on flora:")
for location, flora in locations.items():
    print(f"    {location}:")
    for plant_data in flora:
        print(f"      - {plant_data['species']} ({plant_data['climate']})")
EOF
```

### Seasonal Flora Analysis

```bash
python3 << 'EOF'
seasonal_indicators = {
    'Cherry Blossoms': {
        'month': 'March-April',
        'regions': ['Japan', 'Korea', 'USA (temperate zones)'],
        'latitude_range': (35, 45)
    },
    'Sunflowers': {
        'month': 'July-September',
        'regions': ['Europe', 'USA (Midwest)', 'Asia'],
        'latitude_range': (35, 55)
    },
    'Autumn Leaves': {
        'month': 'September-November',
        'regions': ['North America', 'Europe', 'East Asia'],
        'latitude_range': (35, 55)
    },
    'Spring Snowmelt': {
        'month': 'March-May',
        'regions': ['Alpine', 'Boreal'],
        'latitude_range': (45, 70)
    },
    'Monsoon Flora': {
        'month': 'June-September',
        'regions': ['India', 'Southeast Asia'],
        'latitude_range': (-20, 30)
    }
}

def analyze_seasonal_flora(species, month):
    """Cross-reference flora with season for location narrowing"""
    matches = []
    
    for flora, data in seasonal_indicators.items():
        if species.lower() in flora.lower():
            if month in data['month'] or str(month) in data['month']:
                matches.append({
                    'flora': flora,
                    'regions': data['regions'],
                    'latitude_range': data['latitude_range'],
                    'season_match': True
                })
    
    return matches

# Example
results = analyze_seasonal_flora('Cherry Blossoms', 'April')
print("[+] Seasonal flora analysis:")
for match in results:
    print(f"    {match['flora']}")
    print(f"      Regions: {', '.join(match['regions'])}")
    print(f"      Latitude: {match['latitude_range'][0]}°N - {match['latitude_range'][1]}°N")
EOF
```

### Fauna Identification and Geographic Distribution

Animal species in images indicate specific biomes and regions.

```bash
pip install tensorflow tensorflow-hub

python3 << 'EOF'
import tensorflow_hub as hub
import tensorflow as tf
from PIL import Image
import numpy as np

# Load animal classification model
classifier = hub.load('https://tfhub.dev/google/on_device_vision/classifier/animals_V1/1')

def identify_animal(image_path):
    """Identify animal species in image"""
    img = Image.open(image_path).convert('RGB')
    img_array = tf.image.resize(tf.constant(np.array(img)), [224, 224])
    img_tensor = tf.cast(img_array, tf.uint8)[tf.newaxis, ...]
    
    results = classifier(img_tensor)
    logits = results['logits'][0].numpy()
    top_indices = np.argsort(logits)[::-1][:5]
    
    return [(int(idx), float(logits[idx])) for idx in top_indices]

# Example
animals = identify_animal('animal_image.jpg')
print("[+] Identified animals:")
for idx, confidence in animals:
    print(f"    Index {idx}: {confidence:.2%}")
EOF
```

**Fauna Distribution Framework**

```bash
python3 << 'EOF'
fauna_distribution = {
    'African Elephant': {
        'regions': ['Sub-Saharan Africa'],
        'countries': ['Kenya', 'Tanzania', 'Botswana', 'Zimbabwe'],
        'habitat': 'Savanna, grassland',
        'latitude_range': (-25, 5)
    },
    'Polar Bear': {
        'regions': ['Arctic'],
        'countries': ['Canada', 'Greenland', 'Russia', 'USA (Alaska)'],
        'habitat': 'Sea ice, tundra',
        'latitude_range': (60, 90)
    },
    'Giant Panda': {
        'regions': ['Central China'],
        'countries': ['China (Sichuan, Shaanxi)'],
        'habitat': 'Bamboo forests, mountains',
        'latitude_range': (28, 35)
    },
    'Jaguar': {
        'regions': ['Central and South America'],
        'countries': ['Brazil', 'Peru', 'Colombia', 'Belize'],
        'habitat': 'Rainforest, wetlands',
        'latitude_range': (-33, 15)
    },
    'Kangaroo': {
        'regions': ['Australia'],
        'countries': ['Australia'],
        'habitat': 'Grasslands, open forest',
        'latitude_range': (-45, -10)
    }
}

def geolocate_by_fauna(observed_animals):
    """Narrow geographic location based on animal species"""
    potential_regions = {}
    
    for animal, data in fauna_distribution.items():
        if animal.lower() in observed_animals.lower():
            for country in data['countries']:
                if country not in potential_regions:
                    potential_regions[country] = []
                potential_regions[country].append({
                    'animal': animal,
                    'habitat': data['habitat'],
                    'latitude': data['latitude_range']
                })
    
    return potential_regions

# Example
observed = "Polar Bear"
locations = geolocate_by_fauna(observed)

print("[+] Geographic locations based on fauna:")
for country, animals in locations.items():
    print(f"    {country}:")
    for animal_data in animals:
        print(f"      - {animal_data['animal']} (Latitude: {animal_data['latitude']})")
EOF
```

---

## Architecture and Infrastructure Recognition

### Building Architectural Style Classification

```bash
pip install tensorflow tensorflow-hub

python3 << 'EOF'
import tensorflow_hub as hub
import tensorflow as tf
from PIL import Image
import numpy as np

# Load architecture classifier
classifier = hub.load('https://tfhub.dev/google/on_device_vision/classifier/architecture_V1/1')

def classify_architecture(image_path):
    """Classify architectural style"""
    img = Image.open(image_path).convert('RGB')
    img_array = tf.image.resize(tf.constant(np.array(img)), [224, 224])
    img_tensor = tf.cast(img_array, tf.uint8)[tf.newaxis, ...]
    
    results = classifier(img_tensor)
    logits = results['logits'][0].numpy()
    top_indices = np.argsort(logits)[::-1][:3]
    
    return [(int(idx), float(logits[idx])) for idx in top_indices]

# Example
styles = classify_architecture('building_image.jpg')
print("[+] Detected architectural styles:")
for idx, confidence in styles:
    print(f"    Style index {idx}: {confidence:.2%}")
EOF
```

### Architectural Style Database and Geographic Distribution

```bash
python3 << 'EOF'
architectural_styles = {
    'Neo-Gothic': {
        'period': '1840-1920',
        'primary_regions': ['Europe', 'North America'],
        'characteristic_features': [
            'Pointed arches',
            'Ribbed vaults',
            'Flying buttresses',
            'Ornate stonework',
            'Steep roofs'
        ],
        'notable_examples': ['Big Ben (London)', 'Notre-Dame (Paris)', 'Parliament (Ottawa)'],
        'geographic_indicators': 'Temperate climate regions, 40-55°N latitude'
    },
    'Art Deco': {
        'period': '1920-1940',
        'primary_regions': ['USA', 'Europe', 'Australia'],
        'characteristic_features': [
            'Geometric patterns',
            'Vertical lines',
            'Stepped forms',
            'Metallic surfaces',
            'Bold colors'
        ],
        'notable_examples': ['Chrysler Building (NYC)', 'Flatiron Building'],
        'geographic_indicators': 'Urban centers, major cities, 30-50°N'
    },
    'Mughal': {
        'period': '1526-1857',
        'primary_regions': ['India', 'Pakistan'],
        'characteristic_features': [
            'Marble domes',
            'Minarets',
            'Arched entrances',
            'Inlay work',
            'Symmetrical layout'
        ],
        'notable_examples': ['Taj Mahal (Agra)', 'Red Fort (Delhi)'],
        'geographic_indicators': 'South Asia, 20-35°N latitude, subtropical climate'
    },
    'Traditional Japanese': {
        'period': 'Historical-present',
        'primary_regions': ['Japan'],
        'characteristic_features': [
            'Curved roofs',
            'Wooden construction',
            'Open floor plans',
            'Natural materials',
            'Minimalist design'
        ],
        'notable_examples': ['Kinkaku-ji (Kyoto)', 'Fushimi Inari Shrine'],
        'geographic_indicators': 'Japan, 30-45°N latitude, monsoon climate'
    },
    'Islamic': {
        'period': '7th century-present',
        'primary_regions': ['Middle East', 'North Africa', 'Central Asia'],
        'characteristic_features': [
            'Geometric tile work',
            'Calligraphy',
            'Domes',
            'Arches',
            'Water features'
        ],
        'notable_examples': ['Blue Mosque (Istanbul)', 'Alhambra (Granada)'],
        'geographic_indicators': 'Islamic regions, 15-50°N latitude'
    },
    'Brutalist': {
        'period': '1950-1970',
        'primary_regions': ['Eastern Europe', 'Soviet Union', 'Western Europe'],
        'characteristic_features': [
            'Massive concrete forms',
            'Raw materials',
            'Fortress-like appearance',
            'Geometric shapes',
            'Monumental scale'
        ],
        'notable_examples': ['Parkhill Estate (Sheffield)', 'Habitat 67 (Montreal)'],
        'geographic_indicators': 'Mid-20th century communist and Western Europe, 40-60°N'
    },
    'Spanish Colonial': {
        'period': '1500-1800',
        'primary_regions': ['Mexico', 'Central America', 'Caribbean'],
        'characteristic_features': [
            'Thick stone walls',
            'Barrel vaults',
            'Interior courtyards',
            'Bell towers',
            'Ornamental facades'
        ],
        'notable_examples': ['Cathedral of Mexico City', 'Cartagena fortifications'],
        'geographic_indicators': 'Latin America, Caribbean, 10-30°N latitude'
    }
}

def identify_architecture_location(style, features):
    """Match architectural style to geographic region"""
    if style in architectural_styles:
        data = architectural_styles[style]
        return {
            'style': style,
            'regions': data['primary_regions'],
            'period': data['period'],
            'features': data['characteristic_features'],
            'geographic_indicators': data['geographic_indicators'],
            'examples': data['notable_examples']
        }
    return None

# Example
arch_info = identify_architecture_location('Mughal', ['domes', 'minarets', 'marble'])
if arch_info:
    print(f"[+] Architecture Identification: {arch_info['style']}")
    print(f"    Period: {arch_info['period']}")
    print(f"    Regions: {', '.join(arch_info['regions'])}")
    print(f"    Geographic: {arch_info['geographic_indicators']}")
EOF
```

### Roofing Material and Design Analysis

Roof types vary dramatically by climate and region, providing geolocation clues.

```bash
python3 << 'EOF'
roof_types = {
    'Steep Pitched (Tile/Slate)': {
        'climate': 'High precipitation, snow',
        'regions': ['Northern Europe', 'Alpine regions', 'Central Europe'],
        'latitude_range': (45, 65),
        'purpose': 'Rapid water/snow runoff',
        'characteristic_steepness': '35-60 degrees'
    },
    'Flat Roof (Concrete/Metal)': {
        'climate': 'Arid, low precipitation',
        'regions': ['Middle East', 'North Africa', 'Southwestern USA'],
        'latitude_range': (20, 45),
        'purpose': 'Minimal water accumulation, heat dissipation',
        'characteristic_steepness': '0-5 degrees'
    },
    'Curved Tile (Spanish/Mediterranean)': {
        'climate': 'Mediterranean, warm',
        'regions': ['Spain', 'Southern Italy', 'Greece', 'Morocco'],
        'latitude_range': (30, 45),
        'purpose': 'Heat reflection, drainage',
        'characteristic_steepness': '25-35 degrees'
    },
    'Metal Corrugated': {
        'climate': 'Tropical, high winds',
        'regions': ['Southeast Asia', 'Caribbean', 'Sub-Saharan Africa'],
        'latitude_range': (-35, 25),
        'purpose': 'Wind resistance, rapid water drainage',
        'characteristic_steepness': '20-35 degrees'
    },
    'Thatch': {
        'climate': 'Temperate, moderate precipitation',
        'regions': ['Northern Europe', 'Rural UK', 'Scandinavia'],
        'latitude_range': (50, 65),
        'purpose': 'Insulation, traditional',
        'characteristic_steepness': '45-55 degrees'
    },
    'Curved/Pagoda Style': {
        'climate': 'Monsoon, moderate precipitation',
        'regions': ['East Asia', 'Southeast Asia'],
        'latitude_range': (20, 45),
        'purpose': 'Water drainage, traditional design',
        'characteristic_steepness': '20-40 degrees (curved)'
    }
}

def analyze_roof_type(observed_characteristics):
    """Match roof characteristics to climate and region"""
    matches = {}
    
    for roof_type, data in roof_types.items():
        match_score = 0
        
        if 'steep' in observed_characteristics and roof_type in ['Steep Pitched', 'Thatch']:
            match_score += 2
        if 'flat' in observed_characteristics and roof_type == 'Flat Roof':
            match_score += 2
        if 'tile' in observed_characteristics and 'Tile' in roof_type:
            match_score += 1
        if 'metal' in observed_characteristics and 'Metal' in roof_type:
            match_score += 1
        
        if match_score > 0:
            matches[roof_type] = {
                'score': match_score,
                'regions': data['regions'],
                'climate': data['climate'],
                'latitude': data['latitude_range']
            }
    
    return sorted(matches.items(), key=lambda x: x[1]['score'], reverse=True)

# Example
observed = ['steep', 'tile', 'dark color']
results = analyze_roof_type(observed)

print("[+] Roof type analysis:")
for roof_type, data in results[:3]:
    print(f"    {roof_type}")
    print(f"      Climate: {data['climate']}")
    print(f"      Regions: {', '.join(data['regions'])}")
    print(f"      Latitude: {data['latitude'][0]}°-{data['latitude'][1]}°")
EOF
```

### Street Infrastructure and Road Markings

Road design, signage, and utility systems vary significantly by country and region.

```bash
python3 << 'EOF'
road_infrastructure = {
    'North America': {
        'road_markings': ['Yellow center line', 'White edge lines', 'Dashed passing zones'],
        'traffic_direction': 'Right-hand driving (USA, Canada)',
        'stop_signs': 'Octagonal red signs',
        'speed_limit_units': 'Miles per hour',
        'lane_markings': 'Broken yellow lines for passing zones'
    },
    'Europe': {
        'road_markings': ['White center line', 'White edge lines', 'Continuous center lines'],
        'traffic_direction': 'Right-hand driving (most countries)',
        'stop_signs': 'Octagonal red/white signs (varies by country)',
        'speed_limit_units': 'Kilometers per hour',
        'lane_markings': 'Solid white lines standard'
    },
    'UK and Commonwealth': {
        'road_markings': ['White dashed lines', 'Double yellow lines (parking)'],
        'traffic_direction': 'Left-hand driving',
        'stop_signs': 'Octagonal red signs',
        'speed_limit_units': 'Miles per hour',
        'lane_markings': 'White dashed lines'
    },
    'Middle East': {
        'road_markings': ['Limited, minimal markings', 'Arabic text on signs'],
        'traffic_direction': 'Right-hand driving',
        'stop_signs': 'Red octagonal signs with Arabic text',
        'speed_limit_units': 'Kilometers per hour',
        'lane_markings': 'Irregular or absent'
    },
    'East Asia': {
        'road_markings': ['White solid/dashed lines', 'Complex multilingual signs'],
        'traffic_direction': 'Left-hand (Japan, Thailand) or Right-hand (China, Korea)',
        'stop_signs': 'Octagonal red signs (varies)',
        'speed_limit_units': 'Kilometers per hour',
        'lane_markings': 'White lines with characters'
    }
}

def analyze_road_infrastructure(observations):
    """Identify region based on road characteristics"""
    region_scores = {region: 0 for region in road_infrastructure.keys()}
    
    for region, features in road_infrastructure.items():
        for observation in observations:
            for key, feature_list in features.items():
                if isinstance(feature_list, list):
                    if any(obs_part.lower() in feat.lower() for feat in feature_list for obs_part in observation.split()):
                        region_scores[region] += 1
    
    return sorted(region_scores.items(), key=lambda x: x[1], reverse=True)

# Example
observations = ['yellow center line', 'mph speed limit', 'octagonal red stop sign']
results = analyze_road_infrastructure(observations)

print("[+] Road infrastructure analysis:")
for region, score in results:
    if score > 0:
        print(f"    {region}: {score} matches")
EOF
```

### Utility Pole and Power Line Analysis

```bash
python3 << 'EOF'
utility_infrastructure = {
    'North America': {
        'pole_type': 'Wooden poles (primary)',
        'pole_height': '10-15 meters',
        'insulator_type': 'Ceramic, brown/grey',
        'transformer_placement': 'Mounted on pole',
        'transformer_configuration': 'Single or dual stacked',
        'crossarm_design': 'Wide, heavy-duty',
        'voltage_distribution': '120/240V residential, 4-35kV distribution'
    },
    'Europe': {
        'pole_type': 'Concrete or metal poles',
        'pole_height': '8-12 meters',
        'insulator_type': 'Porcelain, grey/white',
        'transformer_placement': 'Ground-mounted or pole-mounted',
        'transformer_configuration': 'Consolidated, cleaner design',
        'crossarm_design': 'Compact, streamlined',
        'voltage_distribution': '230V residential, 10-30kV distribution'
    },
    'United Kingdom': {
        'pole_type': 'Wooden poles',
        'pole_height': '6-10 meters',
        'insulator_type': 'Ceramic, white/grey',
        'transformer_placement': 'Ground-mounted in boxes',
        'transformer_configuration': 'Underground or boxed above ground',
        'crossarm_design': 'Minimal, simple design',
        'voltage_distribution': '230V residential single-phase'
    },
    'East Asia': {
        'pole_type': 'Concrete poles (primary)',
        'pole_height': '8-12 meters',
        'insulator_type': 'Porcelain, various colors',
        'transformer_placement': 'Pole-mounted or compact',
        'transformer_configuration': 'Multiple stacked units',
        'crossarm_design': 'Dense, complicated networks',
        'voltage_distribution': '110/220V residential (varies by country)'
    },
    'Latin America': {
        'pole_type': 'Wooden poles',
        'pole_height': '6-10 meters',
        'insulator_type': 'Ceramic, minimal',
        'transformer_placement': 'Pole-mounted',
        'transformer_configuration': 'Basic, exposed wiring',
        'crossarm_design': 'Simple, sometimes disorganized',
        'voltage_distribution': '110/220V residential'
    }
}

def analyze_utility_infrastructure(observations):
    """Identify region based on utility pole characteristics"""
    region_scores = {region: 0 for region in utility_infrastructure.keys()}
    
    for region, features in utility_infrastructure.items():
        for observation in observations:
            for key, value in features.items():
                if isinstance(value, str) and observation.lower() in value.lower():
                    region_scores[region] += 1
    
    return sorted(region_scores.items(), key=lambda x: x[1], reverse=True)

# Example
observations = ['wooden pole', 'ceramic brown insulators', 'dual stacked transformers']
results = analyze_utility_infrastructure(observations)

print("[+] Utility infrastructure analysis:")
for region, score in results:
    if score > 0:
        print(f"    {region}: {score} matches")
EOF
```

### Window and Door Style Analysis

Building envelope features correlate with climate and regional construction standards.

```bash
python3 << 'EOF'
window_door_analysis = {
    'Central/Northern Europe': {
        'window_type': 'Double or triple-glazed',
        'window_frame': 'Wooden, aluminum, or uPVC',
        'frame_color': 'Dark colors (brown, black), white',
        'window_thickness': 'Heavy, insulated',
        'shutters': 'Decorative or functional wooden shutters',
        'door_type': 'Heavy, insulated entrance doors',
        'climate_reason': 'Minimize heat loss in cold climate'
    },
    'Mediterranean': {
        'window_type': 'Single-glazed',
        'window_frame': 'Wooden or metal',
        'frame_color': 'Light colors (white, cream), or dark blue',
        'window_thickness': 'Thin, minimal insulation',
        'shutters': 'Decorative shutters (blue, green, white)',
        'door_type': 'Heavy wooden doors',
        'climate_reason': 'Maximize ventilation, minimize solar gain'
    },
    'Tropical': {
        'window_type': 'Large, open windows',
        'window_frame': 'Metal (aluminum), minimal framing',
        'frame_color': 'Silver, white, light colors',
        'window_thickness': 'Minimal, designed for air flow',
        'shutters': 'Louvered shutters, open mesh',
        'door_type': 'Open design, sliding doors, screens',
        'climate_reason': 'Maximum ventilation, prevent heat accumulation'
    },
    'East Asian Modern': {
        'window_type': 'Modern glazing systems',
        'window_frame': 'Aluminum or composite',
        'frame_color': 'Silver, black, contemporary',
        'window_thickness': 'Variable, energy-efficient',
        'shutters': 'Motorized blinds, minimal external shutters',
        'door_type': 'Sliding glass doors, modern design',
        'climate_reason': 'Flexible climate control'
    }
}

def analyze_window_door_style(observations):
    """Identify region from window/door characteristics"""
    region_scores = {region: 0 for region in window_door_analysis.keys()}
    
    for region, features in window_door_analysis.items():
        for observation in observations:
            for key, value in features.items():
                if isinstance(value, str) and observation.lower() in value.lower():
                    region_scores[region] += 1
    
    return sorted(region_scores.items(), key=lambda x: x[1], reverse=True)

# Example
observations = ['white shutters', 'wooden frame', 'minimal insulation', 'blue shutters']
results = analyze_window_door_style(observations)

print("[+] Window/door style analysis:")
for region, score in results:
    if score > 0:
        print(f"    {region}: {score} matches")
EOF
```

---

## Integrated Geolocation Analysis Framework

### Multi-Source Correlation

Combine GPS, landmarks, flora/fauna, and architecture for maximum precision.

```bash
python3 << 'EOF'
import json
from datetime import datetime

class GeolocationAnalyzer:
    def __init__(self):
        self.findings = {
            'gps_data': None,
            'landmarks': [],
            'flora': [],
            'fauna': [],
            'architecture': [],
            'infrastructure': [],
            'combined_analysis': None,
            'confidence_score': 0
        }
    
    def add_gps(self, latitude, longitude, accuracy=None):
        """Add GPS coordinate"""
        self.findings['gps_data'] = {
            'latitude': latitude,
            'longitude': longitude,
            'accuracy': accuracy,
            'maps_url': f"https://maps.google.com/?q={latitude},{longitude}"
        }
    
    def add_landmark(self, landmark_name, confidence):
        """Add identified landmark"""
        self.findings['landmarks'].append({
            'name': landmark_name,
            'confidence': confidence
        })
    
    def add_flora(self, species_list):
        """Add identified plants"""
        self.findings['flora'].extend(species_list)
    
    def add_fauna(self, animal_list):
        """Add identified animals"""
        self.findings['fauna'].extend(animal_list)
    
    def add_architecture(self, style, features):
        """Add architectural analysis"""
        self.findings['architecture'].append({
            'style': style,
            'features': features
        })
    
    def add_infrastructure(self, infrastructure_type, observations):
        """Add infrastructure analysis"""
        self.findings['infrastructure'].append({
            'type': infrastructure_type,
            'observations': observations
        })
    
    def calculate_confidence(self):
        """Calculate overall confidence score"""
        confidence = 0
        
        if self.findings['gps_data']:
            confidence += 40  # GPS is most reliable
        
        if len(self.findings['landmarks']) > 0:
            confidence += 20 * min(len(self.findings['landmarks']), 1)
        
        if len(self.findings['flora']) > 1:
            confidence += 15
        
        if len(self.findings['fauna']) > 0:
            confidence += 10
        
        if len(self.findings['architecture']) > 0:
            confidence += 10
        
        if len(self.findings['infrastructure']) > 0:
            confidence += 5
        
        self.findings['confidence_score'] = min(confidence, 100)
        return self.findings['confidence_score']
    
    def generate_report(self):
        """Generate comprehensive geolocation report"""
        self.calculate_confidence()
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'findings': self.findings,
            'summary': self._generate_summary(),
            'confidence': self.findings['confidence_score']
        }
        
        return report
    
    def _generate_summary(self):
        """Create text summary"""
        summary = []
        
        if self.findings['gps_data']:
            summary.append(f"GPS: {self.findings['gps_data']['latitude']:.4f}, {self.findings['gps_data']['longitude']:.4f}")
        
        if self.findings['landmarks']:
            top_landmark = self.findings['landmarks'][0]
            summary.append(f"Landmark: {top_landmark['name']} ({top_landmark['confidence']:.0%})")
        
        if self.findings['flora']:
            summary.append(f"Flora: {', '.join(self.findings['flora'][:2])}")
        
        if self.findings['fauna']:
            summary.append(f"Fauna: {', '.join(self.findings['fauna'][:2])}")
        
        if self.findings['architecture']:
            arch_style = self.findings['architecture'][0]['style']
            summary.append(f"Architecture: {arch_style}")
        
        return " | ".join(summary)

# Example usage
analyzer = GeolocationAnalyzer()
analyzer.add_gps(51.5074, -0.1278, accuracy=15)
analyzer.add_landmark('Big Ben', 0.95)
analyzer.add_architecture('Neo-Gothic', ['Clock tower', 'Ornate stonework'])
analyzer.add_infrastructure('Road', ['Left-hand driving', 'White dashed lines'])

report = analyzer.generate_report()
print("[+] Geolocation Analysis Report:")
print(json.dumps(report, indent=2))
EOF
```

### Flag Construction from Geolocation Data

```bash
python3 << 'EOF'
def construct_geolocation_flag(analysis_results):
    """Build CTF flag from geolocation analysis"""
    flag_segments = []
    
    # Segment 1: Coordinate precision
    if analysis_results['gps_data']:
        lat = str(analysis_results['gps_data']['latitude']).replace('.', '')[:6]
        lon = str(analysis_results['gps_data']['longitude']).replace('.', '')[:6]
        flag_segments.append(f"GPS_{lat}_{lon}")
    
    # Segment 2: Landmark identifier
    if analysis_results['landmarks']:
        landmark_code = analysis_results['landmarks'][0]['name'].replace(' ', '_').upper()
        flag_segments.append(landmark_code)
    
    # Segment 3: Flora/Fauna code
    if analysis_results['flora'] or analysis_results['fauna']:
        bio_code = ''.join([s[0].upper() for s in analysis_results['flora'][:2]])
        bio_code += ''.join([a[0].upper() for a in analysis_results['fauna'][:2]])
        flag_segments.append(f"BIO_{bio_code}")
    
    # Segment 4: Architecture code
    if analysis_results['architecture']:
        arch_code = analysis_results['architecture'][0]['style'].replace(' ', '_').upper()
        flag_segments.append(arch_code)
    
    # Segment 5: Confidence score
    flag_segments.append(f"CONF_{analysis_results['confidence_score']}")
    
    return "flag{" + "_".join(flag_segments) + "}"

# Example
test_results = {
    'gps_data': {'latitude': 40.7128, 'longitude': -74.0060},
    'landmarks': [{'name': 'Statue of Liberty', 'confidence': 0.98}],
    'flora': ['Oak', 'Maple'],
    'fauna': ['Pigeon', 'Squirrel'],
    'architecture': [{'style': 'Neoclassical', 'features': ['Columns']}],
    'confidence_score': 85
}

flag = construct_geolocation_flag(test_results)
print(f"[+] Constructed flag: {flag}")
EOF
```

### Common CTF Geolocation Patterns

**Pattern: Hidden GPS in Image Metadata + Verification**

- Extract EXIF GPS coordinates
- Reverse geocode to address
- Cross-reference with landmarks visible in image
- Verify through satellite imagery (Google Maps)

**Pattern: Visual-Only Geolocation**

- Identify landmarks/architecture
- Analyze flora/fauna
- Cross-reference infrastructure characteristics
- Triangulate from multiple clues

**Pattern: Coordinate Encoding**

- GPS coordinates themselves encode flag
- Extract latitude/longitude as numeric values
- Convert decimal places to characters
- Latitude/longitude deltas may encode data

**Pattern: Regional Identifier Construction**

- Multiple images from different regions
- Concatenate regional codes (country abbreviations, area codes)
- Architecture/infrastructure codes form flag

**Complete CTF Geolocation Workflow**

```bash
#!/bin/bash

IMAGE="challenge_image.jpg"

# 1. Extract GPS and verify
echo "[*] Extracting GPS coordinates..."
exiftool -GPS* "$IMAGE" | tee gps_raw.txt

# 2. Analyze landmarks
echo "[*] Analyzing landmarks..."
python3 << 'PYTHON'
import tensorflow_hub as hub
from PIL import Image
import numpy as np
import tensorflow as tf

detector = hub.load('https://tfhub.dev/google/on_device_vision/classifier/landmarks_classifier_asia_V1/1')
img = Image.open('challenge_image.jpg').resize((321, 321))
img_tensor = tf.cast(tf.constant(np.array(img)), tf.uint8)[tf.newaxis, ...]
results = detector(img_tensor)
print("[+] Landmarks detected")
PYTHON

# 3. Analyze flora and fauna
echo "[*] Identifying flora and fauna..."
python3 << 'PYTHON'
# Plant and animal detection here
PYTHON

# 4. Analyze architecture and infrastructure
echo "[*] Analyzing architecture..."
exiftool "$IMAGE" | grep -i "software\|model\|datetime"

# 5. Construct timeline and flag
echo "[*] Compiling geolocation analysis..."
python3 << 'PYTHON'
# Multi-source analysis and flag construction
PYTHON

echo "[+] Geolocation analysis complete"
```

---

## Timezone Analysis

### Temporal Pattern Recognition

**Activity-Based Timezone Detection**

```python
# Analyze posting patterns to determine timezone
from collections import Counter
from datetime import datetime
import pytz

def analyze_timezone(utc_timestamps):
    """
    Analyze posting patterns to infer local timezone
    Input: List of UTC datetime objects
    Output: Probable timezone(s)
    """
    
    # Convert to hour of day
    hours = [ts.hour for ts in utc_timestamps]
    hour_counts = Counter(hours)
    
    # Find peak activity window (typically 8am-11pm local time)
    peak_hours = sorted(hour_counts.items(), key=lambda x: x[1], reverse=True)[:5]
    peak_hour_values = [h[0] for h in peak_hours]
    
    # Calculate probable timezone offset
    # Assuming peak activity around 9am-9pm local
    avg_peak = sum(peak_hour_values) / len(peak_hour_values)
    
    # Typical activity center is ~15:00 local (3pm)
    offset = 15 - avg_peak
    
    # Find matching timezones
    possible_timezones = []
    for tz in pytz.all_timezones:
        try:
            tz_offset = datetime.now(pytz.timezone(tz)).utcoffset().total_seconds() / 3600
            if abs(tz_offset - offset) < 1:  # Within 1 hour
                possible_timezones.append(tz)
        except:
            continue
    
    return possible_timezones, offset

# Example usage
timestamps = [
    datetime(2024, 1, 15, 14, 30),  # UTC
    datetime(2024, 1, 15, 15, 45),
    datetime(2024, 1, 15, 23, 20),
    datetime(2024, 1, 16, 1, 15),
    datetime(2024, 1, 16, 13, 50)
]

timezones, offset = analyze_timezone(timestamps)
print(f"Estimated UTC offset: {offset}")
print(f"Possible timezones: {timezones[:5]}")  # Show first 5
```

**Sleep Pattern Analysis**

```python
def detect_sleep_pattern(timestamps):
    """
    Identify likely sleep hours and infer timezone
    Assumes 6-8 hour sleep period, typically 11pm-7am local
    """
    
    # Group by hour across all days
    hour_activity = Counter([ts.hour for ts in timestamps])
    
    # Find consecutive hours with minimal activity
    hours = sorted(hour_activity.keys())
    min_activity_threshold = min(hour_activity.values()) * 1.5
    
    quiet_hours = [h for h in range(24) if hour_activity.get(h, 0) < min_activity_threshold]
    
    # Find longest consecutive sequence
    def longest_consecutive(hours):
        if not hours:
            return []
        
        sequences = []
        current = [hours[0]]
        
        for i in range(1, len(hours)):
            if hours[i] == hours[i-1] + 1 or (hours[i] == 0 and hours[i-1] == 23):
                current.append(hours[i])
            else:
                sequences.append(current)
                current = [hours[i]]
        sequences.append(current)
        
        return max(sequences, key=len)
    
    sleep_hours = longest_consecutive(quiet_hours)
    
    # Estimate timezone: assume sleep midpoint is ~3am local
    if sleep_hours:
        sleep_midpoint = (min(sleep_hours) + max(sleep_hours)) / 2
        utc_offset = 3 - sleep_midpoint
        
        return sleep_hours, utc_offset
    
    return None, None

# [Inference] Sleep patterns provide timezone estimates but may be affected by:
# - Shift work schedules
# - Travel and jet lag
# - Irregular sleep patterns
# - Automated posting tools
```

**Workday Pattern Recognition**

```python
def identify_work_schedule(timestamps):
    """
    Detect work hours and weekend patterns
    """
    from datetime import datetime
    
    weekday_hours = Counter()
    weekend_hours = Counter()
    
    for ts in timestamps:
        hour = ts.hour
        # Monday = 0, Sunday = 6
        if ts.weekday() < 5:  # Weekday
            weekday_hours[hour] += 1
        else:  # Weekend
            weekend_hours[hour] += 1
    
    # Identify work hours (low activity on weekdays)
    if weekday_hours:
        avg_weekday = sum(weekday_hours.values()) / len(weekday_hours)
        work_hours = [h for h in range(24) 
                     if weekday_hours.get(h, 0) < avg_weekday * 0.5]
        
        # Typical work day is 9am-5pm local
        if work_hours:
            # Find 8-hour window with lowest activity
            min_activity_window = None
            min_activity = float('inf')
            
            for start in range(24):
                window = [(start + i) % 24 for i in range(8)]
                activity = sum(weekday_hours.get(h, 0) for h in window)
                if activity < min_activity:
                    min_activity = activity
                    min_activity_window = window
            
            return min_activity_window
    
    return None

# [Inference] Work patterns indicate:
# - Timezone (9am-5pm typical work hours)
# - Employment status (regular vs irregular hours)
# - Work arrangement (office vs remote)
```

### Timestamp Metadata Analysis

**EXIF Timestamp Extraction**

```bash
# Extract all timestamp information
exiftool -time:all -G image.jpg

# Key timestamp fields:
# - DateTimeOriginal: When photo was taken
# - CreateDate: Camera creation time
# - ModifyDate: Last modification
# - GPSTimeStamp: GPS time (UTC)
# - OffsetTime: Timezone offset

# Compare timestamps to detect timezone
exiftool -DateTimeOriginal -OffsetTimeOriginal -GPSTimeStamp image.jpg

# Check for timezone inconsistencies
exiftool -if '$DateTimeOriginal ne $CreateDate' -DateTimeOriginal -CreateDate -FileName ./
```

**Document Metadata Timezone**

```bash
# PDF creation timezone
exiftool -CreationDate -ModDate document.pdf

# Office documents (timezone in metadata)
exiftool -CreateDate -ModifyDate -Company -Author document.docx

# Extract and parse timezone
exiftool -CreateDate document.docx | grep -oP '[+-]\d{2}:\d{2}'
```

**Social Media Post Timestamp Analysis**

```python
def extract_twitter_timestamp_tz(tweet_data):
    """
    Extract timezone from Twitter timestamp
    Twitter API returns created_at in UTC
    """
    import json
    from datetime import datetime
    
    # Example: "created_at": "Wed Oct 10 20:19:24 +0000 2018"
    created_at = tweet_data.get('created_at')
    
    # Parse timestamp
    dt = datetime.strptime(created_at, "%a %b %d %H:%M:%S %z %Y")
    
    # Check user timezone setting (if available)
    user_tz = tweet_data.get('user', {}).get('time_zone')
    utc_offset = tweet_data.get('user', {}).get('utc_offset')
    
    return {
        'timestamp_utc': dt,
        'user_timezone': user_tz,
        'utc_offset_seconds': utc_offset
    }

# [Unverified] User-set timezones may not reflect actual location
# Users can manually configure timezone settings
```

### Solar Time Calculation

**Sun Position from Timestamp**

```python
# Using pysolar for sun position calculations
from pysolar.solar import get_altitude, get_azimuth
from datetime import datetime
import pytz

def calculate_sun_position(latitude, longitude, timestamp_utc):
    """
    Calculate sun altitude and azimuth for given location and time
    """
    
    # Ensure timestamp is timezone-aware
    if timestamp_utc.tzinfo is None:
        timestamp_utc = pytz.utc.localize(timestamp_utc)
    
    altitude = get_altitude(latitude, longitude, timestamp_utc)
    azimuth = get_azimuth(latitude, longitude, timestamp_utc)
    
    return {
        'altitude': altitude,  # Degrees above horizon
        'azimuth': azimuth,    # Degrees from north (clockwise)
        'timestamp': timestamp_utc
    }

# Example: Verify claimed photo timestamp
claimed_location = (40.7128, -74.0060)  # New York City
claimed_time = datetime(2024, 6, 15, 14, 30, tzinfo=pytz.utc)

sun_pos = calculate_sun_position(*claimed_location, claimed_time)
print(f"Sun altitude: {sun_pos['altitude']:.2f}°")
print(f"Sun azimuth: {sun_pos['azimuth']:.2f}°")

# Compare with shadow analysis to verify timestamp and location
```

**Sunrise/Sunset Time Correlation**

```python
from pysolar.solar import get_altitude
from datetime import datetime, timedelta
import pytz

def find_sunrise_sunset(latitude, longitude, date):
    """
    Calculate sunrise and sunset times for a location
    """
    
    # Start at midnight UTC
    start = datetime.combine(date, datetime.min.time()).replace(tzinfo=pytz.utc)
    
    sunrise = None
    sunset = None
    
    # Check every minute for sun crossing horizon
    for minutes in range(24 * 60):
        current_time = start + timedelta(minutes=minutes)
        altitude = get_altitude(latitude, longitude, current_time)
        
        # Sunrise: sun just above horizon
        if altitude > 0 and sunrise is None:
            sunrise = current_time
        
        # Sunset: sun just below horizon after sunrise
        if altitude < 0 and sunrise is not None and sunset is None:
            sunset = current_time
            break
    
    return sunrise, sunset

# Use case: Image shows sunrise/sunset, correlate with location
lat, lon = 51.5074, -0.1278  # London
date = datetime(2024, 10, 20).date()

sunrise, sunset = find_sunrise_sunset(lat, lon, date)
print(f"Sunrise: {sunrise.strftime('%H:%M:%S UTC')}")
print(f"Sunset: {sunset.strftime('%H:%M:%S UTC')}")

# [Inference] If image metadata timestamp matches calculated sunrise/sunset time,
# this supports claimed location (within timezone)
```

## Language and Signage Clues

### Written Language Identification

**Text Extraction from Images**

```bash
# Using Tesseract OCR
tesseract image.jpg output -l eng
tesseract image.jpg output -l ara  # Arabic
tesseract image.jpg output -l chi_sim  # Chinese Simplified
tesseract image.jpg output -l rus  # Russian

# Detect language automatically
tesseract image.jpg output --oem 1 --psm 3

# Extract text from specific region
tesseract image.jpg output --psm 6  # Assume uniform block of text

# Multiple languages
tesseract image.jpg output -l eng+fra+deu
```

**Python Language Detection**

```python
# Using langdetect library
from langdetect import detect, detect_langs

text = "Extracted text from signage"

# Simple detection
language = detect(text)
print(f"Detected language: {language}")

# Multiple possibilities with confidence
languages = detect_langs(text)
for lang in languages:
    print(f"{lang.lang}: {lang.prob:.2%}")

# Map language to probable countries
language_country_map = {
    'en': ['US', 'UK', 'CA', 'AU', 'NZ', 'IE'],
    'es': ['ES', 'MX', 'AR', 'CO', 'PE', 'VE', 'CL'],
    'fr': ['FR', 'CA', 'BE', 'CH', 'LU'],
    'de': ['DE', 'AT', 'CH', 'LI', 'LU'],
    'pt': ['PT', 'BR', 'AO', 'MZ'],
    'ar': ['SA', 'EG', 'DZ', 'SD', 'IQ', 'MA'],
    'zh-cn': ['CN'],
    'zh-tw': ['TW', 'HK'],
    'ja': ['JP'],
    'ko': ['KR'],
    'ru': ['RU', 'BY', 'KZ', 'KG']
}
```

**Script Identification**

```python
import unicodedata

def identify_script(text):
    """
    Identify writing script from text
    """
    scripts = {}
    
    for char in text:
        if char.isspace():
            continue
        try:
            script = unicodedata.name(char).split()[0]
            scripts[script] = scripts.get(script, 0) + 1
        except:
            continue
    
    # Most common script
    if scripts:
        dominant_script = max(scripts.items(), key=lambda x: x[1])
        return dominant_script[0], scripts
    
    return None, scripts

# Script to region mapping
script_regions = {
    'LATIN': 'Europe/Americas/Africa',
    'CYRILLIC': 'Russia/Eastern Europe/Central Asia',
    'ARABIC': 'Middle East/North Africa/Central Asia',
    'DEVANAGARI': 'India/Nepal',
    'BENGALI': 'Bangladesh/India (West Bengal)',
    'HANGUL': 'South Korea/North Korea',
    'HIRAGANA': 'Japan',
    'KATAKANA': 'Japan',
    'HAN': 'China/Taiwan/Japan/Korea',
    'THAI': 'Thailand',
    'HEBREW': 'Israel',
    'GREEK': 'Greece/Cyprus'
}

# [Inference] Script identification narrows geographic region but doesn't
# definitively identify location without additional context
```

### Signage and Brand Recognition

**Business Signage Analysis**

```python
# Common chain identification
regional_chains = {
    'Tesco': ['UK', 'IE', 'CZ', 'SK', 'HU'],
    'Walmart': ['US', 'CA', 'MX'],
    'Carrefour': ['FR', 'ES', 'IT', 'BR', 'AR'],
    '7-Eleven': ['US', 'JP', 'TH', 'TW', 'MY'],
    'Lawson': ['JP', 'CN'],
    'FamilyMart': ['JP', 'TW', 'TH', 'CN'],
    'Oxxo': ['MX'],
    'Wawa': ['US-East Coast'],
    'H-E-B': ['US-Texas'],
    'Publix': ['US-Southeast'],
    'Tim Hortons': ['CA', 'US-Northeast'],
    'Nando\'s': ['ZA', 'UK', 'AU', 'CA'],
    'Jollibee': ['PH', 'US-CA'],
}

def identify_from_signage(business_name):
    """
    Return probable countries based on business signage
    """
    for business, countries in regional_chains.items():
        if business.lower() in business_name.lower():
            return countries
    return None
```

**Street Sign Patterns**

Street sign characteristics by region:

```python
street_sign_characteristics = {
    'US': {
        'shape': 'Rectangle (street names), octagon (stop)',
        'colors': 'Green/white (streets), red/white (stop)',
        'mounting': 'Often on poles, sometimes on buildings',
        'text': 'English, sometimes Spanish',
        'style': 'MUTCD standard'
    },
    'UK': {
        'shape': 'Rectangle',
        'colors': 'White text on blue (motorways), green (primary), white (local)',
        'mounting': 'Typically on poles or buildings',
        'text': 'English, Welsh in Wales',
        'style': 'Worboys system'
    },
    'France': {
        'shape': 'Rectangle',
        'colors': 'Blue (motorways), green (major), white (local)',
        'mounting': 'Often on building walls',
        'text': 'French',
        'style': 'EU standard with French additions'
    },
    'Germany': {
        'shape': 'Rectangle',
        'colors': 'Blue (motorways), yellow (federal roads)',
        'mounting': 'Poles, overhead gantries',
        'text': 'German',
        'style': 'EU standard'
    },
    'Japan': {
        'shape': 'Rectangle, sometimes with rounded corners',
        'colors': 'Green/white (expressways), blue/white (national)',
        'mounting': 'Poles, overhead',
        'text': 'Japanese (kanji/hiragana), sometimes English',
        'style': 'Distinctive Japanese style'
    }
}
```

**License Plate Patterns**

```python
license_plate_patterns = {
    'US': {
        'format': 'Varies by state',
        'colors': 'State-specific',
        'features': 'State name, slogan, single plate (rear) or two plates',
        'notes': 'Can identify specific state from design'
    },
    'EU': {
        'format': 'Country code + number/letter combination',
        'colors': 'White background, blue strip on left',
        'features': 'EU stars on blue strip, country code (D, F, GB, etc.)',
        'notes': 'Standardized across EU members'
    },
    'UK': {
        'format': 'Two letters, two numbers, three letters (current)',
        'colors': 'White (front), yellow (rear)',
        'features': 'Front plate white, rear plate yellow',
        'notes': 'First two letters indicate region of registration'
    },
    'Japan': {
        'format': 'Region name + classification number + hiragana + 4 digits',
        'colors': 'White (private), green on white (commercial), yellow (kei cars)',
        'features': 'Regional office name at top',
        'notes': 'Distinctive format with region names in kanji'
    },
    'Australia': {
        'format': 'Varies by state/territory',
        'colors': 'State-specific',
        'features': 'State/territory name or abbreviation',
        'notes': 'Can identify state from format'
    }
}

# [Inference] License plates are strong location indicators but:
# - May not be visible or readable in images
# - Can be from different regions than photo location (tourists, transfers)
# - Require knowledge of regional variations
```

### Phone Number and Address Formats

**Phone Number Analysis**

```python
import phonenumbers
from phonenumbers import geocoder, carrier

def analyze_phone_number(phone_string):
    """
    Extract country and region from phone number
    """
    try:
        number = phonenumbers.parse(phone_string, None)
        
        # Get country
        country = geocoder.description_for_number(number, "en")
        
        # Get carrier
        carrier_name = carrier.name_for_number(number, "en")
        
        # Get country code
        country_code = number.country_code
        
        # Validate
        is_valid = phonenumbers.is_valid_number(number)
        
        return {
            'country': country,
            'carrier': carrier_name,
            'country_code': country_code,
            'valid': is_valid
        }
    except phonenumbers.NumberParseException:
        return None

# Example usage
# US: +1-555-123-4567
# UK: +44 20 7946 0958
# Japan: +81 3-1234-5678
```

**Postal Code Formats**

```python
postal_code_patterns = {
    'US': r'^\d{5}(-\d{4})?$',  # 12345 or 12345-6789
    'UK': r'^[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}$',  # SW1A 1AA
    'Canada': r'^[A-Z]\d[A-Z]\s?\d[A-Z]\d$',  # K1A 0B1
    'Germany': r'^\d{5}$',  # 12345
    'France': r'^\d{5}$',  # 75001
    'Japan': r'^\d{3}-?\d{4}$',  # 123-4567
    'Australia': r'^\d{4}$',  # 2000
    'Netherlands': r'^\d{4}\s?[A-Z]{2}$',  # 1234 AB
    'Sweden': r'^\d{3}\s?\d{2}$',  # 123 45
    'Brazil': r'^\d{5}-?\d{3}$',  # 12345-678
}

import re

def identify_postal_code(code):
    """
    Identify country from postal code format
    """
    code = code.strip().upper()
    
    matches = []
    for country, pattern in postal_code_patterns.items():
        if re.match(pattern, code):
            matches.append(country)
    
    return matches

# [Inference] Postal codes visible in signage, mail, or addresses can narrow location
```

### Architectural and Urban Planning Clues

**Building Style Indicators**

```python
architectural_indicators = {
    'Dutch_Colonial': {
        'features': ['Gabled roofs', 'Brick construction', 'Terrace houses'],
        'regions': ['Netherlands', 'Belgium', 'Former Dutch colonies'],
        'era': '17th-19th century'
    },
    'Soviet_Brutalism': {
        'features': ['Concrete panel construction', 'Repetitive patterns', 'Utilitarian design'],
        'regions': ['Former USSR', 'Eastern Europe', 'Former Soviet allies'],
        'era': '1960s-1980s'
    },
    'American_Suburban': {
        'features': ['Wood/vinyl siding', 'Attached garage', 'Front yard'],
        'regions': ['US', 'Canada'],
        'era': 'Post-1950'
    },
    'Mediterranean': {
        'features': ['Terracotta roofs', 'White/cream walls', 'Arched elements'],
        'regions': ['Southern Europe', 'California', 'Latin America'],
        'era': 'Various'
    }
}
```

**Urban Infrastructure**

Observable infrastructure elements:

- Power line configuration (overhead vs underground)
- Traffic light mounting style
- Street lighting design
- Sidewalk width and materials
- Bollard designs
- Utility pole markers
- Fire hydrant styles
- Manhole cover designs

[Inference] Infrastructure styles often reflect national standards but require expertise to identify accurately.

## Shadow Analysis

### Shadow Direction and Length Calculation

**Basic Shadow Geometry**

```python
import math
from pysolar.solar import get_altitude, get_azimuth
from datetime import datetime
import pytz

def calculate_shadow_properties(latitude, longitude, timestamp_utc, object_height):
    """
    Calculate expected shadow length and direction
    
    Parameters:
    - latitude, longitude: Location coordinates
    - timestamp_utc: UTC timestamp
    - object_height: Height of object casting shadow
    
    Returns: shadow length and azimuth
    """
    
    # Get sun position
    sun_altitude = get_altitude(latitude, longitude, timestamp_utc)
    sun_azimuth = get_azimuth(latitude, longitude, timestamp_utc)
    
    # Shadow can't exist if sun is below horizon
    if sun_altitude <= 0:
        return None, None
    
    # Calculate shadow length using trigonometry
    # tan(altitude) = object_height / shadow_length
    sun_altitude_rad = math.radians(sun_altitude)
    shadow_length = object_height / math.tan(sun_altitude_rad)
    
    # Shadow direction is opposite to sun azimuth
    shadow_azimuth = (sun_azimuth + 180) % 360
    
    return {
        'shadow_length': shadow_length,
        'shadow_azimuth': shadow_azimuth,  # Degrees from north
        'sun_altitude': sun_altitude,
        'sun_azimuth': sun_azimuth
    }

# Example: Verify photo timestamp
# Person 1.8m tall casts shadow in photo
location = (34.0522, -118.2437)  # Los Angeles
claimed_time = datetime(2024, 6, 15, 19, 30, tzinfo=pytz.utc)  # 12:30 PM PDT
person_height = 1.8  # meters

shadow = calculate_shadow_properties(*location, claimed_time, person_height)
if shadow:
    print(f"Expected shadow length: {shadow['shadow_length']:.2f} meters")
    print(f"Shadow direction: {shadow['shadow_azimuth']:.1f}° from north")
    print(f"Sun altitude: {shadow['sun_altitude']:.1f}°")
```

### Shadow Analysis from Images

**Measuring Shadow Angle in Images**

```python
def measure_shadow_angle_from_image(image_path):
    """
    Semi-automated shadow direction measurement
    Requires manual identification of shadow in image
    
    Returns angle relative to image orientation
    """
    import cv2
    import numpy as np
    
    # Load image
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Edge detection to identify shadow boundaries
    edges = cv2.Canny(gray, 50, 150)
    
    # Hough Line Transform to detect straight lines (shadow edges)
    lines = cv2.HoughLinesP(edges, 1, np.pi/180, threshold=100, 
                            minLineLength=50, maxLineGap=10)
    
    if lines is not None:
        # Calculate angles of detected lines
        angles = []
        for line in lines:
            x1, y1, x2, y2 = line[0]
            angle = math.degrees(math.atan2(y2 - y1, x2 - x1))
            angles.append(angle)
        
        # Most common angle likely represents shadow direction
        return np.median(angles)
    
    return None

# [Unverified] Automated shadow detection requires clear shadows and may not work
# in complex scenes. Manual analysis often more reliable.
```

**Manual Shadow Analysis Workflow**

Steps for manual shadow analysis:

1. **Identify reference object with known height**
    
    - People (~1.6-1.8m)
    - Vehicles (cars ~1.5m, trucks ~2.5m)
    - Street signs (standard heights vary by country)
    - Buildings (count floors, ~3-4m per floor)
2. **Measure shadow-to-object ratio**
    
    ```python
    # Using image measurements
    object_height_pixels = 150  # Measured in image
    shadow_length_pixels = 200  # Measured in image
    known_object_height = 1.8  # meters (e.g., person)
    
    # Calculate actual shadow length
    pixel_to_meter_ratio = known_object_height / object_height_pixels
    shadow_length_meters = shadow_length_pixels * pixel_to_meter_ratio
    
    # Calculate sun altitude
    sun_altitude = math.degrees(math.atan(known_object_height / shadow_length_meters))
    print(f"Sun altitude: {sun_altitude:.1f}°")
    ```
    
3. **Determine shadow direction**
    
    - Use compass if available in image
    - Use street orientation (if known)
    - Use building orientation (if known address)
    - Use satellite imagery to match orientation
4. **Calculate possible locations and times**
    
    ```python
    def find_matching_locations(sun_altitude, shadow_azimuth, date, target_hour_range):
        """
        Find locations where sun matches observed shadow at given date/time
        
        [Inference] This requires iterating through possible locations and times
        """
        
        possible_locations = []
        
        # Iterate through latitude/longitude grid
        for lat in range(-90, 91, 5):  # Every 5 degrees
            for lon in range(-180, 181, 5):
                for hour in range(*target_hour_range):
                    timestamp = datetime(date.year, date.month, date.day, hour, 
                                       tzinfo=pytz.utc)
                    
                    calc_altitude = get_altitude(lat, lon, timestamp)
                    calc_azimuth = get_azimuth(lat, lon, timestamp)
                    
                    # Check if matches observed values (within tolerance)
                    if (abs(calc_altitude - sun_altitude) < 5 and 
                        abs((calc_azimuth + 180) % 360 - shadow_azimuth) < 15):
                        possible_locations.append({
                            'lat': lat,
                            'lon': lon,
                            'time': timestamp,
                            'altitude_diff': abs(calc_altitude - sun_altitude),
                            'azimuth_diff': abs((calc_azimuth + 180) % 360 - shadow_azimuth)
                        })
        
        return possible_locations
    ```
    

### Advanced Shadow Techniques

**Multi-Shadow Triangulation**

```python
def triangulate_from_multiple_shadows(shadow_data):
    """
    Use multiple objects with different shadow directions to pinpoint location
    
    shadow_data format:
    [
        {'azimuth': 180, 'altitude_derived': 45},
        {'azimuth': 185, 'altitude_derived': 45},
        ...
    ]
    
    [Inference] Multiple shadows at same time should have consistent sun position
    If shadows point different directions, they may be from different times or
    the surface is not level
    """
    
    # Average the shadow azimuths (should be very similar)
    azimuths = [s['azimuth'] for s in shadow_data]
    avg_azimuth = sum(azimuths) / len(azimuths)
    azimuth_variance = max(azimuths) - min(azimuths)
    
    if azimuth_variance > 10:
        print("[Warning] High variance in shadow directions suggests:")
        print("- Non-level ground")
        print("- Different times")
        print("- Measurement error")
    
    # Average altitudes
    altitudes = [s['altitude_derived'] for s in shadow_data]
    avg_altitude = sum(altitudes) / len(altitudes)
    
    return avg_azimuth, avg_altitude
```

**Seasonal Shadow Analysis**

```python
def determine_season_from_shadow(latitude, shadow_length_ratio):
    """
    Estimate season based on shadow length at noon
    
    shadow_length_ratio = shadow_length / object_height
    
    [Inference] Sun altitude varies by season:
    - Summer: Higher sun, shorter shadows
    - Winter: Lower sun, longer shadows
    """
    
    # Calculate sun altitude from shadow ratio
    sun_altitude = math.degrees(math.atan(1 / shadow_length_ratio))
    
    # At solar noon, sun altitude varies by season
    # Maximum altitude = 90° - |latitude| + 23.5° (summer solstice)
    # Minimum altitude = 90° - |latitude| - 23.5° (winter solstice)
    
    max_altitude = 90 - abs(latitude) + 23.5
    min_altitude = 90 - abs(latitude) - 23.5

# Estimate season based on observed altitude
if sun_altitude > max_altitude - 5:
    season = "Summer (June-August Northern, Dec-Feb Southern)"
elif sun_altitude < min_altitude + 5:
    season = "Winter (Dec-Feb Northern, June-August Southern)"
else:
    season = "Spring/Autumn"

return {
    'observed_altitude': sun_altitude,
    'max_possible': max_altitude,
    'min_possible': min_altitude,
    'estimated_season': season
}

# Example

latitude = 40.7128 # New York 
shadow_ratio = 0.5 # Shadow is half the object height 
season_info = determine_season_from_shadow(latitude, shadow_ratio) 
print(f"Season: {season_info['estimated_season']}")
````

**Shadow Color Analysis**

[Inference] Shadow color provides limited but useful clues:
- **Blue-tinted shadows**: Indicates clear sky (blue sky light fills shadow areas)
- **Warm-tinted shadows**: Overcast conditions or sunset/sunrise
- **Sharp vs soft shadow edges**: Clear vs cloudy conditions
- **Multiple overlapping shadows**: Multiple light sources (artificial lighting)

## Weather Correlation

### Weather API Integration

**Current and Historical Weather Data**

```bash
# OpenWeatherMap API (requires free API key)
# Current weather
curl "https://api.openweathermap.org/data/2.5/weather?q=London,uk&appid=YOUR_API_KEY"

# Historical weather (requires paid subscription)
curl "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=51.5074&lon=-0.1278&dt=1609459200&appid=YOUR_API_KEY"

# Weather forecast
curl "https://api.openweathermap.org/data/2.5/forecast?q=London,uk&appid=YOUR_API_KEY"
````

```python
import requests
from datetime import datetime

def get_historical_weather(lat, lon, timestamp, api_key):
    """
    Retrieve historical weather data for verification
    
    Parameters:
    - lat, lon: Location coordinates
    - timestamp: Unix timestamp or datetime object
    - api_key: OpenWeatherMap API key
    
    Returns: Weather conditions at specified time/location
    """
    
    if isinstance(timestamp, datetime):
        unix_timestamp = int(timestamp.timestamp())
    else:
        unix_timestamp = timestamp
    
    url = f"https://api.openweathermap.org/data/2.5/onecall/timemachine"
    params = {
        'lat': lat,
        'lon': lon,
        'dt': unix_timestamp,
        'appid': api_key
    }
    
    response = requests.get(url, params=params)
    
    if response.status_code == 200:
        data = response.json()
        
        if 'current' in data:
            weather = data['current']
            return {
                'temperature': weather.get('temp'),
                'humidity': weather.get('humidity'),
                'clouds': weather.get('clouds'),
                'weather': weather.get('weather', [{}])[0].get('main'),
                'description': weather.get('weather', [{}])[0].get('description'),
                'wind_speed': weather.get('wind_speed'),
                'visibility': weather.get('visibility')
            }
    
    return None

# [Unverified] Historical weather APIs may have limited accuracy for specific times
# and locations, particularly for older data or precise timestamps
```

**Visual Meteorology (VisMet) from Web Archives**

```python
def scrape_weather_from_archives(location, date):
    """
    Find historical weather reports from news archives and weather sites
    
    [Inference] Weather Underground, Weather.com archives, and local news sites
    often maintain historical weather data
    """
    
    import requests
    from bs4 import BeautifulSoup
    
    # Weather Underground historical format
    date_str = date.strftime('%Y/%m/%d')
    
    # Example sources (actual URLs vary):
    sources = [
        f"https://www.wunderground.com/history/daily/{location}/date/{date_str}",
        f"https://www.timeanddate.com/weather/{location}/historic?month={date.month}&year={date.year}"
    ]
    
    # [Unverified] Scraping may violate ToS and site structure changes frequently
    
    return None  # Placeholder - actual implementation requires site-specific parsing
```

### Visual Weather Analysis

**Sky Condition Assessment**

```python
def analyze_sky_conditions(image_path):
    """
    Analyze sky portion of image for weather indicators
    
    Indicators:
    - Cloud coverage (clear, partly cloudy, overcast)
    - Cloud types (cumulus, stratus, cirrus)
    - Sky color (blue = clear, gray = overcast, orange/red = sunrise/sunset)
    - Precipitation visibility
    """
    
    import cv2
    import numpy as np
    
    img = cv2.imread(image_path)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # Assume sky is in upper portion of image
    height = img.shape[0]
    sky_region = img[0:height//3, :]
    sky_hsv = hsv[0:height//3, :]
    
    # Analyze color distribution
    # Blue sky: H ~110-130, S >30, V >100
    blue_mask = cv2.inRange(sky_hsv, np.array([100, 30, 100]), np.array([140, 255, 255]))
    blue_percentage = (np.count_nonzero(blue_mask) / blue_mask.size) * 100
    
    # Gray sky: Low saturation
    gray_mask = cv2.inRange(sky_hsv, np.array([0, 0, 100]), np.array([180, 30, 255]))
    gray_percentage = (np.count_nonzero(gray_mask) / gray_mask.size) * 100
    
    # Determine conditions
    if blue_percentage > 60:
        conditions = "Clear sky"
    elif gray_percentage > 50:
        conditions = "Overcast"
    elif blue_percentage > 30:
        conditions = "Partly cloudy"
    else:
        conditions = "Unclear/Obstructed view"
    
    return {
        'conditions': conditions,
        'blue_sky_percentage': blue_percentage,
        'gray_sky_percentage': gray_percentage
    }

# [Inference] Automated analysis provides estimates but manual review recommended
# for accurate assessment
```

**Precipitation Indicators**

Visual indicators of precipitation:

```python
precipitation_indicators = {
    'rain': {
        'visual': [
            'Wet surfaces with reflections',
            'Rain drops visible in air',
            'Puddles on ground',
            'People with umbrellas',
            'Wet clothing/hair',
            'Rain streaks in photo'
        ],
        'indirect': [
            'Dark, heavy clouds',
            'Reduced visibility',
            'Wet pavement darker than dry areas'
        ]
    },
    'snow': {
        'visual': [
            'Snow on ground',
            'Snowflakes visible in air',
            'White accumulation on surfaces',
            'People in winter gear',
            'Vehicle snow/ice'
        ],
        'indirect': [
            'White/gray sky',
            'Reduced visibility',
            'Bare trees (if deciduous)'
        ]
    },
    'fog': {
        'visual': [
            'Reduced visibility of distant objects',
            'Hazy atmosphere',
            'Moisture droplets visible',
            'Vehicle lights in daytime'
        ],
        'indirect': [
            'Low contrast in image',
            'Lack of sharp distant features'
        ]
    }
}
```

**Vegetation and Seasonal Markers**

```python
def assess_vegetation_season(image_analysis):
    """
    Determine season from vegetation state
    
    Indicators:
    - Leaf color (green, yellow/red, none)
    - Grass state (green, brown, snow-covered)
    - Flowering plants
    - Bare branches vs foliage
    """
    
    seasonal_indicators = {
        'spring': [
            'Light green new growth',
            'Flowering trees (cherry, magnolia)',
            'Green grass emerging',
            'Mix of bare and leafing trees'
        ],
        'summer': [
            'Full dark green foliage',
            'Lush green grass',
            'Summer flowers',
            'No bare deciduous trees'
        ],
        'autumn': [
            'Yellow, orange, red leaves',
            'Mixed green and colored foliage',
            'Falling leaves',
            'Some bare branches appearing'
        ],
        'winter': [
            'Bare deciduous trees',
            'Brown/dormant grass',
            'Snow cover',
            'Evergreens prominent'
        ]
    }
    
    return seasonal_indicators

# [Inference] Vegetation indicators are most reliable in temperate climates
# Tropical and arid regions show less seasonal variation
```

### Weather-Location Correlation

**Climate Zone Verification**

```python
def verify_climate_consistency(claimed_location, observed_weather):
    """
    Check if observed weather is consistent with claimed location's climate
    
    Köppen climate classification zones:
    - Tropical (A): Hot year-round, high precipitation
    - Dry (B): Low precipitation
    - Temperate (C): Moderate temperatures, four seasons
    - Continental (D): Cold winters, warm summers
    - Polar (E): Very cold year-round
    """
    
    # Simplified climate data (would use comprehensive database in practice)
    climate_zones = {
        'tropical': {
            'temp_range': (18, 35),  # Celsius
            'snow_probability': 0,
            'regions': ['Singapore', 'Miami', 'Bangkok']
        },
        'desert': {
            'temp_range': (-10, 50),
            'humidity_max': 30,
            'regions': ['Phoenix', 'Dubai', 'Sahara']
        },
        'mediterranean': {
            'temp_range': (5, 35),
            'summer_rain_probability': 'low',
            'regions': ['Los Angeles', 'Barcelona', 'Athens']
        },
        'continental': {
            'temp_range': (-30, 35),
            'seasonal_variation': 'high',
            'regions': ['Moscow', 'Chicago', 'Beijing']
        }
    }
    
    # Check for impossible weather combinations
    inconsistencies = []
    
    if 'snow' in observed_weather and claimed_location in ['Singapore', 'Miami']:
        inconsistencies.append("Snow in tropical location (highly unlikely)")
    
    if 'temperature' in observed_weather:
        temp = observed_weather['temperature']
        # Check against location's typical range
        
    return inconsistencies

# [Inference] Climate verification narrows possibilities but doesn't definitively
# prove or disprove location due to weather variability
```

**Extreme Weather Event Correlation**

```python
def correlate_extreme_weather_events(observed_conditions, date_range, region):
    """
    Check historical records for extreme weather events
    
    Sources:
    - National Weather Service archives
    - Storm databases (hurricanes, tornadoes)
    - Flood records
    - Heat wave/cold snap records
    """
    
    # Example: Hurricane tracking
    if 'strong_winds' in observed_conditions or 'heavy_rain' in observed_conditions:
        # Check NOAA hurricane database for date/region
        # https://www.nhc.noaa.gov/data/
        pass
    
    # Example: Tornado reports
    if 'funnel_cloud' in observed_conditions:
        # Check Storm Prediction Center database
        # https://www.spc.noaa.gov/wcm/
        pass
    
    # Example: Significant snowfall
    if 'heavy_snow' in observed_conditions:
        # Check regional snow records
        pass
    
    # [Inference] Extreme weather events are well-documented and can provide
    # strong verification of time/location if matched
    
    return None  # Placeholder for actual database queries
```

### Atmospheric Optics and Phenomena

**Rainbow and Halo Analysis**

```python
def analyze_rainbow_positioning(image_data, sun_position):
    """
    Analyze rainbow position relative to sun
    
    Physics:
    - Primary rainbow: 40-42° from antisolar point
    - Sun must be behind observer
    - Rain or water droplets must be in front
    
    Can help verify:
    - Sun position (rainbow indicates sun is behind camera)
    - Time of day (sun angle)
    - Weather conditions (rain while sun visible)
    """
    
    rainbow_angle = 42  # degrees from antisolar point
    
    # If rainbow visible, sun is opposite direction from rainbow center
    # Can calculate sun azimuth from rainbow position
    
    return {
        'sun_behind_observer': True,
        'rain_present': True,
        'sun_altitude': 'below 42° (for rainbow to be visible)'
    }

# Other atmospheric phenomena:
atmospheric_phenomena = {
    'sun_dogs': {
        'description': 'Bright spots 22° left/right of sun',
        'requirements': 'Ice crystals in atmosphere',
        'indicates': 'High altitude cirrus clouds, cold weather'
    },
    'glory': {
        'description': 'Circular rainbow around shadow',
        'requirements': 'Observer shadow on cloud/fog',
        'indicates': 'Elevated position, specific weather'
    },
    'crepuscular_rays': {
        'description': 'Sun rays through clouds',
        'requirements': 'Clouds partially obscuring sun',
        'indicates': 'Sun position, can trace back to sun location'
    },
    'moon_halo': {
        'description': '22° ring around moon',
        'requirements': 'Ice crystals, typically cirrus clouds',
        'indicates': 'High altitude clouds, often before precipitation'
    }
}
```

**Lightning Analysis**

```python
def analyze_lightning_characteristics(image_with_lightning):
    """
    Lightning characteristics vary by storm type and geography
    
    Types:
    - Cloud-to-ground (CG): Vertical or angled bolts
    - Intra-cloud (IC): Horizontal flashes within clouds
    - Positive vs negative: Appearance and behavior differ
    
    [Inference] Lightning presence confirms:
    - Thunderstorm activity
    - Specific weather conditions
    - Can be cross-referenced with lightning detection networks
    """
    
    # Lightning detection networks:
    networks = {
        'NLDN': 'National Lightning Detection Network (US)',
        'WWLLN': 'World Wide Lightning Location Network (Global)',
        'ENTLN': 'Earth Networks Total Lightning Network'
    }
    
    # Lightning data can verify:
    # - Exact timestamp (microsecond precision)
    # - Location (kilometer precision)
    # - Storm intensity
    
    return {
        'storm_present': True,
        'verification_possible': 'Check lightning databases for timestamp/location'
    }
```

### Air Quality and Visibility Indicators

**Haze and Pollution Analysis**

```python
def assess_air_quality_from_image(image_path):
    """
    Analyze visibility and haze for air quality indicators
    
    Indicators:
    - Visibility distance of landmarks
    - Sky color at horizon (brown/gray = pollution)
    - Contrast reduction with distance
    - Particulate matter visible in air
    """
    
    import cv2
    import numpy as np
    
    img = cv2.imread(image_path)
    
    # Analyze horizon visibility
    # Lower portion of image typically shows horizon
    height = img.shape[0]
    horizon_region = img[height*2//3:, :]
    
    # Calculate contrast (low contrast = haze/pollution)
    gray = cv2.cvtColor(horizon_region, cv2.COLOR_BGR2GRAY)
    contrast = gray.std()
    
    # Low contrast suggests haze
    if contrast < 30:
        air_quality = "Poor visibility - haze/pollution likely"
    elif contrast < 50:
        air_quality = "Moderate visibility"
    else:
        air_quality = "Good visibility"
    
    return {
        'estimated_air_quality': air_quality,
        'contrast_value': contrast,
        'note': '[Inference] Air quality estimate based on visual analysis'
    }

# Cross-reference with air quality databases:
air_quality_sources = {
    'AirNow': 'https://www.airnow.gov/ (US)',
    'WAQI': 'https://waqi.info/ (World Air Quality Index)',
    'PurpleAir': 'https://www.purpleair.com/ (Crowdsourced sensors)'
}
```

**Smog and Regional Patterns**

```python
regional_air_quality_patterns = {
    'Los Angeles': {
        'smog_seasons': 'Summer/Fall (photochemical smog)',
        'visibility_reduction': 'Common in San Gabriel Valley',
        'characteristic': 'Brown haze, especially afternoon'
    },
    'Beijing': {
        'pollution_seasons': 'Winter (heating season)',
        'visibility': 'Can be severely reduced',
        'characteristic': 'Gray/white haze'
    },
    'Delhi': {
        'worst_months': 'November-January',
        'causes': 'Crop burning, traffic, weather patterns',
        'characteristic': 'Thick smog, very low visibility'
    },
    'London': {
        'historic': 'Famous for fog/smog (reduced modern times)',
        'current': 'Occasional fog, less pollution',
        'characteristic': 'Persistent fog in specific conditions'
    }
}

# [Inference] Severe air pollution visible in images can narrow location to
# regions with known air quality issues during specific seasons
```

### Temperature and Humidity Indicators

**Frost and Dew Analysis**

```python
def analyze_condensation_patterns(image_observations):
    """
    Frost, dew, and condensation indicate specific temperature/humidity conditions
    
    Indicators:
    - Dew on grass: Temperature dropped to dew point (typically morning)
    - Frost patterns: Temperatures below 0°C
    - Condensation on windows: Indoor/outdoor temperature differential
    - Ice formation: Sub-freezing conditions
    """
    
    condensation_indicators = {
        'dew': {
            'temperature': '> 0°C, at dew point',
            'time': 'Early morning typically',
            'humidity': 'High relative humidity',
            'season': 'Any season with temperature drop at night'
        },
        'frost': {
            'temperature': '< 0°C',
            'time': 'Overnight/early morning',
            'humidity': 'Sufficient moisture present',
            'season': 'Late fall, winter, early spring (temperate)'
        },
        'hoarfrost': {
            'temperature': 'Well below freezing',
            'conditions': 'Fog + freezing temperatures',
            'appearance': 'Feathery ice crystals',
            'distinctive': 'Specific atmospheric conditions'
        }
    }
    
    return condensation_indicators

# Temperature from clothing:
clothing_temperature_indicators = {
    'heavy_winter_coats': '< 0°C to 10°C',
    'light_jackets': '10°C to 20°C',
    'short_sleeves': '> 20°C',
    'tank_tops_shorts': '> 25°C',
    'winter_gear_hats_gloves': '< 5°C'
}

# [Inference] Clothing provides rough temperature estimates but varies by:
# - Individual tolerance
# - Cultural norms
# - Activity level
# - Acclimatization
```

**Heat Distortion and Mirage Effects**

```python
def identify_heat_effects(image_analysis):
    """
    Heat distortion visible in images indicates high temperatures
    
    Effects:
    - Heat shimmer/mirage on roads (> 30°C surface temperature)
    - Distortion of distant objects
    - Visible heat waves rising
    - Asphalt appearing wet (inferior mirage)
    """
    
    heat_indicators = {
        'road_mirage': {
            'temperature': 'Surface temp > 30°C, air temp typically > 25°C',
            'conditions': 'Hot day, paved surface, low viewing angle',
            'regions': 'Common in hot climates, summer'
        },
        'heat_shimmer': {
            'temperature': 'Hot conditions',
            'visible': 'Distortion of distant objects',
            'photography': 'Reduces image sharpness at distance'
        }
    }
    
    return heat_indicators

# [Inference] Heat effects confirm hot weather conditions but exact temperature
# requires additional data
```

## Integrated Geolocation Workflow

### Multi-Factor Analysis Process

```python
class GeolocationAnalysis:
    """
    Comprehensive geolocation analysis combining multiple techniques
    """
    
    def __init__(self, image_path, metadata=None):
        self.image_path = image_path
        self.metadata = metadata or {}
        self.findings = {}
    
    def analyze_all(self):
        """
        Run all analysis methods and compile results
        """
        
        # 1. Extract and analyze metadata
        self.findings['metadata'] = self.analyze_metadata()
        
        # 2. Timezone analysis
        if 'timestamps' in self.metadata:
            self.findings['timezone'] = self.analyze_timezone(
                self.metadata['timestamps']
            )
        
        # 3. Language and signage
        self.findings['language'] = self.extract_text_clues()
        
        # 4. Shadow analysis
        self.findings['shadows'] = self.analyze_shadows()
        
        # 5. Weather correlation
        self.findings['weather'] = self.analyze_weather()
        
        # 6. Compile and cross-reference
        self.findings['conclusion'] = self.synthesize_findings()
        
        return self.findings
    
    def analyze_metadata(self):
        """Extract EXIF and metadata clues"""
        # Implementation using exiftool
        return {}
    
    def analyze_timezone(self, timestamps):
        """Analyze temporal patterns"""
        # Implementation as shown earlier
        return {}
    
    def extract_text_clues(self):
        """OCR and language detection"""
        # Implementation using Tesseract + langdetect
        return {}
    
    def analyze_shadows(self):
        """Shadow direction and length analysis"""
        # Implementation as shown earlier
        return {}
    
    def analyze_weather(self):
        """Weather condition assessment"""
        # Implementation combining visual and API data
        return {}
    
    def synthesize_findings(self):
        """
        Cross-reference all findings to determine most likely location
        
        Confidence scoring:
        - High: Multiple independent indicators agree
        - Medium: Some indicators agree, no contradictions
        - Low: Few indicators or contradictions present
        """
        
        conclusions = {
            'probable_locations': [],
            'probable_timeframe': None,
            'confidence_level': None,
            'contradictions': [],
            'supporting_evidence': []
        }
        
        # Check for contradictions
        # Example: Tropical vegetation but snow present
        
        # Score location candidates
        # Weight different evidence types
        
        # Identify strongest indicators
        
        return conclusions

# Example usage
analysis = GeolocationAnalysis('target_image.jpg', metadata={'timestamps': [...]})
results = analysis.analyze_all()
print(f"Probable location: {results['conclusion']['probable_locations']}")
print(f"Confidence: {results['conclusion']['confidence_level']}")
```

### Confidence Scoring System

```python
def calculate_geolocation_confidence(evidence_dict):
    """
    Assign confidence scores based on evidence quality and consistency
    
    Evidence types and weights:
    - GPS coordinates (if available): 100% (if verified authentic)
    - Multiple consistent indicators: 80-95%
    - Single strong indicator: 60-80%
    - Weak or contradictory indicators: < 60%
    """
    
    confidence_weights = {
        'gps_exif': 100,  # If present and verified
        'known_landmark': 95,  # Unique identifiable landmark
        'license_plate': 90,  # Clear, specific region
        'business_signage': 85,  # Regional chain with limited locations
        'multiple_language_clues': 80,
        'shadow_analysis_verified': 75,
        'weather_match': 70,
        'architectural_style': 60,
        'vegetation_indicators': 55,
        'general_signage': 50
    }
    
    total_weight = 0
    max_possible = 0
    
    for evidence_type, present in evidence_dict.items():
        if present and evidence_type in confidence_weights:
            weight = confidence_weights[evidence_type]
            total_weight += weight
            max_possible += 100
    
    if max_possible == 0:
        return 0
    
    # Confidence is weighted average
    confidence = (total_weight / max_possible) * 100
    
    # Apply penalty for contradictions
    if 'contradictions' in evidence_dict:
        contradiction_count = len(evidence_dict['contradictions'])
        confidence -= (contradiction_count * 15)  # -15% per contradiction
    
    # Cap at 0-100%
    confidence = max(0, min(100, confidence))
    
    # Classify confidence level
    if confidence >= 85:
        level = "Very High"
    elif confidence >= 70:
        level = "High"
    elif confidence >= 50:
        level = "Medium"
    elif confidence >= 30:
        level = "Low"
    else:
        level = "Very Low"
    
    return {
        'confidence_percentage': confidence,
        'confidence_level': level
    }

# Example
evidence = {
    'known_landmark': True,
    'license_plate': True,
    'weather_match': True,
    'shadow_analysis_verified': True,
    'contradictions': []
}

confidence = calculate_geolocation_confidence(evidence)
print(f"Confidence: {confidence['confidence_level']} ({confidence['confidence_percentage']:.1f}%)")
```

### Verification and Validation

**Ground Truth Comparison**

```python
def verify_against_ground_truth(estimated_location, estimated_time, ground_truth):
    """
    Compare estimated location/time with known ground truth
    
    Used for:
    - Training and calibrating analysis methods
    - Testing accuracy of techniques
    - Identifying systematic errors
    """
    
    import math
    
    def haversine_distance(lat1, lon1, lat2, lon2):
        """Calculate distance between two points on Earth"""
        R = 6371  # Earth radius in kilometers
        
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        
        a = (math.sin(dlat/2)**2 + 
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
             math.sin(dlon/2)**2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c
    
    # Calculate location error
    if estimated_location and ground_truth.get('location'):
        est_lat, est_lon = estimated_location
        true_lat, true_lon = ground_truth['location']
        
        distance_error = haversine_distance(est_lat, est_lon, true_lat, true_lon)
        
        location_accuracy = {
            'distance_error_km': distance_error,
            'accuracy_rating': (
                'Excellent' if distance_error < 1 else
                'Good' if distance_error < 10 else
                'Fair' if distance_error < 100 else
                'Poor'
            )
        }
    else:
        location_accuracy = None
    
    # Calculate time error
    if estimated_time and ground_truth.get('time'):
        from datetime import timedelta
        
        time_diff = abs((estimated_time - ground_truth['time']).total_seconds())
        hours_diff = time_diff / 3600
        
        time_accuracy = {
            'time_error_hours': hours_diff,
            'accuracy_rating': (
                'Excellent' if hours_diff < 1 else
                'Good' if hours_diff < 6 else
                'Fair' if hours_diff < 24 else
                'Poor'
            )
        }
    else:
        time_accuracy = None
    
    return {
        'location_accuracy': location_accuracy,
        'time_accuracy': time_accuracy
    }
```

## Tools and Resources

### Recommended Geolocation Tools

```bash
# SunCalc - Sun position calculator
# Web: suncalc.org
# API: github.com/mourner/suncalc

# GeoGuessr - Training tool for visual geolocation
# Web: geoguessr.com
# Helps develop intuition for geographic indicators

# Google Earth Pro
# Desktop application for detailed satellite imagery analysis
# Free download: earth.google.com

# Sentinel Hub EO Browser
# Satellite imagery with multiple sensors
# Web: apps.sentinel-hub.com/eo-browser

# Overpass Turbo
# Query OpenStreetMap data
# Web: overpass-turbo.eu
# Find specific features, buildings, landmarks
```

### Python Libraries for Geolocation

```bash
# Install comprehensive geolocation toolkit
pip install pysolar
pip install pytz
pip install geopy
pip install opencv-python
pip install pillow
pip install exiftool
pip install pytesseract
pip install langdetect
pip install phonenumbers
pip install requests

# Specialized libraries
pip install skyfield  # Astronomical calculations
pip install ephem  # Astronomical ephemeris calculations
pip install meteostat  # Historical weather data
```

### Online Resources and Databases

```python
geolocation_resources = {
    'satellite_imagery': {
        'Google Earth': 'earth.google.com',
        'Bing Maps': 'bing.com/maps',
        'Sentinel Hub': 'sentinel-hub.com',
        'Planet': 'planet.com (commercial)',
        'Maxar': 'maxar.com (commercial)'
    },
    
    'street_view': {
        'Google Street View': 'google.com/maps',
        'Mapillary': 'mapillary.com (crowdsourced)',
        'KartaView': 'kartaview.org (crowdsourced)',
        'Bing Streetside': 'bing.com/maps'
    },
    
    'weather_historical': {
        'Weather Underground': 'wunderground.com/history',
        'Time and Date': 'timeanddate.com/weather',
        'Visual Crossing': 'visualcrossing.com',
        'Meteostat': 'meteostat.net'
    },
    
    'astronomical': {
        'SunCalc': 'suncalc.org',
        'TimeAndDate Sun Calculator': 'timeanddate.com/sun',
        'NOAA Solar Calculator': 'esrl.noaa.gov/gmd/grad/solcalc'
    },
    
    'osint_maps': {
        'OpenStreetMap': 'openstreetmap.org',
        'Wikimapia': 'wikimapia.org',
        'Dual Maps': 'data.mashedworld.com/dualmaps'
    }
}
```

## Case Study: Complete Geolocation Example

```python
def complete_geolocation_example():
    """
    Walkthrough of comprehensive geolocation analysis
    
    Scenario: Image found online, need to determine location and time
    
    Available information:
    - Image file with some metadata
    - Person in photo casting shadow
    - Visible signage in background
    - Weather conditions visible
    - Social media post timestamp (may be manipulated)
    """
    
    # Step 1: Extract all available metadata
    print("=== STEP 1: METADATA EXTRACTION ===")
	metadata_findings = {
	    'camera': 'iPhone 12 Pro',
	    'exif_timestamp': '2024:03:15 14:32:18',
	    'gps_coordinates': None,
	    # Stripped
	    'timezone_offset': '+08:00',
	    'software': 'Instagram (edited)'
	}

print(f"Camera: {metadata_findings['camera']}")
print(f"Timestamp: {metadata_findings['exif_timestamp']}")
print(f"Timezone offset: {metadata_findings['timezone_offset']}")
print("Note: GPS data removed, photo edited")

# Step 2: Timezone analysis
print("\n=== STEP 2: TIMEZONE ANALYSIS ===")
# Timestamp shows +08:00 offset
# Possible locations: China, Singapore, Malaysia, Philippines, Western Australia, Taiwan
tz_candidates = ['Asia/Shanghai', 'Asia/Singapore', 'Asia/Manila', 
                 'Asia/Kuala_Lumpur', 'Asia/Taipei', 'Australia/Perth']
print(f"Timezone +08:00 candidates: {tz_candidates}")

# Step 3: Language and signage analysis
print("\n=== STEP 3: LANGUAGE ANALYSIS ===")
ocr_results = {
    'primary_language': 'English',
    'secondary_language': 'Chinese (Traditional)',
    'signage_text': [
        '7-Eleven',
        '便利商店',  # Convenience store in Traditional Chinese
        'Exit 出口'
    ],
    'license_plates_visible': False
}
print(f"Languages detected: {ocr_results['primary_language']}, {ocr_results['secondary_language']}")
print(f"Traditional Chinese suggests: Taiwan, Hong Kong, or Macau")
print(f"Narrows timezone candidates to: Taiwan, Hong Kong")

# Step 4: Shadow analysis
print("\n=== STEP 4: SHADOW ANALYSIS ===")
shadow_data = {
    'person_height_estimate': 1.75,  # meters
    'shadow_length_estimate': 1.20,  # meters
    'shadow_direction': 'Northeast (approximately 45° from north)',
    'shadow_quality': 'Sharp edges - clear weather'
}

# Calculate sun altitude
import math
sun_altitude = math.degrees(math.atan(
    shadow_data['person_height_estimate'] / shadow_data['shadow_length_estimate']
))
print(f"Calculated sun altitude: {sun_altitude:.1f}°")
print(f"Shadow direction: {shadow_data['shadow_direction']}")

# Verify sun position for candidate locations
from datetime import datetime
import pytz
from pysolar.solar import get_altitude, get_azimuth

# Test timestamp: 2024-03-15 14:32:18 +08:00
test_time = datetime(2024, 3, 15, 14, 32, 18, tzinfo=pytz.timezone('Asia/Taipei'))
test_time_utc = test_time.astimezone(pytz.utc)

candidates = {
    'Taipei': (25.0330, 121.5654),
    'Hong Kong': (22.3193, 114.1694)
}

print("\nSun position verification:")
for city, coords in candidates.items():
    altitude = get_altitude(coords[0], coords[1], test_time_utc)
    azimuth = get_azimuth(coords[0], coords[1], test_time_utc)
    shadow_azimuth = (azimuth + 180) % 360
    
    print(f"\n{city}:")
    print(f"  Sun altitude: {altitude:.1f}° (observed: {sun_altitude:.1f}°)")
    print(f"  Shadow direction: {shadow_azimuth:.1f}° from N")
    
    # Check match
    altitude_match = abs(altitude - sun_altitude) < 5
    azimuth_match = abs(shadow_azimuth - 45) < 20  # Observed ~45° from N
    
    if altitude_match and azimuth_match:
        print(f"  ✓ MATCH: Shadow analysis consistent")
    else:
        print(f"  ✗ NO MATCH: Shadow analysis inconsistent")

# Step 5: Weather correlation
print("\n=== STEP 5: WEATHER ANALYSIS ===")
visual_weather = {
    'sky_condition': 'Clear blue sky',
    'clouds': 'Few scattered clouds',
    'precipitation': 'None visible',
    'visibility': 'Excellent',
    'estimated_temperature': '22-28°C (based on clothing - short sleeves)',
    'humidity_indicators': 'No visible haze'
}
print(f"Sky: {visual_weather['sky_condition']}")
print(f"Temperature estimate: {visual_weather['estimated_temperature']}")
print(f"Visibility: {visual_weather['visibility']}")

# Check historical weather (pseudo-code - would use actual API)
print("\nHistorical weather verification:")
historical_weather = {
    'Taipei_2024_03_15': {
        'temp_high': 24,
        'temp_low': 18,
        'conditions': 'Partly Cloudy',
        'precipitation': 0
    },
    'Hong_Kong_2024_03_15': {
        'temp_high': 23,
        'temp_low': 19,
        'conditions': 'Partly Cloudy',
        'precipitation': 0
    }
}

for location, weather in historical_weather.items():
    print(f"{location}: {weather['conditions']}, {weather['temp_high']}°C")
    print(f"  Match with observed conditions: ✓")

# Step 6: Additional visual clues
print("\n=== STEP 6: ADDITIONAL VISUAL CLUES ===")
visual_clues = {
    'architecture': 'Modern urban, mixed high-rise and low-rise buildings',
    'street_furniture': 'Modern style, clean infrastructure',
    'vegetation': 'Subtropical plants, green and healthy',
    'traffic_direction': 'Not clearly visible',
    'power_lines': 'Mix of overhead and underground',
    'building_density': 'High density urban area'
}

for clue_type, observation in visual_clues.items():
    print(f"{clue_type}: {observation}")

# Additional specific indicators
print("\nKey discriminating factors:")
print("- 7-Eleven signage style: Both cities have 7-Eleven")
print("- Traditional Chinese characters: Both use Traditional")
print("- Climate in March: Both similar (subtropical)")

# Look for subtle differences
specific_indicators = {
    'street_sign_style': 'Green background, white text - common in both',
    'building_architecture': 'Could match either location',
    'background_mountains': 'Visible in distance - SIGNIFICANT'
}

print("\n! CRITICAL FINDING: Mountains visible in background")
print("  Taipei: Surrounded by mountains on multiple sides")
print("  Hong Kong: Also mountainous terrain")
print("  Need to analyze mountain profile...")

# Step 7: Synthesis and conclusion
print("\n=== STEP 7: SYNTHESIS ===")

evidence_summary = {
    'timezone': {
        'finding': '+08:00',
        'narrows_to': ['Taiwan', 'Hong Kong', 'Macau', 'parts of China'],
        'confidence': 'High'
    },
    'language': {
        'finding': 'Traditional Chinese + English',
        'narrows_to': ['Taiwan', 'Hong Kong', 'Macau'],
        'confidence': 'High'
    },
    'shadow_analysis': {
        'finding': f'{sun_altitude:.1f}° altitude, NE direction',
        'matches': ['Taipei', 'Hong Kong'],
        'confidence': 'Medium (both locations match)'
    },
    'weather': {
        'finding': 'Clear, 22-28°C',
        'matches': ['Both locations for date'],
        'confidence': 'Medium (weather similar)'
    },
    'timestamp': {
        'finding': '2024-03-15 14:32:18',
        'verified': 'Consistent with shadow analysis',
        'confidence': 'High'
    }
}

print("\nEvidence Summary:")
for category, details in evidence_summary.items():
    print(f"\n{category.upper()}:")
    for key, value in details.items():
        print(f"  {key}: {value}")

# Final determination
print("\n=== FINAL ASSESSMENT ===")

final_conclusion = {
    'most_likely_location': 'Taipei or Hong Kong (unable to definitively distinguish)',
    'confidence_level': 'Medium-High (70-75%)',
    'timestamp': '2024-03-15 14:30-14:35 local time (+08:00)',
    'timestamp_confidence': 'High (85%)',
    'limiting_factors': [
        'No GPS data in EXIF',
        'Both candidate cities share many characteristics',
        'Need additional discriminating features'
    ],
    'recommendations': [
        'Reverse image search to find original posting',
        'Analyze mountain profile against known topography',
        'Check for business names visible in background',
        'Look for vehicle details (Taiwan vs HK license plates)',
        'Search for unique architectural features'
    ]
}

print(f"Location: {final_conclusion['most_likely_location']}")
print(f"Confidence: {final_conclusion['confidence_level']}")
print(f"Timestamp: {final_conclusion['timestamp']}")
print(f"Timestamp confidence: {final_conclusion['timestamp_confidence']}")

print("\nLimiting factors:")
for factor in final_conclusion['limiting_factors']:
    print(f"  - {factor}")

print("\nNext steps for definitive identification:")
for i, rec in enumerate(final_conclusion['recommendations'], 1):
    print(f"  {i}. {rec}")

return final_conclusion

# [Inference] This example demonstrates that even with multiple analysis techniques,

# definitive geolocation may not always be possible without additional data.

# Confidence levels should reflect the quality and consistency of available evidence.
````

## Advanced Techniques

### Astronomical Phenomena for Precise Timing

```python
def analyze_moon_position(image_analysis, date_estimate):
    """
    Moon position can verify both location and timestamp
    
    Moon characteristics:
    - Phase visible (new, crescent, full, etc.)
    - Position in sky
    - Orientation of crescent
    
    [Inference] Moon phase is same worldwide on given date, but position
    in sky varies by location and time
    """
    
    import ephem
    
    # Create observer
    observer = ephem.Observer()
    observer.lat = '25.0330'  # Example: Taipei
    observer.lon = '121.5654'
    observer.date = date_estimate
    
    # Calculate moon position
    moon = ephem.Moon()
    moon.compute(observer)
    
    moon_data = {
        'altitude': float(moon.alt) * 180 / 3.14159,  # Convert to degrees
        'azimuth': float(moon.az) * 180 / 3.14159,
        'phase': moon.phase,  # Percentage illuminated
        'rising_time': observer.next_rising(moon),
        'setting_time': observer.next_setting(moon)
    }
    
    return moon_data

# Star trails for long exposures
def analyze_star_trails(image_with_stars):
    """
    Star trail direction and curvature indicate hemisphere and latitude
    
    Northern Hemisphere: Stars rotate around Polaris (counter-clockwise)
    Southern Hemisphere: Stars rotate around south celestial pole (clockwise)
    
    Equator: Star trails are nearly straight vertical lines
    
    [Inference] Star trail curvature increases with distance from equator
    """
    
    trail_indicators = {
        'circular_northern': 'Northern hemisphere, can estimate latitude from curvature',
        'circular_southern': 'Southern hemisphere, can estimate latitude from curvature',
        'nearly_straight': 'Near equator (within 10-15° latitude)',
        'polaris_visible': 'Northern hemisphere, altitude of Polaris ≈ latitude'
    }
    
    return trail_indicators
````

### Crowd-Sourced Verification

```python
def leverage_community_identification():
    """
    Communities specialized in geolocation can assist with difficult cases
    
    Resources:
    - Reddit: r/whereisthis, r/geoguessing
    - Twitter: #geolocation community
    - Bellingcat Discord: Open source investigation community
    - GeoGuessr community
    
    [Unverified] Crowd-sourced identification should be verified independently
    Local knowledge can identify subtle location-specific features
    """
    
    communities = {
        'reddit_whereisthis': {
            'url': 'reddit.com/r/whereisthis',
            'focus': 'General location identification',
            'response_time': 'Hours to days',
            'expertise': 'Varied, strong for well-known locations'
        },
        'reddit_geoguessing': {
            'url': 'reddit.com/r/geoguessing',
            'focus': 'Challenge-based geolocation',
            'response_time': 'Hours to days',
            'expertise': 'High for visual geolocation'
        },
        'bellingcat': {
            'url': 'bellingcat.com',
            'focus': 'Open source investigation',
            'response_time': 'Varies',
            'expertise': 'Very high for conflict zones and news events'
        },
        'twitter_osint': {
            'hashtags': ['#geolocation', '#OSINT', '#GEOINT'],
            'focus': 'Real-time event verification',
            'response_time': 'Minutes to hours for active events',
            'expertise': 'Professional and enthusiast investigators'
        }
    }
    
    return communities
```

### Metadata Forensics

```python
def advanced_metadata_analysis(file_path):
    """
    Deep metadata analysis for authenticity verification
    
    Checks:
    - Editing history
    - Software signatures
    - Thumbnail mismatches
    - Timestamp inconsistencies
    """
    
    import subprocess
    import json
    
    # Extract all metadata including internal structures
    cmd = ['exiftool', '-a', '-G1', '-j', file_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        metadata = json.loads(result.stdout)[0]
        
        # Check for editing indicators
        editing_indicators = {
            'software_used': metadata.get('EXIF:Software', 'Unknown'),
            'modify_date': metadata.get('EXIF:ModifyDate'),
            'create_date': metadata.get('EXIF:CreateDate'),
            'datetime_original': metadata.get('EXIF:DateTimeOriginal'),
            'thumbnail_present': 'EXIF:ThumbnailImage' in metadata,
            'color_space': metadata.get('EXIF:ColorSpace'),
            'compression': metadata.get('EXIF:Compression')
        }
        
        # Detect potential manipulation
        manipulation_flags = []
        
        if editing_indicators['modify_date'] != editing_indicators['datetime_original']:
            manipulation_flags.append("Modification date differs from original")
        
        if 'Photoshop' in editing_indicators.get('software_used', ''):
            manipulation_flags.append("Edited with Photoshop")
        
        if 'Instagram' in editing_indicators.get('software_used', ''):
            manipulation_flags.append("Processed by Instagram (EXIF data may be stripped/altered)")
        
        # Check thumbnail-image consistency
        if editing_indicators['thumbnail_present']:
            # Extract and compare (advanced technique)
            manipulation_flags.append("Check thumbnail-image consistency manually")
        
        return {
            'metadata': editing_indicators,
            'manipulation_indicators': manipulation_flags,
            'authenticity_assessment': 'Low' if len(manipulation_flags) > 2 else 'Medium' if manipulation_flags else 'High'
        }
    
    return None

# Error Level Analysis (ELA) for image forensics
def error_level_analysis(image_path):
    """
    ELA highlights areas of different compression levels
    Can indicate edited regions
    
    [Unverified] ELA is not definitive proof of manipulation
    High compression images show less distinct ELA patterns
    """
    
    from PIL import Image
    import numpy as np
    
    # Open original image
    img = Image.open(image_path)
    
    # Save at known quality level
    temp_path = 'temp_ela.jpg'
    img.save(temp_path, 'JPEG', quality=95)
    
    # Reload compressed version
    compressed = Image.open(temp_path)
    
    # Calculate difference
    original_array = np.array(img)
    compressed_array = np.array(compressed)
    
    # Error level = absolute difference
    ela = np.abs(original_array.astype(int) - compressed_array.astype(int))
    
    # Amplify for visibility
    ela = (ela * 10).clip(0, 255).astype(np.uint8)
    
    # Convert back to image
    ela_image = Image.fromarray(ela)
    
    return ela_image

# [Inference] Metadata forensics helps assess image authenticity but sophisticated
# manipulation can preserve or forge metadata
```

## Operational Security and Ethics

### Privacy Considerations

```python
ethical_guidelines = {
    'principle_1': {
        'guideline': 'Minimize collection of personal information',
        'application': 'Only geolocate when necessary for legitimate purposes',
        'rationale': 'Respect individual privacy rights'
    },
    'principle_2': {
        'guideline': 'Consider harm potential',
        'application': 'Assess whether geolocation could endanger individuals',
        'rationale': 'Avoid enabling harassment, stalking, or targeting'
    },
    'principle_3': {
        'guideline': 'Respect consent and context',
        'application': 'Consider original context of shared information',
        'rationale': 'Information shared in limited context should not be weaponized'
    },
    'principle_4': {
        'guideline': 'Secure handling of findings',
        'application': 'Protect geolocation results from unauthorized access',
        'rationale': 'Prevent misuse of derived intelligence'
    },
    'principle_5': {
        'guideline': 'Document methodology',
        'application': 'Maintain audit trail of analysis methods',
        'rationale': 'Enable review and verification of findings'
    }
}

# [Unverified] Legal requirements vary by jurisdiction
# Always consult applicable laws and organizational policies
```

### Responsible Disclosure

```python
disclosure_framework = {
    'vulnerability_identified': {
        'action': 'If geolocation reveals security vulnerability',
        'steps': [
            'Document finding without further exploitation',
            'Notify affected party through appropriate channels',
            'Allow reasonable time for remediation',
            'Consider public disclosure only after remediation or if public safety requires'
        ]
    },
    'criminal_activity': {
        'action': 'If geolocation reveals apparent criminal activity',
        'steps': [
            'Preserve evidence without tampering',
            'Report to appropriate law enforcement',
            'Do not conduct independent investigation beyond initial discovery',
            'Maintain chain of custody documentation'
        ]
    },
    'research_purposes': {
        'action': 'If conducting geolocation research',
        'steps': [
            'Obtain ethical review/approval if applicable',
            'Anonymize case studies',
            'Obtain consent when possible',
            'Publish methodology to advance field knowledge'
        ]
    }
}
```

## Summary

Geolocation techniques combine multiple analytical approaches:

1. **Timezone Analysis**: Temporal patterns, metadata timestamps, activity schedules
2. **Language and Signage**: OCR, language detection, regional indicators
3. **Shadow Analysis**: Solar position calculation, geometric analysis, temporal verification
4. **Weather Correlation**: Visual assessment, historical data, atmospheric phenomena

**Key Principles:**

- Multiple independent indicators increase confidence
- Cross-reference findings for consistency
- Document methodology and confidence levels
- Consider alternative explanations
- Respect privacy and ethical boundaries

**Confidence Assessment:**

- Label inferences and unverified claims
- Assign confidence scores based on evidence quality
- Identify contradictions and limitations
- Recommend additional verification steps

[Inference] Geolocation is rarely absolute - most analyses produce probable locations with varying confidence levels rather than definitive proof.

---

# Document Intelligence

## Document Metadata Analysis

### Comprehensive Metadata Extraction

Document metadata embeds authorship, creation timestamps, revision history, and system information critical for attribution and dating.

**ExifTool for Multi-Format Documents**

```bash
# Extract all metadata from document
exiftool document.pdf

# Extract specific metadata tags
exiftool -Author -Creator -Producer -Title document.pdf

# Export metadata to JSON
exiftool -json document.pdf > metadata.json

# Extract creation/modification timestamps
exiftool -CreateDate -ModifyDate -MetadataDate document.pdf

# Batch extract from directory
exiftool -r -csv /path/to/documents/ > all_metadata.csv

# Extract only specific fields
exiftool -a -G1 -s document.pdf | grep -i "author\|creator\|producer\|date"
```

**Python-Based Metadata Extraction**

```bash
pip install PyPDF2 python-docx openpyxl pillow

python3 << 'EOF'
from PyPDF2 import PdfReader
from docx import Document
from openpyxl import load_workbook
import json
from datetime import datetime

def extract_pdf_metadata(pdf_path):
    """Extract comprehensive PDF metadata"""
    pdf = PdfReader(pdf_path)
    
    metadata = {
        'document_type': 'PDF',
        'pages': len(pdf.pages),
        'info': pdf.metadata if pdf.metadata else {}
    }
    
    # Parse metadata dictionary
    if pdf.metadata:
        for key, value in pdf.metadata.items():
            # Remove leading slash from PDF metadata keys
            clean_key = key.lstrip('/')
            
            # Attempt to parse dates
            if isinstance(value, bytes):
                try:
                    value = value.decode('utf-8', errors='ignore')
                except:
                    value = str(value)
            
            metadata['info'][clean_key] = value
    
    return metadata

def extract_docx_metadata(docx_path):
    """Extract DOCX (Microsoft Word) metadata"""
    doc = Document(docx_path)
    
    properties = doc.core_properties
    
    metadata = {
        'document_type': 'DOCX',
        'title': properties.title,
        'author': properties.author,
        'subject': properties.subject,
        'created': str(properties.created),
        'modified': str(properties.modified),
        'last_modified_by': properties.last_modified_by,
        'revision_count': properties.revision,
        'paragraphs': len(doc.paragraphs),
        'tables': len(doc.tables)
    }
    
    # Extract revision history metadata
    revision_metadata = []
    for element in doc.element.body:
        if element.tag.endswith('trackChange'):
            revision_metadata.append(element.attrib)
    
    metadata['revisions'] = revision_metadata
    
    return metadata

def extract_xlsx_metadata(xlsx_path):
    """Extract XLSX (Microsoft Excel) metadata"""
    wb = load_workbook(xlsx_path)
    
    properties = wb.properties
    
    metadata = {
        'document_type': 'XLSX',
        'title': properties.title,
        'author': properties.author,
        'subject': properties.subject,
        'created': str(properties.created),
        'modified': str(properties.modified),
        'sheets': len(wb.sheetnames),
        'sheet_names': wb.sheetnames
    }
    
    return metadata

# Example usage
pdf_meta = extract_pdf_metadata('document.pdf')
docx_meta = extract_docx_metadata('document.docx')
xlsx_meta = extract_xlsx_metadata('document.xlsx')

print("[+] PDF Metadata:")
print(json.dumps(pdf_meta, indent=2, default=str))

print("\n[+] DOCX Metadata:")
print(json.dumps(docx_meta, indent=2, default=str))

print("\n[+] XLSX Metadata:")
print(json.dumps(xlsx_meta, indent=2, default=str))
EOF
```

### Embedded System Information

Document metadata often encodes system information revealing document creation environment.

```bash
python3 << 'EOF'
import json
from PyPDF2 import PdfReader

def extract_producer_info(pdf_path):
    """Extract document producer and software version"""
    pdf = PdfReader(pdf_path)
    
    if not pdf.metadata:
        return None
    
    producer = pdf.metadata.get('/Producer')
    creator = pdf.metadata.get('/Creator')
    
    # Parse producer string for software version
    producer_info = {
        'producer': producer,
        'creator': creator,
        'extracted_software': None,
        'version': None
    }
    
    if producer:
        producer_str = producer if isinstance(producer, str) else str(producer)
        
        # Common software signatures
        software_patterns = {
            'Microsoft Word': r'Word|Microsoft Office',
            'Adobe': r'Adobe|Acrobat',
            'LibreOffice': r'LibreOffice|OpenOffice',
            'Google Docs': r'Google',
            'Apple Pages': r'Pages|macOS',
            'LaTeX': r'pdfTeX|LaTeX|pdftex'
        }
        
        for software, pattern in software_patterns.items():
            import re
            if re.search(pattern, producer_str, re.IGNORECASE):
                producer_info['extracted_software'] = software
                
                # Extract version if present
                version_match = re.search(r'(\d+\.\d+\.*\d*)', producer_str)
                if version_match:
                    producer_info['version'] = version_match.group(1)
                break
    
    return producer_info

# Example
producer = extract_producer_info('document.pdf')
print("[+] Producer Information:")
print(json.dumps(producer, indent=2))

# [Inference] Software version from PDF producer may indicate document age
# Older versions (Word 97-2003, Adobe 6.0) suggest older documents
# However, producer strings can be manually edited
EOF
```

### Timestamp Analysis

Creation and modification timestamps reveal document timeline and potential manipulation.

```bash
python3 << 'EOF'
from datetime import datetime
import json

def analyze_timestamp_consistency(metadata_dict):
    """Check for timestamp inconsistencies indicating manipulation"""
    
    issues = {
        'timestamp_order': [],
        'impossible_dates': [],
        'suspicious_patterns': [],
        'metadata_mismatch': []
    }
    
    timestamps = {
        'created': metadata_dict.get('created'),
        'modified': metadata_dict.get('modified'),
        'accessed': metadata_dict.get('accessed'),
        'metadata_date': metadata_dict.get('metadata_date')
    }
    
    # Clean up timestamps
    clean_ts = {}
    for ts_type, ts_value in timestamps.items():
        if ts_value:
            try:
                if isinstance(ts_value, str):
                    # Handle various date formats
                    for fmt in ['%Y:%m:%d %H:%M:%S', '%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S']:
                        try:
                            clean_ts[ts_type] = datetime.strptime(ts_value[:19], fmt)
                            break
                        except:
                            continue
            except:
                pass
    
    # Check timestamp order (created should be before modified)
    if 'created' in clean_ts and 'modified' in clean_ts:
        if clean_ts['created'] > clean_ts['modified']:
            issues['timestamp_order'].append({
                'issue': 'Created date after modified date',
                'created': str(clean_ts['created']),
                'modified': str(clean_ts['modified'])
            })
    
    # Check for impossible future dates
    now = datetime.now()
    for ts_type, ts_date in clean_ts.items():
        if ts_date > now:
            issues['impossible_dates'].append({
                'timestamp_type': ts_type,
                'date': str(ts_date),
                'issue': 'Future date detected'
            })
    
    # Check for suspicious patterns (e.g., all timestamps identical)
    unique_timestamps = set(str(ts) for ts in clean_ts.values())
    if len(unique_timestamps) == 1:
        issues['suspicious_patterns'].append({
            'issue': 'All timestamps identical',
            'timestamp': str(list(clean_ts.values())[0])
        })
    
    return clean_ts, issues

# Example
metadata = {
    'created': '2024-01-15 10:30:45',
    'modified': '2024-01-15 10:30:45',
    'accessed': '2024-01-20 14:22:10'
}

timestamps, issues = analyze_timestamp_consistency(metadata)
print("[+] Timestamp Analysis:")
print(json.dumps({'timestamps': {k: str(v) for k, v in timestamps.items()}, 'issues': issues}, indent=2))
EOF
```

---

## PDF Forensics

### PDF Structure Analysis

PDFs contain layers of objects, streams, and encryption that reveal document modification history and embedded content.

```bash
pip install PyPDF2 pdfplumber

python3 << 'EOF'
from PyPDF2 import PdfReader
import json

def analyze_pdf_structure(pdf_path):
    """Analyze internal PDF structure"""
    pdf = PdfReader(pdf_path)
    
    analysis = {
        'total_pages': len(pdf.pages),
        'is_encrypted': pdf.is_encrypted,
        'metadata': dict(pdf.metadata) if pdf.metadata else {},
        'page_info': []
    }
    
    # Analyze each page
    for page_num, page in enumerate(pdf.pages):
        page_info = {
            'page': page_num + 1,
            'size': {
                'width': float(page.mediabox.width),
                'height': float(page.mediabox.height)
            },
            'rotation': page.get('/Rotate', 0),
            'resources': list(page.get('/Resources', {}).keys()) if page.get('/Resources') else [],
            'content_streams': len(page['/Contents']) if '/Contents' in page else 0
        }
        analysis['page_info'].append(page_info)
    
    return analysis

def extract_pdf_objects(pdf_path):
    """Extract all PDF objects for detailed analysis"""
    pdf = PdfReader(pdf_path)
    
    objects = {
        'total_objects': len(pdf.pages),
        'object_types': {},
        'stream_objects': []
    }
    
    for obj_num, page in enumerate(pdf.pages):
        obj_type = page.get('/Type')
        if obj_type not in objects['object_types']:
            objects['object_types'][str(obj_type)] = 0
        objects['object_types'][str(obj_type)] += 1
    
    return objects

# Example
structure = analyze_pdf_structure('document.pdf')
print("[+] PDF Structure Analysis:")
print(json.dumps(structure, indent=2, default=str))
EOF
```

### PDF Revision History Detection

PDFs support incremental updates, allowing multiple versions to coexist. Analyzing incremental updates reveals modification history.

```bash
python3 << 'EOF'
from PyPDF2 import PdfReader
import re

def detect_pdf_revisions(pdf_path):
    """Detect multiple PDF revisions and update history"""
    
    with open(pdf_path, 'rb') as f:
        pdf_content = f.read()
    
    # Look for PDF version indicators and xref entries
    revisions = []
    
    # Count EOF markers (each indicates potential revision)
    eof_positions = [m.start() for m in re.finditer(b'%%EOF', pdf_content)]
    
    revision_info = {
        'total_revisions': len(eof_positions),
        'revision_positions': eof_positions,
        'detected_modifications': False
    }
    
    # [Inference] Multiple EOF markers suggest document has been modified and saved incrementally
    if len(eof_positions) > 1:
        revision_info['detected_modifications'] = True
        revision_info['modification_evidence'] = 'Multiple EOF markers detected'
    
    # Analyze xref table for version information
    pdf = PdfReader(pdf_path)
    
    try:
        # Check for /Root object that tracks revisions
        if pdf.trailer and '/Root' in pdf.trailer:
            root = pdf.trailer['/Root']
            # Some PDFs store version in xref metadata
    except:
        pass
    
    return revision_info

def extract_incremental_updates(pdf_path):
    """Extract sections modified between incremental updates"""
    
    with open(pdf_path, 'rb') as f:
        content = f.read()
    
    # Split by PDF incremental update markers
    updates = re.split(b'%PDF-', content)
    
    return {
        'total_updates': len(updates),
        'first_version_offset': 0,
        'updates': [
            {
                'update_num': i,
                'size': len(update)
            }
            for i, update in enumerate(updates)
        ]
    }

# Example
revisions = detect_pdf_revisions('document.pdf')
print("[+] PDF Revision Detection:")
print(json.dumps(revisions, indent=2))

updates = extract_incremental_updates('document.pdf')
print("\n[+] Incremental Updates:")
print(json.dumps(updates, indent=2))
EOF
```

### Embedded Content and Hidden Objects

PDFs can contain hidden text, annotations, and embedded objects not visible in rendered view.

```bash
bash
pip install pdfplumber

python3 << 'EOF'
import pdfplumber
import json

def extract_pdf_annotations(pdf_path):
    """Extract PDF annotations (comments, highlights, etc.)"""
    annotations = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            if '/Annots' in page:
                for annot in page['/Annots']:
                    try:
                        annot_obj = annot.get_object()
                        annotation_data = {
                            'page': page_num + 1,
                            'type': annot_obj.get('/Subtype'),
                            'content': annot_obj.get('/Contents'),
                            'author': annot_obj.get('/T'),
                            'subject': annot_obj.get('/Subj'),
                            'created': annot_obj.get('/CreationDate'),
                            'modified': annot_obj.get('/ModDate')
                        }
                        annotations.append(annotation_data)
                    except:
                        continue
    
    return annotations

def extract_pdf_text_layers(pdf_path):
    """Extract all text from PDF (rendered and embedded)"""
    text_data = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            page_text = page.extract_text()
            
            text_data.append({
                'page': page_num + 1,
                'text_length': len(page_text) if page_text else 0,
                'text': page_text[:200] if page_text else '',  # First 200 chars
                'extraction_method': 'pdfplumber'
            })
    
    return text_data

def extract_pdf_urls(pdf_path):
    """Extract URLs embedded in PDF (links, document actions)"""
    urls = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            # Extract links
            if 'links' in dir(page):
                for link in page.extract_links():
                    urls.append({
                        'page': page_num + 1,
                        'url': link.get('uri'),
                        'type': 'link'
                    })
    
    return urls

# Example usage
annotations = extract_pdf_annotations('document.pdf')
print("[+] PDF Annotations:")
print(json.dumps(annotations[:3], indent=2, default=str))  # First 3 annotations

text_layers = extract_pdf_text_layers('document.pdf')
print("\n[+] Text Extraction:")
print(json.dumps(text_layers[:2], indent=2))  # First 2 pages

urls = extract_pdf_urls('document.pdf')
print("\n[+] Embedded URLs:")
print(json.dumps(urls, indent=2))
EOF
```

### PDF Compression and Encoding Analysis

Compression algorithms and encoding reveal document creation method and potential obfuscation.

```bash
python3 << 'EOF'
from PyPDF2 import PdfReader
import zlib
import json

def analyze_pdf_compression(pdf_path):
    """Analyze compression methods used in PDF streams"""
    pdf = PdfReader(pdf_path)
    
    compression_analysis = {
        'total_streams': 0,
        'compression_methods': {},
        'uncompressed_streams': 0,
        'details': []
    }
    
    for page_num, page in enumerate(pdf.pages):
        if '/Contents' not in page:
            continue
        
        try:
            # Extract content stream
            if isinstance(page['/Contents'], list):
                contents = page['/Contents']
            else:
                contents = [page['/Contents']]
            
            for content in contents:
                obj = content.get_object()
                compression_analysis['total_streams'] += 1
                
                # Check for compression
                if '/FlateDecode' in str(obj.get('/Filter', '')):
                    filter_type = 'FlateDecode (zlib)'
                    if 'FlateDecode' not in compression_analysis['compression_methods']:
                        compression_analysis['compression_methods']['FlateDecode'] = 0
                    compression_analysis['compression_methods']['FlateDecode'] += 1
                elif '/CCITTFaxDecode' in str(obj.get('/Filter', '')):
                    filter_type = 'CCITT Fax'
                    if 'CCITT' not in compression_analysis['compression_methods']:
                        compression_analysis['compression_methods']['CCITT'] = 0
                    compression_analysis['compression_methods']['CCITT'] += 1
                else:
                    filter_type = 'Uncompressed or unknown'
                    compression_analysis['uncompressed_streams'] += 1
                
                compression_analysis['details'].append({
                    'page': page_num + 1,
                    'method': filter_type,
                    'size': len(obj.get_data()) if hasattr(obj, 'get_data') else 0
                })
        except:
            continue
    
    return compression_analysis

# Example
compression = analyze_pdf_compression('document.pdf')
print("[+] PDF Compression Analysis:")
print(json.dumps(compression, indent=2, default=str))

# [Inference] FlateDecode (zlib) compression is standard modern PDF
# Uncompressed streams may indicate older documents or intentional obfuscation
EOF
```

---

## Document Dating Techniques

### Stylometric Analysis (Document Linguistics)

Language patterns, vocabulary frequency, and writing style vary by author and historical period.

```bash
pip install nltk textstat

python3 << 'EOF'
import nltk
from nltk.tokenize import word_tokenize, sent_tokenize
from nltk.corpus import stopwords
import textstat
from collections import Counter
import json

nltk.download('punkt', quiet=True)
nltk.download('stopwords', quiet=True)

def extract_stylometric_features(text):
    """Extract linguistic features for dating and attribution"""
    
    sentences = sent_tokenize(text)
    words = word_tokenize(text.lower())
    
    # Filter stopwords
    stop_words = set(stopwords.words('english'))
    meaningful_words = [w for w in words if w.isalnum() and w not in stop_words]
    
    features = {
        'total_words': len(words),
        'unique_words': len(set(words)),
        'avg_word_length': sum(len(w) for w in words) / len(words) if words else 0,
        'avg_sentence_length': len(words) / len(sentences) if sentences else 0,
        'lexical_diversity': len(set(words)) / len(words) if words else 0,
        'flesch_kincaid_grade': textstat.flesch_kincaid_grade(text),
        'flesch_reading_ease': textstat.flesch_reading_ease(text),
        'syllable_count': textstat.syllable_count(text),
        'sentence_count': len(sentences),
        'paragraph_count': len(text.split('\n\n'))
    }
    
    # Vocabulary frequency (top 20)
    word_freq = Counter(meaningful_words)
    features['top_words'] = dict(word_freq.most_common(20))
    
    return features

def compare_stylometric_profiles(text1, text2):
    """Compare two documents for stylistic similarity"""
    
    profile1 = extract_stylometric_features(text1)
    profile2 = extract_stylometric_features(text2)
    
    similarity_analysis = {
        'flesch_kincaid_diff': abs(profile1['flesch_kincaid_grade'] - profile2['flesch_kincaid_grade']),
        'lexical_diversity_diff': abs(profile1['lexical_diversity'] - profile2['lexical_diversity']),
        'avg_word_length_diff': abs(profile1['avg_word_length'] - profile2['avg_word_length']),
        'sentence_length_diff': abs(profile1['avg_sentence_length'] - profile2['avg_sentence_length']),
        'likely_same_author': False
    }
    
    # [Inference] If differences are minimal (<1.0 for readability, <0.1 for diversity), likely same author
    if (similarity_analysis['flesch_kincaid_diff'] < 1.0 and 
        similarity_analysis['lexical_diversity_diff'] < 0.1):
        similarity_analysis['likely_same_author'] = True
    
    return similarity_analysis

# Example
with open('document.txt', 'r') as f:
    text = f.read()

features = extract_stylometric_features(text)
print("[+] Stylometric Features:")
print(json.dumps({k: v for k, v in features.items() if k != 'top_words'}, indent=2, default=str))
print("\nTop words:", dict(list(features['top_words'].items())[:10]))
EOF
```

### Historical Document Dating

Document format evolution, typeface changes, and technology markers date documents.

```bash
python3 << 'EOF'
document_era_markers = {
    'Digital Age (2000+)': {
        'file_formats': ['PDF', 'DOCX', 'XLSX', 'PPTX'],
        'fonts': ['Calibri', 'Cambria', 'Arial', 'Helvetica'],
        'metadata_present': True,
        'track_changes_available': True,
        'hyperlinks': True,
        'color_common': True
    },
    'Office 97-2003 (1997-2007)': {
        'file_formats': ['DOC', 'XLS', 'PPT'],
        'fonts': ['Times New Roman', 'Arial', 'Courier New'],
        'metadata_present': True,
        'track_changes_available': True,
        'hyperlinks': False,
        'color_common': False
    },
    'Early Digital (1990-1996)': {
        'file_formats': ['TXT', 'RTF', 'WordPerfect'],
        'fonts': ['Courier', 'Palatino', 'Times Roman'],
        'metadata_present': False,
        'track_changes_available': False,
        'hyperlinks': False,
        'color_common': False
    },
    'Typewriter Era (1950-1990)': {
        'file_formats': ['Scanned image', 'Microfilm'],
        'fonts': ['Courier (monospace)'],
        'metadata_present': False,
        'typewriter_characteristics': True,
        'white_out_visible': True,
        'paper_aging': True
    }
}

def estimate_document_era(document_characteristics):
    """Estimate document creation period based on characteristics"""
    
    era_scores = {era: 0 for era in document_era_markers.keys()}
    
    for era, markers in document_era_markers.items():
        for characteristic in document_characteristics:
            for marker_type, marker_values in markers.items():
                if isinstance(marker_values, list):
                    if characteristic in marker_values:
                        era_scores[era] += 1
                elif isinstance(marker_values, bool):
                    if (characteristic == marker_type and marker_values) or \
                       (characteristic != marker_type and not marker_values):
                        era_scores[era] += 0.5
    
    return sorted(era_scores.items(), key=lambda x: x[1], reverse=True)

# Example
observed = ['DOCX', 'Calibri', 'Metadata present', 'Hyperlinks present', 'Track changes']
results = estimate_document_era(observed)

print("[+] Document Era Estimation:")
for era, score in results[:3]:
    print(f"    {era}: {score} points")
EOF
```

### Printer and Scanner Metadata

Physical documents converted to digital format retain hardware signatures.

```bash
python3 << 'EOF'
import json

def analyze_scanner_metadata(image_path):
    """Extract scanner/copier metadata from scanned documents"""
    from PIL import Image
    from PIL.ExifTags import TAGS
    
    img = Image.open(image_path)
    exif_data = img._getexif() if hasattr(img, '_getexif') else {}
    
    scanner_indicators = {
        'device_make': None,
        'device_model': None,
        'software': None,
        'compression_ratio': None,
        'date_digitized': None
    }
    
    if exif_data:
        for tag_id, value in exif_data.items():
            tag = TAGS.get(tag_id, tag_id)
            
            if tag == 'Make':
                scanner_indicators['device_make'] = value
            elif tag == 'Model':
                scanner_indicators['device_model'] = value
            elif tag == 'Software':
                scanner_indicators['software'] = value
            elif tag == 'DateTime':
                scanner_indicators['date_digitized'] = value
    
    return scanner_indicators

# Example
scanner_meta = analyze_scanner_metadata('scanned_document.jpg')
print("[+] Scanner Metadata:")
print(json.dumps(scanner_meta, indent=2))
EOF
```

---

## Authorship Attribution

### N-Gram Analysis

N-grams (sequences of N words/characters) create fingerprints unique to authors.

```bash
python3 << 'EOF'
from collections import Counter
import json
import math

def extract_ngrams(text, n=3):
    """Extract n-grams from text"""
    words = text.lower().split()
    ngrams = [' '.join(words[i:i+n]) for i in range(len(words)-n+1)]
    return Counter(ngrams)

def calculate_ngram_distance(ngrams1, ngrams2):
    """Calculate stylistic distance between two author profiles using n-grams"""
    
    all_ngrams = set(ngrams1.keys()) | set(ngrams2.keys())
    
    if not all_ngrams:
        return None
    
    # Calculate Euclidean distance
    distance = 0
    for ngram in all_ngrams:
        count1 = ngrams1.get(ngram, 0) / sum(ngrams1.values()) if ngrams1.values() else 0
        count2 = ngrams2.get(ngram, 0) / sum(ngrams2.values()) if ngrams2.values() else 0
        distance += (count1 - count2) ** 2
    
    return math.sqrt(distance)

def author_similarity_ranking(test_text, reference_texts_dict):
    """Compare test text against multiple reference texts to identify author"""
    
    test_ngrams = extract_ngrams(test_text, n=3)
    
    distances = {}
    
    for author_name, reference_text in reference_texts_dict.items():
        ref_ngrams = extract_ngrams(reference_text, n=3)
        distance = calculate_ngram_distance(test_ngrams, ref_ngrams)
        
        if distance is not None:
            distances[author_name] = distance
    
    # Sort by distance (lower = more similar)
    return sorted(distances.items(), key=lambda x: x[1])

# Example
unknown_text = """The quick brown fox jumps over the lazy dog. 
The fox was brown and quick. The dog was lazy and sleepy."""

reference_texts = {
    'Author A': 'The quick brown fox is very quick. The dog is lazy. Dogs are lazy animals.',
    'Author B': 'A fox jumped over something. Something was lazy. The lazy dog slept.'
}

results = author_similarity_ranking(unknown_text, reference_texts)
print("[+] Author Attribution (N-gram analysis):")
for author, distance in results:
    print(f"    {author}: {distance:.4f} (lower = more likely match)")
EOF
```

### Function Word Analysis

Function words (the, a, and, of, in) reveal author identity more reliably than content words.

```bash
python3 << 'EOF'
import json
from collections import Counter

function_words = {
    'common': ['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'by', 'with', 'as'],
    'pronouns': ['i', 'me', 'my', 'we', 'us', 'you', 'he', 'she', 'it', 'they', 'them', 'his', 'her', 'its'],
    'verbs': ['is', 'are', 'was', 'were', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'should']
}

def extract_function_word_profile(text):
    """Create function word frequency profile"""
    words = text.lower().split()
    
    profile = {
        'common_words': {},
        'pronouns': {},
        'auxiliary_verbs': {}
    }
    
    for word_type, word_list in function_words.items():
        matches = [w for w in words if w.strip('.,!?;:') in word_list]
        freq = Counter(matches)
        
        if word_type == 'common':
            profile['common_words'] = dict(freq.most_common(10))
        elif word_type == 'pronouns':
            profile['pronouns'] = dict(freq.most_common(5))
        elif word_type == 'verbs':
            profile['auxiliary_verbs'] = dict(freq.most_common(5))
    
    return profile

def compare_function_word_profiles(profile1, profile2):
    """Compare authorship based on function word usage"""
    
    def calculate_chi_squared(dict1, dict2):
        """Chi-squared test for distribution similarity"""
        all_keys = set(dict1.keys()) | set(dict2.keys())
        
        chi_squared = 0
        for key in all_keys:
            val1 = dict1.get(key, 0)
            val2 = dict2.get(key, 0)
            expected = (val1 + val2) / 2
            
            if expected > 0:
                chi_squared += ((val1 - expected) ** 2 + (val2 - expected) ** 2) / expected
        
        return chi_squared
    
    similarity_score = {
        'common_words_chi2': calculate_chi_squared(profile1['common_words'], profile2['common_words']),
        'pronouns_chi2': calculate_chi_squared(profile1['pronouns'], profile2['pronouns']),
        'auxiliary_verbs_chi2': calculate_chi_squared(profile1['auxiliary_verbs'], profile2['auxiliary_verbs']),
        'total_chi2': 0
    }
    
    similarity_score['total_chi2'] = (
        similarity_score['common_words_chi2'] + 
        similarity_score['pronouns_chi2'] + 
        similarity_score['auxiliary_verbs_chi2']
    )
    
    # [Inference] Lower chi-squared indicates more similar distributions (likely same author)
    # Typical threshold: <15 suggests similarity, >30 suggests different authors
    similarity_score['likely_same_author'] = similarity_score['total_chi2'] < 15
    
    return similarity_score

# Example
text1 = """I think that we should consider the proposal carefully. 
The team has been working on this for weeks. We need to make a decision soon."""

text2 = """We believe the proposal is good. The work has been ongoing. 
The team should decide soon. I agree with the assessment."""

profile1 = extract_function_word_profile(text1)
profile2 = extract_function_word_profile(text2)

comparison = compare_function_word_profiles(profile1, profile2)
print("[+] Function Word Analysis:")
print(json.dumps(comparison, indent=2))
EOF
```

### Writing Complexity Metrics

Readability scores and sentence structure complexity distinguish authors.

```bash
python3 << 'EOF'
import textstat
import json
from nltk.tokenize import sent_tokenize, word_tokenize
import nltk

nltk.download('punkt', quiet=True)

def calculate_complexity_metrics(text):
    """Calculate comprehensive writing complexity metrics"""
    
    sentences = sent_tokenize(text)
    words = word_tokenize(text)
    
    metrics = {
        'flesch_kincaid_grade': textstat.flesch_kincaid_grade(text),
        'flesch_reading_ease': textstat.flesch_reading_ease(text),
        'gunning_fog': textstat.gunning_fog(text),
        'smog_index': textstat.smog_index(text),
        'automated_readability_index': textstat.automated_readability_index(text),
        'coleman_liau_index': textstat.coleman_liau_index(text),
        'linsear_write_formula': textstat.linsear_write_formula(text),
        'dale_chall_readability_score': textstat.dale_chall_readability_score(text),
        'avg_sentence_length': len(words) / len(sentences) if sentences else 0,
        'avg_word_length': sum(len(w) for w in words) / len(words) if words else 0
    }
    
    # Determine complexity level
    avg_grade = (metrics['flesch_kincaid_grade'] + 
                 metrics['gunning_fog'] + 
                 metrics['smog_index']) / 3
    
    if avg_grade < 6:
        complexity_level = 'Elementary'
    elif avg_grade < 9:
        complexity_level = 'Middle School'
    elif avg_grade < 13:
        complexity_level = 'High School'
    elif avg_grade < 16:
        complexity_level = 'College'
    else:
        complexity_level = 'Graduate/Professional'
    
    metrics['complexity_level'] = complexity_level
    metrics['avg_grade_level'] = avg_grade
    
    return metrics

# Example
with open('document.txt', 'r') as f:
    text = f.read()

complexity = calculate_complexity_metrics(text)
print("[+] Writing Complexity Metrics:")
print(json.dumps(complexity, indent=2))
EOF
```

### Vocabulary Richness and Lexical Density

Unique word usage patterns distinguish individual authors.

```bash
python3 << 'EOF'
from collections import Counter
import json
import math

def calculate_vocabulary_richness(text):
    """Calculate type-token ratio and related metrics"""
    
    words = text.lower().split()
    words_clean = [w.strip('.,!?;:()[]{}') for w in words if w.strip('.,!?;:()[]{}')]
    
    word_freq = Counter(words_clean)
    
    metrics = {
        'total_tokens': len(words_clean),
        'unique_types': len(word_freq),
        'type_token_ratio': len(word_freq) / len(words_clean) if words_clean else 0,
        'hapax_legomena': len([w for w, c in word_freq.items() if c == 1]),
        'hapax_ratio': len([w for w, c in word_freq.items() if c == 1]) / len(words_clean) if words_clean else 0,
        'yules_k': 0,
        'simpsons_index': 0
    }
    
    # Yule's K (measure of vocabulary diversity)
    # Lower values indicate higher diversity
    if word_freq:
        M1 = sum(word_freq.values())
        M2 = sum([freq ** 2 for freq in word_freq.values()])
        metrics['yules_k'] = 10000 * (M2 - M1) / (M1 ** 2) if M1 > 0 else 0
    
    # Simpson's Index (measure of concentration)
    total = sum(word_freq.values())
    if total > 0:
        metrics['simpsons_index'] = sum([(freq / total) ** 2 for freq in word_freq.values()])
    
    # [Inference] Higher type-token ratio = more diverse vocabulary
    # Professional writers typically have TTR 0.6-0.8, casual writing 0.4-0.6
    
    return metrics

# Example
text_sample = """The comprehensive analysis of document metadata reveals 
significant information about authorship attribution. Various metrics 
demonstrate the complexity and sophistication of modern computational linguistics."""

richness = calculate_vocabulary_richness(text_sample)
print("[+] Vocabulary Richness Analysis:")
print(json.dumps(richness, indent=2))
EOF
```

---

## Document Format Analysis

### File Format Identification and Validation

Determining true file format regardless of extension.

```bash
pip install python-magic

python3 << 'EOF'
import magic
import os
import json

def identify_file_format(file_path):
    """Identify true file format using magic bytes"""
    
    # Read magic bytes
    with open(file_path, 'rb') as f:
        header = f.read(16)
    
    # Use python-magic for detailed detection
    mime_type = magic.from_file(file_path, mime=True)
    file_type = magic.from_file(file_path)
    
    # Common magic byte signatures
    magic_signatures = {
        b'%PDF': 'PDF',
        b'PK\x03\x04': 'ZIP/Office Open XML (DOCX, XLSX, PPTX)',
        b'\xd0\xcf\x11\xe0': 'Microsoft Office 97-2003 (DOC, XLS, PPT)',
        b'\x89PNG': 'PNG',
        b'\xff\xd8\xff': 'JPEG',
        b'GIF8': 'GIF',
        b'<?xml': 'XML',
        b'{\rtf': 'RTF',
        b'MZ': 'Windows Executable'
    }
    
    detected_signature = None
    for signature, format_name in magic_signatures.items():
        if header.startswith(signature):
            detected_signature = format_name
            break
    
    # Check file extension
    _, extension = os.path.splitext(file_path)
    
    format_analysis = {
        'file_path': file_path,
        'declared_extension': extension,
        'mime_type': mime_type,
        'file_type_description': file_type,
        'magic_signature': detected_signature,
        'magic_bytes_hex': header.hex(),
        'extension_matches_content': False,
        'potential_masquerading': False
    }
    
    # Verify extension matches content
    extension_mime_map = {
        '.pdf': 'application/pdf',
        '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        '.jpg': 'image/jpeg',
        '.png': 'image/png',
        '.txt': 'text/plain'
    }
    
    expected_mime = extension_mime_map.get(extension.lower())
    if expected_mime and mime_type == expected_mime:
        format_analysis['extension_matches_content'] = True
    elif expected_mime:
        format_analysis['potential_masquerading'] = True
        format_analysis['warning'] = f"Extension suggests {expected_mime} but content is {mime_type}"
    
    return format_analysis

# Example
format_info = identify_file_format('document.pdf')
print("[+] File Format Analysis:")
print(json.dumps(format_info, indent=2))
EOF
```

### Office Document XML Structure Analysis

Modern Office formats (DOCX, XLSX, PPTX) are ZIP archives containing XML. Analyzing structure reveals hidden content.

```bash
python3 << 'EOF'
import zipfile
import xml.etree.ElementTree as ET
import json

def analyze_docx_structure(docx_path):
    """Analyze internal structure of DOCX file"""
    
    structure = {
        'document_type': 'DOCX',
        'files': [],
        'relationships': [],
        'embedded_objects': [],
        'core_properties': {},
        'custom_properties': {}
    }
    
    with zipfile.ZipFile(docx_path, 'r') as zip_ref:
        # List all files in archive
        structure['files'] = zip_ref.namelist()
        
        # Extract core properties (metadata)
        if 'docProps/core.xml' in structure['files']:
            core_xml = zip_ref.read('docProps/core.xml')
            root = ET.fromstring(core_xml)
            
            # Parse namespaces
            namespaces = {
                'dc': 'http://purl.org/dc/elements/1.1/',
                'dcterms': 'http://purl.org/dc/terms/',
                'cp': 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties'
            }
            
            for elem in root:
                tag = elem.tag.split('}')[-1]  # Remove namespace
                structure['core_properties'][tag] = elem.text
        
        # Extract custom properties
        if 'docProps/custom.xml' in structure['files']:
            custom_xml = zip_ref.read('docProps/custom.xml')
            root = ET.fromstring(custom_xml)
            
            for prop in root:
                name = prop.get('name')
                value = prop[0].text if len(prop) > 0 else None
                structure['custom_properties'][name] = value
        
        # Analyze relationships (linked/embedded objects)
        if 'word/_rels/document.xml.rels' in structure['files']:
            rels_xml = zip_ref.read('word/_rels/document.xml.rels')
            root = ET.fromstring(rels_xml)
            
            for rel in root:
                rel_info = {
                    'id': rel.get('Id'),
                    'type': rel.get('Type').split('/')[-1],
                    'target': rel.get('Target')
                }
                structure['relationships'].append(rel_info)
                
                # Identify embedded objects
                if 'oleObject' in rel.get('Type', '') or 'image' in rel.get('Type', ''):
                    structure['embedded_objects'].append(rel_info)
    
    return structure

def extract_docx_hidden_text(docx_path):
    """Extract text marked as hidden in DOCX"""
    
    hidden_text = []
    
    with zipfile.ZipFile(docx_path, 'r') as zip_ref:
        if 'word/document.xml' in zip_ref.namelist():
            doc_xml = zip_ref.read('word/document.xml')
            root = ET.fromstring(doc_xml)
            
            # Look for hidden text (w:vanish tag)
            namespace = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            
            for vanish in root.findall('.//w:vanish', namespace):
                # Get parent run
                run = vanish.getparent()
                if run is not None:
                    text_elem = run.find('.//w:t', namespace)
                    if text_elem is not None and text_elem.text:
                        hidden_text.append(text_elem.text)
    
    return hidden_text

# Example
structure = analyze_docx_structure('document.docx')
print("[+] DOCX Structure Analysis:")
print(json.dumps(structure, indent=2, default=str))

hidden = extract_docx_hidden_text('document.docx')
if hidden:
    print("\n[+] Hidden Text Detected:")
    for text in hidden:
        print(f"    - {text}")
EOF
```

### Track Changes and Revision History

Extracting deleted/modified content from tracked changes.

```bash
python3 << 'EOF'
import zipfile
import xml.etree.ElementTree as ET
import json
from datetime import datetime

def extract_track_changes(docx_path):
    """Extract all tracked changes from DOCX"""
    
    changes = {
        'insertions': [],
        'deletions': [],
        'modifications': [],
        'comments': []
    }
    
    with zipfile.ZipFile(docx_path, 'r') as zip_ref:
        if 'word/document.xml' in zip_ref.namelist():
            doc_xml = zip_ref.read('word/document.xml')
            root = ET.fromstring(doc_xml)
            
            namespace = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            
            # Extract insertions (w:ins)
            for ins in root.findall('.//w:ins', namespace):
                author = ins.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
                date = ins.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date')
                
                text_content = ''.join([t.text for t in ins.findall('.//w:t', namespace) if t.text])
                
                changes['insertions'].append({
                    'author': author,
                    'date': date,
                    'text': text_content
                })
            
            # Extract deletions (w:del)
            for deletion in root.findall('.//w:del', namespace):
                author = deletion.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
                date = deletion.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date')
                
                text_content = ''.join([t.text for t in deletion.findall('.//w:delText', namespace) if t.text])
                
                changes['deletions'].append({
                    'author': author,
                    'date': date,
                    'deleted_text': text_content
                })
        
        # Extract comments
        if 'word/comments.xml' in zip_ref.namelist():
            comments_xml = zip_ref.read('word/comments.xml')
            root = ET.fromstring(comments_xml)
            
            for comment in root.findall('.//w:comment', namespace):
                comment_id = comment.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}id')
                author = comment.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
                date = comment.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date')
                
                text_content = ''.join([t.text for t in comment.findall('.//w:t', namespace) if t.text])
                
                changes['comments'].append({
                    'id': comment_id,
                    'author': author,
                    'date': date,
                    'text': text_content
                })
    
    return changes

# Example
changes = extract_track_changes('document.docx')
print("[+] Track Changes Analysis:")
print(json.dumps(changes, indent=2, default=str))

# [Inference] Deleted text in track changes often contains sensitive information
# Authors may forget to accept/reject all changes before distribution
EOF
```

### Font Analysis and Embedding

Font usage reveals document creation platform and historical context.

```bash
python3 << 'EOF'
from PyPDF2 import PdfReader
import json

def extract_pdf_fonts(pdf_path):
    """Extract font information from PDF"""
    
    pdf = PdfReader(pdf_path)
    
    font_analysis = {
        'fonts_used': [],
        'embedded_fonts': [],
        'system_fonts': [],
        'historical_indicators': []
    }
    
    for page_num, page in enumerate(pdf.pages):
        if '/Resources' in page and '/Font' in page['/Resources']:
            fonts = page['/Resources']['/Font']
            
            for font_name, font_obj in fonts.items():
                font_data = font_obj.get_object()
                
                base_font = font_data.get('/BaseFont', 'Unknown')
                subtype = font_data.get('/Subtype', 'Unknown')
                
                font_info = {
                    'name': str(base_font),
                    'type': str(subtype),
                    'page': page_num + 1,
                    'embedded': '/FontFile' in font_data or '/FontFile2' in font_data or '/FontFile3' in font_data
                }
                
                font_analysis['fonts_used'].append(font_info)
                
                if font_info['embedded']:
                    font_analysis['embedded_fonts'].append(str(base_font))
                else:
                    font_analysis['system_fonts'].append(str(base_font))
    
    # Remove duplicates
    font_analysis['embedded_fonts'] = list(set(font_analysis['embedded_fonts']))
    font_analysis['system_fonts'] = list(set(font_analysis['system_fonts']))
    
    # Analyze historical indicators
    historical_fonts = {
        'Calibri': 'Post-2007 (Office 2007+)',
        'Cambria': 'Post-2007 (Office 2007+)',
        'Times New Roman': 'Pre-2007 or traditional documents',
        'Arial': 'Windows-based creation',
        'Helvetica': 'Mac/Unix-based creation',
        'Courier New': 'Technical or code documents',
        'Comic Sans': 'Informal/amateur creation'
    }
    
    for font in font_analysis['system_fonts'] + font_analysis['embedded_fonts']:
        for hist_font, indicator in historical_fonts.items():
            if hist_font.lower() in font.lower():
                font_analysis['historical_indicators'].append({
                    'font': hist_font,
                    'indicator': indicator
                })
    
    return font_analysis

# Example
fonts = extract_pdf_fonts('document.pdf')
print("[+] Font Analysis:")
print(json.dumps(fonts, indent=2))
EOF
```

---

## Integrated Document Intelligence Framework

### Comprehensive Document Analysis Pipeline

```bash
python3 << 'EOF'
import json
from datetime import datetime
from PyPDF2 import PdfReader
import os

class DocumentIntelligenceAnalyzer:
    def __init__(self, file_path):
        self.file_path = file_path
        self.analysis = {
            'file_info': {},
            'metadata': {},
            'forensics': {},
            'dating': {},
            'authorship': {},
            'format_analysis': {},
            'timeline': [],
            'flags_detected': [],
            'confidence_score': 0
        }
    
    def analyze_file_info(self):
        """Basic file information"""
        stat = os.stat(self.file_path)
        
        self.analysis['file_info'] = {
            'filename': os.path.basename(self.file_path),
            'size_bytes': stat.st_size,
            'created': datetime.fromtimestamp(stat.st_ctime).isoformat(),
            'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
            'accessed': datetime.fromtimestamp(stat.st_atime).isoformat()
        }
    
    def analyze_metadata(self):
        """Extract comprehensive metadata"""
        if self.file_path.lower().endswith('.pdf'):
            pdf = PdfReader(self.file_path)
            if pdf.metadata:
                self.analysis['metadata'] = {
                    key.lstrip('/'): value 
                    for key, value in pdf.metadata.items()
                }
        
    def detect_anomalies(self):
        """Detect forensic anomalies"""
        anomalies = []
        
        # Check timestamp consistency
        if self.analysis['file_info']:
            created = datetime.fromisoformat(self.analysis['file_info']['created'])
            modified = datetime.fromisoformat(self.analysis['file_info']['modified'])
            
            if modified < created:
                anomalies.append({
                    'type': 'timestamp_anomaly',
                    'description': 'Modification date before creation date',
                    'severity': 'high'
                })
        
        # Check metadata consistency
        if self.analysis['metadata']:
            if self.analysis['metadata'].get('Creator') == self.analysis['metadata'].get('Producer'):
                anomalies.append({
                    'type': 'metadata_pattern',
                    'description': 'Creator equals Producer (common in automated systems)',
                    'severity': 'low'
                })
        
        self.analysis['forensics']['anomalies'] = anomalies
    
    def estimate_document_age(self):
        """Estimate document creation period"""
        indicators = []
        
        if self.analysis['metadata']:
            producer = self.analysis['metadata'].get('Producer', '')
            
            if 'Microsoft Office' in str(producer):
                if '2019' in str(producer) or '365' in str(producer):
                    indicators.append('2019+ (Office 2019/365)')
                elif '2016' in str(producer):
                    indicators.append('2016-2019 (Office 2016)')
                elif '2007' in str(producer) or '2010' in str(producer):
                    indicators.append('2007-2016 (Office 2007-2013)')
        
        self.analysis['dating']['era_indicators'] = indicators
    
    def calculate_confidence(self):
        """Calculate overall analysis confidence"""
        confidence = 0
        
        if self.analysis['metadata']:
            confidence += 30
        
        if self.analysis['forensics'].get('anomalies'):
            confidence += 20
        
        if self.analysis['dating'].get('era_indicators'):
            confidence += 25
        
        if self.analysis['file_info']:
            confidence += 25
        
        self.analysis['confidence_score'] = confidence
    
    def generate_report(self):
        """Generate comprehensive analysis report"""
        self.analyze_file_info()
        self.analyze_metadata()
        self.detect_anomalies()
        self.estimate_document_age()
        self.calculate_confidence()
        
        return self.analysis

# Example usage
analyzer = DocumentIntelligenceAnalyzer('document.pdf')
report = analyzer.generate_report()

print("[+] Document Intelligence Report:")
print(json.dumps(report, indent=2, default=str))
EOF
```

### CTF Flag Extraction Patterns

```bash
python3 << 'EOF'
import re
import json

def extract_potential_flags(analysis_results):
    """Extract potential CTF flags from document analysis"""
    
    potential_flags = []
    
    # Pattern 1: Metadata concatenation
    if 'metadata' in analysis_results:
        author = analysis_results['metadata'].get('Author', '')
        title = analysis_results['metadata'].get('Title', '')
        
        if author and title:
            flag_candidate = f"flag{{{author.replace(' ', '_')}_{title.replace(' ', '_')}}}"
            potential_flags.append({
                'pattern': 'metadata_concat',
                'value': flag_candidate,
                'confidence': 0.7
            })
    
    # Pattern 2: Timestamp encoding
    if 'file_info' in analysis_results:
        created = analysis_results['file_info'].get('created', '')
        if created:
            # Extract numeric components
            timestamp_nums = re.findall(r'\d+', created)
            if timestamp_nums:
                flag_candidate = f"flag{{'_'.join(timestamp_nums)}}"
                potential_flags.append({
                    'pattern': 'timestamp_encoding',
                    'value': flag_candidate,
                    'confidence': 0.5
                })
    
    # Pattern 3: Anomaly indicators
    if 'forensics' in analysis_results and 'anomalies' in analysis_results['forensics']:
        anomaly_count = len(analysis_results['forensics']['anomalies'])
        if anomaly_count > 0:
            flag_candidate = f"flag{{ANOMALIES_{anomaly_count}}}"
            potential_flags.append({
                'pattern': 'anomaly_count',
                'value': flag_candidate,
                'confidence': 0.6
            })
    
    # Pattern 4: Producer version extraction
    if 'metadata' in analysis_results:
        producer = analysis_results['metadata'].get('Producer', '')
        version_match = re.search(r'(\d+\.\d+)', str(producer))
        if version_match:
            version = version_match.group(1).replace('.', '_')
            flag_candidate = f"flag{{VERSION_{version}}}"
            potential_flags.append({
                'pattern': 'version_extraction',
                'value': flag_candidate,
                'confidence': 0.65
            })
    
    return sorted(potential_flags, key=lambda x: x['confidence'], reverse=True)

# Example
test_analysis = {
    'metadata': {
        'Author': 'John Doe',
        'Title': 'Secret Document',
        'Producer': 'Microsoft Word 16.0'
    },
    'file_info': {
        'created': '2024-01-15T10:30:45'
    },
    'forensics': {
        'anomalies': [
            {'type': 'timestamp_anomaly', 'severity': 'high'}
        ]
    }
}

flags = extract_potential_flags(test_analysis)
print("[+] Potential CTF Flags:")
print(json.dumps(flags, indent=2))
EOF
```

### Complete CTF Document Analysis Workflow

```bash
#!/bin/bash

DOCUMENT="challenge_document.pdf"

echo "[*] Starting comprehensive document analysis..."

# 1. Extract all metadata
echo "[1/6] Extracting metadata..."
exiftool -json "$DOCUMENT" > metadata.json

# 2. Analyze PDF structure
echo "[2/6] Analyzing PDF structure..."
python3 << 'PYTHON'
from PyPDF2 import PdfReader
pdf = PdfReader('challenge_document.pdf')
print(f"Pages: {len(pdf.pages)}")
print(f"Encrypted: {pdf.is_encrypted}")
PYTHON

# 3. Extract text and annotations
echo "[3/6] Extracting text and annotations..."
pip install -q pdfplumber
python3 << 'PYTHON'
import pdfplumber
with pdfplumber.open('challenge_document.pdf') as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        if text:
            print(text[:200])
PYTHON

# 4. Analyze fonts and embedded objects
echo "[4/6] Analyzing fonts..."
exiftool -FontName -FontType "$DOCUMENT"

# 5. Check for track changes (if DOCX)
if [[ "$DOCUMENT" == *.docx ]]; then
    echo "[5/6] Extracting track changes..."
    # Track changes extraction code here
fi

# 6. Generate comprehensive report
echo "[6/6] Generating report..."
python3 << 'PYTHON'
# Complete analysis report generation
PYTHON

echo "[+] Document analysis complete. Check output files for flags."
```

---

## Advanced Document Analysis Techniques

### Steganography Detection in Documents

Documents can hide data in whitespace, formatting, or invisible characters.

```bash
python3 << 'EOF'
import re
import json

def detect_whitespace_steganography(text):
    """Detect hidden data in whitespace patterns"""
    
    # Check for unusual whitespace patterns
    lines = text.split('\n')
    
    suspicious_patterns = {
        'trailing_whitespace': [],
        'unusual_spacing': [],
        'tab_patterns': [],
        'zero_width_chars': []
    }
    
    for line_num, line in enumerate(lines):
        # Detect trailing whitespace
        if line.endswith(' ') or line.endswith('\t'):
            trailing = len(line) - len(line.rstrip())
            suspicious_patterns['trailing_whitespace'].append({
                'line': line_num + 1,
                'length': trailing,
                'pattern': repr(line[-trailing:])
            })
        
        # Detect unusual spacing (multiple consecutive spaces)
        if '  ' in line:
            spaces = re.findall(r' {2,}', line)
            for space_seq in spaces:
                suspicious_patterns['unusual_spacing'].append({
                    'line': line_num + 1,
                    'length': len(space_seq),
                    'position': line.index(space_seq)
                })
        
        # Detect zero-width characters (U+200B, U+200C, U+200D, U+FEFF)
        zero_width_chars = ['\u200b', '\u200c', '\u200d', '\ufeff']
        for char in zero_width_chars:
            if char in line:
                suspicious_patterns['zero_width_chars'].append({
                    'line': line_num + 1,
                    'char': repr(char),
                    'count': line.count(char)
                })
    
    return suspicious_patterns

def extract_whitespace_encoding(text):
    """Attempt to decode whitespace-encoded data"""
    
    # Method 1: Space=0, Tab=1 binary encoding
    lines = text.split('\n')
    binary_data = []
    
    for line in lines:
        trailing = line[len(line.rstrip()):]
        if trailing:
            # Convert to binary (space=0, tab=1)
            binary_str = trailing.replace(' ', '0').replace('\t', '1')
            binary_data.append(binary_str)
    
    # Try to decode as ASCII
    decoded_text = []
    full_binary = ''.join(binary_data)
    
    for i in range(0, len(full_binary), 8):
        byte = full_binary[i:i+8]
        if len(byte) == 8:
            try:
                char = chr(int(byte, 2))
                decoded_text.append(char)
            except:
                pass
    
    return {
        'binary_strings': binary_data,
        'decoded_attempt': ''.join(decoded_text),
        'decoding_successful': bool(''.join(decoded_text).isprintable())
    }

# Example
sample_text = """This is a line with trailing spaces.  
This line has unusual  spacing between words.
Normal line here.
Another line with tabs\t\t\tat the end."""

patterns = detect_whitespace_steganography(sample_text)
print("[+] Whitespace Steganography Detection:")
print(json.dumps(patterns, indent=2))

decoded = extract_whitespace_encoding(sample_text)
print("\n[+] Whitespace Decoding Attempt:")
print(json.dumps(decoded, indent=2))
EOF
```

### Unicode Normalization and Homoglyph Detection

Visually identical characters from different Unicode blocks can hide information.

```bash
pip install unidecode

python3 << 'EOF'
import unicodedata
import json

def detect_homoglyphs(text):
    """Detect visually similar characters from different Unicode blocks"""
    
    homoglyph_map = {
        'Latin': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'Cyrillic': 'АВСDЕFGHIJКЛМNОРQRSТUVWXYZ',  # Cyrillic lookalikes
        'Greek': 'ΑΒΕΖΗΙΚΜΝΟΡΤΥΧ'  # Greek lookalikes
    }
    
    detected_homoglyphs = []
    
    for i, char in enumerate(text):
        if char.isalpha():
            char_name = unicodedata.name(char, 'UNKNOWN')
            
            # Check if character is from unusual script
            if 'CYRILLIC' in char_name and char.upper() in homoglyph_map['Latin']:
                detected_homoglyphs.append({
                    'position': i,
                    'character': char,
                    'unicode_name': char_name,
                    'codepoint': f'U+{ord(char):04X}',
                    'type': 'Cyrillic lookalike'
                })
            elif 'GREEK' in char_name and char.upper() in homoglyph_map['Latin']:
                detected_homoglyphs.append({
                    'position': i,
                    'character': char,
                    'unicode_name': char_name,
                    'codepoint': f'U+{ord(char):04X}',
                    'type': 'Greek lookalike'
                })
    
    return detected_homoglyphs

def normalize_unicode(text):
    """Normalize Unicode text to detect hidden variations"""
    
    normalization_forms = {
        'NFC': unicodedata.normalize('NFC', text),
        'NFD': unicodedata.normalize('NFD', text),
        'NFKC': unicodedata.normalize('NFKC', text),
        'NFKD': unicodedata.normalize('NFKD', text)
    }
    
    # Compare lengths to detect composition differences
    analysis = {
        'original_length': len(text),
        'normalized_lengths': {form: len(normalized) for form, normalized in normalization_forms.items()},
        'length_differences': {}
    }
    
    for form, normalized in normalization_forms.items():
        diff = len(text) - len(normalized)
        if diff != 0:
            analysis['length_differences'][form] = diff
    
    return analysis

# Example with Cyrillic lookalikes
sample_text = "This is a test with Суrilliс characters"  # Contains Cyrillic 'у' and 'С'

homoglyphs = detect_homoglyphs(sample_text)
print("[+] Homoglyph Detection:")
print(json.dumps(homoglyphs, indent=2))

normalization = normalize_unicode(sample_text)
print("\n[+] Unicode Normalization Analysis:")
print(json.dumps(normalization, indent=2))
EOF
```

### Macro and Embedded Script Detection

Office documents can contain executable macros and scripts.

```bash
pip install oletools

python3 << 'EOF'
import subprocess
import json
import os

def detect_macros(office_file):
    """Detect VBA macros in Office documents"""
    
    # Using olevba from oletools
    try:
        result = subprocess.run(
            ['olevba', office_file],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        analysis = {
            'macros_detected': 'VBA' in result.stdout,
            'suspicious_keywords': [],
            'obfuscation_detected': False,
            'raw_output': result.stdout[:500]  # First 500 chars
        }
        
        # Check for suspicious keywords
        suspicious_keywords = [
            'AutoOpen', 'AutoExec', 'Auto_Open',
            'Shell', 'CreateObject', 'WScript',
            'Powershell', 'cmd.exe', 'ExecuteExcel4Macro'
        ]
        
        for keyword in suspicious_keywords:
            if keyword.lower() in result.stdout.lower():
                analysis['suspicious_keywords'].append(keyword)
        
        # Check for obfuscation indicators
        obfuscation_patterns = ['Chr(', 'Asc(', 'StrReverse(', 'Replace(']
        for pattern in obfuscation_patterns:
            if pattern in result.stdout:
                analysis['obfuscation_detected'] = True
                break
        
        return analysis
    
    except Exception as e:
        return {'error': str(e)}

def extract_macro_code(office_file):
    """Extract macro source code"""
    
    try:
        result = subprocess.run(
            ['olevba', '--decode', office_file],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        return {
            'macro_code': result.stdout,
            'extraction_successful': result.returncode == 0
        }
    except Exception as e:
        return {'error': str(e)}

# Example
# macro_analysis = detect_macros('document.xlsm')
# print("[+] Macro Detection:")
# print(json.dumps(macro_analysis, indent=2))

print("[+] Macro detection requires oletools package and sample files")
print("    Install: pip install oletools")
print("    Usage: olevba document.xlsm")
EOF
```

### Document Comparison and Diff Analysis

Comparing multiple versions reveals changes and hidden modifications.

```bash
pip install python-docx diff-match-patch

python3 << 'EOF'
import difflib
import json
from diff_match_patch import diff_match_patch

def compare_documents(text1, text2, method='unified'):
    """Compare two document versions"""
    
    if method == 'unified':
        # Unified diff (similar to git diff)
        diff = list(difflib.unified_diff(
            text1.splitlines(),
            text2.splitlines(),
            lineterm='',
            fromfile='Version 1',
            tofile='Version 2'
        ))
        
        return {
            'diff_type': 'unified',
            'differences': diff,
            'total_changes': len([line for line in diff if line.startswith('+') or line.startswith('-')])
        }
    
    elif method == 'semantic':
        # Semantic diff (better for natural language)
        dmp = diff_match_patch()
        diffs = dmp.diff_main(text1, text2)
        dmp.diff_cleanupSemantic(diffs)
        
        changes = {
            'additions': [],
            'deletions': [],
            'unchanged': []
        }
        
        for (op, data) in diffs:
            if op == 1:  # Addition
                changes['additions'].append(data)
            elif op == -1:  # Deletion
                changes['deletions'].append(data)
            else:  # No change
                changes['unchanged'].append(data[:50])  # First 50 chars only
        
        return {
            'diff_type': 'semantic',
            'changes': changes,
            'total_additions': len(changes['additions']),
            'total_deletions': len(changes['deletions'])
        }

def extract_sensitive_deletions(text1, text2):
    """Identify potentially sensitive information that was deleted"""
    
    dmp = diff_match_patch()
    diffs = dmp.diff_main(text1, text2)
    
    deletions = [data for (op, data) in diffs if op == -1]
    
    # Patterns that might indicate sensitive data
    sensitive_patterns = {
        'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
        'phone': r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
        'ssn': r'\b\d{3}-\d{2}-\d{4}\b',
        'credit_card': r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b',
        'ip_address': r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
    }
    
    import re
    sensitive_deletions = {}
    
    for deletion in deletions:
        for pattern_name, pattern in sensitive_patterns.items():
            matches = re.findall(pattern, deletion)
            if matches:
                if pattern_name not in sensitive_deletions:
                    sensitive_deletions[pattern_name] = []
                sensitive_deletions[pattern_name].extend(matches)
    
    return {
        'total_deletions': len(deletions),
        'sensitive_data_found': sensitive_deletions,
        'deleted_text_samples': [d[:100] for d in deletions[:3]]
    }

# Example
doc1 = """This is the original document. 
Contact: john.doe@example.com
Phone: 555-123-4567"""

doc2 = """This is the revised document.
Contact: [REDACTED]
Phone: [REDACTED]"""

comparison = compare_documents(doc1, doc2, method='semantic')
print("[+] Document Comparison:")
print(json.dumps(comparison, indent=2))

sensitive = extract_sensitive_deletions(doc1, doc2)
print("\n[+] Sensitive Deletions Detected:")
print(json.dumps(sensitive, indent=2))
EOF
```

### Metadata Timeline Reconstruction

Build comprehensive timeline from multiple metadata sources.

```bash
python3 << 'EOF'
import json
from datetime import datetime
from collections import defaultdict

def reconstruct_document_timeline(file_path):
    """Reconstruct complete document timeline from all available timestamps"""
    
    timeline = defaultdict(list)
    
    # File system timestamps
    import os
    stat = os.stat(file_path)
    
    timeline['filesystem'] = [
        {
            'timestamp': datetime.fromtimestamp(stat.st_ctime).isoformat(),
            'event': 'File created (filesystem)',
            'source': 'os.stat'
        },
        {
            'timestamp': datetime.fromtimestamp(stat.st_mtime).isoformat(),
            'event': 'File modified (filesystem)',
            'source': 'os.stat'
        },
        {
            'timestamp': datetime.fromtimestamp(stat.st_atime).isoformat(),
            'event': 'File accessed (filesystem)',
            'source': 'os.stat'
        }
    ]
    
    # Document metadata timestamps (PDF example)
    if file_path.lower().endswith('.pdf'):
        from PyPDF2 import PdfReader
        
        try:
            pdf = PdfReader(file_path)
            if pdf.metadata:
                for key, value in pdf.metadata.items():
                    if 'date' in key.lower() or 'time' in key.lower():
                        timeline['document_metadata'].append({
                            'timestamp': str(value),
                            'event': f'Document {key.lstrip("/")}',
                            'source': 'PDF metadata'
                        })
        except:
            pass
    
    # Sort all events chronologically
    all_events = []
    for source, events in timeline.items():
        all_events.extend(events)
    
    try:
        all_events.sort(key=lambda x: datetime.fromisoformat(x['timestamp'].replace('Z', '+00:00').split('+')[0]))
    except:
        pass  # Some timestamps may not parse
    
    return {
        'total_events': len(all_events),
        'timeline': all_events,
        'earliest_event': all_events[0] if all_events else None,
        'latest_event': all_events[-1] if all_events else None
    }

# Example
# timeline = reconstruct_document_timeline('document.pdf')
# print("[+] Document Timeline Reconstruction:")
# print(json.dumps(timeline, indent=2))

print("[+] Timeline reconstruction extracts all timestamp sources")
print("    Useful for detecting backdating or timestamp manipulation")
EOF
```

---

## CTF-Specific Document Intelligence Patterns

### Pattern 1: Metadata Flag Construction

**Challenge Type**: Flag hidden in concatenated metadata fields

**Solution Approach**:

```bash
# Extract all metadata
exiftool -json document.pdf | jq '.[] | {Author, Title, Subject, Keywords}'

# Python extraction and concatenation
python3 << 'EOF'
from PyPDF2 import PdfReader
pdf = PdfReader('document.pdf')
meta = pdf.metadata

flag_parts = [
    meta.get('/Author', ''),
    meta.get('/Title', ''),
    meta.get('/Subject', '')
]

flag = 'flag{' + '_'.join(p.replace(' ', '') for p in flag_parts if p) + '}'
print(f"[+] Constructed flag: {flag}")
EOF
```

### Pattern 2: Track Changes Hidden Data

**Challenge Type**: Flag in deleted text within track changes

**Solution Approach**:

```python
python3 << 'EOF'
import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('document.docx', 'r') as z:
    doc_xml = z.read('word/document.xml')
    root = ET.fromstring(doc_xml)
    
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    # Extract all deleted text
    deleted = []
    for del_text in root.findall('.//w:delText', ns):
        if del_text.text:
            deleted.append(del_text.text)
    
    print("[+] Deleted text:")
    print(''.join(deleted))
EOF
```

### Pattern 3: Timestamp Arithmetic

**Challenge Type**: Flag encoded in timestamp differences or numeric values

**Solution Approach**:

```python
python3 << 'EOF'
from PyPDF2 import PdfReader
from datetime import datetime

pdf = PdfReader('document.pdf')
meta = pdf.metadata

# Extract timestamps
created = meta.get('/CreationDate', '')
modified = meta.get('/ModDate', '')

# Parse PDF date format: D:YYYYMMDDHHmmSS
def parse_pdf_date(date_str):
    date_str = date_str.replace('D:', '').split('+')[0].split('-')[0]
    return datetime.strptime(date_str[:14], '%Y%m%d%H%M%S')

try:
    created_dt = parse_pdf_date(created)
    modified_dt = parse_pdf_date(modified)
    
    # Calculate difference in seconds
    diff = int((modified_dt - created_dt).total_seconds())
    
    # Convert to flag (example: difference is ASCII values)
    flag_chars = []
    temp = diff
    while temp > 0:
        flag_chars.append(chr(temp % 256))
        temp //= 256
    
    print(f"[+] Timestamp difference: {diff} seconds")
    print(f"[+] Decoded flag attempt: {''.join(reversed(flag_chars))}")
except Exception as e:
    print(f"[-] Error: {e}")
EOF
```

### Pattern 4: Font Substitution Cipher

**Challenge Type**: Different fonts encode different letters, creating substitution cipher

**Solution Approach**:

```python
python3 << 'EOF'
import pdfplumber

with pdfplumber.open('document.pdf') as pdf:
    for page in pdf.pages:
        # Extract text with font information
        chars = page.chars
        
        font_mapping = {}
        for char in chars:
            font = char['fontname']
            text = char['text']
            
            if font not in font_mapping:
                font_mapping[font] = []
            font_mapping[font].append(text)
        
        print("[+] Font Mapping:")
        for font, chars_list in font_mapping.items():
            print(f"    {font}: {''.join(chars_list)}")
EOF
```

### Pattern 5: Whitespace Steganography

**Challenge Type**: Flag encoded in trailing whitespace or tab/space patterns

**Solution Approach**:

```python
python3 << 'EOF'
import pdfplumber

with pdfplumber.open('document.pdf') as pdf:
    text = pdf.pages[0].extract_text()
    
    lines = text.split('\n')
    binary_data = []
    
    for line in lines:
        # Check for trailing whitespace
        trailing = line[len(line.rstrip()):]
        if trailing:
            # Convert space=0, tab=1
            binary = trailing.replace(' ', '0').replace('\t', '1')
            binary_data.append(binary)
    
    # Decode binary to ASCII
    full_binary = ''.join(binary_data)
    flag = ''
    
    for i in range(0, len(full_binary), 8):
        byte = full_binary[i:i+8]
        if len(byte) == 8:
            flag += chr(int(byte, 2))
    
    print(f"[+] Decoded from whitespace: {flag}")
EOF
```

### Pattern 6: Version History Concatenation

**Challenge Type**: Flag segments spread across document revision history

**Solution Approach**:

```bash
# Extract PDF revision history
python3 << 'EOF'
with open('document.pdf', 'rb') as f:
    content = f.read()
    
    # Find all EOF markers (indicate revisions)
    import re
    eof_positions = [m.start() for m in re.finditer(b'%%EOF', content)]
    
    print(f"[+] Found {len(eof_positions)} revisions")
    
    # Extract content between revisions
    for i in range(len(eof_positions)):
        start = 0 if i == 0 else eof_positions[i-1]
        end = eof_positions[i]
        
        revision_content = content[start:end]
        # Search for flag pattern
        flag_match = re.search(b'flag\\{[^}]+\\}', revision_content)
        if flag_match:
            print(f"[+] Flag in revision {i+1}: {flag_match.group().decode()}")
EOF
```

---

## Complete CTF Document Intelligence Workflow

```bash
#!/bin/bash

DOCUMENT="$1"

if [ -z "$DOCUMENT" ]; then
    echo "Usage: $0 <document_file>"
    exit 1
fi

echo "========================================="
echo "CTF Document Intelligence Analysis"
echo "========================================="
echo ""

# 1. File identification
echo "[1/10] File Format Identification"
file "$DOCUMENT"
exiftool -FileType -MIMEType "$DOCUMENT"
echo ""

# 2. Comprehensive metadata extraction
echo "[2/10] Metadata Extraction"
exiftool -a -G1 "$DOCUMENT" | tee metadata.txt
echo ""

# 3. Hidden content detection
echo "[3/10] Hidden Content Detection"
if [[ "$DOCUMENT" == *.pdf ]]; then
    pdftotext "$DOCUMENT" - | head -20
fi
echo ""

# 4. Track changes extraction (DOCX)
echo "[4/10] Track Changes Analysis"
if [[ "$DOCUMENT" == *.docx ]]; then
    python3 << 'PYTHON'
import zipfile
import xml.etree.ElementTree as ET
import sys

try:
    with zipfile.ZipFile(sys.argv[1], 'r') as z:
        if 'word/document.xml' in z.namelist():
            doc = z.read('word/document.xml')
            root = ET.fromstring(doc)
            ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            
            deletions = root.findall('.//w:del', ns)
            if deletions:
                print(f"Found {len(deletions)} deletions")
            
            insertions = root.findall('.//w:ins', ns)
            if insertions:
                print(f"Found {len(insertions)} insertions")
except Exception as e:
    print(f"Error: {e}")
PYTHON
fi
echo ""

# 5. Font analysis
echo "[5/10] Font Analysis"
exiftool -FontName* "$DOCUMENT" 2>/dev/null || echo "No font data"
echo ""

# 6. Timestamp analysis
echo "[6/10] Timestamp Analysis"
echo "File system timestamps:"
ls -l "$DOCUMENT"
stat "$DOCUMENT"
echo ""

# 7. Whitespace analysis
echo "[7/10] Whitespace Steganography Check"
if [[ "$DOCUMENT" == *.txt ]] || [[ "$DOCUMENT" == *.pdf ]]; then
    cat "$DOCUMENT" | cat -A | grep -E '\$|\\t' | head -5
fi
echo ""

# 8. String extraction
echo "[8/10] String Extraction (potential flags)"
strings "$DOCUMENT" | grep -iE 'flag\{|ctf\{|key\{' || echo "No obvious flags"
echo ""

# 9. Hash analysis
echo "[9/10] File Hashing"
md5sum "$DOCUMENT"
sha256sum "$DOCUMENT"
echo ""

# 10. Summary report
echo "[10/10] Analysis Summary"
echo "Check the following for flags:"
echo "  - metadata.txt (all metadata fields)"
echo "  - Deleted text in track changes"
echo "  - Timestamp arithmetic (creation vs modification)"
echo "  - Font substitution patterns"
echo "  - Whitespace encoding"
echo "  - Embedded comments/annotations"
echo ""
echo "========================================="
echo "Analysis Complete"
echo "========================================="
```

This comprehensive framework provides immediately actionable tools for CTF document intelligence challenges, covering metadata analysis, PDF forensics, document dating, authorship attribution, format analysis, steganography detection, and complete workflow automation.

---

# Web Archives and Historical Data

## Wayback Machine Techniques

### Core Functionality

The Internet Archive's Wayback Machine (web.archive.org) captures snapshots of web pages over time, storing HTML, CSS, JavaScript, images, and other assets. Understanding its structure and API is essential for historical data recovery.

### Access Methods

**Web Interface Navigation**

```
https://web.archive.org/web/[timestamp]/[target_url]
```

Timestamp format: `YYYYMMDDhhmmss` (year, month, day, hour, minute, second)

Example:

```
https://web.archive.org/web/20150101120000/https://example.com
```

**CDX Server API** The CDX (Capture Index) API provides metadata about archived snapshots without loading full pages.

Basic query structure:

```bash
curl "https://web.archive.org/cdx/search/cdx?url=example.com&output=json"
```

Key parameters:

- `url` - Target URL (supports wildcards with `*`)
- `matchType` - `exact`, `prefix`, `host`, `domain`
- `from` / `to` - Date range (YYYYMMDD format)
- `filter` - Filter results by field (e.g., `statuscode:200`)
- `collapse` - Deduplicate by field (e.g., `timestamp:8` for daily snapshots)
- `output` - `json`, `text`, `csv`
- `limit` - Maximum results

Advanced query examples:

```bash
# Get all snapshots of a domain from 2020
curl "https://web.archive.org/cdx/search/cdx?url=example.com/*&from=20200101&to=20201231&output=json"

# Find only successful captures (200 status)
curl "https://web.archive.org/cdx/search/cdx?url=example.com&filter=statuscode:200&output=json"

# Collapse to one snapshot per day
curl "https://web.archive.org/cdx/search/cdx?url=example.com&collapse=timestamp:8&output=json"

# Search for specific file types
curl "https://web.archive.org/cdx/search/cdx?url=example.com/*.pdf&output=json"
```

**Availability API** Check if a URL is archived and get the closest snapshot:

```bash
curl "https://archive.org/wayback/available?url=example.com&timestamp=20200101"
```

### Asset Recovery Techniques

**Direct Asset Access** Archived pages include linked resources. Construct asset URLs:

```
https://web.archive.org/web/[timestamp]im_/[asset_url]
```

Modifiers:

- `im_` - Image/media assets (no Wayback toolbar)
- `js_` - JavaScript files
- `cs_` - CSS files
- `if_` - Iframe content

**Downloading Complete Snapshots**

```bash
wget --recursive --no-parent --page-requisites --convert-links \
     "https://web.archive.org/web/20200101120000/https://example.com"
```

Parameters:

- `--recursive` - Download linked pages
- `--no-parent` - Don't ascend to parent directory
- `--page-requisites` - Download CSS, images, etc.
- `--convert-links` - Convert links for offline viewing

**Extracting Snapshots Programmatically** Python with `waybackpy`:

```python
from waybackpy import WaybackMachineCDXServerAPI

url = "example.com"
user_agent = "Mozilla/5.0"
cdx = WaybackMachineCDXServerAPI(url, user_agent)

# Get all snapshots
for snapshot in cdx.snapshots():
    print(f"{snapshot.timestamp} - {snapshot.statuscode} - {snapshot.archive_url}")

# Filter by date range
snapshots = cdx.snapshots(from_date="20200101", to_date="20201231")
```

### Advanced Search Strategies

**Wildcard Subdomain Discovery**

```bash
curl "https://web.archive.org/cdx/search/cdx?url=*.example.com&matchType=domain&output=json&fl=original&collapse=urlkey"
```

**Parameter Enumeration** Find URLs with query parameters:

```bash
curl "https://web.archive.org/cdx/search/cdx?url=example.com/*&filter=original:.*\?.*&output=json"
```

**Robots.txt Historical Analysis**

```bash
curl "https://web.archive.org/cdx/search/cdx?url=example.com/robots.txt&output=json"
```

Analyze historical robots.txt to discover previously disallowed paths.

**Calendar View Analysis** The calendar interface (`https://web.archive.org/web/*/example.com`) shows capture frequency. High-frequency periods may indicate:

- Site incidents/changes
- Bot activity
- Significant events

### Rate Limiting and Best Practices

[Unverified] The Wayback Machine implements rate limiting, but exact thresholds are not publicly documented. Observed practices:

- Add delays between requests (1-2 seconds recommended)
- Use `User-Agent` headers identifying your purpose
- Consider using the SavePageNow API for intentional archiving

**SavePageNow API** (for creating new captures):

```bash
curl -X POST -H "Accept: application/json" \
     -H "Authorization: LOW [access_key]:[secret_key]" \
     -d "url=https://example.com" \
     "https://web.archive.org/save/"
```

## Archive.today Usage

### Platform Overview

Archive.today (also known as archive.is, archive.ph, archive.fo due to domain variations) is a time capsule service that creates on-demand snapshots of web pages. Unlike Wayback Machine, it captures pages immediately upon request and preserves exact visual rendering.

### Core Access Methods

**Creating Archives** Submit URLs via the web interface:

```
https://archive.ph/
```

Programmatic submission:

```bash
curl -d "url=https://example.com" https://archive.ph/submit/
```

The response includes the archive URL in the `Location` header.

**Search Interface**

```
https://archive.ph/[domain]
```

Example: `https://archive.ph/example.com`

This returns all snapshots for the domain in reverse chronological order.

**Direct Snapshot Access** Archives use short IDs:

```
https://archive.ph/[shortID]
```

Example: `https://archive.ph/a1B2c`

### Advanced Techniques

**Bypassing Paywalls and Login Walls** Archive.today often captures full page content before JavaScript restrictions load. This can expose:

- Paywalled article content
- Login-restricted pages
- Region-locked content

[Inference] This occurs because the archive captures the initial HTML response before client-side restrictions execute.

**Screenshot Analysis** Archive.today stores full-page screenshots as PNG images. Access directly:

```
https://archive.ph/[shortID]/image
```

Useful for:

- Visual diff analysis
- Capturing JavaScript-rendered content
- Preserving dynamic layouts

**Source Code Preservation** The raw HTML is preserved without modification. Access via:

```
https://archive.ph/[shortID]/again?run=1
```

### API and Automation

**Checking for Existing Archives**

```bash
curl -s "https://archive.ph/timemap/*/example.com" | grep -oP '(?<=<).*?(?=>)'
```

**Batch Archiving Script**

```bash
#!/bin/bash
while IFS= read -r url; do
    curl -s -d "url=$url" https://archive.ph/submit/ -D - | grep -i location
    sleep 2
done < urls.txt
```

**Python Implementation**

```python
import requests

def archive_url(url):
    response = requests.post('https://archive.ph/submit/', data={'url': url}, allow_redirects=False)
    if 'Location' in response.headers:
        return response.headers['Location']
    return None

archive_link = archive_url('https://example.com')
print(f"Archived at: {archive_link}")
```

### Domain Rotation

Archive.today operates across multiple TLDs to avoid blocking:

- archive.ph (primary)
- archive.is
- archive.fo
- archive.today
- archive.vn

All point to the same archive database but may have different availability in various regions.

## Historical Website Analysis

### Comparative Snapshot Analysis

**Diff Generation** Use `diff` or specialized tools to compare snapshots:

```bash
# Download two versions
wget -O version1.html "https://web.archive.org/web/20200101/https://example.com"
wget -O version2.html "https://web.archive.org/web/20210101/https://example.com"

# Generate diff
diff -u version1.html version2.html > changes.diff

# Or use git diff for better formatting
git diff --no-index --word-diff version1.html version2.html
```

**HTML Parsing with Beautiful Soup**

```python
from bs4 import BeautifulSoup
import requests

def get_archived_content(url, timestamp):
    archive_url = f"https://web.archive.org/web/{timestamp}/{url}"
    response = requests.get(archive_url)
    return BeautifulSoup(response.content, 'html.parser')

old_soup = get_archived_content('example.com', '20200101')
new_soup = get_archived_content('example.com', '20210101')

# Extract specific elements
old_emails = [a['href'] for a in old_soup.find_all('a', href=True) if 'mailto:' in a['href']]
new_emails = [a['href'] for a in new_soup.find_all('a', href=True) if 'mailto:' in a['href']]

# Find added emails
added = set(new_emails) - set(old_emails)
```

### Metadata Extraction

**Email Address Discovery**

```bash
# Extract from archived page
curl -s "https://web.archive.org/web/20200101/https://example.com" | \
grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
```

**Phone Number Extraction**

```bash
curl -s "https://web.archive.org/web/20200101/https://example.com" | \
grep -Eo '(\+?[0-9]{1,3}[-.]?)?\(?[0-9]{3}\)?[-.]?[0-9]{3}[-.]?[0-9]{4}'
```

**Comment Analysis**

```python
import re
from bs4 import BeautifulSoup, Comment

soup = get_archived_content('example.com', '20200101')
comments = soup.find_all(string=lambda text: isinstance(text, Comment))

for comment in comments:
    print(f"HTML Comment: {comment}")
    # Look for developer notes, credentials, API keys
    if any(keyword in comment.lower() for keyword in ['todo', 'fixme', 'password', 'key', 'token']):
        print(f"[!] Interesting comment: {comment}")
```

### Technology Stack Evolution

**Framework Detection**

```bash
# Check historical technology usage
curl -s "https://web.archive.org/web/20150101/https://example.com" | \
grep -i -E '(jquery|angular|react|vue|bootstrap|wordpress|drupal)'
```

**Server Header History**

```python
import requests

def get_server_headers(url, timestamp):
    archive_url = f"https://web.archive.org/web/{timestamp}id_/{url}"
    response = requests.get(archive_url)
    return response.headers.get('X-Archive-Orig-Server', 'Unknown')

# Check server evolution
timestamps = ['20150101', '20160101', '20170101', '20180101', '20190101', '20200101']
for ts in timestamps:
    server = get_server_headers('example.com', ts)
    print(f"{ts}: {server}")
```

### JavaScript Analysis

**Extracting Historical JS Files**

```bash
# Find all JS files from a snapshot
curl -s "https://web.archive.org/cdx/search/cdx?url=example.com/*.js&from=20200101&to=20201231&output=json" | \
jq -r '.[] | select(.[0] != "urlkey") | "https://web.archive.org/web/" + .[1] + "js_/" + .[2]'
```

**API Endpoint Discovery**

```bash
# Download old JS file
wget -O app.js "https://web.archive.org/web/20200101js_/https://example.com/static/app.js"

# Search for API endpoints
grep -Eo '(/api/[a-zA-Z0-9/_-]+|https?://[^"'\'']+/api/[^"'\'']+)' app.js | sort -u
```

### Social Media Profile Evolution

**Archived Social Links**

```python
def extract_social_profiles(url, timestamp):
    soup = get_archived_content(url, timestamp)
    social_patterns = {
        'twitter': r'twitter\.com/([a-zA-Z0-9_]+)',
        'facebook': r'facebook\.com/([a-zA-Z0-9.]+)',
        'linkedin': r'linkedin\.com/(in|company)/([a-zA-Z0-9-]+)',
        'github': r'github\.com/([a-zA-Z0-9-]+)',
        'instagram': r'instagram\.com/([a-zA-Z0-9_.]+)'
    }
    
    profiles = {}
    html = str(soup)
    for platform, pattern in social_patterns.items():
        matches = re.findall(pattern, html)
        if matches:
            profiles[platform] = matches
    return profiles
```

## Cached Content Recovery

### Google Cache

**Access Methods** Direct URL structure:

```
https://webcache.googleusercontent.com/search?q=cache:[URL]
```

Example:

```
https://webcache.googleusercontent.com/search?q=cache:example.com
```

**Text-only Version**

```
https://webcache.googleusercontent.com/search?q=cache:[URL]&strip=1
```

**Google Search Operators**

```
cache:example.com/specific-page
```

### Bing Cache

**Access Structure** Less documented than Google, but accessible via:

```
https://cc.bingj.com/cache.aspx?q=[URL]&d=[ID]
```

[Unverified] The ID parameter is dynamically generated and not easily predictable.

### Browser Cache Forensics

**Firefox Cache Location**

```bash
# Linux/Mac
~/.mozilla/firefox/[profile]/cache2/entries/

# Windows
%APPDATA%\Mozilla\Firefox\Profiles\[profile]\cache2\entries\
```

**Chrome Cache Location**

```bash
# Linux
~/.cache/google-chrome/Default/Cache/

# Mac
~/Library/Caches/Google/Chrome/Default/Cache/

# Windows
%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\
```

**Cache Extraction Tools**

ChromeCacheView (Windows):

```bash
# Command-line export
ChromeCacheView.exe /shtml cache_report.html
```

Firefox Cache Viewer:

```bash
# Use about:cache in Firefox to view entries
firefox about:cache
```

### DNS Cache Analysis

**Windows DNS Cache**

```bash
ipconfig /displaydns > dns_cache.txt
```

**Linux DNS Cache (systemd-resolved)**

```bash
sudo systemd-resolve --statistics
sudo systemd-resolve --flush-caches
```

**macOS DNS Cache**

```bash
sudo dscacheutil -cachedump -entries Host
```

### Proxy and CDN Caches

**Cloudflare Cache** Append query parameters to bypass or force cache:

```bash
# Force fresh content
curl "https://example.com/?nocache=$(date +%s)"

# Check cache status
curl -I "https://example.com" | grep -i cf-cache-status
```

Cache status values:

- `HIT` - Served from cache
- `MISS` - Not in cache
- `EXPIRED` - Was cached but expired
- `BYPASS` - Cache bypassed

**Purging CDN Caches** [Inference] Some CDN configurations allow cache purging via specific headers or query parameters, but this varies by provider and is often restricted.

### Search Engine Caches

**Yandex Cache**

```
https://yandex.com/cached?url=[URL]
```

**Memento Framework** Memento aggregates multiple archives:

```bash
curl -L "http://timetravel.mementoweb.org/memento/20200101120000/https://example.com"
```

**Memento Time Map**

```bash
curl "http://timetravel.mementoweb.org/timemap/link/https://example.com"
```

Returns RFC 7089 formatted list of available mementos across multiple archives.

## Timeline Reconstruction

### Event Timeline Building

**Automated Snapshot Collection**

```python
import requests
import json
from datetime import datetime

def build_timeline(url, start_year, end_year):
    timeline = []
    
    for year in range(start_year, end_year + 1):
        cdx_url = f"https://web.archive.org/cdx/search/cdx?url={url}&from={year}0101&to={year}1231&output=json&collapse=timestamp:8"
        response = requests.get(cdx_url)
        
        if response.status_code == 200:
            data = json.loads(response.text)
            for entry in data[1:]:  # Skip header
                timeline.append({
                    'timestamp': entry[1],
                    'status': entry[4],
                    'url': f"https://web.archive.org/web/{entry[1]}/{entry[2]}"
                })
    
    return timeline

timeline = build_timeline('example.com', 2015, 2024)

# Sort by timestamp
timeline.sort(key=lambda x: x['timestamp'])

for event in timeline:
    dt = datetime.strptime(event['timestamp'], '%Y%m%d%H%M%S')
    print(f"{dt.strftime('%Y-%m-%d %H:%M:%S')} - Status {event['status']} - {event['url']}")
```

### Change Detection System

**Content Hash Tracking**

```python
import hashlib
import requests

def get_page_hash(url, timestamp):
    archive_url = f"https://web.archive.org/web/{timestamp}id_/{url}"
    response = requests.get(archive_url)
    return hashlib.sha256(response.content).hexdigest()

# Track changes over time
timestamps = ['20200101', '20200201', '20200301', '20200401']
previous_hash = None

for ts in timestamps:
    current_hash = get_page_hash('example.com', ts)
    if previous_hash and current_hash != previous_hash:
        print(f"[!] Change detected at {ts}")
    previous_hash = current_hash
```

### Visual Timeline Generation

**Graphing with Matplotlib**

```python
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from datetime import datetime

def plot_capture_frequency(url, start_year, end_year):
    timeline = build_timeline(url, start_year, end_year)
    
    dates = [datetime.strptime(t['timestamp'], '%Y%m%d%H%M%S') for t in timeline]
    
    plt.figure(figsize=(15, 6))
    plt.hist(dates, bins=50, edgecolor='black')
    plt.xlabel('Date')
    plt.ylabel('Number of Captures')
    plt.title(f'Archive Capture Frequency for {url}')
    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('capture_timeline.png')

plot_capture_frequency('example.com', 2015, 2024)
```

### Cross-Archive Correlation

**Comparing Multiple Archives**

```python
def get_all_archives(url):
    sources = {
        'wayback': [],
        'archive_today': []
    }
    
    # Wayback Machine
    wb_response = requests.get(f"https://web.archive.org/cdx/search/cdx?url={url}&output=json")
    if wb_response.status_code == 200:
        data = json.loads(wb_response.text)
        sources['wayback'] = [entry[1] for entry in data[1:]]
    
    # Archive.today (scrape search results)
    at_response = requests.get(f"https://archive.ph/{url}")
    # Parse HTML to extract archive dates
    # [Implementation depends on current page structure]
    
    return sources

archives = get_all_archives('example.com')
print(f"Wayback snapshots: {len(archives['wayback'])}")
print(f"Archive.today snapshots: {len(archives['archive_today'])}")
```

### Incident Investigation Timeline

**Security Breach Analysis** When investigating compromised sites:

1. **Identify infection point**

```python
def find_malicious_injection(url, start_timestamp, end_timestamp):
    # Binary search through snapshots
    mid = (int(start_timestamp) + int(end_timestamp)) // 2
    mid_str = str(mid).ljust(14, '0')
    
    # Check for malicious indicators
    response = requests.get(f"https://web.archive.org/web/{mid_str}/{url}")
    
    if contains_malicious_content(response.text):
        # Check earlier
        return find_malicious_injection(url, start_timestamp, mid_str)
    else:
        # Check later
        if mid_str == end_timestamp:
            return mid_str
        return find_malicious_injection(url, mid_str, end_timestamp)
```

2. **Extract malicious payloads**
3. **Track payload evolution**
4. **Correlate with threat intelligence**

### Content Modification Tracking

**Database Leak Detection** Monitor for appearance of sensitive data:

```bash
# Search across time for email patterns
for year in {2015..2024}; do
    echo "Checking $year..."
    curl -s "https://web.archive.org/cdx/search/cdx?url=example.com&from=${year}0101&to=${year}1231&output=json" | \
    jq -r '.[] | select(.[0] != "urlkey") | "https://web.archive.org/web/" + .[1] + "/" + .[2]' | \
    while read archive_url; do
        if curl -s "$archive_url" | grep -q 'admin@internal-domain.com'; then
            echo "[!] Potential leak found: $archive_url"
        fi
    done
done
```

### Temporal OSINT Synthesis

Combine multiple temporal data sources:

- Archive snapshots
- DNS history (SecurityTrails, DNSDumpster)
- WHOIS history
- SSL certificate transparency logs
- Git commit history (if repos discoverable)
- Social media post timestamps

**Integrated Timeline Script**

```python
def create_comprehensive_timeline(domain):
    timeline_events = []
    
    # Add archive events
    timeline_events.extend(get_archive_events(domain))
    
    # Add DNS changes
    timeline_events.extend(get_dns_changes(domain))
    
    # Add WHOIS changes
    timeline_events.extend(get_whois_history(domain))
    
    # Add SSL certificate events
    timeline_events.extend(get_cert_transparency_logs(domain))
    
    # Sort by timestamp
    timeline_events.sort(key=lambda x: x['timestamp'])
    
    return timeline_events
```

---

**Important Related Topics:**

- Google Dorking and advanced search operators (complements cached content discovery)
- Metadata extraction from documents (often found in archived files)
- Automated reconnaissance frameworks (for integrating archive searches into broader OSINT workflows)

---

# Dark Web and Hidden Services

## Tor Network Basics

### Architecture and Protocol

The Tor (The Onion Router) network provides anonymity through a three-layer relay system:

**Circuit Construction:**

- Client selects entry/guard node, middle relay, and exit node
- Each layer encrypted with respective node's public key
- Traffic routed through 3+ relays by default
- Circuit lifetime typically 10 minutes before rotation

**Key Components:**

- **Directory Authorities**: 9 hardcoded servers maintaining network consensus
- **Relay Nodes**: ~6,000+ volunteer-operated servers forwarding traffic
- **Bridge Nodes**: Unlisted entry points for censorship circumvention
- **Hidden Services**: .onion addresses accessible only within Tor

**Traffic Encapsulation:**

```
[Application Data] 
→ Encrypted with Exit Key
→ Encrypted with Middle Key  
→ Encrypted with Guard Key
→ Sent to Guard Node
```

### Tor Browser Bundle Setup

**Installation (Linux):**

```bash
# Download and verify
wget https://www.torproject.org/dist/torbrowser/[VERSION]/tor-browser-linux64-[VERSION]_en-US.tar.xz
wget https://www.torproject.org/dist/torbrowser/[VERSION]/tor-browser-linux64-[VERSION]_en-US.tar.xz.asc

# Import Tor signing key
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org

# Verify signature
gpg --verify tor-browser-*.asc tor-browser-*.tar.xz

# Extract
tar -xf tor-browser-*.tar.xz
cd tor-browser_en-US
./start-tor-browser.desktop
```

**Security Levels:**

- **Standard**: JavaScript enabled, some fingerprinting protection
- **Safer**: JavaScript disabled on non-HTTPS sites, some fonts/symbols disabled
- **Safest**: JavaScript disabled globally, all media click-to-play

**Critical Configuration:**

```
about:config modifications:
- network.proxy.socks_remote_dns = true (prevent DNS leaks)
- media.peerconnection.enabled = false (disable WebRTC)
- privacy.resistFingerprinting = true (standardize browser fingerprint)
```

### Command-Line Tor Configuration

**torrc Configuration:**

```bash
# /etc/tor/torrc or ~/.torrc

# SOCKS proxy
SOCKSPort 9050

# Control port (for automation)
ControlPort 9051
HashedControlPassword [use 'tor --hash-password yourpassword']

# Circuit preferences
ExitNodes {us},{ca},{gb}
StrictNodes 1

# Bridge configuration (for censored networks)
UseBridges 1
Bridge obfs4 [IP:PORT] [FINGERPRINT] cert=[CERT] iat-mode=0

# Hidden service hosting
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:8080
```

**Start Tor service:**

```bash
sudo systemctl start tor
sudo systemctl enable tor

# Verify connection
curl --socks5-hostname localhost:9050 https://check.torproject.org/api/ip
```

### Proxychains Integration

**Configuration (/etc/proxychains4.conf):**

```bash
# Dynamic chain (tries all proxies, skips dead ones)
dynamic_chain

# Proxy DNS requests
proxy_dns

# Proxy list
[ProxyList]
socks5 127.0.0.1 9050
```

**Usage:**

```bash
proxychains4 nmap -sT -Pn target.onion
proxychains4 curl http://example.onion
proxychains4 firefox
```

### Torsocks (Transparent Torification)

```bash
# Install
sudo apt install torsocks

# Route application through Tor
torsocks wget http://example.onion/file.txt
torsocks ssh user@target.onion

# Test isolation
torsocks curl https://check.torproject.org/api/ip
```

### Circuit Control and Monitoring

**Nyx (formerly arm) - Terminal Monitor:**

```bash
sudo apt install nyx
nyx

# View connections, bandwidth, circuit information
# Keyboard shortcuts:
# - 'e' for event log
# - 'c' for connections
# - 'b' for bandwidth graph
```

**Manual Circuit Control (Python):**

```python
from stem import Signal
from stem.control import Controller

with Controller.from_port(port=9051) as controller:
    controller.authenticate(password='yourpassword')
    
    # Force new circuit
    controller.signal(Signal.NEWNYM)
    
    # Get current circuit
    for circ in controller.get_circuits():
        print(f"Circuit {circ.id}: {circ.path}")
```

### Onion Service Architecture

**V3 Onion Address Structure:**

- 56-character base32 encoded address
- Format: `[56 chars].onion`
- Derived from ed25519 public key
- Provides end-to-end encryption

**Descriptor Publication:**

1. Service generates key pair and descriptor
2. Descriptor uploaded to Distributed Hash Table (DHT)
3. Descriptor includes introduction points (3-10 rendezvous nodes)
4. Client retrieves descriptor from DHT
5. Client establishes circuit through introduction point

**Creating Hidden Service:**

```bash
# Configure torrc
HiddenServiceDir /var/lib/tor/myservice/
HiddenServicePort 80 127.0.0.1:8080

# Restart Tor
sudo systemctl restart tor

# Get onion address
sudo cat /var/lib/tor/myservice/hostname
```

**Advanced Options:**

```bash
# Client authorization (v3)
HiddenServiceDir /var/lib/tor/auth_service/
HiddenServicePort 80 127.0.0.1:8080
HiddenServiceAuthorizeClient stealth client1,client2

# Custom vanity address (using mkp224o)
./mkp224o prefix -d /var/lib/tor/vanity/ -n 1
```

---

## .onion Site Discovery

### Direct Discovery Methods

**Link Aggregation Sites:**

- Hidden Wiki variants (multiple mirrors exist)
- Ahmia.fi link collections
- TorLinks (frequently updated directory)
- OnionTree (categorized listings)

[Unverified] - These directories often contain dead links and may include malicious sites.

### Search-Based Discovery

**Ahmia.fi Integration:**

```bash
# API search
curl "https://ahmia.fi/search/?q=keyword"

# Onion service check
curl "https://ahmia.fi/address/[onion-address]/"
```

**OnionScan - OSINT Tool:**

```bash
# Install
git clone https://github.com/s-rah/onionscan.git
cd onionscan
go install

# Basic scan
onionscan --verbose [onion-address]

# Save report
onionscan --jsonReport --reportFile=scan_results.json [onion-address]

# Scan multiple services
for onion in $(cat onion_list.txt); do
    onionscan --verbose --jsonReport --reportFile="${onion}.json" "$onion"
done
```

**Key OnionScan Findings:**

- Apache/Nginx version information
- SSH fingerprints
- Bitcoin addresses
- PGP keys
- Email addresses
- IP address leaks (misconfigured servers)
- Related clearnet sites

### Crawling and Spidering

**OnionIngestor (Automated Collection):**

```bash
# Clone
git clone https://github.com/danieleperera/OnionIngestor.git
cd OnionIngestor

# Configure operators.yaml
databases:
  - module: onioningestor.databases.simple_db
    filename: onions.db

sources:
  - module: onioningestor.sources.simple_web
    urls:
      - "http://exampleindex.onion/links"

# Run
pip3 install -r requirements.txt
python3 ingestor.py operators.yaml
```

**TorBot (Python Crawler):**

```bash
git clone https://github.com/DedSecInside/TorBot.git
cd TorBot
pip3 install -r requirements.txt

# Crawl site
python3 torbot.py -u http://example.onion --depth 2 --save output.json

# Extract emails
python3 torbot.py -u http://example.onion --mail
```

**Custom Python Crawler:**

```python
import requests
from bs4 import BeautifulSoup
import re

session = requests.session()
session.proxies = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def crawl_onion(url, depth=2, visited=None):
    if visited is None:
        visited = set()
    
    if url in visited or depth == 0:
        return visited
    
    visited.add(url)
    
    try:
        response = session.get(url, timeout=30)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract .onion links
        onion_pattern = re.compile(r'[a-z2-7]{56}\.onion')
        for link in soup.find_all('a', href=True):
            href = link['href']
            if '.onion' in href:
                # Normalize URL
                if href.startswith('http'):
                    next_url = href
                else:
                    next_url = url.rstrip('/') + '/' + href.lstrip('/')
                
                crawl_onion(next_url, depth-1, visited)
                
    except Exception as e:
        print(f"Error crawling {url}: {e}")
    
    return visited

discovered = crawl_onion('http://starting-onion.onion/', depth=3)
```

### Passive Discovery Techniques

**Monitoring Public Leak Forums:**

- Pastebin/paste site searches for ".onion"
- GitHub repository searches
- Dark web forum archives (Dread, Hidden Answers mirrors)

**DNS Seeding:**

```bash
# Extract onion addresses from Tor directory authorities
# [Inference] This technique analyzes consensus documents

# Query OnionBalance descriptors
curl --socks5-hostname 127.0.0.1:9050 \
  http://[descriptor-service].onion/tor/status-vote/current/consensus
```

**Certificate Transparency Logs:** [Inference] While .onion sites don't typically use CT logs, misconfigured services may leak information through clearnet certificates.

### Specialized Discovery Tools

**Darkdump (OSINT Framework):**

```bash
git clone https://github.com/josh0xA/darkdump.git
cd darkdump
pip3 install -r requirements.txt

# Search across dark web
python3 darkdump.py --query "keyword" --amount 50
```

**Katana (Web Crawler):**

```bash
# Install
go install github.com/projectdiscovery/katana/cmd/katana@latest

# Crawl with Tor proxy
katana -u http://example.onion -proxy socks5://127.0.0.1:9050 -depth 3 -jc -o output.txt
```

### Monitoring Service Availability

**Onion Availability Checker Script:**

```bash
#!/bin/bash
# check_onions.sh

ONION_LIST="onions.txt"
SOCKS_PROXY="socks5h://127.0.0.1:9050"

while IFS= read -r onion; do
    echo "Checking: $onion"
    
    status=$(curl -x "$SOCKS_PROXY" \
                  --max-time 30 \
                  --silent \
                  --output /dev/null \
                  --write-out "%{http_code}" \
                  "http://${onion}/")
    
    if [ "$status" -eq 200 ]; then
        echo "[+] $onion - ONLINE (HTTP $status)"
    else
        echo "[-] $onion - OFFLINE or ERROR (HTTP $status)"
    fi
    
    sleep 5  # Rate limiting
done < "$ONION_LIST"
```

---

## Dark Web Search Engines

### Primary Search Engines

**Ahmia (.fi)**

- **Clearnet Access**: https://ahmia.fi
- **Onion Access**: [Inference] Ahmia maintains an onion mirror
- **Features**:
    - Blacklist filtering (removes illegal content)
    - API access for automation
    - Advanced search operators
    - Site monitoring status

**Search Syntax:**

```bash
# Direct API query
curl "https://ahmia.fi/search/?q=site:specific.onion+keyword"

# JSON response parsing
curl -s "https://ahmia.fi/search/?q=ctf" | jq '.results[] | {title, url}'
```

**Torch**

- Largest onion search index (claims 1M+ indexed pages)
- No content filtering
- [Unverified] Claims of index size vary

**Access via Tor:**

```bash
torsocks curl http://torch[address].onion/search?query=keyword&action=search
```

**Haystak**

- Focuses on index freshness
- Tiered search (free vs premium)
- Advanced filtering options

**DuckDuckGo Onion**

- Privacy-focused
- Limited dark web indexing compared to specialized engines
- No search history retention

### Meta-Search Strategies

**Combining Multiple Engines:**

```python
import requests
from bs4 import BeautifulSoup

PROXIES = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def search_ahmia(query):
    url = f"https://ahmia.fi/search/?q={query}"
    response = requests.get(url, proxies=PROXIES)
    # Parse results
    soup = BeautifulSoup(response.content, 'html.parser')
    return [a['href'] for a in soup.find_all('a', href=True) if '.onion' in a['href']]

def search_torch(query):
    url = f"http://torch[address].onion/search?query={query}"
    response = requests.get(url, proxies=PROXIES, timeout=60)
    # Parse results
    soup = BeautifulSoup(response.content, 'html.parser')
    return [a['href'] for a in soup.find_all('a', href=True) if '.onion' in a['href']]

def aggregate_searches(query):
    results = set()
    results.update(search_ahmia(query))
    results.update(search_torch(query))
    return list(results)
```

### Specialized Search Tools

**Dark Web OSINT Tools:**

**Shodan Integration:**

```bash
# Search for Tor exit nodes
shodan search "product:Tor"

# Find misconfigured onion services exposing clearnet IPs
shodan search "onion-location header"
```

**Grep.app for Code Search:**

```bash
# Search GitHub for .onion references
# Manual: https://grep.app/search?q=.onion&filter[lang][0]=Python

# Find configuration files with Tor references
curl "https://grep.app/api/search?q=SOCKSPort+9050"
```

### Advanced Search Techniques

**Boolean Operators:**

```
"exact phrase" - Exact match
keyword1 AND keyword2 - Both terms required
keyword1 OR keyword2 - Either term
-excluded - Exclude term
site:specific.onion - Restrict to domain
```

**Temporal Analysis:**

- Most dark web search engines lack date filtering
- [Inference] Wayback Machine integration for .onion sites is limited

**Content Type Filtering:**

```bash
# Search for specific file types
filetype:pdf site:.onion
filetype:txt site:.onion

# Document intelligence gathering
inurl:docs site:.onion
inurl:files site:.onion
```

### Search Engine Limitations

**Coverage Gaps:**

- [Unverified] Most search engines index <30% of active .onion services
- Private/authenticated sites not indexed
- Ephemeral markets frequently change domains

**Anti-Crawling Measures:**

- CAPTCHA protection
- Rate limiting
- JavaScript rendering requirements
- Invite-only access

### Alternative Discovery Methods

**Forum and Market Monitoring:**

- Dread (Reddit-like forum on Tor)
- Dark.fail (verified market links)
- Recon (market verification service)

[Unverified] - Market link verification services may be compromised or operated by law enforcement.

**RSS Feed Aggregation:**

```bash
# Monitor dark web news aggregators
curl --socks5-hostname 127.0.0.1:9050 http://newsite.onion/rss.xml \
  | xmllint --xpath "//item/link/text()" -
```

---

## Paste Site Monitoring

### Target Paste Sites

**Primary Services:**

- Pastebin.com (clearnet)
- Ghostbin, Privatebin (privacy-focused)
- Stronghold Paste, Deep Paste (Tor-based)
- Rentry.co, Disroot Paste (clearnet alternatives)

**Tor-Based Paste Sites:**

- ZeroBin variants on .onion
- Text hosting on image boards (8chan successors)

### Automated Monitoring Tools

**PasteHunter:**

```bash
git clone https://github.com/kevthehermit/PasteHunter.git
cd PasteHunter

# Configure pastehunter.ini
[Inputs]
pastebin_api_key = YOUR_API_KEY

[Outputs]
enable_json = True
json_output_dir = /var/log/pastehunter/

# Install dependencies
pip3 install -r requirements.txt

# Run
python3 pastehunter.py
```

**YARA Rule Integration:**

```yara
rule Credential_Leak {
    meta:
        description = "Detects potential credential leaks"
    strings:
        $api_key = /[A-Za-z0-9]{32,64}/ nocase
        $aws = /AKIA[0-9A-Z]{16}/ nocase
        $private_key = "BEGIN RSA PRIVATE KEY"
        $password = /password\s*[:=]\s*\S+/ nocase
    condition:
        any of them
}

rule Onion_Address {
    strings:
        $onion = /[a-z2-7]{56}\.onion/ nocase
    condition:
        $onion
}
```

**Pastebin Scraper (Python):**

```python
import requests
import time
import re

API_KEY = "your_pastebin_api_key"
SOCKS_PROXY = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def get_recent_pastes():
    url = f"https://pastebin.com/api/api_post.php"
    params = {
        'api_dev_key': API_KEY,
        'api_option': 'list',
        'api_results_limit': '100'
    }
    response = requests.post(url, data=params)
    return response.text

def scrape_paste_content(paste_key):
    url = f"https://pastebin.com/raw/{paste_key}"
    response = requests.get(url)
    return response.text

def find_onions(text):
    pattern = r'[a-z2-7]{56}\.onion'
    return re.findall(pattern, text, re.IGNORECASE)

def find_credentials(text):
    patterns = {
        'email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
        'aws_key': r'AKIA[0-9A-Z]{16}',
        'private_key': r'-----BEGIN (?:RSA|EC|OPENSSH) PRIVATE KEY-----',
        'api_token': r'[A-Za-z0-9_-]{32,64}'
    }
    findings = {}
    for name, pattern in patterns.items():
        findings[name] = re.findall(pattern, text)
    return findings

# Monitor loop
while True:
    pastes = get_recent_pastes()
    # Parse and process
    time.sleep(60)  # API rate limiting
```

### Specialized Paste Monitors

**Dumpmon:**

```bash
git clone https://github.com/jordan-wright/dumpmon.git
cd dumpmon

# Configure config.json
{
  "pastebin_api_key": "YOUR_KEY",
  "search_patterns": [
    {"pattern": "\\.onion", "description": "Onion addresses"},
    {"pattern": "password", "description": "Password mentions"}
  ]
}

# Run
python dumpmon.py
```

**F-Scrack (Forum Scraper):**

```bash
# For dark web forum monitoring
git clone https://github.com/dchrastil/F-Scrack.git
cd F-Scrack

# Configure targets in config.yml
python3 f-scrack.py --forum dread --search "leak"
```

### Keyword Alert System

**Creating Custom Alerts:**

```bash
#!/bin/bash
# paste_monitor.sh

KEYWORDS="company_name|confidential|internal|.onion|ctf{|flag{"
OUTPUT_DIR="./alerts"
mkdir -p "$OUTPUT_DIR"

# Fetch recent pastes
curl -s "https://pastebin.com/api_scraping.php?limit=250" > recent.json

# Search for keywords
jq -r '.[] | .key' recent.json | while read paste_key; do
    content=$(curl -s "https://pastebin.com/raw/$paste_key")
    
    if echo "$content" | grep -qiE "$KEYWORDS"; then
        echo "[!] Match found in paste: $paste_key"
        echo "$content" > "$OUTPUT_DIR/${paste_key}.txt"
    fi
    
    sleep 1
done
```

### Tor Paste Site Monitoring

**Stronghold Paste Scraper:**

```python
import requests
from bs4 import BeautifulSoup

PROXIES = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def scrape_stronghold():
    url = "http://strongholdpaste.onion/recent"  # [Inference] Example URL
    response = requests.get(url, proxies=PROXIES, timeout=60)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    pastes = []
    for link in soup.find_all('a', href=True):
        if '/view/' in link['href']:
            paste_url = f"http://strongholdpaste.onion{link['href']}"
            pastes.append(paste_url)
    
    return pastes

def download_paste(url):
    response = requests.get(url, proxies=PROXIES, timeout=60)
    soup = BeautifulSoup(response.content, 'html.parser')
    content = soup.find('pre') or soup.find('div', class_='content')
    return content.text if content else ""
```

### Data Breach Aggregation

**Monitoring for Leaked Databases:**

**HaveIBeenPwned API Integration:**

```bash
# Check if email appeared in breaches
curl "https://haveibeenpwned.com/api/v3/breachedaccount/test@example.com" \
  -H "hibp-api-key: YOUR_API_KEY"

# Check for paste appearances
curl "https://haveibeenpwned.com/api/v3/pasteaccount/test@example.com" \
  -H "hibp-api-key: YOUR_API_KEY"
```

**DeHashed CLI:**

```bash
# Search leaked databases
dehashed -u username -p password -q "example.com"
dehashed -u username -p password -q "email:admin@target.com"
```

### Retention and Archival

**Automated Archiving:**

```python
import hashlib
import sqlite3
from datetime import datetime

def store_paste(content, source, keywords_found):
    conn = sqlite3.connect('paste_archive.db')
    cursor = conn.cursor()
    
    content_hash = hashlib.sha256(content.encode()).hexdigest()
    timestamp = datetime.now().isoformat()
    
    cursor.execute('''
        INSERT OR IGNORE INTO pastes 
        (hash, content, source, keywords, timestamp)
        VALUES (?, ?, ?, ?, ?)
    ''', (content_hash, content, source, keywords_found, timestamp))
    
    conn.commit()
    conn.close()

# Schema creation
def init_db():
    conn = sqlite3.connect('paste_archive.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS pastes (
            hash TEXT PRIMARY KEY,
            content TEXT,
            source TEXT,
            keywords TEXT,
            timestamp TEXT
        )
    ''')
    conn.commit()
    conn.close()
```

---

## Anonymous Communication Analysis

### Traffic Analysis Fundamentals

**Tor Traffic Characteristics:**

**Packet Size Analysis:**

- Tor cells are fixed 512-byte units
- TLS record layer adds overhead
- Identifiable patterns in cell sequences

**Timing Analysis:**

```python
from scapy.all import *

def analyze_tor_timing(pcap_file):
    packets = rdpcap(pcap_file)
    
    tor_packets = [p for p in packets if p.haslayer(TCP) and 
                   (p[TCP].dport == 9001 or p[TCP].sport == 9001)]
    
    inter_arrival_times = []
    for i in range(1, len(tor_packets)):
        time_delta = float(tor_packets[i].time - tor_packets[i-1].time)
        inter_arrival_times.append(time_delta)
    
    return inter_arrival_times
```

**[Inference] Correlation Attacks:**

- Entry and exit node traffic timing correlation
- Requires adversary controlling multiple network points
- Statistical analysis of packet timing/volume

### Website Fingerprinting

**Traffic Pattern Recognition:**

**DF (Deep Fingerprinting) Technique:** [Inference] Uses machine learning to classify encrypted Tor traffic based on:

- Packet size sequences
- Burst patterns
- Direction (incoming/outgoing) patterns
- Total bandwidth characteristics

**Countermeasure Detection:**

```bash
# Check if website fingerprinting defenses are active
# Look for traffic padding, dummy packets

tcpdump -i any -n 'tcp port 9001' -w tor_traffic.pcap

# Analyze with tshark
tshark -r tor_traffic.pcap -T fields \
  -e frame.time_relative \
  -e ip.src \
  -e ip.dst \
  -e frame.len \
  -E header=y > traffic_analysis.csv
```

### Metadata Leakage Detection

**Common Metadata Sources:**

**HTTP Headers:**

```python
import requests

proxies = {
    'http': 'socks5h://127.0.0.1:9050',
    'https': 'socks5h://127.0.0.1:9050'
}

def check_headers(url):
    response = requests.get(url, proxies=proxies)
    
    leaky_headers = [
        'X-Forwarded-For',
        'X-Real-IP',
        'Via',
        'X-Originating-IP',
        'Forwarded',
        'CF-Connecting-IP'
    ]
    
    for header in leaky_headers:
        if header in response.headers:
            print(f"[!] Potential leak: {header}: {response.headers[header]}")
```

**DNS Leakage:**

```bash
# Test for DNS leaks
torsocks nslookup example.com

# Should resolve through Tor, not local DNS
# Verify with:
curl --socks5-hostname 127.0.0.1:9050 https://ipleak.net/

# Monitor DNS traffic
sudo tcpdump -i any port 53 -n
# Should show no DNS requests when using Tor properly
```

**WebRTC Leaks:**

```javascript
// JavaScript to detect WebRTC leaks
var RTCPeerConnection = window.RTCPeerConnection || 
                        window.mozRTCPeerConnection || 
                        window.webkitRTCPeerConnection;

var pc = new RTCPeerConnection({iceServers: []});
pc.createDataChannel('');

pc.createOffer().then(offer => pc.setLocalDescription(offer));

pc.onicecandidate = (ice) => {
    if (ice && ice.candidate && ice.candidate.candidate) {
        var ip_regex = /([0-9]{1,3}(\.[0-9]{1,3}){3})/
        var ip_addr = ip_regex.exec(ice.candidate.candidate)[1];
        console.log('Leaked IP:', ip_addr);
    }
};
```

### Browser Fingerprinting Analysis

**Canvas Fingerprinting Detection:**

```javascript
// Detect if canvas fingerprinting is being used
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');
ctx.textBaseline = 'top';
ctx.font = '14px Arial';
ctx.fillText('Fingerprint', 2, 2);

const fingerprint = canvas.toDataURL();
console.log('Canvas fingerprint:', fingerprint);
```

**Tor Browser Fingerprinting Resistance:**

- Standardized window dimensions
- Disabled plugins
- Randomized timezone reporting
- Font enumeration blocking

**Testing Fingerprint Resistance:**

```bash
# Visit fingerprinting test sites through Tor
torsocks curl https://amiunique.org/json

# Compare results across circuits
# Tor Browser should produce identical fingerprints
```

### Stylometry and Writing Analysis

**Authorship Attribution Techniques:**

**Writeprints Analysis:** [Inference] Analyzes:

- Vocabulary richness
- Sentence length distribution
- Grammar patterns
- Punctuation usage
- Lexical diversity

**Anonymouth (Stylometry Evasion):**

```bash
git clone https://github.com/psal/anonymouth.git
cd anonymouth

# Analyze writing sample
java -jar Anonymouth.jar -analyze sample.txt

# Suggests modifications to evade stylometry
# [Unverified] Effectiveness depends on target corpus
```

**Custom Stylometry Detection:**

```python
import nltk
from nltk.tokenize import word_tokenize, sent_tokenize
import numpy as np

def extract_features(text):
    words = word_tokenize(text)
    sentences = sent_tokenize(text)
    
    features = {
        'avg_word_length': np.mean([len(w) for w in words]),
        'avg_sentence_length': np.mean([len(word_tokenize(s)) for s in sentences]),
        'lexical_diversity': len(set(words)) / len(words),
        'hapax_legomena': sum(1 for w in set(words) if words.count(w) == 1) / len(set(words)),
        'punctuation_frequency': sum(1 for c in text if c in '.,!?;:') / len(words)
    }
    
    return features

# Compare features across samples to identify authors
```

### Network-Level Deanonymization

**Guard Node Enumeration:**

```bash
# Extract consensus document
curl --socks5-hostname 127.0.0.1:9050 \
  http://[authority].onion/tor/status-vote/current/consensus > consensus.txt

# Parse guard nodes
grep "^r " consensus.txt | awk '{if ($6 ~ /Guard/) print $2,$7}'
```

**[Inference] AS-Level Adversary Analysis:**

- Autonomous System (AS) path analysis
- BGP route hijacking potential 
- Correlation of entry/exit traffic through shared AS infrastructure

**BGP Routing Analysis:**

```bash
# Identify AS paths for Tor relays
# Using RIPE Atlas or similar BGP tools

# Extract relay IPs from consensus
grep "^s " consensus.txt | grep Guard | awk '{print $6}' > guard_ips.txt

# Query AS information
while read ip; do
    whois -h whois.cymru.com " -v $ip" | grep -E "AS|BGP"
done < guard_ips.txt

# [Inference] Identify single-AS paths that could enable correlation
```

**Traffic Confirmation Attacks:**

```python
# Conceptual: Statistical correlation of timing patterns
import numpy as np
from scipy import stats

def timing_correlation(entry_times, exit_times, window=1.0):
    """
    Correlate timing patterns between entry and exit
    [Inference] Simplified model of confirmation attack
    """
    correlations = []
    
    for i in range(0, len(entry_times), int(window * 10)):
        entry_window = entry_times[i:i+int(window*10)]
        exit_window = exit_times[i:i+int(window*10)]
        
        if len(entry_window) > 5 and len(exit_window) > 5:
            corr, p_value = stats.pearsonr(entry_window, exit_window)
            correlations.append((corr, p_value))
    
    return correlations

# High correlation suggests same circuit
# [Unverified] Requires adversary observing both endpoints
```

### Onion Service Deanonymization

**Hidden Service Descriptor Analysis:**

```python
import stem
from stem.control import Controller

def analyze_hidden_service(onion_address):
    """
    Extract introduction points and potential metadata
    """
    with Controller.from_port(port=9051) as controller:
        controller.authenticate(password='your_password')
        
        # Fetch descriptor
        try:
            descriptor = controller.get_hidden_service_descriptor(onion_address)
            
            print(f"Introduction Points: {len(descriptor.introduction_points())}")
            
            for intro_point in descriptor.introduction_points():
                print(f"  - {intro_point.identifier}")
                print(f"    Link: {intro_point.link_specifiers}")
                
        except Exception as e:
            print(f"Error fetching descriptor: {e}")

# [Inference] Long-lived introduction points may reveal server location
```

**Clock Skew Analysis:**

```bash
# Netcraft-style clock skew fingerprinting
# Measure TCP timestamp variations

# Capture traffic
tcpdump -i any host target.onion -w clock_capture.pcap

# Extract TCP timestamps
tshark -r clock_capture.pcap -T fields -e tcp.options.timestamp.tsval -e frame.time_epoch

# [Inference] Clock skew patterns can fingerprint physical servers
```

**Guard Discovery Attacks:** [Inference] Techniques to identify guard node:

- Force circuit creation through targeted attacks
- Monitor network for new Tor connections
- Statistical analysis over extended period

**Countermeasure: Vanguards:**

```bash
# Install vanguards addon for onion services
pip install vanguards

# Run with Tor
vanguards --control_port 9051 --control_pass your_password

# Provides:
# - Layer 2 and layer 3 guard pinning
# - Protection against guard discovery
# - Circuit stats monitoring
```

### Protocol-Level Analysis

**SSL/TLS Fingerprinting:**

```bash
# Capture TLS handshake
tcpdump -i any port 443 -w tls_capture.pcap

# Analyze with tshark
tshark -r tls_capture.pcap -Y "ssl.handshake.type == 1" -T fields \
  -e ssl.handshake.ciphersuite \
  -e ssl.handshake.extensions.type \
  -e ssl.handshake.version

# Compare TLS fingerprints
# Tor Browser uses specific cipher suites
```

**JA3 Fingerprinting:**

```python
# JA3 hash generation
import hashlib

def generate_ja3(ssl_version, ciphers, extensions, elliptic_curves, ec_point_formats):
    """
    Generate JA3 fingerprint from TLS parameters
    """
    ja3_string = f"{ssl_version},{ciphers},{extensions},{elliptic_curves},{ec_point_formats}"
    ja3_hash = hashlib.md5(ja3_string.encode()).hexdigest()
    return ja3_hash

# Tor Browser has consistent JA3 signature
# Deviation indicates different client

# [Inference] JA3 alone cannot deanonymize but aids in traffic classification
```

**Application-Layer Protocol Analysis:**

```bash
# Identify protocols over Tor
nmap --proxies socks5://127.0.0.1:9050 -sV target.onion

# Protocol-specific fingerprinting
# SSH: cipher negotiation, key exchange methods
# HTTP: Server headers, response characteristics
# Bitcoin: Protocol version messages
```

### Behavioral Analysis

**Time-Based Correlation:**

```python
import pandas as pd
import matplotlib.pyplot as plt

def temporal_analysis(activity_log):
    """
    Analyze posting patterns for identity correlation
    """
    df = pd.DataFrame(activity_log, columns=['timestamp', 'action', 'forum'])
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df['hour'] = df['timestamp'].dt.hour
    df['day'] = df['timestamp'].dt.dayofweek
    
    # Identify patterns
    hourly_activity = df.groupby('hour').size()
    daily_activity = df.groupby('day').size()
    
    # [Inference] Consistent timezone patterns may reveal location
    peak_hour = hourly_activity.idxmax()
    print(f"Peak activity hour: {peak_hour}:00")
    
    return hourly_activity, daily_activity

# Cross-reference with other identities showing similar patterns
```

**Cross-Platform Correlation:**

```python
def find_shared_identifiers(clearnet_profile, darkweb_profile):
    """
    Identify shared metadata between identities
    """
    shared = {
        'email_patterns': set(),
        'writing_style': {},
        'technical_knowledge': set(),
        'temporal_overlap': [],
        'cryptocurrency_addresses': set()
    }
    
    # Email pattern analysis
    import re
    email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+'
    
    clearnet_emails = re.findall(email_pattern, clearnet_profile)
    darkweb_emails = re.findall(email_pattern, darkweb_profile)
    
    # Look for structural similarities
    for ce in clearnet_emails:
        for de in darkweb_emails:
            if ce.split('@')[0][:3] == de.split('@')[0][:3]:
                shared['email_patterns'].add((ce, de))
    
    return shared

# [Inference] OPSEC failures often involve reused identifiers
```

### Cryptocurrency Tracing

**Bitcoin Address Clustering:**

```bash
# Using BlockSci or similar blockchain analysis

# Install BlockSci
# [Unverified] Installation complexity varies by system

# Query transactions
blocksci-cli clusterer --address 1ABC...XYZ --heuristic common_input

# Track fund flows
blocksci-cli transactions --txid TXID --depth 3
```

**Monero Timing Analysis:**

```python
# [Inference] Even privacy coins have observable patterns

def analyze_xmr_timing(transactions):
    """
    Analyze transaction timing patterns
    Ring signature sizes, fee patterns
    """
    patterns = {
        'ring_sizes': [],
        'fee_levels': [],
        'timing': []
    }
    
    for tx in transactions:
        patterns['ring_sizes'].append(tx.get('ring_size', 0))
        patterns['fee_levels'].append(tx.get('fee', 0))
        patterns['timing'].append(tx.get('timestamp', 0))
    
    # Statistical analysis of patterns
    # [Unverified] Effectiveness depends on transaction volume
    
    return patterns
```

**Mixing Service Analysis:**

```bash
# Identify mixer usage
# Common patterns:
# - Specific time delays (30min, 1hr, 24hr)
# - Round-number outputs
# - Consistent fee structures

# Track mixed funds (limited effectiveness)
# [Inference] Proper mixing should break deterministic links
```

### Tor Bridge Detection

**Bridge Fingerprinting:**

```bash
# Obfs4 bridge detection
# [Inference] Deep packet inspection can identify some bridges

# Test obfuscation
obfs4proxy -enableLogging -logLevel DEBUG

# Monitor connection patterns
sudo netstat -anp | grep obfs4proxy

# Active probing resistance
# Bridges use authentication to prevent enumeration
```

**Snowflake Analysis:**

```bash
# Snowflake uses WebRTC for ephemeral proxies
# [Inference] Harder to block but has unique characteristics

# Monitor WebRTC connections
chrome://webrtc-internals/

# ICE candidate analysis can reveal proxy infrastructure
```

### Countermeasure Testing

**OpSec Validation Script:**

```bash
#!/bin/bash
# opsec_check.sh

echo "[*] Testing operational security..."

# 1. DNS leak test
echo "[+] Checking DNS leaks..."
dns_result=$(torsocks curl -s https://ipleak.net/api/json | jq -r '.dns')
if [[ "$dns_result" == *"tor"* ]] || [[ "$dns_result" == "null" ]]; then
    echo "    [OK] No DNS leaks detected"
else
    echo "    [FAIL] DNS leak detected: $dns_result"
fi

# 2. IP leak test
echo "[+] Checking IP address..."
ip_result=$(torsocks curl -s https://check.torproject.org/api/ip)
if [[ "$ip_result" == *"\"IsTor\":true"* ]]; then
    echo "    [OK] Using Tor network"
else
    echo "    [FAIL] Not using Tor"
fi

# 3. WebRTC leak (requires browser testing)
echo "[+] WebRTC check required in browser"
echo "    Visit: https://browserleaks.com/webrtc"

# 4. Timezone check
echo "[+] Checking timezone leakage..."
tz_result=$(torsocks curl -s https://browserleaks.com/json/timezone | jq -r '.timezone')
echo "    Reported timezone: $tz_result"
echo "    [Note] Should be UTC for Tor Browser"

# 5. Font enumeration
echo "[+] Font fingerprinting protection check"
echo "    Visit: https://browserleaks.com/fonts"

# 6. Canvas fingerprinting
echo "[+] Canvas fingerprinting check"
echo "    Visit: https://browserleaks.com/canvas"

echo "[*] Manual verification required for browser-based tests"
```

**Traffic Padding Analysis:**

```python
from scapy.all import *

def detect_padding(pcap_file):
    """
    Identify traffic padding/dummy packets
    """
    packets = rdpcap(pcap_file)
    
    # Look for consistent padding patterns
    padding_candidates = []
    
    for pkt in packets:
        if pkt.haslayer(TCP):
            payload_len = len(pkt[TCP].payload)
            
            # Tor cells are 512 bytes
            if payload_len == 512:
                padding_candidates.append(pkt)
    
    # Statistical analysis
    if len(padding_candidates) > 0:
        avg_interval = np.mean([
            float(padding_candidates[i+1].time - padding_candidates[i].time)
            for i in range(len(padding_candidates)-1)
        ])
        print(f"Detected {len(padding_candidates)} potential padding cells")
        print(f"Average interval: {avg_interval:.4f}s")
    
    # [Inference] Regular intervals suggest active padding defense

detect_padding('tor_traffic.pcap')
```

### Advanced Correlation Techniques

**End-to-End Correlation Framework:**

```python
import numpy as np
from scipy.signal import correlate

class TrafficCorrelator:
    """
    Simulate traffic correlation attack
    [Inference] Educational/research purposes only
    """
    
    def __init__(self):
        self.entry_stream = []
        self.exit_stream = []
    
    def capture_stream(self, packets, stream_type):
        """Extract timing and size features"""
        features = []
        for i in range(1, len(packets)):
            time_delta = packets[i].time - packets[i-1].time
            size = len(packets[i])
            direction = 1 if packets[i].src == packets[0].src else -1
            
            features.append({
                'time': time_delta,
                'size': size,
                'direction': direction
            })
        
        if stream_type == 'entry':
            self.entry_stream = features
        else:
            self.exit_stream = features
    
    def correlate_streams(self):
        """Calculate correlation coefficient"""
        if not self.entry_stream or not self.exit_stream:
            return None
        
        # Extract timing sequences
        entry_times = [f['time'] for f in self.entry_stream]
        exit_times = [f['time'] for f in self.exit_stream]
        
        # Cross-correlation
        correlation = correlate(entry_times, exit_times, mode='valid')
        max_corr = np.max(np.abs(correlation))
        
        # [Unverified] Threshold depends on traffic characteristics
        if max_corr > 0.7:
            return "HIGH CORRELATION - Possible match"
        else:
            return "Low correlation"

# [Critical] This is for CTF/research understanding only
# Real-world correlation attacks require extensive infrastructure
```

**Multi-Path Fingerprinting:**

```python
def analyze_circuit_path(circuits):
    """
    Analyze if multiple circuits share infrastructure
    [Inference] Shared paths reduce anonymity
    """
    from collections import Counter
    
    all_nodes = []
    for circuit in circuits:
        all_nodes.extend(circuit['path'])
    
    # Identify frequently used nodes
    node_frequency = Counter(all_nodes)
    
    # Check for AS-level overlap
    # [Inference] Requires AS mapping data
    
    suspicious_overlap = [
        node for node, count in node_frequency.items()
        if count > len(circuits) * 0.5  # Appears in >50% of circuits
    ]
    
    if suspicious_overlap:
        print("[!] Warning: Circuits show significant node overlap")
        print(f"    Shared nodes: {suspicious_overlap}")
        print("    [Inference] May indicate guard/exit node reuse")
    
    return node_frequency
```

---

## Key CTF Application Scenarios

### OSINT Chain Construction

**Scenario: Tracking adversary infrastructure**

```bash
# 1. Discover initial .onion address from paste site
grep -r "\.onion" ./paste_archive/ | head -1

# 2. Scan discovered service
onionscan --verbose target.onion | tee scan_results.txt

# 3. Extract metadata
grep -E "email|bitcoin|pgp" scan_results.txt

# 4. Cross-reference findings
# Search email in clearnet OSINT tools
# Search Bitcoin address in blockchain explorers
# Check PGP key in keyservers

# 5. Expand infrastructure map
# Find related .onion addresses through:
# - Shared hosting fingerprints
# - Similar TLS certificates
# - Related Bitcoin addresses
# - Forum cross-posting patterns
```

### Flag Extraction Techniques

**Hidden in Onion Service:**

```bash
# Crawl entire site structure
wget --execute robots=off \
     --mirror \
     --page-requisites \
     --no-parent \
     -e use_proxy=yes \
     -e http_proxy=socks5h://127.0.0.1:9050 \
     http://target.onion/

# Search for flag patterns
grep -r "CTF{" target.onion/ 
grep -r "flag{" target.onion/
grep -r -E "[A-F0-9]{32}" target.onion/  # MD5 patterns

# Check source code comments
grep -r "<!--" target.onion/ | grep -i flag

# Examine hidden form fields
grep -r "type=\"hidden\"" target.onion/
```

**Metadata Extraction:**

```bash
# Extract document metadata
exiftool target.onion/*.pdf
exiftool target.onion/*.jpg

# Check certificate information
echo | openssl s_client -connect target.onion:443 \
  -proxy localhost:9050 2>/dev/null | \
  openssl x509 -noout -text

# [Inference] Flags may be hidden in:
# - Certificate Subject Alternative Names
# - Document properties
# - Image EXIF data
# - HTML meta tags
```

---

## Important Related Topics to Explore

**Advanced Network Analysis:**

- Deep packet inspection techniques
- Machine learning for traffic classification
- Tor pluggable transport analysis

**Cryptocurrency Forensics:**

- Blockchain analysis platforms (Chainalysis, Elliptic)
- Privacy coin tracing techniques
- Mixing service identification

**Operational Security:**

- Multi-layered anonymity (VPN → Tor → VPN)
- Compartmentalization strategies
- OPSEC failure case studies

**Legal and Ethical Considerations:**

- Attribution vs deanonymization ethics
- Evidence handling for law enforcement cooperation
- Responsible disclosure in CTF contexts

---

# Cryptography in OSINT

Cryptographic analysis in OSINT contexts focuses on identifying, decoding, and extracting intelligence from encoded or encrypted information found in publicly accessible sources. Unlike traditional cryptanalysis, OSINT cryptography emphasizes recognizing encoding schemes, analyzing publicly available cryptographic artifacts, and leveraging weak implementations.

## Basic Encoding Schemes

Encoding transforms data into different formats for transmission or storage. Recognition is the first critical skill.

### Base64 Detection and Decoding

**Recognition patterns:**

- Character set: A-Z, a-z, 0-9, +, / with = padding
- Length typically divisible by 4
- No special characters except +, /, =
- Common in URLs, JSON, XML, email headers

**Command-line tools:**

```bash
# Basic decoding
echo "SGVsbG8gV29ybGQ=" | base64 -d

# Decode from file
base64 -d input.txt > output.bin

# Encode for verification
echo "Hello World" | base64

# Handle URL-safe Base64 (- and _ instead of + and /)
echo "SGVsbG8gV29ybGQ" | base64 -d

# Multi-line Base64
cat multiline.txt | tr -d '\n' | base64 -d
```

**CyberChef operations:**

- From Base64
- URL-safe Base64 variant handling
- Auto-detect encoding chains

**Nested encoding detection:** [Inference] Multiple layers of encoding are common in CTF challenges. Test decoded output for additional encoding patterns.

```bash
# Iterative decoding script
#!/bin/bash
input="$1"
for i in {1..5}; do
    decoded=$(echo "$input" | base64 -d 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Layer $i: $decoded"
        input="$decoded"
    else
        break
    fi
done
```

### Hexadecimal Encoding

**Recognition patterns:**

- Characters: 0-9, A-F (or a-f)
- Even number of characters
- Often prefixed with 0x or \x
- Two hex digits represent one byte

**Decoding methods:**

```bash
# Using xxd
echo "48656c6c6f" | xxd -r -p

# Using Python
echo "48656c6c6f" | python3 -c "import sys; print(bytes.fromhex(sys.stdin.read().strip()).decode())"

# From file with 0x prefix
cat hex.txt | sed 's/0x//g' | xxd -r -p

# Encode for comparison
echo "Hello" | xxd -p

# Convert hex dump back to binary
xxd -r input.hex output.bin
```

**Common hex formats in OSINT:**

- Memory dumps
- Network packet captures
- Binary file representations
- Hash values
- Bitcoin addresses (after Base58 decode)

### URL Encoding (Percent-Encoding)

**Recognition:**

- Percent sign (%) followed by two hex digits
- Used in URLs, HTTP requests
- Spaces become %20 or +

**Decoding:**

```bash
# Using Python
python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))"

# Example
echo "Hello%20World%21" | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))"

# Using Perl
perl -MURI::Escape -e 'print uri_unescape(<STDIN>)'

# Double encoding detection
echo "Hello%2520World" | python3 -c "import sys, urllib.parse; s=sys.stdin.read(); print(urllib.parse.unquote(urllib.parse.unquote(s)))"
```

### ASCII Encoding Variants

**Decimal ASCII:**

```bash
# Decode decimal ASCII
echo "72 101 108 108 111" | python3 -c "import sys; print(''.join(chr(int(x)) for x in sys.stdin.read().split()))"

# Encode to decimal
echo "Hello" | python3 -c "import sys; print(' '.join(str(ord(c)) for c in sys.stdin.read().strip()))"
```

**Octal ASCII:**

```bash
# Decode octal
echo "110 145 154 154 157" | python3 -c "import sys; print(''.join(chr(int(x, 8)) for x in sys.stdin.read().split()))"
```

**Binary ASCII:**

```bash
# Decode binary
echo "01001000 01100101 01101100 01101100 01101111" | python3 -c "import sys; print(''.join(chr(int(x, 2)) for x in sys.stdin.read().split()))"
```

### ROT13 and Caesar Ciphers

**ROT13 (13-character rotation):**

```bash
# Using tr
echo "Uryyb Jbeyq" | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Using Python
echo "Uryyb Jbeyq" | python3 -c "import sys, codecs; print(codecs.decode(sys.stdin.read(), 'rot13'))"
```

**Caesar cipher brute force:**

```python
#!/usr/bin/env python3
def caesar_bruteforce(ciphertext):
    for shift in range(26):
        decoded = ''.join(
            chr((ord(char) - 65 - shift) % 26 + 65) if char.isupper()
            else chr((ord(char) - 97 - shift) % 26 + 97) if char.islower()
            else char
            for char in ciphertext
        )
        print(f"Shift {shift:2d}: {decoded}")

# Usage
caesar_bruteforce("Khoor Zruog")
```

### XOR Encoding

**Single-byte XOR brute force:**

```python
#!/usr/bin/env python3
import sys

def xor_bruteforce(data):
    for key in range(256):
        decoded = bytes([b ^ key for b in data])
        try:
            text = decoded.decode('ascii')
            if all(32 <= ord(c) <= 126 or c in '\n\r\t' for c in text):
                print(f"Key {key:3d} (0x{key:02x}): {text[:80]}")
        except:
            pass

# Read hex input
hex_string = sys.argv[1]
data = bytes.fromhex(hex_string)
xor_bruteforce(data)
```

**Multi-byte XOR key detection:** [Inference] Key length can be estimated using index of coincidence or Hamming distance analysis.

```python
#!/usr/bin/env python3
def hamming_distance(b1, b2):
    return sum(bin(x ^ y).count('1') for x, y in zip(b1, b2))

def find_keysize(data, max_keysize=40):
    distances = []
    for keysize in range(2, max_keysize + 1):
        chunks = [data[i:i+keysize] for i in range(0, len(data), keysize)][:4]
        if len(chunks) < 2:
            continue
        dist = sum(hamming_distance(chunks[i], chunks[i+1]) 
                   for i in range(len(chunks)-1)) / (len(chunks)-1) / keysize
        distances.append((keysize, dist))
    
    return sorted(distances, key=lambda x: x[1])[:5]
```

### Base32 and Base85

**Base32 detection:**

- Character set: A-Z, 2-7, with = padding
- Length divisible by 8
- No lowercase letters

```bash
# Decode Base32
echo "JBSWY3DPEBLW64TMMQ======" | base32 -d

# Python alternative
python3 -c "import base64, sys; print(base64.b32decode(sys.stdin.read()).decode())"
```

**Base85 (Ascii85) detection:**

- Character set: ! through u (ASCII 33-117)
- Often wrapped in <~ and ~>
- Used in PDFs and PostScript

```python
#!/usr/bin/env python3
import base64

# Decode Base85
encoded = b"<~87cURD]j7BEbo80~>"
decoded = base64.a85decode(encoded)
print(decoded.decode())
```

### Multi-Stage Encoding Recognition

**Automated detection tools:**

```bash
# CyberChef "Magic" operation
# https://gchq.github.io/CyberChef/#recipe=Magic(3,false,false,'')

# Online multi-decoder
# https://www.dcode.fr/cipher-identifier
```

**Manual identification checklist:**

1. Character set analysis (alphanumeric only, special chars, etc.)
2. Length patterns (divisible by 4, 8, even, etc.)
3. Entropy measurement (high entropy suggests encryption, not encoding)
4. Common prefixes/suffixes (0x, ===, <~, etc.)
5. Context clues (MIME headers, URL parameters, file formats)

## Hash Identification

Hash functions produce fixed-length outputs from arbitrary inputs. In OSINT, hashes are found in leaked databases, blockchain transactions, code repositories, and configuration files.

### Hash Recognition by Length and Format

**Common hash lengths (hex representation):**

- MD5: 32 characters (128 bits)
- SHA-1: 40 characters (160 bits)
- SHA-224: 56 characters
- SHA-256: 64 characters (256 bits)
- SHA-384: 96 characters
- SHA-512: 128 characters (512 bits)
- RIPEMD-160: 40 characters
- NTLM: 32 characters
- MySQL (OLD): 16 characters

**Automated identification:**

```bash
# hashid tool
hashid 'd033e22ae348aeb5660fc2140aec35850c4da997'
# Output: [+] SHA-1
#         [+] Double SHA-1
#         [+] RIPEMD-160

# With hash types for hashcat
hashid -m 'd033e22ae348aeb5660fc2140aec35850c4da997'

# hash-identifier (interactive)
hash-identifier

# Python hashid library
python3 -c "from hashid import HashID; h=HashID(); print(h.identifyHash('d033e22ae348aeb5660fc2140aec35850c4da997'))"
```

### Hash Format Variants

**Salted hashes:**

- Format varies by system
- Linux shadow file: `$id$salt$hash`
    - $1$ = MD5
    - $2a$, $2y$ = Bcrypt
    - $5$ = SHA-256
    - $6$ = SHA-512
    - $y$ = yescrypt

```bash
# Example shadow hash
$6$rounds=5000$saltsaltsal$VjAyW6HQSLvPFj8VgKuR9WPYXwNa3u1nJmQNvKJ3h7eEKPW8xQZxRG7vBUP3q2nD9RXKM8wFPqR9vKPYWJKH8Q1

# Extract components
# $6$ = SHA-512
# rounds=5000 = iteration count
# saltsaltsal = salt
# VjAy... = hash
```

**Common formats by platform:**

WordPress (MD5):

```
$P$BxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxPassed
```

Joomla (MD5):

```
hash:salt
```

Django:

```
algorithm$iterations$salt$hash
```

**HMAC identification:** [Inference] HMACs use the same hash functions but include a secret key. They are indistinguishable from regular hashes by appearance alone.

### Online Hash Databases

**Hash cracking resources:**

- CrackStation: https://crackstation.net/
- Hashes.com: https://hashes.com/en/decrypt/hash
- cmd5.org: https://www.cmd5.org/
- OnlineHashCrack: https://www.onlinehashcrack.com/

**Programmatic hash lookup:**

```python
#!/usr/bin/env python3
import requests

def lookup_md5(hash_value):
    # Using MD5Decrypt API (example)
    url = f"https://md5decrypt.net/en/Api/api.php?hash={hash_value}&hash_type=md5&email=YOUR_EMAIL&code=YOUR_CODE"
    response = requests.get(url)
    return response.text

# Local wordlist comparison
def check_wordlist(hash_value, hash_type='md5'):
    import hashlib
    with open('/usr/share/wordlists/rockyou.txt', 'r', encoding='latin-1') as f:
        for line in f:
            word = line.strip()
            h = hashlib.new(hash_type)
            h.update(word.encode())
            if h.hexdigest() == hash_value:
                return word
    return None
```

### Hash Cracking with Hashcat

**Basic syntax:**

```bash
# Identify hash mode
hashcat --help | grep -i "sha256"

# Crack MD5
hashcat -m 0 -a 0 hash.txt /usr/share/wordlists/rockyou.txt

# Crack SHA-256
hashcat -m 1400 -a 0 hash.txt wordlist.txt

# Crack NTLM
hashcat -m 1000 -a 0 hash.txt wordlist.txt

# Crack bcrypt
hashcat -m 3200 -a 0 hash.txt wordlist.txt

# Brute force attack (mask attack)
hashcat -m 0 -a 3 hash.txt ?a?a?a?a?a?a
# ?a = all characters
# ?l = lowercase
# ?u = uppercase
# ?d = digits
# ?s = special characters

# Combination attack
hashcat -m 0 -a 1 hash.txt wordlist1.txt wordlist2.txt

# Rule-based attack
hashcat -m 0 -a 0 hash.txt wordlist.txt -r /usr/share/hashcat/rules/best64.rule

# Show cracked hashes
hashcat -m 0 hash.txt --show
```

**Common hash modes:**

- 0: MD5
- 100: SHA-1
- 1400: SHA-256
- 1700: SHA-512
- 1000: NTLM
- 3000: LM
- 3200: bcrypt
- 7500: Kerberos 5 AS-REQ Pre-Auth
- 13100: Kerberos 5 TGS-REP
- 5600: NetNTLMv2
- 1800: sha512crypt (Linux)

### John the Ripper

**Basic usage:**

```bash
# Auto-detect and crack
john hash.txt

# Specify format
john --format=raw-md5 hash.txt

# Use wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Use rules
john --wordlist=wordlist.txt --rules hash.txt

# Show cracked passwords
john --show hash.txt

# List supported formats
john --list=formats

# Crack shadow file
unshadow /etc/passwd /etc/shadow > combined.txt
john combined.txt
```

**Format-specific examples:**

```bash
# ZIP password
zip2john archive.zip > hash.txt
john hash.txt

# RAR password
rar2john archive.rar > hash.txt
john hash.txt

# PDF password
pdf2john document.pdf > hash.txt
john hash.txt

# SSH private key password
ssh2john id_rsa > hash.txt
john hash.txt

# KeePass database
keepass2john database.kdbx > hash.txt
john hash.txt
```

### Custom Hash Analysis

**Creating custom hashes for comparison:**

```bash
# MD5
echo -n "password" | md5sum

# SHA-256
echo -n "password" | sha256sum

# NTLM (Windows)
python3 -c "import hashlib; print(hashlib.new('md4', 'password'.encode('utf-16le')).hexdigest())"

# SHA-512 with salt
python3 -c "import crypt; print(crypt.crypt('password', crypt.mksalt(crypt.METHOD_SHA512)))"
```

**Validating hash collisions:** [Unverified] MD5 and SHA-1 collision attacks exist, but are not commonly encountered in CTF OSINT challenges without explicit indication.

```bash
# Generate MD5 collision pairs using hashclash (if needed)
# Tools: hashclash, UniColl
```

## Steganography Detection

Steganography conceals information within other files. In OSINT, this includes images, audio files, documents, and network traffic.

### File Analysis Basics

**Initial reconnaissance:**

```bash
# File type identification
file image.png
file -b image.png  # brief output

# Hexdump analysis
xxd image.png | head -n 20
hexdump -C image.png | head -n 20

# String extraction
strings image.png
strings -n 10 image.png  # minimum length 10

# Metadata examination
exiftool image.png
exiftool -a -G1 image.png  # all tags with groups

# Check file size anomalies
ls -lh image.png
stat image.png
```

**File signature verification:**

```bash
# Check magic bytes
head -c 16 image.png | xxd

# Common signatures:
# PNG: 89 50 4E 47 0D 0A 1A 0A
# JPEG: FF D8 FF
# GIF: 47 49 46 38
# ZIP: 50 4B 03 04
# PDF: 25 50 44 46
```

### Image Steganography Detection

**Stegdetect and automated tools:**

```bash
# Stegdetect (for JPEG)
stegdetect image.jpg

# Stegbreak (brute force steghide)
stegbreak -r /usr/share/wordlists/rockyou.txt -f /tmp/out.txt image.jpg

# Zsteg (PNG and BMP)
zsteg image.png
zsteg -a image.png  # all methods

# Steghide info
steghide info image.jpg
# Extract with password
steghide extract -sf image.jpg -p password

# Outguess detection
outguess -r image.jpg output.txt

# Binwalk for embedded files
binwalk image.png
binwalk -e image.png  # extract

# Foremost file carving
foremost -i image.png -o output/
```

**LSB (Least Significant Bit) analysis:**

```python
#!/usr/bin/env python3
from PIL import Image
import numpy as np

def extract_lsb(image_path):
    img = Image.open(image_path)
    pixels = np.array(img)
    
    # Extract LSB from each color channel
    lsb_data = pixels & 1
    
    # Convert to binary string
    binary = ''.join(str(bit) for pixel in lsb_data.flatten() for bit in [pixel])
    
    # Convert to ASCII
    chars = [chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)]
    return ''.join(chars)

# Usage
result = extract_lsb('image.png')
print(result[:1000])  # First 1000 characters
```

**Stegsolve (GUI tool):**

- Download: http://www.caesum.com/handbook/Stegsolve.jar
- Run: `java -jar Stegsolve.jar`
- Features:
    - Plane analysis (bit planes)
    - Color filters
    - Stereogram solver
    - Frame browser (animated images)

**StegOnline web tool:**

- URL: https://stegonline.georgeom.net/upload
- Browser-based alternative to Stegsolve
- Supports multiple image formats

### Advanced Image Analysis

**PNG chunk analysis:**

```bash
# pngcheck - validate and analyze PNG structure
pngcheck -v image.png

# Extract specific chunks
pngchunks image.png

# Python PNG chunk extraction
python3 << 'EOF'
import struct

def read_png_chunks(filename):
    with open(filename, 'rb') as f:
        f.read(8)  # Skip PNG signature
        while True:
            length_data = f.read(4)
            if not length_data:
                break
            length = struct.unpack('>I', length_data)[0]
            chunk_type = f.read(4).decode('ascii')
            chunk_data = f.read(length)
            crc = f.read(4)
            
            if chunk_type not in ['IHDR', 'IDAT', 'IEND', 'PLTE']:
                print(f"{chunk_type}: {chunk_data[:100]}")

read_png_chunks('image.png')
EOF
```

**JPEG comment extraction:**

```bash
# Extract JPEG comments
exiftool -Comment image.jpg

# jhead for JPEG analysis
jhead image.jpg

# Manual extraction
strings image.jpg | grep -i "comment"
```

**Color analysis and histograms:**

```python
#!/usr/bin/env python3
from PIL import Image
import matplotlib.pyplot as plt

def analyze_histogram(image_path):
    img = Image.open(image_path)
    
    # Plot histogram
    plt.figure(figsize=(12, 4))
    for i, color in enumerate(['red', 'green', 'blue']):
        plt.subplot(1, 3, i+1)
        plt.hist(np.array(img)[:,:,i].flatten(), bins=256, color=color, alpha=0.7)
        plt.title(f'{color.capitalize()} Channel')
    
    plt.tight_layout()
    plt.savefig('histogram.png')
    
    # Check for anomalies
    histogram = img.histogram()
    print("Unusual spikes in histogram may indicate steganography")

analyze_histogram('image.png')
```

### Audio Steganography

**Spectral analysis:**

```bash
# Sonic Visualizer (GUI)
sonic-visualizer audio.wav

# Audacity
audacity audio.wav
# View -> Spectrogram

# Command-line spectrogram
sox audio.wav -n spectrogram -o spectrogram.png

# WavSteg (LSB in WAV)
python3 WavSteg.py -r -i audio.wav -o output.txt -n 1 -b 10000

# Deepsound detection
# (Windows tool for detecting DeepSound steganography)
```

**Audio metadata and hidden data:**

```bash
# Audio metadata
exiftool audio.mp3
ffprobe audio.mp3

# Extract embedded files
binwalk audio.mp3
binwalk -e audio.mp3

# String analysis
strings audio.wav | grep -E "[A-Za-z0-9]{20,}"
```

### Document Steganography

**PDF analysis:**

```bash
# PDF structure analysis
pdfinfo document.pdf
pdffonts document.pdf
pdfimages document.pdf images/

# Extract streams
pdf-parser document.pdf
qpdf --qdf document.pdf uncompressed.pdf

# Check for hidden layers
pdftk document.pdf dump_data

# Metadata
exiftool document.pdf

# Hidden text (white on white, etc.)
pdftotext document.pdf - | less
```

**Microsoft Office documents:**

```bash
# Office documents are ZIP files
unzip document.docx -d extracted/

# Check for hidden data
cd extracted/
grep -r "flag" .
grep -r "password" .

# Metadata
exiftool document.docx

# Hidden sheets in Excel
# Open with LibreOffice and check hidden sheets

# Embedded macros
olevba document.docm
```

### Polyglot Files

[Inference] Polyglot files are valid in multiple formats simultaneously.

**Detection:**

```bash
# Check multiple file signatures
file polyglot
xxd polyglot | head -n 5
xxd polyglot | tail -n 5

# Try extracting as different formats
unzip polyglot
tar -xf polyglot
7z x polyglot

# Check if image with embedded ZIP
binwalk polyglot
foremost polyglot
```

**Creation example (reference):**

```bash
# Create PNG with embedded ZIP
cat image.png archive.zip > polyglot.png
```

### Network Traffic Steganography

**PCAP analysis for covert channels:**

```bash
# Open in Wireshark
wireshark capture.pcap

# Extract HTTP objects
tshark -r capture.pcap --export-objects http,output/

# Look for unusual traffic patterns
tshark -r capture.pcap -T fields -e ip.src -e ip.dst | sort | uniq -c

# ICMP covert channels (payload analysis)
tshark -r capture.pcap -Y "icmp" -T fields -e data

# DNS tunneling detection
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | grep -E ".{30,}"

# Extract TCP/UDP payloads
tcpflow -r capture.pcap
```

### Steganography Tool Reference

**Essential tools:**

- Steghide: JPEG, BMP, WAV, AU (password-based)
- Zsteg: PNG, BMP (LSB techniques)
- Stegsolve: Image analysis (GUI)
- Binwalk: File signature analysis and extraction
- Foremost: File carving
- Exiftool: Metadata extraction
- Sonic Visualizer: Audio spectral analysis
- Stegseek: Fast steghide cracker

**Stegseek usage:**

```bash
# Fast brute force for steghide
stegseek image.jpg wordlist.txt

# Extract without password
stegseek image.jpg
```

## PGP Key Analysis

PGP (Pretty Good Privacy) keys are used for encryption and digital signatures. In OSINT, PGP keys reveal identities, social connections, and historical communications.

### PGP Key Structure

**Key components:**

- Public key: Shared openly
- Private key: Kept secret
- User ID: Name and email
- Signatures: Web of trust
- Subkeys: For specific purposes
- Key fingerprint: Unique identifier
- Creation and expiration dates

**Key formats:**

- ASCII-armored: `-----BEGIN PGP PUBLIC KEY BLOCK-----`
- Binary: .pgp, .gpg files
- Keyservers: HKP protocol

### Key Extraction and Analysis

**GnuPG (GPG) commands:**

```bash
# Import public key
gpg --import publickey.asc

# List imported keys
gpg --list-keys
gpg --list-keys --keyid-format LONG

# Display key details
gpg --list-packets publickey.asc

# Export key fingerprint
gpg --fingerprint user@example.com

# Export key in ASCII format
gpg --armor --export user@example.com

# Search keyserver
gpg --keyserver hkps://keys.openpgp.org --search-keys user@example.com

# Receive key from keyserver
gpg --keyserver hkps://keys.openpgp.org --recv-keys KEYID

# List signatures on key
gpg --list-sigs user@example.com

# Check key validity
gpg --check-sigs user@example.com
```

**Key fingerprint analysis:**

```bash
# Full fingerprint (160-bit SHA-1 for older keys, SHA-256 for v5)
gpg --fingerprint user@example.com

# Short key ID (last 8 hex characters)
# WARNING: Short IDs are vulnerable to collision attacks

# Long key ID (last 16 hex characters)
gpg --list-keys --keyid-format LONG
```

### Keyserver OSINT

**Major keyservers:**

- keys.openpgp.org
- keyserver.ubuntu.com
- pgp.mit.edu
- keys.gnupg.net

**Web interface searches:**

```bash
# Search via curl
curl "https://keyserver.ubuntu.com/pks/lookup?search=user@example.com&op=index"

# Download key
curl "https://keyserver.ubuntu.com/pks/lookup?search=0xKEYID&op=get" > key.asc

# Search for all keys with email domain
curl "https://keyserver.ubuntu.com/pks/lookup?search=@example.com&op=index"
```

**Automated key harvesting:**

```python
#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup

def search_keyserver(query, keyserver="https://keyserver.ubuntu.com"):
    url = f"{keyserver}/pks/lookup?search={query}&op=index"
    response = requests.get(url)
    
    # Parse results
    soup = BeautifulSoup(response.text, 'html.parser')
    keys = []
    
    for pre in soup.find_all('pre'):
        text = pre.get_text()
        # Extract key IDs and user IDs
        # [Inference] Format varies by keyserver
        print(text)
    
    return keys

# Usage
search_keyserver("user@example.com")
```

### Web of Trust Analysis

**Signature analysis:**

```bash
# Show who signed a key
gpg --list-sigs user@example.com

# Export signatures
gpg --export-options export-signatures --export user@example.com | gpg --list-packets

# Check signature validity
gpg --check-sigs KEYID
```

**Trust path discovery:** [Inference] Finding trust paths requires analyzing the web of trust graph, which can reveal social connections.

```bash
# Set key trust level
gpg --edit-key user@example.com
# Command: trust
# Select trust level

# Check trust path
gpg --list-sigs --with-colons user@example.com
```

**Graph visualization tools:**

- sig2dot: Generates GraphViz graphs from GPG signatures
- KeyAnalyzer: Java tool for key analysis

```bash
# Generate signature graph
gpg --list-sigs --with-colons | sig2dot > graph.dot
dot -Tpng graph.dot -o graph.png
```

### Encrypted Message Analysis

**Identifying encrypted content:**

```bash
# PGP message format
-----BEGIN PGP MESSAGE-----
Version: GnuPG v2

hQEMAw3bi...
=abcd
-----END PGP MESSAGE-----

# Detect encryption algorithm
gpg --list-packets encrypted.asc
```

**Decryption attempts:**

```bash
# Decrypt with private key
gpg --decrypt encrypted.asc

# Decrypt to file
gpg --output decrypted.txt --decrypt encrypted.asc

# Try decryption with specific key
gpg --decrypt --recipient user@example.com encrypted.asc
```

**Brute force weak passwords:** [Inference] If the private key is encrypted with a weak passphrase, dictionary attacks may succeed.

```bash
# gpg-cracker (example tool concept)
# Note: No widely-used production tool exists for this
for password in $(cat wordlist.txt); do
    echo "$password" | gpg --batch --yes --passphrase-fd 0 --decrypt encrypted.asc 2>/dev/null && echo "Password found: $password" && break
done
```

### Key Metadata OSINT

**User ID extraction:**

```bash
# Extract all user IDs
gpg --list-keys --with-colons | grep uid

# Parse user IDs for emails
gpg --list-keys --with-colons | grep uid | cut -d: -f10
```

**Creation date analysis:**

```bash
# Show creation date
gpg --list-keys --with-colons | grep pub

# Parse creation timestamp
gpg --list-packets publickey.asc | grep created
```

**Subkey purposes:**

```bash
# List subkeys
gpg --list-keys --with-colons | grep sub

# Key usage flags:
# S = signing
# E = encryption
# C = certification
# A = authentication
```

### PGP in Public Data Sources

**GitHub:**

- Users can upload PGP keys to their profiles
- Commit signature verification
- Search via API

```bash
# Get user's GPG keys via API
curl https://api.github.com/users/USERNAME/gpg_keys

# Download key
curl https://github.com/USERNAME.gpg

# Search signed commits
git log --show-signature

# Verify commit signature
git verify-commit COMMIT_HASH
```

**Email headers:**

```bash
# Extract PGP signature from email
grep -A 50 "BEGIN PGP SIGNATURE" email.txt

# Verify email signature
gpg --verify signature.asc email.txt

# Extract signed content
gpg --decrypt signed_email.asc
```

**Pastebin and text sharing sites:**

```bash
# Search for PGP keys on Pastebin
# Use Google dork: site:pastebin.com "BEGIN PGP PUBLIC KEY"

# Search for encrypted messages
# site:pastebin.com "BEGIN PGP MESSAGE"

# Automated scraping (example)
curl "https://pastebin.com/raw/PASTEID" | gpg --import
```

**Dark web markets:** [Inference] Many dark web marketplaces required PGP for vendor-buyer communication. Archived keys can establish identity continuity.

- Verify vendor identity across markets
- Historical key analysis from market archives
- Cross-reference with law enforcement disclosures

### PGP Key Forensics

**Key generation patterns:**

```bash
# Analyze key material for weak random number generation
gpg --list-packets --verbose publickey.asc

# Check for Debian weak key vulnerability (2008)
# Affected keys generated between 2006-2008
# Tools: debian-goodies package
```

**Timestamp analysis:**

```bash
# Extract all timestamps
gpg --list-packets publickey.asc | grep -E "created|expires"

# Self-signature timing
# Time between key creation and self-signature may indicate automation
```

**Key revocation certificates:**

```bash
# Generate revocation certificate
gpg --output revoke.asc --gen-revoke user@example.com

# Import revocation
gpg --import revoke.asc

# Check if key is revoked
gpg --list-keys user@example.com
```

### Encrypted File Detection

**File signature recognition:**

```bash
# PGP encrypted file signature
file encrypted.pgp
# Output: PGP RSA encrypted session key

# ASCII armored detection
head -n 1 file.asc
# -----BEGIN PGP MESSAGE-----

# Symmetric encryption (passphrase-only)
gpg --list-packets encrypted.asc | grep "gpg: encrypted with"
```

**Session key attacks:** [Unverified] In some CTF scenarios, weak session keys or implementation flaws may be exploitable.

```bash
# Extract session key (if you have the private key)
gpg --show-session-key --decrypt encrypted.asc

# Use extracted session key
gpg --override-session-key SESSIONKEY --decrypt encrypted.asc
```

## Blockchain Analysis Basics

Blockchain analysis involves tracing cryptocurrency transactions and extracting intelligence from public ledgers. Most blockchains are pseudonymous, not anonymous.

### Bitcoin Fundamentals for OSINT

**Key concepts:**

- Address: Public identifier (starts with 1, 3, or bc1)
- Transaction: Transfer of value between addresses
- Block: Container of transactions
- UTXO: Unspent Transaction Output
- Transaction ID (TXID): Unique transaction identifier

**Address formats:**

- P2PKH (Legacy): Starts with 1, e.g., 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
- P2SH (Script): Starts with 3, e.g., 3J98t1WpEZ73CNmYviecrnyiWrnqRhWNLy
- Bech32 (SegWit): Starts with bc1, e.g., bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq

### Blockchain Explorers

**Major explorers:**

- Blockchain.com: https://www.blockchain.com/explorer
- Blockchair: https://blockchair.com/
- OXT.me: https://oxt.me/ (privacy-focused analysis)
- BlockCypher: https://live.blockcypher.com/
- Etherscan: https://etherscan.io/ (Ethereum)

**Manual address lookup:**

```bash
# Using blockchain.com API
curl "https://blockchain.info/rawaddr/1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

# Using Blockchair API
curl "https://api.blockchair.com/bitcoin/dashboards/address/1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

# Get transaction details
curl "https://blockchain.info/rawtx/TXID"

# Get current balance
curl "https://blockchain.info/q/addressbalance/ADDRESS"

# Get total received
curl "https://blockchain.info/q/getreceivedbyaddress/ADDRESS"
```

### Bitcoin Address Analysis

**Address validation:**

```python
#!/usr/bin/env python3
import hashlib
import base58

def validate_bitcoin_address(address):
    try:
        decoded = base58.b58decode(address)
        # Check length (25 bytes: 1 version + 20 hash + 4 checksum)
        if len(decoded) != 25:
            return False
        
        # Verify checksum
        checksum = decoded[-4:]
        payload = decoded[:-4]
        hash_result = hashlib.sha256(hashlib.sha256(payload).digest()).digest()
        
        return hash_result[:4] == checksum
    except:
        return False

# Usage
print(validate_bitcoin_address("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"))
```

**Transaction graph analysis:**

```python
#!/usr/bin/env python3
import requests
import networkx as nx

def build_transaction_graph(address, depth=2):
    """Build transaction graph from address"""
    G = nx.DiGraph()
    visited = set()
    
    def crawl(addr, current_depth):
        if current_depth > depth or addr in visited:
            return
        
        visited.add(addr)
        
        # Fetch transactions
        url = f"https://blockchain.info/rawaddr/{addr}?limit=50"
        response = requests.get(url)
        data = response.json()
        
        for tx in data.get('txs', []):
            # Analyze inputs and outputs
            for inp in tx.get('inputs', []):
                prev_addr = inp.get('prev_out', {}).get('addr')
                if prev_addr:
                    G.add_edge(prev_addr, addr)
            
            for out in tx.get('out', []):
                out_addr = out.get('addr')
                if out_addr:
                    G.add_edge(addr, out_addr)
                    crawl(out_addr, current_depth + 1)
    
    crawl(address, 0)
    return G

# Usage (be mindful of rate limits)
# graph = build_transaction_graph("ADDRESS", depth=1)
```

**Common OSINT patterns:**

```bash
# Identify exchange deposit addresses
# [Inference] Multiple small deposits to single address suggest exchange

# Identify mixing services
# [Inference] Many inputs, many outputs, similar amounts suggest tumbler

# Identify change addresses
# [Inference] Transaction with 2 outputs: one to recipient, one back to sender
```

### Transaction Tracing

**Input/output analysis:**

```bash
# Get transaction details
curl "https://blockchain.info/rawtx/TXID?format=json" | jq

# Analyze inputs
curl "https://blockchain.info/rawtx/TXID?format=json" | jq '.inputs[] | .prev_out.addr'

# Analyze outputs
curl "https://blockchain.info/rawtx/TXID?format=json" | jq '.out[] | {addr: .addr, value: .value}'

# Calculate fees
# Fee = Sum(inputs) - Sum(outputs)
```

**Python transaction analysis:**

```python
#!/usr/bin/env python3
import requests

def analyze_transaction(txid):
    url = f"https://blockchain.info/rawtx/{txid}"
    response = requests.get(url)
    tx = response.json()
    
    # Extract inputs
    inputs = []
    total_input = 0
    for inp in tx['inputs']:
        addr = inp['prev_out']['addr']
        value = inp['prev_out']['value']
        inputs.append({'address': addr, 'value': value})
        total_input += value
    
    # Extract outputs
    outputs = []
    total_output = 0
    for out in tx['out']:
        addr = out.get('addr', 'Unknown')
        value = out['value']
        outputs.append({'address': addr, 'value': value})
        total_output += value
    
    fee = total_input - total_output
    
    return {
        'txid': txid,
        'inputs': inputs,
        'outputs': outputs,
        'fee': fee,
        'total_input': total_input,
        'total_output': total_output
    }

# Usage
# result = analyze_transaction("TXID")
```

**Temporal analysis:**

```bash
# Get block timestamp
curl "https://blockchain.info/rawtx/TXID?format=json" | jq '.time'

# Convert to readable date
date -d @TIMESTAMP

# Transaction velocity (time between transactions)
# [Inference] Regular intervals may indicate automated systems
```

### Clustering and Heuristics

**Common input heuristic:** [Inference] When a transaction has multiple inputs, they likely belong to the same entity (same wallet).

```python
def cluster_by_common_input(transactions):
    """Group addresses that appear together as inputs"""
    clusters = []
    address_to_cluster = {}
    
    for tx in transactions:
        input_addrs = [inp['address'] for inp in tx['inputs']]
        
        # Find existing clusters
        existing_clusters = set()
        for addr in input_addrs:
            if addr in address_to_cluster:
                existing_clusters.add(address_to_cluster[addr])
        
        # Merge clusters or create new one
        if existing_clusters:
            # Merge all existing clusters
            merged = set()
            for cluster_id in existing_clusters:
                merged.update(clusters[cluster_id])
            merged.update(input_addrs)
            
            # Update mappings
            new_cluster_id = min(existing_clusters)
            clusters[new_cluster_id] = merged
            for addr in merged:
                address_to_cluster[addr] = new_cluster_id
        else:
            # Create new cluster
            cluster_id = len(clusters)
            clusters.append(set(input_addrs))
            for addr in input_addrs:
                address_to_cluster[addr] = cluster_id
    
    return clusters
```

**Change address detection:** [Inference] In transactions with 2 outputs where one is significantly smaller or to a new address, the smaller/new one is likely change.

**Round number heuristic:** [Inference] Outputs with round numbers (1.0, 0.5, etc.) are likely payments; non-round outputs are likely change.

### Exchange and Service Identification

**Known address databases:**

- WalletExplorer.com: Clusters addresses by wallet
- Bitcoin Abuse Database: Reported scam addresses
- Chainalysis: Commercial blockchain analysis (limited free data)

**API-based identification:**

```bash
# Check if address is exchange
curl "https://api.blockchair.com/bitcoin/dashboards/address/ADDRESS" | jq '.data[].address.type'

# Search Bitcoin Abuse database
curl "https://www.bitcoinabuse.com/api/reports/check?address=ADDRESS"
```

**Pattern recognition:**

- High transaction volume → Exchange or service
- Many unique counterparties → Merchant or exchange
- Regular timing → Automated service
- Peel chain pattern → Gradual fund dispersal

### Privacy Coins and Mixers

**CoinJoin detection:** [Inference] Transactions with many equal-value outputs suggest CoinJoin mixing.

```bash
# Identify CoinJoin characteristics:
# - Multiple inputs from different addresses
# - Multiple outputs with identical values
# - Larger transaction size

# Tools for CoinJoin analysis:
# - OXT.me CoinJoin detection
# - Kycp.org CoinJoin tracker
```

**Monero (privacy coin):**

- Transactions use ring signatures (hide sender)
- Stealth addresses (hide receiver)
- RingCT (hide amounts) [Inference] Analysis is limited to timing correlations and exchange transactions where addresses are revealed.

**Tornado Cash (Ethereum mixer):**

```bash
# Analyze Tornado Cash deposits/withdrawals
# Look for timing patterns
# Check deposit/withdrawal amounts (must match pool denominations)

# Etherscan API
curl "https://api.etherscan.io/api?module=account&action=txlist&address=TORNADO_CASH_ADDRESS&apikey=APIKEY"
```

### Ethereum and Smart Contract Analysis

**Ethereum address lookup:**

```bash
# Using Etherscan API
curl "https://api.etherscan.io/api?module=account&action=balance&address=0x...&tag=latest&apikey=APIKEY"

# Get token transfers
curl "https://api.etherscan.io/api?module=account&action=tokentx&address=0x...&apikey=APIKEY"

# Get internal transactions
curl "https://api.etherscan.io/api?module=account&action=txlistinternal&address=0x...&apikey=APIKEY"
```

**Smart contract analysis:**

```bash
# Get contract source code
curl "https://api.etherscan.io/api?module=contract&action=getsourcecode&address=0x...&apikey=APIKEY"

# Get ABI (Application Binary Interface)
curl "https://api.etherscan.io/api?module=contract&action=getabi&address=0x...&apikey=APIKEY"

# Decode contract transactions
# Use tools like ethtx.info or Etherscan's transaction decoder
```

**NFT tracking:**

```bash
# Get NFT transfers
curl "https://api.etherscan.io/api?module=account&action=tokennfttx&address=0x...&apikey=APIKEY"

# Identify NFT ownership
# Check ERC-721/ERC-1155 Transfer events

# Use OpenSea API for marketplace data
curl "https://api.opensea.io/api/v1/assets?owner=0x..."
```

### Bitcoin Script Analysis

**Common script types:**

```bash
# P2PKH (Pay to Public Key Hash)
OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG

# P2SH (Pay to Script Hash)
OP_HASH160 <scriptHash> OP_EQUAL

# P2WPKH (Pay to Witness Public Key Hash - SegWit)
OP_0 <pubKeyHash>

# Multisig
<m> <pubKey1> <pubKey2> ... <pubKeyN> <n> OP_CHECKMULTISIG
```

**Script extraction:**

```bash
# Using Bitcoin Core
bitcoin-cli getrawtransaction TXID 1 | jq '.vout[].scriptPubKey'

# Manual decoding
curl "https://blockchain.info/rawtx/TXID?format=hex"
# Parse hex manually or use bitcoin-cli decoderawtransaction
```

### Blockchain Tool Reference

**Command-line tools:**

- bitcoin-cli: Bitcoin Core RPC interface
- electrum: Bitcoin wallet with advanced features
- btcrecover: Bitcoin wallet password recovery
- pywallet: Python Bitcoin wallet manipulation

**Python libraries:**

- `bitcoinlib`: Bitcoin library for Python
- `web3.py`: Ethereum Python library
- `blockcypher`: BlockCypher API wrapper
- `bit`: Simple Bitcoin library

**Analysis platforms:**

- Maltego: Visual link analysis with blockchain transforms
- GraphSense: Open-source crypto analytics
- Crystal Blockchain: Commercial analytics platform

### Practical CTF Blockchain Scenarios

**Hidden messages in transactions:**

```bash
# OP_RETURN data extraction
curl "https://blockchain.info/rawtx/TXID?format=json" | jq '.out[] | select(.script != null) | .script'

# Decode OP_RETURN data
# OP_RETURN scripts start with 6a (OP_RETURN opcode)
echo "6a..." | xxd -r -p

# Check for ASCII/Base64 encoded messages
```

**Vanity address patterns:**

```bash
# Addresses with custom prefixes may indicate identity
# Example: 1BitcoinEaterAddressDontSendf59kuE

# Generate vanity address (reference)
vanitygen -i 1CTF
```

**Transaction puzzle solving:**

```bash
# Brain wallets (weak passphrases)
# Address derived from SHA-256 of passphrase

# Calculate address from passphrase
echo -n "passphrase" | sha256sum
# Use result as private key to derive address

# Tools: brainflayer (brain wallet cracker)
```

**Smart contract vulnerabilities:**

- Reentrancy attacks
- Integer overflow/underflow
- Unprotected functions [Inference] In CTF contexts, these may contain hidden flags or exploitable logic.

---

**Related subtopics for deeper exploration:**

- Advanced blockchain forensics (cross-chain analysis, DeFi protocol tracing)
- Lightning Network analysis
- Altcoin-specific analysis techniques (Litecoin, Bitcoin Cash, etc.)
- Blockchain data visualization and graph analysis tools
- Legal and ethical considerations in blockchain OSINT
- Cryptocurrency wallet forensics
- Dark web marketplace cryptocurrency tracing

---

# Network Analysis

## Open Port Scanning Ethics and Techniques

### Legal and Ethical Framework

**Authorized Scanning Only**: Port scanning without explicit permission is illegal in most jurisdictions under computer fraud and abuse laws (CFAA in US, Computer Misuse Act in UK). In CTF environments, scanning is authorized within the competition scope.

**Rules of Engagement for CTFs**:

- Scan only target IP ranges specified in competition rules
- Respect rate limits to avoid infrastructure disruption
- Document all scanning activities for writeups
- Never pivot to out-of-scope systems

### TCP Scanning Techniques

**TCP Connect Scan** (Full three-way handshake):

```bash
nmap -sT <target>
```

- Completes full TCP connection (SYN → SYN-ACK → ACK)
- Most reliable but logged by target systems
- No root privileges required
- Use when stealth is not required

**TCP SYN Scan** (Half-open/Stealth scan):

```bash
nmap -sS <target>
```

- Sends SYN, receives SYN-ACK, sends RST instead of ACK
- Faster and stealthier than connect scan
- Requires root/administrator privileges
- Default scan when running as root

**TCP NULL/FIN/Xmas Scans** (Firewall evasion):

```bash
nmap -sN <target>  # NULL scan (no flags)
nmap -sF <target>  # FIN flag only
nmap -sX <target>  # FIN, PSH, URG flags (Xmas)
```

- Exploit RFC 793 behavior: closed ports respond with RST
- Open ports should not respond (filtered/open|filtered)
- Effective against non-stateful firewalls
- Unreliable on Windows systems (respond differently to RFC)

**TCP ACK Scan** (Firewall rule mapping):

```bash
nmap -sA <target>
```

- Maps firewall rulesets, not open ports
- Unfiltered ports respond with RST
- Filtered ports respond with ICMP unreachable or no response

### UDP Scanning Techniques

**UDP Scan**:

```bash
nmap -sU <target>
nmap -sU --top-ports 100 <target>  # Scan most common UDP ports
nmap -sUV --version-intensity 0 <target>  # Fast version detection
```

- Sends UDP packets; closed ports return ICMP port unreachable
- Open|filtered when no response (UDP is connectionless)
- Very slow due to ICMP rate limiting (typically 1 packet/second)
- Critical for finding DNS (53), SNMP (161), TFTP (69), NTP (123)

**Combined TCP/UDP Scan**:

```bash
nmap -sSU -p T:80,443,U:53,161 <target>
```

### Comprehensive Port Scanning Strategy

**Discovery Phase** (Fast identification):

```bash
# Quick TCP scan of common ports
nmap -T4 -F <target>

# Top 1000 ports across TCP/UDP
nmap -sS -sU --top-ports 1000 <target>

# All TCP ports (0-65535)
nmap -p- <target>
```

**Deep Analysis Phase**:

```bash
# Service version detection
nmap -sV <target>
nmap -sV --version-intensity 9 <target>  # Aggressive version detection

# OS detection
nmap -O <target>
nmap -O --osscan-guess <target>  # Aggressive OS guessing

# NSE scripting for vulnerabilities
nmap -sC <target>  # Default scripts
nmap --script vuln <target>  # Vulnerability detection scripts
```

**Aggressive Comprehensive Scan**:

```bash
nmap -A -T4 -p- <target>
# -A: OS detection, version detection, script scanning, traceroute
# -T4: Aggressive timing (faster)
# -p-: All 65535 ports
```

### Timing and Performance Optimization

**Timing Templates** (-T0 through -T5):

```bash
nmap -T0 <target>  # Paranoid: IDS evasion, extremely slow
nmap -T1 <target>  # Sneaky: IDS evasion, very slow
nmap -T2 <target>  # Polite: Less bandwidth, slower
nmap -T3 <target>  # Normal: Default timing
nmap -T4 <target>  # Aggressive: Fast, assumes reliable network
nmap -T5 <target>  # Insane: Very fast, may miss ports/sacrifice accuracy
```

**Custom Timing Parameters**:

```bash
# Parallel host scanning
nmap --min-hostgroup 50 --max-hostgroup 100 <target-range>

# Parallel port probing
nmap --min-parallelism 10 --max-parallelism 100 <target>

# RTT timeout configuration
nmap --min-rtt-timeout 100ms --max-rtt-timeout 500ms <target>

# Scan delay (stealth)
nmap --scan-delay 1s <target>
nmap --max-scan-delay 2s <target>
```

### Firewall and IDS Evasion Techniques

**Fragmentation**:

```bash
nmap -f <target>  # Fragment packets into 8-byte chunks
nmap --mtu 16 <target>  # Custom MTU (must be multiple of 8)
```

**Decoy Scanning**:

```bash
nmap -D RND:10 <target>  # Use 10 random decoy IPs
nmap -D decoy1,decoy2,ME,decoy3 <target>  # Specific decoys (ME = your IP)
```

**Source Port Manipulation**:

```bash
nmap --source-port 53 <target>  # Spoof source port (DNS)
nmap -g 80 <target>  # Alternative syntax
```

**IP Spoofing** (requires packet crafting):

```bash
nmap -S <spoofed-ip> <target>  # Spoof source IP
nmap -e eth0 -Pn -S <spoofed-ip> <target>  # Specify interface, no ping
```

**Idle Scan** (Zombie host technique):

```bash
nmap -sI <zombie-host> <target>
# Uses predictable IPID increments on zombie host
# Completely blind scan from zombie's perspective
```

### Output Formats and Reporting

```bash
# Multiple output formats simultaneously
nmap -oA scan_results <target>
# Creates: scan_results.nmap, scan_results.xml, scan_results.gnmap

# Individual format options
nmap -oN output.txt <target>  # Normal output
nmap -oX output.xml <target>  # XML output
nmap -oG output.gnmap <target>  # Grepable output
nmap -oS output.skid <target>  # Script kiddie format

# Append to existing file
nmap --append-output -oN existing.txt <target>
```

### Advanced Port Specification

```bash
# Specific ports
nmap -p 22,80,443 <target>

# Port ranges
nmap -p 1-1000 <target>
nmap -p- <target>  # All ports (1-65535)

# Named services
nmap -p http,https,ssh <target>

# Protocol-specific ports
nmap -p U:53,161,T:21-25,80,443 <target>

# Exclude ports
nmap --exclude-ports 25,135,445 <target>
```

### NSE (Nmap Scripting Engine) for Deep Analysis

**Script Categories**:

```bash
# Default safe scripts
nmap -sC <target>
nmap --script default <target>

# Vulnerability scanning
nmap --script vuln <target>

# Authentication testing
nmap --script auth <target>

# Brute force attacks
nmap --script brute <target>

# Service discovery
nmap --script discovery <target>

# Specific script
nmap --script http-enum <target>

# Multiple scripts
nmap --script "http-* and not http-brute" <target>

# Script with arguments
nmap --script http-enum --script-args http-enum.basepath='/admin/' <target>
```

**Useful CTF Scripts**:

```bash
# SMB enumeration
nmap --script smb-enum-shares,smb-enum-users -p 445 <target>

# FTP anonymous login
nmap --script ftp-anon -p 21 <target>

# HTTP title and methods
nmap --script http-title,http-methods -p 80,443 <target>

# SSH authentication methods
nmap --script ssh-auth-methods -p 22 <target>

# DNS zone transfer
nmap --script dns-zone-transfer --script-args dns-zone-transfer.domain=<domain> -p 53 <target>
```

## Network Mapping

### Host Discovery Techniques

**Ping Sweeps** (Layer 3 discovery):

```bash
# ICMP echo request (traditional ping)
nmap -sn <target-range>  # Ping scan, no port scan
nmap -sn -PE <target-range>  # ICMP echo explicitly

# TCP SYN ping
nmap -sn -PS22,80,443 <target-range>  # SYN to specific ports

# TCP ACK ping
nmap -sn -PA80,443 <target-range>  # ACK to specific ports

# UDP ping
nmap -sn -PU53,161 <target-range>  # UDP to specific ports

# ICMP variants
nmap -sn -PP <target-range>  # ICMP timestamp request
nmap -sn -PM <target-range>  # ICMP address mask request

# ARP ping (local network only)
nmap -sn -PR <target-range>  # ARP requests (most reliable on LAN)

# No ping (skip host discovery)
nmap -Pn <target>  # Treat host as online
```

**Network Range Notation**:

```bash
# CIDR notation
nmap -sn 192.168.1.0/24

# Octet ranges
nmap -sn 192.168.1.1-254

# Multiple targets
nmap -sn 192.168.1.0/24 10.0.0.0/8

# Input file
nmap -sn -iL targets.txt

# Exclude hosts
nmap -sn 192.168.1.0/24 --exclude 192.168.1.1,192.168.1.254
nmap -sn 192.168.1.0/24 --excludefile exclude.txt
```

### Traceroute and Path Analysis

**Nmap Traceroute**:

```bash
nmap --traceroute <target>
nmap -sn --traceroute <target>  # Just traceroute, no port scan

# Traceroute with port scanning
nmap -A --traceroute <target>
```

**Traditional Traceroute Tools**:

```bash
# Linux/Unix traceroute (UDP by default)
traceroute <target>
traceroute -I <target>  # ICMP echo
traceroute -T <target>  # TCP SYN
traceroute -p 80 <target>  # Specific port

# Windows tracert (ICMP)
tracert <target>

# MTR (My Traceroute) - combines ping and traceroute
mtr <target>
mtr -r -c 100 <target>  # Report mode, 100 cycles
mtr -b <target>  # Show both hostnames and IPs
```

### Network Topology Mapping Tools

**Masscan** (Extremely fast port scanner):

```bash
# Basic scan
masscan -p80,443 192.168.1.0/24

# Fast full port scan
masscan -p0-65535 192.168.1.0/24 --rate 10000

# Specific ports with rate limiting
masscan -p22,80,443,3389 10.0.0.0/8 --rate 100000

# Output formats
masscan -p80,443 192.168.1.0/24 -oL output.txt  # List format
masscan -p80,443 192.168.1.0/24 -oX output.xml  # XML format
masscan -p80,443 192.168.1.0/24 -oJ output.json  # JSON format

# Banner grabbing
masscan -p80,443 192.168.1.0/24 --banners

# Exclude ranges
masscan -p80 10.0.0.0/8 --exclude 10.0.1.0/24
```

[Inference] Masscan claims transmission rates up to 25 million packets/second; actual performance depends on network hardware and configuration.

**Zmap** (Single-port Internet-wide scanner):

```bash
# Basic scan
zmap -p 443 192.168.1.0/24

# Output to file
zmap -p 80 10.0.0.0/8 -o results.txt

# Bandwidth limiting
zmap -p 443 -B 10M 192.168.1.0/24  # 10 Mbps

# Probe modules
zmap -p 80 --probe-module=tcp_synscan 192.168.1.0/24
zmap -p 53 --probe-module=udp 192.168.1.0/24

# Output fields
zmap -p 443 --output-fields=* 192.168.1.0/24
```

**Netdiscover** (ARP-based discovery):

```bash
# Passive mode (sniffs ARP traffic)
netdiscover -p

# Active mode on interface
netdiscover -i eth0

# Scan specific range
netdiscover -r 192.168.1.0/24

# Fast mode
netdiscover -r 192.168.1.0/24 -f
```

### Network Graph Visualization

**Nmap XML to Visual Graphs**:

```bash
# Generate XML output
nmap -oX scan.xml -A --traceroute <target-range>

# Convert with tools (examples of available tools):
# - Zenmap (GUI for nmap with topology view)
# - ndiff (compares scan results)
```

### Service and Banner Analysis

**Banner Grabbing Techniques**:

```bash
# Netcat banner grab
nc -v <target> <port>

# Specific protocols
nc -v <target> 22  # SSH
nc -v <target> 25  # SMTP (then type: EHLO test)
nc -v <target> 80  # HTTP (then type: GET / HTTP/1.0)

# Timeout specification
nc -v -w 3 <target> <port>

# UDP banner grab
nc -u -v <target> <port>
```

**Telnet for Banner Grabbing**:

```bash
telnet <target> <port>

# HTTP example
telnet <target> 80
GET / HTTP/1.0
Host: <target>
[press Enter twice]
```

**Amap** (Application protocol detection):

```bash
amap -bq <target> <port>
amap -A <target> 1-1000  # All ports in range
```

### Network Protocol Analysis

**ARP Analysis**:

```bash
# View ARP cache
arp -a
ip neigh show

# Scan with arping
arping -c 3 192.168.1.1

# ARP scan with arp-scan
arp-scan -l  # Local network
arp-scan -I eth0 192.168.1.0/24
arp-scan --bandwidth=10000000 192.168.1.0/24  # Fast scan
```

## WiFi Geolocation

### WiFi Network Discovery

**Passive WiFi Scanning** (Linux with wireless adapter):

```bash
# Interface setup
ip link set wlan0 down
iw dev wlan0 set type monitor
ip link set wlan0 up

# Scan for networks
iwlist wlan0 scan

# Detailed scanning with airodump-ng
airodump-ng wlan0mon
airodump-ng --band abg wlan0mon  # All bands (2.4GHz + 5GHz)
airodump-ng -c 6 --bssid <MAC> -w capture wlan0mon  # Specific channel/AP
```

**Wireless Information Extraction**:

```bash
# Current connection info
iwconfig
iw dev wlan0 info
iw dev wlan0 link

# Network manager
nmcli device wifi list
nmcli -f ALL device wifi list  # All details
```

### WiFi Geolocation APIs and Databases

**WiGLE (Wireless Geographic Logging Engine)**:

- Website: https://wigle.net
- Crowdsourced WiFi location database
- API available for BSSID → GPS coordinate lookups
- Search by SSID, BSSID, or location coordinates

**API Query Structure** [Unverified - check WiGLE API documentation]:

```bash
# Example curl request format (requires API key)
curl -u apikey:token "https://api.wigle.net/api/v2/network/search?onlymine=false&freenet=false&paynet=false&ssid=<SSID>"
```

**Google Geolocation API**:

- Uses WiFi MAC addresses (BSSID) for location
- Combined with cell tower data for accuracy
- Requires API key from Google Cloud Platform

**Mozilla Location Service (MLS)**:

- Open geolocation service
- API endpoint: https://location.services.mozilla.com

### BSSID Analysis for Geolocation

**BSSID Format and Information**:

- Format: XX:XX:XX:XX:XX:XX (MAC address)
- First 3 octets (OUI): Manufacturer identification
- Can identify router vendor/model

**OUI Lookup**:

```bash
# Online databases
# - https://maclookup.app
# - https://www.wireshark.org/tools/oui-lookup.html

# Command-line lookup with macchanger
macchanger -l | grep -i "<vendor>"

# Python script example for API lookup
curl "https://api.maclookup.app/v2/macs/<MAC-address>"
```

### Wardriving Tools and Techniques

**Kismet** (WiFi detector, sniffer, IDS):

```bash
# Start Kismet server
kismet -c wlan0mon

# Web interface: http://localhost:2501

# GPS integration (with GPSD)
gpsd /dev/ttyUSB0
kismet -c wlan0mon --override gps=true
```

**WiFite** (Automated wireless auditing):

```bash
# Basic scan and attack
wifite

# Specific options
wifite --no-wps  # Disable WPS attacks
wifite --wpa  # Only WPA networks
wifite --dict /path/to/wordlist.txt
```

**Mobile Wardriving Apps**:

- WiGLE WiFi Wardriving (Android)
- WiFi Map (iOS/Android)
- Network Analyzer (iOS)

### Trilateration and Signal Strength

**RSSI (Received Signal Strength Indicator) Analysis**:

- Signal strength measured in dBm (typically -30 to -90 dBm)
- Closer values (e.g., -30 dBm) = stronger signal = closer proximity
- Distance estimation: [Speculation] Path loss models vary significantly by environment

**Distance Estimation Formula** [Inference - simplified free-space path loss]:

```
RSSI = -10n * log10(d) + A
Where:
- n = path loss exponent (typically 2-4)
- d = distance in meters
- A = RSSI at 1 meter reference distance
```

**Trilateration Requirements**:

- Minimum 3 access points with known locations
- RSSI measurements from target device to each AP
- Path loss modeling for environment

## MAC Address Analysis

### MAC Address Structure

**Format**: XX:XX:XX:XX:XX:XX (48-bit address)

**Components**:

- **OUI (Organizationally Unique Identifier)**: First 24 bits (3 octets)
    - Assigned by IEEE to manufacturers
    - Identifies device vendor
- **NIC (Network Interface Controller) Specific**: Last 24 bits
    - Assigned by manufacturer
    - Should be unique per device

**Address Types** (determined by first octet):

```
Bit 0 (LSB of first octet): Individual (0) or Group/Multicast (1)
Bit 1: Globally unique (0) or Locally administered (1)

Examples:
00:1A:2B:3C:4D:5E - Unicast, globally unique
01:1A:2B:3C:4D:5E - Multicast
02:1A:2B:3C:4D:5E - Unicast, locally administered
03:1A:2B:3C:4D:5E - Multicast, locally administered
```

### MAC Address Lookup and OSINT

**OUI Database Lookups**:

```bash
# IEEE OUI database
# https://standards-oui.ieee.org/oui/oui.txt

# Automated lookups
curl "https://api.macvendors.com/<MAC-address>"
curl "https://api.maclookup.app/v2/macs/<MAC-address>"

# Command-line tool: mac-vendor-lookup
pip install mac-vendor-lookup
mac-vendor-lookup <MAC-address>
```

**Wireshark OUI Lookup**:

- Built-in OUI database in Wireshark installation
- Location (Linux): `/usr/share/wireshark/manuf`
- Command-line lookup:

```bash
grep -i "<first-3-octets>" /usr/share/wireshark/manuf
```

### MAC Address Spoofing Detection

**Indicators of Spoofed MAC**:

- Locally administered bit set (second hex digit = 2, 6, A, E)
- Common default spoofed MACs (00:00:00:00:00:00, DE:AD:BE:EF:xx:xx)
- OUI mismatches with known device type
- Duplicate MACs on same network segment

**Detection Commands**:

```bash
# ARP table monitoring for duplicates
arp -a | sort
ip neigh show

# Continuous ARP monitoring
arpwatch -i eth0

# Packet capture analysis
tcpdump -i eth0 -e -n arp
```

### MAC Address Randomization

**Modern Privacy Features**:

- iOS (since iOS 14): Private WiFi Address feature
- Android (since Android 10): MAC randomization by default
- Windows 10/11: Random hardware addresses

**Identifying Randomized MACs**:

- Locally administered bit set (02:xx:xx:xx:xx:xx)
- Changes between network connections or time intervals
- Not found in OUI database (or generic entry)

### Bluetooth MAC Address Analysis

**Bluetooth Device Address (BD_ADDR)**:

- Same 48-bit format as WiFi MAC
- OUI portion identifies manufacturer
- Used for device pairing and identification

**Bluetooth Scanning**:

```bash
# HCI tools (Linux)
hciconfig  # List Bluetooth adapters
hcitool scan  # Discover devices
hcitool info <BD_ADDR>  # Device information

# Bluetooth Low Energy scanning
hcitool lescan
```

### Vendor-Specific MAC Patterns

**Common Manufacturer Prefixes** [Examples]:

```
00:50:56:xx:xx:xx - VMware virtual NICs
08:00:27:xx:xx:xx - VirtualBox virtual NICs
00:0C:29:xx:xx:xx - VMware virtual NICs
00:1C:42:xx:xx:xx - Parallels virtual NICs
00:16:3E:xx:xx:xx - Xen virtual NICs
DC:A6:32:xx:xx:xx - Raspberry Pi Foundation
B8:27:EB:xx:xx:xx - Raspberry Pi Foundation (older)
```

### MAC Address Intelligence in CTFs

**OSINT from MAC Addresses**:

1. **Device Type Identification**: OUI reveals manufacturer (iPhone, Cisco router, Raspberry Pi)
2. **Physical Location Clues**: Combined with WiFi geolocation
3. **Network Segmentation**: MAC patterns may indicate VLAN or subnet organization
4. **Virtualization Detection**: Virtual MAC prefixes indicate VM environments
5. **Age Estimation**: [Inference] Older OUI assignments may suggest older hardware

## Network Device Fingerprinting

### TCP/IP Stack Fingerprinting

**Nmap OS Detection**:

```bash
# Basic OS detection
nmap -O <target>

# Aggressive OS detection
nmap -O --osscan-guess <target>
nmap -O --osscan-limit <target>  # Only fingerprint promising targets
nmap -O --max-os-tries 3 <target>

# With additional details
nmap -A <target>  # Includes OS, version, scripts
```

**OS Detection Methodology** [Based on Nmap documentation]:

- TCP/IP stack implementation variations
- Window sizes, TTL values, options ordering
- Response to crafted malformed packets
- TCP timestamp analysis
- ICMP responses and error messages

**P0f (Passive OS Fingerprinting)**:

```bash
# Start passive fingerprinting
p0f -i eth0

# Read from pcap
p0f -r capture.pcap

# Output to file
p0f -i eth0 -o fingerprints.log
```

### Service Version Detection

**Nmap Version Detection**:

```bash
# Standard version detection
nmap -sV <target>

# Version intensity levels (0-9)
nmap -sV --version-intensity 0 <target>  # Light probes only
nmap -sV --version-intensity 9 <target>  # All probes

# Specific ports
nmap -sV -p 22,80,443 <target>

# Version detection with scripts
nmap -sV -sC <target>
```

**Version Detection Techniques**:

- Banner grabbing and parsing
- Protocol-specific probes (HTTP, FTP, SSH, etc.)
- Application fingerprints database
- Response pattern matching

**Manual Version Identification**:

```bash
# HTTP server identification
curl -I http://<target>
curl -I http://<target> | grep -i server

# SSH version
ssh -v <target>
nc <target> 22  # Banner grab

# FTP version
nc <target> 21

# SMTP version
nc <target> 25
# Then type: EHLO test
```

### TLS/SSL Fingerprinting

**SSLyze** (SSL/TLS scanner):

```bash
# Basic scan
sslyze <target>

# Specific tests
sslyze --regular <target>
sslyze --certinfo <target>
sslyze --compression <target>

# Vulnerabilities
sslyze --heartbleed <target>
sslyze --robot <target>
```

**Nmap SSL Scripts**:

```bash
# SSL certificate information
nmap --script ssl-cert -p 443 <target>

# SSL/TLS enumeration
nmap --script ssl-enum-ciphers -p 443 <target>

# Vulnerabilities
nmap --script ssl-heartbleed -p 443 <target>
nmap --script ssl-poodle -p 443 <target>
```

**OpenSSL Manual Testing**:

```bash
# Connect and retrieve certificate
openssl s_client -connect <target>:443

# Show certificate details
openssl s_client -connect <target>:443 -showcerts

# Specific TLS version
openssl s_client -connect <target>:443 -tls1_2
openssl s_client -connect <target>:443 -tls1_3

# Cipher suite testing
openssl s_client -connect <target>:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'
```

**JA3/JA3S Fingerprinting**:

- JA3: Client TLS fingerprint (based on TLS handshake)
- JA3S: Server TLS fingerprint
- Creates MD5 hash from TLS parameters
- Can identify specific applications/malware

### HTTP/Application Fingerprinting

**Wappalyzer-style Technology Detection**:

```bash
# Whatweb (identifies CMS, frameworks, servers)
whatweb <target>
whatweb -v <target>  # Verbose
whatweb -a 3 <target>  # Aggression level (1-4)

# Specific plugins
whatweb --list-plugins
whatweb -p WordPress,Apache <target>
```

**HTTP Header Analysis**:

```bash
# Headers with curl
curl -I <target>

# All headers
curl -v <target>

# Specific header extraction
curl -s -I <target> | grep -i server
curl -s -I <target> | grep -i x-powered-by
```

**Application-Specific Tools**:

```bash
# WordPress scanning
wpscan --url <target>
wpscan --url <target> --enumerate u,p,t  # Users, plugins, themes

# Drupal scanning
droopescan scan drupal -u <target>

# Joomla scanning
joomscan -u <target>
```

### Network Behavior Fingerprinting

**TTL (Time To Live) Analysis**:

- Default TTL values by OS [Common values]:
    - Linux/Unix: 64
    - Windows: 128
    - Cisco/Network devices: 255
    - Solaris: 255

**Detection via Ping**:

```bash
ping -c 1 <target>
# Observe TTL in response
# Calculate hops: Initial_TTL - Received_TTL = hop_count
```

**Packet Analysis with Tcpdump/Wireshark**:

```bash
# Capture for fingerprinting
tcpdump -i eth0 -w capture.pcap host <target>

# Specific protocol analysis
tcpdump -i eth0 -A 'tcp port 80' host <target>
```

### Device Behavior Patterns

**Timing Analysis**:

- Response time patterns
- Connection establishment timing
- Keep-alive intervals

**Protocol Implementation Quirks**:

- Non-standard responses to edge cases
- Error message formats
- Optional header support

**Load Balancer Detection**:

```bash
# Multiple requests to detect different backend servers
for i in {1..10}; do curl -I http://<target> | grep -i server; done

# Nmap script
nmap --script http-load-balancer-detection <target>
```

### Firewall and Security Device Fingerprinting

**Firewall Detection Methods**:

```bash
# TTL manipulation detection
nmap --ttl 128 <target>
nmap --badsum <target>  # Invalid checksums

# ACK scan for firewall rules
nmap -sA <target>

# Firewall identification scripts
nmap --script firewalk <target>
nmap --script firewall-bypass <target>
```

**WAF (Web Application Firewall) Detection**:

```bash
# Wafw00f
wafw00f <target>
wafw00f -a <target>  # Test all payloads

# Nmap WAF detection
nmap --script http-waf-detect <target>
nmap --script http-waf-fingerprint <target>
```

### Consolidated Fingerprinting Workflow

**Reconnaissance Phase**:

```bash
# 1. Network discovery
nmap -sn <target-range>

# 2. Port scanning
nmap -sS -sU --top-ports 1000 <target>

# 3. Service detection
nmap -sV -sC -A <target>

# 4. OS fingerprinting
nmap -O --osscan-guess <target>

# 5. Passive analysis
p0f -i eth0 &
tcpdump -i eth0 -w passive.pcap host <target>

# 6. Application fingerprinting
whatweb -a 3 http://<target>
wafw00f http://<target>
```

**Important Related Topics**:

- IPv6 network reconnaissance (requires different techniques and tools)
- Network traffic analysis and packet inspection (Wireshark/tcpdump deep-dive)
- Wireless attack vectors (WPA/WPA2/WPA3 exploitation)
- SDR (Software Defined Radio) for RF analysis
- DNS enumeration and zone transfers
- SNMP enumeration (community string attacks, MIB walking)
- Cloud infrastructure fingerprinting (AWS, Azure, GCP identification)

---

# Mobile and App Intelligence

## Mobile OSINT Techniques

### Device Information Gathering

**IMEI/IMSI Analysis:**

**IMEI Structure:**

- 15-digit identifier: `TAC (8 digits) + SNR (6 digits) + CD (1 digit)`
- TAC (Type Allocation Code): Manufacturer/model identifier
- SNR (Serial Number): Unique device identifier
- CD (Check Digit): Luhn algorithm verification

**IMEI Lookup:**

```bash
# Query IMEI database
curl "https://www.imei.info/api/check-imei/?imei=123456789012345"

# Extract device information
# [Unverified] Free API limits may apply

# Alternative: GSMA IMEI Database
# Requires authorized access for detailed queries
```

**IMSI (International Mobile Subscriber Identity):**

```
Format: MCC (3) + MNC (2-3) + MSIN (9-10)
- MCC: Mobile Country Code
- MNC: Mobile Network Code  
- MSIN: Mobile Subscription Identification Number
```

**Carrier Identification:**

```python
def parse_imsi(imsi):
    """Extract carrier information from IMSI"""
    mcc = imsi[:3]
    mnc = imsi[3:5] if len(imsi[3:5]) == 2 else imsi[3:6]
    
    # MCC database lookup
    mcc_database = {
        '310': 'United States',
        '311': 'United States',
        '001': 'Test Network',
        '234': 'United Kingdom',
        '262': 'Germany'
        # [Inference] Full database contains 900+ entries
    }
    
    country = mcc_database.get(mcc, 'Unknown')
    return {'country': country, 'mcc': mcc, 'mnc': mnc}
```

### Phone Number Intelligence

**PhoneInfoga Framework:**

```bash
# Install
git clone https://github.com/sundowndev/phoneinfoga
cd phoneinfoga
go install

# Basic scan
phoneinfoga scan -n +1234567890

# Output includes:
# - Carrier information
# - Location data
# - Line type (mobile/landline/VoIP)
# - Validation status

# Advanced scanning
phoneinfoga scan -n +1234567890 --output json > results.json

# Google Dorks integration
phoneinfoga scan -n +1234567890 --scanner googlesearch
```

**Number Validation and Formatting:**

```python
import phonenumbers
from phonenumbers import geocoder, carrier, timezone

def analyze_phone_number(number):
    """Comprehensive phone number analysis"""
    try:
        parsed = phonenumbers.parse(number, None)
        
        analysis = {
            'valid': phonenumbers.is_valid_number(parsed),
            'country': geocoder.description_for_number(parsed, 'en'),
            'carrier': carrier.name_for_number(parsed, 'en'),
            'timezone': timezone.time_zones_for_number(parsed),
            'number_type': phonenumbers.number_type(parsed),
            'international_format': phonenumbers.format_number(
                parsed, 
                phonenumbers.PhoneNumberFormat.INTERNATIONAL
            ),
            'e164_format': phonenumbers.format_number(
                parsed,
                phonenumbers.PhoneNumberFormat.E164
            )
        }
        
        # Number type interpretation
        type_map = {
            0: 'FIXED_LINE',
            1: 'MOBILE',
            2: 'FIXED_LINE_OR_MOBILE',
            3: 'TOLL_FREE',
            4: 'PREMIUM_RATE',
            5: 'SHARED_COST',
            6: 'VOIP',
            7: 'PERSONAL_NUMBER',
            8: 'PAGER',
            9: 'UAN',
            10: 'VOICEMAIL'
        }
        
        analysis['type_description'] = type_map.get(
            analysis['number_type'], 
            'UNKNOWN'
        )
        
        return analysis
        
    except phonenumbers.NumberParseException as e:
        return {'error': str(e)}

# Usage
result = analyze_phone_number('+14155552671')
```

**Social Media Discovery:**

```bash
# Signal messenger verification
# [Inference] Signal uses phone numbers as identifiers

# Telegram username search
curl -s "https://t.me/+1234567890" | grep -o "username"

# WhatsApp verification
# [Unverified] WhatsApp number validation requires API access

# Search phone in data breach databases
# Using tools like: h8mail, holehe
```

### Mobile App Reverse Engineering

**APK Analysis Workflow:**

**Basic APK Extraction:**

```bash
# Download APK from device
adb pull /data/app/com.example.app/base.apk

# Alternative: Download from APKMirror, APKPure
# [Inference] Verify APK signatures to ensure authenticity

# Extract APK contents
unzip base.apk -d extracted_apk/

# View manifest
aapt dump badging base.apk
aapt dump permissions base.apk
```

**APKTool - Decompilation:**

```bash
# Install apktool
apt install apktool

# Decompile APK
apktool d base.apk -o decompiled_app

# Directory structure:
# - AndroidManifest.xml (readable format)
# - smali/ (Dalvik bytecode)
# - res/ (resources)
# - assets/ (embedded files)
# - lib/ (native libraries)

# Recompile after modifications
apktool b decompiled_app -o modified.apk

# Sign APK
keytool -genkey -v -keystore my-key.keystore -alias app-key \
  -keyalg RSA -keysize 2048 -validity 10000

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore my-key.keystore modified.apk app-key
```

**Jadx - Java Decompiler:**

```bash
# Install jadx
apt install jadx

# Decompile to Java source
jadx base.apk -d jadx_output/

# GUI mode
jadx-gui base.apk

# Export Gradle project
jadx base.apk -d jadx_output/ --export-gradle

# Search for sensitive strings
grep -r "api_key" jadx_output/
grep -r "password" jadx_output/
grep -r "http://" jadx_output/
grep -r "secret" jadx_output/
```

**MobSF - Mobile Security Framework:**

```bash
# Install via Docker
docker pull opensecurity/mobile-security-framework-mobsf
docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest

# Access web interface: http://localhost:8000

# Features:
# - Static analysis
# - Dynamic analysis (with emulator)
# - Malware analysis
# - API endpoint discovery
# - Security scorecard

# API usage
curl -X POST http://localhost:8000/api/v1/upload \
  -F "file=@app.apk" \
  -H "Authorization: API_KEY"
```

**Frida - Dynamic Instrumentation:**

```bash
# Install Frida
pip install frida-tools

# Start Frida server on device
adb push frida-server-16.0.19-android-arm64 /data/local/tmp/
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"

# List running processes
frida-ps -U

# Attach to app and hook functions
frida -U -l hook_script.js com.example.app
```

**Frida Hooking Script Examples:**

```javascript
// hook_script.js

// Hook SSL pinning bypass
Java.perform(function() {
    var CertificateFactory = Java.use('java.security.cert.CertificateFactory');
    
    CertificateFactory.generateCertificate.implementation = function(stream) {
        console.log('[+] SSL Pinning bypass - Certificate validation disabled');
        return this.generateCertificate(stream);
    };
    
    // Hook OkHttp certificate pinner
    var CertificatePinner = Java.use('okhttp3.CertificatePinner');
    CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function(hostname, peerCertificates) {
        console.log('[+] OkHttp pinning bypassed for: ' + hostname);
        return;
    };
});

// Extract API keys
Java.perform(function() {
    var BuildConfig = Java.use('com.example.app.BuildConfig');
    
    console.log('[+] API Key: ' + BuildConfig.API_KEY.value);
    console.log('[+] Secret: ' + BuildConfig.SECRET.value);
});

// Hook encryption methods
Java.perform(function() {
    var Cipher = Java.use('javax.crypto.Cipher');
    
    Cipher.doFinal.overload('[B').implementation = function(data) {
        console.log('[+] Cipher.doFinal called');
        console.log('[+] Input: ' + Java.use('java.lang.String').$new(data));
        
        var result = this.doFinal(data);
        console.log('[+] Output: ' + Java.use('java.lang.String').$new(result));
        
        return result;
    };
});

// Hook network requests
Java.perform(function() {
    var URL = Java.use('java.net.URL');
    
    URL.openConnection.implementation = function() {
        console.log('[+] HTTP Request: ' + this.toString());
        return this.openConnection();
    };
});
```

**Objection - Runtime Mobile Exploration:**

```bash
# Install objection
pip install objection

# Explore app
objection -g com.example.app explore

# Common commands:
android hooking list classes                    # List all classes
android hooking search classes keyword          # Search classes
android hooking watch class com.example.Class   # Watch class methods
android sslpinning disable                      # Disable SSL pinning
android root disable                            # Bypass root detection
android intent launch_activity com.example.Activity  # Launch activity

# Dump memory
memory dump all /tmp/memory_dump

# List loaded libraries
memory list modules

# Search memory for strings
memory search "api_key"
```

### iOS Application Analysis

**IPA Extraction and Analysis:**

```bash
# Extract IPA from device (jailbroken)
ssh root@device-ip
cd /var/containers/Bundle/Application/
ls -la
# Find app directory
cp -r AppName.app ~/

# Download to workstation
scp -r root@device-ip:~/AppName.app ./

# Convert to IPA
mkdir Payload
cp -r AppName.app Payload/
zip -r AppName.ipa Payload/

# Extract IPA
unzip AppName.ipa

# Analyze Info.plist
plutil -convert xml1 Payload/AppName.app/Info.plist
cat Payload/AppName.app/Info.plist
```

**Class-dump-z (iOS Binary Analysis):**

```bash
# Extract class information
./class-dump-z Payload/AppName.app/AppName > classes.txt

# Search for interesting methods
grep -i "password" classes.txt
grep -i "token" classes.txt
grep -i "api" classes.txt
```

**Hopper Disassembler:**

```bash
# [Inference] Commercial tool for iOS binary analysis
# Alternatives: Ghidra (free), IDA Pro (commercial)

# Basic workflow:
# 1. Load binary in Hopper
# 2. Analyze Mach-O structure
# 3. Identify interesting functions
# 4. Review Objective-C method calls
# 5. Extract hardcoded strings
```

**iOS Frida Hooking:**

```javascript
// hook_ios.js

// Bypass jailbreak detection
if (ObjC.available) {
    var JailbreakDetection = ObjC.classes.JailbreakDetection;
    
    JailbreakDetection['- isJailbroken'].implementation = function() {
        console.log('[+] Jailbreak detection bypassed');
        return false;
    };
}

// Hook URL requests
Interceptor.attach(Module.findExportByName(null, 'NSURLSession'), {
    onEnter: function(args) {
        console.log('[+] NSURLSession request intercepted');
    }
});

// Extract keychain items
if (ObjC.available) {
    var query = ObjC.classes.NSMutableDictionary.alloc().init();
    query.setObject_forKey_(ObjC.classes.__NSCFConstantString.alloc()
        .initWithString_("*"), "kSecReturnData");
    
    console.log('[+] Keychain dump: ' + query);
}
```

---

## App Permission Analysis

### Android Permission Enumeration

**Manifest Permission Extraction:**

```bash
# Using aapt
aapt dump permissions app.apk

# Detailed permission analysis
aapt dump badging app.apk | grep "uses-permission"

# Using apktool
apktool d app.apk
cat app/AndroidManifest.xml | grep "uses-permission"
```

**Permission Categories:**

**Normal Permissions (automatically granted):**

- ACCESS_NETWORK_STATE
- ACCESS_WIFI_STATE
- BLUETOOTH
- INTERNET
- NFC
- SET_WALLPAPER

**Dangerous Permissions (require user approval):**

```xml
<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>

<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Microphone -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>

<!-- Contacts -->
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>

<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Phone -->
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.READ_CALL_LOG"/>

<!-- SMS -->
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>

<!-- Calendar -->
<uses-permission android:name="android.permission.READ_CALENDAR"/>
<uses-permission android:name="android.permission.WRITE_CALENDAR"/>
```

**Permission Analysis Script:**

```python
import xml.etree.ElementTree as ET
import subprocess

def analyze_permissions(apk_path):
    """Analyze APK permissions and flag suspicious combinations"""
    
    # Decompile APK
    subprocess.run(['apktool', 'd', apk_path, '-o', 'temp_apk'])
    
    # Parse manifest
    tree = ET.parse('temp_apk/AndroidManifest.xml')
    root = tree.getroot()
    
    permissions = []
    for perm in root.findall('.//uses-permission'):
        perm_name = perm.get('{http://schemas.android.com/apk/res/android}name')
        if perm_name:
            permissions.append(perm_name.split('.')[-1])
    
    # Suspicious permission combinations
    red_flags = {
        'spyware': ['ACCESS_FINE_LOCATION', 'RECORD_AUDIO', 'CAMERA', 'READ_SMS'],
        'data_theft': ['READ_CONTACTS', 'READ_SMS', 'INTERNET'],
        'financial_fraud': ['SEND_SMS', 'CALL_PHONE', 'INTERNET'],
        'ransomware': ['WRITE_EXTERNAL_STORAGE', 'DEVICE_ADMIN', 'INTERNET']
    }
    
    findings = {}
    for category, required_perms in red_flags.items():
        if all(perm in permissions for perm in required_perms):
            findings[category] = required_perms
    
    return {
        'all_permissions': permissions,
        'red_flags': findings,
        'dangerous_count': len([p for p in permissions if p in [
            'ACCESS_FINE_LOCATION', 'CAMERA', 'RECORD_AUDIO', 
            'READ_CONTACTS', 'READ_SMS', 'CALL_PHONE'
        ]])
    }

# Usage
result = analyze_permissions('suspicious.apk')
print(f"Dangerous permissions: {result['dangerous_count']}")
if result['red_flags']:
    print(f"[!] Suspicious patterns detected: {list(result['red_flags'].keys())}")
```

**Runtime Permission Checking:**

```bash
# Via ADB - check granted permissions
adb shell dumpsys package com.example.app | grep permission

# List all granted permissions
adb shell pm list permissions -d -g

# Grant/revoke permissions
adb shell pm grant com.example.app android.permission.CAMERA
adb shell pm revoke com.example.app android.permission.CAMERA

# Monitor permission requests in real-time
adb logcat | grep "PermissionChecker"
```

### iOS Permission Analysis

**Info.plist Permission Keys:**

```xml
<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby places</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We need background location access</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Take photos within the app</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Record audio messages</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos to upload</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>Import your contacts</string>

<!-- Calendar -->
<key>NSCalendarsUsageDescription</key>
<string>Add events to your calendar</string>

<!-- Bluetooth -->
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Connect to Bluetooth devices</string>

<!-- Motion -->
<key>NSMotionUsageDescription</key>
<string>Track your activity</string>
```

**iOS Permission Extraction:**

```bash
# Extract Info.plist
unzip app.ipa
plutil -convert xml1 Payload/App.app/Info.plist

# Parse permission descriptions
grep -A 1 "Usage" Payload/App.app/Info.plist

# Entitlements analysis
codesign -d --entitlements :- Payload/App.app/App

# Common suspicious entitlements:
# - com.apple.developer.healthkit
# - com.apple.security.app-sandbox (or lack thereof)
# - com.apple.developer.contacts
```

### Permission Abuse Detection

**Excessive Permission Patterns:**

```python
def detect_permission_abuse(app_category, permissions):
    """
    Compare app permissions against expected baseline
    [Inference] Based on typical app category requirements
    """
    
    expected_permissions = {
        'flashlight': ['CAMERA', 'FLASHLIGHT'],
        'calculator': [],
        'wallpaper': ['SET_WALLPAPER', 'READ_EXTERNAL_STORAGE'],
        'messaging': ['READ_SMS', 'SEND_SMS', 'READ_CONTACTS', 'INTERNET'],
        'game': ['INTERNET', 'ACCESS_NETWORK_STATE']
    }
    
    expected = set(expected_permissions.get(app_category, []))
    actual = set(permissions)
    
    excessive = actual - expected
    
    # High-risk permissions that are rarely justified
    rarely_justified = {
        'READ_SMS', 'SEND_SMS', 'CALL_PHONE', 'READ_CALL_LOG',
        'RECORD_AUDIO', 'ACCESS_FINE_LOCATION', 'CAMERA'
    }
    
    suspicious = excessive & rarely_justified
    
    return {
        'excessive_permissions': list(excessive),
        'high_risk_excessive': list(suspicious),
        'risk_score': len(suspicious) * 2 + len(excessive)
    }

# Example
result = detect_permission_abuse('flashlight', [
    'CAMERA', 'FLASHLIGHT', 'READ_SMS', 'ACCESS_FINE_LOCATION', 'INTERNET'
])

if result['high_risk_excessive']:
    print(f"[!] Warning: Flashlight app requesting: {result['high_risk_excessive']}")
```

**Background Permission Monitoring:**

```bash
# Android - monitor permission access in real-time
adb logcat | grep -E "PermissionChecker|AppOpsManager"

# Look for patterns:
# - Frequent location access
# - Camera/mic activation when app is backgrounded
# - SMS reading without user interaction

# Permission usage statistics
adb shell appops get com.example.app
```

---

## Mobile Device Tracking

### Location Tracking Methods

**GPS Coordinate Analysis:**

```python
import math

def calculate_distance(lat1, lon1, lat2, lon2):
    """
    Calculate distance between two GPS coordinates (Haversine formula)
    """
    R = 6371  # Earth radius in kilometers
    
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    
    a = (math.sin(dlat/2) * math.sin(dlat/2) +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon/2) * math.sin(dlon/2))
    
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = R * c
    
    return distance

def analyze_location_history(coordinates):
    """
    Analyze location patterns to identify:
    - Home location (most frequent at night)
    - Work location (frequent during business hours)
    - Movement patterns
    """
    from collections import Counter
    from datetime import datetime
    
    night_locations = []
    day_locations = []
    
    for coord in coordinates:
        timestamp = datetime.fromisoformat(coord['timestamp'])
        hour = timestamp.hour
        
        if 22 <= hour or hour <= 6:  # Night hours
            night_locations.append((coord['lat'], coord['lon']))
        elif 9 <= hour <= 17:  # Business hours
            day_locations.append((coord['lat'], coord['lon']))
    
    # Most frequent night location = likely home
    home = Counter(night_locations).most_common(1)[0][0] if night_locations else None
    
    # Most frequent day location = likely work
    work = Counter(day_locations).most_common(1)[0][0] if day_locations else None
    
    return {
        'likely_home': home,
        'likely_work': work,
        'total_points': len(coordinates)
    }
```

**Cell Tower Triangulation:**

```python
def triangulate_position(towers):
    """
    Estimate position from cell tower signals
    [Inference] Simplified triangulation model
    """
    import numpy as np
    
    # towers = [{'lat': x, 'lon': y, 'signal_strength': z}, ...]
    
    # Weight by signal strength (stronger = closer)
    total_weight = sum(1/tower['signal_strength'] for tower in towers)
    
    weighted_lat = sum(
        tower['lat'] / tower['signal_strength'] for tower in towers
    ) / total_weight
    
    weighted_lon = sum(
        tower['lon'] / tower['signal_strength'] for tower in towers
    ) / total_weight
    
    # [Unverified] Accuracy depends on tower density and signal quality
    # Typical accuracy: 50-1000 meters
    
    return {'lat': weighted_lat, 'lon': weighted_lon, 'accuracy': 'low'}
```

**Wi-Fi Positioning System (WPS):**

```bash
# Extract Wi-Fi BSSID (MAC addresses) from device
adb shell dumpsys wifi | grep "BSSID"

# Query geolocation databases
# Google Geolocation API
curl -X POST "https://www.googleapis.com/geolocation/v1/geolocate?key=API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "wifiAccessPoints": [
      {"macAddress": "00:11:22:33:44:55", "signalStrength": -65},
      {"macAddress": "AA:BB:CC:DD:EE:FF", "signalStrength": -75}
    ]
  }'

# [Inference] Major tech companies maintain databases of Wi-Fi AP locations
# Collected through street view vehicles and user devices
```

**WiGLE (Wireless Network Mapping):**

```bash
# Search WiGLE database
curl "https://api.wigle.net/api/v2/network/search?onlymine=false&freenet=false&paynet=false" \
  -u "API_NAME:API_TOKEN" \
  -d "ssid=NetworkName"

# Query by BSSID
curl "https://api.wigle.net/api/v2/network/detail?netid=00:11:22:33:44:55" \
  -u "API_NAME:API_TOKEN"

# Results include:
# - Latitude/Longitude
# - First/last seen timestamps
# - Accuracy radius
```

### IMSI Catcher Detection

**IMSI Catcher Indicators:**

```python
def detect_imsi_catcher(cell_info):
    """
    Identify potential IMSI catcher/StingRay
    [Inference] Based on known behavioral patterns
    """
    red_flags = []
    
    # 1. Sudden change to 2G network
    if cell_info['network_type'] == '2G' and cell_info['previous_type'] in ['4G', '5G']:
        red_flags.append('Downgrade to 2G (common IMSI catcher tactic)')
    
    # 2. Unknown or suspicious cell tower
    if cell_info['cell_id'] not in cell_info['known_towers']:
        red_flags.append('Unknown cell tower ID')
    
    # 3. Inconsistent location
    if cell_info['tower_location_change'] > 10:  # km
        red_flags.append('Tower location changed significantly')
    
    # 4. Lack of encryption
    if not cell_info['encryption_enabled']:
        red_flags.append('No encryption on connection')
    
    # 5. Unusual signal strength
    if cell_info['signal_strength'] > -50:  # Very strong, might be nearby
        red_flags.append('Unusually strong signal')
    
    return {
        'suspicious': len(red_flags) > 0,
        'indicators': red_flags,
        'risk_level': 'high' if len(red_flags) >= 3 else 'medium' if red_flags else 'low'
    }
```

**Android IMSI Catcher Detection Apps:**

```bash
# SnoopSnitch - requires rooted device
# Monitors:
# - Cell tower behavior
# - Encryption status
# - SS7 attacks
# - Silent SMS

# AIMSICD (Android IMSI-Catcher Detector)
# Features:
# - Cell tower tracking
# - Location tracking
# - Cell tower database comparison
# - Suspicious activity alerts

# Manual monitoring via ADB
adb shell dumpsys telephony.registry | grep -E "mCellLocation|mSignalStrength"

# Log cell tower changes
adb logcat | grep "CellLocation"
```

### Device Fingerprinting

**Hardware Identifiers:**

```bash
# Android Device ID collection
adb shell settings get secure android_id

# Hardware serial number
adb shell getprop ro.serialno

# Build fingerprint
adb shell getprop ro.build.fingerprint

# MAC addresses
adb shell cat /sys/class/net/wlan0/address  # Wi-Fi
adb shell cat /sys/class/net/eth0/address   # Ethernet

# Advertising ID
adb shell settings get secure advertising_id
```

**Comprehensive Fingerprint Script:**

```python
import subprocess
import hashlib

def collect_device_fingerprint():
    """
    Generate unique device fingerprint
    [Inference] Combines multiple identifiers for tracking
    """
    
    identifiers = {}
    
    # Android ID
    android_id = subprocess.check_output(
        ['adb', 'shell', 'settings', 'get', 'secure', 'android_id']
    ).decode().strip()
    identifiers['android_id'] = android_id
    
    # Build fingerprint
    build_fp = subprocess.check_output(
        ['adb', 'shell', 'getprop', 'ro.build.fingerprint']
    ).decode().strip()
    identifiers['build_fingerprint'] = build_fp
    
    # Screen resolution
    resolution = subprocess.check_output(
        ['adb', 'shell', 'wm', 'size']
    ).decode().strip()
    identifiers['resolution'] = resolution
    
    # Installed apps
    apps = subprocess.check_output(
        ['adb', 'shell', 'pm', 'list', 'packages']
    ).decode()
    app_hash = hashlib.md5(apps.encode()).hexdigest()
    identifiers['app_signature'] = app_hash
    
    # Fonts (for fingerprinting)
    fonts = subprocess.check_output(
        ['adb', 'shell', 'ls', '/system/fonts/']
    ).decode()
    font_hash = hashlib.md5(fonts.encode()).hexdigest()
    identifiers['font_signature'] = font_hash
    
    # Combine into unique fingerprint
    combined = '|'.join(str(v) for v in identifiers.values())
    fingerprint = hashlib.sha256(combined.encode()).hexdigest()
    
    return {
        'fingerprint': fingerprint,
        'components': identifiers
    }
```

**iOS Device Fingerprinting:**

```bash
# UDID (deprecated but sometimes present)
idevice_id -l

# Device name
ideviceinfo -k DeviceName

# Device model
ideviceinfo -k ProductType

# iOS version
ideviceinfo -k ProductVersion

# Identifier for Vendor (IDFV)
# Accessible via app code only

# Identifier for Advertisers (IDFA)
# User-resettable, privacy-focused
```

### Mobile Network Monitoring

**Traffic Interception Setup:**

```bash
# Set up proxy on workstation
mitmproxy -p 8080 --set block_global=false

# Configure Android device proxy
adb shell settings put global http_proxy host:8080

# For HTTPS traffic, install mitmproxy CA certificate
adb push ~/.mitmproxy/mitmproxy-ca-cert.pem /sdcard/
# Install via Settings > Security > Install certificates

# Monitor traffic
mitmproxy

# Filter specific app
mitmproxy --set "~d com.example.app"

# Save traffic
mitmdump -w traffic.dump
```

**Burp Suite Mobile Configuration:**

```bash
# Configure Burp listener on 0.0.0.0:8080

# Set Android proxy
adb shell settings put global http_proxy 192.168.1.100:8080

# Export Burp CA certificate
# Navigate to http://burp on device
# Download cacert.der

# Install certificate
adb push cacert.der /sdcard/

# Settings > Security > Install from SD card

# SSL pinning bypass with Frida

frida -U -f com.example.app -l ssl-pinning-bypass.js --no-pause

# Monitor intercepted requests in Burp

# Analyze:

# - API endpoints

# - Authentication tokens

# - Sensitive data transmission

# - Session management

````

**PCAPdroid - On-Device Network Capture:**
```bash
# Install PCAPdroid (no root required)
# Uses Android VPN API to capture traffic

# ADB commands for analysis
adb logcat | grep PCAPdroid

# Export PCAP file
adb pull /sdcard/Download/capture.pcap

# Analyze with Wireshark
wireshark capture.pcap

# Filter mobile-specific protocols
# Display filters:
# - http.host contains "api"
# - tcp.port == 443
# - dns
````

**Packet Analysis for Tracking:**

```python
from scapy.all import *

def analyze_mobile_traffic(pcap_file):
    """
    Identify tracking and analytics requests
    """
    packets = rdpcap(pcap_file)
    
    tracking_domains = [
        'google-analytics.com',
        'doubleclick.net',
        'facebook.com/tr',
        'app-measurement.com',
        'crashlytics.com',
        'appsflyer.com',
        'adjust.com',
        'branch.io'
    ]
    
    findings = {
        'tracking_requests': [],
        'unique_domains': set(),
        'analytics_data': []
    }
    
    for pkt in packets:
        if pkt.haslayer(DNS):
            query = pkt[DNS].qd.qname.decode()
            findings['unique_domains'].add(query)
            
            for tracker in tracking_domains:
                if tracker in query:
                    findings['tracking_requests'].append({
                        'domain': query,
                        'time': pkt.time
                    })
        
        if pkt.haslayer(Raw):
            payload = pkt[Raw].load
            # Look for common tracking parameters
            if b'device_id' in payload or b'advertising_id' in payload:
                findings['analytics_data'].append({
                    'packet': pkt.summary(),
                    'data': payload[:200]  # First 200 bytes
                })
    
    return findings
```

---

## Bluetooth Tracking

### Bluetooth Device Enumeration

**Basic Bluetooth Scanning:**

```bash
# Linux - scan for devices
hcitool scan

# Detailed device info
hcitool info [MAC_ADDRESS]

# RSSI (signal strength) monitoring
hcitool rssi [MAC_ADDRESS]

# Low Energy (BLE) scan
sudo hcitool lescan

# With bluetoothctl
bluetoothctl
scan on
devices
info [MAC_ADDRESS]
```

**Advanced BLE Scanning:**

```python
from bluepy.btle import Scanner, DefaultDelegate

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)
    
    def handleDiscovery(self, dev, isNewDev, isNewData):
        if isNewDev:
            print(f"[+] Discovered device: {dev.addr}")
        elif isNewData:
            print(f"[+] Received new data from: {dev.addr}")

def ble_scan(duration=10):
    """
    Scan for BLE devices and extract information
    """
    scanner = Scanner().withDelegate(ScanDelegate())
    devices = scanner.scan(duration)
    
    device_info = []
    
    for dev in devices:
        info = {
            'address': dev.addr,
            'address_type': dev.addrType,
            'rssi': dev.rssi,
            'connectable': dev.connectable,
            'data': {}
        }
        
        for (adtype, desc, value) in dev.getScanData():
            info['data'][desc] = value
            
            # Common advertising data types:
            # 0x01: Flags
            # 0x02/0x03: Service UUIDs
            # 0x08/0x09: Complete/Shortened Local Name
            # 0xFF: Manufacturer Specific Data
        
        device_info.append(info)
    
    return device_info

# Usage
devices = ble_scan(30)
for dev in devices:
    print(f"\nDevice: {dev['address']}")
    print(f"RSSI: {dev['rssi']} dBm")
    print(f"Data: {dev['data']}")
```

**Ubertooth - Bluetooth Monitoring:**

```bash
# Ubertooth One required (hardware)

# Scan for devices
ubertooth-scan

# Follow specific device
ubertooth-follow -t [MAC_ADDRESS]

# BLE sniffing
ubertooth-btle -f -t [MAC_ADDRESS]

# Capture to PCAP
ubertooth-btle -f -c capture.pcap

# Analyze with Wireshark
wireshark capture.pcap -Y btle
```

### Bluetooth Tracking Techniques

**MAC Address Randomization Detection:**

```python
import re
from collections import defaultdict

def analyze_mac_randomization(scan_results):
    """
    Detect patterns in randomized MAC addresses
    [Inference] Some devices have predictable randomization patterns
    """
    
    # Group by OUI (first 3 octets)
    oui_groups = defaultdict(list)
    
    for scan in scan_results:
        mac = scan['address']
        oui = ':'.join(mac.split(':')[:3])
        oui_groups[oui].append(scan)
    
    # Locally administered addresses (randomized)
    # Second character of first octet will be 2, 6, A, or E
    randomized = []
    
    for mac_scan in scan_results:
        mac = mac_scan['address']
        first_octet = int(mac.split(':')[0], 16)
        
        # Check if locally administered bit is set
        if first_octet & 0x02:
            randomized.append(mac_scan)
    
    # [Inference] Correlate with other device characteristics
    # Same manufacturer data, service UUIDs, or RSSI patterns
    
    potential_matches = []
    for r1 in randomized:
        for r2 in randomized:
            if r1['address'] != r2['address']:
                # Compare manufacturer data
                if r1['data'].get('Manufacturer') == r2['data'].get('Manufacturer'):
                    # Similar RSSI suggests same physical device
                    if abs(r1['rssi'] - r2['rssi']) < 10:
                        potential_matches.append((r1['address'], r2['address']))
    
    return {
        'total_devices': len(scan_results),
        'randomized_count': len(randomized),
        'potential_same_device': potential_matches
    }
```

**Bluetooth Beacon Tracking:**

```python
def parse_ibeacon(manufacturer_data):
    """
    Parse Apple iBeacon format
    Format: Company ID (2) + Type (1) + Length (1) + UUID (16) + Major (2) + Minor (2) + TX Power (1)
    """
    if len(manufacturer_data) < 46:  # 23 bytes in hex
        return None
    
    # Apple Company ID: 0x004C
    company_id = manufacturer_data[0:4]
    if company_id != '004c':
        return None
    
    beacon_type = manufacturer_data[4:6]
    if beacon_type != '02':  # iBeacon type
        return None
    
    uuid = manufacturer_data[8:40]
    major = int(manufacturer_data[40:44], 16)
    minor = int(manufacturer_data[44:48], 16)
    tx_power = int(manufacturer_data[48:50], 16)
    
    # Calculate distance (rough estimate)
    # [Inference] Based on RSSI and TX power
    # Accuracy: 1-3 meters typically
    
    return {
        'type': 'iBeacon',
        'uuid': uuid,
        'major': major,
        'minor': minor,
        'tx_power': tx_power
    }

def parse_eddystone(service_data):
    """
    Parse Google Eddystone format
    """
    if not service_data:
        return None
    
    frame_type = service_data[0:2]
    
    if frame_type == '00':  # UID
        namespace = service_data[4:24]
        instance = service_data[24:36]
        return {
            'type': 'Eddystone-UID',
            'namespace': namespace,
            'instance': instance
        }
    
    elif frame_type == '10':  # URL
        url_scheme = {
            '00': 'http://www.',
            '01': 'https://www.',
            '02': 'http://',
            '03': 'https://'
        }
        scheme = url_scheme.get(service_data[2:4], '')
        # URL encoding follows
        return {
            'type': 'Eddystone-URL',
            'url': scheme  # + decoded URL
        }
    
    return None
```

**Proximity Tracking:**

```python
import time
import math

def estimate_distance(rssi, tx_power=-59):
    """
    Estimate distance from RSSI value
    [Inference] Uses path loss formula with environmental factor
    """
    if rssi == 0:
        return -1.0
    
    # Environmental factor (n)
    # 2.0 = free space
    # 2.7-4.3 = indoor
    n = 3.0
    
    distance = 10 ** ((tx_power - rssi) / (10 * n))
    return round(distance, 2)

class DeviceTracker:
    def __init__(self):
        self.devices = {}
        self.location_history = {}
    
    def update_device(self, mac, rssi, timestamp):
        """Track device movement based on RSSI changes"""
        
        distance = estimate_distance(rssi)
        
        if mac not in self.devices:
            self.devices[mac] = {
                'first_seen': timestamp,
                'last_seen': timestamp,
                'rssi_history': [],
                'estimated_distance': []
            }
        
        self.devices[mac]['last_seen'] = timestamp
        self.devices[mac]['rssi_history'].append(rssi)
        self.devices[mac]['estimated_distance'].append(distance)
        
        # Analyze movement patterns
        if len(self.devices[mac]['rssi_history']) > 5:
            recent_rssi = self.devices[mac]['rssi_history'][-5:]
            trend = sum(recent_rssi) / len(recent_rssi)
            
            if trend > rssi + 5:
                self.devices[mac]['movement'] = 'approaching'
            elif trend < rssi - 5:
                self.devices[mac]['movement'] = 'leaving'
            else:
                self.devices[mac]['movement'] = 'stationary'
    
    def get_nearby_devices(self, distance_threshold=5):
        """Get devices within specified distance (meters)"""
        nearby = []
        
        for mac, data in self.devices.items():
            if data['estimated_distance']:
                current_distance = data['estimated_distance'][-1]
                if current_distance <= distance_threshold:
                    nearby.append({
                        'mac': mac,
                        'distance': current_distance,
                        'duration': data['last_seen'] - data['first_seen']
                    })
        
        return nearby

# Usage
tracker = DeviceTracker()
# Continuously update with scan results
tracker.update_device('AA:BB:CC:DD:EE:FF', -65, time.time())
```

### Bluetooth Vulnerability Analysis

**BluetoothSmashingAndroid (Bluedroid Exploits):**

```bash
# Check device vulnerability
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.security_patch

# [Inference] Devices with security patches before 2020-02 vulnerable to BlueFrag
# CVE-2020-0022

# Test with proof-of-concept
# [Critical] Only test on devices you own or have permission to test
```

**KNOB Attack Detection:**

```python
def detect_knob_vulnerability(device_info):
    """
    Key Negotiation of Bluetooth (KNOB) attack detection
    CVE-2019-9506
    [Inference] Affects Bluetooth BR/EDR
    """
    
    vulnerable_indicators = []
    
    # Check Bluetooth version
    bt_version = device_info.get('bluetooth_version', '')
    
    if bt_version and float(bt_version) < 5.1:
        vulnerable_indicators.append('Bluetooth version < 5.1')
    
    # Check encryption key length
    key_length = device_info.get('encryption_key_length', 0)
    
    if key_length < 7:  # KNOB forces 1-byte keys
        vulnerable_indicators.append(f'Weak key length: {key_length} bytes')
    
    return {
        'vulnerable': len(vulnerable_indicators) > 0,
        'indicators': vulnerable_indicators,
        'cve': 'CVE-2019-9506'
    }
```

**BlueBorne Scanner:**

```bash
# Check for BlueBorne vulnerabilities
# Install armis-security scanner or use manual checks

# Check kernel version (Linux)
uname -r

# Vulnerable kernels: < 3.18.69 or specific versions

# Android BlueBorne check
adb shell getprop ro.build.version.security_patch
# Vulnerable if patch < 2017-09-05

# Windows: Check Bluetooth driver version
# Vulnerable: before September 2017 patches
```

### Contact Tracing Analysis

**COVID-19 Exposure Notification Analysis:**

```python
def analyze_exposure_notifications(ble_scans):
    """
    Identify COVID-19 exposure notification beacons
    [Inference] Based on Google/Apple Exposure Notification framework
    """
    
    # Exposure Notification Service UUID: 0xFD6F
    exposure_uuid = 'fd6f'
    
    exposure_devices = []
    
    for scan in ble_scans:
        services = scan.get('data', {}).get('service_uuids', [])
        
        if exposure_uuid in [s.lower() for s in services]:
            # Rolling Proximity Identifier (RPI) changes every 10-20 minutes
            rpi = scan.get('data', {}).get('service_data', {}).get(exposure_uuid)
            
            exposure_devices.append({
                'timestamp': scan['timestamp'],
                'rpi': rpi,
                'rssi': scan['rssi'],
                'metadata': scan.get('data', {}).get('metadata')
            })
    
    # Analyze encounter duration
    encounters = {}
    for device in exposure_devices:
        rpi = device['rpi']
        if rpi not in encounters:
            encounters[rpi] = {
                'first_seen': device['timestamp'],
                'last_seen': device['timestamp'],
                'rssi_values': []
            }
        else:
            encounters[rpi]['last_seen'] = device['timestamp']
        
        encounters[rpi]['rssi_values'].append(device['rssi'])
    
    # Calculate exposure duration and proximity
    for rpi, data in encounters.items():
        duration = data['last_seen'] - data['first_seen']
        avg_rssi = sum(data['rssi_values']) / len(data['rssi_values'])
        avg_distance = estimate_distance(avg_rssi)
        
        encounters[rpi]['duration'] = duration
        encounters[rpi]['avg_distance'] = avg_distance
        
        # [Inference] High-risk encounter: >15 minutes within 2 meters
        if duration > 900 and avg_distance < 2:
            encounters[rpi]['risk_level'] = 'high'
        else:
            encounters[rpi]['risk_level'] = 'low'
    
    return encounters
```

**Bluetooth Mesh Network Analysis:**

```python
def analyze_mesh_network(devices):
    """
    Map Bluetooth mesh network topology
    [Inference] Used in IoT, smart home devices
    """
    
    mesh_nodes = []
    
    for device in devices:
        # Mesh Proxy Service UUID: 0x1828
        # Mesh Provisioning Service UUID: 0x1827
        
        services = device.get('services', [])
        
        if '1828' in services or '1827' in services:
            mesh_nodes.append({
                'address': device['address'],
                'role': 'proxy' if '1828' in services else 'provisioning',
                'rssi': device['rssi'],
                'neighbors': []
            })
    
    # Build connection graph based on proximity
    # [Inference] Devices within range can communicate
    
    for i, node1 in enumerate(mesh_nodes):
        for j, node2 in enumerate(mesh_nodes):
            if i != j:
                # If RSSI strong enough, they can communicate
                if node1['rssi'] > -80 and node2['rssi'] > -80:
                    mesh_nodes[i]['neighbors'].append(node2['address'])
    
    return mesh_nodes
```

---

## Mobile Metadata

### EXIF Data Extraction

**Image Metadata Analysis:**

```bash
# Install exiftool
apt install libimage-exiftool-perl

# Extract all EXIF data
exiftool image.jpg

# Specific GPS coordinates
exiftool -GPSPosition image.jpg
exiftool -GPSLatitude -GPSLongitude image.jpg

# Device information
exiftool -Make -Model -Software image.jpg

# Timestamp information
exiftool -DateTimeOriginal -CreateDate image.jpg

# Remove all metadata
exiftool -all= image.jpg

# Bulk processing
exiftool -GPS* -r /path/to/photos/ > gps_data.txt
```

**Python EXIF Extraction:**

```python
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
import datetime

def extract_exif(image_path):
    """
    Extract comprehensive EXIF metadata
    """
    image = Image.open(image_path)
    exif_data = image._getexif()
    
    if not exif_data:
        return None
    
    metadata = {}
    
    for tag_id, value in exif_data.items():
        tag = TAGS.get(tag_id, tag_id)
        metadata[tag] = value
    
    return metadata

def get_gps_coordinates(exif_data):
    """
    Extract and convert GPS coordinates
    """
    if not exif_data or 'GPSInfo' not in exif_data:
        return None
    
    gps_info = {}
    for key in exif_data['GPSInfo'].keys():
        decode = GPSTAGS.get(key, key)
        gps_info[decode] = exif_data['GPSInfo'][key]
    
    def convert_to_degrees(value):
        d, m, s = value
        return d + (m / 60.0) + (s / 3600.0)
    
    if 'GPSLatitude' in gps_info and 'GPSLongitude' in gps_info:
        lat = convert_to_degrees(gps_info['GPSLatitude'])
        lon = convert_to_degrees(gps_info['GPSLongitude'])
        
        if gps_info.get('GPSLatitudeRef') == 'S':
            lat = -lat
        if gps_info.get('GPSLongitudeRef') == 'W':
            lon = -lon
        
        return {
            'latitude': lat,
            'longitude': lon,
            'altitude': gps_info.get('GPSAltitude'),
            'timestamp': gps_info.get('GPSDateStamp')
        }
    
    return None

def analyze_device_fingerprint(exif_data):
    """
    Create device fingerprint from EXIF metadata
    """
    if not exif_data:
        return None
    
    fingerprint = {
        'camera_make': exif_data.get('Make', ''),
        'camera_model': exif_data.get('Model', ''),
        'software': exif_data.get('Software', ''),
        'lens_model': exif_data.get('LensModel', ''),
        'focal_length': exif_data.get('FocalLength', ''),
        'iso': exif_data.get('ISOSpeedRatings', ''),
        'image_dimensions': f"{exif_data.get('ExifImageWidth', '')}x{exif_data.get('ExifImageHeight', '')}"
    }
    
    # Create unique signature
    import hashlib
    signature_string = '|'.join(str(v) for v in fingerprint.values())
    fingerprint['signature'] = hashlib.md5(signature_string.encode()).hexdigest()
    
    return fingerprint

# Usage
exif = extract_exif('photo.jpg')
gps = get_gps_coordinates(exif)
if gps:
    print(f"Location: {gps['latitude']}, {gps['longitude']}")
    print(f"Altitude: {gps['altitude']} meters")

device = analyze_device_fingerprint(exif)
print(f"Device signature: {device['signature']}")
```

**Geolocation Visualization:**

```python
import folium
from geopy.geocoders import Nominatim

def create_photo_map(image_files):
    """
    Create interactive map of photo locations
    """
    geolocator = Nominatim(user_agent="photo_analyzer")
    
    # Extract GPS from all images
    locations = []
    for img_file in image_files:
        exif = extract_exif(img_file)
        gps = get_gps_coordinates(exif)
        
        if gps:
            # Reverse geocode
            try:
                location = geolocator.reverse(
                    f"{gps['latitude']}, {gps['longitude']}"
                )
                address = location.address
            except:
                address = "Unknown"
            
            locations.append({
                'file': img_file,
                'lat': gps['latitude'],
                'lon': gps['longitude'],
                'address': address,
                'timestamp': exif.get('DateTimeOriginal', 'Unknown')
            })
    
    if not locations:
        return None
    
    # Create map centered on first location
    map_center = [locations[0]['lat'], locations[0]['lon']]
    photo_map = folium.Map(location=map_center, zoom_start=12)
    
    # Add markers
    for loc in locations:
        folium.Marker(
            [loc['lat'], loc['lon']],
            popup=f"{loc['file']}<br>{loc['timestamp']}<br>{loc['address']}",
            tooltip=loc['file']
        ).add_to(photo_map)
    
    # Add path lines
    if len(locations) > 1:
        coordinates = [[loc['lat'], loc['lon']] for loc in locations]
        folium.PolyLine(coordinates, color='red', weight=2).add_to(photo_map)
    
    photo_map.save('photo_locations.html')
    return locations
```

### Video Metadata Analysis

**Video File Metadata:**

```bash
# Using ffprobe (part of ffmpeg)
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4

# Extract GPS from video
exiftool -ee -G3 -api LargeFileSupport=1 video.mp4 | grep GPS

# MediaInfo (detailed codec information)
mediainfo video.mp4

# Extract specific metadata
ffprobe -v error -show_entries format_tags=location -of default=noprint_wrappers=1:nokey=1 video.mp4
```

**Python Video Metadata:**

```python
import subprocess
import json

def extract_video_metadata(video_path):
    """
    Extract comprehensive video metadata
    """
    cmd = [
        'ffprobe',
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        video_path
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    metadata = json.loads(result.stdout)
    
    info = {
        'duration': float(metadata['format'].get('duration', 0)),
        'size': int(metadata['format'].get('size', 0)),
        'bit_rate': int(metadata['format'].get('bit_rate', 0)),
        'format_name': metadata['format'].get('format_name', ''),
        'tags': metadata['format'].get('tags', {}),
        'streams': []
    }
    
    for stream in metadata.get('streams', []):
        stream_info = {
            'codec_type': stream.get('codec_type', ''),
            'codec_name': stream.get('codec_name', ''),
            'width': stream.get('width'),
            'height': stream.get('height'),
            'frame_rate': stream.get('r_frame_rate', '')
        }
        info['streams'].append(stream_info)
    
    # Extract GPS data if present
    tags = info['tags']
    if 'location' in tags:
        # Parse location string (format varies)
        # Example: "+37.5090+127.0620/"
        location = tags['location']
        info['gps'] = parse_location_string(location)
    
    return info

def parse_location_string(location):
    """
    Parse GPS location string from video metadata
    [Inference] Format varies by device/software
    """
    import re
    
    # Common format: +37.5090+127.0620/
    pattern = r'([+-]\d+\.\d+)([+-]\d+\.\d+)'
    match = re.search(pattern, location)
    
    if match:
        return {
            'latitude': float(match.group(1)),
            'longitude': float(match.group(2))
        }
    
    return None
```

### Audio Metadata Forensics

**Audio File Analysis:**

```bash
# Extract audio metadata
exiftool audio.mp3
mediainfo audio.wav

# Spectrogram analysis (hidden data visualization)
sox audio.wav -n spectrogram -o spectrogram.png

# Check for steganography
# [Inference] Data can be hidden in audio files

# Waveform analysis
ffmpeg -i audio.mp3 -filter_complex "showwavespic=s=1920x1080" waveform.png

# Extract embedded images (album art)
ffmpeg -i audio.mp3 -an -vcodec copy cover.jpg
```

**Audio Fingerprinting:**

```python
import librosa
import numpy as np

def analyze_audio_fingerprint(audio_path):
    """
    Create audio fingerprint for comparison
    [Inference] Useful for identifying source device/recorder
    """
    y, sr = librosa.load(audio_path)
    
    # Extract features
    features = {
        'sample_rate': sr,
        'duration': librosa.get_duration(y=y, sr=sr),
        'tempo': librosa.beat.tempo(y=y, sr=sr)[0],
        'spectral_centroid': np.mean(librosa.feature.spectral_centroid(y=y, sr=sr)),
        'zero_crossing_rate': np.mean(librosa.feature.zero_crossing_rate(y)),
        'mfcc': np.mean(librosa.feature.mfcc(y=y, sr=sr), axis=1).tolist()
    }
    
    return features

def detect_audio_manipulation(audio_path):
    """
    Detect potential audio editing/splicing
    [Inference] Based on discontinuities in audio signal
    """
    y, sr = librosa.load(audio_path)
    
    # Analyze spectral flux (sudden changes)
    onset_env = librosa.onset.onset_strength(y=y, sr=sr)
    peaks = librosa.util.peak_pick(onset_env, 3, 3, 3, 5, 0.5, 10)
    
    # Detect abrupt changes
    suspicious_segments = []
    
    for i in range(1, len(onset_env)):
        change = abs(onset_env[i] - onset_env[i-1])
        if change > np.std(onset_env) * 3:  # 3 standard deviations
            suspicious_segments.append({
                'time': i / sr,
                'magnitude': change
            })
    
    return {
        'suspicious_count': len(suspicious_segments),
        'segments': suspicious_segments[:10]  # First 10
    }
```

### Document Metadata

**PDF Metadata Extraction:**

```bash
# Using exiftool
exiftool document.pdf

# Using pdfinfo
pdfinfo document.pdf

# Extract hidden text
pdftotext document.pdf -

# Check for JavaScript/malicious content
pdf-parser -a document.pdf | grep -i javascript

# Extract embedded files
binwalk -e document.pdf
```

**Python PDF Analysis:**

```python
from PyPDF2 import PdfReader
import datetime

def extract_pdf_metadata(pdf_path):
    """
    Extract PDF metadata and hidden information
    """
    reader = PdfReader(pdf_path)
    metadata = reader.metadata
    
    info = {
        'title': metadata.get('/Title', ''),
        'author': metadata.get('/Author', ''),
        'subject': metadata.get('/Subject', ''),
        'creator': metadata.get('/Creator', ''),
        'producer': metadata.get('/Producer', ''),
        'creation_date': metadata.get('/CreationDate', ''),
        'modification_date': metadata.get('/ModDate', ''),
        'num_pages': len(reader.pages)
    }
    
    # Parse PDF dates (format: D:YYYYMMDDHHmmSS)
    def parse_pdf_date(date_str):
        if date_str and date_str.startswith('D:'):
            date_str = date_str[2:16]  # Extract YYYYMMDDHHmmSS
            try:
                return datetime.datetime.strptime(date_str, '%Y%m%d%H%M%S')
            except:
                return None
        return None
    
    info['creation_datetime'] = parse_pdf_date(info['creation_date'])
    info['modification_datetime'] = parse_pdf_date(info['modification_date'])
    
    # Extract text from first page (may contain hidden info)
    if reader.pages:
        info['first_page_text'] = reader.pages[0].extract_text()[:500]
    
    return info

def detect_pdf_manipulation(pdf_path):
    """
    Detect signs of PDF manipulation
    [Inference] Based on metadata inconsistencies
    """
    metadata = extract_pdf_metadata(pdf_path)
    
    red_flags = []
    
    # Check if modification date is before creation date
    if metadata['creation_datetime'] and metadata['modification_datetime']:
        if metadata['modification_datetime'] < metadata['creation_datetime']:
            red_flags.append('Modification date before creation date')
    
    # Check for mismatched creator/producer
    creator = metadata.get('creator', '').lower()
    producer = metadata.get('producer', '').lower()
    
    common_pairs = [
        ('microsoft word', 'microsoft'),
        ('writer', 'libreoffice'),
        ('pages', 'apple')
    ]
    
    # [Inference] Mismatched creator/producer may indicate conversion or manipulation
    mismatch = True
    for c, p in common_pairs:
        if c in creator and p in producer: mismatch = False break

if mismatch and creator and producer:
    red_flags.append(f'Unusual creator/producer combination: {creator} / {producer}')

return {
    'suspicious': len(red_flags) > 0,
    'indicators': red_flags
}
````

**Office Document Metadata:**
```bash
# Microsoft Office documents
exiftool document.docx

# Extract internal XML structure
unzip document.docx -d extracted_docx/
cat extracted_docx/docProps/core.xml
cat extracted_docx/docProps/app.xml

# Check for tracked changes
strings document.docx | grep -i "author\|editor\|revision"

# Extract embedded objects
binwalk document.docx
foremost document.docx
````

**Python Office Document Analysis:**

```python
from docx import Document
import zipfile
import xml.etree.ElementTree as ET

def extract_docx_metadata(docx_path):
    """
    Extract comprehensive Word document metadata
    """
    doc = Document(docx_path)
    core_props = doc.core_properties
    
    metadata = {
        'title': core_props.title,
        'author': core_props.author,
        'subject': core_props.subject,
        'keywords': core_props.keywords,
        'comments': core_props.comments,
        'last_modified_by': core_props.last_modified_by,
        'revision': core_props.revision,
        'created': core_props.created,
        'modified': core_props.modified,
        'category': core_props.category,
        'content_status': core_props.content_status
    }
    
    # Extract custom properties and hidden data
    with zipfile.ZipFile(docx_path, 'r') as zip_ref:
        # Read custom properties
        try:
            custom_xml = zip_ref.read('docProps/custom.xml')
            root = ET.fromstring(custom_xml)
            metadata['custom_properties'] = {}
            
            for prop in root:
                name = prop.get('name')
                value = prop[0].text
                metadata['custom_properties'][name] = value
        except:
            pass
        
        # Check for comments
        try:
            comments_xml = zip_ref.read('word/comments.xml')
            root = ET.fromstring(comments_xml)
            metadata['comment_count'] = len(root)
            metadata['has_comments'] = len(root) > 0
        except:
            metadata['comment_count'] = 0
            metadata['has_comments'] = False
    
    return metadata

def extract_revision_history(docx_path):
    """
    Extract tracked changes and revision history
    """
    with zipfile.ZipFile(docx_path, 'r') as zip_ref:
        document_xml = zip_ref.read('word/document.xml')
        root = ET.fromstring(document_xml)
        
        # Namespace for Word XML
        ns = {
            'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        }
        
        revisions = []
        
        # Find insertions
        for ins in root.findall('.//w:ins', ns):
            author = ins.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
            date = ins.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date')
            text = ''.join(ins.itertext())
            
            revisions.append({
                'type': 'insertion',
                'author': author,
                'date': date,
                'text': text[:100]  # First 100 chars
            })
        
        # Find deletions
        for delete in root.findall('.//w:del', ns):
            author = delete.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}author')
            date = delete.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}date')
            text = ''.join(delete.itertext())
            
            revisions.append({
                'type': 'deletion',
                'author': author,
                'date': date,
                'text': text[:100]
            })
        
        return revisions

def find_hidden_text(docx_path):
    """
    Find hidden or white text in document
    """
    doc = Document(docx_path)
    hidden_content = []
    
    for paragraph in doc.paragraphs:
        for run in paragraph.runs:
            # Check if text is hidden
            if run.font.hidden:
                hidden_content.append({
                    'text': run.text,
                    'type': 'hidden'
                })
            
            # Check for white text (potential hiding)
            if run.font.color and run.font.color.rgb:
                rgb = run.font.color.rgb
                if rgb == (255, 255, 255) or rgb == (254, 254, 254):
                    hidden_content.append({
                        'text': run.text,
                        'type': 'white_text'
                    })
    
    return hidden_content
```

### Mobile App Metadata

**APK Metadata Extraction:**

```python
import zipfile
import xml.etree.ElementTree as ET
from androguard.core.bytecodes.apk import APK

def extract_apk_metadata(apk_path):
    """
    Extract comprehensive APK metadata
    """
    apk = APK(apk_path)
    
    metadata = {
        'package_name': apk.get_package(),
        'app_name': apk.get_app_name(),
        'version_name': apk.get_androidversion_name(),
        'version_code': apk.get_androidversion_code(),
        'min_sdk': apk.get_min_sdk_version(),
        'target_sdk': apk.get_target_sdk_version(),
        'permissions': apk.get_permissions(),
        'activities': apk.get_activities(),
        'services': apk.get_services(),
        'receivers': apk.get_receivers(),
        'providers': apk.get_providers(),
        'libraries': apk.get_libraries(),
        'files': apk.get_files(),
        'signature': apk.get_signature_name()
    }
    
    # Extract hardcoded strings
    strings = []
    for dex in apk.get_all_dex():
        strings.extend(list(dex.get_strings())[:100])  # First 100
    
    metadata['sample_strings'] = strings
    
    # Find URLs, IPs, emails
    import re
    all_text = ' '.join(strings)
    
    metadata['urls'] = re.findall(r'https?://[^\s]+', all_text)
    metadata['ips'] = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', all_text)
    metadata['emails'] = re.findall(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', all_text)
    
    return metadata

def find_hardcoded_secrets(apk_path):
    """
    Search for hardcoded credentials and API keys
    """
    apk = APK(apk_path)
    secrets = {
        'api_keys': [],
        'passwords': [],
        'tokens': [],
        'secrets': []
    }
    
    patterns = {
        'api_key': r'["\']?api[_-]?key["\']?\s*[:=]\s*["\']([a-zA-Z0-9_\-]{20,})["\']',
        'password': r'["\']?password["\']?\s*[:=]\s*["\']([^"\']{6,})["\']',
        'token': r'["\']?token["\']?\s*[:=]\s*["\']([a-zA-Z0-9_\-\.]{20,})["\']',
        'secret': r'["\']?secret["\']?\s*[:=]\s*["\']([a-zA-Z0-9_\-]{16,})["\']',
        'aws_key': r'AKIA[0-9A-Z]{16}',
        'private_key': r'-----BEGIN (?:RSA |EC )?PRIVATE KEY-----'
    }
    
    # Search in all files
    with zipfile.ZipFile(apk_path, 'r') as zip_ref:
        for filename in zip_ref.namelist():
            if filename.endswith(('.xml', '.json', '.txt', '.properties')):
                try:
                    content = zip_ref.read(filename).decode('utf-8', errors='ignore')
                    
                    for pattern_name, pattern in patterns.items():
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        if matches:
                            for match in matches:
                                secrets.setdefault(pattern_name, []).append({
                                    'file': filename,
                                    'value': match if isinstance(match, str) else match[0]
                                })
                except:
                    pass
    
    return secrets

def compare_apk_versions(apk1_path, apk2_path):
    """
    Compare two APK versions to identify changes
    [Inference] Useful for detecting malicious modifications
    """
    apk1 = APK(apk1_path)
    apk2 = APK(apk2_path)
    
    changes = {
        'permissions': {
            'added': set(apk2.get_permissions()) - set(apk1.get_permissions()),
            'removed': set(apk1.get_permissions()) - set(apk2.get_permissions())
        },
        'activities': {
            'added': set(apk2.get_activities()) - set(apk1.get_activities()),
            'removed': set(apk1.get_activities()) - set(apk2.get_activities())
        },
        'services': {
            'added': set(apk2.get_services()) - set(apk1.get_services()),
            'removed': set(apk1.get_services()) - set(apk2.get_services())
        },
        'version_change': {
            'from': apk1.get_androidversion_name(),
            'to': apk2.get_androidversion_name()
        }
    }
    
    # Calculate risk score
    risk_score = 0
    
    # Dangerous permission additions
    dangerous_perms = [
        'READ_SMS', 'SEND_SMS', 'CALL_PHONE', 'ACCESS_FINE_LOCATION',
        'CAMERA', 'RECORD_AUDIO', 'READ_CONTACTS'
    ]
    
    for perm in changes['permissions']['added']:
        if any(dp in perm for dp in dangerous_perms):
            risk_score += 5
    
    changes['risk_score'] = risk_score
    changes['suspicious'] = risk_score > 10
    
    return changes
```

### Smartphone Sensor Metadata

**Sensor Data Collection:**

```python
# Via ADB - requires device connection

def collect_sensor_data():
    """
    Collect sensor information from Android device
    """
    import subprocess
    import json
    
    # List available sensors
    sensors_raw = subprocess.check_output([
        'adb', 'shell', 'dumpsys', 'sensorservice'
    ]).decode('utf-8')
    
    # Extract sensor types
    sensors = {
        'accelerometer': 'TYPE_ACCELEROMETER' in sensors_raw,
        'gyroscope': 'TYPE_GYROSCOPE' in sensors_raw,
        'magnetometer': 'TYPE_MAGNETIC_FIELD' in sensors_raw,
        'gps': 'TYPE_GPS' in sensors_raw,
        'barometer': 'TYPE_PRESSURE' in sensors_raw,
        'proximity': 'TYPE_PROXIMITY' in sensors_raw,
        'light': 'TYPE_LIGHT' in sensors_raw,
        'fingerprint': False  # Requires different check
    }
    
    # Get battery information
    battery_raw = subprocess.check_output([
        'adb', 'shell', 'dumpsys', 'battery'
    ]).decode('utf-8')
    
    battery_info = {}
    for line in battery_raw.split('\n'):
        if ':' in line:
            key, value = line.strip().split(':', 1)
            battery_info[key.strip()] = value.strip()
    
    # Get network information
    network_raw = subprocess.check_output([
        'adb', 'shell', 'dumpsys', 'connectivity'
    ]).decode('utf-8')
    
    return {
        'sensors': sensors,
        'battery': battery_info,
        'network_info': network_raw[:500]  # Truncated
    }

def fingerprint_from_sensors(sensor_data):
    """
    Create device fingerprint from sensor characteristics
    [Inference] Sensor imperfections create unique signatures
    """
    import hashlib
    
    # Combine sensor availability and characteristics
    fingerprint_components = []
    
    for sensor, available in sensor_data['sensors'].items():
        fingerprint_components.append(f"{sensor}:{available}")
    
    # Add battery characteristics
    if 'battery' in sensor_data:
        capacity = sensor_data['battery'].get('Charge counter', '')
        fingerprint_components.append(f"battery:{capacity}")
    
    # Create hash
    combined = '|'.join(fingerprint_components)
    fingerprint = hashlib.sha256(combined.encode()).hexdigest()
    
    return fingerprint
```

**Accelerometer Fingerprinting:**

```python
import numpy as np

def analyze_accelerometer_data(readings):
    """
    Analyze accelerometer data for device fingerprinting
    [Inference] Manufacturing imperfections create unique patterns
    """
    x_values = [r['x'] for r in readings]
    y_values = [r['y'] for r in readings]
    z_values = [r['z'] for r in readings]
    
    # Calculate statistical characteristics
    fingerprint = {
        'x_mean': np.mean(x_values),
        'x_std': np.std(x_values),
        'x_bias': np.mean(x_values) - 0,  # Deviation from expected zero
        'y_mean': np.mean(y_values),
        'y_std': np.std(y_values),
        'y_bias': np.mean(y_values) - 0,
        'z_mean': np.mean(z_values),
        'z_std': np.std(z_values),
        'z_bias': np.mean(z_values) - 9.81  # Deviation from gravity
    }
    
    # [Inference] These biases are hardware-specific and persistent
    # Can be used for device identification even after factory reset
    
    return fingerprint

def detect_motion_patterns(accelerometer_data, gyroscope_data):
    """
    Identify user behavior patterns from motion sensors
    [Inference] Walking gait, typing patterns are unique per person
    """
    patterns = {
        'activity': None,
        'confidence': 0
    }
    
    # Simple activity recognition
    accel_magnitude = np.sqrt(
        np.array([r['x']**2 + r['y']**2 + r['z']**2 for r in accelerometer_data])
    )
    
    variance = np.var(accel_magnitude)
    mean_magnitude = np.mean(accel_magnitude)
    
    # Classification thresholds [Inference]
    if variance < 0.5:
        patterns['activity'] = 'stationary'
        patterns['confidence'] = 0.9
    elif variance < 2.0 and mean_magnitude < 12:
        patterns['activity'] = 'walking'
        patterns['confidence'] = 0.7
    elif variance > 5.0:
        patterns['activity'] = 'running'
        patterns['confidence'] = 0.6
    else:
        patterns['activity'] = 'in_vehicle'
        patterns['confidence'] = 0.5
    
    return patterns
```

### Network Metadata

**Mobile Network Information:**

```bash
# Extract network details via ADB
adb shell dumpsys telephony.registry

# Cell tower information
adb shell dumpsys telephony.registry | grep mCellLocation

# Network type
adb shell dumpsys telephony.registry | grep mDataConnectionState

# Signal strength
adb shell dumpsys telephony.registry | grep mSignalStrength

# Carrier information
adb shell getprop | grep -i "gsm\|operator"

# IMEI/IMSI (requires privileges)
adb shell service call iphonesubinfo 1
```

**Network Metadata Extraction:**

```python
def extract_network_metadata():
    """
    Extract comprehensive network metadata from device
    """
    import subprocess
    
    metadata = {}
    
    # Get network type
    network_type = subprocess.check_output([
        'adb', 'shell', 'dumpsys', 'telephony.registry'
    ]).decode('utf-8')
    
    # Parse key information
    for line in network_type.split('\n'):
        if 'mDataConnectionState' in line:
            metadata['data_connection'] = line.split('=')[1].strip()
        elif 'mSignalStrength' in line:
            metadata['signal_strength'] = line.strip()
        elif 'mCellLocation' in line:
            metadata['cell_location'] = line.split('=')[1].strip()
    
    # Get Wi-Fi information
    wifi_info = subprocess.check_output([
        'adb', 'shell', 'dumpsys', 'wifi'
    ]).decode('utf-8')
    
    # Extract current connection
    for line in wifi_info.split('\n'):
        if 'mWifiInfo' in line:
            metadata['wifi_info'] = line.strip()
            break
    
    # Get network interfaces
    interfaces = subprocess.check_output([
        'adb', 'shell', 'ip', 'addr'
    ]).decode('utf-8')
    
    metadata['interfaces'] = interfaces
    
    return metadata

def track_network_changes(duration=60):
    """
    Monitor network changes over time
    [Inference] Reveals movement patterns and location changes
    """
    import time
    
    changes = []
    previous_cell = None
    
    start_time = time.time()
    
    while time.time() - start_time < duration:
        current_metadata = extract_network_metadata()
        current_cell = current_metadata.get('cell_location')
        
        if current_cell != previous_cell:
            changes.append({
                'timestamp': time.time(),
                'old_cell': previous_cell,
                'new_cell': current_cell,
                'signal': current_metadata.get('signal_strength')
            })
            previous_cell = current_cell
        
        time.sleep(5)  # Check every 5 seconds
    
    # Analyze patterns
    analysis = {
        'total_changes': len(changes),
        'changes': changes,
        'mobility': 'high' if len(changes) > 10 else 'low'
    }
    
    return analysis
```

---

## Key CTF Application Scenarios

### Mobile OSINT Challenge Workflow

**Scenario: Extract intelligence from mobile app**

```bash
# 1. Obtain APK
adb pull /data/app/com.challenge.app/base.apk

# 2. Decompile
apktool d base.apk -o decompiled/
jadx base.apk -d jadx_output/

# 3. Search for flags
grep -r "flag{" jadx_output/
grep -r "CTF{" jadx_output/
grep -r -E "[A-F0-9]{32}" jadx_output/

# 4. Check resources
cat decompiled/res/values/strings.xml | grep -i "flag\|key\|secret"

# 5. Analyze network calls
grep -r "http" jadx_output/ | grep -v "apache"

# 6. Check SharedPreferences
adb shell run-as com.challenge.app
cd shared_prefs/
cat *.xml

# 7. Dynamic analysis with Frida
frida -U -l extract_secrets.js com.challenge.app
```

**EXIF-Based Location Challenge:**

```python
# Extract GPS from multiple images
# Reconstruct movement path
# Find pattern or specific location

import os

def solve_exif_challenge(image_directory):
    """
    Common CTF scenario: GPS coordinates spell out flag
    """
    images = sorted([f for f in os.listdir(image_directory) if f.endswith(('.jpg', '.png'))])
    
    coordinates = []
    
    for img_file in images:
        path = os.path.join(image_directory, img_file)
        exif = extract_exif(path)
        gps = get_gps_coordinates(exif)
        
        if gps:
            coordinates.append({
                'file': img_file,
                'lat': gps['latitude'],
                'lon': gps['longitude'],
                'timestamp': exif.get('DateTimeOriginal')
            })
    
    # Sort by timestamp
    coordinates.sort(key=lambda x: x['timestamp'] if x['timestamp'] else '')
    
    # Check if coordinates form pattern
    # Sometimes coordinates encode ASCII values
    # Or point to specific location with significance
    
    return coordinates
```

---

## Important Related Topics

**Advanced Mobile Forensics:**

- Full file system extraction techniques
- SQLite database analysis
- Memory dump analysis
- Deleted data recovery

**Mobile Malware Analysis:**

- Banking trojans detection
- RAT (Remote Access Trojan) identification
- Spyware behavioral analysis
- Dropper and payload analysis

**5G Security:**

- 5G network enumeration
- SUCI (Subscription Concealed Identifier) analysis
- Network slicing security

**IoT and Wearable Devices:**

- Smartwatch forensics
- Fitness tracker data analysis
- IoT device fingerprinting
- Matter/Thread protocol analysis

**Mobile App Security Testing:**

- Runtime application self-protection (RASP) bypass
- Code obfuscation analysis
- Certificate pinning implementation review
- Secure storage assessment

---

# Automation and Tooling

Automation transforms manual OSINT processes into scalable, repeatable operations. Effective automation requires understanding both the technical tools and the investigative workflow, enabling rapid data collection, processing, and analysis across multiple sources.

## Python for OSINT Automation

Python dominates OSINT automation due to extensive libraries, readable syntax, and rapid development cycles. Mastery requires understanding both core language features and domain-specific packages.

### Essential Python Libraries for OSINT

**HTTP and web requests:**

```python
#!/usr/bin/env python3
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Basic request
response = requests.get('https://example.com')
print(response.status_code)
print(response.text)

# Request with headers (user agent spoofing)
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}
response = requests.get('https://example.com', headers=headers)

# Request with parameters
params = {'q': 'search term', 'page': 1}
response = requests.get('https://api.example.com/search', params=params)

# POST request with JSON data
data = {'username': 'user', 'query': 'test'}
response = requests.post('https://api.example.com/endpoint', json=data)

# Session with persistent cookies
session = requests.Session()
session.get('https://example.com/login')
session.post('https://example.com/login', data={'user': 'test', 'pass': 'test'})

# Retry strategy for reliability
retry_strategy = Retry(
    total=3,
    backoff_factor=1,
    status_forcelist=[429, 500, 502, 503, 504]
)
adapter = HTTPAdapter(max_retries=retry_strategy)
session = requests.Session()
session.mount("http://", adapter)
session.mount("https://", adapter)

# Timeout handling
try:
    response = requests.get('https://example.com', timeout=10)
except requests.exceptions.Timeout:
    print("Request timed out")
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")

# Proxy usage
proxies = {
    'http': 'http://proxy.example.com:8080',
    'https': 'http://proxy.example.com:8080'
}
response = requests.get('https://example.com', proxies=proxies)

# SSL verification control (use cautiously)
response = requests.get('https://example.com', verify=False)

# Download file
response = requests.get('https://example.com/file.pdf', stream=True)
with open('file.pdf', 'wb') as f:
    for chunk in response.iter_content(chunk_size=8192):
        f.write(chunk)
```

**HTML parsing with BeautifulSoup:**

```python
#!/usr/bin/env python3
from bs4 import BeautifulSoup
import requests

# Parse HTML
html = requests.get('https://example.com').text
soup = BeautifulSoup(html, 'html.parser')

# Find elements by tag
title = soup.find('title').text
all_links = soup.find_all('a')

# Find by class
divs = soup.find_all('div', class_='content')

# Find by id
header = soup.find(id='header')

# CSS selectors
articles = soup.select('div.article > h2')

# Extract attributes
for link in soup.find_all('a'):
    href = link.get('href')
    text = link.get_text()
    print(f"{text}: {href}")

# Navigate tree structure
parent = soup.find('div', class_='content').parent
children = soup.find('div', class_='content').children
siblings = soup.find('div', class_='content').find_next_siblings()

# Extract text content
text = soup.get_text()
clean_text = soup.get_text(strip=True, separator=' ')

# Find with regex
import re
phone_pattern = re.compile(r'\d{3}-\d{3}-\d{4}')
phones = soup.find_all(text=phone_pattern)

# Extract metadata
meta_tags = soup.find_all('meta')
for tag in meta_tags:
    if tag.get('name') == 'description':
        print(tag.get('content'))

# Table extraction
table = soup.find('table')
rows = []
for tr in table.find_all('tr'):
    row = [td.get_text(strip=True) for td in tr.find_all(['td', 'th'])]
    rows.append(row)

# Handle malformed HTML
soup = BeautifulSoup(html, 'lxml')  # More forgiving parser
```

**Advanced scraping with Selenium:**

```python
#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
import time

# Headless browser setup
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--disable-dev-shm-usage')
chrome_options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')

# Initialize driver
driver = webdriver.Chrome(options=chrome_options)

# Navigate to URL
driver.get('https://example.com')

# Wait for page load
driver.implicitly_wait(10)

# Explicit wait for element
wait = WebDriverWait(driver, 10)
element = wait.until(EC.presence_of_element_located((By.ID, 'search-box')))

# Find elements
search_box = driver.find_element(By.ID, 'search-box')
links = driver.find_elements(By.TAG_NAME, 'a')
by_class = driver.find_elements(By.CLASS_NAME, 'item')
by_xpath = driver.find_element(By.XPATH, '//div[@class="content"]')
by_css = driver.find_element(By.CSS_SELECTOR, 'div.content > p')

# Interact with elements
search_box.send_keys('search query')
search_box.send_keys(Keys.RETURN)

button = driver.find_element(By.ID, 'submit-btn')
button.click()

# Scroll page
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

# Infinite scroll handling
last_height = driver.execute_script("return document.body.scrollHeight")
while True:
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    time.sleep(2)
    new_height = driver.execute_script("return document.body.scrollHeight")
    if new_height == last_height:
        break
    last_height = new_height

# Handle JavaScript-loaded content
time.sleep(3)  # Wait for JS to execute
html = driver.page_source
soup = BeautifulSoup(html, 'html.parser')

# Switch between frames
driver.switch_to.frame('frame_name')
driver.switch_to.default_content()

# Handle multiple windows
driver.switch_to.window(driver.window_handles[1])

# Execute JavaScript
result = driver.execute_script('return document.title;')

# Take screenshot
driver.save_screenshot('screenshot.png')

# Get cookies
cookies = driver.get_cookies()

# Handle alerts
alert = driver.switch_to.alert
alert.accept()  # or alert.dismiss()

# Close browser
driver.quit()
```

**JSON handling:**

```python
#!/usr/bin/env python3
import json
import requests

# Parse JSON response
response = requests.get('https://api.example.com/data')
data = response.json()

# Access nested data
value = data['key']['nested_key'][0]

# Load from file
with open('data.json', 'r') as f:
    data = json.load(f)

# Save to file
with open('output.json', 'w') as f:
    json.dump(data, f, indent=2)

# Pretty print
print(json.dumps(data, indent=2, sort_keys=True))

# Handle JSON strings
json_string = '{"key": "value"}'
data = json.loads(json_string)

# Custom JSON encoder for complex objects
class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, set):
            return list(obj)
        return json.JSONEncoder.default(self, obj)

json.dumps(data, cls=CustomEncoder)

# Extract specific fields
usernames = [item['username'] for item in data['users']]

# Safe navigation with .get()
value = data.get('key', {}).get('nested', 'default')
```

**Regular expressions for data extraction:**

```python
#!/usr/bin/env python3
import re

text = "Contact us at admin@example.com or support@example.org"

# Email extraction
emails = re.findall(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', text)

# Phone numbers
phones = re.findall(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', text)

# URLs
urls = re.findall(r'https?://(?:www\.)?[a-zA-Z0-9./\-_]+', text)

# IP addresses
ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', text)

# Bitcoin addresses
btc_addresses = re.findall(r'\b[13][a-km-zA-HJ-NP-Z1-9]{25,34}\b', text)

# Ethereum addresses
eth_addresses = re.findall(r'\b0x[a-fA-F0-9]{40}\b', text)

# Credit card numbers (Luhn check recommended)
cards = re.findall(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', text)

# Social security numbers
ssns = re.findall(r'\b\d{3}-\d{2}-\d{4}\b', text)

# Dates (various formats)
dates = re.findall(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b', text)

# Hashtags
hashtags = re.findall(r'#\w+', text)

# Twitter handles
handles = re.findall(r'@\w+', text)

# Named groups for complex extraction
pattern = r'(?P<username>\w+)@(?P<domain>[a-zA-Z0-9.-]+\.[a-z]{2,})'
for match in re.finditer(pattern, text):
    print(f"User: {match.group('username')}, Domain: {match.group('domain')}")

# Case-insensitive search
results = re.findall(r'error', text, re.IGNORECASE)

# Multiline search
text_multiline = """Line 1
Line 2
Line 3"""
matches = re.findall(r'^Line', text_multiline, re.MULTILINE)

# Substitution
cleaned = re.sub(r'\s+', ' ', text)  # Replace multiple spaces with single space

# Split by pattern
parts = re.split(r'[,;]', "item1,item2;item3")

# Validate format
def is_valid_email(email):
    pattern = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'
    return re.match(pattern, email) is not None
```

**Data manipulation with Pandas:**

```python
#!/usr/bin/env python3
import pandas as pd

# Load data from various sources
df = pd.read_csv('data.csv')
df = pd.read_json('data.json')
df = pd.read_excel('data.xlsx')

# Load from API response
import requests
response = requests.get('https://api.example.com/data')
df = pd.DataFrame(response.json())

# Basic inspection
print(df.head())
print(df.info())
print(df.describe())
print(df.columns)

# Select columns
usernames = df['username']
subset = df[['username', 'email', 'created_at']]

# Filter rows
active_users = df[df['status'] == 'active']
recent = df[df['timestamp'] > '2024-01-01']
combined = df[(df['status'] == 'active') & (df['posts'] > 10)]

# Sort data
sorted_df = df.sort_values('created_at', ascending=False)

# Group and aggregate
user_stats = df.groupby('username').agg({
    'posts': 'count',
    'likes': 'sum',
    'timestamp': 'max'
})

# Add calculated columns
df['post_per_day'] = df['posts'] / df['days_active']

# Handle missing data
df = df.dropna()  # Remove rows with any NA
df = df.fillna(0)  # Fill NA with value

# Remove duplicates
df = df.drop_duplicates(subset=['username'])

# Merge dataframes
merged = pd.merge(df1, df2, on='user_id', how='left')

# Export data
df.to_csv('output.csv', index=False)
df.to_json('output.json', orient='records')
df.to_excel('output.xlsx', index=False)

# Apply custom function
df['email_domain'] = df['email'].apply(lambda x: x.split('@')[1])

# Date/time handling
df['timestamp'] = pd.to_datetime(df['timestamp'])
df['year'] = df['timestamp'].dt.year
df['month'] = df['timestamp'].dt.month

# Pivot tables
pivot = df.pivot_table(
    values='posts',
    index='username',
    columns='category',
    aggfunc='sum'
)

# String operations
df['username_lower'] = df['username'].str.lower()
df['has_keyword'] = df['bio'].str.contains('keyword', case=False)
```

### Rate Limiting and Ethical Scraping

**Implementing rate limits:**

```python
#!/usr/bin/env python3
import time
import requests
from functools import wraps

# Simple delay
def rate_limit(delay):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            result = func(*args, **kwargs)
            time.sleep(delay)
            return result
        return wrapper
    return decorator

@rate_limit(1)  # 1 second delay
def fetch_url(url):
    return requests.get(url)

# Token bucket algorithm
import threading

class RateLimiter:
    def __init__(self, max_calls, period):
        self.max_calls = max_calls
        self.period = period
        self.calls = []
        self.lock = threading.Lock()
    
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            with self.lock:
                now = time.time()
                # Remove old calls outside the time window
                self.calls = [call for call in self.calls if call > now - self.period]
                
                if len(self.calls) >= self.max_calls:
                    sleep_time = self.period - (now - self.calls[0])
                    if sleep_time > 0:
                        time.sleep(sleep_time)
                        self.calls = []
                
                self.calls.append(time.time())
            
            return func(*args, **kwargs)
        return wrapper

@RateLimiter(max_calls=10, period=60)  # 10 calls per minute
def api_call(endpoint):
    return requests.get(endpoint)

# Using ratelimit library
from ratelimit import limits, sleep_and_retry

@sleep_and_retry
@limits(calls=15, period=60)
def call_api(url):
    response = requests.get(url)
    return response.json()

# Exponential backoff for retries
def exponential_backoff_request(url, max_retries=5):
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                return response
            elif response.status_code == 429:  # Too many requests
                wait_time = 2 ** attempt
                print(f"Rate limited. Waiting {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                response.raise_for_status()
        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise
            wait_time = 2 ** attempt
            time.sleep(wait_time)
```

**Respecting robots.txt:**

```python
#!/usr/bin/env python3
from urllib.robotparser import RobotFileParser
from urllib.parse import urlparse

def can_fetch(url, user_agent='*'):
    """Check if URL can be fetched according to robots.txt"""
    parsed = urlparse(url)
    robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"
    
    rp = RobotFileParser()
    rp.set_url(robots_url)
    try:
        rp.read()
        return rp.can_fetch(user_agent, url)
    except:
        # If robots.txt cannot be read, assume allowed
        return True

# Usage
if can_fetch('https://example.com/page'):
    response = requests.get('https://example.com/page')
else:
    print("Blocked by robots.txt")

# Get crawl delay
def get_crawl_delay(base_url, user_agent='*'):
    parsed = urlparse(base_url)
    robots_url = f"{parsed.scheme}://{parsed.netloc}/robots.txt"
    
    rp = RobotFileParser()
    rp.set_url(robots_url)
    rp.read()
    
    return rp.crawl_delay(user_agent) or 1  # Default to 1 second
```

### Error Handling and Logging

**Comprehensive error handling:**

```python
#!/usr/bin/env python3
import requests
import logging
from requests.exceptions import RequestException, Timeout, ConnectionError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('osint.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def safe_request(url, max_retries=3):
    """Make HTTP request with error handling"""
    for attempt in range(max_retries):
        try:
            logger.info(f"Requesting {url} (attempt {attempt + 1}/{max_retries})")
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            logger.info(f"Successfully fetched {url}")
            return response
            
        except Timeout:
            logger.warning(f"Timeout for {url}")
            if attempt == max_retries - 1:
                logger.error(f"Max retries reached for {url}")
                return None
                
        except ConnectionError:
            logger.error(f"Connection error for {url}")
            if attempt == max_retries - 1:
                return None
                
        except requests.HTTPError as e:
            logger.error(f"HTTP error {e.response.status_code} for {url}")
            if e.response.status_code == 404:
                return None  # Don't retry 404
            if attempt == max_retries - 1:
                return None
                
        except RequestException as e:
            logger.error(f"Request exception for {url}: {str(e)}")
            if attempt == max_retries - 1:
                return None
        
        time.sleep(2 ** attempt)  # Exponential backoff
    
    return None

# Context manager for resource cleanup
class OSINTSession:
    def __init__(self):
        self.session = requests.Session()
        self.results = []
    
    def __enter__(self):
        logger.info("Starting OSINT session")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.session.close()
        logger.info(f"Session ended. Collected {len(self.results)} results")
        if exc_type:
            logger.error(f"Exception occurred: {exc_val}")
        return False

# Usage
with OSINTSession() as osint:
    response = osint.session.get('https://example.com')
    osint.results.append(response.json())
```

### Multi-threading and Async Operations

**Threading for I/O-bound tasks:**

```python
#!/usr/bin/env python3
import threading
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from queue import Queue

# Basic threading
def fetch_url(url):
    response = requests.get(url)
    return url, response.status_code

urls = ['https://example.com', 'https://example.org', 'https://example.net']

threads = []
results = []

for url in urls:
    thread = threading.Thread(target=lambda u: results.append(fetch_url(u)), args=(url,))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()

# ThreadPoolExecutor (preferred method)
def fetch_with_details(url):
    try:
        response = requests.get(url, timeout=10)
        return {
            'url': url,
            'status': response.status_code,
            'length': len(response.content),
            'success': True
        }
    except Exception as e:
        return {
            'url': url,
            'error': str(e),
            'success': False
        }

urls = ['https://example.com'] * 100

with ThreadPoolExecutor(max_workers=10) as executor:
    futures = {executor.submit(fetch_with_details, url): url for url in urls}
    
    for future in as_completed(futures):
        result = future.result()
        print(f"{result['url']}: {result.get('status', 'Error')}")

# Producer-consumer pattern
class URLFetcher:
    def __init__(self, num_workers=5):
        self.queue = Queue()
        self.results = []
        self.num_workers = num_workers
    
    def worker(self):
        while True:
            url = self.queue.get()
            if url is None:
                break
            
            try:
                response = requests.get(url, timeout=10)
                self.results.append({
                    'url': url,
                    'status': response.status_code
                })
            except Exception as e:
                self.results.append({
                    'url': url,
                    'error': str(e)
                })
            finally:
                self.queue.task_done()
    
    def fetch_all(self, urls):
        # Start workers
        workers = []
        for _ in range(self.num_workers):
            t = threading.Thread(target=self.worker)
            t.start()
            workers.append(t)
        
        # Add URLs to queue
        for url in urls:
            self.queue.put(url)
        
        # Wait for completion
        self.queue.join()
        
        # Stop workers
        for _ in range(self.num_workers):
            self.queue.put(None)
        for t in workers:
            t.join()
        
        return self.results

# Usage
fetcher = URLFetcher(num_workers=10)
results = fetcher.fetch_all(urls)
```

**Async programming with asyncio:**

```python
#!/usr/bin/env python3
import asyncio
import aiohttp
import time

# Basic async function
async def fetch_url_async(session, url):
    try:
        async with session.get(url) as response:
            content = await response.text()
            return {
                'url': url,
                'status': response.status,
                'length': len(content)
            }
    except Exception as e:
        return {
            'url': url,
            'error': str(e)
        }

# Main async function
async def fetch_all_async(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url_async(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
        return results

# Run async code
urls = ['https://example.com'] * 100
start = time.time()
results = asyncio.run(fetch_all_async(urls))
print(f"Fetched {len(results)} URLs in {time.time() - start:.2f} seconds")

# Async with rate limiting
class AsyncRateLimiter:
    def __init__(self, max_calls, period):
        self.max_calls = max_calls
        self.period = period
        self.semaphore = asyncio.Semaphore(max_calls)
        self.calls = []
    
    async def __aenter__(self):
        async with self.semaphore:
            now = time.time()
            self.calls = [call for call in self.calls if call > now - self.period]
            
            if len(self.calls) >= self.max_calls:
                sleep_time = self.period - (now - self.calls[0])
                if sleep_time > 0:
                    await asyncio.sleep(sleep_time)
                    self.calls = []
            
            self.calls.append(time.time())
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        pass

# Usage with rate limiter
rate_limiter = AsyncRateLimiter(max_calls=10, period=1)

async def fetch_with_limit(session, url):
    async with rate_limiter:
        async with session.get(url) as response:
            return await response.text()

# Async queue processing
async def async_worker(queue, session, results):
    while True:
        url = await queue.get()
        
        try:
            result = await fetch_url_async(session, url)
            results.append(result)
        except Exception as e:
            results.append({'url': url, 'error': str(e)})
        finally:
            queue.task_done()

async def process_urls_async(urls, num_workers=10):
    queue = asyncio.Queue()
    results = []
    
    # Add URLs to queue
    for url in urls:
        await queue.put(url)
    
    # Start workers
    async with aiohttp.ClientSession() as session:
        workers = [
            asyncio.create_task(async_worker(queue, session, results))
            for _ in range(num_workers)
        ]
        
        await queue.join()
        
        # Cancel workers
        for worker in workers:
            worker.cancel()
    
    return results
```

### Data Storage and Persistence

**SQLite for local storage:**

```python
#!/usr/bin/env python3
import sqlite3
import json
from datetime import datetime

class OSINTDatabase:
    def __init__(self, db_path='osint.db'):
        self.conn = sqlite3.connect(db_path)
        self.cursor = self.conn.cursor()
        self.setup_tables()
    
    def setup_tables(self):
        # Create tables
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT,
                profile_url TEXT,
                data TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS searches (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                query TEXT NOT NULL,
                source TEXT,
                results_count INTEGER,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        self.conn.commit()
    
    def add_user(self, username, email=None, profile_url=None, data=None):
        try:
            self.cursor.execute('''
                INSERT INTO users (username, email, profile_url, data)
                VALUES (?, ?, ?, ?)
            ''', (username, email, profile_url, json.dumps(data) if data else None))
            self.conn.commit()
            return self.cursor.lastrowid
        except sqlite3.IntegrityError:
            # Update existing user
            self.cursor.execute('''
                UPDATE users
                SET email=?, profile_url=?, data=?, updated_at=CURRENT_TIMESTAMP
                WHERE username=?
            ''', (email, profile_url, json.dumps(data) if data else None, username))
            self.conn.commit()
            return None
    
    def get_user(self, username):
        self.cursor.execute('SELECT * FROM users WHERE username=?', (username,))
        return self.cursor.fetchone()
    
    def search_users(self, keyword):
        self.cursor.execute('''
            SELECT * FROM users
            WHERE username LIKE ? OR email LIKE ?
        ''', (f'%{keyword}%', f'%{keyword}%'))
        return self.cursor.fetchall()
    
    def log_search(self, query, source, results_count):
        self.cursor.execute('''
            INSERT INTO searches (query, source, results_count)
            VALUES (?, ?, ?)
        ''', (query, source, results_count))
        self.conn.commit()
    
    def close(self):
        self.conn.close()

# Usage
db = OSINTDatabase()
db.add_user('john_doe', 'john@example.com', 'https://example.com/john', {'posts': 42})
user = db.get_user('john_doe')
db.close()
```

**CSV export for spreadsheet analysis:**

```python
#!/usr/bin/env python3
import csv
from datetime import datetime

def export_to_csv(data, filename='output.csv'):
    """Export list of dictionaries to CSV"""
    if not data:
        return
    
    keys = data[0].keys()
    
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldkeys=keys)
        writer.writeheader()
        writer.writerows(data)

# Append to existing CSV
def append_to_csv(data, filename='output.csv'):
    with open(filename, 'a', newline='', encoding='utf-8') as f:
        if data:
            writer = csv.DictWriter(f, fieldnames=data[0].keys())
            writer.writerows(data)

# Read CSV
def read_csv(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return list(csv.DictReader(f))
```

**JSON Lines format for streaming:**

```python
#!/usr/bin/env python3
import json

def write_jsonl(data, filename='output.jsonl'):
    """Write data in JSON Lines format"""
    with open(filename, 'w') as f:
        for item in data:
            f.write(json.dumps(item) + '\n')

def append_jsonl(item, filename='output.jsonl'):
    """Append single item to JSONL file"""
    with open(filename, 'a') as f:
        f.write(json.dumps(item) + '\n')

def read_jsonl(filename='output.jsonl'):
    """Read JSON Lines format file"""
    data = []
    with open(filename, 'r') as f:
        for line in f:
            data.append(json.loads(line.strip()))
    return data

# Streaming read for large files
def stream_jsonl(filename='output.jsonl'):
    """Generator for memory-efficient reading"""
    with open(filename, 'r') as f:
        for line in f:
            yield json.loads(line.strip())

# Usage for large datasets
for item in stream_jsonl('large_dataset.jsonl'):
    process_item(item)  # Process one at a time
```

## API Integration

APIs provide structured access to data sources. Effective API integration requires understanding authentication, rate limits, pagination, and error handling.

### REST API Basics

**Authentication methods:**

```python
#!/usr/bin/env python3
import requests
from requests.auth import HTTPBasicAuth
import hashlib
import hmac
import time

# API Key in headers
headers = {'X-API-Key': 'your_api_key_here'}
response = requests.get('https://api.example.com/data', headers=headers)

# API Key in query parameters
params = {'api_key': 'your_api_key_here', 'query': 'search'}
response = requests.get('https://api.example.com/data', params=params)

# Bearer token authentication (OAuth)
headers = {'Authorization': 'Bearer your_access_token_here'}
response = requests.get('https://api.example.com/data', headers=headers)

# Basic authentication
response = requests.get(
    'https://api.example.com/data',
    auth=HTTPBasicAuth('username', 'password')
)

# OAuth 2.0 flow
from requests_oauthlib import OAuth2Session

client_id = 'your_client_id'
client_secret = 'your_client_secret'
authorization_base_url = 'https://example.com/oauth/authorize'
token_url = 'https://example.com/oauth/token'
redirect_uri = 'http://localhost:8080/callback'

oauth = OAuth2Session(client_id, redirect_uri=redirect_uri)
authorization_url, state = oauth.authorization_url(authorization_base_url)

# User visits authorization_url and gets redirected back with code
# Extract code from redirect URL
# token = oauth.fetch_token(token_url, authorization_response=redirect_response)

# HMAC signature authentication
def create_hmac_signature(secret, message):
    """Create HMAC-SHA256 signature"""
    signature = hmac.new(
        secret.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    return signature

# Example: Twitter-style authentication
timestamp = str(int(time.time()))
nonce = hashlib.md5(timestamp.encode()).hexdigest()
signature_base = f"GET&https://api.example.com/data&timestamp={timestamp}&nonce={nonce}"
signature = create_hmac_signature('your_secret', signature_base)

headers = {
    'X-Timestamp': timestamp,
    'X-Nonce': nonce,
    'X-Signature': signature
}
```

**Pagination handling:**

```python
#!/usr/bin/env python3
import requests
import time

def fetch_paginated_data(base_url, params=None, max_pages=None):
    """
    Fetch all pages from paginated API
    Supports multiple pagination styles
    """
    results = []
    page = 1
    params = params or {}
    
    while True:
        # Offset-based pagination
        params['offset'] = (page - 1) * params.get('limit', 100)
        params['limit'] = params.get('limit', 100)
        
        # Page-based pagination (alternative)
        # params['page'] = page
        
        response = requests.get(base_url, params=params)
        
        if response.status_code != 200:
            break
        
        data = response.json()
        
        # Extract results (adjust based on API structure)
        if isinstance(data, list):
            page_results = data
        elif 'data' in data:
            page_results = data['data']
        elif 'results' in data:
            page_results = data['results']
        else:
            page_results = []
        
        if not page_results:
            break
        
        results.extend(page_results)
        
        # Check if more pages exist
        if 'next' not in data and 'has_more' not in data:
            if len(page_results) < params.get('limit', 100):
                break
        
        if max_pages and page >= max_pages:
            break
        
        page += 1
        time.sleep(0.5)  # Rate limiting
    
    return results

# Cursor-based pagination
def fetch_cursor_paginated(base_url, params=None):
    """Handle cursor-based pagination"""
    results = []
    params = params or {}
    cursor = None
    
    while True:
        if cursor:
            params['cursor'] = cursor
        
        response = requests.get(base_url, params=params)
        data = response.json()
        
        results.extend(data.get('data', []))
        
        cursor = data.get('next_cursor')
        if not cursor:
            break
        
        time.sleep(0.5)
    
    return results

# Link header pagination (GitHub-style)
def fetch_link_header_paginated(base_url, headers=None):
    """Handle pagination via Link headers"""
    results = []
    url = base_url
    headers = headers or {}
    
    while url:
        response = requests.get(url, headers=headers)
        results.extend(response.json())
        
        # Parse Link header
        link_header = response.headers.get('Link', '')
        next_url = None
        
        for link in link_header.split(','):
            if 'rel="next"' in link:
                next_url = link.split(';')[0].strip('<> ')
                break
        
        url = next_url
        time.sleep(0.5)
    
    return results
```

**API wrapper class:**

```python
#!/usr/bin/env python3
import requests
import time
from typing import Optional, Dict, List
import logging

class APIWrapper:
    """Generic API wrapper with common functionality"""
    
    def __init__(self, base_url: str, api_key: Optional[str] = None,
                 rate_limit: int = 10, rate_period: int = 60):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        self.rate_limit = rate_limit
        self.rate_period = rate_period
        self.call_times = []
        self.logger = logging.getLogger(self.__class__.__name__)
        
        if api_key:
            self.session.headers.update({'Authorization': f'Bearer {api_key}'})
    
    def _rate_limit_wait(self):
        """Implement rate limiting"""
        now = time.time()
        self.call_times = [t for t in self.call_times if t > now - self.rate_period]
        
        if len(self.call_times) >= self.rate_limit:
            sleep_time = self.rate_period - (now - self.call_times[0])
            if sleep_time > 0:
                self.logger.info(f"Rate limit reached, sleeping {sleep_time:.2f}s")
                time.sleep(sleep_time)
                self.call_times = []
        
        self.call_times.append(time.time())
    
    def _request(self, method: str, endpoint: str, **kwargs) -> Optional[Dict]:
        """Make HTTP request with error handling"""
        self._rate_limit_wait()
        
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        try:
            response = self.session.request(method, url, **kwargs)
            response.raise_for_status()
            return response.json()
            
        except requests.HTTPError as e:
            self.logger.error(f"HTTP {e.response.status_code}: {e.response.text}")
            if e.response.status_code == 429:  # Too many requests
                retry_after = int(e.response.headers.get('Retry-After', 60))
                time.sleep(retry_after)
                return self._request(method, endpoint, **kwargs)
            return None
            
        except requests.RequestException as e:
            self.logger.error(f"Request failed: {str(e)}")
            return None
    
    def get(self, endpoint: str, params: Optional[Dict] = None) -> Optional[Dict]:
        """GET request"""
        return self._request('GET', endpoint, params=params)
    
    def post(self, endpoint: str, data: Optional[Dict] = None, 
             json: Optional[Dict] = None) -> Optional[Dict]:
        """POST request"""
        return self._request('POST', endpoint, data=data, json=json)
    
    def get_paginated(self, endpoint: str, params: Optional[Dict] = None,
                     max_pages: Optional[int] = None) -> List[Dict]:
        """Fetch all paginated results"""
        results = []
        params = params or {}
        page = 1
        
        while True:
            params['page'] = page
            data = self.get(endpoint, params=params)
            
            if not data or not data.get('results'):
                break
            
            results.extend(data['results'])
            
            if not data.get('has_more') or (max_pages and page >= max_pages):
                break
            
            page += 1
        
        return results

# Usage example
class GitHubAPI(APIWrapper):
    def __init__(self, token: str):
        super().__init__(
            base_url='https://api.github.com',
            api_key=token,
            rate_limit=5000,
            rate_period=3600
        )
        self.session.headers.update({
            'Accept': 'application/vnd.github.v3+json'
        })
    
    def get_user(self, username: str) -> Optional[Dict]:
        """Get user information"""
        return self.get(f'/users/{username}')
    
    def get_user_repos(self, username: str) -> List[Dict]:
        """Get all user repositories"""
        return self.get_paginated(f'/users/{username}/repos')
    
    def search_code(self, query: str) -> List[Dict]:
        """Search code"""
        data = self.get('/search/code', params={'q': query})
        return data.get('items', []) if data else []
```

### Common OSINT APIs

**Twitter/X API (v2):**

```python
#!/usr/bin/env python3
import requests
from typing import List, Dict, Optional

class TwitterAPI:
    def __init__(self, bearer_token: str):
        self.base_url = 'https://api.twitter.com/2'
        self.headers = {
            'Authorization': f'Bearer {bearer_token}',
            'Content-Type': 'application/json'
        }
    
    def get_user_by_username(self, username: str) -> Optional[Dict]:
        """Get user information by username"""
        url = f'{self.base_url}/users/by/username/{username}'
        params = {
            'user.fields': 'created_at,description,location,public_metrics,verified'
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            return response.json().get('data')
        return None
    
    def get_user_tweets(self, user_id: str, max_results: int = 100) -> List[Dict]:
        """Get user's recent tweets"""
        url = f'{self.base_url}/users/{user_id}/tweets'
        params = {
            'max_results': min(max_results, 100),
            'tweet.fields': 'created_at,public_metrics,entities',
            'expansions': 'author_id'
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            return response.json().get('data', [])
        return []
    
    def search_recent_tweets(self, query: str, max_results: int = 100) -> List[Dict]:
        """Search recent tweets"""
        url = f'{self.base_url}/tweets/search/recent'
        params = {
            'query': query,
            'max_results': min(max_results, 100),
            'tweet.fields': 'created_at,author_id,public_metrics'
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        if response.status_code == 200:
            return response.json().get('data', [])
        return []
    
    def get_followers(self, user_id: str, max_results: int = 1000) -> List[Dict]:
        """Get user's followers with pagination"""
        url = f'{self.base_url}/users/{user_id}/followers'
        followers = []
        pagination_token = None
        
        while len(followers) < max_results:
            params = {
                'max_results': min(1000, max_results - len(followers)),
                'user.fields': 'username,name,created_at'
            }
            
            if pagination_token:
                params['pagination_token'] = pagination_token
            
            response = requests.get(url, headers=self.headers, params=params)
            if response.status_code != 200:
                break
            
            data = response.json()
            followers.extend(data.get('data', []))
            
            pagination_token = data.get('meta', {}).get('next_token')
            if not pagination_token:
                break
        
        return followers
```

**GitHub API:**

```python
#!/usr/bin/env python3
import requests
from typing import List, Dict, Optional

class GitHubOSINT:
    def __init__(self, token: Optional[str] = None):
        self.base_url = 'https://api.github.com'
        self.headers = {'Accept': 'application/vnd.github.v3+json'}
        if token:
            self.headers['Authorization'] = f'token {token}'
    
    def get_user(self, username: str) -> Optional[Dict]:
        """Get user profile information"""
        response = requests.get(
            f'{self.base_url}/users/{username}',
            headers=self.headers
        )
        return response.json() if response.status_code == 200 else None
    
    def get_user_repos(self, username: str) -> List[Dict]:
        """Get all public repositories"""
        repos = []
        page = 1
        
        while True:
            response = requests.get(
                f'{self.base_url}/users/{username}/repos',
                headers=self.headers,
                params={'page': page, 'per_page': 100}
            )
            
            if response.status_code != 200:
                break
            
            data = response.json()
            if not data:
                break
            
            repos.extend(data)
            page += 1
        
        return repos
    
    def get_user_events(self, username: str) -> List[Dict]:
        """Get user's public events"""
        response = requests.get(
            f'{self.base_url}/users/{username}/events/public',
            headers=self.headers,
            params={'per_page': 100}
        )
        return response.json() if response.status_code == 200 else []
    
    def search_code(self, query: str, max_results: int = 100) -> List[Dict]:
        """Search code across GitHub"""
        results = []
        page = 1
        
        while len(results) < max_results:
            response = requests.get(
                f'{self.base_url}/search/code',
                headers=self.headers,
                params={
                    'q': query,
                    'page': page,
                    'per_page': min(100, max_results - len(results))
                }
            )
            
            if response.status_code != 200:
                break
            
            data = response.json()
            items = data.get('items', [])
            if not items:
                break
            
            results.extend(items)
            page += 1
            
            time.sleep(2)  # Rate limiting
        
        return results
    
    def get_user_gists(self, username: str) -> List[Dict]:
        """Get user's public gists"""
        response = requests.get(
            f'{self.base_url}/users/{username}/gists',
            headers=self.headers
        )
        return response.json() if response.status_code == 200 else []
    
    def get_commit_history(self, owner: str, repo: str, author: str) -> List[Dict]:
        """Get commit history for specific author"""
        response = requests.get(
            f'{self.base_url}/repos/{owner}/{repo}/commits',
            headers=self.headers,
            params={'author': author, 'per_page': 100}
        )
        return response.json() if response.status_code == 200 else []
```

**Shodan API:**

```python
#!/usr/bin/env python3
import requests
from typing import Dict, List, Optional

class ShodanAPI:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = 'https://api.shodan.io'
    
    def search(self, query: str, page: int = 1) -> Optional[Dict]:
        """Search Shodan"""
        url = f'{self.base_url}/shodan/host/search'
        params = {
            'key': self.api_key,
            'query': query,
            'page': page
        }
        
        response = requests.get(url, params=params)
        return response.json() if response.status_code == 200 else None
    
    def host(self, ip: str) -> Optional[Dict]:
        """Get information about a specific host"""
        url = f'{self.base_url}/shodan/host/{ip}'
        params = {'key': self.api_key}
        
        response = requests.get(url, params=params)
        return response.json() if response.status_code == 200 else None
    
    def dns_resolve(self, hostnames: List[str]) -> Optional[Dict]:
        """Resolve hostnames to IP addresses"""
        url = f'{self.base_url}/dns/resolve'
        params = {
            'key': self.api_key,
            'hostnames': ','.join(hostnames)
        }
        
        response = requests.get(url, params=params)
        return response.json() if response.status_code == 200 else None
    
    def search_facets(self, query: str, facets: List[str]) -> Optional[Dict]:
        """Get summary information (facets) for a search query"""
        url = f'{self.base_url}/shodan/host/search/facets'
        params = {
            'key': self.api_key,
            'query': query,
            'facets': ','.join(facets)
        }
        
        response = requests.get(url, params=params)
        return response.json() if response.status_code == 200 else None
```

**Have I Been Pwned API:**

```python
#!/usr/bin/env python3
import requests
import hashlib
from typing import List, Optional

class HIBPChecker:
    def __init__(self, api_key: Optional[str] = None):
        self.base_url = 'https://haveibeenpwned.com/api/v3'
        self.headers = {'User-Agent': 'OSINT-Tool'}
        if api_key:
            self.headers['hibp-api-key'] = api_key
    
    def check_email_breaches(self, email: str) -> List[Dict]:
        """Check if email appears in breaches"""
        url = f'{self.base_url}/breachedaccount/{email}'
        
        response = requests.get(url, headers=self.headers)
        
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 404:
            return []  # No breaches found
        else:
            return []
    
    def check_password_pwned(self, password: str) -> int:
        """
        Check if password has been pwned using k-anonymity
        Returns number of times password appears in breaches
        """
        sha1_hash = hashlib.sha1(password.encode()).hexdigest().upper()
        prefix = sha1_hash[:5]
        suffix = sha1_hash[5:]
        
        url = f'https://api.pwnedpasswords.com/range/{prefix}'
        response = requests.get(url)
        
        if response.status_code == 200:
            for line in response.text.splitlines():
                hash_suffix, count = line.split(':')
                if hash_suffix == suffix:
                    return int(count)
        
        return 0  # Not found in breaches
    
    def get_all_breaches(self) -> List[Dict]:
        """Get list of all breaches in the system"""
        url = f'{self.base_url}/breaches'
        response = requests.get(url, headers=self.headers)
        return response.json() if response.status_code == 200 else []
```

### API Response Caching

**Simple file-based caching:**

```python
#!/usr/bin/env python3
import json
import hashlib
import os
from datetime import datetime, timedelta
from pathlib import Path

class APICache:
    def __init__(self, cache_dir='./cache', ttl_seconds=3600):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(exist_ok=True)
        self.ttl = timedelta(seconds=ttl_seconds)
    
    def _get_cache_key(self, url: str, params: dict = None) -> str:
        """Generate cache key from URL and parameters"""
        cache_string = url
        if params:
            cache_string += json.dumps(params, sort_keys=True)
        
        return hashlib.md5(cache_string.encode()).hexdigest()
    
    def get(self, url: str, params: dict = None):
        """Retrieve cached response if valid"""
        cache_key = self._get_cache_key(url, params)
        cache_file = self.cache_dir / f'{cache_key}.json'
        
        if not cache_file.exists():
            return None
        
        # Check if cache is expired
        modified_time = datetime.fromtimestamp(cache_file.stat().st_mtime)
        if datetime.now() - modified_time > self.ttl:
            cache_file.unlink()
            return None
        
        with open(cache_file, 'r') as f:
            return json.load(f)
    
    def set(self, url: str, data, params: dict = None):
        """Store response in cache"""
        cache_key = self._get_cache_key(url, params)
        cache_file = self.cache_dir / f'{cache_key}.json'
        
        with open(cache_file, 'w') as f:
            json.dump(data, f)
    
    def clear(self):
        """Clear all cache files"""
        for cache_file in self.cache_dir.glob('*.json'):
            cache_file.unlink()

# Usage with requests
cache = APICache(ttl_seconds=3600)

def cached_get(url, params=None):
    # Check cache first
    cached_data = cache.get(url, params)
    if cached_data:
        return cached_data
    
    # Make request if not cached
    response = requests.get(url, params=params)
    data = response.json()
    
    # Store in cache
    cache.set(url, data, params)
    
    return data
```

**Using requests-cache library:**

```python
#!/usr/bin/env python3
import requests_cache

# Install SQLite-based cache
requests_cache.install_cache(
    'osint_cache',
    backend='sqlite',
    expire_after=3600  # 1 hour
)

# Now all requests are automatically cached
response = requests.get('https://api.example.com/data')

# Clear cache
requests_cache.clear()

# Disable cache for specific request
with requests_cache.disabled():
    response = requests.get('https://api.example.com/data')
```

## Web Scraping Fundamentals

Web scraping extracts data from websites not providing APIs. Effective scraping requires understanding HTML structure, handling dynamic content, and respecting website policies.

### Advanced BeautifulSoup Techniques

**Complex data extraction:**

```python
#!/usr/bin/env python3
from bs4 import BeautifulSoup
import requests
import re

def scrape_article(url):
    """Extract structured data from article page"""
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    article = {}
    
    # Extract title
    title_tag = soup.find('h1', class_='article-title') or soup.find('h1')
    article['title'] = title_tag.get_text(strip=True) if title_tag else None
    
    # Extract author
    author_tag = soup.find('span', class_='author') or soup.find('a', rel='author')
    article['author'] = author_tag.get_text(strip=True) if author_tag else None
    
    # Extract date
    date_tag = soup.find('time') or soup.find('span', class_='date')
    article['date'] = date_tag.get('datetime') or date_tag.get_text(strip=True) if date_tag else None
    
    # Extract content
    content_div = soup.find('div', class_='article-content') or soup.find('article')
    if content_div:
        # Remove unwanted elements
        for unwanted in content_div.find_all(['script', 'style', 'aside', 'nav']):
            unwanted.decompose()
        
        article['content'] = content_div.get_text(separator='\n', strip=True)
        
        # Extract images
        images = []
        for img in content_div.find_all('img'):
            images.append({
                'src': img.get('src'),
                'alt': img.get('alt'),
                'title': img.get('title')
            })
        article['images'] = images
    
    # Extract tags/categories
    tags = []
    for tag in soup.find_all('a', class_=re.compile('tag|category')):
        tags.append(tag.get_text(strip=True))
    article['tags'] = tags
    
    # Extract metadata
    meta_desc = soup.find('meta', attrs={'name': 'description'})
    article['meta_description'] = meta_desc.get('content') if meta_desc else None
    
    return article

# Extract structured data (Schema.org)
def extract_json_ld(url):
    """Extract JSON-LD structured data"""
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    json_ld_scripts = soup.find_all('script', type='application/ld+json')
    
    structured_data = []
    for script in json_ld_scripts:
        try:
            data = json.loads(script.string)
            structured_data.append(data)
        except json.JSONDecodeError:
            pass
    
    return structured_data

# Extract social media links
def extract_social_links(url):
    """Find social media profiles linked on page"""
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    social_platforms = {
        'twitter': r'twitter\.com/([^/\s"\']+)',
        'facebook': r'facebook\.com/([^/\s"\']+)',
        'linkedin': r'linkedin\.com/in/([^/\s"\']+)',
        'instagram': r'instagram\.com/([^/\s"\']+)',
        'github': r'github\.com/([^/\s"\']+)',
        'youtube': r'youtube\.com/(c/|channel/|user/)?([^/\s"\']+)'
    }
    
    social_links = {}
    
    for platform, pattern in social_platforms.items():
        links = soup.find_all('a', href=re.compile(pattern))
        if links:
            matches = []
            for link in links:
                href = link.get('href')
                match = re.search(pattern, href)
                if match:
                    username = match.group(1)
                    if username not in matches:
                        matches.append(username)
            social_links[platform] = matches
    
    return social_links
```

**Handling dynamic selectors:**

```python
#!/usr/bin/env python3
from bs4 import BeautifulSoup

def robust_find(soup, selectors_priority):
    """
    Try multiple selectors in order of priority
    Returns first successful match
    """
    for selector_type, selector_value in selectors_priority:
        if selector_type == 'id':
            element = soup.find(id=selector_value)
        elif selector_type == 'class':
            element = soup.find(class_=selector_value)
        elif selector_type == 'css':
            element = soup.select_one(selector_value)
        elif selector_type == 'xpath':
            # BeautifulSoup doesn't support XPath natively
            # Use lxml if XPath is needed
            pass
        else:
            element = None
        
        if element:
            return element
    
    return None

# Usage
selectors = [
    ('id', 'main-content'),
    ('class', 'content-wrapper'),
    ('css', 'div.article > div.body'),
    ('css', 'article')
]

content = robust_find(soup, selectors)
```

### Selenium Advanced Techniques

**Waiting strategies:**

```python
#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

driver = webdriver.Chrome()

# Wait for element to be present
try:
    element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, 'element-id'))
    )
except TimeoutException:
    print("Element not found")

# Wait for element to be visible
element = WebDriverWait(driver, 10).until(
    EC.visibility_of_element_located((By.CLASS_NAME, 'visible-class'))
)

# Wait for element to be clickable
button = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.ID, 'submit-button'))
)

# Wait for text to be present in element
WebDriverWait(driver, 10).until(
    EC.text_to_be_present_in_element((By.ID, 'status'), 'Complete')
)

# Wait for URL to change
WebDriverWait(driver, 10).until(
    EC.url_contains('success')
)

# Wait for number of windows to be
WebDriverWait(driver, 10).until(
    EC.number_of_windows_to_be(2)
)

# Custom wait condition
def element_has_attribute(locator, attribute):
    def check(driver):
        element = driver.find_element(*locator)
        return element.get_attribute(attribute) is not None
    return check

WebDriverWait(driver, 10).until(
    element_has_attribute((By.ID, 'element-id'), 'data-loaded')
)

# Wait for AJAX requests to complete
def wait_for_ajax(driver, timeout=10):
    """Wait for all AJAX requests to complete"""
    WebDriverWait(driver, timeout).until(
        lambda d: d.execute_script('return jQuery.active == 0')
    )

# Wait for page load complete
def wait_for_page_load(driver, timeout=30):
    """Wait for page to fully load"""
    WebDriverWait(driver, timeout).until(
        lambda d: d.execute_script('return document.readyState') == 'complete'
    )
```

**Handling dynamic content:**

```python
#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

class DynamicScraper:
    def __init__(self, headless=True):
        options = webdriver.ChromeOptions()
        if headless:
            options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-blink-features=AutomationControlled')
        
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 10)
    
    def infinite_scroll(self, url, max_scrolls=10):
        """Handle infinite scroll pages"""
        self.driver.get(url)
        
        items = []
        last_height = self.driver.execute_script("return document.body.scrollHeight")
        scrolls = 0
        
        while scrolls < max_scrolls:
            # Scroll to bottom
            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            
            # Wait for new content to load
            time.sleep(2)
            
            # Calculate new scroll height
            new_height = self.driver.execute_script("return document.body.scrollHeight")
            
            # Extract items
            elements = self.driver.find_elements(By.CLASS_NAME, 'item')
            items.extend([elem.text for elem in elements])
            
            # Check if reached bottom
            if new_height == last_height:
                break
            
            last_height = new_height
            scrolls += 1
        
        return list(set(items))  # Remove duplicates
    
    def click_load_more(self, url, button_selector, max_clicks=10):
        """Handle 'Load More' button pagination"""
        self.driver.get(url)
        
        items = []
        clicks = 0
        
        while clicks < max_clicks:
            # Extract current items
            elements = self.driver.find_elements(By.CLASS_NAME, 'item')
            items.extend([elem.text for elem in elements])
            
            try:
                # Find and click "Load More" button
                button = self.wait.until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, button_selector))
                )
                button.click()
                
                # Wait for new content
                time.sleep(2)
                clicks += 1
                
            except:
                # Button not found or not clickable
                break
        
        return list(set(items))
    
    def handle_lazy_images(self, url):
        """Trigger lazy-loaded images"""
        self.driver.get(url)
        
        # Scroll to each image to trigger loading
        images = self.driver.find_elements(By.TAG_NAME, 'img')
        
        for img in images:
            self.driver.execute_script("arguments[0].scrollIntoView();", img)
            time.sleep(0.5)
        
        # Extract image sources after loading
        loaded_images = []
        for img in images:
            src = img.get_attribute('src') or img.get_attribute('data-src')
            if src:
                loaded_images.append(src)
        
        return loaded_images
    
    def extract_shadow_dom(self, url):
        """Extract content from Shadow DOM"""
        self.driver.get(url)
        
        # Find shadow host element
        shadow_host = self.driver.find_element(By.CSS_SELECTOR, 'shadow-host-selector')
        
        # Access shadow root
        shadow_root = self.driver.execute_script(
            'return arguments[0].shadowRoot', 
            shadow_host
        )
        
        # Find elements within shadow root
        shadow_elements = shadow_root.find_elements(By.CSS_SELECTOR, '.item')
        
        return [elem.text for elem in shadow_elements]
    
    def close(self):
        self.driver.quit()
```

**Anti-detection techniques:**

```python
#!/usr/bin/env python3
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
import random
import time

def create_stealth_driver():
    """Create Selenium driver with anti-detection measures"""
    options = webdriver.ChromeOptions()
    
    # Stealth options
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)
    
    # Random user agent
    user_agents = [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    ]
    options.add_argument(f'user-agent={random.choice(user_agents)}')
    
    # Additional options
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--no-sandbox')
    
    driver = webdriver.Chrome(options=options)
    
    # Execute stealth scripts
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    
    driver.execute_cdp_cmd('Network.setUserAgentOverride', {
        "userAgent": random.choice(user_agents)
    })
    
    driver.execute_cdp_cmd('Page.addScriptToEvaluateOnNewDocument', {
        'source': '''
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en']
            });
        '''
    })
    
    return driver

def human_like_typing(element, text):
    """Type with human-like delays"""
    for char in text:
        element.send_keys(char)
        time.sleep(random.uniform(0.05, 0.2))

def human_like_scroll(driver):
    """Scroll with random patterns"""
    total_height = driver.execute_script("return document.body.scrollHeight")
    viewport_height = driver.execute_script("return window.innerHeight")
    
    current_position = 0
    
    while current_position < total_height:
        # Random scroll distance
        scroll_distance = random.randint(100, 400)
        current_position += scroll_distance
        
        driver.execute_script(f"window.scrollTo(0, {current_position});")
        
        # Random delay
        time.sleep(random.uniform(0.5, 2.0))
        
        # Occasionally scroll back up
        if random.random() < 0.1:
            current_position -= random.randint(50, 150)
            driver.execute_script(f"window.scrollTo(0, {current_position});")
            time.sleep(random.uniform(0.3, 1.0))

def random_mouse_movement(driver):
    """Simulate random mouse movements"""
    from selenium.webdriver.common.action_chains import ActionChains
    
    actions = ActionChains(driver)
    
    for _ in range(random.randint(2, 5)):
        x_offset = random.randint(-100, 100)
        y_offset = random.randint(-100, 100)
        actions.move_by_offset(x_offset, y_offset)
        actions.pause(random.uniform(0.1, 0.5))
    
    actions.perform()
```

### Handling CAPTCHAs and Bot Detection

[Inference] CAPTCHA solving typically requires human intervention or third-party services. Automated CAPTCHA solving may violate terms of service.

```python
#!/usr/bin/env python3
from selenium import webdriver
import time

class CaptchaHandler:
    def __init__(self, driver):
        self.driver = driver
    
    def detect_captcha(self):
        """Detect common CAPTCHA types"""
        captcha_indicators = [
            'recaptcha',
            'g-recaptcha',
            'captcha',
            'hcaptcha',
            'funcaptcha'
        ]
        
        for indicator in captcha_indicators:
            elements = self.driver.find_elements(By.CLASS_NAME, indicator)
            if elements:
                return True
        
        return False
    
    def wait_for_manual_solve(self, timeout=120):
        """
        Pause execution and wait for manual CAPTCHA solving
        [Unverified] This approach assumes human intervention
        """
        print("CAPTCHA detected. Please solve manually...")
        time.sleep(timeout)
    
    def use_audio_captcha(self):
        """
        Switch to audio CAPTCHA if available
        [Inference] Audio CAPTCHAs may be easier to automate
        but this approach has limitations
        """
        try:
            audio_button = self.driver.find_element(By.ID, 'recaptcha-audio-button')
            audio_button.click()
            time.sleep(2)
            # Audio processing would go here
        except:
            pass
```

### Proxy Management

```python
#!/usr/bin/env python3
import requests
from itertools import cycle
import random

class ProxyManager:
    def __init__(self, proxy_list_file=None):
        self.proxies = []
        if proxy_list_file:
            self.load_proxies(proxy_list_file)
        self.proxy_pool = cycle(self.proxies) if self.proxies else None
    
    def load_proxies(self, filename):
        """Load proxies from file"""
        with open(filename, 'r') as f:
            self.proxies = [line.strip() for line in f if line.strip()]
        
        if self.proxies:
            self.proxy_pool = cycle(self.proxies)
    
    def get_next_proxy(self):
        """Get next proxy from pool"""
        if self.proxy_pool:
            return next(self.proxy_pool)
        return None
    
    def get_random_proxy(self):
        """Get random proxy"""
        if self.proxies:
            return random.choice(self.proxies)
        return None
    
    def test_proxy(self, proxy, test_url='http://httpbin.org/ip'):
        """Test if proxy is working"""
        proxies = {
            'http': f'http://{proxy}',
            'https': f'http://{proxy}'
        }
        
        try:
            response = requests.get(test_url, proxies=proxies, timeout=10)
            return response.status_code == 200
        except:
            return False
    
    def get_working_proxies(self, test_url='http://httpbin.org/ip'):
        """Filter working proxies"""
        working = []
        
        for proxy in self.proxies:
            if self.test_proxy(proxy, test_url):
                working.append(proxy)
        
        return working
    
    def make_request(self, url, max_retries=3):
        """Make request with automatic proxy rotation"""
        for attempt in range(max_retries):
            proxy = self.get_next_proxy()
            
            if not proxy:
                # No proxies available, make direct request
                return requests.get(url)
            
            proxies = {
                'http': f'http://{proxy}',
                'https': f'http://{proxy}'
            }
            
            try:
                response = requests.get(url, proxies=proxies, timeout=10)
                return response
            except:
                continue
        
        raise Exception("All proxy attempts failed")

# Selenium with proxy
def create_driver_with_proxy(proxy):
    """Create Selenium driver with proxy"""
    options = webdriver.ChromeOptions()
    options.add_argument(f'--proxy-server={proxy}')
    
    driver = webdriver.Chrome(options=options)
    return driver

# Rotating proxy example
proxy_manager = ProxyManager('proxies.txt')

for i in range(10):
    proxy = proxy_manager.get_next_proxy()
    response = requests.get('https://api.example.com/data', proxies={
        'http': f'http://{proxy}',
        'https': f'http://{proxy}'
    })
```

### Session Management

```python
#!/usr/bin/env python3
import requests
import pickle
from pathlib import Path

class SessionManager:
    def __init__(self, session_file='session.pkl'):
        self.session_file = Path(session_file)
        self.session = requests.Session()
    
    def login(self, login_url, credentials):
        """Perform login and save session"""
        response = self.session.post(login_url, data=credentials)
        
        if response.status_code == 200:
            self.save_session()
            return True
        return False
    
    def save_session(self):
        """Save session cookies to file"""
        with open(self.session_file, 'wb') as f:
            pickle.dump(self.session.cookies, f)
    
    def load_session(self):
        """Load session cookies from file"""
        if self.session_file.exists():
            with open(self.session_file, 'rb') as f:
                self.session.cookies.update(pickle.load(f))
            return True
        return False
    
    def is_logged_in(self, test_url):
        """Check if session is still valid"""
        response = self.session.get(test_url)
        # Check for login indicators in response
        return 'logout' in response.text.lower()
    
    def get(self, url, **kwargs):
        """Make GET request with session"""
        return self.session.get(url, **kwargs)
    
    def post(self, url, **kwargs):
        """Make POST request with session"""
        return self.session.post(url, **kwargs)

# Selenium session persistence
def save_selenium_cookies(driver, filename='cookies.pkl'):
    """Save Selenium cookies"""
    with open(filename, 'wb') as f:
        pickle.dump(driver.get_cookies(), f)

def load_selenium_cookies(driver, filename='cookies.pkl'):
    """Load Selenium cookies"""
    if Path(filename).exists():
        with open(filename, 'rb') as f:
            cookies = pickle.load(f)
            for cookie in cookies:
                driver.add_cookie(cookie)
```

## Custom Tool Development

Building custom OSINT tools enables automation of repetitive workflows and integration of multiple data sources.

### Command-Line Tool Structure

```python
#!/usr/bin/env python3
import argparse
import sys
import json
from pathlib import Path

class OSINTTool:
    def __init__(self):
        self.parser = self.create_parser()
    
    def create_parser(self):
        """Create argument parser"""
        parser = argparse.ArgumentParser(
            description='OSINT Investigation Tool',
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='''
Examples:
  %(prog)s username john_doe --platform twitter
  %(prog)s email user@example.com --check-breach
  %(prog)s domain example.com --dns
            '''
        )
        
        # Subcommands
        subparsers = parser.add_subparsers(dest='command', help='Command to execute')
        
        # Username lookup
        username_parser = subparsers.add_parser('username', help='Lookup username')
        username_parser.add_argument('target', help='Username to search')
        username_parser.add_argument('--platform', choices=['twitter', 'github', 'instagram'],
                                    help='Specific platform to check')
        username_parser.add_argument('--output', '-o', help='Output file')
        
        # Email lookup
        email_parser = subparsers.add_parser('email', help='Lookup email')
        email_parser.add_argument('target', help='Email address')
        email_parser.add_argument('--check-breach', action='store_true',
                                 help='Check data breaches')
        email_parser.add_argument('--output', '-o', help='Output file')
        
        # Domain lookup
        domain_parser = subparsers.add_parser('domain', help='Domain investigation')
        domain_parser.add_argument('target', help='Domain name')
        domain_parser.add_argument('--dns', action='store_true', help='DNS lookup')
        domain_parser.add_argument('--whois', action='store_true', help='WHOIS lookup')
        domain_parser.add_argument('--output', '-o', help='Output file')
        
        # Global options
        parser.add_argument('--verbose', '-v', action='store_true',
                          help='Verbose output')
        parser.add_argument('--format', choices=['json', 'csv', 'txt'],
                          default='json', help='Output format')
        
        return parser
    
    def username_lookup(self, args):
        """Perform username lookup"""
        results = {
            'username': args.target,
            'platforms': {}
        }
        
        # Implement platform-specific lookups
        if args.platform:
            results['platforms'][args.platform] = self.check_platform(
                args.platform, args.target
            )
        else:
            # Check all platforms
            for platform in ['twitter', 'github', 'instagram']:
                results['platforms'][platform] = self.check_platform(
                    platform, args.target
                )
        
        return results
    
    def check_platform(self, platform, username):
        """Check if username exists on platform"""
        # Placeholder implementation
        return {'exists': True, 'url': f'https://{platform}.com/{username}'}
    
    def email_lookup(self, args):
        """Perform email lookup"""
        results = {
            'email': args.target,
            'breaches': []
        }
        
        if args.check_breach:
            # Implement breach checking
            results['breaches'] = self.check_breaches(args.target)
        
        return results
    
    def check_breaches(self, email):
        """Check email in breaches"""
        # Placeholder implementation
        return []
    
    def domain_lookup(self, args):
        """Perform domain lookup"""
        results = {
            'domain': args.target
        }
        
        if args.dns:
            results['dns'] = self.dns_lookup(args.target)
        
        if args.whois:
            results['whois'] = self.whois_lookup(args.target)
        
        return results
    
    def dns_lookup(self, domain):
        """Perform DNS lookup"""
        import socket
        try:
            return {'ip': socket.gethostbyname(domain)}
        except:
            return {'error': 'DNS lookup failed'}
    
    def whois_lookup(self, domain):
        """Perform WHOIS lookup"""
        # Placeholder
        return {}
    
    def save_results(self, results, filename, format_type):
        """Save results to file"""
        path = Path(filename)
        
        if format_type == 'json':
            with open(path, 'w') as f:
                json.dump(results, f, indent=2)
        
        elif format_type == 'csv':
            # Implement CSV export
            pass
        
        elif format_type == 'txt':
            with open(path, 'w') as f:
                f.write(str(results))
    
    def run(self):
        """Main execution method"""
        args = self.parser.parse_args()
        
        if not args.command:
            self.parser.print_help()
            sys.exit(1)
        
        # Execute command
        if args.command == 'username':
            results = self.username_lookup(args)
        elif args.command == 'email':
            results = self.email_lookup(args)
        elif args.command == 'domain':
            results = self.domain_lookup(args)
        else:
            print(f"Unknown command: {args.command}")
            sys.exit(1)
        
        # Output results
        if args.output:
            self.save_results(results, args.output, args.format)
            print(f"Results saved to {args.output}")
        else:
            print(json.dumps(results, indent=2))

if __name__ == '__main__':
    tool = OSINTTool()
    tool.run()
```

### Configuration Management

```python
#!/usr/bin/env python3
import json
import yaml
from pathlib import Path
import os

class Config:
    def __init__(self, config_file='config.yaml'):
        self.config_file = Path(config_file)
        self.config = self.load_config()
    
    def load_config(self):
        """Load configuration from file"""
        if not self.config_file.exists():
            return self.create_default_config()
        
        with open(self.config_file, 'r') as f:
            if self.config_file.suffix == '.yaml' or self.config_file.suffix == '.yml':
                return yaml.safe_load(f)
            elif self.config_file.suffix == '.json':
                return json.load(f)
        
        return {}
    
    def create_default_config(self):
        """Create default configuration"""
        default_config = {
            'api_keys': {
                'twitter': os.getenv('TWITTER_API_KEY', ''),
                'github': os.getenv('GITHUB_TOKEN', ''),
                'shodan': os.getenv('SHODAN_API_KEY', '')
            },
            'settings': {
                'rate_limit': 10,
                'timeout': 30,
                'user_agent': 'OSINT-Tool/1.0',
                'proxies': []
            },
            'output': {
                'format': 'json',
                'directory': './output'
            }
        }
        
        self.save_config(default_config)
        return default_config
    
    def save_config(self, config=None):
        """Save configuration to file"""
        if config is None:
            config = self.config
        
        with open(self.config_file, 'w') as f:
            if self.config_file.suffix in ['.yaml', '.yml']:
                yaml.dump(config, f, default_flow_style=False)
            elif self.config_file.suffix == '.json':
                json.dump(config, f, indent=2)
    
    def get(self, key, default=None):
        """Get configuration value"""
        keys = key.split('.')
        value = self.config
        
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
                if value is None:
                    return default
            else:
                return default
        
        return value
    
    def set(self, key, value):
        """Set configuration value"""
        keys = key.split('.')
        config = self.config
        
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        config[keys[-1]] = value
        self.save_config()

# Usage
config = Config()
twitter_key = config.get('api_keys.twitter')
config.set('settings.rate_limit', 20)
```

### Plugin System

```python
#!/usr/bin/env python3
import importlib
import inspect
from pathlib import Path
from abc import ABC, abstractmethod

class PluginBase(ABC):
    """Base class for plugins"""
    
    @abstractmethod
    def get_name(self):
        """Return plugin name"""
        pass
    
    @abstractmethod
    def execute(self, target, **kwargs):
        """Execute plugin functionality"""
        pass

class PluginManager:
    def __init__(self, plugin_dir='./plugins'):
        self.plugin_dir = Path(plugin_dir)
        self.plugins = {}
        self.load_plugins()
    
    def load_plugins(self):
        """Load all plugins from plugin directory"""
        if not self.plugin_dir.exists():
            self.plugin_dir.mkdir(parents=True)
            return
        
        for file in self.plugin_dir.glob('*.py'):
            if file.stem.startswith('_'):
                continue
            
            try:
                # Import module
                spec = importlib.util.spec_from_file_location(file.stem, file)
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                
                # Find plugin classes
                for name, obj in inspect.getmembers(module):
                    if (inspect.isclass(obj) and 
                        issubclass(obj, PluginBase) and 
                        obj != PluginBase):
                        
                        plugin = obj()
                        self.plugins[plugin.get_name()] = plugin
                        
            except Exception as e:
                print(f"Failed to load plugin {file.stem}: {str(e)}")
    
    def get_plugin(self, name):
        """Get plugin by name"""
        return self.plugins.get(name)
    
    def list_plugins(self):
        """List all loaded plugins"""
        return list(self.plugins.keys())
    
    def execute_plugin(self, name, target, **kwargs):
        """Execute specific plugin"""
        plugin = self.get_plugin(name)
        if plugin:
            return plugin.execute(target, **kwargs)
        return None

# Example plugin (save as plugins/twitter_plugin.py)
"""
from plugin_base import PluginBase

class TwitterPlugin(PluginBase):
    def get_name(self):
        return 'twitter'
    
    def execute(self, target, **kwargs):
        # Implement Twitter lookup
        return {
            'username': target,
            'exists': True
        }
"""
```

## Workflow Automation

Automating complete OSINT workflows chains multiple tools and data sources into comprehensive investigations.

### Investigation Workflow

```python
#!/usr/bin/env python3
import json
from datetime import datetime
from pathlib import Path

class OSINTWorkflow:
    def __init__(self, target, workflow_type='username'):
        self.target = target
        self.workflow_type = workflow_type
        self.results = {
            'target': target,
            'type': workflow_type,
            'timestamp': datetime.now().isoformat(),
            'steps': []
        }
        self.output_dir = Path(f'./investigations/{target}_{datetime.now().strftime("%Y%m%d_%H%M%S")}')
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def add_step_result(self, step_name, data):
        """Add result from workflow step"""
        self.results['steps'].append({
            'name': step_name,
            'timestamp': datetime.now().isoformat(),
            'data': data
        })
    
    def save_results(self):
        """Save complete workflow results"""
        output_file = self.output_dir / 'results.json'
        with open(output_file, 'w') as f:
            json.dump(self.results, f, indent=2)
    
    def username_workflow(self):
        """Complete username investigation workflow"""
        print(f"Starting username investigation for: {self.target}")
        
        # Step 1: Platform enumeration
        print("[1/5] Checking social media platforms...")
        platforms = self.check_platforms(self.target)
        self.add_step_result('platform_enumeration', platforms)
        
        # Step 2: Profile data collection
        print("[2/5] Collecting profile data...")
        profiles = {}
        for platform, data in platforms.items():
            if data.get('exists'):
                profile = self.get_profile_data(platform, self.target)
                profiles[platform] = profile
        self.add_step_result('profile_collection', profiles)
        
        # Step 3: Associated accounts discovery
        print("[3/5] Finding associated accounts...")
        associated = self.find_associated_accounts(profiles)
        self.add_step_result('associated_accounts', associated)
        
        # Step 4: Content analysis
        print("[4/5] Analyzing public content...")
        content = self.analyze_content(profiles)
        self.add_step_result('content_analysis', content)
        
        # Step 5: Generate report
        print("[5/5] Generating report...")
        self.generate_report()
        
        self.save_results()
        print(f"\nInvestigation complete. Results saved to: {self.output_dir}")
    
    def check_platforms(self, username):
        """Check username across multiple platforms"""
        # Placeholder implementation
        return {
            'twitter': {'exists': True, 'url': f'https://twitter.com/{username}'},
            'github': {'exists': True, 'url': f'https://github.com/{username}'},
            'instagram': {'exists': False}
        }
    
    def get_profile_data(self, platform, username):
        """Collect profile data from platform"""
        # Placeholder implementation
        return {
            'username': username,
            'bio': 'Sample bio',
            'followers': 1000
        }
    
    def find_associated_accounts(self, profiles):
        """Find associated accounts across platforms"""
        # Placeholder implementation
        return []
    
    def analyze_content(self, profiles):
        """Analyze public content"""
        # Placeholder implementation
        return {}
    
	
	def generate_report(self):
	    """Generate HTML report"""
	    report_html = f"""
	    <!DOCTYPE html>
	    <html>
	    <head>
	        <title>OSINT Report: {self.target}</title>
	        <style>
	            body {{ font-family: Arial, sans-serif; margin: 40px; }}
	            h1 {{ color: #333; }}
	            .section {{ margin: 20px 0; padding: 20px; border: 1px solid #ddd; }}
	        </style>
	    </head>
	    <body>
	        <h1>OSINT Investigation Report</h1>
	        <div class="section">
	            <h2>Target Information</h2>
	            <p><strong>Target:</strong> {self.target}</p>
	            <p><strong>Workflow Type:</strong> {self.workflow_type}</p>
	            <p><strong>Date:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
	        </div>
	        <div class="section">
	            <h2>Summary</h2>
	            <pre>{json.dumps(self.results, indent=2)}</pre>
	        </div>
	    </body>
	    </html>
	    """
	
	    report_file = self.output_dir / 'report.html'
	    with open(report_file, 'w') as f:
	        f.write(report_html)

def run(self):
    """Execute workflow based on type"""
    if self.workflow_type == 'username':
        self.username_workflow()
    elif self.workflow_type == 'email':
        self.email_workflow()
    elif self.workflow_type == 'domain':
        self.domain_workflow()
    else:
        print(f"Unknown workflow type: {self.workflow_type}")

def email_workflow(self):
    """Complete email investigation workflow"""
    print(f"Starting email investigation for: {self.target}")
    
    # Email verification
    print("[1/4] Verifying email format...")
    is_valid = self.verify_email_format(self.target)
    self.add_step_result('email_validation', {'valid': is_valid})
    
    # Breach checking
    print("[2/4] Checking data breaches...")
    breaches = self.check_email_breaches(self.target)
    self.add_step_result('breach_check', breaches)
    
    # Domain analysis
    print("[3/4] Analyzing email domain...")
    domain = self.target.split('@')[1]
    domain_info = self.analyze_email_domain(domain)
    self.add_step_result('domain_analysis', domain_info)
    
    # Report generation
    print("[4/4] Generating report...")
    self.generate_report()
    self.save_results()

def verify_email_format(self, email):
    """Verify email format"""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def check_email_breaches(self, email):
    """Check email in data breaches"""
    # Placeholder - implement HIBP integration
    return []

def analyze_email_domain(self, domain):
    """Analyze email domain"""
    # Placeholder
    return {'domain': domain}

def domain_workflow(self):
    """Complete domain investigation workflow"""
    print(f"Starting domain investigation for: {self.target}")
    
    # DNS enumeration
    print("[1/6] DNS enumeration...")
    dns_records = self.enumerate_dns(self.target)
    self.add_step_result('dns_enumeration', dns_records)
    
    # WHOIS lookup
    print("[2/6] WHOIS lookup...")
    whois_data = self.whois_lookup(self.target)
    self.add_step_result('whois', whois_data)
    
    # Subdomain enumeration
    print("[3/6] Subdomain enumeration...")
    subdomains = self.enumerate_subdomains(self.target)
    self.add_step_result('subdomains', subdomains)
    
    # SSL/TLS analysis
    print("[4/6] SSL/TLS certificate analysis...")
    ssl_info = self.analyze_ssl(self.target)
    self.add_step_result('ssl_analysis', ssl_info)
    
    # Web technology detection
    print("[5/6] Detecting web technologies...")
    technologies = self.detect_technologies(self.target)
    self.add_step_result('technologies', technologies)
    
    # Report generation
    print("[6/6] Generating report...")
    self.generate_report()
    self.save_results()

def enumerate_dns(self, domain):
    """Enumerate DNS records"""
    import socket
    records = {}
    
    try:
        records['A'] = socket.gethostbyname(domain)
    except:
        records['A'] = None
    
    return records

def whois_lookup(self, domain):
    """Perform WHOIS lookup"""
    # Placeholder
    return {}

def enumerate_subdomains(self, domain):
    """Enumerate subdomains"""
    # Placeholder
    return []

def analyze_ssl(self, domain):
    """Analyze SSL/TLS certificate"""
    # Placeholder
    return {}

def detect_technologies(self, domain):
    """Detect web technologies"""
    # Placeholder
    return []

# Usage

if __name__ == '__main__': 
	workflow = OSINTWorkflow('john_doe', 'username') 
	workflow.run()
````

### Scheduled Monitoring

```python
#!/usr/bin/env python3
import schedule
import time
import json
from datetime import datetime
from pathlib import Path
import hashlib

class OSINTMonitor:
    def __init__(self, config_file='monitor_config.json'):
        self.config_file = Path(config_file)
        self.config = self.load_config()
        self.state_dir = Path('./monitor_state')
        self.state_dir.mkdir(exist_ok=True)
    
    def load_config(self):
        """Load monitoring configuration"""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                return json.load(f)
        
        # Default configuration
        return {
            'targets': [],
            'checks': {
                'social_media': True,
                'web_changes': True,
                'dns_changes': True
            },
            'interval': 3600,  # seconds
            'notifications': {
                'enabled': False,
                'email': None,
                'webhook': None
            }
        }
    
    def add_target(self, target, target_type='username'):
        """Add target to monitoring"""
        self.config['targets'].append({
            'value': target,
            'type': target_type,
            'added': datetime.now().isoformat()
        })
        self.save_config()
    
    def save_config(self):
        """Save configuration"""
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def get_state_file(self, target):
        """Get state file path for target"""
        target_hash = hashlib.md5(target.encode()).hexdigest()
        return self.state_dir / f'{target_hash}.json'
    
    def load_state(self, target):
        """Load previous state for target"""
        state_file = self.get_state_file(target)
        if state_file.exists():
            with open(state_file, 'r') as f:
                return json.load(f)
        return {}
    
    def save_state(self, target, state):
        """Save current state for target"""
        state_file = self.get_state_file(target)
        with open(state_file, 'w') as f:
            json.dump(state, f, indent=2)
    
    def check_target(self, target_info):
        """Check target for changes"""
        target = target_info['value']
        target_type = target_info['type']
        
        print(f"Checking {target_type}: {target}")
        
        # Get current state
        current_state = self.collect_current_state(target, target_type)
        
        # Load previous state
        previous_state = self.load_state(target)
        
        # Detect changes
        changes = self.detect_changes(previous_state, current_state)
        
        if changes:
            print(f"Changes detected for {target}:")
            for change in changes:
                print(f"  - {change}")
            
            # Send notifications
            if self.config['notifications']['enabled']:
                self.send_notification(target, changes)
        
        # Save current state
        self.save_state(target, current_state)
    
    def collect_current_state(self, target, target_type):
        """Collect current state of target"""
        state = {
            'timestamp': datetime.now().isoformat(),
            'target': target,
            'type': target_type
        }
        
        if target_type == 'username':
            state['social_media'] = self.check_social_media(target)
        elif target_type == 'domain':
            state['dns'] = self.check_dns(target)
            state['web_content'] = self.check_web_content(target)
        elif target_type == 'email':
            state['breaches'] = self.check_breaches(target)
        
        return state
    
    def check_social_media(self, username):
        """Check social media profiles"""
        # Placeholder - implement actual checks
        return {
            'twitter': {'exists': True, 'followers': 1000},
            'github': {'exists': True, 'repos': 5}
        }
    
    def check_dns(self, domain):
        """Check DNS records"""
        import socket
        try:
            ip = socket.gethostbyname(domain)
            return {'A': ip}
        except:
            return {}
    
    def check_web_content(self, domain):
        """Check web content hash"""
        import requests
        import hashlib
        
        try:
            response = requests.get(f'https://{domain}', timeout=10)
            content_hash = hashlib.md5(response.text.encode()).hexdigest()
            return {'hash': content_hash, 'status': response.status_code}
        except:
            return {}
    
    def check_breaches(self, email):
        """Check data breaches"""
        # Placeholder
        return []
    
    def detect_changes(self, previous, current):
        """Detect changes between states"""
        changes = []
        
        if not previous:
            return ['Initial state recorded']
        
        # Compare social media
        if 'social_media' in current:
            for platform, data in current['social_media'].items():
                prev_data = previous.get('social_media', {}).get(platform, {})
                
                if not prev_data.get('exists') and data.get('exists'):
                    changes.append(f'New {platform} account detected')
                
                if 'followers' in data and 'followers' in prev_data:
                    if data['followers'] != prev_data['followers']:
                        diff = data['followers'] - prev_data['followers']
                        changes.append(f'{platform} followers changed by {diff:+d}')
        
        # Compare DNS
        if 'dns' in current and 'dns' in previous:
            if current['dns'] != previous['dns']:
                changes.append(f'DNS records changed')
        
        # Compare web content
        if 'web_content' in current and 'web_content' in previous:
            if current['web_content'].get('hash') != previous['web_content'].get('hash'):
                changes.append('Website content changed')
        
        # Compare breaches
        if 'breaches' in current and 'breaches' in previous:
            new_breaches = set(current['breaches']) - set(previous['breaches'])
            if new_breaches:
                changes.append(f'New data breaches: {", ".join(new_breaches)}')
        
        return changes
    
    def send_notification(self, target, changes):
        """Send notification about changes"""
        message = f"Changes detected for {target}:\n"
        message += "\n".join(f"- {change}" for change in changes)
        
        # Email notification
        if self.config['notifications'].get('email'):
            self.send_email_notification(message)
        
        # Webhook notification
        if self.config['notifications'].get('webhook'):
            self.send_webhook_notification(target, changes)
        
        # Log to file
        log_file = Path('./monitor_changes.log')
        with open(log_file, 'a') as f:
            f.write(f"[{datetime.now().isoformat()}] {message}\n\n")
    
    def send_email_notification(self, message):
        """Send email notification"""
        # Placeholder - implement SMTP
        print(f"Email notification: {message}")
    
    def send_webhook_notification(self, target, changes):
        """Send webhook notification"""
        import requests
        
        webhook_url = self.config['notifications']['webhook']
        payload = {
            'target': target,
            'changes': changes,
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            requests.post(webhook_url, json=payload)
        except:
            pass
    
    def check_all_targets(self):
        """Check all monitored targets"""
        for target_info in self.config['targets']:
            try:
                self.check_target(target_info)
            except Exception as e:
                print(f"Error checking {target_info['value']}: {str(e)}")
    
    def start_monitoring(self):
        """Start scheduled monitoring"""
        interval_minutes = self.config['interval'] // 60
        
        print(f"Starting OSINT monitoring (checking every {interval_minutes} minutes)")
        print(f"Monitoring {len(self.config['targets'])} targets")
        
        # Schedule checks
        schedule.every(interval_minutes).minutes.do(self.check_all_targets)
        
        # Run immediately
        self.check_all_targets()
        
        # Keep running
        while True:
            schedule.run_pending()
            time.sleep(60)

# Usage
if __name__ == '__main__':
    monitor = OSINTMonitor()
    monitor.add_target('john_doe', 'username')
    monitor.add_target('example.com', 'domain')
    monitor.start_monitoring()
````

### Batch Processing

```python
#!/usr/bin/env python3
import csv
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import json
from datetime import datetime

class BatchProcessor:
    def __init__(self, max_workers=5):
        self.max_workers = max_workers
        self.results = []
    
    def load_targets(self, input_file):
        """Load targets from CSV file"""
        targets = []
        
        with open(input_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                targets.append(row)
        
        return targets
    
    def process_target(self, target):
        """Process single target"""
        target_type = target.get('type', 'username')
        target_value = target.get('value')
        
        print(f"Processing {target_type}: {target_value}")
        
        result = {
            'target': target_value,
            'type': target_type,
            'timestamp': datetime.now().isoformat(),
            'status': 'success'
        }
        
        try:
            if target_type == 'username':
                result['data'] = self.process_username(target_value)
            elif target_type == 'email':
                result['data'] = self.process_email(target_value)
            elif target_type == 'domain':
                result['data'] = self.process_domain(target_value)
            else:
                result['status'] = 'error'
                result['error'] = f'Unknown type: {target_type}'
        
        except Exception as e:
            result['status'] = 'error'
            result['error'] = str(e)
        
        return result
    
    def process_username(self, username):
        """Process username target"""
        # Placeholder implementation
        return {'username': username, 'platforms': []}
    
    def process_email(self, email):
        """Process email target"""
        # Placeholder implementation
        return {'email': email, 'breaches': []}
    
    def process_domain(self, domain):
        """Process domain target"""
        # Placeholder implementation
        return {'domain': domain, 'dns': {}}
    
    def process_batch(self, targets):
        """Process targets in parallel"""
        self.results = []
        
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.process_target, target): target 
                      for target in targets}
            
            for future in as_completed(futures):
                result = future.result()
                self.results.append(result)
                
                status = result['status']
                target = result['target']
                print(f"Completed {target}: {status}")
        
        return self.results
    
    def save_results(self, output_file):
        """Save results to file"""
        output_path = Path(output_file)
        
        if output_path.suffix == '.json':
            with open(output_path, 'w') as f:
                json.dump(self.results, f, indent=2)
        
        elif output_path.suffix == '.csv':
            if not self.results:
                return
            
            keys = ['target', 'type', 'status', 'timestamp']
            
            with open(output_path, 'w', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                
                for result in self.results:
                    row = {k: result.get(k) for k in keys}
                    writer.writerow(row)
    
    def generate_summary(self):
        """Generate summary statistics"""
        total = len(self.results)
        successful = sum(1 for r in self.results if r['status'] == 'success')
        failed = total - successful
        
        by_type = {}
        for result in self.results:
            target_type = result['type']
            by_type[target_type] = by_type.get(target_type, 0) + 1
        
        summary = {
            'total_processed': total,
            'successful': successful,
            'failed': failed,
            'by_type': by_type,
            'timestamp': datetime.now().isoformat()
        }
        
        return summary

# Usage
if __name__ == '__main__':
    processor = BatchProcessor(max_workers=10)
    
    # Load targets from CSV
    # Format: value,type
    # john_doe,username
    # user@example.com,email
    
    targets = processor.load_targets('targets.csv')
    results = processor.process_batch(targets)
    
    processor.save_results('results.json')
    
    summary = processor.generate_summary()
    print(json.dumps(summary, indent=2))
```

### Data Pipeline

```python
#!/usr/bin/env python3
from typing import List, Callable, Any
import logging

class DataPipeline:
    """
    Data processing pipeline for OSINT workflows
    Allows chaining of processing steps
    """
    
    def __init__(self):
        self.steps: List[Callable] = []
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def add_step(self, func: Callable, name: str = None):
        """Add processing step to pipeline"""
        step_name = name or func.__name__
        
        def wrapped_step(data):
            self.logger.info(f"Executing step: {step_name}")
            try:
                result = func(data)
                self.logger.info(f"Step {step_name} completed")
                return result
            except Exception as e:
                self.logger.error(f"Step {step_name} failed: {str(e)}")
                raise
        
        self.steps.append(wrapped_step)
        return self
    
    def process(self, initial_data: Any) -> Any:
        """Execute pipeline on data"""
        data = initial_data
        
        for step in self.steps:
            data = step(data)
        
        return data
    
    def clear(self):
        """Clear all pipeline steps"""
        self.steps = []

# Example pipeline for username investigation
def create_username_pipeline():
    """Create pipeline for username investigation"""
    pipeline = DataPipeline()
    
    # Step 1: Validate input
    def validate_username(data):
        username = data['username']
        if not username or len(username) < 3:
            raise ValueError("Invalid username")
        return data
    
    # Step 2: Check platforms
    def check_platforms(data):
        username = data['username']
        # Placeholder implementation
        data['platforms'] = {
            'twitter': True,
            'github': True,
            'instagram': False
        }
        return data
    
    # Step 3: Collect profiles
    def collect_profiles(data):
        profiles = {}
        for platform, exists in data['platforms'].items():
            if exists:
                # Placeholder
                profiles[platform] = {
                    'username': data['username'],
                    'bio': f'Sample bio for {platform}'
                }
        data['profiles'] = profiles
        return data
    
    # Step 4: Extract metadata
    def extract_metadata(data):
        metadata = {}
        for platform, profile in data.get('profiles', {}).items():
            # Extract emails, URLs, etc.
            metadata[platform] = {
                'extracted_emails': [],
                'extracted_urls': []
            }
        data['metadata'] = metadata
        return data
    
    # Step 5: Enrich data
    def enrich_data(data):
        # Add additional context
        data['enriched'] = True
        data['confidence_score'] = 0.85
        return data
    
    # Build pipeline
    pipeline.add_step(validate_username, "Validate Input")
    pipeline.add_step(check_platforms, "Check Platforms")
    pipeline.add_step(collect_profiles, "Collect Profiles")
    pipeline.add_step(extract_metadata, "Extract Metadata")
    pipeline.add_step(enrich_data, "Enrich Data")
    
    return pipeline

# Usage
pipeline = create_username_pipeline()
result = pipeline.process({'username': 'john_doe'})
print(json.dumps(result, indent=2))
```

---

**Related topics for advanced automation:**

- Machine learning integration for pattern recognition and anomaly detection
- Distributed computing for large-scale OSINT operations
- Real-time streaming data processing
- Natural language processing for content analysis
- Graph databases for relationship mapping
- CI/CD integration for automated OSINT workflows
- Containerization and deployment (Docker, Kubernetes)
- Cloud platform integration (AWS, Azure, GCP)



---

# Data Analysis and Visualization

## Link Analysis

### Fundamentals of Link Analysis

**Definition**: Systematic examination of connections between entities (people, organizations, events, locations, digital artifacts) to identify patterns, relationships, and hidden structures.

**Core Components**:

- **Nodes**: Entities being analyzed (persons, IPs, domains, accounts)
- **Edges**: Relationships or connections between nodes
- **Attributes**: Properties of nodes/edges (weight, type, timestamp)
- **Directionality**: Unidirectional vs bidirectional relationships

### Link Analysis Methodologies

**Network Centrality Measures**:

**Degree Centrality**: Number of direct connections

```python
# NetworkX example
import networkx as nx

G = nx.Graph()
G.add_edges_from([('A', 'B'), ('A', 'C'), ('B', 'D')])
degree_centrality = nx.degree_centrality(G)
# Returns: {'A': 0.667, 'B': 0.667, 'C': 0.333, 'D': 0.333}
```

**Betweenness Centrality**: Frequency a node appears on shortest paths

```python
betweenness = nx.betweenness_centrality(G)
# Identifies "bridge" nodes connecting different clusters
```

**Closeness Centrality**: Average distance to all other nodes

```python
closeness = nx.closeness_centrality(G)
# Identifies nodes that can quickly reach others
```

**Eigenvector Centrality**: Influence based on connections to influential nodes

```python
eigenvector = nx.eigenvector_centrality(G)
# High-value connections to high-value nodes
```

**PageRank**: Google's algorithm for importance weighting

```python
pagerank = nx.pagerank(G)
# Considers both quantity and quality of connections
```

### Python Tools for Link Analysis

**NetworkX** (Graph analysis library):

```python
import networkx as nx
import matplotlib.pyplot as plt

# Create directed graph
G = nx.DiGraph()

# Add nodes with attributes
G.add_node('IP_192.168.1.100', type='host', role='server')
G.add_node('IP_10.0.0.50', type='host', role='client')
G.add_node('domain.com', type='domain')

# Add edges with attributes
G.add_edge('IP_10.0.0.50', 'IP_192.168.1.100', 
           protocol='HTTP', timestamp='2025-01-15T10:30:00')
G.add_edge('IP_192.168.1.100', 'domain.com', 
           relationship='resolves_to')

# Query graph
print(f"Number of nodes: {G.number_of_nodes()}")
print(f"Number of edges: {G.number_of_edges()}")
print(f"Neighbors of IP_192.168.1.100: {list(G.neighbors('IP_192.168.1.100'))}")

# Find shortest path
path = nx.shortest_path(G, 'IP_10.0.0.50', 'domain.com')
print(f"Path: {path}")

# Detect communities/clusters
communities = nx.community.greedy_modularity_communities(G.to_undirected())
```

**Graph Visualization with NetworkX**:

```python
# Basic visualization
plt.figure(figsize=(12, 8))
pos = nx.spring_layout(G, k=0.5, iterations=50)
nx.draw(G, pos, with_labels=True, node_color='lightblue', 
        node_size=1500, font_size=10, font_weight='bold',
        edge_color='gray', arrows=True, arrowsize=20)
plt.title("Network Link Analysis")
plt.savefig('network_graph.png', dpi=300, bbox_inches='tight')
plt.show()

# Advanced visualization with attributes
node_colors = ['red' if G.nodes[n].get('role') == 'server' 
               else 'blue' for n in G.nodes()]
node_sizes = [G.degree(n) * 500 for n in G.nodes()]

nx.draw(G, pos, node_color=node_colors, node_size=node_sizes,
        with_labels=True, edge_color='gray', arrows=True)
```

**PyVis** (Interactive network visualization):

```python
from pyvis.network import Network

# Create network
net = Network(height='750px', width='100%', directed=True)

# Add nodes
net.add_node('node1', label='Server', color='red', size=25)
net.add_node('node2', label='Client', color='blue', size=15)
net.add_node('node3', label='Domain', color='green', size=20)

# Add edges with labels
net.add_edge('node2', 'node1', title='HTTP Request', color='gray')
net.add_edge('node1', 'node3', title='DNS Query', color='orange')

# Physics settings
net.set_options("""
{
  "physics": {
    "enabled": true,
    "barnesHut": {
      "gravitationalConstant": -8000,
      "springLength": 250
    }
  }
}
""")

# Save interactive HTML
net.show('network.html')
```

### Domain and IP Link Analysis

**Passive DNS Analysis**:

```python
# Example structure for passive DNS data
import pandas as pd

pDNS_data = pd.DataFrame({
    'domain': ['malicious.com', 'malicious.com', 'phishing.net'],
    'ip_address': ['192.168.1.100', '10.0.0.50', '192.168.1.100'],
    'first_seen': ['2025-01-01', '2025-01-05', '2025-01-10'],
    'last_seen': ['2025-01-15', '2025-01-15', '2025-01-15']
})

# Find domains sharing IPs (infrastructure overlap)
ip_groups = pDNS_data.groupby('ip_address')['domain'].apply(list)
print("Domains sharing infrastructure:")
print(ip_groups[ip_groups.str.len() > 1])
```

**WHOIS Relationship Mapping**:

```python
# Example: Finding domains with shared registrant email
whois_data = pd.DataFrame({
    'domain': ['example1.com', 'example2.com', 'example3.com'],
    'registrant_email': ['actor@email.com', 'actor@email.com', 'other@email.com'],
    'registrar': ['RegistrarA', 'RegistrarA', 'RegistrarB']
})

# Group by registrant
actor_domains = whois_data.groupby('registrant_email')['domain'].apply(list)
print("Domains by registrant:")
print(actor_domains)
```

### Email and Communication Link Analysis

**Email Header Analysis**:

```python
# Parse email relationships
import email
from email import policy

def extract_email_links(email_file):
    with open(email_file, 'rb') as f:
        msg = email.message_from_binary_file(f, policy=policy.default)
    
    links = {
        'from': msg['From'],
        'to': msg['To'],
        'cc': msg.get('Cc', ''),
        'reply_to': msg.get('Reply-To', ''),
        'message_id': msg['Message-ID'],
        'in_reply_to': msg.get('In-Reply-To', ''),
        'references': msg.get('References', '')
    }
    
    return links

# Build email thread graph
G = nx.DiGraph()
# Add nodes for email addresses and message IDs
# Add edges based on reply relationships
```

**Social Network Analysis**:

```python
# Communication frequency matrix
import numpy as np

# Example: Who communicates with whom
comm_matrix = pd.DataFrame({
    'Alice': [0, 15, 3, 0],
    'Bob': [15, 0, 8, 2],
    'Charlie': [3, 8, 0, 12],
    'David': [0, 2, 12, 0]
}, index=['Alice', 'Bob', 'Charlie', 'David'])

# Convert to NetworkX graph
G = nx.from_pandas_adjacency(comm_matrix, create_using=nx.DiGraph())

# Find most connected individuals
most_connected = sorted(G.degree(), key=lambda x: x[1], reverse=True)
print(f"Most connected: {most_connected}")
```

### Clustering and Community Detection

**Louvain Method** (Community detection):

```python
import community.community_louvain as community_louvain

# Detect communities
G_undirected = G.to_undirected()
partition = community_louvain.best_partition(G_undirected)

# Visualize communities
pos = nx.spring_layout(G_undirected)
colors = [partition[node] for node in G_undirected.nodes()]
nx.draw(G_undirected, pos, node_color=colors, with_labels=True, cmap=plt.cm.Set3)
```

**K-Clique Communities**:

```python
# Find groups where every member is connected to k others
from networkx.algorithms import community

k_cliques = list(community.k_clique_communities(G_undirected, 3))
print(f"Found {len(k_cliques)} communities with k=3")
```

### Temporal Link Analysis

**Dynamic Networks** (Time-evolving graphs):

```python
# Create snapshots of network at different times
import datetime

def create_temporal_graph(edges_with_time):
    """
    edges_with_time: [(source, target, timestamp), ...]
    """
    graphs_by_time = {}
    
    for source, target, timestamp in edges_with_time:
        date = timestamp.date()
        if date not in graphs_by_time:
            graphs_by_time[date] = nx.DiGraph()
        graphs_by_time[date].add_edge(source, target)
    
    return graphs_by_time

# Example usage
edges = [
    ('A', 'B', datetime.datetime(2025, 1, 1)),
    ('B', 'C', datetime.datetime(2025, 1, 1)),
    ('A', 'C', datetime.datetime(2025, 1, 2)),
    ('C', 'D', datetime.datetime(2025, 1, 3))
]

temporal_graphs = create_temporal_graph(edges)

# Analyze evolution
for date, graph in sorted(temporal_graphs.items()):
    print(f"{date}: {graph.number_of_edges()} edges, density: {nx.density(graph):.3f}")
```

### Maltego-Style Transforms

**Entity Transformation Framework**:

```python
# Conceptual transform structure
class Transform:
    def __init__(self, entity_type, transform_name):
        self.entity_type = entity_type
        self.transform_name = transform_name
    
    def execute(self, entity_value):
        """Execute transform and return related entities"""
        raise NotImplementedError

# Example: Domain to IP transform
class DomainToIP(Transform):
    def __init__(self):
        super().__init__('Domain', 'ResolveToIP')
    
    def execute(self, domain):
        import socket
        try:
            ip_addresses = socket.gethostbyname_ex(domain)[2]
            return [{'type': 'IP', 'value': ip} for ip in ip_addresses]
        except socket.gaierror:
            return []

# Example: IP to ASN transform
class IPToASN(Transform):
    def __init__(self):
        super().__init__('IP', 'IPToASN')
    
    def execute(self, ip_address):
        # Would use API like ipinfo.io, whois, or Team Cymru
        # This is a conceptual example
        return [{'type': 'ASN', 'value': 'AS15169', 'organization': 'Google LLC'}]
```

### Graph Export Formats

**GEXF (Graph Exchange XML Format)**:

```python
# Export to Gephi-compatible format
nx.write_gexf(G, 'network.gexf')
```

**GraphML**:

```python
# Universal graph format
nx.write_graphml(G, 'network.graphml')
```

**JSON for D3.js**:

```python
from networkx.readwrite import json_graph

# Node-link format
data = json_graph.node_link_data(G)

import json
with open('network.json', 'w') as f:
    json.dump(data, f, indent=2)
```

## Timeline Creation

### Timeline Data Structures

**Event Components**:

- **Timestamp**: Precise time of occurrence (ISO 8601 format recommended)
- **Event Type**: Category or classification
- **Description**: Human-readable summary
- **Source**: Data provenance
- **Attributes**: Additional metadata (actor, location, artifact)

**Python Timeline Structure**:

```python
import pandas as pd
from datetime import datetime

# Create timeline dataframe
timeline = pd.DataFrame({
    'timestamp': pd.to_datetime([
        '2025-01-15 10:30:00',
        '2025-01-15 10:35:22',
        '2025-01-15 10:40:15',
        '2025-01-15 11:15:00'
    ]),
    'event_type': ['Login', 'File_Access', 'Network_Connection', 'Logout'],
    'description': [
        'User admin logged in from 192.168.1.50',
        'Accessed /etc/passwd',
        'Outbound connection to 203.0.113.10:4444',
        'User admin logged out'
    ],
    'source': ['auth.log', 'audit.log', 'firewall.log', 'auth.log'],
    'severity': ['info', 'warning', 'critical', 'info']
})

# Sort chronologically
timeline = timeline.sort_values('timestamp').reset_index(drop=True)
```

### Timeline Analysis Techniques

**Gap Analysis** (Identify suspicious time gaps):

```python
# Calculate time differences between events
timeline['time_delta'] = timeline['timestamp'].diff()

# Find large gaps (potential data deletion or system downtime)
large_gaps = timeline[timeline['time_delta'] > pd.Timedelta(minutes=30)]
print("Suspicious time gaps:")
print(large_gaps[['timestamp', 'time_delta', 'event_type']])
```

**Event Frequency Analysis**:

```python
# Events per time window
timeline.set_index('timestamp').resample('1H').size().plot(kind='bar')
plt.title('Events per Hour')
plt.ylabel('Event Count')
plt.xlabel('Time Period')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Identify burst activity
hourly_counts = timeline.set_index('timestamp').resample('1H').size()
threshold = hourly_counts.mean() + 2 * hourly_counts.std()
bursts = hourly_counts[hourly_counts > threshold]
print(f"Burst activity periods: {bursts}")
```

**Event Sequence Patterns**:

```python
# Find common event sequences
from collections import Counter

def extract_sequences(df, window_size=3):
    """Extract n-gram sequences of event types"""
    sequences = []
    events = df['event_type'].tolist()
    
    for i in range(len(events) - window_size + 1):
        sequence = tuple(events[i:i + window_size])
        sequences.append(sequence)
    
    return Counter(sequences)

sequences = extract_sequences(timeline, window_size=3)
print("Most common event sequences:")
for seq, count in sequences.most_common(5):
    print(f"{' -> '.join(seq)}: {count} times")
```

### Timeline Visualization Libraries

**Plotly Timeline**:

```python
import plotly.express as px

# Create interactive timeline
fig = px.timeline(timeline, 
                  x_start='timestamp', 
                  x_end='timestamp',  # For point events
                  y='event_type',
                  color='severity',
                  hover_data=['description', 'source'],
                  title='Security Event Timeline')

fig.update_yaxes(categoryorder='total ascending')
fig.show()
```

**Matplotlib Gantt-Style Timeline**:

```python
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

fig, ax = plt.subplots(figsize=(14, 6))

# Plot events
for idx, row in timeline.iterrows():
    color_map = {'info': 'blue', 'warning': 'orange', 'critical': 'red'}
    color = color_map.get(row['severity'], 'gray')
    
    ax.scatter(row['timestamp'], idx, c=color, s=100, alpha=0.7, 
               edgecolors='black', linewidth=1.5)
    ax.text(row['timestamp'], idx, f"  {row['event_type']}", 
            va='center', fontsize=9)

# Format x-axis
ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
ax.xaxis.set_major_locator(mdates.MinuteLocator(interval=10))
plt.xticks(rotation=45, ha='right')

ax.set_xlabel('Time')
ax.set_ylabel('Event Index')
ax.set_title('Event Timeline')
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('timeline.png', dpi=300)
plt.show()
```

**TimelineJS Format** (JSON export for web visualization):

```python
def export_timelinejs(timeline_df, output_file):
    """
    Export to TimelineJS 3 format
    Documentation: https://timeline.knightlab.com/docs/json-format.html
    """
    events = []
    
    for _, row in timeline_df.iterrows():
        event = {
            "start_date": {
                "year": row['timestamp'].year,
                "month": row['timestamp'].month,
                "day": row['timestamp'].day,
                "hour": row['timestamp'].hour,
                "minute": row['timestamp'].minute,
                "second": row['timestamp'].second
            },
            "text": {
                "headline": row['event_type'],
                "text": row['description']
            }
        }
        events.append(event)
    
    timeline_json = {
        "title": {
            "text": {
                "headline": "CTF Event Timeline",
                "text": "Analysis of security events"
            }
        },
        "events": events
    }
    
    import json
    with open(output_file, 'w') as f:
        json.dump(timeline_json, f, indent=2)
    
    return timeline_json

export_timelinejs(timeline, 'timeline.json')
```

### Log Aggregation and Timeline Synthesis

**Multi-Source Timeline Merge**:

```python
# Parse different log formats
def parse_apache_log(line):
    # Example: 192.168.1.1 - - [15/Jan/2025:10:30:00 +0000] "GET /index.html HTTP/1.1" 200
    import re
    pattern = r'(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) \S+" (\d+)'
    match = re.match(pattern, line)
    if match:
        return {
            'timestamp': pd.to_datetime(match.group(2), format='%d/%b/%Y:%H:%M:%S %z'),
            'ip': match.group(1),
            'method': match.group(3),
            'path': match.group(4),
            'status': int(match.group(5)),
            'source': 'apache'
        }
    return None

def parse_auth_log(line):
    # Example: Jan 15 10:30:00 server sshd[1234]: Accepted password for admin from 192.168.1.50
    import re
    pattern = r'(\w+ \d+ \d+:\d+:\d+) \S+ (\S+)\[\d+\]: (.+)'
    match = re.match(pattern, line)
    if match:
        timestamp_str = match.group(1)
        # Add current year if not present
        timestamp = pd.to_datetime(f"2025 {timestamp_str}", format='%Y %b %d %H:%M:%S')
        return {
            'timestamp': timestamp,
            'service': match.group(2),
            'message': match.group(3),
            'source': 'auth.log'
        }
    return None

# Merge timelines
def merge_timelines(*dataframes):
    """Merge multiple timeline dataframes"""
    merged = pd.concat(dataframes, ignore_index=True)
    merged = merged.sort_values('timestamp').reset_index(drop=True)
    return merged
```

### Super Timeline Creation (Plaso/log2timeline)

**Plaso Timeline Format**:

```bash
# Generate super timeline from disk image (command reference)
log2timeline.py --storage-file timeline.plaso image.dd

# Filter and output to CSV
psort.py -o l2tcsv -w timeline.csv timeline.plaso

# Filter by date range
psort.py -o l2tcsv -w filtered.csv timeline.plaso "date > '2025-01-01 00:00:00'"
```

**Processing Plaso CSV in Python**:

```python
# Read Plaso CSV output
plaso_timeline = pd.read_csv('timeline.csv')

# Standardize columns
plaso_timeline['timestamp'] = pd.to_datetime(plaso_timeline['datetime'])
plaso_timeline['event_type'] = plaso_timeline['source_short']
plaso_timeline['description'] = plaso_timeline['message']

# Filter for specific artifact types
file_system_events = plaso_timeline[plaso_timeline['source_short'].str.contains('FILE', na=False)]
registry_events = plaso_timeline[plaso_timeline['source_short'].str.contains('REG', na=False)]
```

### Timeline Correlation Windows

**Sliding Window Analysis**:

```python
def events_in_window(timeline_df, center_time, window_minutes=5):
    """Find all events within time window of a specific event"""
    window_start = center_time - pd.Timedelta(minutes=window_minutes)
    window_end = center_time + pd.Timedelta(minutes=window_minutes)
    
    mask = (timeline_df['timestamp'] >= window_start) & (timeline_df['timestamp'] <= window_end)
    return timeline_df[mask]

# Example: Find all events around a critical event
critical_event_time = timeline[timeline['severity'] == 'critical']['timestamp'].iloc[0]
related_events = events_in_window(timeline, critical_event_time, window_minutes=10)
print(f"Events within 10 minutes of critical event:")
print(related_events[['timestamp', 'event_type', 'description']])
```

## Relationship Mapping

### Entity-Relationship Models

**Graph Data Model**:

```python
# Define entity types and relationship types
class Entity:
    def __init__(self, entity_id, entity_type, attributes=None):
        self.id = entity_id
        self.type = entity_type
        self.attributes = attributes or {}
    
    def __repr__(self):
        return f"{self.type}({self.id})"

class Relationship:
    def __init__(self, source, target, rel_type, attributes=None):
        self.source = source
        self.target = target
        self.type = rel_type
        self.attributes = attributes or {}
    
    def __repr__(self):
        return f"{self.source} --[{self.type}]--> {self.target}"

# Example: Create entities and relationships
user = Entity('user_123', 'User', {'name': 'admin', 'role': 'administrator'})
server = Entity('srv_456', 'Server', {'ip': '192.168.1.100', 'os': 'Linux'})
file = Entity('file_789', 'File', {'path': '/etc/passwd', 'permissions': '644'})

login_rel = Relationship(user, server, 'LOGGED_IN', {'timestamp': '2025-01-15T10:30:00'})
access_rel = Relationship(user, file, 'ACCESSED', {'timestamp': '2025-01-15T10:35:00', 'operation': 'READ'})
```

### Property Graph Implementation

**NetworkX Property Graph**:

```python
G = nx.MultiDiGraph()  # Allow multiple edges between nodes

# Add nodes with properties
G.add_node('user_123', 
           label='User',
           name='admin',
           role='administrator',
           created='2024-01-01')

G.add_node('srv_456',
           label='Server',
           ip='192.168.1.100',
           os='Linux',
           hostname='webserver01')

G.add_node('file_789',
           label='File',
           path='/etc/passwd',
           permissions='644')

# Add edges with properties
G.add_edge('user_123', 'srv_456',
           key='login_1',
           relationship='LOGGED_IN',
           timestamp='2025-01-15T10:30:00',
           source_ip='192.168.1.50')

G.add_edge('user_123', 'file_789',
           key='access_1',
           relationship='ACCESSED',
           timestamp='2025-01-15T10:35:00',
           operation='READ')

# Query relationships
print("User connections:")
for neighbor in G.neighbors('user_123'):
    edge_data = G.get_edge_data('user_123', neighbor)
    for key, attrs in edge_data.items():
        print(f"  -> {neighbor}: {attrs['relationship']} at {attrs['timestamp']}")
```

### Advanced Relationship Queries

**Path Finding**:

```python
# Find all paths between two entities
def find_all_paths(graph, source, target, max_depth=3):
    """Find all simple paths up to max_depth"""
    paths = []
    for path in nx.all_simple_paths(graph, source, target, cutoff=max_depth):
        # Annotate path with relationship types
        annotated_path = []
        for i in range(len(path) - 1):
            edge_data = graph.get_edge_data(path[i], path[i+1])
            rel_types = [data.get('relationship', 'UNKNOWN') for data in edge_data.values()]
            annotated_path.append((path[i], path[i+1], rel_types))
        paths.append(annotated_path)
    return paths

# Example usage
paths = find_all_paths(G, 'user_123', 'file_789', max_depth=3)
for i, path in enumerate(paths, 1):
    print(f"Path {i}:")
    for source, target, rel_types in path:
        print(f"  {source} --{rel_types}--> {target}")
```

**Relationship Pattern Matching**:

```python
def find_pattern(graph, pattern):
    """
    Find subgraphs matching a pattern
    pattern: list of (node_type, relationship_type, node_type) tuples
    """
    matches = []
    
    # Example pattern: User -LOGGED_IN-> Server -HOSTS-> File
    # pattern = [('User', 'LOGGED_IN', 'Server'), ('Server', 'HOSTS', 'File')]
    
    for node in graph.nodes():
        if graph.nodes[node].get('label') == pattern[0][0]:
            # Start pattern matching from this node
            match = [node]
            current = node
            
            for i, (src_type, rel_type, tgt_type) in enumerate(pattern):
                found = False
                for neighbor in graph.neighbors(current):
                    edge_data = graph.get_edge_data(current, neighbor)
                    node_label = graph.nodes[neighbor].get('label')
                    
                    # Check if any edge matches the relationship type
                    for data in edge_data.values():
                        if (data.get('relationship') == rel_type and 
                            node_label == tgt_type):
                            match.append(neighbor)
                            current = neighbor
                            found = True
                            break
                    if found:
                        break
                
                if not found:
                    break
            
            if len(match) == len(pattern) + 1:
                matches.append(match)
    
    return matches
```

### Relationship Strength and Weighting

**Edge Weight Calculation**:

```python
def calculate_relationship_strength(graph, source, target):
    """
    Calculate strength based on multiple factors:
    - Frequency of interaction
    - Recency of interaction
    - Diversity of relationship types
    """
    edge_data = graph.get_edge_data(source, target)
    if not edge_data:
        return 0
    
    # Frequency: number of interactions
    frequency = len(edge_data)
    
    # Recency: weight recent interactions more
    timestamps = [pd.to_datetime(data.get('timestamp', '1970-01-01')) 
                  for data in edge_data.values()]
    now = pd.Timestamp.now()
    recency_weights = [1 / (1 + (now - ts).days) for ts in timestamps]
    recency_score = sum(recency_weights)
    
    # Diversity: number of unique relationship types
    rel_types = set(data.get('relationship', 'UNKNOWN') for data in edge_data.values())
    diversity = len(rel_types)
    
    # Combined score
    strength = (frequency * 0.4) + (recency_score * 0.4) + (diversity * 0.2)
    return strength

# Add strength as edge attribute
for u, v in G.edges():
    strength = calculate_relationship_strength(G, u, v)
    for key in G[u][v]:
        G[u][v][key]['strength'] = strength
```

**Weighted Graph Visualization**:

```python
# Visualize with edge width based on strength
pos = nx.spring_layout(G)

# Get edge strengths for width calculation
edges = G.edges()
strengths = [G[u][v][list(G[u][v].keys())[0]].get('strength', 1) for u, v in edges]
widths = [s * 2 for s in strengths]  # Scale for visibility

nx.draw_networkx_nodes(G, pos, node_color='lightblue', node_size=1500)
nx.draw_networkx_labels(G, pos, font_size=10)
nx.draw_networkx_edges(G, pos, width=widths, edge_color='gray', arrows=True, arrowsize=20)

plt.title("Relationship Strength Visualization")
plt.axis('off')
plt.tight_layout()
plt.show()
```

### Hierarchical Relationship Structures

**Tree Structures**:

```python
# File system hierarchy example
file_tree = nx.DiGraph()

file_tree.add_edge('/', '/home')
file_tree.add_edge('/', '/etc')
file_tree.add_edge('/home', '/home/user1')
file_tree.add_edge('/home', '/home/user2')
file_tree.add_edge('/home/user1', '/home/user1/documents')
file_tree.add_edge('/home/user1', '/home/user1/downloads')
file_tree.add_edge('/etc', '/etc/passwd')
file_tree.add_edge('/etc', '/etc/shadow')

# Visualize as tree
pos = nx.nx_agraph.graphviz_layout(file_tree, prog='dot')
nx.draw(file_tree, pos, with_labels=True, node_color='lightgreen', 
        node_size=2000, font_size=8, arrows=True)
plt.title("File System Hierarchy")
plt.show()

# Find all descendants of a node
def get_descendants(tree, node): 
	"""Get all nodes reachable from given node""" 
	return list(nx.descendants(tree, node))

# Find all ancestors
def get_ancestors(tree, node): 
	"""Get all nodes that can reach given node""" 
	return list(nx.ancestors(tree, node))

# Example queries
print(f"All files under /home: {get_descendants(file_tree, '/home')}") 
print(f"Path to /etc/passwd: {nx.shortest_path(file_tree, '/', '/etc/passwd')}")
````

**Organizational Hierarchies**:
```python
# Command structure / org chart
org_chart = nx.DiGraph()

org_chart.add_edge('CEO', 'CTO')
org_chart.add_edge('CEO', 'CFO')
org_chart.add_edge('CTO', 'Dev_Manager')
org_chart.add_edge('CTO', 'Ops_Manager')
org_chart.add_edge('Dev_Manager', 'Developer_1')
org_chart.add_edge('Dev_Manager', 'Developer_2')

# Calculate reporting levels
def get_level(tree, root, node):
    """Get hierarchical level from root"""
    try:
        path = nx.shortest_path(tree, root, node)
        return len(path) - 1
    except nx.NetworkXNoPath:
        return -1

for node in org_chart.nodes():
    level = get_level(org_chart, 'CEO', node)
    org_chart.nodes[node]['level'] = level
    print(f"{node}: Level {level}")
````

### Multi-Dimensional Relationships

**Relationship Type Classification**:

```python
# Multiple relationship dimensions
class RelationshipDimension:
    TECHNICAL = ['CONNECTS_TO', 'RESOLVES_TO', 'ROUTES_THROUGH', 'HOSTED_ON']
    TEMPORAL = ['PRECEDED_BY', 'FOLLOWED_BY', 'CONCURRENT_WITH']
    SOCIAL = ['COLLABORATED_WITH', 'REPORTED_TO', 'COMMUNICATED_WITH']
    LOGICAL = ['PART_OF', 'CONTAINS', 'DEPENDS_ON', 'DERIVED_FROM']
    ADVERSARIAL = ['ATTACKED', 'EXPLOITED', 'COMPROMISED', 'EXFILTRATED_FROM']

# Create multi-layer graph
def create_multilayer_graph(relationships):
    """Separate graph layers by relationship dimension"""
    layers = {
        'technical': nx.DiGraph(),
        'temporal': nx.DiGraph(),
        'social': nx.DiGraph(),
        'logical': nx.DiGraph(),
        'adversarial': nx.DiGraph()
    }
    
    for source, target, rel_type, attrs in relationships:
        # Determine layer
        if rel_type in RelationshipDimension.TECHNICAL:
            layers['technical'].add_edge(source, target, relationship=rel_type, **attrs)
        elif rel_type in RelationshipDimension.TEMPORAL:
            layers['temporal'].add_edge(source, target, relationship=rel_type, **attrs)
        elif rel_type in RelationshipDimension.SOCIAL:
            layers['social'].add_edge(source, target, relationship=rel_type, **attrs)
        elif rel_type in RelationshipDimension.LOGICAL:
            layers['logical'].add_edge(source, target, relationship=rel_type, **attrs)
        elif rel_type in RelationshipDimension.ADVERSARIAL:
            layers['adversarial'].add_edge(source, target, relationship=rel_type, **attrs)
    
    return layers

# Example relationships
relationships = [
    ('IP_10.0.0.1', 'IP_192.168.1.100', 'CONNECTS_TO', {'port': 443}),
    ('Event_1', 'Event_2', 'PRECEDED_BY', {'time_delta': '5s'}),
    ('User_A', 'User_B', 'COLLABORATED_WITH', {'project': 'CTF_2025'}),
    ('File_X', 'Archive_Y', 'PART_OF', {}),
    ('Attacker', 'Server_Z', 'COMPROMISED', {'method': 'SQLi'})
]

layers = create_multilayer_graph(relationships)

# Analyze specific dimension
print(f"Adversarial relationships: {layers['adversarial'].number_of_edges()}")
for u, v, data in layers['adversarial'].edges(data=True):
    print(f"  {u} --[{data['relationship']}]--> {v}")
```

### Bi-Directional Relationship Analysis

**Mutual Relationships**:

```python
def find_mutual_relationships(graph):
    """Find bidirectional edges (A->B and B->A exist)"""
    mutual = []
    
    for u, v in graph.edges():
        if graph.has_edge(v, u):
            # Avoid duplicates
            if (v, u) not in mutual:
                mutual.append((u, v))
    
    return mutual

# Analyze reciprocity
def calculate_reciprocity(graph):
    """
    Reciprocity: proportion of mutual connections
    """
    if graph.number_of_edges() == 0:
        return 0
    
    mutual_count = len(find_mutual_relationships(graph))
    total_edges = graph.number_of_edges()
    
    # Each mutual relationship counts as 2 edges
    reciprocity = (2 * mutual_count) / total_edges
    return reciprocity

print(f"Network reciprocity: {calculate_reciprocity(G):.2%}")
```

### Relationship Inference and Prediction

**Transitive Relationship Discovery**:

```python
def infer_transitive_relationships(graph, relationship_type):
    """
    If A-[rel]->B and B-[rel]->C, infer A-[rel]->C
    Example: If A trusts B and B trusts C, A may trust C
    """
    inferred = []
    
    for node in graph.nodes():
        # Find all nodes this node connects to with specified relationship
        targets = []
        for neighbor in graph.neighbors(node):
            edge_data = graph.get_edge_data(node, neighbor)
            for data in edge_data.values():
                if data.get('relationship') == relationship_type:
                    targets.append(neighbor)
        
        # Find second-order connections
        for target in targets:
            for second_target in graph.neighbors(target):
                edge_data = graph.get_edge_data(target, second_target)
                for data in edge_data.values():
                    if data.get('relationship') == relationship_type:
                        # Check if direct connection doesn't already exist
                        if not graph.has_edge(node, second_target):
                            inferred.append((node, second_target, relationship_type, 'inferred'))
    
    return inferred

# Example: Infer trust relationships
inferred_rels = infer_transitive_relationships(G, 'TRUSTS')
print(f"Inferred {len(inferred_rels)} transitive relationships")
```

**Link Prediction** (for missing relationships):

```python
from networkx.algorithms import link_prediction

def predict_links(graph, method='jaccard'):
    """
    Predict likely missing edges using various algorithms
    Methods: jaccard_coefficient, adamic_adar_index, preferential_attachment
    """
    if method == 'jaccard':
        preds = link_prediction.jaccard_coefficient(graph)
    elif method == 'adamic_adar':
        preds = link_prediction.adamic_adar_index(graph)
    elif method == 'preferential_attachment':
        preds = link_prediction.preferential_attachment(graph)
    else:
        raise ValueError(f"Unknown method: {method}")
    
    # Convert to list and sort by score
    predictions = [(u, v, score) for u, v, score in preds]
    predictions.sort(key=lambda x: x[2], reverse=True)
    
    return predictions

# Get top predictions
predictions = predict_links(G.to_undirected(), method='jaccard')
print("Top 5 predicted relationships:")
for u, v, score in predictions[:5]:
    print(f"  {u} <-> {v}: {score:.4f}")
```

## Graph Databases

### Graph Database Concepts

**Property Graph Model**:

- **Nodes**: Entities with labels and properties
- **Relationships**: Directed, typed connections with properties
- **Labels**: Categories/types for nodes (e.g., User, Server, File)
- **Properties**: Key-value pairs on nodes and relationships

**Graph vs Relational Databases**:

- Graph: Optimized for relationship traversal (constant time)
- Relational: Requires expensive JOINs for multi-hop queries
- Graph: Schema-flexible, easy to add relationship types
- Relational: Fixed schema, ALTER TABLE operations needed

### Neo4j Query Language (Cypher)

**Basic Cypher Syntax**:

```cypher
// Create nodes
CREATE (u:User {name: 'admin', id: 'user_123', role: 'administrator'})
CREATE (s:Server {hostname: 'webserver01', ip: '192.168.1.100'})
CREATE (f:File {path: '/etc/passwd', permissions: '644'})

// Create relationships
MATCH (u:User {id: 'user_123'}), (s:Server {hostname: 'webserver01'})
CREATE (u)-[:LOGGED_IN {timestamp: '2025-01-15T10:30:00', source_ip: '192.168.1.50'}]->(s)

MATCH (u:User {id: 'user_123'}), (f:File {path: '/etc/passwd'})
CREATE (u)-[:ACCESSED {timestamp: '2025-01-15T10:35:00', operation: 'READ'}]->(f)

// Query patterns
// Find all servers a user logged into
MATCH (u:User {name: 'admin'})-[:LOGGED_IN]->(s:Server)
RETURN u.name, s.hostname, s.ip

// Find files accessed by user on specific server
MATCH (u:User)-[:LOGGED_IN]->(s:Server),
      (u)-[:ACCESSED]->(f:File)
WHERE u.name = 'admin' AND s.hostname = 'webserver01'
RETURN f.path, f.permissions

// Multi-hop traversal: Find all entities within 3 hops
MATCH path = (u:User {name: 'admin'})-[*1..3]-(connected)
RETURN DISTINCT connected

// Path finding: Shortest path between entities
MATCH path = shortestPath(
  (u:User {name: 'admin'})-[*]-(f:File {path: '/etc/shadow'})
)
RETURN path

// Aggregation: Count relationships by type
MATCH (u:User {name: 'admin'})-[r]->(target)
RETURN type(r) as relationship_type, count(*) as count
ORDER BY count DESC

// Time-based filtering
MATCH (u:User)-[r:ACCESSED]->(f:File)
WHERE r.timestamp > '2025-01-15T10:00:00'
RETURN u.name, f.path, r.timestamp
ORDER BY r.timestamp

// Pattern matching: Find attack chains
MATCH (attacker:User)-[:EXPLOITED]->(vuln:Vulnerability)-[:EXISTS_IN]->(server:Server),
      (attacker)-[:ACCESSED]->(sensitive:File)
WHERE sensitive.classification = 'confidential'
RETURN attacker.name, vuln.cve, server.hostname, sensitive.path
```

**Advanced Cypher Queries**:

```cypher
// Detect privilege escalation paths
MATCH path = (low:User {privilege: 'low'})-[*1..5]->(high:User {privilege: 'admin'})
WHERE NONE(r IN relationships(path) WHERE type(r) = 'REPORTS_TO')
RETURN path

// Find isolated components (disconnected subgraphs)
CALL algo.unionFind.stream('User', 'COMMUNICATED_WITH')
YIELD nodeId, setId
RETURN setId, count(*) as component_size
ORDER BY component_size DESC

// Temporal path analysis: Events in sequence
MATCH path = (e1:Event)-[:PRECEDED_BY*]->(e2:Event)
WHERE e1.timestamp < e2.timestamp
RETURN path
ORDER BY e1.timestamp

// Centrality analysis (using GDS library)
CALL gds.pageRank.stream('myGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10

// Community detection
CALL gds.louvain.stream('myGraph')
YIELD nodeId, communityId
RETURN communityId, collect(gds.util.asNode(nodeId).name) as members
ORDER BY communityId
```

### Neo4j with Python (py2neo)

**Basic Operations**:

```python
from py2neo import Graph, Node, Relationship

# Connect to Neo4j
graph = Graph("bolt://localhost:7687", auth=("neo4j", "password"))

# Create nodes
user = Node("User", name="admin", id="user_123", role="administrator")
server = Node("Server", hostname="webserver01", ip="192.168.1.100")
file_node = Node("File", path="/etc/passwd", permissions="644")

# Create relationships
logged_in = Relationship(user, "LOGGED_IN", server, 
                         timestamp="2025-01-15T10:30:00",
                         source_ip="192.168.1.50")
accessed = Relationship(user, "ACCESSED", file_node,
                       timestamp="2025-01-15T10:35:00",
                       operation="READ")

# Add to database
graph.create(user)
graph.create(server)
graph.create(file_node)
graph.create(logged_in)
graph.create(accessed)

# Query with Cypher
query = """
MATCH (u:User {name: $username})-[r]->(target)
RETURN type(r) as relationship, target
"""
results = graph.run(query, username="admin")

for record in results:
    print(f"{record['relationship']}: {record['target']}")

# Bulk import from pandas
import pandas as pd

def bulk_import_nodes(graph, df, label):
    """Import nodes from DataFrame"""
    for _, row in df.iterrows():
        props = row.to_dict()
        node = Node(label, **props)
        graph.merge(node, label, "id")  # Merge on 'id' property

def bulk_import_relationships(graph, df, rel_type, 
                              source_label, target_label,
                              source_id_col, target_id_col):
    """Import relationships from DataFrame"""
    for _, row in df.iterrows():
        query = f"""
        MATCH (a:{source_label} {{id: $source_id}})
        MATCH (b:{target_label} {{id: $target_id}})
        MERGE (a)-[r:{rel_type}]->(b)
        SET r += $properties
        """
        props = row.to_dict()
        source_id = props.pop(source_id_col)
        target_id = props.pop(target_id_col)
        
        graph.run(query, 
                 source_id=source_id,
                 target_id=target_id,
                 properties=props)
```

**Complex Analysis Patterns**:

```python
def find_attack_paths(graph, entry_point, target):
    """Find all possible attack paths from entry to target"""
    query = """
    MATCH path = (entry {id: $entry_id})-[*1..10]->(target {id: $target_id})
    WHERE ALL(r IN relationships(path) WHERE 
              type(r) IN ['EXPLOITED', 'CONNECTED_TO', 'ACCESSED', 'ESCALATED_TO'])
    RETURN path,
           length(path) as path_length,
           [r IN relationships(path) | type(r)] as relationship_types
    ORDER BY path_length
    """
    
    results = graph.run(query, entry_id=entry_point, target_id=target)
    
    paths = []
    for record in results:
        paths.append({
            'path': record['path'],
            'length': record['path_length'],
            'types': record['relationship_types']
        })
    
    return paths

def detect_lateral_movement(graph, time_window_minutes=30):
    """Detect potential lateral movement patterns"""
    query = """
    MATCH (u:User)-[r1:LOGGED_IN]->(s1:Server),
          (u)-[r2:LOGGED_IN]->(s2:Server)
    WHERE s1 <> s2
      AND duration.between(
            datetime(r1.timestamp), 
            datetime(r2.timestamp)
          ).minutes < $window
    RETURN u.name as user,
           s1.hostname as from_server,
           s2.hostname as to_server,
           r1.timestamp as first_login,
           r2.timestamp as second_login
    ORDER BY r1.timestamp
    """
    
    results = graph.run(query, window=time_window_minutes)
    return [dict(record) for record in results]

def identify_data_exfiltration_chains(graph):
    """Find chains: User -> File Access -> Network Transfer"""
    query = """
    MATCH (u:User)-[:ACCESSED]->(f:File),
          (u)-[:CONNECTED_TO]->(ext:ExternalIP)
    WHERE f.classification = 'sensitive'
      AND datetime(f.access_time) < datetime(ext.connection_time)
      AND duration.between(
            datetime(f.access_time),
            datetime(ext.connection_time)
          ).minutes < 60
    RETURN u.name as user,
           f.path as file_accessed,
           f.access_time,
           ext.ip as external_ip,
           ext.connection_time,
           ext.bytes_transferred
    """
    
    results = graph.run(query)
    return [dict(record) for record in results]
```

### Alternative Graph Databases

**ArangoDB** (Multi-model: graph, document, key-value):

```python
from arango import ArangoClient

# Connect to ArangoDB
client = ArangoClient(hosts='http://localhost:8529')
db = client.db('ctf_analysis', username='root', password='password')

# Create graph
if not db.has_graph('security_graph'):
    graph = db.create_graph('security_graph')
    
    # Define edge definitions
    graph.create_edge_definition(
        edge_collection='logged_in',
        from_vertex_collections=['users'],
        to_vertex_collections=['servers']
    )

# Insert vertices
users = db.collection('users')
servers = db.collection('servers')

users.insert({'_key': 'user_123', 'name': 'admin', 'role': 'administrator'})
servers.insert({'_key': 'server_456', 'hostname': 'webserver01', 'ip': '192.168.1.100'})

# Insert edge
logged_in = db.collection('logged_in')
logged_in.insert({
    '_from': 'users/user_123',
    '_to': 'servers/server_456',
    'timestamp': '2025-01-15T10:30:00',
    'source_ip': '192.168.1.50'
})

# AQL query (ArangoDB Query Language)
aql_query = """
FOR u IN users
    FOR s IN 1..1 OUTBOUND u logged_in
    RETURN {user: u.name, server: s.hostname}
"""

cursor = db.aql.execute(aql_query)
results = [doc for doc in cursor]
```

**TinkerPop/Gremlin** (Graph traversal language):

```python
# Gremlin query examples (conceptual syntax)

# Find all servers user logged into
"""
g.V().hasLabel('User').has('name', 'admin')
  .out('LOGGED_IN').hasLabel('Server')
  .values('hostname')
"""

# Multi-hop traversal with filtering
"""
g.V().hasLabel('User').has('name', 'admin')
  .repeat(out().simplePath()).times(3)
  .hasLabel('File')
  .has('classification', 'confidential')
  .path()
"""

# Centrality: Find most connected nodes
"""
g.V().group()
  .by(label())
  .by(bothE().count())
  .unfold()
"""
```

**JanusGraph** (Distributed graph database):

- Backend storage: Cassandra, HBase, BerkeleyDB
- Index backend: Elasticsearch, Solr, Lucene
- Scales to billions of vertices and edges
- Supports Gremlin traversal language

### Graph Database Design Patterns

**Modeling Best Practices**:

1. **Specific Relationship Types**: Use descriptive relationship types instead of generic ones
    
    - Good: `LOGGED_IN`, `EXPLOITED`, `EXFILTRATED_FROM`
    - Bad: `RELATED_TO`, `CONNECTED`
2. **Denormalization**: Store frequently accessed properties on relationships
    
    ```cypher
    // Store timestamp on relationship rather than separate event node
    (u:User)-[:ACCESSED {timestamp: '...', operation: 'READ'}]->(f:File)
    ```
    
3. **Intermediate Nodes for Complex Relationships**:
    
    ```cypher
    // Instead of: (User)-[:SENT_EMAIL]->(User)
    // Use: (User)-[:SENT]->(Email)-[:RECEIVED_BY]->(User)
    ```
    
4. **Time-Tree Pattern** for temporal data:
    
    ```cypher
    // Organize events in hierarchical time structure
    (Event)-[:OCCURRED_ON]->(Day)-[:IN]->(Month)-[:IN]->(Year)
    ```
    
5. **Linked List Pattern** for sequential events:
    
    ```cypher
    (Event1)-[:NEXT {time_delta: '5s'}]->(Event2)-[:NEXT]->(Event3)
    ```
    

### Graph Database Performance Optimization

**Indexing**:

```cypher
// Create index on frequently queried properties
CREATE INDEX user_name_index FOR (u:User) ON (u.name)
CREATE INDEX file_path_index FOR (f:File) ON (f.path)

// Composite index
CREATE INDEX user_role_created FOR (u:User) ON (u.role, u.created_date)

// Full-text search index
CREATE FULLTEXT INDEX file_content_index FOR (f:File) ON EACH [f.content]
```

**Query Optimization**:

```cypher
// Use PROFILE to analyze query performance
PROFILE
MATCH (u:User {name: 'admin'})-[:LOGGED_IN]->(s:Server)
RETURN s.hostname

// Use WITH to pipeline results and reduce memory
MATCH (u:User)
WHERE u.last_login > datetime('2025-01-01')
WITH u
MATCH (u)-[:ACCESSED]->(f:File)
RETURN u.name, count(f) as file_count

// Limit early in query
MATCH (u:User)
WITH u LIMIT 100
MATCH (u)-[:LOGGED_IN]->(s:Server)
RETURN u, s
```

## Data Correlation Techniques

### Time-Based Correlation

**Event Window Correlation**:

```python
import pandas as pd
import numpy as np

def correlate_events_by_time(df1, df2, time_col='timestamp', 
                              window_seconds=300, key_cols=None):
    """
    Correlate events from two dataframes occurring within time window
    
    Args:
        df1, df2: DataFrames with events
        time_col: Column containing timestamps
        window_seconds: Time window for correlation
        key_cols: Additional columns that must match (e.g., 'user_id', 'ip')
    """
    # Ensure timestamps are datetime
    df1[time_col] = pd.to_datetime(df1[time_col])
    df2[time_col] = pd.to_datetime(df2[time_col])
    
    correlated = []
    
    for idx1, row1 in df1.iterrows():
        # Define time window
        window_start = row1[time_col] - pd.Timedelta(seconds=window_seconds)
        window_end = row1[time_col] + pd.Timedelta(seconds=window_seconds)
        
        # Filter df2 by time window
        mask = (df2[time_col] >= window_start) & (df2[time_col] <= window_end)
        candidates = df2[mask]
        
        # Additional key matching
        if key_cols:
            for col in key_cols:
                if col in row1 and col in df2.columns:
                    candidates = candidates[candidates[col] == row1[col]]
        
        # Record correlations
        for idx2, row2 in candidates.iterrows():
            time_diff = (row2[time_col] - row1[time_col]).total_seconds()
            
            correlated.append({
                'event1_idx': idx1,
                'event2_idx': idx2,
                'time_diff_seconds': time_diff,
                'event1_data': row1.to_dict(),
                'event2_data': row2.to_dict()
            })
    
    return pd.DataFrame(correlated)

# Example usage
auth_logs = pd.DataFrame({
    'timestamp': pd.to_datetime(['2025-01-15 10:30:00', '2025-01-15 10:35:00']),
    'user': ['admin', 'admin'],
    'event': ['login_success', 'privilege_escalation'],
    'source': ['auth.log', 'auth.log']
})

network_logs = pd.DataFrame({
    'timestamp': pd.to_datetime(['2025-01-15 10:31:00', '2025-01-15 10:36:00']),
    'user': ['admin', 'admin'],
    'event': ['outbound_connection', 'data_transfer'],
    'destination': ['203.0.113.10', '203.0.113.10'],
    'source': ['firewall.log', 'firewall.log']
})

correlations = correlate_events_by_time(auth_logs, network_logs, 
                                        window_seconds=300,
                                        key_cols=['user'])

print("Correlated events:")
print(correlations[['event1_data', 'event2_data', 'time_diff_seconds']])
```

**Sliding Window Aggregation**:

```python
def sliding_window_analysis(df, timestamp_col, window_size='5min', 
                            aggregation_col='event', agg_func='count'):
    """
    Analyze event patterns over sliding time windows
    """
    df[timestamp_col] = pd.to_datetime(df[timestamp_col])
    df = df.set_index(timestamp_col).sort_index()
    
    # Rolling window aggregation
    if agg_func == 'count':
        result = df[aggregation_col].rolling(window=window_size).count()
    elif agg_func == 'unique':
        result = df[aggregation_col].rolling(window=window_size).apply(
            lambda x: x.nunique(), raw=False
        )
    else:
        result = df[aggregation_col].rolling(window=window_size).agg(agg_func)
    
    return result.reset_index()

# Detect bursts of activity
event_counts = sliding_window_analysis(auth_logs, 'timestamp', 
                                       window_size='5min',
                                       aggregation_col='event',
                                       agg_func='count')

# Find anomalous windows (Z-score method)
mean_count = event_counts['event'].mean()
std_count = event_counts['event'].std()
event_counts['z_score'] = (event_counts['event'] - mean_count) / std_count

anomalous = event_counts[abs(event_counts['z_score']) > 2]
print(f"Anomalous time windows:\n{anomalous}")
```

### Statistical Correlation Methods

**Pearson Correlation** (Linear relationships):

```python
# Example: Correlate different metrics over time
metrics = pd.DataFrame({
    'timestamp': pd.date_range('2025-01-15', periods=100, freq='1min'),
    'cpu_usage': np.random.randn(100).cumsum() + 50,
    'network_traffic': np.random.randn(100).cumsum() + 1000,
    'disk_io': np.random.randn(100).cumsum() + 500
})

# Calculate correlation matrix
correlation_matrix = metrics[['cpu_usage', 'network_traffic', 'disk_io']].corr()
print("Correlation matrix:")
print(correlation_matrix)

# Visualize correlation
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(8, 6))
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', center=0,
            square=True, linewidths=1, cbar_kws={"shrink": 0.8})
plt.title('Metric Correlation Heatmap')
plt.tight_layout()
plt.show()

# Find strong correlations
def find_strong_correlations(corr_matrix, threshold=0.7):
    """Find variable pairs with correlation above threshold"""
    strong_corr = []
    
    for i in range(len(corr_matrix.columns)):
        for j in range(i+1, len(corr_matrix.columns)):
            corr_value = corr_matrix.iloc[i, j]
            if abs(corr_value) >= threshold:
                strong_corr.append({
                    'var1': corr_matrix.columns[i],
                    'var2': corr_matrix.columns[j],
                    'correlation': corr_value
                })
    
    return pd.DataFrame(strong_corr)

strong = find_strong_correlations(correlation_matrix, threshold=0.5)
print(f"\nStrong correlations:\n{strong}")
```

**Spearman Correlation** (Monotonic relationships):

```python
# Non-linear but monotonic relationships
spearman_corr = metrics[['cpu_usage', 'network_traffic', 'disk_io']].corr(method='spearman')
print("Spearman correlation:")
print(spearman_corr)
```

**Cross-Correlation** (Time-lagged relationships):

```python
from scipy import signal

def find_time_lag(series1, series2, max_lag=50):
    """
    Find optimal time lag between two time series
    Returns lag where correlation is maximized
    """
    # Normalize series
    s1 = (series1 - series1.mean()) / series1.std()
    s2 = (series2 - series2.mean()) / series2.std()
    
    # Compute cross-correlation
    correlation = signal.correlate(s1, s2, mode='same')
    lags = signal.correlation_lags(len(s1), len(s2), mode='same')
    
    # Find lag with maximum correlation
    max_corr_idx = np.argmax(np.abs(correlation))
    optimal_lag = lags[max_corr_idx]
    max_correlation = correlation[max_corr_idx] / len(s1)
    
    return optimal_lag, max_correlation

# Example: Find if CPU usage predicts network traffic
lag, corr = find_time_lag(metrics['cpu_usage'].values, 
                          metrics['network_traffic'].values)

print(f"Optimal lag: {lag} time units")
print(f"Correlation at lag: {corr:.3f}")

if lag > 0:
    print(f"CPU usage leads network traffic by {lag} units")
elif lag < 0:
    print(f"Network traffic leads CPU usage by {abs(lag)} units")
```

### Entity Resolution and Matching

**Fuzzy String Matching**:

```python
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

def fuzzy_entity_matching(entities1, entities2, threshold=80, method='token_sort'):
    """
    Match entities between two lists using fuzzy string matching
    
    Args:
        entities1, entities2: Lists of entity names/strings
        threshold: Minimum similarity score (0-100)
        method: 'ratio', 'partial_ratio', 'token_sort', 'token_set'
    """
    matches = []
    
    for entity1 in entities1:
        if method == 'ratio':
            scores = [(entity2, fuzz.ratio(entity1, entity2)) for entity2 in entities2]
        elif method == 'partial_ratio':
            scores = [(entity2, fuzz.partial_ratio(entity1, entity2)) for entity2 in entities2]
        elif method == 'token_sort':
            scores = [(entity2, fuzz.token_sort_ratio(entity1, entity2)) for entity2 in entities2]
        elif method == 'token_set':
            scores = [(entity2, fuzz.token_set_ratio(entity1, entity2)) for entity2 in entities2]
        
        # Find best match above threshold
        best_match = max(scores, key=lambda x: x[1])
        if best_match[1] >= threshold:
            matches.append({
                'entity1': entity1,
                'entity2': best_match[0],
                'similarity': best_match[1],
                'method': method
            })
    
    return pd.DataFrame(matches)

# Example: Match usernames across different systems
system1_users = ['admin', 'j.smith', 'administrator', 'root']
system2_users = ['Administrator', 'john.smith', 'admin_user', 'r00t']

matches = fuzzy_entity_matching(system1_users, system2_users, threshold=70)
print("Entity matches:")
print(matches)

# Batch matching with process.extract
def batch_fuzzy_match(query_list, choice_list, limit=3, threshold=80):
    """Get top N matches for each query"""
    results = []
    
    for query in query_list:
        matches = process.extract(query, choice_list, limit=limit)
        for match, score in matches:
            if score >= threshold:
                results.append({
                    'query': query,
                    'match': match,
                    'score': score
                })
    
    return pd.DataFrame(results)
```

**Levenshtein Distance** (Edit distance):

```python
import Levenshtein

def calculate_similarity_matrix(entities):
    """Calculate pairwise similarity between all entities"""
    n = len(entities)
    similarity_matrix = np.zeros((n, n))
    
    for i in range(n):
        for j in range(n):
            # Normalized Levenshtein distance (0-1 scale)
            distance = Levenshtein.distance(entities[i], entities[j])
            max_len = max(len(entities[i]), len(entities[j]))
            similarity = 1 - (distance / max_len) if max_len > 0 else 1
            similarity_matrix[i, j] = similarity
    
    return pd.DataFrame(similarity_matrix, 
                       index=entities, 
                       columns=entities)

# Example: Find similar domain names (potential typosquatting)
domains = ['google.com', 'gooogle.com', 'g00gle.com', 'facebook.com', 'facebo0k.com']
similarity = calculate_similarity_matrix(domains)

print("Domain similarity matrix:")
print(similarity.round(3))

# Find suspicious similar domains
def find_similar_pairs(similarity_matrix, threshold=0.8, exclude_diagonal=True):
    """Find pairs with high similarity"""
    pairs = []
    
    for i in range(len(similarity_matrix)):
        for j in range(i+1 if exclude_diagonal else i, len(similarity_matrix)):
            sim_value = similarity_matrix.iloc[i, j]
            if sim_value >= threshold and (not exclude_diagonal or i != j):
                pairs.append({
                    'entity1': similarity_matrix.index[i],
                    'entity2': similarity_matrix.columns[j],
                    'similarity': sim_value
                })
    
    return pd.DataFrame(pairs).sort_values('similarity', ascending=False)

suspicious_domains = find_similar_pairs(similarity, threshold=0.7)
print("\nSuspicious similar domains:")
print(suspicious_domains)
```

**Record Linkage** (Dedupe library):

```python
# Example using dedupe library for entity resolution
import dedupe

def dedupe_entities(data_dict, fields):
    """
    Deduplicate entities using machine learning
    
    Args:
        data_dict: {id: {field1: value1, field2: value2, ...}, ...}
        fields: List of field definitions for dedupe
    
    Example fields:
    [
        {'field': 'name', 'type': 'String'},
        {'field': 'email', 'type': 'String'},
        {'field': 'address', 'type': 'String', 'has missing': True}
    ]
    """
    # [Unverified] This is a conceptual example
    # Actual implementation requires training with labeled examples
    
    # Initialize deduper
    deduper = dedupe.Dedupe(fields)
    
    # Training phase would go here (requires manual labeling)
    # deduper.prepare_training(data_dict)
    # dedupe.console_label(deduper)
    # deduper.train()
    
    # Find duplicates
    # clustered_dupes = deduper.partition(data_dict, threshold=0.5)
    
    # Return cluster mapping
    # return clustered_dupes
    
    pass  # Placeholder for conceptual example
```

### IP and Network Correlation

**IP Geolocation Correlation**:

```python
def correlate_ips_by_location(ip_list, geolocation_data):
    """
    Group IPs by geographic proximity
    
    Args:
        ip_list: List of IP addresses
        geolocation_data: Dict mapping IPs to {'lat': float, 'lon': float, 'country': str, ...}
    """
    from math import radians, cos, sin, asin, sqrt
    
    def haversine_distance(lat1, lon1, lat2, lon2):
        """Calculate distance between two coordinates in km"""
        lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        km = 6371 * c
        return km
    
    # Calculate pairwise distances
    correlations = []
    
    for i, ip1 in enumerate(ip_list):
        if ip1 not in geolocation_data:
            continue
        
        for ip2 in ip_list[i+1:]:
            if ip2 not in geolocation_data:
                continue
            
            geo1 = geolocation_data[ip1]
            geo2 = geolocation_data[ip2]
            
            distance = haversine_distance(
                geo1['lat'], geo1['lon'],
                geo2['lat'], geo2['lon']
            )
            
            correlations.append({
                'ip1': ip1,
                'ip2': ip2,
                'distance_km': distance,
                'same_country': geo1['country'] == geo2['country'],
                'country1': geo1['country'],
                'country2': geo2['country']
            })
    
    return pd.DataFrame(correlations)

# Example usage
geo_data = {
    '192.0.2.1': {'lat': 40.7128, 'lon': -74.0060, 'country': 'US', 'city': 'New York'},
    '192.0.2.2': {'lat': 40.7589, 'lon': -73.9851, 'country': 'US', 'city': 'New York'},
    '203.0.113.1': {'lat': 51.5074, 'lon': -0.1278, 'country': 'GB', 'city': 'London'}
}

ips = ['192.0.2.1', '192.0.2.2', '203.0.113.1']
ip_correlations = correlate_ips_by_location(ips, geo_data)

print("IP geographic correlations:")
print(ip_correlations)

# Find IPs in close proximity (potential shared infrastructure)
close_proximity = ip_correlations[ip_correlations['distance_km'] < 50]
print(f"\nIPs within 50km: {len(close_proximity)}")
```

**ASN and Infrastructure Correlation**:

```python
def correlate_by_infrastructure(ip_data):
    """
    Correlate IPs by shared infrastructure (ASN, hosting provider)
    
    Args:
        ip_data: DataFrame with columns: ip, asn, org, hosting_provider
    """
    # Group by ASN
    asn_groups = ip_data.groupby('asn').agg({
        'ip': list,
        'org': 'first',
        'hosting_provider': 'first'
    }).reset_index()
    
    # Find ASNs with multiple IPs (shared infrastructure)
    shared_infrastructure = asn_groups[asn_groups['ip'].apply(len) > 1]
    
    return shared_infrastructure

# Example
ip_infrastructure = pd.DataFrame({
    'ip': ['192.0.2.1', '192.0.2.2', '192.0.2.3', '203.0.113.1'],
    'asn': ['AS15169', 'AS15169', 'AS8075', 'AS8075'],
    'org': ['Google LLC', 'Google LLC', 'Microsoft', 'Microsoft'],
    'hosting_provider': ['Google Cloud', 'Google Cloud', 'Azure', 'Azure']
})

shared = correlate_by_infrastructure(ip_infrastructure)
print("Shared infrastructure:")
for _, row in shared.iterrows():
    print(f"ASN {row['asn']} ({row['org']}): {len(row['ip'])} IPs")
    print(f"  IPs: {row['ip']}")
```

### Content-Based Correlation

**Hash-Based Correlation** (File/artifact matching):

```python
import hashlib

def calculate_file_hashes(file_path):
    """Calculate multiple hashes for a file"""
    hash_md5 = hashlib.md5()
    hash_sha1 = hashlib.sha1()
    hash_sha256 = hashlib.sha256()
    
    with open(file_path, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hash_md5.update(chunk)
            hash_sha1.update(chunk)
            hash_sha256.update(chunk)
    
    return {
        'md5': hash_md5.hexdigest(),
        'sha1': hash_sha1.hexdigest(),
        'sha256': hash_sha256.hexdigest()
    }

def find_duplicate_files(file_hash_dict):
    """
    Find duplicate files based on hash matching
    
    Args:
        file_hash_dict: {filename: {'md5': '...', 'sha1': '...', 'sha256': '...'}}
    """
    # Group by hash values
    hash_groups = {}
    
    for filename, hashes in file_hash_dict.items():
        sha256 = hashes['sha256']
        if sha256 not in hash_groups:
            hash_groups[sha256] = []
        hash_groups[sha256].append(filename)
    
    # Find duplicates
    duplicates = {hash_val: files for hash_val, files in hash_groups.items() if len(files) > 1}
    
    return duplicates

# Example usage
file_hashes = {
    'file1.txt': {'md5': 'abc123', 'sha1': 'def456', 'sha256': 'hash1'},
    'file2.txt': {'md5': 'abc123', 'sha1': 'def456', 'sha256': 'hash1'},
    'file3.txt': {'md5': 'xyz789', 'sha1': 'uvw012', 'sha256': 'hash2'}
}

dupes = find_duplicate_files(file_hashes)
print("Duplicate files:")
for hash_val, files in dupes.items():
    print(f"SHA256 {hash_val}: {files}")
```

**Fuzzy Hashing** (ssdeep for similar content):

```python
# Conceptual example using ssdeep for fuzzy hashing
import ssdeep

def calculate_fuzzy_hash(file_path):
    """Calculate ssdeep fuzzy hash"""
    with open(file_path, 'rb') as f:
        return ssdeep.hash(f.read())

def compare_fuzzy_hashes(hash1, hash2):
    """Compare two fuzzy hashes (returns 0-100 similarity score)"""
    return ssdeep.compare(hash1, hash2)

def find_similar_files(file_fuzzy_hashes, threshold=50):
    """
    Find files with similar content using fuzzy hashing
    
    Args:
        file_fuzzy_hashes: {filename: fuzzy_hash_string}
        threshold: Minimum similarity score (0-100)
    """
    similar_pairs = []
    files = list(file_fuzzy_hashes.keys())
    
    for i in range(len(files)):
        for j in range(i+1, len(files)):
            file1, file2 = files[i], files[j]
            similarity = compare_fuzzy_hashes(
                file_fuzzy_hashes[file1],
                file_fuzzy_hashes[file2]
            )
            
            if similarity >= threshold:
                similar_pairs.append({
                    'file1': file1,
                    'file2': file2,
                    'similarity': similarity
                })
    
    return pd.DataFrame(similar_pairs)
```

**Text Similarity** (Document correlation):

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def correlate_text_documents(documents_dict, min_similarity=0.3):
    """
    Find similar documents using TF-IDF and cosine similarity
    
    Args:
        documents_dict: {doc_id: text_content}
        min_similarity: Minimum cosine similarity (0-1)
    """
    doc_ids = list(documents_dict.keys())
    texts = list(documents_dict.values())
    
    # Create TF-IDF vectors
    vectorizer = TfidfVectorizer(stop_words='english')
    tfidf_matrix = vectorizer.fit_transform(texts)
    
    # Calculate cosine similarity
    similarity_matrix = cosine_similarity(tfidf_matrix)
    
    # Find similar pairs
    similar_pairs = []
    for i in range(len(doc_ids)):
        for j in range(i+1, len(doc_ids)):
            sim_score = similarity_matrix[i, j]
            if sim_score >= min_similarity:
                similar_pairs.append({
                    'doc1': doc_ids[i],
                    'doc2': doc_ids[j],
                    'similarity': sim_score
                })
    
    return pd.DataFrame(similar_pairs).sort_values('similarity', ascending=False)

# Example: Find similar phishing emails
emails = {
    'email1': 'Your account has been compromised. Click here to verify.',
    'email2': 'Your account security is at risk. Please verify immediately.',
    'email3': 'Meeting scheduled for tomorrow at 2pm.',
    'email4': 'Account verification required. Follow this link.'
}

similar_emails = correlate_text_documents(emails, min_similarity=0.3)
print("Similar email content:")
print(similar_emails)
```

### Behavioral Correlation

**User Behavior Profiling**:

```python
def create_user_behavior_profile(user_activity_df):
    """
    Create behavioral profile for anomaly detection
    
    Args:
        user_activity_df: DataFrame with columns: user_id, timestamp, action, resource
    """
    profiles = {}
    
    for user_id in user_activity_df['user_id'].unique():
        user_data = user_activity_df[user_activity_df['user_id'] == user_id]
        
        profile = {
            'user_id': user_id,
            'total_actions': len(user_data),
            'unique_actions': user_data['action'].nunique(),
            'unique_resources': user_data['resource'].nunique(),
            'action_distribution': user_data['action'].value_counts().to_dict(),
            'most_common_action': user_data['action'].mode()[0] if len(user_data) > 0 else None,
            'activity_hours': user_data['timestamp'].dt.hour.value_counts().to_dict(),
            'activity_days': user_data['timestamp'].dt.dayofweek.value_counts().to_dict()
        }
        
        profiles[user_id] = profile
    
    return profiles

def compare_user_profiles(profile1, profile2):
    """Calculate similarity between two user behavior profiles"""
    # Action distribution similarity (cosine similarity)
    actions1 = profile1['action_distribution']
    actions2 = profile2['action_distribution']
    
    all_actions = set(actions1.keys()) | set(actions2.keys())
    vec1 = np.array([actions1.get(a, 0) for a in all_actions])
    vec2 = np.array([actions2.get(a, 0) for a in all_actions])
    
    # Normalize
    vec1 = vec1 / np.linalg.norm(vec1) if np.linalg.norm(vec1) > 0 else vec1
    vec2 = vec2 / np.linalg.norm(vec2) if np.linalg.norm(vec2) > 0 else vec2
    
    similarity = np.dot(vec1, vec2)
    
    return similarity

# Example: Find users with similar behavior (potential account sharing)
activity_data = pd.DataFrame({
    'user_id': ['user1', 'user1', 'user2', 'user2', 'user3'],
    'timestamp': pd.to_datetime([
        '2025-01-15 09:00:00',
        '2025-01-15 09:15:00',
        '2025-01-15 09:05:00',
        '2025-01-15 09:20:00',
        '2025-01-15 14:00:00'
    ]),
    'action': ['login', 'file_access', 'login', 'file_access', 'login'],
    'resource': ['server1', '/etc/passwd', 'server1', '/etc/passwd', 'server2']
})

profiles = create_user_behavior_profile(activity_data)

# Compare all user pairs
for user1 in profiles:
    for user2 in profiles:
        if user1 < user2:  # Avoid duplicates
            similarity = compare_user_profiles(profiles[user1], profiles[user2])
            print(f"{user1} vs {user2}: {similarity:.3f} similarity")
```

**Sequence Pattern Mining**:

```python
def find_frequent_sequences(event_sequences, min_support=2):
    """
    Find frequently occurring event sequences
    
    Args:
        event_sequences: List of event sequences (lists)
        min_support: Minimum number of occurrences
    """
    from collections import Counter
    
    # Find all subsequences
    def get_subsequences(sequence, length):
        return [tuple(sequence[i:i+length]) for i in range(len(sequence) - length + 1)]
    
    # Count occurrences of each subsequence
    subsequence_counts = Counter()
    
    for sequence in event_sequences:
        for length in range(2, len(sequence) + 1):
            for subseq in get_subsequences(sequence, length):
                subsequence_counts[subseq] += 1
    
    # Filter by minimum support
    frequent = {seq: count for seq, count in subsequence_counts.items() 
                if count >= min_support}
    
    return sorted(frequent.items(), key=lambda x: x[1], reverse=True)

# Example: Find common attack patterns
attack_sequences = [
    ['recon', 'exploit', 'privilege_escalation', 'lateral_movement', 'exfiltration'],
    ['recon', 'exploit', 'persistence', 'exfiltration'],
    ['recon', 'exploit', 'privilege_escalation', 'persistence'],
    ['scan', 'exploit', 'privilege_escalation', 'lateral_movement']
]

frequent_patterns = find_frequent_sequences(attack_sequences, min_support=2)

print("Frequent attack patterns:")
for pattern, count in frequent_patterns[:10]:
    print(f"{' -> '.join(pattern)}: {count} times")
```

### Multi-Source Data Fusion

**Evidence Accumulation**:

```python
def accumulate_evidence(observations, weights=None):
    """
    Combine evidence from multiple sources using weighted voting
    
    Args:
        observations: List of dicts with 'source', 'entity', 'score', 'confidence'
        weights: Dict mapping source names to weight values
    """
    if weights is None:
        weights = {}
    
    # Group observations by entity
    entity_scores = {}
    
    for obs in observations:
        entity = obs['entity']
        source = obs['source']
        score = obs['score']
        confidence = obs.get('confidence', 1.0)
        weight = weights.get(source, 1.0)
        
        if entity not in entity_scores:
            entity_scores[entity] = {
                'total_score': 0,
                'total_weight': 0,
                'observations': []
            }
        
        weighted_score = score * confidence * weight
        entity_scores[entity]['total_score'] += weighted_score
        entity_scores[entity]['total_weight'] += weight * confidence
        entity_scores[entity]['observations'].append(obs)
    
    # Calculate final scores
    results = []
    for entity, data in entity_scores.items():
        final_score = data['total_score'] / data['total_weight'] if data['total_weight'] > 0 else 0
        results.append({
            'entity': entity,
            'final_score': final_score,
            'num_sources': len(data['observations']),
            'observations': data['observations']
        })
    
    return sorted(results, key=lambda x: x['final_score'], reverse=True)

# Example: Combine threat intelligence from multiple sources
observations = [
    {'source': 'VirusTotal', 'entity': '203.0.113.10', 'score': 0.9, 'confidence': 0.8},
    {'source': 'AbuseIPDB', 'entity': '203.0.113.10', 'score': 0.85, 'confidence': 0.9},
    {'source': 'Shodan', 'entity': '203.0.113.10', 'score': 0.7, 'confidence': 0.6},
    {'source': 'VirusTotal', 'entity': '198.51.100.5', 'score': 0.3, 'confidence': 0.8}
]

# Weight sources differently based on reliability
source_weights = {
    'VirusTotal': 1.0,
    'AbuseIPDB': 0.9,
    'Shodan': 0.7
}

threat_scores = accumulate_evidence(observations, weights=source_weights)

print("Aggregated threat scores:")
for result in threat_scores:
    print(f"{result['entity']}: {result['final_score']:.3f} (from {result['num_sources']} sources)")
```

**Confidence Scoring**:

```python
def calculate_confidence_score(indicators):
    """
    Calculate overall confidence based on multiple indicators
    
    Factors:
    - Number of confirming sources
    - Source reliability
    - Data freshness
    - Consistency across sources
    """
    if not indicators:
        return 0.0
    
    # Factor 1: Number of sources (more is better, diminishing returns)
    num_sources = len(indicators)
    source_score = min(1.0, num_sources / 5.0)  # Normalize to 5 sources
    
    # Factor 2: Average reliability
    reliabilities = [ind.get('reliability', 0.5) for ind in indicators]
    reliability_score = np.mean(reliabilities)
    
    # Factor 3: Freshness (exponential decay)
    current_time = pd.Timestamp.now()
    freshness_scores = []
    for ind in indicators:
        if 'timestamp' in ind:
            age_days = (current_time - pd.to_datetime(ind['timestamp'])).days
            freshness = np.exp(-age_days / 30.0)  # 30-day half-life
            freshness_scores.append(freshness)
    freshness_score = np.mean(freshness_scores) if freshness_scores else 0.5
    
    # Factor 4: Consistency (standard deviation of values)
    values = [ind.get('value', 0.5) for ind in indicators]
    consistency_score = 1.0 - min(1.0, np.std(values))
    
    # Weighted combination
    confidence = (
        source_score * 0.25 +
        reliability_score * 0.30 +
        freshness_score * 0.25 +
        consistency_score * 0.20
    )
    
    return confidence

# Example usage
threat_indicators = [
    {'source': 'TI_Feed_1', 'value': 0.9, 'reliability': 0.9, 'timestamp': '2025-01-15'},
    {'source': 'TI_Feed_2', 'value': 0.85, 'reliability': 0.8, 'timestamp': '2025-01-14'},
    {'source': 'TI_Feed_3', 'value': 0.88, 'reliability': 0.7, 'timestamp': '2025-01-10'}
]

confidence = calculate_confidence_score(threat_indicators)
print(f"Overall confidence: {confidence:.2%}")
```

### Visualization of Correlations

**Correlation Network Graph**:

```python
def visualize_correlation_network(correlation_data, threshold=0.5):
    """
    Visualize correlations as a network graph
    
    Args:
        correlation_data: List of dicts with 'entity1', 'entity2', 'correlation'
        threshold: Minimum correlation to display
    """
    G = nx.Graph()
    
    for item in correlation_data:
        if item['correlation'] >= threshold:
            G.add_edge(
                item['entity1'],
                item['entity2'],
                weight=item['correlation']
            )
    
    # Layout
    pos = nx.spring_layout(G, k=0.5, iterations=50)
    
    # Draw
    plt.figure(figsize=(12, 8))
    
    # Nodes
    nx.draw_networkx_nodes(G, pos, node_color='lightblue', 
                          node_size=1000, alpha=0.9)
    
    # Edges with varying width
    edges = G.edges()
    weights = [G[u][v]['weight'] for u, v in edges]
    nx.draw_networkx_edges(G, pos, width=[w*3 for w in weights], 
                          alpha=0.5, edge_color='gray')
    
    # Labels
    nx.draw_networkx_labels(G, pos, font_size=10, font_weight='bold')
    
    # Edge labels (correlation values)
    edge_labels = {(u, v): f"{G[u][v]['weight']:.2f}" for u, v in edges}
    nx.draw_networkx_edge_labels(G, pos, edge_labels, font_size=8)
    
    plt.title('Correlation Network')
    plt.axis('off')
    plt.tight_layout()
    plt.show()
```

**Temporal Correlation Heatmap**:

```python
def visualize_temporal_correlations(time_series_data, window='1H'):
    """
    Create heatmap showing correlations over time windows
    
    Args:
        time_series_data: DataFrame with timestamp index and metric columns
        window: Time window for rolling correlation
    """
    # Calculate rolling correlations
    correlations_over_time = []
    
    for start in pd.date_range(time_series_data.index.min(), 
                               time_series_data.index.max(), 
                               freq=window):
        end = start + pd.Timedelta(window)
        window_data = time_series_data[start:end]
        
        if len(window_data) > 1:
            corr_matrix = window_data.corr()
            corr_matrix['timestamp'] = start
            correlations_over_time.append(corr_matrix)
    
    # Visualize
    if correlations_over_time:
        # Example: Plot correlation between two specific metrics over time
        metric1, metric2 = time_series_data.columns[0], time_series_data.columns[1]
        
        timestamps = [corr['timestamp'] for corr in correlations_over_time]
        corr_values = [corr.loc[metric1, metric2] for corr in correlations_over_time]
        
        plt.figure(figsize=(12, 6))
        plt.plot(timestamps, corr_values, marker='o', linewidth=2)
        plt.xlabel('Time')
        plt.ylabel(f'Correlation: {metric1} vs {metric2}')
        plt.title('Temporal Correlation Evolution')
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.show()
```

**Important Related Topics**:

- Machine Learning for anomaly detection (isolation forests, autoencoders)
- Bayesian networks for probabilistic reasoning
- Time series forecasting (ARIMA, Prophet, LSTM)
- Natural Language Processing for log analysis
- Stream processing frameworks (Apache Kafka, Flink) for real-time correlation
- SIEM correlation rules and alert tuning
- Attack graph generation and analysis
- Causal inference techniques
- Data provenance tracking
- Feature engineering for CTF data
- Interactive visualization frameworks (Plotly Dash, Streamlit, Grafana)

---

# Specialized OSINT

## Aviation Tracking

### Core Platforms and Data Sources

**FlightRadar24** (flightradar24.com)

- Real-time ADS-B data aggregation from ground stations worldwide
- Basic search: Enter callsign, registration, or flight number in search bar
- Aircraft details: Click on aircraft icon → Access registration, type, altitude, speed, heading, route
- Historical playback: Premium feature allows reviewing past flights
- Filters: Aircraft type, airline, altitude range, airport origin/destination
- API access: `https://data-live.flightradar24.com/zones/fcgi/feed.js?bounds=LAT1,LAT2,LON1,LON2`

**ADS-B Exchange** (adsbexchange.com)

- Unfiltered feed (shows military/private aircraft often blocked elsewhere)
- More comprehensive coverage for sensitive flights
- JSON API: `https://globe.adsbexchange.com/data/aircraft.json`
- Historical database access via tar1090 interface
- Hex code lookup: Direct aircraft identification via ICAO 24-bit address

**OpenSky Network** (opensky-network.org)

- Academic research platform with historical data
- Python API: `from opensky_api import OpenSkyApi; api = OpenSkyApi()`
- Query by bounding box: `api.get_states(bbox=(lat_min, lat_max, lon_min, lon_max))`
- Historical track retrieval: `api.get_track_by_aircraft(icao24, time)`
- Free tier: 400 credits per day (1 credit per request)

### Aircraft Identification Techniques

**Registration Number Decoding**

- Format varies by country: N12345 (USA), G-ABCD (UK), D-EFGH (Germany)
- Lookup databases: FAA N-Number registry, UK CAA G-INFO
- FAA query: `https://registry.faa.gov/aircraftinquiry/Search/NNumberInquiry`
- Returns: Owner name, address, aircraft model, manufacturing year

**ICAO 24-bit Address (Mode S Hex)**

- Unique identifier: 6-character hexadecimal code (e.g., A12B34)
- Persistent across registration changes
- Correlation tool: `icao24.py` scripts for bulk lookups
- Cross-reference: ADS-B Exchange hex database

**Callsign Analysis**

- Commercial: AAL123 (American Airlines Flight 123)
- Private: N12345 (using registration as callsign)
- Military: EVAL01, RCH### (US Air Force)
- Pattern recognition: Blocked callsigns often indicate sensitive operations

### Tracking Methodologies

**Live Monitoring Setup**

```bash
# Using dump1090 with RTL-SDR
sudo apt-get install rtl-sdr dump1090-mutability
dump1090 --interactive --net --gain 49.6

# Feed to local tar1090 map
http://localhost:8080/
```

**Historical Flight Path Reconstruction**

- FlightAware: Enter registration → Flight History tab
- Time range analysis: Identify pattern-of-life, regular routes
- Geofencing alerts: Set up notifications for specific tail numbers entering defined areas
- KML export: Download track data for mapping in Google Earth

**Aircraft Ownership Investigation**

- Corporate aircraft: FAA registry shows trust/LLC ownership
- Cross-reference with:
    - SEC filings (corporate executives)
    - State business registries (LLC formation docs)
    - Property records (hangar leases)
- Example query: Search FAA owner name → Check LinkedIn for company affiliations

### Advanced Techniques

**ADS-B Signal Analysis**

- RTL-SDR reception: 1090 MHz frequency
- Range: ~250 nautical miles at altitude
- Ground station setup:

```bash
rtl_test -t  # Test dongle
rtl_adsb | acarsdec -r 0 131.550  # Decode ADS-B
```

**ACARS Monitoring** [Inference]

- Aircraft Communications Addressing and Reporting System
- VHF frequencies: 131.550 MHz (primary), 130.025, 131.725
- Software: `acarsdec`, `jaero` (for SATCOM ACARS)
- Reveals: Flight plans, maintenance messages, position reports

**Correlating Multiple Data Sources**

- Cross-reference: FlightRadar24 + ADS-B Exchange + FAA registry
- Detect discrepancies: Blocked aircraft on one platform but visible on another
- Pattern analysis: Repeated flights between specific airports
- Timing correlation: Match aircraft movements with known events

**Squawk Code Intelligence**

- 7700: Emergency
- 7600: Radio failure
- 7500: Hijacking
- Discrete codes: Assigned by ATC, can indicate aircraft mission/type

## Maritime Tracking

### Vessel Tracking Platforms

**MarineTraffic** (marinetraffic.com)

- AIS data aggregation from terrestrial and satellite receivers
- Free tier: Live positions, basic vessel details
- Vessel search: Name, IMO number, MMSI, callsign
- API endpoint: `https://services.marinetraffic.com/api/exportvessel/v:8/[API_KEY]/protocol:json/shipid:[SHIPID]`
- Historical tracks: Premium feature, shows past 7 days to 1 year

**VesselFinder** (vesselfinder.com)

- Similar coverage to MarineTraffic
- Port arrival/departure schedules
- Voyage history by vessel or port
- Fleet tracking: Monitor multiple vessels simultaneously

**AIS Hub** (aishub.net)

- Community-sourced AIS data
- Free data feeds: Real-time XML/JSON streams
- API access: `http://data.aishub.net/ws.php?username=USER&format=1&output=json&compress=0`
- Returns: MMSI, latitude, longitude, speed, course, vessel type

**CruiseMapper** (cruisemapper.com)

- Specialized for cruise ships and ferries
- Current position and itineraries
- Deck plans and vessel specifications

### Vessel Identification

**MMSI (Maritime Mobile Service Identity)**

- 9-digit identifier: MID (Maritime Identification Digits) + vessel ID
- Format: 123456789
- First 3 digits: Country code (338 = USA, 235 = UK, 211 = Germany)
- Lookup: ITU MID list, MarineTraffic MMSI search

**IMO Number**

- Permanent 7-digit hull identifier (Lloyd's Register)
- Remains constant even if vessel changes name/flag
- Format: IMO 1234567
- Database: IHS Markit Sea-web, Equasis (equasis.org)

**Call Signs**

- Radio identification: Varies by flag state
- Used in VHF communications
- Lookup via FCC database (US vessels) or ITU database

### AIS Data Analysis

**AIS Message Types**

- Type 1/2/3: Position reports (Class A, every 2-10 seconds)
- Type 5: Static voyage data (destination, ETA, cargo type)
- Type 18: Position report (Class B, every 30 seconds)
- Type 24: Class B static data

**Decoding AIS Payloads** [Inference]

```python
# Using pyais library
from pyais import decode

msg = "!AIVDM,1,1,,A,13aEOK?P00PD2wVMdLDRhgvL289?,0*26"
decoded = decode(msg)
print(decoded.mmsi, decoded.lat, decoded.lon, decoded.speed)
```

**AIS Gaps and Spoofing**

- Dark activity: Vessels turning off AIS transponders
- Detection: Compare last known position with expected position based on speed/course
- Spoofing indicators: Impossible speed changes, location jumps, multiple vessels with same MMSI
- Tools: Sentinel-1 SAR imagery to detect vessels in AIS gaps

### Vessel Investigation Techniques

**Ownership and Registration**

- Flag state registries: Panama, Liberia, Marshall Islands (flags of convenience)
- Query Equasis: Enter IMO number → Owner, manager, flag history
- Corporate structure: Check company registries in vessel's country of registration
- Beneficial ownership: Often obscured through shell companies

**Port Call History**

```bash
# MarineTraffic API for port calls
curl "https://services.marinetraffic.com/api/portcalls/v:1/[API_KEY]/portid:1/period:daily/from:2024-01-01"
```

**Cargo Tracking**

- Bill of Lading (BOL) databases: Import Genius, Panjiva
- Container tracking: Track by container number across multiple shipping lines
- Manifest data: US imports searchable via USA Trade Online

**Satellite AIS (S-AIS)**

- Coverage beyond terrestrial receiver range (~40 nm)
- Providers: ORBCOMM, Spire, Unseenlabs
- Access: Often requires subscription or partnership

### Advanced Maritime OSINT

**Radio Monitoring**

- VHF Marine Band: 156-162 MHz
- Receive vessel communications using SDR

```bash
rtl_fm -f 156.8M -s 12k -g 50 - | play -r 12k -t raw -e s -b 16 -c 1 -V1 -
```

- Channel 16: International distress/calling
- AIS channels: 161.975 MHz (87B), 162.025 MHz (88B)

**Behavioral Pattern Analysis**

- Identify suspicious patterns: Frequent flag changes, AIS off in EEZ, loitering near infrastructure
- Speed analysis: Slow speeds may indicate fishing, drifting, or rendezvous
- Proximity alerts: Set geofences around sensitive areas (pipelines, cables, ports)

**Dark Fleet Detection** [Inference]

- Sanctions evasion: Ship-to-ship transfers, AIS manipulation
- Methods: Correlate SAR imagery with AIS data, identify missing vessels
- Tools: Windward, Pole Star, Spire Maritime

## Satellite Imagery Analysis

### Imagery Sources

**Free/Open Access Platforms**

**Sentinel Hub** (sentinel-hub.com)

- ESA Copernicus Sentinel satellites
- Sentinel-2: 10m resolution optical (13-day revisit)
- Sentinel-1: C-band SAR, all-weather (6-day revisit)
- API access: EO Browser or custom scripts

```python
# Sentinel Hub API example
from sentinelhub import SHConfig, SentinelHubRequest, DataCollection, MimeType, BBox, CRS

bbox = BBox(bbox=[lon_min, lat_min, lon_max, lat_max], crs=CRS.WGS84)
request = SentinelHubRequest(
    data_folder='output',
    evalscript='...',  # Custom rendering script
    input_data=[SentinelHubRequest.input_data(DataCollection.SENTINEL2_L2A)],
    responses=[SentinelHubRequest.output_response('default', MimeType.TIFF)],
    bbox=bbox,
    size=[512, 512],
    config=config
)
```

**Google Earth / Google Earth Pro**

- Historical imagery: Timeline slider (varies by location, some areas have decades of coverage)
- Resolution: Varies 15cm-15m depending on source
- Measurement tools: Path, polygon area calculation
- KML/KMZ import: Overlay custom data

**Zoom.earth**

- Near real-time satellite imagery (GOES, Himawari-8)
- Weather overlays: Clouds, precipitation
- Time slider: Review past 24-48 hours
- Free, no registration

**NASA Worldview** (worldview.earthdata.nasa.gov)

- MODIS, VIIRS satellite data
- Daily global coverage
- Overlays: Fires, aerosols, sea surface temperature
- Download: GeoTIFF export

**Copernicus Open Access Hub** (scihub.copernicus.eu)

- Direct download of Sentinel data products
- API query:

```bash
# Search for Sentinel-2 imagery
wget --user=USERNAME --password=PASSWORD \
"https://apihub.copernicus.eu/apihub/search?q=footprint:\"Intersects(POLYGON((lon lat, ...)))\" \
AND platformname:Sentinel-2 AND cloudcoverpercentage:[0 TO 10]"
```

**USGS Earth Explorer** (earthexplorer.usgs.gov)

- Landsat archive (1972-present)
- 30m resolution multispectral
- Free registration, bulk download

### Commercial High-Resolution Imagery

**Paid/On-Demand Platforms** [Unverified pricing/access terms]

**Planet Labs** (planet.com)

- Daily global coverage at 3-5m resolution (PlanetScope)
- SkySat: 50cm resolution, daily revisit for specific areas
- Tasking: Request imagery of specific coordinates
- API: Programmatic search and download

**Maxar SecureWatch** (securewatch.digitalglobe.com)

- 30-50cm resolution (WorldView satellites)
- Historical archive: 2000-present
- Subscription model: Credits for imagery downloads

**Airbus Intelligence** (intelligence-airbusds.com)

- Pleiades: 50cm resolution
- SPOT: 1.5m resolution
- Tasking and archive access

### Image Analysis Techniques

**Change Detection**

- Compare imagery from different dates
- Identify: New construction, demolished buildings, vehicle movements
- Method: Layer two images in QGIS/ArcGIS, adjust transparency
- Automated tools: `cv2.absdiff()` in OpenCV for pixel-level change

**Geolocation/Geotagging**

- Identify location from image features
- Techniques:
    1. Landmark identification (buildings, monuments)
    2. Sun angle calculation (shadows)
    3. Vegetation patterns
    4. Infrastructure matching (roads, power lines)
- Tools: Google Earth, OpenStreetMap, GeoGuessr techniques

**Multispectral Analysis**

- Near-infrared (NIR) bands: Vegetation health, false-color composites
- NDVI (Normalized Difference Vegetation Index): `(NIR - Red) / (NIR + Red)`
- Water detection: NDWI, using SWIR bands
- Example in QGIS: Raster calculator with Sentinel-2 bands

**Shadow Analysis**

- Determine time of day: Shadow length and direction
- Sun position calculators: SunCalc.org, NOAA solar calculator
- Estimate object height: `height = shadow_length × tan(sun_altitude)`

**SAR Imagery Interpretation**

- Bright returns: Metal structures, buildings, ships
- Dark returns: Water, smooth surfaces
- Speckle noise: Inherent to SAR, requires filtering
- Coherence change detection: Identify ground deformation (earthquakes, landslides)

### Specialized Analysis

**Building/Structure Measurement**

- Google Earth Pro ruler tool: 3D building height measurement
- Shadow-based height calculation
- Comparison with known reference objects (cars ~1.5m height, shipping containers 2.4m height)

**Facility Identification**

- Military installations: Revetments, radar domes, bunkers
- Industrial: Cooling towers, smokestacks, storage tanks
- OSINT databases: Wikimapia, OpenStreetMap military tags

**Activity Indicators**

- Vehicle density changes
- New trackways or disturbance
- Heat signatures (thermal bands on Landsat)
- Light pollution (VIIRS nighttime lights)

**Temporal Analysis**

- Sentinel-2 time series: Track vegetation cycles, construction progress
- Animation creation: Export frames, compile with `ffmpeg`

```bash
ffmpeg -framerate 2 -pattern_type glob -i '*.png' -c:v libx264 output.mp4
```

### Tools and Software

**QGIS** (Open Source)

- Import: GeoTIFF, KML, Shapefiles
- Plugins: Semi-Automatic Classification, QuickMapServices
- Georeferencing: Align ungeoreferenced imagery
- Analysis: Raster calculator, zonal statistics

**SNAP (Sentinel Application Platform)**

- ESA toolbox for Sentinel data processing
- SAR processing: Calibration, terrain correction, speckle filtering
- Graph processing: Automate workflows

```bash
# Command-line processing
gpt graph.xml -Pinput=S1A_*.zip -Poutput=output.tif
```

**Google Earth Engine** (Code Editor)

- Cloud-based processing of satellite imagery
- JavaScript API:

```javascript
var s2 = ee.ImageCollection('COPERNICUS/S2_SR')
  .filterBounds(geometry)
  .filterDate('2024-01-01', '2024-12-31')
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20));
var median = s2.median();
Map.addLayer(median, {bands: ['B4', 'B3', 'B2'], max: 3000}, 'Sentinel-2');
```

**OpenCV (Python)** [Inference - requires programming knowledge]

```python
import cv2
import numpy as np

img1 = cv2.imread('before.jpg', 0)
img2 = cv2.imread('after.jpg', 0)
diff = cv2.absdiff(img1, img2)
_, thresh = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)
cv2.imwrite('changes.jpg', thresh)
```

## Radio Frequency Analysis

### SDR Hardware

**RTL-SDR (RTL2832U)**

- Frequency range: 24-1766 MHz (with gaps)
- Sampling rate: Up to 2.4 MS/s
- Cost: ~$25-40
- Setup:

```bash
sudo apt-get install rtl-sdr
rtl_test -t  # Test functionality
rtl_eeprom   # Check device info
```

**HackRF One**

- Frequency: 1 MHz - 6 GHz
- Half-duplex transceiver
- 20 MS/s sampling
- TX capable [Warning: Requires appropriate licensing to transmit]

**Airspy**

- Better dynamic range than RTL-SDR
- Airspy Mini: 24-1800 MHz
- Airspy HF+: 0.5 kHz - 31 MHz, 60-260 MHz

**LimeSDR**

- Full-duplex
- Frequency: 100 kHz - 3.8 GHz
- FPGA-based, highly flexible

### Software Tools

**GQRX** (Receiver)

- GUI-based SDR software (Linux/Mac)
- Demodulation: AM, FM, SSB, CW
- Waterfall display: Visualize spectrum activity
- Installation:

```bash
sudo apt-get install gqrx-sdr
gqrx
```

**SDR#** (SDRSharp - Windows)

- Popular Windows SDR receiver
- Plugins: DSD+ (digital voice), frequency scanner
- Download: airspy.com/download

**Cubic SDR** (Cross-platform)

- Multi-receiver support
- Bookmark management for frequency tracking
- Recording capability

**GNU Radio**

- Visual programming for SDR
- Flowgraph-based DSP
- Companion: Create complex signal processing chains

```python
# Example flowgraph (saved as .grc)
# RTL-SDR Source → Low Pass Filter → WBFM Receive → Audio Sink
```

**URH (Universal Radio Hacker)**

- Protocol reverse engineering
- Record signals, analyze modulation
- Auto-detect signal parameters
- Replay attacks (for authorized testing)

```bash
pip3 install urh
urh
```

### Signal Identification

**Frequency Databases**

- Sigidwiki.com: Comprehensive signal database with waterfall examples
- Radioreference.com: Frequency allocations by region
- FCC frequency allocation chart: 0-300 GHz

**Common Signal Types**

- FM Broadcast: 88-108 MHz (200 kHz bandwidth)
- Aviation VHF: 118-137 MHz (AM, 25 kHz spacing)
- Marine VHF: 156-162 MHz (FM, 25 kHz spacing)
- ISM Bands: 433 MHz, 868 MHz (EU), 915 MHz (US)
- LTE/5G: Various bands (700 MHz, 1800 MHz, 2600 MHz)

**Modulation Recognition** [Inference]

- Visual patterns in FFT/waterfall:
    - AM: Single carrier
    - FM: Varying bandwidth
    - FSK: Discrete frequency shifts
    - PSK: Constant amplitude, phase changes
- Automatic classification: `inspectrum`, GNU Radio's modulation recognizers

### Signal Interception

**ADS-B (Aircraft)**

```bash
dump1090 --interactive --net
# Open http://localhost:8080 for map
```

**AIS (Maritime)**

```bash
rtl_ais -n
# Decodes AIS messages
```

**ACARS (Aircraft Communications)**

```bash
acarsdec -r 0 131.550 131.725 130.025
# Decode ACARS messages from common frequencies
```

**Weather Satellites (APT)**

- NOAA 15/18/19: 137 MHz band
- Receive script:

```bash
# Record audio
rtl_fm -f 137.62M -s 60k -g 50 -p 55 - | sox -t raw -r 60k -c 1 -b 16 -e s - output.wav rate 11025

# Decode with WXtoImg or noaa-apt
noaa-apt output.wav -o image.png
```

**Pagers (POCSAG)**

```bash
rtl_fm -f 157.5M -s 22050 | multimon-ng -t raw -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -
# Common pager frequencies: 137-174 MHz
```

### Direction Finding (DF) [Inference - requires multiple receivers]

**Doppler-based DF**

- Rotating antenna array
- Phase difference calculations
- Tools: KrakenSDR (5-tuner coherent SDR)

**Triangulation**

- Multiple fixed receivers
- Time difference of arrival (TDOA)
- Software: TDoA server implementations for KiwiSDR network

**Signal Strength-based**

- Handheld yagi antenna + SDR
- Move toward stronger signal
- Crude but effective for short-range

### Spectrum Analysis

**Wideband Scanning**

```bash
# RTL-SDR scanner
rtl_power -f 100M:1000M:1M -g 50 -i 10 output.csv
# Scan 100-1000 MHz in 1 MHz steps, 10-second integration
```

**FFT Analysis**

- Inspect signal bandwidth and shape
- Identify interference patterns
- Tools: GQRX FFT display, Inspectrum for recorded IQ files

**Recording IQ Data**

```bash
rtl_sdr -f 433.92M -s 2.4M -g 40 output.iq
# Records raw IQ samples for later analysis
```

**Replay Analysis with Inspectrum**

```bash
inspectrum output.iq
# GUI tool: Zoom into signals, measure symbol rate, extract data
```

### Digital Modes

**DMR/P25/NXDN (Digital Voice)** [Inference]

- Software: DSD+ (Windows), SDRTrunk
- Requires discriminator tap or UDP audio from SDR#
- Frequencies: Public safety (700/800 MHz), amateur radio (144/440 MHz)

**LoRa**

- ISM bands: 433/868/915 MHz
- Decoder: `gr-lora` GNU Radio module
- Monitor: LoRa packets with RTL-SDR + GNU Radio flowgraph

**Satellite Communication**

- Inmarsat: L-band (1525-1660 MHz)
- Iridium: L-band (~1616-1626 MHz)
- Decoder: `iridium-toolkit`, `jaero` for Inmarsat

### Legal and Safety Considerations

**Regulatory Compliance**

- Receiving: Generally legal in most jurisdictions
- Transmitting: Requires appropriate licensing (amateur radio, commercial)
- Encrypted communications: Legal to receive, illegal to decrypt (varies by jurisdiction)
- Privacy: Intercepting cellular communications is illegal in many countries

**Antenna Safety**

- RF exposure limits: FCC/ICNIRP guidelines
- High-gain antennas: Risk of elevated RF exposure when transmitting
- Avoid transmitting near pacemakers or other medical devices

## Financial Intelligence (FININT)

### Open Source Financial Data

**Company Financial Records**

**SEC EDGAR** (sec.gov/edgar)

- US public company filings
- Key forms:
    - 10-K: Annual report
    - 10-Q: Quarterly report
    - 8-K: Material events
    - DEF 14A: Proxy statement (executive compensation, board)
    - Form 4: Insider trading
- API access: `https://data.sec.gov/submissions/CIK##########.json`

```python
import requests
cik = '0000789019'  # Microsoft
headers = {'User-Agent': 'Your Name your@email.com'}
r = requests.get(f'https://data.sec.gov/submissions/CIK{cik}.json', headers=headers)
data = r.json()
```

**OpenCorporates** (opencorporates.com)

- Global company registry database
- Free API (rate-limited):

```bash
curl "https://api.opencorporates.com/v0.4/companies/search?q=company_name"
```

- Returns: Jurisdiction, incorporation date, registered address, officers

**Companies House (UK)** (companieshouse.gov.uk)

- UK company filings
- Free API:

```bash
curl -u YOUR_API_KEY: "https://api.company-information.service.gov.uk/company/00000006"
```

- Access: Annual accounts, confirmation statements, officer details

**Trade Registers (EU)**

- Germany: Handelsregister (handelsregister.de)
- France: Infogreffe (infogreffe.fr)
- Often require paid access for detailed records

### Beneficial Ownership

**Offshore Leaks Database** (ICIJ)

- Panama Papers, Paradise Papers, Pandora Papers
- Search: offshoreleaks.icij.org
- Entity connections: Beneficial owners, intermediaries, offshore entities

**OpenOwnership Register** (register.openownership.org)

- Aggregates beneficial ownership data from multiple jurisdictions
- Searchable database
- API: `https://api.openownership.org/v0.2/entities/[ENTITY_ID]`

**Corporate Structures**

- Layered ownership: Parent companies, subsidiaries, affiliates
- Mapping tools: Draw.io, Maltego (commercial)
- SEC Schedule 13D/13G: Disclose beneficial ownership >5%

### Financial Sanctions and Watchlists

**OFAC SDN List** (US Treasury)

- Specially Designated Nationals
- Download: `https://www.treasury.gov/ofac/downloads/sdn.xml`
- Parse XML for entity matching

```python
import xml.etree.ElementTree as ET
tree = ET.parse('sdn.xml')
for entry in tree.findall('.//sdnEntry'):
    name = entry.find('firstName').text if entry.find('firstName') is not None else ''
    print(name)
```

**UN Security Council Sanctions**

- Consolidated list: un.org/securitycouncil/sanctions/1267
- JSON/XML formats available

**EU Sanctions Map**

- sanctionsmap.eu
- Searchable by person, entity, or sanction regime

**Interpol Red Notices**

- Public database: interpol.int/en/How-we-work/Notices/Red-Notices
- Wanted individuals (not all notices are public)

### Cryptocurrency Intelligence

**Blockchain Explorers**

- Bitcoin: blockchain.com/explorer, blockchair.com
- Ethereum: etherscan.io
- Query by address, transaction hash, block number
- Example: `https://blockchain.info/address/[BTC_ADDRESS]?format=json`

**On-Chain Analysis** [Inference]

- Cluster analysis: Group addresses by common ownership
- Transaction graph: Map fund flows
- Tools: Chainalysis (commercial), Elliptic (commercial)
- Open source: `BlockSci` (requires technical setup)

**Mixing/Tumbling Detection**

- Patterns: CoinJoin transactions, multi-input/multi-output
- Services: Wasabi Wallet, Samourai Whirlpool
- Taint analysis: Trace funds through mixers

**Exchange Identification**

- Known wallet addresses: Bitfinex, Binance, Coinbase (published by exchanges)
- Clustering: Identify exchange cold storage
- Leakbase: Crystalblockchain.com (free tier)

### Asset Tracking

**Real Estate Records**

- County assessor databases (US): Property ownership, sales history, tax assessments
- Zillow, Redfin: Estimated values, transaction history
- UK Land Registry: Search by address or owner (paid)

```bash
# Example: NYC property lookup (ACRIS)
https://a836-acris.nyc.gov/DS/DocumentSearch/Index
```

**Aircraft/Vessel Registration**

- FAA N-Number registry: Owner names and addresses (see Aviation section)
- USCG vessel documentation: uscgboating.org
- Cross-reference with corporate ownership

**Intellectual Property**

- USPTO Patent/Trademark databases (uspto.gov)
- WIPO Global Brand Database (wipo.int/branddb)
- Identify corporate activities, R&D focus

### Financial News and Alerts

**Google Finance / Yahoo Finance**

- Real-time stock quotes, corporate actions
- Historical price data API:

```python
import yfinance as yf
msft = yf.Ticker("MSFT")
hist = msft.history(period="1y")
```

**SEC RSS Feeds**

- Company-specific: `https://data.sec.gov/cik-lookup-data.txt`
- Setup alerts for new filings via RSS reader

**Financial Times / Wall Street Journal**

- Investigative reporting on corporate malfeasance
- Archive access (often paywalled)

### Court Records and Litigation

**PACER** (US Federal Courts)

- pacer.uscourts.gov
- Paid access (~$0.10/page)
- Search: Case number, party name, nature of suit
- Types: Civil, criminal, bankruptcy

**State Court Records**

- Varies by jurisdiction: Often county clerk websites
- Example: California - courts.ca.gov

**International Court Records** [Unverified - access varies significantly]

- UK Courts and Tribunals Judiciary: judiciary.uk
- ECLI (European Case Law Identifier): Search EU court decisions

### Trade Data

**USA Trade Online** (usatrade.census.gov)

- US import/export data by company
- Paid subscription
- HS codes: Harmonized System commodity classification

**Import Genius / Panjiva**

- Commercial platforms aggregating Bills of Lading
- Free tier: Limited searches per month
- Identify supply chains, trade partners

**Zauba** (India - partially restricted)

- zauba.com
- Indian import/export data (previously free, now limited)

### Investigative Techniques

**Follow the Money**

1. Identify initial entity (company, individual)
2. Map corporate structure (subsidiaries, parent companies)
3. Locate financial filings (SEC, Companies House)
4. Identify officers and beneficial owners
5. Cross-reference against sanctions lists, adverse media
6. Track asset ownership (real estate, vessels, aircraft)
7. Monitor cryptocurrency addresses if relevant

**Timeline Construction**

- Chronological mapping of financial events
- Correlate with news, regulatory filings, insider trades
- Identify suspicious patterns (timing of transactions)

**Network Analysis**

- Maltego transforms for OSINT (commercial, some free)
- Manual network diagrams: Officers sitting on multiple boards
- Shared addresses, phone numbers, email domains

**Due Diligence Checklist** [Inference]

- Verify company registration and good standing
- Review financial statements (revenue trends, debt levels)
- Check officer backgrounds (LinkedIn, past companies)
- Screen against sanctions and watchlists
- Review litigation history
- Assess reputational risk (adverse media search)

---

**Important Subtopics for Further Study:**

- Advanced SAR interferometry (InSAR) for ground deformation analysis
- SATCOM intelligence (Inmarsat/Iridium decoding)
- Cryptocurrency privacy coins (Monero/Zcash) analysis limitations
- Corporate intelligence databases (Dun & Bradstreet, LexisNexis)
- Advanced RF techniques (spectrum waterfall analysis

## Advanced RF Techniques

### Spectrum Waterfall Analysis

**Understanding Waterfall Displays**

- Y-axis: Time (older signals at top, newer at bottom)
- X-axis: Frequency range
- Color: Signal strength (blue=weak, red=strong)
- Bandwidth measurement: Identify signal width in Hz/kHz
- Duty cycle observation: Intermittent vs continuous transmissions

**Pattern Recognition**

- Continuous carrier: Beacon, jamming, or idle transmitter
- Pulsed signals: Radar, data bursts
- Frequency hopping: Rapid horizontal lines across spectrum (Bluetooth, military comms)
- OFDM patterns: Dense vertical bars (LTE, Wi-Fi, DVB-T)
- Chirp signals: Diagonal lines (radar, LoRa)

**Anomaly Detection**

- Unexpected transmissions in licensed bands
- Signal strength variations: Identify mobile transmitters
- Interference patterns: Harmonics, intermodulation products
- Time correlation: Match RF activity with known events

**Recording and Playback**

```bash
# Record waterfall data with rtl_power
rtl_power -f 88M:108M:1k -g 50 -i 1 -e 1h output.csv

# Process with heatmap.py
python heatmap.py --low -40 --high 0 output.csv output.png
```

### Advanced Signal Decoding

**POCSAG/FLEX Pager Decoding**

```bash
# Install multimon-ng
sudo apt-get install multimon-ng

# Decode POCSAG
rtl_fm -f 157.4625M -s 22050 -g 50 | multimon-ng -t raw -a POCSAG512 -a POCSAG1200 -f alpha -
```

- Common frequencies: 137-174 MHz (VHF), 929-932 MHz (UHF)
- Extract: Capcode (address), message content, timestamp
- Privacy note: Medical, emergency services often use pagers - respect privacy

**APRS (Automatic Packet Reporting System)**

- Amateur radio position reporting: 144.39 MHz (North America)

```bash
rtl_fm -f 144.39M -s 22050 | direwolf -n 1 -r 22050 -b 16 -
# Outputs decoded position reports
```

- Data includes: Callsign, GPS coordinates, altitude, speed
- Online aggregators: aprs.fi (map view of all APRS stations)

**Mode S / ADS-B Deep Dive**

- Message types beyond position:
    - BDS 4,0: Selected vertical intention
    - BDS 5,0: Track and turn report
    - BDS 6,0: Heading and speed report
- Decode with pyModeS:

```python
from pyModeS import adsb

msg = "8D406B902015A678D4D220AA4BDA"
if adsb.typecode(msg) >= 9 and adsb.typecode(msg) <= 18:
    lat, lon = adsb.position(msg, msg, time0, time1)
    alt = adsb.altitude(msg)
```

**ACARS Message Analysis**

- Label codes indicate message type:
    - H1: Position report
    - 5Z: OOOI (Out, Off, On, In) event
    - 16: Departure report
    - Q0: Free text
- Software: `acarsdec` with JSON output

```bash
acarsdec -o 4 -j 127.0.0.1:5555 -r 0 131.550
# Output JSON to port 5555 for parsing
```

**NOAA Weather Satellite (APT) Processing**

- Advanced techniques beyond basic reception:
    - False color enhancement (vegetation, water detection)
    - Geographic overlay alignment
    - Multi-pass composites for full continental coverage
- Software: WXtoImg (discontinued but archived), SatDump, noaa-apt

```bash
# Decode with noaa-apt
noaa-apt recorded.wav -o image.png --contrast Telemetry
```

### Trunked Radio Systems [Inference]

**System Identification**

- P25 Phase I/II: Digital public safety (700/800 MHz)
- DMR Tier III: Commercial trunked (400/800 MHz)
- NXDN: Alternative digital standard
- TETRA: European public safety

**Control Channel Decoding**

```bash
# Using RTL-SDR with Unitrunker (Windows)
# 1. Identify control channel frequency (usually first in trunked system)
# 2. Configure Unitrunker with control channel
# 3. Monitor voice grant assignments
```

- Control channel reveals: Talk group IDs, unit IDs, frequency grants
- Traffic analysis: Pattern-of-life for radio users without decrypting voice

**SDRTrunk** (Open Source Alternative)

- Java-based trunked radio decoder
- Supports: P25 Phase I/II, DMR, LTR
- Setup:

```bash
git clone https://github.com/DSheirer/sdrtrunk.git
# Follow build instructions
java -jar sdrtrunk.jar
```

- Configure playlist with control channel, monitor talk groups

### Satellite Communications SIGINT

**Inmarsat-C Decoding**

- Maritime safety and distress: 1525-1559 MHz (downlink)
- Software: JAERO (Qt-based decoder)
- Requires: RTL-SDR or similar, JAERO compiled from source
- Output: Position reports, short messages from ships/aircraft

**Iridium Satellite Tracking**

- Frequency: ~1616-1626 MHz
- Toolkit: `iridium-toolkit` (GitHub: muccc/iridium-toolkit)

```bash
# Record IQ samples
rtl_sdr -f 1626000000 -s 2000000 -g 40 iridium.cu8

# Demodulate
iridium-extractor -D 4 iridium.cu8 | grep "RAW:"
```

- Extract: Ring alerts, pager messages, call setup metadata
- Note: Voice is encrypted, but metadata is valuable

**GOES/Meteosat HRIT/LRIT**

- Geostationary weather satellites
- LRIT: Low Rate Information Transmission (VHF, 137 MHz region)
- HRIT: High Rate (L-band, 1691 MHz for GOES)
- Decoder: `goestools`, `xrit-rx`

```bash
# GOES-16 reception
goesrecv -c goesrecv.conf  # Demodulate
goesproc -c goesproc.conf  # Process images
```

### Direction Finding (DF) Advanced Techniques

**KrakenSDR Setup**

- 5-channel coherent SDR for TDOA
- Antenna array: Uniform circular array (UCA) recommended
- Software: KrakenSDR DOA DSP + Android app

```bash
# Server-side processing
cd krakensdr_doa
./kraken_doa_start.sh
# Access web interface on port 8080
```

- Accuracy: ~5° under good conditions
- Range: Depends on frequency and transmitter power

**Time Difference of Arrival (TDOA)**

- Multiple synchronized receivers
- Calculate position from timing differences
- KiwiSDR network: TDoA service at rx.linkfanel.net
- Upload IQ recording, system calculates probable transmitter location

**Manual DF with Directional Antenna**

- Yagi antenna: Highly directional (3-element ~12 dBi gain)
- Technique: Rotate antenna, note strongest signal direction
- Cross-bearing: Take bearings from 2+ locations, plot intersection
- Tools: Compass, mapping software (Google Earth)

**Doppler DF** [Inference - requires specialized hardware]

- Rotating antenna or electronically switched array
- Phase shift analysis determines direction
- Commercial units: RDF products from DDF, Ramsey Electronics
- DIY: Arduino-controlled RF switch + antenna array

### RF Exploitation in CTF Context

**Challenge Signal Capture**

- Provided RF file formats: .wav (audio), .iq (raw samples), .cu8 (complex unsigned 8-bit)
- Identify modulation visually:

```bash
# View in inspectrum
inspectrum challenge.iq
```

- Measure symbol rate: Zoom into transitions, use cursor measurement

**Common CTF Signal Types**

- FSK (Frequency Shift Keying): Binary data, two distinct tones
- PSK (Phase Shift Keying): Constant frequency, phase changes encode data
- OOK (On-Off Keying): Simplest, signal present = 1, absent = 0
- AFSK (Audio FSK): Used in APRS, AX.25 packet radio

**Decoding Workflow**

1. Load signal in Universal Radio Hacker (URH)
2. Auto-detect modulation parameters
3. Demodulate to binary
4. Analyze protocol: Look for preambles, sync words
5. Extract data: Convert binary to ASCII/hex
6. Decode protocol-specific encoding

**Example: FSK Challenge**

```bash
# Using URH
urh challenge.iq
# In URH GUI:
# - Analysis tab: Auto-detect modulation (FSK)
# - Interpretation: Binary
# - Search for ASCII patterns or known headers
```

**Manchester Encoding**

- Common in RF protocols (LoRa, RFID)
- Each bit encoded as transition: 01 = 0, 10 = 1
- Decoder: Manual in Python or URH's interpretation modes

```python
def manchester_decode(bits):
    decoded = ''
    for i in range(0, len(bits)-1, 2):
        if bits[i:i+2] == '01':
            decoded += '0'
        elif bits[i:i+2] == '10':
            decoded += '1'
    return decoded
```

### Spectrum Allocation Research

**ITU Radio Regulations**

- International Telecommunication Union frequency allocations
- Regions: Region 1 (Europe/Africa), Region 2 (Americas), Region 3 (Asia/Pacific)
- Document: ITU Radio Regulations Article 5 (Frequency Allocations)
- Access: itu.int/en/ITU-R/terrestrial/fmd

**National Allocation Tables**

- FCC (USA): transition.fcc.gov/oet/spectrum/table/fcctable.pdf
- Ofcom (UK): ofcom.org.uk/spectrum/information/uk-fat
- ACMA (Australia): acma.gov.au/spectrum

**License Lookups**

- FCC ULS (Universal Licensing System): wireless2.fcc.gov/UlsApp/UlsSearch
- Search by: Callsign, frequency, geographic area, licensee name
- Returns: Exact frequencies, transmitter locations, power levels, license holder

**Database of Assigned Frequencies** [Unverified - availability varies]

- Some governments publish assigned frequencies for coordination
- Example: UK Ofcom OfcomWatch (discontinued but archived)
- Amateur radio coordination: Repeater directories (artscipub.com/repeaters)

## Financial Intelligence - Advanced Techniques

### Dark Web Financial Intelligence [Inference]

**Cryptocurrency Tracking on Dark Markets**

- Marketplaces: Vendor Bitcoin addresses publicly visible in listings
- Methodology:
    1. Identify marketplace wallet addresses
    2. Track transactions to vendor addresses
    3. Follow fund flows to exchanges (cashout points)
    4. Cluster analysis: Group related addresses
- Tools: GraphSense (open source blockchain analytics), OXT.me

**Ransomware Payment Tracking**

- Payment addresses: Often published by victims or researchers
- Databases: Ransomwhere Project (ransomwhe.re - defunct but archived data exists)
- Monitor addresses for incoming payments (indicates new victims)
- Track to exchanges: Identify cashout patterns

**Mixing Service Detection**

- CoinJoin detection: Multiple inputs, multiple outputs of similar amounts
- Peeling chain analysis: Sequential transactions with decreasing amounts
- Example analysis:

```python
# Pseudocode for basic taint analysis
def trace_funds(address, depth=5):
    if depth == 0:
        return
    transactions = get_transactions(address)
    for tx in transactions:
        for output in tx.outputs:
            if output.value > threshold:
                trace_funds(output.address, depth-1)
```

### Corporate Espionage Indicators [Inference]

**Insider Trading Detection**

- SEC Form 4 monitoring: Unusual officer/director trades before announcements
- Pattern: Large sales shortly before negative news
- Tools: OpenInsider.com (aggregates Form 4 filings)
- Automated alerts:

```python
import requests
from bs4 import BeautifulSoup

def check_insider_trades(ticker):
    url = f"http://openinsider.com/screener?s={ticker}"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    # Parse table for recent trades
    # Alert if large trades detected
```

**Patent Racing Analysis**

- Identify competing patent applications in same tech area
- USPTO Public PAIR: Track prosecution history
- Indicators: Competitor filing shortly after target company
- Cross-reference with employee LinkedIn moves (ex-employee joins competitor)

**M&A Intelligence** [Inference]

- Predictive indicators before public announcement:
    - Unusual volume of site visits (Similarweb Pro data)
    - Job postings for integration roles
    - Increased executive travel patterns (if trackable)
    - Uptick in NDA filings (if accessible via court records)
- Google Trends: Search volume spikes for "Company A + Company B"

### Supply Chain Intelligence

**Shipping Container Tracking**

- Container number format: 4 letters + 7 digits (e.g., MSCU1234567)
- Tracking portals: Maersk, MSC, CMA CGM carrier websites
- Input container number → Receive: Current location, ETA, vessel name

**Bill of Lading (BOL) Analysis**

- Commercial databases: Import Genius, Panjiva (subscription)
- Free alternatives: USA Trade Online (limited free tier)
- Extract: Shipper, consignee, HS code, quantity, value
- Use case: Map supplier relationships, identify grey market flows

**Port Activity Monitoring**

- AIS data: Identify vessels at specific ports (see Maritime section)
- Port webcams: Public cameras showing berth activity
- Example: Port of Los Angeles webcam network
- Correlate vessel calls with corporate earnings guidance

**Logistics Pattern Analysis** [Inference]

- Seasonal trends: Increase in shipments before product launches
- Route changes: Shifts may indicate new suppliers or tariff avoidance
- Transit time analysis: Expedited shipping may signal supply urgency

### Financial Network Mapping

**Maltego Transforms for Finance**

- Built-in transforms: Company → Officers, Email → Social Media
- Custom transforms: SEC filings, OpenCorporates API
- Configuration:

```python
# Example custom transform (pseudo-code)
def sec_filing_transform(company_cik):
    filings = query_edgar_api(company_cik)
    for filing in filings:
        return MaltegoEntity('Filing', filing.form_type)
```

**Officer Network Analysis**

- Identify shared board members across companies
- Interlocking directorates: Potential conflicts of interest
- Data source: DEF 14A proxy statements (SEC)
- Visualization: NetworkX in Python

```python
import networkx as nx
import matplotlib.pyplot as plt

G = nx.Graph()
G.add_edge('Company A', 'Officer 1')
G.add_edge('Company B', 'Officer 1')
G.add_edge('Company B', 'Officer 2')
nx.draw(G, with_labels=True)
plt.show()
```

**Shell Company Identification** [Inference]

- Red flags:
    - Registered agent address (corporate services company)
    - Minimal public information
    - No website or web presence
    - Recent incorporation with immediate major transactions
    - Officers with multiple simultaneous directorships (100+)
- Verification: OpenCorporates, state business registries

**Tax Haven Analysis**

- Common jurisdictions: BVI, Cayman Islands, Panama, Jersey
- Identify structures: Review Panama Papers dataset (ICIJ)
- Legal but notable: Aggressive tax planning structures
- Cross-reference: OECD list of non-cooperative jurisdictions

### Sanctions Evasion Detection [Inference]

**Ship-to-Ship (STS) Transfer Monitoring**

- AIS gap analysis: Vessel turns off AIS, reappears elsewhere
- Loitering detection: Slow speed in open ocean areas
- Satellite imagery: Confirm STS transfers visually
- Tools: Windward Maritime AI, Spire Maritime

**Name Variations and Aliases**

- Fuzzy matching algorithms: Levenshtein distance for entity names

```python
from fuzzywuzzy import fuzz

def check_sanctions_match(entity_name, sanctions_list):
    for sanctioned in sanctions_list:
        ratio = fuzz.ratio(entity_name, sanctioned)
        if ratio > 85:  # Threshold for match
            return True, sanctioned
    return False, None
```

- Translation variants: Romanization differences (Cyrillic, Arabic)

**Front Company Indicators**

- Shared addresses with known sanctioned entities
- Recent formation coinciding with sanctions implementation
- Lack of legitimate business web presence
- Payment routing through multiple jurisdictions

**Trade-Based Money Laundering (TBML)** [Inference]

- Invoice manipulation: Over/under-invoicing goods
- Detection: Compare declared values against market prices
- Data: Import/export declarations (where accessible)
- Red flags: Significant variance from commodity pricing indices

### Advanced Due Diligence Techniques

**Adverse Media Screening**

- Automated searches: Google News API, news aggregators

```python
from GoogleNews import GoogleNews

googlenews = GoogleNews(lang='en', period='1y')
googlenews.search(f'"{company_name}" AND (fraud OR corruption OR investigation)')
results = googlenews.results()
```

- Keywords: Fraud, corruption, investigation, lawsuit, sanctions
- Languages: Search in local language of entity's jurisdiction

**Politically Exposed Persons (PEP) Screening**

- Databases: World-Check (commercial), PEP data from OpenSanctions
- Definition: Government officials, immediate family, close associates
- Automation: API integration for batch screening

```python
# Using OpenSanctions API (hypothetical)
import requests
response = requests.get(f'https://api.opensanctions.org/search/{entity_name}')
if response.json()['results']:
    # Flag as PEP match
```

**Social Media Financial Intelligence**

- LinkedIn: Track employee growth/decline (hiring freezes, mass layoffs)
- Twitter/X: Executive statements, corporate communications
- Glassdoor: Employee reviews indicating financial distress
- Archive.org: Historical website changes (remove products, downsize)

**UCC Filings (US Secured Transactions)**

- Uniform Commercial Code: Public record of collateral pledges
- Search: Secretary of State websites by debtor name
- Indicates: Loans secured by assets (equipment, inventory, receivables)
- Financial distress indicator: Multiple recent UCC filings

### Cryptocurrency Advanced Topics

**DeFi Protocol Analysis**

- Smart contract addresses: Publicly viewable on blockchain explorers
- Etherscan.io: Read contract code, transaction history
- Identify protocol treasuries: Large balances in known contracts
- Token flows: Track governance token movements

**NFT Wash Trading Detection** [Inference]

- Pattern: Repeated sales between same addresses
- Indicator: Price artificially inflated
- Analysis: Graph wallet connections, identify circular transactions

```python
# Pseudo-code
def detect_wash_trading(nft_contract, token_id):
    transfers = get_token_transfers(nft_contract, token_id)
    addresses = [t['from'] for t in transfers] + [t['to'] for t in transfers]
    if len(addresses) != len(set(addresses)):
        return True  # Same address appears multiple times
    return False
```

**Cross-Chain Tracking**

- Bridge protocols: Wrapped tokens moving between chains (BTC→WBTC on Ethereum)
- Challenge: Different address formats across chains
- Tools: Blockchain.com multi-chain explorer, Blockchair
- Methodology: Track wallet owner across chains via exchange deposit/withdrawal timing

**Privacy Coin Limitations**

- Monero (XMR): Stealth addresses, ring signatures obscure sender/receiver
- Zcash (ZEC): Optional shielded transactions (most use transparent)
- Analysis limitation: Cannot trace Monero transactions with public tools
- Metadata still available: Exchange records (if user cashes out to fiat)

## Satellite Imagery - Advanced Analysis

### Hyperspectral Analysis [Inference - requires specialized data]

**Beyond RGB Imaging**

- Hyperspectral: 100+ narrow spectral bands
- Applications: Mineral detection, precision agriculture, environmental monitoring
- Data sources: NASA EO-1 Hyperion (archived), PRISMA (Italian Space Agency)
- Analysis software: ENVI (commercial), SpecTIR (commercial)

**Material Identification**

- Spectral signatures: Unique absorption patterns identify materials
- Examples:
    - Vegetation: Strong reflection in NIR, absorption in red
    - Water: Strong absorption in NIR/SWIR
    - Concrete: Relatively flat spectral response
- Library matching: Compare spectra to reference databases

**Military Application Examples** [Inference]

- Camouflage detection: Spectral mismatch between paint and natural vegetation
- Vehicle identification: Metal vs. decoy spectral signatures
- Disturbed earth: Spectral changes indicate recent digging

### Synthetic Aperture Radar (SAR) Advanced Techniques

**Interferometric SAR (InSAR)**

- Purpose: Measure ground deformation at millimeter scale
- Methodology: Compare phase difference between two SAR acquisitions
- Applications: Earthquake damage, subsidence, volcanic activity, infrastructure monitoring
- Tools: SNAP (ESA), ISCE (JPL/Caltech)

```bash
# SNAP graph processing (simplified)
gpt Interferogram.xml -Pmaster=S1A_master.zip -Pslave=S1A_slave.zip -Poutput=ifg.tif
```

**Coherence Change Detection**

- Measures correlation between two SAR images
- High coherence: No change (stable scatterers)
- Low coherence: Change occurred (construction, vegetation growth, flooding)
- Application: Rapid damage assessment after disasters

**Polarimetric SAR**

- Multiple polarizations: HH, HV, VH, VV
- Scattering mechanisms: Surface, double-bounce, volume
- Classification: Distinguish vegetation types, urban structures
- Data: ALOS-2, RADARSAT-2 (commercial)

**SAR Ship Detection**

- Bright targets on dark ocean background
- Automated detection algorithms: Constant False Alarm Rate (CFAR)
- Challenges: Sea state, vessel size
- Comparison: Match detected vessels with AIS data (identify dark ships)

### Change Detection Methodologies

**Automated Change Detection**

```python
# Using OpenCV
import cv2
import numpy as np

img1 = cv2.imread('before.tif', 0)
img2 = cv2.imread('after.tif', 0)

# Ensure same size
img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))

# Absolute difference
diff = cv2.absdiff(img1, img2)

# Threshold
_, thresh = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)

# Morphological operations to reduce noise
kernel = np.ones((5,5), np.uint8)
thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)

cv2.imwrite('changes_detected.tif', thresh)
```

**Machine Learning-Based Detection** [Inference]

- Training: Labeled dataset of change/no-change regions
- Algorithms: Random Forest, CNN-based (U-Net architecture)
- Framework: TensorFlow, PyTorch
- Output: Probability map of changed areas

**Multi-Temporal Analysis**

- Time series: Landsat/Sentinel-2 (monthly to biweekly)
- Trend detection: NDVI decline indicating deforestation
- Phenology: Track agricultural cycles, crop identification
- Tools: Google Earth Engine for cloud-based processing

### 3D Reconstruction

**Stereo Photogrammetry**

- Principle: Overlapping images from different angles
- Software: OpenDroneMap (open source), Pix4D (commercial)
- Input: Multiple images with GPS tags
- Output: Digital Elevation Model (DEM), orthophoto, 3D mesh

**Structure from Motion (SfM)**

- Extract 3D structure from 2D image sequences
- Application: Reconstruct buildings from multiple satellite passes
- Tools: VisualSFM, COLMAP
- CTF relevance: Estimate object heights, volumes from imagery

**LiDAR Data Integration** [Unverified - data availability varies]

- Light Detection and Ranging: Laser-based elevation measurement
- Public data: USGS 3DEP (US), OpenTopography
- Precision: Centimeter-level elevation accuracy
- Fusion: Combine with optical imagery for detailed terrain models

### Activity-Based Intelligence (ABI) from Imagery

**Pattern-of-Life Analysis**

- Time series of high-resolution imagery
- Track: Vehicle parking patterns, facility usage
- Example: Identify work schedules from peak vehicle presence
- Tools: Manual annotation, time-lapse generation

**Predictive Analysis** [Inference]

- Historical patterns predict future activity
- Example: Military exercises - identify mobilization indicators (equipment staging)
- Methodology: Correlate past imagery with known events

**Multi-INT Fusion**

- Combine: Satellite imagery + AIS/ADS-B + SIGINT
- Example: Confirm vessel at port (imagery) matches AIS report
- Discrepancies: Indicate spoofing or deception

### Geospatial Tools and Workflows

**QGIS Advanced Techniques**

- **Raster Calculator**: Compute indices (NDVI, NDWI)

```
# NDVI calculation in QGIS Raster Calculator
("NIR_band@1" - "Red_band@1") / ("NIR_band@1" + "Red_band@1")
```

- **Semi-Automatic Classification Plugin**
    
    - Supervised classification: Train algorithm with sample polygons
    - Output: Land cover map (urban, vegetation, water, bare soil)
- **Time Manager Plugin**: Animate time-series data
    

**Google Earth Engine (GEE) Scripts**

```javascript
// Cloud-free composite
var s2 = ee.ImageCollection('COPERNICUS/S2_SR')
  .filterBounds(geometry)
  .filterDate('2024-01-01', '2024-12-31')
  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20))
  .median();

// Calculate NDVI
var ndvi = s2.normalizedDifference(['B8', 'B4']);

// Threshold vegetation
var vegetation = ndvi.gt(0.4);

Map.addLayer(vegetation, {palette: ['white', 'green']}, 'Vegetation');

// Export
Export.image.toDrive({
  image: vegetation,
  description: 'vegetation_mask',
  scale: 10,
  region: geometry
});
```

**Automation with Python**

```python
# Sentinelsat: Download Sentinel imagery programmatically
from sentinelsat import SentinelAPI, read_geojson, geojson_to_wkt

api = SentinelAPI('username', 'password', 'https://apihub.copernicus.eu/apihub')

footprint = geojson_to_wkt(read_geojson('area.geojson'))

products = api.query(footprint,
                     date=('20240101', '20241231'),
                     platformname='Sentinel-2',
                     cloudcoverpercentage=(0, 10))

api.download_all(products)
```

---

**Related Topics for Deep Dives:**

- MASINT (Measurement and Signature Intelligence) integration with OSINT
- Counter-OSINT: Detecting when you're being tracked via OSINT methods
- Legal frameworks: GDPR, CCPA implications for OSINT collection
- OSINT automation frameworks: Spiderfoot, Recon-ng, theHarvester
- Darknet OSINT: Tor hidden service enumeration, marketplace scraping ethics and legality

---

# CTF-Specific Techniques

## Common CTF Challenge Types

CTF challenges are organized into distinct categories, each requiring specialized knowledge and toolsets. Understanding these categories helps direct your reconnaissance and exploitation approach.

### Web Exploitation

Challenges targeting web application vulnerabilities including SQL injection, XSS, CSRF, authentication bypasses, session manipulation, and server-side request forgery (SSRF). Common subtypes include:

**SQL Injection variants**: Error-based, blind boolean-based, time-based blind, union-based, second-order injection **Authentication flaws**: Broken access control, weak session management, JWT vulnerabilities, OAuth misconfigurations **File operations**: Local File Inclusion (LFI), Remote File Inclusion (RFI), unrestricted file upload, path traversal **Server-side vulnerabilities**: SSRF, Server-Side Template Injection (SSTI), XML External Entity (XXE) injection, deserialization attacks **Client-side attacks**: DOM-based XSS, prototype pollution, clickjacking

### Binary Exploitation (Pwn)

Memory corruption and exploitation of compiled binaries, typically requiring reverse engineering and exploitation development skills.

**Buffer overflows**: Stack-based, heap-based, format string vulnerabilities **Return-oriented programming (ROP)**: Chain gadgets to bypass DEP/NX **Heap exploitation**: Use-after-free, double-free, heap overflow, tcache poisoning **Shellcoding**: Writing position-independent shellcode for various architectures **Bypass techniques**: ASLR defeat, stack canary bypass, PIE circumvention

Tools commonly used: `gdb` with PWNDBG/GEF/PEDA, `pwntools`, `ROPgadget`, `one_gadget`, `radare2`, `ghidra`

### Reverse Engineering

Analysis of compiled binaries, obfuscated code, or proprietary formats to understand functionality and extract secrets.

**Static analysis**: Disassembly examination, control flow analysis, string/symbol analysis **Dynamic analysis**: Runtime debugging, API monitoring, memory inspection **Obfuscation defeat**: Unpacking, deobfuscation, anti-debugging bypass **Platforms**: x86/x64 Windows/Linux binaries, Android APKs, iOS applications, embedded firmware, Java/Python bytecode

Tools: `IDA Pro`/`IDA Free`, `Ghidra`, `Binary Ninja`, `radare2`, `dnSpy` (.NET), `jadx` (Android), `Hopper`, `x64dbg`

### Cryptography

Breaking weak implementations, exploiting mathematical vulnerabilities, or finding flaws in cryptographic protocols.

**Classical ciphers**: Caesar, Vigenère, substitution, transposition **Modern weaknesses**: Weak key generation, ECB mode vulnerabilities, padding oracle attacks, RSA implementation flaws (small exponent, common modulus, Wiener's attack) **Hash vulnerabilities**: Length extension attacks, collision attacks, hash format confusion **Protocol attacks**: Man-in-the-middle, replay attacks, downgrade attacks

Common scenarios: Custom crypto implementations, reused nonces/IVs, predictable randomness, implementation side-channels

### Forensics

Data recovery, file analysis, memory analysis, network traffic analysis, steganography detection.

**File forensics**: File carving, metadata extraction, corrupted file repair, file format analysis, alternate data streams **Memory forensics**: Process analysis, malware detection, credential extraction using Volatility **Network forensics**: PCAP analysis with Wireshark/tshark, protocol reconstruction, traffic pattern analysis **Steganography**: LSB analysis, statistical detection, tool-specific extraction (steghide, outguess, zsteg) **Disk forensics**: Deleted file recovery, filesystem timeline analysis, partition analysis

Tools: `Autopsy`, `Volatility`, `Wireshark`, `binwalk`, `foremost`, `strings`, `exiftool`, `steghide`, `stegsolve`

### OSINT (Open Source Intelligence)

Information gathering from publicly available sources, social media, metadata, and internet resources.

**Domain intelligence**: WHOIS lookups, DNS enumeration, subdomain discovery, certificate transparency logs **Social media**: Profile analysis, relationship mapping, timeline correlation, username pivoting **Geolocation**: Image geolocation using EXIF, landmark identification, reverse image search **Document intelligence**: Metadata extraction, authorship attribution, hidden information recovery **Data breach analysis**: Credential searching, email correlation, leaked database queries

Tools: `theHarvester`, `recon-ng`, `maltego`, `sherlock`, `exiftool`, Google dorking, `wayback machine`

### Miscellaneous

Challenges that don't fit traditional categories or combine multiple disciplines.

**Esoteric languages**: Brainfuck, Malbolge, Whitespace, Piet **Game hacking**: Save file manipulation, client-side modification, network protocol analysis **OSINT puzzles**: QR codes, barcodes, audio spectrograms, puzzles requiring external research **Sanity checks**: Simple challenges verifying connection and flag submission **Programming challenges**: Algorithm implementation, code golf, automation tasks

## Flag Format Recognition

Flags follow predictable patterns that help validate successful exploitation and guide extraction efforts.

### Standard Flag Formats

**Wrapped formats** (most common):

```
flag{...}
FLAG{...}
ctf{...}
CTF{...}
```

**Competition-specific formats**:

```
HTB{...}           # HackTheBox
picoCTF{...}       # picoCTF
DUCTF{...}         # DownUnderCTF
tjctf{...}         # TJCTF
```

**Organizational prefixes**:

```
[ORGNAME]{...}
[EVENTNAME]_...
ORGNAME_...
```

### Flag Content Patterns

**Hexadecimal strings**: `flag{a1b2c3d4e5f67890abcdef}`

- Typically 32 or 64 characters (MD5, SHA256 representations)
- Mixed case or lowercase

**Alphanumeric with underscores**: `flag{this_is_the_flag}`

- Human-readable message
- Often hints at vulnerability or technique

**Base64 encoded**: `flag{dGhpc19pc19iYXNlNjQ=}`

- Recognizable by trailing `=` padding
- May require decoding after extraction

**UUIDs**: `flag{550e8400-e29b-41d4-a716-446655440000}`

- Follows UUID v4 format pattern

**Hash formats**: `flag{$2b$12$...}` or `flag{$1$...}`

- Bcrypt, MD5crypt, or other hash algorithm formats

### Detection and Extraction Techniques

**Grep patterns for common formats**:

```bash
grep -r "flag{" .
grep -r "[A-Za-z0-9_]*{[^}]*}" .
grep -roP "[A-Z]{2,10}\{[^\}]{10,}\}" .
```

**Regular expressions for automated extraction**:

```python
import re
flag_patterns = [
    r'flag\{[^\}]+\}',
    r'[A-Z]{2,10}\{[^\}]{10,}\}',
    r'[a-zA-Z0-9_]+\{[a-zA-Z0-9_\-!@#$%^&*()+=]+\}'
]
```

**Multi-stage flags**: Some challenges split flags across multiple locations:

- `flag{part1_` in one location, `part2_part3}` in another
- Sequential parts: `flag_part1: HTB{first_`, `flag_part2: half_here}`

**Obfuscated flags**:

- ROT13/Caesar shifted: `synt{guvf_vf_ebg13}`
- Base64: `ZmxhZ3t0aGlzX2lzX2Jhc2U2NH0=`
- Hex encoded: `666c61677b746869735f69735f6865787d`
- Reversed: `}galf_eht_si_siht{galf`
- Leetspeak: `fl4g{7h15_15_l337}`

**Binary/non-printable flags**:

```bash
strings binary_file | grep -i flag
xxd file | grep -i "flag"
```

**Network traffic flags**:

```bash
tcpdump -r capture.pcap -A | grep -i flag
tshark -r capture.pcap -Y "frame contains flag" -T fields -e data
```

### Validation Strategies

**Checksums and validation**: Some CTFs include checksums in flag format:

```
flag{content_here_checksum:a1b2c3}
```

**Case sensitivity**: Always preserve exact case when submitting:

- `FLAG{...}` ≠ `flag{...}`
- Some platforms reject incorrect casing

**Whitespace handling**: Flags typically contain no leading/trailing whitespace:

```bash
echo "flag{extracted}" | tr -d '[:space:]'  # Remove all whitespace
```

**Partial flag indicators**: When you find strings like:

- `Flag is in /root/flag.txt`
- `Your flag: ...`
- `Congratulations! Here's your flag:`

These indicate proximity to the actual flag.

### Context-Specific Recognition

**Web challenges**: Check these common locations:

- HTML comments: `<!-- flag{hidden_here} -->`
- JavaScript variables: `var flag = "flag{...}";`
- Cookie values: `flag=flag%7Burl_encoded%7D`
- HTTP headers: `X-Flag: flag{...}`
- API responses: JSON fields named `flag`, `secret`, `key`

**Binary challenges**: Typical storage locations:

- `.rodata` section for hardcoded flags
- Stack memory after successful exploitation
- File I/O operations revealing filesystem flags
- Environment variables

**Forensics challenges**:

- EXIF metadata fields
- Steganography embedded data
- Slack space in filesystems
- Alternate data streams (Windows)
- Memory dumps at specific addresses

### False Positives and Decoys

**Common decoy patterns**:

```
flag{this_is_not_the_real_flag}
flag{keep_looking}
flag{try_harder}
flag{fake_flag_lol}
```

**Validation approaches**:

- Check flag length against platform requirements
- Verify format matches competition standard
- Submit through official channels only
- Cross-reference with challenge point value (longer flags often correlate with harder challenges)

### Automated Flag Detection Scripts

**Python extraction utility**:

```python
import re
import sys

def extract_flags(data):
    patterns = [
        r'flag\{[^\}]+\}',
        r'FLAG\{[^\}]+\}',
        r'ctf\{[^\}]+\}',
        r'CTF\{[^\}]+\}',
        r'[A-Z]{2,10}\{[a-zA-Z0-9_\-!@#$%^&*()+=]{10,}\}'
    ]
    
    found_flags = set()
    for pattern in patterns:
        matches = re.findall(pattern, data, re.IGNORECASE)
        found_flags.update(matches)
    
    return list(found_flags)

if __name__ == "__main__":
    with open(sys.argv[1], 'r', errors='ignore') as f:
        content = f.read()
    
    flags = extract_flags(content)
    for flag in flags:
        print(flag)
```

**Bash one-liner for recursive searching**:

```bash
find . -type f -exec grep -l "flag{" {} \; 2>/dev/null
```

[Inference] The specific flag formats for newer or regional CTF competitions may vary from these common patterns, as organizers occasionally create unique formats to prevent automated flag harvesting across challenges.

---

**Related important subtopics**: Challenge reconnaissance methodology, platform-specific submission requirements, automated solve script development, writeup analysis for pattern recognition

---

## Puzzle-Solving Approaches

### Pattern Recognition and Analysis

**Multi-Layer Analysis Framework** When confronting CTF challenges, apply systematic pattern recognition across multiple dimensions:

- **Data Format Identification**: Examine character sets, length patterns, and structural markers. Base64 typically uses A-Z, a-z, 0-9, +, / with = padding. Hexadecimal uses 0-9, A-F. Binary uses only 0s and 1s.
- **Frequency Analysis**: Apply statistical techniques to ciphertext. English text shows specific letter frequency (E, T, A, O, I most common). Use `freq` or custom Python scripts with `collections.Counter`.
- **Entropy Calculation**: High entropy suggests encryption or compression, low entropy suggests patterns or encoding.

```bash
# Calculate entropy of a file
ent filename

# Frequency analysis with Python
python3 -c "from collections import Counter; print(Counter(open('file.txt').read()))"
```

**Reverse Engineering Challenge Flow**

- **Static Analysis First**: Examine strings, imports, and structure before execution
- **Dynamic Analysis Second**: Run in isolated environment with monitoring
- **Hybrid Approach**: Combine both for obfuscated binaries

```bash
# Extract readable strings
strings -n 8 binary | grep -i "flag\|ctf\|password"

# Check file type and architecture
file binary
rabin2 -I binary  # using radare2

# List imported functions
objdump -T binary | grep FUNC
```

### Systematic Enumeration Techniques

**Web Application Enumeration Workflow**

1. **Information Gathering Phase**

```bash
# Directory and file discovery
gobuster dir -u http://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,txt,html,js -t 50

# Alternative with ffuf
ffuf -u http://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403

# Subdomain enumeration
ffuf -u http://FUZZ.target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

2. **Parameter Fuzzing**

```bash
# GET parameter discovery
ffuf -u "http://target.com/page.php?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -fs 0

# POST parameter fuzzing with Burp Suite Intruder or ffuf
ffuf -u http://target.com/login -X POST -d "FUZZ=test&password=test" -w params.txt -H "Content-Type: application/x-www-form-urlencoded"
```

**Network Service Enumeration**

```bash
# Comprehensive port scan
nmap -p- -sV -sC -T4 target.com -oA scan_results

# Specific service enumeration
nmap -p 445 --script smb-enum-shares,smb-enum-users target.com
nmap -p 21 --script ftp-anon,ftp-bounce target.com

# Banner grabbing
nc -nv target.com 80
```

### Lateral Thinking Strategies

**Breaking Conventional Assumptions**

- **Challenge Title Analysis**: Titles often contain hints about techniques or tools needed
- **File Extension Misdirection**: A `.jpg` might actually be a `.zip` or contain steganographic data
- **Red Herrings**: Not all data is relevant; distinguish noise from signal through validation
- **Metadata Examination**: Check EXIF data, file timestamps, and hidden attributes

```bash
# Check actual file type regardless of extension
file --mime-type suspicious.jpg

# Extract EXIF data
exiftool image.jpg

# Check for hidden data streams (NTFS ADS)
streams -s suspicious_file  # Windows
```

**Cognitive Biases to Avoid**

- **Confirmation Bias**: Don't force data to fit your initial hypothesis; remain flexible
- **Anchoring**: The first approach isn't always correct; be willing to restart
- **Sunk Cost Fallacy**: If stuck for >30 minutes, switch challenges or ask teammates

### Creative Problem-Solving Techniques

**Unconventional Data Extraction**

```bash
# Check for alternate data streams
binwalk -e firmware.bin  # Extract embedded files

# Look for hidden ZIP archives
unzip -l potential_archive.dat

# Raw data extraction
dd if=file.bin of=extracted.dat bs=1 skip=1024 count=2048

# Check for polyglot files (valid as multiple formats)
pngcheck image.png && unzip -l image.png
```

**Encoding/Cipher Chain Recognition** Multiple encoding layers are common:

1. Base64 → Hex → ROT13 → Plaintext
2. URL encoding → Base64 → XOR → Flag

```python
# Multi-decode automation script
import base64
import codecs

def try_decode(data):
    attempts = []
    
    # Try base64
    try:
        decoded = base64.b64decode(data)
        attempts.append(("base64", decoded))
    except: pass
    
    # Try hex
    try:
        decoded = bytes.fromhex(data.decode() if isinstance(data, bytes) else data)
        attempts.append(("hex", decoded))
    except: pass
    
    # Try ROT13
    try:
        decoded = codecs.decode(data.decode() if isinstance(data, bytes) else data, 'rot13')
        attempts.append(("rot13", decoded))
    except: pass
    
    return attempts
```

### Challenge-Specific Heuristics

**Cryptography Challenges**

- **Low Exponent Attack**: RSA with e=3 may be vulnerable to cube root attack
- **Common Modulus**: Multiple messages with same N but different e
- **Weak Padding**: Check for padding oracle vulnerabilities
- **Classical Ciphers**: Frequency analysis for substitution ciphers, Kasiski examination for Vigenère

**Binary Exploitation**

- **Buffer Overflow Indicators**: `gets()`, `strcpy()`, `scanf("%s")` without bounds checking
- **Format String Bugs**: Uncontrolled format strings in `printf()` family functions
- **Integer Overflows**: Arithmetic operations without validation, especially in size calculations
- **Use-After-Free**: Pointer usage after `free()` calls

```bash
# Check for security mechanisms
checksec binary  # Using pwntools

# Basic buffer overflow identification with GDB + GEF
gdb binary
gef> pattern create 200
gef> run < <(python3 -c 'print("PATTERN_HERE")')
gef> pattern offset $rsp
```

**Web Exploitation Pattern Recognition**

- **SQL Injection Indicators**: Error messages, timing differences, boolean-based responses
- **XSS Contexts**: Check where input appears (HTML, JavaScript, attribute, URL)
- **SSRF Opportunities**: URL parameters, file upload paths, webhook endpoints
- **Path Traversal**: File parameters, template paths, include statements

```bash
# Quick SQLi detection
sqlmap -u "http://target.com/page?id=1" --batch --level=3 --risk=2

# Manual boolean-based SQLi test
' AND 1=1 --   # True condition
' AND 1=2 --   # False condition
# Compare responses
```

## Time Management Strategies

### Pre-Competition Preparation

**Environment Setup Checklist** Create a standardized CTF environment to minimize setup time:

```bash
# Essential tools installation script
#!/bin/bash
apt update && apt install -y \
    nmap gobuster ffuf nikto sqlmap \
    binwalk foremost steghide stegseek \
    john hashcat hydra \
    gdb radare2 ghidra \
    python3-pip wireshark tcpdump \
    exiftool file binutils \
    git curl wget netcat-openbsd

# Python tools
pip3 install pwntools requests beautifulsoup4 pycryptodome
```

**Template Scripts and Payloads** Maintain a personal repository of frequently used code:

```python
# Template: Socket interaction
from pwn import *

context.log_level = 'debug'
# r = process('./binary')
r = remote('target.com', 1337)

r.sendline(b'payload')
response = r.recvline()
print(response)
```

```python
# Template: Web request automation
import requests

session = requests.Session()
session.headers.update({'User-Agent': 'CTF-Bot'})

# GET request
resp = session.get('http://target.com/api/data')

# POST with JSON
resp = session.post('http://target.com/api/submit', 
                    json={'key': 'value'})
```

### Challenge Prioritization Matrix

**Dynamic Scoring Assessment** [Inference] Most CTFs use dynamic scoring where solve count affects points:

- **High-value targets**: Unsolved challenges (maximum points)
- **Quick wins**: Low-solve challenges with 200+ points remaining
- **Avoid**: Heavily solved challenges unless trivial

**Time Investment Calculation** Track time spent per challenge category:

```
Category          | Avg Time | Success Rate | Priority
Forensics         | 25 min   | 75%          | High
Web               | 15 min   | 85%          | High  
Crypto (classical)| 20 min   | 70%          | Medium
Crypto (modern)   | 45 min   | 40%          | Low (unless specialized)
Pwn               | 60 min   | 35%          | Medium
```

**30-Minute Rule** [Recommendation] If no progress after 30 minutes:

1. Document findings in team chat
2. Switch to different challenge
3. Return with fresh perspective or after teammate review

### Efficient Workflow Optimization

**Challenge Triage Process** (First 5 minutes)

1. **Read description carefully** - Note explicit and implicit hints
2. **Check provided files** - File types, sizes, naming conventions
3. **Run automated tools first** - Let tools work while you analyze
4. **Identify challenge category** - Determines tool selection
5. **Estimate difficulty** - Based on points, solve count, description complexity

**Parallel Processing Approach**

```bash
# Run multiple scans simultaneously
gobuster dir -u http://target.com -w wordlist.txt &
nikto -h http://target.com &
nmap -sV -sC target.com &

# Monitor all processes
jobs
```

**Command History and Note-Taking**

```bash
# Auto-log all commands with timestamps
export HISTTIMEFORMAT="%F %T "
export PROMPT_COMMAND='echo "$(history 1)" >> ~/ctf_commands.log'

# Structured notes template
mkdir -p ~/ctf_workspace/challenge_name/{files,notes,exploits}
cd ~/ctf_workspace/challenge_name/notes
cat > notes.md << EOF
# Challenge: [Name]
Category: [Web/Pwn/Crypto/etc]
Points: [Value]
Solves: [Count]

## Initial Analysis
- 

## Approach
1. 

## Solution
EOF
```

### Break and Context-Switching Strategy

**Productive Break Activities** (5-10 minutes)

- Review teammates' progress on other challenges
- Check scoreboard for newly released challenges
- Read writeups of similar past CTF challenges (for technique refresh, not current CTF)
- Physical movement to maintain alertness

**Context Switching Protocol** When changing challenges:

1. **Document current state**: Write down what you've tried, what failed, and what's unexplored
2. **Save intermediate files**: Keep all generated payloads, extracted data, and tool output
3. **Set next steps**: Write 2-3 specific things to try when returning
4. **Clean mental slate**: Completely shift focus to new challenge

### Endgame Time Management

**Final Hour Strategy** (Last 60 minutes)

- **40 minutes**: Focus only on challenges you're closest to solving (≥70% progress)
- **15 minutes**: Quick attempts at newly released challenges (often easier)
- **5 minutes**: Submit partial flags or request hints if available

**Flag Submission Optimization**

```bash
# Auto-submit flags from command line (if API available)
submit_flag() {
    curl -X POST http://ctf.com/api/submit \
         -H "Authorization: Bearer $TOKEN" \
         -d '{"challenge": "'$1'", "flag": "'$2'"}'
}

# Usage
submit_flag "web-100" "flag{found_the_secret}"
```

## Collaboration in Team CTFs

### Team Structure and Role Assignment

**Specialized Role Distribution** [Inference] Effective teams typically organize by expertise:

**Technical Roles:**

- **Web Exploitation Specialist** - Focuses on web challenges, SQLi, XSS, SSRF
- **Binary Exploitation Expert** - Handles pwn challenges, reverse engineering
- **Cryptography Analyst** - Solves crypto challenges, implements attacks
- **Forensics/Steganography** - Analyzes images, packets, memory dumps
- **Reconnaissance/OSINT** - Information gathering, social engineering challenges

**Support Roles:**

- **Challenge Coordinator** - Tracks progress, assigns challenges, manages time
- **Knowledge Manager** - Documents solutions, maintains team wiki/notes
- **Scout** - Monitors scoreboard, identifies high-value targets, spots trends

**Dynamic Role Flexibility** Team members should be cross-trained to adapt when:

- Challenge category skew (e.g., 60% web challenges)
- Individual specialization not needed
- Fresh perspectives needed on difficult challenges

### Communication Infrastructure

**Essential Communication Channels**

**Primary Platform Setup** (Discord/Slack recommended)

```
#general - Team coordination, announcements
#web - Web exploitation discussion
#pwn - Binary exploitation
#crypto - Cryptography challenges  
#forensics - Forensics and steganography
#misc - OSINT, miscellaneous challenges
#solved - Solution documentation
#scoreboard - Automated scoreboard updates
#ideas - Brainstorming and speculation
```

**Real-Time Status Updates Protocol**

```
Format: [CHALLENGE-ID] [STATUS] Brief message

Statuses:
[CLAIMED] - Working on challenge
[PROGRESS-XX%] - Estimation of completion
[STUCK] - Need assistance or switching
[SOLVED] - Challenge completed
[FLAG] - Flag found, submitting

Examples:
"[web-250] [CLAIMED] Found SQLi vector, testing payloads"
"[crypto-300] [PROGRESS-60%] Identified RSA low exponent, calculating cube root"
"[pwn-400] [STUCK] Buffer overflow working locally but not remote, need second look"
```

**Effective Communication Practices**

- **Post code snippets** using pastebin/hastebin for review, not screenshots
- **Share findings incrementally** - Don't wait until fully solved
- **Use threads/replies** to keep channels organized
- **Tag teammates** when their expertise is needed
- **Minimize noise** in focused work periods

### Knowledge Sharing Systems

**Centralized Documentation Platform**

**Recommended Structure** (HackMD/Notion/Git repository):

```
CTF_Competition_Name/
├── README.md (Overview, team info, results)
├── challenges/
│   ├── web/
│   │   ├── challenge1.md
│   │   └── challenge2.md
│   ├── pwn/
│   ├── crypto/
│   └── forensics/
├── tools/
│   ├── useful_scripts.md
│   └── custom_tools/
├── writeups/
│   └── solved_challenges.md
└── lessons_learned.md
```

**Challenge Documentation Template**

````markdown
# [Challenge Name]

**Category:** Web  
**Points:** 250  
**Solves:** 45  
**Claimed By:** @teammate  

## Description
[Challenge description]

## Files
- `source.zip` - Application source code
- `backup.sql` - Database dump

## Initial Analysis
- Identified SQL injection in login form
- MySQL database backend
- PHP 7.4 application

## Vulnerabilities Found
1. SQL injection in `/login.php` parameter `username`
2. Weak session management

## Solution Steps
1. Identified injection point: `username=' OR '1'='1`
2. Extracted database schema: [sqlmap command]
3. Retrieved flag from `secrets` table

## Flag
`flag{sql_1nj3ct10n_m4st3r}`

## Commands Used
```bash
sqlmap -u "http://target.com/login.php" --data="username=test&password=test" --dbs
````

## Lessons Learned

- Always test authentication forms for SQLi
- Check for error-based vs blind injection

```

### Collaborative Problem-Solving Techniques

**Pair Programming for Complex Challenges**
When multiple team members work together:
- **Driver/Navigator Model**: One person codes/executes, other reviews and suggests
- **Time-boxed Pairing**: 20-minute focused sessions, then evaluate progress
- **Screen Sharing**: Use Discord/Zoom for remote collaboration

**Structured Brainstorming Sessions**
When team is stuck:
1. **Facts Phase** (5 min) - List everything known about the challenge
2. **Ideas Phase** (10 min) - Generate approaches without judgment
3. **Evaluation Phase** (5 min) - Assess feasibility of each approach
4. **Assignment Phase** (2 min) - Distribute ideas to test in parallel

**Rubber Duck Debugging with Team**
[Inference] Explaining your approach to teammates often reveals issues:
```

"I'm working on [challenge]. Here's what I understand:

1. [Input mechanism]
2. [Processing logic]
3. [Output behavior]

I've tried [approach A] but got [result]. I think the issue might be [hypothesis]. What am I missing?"

````

### Conflict Resolution and Workload Balance

**Challenge Ownership Protocol**
- **Claim Before Starting**: Post intention to avoid duplication
- **30-Minute Claim Duration**: After 30 min without update, challenge available to others
- **Progress Updates**: Update every 15-20 minutes to maintain claim
- **Transfer Protocol**: Document findings when handing off challenge

**Preventing Burnout**
- **Mandatory Breaks**: Rotate 10-minute breaks every 90 minutes
- **Sleep Shifts**: For 48+ hour CTFs, schedule sleep rotations
- **Frustration Management**: Recognize when diminishing returns occur, switch challenges

**Decision-Making Under Pressure**
When disagreements arise:
1. **Data-Driven Decisions**: Prefer approaches with concrete progress
2. **Time-Boxing Disputes**: Test both approaches for 10 minutes, compare results
3. **Coordinator Override**: Designated team lead makes final call in deadlocks

### Tool and Resource Sharing

**Shared Infrastructure Setup**
```bash
# Shared CTF server setup (if allowed by rules)
# Central workspace for team
ssh ctf-server.team.com

# Shared tmux session for collaboration
tmux new-session -s ctf
tmux attach-session -t ctf

# Shared file storage
mkdir /shared/challenges/web-250
chmod 775 /shared/challenges/web-250
````

**Exploit and Payload Library** Maintain team repository of working exploits:

```python
# Team exploit library structure
team_exploits/
├── web/
│   ├── sqli_payloads.txt
│   ├── xss_vectors.html
│   └── lfi_wrappers.txt
├── pwn/
│   ├── rop_chains.py
│   └── shellcode_library.asm
└── crypto/
    ├── rsa_attacks.py
    └── oracle_padding.py
```

**Real-Time Knowledge Transfer**

- **Micro-Writeups**: Short explanations posted immediately after solving
- **Tool Demonstrations**: Quick screen-share when teammate discovers useful technique
- **Alert System**: Post urgent findings that affect multiple challenges

### Post-CTF Analysis and Improvement

**Team Retrospective Structure** (30-60 minutes after competition)

**What Went Well**

- Which strategies worked effectively?
- Which challenges were solved efficiently?
- What was our best team coordination moment?

**What Needs Improvement**

- Where did we lose time unnecessarily?
- Which tools/skills should we develop?
- What communication breakdowns occurred?

**Action Items**

- Specific skills to practice before next CTF
- Tools to install/configure
- Team process improvements to implement

**Metrics to Track**

```
Team Performance Dashboard:
- Total points: 4500 / 8000 available
- Placement: 15th / 250 teams
- Challenges solved: 18 / 40
- Average solve time: 42 minutes
- Category breakdown:
  * Web: 7/10 solved
  * Pwn: 2/8 solved
  * Crypto: 4/9 solved
  * Forensics: 5/7 solved
```

**Continuous Learning Culture**

- Share writeups from other teams after CTF ends
- Practice identified weaknesses in downtime
- Maintain updated team skillset matrix
- Rotate challenge types to build cross-functional expertise

---

# Verification and Validation

## Source Credibility Assessment

### Domain Analysis

**WHOIS Investigation**

```bash
whois example.com
whois -h whois.iana.org example.com

# Automated WHOIS analysis
python3 -c "import whois; print(whois.whois('example.com'))"
```

**DNS Records Examination**

```bash
dig example.com ANY
dig example.com TXT
nslookup -type=ANY example.com

# Historical DNS data
curl "https://securitytrails.com/domain/example.com/dns"
# Note: Requires API key for programmatic access
```

**Certificate Transparency Logs**

```bash
# Query crt.sh for certificate history
curl "https://crt.sh/?q=example.com&output=json" | jq

# Check certificate details
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -text
```

### Website Verification Techniques

**Archive Analysis**

```bash
# Wayback Machine CLI
waybackpack example.com -d ./archive

# Check archive availability
curl "http://archive.org/wayback/available?url=example.com"
```

**Technology Stack Fingerprinting**

```bash
whatweb -v example.com
wappalyzer example.com

# Header analysis
curl -I example.com
curl -s -D - example.com -o /dev/null
```

**Domain Reputation Check**

```bash
# VirusTotal domain lookup
curl -X GET "https://www.virustotal.com/api/v3/domains/example.com" \
  -H "x-apikey: YOUR_API_KEY"

# URLhaus database check
curl "https://urlhaus-api.abuse.ch/v1/url/" -d "url=http://example.com"
```

### Social Media Account Verification

**Profile Authenticity Indicators**

- Account creation date (older = more established)
- Verification badges (platform-specific criteria)
- Follower-to-following ratio patterns
- Post consistency and frequency
- Engagement metrics (genuine vs. artificial)

**Metadata Extraction**

```bash
# Twitter/X user data
curl "https://api.twitter.com/2/users/by/username/username" \
  -H "Authorization: Bearer YOUR_BEARER_TOKEN"

# Instagram profile analysis via OSINTgram
python3 osintgram.py
> info username
> followers username
```

**Reverse Image Search for Profile Pictures**

```bash
# Using Google Images API or manual methods
# Upload profile picture to:
# - images.google.com
# - tineye.com
# - yandex.com/images
```

## Cross-Referencing Techniques

### Multi-Source Validation Framework

**Three-Point Verification Method**

1. Primary source identification
2. Independent secondary confirmation
3. Tertiary corroboration or contradiction analysis

**Information Triangulation**

```bash
# Example: Verify company information
# Source 1: Official business registry
# Source 2: News archives
# Source 3: Social media presence

# Automated correlation
grep -r "company_name" ./source1/ ./source2/ ./source3/
```

### Temporal Cross-Referencing

**Timeline Construction**

```bash
# Extract dates from documents
exiftool -time:all document.pdf
pdfinfo document.pdf | grep -i date

# Create chronology
cat events.txt | sort -k1 -t',' 
```

**Historical Snapshot Comparison**

```bash
# Compare archive snapshots
diff <(curl "http://archive.org/web/20200101000000/example.com") \
     <(curl "http://archive.org/web/20210101000000/example.com")
```

### Geolocation Cross-Referencing

**Coordinate Verification**

```bash
# Reverse geocoding
curl "https://nominatim.openstreetmap.org/reverse?lat=LAT&lon=LON&format=json"

# Sun position calculation for photo verification
python3 suncalc.py --lat LAT --lon LON --date "YYYY-MM-DD" --time "HH:MM"
```

**Shadow Analysis** [Inference] Shadow angles can indicate time and approximate location when cross-referenced with sun position data, though this requires clear shadows and known reference objects.

## Fact-Checking Methodologies

### Claim Decomposition

**Breaking Down Complex Claims**

1. Identify core assertion
2. Extract supporting sub-claims
3. Isolate verifiable facts
4. Flag unverifiable opinions

**Structured Analysis Template**

```
Claim: [Original statement]
Core Facts: [Extractable data points]
Dependencies: [Prerequisite truths]
Assumptions: [Unstated premises]
Verification Status: [Confirmed/Unverified/False]
```

### Primary Source Location

**Document Authentication**

```bash
# PDF metadata analysis
exiftool -all document.pdf
pdfinfo -meta document.pdf

# Check for modifications
qpdf --check document.pdf
pdfid.py document.pdf
```

**Official Records Access**

- Government databases (SEC filings, court records)
- Academic repositories (Google Scholar, ArXiv)
- News wire services (AP, Reuters archives)
- Statistical agencies (census data, economic indicators)

### Logical Consistency Testing

**Internal Contradiction Detection**

```python
# Pseudocode for claim analysis
claims = extract_claims(text)
for c1 in claims:
    for c2 in claims:
        if contradicts(c1, c2):
            flag_inconsistency(c1, c2)
```

**Causality Verification**

- Check temporal sequence (cause before effect)
- Verify mechanism plausibility
- Assess scale/magnitude consistency
- [Inference] Identify correlation vs. causation conflation

## Misinformation Detection

### Content Analysis Techniques

**Linguistic Pattern Recognition**

```bash
# Emotional language detection
grep -i -E '(shocking|unbelievable|they don.t want|wake up)' article.txt

# Absolutist language markers
grep -i -E '(always|never|everyone|nobody|all|none)' article.txt
```

**Sentiment Analysis**

```python
# Using TextBlob or VADER
from textblob import TextBlob

text = "article content"
analysis = TextBlob(text)
print(f"Polarity: {analysis.sentiment.polarity}")
print(f"Subjectivity: {analysis.sentiment.subjectivity}")
```

### Source Behavior Patterns

**Bot Detection Indicators**

- Generic usernames (user123456789)
- Recent account creation
- High posting frequency
- Repetitive content
- Limited social interaction

**Coordination Analysis**

```bash
# Detect synchronized posting patterns
# Analyze timestamp clustering
cat posts.csv | cut -d',' -f2 | sort | uniq -c

# Network graph of retweets/shares
# Use Gephi or NetworkX for visualization
```

### Image Manipulation Detection

**Reverse Image Search**

```bash
# TinEye API
curl -X GET "https://api.tineye.com/rest/search/" \
  -d "image_url=URL" \
  -d "api_key=KEY"

# Google Vision API
curl -X POST "https://vision.googleapis.com/v1/images:annotate?key=API_KEY" \
  -H "Content-Type: application/json" \
  -d @request.json
```

**EXIF Manipulation Detection**

```bash
exiftool -all image.jpg
exiftool -history image.jpg

# Check for editing software traces
exiftool image.jpg | grep -i -E '(photoshop|gimp|editor)'
```

## Deepfake Detection

### Audio Deepfake Detection

**Spectral Analysis**

```bash
# Extract audio spectrogram
sox audio.wav -n spectrogram -o spectrogram.png

# Frequency analysis
ffmpeg -i audio.wav -af "aformat=channel_layouts=mono,showspectrumpic=s=1920x1080" spectrum.png
```

**Artifact Detection** [Unverified] Some deepfake audio may exhibit:

- Unnatural breathing patterns
- Inconsistent background noise
- Spectral discontinuities
- Phase inconsistencies

**Forensic Tools**

```bash
# Audiowmark (audio watermark detection)
audiowmark test audio.wav

# Voice consistency analysis
# Note: Requires specialized tools or APIs like Resemble AI Detect
```

### Video Deepfake Detection

**Frame-by-Frame Analysis**

```bash
# Extract frames
ffmpeg -i video.mp4 -vf fps=1 frame_%04d.png

# Analyze specific frames
for frame in frame_*.png; do
  python3 deepfake_detector.py "$frame"
done
```

**Facial Inconsistency Detection** [Inference] Common deepfake artifacts:

- Blinking pattern irregularities
- Lip-sync misalignment
- Lighting inconsistencies on face vs. body
- Edge artifacts around face boundary
- Hair/forehead texture discontinuities

**Metadata Examination**

```bash
# Extract video metadata
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4

# Check for compression artifacts
ffmpeg -i video.mp4 -vf "signalstats" -f null -
```

### Image Deepfake Detection

**AI-Generated Image Detection Tools**

```bash
# Using specialized detection models
python3 detect_gan.py --image suspicious.jpg

# Inspect for GAN fingerprints
# Note: Many detection tools are research-stage
```

**Common GAN Artifacts** [Unverified] Potential indicators:

- Asymmetric facial features
- Distorted backgrounds
- Inconsistent lighting sources
- Unnatural textures in hair/teeth
- Mismatched eye reflections
- Warped text or patterns

**Forensic Analysis**

```bash
# Noise pattern analysis
python3 noiseprint.py suspicious.jpg

# ELA (Error Level Analysis)
convert suspicious.jpg -quality 95 resaved.jpg
composite suspicious.jpg resaved.jpg -compose difference ela.png
```

### Platform-Specific Verification Tools

**Twitter/X Verification**

```bash
# Botometer API (bot likelihood score)
curl -X POST "https://botometer-pro.p.rapidapi.com/4/check_account" \
  -H "X-RapidAPI-Key: YOUR_KEY" \
  -d '{"user_id": "12345"}'
```

**YouTube Video Verification**

```bash
# InVID verification plugin techniques
# Download: https://www.invid-project.eu/tools-and-services/invid-verification-plugin/

# Manual forensics
youtube-dl -F VIDEO_URL
youtube-dl --write-info-json VIDEO_URL
```

### Advanced Detection Methodologies

**Neural Network Artifact Detection** [Unverified] Research-stage techniques:

- Attention mechanism analysis
- Frequency domain analysis (F3-Net)
- Spatial-temporal inconsistency detection
- Biological signal extraction (PPG from facial video)

**Behavioral Biometrics** [Inference] Authentic video may exhibit:

- Natural micro-expressions
- Consistent head movement patterns
- Appropriate eye contact and gaze patterns
- Natural gesture-speech coordination

### Verification Workflow

**Standard Operating Procedure**

1. **Initial Assessment**: Identify claim type and required evidence level
2. **Source Verification**: Validate origin and publication context
3. **Content Analysis**: Technical examination for manipulation
4. **Cross-Reference**: Multiple independent source confirmation
5. **Expert Consultation**: Domain specialist review when needed
6. **Documentation**: Record methodology and confidence level

**Confidence Scoring Framework**

```
High Confidence (90-100%):
- Multiple primary sources confirm
- No contradictory evidence
- Technical analysis passes all tests

Medium Confidence (60-89%):
- Secondary sources confirm
- Minor inconsistencies explainable
- Limited contradictory evidence

Low Confidence (30-59%):
- Single source or unverified sources
- Significant unexplained discrepancies
- Technical red flags present

No Confidence (<30%):
- No reliable sources
- Multiple contradictions
- Clear evidence of manipulation
```

**Important Considerations**: Deepfake detection tools and techniques are rapidly evolving. Detection methods that work today may become ineffective as generation techniques improve. Always use multiple verification approaches and maintain skepticism about any single test result. Many advanced detection tools are proprietary or research-stage and may not be publicly accessible.

---

# Operational Security

## Protecting Your Identity During OSINT

Identity protection during OSINT operations prevents attribution of reconnaissance activities to your real persona and protects against counter-intelligence.

### Identity Compartmentalization

**Persona separation strategy**: Create distinct operational identities with no linkable characteristics:

- Unique usernames never used elsewhere
- Separate email addresses for each persona
- Distinct writing styles and linguistic patterns
- Different time zone activity patterns
- Non-overlapping interest profiles

**Attribution vectors to eliminate**:

- Username reuse across platforms
- Email address patterns (similar formats)
- Password reuse (breach correlation)
- Profile picture reuse (reverse image search)
- Behavioral patterns (posting times, language quirks)
- Technical indicators (same User-Agent, screen resolution)

**Operational email management**:

```bash
# Disposable email services
10minutemail.com
guerrillamail.com
temp-mail.org

# Anonymous email providers
ProtonMail (with Tor)
Tutanota
Mailbox.org (paid)
```

Avoid: Gmail, Outlook, Yahoo for operational accounts - these require phone verification and maintain detailed logs.

### Account Creation Operational Security

**Registration requirements bypass**:

- Use VoIP numbers for SMS verification: `textnow.com`, `voice.google.com` (with precautions), `sms-activate.org` (paid)
- Temporary phone services: `receive-smss.com`, `sms-online.co`
- Avoid services requiring government ID verification

**Profile construction**:

- Use AI-generated faces: `thispersondoesnotexist.com`
- Generate fake but consistent identity: `fakenamegenerator.com`
- Create believable backstory for social engineering scenarios
- Maintain consistent metadata (location, age, interests)

[Inference] Many platforms employ machine learning to detect fake accounts through behavioral analysis, so newly created accounts may face restrictions until establishing "normal" activity patterns.

### Social Media Reconnaissance Protection

**Viewing without attribution**:

```bash
# Instagram viewing without login
bibliogram.art (instance may vary)
imginn.com

# Twitter/X viewing without account
nitter.net (various instances)

# Facebook profile viewing
mbasic.facebook.com (limited features without login)

# LinkedIn profile viewing
Use Google cache: site:linkedin.com "target name"
```

**Search engine cache exploitation**:

```
cache:linkedin.com/in/targetuser
site:archive.org linkedin.com/in/targetuser
```

**Activity minimization on platforms**:

- Never "like" or interact with target content
- Use read-only viewing methods
- Clear cookies between reconnaissance sessions
- Disable JavaScript when possible to prevent tracking pixels

### Information Request Sanitization

**Search query OpSec**: Avoid revealing reconnaissance objectives through search patterns:

**Poor OpSec**:

```
"John Smith" + "Company XYZ" + "email address"
"Company XYZ employees" + "contact information"
```

**Better OpSec**:

```
site:companyxyz.com
intitle:"Company XYZ" contact
```

Use search engine privacy features:

```bash
# DuckDuckGo (no query logging)
https://duckduckgo.com

# StartPage (Google results proxied)
https://www.startpage.com

# Searx (self-hostable metasearch)
https://searx.space (instance list)
```

## VPN and Proxy Usage

Network-level anonymization prevents IP-based attribution and geographic correlation.

### VPN Selection Criteria

**Operational VPN requirements**:

- **No-logs policy**: Verified through third-party audit
- **Jurisdiction**: Outside Five/Nine/Fourteen Eyes countries
- **Payment anonymity**: Accepts cryptocurrency, cash
- **Kill switch**: Automatic disconnect if VPN drops
- **DNS leak protection**: No DNS queries outside tunnel
- **Multi-hop**: Traffic routed through multiple servers

**Recommended providers for operational use**:

- Mullvad: Anonymous account numbers, accepts cash/crypto, Sweden jurisdiction
- IVPN: No email required, accepts Monero, Gibraltar jurisdiction
- ProtonVPN: Switzerland jurisdiction, Secure Core (multi-hop)

**VPN configuration hardening**:

```bash
# OpenVPN configuration additions
pull-filter ignore "dhcp-option DNS"
dhcp-option DNS 1.1.1.1
block-outside-dns
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

**Testing VPN effectiveness**:

```bash
# Check IP address
curl ifconfig.me
curl icanhazip.com

# DNS leak test
nslookup whoami.akamai.net
dig +short whoami.akamai.net

# WebRTC leak test (browser)
Visit: browserleaks.com/webrtc
```

### Proxy Chains and SOCKS

**Proxy configuration for terminal tools**:

```bash
# Set system-wide proxy (Linux)
export http_proxy="http://127.0.0.1:8080"
export https_proxy="http://127.0.0.1:8080"

# SOCKS5 proxy
export ALL_PROXY="socks5://127.0.0.1:9050"

# Proxychains configuration
# Edit /etc/proxychains4.conf
strict_chain  # OR dynamic_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 127.0.0.1 9050
http 10.0.0.1 8080
```

**Usage with tools**:

```bash
proxychains4 nmap -sT -Pn target.com
proxychains4 curl https://ifconfig.me
proxychains4 firefox

# SSH through SOCKS proxy
ssh -o ProxyCommand='nc -x 127.0.0.1:9050 %h %p' user@target
```

### Tor Network Integration

**Tor Browser for OSINT**:

- Default Tor Browser provides reasonable anonymity
- Use "Safest" security level for OSINT work
- Never install additional extensions
- Never login to personal accounts over Tor

**System-wide Tor routing**:

```bash
# Install Tor
apt-get install tor

# Start Tor service
systemctl start tor

# Configure applications to use SOCKS5 proxy
localhost:9050

# Transparent proxy setup (advanced)
# Route all traffic through Tor
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports 9040
```

**Tor with specific tools**:

```bash
# wget through Tor
torify wget https://target.com

# curl through Tor
curl --socks5-hostname 127.0.0.1:9050 https://target.com

# SSH through Tor
torify ssh user@hiddenservice.onion
```

**Tor operational security**:

- Never torrent over Tor (leaks real IP)
- Avoid logging into clearnet services
- Don't mix Tor and non-Tor traffic in same session
- Be aware of timing correlation attacks
- Use Tor Browser, not system Tor, for web browsing

[Unverified] Tor provides strong anonymity against most adversaries, but nation-state actors with ability to monitor both entry and exit nodes may perform timing correlation attacks. No peer-reviewed evidence confirms successful de-anonymization of properly-configured Tor users by passive monitoring alone.

### VPN + Tor Combinations

**Tor over VPN** (VPN → Tor):

```
Your IP → VPN → Tor → Internet
```

Benefits: ISP doesn't see Tor usage; Tor entry node doesn't see real IP Drawbacks: VPN provider sees you're using Tor

**VPN over Tor** (Tor → VPN):

```
Your IP → Tor → VPN → Internet
```

Benefits: VPN doesn't see real IP; can access VPN-only services Drawbacks: Complex setup; VPN exit traffic isn't anonymized by Tor

**Configuration for Tor over VPN**:

```bash
# 1. Connect to VPN first
# 2. Start Tor Browser or Tor service
# No additional configuration needed
```

## Browser Fingerprinting Prevention

Browser fingerprinting creates unique identifiers from browser characteristics, defeating IP-based anonymization.

### Fingerprinting Vectors

**Canvas fingerprinting**: HTML5 canvas rendering produces device-specific outputs based on GPU, drivers, fonts.

**WebGL fingerprinting**: Graphics card characteristics, supported extensions, rendering capabilities.

**Audio fingerprinting**: Audio context API produces unique signals based on hardware.

**Font enumeration**: List of installed fonts creates unique identifier.

**Screen resolution and color depth**: Display characteristics narrow down device type.

**Timezone and language**: Browser-reported locale information.

**HTTP headers**: User-Agent, Accept-Language, Accept-Encoding combinations.

**Browser plugins and extensions**: Installed extensions detectable through resource timing.

**Hardware concurrency**: Number of CPU cores revealed via JavaScript.

### Fingerprinting Mitigation

**Tor Browser** (recommended for maximum anonymity):

- Designed to make all users look identical
- Resists fingerprinting through consistent canvas, WebGL responses
- Updates coordinated to prevent version-based fingerprinting
- Default configuration sufficient; don't add extensions

**Browser hardening configuration**:

**Firefox hardening**:

```
about:config modifications:

privacy.resistFingerprinting = true
privacy.firstparty.isolate = true
webgl.disabled = true
media.peerconnection.enabled = false (disable WebRTC)
geo.enabled = false
dom.battery.enabled = false
dom.event.clipboardevents.enabled = false
media.navigator.enabled = false
```

**User-Agent spoofing** (limited effectiveness):

```bash
# Browser extensions
User-Agent Switcher (Firefox/Chrome)
Random User-Agent (Firefox)

# curl
curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/91.0.4472.124" https://target.com
```

[Inference] User-Agent spoofing alone provides minimal protection, as modern fingerprinting combines dozens of attributes. Inconsistent User-Agent with other browser characteristics may increase uniqueness.

**Canvas defender extensions**:

- CanvasBlocker (Firefox)
- Canvas Fingerprint Defender (Chrome)

These add random noise to canvas output, but may increase fingerprint uniqueness if improperly configured.

**Testing your fingerprint**:

```
https://coveryourtracks.eff.org
https://amiunique.org
https://browserleaks.com
https://deviceinfo.me
```

### Browser Profile Isolation

**Multiple browser profiles**:

```bash
# Firefox profile management
firefox -ProfileManager
firefox -P "operational-profile" -no-remote

# Chrome/Chromium profiles
chromium --user-data-dir="/path/to/profile"
```

**Profile isolation strategy**:

- **Profile 1**: Personal use (not for OSINT)
- **Profile 2**: General research (not sensitive)
- **Profile 3**: Operational OSINT (VPN/Tor)
- Never mix activities between profiles

**Container tabs** (Firefox):

```
# Install Multi-Account Containers extension
# Create containers for:
- Banking
- Shopping  
- Social Media
- Research
- Operational
```

Containers isolate cookies, cache, and storage between tabs.

### JavaScript and Active Content

**JavaScript restrictions**:

```bash
# NoScript extension (Firefox)
Default-deny JavaScript execution
Whitelist only necessary domains

# uBlock Origin advanced mode
Block 3rd-party scripts by default
Block 3rd-party frames
```

**Trade-offs**:

- Maximum privacy: Disable all JavaScript (many sites break)
- Balanced: Use NoScript with selective whitelisting
- Minimal: Enable JavaScript but block 3rd-party

## Secure Research Environments

Isolated research environments prevent contamination between operational and personal systems.

### Virtual Machine Isolation

**VM-based OSINT workstation**:

```bash
# VirtualBox setup
1. Install VirtualBox
2. Download Linux ISO (Debian, Ubuntu, Tails)
3. Create new VM:
   - 4GB RAM minimum
   - 50GB dynamic disk
   - NAT or Bridged networking

# VM network isolation
Settings → Network → Adapter 1
Attached to: NAT (prevents direct network exposure)

# Snapshot before each operation
VBoxManage snapshot "OSINT-VM" take "clean-state"

# Revert after operation
VBoxManage snapshot "OSINT-VM" restore "clean-state"
```

**VM hardening**:

```bash
# Disable shared folders
Settings → Shared Folders → Remove all

# Disable clipboard sharing
Settings → General → Advanced → Shared Clipboard: Disabled

# Disable drag and drop
Settings → General → Advanced → Drag'n'Drop: Disabled

# Snapshot mechanism
Create baseline → Conduct research → Revert to baseline
```

**Whonix** (Tor-focused VM):

```
Architecture: Gateway VM + Workstation VM
Gateway: Routes all traffic through Tor
Workstation: Isolated from network, uses Gateway

Download: whonix.org
Setup: Import both VMs, start Gateway then Workstation
```

Benefits: All workstation traffic forced through Tor, no leak possibility.

### Live Operating Systems

**Tails** (The Amnesic Incognito Live System):

```
Download: tails.boum.org
Boot from USB: Non-persistent by default
All traffic: Forced through Tor
Shutdown: RAM wiped, no traces
```

**Tails features**:

- Boots from USB, no hard drive installation
- All network traffic routed through Tor
- No persistent storage by default
- Cryptographic tools included
- Leaves no trace on host system

**Persistent storage** (optional):

```bash
# Configure encrypted persistence
Applications → Tails → Configure persistent volume
Select data to persist: GnuPG, SSH, browser bookmarks
```

**Kali Linux Live**:

```bash
# Create bootable USB
dd if=kali-linux.iso of=/dev/sdX bs=4M status=progress

# Boot with persistence (optional)
Select "Live USB Persistence" at boot menu
```

### Containerized Environments

**Docker containers for OSINT tools**:

```dockerfile
# Dockerfile for OSINT environment
FROM kalilinux/kali-rolling
RUN apt-get update && apt-get install -y \
    theharvester \
    recon-ng \
    maltego \
    sherlock \
    spiderfoot \
    && apt-get clean

USER osint
WORKDIR /data
```

**Build and run**:

```bash
docker build -t osint-env .
docker run -it --rm \
    --network=host \
    -v $(pwd)/data:/data \
    osint-env /bin/bash

# Network isolation (no external access)
docker run -it --rm --network=none osint-env
```

**Benefits**:

- Isolated environment
- Reproducible configuration
- Easy cleanup (container deletion)
- No host system contamination

### Physical Security Considerations

**Hardware isolation**:

- Dedicated laptop for sensitive operations
- No personal data stored on device
- Full disk encryption (LUKS, VeraCrypt)
- Encrypted USB for data transfer

**BIOS/UEFI hardening**:

```
- Set supervisor password
- Disable boot from external media (except when needed)
- Enable Secure Boot (if applicable)
- Disable unnecessary hardware (webcam, microphone)
```

**Emergency procedures**:

```bash
# Quick system wipe (Linux)
dd if=/dev/urandom of=/dev/sda bs=1M

# LUKS header destruction (renders data unrecoverable)
dd if=/dev/urandom of=/dev/sda bs=512 count=4096
```

[Inference] Physical access to hardware generally defeats software-level protections, so operational devices should never be left unattended or seized if possible.

## Digital Footprint Minimization

Reducing existing and future digital traces limits exposure during operational activities.

### Personal Information Removal

**Data broker opt-out process**:

Major data brokers requiring opt-out:

```
Spokeo: spokeo.com/optout
Whitepages: whitepages.com/suppression-requests
BeenVerified: beenverified.com/opt-out
PeopleFinder: peoplefinder.com/opt-out
Intelius: intelius.com/optout
MyLife: mylife.com/privacy-policy
```

**Automated removal services** (paid):

- DeleteMe: Monitors and removes from 40+ data brokers
- PrivacyDuck: Manual removal service
- Optery: Automated scanning and removal

**Search engine result removal**:

```
Google: google.com/webmasters/tools/removals
Bing: bing.com/webmasters/tools/content-removal
```

Note: Only removes results from search engine, not source websites.

### Social Media Sanitization

**Pre-operation account lockdown**:

```
Facebook:
Settings → Privacy → Limit Past Posts
Settings → Privacy → Who can see your friends list? → Only Me
Settings → Privacy → Who can look you up? → Friends only

LinkedIn:
Settings → Visibility → Edit your public profile → Turn off
Settings → Visibility → Profile viewing options → Anonymous

Twitter/X:
Settings → Privacy and Safety → Protect your Tweets

Instagram:
Settings → Privacy → Private Account
Settings → Privacy → Hide Story From (specific users)
```

**Metadata scrubbing before posting**:

```bash
# Image EXIF removal
exiftool -all= image.jpg

# PDF metadata removal
exiftool -all:all= document.pdf
qpdf --linearize input.pdf output.pdf

# Microsoft Office documents
exiftool -all= document.docx
```

**Historical post cleanup**:

```bash
# Twitter/X deletion tools
TweetDelete: tweetdelete.net
Semiphemeral: micahflee.com/2019/06/semiphemeral

# Reddit comment/post deletion
Redact: redact.dev
PowerDeleteSuite: github.com/j0be/PowerDeleteSuite
```

### Operational Communication Channels

**Secure messaging for coordination**:

**Signal**:

- End-to-end encrypted by default
- Minimal metadata retention
- Disappearing messages feature
- Requires phone number (use VoIP)

**Session**:

- No phone number required
- Onion-routed messages
- Decentralized architecture

**Element/Matrix**:

- Federated, self-hostable
- End-to-end encryption available
- No phone number required

**Avoiding insecure channels**: Never use for operational coordination:

- SMS/text messages
- Standard email (Gmail, Outlook)
- Discord (stores all message history)
- Telegram (not E2EE by default)
- WhatsApp (metadata collected)

### File and Communication Metadata

**Metadata in shared files**:

```bash
# Check metadata before sharing
exiftool -a -G1 file.jpg

# Common metadata leaks
GPS coordinates in photos
Author information in documents
Software version in PDFs
Creation timestamps
Edit history in Office documents
```

**Metadata removal workflow**:

```bash
#!/bin/bash
# Scrub all metadata from file

FILE="$1"
EXTENSION="${FILE##*.}"

case "$EXTENSION" in
    jpg|jpeg|png|gif)
        exiftool -all= "$FILE"
        ;;
    pdf)
        qpdf --linearize "$FILE" temp.pdf && mv temp.pdf "$FILE"
        ;;
    docx|xlsx|pptx)
        exiftool -all= "$FILE"
        ;;
    *)
        echo "Unsupported file type"
        ;;
esac
```

### DNS and Network Correlation Prevention

**DNS query privacy**:

```bash
# DNS over HTTPS (DoH)
# Firefox configuration
about:config → network.trr.mode = 2
network.trr.uri = https://mozilla.cloudflare-dns.com/dns-query

# System-wide DoH (Linux)
# Install dnscrypt-proxy
apt-get install dnscrypt-proxy
systemctl enable dnscrypt-proxy
systemctl start dnscrypt-proxy

# Configure /etc/dnscrypt-proxy/dnscrypt-proxy.toml
server_names = ['cloudflare', 'google']
listen_addresses = ['127.0.0.1:53']
```

**DNS leak prevention**:

```bash
# Test for leaks
dig +short whoami.akamai.net
nslookup whoami.akamai.net

# Force DNS through VPN tunnel
# OpenVPN configuration
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

### Temporal Pattern Obfuscation

**Activity timing correlation**: Adversaries can correlate online activity times with known individuals.

**Mitigation strategies**:

- Schedule posts/activity at random times
- Use different time zones for different personas
- Automate scheduled posts to break patterns
- Never post immediately after login

**Timezone obfuscation**:

```bash
# Set system timezone to operational location
timedatectl set-timezone Europe/London

# Browser timezone spoofing (limited effectiveness)
# Use extensions like:
- Timezone Master (Chrome)
- TimeZone Shifter (Firefox)
```

[Inference] Sophisticated adversaries may still correlate activity through behavioral analysis even with temporal obfuscation, particularly if unique linguistic patterns or domain expertise is evident.

### Operational Security Checklist

Before initiating OSINT operation:

```
[ ] VPN/Tor connection established and verified
[ ] Browser fingerprint tested (unique across sessions)
[ ] Operational persona accounts ready (no personal linkage)
[ ] VM/container snapshot taken (clean state)
[ ] No personal browser sessions active
[ ] Operational email configured with anonymous registration
[ ] DNS leak test passed
[ ] WebRTC disabled/leak tested
[ ] No location services enabled
[ ] Screen resolution set to common value
[ ] Timezone matches operational location
[ ] User-Agent matches expected profile
```

After operation:

```
[ ] Clear browser cache/cookies
[ ] Close all operational sessions
[ ] Revert VM to clean snapshot
[ ] Clear command history (history -c)
[ ] Review logs for anomalies
[ ] Scrub metadata from collected files
[ ] Move data to encrypted storage
[ ] Disconnect VPN/Tor
```

---

**Important related subtopics**: Counter-OSINT detection techniques, adversary attribution capabilities, compartmentalized identity management systems, operational security frameworks for team coordination