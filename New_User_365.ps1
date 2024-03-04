#Create New user

Import-Module Microsoft.Graph.Users

Connect-MgGraph -Scopes "Directory.ReadWrite.All", "User.ReadWrite.All"
$FirstName = Read-Host -Prompt "Please enter the First Name"
$LastName = Read-Host -Prompt "Please enter the Last Name"
$User = Read-Host -Prompt "Please enter the new Email"
$Password = Read-Host -Prompt "Please enter the Password" -AsSecureString
$Nick = Read-Host -Prompt "Please enter the Nick Name"


$params = @{
	accountEnabled = $true
    mailNickname = $Nick
	displayName = "$($FirstName) $($LastName)"
	userPrincipalName = $User
	passwordProfile = @{
		forceChangePasswordNextSignIn = $true
		password = $Password
	}
}

New-MgUser -BodyParameter $params
#Change Usage Location
Update-MgUser -UserId $User -UsageLocation US

#Get available licenses
$EmsSku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'O365_BUSINESS_PREMIUM'


#Add License 

Set-MgUserLicense -UserId $User  -AddLicenses @{SkuId = $EmsSku.SkuId} -RemoveLicenses @()

#Get User Information
Get-MgUser -UserId $User | Select-Object -Property DisplayName, UserPrincipalName, Id | Format-List
#get User Location
Get-MgUser -UserId $User -Property UsageLocation  | Select-Object UsageLocation

#Get License Information
Get-MgUserLicenseDetail -UserId $User | Select-Object -Property SkuPartNumber, SkuId   

#Disconnect from tenant
Disconnect-Graph | Out-Null