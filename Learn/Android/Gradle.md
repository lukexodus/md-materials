# Gradle Configuration

## What is Gradle?

Gradle is a build automation tool that uses a domain-specific language (DSL) based on Groovy or Kotlin. It's designed to be flexible and can build projects in multiple languages including Java, Kotlin, Android, C++, and more.

## Core Gradle Files

### build.gradle (or build.gradle.kts)
The main build configuration file that defines:
- Project dependencies
- Build tasks
- Plugins
- Build logic

### settings.gradle (or settings.gradle.kts)
Defines the project structure and includes subprojects:
```gradle
rootProject.name = 'my-project'
include 'subproject1', 'subproject2'
```

### gradle.properties
Contains project-wide properties and configuration:
```properties
# Gradle daemon settings
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true

# JVM settings
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m

# Project properties
version=1.0.0
```

### gradle/wrapper/gradle-wrapper.properties
Specifies the Gradle version to use:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
```

## Basic Build.gradle Structure

### Groovy DSL Example
```gradle
plugins {
    id 'java'
    id 'application'
}

group = 'com.example'
version = '1.0.0'
sourceCompatibility = '17'

repositories {
    mavenCentral()
    gradlePluginPortal()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter:3.1.0'
    testImplementation 'junit:junit:4.13.2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
}

application {
    mainClass = 'com.example.Main'
}

test {
    useJUnitPlatform()
}
```

### Kotlin DSL Example (build.gradle.kts)
```kotlin
plugins {
    java
    application
}

group = "com.example"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter:3.1.0")
    testImplementation("junit:junit:4.13.2")
}

application {
    mainClass.set("com.example.Main")
}

tasks.test {
    useJUnitPlatform()
}
```

## Plugin Configuration

### Applying Plugins
```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.1.0'
    id 'io.spring.dependency-management' version '1.1.0'
}

// Legacy plugin syntax (still supported)
apply plugin: 'java'
apply plugin: 'maven-publish'
```

### Plugin Configuration Blocks
```gradle
// Java plugin configuration
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

// Spring Boot plugin configuration
springBoot {
    buildInfo()
    mainClass = 'com.example.Application'
}
```

## Dependency Management

### Dependency Configurations
```gradle
dependencies {
    // Compile time and runtime
    implementation 'org.springframework:spring-core:6.0.0'
    
    // Compile time only
    compileOnly 'org.projectlombok:lombok:1.18.24'
    
    // Runtime only
    runtimeOnly 'com.h2database:h2:2.1.214'
    
    // Test dependencies
    testImplementation 'junit:junit:4.13.2'
    testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
    
    // Annotation processing
    annotationProcessor 'org.projectlombok:lombok:1.18.24'
}
```

### Version Catalogs (Gradle 7.0+)
Create `gradle/libs.versions.toml`:
```toml
[versions]
spring = "6.0.0"
junit = "5.9.0"

[libraries]
spring-core = { module = "org.springframework:spring-core", version.ref = "spring" }
junit-jupiter = { module = "org.junit.jupiter:junit-jupiter", version.ref = "junit" }

[bundles]
spring = ["spring-core", "spring-context"]

[plugins]
spring-boot = { id = "org.springframework.boot", version = "3.1.0" }
```

Use in build.gradle:
```gradle
dependencies {
    implementation libs.spring.core
    implementation libs.bundles.spring
    testImplementation libs.junit.jupiter
}
```

## Repository Configuration

```gradle
repositories {
    // Maven Central
    mavenCentral()
    
    // Google's Maven repository
    google()
    
    // Gradle Plugin Portal
    gradlePluginPortal()
    
    // JCenter (deprecated but still available)
    jcenter()
    
    // Custom Maven repository
    maven {
        url 'https://repo.spring.io/milestone'
        credentials {
            username = project.findProperty('repoUser') ?: ''
            password = project.findProperty('repoPassword') ?: ''
        }
    }
    
    // Local Maven repository
    mavenLocal()
    
    // Flat directory repository
    flatDir {
        dirs 'lib'
    }
}
```

## Task Configuration

### Defining Custom Tasks
```gradle
task customTask {
    doLast {
        println 'Executing custom task'
    }
}

// Task with configuration
task processFiles(type: Copy) {
    from 'src/main/resources'
    into 'build/processed'
    include '**/*.properties'
}

// Task dependencies
task deploy {
    dependsOn 'build', 'test'
    doLast {
        println 'Deploying application'
    }
}
```

### Configuring Built-in Tasks
```gradle
// Configure the jar task
jar {
    archiveBaseName = 'my-app'
    archiveVersion = '1.0.0'
    
    manifest {
        attributes(
            'Implementation-Title': project.name,
            'Implementation-Version': project.version,
            'Main-Class': 'com.example.Main'
        )
    }
}

// Configure test task
test {
    useJUnitPlatform()
    
    testLogging {
        events "passed", "skipped", "failed"
        exceptionFormat = 'full'
    }
    
    systemProperties = [
        'spring.profiles.active': 'test'
    ]
}

// Configure JavaCompile task
tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
    options.compilerArgs += ['-Xlint:unchecked', '-Xlint:deprecation']
}
```

## Multi-Project Configuration

### Root Project settings.gradle
```gradle
rootProject.name = 'multi-project-example'

include 'core', 'web', 'mobile'

// Configure project locations
project(':core').projectDir = file('modules/core')
project(':web').projectDir = file('modules/web')
```

### Root Project build.gradle
```gradle
// Configuration applied to all projects
allprojects {
    group = 'com.example'
    version = '1.0.0'
    
    repositories {
        mavenCentral()
    }
}

