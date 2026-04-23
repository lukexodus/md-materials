# Gradle

A build automation tool for JVM (and beyond) projects. Gradle builds are defined in Groovy or Kotlin DSL scripts and model your project as a directed acyclic graph of tasks.

> Gradle is the standard build tool for Android projects and widely used for Java, Kotlin, Scala, and Groovy projects. It replaced Maven and Ant in most modern JVM ecosystems.

**Official docs:** `docs.gradle.org`

---

## Table of Contents

1. [What is Gradle?](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#what-is-gradle)
2. [Installation](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#installation)
3. [The Gradle Wrapper](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#the-gradle-wrapper)
4. [Project Structure](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#project-structure)
5. [Build Scripts](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#build-scripts)
6. [Tasks](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#tasks)
7. [Dependencies](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#dependencies)
8. [Plugins](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#plugins)
9. [Multi-project Builds](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#multi-project-builds)
10. [The Build Lifecycle](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#the-build-lifecycle)
11. [Configuration & Properties](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#configuration--properties)
12. [Testing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#testing)
13. [Publishing](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#publishing)
14. [Build Cache & Performance](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#build-cache--performance)
15. [Dependency Locking & Verification](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#dependency-locking--verification)
16. [Common CLI Commands](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#common-cli-commands)
17. [Practical Tips](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#practical-tips)
18. [Quick Cheatsheet](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#quick-cheatsheet)

---

## What is Gradle?

Gradle is a build tool that describes builds as code. A Gradle build consists of:

- One or more **projects** (root + subprojects)
- Each project has **tasks** — units of work (compile, test, jar, publish, etc.)
- Tasks have **dependencies** on other tasks, forming a DAG
- **Plugins** contribute pre-built tasks and conventions (e.g. the `java` plugin adds `compileJava`, `test`, `jar`)
- **Dependencies** are declared per configuration (compile, runtime, test, etc.) and resolved from repositories

Builds are written in either:

- **Kotlin DSL** — `build.gradle.kts` (recommended for new projects; IDE support is better)
- **Groovy DSL** — `build.gradle` (older default; still widely used)

This guide shows both where they differ.

---

## Installation

### Recommended: use the Gradle Wrapper

In most projects you should **not** install Gradle globally — use the wrapper (`./gradlew`) that is checked into the repo. See [The Gradle Wrapper](https://claude.ai/chat/964f3045-a161-442c-a84c-1a0249a23a6f#the-gradle-wrapper).

### Manual installation

```sh
# macOS — Homebrew
brew install gradle

# SDKMAN (macOS / Linux — recommended for managing versions)
sdk install gradle
sdk install gradle 8.7       # specific version
sdk use gradle 8.7           # switch version in current shell

# Windows — Scoop
scoop install gradle

# Windows — Chocolatey
choco install gradle
```

Verify: `gradle --version`

---

## The Gradle Wrapper

The wrapper is a shell script (`gradlew` / `gradlew.bat`) checked into the repo that downloads and uses a specific Gradle version. This means every developer and CI system uses the same Gradle version automatically.

**Always use `./gradlew` (or `gradlew.bat`) instead of the global `gradle` command.**

### Wrapper files

```
project/
├── gradlew               ← Unix shell script
├── gradlew.bat           ← Windows batch script
└── gradle/
    └── wrapper/
        ├── gradle-wrapper.jar
        └── gradle-wrapper.properties
```

### `gradle-wrapper.properties`

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

Change `distributionUrl` to upgrade the Gradle version for the project.

### Generate or upgrade the wrapper

```sh
# Generate wrapper files (requires global gradle)
gradle wrapper

# Upgrade to a specific version
gradle wrapper --gradle-version 8.7

# Or update gradle-wrapper.properties manually and run:
./gradlew wrapper
```

### First run

The first `./gradlew` invocation downloads the specified Gradle distribution and caches it in `~/.gradle/wrapper/dists/`.

---

## Project Structure

### Single project

```
project/
├── build.gradle.kts      ← build script
├── settings.gradle.kts   ← project name, subproject declarations
├── gradle.properties     ← project/system properties
├── gradlew
├── gradlew.bat
├── gradle/wrapper/
└── src/
    ├── main/
    │   ├── java/
    │   ├── kotlin/
    │   └── resources/
    └── test/
        ├── java/
        ├── kotlin/
        └── resources/
```

### `settings.gradle.kts`

Every Gradle project must have a settings file. It declares the project name and any subprojects:

```kotlin
// settings.gradle.kts
rootProject.name = "my-app"
```

---

## Build Scripts

### Minimal Java project

**Kotlin DSL (`build.gradle.kts`):**

```kotlin
plugins {
    java
}

group = "com.example"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}
```

**Groovy DSL (`build.gradle`):**

```groovy
plugins {
    id 'java'
}

group = 'com.example'
version = '1.0.0'

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

test {
    useJUnitPlatform()
}
```

### Kotlin application project

```kotlin
plugins {
    kotlin("jvm") version "2.0.0"
    application
}

application {
    mainClass = "com.example.MainKt"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    testImplementation(kotlin("test"))
}
```

---

## Tasks

Tasks are the fundamental unit of work in Gradle. The `java` plugin contributes a standard task graph; you can also define your own.

### Running tasks

```sh
./gradlew taskName                  # run a task
./gradlew build                     # compile, test, assemble
./gradlew clean                     # delete build outputs
./gradlew test                      # run tests
./gradlew assemble                  # build artifacts without running tests
./gradlew check                     # run all verification tasks (tests, lint, etc.)
./gradlew clean build               # chain tasks
./gradlew :subproject:taskName      # run task in a specific subproject
```

### Listing tasks

```sh
./gradlew tasks                     # show main tasks
./gradlew tasks --all               # show all tasks including dependencies
./gradlew :subproject:tasks         # tasks for a specific subproject
```

### Defining custom tasks

**Kotlin DSL:**

```kotlin
// Simple task
tasks.register("hello") {
    doLast {
        println("Hello, Gradle!")
    }
}

// Task with type
tasks.register<Copy>("copyDocs") {
    from("docs")
    into(layout.buildDirectory.dir("output/docs"))
}

// Task depending on another task
tasks.register("greet") {
    dependsOn("hello")
    doLast {
        println("Greetings from greet task")
    }
}
```

**Groovy DSL:**

```groovy
tasks.register('hello') {
    doLast {
        println 'Hello, Gradle!'
    }
}

tasks.register('copyDocs', Copy) {
    from 'docs'
    into layout.buildDirectory.dir('output/docs')
}
```

### Task phases: `doFirst` and `doLast`

```kotlin
tasks.named("build") {
    doFirst {
        println("About to build...")   // runs before existing build actions
    }
    doLast {
        println("Build done.")         // runs after existing build actions
    }
}
```

### Skipping tasks

```kotlin
tasks.register("maybeSkip") {
    onlyIf { System.getenv("RUN_TASK") != null }
    doLast { println("Running") }
}
```

### Task inputs and outputs

Declaring inputs/outputs enables incremental builds and the build cache:

```kotlin
tasks.register<Exec>("generateCode") {
    inputs.file("schema.json")
    outputs.dir(layout.buildDirectory.dir("generated"))
    commandLine("./codegen.sh", "schema.json")
}
```

If inputs have not changed since last run, Gradle skips the task (UP-TO-DATE).

---

## Dependencies

Dependencies are declared in `configurations`. The Java plugin provides standard configurations.

### Common configurations

|Configuration|Purpose|
|---|---|
|`implementation`|Compile + runtime; not exposed to consumers|
|`api`|Compile + runtime; exposed to consumers (requires `java-library` plugin)|
|`compileOnly`|Compile only; not included at runtime|
|`runtimeOnly`|Runtime only; not on compile classpath|
|`testImplementation`|Test compile + runtime|
|`testCompileOnly`|Test compile only|
|`testRuntimeOnly`|Test runtime only|

> `implementation` hides dependencies from consumers of your library, which speeds up compilation and avoids leaking transitive deps. Use `api` only when the type truly appears in your public API.

### Declaring dependencies

```kotlin
dependencies {
    // External library — group:artifact:version
    implementation("com.google.guava:guava:33.2.0-jre")

    // Kotlin stdlib shorthand
    implementation(kotlin("stdlib"))

    // Platform / BOM (Bill of Materials) — align versions
    implementation(platform("org.springframework.boot:spring-boot-dependencies:3.3.0"))
    implementation("org.springframework.boot:spring-boot-starter-web") // no version needed

    // Project dependency (in multi-project builds)
    implementation(project(":core"))

    // File dependency
    implementation(files("libs/external.jar"))
    implementation(fileTree("libs") { include("*.jar") })

    // Test dependencies
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}
```

### Repositories

```kotlin
repositories {
    mavenCentral()                           // Maven Central
    google()                                 // Google Maven (required for Android)
    gradlePluginPortal()                     // Gradle plugin portal
    mavenLocal()                             // ~/.m2/repository

    // Custom Maven repo
    maven {
        url = uri("https://repo.example.com/maven")
        credentials {
            username = providers.gradleProperty("repoUser").get()
            password = providers.gradleProperty("repoPass").get()
        }
    }
}
```

### Viewing the dependency tree

```sh
./gradlew dependencies                       # all configurations
./gradlew dependencies --configuration runtimeClasspath
./gradlew :subproject:dependencies
```

### Resolving version conflicts

Gradle uses the **highest requested version** strategy by default. You can force or strictly constrain a version:

```kotlin
dependencies {
    implementation("com.example:lib") {
        version {
            strictly("1.2.3")      // fail if anything else is requested
        }
    }
}

// Or globally via resolution strategy
configurations.all {
    resolutionStrategy {
        force("com.example:lib:1.2.3")
    }
}
```

### Excluding transitive dependencies

```kotlin
dependencies {
    implementation("com.example:lib:1.0") {
        exclude(group = "org.unwanted", module = "dep")
    }
}
```

---

## Plugins

Plugins add tasks, configurations, and conventions to your build.

### Core plugins (built-in)

```kotlin
plugins {
    java                            // Java compilation, test, jar
    `java-library`                  // java + api configuration
    application                     // runnable JVM application
    `maven-publish`                 // publish to Maven repos
    signing                         // sign artifacts
    kotlin("jvm") version "2.0.0"  // Kotlin JVM support
}
```

### Community plugins (from Gradle Plugin Portal)

```kotlin
plugins {
    id("com.google.protobuf") version "0.9.4"
    id("org.springframework.boot") version "3.3.0"
    id("io.freefair.lombok") version "8.6"
    id("com.github.johnrengelman.shadow") version "8.1.1"   // fat/uber JARs
}
```

### Applying plugins in subprojects

In `build.gradle.kts` at the root or in a subproject:

```kotlin
// Apply to all subprojects
subprojects {
    apply(plugin = "java")
    apply(plugin = "checkstyle")
}
```

### Convention plugins (recommended for multi-project)

Store shared build logic in `buildSrc/` or in an included build. This is the modern way to share configuration:

```
buildSrc/
├── build.gradle.kts
└── src/main/kotlin/
    └── my-java-conventions.gradle.kts
```

```kotlin
// buildSrc/src/main/kotlin/my-java-conventions.gradle.kts
plugins {
    java
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}
```

Then in any subproject:

```kotlin
plugins {
    id("my-java-conventions")
}
```

---

## Multi-project Builds

### Structure

```
root/
├── settings.gradle.kts
├── build.gradle.kts          ← root build (shared config)
├── app/
│   └── build.gradle.kts
├── core/
│   └── build.gradle.kts
└── utils/
    └── build.gradle.kts
```

### `settings.gradle.kts`

```kotlin
rootProject.name = "my-platform"

include("app", "core", "utils")

// Subdirectory different from project name:
include("api-client")
project(":api-client").projectDir = file("clients/api")
```

### Root `build.gradle.kts` — shared config

```kotlin
// Apply config to all subprojects
subprojects {
    apply(plugin = "java")

    repositories {
        mavenCentral()
    }

    tasks.withType<Test>().configureEach {
        useJUnitPlatform()
    }
}

// Apply to all projects including root
allprojects {
    group = "com.example"
    version = "1.0.0"
}
```

### Cross-project dependencies

```kotlin
// app/build.gradle.kts
dependencies {
    implementation(project(":core"))
    implementation(project(":utils"))
}
```

### Running tasks across subprojects

```sh
./gradlew build                     # builds all subprojects
./gradlew :app:build                # builds only the app subproject
./gradlew :core:test                # tests only core
./gradlew test --continue           # run tests in all, don't stop on first failure
```

---

## The Build Lifecycle

Every Gradle build passes through three phases:

### 1. Initialization

Gradle evaluates `settings.gradle.kts` to determine which projects are part of the build and creates `Project` objects for each.

### 2. Configuration

Gradle evaluates every project's `build.gradle.kts`. All task objects are created and configured — but **no task actions run yet**. This is why code at the top level of a build script runs during configuration, not execution.

```kotlin
// This runs at CONFIGURATION time:
println("Configuring project ${project.name}")

tasks.register("hello") {
    // This closure also runs at configuration time (configuring the task)

    doLast {
        // This runs at EXECUTION time only
        println("Hello!")
    }
}
```

### 3. Execution

Gradle executes the requested tasks in dependency order.

### Configuration avoidance

Use `tasks.register` (lazy) instead of `tasks.create` (eager) to avoid configuring tasks that won't run. This speeds up configuration time significantly in large builds:

```kotlin
// Preferred — lazy registration
tasks.register("myTask") { ... }

// Avoid — eagerly creates and configures even if task is never run
tasks.create("myTask") { ... }
```

---

## Configuration & Properties

### `gradle.properties`

Key-value pairs available as project properties. Checked into version control (avoid secrets):

```properties
# gradle.properties
org.gradle.jvmargs=-Xmx2g -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true

group=com.example
version=1.0.0

myCustomProperty=someValue
```

### `~/.gradle/gradle.properties`

User-level properties — **not** checked into source control. Good for credentials:

```properties
# ~/.gradle/gradle.properties
mavenUser=alice
mavenPassword=s3cr3t
signingKeyId=ABCDEF12
```

### Accessing properties in build scripts

```kotlin
// Project property (from gradle.properties or -P flag)
val myProp: String by project
println(myProp)

// Safer — with default
val myProp = findProperty("myCustomProperty") as String? ?: "default"

// System property
val javaHome = System.getProperty("java.home")

// Environment variable
val apiKey = System.getenv("API_KEY")
```

### Passing properties on the command line

```sh
./gradlew build -PmyProperty=value         # project property
./gradlew build -Dmy.system.prop=value     # system property (JVM)
```

### Java toolchains

Toolchains let Gradle download and use a specific JDK version regardless of what is installed:

```kotlin
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
        vendor = JvmVendorSpec.ADOPTIUM
    }
}
```

---

## Testing

### JUnit 5

```kotlin
dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()

    // Logging
    testLogging {
        events("passed", "skipped", "failed")
    }

    // Retry on failure (requires test-retry plugin)
    // maxRetries = 2

    // Run tests in parallel
    maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2).coerceAtLeast(1)
}
```

### Running specific tests

```sh
./gradlew test --tests "com.example.MyTest"
./gradlew test --tests "com.example.MyTest.myMethod"
./gradlew test --tests "com.example.*"
./gradlew test --info                              # verbose output
./gradlew test --rerun                             # force re-run even if UP-TO-DATE
```

### Test reports

Reports are generated at `build/reports/tests/test/index.html`.

### Test filtering by tag (JUnit 5)

```kotlin
tasks.test {
    useJUnitPlatform {
        includeTags("unit")
        excludeTags("slow", "integration")
    }
}
```

---

## Publishing

### Maven Publish plugin

```kotlin
plugins {
    `maven-publish`
    `java-library`
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])

            pom {
                name = "My Library"
                description = "A useful library"
                url = "https://github.com/example/my-lib"

                licenses {
                    license {
                        name = "Apache-2.0"
                        url = "https://www.apache.org/licenses/LICENSE-2.0"
                    }
                }
            }
        }
    }

    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/example/my-lib")
            credentials {
                username = System.getenv("GITHUB_ACTOR")
                password = System.getenv("GITHUB_TOKEN")
            }
        }

        // Publish locally for testing
        maven {
            name = "LocalRepo"
            url = uri(layout.buildDirectory.dir("repo"))
        }
    }
}
```

### Publishing commands

```sh
./gradlew publish                             # publish to all configured repos
./gradlew publishToMavenLocal                 # publish to ~/.m2/repository
./gradlew publishMavenJavaPublicationToGitHubPackagesRepository
```

---

## Build Cache & Performance

### Enable the build cache

```properties
# gradle.properties
org.gradle.caching=true
```

When enabled, Gradle reuses task outputs from previous runs (or a remote cache) if inputs have not changed. This is different from UP-TO-DATE checks — the cache works across clean builds and across machines.

### Enable configuration cache

```properties
# gradle.properties
org.gradle.configuration-cache=true
```

The configuration cache serializes the result of the configuration phase so it can be reused on subsequent runs if build scripts and inputs have not changed.

> **Note:** Configuration cache has compatibility requirements. Not all plugins support it. Check `./gradlew --configuration-cache` and read any warnings.

### Enable parallel execution

```properties
org.gradle.parallel=true
```

Runs independent subproject builds in parallel. Most effective in multi-project builds.

### Other performance flags

```properties
org.gradle.daemon=true           # default true — keeps a JVM warm between builds
org.gradle.jvmargs=-Xmx4g       # give the build JVM more memory
```

### Build scan

Build scans are detailed reports published to scans.gradle.com (free):

```sh
./gradlew build --scan
```

They show task timeline, dependency resolution, test results, and performance insights. Useful for diagnosing slow builds.

### Profiling locally

```sh
./gradlew build --profile          # generates build/reports/profile/profile-*.html
```

---

## Dependency Locking & Verification

### Dependency locking

Locks resolved dependency versions to a file so builds are reproducible even when using dynamic versions (`1.+`, `latest.release`):

```kotlin
// build.gradle.kts
configurations.all {
    resolutionStrategy.activateDependencyLocking()
}
```

```sh
./gradlew dependencies --write-locks     # generate/update lockfiles
./gradlew dependencies                   # subsequent runs verify against lockfiles
```

Lockfiles (`gradle/dependency-locks/*.lockfile`) should be committed to version control.

### Dependency verification

Verifies checksums and signatures of downloaded dependencies:

```sh
./gradlew --write-verification-metadata sha256
# Generates gradle/verification-metadata.xml
```

After generating, subsequent builds verify each artifact against the recorded checksum.

---

## Common CLI Commands

### Building

```sh
./gradlew build              # compile + test + assemble
./gradlew clean              # delete build directory
./gradlew clean build        # full rebuild
./gradlew assemble           # build artifacts, skip tests
./gradlew check              # run all verification (tests, lint, etc.)
./gradlew jar                # build the JAR only
./gradlew run                # run the application (requires application plugin)
```

### Testing

```sh
./gradlew test
./gradlew test --tests "com.example.*"
./gradlew test --rerun
./gradlew test --info
./gradlew test --continue    # don't stop on first failure
```

### Inspecting

```sh
./gradlew tasks              # list available tasks
./gradlew tasks --all        # list all tasks
./gradlew dependencies       # show dependency tree
./gradlew dependencies --configuration runtimeClasspath
./gradlew dependencyInsight --dependency guava
./gradlew properties         # show project properties
./gradlew projects           # list subprojects
./gradlew help --task build  # show help for a task
```

### Controlling execution

```sh
./gradlew build -x test          # skip the test task
./gradlew build --continue       # continue after failures
./gradlew build --parallel       # enable parallel execution
./gradlew build --no-daemon      # don't use the Gradle daemon
./gradlew build --rerun-tasks    # force all tasks to re-run (ignore UP-TO-DATE)
./gradlew build --quiet          # suppress most output
./gradlew build --info           # verbose output
./gradlew build --debug          # very verbose output
./gradlew build --stacktrace     # print full stack traces on errors
./gradlew build --scan           # publish build scan
./gradlew build --offline        # use only cached dependencies
```

---

## Practical Tips

**Always use the wrapper.** Never rely on a globally installed Gradle version. Commit `gradlew`, `gradlew.bat`, and `gradle/wrapper/` to version control.

**Check what will run before running it:**

```sh
./gradlew build --dry-run        # prints task execution plan without running anything
```

**Find why a dependency is included:**

```sh
./gradlew dependencyInsight --dependency jackson-databind --configuration runtimeClasspath
```

This shows which dependency pulled in `jackson-databind` transitively.

**Skip a task for one run:**

```sh
./gradlew build -x test -x checkstyleMain
```

**Force re-run a specific task even if UP-TO-DATE:**

```sh
./gradlew test --rerun
```

**Run only tasks that have changed inputs (incremental):** Gradle does this automatically when build caching is enabled and tasks properly declare their inputs/outputs.

**Speed up the first build on CI:** Use a remote build cache. Gradle Enterprise / Develocity provides one. Alternatively configure an HTTP build cache:

```kotlin
buildCache {
    remote<HttpBuildCache> {
        url = uri("https://cache.example.com/cache/")
        isPush = System.getenv("CI") != null   // only push from CI
    }
}
```

**Suppress deprecation warnings while upgrading:**

```sh
./gradlew build --warning-mode all   # see all deprecation warnings explicitly
```

**Daemon status:**

```sh
./gradlew --status           # list running Gradle daemons
./gradlew --stop             # stop all daemons
```

---

## Quick Cheatsheet

### Wrapper

|Command|Action|
|---|---|
|`./gradlew`|Run a task using the project wrapper|
|`gradle wrapper --gradle-version X`|Update wrapper to version X|
|`./gradlew wrapper`|Regenerate wrapper files|

### Common tasks

|Command|Action|
|---|---|
|`./gradlew build`|Compile + test + assemble|
|`./gradlew clean`|Delete build outputs|
|`./gradlew test`|Run tests|
|`./gradlew check`|All verification tasks|
|`./gradlew assemble`|Build artifacts, skip tests|
|`./gradlew run`|Run the application|
|`./gradlew jar`|Build JAR only|
|`./gradlew publish`|Publish artifacts|
|`./gradlew publishToMavenLocal`|Publish to `~/.m2`|

### Inspecting

|Command|Action|
|---|---|
|`./gradlew tasks`|List main tasks|
|`./gradlew tasks --all`|List all tasks|
|`./gradlew dependencies`|Dependency tree|
|`./gradlew dependencyInsight --dependency X`|Why is X on the classpath?|
|`./gradlew properties`|Project properties|
|`./gradlew projects`|List subprojects|
|`./gradlew build --dry-run`|Task execution plan|

### Flags

|Flag|Meaning|
|---|---|
|`-x taskName`|Skip a task|
|`--continue`|Don't stop on failure|
|`--rerun-tasks`|Force re-run all tasks|
|`--parallel`|Parallel execution|
|`--offline`|No network, use cache|
|`--no-daemon`|Don't use daemon|
|`--scan`|Publish build scan|
|`--stacktrace`|Full stack traces|
|`--info` / `--debug`|Verbose output|
|`--quiet`|Suppress output|
|`-PmyProp=val`|Set project property|
|`-Dmy.prop=val`|Set system property|

### `gradle.properties` performance settings

```properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.jvmargs=-Xmx2g
```

### Dependency configurations

|Configuration|Scope|
|---|---|
|`implementation`|Compile + runtime, hidden from consumers|
|`api`|Compile + runtime, exposed to consumers|
|`compileOnly`|Compile only|
|`runtimeOnly`|Runtime only|
|`testImplementation`|Test compile + runtime|
|`testRuntimeOnly`|Test runtime only|

---

_Source: [Gradle documentation](https://docs.gradle.org/) — always refer to the docs for your specific Gradle version, as the API and DSL evolve across releases._