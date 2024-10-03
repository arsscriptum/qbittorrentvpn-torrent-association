<# 
    File: Install.ps1
    Author: [Your Name]
    Created Date: [Date]
    Purpose: 
        This script installs the "Invoke-DownloadTorrentFile" functionality by copying the script 
        to the SYSTEM_SCRIPTS_PATH directory, checking for administrative privileges, and adding 
        a context menu option for ".torrent" files.

    Usage:
        Run this script to set up the file association and context menu for .torrent files.

    Requirements:
        - SYSTEM_SCRIPTS_PATH environment variable must be set.
        - Administrator privileges are required to modify registry settings.
#>

# Function to check if the script is running as Administrator
function Test-Administrator {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Main script logic
try {
    # Check if the user has administrator privileges
    if (-not (Test-Administrator)) {
        throw "This script must be run as an administrator."
    }

    # Check if SYSTEM_SCRIPTS_PATH is set
    if ([string]::IsNullOrEmpty("$ENV:SYSTEM_SCRIPTS_PATH")) {
        throw "Environment variable SYSTEM_SCRIPTS_PATH is not set. Please set it up before running the script."
    }

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

    # Define source and target paths
    $sourcePath = "$PSScriptRoot\Invoke-DownloadTorrentFile.ps1"
    $targetPath = Join-Path -Path $ENV:SYSTEM_SCRIPTS_PATH -ChildPath "Invoke-DownloadTorrentFile.ps1"

    # Check if the source script exists
    if (-not (Test-Path -Path $sourcePath)) {
        throw "The script 'Invoke-DownloadTorrentFile.ps1' does not exist in the current directory."
    }

    # Copy the script to the SYSTEM_SCRIPTS_PATH directory
    Write-Host "Copying 'Invoke-DownloadTorrentFile.ps1' to $targetPath"
    Copy-Item -Path $sourcePath -Destination $targetPath -Force

    # Define the command for the context menu option
    $command = "pwsh.exe -Noni -Nop -WindowStyle Hidden -File `"$targetPath`" -Path `"%1`""

    # Create a registry entry for the context menu option
    Write-Host "Creating context menu option for .torrent files..."

    # Define registry paths for context menu
    $contextMenuKey = "HKCR:\SystemFileAssociations\.torrent\shell\download_with_qbittorrentvpn"
    $shellCommandKey = "$contextMenuKey\command"

    # Create registry keys for .torrent context menu
    New-Item -Path $contextMenuKey -Force | Out-Null
    Set-ItemProperty -Path $contextMenuKey -Name "(default)" -Value "Download with QBittorrentVPN" -Force

    # Set the command to execute the script with the selected torrent file path
    New-Item -Path $shellCommandKey -Force | Out-Null
    Set-ItemProperty -Path $shellCommandKey -Name "(default)" -Value $command -Force

    Write-Host "Context menu option created successfully. Right-click on .torrent files to use 'Download with QBittorrentVPN'."

} catch {
    Write-Warning "An error occurred: $_"
}
