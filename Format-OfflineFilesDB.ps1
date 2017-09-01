function Format-OfflineFilesDB {
    <# 
    .Synopsis
        Creates a registry key to Format the Offline files DB.
    .DESCRIPTION
        This script will create the required registry key on a remote machine.
        Once the computer restarted the C:\WIndows\CSC directory will be cleared
        down and the registry key will be deleted. Offline Files has to be enabled
        for this to work.
    .PARAMETER computername 
        The computer name to query.
    .EXAMPLE
        Format-OfflineFilesDB -ComputerName COMPUTER1

        Format the Offline files database on COMPUTER1
    .EXAMPLE
        Format-OfflineFilesDB -ComputerName COMPUTER1 -Verbose
        
        Use the Verbose common parameter for more information of the scripts activity
    .NOTES 
        Author:     Mark Kerry
        Date:       01/09/2017
        Version:    1.0 - Initial version 
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
        HelpMessage='Please enter a Computer Name.')]
        [string]
        $ComputerName
    )

    function Get-ElevationStatus {
        if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
        else {
            Write-Verbose "Running with the required elevated priviledges"
        }
    }
    Get-ElevationStatus

    function Test-MachineOnline {
        if (!(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
            Write-Output "$ComputerName is offline."
            break
        }
        else {
            Write-Verbose "$ComputerName is online."
        }
    }
    Test-MachineOnline

    function Start-RemoteRegistryService {
        $service = 'RemoteRegistry'
        Write-Verbose "Checking the $service service is running on $ComputerName"
        $RemoteRegistry = (Get-Service -ComputerName $ComputerName -Name $Service)
        if ($RemoteRegistry.Status -ne 'Running') {
            Write-Verbose "$service service is not running on $ComputerName. Attempting to start the service"
            try {
                $RemoteRegistry | Set-Service -StartupType Automatic
                Start-Sleep 1
                $RemoteRegistry | Start-Service
                Start-Sleep 1
            }
            catch {
                Write-Output "Failed to start the $service service on $ComputerName"
                break
            }
            Write-Verbose "Started the $service service on $ComputerName"
        }
        else {
            Write-Verbose "$service service is running on $ComputerName"
        }
    }
    Start-RemoteRegistryService

    function Set-RegKey {
        Write-Verbose "Creating the reg DWORD to Format the OfflineFiles DB on $ComputerName..."
        try {
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$ComputerName)
        }
        catch {
            Write-Output "Failed to connect to the remote registry of $ComputerName"
            break
        }
        $RegKey = $Reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Services\\Csc\\Parameters",$true)
        $ValueName = "FormatDatabase"
        $Value = 1
        try {
            $RegKey.SetValue($ValueName,$Value,[Microsoft.Win32.RegistryValueKind]::DWORD)
            Write-Verbose "Successfully changed the reg key on $Computername."
            Write-Output "Script complete. Once $ComputerName has restarted the Offline Files DB will be reset."
        }
        catch {
            Write-Output "Failed to modify the registry of $ComputerName"
        }
    }    
    Set-RegKey 
}