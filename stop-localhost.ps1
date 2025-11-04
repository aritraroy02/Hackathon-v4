# ====================================================================
# Stop All Localhost Services
# ====================================================================
# This script helps you cleanly stop all running services
# ====================================================================

param(
    [switch]$KeepDocker,
    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "Usage: .\stop-localhost.ps1 [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -KeepDocker    Keep Docker services running" -ForegroundColor White
    Write-Host "  -Help          Show this help message" -ForegroundColor White
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host " Stopping Localhost Services" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# ====================================================================
# Stop Node.js processes
# ====================================================================
Write-Host "[1/2] Stopping Node.js services..." -ForegroundColor Yellow

$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-Host "   Found $($nodeProcesses.Count) Node.js process(es)" -ForegroundColor Gray
    
    foreach ($proc in $nodeProcesses) {
        try {
            $commandLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($proc.Id)").CommandLine
            Write-Host "   Stopping: PID $($proc.Id) - $commandLine" -ForegroundColor Gray
            Stop-Process -Id $proc.Id -Force
        } catch {
            Write-Host "   Could not stop process $($proc.Id)" -ForegroundColor Yellow
        }
    }
    Write-Host "   [OK] Node.js processes stopped" -ForegroundColor Green
} else {
    Write-Host "   [OK] No Node.js processes found" -ForegroundColor Green
}

# ====================================================================
# Stop Docker services
# ====================================================================
if (-not $KeepDocker) {
    Write-Host ""
    Write-Host "[2/2] Stopping Docker services..." -ForegroundColor Yellow
    Push-Location "navbar-app\docker-compose"
    try {
        docker-compose down
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] Docker services stopped" -ForegroundColor Green
        } else {
            Write-Host "   [WARN] Failed to stop Docker services" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
    Pop-Location
} else {
    Write-Host ""
    Write-Host "[2/2] Keeping Docker services running..." -ForegroundColor Gray
}

# ====================================================================
# Summary
# ====================================================================
Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host " Services Stopped" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if any processes are still running on our ports
$ports = @{
    "3001" = "React Frontend"
    "5000" = "Callback Server"
    "8080" = "Backend API"
}

Write-Host "Port Status:" -ForegroundColor Yellow
$anyRunning = $false
foreach ($port in $ports.Keys) {
    try {
        $conn = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if ($conn) {
            Write-Host "  [BUSY] Port $port ($($ports[$port])) still in use" -ForegroundColor Yellow
            $anyRunning = $true
        } else {
            Write-Host "  [FREE] Port $port ($($ports[$port]))" -ForegroundColor Green
        }
    } catch {
        Write-Host "  [FREE] Port $port ($($ports[$port]))" -ForegroundColor Green
    }
}

if ($anyRunning) {
    Write-Host ""
    Write-Host "[WARN] Some ports are still in use. You may need to manually kill processes." -ForegroundColor Yellow
    Write-Host "Use: netstat -ano | findstr :<port>" -ForegroundColor Gray
    Write-Host "Then: taskkill /PID <PID> /F" -ForegroundColor Gray
}

Write-Host ""
Write-Host "To start services again, run: .\start-localhost.ps1" -ForegroundColor Cyan
Write-Host ""
