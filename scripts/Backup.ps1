param (
    [switch]$packages = $false,
    [switch]$aliases = $false,
    [switch]$clean = $false
)

$temp_dir = "C:\Temp"

# Takes a list of locally installed chocolatey packages and stores them in a log file
if($packages){
    clist -l -idonly -r > packages.log
    # Upload packages.log to personal OneDrive folder and copy to C:\Temp
    Copy-Item ./packages.log $env:OneDriveConsumer
    Copy-Item ./packages.log $temp_dir
    echo "All packages backed up to package.log (C:\Temp & Personal OneDrive)"

}


# Takes a list of all PowerShell aliases and stores them in a log file
if($aliases){
    $alias_log = foreach($alias in Get-Alias){
        $name = $alias.Name
        $def = $alias.Definition
        echo "$name,$def"
    }
    $alias_log > .\aliases.log
    # Upload aliases.log to personal OneDrive folder and copy to C:\Temp
    Copy-Item ./aliases.log $env:OneDriveConsumer
    Copy-Item ./aliases.log $temp_dir
    echo "All aliases backed up to aliases.log (C:\Temp & Personal OneDrive)"
}


# Delete package and alias logs from local drive and OneDrive
if($clean){
    # OneDrive copies
    Remove-Item (Join-Path -Path $env:OneDriveConsumer -ChildPath packages.log)
    Remove-Item (Join-Path -Path $env:OneDriveConsumer -ChildPath aliases.log)
    echo "Uploaded OneDrive copies have been cleaned!"
    # Local copies
    Remove-Item "C:\Temp\packages.log"
    Remove-Item "C:\Temp\aliases.log"
    echo "Local copies have been cleaned!"
}