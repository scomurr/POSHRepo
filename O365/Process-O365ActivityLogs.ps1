# Author: Scott Murray
# Date: 6/22/2019

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

# Summary: Handles the output from the Get script. Simply demos how the records are
# returned and then displays a grouped list of all of the userids

.\Get-O365ActivityLogs.ps1 | out-file C:\windows\temp\out.txt

# This will give you a collection of objects and each object will contain multiple records
# This will throw some errors but that is due to the header records that are not in json
# format. Ignore.
$output = gc c:\windows\temp\out.txt | %{$_ | convertfrom-json} | ?{$null -ne $_}

# This exands each of the json chunks so that we now have a collection of records
$output = $output | %{$_}

#$output | ?{$_.UserID -match "sync"} | select -property UserID | sort -Unique

$output | select -property userid | sort userid -Unique