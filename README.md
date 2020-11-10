# Win10-Transfer-Scripts

## Some PowerShell scripts to help me quickly get up and running on a fresh install of Windows 10.

## Why?

I like Windows machines set up in a particular way, and doing these monotonous changes and installing all my pieces of software manually each time is a bore. So let's automate it.

## So what do these scripts do?

- `Main.ps1`: main driver script - does all the heavy lifting.
- `Test.ps1`: boots up a Windows Sandbox instance to test `Main.ps1` in an isolated environment
- `Backup.ps1`: makes copies of and backs up files. Moves them to `C:\Temp` for the test script, also uploads them to OneDrive for access on other systems.

## Features

✔️ Done 🔧 Under development

### On the old system

- **`Test.ps1`**
  - ✔️ Being able to boot up a Windows Sandbox instance to test the Main.ps1
- **`Backup.ps1`**
  - ✔️ Backing up currently installed Chocolately packages into a log file
  - ✔️ Backing up all PowerShell command aliases into a log file
  - ✔️ Backing up the Windows Terminal config file
  - ✔️ Backing up installed Rainmeter skins and their config files
  - ✔️ Making an archive of all backed up data and uploading to OneDrive

### On the new system

- **`Main.ps1`**
  - ✔️ Installing chocolatey
  - ✔️ Using log file to reinstall all software
  - ✔️ Enabling Windows Sandbox as a Windows feature
  - ✔️ Enabling WSL & installing Ubuntu
  - ✔️ Changing Windows Registry settings for things like file extensions and hidden files, folders and drives
  - ✔️ Generate new set of SSH keys for auth with GitHub
  - ✔️ Set up global Git info like name/username
  - ✔️ Use a generated alias file from the old system to re-import all CLI aliases

## Notes to self

- Running `Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force` before executing `Main.ps1` is required. Installing Chocolatey requires invoking a script from the web. Also, running the `profile.ps1` script that is created to contain all of the aliases requires unsigned script execution permission. Simply setting this to be unrestricted solves this.
- Not all of the software backed up in the log will want to be installed on a new system, so just scan through this and remove anything that isn't needed.

## After script has executed

- Upload new public SSH key to https://github.com/settings/keys
