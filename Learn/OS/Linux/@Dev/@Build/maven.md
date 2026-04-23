# Maven

Apache Maven is a build automation and project management tool for Java (and JVM) projects. It manages dependencies, compiles code, runs tests, packages artifacts, and handles deployment — all driven by a `pom.xml` file and a convention-over-configuration model.

---

## Installation

```bash
# Debian / Ubuntu
sudo apt install maven

# Arch / Manjaro
sudo pacman -S maven

# Fedora
sudo dnf install maven

# macOS
brew install maven

# Windows (Scoop)
scoop install maven

# Windows (winget)
winget install Apache.Maven

# Manual install (any OS)
# 1. Download from https://maven.apache.org/download.cgi
# 2. Extract to a directory (e.g. /opt/maven)
# 3. Add to PATH:
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
```

```bash
# Verify
mvn --version
```

> Maven requires a JDK (not just a JRE) to be installed and `JAVA_HOME` set correctly.

```bash
# Set JAVA_HOME (add to ~/.bashrc or ~/.zshrc)
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
```

---

## Core Concepts

### Convention over Configuration

Maven expects a standard directory layout. If you follow it, you need minimal configuration.

```
project/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/          # production source code
    │   └── resources/     # production resources (config files, etc.)
    └── test/
        ├── java/          # test source code
        └── resources/     # test resources
```

Output goes to `target/` (created automatically, never commit this).

### The POM (Project Object Model)

`pom.xml` is the central configuration file. Every Maven project has one.

### Coordinates

Every artifact in Maven is identified by three coordinates:

|Field|Description|Example|
|---|---|---|
|`groupId`|Organisation or project namespace|`com.example`|
|`artifactId`|Project/module name|`my-app`|
|`version`|Version string|`1.0.0`|

Together: `groupId:artifactId:version` — e.g. `com.example:my-app:1.0.0`

### Local Repository

Downloaded dependencies are cached in `~/.m2/repository/`. You rarely need to touch this directly.

---

## Minimal pom.xml

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>my-app</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

</project>
```

---

## Build Lifecycle

Maven has three built-in lifecycles. The most important is **default**.

### Default Lifecycle (key phases in order)

|Phase|What it does|
|---|---|
|`validate`|Checks the project structure is correct|
|`compile`|Compiles `src/main/java` → `target/classes`|
|`test`|Runs unit tests (does not package first)|
|`package`|Packages compiled code into JAR/WAR/etc → `target/`|
|`verify`|Runs integration tests and checks|
|`install`|Installs the artifact to local `~/.m2` repository|
|`deploy`|Copies the artifact to a remote repository|

Running a phase runs **all preceding phases** in that lifecycle automatically.

```bash
mvn compile      # runs: validate → compile
mvn test         # runs: validate → compile → test
mvn package      # runs: validate → compile → test → package
mvn install      # runs: ... → package → install
mvn deploy       # runs: ... → install → deploy
```

### Clean Lifecycle

```bash
mvn clean        # deletes the target/ directory
mvn clean package  # clean first, then build (recommended for CI)
```

### Site Lifecycle

```bash
mvn site         # generates project documentation site in target/site/
```

---

## Common Commands

```bash
# Build and package
mvn package

# Clean and build
mvn clean package

# Skip tests
mvn package -DskipTests

# Skip test compilation and execution
mvn package -Dmaven.test.skip=true

# Run tests only
mvn test

# Run a specific test class
mvn test -Dtest=MyTestClass

# Run a specific test method
mvn test -Dtest=MyTestClass#myMethod

# Install to local repo
mvn install

# Clean local repo cache for this project and reinstall
mvn dependency:purge-local-repository

# Run the application (requires exec-maven-plugin or spring-boot-maven-plugin)
mvn exec:java -Dexec.mainClass=com.example.Main

# Print effective POM (fully resolved, after inheritance)
mvn help:effective-pom

# Print all active profiles
mvn help:active-profiles

# Describe a plugin goal
mvn help:describe -Dplugin=compiler -Dgoal=compile
```

---

## Dependencies

### Adding a Dependency

```xml
<dependencies>
  <dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <version>6.1.0</version>
  </dependency>
