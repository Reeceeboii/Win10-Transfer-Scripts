# Win10-Transfer-Scripts

## Some PowerShell scripts to help me quickly get up and running on a fresh install of Windows 10.

## Why?

I like Windows machines set up in a particular way, and doing these monotonous changes and installing all my pieces of software manually each time is a bore. So let's automate it.

## So what do these scripts do?

- `Main.ps1`: main driver script - does all the heavy lifting.
- `Invoke-Test.ps1`: boots up a Windows Sandbox instance to test `Main.ps1` in an isolated environment
- `Backup-Data.ps1`: makes copies of and backs up files. Moves them to `C:\Temp` for the test script, also uploads them to OneDrive for access on the new systems.

## Features

✔️ Done 🔧 Under development

### On the old system

- **`Invoke-Test.ps1`**
  - ✔️ Using `Backup-Data.ps1` to create a backup
  - ✔️ Boot up a Windows Sandbox instance to test `Main.ps1` using the newly created backup
- **`Backup-Data.ps1`**
  - **Backups**
    - ✔️ All currently installed Chocolately packages
    - ✔️ All PowerShell command aliases
    - ✔️ Windows Terminal config file
    - ✔️ Home folder of the WSL filesystem
    - ✔️ Installed Rainmeter skins and their config files
    - 🔧 Currently saved Rainmeter layout
    - ✔️ Backing up the current layout of the Start menu
  - ✔️ Making an archive of all backed up data and uploading to OneDrive

### On the new system

- **`Main.ps1`**
  - **Installations**
    - ✔️ Installing chocolatey
    - ✔️ Using log file to reinstall all software
  - **Windows features and settings**
    - ✔️ Enabling Windows Sandbox as a Windows feature
    - ✔️ Enabling WSL as a Windows Feature
    - 🔧 Downloading and adding the Ubuntu WSL appx file from the web
    - ✔️ Enabling hidden file and folders' display in the registry
  - **Git & Development**
    - ✔️ Generate new set of SSH keys for auth with GitHub
    - ✔️ Set up global Git info like name/username
  - **Importing settings and data from backup**
    - ✔️ Importing PowerShell aliases
    - 🔧 Importing Rainmeter skins & settings
    - 🔧 Importing Windows Terminal config file
    - 🔧 Importing Start Menu layout
  - **Misc**
    - 🔧 Use [Windows-terminal-context-menu](https://github.com/kerol2r20/Windows-terminal-context-menu) to set up context menu entries for Windows Terminal

## Notes to self

- Running `Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force` before executing `Main.ps1` is required. Installing Chocolatey requires invoking a script from the web. Also, running the `profile.ps1` script that is created to contain all of the aliases requires unsigned script execution permission. Simply setting this to be unrestricted solves this.
- Not all of the software backed up in the log will want to be installed on a new system, so just scan through this and remove anything that isn't needed.

## After script has executed

- Upload new public SSH key to https://github.com/settings/keys
