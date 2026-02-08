# Docker Deployment Guide

This guide explains how to deploy the Community Volunteer application using Docker.

## Prerequisites

- Docker and Docker Compose installed on your system
- Git (to clone the repository)

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd com_serve
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your desired configuration.

3. **Build and run with Docker Compose:**
   ```bash
   docker-compose up --build
   ```

4. **Access the application:**
   - Frontend: http://localhost
   - Backend API: http://localhost:5000
   - Database: localhost:3306

## Services

### Frontend (React + Nginx)
- **Port:** 80
- **Technology:** React with Vite, served by Nginx
- **Features:** 
  - Production-optimized build
  - SPA routing support
  - API proxy to backend
  - Static asset caching

### Backend (Node.js + Express)
- **Port:** 5000
- **Technology:** Node.js with Express
- **Features:**
  - RESTful API
  - JWT authentication
  - Database connectivity
  - Health checks

### Database (MySQL)
- **Port:** 3306
- **Technology:** MySQL 8.0
- **Features:**
  - Automatic schema initialization
  - Persistent data storage
  - Health monitoring

## Docker Commands

### Development Mode
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Mode
```bash
# Build and start
docker-compose -f docker-compose.yml up --build -d

# Update services
docker-compose pull
docker-compose up -d
```

### Management Commands
```bash
# Rebuild specific service
docker-compose build backend
docker-compose up -d backend

# Access service shell
docker-compose exec backend sh
docker-compose exec mysql mysql -u root -p

# View service status
docker-compose ps

# Remove everything (including volumes)
docker-compose down -v
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `rootpassword` |
| `MYSQL_DATABASE` | Database name | `com_serve` |
| `MYSQL_USER` | Database user | `com_serve_user` |
| `MYSQL_PASSWORD` | Database password | `userpassword` |
| `JWT_SECRET` | JWT signing secret | `your-super-secret-jwt-key` |

## Health Checks

All services include health checks:
- **Frontend:** HTTP check on port 80
- **Backend:** Custom Node.js health endpoint
- **Database:** MySQL ping command

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Change ports in docker-compose.yml
   ports:
     - "8080:80"  # Frontend on port 8080
     - "5001:5000"  # Backend on port 5001
   ```

2. **Database connection errors:**
   - Wait for MySQL to fully initialize (can take 30-60 seconds)
   - Check environment variables match between services

3. **Frontend not loading:**
   - Ensure backend is running and healthy
   - Check nginx configuration

### Viewing Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs mysql

# Follow logs in real-time
docker-compose logs -f
```

## Security Notes

**For Production:**
1. Change all default passwords
2. Use strong JWT secrets
3. Enable HTTPS
4. Configure firewall rules
5. Regular security updates

## Performance Optimization

1. **Multi-stage builds** reduce image size
2. **Health checks** ensure service reliability
3. **Volume mounting** for persistent data
4. **Network isolation** between services

## Backup and Recovery

### Database Backup
```bash
docker-compose exec mysql mysqldump -u root -p com_serve > backup.sql
```

### Database Restore
```bash
docker-compose exec -T mysql mysql -u root -p com_serve < backup.sql
```