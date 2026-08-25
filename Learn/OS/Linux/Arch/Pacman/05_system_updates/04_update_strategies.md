## Update Strategies


### Read Before Upgrading

Before upgrading, users are expected to visit the Arch Linux home page to check the latest news:[1][2][3]

```
https://archlinux.org/
```


When updates require out-of-the-ordinary user intervention (more than what can be handled simply by following the instructions given by pacman), an appropriate news post will be made. Users should also subscribe to the RSS feed or the arch-announce mailing list.[2]

**Alternative news sources:**
```
https://archlinux.org/news/
RSS: https://archlinux.org/feeds/news/
```


Before upgrading fundamental software (such as the kernel, xorg, systemd, or glibc) to a new version, look over the appropriate forum to see if there have been any reported problems.[2]

### Automated News Checking

Use a pacman hook to prevent updating if there is fresh Arch News that you have not read since the last update ran:[1][2]

**Available tools:**
- `informant` (AUR)[2]
- `newscheck` (AUR)[2]
- `arch-manwarn` (AUR)[2]

**AUR helpers with built-in news checking:**
```
yay -Syu    # Automatically checks for news
paru -Syu   # Automatically checks for news
```


These helpers have options to automatically check for news if there's something like manual intervention involved.[1]

### Update Frequency Recommendations

#### Regular Update Schedule

**Daily updates:** Ideal for users who actively use their system. Most users update once a day or every few days. Updates are typically straightforward, and the risk associated with updates is minimal.[4]

**Weekly updates:** Acceptable for most use cases. Provides a good balance between staying current and avoiding constant maintenance.[4][1]

**Monthly updates:** Minimum recommended frequency. Waiting longer than a month between updates can complicate the process and lead to dependency issues.[4]

**What to avoid:** Never leave the system without updates for extended periods (months or years). An Arch installation that hasn't been updated in two years is technically feasible to update, but a complete reinstallation would be faster.[4]

#### Rolling Release Considerations

Arch is a rolling release distribution that receives continuous updates. It is recommended to perform full system upgrades regularly to enjoy both the latest bug fixes and security updates, and also to avoid having to deal with too many package upgrades that require manual intervention at once.[3][4][2]

When requesting support from the community, it will usually be assumed that the system is up to date.[2]

### Pre-Update Preparation

#### Have Rescue Media Ready

Make sure to have the Arch install media or another Linux "live" CD/USB available so you can easily rescue your system if there is a problem after updating:[1][2]

```
# Keep an Arch ISO on a ventoy USB
# Update the ISO periodically
```


#### Production Environment Testing

If you are running Arch in a production environment, or cannot afford downtime for any reason, test changes to configuration files, as well as updates to software packages, on a non-critical duplicate system first. Then, if no problems arise, roll out the changes to the production system.[2]

#### Timing Considerations

It is discouraged to upgrade a stable system shortly before it is required for carrying out an important task. Instead, wait to upgrade until there is enough time available to resolve any post-upgrade issues.[2]

Upgrading packages can raise unexpected problems that could need immediate intervention.[2]

### Update Execution

#### Standard Update Command

The primary command for system updates:[3][2]

```
sudo pacman -Syu
```


**For systems with AUR packages:**
```
yay -Syu
```


Or:
```
paru -Syu
```

AUR helpers update both official repositories and AUR packages in one command.[3]

#### Monitor the Update Process

Pay attention to the alert notices provided by pacman during upgrades. If any additional actions are required by the user, be sure to take care of them right away.[2]

If a pacman alert is confusing:
- Search the forums for clarification[2]
- Check the latest news on the Arch Linux homepage[2]
- Look for more detailed instructions[2]

### Post-Update Actions

#### Handle Configuration Files Promptly

When pacman is invoked, `.pacnew` and `.pacsave` files can be created. Pacman provides notice when this happens and users must deal with these files promptly.[2]

**Using checkservices script:**
The `archlinux-contrib` package provides a script called `checkservices` which runs `pacdiff` to merge `.pacnew` files then checks for processes running with outdated libraries and prompts the user if they want them to be restarted.[2]

Also, think about other configuration files you may have copied or created. If a package had an example configuration that you copied to your home directory, check to see if a new one has been created.[2]

#### Restart or Reboot After Upgrades

Upgrades are typically not applied to existing processes. You must restart processes to fully apply the upgrade.[2]

The kernel is particularly difficult to patch without a reboot. A reboot is always the most secure option, but if this is very inconvenient, kernel live patching can be used to apply upgrades without a reboot.[2]

