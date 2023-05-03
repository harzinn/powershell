# Check if the Secondary Logon service is running
if ((Get-Service -Name seclogon).Status -ne "Running") {
    # If the service is not running, start it
    Start-Service -Name seclogon
}

# Set the startup type to Automatic
Set-Service -Name seclogon -StartupType Automatic
