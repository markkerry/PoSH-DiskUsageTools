function Remove-OldOstFiles { 
    <# 
    .SYNOPSIS 
        This function removes Outlook OST files not modified in the specified anount of days.
    .DESCRIPTION 
        First it checks the machine is online before querying each OST file. If the ost has not been modified within the specified number of days it will be deleted.
    .PARAMETER computername 
        The computer name to query.
    .PARAMETER OlderThanDays 
        The amount in days in which the ost hasn't been modified will get deleted. Only available in days: 30, 60, 90, 120. You can change this.
    .EXAMPLE 
        This will action on one machine

        Remove-OldOstFiles -ComputerName COMPUTER1 -OlderThanDays 30
    .EXAMPLE 
        This will action on multiple machines.
        
        Remove-OldOstFiles -ComputerName COMPUTER1,COMPUTER2 -OlderThanDays 60
        Remove-OldOstFiles -ComputerName (Get-Content C:\Scripts\Computers.txt) -OlderThanDays 90
    .NOTES
        Author: Mark Kerry
        Date:   17/11/2016
    #> 

    [CmdletBinding()] 
    param 
    ( 
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True,
                   Position=0)] 
        [string[]]$ComputerName,

        [Parameter(Mandatory=$True,
                   Position=1)]
        [ValidateSet("30","60","90","120")]
        [string]$OlderThanDays 
    ) 
 
    # Check for elevation
    begin { 
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
            break
        }
    } 
 
    process { 
        # Set the number of days ago from today
        $date = (Get-Date).AddDays(-$OlderThanDays)

        # Loop through each computer in the ComputerName variable
        foreach ($Computer in $ComputerName) {
            #Check it's online
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                Write-Output "Deleting .ost files from $Computer which haven't been used in the last $OlderThanDays days."
                # Set the directory
                $d = "\\$Computer\C$\Users"
                try {
                    # Find each user profile in the Users directory
                    Get-ChildItem -Path $d -ErrorAction Stop | Select -ExpandProperty Name | ForEach-Object {
                        # For each object, get the outlook OST file and if not been modified in the amount of days specified remove it.
                        $Ost = Get-ChildItem -Path "$d\$_\AppData\Local\Microsoft\Outlook\*.ost" -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -lt $date} | Remove-Item -Verbose
                    }
                }
                catch {
                    Write-Warning $_.exception.message
                }
            }
            else {
                Write-Output "Unable to connect to $Computer."
            }
        }
    }
    end {}
}