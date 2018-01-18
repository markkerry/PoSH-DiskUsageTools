# PoSH-DiskUsageTools

## By Mark Kerry

### About

The PoSH-DiskUsageTools module is a collection PowerShell functions designed to check disk usage, what common areas are affected, and a few tools to clean-up disk space on Windows desktop machines.

**PoSH-DiskUsageTools** functions

***Format-OfflineFilesDB***

* What it does

***Get-DiskUsageReport***

* What it does

***Get-LastBootTime***

* What it does

***Get-LocalDiskUsage***

* What it does

***Get-LoggedOnUser***

* What it does

***Get-OstSize***

* What it does

***Remove-OldOstFiles***

* What it does

### Installation

``` powershell
# Download and unzip the PoSH-DiskUsageTools module.
# Unblock the files. E.g:
Get-ChildItem C:\PoSH-DiskUsageTools\ -Recurse | Unblock-File

# Import the module
Import-Module C:\PoSH-DiskUsageTools\PoSH-DiskUsageTools\PoSH-DiskUsageTools.psd1 -Force -Verbose
```

### Examples

#### Format-OfflineFilesDB

``` powershell
# Format-OfflineFilesDB
Format-OfflineFilesDB -ComputerName <String>
```

![Format-OfflineFilesDB](/Media/Format-OfflineFilesDB_01.png)

#### Get-DiskUsageReport

``` powershell
# Get-DiskUsageReport
Get-DiskUsageReport -ComputerName <String[]> | FT
```

![Get-DiskUsageReport](/Media/Get-DiskUsageReport_01.png)

#### Get-LastBootTime

``` powershell
# Get-LastBootTime
Get-LastBootTime -ComputerName <String>
```

![Get-LastBootTime](/Media/Get-LastBootTime_01.png)

#### Get-LocalDiskUsage

``` powershell
# Get-LocalDiskUsage
Get-LocalDiskUsage -ComputerName <String[]>
```

![Get-LocalDiskUsage](/Media/Get-LocalDiskUsage_01.png)

#### Get-LoggedOnUser

``` powershell
# Get-LoggedOnUser
Get-LoggedOnUser -ComputerName <String>
```

![Get-LoggedOnUser](/Media/Get-LoggedOnUser_01.png)

#### Get-OstSize

``` powershell
# Get-OstSize
Get-OstSize -ComputerName <String>
```

![Get-OstSize](/Media/Get-OstSize_01.png)

#### Remove-OldOstFiles

``` powershell
# Remove-OldOstFiles
Remove-OldOstFiles -ComputerName <String> -OlderThanDays <int>
```

![Remove-OldOstFiles](/Media/Get-OstSize_01.png)
