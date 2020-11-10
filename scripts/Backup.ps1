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
    Switch that is enabled if Rainmeter skins and their settings are to be backed up

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
$localTemp = Join-Path -Path $PSScriptRoot -ChildPath "backup"
$consumerOneDrive = Join-Path -Path $env:OneDriveConsumer -ChildPath $backupDirName



function Resolve-RainmeterSkinsPath {
    Join-Path -Path (Resolve-Path -Path "~\Documents") -ChildPath "Rainmeter"
}

if ($Packages -or $Aliases -or $RainmeterSkins) {
    if (Test-Path -Path $localTemp) {
        Remove-Item -Force -Recurse $localTemp
    }
    New-Item -Path $localTemp -ItemType "directory" | Out-Null # https://bit.ly/3lnQOE8
}


# Takes a list of locally installed chocolatey packages and stores them in a log file
if ($Packages) {
    clist -l -idonly -r | Out-File -Force -FilePath $localTemp\packages.log
    Write-Host "packages.log file created" -ForegroundColor Yellow
}

# Takes a list of all PowerShell aliases and stores them in a log file
if ($Aliases) {
    Get-Alias | ForEach-Object { "$($_.Name),$($_.Definition)" } | Out-File -FilePath $localTemp\aliases.log
    Write-Host "aliases.log file created" -ForegroundColor Yellow
}

# Makes a copy installed Rainmeter skins and settings 
if ($RainmeterSkins) {
    $localRainmeterSkins = Resolve-RainmeterSkinsPath
    if (Test-Path -Path $localRainmeterSkins) {
        Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $localTemp
    }
    else {
        Write-Host "Rainmeter folder doesn't seem to exist?" -ForegroundColor Red
    }
}

# if any backups were made
if ($Packages -or $Aliases -or $RainmeterSkins) {
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
    Copy-Item $localTemp\packages.log $tempDir -ErrorAction SilentlyContinue
    Copy-Item $localTemp\aliases.log $tempDir -ErrorAction SilentlyContinue
    # copy Rainmeter skins to C:\Temp
    Copy-Item -Force -Recurse -Path $localRainmeterSkins -Destination $tempDir -ErrorAction SilentlyContinue
    Write-Host "Local ($($tempDir)) copies created" -ForegroundColor Green
    
    # copy backup zip file to OneDrive
    Copy-Item -Force -Path $localTemp\backup.zip -Destination $consumerOneDrive
    Write-Host "OneDrive ($($consumerOneDrive)) copies created" -ForegroundColor Green

}

# Delete package and alias logs from local drive and OneDrive
if ($Clean) {
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
    Remove-Item -Recurse $tempDir\Rainmeter -ErrorAction SilentlyContinue
    Write-Host "Local Rainmeter backups have been cleaned!" -ForegroundColor Green
}