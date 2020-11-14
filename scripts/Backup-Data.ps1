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
    .PARAMETER wslHome
    Switch that is enabled if the WSL home folder is to be backed up
    .PARAMETER startLayout
    Switch that is enabled if the start menu layout is to be backed up
    .PARAMETER clean
    Switch that is enabled if created backups are to be removed from C:\Temp and OneDrive
    .PARAMETER all
    Enables all other backup switches (causing a full backup)

    .INPUTS
    None.

    .OUTPUTS
    None

    .EXAMPLE
    PS> Backup-Data -packages -aliases -rainmeterSkins
    [backs up packages, aliases and Rainmeter skins]

    .EXAMPLE
    PS> Backup-Data -all
    [backs up everything]

    .EXAMPLE
    PS> Backup-Data -clean
    [Removes backup files from C:\Temp and OneDrive]
#>

param (
    [switch]$packages = $false,
    [switch]$aliases = $false,
    [switch]$rainmeterSkins = $false,
    [switch]$terminalConfig = $false,
    [switch]$wslHome = $false,
    [switch]$startLayout = $false,
    [switch]$all = $false,
    [switch]$clean = $false
)

Import-Module $PSScriptRoot\utils\Write-CustomOutput

$tempDir = "C:\Temp"
$localTemp = Join-Path -Path $PSScriptRoot -ChildPath "backup"
$consumerOneDrive = Join-Path -Path $env:OneDriveConsumer -ChildPath $backupDirName
$backupSwitchNames = "packages", "aliases", "rainmeterSkins", "terminalConfig", "wslHome", "startLayout"

# resolves the file path of the local Rainmeter folder
function Resolve-RainmeterSkinsPath {
    Join-Path -Path (Resolve-Path -Path "~\Documents") -ChildPath "Rainmeter"
}

function Get-AnyBackupsEnabled {
    foreach ($name in $backupSwitchNames) {
        if ((Get-Variable -Name $name).Value) {
            return $true
        }
    }
    return $false
}

# if a full backup is chosen, enable all other switches
if ($all) {
    Write-CustomOutput "Starting full backup..." -progress
    $backupSwitchNames | ForEach-Object {
        Set-Variable -Name $_ -Value $true
    }

}

# create local ./backup folder (remove if it already exists)
if (Get-AnyBackupsEnabled) {
    if (Test-Path -Path $localTemp) {
        Remove-Item -Force -Recurse $localTemp
    }
    New-Item -Path $localTemp -ItemType "directory" | Out-Null # https://bit.ly/3lnQOE8
}

# Takes a list of locally installed chocolatey packages and stores them in a log file
if ($packages) {
    clist -l -idonly -r | Out-File -Force -FilePath $localTemp\packages.log
    Write-CustomOutput "packages.log file created" -progress
}

# Takes a list of all PowerShell aliases and stores them in a log file
if ($aliases) {
    Get-Alias | ForEach-Object { "$($_.Name),$($_.Definition)" } | Out-File -FilePath $localTemp\aliases.log
    Write-CustomOutput "aliases.log file created" -progress
}

# Makes a copy installed Rainmeter skins and settings 
if ($rainmeterSkins) {
    $localRainmeterSkins = Resolve-RainmeterSkinsPath
    if (Test-Path -Path $localRainmeterSkins) {
        Write-CustomOutput "Rainmeter skin copy created" -progress
        Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $localTemp
    }
    else {
        Write-CustomOutput "Rainmeter folder doesn't seem to exist?" -warning
    }
}

# Makes a copy of the Windows Terminal settings file
if ($terminalConfig) {
    $local = Resolve-Path $env:APPDATA\..\local\packages\Microsoft.WindowsTerminal_*\localstate
    Copy-Item -Path $local\settings.json -Destination $localTemp\settings.json
    Write-CustomOutput "Windows Terminal settings file backed up" -progress
}

# Makes a copy of the home folder of the WSL distro I have installed (ubuntu-xx.xx)
if ($wslHome) {
    try {
        Copy-Item -Recurse -Path "\\wsl$\Ubuntu-20.04\home\reece" -Destination $localTemp\wslHome
        Write-CustomOutput "WSL home directory backed up!" -progress
    }
    catch {
        Write-CustomOutput "WSL doesn't seem to be accessible. Maybe it isn't running?" -warning
    }
}

# Creates a backup of the current start menu layout
if ($startLayout) {
    Export-StartLayout -Path $localTemp\StartLayout.xml
    Write-CustomOutput "Start menu layout XML file created!" -progress
}

# if any backups were made
if (Get-AnyBackupsEnabled) {
    $localRainmeterSkins = Resolve-RainmeterSkinsPath
    $compress = @{
        Path             = ".\backup"
        CompressionLevel = "Fastest"
        DestinationPath  = "$($localTemp)\backup.zip"
    }

    # compress local copies of files to a zip archive
    Compress-Archive @compress
    Write-CustomOutput "Backup archive created" -progress

    # copy local copies to C:\Temp

    # log files
    Copy-Item -Path $localTemp\packages.log -Destination $tempDir -ErrorAction SilentlyContinue
    Copy-Item -Path $localTemp\aliases.log -Destination $tempDir -ErrorAction SilentlyContinue
    # Rainmeter skins
    Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $tempDir\Rainmeter -ErrorAction SilentlyContinue
    # Windows Terminal settings
    Copy-Item -Path $localTemp\settings.json -Destination $tempDir -ErrorAction SilentlyContinue
    # start menu layout
    Copy-Item -Path $localTemp\StartLayout.xml -Destination $tempDir -ErrorAction SilentlyContinue

    # we don't need to copy WSL stuff to local test directory as testing Windows Features within WinSandbox is not possible

    Write-CustomOutput "Local ($($tempDir)) copies created"
    
    # copy backup zip file to OneDrive
    Copy-Item -Force -Path $localTemp\backup.zip -Destination $consumerOneDrive
    Write-CustomOutput "OneDrive ($($consumerOneDrive)) copies created"

}

# Delete package and alias logs from local drive and OneDrive
if ($clean) {
    if (Test-Path $localTemp) {
        Remove-Item -Recurse -Force $localTemp
        Write-CustomOutput "Local backup temp files removed"
    }
    # OneDrive files
    Remove-Item $consumerOneDrive\backup.zip -ErrorAction SilentlyContinue
    Write-CustomOutput "OneDrive zip removed!"

    # Local copies
    
    # logs
    Remove-Item $tempDir\packages.log -ErrorAction SilentlyContinue
    Remove-Item $tempDir\aliases.log -ErrorAction SilentlyContinue
    Write-CustomOutput "Local .log files have been cleaned!"
    # terminal config
    Remove-Item $tempDir\settings.json -ErrorAction SilentlyContinue
    Write-CustomOutput "Local Windows Terminal settings have been cleaned!"
    # Rainmeter skins
    Remove-Item -Recurse $tempDir\Rainmeter -ErrorAction SilentlyContinue
    Write-CustomOutput "Local Rainmeter backups have been cleaned!"
    # start menu layout
    Remove-Item $tempDir\StartLayout.xml -ErrorAction SilentlyContinue
    Write-CustomOutput "Local Start Menu backup file has been cleaned!"
}