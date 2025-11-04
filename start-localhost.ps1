# ====================================================================
# Start All Services on Localhost
# ====================================================================
# This script helps you start all required services in the correct order
# ====================================================================

param(
    [switch]$SkipDocker,
    [switch]$SkipClient,
    [switch]$Help
)

if ($Help) {
    Write-Host ""
    Write-Host "Usage: .\start-localhost.ps1 [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -SkipDocker    Skip Docker services startup" -ForegroundColor White
    Write-Host "  -SkipClient    Skip client registration" -ForegroundColor White
    Write-Host "  -Help          Show this help message" -ForegroundColor White
    Write-Host ""
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host " Starting Localhost Development Environment" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# ====================================================================
# Step 1: Check Docker
# ====================================================================
if (-not $SkipDocker) {
    Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
    try {
        $dockerRunning = docker ps 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   [ERROR] Docker is not running. Please start Docker Desktop." -ForegroundColor Red
            exit 1
        }
        Write-Host "   [OK] Docker is running" -ForegroundColor Green
    } catch {
        Write-Host "   [ERROR] Docker not found. Please install Docker Desktop." -ForegroundColor Red
        exit 1
    }

    # Start Docker Compose services
    Write-Host ""
    Write-Host "[2/5] Starting Docker services (eSignet, PostgreSQL, Redis)..." -ForegroundColor Yellow
    Push-Location "navbar-app\docker-compose"
    try {
        docker-compose up -d
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] Docker services started" -ForegroundColor Green
            Write-Host "   Waiting 15 seconds for services to initialize..." -ForegroundColor Gray
            Start-Sleep -Seconds 15
        } else {
            Write-Host "   [ERROR] Failed to start Docker services" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    } catch {
        Write-Host "   [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-Host "[1/5] Skipping Docker startup (assuming already running)..." -ForegroundColor Gray
    Write-Host "[2/5] Skipping Docker startup (assuming already running)..." -ForegroundColor Gray
}

# ====================================================================
# Step 2: Register OIDC Client
# ====================================================================
if (-not $SkipClient) {
    Write-Host ""
    Write-Host "[3/5] Registering OIDC client..." -ForegroundColor Yellow
    Push-Location "navbar-app"
    
    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Host "   Installing dependencies..." -ForegroundColor Gray
        npm install --silent
    }
    
    try {
        Write-Host "   Creating client configuration..." -ForegroundColor Gray
        node create-client.js
        Write-Host "   Registering client with eSignet..." -ForegroundColor Gray
        node register-client.js
        Write-Host "   [OK] Client registered successfully" -ForegroundColor Green
    } catch {
        Write-Host "   [WARN] Client registration may have failed. Check eSignet is running." -ForegroundColor Yellow
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    Pop-Location
} else {
    Write-Host ""
    Write-Host "[3/5] Skipping client registration..." -ForegroundColor Gray
}

# ====================================================================
# Step 3: Check if ports are available
# ====================================================================
Write-Host ""
Write-Host "[4/5] Checking port availability..." -ForegroundColor Yellow

$ports = @{
    "3000" = "eSignet UI"
    "3001" = "React Frontend"
    "5000" = "Callback Server"
    "8080" = "Backend API"
    "8088" = "eSignet Backend"
}

$portsInUse = @()
foreach ($port in $ports.Keys) {
    try {
        $conn = Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($conn) {
            Write-Host "   [BUSY] Port $port ($($ports[$port])) is already in use" -ForegroundColor Yellow
            $portsInUse += $port
        } else {
            Write-Host "   [FREE] Port $port ($($ports[$port]))" -ForegroundColor Green
        }
    } catch {
        Write-Host "   [FREE] Port $port ($($ports[$port]))" -ForegroundColor Green
    }
}

if ($portsInUse.Count -gt 0) {
    Write-Host ""
    Write-Host "   [WARN] Some ports are in use. Services may already be running." -ForegroundColor Yellow
}

# ====================================================================
# Step 4: Display startup commands
# ====================================================================
Write-Host ""
Write-Host "[5/5] Ready to start services!" -ForegroundColor Yellow
Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host " Manual Startup Instructions" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open 3 separate terminals and run:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Terminal 1 - Backend API:" -ForegroundColor Cyan
Write-Host "  cd navbar-app\backend" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 2 - Callback Server:" -ForegroundColor Cyan
Write-Host "  cd navbar-app" -ForegroundColor White
Write-Host "  node callback-server.js" -ForegroundColor White
Write-Host ""
Write-Host "Terminal 3 - React Frontend:" -ForegroundColor Cyan
Write-Host "  cd navbar-app" -ForegroundColor White
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host " Access URLs" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  eSignet UI:       http://localhost:3000" -ForegroundColor Green
Write-Host "  React App:        http://localhost:3001" -ForegroundColor Green
Write-Host "  Callback Server:  http://localhost:5000/health" -ForegroundColor Green
Write-Host "  Backend API:      http://localhost:8080/health" -ForegroundColor Green
Write-Host "  eSignet Backend:  http://localhost:8088/actuator/health" -ForegroundColor Green
Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
