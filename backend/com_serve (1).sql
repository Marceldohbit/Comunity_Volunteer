-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 07, 2026 at 08:30 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `com_serve`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `log_name` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `subject_type` varchar(255) DEFAULT NULL,
  `event` varchar(255) DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `causer_type` varchar(255) DEFAULT NULL,
  `causer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `properties` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`properties`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `log_name`, `description`, `subject_type`, `event`, `subject_id`, `causer_type`, `causer_id`, `properties`, `created_at`, `updated_at`) VALUES
(1, 'volunteer_work', 'Volunteer work created', 'App\\Models\\VolunteerWork', 'created', 1, 'App\\Models\\User', 2, '{\"attributes\":{\"title\":\"Community Garden Expansion\",\"status\":\"published\"}}', '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 'volunteer_work', 'Volunteer work created', 'App\\Models\\VolunteerWork', 'created', 2, 'App\\Models\\User', 2, '{\"attributes\":{\"title\":\"After-School Tutoring Program\",\"status\":\"published\"}}', '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 'community', 'Community created', 'App\\Models\\Community', 'created', 1, 'App\\Models\\User', 2, '{\"attributes\":{\"name\":\"Green Valley Neighborhood\",\"status\":\"active\"}}', '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 'registration', 'Volunteer registration approved', 'App\\Models\\VolunteerRegistration', 'updated', 1, 'App\\Models\\User', 2, '{\"old\":{\"status\":\"pending\"},\"attributes\":{\"status\":\"approved\"}}', '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 'registration', 'Volunteer registration completed', 'App\\Models\\VolunteerRegistration', 'updated', 5, 'App\\Models\\User', 2, '{\"old\":{\"status\":\"approved\"},\"attributes\":{\"status\":\"completed\"}}', '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `color_code` varchar(7) DEFAULT NULL,
  `icon` varchar(100) DEFAULT 'fa-hand-heart',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `color_code`, `icon`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'Education & Tutoring', 'education', 'Educational support, tutoring, literacy programs, and academic assistance', '#3498db', 'fa-graduation-cap', 1, 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 'Environmental Conservation', 'environment', 'Environmental cleanup, conservation projects, and sustainability initiatives', '#27ae60', 'fa-leaf', 1, 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 'Health & Wellness', 'health', 'Healthcare support, wellness programs, and medical assistance', '#e74c3c', 'fa-heartbeat', 1, 3, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 'Social Services', 'social', 'Community outreach, social support, and assistance programs', '#9b59b6', 'fa-hands-helping', 1, 4, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 'Youth Development', 'youth', 'Youth programs, mentorship, and skill development for young people', '#f39c12', 'fa-child', 1, 5, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(6, 'Elderly Care', 'elderly', 'Senior support, companionship, and assistance for elderly community members', '#e67e22', 'fa-heart', 1, 6, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Table structure for table `communities`
--

CREATE TABLE `communities` (
  `id` bigint(20) UNSIGNED NOT NULL,
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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `communities`
--

INSERT INTO `communities` (`id`, `slug`, `description`, `mission_statement`, `location`, `address`, `city`, `region_id`, `website_url`, `contact_email`, `contact_phone`, `logo_image`, `banner_image`, `icon`, `member_count`, `active_works_count`, `total_volunteer_hours`, `is_verified`, `status`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'green-valley-neighborhood', 'A vibrant community focused on environmental sustainability and family-friendly activities.', 'Creating a sustainable and thriving community for all residents', 'Green Valley, Yaoundé', 'Quartier Bastos', 'Yaoundé', 1, 'https://greenvalley.org', 'info@greenvalley.org', '+237670100001', NULL, NULL, 'fa-home', 248, 12, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(2, 'downtown-urban-center', 'Urban community working on homelessness, education, and community development.', 'Building inclusive urban spaces that serve everyone', 'Downtown Douala', 'Akwa District', 'Douala', 2, 'https://downtownurban.org', 'contact@downtownurban.org', '+237670100002', NULL, NULL, 'fa-building', 189, 8, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(3, 'riverside-youth-network', 'Dedicated to youth development, mentorship, and educational support programs.', 'Empowering the next generation through education and mentorship', 'Riverside', 'Near University', 'Bafoussam', 3, NULL, 'youth@riverside.org', '+237670100003', NULL, NULL, 'fa-graduation-cap', 156, 15, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(4, 'elderly-care-alliance', 'Supporting seniors through companionship, healthcare assistance, and social activities.', 'Ensuring dignity and quality of life for our elders', 'Citywide', 'Multiple Locations', 'Yaoundé', 1, NULL, 'care@elderlyalliance.org', '+237670100004', NULL, NULL, 'fa-heart', 97, 6, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(5, 'environmental-action-group', 'Community-driven environmental conservation and cleanup initiatives.', 'Protecting our environment for future generations', 'Various Locations', 'Mobile Operations', 'Douala', 2, 'https://enviroaction.org', 'info@enviroaction.org', '+237670100005', NULL, NULL, 'fa-leaf', 312, 9, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(6, 'food-security-network', 'Fighting hunger through food banks, community gardens, and nutrition education.', 'No one should go hungry in our community', 'Multiple Districts', 'Central Hub, Bastos', 'Yaoundé', 1, NULL, 'help@foodsecurity.org', '+237670100006', NULL, NULL, 'fa-utensils', 203, 11, 0, 1, 'active', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `community_members`
--

CREATE TABLE `community_members` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('member','volunteer_coordinator','admin','owner') NOT NULL DEFAULT 'member',
  `status` enum('active','inactive','pending','suspended') NOT NULL DEFAULT 'pending',
  `join_date` date NOT NULL,
  `contribution_hours` bigint(20) NOT NULL DEFAULT 0,
  `volunteer_works_completed` int(11) NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `community_statistics`
-- (See below for the actual view)
--
CREATE TABLE `community_statistics` (
`id` bigint(20) unsigned
,`slug` varchar(200)
,`description` text
,`mission_statement` text
,`location` varchar(255)
,`address` varchar(255)
,`city` varchar(100)
,`region_id` bigint(20) unsigned
,`website_url` varchar(255)
,`contact_email` varchar(255)
,`contact_phone` varchar(20)
,`logo_image` varchar(255)
,`banner_image` varchar(255)
,`icon` varchar(100)
,`member_count` int(11)
,`active_works_count` int(11)
,`total_volunteer_hours` bigint(20)
,`is_verified` tinyint(1)
,`status` enum('active','inactive','pending_approval','suspended')
,`created_by` bigint(20) unsigned
,`created_at` timestamp
,`updated_at` timestamp
,`deleted_at` timestamp
,`total_works` bigint(21)
,`active_works` bigint(21)
);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `type`, `notifiable_type`, `notifiable_id`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'App\\Notifications\\VolunteerRegistrationApproved', 'App\\Models\\User', 3, '{\"message\":\"Your registration for Community Garden Expansion has been approved!\",\"work_id\":1,\"work_title\":\"Community Garden Expansion\"}', '2025-01-12 15:00:00', '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
('550e8400-e29b-41d4-a716-446655440002', 'App\\Notifications\\VolunteerRegistrationApproved', 'App\\Models\\User', 4, '{\"message\":\"Your registration for After-School Tutoring Program has been approved!\",\"work_id\":2,\"work_title\":\"After-School Tutoring Program\"}', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
('550e8400-e29b-41d4-a716-446655440003', 'App\\Notifications\\NewVolunteerWork', 'App\\Models\\User', 3, '{\"message\":\"New volunteer opportunity: Tree Planting Campaign\",\"work_id\":9,\"work_title\":\"Tree Planting Campaign\"}', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
('550e8400-e29b-41d4-a716-446655440004', 'App\\Notifications\\VolunteerRegistrationPending', 'App\\Models\\User', 2, '{\"message\":\"New volunteer application for Youth Sports Mentorship\",\"work_id\":7,\"applicant\":\"Jean Mbarga\"}', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `regions`
--

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

-- --------------------------------------------------------

--
-- Table structure for table `skills`
--

CREATE TABLE `skills` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `skills`
--

INSERT INTO `skills` (`id`, `name`, `slug`, `description`, `category`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Teaching & Tutoring', 'teaching-tutoring', 'Ability to teach and provide educational support', 'Education', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 'Event Organization', 'event-organization', 'Planning and organizing community events and activities', 'Management', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 'First Aid & CPR', 'first-aid-cpr', 'Certified in first aid and CPR emergency response', 'Healthcare', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 'Gardening & Landscaping', 'gardening-landscaping', 'Knowledge of plants, gardening, and landscape maintenance', 'Environment', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 'Computer & Technology', 'computer-technology', 'Technical skills with computers and digital tools', 'Technology', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(6, 'Language Translation', 'language-translation', 'Multilingual abilities and translation services', 'Communication', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(7, 'Counseling & Support', 'counseling-support', 'Emotional support and basic counseling skills', 'Mental Health', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(8, 'Construction & Repair', 'construction-repair', 'Building, repair, and maintenance skills', 'Manual Labor', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(9, 'Art & Creativity', 'art-creativity', 'Artistic abilities and creative project skills', 'Arts', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(10, 'Sports & Recreation', 'sports-recreation', 'Athletic abilities and recreational activity leadership', 'Sports', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `type` enum('string','integer','boolean','json','text') NOT NULL DEFAULT 'string',
  `group` varchar(100) DEFAULT 'general',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`id`, `key`, `value`, `type`, `group`, `description`, `is_public`, `created_at`, `updated_at`) VALUES
(1, 'app_name', 'Community Serve', 'string', 'general', 'Application name', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 'app_description', 'A platform for community volunteer management and coordination', 'string', 'general', 'Application description', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 'default_timezone', 'UTC', 'string', 'general', 'Default timezone for the application', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 'registration_enabled', '1', 'boolean', 'registration', 'Whether new user registration is enabled', 1, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 'email_verification_required', '1', 'boolean', 'registration', 'Whether email verification is required for new users', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(6, 'max_volunteer_hours_per_week', '40', 'integer', 'volunteering', 'Maximum volunteer hours per week per person', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(7, 'volunteer_background_check_required', '0', 'boolean', 'volunteering', 'Whether background checks are required by default', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(8, 'community_approval_required', '1', 'boolean', 'communities', 'Whether new communities require admin approval', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(9, 'volunteer_work_approval_required', '0', 'boolean', 'volunteering', 'Whether new volunteer works require approval', 0, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `first_name`, `last_name`, `phone`, `date_of_birth`, `gender`, `profile_image`, `city`, `region_id`, `emergency_contact_phone`, `role`, `status`, `last_login_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'admin@communityserve.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System', 'Administrator', '+237670000001', '1985-05-15', 'male', NULL, 'Yaoundé', 1, '+237670000002', 'admin', 'active', '2025-12-17 20:57:09', '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(2, 'manager@communityserve.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Marie', 'Nkolo', '+237670000011', '1990-08-22', 'female', NULL, 'Douala', 2, '+237670000012', 'community_manager', 'active', '2025-12-17 20:57:09', '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(3, 'volunteer1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jean', 'Mbarga', '+237670000021', '1995-03-10', 'male', NULL, 'Bafoussam', 3, '+237670000022', 'volunteer', 'active', '2025-12-17 20:57:09', '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(4, 'volunteer2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Grace', 'Fouda', '+237670000031', '1992-11-05', 'female', NULL, 'Yaoundé', 1, '+237670000032', 'volunteer', 'active', '2025-12-17 20:57:09', '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(5, 'volunteer3@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Paul', 'Eto\'o', '+237670000041', '1998-07-18', 'male', NULL, 'Douala', 2, '+237670000042', 'volunteer', 'active', '2025-12-17 20:57:09', '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_skills`
--

CREATE TABLE `user_skills` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `skill_id` bigint(20) UNSIGNED NOT NULL,
  `proficiency_level` enum('beginner','intermediate','advanced','expert') NOT NULL DEFAULT 'beginner',
  `years_experience` int(11) DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_skills`
--

INSERT INTO `user_skills` (`id`, `user_id`, `skill_id`, `proficiency_level`, `years_experience`, `is_verified`, `notes`, `created_at`, `updated_at`) VALUES
(1, 3, 1, 'intermediate', 3, 1, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 3, 4, 'advanced', 5, 1, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 4, 7, 'advanced', 4, 1, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 4, 1, 'beginner', 1, 0, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 5, 5, 'expert', 8, 1, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(6, 5, 10, 'advanced', 6, 1, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_volunteer_summary`
-- (See below for the actual view)
--
CREATE TABLE `user_volunteer_summary` (
`user_id` bigint(20) unsigned
,`first_name` varchar(100)
,`last_name` varchar(100)
,`email` varchar(255)
,`total_registrations` bigint(21)
,`completed_works` bigint(21)
,`total_volunteer_hours` decimal(30,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_registrations`
--

CREATE TABLE `volunteer_registrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `volunteer_registrations`
--

INSERT INTO `volunteer_registrations` (`id`, `volunteer_work_id`, `status`, `application_message`, `motivation`, `relevant_skills`, `availability_notes`, `emergency_contact_name`, `emergency_contact_phone`, `emergency_contact_relationship`, `has_transportation`, `dietary_restrictions`, `medical_conditions`, `background_check_status`, `background_check_date`, `training_completion_status`, `training_completion_date`, `hours_committed`, `hours_completed`, `start_date`, `end_date`, `feedback_rating`, `feedback_comment`, `supervisor_notes`, `reviewed_by`, `reviewed_at`, `approved_at`, `completed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'approved', 'I would love to help with the garden expansion.', 'Passionate about sustainable living and community agriculture', 'Basic gardening knowledge, physical fitness', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 40.00, 25.00, '2025-01-15', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-12 10:00:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(2, 2, 'approved', 'I have teaching experience and want to help students succeed.', 'Education is the key to breaking poverty cycles', 'Teaching, math tutoring, mentorship', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 60.00, 45.00, '2025-01-08', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-06 14:30:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(3, 3, 'approved', 'My grandmother was in a nursing home, I understand the importance of companionship.', 'Want to give back and brighten someone\'s day', 'Good listener, patient, compassionate', NULL, NULL, NULL, NULL, 0, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 52.00, 30.00, '2025-01-01', NULL, NULL, NULL, NULL, NULL, NULL, '2024-12-28 09:15:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(4, 4, 'approved', 'Environmental conservation is my passion!', 'Protecting our beaches and marine life is critical', 'Beach cleanup experience, environmental awareness', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 24.00, 16.00, '2025-01-20', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-18 11:00:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(5, 5, 'completed', 'I want to help those less fortunate in our community.', 'Everyone deserves dignity and basic necessities', 'Empathy, communication, organization', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 80.00, 80.00, '2024-12-01', NULL, NULL, NULL, NULL, NULL, NULL, '2024-11-28 16:00:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(6, 6, 'approved', 'Happy to help sort and distribute food to families.', 'No one should go hungry', 'Organization, physical strength, reliability', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 50.00, 35.00, '2025-01-10', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-08 13:00:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(7, 7, 'pending', 'Former athlete wanting to mentor youth.', 'Sports taught me discipline and teamwork', 'Basketball coaching, youth mentorship', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 40.00, 0.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(8, 8, 'approved', 'Tech professional wanting to help seniors learn computers.', 'Technology should be accessible to everyone', 'Computer training, IT support, patience', NULL, NULL, NULL, NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 30.00, 20.00, '2025-01-12', NULL, NULL, NULL, NULL, NULL, NULL, '2025-01-10 10:30:00', NULL, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(9, 1, 'pending', 'Volunteer application - Interested in: education, youth', NULL, 'education, youth', NULL, 'BANYIN', '42645974', NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 07:32:28', '2025-12-18 07:32:28', NULL),
(10, 1, 'pending', 'Volunteer application - Interested in: environment, social', NULL, 'environment, social', NULL, 'BANYIN', '467638874', NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 07:42:31', '2025-12-18 07:42:31', NULL),
(11, 6, 'pending', 'General volunteer application. Interested in: education. Available: weekdays', 'I want to volunteer with Food Security Network', 'education', NULL, 'mARK', '67893333333332', NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-18 07:44:11', '2025-12-18 07:44:11', NULL),
(12, 6, 'pending', 'General volunteer application. Interested in: health, social. Available: specific times', 'I want to volunteer with Food Security Network', 'health, social', NULL, 'Hillary', '653882798', NULL, 1, NULL, NULL, 'not_required', NULL, 'not_required', NULL, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-24 09:46:36', '2026-01-24 09:46:36', NULL);

--
-- Triggers `volunteer_registrations`
--
DELIMITER $$
CREATE TRIGGER `update_volunteer_work_registration_count` AFTER INSERT ON `volunteer_registrations` FOR EACH ROW BEGIN 
    UPDATE volunteer_works 
    SET volunteers_registered = (
        SELECT COUNT(*) 
        FROM volunteer_registrations 
        WHERE volunteer_work_id = NEW.volunteer_work_id 
        AND status IN ('pending', 'approved') 
        AND deleted_at IS NULL
    ) 
    WHERE id = NEW.volunteer_work_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_volunteer_work_registration_count_update` AFTER UPDATE ON `volunteer_registrations` FOR EACH ROW BEGIN 
    UPDATE volunteer_works 
    SET volunteers_registered = (
        SELECT COUNT(*) 
        FROM volunteer_registrations 
        WHERE volunteer_work_id = NEW.volunteer_work_id 
        AND status IN ('pending', 'approved') 
        AND deleted_at IS NULL
    ) 
    WHERE id = NEW.volunteer_work_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_works`
--

CREATE TABLE `volunteer_works` (
  `id` bigint(20) UNSIGNED NOT NULL,
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
  `gallery_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gallery_images`)),
  `icon` varchar(100) DEFAULT 'fa-hand-heart',
  `is_training_provided` tinyint(1) NOT NULL DEFAULT 0,
  `is_background_check_required` tinyint(1) NOT NULL DEFAULT 0,
  `application_deadline` date DEFAULT NULL,
  `status` enum('draft','published','in_progress','completed','cancelled','on_hold') NOT NULL DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `volunteer_works`
--

INSERT INTO `volunteer_works` (`id`, `community_id`, `category_id`, `title`, `slug`, `description`, `objectives`, `requirements`, `benefits`, `location`, `address`, `address_line_2`, `city`, `region_id`, `start_date`, `end_date`, `volunteers_needed`, `volunteers_registered`, `min_age_requirement`, `max_age_requirement`, `skills_required`, `time_commitment_hours`, `time_commitment_description`, `contact_person_name`, `contact_email`, `contact_phone`, `featured_image`, `gallery_images`, `icon`, `is_training_provided`, `is_background_check_required`, `application_deadline`, `status`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 2, 'Community Garden Expansion', 'community-garden-expansion', 'Expanding our community garden to provide fresh produce for local food banks and teach sustainable gardening practices.', 'Increase food production, educate community members on sustainable agriculture', 'Physical fitness, willingness to work outdoors, no prior experience needed', NULL, 'Green Valley Park', 'Bastos District', NULL, 'Yaoundé', 1, '2025-01-15', '2025-04-30', 20, 4, 16, NULL, NULL, NULL, NULL, 'Marie Nkolo', 'info@greenvalley.org', '+237670100001', NULL, NULL, 'fa-seedling', 1, 0, '2025-01-10', 'published', 2, '2025-12-17 20:57:09', '2025-12-18 07:42:31', NULL),
(2, 3, 1, 'After-School Tutoring Program', 'after-school-tutoring-program', 'Providing academic support and mentorship for elementary and middle school students in math, reading, and science.', 'Improve student academic performance, provide mentorship', 'Teaching experience or strong academic background required', NULL, 'Riverside Community Center', 'Near University Campus', NULL, 'Bafoussam', 3, '2025-01-08', '2025-06-15', 15, 12, 18, NULL, NULL, NULL, NULL, 'Jean Mbarga', 'youth@riverside.org', '+237670100003', NULL, NULL, 'fa-book', 1, 1, '2025-01-05', 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(3, 4, 6, 'Senior Companion Program', 'senior-companion-program', 'Weekly visits and companionship for elderly residents in nursing homes and assisted living facilities.', 'Reduce loneliness, provide social interaction for seniors', 'Patience, good communication skills, commitment to weekly visits', NULL, 'Various Nursing Homes', 'Multiple Locations', NULL, 'Yaoundé', 1, '2025-01-01', '2025-12-31', 25, 18, 18, NULL, NULL, NULL, NULL, 'Grace Fouda', 'care@elderlyalliance.org', '+237670100004', NULL, NULL, 'fa-heart', 1, 1, NULL, 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(4, 5, 2, 'Beach Cleanup Initiative', 'beach-cleanup-initiative', 'Monthly beach cleanup to remove plastic waste and protect marine life along the Douala coastline.', 'Clean beaches, raise environmental awareness', 'Ability to walk on beach terrain, commitment to monthly participation', NULL, 'Douala Beaches', 'Coastal Areas', NULL, 'Douala', 2, '2025-01-20', NULL, 30, 22, 14, NULL, NULL, NULL, NULL, 'Paul Eto\'o', 'info@enviroaction.org', '+237670100005', NULL, NULL, 'fa-water', 0, 0, '2025-01-15', 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(5, 2, 4, 'Homeless Outreach Program', 'homeless-outreach-program', 'Providing meals, clothing, and support services to homeless individuals in downtown areas.', 'Address immediate needs of homeless population, connect with services', 'Compassion, non-judgmental attitude, safety training provided', NULL, 'Downtown Douala', 'Akwa District', NULL, 'Douala', 2, '2024-12-01', '2025-11-30', 40, 28, 18, NULL, NULL, NULL, NULL, 'Marie Nkolo', 'contact@downtownurban.org', '+237670100002', NULL, NULL, 'fa-hands-helping', 1, 0, NULL, 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(6, 6, 4, 'Community Food Bank', 'community-food-bank', 'Sorting, packing, and distributing food to families in need through our network of food banks.', 'Provide food assistance to struggling families', 'Ability to lift 25 lbs, organized, reliable', NULL, 'Food Security Hub', 'Central Hub, Bastos', NULL, 'Yaoundé', 1, '2025-01-10', NULL, 35, 4, 16, NULL, NULL, NULL, NULL, 'Grace Fouda', 'help@foodsecurity.org', '+237670100006', NULL, NULL, 'fa-box', 1, 0, NULL, 'published', 2, '2025-12-17 20:57:09', '2026-01-24 09:46:36', NULL),
(7, 3, 5, 'Youth Sports Mentorship', 'youth-sports-mentorship', 'Coaching and mentoring youth in various sports activities while teaching life skills and teamwork.', 'Promote physical fitness, teach teamwork and leadership', 'Sports background, experience working with youth', NULL, 'Community Sports Fields', 'University Sports Complex', NULL, 'Bafoussam', 3, '2025-02-01', '2025-07-31', 18, 10, 21, NULL, NULL, NULL, NULL, 'Jean Mbarga', 'youth@riverside.org', '+237670100003', NULL, NULL, 'fa-futbol', 1, 1, '2025-01-25', 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(8, 1, 1, 'Digital Literacy Classes', 'digital-literacy-classes', 'Teaching basic computer skills and internet safety to senior citizens and adults with limited tech experience.', 'Bridge digital divide, improve tech literacy', 'Computer proficiency, patience, teaching ability', NULL, 'Community Center', 'Bastos Community Hall', NULL, 'Yaoundé', 1, '2025-01-12', '2025-05-30', 12, 8, 18, NULL, NULL, NULL, NULL, 'Marie Nkolo', 'info@greenvalley.org', '+237670100001', NULL, NULL, 'fa-laptop', 1, 0, '2025-01-08', 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL),
(9, 5, 2, 'Tree Planting Campaign', 'tree-planting-campaign', 'Large-scale tree planting initiative to combat deforestation and improve air quality in urban areas.', 'Plant 5000 trees, raise environmental awareness', 'Physical ability, willingness to work outdoors', NULL, 'Various Parks', 'Multiple City Parks', NULL, 'Douala', 2, '2025-03-01', '2025-03-15', 50, 35, 14, NULL, NULL, NULL, NULL, 'Paul Eto\'o', 'info@enviroaction.org', '+237670100005', NULL, NULL, 'fa-tree', 1, 0, '2025-02-25', 'published', 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_work_skills`
--

CREATE TABLE `volunteer_work_skills` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `volunteer_work_id` bigint(20) UNSIGNED NOT NULL,
  `skill_id` bigint(20) UNSIGNED NOT NULL,
  `required_proficiency` enum('beginner','intermediate','advanced','expert') NOT NULL DEFAULT 'beginner',
  `is_mandatory` tinyint(1) NOT NULL DEFAULT 0,
  `weight` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `volunteer_work_skills`
--

INSERT INTO `volunteer_work_skills` (`id`, `volunteer_work_id`, `skill_id`, `required_proficiency`, `is_mandatory`, `weight`, `created_at`, `updated_at`) VALUES
(1, 1, 4, 'beginner', 0, 3, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(2, 2, 1, 'intermediate', 1, 5, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(3, 3, 7, 'intermediate', 0, 4, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(4, 5, 7, 'beginner', 0, 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(5, 6, 2, 'beginner', 0, 2, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(6, 7, 10, 'intermediate', 1, 5, '2025-12-17 20:57:09', '2025-12-17 20:57:09'),
(7, 8, 5, 'advanced', 1, 5, '2025-12-17 20:57:09', '2025-12-17 20:57:09');

-- --------------------------------------------------------

--
-- Structure for view `community_statistics`
--
DROP TABLE IF EXISTS `community_statistics`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `community_statistics`  AS SELECT `c`.`id` AS `id`, `c`.`slug` AS `slug`, `c`.`description` AS `description`, `c`.`mission_statement` AS `mission_statement`, `c`.`location` AS `location`, `c`.`address` AS `address`, `c`.`city` AS `city`, `c`.`region_id` AS `region_id`, `c`.`website_url` AS `website_url`, `c`.`contact_email` AS `contact_email`, `c`.`contact_phone` AS `contact_phone`, `c`.`logo_image` AS `logo_image`, `c`.`banner_image` AS `banner_image`, `c`.`icon` AS `icon`, `c`.`member_count` AS `member_count`, `c`.`active_works_count` AS `active_works_count`, `c`.`total_volunteer_hours` AS `total_volunteer_hours`, `c`.`is_verified` AS `is_verified`, `c`.`status` AS `status`, `c`.`created_by` AS `created_by`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at`, `c`.`deleted_at` AS `deleted_at`, count(distinct `vw`.`id`) AS `total_works`, count(distinct case when `vw`.`status` = 'published' then `vw`.`id` end) AS `active_works` FROM (`communities` `c` left join `volunteer_works` `vw` on(`c`.`id` = `vw`.`community_id` and `vw`.`deleted_at` is null)) WHERE `c`.`deleted_at` is null GROUP BY `c`.`id` ;

-- --------------------------------------------------------

--
-- Structure for view `user_volunteer_summary`
--
DROP TABLE IF EXISTS `user_volunteer_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_volunteer_summary`  AS SELECT `u`.`id` AS `user_id`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, count(distinct `vr`.`id`) AS `total_registrations`, count(distinct case when `vr`.`status` = 'completed' then `vr`.`id` end) AS `completed_works`, coalesce(sum(`vr`.`hours_completed`),0) AS `total_volunteer_hours` FROM (`users` `u` left join `volunteer_registrations` `vr` on(`vr`.`deleted_at` is null)) WHERE `u`.`deleted_at` is null GROUP BY `u`.`id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `subject` (`subject_type`,`subject_id`),
  ADD KEY `causer` (`causer_type`,`causer_id`),
  ADD KEY `activity_log_log_name_index` (`log_name`),
  ADD KEY `idx_activity_logs_event` (`event`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_slug_unique` (`slug`),
  ADD KEY `idx_categories_is_active` (`is_active`),
  ADD KEY `idx_categories_sort_order` (`sort_order`);

--
-- Indexes for table `communities`
--
ALTER TABLE `communities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `communities_slug_unique` (`slug`),
  ADD KEY `idx_communities_status` (`status`),
  ADD KEY `idx_communities_city` (`city`),
  ADD KEY `idx_communities_region_id` (`region_id`),
  ADD KEY `idx_communities_is_verified` (`is_verified`),
  ADD KEY `idx_communities_created_by` (`created_by`),
  ADD KEY `idx_communities_deleted_at` (`deleted_at`);

--
-- Indexes for table `community_members`
--
ALTER TABLE `community_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_community_members_role` (`role`),
  ADD KEY `idx_community_members_status` (`status`),
  ADD KEY `idx_community_members_deleted_at` (`deleted_at`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`),
  ADD KEY `idx_notifications_read_at` (`read_at`),
  ADD KEY `idx_notifications_type` (`type`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_regions_name` (`name`);

--
-- Indexes for table `skills`
--
ALTER TABLE `skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `skills_slug_unique` (`slug`),
  ADD KEY `idx_skills_is_active` (`is_active`),
  ADD KEY `idx_skills_category` (`category`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `system_settings_key_unique` (`key`),
  ADD KEY `idx_system_settings_group` (`group`),
  ADD KEY `idx_system_settings_is_public` (`is_public`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `idx_users_status` (`status`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_city` (`city`),
  ADD KEY `idx_users_region_id` (`region_id`),
  ADD KEY `idx_users_deleted_at` (`deleted_at`);

--
-- Indexes for table `user_skills`
--
ALTER TABLE `user_skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_skills_user_skill_unique` (`user_id`,`skill_id`),
  ADD KEY `idx_user_skills_skill_id` (`skill_id`),
  ADD KEY `idx_user_skills_proficiency_level` (`proficiency_level`);

--
-- Indexes for table `volunteer_registrations`
--
ALTER TABLE `volunteer_registrations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_volunteer_registrations_status` (`status`),
  ADD KEY `idx_volunteer_registrations_volunteer_work_id` (`volunteer_work_id`),
  ADD KEY `idx_volunteer_registrations_reviewed_by` (`reviewed_by`),
  ADD KEY `idx_volunteer_registrations_deleted_at` (`deleted_at`);

--
-- Indexes for table `volunteer_works`
--
ALTER TABLE `volunteer_works`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `volunteer_works_slug_unique` (`slug`),
  ADD KEY `idx_volunteer_works_community_id` (`community_id`),
  ADD KEY `idx_volunteer_works_category_id` (`category_id`),
  ADD KEY `idx_volunteer_works_status` (`status`),
  ADD KEY `idx_volunteer_works_start_date` (`start_date`),
  ADD KEY `idx_volunteer_works_city` (`city`),
  ADD KEY `idx_volunteer_works_region_id` (`region_id`),
  ADD KEY `idx_volunteer_works_created_by` (`created_by`),
  ADD KEY `idx_volunteer_works_deleted_at` (`deleted_at`),
  ADD KEY `idx_volunteer_works_application_deadline` (`application_deadline`);

--
-- Indexes for table `volunteer_work_skills`
--
ALTER TABLE `volunteer_work_skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `volunteer_work_skills_work_skill_unique` (`volunteer_work_id`,`skill_id`),
  ADD KEY `idx_volunteer_work_skills_skill_id` (`skill_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `communities`
--
ALTER TABLE `communities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `community_members`
--
ALTER TABLE `community_members`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `skills`
--
ALTER TABLE `skills`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_skills`
--
ALTER TABLE `user_skills`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `volunteer_registrations`
--
ALTER TABLE `volunteer_registrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `volunteer_works`
--
ALTER TABLE `volunteer_works`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `volunteer_work_skills`
--
ALTER TABLE `volunteer_work_skills`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `communities`
--
ALTER TABLE `communities`
  ADD CONSTRAINT `communities_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `communities_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_skills`
--
ALTER TABLE `user_skills`
  ADD CONSTRAINT `user_skills_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_skills_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `volunteer_registrations`
--
ALTER TABLE `volunteer_registrations`
  ADD CONSTRAINT `volunteer_registrations_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `volunteer_registrations_volunteer_work_id_foreign` FOREIGN KEY (`volunteer_work_id`) REFERENCES `volunteer_works` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `volunteer_works`
--
ALTER TABLE `volunteer_works`
  ADD CONSTRAINT `volunteer_works_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  ADD CONSTRAINT `volunteer_works_community_id_foreign` FOREIGN KEY (`community_id`) REFERENCES `communities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteer_works_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `volunteer_works_region_id_foreign` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `volunteer_work_skills`
--
ALTER TABLE `volunteer_work_skills`
  ADD CONSTRAINT `volunteer_work_skills_skill_id_foreign` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteer_work_skills_volunteer_work_id_foreign` FOREIGN KEY (`volunteer_work_id`) REFERENCES `volunteer_works` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
