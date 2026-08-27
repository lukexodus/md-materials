# The Anthropic API: A Comprehensive Guide

## What this covers

This is a working reference for the Anthropic Messages API — the actual HTTP interface developers use to build with Claude. It's organized so you can read it top to bottom as a tutorial, or jump to any section as a lookup.

I pulled current details from Anthropic's own documentation rather than relying on memory, since API specifics (model names, parameters, pricing) change often enough that stale info would actively mislead you here.

---

## 1. Core concepts

### 1.1 The Messages API

Anthropic's primary interface is the **Messages API**, reached via `POST https://api.anthropic.com/v1/messages`. It's a single endpoint that handles everything: plain text conversations, multi-turn dialogue, tool use, vision, extended thinking, and streaming. There's no separate "chat" vs "completion" endpoint — Claude models are conversational by design, so every request is structured as an exchange of `user` and `assistant` turns.

### 1.2 Authentication

Every request needs two headers:

```
x-api-key: YOUR_API_KEY
anthropic-version: 2023-06-01
```

- `x-api-key` — your API key, created in the [Anthropic Console](https://console.anthropic.com/).
- `anthropic-version` — a required date-stamped version string that pins the API's request/response shape. This exists so Anthropic can evolve the API without silently breaking your integration; you upgrade the version string deliberately when you're ready.

Content-Type is `application/json` for standard requests (multipart is used for the Files API).

### 1.3 The basic request shape

Every Messages API call needs at minimum:

```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 1024,
  "messages": [
    {"role": "user", "content": "Hello, Claude"}
  ]
}
```

- `model` — which model to use (see §2).
- `max_tokens` — the _maximum_ number of tokens Claude is allowed to generate. This is not a target length; it's a hard ceiling. Generation stops early and naturally most of the time.
- `messages` — an array of turns, each with a `role` (`user` or `assistant`) and `content`.

A minimal curl call:

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "Hello, Claude"}]
  }'
