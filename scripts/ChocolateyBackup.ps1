# Takes a list of locally installed chocolatey packages and stores them in a log file
clist -l -idonly -r > packages.log
$lines = Get-Content .\packages.log | Measure-Object -Line
echo "Packages backed up to package.log: $($lines.Lines)"