</dependencies>
```

### Dependency Scopes

|Scope|Compile|Test|Runtime|Packaged|
|---|---|---|---|---|
|`compile` (default)|✓|✓|✓|✓|
|`test`|—|✓|—|—|
|`runtime`|—|✓|✓|✓|
|`provided`|✓|✓|—|—|
|`system`|✓|✓|—|—|
|`import`|POM imports only||||

```xml
<!-- Test-only dependency -->
<dependency>
  <groupId>org.junit.jupiter</groupId>
  <artifactId>junit-jupiter</artifactId>
  <version>5.10.0</version>
  <scope>test</scope>
</dependency>

<!-- Provided by the container (e.g. servlet-api in a WAR) -->
<dependency>
  <groupId>jakarta.servlet</groupId>
  <artifactId>jakarta.servlet-api</artifactId>
  <version>6.0.0</version>
  <scope>provided</scope>
</dependency>
```

### Excluding Transitive Dependencies

```xml
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-core</artifactId>
  <version>6.1.0</version>
  <exclusions>
    <exclusion>
      <groupId>commons-logging</groupId>
      <artifactId>commons-logging</artifactId>
    </exclusion>
  </exclusions>
</dependency>
```

### Dependency Management

Centralise versions (often in a parent POM) without actually adding the dependency:

```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.16.0</version>
    </dependency>
  </dependencies>
</dependencyManagement>
```

Child modules can then declare the dependency without a `<version>`:

```xml
<dependency>
  <groupId>com.fasterxml.jackson.core</groupId>
  <artifactId>jackson-databind</artifactId>
</dependency>
```

### Dependency Commands

```bash
# Show the full dependency tree
mvn dependency:tree

# Show tree with verbose conflict resolution
mvn dependency:tree -Dverbose

# Resolve and copy dependencies to a directory
mvn dependency:copy-dependencies -DoutputDirectory=target/libs

# Check for dependency updates
mvn versions:display-dependency-updates

# Analyse unused/undeclared dependencies
mvn dependency:analyze
```

---

## Properties

```xml
<properties>
  <!-- Java version -->
  <maven.compiler.source>17</maven.compiler.source>
  <maven.compiler.target>17</maven.compiler.target>

  <!-- Encoding -->
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

  <!-- Custom property (reusable version) -->
  <jackson.version>2.16.0</jackson.version>
</properties>

<dependencies>
  <dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>${jackson.version}</version>
  </dependency>
</dependencies>
```

Built-in properties:

|Property|Value|
|---|---|
|`${project.version}`|Current project version|
|`${project.groupId}`|Current groupId|
|`${project.artifactId}`|Current artifactId|
|`${project.basedir}`|Project root directory|
|`${project.build.directory}`|`target/`|
|`${project.build.sourceDirectory}`|`src/main/java`|
|`${maven.build.timestamp}`|Build timestamp|
|`${env.HOME}`|Environment variable|
|`${settings.localRepository}`|Local repo path|

---

## Plugins

Maven's functionality is entirely plugin-based. Phases bind to plugin goals.

### Plugin Configuration

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>3.12.1</version>
      <configuration>
        <source>17</source>
        <target>17</target>
        <compilerArgs>
          <arg>-Xlint:all</arg>
        </compilerArgs>
      </configuration>
    </plugin>
  </plugins>
</build>
```

### Common Built-in Plugins

|Plugin|Purpose|
|---|---|
|`maven-compiler-plugin`|Compiles Java source|
|`maven-surefire-plugin`|Runs unit tests|
|`maven-failsafe-plugin`|Runs integration tests|
|`maven-jar-plugin`|Packages JAR|
|`maven-war-plugin`|Packages WAR|
|`maven-install-plugin`|Installs to local repo|
|`maven-deploy-plugin`|Deploys to remote repo|
|`maven-clean-plugin`|Cleans `target/`|
|`maven-resources-plugin`|Copies resources|
|`maven-dependency-plugin`|Dependency utilities|
|`maven-site-plugin`|Generates project site|
|`maven-release-plugin`|Manages releases|

