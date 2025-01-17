param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$SkipDistroInstall
)

# Ensure the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

if (-not ($Install -or $Uninstall)) {
    Write-Host "Please specify either -Install or -Uninstall flag." -ForegroundColor Yellow
    exit 1
}

# Check if the script is running on Windows 10/11 version 2004 or later
$WinVer = [System.Environment]::OSVersion.Version
if ($WinVer.Major -lt 10 -or ($WinVer.Major -eq 10 -and $WinVer.Build -lt 19041)) {
    Write-Host "Windows Subsystem for Linux requires Windows 10 version 2004 or later." -ForegroundColor Red
    exit 1
}

if ($Install) {
    # Enable the Windows Subsystem for Linux (WSL) feature
    Write-Host "Enabling Windows Subsystem for Linux (WSL) feature..." -ForegroundColor Green
    try {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    } catch {
        Write-Host "Failed to enable WSL features." -ForegroundColor Red
        exit 1
    }

    # Set WSL version to 2 as default
    Write-Host "Setting WSL version to 2 as default..." -ForegroundColor Green
    try {
        wsl --set-default-version 2
    } catch {
        Write-Host "Failed to set WSL version to 2." -ForegroundColor Red
        exit 1
    }

    if (-not $SkipDistroInstall) {
        # Install a default Linux distribution (Ubuntu)
        $DistroName = "Ubuntu"
        Write-Host "Installing $DistroName from Microsoft Store..." -ForegroundColor Green
        try {
            Invoke-WebRequest -Uri "https://aka.ms/wslubuntu" -OutFile "$env:TEMP\$DistroName.appx" -UseBasicParsing
            Add-AppxPackage -Path "$env:TEMP\$DistroName.appx"
            Write-Host "$DistroName installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to install $DistroName." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Skipping Linux distribution installation." -ForegroundColor Yellow
    }

    Write-Host "Windows Subsystem for Linux setup is complete." -ForegroundColor Green
}

if ($Uninstall) {
    # Uninstall WSL and related features
    Write-Host "Uninstalling Windows Subsystem for Linux (WSL) feature..." -ForegroundColor Green
    try {
        dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
        dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
    } catch {
        Write-Host "Failed to uninstall WSL features." -ForegroundColor Red
        exit 1
    }

    # Remove default Linux distribution (Ubuntu)
    $DistroName = "Ubuntu"
    Write-Host "Removing $DistroName..." -ForegroundColor Green
    try {
        Get-AppxPackage -Name "CanonicalGroupLimited.Ubuntu" | Remove-AppxPackage
        Write-Host "$DistroName removed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to remove $DistroName." -ForegroundColor Red
    }

    Write-Host "Windows Subsystem for Linux has been uninstalled." -ForegroundColor Green
}
