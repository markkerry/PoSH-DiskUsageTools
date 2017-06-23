
function Get-LoggedOnUser {
    <#
    .Synopsis
        Displays the currently logged on user of a machine(s).
    .DESCRIPTION
        This function allows you to remotely check who is logged onto a machine.
    .PARAMETER ComputerName
        The computer(s) you want to query.
    .EXAMPLE
        Get-LoggedOnUser -ComputerName COMPUTER1
        
        Check who is logged onto a single machine.
    .EXAMPLE
        Get-LoggedOnUser -ComputerName (Get-Content C:\Scripts\Computers.txt)
        
        Check who is logged onto multiple machines.
    .EXAMPLE 
        Get-LoggedOnUser -ComputerName COMPUTER1,COMPUTER2,COMPUTER3
        
        Check who is logged onto multiple machines.
    .NOTES
        Created:	2017-06-23            

        Author:     Mark Kerry
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String[]]$ComputerName
    )

    begin {
        # Check for elevation
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
    }

    process {
        # Loop through each computer in the ComputerName parameter.    
        foreach ($Computer in $ComputerName) {
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                $a = Get-WmiObject Win32_ComputerSystem -ComputerName $Computer
                $b = $a.PSComputerName
                $c = $a.UserName
                if (!($c)) {
                    $c = 'NoLoggedOnUser'
                }
            }
            else {
                $b = $Computer
                $c = 'OFFLINE'
            }
            [PsCustomObject]@{
                "ComputerName" = $b
                "Current Logged On User Name" = $c
            }
        }
    }
}
