# Check if WSL is enabled
$WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$VMFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

# Check for default Linux distribution (Ubuntu)
$DistroInstalled = Get-AppxPackage -Name "CanonicalGroupLimited.Ubuntu" -ErrorAction SilentlyContinue

if ($WSLFeature.State -eq "Enabled" -and $VMFeature.State -eq "Enabled" -and $DistroInstalled) {
    # WSL and Ubuntu are installed
    exit 0
} else {
    # WSL and/or Ubuntu are not installed
    exit 1
}
