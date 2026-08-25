## Time and Date Functions


Time and date functions provide capabilities for measuring time, formatting dates, and performing time arithmetic.

**Header File:** `time.h`

**Core Data Types:**

- `time_t`: Represents calendar time (typically seconds since epoch)
- `clock_t`: Represents processor time
- `struct tm`: Broken-down time structure
- `size_t`: Used for sizes and counts

**struct tm Members:**

- `tm_sec`: Seconds (0-60, allowing for leap seconds)
- `tm_min`: Minutes (0-59)
- `tm_hour`: Hours (0-23)
- `tm_mday`: Day of month (1-31)
- `tm_mon`: Month (0-11, January = 0)
- `tm_year`: Years since 1900
- `tm_wday`: Day of week (0-6, Sunday = 0)
- `tm_yday`: Day of year (0-365)
- `tm_isdst`: Daylight saving time flag

**Time Acquisition Functions:**

- `time(time_t *timer)`: Get current calendar time
- `clock()`: Get processor time used by program
- `difftime(time_t end, time_t beginning)`: Calculate time difference

**Time Conversion Functions:**

- `gmtime(const time_t *timer)`: Convert to UTC broken-down time
- `localtime(const time_t *timer)`: Convert to local broken-down time
- `mktime(struct tm *timeptr)`: Convert broken-down time to time_t
- `asctime(const struct tm *timeptr)`: Convert to string representation
- `ctime(const time_t *timer)`: Convert time_t to string

**Time Formatting:**

- `strftime(char *s, size_t maxsize, const char *format, const struct tm *timeptr)`: Format time according to format string

**Format Specifiers for strftime:**

- `%Y`: 4-digit year
- `%y`: 2-digit year
- `%m`: Month (01-12)
- `%d`: Day of month (01-31)
- `%H`: Hour (00-23)
- `%M`: Minute (00-59)
- `%S`: Second (00-60)
- `%A`: Full weekday name
- `%B`: Full month name
- `%c`: Complete date and time representation

**Constants:**

- `CLOCKS_PER_SEC`: Clock ticks per second
- `CLK_TCK`: Deprecated, use CLOCKS_PER_SEC [Inference - common practice]

**Timezone Handling:**

- Functions respect local timezone settings
- `gmtime()` provides UTC/GMT time
- `localtime()` adjusts for local timezone and daylight saving

**Performance Measurement:**

- `clock()` measures CPU time used by program
- Resolution depends on implementation
- Useful for benchmarking and profiling

