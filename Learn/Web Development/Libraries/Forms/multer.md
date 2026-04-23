# Comprehensive Guide to Multer

`multer` is a Node.js middleware for handling `multipart/form-data`, which is the encoding type used when uploading files via HTML forms or HTTP clients. It is built on top of `busboy` and integrates directly with Express.

> **Scope note:** Multer only processes requests with `Content-Type: multipart/form-data`. It does nothing for other content types such as `application/json` or `application/x-www-form-urlencoded`.

---

## Installation

```bash
npm install multer
```

Multer has no required peer dependencies beyond a compatible version of Node.js and Express (or a Connect-compatible framework).

---

## How Multer Works

When a `multipart/form-data` request arrives, Multer parses the request body and separates it into:

- **File fields** — binary file data, exposed on `req.file` (single) or `req.files` (multiple)
- **Non-file fields** — text values, exposed on `req.body`

Multer does not process the request at all unless you attach it as middleware to a route.

---

## Storage Engines

Multer requires you to choose where uploaded files go. There are two built-in options.

### DiskStorage

Saves files to the local filesystem. You control the destination directory and filename.

```js
const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/");
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, uniqueName);
  },
});

const upload = multer({ storage });
```

Both `destination` and `filename` are functions that receive:

- `req` — the Express request object
- `file` — the file object (described below)
- `cb` — a Node-style callback: `cb(error, value)`

#### `destination`

Can also be a string instead of a function:

```js
multer.diskStorage({ destination: "uploads/" })
```

> **Important:** Multer does not create the destination directory if it does not exist. You must ensure the directory is present before the middleware runs.

#### `filename`

If omitted, Multer generates a random name with no file extension. You are responsible for constructing a safe and unique filename.

> **Security note:** Never use `file.originalname` as the stored filename without sanitization. User-controlled filenames can contain path traversal sequences (e.g., `../../etc/passwd`) or overwrite existing files.

### MemoryStorage

Stores files in memory as `Buffer` objects on `file.buffer`. No files are written to disk.

```js
const upload = multer({ storage: multer.memoryStorage() });
```

Use this when you intend to immediately process or forward the file (e.g., upload to S3, run through an image pipeline) without persisting it locally.

> **Caution:** Large files or high concurrency can exhaust available memory. Always set `limits` when using `memoryStorage`.

---

## Basic Usage

### Single File

```js
app.post("/upload", upload.single("avatar"), (req, res) => {
  console.log(req.file);   // the uploaded file
  console.log(req.body);   // other form fields
  res.json({ file: req.file });
});
```

`upload.single(fieldname)` accepts one file from the field named `fieldname`. The file is available on `req.file`.

### Multiple Files from One Field

```js
app.post("/photos", upload.array("photos", 5), (req, res) => {
  console.log(req.files); // array of file objects
});
```

`upload.array(fieldname, maxCount)` accepts up to `maxCount` files from a single field. Files are on `req.files`.

### Multiple Files from Multiple Fields

```js
app.post(
  "/mixed",
  upload.fields([
    { name: "avatar", maxCount: 1 },
    { name: "gallery", maxCount: 8 },
  ]),
  (req, res) => {
    console.log(req.files["avatar"]);
    console.log(req.files["gallery"]);
  }
);
```

`req.files` is an object keyed by field name, each value being an array of file objects.

### No Files — Text Fields Only

```js
app.post("/profile", upload.none(), (req, res) => {
  console.log(req.body); // only non-file fields
});
```

Use `upload.none()` when the request is `multipart/form-data` but contains no file fields. If a file is included when `none()` is used, Multer throws an error.

### Accept Any Files

```js
app.post("/any", upload.any(), (req, res) => {
  console.log(req.files); // all uploaded files regardless of field name
});
```

> **Security note:** `upload.any()` accepts files from any field without restriction. Use it only when you explicitly trust or validate all input downstream.

---

## The File Object

Each parsed file object has these properties:

|Property|Description|
|---|---|
|`fieldname`|The form field name|
|`originalname`|The filename as provided by the client|
|`encoding`|Encoding type of the file (e.g., `7bit`)|
|`mimetype`|MIME type as reported by the client|
|`size`|File size in bytes|
|`destination`|Directory where the file was saved (DiskStorage only)|
|`filename`|The name the file was saved as (DiskStorage only)|
|`path`|Full path to the saved file (DiskStorage only)|
|`buffer`|The file data as a `Buffer` (MemoryStorage only)|

> **Important:** `mimetype` and `originalname` come from the client and are not verified by Multer. Do not trust them for security decisions without independent validation.

---

## Limits

You can restrict upload sizes and counts to prevent abuse:

```js
const upload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,  // 5 MB per file
    files: 10,                   // max 10 files per request
    fields: 20,                  // max 20 non-file fields
    fieldNameSize: 100,          // max field name length in bytes
    fieldSize: 1024 * 1024,      // max non-file field value size (1 MB)
    parts: 30,                   // max total parts (files + fields)
    headerPairs: 2000,           // max header key-value pairs
  },
});
```

