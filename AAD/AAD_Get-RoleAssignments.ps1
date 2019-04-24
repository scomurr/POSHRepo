# Author: Scott Murray
# Date:
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

# Adds a specific user to the a specific role through the PIM API and makes
# that user eligible for elevation

#vars
$ClientID       = ""             # Should be a ~35 character string insert your info here
$ClientSecret   = ""     # Should be a ~44 character string insert your info here
$loginURL       = "https://login.microsoftonline.com/"
$tenantdomain = "<domain>.onmicrosoft.com"
# $tenantId = ""

# pulling stored credentials from the local credential manager
$cred = Get-StoredCredential -target Azure
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password

<#$cred = Get-Credential
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password
#>

$resource = "https://graph.microsoft.com"

#oauth
#$body = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$body = @{grant_type="password";resource=$resource;username=$username;password=$password;client_id=$ClientID;client_secret=$ClientSecret}
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

#action
#$results = Invoke-RestMethod -Headers $headerParams -Method get -Uri "https://graph.microsoft.com/beta/privilegedRoleAssignments"
#$results.value.Count

#add a user to a role
$url2 = "https://graph.microsoft.com/beta/privilegedRoleAssignments"
$contentType = "application/json"

#cloudonly1 user account id = cbbeeed5-bb9f-44b4-8c4b-9a6b39072bde
#compliance admin role = 17315797-102d-40b4-93e0-432062caca18
$op = "Post"
$body = '{ "userId":"cbbeeed5-bb9f-44b4-8c4b-9a6b39072bde","roleId":"17315797-102d-40b4-93e0-432062caca18","type":"UserAdd"}'
$body
$results = $null
$results = Invoke-RestMethod -Headers $headerParams -Method $op -ContentType $contentType -Uri $url2 -Body $body
$results
$id = $results.id

$op = "Post"
$url3 = "https://graph.microsoft.com/beta/privilegedRoleAssignments/$id/makeEligible"
$url3
$body = '{ "reason":"blah","ticketNumber":"blah","ticketSystem":"blah"}'

$results = $null
$results = Invoke-RestMethod -Headers $headerParams -Method $op -Uri $url3 -body $body -ContentType "application/json"
$results


<#$url4 = "https://graph.microsoft.com/beta/privilegedRoleAssignments/my"
$results = Invoke-RestMethod -Headers $headerParams -Method Get  -Uri $url4
$results.value
#>


