## Project Structure and Organization


Android projects follow a standardized directory structure that organizes code, resources, and configuration files systematically.

The **app/src/main/java** directory contains the application's Java or Kotlin source code, organized in packages that typically follow reverse domain naming conventions. The main application logic, activities, services, and other components reside here.

The **app/src/main/res** directory houses all non-code resources including layouts (res/layout), images (res/drawable), strings (res/values), colors, dimensions, and styles. Resources are organized by type and configuration qualifiers for internationalization and device-specific adaptations.

The **app/src/main/assets** directory stores raw files that need to be bundled with the application, accessible through the AssetManager at runtime. Unlike resources, assets are not processed by the build system and maintain their original file structure.

Build configuration files include **build.gradle** files at both project and module levels, defining dependencies, build variants, signing configurations, and compilation settings. The **gradle.properties** file contains project-wide Gradle settings and custom properties.

