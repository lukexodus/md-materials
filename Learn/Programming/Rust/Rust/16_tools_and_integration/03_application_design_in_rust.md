## Application Design in Rust


### Architecture Patterns

#### Hexagonal Architecture (Ports and Adapters)

Rust's trait system makes hexagonal architecture particularly elegant. The core business logic sits in the center, isolated from external concerns through well-defined interfaces (ports). Adapters implement these traits to connect to databases, web frameworks, or external services.

```rust
// Domain port
trait UserRepository {
    async fn find_by_id(&self, id: UserId) -> Result<Option<User>, RepositoryError>;
    async fn save(&self, user: User) -> Result<(), RepositoryError>;
}

// Infrastructure adapter
struct PostgresUserRepository {
    pool: PgPool,
}

impl UserRepository for PostgresUserRepository {
    async fn find_by_id(&self, id: UserId) -> Result<Option<User>, RepositoryError> {
        // Database implementation
    }
}
```

#### Layered Architecture

Rust's module system naturally supports layered architecture with clear boundaries between presentation, application, domain, and infrastructure layers. Each layer depends only on lower layers, with the domain layer remaining pure and dependency-free.

#### Actor Model with Tokio

For concurrent systems, Rust's actor model implementation using `tokio` and channels provides excellent isolation and message-passing capabilities. Each actor maintains its own state and communicates through typed channels.

```rust
#[derive(Debug)]
enum UserMessage {
    Create(CreateUserRequest),
    Update(UpdateUserRequest),
    Delete(UserId),
}

struct UserActor {
    repository: Arc<dyn UserRepository>,
    receiver: mpsc::Receiver<UserMessage>,
}
```

#### Event-Driven Architecture

Rust's strong typing and pattern matching make event-driven systems robust. Events are typically modeled as enums, ensuring all possible states are handled at compile time.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
enum DomainEvent {
    UserRegistered { user_id: UserId, email: String },
    UserActivated { user_id: UserId },
    UserDeleted { user_id: UserId },
}
```

### API Design

#### RESTful API Structure

Rust web frameworks like `axum`, `warp`, or `actix-web` provide excellent foundations for REST APIs. The type system ensures request/response contracts are enforced at compile time.

```rust
#[derive(Deserialize)]
struct CreateUserRequest {
    email: String,
    name: String,
}

#[derive(Serialize)]
struct UserResponse {
    id: UserId,
    email: String,
    name: String,
    created_at: DateTime<Utc>,
}

async fn create_user(
    State(app_state): State<AppState>,
    Json(request): Json<CreateUserRequest>,
) -> Result<Json<UserResponse>, ApiError> {
    // Implementation
}
```

#### GraphQL Integration

Libraries like `async-graphql` provide type-safe GraphQL implementations that leverage Rust's compile-time guarantees.

#### gRPC Services

`tonic` offers robust gRPC support with automatic code generation from protobuf definitions, ensuring type safety across service boundaries.

#### Content Negotiation and Versioning

Implement version-aware APIs using extractors and middleware to handle different API versions gracefully.

```rust
#[derive(Debug)]
enum ApiVersion {
    V1,
    V2,
}

impl<S> FromRequestParts<S> for ApiVersion {
    type Rejection = ApiError;
    
