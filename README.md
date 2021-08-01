### PS-PwUtils
Collection of tools for generating and sharing passwords using PowerShell

# Publish-Password
This cmdlet provides a powershell frontend for Peter Giacomo Lombardo's excellent PwPush utility, allowing you to customise the number of days/views the password is available for and whether it can be deleted early by viewers

# SYNOPSIS
    Generate PwPush link for a given password.
    
    
# SYNTAX
    `Publish-Password [-Password] <String> [[-Days] <Int16>] [[-Views] <Int16>] [[-URI] <String>] [-DisableEarlyDeletion] [<CommonParameters>]`
    
    
# DESCRIPTION
    Generate a PwPush link with a cusomisable lifetime and copies it to the clipboard.
    When multiple passwords are provided via pipeline input only the last is available on the clipboard.
    

# PARAMETERS
    -Password <String>
        The password to be sent (Mandatory).
        
    -Days <Int16>
        How long to make the password available for. Default: 7. Maximum: 90.
        
    -Views <Int16>
        How many times the password can be viewed before the link is removed. Default: 5. Maximum 90.
        
    -URI <String>
        URI for PwPush API. Default: https://pwpush.com/p.json
        
    -DisableEarlyDeletion [<SwitchParameter>]
        Prevent anyone accessing the link from deleting the password before the scheduled expiration.
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
# Example   

    `PS>Publish-Password -Password password123 -Days 7 -Views 5 -DisableEarlyDeletion`
    ```
    Password  : password123
    Days      : 7
    Views     : 5
    Deletable : False
    Link      : https://pwpush.com/p/f3vg6lry95gj6n9n
    ```
    This example creates a link for the password "password123", makes it available for 7 days or 5 views and prevents the user from deleting it early
    
    
    
    
# Example
    
    `PS>New-Password -Character -Length 32 | Publish-Password -Views 10`
    ```
    Password  : \t&#P$c`u~5Xgb9c`!V]w0,r>9O~nsA3
    Days      : 7
    Views     : 10
    Deletable : True
    Link      : https://pwpush.com/p/dd59wor2ipsnm7az
    ```
    This example generates a random string and pipes it to PwPush with a view count of 10


# Credit

Wordlist: http://www.mieliestronk.com/wordlist.html