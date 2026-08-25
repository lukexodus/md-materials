## R Installation and Setup


**Windows Installation** Download the R installer from the Comprehensive R Archive Network (CRAN) at cran.r-project.org. Select the Windows version, choose "base" distribution, and download the latest release. Run the installer with administrator privileges, accepting default settings for most users. The installation includes the R GUI, command-line interface, and essential base packages.

**macOS Installation** Download the macOS installer package (.pkg file) from CRAN, ensuring compatibility with your macOS version. The installer handles dependencies automatically. For users with Apple Silicon (M1/M2) processors, download the ARM64 version for optimal performance.

**Linux Installation** Most Linux distributions include R in their package repositories. For Ubuntu/Debian systems, use `sudo apt update && sudo apt install r-base r-base-dev`. The development package (r-base-dev) enables compilation of packages from source. For CentOS/RHEL, use `sudo yum install R` or `sudo dnf install R`.

**Version Management** R follows semantic versioning with major releases annually. Version 4.x introduced significant changes including improved syntax consistency and enhanced package management. Users can maintain multiple R versions simultaneously, though this requires careful management of package libraries and PATH variables.

**Environment Variables** Key environment variables include R_HOME (R installation directory), R_LIBS_USER (user package library), and R_PROFILE (startup script location). These can be configured in .Renviron and .Rprofile files for persistent customization.

