# Winston

Winston is a multi-transport, asynchronous logging library for Node.js. It separates the concerns of log formatting, log levels, and log transport (destination), allowing each to be configured independently.

---

## Installation

```bash
npm install winston
```

---

## Basic Usage

```js
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
  ],
});

logger.info('Server started');
logger.warn('Low memory');
logger.error('Unhandled exception', { error: err.message });
```

---

## Log Levels

Winston uses npm log levels by default, ordered by severity (lower number = higher severity):

|Level|Value|
|---|---|
|`error`|0|
|`warn`|1|
|`info`|2|
|`http`|3|
|`verbose`|4|
|`debug`|5|
|`silly`|6|

The logger only emits messages at or above the configured `level`. Setting `level: 'info'` suppresses `http`, `verbose`, `debug`, and `silly`.

Each level is available as a method on the logger instance:

```js
logger.error('...');
logger.warn('...');
logger.info('...');
logger.debug('...');
```

### Custom Levels

```js
const logger = winston.createLogger({
  levels: {
    critical: 0,
    alert: 1,
    notice: 2,
    trace: 3,
  },
  level: 'notice',
  transports: [new winston.transports.Console()],
});

logger.critical('Database unreachable');
```

If using custom levels with colorization, register the colors separately:

```js
winston.addColors({
  critical: 'red',
  alert: 'yellow',
  notice: 'cyan',
  trace: 'white',
});
```

---

## createLogger Options

```js
winston.createLogger({
  level: 'info',              // minimum level to log
  levels: winston.config.npm.levels,  // level definitions
  format: winston.format.json(),      // format pipeline
  transports: [...],          // one or more transports
  exitOnError: false,         // whether to exit on uncaught exceptions logged
  silent: false,              // suppress all output when true
  defaultMeta: { service: 'api' },   // merged into every log entry
  exceptionHandlers: [...],   // transports for uncaught exceptions
  rejectionHandlers: [...],   // transports for unhandled promise rejections
});
```

---

## Formats

Formats are composable transformers applied to log entries before output. They live under `winston.format`.

### Built-in Formats

#### json

Serializes the log entry as JSON.

```js
format: winston.format.json()
```

Output:

```json
{"level":"info","message":"Server started","service":"api"}
```

#### simple

Human-readable single-line output.

```js
format: winston.format.simple()
```

Output:

```
info: Server started
```

#### prettyPrint

Pretty-prints the entire log object. Useful for development.

```js
format: winston.format.prettyPrint()
```

#### colorize

Adds ANSI color codes to level strings. Only meaningful for Console output.

```js
format: winston.format.colorize()
```

Options:

```js
winston.format.colorize({
  all: true,          // colorize entire message, not just level
  colors: {
    info: 'blue',
    error: 'red bold',
  },
});
```

#### timestamp

Adds a `timestamp` field to log entries.

```js
winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' })
```

Requires `date-fns` or similar only if you use advanced format strings; the default ISO format has no external dependency.

#### label

Adds a static `label` field.

```js
winston.format.label({ label: 'worker-1' })
```

#### printf

Defines a custom output string using a template function.

```js
winston.format.printf(({ level, message, timestamp, ...meta }) => {
  return `${timestamp} [${level}]: ${message} ${Object.keys(meta).length ? JSON.stringify(meta) : ''}`;
})
```

#### errors

Preserves stack traces when logging `Error` objects.

```js
winston.format.errors({ stack: true })
```

Without this, `logger.error(new Error('boom'))` may lose the stack.

#### splat

Enables `%s`, `%d`, `%o` style string interpolation in messages using `util.format` semantics.

```js
winston.format.splat()

logger.info('User %s logged in from %s', userId, ip);
```

#### metadata

Moves all extra fields into a nested `metadata` key.

```js
winston.format.metadata()
```

#### uncolorize

Strips ANSI color codes. Useful when piping colorized output into a file transport.

```js
winston.format.uncolorize()
```

---

### Combining Formats with combine

```js
const { combine, timestamp, label, printf, colorize, errors } = winston.format;

const logger = winston.createLogger({
  format: combine(
    errors({ stack: true }),
    label({ label: 'app' }),
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    printf(({ level, message, label, timestamp, stack }) => {
      return `${timestamp} [${label}] ${level}: ${stack || message}`;
    })
  ),
  transports: [new winston.transports.Console()],
});
```

Formats in `combine` are applied left to right. Order matters — `timestamp` must precede `printf` for the timestamp field to be available in the template.

---

### Custom Formats

