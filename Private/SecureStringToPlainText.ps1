
<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

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