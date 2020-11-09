<#
    .SYNOPSIS
    Makes backups of instsalled chocolatey packages, PowerShell aliases and Rainmeter skins.

    .DESCRIPTION
    Sends the files to consumer OneDrive folder for retrieval on other machines, and to C:\Temp for local testing

    .PARAMETER Packages
    Switch that is enabled if Chocolatey packages are to be backed up

    .PARAMETER Aliases
    Switch that is enabled if PowerShell aliases are to be backed up

    .PARAMETER RainmeterSkins
    Switch that is enabled if Rainmeter skins are to be backed up

    .PARAMETER Clean
    Switch that is enabled if created backups are to be removed from C:\Temp and OneDrive

    .INPUTS
    None.

    .OUTPUTS
    None

    .EXAMPLE
    PS> Backup.ps1 -Packages -Aliases -RainmeterSkins
    [backs up packages, aliases and Rainmeter skins]

    .EXAMPLE
    PS> Backup.ps1 -Clean
    [Removes backup files from C:\Temp and OneDrive]
#>

param (
    [switch]$Packages = $false,
    [switch]$Aliases = $false,
    [switch]$RainmeterSkins = $false,
    [switch]$Clean = $false
)

$tempDir = "C:\Temp"
$backupDirName = "WIN10TSBACKUPS"
$consumerOneDrive = Join-Path -Path $env:OneDriveConsumer -ChildPath $backupDirName


# Takes a list of locally installed chocolatey packages and stores them in a log file
if ($Packages) {
    if (-not (Test-Path -Path $consumerOneDrive)) {
        New-Item -Path $env:OneDriveConsumer -Name $backupDirName -ItemType "directory"
        Write-Host "Created OneDrive backup folder" -ForegroundColor Green
    }
    clist -l -idonly -r | Out-File -FilePath ./packages.log
    Write-Host "packages.log file created" -ForegroundColor Green
    # Upload packages.log to personal OneDrive folder and copy to C:\Temp
    Copy-Item ./packages.log $consumerOneDrive
    Copy-Item ./packages.log $tempDir
    Remove-Item ./packages.log
    Write-Host "All packages backed up to package.log (C:\Temp & Personal OneDrive backup folder)" -ForegroundColor Green
}


# Takes a list of all PowerShell aliases and stores them in a log file
if ($Aliases) {
    Get-Alias | ForEach-Object { "$($_.Name),$($_.Definition)" } | Out-File -FilePath ./aliases.log
    Write-Host "aliases.log file created" -ForegroundColor Green
    # Upload aliases.log to personal OneDrive folder and copy to C:\Temp
    Copy-Item ./aliases.log $consumerOneDrive
    Copy-Item ./aliases.log $tempDir
    Remove-Item ./aliases.log
    Write-Host "All aliases backed up to aliases.log (C:\Temp & Personal OneDrive backup folder)" -ForegroundColor Green
}


# Delete package and alias logs from local drive and OneDrive
if ($Clean) {
    # OneDrive copies
    if (Test-Path -Path $consumerOneDrive) {
        Remove-Item $consumerOneDrive\*
        Write-Host "Uploaded OneDrive files have been cleaned!" -ForegroundColor Green
    }
    # Local copies
    Remove-Item $tempDir\packages.log -ErrorAction SilentlyContinue
    Remove-Item $tempDir\aliases.log -ErrorAction SilentlyContinue
    Write-Host "Local .log files have been cleaned!" -ForegroundColor Green
}