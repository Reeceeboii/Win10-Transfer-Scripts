#Requires -RunAsAdministrator

$temp_dir = "C:\Temp"

# Is the Windows sandbox optional feature turned on?
function sandboxEnabled{
    [bool](Get-WindowsOptionalFeature -Online | Where-Object FeatureName -eq Containers-DisposableClientVM).State
}

# Is windows sandbox enabled on this system?
if(sandboxEnabled) {
    # Generate and copy the packages log to C:\Temp
    ./ChocolateyBackup.ps1
    Copy-Item ./packages.log $temp_dir
    # And the same for the main script
    Copy-Item ./Main.ps1 $temp_dir
    echo "Main script and package log generated and copied to $temp_dir, opening VM..."
    echo "At the PowerShell prompt: run './Main.ps1'"
    # Make sure there's a file ext. association here dummy
    ./WindowsVMConfig.wsb
} else {
    # Do I actually want to enable it?
    $resp = Read-Host -Prompt "Windows Sandbox is not enabled, would you like to enable? [Y/N]: "
    if($resp.ToLower() -eq "y") {
        echo "Attempting to enable Windows Sandbox..."
        # Enable the 'Containers-DisposableClientVM' (sandbox) feature
        Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -NoRestart -ErrorAction Stop
    } else {
        echo "Exiting..."
    }
}