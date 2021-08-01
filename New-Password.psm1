$LowerCase = "abcdefghijklmnopqrstuvwxyz"
$UpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$Numbers = "0123456789"
$Symbols = "!`"$%^&*()-_=+{}[];'#:@~,./<>?\|``'"
Function New-Password {
    <#
    .SYNOPSIS
        Generate a random password either using random words (XKCD format) or a random character string.
    .DESCRIPTION
        Generate a random password using user-specified parameters. Supports either a random string or a word list.
        While characters are faster to generate they may be harder to remember so are best suited to service accounts
        or other systems where they are less likely to be entered manually. By default Character mode uses all alphanumeric
        characters and punctuation but can be customised.
        Word formatted passwords support a custom number of words and optional padding digits at the beginning and end. Word
        case is randomised to increase entropy. There will not be an option to customise word case.
        The word list cannot be specified at the command line but new wordlists can be imported using the Organise-Wordlist.ps1 script
    .INPUTS
        None
    .OUTPUTS
        System.String
    #>
    [CmdletBinding(DefaultParameterSetName = "Character")]
    param(
        #The format to use, Character or Word.
        [Parameter(ParameterSetName = "Character")]
        [switch]
        $Character,

        #Number of characters to use in character password.
        [Parameter(ParameterSetName = "Character")]
        [ValidateRange(4, 255)]
        [byte]
        $Length = 20,

        #Character set to use when generating character passwords.
        [Parameter(ParameterSetName = "Character")]
        [string]
        $Characters = $LowerCase + $UpperCase + $Numbers + $Symbols,

        # Generate a Word passphrase.
        [Parameter(Mandatory, ParameterSetName = "Word")]
        [switch]
        $Word,

        #Number of words to use in Word password.
        [Parameter(ParameterSetName = "Word")]
        [byte]
        $Words = 4,

        #Minimum length of words to use in Word password.
        [Parameter(ParameterSetName = "Word")]
        [ValidateRange(4, 15)]
        [byte]
        $MinimumLength = 4,

        #Maximum length of words to use in password.
        [Parameter(ParameterSetName = "Word")]
        [ValidateScript( {
                $_ -ge $MinimumLength -and $_ -le 15
            })]
        [byte]
        $MaximumLength = 8,

        # Number of digits at beginning of password.
        [Parameter(ParameterSetName = "Word")]
        [int]
        $PrefixDigits = 0,

        # Number of digits at end of password.
        [Parameter(ParameterSetName = "Word")]
        [byte]
        $SuffixDigits = 0,
        
        # String of digits to be used as separator character. One character in the string will be chosen at random.
        [Parameter(ParameterSetName = "Word")]
        [string]
        $SeparatorCharacters = $Symbols,

        # Number of random symbols at beginning of password.
        [Parameter(ParameterSetName = "Word")]
        [byte]
        $PrefixSymbols = 0,

        # Number of random symbols at end of password.
        [Parameter(ParameterSetName = "Word")]
        [byte]
        $SuffixSymbols = 0,

        # Character set for padding symbols
        [Parameter(ParameterSetName = "Word")]
        [string]
        $PaddingSymbols = $Symbols,

        # How many passwords to generate
        [Parameter()]
        [byte]
        $Count = 1
    )

    if ($PSCmdlet.ParameterSetName -eq "Word") {
        # Import WordList. In the event that count is greater than 1 and we want a Words type password,
        # we import the dictionary outside the loop as it only needs to be done once
        $Wordlist = Import-Clixml $PSScriptRoot\words.xml
        $AvailableWords = New-Object -TypeName System.Collections.ArrayList
        ($MinimumLength..$MaximumLength) | ForEach-Object {
            $AvailableWords += $Wordlist[$_]
        }
    }
    (1..$Count) | ForEach-Object {
        if ($PSCmdlet.ParameterSetName -eq "Character") {
            $CharacterCount = $Characters.Length
            $Password = ""
            (1..$Length) | ForEach-Object {
                $Random = Get-Random -Minimum 0 -Maximum $CharacterCount
                $SelectedCharacter = $Characters[$Random]
                $Password += $SelectedCharacter
            }
            Write-Output $Password
        }


        else {

            # Initialise array to contain password components
            [string[]]$PasswordWords = @()

            # Generate prefix symbols
            if ($PrefixSymbols -gt 0) {
                $PrefixSymbolCharacters
                (1..$PrefixSymbols) | ForEach-Object {
                    $PrefixSymbolCharacters += $Symbols[(Get-Random -Minimum 0 -Maximum $Symbols.Length)]
                }
                $PasswordWords += $PrefixSymbolCharacters
            }

            # Generate prefix digits
            if ($PrefixDigits -gt 0) {
                $PrefixDigitValue = [int](Get-Random -Maximum ([Math]::Pow(10, $PrefixDigits)))
                $PasswordWords += "{0:d$PrefixDigits}" -f $PrefixDigitValue # Formatting string ensures leading zeros are preserved
            }

            # Generate $Words random words and add them to oputput array. Word case is decided randomly
            (1..$Words) | ForEach-Object {
                [system.gc]::Collect()
                $Random = Get-Random -Minimum 0 -Maximum $AvailableWords.Length
                $SelectedWord = $AvailableWords[$Random]
                if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
                    $SelectedWord = $SelectedWord.ToUpper()
                }
                $PasswordWords += $SelectedWord
            }

            # Generate suffix digits
            if ($SuffixDigits -gt 0) {
                $SuffixDigitValue = [int](Get-Random -Maximum ([Math]::Pow(10, $SuffixDigits)))
                $PasswordWords += "{0:d$SuffixDigits}" -f $SuffixDigitValue # Formatting string ensures leading zeros are preserved
            }

            # Generate suffix symbols
            if ($SuffixSymbols -gt 0) {
                $SuffixSymbolCharacters
                (1..$SuffixSymbols) | ForEach-Object {
                    $SuffixSymbolCharacters += $Symbols[(Get-Random -Minimum 0 -Maximum $Symbols.Length)]
                }
                $PasswordWords += $SuffixSymbolCharacters
            }

            # Choose separator character
            if ($SeparatorCharacters.Length -gt 1) {
                $SeparatorIndex = Get-Random -Minimum 0 -Maximum ($SeparatorCharacters.Length)
                $SeparatorCharacter = $SeparatorCharacters[$SeparatorIndex]
            }
            else { $SeparatorCharacter = $SeparatorCharacters }

            # Print final password
            Write-Output ($PasswordWords -join $SeparatorCharacter)
        }
    }
}