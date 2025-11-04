# 🏠 Localhost Setup Guide

This guide helps you run the entire application stack on your local machine instead of Google Cloud.

## 📋 Prerequisites

1. **Docker Desktop** - Install from [docker.com](https://www.docker.com/products/docker-desktop)
2. **Node.js** (v16 or higher) - Install from [nodejs.org](https://nodejs.org/)
3. **Git** - Already installed on your system

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```powershell
# Run the startup script
.\start-localhost.ps1
```

This will:
- ✅ Check Docker is running
- ✅ Start Docker services (eSignet, PostgreSQL, Redis)
- ✅ Register OIDC client with localhost URLs
- ✅ Check port availability
- ✅ Show you next steps

### Option 2: Manual Setup

#### Step 1: Start Docker Services

```powershell
cd navbar-app\docker-compose
docker-compose up -d
```

Wait ~30 seconds for all services to initialize.

#### Step 2: Register OIDC Client

```powershell
cd ..\
node create-client.js
node register-client.js
```

This creates and registers a new OAuth2 client with localhost redirect URIs.

#### Step 3: Start Backend Services

Open **3 separate PowerShell terminals**:

**Terminal 1 - Backend API:**
```powershell
cd navbar-app\backend
npm install
npm start
```
Backend will run on `http://localhost:8080`

**Terminal 2 - Callback Server:**
```powershell
cd navbar-app
npm install
node callback-server.js
```
Callback server will run on `http://localhost:5000`

**Terminal 3 - React Frontend:**
```powershell
cd navbar-app
npm start
```
React app will run on `http://localhost:3001`

## 🌐 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **React App** | http://localhost:3001 | Main application frontend |
| **Callback Server** | http://localhost:5000 | OAuth2 callback handler |
| **Backend API** | http://localhost:8080 | REST API backend |
| **eSignet UI** | http://localhost:3000 | OAuth2 login interface |
| **eSignet Backend** | http://localhost:8088 | OAuth2 authorization server |
| **PostgreSQL** | localhost:5455 | Database (Docker) |
| **Redis** | localhost:6379 | Cache (Docker) |

## 🔧 Configuration Changes

The migration script (`migrate-to-localhost.ps1`) updated these files:

### Updated Files:
- ✅ `navbar-app/callback-server.js` - Callback server URLs
- ✅ `navbar-app/client-config.json` - OIDC client config
- ✅ `navbar-app/public/runtime-config.js` - Frontend runtime config
- ✅ `navbar-app/build/runtime-config.js` - Build runtime config
- ✅ `navbar-app/ecosystem.config.js` - PM2 config
- ✅ `navbar-app/create-client.js` - Client creation script
- ✅ `navbar-app/register-client.js` - Client registration script
- ✅ `identity-proxy.js` - Identity proxy
- ✅ `current-server.js` - PostgreSQL host
- ✅ All React components (AdminAgents, AdminPage, AdminRecords, Records, sync.js)

### Old Values → New Values:
| Old (Google Cloud) | New (Localhost) |
|-------------------|-----------------|
| `34.58.198.143:5000` | `localhost:5000` |
| `34.58.198.143:3000` | `localhost:3000` |
| `34.58.198.143:8088` | `localhost:8088` |
| `35.194.34.36:8080` | `localhost:8080` |

## 🧪 Testing the Setup

### 1. Check Docker Services
```powershell
cd navbar-app\docker-compose
docker-compose ps
```

All services should show "Up" status.

### 2. Health Checks
```powershell
# Test eSignet backend
curl http://localhost:8088/actuator/health

# Test callback server
curl http://localhost:5000/health

# Test backend API
curl http://localhost:8080/health
```

### 3. Test Authentication Flow
1. Open http://localhost:3001
2. Click "Sign In with eSignet"
3. You should be redirected to http://localhost:3000 (eSignet UI)
4. Use mock credentials to log in
5. You'll be redirected back to http://localhost:3001

## 🐛 Troubleshooting

### Docker services won't start
```powershell
# Check Docker is running
docker ps

# Check logs
cd navbar-app\docker-compose
docker-compose logs -f
```

### Port already in use
```powershell
# Find what's using the port
netstat -ano | findstr :3000
netstat -ano | findstr :5000
netstat -ano | findstr :8080
netstat -ano | findstr :8088

# Kill the process (replace PID)
taskkill /PID <PID> /F
```

### Client registration fails
Make sure eSignet backend is running first:
```powershell
curl http://localhost:8088/actuator/health
```

If it's not responding, wait longer or restart Docker services:
```powershell
cd navbar-app\docker-compose
docker-compose restart
```

### MongoDB connection issues
The backend uses MongoDB Atlas. Check your `MONGO_URI` environment variable:
```powershell
# In navbar-app\backend\.env or set environment variable
$env:MONGO_URI = "your-mongodb-connection-string"
```

## 🔄 Reverting to Google Cloud

If you need to switch back to Google Cloud IPs:

1. The old configuration values were:
   - Callback IP: `34.58.198.143`
   - Backend IP: `35.194.34.36`

2. You can manually replace `localhost` with these IPs in the files listed above, or:

3. Create a reverse migration script (similar to `migrate-to-localhost.ps1`)

## 📚 Additional Resources

- **eSignet Documentation**: `navbar-app/docs/eSignet-Integration-Guide.md`
- **API Documentation**: `docs/API.md`
- **Architecture**: `ARCHITECTURE.md`
- **Software Documentation**: `docs/Software-Documentation.md`

## 🆘 Need Help?

Common commands:
```powershell
# Stop all Docker services
cd navbar-app\docker-compose
docker-compose down

# Restart all Docker services
docker-compose restart

# View logs
docker-compose logs -f esignet
docker-compose logs -f database

# Clean restart
docker-compose down -v
docker-compose up -d
```

## ✅ Checklist

Before starting development:

- [ ] Docker Desktop is running
- [ ] Ran `migrate-to-localhost.ps1` successfully
- [ ] All Docker services are up (`docker-compose ps`)
- [ ] OIDC client is registered (`node create-client.js && node register-client.js`)
- [ ] All 3 services are running (backend, callback, frontend)
- [ ] Can access http://localhost:3001
- [ ] Authentication flow works

---

**Last Updated**: Migration completed
**Migration Script**: `migrate-to-localhost.ps1`
**Startup Script**: `start-localhost.ps1`
