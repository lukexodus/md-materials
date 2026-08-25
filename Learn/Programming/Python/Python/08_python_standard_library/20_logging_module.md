## `logging` Module


### Overview

The Python logging module is a built-in library that provides a flexible framework for emitting log messages from Python programs. It's part of the standard library since Python 2.3 and offers a sophisticated system for capturing, filtering, formatting, and outputting diagnostic information.

### Core Components

#### Loggers

Loggers are the primary interface for application code. They expose methods that applications use directly and determine which log messages to process based on severity levels.

- **Root Logger**: The parent of all loggers, created automatically
- **Named Loggers**: Created using `logging.getLogger(name)`
- **Logger Hierarchy**: Uses dot notation (e.g., 'myapp.module1.submodule')

#### Handlers

Handlers determine where log messages go. Multiple handlers can be attached to a single logger.

- **StreamHandler**: Outputs to streams (stdout, stderr)
- **FileHandler**: Writes to files
- **RotatingFileHandler**: Rotates files based on size
- **TimedRotatingFileHandler**: Rotates files based on time intervals
- **HTTPHandler**: Sends logs via HTTP
- **SMTPHandler**: Emails log messages
- **SysLogHandler**: Sends to system logging daemon
- **NTEventLogHandler**: Windows Event Log (Windows only)

#### Formatters

Formatters specify the layout of log records in the final output.

**Key attributes:**

- `%(name)s`: Logger name
- `%(levelname)s`: Log level name
- `%(message)s`: The logged message
- `%(asctime)s`: Timestamp
- `%(filename)s`: Source filename
- `%(lineno)d`: Line number
- `%(funcName)s`: Function name

#### Filters

Filters provide fine-grained control over which log records are processed.

### Log Levels

Python logging defines five standard levels:

- **DEBUG (10)**: Detailed diagnostic information
- **INFO (20)**: General information about program execution
- **WARNING (30)**: Something unexpected happened or potential problems
- **ERROR (40)**: Serious problems that prevented a function from executing
- **CRITICAL (50)**: Very serious errors that may abort the program

### Basic Usage

#### Simple Logging

```python
import logging

# Basic configuration
logging.basicConfig(level=logging.INFO)

# Log messages
logging.debug('This is a debug message')
logging.info('This is an info message')
logging.warning('This is a warning message')
logging.error('This is an error message')
logging.critical('This is a critical message')
```

#### Creating Custom Loggers

```python
import logging

# Create logger
logger = logging.getLogger('my_app')
logger.setLevel(logging.DEBUG)

# Create handler
handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)

# Create formatter
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

# Add handler to logger
logger.addHandler(handler)

# Use logger
logger.info('Custom logger message')
```

### Configuration Methods

#### Basic Configuration

`logging.basicConfig()` provides quick setup for simple logging needs:

```python
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='app.log',
    filemode='a'
)
```

#### Dictionary Configuration

```python
import logging.config

config = {
    'version': 1,
    'formatters': {
        'default': {
            'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'default',
        },
    },
    'root': {
        'level': 'INFO',
        'handlers': ['console'],
    },
}

logging.config.dictConfig(config)
```

#### File-Based Configuration

Configuration can be loaded from INI or YAML files using `logging.config.fileConfig()`.

### Advanced Features

#### Log Rotation

```python
import logging
from logging.handlers import RotatingFileHandler

# Size-based rotation
handler = RotatingFileHandler('app.log', maxBytes=1024*1024, backupCount=5)

# Time-based rotation
from logging.handlers import TimedRotatingFileHandler
handler = TimedRotatingFileHandler('app.log', when='midnight', interval=1, backupCount=7)
```

#### Custom Filters

```python
class SpecificFilter(logging.Filter):
    def filter(self, record):
        return 'specific_keyword' in record.getMessage()

logger.addFilter(SpecificFilter())
```

#### Context Information

```python
# Using extra parameter
logger.info('User action', extra={'user_id': 123, 'action': 'login'})

# Using LoggerAdapter
adapter = logging.LoggerAdapter(logger, {'user_id': 123})
adapter.info('User performed action')
```