    async fn from_request_parts(parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        // Parse version from headers or path
    }
}
```

### Error Handling Strategies

#### Hierarchical Error Types

Create a comprehensive error hierarchy using enums and the `thiserror` crate for automatic trait implementations.

```rust
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    
    #[error("Validation error: {field}: {message}")]
    Validation { field: String, message: String },
    
    #[error("User not found: {id}")]
    UserNotFound { id: UserId },
    
    #[error("Authentication failed")]
    Authentication,
    
    #[error("Authorization failed: {reason}")]
    Authorization { reason: String },
}
```

#### Error Conversion and Propagation

Implement `From` traits for seamless error conversion across layers. Use `anyhow` for application-level error handling and `thiserror` for library-level errors.

```rust
impl From<AppError> for ApiError {
    fn from(err: AppError) -> Self {
        match err {
            AppError::UserNotFound { .. } => ApiError::NotFound(err.to_string()),
            AppError::Validation { .. } => ApiError::BadRequest(err.to_string()),
            AppError::Authentication => ApiError::Unauthorized,
            AppError::Authorization { .. } => ApiError::Forbidden(err.to_string()),
            _ => ApiError::InternalServerError,
        }
    }
}
```

#### Circuit Breaker Pattern

Implement circuit breakers for external service calls to prevent cascade failures.

```rust
#[derive(Debug)]
pub struct CircuitBreaker {
    failure_threshold: u32,
    recovery_timeout: Duration,
    failure_count: AtomicU32,
    last_failure_time: Mutex<Option<Instant>>,
    state: AtomicU8, // 0: Closed, 1: Open, 2: Half-Open
}
```

#### Retry Mechanisms

Use exponential backoff strategies with jitter for transient failures.

```rust
async fn retry_with_backoff<F, T, E, Fut>(
    mut operation: F,
    max_attempts: u32,
    base_delay: Duration,
) -> Result<T, E>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, E>>,
{
    let mut attempts = 0;
    loop {
        match operation().await {
            Ok(result) => return Ok(result),
            Err(e) if attempts >= max_attempts => return Err(e),
            Err(_) => {
                attempts += 1;
                let delay = base_delay * 2_u32.pow(attempts - 1);
                tokio::time::sleep(delay).await;
            }
        }
    }
}
```

### Configuration Management

#### Environment-Based Configuration

Use `serde` and `envy` for environment variable parsing with strong typing.

```rust
#[derive(Debug, Deserialize)]
pub struct Config {
    pub database: DatabaseConfig,
    pub server: ServerConfig,
    pub auth: AuthConfig,
    pub logging: LoggingConfig,
}

#[derive(Debug, Deserialize)]
pub struct DatabaseConfig {
    pub url: String,
    pub max_connections: u32,
    pub timeout: u64,
}

impl Config {
    pub fn from_env() -> Result<Self, ConfigError> {
        envy::from_env::<Config>()
            .map_err(ConfigError::from)
    }
}
```

#### Layered Configuration

Implement configuration layers (defaults, files, environment variables, command-line arguments) with proper precedence.

```rust
pub struct ConfigBuilder {
    sources: Vec<Box<dyn ConfigSource>>,
}

impl ConfigBuilder {
    pub fn new() -> Self {
        Self {
            sources: vec![
                Box::new(DefaultConfigSource),
                Box::new(FileConfigSource::new("config.toml")),
                Box::new(EnvConfigSource),
                Box::new(ArgsConfigSource),
            ],
        }
    }
    
    pub fn build(self) -> Result<Config, ConfigError> {
        let mut config = Config::default();
        for source in self.sources {
            source.apply(&mut config)?;
        }
        Ok(config)
    }
}
```

#### Configuration Validation

Implement comprehensive validation for configuration values.

```rust
impl Config {
    pub fn validate(&self) -> Result<(), ConfigError> {
        if self.database.max_connections == 0 {
            return Err(ConfigError::InvalidValue("database.max_connections must be > 0".into()));
        }
        
        if self.server.port < 1024 || self.server.port > 65535 {
            return Err(ConfigError::InvalidValue("server.port must be between 1024 and 65535".into()));
        }
        
        // Additional validations...
        Ok(())
    }
}
```

#### Hot Reloading

Implement configuration hot reloading using file system watchers.

```rust
pub struct ConfigWatcher {
    config: Arc<RwLock<Config>>,
    _watcher: RecommendedWatcher,
}

impl ConfigWatcher {
    pub fn new(config_path: &Path) -> Result<Self, ConfigError> {
        let config = Arc::new(RwLock::new(Config::load(config_path)?));
        let config_clone = config.clone();
        
        let mut watcher = notify::recommended_watcher(move |res| {
            if let Ok(Event { kind: EventKind::Modify(_), .. }) = res {
                if let Ok(new_config) = Config::load(config_path) {
                    *config_clone.write().unwrap() = new_config;
                }
            }
        })?;
        
        watcher.watch(config_path, RecursiveMode::NonRecursive)?;
        
        Ok(Self {
            config,
            _watcher: watcher,
        })
    }
}
```

### Logging and Observability

#### Structured Logging with Tracing

Use the `tracing` ecosystem for structured, contextual logging that integrates seamlessly with async code.

```rust
use tracing::{info, error, instrument, Span};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[instrument(skip(repository))]
async fn create_user(
    repository: &dyn UserRepository,
    request: CreateUserRequest,
) -> Result<User, AppError> {
    let span = Span::current();
    span.record("user.email", &request.email);
    
    info!("Creating new user");
    
    let user = User::new(request.email, request.name)?;
    repository.save(user.clone()).await?;
    
    info!("User created successfully");
    Ok(user)
}

