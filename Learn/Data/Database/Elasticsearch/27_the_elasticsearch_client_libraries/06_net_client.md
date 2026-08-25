## .NET Client

### Overview

Elastic's official .NET client, `Elastic.Clients.Elasticsearch`, provides a strongly typed API for interacting with Elasticsearch from C# and other .NET languages, following patterns idiomatic to the .NET ecosystem (fluent builders, LINQ-influenced expression syntax, and integration with .NET's standard dependency injection and configuration conventions). It succeeded an earlier client generation (NEST and Elasticsearch.Net) as the current recommended client.

### Client Setup

```csharp
var settings = new ElasticsearchClientSettings(new Uri("https://localhost:9200"))
    .Authentication(new ApiKey("your-api-key"))
    .DefaultIndex("products");

var client = new ElasticsearchClient(settings);
```

**Key Points**
- `ElasticsearchClientSettings` configures connection details — node URIs, authentication, default index, and serializer options — separately from the client instance itself.
- `DefaultIndex` sets a fallback index for requests that don't explicitly specify one, reducing repetition when an application predominantly works against a single index.
- The client supports both API key and basic authentication, following the same general authentication patterns described for clients broadly in the earlier overview topic.

### Two Query Construction Styles: Fluent and Object Initializer

**Key Points**
- The .NET client supports two parallel syntaxes for building requests: a **fluent lambda-based syntax** and an **object initializer syntax**, both producing equivalent requests, letting developers pick whichever fits their team's style preferences.
- Fluent syntax chains lambda expressions in a builder pattern, similar in spirit to the Java client's lambda builders covered previously.
- Object initializer syntax constructs the request as a direct object graph using C#'s object/collection initializer syntax, which some developers find more readable for deeply nested query structures since it more directly mirrors the resulting JSON's shape.

```csharp
// Fluent syntax
var response = await client.SearchAsync<Product>(s => s
    .Index("products")
    .Query(q => q
        .Match(m => m
            .Field(f => f.Name)
            .Query("elasticsearch")
        )
    )
);

// Object initializer syntax
var response = await client.SearchAsync<Product>(new SearchRequest<Product>("products")
{
    Query = new MatchQuery(new Field("name")) { Query = "elasticsearch" }
});
```

### Diagram: Two Syntax Styles, One Request Model

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Fluent and object initializer syntax producing the same request (svg_diagram)</title><desc>Both the fluent lambda-based syntax and the object initializer syntax in the dotnet client compile down to the same underlying request object sent to Elasticsearch.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="150" y="50" text-anchor="middle" dominant-baseline="central">Fluent syntax</text>
<text class="ts" x="150" y="70" text-anchor="middle" dominant-baseline="central">Lambda builder chain</text>
</g>

<g class="node c-teal">
<rect x="420" y="30" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="530" y="50" text-anchor="middle" dominant-baseline="central">Object initializer</text>
<text class="ts" x="530" y="70" text-anchor="middle" dominant-baseline="central">Direct object graph</text>
</g>

<line x1="150" y1="86" x2="300" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="530" y1="86" x2="380" y2="150" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="240" y="150" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="170" text-anchor="middle" dominant-baseline="central">SearchRequest object</text>
<text class="ts" x="340" y="190" text-anchor="middle" dominant-baseline="central">Same underlying model</text>
</g>

<line x1="340" y1="206" x2="340" y2="240" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="340" y="250" text-anchor="middle">Serialized and sent to Elasticsearch</text>
</svg>

### Source Serialization and Strongly Typed Documents

**Key Points**
- Documents indexed and retrieved through the client can be represented as strongly typed C# classes, with the client handling JSON serialization/deserialization between those classes and Elasticsearch's document format via `System.Text.Json` (the current default serializer).
- Property name mapping between C# naming conventions (PascalCase, by .NET convention) and Elasticsearch field naming conventions (commonly camelCase or snake_case) is handled through the client's default naming policy or explicit attribute-based overrides, similar in purpose to Jackson annotations in the Java client.

```csharp
public class Product
{
    public string Name { get; set; }
    public decimal Price { get; set; }
}

var indexResponse = await client.IndexAsync(
    new Product { Name = "Widget", Price = 9.99m },
    idx => idx.Index("products")
);
```

### Async-First Design

**Key Points**
- The .NET client is async-first, with essentially every API method exposed as a `Task`-returning `*Async` method (`SearchAsync`, `IndexAsync`, `BulkAsync`), aligning with idiomatic .NET conventions where async is the default expectation for I/O-bound operations rather than an alternate mode.
- Synchronous equivalents are generally also available, but the async methods represent the primary, recommended usage pattern in current .NET application development.

### Bulk Operations

**Key Points**
- The client provides a `BulkAllObservable` helper (accessed via `client.BulkAll(...)`) for streaming large volumes of documents through the bulk API with automatic batching, retry, and backpressure handling, conceptually parallel to the `BulkIngester` helper in the Java client and the bulk helpers in other official clients.
- This integrates with .NET's `IObservable` reactive extensions pattern, allowing subscription to progress and completion events during a long-running bulk operation.

### Dependency Injection Integration

[Inference] Because .NET application architecture commonly relies on built-in dependency injection, the client is typically registered as a singleton service in an application's DI container during startup configuration, letting it be injected into services and controllers throughout the application rather than being manually instantiated at each call site — this is a standard .NET application pattern generally, applied to the Elasticsearch client as it would be to any other injected service dependency.

### Migration from NEST

**Key Points**
- NEST was the previous-generation .NET client, and the current `Elastic.Clients.Elasticsearch` client represents a substantial redesign rather than an incremental update.
- [Unverified] The specific breaking changes and migration steps between NEST and the current client are extensive enough that Elastic's own migration documentation should be consulted directly for applications undertaking this migration, rather than relying on a general summary.

### Related Topics

- **Official clients overview** (earlier topic) for cross-language comparison of client design
- **Java client** (previous topic) as a comparison point for typed-client design across languages
- **`System.Text.Json` customization** for advanced serialization scenarios in the .NET client
- **NEST to `Elastic.Clients.Elasticsearch` migration guide** in depth
- **API key authentication** setup shared across official clients
- **Bulk API mechanics** underlying the `BulkAllObservable` helper's batching behavior