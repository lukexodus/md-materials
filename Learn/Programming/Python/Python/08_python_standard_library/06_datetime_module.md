## `datetime` Module


### Overview

The datetime module is a built-in Python library that provides classes for manipulating dates and times. It offers comprehensive functionality for parsing, formatting, arithmetic operations, and timezone handling with date and time values. The module is designed to be more intuitive and feature-rich than the older time module.

### Importing the Datetime Module

```python
import datetime
from datetime import datetime, date, time, timedelta, timezone
```

### Core Classes

#### datetime.datetime

Represents a specific moment in time with date and time components.

```python
from datetime import datetime

# Create datetime objects
now = datetime.now()
specific_time = datetime(2023, 12, 25, 15, 30, 45)
print(specific_time)  # 2023-12-25 15:30:45
```

#### datetime.date

Represents a date (year, month, day) without time information.

```python
from datetime import date

# Create date objects
today = date.today()
specific_date = date(2023, 12, 25)
print(specific_date)  # 2023-12-25
```

#### datetime.time

Represents a time (hour, minute, second, microsecond) without date information.

```python
from datetime import time

# Create time objects
specific_time = time(15, 30, 45)
with_microseconds = time(15, 30, 45, 123456)
print(specific_time)  # 15:30:45
```

#### datetime.timedelta

Represents a duration, the difference between two dates or times.

```python
from datetime import timedelta

# Create timedelta objects
one_week = timedelta(weeks=1)
mixed_duration = timedelta(days=5, hours=3, minutes=30)
print(one_week)  # 7 days, 0:00:00
```

#### datetime.timezone

Represents timezone information.

```python
from datetime import timezone, timedelta

# Create timezone objects
utc = timezone.utc
eastern = timezone(timedelta(hours=-5))
```

### Creating Datetime Objects

#### Current Date and Time

```python
from datetime import datetime, date, time

# Current date and time
now = datetime.now()
today = date.today()
current_time = datetime.now().time()
```

#### Specific Date and Time

```python
# Various ways to create datetime objects
specific_datetime = datetime(2023, 12, 25, 15, 30, 45)
from_date_and_time = datetime.combine(date(2023, 12, 25), time(15, 30, 45))
```

#### From Timestamps

```python
import time
from datetime import datetime

# From Unix timestamp
timestamp = time.time()
from_timestamp = datetime.fromtimestamp(timestamp)
utc_from_timestamp = datetime.utcfromtimestamp(timestamp)
```

#### From ISO Format

```python
from datetime import datetime

# From ISO 8601 format
iso_string = "2023-12-25T15:30:45"
from_iso = datetime.fromisoformat(iso_string)
```

### Formatting and Parsing

#### strftime() - Format to String

```python
from datetime import datetime

dt = datetime(2023, 12, 25, 15, 30, 45)

# Common format codes
formatted = dt.strftime("%Y-%m-%d %H:%M:%S")  # 2023-12-25 15:30:45
date_only = dt.strftime("%Y-%m-%d")           # 2023-12-25
time_only = dt.strftime("%H:%M:%S")           # 15:30:45
readable = dt.strftime("%B %d, %Y at %I:%M %p")  # December 25, 2023 at 03:30 PM
```

#### Format Codes Reference

```python
# Common format codes
codes = {
    "%Y": "4-digit year",
    "%y": "2-digit year",
    "%m": "Month as number (01-12)",
    "%B": "Full month name",
    "%b": "Abbreviated month name",
    "%d": "Day of month (01-31)",
    "%H": "Hour (00-23)",
    "%I": "Hour (01-12)",
    "%M": "Minute (00-59)",
    "%S": "Second (00-59)",
    "%p": "AM/PM",
    "%A": "Full weekday name",
    "%a": "Abbreviated weekday name",
    "%w": "Weekday as number (0-6)",
    "%z": "UTC offset",
    "%Z": "Timezone name"
}
```

#### strptime() - Parse from String

```python
from datetime import datetime

# Parse various formats
date_string = "2023-12-25 15:30:45"
parsed = datetime.strptime(date_string, "%Y-%m-%d %H:%M:%S")

# Different format
date_string2 = "December 25, 2023"
parsed2 = datetime.strptime(date_string2, "%B %d, %Y")
```

### Date and Time Arithmetic

#### Using timedelta

