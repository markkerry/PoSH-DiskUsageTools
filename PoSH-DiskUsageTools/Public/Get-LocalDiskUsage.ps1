function Get-LocalDiskUsage { 
    <# 
    .SYNOPSIS 
        This function retrieves the size and free space of local disks on remote machines.

    .DESCRIPTION 
        A simple function to check the local disk(s) size and free space of remote servers or desktops.
        Displays the information in a PsCustomObject. 

    .PARAMETER ComputerName 
        The computer(s) name to query.

    .EXAMPLE 
        Get-LocalDiskUsage -ComputerName COMPUTER1
        
        This will query one machine
    .EXAMPLE 
        Get-LocalDiskUsage -ComputerName COMPUTER1,COMPUTER2

        This will query two machines.
    .EXAMPLE 
        Get-LocalDiskUsage -ComputerName (get-content C:\Scripts\Computers.txt)
        
        This will query all the machines in the Computers.txt file
    .NOTES
        Author: Mark Kerry

        Date:   17/11/2016
    #> 

    [CmdletBinding()] 
    param 
    ( 
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)] 
        [Alias('host,CN,Computer')] 
        [ValidateLength(3,30)] 
        [string[]]$ComputerName
    ) 
 
    # Begin by checking that PowerShell is ruuning from an elevated shell.
    begin { 
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
    } 

    process {

        Write-Output 'Retrieving disk info...'
 
        # Loop though computers. Check it's online before connection to WMI.
        foreach ($Computer in $ComputerName) {
            if ((Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
                try {
                    $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DriveType='3'"
                }
                catch {
                    Write-Error "Failed to query the WMI of $Computer."
                    Write-Warning $_.exception.message
                }
                
                # Loop through each local disk found and display in a PSCustomObject
                foreach ($disk in $disks) {
                    $Size = "$("{0:N1}" -f ($disk.Size / 1GB)) GB"
                    $FreeSpace = "$("{0:N1}" -f ($disk.FreeSpace / 1GB)) GB"
                    [PsCustomObject]@{
                        ComputerName = $Computer
                        DeviceID = $disk.DeviceID
                        Size = $Size
                        FreeSpace = $FreeSpace
                    }
                }
            }
            else {
                Write-Output "Unable to connect to $Computer"
            }
        }
    }
    end {}
}