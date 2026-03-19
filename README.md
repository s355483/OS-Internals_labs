# OS-Internals_labs
Repository for the laboratory part of the OS internals class (Politecnico di Torino LM-32 AI-Driven) held by Professor Giampiero Cabodi

---

# How to work (with VScode)
Click on the Manage button in the bottom left, then "Extensions" and ensure that you have the "Remote - Containers" extension installed. (You can also open the Extensions tab with <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>X</kbd> on macOS.)

With the container running,  use the shortcut <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> (or <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> if you are on macOS) to open the *Command Palette* and run the **Remote-Containers: Attach to Running Container...** command.

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