```python
from datetime import datetime, timedelta

now = datetime.now()

# Add time
future = now + timedelta(days=7, hours=3, minutes=30)
past = now - timedelta(weeks=2)

# More complex operations
next_month = now + timedelta(days=30)
in_one_year = now + timedelta(days=365)
```

#### Duration Between Dates

```python
from datetime import datetime, date

# Calculate differences
start_date = datetime(2023, 1, 1)
end_date = datetime(2023, 12, 31)
difference = end_date - start_date
print(difference.days)  # 364
print(difference.total_seconds())  # 31,449,600
```

#### Timedelta Operations

```python
from datetime import timedelta

# Create timedelta objects
one_week = timedelta(weeks=1)
one_day = timedelta(days=1)
one_hour = timedelta(hours=1)

# Arithmetic operations
combined = one_week + one_day + one_hour
multiplied = one_day * 7
divided = one_week / 7
```

### Working with Dates

#### Date Attributes and Methods

```python
from datetime import date

today = date.today()
specific_date = date(2023, 12, 25)

# Attributes
print(today.year)     # 2023
print(today.month)    # Current month
print(today.day)      # Current day

# Methods
print(today.weekday())     # Monday is 0, Sunday is 6
print(today.isoweekday())  # Monday is 1, Sunday is 7
print(today.strftime("%A"))  # Full weekday name
```

#### Date Comparison

```python
from datetime import date

date1 = date(2023, 12, 25)
date2 = date(2023, 12, 31)

# Comparison operations
print(date1 < date2)   # True
print(date1 == date2)  # False
print(date1 > date2)   # False
```

#### Date Arithmetic

```python
from datetime import date, timedelta

today = date.today()
tomorrow = today + timedelta(days=1)
last_week = today - timedelta(weeks=1)

# Calculate age
birth_date = date(1990, 5, 15)
age = today - birth_date
print(f"Age in days: {age.days}")
```

### Working with Time

#### Time Attributes and Methods

```python
from datetime import time

specific_time = time(15, 30, 45, 123456)

# Attributes
print(specific_time.hour)        # 15
print(specific_time.minute)      # 30
print(specific_time.second)      # 45
print(specific_time.microsecond) # 123456
```

#### Time Comparison

```python
from datetime import time

time1 = time(9, 30)
time2 = time(17, 45)

print(time1 < time2)  # True
print(time1.strftime("%I:%M %p"))  # 09:30 AM
```

### Working with Datetime

#### Datetime Attributes and Methods

```python
from datetime import datetime

dt = datetime(2023, 12, 25, 15, 30, 45, 123456)

# Date components
print(dt.year, dt.month, dt.day)

# Time components
print(dt.hour, dt.minute, dt.second, dt.microsecond)

# Extract date and time
date_part = dt.date()
time_part = dt.time()
```

#### Datetime Arithmetic

```python
from datetime import datetime, timedelta

now = datetime.now()

# Add/subtract time
future = now + timedelta(days=30, hours=5)
past = now - timedelta(weeks=2, days=3)

# Calculate duration
event_time = datetime(2023, 12, 25, 18, 0)
time_until_event = event_time - now
```

### Timezone Handling

#### Creating Timezone-Aware Objects

```python
from datetime import datetime, timezone, timedelta

# UTC timezone
utc_time = datetime.now(timezone.utc)

# Custom timezone
est = timezone(timedelta(hours=-5))
est_time = datetime.now(est)

# From timestamp with timezone
import time
timestamp = time.time()
aware_dt = datetime.fromtimestamp(timestamp, tz=timezone.utc)
```

#### Converting Between Timezones

```python
from datetime import datetime, timezone, timedelta

# Create timezone-aware datetime
utc = timezone.utc
eastern = timezone(timedelta(hours=-5))
pacific = timezone(timedelta(hours=-8))

# UTC time
utc_time = datetime.now(utc)

# Convert to other timezones
eastern_time = utc_time.astimezone(eastern)
pacific_time = utc_time.astimezone(pacific)
```

#### Working with pytz (Third-party library)

```python
# Note: pytz is not built-in, requires installation
import pytz
from datetime import datetime

# Create timezone-aware datetime with pytz
utc = pytz.UTC
eastern = pytz.timezone('US/Eastern')
pacific = pytz.timezone('US/Pacific')

# Localize naive datetime
naive_dt = datetime(2023, 12, 25, 15, 30)
localized = eastern.localize(naive_dt)

# Convert between timezones
pacific_time = localized.astimezone(pacific)
```

