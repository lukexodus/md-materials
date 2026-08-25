## Boot Sequence and IOS Image Management


**Boot Sequence**

When a Cisco device powers on, it executes a specific boot sequence:

1. **Power-On Self-Test (POST)**: Hardware diagnostics verify CPU, memory, and interfaces. POST is stored in ROM and executes automatically.
    
2. **Bootstrap Loader**: A small program in ROM initializes the hardware and locates the IOS image. On routers, this is the ROMMON (ROM Monitor) environment.
    
3. **IOS Image Loading**: The bootstrap loader finds and loads the IOS image from flash memory. The location is determined by the boot system commands in the configuration or default flash location.
    
4. **Configuration Loading**: After IOS loads, the device loads the startup-config from NVRAM into running-config in RAM. If no startup-config exists, the device enters setup mode or presents an empty configuration.
    
5. **Normal Operation**: The device becomes operational with the loaded configuration.
    

**IOS Image Management**

IOS images are typically stored in flash memory (flash: or bootflash:). Image files use naming conventions that indicate platform, feature set, and version (e.g., c2900-universalk9-mz.SPA.157-3.M5.bin). The "mz" indicates the image runs from RAM (copied from flash), while "universal" indicates a combined feature set.

Image management commands:

- `show flash:` displays flash contents and available space
- `show version` shows currently running IOS version, uptime, and boot image
- `boot system flash:filename` configures which image to load
- `copy tftp: flash:` transfers new images to the device
- `verify /md5 flash:filename` verifies image integrity
- `delete flash:filename` removes old images to free space

Multiple boot system commands can be configured as fallback options. If the primary image fails, the device attempts subsequent configured images, then the first valid image in flash, and finally ROMMON mode.

