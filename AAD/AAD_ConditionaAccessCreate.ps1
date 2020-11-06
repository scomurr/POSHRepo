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

# Install the module for AAD
# install-module AzureAD -Force

# Connect - for the purposes of creating policies the user should have Conditional Access Admin privs
Connect-AzureAD

# get, set, remove, new-Get-AzureADMSConditionalAccessPolicy

# create the CA policy

<# Sample from https://github.com/Azure-Samples/azure-ad-conditional-access-apis/tree/main/01-configure/powershell
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Applications.IncludeApplications = "All"
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$conditions.Users.IncludeGroups = "6c96716b-b32b-40b8-9009-49748bb6fcd5"
$conditions.Users.ExcludeGroups = "f753047e-de31-4c74-a6fb-c38589047723"
$conditions.SignInRiskLevels = @('high', 'medium')
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$controls._Operator = "OR"
$controls.BuiltInControls = "mfa"

New-AzureADMSConditionalAccessPolicy -DisplayName "CA0002: Require MFA for medium + sign-in risk" `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

#>

# Constants - I wonder if these are static across tenant
$teamsGUID = "cc15fd57-2c6c-4117-a88c-83b1d56b4bbe"
$exoGUID = "00000002-0000-0ff1-ce00-000000000000"
$spoGUID = "00000003-0000-0ff1-ce00-000000000000"
$o365GUID = "Office365"  # Had to retrieve this one by creating a policy with it configured as criteria
# All Apps = "All" - will just use "All" rather than creating a var

# used Get-AzureADUser to get these GUIDs
$tc1UserGUID = "60b7d370-fa26-451f-a2ca-aaa359183846"
$tc2UserGUID = "3dc7631e-6954-4bc0-b786-f06bfb16a64b"
$tc3UserGUID = "cf6850a3-bab3-4c51-ad6c-03d0b5e145b5"
$tc4UserGUID = "a281bdb8-5dd3-425d-967e-b9ff149d7e09"
$tc5UserGUID = "b65f688a-6e08-4129-9a50-ed364f7df1ca"
$tc6UserGUID = "c6346ab4-989c-483f-8a7d-0eb162557445"
$tc7UserGUID = "33784c01-4829-40fd-8b02-294bd99bd497"
$tc8UserGUID = "42ad1da1-8193-4451-8930-edfd4ee708e4"
$tc9UserGUID = "b5302bf5-ffad-46a6-b990-fc0624b1236c"
$tc10UserGUID = "44d39bba-5c15-4878-b3ca-22f028e7644b"
$tc11UserGUID = "476310f6-f69a-4c79-9899-ca72174c4ce4"

#### TC 1
$CAName = "TC1"
# We need to create conditions
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls

$conditions.Applications.IncludeApplications = "All"
# you can copy these off the apps when configuring a CA policy in the AAD portal
# setting these as constants at the top of the script
# $conditions.Applications.ExcludeApplications = @('','','')
$conditions.Applications.ExcludeApplications = @($teamsGUID)

# users - you can use collections of users, groups, or roles
# for this work, I need the GUIDs for my test users so that I can create them as vars up top and use them
$conditions.Users.IncludeUsers = @($tc1UserGUID)

# for my use cases, I do not believe there are any additional conditions

# We need to create controls
# played with CA and retrieved configs with the get-AzureADMSConditionalAccessPolicy cmdlet
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"

# Do it up
New-AzureADMSConditionalAccessPolicy -DisplayName $CAName `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

# This worked - need to create the additional use cases
#### TC 2
$CAName = "TC2"
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$conditions.Applications.IncludeApplications = "All"
$conditions.Applications.ExcludeApplications = @($teamsGUID, $exoGUID)
$conditions.Users.IncludeUsers = @($tc2UserGUID)
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"

New-AzureADMSConditionalAccessPolicy -DisplayName $CAName `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

#### TC 3
$CAName = "TC3"
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$conditions.Applications.IncludeApplications = "All"
$conditions.Applications.ExcludeApplications = @($teamsGUID, $spoGUID)
$conditions.Users.IncludeUsers = @($tc3UserGUID)
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"

New-AzureADMSConditionalAccessPolicy -DisplayName $CAName `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

#### TC 4
$CAName = "TC4"  <# change here #>
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$conditions.Applications.IncludeApplications = "All" <# change here #>
$conditions.Applications.ExcludeApplications = @($teamsGUID, $spoGUID, $exoGUID) <# change here #>
$conditions.Users.IncludeUsers = @($tc4UserGUID) <# change here #>
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"

New-AzureADMSConditionalAccessPolicy -DisplayName $CAName `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

#### TC 5 - this one needs extra users in order to enable the approp block for the rest of the use cases
$CAName = "TC5"  <# change here #>
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$conditions.Applications.IncludeApplications = "All" <# change here #>
$conditions.Applications.ExcludeApplications = @($o365GUID) <# change here #>
$conditions.Users.IncludeUsers = @($tc5UserGUID) <# change here #>
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"

New-AzureADMSConditionalAccessPolicy -DisplayName $CAName `
   -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls

# validate config and then update to enabled
Get-AzureADMSConditionalAccessPolicy | ?{$_.DisplayName -match 'TC'} | %{set-AzureADMSConditionalAccessPolicy -State "enabled" -PolicyId $_.id}


