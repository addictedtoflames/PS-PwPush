<#
.SYNOPSIS
    Imports wordlists and organise by length
.DESCRIPTION
    Wordlists must be organised to speed up processing, this script accepts a word list with one word per line and organises it as a PowerShell array ordered by length
.INPUTS
    None
.OUTPUTS
    None
#>
param (
# List of words to import (1 word per line)
[Parameter(Mandatory)]
[string]
$Dictionary,

# Minimum length of words to import
[Parameter()]
[int]
$MinimumLength = 4,

# Maximum lenth of words to import
[Parameter()]
[int]
$MaximumLength = 15

)
$wordlist = Get-Content $Dictionary


$usableWords = $wordlist | ForEach-Object {
    if ($_.Length -ge $MinimumLength -and $_.Length -le $MaximumLength){
        [pscustomobject]@{
            Word = $_
            Length = $_.Length
        }
    }
}

$usableWords  | Sort-Object -Property Length | Export-Clixml -Path $PSScriptRoot\words.xml

Write-Host "Imported $($usableWords.length) Words"

Remove-Variable usableWords

[system.gc]::Collect()