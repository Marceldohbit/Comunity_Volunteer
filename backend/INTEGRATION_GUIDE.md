# Community Serve - Database Integration Guide

## 🚀 Setup Instructions

### 1. Database Setup
1. Open phpMyAdmin
2. Create a new database named `com_serve`
3. Import the `database.sql` file
4. Verify all tables are created with sample data

### 2. File Structure
```
com_serve/
├── api.php          # Backend API (NEW)
├── app.js           # Frontend JavaScript (UPDATED)
├── index.html       # Main HTML
├── styles.css       # Styles
└── database.sql     # Database schema
```

### 3. Configuration
Edit `api.php` if your database credentials are different:
```php
$host = 'localhost';
$dbname = 'com_serve';
$username = 'root';
$password = '';
```

### 4. Running the Application
- **Local Server Required**: You need a PHP server to run the API
- **Options**:
  1. **XAMPP/WAMP**: Place files in `htdocs` folder and access via `http://localhost/com_serve/`
  2. **PHP Built-in Server**: 
     ```bash
     cd c:\Users\INFINITY\Desktop\com_serve
     php -S localhost:8000
     ```
     Then open `http://localhost:8000` in your browser

### 5. Testing the Integration

#### Test API Endpoints:
- Communities: `http://localhost:8000/api.php?action=getCommunities`
- Works: `http://localhost:8000/api.php?action=getWorks`
- Categories: `http://localhost:8000/api.php?action=getCategories`
- Regions: `http://localhost:8000/api.php?action=getRegions`
- Stats: `http://localhost:8000/api.php?action=getStats`

## 📊 API Documentation

### GET Endpoints

#### Get Communities
```
GET api.php?action=getCommunities
```
Returns all active communities with their details.

#### Get Single Community
```
GET api.php?action=getCommunity&id={community_id}
```

#### Get Volunteer Works
```
GET api.php?action=getWorks
GET api.php?action=getWorks&community_id={id}
GET api.php?action=getWorks&category_id={id}
GET api.php?action=getWorks&search={keyword}
```

#### Get Single Work
```
GET api.php?action=getWork&id={work_id}
```

#### Get Categories
```
GET api.php?action=getCategories
```

#### Get Regions
```
GET api.php?action=getRegions
```

#### Get Statistics
```
GET api.php?action=getStats
```

### POST Endpoints

#### Register Volunteer
```
POST api.php?action=registerVolunteer
Content-Type: application/json

{
  "work_id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+237670000000",
  "interests": "Teaching, Mentoring",
  "message": "I'd love to help!",
  "emergency_name": "Jane Doe",
  "emergency_phone": "+237670000001",
  "transportation": true
}
```

## 🔧 Features

### Current Features
- ✅ Dynamic data loading from MySQL database
- ✅ Communities management
- ✅ Volunteer works listing
- ✅ Volunteer registration with database storage
- ✅ Real-time statistics
- ✅ Category and region filtering
- ✅ Search functionality
- ✅ RESTful API architecture

### Data Flow
1. **Frontend (app.js)** → Makes API calls
2. **Backend (api.php)** → Queries MySQL database
3. **Database (com_serve)** → Returns data
4. **API** → Formats and sends JSON response
5. **Frontend** → Renders data in UI

## 🗄️ Database Tables

The system uses the following tables:
- `regions` - Geographic regions
- `users` - User accounts
- `communities` - Community organizations
- `categories` - Work categories
- `volunteer_works` - Volunteer opportunities
- `volunteer_registrations` - Volunteer sign-ups
- `skills` - Available skills
- `user_skills` - User skill mappings
- `volunteer_work_skills` - Required work skills
- `notifications` - System notifications
- `activity_logs` - Activity tracking
- `system_settings` - Configuration

## 🔒 Security Notes

**For Production:**
1. Change database password
2. Add input validation
3. Implement authentication
4. Use prepared statements (already implemented)
5. Add rate limiting
6. Enable HTTPS
7. Sanitize all user inputs
8. Add CSRF protection

## 🐛 Troubleshooting

### "Database connection failed"
- Check MySQL is running
- Verify database name is `com_serve`
- Check credentials in `api.php`

### "CORS Error"
- Ensure you're accessing via `http://localhost` not `file://`
- Check CORS headers in `api.php`

### Data not loading
- Open browser console (F12) to check for errors
- Verify API endpoints are accessible
- Check database has sample data

## 📝 Sample Data

The database includes:
- 5 sample users (1 admin, 1 manager, 3 volunteers)
- 6 communities across different regions
- 9 volunteer works
- 6 categories
- 10 skills
- 10 regions (Cameroon)
- Sample registrations and activity logs

## 🚀 Next Steps

1. **Authentication**: Add user login system
2. **Admin Panel**: Create admin dashboard
3. **Image Upload**: Add community/work images
4. **Email Notifications**: Send confirmation emails
5. **Advanced Search**: Add filters and sorting
6. **User Dashboard**: Show volunteer history
7. **Mobile App**: Create mobile version

---

**Need Help?** Check the browser console for errors or review API responses in Network tab.
