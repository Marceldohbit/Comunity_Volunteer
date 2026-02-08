# Community Serve - Node.js Backend

## 🚀 Quick Start

### 1. Install Dependencies
```powershell
npm install
```

### 2. Configure Database
Edit `.env` if needed:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=com_serve
PORT=3000
```

### 3. Start Server
```powershell
npm start
```

### 4. Open Browser
```
http://localhost:3000/index.html
```

## 📌 API Endpoints

- `GET /api/communities` - All communities
- `GET /api/works` - All volunteer works
- `GET /api/categories` - All categories
- `GET /api/regions` - All regions
- `GET /api/stats` - Statistics
- `POST /api/register` - Register volunteer

## 🐛 Troubleshooting

**Cannot find module:**
```powershell
npm install
```

**Database error:**
- Check MySQL is running
- Verify credentials in `.env`

**Port already in use:**
Change `PORT=3001` in `.env`

---

For full documentation, see `INTEGRATION_GUIDE.md`