### Advanced Operations

#### Working with Weekdays

```python
from datetime import datetime, timedelta

def get_next_weekday(date, weekday):
    """Get the next occurrence of a specific weekday"""
    days_ahead = weekday - date.weekday()
    if days_ahead <= 0:
        days_ahead += 7
    return date + timedelta(days_ahead)

# Get next Monday (0 = Monday)
today = datetime.now()
next_monday = get_next_weekday(today, 0)
```

#### Month and Year Operations

```python
from datetime import datetime, timedelta
import calendar

def add_months(date, months):
    """Add months to a date"""
    month = date.month - 1 + months
    year = date.year + month // 12
    month = month % 12 + 1
    day = min(date.day, calendar.monthrange(year, month)[1])
    return date.replace(year=year, month=month, day=day)

# Add 3 months to current date
current_date = datetime.now()
future_date = add_months(current_date, 3)
```

#### Business Day Calculations

```python
from datetime import datetime, timedelta

def add_business_days(date, business_days):
    """Add business days (excluding weekends)"""
    while business_days > 0:
        date += timedelta(days=1)
        if date.weekday() < 5:  # Monday to Friday
            business_days -= 1
    return date

# Add 5 business days
start_date = datetime(2023, 12, 20)
end_date = add_business_days(start_date, 5)
```

### Practical Examples

#### Age Calculator

```python
from datetime import date

def calculate_age(birth_date):
    """Calculate age in years"""
    today = date.today()
    age = today.year - birth_date.year
    
    # Check if birthday has occurred this year
    if (today.month, today.day) < (birth_date.month, birth_date.day):
        age -= 1
    
    return age

# Example usage
birth_date = date(1990, 5, 15)
age = calculate_age(birth_date)
print(f"Age: {age} years")
```

#### Date Range Generator

```python
from datetime import datetime, timedelta

def date_range(start_date, end_date, step=timedelta(days=1)):
    """Generate dates between start and end"""
    current = start_date
    while current < end_date:
        yield current
        current += step

# Generate all dates in a month
start = datetime(2023, 12, 1)
end = datetime(2023, 12, 31)
for date in date_range(start, end):
    print(date.strftime("%Y-%m-%d"))
```

#### Working Hours Calculator

```python
from datetime import datetime, timedelta

def calculate_working_hours(start_date, end_date, work_start=9, work_end=17):
    """Calculate working hours between two dates"""
    total_hours = 0
    current = start_date
    
    while current.date() <= end_date.date():
        # Skip weekends
        if current.weekday() < 5:
            if current.date() == start_date.date():
                # First day - use actual start time
                work_start_time = max(current.time(), datetime.min.time().replace(hour=work_start))
            else:
                work_start_time = datetime.min.time().replace(hour=work_start)
            
            if current.date() == end_date.date():
                # Last day - use actual end time
                work_end_time = min(end_date.time(), datetime.min.time().replace(hour=work_end))
            else:
                work_end_time = datetime.min.time().replace(hour=work_end)
            
            # Calculate hours for this day
            if work_end_time > work_start_time:
                day_hours = (datetime.combine(current.date(), work_end_time) - 
                           datetime.combine(current.date(), work_start_time)).total_seconds() / 3600
                total_hours += max(0, min(8, day_hours))
        
        current += timedelta(days=1)
    
    return total_hours
```

#### Recurring Event Generator

```python
from datetime import datetime, timedelta

def generate_recurring_events(start_date, recurrence_pattern, count=10):
    """Generate recurring events"""
    events = []
    current_date = start_date
    
    for i in range(count):
        events.append(current_date)
        
        if recurrence_pattern == 'daily':
            current_date += timedelta(days=1)
        elif recurrence_pattern == 'weekly':
            current_date += timedelta(weeks=1)
        elif recurrence_pattern == 'monthly':
            # Simple monthly (same day of month)
            if current_date.month == 12:
                current_date = current_date.replace(year=current_date.year + 1, month=1)
            else:
                current_date = current_date.replace(month=current_date.month + 1)
    
    return events
```

### Error Handling

#### Common Exceptions

