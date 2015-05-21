
function Get-ContainsLicense {
    param($licenses, $accountSku);

    $toReturn = $licenses | Where-Object { $_.AccountSkuId -eq "byu:OFFICESUBSCRIPTION_STUDENT" };
    
    return $toReturn -ne $null;
}

$curDate = $([datetime]::Now.ToString("yyyy-MM-dd"));

Import-Module MSOnline
$securePassword = ConvertTo-SecureString "Dana2471" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential("licensesupdateuser@byu.onmicrosoft.com", $securePassword)
Connect-MsolService -Credential $credentials >> "D:\Scripts\Licensesupdates\Logs\UsersToDelete\DELETEDUsers-$curDate.txt"

$studentadvantage = New-MsolLicenseOptions -AccountSkuId byu:OFFICESUBSCRIPTION_STUDENT 

$student = New-MsolLicenseOptions -AccountSkuId byu:STANDARDWOFFPACK_STUDENT -DisabledPlans EXCHANGE_S_STANDARD,MCOSTANDARD

$facultyadvantage = New-MsolLicenseOptions -AccountSkuId byu:OFFICESUBSCRIPTION_FACULTY 

$faculty = New-MsolLicenseOptions -AccountSkuId byu:STANDARDWOFFPACK_FACULTY -DisabledPlans EXCHANGE_S_STANDARD,MCOSTANDARD

$msolUsers = (Get-MsolUser -All);

Import-Csv -Path D:\Scripts\Licensesupdates\currentusers\Office_365.txt |  ForEach-Object {
    $csvusers += $_.UserPrincipalName;
    $usersFound = Get-MsolUser -UserPrincipalName $_.UserPrincipalName;
    
    if ($usersFound -ne $null) {
        if(-not($usersFound.isLicensed)) {

            if ($_.Status -eq "Student"){
                Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
	            Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions @($student, $studentadvantage) -AddLicenses @("byu:STANDARDWOFFPACK_STUDENT", "byu:OFFICESUBSCRIPTION_STUDENT");
               Write-Output "Added non existing user $($_.UserPrincipalName) to Student" >> "D:\Scripts\Licensesupdates\Logs\ChangeLogs\change-$curDate.txt";
            }
            elseif ($_.Status -eq "Employee"){
                Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
                Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions @($faculty, $facultyadvantage) -AddLicenses @("byu:STANDARDWOFFPACK_FACULTY", "byu:OFFICESUBSCRIPTION_FACULTY");
                Write-Output "Added non existing user $($_.UserPrincipalName) to Faculty" >> "D:\Scripts\Licensesupdates\Logs\ChangeLogs\change-$curDate.txt";
            }

        }
     
        

        #cleanup for existing licenses
        elseif ($_.Status -eq "Employee" -and $usersFound.Licenses.Count -lt 2) {
            Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation "US"
            Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions @($faculty, $facultyadvantage) -AddLicenses @("byu:STANDARDWOFFPACK_FACULTY", "byu:OFFICESUBSCRIPTION_FACULTY");
        }
        elseif ($usersFound.Licenses -ne $null -and (-not(Get-ContainsLicense -accountSku "byu:OFFICESUBSCRIPTION_STUDENT" -licenses ($usersFound.Licenses))) -and ($_.Status -eq "Student")){
                Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions $studentadvantage -AddLicenses "byu:OFFICESUBSCRIPTION_STUDENT"
                Write-Output "Added existing user $($_.UserPrincipalName) to Office Pro Subscription" >> "D:\Scripts\Licensesupdates\Logs\ChangeLogs\change-$curDate.txt";
        }
        elseif ($usersFound.Licenses -ne $null -and (Get-ContainsLicense -accountSku "byu:OFFICESUBSCRIPTION_STUDENT" -licenses ($usersFound.Licenses)) -and ($_.Status -eq "Employee")){
                Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -RemoveLicenses "byu:OFFICESUBSCRIPTION_STUDENT";
                Write-Output "Removed existing user $($_.UserPrincipalName) from Office Pro Subscription" >> "D:\Scripts\Licensesupdates\Logs\ChangeLogs\change-$curDate.txt";
        }
 }
 }

 ###This script used to have a part below that would remove old msolusers.  However, that function did not work. 