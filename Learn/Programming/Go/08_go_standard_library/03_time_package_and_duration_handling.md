## time Package and Duration Handling


The `time` package provides functionality for measuring and displaying time, with support for timezones, formatting, and arithmetic operations.

**Core Types**

- `time.Time` - represents an instant in time
- `time.Duration` - represents elapsed time between two instants
- `time.Location` - represents timezone information

**Time Creation and Parsing**

- `time.Now()` - current time
- `time.Date()` - creates time from components
- `time.Parse()`, `time.ParseInLocation()` - parses formatted time strings
- `time.Unix()` - creates time from Unix timestamp

**Time Formatting** Go uses a reference time for formatting: `Mon Jan 2 15:04:05 MST 2006`

- `Format()` - converts time to string
- `String()` - default string representation
- Predefined formats: `time.RFC3339`, `time.Kitchen`, etc.

**Duration Operations** Duration represents nanoseconds as int64:

- Constants: `time.Nanosecond`, `time.Microsecond`, `time.Millisecond`, `time.Second`, `time.Minute`, `time.Hour`
- Methods: `Hours()`, `Minutes()`, `Seconds()`, `Nanoseconds()`
- Arithmetic: `Add()`, `Sub()`, multiplication/division with scalars

**Timers and Tickers**

- `time.Timer` - single event after duration
- `time.Ticker` - repeated events at intervals
- `time.Sleep()` - pauses execution
- `time.After()` - returns channel that receives after duration

**Timezone Handling**

- `time.LoadLocation()` - loads timezone data
- `time.UTC`, `time.Local` - predefined locations
- `In()` - converts time to different timezone

