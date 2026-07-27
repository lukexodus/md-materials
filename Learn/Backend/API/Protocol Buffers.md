# Protocol Buffers (Protobuf): A Comprehensive Guide

## What Protobuf Is and Why It Exists

Protocol Buffers is a binary serialization format developed by Google, along with the interface definition language (IDL) used to describe the structure of that data. You write a schema in a `.proto` file, run it through a compiler (`protoc`), and get generated code in whatever language you need — Python, Java, Go, C++, and many others — that can serialize your data structures to bytes and back.

The core problem it solves is this: JSON and XML are human-readable and flexible, but that flexibility costs you. Every field name is repeated as a string in every single message. There's no enforced schema, so a typo in a field name silently produces missing data instead of an error. Parsing text formats is CPU-expensive compared to reading fixed binary layouts. And there's no compact, efficient way to represent numbers — a JSON integer is a string of ASCII digits, not a packed binary value.

Protobuf trades human-readability for:
- **Compactness** — field names never appear in the payload, only numeric field tags (more on this below), and numbers are encoded in variable-length binary
- **Speed** — binary parsing is much faster than text parsing
- **A strict, generated-code contract** — you don't hand-write serialization logic or risk key-name typos; the compiler generates strongly-typed accessor code for you
- **Built-in, well-defined rules for schema evolution** — you can add fields to a message and both old and new code can still talk to each other, which is much harder to guarantee safely with hand-rolled JSON parsing

The tradeoff is that protobuf payloads are not human-readable on the wire (you need the schema, or a tool like `protoc --decode`, to make sense of the bytes), and you need a compile step before you can use your schema in code. For internal service-to-service communication, config files that only tooling reads, or high-throughput systems, this tradeoff is usually well worth it. For a public API where third parties need to read raw payloads by eye, JSON is often still the better choice — which is part of why gRPC (built on protobuf) coexists with REST/JSON APIs rather than replacing them everywhere.

## Basic `.proto` File Syntax

A minimal `.proto` file looks like this:

```protobuf
syntax = "proto3";

package myapp.users;

message Person {
  string name = 1;
  int32 id = 2;
  string email = 3;
}
```

Breaking this down:

- `syntax = "proto3";` declares which version of the protobuf language you're using. This should be the first non-comment line in the file. If omitted, older `protoc` versions default to `proto2`, which has different semantics — always declare it explicitly.
- `package myapp.users;` namespaces your messages, similar to a package/namespace in most programming languages, to avoid naming collisions when your `.proto` files are combined with others.
- `message Person { ... }` defines a structured data type, analogous to a class or struct.
- Each line inside the message is a **field**: a type, a name, and — critically — a **field number** after the `=` sign.

That field number is the single most important concept in the entire protobuf system, and it's worth stopping on before going further, because everything about schema evolution later comes back to this.

## Field Numbers: The Load-Bearing Concept

In protobuf, the field *name* (`name`, `id`, `email` above) exists only for the generated code and for human readability of the `.proto` file. It is **never transmitted on the wire**. What's actually sent in the binary payload is the field *number* (`1`, `2`, `3`).

This has a major consequence: you can rename a field in your `.proto` file at any time without breaking wire compatibility, because renaming doesn't change the number. Conversely, you must **never reassign an existing field number to a different field**, because any data already serialized under the old schema will be silently misinterpreted under the new one — the receiver has no way to know the meaning changed, because all it sees is "field number 3."

Field numbers 1 through 15 use one byte on the wire (as part of the tag, explained in the wire format section below) instead of two, so it's a common convention to reserve 1–15 for fields you expect to be present frequently, or that are unlikely to be removed. Field numbers up to 2^29 - 1 are valid, but 19000–19999 are reserved by protobuf internally and cannot be used.

When you delete a field, you should **reserve** its number and name so nobody accidentally reuses them later:

```protobuf
message Person {
  reserved 4, 5;
  reserved "old_field_name";
  string name = 1;
  int32 id = 2;
  string email = 3;
}
```

This is not just style — `protoc` will actually error out if someone tries to reuse a reserved number or name, which is exactly the safety net you want given how bad the silent-misinterpretation failure mode is.

## The Wire Format: How Bytes Are Actually Encoded

I'm including this section even though many people learn to *use* protobuf without ever thinking about the wire format — but the "why" behind schema evolution rules, and behind the scalar-type gotchas coming up next, only really clicks once you've seen this. It's worth the detour.

