<##
 # Copyright 2021 David Hollings. All rights reserved.
 # Use of this source code is governed by a BSD-style
 # license that can be found in the LICENSE file.
#>

. $PSScriptRoot/Private/HelperFunctions.ps1

Function Publish-Password {
	<#
	.SYNOPSIS
		Generate PwPush link for a given password.
	.DESCRIPTION
		Generate a PwPush link with a cusomisable lifetime and copies it to the clipboard.
		When multiple passwords are provided via pipeline input only the last is available on the clipboard.
	.PARAMETER Password
		The password to be sent (Mandatory).
	.PARAMETER Days
		How long to make the password available for. Default: 7. Maximum: 90.
	.PARAMETER Views
		How many times the password can be viewed before the link is removed. Default: 5. Maximum 90.
	.PARAMETER URI
		URI for PwPush API. Default: https://pwpush.com/p.json
	.PARAMETER DisableEarlyDeletion
		Prevent anyone accessing the link from deleting the password before the scheduled expiration.
	.EXAMPLE
		PS> Publish-Password -Password password123 -Days 7 -Views 5 -DisableEarlyDeletion

		Password  : password123
		Days      : 7
		Views     : 5
		Deletable : False
		Link      : https://pwpush.com/p/f3vg6lry95gj6n9n

		This example creates a link for the password "password123", makes it available for 7 days or 5 views and prevents the user from deleting it early.
	.EXAMPLE
		PS> New-Password -Character -Length 32 | Publish-Password -Views 10

		Password  : \t&#P$c`u~5Xgb9c`!V]w0,r>9O~nsA3
		Days      : 7
		Views     : 10
		Deletable : True
		Link      : https://pwpush.com/p/dd59wor2ipsnm7az

		This example generates a random string and pipes it to PwPush with a view count of 10.
	.INPUTS
		System.String
	.OUTPUTS
		System.Management.Automation.PSCustomObject

	.LINK
        https://github.com/davidshomelab/PS-PwUtils
	#>

	[CmdletBinding()]
	Param(
		# Password to be sent.
		[Parameter(mandatory, ValueFromPipeline)]
		$Password,

		# Days to retain link.
		[ValidateRange(1, 90)]
		[int16]
		$Days = 7,
    
		# Views to retain link.
		[ValidateRange(1, 100)]
		[int16]
		$Views = 5,

		# URI for PwPush API.
		[ValidateScript ({
				$UriStructure = [uri]$_
				$UriStructure.Scheme -eq "HTTPS"
			})]
		[string]
		$URI = 'https://pwpush.com/p.json',

		# Is user allowed to delete link early.
		[Parameter()]
		[switch]
		$DisableEarlyDeletion,

		# Use 1-click retrieval step. Avoids URL scanners consuming a view.
		[Parameter()]
		[switch]
		$OneClickRetrieval,

		# Do not show password in output. If set, SecureString object will be returned instead of cleartext password.
		[Parameter()]
		[switch]
		$HidePassword,

		# Copy link to clipboard. If called as part of a pipeline, only the last value will be copied
		[Parameter()]
		[switch]
		$CopyToClipboard,

		# Number of retries if connection fails. Default = 5
		[Parameter()]
		[int]
		$MaxRetries
	)

	begin {
		# Response URI ends in /p instead of /p.json so we prepare this in advance to avoid recalculating for every pipeline object
		# We convert to a [uri] object to ensure URI is in simplest form (i.e. implicit port numbers are removed)
		$ResponseUri = (([uri]$URI).AbsoluteUri -replace '.json$', '/')
	}
    
	process {

		# Check if password was recieved from New-Password and extract password property if it was
		Write-Verbose "Checking if pipeline input is pscustomobject"
		Write-Verbose "Password type is $($Password.GetType().Name)"

		if ($Password.GetType().Name -eq "PSCustomObject") {
			$Password = $Password.Password
			Write-Verbose "Extracted password $Password from pipeline object"
		}
		
		# Ideally password should be received as a secure string. If a String is received, print a warning and convert to secure string
		if ($Password -isnot [SecureString]) {
			Write-Warning -Message "It is recommended to input the password as a secure string."
			$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
		}
		else {
			$SecurePassword = $Password
		}

		$attempts = 0
		$Response
		do {
			$attempts ++
			try {
				$Response = Invoke-RestMethod -Method "Post" -Uri $URI -ContentType "application/json" -TimeoutSec 5 -Body ([PSCustomObject]@{
						password = [PSCustomObject]@{
							payload             = SecureStringToPlainText -Password $SecurePassword
							expire_after_days   = $Days
							expire_after_views  = $Views
							deletable_by_viewer = -not $DisableEarlyDeletion
						}
					} | ConvertTo-Json ) 
			   
			}

			catch [Microsoft.PowerShell.Commands.HttpResponseException] {
				Start-Sleep -Seconds 2
			}
			
		} while ($attempts -le $MaxRetries)
		   
		
		# If the request fails for any reason we won't get a response. In this case we shouldn't write out a summary
		if ($Response) {

			$Link = $ResponseUri + $Response.url_token
			
			if ($OneClickRetrieval) {
				$Link += "/r"
			}

			return [PSCustomObject]@{
				Password  = if ($HidePassword) { $SecurePassword } else { SecureStringToPlainText -Password $SecurePassword }
				Days      = $Days
				Views     = $Views
				Deletable = -not $DisableEarlyDeletion
				Link      = $Link
			}
		}
	}
	end {
		if ($CopyToClipboard) {
			Set-Clipboard -Value $Link
		}
	}
}

New-Alias PwPush -Value Publish-Password