```js
const { createLogger, format, transports } = require('winston');
const { combine, timestamp, printf } = format;

const redactSecrets = format((info) => {
  if (info.password) info.password = '[REDACTED]';
  if (info.token) info.token = '[REDACTED]';
  return info;
});

const logger = createLogger({
  format: combine(redactSecrets(), timestamp(), printf(({ level, message, timestamp }) => {
    return `${timestamp} ${level}: ${message}`;
  })),
  transports: [new transports.Console()],
});
```

Custom formats are created with `format(transformFn)`. The transform receives the `info` object and must return it (modified or unmodified) or return `false` to suppress the entry.

---

## Transports

Transports define where log output is written.

### Console

```js
new winston.transports.Console({
  level: 'debug',
  silent: false,
  stderrLevels: ['error'],   // write these levels to stderr instead of stdout
  consoleWarnLevels: ['warn'],
  format: winston.format.simple(),
})
```

### File

```js
new winston.transports.File({
  filename: 'logs/combined.log',
  level: 'info',
  maxsize: 5242880,     // 5MB — rotate after this size
  maxFiles: 5,          // keep at most 5 rotated files
  tailable: true,       // always write to the configured filename (not rotated names)
  zippedArchive: false, // gzip rotated files
  format: winston.format.json(),
})
```

Each transport can have its own `level` and `format`, independent of the logger-level settings.

### HTTP

Ships logs to an HTTP endpoint.

```js
new winston.transports.Http({
  host: 'logs.example.com',
  port: 443,
  path: '/ingest',
  ssl: true,
  auth: { bearer: process.env.LOG_TOKEN },
  level: 'warn',
})
```

### Stream

Writes to any writable Node.js stream.

```js
const fs = require('fs');

new winston.transports.Stream({
  stream: fs.createWriteStream('/var/log/app.log', { flags: 'a' }),
})
```

---

## Multiple Transports

```js
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'api' },
  transports: [
    new winston.transports.Console({
      level: 'debug',
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
  ],
});
```

The `error.log` file receives only `error`-level entries. `combined.log` receives everything at `info` and above (inherited from the logger-level setting).

---

## Logging Errors

Pass `Error` objects directly. Use `errors({ stack: true })` in the format pipeline to preserve stack traces.

```js
try {
  riskyOperation();
} catch (err) {
  logger.error('Operation failed', { error: err });
}

// or pass the Error as the first argument with errors() format enabled
logger.error(err);
```

Without `winston.format.errors({ stack: true })`, the stack trace is not included in output.

---

## Metadata and defaultMeta

All log calls accept a metadata object as the second argument:

```js
logger.info('Request received', { method: 'GET', path: '/api/users', userId: 42 });
```

`defaultMeta` merges into every entry automatically:

```js
const logger = winston.createLogger({
  defaultMeta: { service: 'payment-service', env: process.env.NODE_ENV },
  ...
});
```

---

## Child Loggers

Child loggers inherit the parent's configuration and merge additional metadata into every entry:

```js
const requestLogger = logger.child({ requestId: req.id, userId: req.user.id });

requestLogger.info('Processing request');
// → includes requestId and userId in every entry from this child
```

Child loggers are inexpensive to create and are well-suited for per-request or per-context scoping.

---

## Exception and Rejection Handling

### Uncaught Exceptions

```js
const logger = winston.createLogger({
  exceptionHandlers: [
    new winston.transports.File({ filename: 'logs/exceptions.log' }),
    new winston.transports.Console(),
  ],
});
```

Or attach to an existing logger:

```js
logger.exceptions.handle(
  new winston.transports.File({ filename: 'logs/exceptions.log' })
);
```

### Unhandled Promise Rejections

```js
const logger = winston.createLogger({
  rejectionHandlers: [
    new winston.transports.File({ filename: 'logs/rejections.log' }),
  ],
});
```

`exitOnError` (default `true`) causes the process to exit after an exception is logged. Set to `false` to suppress this:

```js
winston.createLogger({ exitOnError: false, ... });
```

[Inference — suppressing `exitOnError` in production should be deliberate; Node.js behavior after an uncaught exception is not guaranteed to be stable.]

---

## Dynamic Level Changes

The logger's level can be changed at runtime:

```js
logger.level = 'debug';
```

Per-transport levels can also be changed:

```js
logger.transports[0].level = 'silly';
```

---

## Adding and Removing Transports at Runtime

```js
const fileTransport = new winston.transports.File({ filename: 'logs/combined.log' });

logger.add(fileTransport);
logger.remove(fileTransport);
```

