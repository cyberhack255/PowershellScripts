﻿function Download-PreHydrationFiles
{

# Download some of the needed files for hydration
# Author: Oddvar Håland Moe
# msitpros.com
# 
# Posh Command to start this script directly from GIT:
# IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/api0cradle/PowershellScripts/master/Hydration/Pre-Hydration-Download-RunFromGit.ps1')
# Or for the brave:
# IEX (New-Object Net.WebClient).DownloadString('https://goo.gl/N0XK6f'); Download-PreHydrationFiles

# Web Client object
$wc = New-Object System.Net.WebClient
$CSVFile = "https://github.com/api0cradle/PowershellScripts/raw/master/Hydration/Pre-HydrationFiles.csv"

# CSV file with download list
$FilesToDownload = "c:\Downloads\Pre-HydrationFiles.csv"

# Where to put the downloaded files
$DestinationFolder = "c:\Downloads\"

#Pre-Checks
#Verify C:\Downloads - Create if missing
if(!(test-path $DestinationFolder)){New-Item -ItemType Directory $DestinationFolder}

# Download CSV from GIT
$wc.DownloadFile($CSVFile, $FilesToDownload)

# Read content of the CSV file
$HydrationFiles = Import-csv $FilesToDownload

#Function for download with progress
function downloadFile($url, $targetFile)
{ 
    "Downloading $url" 
    $uri = New-Object "System.Uri" "$url" 
    $request = [System.Net.HttpWebRequest]::Create($uri) 
    $request.set_Timeout(15000) #15 second timeout 
    $response = $request.GetResponse() 
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024) 
    $responseStream = $response.GetResponseStream() 
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create 
    $buffer = new-object byte[] 10KB 
    $count = $responseStream.Read($buffer,0,$buffer.length) 
    $downloadedBytes = $count 
    while ($count -gt 0) 
    { 
        [System.Console]::CursorLeft = 0 
        [System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength) 
        $targetStream.Write($buffer, 0, $count) 
        $count = $responseStream.Read($buffer,0,$buffer.length) 
        $downloadedBytes = $downloadedBytes + $count 
    } 
    "`nFinished Downloading "+$targetFile 
    $targetStream.Flush()
    $targetStream.Close() 
    $targetStream.Dispose() 
    $responseStream.Dispose() 
}


# Verify paths and create needed folders
$HydrationFiles | foreach{
$source = $_.URL
    $PathTest = split-path ($DestinationFolder+$_.filename) -Parent | test-path

    if(-Not $PathTest){
    $NewFolder = Split-path ($DestinationFolder+$_.filename) -Parent 
    new-item -Path $NewFolder -type directory }
    
    
$destination = $DestinationFolder+$_.filename

# Do the download
downloadFile $source $destination

}

# Special download - ADK
write-host "Downloading ADK8.1 content - please wait a while :-) "
$ADKDownloadFolder = $DestinationFolder+"ADK8.1"
New-Item -Path $ADKDownloadFolder -type directory
$ADKDownloadCmd = "adksetup.exe /layout $ADKDownloadFolder /quiet"
$ADKDownloadCmd = $DestinationFolder+$ADKDownloadCmd
IEX "cmd /c start /wait $ADKDownloadCmd" | Out-Null

# Things still needed to be downloaded
write-host "You still need to manually download the following files:"
write-host "SQL Server 2012 Standard with SP1"
write-host "System Center 2012 R2 Configuration Manager + PreReqs"
write-host "System Center 2012 R2 Data Protection Manager"
write-host "System Center 2012 R2 Operations Manager"
write-host "System Center 2012 R2 Orchestrator"
write-host "System Center 2012 R2 Virtual Machine Manager"
write-host "Windows 7 SP1 x64"
write-host "Windows 8.1 x64"
write-host "Windows Server 2012 R2"
write-host "Link to guide is here: http://deploymentresearch.com/Research/Post/407/The-Hydration-Kit-for-System-Center-2012-R2-is-available-for-download"
}
