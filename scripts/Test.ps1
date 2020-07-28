#Requires -RunAsAdministrator

# Is the Windows sandbox optional feature turned on?
function sandboxEnabled{
    [bool](Get-WindowsOptionalFeature -Online | Where-Object FeatureName -eq Containers-DisposableClientVM).State
}

# Is windows sandbox enabled on this system?
if(sandboxEnabled) {
    # Copy the contents of the main script to clipboard
    Get-Content ./Main.ps1 | clip
    ./ChocolateyBackup.ps1
    echo "Main script copied to clipboard and new log file generated, opening VM..."
    echo "At the PowerShell prompt: run 'Set-ExecutionPolicy RemoteSigned' then 'Get-Clipboard > x.ps1' and finally './x.ps1'"
    echo "Booting Windows Sandbox..."
    WindowsSandbox.exe
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