-- ============================================================
-- Community Volunteer Management System Database Schema
-- ============================================================
-- Created: December 17, 2025
-- Description: Comprehensive database schema for managing 
--              community volunteer organizations, works, and volunteers
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================
-- DATABASE CONFIGURATION
-- ============================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Create database (uncomment if needed)
-- CREATE DATABASE IF NOT EXISTS `community_volunteer` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE `community_volunteer`;

-- ============================================================
-- TABLE: regions
-- Purpose: Manage regions/states
-- ============================================================

DROP TABLE IF EXISTS `regions`;
CREATE TABLE `regions` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_regions_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: users
-- Purpose: Core user authentication and profile management
-- ============================================================

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `region_id` bigint(20) UNSIGNED DEFAULT NULL,
  `emergency_contact_phone` varchar(20) DEFAULT NULL,
  `role` enum('admin','community_manager','volunteer','guest') NOT NULL DEFAULT 'volunteer',
  `status` enum('active','inactive','suspended','pending_verification') NOT NULL DEFAULT 'pending_verification',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `idx_users_status` (`status`),
  KEY `idx_users_role` (`role`),
  KEY `idx_users_city` (`city`),
  KEY `idx_users_region_id` (`region_id`),
  KEY `idx_users_deleted_at` (`deleted_at`),
  CONSTRAINT `users_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: communities
-- Purpose: Manage volunteer communities and organizations
-- ============================================================

DROP TABLE IF EXISTS `communities`;
CREATE TABLE `communities` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `mission_statement` text DEFAULT NULL,
  `location` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `region_id` bigint(20) UNSIGNED DEFAULT NULL,
  `website_url` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) NOT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `logo_image` varchar(255) DEFAULT NULL,
  `banner_image` varchar(255) DEFAULT NULL,
  `icon` varchar(100) DEFAULT 'fa-home',
  `member_count` int(11) NOT NULL DEFAULT 0,
  `active_works_count` int(11) NOT NULL DEFAULT 0,
  `total_volunteer_hours` bigint(20) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','pending_approval','suspended') NOT NULL DEFAULT 'pending_approval',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `communities_slug_unique` (`slug`),
  KEY `idx_communities_status` (`status`),
  KEY `idx_communities_city` (`city`),
  KEY `idx_communities_region_id` (`region_id`),
  KEY `idx_communities_is_verified` (`is_verified`),
  KEY `idx_communities_created_by` (`created_by`),
  KEY `idx_communities_deleted_at` (`deleted_at`),
  CONSTRAINT `communities_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `communities_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: categories
-- Purpose: Categorize volunteer works and opportunities
-- ============================================================

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `color_code` varchar(7) DEFAULT NULL,
  `icon` varchar(100) DEFAULT 'fa-hand-heart',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`),
  KEY `idx_categories_is_active` (`is_active`),
  KEY `idx_categories_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: volunteer_works
-- Purpose: Manage volunteer opportunities and projects
-- ============================================================

DROP TABLE IF EXISTS `volunteer_works`;
CREATE TABLE `volunteer_works` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `community_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `objectives` text DEFAULT NULL,
  `requirements` text DEFAULT NULL,
  `benefits` text DEFAULT NULL,
  `location` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `region_id` bigint(20) UNSIGNED DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `volunteers_needed` int(11) NOT NULL DEFAULT 1,
  `volunteers_registered` int(11) NOT NULL DEFAULT 0,
  `min_age_requirement` int(11) DEFAULT NULL,
  `max_age_requirement` int(11) DEFAULT NULL,
  `skills_required` text DEFAULT NULL,
  `time_commitment_hours` int(11) DEFAULT NULL,
  `time_commitment_description` varchar(255) DEFAULT NULL,
  `contact_person_name` varchar(200) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `featured_image` varchar(255) DEFAULT NULL,
  `gallery_images` json DEFAULT NULL,
  `icon` varchar(100) DEFAULT 'fa-hand-heart',
  `is_training_provided` tinyint(1) NOT NULL DEFAULT 0,
  `is_background_check_required` tinyint(1) NOT NULL DEFAULT 0,
  `application_deadline` date DEFAULT NULL,
  `status` enum('draft','published','in_progress','completed','cancelled','on_hold') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `volunteer_works_slug_unique` (`slug`),
  KEY `idx_volunteer_works_community_id` (`community_id`),
  KEY `idx_volunteer_works_category_id` (`category_id`),
  KEY `idx_volunteer_works_status` (`status`),
  KEY `idx_volunteer_works_start_date` (`start_date`),
  KEY `idx_volunteer_works_city` (`city`),
  KEY `idx_volunteer_works_region_id` (`region_id`),
  KEY `idx_volunteer_works_created_by` (`created_by`),
  KEY `idx_volunteer_works_deleted_at` (`deleted_at`),
  CONSTRAINT `volunteer_works_community_id_foreign` FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `volunteer_works_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `volunteer_works_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `volunteer_works_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: volunteer_registrations
-- Purpose: Track volunteer sign-ups and applications
-- ============================================================

DROP TABLE IF EXISTS `volunteer_registrations`;
CREATE TABLE `volunteer_registrations` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `volunteer_work_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','approved','rejected','withdrawn','completed') NOT NULL DEFAULT 'pending',
  `application_message` text DEFAULT NULL,
  `motivation` text DEFAULT NULL,
  `relevant_skills` text DEFAULT NULL,
  `availability_notes` text DEFAULT NULL,
  `emergency_contact_name` varchar(200) DEFAULT NULL,
  `emergency_contact_phone` varchar(20) DEFAULT NULL,
  `emergency_contact_relationship` varchar(100) DEFAULT NULL,
  `has_transportation` tinyint(1) DEFAULT NULL,
  `dietary_restrictions` text DEFAULT NULL,
  `medical_conditions` text DEFAULT NULL,
  `background_check_status` enum('not_required','pending','approved','rejected') DEFAULT 'not_required',
  `background_check_date` date DEFAULT NULL,
  `training_completion_status` enum('not_required','pending','in_progress','completed') DEFAULT 'not_required',
  `training_completion_date` date DEFAULT NULL,
  `hours_committed` decimal(8,2) DEFAULT 0.00,
  `hours_completed` decimal(8,2) DEFAULT 0.00,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `feedback_rating` decimal(3,2) DEFAULT NULL,
  `feedback_comment` text DEFAULT NULL,
  `supervisor_notes` text DEFAULT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_volunteer_registrations_status` (`status`),
  KEY `idx_volunteer_registrations_volunteer_work_id` (`volunteer_work_id`),
  KEY `idx_volunteer_registrations_reviewed_by` (`reviewed_by`),
  KEY `idx_volunteer_registrations_deleted_at` (`deleted_at`),
  CONSTRAINT `volunteer_registrations_volunteer_work_id_foreign` FOREIGN KEY (`volunteer_work_id`) REFERENCES `volunteer_works` (`id`) ON DELETE CASCADE,
  CONSTRAINT `volunteer_registrations_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: community_members
