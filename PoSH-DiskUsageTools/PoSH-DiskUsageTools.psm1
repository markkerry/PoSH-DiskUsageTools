if ($PSVersionTable.PSEdition -eq 'Core') {
    Write-Warning "This function is not compatible with PowerShell Core as it reiles on the MSI module binaries."
    break
}

# Get Public and private functions
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach ($function in @($Public + $Private)) {
    try {
        . $function.Fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($function.Fullname): $_"
    }
}