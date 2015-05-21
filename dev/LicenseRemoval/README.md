#Removal of Licenses
This script removes licenses from those who are not eligable for those licenses.  However this does not remove the actual account.  It only removes the licenses. 

Note: The password for any "person" user is "W3ar33dgy!"



This is the email that would be sent out in case of a failure



In order to speed up the script this function only gets those who have licenses and not all users 
This puts the MSOLusers in the correct format of "userprincipalname" into the array of $haslicense


this puts the activeusers in the correct format of "userprincipalname" into the array of $activeusers


This compares the two lists. If someone is licensesed but isn't on the "active users" their license is then put into the $needtoremove array

This is a check.  In theory, if someone is in the $needtoremove they shouldn't be in the $activeusers.  If they are they are then put into the $dontremove array.  If that array exceeds one person, the script stops.


This serves as a douple check.  If $needtoremove exceeds a certain number the script will stop


This does the actual removal of the licenses

This serves as a third check.  If a certain license has dropped signficantly then the script will restore licenses to users
