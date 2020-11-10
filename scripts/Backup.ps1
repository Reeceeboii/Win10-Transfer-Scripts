<#
    .SYNOPSIS
    Makes backups of instsalled chocolatey packages, PowerShell aliases and Rainmeter skins.

    .DESCRIPTION
    Sends the files to consumer OneDrive folder for retrieval on other machines, and to C:\Temp for local testing

    .PARAMETER packages
    Switch that is enabled if Chocolatey packages are to be backed up
    .PARAMETER aliases
    Switch that is enabled if PowerShell aliases are to be backed up
    .PARAMETER rainmeterSkins
    Switch that is enabled if Rainmeter skins and their settings are to be backed up
    .PARAMETER terminalConfig
    Switch that is enabled if the Windows Terminal config is to be backed up
    .PARAMETER clean
    Switch that is enabled if created backups are to be removed from C:\Temp and OneDrive
    .PARAMETER all
    Enables all other backup switches (causing a full backup)

    .INPUTS
    None.

    .OUTPUTS
    None

    .EXAMPLE
    PS> Backup.ps1 -packages -aliases -rainmeterSkins
    [backs up packages, aliases and Rainmeter skins]

    .EXAMPLE
    PS> Backup.ps1 -all
    [backs up everything]

    .EXAMPLE
    PS> Backup.ps1 -clean
    [Removes backup files from C:\Temp and OneDrive]
#>

param (
    [switch]$packages = $false,
    [switch]$aliases = $false,
    [switch]$rainmeterSkins = $false,
    [switch]$terminalConfig = $false,
    [switch]$all = $false,
    [switch]$clean = $false
)

$tempDir = "C:\Temp"
$localTemp = Join-Path -Path $PSScriptRoot -ChildPath "backup"
$consumerOneDrive = Join-Path -Path $env:OneDriveConsumer -ChildPath $backupDirName

# if a full backup is chosen, enable all other switches
if ($all) {
    Write-Host "Starting full backup..." -ForegroundColor Yellow
    $packages = $true
    $aliases = $true
    $rainmeterSkins = $true
    $terminalConfig = $true
}

# resolves the file path of the local Rainmeter folder
function Resolve-RainmeterSkinsPath {
    Join-Path -Path (Resolve-Path -Path "~\Documents") -ChildPath "Rainmeter"
}

# create local ./backup folder (remove if it already exists)
if ($packages -or $aliases -or $rainmeterSkins -or $terminalConfig) {
    if (Test-Path -Path $localTemp) {
        Remove-Item -Force -Recurse $localTemp
    }
    New-Item -Path $localTemp -ItemType "directory" | Out-Null # https://bit.ly/3lnQOE8
}


# Takes a list of locally installed chocolatey packages and stores them in a log file
if ($packages) {
    clist -l -idonly -r | Out-File -Force -FilePath $localTemp\packages.log
    Write-Host "packages.log file created" -ForegroundColor Yellow
}

# Takes a list of all PowerShell aliases and stores them in a log file
if ($aliases) {
    Get-Alias | ForEach-Object { "$($_.Name),$($_.Definition)" } | Out-File -FilePath $localTemp\aliases.log
    Write-Host "aliases.log file created" -ForegroundColor Yellow
}

# Makes a copy installed Rainmeter skins and settings 
if ($rainmeterSkins) {
    $localRainmeterSkins = Resolve-RainmeterSkinsPath
    if (Test-Path -Path $localRainmeterSkins) {
        Write-Host "Rainmeter skin copy created" -ForegroundColor Yellow
        Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $localTemp
    }
    else {
        Write-Host "Rainmeter folder doesn't seem to exist?" -ForegroundColor Red
    }
}

# Makes a copy of the Windows Terminal settings file
if ($terminalConfig) {
    $local = Resolve-Path $env:APPDATA\..\local\packages\Microsoft.WindowsTerminal_*\localstate
    Copy-Item -Path $local\settings.json -Destination $localTemp\settings.json
    Write-Host "Windows Terminal settings file backed up" -ForegroundColor Yellow
}

# if any backups were made
if ($packages -or $aliases -or $rainmeterSkins -or $terminalConfig) {
    $localRainmeterSkins = Resolve-RainmeterSkinsPath
    $compress = @{
        Path             = ".\backup"
        CompressionLevel = "Fastest"
        DestinationPath  = "$($localTemp)\backup.zip"
    }

    # compress local copies of files to a zip archive
    Compress-Archive @compress
    Write-Host "Backup archive created" -ForegroundColor Yellow

    # copy log files to C:\Temp
    Copy-Item -Path $localTemp\packages.log -Destination $tempDir -ErrorAction SilentlyContinue
    Copy-Item -Path $localTemp\aliases.log -Destination $tempDir -ErrorAction SilentlyContinue
    # copy Rainmeter skins to C:\Temp
    Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $tempDir -ErrorAction SilentlyContinue
    # copy Windows Terminal settings to C:\Temp
    Copy-Item -Path $localTemp\settings.json -Destination $tempDir -ErrorAction SilentlyContinue

    Write-Host "Local ($($tempDir)) copies created" -ForegroundColor Green
    
    # copy backup zip file to OneDrive
    Copy-Item -Force -Path $localTemp\backup.zip -Destination $consumerOneDrive
    Write-Host "OneDrive ($($consumerOneDrive)) copies created" -ForegroundColor Green

}

# Delete package and alias logs from local drive and OneDrive
if ($clean) {
    if (Test-Path $localTemp) {
        Remove-Item -Recurse -Force $localTemp
        Write-Host "Local backup temp files removed" -ForegroundColor Green
    }
    # OneDrive files
    Remove-Item $consumerOneDrive\backup.zip -ErrorAction SilentlyContinue
    Write-Host "OneDrive zip removed!" -ForegroundColor Green

    # Local copies
    Remove-Item $tempDir\packages.log -ErrorAction SilentlyContinue
    Remove-Item $tempDir\aliases.log -ErrorAction SilentlyContinue
    Write-Host "Local .log files have been cleaned!" -ForegroundColor Green
    Remove-Item $tempDir\settings.json -ErrorAction SilentlyContinue
    Write-Host "Local Windows Terminal settings have been cleaned!" -ForegroundColor Green
    Remove-Item -Recurse $tempDir\Rainmeter -ErrorAction SilentlyContinue
    Write-Host "Local Rainmeter backups have been cleaned!" -ForegroundColor Green
}