---

## Querying Logs

The File transport supports querying logged entries (requires the file to be in JSON format):

```js
logger.query(
  {
    from: new Date(Date.now() - 24 * 60 * 60 * 1000),
    until: new Date(),
    limit: 100,
    start: 0,
    order: 'desc',
    fields: ['message', 'level', 'timestamp'],
  },
  (err, results) => {
    if (err) throw err;
    console.log(results);
  }
);
```

---

## Streaming Logs

Read log entries as a stream from a transport:

```js
const stream = logger.stream({ start: -1 });

stream.on('log', (log) => {
  console.log(log);
});
```

`start: -1` begins from the last entry.

---

## Third-Party Transports

Winston has an ecosystem of community transports. Common ones include:

|Package|Destination|
|---|---|
|`winston-mongodb`|MongoDB|
|`winston-elasticsearch`|Elasticsearch|
|`winston-cloudwatch`|AWS CloudWatch Logs|
|`winston-loggly-bulk`|Loggly|
|`winston-syslog`|Syslog (RFC 5424)|
|`winston-daily-rotate-file`|File with daily rotation|
|`@google-cloud/logging-winston`|Google Cloud Logging|

[Unverified — package availability and maintenance status change over time; verify on npmjs.com before use.]

### Daily Rotating Files

```bash
npm install winston-daily-rotate-file
```

```js
const DailyRotateFile = require('winston-daily-rotate-file');

new DailyRotateFile({
  filename: 'logs/application-%DATE%.log',
  datePattern: 'YYYY-MM-DD',
  zippedArchive: true,
  maxSize: '20m',
  maxFiles: '14d',   // keep 14 days of logs
})
```

---

## Writing a Custom Transport

Extend `winston-transport`:

```js
const Transport = require('winston-transport');

class CustomTransport extends Transport {
  constructor(opts) {
    super(opts);
    // initialization
  }

  log(info, callback) {
    setImmediate(() => this.emit('logged', info));

    // write info somewhere
    myExternalSystem.send(info);

    callback();
  }
}
```

The `log` method receives the formatted `info` object and a `callback` that must be called when done.

---

## Integration with Express

Use `morgan` to generate HTTP request logs and pipe them into Winston:

```bash
npm install morgan
```

```js
const morgan = require('morgan');
const winston = require('winston');

const logger = winston.createLogger({
  level: 'http',
  format: winston.format.json(),
  transports: [new winston.transports.Console()],
});

const morganStream = {
  write: (message) => logger.http(message.trim()),
};

app.use(morgan('combined', { stream: morganStream }));
```

---

## Profiling

Winston includes a built-in profiler:

```js
logger.profile('db-query');

// ... perform operation ...

logger.profile('db-query');
// → logs duration between the two calls
```

Manual timing via `startTimer`:

```js
const profiler = logger.startTimer();

// ... perform operation ...

profiler.done({ message: 'DB query completed', query: sql });
```

---

## Silencing the Logger

```js
logger.silent = true;   // suppress all output
logger.silent = false;  // restore output
```

Useful in test environments to suppress log noise without removing logger calls from application code.

---

## Common Mistakes

**Not including `errors({ stack: true })` in the format.** Error stack traces are silently dropped without it.

**Using `colorize` with file transports.** ANSI escape codes corrupt log files. Apply `colorize` only to Console transports, or strip with `uncolorize` before writing to file.

**Setting logger-level to `error` in development.** Suppresses all non-error output, making debugging difficult. Use environment-conditional level configuration:

```js
level: process.env.NODE_ENV === 'production' ? 'warn' : 'debug'
```

**Sharing a single logger instance with no child scoping.** Log entries lack per-request context, making it difficult to correlate entries. Use `logger.child()` per request.

**Logging large objects directly.** Circular references or deeply nested objects can cause `JSON.stringify` to throw or produce enormous output. Sanitize before logging.

**Not handling transport errors.** Transport streams can fail (disk full, network down). Attach error handlers:

```js
const fileTransport = new winston.transports.File({ filename: 'app.log' });
fileTransport.on('error', (err) => { /* handle */ });
```

---

## Reference

- Repository: [github.com/winstonjs/winston](https://github.com/winstonjs/winston)
- Transport list: [github.com/winstonjs/winston/blob/master/docs/transports.md](https://github.com/winstonjs/winston/blob/master/docs/transports.md)
- `winston-transport`: [github.com/winstonjs/winston-transport](https://github.com/winstonjs/winston-transport)