# not even sue this is possible
# going to get all members of an O365 group
# going to for them into a specific DLP policy for OD4B

$params = @{
    'name' = 'OD4B PS Test DLP Rule';
    'OneDriveLocation' = 'All';
    'Mode' = 'Enable'
}

set-dlpcompliancepolicy @params


# https://blog.ciaops.com/2018/12/20/configuring-office-365-dlp-with-powershell/