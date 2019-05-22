# Author: Scott Murray
# Date: 5/22/2019

# Summary: The purpose of these scripts is to connect to OD personal and download files
# to a local repository.

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

# read in .env file to get ClientID and other env variables
$Config = gc .\OD_Dowload-ScotlandPictures.env | ConvertFrom-JSON
$ClientId = $config.ClientID
$downloadPath = $Config.downloadPath
$tokenPath = $Config.tokenPath
$ODPath = $Config.ODPath
$uploadURI = $Config.uploadURI

# Use the refresh token to grab a new access token
# Handled in a seperate script for ease of reuse
& .\OD_Get-Tokens.ps1 -ClientID $ClientId -tokenPath $tokenPath

sleep -s 3  #just to make sure the file is fully written out

$oauth = (ls $tokenPath\access_token* | sort lastwritetime -descending)[0] | gc | convertfrom-json

$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
$headerParams
$resource = "https://api.onedrive.com/v1.0"

# easier to access the items if you can mine the drive id and then the information foreach of the items
# you want to touch. Gaining the driveid is making a call to root and then harvesting the drive id
$url = "https://api.onedrive.com/v1.0/drive/root"
$driveInfo = (Invoke-restmethod -uri $url -Headers $headerParams).value
$driveID = $driveInfo.id

$url = $resource + "/drives/$driveID/root:" + $ODPath + ":/children"
$pictureInfo = (Invoke-restmethod -uri $url -Headers $headerParams).value

$uploadedList = (invoke-webrequest -Uri $uploadURI).Links.InnerText

$pictureInfo | %{
    if(-NOT $uploadedList.contains($_.name)) {
        write-host "Downloading: $($_.name)"
        $uri = $resource + "/drives/$driveid/items/$($_.id)/content"
        $outFileName = "$downloadPath\$($_.name)"
        $file = Invoke-restmethod -uri $uri -Headers $headerParams -Method Get -OutFile $outFileName
    } else {
        write-host "File already exists: $($_.name)"
    }
}

