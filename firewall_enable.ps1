$FirewallProfiles = @("Domain", "Private", "Public")

foreach ($Profile in $FirewallProfiles) {
    $GPOPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\$Profile"

    if (-not (Test-Path $GPOPath)) {
        New-Item -Path $GPOPath -Force | Out-Null
    }

    Set-ItemProperty -Path $GPOPath -Name "EnableFirewall" -Value 1
}

gpupdate /force
