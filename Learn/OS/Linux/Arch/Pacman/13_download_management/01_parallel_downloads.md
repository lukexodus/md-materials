## Parallel Downloads


### Overview

Parallel downloads allow pacman to download multiple packages simultaneously rather than sequentially, significantly reducing the time required for system updates and package installations. This feature was introduced in pacman 6.0.

### Enabling Parallel Downloads

#### Configuration in pacman.conf

Edit `/etc/pacman.conf` to enable parallel downloads:

```
sudo nano /etc/pacman.conf
```

Add or uncomment the `ParallelDownloads` directive in the `[options]` section:

```
[options]
ParallelDownloads = 5
```

The number specifies how many packages to download simultaneously.

#### Recommended Values

**Conservative (default):**
```
ParallelDownloads = 5
```

Provides good speedup without overwhelming the connection.

**Moderate:**
```
ParallelDownloads = 10
```

Better for fast internet connections (50+ Mbps).

**Aggressive:**
```
ParallelDownloads = 15
```

For very fast connections (100+ Mbps) or when downloading small packages.

**Maximum:**
```
ParallelDownloads = 20
```

Generally not recommended; diminishing returns and potential mirror strain.

### How It Works

#### Sequential vs Parallel Downloading

**Without parallel downloads (traditional):**
1. Download package 1 → Complete
2. Download package 2 → Complete
3. Download package 3 → Complete
4. Total time: Sum of all individual download times

**With parallel downloads (ParallelDownloads = 5):**
1. Download packages 1, 2, 3, 4, 5 simultaneously
2. As each completes, start the next package
3. All packages finish faster overall
4. Total time: Reduced significantly, limited by bandwidth

#### Benefits

**Faster updates:** System upgrades complete more quickly, especially when many packages need updating.

**Better bandwidth utilization:** Maximizes use of available internet bandwidth rather than downloading one small package at a time.

**Reduced wait time:** Less time spent waiting for package operations to complete.

**Improved user experience:** More responsive package management, particularly on fast connections.

### Performance Considerations

#### Optimal Number Selection

The ideal `ParallelDownloads` value depends on:

**Internet connection speed:**
- Slow (< 10 Mbps): 3-5 parallel downloads
- Medium (10-50 Mbps): 5-10 parallel downloads
- Fast (50-100 Mbps): 10-15 parallel downloads
- Very fast (> 100 Mbps): 15-20 parallel downloads

**Mirror capacity:**
- Some mirrors may throttle or struggle with many simultaneous connections
- More isn't always better if mirrors can't handle the load

**Package size distribution:**
- Many small packages benefit more from parallel downloads
- Few large packages see less benefit

**System resources:**
- Each concurrent download uses some CPU and RAM for verification
- Very resource-constrained systems might want lower values

### Testing and Optimization

#### Benchmark Different Settings

Test various `ParallelDownloads` values to find optimal performance:

**Test with 5 parallel downloads:**
```
# Set ParallelDownloads = 5
time sudo pacman -Syu
```

**Test with 10 parallel downloads:**
```
# Set ParallelDownloads = 10
time sudo pacman -Syu
```

Compare times to determine the sweet spot for your connection and mirrors.

#### Monitor Download Performance

Watch download activity during package operations:

```
sudo pacman -Syu
```

Observe:
- How many packages download simultaneously
- Whether bandwidth is fully utilized
- If downloads seem to queue or stall

### Compatibility

#### Pacman Version Requirement

Parallel downloads require **pacman 6.0 or later**.

**Check pacman version:**
```
pacman --version
```

**Example output:**
```
Pacman v6.0.2 - libalpm v13.0.2
```

If you're on pacman 5.x or earlier, the `ParallelDownloads` directive is ignored.

#### Upgrading Pacman

To use parallel downloads on older systems:

```
sudo pacman -Syu pacman
```

After upgrading pacman to 6.0+, enable `ParallelDownloads` in the configuration.

### Interaction with Other Features

#### Mirror Selection

Parallel downloads work best with:

**Multiple fast mirrors:** Having several mirrors in the mirrorlist allows pacman to distribute load and use the fastest available servers.

