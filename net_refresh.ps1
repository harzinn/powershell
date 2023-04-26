# Function to refresh a single network adapter
function Refresh-NetworkAdapter {
    param (
        [Parameter(Mandatory=$true)]
        $Adapter
    )

    # Disable the adapter
    Write-Host "Disabling $($Adapter.Name)..."
    Disable-NetAdapter -Name $Adapter.Name -Confirm:$false

    # Enable the adapter
    Write-Host "Enabling $($Adapter.Name)..."
    Enable-NetAdapter -Name $Adapter.Name -Confirm:$false

    # Release the current DHCP lease
    Write-Host "Releasing DHCP lease for $($Adapter.Name)..."
    ipconfig /release $($Adapter.ifIndex)

    # Renew the DHCP lease
    Write-Host "Renewing DHCP lease for $($Adapter.Name)..."
    ipconfig /renew $($Adapter.ifIndex)
}

# Get all network adapters
$adapters = Get-NetAdapter

# Create an array to store jobs
$jobs = @()

# Loop through each adapter
foreach ($adapter in $adapters) {
    # Start a new job to refresh the adapter
    $job = Start-Job -ScriptBlock ${function:Refresh-NetworkAdapter} -ArgumentList $adapter
    $jobs += $job
}

# Wait for all jobs to complete
Wait-Job -Job $jobs

# Collect and display job results
$results = Receive-Job -Job $jobs
Write-Host $results

# Clean up jobs
Remove-Job -Job $jobs

Write-Host "Network interfaces have been refreshed."
