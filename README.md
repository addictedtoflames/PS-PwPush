<!--
 Copyright 2021 David Hollings. All rights reserved.
 Use of this source code is governed by a BSD-style
 license that can be found in the LICENSE file.
-->

# PS-PwUtils
Collection of tools for generating and sharing passwords using PowerShell

## Installing

To install, simply clone the repository to a folder in your PowerShell module path. You can view this path in the `$env:PSModulePath` variable.
```
Set-Location $env:USERPEOFILE\Documents\WindowsPowerShell\Modules
git clone https://github.com/davidshomelab/PS-PwUtils
```

## New-Password

### SYNOPSIS
Generate a random password either using random words (XKCD format) or a random character string.
    
    
### SYNTAX
    New-Password [-Character] [-Length <int>] [-Characters <String>] [<CommonParameters>]
    
    New-Password -Word [-Words <int>] [-MinimumLength <int>] [-MaximumLength <int>] [-PrefixDigits <Int32>] [-SuffixDigits <int>] [-SeparatorCharacters <String>] [-PrefixSymbols <int>] [-SuffixSymbols <int>] [-PaddingSymbols <String>] [<CommonParameters>]
    
    
### DESCRIPTION
Generate a random password using user-specified parameters. Supports either a random string or a word list. While characters are faster to generate they may be harder to remember so are best suited to service accounts or other systems where they are less likely to be entered manually. By default Character mode uses all alphanumeric
characters and punctuation but can be customised.
Word formatted passwords support a custom number of words and optional padding digits at the beginning and end. Word case is randomised to increase entropy. There will not be an option to customise word case. The word list cannot be specified at the command line but new wordlists can be imported using the Import-PSPWUtilsWordList script

### Updating the word list
A default word list is provided with the module but custom word lists can be used if desired. Word lists should be provided in plain text with one word per line.

    Import-PSPwUtilsWordList [-Dictionary] <String> [[-MinimumLength] <Int32>] [[-MaximumLength] <Int32>]

Updating the word list will completely replace the existing wordlist instead of appending to it. If you wish to back up the existing word list before replacing it, you can find it in `words.xml` in the module install directory.

If not specified, the minimum and maximum length properties are set as 4 and 15 respectively. Words outside these ranges will not be imported in to the wordlist as they are unlikely to ever be used in a password so will just unnecessarily increase the file size.

## Publish-Password
This cmdlet provides a powershell frontend for Peter Giacomo Lombardo's excellent PwPush utility, allowing you to customise the number of days/views the password is available for and whether it can be deleted early by viewers

### SYNOPSIS
Generate PwPush link for a given password.
    
    
### SYNTAX
    Publish-Password [-Password] <String> [[-Days] <Int16>] [[-Views] <Int16>] [[-URI] <String>] [-DisableEarlyDeletion] [<CommonParameters>]
    
    
### DESCRIPTION
Generate a PwPush link with a cusomisable lifetime and copies it to the clipboard.
When multiple passwords are provided via pipeline input only the last is available on the clipboard.
    
# More information

To keep the README short, only a summary of the available commands is given. All commands have additional help documentation which can be accessed via the `Get-Help` cmdlet. This help contains a full explanation of all command parameters and several examples.

# Credit

Wordlist: http://www.mieliestronk.com/wordlist.html