### Executable JAR (fat JAR) with maven-shade-plugin

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-shade-plugin</artifactId>
  <version>3.5.1</version>
  <executions>
    <execution>
      <phase>package</phase>
      <goals><goal>shade</goal></goals>
      <configuration>
        <transformers>
          <transformer implementation=
            "org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
            <mainClass>com.example.Main</mainClass>
          </transformer>
        </transformers>
      </configuration>
    </execution>
  </executions>
</plugin>
```

```bash
mvn package
java -jar target/my-app-1.0.0.jar
```

### exec-maven-plugin (run without packaging)

```xml
<plugin>
  <groupId>org.codehaus.mojo</groupId>
  <artifactId>exec-maven-plugin</artifactId>
  <version>3.1.1</version>
  <configuration>
    <mainClass>com.example.Main</mainClass>
  </configuration>
</plugin>
```

```bash
mvn exec:java
```

---

## Profiles

Profiles let you vary build configuration by environment.

```xml
<profiles>
  <profile>
    <id>production</id>
    <properties>
      <env>prod</env>
    </properties>
    <dependencies>
      <!-- prod-only deps -->
    </dependencies>
  </profile>

  <profile>
    <id>development</id>
    <activation>
      <activeByDefault>true</activeByDefault>
    </activation>
    <properties>
      <env>dev</env>
    </properties>
  </profile>
</profiles>
```

```bash
# Activate a profile
mvn package -Pproduction

# Activate multiple profiles
mvn package -Pproduction,extra

# Deactivate a profile
mvn package -P!development

# List active profiles
mvn help:active-profiles
```

Profiles can also be activated automatically by:

```xml
<activation>
  <os><name>Windows 11</name></os>
</activation>

<activation>
  <property>
    <name>env</name>
    <value>prod</value>
  </property>
</activation>

<activation>
  <file>
    <exists>config/prod.properties</exists>
  </file>
</activation>
```

---

## Multi-Module Projects

A parent POM aggregates multiple modules.

### Parent pom.xml

```xml
<project>
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example</groupId>
  <artifactId>my-project</artifactId>
  <version>1.0.0</version>
  <packaging>pom</packaging>   <!-- must be pom for parent -->

  <modules>
    <module>my-core</module>
    <module>my-service</module>
    <module>my-web</module>
  </modules>

  <dependencyManagement>
    <!-- centralised version management -->
  </dependencyManagement>
</project>
```

### Child pom.xml

```xml
<project>
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>com.example</groupId>
    <artifactId>my-project</artifactId>
    <version>1.0.0</version>
  </parent>

  <artifactId>my-core</artifactId>
  <!-- groupId and version inherited from parent -->
</project>
```

```
my-project/
├── pom.xml              ← parent
├── my-core/
│   ├── pom.xml
│   └── src/
├── my-service/
│   ├── pom.xml
│   └── src/
└── my-web/
    ├── pom.xml
    └── src/
```

```bash
# Build all modules from the parent directory
mvn clean install

# Build a specific module and its dependencies
mvn clean install -pl my-service -am

# Build a specific module only (no dependencies)
mvn clean install -pl my-service

# Skip a module
mvn clean install -pl !my-web
```

---

## Repository Configuration

### settings.xml

The global Maven settings file lives at `~/.m2/settings.xml` (user) or `$M2_HOME/conf/settings.xml` (global).

```xml
<settings>
  <!-- Custom local repo location -->
  <localRepository>/path/to/local/repo</localRepository>

  <!-- Mirror (e.g. internal Nexus/Artifactory) -->
  <mirrors>
    <mirror>
      <id>internal-repo</id>
      <mirrorOf>central</mirrorOf>
      <url>https://repo.example.com/repository/maven-public/</url>
    </mirror>
  </mirrors>

  <!-- Server credentials -->
  <servers>
    <server>
      <id>internal-repo</id>
      <username>user</username>
      <password>secret</password>
    </server>
  </servers>

  <!-- Proxy -->
  <proxies>
    <proxy>
      <id>myproxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>proxy.example.com</host>
      <port>8080</port>
      <nonProxyHosts>localhost|*.internal</nonProxyHosts>
    </proxy>
  </proxies>
