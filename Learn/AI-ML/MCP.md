# Model Context Protocol (MCP): A Comprehensive Guide

## What Is MCP?

Model Context Protocol (MCP) is an open standard developed by Anthropic that defines how AI models communicate with external tools, data sources, and services. It provides a common interface so that an AI assistant can connect to many different systems — databases, APIs, file systems, calendars, code editors — without each integration needing to be built from scratch in a custom, one-off way.

Think of it as USB for AI: a standardized plug that lets any compatible device connect to any compatible host.

MCP was publicly released by Anthropic in November 2024 and has since been adopted by a growing ecosystem of developers and tool providers.

---

## Core Concepts

### Hosts, Clients, and Servers

MCP defines three roles in every interaction:

- **Host** — the application the user interacts with (e.g., Claude.ai, Claude Desktop, an IDE). The host manages the overall session and user experience.
- **Client** — a component inside the host that speaks the MCP protocol on behalf of the host. Each client maintains a one-to-one connection with one server.
- **Server** — a lightweight process or remote service that exposes tools, resources, or prompts to the client. Servers do the actual work: querying a database, reading a file, calling an API.

A single host can run multiple clients simultaneously, meaning it can talk to many servers at once.

### The Three Primitives

MCP servers expose capabilities through three building blocks:

#### Tools

Tools are callable functions. The model can invoke a tool by name, pass arguments, and receive a result. Examples: searching the web, creating a calendar event, running a SQL query. Tools are the most commonly used primitive.

#### Resources

Resources are read-only data that a server exposes for the model to consume. They function similarly to files or documents — the model can read them to gain context. Examples: a file's contents, a database record, a webpage.

#### Prompts

Prompts are pre-defined, reusable message templates or workflows stored on the server. They can be surfaced to users or injected into conversations to guide model behavior in structured ways.

---

## How MCP Works

### Transport Layer

MCP supports two primary transport mechanisms:

- **stdio (Standard Input/Output)** — the server runs as a local subprocess, and the client communicates with it over stdin/stdout. This is the most common method for local tools (e.g., a filesystem server running on your machine).
- **HTTP with SSE (Server-Sent Events)** — the server is a remote HTTP service. The client sends requests via HTTP POST and receives streaming responses via SSE. This is used for remote or cloud-hosted MCP servers.

### Message Format

MCP uses **JSON-RPC 2.0** as its message format. All communication — requests, responses, and notifications — is structured as JSON-RPC messages. This is a well-established, lightweight protocol.

### Session Lifecycle

1. **Initialization** — the client connects and exchanges capability declarations with the server. Each side announces what it supports.
2. **Operation** — the model issues requests (tool calls, resource reads, prompt fetches) and the server responds.
3. **Shutdown** — the session is cleanly terminated.

---

## MCP Architecture Patterns

### Local MCP Servers

A server runs as a process on the user's own machine. The host spawns it as a child process and communicates over stdio. This is appropriate for tools that need local system access: reading files, running terminal commands, interacting with local applications.

### Remote MCP Servers

A server runs on a remote host and is accessed over the network via HTTP + SSE. This is appropriate for cloud services, shared team infrastructure, or any tool that doesn't need local access. Authentication is handled at the HTTP layer (e.g., OAuth, API keys in headers).

### Multi-Server Setups

A single AI session can connect to many MCP servers simultaneously. For example, a developer might have Claude connected to:

- A filesystem server (local)
- A GitHub server (remote)
- A Postgres database server (local or remote)
- A web search server (remote)

Each server is isolated; they do not communicate with each other directly.

---

## Security Model

### Server Isolation

Each MCP server runs in its own process and is sandboxed from others. A compromised or malicious server cannot directly access the capabilities of another server in the same session.

### Trust Boundaries

MCP draws explicit trust boundaries:

- **Hosts** are trusted to manage user consent and control which servers are connected.
- **Servers** should be granted only the permissions they need (principle of least privilege).
- **Users** must explicitly approve connections to MCP servers. Tools should not be invoked without user awareness.

### Prompt Injection Risk

[Inference] Because MCP tools can return arbitrary text that the model reads, a malicious server — or malicious content returned by a legitimate server — could attempt to inject instructions into the model's context. This is an active area of concern in the MCP security community. Mitigations include careful tool output handling and user confirmation flows. _Note: The effectiveness of any specific mitigation is not guaranteed; LLM behavior in adversarial conditions is subject to ongoing research and cannot be certified._

### Authentication

MCP itself does not mandate a specific authentication scheme. Remote servers typically use standard HTTP authentication patterns (OAuth 2.0, bearer tokens, API keys). Local servers rely on OS-level process isolation.

---

## Building an MCP Server

### What You Need

MCP servers can be written in any language that can handle JSON over stdio or HTTP. Anthropic and the community provide official SDKs for:

- **TypeScript / JavaScript** (`@modelcontextprotocol/sdk`)
- **Python** (`mcp` package via PyPI)

