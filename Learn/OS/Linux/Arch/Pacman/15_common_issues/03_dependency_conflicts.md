## Dependency Conflicts


### Overview

Dependency conflicts occur when package relationships cannot be satisfied simultaneously. Understanding and resolving these conflicts is crucial for maintaining a functional Arch Linux system, especially given its rolling-release nature.

### Types of Dependency Conflicts

#### Unresolvable Dependencies

**Missing package:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-a (1.0-1) breaks dependency 'lib-old' required by package-b
```

**Cause:** Package requires a specific version or library that conflicts with other requirements.

#### Version Conflicts

**Incompatible versions:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires lib>=2.0
:: package-b: requires lib<2.0
```

**Cause:** Two packages need incompatible versions of the same dependency.

#### Circular Dependencies

**Mutual requirements:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-a: requires package-b
:: package-b: requires package-a
```

**Cause:** Packages depend on each other, creating a chicken-and-egg problem.

#### Provider Conflicts

**Multiple providers:**
```
:: There are 2 providers available for dependency-name:
:: Repository extra
   1) provider-a  2) provider-b

Enter a number (default=1):
```

**Cause:** Multiple packages can satisfy a virtual dependency.

### Common Dependency Scenarios

#### Broken Dependencies After Partial Upgrade

**Symptom:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package: requires glibc=2.38 but 2.39 is to be installed
```

**Cause:** Partial upgrade (`pacman -Sy package-name` instead of `pacman -Syu`).

**Solution:**
```
sudo pacman -Syu
```

Always perform full system upgrades. Partial upgrades are **unsupported** on Arch Linux.

#### AUR Package Dependency Conflicts

**Symptom:**
```
error: package: requires python<3.12
```

**Cause:** AUR package not updated for newer system libraries.

**Solutions:**

**1. Update AUR package:**
```
cd ~/aur-package
git pull
makepkg -si
```

**2. Check AUR comments for fixes:**
Visit the AUR page and check comments for patches or workarounds.

**3. Modify PKGBUILD:**
Update dependency versions in the PKGBUILD if safe.

**4. Downgrade system package temporarily:**
```
sudo pacman -U /var/cache/pacman/pkg/python-3.11.*.pkg.tar.zst
```

Add to IgnorePkg while waiting for AUR package update.

#### Library Version Conflicts

**Symptom:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: package-new: installing package-new (2.0-1) breaks dependency 'lib<2.0' required by package-old
```

**Cause:** New package version incompatible with old dependents.

**Solution:**

**Update all affected packages:**
```
sudo pacman -S package-new package-old
```

If package-old has a compatible update, both install successfully.

**If no update available:**
```
sudo pacman -Rns package-old  # Remove old package
sudo pacman -S package-new    # Install new package
```

### Resolving Dependency Conflicts

#### Strategy 1: Full System Upgrade

**Always try this first:**
```
sudo pacman -Syu
```

Most dependency conflicts resolve when all packages update together.

#### Strategy 2: Install Conflicting Packages Together

**Simultaneous installation:**
```
sudo pacman -S package-a package-b package-c
```

Installing multiple packages in one transaction allows pacman to resolve dependencies collectively.

#### Strategy 3: Remove Blocking Packages

**Identify blocking package:**
```
error: failed to prepare transaction (could not satisfy dependencies)
:: installing package-new breaks dependency 'old-lib' required by blocking-package
```

**Remove blocker:**
```
sudo pacman -Rns blocking-package
sudo pacman -S package-new
```

**Reinstall compatible version:**
```
sudo pacman -S blocking-package-new
```

#### Strategy 4: Use --overwrite for File Conflicts

**When files conflict during dependency resolution:**
```
sudo pacman -S --overwrite /path/to/conflicting/file package-name
```

**For widespread conflicts:**
```
sudo pacman -S --overwrite '*' package-name
```

**Warning:** Use sparingly; understand what you're overwriting.

#### Strategy 5: Skip Dependency Checks (Dangerous)

**Single dependency level skip:**
```
sudo pacman -Sd package-name
```

**Skip all dependency checks:**
```
sudo pacman -Sdd package-name
```

**Warning:** This can break your system. Only use when you fully understand the implications and have a recovery plan.

### Handling Circular Dependencies

#### Simultaneous Installation

**Install both packages together:**
```
sudo pacman -S package-a package-b
```

Pacman resolves circular dependencies when packages install in the same transaction.

#### Build Order Issues

**For AUR packages with circular deps:**

**1. Install one with --nodeps:**
```
makepkg -si --nodeps
```

**2. Install the other normally:**
```
makepkg -si
```

**3. Reinstall the first to satisfy deps:**
```
makepkg -sif
```

### Provider Selection

#### Choosing Between Providers

**Multiple providers available:**
```
:: There are 3 providers available for java-runtime:
:: Repository extra
   1) jre-openjdk  2) jre11-openjdk  3) jre8-openjdk

