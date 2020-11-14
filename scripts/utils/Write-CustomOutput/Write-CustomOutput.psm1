<#
    .SYNOPSIS
    A small wrapper around Write-Host that adds some colouring to the output depending on provided flags.
    If no flags are provided (-progress or -warning), the output is coloured green.

    .PARAMETER content
    The content that is to be displayed

    .PARAMETER progress
    If the output is to do with a process progressing. This outputs the text in yellow.

    .PARAMETER warning
    If the output is to warn of something. This outputs the text in red.
#>
function Write-CustomOutput {
    param (
        # the progression text to be send to the console
        [Parameter(Mandatory = $true)]
        [Object]
        $content,
        # whether or not the text is to do with progress or completion
        [switch]
        $progress,
        # if the output is a warning message
        [switch]
        $warning
    )

    if ($progress) {
        Write-Host $content -ForegroundColor Yellow
    }
    elseif ($warning) {
        Write-Host $content -ForegroundColor Red
    }
    else { 
        Write-Host $content -ForegroundColor Green 
    }
}