Each field in a serialized protobuf message is encoded as a **tag**, followed by a **value**. The tag is a single varint that packs together two pieces of information: the field number, and the **wire type** — a 3-bit code indicating how to interpret the bytes that follow.

The tag is computed as:

```
tag = (field_number << 3) | wire_type
```

The wire types are:

| Wire Type | Number | Used For |
|---|---|---|
| VARINT | 0 | int32, int64, uint32, uint64, sint32, sint64, bool, enum |
| I64 (64-bit) | 1 | fixed64, sfixed64, double |
| LEN (length-delimited) | 2 | string, bytes, embedded messages, packed repeated fields |
| SGROUP (start group) | 3 | deprecated, proto2 groups |
| EGROUP (end group) | 4 | deprecated, proto2 groups |
| I32 (32-bit) | 5 | fixed32, sfixed32, float |

You almost never need to think about groups (wire types 3/4) — they're a legacy proto2 feature superseded by nested messages.

**Varints** deserve explanation because they're the backbone of the whole compact-encoding story. A varint encodes an integer using 1 to 10 bytes, where each byte contributes 7 bits of the number, and the most significant bit of each byte is a continuation flag: 1 means "more bytes follow," 0 means "this is the last byte." Small numbers — which are extremely common in real data (short counts, small IDs, small enum values) — take just one byte. Larger numbers take more bytes, up to 10 for a full 64-bit value. This is precisely why field numbers 1–15 are cheaper: they fit in the tag's varint using a single byte total (3 bits wire type + 4 bits field number = 7 bits, fits in one byte), while field numbers 16 and above need a second tag byte.

**Length-delimited (LEN)** fields — strings, bytes, embedded messages, and packed repeated fields — are encoded as: tag, then a varint giving the byte length, then that many raw bytes. This is why embedded messages are so natural in protobuf: a nested message is just serialized independently and then dropped in as a length-prefixed blob inside the parent.

One important wire-format consequence worth internalizing: **a parser that doesn't recognize a field number simply skips over it**, because the wire type tells it how many bytes to skip even without knowing the field's semantic meaning. This is the mechanical basis for forward compatibility — old code can safely ignore fields it doesn't understand yet, rather than crashing or misparsing.

## Scalar Types and Their Wire Behavior

This table matters more than it might look like, because picking the wrong integer type is one of the most common real-world protobuf mistakes — it doesn't cause bugs in normal-range testing, only shows up as wasted bytes or (for negative numbers) *dramatically* wasted bytes in production.