**When to reboot:**
- Kernel updates[4]
- systemd updates
- Critical system library updates
- After major upgrades

**Note:** If an update involves the kernel or its modules, it's wise to hold off if you don't plan to reboot right away, as the old modules will be removed.[4]

### AUR Package Management

If the system has packages from the AUR, carefully upgrade all of them. Make sure to update your AUR packages as well, especially when system libraries change, as this is a common source of user errors.[4][2]

Occasionally, new software might introduce bugs or compatibility issues with your hardware.[4]

### Selective Update Strategies

#### Using IgnorePkg

If you encounter trouble with a new kernel version, it's generally acceptable to use `IgnorePkg` for the linux package to prevent the update:[4]

```
# /etc/pacman.conf
[options]
IgnorePkg = linux
```


**Warning:** While you can defer updates for many packages, be cautious, as this can lead to a partial upgrade, which is unsupported. Some critical system packages cannot be individually held back.[4]

#### Holding Back Updates Temporarily

When updates are available but you're not ready to apply them:

1. Check the news for manual intervention requirements
2. If manual intervention is needed and you can't perform it immediately, delay the update
3. Never run `pacman -Sy` alone—always complete the full upgrade when you start
4. Document which packages you're holding back and why

### Community Research Strategy

Check forums and Reddit for potential issues before updating:[1]

```
# Search on Reddit: r/archlinux
# Look for posts about recent updates
# Check for widespread issues or bugs
```


This proactive approach helps identify problems before they affect your system.[1]

### Backup and Recovery Tools

#### downgrade Utility

Keep the `downgrade` tool available as a stopgap to roll back bad packages at times:[1]

```
paru -S downgrade
yay -S downgrade
```


This tool provides quick recovery when a package update causes problems.[1]

#### Pacman Cache

The previous packages are stored in the `/var/cache` directory, allowing you to revert to earlier versions if any issues arise.[4]

Use `paccache` to help manage your cached packages effectively:[4]

```
paccache -r      # Keep 3 most recent versions
paccache -rk1    # Keep only 1 version
```


### Maintenance Integration

#### Regular Maintenance Tasks

Combine updates with regular maintenance:[3]

```
# 1. Update system
sudo pacman -Syu

# 2. Clean package cache
paccache -r

# 3. Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# 4. Clean home directory cache
rm -rf ~/.cache/*

# 5. Check system logs
journalctl --vacuum-size=100M
```


#### Troubleshooting Common Issues

**Marginal trust errors:**
If you encounter "signature from someone is marginal trust" errors:[3]

```
sudo pacman -Sy archlinux-keyring
sudo pacman -Syu
```


This updates the keyrings and then runs the full system upgrade command again.[3]

### Best Practices Summary

**Always:**
- Read Arch Linux news before updating[3][1][2]
- Have rescue media available[1][2]
- Use `pacman -Syu` for full system upgrades[2]
- Handle `.pacnew` files promptly[2]
- Restart or reboot after significant updates[2]
- Update AUR packages when system libraries change[4][2]

**Never:**
- Perform partial upgrades (`pacman -Sy package_name`)[2]
- Update immediately before critical tasks[2]
- Ignore pacman alerts during upgrades[2]
- Leave the system without updates for months[4]

**Recommended frequency:**
- Daily to weekly for active systems[1][4]
- Minimum monthly for occasional-use systems[4]

Sources
[1] what are the best practices to update arch? : r/archlinux https://www.reddit.com/r/archlinux/comments/19d6h04/what_are_the_best_practices_to_update_arch/
[2] System maintenance - ArchWiki https://wiki.archlinux.org/title/System_maintenance
[3] Arch Linux System Maintainance. https://fernandocejas.com/blog/engineering/2022-03-30-arch-linux-system-maintance/
[4] How often should I be updating my Arch installation? https://www.reddit.com/r/archlinux/comments/1l39jb4/how_often_should_i_be_updating_my_arch/
[5] Best practices for updating Arch Linux systems safely https://www.facebook.com/groups/linux.fans.group/posts/25519821174299657/
[6] Essential Tips for Updating & Upgrading Your Linux Distro https://linuxsecurity.com/howtos/learn-tips-and-tricks/upgrade-your-linux-distro
[7] General recommendations - ArchWiki https://wiki.archlinux.org/title/General_recommendations
[8] Arch Linux Maintenance | Pacman maintenance https://www.youtube.com/watch?v=3BnHHP7Fmo0


