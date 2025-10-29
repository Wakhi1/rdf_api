-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 29, 2025 at 12:57 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rdf_sys`
--

-- --------------------------------------------------------

--
-- Table structure for table `applications`
--

CREATE TABLE `applications` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `form_id` int(11) NOT NULL,
  `reference_number` varchar(50) NOT NULL,
  `current_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') DEFAULT 'EOG_LEVEL',
  `progress_percentage` decimal(5,2) DEFAULT 0.00,
  `status` enum('draft','submitted','in_review','returned','recommended','approved','rejected','completed') DEFAULT 'draft',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `funding_amount` decimal(15,2) DEFAULT NULL,
  `approved_amount` decimal(15,2) DEFAULT NULL,
  `disbursed_amount` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `applications`
--

INSERT INTO `applications` (`id`, `eog_id`, `form_id`, `reference_number`, `current_level`, `progress_percentage`, `status`, `submitted_at`, `completed_at`, `funding_amount`, `approved_amount`, `disbursed_amount`, `created_at`, `updated_at`) VALUES
(1, 1, 5, 'RDF-2025-0001', 'EOG_LEVEL', 0.00, 'draft', NULL, NULL, NULL, NULL, 0.00, '2025-10-28 21:37:11', '2025-10-28 21:37:11');

-- --------------------------------------------------------

--
-- Table structure for table `application_attachments`
--

CREATE TABLE `application_attachments` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `workflow_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') NOT NULL,
  `attachment_type` varchar(100) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `application_comments`
--

CREATE TABLE `application_comments` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `workflow_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') NOT NULL,
  `comment_type` enum('question','clarification_request','feedback','recommendation','return_reason','general') NOT NULL,
  `comment_text` text NOT NULL,
  `parent_comment_id` int(11) DEFAULT NULL,
  `is_internal` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `application_workflow`
--

CREATE TABLE `application_workflow` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `from_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') DEFAULT NULL,
  `to_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') NOT NULL,
  `action` enum('submit','approve','return','reject','recommend') NOT NULL,
  `comments` text DEFAULT NULL,
  `actioned_by` int(11) NOT NULL,
  `actioned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `beneficiary_feedback`
--

CREATE TABLE `beneficiary_feedback` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `feedback_type` enum('survey','interview','complaint','suggestion') NOT NULL,
  `feedback_text` text NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `submitted_by` varchar(100) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cdo_review_queue`
--

CREATE TABLE `cdo_review_queue` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `assigned_cdo_id` int(11) DEFAULT NULL,
  `priority` enum('high','medium','low') DEFAULT 'medium',
  `status` enum('pending','in_review','approved','rejected','more_info_needed') DEFAULT 'pending',
  `review_notes` text DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cdo_review_queue`
--

INSERT INTO `cdo_review_queue` (`id`, `eog_id`, `assigned_cdo_id`, `priority`, `status`, `review_notes`, `assigned_at`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 1, 18, 'medium', 'approved', 'Approved by CDO', '2025-10-28 11:30:44', '2025-10-28 11:35:10', '2025-10-27 02:37:00', '2025-10-28 11:35:10'),
(2, 2, NULL, 'medium', 'pending', NULL, NULL, NULL, '2025-10-28 14:20:13', '2025-10-28 14:20:13');

-- --------------------------------------------------------

--
-- Table structure for table `committees`
--

CREATE TABLE `committees` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `type` enum('CDC','INKHUNDLA_COUNCIL','RDFTC','RDFC') NOT NULL,
  `region_id` int(11) DEFAULT NULL,
  `tinkhundla_id` int(11) DEFAULT NULL,
  `umphakatsi_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `committee_approvals`
--

CREATE TABLE `committee_approvals` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `committee_id` int(11) NOT NULL,
  `committee_member_id` int(11) NOT NULL,
  `workflow_level` enum('UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL') NOT NULL,
  `signature_otp_id` int(11) DEFAULT NULL,
  `decision` enum('approved','rejected') NOT NULL,
  `comments` text DEFAULT NULL,
  `signed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `committee_members`
--

CREATE TABLE `committee_members` (
  `id` int(11) NOT NULL,
  `committee_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `position` varchar(100) DEFAULT NULL,
  `is_chairperson` tinyint(1) DEFAULT 0,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_logs`
--

CREATE TABLE `email_logs` (
  `id` int(11) NOT NULL,
  `recipient_email` varchar(100) NOT NULL,
  `recipient_user_id` int(11) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `status` enum('pending','sent','failed') DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_logs`
--