Community SDKs exist for other languages including Go, Rust, Java, and C#. [Unverified: the completeness and maintenance status of individual community SDKs varies and should be verified before use.]

### Minimal Server Structure (Conceptual)

A basic MCP server does the following:

1. Declares its name, version, and capabilities during initialization.
2. Registers one or more tools, each with:
    - A unique name
    - A description (used by the model to decide when to call it)
    - A JSON Schema defining its input parameters
    - A handler function that executes when the tool is called
3. Starts listening (on stdio or HTTP) for incoming requests.

### Tool Description Quality

The natural-language description of a tool is important. The model uses it to decide whether and when to invoke the tool. Vague or misleading descriptions can cause tools to be called at wrong times or ignored entirely. [Inference] Clear, specific descriptions with examples of when to use (and not use) the tool tend to improve reliability, though behavior is not guaranteed.

### Error Handling

Servers should return structured errors rather than crashing. MCP defines an error response format that tells the client what went wrong, allowing the model and host to handle failures gracefully.

---

## Using MCP as a Consumer

### Claude Desktop

Claude Desktop supports local MCP servers configured via a JSON configuration file (`claude_desktop_config.json`). Each entry specifies a server name, the command to launch it, and any environment variables it needs.

### Claude.ai

Claude.ai supports remote MCP servers for connected users, allowing integrations with third-party services through Anthropic's connector directory.

### The Anthropic API

Developers using the Anthropic API directly can pass MCP server configurations as part of the API request. This allows server-side tool use without requiring a desktop application.

---

## The MCP Ecosystem

### Official Servers (by Anthropic)

Anthropic maintains a set of reference server implementations, including servers for:

- Local filesystem access
- Git repositories
- Web fetch / browser automation
- Memory (key-value store)
- Sequential thinking (a reasoning scaffold)

These live in the official `modelcontextprotocol/servers` GitHub repository.

### Community and Third-Party Servers

A large and growing number of third-party MCP servers exist, contributed by companies and individual developers. Common categories include:

- Code and development tools (GitHub, GitLab, Jira, Linear)
- Productivity and communication (Google Drive, Notion, Slack, email)
- Databases (PostgreSQL, SQLite, MongoDB)
- Cloud platforms (AWS, GCP tools)
- Search and web (Brave Search, Exa, Tavily)

[Unverified: the availability, quality, and security of any specific third-party server should be independently assessed before use.]

### MCP Registry / Discovery

As of early 2025, there is no single authoritative central registry for all MCP servers. Discovery currently happens through GitHub, community lists, and platform-specific directories. [Inference] This is likely to evolve as the ecosystem matures, but no confirmed universal registry standard existed at the time of writing.

---

## MCP vs. Other Approaches

### MCP vs. Function Calling (Tool Use)

Standard function/tool calling in LLM APIs (including Anthropic's) lets you define tools inline per request. MCP extends this by:

- Moving tool definitions out of the request and into persistent servers
- Enabling tool reuse across many sessions and applications
- Standardizing how tools are discovered and invoked across different AI systems

MCP tool calls ultimately resolve to function calls under the hood; MCP is the coordination layer above them.

### MCP vs. Plugins (e.g., OpenAI Plugins)

OpenAI's plugin system (now largely superseded) used OpenAPI specs served over HTTP. MCP is more general: it supports tools, resources, and prompts; it works locally and remotely; and it is designed as an open, model-agnostic standard rather than a product-specific feature.

### MCP vs. Direct API Integration

Calling a third-party API directly (inside your application logic) gives you full control but requires bespoke integration for every API. MCP gives up some control in exchange for standardization, reusability, and the ability to let the model decide dynamically which tools to call.

---

## Limitations and Honest Caveats

- **Spec compliance varies.** Not all servers labeled "MCP-compatible" implement the full spec correctly. [Unverified: behavior of third-party servers should be tested, not assumed.]
- **Model behavior is not guaranteed.** Even with a well-described tool, the model may call it at unexpected times, fail to call it when appropriate, or misinterpret its outputs. [Inference, with disclaimer: these are observed patterns, but LLM behavior cannot be certified.]
- **Security is the server author's responsibility.** MCP provides a structure, but does not enforce what a server does with its permissions. Connecting to an untrusted server carries real risk.
- **Performance overhead.** Each tool call involves a round-trip to the server. For latency-sensitive applications, this matters and should be measured.
- **Evolving standard.** MCP is relatively new. Parts of the specification may change, and tooling is still maturing.

---

## Glossary

|Term|Meaning|
|---|---|
|Host|The user-facing application (e.g., Claude Desktop)|
|Client|The in-process MCP protocol handler inside the host|
|Server|The external process or service exposing tools/resources|
|Tool|A callable function exposed by a server|
|Resource|Read-only data exposed by a server|
|Prompt|A reusable prompt template stored on a server|
|stdio|Local transport via standard input/output|
|SSE|Server-Sent Events; used for HTTP-based streaming transport|
|JSON-RPC 2.0|The message format used by MCP|