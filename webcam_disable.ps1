# Get the webcam device instance ID
$webcam = Get-PnpDevice | Where-Object {$_.Class -eq 'Camera' -or $_.Class -eq 'Image'}

# Disable the webcam
if ($webcam -ne $null) {
    Disable-PnpDevice -InstanceId $webcam.InstanceId -Confirm:$false
    Write-Host "Webcam disabled"
} else {
    Write-Host "Webcam not found"
}
