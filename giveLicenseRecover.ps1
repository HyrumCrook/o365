###################
#Author: Michael Matthews
#Date: Aug. 24, 2015
#Reason for writing this script:
#This quick script was written to supply the Informatica Team (Mark Werner) with a list of all 
#Unlicencesed users.  Since our granting and removing licenses scripts run as a delta, if we miss 
#a student one day - in theory, they would never get the license.  This script is meant to show,
#the Informatica team, which users still do not have a license.  They then compare this list with their list
#of all eligible users.  If someone shows up on both lists (unlicensed but elibigle to have a license) they will then
#be given a license
###################

#If you ever need to change the password.  Use the code below to convert it to a secure string and save it to a file
 #"testpassword" | ConvertTo-SecureString -AsPlainText -Force |
 #ConvertFrom-SecureString | Out-File "D:\Prod\Login\o365-Prod\Login2.txt"

#Establishing a session
Import-Module MSOnline
$User = "licensesupdateuser@byu.onmicrosoft.com"
$File = "D:\Prod\Login\o365-Prod\Login2.txt"
$MyCredential=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
Connect-MsolService -Credential $MyCredential

#Setting for the unlicensed variable

$unlicensed = Get-Msoluser -UnlicensedUsersOnly -all


$msol = @()
$msol = $unlicensed.UserPrincipalName
$needsLicense = @()

$active = Import-csv D:\Scripts\Licensesupdates\currentusers\Office_365_Eligible_Users.txt
$activePrincipal = $active.UserPrincipalName


for ($i =0; $i -lt $active.count; $i++){
    if ($msol -contains $active[$i].UserPrincipalName){
        $needsLicense += $active[$i]
        }
  }

  
  $needslicense >> D:\Scripts\Licensesupdates\currentusers\cleanupdelta.csv
