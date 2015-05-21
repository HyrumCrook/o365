#This must be run on CA6
Add-PSSnapin Microsoft.exchange.management.powershell.snapin

$in = Read-host "Please enter the NetId of the user that needs to connect a mailbox" 

cd D:\Reports\mailboxlocations 
select-string -path *.csv -pattern $in >> d:/reports/powershelloutput/search.txt
get-content d:/reports/powershelloutput/search.txt | out-file D:\reports\Powershelloutput\search.csv -append
$search = import-csv D:\reports\Powershelloutput\search.csv
$location = @()
$name = @()

Foreach ($database in $search)
{

   $location += $database.database
}

Foreach ($displayname in $search)
{

    $name += $displayname.displayname

    }

Connect-Mailbox -Database $location[-1] -Identity $name[-1]