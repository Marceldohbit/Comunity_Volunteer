# Docker Validation Script for Windows PowerShell
Write-Host "🔍 Validating Docker Configuration..." -ForegroundColor Cyan

# Check if Docker files exist
Write-Host "📁 Checking Docker files..." -ForegroundColor Yellow
if (Test-Path "backend/Dockerfile") {
    Write-Host "✅ Backend Dockerfile found" -ForegroundColor Green
} else {
    Write-Host "❌ Backend Dockerfile missing" -ForegroundColor Red
}

if (Test-Path "frontend/Dockerfile") {
    Write-Host "✅ Frontend Dockerfile found" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend Dockerfile missing" -ForegroundColor Red
}

if (Test-Path "docker-compose.yml") {
    Write-Host "✅ Docker Compose file found" -ForegroundColor Green
} else {
    Write-Host "❌ Docker Compose file missing" -ForegroundColor Red
}

# Check required files for backend
Write-Host "📦 Checking Backend requirements..." -ForegroundColor Yellow
if (Test-Path "backend/package.json") {
    Write-Host "✅ Backend package.json found" -ForegroundColor Green
} else {
    Write-Host "❌ Backend package.json missing" -ForegroundColor Red
}

if (Test-Path "backend/server.js") {
    Write-Host "✅ Backend server.js found" -ForegroundColor Green
} else {
    Write-Host "❌ Backend server.js missing" -ForegroundColor Red
}

# Check required files for frontend
Write-Host "🎨 Checking Frontend requirements..." -ForegroundColor Yellow
if (Test-Path "frontend/package.json") {
    Write-Host "✅ Frontend package.json found" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend package.json missing" -ForegroundColor Red
}

# Check if build script exists in frontend
if (Test-Path "frontend/package.json") {
    $packageContent = Get-Content "frontend/package.json" -Raw
    if ($packageContent -match '"build"') {
        Write-Host "✅ Frontend build script found" -ForegroundColor Green
    } else {
        Write-Host "❌ Frontend build script missing" -ForegroundColor Red
    }
}

# Check environment setup
Write-Host "🔧 Checking Environment setup..." -ForegroundColor Yellow
if (Test-Path ".env.example") {
    Write-Host "✅ Environment template found" -ForegroundColor Green
} else {
    Write-Host "❌ Environment template missing" -ForegroundColor Red
}

# Check dockerignore files
if (Test-Path "backend/.dockerignore") {
    Write-Host "✅ Backend .dockerignore found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Backend .dockerignore missing" -ForegroundColor Yellow
}

if (Test-Path "frontend/.dockerignore") {
    Write-Host "✅ Frontend .dockerignore found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Frontend .dockerignore missing" -ForegroundColor Yellow
}

Write-Host "`n✨ Validation complete!" -ForegroundColor Cyan
Write-Host "💡 To test with Docker, push to GitHub and check Actions tab" -ForegroundColor Blue
Write-Host "🌐 Or try Play with Docker: https://labs.play-with-docker.com/" -ForegroundColor Blue