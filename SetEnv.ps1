<# 
    File: setenv.ps1
    Author: Guillaume Plante
    Created Date: 12-09-2023
    Purpose: 
        This script sets up environment variables required for the system scripts and qBittorrentVPN.
        It ensures the required directory for "SystemScripts" exists under the ScriptsRoot environment variable,
        and then sets the environment variables for both the User and Session scopes.

    Parameters: 
        None.

    Environment Variables:
        - ScriptsRoot: Path where all script files are stored.
    
    Usage:
        Run this script to set up the environment for running other system scripts.
    
    Example:
        .\setenv.ps1
    
    Note:
        Ensure that the "ScriptsRoot" environment variable is properly set before executing this script.
#>

try {
    # Check if ScriptsRoot is set
    if ([string]::IsNullOrEmpty("$ENV:ScriptsRoot")) {
        throw "no ENV:ScriptsRoot value"
    }

    # Construct SystemScriptsPath
    $SystemScriptsPath = Join-Path "$ENV:ScriptsRoot" "SystemScripts"
    
    # Ensure SystemScripts directory exists
    if (-not (Test-Path "$SystemScriptsPath")) {
        Write-Host "Creating SystemScripts directory at: $SystemScriptsPath"
        New-Item -Path "$SystemScriptsPath" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    } else {
        Write-Host "SystemScripts directory already exists at: $SystemScriptsPath"
    }

    # Set environment variables (User scope)
    Write-Host "Setting User environment variables..."
    Set-EnvironmentVariable -Name "QBITTORRENTVPN_ADDRESS" -Value "10.0.0.111" -Scope User
    Set-EnvironmentVariable -Name "QBITTORRENTVPN_PORT" -Value "8080" -Scope User
    Set-EnvironmentVariable -Name "SYSTEM_SCRIPTS_PATH" -Value "$SystemScriptsPath" -Scope User

    # Set environment variables (Session scope)
    Write-Host "Setting Session environment variables..."
    Set-EnvironmentVariable -Name "QBITTORRENTVPN_ADDRESS" -Value "10.0.0.111" -Scope Session
    Set-EnvironmentVariable -Name "QBITTORRENTVPN_PORT" -Value "8080" -Scope Session
    Set-EnvironmentVariable -Name "SYSTEM_SCRIPTS_PATH" -Value "$SystemScriptsPath" -Scope Session

    Write-Host "Environment setup completed successfully."

} catch {
    Write-Warning ($_)
}
