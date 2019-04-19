# PIM Demo
# This script adds the CloudOnly1 account from the JHGFDSA tenant to the
# Compliance Administrator role and makes them eligible for elevation via
# PIM.

# Author: Scott Murray
# Date: 1/8/2018

<#
LEGAL DISCLAIMER
This Sample Code is provided for the purpose of illustration only and is not
intended to be used in a production environment.  THIS SAMPLE CODE AND ANY
RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant You a
nonexclusive, royalty-free right to use and modify the Sample Code and to
reproduce and distribute the object code form of the Sample Code, provided
that You agree: (i) to not use Our name, logo, or trademarks to market Your
software product in which the Sample Code is embedded; (ii) to include a valid
copyright notice on Your software product in which the Sample Code is embedded;
and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and
against any claims or lawsuits, including attorneys’ fees, that arise or result
from the use or distribution of the Sample Code.

This posting is provided "AS IS" with no warranties, and confers no rights. Use
of included script samples are subject to the terms specified
at http://www.microsoft.com/info/cpyright.htm.
#>

<# Show app registration first #>

# Variables
$ClientID       = ""             # Should be a ~35 character string insert your info here
$ClientSecret   = ""     # Should be a ~44 character string insert your info here
$loginURL       = "https://login.microsoftonline.com/"
$tenantdomain = "jhgfdsa.com"
$tenantId = ""
$resource = "https://graph.microsoft.com"

# Get credential from Credential Manager
$cred = Get-StoredCredential -target Azure
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password

# Authenticates to the registered app either as a user simply with the client secret
# A user is required for any of the "on behalf of" permissions
#$body = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$body = @{grant_type="password";resource=$resource;username=$username;password=$password;client_id=$ClientID;client_secret=$ClientSecret}
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

# Add a user to a role. Here is the URI and contenttype for the request
$url2 = "https://graph.microsoft.com/beta/privilegedRoleAssignments"
$contentType = "application/json"

# cloudonly1 user account id = cbbeeed5-bb9f-44b4-8c4b-9a6b39072bde
# compliance admin role = 17315797-102d-40b4-93e0-432062caca18
Write-Host "Adding user to role..." -ForegroundColor Yellow
$op = "Post"
$body = '{ "userId":"cbbeeed5-bb9f-44b4-8c4b-9a6b39072bde","roleId":"17315797-102d-40b4-93e0-432062caca18","type":"UserAdd"}'
$results = $null
$results = Invoke-RestMethod -Headers $headerParams -Method $op -ContentType $contentType -Uri $url2 -Body $body
$results

Write-Host "Making the user eligible for elevation..." -ForegroundColor Yellow
$id = $results.id
$op = "Post"
$url3 = "https://graph.microsoft.com/beta/privilegedRoleAssignments/$id/makeEligible"
$body = '{ "reason":"Demo","ticketNumber":"1234","ticketSystem":"Homegrown"}'

$results = $null
$results = Invoke-RestMethod -Headers $headerParams -Method $op -Uri $url3 -body $body -ContentType "application/json"
$results

<# Turn MFA off for the automation account

   Protect the automation account with extreme vigor
	1. Only grant it the necessary perms. Does it need GA? Can it get by without that level of access?
	2. Conditional Access
		a. Only allow access to specific apps or APIs
		b. Only allow it to come from a trusted space
		c. Utilize Device state if possible
	3. Set a strong unique password on the account and create a rotation policy every 60 days
	4. Monitor the accounts use and set up alerts should something deviate from normal usage
        a. Identity Protection if licensed
	5. Treat the source machine as an appropriate Tier
		a. SPA roadmap on-prem needs to be followed and this machine may be T0
   Source machine should be hardened as a PAW and treated as such (if possible)

 App Registration
  1. Client secret needs to be protected
  2. Does not alleviate the need for a password in delegated perm situations
  3. App is easier to put behind conditional access (EA)
  4. Specific users can be assigned to the app (EA)
  5. Perms for the app can be restricted to specific APIs and activities
  6. Account can be a standard user account (no GA or priv role)

 Resources
  1. Graph Explorer: https://developer.microsoft.com/en-us/graph/graph-explorer
  2. Privsec roadmap: https://aka.ms/privsec
  3. Create app for managing Azure resources (like VMs): https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
  4. Using the GRAPH API: https://docs.microsoft.com/en-us/graph/use-the-api
  5. Tokens and registing an app for GRAPH: https://docs.microsoft.com/en-us/graph/auth-overview
  6. Azure API Reference

#>