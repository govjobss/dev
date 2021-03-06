
#########################################################################################################
# ScriptName: Zip and backup logs							#
# Author: Arun Sabale										#
# Date: 05/01/2015											#
# Version : 1.0												#
#########################################################################################################

$ErrorActionPreference= 'silentlycontinue'

$hostnm = $env:computername
$hostnm
$LogfileDirectory = "C:\Program Files\Microsoft\Exchange Server\V14\Mailbox\Mailbox Database 1818204029"
$LogArchiveDirectory = "E:\Log-BKP"


function Add-event-Zip
{
	param([string]$zipfilename)

	if(-not (test-path($zipfilename)))
	{
		set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		(dir $zipfilename).IsReadOnly = $false	
	}
	
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($zipfilename)
	
	foreach($file in $input) 
	{ 
            $zipPackage.CopyHere($file.FullName)
            Start-sleep -milliseconds 10000
	}
}


$LogFileNames = Get-ChildItem $LogfileDirectory -Recurse -Include *.log | Where-Object { $_.CreationTime -lt (Get-Date).Adddays(-2) -and $_.name -like "$hostnm*"}
$tempfolderName =  (Get-Date).adddays(-2).ToString("ddMMyyyy")

                                 $LogDestination = $LogArchiveDirectory + "\" + $tempfolderName 
                                 $targetCheck = Test-Path $LogDestination
                                 if(!$targetCheck) {mkdir $LogDestination }

foreach($file in $LogFileNames) {
                                        $LogSource = $LogfileDirectory + "\" + $file.Name

                                        Move-item -path $LogSource -destination $LogDestination -Force -ErrorAction:SilentlyContinue -Confirm:$false
                                        write-host "Moving $file.Name to backup location"
                                        #echo $SiteLogfileDirectory + "\" + "u_ex120125.log", $TargetArchiveFolder + "\" + "u_ex120125.log"
                                                                                                                                                               
                                    }
                               
                                            $LogDestinationZip = $LogDestination + ".zip"
                                            dir $LogDestination\*.* -Recurse | Add-event-Zip $LogDestinationZip
                                            write-host "adding files to Zip"
					   Start-sleep -milliseconds 3000
                                            Remove-Item $LogDestination -Recurse -force