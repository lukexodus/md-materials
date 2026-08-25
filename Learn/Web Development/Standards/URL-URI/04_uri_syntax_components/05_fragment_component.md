## Fragment Component


The fragment component identifies a secondary resource within the primary resource identified by the URI. It appears after a hash symbol (#) and is the final component of a URI.

**Syntax Position:**

```
scheme://authority/path?query#fragment
                              ↑
                        fragment starts here
```

The fragment component provides a method to reference a specific part of a resource without requiring the server to process it. When a URI containing a fragment is dereferenced, the client retrieves the primary resource first, then processes the fragment identifier locally.

**Processing Behavior:**

Fragment identifiers are not sent to the server during HTTP requests. When a browser requests `https://example.com/doc.html#section2`, only `https://example.com/doc.html` is transmitted in the HTTP request. The client handles the fragment after receiving the response.

**Allowed Characters:**

The fragment component permits unreserved characters (letters, digits, hyphen, period, underscore, tilde), percent-encoded characters, and sub-delimiters (!, $, &, ', (, ), *, +, ,, ;, =). Additionally, the characters : @ / ? are allowed within fragments.

**Common Applications:**

In HTML documents, fragments reference element IDs or named anchors. For `https://example.com/page.html#introduction`, the browser scrolls to the element with `id="introduction"`. In JSON documents using JSON Pointer notation, fragments specify paths to specific values. SVG files use fragments to reference specific graphic elements within the image. Media fragments specify temporal or spatial segments of audio/video resources.

**Fragment Semantics:**

The interpretation of fragment identifiers depends on the media type of the retrieved resource. HTML fragments identify elements, while PDF fragments might specify page numbers or named destinations. This media-type-specific interpretation occurs entirely on the client side.

