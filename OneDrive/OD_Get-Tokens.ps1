# Author: Scott Murray
# Date: 5/22/2019

# Summary: This script helps you retrieve the access and refresh token for
# OneDrive personal in order to connect to the API and manage the files.

### NOTE ###
# There does not seem to be a way to programattically retrieve the access
# token in full. For the personal OneDrive, a code needs to be retrieved
# interactively (client secret does not work - the api rejects it and
# forces you the code route)
# you need to retrieve the code 1x using an interactive login
# you can then use that code to retrieve the access code
# store the returned access, refresh and auth codes for future use
# https://docs.microsoft.com/en-us/onedrive/developer/rest-api/getting-started/msa-oauth?view=odsp-graph-online

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

param (
    [Parameter(Mandatory=$true)][string]$ClientID,
    [Parameter(Mandatory=$true)][string]$tokenPath,
    [Parameter][string]$tokenType = "refresh", # access
    [Parameter][string]$Scope = "onedrive.readwrite offline_access" #offline_access required to get refresh token
)

#get code
$RedirectUri = "https://login.live.com/oauth20_desktop.srf"
$resource       = "https://graph.microsoft.com"

if($tokentype -eq "access")
{
    $url = "https://login.live.com/oauth20_authorize.srf?client_id=$clientid&scope=$scope&response_type=code&redirect_uri=$redirecturi&resource=$resource"
    write-host $url

    #paste the output into browser, authenticate and then copy the code out of the returned URL
    if(test-path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") {
        & "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" $url
    } else {
        Write-Host "Chrome is not installed in the default path. Please copy the displayed URL and paste into your browser of choice."
    }
    pause

    # just stop the script here and then run the rest of the this block by hand after pasting in the code
    # enter the copied in code here - it seems to be a 1x code in order to retrieve tokens
    $code = "XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

    $body        = @{client_id=$clientid;redirect_uri=$redirecturi;code=$code;grant_type="authorization_code"}
    $oauth       = Invoke-RestMethod -Method Post -Uri "https://login.live.com/oauth20_token.srf" -Body $body -ContentType "application/x-www-form-urlencoded"

    $filename = "$tokenPath\access_token_" + (get-date -format "yyyymm%d%H%M%S") + ".json"
    $oauth | convertto-json | out-file $filename -encoding ascii
} else {
    $token = (ls .\access_token* | sort lastwritetime -descending)[0] | gc | convertfrom-json

    $body = "client_id=$clientid&redirect_uri=$redirecturi&refresh_token=$($token.refresh_token)&grant_type=refresh_token"
    $oauth = Invoke-RestMethod -Method post -uri "https://login.live.com/oauth20_token.srf" -ContentType "application/x-www-form-urlencoded" -Body $body

    $filename = "$tokenPath\access_token_" + (get-date -format "yyyymm%d%H%M%S") + ".json"
    $oauth | convertto-json | out-file $filename -encoding ascii
}