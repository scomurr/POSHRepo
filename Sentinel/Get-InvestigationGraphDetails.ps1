# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.0.0&viewFallbackFrom=azps-3.2.0
# Install-Module -Name Az -AllowClobber -Scope CurrentUser

Connect-AzAccount

$context = Get-AzContext
$pro = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($pro)
$token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
$authHeader = @{
  'Content-Type' = 'application/json'
  'Authorization' = 'Bearer ' + $token.AccessToken 
}

# MTP Sentinel Info
$subscriptionID = "d12e1db0-00d4-499e-8429-d0f374fefced"
$resourceGroupName = "MTPDemoEnvironment"
$OIResourceProvider = "Microsoft.OperationalInsights"
$workspaceName = "MTPDemosLogAnalyticsWorkspace"


# Get all incident data - formerly called cases
$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/$OIResourceProvider/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/cases"
$version = "?api-version=2019-01-01-preview"
$fulluri = $uri + $version
$result = Invoke-RestMethod -Method "Get" -Uri $fulluri -Headers $authHeader
$jsonResult = convertto-json($result)
$jsonResult

# Get all incident data - new API version
$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/$OIResourceProvider/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/incidents"
$version = "?api-version=2020-01-01"
$fulluri = $uri + $version
$result = Invoke-RestMethod -Method "Get" -Uri $fulluri -Headers $authHeader
$jsonResult = convertto-json($result)
$jsonResult

# Get specific incident data - new API version
# incidentid is not a param - it's part of the URL
$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/$OIResourceProvider/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/incidents"
$version = "?api-version=2020-01-01"
$incidentID = "ce3eeaaa-1fad-4856-98c6-c649bab2883d"
$fulluri = $uri + "/$incidentID" + $version
$result = Invoke-RestMethod -Method "Get" -Uri $fulluri -Headers $authHeader
$jsonResult = convertto-json($result)
$jsonResult

# Fuzzing for investigation data
$uri = $version = $fulluri = $jsonResult = $null
$uri = "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$resourceGroupName/providers/$OIResourceProvider/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/"
$version = "?api-version=2019-01-01-preview"
$fulluri = $uri + "traces" + $version
$result = Invoke-RestMethod -Method "Get" -Uri $fulluri -Headers $authHeader
$jsonResult = convertto-json($result)
#$jsonResult

# this one works but it doesn't give me full details for what is included in the investigation graph
# captured from burp 
# "https://management.azure.com/subscriptions/d12e1db0-00d4-499e-8429-d0f374fefced/resourceGroups/mtpdemoenvironment/providers/Microsoft.OperationalInsights/workspaces/mtpdemosloganalyticsworkspace/providers/Microsoft.SecurityInsights/entities/f2d7a864-67f5-c369-9986-92487619e7c8/expand?api-version=2019-01-01-preview&graphStoreV2=true"
$fulluri =  "https://management.azure.com/subscriptions/d12e1db0-00d4-499e-8429-d0f374fefced/"
$fulluri += "resourceGroups/mtpdemoenvironment/providers/Microsoft.OperationalInsights/workspaces/"
$fulluri += "mtpdemosloganalyticsworkspace/providers/Microsoft.SecurityInsights/"
$fulluri += "entities/f2d7a864-67f5-c369-9986-92487619e7c8"
#$fulluri += "/expand"
$fulluri += "?api-version=2019-01-01-preview"
#$fulluri += "?api-version=2020-08-01"
$fulluri += "&graphStoreV2=true" #/ce3eeaaa-1fad-4856-98c6-c649bab2883d/expand?api-version=2019-01-01-preview&graphStoreV2=true"
$result = (Invoke-RestMethod -Method "Get" -Uri $fulluri -Headers $authHeader) #.value
# The .value property contains a collection of PSObjects already - can skip all of the JSON conversion

$result | format-table kind,properties

# It's a post we need 
# details captured in the two getdata files
# incident 2302
# screenshot in the getdata ss