All limit values are in bytes unless noted. All are optional.

When a limit is exceeded, Multer emits an error of type `MulterError`. See the error handling section for how to catch these.

---

## File Filtering

Use `fileFilter` to accept or reject files before they are processed:

```js
const upload = multer({
  storage,
  fileFilter: function (req, file, cb) {
    const allowed = ["image/jpeg", "image/png", "image/webp"];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);   // accept
    } else {
      cb(null, false);  // reject silently
      // or: cb(new Error("Invalid file type")); to reject with an error
    }
  },
});
```

Passing `false` as the second argument to `cb` silently skips the file — it will not appear in `req.file` or `req.files`, and no error is thrown unless you explicitly pass one.

> **Important:** `file.mimetype` is client-supplied and can be spoofed. For robust validation, check the actual file contents using a library such as `file-type` after the file is received.

---

## Error Handling

Multer throws two kinds of errors:

- `MulterError` — a Multer-specific error (e.g., file too large, too many files)
- Generic `Error` — from your own `fileFilter` or unexpected issues

Standard Express error middleware does not catch Multer errors unless you wrap the middleware manually.

### Recommended Pattern

```js
const multer = require("multer");

app.post("/upload", (req, res, next) => {
  upload.single("file")(req, res, function (err) {
    if (err instanceof multer.MulterError) {
      // A Multer-specific error (e.g., LIMIT_FILE_SIZE)
      return res.status(400).json({ error: err.message, code: err.code });
    } else if (err) {
      // An unknown error
      return res.status(500).json({ error: err.message });
    }
    // No error — proceed
    res.json({ file: req.file });
  });
});
```

Calling the middleware as a function and passing a callback gives you direct control over errors.

### MulterError Codes

|Code|Meaning|
|---|---|
|`LIMIT_PART_COUNT`|Too many parts|
|`LIMIT_FILE_SIZE`|File exceeds `limits.fileSize`|
|`LIMIT_FILE_COUNT`|Too many files|
|`LIMIT_FIELD_KEY`|Field name too long|
|`LIMIT_FIELD_VALUE`|Field value too large|
|`LIMIT_FIELD_COUNT`|Too many fields|
|`LIMIT_UNEXPECTED_FILE`|Unexpected field name (when using `single`, `array`, or `fields`)|

---

## Using with Third-Party Storage (e.g., AWS S3)

Multer supports custom storage engines. The most common is `multer-s3` for uploading directly to AWS S3.

```bash
npm install multer-s3 @aws-sdk/client-s3
```

```js
const multerS3 = require("multer-s3");
const { S3Client } = require("@aws-sdk/client-s3");

const s3 = new S3Client({ region: "us-east-1" });

const upload = multer({
  storage: multerS3({
    s3,
    bucket: "your-bucket-name",
    contentType: multerS3.AUTO_CONTENT_TYPE,
    key: function (req, file, cb) {
      cb(null, `uploads/${Date.now()}-${file.originalname}`);
    },
  }),
  limits: { fileSize: 10 * 1024 * 1024 },
});
```

The file object will include additional S3-specific properties such as `location`, `etag`, `key`, and `bucket`.

> [Unverified] `multer-s3` compatibility with specific versions of the AWS SDK v3 has varied over time. Verify the README of your installed `multer-s3` version for the correct import pattern.

---

## Building a Custom Storage Engine

You can implement your own storage engine by providing an object with two methods:

```js
const customStorage = {
  _handleFile(req, file, cb) {
    // file.stream is a readable stream of the file data
    // call cb(null, { ...extraFields }) on success
    // call cb(error) on failure
  },
  _removeFile(req, file, cb) {
    // called when an error occurs after the file was stored
    // clean up the file here
    // call cb(null) when done
  },
};

const upload = multer({ storage: customStorage });
```

`file.stream` is a Node.js `Readable` that emits the raw file bytes. You can pipe it anywhere — a database, a network socket, an image processor, etc.

---

## TypeScript Usage

Multer ships with its own type definitions. No separate `@types/multer` package is needed in recent versions.

```ts
import multer, { FileFilterCallback } from "multer";
import { Request } from "express";

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, "uploads/"),
  filename: (_req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});

const fileFilter = (
  _req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
) => {
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(null, false);
  }
};

export const upload = multer({ storage, fileFilter });
```

`req.file` is typed as `Express.Multer.File | undefined`. `req.files` is typed as `Express.Multer.File[]` or `{ [fieldname: string]: Express.Multer.File[] }` depending on the middleware used.

---

## Accessing Form Fields Alongside Files

Non-file fields in a `multipart/form-data` request are available on `req.body` after Multer processes the request:

```js
app.post("/upload", upload.single("file"), (req, res) => {
  console.log(req.body.title);    // text field named "title"
  console.log(req.body.tags);     // text field named "tags"
  console.log(req.file);          // uploaded file
});
```

