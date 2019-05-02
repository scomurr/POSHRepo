# This script will require the Web Application and permissions setup in Azure Active Directory
# Associated steps for configuring the AAD app included in the word doc
# This script enables the subscriptions for the various log types and then retrieves
# AAD log entries through the AAD sub. Retrieves the past 7 days.
# Author: Scott Murray
# Date: 5/1/2019

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

#$ClientID       = "" # Should be a ~35 character string insert your info here
#$ClientSecret   = "" # Should be a ~44 character string insert your info here
$loginURL       = "https://login.microsoftonline.com/"
$resource       = "https://manage.office.com"

# Read ClientID, ClientSecret, TenantDomain and TenantId from a .env file
# within the same folder
$Config = gc .\Get-O365ActivityLogs.env | ConvertFrom-JSON
$ClientID       = $Config.ClientId
$ClientSecret   = $Config.ClientSecret
$tenantdomain   = $Config.TenantDomain
$tenantId       = $Config.TenantId

# Retrieve the access token. Check to make sure the script was able to retrieve.
# If so, construct the headerparameters for subsequent calls
$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body

if ($oauth.access_token -ne $null) {
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
} else {
    Write-Host "ERROR: No Access Token"
    pause
    # exit
}

# List the currently enabled subscription types within the tenant. If non of them are enabled, this script will
# enable them all. If 1 or more are enabled, the script will not enable any additional and move on.
$subtypes = @("Audit.AzureActiveDirectory", "Audit.Exchange", "Audit.SharePoint", "Audit.General", "DLP.All")
$subs = Invoke-WebRequest -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenantId/activity/feed/subscriptions/list"

if(($subs -eq $null) -or ($subs.Content -eq "[]"))
{
    # Enable all of the subscriptions
    foreach ($st in $subtypes)
    {
        write-host -ForegroundColor Yellow "Enabling $st..."
        Invoke-RestMethod -Method Post -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenantId/activity/feed/subscriptions/start?contentType=$st"
    }
} else {
    ConvertFrom-JSON $subs.Content
}

# List the AAD Activity content available for the specified window
$startTime = (get-date).AddDays(-7).tostring("yyyy-MM-dd")
$endTime = (get-date).AddDays(1).tostring("yyyy-MM-dd")

$root = "https://manage.office.com/api/v1.0/$tenantId/activity/feed"
$operation = "/subscriptions/content?contentType=audit.azureactivedirectory&amp;startTime=$startTime&amp;endTime=$endTime"
$url = $root + $operation
Write-Output $url

$AADContent = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)

$URIs = ConvertFrom-JSON $AADContent.Content

# Retrieving content from the returned blobs for AAD
$URIs | %{
  $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $_.contentUri).Content
  $myReport
}