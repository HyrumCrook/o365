#This Script ensures that the OIT-Service Desk group "m.csce" has the rights of "User Account Administrator",
#The script will make sure that users who have been deleted from the group m.csce have their Admin right removed,
#it will also add the admin rights to new users

###After running this command you may recieve the following errors.  These errors do not interupt the effectivness of the script
#WARNING: There is a newer version of the Microsoft Online Services Module.  Your current version will still work as expected, however the latest version can be
 #downloaded at https://portal.microsoftonline.com.

    ###We haven't installed this new module yet

#WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers.
        #this has to do with the Import-CSV command.  If a header row entry in a CSV file contains an empty or null value, Powershell insters a default header.  
        #This doesn't affect the script

#Remove-MsolRoleMember : Access Denied. You do not have permissions to call this cmdlet.
#At line:53 char:9
#+         Remove-MsolRoleMember -RoleName "User Account Administrator" -rolemember ...
#+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 #   + CategoryInfo          : OperationStopped: (:) [Remove-MsolRoleMember], MicrosoftOnlineException
  #  + FullyQualifiedErrorId : Microsoft.Online.Administration.Automation.UserNotFoundException,Microsoft.Online.Administration.Automation.RemoveRoleMember
 #
#@byu.edu has been deleted

    #this "access denied" actually doesn't deny access.  It simply denies access from deleted @byu.edu but will delete any other user.  has no affect
    #on the script.  

###IMPORTANT####
#Regardless of any "errors" it you recieve the output of "netid@byu.edu" has been deleted" or "netid@byu.edu has been added" 
#then they really have been added or deleted

#Authentication
Import-Module MSOnline
$securePassword = ConvertTo-SecureString "Dana2471" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential("licensesupdateuser@byu.onmicrosoft.com", $securePassword)
Connect-MsolService -Credential $credentials

#Getting date information to use on the file extensions
$todaysDate = Get-Date -Format yyyy-%M-%d
$date = (Get-Date).AddDays(-1)
$yesterdaysDate = date $date -format yyyy-%M-%d


#Path for the current list of users
$userPath = "D:\Scripts\Licensesupdates\serviceDeskRights\m.csceUsers_$todaysDate.txt"

#This will just format the txt file correctly, skipping the first 3 lines which consist of the header
Get-ADGroupMember m.csce | ft name > $userPath
Get-Content $userPath | Foreach {$_.TrimEnd()} | set-content "$userPath-1"
Get-Content "$userPath-1" | select -Skip 3 | set-content "$userPath-temp"
move "$userPath-temp" $userPath -Force

$array = Get-Content $userPath

$usersOld = Get-Content "D:\Scripts\Licensesupdates\serviceDeskRights\m.csceUsers_$yesterdaysDate.txt"
$usersNew = Get-Content "D:\Scripts\Licensesupdates\serviceDeskRights\m.csceUsers_$todaysDate.txt"

$comparisons = Compare-Object $($usersOld) $($usersNew)

Compare-Object $($usersOld) $($usersNew) >> "D:\Scripts\Licensesupdates\serviceDeskrights\output\output_$todaysDate.txt"

$obj= Import-Csv -Path "D:\Scripts\Licensesupdates\serviceDeskRights\output\output_$todaysdate.txt"

if($usersOld -ne $null){


foreach ($obj in $comparisons)
{
$name = $obj.InputObject + "@byu.edu"
    if($obj.SideIndicator -eq "=>"){

    Invoke-Command -ScriptBlock {
        Add-MsolRoleMember -RoleName "User Account Administrator" -RoleMembertype User -RoleMemberEmailAddress $name
        }
        write-host $name " Has been added"
    }
    elseif($obj.SideIndicator -eq "<="){

    Invoke-Command -ScriptBlock {
        Remove-MsolRoleMember -RoleName "User Account Administrator" -rolemembertype user -RoleMemberEmailAddress $name
    
        } 
        write-host $name "has been deleted"   
    }
}
}
else{
    foreach ($obj in $usersNew)
{
$name = $obj.InputObject + "@byu.edu"

    Invoke-Command -ScriptBlock {
        Add-MsolRoleMember -RoleName "User Account Administrator" -RoleMemberType User -RoleMemberEmailAddress $name
        }
write-host $name " Has been added"

}
}
write-host ""
write-host ""
write-host "---------------------------------------------"
write-host ""
write-host ""
write-host ""
write-host "----" "IMPORTANT" "----" "Read below" "----"
write-host ""
Write-host "Despite of 'Access Denied' or 'Warning: One or more headers were not specified' errors above, this script has run successfully"
write-host "For more information about this script see ADFS1 D:\Scripts\Licensesupdates\serviceDeskRights\documentation\documentation.txt" 