# Lab1 part 2

## OS161 Thread Debugging Guide: Docker/WSL TCP Workaround

### Terminal 1: Starting the OS161 Simulator

First, start the simulator and tell it to wait for a debugger connection (`-w`) and open a TCP port (`-p 2345`) because we need to overcame Docker socket limitation.

```bash
cd ~/os161/root
sys161 -w -p 2345 kernel
```
the expected output is:
```bash
sys161: bind: Operation not supported
sys161: Could not set up meter socket; metering disabled
sys161: System/161 release 2.0.8, compiled Mar 22 2022 23:45:01
sys161: Waiting for debugger connection...
```
in case the kernel happen to be locked by another process:
```bash
sys161 -w -p 2345 kernel
sys161: disk: slot 2: LHD0.img: Locked by another process
```
we simply kill it with:
```bash
pkill -9 sys161
```

### Terminal 2: Launching and Connecting GDB
Open a second terminal to launch the debugger. Depending on your toolchain, the command might be `mips-harvard-os161-gdb`.
```bash
cd ~/os161/root
mips-harvard-os161-gdb kernel
```
the expected output is (may vary based on the `os161` version):
```bash
GNU gdb (GDB) 7.8
Copyright (C) 2014 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "--host=x86_64-unknown-linux-gnu --target=mips-harvard-os161".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from kernel...done.
.gdbinit:5: Error in sourced command file:
unix:.sockets/gdb: Operation not supported.
```
now we manually extablish our TCP connection with the port opened in the terminal before:
```bash
(gdb) target remote 127.0.0.1:2345
```
expected output (similar):
```bash
Remote debugging using 127.0.0.1:2345
__start () at ../../arch/sys161/main/start.S:54
54         addiu sp, sp, -24
```
Meanwhile on terminal one it will be appended:
```bash
...
sys161: Waiting for debugger connection...
sys161: New debugger connection
```
so now our connection is established

### Setting Breakpoints
With the simulator paused before boot, set breakpoints on the key thread lifecycle functions to trace the scheduler and context switches (output may vary based on the version and kernel config):
```bash
(gdb) break thread_create
Breakpoint 1 at 0x80014628: file ../../thread/thread.c, line 118.
(gdb) break thread_yield
Breakpoint 2 at 0x800154c4: file ../../thread/thread.c, line 808.
(gdb) break thread_fork
Breakpoint 3 at 0x80015048: file ../../thread/thread.c, line 499.
```

### Running the Test and Tracing Execution
In Terminal 2 (GDB), type `continue` (or `c`) until the OS finish booting.

In Terminal 1, wait for the OS menu prompt (OS/161 kernel [? for menu]:) and type your test command (e.g., tt1).

Terminal 2 will instantly pause execution when it hits your first breakpoint.

#### GDB Command Cheat Sheet
Once execution is paused, use these commands in the (gdb) prompt to trace the kernel:

- `c` (continue): Fast-forwards execution until the next breakpoint is hit.

- `n` (next): Executes the current line of C code and stops at the next line (steps over functions).

- `s` (step): Executes the current line and steps inside the function being called (crucial for watching thread_yield call thread_switch).

- `bt` (backtrace): Prints the call stack. Shows you exactly which sequence of functions led to the current pause state.

- `p <variable>` (print): Evaluates and prints the value of a variable (e.g., p curthread->t_name).

- `delete`: Removes all breakpoints so the test can finish running at full speed.

- `quit`: Exits the debugger.

Pressing Enter without typing anything will automatically repeat your last command.
