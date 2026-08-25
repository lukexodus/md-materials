## `time` Module


### Overview

The `time` module provides functions for working with time-related operations in Python. It handles time representations, formatting, parsing, and sleeping operations. The module works with both system time and provides utilities for measuring elapsed time, making it essential for scheduling, performance measurement, and time-based operations.

### Importing the Module

```python
import time
from time import sleep, time, strftime  # Import specific functions
```

### Time Representations

#### Epoch Time

Unix timestamp representing seconds since January 1, 1970, 00:00:00 UTC.

```python
import time

# Current time as timestamp
current_time = time.time()
print(current_time)  # 1720497234.567890

# Convert timestamp to readable format
print(time.ctime(current_time))  # Wed Jul 09 14:20:34 2025
```

#### Struct Time

A named tuple containing time components.

```python
# Current time as struct_time
current_struct = time.localtime()
print(current_struct)
# time.struct_time(tm_year=2025, tm_mon=7, tm_mday=9, tm_hour=14, tm_min=20, tm_sec=34, tm_wday=2, tm_yday=190, tm_isdst=0)

# Access individual components
print(current_struct.tm_year)   # 2025
print(current_struct.tm_mon)    # 7
print(current_struct.tm_mday)   # 9
print(current_struct.tm_hour)   # 14
```

### Core Time Functions

#### time()

Returns current time as a floating-point number of seconds since epoch.

```python
start = time.time()
# Some operation
end = time.time()
duration = end - start
print(f"Operation took {duration:.4f} seconds")
```

#### sleep(seconds)

Suspends execution for the specified number of seconds.

```python
print("Starting...")
time.sleep(2)      # Sleep for 2 seconds
print("2 seconds later")

time.sleep(0.5)    # Sleep for 500 milliseconds
print("0.5 seconds later")
```

#### localtime(seconds)

Converts timestamp to local time struct_time.

```python
# Current local time
local_time = time.localtime()
print(local_time)

# Convert specific timestamp
timestamp = 1720497234
local_time = time.localtime(timestamp)
print(local_time)
```

#### gmtime(seconds)

Converts timestamp to UTC time struct_time.

```python
# Current UTC time
utc_time = time.gmtime()
print(utc_time)

# Convert specific timestamp to UTC
utc_time = time.gmtime(1720497234)
print(utc_time)
```

#### mktime(time_tuple)

Converts struct_time to timestamp.

```python
# Create a specific time
time_tuple = (2025, 7, 9, 14, 30, 0, 0, 0, 0)
timestamp = time.mktime(time_tuple)
print(timestamp)  # 1720497000.0
```

### Time Formatting and Parsing

#### strftime(format, time_tuple)

Formats time according to format string.

```python
# Current time formatting
now = time.localtime()
print(time.strftime("%Y-%m-%d %H:%M:%S", now))  # 2025-07-09 14:30:00
print(time.strftime("%A, %B %d, %Y", now))     # Wednesday, July 09, 2025
print(time.strftime("%I:%M %p", now))           # 02:30 PM

# Common format codes
formats = {
    "%Y": "Year with century (2025)",
    "%y": "Year without century (25)",
    "%m": "Month as number (07)",
    "%B": "Full month name (July)",
    "%b": "Abbreviated month (Jul)",
    "%d": "Day of month (09)",
    "%A": "Full weekday name (Wednesday)",
    "%a": "Abbreviated weekday (Wed)",
    "%H": "Hour 24-hour format (14)",
    "%I": "Hour 12-hour format (02)",
    "%M": "Minute (30)",
    "%S": "Second (00)",
    "%p": "AM/PM indicator"
}
```

#### strptime(string, format)

Parses time string according to format.

```python
# Parse date string
date_string = "2025-07-09 14:30:00"
parsed_time = time.strptime(date_string, "%Y-%m-%d %H:%M:%S")
print(parsed_time)

# Parse different formats
time_str = "July 9, 2025 2:30 PM"
parsed = time.strptime(time_str, "%B %d, %Y %I:%M %p")
print(parsed)
```

#### ctime(seconds)

Converts timestamp to readable string.

```python
print(time.ctime())           # Current time
print(time.ctime(1720497234)) # Wed Jul  9 14:20:34 2025
```

#### asctime(time_tuple)

Converts struct_time to readable string.

```python
current_time = time.localtime()
print(time.asctime(current_time))  # Wed Jul  9 14:30:00 2025
```

### Performance Measurement

#### Timing Code Execution