Enter a number (default=1):
```

**Selection strategies:**

**Default option:** Press Enter to accept default (usually most current version).

**Specific version:** Enter number for required version (check dependent package requirements).

**Research-based:** Check package descriptions and dependencies before selecting:
```
pacman -Si jre-openjdk
pacman -Si jre11-openjdk
```

#### Setting Default Providers

**Avoid repeated prompts:**

Install the preferred provider first:
```
sudo pacman -S jre-openjdk
```

Future packages requiring `java-runtime` use the already-installed provider.

### Dependency Trees and Analysis

#### Viewing Dependency Trees

**Show package dependencies:**
```
pactree package-name
```

**Show reverse dependencies:**
```
pactree -r package-name
```

This shows which packages depend on the specified package.

**Install pactree:**
```
sudo pacman -S pacman-contrib
```

#### Analyzing Conflicts

**Check why a package is needed:**
```
pacman -Qi package-name | grep "Required By"
```

**Find optional dependencies:**
```
pacman -Qi package-name | grep "Optional For"
```

**Determine if safe to remove:**
```
pactree -r package-name
```

If no packages depend on it, removal is safe.

### Common Conflict Patterns

#### Python Version Conflicts

**Symptom:**
```
package-name: requires python<3.12
```

**Common with:** AUR packages, older Python applications

**Solutions:**

**1. Update package:**
Check for newer version or AUR comments for Python 3.12 compatibility.

**2. Use virtual environments:**
```
python -m venv venv
source venv/bin/activate
pip install package
```

**3. Downgrade Python temporarily:**
```
sudo pacman -U /var/cache/pacman/pkg/python-3.11.*.pkg.tar.zst
```

Add to IgnorePkg until package updates.

#### Qt/KDE Library Conflicts

**Symptom:**
```
package: requires qt5-base=5.15.10
```

**Cause:** Qt libraries frequently update; dependent packages lag.

**Solution:**

**Full KDE/Qt update:**
```
sudo pacman -S $(pacman -Qsq qt5) $(pacman -Qsq qt6)
```

Updates all Qt-related packages together.

#### GTK Version Conflicts

**Mixing GTK3 and GTK4:**
```
package-new: requires gtk4
package-old: requires gtk3
```

**Solution:**
Both can coexist. Install both GTK versions:
```
sudo pacman -S gtk3 gtk4
```

#### Library Soname Changes

**Symptom:**
```
error: package: requires libfoo.so.5
```

**Cause:** Library major version changed (libfoo.so.5 → libfoo.so.6).

**Solution:**

**Update all dependents:**
```
sudo pacman -Syu
```

**Rebuild AUR packages:**
```
yay -S package-name --rebuild
paru -S package-name --rebuild
```

### Breaking Dependency Chains

#### Using -Rdd (Remove Without Deps)

**Remove package ignoring dependencies:**
```
sudo pacman -Rdd package-name
```

**Warning:** This breaks dependent packages. Only use when:
- You plan to immediately reinstall compatible version
- You're removing the dependent packages too
- You fully understand the consequences

**Safer alternative with cascade:**
```
sudo pacman -Rc package-name
```

This removes the package and all dependents (prompts for confirmation).

#### Temporary Dependency Satisfaction

**Trick pacman into thinking dependency is satisfied:**
```
sudo pacman -S --assume-installed dependency=version package-name
```

**Example:**
```
sudo pacman -S --assume-installed python=3.11 package-requiring-old-python
```

**Warning:** This doesn't actually install the dependency; use only when you know it's truly satisfied another way.

### Recovery from Broken Dependencies

#### Identifying Broken Packages

**Check for broken dependencies:**
```
pacman -Qk
```

**More thorough check:**
```
pacman -Qkk
```

**Using paccheck:**
```
sudo pacman -S pacutils
paccheck --depends
```

#### Rebuilding Dependency Information

**Reinstall package to fix meta**
```
sudo pacman -S package-name
```

**Force database update only:**
```
sudo pacman -S --dbonly package-name
```

### Preventive Measures

#### Best Practices to Avoid Conflicts

**Never do partial upgrades:**
```
# Bad: pacman -Sy package-name
# Good: pacman -Syu
```

**Update regularly:** Frequent updates prevent large dependency gaps.

**Read Arch news:** Manual intervention notices explain major dependency changes.

**Update AUR packages:** Rebuild AUR packages after system library updates:
```
yay -Syu --devel
paru -Syu --devel
```

**Maintain clean system:** Remove orphaned packages:
```
sudo pacman -Rns $(pacman -Qdtq)
```

**Check before installing:** Review dependencies before committing:
```
pacman -Si package-name | grep Depends
```

### When to Seek Help

#### Documentation Resources

**Arch Wiki:**
```
https://wiki.archlinux.org/
```

Search for specific packages or error messages.

**Arch Forums:**
```
https://bbs.archlinux.org/
```

Search for similar issues or post new questions.

**AUR Package Comments:**
Check AUR page comments for known dependency issues and solutions.

#### Reporting Issues

**Check if it's a known issue:**
```
https://bugs.archlinux.org/
```

**Gather diagnostic information:**
```
pacman -Si package-name
pacman -Qi package-name
pactree package-name
pactree -r package-name
```

Include this information when reporting or asking for help.

### Best Practices

**Understand before acting:** Research why conflicts occur before forcing solutions.

**Full system upgrades:** Always use `pacman -Syu`, never partial upgrades.

**Read error messages:** Pacman clearly explains what's wrong; read carefully.

**Check dependency trees:** Use `pactree` to understand package relationships.

**Avoid --nodeps:** Skipping dependency checks creates problems.

**Update together:** Install conflicting packages in single transaction.

**Remove cleanly:** Use `-Rns` to remove packages with dependencies and configs.

**Monitor AUR packages:** Rebuild after system library updates.

**Keep backups:** Snapshot system before major dependency changes.

**Ask for help:** Don't guess; seek assistance when unsure.

Proper dependency conflict resolution maintains system stability and prevents cascading failures that could render

