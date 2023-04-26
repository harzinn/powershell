# Get all display adapters
$displayAdapters = Get-PnpDevice -Class Display

# Disable and re-enable each display adapter
foreach ($adapter in $displayAdapters) {
    # Disable the adapter
    Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
    
    # Wait a moment
    Start-Sleep -Seconds 3
    
    # Re-enable the adapter
    Enable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
}
