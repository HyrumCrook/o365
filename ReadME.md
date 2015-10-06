O365 License Script
===============
Office 365 Script  
 
On developer.byu.edu under Support Service Engineering/O365/ the script itself and git commands and more information regarding this script can be found.  
 
  
User Name and Password 
   
Office 365: 
Prod:     office.byu.edu UserName: licensesupdateuser@byu.onmicrosoft.com Password: See Password Safe  
Stg:        portal.office.byu.edu byu_admin@byucommtest.onmicrosoft.com 
Password: See Password Safe 
This script grants the licenses for active users at BYU. This script does not deal with accounts, but only licenses. A brief description of how the accounts work is given below. 
 
Accounts: 
Accounts are added onto the office.byu.edu website via DirSync. This is supported with Microsoft and syncs with our Active Directory. All those in our AD (except for the inactive OU) is synced with MSOl. The only reason it wouldn't be synced it because it lacks the Attributes 10 and 11. More information concerning this can be found by speaking with Jim Saunders or looking in the BYU EDGE OneNote. Accounts are also removed through DirSync.  This function, as far as we are aware, is not currently working.  However this does not affect the effectiveness of the script.  
 
Script1: GiveLicense 
 
This part of the script simply connects with Msol (the online office 365)  Afterwards it imports a csv with the list of new users.  If they are not licensed, they are then given the license.  If they are licensed but don't have all of the licenses they are given the licenses they need.  (this part of the script is a little harder to control.  In theory they should never have only some licenses).  The script then outputs those who were added into the D:\Scripts\Licensesupdates\Logs\ChangeLogs\change-currentdate.txt 
 
Script 2:  Remove License 
 
This script goes through very same process as the script above, however, it imports the csv of those expired users.  These users would have gone 30 days from not being on the list and should've received an email notifying that their license would be removed.  This also outputs those who were deleted in D:/stage/changelogs/remove-currentdate.txt.  This part of the script may give errors if it tries to remove a license that the user doesn't have.   This doesn't affect the script however.  
 
Script 3: Safety Nets 
 
Also, under the script, it has a certain threshold of users to delete at once.  If it tries to exceed this limit it will not work.  
 
Possible Issues 
If the script begins removing many licenses at once, immediately stop the script on ADFS1 and change the name of the script in Task Manager so that the script doesn't kick off the next morning. 
 
For more information contact - Michael Matthews, Jim Saunders, Josh Caldwell, Dan Cunningham (in that order) 

Find Documentation
==================
sse.byu.edu/documents/o365