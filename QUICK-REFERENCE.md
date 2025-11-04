# 🚀 Quick Reference Card - Localhost Development

## One-Line Commands

### Start Everything
```powershell
.\start-localhost.ps1
```

### Stop Everything
```powershell
.\stop-localhost.ps1
```

### Migrate from Cloud
```powershell
.\migrate-to-localhost.ps1
```

---

## Service URLs

| What | URL |
|------|-----|
| 🎨 **React App** | http://localhost:3001 |
| 🔐 **eSignet Login** | http://localhost:3000 |
| 📞 **Callback Server** | http://localhost:5000 |
| 🔌 **Backend API** | http://localhost:8080 |
| 🏢 **eSignet Backend** | http://localhost:8088 |

---

## Health Checks

```powershell
# eSignet Backend
curl http://localhost:8088/actuator/health

# Callback Server
curl http://localhost:5000/health

# Backend API
curl http://localhost:8080/health
```

---

## Manual Startup (3 Terminals)

### Terminal 1: Backend
```powershell
cd navbar-app\backend
npm start
```

### Terminal 2: Callback
```powershell
cd navbar-app
node callback-server.js
```

### Terminal 3: Frontend
```powershell
cd navbar-app
npm start
```

---

## Docker Commands

```powershell
# Start Docker services
cd navbar-app\docker-compose
docker-compose up -d

# Stop Docker services
docker-compose down

# View logs
docker-compose logs -f

# Check status
docker-compose ps

# Restart service
docker-compose restart esignet
```

---

## OIDC Client Registration

```powershell
cd navbar-app
node create-client.js
node register-client.js
```

---

## Common Troubleshooting

### Port in use?
```powershell
# Find process on port 5000
netstat -ano | findstr :5000

# Kill process (replace <PID>)
taskkill /PID <PID> /F
```

### Docker not starting?
```powershell
# Make sure Docker Desktop is running
docker ps

# If issues, try:
docker-compose down -v
docker-compose up -d
```

### Client registration fails?
```powershell
# Wait for eSignet to start (check health)
curl http://localhost:8088/actuator/health

# Then retry registration
node create-client.js
node register-client.js
```

---

## File Locations

| File | Purpose |
|------|---------|
| `LOCALHOST-SETUP.md` | Full setup guide |
| `MIGRATION-SUMMARY.md` | What changed |
| `migrate-to-localhost.ps1` | Migration script |
| `start-localhost.ps1` | Startup helper |
| `stop-localhost.ps1` | Shutdown helper |
| `navbar-app/client-config.json` | OIDC client config |
| `navbar-app/callback-server.js` | Callback server |
| `navbar-app/public/runtime-config.js` | Runtime config |

---

## Port Reference

| Port | Service |
|------|---------|
| 3000 | eSignet UI |
| 3001 | React Frontend |
| 5000 | Callback Server |
| 5455 | PostgreSQL |
| 6379 | Redis |
| 8080 | Backend API |
| 8082 | Mock Identity |
| 8088 | eSignet Backend |

---

## Need Help?

1. Check `LOCALHOST-SETUP.md` for detailed guide
2. Check `MIGRATION-SUMMARY.md` for what changed
3. Check logs: `docker-compose logs -f`
4. Check port availability: `netstat -ano | findstr :PORT`

---

**Quick Links:**
- 📘 [Full Setup Guide](LOCALHOST-SETUP.md)
- 📋 [Migration Summary](MIGRATION-SUMMARY.md)
- 🏗️ [Architecture](ARCHITECTURE.md)
- 📚 [API Docs](docs/API.md)
