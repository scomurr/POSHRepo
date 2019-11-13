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

# Summary: This script will download and then upload the provided zip file to an
# MCAS collector machine waiting which will then upload to MCAS and populate the
# discovery dashboards.

# Flow:
# 1. Start the VM
# 2. wait for the VM to fire all the way up
# 3. Upload the zip
# 4. Wait for > 5 minutes so that the log is uploaded to MCAS
# 5. Shutdown the vm

# Script leverages the CredentialManager Module
# https://www.powershellgallery.com/packages/CredentialManager/2.0

# As of the writing of the script, the Palo Alto FW sample logs are located here:
# "https://adaproddiscovery.blob.core.windows.net/logs/pa-series-firewall_demo_log.log.zip"
$PaloAltoLogLocation = "https://adaproddiscovery.blob.core.windows.net/logs/pa-series-firewall_demo_log.log.zip"

# Import config from .env file
$Config = gc .\MCAS_Upload-Log.env | ConvertFrom-JSON
$LogCollectorVMName = $config.LogCollectorVMName
$LogCollectorHVHost = $config.LogCollectorHVHost
$LogCollectorIP = $Config.LogCollectorIP
$LogCollectorDSName = $Config.LogCollectorDSName
$CredManTarget = $Config.CredManTarget
$LogfilePath = $Config.LogfilePath

# start the vm
get-vm -Name $LogCollectorVMName -ComputerName $LogCollectorHVHost | Start-VM

# sleep -s 180

rm $LogfilePath
wget -uri $PaloAltoLogLocation -OutFile $LogfilePath

# upload
$credential = Get-StoredCredential -Target $CredManTarget
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

$ftpsite = "ftp://$LogCollectorIP"


ls $LogfilePath\*.zip | %{
    # create the FtpWebRequest and configure it
    $ftp = [System.Net.FtpWebRequest]::Create("$ftpsite/$LogCollectorDSName/$($_.name)")
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.Credentials = new-object System.Net.NetworkCredential("$username","$password")
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true
    # read in the file to upload as a byte array
    $content = [System.IO.File]::ReadAllBytes($_.FullName)
    $ftp.ContentLength = $content.Length
    # get the request stream, and write the bytes into it
    $rs = $ftp.GetRequestStream()
    $rs.Write($content, 0, $content.Length)
    # be sure to clean up after ourselves
    $rs.Close()
    $rs.Dispose()
    $_.name
}

# Wait 15 minutes before shutting down the VM to allow the file to be uploaded to MCAS
sleep -s 900

#shutdown vm
get-vm -Name $LogCollectorVMName -ComputerName $LogCollectorHVHost | Stop-VM -force

# Default creds for the FTP server - discovery:BP98Jw4Ns*zpTFrH