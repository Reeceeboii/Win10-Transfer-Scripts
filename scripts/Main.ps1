#Requires -RunAsAdministrator

$script_start = Get-Date
echo "`nWelcome back Reece! - it's currently $script_start`nStarting...`n"

# INSTALLING CHOCOLATEY
echo "`tInstalling Chocolatey..."
echo "`tSetting required execution policy..."
set-ExecutionPolicy AllSigned
echo "`Downloading and running install.ps1..."
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# INSTALLING ALL PREVIOUSLY BACKED UP CHOCOLATEY PACKAGES
Get-Content .\packages.log