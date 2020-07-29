param (
    [switch]$choco = $false,
    [switch]$aliases = $false
)


# Takes a list of locally installed chocolatey packages and stores them in a log file
if($choco){
    clist -l -idonly -r > packages.log
    echo "All packages backed up to package.log"
}

if($aliases){
    $alias_log = foreach($alias in Get-Alias){
        $name = $alias.Name
        $def = $alias.Definition
        echo "$name->$def"
    }
    echo "All aliases backed up to aliases.log"
    $alias_log > .\aliases.log
}