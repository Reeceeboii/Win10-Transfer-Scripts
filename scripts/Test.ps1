#Requires -RunAsAdministrator

$temp_dir = "C:\Temp"

# Is the Windows sandbox optional feature turned on?
function sandboxEnabled {
    [bool](Get-WindowsOptionalFeature -Online | Where-Object FeatureName -eq Containers-DisposableClientVM).State
}


# Is windows sandbox enabled on this system?
if (sandboxEnabled) {
    # Generate and copy the packages & aliases log to C:\Temp
    ./Backup.ps1 -Packages -Aliases
    Copy-Item ./packages.log $temp_dir
    Copy-Item ./aliases.log $temp_dir
    # And the same for the main script
    Copy-Item ./Main.ps1 $temp_dir
    Write-Host "Main script and package log generated and copied to $temp_dir, opening VM..."
    Write-Host "At the PowerShell prompt: 'Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force' before executing script"
    # Make sure there's a file ext. association here dummy
    ./WindowsVMConfig.wsb
}
else {
    # Do I actually want to enable it?
    $resp = Read-Host -Prompt "Windows Sandbox is not enabled, would you like to enable? [Y/N]: "
    if ($resp.ToLower() -eq "y") {
        Write-Host "Attempting to enable Windows Sandbox..."
        # Enable the 'Containers-DisposableClientVM' (sandbox) feature
        Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -NoRestart -ErrorAction Stop
    }
    else {
        Write-Host "Exiting..."
    }
}