-- Purpose: Track community memberships and roles
-- ============================================================

DROP TABLE IF EXISTS `community_members`;
CREATE TABLE `community_members` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role` enum('member','volunteer_coordinator','admin','owner') NOT NULL DEFAULT 'member',
  `status` enum('active','inactive','pending','suspended') NOT NULL DEFAULT 'pending',
  `join_date` date NOT NULL,
  `contribution_hours` bigint(20) NOT NULL DEFAULT 0,
  `volunteer_works_completed` int(11) NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_community_members_role` (`role`),
  KEY `idx_community_members_status` (`status`),
  KEY `idx_community_members_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- TABLE: skills
-- Purpose: Manage available skills for matching volunteers to works
-- ============================================================

DROP TABLE IF EXISTS `skills`;
CREATE TABLE `skills` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `skills_slug_unique` (`slug`),
  KEY `idx_skills_is_active` (`is_active`),
  KEY `idx_skills_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: user_skills
-- Purpose: Link users with their skills and proficiency levels
-- ============================================================

DROP TABLE IF EXISTS `user_skills`;
CREATE TABLE `user_skills` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `skill_id` bigint(20) UNSIGNED NOT NULL,
  `proficiency_level` enum('beginner','intermediate','advanced','expert') NOT NULL DEFAULT 'beginner',
  `years_experience` int(11) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_skills_user_skill_unique` (`user_id`,`skill_id`),
  KEY `idx_user_skills_skill_id` (`skill_id`),
  KEY `idx_user_skills_proficiency_level` (`proficiency_level`),
  CONSTRAINT `user_skills_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_skills_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: volunteer_work_skills
