<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

# Import helper scripts
. $PSScriptRoot/HelperFunctions.ps1
. $PSScriptRoot/vars.ps1

Function GetEntropy{
    [CmdletBinding(DefaultParameterSetName = "Character")]
    param(
        # Password to check
        [Parameter(Mandatory)]
        [securestring]
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
       Write-Verbose "Word Permutations: $WordPermutations"

       # Cases

       $CasePermutations = [math]::Pow(2,$WordCount)
       Write-Verbose "Case Permutations: $CasePermutations"

       # Padding Characters

       $PaddingPermutations = ([math]::Pow($SymbolSetSize,($PrefixSymbolCount + $SuffixSymbolCount)))
       Write-Verbose "Padding Permutations: $PaddingPermutations"

       # Digits

       $DigitPermutations = [math]::Pow(10,($PrefixDigitCount + $SuffixDigitCount))
       Write-Verbose "Digit Permutations: $DigitPermutations"

       # Separator Character

       if ($SeparatorCharacterCount -eq 0) { $SeparatorCharacterCount ++}

       $SeparatorPermutations = $SeparatorCharacterCount
       Write-Verbose "Separator Permutations: $SeparatorPermutations"

       $SeenPermutations = $WordPermutations * $CasePermutations * $PaddingPermutations * $DigitPermutations * $SeparatorPermutations

       $SeenEntropy = [math]::round([math]::log($SeenPermutations,2))
        
    }

    # Unpack secure string to read password. If we are using Windows Powershell we need to use the BSTR method but this doesn't work on Linux
    # so for modern versions we use ConvertFrom-SecureString

    $PasswordPlain = SecureStringToPlainText -Password $Password


    if (StringContains -String $PasswordPlain -Characters $LowerCase){
        $CharacterSet += $LowerCase
    }
    if (StringContains -String $PasswordPlain -Characters $UpperCase){
        $CharacterSet += $UpperCase
    }
    if (StringContains -String $PasswordPlain -Characters $Numbers){
        $CharacterSet += $Numbers
    }
    if (StringContains -String $PasswordPlain -Characters $Symbols){
        $CharacterSet += $Symbols
    }

    $BlindPermutations = [math]::pow($CharacterSet.Length,$PasswordPlain.Length)

    $BlindEntropy = [math]::round([math]::log($BlindPermutations,2))

    # Remove plain password variable and garbage collect
    Remove-Variable -Name PasswordPlain
    [System.GC]::Collect()

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