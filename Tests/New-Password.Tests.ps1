<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

Describe -Name "New-Password" {
    It "Static passwords return correct length" {
        $password = (New-Password -Length 25).Password
        $password.length | Should -Be 25
    }
    It "Blind entropy for 20 characters is 131" {
        # Just in case our random string is missing some character sets we set a predictable random seed
        Get-Random -SetSeed 1
        $password = New-Password -Length 20
        $password.BlindEntropy | Should -Be 131
    }
    It "For character passwords, blind entropy equals seen entropy" {
        $password = New-Password
        $password.BlindEntropy | Should -Be $password.SeenEntropy
    }
    It "Example words password is correct" {
        Get-Random -SetSeed 1
        $password = New-Password -Word
        $password.Password | Should -Be "PANAMA!swagger!NIBBLE!grudge"
    }
    It "Character password length is correct" {
        $password = New-Password -Character -Length 40
        $password.Password.Length | Should -Be 40
    }
}