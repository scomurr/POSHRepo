# author: Scott Murray
# date: 5/22/2019

# summary: ftps files from a local repo to a remote ftp server

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


# install-module CredentialManager
# use the module to store the credentials in the local credman and not have to store
# them in a config or flat file
$credential = Get-StoredCredential -Target scotland
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

$Config = gc .\OD_Dowload-ScotlandPictures.env | ConvertFrom-JSON
$ftpsite = $Config.ftpsite
$ftpfolder = $Config.ftpfolder
$ftpfull = $ftpsite + $ftpfolder
$archiveFolder = $Config.archiveFolder

ls C:\ScotlandScript\ToUpload | %{
    # create the FtpWebRequest and configure it
    $ftp = [System.Net.FtpWebRequest]::Create("$ftpfull/$($_.name)")
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.Credentials = new-object System.Net.NetworkCredential("$username","$password")
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true

    # create the byte stream to upload
    $content = [System.IO.File]::ReadAllBytes($_.FullName)
    $ftp.ContentLength = $content.Length

    # establish the stream and upload (write)
    $rs = $ftp.GetRequestStream()
    $rs.Write($content, 0, $content.Length)

    # destroy objects and clean up
    $rs.Close()
    $rs.Dispose()
    $_.name

    # if the upload fails, the file is left in the upload location for the next
    # iteration. If the upload succeeds, the file is moved to an archive folder
    & @({"File failed to upload - leaving for next iteration"},{"File uploaded. Moving...";move $($_.fullname) $archiveFolder -force })[((invoke-webrequest -Uri $ftpfull).Links.InnerText.Contains($_.Name))]
}