$adapterName = "Ethernet 3"

$enable = Read-Host "Do you want to enable the Ethernet adapter? (Y/N)"

if ($enable -eq "Y") {
    Enable-NetAdapter -Name $adapterName
    Write-Host "Ethernet adapter has been enabled." -ForegroundColor Green
} elseif ($enable -eq "N") {
    Disable-NetAdapter -Name $adapterName
    Write-Host "Ethernet adapter has been disabled." -ForegroundColor Green
} else {
    Write-Host "Invalid input. Please enter Y or N." -ForegroundColor Red
}
