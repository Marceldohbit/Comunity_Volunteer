# Volunteer Signup - Database Integration

## ✅ Changes Made

### Backend (server.js)
The `/api/register` endpoint saves volunteer registrations to the database:
- Validates required fields (work_id, name, email, phone)
- Checks if volunteer work exists and has capacity
- Inserts registration into `volunteer_registrations` table
- Updates volunteer count in `volunteer_works` table
- Returns registration ID on success

### Frontend (app.js)
Updated two signup methods to save to database:

#### 1. Main Volunteer Form (`handleVolunteerSignup`)
- Collects all form data (name, email, phone, community, interests, availability)
- Finds available work in selected community
- Sends data to `/api/register` endpoint
- Reloads data to show updated counts
- Shows success/error message

#### 2. Quick "Join" Button (`quickVolunteerSignup`)
- Prompts for name, email, phone
- Sends data to `/api/register` endpoint
- Updates local state and database
- Reloads data to show updated counts
- Shows success/error message

## 📊 Database Flow

```
User fills form/clicks Join
        ↓
Frontend collects data
        ↓
POST /api/register
        ↓
Validate data
        ↓
Check work capacity
        ↓
INSERT into volunteer_registrations
        ↓
UPDATE volunteer_works (increment count)
        ↓
Return success + registration_id
        ↓
Frontend reloads data
        ↓
UI shows updated counts
```

## 🗄️ Database Table Structure

### volunteer_registrations
Stores all volunteer sign-ups:
- `id` - Auto-increment primary key
- `volunteer_work_id` - Foreign key to volunteer_works
- `status` - pending/approved/rejected/completed
- `application_message` - User's message
- `motivation` - Why they want to volunteer
- `relevant_skills` - Skills/interests
- `emergency_contact_name` - Emergency contact
- `emergency_contact_phone` - Emergency phone
- `has_transportation` - Boolean
- `created_at` - Timestamp

## 🧪 Testing

### Test Main Form
1. Open `http://localhost:3000/index.html`
2. Scroll to "Volunteer" section
3. Fill in form with:
   - Name: Test User
   - Email: test@example.com
   - Phone: +237670000000
   - Select a community
   - Check some interests
   - Click "Sign Up"
4. Check database: `SELECT * FROM volunteer_registrations ORDER BY id DESC LIMIT 1;`

### Test Quick Signup
1. Scroll to "Works" section
2. Click "Join" button on any work
3. Enter name, email, phone in prompts
4. Check database for new registration

### Verify in Database
```sql
-- Check registrations
SELECT 
    vr.id,
    vr.application_message,
    vr.status,
    vr.created_at,
    vw.title as work_title
FROM volunteer_registrations vr
JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
ORDER BY vr.created_at DESC
LIMIT 10;

-- Check volunteer counts updated
SELECT id, title, volunteers_needed, volunteers_registered
FROM volunteer_works
ORDER BY id;
```

## 🎯 What Happens on Signup

1. **Frontend Validation**
   - Checks if email already registered locally
   - Validates required fields

2. **Backend Validation**
   - Checks if work exists and is published
   - Verifies work has available spots
   - Validates all required data present

3. **Database Insert**
   - Creates new registration record with status='pending'
   - Increments `volunteers_registered` count

4. **Response**
   - Success: Returns registration_id and success message
   - Error: Returns error message

5. **UI Update**
   - Reloads all data from database
   - Updates volunteer counts on work cards
   - Updates statistics counters
   - Shows success message to user

## 🔍 Check Registrations

To see all volunteer registrations:
```sql
SELECT * FROM volunteer_registrations 
WHERE deleted_at IS NULL 
ORDER BY created_at DESC;
```

To see registration with work details:
```sql
SELECT 
    vr.*,
    vw.title,
    vw.community_id,
    c.slug as community_name
FROM volunteer_registrations vr
JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
JOIN communities c ON vw.community_id = c.id
WHERE vr.deleted_at IS NULL
ORDER BY vr.created_at DESC;
```

## ✨ Features

- ✅ All signups saved to MySQL database
- ✅ Real-time volunteer count updates
- ✅ Duplicate email prevention
- ✅ Capacity checking (no over-booking)
- ✅ Form validation
- ✅ Error handling with user-friendly messages
- ✅ Automatic data reload after signup
- ✅ Local + database storage for offline support