INSERT INTO `email_logs` (`id`, `recipient_email`, `recipient_user_id`, `subject`, `body`, `status`, `error_message`, `sent_at`, `created_at`) VALUES
(1, 'wakhiwakhi1@outlook.com', NULL, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Olwethu Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> olwethu</li>\n      <li><strong>Temporary Password:</strong> !vM@bwquK2t%</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-25 20:58:44', '2025-10-25 20:58:44'),
(2, 'wakhiwakhi1@outlook.com', NULL, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Olwethu Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> olwethu</li>\n      <li><strong>Temporary Password:</strong> sL9Db$tUKjw5</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-25 21:20:26', '2025-10-25 21:20:26'),
(3, 'celimphilodlamini94@gmail.com', 17, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Timphisini Beehives ,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> temp_20251026_9084</li>\n      <li><strong>Temporary Password:</strong> Xn2g_QY&$_</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-26 11:02:53', '2025-10-26 11:02:53'),
(4, 'wakhiwakhi1@outlook.com', 18, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Olwethu Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> olwethu</li>\n      <li><strong>Temporary Password:</strong> YLYp@vtSmW$6</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-26 11:20:59', '2025-10-26 11:20:59'),
(5, 'celimphilodlamini94@gmail.com', 17, 'RDF System - EOG Account Approved', '\n    <h1>EOG Account Approved</h1>\n    <p>Hello Timphisini Beehives Cooperative,</p>\n    <p>Congratulations! Your EOG account for \"Timphisini Beehives\" has been approved.</p>\n    <p>You can now log in and submit applications for funding.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-28 11:35:15', '2025-10-28 11:35:15'),
(6, 'olwethudlamin10@gmail.com', 19, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Inana Mainze Meal ,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> temp_20251028_9868</li>\n      <li><strong>Temporary Password:</strong> Y%Mcc41hwC</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-28 13:23:31', '2025-10-28 13:23:31');

-- --------------------------------------------------------

--
-- Table structure for table `eogs`
--

CREATE TABLE `eogs` (
  `id` int(11) NOT NULL,
  `company_name` varchar(200) NOT NULL,
  `company_type` enum('Association','Cooperative','Company','Community Group','Scheme','Partnership') NOT NULL,
  `bin_cin` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `region_id` int(11) NOT NULL,
  `tinkhundla_id` int(11) NOT NULL,
  `umphakatsi_id` int(11) NOT NULL,
  `total_members` int(11) NOT NULL DEFAULT 0,
  `status` enum('temporary','pending_verification','approved','rejected','suspended') DEFAULT 'temporary',
  `temp_account_expires` timestamp NULL DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eogs`
--

INSERT INTO `eogs` (`id`, `company_name`, `company_type`, `bin_cin`, `email`, `phone`, `region_id`, `tinkhundla_id`, `umphakatsi_id`, `total_members`, `status`, `temp_account_expires`, `approved_by`, `approved_at`, `rejection_reason`, `created_at`, `updated_at`) VALUES
(1, 'Timphisini Beehives', 'Cooperative', '12345', 'celimphilodlamini94@gmail.com', '79876543', 1, 15, 77, 25, 'approved', NULL, 18, '2025-10-28 11:35:10', NULL, '2025-10-26 11:02:48', '2025-10-28 11:35:10'),
(2, 'Inana Mainze Meal', 'Cooperative', '543211', 'olwethudlamin10@gmail.com', '26878900987', 1, 1, 1, 15, 'pending_verification', '2025-11-27 13:23:26', NULL, NULL, NULL, '2025-10-28 13:23:26', '2025-10-28 14:20:13');

-- --------------------------------------------------------

--
-- Table structure for table `eog_documents`
--

CREATE TABLE `eog_documents` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `document_type` enum('constitution','recognition_letter','articles','form_j','certificate','member_list') NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eog_documents`
--

INSERT INTO `eog_documents` (`id`, `eog_id`, `document_type`, `file_name`, `file_path`, `file_size`, `uploaded_at`) VALUES
(1, 1, 'constitution', 'Application Letter Sibusiso Dif Simelane.pdf', 'uploads\\eog_documents\\1\\constitution\\constitution-1761495860591-200679727.pdf', 10534, '2025-10-26 16:24:20'),
(2, 1, 'recognition_letter', 'Application_Trainig Center Dif.pdf', 'uploads\\eog_documents\\1\\recognition_letter\\recognition_letter-1761495880657-837100703.pdf', 66940, '2025-10-26 16:24:40'),
(3, 1, 'articles', 'Application St Theresa - Sibusiso.pdf', 'uploads\\eog_documents\\1\\articles\\articles-1761495887045-881170275.pdf', 66093, '2025-10-26 16:24:47'),
(4, 1, 'form_j', 'Cover letter - Sibusio Simelane.pdf', 'uploads\\eog_documents\\1\\form_j\\form_j-1761495890969-727506227.pdf', 65953, '2025-10-26 16:24:51'),
(5, 1, 'certificate', 'cover page.pdf', 'uploads\\eog_documents\\1\\certificate\\certificate-1761495895506-27803107.pdf', 585855, '2025-10-26 16:24:55'),
(7, 1, 'member_list', 'sampling.csv', 'uploads/eog_documents/1/member_list/member_list-1761499523039-767085618.csv', 1669, '2025-10-26 17:25:23'),
(8, 2, 'constitution', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/constitution/constitution-1761658392355-951931451.pdf', 63614, '2025-10-28 13:33:12'),
(9, 2, 'recognition_letter', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/recognition_letter/recognition_letter-1761658397824-706541221.pdf', 63614, '2025-10-28 13:33:17'),
(10, 2, 'articles', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/articles/articles-1761658404002-26313455.pdf', 63614, '2025-10-28 13:33:24'),
(11, 2, 'form_j', 'cover page.pdf', 'uploads/eog_documents/2/form_j/form_j-1761660038769-139348813.pdf', 585855, '2025-10-28 14:00:38'),
(12, 2, 'certificate', 'Blue Breeze Investment.pdf', 'uploads/eog_documents/2/certificate/certificate-1761660045333-448415201.pdf', 64020, '2025-10-28 14:00:45'),
(13, 2, 'member_list', 'facilitySheet_updated.xlsx', 'uploads/eog_documents/2/member_list/member_list-1761660052702-72902592.xlsx', 81859, '2025-10-28 14:00:52');

-- --------------------------------------------------------

--
-- Table structure for table `eog_expiry_notifications`
--

CREATE TABLE `eog_expiry_notifications` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `notification_type` enum('7_days_warning','3_days_warning','1_day_warning','expired_notice') NOT NULL,
  `sent_to_email` varchar(100) NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `email_log_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `eog_members`
--

CREATE TABLE `eog_members` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `id_number` varchar(13) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `position` varchar(100) NOT NULL,
  `is_executive` tinyint(1) DEFAULT 0,
  `verification_status` enum('pending','verified','failed','corrected') DEFAULT 'pending',
  `verification_notes` text DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eog_members`
--

INSERT INTO `eog_members` (`id`, `eog_id`, `id_number`, `first_name`, `surname`, `gender`, `contact_number`, `position`, `is_executive`, `verification_status`, `verification_notes`, `verified_by`, `verified_at`, `created_at`) VALUES
(2, 1, '0101011234567', 'Musa', 'Dlamini', 'Male', '76859430', 'Chairman', 1, 'verified', NULL, 18, '2025-10-28 11:31:36', '2025-10-26 16:37:14'),
(3, 1, '9001010000001', 'Sibusiso', 'Dlamini', 'Male', '26876000001', 'Secretary', 1, 'verified', NULL, 18, '2025-10-28 11:34:41', '2025-10-27 02:30:03'),
(4, 1, '3905050000050', 'Nandi', 'Shongwe', 'Female', '26878000050', 'Treasurer', 1, 'verified', NULL, 18, '2025-10-28 11:31:39', '2025-10-27 02:31:20'),
(5, 1, '3207070000043', 'Siphesihle', 'Mamba', 'Female', '26876000043', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:34:35', '2025-10-27 02:32:03'),
(6, 1, '0406060000015', 'Mfundo', 'Shabangu', 'Female', '26879000015', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:31:32', '2025-10-27 02:33:10'),
(7, 1, '1407070000025', 'Samkeliso', 'Nxumalo', 'Male', '26876000025', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:34:44', '2025-10-27 02:33:57'),
(8, 1, '1609090000027', 'Mthokozisi', 'Simelane', 'Male', '26879000027', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:31:34', '2025-10-27 02:34:30'),
(9, 1, '1903030000030', 'Phumelele', 'Mabuza', 'Female', '26879000030', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:34:47', '2025-10-27 02:34:57'),
(10, 1, '2206060000033', 'Bongani', 'Nxumalo', 'Male', '26879000033', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:31:28', '2025-10-27 02:35:29'),
(11, 1, '2601010000037', 'Sabelo', 'Mthethwa', 'Male', '26876000037', 'Chairperson', 1, 'verified', NULL, 18, '2025-10-28 11:34:50', '2025-10-27 02:36:10'),
(12, 1, '3005050000041', 'Thokozani', 'Shongwe', 'Male', '26878000041', 'Member', 1, 'verified', NULL, 18, '2025-10-28 11:34:37', '2025-10-27 02:36:46'),
(13, 2, '9203030000003', 'Thabo', 'Mthethwa', 'Male', '26879000003', 'Chairman', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:04:30'),
(14, 2, '9304040000004', 'Ayanda', 'Nkambule', 'Female', '26876000004', 'Secretary', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:05:08'),
(15, 2, '9405050000005', 'Sipho', 'Shongwe', 'Female', '26878000005', 'Treasurer', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:05:35'),
(16, 2, '9506060000006', 'Zanele', 'Magagula', 'Female', '26879000006', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:06:02'),
(17, 2, '9607070000007', 'Banele', 'Nxumalo', 'Male', '26876000007', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:06:23'),
(18, 2, '9708080000008', 'Phindile', 'Dlamini', 'Female', '26878000008', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:06:48'),
(19, 2, '9809090000009', 'Mandla', 'Mamba', 'Male', '26879000009', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:07:16'),
(20, 2, '9901010000010', 'Nokuthula', 'Mhlanga', 'Female', '26876000010', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:07:40'),
(21, 2, '0002020000011', 'Sandile', 'Simelane', 'Male', '26878000011', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:08:06'),
(22, 2, '0103030000012', 'Lindiwe', 'Dlamini', 'Female', '26879000012', 'Member', 1, 'pending', NULL, NULL, NULL, '2025-10-28 14:08:44');

-- --------------------------------------------------------

--
-- Table structure for table `eog_temporal_activity`
--

CREATE TABLE `eog_temporal_activity` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `activity_type` enum('registration_started','document_uploaded','member_added','member_verified','submission_attempted','cdo_review_requested','expiry_warning_sent','account_expired','account_activated') NOT NULL,
  `description` text DEFAULT NULL,
  `performed_by` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eog_temporal_activity`
--

INSERT INTO `eog_temporal_activity` (`id`, `eog_id`, `activity_type`, `description`, `performed_by`, `ip_address`, `created_at`) VALUES
(1, 1, 'registration_started', 'EOG created temporary account', 17, '::ffff:127.0.0.1', '2025-10-26 11:02:49'),
(2, 1, 'document_uploaded', 'Uploaded constitution document: Application Letter Sibusiso Dif Simelane.pdf', 17, '::ffff:127.0.0.1', '2025-10-26 16:24:20'),
(3, 1, 'document_uploaded', 'Uploaded recognition_letter document: Application_Trainig Center Dif.pdf', 17, '::ffff:127.0.0.1', '2025-10-26 16:24:40'),
(4, 1, 'document_uploaded', 'Uploaded articles document: Application St Theresa - Sibusiso.pdf', 17, '::ffff:127.0.0.1', '2025-10-26 16:24:47'),
(5, 1, 'document_uploaded', 'Uploaded form_j document: Cover letter - Sibusio Simelane.pdf', 17, '::ffff:127.0.0.1', '2025-10-26 16:24:51'),
(6, 1, 'document_uploaded', 'Uploaded certificate document: cover page.pdf', 17, '::ffff:127.0.0.1', '2025-10-26 16:24:55'),
(7, 1, 'document_uploaded', 'Uploaded member_list document: HMIS Interns.xlsx', 17, '::ffff:127.0.0.1', '2025-10-26 16:25:01'),
(8, 1, 'member_added', 'Added executive member: Musa Dlamini (Chairman)', 17, '::ffff:127.0.0.1', '2025-10-26 16:37:14'),
(9, 1, 'document_uploaded', 'Uploaded member_list document: sampling.csv', 17, '::ffff:127.0.0.1', '2025-10-26 17:25:23'),
(10, 1, 'member_added', 'Added executive member: Sibusiso Dlamini (Secretary)', 17, '::ffff:127.0.0.1', '2025-10-27 02:30:03'),
(11, 1, 'member_added', 'Added executive member: Nandi Shongwe (Treasurer)', 17, '::ffff:127.0.0.1', '2025-10-27 02:31:20'),
(12, 1, 'member_added', 'Added executive member: Siphesihle Mamba (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:32:03'),
(13, 1, 'member_added', 'Added executive member: Mfundo Shabangu (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:33:10'),
(14, 1, 'member_added', 'Added executive member: Samkeliso Nxumalo (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:33:57'),
(15, 1, 'member_added', 'Added executive member: Mthokozisi Simelane (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:34:30'),
(16, 1, 'member_added', 'Added executive member: Phumelele Mabuza (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:34:57'),
(17, 1, 'member_added', 'Added executive member: Bongani Nxumalo (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:35:29'),
(18, 1, 'member_added', 'Added executive member: Sabelo Mthethwa (Chairperson)', 17, '::ffff:127.0.0.1', '2025-10-27 02:36:10'),
(19, 1, 'member_added', 'Added executive member: Thokozani Shongwe (Member)', 17, '::ffff:127.0.0.1', '2025-10-27 02:36:46'),
(20, 1, '', 'Submitted EOG for CDO review', 17, '::ffff:127.0.0.1', '2025-10-27 02:37:00'),
(21, 1, '', 'CDO started reviewing EOG', 18, '::ffff:127.0.0.1', '2025-10-28 11:30:44'),
(22, 1, 'member_verified', 'CDO verified member: Bongani Nxumalo', 18, '::ffff:127.0.0.1', '2025-10-28 11:31:28'),
(23, 1, 'member_verified', 'CDO verified member: Mfundo Shabangu', 18, '::ffff:127.0.0.1', '2025-10-28 11:31:32'),
(24, 1, 'member_verified', 'CDO verified member: Mthokozisi Simelane', 18, '::ffff:127.0.0.1', '2025-10-28 11:31:34'),
(25, 1, 'member_verified', 'CDO verified member: Musa Dlamini', 18, '::ffff:127.0.0.1', '2025-10-28 11:31:36'),
(26, 1, 'member_verified', 'CDO verified member: Nandi Shongwe', 18, '::ffff:127.0.0.1', '2025-10-28 11:31:39'),
(27, 1, 'member_verified', 'CDO verified member: Siphesihle Mamba', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:35'),
(28, 1, 'member_verified', 'CDO verified member: Thokozani Shongwe', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:37'),
(29, 1, 'member_verified', 'CDO verified member: Sibusiso Dlamini', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:41'),
(30, 1, 'member_verified', 'CDO verified member: Samkeliso Nxumalo', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:44'),
(31, 1, 'member_verified', 'CDO verified member: Phumelele Mabuza', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:47'),
(32, 1, 'member_verified', 'CDO verified member: Sabelo Mthethwa', 18, '::ffff:127.0.0.1', '2025-10-28 11:34:50'),
(33, 1, '', 'EOG approved by CDO: No notes provided', 18, '::ffff:127.0.0.1', '2025-10-28 11:35:10'),
(34, 2, 'registration_started', 'EOG created temporary account', 19, '::ffff:127.0.0.1', '2025-10-28 13:23:26'),
(35, 2, 'document_uploaded', 'Uploaded constitution document: Application Letter - Mfundo Masilela.pdf', 19, '::ffff:127.0.0.1', '2025-10-28 13:33:12'),
(36, 2, 'document_uploaded', 'Uploaded recognition_letter document: Application Letter - Mfundo Masilela.pdf', 19, '::ffff:127.0.0.1', '2025-10-28 13:33:17'),
(37, 2, 'document_uploaded', 'Uploaded articles document: Application Letter - Mfundo Masilela.pdf', 19, '::ffff:127.0.0.1', '2025-10-28 13:33:24'),
(38, 2, 'document_uploaded', 'Uploaded form_j document: cover page.pdf', 19, '::ffff:127.0.0.1', '2025-10-28 14:00:38'),
(39, 2, 'document_uploaded', 'Uploaded certificate document: Blue Breeze Investment.pdf', 19, '::ffff:127.0.0.1', '2025-10-28 14:00:45'),
(40, 2, 'document_uploaded', 'Uploaded member_list document: facilitySheet_updated.xlsx', 19, '::ffff:127.0.0.1', '2025-10-28 14:00:52'),
(41, 2, 'member_added', 'Added executive member: Thabo Mthethwa (Chairman)', 19, '::ffff:127.0.0.1', '2025-10-28 14:04:30'),
(42, 2, 'member_added', 'Added executive member: Ayanda Nkambule (Secretary)', 19, '::ffff:127.0.0.1', '2025-10-28 14:05:08'),
(43, 2, 'member_added', 'Added executive member: Sipho Shongwe (Treasurer)', 19, '::ffff:127.0.0.1', '2025-10-28 14:05:35'),
(44, 2, 'member_added', 'Added executive member: Zanele Magagula (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:06:02'),
(45, 2, 'member_added', 'Added executive member: Banele Nxumalo (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:06:23'),
(46, 2, 'member_added', 'Added executive member: Phindile Dlamini (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:06:48'),
(47, 2, 'member_added', 'Added executive member: Mandla Mamba (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:07:16'),
(48, 2, 'member_added', 'Added executive member: Nokuthula Mhlanga (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:07:40'),
(49, 2, 'member_added', 'Added executive member: Sandile Simelane (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:08:06'),
(50, 2, 'member_added', 'Added executive member: Lindiwe Dlamini (Member)', 19, '::ffff:127.0.0.1', '2025-10-28 14:08:44'),
(51, 2, '', 'Submitted EOG for CDO review', 19, '::ffff:127.0.0.1', '2025-10-28 14:20:13');

-- --------------------------------------------------------

--
-- Table structure for table `eog_users`
--

CREATE TABLE `eog_users` (
  `id` int(11) NOT NULL,
  `eog_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_primary_contact` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eog_users`
--

INSERT INTO `eog_users` (`id`, `eog_id`, `user_id`, `is_primary_contact`, `created_at`) VALUES
(1, 1, 17, 1, '2025-10-26 11:02:49'),
(2, 2, 19, 1, '2025-10-28 13:23:26');

-- --------------------------------------------------------

--
-- Table structure for table `forms`
--

CREATE TABLE `forms` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `version` varchar(20) DEFAULT '1.0',
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `forms`
--

INSERT INTO `forms` (`id`, `name`, `description`, `version`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
(5, 'Regional Development Fund Application Form', 'Ministry of Tinkhundla Administration and Development', '1.2', 1, 1, '2025-10-27 11:24:02', '2025-10-27 11:24:02');

-- --------------------------------------------------------

--
-- Table structure for table `form_questions`
--

CREATE TABLE `form_questions` (
  `id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('TEXT','TEXTAREA','NUMBER','DECIMAL','SELECT','MULTISELECT','RADIO','CHECKBOX','DATE','BOOLEAN','FILE','SIGNATURE','TABLE') NOT NULL,
  `options` text DEFAULT NULL,
  `is_required` tinyint(1) DEFAULT 0,
  `order_number` int(11) NOT NULL DEFAULT 0,
  `visible_to_roles` text DEFAULT NULL,
  `editable_by_roles` text DEFAULT NULL,
  `conditional_question_id` int(11) DEFAULT NULL,
  `conditional_answer` text DEFAULT NULL,
  `validation_rules` text DEFAULT NULL,
  `help_text` text DEFAULT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `table_config` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `table_columns` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`table_columns`)),
  `min_rows` int(11) DEFAULT NULL,
  `max_rows` int(11) DEFAULT NULL,
  `allow_add_rows` tinyint(1) DEFAULT 1,
  `allow_delete_rows` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `form_questions`
--

INSERT INTO `form_questions` (`id`, `section_id`, `question_text`, `question_type`, `options`, `is_required`, `order_number`, `visible_to_roles`, `editable_by_roles`, `conditional_question_id`, `conditional_answer`, `validation_rules`, `help_text`, `file_path`, `table_config`, `created_at`, `table_columns`, `min_rows`, `max_rows`, `allow_add_rows`, `allow_delete_rows`) VALUES
(27, 3, '1.1. NAME OF THE SWAZI ORGANIZED GROUP', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'libito le-EOG', NULL, NULL, '2025-10-27 14:10:05', NULL, NULL, NULL, 1, 1),
(28, 4, '2.1. TYPE AND FORM OF REGISTRATION OF ESWATINI ORGANIZED GROUP.', 'SELECT', '[\"Cooperative\",\"Company\",\"Partnership\",\"Association\",\"Community Group\",\"Scheme\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 14:13:21', NULL, NULL, NULL, 1, 1),
(31, 3, '1.2. POSTAL ADRESS OF APPLICANT', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'liposi', NULL, NULL, '2025-10-27 18:50:10', NULL, NULL, NULL, 1, 1),
(32, 3, '1.3. PHYSICAL ADDRESS', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'indzawo', NULL, NULL, '2025-10-27 18:50:35', NULL, NULL, NULL, 1, 1),
(33, 3, '1.4. NAME OF THE CHIEF', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'Sikhulu', NULL, NULL, '2025-10-27 18:50:59', NULL, NULL, NULL, 1, 1),
(34, 4, ' 2.2 TOTAL NUMBER OF REGISTERED MEMBERS', 'NUMBER', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 18:56:56', NULL, NULL, NULL, 1, 1),
(35, 4, '2.3 NAMES OFMEMBERS OF THE EXECUTIVE COMMITTEE AND THEIR CONTACT DETAILS.', 'TABLE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 18:58:05', '\"[{\\\"name\\\":\\\"designation\\\",\\\"label\\\":\\\"Designation\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"name\\\",\\\"label\\\":\\\"Name\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"id_no.\\\",\\\"label\\\":\\\"ID No.\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":false},{\\\"name\\\":\\\"contact\\\",\\\"label\\\":\\\"Contact\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true}]\"', 10, NULL, 1, 1),
(36, 4, '2.4 ATTACH LIST OF OTHER PROJECT MEMBERS WHERE NECESSARY (I.E. INCOME GENERATING PROJECTS)', 'FILE', NULL, 1, 3, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 18:59:15', NULL, NULL, NULL, 1, 1),
(37, 5, '3.1 CLASSIFICATION OF PROJECT', 'SELECT', '[\"Infrastructure\\rDevelopment Project\",\"Income Generating Project\",\"Regional Project\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:04:49', NULL, NULL, NULL, 1, 1),
(38, 5, '3.1.1  PROJECT DESCRIPTION', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:05:40', NULL, NULL, NULL, 1, 1),
(39, 6, ' 4.1. PURPOSE', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:07:10', NULL, NULL, NULL, 1, 1),
(40, 6, '4.2. BACKGROUND OF COMMUNITY (PROBLEMS)', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:07:48', NULL, NULL, NULL, 1, 1),
(41, 6, '4.3. TARGET POPULATION', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'Who are they, Number of Males, Number of Females', NULL, NULL, '2025-10-27 19:09:13', NULL, NULL, NULL, 1, 1),
(42, 6, '4.4. IMPACT', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'Change as a result of the projetc', NULL, NULL, '2025-10-27 19:10:08', NULL, NULL, NULL, 1, 1),
(43, 7, '5.1. HAVE YOU RECEIVED ANY ASSISTANCE TO DATE FOR THIS PROPOSED PROJECT', 'BOOLEAN', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:12:06', NULL, NULL, NULL, 1, 1),
(44, 7, '5.2. IF YES FROM WHO?', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 43, 'Yes', NULL, NULL, NULL, NULL, '2025-10-27 19:13:16', NULL, NULL, NULL, 1, 1),
(45, 7, '5.3. HOW MUCH CASH HAVE YOU SPENT TO-DATE ON THE PROJECT?', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:14:12', NULL, NULL, NULL, 1, 1),
(46, 7, ' 5.4. HOW MUCH DO YOU HAVE IN YOUR SAVINGS ACCOUNT? (E)', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'In Emalangeni ', NULL, NULL, '2025-10-27 19:15:19', NULL, NULL, NULL, 1, 1),
(47, 7, '5.5. FINANCIAL BREAKDOWN OFTHEPROJECT', 'FILE', NULL, 1, 4, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,MICROPROJECTS', 37, 'Infrastructure Development Project', NULL, 'Total construction costs if it is an Infrastructure Project - Projections must include contribution by the Applicant', NULL, NULL, '2025-10-27 19:21:40', NULL, NULL, NULL, 1, 1),
(48, 8, '6.0.1 DETAILS OF INCOME AND EXPENDITURE', 'FILE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 37, 'Income Generating Project', NULL, NULL, NULL, NULL, '2025-10-27 19:24:36', NULL, NULL, NULL, 1, 1),
(49, 8, '6.1. WHAT IS YOUR MARKET?', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:25:49', NULL, NULL, NULL, 1, 1),
(50, 8, '6.2. DO YOU HAVE ANY SALES AGREEMENT WITH YOUR MARKET?', 'BOOLEAN', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:26:46', NULL, NULL, NULL, 1, 1),
(51, 8, '6.2.1. PLEASE ATTACH A CONFIRIMATION LETTER FROM THE MARKET', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 50, 'Yes', NULL, NULL, NULL, NULL, '2025-10-27 19:27:38', NULL, NULL, NULL, 1, 1),
(52, 8, '7.1. WHO WILL OPERATEOR MANAGE THEPROJECT AFTER ITS COMPLETION?', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:28:40', NULL, NULL, NULL, 1, 1),
(53, 9, '7.1. WHO WILL OPERATEOR MANAGE THEPROJECT AFTER ITS COMPLETION?', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:29:28', NULL, NULL, NULL, 1, 1),
(54, 9, ' 7.2. WHAT ARE HIS/HER EXPERIENCES AND QUALIFICATIONS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:04', NULL, NULL, NULL, 1, 1),
(55, 9, '7.3. HOW WILL YOURAISE THE FUNDS FOR MAINTENANCE', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:29', NULL, NULL, NULL, 1, 1),
(56, 9, '7.4. WHAT WILL BE THE TOTAL COST PER YEAR?', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:53', NULL, NULL, NULL, 1, 1),
(57, 10, '8.1. ATTACH YOUR PLAN BELOW', 'FILE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:33:12', NULL, NULL, NULL, 1, 1),
(58, 11, ' 9.1. GOVERNMENT LINE MINISTRY TECHNICIAN\'S COMMENTS.', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'LINE_MINISTRY,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:34:38', NULL, NULL, NULL, 1, 1),
(59, 11, '9.2. COMMUNITY DEVELOPMENT OFFICER\'S COMMENTS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDO,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:35:25', NULL, NULL, NULL, 1, 1),
(60, 11, '9.3. MICRO-PROJECTS\'TECHNICIANS COMMENTS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'MICROPROJECTS,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:36:04', NULL, NULL, NULL, 1, 1),
(63, 13, '10.1.1 CHECKLIST BY BANDLANCANE AND DEVELOPMENT COMMITTEE', 'MULTISELECT', '[\"Are registered\\r in the Umphakatsi as a bona fide Eswatini organized group\",\"Community mobilization has been carried out by Community  Development Officers\",\"Involvement of line Ministry\",\"Availability of project design (from line ministry)\",\"Project will benefit the wider community\",\"Land/ site for the project is available and approved by umphakatsi\",\"Project is recommended for considerationby Inkhundla\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, 'If no, leave box unchecked', NULL, NULL, '2025-10-27 21:21:09', NULL, NULL, NULL, 1, 1),
(64, 15, '10.2.1. CDC Approvals', 'TABLE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 22:51:51', '\"[{\\\"name\\\":\\\"designation\\\",\\\"label\\\":\\\"Designation\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"fullname\\\",\\\"label\\\":\\\"Fullname\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"date\\\",\\\"label\\\":\\\"Date\\\",\\\"type\\\":\\\"DATE\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"id_no.\\\",\\\"label\\\":\\\"ID No.\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true}]\"', 3, 3, 1, 1),
(65, 15, 'PLEASE INSERT UMPHAKATSIOFFICIAL STANMP HERE.', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 23:00:18', NULL, NULL, NULL, 1, 1),
(66, 16, '10.3.1.  Confirmation by Inkhundla Council that the applicants', 'CHECKBOX', '[\"Are registered in the Inkhundlas a bona fide Eswatini Organized Group\",\"Went through Umphakatsi\",\"Community mobilization\\rhas been carried out by Community Development Officers\",\"Project has been technically appraised and viable\",\"Project will benefit the wider community and has at least ten members\",\"Land/ project site is available and approved by umphakatsi\",\"Project is a priority in the needs ofthe Inkhundla\",\"Project is recommended for appraisal by RDFTC\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'INKHUNDLA_COUNCIL,SUPER_USER', NULL, NULL, NULL, 'If no, leave box unchecked', NULL, NULL, '2025-10-27 23:04:51', NULL, NULL, NULL, 1, 1),
(67, 17, '10.4.1 Signatories', 'TABLE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'INKHUNDLA_COUNCIL,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 23:09:05', '\"[{\\\"name\\\":\\\"designation\\\",\\\"label\\\":\\\"Designation\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"fullname\\\",\\\"label\\\":\\\"Fullname\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"date\\\",\\\"label\\\":\\\"Date\\\",\\\"type\\\":\\\"DATE\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"id_no\\\",\\\"label\\\":\\\"ID No\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true}]\"', 3, 3, 1, 1),
(68, 17, 'INKHUNDLA STAMP', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,INKHUNDLA_COUNCIL', NULL, NULL, NULL, 'sitembu senkhundla', NULL, NULL, '2025-10-27 23:09:50', NULL, NULL, NULL, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `form_responses`
--

CREATE TABLE `form_responses` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `answer_text` text DEFAULT NULL,
  `answer_number` decimal(15,2) DEFAULT NULL,
  `answer_date` date DEFAULT NULL,
  `answer_file_path` varchar(500) DEFAULT NULL,
  `answered_by` int(11) NOT NULL,
  `answered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `form_sections`
--

CREATE TABLE `form_sections` (
  `id` int(11) NOT NULL,
  `form_id` int(11) NOT NULL,
  `parent_section_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `order_number` int(11) NOT NULL DEFAULT 0,
  `workflow_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `form_sections`
--

INSERT INTO `form_sections` (`id`, `form_id`, `parent_section_id`, `title`, `description`, `order_number`, `workflow_level`, `created_at`) VALUES
(3, 5, NULL, '1. PARTICULARS OF THE APPLICANT', NULL, 0, NULL, '2025-10-27 11:39:32'),
(4, 5, NULL, '2. REGISTRATION AND COMPOSITION OF COMMITTEE', NULL, 1, NULL, '2025-10-27 11:47:04'),
(5, 5, NULL, '3. Project Details', NULL, 2, NULL, '2025-10-27 14:18:46'),
(6, 5, NULL, '4. PROJECT FULL DESCRIPTION', 'INCLUDE SKETCH DIAGRAMS AS ATTACHEMENT WHERE APPLICABLE', 3, NULL, '2025-10-27 19:06:35'),
(7, 5, NULL, '5. CONTRIBUTIONS AND FINANCES', NULL, 4, NULL, '2025-10-27 19:10:40'),
(8, 5, NULL, ' 6. FOR INCOME GENERATING PROJECTS ANSWER BELOW', 'DETAILS OF INCOME AND EXPENDITURE OF THE PROPOSED PROJECT - THE APPLICANT MUST ATTACH A BUSINESS PLAN.', 5, NULL, '2025-10-27 19:22:51'),
(9, 5, NULL, '7. PROJECTMAINTAINENCEANDREPAIR', NULL, 6, NULL, '2025-10-27 19:28:14'),
(10, 5, NULL, ' 8. IMPLEMENTATION PLAN', NULL, 7, NULL, '2025-10-27 19:32:39'),
(11, 5, NULL, '9. COMMENTS ON PROJECT VIABILITY BY THE RELEVANT SECTOR EXPERTS.', NULL, 8, NULL, '2025-10-27 19:33:44'),
(12, 5, NULL, '10. TECHNICAL AND ADMINISTRATIVE CLEARANCES', NULL, 9, NULL, '2025-10-27 19:36:37'),
(13, 5, 12, ' 10.1. AT UMPHAKATSI LEVEL', 'Confirmation by Bandlancane and the Chairperson of the Community Development Committee that the applicants met and discussed the project with umphakatsi.', 0, 'UMPHAKATSI_LEVEL', '2025-10-27 20:44:21'),
(15, 5, 12, '10.2.\r Approvals at Umphakatsi level:', NULL, 1, 'UMPHAKATSI_LEVEL', '2025-10-27 22:12:40'),
(16, 5, 12, '10.3. AT INKHUNDLALEVEL', NULL, 2, 'INKHUNDLA_LEVEL', '2025-10-27 23:01:10'),
(17, 5, 12, '10.4. SIGNATURES of Inkhundla Representatives', NULL, 3, 'INKHUNDLA_LEVEL', '2025-10-27 23:06:56');

-- --------------------------------------------------------

--
-- Table structure for table `imiphakatsi`
--

CREATE TABLE `imiphakatsi` (
  `id` int(11) NOT NULL,
  `tinkhundla_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `chief_name` varchar(150) NOT NULL,
  `chief_contact` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `imiphakatsi`
--

INSERT INTO `imiphakatsi` (`id`, `tinkhundla_id`, `name`, `chief_name`, `chief_contact`, `created_at`) VALUES
(1, 1, 'Dlangeni', 'Chief Mfanasibili Dlangeni', NULL, '2025-10-24 07:43:01'),
(2, 1, 'KaSiko', 'Chief Mahlalela KaSiko', NULL, '2025-10-24 07:43:01'),
(3, 1, 'LaMgabhi', 'Chief Mgabhi Dlamini', NULL, '2025-10-24 07:43:01'),
(4, 1, 'Sitseni', 'Chief Zwelibanzi Sitseni', NULL, '2025-10-24 07:43:01'),
(5, 2, 'Elangeni', 'Chief Simelane Elangeni', NULL, '2025-10-24 07:43:01'),
(6, 2, 'Ezabeni', 'Chief Mamba Ezabeni', NULL, '2025-10-24 07:43:01'),
(7, 2, 'Ezulwini', 'Chief Fakudze Ezulwini', NULL, '2025-10-24 07:43:01'),
(8, 2, 'Lobamba', 'Chief Maseko Lobamba', NULL, '2025-10-24 07:43:01'),
(9, 2, 'Nkhanini', 'Chief Dlamini Nkhanini', NULL, '2025-10-24 07:43:01'),
(10, 3, 'Dvokolwako Ekuphakameni', 'Chief Dlamini Dvokolwako', NULL, '2025-10-24 07:43:01'),
(11, 3, 'Gucuka', 'Chief Gamedze Gucuka', NULL, '2025-10-24 07:43:01'),
(12, 3, 'Mavula', 'Chief Mavula Shongwe', NULL, '2025-10-24 07:43:01'),
(13, 3, 'Nyonyane Maguga', 'Chief Zwane Nyonyane', NULL, '2025-10-24 07:43:01'),
(14, 3, 'Tfuntini Buhlebuyeza', 'Chief Mabuza Tfuntini', NULL, '2025-10-24 07:43:01'),
(15, 3, 'Ekukhulumeni Mzaceni', 'Chief Hlophe Ekukhulumeni', NULL, '2025-10-24 07:43:01'),
(16, 3, 'Zandondo', 'Chief Msibi Zandondo', NULL, '2025-10-24 07:43:01'),
(17, 4, 'Edlozini', 'Chief Kunene Edlozini', NULL, '2025-10-24 07:43:01'),
(18, 4, 'Madlolo', 'Chief Sihlongonyane Madlolo', NULL, '2025-10-24 07:43:01'),
(19, 4, 'Maphalaleni', 'Chief Dlamini Maphalaleni', NULL, '2025-10-24 07:43:01'),
(20, 4, 'Nsingweni', 'Chief Tfwala Nsingweni', NULL, '2025-10-24 07:43:01'),
(21, 4, 'Mfeni', 'Chief Vilakati Mfeni', NULL, '2025-10-24 07:43:01'),
(22, 4, 'Mcengeni', 'Chief Magagula Mcengeni', NULL, '2025-10-24 07:43:01'),
(23, 5, 'Hereford\'s', 'Chief Simelane Hereford', NULL, '2025-10-24 07:43:01'),
(24, 5, 'Mavula', 'Chief Dlamini Mavula', NULL, '2025-10-24 07:43:01'),
(25, 5, 'Mfasini', 'Chief Motsa Mfasini', NULL, '2025-10-24 07:43:01'),
(26, 5, 'Mkhuzweni', 'Chief Nkambule Mkhuzweni', NULL, '2025-10-24 07:43:01'),
(27, 5, 'Mkhweni', 'Chief Shongwe Mkhweni', NULL, '2025-10-24 07:43:01'),
(28, 6, 'Fonteyn', 'Chief Masuku Fonteyn', NULL, '2025-10-24 07:43:01'),
(29, 6, 'Mdzimba Lofokati', 'Chief Mdzimba Lofokati', NULL, '2025-10-24 07:43:01'),
(30, 6, 'Msunduza', 'Chief Fakudze Msunduza', NULL, '2025-10-24 07:43:01'),
(31, 6, 'Sidvwashini', 'Chief Dlamini Sidvwashini', NULL, '2025-10-24 07:43:01'),
(32, 7, 'Mangwaneni', 'Chief Simelane Mangwaneni', NULL, '2025-10-24 07:43:01'),
(33, 7, 'Manzana', 'Chief Ngwenya Manzana', NULL, '2025-10-24 07:43:01'),
(34, 7, 'Nkwalini', 'Chief Hlophe Nkwalini', NULL, '2025-10-24 07:43:01'),
(35, 8, 'Malibeni', 'Chief Dlamini Malibeni', NULL, '2025-10-24 07:43:01'),
(36, 8, 'Mangweni', 'Chief Mabuza Mangweni', NULL, '2025-10-24 07:43:01'),
(37, 8, 'Mphofu', 'Chief Zwane Mphofu', NULL, '2025-10-24 07:43:01'),
(38, 8, 'Ndvwabangeni', 'Chief Maseko Ndvwabangeni', NULL, '2025-10-24 07:43:01'),
(39, 8, 'Nhlanguyavuka', 'Chief Tfwala Nhlanguyavuka', NULL, '2025-10-24 07:43:01'),
(40, 8, 'Nyakatfo', 'Chief Vilakati Nyakatfo', NULL, '2025-10-24 07:43:01'),
(41, 8, 'Sidvwashini', 'Chief Mamba Sidvwashini', NULL, '2025-10-24 07:43:01'),
(42, 8, 'Zinyane', 'Chief Gamedze Zinyane', NULL, '2025-10-24 07:43:01'),
(43, 9, 'Kupheleni', 'Chief Dlamini Kupheleni', NULL, '2025-10-24 07:43:01'),
(44, 9, 'Mpolonjeni', 'Chief Simelane Mpolonjeni', NULL, '2025-10-24 07:43:01'),
(45, 9, 'Nduma', 'Chief Shongwe Nduma', NULL, '2025-10-24 07:43:01'),
(46, 10, 'Bulandzeni', 'Chief Msibi Bulandzeni', NULL, '2025-10-24 07:43:01'),
(47, 10, 'Ludlawini', 'Chief Kunene Ludlawini', NULL, '2025-10-24 07:43:01'),
(48, 10, 'Kwaliweni', 'Chief Magagula Kwaliweni', NULL, '2025-10-24 07:43:01'),
(49, 10, 'Meleti', 'Chief Dlamini Meleti', NULL, '2025-10-24 07:43:01'),
(50, 10, 'Mvuma', 'Chief Motsa Mvuma', NULL, '2025-10-24 07:43:01'),
(51, 10, 'Mgungundlovu', 'Chief Fakudze Mgungundlovu', NULL, '2025-10-24 07:43:01'),
(52, 10, 'Ndzingeni', 'Chief Ndzingeni Nkambule', NULL, '2025-10-24 07:43:01'),
(53, 10, 'Nkamanzi', 'Chief Sihlongonyane Nkamanzi', NULL, '2025-10-24 07:43:01'),
(54, 10, 'Ntsanjeni', 'Chief Hlophe Ntsanjeni', NULL, '2025-10-24 07:43:01'),
(55, 11, 'Ejubukweni', 'Chief Dlamini Ejubukweni', NULL, '2025-10-24 07:43:01'),
(56, 11, 'Ekuvinjelweni', 'Chief Maseko Ekuvinjelweni', NULL, '2025-10-24 07:43:01'),
(57, 11, 'Malanti', 'Chief Tfwala Malanti', NULL, '2025-10-24 07:43:01'),
(58, 11, 'Nkhaba', 'Chief Nkhaba Gamedze', NULL, '2025-10-24 07:43:01'),
(59, 12, 'Emvembili', 'Chief Vilakati Emvembili', NULL, '2025-10-24 07:43:01'),
(60, 12, 'Hhelehhele', 'Chief Zwane Hhelehhele', NULL, '2025-10-24 07:43:01'),
(61, 12, 'Ka Hhohho', 'Chief Mabuza KaHhohho', NULL, '2025-10-24 07:43:01'),
(62, 12, 'KaNdwandwa', 'Chief Ndwandwa Dlamini', NULL, '2025-10-24 07:43:01'),
(63, 12, 'Lomshiyo', 'Chief Simelane Lomshiyo', NULL, '2025-10-24 07:43:01'),
(64, 12, 'Mshingishingini', 'Chief Mamba Mshingishingini', NULL, '2025-10-24 07:43:01'),
(65, 12, 'Vusweni', 'Chief Shongwe Vusweni', NULL, '2025-10-24 07:43:01'),
(66, 13, 'Bulembu Luhhumaneni 1', 'Chief Fakudze Bulembu', NULL, '2025-10-24 07:43:01'),
(67, 13, 'Luhhumaneni Kandeva', 'Chief Magagula Luhhumaneni', NULL, '2025-10-24 07:43:01'),
(68, 13, 'Luhlangotsini', 'Chief Dlamini Luhlangotsini', NULL, '2025-10-24 07:43:01'),
(69, 13, 'Nginamadvolo', 'Chief Maseko Nginamadvolo', NULL, '2025-10-24 07:43:01'),
(70, 13, 'Nsangwini', 'Chief Kunene Nsangwini', NULL, '2025-10-24 07:43:01'),
(71, 13, 'Pigg\'s Peak', 'Chief Simelane PiggsPeak', NULL, '2025-10-24 07:43:01'),
(72, 14, 'Luhlendlweni', 'Chief Hlophe Luhlendlweni', NULL, '2025-10-24 07:43:01'),
(73, 14, 'Mantabeni', 'Chief Motsa Mantabeni', NULL, '2025-10-24 07:43:01'),
(74, 14, 'Sigangeni', 'Chief Tfwala Sigangeni', NULL, '2025-10-24 07:43:01'),
(75, 14, 'Siphocosini', 'Chief Gamedze Siphocosini', NULL, '2025-10-24 07:43:01'),
(76, 15, 'Hhohho', 'Chief Dlamini Hhohho', NULL, '2025-10-24 07:43:01'),
(77, 15, 'Ludzibini', 'Chief Vilakati Ludzibini', NULL, '2025-10-24 07:43:01'),
(78, 15, 'Mashobeni North', 'Chief Sihlongonyane Mashobeni', NULL, '2025-10-24 07:43:01'),
(79, 15, 'Mvembili', 'Chief Msibi Mvembili', NULL, '2025-10-24 07:43:01'),
(80, 16, 'Hlane', 'Chief Zwane Hlane', NULL, '2025-10-24 07:43:01'),
(81, 16, 'Malindza', 'Chief Malindza Dlamini', NULL, '2025-10-24 07:43:01'),
(82, 16, 'Mdumezulu', 'Chief Maseko Mdumezulu', NULL, '2025-10-24 07:43:01'),
(83, 16, 'Mhlangatane', 'Chief Mamba Mhlangatane', NULL, '2025-10-24 07:43:01'),
(84, 16, 'Njabulweni', 'Chief Simelane Njabulweni', NULL, '2025-10-24 07:43:01'),
(85, 16, 'Ntandweni', 'Chief Fakudze Ntandweni', NULL, '2025-10-24 07:43:01'),
(86, 17, 'Bulunga', 'Chief Gamedze Bulunga', NULL, '2025-10-24 07:43:01'),
(87, 17, 'Etjedze', 'Chief Dlamini Etjedze', NULL, '2025-10-24 07:43:01'),
(88, 17, 'Hlutse', 'Chief Shongwe Hlutse', NULL, '2025-10-24 07:43:01'),
(89, 17, 'Mabondvweni', 'Chief Kunene Mabondvweni', NULL, '2025-10-24 07:43:01'),
(90, 17, 'Macetjeni', 'Chief Tfwala Macetjeni', NULL, '2025-10-24 07:43:01'),
(91, 17, 'Sigcaweni', 'Chief Motsa Sigcaweni', NULL, '2025-10-24 07:43:01'),
(92, 17, 'Vikizijula', 'Chief Vilakati Vikizijula', NULL, '2025-10-24 07:43:01'),
(93, 18, 'Lomahasha', 'Chief Lomahasha Magagula', NULL, '2025-10-24 07:43:01'),
(94, 18, 'Shewula', 'Chief Hlophe Shewula', NULL, '2025-10-24 07:43:01'),
(95, 19, 'Nsoko', 'Chief Nsoko Dlamini', NULL, '2025-10-24 07:43:01'),
(96, 19, 'KaVuma', 'Chief Vuma Simelane', NULL, '2025-10-24 07:43:01'),
(97, 19, 'Mabantaneni', 'Chief Msibi Mabantaneni', NULL, '2025-10-24 07:43:01'),
(98, 19, 'Ntuthwakazi', 'Chief Mabuza Ntuthwakazi', NULL, '2025-10-24 07:43:01'),
(99, 20, 'KaLanga', 'Chief Langa Fakudze', NULL, '2025-10-24 07:43:01'),
(100, 20, 'Makhewu', 'Chief Maseko Makhewu', NULL, '2025-10-24 07:43:01'),
(101, 20, 'Mlindazwe', 'Chief Zwane Mlindazwe', NULL, '2025-10-24 07:43:01'),
(102, 20, 'Sitsatsaweni', 'Chief Gamedze Sitsatsaweni', NULL, '2025-10-24 07:43:01'),
(103, 21, 'Lukhetseni', 'Chief Dlamini Lukhetseni', NULL, '2025-10-24 07:43:01'),
(104, 21, 'Mambane', 'Chief Simelane Mambane', NULL, '2025-10-24 07:43:01'),
(105, 21, 'Maphungwane', 'Chief Mamba Maphungwane', NULL, '2025-10-24 07:43:01'),
(106, 21, 'Tikhuba', 'Chief Shongwe Tikhuba', NULL, '2025-10-24 07:43:01'),
(107, 22, 'Mafucula', 'Chief Tfwala Mafucula', NULL, '2025-10-24 07:43:01'),
(108, 22, 'Mhlume', 'Chief Mhlume Kunene', NULL, '2025-10-24 07:43:01'),
(109, 22, 'Simunye', 'Chief Motsa Simunye', NULL, '2025-10-24 07:43:01'),
(110, 22, 'Tambankulu', 'Chief Vilakati Tambankulu', NULL, '2025-10-24 07:43:01'),
(111, 22, 'Tsambokhulu', 'Chief Hlophe Tsambokhulu', NULL, '2025-10-24 07:43:01'),
(112, 22, 'Tshaneni', 'Chief Fakudze Tshaneni', NULL, '2025-10-24 07:43:01'),
(113, 22, 'Vuvulane', 'Chief Magagula Vuvulane', NULL, '2025-10-24 07:43:01'),
(114, 23, 'KaShoba', 'Chief Shoba Dlamini', NULL, '2025-10-24 07:43:01'),
(115, 23, 'Mpolonjeni', 'Chief Simelane Mpolonjeni', NULL, '2025-10-24 07:43:01'),
(116, 23, 'Ndzangu', 'Chief Msibi Ndzangu', NULL, '2025-10-24 07:43:01'),
(117, 23, 'Ngcina', 'Chief Gamedze Ngcina', NULL, '2025-10-24 07:43:01'),
(118, 23, 'Sigcaweni East', 'Chief Mabuza Sigcaweni', NULL, '2025-10-24 07:43:01'),
(119, 24, 'Crooks Plantations', 'Chief Zwane Crooks', NULL, '2025-10-24 07:43:01'),
(120, 24, 'Gamula', 'Chief Maseko Gamula', NULL, '2025-10-24 07:43:01'),
(121, 24, 'Illovo Mayaluka', 'Chief Fakudze Illovo', NULL, '2025-10-24 07:43:01'),
(122, 24, 'Lunkuntfu', 'Chief Dlamini Lunkuntfu', NULL, '2025-10-24 07:43:01'),
(123, 24, 'Nkhanini Lusabeni', 'Chief Shongwe Nkhanini', NULL, '2025-10-24 07:43:01'),
(124, 24, 'Phafeni', 'Chief Kunene Phafeni', NULL, '2025-10-24 07:43:01'),
(125, 25, 'KaMkhweli', 'Chief Mkhweli Simelane', NULL, '2025-10-24 07:43:01'),
(126, 25, 'Madlenya', 'Chief Tfwala Madlenya', NULL, '2025-10-24 07:43:01'),
(127, 25, 'Maphilingo', 'Chief Motsa Maphilingo', NULL, '2025-10-24 07:43:01'),
(128, 25, 'Mphumakudze', 'Chief Vilakati Mphumakudze', NULL, '2025-10-24 07:43:01'),
(129, 25, 'Nceka', 'Chief Mamba Nceka', NULL, '2025-10-24 07:43:01'),
(130, 25, 'Ngevini', 'Chief Hlophe Ngevini', NULL, '2025-10-24 07:43:01'),
(131, 25, 'Tambuti', 'Chief Gamedze Tambuti', NULL, '2025-10-24 07:43:01'),
(132, 26, 'Luhlanyeni', 'Chief Magagula Luhlanyeni', NULL, '2025-10-24 07:43:01'),
(133, 26, 'Mamisa', 'Chief Dlamini Mamisa', NULL, '2025-10-24 07:43:01'),
(134, 26, 'Nkonjwa', 'Chief Fakudze Nkonjwa', NULL, '2025-10-24 07:43:01'),
(135, 26, 'Nokwane', 'Chief Msibi Nokwane', NULL, '2025-10-24 07:43:01'),
(136, 27, 'Bhekinkosi', 'Chief Dlamini Bhekinkosi', NULL, '2025-10-24 07:43:01'),
(137, 27, 'Maliyaduma', 'Chief Simelane Maliyaduma', NULL, '2025-10-24 07:43:01'),
(138, 27, 'Mbeka', 'Chief Maseko Mbeka', NULL, '2025-10-24 07:43:01'),
(139, 27, 'Mkhulamini', 'Chief Zwane Mkhulamini', NULL, '2025-10-24 07:43:01'),
(140, 27, 'Nkiliji', 'Chief Gamedze Nkiliji', NULL, '2025-10-24 07:43:01'),
(141, 27, 'Nyakeni', 'Chief Fakudze Nyakeni', NULL, '2025-10-24 07:43:01'),
(142, 27, 'Nswaceni', 'Chief Mamba Nswaceni', NULL, '2025-10-24 07:43:01'),
(143, 28, 'Dudzandla', 'Chief Shongwe Dudzandla', NULL, '2025-10-24 07:43:01'),
(144, 28, 'Ekukhanyeni', 'Chief Kunene Ekukhanyeni', NULL, '2025-10-24 07:43:01'),
(145, 28, 'Emgwempisi', 'Chief Tfwala Emgwempisi', NULL, '2025-10-24 07:43:01'),
(146, 28, 'Fumbhane', 'Chief Motsa Fumbhane', NULL, '2025-10-24 07:43:01'),
(147, 28, 'Kwaluseni', 'Chief Kwaluseni Vilakati', NULL, '2025-10-24 07:43:01'),
(148, 29, 'Ekujabuleni', 'Chief Hlophe Ekujabuleni', NULL, '2025-10-24 07:43:01'),
(149, 29, 'Kamkhweli', 'Chief Magagula Kamkhweli', NULL, '2025-10-24 07:43:01'),
(150, 29, 'Kudzeni', 'Chief Dlamini Kudzeni', NULL, '2025-10-24 07:43:01'),
(151, 29, 'Lozitha', 'Chief Msibi Lozitha', NULL, '2025-10-24 07:43:01'),
(152, 29, 'Mbekelweni', 'Chief Simelane Mbekelweni', NULL, '2025-10-24 07:43:01'),
(153, 29, 'Nkamanzi', 'Chief Mabuza Nkamanzi', NULL, '2025-10-24 07:43:01'),
(154, 29, 'Zombodze', 'Chief Fakudze Zombodze', NULL, '2025-10-24 07:43:01'),
(155, 30, 'Bhudla', 'Chief Maseko Bhudla', NULL, '2025-10-24 07:43:01'),
(156, 30, 'Ka Nkambule', 'Chief Nkambule Zwane', NULL, '2025-10-24 07:43:01'),
(157, 30, 'Luhlokohla', 'Chief Gamedze Luhlokohla', NULL, '2025-10-24 07:43:01'),
(158, 30, 'Mafutseni', 'Chief Dlamini Mafutseni', NULL, '2025-10-24 07:43:01'),
(159, 30, 'Ngculwini', 'Chief Shongwe Ngculwini', NULL, '2025-10-24 07:43:01'),
(160, 30, 'Timbutini', 'Chief Kunene Timbutini', NULL, '2025-10-24 07:43:01'),
(161, 31, 'Bhudla', 'Chief Tfwala Bhudla', NULL, '2025-10-24 07:43:01'),
(162, 31, 'Ka Nkambule', 'Chief Nkambule Motsa', NULL, '2025-10-24 07:43:01'),
(163, 31, 'Luhlokohla', 'Chief Vilakati Luhlokohla', NULL, '2025-10-24 07:43:01'),
(164, 31, 'Mafutseni', 'Chief Mamba Mafutseni', NULL, '2025-10-24 07:43:01'),
(165, 31, 'Ngculwini', 'Chief Hlophe Ngculwini', NULL, '2025-10-24 07:43:01'),
(166, 31, 'Timbutini', 'Chief Magagula Timbutini', NULL, '2025-10-24 07:43:01'),
(167, 32, 'Bhudla', 'Chief Fakudze Bhudla', NULL, '2025-10-24 07:43:01'),
(168, 32, 'Ka Nkambule', 'Chief Nkambule Dlamini', NULL, '2025-10-24 07:43:01'),
(169, 32, 'Luhlokohla', 'Chief Msibi Luhlokohla', NULL, '2025-10-24 07:43:01'),
(170, 32, 'Mafutseni', 'Chief Mafutseni Simelane', NULL, '2025-10-24 07:43:01'),
(171, 32, 'Ngculwini', 'Chief Mabuza Ngculwini', NULL, '2025-10-24 07:43:01'),
(172, 32, 'Timbutini', 'Chief Maseko Timbutini', NULL, '2025-10-24 07:43:01'),
(173, 33, 'Bhahwini', 'Chief Zwane Bhahwini', NULL, '2025-10-24 07:43:01'),
(174, 33, 'KaZulu', 'Chief Zulu Gamedze', NULL, '2025-10-24 07:43:01'),
(175, 33, 'Ludvodvolweni', 'Chief Dlamini Ludvodvolweni', NULL, '2025-10-24 07:43:01'),
(176, 33, 'Luzelweni', 'Chief Shongwe Luzelweni', NULL, '2025-10-24 07:43:01'),
(177, 33, 'Mahlangatsha', 'Chief Mahlangatsha Kunene', NULL, '2025-10-24 07:43:01'),
(178, 33, 'Mambatfweni', 'Chief Tfwala Mambatfweni', NULL, '2025-10-24 07:43:01'),
(179, 33, 'Mgofelweni', 'Chief Motsa Mgofelweni', NULL, '2025-10-24 07:43:01'),
(180, 33, 'Nciniselweni', 'Chief Vilakati Nciniselweni', NULL, '2025-10-24 07:43:01'),
(181, 33, 'Ndzeleni', 'Chief Hlophe Ndzeleni', NULL, '2025-10-24 07:43:01'),
(182, 33, 'Nsangwini', 'Chief Fakudze Nsangwini', NULL, '2025-10-24 07:43:01'),
(183, 33, 'Sigcineni', 'Chief Mamba Sigcineni', NULL, '2025-10-24 07:43:01'),
(184, 34, 'Dwalile', 'Chief Magagula Dwalile', NULL, '2025-10-24 07:43:01'),
(185, 34, 'Mabhukwini', 'Chief Dlamini Mabhukwini', NULL, '2025-10-24 07:43:01'),
(186, 34, 'Mangcongco Zenukeni', 'Chief Msibi Mangcongco', NULL, '2025-10-24 07:43:01'),
(187, 34, 'Sandlane Ekuthuleni', 'Chief Simelane Sandlane', NULL, '2025-10-24 07:43:01'),
(188, 35, 'Dvwaleni', 'Chief Mabuza Dvwaleni', NULL, '2025-10-24 07:43:01'),
(189, 35, 'Makholweni', 'Chief Maseko Makholweni', NULL, '2025-10-24 07:43:01'),
(190, 35, 'Manzini Central', 'Chief Fakudze ManziniCentral', NULL, '2025-10-24 07:43:01'),
(191, 35, 'Mnyenyweni', 'Chief Zwane Mnyenyweni', NULL, '2025-10-24 07:43:01'),
(192, 35, 'Mzimnene', 'Chief Gamedze Mzimnene', NULL, '2025-10-24 07:43:01'),
(193, 35, 'St Pauls', 'Chief Dlamini StPauls', NULL, '2025-10-24 07:43:01'),
(194, 36, 'Mhobodleni', 'Chief Shongwe Mhobodleni', NULL, '2025-10-24 07:43:01'),
(195, 36, 'Mjingo', 'Chief Kunene Mjingo', NULL, '2025-10-24 07:43:01'),
(196, 36, 'Moneni', 'Chief Tfwala Moneni', NULL, '2025-10-24 07:43:01'),
(197, 36, 'Ngwane Park', 'Chief Motsa NgwanePark', NULL, '2025-10-24 07:43:01'),
(198, 36, 'Ticancweni', 'Chief Vilakati Ticancweni', NULL, '2025-10-24 07:43:01'),
(199, 36, 'Zakhele', 'Chief Hlophe Zakhele', NULL, '2025-10-24 07:43:01'),
(200, 37, 'Bhunya', 'Chief Fakudze Bhunya', NULL, '2025-10-24 07:43:01'),
(201, 37, 'Dingizwe', 'Chief Mamba Dingizwe', NULL, '2025-10-24 07:43:01'),
(202, 37, 'Lundzi', 'Chief Magagula Lundzi', NULL, '2025-10-24 07:43:01'),
(203, 37, 'Mbangave', 'Chief Dlamini Mbangave', NULL, '2025-10-24 07:43:01'),
(204, 37, 'Mlindazwe', 'Chief Msibi Mlindazwe', NULL, '2025-10-24 07:43:01'),
(205, 37, 'Zondwako', 'Chief Simelane Zondwako', NULL, '2025-10-24 07:43:01'),
(206, 38, 'Mbelebeleni', 'Chief Mabuza Mbelebeleni', NULL, '2025-10-24 07:43:01'),
(207, 38, 'Ekutsimleni', 'Chief Maseko Ekutsimleni', NULL, '2025-10-24 07:43:01'),
(208, 38, 'Khuphuka', 'Chief Zwane Khuphuka', NULL, '2025-10-24 07:43:01'),
(209, 38, 'Dvokolwako', 'Chief Gamedze Dvokolwako', NULL, '2025-10-24 07:43:01'),
(210, 38, 'Mnjoli Likima', 'Chief Fakudze Mnjoli', NULL, '2025-10-24 07:43:01'),
(211, 39, 'Gundvwini', 'Chief Dlamini Gundvwini', NULL, '2025-10-24 07:43:01'),
(212, 39, 'Lwandle', 'Chief Shongwe Lwandle', NULL, '2025-10-24 07:43:01'),
(213, 39, 'Ndlandlameni', 'Chief Kunene Ndlandlameni', NULL, '2025-10-24 07:43:01'),
(214, 39, 'Hlane Bulunga', 'Chief Tfwala Hlane', NULL, '2025-10-24 07:43:01'),
(215, 40, 'Bhadzeni 1', 'Chief Motsa Bhadzeni', NULL, '2025-10-24 07:43:01'),
(216, 40, 'Dladleni', 'Chief Vilakati Dladleni', NULL, '2025-10-24 07:43:01'),
(217, 40, 'Macundvulwini', 'Chief Hlophe Macundvulwini', NULL, '2025-10-24 07:43:01'),
(218, 40, 'Ngcoseni', 'Chief Fakudze Ngcoseni', NULL, '2025-10-24 07:43:01'),
(219, 40, 'Velezizweni', 'Chief Mamba Velezizweni', NULL, '2025-10-24 07:43:01'),
(220, 41, 'Masundvwini', 'Chief Magagula Masundvwini', NULL, '2025-10-24 07:43:01'),
(221, 41, 'Mphankhomo', 'Chief Dlamini Mphankhomo', NULL, '2025-10-24 07:43:01'),
(222, 41, 'Ngonini', 'Chief Msibi Ngonini', NULL, '2025-10-24 07:43:01'),
(223, 41, 'Njelu', 'Chief Simelane Njelu', NULL, '2025-10-24 07:43:01'),
(224, 42, 'Eni', 'Chief Mabuza Eni', NULL, '2025-10-24 07:43:01'),
(225, 42, 'Ngcayini', 'Chief Maseko Ngcayini', NULL, '2025-10-24 07:43:01'),
(226, 42, 'Ntunja', 'Chief Zwane Ntunja', NULL, '2025-10-24 07:43:01'),
(227, 42, 'Nsenga', 'Chief Gamedze Nsenga', NULL, '2025-10-24 07:43:01'),
(228, 42, 'Nsingweni', 'Chief Fakudze Nsingweni', NULL, '2025-10-24 07:43:01'),
(229, 42, 'Sankolweni', 'Chief Dlamini Sankolweni', NULL, '2025-10-24 07:43:01'),
(230, 42, 'Sigombeni', 'Chief Shongwe Sigombeni', NULL, '2025-10-24 07:43:01'),
(231, 42, 'Sibuyeni', 'Chief Kunene Sibuyeni', NULL, '2025-10-24 07:43:01'),
(232, 42, 'Vusweni', 'Chief Tfwala Vusweni', NULL, '2025-10-24 07:43:01'),
(233, 43, 'Gebeni', 'Chief Motsa Gebeni', NULL, '2025-10-24 07:43:01'),
(234, 43, 'Khalangilile', 'Chief Vilakati Khalangilile', NULL, '2025-10-24 07:43:01'),
(235, 43, 'Mphini', 'Chief Hlophe Mphini', NULL, '2025-10-24 07:43:01'),
(236, 43, 'Ncabaneni', 'Chief Fakudze Ncabaneni', NULL, '2025-10-24 07:43:01'),
(237, 43, 'Ndinda', 'Chief Mamba Ndinda', NULL, '2025-10-24 07:43:01'),
(238, 43, 'Ndlinilembi', 'Chief Magagula Ndlinilembi', NULL, '2025-10-24 07:43:01'),
(239, 43, 'Ntondozi', 'Chief Ntondozi Dlamini', NULL, '2025-10-24 07:43:01'),
(240, 44, 'Bhadzeni 2', 'Chief Msibi Bhadzeni', NULL, '2025-10-24 07:43:01'),
(241, 44, 'Khabonina', 'Chief Simelane Khabonina', NULL, '2025-10-24 07:43:01'),
(242, 44, 'Lushikishini', 'Chief Mabuza Lushikishini', NULL, '2025-10-24 07:43:01'),
(243, 44, 'Mahhashini', 'Chief Maseko Mahhashini', NULL, '2025-10-24 07:43:01'),
(244, 44, 'Mgazini', 'Chief Zwane Mgazini', NULL, '2025-10-24 07:43:01'),
(245, 45, 'Dilini', 'Chief Gamedze Dilini', NULL, '2025-10-24 07:43:01'),
(246, 45, 'KaDinga', 'Chief Dinga Fakudze', NULL, '2025-10-24 07:43:01'),
(247, 45, 'KaTsambekwako', 'Chief Tsambekwako Dlamini', NULL, '2025-10-24 07:43:01'),
(248, 45, 'Mashobeni South', 'Chief Mamba Mashobeni', NULL, '2025-10-24 07:43:01'),
(249, 45, 'Mhlahlweni', 'Chief Shongwe Mhlahlweni', NULL, '2025-10-24 07:43:01'),
(250, 45, 'Mlindazwe', 'Chief Kunene Mlindazwe', NULL, '2025-10-24 07:43:01'),
(251, 45, 'Nshamanti', 'Chief Tfwala Nshamanti', NULL, '2025-10-24 07:43:01'),
(252, 45, 'Nsukazi', 'Chief Motsa Nsukazi', NULL, '2025-10-24 07:43:01'),
(253, 45, 'Sidwala', 'Chief Vilakati Sidwala', NULL, '2025-10-24 07:43:01'),
(254, 45, 'Sisingeni', 'Chief Hlophe Sisingeni', NULL, '2025-10-24 07:43:01'),
(255, 45, 'Siyendle', 'Chief Magagula Siyendle', NULL, '2025-10-24 07:43:01'),
(256, 46, 'Bufaneni', 'Chief Dlamini Bufaneni', NULL, '2025-10-24 07:43:01'),
(257, 46, 'Hhohho Emuva', 'Chief Msibi HhohhoEmuva', NULL, '2025-10-24 07:43:01'),
(258, 46, 'KaLiba', 'Chief Liba Simelane', NULL, '2025-10-24 07:43:01'),
(259, 46, 'Lushini', 'Chief Mabuza Lushini', NULL, '2025-10-24 07:43:01'),
(260, 46, 'Manyiseni', 'Chief Maseko Manyiseni', NULL, '2025-10-24 07:43:01'),
(261, 46, 'Nsingizini', 'Chief Zwane Nsingizini', NULL, '2025-10-24 07:43:01'),
(262, 46, 'Ondiyaneni', 'Chief Gamedze Ondiyaneni', NULL, '2025-10-24 07:43:01'),
(263, 47, 'Ezishineni', 'Chief Fakudze Ezishineni', NULL, '2025-10-24 07:43:01'),
(264, 47, 'KaGwebu', 'Chief Gwebu Dlamini', NULL, '2025-10-24 07:43:01'),
(265, 47, 'KaKholwane', 'Chief Kholwane Shongwe', NULL, '2025-10-24 07:43:01'),
(266, 47, 'KaMbhoke', 'Chief Mbhoke Kunene', NULL, '2025-10-24 07:43:01'),
(267, 47, 'KaPhunga', 'Chief Phunga Tfwala', NULL, '2025-10-24 07:43:01'),
(268, 47, 'Manyeveni', 'Chief Motsa Manyeveni', NULL, '2025-10-24 07:43:01'),
(269, 47, 'Ngobelweni', 'Chief Vilakati Ngobelweni', NULL, '2025-10-24 07:43:01'),
(270, 47, 'Nhlalabantfu', 'Chief Hlophe Nhlalabantfu', NULL, '2025-10-24 07:43:01'),
(271, 48, 'Gasa', 'Chief Fakudze Gasa', NULL, '2025-10-24 07:43:01'),
(272, 48, 'Khamsile', 'Chief Mamba Khamsile', NULL, '2025-10-24 07:43:01'),
(273, 48, 'Lomfa', 'Chief Magagula Lomfa', NULL, '2025-10-24 07:43:01'),
(274, 48, 'Mbabane', 'Chief Dlamini Mbabane', NULL, '2025-10-24 07:43:01'),
(275, 48, 'Mbangweni', 'Chief Msibi Mbangweni', NULL, '2025-10-24 07:43:01'),
(276, 48, 'Nkalaneni', 'Chief Simelane Nkalaneni', NULL, '2025-10-24 07:43:01'),
(277, 48, 'Nkomonye', 'Chief Mabuza Nkomonye', NULL, '2025-10-24 07:43:01'),
(278, 48, 'Nzameya', 'Chief Maseko Nzameya', NULL, '2025-10-24 07:43:01'),
(279, 49, 'Dlovunga', 'Chief Zwane Dlovunga', NULL, '2025-10-24 07:43:01'),
(280, 49, 'KaMzizi', 'Chief Mzizi Gamedze', NULL, '2025-10-24 07:43:01'),
(281, 49, 'Masibini', 'Chief Fakudze Masibini', NULL, '2025-10-24 07:43:01'),
(282, 49, 'Mbilaneni', 'Chief Dlamini Mbilaneni', NULL, '2025-10-24 07:43:01'),
(283, 49, 'Simemeni', 'Chief Shongwe Simemeni', NULL, '2025-10-24 07:43:01'),
(284, 49, 'Vusweni', 'Chief Kunene Vusweni', NULL, '2025-10-24 07:43:01'),
(285, 50, 'Bambitje', 'Chief Tfwala Bambitje', NULL, '2025-10-24 07:43:01'),
(286, 50, 'Dinabanye', 'Chief Motsa Dinabanye', NULL, '2025-10-24 07:43:01'),
(287, 50, 'Kwaluseni', 'Chief Vilakati Kwaluseni', NULL, '2025-10-24 07:43:01'),
(288, 50, 'Nkonka', 'Chief Hlophe Nkonka', NULL, '2025-10-24 07:43:01'),
(289, 50, 'Nsalitje', 'Chief Fakudze Nsalitje', NULL, '2025-10-24 07:43:01'),
(290, 50, 'Qomintaba', 'Chief Mamba Qomintaba', NULL, '2025-10-24 07:43:01'),
(291, 51, 'Ebenezer', 'Chief Magagula Ebenezer', NULL, '2025-10-24 07:43:01'),
(292, 51, 'Bhanganoma', 'Chief Dlamini Bhanganoma', NULL, '2025-10-24 07:43:01'),
(293, 51, 'Kwendzeni', 'Chief Msibi Kwendzeni', NULL, '2025-10-24 07:43:01'),
(294, 51, 'KaZenzile', 'Chief Zenzile Simelane', NULL, '2025-10-24 07:43:01'),
(295, 51, 'Magele', 'Chief Mabuza Magele', NULL, '2025-10-24 07:43:01'),
(296, 52, 'KaMkhaya', 'Chief Mkhaya Maseko', NULL, '2025-10-24 07:43:01'),
(297, 52, 'KaMhawu', 'Chief Mhawu Zwane', NULL, '2025-10-24 07:43:01'),
(298, 52, 'KaMshengu', 'Chief Mshengu Gamedze', NULL, '2025-10-24 07:43:01'),
(299, 52, 'Lusitini', 'Chief Fakudze Lusitini', NULL, '2025-10-24 07:43:01'),
(300, 52, 'Mphini', 'Chief Dlamini Mphini', NULL, '2025-10-24 07:43:01'),
(301, 52, 'Ndushulweni', 'Chief Shongwe Ndushulweni', NULL, '2025-10-24 07:43:01'),
(302, 52, 'Nokwane', 'Chief Kunene Nokwane', NULL, '2025-10-24 07:43:01'),
(303, 52, 'Phobane', 'Chief Tfwala Phobane', NULL, '2025-10-24 07:43:01'),
(304, 53, 'Buseleni', 'Chief Motsa Buseleni', NULL, '2025-10-24 07:43:01'),
(305, 53, 'Hlobane', 'Chief Vilakati Hlobane', NULL, '2025-10-24 07:43:01'),
(306, 53, 'Ekuphumleni', 'Chief Hlophe Ekuphumleni', NULL, '2025-10-24 07:43:01'),
(307, 53, 'Nkwene', 'Chief Nkwene Fakudze', NULL, '2025-10-24 07:43:01'),
(308, 54, 'Ezibondeni KaShiba', 'Chief Shiba Mamba', NULL, '2025-10-24 07:43:01'),
(309, 54, 'KaGwegwe', 'Chief Gwegwe Magagula', NULL, '2025-10-24 07:43:01'),
(310, 54, 'Ngololweni', 'Chief Dlamini Ngololweni', NULL, '2025-10-24 07:43:01'),
(311, 54, 'Nhletjeni', 'Chief Msibi Nhletjeni', NULL, '2025-10-24 07:43:01'),
(312, 54, 'Nkhungwini', 'Chief Simelane Nkhungwini', NULL, '2025-10-24 07:43:01'),
(313, 55, 'Dumenkungwini', 'Chief Mabuza Dumenkungwini', NULL, '2025-10-24 07:43:01'),
(314, 55, 'Eposini', 'Chief Maseko Eposini', NULL, '2025-10-24 07:43:01'),
(315, 55, 'Hhuhhuma', 'Chief Zwane Hhuhhuma', NULL, '2025-10-24 07:43:01'),
(316, 55, 'Mabonabulawe', 'Chief Gamedze Mabonabulawe', NULL, '2025-10-24 07:43:01'),
(317, 55, 'Manyandzeni', 'Chief Fakudze Manyandzeni', NULL, '2025-10-24 07:43:01'),
(318, 55, 'Mchinsweni', 'Chief Dlamini Mchinsweni', NULL, '2025-10-24 07:43:01'),
(319, 55, 'Zikhotheni', 'Chief Shongwe Zikhotheni', NULL, '2025-10-24 07:43:01'),
(320, 56, 'Mahlalini', 'Chief Kunene Mahlalini', NULL, '2025-10-24 07:43:01'),
(321, 56, 'Makhwelela', 'Chief Tfwala Makhwelela', NULL, '2025-10-24 07:43:01'),
(322, 56, 'Mathendele', 'Chief Motsa Mathendele', NULL, '2025-10-24 07:43:01'),
(323, 56, 'Mbabala', 'Chief Vilakati Mbabala', NULL, '2025-10-24 07:43:01'),
(324, 56, 'Mbangweni', 'Chief Hlophe Mbangweni', NULL, '2025-10-24 07:43:01'),
(325, 56, 'Mbeka', 'Chief Fakudze Mbeka', NULL, '2025-10-24 07:43:01'),
(326, 56, 'Mkhitsini', 'Chief Mamba Mkhitsini', NULL, '2025-10-24 07:43:01'),
(327, 56, 'Mpangisweni', 'Chief Magagula Mpangisweni', NULL, '2025-10-24 07:43:01'),
(328, 56, 'Sikhotseni', 'Chief Dlamini Sikhotseni', NULL, '2025-10-24 07:43:01'),
(329, 57, 'Kuphumleni Enjabulweni', 'Chief Msibi Kuphumleni', NULL, '2025-10-24 07:43:01'),
(330, 57, 'Lulakeni', 'Chief Simelane Lulakeni', NULL, '2025-10-24 07:43:01'),
(331, 57, 'Ndunayithini', 'Chief Mabuza Ndunayithini', NULL, '2025-10-24 07:43:01'),
(332, 57, 'Nyatsini', 'Chief Maseko Nyatsini', NULL, '2025-10-24 07:43:01'),
(333, 58, 'Etjeni', 'Chief Zwane Etjeni', NULL, '2025-10-24 07:43:01'),
(334, 58, 'Luhlekweni', 'Chief Gamedze Luhlekweni', NULL, '2025-10-24 07:43:01'),
(335, 58, 'Maplotini', 'Chief Fakudze Maplotini', NULL, '2025-10-24 07:43:01'),
(336, 58, 'Nsubane', 'Chief Dlamini Nsubane', NULL, '2025-10-24 07:43:01'),
(337, 58, 'Ntuthwakazi', 'Chief Shongwe Ntuthwakazi', NULL, '2025-10-24 07:43:01'),
(338, 58, 'Phangweni', 'Chief Kunene Phangweni', NULL, '2025-10-24 07:43:01'),
(339, 58, 'Vimbizibuko', 'Chief Tfwala Vimbizibuko', NULL, '2025-10-24 07:43:01'),
(340, 59, 'Bulekeni', 'Chief Motsa Bulekeni', NULL, '2025-10-24 07:43:01'),
(341, 59, 'Mampondweni', 'Chief Vilakati Mampondweni', NULL, '2025-10-24 07:43:01'),
(342, 59, 'Ngwenyameni', 'Chief Hlophe Ngwenyameni', NULL, '2025-10-24 07:43:01'),
(343, 59, 'Zombodze', 'Chief Zombodze Fakudze', NULL, '2025-10-24 07:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `impact_assessments`
--

CREATE TABLE `impact_assessments` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `assessment_date` date NOT NULL,
  `assessor_user_id` int(11) NOT NULL,
  `jobs_created` int(11) DEFAULT 0,
  `beneficiaries_reached` int(11) DEFAULT 0,
  `economic_impact` decimal(15,2) DEFAULT NULL,
  `social_impact_score` int(11) DEFAULT NULL CHECK (`social_impact_score` >= 1 and `social_impact_score` <= 10),
  `environmental_impact_score` int(11) DEFAULT NULL CHECK (`environmental_impact_score` >= 1 and `environmental_impact_score` <= 10),
  `assessment_report` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `member_verification_issues`
--

CREATE TABLE `member_verification_issues` (
  `id` int(11) NOT NULL,
  `eog_member_id` int(11) NOT NULL,
  `issue_type` enum('id_not_found','name_mismatch','gender_mismatch','not_trained','multiple_matches','other') NOT NULL,
  `issue_description` text DEFAULT NULL,
  `training_register_id` int(11) DEFAULT NULL,
  `reported_by` int(11) DEFAULT NULL,
  `resolved` tinyint(1) DEFAULT 0,
  `resolution_notes` text DEFAULT NULL,
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `member_verification_issues`
--

INSERT INTO `member_verification_issues` (`id`, `eog_member_id`, `issue_type`, `issue_description`, `training_register_id`, `reported_by`, `resolved`, `resolution_notes`, `resolved_by`, `resolved_at`, `created_at`) VALUES
(1, 2, 'name_mismatch', 'Name mismatch: Member (Musa Dlamini) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:31:36', '2025-10-26 16:37:14'),
(2, 3, 'name_mismatch', 'Name mismatch: Member (Sibusiso Dlamini) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:41', '2025-10-27 02:30:03'),
(3, 4, 'name_mismatch', 'Name mismatch: Member (Nandi Shongwe) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:31:39', '2025-10-27 02:31:20'),
(4, 5, 'name_mismatch', 'Name mismatch: Member (Siphesihle Mamba) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:35', '2025-10-27 02:32:03'),
(5, 6, 'name_mismatch', 'Name mismatch: Member (Mfundo Shabangu) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:31:32', '2025-10-27 02:33:10'),
(6, 7, 'name_mismatch', 'Name mismatch: Member (Samkeliso Nxumalo) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:44', '2025-10-27 02:33:57'),
(7, 8, 'name_mismatch', 'Name mismatch: Member (Mthokozisi Simelane) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:31:34', '2025-10-27 02:34:30'),
(8, 9, 'name_mismatch', 'Name mismatch: Member (Phumelele Mabuza) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:47', '2025-10-27 02:34:57'),
(9, 10, 'name_mismatch', 'Name mismatch: Member (Bongani Nxumalo) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:31:28', '2025-10-27 02:35:29'),
(10, 11, 'name_mismatch', 'Name mismatch: Member (Sabelo Mthethwa) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:50', '2025-10-27 02:36:10'),
(11, 12, 'name_mismatch', 'Name mismatch: Member (Thokozani Shongwe) vs Training (undefined undefined)', NULL, NULL, 1, 'Manually verified by CDO', 18, '2025-10-28 11:34:37', '2025-10-27 02:36:46'),
(12, 13, 'name_mismatch', 'Name mismatch: Member (Thabo Mthethwa) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:04:30'),
(13, 14, 'name_mismatch', 'Name mismatch: Member (Ayanda Nkambule) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:05:08'),
(14, 15, 'name_mismatch', 'Name mismatch: Member (Sipho Shongwe) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:05:35'),
(15, 16, 'name_mismatch', 'Name mismatch: Member (Zanele Magagula) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:06:02'),
(16, 17, 'name_mismatch', 'Name mismatch: Member (Banele Nxumalo) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:06:23'),
(17, 18, 'name_mismatch', 'Name mismatch: Member (Phindile Dlamini) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:06:48'),
(18, 19, 'name_mismatch', 'Name mismatch: Member (Mandla Mamba) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:07:16'),
(19, 20, 'name_mismatch', 'Name mismatch: Member (Nokuthula Mhlanga) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:07:40'),
(20, 21, 'name_mismatch', 'Name mismatch: Member (Sandile Simelane) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:08:06'),
(21, 22, 'name_mismatch', 'Name mismatch: Member (Lindiwe Dlamini) vs Training (undefined undefined)', NULL, NULL, 0, NULL, NULL, NULL, '2025-10-28 14:08:44');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message_text` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `parent_message_id` int(11) DEFAULT NULL,
  `related_application_id` int(11) DEFAULT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otps`
--

CREATE TABLE `otps` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `purpose` enum('signature','verification','password_reset','login') NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `attempts` int(11) DEFAULT 0,
  `max_attempts` int(11) DEFAULT 3,
  `is_used` tinyint(1) DEFAULT 0,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `project_milestones`
--

CREATE TABLE `project_milestones` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `milestone_name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `target_date` date NOT NULL,
  `completion_date` date DEFAULT NULL,
  `status` enum('pending','in_progress','completed','delayed') DEFAULT 'pending',
  `budget_allocated` decimal(15,2) DEFAULT NULL,
  `budget_utilized` decimal(15,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `code` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `regions`
--

INSERT INTO `regions` (`id`, `name`, `code`, `created_at`) VALUES
(1, 'Hhohho', 'HHO', '2025-10-24 07:43:01'),
(2, 'Lubombo', 'LUB', '2025-10-24 07:43:01'),
(3, 'Manzini', 'MAN', '2025-10-24 07:43:01'),
(4, 'Shiselweni', 'SHI', '2025-10-24 07:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `site_visits`
--

CREATE TABLE `site_visits` (
  `id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `visit_date` date NOT NULL,
  `visitor_user_id` int(11) NOT NULL,
  `findings` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `photos` text DEFAULT NULL,
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sms_logs`
--

CREATE TABLE `sms_logs` (
  `id` int(11) NOT NULL,
  `recipient_phone` varchar(20) NOT NULL,
  `recipient_user_id` int(11) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('pending','sent','failed') DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tinkhundla`
--

CREATE TABLE `tinkhundla` (
  `id` int(11) NOT NULL,
  `region_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tinkhundla`
--

INSERT INTO `tinkhundla` (`id`, `region_id`, `name`, `code`, `created_at`) VALUES
(1, 1, 'Hhukwini', 'HHO_HHU', '2025-10-24 07:43:01'),
(2, 1, 'Lobamba', 'HHO_LOB', '2025-10-24 07:43:01'),
(3, 1, 'Madlangempisi', 'HHO_MAD', '2025-10-24 07:43:01'),
(4, 1, 'Maphalaleni', 'HHO_MAP', '2025-10-24 07:43:01'),
(5, 1, 'Mayiwane', 'HHO_MAY', '2025-10-24 07:43:01'),
(6, 1, 'Mbabane East', 'HHO_MBE', '2025-10-24 07:43:01'),
(7, 1, 'Mbabane West', 'HHO_MBW', '2025-10-24 07:43:01'),
(8, 1, 'Mhlangatane', 'HHO_MHL', '2025-10-24 07:43:01'),
(9, 1, 'Motshane', 'HHO_MOT', '2025-10-24 07:43:01'),
(10, 1, 'Ndzingeni', 'HHO_NDZ', '2025-10-24 07:43:01'),
(11, 1, 'Nkhaba', 'HHO_NKH', '2025-10-24 07:43:01'),
(12, 1, 'Ntfonjeni', 'HHO_NTF', '2025-10-24 07:43:01'),
(13, 1, 'Pigg\'s Peak', 'HHO_PIG', '2025-10-24 07:43:01'),
(14, 1, 'Siphocosini', 'HHO_SIP', '2025-10-24 07:43:01'),
(15, 1, 'Timphisini', 'HHO_TIM', '2025-10-24 07:43:01'),
(16, 2, 'Dvokodvweni', 'LUB_DVO', '2025-10-24 07:43:01'),
(17, 2, 'Gilgal', 'LUB_GIL', '2025-10-24 07:43:01'),
(18, 2, 'Lomahasha', 'LUB_LOM', '2025-10-24 07:43:01'),
(19, 2, 'Lubuli', 'LUB_LUB', '2025-10-24 07:43:01'),
(20, 2, 'Lugongolweni', 'LUB_LUG', '2025-10-24 07:43:01'),
(21, 2, 'Matsanjeni North', 'LUB_MTN', '2025-10-24 07:43:01'),
(22, 2, 'Mhlume', 'LUB_MHL', '2025-10-24 07:43:01'),
(23, 2, 'Mpolonjeni', 'LUB_MPO', '2025-10-24 07:43:01'),
(24, 2, 'Nkilongo', 'LUB_NKI', '2025-10-24 07:43:01'),
(25, 2, 'Siphofaneni', 'LUB_SIP', '2025-10-24 07:43:01'),
(26, 2, 'Sithobela', 'LUB_SIT', '2025-10-24 07:43:01'),
(27, 3, 'Kukhanyeni', 'MAN_KUK', '2025-10-24 07:43:01'),
(28, 3, 'Kwaluseni', 'MAN_KWA', '2025-10-24 07:43:01'),
(29, 3, 'Lamgabhi', 'MAN_LAM', '2025-10-24 07:43:01'),
(30, 3, 'Lobamba Lomdzala', 'MAN_LOB', '2025-10-24 07:43:01'),
(31, 3, 'Ludzeludze', 'MAN_LUD', '2025-10-24 07:43:01'),
(32, 3, 'Mafutseni', 'MAN_MAF', '2025-10-24 07:43:01'),
(33, 3, 'Mahlangatsha', 'MAN_MAH', '2025-10-24 07:43:01'),
(34, 3, 'Mangcongco', 'MAN_MAN', '2025-10-24 07:43:01'),
(35, 3, 'Manzini North', 'MAN_MNO', '2025-10-24 07:43:01'),
(36, 3, 'Manzini South', 'MAN_MSO', '2025-10-24 07:43:01'),
(37, 3, 'Mhlambanyatsi', 'MAN_MHL', '2025-10-24 07:43:01'),
(38, 3, 'Mkhiweni', 'MAN_MKH', '2025-10-24 07:43:01'),
(39, 3, 'Mtfongwaneni', 'MAN_MTF', '2025-10-24 07:43:01'),
(40, 3, 'Ngwempisi', 'MAN_NGW', '2025-10-24 07:43:01'),
(41, 3, 'Nhlambeni', 'MAN_NHL', '2025-10-24 07:43:01'),
(42, 3, 'Nkomiyahlaba', 'MAN_NKO', '2025-10-24 07:43:01'),
(43, 3, 'Ntondozi', 'MAN_NTO', '2025-10-24 07:43:01'),
(44, 3, 'Phondo', 'MAN_PHO', '2025-10-24 07:43:01'),
(45, 4, 'Gege', 'SHI_GEG', '2025-10-24 07:43:01'),
(46, 4, 'Hosea', 'SHI_HOS', '2025-10-24 07:43:01'),
(47, 4, 'Kubuta', 'SHI_KUB', '2025-10-24 07:43:01'),
(48, 4, 'KuMethula', 'SHI_KUM', '2025-10-24 07:43:01'),
(49, 4, 'Maseyisini', 'SHI_MAS', '2025-10-24 07:43:01'),
(50, 4, 'Matsanjeni South', 'SHI_MTS', '2025-10-24 07:43:01'),
(51, 4, 'Mtsambama', 'SHI_MTB', '2025-10-24 07:43:01'),
(52, 4, 'Ngudzeni', 'SHI_NGU', '2025-10-24 07:43:01'),
(53, 4, 'Nkwene', 'SHI_NKW', '2025-10-24 07:43:01'),
(54, 4, 'Sandleni', 'SHI_SAN', '2025-10-24 07:43:01'),
(55, 4, 'Shiselweni 1', 'SHI_SH1', '2025-10-24 07:43:01'),
(56, 4, 'Shiselweni 2', 'SHI_SH2', '2025-10-24 07:43:01'),
(57, 4, 'Sigwe', 'SHI_SIG', '2025-10-24 07:43:01'),
(58, 4, 'Somntongo', 'SHI_SOM', '2025-10-24 07:43:01'),
(59, 4, 'Zombodze Emuva', 'SHI_ZOM', '2025-10-24 07:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `training_register`
--

CREATE TABLE `training_register` (
  `id` int(11) NOT NULL,
  `id_number` varchar(13) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `training_date` date NOT NULL,
  `training_type` varchar(100) DEFAULT NULL,
  `certificate_number` varchar(50) DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `training_register`
--

INSERT INTO `training_register` (`id`, `id_number`, `first_name`, `surname`, `gender`, `contact_number`, `region_id`, `training_date`, `training_type`, `certificate_number`, `verified_by`, `created_at`) VALUES
(1, '9001010000001', 'Sibusiso', 'Dlamini', 'Male', '26876000001', 1, '2025-01-15', 'ICT Fundamentals', 'CERT001', 1, '2025-10-27 02:29:20'),
(2, '9102020000002', 'Nomcebo', 'Simelane', 'Female', '26878000002', 2, '2025-02-10', 'Entrepreneurship', 'CERT002', 1, '2025-10-27 02:29:20'),
(3, '9203030000003', 'Thabo', 'Mthethwa', 'Male', '26879000003', 3, '2025-03-12', 'Financial Literacy', 'CERT003', 1, '2025-10-27 02:29:20'),
(4, '9304040000004', 'Ayanda', 'Nkambule', 'Female', '26876000004', 4, '2025-04-05', 'ICT Fundamentals', 'CERT004', 1, '2025-10-27 02:29:20'),
(5, '9405050000005', 'Sipho', 'Shongwe', 'Male', '26878000005', 1, '2025-04-20', 'Small Business', 'CERT005', 1, '2025-10-27 02:29:20'),
(6, '9506060000006', 'Zanele', 'Magagula', 'Female', '26879000006', 2, '2025-05-02', 'Entrepreneurship', 'CERT006', 1, '2025-10-27 02:29:20'),
(7, '9607070000007', 'Banele', 'Nxumalo', 'Male', '26876000007', 3, '2025-05-10', 'ICT Fundamentals', 'CERT007', 1, '2025-10-27 02:29:20'),
(8, '9708080000008', 'Phindile', 'Dlamini', 'Female', '26878000008', 4, '2025-05-22', 'Financial Literacy', 'CERT008', 1, '2025-10-27 02:29:20'),
(9, '9809090000009', 'Mandla', 'Mamba', 'Male', '26879000009', 1, '2025-06-01', 'Small Business', 'CERT009', 1, '2025-10-27 02:29:20'),
(10, '9901010000010', 'Nokuthula', 'Mhlanga', 'Female', '26876000010', 2, '2025-06-15', 'ICT Fundamentals', 'CERT010', 1, '2025-10-27 02:29:20'),
(11, '0002020000011', 'Sandile', 'Simelane', 'Male', '26878000011', 3, '2025-06-22', 'Entrepreneurship', 'CERT011', 1, '2025-10-27 02:29:20'),
(12, '0103030000012', 'Lindiwe', 'Dlamini', 'Female', '26879000012', 4, '2025-07-01', 'Financial Literacy', 'CERT012', 1, '2025-10-27 02:29:20'),
(13, '0204040000013', 'Sifiso', 'Mavimbela', 'Male', '26876000013', 1, '2025-07-05', 'ICT Fundamentals', 'CERT013', 1, '2025-10-27 02:29:20'),
(14, '0305050000014', 'Nontobeko', 'Hlophe', 'Female', '26878000014', 2, '2025-07-10', 'Entrepreneurship', 'CERT014', 1, '2025-10-27 02:29:20'),
(15, '0406060000015', 'Mfundo', 'Shabangu', 'Male', '26879000015', 3, '2025-07-15', 'Small Business', 'CERT015', 1, '2025-10-27 02:29:20'),
(16, '0507070000016', 'Fikile', 'Mabuza', 'Female', '26876000016', 4, '2025-07-20', 'ICT Fundamentals', 'CERT016', 1, '2025-10-27 02:29:20'),
(17, '0608080000017', 'Sanele', 'Dlamini', 'Male', '26878000017', 1, '2025-07-25', 'Financial Literacy', 'CERT017', 1, '2025-10-27 02:29:20'),
(18, '0709090000018', 'Gugu', 'Motsa', 'Female', '26879000018', 2, '2025-07-28', 'Small Business', 'CERT018', 1, '2025-10-27 02:29:20'),
(19, '0801010000019', 'Musa', 'Mhlongo', 'Male', '26876000019', 3, '2025-08-01', 'Entrepreneurship', 'CERT019', 1, '2025-10-27 02:29:20'),
(20, '0902020000020', 'Amanda', 'Gama', 'Female', '26878000020', 4, '2025-08-04', 'ICT Fundamentals', 'CERT020', 1, '2025-10-27 02:29:20'),
(21, '1003030000021', 'Sibongile', 'Nkambule', 'Female', '26879000021', 1, '2025-08-07', 'Entrepreneurship', 'CERT021', 1, '2025-10-27 02:29:20'),
(22, '1104040000022', 'Mduduzi', 'Dlamini', 'Male', '26876000022', 2, '2025-08-10', 'Financial Literacy', 'CERT022', 1, '2025-10-27 02:29:20'),
(23, '1205050000023', 'Nhlanhla', 'Motsa', 'Male', '26878000023', 3, '2025-08-12', 'ICT Fundamentals', 'CERT023', 1, '2025-10-27 02:29:20'),
(24, '1306060000024', 'Thandeka', 'Mamba', 'Female', '26879000024', 4, '2025-08-14', 'Small Business', 'CERT024', 1, '2025-10-27 02:29:20'),
(25, '1407070000025', 'Samkeliso', 'Nxumalo', 'Male', '26876000025', 1, '2025-08-16', 'Entrepreneurship', 'CERT025', 1, '2025-10-27 02:29:20'),
(26, '1508080000026', 'Zodwa', 'Dlamini', 'Female', '26878000026', 2, '2025-08-18', 'Financial Literacy', 'CERT026', 1, '2025-10-27 02:29:20'),
(27, '1609090000027', 'Mthokozisi', 'Simelane', 'Male', '26879000027', 3, '2025-08-20', 'ICT Fundamentals', 'CERT027', 1, '2025-10-27 02:29:20'),
(28, '1701010000028', 'Nokwazi', 'Mahlalela', 'Female', '26876000028', 4, '2025-08-22', 'Small Business', 'CERT028', 1, '2025-10-27 02:29:20'),
(29, '1802020000029', 'Themba', 'Magongo', 'Male', '26878000029', 1, '2025-08-24', 'Entrepreneurship', 'CERT029', 18, '2025-10-27 02:29:20'),
(30, '1903030000030', 'Phumelele', 'Mabuza', 'Female', '26879000030', 2, '2025-08-26', 'Financial Literacy', 'CERT030', 1, '2025-10-27 02:29:20'),
(31, '2004040000031', 'Vusi', 'Dlamini', 'Male', '26876000031', 3, '2025-08-28', 'ICT Fundamentals', 'CERT031', 1, '2025-10-27 02:29:20'),
(32, '2105050000032', 'Nosipho', 'Simelane', 'Female', '26878000032', 4, '2025-08-30', 'Entrepreneurship', 'CERT032', 1, '2025-10-27 02:29:20'),
(33, '2206060000033', 'Bongani', 'Nxumalo', 'Male', '26879000033', 1, '2025-09-01', 'Financial Literacy', 'CERT033', 1, '2025-10-27 02:29:20'),
(34, '2307070000034', 'Hlengiwe', 'Motsa', 'Female', '26876000034', 2, '2025-09-03', 'ICT Fundamentals', 'CERT034', 1, '2025-10-27 02:29:20'),
(35, '2408080000035', 'Mthunzi', 'Dlamini', 'Male', '26878000035', 3, '2025-09-05', 'Small Business', 'CERT035', 1, '2025-10-27 02:29:20'),
(36, '2509090000036', 'Zinhle', 'Mavuso', 'Female', '26879000036', 4, '2025-09-07', 'Entrepreneurship', 'CERT036', 1, '2025-10-27 02:29:20'),
(37, '2601010000037', 'Sabelo', 'Mthethwa', 'Male', '26876000037', 1, '2025-09-09', 'Financial Literacy', 'CERT037', 1, '2025-10-27 02:29:20'),
(38, '2702020000038', 'Nonhlanhla', 'Dlamini', 'Female', '26878000038', 2, '2025-09-11', 'ICT Fundamentals', 'CERT038', 1, '2025-10-27 02:29:20'),
(39, '2803030000039', 'Mduduzi', 'Mamba', 'Male', '26879000039', 3, '2025-09-13', 'Small Business', 'CERT039', 1, '2025-10-27 02:29:20'),
(40, '2904040000040', 'Gugu', 'Nkambule', 'Female', '26876000040', 4, '2025-09-15', 'Entrepreneurship', 'CERT040', 1, '2025-10-27 02:29:20'),
(41, '3005050000041', 'Thokozani', 'Shongwe', 'Male', '26878000041', 1, '2025-09-17', 'Financial Literacy', 'CERT041', 1, '2025-10-27 02:29:20'),
(42, '3106060000042', 'Nomvula', 'Dlamini', 'Female', '26879000042', 2, '2025-09-19', 'ICT Fundamentals', 'CERT042', 1, '2025-10-27 02:29:20'),
(43, '3207070000043', 'Siphesihle', 'Mamba', 'Male', '26876000043', 3, '2025-09-21', 'Small Business', 'CERT043', 1, '2025-10-27 02:29:20'),
(44, '3308080000044', 'Ncamsile', 'Nxumalo', 'Female', '26878000044', 4, '2025-09-23', 'Entrepreneurship', 'CERT044', 1, '2025-10-27 02:29:20'),
(45, '3409090000045', 'Lucky', 'Dlamini', 'Male', '26879000045', 1, '2025-09-25', 'Financial Literacy', 'CERT045', 1, '2025-10-27 02:29:20'),
(46, '3501010000046', 'Nobuhle', 'Motsa', 'Female', '26876000046', 2, '2025-09-27', 'ICT Fundamentals', 'CERT046', 1, '2025-10-27 02:29:20'),
(47, '3602020000047', 'Andile', 'Mahlalela', 'Male', '26878000047', 3, '2025-09-29', 'Small Business', 'CERT047', 1, '2025-10-27 02:29:20'),
(48, '3703030000048', 'Zama', 'Simelane', 'Female', '26879000048', 4, '2025-10-01', 'Entrepreneurship', 'CERT048', 1, '2025-10-27 02:29:20'),
(49, '3804040000049', 'Celani', 'Dlamini', 'Male', '26876000049', 1, '2025-10-03', 'Financial Literacy', 'CERT049', 1, '2025-10-27 02:29:20'),
(50, '3905050000050', 'Nandi', 'Shongwe', 'Female', '26878000050', 2, '2025-10-05', 'ICT Fundamentals', 'CERT050', 1, '2025-10-27 02:29:20');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('EOG','CDO','LINE_MINISTRY','MICROPROJECTS','CDC','INKHUNDLA_COUNCIL','RDFTC','RDFC','PS','SUPER_USER') NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `status` enum('active','inactive','suspended','temporary') DEFAULT 'active',
  `region_id` int(11) DEFAULT NULL,
  `tinkhundla_id` int(11) DEFAULT NULL,
  `umphakatsi_id` int(11) DEFAULT NULL,
  `ministry` varchar(100) DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `password_reset_token` varchar(255) DEFAULT NULL,
  `password_reset_expires` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `first_name`, `last_name`, `phone`, `status`, `region_id`, `tinkhundla_id`, `umphakatsi_id`, `ministry`, `last_login`, `password_reset_token`, `password_reset_expires`, `created_at`, `updated_at`, `user_id`) VALUES
(1, 'admin', 'admin@rdf.gov.sz', '$2b$12$B9N.Xon.UNL6Z1CmDe8/r.dWLhsbKSoRibvZuLxWoU7sWBE324/y.', 'SUPER_USER', 'Super  User', 'Administrator', '+26876000000', 'active', NULL, NULL, NULL, NULL, '2025-10-29 10:58:43', NULL, NULL, '2025-10-24 07:43:01', '2025-10-29 10:58:43', NULL),
(11, 'wandile', 'wakhiwakhi1@gmail.com', '$2b$12$CtgMosqQVIg7x515J2jb6ORD9n1M8F/KxvqxrBYn0hM4w4YqbXQSy', 'CDO', 'Wandile', 'Ngwenya', '76543212', 'active', 2, 24, 123, 'TINKHUNDLA', '2025-10-27 02:09:15', NULL, NULL, '2025-10-25 20:11:27', '2025-10-27 02:09:15', NULL),
(17, 'beehives', 'celimphilodlamini94@gmail.com', '$2b$12$rwMqQp1q0i4mYJH3HlkMYeniqSoecVksuFLeBaBnKCa8wCEP2VDYe', 'EOG', 'Timphisini Beehives', 'Cooperative', '79876543', 'active', 1, 15, 77, NULL, '2025-10-29 08:37:49', NULL, NULL, '2025-10-26 11:02:49', '2025-10-29 08:37:49', NULL),
(18, 'olwethu', 'wakhiwakhi1@outlook.com', '$2b$12$bXaXOndWnnX8cAESxCmp9OLkHBRfhkXpce14cv6.gZNFHsO8HR536', 'CDO', 'Olwethu', 'Dlamini', '+26878654321', 'active', 1, 15, 76, 'TINKHUNDLA', '2025-10-28 15:05:41', NULL, NULL, '2025-10-26 11:20:56', '2025-10-28 15:05:41', NULL),
(19, 'temp_20251028_9868', 'olwethudlamin10@gmail.com', '$2b$12$owdh2m1Khu.SO5HVm3h3J.uZND.clCGMZ9feB4AooiZUbX6mVLEX.', 'EOG', 'Inana Mainze Meal', 'Cooperative', '26878900987', 'temporary', 1, 1, 1, NULL, '2025-10-28 14:19:48', NULL, NULL, '2025-10-28 13:23:26', '2025-10-28 14:19:48', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_activity_logs`
--

CREATE TABLE `user_activity_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_activity_logs`
--

INSERT INTO `user_activity_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `description`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 'user_created', 'users', 3, NULL, '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 19:20:45'),
(2, 1, 'user_created', 'users', 4, NULL, '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 19:35:59'),
(3, 1, 'user_created', 'users', 5, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 19:42:28'),
(4, 1, 'user_created', 'users', 6, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 19:56:07'),
(5, 1, 'user_created', 'users', 8, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 19:58:32'),
(6, 1, 'user_created', 'users', 9, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:01:02'),
(7, 1, 'user_created', 'users', 10, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:03:24'),
(8, 1, 'user_created', 'users', 11, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:11:27'),
(9, 1, 'user_created', 'users', 12, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:45:30'),
(10, 1, 'user_created', 'users', 13, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:49:06'),
(11, 1, 'user_created', 'users', 14, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:51:59'),
(12, 1, 'user_created', 'users', 15, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 20:58:40'),
(13, 1, 'user_created', 'users', 16, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-25 21:20:22'),
(14, 1, 'user_created', 'users', 18, '{\"role\":\"CDO\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-26 11:20:56'),
(15, 17, 'application_created', 'applications', 1, 'Created new application with reference: RDF-2025-0001', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 21:37:11'),
(16, 17, 'form_responses_saved', 'applications', 1, 'Saved 0 form responses (0 permission errors, 4 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 22:06:02'),
(17, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 22:37:41'),
(18, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 22:42:12'),
(19, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 23:01:40'),
(20, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 23:17:51'),
(21, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-28 23:24:38'),
(22, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-29 00:01:51'),
(23, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-29 08:38:02');

-- --------------------------------------------------------

--
-- Table structure for table `user_notification_preferences`
--

CREATE TABLE `user_notification_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `email_notifications` tinyint(1) DEFAULT 1,
  `sms_notifications` tinyint(1) DEFAULT 0,
  `application_updates` tinyint(1) DEFAULT 1,
  `committee_reminders` tinyint(1) DEFAULT 1,
  `system_announcements` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_notification_preferences`
--

INSERT INTO `user_notification_preferences` (`id`, `user_id`, `email_notifications`, `sms_notifications`, `application_updates`, `committee_reminders`, `system_announcements`, `created_at`, `updated_at`) VALUES
(10, 11, 1, 0, 1, 1, 1, '2025-10-25 20:11:27', '2025-10-25 20:11:27'),
(16, 17, 1, 0, 1, 1, 1, '2025-10-26 11:02:49', '2025-10-26 11:02:49'),
(17, 18, 1, 0, 1, 1, 1, '2025-10-26 11:20:56', '2025-10-26 11:20:56'),
(18, 19, 1, 0, 1, 1, 1, '2025-10-28 13:23:26', '2025-10-28 13:23:26');

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `refresh_token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `refresh_token`, `ip_address`, `user_agent`, `is_active`, `expires_at`, `created_at`, `last_activity`) VALUES
(26, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDEzMTgxLCJleHAiOjE3NjE0MTQwODF9.1NZAUgjceQfoJehCAI9IlNLblA2NtpIl6Gy0d3KgHQw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxMjk3NywiZXhwIjoxNzYyMDE3Nzc3fQ.gaSUPUG3MRuxa6uG4W_8OUJOzxju-U1IsaOlBdQYhjA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-25 17:29:21', '2025-10-25 17:22:57', '2025-10-25 17:26:39'),
(27, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE0MjM0LCJleHAiOjE3NjE0MTUxMzR9.Mnmtfb5w5H8j-Lkj5zpjo0CNkpnMF94d9xN05aND9Rg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNDIzMCwiZXhwIjoxNzYyMDE5MDMwfQ.5CMe85mlKUvpoPBpfaa8qUQM5j8ZxccmN3RwMVuNIn8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 17:53:02', '2025-10-25 17:43:50', '2025-10-25 17:53:02'),
(28, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE0ODE4LCJleHAiOjE3NjE0MTU3MTh9.xP_jMqMZ-b4rXBoXPxMpYdC_03upaplpS-o0jfAbriY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNDgxMywiZXhwIjoxNzYyMDE5NjEzfQ.Jg0Xi2lV9pRqM282uEU_TYS-Z2AJhr7YdAIUXXU4Dkk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 17:54:01', '2025-10-25 17:53:33', '2025-10-25 17:54:01'),
(29, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE0OTY3LCJleHAiOjE3NjE0MTU4Njd9.vZdt2-z0Vj9xwWSMVx-BWVHtGDnXJCG1VyN276hJOvA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNDk2MywiZXhwIjoxNzYyMDE5NzYzfQ.4IwuUtAE_rovAFwkxnHtCS6rUwDF7tN88Qq951JxsyM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 17:56:13', '2025-10-25 17:56:03', '2025-10-25 17:56:13'),
(30, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE1MDMxLCJleHAiOjE3NjE0MTU5MzF9.UApfVJUf1PW9e8mM5zKJ_1oyj83Poo3EStTP0u5YIdo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNTAyNiwiZXhwIjoxNzYyMDE5ODI2fQ.f8Ia3Quy219EM7UjMMpzknnPhxDK8oj6Ta4raevGf4o', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 17:57:19', '2025-10-25 17:57:06', '2025-10-25 17:57:19'),
(31, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE1MTAzLCJleHAiOjE3NjE0MTYwMDN9.CqJsp1-ddX89GxqZzPhYpPcwOuBYHsXSAnjtwmwxkgE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNTEwMywiZXhwIjoxNzYyMDE5OTAzfQ.OOYwPrXXv8BlcwNrUCPfaj8laf0wR4a7zJamMZfivL4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 18:05:35', '2025-10-25 17:58:23', '2025-10-25 18:05:35'),
(32, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE2MTMzLCJleHAiOjE3NjE0MTcwMzN9.qsq3dt2_4CdXYuULtl6b_B_uIOsGa0F3YfRWD0oNAos', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNTU2OSwiZXhwIjoxNzYyMDIwMzY5fQ.iMDhqyETwC7OHYhbgYcMNzMqF6t0gXkXuo27XiQB39A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 18:19:38', '2025-10-25 18:06:09', '2025-10-25 18:19:38'),
(33, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDE5NjE0LCJleHAiOjE3NjE0MjA1MTR9.4AjH9CQsQe8bYDOkp0FNHDAhvc4xv6EJXNqM9pVbzww', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQxNjM4OSwiZXhwIjoxNzYyMDIxMTg5fQ.IIHpxe8GD_nrJdz6oEARFtnLzmoOTQxYA0WK8lFJz0Q', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-25 19:22:39', '2025-10-25 18:19:49', '2025-10-25 19:22:39'),
(34, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDIwOTAyLCJleHAiOjE3NjE0MjE4MDJ9.FYpAAJ0GsmBblkN7srHuwYzLpFlJaBfCLIQjTezeLW0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyMDkwMiwiZXhwIjoxNzYyMDI1NzAyfQ.aIwSkkh1trccJpNltpsc30UwLuCcWjTjO3ZIZmLIJ2w', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-25 19:42:28', '2025-10-25 19:35:02', '2025-10-25 19:42:28'),
(35, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDIyMTEzLCJleHAiOjE3NjE0MjMwMTN9.l7RqYr1hkh3RYvX1W9mlskr9omWj1Y7Q_SkBnBYgG4k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyMjExMywiZXhwIjoxNzYyMDI2OTEzfQ.SHC5XOkG5xMwsiw71iOCAegd6SgORFZTkIUbFxBJzT8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-25 20:03:23', '2025-10-25 19:55:13', '2025-10-25 20:03:23'),
(36, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDIzMDUyLCJleHAiOjE3NjE0MjM5NTJ9.2ecb6tn-fW_FIB7O8CcrRFaBDaEJ9NpaQEZVA5tzbAo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyMzA1MiwiZXhwIjoxNzYyMDI3ODUyfQ.0VZ04IENeb4q6HSB23Lt0TzVMf_t9KjQgdqW-I-e92Y', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:12:55', '2025-10-25 20:10:52', '2025-10-25 20:12:55'),
(37, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzMzOSwiZXhwIjoxNzYxNDI0MjM5fQ.rlh7dI6mIuhQGUPqMu0oMO7sDv-ReeEq5I-jkNHDT7k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjMxODcsImV4cCI6MTc2MjAyNzk4N30.NxYCw695j5QKXPqdoog9jTVBoF-B3nBCGXl8NU9C0mg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:16:07', '2025-10-25 20:13:07', '2025-10-25 20:16:07'),
(38, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzUzNSwiZXhwIjoxNzYxNDI0NDM1fQ.-uyTKCM9vcgkdKUZkrV0P1BK_rrept5_TUI_k07lFyA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjMzODEsImV4cCI6MTc2MjAyODE4MX0.AD8Eg1PjA2NnsG6RoGqvyhG4fU5tIIne2sbkYiWejBU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:19:13', '2025-10-25 20:16:21', '2025-10-25 20:19:13'),
(39, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzU2OSwiZXhwIjoxNzYxNDI0NDY5fQ.1g5HL1KuzJusuMerSyTIl6qniiK-uba3GvcQs8sum3E', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM1NjksImV4cCI6MTc2MjAyODM2OX0.rkE_Qr0tqpBiFE_gZrprbHbGR0apYM8sRcMaM2gF1f4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-01 20:19:29', '2025-10-25 20:19:29', '2025-10-25 20:19:29'),
(40, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzU4NywiZXhwIjoxNzYxNDI0NDg3fQ.IZ8o3kYtP8CpnwJa84RIOCoS_5FkdlluYjjdG4TFglQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM1NzgsImV4cCI6MTc2MjAyODM3OH0.Kwp6Uk0_lZT3B_m3KjfdUfrhyQa965lhM6CExurdQKo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:19:53', '2025-10-25 20:19:38', '2025-10-25 20:19:53'),
(41, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzYwMywiZXhwIjoxNzYxNDI0NTAzfQ.uhU_1kOFgAsaC1n9SwANh5PlZJv2jGdSS2e_fWiG9hE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM2MDMsImV4cCI6MTc2MjAyODQwM30.IKGvQt9KCVDb5ydO2knRo98AlVQDuUd8muea3-CFYdQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-01 20:20:03', '2025-10-25 20:20:03', '2025-10-25 20:20:03'),
(42, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzcyOCwiZXhwIjoxNzYxNDI0NjI4fQ.wd2jo000zr3TfVfJbaa9cGWwXX6fHj-u7XEEiXCcxXg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM3MjgsImV4cCI6MTc2MjAyODUyOH0.p0hzRowkGb5tdn5hc8FhFXzyzaK1yYwazPo5k36k8T0', '::1', 'PostmanRuntime/7.49.0', 1, '2025-11-01 20:22:08', '2025-10-25 20:22:08', '2025-10-25 20:22:08'),
(43, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzgxMCwiZXhwIjoxNzYxNDI0NzEwfQ.sKJwg9GrAdAs5ldL8as23Qs5WPQCT6YDoMX23H9XIR4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM4MTAsImV4cCI6MTc2MjAyODYxMH0.8F5aom_nCSZxJLdbbhH3ezIpqFewqkVPNpwMR_w_EUE', '::1', 'PostmanRuntime/7.49.0', 1, '2025-11-01 20:23:30', '2025-10-25 20:23:30', '2025-10-25 20:23:30'),
(44, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzgxNCwiZXhwIjoxNzYxNDI0NzE0fQ.2grntbrpfTM7bexkraCDHvlxFjwOQEYIekL7QFSe0kk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM4MTQsImV4cCI6MTc2MjAyODYxNH0.dKKXLND7CVMoLPA5QHP_3hOffXrXdg0fz_tmtUApeqo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:23:38', '2025-10-25 20:23:34', '2025-10-25 20:23:38'),
(45, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzgzMiwiZXhwIjoxNzYxNDI0NzMyfQ.EULz78D7gMxQiTVdMIsyz4n0LEH04yHye5EKOyP5C_8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM4MjUsImV4cCI6MTc2MjAyODYyNX0.Fog4LWNyhHmCeAjv4JqY-RrS2aYfmrwFCTrCc4sLt0A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 20:23:56', '2025-10-25 20:23:45', '2025-10-25 20:23:56'),
(46, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQyMzg0MiwiZXhwIjoxNzYxNDI0NzQyfQ.E2iPYe9843Q3d4nqlSrhJjeYmMvyt3wmUhWt2YbLjq8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0MjM4NDIsImV4cCI6MTc2MjAyODY0Mn0.BAXaV_hnbW0hXpUdtAORDOAgW_g2Hes_z5t7sqmGPP0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-01 20:24:02', '2025-10-25 20:24:02', '2025-10-25 20:24:02'),
(47, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDI1MDY4LCJleHAiOjE3NjE0MjU5Njh9.NO7i6_JDvIpF7pbwZNbDmXWA4Lxutvvmt3W_Kbjp5NU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyNTA2OCwiZXhwIjoxNzYyMDI5ODY4fQ.MNw30BK69x5rbxsyw1XohySWsH-urzN7yjhYbUwrjpk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-25 20:58:40', '2025-10-25 20:44:28', '2025-10-25 20:58:40'),
(48, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDI3MTc5LCJleHAiOjE3NjE0MjgwNzl9.jmaoBQKdbWwzphR9rUGgqCkKcNuOE0MYVLN1T0Ty2Qo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyNzE3OSwiZXhwIjoxNzYyMDMxOTc5fQ.Ca6_oxQ0ut2bboa_sz7-tFK0ydYt-VDsGgwE9jHa42A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 21:29:00', '2025-10-25 21:19:39', '2025-10-25 21:29:00'),
(49, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDI3NzU0LCJleHAiOjE3NjE0Mjg2NTR9.rreGiQ7U65wvobyBXLSD6JD60QQ8ZZdl3ZLk4jlXuKQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyNzc1NCwiZXhwIjoxNzYyMDMyNTU0fQ.XtI1UWDCZfIDP3htDwhDFMYn0BkxaQYbnIa_Tn4gwJU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 21:29:21', '2025-10-25 21:29:14', '2025-10-25 21:29:21'),
(50, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDMwNTA3LCJleHAiOjE3NjE0MzE0MDd9.DrduUKRw7UyaJODbfqhDBCjI8ccPvemAPKE-4tmrwps', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQyODM5MiwiZXhwIjoxNzYyMDMzMTkyfQ.TJ8iPkoqoXlvK1br9ue_nMKRV6fTWL6nKPBqRnf_CJE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 22:17:12', '2025-10-25 21:39:52', '2025-10-25 22:17:12'),
(52, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDMxMTE5LCJleHAiOjE3NjE0MzIwMTl9.fjlXCvFYxsnt0x-ikOrUg0JN_WQB7hLkpQCV5voKvaQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQzMTExOSwiZXhwIjoxNzYyMDM1OTE5fQ.-9jXpiAi7tEO95nSN1xo33AooaGs9QE6R5kHrwxFW4Y', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-25 22:26:32', '2025-10-25 22:25:19', '2025-10-25 22:26:32'),
(53, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0NzY3MjEsImV4cCI6MTc2MTQ3NzYyMX0.e1odEcLMUXtllMyZLixmg73aY81cmeiD2Je0G4O6rcU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0NzY3MjEsImV4cCI6MTc2MjA4MTUyMX0.DQAKwZvj1uIyAdyeBhBeKXrKYlpXR9MtHhFrwfig8fg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 11:05:21', '2025-10-26 11:05:21', '2025-10-26 11:05:21'),
(54, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTQ3NzI1MywiZXhwIjoxNzYxNDc4MTUzfQ.Jn5XDh1gJeFLh6l9bEfFF5j3An-bebi7lIeqa2sfOz8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0NzcyNTMsImV4cCI6MTc2MjA4MjA1M30.Vur1PG-8YM6J3UuG7lb9akKjxcYfvhbqTXJF4_Ue-K0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 11:14:43', '2025-10-26 11:14:13', '2025-10-26 11:14:43'),
(56, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDc3NTgzLCJleHAiOjE3NjE0Nzg0ODN9.dYqC_peXxiQHRgi7PMcYcKzI_X-_mclk_LVbTdbqd0I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ3NzU4MywiZXhwIjoxNzYyMDgyMzgzfQ.RH9yBSXQ9B_1hnm-8cUL0s4GNBH3ULNCG0MrFaZQJ8o', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 11:21:04', '2025-10-26 11:19:43', '2025-10-26 11:21:04'),
(57, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDc4MzY2LCJleHAiOjE3NjE0NzkyNjZ9.L3-Xv88C2lJC5is7DY9j_d7Fq5k_bDiVY91k05vgIhI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0Nzc2OTgsImV4cCI6MTc2MjA4MjQ5OH0.a9NKgicmiY9-Orsc8ztRucAxsEWJdla-A9y7eLdq2Vc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 11:32:47', '2025-10-26 11:21:38', '2025-10-26 11:32:47'),
(58, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDc4NjIxLCJleHAiOjE3NjE0Nzk1MjF9.ODJTy2BZDgUFabF5yJzxMEV1Um513S9_SK-jngRwPsQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0Nzg2MjEsImV4cCI6MTc2MjA4MzQyMX0.kNpqS774pr-nMUrSKjPTmkAytDyZiL0nT0_5DgQRHH8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 11:37:01', '2025-10-26 11:37:01', '2025-10-26 11:37:01'),
(59, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDc4NjMxLCJleHAiOjE3NjE0Nzk1MzF9.PKLxgsR9DwRsfvCZhug3DRZVy_A-tvB2ODixhCFJ7m8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0Nzg2MzEsImV4cCI6MTc2MjA4MzQzMX0.pQ9sgi35D6BIu7jr1_GJJ6sWuGHACdr_gkJapIQ_WD4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 11:37:11', '2025-10-26 11:37:11', '2025-10-26 11:37:11'),
(60, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDc5Nzk4LCJleHAiOjE3NjE0ODA2OTh9.GPydHTxTU46DCtMv8EX1CCh2dL6TEJO-xpt6WSMbUPw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0Nzk3OTgsImV4cCI6MTc2MjA4NDU5OH0.rtTpN6hgrR8-cuKmZs6vqeezNfmumVT1uhr5KRJnfQs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 11:56:38', '2025-10-26 11:56:38', '2025-10-26 11:56:38'),
(61, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDc5ODA3LCJleHAiOjE3NjE0ODA3MDd9.rjpKGSxRJHND_nn0IRVwovESJdLBXNfltqjjk3mUtHA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0Nzk4MDcsImV4cCI6MTc2MjA4NDYwN30.mBPnr61dK4RJHXDsgEyOb1K9MN7tinAfcr-jNSx7cv8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 11:56:47', '2025-10-26 11:56:47', '2025-10-26 11:56:47'),
(62, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDc5ODkyLCJleHAiOjE3NjE0ODA3OTJ9.vOArk8-U_TdZsYvbp4vCjF12IknZJ9o91HOnmCMJs7s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ3OTg3OCwiZXhwIjoxNzYyMDg0Njc4fQ.u5epaKUDc8ymEo9660fbrZdiShmB_vpSIyZF7msLdvY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 11:58:12', '2025-10-26 11:57:58', '2025-10-26 11:58:12'),
(63, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwMDk4LCJleHAiOjE3NjE0ODA5OTh9.u7XUcoAoGlyyWZ0VJKHdQAA4D89fxUBC8mNQCzyed7s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ3OTkwOCwiZXhwIjoxNzYyMDg0NzA4fQ.KFVWGm1wj6F_AW2zwidq7bZiltHHsZ7wnSB6l8rQIbE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 12:01:38', '2025-10-26 11:58:28', '2025-10-26 12:01:38'),
(64, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwMjA3LCJleHAiOjE3NjE0ODExMDd9.cnyFsvbWQLghY6SMsHuC2mNA8bKMDeDFCun-Sdqmbyw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDEwOCwiZXhwIjoxNzYyMDg0OTA4fQ.JCfAs1lhI-vGC-4begYQ6hjfpkgBjlaEag5QA6fDmbM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:03:38', '2025-10-26 12:01:48', '2025-10-26 12:03:38'),
(65, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwMjcyLCJleHAiOjE3NjE0ODExNzJ9.ZsrZ-eMp7xqbHlgypGj00ynBtuzuHAuaDLqOB5wegQ0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDIyOSwiZXhwIjoxNzYyMDg1MDI5fQ.CCdOh9aHV52PoHuYWw-xJ_bxlRJ1d5BgAfqo25mMYME', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:04:38', '2025-10-26 12:03:49', '2025-10-26 12:04:38'),
(66, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwMjkzLCJleHAiOjE3NjE0ODExOTN9.NbnqhrLL-0JeDZxg30SelRztpER7Ps-ZH2mW7TJwKeI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDI5MywiZXhwIjoxNzYyMDg1MDkzfQ.dewNc-JWd0u123ephjIDJEvuJ52IglKGGdJZh8Cdn4k', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 12:04:53', '2025-10-26 12:04:53', '2025-10-26 12:04:53'),
(67, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwMzM5LCJleHAiOjE3NjE0ODEyMzl9.6Aee7_rNBnCU-lXYjUMJUBFEawP_AC05WU78DmxEJwM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDMxMCwiZXhwIjoxNzYyMDg1MTEwfQ.viH0R8oT19xNjd1gy9rdJbSor3Lp1ro0yJEsUAoVyQw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:05:55', '2025-10-26 12:05:10', '2025-10-26 12:05:55'),
(68, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwNDg2LCJleHAiOjE3NjE0ODEzODZ9.A1StV6MOwmuRUBN0BRQv8wyGszGGL4aIedM_GvxwEBY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDQ4NywiZXhwIjoxNzYyMDg1Mjg3fQ.ZQOJWA0QNrFZAEA_9UGcHGrmK7hB5sEHeblF72PbSss', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 12:08:07', '2025-10-26 12:08:07', '2025-10-26 12:08:07'),
(69, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDgwNzcyLCJleHAiOjE3NjE0ODE2NzJ9.HlXhuLiIJyy2PjREvSBSSK6mABYk8TkH5QvG_t4nlbU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODA3NzIsImV4cCI6MTc2MjA4NTU3Mn0.5xi1McRqjXIRn8AAayemqri_p9opVZJL99itWiu8uYc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:13:14', '2025-10-26 12:12:52', '2025-10-26 12:13:14'),
(70, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDgwODA4LCJleHAiOjE3NjE0ODE3MDh9.qpXT2UYiiVy_W6Kx2zeX_bKCuX8dnlYnMvunjJ8XVeE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODA4MDgsImV4cCI6MTc2MjA4NTYwOH0.OtB6AZFGBzpsuLpIUSL7YEJKljrtOUXZXVJ4lcR-6Rw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:14:00', '2025-10-26 12:13:28', '2025-10-26 12:14:00'),
(71, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDgwODUzLCJleHAiOjE3NjE0ODE3NTN9.Bkzo-z5qYGT6qBekDa6h3ldpnbACuyL1srx1MsRbEfI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4MDg1MywiZXhwIjoxNzYyMDg1NjUzfQ.OaipdGQDyoSuxomuBJd3bJqCdDmxGLeJdU0uPE9Usgg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 12:26:30', '2025-10-26 12:14:13', '2025-10-26 12:26:30'),
(72, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDgxNjE3LCJleHAiOjE3NjE0ODI1MTd9.XyZI55E0ZsnDjoClJyB47d0nsfTbUn6BRKWDIiCrH-Y', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODE2MTcsImV4cCI6MTc2MjA4NjQxN30.vkXH86PvuRFXJtOdye2crQGwrTzo4ch7nGE01L_SWVg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 12:26:58', '2025-10-26 12:26:57', '2025-10-26 12:26:58'),
(73, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODMzNzEsImV4cCI6MTc2MTQ4NDI3MX0.2pi_wcSIg0R3xrrpgR951wCFGLtSsW01rr6ov1vqCyU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODMzNzEsImV4cCI6MTc2MjA4ODE3MX0.3PWsCwhqpE3hi1h1lGP9WonqANY-50Mt7Ey5PR0ffNs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 12:56:11', '2025-10-26 12:56:11', '2025-10-26 12:56:11'),
(74, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODQwMDksImV4cCI6MTc2MTQ4NDkwOX0.4q7wIBz0SZl-lReTOnlSx3HLNBe-ENO6YVttpRFc1BY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODQwMDksImV4cCI6MTc2MjA4ODgwOX0.dGSa8r6ix5So3eUmtlvnM7PbXDcsISBO0-upLB_W2Jk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:06:49', '2025-10-26 13:06:49', '2025-10-26 13:06:49'),
(75, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODQ0NzksImV4cCI6MTc2MTQ4NTM3OX0.GSfbzgzluOTAMfPrXI26_UOtON7i8DnjTKHc2ERLnM8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODQ0NzksImV4cCI6MTc2MjA4OTI3OX0.3MEvgwORSe8d6zWgh9CDZok1aiSU5d9daxGVHMzq334', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:14:39', '2025-10-26 13:14:39', '2025-10-26 13:14:39'),
(76, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODUyNzAsImV4cCI6MTc2MTQ4NjE3MH0.dRhEkyqS19sfw9UHloRVNylcLnmWEPVs64HowHjM4Q4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODUyNzAsImV4cCI6MTc2MjA5MDA3MH0.e0D06DSLL0rHVeGQMy5NcE1wZTmdpqQ-uWlDrlA5NgQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:27:50', '2025-10-26 13:27:50', '2025-10-26 13:27:50'),
(77, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODU0NjcsImV4cCI6MTc2MTQ4NjM2N30.KNBM4PbooDi1Ip2GiMI5Mh7gCrjL4Yk7otsyZAhJ6Co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODU0NjcsImV4cCI6MTc2MjA5MDI2N30.WzDelHg3HqbMbmnxDxCMx15F95jBojclulTqhG4Fbbg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:31:07', '2025-10-26 13:31:07', '2025-10-26 13:31:07'),
(78, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODU3NjEsImV4cCI6MTc2MTQ4NjY2MX0.wCAPY766RSF3kPSewhSfzNLnLfIik9l755Jb-_munQM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODU3NjEsImV4cCI6MTc2MjA5MDU2MX0.E7fekbHgyKodITKVpbEaODqnylssNau5Pj0w2gQODBQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:36:01', '2025-10-26 13:36:01', '2025-10-26 13:36:01'),
(79, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODY1OTksImV4cCI6MTc2MTQ4NzQ5OX0.n3tWvn5HQ3UgHbnyuQU8xewkQfWzj_3MLJWfUWfMB_U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODY1OTksImV4cCI6MTc2MjA5MTM5OX0.oF4Td-V65f_wvctvshfAcDtzhkmyAfZav3RCEsDJlLg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:49:59', '2025-10-26 13:49:59', '2025-10-26 13:49:59'),
(80, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODY2MjYsImV4cCI6MTc2MTQ4NzUyNn0.yCyDbcMP7EuFyCgiuYajk5pBc9sXOeRhW0AVbaNSjYg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODY2MjYsImV4cCI6MTc2MjA5MTQyNn0.Qq2FTGrItez4V7xrYRxrBT7Q39_TYbkrVu2nr0UyoLM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:50:26', '2025-10-26 13:50:26', '2025-10-26 13:50:26'),
(81, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNDg2NzkxLCJleHAiOjE3NjE0ODc2OTF9.rfVwvIFZcZfElqBL0EbUPj-8tQUN0GYNmWStf7prWEg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTQ4Njc5MSwiZXhwIjoxNzYyMDkxNTkxfQ.OFGLa_bzt_KJFcMNLTCGrlSdzegG_AMDp0q6QAJNqZo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 13:54:21', '2025-10-26 13:53:11', '2025-10-26 13:54:21'),
(82, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODY5NzIsImV4cCI6MTc2MTQ4Nzg3Mn0.jhSPdy1lhymBP929yd5cxbcDH3VTv6ntHcDdcyTA36Y', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODY5NzIsImV4cCI6MTc2MjA5MTc3Mn0.nWEzX0QpSmOU15juZTvpV6gtqLmaBOt6oCEDpFHH1fk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 13:56:12', '2025-10-26 13:56:12', '2025-10-26 13:56:12'),
(83, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODczMTQsImV4cCI6MTc2MTQ4ODIxNH0.ZKFrMIThFenkkNRV-aauj7K3rNaW6rMHFTL3MgmyqJo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODczMTQsImV4cCI6MTc2MjA5MjExNH0.7yowOJrZHuq09_2oXpRKOZILzHyrti0-6W_X4ToxCcY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:01:54', '2025-10-26 14:01:54', '2025-10-26 14:01:54'),
(84, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODc4NDUsImV4cCI6MTc2MTQ4ODc0NX0.dtAvfpWRhtpmpT2kLC9o3u1itEe6ZYGpmHCrw_e_q4c', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODc4NDUsImV4cCI6MTc2MjA5MjY0NX0.m8nNxQSmfJ6fhqXYevWi4GfhqXLOu5_0TJbKXsULq5s', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:10:45', '2025-10-26 14:10:45', '2025-10-26 14:10:45'),
(85, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODc5OTEsImV4cCI6MTc2MTQ4ODg5MX0.pX0v1RHBzuCo_lomuxFuTvJOV1nfUjYVXacBJhBLa4I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODc5OTEsImV4cCI6MTc2MjA5Mjc5MX0.yFYZzQGrwbsOnn4MDvNZBoIdHB16xeP2f-jf5pqREUU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:13:11', '2025-10-26 14:13:11', '2025-10-26 14:13:11'),
(86, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODgwMjcsImV4cCI6MTc2MTQ4ODkyN30.gWYLk8p9LI2RZylPPjVNpVXRaPvc_AGR-cL26uO6dxs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODgwMjcsImV4cCI6MTc2MjA5MjgyN30.hl3kZ2cPz9gb1626oP0X7wLCSnXLeWMbjv_9Z1ZqkiE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:13:47', '2025-10-26 14:13:47', '2025-10-26 14:13:47'),
(87, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODgwMzIsImV4cCI6MTc2MTQ4ODkzMn0.SgPIZqVvH1GIaZC3jdZs-JqIsW-ULaZTUyIHzF01Zhc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODgwMzIsImV4cCI6MTc2MjA5MjgzMn0.uknVZjiFRK0BW4wp5eIXQRAKgyJHQlhYGwI2h9Ri4gs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:13:52', '2025-10-26 14:13:52', '2025-10-26 14:13:52'),
(88, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODgxMTAsImV4cCI6MTc2MTQ4OTAxMH0.EjLa62DMYYmhOcWxa64iAijHV-Z3GMsBTo9_snb5BW4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODgxMTAsImV4cCI6MTc2MjA5MjkxMH0.xL1o1Srz3kYXCANMBnd-yPhUB5uksGYI0QAzhgXOj0g', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:15:10', '2025-10-26 14:15:10', '2025-10-26 14:15:10'),
(89, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0ODgzMDIsImV4cCI6MTc2MTQ4OTIwMn0.iK5u1Wlel3X9XRTvNtypAoQTU2CvftmG-aPLqiKaQv0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0ODgzMDIsImV4cCI6MTc2MjA5MzEwMn0.lfZktpU65n2EDTD5BenlJrLeBDBk0ZSrCBuJuOli1uk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 14:18:22', '2025-10-26 14:18:22', '2025-10-26 14:18:22'),
(90, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTI2MDYsImV4cCI6MTc2MTQ5MzUwNn0.ZAY2bDCEDrm9ZcQegZIprPGPKZ3giH0pKwS8i9CBcaU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTI2MDYsImV4cCI6MTc2MjA5NzQwNn0.2n3XX24369LBFu1daBJOW_Wtwz5J-tOqKtJFlGslor8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:30:06', '2025-10-26 15:30:06', '2025-10-26 15:30:06'),
(91, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTI5MzEsImV4cCI6MTc2MTQ5MzgzMX0.v3jBdWnzKRxcH_AVxFuqivogqrIzg567pn9vhn-6IAY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTI5MzEsImV4cCI6MTc2MjA5NzczMX0.Cjw-n2rQuPtYLXbD3NtcUNQFB26bgEFJqH0ykB-FYPs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:35:31', '2025-10-26 15:35:31', '2025-10-26 15:35:31'),
(92, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDkzMjAxLCJleHAiOjE3NjE0OTQxMDF9.S2HTGM5sGukPJ7Lu5-FQojcyD1q8GETkdIKR7u8_1GI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTMyMDEsImV4cCI6MTc2MjA5ODAwMX0.KUo9BDNVq139EaS4dKxf_4Jat4mtL8yZucruH6r3R7M', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 15:45:25', '2025-10-26 15:40:01', '2025-10-26 15:45:25'),
(93, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTM1NTAsImV4cCI6MTc2MTQ5NDQ1MH0.P91v7SaxXKTyV4wpP1DdRN8LwesYrbMZXu7v-i0mnsY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTM1NTAsImV4cCI6MTc2MjA5ODM1MH0.kjKavHw3KDXuCcdjcOIlFiFljrCub24aX_-fbQRg7UM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:45:50', '2025-10-26 15:45:50', '2025-10-26 15:45:50'),
(94, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTM2NjUsImV4cCI6MTc2MTQ5NDU2NX0.4BVaqrOZBWFG9QMQdNCMz3_fP18LczBJOqWiLxM0YCg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTM2NjUsImV4cCI6MTc2MjA5ODQ2NX0.SmfL3VbWLFI6e2ffBYMGUyubAioD_tVkCv0nGJPKA3U', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:47:45', '2025-10-26 15:47:45', '2025-10-26 15:47:45'),
(95, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTM2NzMsImV4cCI6MTc2MTQ5NDU3M30.8PtEyuFbJMsHbJ6x-fawEz2DU_EGL6l1QF4yzGJhF0s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTM2NzMsImV4cCI6MTc2MjA5ODQ3M30.mml5JHJTyne9BIOrjlGfuYO3PHYYtBvHmfL2sMx1wXA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:47:53', '2025-10-26 15:47:53', '2025-10-26 15:47:53'),
(96, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTM4NzYsImV4cCI6MTc2MTQ5NDc3Nn0.CGBacSA4FWJ-U0QZx5gbZmSLqTNlF5ZTCXghW2J8dPg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTM4NzYsImV4cCI6MTc2MjA5ODY3Nn0.ZEccSXgf8zYFRnGjNGlKoflao8j1XO7DfBtYnnLKwX8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-02 15:51:16', '2025-10-26 15:51:16', '2025-10-26 15:51:16'),
(97, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTQxNDIsImV4cCI6MTc2MTQ5NTA0Mn0.OYmzPp235tIChPZcqizJ0ICYjLrFjsVrub8lbFm8H1I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTQxNDIsImV4cCI6MTc2MjA5ODk0Mn0.xsD98mE9Mrr8Tci0MKmSQjtSdZ8FVgIlcnYZD6zK72Y', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 16:07:50', '2025-10-26 15:55:42', '2025-10-26 16:07:50'),
(98, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTQ4OTEsImV4cCI6MTc2MTQ5NTc5MX0.6UrSYCok31z1nRpDXpp4NYSqVxuF3LC5d22-ndn1jIk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTQ4OTEsImV4cCI6MTc2MjA5OTY5MX0.9X0b-PU1g1WugPMEDPOHArBZivx9Xc0fydAaqIdAWlk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 16:08:30', '2025-10-26 16:08:11', '2025-10-26 16:08:30'),
(99, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDk1MjA5LCJleHAiOjE3NjE0OTYxMDl9.QdcwleBA78P3xrUbYSYdmLN31GuTJvfAJWKjIHU093g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTUyMDksImV4cCI6MTc2MjEwMDAwOX0.OiqIdEBfOGaxIEhxeewsdyUFB4W--XZFqlF_KczxYwk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 16:23:56', '2025-10-26 16:13:29', '2025-10-26 16:23:56'),
(100, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTU4NTMsImV4cCI6MTc2MTQ5Njc1M30.c6UWE-ysuQHHTeFTrhftiZosUu5dEmNAzv08696HIY4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTU4NTMsImV4cCI6MTc2MjEwMDY1M30.Z7IzrlFfRhwwy4IHFX9mEvTLyy9WCYSjCB-wP8zzYCU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 16:25:33', '2025-10-26 16:24:13', '2025-10-26 16:25:33'),
(101, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTU5NDYsImV4cCI6MTc2MTQ5Njg0Nn0.12lnWN1wShWQPsGjcfl0Owp9Dv4H2O3zuIO1XotLnec', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTU5NDYsImV4cCI6MTc2MjEwMDc0Nn0.-2ASxM_dNERiCOmB2ldGeUg2f8tfRm9Ux0Xml-sR_Zg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 16:40:09', '2025-10-26 16:25:46', '2025-10-26 16:40:09'),
(102, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTY5ODcsImV4cCI6MTc2MTQ5Nzg4N30.LGRj6FpPZSgcHBGtYpRFkMRMDkOMJZFxTUOMwLWCCE0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTY5ODcsImV4cCI6MTc2MjEwMTc4N30.h4kAhHD90pN4LJ1MKaO052L24M05aOGHIEjiHGJgbMo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 16:49:37', '2025-10-26 16:43:07', '2025-10-26 16:49:37'),
(103, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTc4MjksImV4cCI6MTc2MTQ5ODcyOX0.-kBJGlgtSzyl1isx0c1BM-hQv4nVu63FsuaTVNxHg_4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTc4MjksImV4cCI6MTc2MjEwMjYyOX0.UcIDgEcCDtDXANy3TidANsichpvUSg2UHPMZbxzJiU8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 17:00:00', '2025-10-26 16:57:09', '2025-10-26 17:00:00'),
(104, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTgwMTIsImV4cCI6MTc2MTQ5ODkxMn0.HEAe906S1lJQ2fX6LFxKAyZ9_kFnaSDiIMY4vdVEHUI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTgwMTIsImV4cCI6MTc2MjEwMjgxMn0.aOFh4rGSxjRK4I-jkZOpM3uasHaPBx_GDKkM1q1uY7g', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 17:00:59', '2025-10-26 17:00:12', '2025-10-26 17:00:59'),
(105, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNDk4MDY4LCJleHAiOjE3NjE0OTg5Njh9.49sb7dOkR3QQ_6ysDpuZCldOaYV-E-2lkxJpCjQzWyc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTgwNjgsImV4cCI6MTc2MjEwMjg2OH0.RbanH3M4L6CLt43Eb46qK9AyAQm8xjGHgEfyWVvwwdk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 17:03:51', '2025-10-26 17:01:08', '2025-10-26 17:03:51'),
(106, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTgyNDMsImV4cCI6MTc2MTQ5OTE0M30.C-wiFaJHdWn4-SJ8da9HeZ8MjF3-lJIaC3z0a0bfguE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTgyNDMsImV4cCI6MTc2MjEwMzA0M30.kJ8wxsizP5xHGXSk0JjOf_ISreq449XYBDWGUT_NvHQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 17:16:41', '2025-10-26 17:04:03', '2025-10-26 17:16:41'),
(107, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE0OTkzMzIsImV4cCI6MTc2MTUwMDIzMn0.eQ2lsz4msPVT-nBUM703YJMh_QKCGsAjYTJ7wF6Yf-U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE0OTkzMzIsImV4cCI6MTc2MjEwNDEzMn0.djeA5U3OnXnWSDZ4Bq1RcJ3IpwWAO5Ul40TIG4fUJwo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 17:25:23', '2025-10-26 17:22:12', '2025-10-26 17:25:23'),
(108, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE1MDAzNjYsImV4cCI6MTc2MTUwMTI2Nn0.ymhDWvcXzdLL6E5PUItQ0-sngi-BCfF3rjTYHgr--qQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MDAzNjYsImV4cCI6MTc2MjEwNTE2Nn0.36NPkVHSX0VllhXrbGJPQI1paafTi64lc-BzNONGJBo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 17:42:03', '2025-10-26 17:39:26', '2025-10-26 17:42:03'),
(109, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE1MDI1MzcsImV4cCI6MTc2MTUwMzQzN30.izwB9cUZdVLJTo_-cXQ8w_fTLXyS5OcDFZ0f_lhmRhI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MDI1MzcsImV4cCI6MTc2MjEwNzMzN30.4FbhafOyBfyA3iqqsdkk4m7whGoiK4nPcO-jOplKKWA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 18:23:40', '2025-10-26 18:15:37', '2025-10-26 18:23:40'),
(110, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTA2NTIxLCJleHAiOjE3NjE1MDc0MjF9.UGBqAQ6gn9Lwb9GM1j54lFuFq1FCCyKexex-lIucNQU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MDY1MjEsImV4cCI6MTc2MjExMTMyMX0.IgpwruanlY6jn5bZHmzsc6fXN2vm1J0kDJfzidPtu3A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 19:22:02', '2025-10-26 19:22:01', '2025-10-26 19:22:02'),
(111, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTA4NDEzLCJleHAiOjE3NjE1MDkzMTN9.Mk6szNfzl7-HViD1PMxV6vC-xmhPtzoq8OcqUinf46o', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUwODQxMywiZXhwIjoxNzYyMTEzMjEzfQ.fGhih6fPEoNX1aihDQ-46PV1gyF3tmNdZXFlj8cT1TE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 19:55:29', '2025-10-26 19:53:33', '2025-10-26 19:55:29'),
(112, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTA4NTM5LCJleHAiOjE3NjE1MDk0Mzl9.7WonXfnOf0vhNCyyQ6t-mPJbgFB7zPFMdhRW5LbT6KY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MDg1MzksImV4cCI6MTc2MjExMzMzOX0.LNkbgAZY7_-WVZcFyMxuMWlIi8gPz3x6l5nvZ86ah08', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 20:04:27', '2025-10-26 19:55:39', '2025-10-26 20:04:27'),
(113, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTEyMDMzLCJleHAiOjE3NjE1MTI5MzN9.JdIg2-VgmIH6-EXn_8S23-a1m9dIUmDd1cliSkcE7E0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MTIwMzQsImV4cCI6MTc2MjExNjgzNH0.F_EBkfjdsSwM-YPD8EJFv82BvN2tXZIgqCaVyBc-gH8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 20:54:43', '2025-10-26 20:53:54', '2025-10-26 20:54:43'),
(114, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTEyMDk0LCJleHAiOjE3NjE1MTI5OTR9.eZvzxfaJEQVKTwHBloHu4zl8XkzBpTvsdUFOxy14Hq8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUxMjA5NCwiZXhwIjoxNzYyMTE2ODk0fQ.1jBqGOgFzM2vkvyfuZ7F3P-89TcNGQp2739iYZ2fWu4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 20:56:08', '2025-10-26 20:54:54', '2025-10-26 20:56:08'),
(115, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTEzMzUxLCJleHAiOjE3NjE1MTQyNTF9.cYJvthOlIWnkCQgB4zLvPDWGBE8ZQ-VCjD6m7Jo28qA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MTMzNTEsImV4cCI6MTc2MjExODE1MX0.JwJpFj3A-nOpAnNU4cWLE89C4S9lGqKnr0iNpcOv0Mo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-26 21:18:46', '2025-10-26 21:15:51', '2025-10-26 21:18:46'),
(116, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTEzNTM1LCJleHAiOjE3NjE1MTQ0MzV9.Q5MZGG1Elvz_4-PEGPu8qLWRHvdvN4DlX2UWNZfSmCM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUxMzUzNSwiZXhwIjoxNzYyMTE4MzM1fQ.8L9QpdIvZXvBrIOEFzigbi_J3eYpsSvG6dluGNCIQzs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 21:33:04', '2025-10-26 21:18:55', '2025-10-26 21:33:04'),
(117, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTE0NDU3LCJleHAiOjE3NjE1MTUzNTd9.K3UAX9sXvdyBZLntxCxSnqvOGFcRMmATTP5i8d4lwwQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUxNDQ1NywiZXhwIjoxNzYyMTE5MjU3fQ.S7HDXZXrZ3sZQCK7NDf-3Ba_e-RXnzal8vc-ZWHeEds', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 21:46:15', '2025-10-26 21:34:17', '2025-10-26 21:46:15'),
(118, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTE2MDE2LCJleHAiOjE3NjE1MTY5MTZ9.fU8KtaA2VspYRf50arSzjJo-j5x7AwWK6r9K7dbt4_U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUxNjAxNiwiZXhwIjoxNzYyMTIwODE2fQ.pVmpDWDLVQ36HEKEQl-VWS8-AVXP8u93SwKB8FpLpzI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 22:14:52', '2025-10-26 22:00:16', '2025-10-26 22:14:52'),
(119, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTIxMjAyLCJleHAiOjE3NjE1MjIxMDJ9.32PVWyJuJybhtmdvfsWhtiyRhxEu8AYEDfUG37fJV6g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUyMTIwMiwiZXhwIjoxNzYyMTI2MDAyfQ.HN0-KtUq_h9020uXSaYF0g-LHVMyimZgFKu69mh1jOc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 23:38:13', '2025-10-26 23:26:42', '2025-10-26 23:38:13'),
(120, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTUyMjIwMSwiZXhwIjoxNzYxNTIzMTAxfQ.8sBhgdifnCU6_6koKSmlzlGNIJScmGlicmb6PGfpa88', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MjIyMDEsImV4cCI6MTc2MjEyNzAwMX0.LJ_0Qui1V0qKQFQE_pG1j8AKlcF6UUxU9W9-s_VW200', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-26 23:43:40', '2025-10-26 23:43:21', '2025-10-26 23:43:40');
INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `refresh_token`, `ip_address`, `user_agent`, `is_active`, `expires_at`, `created_at`, `last_activity`) VALUES
(121, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTIyNjEyLCJleHAiOjE3NjE1MjM1MTJ9.OB45w6Y_s-NdWGI8qLVUlg00I3tnTl2_em_Cujj-6PM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUyMjYxMiwiZXhwIjoxNzYyMTI3NDEyfQ.KYPlrMAe6WziACTunfYmgMfU1J8YK2xM15lMdtZIvoA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-26 23:59:26', '2025-10-26 23:50:12', '2025-10-26 23:59:26'),
(122, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTIzNTQ3LCJleHAiOjE3NjE1MjQ0NDd9.DE7sFVKmC8wDebsZSkW96vMIsd4MaCamVgDEpzSCnhw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUyMzU0NywiZXhwIjoxNzYyMTI4MzQ3fQ.61q0g083fiNsU8Ljz_NP4K86lRwYA3B95aICKRdyzSY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 00:07:01', '2025-10-27 00:05:47', '2025-10-27 00:07:01'),
(123, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTI4NTM4LCJleHAiOjE3NjE1Mjk0Mzh9.tvoemQf1oAM3_jhLdLngYLNnKDGCfFOg2o7mH43F-Jo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUyODUzOCwiZXhwIjoxNzYyMTMzMzM4fQ.-bVoWqcXyw2-9fZ36eMlMRfMIjcFBLdUT6cnAUX6-Bo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 01:29:16', '2025-10-27 01:28:58', '2025-10-27 01:29:16'),
(124, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTI5OTQzLCJleHAiOjE3NjE1MzA4NDN9.ScKzEkk9968sSw-6776usZBtXERoywQPbyeEEgexjx0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1Mjk5NDMsImV4cCI6MTc2MjEzNDc0M30.ii1JAasU_kaT_o4mV8AncYGjpFzmbpFdVKrYXTLKxOc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:06:02', '2025-10-27 01:52:23', '2025-10-27 02:06:02'),
(125, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMwNzcxLCJleHAiOjE3NjE1MzE2NzF9.43EdQ2N1MqKdNv0GDmnDQdDGOODAB6X9C2cGrI-X5JM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMDc3MSwiZXhwIjoxNzYyMTM1NTcxfQ.X8d9fScovoI8Y_e2fuT4JFWPfIDv5z6-GNVhu1zWYQo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 02:19:51', '2025-10-27 02:06:11', '2025-10-27 02:19:51'),
(126, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTUzMDk1NSwiZXhwIjoxNzYxNTMxODU1fQ.CXU0n4Ch8MCA2Yql2M0zqON1rCGoXXfCwWZ6t7Oe3wg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MzA5NTUsImV4cCI6MTc2MjEzNTc1NX0.hgpsA0sH_czznsT1KkqtveqpOUOU8d4hWV8xtC5nYhc', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-27 02:12:19', '2025-10-27 02:09:15', '2025-10-27 02:12:19'),
(127, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMxMTY1LCJleHAiOjE3NjE1MzIwNjV9.ZqBU9tBSEXncJrOkVm9mBoDYhhZCD2tRfZ45OfW_YU4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMTE2NSwiZXhwIjoxNzYyMTM1OTY1fQ.B8hcq3HqaKexMdoE8sSsOEE_5bBwj5GPynkWMwhFRwM', '::1', 'PostmanRuntime/7.49.0', 1, '2025-11-03 02:12:45', '2025-10-27 02:12:45', '2025-10-27 02:12:45'),
(128, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMxMTg3LCJleHAiOjE3NjE1MzIwODd9.d0Apbm0jcP23ciWnGQNmM7eh375n7nfCL8C5V737aE8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMTE4NywiZXhwIjoxNzYyMTM1OTg3fQ._S3cHKv0gRTstJONpIP_Amm7j6rAcOLT97lsZUbV5Hg', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-27 02:13:59', '2025-10-27 02:13:07', '2025-10-27 02:13:59'),
(129, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMxNDI1LCJleHAiOjE3NjE1MzIzMjV9.75_Vdv5JgZ-9cBLB5a2Gn5Tl1sJ3v6lb-62JWO8EEgY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMTQyNSwiZXhwIjoxNzYyMTM2MjI1fQ.YKyehYgTDLcfbQeKp39JS9bvDqqM3-mM0gpxco0sAls', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-27 02:17:25', '2025-10-27 02:17:05', '2025-10-27 02:17:25'),
(130, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMyMDQ0LCJleHAiOjE3NjE1MzI5NDR9.9-y5b86-HapQfhC4NI3yF6EpNVRgHh_rg1A826HLcXs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMjA0NCwiZXhwIjoxNzYyMTM2ODQ0fQ.uGovSh7JFvgyk-Y5er4c0FkIhWbQ-zG4w_6xeDd_GMA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:28:11', '2025-10-27 02:27:24', '2025-10-27 02:28:11'),
(131, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE1MzIxMzIsImV4cCI6MTc2MTUzMzAzMn0.6TgccLPgCjWrgYdmumbaF7lkqqaAUYq-AzpwGE1_S-0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MzIxMzIsImV4cCI6MTc2MjEzNjkzMn0.gZPbOPh9F__zorMo2nMUBVCNd-Gkt-Q3xFTcRmGYkdM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:37:36', '2025-10-27 02:28:52', '2025-10-27 02:37:36'),
(132, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE1MzI2NzgsImV4cCI6MTc2MTUzMzU3OH0.ttKlw9oZ-3jmtmz_2w1nFO5L5g-OAbKKYcqVKqL4eQE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MzI2NzgsImV4cCI6MTc2MjEzNzQ3OH0.9l03X31pdSLb9lY-B2Gs-J7zluit7CnIqDMUyz7bcw8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:38:25', '2025-10-27 02:37:58', '2025-10-27 02:38:25'),
(133, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNTMyNzE4LCJleHAiOjE3NjE1MzM2MTh9.SVdh97PbbFXBa1TpQ-wa_02fP1Zn0FMmlvlc-CwHt-g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MzI3MTgsImV4cCI6MTc2MjEzNzUxOH0.e0k2iCsug6Vy2e6hOxxir3pMiRJITb1m_akLIT22aYM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:41:19', '2025-10-27 02:38:38', '2025-10-27 02:41:19'),
(134, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE1MzI4OTMsImV4cCI6MTc2MTUzMzc5M30.imTWcFia8yu7OD0xtbgNsfUUoZJaRCm2rmIzJS58SRY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE1MzI4OTMsImV4cCI6MTc2MjEzNzY5M30.NRaA4wYFE75APaREGZRLwyb_Tqfp3evK31tW19feYck', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 02:43:41', '2025-10-27 02:41:33', '2025-10-27 02:43:41'),
(135, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTMzMDI5LCJleHAiOjE3NjE1MzM5Mjl9.eN5rt_5jhBleDWHesvbJnqSkEPk0eCrulpvh6Y-QngU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzMzAyOSwiZXhwIjoxNzYyMTM3ODI5fQ.0gOfXf-htHP-kdbMsoNmW17e9fs61RG_-WfBBk9NFgU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 02:45:07', '2025-10-27 02:43:49', '2025-10-27 02:45:07'),
(136, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTM0MDg2LCJleHAiOjE3NjE1MzQ5ODZ9.GS9zv1SMPZpKUxdf5mk00oA5pGROq43t8LLbhTIiiJA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzNDA4NiwiZXhwIjoxNzYyMTM4ODg2fQ.IauinQfTNF7_aKXca-z1KWqLQFuZqfstd-VP7OebqFI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 03:13:07', '2025-10-27 03:01:26', '2025-10-27 03:13:07'),
(137, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTM1NjQ0LCJleHAiOjE3NjE1MzY1NDR9.f-wy0J9HaSOyLURUk4zMJU2EV5ZKIBeMilLyYzljpjE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTUzNTY0NCwiZXhwIjoxNzYyMTQwNDQ0fQ.6ochkR5FW0AflxlLrJorl4lq9uemDLWNhoUTKm8smYQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-03 03:27:24', '2025-10-27 03:27:24', '2025-10-27 03:27:24'),
(138, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTUwNzk4LCJleHAiOjE3NjE1NTE2OTh9.UWxWZjQJ-HKgmCNNZOGqUCdKBrNDSf3jP0kFP-H8YAc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU1MDc5OCwiZXhwIjoxNzYyMTU1NTk4fQ.GkOzZ5KUr5vbX8K2dcR7tIq3JFFVXdYPlmWm__YyEHo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-03 07:39:58', '2025-10-27 07:39:58', '2025-10-27 07:39:58'),
(139, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTU4MTAzLCJleHAiOjE3NjE1NTkwMDN9.bMj9MrHBa4Wfz_VELiwfS9RZULls56jnelsfUy3681s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU1ODEwMywiZXhwIjoxNzYyMTYyOTAzfQ.p52Co7eomw1ti0RqIU5TCX4J-OjPoOn0zft-UdxiP9Q', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 09:44:49', '2025-10-27 09:41:43', '2025-10-27 09:44:49'),
(140, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTU5MzUxLCJleHAiOjE3NjE1NjAyNTF9.26pJcpA_6ZlwM6yDkXoxTBOss-jGYQR7FkKCSQjyEuA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU1OTM1MSwiZXhwIjoxNzYyMTY0MTUxfQ.h_tTVa4SrVBLYoJO4FI-HTk2qBgbmEM3fCM9aqdTphM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 10:13:06', '2025-10-27 10:02:31', '2025-10-27 10:13:06'),
(141, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTYyMTAzLCJleHAiOjE3NjE1NjMwMDN9.prgqMRoNwg_gqVVGll4hIEFgwnkJuQhz5nnl1OpVMXI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2MjEwMywiZXhwIjoxNzYyMTY2OTAzfQ.gL6PZUY42ao2HIG6WkOP6npE6Xn7wt7_74O_Um2ZXhw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 10:49:34', '2025-10-27 10:48:23', '2025-10-27 10:49:34'),
(142, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY0MTk1LCJleHAiOjE3NjE1NjUwOTV9.hkD2z-kmuDNrDNNOJmRwm5D1z089dhqUzXrHERcUtkY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2NDE5NSwiZXhwIjoxNzYyMTY4OTk1fQ.KPArIZ-Yf8_C6mVjGyegXPHKoJuFpsKLhsAKnj_2t4A', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-27 11:30:06', '2025-10-27 11:23:15', '2025-10-27 11:30:06'),
(143, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY0ODQyLCJleHAiOjE3NjE1NjU3NDJ9.87YHqEYePI0qfcwwNCEtcck7TRJ4t5bj30A2U9JzpoQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2NDg0MiwiZXhwIjoxNzYyMTY5NjQyfQ.MnC--bMj1G766vpH7Rye2PPmSdUpsQg9Vzrfbg3Q9Wk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 11:47:34', '2025-10-27 11:34:02', '2025-10-27 11:47:34'),
(144, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY1ODI0LCJleHAiOjE3NjE1NjY3MjR9.zB_7QqTD5HS28goOWC_tZnWM68Nbi-zRvU-adwNRHgk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2NTgyNCwiZXhwIjoxNzYyMTcwNjI0fQ.qbOrFohq4VcW8Szo1Ul91rsyJv_VKtKDyQr8I8McrMQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 12:02:08', '2025-10-27 11:50:24', '2025-10-27 12:02:08'),
(145, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY2Mjc5LCJleHAiOjE3NjE1NjcxNzl9.70_bZ7uHc4VtEv3PWngD7IHn1fIDBwS7pdAjPkARxIY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2NjI3OSwiZXhwIjoxNzYyMTcxMDc5fQ.XaUb1qAIaNmI5-NoebfVNlhQZQX43JOJrmFoY2H_XlI', '::1', 'PostmanRuntime/7.49.0', 1, '2025-10-27 12:00:19', '2025-10-27 11:57:59', '2025-10-27 12:00:19'),
(146, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY2NzU1LCJleHAiOjE3NjE1Njc2NTV9.lJu60KuZ0vXR6cFgK55t9xB1VRJ-x1zDfYjze6VSSP4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2Njc1NSwiZXhwIjoxNzYyMTcxNTU1fQ.FdOVrPA2YIFOCei_QwTSpIDrFAIM1DrUeG3oOKbqb_c', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 12:07:21', '2025-10-27 12:05:55', '2025-10-27 12:07:21'),
(147, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTY4MjA0LCJleHAiOjE3NjE1NjkxMDR9.igtAdVIzDapC6EU1I9pV5EC5ccxQ0sKGoz0nkGSTLcs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU2ODIwNCwiZXhwIjoxNzYyMTczMDA0fQ.Pin-Yb5lFhq3RANdglOwBCK9KtBehOU7zsmLN7FenIY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 12:32:43', '2025-10-27 12:30:04', '2025-10-27 12:32:43'),
(148, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTcwNDg4LCJleHAiOjE3NjE1NzEzODh9.2ySIUQOwWTzu3FkEzT9MTwBGqhrF_r-4XrO6MwbALoI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU3MDQ4OCwiZXhwIjoxNzYyMTc1Mjg4fQ.vIBWwz3gJhOk8bOECOT0n1O-3JposfGCtTrYEuSxQDY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 13:22:58', '2025-10-27 13:08:08', '2025-10-27 13:22:58'),
(149, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTcxNjI0LCJleHAiOjE3NjE1NzI1MjR9.7TL5pxKmhsLebnM9zAbLUETpeE_PTV83YEBkLcSZjow', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU3MTYyNCwiZXhwIjoxNzYyMTc2NDI0fQ.60meLABt9rSz4yBA5L4ce9fuIb407Fc5nKnDeN0EmBc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 13:38:38', '2025-10-27 13:27:04', '2025-10-27 13:38:38'),
(150, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTczMTU0LCJleHAiOjE3NjE1NzQwNTR9.VFl-hmyF2FIwQ-xb5aAl2SGlI3HqR8Dm0R_HukXTxUs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU3MzE1NCwiZXhwIjoxNzYyMTc3OTU0fQ._CUyo5aiTLWee8G3f9z6C0l2R6_X2baxx1q0LVuSyX0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 14:07:29', '2025-10-27 13:52:34', '2025-10-27 14:07:29'),
(151, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTc0MTQwLCJleHAiOjE3NjE1NzUwNDB9.hH0vjdXBFOTNeGBgCOrGDc2FyYy1VE5dxE5k0j4MRkw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU3NDE0MCwiZXhwIjoxNzYyMTc4OTQwfQ.7czLYs1sJQqqmz2uy2VmsAxMQRSYyeNW2_d7Ga70eng', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 14:19:44', '2025-10-27 14:09:00', '2025-10-27 14:19:44'),
(152, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTc1MTY5LCJleHAiOjE3NjE1NzYwNjl9.KC7XPu5RyujaPwMeWQ4SHzbJVyZrCuxmOqfEwGjjBu0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU3NTE2OSwiZXhwIjoxNzYyMTc5OTY5fQ.b0rsdkO-yz2JHnUGqiL9cMwuL5KmypoI0eSLOOyCRrw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 14:30:54', '2025-10-27 14:26:09', '2025-10-27 14:30:54'),
(153, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTkwNjc3LCJleHAiOjE3NjE1OTE1Nzd9.MdCrsPKa4VNZpYgq7AJUZ3s8qLxGpM0lh4GybkxWnrw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5MDY3NywiZXhwIjoxNzYyMTk1NDc3fQ.ZJoC6O4JraS8zl0F86tv2JzHl9hm7zMMWwsEG4cyuKA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 18:59:16', '2025-10-27 18:44:37', '2025-10-27 18:59:16'),
(154, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTkxNzczLCJleHAiOjE3NjE1OTI2NzN9.Ld3E83WJ2tFJcpW5xaONOg8-8S6mbZcKoAE2DC_26A8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5MTc3MywiZXhwIjoxNzYyMTk2NTczfQ.Nxjuf9NBnEDZPzFAGtcwrjBfWzgqno1eKyzJ5gY5ckc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 19:15:19', '2025-10-27 19:02:53', '2025-10-27 19:15:19'),
(155, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTkyNzQzLCJleHAiOjE3NjE1OTM2NDN9.3vig8put7q4h70eaH9IgpTRTifVYaGHhlwwQO3aX6hY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5Mjc0MywiZXhwIjoxNzYyMTk3NTQzfQ.Uz1XPQUrqecs-r9zaKgrlo5SdOA5MZAIjgYu3QX96ek', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 19:28:56', '2025-10-27 19:19:03', '2025-10-27 19:28:56'),
(156, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTkzMzQyLCJleHAiOjE3NjE1OTQyNDJ9.B8eN9tlv46_yxwTYxZViq3mGGYI0e6RKhwboHucUATA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5MzM0MiwiZXhwIjoxNzYyMTk4MTQyfQ.nFMlwlVzB-dDUpL9rCoNYd3eeAWUW-POihZAtqxnfH4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 19:42:57', '2025-10-27 19:29:02', '2025-10-27 19:42:57'),
(157, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTk0NDMxLCJleHAiOjE3NjE1OTUzMzF9.nyfGO9Te4VW0VLEz1LMTk2ul1DoUpblxq9p8xLT6j7M', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5NDQzMSwiZXhwIjoxNzYyMTk5MjMxfQ.qQP-x8BReX3q72KhCuwj4B2eE4-cuRqejvAHQT-qtHw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 19:50:15', '2025-10-27 19:47:11', '2025-10-27 19:50:15'),
(158, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTk2MjMxLCJleHAiOjE3NjE1OTcxMzF9.S-kwzPNl50b153z45xwujAxIak10EItD-8sHm1y7lfw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5NjIzMSwiZXhwIjoxNzYyMjAxMDMxfQ.OF3RUIkX4neBXXKupQnlOAqNUeXCv5yG0h00-bGEc44', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 20:23:52', '2025-10-27 20:17:11', '2025-10-27 20:23:52'),
(159, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTk3NzA0LCJleHAiOjE3NjE1OTg2MDR9.cLzRI7eW3JuiuRbb2Gyqi-fQJqpIYf_BxcbmwaRCJ6U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5NzcwNCwiZXhwIjoxNzYyMjAyNTA0fQ.ur2pzy2Hlz3RhOfMSjtPVHgXe2pAZok0wa0CC0w9QWw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 20:52:30', '2025-10-27 20:41:44', '2025-10-27 20:52:30'),
(160, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNTk5ODM1LCJleHAiOjE3NjE2MDA3MzV9.Wf5NW2sUWgVBFk1hgCsVtGVAftBLnTO1yyGkQOoMRoo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTU5OTgzNSwiZXhwIjoxNzYyMjA0NjM1fQ.Dr5nYRo878Z-yjIrd7zQQDgXvvfWz2k0SsyxXilpO2w', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 21:31:04', '2025-10-27 21:17:15', '2025-10-27 21:31:04'),
(161, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjAxOTA0LCJleHAiOjE3NjE2MDI4MDR9.VG-glBjtL1mCNIo7fhJYf8lqPxO-S3lHeG57ZxkklSg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTYwMTkwNCwiZXhwIjoxNzYyMjA2NzA0fQ.a3LVqOadijcBVeo5udRJiylQ6JrNf6LMEuxcNOzLp1A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 22:02:16', '2025-10-27 21:51:44', '2025-10-27 22:02:16'),
(162, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjAzMDQyLCJleHAiOjE3NjE2MDM5NDJ9.ogvoRvFyarqKuL5S8YAm7Gead_JJbf3CFHGHdm6-qC0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTYwMzA0MiwiZXhwIjoxNzYyMjA3ODQyfQ.DPqPZ_DBiCefjHF-b868I6qLugYoE188cTp7EKGREWI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 22:24:51', '2025-10-27 22:10:42', '2025-10-27 22:24:51'),
(163, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjA0MzkzLCJleHAiOjE3NjE2MDUyOTN9.gd_0R_8qPFA_HIusN7SULgI0v77igd_dkTWAv-Q5GVI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTYwNDM5MywiZXhwIjoxNzYyMjA5MTkzfQ.Mm8p708f1PPXN4ICSKdYWnG-jcMYmVDPNqb4p-EAgTM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 22:43:52', '2025-10-27 22:33:13', '2025-10-27 22:43:52'),
(164, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjA1MzkxLCJleHAiOjE3NjE2MDYyOTF9.7uVnmP40DfCOwBz9NAAximymBMYadnlQd548vSJl28w', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTYwNTM5MSwiZXhwIjoxNzYyMjEwMTkxfQ.n0IfOXX-o1NMMJX1B1SJH07VGBMebVasfkqMs2K28wo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 22:59:21', '2025-10-27 22:49:51', '2025-10-27 22:59:21'),
(165, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjA1OTcxLCJleHAiOjE3NjE2MDY4NzF9.eEU07JGR1TLAtclD0DfnB-CY8R8GOlg8bu2uEfVSb88', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTYwNTk3MSwiZXhwIjoxNzYyMjEwNzcxfQ.KToPP0C31GnVGgz4SYMviu52S31TCin03IT4Y5B9t9s', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-27 23:11:58', '2025-10-27 22:59:31', '2025-10-27 23:11:58'),
(166, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjA2NzI5LCJleHAiOjE3NjE2MDc2Mjl9.yAoz5AEwi7Ux9x9yFfKCz3woGQSKjxgfkW0nHXeSl2s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2MDY3MjksImV4cCI6MTc2MjIxMTUyOX0.9Z914xOthg_vPMYgv3UYv8AWLjiT7RXvCmajy1iEeK8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 23:17:36', '2025-10-27 23:12:09', '2025-10-27 23:17:36'),
(167, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjA3OTM4LCJleHAiOjE3NjE2MDg4Mzh9.TchJFRrXcFDglu_LLTrPzBKntlhhFdKvnkdIyBGOK7o', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2MDc5MzgsImV4cCI6MTc2MjIxMjczOH0.SqT24rJggdpzNt0KjQtlyZNPZaCwycjC1UM5sxaZ_x0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-27 23:40:26', '2025-10-27 23:32:18', '2025-10-27 23:40:26'),
(168, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjA5MTEwLCJleHAiOjE3NjE2MTAwMTB9.PQSPzPVVuRZsi0CEjcgwaqWs-shFAbePObXSX2aepp8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2MDkxMTAsImV4cCI6MTc2MjIxMzkxMH0.nu17sNZ-HnQ1apzWxdEXzAgCuMrfz9xsZUau0pe0o1Q', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 00:05:56', '2025-10-27 23:51:50', '2025-10-28 00:05:56'),
(169, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjQwMDkwLCJleHAiOjE3NjE2NDA5OTB9.PP87OvQEwLjbtoavOl2qd5uEjQSAjdTrtx62TeH0ZUg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY0MDA5MCwiZXhwIjoxNzYyMjQ0ODkwfQ.1O5o3grqcagmLY12XxS7xbHmr9MTAnmg8Dvda5S-h54', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 08:38:28', '2025-10-28 08:28:10', '2025-10-28 08:38:28'),
(170, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQwNzE5LCJleHAiOjE3NjE2NDE2MTl9.I-x04PLmkDfxGRO_lzObaOuYMIvebASNSHLFd7oMOFI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDA3MTksImV4cCI6MTc2MjI0NTUxOX0.vX3xdd-RWh7C-9dwhUAsK71i81hXOax5Ph41JuXOaN4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 08:43:26', '2025-10-28 08:38:39', '2025-10-28 08:43:26'),
(171, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQyNTI2LCJleHAiOjE3NjE2NDM0MjZ9.A3xm7dDnHY6mQdpefS70IUQ4e3VYG9xd0k6-LfN_sZQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDI1MjYsImV4cCI6MTc2MjI0NzMyNn0.Nbucvaccsvuzt1NXEwqYms1fPvj7me2NY9JnKxQe82g', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 09:22:01', '2025-10-28 09:08:46', '2025-10-28 09:22:01'),
(172, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQzNDU5LCJleHAiOjE3NjE2NDQzNTl9.sPb7Nzw9pk7GYRVgDv5FJF21S7ubl77ZLzPRmS0_Zew', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDM0NTksImV4cCI6MTc2MjI0ODI1OX0.0spYVKYBxtk12R57-S6-idVmY6RNf1AMHB8Rbm5i5A4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 09:24:58', '2025-10-28 09:24:19', '2025-10-28 09:24:58'),
(173, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ1MTA4LCJleHAiOjE3NjE2NDYwMDh9.XKdRExHL0ikTqhri0uZgfcQoTqPMNcLDyMseuyITIf4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDUxMDgsImV4cCI6MTc2MjI0OTkwOH0.k_mse3ShspXh3d-hFGjrGEw2It8XnN0c5IzsXCV8Sxo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 09:55:41', '2025-10-28 09:51:48', '2025-10-28 09:55:41'),
(174, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ1MzUyLCJleHAiOjE3NjE2NDYyNTJ9.GUHq6IjJjKdeREPQbYNULob2FWUNYNJrVkWF81SycLE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDUzNTIsImV4cCI6MTc2MjI1MDE1Mn0.54eUCpyRHeUtqZAsWiA6eEQXrA9iOO1Rxr0AD5vEUGk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 10:02:15', '2025-10-28 09:55:52', '2025-10-28 10:02:15'),
(175, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ1NzQyLCJleHAiOjE3NjE2NDY2NDJ9.VL-BVVVt8dwSCv6AK4oQEjb3qma2tbJO2U0qX6l-m-0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDU3NDIsImV4cCI6MTc2MjI1MDU0Mn0.bf2jbUer4Fcl89gbGw-dqeEsuAeR6ffRtssy4lUH3iA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 10:16:40', '2025-10-28 10:02:22', '2025-10-28 10:16:40'),
(176, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ2NjgwLCJleHAiOjE3NjE2NDc1ODB9.asBEYBEOUzL5q9wHy3Zvumyt4zUfQ00SatrlE4yeuMs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDY2ODAsImV4cCI6MTc2MjI1MTQ4MH0.L2BbFSrmNedwDbV_S-2lrdOx_6dQGepJtSVcsSenCqs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 10:28:45', '2025-10-28 10:18:00', '2025-10-28 10:28:45'),
(177, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ3NzUyLCJleHAiOjE3NjE2NDg2NTJ9.fGe7keUogoN78tyBO-vAdJlyI1On_rOscyLhSicO0Ys', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDc3NTIsImV4cCI6MTc2MjI1MjU1Mn0.IhQpOIdmV5zhTMP5UuDfOVnCSG0CHNt7UVedVFndDP4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 10:39:57', '2025-10-28 10:35:52', '2025-10-28 10:39:57'),
(178, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjQ4MDAzLCJleHAiOjE3NjE2NDg5MDN9.FUVqUSNokDsPpyTqAOTFd2jt8A4feg3LnQNmjoPeGPQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY0ODAwMywiZXhwIjoxNzYyMjUyODAzfQ.By_GD3V5ihZOIJ1zk1zhdcWLwY3fhHMfEtOj8pSCyKo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 10:46:21', '2025-10-28 10:40:03', '2025-10-28 10:46:21'),
(179, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2NDg0MjIsImV4cCI6MTc2MTY0OTMyMn0.nyXrM32R2KQ_pKRXg2wC4QLEXcLnhYLAU9hj4vb-sx0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDg0MjIsImV4cCI6MTc2MjI1MzIyMn0.4NC6xM03qDdZutUwDH5e2aEw7WCgOCAJSOyt7UTmX6Y', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 10:47:44', '2025-10-28 10:47:02', '2025-10-28 10:47:44'),
(180, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ4NDgwLCJleHAiOjE3NjE2NDkzODB9.UQXvk75Jqbuuxtt55VJaYuNi6FTqkTV7wN0mnvxJvz0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDg0ODAsImV4cCI6MTc2MjI1MzI4MH0.2PVtlGJOmIfIKoZNRyeKECopQDwzmWPUD1svMDHITU8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 10:49:41', '2025-10-28 10:48:00', '2025-10-28 10:49:41'),
(181, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjQ4NTg4LCJleHAiOjE3NjE2NDk0ODh9.R1XYw2SL5VaXmXeXu_-ghTUtzMZcxEBRrWjMExqsAaE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY0ODU4OCwiZXhwIjoxNzYyMjUzMzg4fQ.FB6pQlJCAk5d22v67qqjf110P4O8bwqPzd1oQIi_XfY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 10:54:19', '2025-10-28 10:49:48', '2025-10-28 10:54:19'),
(182, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjQ5NjE3LCJleHAiOjE3NjE2NTA1MTd9.U9sNM7C5klA8zDBIq6ODQzm61cKbk9SGHThlomNtjrM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY0OTYxNywiZXhwIjoxNzYyMjU0NDE3fQ.qRTJvMlekYonN8knlN3DgdG8qTSJ7-kxlC1G1U5T8ug', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 11:10:27', '2025-10-28 11:06:57', '2025-10-28 11:10:27'),
(183, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjQ5OTUzLCJleHAiOjE3NjE2NTA4NTN9.7oWjWD_h33cf6Ysa_yW3sCohTxDfG0mDKgpeeDZAxRU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NDk5NTMsImV4cCI6MTc2MjI1NDc1M30.c8xoejC49v-ISXHctBE_u0HSU9-jN_wxUV-68_LTosE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 11:24:19', '2025-10-28 11:12:33', '2025-10-28 11:24:19'),
(184, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjUxMDMzLCJleHAiOjE3NjE2NTE5MzN9.0_tt6dndrfg86NnWlBHpSfYKrPUOEZsRC-LDTO1taco', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTEwMzMsImV4cCI6MTc2MjI1NTgzM30.yK9aI1lbHg2iC681GfoawleUuR1iJ2p6WqMrBP4qkOo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 11:33:00', '2025-10-28 11:30:33', '2025-10-28 11:33:00'),
(185, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjUxMTg1LCJleHAiOjE3NjE2NTIwODV9.0V_I0rg2vSfwDGRFC-fJ-jHXvaI3cxvKCs-QqpzXpI0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY1MTE4NSwiZXhwIjoxNzYyMjU1OTg1fQ.pGipRciPPX7EseCU7prfw2dJRg4PcszHbAyDWaETZmg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 11:33:38', '2025-10-28 11:33:05', '2025-10-28 11:33:38'),
(186, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjUxMjI2LCJleHAiOjE3NjE2NTIxMjZ9.hsHb0FYsQJOdNypNl6dqCCH-ma4G6D0nj2e1bnT6y-4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTEyMjYsImV4cCI6MTc2MjI1NjAyNn0.nwz0mzTylgAt3kNP-GKAIF03NFjsyvjdTOij5Zv_65A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 11:36:38', '2025-10-28 11:33:46', '2025-10-28 11:36:38'),
(187, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2NTE0MTMsImV4cCI6MTc2MTY1MjMxM30.RMAmNhsz2xvKhz-6PdoVhUZ0INSDU6iT_dZ_Tx-444s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTE0MTMsImV4cCI6MTc2MjI1NjIxM30.6oPM96hWM0Jn7gflYdhFaS_4RFMtvIguVbMR34TiZNY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 11:47:05', '2025-10-28 11:36:53', '2025-10-28 11:47:05'),
(188, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjUyMDM1LCJleHAiOjE3NjE2NTI5MzV9.eIKVCbyWiaTZoVNVYmuV-Nf5MOjCf-LOzAmbOE_qHHg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTIwMzUsImV4cCI6MTc2MjI1NjgzNX0.OgntfZfPFINAHCVcQtW6k2RzIygRxONRBJHB44ZBGuU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 12:02:10', '2025-10-28 11:47:15', '2025-10-28 12:02:10'),
(189, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjUyOTQxLCJleHAiOjE3NjE2NTM4NDF9.7nClqXLM5asXCJxYa7YD8ajccpdZH6OxroC4X0Nq75U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTI5NDEsImV4cCI6MTc2MjI1Nzc0MX0.1In91FBz5pEEcFBnDV2ENEkvtuPAX_i6G1ysKYGMPwE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 12:14:47', '2025-10-28 12:02:21', '2025-10-28 12:14:47'),
(190, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2NTY0MTMsImV4cCI6MTc2MTY1NzMxM30.xWJkVzP1MEjcSHxjHbfZyfx52DcvH3o7gJlObH64zv0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTY0MTMsImV4cCI6MTc2MjI2MTIxM30.Aa3J8gTjjuaFB2sgEK2gsoUOGi4st5QRw2za-oafHvE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 13:12:06', '2025-10-28 13:00:13', '2025-10-28 13:12:06'),
(191, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyOF85ODY4IiwiZW1haWwiOiJvbHdldGh1ZGxhbWluMTBAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTY1Nzk2NywiZXhwIjoxNzYxNjU4ODY3fQ.zzjMsRCHqrsy5F-GD4bTTNZc9mzxaG6Hses7HZHbyBA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NTc5NjcsImV4cCI6MTc2MjI2Mjc2N30.MOGQtSA6WDpeks9xDV2puPzxjz_TH0IAaH1iomdWdO8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 13:36:44', '2025-10-28 13:26:07', '2025-10-28 13:36:44'),
(192, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyOF85ODY4IiwiZW1haWwiOiJvbHdldGh1ZGxhbWluMTBAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTY2MDAzMSwiZXhwIjoxNzYxNjYwOTMxfQ.zHH6WDitirIKVJr95s5UzDLxH1AXkL5nWlt_vtiR1RE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NjAwMzEsImV4cCI6MTc2MjI2NDgzMX0.7SR0f4EJiB32fNlb5FHQM1xbkJtzjXWRAeQPMOO9QfU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 14:09:09', '2025-10-28 14:00:31', '2025-10-28 14:09:09'),
(193, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyOF85ODY4IiwiZW1haWwiOiJvbHdldGh1ZGxhbWluMTBAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTY2MTE4OCwiZXhwIjoxNzYxNjYyMDg4fQ.bRiMlkVFGy01KUhuxGQOFXPyxOKps-slZW1m08A48pw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NjExODgsImV4cCI6MTc2MjI2NTk4OH0.zD-0ub69mkL6bymeOLkV5T308fNusy2pBMQxvrF7YGM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 14:20:25', '2025-10-28 14:19:48', '2025-10-28 14:20:25'),
(194, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjYxMjM5LCJleHAiOjE3NjE2NjIxMzl9.oWpLueBBc7c8oMmcdnVFuZItRk9k5isLlYdz-AjZxyo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY2MTIzOSwiZXhwIjoxNzYyMjY2MDM5fQ.Mfmh9J0QYNy7TWqjBInufW8fwtbiZyas2mtFSsWIpMM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 14:20:54', '2025-10-28 14:20:39', '2025-10-28 14:20:54'),
(195, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjYxMjYzLCJleHAiOjE3NjE2NjIxNjN9.022AKOKidQkH4xb4AZHR-ptPSeulkMD0RD0alzi2hoE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NjEyNjMsImV4cCI6MTc2MjI2NjA2M30.JAM-P7dHl1albO7Y4BG3SugWMa0VIsbbNQ59mOWFpM0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 14:35:35', '2025-10-28 14:21:03', '2025-10-28 14:35:35'),
(196, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjYyNDE4LCJleHAiOjE3NjE2NjMzMTh9.brKVq-qKMwUb7DSN625l2Ppr8q2sq30wwtMbe64T_zM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NjI0MTgsImV4cCI6MTc2MjI2NzIxOH0.kdRG2_URUoPBlStVxQN1n86TPX5tpxcKv44B7yQZ1c8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 14:40:32', '2025-10-28 14:40:18', '2025-10-28 14:40:32'),
(197, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxNjYzOTQxLCJleHAiOjE3NjE2NjQ4NDF9.9U-4Y_bbawhoAPdfjUmsVlrd8xvCfLLi45yl5S7yI7A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2NjM5NDEsImV4cCI6MTc2MjI2ODc0MX0.vWf-lpTCQcxCz8z041TnJuq7Q_5rPh38Fbe3zQsS678', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 15:06:26', '2025-10-28 15:05:41', '2025-10-28 15:06:26'),
(198, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjYzOTkzLCJleHAiOjE3NjE2NjQ4OTN9.obZrdYoEEEDMgoFNhOqPyzquKCDBqPZjUPlMrZqRHoY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY2Mzk5MywiZXhwIjoxNzYyMjY4NzkzfQ.4ndX2Ght7kfx4VukiPPbIEPgg6tgm2CLx8t2WQ6VbeI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 15:17:24', '2025-10-28 15:06:33', '2025-10-28 15:17:24'),
(199, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjY1MTExLCJleHAiOjE3NjE2NjYwMTF9.m-hJWn4h-iWqLgDjozo-AQSOyXkxPj6KgKWta_sUShY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY2NTExMSwiZXhwIjoxNzYyMjY5OTExfQ.elcOWUv9fIOxTAIfa0lYxw1gF3HTflD42mEimF7wry0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 15:38:27', '2025-10-28 15:25:11', '2025-10-28 15:38:27'),
(200, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjc0Nzg1LCJleHAiOjE3NjE2NzU2ODV9.AuTysX1NtQxs06RAGLFSO5TtIwEmRPiSkwFPFYpZ5X8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY3NDc4NSwiZXhwIjoxNzYyMjc5NTg1fQ.ESEvhD60ZJoQq05XS2npLZSnC4JQz216SBpPhLoYGlI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 18:07:54', '2025-10-28 18:06:25', '2025-10-28 18:07:54'),
(201, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjc0ODg1LCJleHAiOjE3NjE2NzU3ODV9.mFOjFI__GULdNVgk8QUmMBJPfec6YUqeEsCqnxDybbc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY3NDg4NSwiZXhwIjoxNzYyMjc5Njg1fQ.TrsQPpA3EdHCTSIrf9HdGlD4fUY6lj321XIDUEYeb9s', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 18:12:32', '2025-10-28 18:08:05', '2025-10-28 18:12:32'),
(202, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjc1MTY2LCJleHAiOjE3NjE2NzYwNjZ9._cH2fniNvKP7NN6m8d8hcg8E-fWhaFak7ZVvIdEMudw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY3NTE2NiwiZXhwIjoxNzYyMjc5OTY2fQ.CqiCDnHff_aavIOBmhXS0c_N6qpGvqWSSclIGYtrBqE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 18:14:36', '2025-10-28 18:12:46', '2025-10-28 18:14:36'),
(203, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjc1Mjg0LCJleHAiOjE3NjE2NzYxODR9.Y3LhyhNOI1rxEhBCEVrmI9k_GfDK_meEpDfg1leC25Q', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY3NTI4NCwiZXhwIjoxNzYyMjgwMDg0fQ.ALYCbNV7wGhj_8-BFQKsSxVxuhrFCSgdxWsyeE-1bPk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-28 18:16:28', '2025-10-28 18:14:44', '2025-10-28 18:16:28'),
(204, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjc1Mzk2LCJleHAiOjE3NjE2NzYyOTZ9.TU0wgkxskfu96vcv4wce7ipzanR7iyJcXiiiMEESxz4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY3NTM5NiwiZXhwIjoxNzYyMjgwMTk2fQ.aen_wSboEvrLB66O-2cxi9sT5uE2AryVowwcrffZg_8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 18:21:49', '2025-10-28 18:16:36', '2025-10-28 18:21:49'),
(205, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNjgxMDgzLCJleHAiOjE3NjE2ODE5ODN9.tBKLGU9aUawE4KJAu6U6YqmGEsUsdeAgEo3tvqKZzXE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTY4MTA4MywiZXhwIjoxNzYyMjg1ODgzfQ.ALhIbt-7ZMTqC72q-qtNy_WdXplYCgU8HtSKHayAhS0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 20:04:22', '2025-10-28 19:51:23', '2025-10-28 20:04:22'),
(206, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2ODI1NTUsImV4cCI6MTc2MTY4MzQ1NX0.-XUj70-5OuDtcFY9UO1f2obJ_YWM4SU39Obm4Xv-c_s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2ODI1NTUsImV4cCI6MTc2MjI4NzM1NX0.BwQdBMCR3AT4_nYbK0vqwOQnoN2vZ_oe6bCUJSnsSqI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 20:25:42', '2025-10-28 20:15:55', '2025-10-28 20:25:42'),
(207, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2ODU4MTgsImV4cCI6MTc2MTY4NjcxOH0.v-wFpRiIFoHFzZKB0g5TKiyPNoNApd7GgVKBBIRpENw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2ODU4MTgsImV4cCI6MTc2MjI5MDYxOH0.Id5TF2mQ7DpqNHasVzptyj-synklVmfffvVe1CxVASg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 21:24:59', '2025-10-28 21:10:18', '2025-10-28 21:24:59'),
(208, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2ODc0MjksImV4cCI6MTc2MTY4ODMyOX0.LmcvaAd_i9mFI2Hm0oLJ9yF1aacHE_9qAVx8Kke37a0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2ODc0MjksImV4cCI6MTc2MjI5MjIyOX0.fxanGRPALEUf9oE5JonMASQI3PioZJgIiHXiJu-h6Ig', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 21:37:11', '2025-10-28 21:37:09', '2025-10-28 21:37:11'),
(209, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2ODg1NjAsImV4cCI6MTc2MTY4OTQ2MH0.CEA1y46mf1IrC3IJrhI933MO9vlYl_tpo7N90tBQj3c', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2ODg1NjAsImV4cCI6MTc2MjI5MzM2MH0.Eo6qLOJE9ssDvhl2ndziGszJD9oGO5ph5DCp6oONHww', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 22:06:09', '2025-10-28 21:56:00', '2025-10-28 22:06:09'),
(210, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2ODk5NTMsImV4cCI6MTc2MTY5MDg1M30.nHhNh5wQ7KuVu75dGXpJE8JBqQSAIGoziJZ_bIfSFiU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2ODk5NTMsImV4cCI6MTc2MjI5NDc1M30.e9hx2yi8omeffayKVI-bJZWvBmhxgY1XHLvQnND1ivo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 22:33:57', '2025-10-28 22:19:13', '2025-10-28 22:33:57'),
(211, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2OTA5MTYsImV4cCI6MTc2MTY5MTgxNn0.MMKsl-1n_S9_UC8TZg5MWCg1d8V3LBlx-DCBkIW_v6o', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2OTA5MTYsImV4cCI6MTc2MjI5NTcxNn0.my75gkwD8C2w-n5qBB-MeA0rXpt-j9c5CVECZWiC2Yc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 22:42:16', '2025-10-28 22:35:16', '2025-10-28 22:42:16'),
(212, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2OTIwNjIsImV4cCI6MTc2MTY5Mjk2Mn0.Q-oT57n-orA8Jp3IrRolSCNWSgvE1YZTYKAWpYB0Xjk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2OTIwNjIsImV4cCI6MTc2MjI5Njg2Mn0.UUp7ooeN-JFzZTN3sTOMFE-mFMTPhyJrgW8ORhFqtDc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 23:02:52', '2025-10-28 22:54:22', '2025-10-28 23:02:52'),
(213, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2OTM0NTgsImV4cCI6MTc2MTY5NDM1OH0.m5_J7gsM3Ews-goRUSFIYOKNNEUYVgzmPTvUYbc_dSI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2OTM0NTgsImV4cCI6MTc2MjI5ODI1OH0.kXTK4oaG9GNcZinavuCVMI0eqcV-zStfxyt2qkeexoc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-28 23:26:06', '2025-10-28 23:17:38', '2025-10-28 23:26:06'),
(214, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE2OTYwOTYsImV4cCI6MTc2MTY5Njk5Nn0.yBOOzky1FTz2_Yu26ObGIZH1hlbcBqGan2jaifBnIkA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE2OTYwOTYsImV4cCI6MTc2MjMwMDg5Nn0.uLPOuNnFTjn4KpvpJrzlggdQdRIZ21bmhJjEhKebxv0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-29 00:01:51', '2025-10-29 00:01:36', '2025-10-29 00:01:51');
INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `refresh_token`, `ip_address`, `user_agent`, `is_active`, `expires_at`, `created_at`, `last_activity`) VALUES
(215, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoidGVtcF8yMDI1MTAyNl85MDg0IiwiZW1haWwiOiJjZWxpbXBoaWxvZGxhbWluaTk0QGdtYWlsLmNvbSIsInJvbGUiOiJFT0ciLCJpYXQiOjE3NjE3MjQ5NjAsImV4cCI6MTc2MTcyNTg2MH0.mIuPmhc5Nllmc5nfjcZBjoBXztym5oCxQBbZtIqjr94', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE3MjQ5NjAsImV4cCI6MTc2MjMyOTc2MH0.rscG94AL8lPKiEFa95Fi8YhVsSTMfBAW0-OaTPxkJGo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-10-29 08:03:22', '2025-10-29 08:02:40', '2025-10-29 08:03:22'),
(216, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTcyNTAxMCwiZXhwIjoxNzYxNzI1OTEwfQ.ZxPj0K-aYYfQed1WAv9-EFYgf4dwg1riUg_FNuOz_E8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE3MjUwMTAsImV4cCI6MTc2MjMyOTgxMH0.6hnmkKAKB9RMCYS1kfETs4dSN0S0kUXsqcRlBxYm3ZY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-29 08:06:29', '2025-10-29 08:03:30', '2025-10-29 08:06:29'),
(217, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTcyNzA2OSwiZXhwIjoxNzYxNzI3OTY5fQ.yb8Ey0_zrMfseqk3n39qTd52orcHS_BEgcld7qXAZ4g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE3MjcwNjksImV4cCI6MTc2MjMzMTg2OX0.CGGSkQU5M5dzd-OY7PSGg1fAf5SZZVBzeg_5myZwWjU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-29 08:38:15', '2025-10-29 08:37:49', '2025-10-29 08:38:15'),
(218, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxNzM1NTIzLCJleHAiOjE3NjE3MzY0MjN9.0aMZEjOfnvS2vREp8EYdtzOb2DRW3tq4hYGpI88Z9us', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTczNTUyMywiZXhwIjoxNzYyMzQwMzIzfQ.aVwNXZf3dutjU2zmM-xH0V-AO3isCOPhzVGnDFsT5sw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-29 10:58:47', '2025-10-29 10:58:43', '2025-10-29 10:58:47');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_application_progress`
-- (See below for the actual view)
--
CREATE TABLE `v_application_progress` (
`id` int(11)
,`reference_number` varchar(50)
,`eog_name` varchar(200)
,`current_level` enum('EOG_LEVEL','MINISTRY_LEVEL','MICROPROJECTS_LEVEL','CDO_LEVEL','UMPHAKATSI_LEVEL','INKHUNDLA_LEVEL','RDFTC_LEVEL','RDFC_LEVEL','PS_LEVEL','PROCUREMENT_LEVEL','IMPLEMENTATION_LEVEL')
,`status` enum('draft','submitted','in_review','returned','recommended','approved','rejected','completed')
,`progress_percentage` decimal(5,2)
,`funding_amount` decimal(15,2)
,`approved_amount` decimal(15,2)
,`disbursed_amount` decimal(15,2)
,`region` varchar(50)
,`tinkhundla` varchar(100)
,`submitted_at` timestamp
,`days_in_system` int(7)
,`workflow_actions` bigint(21)
,`total_comments` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_temporal_eogs`
-- (See below for the actual view)
--
CREATE TABLE `v_temporal_eogs` (
`id` int(11)
,`company_name` varchar(200)
,`company_type` enum('Association','Cooperative','Company','Community Group','Scheme','Partnership')
,`email` varchar(100)
,`phone` varchar(20)
,`region` varchar(50)
,`tinkhundla` varchar(100)
,`umphakatsi` varchar(100)
,`chief_name` varchar(150)
,`status` enum('temporary','pending_verification','approved','rejected','suspended')
,`temp_account_expires` timestamp
,`days_remaining` int(7)
,`total_members` bigint(21)
,`executive_members` decimal(22,0)
,`verified_executives` decimal(22,0)
,`uploaded_documents` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `v_application_progress`
--
DROP TABLE IF EXISTS `v_application_progress`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_application_progress`  AS SELECT `a`.`id` AS `id`, `a`.`reference_number` AS `reference_number`, `e`.`company_name` AS `eog_name`, `a`.`current_level` AS `current_level`, `a`.`status` AS `status`, `a`.`progress_percentage` AS `progress_percentage`, `a`.`funding_amount` AS `funding_amount`, `a`.`approved_amount` AS `approved_amount`, `a`.`disbursed_amount` AS `disbursed_amount`, `r`.`name` AS `region`, `t`.`name` AS `tinkhundla`, `a`.`submitted_at` AS `submitted_at`, to_days(current_timestamp()) - to_days(`a`.`submitted_at`) AS `days_in_system`, (select count(0) from `application_workflow` where `application_workflow`.`application_id` = `a`.`id`) AS `workflow_actions`, (select count(0) from `application_comments` where `application_comments`.`application_id` = `a`.`id`) AS `total_comments` FROM (((`applications` `a` join `eogs` `e` on(`a`.`eog_id` = `e`.`id`)) join `regions` `r` on(`e`.`region_id` = `r`.`id`)) join `tinkhundla` `t` on(`e`.`tinkhundla_id` = `t`.`id`)) WHERE `a`.`status` <> 'draft' ;

-- --------------------------------------------------------

--
-- Structure for view `v_temporal_eogs`
--
DROP TABLE IF EXISTS `v_temporal_eogs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_temporal_eogs`  AS SELECT `e`.`id` AS `id`, `e`.`company_name` AS `company_name`, `e`.`company_type` AS `company_type`, `e`.`email` AS `email`, `e`.`phone` AS `phone`, `r`.`name` AS `region`, `t`.`name` AS `tinkhundla`, `i`.`name` AS `umphakatsi`, `i`.`chief_name` AS `chief_name`, `e`.`status` AS `status`, `e`.`temp_account_expires` AS `temp_account_expires`, to_days(`e`.`temp_account_expires`) - to_days(current_timestamp()) AS `days_remaining`, count(distinct `em`.`id`) AS `total_members`, sum(case when `em`.`is_executive` = 1 then 1 else 0 end) AS `executive_members`, sum(case when `em`.`is_executive` = 1 and `em`.`verification_status` = 'verified' then 1 else 0 end) AS `verified_executives`, count(distinct `ed`.`id`) AS `uploaded_documents` FROM (((((`eogs` `e` join `regions` `r` on(`e`.`region_id` = `r`.`id`)) join `tinkhundla` `t` on(`e`.`tinkhundla_id` = `t`.`id`)) join `imiphakatsi` `i` on(`e`.`umphakatsi_id` = `i`.`id`)) left join `eog_members` `em` on(`em`.`eog_id` = `e`.`id`)) left join `eog_documents` `ed` on(`ed`.`eog_id` = `e`.`id`)) WHERE `e`.`status` in ('temporary','pending_verification') GROUP BY `e`.`id`, `e`.`company_name`, `e`.`company_type`, `e`.`email`, `e`.`phone`, `r`.`name`, `t`.`name`, `i`.`name`, `i`.`chief_name`, `e`.`status`, `e`.`temp_account_expires` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference_number` (`reference_number`),
  ADD KEY `form_id` (`form_id`),
  ADD KEY `idx_reference` (`reference_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_level` (`current_level`),
  ADD KEY `idx_eog` (`eog_id`);

--
-- Indexes for table `application_attachments`
--
ALTER TABLE `application_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_workflow_level` (`workflow_level`);

--
-- Indexes for table `application_comments`
--
ALTER TABLE `application_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `parent_comment_id` (`parent_comment_id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_workflow_level` (`workflow_level`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `application_workflow`
--
ALTER TABLE `application_workflow`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actioned_by` (`actioned_by`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_level` (`to_level`),
  ADD KEY `idx_actioned_at` (`actioned_at`);

--
-- Indexes for table `beneficiary_feedback`
--
ALTER TABLE `beneficiary_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_type` (`feedback_type`);

--
-- Indexes for table `cdo_review_queue`
--
ALTER TABLE `cdo_review_queue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_assigned_cdo` (`assigned_cdo_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_priority` (`priority`);

--
-- Indexes for table `committees`
--
ALTER TABLE `committees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `region_id` (`region_id`),
  ADD KEY `tinkhundla_id` (`tinkhundla_id`),
  ADD KEY `umphakatsi_id` (`umphakatsi_id`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `committee_approvals`
--
ALTER TABLE `committee_approvals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_approval` (`application_id`,`committee_member_id`,`workflow_level`),
  ADD KEY `committee_member_id` (`committee_member_id`),
  ADD KEY `signature_otp_id` (`signature_otp_id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_committee` (`committee_id`),
  ADD KEY `idx_level` (`workflow_level`),
  ADD KEY `idx_signed_at` (`signed_at`);

--
-- Indexes for table `committee_members`
--
ALTER TABLE `committee_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_committee_user` (`committee_id`,`user_id`),
  ADD KEY `idx_committee` (`committee_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `email_logs`
--
ALTER TABLE `email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_recipient` (`recipient_user_id`);

--
-- Indexes for table `eogs`
--
ALTER TABLE `eogs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_name` (`company_name`),
  ADD UNIQUE KEY `bin_cin` (`bin_cin`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `tinkhundla_id` (`tinkhundla_id`),
  ADD KEY `umphakatsi_id` (`umphakatsi_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_region` (`region_id`),
  ADD KEY `idx_bin_cin` (`bin_cin`);

--
-- Indexes for table `eog_documents`
--
ALTER TABLE `eog_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_type` (`document_type`);

--
-- Indexes for table `eog_expiry_notifications`
--
ALTER TABLE `eog_expiry_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email_log_id` (`email_log_id`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_sent_at` (`sent_at`);

--
-- Indexes for table `eog_members`
--
ALTER TABLE `eog_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_id_number` (`id_number`),
  ADD KEY `idx_verification` (`verification_status`);

--
-- Indexes for table `eog_temporal_activity`
--
ALTER TABLE `eog_temporal_activity`
  ADD PRIMARY KEY (`id`),
  ADD KEY `performed_by` (`performed_by`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_activity_type` (`activity_type`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `eog_users`
--
ALTER TABLE `eog_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_eog_user` (`eog_id`,`user_id`),
  ADD KEY `idx_eog_id` (`eog_id`),
  ADD KEY `idx_user_id` (`user_id`);

--
-- Indexes for table `forms`
--
ALTER TABLE `forms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `form_questions`
--
ALTER TABLE `form_questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `conditional_question_id` (`conditional_question_id`),
  ADD KEY `idx_section` (`section_id`),
  ADD KEY `idx_type` (`question_type`);

--
-- Indexes for table `form_responses`
--
ALTER TABLE `form_responses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_application_question` (`application_id`,`question_id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_question` (`question_id`),
  ADD KEY `idx_answered_by` (`answered_by`);

--
-- Indexes for table `form_sections`
--
ALTER TABLE `form_sections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_id` (`form_id`),
  ADD KEY `idx_parent` (`parent_section_id`),
  ADD KEY `idx_workflow` (`workflow_level`);

--
-- Indexes for table `imiphakatsi`
--
ALTER TABLE `imiphakatsi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tinkhundla_id` (`tinkhundla_id`);

--
-- Indexes for table `impact_assessments`
--
ALTER TABLE `impact_assessments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assessor_user_id` (`assessor_user_id`),
  ADD KEY `idx_application` (`application_id`);

--
-- Indexes for table `member_verification_issues`
--
ALTER TABLE `member_verification_issues`
  ADD PRIMARY KEY (`id`),
  ADD KEY `training_register_id` (`training_register_id`),
  ADD KEY `reported_by` (`reported_by`),
  ADD KEY `resolved_by` (`resolved_by`),
  ADD KEY `idx_eog_member` (`eog_member_id`),
  ADD KEY `idx_resolved` (`resolved`),
  ADD KEY `idx_issue_type` (`issue_type`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parent_message_id` (`parent_message_id`),
  ADD KEY `related_application_id` (`related_application_id`),
  ADD KEY `idx_sender` (`sender_id`),
  ADD KEY `idx_recipient` (`recipient_id`),
  ADD KEY `idx_read` (`is_read`);

--
-- Indexes for table `otps`
--
ALTER TABLE `otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_otp` (`otp_code`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `idx_purpose` (`purpose`);

--
-- Indexes for table `project_milestones`
--
ALTER TABLE `project_milestones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_code` (`code`);

--
-- Indexes for table `site_visits`
--
ALTER TABLE `site_visits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `visitor_user_id` (`visitor_user_id`),
  ADD KEY `idx_application` (`application_id`),
  ADD KEY `idx_date` (`visit_date`);

--
-- Indexes for table `sms_logs`
--
ALTER TABLE `sms_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_recipient` (`recipient_user_id`);

--
-- Indexes for table `tinkhundla`
--
ALTER TABLE `tinkhundla`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_region_id` (`region_id`),
  ADD KEY `idx_code` (`code`);

--
-- Indexes for table `training_register`
--
ALTER TABLE `training_register`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id_number` (`id_number`),
  ADD KEY `region_id` (`region_id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_id_number` (`id_number`),
  ADD KEY `idx_names` (`first_name`,`surname`),
  ADD KEY `idx_gender` (`gender`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `tinkhundla_id` (`tinkhundla_id`),
  ADD KEY `umphakatsi_id` (`umphakatsi_id`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_region_id` (`region_id`),
  ADD KEY `idx_email` (`email`);

--
-- Indexes for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `user_notification_preferences`
--
ALTER TABLE `user_notification_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_preferences` (`user_id`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_token` (`session_token`),
  ADD UNIQUE KEY `refresh_token` (`refresh_token`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_session_token` (`session_token`),
  ADD KEY `idx_expires_at` (`expires_at`),
  ADD KEY `idx_is_active` (`is_active`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `application_attachments`
--
ALTER TABLE `application_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `application_comments`
--
ALTER TABLE `application_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `application_workflow`
--
ALTER TABLE `application_workflow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `beneficiary_feedback`
--
ALTER TABLE `beneficiary_feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cdo_review_queue`
--
ALTER TABLE `cdo_review_queue`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `committees`
--
ALTER TABLE `committees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `committee_approvals`
--
ALTER TABLE `committee_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `committee_members`
--
ALTER TABLE `committee_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `eogs`
--
ALTER TABLE `eogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `eog_documents`
--
ALTER TABLE `eog_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `eog_expiry_notifications`
--
ALTER TABLE `eog_expiry_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `eog_members`
--
ALTER TABLE `eog_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `eog_temporal_activity`
--
ALTER TABLE `eog_temporal_activity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `eog_users`
--
ALTER TABLE `eog_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `forms`
--
ALTER TABLE `forms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `form_questions`
--
ALTER TABLE `form_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `form_responses`
--
ALTER TABLE `form_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `form_sections`
--
ALTER TABLE `form_sections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `imiphakatsi`
--
ALTER TABLE `imiphakatsi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=344;

--
-- AUTO_INCREMENT for table `impact_assessments`
--
ALTER TABLE `impact_assessments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `member_verification_issues`
--
ALTER TABLE `member_verification_issues`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `otps`
--
ALTER TABLE `otps`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_milestones`
--
ALTER TABLE `project_milestones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `site_visits`
--
ALTER TABLE `site_visits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sms_logs`
--
ALTER TABLE `sms_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tinkhundla`
--
ALTER TABLE `tinkhundla`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `training_register`
--
ALTER TABLE `training_register`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `user_notification_preferences`
--
ALTER TABLE `user_notification_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=219;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`),
  ADD CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`);

--
-- Constraints for table `application_attachments`
--
ALTER TABLE `application_attachments`
  ADD CONSTRAINT `application_attachments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `application_attachments_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `application_comments`
--
ALTER TABLE `application_comments`
  ADD CONSTRAINT `application_comments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `application_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `application_comments_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `application_comments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `application_workflow`
--
ALTER TABLE `application_workflow`
  ADD CONSTRAINT `application_workflow_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `application_workflow_ibfk_2` FOREIGN KEY (`actioned_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `beneficiary_feedback`
--
ALTER TABLE `beneficiary_feedback`
  ADD CONSTRAINT `beneficiary_feedback_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cdo_review_queue`
--
ALTER TABLE `cdo_review_queue`
  ADD CONSTRAINT `cdo_review_queue_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cdo_review_queue_ibfk_2` FOREIGN KEY (`assigned_cdo_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `committees`
--
ALTER TABLE `committees`
  ADD CONSTRAINT `committees_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `committees_ibfk_2` FOREIGN KEY (`tinkhundla_id`) REFERENCES `tinkhundla` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `committees_ibfk_3` FOREIGN KEY (`umphakatsi_id`) REFERENCES `imiphakatsi` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `committee_approvals`
--
ALTER TABLE `committee_approvals`
  ADD CONSTRAINT `committee_approvals_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `committee_approvals_ibfk_2` FOREIGN KEY (`committee_id`) REFERENCES `committees` (`id`),
  ADD CONSTRAINT `committee_approvals_ibfk_3` FOREIGN KEY (`committee_member_id`) REFERENCES `committee_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `committee_approvals_ibfk_4` FOREIGN KEY (`signature_otp_id`) REFERENCES `otps` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `committee_members`
--
ALTER TABLE `committee_members`
  ADD CONSTRAINT `committee_members_ibfk_1` FOREIGN KEY (`committee_id`) REFERENCES `committees` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `committee_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `email_logs`
--
ALTER TABLE `email_logs`
  ADD CONSTRAINT `email_logs_ibfk_1` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `eogs`
--
ALTER TABLE `eogs`
  ADD CONSTRAINT `eogs_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `eogs_ibfk_2` FOREIGN KEY (`tinkhundla_id`) REFERENCES `tinkhundla` (`id`),
  ADD CONSTRAINT `eogs_ibfk_3` FOREIGN KEY (`umphakatsi_id`) REFERENCES `imiphakatsi` (`id`),
  ADD CONSTRAINT `eogs_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `eog_documents`
--
ALTER TABLE `eog_documents`
  ADD CONSTRAINT `eog_documents_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `eog_expiry_notifications`
--
ALTER TABLE `eog_expiry_notifications`
  ADD CONSTRAINT `eog_expiry_notifications_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eog_expiry_notifications_ibfk_2` FOREIGN KEY (`email_log_id`) REFERENCES `email_logs` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `eog_members`
--
ALTER TABLE `eog_members`
  ADD CONSTRAINT `eog_members_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eog_members_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `eog_temporal_activity`
--
ALTER TABLE `eog_temporal_activity`
  ADD CONSTRAINT `eog_temporal_activity_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eog_temporal_activity_ibfk_2` FOREIGN KEY (`performed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `eog_users`
--
ALTER TABLE `eog_users`
  ADD CONSTRAINT `eog_users_ibfk_1` FOREIGN KEY (`eog_id`) REFERENCES `eogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `eog_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `forms`
--
ALTER TABLE `forms`
  ADD CONSTRAINT `forms_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `form_questions`
--
ALTER TABLE `form_questions`
  ADD CONSTRAINT `form_questions_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `form_sections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `form_questions_ibfk_2` FOREIGN KEY (`conditional_question_id`) REFERENCES `form_questions` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `form_responses`
--
ALTER TABLE `form_responses`
  ADD CONSTRAINT `form_responses_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `form_responses_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `form_questions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `form_responses_ibfk_3` FOREIGN KEY (`answered_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `form_sections`
--
ALTER TABLE `form_sections`
  ADD CONSTRAINT `form_sections_ibfk_1` FOREIGN KEY (`form_id`) REFERENCES `forms` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `form_sections_ibfk_2` FOREIGN KEY (`parent_section_id`) REFERENCES `form_sections` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `imiphakatsi`
--
ALTER TABLE `imiphakatsi`
  ADD CONSTRAINT `imiphakatsi_ibfk_1` FOREIGN KEY (`tinkhundla_id`) REFERENCES `tinkhundla` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `impact_assessments`
--
ALTER TABLE `impact_assessments`
  ADD CONSTRAINT `impact_assessments_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `impact_assessments_ibfk_2` FOREIGN KEY (`assessor_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `member_verification_issues`
--
ALTER TABLE `member_verification_issues`
  ADD CONSTRAINT `member_verification_issues_ibfk_1` FOREIGN KEY (`eog_member_id`) REFERENCES `eog_members` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `member_verification_issues_ibfk_2` FOREIGN KEY (`training_register_id`) REFERENCES `training_register` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `member_verification_issues_ibfk_3` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `member_verification_issues_ibfk_4` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `messages_ibfk_4` FOREIGN KEY (`related_application_id`) REFERENCES `applications` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `otps`
--
ALTER TABLE `otps`
  ADD CONSTRAINT `otps_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `project_milestones`
--
ALTER TABLE `project_milestones`
  ADD CONSTRAINT `project_milestones_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `site_visits`
--
ALTER TABLE `site_visits`
  ADD CONSTRAINT `site_visits_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `site_visits_ibfk_2` FOREIGN KEY (`visitor_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `sms_logs`
--
ALTER TABLE `sms_logs`
  ADD CONSTRAINT `sms_logs_ibfk_1` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tinkhundla`
--
ALTER TABLE `tinkhundla`
  ADD CONSTRAINT `tinkhundla_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `training_register`
--
ALTER TABLE `training_register`
  ADD CONSTRAINT `training_register_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `training_register_ibfk_2` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`tinkhundla_id`) REFERENCES `tinkhundla` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `users_ibfk_3` FOREIGN KEY (`umphakatsi_id`) REFERENCES `imiphakatsi` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  ADD CONSTRAINT `user_activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_notification_preferences`
--
ALTER TABLE `user_notification_preferences`
  ADD CONSTRAINT `user_notification_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
