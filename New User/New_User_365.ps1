#This script helps to create a new user with Office 365 bussines premium license
# David Olvera V 1.0

#Import Graph Module
Import-Module Microsoft.Graph.Users

#Connect to your tenant
Connect-MgGraph -Scopes "Directory.ReadWrite.All", "User.ReadWrite.All"

#Ask for new user details 
$FirstName = Read-Host -Prompt "Please enter the First Name"
$LastName = Read-Host -Prompt "Please enter the Last Name"
$User = Read-Host -Prompt "Please enter the new Email"
$Password = Read-Host -Prompt "Please enter the Password" -AsSecureString
$Nick = Read-Host -Prompt "Please enter the Nick Name"

#Create a Hash table the data 
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

#Create new user with the hash table 
New-MgUser -BodyParameter $params
#Change Usage Location
Update-MgUser -UserId $User -UsageLocation US

#Get  office 365 bussiness premium 
$EmsSku = Get-MgSubscribedSku -All | Where-Object SkuPartNumber -eq 'O365_BUSINESS_PREMIUM'


#Add office 365 bussines premium  license  using SkuId

Set-MgUserLicense -UserId $User  -AddLicenses @{SkuId = $EmsSku.SkuId} -RemoveLicenses @()

#Get User Information
Get-MgUser -UserId $User | Select-Object -Property DisplayName, UserPrincipalName, Id | Format-List
#get User Location
Get-MgUser -UserId $User -Property UsageLocation  | Select-Object UsageLocation

#Get License Information
Get-MgUserLicenseDetail -UserId $User | Select-Object -Property SkuPartNumber, SkuId   

#Disconnect from tenant
Disconnect-Graph | Out-Null