> **Note:** `req.body` is only populated after Multer middleware runs. Field order in `multipart/form-data` is not guaranteed by the spec, but in practice most clients send fields before files. Do not rely on ordering.

---

## Common Patterns

### Validate File Type by Extension and MIME Type

```js
const ALLOWED_TYPES = ["image/jpeg", "image/png"];
const ALLOWED_EXTS = [".jpg", ".jpeg", ".png"];

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  if (ALLOWED_TYPES.includes(file.mimetype) && ALLOWED_EXTS.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error("Only JPEG and PNG files are allowed"));
  }
};
```

This adds a basic layer of defense. Still not equivalent to inspecting actual file bytes.

### Generate a Unique Filename

```js
const { randomUUID } = require("crypto");

filename: (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  cb(null, `${randomUUID()}${ext}`);
}
```

Using `crypto.randomUUID()` (Node v15.6+) produces a collision-resistant name.

### Dynamically Choose Destination by File Type

```js
destination: (req, file, cb) => {
  const dir = file.mimetype.startsWith("image/") ? "uploads/images" : "uploads/docs";
  cb(null, dir);
}
```

### Reuse Middleware Instances

Define `upload` once and reuse it across routes rather than calling `multer()` on every request:

```js
// upload.js
const upload = multer({ storage, limits, fileFilter });
module.exports = upload;

// routes/profile.js
const upload = require("../upload");
router.post("/avatar", upload.single("avatar"), handler);
```

---

## Security Considerations

### Never trust client-supplied metadata

`file.mimetype` and `file.originalname` are set by the HTTP client and can be anything. An attacker can upload a PHP script with `mimetype: "image/jpeg"`.

For meaningful type validation, inspect actual file bytes after upload using a library such as `file-type`:

```bash
npm install file-type
```

```js
const { fileTypeFromBuffer } = require("file-type");

app.post("/upload", upload.single("file"), async (req, res) => {
  const type = await fileTypeFromBuffer(req.file.buffer);
  if (!type || !["image/jpeg", "image/png"].includes(type.mime)) {
    return res.status(400).json({ error: "Invalid file type" });
  }
  // proceed
});
```

### Sanitize filenames before storing or serving

If you use `originalname` anywhere in a path, sanitize it:

```bash
npm install sanitize-filename
```

```js
const sanitize = require("sanitize-filename");

filename: (req, file, cb) => {
  cb(null, sanitize(file.originalname) || "upload");
}
```

### Serve uploaded files from a separate domain or path

Files uploaded by users should never be served from the same origin as your application unless you are confident they cannot contain executable content. A user who uploads an HTML file to an `uploads/` directory served by the same Express app can potentially execute scripts in a visitor's browser.

### Always set `limits`

Without `limits`, a single request could consume unbounded memory (MemoryStorage) or disk (DiskStorage). Set at minimum `fileSize`.

### Clean up files on error

When using DiskStorage, if an error occurs after a file is written but before your handler finishes, the file remains on disk. Use `_removeFile` in a custom engine or manually delete files in your error handling:

```js
upload.single("file")(req, res, function (err) {
  if (err) {
    if (req.file) fs.unlink(req.file.path, () => {});
    return res.status(400).json({ error: err.message });
  }
  // proceed
});
```

---

## Common Pitfalls

### Middleware not running

Multer only runs if the `Content-Type` header of the request is `multipart/form-data`. If `req.file` is `undefined` and no error is thrown, check that the client is sending the correct content type.

### `req.body` is empty

`req.body` is only populated by Multer for `multipart/form-data` requests. If you are sending JSON with a file, that is not a valid pattern — you must use `multipart/form-data` and include all fields as form parts.

### Files saved with no extension

If you omit `filename` in DiskStorage, Multer saves files without an extension. This is intentional but often surprising. Always define a `filename` function.

### `LIMIT_UNEXPECTED_FILE` error

This occurs when the client sends a file on a field name not declared in `upload.single()`, `upload.array()`, or `upload.fields()`. Use `upload.any()` if you genuinely need to accept arbitrary field names, or ensure the client and server agree on field names.

### Multer errors not caught by Express error middleware

As described in the error handling section, Multer errors do not automatically propagate to Express's `(err, req, res, next)` middleware when you use the standard middleware pattern. Wrap the middleware invocation manually or use a wrapper utility.

---

## Compatibility

|multer version|Node.js|Express|
|---|---|---|
|v2.x|v14+|v4+|
|v1.x|v6+|v4+|

> [Unverified] Multer v2 was in development as of early 2025 and may have changed the internal API. Verify current status on the official GitHub repository before using pre-release versions.

---

## Minimal Production Checklist

- Storage engine explicitly chosen (not defaulting to MemoryStorage for large files)
- `limits.fileSize` set
- `fileFilter` in place to restrict accepted types
- Destination directory exists before the server starts
- Filenames generated server-side, not taken from `originalname`
- Uploaded files not served from the same origin without content-type enforcement
- Error handling wraps Multer middleware directly to catch `MulterError`
- Files cleaned up on error when using DiskStorage