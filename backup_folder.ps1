<#
.SYNOPSIS
    A PowerShell script to create a timestamped ZIP backup of a specified folder.

.DESCRIPTION
    This script automates the process of creating a timestamped ZIP archive of a
    source folder provided as a command-line argument. The resulting ZIP file
    will be named with the format: YYYYMMDDHHMMSS-BKP-[FolderName].zip, where
    [FolderName] is the last part of the source folder's path, containing only
    alphanumeric characters and underscores. The ZIP file is saved in the
    directory where the script is executed.
    
.REQUIREMENTS
    - PowerShell 5.0 or newer (for the Compress-Archive cmdlet).
    - The script must be run with appropriate permissions to access the source folder.


.PARAMETER SourceFolder
    The full path to the folder you wish to backup.
    This parameter is mandatory and should be the first argument when running the script.

.EXAMPLE 1
    .\backup_folder.ps1 "C:\Users\<YourUser>\Documents\My Project"
    Description: Backs up the "My Project" folder, creating a file like
                 20250623143000-BKP-My_Project.zip.

.EXAMPLE 2
    .\backup_folder.ps1 "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data"
    Description: Backs up the Google Chrome User Data folder, creating a file like
                 20250623143000-BKP-User_Data.zip.

.EXAMPLE 3
    .\backup_folder.ps1 "D:\localdata\"
    Description: Backs up the Google Chrome User Data folder, creating a file like
                 20250623143000-BKP-localdata.zip.

.NOTES
    - Requires PowerShell 5.0 or newer for the Compress-Archive cmdlet.
      (Windows 10, Windows Server 2016 and later typically have this by default).
    - Ensures the source folder exists before attempting to create the archive.
    - Provides error messages if the source folder does not exist or if the backup fails.
    - If no source folder is provided, PowerShell will automatically prompt you for it.
    - Does not provide a real-time progress bar due to Compress-Archive limitations,
      but shows source size and 'Please wait' message.

.LICENSING: 
    This script is provided "as is" without warranty of any kind.
    You may use and modify it for personal or commercial purposes. 
    You can be nice and credit the original author if you distribute it.

#>

#region Parameter and Argument Handling
[CmdletBinding()] # Allows for advanced function features like common parameters
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SourceFolder # This parameter is now strictly mandatory.
)

# PowerShell's built-in parameter binding handles the 'no argument' case by prompting.
# If the script continues past the param block, $SourceFolder will have a value.

#endregion

#region Variable Definitions
# Generate timestamp for filename (YYYYMMDDHHMMSS)
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# Extract the last part of the SourceFolder path (the actual folder name)
# Remove trailing backslashes/slashes for consistent splitting
$folderName = (Split-Path -Path $SourceFolder -Leaf)

# Sanitize the folder name to contain only letters, numbers, and underscores
# Replace any character that is NOT a letter (a-z, A-Z), number (0-9), or underscore (_) with an underscore.
# Ensure that if multiple non-alphanumeric characters are adjacent, they are replaced by a single underscore
# Trim leading/trailing underscores that might result from sanitization
$sanitizedFolderName = ($folderName -replace '[^a-zA-Z0-9_]', '_' | ForEach-Object { $_ -replace '__+', '_' } | ForEach-Object { $_.Trim('_') })

# Construct the new backup file name: YYYYMMDDHHMMSS-BKP-[FolderName].zip
# Ensure that if the sanitized folder name is empty (e.g., if SourceFolder was just a drive letter),
# we don't have a leading hyphen before .zip.
$backupFileName = "${timestamp}-BKP"
if (-not [string]::IsNullOrEmpty($sanitizedFolderName)) {
    $backupFileName = "${backupFileName}-${sanitizedFolderName}"
}
$backupFileName = "${backupFileName}.zip"


# Get the current directory to save the zip file
$currentDirectory = Get-Location

# Construct the full path for the backup file
$backupFilePath = Join-Path -Path $currentDirectory -ChildPath $backupFileName
#endregion

#region Pre-Backup Checks
# Check if source folder exists
if (-not (Test-Path -Path $SourceFolder -PathType Container)) {
    Write-Host "`nError: Source folder '$SourceFolder' does not exist or is inaccessible.`n" -ForegroundColor Red
    Write-Host "Please verify the path."
    Write-Host ""
    Pause
    exit 1
}
#endregion

#region Backup Process
Write-Host "`nStarting backup process..." -ForegroundColor Cyan

# Optional: Calculate and display the total size of the source folder
Write-Host "Calculating total size of '$SourceFolder'..." -ForegroundColor DarkGray
try {
    # Get all files recursively and sum their lengths
    $totalBytes = (Get-ChildItem -LiteralPath $SourceFolder -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum).Sum

    # Convert bytes to a human-readable format (e.g., KB, MB, GB)
    $sizeDisplay = ""
    if ($totalBytes -ge 1TB) { $sizeDisplay = "$([math]::Round($totalBytes / 1TB, 2)) TB" }
    elseif ($totalBytes -ge 1GB) { $sizeDisplay = "$([math]::Round($totalBytes / 1GB, 2)) GB" }
    elseif ($totalBytes -ge 1MB) { $sizeDisplay = "$([math]::Round($totalBytes / 1MB, 2)) MB" }
    elseif ($totalBytes -ge 1KB) { $sizeDisplay = "$([math]::Round($totalBytes / 1KB, 2)) KB" }
    else { $sizeDisplay = "$totalBytes Bytes" }

    Write-Host "Total source size: $sizeDisplay" -ForegroundColor Green
} catch {
    Write-Warning "Could not calculate source folder size: $($_.Exception.Message)"
}

Write-Host "Starting compression, please wait... This may take a while for large folders." -ForegroundColor DarkYellow
Write-Host "" # Add an empty line for readability

try {
    # Compress-Archive creates a zip archive.
    # -Path "$SourceFolder\*" includes all files and subfolders within the source.
    # -DestinationPath specifies the output archive filename and path.
    # -CompressionLevel Fastest for quicker backups, can be 'NoCompression', 'Fastest', 'Optimal'.
    # -Force overwrites existing zip file with the same name if it exists.
    # -ErrorAction Stop ensures that any critical errors stop the command and trigger the catch block.
    # -WarningAction SilentlyContinue suppresses the 'LastWriteTime earlier than 1980' warnings.
    Compress-Archive -Path "$SourceFolder\*" -DestinationPath $backupFilePath -CompressionLevel Fastest -Force -ErrorAction Stop -WarningAction SilentlyContinue

    Write-Host "`nBackup completed successfully!" -ForegroundColor Green
    Write-Host "Created: $backupFilePath"
    Write-Host "Source:  `"$SourceFolder`"" # Add quotes for clarity if path has spaces
    Write-Host ""
}
catch {
    Write-Host "`nAn error occurred during backup:`n" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
}

#endregion

#region Script Completion
Pause
#endregion