```python
import time

def time_function(func, *args, **kwargs):
    start = time.time()
    result = func(*args, **kwargs)
    end = time.time()
    print(f"Function took {end - start:.4f} seconds")
    return result

def slow_operation():
    time.sleep(1)
    return "Done"

result = time_function(slow_operation)
```

#### High-Resolution Timing

```python
# More precise timing using perf_counter
start = time.perf_counter()
# Some operation
end = time.perf_counter()
duration = end - start
print(f"High precision duration: {duration:.9f} seconds")
```

#### Process and Thread Time

```python
# CPU time spent by current process
process_time = time.process_time()
print(f"Process time: {process_time}")

# Thread time
thread_time = time.thread_time()
print(f"Thread time: {thread_time}")
```

### Time Zones and UTC

#### Working with UTC

```python
# Current UTC timestamp
utc_timestamp = time.time()
print(f"UTC timestamp: {utc_timestamp}")

# Convert to UTC struct_time
utc_struct = time.gmtime(utc_timestamp)
print(f"UTC time: {time.asctime(utc_struct)}")

# Convert to local time
local_struct = time.localtime(utc_timestamp)
print(f"Local time: {time.asctime(local_struct)}")
```

#### Time Zone Information

```python
# Get timezone information
print(f"Timezone: {time.tzname}")      # ('UTC', 'UTC') or ('EST', 'EDT')
print(f"Daylight saving: {time.daylight}")  # 0 or 1
print(f"Timezone offset: {time.timezone}")  # Seconds west of UTC
```

### Advanced Time Operations

#### Creating Custom Time Objects

```python
def create_time(year, month, day, hour=0, minute=0, second=0):
    """Create a timestamp from individual components"""
    time_tuple = (year, month, day, hour, minute, second, 0, 0, 0)
    return time.mktime(time_tuple)

# Create specific time
birthday = create_time(2025, 12, 25, 9, 30, 0)
print(f"Birthday timestamp: {birthday}")
print(f"Birthday: {time.ctime(birthday)}")
```

#### Time Calculations

```python
# Calculate days between dates
def days_between(date1, date2):
    """Calculate days between two date strings"""
    format_str = "%Y-%m-%d"
    time1 = time.mktime(time.strptime(date1, format_str))
    time2 = time.mktime(time.strptime(date2, format_str))
    return abs(time2 - time1) / (24 * 60 * 60)

days = days_between("2025-01-01", "2025-07-09")
print(f"Days between: {days}")
```

#### Time Intervals

```python
def format_duration(seconds):
    """Format seconds into human-readable duration"""
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    days, hours = divmod(hours, 24)
    
    parts = []
    if days:
        parts.append(f"{int(days)} days")
    if hours:
        parts.append(f"{int(hours)} hours")
    if minutes:
        parts.append(f"{int(minutes)} minutes")
    if seconds:
        parts.append(f"{int(seconds)} seconds")
    
    return ", ".join(parts)

duration = 90061  # seconds
print(format_duration(duration))  # 1 days, 1 hours, 1 minutes, 1 seconds
```

### Practical Applications

#### Scheduling and Delays

```python
def schedule_task(task_func, delay_seconds):
    """Schedule a task to run after a delay"""
    print(f"Task scheduled for {delay_seconds} seconds from now")
    time.sleep(delay_seconds)
    task_func()

def my_task():
    print("Task executed!")

schedule_task(my_task, 3)  # Run after 3 seconds
```

#### Rate Limiting

```python
class RateLimiter:
    def __init__(self, max_calls, time_window):
        self.max_calls = max_calls
        self.time_window = time_window
        self.calls = []
    
    def can_make_call(self):
        now = time.time()
        # Remove old calls outside the time window
        self.calls = [call_time for call_time in self.calls 
                     if now - call_time <= self.time_window]
        
        if len(self.calls) < self.max_calls:
            self.calls.append(now)
            return True
        return False

# Allow 5 calls per 10 seconds
limiter = RateLimiter(5, 10)
print(limiter.can_make_call())  # True
```

#### Timeout Implementation

```python
def timeout_function(func, timeout_seconds, *args, **kwargs):
    """Execute function with timeout"""
    import signal
    
    def timeout_handler(signum, frame):
        raise TimeoutError("Function timed out")
    
    # Set up timeout
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(int(timeout_seconds))
    
    try:
        result = func(*args, **kwargs)
        signal.alarm(0)  # Cancel timeout
        return result
    except TimeoutError:
        print("Function timed out!")
        return None
```

