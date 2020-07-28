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



# Clean up
rm ./Main.ps1
rm ./packages.log