<!--
 Copyright 2021 David Hollings. All rights reserved.
 Use of this source code is governed by a BSD-style
 license that can be found in the LICENSE file.
-->

# PS-PwUtils
Collection of tools for generating and sharing passwords using PowerShell

## New-Password

### SYNOPSIS
Generate a random password either using random words (XKCD format) or a random character string.
    
    
### SYNTAX
    New-Password [-Character] [-Length <Byte>] [-Characters <String>] [<CommonParameters>]
    
    New-Password -Word [-Words <Byte>] [-MinimumLength <Byte>] [-MaximumLength <Byte>] [-PrefixDigits <Int32>] [-SuffixDigits <Byte>] [-SeparatorCharacters <String>] [-PrefixSymbols <Byte>] [-SuffixSymbols <Byte>] [-PaddingSymbols <String>] [<CommonParameters>]
    
    
### DESCRIPTION
Generate a random password using user-specified parameters. Supports either a random string or a word list. While characters are faster to generate they may be harder to remember so are best suited to service accounts or other systems where they are less likely to be entered manually. By default Character mode uses all alphanumeric
characters and punctuation but can be customised.
Word formatted passwords support a custom number of words and optional padding digits at the beginning and end. Word case is randomised to increase entropy. There will not be an option to customise word case. The word list cannot be specified at the command line but new wordlists can be imported using the Organise-Wordlist.ps1 script
    

### PARAMETERS
`-Character [<SwitchParameter>]`
    The format to use, Character or Word.
        
`-Length <Byte>`
    Number of characters to use in character password.
        
`-Characters <String>`
    Character set to use when generating character passwords.
        
`-Word [<SwitchParameter>]`
    Generate a Word passphrase.
    
`-Words <Byte>`
    Number of words to use in Word password.
    
`-MinimumLength <Byte>`
    Minimum length of words to use in Word password.
    
`-MaximumLength <Byte>`
    Maximum length of words to use in password.
    
`-PrefixDigits <Int32>`
    Number of digits at beginning of password.
    
`-SuffixDigits <Byte>`
    Number of digits at end of password.
    
`-SeparatorCharacters <String>`
    String of digits to be used as separator character. One character in the string will be chosen at random.
    
`-PrefixSymbols <Byte>`
    Number of random symbols at beginning of password.
    
`-SuffixSymbols <Byte>`
    Number of random symbols at end of password.
    
`-PaddingSymbols <String>`
    Character set for padding symbols.

`-Count`
    Number of passwords to generate
    



## Publish-Password
This cmdlet provides a powershell frontend for Peter Giacomo Lombardo's excellent PwPush utility, allowing you to customise the number of days/views the password is available for and whether it can be deleted early by viewers

### SYNOPSIS
Generate PwPush link for a given password.
    
    
### SYNTAX
    Publish-Password [-Password] <String> [[-Days] <Int16>] [[-Views] <Int16>] [[-URI] <String>] [-DisableEarlyDeletion] [<CommonParameters>]
    
    
### DESCRIPTION
Generate a PwPush link with a cusomisable lifetime and copies it to the clipboard.
When multiple passwords are provided via pipeline input only the last is available on the clipboard.
    

### PARAMETERS
`-Password <String>`
    The password to be sent (Mandatory).
    
`-Days <Int16>`
    How long to make the password available for. Default: 7. Maximum: 90.
    
`-Views <Int16>`
    How many times the password can be viewed before the link is removed. Default: 5. Maximum 90.
    
`-URI <StriLength <Byte>`
    URI for PwPush API. Default: https://pwpush.com/p.json
    
`-DisableEarlyDeletion [<SwitchParameter>]`
    Prevent anyone accessing the link from deleting the password before the scheduled expiration.
        

    
### Example   

    PS>Publish-Password -Password password123 -Days 7 -Views 5 -DisableEarlyDeletion

    Password  : password123
    Days      : 7
    Views     : 5
    Deletable : False
    Link      : https://pwpush.com/p/f3vg6lry95gj6n9n

    This example creates a link for the password "password123", makes it available for 7 days or 5 views and prevents the user from deleting it early
    
    
### Example
    
    PS>New-Password -Character -Length 32 | Publish-Password -Views 10

    Password  : \t&#P$c`u~5Xgb9c`!V]w0,r>9O~nsA3
    Days      : 7
    Views     : 10
    Deletable : True
    Link      : https://pwpush.com/p/dd59wor2ipsnm7az

    This example generates a random string and pipes it to PwPush with a view count of 10


# Credit

Wordlist: http://www.mieliestronk.com/wordlist.html