pub fn init_tracing() {
    tracing_subscriber::registry()
        .with(tracing_subscriber::fmt::layer())
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .init();
}
```

#### Metrics Collection

Integrate with Prometheus using `prometheus` or `metrics` crates for comprehensive application metrics.

```rust
use metrics::{counter, histogram, gauge};

#[derive(Debug)]
pub struct Metrics {
    pub requests_total: Counter,
    pub request_duration: Histogram,
    pub active_connections: Gauge,
}

impl Metrics {
    pub fn new() -> Self {
        Self {
            requests_total: counter!("http_requests_total"),
            request_duration: histogram!("http_request_duration_seconds"),
            active_connections: gauge!("active_connections"),
        }
    }
    
    pub fn record_request(&self, method: &str, path: &str, status: u16, duration: Duration) {
        self.requests_total.increment(&[
            ("method", method),
            ("path", path),
            ("status", &status.to_string()),
        ]);
        self.request_duration.record(duration.as_secs_f64(), &[
            ("method", method),
            ("path", path),
        ]);
    }
}
```

#### Distributed Tracing

Implement distributed tracing with OpenTelemetry for microservices architectures.

```rust
use opentelemetry::{global, sdk::trace::TracerProvider};
use opentelemetry_jaeger::JaegerTraceExporter;
use tracing_opentelemetry::OpenTelemetryLayer;

pub fn init_telemetry() -> Result<(), Box<dyn std::error::Error>> {
    let tracer = opentelemetry_jaeger::new_collector_pipeline()
        .with_service_name("my-rust-service")
        .with_endpoint("http://localhost:14268/api/traces")
        .build_batch(opentelemetry::runtime::Tokio)?;
    
    let telemetry = OpenTelemetryLayer::new(tracer);
    
    tracing_subscriber::registry()
        .with(telemetry)
        .with(tracing_subscriber::fmt::layer())
        .init();
    
    Ok(())
}
```

#### Health Checks and Readiness Probes

Implement comprehensive health checking for service dependencies.

```rust
#[derive(Debug, Serialize)]
pub struct HealthStatus {
    pub status: String,
    pub version: String,
    pub uptime: u64,
    pub dependencies: HashMap<String, DependencyHealth>,
}

#[derive(Debug, Serialize)]
pub struct DependencyHealth {
    pub status: String,
    pub response_time_ms: u64,
    pub last_error: Option<String>,
}

#[async_trait]
pub trait HealthChecker: Send + Sync {
    async fn check_health(&self) -> DependencyHealth;
}

pub struct DatabaseHealthChecker {
    pool: PgPool,
}

#[async_trait]
impl HealthChecker for DatabaseHealthChecker {
    async fn check_health(&self) -> DependencyHealth {
        let start = Instant::now();
        match sqlx::query("SELECT 1").fetch_one(&self.pool).await {
            Ok(_) => DependencyHealth {
                status: "healthy".to_string(),
                response_time_ms: start.elapsed().as_millis() as u64,
                last_error: None,
            },
            Err(e) => DependencyHealth {
                status: "unhealthy".to_string(),
                response_time_ms: start.elapsed().as_millis() as u64,
                last_error: Some(e.to_string()),
            },
        }
    }
}
```

### State Management

#### Application State Pattern

Design centralized application state that can be safely shared across request handlers.

```rust
#[derive(Clone)]
pub struct AppState {
    pub database: Arc<dyn Database>,
    pub redis: Arc<Redis>,
    pub config: Arc<Config>,
    pub metrics: Arc<Metrics>,
    pub event_bus: Arc<EventBus>,
}