```

### 1.4 Content blocks

`content` in a message can be a plain string (shorthand for a single text block) or an **array of content blocks**. This array form is what unlocks everything else — images, documents, tool calls, tool results, thinking blocks — because each block carries a `type` field:

```json
{
  "role": "user",
  "content": [
    {"type": "text", "text": "What's in this image?"},
    {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": "..."}}
  ]
}
```

The response's `content` array works the same way — you may get back a `text` block, a `tool_use` block, or (with extended thinking enabled) a `thinking` block, sometimes several of these in sequence within one response.

### 1.5 System prompts

Unlike some other APIs, the system prompt is **not** a message with `role: "system"`. It's a top-level parameter:

```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 1024,
  "system": "You are a helpful assistant that responds only in formal English.",
  "messages": [{"role": "user", "content": "Hi"}]
}
```

`system` can also be an array of content blocks — this matters for prompt caching (§6).

### 1.6 Multi-turn conversation

The API is stateless — Claude has no memory of past requests. Every call must include the _full_ conversation history you want Claude to see:

```json
{
  "messages": [
    {"role": "user", "content": "What's the capital of France?"},
    {"role": "assistant", "content": "The capital of France is Paris."},
    {"role": "user", "content": "What's the population there?"}
  ]
}
```

Roles must alternate `user`/`assistant`/`user`/`assistant`... and the first message must be `role: "user"`. Consecutive same-role messages aren't allowed in a single request (though you can pass a list containing multiple content blocks under one role in some contexts, like when doing multi-block tool results).

A trick worth knowing: if you supply a final `assistant` message, Claude treats it as the start of its own reply and continues from there rather than starting fresh. This "assistant message prefill" is useful for forcing a specific format (e.g., prefill `{"role": "assistant", "content": "{"}` to nudge toward JSON output) or for skipping a preamble you don't want.

### 1.7 Stop reasons

Every response includes a `stop_reason` telling you _why_ generation stopped:

|`stop_reason`|Meaning|
|---|---|
|`end_turn`|Claude finished its turn naturally|
|`max_tokens`|Hit the `max_tokens` ceiling — response may be truncated|
|`stop_sequence`|Hit one of your custom `stop_sequences`|
|`tool_use`|Claude is calling a tool and pausing for you to return a result|
|`pause_turn`|Used with server-side tools (e.g., web search) for long-running turns; you resume by making another request with the response appended as-is|
|`refusal`|Claude declined to generate content for safety reasons|

Checking `stop_reason` (not just parsing text) is the correct way to detect truncation or tool calls programmatically.

---

## 2. Models

I'm not going to hardcode a model list here with confidence, because this is exactly the kind of detail that goes stale fastest — model names, context windows, and pricing shift over time, and this guide should stay useful rather than becoming a snapshot of one particular week. Instead:

- Model identifiers follow a pattern like `claude-{tier}-{version}` — e.g. `claude-sonnet-4-5`, `claude-opus-4-5`. Tiers roughly trade off capability against speed/cost: **Opus** (most capable), **Sonnet** (balanced), **Haiku** (fastest/cheapest).
- Anthropic also publishes **dated snapshot names** (e.g. `claude-sonnet-4-5-20250929`) which pin you to an exact model version rather than an alias that may get silently upgraded. Use snapshots in production if you need behavioral stability; use aliases if you want to always get the latest within a tier.
- For the authoritative, current list of model names, context window sizes, max output tokens, and per-model pricing, check the [models overview page](https://docs.claude.com/en/docs/about-claude/models/overview) directly — that's the one place this doesn't go stale on you.

---

## 3. Tool use (function calling)

This is one of the API's most load-bearing features, so I'll go deeper here.

### 3.1 The mental model

Tool use is **not** Claude executing code on Anthropic's servers (with the exception of specific server-side tools — see §3.5). It's a structured way for Claude to say "I need you to run this function with these arguments and tell me what happened." The actual execution is entirely your responsibility. The flow is:

1. You define tools and send a request.
2. Claude decides a tool would help, and responds with `stop_reason: "tool_use"` and a `tool_use` content block containing the tool name and input.
3. **You** execute the tool in your own code/infrastructure.
4. You send a new request with the original messages, Claude's tool-use response appended, and a `tool_result` block containing what your tool returned.
5. Claude reads the result and either calls another tool or produces a final text answer.

### 3.2 Defining a tool

```json
{
  "name": "get_weather",
  "description": "Get the current weather in a given location.",
  "input_schema": {
    "type": "object",
    "properties": {
      "location": {
        "type": "string",
        "description": "The city and state, e.g. San Francisco, CA"
      },
      "unit": {
        "type": "string",
        "enum": ["celsius", "fahrenheit"]
      }
    },
    "required": ["location"]
  }
}
```

`input_schema` is JSON Schema. Two things worth internalizing:

- **`description` quality directly determines tool-use accuracy.** Claude decides _whether_ and _how_ to call a tool based on the description you write, not the tool's actual implementation (which it never sees). A vague description produces vague, wrong, or missed calls.
- The tool definitions themselves consume input tokens on every request, so a large tool roster has a real cost — both in dollars and in the model's ability to pick the right tool.

### 3.3 The full round trip

**Request 1 (you → API):**

```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 1024,
  "tools": [ /* the get_weather tool above */ ],
  "messages": [
    {"role": "user", "content": "What's the weather in San Francisco?"}
  ]
}
```

**Response 1 (API → you):**

```json
{
  "id": "msg_01...",
  "stop_reason": "tool_use",
  "content": [
    {"type": "text", "text": "I'll check the weather for you."},
    {
      "type": "tool_use",
      "id": "toolu_01ABC",
      "name": "get_weather",
      "input": {"location": "San Francisco, CA", "unit": "fahrenheit"}
    }
  ]
}
```

**You now execute `get_weather("San Francisco, CA", "fahrenheit")` yourself.** Say it returns `"68°F, partly cloudy"`.

**Request 2 (you → API) — append the assistant turn verbatim, then a tool_result:**

```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 1024,
  "tools": [ /* same tools array */ ],
  "messages": [
    {"role": "user", "content": "What's the weather in San Francisco?"},
    {"role": "assistant", "content": [
      {"type": "text", "text": "I'll check the weather for you."},
      {"type": "tool_use", "id": "toolu_01ABC", "name": "get_weather", "input": {"location": "San Francisco, CA", "unit": "fahrenheit"}}
    ]},
    {"role": "user", "content": [
      {"type": "tool_result", "tool_use_id": "toolu_01ABC", "content": "68°F, partly cloudy"}
    ]}
  ]
}
```

Note the `tool_result` goes in a **`user`** message, and its `tool_use_id` must match the `id` from the `tool_use` block exactly — this is how Claude correlates the result to the call that produced it.

**Response 2 (API → you):**

```json
{
  "stop_reason": "end_turn",
  "content": [
    {"type": "text", "text": "It's currently 68°F and partly cloudy in San Francisco."}
  ]
}
```

### 3.4 Parallel tool calls and errors

Claude can request multiple tool calls in a single response (several `tool_use` blocks in one `content` array) when the calls are independent — e.g., checking weather in three cities at once. You then return multiple corresponding `tool_result` blocks in the next `user` message, each matched by `tool_use_id`.

If a tool execution fails on your end, don't hide it — return the error _as_ the tool result with `"is_error": true`:

```json
{"type": "tool_result", "tool_use_id": "toolu_01ABC", "content": "Error: location not found", "is_error": true}
```

Claude can then reason about the failure (retry with different input, ask the user for clarification, fall back to another approach) instead of silently hallucinating a result.

### 3.5 Tool choice control

The `tool_choice` parameter controls how eagerly Claude reaches for tools:

- `{"type": "auto"}` — default; Claude decides whether to use a tool.
- `{"type": "any"}` — Claude must use _some_ tool, but you don't pick which.
- `{"type": "tool", "name": "get_weather"}` — force this specific tool.
- `{"type": "none"}` — disable tool use for this call, even if tools are defined (useful when you want to keep the same tools array wired up for later turns but not this one).

### 3.6 Server-side (Anthropic-hosted) tools

Beyond the "you execute it" pattern above, Anthropic offers tools that run on their infrastructure and don't require you to implement anything:

- **Web search** — Claude can search the live web and cite results, useful for anything past its training cutoff.
- **Code execution** — Claude runs code (e.g., Python) in a sandboxed environment.
- **Computer use** — Claude can control a computer via screenshots and simulated mouse/keyboard actions, for browser/desktop automation tasks.

These are invoked the same way (declared in the `tools` array), but you don't write the execution logic — Anthropic's infrastructure handles the `tool_use` → execution → `tool_result` loop internally (sometimes producing the `pause_turn` stop reason for long-running server-side work). Since server-side tools evolve independently of the core API and I don't want to state exact parameter names with false confidence, check the [tool use documentation](https://docs.claude.com/en/docs/agents-and-tools/tool-use/overview) for exact schemas.

### 3.7 Structured output via tools

A very common pattern: define a tool purely to get JSON back, never intending to actually "execute" it in the traditional sense. You force it with `tool_choice`, and Claude's `input` on the resulting `tool_use` block _is_ your structured JSON output, already validated against your schema. This tends to be more reliable than asking Claude to "output JSON" as text and hoping.

---

## 4. Vision (image and document input)

### 4.1 Images

Images are content blocks with `type: "image"`, supplied either as base64 or a URL:

```json
{
  "type": "image",
  "source": {
    "type": "base64",
    "media_type": "image/jpeg",
    "data": "/9j/4AAQSkZJRg..."
  }
}
```

or

```json
{
  "type": "image",
  "source": {
    "type": "url",
    "url": "https://example.com/photo.jpg"
  }
}
```

Supported formats: JPEG, PNG, GIF, and WebP. You can include multiple images in one message; Claude reads them in the order they appear relative to any interleaved text blocks, so if you're referencing "the second image," structure the array so that ordering is unambiguous.

### 4.2 PDFs and documents

Documents use `type: "document"` with the same `source` shape, `media_type: "application/pdf"`. Claude reads both the extracted text _and_ the visual layout (so it can reason about charts, tables, and figures embedded in a PDF, not just raw text) — this is genuinely different from a text-extraction pipeline you'd build yourself.

```json
{
  "type": "document",
  "source": {
    "type": "base64",
    "media_type": "application/pdf",
    "data": "..."
  }
}
```

### 4.3 Practical limits

Large images and multi-page PDFs consume substantial input tokens — a single high-resolution image can be several hundred to over a thousand tokens depending on resolution, and this scales with page count for PDFs. If you're processing many documents, this is often the dominant cost driver, more than the text portions of your prompts.

---

## 5. Extended thinking

For complex reasoning tasks (multi-step math, involved logic puzzles, planning), you can enable **extended thinking**, which gives Claude a dedicated space to reason before producing its final answer:

```json
{
  "model": "claude-sonnet-4-5",
  "max_tokens": 16000,
  "thinking": {
    "type": "enabled",
    "budget_tokens": 10000
  },
  "messages": [{"role": "user", "content": "..."}]
}
```

- `budget_tokens` sets a ceiling on how many tokens Claude can spend thinking, separate from (and counted within) `max_tokens` — so `max_tokens` must exceed `budget_tokens`.
- The response includes a `thinking` content block ahead of the final `text` block, letting you inspect the reasoning process if you want to.
- Thinking blocks are **signed** (a cryptographic signature field) precisely so you can pass them back verbatim in multi-turn conversations without tampering — this preserves reasoning continuity across turns in agentic loops. Don't try to edit or truncate a thinking block you're passing back; treat it as an opaque unit.
- Thinking tokens are billed as output tokens.

This is not something you'd turn on for every request — simple factual Q&A doesn't benefit and just costs more latency/tokens. It earns its keep on genuinely hard multi-step problems, or in agentic tool-use loops where Claude benefits from planning before acting.

---

## 6. Prompt caching

If you're sending the same large chunk of context repeatedly (a long system prompt, a big document, a large tool definitions array) across many requests, prompt caching lets you avoid re-paying full input-token price for that unchanging portion every time.

You mark a cache breakpoint with `cache_control` on a content block:

```json
{
  "system": [
    {
      "type": "text",
      "text": "... a very long, static set of instructions ...",
      "cache_control": {"type": "ephemeral"}
    }
  ],
  "messages": [...]
}
```

Mechanically:

- Anthropic caches everything _up to and including_ the block with `cache_control`.
- Cache writes cost more than a normal input token; cache _reads_ (hits) cost meaningfully less. The economics favor you when the same prefix is reused often enough, soon enough, that the discounted reads outweigh the initial write premium.
- Cache entries have a short time-to-live and refresh on use — so the pattern that benefits most is high-frequency reuse of a stable prefix (e.g., an agent looping many times against the same system prompt and tool definitions within a session), not something you set once and revisit a week later.
- The response includes cache-related token usage fields (cache creation vs. cache read counts) so you can verify caching is actually working and measure the savings, rather than assuming it is.

This is one of the highest-leverage optimizations available if your usage pattern fits — I've seen it cut costs substantially for anything with a large, mostly-static system prompt hit repeatedly (agents, chatbots with long persona instructions, RAG setups with static schemas).

---

## 7. Streaming

Set `"stream": true` and the response arrives as a sequence of **Server-Sent Events (SSE)** instead of one JSON blob — essential for anything user-facing where you want text appearing incrementally rather than the user staring at a spinner for 10+ seconds.

Event types you'll see, roughly in order:

|Event|Purpose|
|---|---|
|`message_start`|Initial message shell (id, model, empty content)|
|`content_block_start`|A new content block (text, tool_use, thinking) is beginning|
|`content_block_delta`|Incremental content — the actual streamed text/JSON fragments|
|`content_block_stop`|That block is complete|
|`message_delta`|Top-level fields changing (e.g., final `stop_reason`)|
|`message_stop`|The full response is done|

Within `content_block_delta`, the `delta` shape differs by block type — `text_delta` for prose, `input_json_delta` for a tool call's arguments streaming in as partial JSON (you accumulate the fragments and parse once complete, not on every chunk), and `thinking_delta` for extended thinking content.

Practically: most official SDKs (Python, TypeScript) give you an async iterator or event-callback interface that handles SSE parsing for you, so you rarely hand-parse the raw event stream unless you're working in a language without SDK support.

---

## 8. Extended context, batching, and files

Briefly, three more pieces worth knowing exist, without me overclaiming specifics that drift:

- **Batch processing** — a separate endpoint for submitting large volumes of non-time-sensitive requests (think: bulk classification, large-scale content generation) at a significant cost discount versus real-time calls, in exchange for asynchronous completion (results come back within a processing window rather than immediately). Good fit for anything where you don't need the answer in the next few seconds.
- **Files API** — lets you upload a file once and reference it by ID across many subsequent requests, rather than re-encoding and re-sending the same base64 blob every single time. Matters most for large PDFs/images reused across many prompts.
- **Token counting endpoint** — a dedicated endpoint to count tokens for a given request _before_ sending it, useful for cost estimation and staying under context limits without a full round trip.

---

## 9. Error handling

Standard HTTP status codes, with a JSON error body describing what went wrong:

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "..."
  }
}
```