```python
from datetime import datetime, date

# ValueError - Invalid date/time values
try:
    invalid_date = date(2023, 13, 1)  # Invalid month
except ValueError as e:
    print(f"Error: {e}")

# TypeError - Wrong type
try:
    result = datetime.now() + 5  # Can't add int to datetime
except TypeError as e:
    print(f"Error: {e}")

# AttributeError - Invalid attribute
try:
    d = date.today()
    print(d.hour)  # date objects don't have hour attribute
except AttributeError as e:
    print(f"Error: {e}")
```

#### Safe Date Operations

```python
from datetime import datetime, date
import calendar

def safe_date_create(year, month, day):
    """Safely create a date, handling invalid days"""
    try:
        return date(year, month, day)
    except ValueError:
        # Use last valid day of month
        last_day = calendar.monthrange(year, month)[1]
        return date(year, month, min(day, last_day))

def safe_parse_date(date_string, format_string):
    """Safely parse date string"""
    try:
        return datetime.strptime(date_string, format_string)
    except ValueError as e:
        print(f"Unable to parse date: {e}")
        return None
```

### Performance Considerations

#### Efficient Date Operations

```python
from datetime import datetime, date

# Use date objects for date-only operations
today = date.today()  # More efficient than datetime.now().date()

# Cache expensive operations
import functools

@functools.lru_cache(maxsize=128)
def get_first_day_of_month(year, month):
    return date(year, month, 1)

# Use comparison instead of conversion when possible
def is_weekend(date_obj):
    return date_obj.weekday() >= 5  # More efficient than string comparison
```

#### Memory-Efficient Date Iteration

```python
from datetime import date, timedelta

def efficient_date_range(start_date, end_date):
    """Memory-efficient date generator"""
    current = start_date
    while current <= end_date:
        yield current
        current += timedelta(days=1)

# Use generator instead of creating list
for date in efficient_date_range(date(2023, 1, 1), date(2023, 12, 31)):
    # Process date without storing all dates in memory
    pass
```

### Integration with Other Libraries

#### With JSON

```python
import json
from datetime import datetime

# Custom JSON encoder for datetime
class DateTimeEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

# Usage
data = {'timestamp': datetime.now()}
json_string = json.dumps(data, cls=DateTimeEncoder)
```

#### With Pandas

```python
import pandas as pd
from datetime import datetime

# Create pandas Series with datetime
dates = pd.date_range(start='2023-01-01', end='2023-12-31', freq='D')
df = pd.DataFrame({'date': dates})

# Convert datetime objects to pandas
py_dates = [datetime(2023, 1, 1), datetime(2023, 1, 2)]
df_from_py = pd.DataFrame({'date': pd.to_datetime(py_dates)})
```

### Best Practices

#### Code Organization

```python
from datetime import datetime, timezone
import pytz

class DateTimeHelper:
    """Helper class for common datetime operations"""
    
    @staticmethod
    def now_utc():
        """Get current UTC time"""
        return datetime.now(timezone.utc)
    
    @staticmethod
    def format_for_display(dt):
        """Format datetime for user display"""
        return dt.strftime("%B %d, %Y at %I:%M %p")
    
    @staticmethod
    def parse_iso(iso_string):
        """Parse ISO format string safely"""
        try:
            return datetime.fromisoformat(iso_string)
        except ValueError:
            return None
```

#### Configuration Management

```python
from datetime import datetime, timezone

class Config:
    DEFAULT_TIMEZONE = timezone.utc
    DATE_FORMAT = "%Y-%m-%d"
    DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
    DISPLAY_FORMAT = "%B %d, %Y at %I:%M %p"

def format_date(dt, format_type='default'):
    """Format date according to configuration"""
    formats = {
        'default': Config.DATE_FORMAT,
        'datetime': Config.DATETIME_FORMAT,
        'display': Config.DISPLAY_FORMAT
    }
    return dt.strftime(formats.get(format_type, Config.DATE_FORMAT))
```

**Key points:** The datetime module provides comprehensive date and time handling capabilities with separate classes for dates, times, and combined datetime objects. It offers robust parsing and formatting options, timezone support, and arithmetic operations. The module is essential for any application that needs to work with temporal data, from simple date calculations to complex timezone-aware applications.

**Next steps:** For more advanced timezone handling, consider using the zoneinfo module (Python 3.9+) or the pytz library. For high-performance date operations with large datasets, explore pandas' datetime functionality. For more complex date parsing, investigate the dateutil library.

---

