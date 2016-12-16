function Get-DiskUsageReport { 
    <# 
    .SYNOPSIS 
        This function retrieves the sizes of the local hard disk and its common areas of usage.

    .DESCRIPTION 
        First it checks the machine is online before querying the C: drive size, free space, OST file sizes, SCCM Cache and Windows Search db.

    .PARAMETER computername 
        The computer name to query.

    .EXAMPLE 
        Get-DiskUsageReport -ComputerName COMPUTER1 | FT
        Get-DiskUsageReport -ComputerName COMPUTER1 | Out-File C:\Temp\DiskReport.txt
        Get-DiskUsageReport -ComputerName COMPUTER1 | Out-GridView
        Get-DiskUsageReport -ComputerName COMPUTER1 | Export-Csv -Path "C:\Temp\DiskUsage.csv" -NoTypeInformation
        Get-DiskUsageReport -ComputerName COMPUTER1,COMPUTER2 | ConvertTo-HTML | Out-File "C:\Temp\DiskUsage.html"
        
        This will query one machine
    .EXAMPLE 
        Get-DiskUsageReport -ComputerName COMPUTER1,COMPUTER2 | FT
        
        This will query two machines. I recommend piping to Format-Table for nicer view
    .EXAMPLE 
        Get-DiskUsageReport -ComputerName (get-content C:\Scripts\Computers.txt) | FT
        
        This will query all the machines in the Computers.txt file
    .NOTES
        Author: Mark Kerry
        Date:   01/12/2016
    #> 

    [CmdletBinding()] 
    param 
    ( 
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)] 
        [ValidateLength(3,30)] 
        [string[]]$ComputerName
    ) 
 
    # Check you're running this function from an elevated shell
    begin { 
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
    } 
 
    process { 

        Write-Output 'Retrieving disk info...'
        # loop through each computer
        foreach ($Computer in $ComputerName) {
            # Test connectivity to machine
            if ((Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue)) {
                # Check the machine's C:\ drive total size and free space
                try {
                    $disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter "DeviceID='C:'" | Select-Object Size,FreeSpace
                    $DriveSize = "$("{0:N2}" -f ($disk.Size / 1GB)) GB"
                    $FreeSpace = "$("{0:N2}" -f ($disk.FreeSpace / 1GB)) GB"
                }
                catch {
                    Write-Error "Failed to query the WMI of $Computer."
                    $DriveSize = $null
                    $FreeSpace = $null
                }

                # Check for any locally caches Outlook OST files and their total combined size
                $a = "\\$Computer\C$\Users"
                $b = $null
                try {
                    Get-ChildItem -Path $a | Select -ExpandProperty Name | ForEach-Object {
                        $Ost = Get-ChildItem -Path "$a\$_\AppData\Local\Microsoft\Outlook\*.ost" -ErrorAction SilentlyContinue
                        if (-not($Ost -eq $null)) {
                            $b += $Ost.Length
                        }
                    }
                    $OstSize = "$("{0:N2}" -f ($b / 1GB)) GB"
                }
                catch {
                    $OstSize = $null
                }

                # Check the SCCMCache size
                try {
                    $CCMDir = "C$\Windows\ccmcache"
                    $objFSO = New-Object -com  Scripting.FileSystemObject
                    $CCMCache = "{0:N2}" -f (($objFSO.GetFolder("\\$Computer\$CCMDir").Size) / 1GB) + " GB"
                }
                catch {
                    $CCMCache = $null
                }
                
                # Check the WindowsSearch index size which can grow quite large
                try {
                    $WSearchDir = "C$\ProgramData\Microsoft\Search\Data\Applications\Windows"
                    $objFSO2 = New-Object -com  Scripting.FileSystemObject
                    $WSearch = "{0:N2}" -f (($objFSO2.GetFolder("\\$Computer\$WSearchDir").Size) / 1GB) + " GB"
                }
                catch {
                    $WSearch = $null
                }

                # List Report in a PsCustomObject
                [PsCustomObject]@{
                    ComputerName = $Computer
                    DeviceID = "C:\"
                    Size = $DriveSize
                    FreeSpace = $FreeSpace
                    TotalOstSize = $OstSize
                    SCCMCache = $CCMCache
                    WindowsSearch = $WSearch
                }
            }
            else {
                Write-Output "Unable to connect to $Computer."
            }
        }
    }
    end {}
}