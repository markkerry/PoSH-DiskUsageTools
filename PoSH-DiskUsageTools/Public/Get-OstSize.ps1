function Get-OstSize { 
    <# 
    .SYNOPSIS 
        This function retrieves the sizes of Outlook OST files on a machine.
    .DESCRIPTION 
        First it checks the machine is online before querying each user profile on the machine for an OST file.
    .PARAMETER computername 
        The computer name to query.
    .EXAMPLE 
        . .\Get-OstSize.PS1
        This loads the function. Next you type the cmdlet.

        Get-OstSize -ComputerName COMPUTER1 | FT
        This will query one machine
    .EXAMPLE 
        Get-OstSize -ComputerName COMPUTER1, COMPUTER2 | FT
        This will query two machines. I recommend piping to Format-Table for an easier view

        Get-OstSize -ComputerName (get-content C:\Scripts\Computers.txt) | FT
        This will query all the machines in the Computers.txt file
    .NOTES
        Author: Mark Kerry
        Date:   23/09/2016
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
 
    # Begin for elevation
    begin { 
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
    } 
 
    process { 
        # Loop through each computer in the ComputerName variable
        foreach ($Computer in $ComputerName) {
            # Check it's online
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                # Set the users path
                $d = "\\$Computer\C$\Users"
                # Get the name of each folder in the Users directory and for each object check if an outlook ost file exists
                Get-ChildItem -Path $d | Select -ExpandProperty Name | ForEach-Object {
                    $Ost = Get-ChildItem -Path "$d\$_\AppData\Local\Microsoft\Outlook\*.ost" -ErrorAction SilentlyContinue
                    if (-not($Ost -eq $null)) {
                        if ($Ost.Length -lt 1GB) {                       
                            $Size = "$("{0:N2}" -f ($Ost.Length / 1MB)) MB" 
                        }
                        elseif ($Ost.Length -lt 1TB) {                       
                            $Size = "$("{0:N2}" -f ($Ost.Length / 1GB)) GB" 
                        }
                        # List each ost file in a PsCustomObject.
                        [PsCustomObject]@{
                            ComputerName = $Computer
                            UserName = $_
                            OstName = $Ost.Name
                            OstSize = $Size
                            LastWriteTime = $Ost.LastWriteTime
                        }
                    }
                }
            }
            else {
                Write-Error "Unable to connect to $Computer"
            }
        }
    } End {}
} 