</settings>
```

### Adding a Remote Repository in pom.xml

```xml
<repositories>
  <repository>
    <id>jitpack.io</id>
    <url>https://jitpack.io</url>
  </repository>
</repositories>
```

---

## Versioning

Maven version conventions:

```
1.0.0          release
1.0.1-SNAPSHOT development/in-progress (mutable)
1.0.0-alpha1   pre-release
1.0.0-beta2    pre-release
1.0.0-RC1      release candidate
```

`SNAPSHOT` versions are treated specially — Maven always checks for newer snapshots in remote repositories. Release versions are immutable once published.

```bash
# Update all dependency versions interactively
mvn versions:display-dependency-updates

# Update all plugin versions
mvn versions:display-plugin-updates

# Set a new project version
mvn versions:set -DnewVersion=2.0.0

# Revert versions:set if unhappy
mvn versions:revert

# Commit the new version
mvn versions:commit
```

---

## Maven Wrapper

The Maven Wrapper (`mvnw`) pins a specific Maven version per project so all developers and CI use the same version without a system install.

```bash
# Add the wrapper to an existing project
mvn wrapper:wrapper

# Add a specific version
mvn wrapper:wrapper -Dmaven=3.9.6
```

This creates:

```
mvnw            ← Unix shell script
mvnw.cmd        ← Windows batch script
.mvn/
└── wrapper/
    └── maven-wrapper.properties
```

```bash
# Use exactly like mvn
./mvnw clean package
./mvnw test
```

Commit `mvnw`, `mvnw.cmd`, and `.mvn/` to version control. Never commit `~/.m2/`.

---

## Useful Flags

|Flag|Description|
|---|---|
|`-DskipTests`|Skip test execution (still compiles tests)|
|`-Dmaven.test.skip=true`|Skip test compilation and execution|
|`-P<profile>`|Activate a profile|
|`-pl <module>`|Build specific module(s)|
|`-am`|Also build modules the target depends on|
|`-amd`|Also build modules that depend on the target|
|`-T 4`|Build with 4 threads (parallel)|
|`-T 1C`|One thread per CPU core|
|`-o`|Offline mode (use local cache only)|
|`-U`|Force update of snapshots|
|`-X`|Debug output (very verbose)|
|`-q`|Quiet output (errors only)|
|`-e`|Show exception stack traces|
|`-B`|Batch mode (no interactive prompts, good for CI)|
|`-N`|Non-recursive (don't build submodules)|
|`-f <pom>`|Use a specific POM file|
|`--fail-fast`|Stop at first module failure|
|`--fail-at-end`|Build all modules, report failures at end|
|`--fail-never`|Never fail the build (for reporting)|

---

## Practical Tips

**Always use `mvn clean package` (not just `mvn package`) for release or CI builds.** Incremental builds can carry stale class files from previous compilations.

**Use `-B` in CI.** Batch mode disables interactive prompts and progress animations, producing cleaner logs.

```bash
mvn -B clean package
```

**Parallel builds speed things up significantly.** For multi-module projects:

```bash
mvn -T 1C clean install    # one thread per CPU core
```

**Pin your Maven version with the wrapper.** A `mvnw` in the repo removes the "it works on my machine" problem for build tooling versions.

**`dependency:tree` is the first tool to reach for when resolving conflicts.** When two libraries pull in different versions of the same transitive dependency, this command shows you exactly where each version comes from.

**`-o` offline mode for fast iteration.** If you are not adding new dependencies, `-o` skips all remote repository checks and speeds up startup.

**Keep `~/.m2/settings.xml` out of version control.** It often contains credentials. Use environment variable substitution instead:

```xml
<password>${env.REPO_PASSWORD}</password>
```

**SNAPSHOT vs release in `dependencyManagement`.** Never depend on a SNAPSHOT in a release artifact — they are mutable and can change under you. Pin to release versions before tagging a release.

> **[Inference]** Plugin and dependency version numbers used in this guide are illustrative. Always check Maven Central for the current latest versions before using them in a real project.