#Help Desk O365 Admin Rights

This Script ensures that the OIT-Service Desk group "m.csce" has the rights of "User Account Administrator", the script will make sure that users who have been deleted from the group m.csce have their Admin right removed, it will also add the admin rights to new users.

m.csceUserUpdateScript


Previously this script was not working correctly.  One can see the orginal script at "D:\Scripts\Licensesupdates\serviceDeskRights\m.csceUserUpdateScriptOld"

The previously mentioned script failed to actually add users due to the error on line 38.  

There was no $obj variable that was defined.  Also, the previous script would attempt to delete the files after use.  This didn't work because the time format wasn't used correctly.  The $deleteDate = (Get-Date).AddDays(-3) on line 72 cannot use the .AddDays and then format that correctly as was done on line 12 of the script.

I saw no need to delete past files due to the fact that each file is only 1KB.  I took out this function.  I also created the $obj variable.  Because of
this, each time the script is run it will give the following warning:

	 "WARNING: One or more headers were not specified. Default names starting with "H" have been used in place of any missing headers."

This does NOT affect the script in anyway. "Beginning in Windows PowerShell 3.0, if a header row entry in a CSV file contains an empty or null value, 
Windows PowerShell inserts a default header row name and displays a warning message. In previous versions of Windows PowerShell, if a header row entry 
in a CSV file contains an empty or null value, the Import-Csv command fails." More information regarding this warning can be found at:

	https://technet.microsoft.com/en-us/library/hh849891.aspx

Also each time the script is run you may see the following in red:

	"Access Denied. You do not have permissions to call this cmdlet."
	
This however does not affect the script.  If you see either "netid@byu.ed" has been added or "netid@byu.edu" has been deleted then the script has been successful in adding or deleting users.  If you see "@byu.edu" has been deleted, don't worry, it didn't really delete anything.  If you see neither of these then there were no users added or deleted. 

For more information regarding this script please contact Michael Matthews at michaeljmatthews@byu.edu or Jim Saunders.

-Michael Matthews

May 20th 2015