// Configuration applied to all subprojects
subprojects {
    apply plugin: 'java'
    
    java {
        sourceCompatibility = JavaVersion.VERSION_17
    }
    
    dependencies {
        testImplementation 'junit:junit:4.13.2'
    }
}

// Project-specific configuration
project(':web') {
    apply plugin: 'war'
    
    dependencies {
        implementation project(':core')
    }
}
```

## Build Variants and Configurations

### Creating Custom Configurations
```gradle
configurations {
    integrationTestImplementation.extendsFrom testImplementation
    integrationTestRuntimeOnly.extendsFrom testRuntimeOnly
}

dependencies {
    integrationTestImplementation 'org.testcontainers:junit-jupiter:1.17.6'
}

// Create source sets
sourceSets {
    integrationTest {
        java {
            srcDir 'src/integration-test/java'
        }
        resources {
            srcDir 'src/integration-test/resources'
        }
        compileClasspath += sourceSets.main.output
        runtimeClasspath += sourceSets.main.output
    }
}
```

## Environment-Specific Configuration

### Using Profiles
```gradle
// Define profiles
if (project.hasProperty('prod')) {
    apply from: 'gradle/prod.gradle'
} else if (project.hasProperty('test')) {
    apply from: 'gradle/test.gradle'
} else {
    apply from: 'gradle/dev.gradle'
}

// In gradle/prod.gradle
ext {
    databaseUrl = 'jdbc:postgresql://prod-db:5432/app'
    logLevel = 'WARN'
}

// Usage: gradle build -Pprod
```

### Using Gradle Properties
```gradle
// Access properties
def dbUrl = project.findProperty('database.url') ?: 'jdbc:h2:mem:testdb'
def isProduction = project.hasProperty('production')

// From gradle.properties
database.url=jdbc:mysql://localhost:3306/mydb
production=true
```

## Build Script Configuration

### Build Script Dependencies
```gradle
buildscript {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
    dependencies {
        classpath 'org.springframework.boot:spring-boot-gradle-plugin:3.1.0'
    }
}
```

### Applying External Scripts
```gradle
// Apply external build scripts
apply from: 'gradle/dependencies.gradle'
apply from: 'gradle/publishing.gradle'

// Remote script application
apply from: 'https://raw.githubusercontent.com/example/scripts/main/common.gradle'
```

## Performance Configuration

### Gradle Daemon Configuration
```properties
# In gradle.properties
org.gradle.daemon=true
org.gradle.daemon.idletimeout=7200000
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g -XX:+UseG1GC
```

### Parallel and Incremental Builds
```properties
# Enable parallel execution
org.gradle.parallel=true

# Enable build cache
org.gradle.caching=true

# Enable configuration cache (Gradle 6.6+)
org.gradle.configuration-cache=true

# Enable file system watching (Gradle 7.0+)
org.gradle.vfs.watch=true
```

### Build Cache Configuration
```gradle
buildCache {
    local {
        enabled = true
        directory = new File(rootDir, 'build-cache')
    }
    
    remote(HttpBuildCache) {
        url = 'https://cache.example.com/'
        push = true
        credentials {
            username = findProperty('cacheUser')
            password = findProperty('cachePassword')
        }
    }
}
```

## Testing Configuration

### Test Suites (Gradle 7.3+)
```gradle
testing {
    suites {
        test {
            useJUnitJupiter()
        }
        
        integrationTest(JvmTestSuite) {
            dependencies {
                implementation project()
                implementation 'org.testcontainers:junit-jupiter:1.17.6'
            }
        }
        
        functionalTest(JvmTestSuite) {
            dependencies {
                implementation project()
            }
        }
    }
}
```

## Publishing Configuration

### Maven Publishing
```gradle
publishing {
    publications {
        maven(MavenPublication) {
            from components.java
            
            pom {
                name = 'My Library'
                description = 'A library for demonstration'
                url = 'https://github.com/example/my-library'
                
                licenses {
                    license {
                        name = 'Apache License 2.0'
                        url = 'https://www.apache.org/licenses/LICENSE-2.0'
                    }
                }
                
                developers {
                    developer {
                        id = 'johndoe'
                        name = 'John Doe'
                        email = 'john@example.com'
                    }
                }
            }
        }
    }
    
    repositories {
        maven {
            url = version.endsWith('SNAPSHOT') ? 
                'https://oss.sonatype.org/content/repositories/snapshots/' :
                'https://oss.sonatype.org/service/local/staging/deploy/maven2/'
            
            credentials {
                username = findProperty('sonatypeUser')
                password = findProperty('sonatypePassword')
            }
        }
    }
}
```

## Best Practices

### 1. Use Version Catalogs for Dependency Management
- Centralize version definitions
- Enable type-safe accessors
- Improve dependency updates

### 2. Configure Build Caching
- Enable local and remote caching
- Use `--build-cache` for better performance
- Configure cache retention policies

### 3. Optimize Build Performance
- Enable parallel execution
- Use configuration cache
- Minimize plugin applications

### 4. Structure Multi-Project Builds Properly
- Use `allprojects` and `subprojects` wisely
- Extract common configuration
- Use composite builds when appropriate

### 5. Handle Secrets Securely
- Use `gradle.properties` for local development
- Use environment variables in CI/CD
- Never commit credentials to version control

### 6. Use Gradle Wrapper
- Ensures consistent Gradle version
- Include wrapper files in version control
- Update wrapper regularly

This guide covers the essential aspects of Gradle configuration. The exact configuration will depend on your specific project requirements, technology stack, and build environment.