# Run this script with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrative privileges. Please run as administrator." -ForegroundColor Red
    exit
}

# List available network interfaces
$interfaces = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object Name, InterfaceDescription, MacAddress, Status

# Display network interfaces with index numbers
Write-Host "Available Network Interfaces:"
for ($i = 0; $i -lt $interfaces.Count; $i++) {
    Write-Host ("{0}: {1}" -f $i, $interfaces[$i].Name)
}

# Prompt the user to select a network interface
$selectedIndex = Read-Host "Enter the number of the network interface you'd like to configure"

$selectedInterface = $interfaces[$selectedIndex]

if (!$selectedInterface) {
    Write-Host "Invalid selection. Please try again with a valid index number." -ForegroundColor Red
    exit
}

# Ask the user if they want to set a static IP or use DHCP
$action = Read-Host "Enter '1' to set a static IP address or '2' to use DHCP"

if ($action -eq '1') {
    # Set static IP address
    $ipAddress = Read-Host "Enter the IP address (e.g. 192.168.1.10)"
    $subnetMask = Read-Host "Enter the subnet mask (e.g. 255.255.255.0)"
    $defaultGateway = Read-Host "Enter the default gateway (e.g. 192.168.1.1) (Press Enter to skip)"
    $dnsServers = Read-Host "Enter the DNS servers (comma-separated, e.g. 8.8.8.8,8.8.4.4) (Press Enter to skip)"

    # Calculate prefix length based on subnet mask
    $prefixLength = ([IPAddress]$subnetMask).GetAddressBytes() | ForEach-Object { [Convert]::ToString($_, 2) } | ForEach-Object { $_.Replace("0", "").Length } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    # Configure the selected interface with the static IP address, subnet mask, and default gateway (if provided)
    if (![string]::IsNullOrEmpty($defaultGateway)) {
        New-NetIPAddress -InterfaceAlias $selectedInterface.Name -IPAddress $ipAddress -PrefixLength $prefixLength -DefaultGateway $defaultGateway
    } else {
        New-NetIPAddress -InterfaceAlias $selectedInterface.Name -IPAddress $ipAddress -PrefixLength $prefixLength
    }

    # Set DNS servers (if provided)
    if (![string]::IsNullOrEmpty($dnsServers)) {
        Set-DnsClientServerAddress -InterfaceAlias $selectedInterface.Name -ServerAddresses $dnsServers.Split(',')
    }

    Write-Host "Static IP address configuration applied successfully." -ForegroundColor Green
} elseif ($action -eq '2') {
    # Configure the selected interface to use DHCP
    Set-NetIPInterface -InterfaceAlias $selectedInterface.Name -Dhcp Enabled
    Write-Host "DHCP configuration applied successfully." -ForegroundColor Green
} else {
    Write-Host "Invalid option. Please try again and enter either '1' or '2'." -ForegroundColor Red
}
