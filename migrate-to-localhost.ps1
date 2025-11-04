# ====================================================================
# Migrate from Google Cloud to Localhost
# ====================================================================
# This script updates all configuration files to use localhost instead
# of Google Cloud IPs (34.58.198.143 and 35.194.34.36)
# ====================================================================

Write-Host "🔄 Starting migration from Google Cloud to Localhost..." -ForegroundColor Cyan
Write-Host ""

# Define IP mappings
$GCLOUD_CALLBACK_IP = "34.58.198.143"  # Old callback server IP
$GCLOUD_BACKEND_IP = "35.194.34.36"    # Old backend IP
$LOCALHOST = "localhost"

# ====================================================================
# 1. Update callback-server.js
# ====================================================================
Write-Host "Updating navbar-app/callback-server.js..." -ForegroundColor Yellow
$callbackServerPath = ".\navbar-app\callback-server.js"
if (Test-Path $callbackServerPath) {
    $content = Get-Content $callbackServerPath -Raw
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:3001", "http://localhost:3001"
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP`:5000", "http://localhost:5000"
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:3000/authorize", "http://localhost:3000/authorize"
    Set-Content $callbackServerPath $content -NoNewline
    Write-Host "   [OK] Updated callback-server.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $callbackServerPath" -ForegroundColor Red
}

# ====================================================================
# 2. Update client-config.json
# ====================================================================
Write-Host "Updating navbar-app/client-config.json..." -ForegroundColor Yellow
$clientConfigPath = ".\navbar-app\client-config.json"
if (Test-Path $clientConfigPath) {
    $content = Get-Content $clientConfigPath -Raw
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:8088", "http://localhost:8088"
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:5000/callback", "http://localhost:5000/callback"
    Set-Content $clientConfigPath $content -NoNewline
    Write-Host "   [OK] Updated client-config.json" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $clientConfigPath" -ForegroundColor Red
}

# ====================================================================
# 3. Update runtime-config.js (public)
# ====================================================================
Write-Host "Updating navbar-app/public/runtime-config.js..." -ForegroundColor Yellow
$runtimeConfigPath = ".\navbar-app\public\runtime-config.js"
if (Test-Path $runtimeConfigPath) {
    $content = @"
// Localhost runtime config - no trailing slash
window.__CALLBACK_BASE = 'http://localhost:5000';
// Backend API base URL
window.__API_BASE = 'http://localhost:8080';
"@
    Set-Content $runtimeConfigPath $content
    Write-Host "   [OK] Updated public/runtime-config.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $runtimeConfigPath" -ForegroundColor Red
}

# ====================================================================
# 4. Update runtime-config.js (build)
# ====================================================================
Write-Host "Updating navbar-app/build/runtime-config.js..." -ForegroundColor Yellow
$buildRuntimeConfigPath = ".\navbar-app\build\runtime-config.js"
if (Test-Path $buildRuntimeConfigPath) {
    $content = @"
// Localhost runtime config - no trailing slash
window.__CALLBACK_BASE = 'http://localhost:5000';
"@
    Set-Content $buildRuntimeConfigPath $content
    Write-Host "   [OK] Updated build/runtime-config.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $buildRuntimeConfigPath" -ForegroundColor Red
}

# ====================================================================
# 5. Update ecosystem.config.js
# ====================================================================
Write-Host "Updating navbar-app/ecosystem.config.js..." -ForegroundColor Yellow
$ecosystemPath = ".\navbar-app\ecosystem.config.js"
if (Test-Path $ecosystemPath) {
    $content = @"
module.exports = {
  apps: [
    {
      name: 'callback-server',
      script: './callback-server.js',
      env: {
        PORT: 5000,
        HOST: '0.0.0.0',
        SPA_BASE_URL: 'http://localhost:3001',
        CALLBACK_BASE_URL: 'http://localhost:5000',
        AUTHORIZE_URI: 'http://localhost:3000/authorize'
      }
    }
  ]
};
"@
    Set-Content $ecosystemPath $content
    Write-Host "   [OK] Updated ecosystem.config.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $ecosystemPath" -ForegroundColor Red
}

# ====================================================================
# 6. Update identity-proxy.js
# ====================================================================
Write-Host "Updating identity-proxy.js..." -ForegroundColor Yellow
$identityProxyPath = ".\identity-proxy.js"
if (Test-Path $identityProxyPath) {
    $content = Get-Content $identityProxyPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $identityProxyPath $content -NoNewline
    Write-Host "   [OK] Updated identity-proxy.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $identityProxyPath" -ForegroundColor Red
}

# ====================================================================
# 7. Update current-server.js (PostgreSQL host)
# ====================================================================
Write-Host "Updating current-server.js..." -ForegroundColor Yellow
$currentServerPath = ".\current-server.js"
if (Test-Path $currentServerPath) {
    $content = Get-Content $currentServerPath -Raw
    $content = $content -replace [regex]::Escape("process.env.PG_HOST || '$GCLOUD_CALLBACK_IP'"), "process.env.PG_HOST || 'localhost'"
    Set-Content $currentServerPath $content -NoNewline
    Write-Host "   [OK] Updated current-server.js" -ForegroundColor Green
} else {
    Write-Host "   [WARN] File not found: $currentServerPath" -ForegroundColor Red
}

# ====================================================================
# 8. Update React source files
# ====================================================================
Write-Host "Updating React source files..." -ForegroundColor Yellow

# AdminAgents.js
$adminAgentsPath = ".\navbar-app\src\components\AdminAgents.js"
if (Test-Path $adminAgentsPath) {
    $content = Get-Content $adminAgentsPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $adminAgentsPath $content -NoNewline
    Write-Host "   [OK] Updated AdminAgents.js" -ForegroundColor Green
}

# AdminPage.js
$adminPagePath = ".\navbar-app\src\components\AdminPage.js"
if (Test-Path $adminPagePath) {
    $content = Get-Content $adminPagePath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    $content = $content -replace "GCLOUD_VM_BACKEND", "LOCALHOST_BACKEND"
    Set-Content $adminPagePath $content -NoNewline
    Write-Host "   [OK] Updated AdminPage.js" -ForegroundColor Green
}

# AdminRecords.js
$adminRecordsPath = ".\navbar-app\src\components\AdminRecords.js"
if (Test-Path $adminRecordsPath) {
    $content = Get-Content $adminRecordsPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $adminRecordsPath $content -NoNewline
    Write-Host "   [OK] Updated AdminRecords.js" -ForegroundColor Green
}

# Records.js
$recordsPath = ".\navbar-app\src\components\Records.js"
if (Test-Path $recordsPath) {
    $content = Get-Content $recordsPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $recordsPath $content -NoNewline
    Write-Host "   [OK] Updated Records.js" -ForegroundColor Green
}

# sync.js
$syncPath = ".\navbar-app\src\offline\sync.js"
if (Test-Path $syncPath) {
    $content = Get-Content $syncPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $syncPath $content -NoNewline
    Write-Host "   [OK] Updated sync.js" -ForegroundColor Green
}

# ====================================================================
# 9. Update debug-upload.html
# ====================================================================
Write-Host "Updating navbar-app/debug-upload.html..." -ForegroundColor Yellow
$debugUploadPath = ".\navbar-app\debug-upload.html"
if (Test-Path $debugUploadPath) {
    $content = Get-Content $debugUploadPath -Raw
    $content = $content -replace "http://$GCLOUD_BACKEND_IP:8080", "http://localhost:8080"
    Set-Content $debugUploadPath $content -NoNewline
    Write-Host "   [OK] Updated debug-upload.html" -ForegroundColor Green
}

# ====================================================================
# 10. Update create-client.js and register-client.js
# ====================================================================
Write-Host "Updating create-client.js..." -ForegroundColor Yellow
$createClientPath = ".\navbar-app\create-client.js"
if (Test-Path $createClientPath) {
    $content = Get-Content $createClientPath -Raw
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:5000/callback", "http://localhost:5000/callback"
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:8088", "http://localhost:8088"
    Set-Content $createClientPath $content -NoNewline
    Write-Host "   [OK] Updated create-client.js" -ForegroundColor Green
}

Write-Host "Updating register-client.js..." -ForegroundColor Yellow
$registerClientPath = ".\navbar-app\register-client.js"
if (Test-Path $registerClientPath) {
    $content = Get-Content $registerClientPath -Raw
    $content = $content -replace "http://$GCLOUD_CALLBACK_IP:8088", "http://localhost:8088"
    Set-Content $registerClientPath $content -NoNewline
    Write-Host "   [OK] Updated register-client.js" -ForegroundColor Green
}

# ====================================================================
# Summary and Next Steps
# ====================================================================
Write-Host ""
Write-Host "[COMPLETE] Migration Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "   eSignet UI:         http://localhost:3000" -ForegroundColor White
Write-Host "   eSignet Backend:    http://localhost:8088" -ForegroundColor White
Write-Host "   Callback Server:    http://localhost:5000" -ForegroundColor White
Write-Host "   Frontend (React):   http://localhost:3001" -ForegroundColor White
Write-Host "   Backend API:        http://localhost:8080" -ForegroundColor White
Write-Host "   PostgreSQL:         localhost:5455" -ForegroundColor White
Write-Host "   Redis:              localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Start Docker services:" -ForegroundColor White
Write-Host "      cd navbar-app\docker-compose" -ForegroundColor Gray
Write-Host "      docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Re-register OIDC client (important!):" -ForegroundColor White
Write-Host "      cd ..\navbar-app" -ForegroundColor Gray
Write-Host "      node create-client.js" -ForegroundColor Gray
Write-Host "      node register-client.js" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Start backend server:" -ForegroundColor White
Write-Host "      cd backend" -ForegroundColor Gray
Write-Host "      npm install" -ForegroundColor Gray
Write-Host "      npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Start callback server:" -ForegroundColor White
Write-Host "      cd .." -ForegroundColor Gray
Write-Host "      npm install" -ForegroundColor Gray
Write-Host "      node callback-server.js" -ForegroundColor Gray
Write-Host ""
Write-Host "   5. Start React frontend:" -ForegroundColor White
Write-Host "      npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Red
Write-Host "   You MUST re-register the OIDC client with new localhost URLs" -ForegroundColor White
Write-Host "   Make sure Docker services are running before starting servers" -ForegroundColor White
Write-Host "   Check that all ports are available (3000, 3001, 5000, 8080, 8088)" -ForegroundColor White
Write-Host ""
