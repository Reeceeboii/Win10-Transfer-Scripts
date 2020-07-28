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
$choco_install_str = "choco install "
foreach ($line in Get-Content ./packages.log){
    $choco_install_str += $line + " "
}
$choco_install_str += "--ignore-checksums -y"
# Execute the install string
iex($choco_install_str)


# WINDOWS FEATURES
echo "Attempting to enable Windows Sandbox..."
# Enable the 'Containers-DisposableClientVM' (sandbox) feature
Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -NoRestart -ErrorAction Stop
echo "Attempting to enable WSL..."
# Enable the 'Microsoft-Windows-Subsystem-Linux' (WSL) feature
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -ErrorAction Stop


# REGISTRY SETTINGS
Push-Location
Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
# Enable file extensions for known file types
Set-ItemProperty . HideFileExt "0"
# Show hidden files, folders and drives
Set-ItemProperty . Hidden "1" 
Pop-Location


# CLEAN UP
rm ./Main.ps1
rm ./packages.log