**Geographically close mirrors:** Reduces latency, improving parallel download efficiency.

**HTTPS mirrors:** While slightly slower than HTTP, HTTPS provides security without significantly impacting parallel download performance.

#### Signature Verification

Package signature verification happens **after** download completes. With parallel downloads:

1. Multiple packages download simultaneously
2. Each completed package is verified before installation
3. Verification is still single-threaded (as of pacman 6.0)

Future pacman versions may parallelize signature verification as well.

### Troubleshooting

#### Slow Downloads Despite Parallel Downloads

**Possible causes:**

**Mirror limitations:** Some mirrors throttle connections or have bandwidth limits.

**Solution:** Update mirrorlist to use faster mirrors:
```
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

**Connection bottleneck:** Your internet connection is the limiting factor, not download parallelism.

**Solution:** Reduce `ParallelDownloads` to avoid overhead; more connections won't help if bandwidth is saturated.

**ISP throttling:** Internet service provider may throttle multiple connections.

**Solution:** Try different mirrors or HTTPS vs HTTP protocols.

#### Download Failures or Timeouts

Too many parallel downloads can cause issues:

**Symptoms:**
- Connection timeouts
- Failed downloads
- Mirror refusing connections

**Solution:** Reduce `ParallelDownloads` value:
```
ParallelDownloads = 3
```

#### Increased CPU/Memory Usage

Each parallel download consumes resources:

**Symptoms:**
- High CPU usage during downloads
- Increased memory consumption
- System slowdown during package operations

**Solution:** Lower `ParallelDownloads` on resource-constrained systems:
```
ParallelDownloads = 3
```

### Comparison: Before and After

#### Example Scenario

**100 packages to download, average 10 MB each, 50 Mbps connection**

**Sequential (ParallelDownloads disabled):**
- Download time: ~27 minutes (one at a time)

**Parallel (ParallelDownloads = 5):**
- Download time: ~8-10 minutes (5 at a time)
- Speedup: ~60-70% reduction

**Parallel (ParallelDownloads = 10):**
- Download time: ~6-8 minutes (10 at a time)
- Speedup: ~70-80% reduction

Actual performance varies based on connection speed, mirror performance, and package sizes.

### Advanced Configuration

#### Disable Parallel Downloads

To disable parallel downloads and return to sequential behavior:

**Remove or comment out the directive:**
```
#ParallelDownloads = 5
```

Or set to 1:
```
ParallelDownloads = 1
```

#### Temporary Override

Override parallel downloads for a single operation:

Unfortunately, pacman doesn't provide a command-line flag to override `ParallelDownloads`. You must edit `/etc/pacman.conf` to change the setting.

### Best Practices

**Start conservative:** Begin with `ParallelDownloads = 5` and adjust based on performance.

**Monitor performance:** Observe actual download speeds and adjust accordingly.

**Consider connection type:** WiFi connections may benefit from lower values than wired connections.

**Respect mirrors:** Don't use excessively high values that stress mirror servers unnecessarily.

**Update mirrors regularly:** Fast, reliable mirrors maximize parallel download benefits.

**Test during off-peak:** Mirror performance varies by time of day; test at typical usage times.

**Balance speed and stability:** Higher values aren't always better if they cause timeouts or failures.

**Resource constraints matter:** Lower-powered systems (Raspberry Pi, VMs) should use lower values.

### Security Considerations

**Signature verification unchanged:** Parallel downloads don't affect signature verification; all packages are still validated.

**HTTPS recommended:** Use HTTPS mirrors with parallel downloads for security without significant performance penalty.

**Mirror trust:** Parallel downloads don't change mirror trust model; package signatures provide security, not download method.

### Future Developments

Potential future improvements to parallel downloads:

**Parallel signature verification:** Verifying signatures in parallel could further reduce installation time.

**Intelligent scheduling:** Optimizing which packages download first based on size and dependencies.

**Adaptive parallelism:** Automatically adjusting parallel download count based on connection performance.

**Per-mirror parallelism:** Different parallel settings for different mirrors based on their capacity.

Parallel downloads are a significant improvement in pacman's performance, making system maintenance faster and more efficient for most users with modern internet connections.

