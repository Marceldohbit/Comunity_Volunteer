const mysql = require('mysql2/promise');
require('dotenv').config();

async function addVolunteerEmail() {
    try {
        // Database connection
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'com_serve',
            port: process.env.DB_PORT || 3306
        });

        console.log('✅ Connected to database');

        // Check if volunteer_email column exists
        const [columns] = await connection.query(`
            SELECT COLUMN_NAME 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = 'volunteer_registrations' 
            AND COLUMN_NAME = 'volunteer_email'
        `);

        if (columns.length === 0) {
            // Add volunteer_email column
            await connection.query(`
                ALTER TABLE volunteer_registrations 
                ADD COLUMN volunteer_email VARCHAR(255) DEFAULT NULL 
                AFTER volunteer_work_id
            `);
            console.log('✅ Added volunteer_email column');

            // Update existing records with placeholder emails
            await connection.query(`
                UPDATE volunteer_registrations 
                SET volunteer_email = CONCAT('volunteer_', id, '@placeholder.com') 
                WHERE volunteer_email IS NULL
            `);
            console.log('✅ Updated existing records with placeholder emails');
        } else {
            console.log('ℹ️ volunteer_email column already exists');
        }

        await connection.end();
        console.log('✅ Migration completed successfully');
    } catch (error) {
        console.error('❌ Migration failed:', error.message);
        process.exit(1);
    }
}

addVolunteerEmail();