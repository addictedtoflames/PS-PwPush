<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

Get-ChildItem $PSScriptRoot/Private/*.ps1 | ForEach-Object{
    . $_.FullName
}

Function StringContains {
    param (
        # String to validate
        [Parameter(Mandatory)]
        [string]
        $String,

        # Character set to look for in String
        [Parameter(Mandatory)]
        [string]
        $Characters
    )

    foreach ($Character in $Characters.ToCharArray()) {
        if ($String.IndexOf($Character) -ge 0){
            return $true
            break
        }
    }

}

Function Get-Entropy{
    [CmdletBinding(DefaultParameterSetName = "Character")]
    param(
        # Password to check
        [Parameter(Mandatory)]
        [string]
        $Password,

        # Is it a word password? Will return seen entropy as well as blind if true
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [switch]
        $Word,

        # Length of word list in use
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [int32]
        $WordlistLength,

        # Number of Words
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $WordCount,

        # Prefix Symbols
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $PrefixSymbolCount,

        # Suffix Symbols
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $SuffixSymbolCount,

        # Number of padding symbols to choose from
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $SymbolSetSize,

        # Number of prefix digits
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $PrefixDigitCount,

        # Number of suffix digits
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [byte]
        $SuffixDigitCount,

        # Number of separator symbols
        [Parameter(Mandatory, ParameterSetName= "Word")]
        [byte]
        $SeparatorCharacterCount
        
        )


    if ($PSCmdlet.ParameterSetName -eq "Word"){
       # Words
       $WordPermutations =  [math]::Pow($WordlistLength,$WordCount)
       Write-Debug "Word Permutations: $WordPermutations"

       # Cases

       $CasePermutations = [math]::Pow(2,$WordCount)
       Write-Debug "Case Permutations: $CasePermutations"

       # Padding Characters

       $PaddingPermutations = ([math]::Pow($SymbolSetSize,($PrefixSymbolCount + $SuffixSymbolCount)))
       Write-Debug "Padding Permutations: $PaddingPermutations"

       # Digits

       $DigitPermutations = [math]::Pow(10,($PrefixDigitCount + $SuffixDigitCount))
       Write-Debug "Digit Permutations: $DigitPermutations"

       # Separator Character

       if ($SeparatorCharacterCount -eq 0) { $SeparatorCharacterCount ++}

       $SeparatorPermutations = $SeparatorCharacterCount
       Write-Debug "Separator Permutations: $SeparatorPermutations"

       $SeenPermutations = $WordPermutations * $CasePermutations * $PaddingPermutations * $DigitPermutations * $SeparatorPermutations

       $SeenEntropy = [math]::round([math]::log2($SeenPermutations))


    }

    if (StringContains -String $Password -Characters $LowerCase){
        $CharacterSet += $LowerCase
    }
    if (StringContains -String $Password -Characters $UpperCase){
        $CharacterSet += $UpperCase
    }
    if (StringContains -String $Password -Characters $Numbers){
        $CharacterSet += $Numbers
    }
    if (StringContains -String $Password -Characters $Symbols){
        $CharacterSet += $Symbols
    }

    $BlindPermutations = [math]::pow($CharacterSet.Length,$Password.Length)

    $BlindEntropy = [math]::round([math]::log2($BlindPermutations))

    if (!($SeenEntropy)){
        # If not using a word format the seen entropy will be the same as blind entropy
        $SeenEntropy = $BlindEntropy
    }

    $TotalEntropy = [PSCustomObject]@{
        SeenEntropy = $SeenEntropy
        BlindEntropy = $BlindEntropy
    }

    Write-Output $TotalEntropy
    
}