Office 365

This script grants the licenses for active users at BYU.  This script does not deal with accounts, but only licenses.  A brief description of how the accounts work is given below. 

Accounts:

Accounts are added onto the office.byu.edu website via DirSync.  This is supported with Microsoft and syncs with our Active Directory.  All those in our AD (except for the inactive OU) is synced with MSOl.  The only reason it wouldn't be synced it because it lacks the Attributes 10 and 11.  More information concerning this can be found by speaking with Jim Saunders or looking in the BYU EDGE OneNote.  Accounts are also removed through DirSync

Licenses:

This script gets all active students from a file under D:/scripts/licenseupdates/currentusers/office365.txt on ADFS1.  This file is supplied by Mark Werner and updates daily. The script then compares active users with those one MSOL.  If someone is on the active users but does not have licenses they are then given the licenses.  This script does not remove licenses. The only license that it would remove is if a student became a full-time employee, then it would give the employee the faculty license and remove the student license. 

-Michael Matthews 5/20/2015
michaeljmatthews@byu.edu