<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>
BeforeAll {
    $plaintextpassword = "abcdef"
    $securepassword = ConvertTo-SecureString -String $plaintextpassword -AsPlainText -Force
Mock New-Password {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $AsSecureString
    )
    if ($AsSecureString){
        $password = $securepassword
    }
    else {
        $password = $plaintextpassword
    }

    $response = [PSCustomObject]@{
        Password = $password
        BlindEntropy = 20
        SeenEntropy = 20
    }
    Write-Output $response
}
}


Describe -Name "Publish-Password" {

    It "Accepts String Password" {
        (Publish-Password -Password $plaintextpassword).Password | Should -Be $plaintextpassword
    }
    It "Accepts SecureString Password" {
        (Publish-Password -Password $securepassword).Password | Should -Be $plaintextpassword
    }
    It "Accepts String Fron Pipeline" {
        ($plaintextpassword | Publish-Password).Password | Should -Be $plaintextpassword
    }
    It "Accepts SecureStringFromPipeline" {
        ($securepassword | Publish-Password).Password | Should -Be $plaintextpassword
    }
    It "Accepts String Password From New-Password" {
        (New-Password | Publish-Password).Password | Should -Be $plaintextpassword
    }
    It "Accepts SecureString Password From New-Password" {
        (New-Password -AsSecureString | Publish-Password).Password | Should -Be $plaintextpassword
    }
    It "Warns when publishing a cleartext password" {
        {Publish-Password -Password $plaintextpassword -WarningAction Stop} | Should -Throw -ExpectedMessage "The running command stopped because the preference variable `"WarningPreference`" or common parameter is set to Stop: It is recommended to input the password as a secure string."
    }

    
}