# Author: Scott Murray
# Date: 6/25/2019

# We are going to use the search-unifiedauditlog cmdlet to get the
# PowerBI related audit info

# relies on the CredentialManager module

$cred = Get-StoredCredential -Target jhgfdsa

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection

Import-PSSession $session

# not allowed to connect - Access Denied