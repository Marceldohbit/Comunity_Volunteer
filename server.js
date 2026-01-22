const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bodyParser = require('body-parser');
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


// API ROUTES


// Get all communities
app.get('/api/communities', async (req, res) => {
    try {
        const [rows] = await pool.query(`
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
            WHERE c.status = 'active' AND c.deleted_at IS NULL
            ORDER BY c.is_verified DESC, c.member_count DESC
        `);
        
        res.json({ success: true, data: rows });
    } catch (error) {
        console.error('Error fetching communities:', error);
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
        const { community_id, category_id, search } = req.query;
        
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
            message || `Application from ${name}`,
            motivation || null,
            interests || null,
            emergency_name || null,
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

// 404 handler for API routes
app.use('/api/*', (req, res) => {
    res.status(404).json({ success: false, error: 'API endpoint not found' });
});

// Start server
app.listen(PORT, () => {
    console.log(` Server running on http://localhost:${PORT}`);
    console.log(` API available at http://localhost:${PORT}/api`);
    console.log(` Frontend available at http://localhost:${PORT}/index.html`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM signal received: closing HTTP server');
    await pool.end();
    process.exit(0);
});
