# Check if the Windows Time service is running and synchronized
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue
$syncStatus = w32tm /query /status | Select-String "Source" | Out-String

if ($service.Status -eq "Running" -and $syncStatus -match "Free-running System Clock") {
    Write-Output "Clock not synchronized"
    Exit 1
} else {
    Write-Output "Clock synchronized"
    Exit 0
}
