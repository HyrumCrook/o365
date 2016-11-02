#Remove O365 Licenses
#August 14, 2015
#Michael Matthews 
#Important NOTE: There is a catch on this script. If you try and remove more than 15,000 users at once it will not work

#################
#This script is designed to remove office 365 licenses from past students and employees at BYU.  It logs in using the Connet-MsolService command
#It then sets forth the different types of licenses. Afterwards it uses the Import-CSV command to bring in the list of need-to-remove users.
#Afterwards it determines whether or not they are a student or employee.  They are then given the appriopriate licenses.  
#This information is then logged under D:\Scripts\Licensesupdates\Logs\ChangeLogs
#################

#Formatting Dates
$todaysDate = Get-Date -Format yyyy-%M-%d
$currentYear = Get-Date -Format yyyy

#If you ever need to change the password.  Use the code below to convert it to a secure string and save it to a file "testpassword" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "D:\Prod\Login\o365-Prod\Login2.txt"


<#
Important!!!

In order to run this script you have to be running it as emailservice. This is because it was the 
emailservice account that encrypted the password at D:\Prod\Login\o365-Prod\Login2.txt


#>


#Establishing a session
Import-Module MSOnline
$User = "licensesupdateuser@byu.onmicrosoft.com"
$File = "D:\Prod\Login\o365-Prod\Login2.txt"
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)

Connect-MsolService -Credential $MyCredential 


#The variables below are for logging purposes
$fileToWrite = "D:\Prod\Logs\ChangeLogs\$currentYear\change-$todaysDate.txt" 
$toLogStudent = " Removed the following students "
$toLogEmployee = " Removed the following employees"
$noUsers = "No Users were added today"


$needToRemoveList = import-csv D:\Scripts\Licensesupdates\currentusers\Office_365_Delete.txt

$needtoremove = @()

ForEach($old in $needToRemoveList) {
    ($needtoremove += $old.UserPrincipalName)
}

#The number below is the limit to how many users can be removed at once
$catch = 15000

$From = "office365admin@byu.edu"
$To = "office365admin@byu.edu"
$Cc = "michaeljmatthews@byu.edu"
$Subject = "Office 365 Script Failed"
$Body = "There is a script that runs on ADFS1 on a daily basis to give and remove office 365 licenses. The script failed because it exceeded the limit of 
deletions allowed per day. No users were deleted. In order to delete these users please do it manually.

Thank you


BYU OIT"

$SMTPServer = "gateway.byu.edu"
$SMTPPort = "25"



#This serves as a douple check.  If $needtoremove exceeds a certain number the script will stop
if ($needtoremove.length -ge $catch) {
    Write-host "You are trying to remove too many users at once"
    Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort
    break
}



 $needToRemoveList |  ForEach-Object {
    $csvusers += $_.UserPrincipalName;
    $usersFound = Get-MsolUser -UserPrincipalName $_.UserPrincipalName;
    
    if ($usersFound -ne $null) {
        if($usersFound.isLicensed) {

            if ($_.Status -eq "Student"){
              
		#The reason that I go through and delete both student and faculty licenses is because sometimes we have issues where a student, over the summer becomes an employee. So when we go to delete them
		#we need to delete any license they may have because even though they may be an "employee" they may have a student license
		#The reason that I don't delete all the licenses on a single line is because if one of the licenses isn't there, the command fails and doesn't delete any of them

	     	Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:STANDARDWOFFPACK_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:OFFICESUBSCRIPTION_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:POWER_BI_STANDARD 
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:OFFICESUBSCRIPTION_FACULTY
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:STANDARDWOFFPACK_FACULTY
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:PROJECTONLINE_PLAN_1_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:PROJECTONLINE_PLAN_1_FACULTY

              $toLogStudent += "$($_.UserPrincipalName)", ",";

               
            }
            elseif ($_.Status -eq "Employee"){
               
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:STANDARDWOFFPACK_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:OFFICESUBSCRIPTION_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:POWER_BI_STANDARD 
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:OFFICESUBSCRIPTION_FACULTY
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:STANDARDWOFFPACK_FACULTY
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:PROJECTONLINE_PLAN_1_STUDENT
              Set-MsolUserLicense -UserPrincipalName  $_.UserPrincipalName -RemoveLicense byu:PROJECTONLINE_PLAN_1_FACULTY

              $toLogEmployee += "$($_.UserPrincipalName)", ",";
        
            }
        }
    
     }
 } 

 #If there isn't any users removed then it loggs $noUsers
 
 if ($needToRemoveList.Length -eq 0){
     $noUsers | Outfile $fileToWrite -append
 }
 else {
 
    $toLogStudent | Out-file $fileToWrite -append
    $toLogEmployee | Out-File $fileToWrite -append
}

 
