#Removal of Licenses
This script removes licenses from those who are not eligable for those licenses.  However this does not remove the actual account.  It only removes the licenses. 

Note: The password for any "person" user is "W3ar33dgy!"

The script connects with MSOnline.  In theory we would want to update our Service Module considering that there is a new one.  However the current module will still work correctly. 

There are some emails that would be sent out in case of an error.  These emails would warn the admin that they were trying to remove to many users at once (see $catch2) or that the license count dropped too much (see $catch3)  However it should be noted that if more licenses become availbe that this would affect the $catch3 and the script would need be editing. 


In order to speed up the script this function only gets those who have licenses and not all users 
This puts the MSOLusers in the correct format of "userprincipalname" into the array of $haslicense


The next part of the script puts the activeusers in the correct format of "userprincipalname" into the array of $activeusers.


The next part of the script compares the two lists. If someone is licensesed but isn't on the "active users" their license is then put into the $needtoremove array

In theory, if someone is in the $needtoremove they shouldn't be in the $activeusers.  If they are they are then put into the $dontremove array.  If that array exceeds one person, the script stops.


The next part of the script serves as a douple check.  If $needtoremove exceeds a certain number the script will stop.  The number of how many users can be removed can be edited on the $catch2 array at the beginning of the script. 

The script then uses a for loop and removes all the licenses. 

This next part serves as a third check.  If a certain license has dropped signficantly then the script will restore licenses to users. NOTE: If the license order changes in the Get-MsolAccountSku then the script will not work correctly.  That is why the email is sent out.  The script would need to be modified so that the $giveback[3] was differnt.  I.E. If there is one more license added so that it comes before the certain license it would need to be $giveback[4].

Any questions regarding this script can be asked to Michael Matthews at michaeljmatthews@byu.edu or Dan Cunningham.

Written by Michael Matthews

May 21st 2015
