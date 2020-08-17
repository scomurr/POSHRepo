# Get-SCCAlerts
# This script pulls the Alerts from the SCC via the Graph API

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

# This script will require the Web Application and permissions setup in Azure Active Directory
# See word Doc with in the O365 set
# https://developer.microsoft.com/en-us/graph/graph-explorer  <-- great examples for what you can get through the API
$Config = Get-Content .\Get-SCCAlerts.env | ConvertFrom-JSON
$ClientID       = $Config.ClientId
$ClientSecret   = $Config.ClientSecret
$Tenantdomain   = $Config.TenantDomain
$loginURL       = "https://login.microsoftonline.com/"

# $daterange
$resource       = "https://graph.microsoft.com"

$body       = @{grant_type="client_credentials";resource=$resource;client_id=$ClientID;client_secret=$ClientSecret}
$oauth      = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body

Write-Output $oauth

if ($oauth.access_token -ne $null) {
    $headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}

    $url = "https://graph.microsoft.com/v1.0/security/alerts"
    Write-Output $url

    $myReport = (Invoke-WebRequest -UseBasicParsing -Headers $headerParams -Uri $url)

    <# foreach ($event in ($myReport.Content | ConvertFrom-Json).value) {
        Write-Output $event
    } #>

    ($myReport.Content | ConvertFrom-Json).value | ft Title

} else {
    Write-Host "ERROR: No Access Token"
}