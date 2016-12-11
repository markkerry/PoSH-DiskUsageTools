function Reset-WindowsSearch {    
    <#
    .Synopsis
        Rebuild large Windows search indexes
    .DESCRIPTION
        Used in to rebuild the Windows.edb file. Connection to remote machine is verified, Size of dir is displayed.
        Service is stopped, file deleted and size of the dir is displayed again. index will rebuild next time the WSearch service is started.
    .EXAMPLE
        Reset-WindowsSearch -ComputerName COMPUTER1

        This will delete the Windows.edb file on one machine
    .EXAMPLE
        Reset-WindowsSearch -ComputerName COMPUTER1,COMPUTER2

        This will delete the Windows.edb file on two machines
    .EXAMPLE
        Reset-WindowsSearch -ComputerName (Get-Content C:\Scripts\Computers.txt)

        This will delete the Windows.edb file from every machine in the Computers.txt file.
    .NOTES
        Created:	2016-03-16
        Version:    1.0 - Intial version
                    1.1 - 07/06/2016 - Restructured script and took out restarting the service to allow Windows to do it at next boot.
                    1.2 - 18/07/2016 - Changed to -ComputerName parameter
        
        Author - Mark Kerry
    #>

    # Parameters to run the script
    [CmdletBinding(SupportsShouldProcess=$True)]
    param 
    (
        [Parameter(Mandatory=$true)]
        [string] $ComputerName
    )

    begin {
        # Check for elevation
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            return
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            
            # Test machine connectivity
            if ((Test-Connection $Computer -count 1 -quiet)) {
                
                $Dir = "C$\ProgramData\Microsoft\Search\Data\Applications\Windows"
                $edb = "$Computer\$Dir\Windows.edb"
                
                # Check if an index file exists. Directory will exist but index won't if already been disabled
                if ((Test-Path -Path "\\$edb")) {

                    # Display size of the directory the index is in before deleting
                    Write-Output "Current size of \\$Computer\$Dir is:"
                    $objFSO = New-Object -com  Scripting.FileSystemObject
                    "{0:N2}" -f (($objFSO.GetFolder("\\$Computer\$Dir").Size) / 1MB) + " MB"
                    
                    # Check the Wsearch service and stop it if running
                    $S = Get-Service -Name WSearch -ComputerName $Computer
                    if ($S.Status -eq "Running") {
                        Write-Output "WSearch service is Running on $Computer, stopping service"
                        $S.Stop()
                        Start-Sleep -Seconds 15
                    } 
                    elseif ($S.status -eq "Stopped") {
                        Write-Output "$S.name is not running on $Computer"
                    }
                    else {
                        Write-Warning "Unable to determine the $S.name state"
                        break
                    }
                
                    Write-Output "Deleting the Windows.edb file"
                    Remove-Item -Path \\$edb -Force -Verbose

                    # Pause script for 5 seconds
                    Write-Output "Please Wait..."
                    Start-Sleep -Seconds 5
                    Write-Output "Size of \\$Computer\$Dir after index deletion is:"
                    $objFSO = New-Object -com  Scripting.FileSystemObject
                    "{0:N2}" -f (($objFSO.GetFolder("\\$Computer\$Dir").Size) / 1MB) + " MB"
                    Write-Output "The WSearch service will start at next boot and the file will start to rebuild"
                    Write-Output "Script Complete..."  
                }
                else {
                    Write-Output "$edb not found."
                }
            }
            else {
                Write-Output "Connection to $Computer failed."
            }
        }
    }
    end {}
}
