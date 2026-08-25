## Go Modules and Dependency Management


Go modules represent Go's modern dependency management system, introduced in Go 1.11 and becoming the default in Go 1.13. Modules provide versioned dependency management, reproducible builds, and decentralized package distribution.

**Module Initialization**

```bash
go mod init example.com/myproject
```

Creates `go.mod` file defining module path and Go version requirements.

**go.mod File Structure**

```go
module example.com/myproject

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/lib/pq v1.10.9
)

require (
    github.com/bytedance/sonic v1.9.1 // indirect
    github.com/chenzhuoyu/base64x v0.0.0-20221115062448-fe3a3abad311 // indirect
    // ... other indirect dependencies
)

replace github.com/old/package => github.com/new/package v1.2.3

exclude github.com/broken/package v1.0.0
```

**Module Commands**

- `go mod tidy` - adds missing modules, removes unused modules
- `go mod download` - downloads modules to local cache
- `go mod verify` - verifies downloaded modules against checksums
- `go mod graph` - prints module requirement graph
- `go mod why` - explains why modules are needed
- `go mod vendor` - creates vendor directory with dependencies

**Semantic Versioning** Go modules follow semantic versioning (semver):

- `v1.2.3` - major.minor.patch
- `v0.x.y` - pre-v1.0.0 releases
- `v2+` - major version suffixes in module paths

**Version Selection** Go uses Minimal Version Selection (MVS) algorithm:

- Selects minimum version that satisfies all requirements
- Provides deterministic, reproducible builds
- Avoids complex SAT solver approaches

**Module Proxy and Checksums**

- `GOPROXY` - controls module download source
- `GOSUMDB` - verifies module authenticity
- `go.sum` - contains cryptographic checksums
- Default proxy: `https://proxy.golang.org`

**Private Modules**

```bash
export GOPRIVATE=github.com/mycompany/*
export GONOPROXY=github.com/mycompany/*
export GONOSUMDB=github.com/mycompany/*
```

**Workspace Mode** [Inference] Go 1.18+ supports multi-module workspaces:

```bash
go work init ./module1 ./module2
go work use ./module3
```

**Module Best Practices**

- Use semantic import versioning for major versions v2+
- Keep dependencies minimal and up-to-date
- Regular `go mod tidy` to clean unused dependencies
- Commit `go.mod` and `go.sum` to version control
- Use `replace` directives carefully, preferably temporarily

