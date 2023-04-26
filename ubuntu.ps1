# Check if the current PowerShell session is running as Administrator
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isElevated) {
    # If not running as Administrator, start a new PowerShell session with elevated privileges
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Get all network adapters including hidden ones
$adapters = Get-NetAdapter -IncludeHidden

# Find the Hyper-V Virtual Ethernet Adapter by description
$hyperVAdapter = $adapters | Where-Object { $_.InterfaceDescription -eq "Hyper-V Virtual Ethernet Adapter" }

if ($hyperVAdapter) {
    # Get the interface index of the Hyper-V adapter
    $interfaceIndex = $hyperVAdapter.ifIndex

    # Check if the IP address is already assigned
    $existingIPAddress = Get-NetIPAddress -IPAddress 172.29.16.1 -ErrorAction SilentlyContinue

    if ($existingIPAddress) {
        # Remove the existing IP address
        Remove-NetIPAddress -IPAddress 172.29.16.1 -Confirm:$false
    }

    # Check if the default gateway is already assigned
    $existingDefaultGateway = Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Where-Object { $_.NextHop -eq '172.29.16.254' }

    if ($existingDefaultGateway) {
        # Remove the existing default gateway
        Remove-NetRoute -DestinationPrefix 0.0.0.0/0 -NextHop 172.29.16.254 -Confirm:$false
    }

    # Create a new IP address with the specified parameters
    New-NetIPAddress -InterfaceIndex $interfaceIndex -IPAddress 172.29.16.1 -PrefixLength 28 -DefaultGateway 172.29.16.254

    Write-Host "IP address and gateway have been set for the Hyper-V Virtual Ethernet Adapter."
} else {
    Write-Host "Hyper-V Virtual Ethernet Adapter not found."
}
# This script checks to see if a Hyper-V named Ubuntu is started, and if it is not, starts it. Then, it SSH into it.

# Check if the Hyper-V service is running
$hyperVService = Get-Service -Name "vmms"
if ($hyperVService.Status -eq "Running") {

  # The Hyper-V service is running, so check if the Ubuntu VM is started
  $UbuntuVM = Get-VM -Name "Ubuntu"
  if ($UbuntuVM.State -eq "Running") {

    # The Ubuntu VM is already started, so do nothing
    Write-Host "The Ubuntu VM is already started."
  } else {

    # The Ubuntu VM is not started, so start it
    Start-VM -Name "Ubuntu"
  }
} else {

  # The Hyper-V service is not running, so start it
  Start-Service -Name "vmms"

  # After the Hyper-V service is started, check if the Ubuntu VM is started
  $UbuntuVM = Get-VM -Name "Ubuntu"
  if ($UbuntuVM.State -eq "Running") {

    # The Ubuntu VM is already started, so do nothing
    Write-Host "The Ubuntu VM is already started."
  } else {

    # The Ubuntu VM is not started, so start it
    Start-VM -Name "Ubuntu"
  }
}

# Wait for 30 seconds to allow the VM to start up fully
Write-Host "Waiting 30 seconds to attempt VM connection"
Start-Sleep -Seconds 30

# Attempt to connect to the VM on port 22 (SSH) until successful
$maxAttempts = 5
$attempt = 1
$connected = $false

while (-not $connected -and $attempt -le $maxAttempts) {
    Write-Host "Attempting to connect to VM (attempt $attempt)..."
    
    $reachable = Test-NetConnection -ComputerName 172.29.16.2 -Port 22
    
    if ($reachable.TcpTestSucceeded) {
        # If the VM is reachable on port 22, SSH into it
        & ssh.exe harzinn@172.29.16.2
        
        $connected = $true
        Write-Host "Connected to VM."
    } else {
        Write-Host "Unable to connect to VM."
        $attempt++
    }
}

if (-not $connected) {
    Write-Host "Failed to connect to VM after $maxAttempts attempts."
}
