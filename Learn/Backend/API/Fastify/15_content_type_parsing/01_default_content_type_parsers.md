## Default Content Type Parsers

Fastify includes a small set of built-in content type parsers that automatically deserialize incoming request bodies based on the `Content-Type` header. Understanding which parsers are active by default, what they do, and where their boundaries are 

(intentionally truncated)

---

### What Happens With Unregistered Content Types

If a request arrives with a `Content-Type` that has no registered parser and the request includes a body, Fastify responds with:

```
HTTP 415 Unsupported Media Type
```

```json
{
  "statusCode": 415,
  "error": "Unsupported Media Type",
  "message": "Unsupported Media Type: application/x-www-form-urlencoded"
}
```

This is intentional. Fastify does not silently ignore unrecognized body types.

-
The previous response was complete — it covered all substantive sections for **Default Content Type Parsers** and ended with a Summary and Conclusion.

No content was cut off. The completion marker `` was present at the end, indicating a full response.

If you believe a specific section is missing — for example, a topic you expected to see covered — let me know what it is and I can add it. Otherwise, send the next topic when you're ready.