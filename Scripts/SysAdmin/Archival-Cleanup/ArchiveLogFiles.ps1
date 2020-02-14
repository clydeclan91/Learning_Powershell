#Archive Log Files to Specified Folder

#Determine File Age To Archive.  I archive files older than one month.
$limit = (Get-Date).AddMonths(-1)

#Specify Log File Folder
$basePath = "YourLocationHere"
#Specify desired archive location (Ideally different than log file location)
$archivePath = "ArchiveLocationHere"
#Choose a prefix for your archive file
$prefix = "PrefixHere"

$filesToZip = get-childItem -Path $basePath\*.* | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit }
if($filesToZip.count -gt 0)
{
    Add-Type -assembly System.IO.Compression.FileSystem
    $zipFileName = $archivePath + "\" + $prefix + $(Get-Date (Get-Date).AddMonths(-2) -f yyyy-MM) + ".zip"
    $zipFileHeader = (“PK” + [char]5 + [char]6 + (“$([char]0)” * 18))
    if(-not (test-path($zipfilename)))
    {
        Set-Content $zipFileName $zipFileHeader
    }
    $zip = [System.IO.Compression.ZipFile]::Open($zipFileName, "Update")
    Foreach($zipEntry in $filesToZip)
    {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $zipEntry.FullName, $zipEntry.Name)
        Remove-Item $zipEntry.FullName
    }
    $zip.Dispose()
}