Common `error.type` values: `invalid_request_error` (malformed request — check your JSON shape and required fields), `authentication_error` (bad or missing API key), `permission_error`, `not_found_error`, `rate_limit_error` (back off and retry — see below), `overloaded_error` (Anthropic-side capacity issue, also worth retrying), `api_error` (something went wrong on Anthropic's end).

For `rate_limit_error` and `overloaded_error`, the correct handling is **exponential backoff with jitter**, not an immediate hard retry — hammering the API immediately after a 429 tends to make things worse, not better. Official SDKs implement this retry logic for you by default.

---

## 10. SDKs and getting started fastest

Anthropic maintains official SDKs for Python and TypeScript/JavaScript, which wrap all of the above — auth headers, streaming/SSE parsing, retries with backoff, and typed request/response objects — so you're rarely hand-building raw HTTP requests in practice.

Python:

```python
import anthropic

client = anthropic.Anthropic()  # reads ANTHROPIC_API_KEY from env by default

message = client.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello, Claude"}]
)
print(message.content)
```

TypeScript:

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic(); // reads ANTHROPIC_API_KEY from env by default

const message = await client.messages.create({
  model: 'claude-sonnet-4-5',
  max_tokens: 1024,
  messages: [{ role: 'user', content: 'Hello, Claude' }],
});
console.log(message.content);
```

Both also ship helper methods for common patterns — e.g. streaming iterators, and higher-level "run this tool loop until there's no more tool_use" helpers so you're not hand-rolling the round-trip logic from §3.3 every time.

---

## Where this can go stale, and how to check

To be upfront about what I'm confident in versus what I'd verify before shipping code against it:

**Stable — architectural/structural, unlikely to change:** the request/response shape, the tool-use round-trip mechanics, the streaming event model, roles/content-block structure, the general shape of prompt caching and extended thinking.

**Drifts over time — verify before relying on it:** exact model identifiers and their capabilities, specific pricing, exact parameter names for newer/server-side tools (web search, code execution, computer use), rate limit numbers, context window sizes.

For the second bucket, [docs.claude.com](https://docs.claude.com) is the canonical source, and I'd check it directly rather than trust a fixed snapshot — including this one — for anything where being current actually matters (billing decisions, capability claims to a client, production config).