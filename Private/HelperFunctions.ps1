<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>
Function StringContains {
    <#
    .SYNOPSIS
        Input 2 strings and return true if any of the characters in the second string appear in the first string
    .DESCRIPTION
        This function is used to check if any
    #>
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

    return $false

}

function GenerateCharString {
    [CmdletBinding()]
    param (
        # Number of characters
        [Parameter(Mandatory)]
        [int]
        $Length,
        
        # Character set to use
        [Parameter(Mandatory)]
        [string]
        $Charset
    )


    for ($i = 0; $i -lt $Length; $i ++){
        $output += $Charset[(Get-Random -Minimum 0 -Maximum $Charset.Length)]
    }

    return $output
}

function SecureStringToPlainText {
    <#
    .SYNOPSIS
        Convert secure string to plain text.
    #>
    [CmdletBinding()]
    param (
        # Password to convert
        [Parameter(Mandatory, ValueFromPipeline)]
        [SecureString]
        $Password
    )
    
    process {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        }
        else {
            return ConvertFrom-SecureString $Password -AsPlainText
        }
    }
    
}