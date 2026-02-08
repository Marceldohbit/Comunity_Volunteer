#!/bin/bash
# Docker Validation Script (runs without Docker installed)

echo "🔍 Validating Docker Configuration..."

# Check if Docker files exist
echo "📁 Checking Docker files..."
if [ -f "backend/Dockerfile" ]; then
    echo "✅ Backend Dockerfile found"
else
    echo "❌ Backend Dockerfile missing"
fi

if [ -f "frontend/Dockerfile" ]; then
    echo "✅ Frontend Dockerfile found"
else
    echo "❌ Frontend Dockerfile missing"
fi

if [ -f "docker-compose.yml" ]; then
    echo "✅ Docker Compose file found"
else
    echo "❌ Docker Compose file missing"
fi

# Check required files for backend
echo "📦 Checking Backend requirements..."
if [ -f "backend/package.json" ]; then
    echo "✅ Backend package.json found"
else
    echo "❌ Backend package.json missing"
fi

if [ -f "backend/server.js" ]; then
    echo "✅ Backend server.js found"
else
    echo "❌ Backend server.js missing"
fi

# Check required files for frontend
echo "🎨 Checking Frontend requirements..."
if [ -f "frontend/package.json" ]; then
    echo "✅ Frontend package.json found"
else
    echo "❌ Frontend package.json missing"
fi

# Check if build script exists in frontend
if grep -q '"build"' frontend/package.json 2>/dev/null; then
    echo "✅ Frontend build script found"
else
    echo "❌ Frontend build script missing"
fi

# Check environment setup
echo "🔧 Checking Environment setup..."
if [ -f ".env.example" ]; then
    echo "✅ Environment template found"
else
    echo "❌ Environment template missing"
fi

echo "✨ Validation complete!"
echo "💡 To test with Docker, push to GitHub and check Actions tab"