## Authority Syntax Structure


The authority component follows this hierarchical pattern:

```
authority = [userinfo@]host[:port]
```

All three subcomponents are optional in the general syntax, though specific schemes may impose requirements. The authority appears in the overall URI structure as:

```
scheme://authority/path?query#fragment
```

### Syntax Rules

**Component boundaries:**

- Authority begins after `://` in absolute URIs
- Authority ends at the first `/`, `?`, `#`, or end of string
- Empty authority is valid: `scheme:///path` has an empty authority

**Character restrictions:**

- Must use percent-encoding for characters outside the allowed set
- Different subcomponents have different allowed character sets
- Reserved characters within authority: `@`, `:`, `[`, `]`

**Example:**

```
https://user:password@www.example.com:8080/path
       └──────────────authority─────────────┘
       └─userinfo─┘ └─────host──────┘ └port┘
```

