## Response Object Structure


### Core Response Envelope

The response object wraps all return data from API endpoints in a consistent envelope structure. The outer shell contains metadata about the request execution, while the nested content array holds the actual response data.

```json
{
  "id": "msg_01XYZ...",
  "type": "message",
  "role": "assistant",
  "model": "claude-sonnet-4-20250514",
  "content": [...],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {...}
}
```

### Content Array Architecture

The content array is polymorphic, supporting multiple block types that can be intermixed within a single response. Each block contains a `type` discriminator that determines its structure.

#### Text Blocks

The fundamental response unit carrying natural language output:

```json
{
  "type": "text",
  "text": "The actual response content here..."
}
```

Text blocks may contain markdown formatting, code blocks, or plain text depending on the model's generation choices. Multiple text blocks can appear when the model alternates between text generation and tool use.

#### Tool Use Blocks

Structured requests for function execution:

```json
{
  "type": "tool_use",
  "id": "toolu_01ABC...",
  "name": "function_name",
  "input": {
    "param1": "value1",
    "param2": "value2"
  }
}
```

The `id` field uniquely identifies this tool invocation for matching with subsequent tool result submissions. The `input` object structure is validated against the tool's JSON schema definition provided in the request.

#### Thinking Blocks

Extended reasoning chains when extended thinking is enabled:

```json
{
  "type": "thinking",
  "thinking": "Internal reasoning process..."
}
```

These blocks expose the model's chain-of-thought reasoning before producing final outputs. They're only present when the request includes thinking budget parameters.

### Stop Reason Enumeration

The `stop_reason` field indicates why generation terminated:

- **`end_turn`**: Natural completion where the model finished its response
- **`max_tokens`**: Generation hit the `max_tokens` limit before completion
- **`stop_sequence`**: Encountered a custom stop sequence from the request
- **`tool_use`**: Model produced tool calls and paused for tool result injection

When `stop_reason` is `"tool_use"`, the response expects a follow-up request containing tool results before generation can continue.

### Usage Metrics Object

Token consumption breakdown for billing and monitoring:

```json
{
  "input_tokens": 2048,
  "output_tokens": 512,
  "cache_creation_input_tokens": 0,
  "cache_read_input_tokens": 0
}
```

#### Token Counting Semantics

- **`input_tokens`**: All prompt tokens processed, including system prompts, conversation history, and tool definitions
- **`output_tokens`**: Tokens generated in the response content array
- **`cache_creation_input_tokens`**: Tokens written to prompt cache on this request
- **`cache_read_input_tokens`**: Tokens retrieved from prompt cache, charged at reduced rate

Cache tokens are only populated when prompt caching is enabled and cache control markers are present in the request.

### Streaming Response Variants

#### Event Stream Structure

Streaming responses use Server-Sent Events (SSE) format with typed event chunks:

```
event: message_start
data: {"type":"message_start","message":{...}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_delta
data: {"type":"message_delta","delta":{"stop_reason":"end_turn"},"usage":{...}}

event: message_stop
data: {"type":"message_stop"}
```

#### Delta Objects

Content deltas contain incremental additions to blocks:

```json
{
  "type": "text_delta",
  "text": "incremental tokens"
}
```

For tool use blocks, the input field streams as partial JSON:

```json
{
  "type": "input_json_delta",
  "partial_json": "{\"param\": \"val"
}
```

Clients must accumulate deltas to reconstruct complete blocks. JSON deltas may contain incomplete syntax until the `content_block_stop` event signals completion.

### Error Response Structure

Errors replace the standard response envelope with a distinct structure:

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "Detailed error description"
  }
}
```

#### Error Type Taxonomy

- **`invalid_request_error`**: Malformed request syntax or schema violations
- **`authentication_error`**: Missing or invalid API key
- **`permission_error`**: Valid credentials lack required access
- **`not_found_error`**: Requested resource doesn't exist
- **`rate_limit_error`**: Request exceeds rate limiting quotas
- **`api_error`**: Internal server errors or model failures
- **`overloaded_error`**: Service temporarily unavailable due to capacity

Rate limit errors include additional fields for quota management:

```json
{
  "type": "error",
  "error": {
    "type": "rate_limit_error",
    "message": "Rate limit exceeded",
    "retry_after": 30
  }
}
```

### Multi-Turn Conversation Continuity

Response IDs enable conversation threading and analytics correlation:

```json
{
  "id": "msg_01XYZ...",
  ...
}
```

These IDs are opaque identifiers unique per message generation. They should be logged for debugging but not parsed or relied upon for semantic meaning.

### Model Metadata Fields

The `model` field echoes the exact model identifier that processed the request:

```json
{
  "model": "claude-sonnet-4-20250514"
}
```

This may differ from the requested model if aliasing or fallback logic is applied. The returned value represents the actual inference engine used.

### Stop Sequence Matching

When a custom stop sequence triggers termination, the `stop_sequence` field contains the matched string:

```json
{
  "stop_reason": "stop_sequence",
  "stop_sequence": "\n\nHuman:"
}
```

The matched sequence is excluded from the final text block content. Multiple stop sequences can be provided in requests, but only one can match per generation.

### Content Block Ordering Guarantees

Content blocks maintain strict generation order within the array. Tool use blocks always appear after any text explaining the tool call rationale, never before.

When multiple tool calls occur, they appear sequentially in the order the model decided to invoke them:

```json
{
  "content": [
    {"type": "text", "text": "I'll search for that information..."},
    {"type": "tool_use", "id": "toolu_01", "name": "search", "input": {...}},
    {"type": "tool_use", "id": "toolu_02", "name": "fetch", "input": {...}}
  ]
}
```

### Role Field Semantics

The `role` field is always `"assistant"` in response objects, distinguishing model outputs from user messages in conversation history construction.

### Extended Thinking Token Accounting

When extended thinking is active, thinking tokens are tracked separately in usage metrics:

```json
{
  "usage": {
    "input_tokens": 2048,
    "output_tokens": 512,
    "thinking_tokens": 8192
  }
}
```

Thinking tokens are charged at standard output rates but represent internal reasoning not visible to users unless thinking blocks are explicitly enabled.

### Prompt Caching Interaction

Response objects reflect cache behavior through specialized usage fields. On cache miss, `cache_creation_input_tokens` shows tokens written to cache. Subsequent requests with matching cache prefixes populate `cache_read_input_tokens`.

Cache keys are derived from prompt content hashes, making cache hits deterministic for identical input prefixes. TTL is 5 minutes, after which cached content expires and requires recreation.

### Type Safety Considerations

The `type` discriminator enables type-safe parsing in strongly-typed languages:

```typescript
type ContentBlock = 
  | { type: "text", text: string }
  | { type: "tool_use", id: string, name: string, input: Record<string, unknown> }
  | { type: "thinking", thinking: string };
```

Clients should validate the `type` field before accessing type-specific properties to avoid runtime errors on future block type additions.

---

