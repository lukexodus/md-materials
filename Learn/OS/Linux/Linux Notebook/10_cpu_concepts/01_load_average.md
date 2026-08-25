## Load Average


Load average is a **metric that measures** system load, representing the average number of processes either running on the CPU or waiting in the queue for CPU time and I/O resources over specified time periods. In Linux and Unix-like systems, load average is displayed as three decimal values.[1][3]

### Understanding the Three Values

The three load average numbers represent exponentially damped moving averages over different time periods:[3]

- **First number**: 1-minute average
- **Second number**: 5-minute average  
- **Third number**: 15-minute average

You can view load average using the `uptime` command, the `w` command, the `top` command, or by reading `/proc/loadavg`. For example, `uptime` might display: `load average: 0.06, 0.11, 0.09`.[3]

### Interpreting Load Average

Load average differs from CPU usage percentage. The key to interpretation is understanding your system's CPU core count. A load of 1.0 equals 100% utilization on a single-core system, but on a dual-core system, a load of 2.0 represents full utilization, and on a quad-core system, a load of 4.0 means full utilization.[2][5]

Common guidelines for single-core systems include:

- **Load < 0.70**: System is healthy with headroom
- **Load 0.70-1.00**: Time to investigate performance issues
- **Load > 1.00**: System is overloaded and needs attention[5]

For multi-core systems, divide the load average by the number of cores to determine utilization percentage.[5]

### What Load Average Measures

Load average includes both CPU-bound processes and processes waiting for I/O resources (disk reads/writes), making it a comprehensive measure of system pressure beyond just CPU usage. This metric is valuable for system performance monitoring, troubleshooting performance problems, and capacity planning decisions.[6]

Sources
[1] What is Load Average in Linux? https://www.digitalocean.com/community/tutorials/load-average-in-linux
[2] Understanding load average vs. cpu usage [closed] https://stackoverflow.com/questions/21617500/understanding-load-average-vs-cpu-usage
[3] Load (computing) https://en.wikipedia.org/wiki/Load_(computing)
[4] understanding load averages in the context of the number ... https://www.reddit.com/r/linuxquestions/comments/1f78vy5/understanding_load_averages_in_the_context_of_the/
[5] Understanding Linux CPU Load - when should you be ... https://www.scoutapm.com/blog/understanding-load-averages
[6] System Load Average | Learn Netdata https://learn.netdata.cloud/docs/collecting-metrics/linux-systems/system/system-load-average
[7] Can someone explain the CPU 5 minute load average ... https://community.logicmonitor.com/discussions/product-discussions/can-someone-explain-the-cpu-5-minute-load-average-thing-to-me/17297



