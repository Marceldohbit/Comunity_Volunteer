-- Add volunteer_email column to volunteer_registrations table
ALTER TABLE `volunteer_registrations` 
ADD COLUMN `volunteer_email` varchar(255) DEFAULT NULL 
AFTER `volunteer_work_id`;

-- Update existing records to add email from emergency contact info if available
-- This is just for existing data, new registrations will have email directly
UPDATE `volunteer_registrations` 
SET `volunteer_email` = CONCAT('volunteer_', id, '@example.com') 
WHERE `volunteer_email` IS NULL;