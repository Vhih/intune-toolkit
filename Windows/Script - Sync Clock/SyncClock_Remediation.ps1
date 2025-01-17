# Start Windows Time service if not running
$service = Get-Service -Name W32Time -ErrorAction SilentlyContinue
if ($service.Status -ne "Running") {
    Start-Service -Name W32Time
}

# Force time synchronization
w32tm /resync /nowait
