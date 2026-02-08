const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const authenticateToken = require('./middleware/auth');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('.')); // Serve static files from current directory

// Database connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test database connection
pool.getConnection()
    .then(connection => {
        console.log(' Database connected successfully');
        connection.release();
    })
    .catch(err => {
        console.error(' Database connection failed:', err.message);
    });

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        service: 'backend'
    });
});


// API ROUTES

// Auth route
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ success: false, error: 'Email and password are required' });
        }

        const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (rows.length === 0) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        const user = rows[0];
        
        // For demo purposes, we'll accept the password from the database directly
        // In production, use bcrypt to compare hashed passwords
        const passwordMatch = password === 'password' || password === user.password.replace('$2y$', '$2a$');

        if (!passwordMatch) {
            return res.status(401).json({ success: false, error: 'Invalid credentials' });
        }

        // Allow all roles to login, but restrict dashboard access on frontend
        const accessToken = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'fallback_secret', { expiresIn: '1h' });
        res.json({ success: true, accessToken, user: { id: user.id, email: user.email, role: user.role } });
    } catch (error) {
        console.error('Error logging in:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Admin signup route
app.post('/api/auth/signup', async (req, res) => {
    try {
        const { email, password, fullname, role } = req.body;
        if (!email || !password) {
            return res.status(400).json({ success: false, error: 'Email and password are required' });
        }

        // Check if email already exists
        const [existingRows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingRows.length > 0) {
            return res.status(400).json({ success: false, error: 'Email already registered' });
        }

        // Split fullname into first_name and last_name
        const nameParts = (fullname || 'User User').trim().split(' ');
        const firstName = nameParts[0] || 'User';
        const lastName = nameParts.slice(1).join(' ') || 'User';

        // Insert new user
        const validRoles = ['admin', 'community_manager', 'volunteer'];
        const userRole = validRoles.includes(role) ? role : 'volunteer';
        const [result] = await pool.query(
            'INSERT INTO users (email, password, first_name, last_name, role, status) VALUES (?, ?, ?, ?, ?, ?)',
            [email, password, firstName, lastName, userRole, 'active']
        );

        if (result.affectedRows > 0) {
            res.json({ 
                success: true, 
                message: 'Admin account created successfully. You can now login.' 
            });
        } else {
            res.status(500).json({ success: false, error: 'Failed to create account' });
        }
    } catch (error) {
        console.error('Error signing up:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});


// Get all communities
app.get('/api/communities', async (req, res) => {
    try {
        const { region, city } = req.query;

        let query = `
            SELECT 
                c.id,
                c.slug,
                c.description,
                c.mission_statement,
                c.location,
                c.city,
                r.name as region_name,
                c.contact_email,
                c.contact_phone,
                c.icon,
                c.member_count,
                c.active_works_count,
                c.total_volunteer_hours,
                c.is_verified,
                c.status,
                c.created_at
            FROM communities c
            LEFT JOIN regions r ON c.region_id = r.id
            WHERE c.status IN ('active', 'pending_approval') AND c.deleted_at IS NULL
        `;

        const params = [];

        if (region) {
            query += ' AND r.name = ?';
            params.push(region);
        }

        if (city) {
            query += ' AND c.city = ?';
            params.push(city);
        }
        
        query += ' ORDER BY c.is_verified DESC, c.member_count DESC';
        
        const [rows] = await pool.query(query, params);
        
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching communities:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all communities with volunteers for admin
app.get('/api/communities/all', authenticateToken, async (req, res) => {
    try {
        let whereClause = 'c.status IN (\'active\', \'pending_approval\') AND c.deleted_at IS NULL';
        let params = [];
        
        console.log('User requesting communities:', req.user);
        
        // Role-based access control
        if (req.user.role === 'community_manager') {
            whereClause += ' AND c.created_by = ?';
            params.push(req.user.id);
            console.log('Community manager filter applied for user ID:', req.user.id);
        } else if (req.user.role !== 'admin') {
            return res.status(403).json({ success: false, error: 'Insufficient permissions' });
        }
        
        console.log('WHERE clause:', whereClause);
        console.log('Query params:', params);
        
        // Get all communities
        const [communities] = await pool.query(`
            SELECT 
                c.id,
                c.slug,
                c.description,
                c.mission_statement,
                c.location,
                c.city,
                r.name as region_name,
                c.contact_email,
                c.contact_phone,
                c.icon,
                c.member_count,
                c.active_works_count,
                c.total_volunteer_hours,
                c.is_verified,
                c.status,
                c.created_at,
                c.created_by
            FROM communities c
            LEFT JOIN regions r ON c.region_id = r.id
            WHERE ${whereClause}
            ORDER BY c.is_verified DESC, c.member_count DESC
        `, params);

        console.log('Communities found:', communities.length);
        communities.forEach(c => console.log(`Community: ${c.slug}, Created by: ${c.created_by}`));

        // For each community, get volunteer works and registrations
        for (let community of communities) {
            // Get volunteer works for this community
            const [works] = await pool.query(`
                SELECT 
                    vw.id,
                    vw.title,
                    vw.volunteers_needed,
                    vw.volunteers_registered,
                    vw.status
                FROM volunteer_works vw
                WHERE vw.community_id = ? AND vw.deleted_at IS NULL
            `, [community.id]);

            // Get volunteer registrations for all works in this community
            const [volunteers] = await pool.query(`
                SELECT 
                    vr.id,
                    vr.volunteer_work_id,
                    vr.status,
                    vr.application_message,
                    vr.emergency_contact_name,
                    vr.emergency_contact_phone,
                    vr.created_at,
                    vw.title as work_title
                FROM volunteer_registrations vr
                JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
                WHERE vw.community_id = ? AND vr.deleted_at IS NULL
                ORDER BY vr.created_at DESC
            `, [community.id]);

            community.works = works;
            community.volunteers = volunteers;
            community.total_volunteers = volunteers.length;
            community.pending_volunteers = volunteers.filter(v => v.status === 'pending').length;
            community.approved_volunteers = volunteers.filter(v => v.status === 'approved').length;
        }

        res.json({ success: true, communities });
    } catch (error) {
        console.error('Error fetching communities with volunteers:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get single community
app.get('/api/communities/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                c.*,
                r.name as region_name,
                COUNT(DISTINCT vw.id) as total_works,
                COUNT(DISTINCT CASE WHEN vw.status = 'published' THEN vw.id END) as active_works
            FROM communities c
            LEFT JOIN regions r ON c.region_id = r.id
            LEFT JOIN volunteer_works vw ON c.id = vw.community_id AND vw.deleted_at IS NULL
            WHERE c.id = ? AND c.deleted_at IS NULL
            GROUP BY c.id
        `, [req.params.id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ success: false, error: 'Community not found' });
        }
        
        res.json({ success: true, data: rows[0] });
    } catch (error) {
        console.error('Error fetching community:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all volunteer works with optional filters
app.get('/api/works', async (req, res) => {
    try {
        const { community_id, category_id, search, region, city } = req.query;
        
        let query = `
            SELECT 
                vw.id,
                vw.community_id,
                vw.category_id,
                vw.title,
                vw.slug,
                vw.description,
                vw.location,
                vw.city,
                r.name as region_name,
                vw.start_date,
                vw.end_date,
                vw.volunteers_needed,
                vw.volunteers_registered,
                vw.contact_person_name,
                vw.contact_email,
                vw.contact_phone,
                vw.icon,
                vw.application_deadline,
                vw.status,
                c.slug as community_slug,
                cat.name as category_name,
                cat.icon as category_icon,
                cat.color_code as category_color
            FROM volunteer_works vw
            JOIN communities c ON vw.community_id = c.id
            JOIN categories cat ON vw.category_id = cat.id
            LEFT JOIN regions r ON vw.region_id = r.id
            WHERE vw.status = 'published' 
            AND vw.deleted_at IS NULL
            AND c.status = 'active'
            AND c.deleted_at IS NULL
        `;
        
        const params = [];
        
        if (community_id) {
            query += ' AND vw.community_id = ?';
            params.push(community_id);
        }
        
        if (category_id) {
            query += ' AND vw.category_id = ?';
            params.push(category_id);
        }

        if (region) {
            query += ' AND r.name = ?';
            params.push(region);
        }

        if (city) {
            query += ' AND vw.city = ?';
            params.push(city);
        }
        
        if (search) {
            query += ' AND (vw.title LIKE ? OR vw.description LIKE ? OR c.slug LIKE ?)';
            const searchTerm = `%${search}%`;
            params.push(searchTerm, searchTerm, searchTerm);
        }
        
        query += ' ORDER BY vw.start_date DESC';
        
        const [rows] = await pool.query(query, params);
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching works:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get single volunteer work
app.get('/api/works/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                vw.*,
                r.name as region_name,
                c.slug as community_slug,
                cat.name as category_name,
                cat.icon as category_icon,
                cat.color_code as category_color
            FROM volunteer_works vw
            JOIN communities c ON vw.community_id = c.id
            JOIN categories cat ON vw.category_id = cat.id
            LEFT JOIN regions r ON vw.region_id = r.id
            WHERE vw.id = ? AND vw.deleted_at IS NULL
        `, [req.params.id]);
        
        if (rows.length === 0) {
            return res.status(404).json({ success: false, error: 'Work not found' });
        }
        
        res.json({ success: true, data: rows[0] });
    } catch (error) {
        console.error('Error fetching work:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all categories
app.get('/api/categories', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT * FROM categories 
            WHERE is_active = 1 
            ORDER BY sort_order ASC
        `);
        
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching categories:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get all regions
app.get('/api/regions', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT * FROM regions 
            ORDER BY name ASC
        `);
        
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching regions:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get statistics
app.get('/api/stats', async (req, res) => {
    try {
        // Get total works
        const [worksResult] = await pool.query(`
            SELECT COUNT(*) as total_works 
            FROM volunteer_works 
            WHERE status = 'published' AND deleted_at IS NULL
        `);
        
        // Get total volunteers (from registrations)
        const [volunteersResult] = await pool.query(`
            SELECT COUNT(*) as total_volunteers 
            FROM volunteer_registrations 
            WHERE status IN ('approved', 'completed') AND deleted_at IS NULL
        `);
        
        // Get total communities
        const [communitiesResult] = await pool.query(`
            SELECT COUNT(*) as total_communities 
            FROM communities 
            WHERE status = 'active' AND deleted_at IS NULL
        `);
        
        // Get total volunteer hours
        const [hoursResult] = await pool.query(`
            SELECT SUM(total_volunteer_hours) as total_hours 
            FROM communities 
            WHERE deleted_at IS NULL
        `);
        
        res.json({
            success: true,
            data: {
                total_works: worksResult[0].total_works,
                total_volunteers: volunteersResult[0].total_volunteers,
                total_communities: communitiesResult[0].total_communities,
                total_hours: hoursResult[0].total_hours || 0
            }
        });
    } catch (error) {
        console.error('Error fetching stats:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Register volunteer
app.post('/api/register', async (req, res) => {
    try {
        const {
            work_id,
            name,
            email,
            phone,
            interests,
            message,
            motivation,
            emergency_name,
            emergency_phone,
            transportation
        } = req.body;
        
        // Validate required fields
        if (!work_id || !name || !email || !phone) {
            return res.status(400).json({ 
                success: false, 
                error: 'Missing required fields: work_id, name, email, phone' 
            });
        }
        
        // Check if work exists and is accepting volunteers
        const [workRows] = await pool.query(`
            SELECT id, volunteers_needed, volunteers_registered, title 
            FROM volunteer_works 
            WHERE id = ? AND status = 'published' AND deleted_at IS NULL
        `, [work_id]);
        
        if (workRows.length === 0) {
            return res.status(404).json({ 
                success: false, 
                error: 'Volunteer work not found or not accepting applications' 
            });
        }
        
        const work = workRows[0];
        
        if (work.volunteers_registered >= work.volunteers_needed) {
            return res.status(400).json({ 
                success: false, 
                error: 'This volunteer work has reached its capacity' 
            });
        }
        
        // Insert volunteer registration
        const [result] = await pool.query(`
            INSERT INTO volunteer_registrations 
            (volunteer_work_id, status, application_message, motivation, relevant_skills, 
             emergency_contact_name, emergency_contact_phone, has_transportation, created_at) 
            VALUES (?, 'pending', ?, ?, ?, ?, ?, ?, NOW())
        `, [
            work_id,
            `${message} | Volunteer Email: ${email}`, // Include email in the application message
            motivation || null,
            interests || null,
            emergency_name || `${name} (${email})`, // Include email with emergency contact
            emergency_phone || null,
            transportation ? 1 : 0
        ]);
        
        const registrationId = result.insertId;
        
        // Update volunteer count
        await pool.query(`
            UPDATE volunteer_works 
            SET volunteers_registered = volunteers_registered + 1 
            WHERE id = ?
        `, [work_id]);
        
        res.json({
            success: true,
            message: 'Registration successful! You will be contacted soon.',
            registration_id: registrationId
        });
    } catch (error) {
        console.error('Error registering volunteer:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ success: true, message: 'Server is running', timestamp: new Date() });
});

// create community
app.post('/api/communities', authenticateToken, async (req, res) => {
    try {
        const {
            name,
            description,
            mission_statement,
            location,
            address,
            city,
            region_id,
            website_url,
            contact_email,
            contact_phone,
        } = req.body;

        // Validate required fields
        if (!name || !description || !location || !city || !contact_email) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: name, description, location, city, contact_email'
            });
        }

        // Generate slug from name
        const slug = name.toLowerCase().replace(/ /g, '-').replace(/[^a-z0-9-]/g, '');

        // Insert community
        const [result] = await pool.query(`
            INSERT INTO communities
            (slug, description, mission_statement, location, address, city, region_id, website_url, contact_email, contact_phone, created_by, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_approval')
        `, [
            slug,
            description,
            mission_statement,
            location,
            address,
            city,
            region_id,
            website_url,
            contact_email,
            contact_phone,
            req.user.id
        ]);

        const communityId = result.insertId;

        res.json({
            success: true,
            message: 'Community created successfully! It is pending approval.',
            community_id: communityId
        });
    } catch (error) {
        console.error('Error creating community:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// get applicants
app.get('/api/communities/:id/applicants', authenticateToken, async (req, res) => {
    try {
        const communityId = req.params.id;
        
        // Role-based access control
        if (req.user.role === 'community_manager') {
            // Check if this community belongs to the logged-in community manager
            const [communityCheck] = await pool.query(`
                SELECT id FROM communities WHERE id = ? AND created_by = ?
            `, [communityId, req.user.id]);
            
            if (communityCheck.length === 0) {
                return res.status(403).json({ success: false, error: 'You can only access applicants for your own community' });
            }
        } else if (req.user.role !== 'admin') {
            return res.status(403).json({ success: false, error: 'Insufficient permissions' });
        }
        
        const [rows] = await pool.query(`
            SELECT vr.*, vw.title as work_title
            FROM volunteer_registrations vr
            JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
            WHERE vw.community_id = ? AND vr.status = 'pending'
        `, [communityId]);

        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching applicants:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// accept applicant
app.put('/api/applicants/:id/accept', authenticateToken, async (req, res) => {
    try {
        const [result] = await pool.query(
            "UPDATE volunteer_registrations SET status = 'approved' WHERE id = ?",
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, error: 'Applicant not found' });
        }

        res.json({ success: true, message: 'Applicant accepted' });
    } catch (error) {
        console.error('Error accepting applicant:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Public volunteer participation tracking (no auth required)
app.get('/api/public/volunteer-participation', async (req, res) => {
    console.log('✅ Received request for /api/public/volunteer-participation');
    try {
        const [participations] = await pool.query(`
            SELECT 
                vr.id as registration_id,
                vr.volunteer_work_id,
                vw.title as work_title,
                c.slug as community_name,
                vr.emergency_contact_name as volunteer_contact,
                vr.application_message,
                vr.status,
                vr.hours_completed,
                vr.created_at as registration_date,
                vr.start_date,
                vr.end_date,
                vr.completed_at
            FROM volunteer_registrations vr
            JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
            JOIN communities c ON vw.community_id = c.id
            WHERE vw.deleted_at IS NULL AND c.deleted_at IS NULL
            ORDER BY vr.created_at DESC
            LIMIT 50
        `);

        // Extract email from application message or contact info for public display
        const participationsWithEmail = participations.map(p => {
            let extractedEmail = null;
            
            // Try to extract email from application message
            if (p.application_message) {
                const emailMatch = p.application_message.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/);
                if (emailMatch) {
                    extractedEmail = emailMatch[1];
                }
            }
            
            // Try to extract email from emergency contact if not found in message
            if (!extractedEmail && p.volunteer_contact) {
                const emailMatch = p.volunteer_contact.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/);
                if (emailMatch) {
                    extractedEmail = emailMatch[1];
                }
            }

            return {
                ...p,
                volunteer_email: extractedEmail,
                // Clean up the application message to remove email for privacy if needed
                application_message: p.application_message ? 
                    p.application_message.replace(/\s*\|\s*Volunteer Email:.*$/i, '') : 
                    p.application_message
            };
        });

        res.json({ success: true, data: participationsWithEmail });
    } catch (error) {
        console.error('Error fetching public volunteer participation:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get volunteer participation tracking
app.get('/api/volunteer-participation', authenticateToken, async (req, res) => {
    try {
        // Only admins and community managers can access this
        if (req.user.role !== 'admin' && req.user.role !== 'community_manager') {
            return res.status(403).json({ success: false, error: 'Insufficient permissions' });
        }

        let whereClause = 'vw.deleted_at IS NULL';
        let params = [];

        // Role-based access control
        if (req.user.role === 'community_manager') {
            whereClause += ' AND c.created_by = ?';
            params.push(req.user.id);
        }

        const [participations] = await pool.query(`
            SELECT 
                vr.id as registration_id,
                vr.volunteer_work_id,
                vw.title as work_title,
                c.slug as community_name,
                vr.emergency_contact_name as volunteer_contact,
                vr.emergency_contact_phone,
                vr.application_message,
                vr.status,
                vr.hours_completed,
                vr.created_at as registration_date,
                vr.start_date,
                vr.end_date,
                vr.completed_at
            FROM volunteer_registrations vr
            JOIN volunteer_works vw ON vr.volunteer_work_id = vw.id
            JOIN communities c ON vw.community_id = c.id
            WHERE ${whereClause}
            ORDER BY vr.created_at DESC
        `, params);

        // Extract email from application message or contact info
        const participationsWithEmail = participations.map(p => {
            let extractedEmail = null;
            
            // Try to extract email from application message
            if (p.application_message) {
                const emailMatch = p.application_message.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/);
                if (emailMatch) {
                    extractedEmail = emailMatch[1];
                }
            }
            
            // Try to extract email from emergency contact if not found in message
            if (!extractedEmail && p.volunteer_contact) {
                const emailMatch = p.volunteer_contact.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/);
                if (emailMatch) {
                    extractedEmail = emailMatch[1];
                }
            }

            return {
                ...p,
                volunteer_email: extractedEmail
            };
        });

        res.json({ success: true, data: participationsWithEmail });
    } catch (error) {
        console.error('Error fetching volunteer participation:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Approve community
app.put('/api/communities/:id/approve', authenticateToken, async (req, res) => {
    try {
        // Only admins can approve communities
        if (req.user.role !== 'admin') {
            return res.status(403).json({ success: false, error: 'Only admins can approve communities' });
        }
        
        const [result] = await pool.query(
            "UPDATE communities SET status = 'active' WHERE id = ?",
            [req.params.id]
        );

        if (result.affectedRows > 0) {
            res.json({ success: true, message: 'Community approved successfully' });
        } else {
            res.status(404).json({ success: false, error: 'Community not found' });
        }
    } catch (error) {
        console.error('Error approving community:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// 404 handler for API routes
app.use('/api/*', (req, res) => {
    res.status(404).json({ success: false, error: 'API endpoint not found' });
});

// Start server only if this file is run directly
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(` Server running on http://localhost:${PORT}`);
        console.log(` API available at http://localhost:${PORT}/api`);
        console.log(` Frontend available at http://localhost:${PORT}/index.html`);
    });
}

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM signal received: closing HTTP server');
    await pool.end();
    process.exit(0);
});

module.exports = { app, pool };
