## Web Scraping and APIs


### Web Data Acquisition Framework

R provides comprehensive tools for extracting data from web sources, including static HTML parsing, dynamic content scraping, and API interaction.

**Core Web Scraping Packages:**

- `rvest` for HTML parsing and web scraping
- `httr` for HTTP requests and API interaction
- `RSelenium` for dynamic content and JavaScript-heavy sites
- `xml2` for XML parsing and manipulation
- `jsonlite` for JSON data handling

**Basic Web Scraping Workflow:**

```r
library(rvest)
library(httr)

# Read HTML page
webpage <- read_html("https://example.com/data")

# Extract specific elements
table_data <- webpage %>%
  html_nodes("table.data-table") %>%
  html_table(fill = TRUE)

# Extract text and attributes
links <- webpage %>%
  html_nodes("a") %>%
  html_attr("href")
```

### API Integration and Data Retrieval

Modern data acquisition increasingly relies on APIs providing structured access to data sources.

**RESTful API Interaction:**

```r
library(httr)
library(jsonlite)

# API request with authentication
api_response <- GET("https://api.example.com/v1/data",
                    add_headers(Authorization = paste("Bearer", api_key)),
                    query = list(limit = 100, offset = 0))

# Parse JSON response
if (status_code(api_response) == 200) {
  api_data <- content(api_response, "text") %>%
    fromJSON(flatten = TRUE)
}
```

**Specialized API Packages:** Domain-specific packages provide streamlined access to particular data sources:

- `rtweet` for Twitter API integration
- `Rfacebook` for Facebook Graph API
- `googlesheets4` for Google Sheets API
- `rdrop2` for Dropbox API
- `aws.s3` for Amazon S3 integration

### Advanced Scraping Techniques

Complex web scraping scenarios require sophisticated approaches handling authentication, rate limiting, and dynamic content.

**Dynamic Content Scraping:**

```r
library(RSelenium)

# Start Selenium server
rD <- rsDriver(browser = "firefox", port = 4545L)
remDr <- rD[["client"]]

# Navigate and interact with dynamic content
remDr$navigate("https://dynamic-site.com")
remDr$findElement(using = "id", value = "search-box")$sendKeysToElement(list("search term"))
remDr$findElement(using = "id", value = "search-button")$clickElement()

# Extract results after JavaScript execution
page_source <- remDr$getPageSource()
```

