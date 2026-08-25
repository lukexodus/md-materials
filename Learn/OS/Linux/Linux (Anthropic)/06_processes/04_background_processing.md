## Background Processing


### Background Execution

**Key points:** Background execution allows processes to run independently of the terminal session, freeing up the command line for other tasks.

The ampersand (`&`) operator launches commands in the background:

```bash
command &
```

When a process runs in the background:

- The shell immediately returns control to the user
- A job number and process ID (PID) are displayed
- The process continues executing without blocking the terminal

**Example:**

```bash
$ sleep 300 &
[1] 12345
$ # Terminal is immediately available for other commands
```

**Output:** `[1]` represents the job number, `12345` is the PID.

Background processes inherit the current working directory and environment variables from the parent shell. They can still produce output to the terminal unless redirected:

```bash
find / -name "*.log" > search_results.txt 2>&1 &
```

### Job Management

**Key points:** Job management commands control processes started from the current shell session.

#### Jobs Command

The `jobs` command lists active jobs:

```bash
jobs [options]
```

Common options:

- `-l`: Show process IDs alongside job information
- `-p`: Display only process IDs
- `-r`: Show only running jobs
- `-s`: Show only stopped jobs

**Example:**

```bash
$ jobs -l
[1]+ 12345 Running    sleep 300 &
[2]- 12346 Stopped    vim document.txt
```

#### Foreground Command (fg)

The `fg` command brings background jobs to the foreground:

```bash
fg [job_spec]
```

If no job specification is provided, `fg` affects the most recent job. Job specifications can be:

- `%n`: Job number n
- `%string`: Job whose command begins with string
- `%?string`: Job whose command contains string
- `%%` or `%+`: Current job
- `%-`: Previous job

**Example:**

```bash
$ fg %1    # Brings job 1 to foreground
$ fg       # Brings current job to foreground
```

#### Background Command (bg)

The `bg` command resumes stopped jobs in the background:

```bash
bg [job_spec]
```

This is particularly useful for jobs stopped with Ctrl+Z:

```bash
$ vim document.txt
# Press Ctrl+Z to suspend
[1]+ Stopped    vim document.txt
$ bg %1
[1]+ vim document.txt &
```

### Persistent Processes

**Key points:** Standard background processes terminate when the parent shell exits. Persistent process techniques ensure continuation beyond session termination.

#### Nohup Command

The `nohup` (no hang up) command prevents processes from receiving the SIGHUP signal:

```bash
nohup command [arguments] &
```

**Features:**

- Ignores SIGHUP signals sent when terminal closes
- Redirects stdout and stderr to `nohup.out` by default
- Process continues running after logout

**Example:**

```bash
$ nohup python data_processing.py &
[1] 12347
nohup: ignoring input and appending output to 'nohup.out'
```

Custom output redirection with nohup:

```bash
nohup ./backup_script.sh > backup.log 2>&1 &
```

#### Disown Command

The `disown` command removes jobs from the shell's job table:

```bash
disown [job_spec]
```

Options:

- `-a`: Remove all jobs from job table
- `-h`: Mark jobs to not receive SIGHUP
- `-r`: Remove only running jobs

**Example:**

```bash
$ long_running_process &
[1] 12348
$ disown %1
$ # Process continues even after shell exit
```

#### Screen and Tmux

Terminal multiplexers provide robust session persistence:

Screen usage:

```bash
screen -S session_name
# Run commands
# Detach with Ctrl+A, D
screen -r session_name  # Reattach
```

Tmux usage:

```bash
tmux new-session -s session_name
# Run commands
# Detach with Ctrl+B, D
tmux attach-session -t session_name
```

### Process Priorities

**Key points:** Process priorities determine CPU scheduling preference using nice values ranging from -20 (highest priority) to 19 (lowest priority).

#### Nice Command

The `nice` command starts processes with specified priority:

```bash
nice [option] [command [arguments]]
```

Default nice value is 0. Higher nice values mean lower priority:

```bash
nice -n 10 compute_intensive_task
nice --adjustment=5 backup_script.sh
```

**Example:**

```bash
$ nice -n 15 find / -name "*.tmp" -delete &
[1] 12349
$ # Process runs with lower priority, using CPU when available
```

#### Renice Command

The `renice` command modifies priority of existing processes:

```bash
renice priority [-p] pid
renice priority -g process_group
renice priority -u username
```

**Example:**

```bash
$ renice 10 12349          # Change PID 12349 to nice value 10
$ renice -5 -u john        # Set all john's processes to nice -5
$ renice 0 -g staff        # Set process group staff to nice 0
```

Priority modification permissions:

- Regular users can only increase nice values (lower priority)
- Root can set any nice value
- Users cannot modify other users' processes without privileges

**Practical considerations:**

- Nice values affect CPU scheduling, not I/O priority
- Use `ionice` for I/O priority control on supported systems
- Monitor system load when running multiple background processes
- Consider using `cpulimit` for strict CPU usage control

**Conclusion:** Background processing enables efficient multitasking and resource management. Job control provides flexibility in managing concurrent processes, while persistence techniques ensure critical tasks survive session termination. Priority management prevents resource monopolization and maintains system responsiveness.

---

