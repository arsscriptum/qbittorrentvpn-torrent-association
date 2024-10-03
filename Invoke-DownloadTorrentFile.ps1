<#
    Script: Invoke-DownloadTorrentFile.ps1
    Author: Guillaume Plante
    Created Date: 12-09-2023
    Purpose: 
        This script adds a torrent file to the download list of a qBittorrentVPN server
        by sending the .torrent file using qBittorrent's Web API.

    Parameters:
        -Path [string] (Mandatory): The path to the torrent file to be added.
        -ServerAddress [string] (Optional): The address of the qBittorrentVPN server. Default is '10.0.0.111'.
        -ServerPort [int] (Optional): The port of the qBittorrentVPN server. Default is 8080.

    Usage:
        pwsh.exe -File "Invoke-DownloadTorrentFile.ps1" -Path "C:\path\to\torrent.torrent"
        pwsh.exe -File "Invoke-DownloadTorrentFile.ps1" -Path "C:\path\to\torrent.torrent" -ServerAddress "192.168.1.100" -ServerPort 8081
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$ServerAddress = "10.0.0.111",

    [int]$ServerPort = 8080
)

# Load the System.Windows.Forms assembly for using message boxes
Add-Type -AssemblyName System.Windows.Forms

# Construct the full URL for adding a torrent
$url = "http://$ServerAddress`:$ServerPort/api/v2/torrents/add"

# Check if the specified torrent file exists
if (-not (Test-Path -Path $Path)) {
    [System.Windows.Forms.MessageBox]::Show("The torrent file at '$Path' does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}

try {
    # Prepare the form data
    $formData = @{
        "torrents" = Get-Item -Path $Path
    }

    # Write verbose logging
    Write-Host "Starting the process to add the torrent file '$Path' to server at $ServerAddress on port $ServerPort."

    # Send the POST request to add the torrent
    $response = Invoke-WebRequest -Uri $url -Method Post -Form $formData

    # Check if the response indicates success
    if ($response.StatusCode -eq 200) {
        $result = [System.Windows.Forms.MessageBox]::Show("Torrent added successfully! Open QBitTorrentVPN?", "Success", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Information)
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # Construct the URL to open qBittorrentVPN
            $webUrl = "http://$ServerAddress`:$ServerPort"
            Start-Process -FilePath $webUrl
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Failed to add torrent. Server responded with status code $($response.StatusCode).", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }

} catch {
    [System.Windows.Forms.MessageBox]::Show("An error occurred while trying to add the torrent: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}

Write-Host "Script execution completed."
