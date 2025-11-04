# Start backend server with MongoDB URI
$env:MONGO_URI="mongodb+srv://harshbontala188:8I52Oqeh3sWYTDJ7@cluster0.5lsiap2.mongodb.net/childBooklet?retryWrites=true&w=majority&appName=Cluster0"
$env:MONGODB_URI="mongodb+srv://harshbontala188:8I52Oqeh3sWYTDJ7@cluster0.5lsiap2.mongodb.net/childBooklet?retryWrites=true&w=majority&appName=Cluster0"
Set-Location $PSScriptRoot
Write-Host "Starting backend server on port 8080..." -ForegroundColor Green
node src\server.js
