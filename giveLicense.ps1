#Give O365 Licenses
#August 14, 2015
#Michael Matthews 
#################
#This script is designed to give office 365 licenses to students and employees at BYU.  It logs in using the Connet-MsolService command
#It then sets forth the different types of licenses. Afterwards it uses the Import-CSV command to bring in the list of need-to-add users.
#Afterwards it determines whether or not they are a student or employee.  They are then given the appriopriate licenses.  
#This information is then logged under D:\Scripts\Licensesupdates\Logs\ChangeLogs
#################

#If there is a day that the script does not go off, then the user will not be deleted. Therefore, at the end of each semester you should manually run a script to manually remove all the users
#that fell inbetween the cracks

#Formatting Dates
$todaysDate = Get-Date -Format yyyy-%M-%d
$currentYear = Get-Date -Format yyyy


#If you ever need to change the password.  Use the code below to convert it to a secure string and save it to a file
 #"testpassword" | ConvertTo-SecureString -AsPlainText -Force |
 #ConvertFrom-SecureString | Out-File "D:\Prod\Login\o365-Prod\Login2.txt"

#Establishing a session
<#
Important!!!

In order to run this script you have to be running it as emailservice. This is because it was the 
emailservice account that encrypted the password at D:\Prod\Login\o365-Prod\Login2.txt

#>


Import-Module MSOnline
$User = "licensesupdateuser@byu.onmicrosoft.com"
$File = "D:\Prod\Login\o365-Prod\Login2.txt"
$MyCredential=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)

Connect-MsolService -Credential $MyCredential 


#The variables below are for logging purposes
$fileToWrite = "D:\Prod\Logs\ChangeLogs\$currentYear\change-$todaysDate.txt" 
$toLogStudent = " Added the following students "
$toLogEmployee = " Added the following employees"
$noUsers = "No Users were added today"

#In dev the licenses are different than those in prod
#If you want to see every service plan and it's provisioning status: Get-MSolAccountSku | select -ExpandProperty ServiceStatus
$studentadvantage = New-MsolLicenseOptions -AccountSkuId byu:OFFICESUBSCRIPTION_STUDENT 

#$student = New-MsolLicenseOptions -AccountSkuId byu:STANDARDWOFFPACK_STUDENT -DisabledPlans EXCHANGE_S_STANDARD,MCOSTANDARD

$Proj_Student = New-MsolLicenseOptions -AccountSkuId byu:PROJECTONLINE_PLAN_1_STUDENT 

$facultyadvantage = New-MsolLicenseOptions -AccountSkuId byu:OFFICESUBSCRIPTION_FACULTY 

#$faculty = New-MsolLicenseOptions -AccountSkuId byu:STANDARDWOFFPACK_FACULTY -DisabledPlans EXCHANGE_S_STANDARD,MCOSTANDARD

$Proj_Faculty = New-MsolLicenseOptions -AccountSkuId byu:PROJECTONLINE_PLAN_1_FACULTY

$BI = New-MsolLicenseOptions -AccountSkuId byu:POWER_BI_STANDARD

#########If the script fails, email Mark Werner and get the list of people.

#########The locations of the file below needs to be changed for prod ################
$needtogivelist = import-csv D:\Scripts\Licensesupdates\currentusers\Office_365_Add.txt

$needtogivelist |  ForEach-Object {
    $usersFound = Get-MsolUser -UserPrincipalName $_.UserPrincipalName;
    
    if ($usersFound -ne $null) {
        if(!($usersFound.isLicensed)) {

            if ($_.Status -eq "Student"){
              Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
              #The line below is the the code that actually gives the license
              Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions @($Proj_Student, $studentadvantage, $BI) -AddLicenses @("byu:PROJECTONLINE_PLAN_1_STUDENT", "byu:OFFICESUBSCRIPTION_STUDENT", "byu:POWER_BI_STANDARD");
              $toLogStudent += "$($_.UserPrincipalName)", "$($_.Status)";
            }
            elseif ($_.Status -eq "Employee"){
               Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
                #The line below is the the code that actually gives the license
              Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions @($Proj_Faculty, $facultyadvantage, $BI) -AddLicenses @("byu:PROJECTONLINE_PLAN_1_FACULTY", "byu:OFFICESUBSCRIPTION_FACULTY", "byu:POWER_BI_STANDARD");
              $toLogEmployee += "$($_.UserPrincipalName)", "$($_.Status)";
            }

        }
    
     }
 } 
 
 #If there isn't any users added then it loggs $noUsers
 
 write-host $needtogivelist
 if ($needtogivelist.Length -eq 0){

 $noUsers | Outfile $fileToWrite -append

 }
 else {
 
 $toLogStudent | Out-file $fileToWrite -append
 $toLogEmployee | Out-File $fileToWrite -append

 }