#### Logging with Timestamps

```python
def log_message(message, level="INFO"):
    """Log message with timestamp"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    print(f"[{timestamp}] {level}: {message}")

log_message("Application started")
time.sleep(1)
log_message("Processing data", "DEBUG")
log_message("Error occurred", "ERROR")
```

### Performance Monitoring

#### Execution Time Decorator

```python
import functools

def time_it(func):
    """Decorator to measure function execution time"""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

@time_it
def slow_function():
    time.sleep(0.5)
    return "Result"

result = slow_function()
```

#### Profiling Code Sections

```python
class Timer:
    def __init__(self):
        self.start_time = None
    
    def start(self):
        self.start_time = time.perf_counter()
    
    def stop(self):
        if self.start_time is None:
            raise ValueError("Timer not started")
        elapsed = time.perf_counter() - self.start_time
        self.start_time = None
        return elapsed
    
    def __enter__(self):
        self.start()
        return self
    
    def __exit__(self, *args):
        elapsed = self.stop()
        print(f"Elapsed time: {elapsed:.4f} seconds")

# Usage as context manager
with Timer():
    time.sleep(1)
    # Code to time
```

### Common Patterns

#### Retry with Backoff

```python
def retry_with_backoff(func, max_retries=3, base_delay=1):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            delay = base_delay * (2 ** attempt)
            print(f"Attempt {attempt + 1} failed, retrying in {delay}s")
            time.sleep(delay)
```

#### Periodic Task Execution

```python
def run_periodic_task(task_func, interval_seconds, duration_seconds=None):
    """Run task periodically"""
    start_time = time.time()
    
    while True:
        task_func()
        
        if duration_seconds and time.time() - start_time >= duration_seconds:
            break
        
        time.sleep(interval_seconds)

def heartbeat():
    print(f"Heartbeat at {time.strftime('%H:%M:%S')}")

# Run heartbeat every 5 seconds for 30 seconds
run_periodic_task(heartbeat, 5, 30)
```

### Cross-Platform Considerations

#### Sleep Precision

```python
# Sleep precision varies by platform
def precise_sleep(duration):
    """More precise sleep implementation"""
    start = time.perf_counter()
    while time.perf_counter() - start < duration:
        time.sleep(0.0001)  # Short sleep to avoid busy waiting
```

#### Platform-Specific Functions

```python
# Windows-specific high-resolution timer
try:
    # Windows
    time.clock()  # Deprecated in Python 3.8+
except AttributeError:
    # Use perf_counter instead
    pass

# Cross-platform monotonic time
monotonic_time = time.monotonic()  # Not affected by system clock adjustments
```

### Integration with Other Modules

#### DateTime Integration

```python
import datetime

# Convert between time and datetime
timestamp = time.time()
dt = datetime.datetime.fromtimestamp(timestamp)
back_to_timestamp = dt.timestamp()

# Time zone aware datetime
utc_dt = datetime.datetime.fromtimestamp(timestamp, tz=datetime.timezone.utc)
```

#### Threading with Time

```python
import threading
import time

def worker_with_timeout(work_func, timeout):
    """Run function in thread with timeout"""
    result = [None]
    exception = [None]
    
    def target():
        try:
            result[0] = work_func()
        except Exception as e:
            exception[0] = e
    
    thread = threading.Thread(target=target)
    thread.start()
    thread.join(timeout)
    
    if thread.is_alive():
        # Timeout occurred
        return None, "Timeout"
    
    return result[0], exception[0]
```

### Error Handling

#### Common Time-Related Errors

```python
try:
    # Invalid time string
    time.strptime("invalid", "%Y-%m-%d")
except ValueError as e:
    print(f"Parse error: {e}")

try:
    # Invalid timestamp
    time.localtime(-1)
except (ValueError, OSError) as e:
    print(f"Timestamp error: {e}")

try:
    # Timezone issues
    time.mktime((2025, 13, 32, 25, 61, 61, 0, 0, 0))  # Invalid values
except (ValueError, OverflowError) as e:
    print(f"Invalid time values: {e}")
```

**Key points**: The time module works with floating-point timestamps and struct_time objects, providing both low-level and high-level time operations. Understanding the difference between local time and UTC is crucial for global applications. The module's sleep function is essential for timing control, while formatting functions enable human-readable time representation. For more advanced time zone handling, consider using the datetime module or third-party libraries like pytz.

---

