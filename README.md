# Win10-Transfer-Scripts
## Some PowerShell scripts to help me quickly get up and running on a fresh install of Windows 10.

## Why?
I like Windows machines set up in a particular way, and doing these monotonous changes and installing all my pieces of software manually each time is a bore. So let's automate it.

## So what do these scripts do?

* `Main.ps1`: main driver script - does all the heavy lifting.
* `Test.ps1`: boots up a Windows Sandbox instance to test `Main.ps1` in an isolated environment
* `Backup.ps1`: creates backup files of Chocolatey packages and PowerShell aliases. Moves them to `C:\Temp` for the test script, also uploads them to OneDrive for access on other systems.

## Development progress
✔️ Done 🔧 Under development

### On the old system
* ✔️ Backing up currently installed Chocolately packages into a log file
* ✔️ Using a test script to boot up a Windows Sandbox instance to test the main script out safely away from my main machine in case things go boom (and also to test software installs that would obviously already exist on my main machine)
* ✔️ Making a log file of all existing PowerShell aliases

### On the new system
* ✔️ Installing chocolatey
* ✔️ Using log file to reinstall all software
* ✔️ Enabling Windows Sandbox as a Windows feature
* ✔️ Enabling WSL & installing Ubuntu
* ✔️ Changing registry settings for things like file extensions and hidden files, folders and drives
* ✔️ Generate new set of SSH keys for auth with GitHub
* ✔️ Set up global Git info like name/username
* 🔧 Take a running log of the entirety of `Main.ps1` as it's doing its stuff
* ✔️ Use a generated alias file from the old system to re-import all CLI aliases
* 🔧 Make sure PATH is set correctly for things like Python and Java

## Notes
Running `Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force` before executing `Main.ps1` is required. Installing Chocolatey requires `iex`ing a script from the web. Also, running the `profile.ps1` script that is created to contain all of the aliases also requires unsigned script executions permissions. Simply setting this to be unrestricted system-wide solves this. 