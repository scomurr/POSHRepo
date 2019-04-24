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

# Creates a litigation hold report and also concatenates total item size as
# well as the recoverable items size to the objects prior to writing out to
# the output file

$Username = "admin@<domain>.onmicrosoft.com"
$Password = ConvertTo-SecureString '<SuperSecretPassword>' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential $Username,$Password
#$Session = New-PSSession -Authentication Basic -Credential $Credential -ConnectionUri https://mail.jhgfdsa.com/powershell/ -ConfigurationName Microsoft.Exchange -AllowRedirection
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber

$file = "c:\windows\temp\lithold.txt"
out-file -filepath $file -encoding ascii
$mboxes = Get-mailbox -Filter { LitigationHoldEnabled -eq $true } -ResultSize unlimited | Select-Object name,alias,LitigationHoldEnabled,LitigationHoldDate,LitigationHoldOwner,LitigationHoldDuration,RetentionComment
foreach($mbox in $mboxes) {
    $recItems = Get-MailboxFolderStatistics –FolderScope RecoverableItems -Identity $mbox.Name
    $mboxStats = Get-MailBoxStatistics -Identity $mbox.Name
    $mbox | Add-Member NoteProperty TotalItemSize $mboxStats.TotalItemSize
    $mbox | Add-Member NoteProperty RecoverableItemSize ($recItems | ?{$_.name -eq "Recoverable Items"}).FolderAndSubfolderSize
    $mbox | out-file $file -encoding ascii -Append
}
