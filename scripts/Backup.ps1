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

if ($Packages -or $Aliases -or $RainmeterSkins) {
    if (Test-Path -Path $localTemp) {
        Remove-Item -Force -Recurse $localTemp
    }
    New-Item -Path $localTemp -ItemType "directory"
}


# Takes a list of locally installed chocolatey packages and stores them in a log file
if ($Packages) {
    clist -l -idonly -r | Out-File -Force -FilePath $localTemp\packages.log
    Write-Host "packages.log file created" -ForegroundColor Green
}

# Takes a list of all PowerShell aliases and stores them in a log file
if ($Aliases) {
    Get-Alias | ForEach-Object { "$($_.Name),$($_.Definition)" } | Out-File -FilePath $localTemp\aliases.log
    Write-Host "aliases.log file created" -ForegroundColor Green
}

# Makes a copy installed Rainmeter skins and settings 
if ($RainmeterSkins) {
    $rainmeterSkinsLocal = Join-Path -Path (Resolve-Path -Path "~\Documents") -ChildPath "Rainmeter"
    if (Test-Path $rainmeterSkinsLocal) {
        Copy-Item -Force -Recurse -Path $rainmeterSkinsLocal -Destination $localTemp
    }
    else {
        Write-Host "Rainmeter folder doesn't seem to exist?" -ForegroundColor Red
    }
}

# if any backups were made
if ($Packages -or $Aliases -or $RainmeterSkins) {
    $compress = @{
        Path             = ".\backup"
        CompressionLevel = "Fastest"
        DestinationPath  = "$($localTemp)\backup.zip"
    }
    Compress-Archive @compress
    Write-Host "Backup archive created" -ForegroundColor Green

    Copy-Item $localTemp\packages.log $tempDir -ErrorAction SilentlyContinue
    Copy-Item $localTemp\aliases.log $tempDir -ErrorAction SilentlyContinue
    Copy-Item -Force -Recurse -Path $rainmeterSkinsLocal -Destination $tempDir -ErrorAction SilentlyContinue
    Write-Host "`tLocal ($($tempDir)) copies created" -ForegroundColor Yellow
    Copy-Item -Force -Path $localTemp\backup.zip -Destination $consumerOneDrive
    Write-Host "`tOneDrive ($($consumerOneDrive)) copies created" -ForegroundColor Yellow

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