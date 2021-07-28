Function PwPush {
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
		PS> PwPush -Password password123 -Days 7 -Views 5 -DisableEarlyDeletion

		Password  : password123
		Days      : 7
		Views     : 5
		Deletable : False
		Link      : https://pwpush.com/p/f3vg6lry95gj6n9n

		This example creates a link for the password "password123", makes it available for 7 days or 5 views and prevents the user from deleting it early
	.EXAMPLE
		PS> -join ((33..126) * 20 | Get-Random -Count 32 | % {[char]$_}) | PwPush -Views 10

		Password  : \t&#P$c`u~5Xgb9c`!V]w0,r>9O~nsA3
		Days      : 7
		Views     : 10
		Deletable : True
		Link      : https://pwpush.com/p/dd59wor2ipsnm7az

		This example generates a random string and pipes it to PwPush with a view count of 10
	.INPUTS
		System.String
	.OUTPUTS
		System.Management.Automation.PSCustomObject
	#>

	Param(
	    # Password to be sent
	    [Parameter(mandatory, valuefrompipeline)]
	    [string]
	    $Password,
    
	    # Days to retain link
	    [ValidateRange(1,90)]
	    [int16]
	    $Days = 7,
    
	    # Views to retain link
	    [ValidateRange(1,100)]
	    [int16]
	    $Views = 5,

	    [ValidateScript ({
		    $UriStructure = [uri]$_
		    $UriStructure.Scheme -eq "HTTPS" #-and (Test-NetConnection -ComputerName $UriStructure.IdnHost -Port $UriStructure.Port).TcpTestSucceeded
	    })]
	    [string]
	    $URI = 'https://pwpush.com/p.json',

	    # Is user allowed to delete link early
	    [Parameter()]
	    [switch]
	    $DisableEarlyDeletion
	)

	begin {
		# Response URI ends in /p instead of /p.json so we prepare this in advance to avoid recalculating for every pipeline object
		# We convert to a [uri] object to ensure URI is in simplest form (i.e. implicit port numbers are removed)
		$ResponseUri = (([uri]$URI).AbsoluteUri -replace '.json$','/')
	}
    
	process {
	    $Request = [PSCustomObject]@{
		    payload = $Password
		    expire_after_days = $Days
		    expire_after_views = $Views
		    deletable_by_viewer = -not $DisableEarlyDeletion
	    }

	    $Response = Invoke-RestMethod -Method "Post" -Uri $URI -ContentType "application/json" -TimeoutSec 5 -Body ([PSCustomObject]@{
				password = $Request
			} | ConvertTo-Json ) 
		   
		
		# If the request fails for any reason we won't get a response. In this case we shouldn't write out a summary
		if ($Response) {

			$Link = $ResponseUri + $Response.url_token

			$Summary = [PSCustomObject]@{
				Password = $Password
				Days     = $Days
				Views    = $Views
				Deletable = -not $DisableEarlyDeletion
				Link     = $Link
			}
    
			Write-Output $Summary
		}
	}
	end {
		Set-Clipboard -Value $Summary.Link
	}
}