| Type | Wire Type | Notes |
|---|---|---|
| `double` | I64 | 64-bit floating point |
| `float` | I32 | 32-bit floating point |
| `int32` | VARINT | Efficient for small **positive** numbers. Negative numbers always encode as a full 10-byte varint (they're treated as very large unsigned 64-bit numbers internally) — this is a real trap |
| `int64` | VARINT | Same negative-number caveat as int32 |
| `uint32` | VARINT | Unsigned, no negative-number caveat since negatives aren't valid |
| `uint64` | VARINT | Unsigned |
| `sint32` | VARINT | Uses "zigzag encoding" — efficiently encodes negative numbers. Use this instead of int32 if the field is likely to hold negative values |
| `sint64` | VARINT | Zigzag-encoded, like sint32 |
| `fixed32` | I32 | Always exactly 4 bytes. More efficient than uint32 if values are frequently larger than 2^28 |
| `fixed64` | I64 | Always exactly 8 bytes. More efficient than uint64 if values are frequently larger than 2^56 |
| `sfixed32` | I32 | Signed, always exactly 4 bytes |
| `sfixed64` | I64 | Signed, always exactly 8 bytes |
| `bool` | VARINT | Encoded as 0 or 1 |
| `string` | LEN | Must be UTF-8 encoded text |
| `bytes` | LEN | Arbitrary byte sequence, no encoding requirement |

The zigzag encoding used by `sint32`/`sint64` is worth a quick explanation since "why would negative numbers need special encoding" isn't obvious. A plain varint interpretation of a negative number treats it as its two's-complement bit pattern reinterpreted as unsigned — which for something like `-1` means a value close to 2^64, requiring the full 10 bytes to encode. Zigzag encoding instead maps signed integers to unsigned ones by interleaving positive and negative values: 0 → 0, -1 → 1, 1 → 2, -2 → 3, 2 → 4, and so on. This keeps small-magnitude negative numbers small in their zigzag-mapped form, so they compress efficiently as varints. The rule of thumb: if a field can plausibly be negative, use `sint32`/`sint64`, not `int32`/`int64`.

## Repeated Fields

A `repeated` field represents a list/array of values:

```protobuf
message ShoppingList {
  repeated string items = 1;
  repeated int32 quantities = 2;
}
```

For scalar numeric types, proto3 automatically uses **packed encoding** by default: instead of writing a separate tag + value for every single element (which would repeat the tag bytes wastefully), all the values are concatenated into one single LEN-wire-type field — one tag, one combined length, then all the values back to back. This is meaningfully more compact for numeric arrays with more than a couple of elements. `string` and `bytes` repeated fields are not packed this way (each string element already needs its own length prefix, so there's no equivalent win) — each repeated string/bytes/message element gets its own separate tag+length+value entry.

## Nested Messages and Imports

Messages can contain other messages, either defined inline or in separate files:

```protobuf
message Address {
  string street = 1;
  string city = 2;
  string postal_code = 3;
}

message Person {
  string name = 1;
  int32 id = 2;
  Address address = 4;
}
```

For larger schemas, you'll split messages across files and pull them in with `import`:

```protobuf
import "address.proto";

message Person {
  string name = 1;
  int32 id = 2;
  Address address = 4;
}
```

A nested message field in proto3, when unset, is simply absent — this connects to the "presence" discussion below, because message-type fields behave differently from scalar fields in an important way.

## Enums

```protobuf
enum Status {
  STATUS_UNSPECIFIED = 0;
  STATUS_ACTIVE = 1;
  STATUS_INACTIVE = 2;
  STATUS_SUSPENDED = 3;
}

message Account {
  Status status = 1;
}
```

Two rules that are easy to get wrong:

**The first enum value must be 0**, and by strong convention should be named something like `*_UNSPECIFIED` or `*_UNKNOWN`. This isn't just style — 0 is the default value used when the field isn't explicitly set, so having a meaningful "zero value" (as opposed to accidentally making, say, `ACTIVE = 0`) avoids a subtle bug where "field wasn't set" becomes indistinguishable from "field was explicitly set to active."

**As of proto3, enums are "open"** — meaning if a message is serialized with an enum value that the receiving code's schema doesn't recognize (because it was added in a newer schema version), the receiver doesn't error out or discard the field. It preserves the unrecognized integer value, which round-trips correctly if the message is re-serialized, even though the receiving code can't meaningfully interpret it. This is a deliberate forward-compatibility design choice, and it's a change from early proto3 releases, which briefly had "closed" enum semantics — worth knowing if you ever encounter older documentation describing different behavior.

## `oneof`

`oneof` expresses "exactly one of these fields may be set at a time" — useful for representing a union/variant type:

```protobuf
message SearchRequest {
  oneof query_type {
    string text_query = 1;
    int32 id_query = 2;
    GeoQuery geo_query = 3;
  }
}
```

Setting one field of a `oneof` automatically clears any other field in the same `oneof` that was previously set — the generated code handles this for you. This is genuinely useful for modeling "this message means one of several different things," and it's also the one place in proto3 where you get explicit field presence tracking for free (see the next section), since the generated code exposes a way to check which field of the `oneof`, if any, is currently set.

A couple of restrictions worth knowing: fields in a `oneof` cannot be `repeated`, and you cannot nest one `oneof` inside another.

## Maps

```protobuf
message Inventory {
  map<string, int32> item_counts = 1;
}
```

Maps look like a distinct feature but are actually syntactic sugar. Under the hood, `map<string, int32> item_counts = 1;` compiles to the equivalent of:

```protobuf
message ItemCountsEntry {
  string key = 1;
  int32 value = 2;
}
repeated ItemCountsEntry item_counts = 1;
```

Knowing this matters for two practical reasons. First, map key order is **not preserved** on the wire — if you need ordering, use a `repeated` message with explicit key/value fields instead of a map. Second, map key types are restricted to integral and string types (no floating-point, no message types, no `bytes`) — direct consequence of the fact that a map entry is a real message, and message-typed map keys wouldn't have well-defined equality/ordering semantics for the underlying map data structure.

## Well-Known Types

Google ships a standard library of common message types with the protobuf distribution, since certain shapes come up constantly enough to standardize:

- **`google.protobuf.Timestamp`** — represents an absolute point in time, as seconds + nanoseconds since the Unix epoch. Use this instead of inventing your own timestamp representation (a raw `int64` of milliseconds, a string, etc.) so that tooling and other services can interoperate.
- **`google.protobuf.Duration`** — represents a signed span of time, also as seconds + nanoseconds.
- **`google.protobuf.Any`** — allows a field to hold an arbitrary serialized message of any type, along with a URL string identifying that type, similar in spirit to `interface{}`/`Object` in a general-purpose language. Useful for plugin-style systems where the exact message type isn't known at schema-design time, but it sacrifices some of protobuf's compile-time type safety, so it's used sparingly.
- **`google.protobuf.Empty`** — a message with no fields, commonly used as the request or response type for an RPC that genuinely carries no data (e.g., a "ping" or a "delete" that returns nothing).
- **`google.protobuf.FieldMask`** — represents a set of field paths, commonly used in update RPCs to specify exactly which fields of a resource should be modified (so a partial update doesn't require the caller to resend the entire object).
- **Wrapper types** (`google.protobuf.Int32Value`, `google.protobuf.StringValue`, `google.protobuf.BoolValue`, etc.) — exist specifically to solve the proto3 default-value presence problem for scalars, discussed just below, by wrapping a scalar in a message so its presence/absence becomes distinguishable from its zero value.

## Default Values and the Presence Problem

This is one of the most conceptually important, and most commonly misunderstood, parts of proto3.

In proto3, scalar fields do **not** have a way to distinguish "explicitly set to the zero value" from "never set at all," unless you take a specific extra step. If you never set an `int32` field, it reads back as `0`. If you explicitly set it to `0`, it also reads back as `0`. There is no `hasFoo()` — no field-presence check — for a plain scalar field in proto3 by default. The same applies to `string` (default `""`), `bool` (default `false`), and so on.

This matters a lot in practice. Consider a `bool subscribed = 1;` field meant to represent whether a user opted into notifications. If `subscribed` is `false`, you cannot tell — from the message alone — whether the user explicitly opted out, or whether this message was constructed without ever touching that field at all. For many use cases that distinction doesn't matter. For some (like "did this client actually send a preference, or should I apply a server-side default?") it matters a great deal.

Proto3 gives you two ways to solve this:

**The `optional` keyword** (reintroduced to proto3 in more recent protobuf releases, after early proto3 initially removed field presence for scalars) makes a scalar field presence-tracked again:

```protobuf
message NotificationSettings {
  optional bool subscribed = 1;
}
```

With `optional`, the generated code gains a `hasSubscribed()`-style accessor (naming varies by language), letting you distinguish "not set" from "set to false." Under the hood, `optional` scalar fields are implemented using a hidden single-field `oneof`, which is exactly the mechanism that already provided presence-tracking, as mentioned above.

**Wrapper message types**, as mentioned in well-known types above, are the older workaround for the same problem, predating the reintroduction of `optional`: wrap the scalar in a message (`google.protobuf.BoolValue` instead of `bool`) so that the whole thing becomes a message-typed field, and message-typed fields in proto3 *have always* had presence tracking (an unset message field is genuinely absent — `null`/`None`/`nullptr` depending on language — rather than defaulting to some zero-equivalent). This works, but it's a heavier-weight solution (you're now serializing a nested message just to hold one scalar) and modern advice generally favors `optional` when your protobuf version supports it.

Note that this presence problem does **not** apply to `repeated` fields or `map` fields — an empty list and an unset list are already indistinguishable in a meaningful sense (there's nothing to distinguish; "unset repeated field" and "repeated field explicitly set to zero elements" behave identically and this is rarely a problem in practice), so `optional` cannot be applied to `repeated` fields.

## proto2 vs proto3, Briefly

You'll mostly be writing proto3 today, but you'll likely encounter proto2 in older codebases, so it's worth knowing the key differences rather than being surprised by them:

- **Field presence**: In proto2, *all* scalar fields have explicit presence tracking by default (there's no need for `optional` as a special case — it's just how proto2 always worked). Proto3 initially removed this for scalars (as described above) and later reintroduced it via the `optional` keyword.
- **Required fields**: proto2 has a `required` keyword, enforcing that a field must be set or the message fails to serialize/parse. This was removed entirely in proto3, because in practice `required` turned out to be a schema-evolution hazard — you can never safely stop requiring a field once any deployed code depends on it being required, which defeats one of protobuf's central selling points. Proto3's philosophy is that all fields are effectively optional.
- **Default value customization**: proto2 lets you specify custom default values per field (e.g., `optional int32 count = 1 [default = 42];`). Proto3 removed this — the default is always the type's zero value.
- **Enums**: proto2 enums are historically closed (unrecognized values are treated as unknown fields rather than preserved as the enum type); proto3 enums are open, as described earlier.

If you're designing something new, proto3 is almost always the right choice today.

## Schema Evolution and Backward/Forward Compatibility Rules

This is, in practical terms, the single most valuable section of this whole guide, because it's the part that prevents production incidents. Everything above about field numbers and the wire format was building toward this.

The core guarantee protobuf offers is: **if you follow these rules, old code can read new data, and new code can read old data**, without either side crashing or silently corrupting data. Here's the rule set:

**Safe changes:**
- **Adding a new field.** Old code parsing a message with a field it doesn't know about simply skips those bytes (this is the wire-format mechanism described earlier — the wire type tells the parser how many bytes to skip). New code parsing an old message where the new field is absent just gets the default/zero value for it.
- **Removing a field**, *provided* you reserve its number and name (as shown in the field numbers section) so it's never reused. Old code that still has this field in its schema will simply see it as absent when parsing new data.
- **Renaming a field.** Since only the field number goes on the wire, renaming has zero effect on wire compatibility. It does, however, change the generated code's method/property names, which can break code that references them — so this is wire-safe but not necessarily source-code-safe.
- **Adding values to an enum**, since proto3 enums are open (as covered above) and unrecognized values are preserved rather than erroring.
- **Changing a field from `optional` to being part of a new `oneof`** containing just that field, or vice versa — generally safe, though there are edge cases worth testing.

**Unsafe changes — avoid these:**
- **Changing a field's number.** This is the single most damaging mistake, because it silently reinterprets old data under a new meaning rather than failing loudly.
- **Changing a field's type**, in most cases. Some narrow exceptions exist (e.g., `int32` and `uint32` and `int64` and `uint64` share wire-compatible encodings in most practical cases, so you *can* sometimes change between them, though sign-related edge cases can still bite you), but as a general rule, changing a field's declared type is unsafe and should be treated as "add a new field with a new number and deprecate the old one" instead.
- **Changing a singular field to `repeated`, or vice versa.** This changes the wire encoding expectations and is not safe.
- **Removing a field without reserving its number.** A future developer might reuse that number for something semantically unrelated, and now old serialized data gets silently misinterpreted.
- **Changing a `oneof`'s member fields in incompatible ways**, or moving an existing field into a new `oneof` if other fields might already be relying on independent presence.

The practical takeaway, if you remember nothing else from this section: **field numbers are a permanent, append-only contract.** Once a number is shipped in production data anywhere, you don't reuse it, you don't repurpose it, and if you remove the field, you reserve the number so nobody else does either.

## Services and RPC Definitions

Protobuf's IDL also supports defining services — this is the piece that gRPC is built on top of:

```protobuf
service UserService {
  rpc GetUser (GetUserRequest) returns (GetUserResponse);
  rpc ListUsers (ListUsersRequest) returns (stream User);
  rpc UploadUsers (stream User) returns (UploadSummary);
  rpc SyncUsers (stream SyncRequest) returns (stream SyncResponse);
}

message GetUserRequest {
  int32 user_id = 1;
}

message GetUserResponse {
  Person user = 1;
}
```

The `stream` keyword marks a streaming argument or return value rather than a single request/response, giving you four possible RPC shapes:
- **Unary** (no `stream` on either side) — one request, one response, the traditional REST-like call
- **Server streaming** (`stream` on the return only) — one request, a stream of responses (e.g., subscribing to updates)
- **Client streaming** (`stream` on the request only) — a stream of requests, one final response (e.g., uploading chunks)
- **Bidirectional streaming** (`stream` on both) — both sides send independent streams (e.g., a chat-like protocol)

The `.proto` file only *defines* the service contract — it doesn't implement any networking logic itself. `protoc`, combined with the gRPC plugin for your target language, generates client stub code and server-side interface/base classes; you then write the actual business logic that fulfills that generated interface.

## Compilation Workflow

The typical workflow is:

1. Write your schema in one or more `.proto` files.
2. Run `protoc` (the Protocol Buffer Compiler) with a language-specific plugin, e.g.:
   ```
   protoc --python_out=. --grpc_python_out=. my_service.proto
   ```
3. `protoc` generates source code in your target language — typically one file (or a pair of files, for gRPC services) per `.proto` file.
4. You import the generated code into your application and use the generated classes to construct messages, and their generated `.SerializeToString()` / `.ParseFromString()` (or equivalent, naming varies by language) methods to convert to/from bytes.

The generated code gives you, for each message: a class/struct with typed fields matching your schema, getter/setter (or direct field access, depending on language) methods, serialization and deserialization methods, and — for `optional` fields and `oneof`s — presence-check methods.

It's worth internalizing that **you never hand-write serialization logic** in a protobuf-based system. The entire point of the generated code is that the tedious, error-prone, easy-to-get-subtly-wrong parts (byte layout, varint encoding, tag computation) are handled once, correctly, by the compiler — and you interact only with the typed, generated interface.

## Common Pitfalls

Pulling together the mistakes that show up most often in real codebases, since abstract rules are more memorable with concrete failure modes attached:

1. **Reusing a field number after deleting a field**, without having reserved it — leads to old serialized data being silently misinterpreted as the new field's type. This is the single most dangerous mistake in the whole system, and it fails silently rather than loudly, which is what makes it dangerous.
2. **Using `int32`/`int64` for fields that can be negative**, instead of `sint32`/`sint64` — doesn't cause incorrect behavior, just quietly wastes up to 10 bytes per value instead of 1-2.
3. **Treating proto3's implicit scalar defaults as "unset," without adding `optional`** — leads to bugs where "explicitly set to false/0/empty-string" and "never touched" get conflated, especially in update/PATCH-style APIs where the difference between "don't change this field" and "set this field to its zero value" genuinely matters.
4. **Forgetting that `0` must be the first enum value** — either the compiler rejects the schema outright (in proto3, this is actually enforced — `protoc` will error if the first enum value isn't 0), or if there's some workaround, you end up with a confusing default state.
5. **Assuming map key order is preserved** — it isn't; if order matters, use a `repeated` message with explicit key/value fields.
6. **Changing a field's type carelessly**, assuming it's fine because "it's just a number" — even between seemingly compatible-looking numeric types, this can silently break older or newer clients depending on the exact types involved.
7. **Not setting `syntax = "proto3";` explicitly** and being surprised by different default behavior from an older `protoc` version defaulting to proto2 syntax rules.
8. **Overusing `google.protobuf.Any`** for cases where a `oneof` would have given the same flexibility with actual compile-time type safety — `Any` should generally be a last resort, not a default choice, because it discards most of the benefit of having a schema in the first place.

## Worked Example: Putting It Together

A small but realistic schema, showing several of the concepts above working together:

```protobuf
syntax = "proto3";

package library.catalog;

import "google/protobuf/timestamp.proto";

message Book {
  reserved 6;
  reserved "isbn_old_format";

  string title = 1;
  string author = 2;
  int32 publication_year = 3;
  Genre genre = 4;
  repeated string tags = 5;
  optional string isbn = 7;
  google.protobuf.Timestamp added_at = 8;

  oneof availability {
    AvailableCopy available = 9;
    CheckedOutInfo checked_out = 10;
  }
}

enum Genre {
  GENRE_UNSPECIFIED = 0;
  GENRE_FICTION = 1;
  GENRE_NONFICTION = 2;
  GENRE_REFERENCE = 3;
}

message AvailableCopy {
  int32 shelf_location = 1;
}

message CheckedOutInfo {
  string borrower_name = 1;
  google.protobuf.Timestamp due_date = 2;
}

service CatalogService {
  rpc GetBook (GetBookRequest) returns (Book);
  rpc SearchBooks (SearchRequest) returns (stream Book);
}

message GetBookRequest {
  int32 book_id = 1;
}

message SearchRequest {
  string query = 1;
}
```

Notice what this example demonstrates: field 6 and an old field name are properly reserved rather than left open for reuse; `optional` is used on `isbn` because "book has no ISBN" and "ISBN not yet looked up" are genuinely different states worth distinguishing; `Genre` starts at 0 with an `UNSPECIFIED` value; a `Timestamp` well-known type is used instead of a custom date representation; `oneof` cleanly models "a book is either available or checked out, never both, never neither"; and the service definition includes both a unary call and a server-streaming call, showing both RPC shapes in one schema.

---

That's the full guide. A few notes on scope, stated plainly rather than hidden: I focused on proto3 as the primary version since that's what new work should target, treated proto2 as a comparison point rather than giving it equal depth, and didn't go deep into language-specific generated-code APIs (Python vs Java vs Go all differ in exact method names) since that's more of a per-language reference than a conceptual "learn protobuf" document. If you want a follow-up focused on a specific language's generated code, or on protobuf inside a specific context like gRPC service design patterns or JSON-mapping (`google.protobuf.util.JsonFormat` and proto3's canonical JSON encoding), I can go deeper on either of those next.