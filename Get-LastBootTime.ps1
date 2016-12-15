function Get-LastBootTime {
    <#
    .Synopsis
        Finds the last boot time of specified computers.
    .DESCRIPTION
        It checks the WMI LastBootUpTime object.
    .EXAMPLE
        To query a single machine.

        Get-LastBootTime -ComputerName HOSTNAME
    .EXAMPLE
        To query multiple machines.

        Get-LastBootTime -ComputerName COMPUTER1,COMPUTER2,COMPUTER3
        Get-LastBootTime -ComputerName (Get-Content C:\Scripts\Computers.txt)
        Get-LastBootTime -ComputerName (Get-Content C:\Scripts\Computers.txt) | Out-File c:\scripts\LastBootTime.txt
    .NOTES
        Created:	2016-11-14
        Author:     Mark Kerry
    #>

    [CmdletBinding()]
    param([Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true
        )]
        [string[]]
        $ComputerName = $env:ComputerName
    )

    begin {
        Write-Verbose "Starting Script..."
    }

    process {
        # Loop through each computer in the ComputerName variable.
        foreach ($Computer in $ComputerName) {
            # Check if online
            if (Test-Connection $Computer -count 1 -quiet) {
                # Query WMI for the last boot time and add to a PsCustomObject
                try {
                    $LastBootUpTime = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer | Select -Exp LastBootUpTime -ErrorAction Stop
                    $Boot = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
                    [PsCustomObject]@{
                        ComputerDisplayName = $Computer
                        LastBootUpTime = $Boot
                    }
                }
                catch {
                    Write-Warning "Failed to query WMI of $Computer"
                    Write-Warning $_.exception.message
                }
            }   
            else {
                Write-Output "$Computer is offline"
            }
        }
    }

    end {
        Write-Verbose "Script Complete..."
    }
}