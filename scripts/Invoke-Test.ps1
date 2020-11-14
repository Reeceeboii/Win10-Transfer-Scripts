#Requires -RunAsAdministrator

Import-Module $PSScriptRoot\utils\Write-CustomOutput

$tempDir = "C:\Temp"

# Is the Windows Sandbox optional feature turned on?
function Get-WindowsSandboxEnabled {
    [bool](Get-WindowsOptionalFeature -Online | Where-Object FeatureName -eq Containers-DisposableClientVM).State
}

# Is windows sandbox enabled on this system?
if (Get-WindowsSandboxEnabled) {
    # run a full backup
    ./Backup-Data.ps1 -all
    # copy main script to temp directory
    Copy-Item ./Main.ps1 $tempDir
    Write-CustomOutput "Main script copied to $tempDir, opening VM..."
    Write-CustomOutput "At the PowerShell prompt: 'Set-ExecutionPolicy unrestricted -Scope CurrentUser -Force' before executing script" -progress
    # Make sure there's a file ext. association here dummy
    ./WindowsVMConfig.wsb
}
else {
    # Do I actually want to enable it?
    $resp = Read-Host -Prompt "Windows Sandbox is not enabled, would you like to enable? [Y/N]: "
    if ($resp.ToLower() -eq "y") {
        Write-CustomOutput "Attempting to enable Windows Sandbox..." -progress
        # Enable the 'Containers-DisposableClientVM' (sandbox) feature
        Enable-WindowsOptionalFeature -FeatureName Containers-DisposableClientVM -Online -NoRestart -ErrorAction Stop
    }
    else {
        Write-CustomOutput "Exiting..." -warning
    }
}