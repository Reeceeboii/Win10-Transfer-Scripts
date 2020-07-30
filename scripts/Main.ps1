#Requires -RunAsAdministrator


$script_start = Get-Date
echo "`nWelcome back Reece! - it's currently $script_start`nStarting...`n"


# INSTALLING CHOCOLATEY
echo "`tInstalling Chocolatey..."
echo "`tDownloading and running Chocolatey install script..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


# INSTALLING ALL PREVIOUSLY BACKED UP CHOCOLATEY PACKAGES
$choco_install_str = "choco install "
foreach ($line in Get-Content ./packages.log){
    $choco_install_str += $line + " "
}
$choco_install_str += "--ignore-checksums -y"
# Execute the install string
iex($choco_install_str)


# WINDOWS FEATURES
# We only want to do these if outside of the sandbox or it will just spew errors out
if(-not ($env:UserName -eq "WDAGUtilityAccount")) {
    echo "`tAttempting to enable Windows Sandbox..."
    # Enable the 'Containers-DisposableClientVM' (sandbox) feature
    Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -NoRestart -ErrorAction Stop
    echo "`tAttempting to enable WSL..."
    # Enable the 'Microsoft-Windows-Subsystem-Linux' (WSL) feature
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -ErrorAction Stop
}


# REGISTRY SETTINGS
Push-Location
Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
# Enable file extensions for known file types
Set-ItemProperty . HideFileExt "0"
# Show hidden files, folders and drives
Set-ItemProperty . Hidden "1" 
Pop-Location
# Apply file system changes by force restarting explorer.exe
Stop-Process -processName: Explorer -force


# Make `refreshenv` available right away, by defining the $env:ChocolateyInstall
# variable and importing the Chocolatey profile module.
# Note: Using `. $PROFILE` instead *may* work, but isn't guaranteed to.
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv


# GIT SETUP
# Commit details
$git_email = "reecemercer981@gmail.com"
echo "`tSetting up git config details..."
git config --global user.name "Reece Mercer"
git config --global user.email $git_email
# SSH keys
ssh-keygen -t rsa -b 4096 -C $git_email
echo "`tssh keys generated! - go to ~/.ssh"



# LOAD ALIASES
<#
What we do here is output an alias registration command for each alias, save it to a var and then
send that var to a file (profile.ps1). That file can then be sent directly to $PsHome so that all aliases are 
carried over across different sessions
#>
$profile_ps1 = foreach($alias_pair in Get-Content aliases.log){
    $name = $alias_pair.Split(",")[0]
    $mapped_to = $alias_pair.Split(",")[1]
    # If the alias doesn't already exist, register it
    echo "Set-Alias $name $mapped_to -ErrorAction SilentlyContinue"
}

# Write alias setups to profile.ps1 in the PowerShell home directory
$profile_ps1 > (Join-Path -Path $PsHome -ChildPath "profile.ps1")


$script_end = Get-Date
echo "`tScript took $(($script_end - $script_start).Minutes) minutes and $(($script_end - $script_start).Seconds) seconds!"


# CLEAN UP
rm ./Main.ps1
rm ./packages.log
rm ./aliases.log