-- Purpose: Link volunteer works with required skills
-- ============================================================

DROP TABLE IF EXISTS `volunteer_work_skills`;
CREATE TABLE `volunteer_work_skills` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `volunteer_work_id` bigint(20) UNSIGNED NOT NULL,
  `skill_id` bigint(20) UNSIGNED NOT NULL,
  `required_proficiency` enum('beginner','intermediate','advanced','expert') NOT NULL DEFAULT 'beginner',
  `is_mandatory` tinyint(1) NOT NULL DEFAULT 0,
  `weight` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `volunteer_work_skills_work_skill_unique` (`volunteer_work_id`,`skill_id`),
  KEY `idx_volunteer_work_skills_skill_id` (`skill_id`),
  CONSTRAINT `volunteer_work_skills_volunteer_work_id_foreign` FOREIGN KEY (`volunteer_work_id`) REFERENCES `volunteer_works` (`id`) ON DELETE CASCADE,
  CONSTRAINT `volunteer_work_skills_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: notifications
-- Purpose: System notifications and communications
-- ============================================================

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `data` json NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`),
  KEY `idx_notifications_read_at` (`read_at`),
  KEY `idx_notifications_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: activity_logs
-- Purpose: Track system activities and changes
-- ============================================================

DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `log_name` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `causer_type` varchar(255) DEFAULT NULL,
  `causer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `properties` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `subject` (`subject_type`,`subject_id`),
  KEY `causer` (`causer_type`,`causer_id`),
  KEY `activity_log_log_name_index` (`log_name`),
  KEY `idx_activity_logs_event` (`event`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: system_settings
-- Purpose: Application configuration and settings
-- ============================================================

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `type` enum('string','integer','boolean','json','text') NOT NULL DEFAULT 'string',
  `group` varchar(100) DEFAULT 'general',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `system_settings_key_unique` (`key`),
  KEY `idx_system_settings_group` (`group`),
  KEY `idx_system_settings_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- INSERT DEFAULT DATA
-- ============================================================

-- Insert default categories
INSERT INTO `categories` (`name`, `slug`, `description`, `color_code`, `icon`, `is_active`, `sort_order`) VALUES
('Education & Tutoring', 'education', 'Educational support, tutoring, literacy programs, and academic assistance', '#3498db', 'fa-graduation-cap', 1, 1),
('Environmental Conservation', 'environment', 'Environmental cleanup, conservation projects, and sustainability initiatives', '#27ae60', 'fa-leaf', 1, 2),
('Health & Wellness', 'health', 'Healthcare support, wellness programs, and medical assistance', '#e74c3c', 'fa-heartbeat', 1, 3),
('Social Services', 'social', 'Community outreach, social support, and assistance programs', '#9b59b6', 'fa-hands-helping', 1, 4),
('Youth Development', 'youth', 'Youth programs, mentorship, and skill development for young people', '#f39c12', 'fa-child', 1, 5),
('Elderly Care', 'elderly', 'Senior support, companionship, and assistance for elderly community members', '#e67e22', 'fa-heart', 1, 6);

-- Insert regions (Cameroon)
INSERT INTO `regions` (`id`, `name`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Center', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(2, 'Littoral', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(3, 'West', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(4, 'North', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(5, 'Far North', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(6, 'Adamawa', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(7, 'East', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(8, 'South', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(9, 'Southwest', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00'),
(10, 'Northwest', NULL, '2025-10-21 07:00:00', '2025-10-21 07:00:00');

-- Insert default skills
INSERT INTO `skills` (`name`, `slug`, `description`, `category`, `is_active`) VALUES
('Teaching & Tutoring', 'teaching-tutoring', 'Ability to teach and provide educational support', 'Education', 1),
('Event Organization', 'event-organization', 'Planning and organizing community events and activities', 'Management', 1),
('First Aid & CPR', 'first-aid-cpr', 'Certified in first aid and CPR emergency response', 'Healthcare', 1),
('Gardening & Landscaping', 'gardening-landscaping', 'Knowledge of plants, gardening, and landscape maintenance', 'Environment', 1),
('Computer & Technology', 'computer-technology', 'Technical skills with computers and digital tools', 'Technology', 1),
('Language Translation', 'language-translation', 'Multilingual abilities and translation services', 'Communication', 1),
('Counseling & Support', 'counseling-support', 'Emotional support and basic counseling skills', 'Mental Health', 1),
('Construction & Repair', 'construction-repair', 'Building, repair, and maintenance skills', 'Manual Labor', 1),
('Art & Creativity', 'art-creativity', 'Artistic abilities and creative project skills', 'Arts', 1),
('Sports & Recreation', 'sports-recreation', 'Athletic abilities and recreational activity leadership', 'Sports', 1);

-- Insert sample users
INSERT INTO `users` (`id`, `email`, `password`, `first_name`, `last_name`, `phone`, `date_of_birth`, `gender`, `city`, `region_id`, `emergency_contact_phone`, `role`, `status`, `last_login_at`) VALUES
(1, 'admin@communityserve.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System', 'Administrator', '+237670000001', '1985-05-15', 'male', 'Yaoundé', 1, '+237670000002', 'admin', 'active', NOW()),
(2, 'manager@communityserve.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Marie', 'Nkolo', '+237670000011', '1990-08-22', 'female', 'Douala', 2, '+237670000012', 'community_manager', 'active', NOW()),
(3, 'volunteer1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jean', 'Mbarga', '+237670000021', '1995-03-10', 'male', 'Bafoussam', 3, '+237670000022', 'volunteer', 'active', NOW()),
(4, 'volunteer2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Grace', 'Fouda', '+237670000031', '1992-11-05', 'female', 'Yaoundé', 1, '+237670000032', 'volunteer', 'active', NOW()),
(5, 'volunteer3@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Paul', 'Eto\'o', '+237670000041', '1998-07-18', 'male', 'Douala', 2, '+237670000042', 'volunteer', 'active', NOW());

-- Insert sample communities
INSERT INTO `communities` (`id`, `slug`, `description`, `mission_statement`, `location`, `address`, `city`, `region_id`, `website_url`, `contact_email`, `contact_phone`, `logo_image`, `icon`, `member_count`, `active_works_count`, `is_verified`, `status`, `created_by`) VALUES
(1, 'green-valley-neighborhood', 'A vibrant community focused on environmental sustainability and family-friendly activities.', 'Creating a sustainable and thriving community for all residents', 'Green Valley, Yaoundé', 'Quartier Bastos', 'Yaoundé', 1, 'https://greenvalley.org', 'info@greenvalley.org', '+237670100001', NULL, 'fa-home', 248, 12, 1, 'active', 2),
(2, 'downtown-urban-center', 'Urban community working on homelessness, education, and community development.', 'Building inclusive urban spaces that serve everyone', 'Downtown Douala', 'Akwa District', 'Douala', 2, 'https://downtownurban.org', 'contact@downtownurban.org', '+237670100002', NULL, 'fa-building', 189, 8, 1, 'active', 2),
(3, 'riverside-youth-network', 'Dedicated to youth development, mentorship, and educational support programs.', 'Empowering the next generation through education and mentorship', 'Riverside', 'Near University', 'Bafoussam', 3, NULL, 'youth@riverside.org', '+237670100003', NULL, 'fa-graduation-cap', 156, 15, 1, 'active', 2),
(4, 'elderly-care-alliance', 'Supporting seniors through companionship, healthcare assistance, and social activities.', 'Ensuring dignity and quality of life for our elders', 'Citywide', 'Multiple Locations', 'Yaoundé', 1, NULL, 'care@elderlyalliance.org', '+237670100004', NULL, 'fa-heart', 97, 6, 1, 'active', 2),
(5, 'environmental-action-group', 'Community-driven environmental conservation and cleanup initiatives.', 'Protecting our environment for future generations', 'Various Locations', 'Mobile Operations', 'Douala', 2, 'https://enviroaction.org', 'info@enviroaction.org', '+237670100005', NULL, 'fa-leaf', 312, 9, 1, 'active', 2),
(6, 'food-security-network', 'Fighting hunger through food banks, community gardens, and nutrition education.', 'No one should go hungry in our community', 'Multiple Districts', 'Central Hub, Bastos', 'Yaoundé', 1, NULL, 'help@foodsecurity.org', '+237670100006', NULL, 'fa-utensils', 203, 11, 1, 'active', 2);

-- Insert sample volunteer works
INSERT INTO `volunteer_works` (`id`, `community_id`, `category_id`, `title`, `slug`, `description`, `objectives`, `requirements`, `location`, `address`, `city`, `region_id`, `start_date`, `end_date`, `volunteers_needed`, `volunteers_registered`, `min_age_requirement`, `contact_person_name`, `contact_email`, `contact_phone`, `icon`, `is_training_provided`, `is_background_check_required`, `application_deadline`, `status`, `created_by`) VALUES
(1, 1, 2, 'Community Garden Expansion', 'community-garden-expansion', 'Expanding our community garden to provide fresh produce for local food banks and teach sustainable gardening practices.', 'Increase food production, educate community members on sustainable agriculture', 'Physical fitness, willingness to work outdoors, no prior experience needed', 'Green Valley Park', 'Bastos District', 'Yaoundé', 1, '2025-01-15', '2025-04-30', 20, 14, 16, 'Marie Nkolo', 'info@greenvalley.org', '+237670100001', 'fa-seedling', 1, 0, '2025-01-10', 'published', 2),
(2, 3, 1, 'After-School Tutoring Program', 'after-school-tutoring-program', 'Providing academic support and mentorship for elementary and middle school students in math, reading, and science.', 'Improve student academic performance, provide mentorship', 'Teaching experience or strong academic background required', 'Riverside Community Center', 'Near University Campus', 'Bafoussam', 3, '2025-01-08', '2025-06-15', 15, 12, 18, 'Jean Mbarga', 'youth@riverside.org', '+237670100003', 'fa-book', 1, 1, '2025-01-05', 'published', 2),
(3, 4, 6, 'Senior Companion Program', 'senior-companion-program', 'Weekly visits and companionship for elderly residents in nursing homes and assisted living facilities.', 'Reduce loneliness, provide social interaction for seniors', 'Patience, good communication skills, commitment to weekly visits', 'Various Nursing Homes', 'Multiple Locations', 'Yaoundé', 1, '2025-01-01', '2025-12-31', 25, 18, 18, 'Grace Fouda', 'care@elderlyalliance.org', '+237670100004', 'fa-heart', 1, 1, NULL, 'published', 2),
(4, 5, 2, 'Beach Cleanup Initiative', 'beach-cleanup-initiative', 'Monthly beach cleanup to remove plastic waste and protect marine life along the Douala coastline.', 'Clean beaches, raise environmental awareness', 'Ability to walk on beach terrain, commitment to monthly participation', 'Douala Beaches', 'Coastal Areas', 'Douala', 2, '2025-01-20', NULL, 30, 22, 14, 'Paul Eto\'o', 'info@enviroaction.org', '+237670100005', 'fa-water', 0, 0, '2025-01-15', 'published', 2),
(5, 2, 4, 'Homeless Outreach Program', 'homeless-outreach-program', 'Providing meals, clothing, and support services to homeless individuals in downtown areas.', 'Address immediate needs of homeless population, connect with services', 'Compassion, non-judgmental attitude, safety training provided', 'Downtown Douala', 'Akwa District', 'Douala', 2, '2024-12-01', '2025-11-30', 40, 28, 18, 'Marie Nkolo', 'contact@downtownurban.org', '+237670100002', 'fa-hands-helping', 1, 0, NULL, 'published', 2),
(6, 6, 4, 'Community Food Bank', 'community-food-bank', 'Sorting, packing, and distributing food to families in need through our network of food banks.', 'Provide food assistance to struggling families', 'Ability to lift 25 lbs, organized, reliable', 'Food Security Hub', 'Central Hub, Bastos', 'Yaoundé', 1, '2025-01-10', NULL, 35, 26, 16, 'Grace Fouda', 'help@foodsecurity.org', '+237670100006', 'fa-box', 1, 0, NULL, 'published', 2),
(7, 3, 5, 'Youth Sports Mentorship', 'youth-sports-mentorship', 'Coaching and mentoring youth in various sports activities while teaching life skills and teamwork.', 'Promote physical fitness, teach teamwork and leadership', 'Sports background, experience working with youth', 'Community Sports Fields', 'University Sports Complex', 'Bafoussam', 3, '2025-02-01', '2025-07-31', 18, 10, 21, 'Jean Mbarga', 'youth@riverside.org', '+237670100003', 'fa-futbol', 1, 1, '2025-01-25', 'published', 2),
(8, 1, 1, 'Digital Literacy Classes', 'digital-literacy-classes', 'Teaching basic computer skills and internet safety to senior citizens and adults with limited tech experience.', 'Bridge digital divide, improve tech literacy', 'Computer proficiency, patience, teaching ability', 'Community Center', 'Bastos Community Hall', 'Yaoundé', 1, '2025-01-12', '2025-05-30', 12, 8, 18, 'Marie Nkolo', 'info@greenvalley.org', '+237670100001', 'fa-laptop', 1, 0, '2025-01-08', 'published', 2),
(9, 5, 2, 'Tree Planting Campaign', 'tree-planting-campaign', 'Large-scale tree planting initiative to combat deforestation and improve air quality in urban areas.', 'Plant 5000 trees, raise environmental awareness', 'Physical ability, willingness to work outdoors', 'Various Parks', 'Multiple City Parks', 'Douala', 2, '2025-03-01', '2025-03-15', 50, 35, 14, 'Paul Eto\'o', 'info@enviroaction.org', '+237670100005', 'fa-tree', 1, 0, '2025-02-25', 'published', 2);

-- Insert sample volunteer registrations
INSERT INTO `volunteer_registrations` (`volunteer_work_id`, `status`, `application_message`, `motivation`, `relevant_skills`, `has_transportation`, `hours_committed`, `hours_completed`, `start_date`, `approved_at`) VALUES
(1, 'approved', 'I would love to help with the garden expansion.', 'Passionate about sustainable living and community agriculture', 'Basic gardening knowledge, physical fitness', 1, 40.00, 25.00, '2025-01-15', '2025-01-12 10:00:00'),
(2, 'approved', 'I have teaching experience and want to help students succeed.', 'Education is the key to breaking poverty cycles', 'Teaching, math tutoring, mentorship', 1, 60.00, 45.00, '2025-01-08', '2025-01-06 14:30:00'),
(3, 'approved', 'My grandmother was in a nursing home, I understand the importance of companionship.', 'Want to give back and brighten someone\'s day', 'Good listener, patient, compassionate', 0, 52.00, 30.00, '2025-01-01', '2024-12-28 09:15:00'),
(4, 'approved', 'Environmental conservation is my passion!', 'Protecting our beaches and marine life is critical', 'Beach cleanup experience, environmental awareness', 1, 24.00, 16.00, '2025-01-20', '2025-01-18 11:00:00'),
(5, 'completed', 'I want to help those less fortunate in our community.', 'Everyone deserves dignity and basic necessities', 'Empathy, communication, organization', 1, 80.00, 80.00, '2024-12-01', '2024-11-28 16:00:00'),
(6, 'approved', 'Happy to help sort and distribute food to families.', 'No one should go hungry', 'Organization, physical strength, reliability', 1, 50.00, 35.00, '2025-01-10', '2025-01-08 13:00:00'),
(7, 'pending', 'Former athlete wanting to mentor youth.', 'Sports taught me discipline and teamwork', 'Basketball coaching, youth mentorship', 1, 40.00, 0.00, NULL, NULL),
(8, 'approved', 'Tech professional wanting to help seniors learn computers.', 'Technology should be accessible to everyone', 'Computer training, IT support, patience', 1, 30.00, 20.00, '2025-01-12', '2025-01-10 10:30:00');

-- Insert sample user skills
INSERT INTO `user_skills` (`user_id`, `skill_id`, `proficiency_level`, `years_experience`, `is_verified`) VALUES
(3, 1, 'intermediate', 3, 1),
(3, 4, 'advanced', 5, 1),
(4, 7, 'advanced', 4, 1),
(4, 1, 'beginner', 1, 0),
(5, 5, 'expert', 8, 1),
(5, 10, 'advanced', 6, 1);

-- Insert sample volunteer work skills
INSERT INTO `volunteer_work_skills` (`volunteer_work_id`, `skill_id`, `required_proficiency`, `is_mandatory`, `weight`) VALUES
(1, 4, 'beginner', 0, 3),
(2, 1, 'intermediate', 1, 5),
(3, 7, 'intermediate', 0, 4),
(5, 7, 'beginner', 0, 2),
(6, 2, 'beginner', 0, 2),
(7, 10, 'intermediate', 1, 5),
(8, 5, 'advanced', 1, 5);

-- Insert sample notifications
INSERT INTO `notifications` (`id`, `type`, `notifiable_type`, `notifiable_id`, `data`, `read_at`) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'App\\Notifications\\VolunteerRegistrationApproved', 'App\\Models\\User', 3, '{"message":"Your registration for Community Garden Expansion has been approved!","work_id":1,"work_title":"Community Garden Expansion"}', '2025-01-12 15:00:00'),
('550e8400-e29b-41d4-a716-446655440002', 'App\\Notifications\\VolunteerRegistrationApproved', 'App\\Models\\User', 4, '{"message":"Your registration for After-School Tutoring Program has been approved!","work_id":2,"work_title":"After-School Tutoring Program"}', NULL),
('550e8400-e29b-41d4-a716-446655440003', 'App\\Notifications\\NewVolunteerWork', 'App\\Models\\User', 3, '{"message":"New volunteer opportunity: Tree Planting Campaign","work_id":9,"work_title":"Tree Planting Campaign"}', NULL),
('550e8400-e29b-41d4-a716-446655440004', 'App\\Notifications\\VolunteerRegistrationPending', 'App\\Models\\User', 2, '{"message":"New volunteer application for Youth Sports Mentorship","work_id":7,"applicant":"Jean Mbarga"}', NULL);

-- Insert sample activity logs
INSERT INTO `activity_logs` (`log_name`, `description`, `subject_type`, `event`, `subject_id`, `causer_type`, `causer_id`, `properties`) VALUES
('volunteer_work', 'Volunteer work created', 'App\\Models\\VolunteerWork', 'created', 1, 'App\\Models\\User', 2, '{"attributes":{"title":"Community Garden Expansion","status":"published"}}'),
('volunteer_work', 'Volunteer work created', 'App\\Models\\VolunteerWork', 'created', 2, 'App\\Models\\User', 2, '{"attributes":{"title":"After-School Tutoring Program","status":"published"}}'),
('community', 'Community created', 'App\\Models\\Community', 'created', 1, 'App\\Models\\User', 2, '{"attributes":{"name":"Green Valley Neighborhood","status":"active"}}'),
('registration', 'Volunteer registration approved', 'App\\Models\\VolunteerRegistration', 'updated', 1, 'App\\Models\\User', 2, '{"old":{"status":"pending"},"attributes":{"status":"approved"}}'),
('registration', 'Volunteer registration completed', 'App\\Models\\VolunteerRegistration', 'updated', 5, 'App\\Models\\User', 2, '{"old":{"status":"approved"},"attributes":{"status":"completed"}}');

-- Insert default system settings
INSERT INTO `system_settings` (`key`, `value`, `type`, `group`, `description`, `is_public`) VALUES
('app_name', 'Community Serve', 'string', 'general', 'Application name', 1),
('app_description', 'A platform for community volunteer management and coordination', 'string', 'general', 'Application description', 1),
('default_timezone', 'UTC', 'string', 'general', 'Default timezone for the application', 0),
('registration_enabled', '1', 'boolean', 'registration', 'Whether new user registration is enabled', 1),
('email_verification_required', '1', 'boolean', 'registration', 'Whether email verification is required for new users', 0),
('max_volunteer_hours_per_week', '40', 'integer', 'volunteering', 'Maximum volunteer hours per week per person', 0),
('volunteer_background_check_required', '0', 'boolean', 'volunteering', 'Whether background checks are required by default', 0),
('community_approval_required', '1', 'boolean', 'communities', 'Whether new communities require admin approval', 0),
('volunteer_work_approval_required', '0', 'boolean', 'volunteering', 'Whether new volunteer works require approval', 0);

-- ============================================================
-- CREATE TRIGGERS FOR AUTOMATIC CALCULATIONS
-- ============================================================

-- Trigger to update volunteer work registration count
DELIMITER $$
CREATE TRIGGER update_volunteer_work_registration_count 
AFTER INSERT ON volunteer_registrations 
FOR EACH ROW 
BEGIN 
    UPDATE volunteer_works 
    SET volunteers_registered = (
        SELECT COUNT(*) 
        FROM volunteer_registrations 
        WHERE volunteer_work_id = NEW.volunteer_work_id 
        AND status IN ('pending', 'approved') 
        AND deleted_at IS NULL
    ) 
    WHERE id = NEW.volunteer_work_id;
END$$

CREATE TRIGGER update_volunteer_work_registration_count_update 
AFTER UPDATE ON volunteer_registrations 
FOR EACH ROW 
BEGIN 
    UPDATE volunteer_works 
    SET volunteers_registered = (
        SELECT COUNT(*) 
        FROM volunteer_registrations 
        WHERE volunteer_work_id = NEW.volunteer_work_id 
        AND status IN ('pending', 'approved') 
        AND deleted_at IS NULL
    ) 
    WHERE id = NEW.volunteer_work_id;
END$$

DELIMITER ;

-- ============================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ============================================================

-- View for active volunteer opportunities
CREATE VIEW `active_volunteer_opportunities` AS
SELECT 
    vw.*,
    c.name as community_name,
    c.location as community_location,
    cat.name as category_name,
    cat.color_code as category_color,
    (vw.volunteers_needed - vw.volunteers_registered) as volunteers_still_needed
FROM volunteer_works vw
JOIN communities c ON vw.community_id = c.id
JOIN categories cat ON vw.category_id = cat.id
WHERE vw.status = 'published'
AND vw.deleted_at IS NULL
AND c.status = 'active'
AND c.deleted_at IS NULL
AND (vw.application_deadline IS NULL OR vw.application_deadline >= CURDATE())
AND (vw.end_date IS NULL OR vw.end_date >= CURDATE() OR vw.is_ongoing = 1);

-- View for user volunteer summary
CREATE VIEW `user_volunteer_summary` AS
SELECT 
    u.id as user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(DISTINCT vr.id) as total_registrations,
    COUNT(DISTINCT CASE WHEN vr.status = 'completed' THEN vr.id END) as completed_works,
    COALESCE(SUM(vr.hours_completed), 0) as total_volunteer_hours
FROM users u
LEFT JOIN volunteer_registrations vr ON vr.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id;

-- View for community statistics
CREATE VIEW `community_statistics` AS
SELECT 
    c.*,
    COUNT(DISTINCT vw.id) as total_works,
    COUNT(DISTINCT CASE WHEN vw.status = 'published' THEN vw.id END) as active_works
FROM communities c
LEFT JOIN volunteer_works vw ON c.id = vw.community_id AND vw.deleted_at IS NULL
WHERE c.deleted_at IS NULL
GROUP BY c.id;

-- ============================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================

-- Additional performance indexes
CREATE INDEX `idx_volunteer_works_application_deadline` ON `volunteer_works` (`application_deadline`);
CREATE INDEX `idx_volunteer_works_end_date` ON `volunteer_works` (`end_date`);
CREATE INDEX `idx_volunteer_registrations_created_at` ON `volunteer_registrations` (`created_at`);
CREATE INDEX `idx_communities_member_count` ON `communities` (`member_count`);
CREATE INDEX `idx_users_last_login_at` ON `users` (`last_login_at`);

-- ============================================================
-- FINAL CONFIGURATION
-- ============================================================

-- Set AUTO_INCREMENT starting values
ALTER TABLE `regions` AUTO_INCREMENT = 11;
ALTER TABLE `users` AUTO_INCREMENT = 1000;
ALTER TABLE `communities` AUTO_INCREMENT = 100;
ALTER TABLE `categories` AUTO_INCREMENT = 10;
ALTER TABLE `volunteer_works` AUTO_INCREMENT = 1000;
ALTER TABLE `volunteer_registrations` AUTO_INCREMENT = 10000;
ALTER TABLE `skills` AUTO_INCREMENT = 100;
ALTER TABLE `user_skills` AUTO_INCREMENT = 10000;
ALTER TABLE `volunteer_work_skills` AUTO_INCREMENT = 10000;
ALTER TABLE `activity_logs` AUTO_INCREMENT = 100000;
ALTER TABLE `system_settings` AUTO_INCREMENT = 100;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- ============================================================
-- END OF SCHEMA
-- ============================================================