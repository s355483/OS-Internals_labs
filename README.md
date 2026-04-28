# OS-Internals_labs
Repository for the laboratory part of the OS internals class (Politecnico di Torino LM-32 AI-Driven) held by Professor Giampiero Cabodi

---

# How to work (with VScode)
Click on the Manage button in the bottom left, then "Extensions" and ensure that you have the "Remote - Containers" extension installed. (You can also open the Extensions tab with <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> on macOS.)

With the container running,  use the shortcut <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> if you are on macOS) to open the *Command Palette* and run the **Dev Containers: Attach to Running Container...** command.

You will be asked to confirm that attaching means you trust the container. You need to confirm this only once, the first time you attach to the container.

Select the `polito-os161` container. The first time you attach to it, VSCode will install a server inside the container. This allows us to install and run extensions inside the container, where they have full access to the tools, platform, and file system. Wait until the installation is complete, you should see something like this in the bottom left-hand corner:

Now you can go ahead to open the folder containing OS/161 inside the container by clicking on *File -> Open Folder* and searching for `/home/os161user/os161`. The window will reload with the opened folder.

## Configure VScode to work on OS/161

Before starting to work on OS/161 using VSCode, we suggest to install the [C/C++ Extension](https://code.visualstudio.com/docs/languages/cpp).

If you are using macOs, chances are that the C/C++ extension won't work correctly out-of-the-box within the container. If you get an error like this one when trying to launch the debugger:
```
Launching server using command /home/os161user/.vscode-server/extensions/ms-vscode.cpptools-<CPPTOOLS_VERSION>/bin failed.
```
you can try the following workaround:
1. Log into a terminal session within the container (the open session in the Terminal panel of VSCode works just fine).
2. Navigate to the directory containing the C/C++ extension binaries.
```
cd /home/os161user/.vscode-server/extensions/ms-vscode.cpptools-<CPPTOOLS_VERSION>/bin
```
3. Add execution permissions to `cpptools` and `cpptools-srv`.
```
chmod +x cpptools
chmod +x cpptools-srv
```

---

# How to run the os161 kernel

in `/home/os161user/os161/src/kern/conf` create or use a kernel configuration file named in full uppercase, then generate the kernel build configuration with the following command (remember to stick with the previous folder):
```
./config <KERNEL-CONFIG>
```
after that we need to invoke what's so called "Holy Trinity" in that very order, but first we need to get to the correct path:
```
cd ../compile/<KERNEL-CONFIG>
```
this is the build directory for our specific kernel configuration and now we can begin this holy operation:
```
bmake depend
```
It analyzes your source code and builds a dependency map. Without this step: changes might not propagate correctly and you can get weird bugs or outdated builds, it also generates internal rules used by `bmake`.
Then we need to compile our kernel with:
```
bmake
```
it compile all the source `.c` files into object files `.o`, links them together and produces the final kernel binary.
After that we need to install our kernel in order to run it.
```
bmake install
```
It basically copies the compiled kernel into the runtime directory. Run those 3 commands and will end up having your vibe-coded "upedated" kernell ready to create bugs and leeks all around. <br>
In the end we need to set up our simulator configuration in order to launch our kernell.
```
cd /home/os161user/os161/root
```
First move to the runtime environment directory then, IF NEEDED, copy the simulator configuration sample into the sys161 configuration file.
```
cp /home/os161user/os161/tools/share/examples/sys161/sys161.conf.sample sys161.conf
```
Now keeping ourselves located in the root folder of the `os161` kernel let’s **light it up!🧨🔥**:
```
sys161 kernel
```
that command start the simulator with your kernel.

# Do you want to run it quickly?
### Use the `build.sh`
if not provided here is the code:
```bash
#!/bin/bash

# Exit immediately if any command fails
set -e

# ==============================================================================
# OS/161 Kernel Build & Run Automation Script
#
# Description:
#   Automates the process of configuring, compiling, installing, and optionally 
#   running an OS/161 kernel. Uses flag arguments for maximum flexibility.
#
# Usage:
#   ./build.sh [-c CONFIG] [-a ACTION] [-t CONF_TEMPLATE]
#
# Options:
#   -c CONFIG        : The kernel configuration name. 
#                      (Default: DUMBVM)
#   -a ACTION        : 'build' to only compile and install, or 'run' to 
#                      compile, install, and immediately launch sys161. 
#                      (Default: build)
#   -t CONF_TEMPLATE : The filename of the sys161.conf sample file. This is 
#                      appended to the default OS/161 tools path.
#                      (Default: sys161.conf.sample)
#
# Examples:
#   ./build.sh                           -> Builds DUMBVM (does not run)
#   ./build.sh -c ASST1                  -> Builds ASST1 (does not run)
#   ./build.sh -a run                    -> Builds DUMBVM and runs it
#   ./build.sh -c ASST2 -a run           -> Builds ASST2 and runs it
#   ./build.sh -a run -t my_custom.conf  -> Builds DUMBVM, runs it, uses custom template
# ==============================================================================

KERNEL_CONFIG="DUMBVM"
ACTION="build"
CONF_TEMPLATE="sys161.conf.sample"

while getopts "c:a:t:" opt; do
  case $opt in
    c) KERNEL_CONFIG="$OPTARG" ;;
    a) ACTION="$OPTARG" ;;
    t) CONF_TEMPLATE="$OPTARG" ;;
    \?) echo "Uso: ./build.sh [-c config] [-a action] [-t template]" >&2
        exit 1 ;;
  esac
done

echo "========================================"
echo " Starting OS/161 Workflow"
echo " Configuration  : $KERNEL_CONFIG"
echo " Action         : $ACTION"
echo " Confi Template : $CONF_TEMPLATE"
echo "========================================"

echo "[1/4] Generating kernel build..."
cd ~/os161/src/kern/conf
./config "$KERNEL_CONFIG"

echo "[2/4] Linking kernel dependencies..."
cd "../compile/$KERNEL_CONFIG"
bmake depend

echo "[3/4] Compiling the kernel..."
bmake

echo "[4/4] Installing the kernel..."
bmake install

if [ "$ACTION" = "run" ]; then
    echo "========================================"
    echo " Launching OS/161 Emulator"
    echo "========================================"
    
    cd ~/os161/root

    if [ ! -f sys161.conf ]; then
        echo "sys161.conf missing in root directory."
        echo "Copying template from: $~/os161/tools/share/examples/sys161/$CONF_TEMPLATE"
        cp "~/os161/tools/share/examples/sys161/$CONF_TEMPLATE" sys161.conf
    fi

    # Launch the emulator
    sys161 kernel
else
    echo "========================================"
    echo " Build complete. (Run skipped)"
    echo "========================================"
fi
```

### Make it Executable
Before you can run the script, you must grant it execution permissions. Run this once in your terminal:

```bash
cd ~/os161
chmod +x build.sh
```
### Usage Examples
- Build the default kernel (DUMBVM) without running it with default parameters:

| Parameter | Value | 
|:---|:---|
| KERNEL_CONFIG | DUMBVM | 
| ACTION | build |
| CONF_TEMPLATE | sys161.conf.sample |

```bash
./build.sh
```

- Build a specific assignment configuration

| Parameter | Value | 
|:---|:---|
| KERNEL_CONFIG | ASST1 | 
| ACTION | build |
| CONF_TEMPLATE | sys161.conf.sample |
```bash
./build.sh -c ASST1
```

- Build the default kernel and run the emulator immediately

| Parameter | Value | 
|:---|:---|
| KERNEL_CONFIG | DUMBVM | 
| ACTION | run |
| CONF_TEMPLATE | sys161.conf.sample |
```bash
./build.sh -a run
```

- Build a specific assignment configuration templete

| Parameter | Value | 
|:---|:---|
| KERNEL_CONFIG | DUMBVM | 
| ACTION | build |
| CONF_TEMPLATE | sys161_temp2.conf.sample |
```bash
./build.sh -t sys161_temp2.conf.sample
```

- Everything can be mixed

| Parameter | Value | 
|:---|:---|
| KERNEL_CONFIG | ASST1 | 
| ACTION | run |
| CONF_TEMPLATE | sys161_temp2.conf.sample |

```bash
./build.sh -c ASST1 -a run -t sys161_temp2.conf.sample
```

---

# Utilities
### `sudo` access
In case you'll ever need it that's the sudo password on this version of the `os161` system:
```
~/os161$ sudo whoami
[sudo] password for os161user: root
```
to verify you are in sudo you can launch this command the result will determine if you gained access to `sudo` or not:
```
sudo id -> uid=0(root) gid=0(root) groups=0(root)
```
if password is asked you are not a superuser.

### How to change sudo password (only Docker based)
If you forgot, or simply do not know, your mighty sudo password you i got you but only if your `os161` is running in a Docker container.
At first you need to open an interactive shell inside the desired running container, as the root user.
```
docker exec -it -u root <container-id> bash
```
then we can change the password for our default `os161` user.
```
passwd os161user
```

---

# Project File Tree explained

From -> 📁 /home/os161user/os161/
```
├── .sockets/  
│   └── Temporary files used by the sys161 emulator (do not modify)

├── lab_docs/  
│   └── Lab documentation (PDFs with assignments)

├── root/   # 🖥️ Runtime environment (similar to Linux "/")
│   ├── .sockets/  
│   │   └── Sockets for debugging (gdb, meter)
│   │
│   ├── hostbin/  
│   │   └── Programs executed on the host machine
│   │
│   ├── hostinclude/  
│   │   └── Headers for host-side compilation
│   │
│   ├── include/  
│   │   └── Headers available to userland programs
│   │
│   ├── lib/  
│   │   └── Userland libraries
│   │
│   ├── man/  
│   │   └── HTML manuals (syscalls, libc, etc.)
│   │
│   ├── sbin/  
│   │   └── System programs (halt, reboot)
│   │
│   ├── testbin/  
│   │   └── Test programs to verify the kernel
│   │
│   ├── testscripts/  
│   │   └── Automated test scripts
│   │
│   ├── kernel / kernel-DUMBVM  
│   │   └── Compiled kernel (executable)
│   │
│   ├── LHD0.img, LHD1.img  
│   │   └── Virtual disks (filesystems)
│   │
│   └── sys161.conf  
│       └── Emulator configuration (RAM, CPU, disks)

├── src/   # 🔥 OS/161 source code
│
│   ├── common/  
│   │   └── Shared code (basic libc, standard functions)
│   │
│   ├── design/  
│   │   └── Conceptual system documentation
│   │
│   ├── kern/   # 🧠 CORE OF THE OPERATING SYSTEM
│   │
│   │   ├── arch/  
│   │   │   └── Architecture-dependent code (MIPS: traps, syscall entry, TLB)
│   │   │
│   │   ├── compile/  
│   │   │   └── Kernel build directories (e.g., DUMBVM)
│   │   │
│   │   ├── conf/  
│   │   │   └── Kernel configuration files (GENERIC, DUMBVM)
│   │   │
│   │   ├── dev/  
│   │   │   └── Device drivers (console, disk, timer)
│   │   │
│   │   ├── fs/  
│   │   │   └── Filesystem implementations (SFS, SEMFS)
│   │   │
│   │   ├── gdbscripts/  
│   │   │   └── Scripts for GDB debugging
│   │   │
│   │   ├── include/  
│   │   │   └── Internal kernel headers
│   │   │
│   │   ├── lib/  
│   │   │   └── Kernel utilities (arrays, bitmap, printf)
│   │   │
│   │   ├── main/  
│   │   │   └── Kernel entry point + command menu
│   │   │
│   │   ├── proc/  
│   │   │   └── Process management (LAB 2)
│   │   │
│   │   ├── syscall/  
│   │   │   └── System call implementation
│   │   │
│   │   ├── test/  
│   │   │   └── Internal kernel tests (threads, sync)
│   │   │
│   │   ├── thread/  
│   │   │   └── Threads + synchronization (LAB 1)
│   │   │
│   │   ├── vfs/  
│   │   │   └── Virtual File System (filesystem abstraction)
│   │   │
│   │   └── vm/  
│   │       └── Virtual memory (advanced lab)
│   │
│   ├── man/  
│   │   └── Manuals (source format)
│   │
│   ├── mk/  
│   │   └── Build system (makefile framework)
│   │
│   ├── testscripts/  
│   │   └── Automated test scripts
│   │
│   └── userland/   # 👤 User programs (run on top of the kernel)
│       ├── include/  
│       │   └── Userland headers
│       │
│       ├── lib/  
│       │   └── Libraries (printf, malloc, etc.)
│       │
│       ├── sbin/  
│       │   └── System programs (halt, reboot)
│       │
│       └── testbin/  
│           └── Test programs (fork, memory, file system)
```
