<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

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
$Wordlist = Get-Content $Dictionary

$OrganisedDictionary = @{}
($MinimumLength..$MaximumLength) | ForEach-Object{
    $OrganisedDictionary[$_] = (New-Object -Type System.Collections.ArrayList)
}

foreach ($Word in $Wordlist){
    if ($Word.Length -ge $MinimumLength -and $Word.Length -le $MaximumLength){
        $OrganisedDictionary[$Word.Length].Add($Word) | Out-Null
        $ImportedWords ++
    }
}

Write-Host "Imported $ImportedWords Words"

$OrganisedDictionary | Export-Clixml -Path words.xml

# this function will use a lot of memory, we make sure to clear the variables containing the dictionary and garbage collect
#Remove-Variable usableWords
Remove-Variable OrganisedDictionary
Remove-Variable WordList
[system.gc]::Collect()