impl AppState {
    pub fn new(config: Config) -> Result<Self, AppError> {
        let database = Arc::new(PostgresDatabase::new(&config.database)?);
        let redis = Arc::new(Redis::new(&config.redis)?);
        let metrics = Arc::new(Metrics::new());
        let event_bus = Arc::new(EventBus::new());
        
        Ok(Self {
            database,
            redis,
            config: Arc::new(config),
            metrics,
            event_bus,
        })
    }
}
```

#### Session Management

Implement secure session management with configurable storage backends.

```rust
#[async_trait]
pub trait SessionStore: Send + Sync {
    async fn create_session(&self, user_id: UserId) -> Result<SessionId, SessionError>;
    async fn get_session(&self, session_id: &SessionId) -> Result<Option<Session>, SessionError>;
    async fn update_session(&self, session: &Session) -> Result<(), SessionError>;
    async fn delete_session(&self, session_id: &SessionId) -> Result<(), SessionError>;
}

pub struct RedisSessionStore {
    client: redis::Client,
    ttl: Duration,
}

#[async_trait]
impl SessionStore for RedisSessionStore {
    async fn create_session(&self, user_id: UserId) -> Result<SessionId, SessionError> {
        let session_id = SessionId::new();
        let session = Session {
            id: session_id.clone(),
            user_id,
            created_at: Utc::now(),
            expires_at: Utc::now() + chrono::Duration::from_std(self.ttl)?,
        };
        
        let mut conn = self.client.get_async_connection().await?;
        let serialized = serde_json::to_string(&session)?;
        
        conn.set_ex(&session_id.to_string(), serialized, self.ttl.as_secs()).await?;
        
        Ok(session_id)
    }
}
```

#### Caching Strategies

Implement multi-level caching with cache-aside, write-through, and write-behind patterns.

```rust
#[async_trait]
pub trait Cache: Send + Sync {
    async fn get<T>(&self, key: &str) -> Result<Option<T>, CacheError>
    where
        T: DeserializeOwned;
    
    async fn set<T>(&self, key: &str, value: &T, ttl: Option<Duration>) -> Result<(), CacheError>
    where
        T: Serialize;
    
    async fn delete(&self, key: &str) -> Result<(), CacheError>;
}

pub struct LayeredCache {
    l1: Arc<dyn Cache>, // Memory cache
    l2: Arc<dyn Cache>, // Redis cache
}

#[async_trait]
impl Cache for LayeredCache {
    async fn get<T>(&self, key: &str) -> Result<Option<T>, CacheError>
    where
        T: DeserializeOwned,
    {
        // Try L1 cache first
        if let Some(value) = self.l1.get(key).await? {
            return Ok(Some(value));
        }
        
        // Try L2 cache
        if let Some(value) = self.l2.get(key).await? {
            // Populate L1 cache
            self.l1.set(key, &value, Some(Duration::from_secs(300))).await?;
            return Ok(Some(value));
        }
        
        Ok(None)
    }
}
```

#### Event Sourcing

Implement event sourcing for complex domain models requiring full audit trails.

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EventRecord {
    pub id: EventId,
    pub aggregate_id: AggregateId,
    pub event_type: String,
    pub event_data: Value,
    pub version: u64,
    pub timestamp: DateTime<Utc>,
}

#[async_trait]
pub trait EventStore: Send + Sync {
    async fn append_events(
        &self,
        aggregate_id: AggregateId,
        events: Vec<DomainEvent>,
        expected_version: u64,
    ) -> Result<(), EventStoreError>;
    
    async fn load_events(
        &self,
        aggregate_id: AggregateId,
        from_version: u64,
    ) -> Result<Vec<EventRecord>, EventStoreError>;
}

pub trait Aggregate: Sized {
    type Event: DomainEvent;
    
    fn apply_event(&mut self, event: &Self::Event);
    
    fn load_from_history(events: Vec<Self::Event>) -> Self {
        let mut aggregate = Self::default();
        for event in events {
            aggregate.apply_event(&event);
        }
        aggregate
    }
}
```

**Key Points:**

- Rust's ownership system and type safety provide excellent foundations for robust application design
- The trait system enables clean abstraction boundaries and dependency injection
- Async/await with tokio provides efficient concurrent processing
- Strong typing catches many architectural mistakes at compile time
- Error handling is explicit and composable through the Result type
- Configuration management should leverage Rust's serialization ecosystem
- Observability integrates naturally with async contexts through tracing
- State management patterns benefit from Rust's concurrency primitives and Arc/Mutex patterns

Important subtopics to explore further include database connection pooling strategies, message queue integration patterns, authentication/authorization middleware design, and deployment strategies for Rust applications.

---