#### Exception Logging

```python
try:
    risky_operation()
except Exception:
    logger.exception('An error occurred')  # Includes traceback
    # or
    logger.error('An error occurred', exc_info=True)
```

### Performance Considerations

#### Lazy Evaluation

```python
# Inefficient - string formatting happens even if not logged
logger.debug('Value: ' + str(expensive_operation()))

# Efficient - formatting only happens if logged
logger.debug('Value: %s', expensive_operation())
```

#### Conditional Logging

```python
if logger.isEnabledFor(logging.DEBUG):
    logger.debug('Expensive debug info: %s', compute_expensive_info())
```

### Threading Considerations

The logging module is thread-safe by default. All handlers use locks to ensure thread safety, but this can impact performance in high-throughput applications.

**Key points:**

- Default handlers are thread-safe
- Custom handlers should implement proper locking
- QueueHandler can be used for better performance in multi-threaded applications

### Best Practices

#### Logger Naming

```python
# Use module's __name__ for automatic hierarchy
logger = logging.getLogger(__name__)

# Results in hierarchical names like:
# myproject.module1
# myproject.module1.submodule
```

#### Configuration Management

- Configure logging once at application startup
- Use configuration files for production environments
- Separate configuration from application code

#### Log Message Format

- Include relevant context (timestamp, level, module)
- Use structured logging for machine parsing
- Avoid logging sensitive information

#### Error Handling

```python
# Don't let logging errors crash your application
try:
    logger.info('Operation completed')
except Exception:
    pass  # Or use a fallback logging mechanism
```

### Integration with Other Libraries

#### With Web Frameworks

```python
# Flask example
from flask import Flask
import logging

app = Flask(__name__)
app.logger.setLevel(logging.INFO)

# Django uses Python logging by default
```

#### With Third-Party Libraries

Many libraries use Python logging:

- **Requests**: HTTP library logging
- **SQLAlchemy**: Database query logging
- **Celery**: Task queue logging

### Structured Logging

#### JSON Logging

```python
import json
import logging

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': self.formatTime(record),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
        }
        return json.dumps(log_entry)
```

### Common Patterns

#### Module-Level Logger

```python
import logging

logger = logging.getLogger(__name__)

def my_function():
    logger.info('Function called')
```

#### Contextual Logging

```python
import logging
from contextlib import contextmanager

@contextmanager
def log_context(logger, message):
    logger.info(f'Starting: {message}')
    try:
        yield
    finally:
        logger.info(f'Finished: {message}')

# Usage
with log_context(logger, 'database operation'):
    perform_database_operation()
```

### Troubleshooting

#### Common Issues

- **No output**: Check log levels and handler configuration
- **Duplicate messages**: Multiple handlers or propagation issues
- **Performance problems**: Excessive logging or inefficient formatters
- **Unicode errors**: Encoding issues with file handlers

#### Debugging Logging Configuration

```python
# Enable logging module's own debug output
logging.basicConfig(level=logging.DEBUG)
logging.getLogger().debug('Test message')

# Print current logger configuration
for name, logger in logging.Logger.manager.loggerDict.items():
    print(f'Logger: {name}, Level: {logger.level if hasattr(logger, "level") else "Not set"}')
```

### Testing Considerations

#### Capturing Logs in Tests

```python
import logging
import unittest
from unittest.mock import patch

class TestLogging(unittest.TestCase):
    def test_logging_output(self):
        with patch('logging.Logger.info') as mock_info:
            my_function_that_logs()
            mock_info.assert_called_with('Expected message')
```

### Security Considerations

- Avoid logging sensitive data (passwords, tokens, personal information)
- Sanitize user input before logging
- Consider log file permissions and storage security
- Be aware of log injection attacks

**Key points:**

- Log rotation prevents disk space issues
- Structured logging aids in log analysis
- Proper configuration separation improves maintainability
- Thread safety is handled automatically for standard handlers

---

