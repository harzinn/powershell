# Get the webcam device instance ID
$webcam = Get-PnpDevice | Where-Object {$_.Class -eq 'Camera' -or $_.Class -eq 'Image'}

# Enable the webcam
if ($webcam -ne $null) {
    Enable-PnpDevice -InstanceId $webcam.InstanceId -Confirm:$false
    Write-Host "Webcam enabled"
} else {
    Write-Host "Webcam not found"
}
