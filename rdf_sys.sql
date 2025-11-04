-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 04, 2025 at 12:00 AM
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
(1, 1, 5, 'RDF-2025-0001', 'PROCUREMENT_LEVEL', 81.81, 'approved', '2025-10-30 16:36:11', NULL, 200000.00, NULL, 0.00, '2025-10-28 21:37:11', '2025-11-03 14:47:33'),
(4, 1, 5, 'RDF-2025-000002', 'EOG_LEVEL', 0.00, 'draft', NULL, NULL, NULL, NULL, 0.00, '2025-10-29 20:38:07', '2025-10-29 20:38:07'),
(5, 1, 5, 'RDF-2025-000003', 'EOG_LEVEL', 0.00, 'draft', NULL, NULL, NULL, NULL, 0.00, '2025-11-01 11:42:09', '2025-11-01 11:42:09'),
(6, 1, 5, 'HHO-2025-000004', 'EOG_LEVEL', 10.71, 'draft', NULL, NULL, NULL, NULL, 0.00, '2025-11-02 19:56:15', '2025-11-03 15:06:17');

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

--
-- Dumping data for table `application_comments`
--

INSERT INTO `application_comments` (`id`, `application_id`, `user_id`, `workflow_level`, `comment_type`, `comment_text`, `parent_comment_id`, `is_internal`, `created_at`) VALUES
(1, 1, 1, 'MINISTRY_LEVEL', 'return_reason', 'Fix Q3', NULL, 0, '2025-10-30 19:43:30'),
(2, 1, 1, 'CDO_LEVEL', 'return_reason', 'returned', NULL, 0, '2025-10-31 10:13:49'),
(3, 1, 1, 'INKHUNDLA_LEVEL', 'return_reason', 'Testing OTP', NULL, 0, '2025-11-01 20:20:47'),
(4, 1, 24, 'INKHUNDLA_LEVEL', 'return_reason', 'Fix', NULL, 0, '2025-11-01 21:15:00'),
(5, 1, 1, 'RDFC_LEVEL', 'return_reason', 'Approve', NULL, 0, '2025-11-03 10:08:44'),
(7, 1, 29, 'RDFTC_LEVEL', 'recommendation', 'Approved by Fana Dlamini (RDFTC)', NULL, 0, '2025-11-03 11:04:02'),
(8, 1, 30, 'RDFC_LEVEL', 'recommendation', 'Good Project', NULL, 0, '2025-11-03 11:33:42'),
(9, 1, 1, 'PROCUREMENT_LEVEL', 'return_reason', 'Approve Application First', NULL, 0, '2025-11-03 13:43:15'),
(10, 1, 31, 'PS_LEVEL', 'return_reason', 'Text approval', NULL, 0, '2025-11-03 13:51:48');

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

--
-- Dumping data for table `application_workflow`
--

INSERT INTO `application_workflow` (`id`, `application_id`, `from_level`, `to_level`, `action`, `comments`, `actioned_by`, `actioned_at`) VALUES
(1, 1, 'EOG_LEVEL', 'MINISTRY_LEVEL', 'submit', 'Application submitted by EOG', 17, '2025-10-30 16:36:11'),
(2, 1, 'MINISTRY_LEVEL', 'EOG_LEVEL', 'return', 'Fix Q3', 1, '2025-10-30 19:43:30'),
(3, 1, 'EOG_LEVEL', 'EOG_LEVEL', '', 'Application resubmitted after corrections', 17, '2025-10-30 20:19:58'),
(4, 1, 'EOG_LEVEL', 'MINISTRY_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 17, '2025-10-30 20:49:35'),
(6, 1, 'MINISTRY_LEVEL', 'MICROPROJECTS_LEVEL', '', 'Advanced to next level', 11, '2025-10-31 08:49:33'),
(7, 1, 'MICROPROJECTS_LEVEL', 'CDO_LEVEL', '', 'Advanced to next level', 22, '2025-10-31 08:56:26'),
(8, 1, 'MICROPROJECTS_LEVEL', 'CDO_LEVEL', '', 'Advanced to next level', 22, '2025-10-31 09:25:22'),
(9, 1, 'CDO_LEVEL', 'EOG_LEVEL', 'return', 'returned', 1, '2025-10-31 10:13:49'),
(10, 1, 'EOG_LEVEL', 'MINISTRY_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 17, '2025-10-31 10:16:39'),
(11, 1, 'MINISTRY_LEVEL', 'MICROPROJECTS_LEVEL', '', 'Advanced to next level', 11, '2025-10-31 10:40:34'),
(12, 1, 'MICROPROJECTS_LEVEL', 'CDO_LEVEL', '', 'Advanced to next level', 22, '2025-10-31 10:40:59'),
(13, 1, 'CDO_LEVEL', 'UMPHAKATSI_LEVEL', '', 'Advanced to next level', 18, '2025-10-31 10:42:55'),
(14, 1, 'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', '', 'Advanced to next level', 23, '2025-11-01 18:53:46'),
(15, 1, 'INKHUNDLA_LEVEL', 'UMPHAKATSI_LEVEL', 'return', 'Testing OTP', 1, '2025-11-01 20:20:47'),
(16, 1, 'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 23, '2025-11-01 20:22:06'),
(17, 1, 'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', '', 'Advanced to next level', 23, '2025-11-01 21:02:07'),
(18, 1, 'INKHUNDLA_LEVEL', 'UMPHAKATSI_LEVEL', 'return', 'Fix', 24, '2025-11-01 21:15:00'),
(19, 1, 'UMPHAKATSI_LEVEL', 'INKHUNDLA_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 23, '2025-11-01 21:16:39'),
(20, 1, 'INKHUNDLA_LEVEL', 'RDFTC_LEVEL', '', 'Advanced to next level', 24, '2025-11-02 18:20:32'),
(21, 1, 'RDFTC_LEVEL', 'RDFC_LEVEL', '', 'Advanced to next level', 29, '2025-11-03 09:44:22'),
(22, 1, 'RDFC_LEVEL', 'RDFTC_LEVEL', 'return', 'Approve', 1, '2025-11-03 10:08:44'),
(23, 1, 'RDFTC_LEVEL', 'RDFC_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 29, '2025-11-03 11:04:56'),
(24, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Advanced to next level', 30, '2025-11-03 11:34:36'),
(25, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 13:09:49'),
(26, 1, 'PROCUREMENT_LEVEL', 'PS_LEVEL', 'return', 'Approve Application First', 1, '2025-11-03 13:43:15'),
(27, 1, 'PS_LEVEL', 'RDFC_LEVEL', 'return', 'Text approval', 31, '2025-11-03 13:51:48'),
(28, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Application resubmitted after corrections and advanced to next level', 30, '2025-11-03 13:53:55'),
(29, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Advanced to next level', 30, '2025-11-03 14:00:58'),
(30, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Advanced to next level', 30, '2025-11-03 14:06:27'),
(31, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 14:21:13'),
(32, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Advanced to next level', 30, '2025-11-03 14:32:13'),
(33, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 14:34:34'),
(34, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 14:38:45'),
(35, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 14:42:42'),
(36, 1, 'RDFC_LEVEL', 'PS_LEVEL', '', 'Advanced to next level', 30, '2025-11-03 14:46:51'),
(37, 1, 'PS_LEVEL', 'PROCUREMENT_LEVEL', '', 'Advanced to next level', 31, '2025-11-03 14:47:33');

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
(2, 2, 1, 'medium', 'in_review', NULL, '2025-11-03 13:03:05', NULL, '2025-10-28 14:20:13', '2025-11-03 13:03:05');

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

--
-- Dumping data for table `committees`
--

INSERT INTO `committees` (`id`, `name`, `type`, `region_id`, `tinkhundla_id`, `umphakatsi_id`, `is_active`, `created_at`) VALUES
(1, 'Hhohho CDC', 'CDC', 1, 1, 1, 1, '2025-10-31 12:01:22'),
(2, 'Timphisini CDC', 'INKHUNDLA_COUNCIL', 1, 15, 77, 1, '2025-11-01 08:52:00'),
(3, 'RDFTC', 'RDFTC', 1, 11, 58, 1, '2025-11-03 07:25:16'),
(4, 'RDFC', 'RDFC', 1, 6, 28, 1, '2025-11-03 07:25:54');

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

--
-- Dumping data for table `committee_approvals`
--

INSERT INTO `committee_approvals` (`id`, `application_id`, `committee_id`, `committee_member_id`, `workflow_level`, `signature_otp_id`, `decision`, `comments`, `signed_at`) VALUES
(3, 1, 3, 3, 'UMPHAKATSI_LEVEL', 13, 'approved', 'Approved', '2025-11-03 11:04:02'),
(4, 1, 4, 4, 'UMPHAKATSI_LEVEL', NULL, 'approved', 'Good Project', '2025-11-03 11:33:42');

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
  `status` varchar(50) DEFAULT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `committee_members`
--

INSERT INTO `committee_members` (`id`, `committee_id`, `user_id`, `position`, `is_chairperson`, `status`, `joined_at`) VALUES
(1, 1, 23, 'Chairperson', 1, 'active', '2025-10-31 13:04:35'),
(2, 2, 24, 'MP', 1, 'active', '2025-11-01 18:58:12'),
(3, 3, 29, 'Technician', 1, 'active', '2025-11-03 09:41:47'),
(4, 4, 30, 'Chairman', 1, NULL, '2025-11-03 11:11:33');

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
(6, 'olwethudlamin10@gmail.com', 19, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Inana Mainze Meal ,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> temp_20251028_9868</li>\n      <li><strong>Temporary Password:</strong> Y%Mcc41hwC</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-28 13:23:31', '2025-10-28 13:23:31'),
(7, 'olwethu10@gmail.com', 20, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Siyatfutfuka ,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> temp_20251030_6156</li>\n      <li><strong>Temporary Password:</strong> 8aFd4(#$Ay</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-30 13:39:40', '2025-10-30 13:39:40'),
(8, 'olwethudlamini10@gmail.com', 21, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Siyatfutfuka ,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> temp_20251030_2065</li>\n      <li><strong>Temporary Password:</strong> 7Q%IbFi!Cp</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-10-30 14:07:28', '2025-10-30 14:07:28'),
(9, 'wakhiwakhi1@outlook.com', 18, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Olwethu Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from MICROPROJECTS_LEVEL to CDO_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: CDO_LEVEL</p>\n      <p>Progress: 27.27%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-10-31 08:57:02', '2025-10-31 08:57:02'),
(10, 'wakhiwakhi1@outlook.com', 18, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Olwethu Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from MICROPROJECTS_LEVEL to CDO_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: CDO_LEVEL</p>\n      <p>Progress: 27.27%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-10-31 09:25:27', '2025-10-31 09:25:27'),
(11, 'cynthia.makhabane9044@gmail.com', 22, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Cynthia Makhabane,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from MINISTRY_LEVEL to MICROPROJECTS_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: MICROPROJECTS_LEVEL</p>\n      <p>Progress: 18.18%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-10-31 10:40:38', '2025-10-31 10:40:38'),
(12, 'wakhiwakhi1@outlook.com', 18, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Olwethu Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from MICROPROJECTS_LEVEL to CDO_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: CDO_LEVEL</p>\n      <p>Progress: 27.27%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-10-31 10:41:02', '2025-10-31 10:41:02'),
(13, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">745083</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:27:49', '2025-11-01 20:27:49'),
(14, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">637178</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:33:57', '2025-11-01 20:33:57'),
(15, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">319160</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:33:59', '2025-11-01 20:33:59'),
(16, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">872567</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:49:35', '2025-11-01 20:49:35'),
(17, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">109210</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:53:19', '2025-11-01 20:53:19'),
(18, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">420572</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 20:56:19', '2025-11-01 20:56:19'),
(19, 'mbosibandze@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mbongeni Goje,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">991590</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 21:01:45', '2025-11-01 21:01:45'),
(20, 'terencesimelane@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mr. T Mnguni,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">648944</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-01 21:18:21', '2025-11-01 21:18:21'),
(21, 'terencesimelane@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mr. T Mnguni,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">129894</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-02 17:09:14', '2025-11-02 17:09:14'),
(22, 'terencesimelane@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Mr. T Mnguni,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">650164</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-02 18:20:09', '2025-11-02 18:20:09'),
(23, 'mbongeni@realnet.co.sz', 29, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Fana Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> Fana</li>\n      <li><strong>Temporary Password:</strong> HCGFi83lwPa$</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-11-03 09:39:34', '2025-11-03 09:39:34'),
(24, 'mbongeni@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Fana Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">129392</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 09:44:08', '2025-11-03 09:44:08'),
(25, 'mbongeni@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Fana Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">482612</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 10:24:34', '2025-11-03 10:24:34'),
(26, 'mbongeni@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Fana Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">568932</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 10:43:26', '2025-11-03 10:43:26'),
(27, 'mbongeni@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Fana Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">672487</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 10:54:55', '2025-11-03 10:54:55'),
(28, 'olwethu@realnet.co.sz', 30, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Owami Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> Owami</li>\n      <li><strong>Temporary Password:</strong> password123.</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-11-03 11:11:08', '2025-11-03 11:11:08'),
(29, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">672871</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 11:33:18', '2025-11-03 11:33:18'),
(30, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">562142</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 11:34:10', '2025-11-03 11:34:10'),
(31, 'makhabanecynthia@gmail.com', 31, 'Welcome to the RDF System', '\n    <h1>Welcome to the RDF System</h1>\n    <p>Hello Bongiwe Dlamini,</p>\n    <p>Your account has been created successfully. Here are your credentials:</p>\n    <ul>\n      <li><strong>Username:</strong> Bongiwe</li>\n      <li><strong>Temporary Password:</strong> password123.</li>\n    </ul>\n    <p>Please log in and change your password as soon as possible.</p>\n    <p>Thank you,</p>\n    <p>The RDF System Team</p>\n  ', 'sent', NULL, '2025-11-03 13:05:57', '2025-11-03 13:05:57'),
(32, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">560359</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 13:53:18', '2025-11-03 13:53:18'),
(33, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">133366</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 13:55:13', '2025-11-03 13:55:13'),
(34, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">118122</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:00:45', '2025-11-03 14:00:45'),
(35, 'makhabanecynthia@gmail.com', 31, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Bongiwe Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from RDFC_LEVEL to PS_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: PS_LEVEL</p>\n      <p>Progress: 72.72%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-11-03 14:01:01', '2025-11-03 14:01:01'),
(36, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">893528</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:06:10', '2025-11-03 14:06:10'),
(37, 'makhabanecynthia@gmail.com', 31, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Bongiwe Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from RDFC_LEVEL to PS_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: PS_LEVEL</p>\n      <p>Progress: 72.72%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-11-03 14:06:30', '2025-11-03 14:06:30'),
(38, 'makhabanecynthia@gmail.com', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Bongiwe Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">892773</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:19:39', '2025-11-03 14:19:39'),
(39, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">443206</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:30:23', '2025-11-03 14:30:23'),
(40, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">496133</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:32:01', '2025-11-03 14:32:01'),
(41, 'makhabanecynthia@gmail.com', 31, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Bongiwe Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from RDFC_LEVEL to PS_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: PS_LEVEL</p>\n      <p>Progress: 72.72%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-11-03 14:32:16', '2025-11-03 14:32:16'),
(42, 'olwethu@realnet.co.sz', NULL, 'Committee Verification - RDF-2025-0001', '\n        <h1>Committee Member Verification</h1>\n        <p>Hello Owami Dlamini,</p>\n        <p>You have requested to advance application <strong>RDF-2025-0001</strong> (Timphisini Beehives).</p>\n        <p>Your verification code is: <strong style=\"font-size: 24px; color: #2563eb;\">972204</strong></p>\n        <p>This code will expire in 10 minutes.</p>\n        <p>If you did not request this code, please ignore this email.</p>\n        <p>Thank you,</p>\n        <p>The RDF System</p>\n        ', 'sent', NULL, '2025-11-03 14:46:30', '2025-11-03 14:46:30'),
(43, 'makhabanecynthia@gmail.com', 31, 'RDF System - Application RDF-2025-0001 Update', '\n      <h1>Application Update</h1>\n      <p>Hello Bongiwe Dlamini,</p>\n      <p>Application <strong>RDF-2025-0001</strong> has been advanced to your level.</p>\n      <p><strong>Comment:</strong> The application has been advanced from RDFC_LEVEL to PS_LEVEL.</p>\n      <p>Current status: submitted</p>\n      <p>Current level: PS_LEVEL</p>\n      <p>Progress: 72.72%</p>\n      <p>Thank you,</p>\n      <p>The RDF System Team</p>\n    ', 'sent', NULL, '2025-11-03 14:46:54', '2025-11-03 14:46:54');

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
(2, 'Inana Mainze Meal', 'Cooperative', '543211', 'olwethudlamin10@gmail.com', '26878900987', 1, 1, 1, 15, 'pending_verification', '2025-11-27 13:23:26', NULL, NULL, NULL, '2025-10-28 13:23:26', '2025-10-28 14:20:13'),
(5, 'Siyatfutfuka', 'Association', '21413', 'olwethudlamini10@gmail.com', '+26876112233', 1, 13, 70, 27, 'temporary', '2025-11-29 14:07:24', NULL, NULL, NULL, '2025-10-30 14:07:24', '2025-10-30 14:07:24');

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
  `mime_type` varchar(150) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `eog_documents`
--

INSERT INTO `eog_documents` (`id`, `eog_id`, `document_type`, `file_name`, `file_path`, `file_size`, `mime_type`, `status`, `uploaded_at`) VALUES
(1, 1, 'constitution', 'Application Letter Sibusiso Dif Simelane.pdf', 'uploads\\eog_documents\\1\\constitution\\constitution-1761495860591-200679727.pdf', 10534, NULL, NULL, '2025-10-26 16:24:20'),
(2, 1, 'recognition_letter', 'Application_Trainig Center Dif.pdf', 'uploads\\eog_documents\\1\\recognition_letter\\recognition_letter-1761495880657-837100703.pdf', 66940, NULL, NULL, '2025-10-26 16:24:40'),
(3, 1, 'articles', 'Application St Theresa - Sibusiso.pdf', 'uploads\\eog_documents\\1\\articles\\articles-1761495887045-881170275.pdf', 66093, NULL, NULL, '2025-10-26 16:24:47'),
(4, 1, 'form_j', 'Cover letter - Sibusio Simelane.pdf', 'uploads\\eog_documents\\1\\form_j\\form_j-1761495890969-727506227.pdf', 65953, NULL, NULL, '2025-10-26 16:24:51'),
(5, 1, 'certificate', 'cover page.pdf', 'uploads\\eog_documents\\1\\certificate\\certificate-1761495895506-27803107.pdf', 585855, NULL, NULL, '2025-10-26 16:24:55'),
(7, 1, 'member_list', 'sampling.csv', 'uploads/eog_documents/1/member_list/member_list-1761499523039-767085618.csv', 1669, NULL, NULL, '2025-10-26 17:25:23'),
(8, 2, 'constitution', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/constitution/constitution-1761658392355-951931451.pdf', 63614, NULL, NULL, '2025-10-28 13:33:12'),
(9, 2, 'recognition_letter', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/recognition_letter/recognition_letter-1761658397824-706541221.pdf', 63614, NULL, NULL, '2025-10-28 13:33:17'),
(10, 2, 'articles', 'Application Letter - Mfundo Masilela.pdf', 'uploads/eog_documents/2/articles/articles-1761658404002-26313455.pdf', 63614, NULL, NULL, '2025-10-28 13:33:24'),
(11, 2, 'form_j', 'cover page.pdf', 'uploads/eog_documents/2/form_j/form_j-1761660038769-139348813.pdf', 585855, NULL, NULL, '2025-10-28 14:00:38'),
(12, 2, 'certificate', 'Blue Breeze Investment.pdf', 'uploads/eog_documents/2/certificate/certificate-1761660045333-448415201.pdf', 64020, NULL, NULL, '2025-10-28 14:00:45'),
(13, 2, 'member_list', 'facilitySheet_updated.xlsx', 'uploads/eog_documents/2/member_list/member_list-1761660052702-72902592.xlsx', 81859, NULL, NULL, '2025-10-28 14:00:52'),
(19, 5, 'constitution', 'form.pdf', 'uploads\\temp_eog_documents\\constitution-1761833244032-430567432.pdf', 56449, 'application/pdf', 'pending_review', '2025-10-30 14:07:24'),
(20, 5, 'recognition_letter', 'form.pdf', 'uploads\\temp_eog_documents\\recognition_letter-1761833244032-634333144.pdf', 56449, 'application/pdf', 'pending_review', '2025-10-30 14:07:24'),
(21, 5, 'articles', 'form.pdf', 'uploads\\temp_eog_documents\\articles-1761833244040-455712047.pdf', 56449, 'application/pdf', 'pending_review', '2025-10-30 14:07:24'),
(22, 5, 'form_j', 'form.pdf', 'uploads\\temp_eog_documents\\form_j-1761833244041-571792038.pdf', 56449, 'application/pdf', 'pending_review', '2025-10-30 14:07:24'),
(23, 5, 'certificate', 'form.pdf', 'uploads\\temp_eog_documents\\certificate-1761833244048-352564780.pdf', 56449, 'application/pdf', 'pending_review', '2025-10-30 14:07:24'),
(24, 5, 'member_list', 'cover page.pdf', 'uploads\\temp_eog_documents\\members_list-1761833244055-722536736.pdf', 585855, 'application/pdf', 'pending_review', '2025-10-30 14:07:24');

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
(51, 2, '', 'Submitted EOG for CDO review', 19, '::ffff:127.0.0.1', '2025-10-28 14:20:13'),
(53, 5, '', 'EOG created account with documents uploaded', 21, '::ffff:127.0.0.1', '2025-10-30 14:07:24'),
(54, 2, '', 'SUPER_USER started reviewing EOG', 1, '::ffff:127.0.0.1', '2025-11-03 13:03:05');

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
(2, 2, 19, 1, '2025-10-28 13:23:26'),
(4, 5, 21, 1, '2025-10-30 14:07:24');

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
(44, 7, '5.2. IF YES FROM WHO?', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 43, 'true', NULL, NULL, NULL, NULL, '2025-10-27 19:13:16', NULL, NULL, NULL, 1, 1),
(45, 7, '5.3. HOW MUCH CASH HAVE YOU SPENT TO-DATE ON THE PROJECT?', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:14:12', NULL, NULL, NULL, 1, 1),
(46, 7, ' 5.4. HOW MUCH DO YOU HAVE IN YOUR SAVINGS ACCOUNT? (E)', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, 'In Emalangeni ', NULL, NULL, '2025-10-27 19:15:19', NULL, NULL, NULL, 1, 1),
(47, 7, '5.5. FINANCIAL BREAKDOWN OFTHEPROJECT', 'FILE', NULL, 1, 4, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,MICROPROJECTS', 37, 'Infrastructure Development Project', NULL, 'Total construction costs if it is an Infrastructure Project - Projections must include contribution by the Applicant', NULL, NULL, '2025-10-27 19:21:40', NULL, NULL, NULL, 1, 1),
(48, 8, '6.0.1 DETAILS OF INCOME AND EXPENDITURE', 'FILE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 37, 'Income Generating Project', NULL, NULL, NULL, NULL, '2025-10-27 19:24:36', NULL, NULL, NULL, 1, 1),
(49, 8, '6.1. WHAT IS YOUR MARKET?', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:25:49', NULL, NULL, NULL, 1, 1),
(50, 8, '6.2. DO YOU HAVE ANY SALES AGREEMENT WITH YOUR MARKET?', 'BOOLEAN', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:26:46', NULL, NULL, NULL, 1, 1),
(51, 8, '6.2.1. PLEASE ATTACH A CONFIRIMATION LETTER FROM THE MARKET', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', 50, 'true', NULL, NULL, NULL, NULL, '2025-10-27 19:27:38', NULL, NULL, NULL, 1, 1),
(52, 8, '7.1. WHO WILL OPERATEOR MANAGE THEPROJECT AFTER ITS COMPLETION?', 'TEXT', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:28:40', NULL, NULL, NULL, 1, 1),
(53, 9, '7.1. WHO WILL OPERATE OR MANAGE THE PROJECT AFTER ITS COMPLETION?', 'TEXT', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:29:28', NULL, NULL, NULL, 1, 1),
(54, 9, ' 7.2. WHAT ARE HIS/HER EXPERIENCES AND QUALIFICATIONS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:04', NULL, NULL, NULL, 1, 1),
(55, 9, '7.3. HOW WILL YOURAISE THE FUNDS FOR MAINTENANCE', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:29', NULL, NULL, NULL, 1, 1),
(56, 9, '7.4. WHAT WILL BE THE TOTAL COST PER YEAR?', 'DECIMAL', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:30:53', NULL, NULL, NULL, 1, 1),
(57, 10, '8.1. ATTACH YOUR PLAN BELOW', 'FILE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'EOG,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:33:12', NULL, NULL, NULL, 1, 1),
(58, 11, ' 9.1. GOVERNMENT LINE MINISTRY TECHNICIAN\'S COMMENTS.', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,LINE_MINISTRY', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:34:38', NULL, NULL, NULL, 1, 1),
(59, 11, '9.2. COMMUNITY DEVELOPMENT OFFICER\'S COMMENTS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,CDO', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:35:25', NULL, NULL, NULL, 1, 1),
(60, 11, '9.3. MICRO-PROJECTS\'TECHNICIANS COMMENTS', 'TEXTAREA', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'MICROPROJECTS,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 19:36:04', NULL, NULL, NULL, 1, 1),
(63, 13, '10.1.1 CHECKLIST BY BANDLANCANE AND DEVELOPMENT COMMITTEE', 'MULTISELECT', '[\"Are registered\\r in the Umphakatsi as a bona fide Eswatini organized group\",\"Community mobilization has been carried out by Community  Development Officers\",\"Involvement of line Ministry\",\"Availability of project design (from line ministry)\",\"Project will benefit the wider community\",\"Land/ site for the project is available and approved by umphakatsi\",\"Project is recommended for considerationby Inkhundla\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, 'If no, leave box unchecked', NULL, NULL, '2025-10-27 21:21:09', NULL, NULL, NULL, 1, 1),
(64, 15, '10.2.1. CDC Approvals', 'TABLE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 22:51:51', '\"[{\\\"name\\\":\\\"designation\\\",\\\"label\\\":\\\"Designation\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"fullname\\\",\\\"label\\\":\\\"Fullname\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"date\\\",\\\"label\\\":\\\"Date\\\",\\\"type\\\":\\\"DATE\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"id_no.\\\",\\\"label\\\":\\\"ID No.\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true}]\"', 3, 3, 1, 1),
(65, 15, 'PLEASE INSERT UMPHAKATSIOFFICIAL STANMP HERE.', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 23:00:18', NULL, NULL, NULL, 1, 1),
(66, 16, '10.3.1.  Confirmation by Inkhundla Council that the applicants', 'CHECKBOX', '[\"Are registered in the Inkhundlas a bona fide Eswatini Organized Group\",\"Went through Umphakatsi\",\"Community mobilization\\rhas been carried out by Community Development Officers\",\"Project has been technically appraised and viable\",\"Project will benefit the wider community and has at least ten members\",\"Land/ project site is available and approved by umphakatsi\",\"Project is a priority in the needs ofthe Inkhundla\",\"Project is recommended for appraisal by RDFTC\"]', 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'INKHUNDLA_COUNCIL,SUPER_USER', NULL, NULL, NULL, 'If no, leave box unchecked', NULL, NULL, '2025-10-27 23:04:51', NULL, NULL, NULL, 1, 1),
(67, 17, '10.4.1 Signatories', 'TABLE', NULL, 1, 0, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'INKHUNDLA_COUNCIL,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-27 23:09:05', '\"[{\\\"name\\\":\\\"designation\\\",\\\"label\\\":\\\"Designation\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"fullname\\\",\\\"label\\\":\\\"Fullname\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"date\\\",\\\"label\\\":\\\"Date\\\",\\\"type\\\":\\\"DATE\\\",\\\"is_required\\\":true},{\\\"name\\\":\\\"id_no\\\",\\\"label\\\":\\\"ID No\\\",\\\"type\\\":\\\"TEXT\\\",\\\"is_required\\\":true}]\"', 3, 3, 1, 1),
(68, 17, 'INKHUNDLA STAMP', 'FILE', NULL, 1, 1, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'SUPER_USER,INKHUNDLA_COUNCIL', NULL, NULL, NULL, 'sitembu senkhundla', NULL, NULL, '2025-10-27 23:09:50', NULL, NULL, NULL, 1, 1),
(69, 15, 'Bucopho Signature', 'SIGNATURE', NULL, 0, 2, 'EOG,CDO,CDC,LINE_MINISTRY,MICROPROJECTS,INKHUNDLA_COUNCIL,RDFTC,RDFC,PS,SUPER_USER', 'CDC,SUPER_USER', NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-30 10:45:32', NULL, NULL, NULL, 1, 1);

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

--
-- Dumping data for table `form_responses`
--

INSERT INTO `form_responses` (`id`, `application_id`, `question_id`, `answer_text`, `answer_number`, `answer_date`, `answer_file_path`, `answered_by`, `answered_at`, `updated_at`) VALUES
(2, 1, 27, 'Timphisini Beehives', NULL, NULL, NULL, 1, '2025-10-29 19:06:58', '2025-11-02 18:53:42'),
(4, 1, 31, 'P.O. Box 13 Buhleni', NULL, NULL, NULL, 17, '2025-10-29 19:11:26', '2025-10-29 19:11:39'),
(5, 1, 32, 'Ludzibini, Timphisini, Hhohho', NULL, NULL, NULL, 1, '2025-10-29 19:11:42', '2025-11-02 18:54:12'),
(6, 1, 33, 'Chief Vilakati Ludzibini', NULL, NULL, NULL, 1, '2025-10-29 19:11:48', '2025-11-02 18:53:57'),
(7, 1, 28, 'Cooperative', NULL, NULL, NULL, 17, '2025-10-29 19:11:56', '2025-10-29 19:11:56'),
(8, 1, 34, NULL, 25.00, NULL, NULL, 17, '2025-10-29 19:12:05', '2025-10-29 19:12:05'),
(9, 1, 35, '[{\"designation\":\"Chairman\",\"name\":\"Sihlalo Dlamini\",\"id_no.\":\"0102048765645\",\"contact\":\"26876477563\"},{\"designation\":\"Treasure\",\"name\":\"Sandile Shonwe\",\"id_no.\":\"010203040506\",\"contact\":\"26876544352\"},{\"designation\":\"Secretary\",\"name\":\"Simanga Dlamini\",\"id_no.\":\"0112127646354\",\"contact\":\"26878988768\"},{\"designation\":\"Member\",\"name\":\"Tenele Dlomo\",\"id_no.\":\"0201017654345\",\"contact\":\"268765433423\"},{\"designation\":\"Member\",\"name\":\"Ayanda Mbuli\",\"id_no.\":\"0302016754342\",\"contact\":\"26876566788\"},{\"designation\":\"Member\",\"name\":\"Sabelo Khoza\",\"id_no.\":\"0012127676543\",\"contact\":\"26876544354\"},{\"designation\":\"Member\",\"name\":\"Mthokozisi Ndlela\",\"id_no.\":\"1902136765434\",\"contact\":\"26876589876\"},{\"designation\":\"Member\",\"name\":\"Simiso Dlamini\",\"id_no.\":\"1811119876554\",\"contact\":\"26879876545\"},{\"designation\":\"Member\",\"name\":\"Mbali Simelane\",\"id_no.\":\"0303015565432\",\"contact\":\"26876543988\"},{\"designation\":\"Member\",\"name\":\"Singiseni Mamba\",\"id_no.\":\"0502127865403\",\"contact\":\"26876577899\"}]', NULL, NULL, NULL, 17, '2025-10-29 19:21:43', '2025-10-30 16:34:03'),
(11, 1, 37, 'Income Generating Project', NULL, NULL, NULL, 17, '2025-10-30 00:14:11', '2025-10-30 12:38:07'),
(15, 1, 43, 'true', NULL, NULL, NULL, 1, '2025-10-30 10:02:49', '2025-10-30 10:04:29'),
(16, 1, 50, 'true', NULL, NULL, NULL, 1, '2025-10-30 10:07:20', '2025-10-30 10:07:24'),
(17, 1, 63, '{\"Are registered\\r in the Umphakatsi as a bona fide Eswatini organized group\":\"yes\",\"Community mobilization has been carried out by Community  Development Officers\":\"yes\",\"Involvement of line Ministry\":\"yes\",\"Availability of project design (from line ministry)\":\"yes\",\"Project will benefit the wider community\":\"yes\",\"Land/ site for the project is available and approved by umphakatsi\":\"yes\",\"Project is recommended for considerationby Inkhundla\":\"yes\"}', NULL, NULL, NULL, 23, '2025-10-30 10:29:52', '2025-11-01 17:57:58'),
(18, 1, 38, 'Bee keeping', NULL, NULL, NULL, 1, '2025-10-30 12:11:13', '2025-10-30 12:11:18'),
(19, 1, 36, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\blue_breeze.pdf', 17, '2025-10-30 12:26:01', '2025-10-30 12:36:14'),
(20, 1, 39, 'Hoticulture', NULL, NULL, NULL, 17, '2025-10-30 14:51:06', '2025-10-30 14:51:13'),
(21, 1, 40, 'Less jobs and less yield, no bees for pollination', NULL, NULL, NULL, 17, '2025-10-30 14:51:17', '2025-10-30 14:51:36'),
(22, 1, 41, 'All the community of Timphisini', NULL, NULL, NULL, 17, '2025-10-30 14:51:42', '2025-10-30 14:51:50'),
(23, 1, 42, 'To increase crop yield while icreasing jobs', NULL, NULL, NULL, 17, '2025-10-30 14:51:53', '2025-10-30 14:52:08'),
(24, 1, 44, 'UNICEF', NULL, NULL, NULL, 17, '2025-10-30 14:52:13', '2025-10-30 14:52:19'),
(25, 1, 45, NULL, 11948.00, NULL, NULL, 1, '2025-10-30 14:52:23', '2025-10-30 23:07:51'),
(26, 1, 46, NULL, 20000.00, NULL, NULL, 17, '2025-10-30 14:52:35', '2025-10-30 14:52:36'),
(27, 1, 48, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\Application_Trainig_Center_Dif.pdf', 17, '2025-10-30 14:52:53', '2025-10-30 14:52:53'),
(28, 1, 49, 'Shops', NULL, NULL, NULL, 17, '2025-10-30 14:53:00', '2025-10-30 14:53:00'),
(29, 1, 51, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\Application_Letter_Sibusiso_Dif_Simelane.pdf', 17, '2025-10-30 14:53:08', '2025-10-30 14:53:08'),
(30, 1, 52, 'Wandile', NULL, NULL, NULL, 17, '2025-10-30 14:53:12', '2025-10-30 14:53:13'),
(31, 1, 53, 'Wandile Ngwenya', NULL, NULL, NULL, 17, '2025-10-30 14:53:30', '2025-10-30 14:53:33'),
(32, 1, 55, 'Fundraising events', NULL, NULL, NULL, 17, '2025-10-30 14:53:54', '2025-10-30 14:54:02'),
(33, 1, 56, NULL, 30000.00, NULL, NULL, 17, '2025-10-30 14:54:07', '2025-10-30 14:54:08'),
(34, 1, 57, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\Blue_Breeze_Investment.pdf', 17, '2025-10-30 14:54:14', '2025-10-30 14:54:14'),
(35, 1, 58, 'Good to go', NULL, NULL, NULL, 11, '2025-10-30 23:02:01', '2025-10-31 08:21:03'),
(36, 1, 54, 'BSc Hoticulture', NULL, NULL, NULL, 1, '2025-10-30 23:08:00', '2025-11-02 18:56:52'),
(37, 1, 60, 'Project Looks Good', NULL, NULL, NULL, 22, '2025-10-31 08:56:17', '2025-10-31 08:56:22'),
(38, 1, 59, 'Looks Okay to me', NULL, NULL, NULL, 1, '2025-10-31 10:13:17', '2025-11-02 18:56:46'),
(39, 1, 65, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\ADIDAS2.png', 23, '2025-11-01 18:28:14', '2025-11-01 18:28:14'),
(40, 1, 64, '[{\"designation\":\"Chairman\",\"fullname\":\"Mbongeni Goje\",\"date\":\"2025-11-01\",\"id_no.\":\"0203048764563\"},{\"designation\":\"Bucopho\",\"fullname\":\"Simiso Ngwenya\",\"date\":\"2025-11-01\",\"id_no.\":\"9902023675475\"},{\"designation\":\"Chief\",\"fullname\":\"Sululu Dlamini\",\"date\":\"2025-11-01\",\"id_no.\":\"7701126710042\"}]', NULL, NULL, NULL, 23, '2025-11-01 18:36:54', '2025-11-01 18:41:45'),
(41, 1, 69, NULL, NULL, NULL, NULL, 23, '2025-11-01 18:39:51', '2025-11-01 18:39:51'),
(42, 1, 66, '{\"Are registered in the Inkhundlas a bona fide Eswatini Organized Group\":\"yes\",\"Went through Umphakatsi\":\"yes\",\"Community mobilization\\rhas been carried out by Community Development Officers\":\"yes\",\"Project has been technically appraised and viable\":\"yes\",\"Project will benefit the wider community and has at least ten members\":\"yes\",\"Land/ project site is available and approved by umphakatsi\":\"yes\",\"Project is a priority in the needs ofthe Inkhundla\":\"yes\",\"Project is recommended for appraisal by RDFTC\":\"yes\"}', NULL, NULL, NULL, 24, '2025-11-01 21:17:39', '2025-11-01 21:18:04'),
(43, 1, 67, '[{\"designation\":\"MP\",\"fullname\":\"Mr. T Simelane\",\"date\":\"2025-11-02\",\"id_no\":\"9807076710098\"},{\"designation\":\"Regional Secretary\",\"fullname\":\"Mrs Tfwala\",\"date\":\"2025-11-02\",\"id_no\":\"7711116100987\"},{\"designation\":\"Inkhundla Secretary\",\"fullname\":\"Hlobisile Gwebu\",\"date\":\"2025-11-02\",\"id_no\":\"8712217610056\"}]', NULL, NULL, NULL, 24, '2025-11-02 13:50:49', '2025-11-02 18:20:00'),
(44, 1, 68, NULL, NULL, NULL, 'uploads\\application_attachments\\1\\ADIDAS2_1762091617276.png', 24, '2025-11-02 13:53:37', '2025-11-02 13:53:37'),
(45, 6, 27, 'Timphisini Beehives', NULL, NULL, NULL, 17, '2025-11-03 15:06:08', '2025-11-03 15:06:08'),
(46, 6, 32, 'Ludzibini, Timphisini, Hhohho', NULL, NULL, NULL, 17, '2025-11-03 15:06:13', '2025-11-03 15:06:13'),
(47, 6, 33, 'Chief Vilakati Ludzibini', NULL, NULL, NULL, 17, '2025-11-03 15:06:16', '2025-11-03 15:06:16');

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
(5, 5, NULL, '3. PROJECT DETAILS', NULL, 2, NULL, '2025-10-27 14:18:46'),
(6, 5, NULL, '4. PROJECT FULL DESCRIPTION', 'INCLUDE SKETCH DIAGRAMS AS ATTACHEMENT WHERE APPLICABLE', 3, NULL, '2025-10-27 19:06:35'),
(7, 5, NULL, '5. CONTRIBUTIONS AND FINANCES', NULL, 4, NULL, '2025-10-27 19:10:40'),
(8, 5, NULL, ' 6. FOR INCOME GENERATING PROJECTS ANSWER BELOW', 'DETAILS OF INCOME AND EXPENDITURE OF THE PROPOSED PROJECT - THE APPLICANT MUST ATTACH A BUSINESS PLAN.', 5, NULL, '2025-10-27 19:22:51'),
(9, 5, NULL, '7. PROJECT MAINTAINENCE AND REPAIR', NULL, 6, NULL, '2025-10-27 19:28:14'),
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
  `status` varchar(50) DEFAULT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `attempts` int(11) DEFAULT 0,
  `max_attempts` int(11) DEFAULT 3,
  `is_used` tinyint(1) DEFAULT 0,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otps`
--

INSERT INTO `otps` (`id`, `user_id`, `otp_code`, `purpose`, `status`, `entity_type`, `entity_id`, `attempts`, `max_attempts`, `is_used`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 23, '637178', '', 'active', 'applications', 1, 0, 3, 0, '2025-11-01 20:43:53', NULL, '2025-11-01 20:33:53'),
(2, 23, '319160', '', 'active', 'applications', 1, 0, 3, 0, '2025-11-01 20:43:55', NULL, '2025-11-01 20:33:55'),
(3, 23, '872567', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-01 21:01:41', NULL, '2025-11-01 20:49:32'),
(4, 23, '109210', '', 'active', 'applications', 1, 0, 3, 0, '2025-11-01 21:03:14', NULL, '2025-11-01 20:53:14'),
(5, 23, '420572', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-01 21:01:11', NULL, '2025-11-01 20:56:13'),
(6, 23, '991590', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-01 21:02:07', NULL, '2025-11-01 21:01:41'),
(7, 24, '648944', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-02 17:08:58', NULL, '2025-11-01 21:18:17'),
(8, 24, '129894', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-02 18:20:04', NULL, '2025-11-02 17:08:58'),
(9, 24, '650164', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-02 18:20:32', NULL, '2025-11-02 18:20:04'),
(10, 29, '129392', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 09:44:22', NULL, '2025-11-03 09:44:04'),
(11, 29, '482612', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-03 10:43:22', NULL, '2025-11-03 10:24:29'),
(12, 29, '568932', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-03 10:54:52', NULL, '2025-11-03 10:43:22'),
(13, 29, '672487', 'verification', 'active', 'applications', 1, 0, 3, 0, '2025-11-03 11:04:52', NULL, '2025-11-03 10:54:52'),
(14, 30, '672871', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-03 11:34:07', NULL, '2025-11-03 11:33:15'),
(15, 30, '562142', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 11:34:36', NULL, '2025-11-03 11:34:07'),
(16, 30, '560359', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-03 13:55:10', NULL, '2025-11-03 13:53:14'),
(17, 30, '133366', 'verification', 'expired', 'applications', 1, 0, 3, 0, '2025-11-03 14:00:42', NULL, '2025-11-03 13:55:10'),
(18, 30, '118122', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 14:00:58', NULL, '2025-11-03 14:00:42'),
(19, 30, '893528', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 14:06:27', NULL, '2025-11-03 14:06:07'),
(20, 31, '892773', 'verification', 'active', 'applications', 1, 0, 3, 0, '2025-11-03 14:29:35', NULL, '2025-11-03 14:19:35'),
(21, 30, '443206', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 14:30:37', NULL, '2025-11-03 14:30:19'),
(22, 30, '496133', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 14:32:13', NULL, '2025-11-03 14:31:57'),
(23, 30, '972204', 'verification', 'used', 'applications', 1, 1, 3, 0, '2025-11-03 14:46:51', NULL, '2025-11-03 14:46:27');

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
(1, 'admin', 'admin@rdf.gov.sz', '$2b$12$B9N.Xon.UNL6Z1CmDe8/r.dWLhsbKSoRibvZuLxWoU7sWBE324/y.', 'SUPER_USER', 'Super  User', 'Administrator', '+26876000000', 'active', NULL, NULL, NULL, NULL, '2025-11-03 22:17:30', NULL, NULL, '2025-10-24 07:43:01', '2025-11-03 22:17:30', NULL),
(11, 'wandile', 'wakhiwakhi1@gmail.com', '$2b$12$CDJ1YR1X7FC56u3gPIprGO/avmb8OLOlCtCKWftKIxpwvq6/J2q.S', 'LINE_MINISTRY', 'Wandile', 'Ngwenya', '26876543212', 'active', 1, 2, 7, 'AGRIC', '2025-10-31 10:39:32', NULL, NULL, '2025-10-25 20:11:27', '2025-10-31 10:39:32', NULL),
(17, 'beehives', 'celimphilodlamini94@gmail.com', '$2b$12$rwMqQp1q0i4mYJH3HlkMYeniqSoecVksuFLeBaBnKCa8wCEP2VDYe', 'EOG', 'Timphisini Beehives', 'Cooperative', '79876543', 'active', 1, 15, 77, NULL, '2025-11-03 15:01:55', NULL, NULL, '2025-10-26 11:02:49', '2025-11-03 15:01:55', NULL),
(18, 'olwethu', 'wakhiwakhi1@outlook.com', '$2b$12$bXaXOndWnnX8cAESxCmp9OLkHBRfhkXpce14cv6.gZNFHsO8HR536', 'CDO', 'Olwethu', 'Dlamini', '+26878654321', 'active', 1, 15, 76, 'TINKHUNDLA', '2025-10-31 10:41:41', NULL, NULL, '2025-10-26 11:20:56', '2025-10-31 10:41:41', NULL),
(19, 'temp_20251028_9868', 'olwethudlamin10@gmail.com', '$2b$12$owdh2m1Khu.SO5HVm3h3J.uZND.clCGMZ9feB4AooiZUbX6mVLEX.', 'EOG', 'Inana Mainze Meal', 'Cooperative', '26878900987', 'temporary', 1, 1, 1, NULL, '2025-10-28 14:19:48', NULL, NULL, '2025-10-28 13:23:26', '2025-10-28 14:19:48', NULL),
(20, 'temp_20251030_6156', 'olwethu10@gmail.com', '$2b$12$R7Ht54Rg65KSLvixJUAYPezzLKw58GEa.43lvnkzEcPmxVCwzBnEC', 'EOG', 'Siyatfutfuka', 'Partnership', '+26876000000', 'temporary', 1, 13, 70, NULL, '2025-10-30 13:51:54', NULL, NULL, '2025-10-30 13:39:35', '2025-10-30 13:51:54', NULL),
(21, 'temp_20251030_2065', 'olwethudlamini10@gmail.com', '$2b$12$cGgvOPpB/FN2d5o8JXzzIOw1n.hKJZWWtQwH4vkcJBgDbwkMJz03e', 'EOG', 'Siyatfutfuka', 'Association', '+26876112233', 'temporary', 1, 13, 70, NULL, '2025-10-30 14:08:26', NULL, NULL, '2025-10-30 14:07:24', '2025-10-30 14:08:26', NULL),
(22, 'cynthia', 'cynthia.makhabane9044@gmail.com', '$2b$12$Bp24lF5uT8nCaaTXXW2cZedBSFSlFUVjTI/fonthrjOVTzl8WifDG', 'MICROPROJECTS', 'Cynthia', 'Makhabane', '26878900900', 'active', 3, 30, 160, 'TINKHUNDLA', '2025-11-03 22:57:14', NULL, NULL, '2025-10-31 08:54:02', '2025-11-03 22:57:14', NULL),
(23, 'Goje', 'mbosibandze@gmail.com', '$2b$12$rBbxl6E8gTCjuAG5qlNNJepOTIURWfhaPs4c5BcGzwuOBZ7e.2qH2', 'CDC', 'Mbongeni', 'Goje', '26876878980', 'active', 1, 15, 77, 'TINKHUNDLA', '2025-11-02 18:21:33', NULL, NULL, '2025-10-31 09:00:54', '2025-11-02 18:21:33', NULL),
(24, 'Mnguni', 'terencesimelane@gmail.com', '$2b$12$ZZeAK9yugB8jvtLS2.AUE.zMlUhTvZU1Q.Z6LJz3ck6b7rMzOP.Ke', 'INKHUNDLA_COUNCIL', 'Mr. T', 'Mnguni', '26879877564', 'active', 1, 15, 79, 'TINKHUNDLA', '2025-11-02 18:23:46', NULL, NULL, '2025-10-31 11:49:03', '2025-11-02 18:23:46', NULL),
(29, 'Fana', 'mbongeni@realnet.co.sz', '$2b$12$6nTmqAj5hC9hKsLQarH1UubGkmhTiZDv839MaKT8mZI96tzZtS8a.', 'RDFTC', 'Fana', 'Dlamini', '+26878678987', 'active', 1, 8, 36, 'TINKHUNDLA', '2025-11-03 13:52:06', NULL, NULL, '2025-11-03 09:39:30', '2025-11-03 13:52:06', NULL),
(30, 'Owami', 'olwethu@realnet.co.sz', '$2b$12$ypcUTDlIHu8bGcF1PxMeQeAzFl218Q2IpkoqZMfnwIMjIGw7Jx3me', 'RDFC', 'Owami', 'Dlamini', '+26879866454', 'active', 2, 23, 117, 'TINKHUNDLA', '2025-11-03 14:46:21', NULL, NULL, '2025-11-03 11:11:05', '2025-11-03 14:46:21', NULL),
(31, 'Bongiwe', 'makhabanecynthia@gmail.com', '$2b$12$fD0dbBSZyuwghshjYS0m5OLo2JkWpnBpqC.WURuRA1m6u2Z7eO6/q', 'PS', 'Bongiwe', 'Dlamini', '+26876890909', 'active', 1, 7, 33, 'TINKHUNDLA', '2025-11-03 22:58:20', NULL, NULL, '2025-11-03 13:05:54', '2025-11-03 22:58:20', NULL);

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
(23, 17, 'form_responses_saved', 'applications', 1, 'Saved 1 form responses (0 permission errors, 0 validation errors)', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-29 08:38:02'),
(24, 11, 'workflow_advanced', 'applications', 1, '{\"from\":\"MINISTRY_LEVEL\",\"to\":\"MICROPROJECTS_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 08:49:34'),
(25, 22, 'workflow_advanced', 'applications', 1, '{\"from\":\"MICROPROJECTS_LEVEL\",\"to\":\"CDO_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 08:56:26'),
(26, 22, 'workflow_advanced', 'applications', 1, '{\"from\":\"MICROPROJECTS_LEVEL\",\"to\":\"CDO_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 09:25:22'),
(27, 11, 'workflow_advanced', 'applications', 1, '{\"from\":\"MINISTRY_LEVEL\",\"to\":\"MICROPROJECTS_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 10:40:34'),
(28, 22, 'workflow_advanced', 'applications', 1, '{\"from\":\"MICROPROJECTS_LEVEL\",\"to\":\"CDO_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 10:40:59'),
(29, 18, 'workflow_advanced', 'applications', 1, '{\"from\":\"CDO_LEVEL\",\"to\":\"UMPHAKATSI_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-10-31 10:42:55'),
(30, 23, 'workflow_advanced', 'applications', 1, '{\"from\":\"UMPHAKATSI_LEVEL\",\"to\":\"INKHUNDLA_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-01 18:53:46'),
(31, 23, 'workflow_advanced', 'applications', 1, '{\"from\":\"UMPHAKATSI_LEVEL\",\"to\":\"INKHUNDLA_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-01 21:02:07'),
(32, 24, 'workflow_advanced', 'applications', 1, '{\"from\":\"INKHUNDLA_LEVEL\",\"to\":\"RDFTC_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-02 18:20:32'),
(33, 1, 'user_created', 'users', 29, '{\"role\":\"RDFTC\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 09:39:30'),
(34, 29, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFTC_LEVEL\",\"to\":\"RDFC_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 09:44:22'),
(36, 29, 'committee_approval', 'applications', 1, '{\"committee_type\":\"RDFTC\",\"committee_id\":3,\"workflow_level\":\"RDFTC_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 11:04:02'),
(37, 1, 'user_created', 'users', 30, '{\"role\":\"RDFC\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 11:11:05'),
(38, 30, 'committee_approval', 'applications', 1, '{\"committee_type\":\"RDFC\",\"committee_id\":4,\"workflow_level\":\"RDFC_LEVEL\"}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 11:33:42'),
(39, 30, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFC_LEVEL\",\"to\":\"PS_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 11:34:36'),
(40, 1, 'user_created', 'users', 31, '{\"role\":\"PS\",\"creator\":1}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 13:05:54'),
(41, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 13:09:49'),
(42, 30, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFC_LEVEL\",\"to\":\"PS_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:00:58'),
(43, 30, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFC_LEVEL\",\"to\":\"PS_LEVEL\",\"otp_verified\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:06:27'),
(44, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:21:13'),
(45, 30, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFC_LEVEL\",\"to\":\"PS_LEVEL\",\"otp_verified\":true,\"approved_by_ps\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:32:13'),
(46, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false,\"approved_by_ps\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:34:34'),
(47, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false,\"approved_by_ps\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:38:45'),
(48, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false,\"approved\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:42:42'),
(49, 30, 'workflow_advanced', 'applications', 1, '{\"from\":\"RDFC_LEVEL\",\"to\":\"PS_LEVEL\",\"otp_verified\":true,\"approved\":false}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:46:51'),
(50, 31, 'workflow_advanced', 'applications', 1, '{\"from\":\"PS_LEVEL\",\"to\":\"PROCUREMENT_LEVEL\",\"otp_verified\":false,\"approved\":true}', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', '2025-11-03 14:47:33');

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
(18, 19, 1, 0, 1, 1, 1, '2025-10-28 13:23:26', '2025-10-28 13:23:26'),
(19, 20, 1, 0, 1, 1, 1, '2025-10-30 13:39:35', '2025-10-30 13:39:35'),
(20, 21, 1, 0, 1, 1, 1, '2025-10-30 14:07:24', '2025-10-30 14:07:24'),
(21, 29, 1, 0, 1, 1, 1, '2025-11-03 09:39:30', '2025-11-03 09:39:30'),
(22, 30, 1, 0, 1, 1, 1, '2025-11-03 11:11:05', '2025-11-03 11:11:05'),
(23, 31, 1, 0, 1, 1, 1, '2025-11-03 13:05:54', '2025-11-03 13:05:54');

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
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `refresh_token`, `ip_address`, `user_agent`, `is_active`, `expires_at`, `created_at`, `last_activity`) VALUES
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxODYwOTk4LCJleHAiOjE3NjE4NjE4OTh9.jPHPqsKJXtEhvP-oEFBT_blNUDcjte5S50n1tdpypGQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTg2MDk5OCwiZXhwIjoxNzYyNDY1Nzk4fQ.NkkeClwAH4dSg0koaRUxn6YdiGhADN5O50g4Glxu-Ck', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-10-30 22:04:00', '2025-10-30 21:49:58', '2025-10-30 22:03:02'),
(2, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE4NjE5MzQsImV4cCI6MTc2MTg2MjgzNH0.YhIAZi9SHcwFQxwJdBzmhZ4QfERwWgfotUNPvnGVRv0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE4NjE5MzQsImV4cCI6MTc2MjQ2NjczNH0.vvIcIUD6mGQR5W99vEExCkbKNzhi2h3YXk6zsfJ3Zp0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 22:05:34', '2025-10-30 22:05:34', '2025-10-30 22:19:56'),
(3, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxODYyODEyLCJleHAiOjE3NjE4NjM3MTJ9.rOfNivibftiTRFywb57BXLYEmly8lFD20oA43PcJA98', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTg2MjgxMiwiZXhwIjoxNzYyNDY3NjEyfQ.ovbrNqsq5fYJ_AOCktU_6WhYjeqGTteyvskOnsD3_OQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 22:20:12', '2025-10-30 22:20:12', '2025-10-30 22:20:17'),
(4, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE4NjQyOTcsImV4cCI6MTc2MTg2NTE5N30.gwHUhnx4SGYD4q5QXiF0l-VFysdvzL_L8VkvGMh4wHI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE4NjQyOTcsImV4cCI6MTc2MjQ2OTA5N30.sCtkRz7gSE-IsKTbQrD-WExIDiOlOZq9NcdraemobLI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 22:44:57', '2025-10-30 22:44:57', '2025-10-30 22:58:37'),
(5, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE4NjUyOTcsImV4cCI6MTc2MTg2NjE5N30.jrBf9DXMXKVY42MuU1E3nbU7GSGSYVlULKFlMs5KJ5I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE4NjUyOTcsImV4cCI6MTc2MjQ3MDA5N30.rMercudjY6kCNMDFJJQuJbik6gnoFTp67EDIhOZdgtI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 23:01:37', '2025-10-30 23:01:37', '2025-10-30 23:06:08'),
(6, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxODY1NTg0LCJleHAiOjE3NjE4NjY0ODR9.nNkMCIHMCeHsDZnXYJzMHbnFtBQgItQOTYCTrgzPw7o', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTg2NTU4NCwiZXhwIjoxNzYyNDcwMzg0fQ.KizU8vwVIubuLo7G0ti3qzFS5gI-wvCuzF4mqH26R2M', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 23:06:24', '2025-10-30 23:06:24', '2025-10-30 23:07:05'),
(7, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxODY1NjM4LCJleHAiOjE3NjE4NjY1Mzh9.uDd8zNbcMnyoaLsM_zRRtBdMcUwEPl_b3etl2N3LJig', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTg2NTYzOCwiZXhwIjoxNzYyNDcwNDM4fQ.sar3pwX-xDXEqO-Soyh-1WLA897ZSXAvv8TXXEQmkIo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-06 23:07:18', '2025-10-30 23:07:18', '2025-10-30 23:15:56'),
(8, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxODkxMDczLCJleHAiOjE3NjE4OTE5NzN9.rAHQsnGP8WKYuMWkAie1rDZ3C1r_68DJZeXd4jN2zgw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTg5MTA3MywiZXhwIjoxNzYyNDk1ODczfQ.aYD85i7w_p8rxIiQGEp7wmPvcsRbZRqb-bN6EcSpswc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 06:11:13', '2025-10-31 06:11:13', '2025-10-31 06:14:57'),
(9, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE4OTg3NTcsImV4cCI6MTc2MTg5OTY1N30.tuKIKNprTWVf4Jee1E26_x9e5LZu-hbNC8-Hg9pF1RQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE4OTg3NTcsImV4cCI6MTc2MjUwMzU1N30.ls54NKwxKfDaurV1ttgG8kgjhKC9jUnxt-UL1VPZWR8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 08:19:17', '2025-10-31 08:19:17', '2025-10-31 08:24:03'),
(10, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDAxMTUsImV4cCI6MTc2MTkwMTAxNX0.02HqtO9jgmWyCHAAUsQtnCzwWM6P5oY2usYZE03gACg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDAxMTUsImV4cCI6MTc2MjUwNDkxNX0.yjcLtTTjR2p0qXfCpolcNcPdrGP3UAZrfwU68VUxG-o', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 08:41:55', '2025-10-31 08:41:55', '2025-10-31 08:50:20'),
(11, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAwNjg5LCJleHAiOjE3NjE5MDE1ODl9.YmudO4UyC1QyirC7TWza-AfYOmxejOSX1J48_E3aDVw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMDY4OSwiZXhwIjoxNzYyNTA1NDg5fQ.hY1r79uGggI2E8Nve6rKiLRPxPhPbw1no0e45D_PseA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 08:51:29', '2025-10-31 08:51:29', '2025-10-31 08:51:34'),
(12, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAwNzA3LCJleHAiOjE3NjE5MDE2MDd9.or1jAqziynF0Ex6FcreFyNKV45ddEJKI0M0t6XJSZN8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMDcwNywiZXhwIjoxNzYyNTA1NTA3fQ.L78MxUpT4gAm73g3kfsYPqYEtSQDGB3CtLY4a3Qx-yM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 08:51:47', '2025-10-31 08:51:47', '2025-10-31 08:54:21'),
(13, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYxOTAwODcwLCJleHAiOjE3NjE5MDE3NzB9.ahVw2GS66aU3FAGNrNryTpE9PpgTZwy_7q4r045lUz4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDA4NzAsImV4cCI6MTc2MjUwNTY3MH0.397akW8py9Q4tOaoxDe773kJ5p3Q3T6hxiEX6CsnP_0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 08:54:30', '2025-10-31 08:54:30', '2025-10-31 08:56:39'),
(14, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTkwMTAwNiwiZXhwIjoxNzYxOTAxOTA2fQ.ktg8eUT1_u8m2_26Z66bMI2r3x9lhbVl0_lCqUUU6KI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDEwMDYsImV4cCI6MTc2MjUwNTgwNn0.AfQaJ1uar2rsiLxh9pEZqICfv1hn6yf3RBy1vXP3_hU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 08:56:46', '2025-10-31 08:56:46', '2025-10-31 08:58:21'),
(15, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAxMTEzLCJleHAiOjE3NjE5MDIwMTN9.AQ6xLYL-jKvvTg34BExvEZDPmbsdogSXm0pQs0aBB2k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMTExMywiZXhwIjoxNzYyNTA1OTEzfQ.w2rYZ71sa4yz0k2Z6ZEFU1w6dcPEgadvdkPhT8Sqfog', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 08:58:33', '2025-10-31 08:58:33', '2025-10-31 09:02:40'),
(16, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNETyIsImlhdCI6MTc2MTkwMTM3MSwiZXhwIjoxNzYxOTAyMjcxfQ.o9lgNUl3Wek5wueFRyQ6IKNM_x1SNJir29JA-qfPPMc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDEzNzEsImV4cCI6MTc2MjUwNjE3MX0.IHPM1v-70lhoaA7QjiMogkDll_EGbm1u7TulfdHfFhE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:02:51', '2025-10-31 09:02:51', '2025-10-31 09:03:15'),
(17, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDE0MDcsImV4cCI6MTc2MTkwMjMwN30.4uVhW4dveISdwbVgVWwsERG62RQQCdoMoLV0VtLf1EU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDE0MDcsImV4cCI6MTc2MjUwNjIwN30.l4M641TxcGwlpHD8w0VlE8oX_OwHUpz50bTiMIhGUQA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:03:27', '2025-10-31 09:03:27', '2025-10-31 09:04:12'),
(18, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAxNDU4LCJleHAiOjE3NjE5MDIzNTh9.72kN8DoSNrjus6pCjI-DnvPIcPX-Uh14iukkwY24Szw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMTQ1OCwiZXhwIjoxNzYyNTA2MjU4fQ.hMUlCe00aSWk6xaqjmoWrtNn9iNvJBjNi1lE4EzgmyI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:04:18', '2025-10-31 09:04:18', '2025-10-31 09:04:46'),
(19, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTkwMTQ5NCwiZXhwIjoxNzYxOTAyMzk0fQ.SUGW48yrzPAbzLulk6-P_yQKEMDQkh1unSzv-DIb8B4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDE0OTQsImV4cCI6MTc2MjUwNjI5NH0.EZnsEwZFxO0eQiwL_TXPi2w6hzJQEKlEqPXDXiML0tc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:04:54', '2025-10-31 09:04:54', '2025-10-31 09:05:20'),
(20, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAxNTI4LCJleHAiOjE3NjE5MDI0Mjh9.XPhfDIpLWWSnV3e6aqVMBLN4Yv9CJuqQkXtargV45Pw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMTUyOCwiZXhwIjoxNzYyNTA2MzI4fQ.7Z4Vuy8YMK5L-IeF-OIZcTWmExqjARv2LYBNL_zn068', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:05:28', '2025-10-31 09:05:28', '2025-10-31 09:06:00'),
(21, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTkwMTU2NywiZXhwIjoxNzYxOTAyNDY3fQ.FcjPwPre9nwgOny4Ch4FgZ-4Czk7GWXJsCy01fgrTUE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDE1NjcsImV4cCI6MTc2MjUwNjM2N30.4cQMv0ByJJv1jULsapiOXbYnRRfVGsuMP0lQ7Bvzvik', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:06:07', '2025-10-31 09:06:07', '2025-10-31 09:18:39'),
(22, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDIzMzIsImV4cCI6MTc2MTkwMzIzMn0.e60gCBGPpQyIVxUeFYqf-3tXziUkQ_dzrDYfSbhsryE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDIzMzIsImV4cCI6MTc2MjUwNzEzMn0.JQLCHACNwwLWDaQsEG72NmEHlb4NavABIRgbb8EJ3y4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:18:52', '2025-10-31 09:18:52', '2025-10-31 09:24:56'),
(23, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYxOTAyNzExLCJleHAiOjE3NjE5MDM2MTF9.wC-zgkFh-Vjh7eu54NudBW8gPMDyPABnSZEXfquAlzQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDI3MTEsImV4cCI6MTc2MjUwNzUxMX0.zCxmiuVVBR6xwWz2ZlJ5y9_POfJprqMFgyUz2H4cNmM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:25:11', '2025-10-31 09:25:11', '2025-10-31 09:25:47'),
(24, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDI3NTksImV4cCI6MTc2MTkwMzY1OX0.Ul3l7QunZkIhIZCcR4JSyVqB0poy0_7bJ_1_pvhLiQM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDI3NTksImV4cCI6MTc2MjUwNzU1OX0.zCPSsbdeyyY2G6bFv9Td9n7S0kevNGHRSYHLak2OgoA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:25:59', '2025-10-31 09:25:59', '2025-10-31 09:26:33'),
(25, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTAyODA4LCJleHAiOjE3NjE5MDM3MDh9.8uWXnzbK8pS-Ub6CoL3G_5bhE6P3Qeli5PGO4MT3q9s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwMjgwOCwiZXhwIjoxNzYyNTA3NjA4fQ.NRjDEv3ii-OEVV3URXEwzCOZEmdxCCEYLIajG_L2p6I', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 09:26:48', '2025-10-31 09:26:48', '2025-10-31 09:27:31'),
(26, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDI4NjYsImV4cCI6MTc2MTkwMzc2Nn0.kpgLWJqrjssXVlEHGRqNcdEDDdhxcDtRIHFdhadsn_8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDI4NjYsImV4cCI6MTc2MjUwNzY2Nn0.xAlODKsFJU1QW_QYQ56FkHHWyZdZbRcY4BukzaATLVw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 09:27:46', '2025-10-31 09:27:46', '2025-10-31 09:41:54'),
(27, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDM4MDEsImV4cCI6MTc2MTkwNDcwMX0.sq9IzMvrMbraKxlXmCHQOWSf5amTy9uCBJqI-GlbXVQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDM4MDEsImV4cCI6MTc2MjUwODYwMX0._Gank0B7ubRioAl_DOEn7UsRRwtF-oG3aWohegAsHJ8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 09:43:21', '2025-10-31 09:43:21', '2025-10-31 09:57:09'),
(28, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTA1NDc0LCJleHAiOjE3NjE5MDYzNzR9.KXNoaTCWUBp8mddoCD1N_c545v3COmlJ2_unVx1XW88', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwNTQ3NCwiZXhwIjoxNzYyNTEwMjc0fQ.c5nPHcL2MXjRmCK-gZXsCTavFr1Y0vGbL7PSXq8adBk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:11:14', '2025-10-31 10:11:14', '2025-10-31 10:16:21'),
(29, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTkwNTc4NiwiZXhwIjoxNzYxOTA2Njg2fQ.tZkUB1M7SbQu879bFQ72yHSQmCruJ0RJswViuD2jjZY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDU3ODYsImV4cCI6MTc2MjUxMDU4Nn0.yQR5EcG0V30CbuhN6faFtaYP1eHyQFekfjEPKRHKRug', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:16:26', '2025-10-31 10:16:26', '2025-10-31 10:16:49'),
(30, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxOTA1ODI5LCJleHAiOjE3NjE5MDY3Mjl9.9ZYfcC04-CyQIxPz8BLnG3A3AhkBg2uFtXMQkCNI2HY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDU4MjksImV4cCI6MTc2MjUxMDYyOX0.q1aKbpE0BPnabAnrFPnC4WSSVeUyyfZNKCecBQar1F4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:17:09', '2025-10-31 10:17:09', '2025-10-31 10:17:33'),
(31, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTA1ODYwLCJleHAiOjE3NjE5MDY3NjB9.6mPDWLpH58koP_luiK4SeoyHtJnsveXS_O5GgquMmWI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwNTg2MCwiZXhwIjoxNzYyNTEwNjYwfQ.OxqcpwiANX2VYG-RnGS6E-hpyPWBZpuOsXt9bmmQdv8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:17:40', '2025-10-31 10:17:40', '2025-10-31 10:18:02'),
(32, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYxOTA2MDEzLCJleHAiOjE3NjE5MDY5MTN9.IHpzI4nnRNV-v3PBDnL-WsZP5yyUNKzqgeW8MYHfMgE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDYwMTMsImV4cCI6MTc2MjUxMDgxM30.kCE-NKIk8Om8UD8sOx7O7DxkNLJvJRVqZ1TtbRaXoEo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 10:20:13', '2025-10-31 10:20:13', '2025-10-31 10:34:44'),
(33, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTA3MTUzLCJleHAiOjE3NjE5MDgwNTN9.ZqvsaYiTo34vms48nkEx3eTEAHcEe5ENyC_FQj4em-8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwNzE1MywiZXhwIjoxNzYyNTExOTUzfQ.vqCx6NDgjXw8Jd_2jReXpVO6ZF2pFIwV1HpuNubi9-E', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:39:13', '2025-10-31 10:39:13', '2025-10-31 10:39:25'),
(34, 11, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInVzZXJuYW1lIjoid2FuZGlsZSIsImVtYWlsIjoid2FraGl3YWtoaTFAZ21haWwuY29tIiwicm9sZSI6IkxJTkVfTUlOSVNUUlkiLCJpYXQiOjE3NjE5MDcxNzIsImV4cCI6MTc2MTkwODA3Mn0.m-izr25k7NpJPiUFTH_4usUFj7mN1L37S_ms_9MOJks', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDcxNzIsImV4cCI6MTc2MjUxMTk3Mn0.NBxTg_elaIgWrNSXxaGc7pHLw_XmmT3LWsTrJDRjMAk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:39:32', '2025-10-31 10:39:32', '2025-10-31 10:40:43'),
(35, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYxOTA3MjUyLCJleHAiOjE3NjE5MDgxNTJ9.9SyB0gffzZa8wFtTFgpOMkIthAeqca3xmyDw9_dn6M8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDcyNTIsImV4cCI6MTc2MjUxMjA1Mn0.dMz9Q-mEkM07Upg95wm-WKOsejyjuhtAFpfZDx5KzGA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:40:52', '2025-10-31 10:40:52', '2025-10-31 10:41:10'),
(36, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTA3Mjc1LCJleHAiOjE3NjE5MDgxNzV9.Tpl6S0dzbmqsILlmcterrMioNOI1CQxwT6FVdaGKogE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwNzI3NSwiZXhwIjoxNzYyNTEyMDc1fQ.k3qMBefdO2CwU6cb067eBOPxeEk7p9MOp9P0TCJWMPA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 10:41:15', '2025-10-31 10:41:15', '2025-10-31 10:41:32'),
(37, 18, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInVzZXJuYW1lIjoib2x3ZXRodSIsImVtYWlsIjoid2FraGl3YWtoaTFAb3V0bG9vay5jb20iLCJyb2xlIjoiQ0RPIiwiaWF0IjoxNzYxOTA3MzAxLCJleHAiOjE3NjE5MDgyMDF9.ojV-UcyZ9n6BxXea687sKH97IvfpXKMf-sGQmXc7A3k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTgsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MDczMDEsImV4cCI6MTc2MjUxMjEwMX0._b3dwepx3tT5K3n5TiYshCqGoF5w2KAgR-44EpcBfs4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 10:41:41', '2025-10-31 10:41:41', '2025-10-31 10:55:17'),
(38, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTA5ODM4LCJleHAiOjE3NjE5MTA3Mzh9.Zh2CyzB7gsr75nzVABbRcMbQ-60v_wA2tMkDjzdVod0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkwOTgzOCwiZXhwIjoxNzYyNTE0NjM4fQ.akrm7320iqtVgD0ETqSqylBkLhn8itIvPcdIdZkmYzs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 11:23:58', '2025-10-31 11:23:58', '2025-10-31 11:27:01'),
(39, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTExMjAwLCJleHAiOjE3NjE5MTIxMDB9.C36K44luQfxmV8zDjwtPoju3oaVMvrnLt5raw_Ob-C4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxMTIwMCwiZXhwIjoxNzYyNTE2MDAwfQ.y3Xp-eEO2FCptYjBZxom7aX9U6kN_w0VxNGVdIxDz20', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 11:46:40', '2025-10-31 11:46:40', '2025-10-31 12:01:30'),
(40, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTEyMTU1LCJleHAiOjE3NjE5MTMwNTV9.wPpgL0YuLLeW8CGDbyvk2wZnwcRfcBVAi1ndBr2e268', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxMjE1NSwiZXhwIjoxNzYyNTE2OTU1fQ.kI3F-OGLhuVY68IovHT6UJnObig7DezstRKk4jipF-0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 12:02:35', '2025-10-31 12:02:35', '2025-10-31 12:03:01'),
(41, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTEzNjc2LCJleHAiOjE3NjE5MTQ1NzZ9.FC44oiQa2V69yqcsQXzXYi2xLjfRoXQ0Tm_84T-1PT4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxMzY3NiwiZXhwIjoxNzYyNTE4NDc2fQ.DpRm0fl6UDPOxdVyCy4SZSTBdaT5mNdeJT-x3r2JeYk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 12:27:56', '2025-10-31 12:27:56', '2025-10-31 12:41:37'),
(42, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTE1MDU5LCJleHAiOjE3NjE5MTU5NTl9.eMdhPBNGxXYVdeqqY1--Koz5zOndSz5pHTtNrsXEbEg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxNTA1OSwiZXhwIjoxNzYyNTE5ODU5fQ.v3XvGRv7SULxpTwfOUsM0AVupN3_5Ti9nGemiVpGeg8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 12:50:59', '2025-10-31 12:50:59', '2025-10-31 13:04:40'),
(43, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTE3MDY0LCJleHAiOjE3NjE5MTc5NjR9._MxJMttXDWVF9PXBCM2BiDcv6B1dC6psv7dLsacynl4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxNzA2NCwiZXhwIjoxNzYyNTIxODY0fQ.t6zxri81cUkAPukF9EfpZzNidgYn5jlQKhCWEJanCL0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 13:24:24', '2025-10-31 13:24:24', '2025-10-31 13:25:19'),
(44, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTkxNzEyNiwiZXhwIjoxNzYxOTE4MDI2fQ.46fNgVBmyYGn7T0RBvIVxwDDQYvEmUd3fCBVFWXp1tM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MTcxMjYsImV4cCI6MTc2MjUyMTkyNn0.vNwLOxScR_Z4UdUnk6q0kLacRRNTbhqqvsewgTH0Y4U', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 13:25:26', '2025-10-31 13:25:26', '2025-10-31 13:26:06'),
(45, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTE3MTcxLCJleHAiOjE3NjE5MTgwNzF9.Ozf954WxRW-gjDcumLsaZR5ZsXirVaZRzqTwM3pZeqY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxNzE3MSwiZXhwIjoxNzYyNTIxOTcxfQ.Ubtkk5wYNVkchbfvDIBb6UhCYqn6tlm64cU5fyjTjak', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 13:26:11', '2025-10-31 13:26:11', '2025-10-31 13:26:15'),
(46, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTkxOTI1NCwiZXhwIjoxNzYxOTIwMTU0fQ.LboIE6sltlOJjGUghHPWA_fLoxT6N8Z_4ASIKSBXSSg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MTkyNTQsImV4cCI6MTc2MjUyNDA1NH0.QZUau9UiAPDCeraU9NMpRnELayrnOrjLJd3XzNEfsoM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 14:00:54', '2025-10-31 14:00:54', '2025-10-31 14:03:05'),
(47, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTE5MzkwLCJleHAiOjE3NjE5MjAyOTB9.pd7m3vsnIjMh-c3mdkbewcTQoHdLAas3jBlZ3McCJ0A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTkxOTM5MCwiZXhwIjoxNzYyNTI0MTkwfQ.s437kBJhCTQTrP59U5o6nvnHF7WrpFMNpBvOWzC5HFM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-07 14:03:10', '2025-10-31 14:03:10', '2025-10-31 14:04:51'),
(48, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTkxOTUwMCwiZXhwIjoxNzYxOTIwNDAwfQ.__HhQdwqJ9qxKN3m6460aa1EkvGLqC4BXsuUnVhvPMs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5MTk1MDAsImV4cCI6MTc2MjUyNDMwMH0.hzh93BU0czXnV0pJ1a7iXmn_I2W0RF-iKLP84uRyY2k', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-07 14:05:00', '2025-10-31 14:05:00', '2025-10-31 14:06:07'),
(49, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTg3MDE5LCJleHAiOjE3NjE5ODc5MTl9.Xz3aVJHs9mfVmr1SBX3bEzeeshatWkg5kqxNfzJIGZg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk4NzAxOSwiZXhwIjoxNzYyNTkxODE5fQ.8Ip60R_PgWzw84NCZhiWroRGDo9-aU7xCmz2LTRZLls', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 08:50:19', '2025-11-01 08:50:19', '2025-11-01 08:52:12'),
(50, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTg4OTk1LCJleHAiOjE3NjE5ODk4OTV9.xzDT83zy2sGn8_BNPmn-R6f_A3i4jVSiE13vbLtFaoY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk4ODk5NSwiZXhwIjoxNzYyNTkzNzk1fQ.1wBy8VJ6Zcmop1owvKQxIQ-X0SKFPrBVc-3Uh59olaw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 09:23:15', '2025-11-01 09:23:15', '2025-11-01 09:23:25'),
(51, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTkxMDk2LCJleHAiOjE3NjE5OTE5OTZ9.I3BFLjxd_DYxlVOVUUSg-Y_gH0x0agU2m51eKYxM--A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk5MTA5NiwiZXhwIjoxNzYyNTk1ODk2fQ.Gb3JBJCLVceV-xlI15HvSTclH8uy5xYL0q7t5iNb7NQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 09:58:16', '2025-11-01 09:58:16', '2025-11-01 09:59:41'),
(52, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTkyNjI0LCJleHAiOjE3NjE5OTM1MjR9.TI8Hj6q6ztu0O52-juHshkw3_VC1-DVn-cwmkN5L4_M', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk5MjYyNCwiZXhwIjoxNzYyNTk3NDI0fQ.I4QOTl0G0QHq33rCCvgaPn9EsgZnNB5foruUSYDRWwk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 10:23:44', '2025-11-01 10:23:44', '2025-11-01 10:24:00'),
(53, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTkzNzA2LCJleHAiOjE3NjE5OTQ2MDZ9.xY7cxMHWFSPZ9Ndy84LDgHR-IpGTbPW-o1ewEB9-ntY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk5MzcwNiwiZXhwIjoxNzYyNTk4NTA2fQ.hkCy6t4cGGsPrqDRw5YRSDqFEGUMhMtk_gBOF1wk0qg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 10:41:46', '2025-11-01 10:41:46', '2025-11-01 10:43:18'),
(54, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTk5NDg2OCwiZXhwIjoxNzYxOTk1NzY4fQ._Fe3jsozqg12DrLKMAOgDP-xGWx2i_sOInE5hJv5LmU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5OTQ4NjgsImV4cCI6MTc2MjU5OTY2OH0.Nbn3DeBVGJBOvkdWp6UFcPlYP7b78PS1ROpT1xL5_Dw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 11:01:08', '2025-11-01 11:01:08', '2025-11-01 11:09:47'),
(55, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYxOTk1Mzk1LCJleHAiOjE3NjE5OTYyOTV9.r-MXjYTlb3iHd9zzg6b69WLjAIhqhnIJqSc5RfP-J1g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MTk5NTM5NSwiZXhwIjoxNzYyNjAwMTk1fQ.cVU_nS85FpgglPQcPBxmLT7I5XXnHHEvlkadNZaA7EA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 11:09:55', '2025-11-01 11:09:55', '2025-11-01 11:10:09'),
(56, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MTk5NTQxOSwiZXhwIjoxNzYxOTk2MzE5fQ.VJTzFk4wu3dQ-3-foWLDtWM3COseaCO19x6uRi9Jh9U', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5OTU0MTksImV4cCI6MTc2MjYwMDIxOX0.-arNXZxTvnKboKiwB-UgyWgkSud9aw4rwmlYS_fFXy4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 11:10:19', '2025-11-01 11:10:19', '2025-11-01 11:10:44'),
(57, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTk5Njc1MCwiZXhwIjoxNzYxOTk3NjUwfQ.IwonOd4wRkNwaSGHUYV76mztMJiuDNMbSTj5PeOtelI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5OTY3NTAsImV4cCI6MTc2MjYwMTU1MH0.bROaMt9F4J7cAqMqGf0pxwd0rST_zr-eKdUAB-y058U', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 11:32:30', '2025-11-01 11:32:30', '2025-11-01 11:42:42'),
(58, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTk5ODQ4NCwiZXhwIjoxNzYxOTk5Mzg0fQ.FEO95ZpOBWFrsA2v97KW1y4OBxwZBxFKekDYkhC5PJ0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5OTg0ODQsImV4cCI6MTc2MjYwMzI4NH0.nz4VYJuY7fySv3CWhHtCcsfG0NV4RmnEbsOZ-OnRYX4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 12:01:24', '2025-11-01 12:01:24', '2025-11-01 12:09:32'),
(59, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MTk5OTA4NiwiZXhwIjoxNzYxOTk5OTg2fQ.luI6Y3mgMPA9WmKflyHgeEVi1_xKu9Q7ottTxTEcsvY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjE5OTkwODYsImV4cCI6MTc2MjYwMzg4Nn0.ozfqyYzeL4OHDRibUmQnMaeZQknwAPrAvDsnFmeoPr4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 12:11:26', '2025-11-01 12:11:26', '2025-11-01 12:26:20'),
(60, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAwNjc0NCwiZXhwIjoxNzYyMDA3NjQ0fQ.G1vAFIVqPAj36lfwtwJ5tGYtH8ua0Og4DZ1PHgkDiQs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMDY3NDQsImV4cCI6MTc2MjYxMTU0NH0.ia-Bm_O2LnQhZBRQ_TraMbeoFxVmkQxY3nEEqI6aZ70', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 14:19:04', '2025-11-01 14:19:04', '2025-11-01 14:19:04'),
(61, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAxMTAyMCwiZXhwIjoxNzYyMDExOTIwfQ.1EET0bAPkScY8qQH3JprVeZpxkdUZK0kazvz8fndaOU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMTEwMjAsImV4cCI6MTc2MjYxNTgyMH0.G1noGIuIdoQZX4EEKNhGQmXfkMJExNemZInj42q__Fg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 15:30:20', '2025-11-01 15:30:20', '2025-11-01 15:45:14'),
(62, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAxMjAzMCwiZXhwIjoxNzYyMDEyOTMwfQ.NyUumxs-w-ZJgZpZZ-9vmM43XmX-XvZzdBJKHMjrolY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMTIwMzAsImV4cCI6MTc2MjYxNjgzMH0.EDBAUZNzm2-zm4Eg-NE4QJ-1-TjhtH8BbPfUnylEOXE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 15:47:10', '2025-11-01 15:47:10', '2025-11-01 15:56:56'),
(63, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDEzMDIzLCJleHAiOjE3NjIwMTM5MjN9.aAvHWOQDIpKoDFF8BLsfgdC4RhGf3UNRZsYrv4gJH5Y', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAxMzAyMywiZXhwIjoxNzYyNjE3ODIzfQ.Hn2bNprjh78I7T-tuAMelYxTn6EIuGiJIA0mUZnFswU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 16:03:43', '2025-11-01 16:03:43', '2025-11-01 16:03:49'),
(64, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAxMzAzNywiZXhwIjoxNzYyMDEzOTM3fQ.CYzHO7TMzJtlB3J-eqqErn31ssjDjpSOjM9ORCSqPM4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMTMwMzcsImV4cCI6MTc2MjYxNzgzN30.k7R8Zm8VRpQu88U4LfUHBoSZVz7BzracVS_aziZgSXI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 16:03:57', '2025-11-01 16:03:57', '2025-11-01 16:17:43'),
(65, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDE1MjI3LCJleHAiOjE3NjIwMTYxMjd9.pRru75nGoGnZOk94PQwBZrxxHtuugHVafeAcdKYfooE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAxNTIyNywiZXhwIjoxNzYyNjIwMDI3fQ.1NOQUlH8nFNr1eNFig1e8BEgHN8MBO08oN6EI792lBw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 16:40:27', '2025-11-01 16:40:27', '2025-11-01 16:42:02'),
(66, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDE5ODM1LCJleHAiOjE3NjIwMjA3MzV9.swkRasmQqYfDwWuPoAbZq41_-Qd0cW51TczJg-FCqnc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAxOTgzNSwiZXhwIjoxNzYyNjI0NjM1fQ.p95Dhxn-pmu885vy5vJW9rcvPhyCubzgg8VM0qHzTxM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 17:57:15', '2025-11-01 17:57:15', '2025-11-01 17:57:24'),
(67, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAxOTg1MSwiZXhwIjoxNzYyMDIwNzUxfQ.pR1UIuffx_Er0odezgEexKg6vKMq8FVJhOSQfSoyS8g', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMTk4NTEsImV4cCI6MTc2MjYyNDY1MX0.o3u2nzRGuqP4ZsmjUrrePnFQE2QRx-QNgk-Zx1jt1PI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 17:57:31', '2025-11-01 17:57:31', '2025-11-01 17:58:43'),
(68, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDE5OTI4LCJleHAiOjE3NjIwMjA4Mjh9.RVgsxOJgyPGiYiNkxrySkvDpa8G7ej36aRAysrqg2hM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAxOTkyOCwiZXhwIjoxNzYyNjI0NzI4fQ.yKod9eCDmEYZ_im6Ea5AJUKj0w8AmEiuma78GLTj8Nw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 17:58:48', '2025-11-01 17:58:48', '2025-11-01 18:08:36'),
(69, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAyMTY1NywiZXhwIjoxNzYyMDIyNTU3fQ.67N_sAaNutx-v1mpGi5HU4VULVgUbuY46bpekPQc9hg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjE2NTcsImV4cCI6MTc2MjYyNjQ1N30.qurtG8UAw-TuJeH63m4CXI8DeplLZTNd1kSGY_IDzvU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 18:27:37', '2025-11-01 18:27:37', '2025-11-01 18:37:08'),
(70, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAyMjI0MCwiZXhwIjoxNzYyMDIzMTQwfQ.oyekw5RxQmG216zHqOX0lXWWuEHKi6ROJ--9NwY3xvw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjIyNDAsImV4cCI6MTc2MjYyNzA0MH0.JamNk25g9u46h07SNYi3F4LKa6plI6NNPEzl1HxfwRQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 18:37:20', '2025-11-01 18:37:20', '2025-11-01 18:39:21'),
(71, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAyMjM3MSwiZXhwIjoxNzYyMDIzMjcxfQ.iddyyB1OyYxZSpOaNLXowUhGjLao2XL59Jhq27LiAsE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjIzNzEsImV4cCI6MTc2MjYyNzE3MX0.GfuFNmJdG_Wn7AN9honta_P33n7usvZbfGpBlpdsf4E', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 18:39:31', '2025-11-01 18:39:31', '2025-11-01 18:53:47'),
(72, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDIzMzQ0LCJleHAiOjE3NjIwMjQyNDR9.6l0okCAXUMG3e-VDQhXzrNnjebW111NAMJXmVSMkvCM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAyMzM0NCwiZXhwIjoxNzYyNjI4MTQ0fQ.0A2h6_wDUnvBPHdw0ySD4ZZqcPP3y2Rv7y9S1cU9AHA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 18:55:44', '2025-11-01 18:55:44', '2025-11-01 18:58:28'),
(73, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMDIzNTE5LCJleHAiOjE3NjIwMjQ0MTl9.RCLWkjlIUIV6yJuTviLlC_qZi_pXoGiioUoKH-AkxBs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjM1MTksImV4cCI6MTc2MjYyODMxOX0.IG814fMwIYepnxVBsizDwX0UJboSkxO4624oDf9QoPg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 18:58:39', '2025-11-01 18:58:39', '2025-11-01 18:59:13'),
(74, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDIzNTYwLCJleHAiOjE3NjIwMjQ0NjB9.Tpe2azmbu9Br-cUNZgrIZmeK3wuVVTxnbSnXdYdj80w', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAyMzU2MCwiZXhwIjoxNzYyNjI4MzYwfQ.jInQHaUkRm-KgQZyMuJPbMYXaRceezvEQORGPycN4uY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 18:59:20', '2025-11-01 18:59:20', '2025-11-01 18:59:42'),
(75, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMDIzNTk5LCJleHAiOjE3NjIwMjQ0OTl9.3Cy7RgJv99ZxTMgCoR2yiKw5SBy_GtqGgAtAZzETy6A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjM1OTksImV4cCI6MTc2MjYyODM5OX0.HtFNSzrd3Wzfr27jCENQ0MJ_vyQqTAnVaXM7eRSfCGA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 18:59:59', '2025-11-01 18:59:59', '2025-11-01 19:00:20'),
(76, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDI4NDI0LCJleHAiOjE3NjIwMjkzMjR9.vkcBussAz1VlHtJcmdOd4sVpm5RnQpEKlqL4q1G4rTs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjAyODQyNCwiZXhwIjoxNzYyNjMzMjI0fQ.J274awjp6P816qFbb6Qax9Nq9cBtdLTHcqZ1pawXvw4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 20:20:24', '2025-11-01 20:20:24', '2025-11-01 20:20:56'),
(77, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAyODQ5MCwiZXhwIjoxNzYyMDI5MzkwfQ.xTckO_4Y7XqCysoJslIGbZ0vAxyJ4ehxTIonGefK0ow', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMjg0OTAsImV4cCI6MTc2MjYzMzI5MH0.4t9EhjjIr9r95Uje5engd82ka01hto7ez4qAmClW_-s', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 20:21:30', '2025-11-01 20:21:30', '2025-11-01 20:34:31'),
(78, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAzMDE2MywiZXhwIjoxNzYyMDMxMDYzfQ.ACAbkFxi4zeQ-9CldWyxAFMt_Zp5krKsb15eWmk4DWU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMzAxNjMsImV4cCI6MTc2MjYzNDk2M30.mqsM6I5WPzN6cPhwWeasBOxmsoBVXVPJ5HSHfwbRafg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 20:49:23', '2025-11-01 20:49:23', '2025-11-01 21:02:07'),
(79, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMDMxNjg1LCJleHAiOjE3NjIwMzI1ODV9.Can6EoL843vo2oVAPYrVQTdVONyLt_ww3SW0So67jjU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMzE2ODUsImV4cCI6MTc2MjYzNjQ4NX0.G3sK173trDHQME28tWbmkDflipUamkafQqY3hmkdMmc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 21:14:45', '2025-11-01 21:14:45', '2025-11-01 21:16:17'),
(80, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjAzMTc5MywiZXhwIjoxNzYyMDMyNjkzfQ.tS4SRBi5iblkt9xmvmODfwUOmzEkzlk4H4w6ORt1O0I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMzE3OTMsImV4cCI6MTc2MjYzNjU5M30.7fRfVUmL-9kPq4Qn-GR0wdY4iBU4IAmLCZr1CajkR0E', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 21:16:33', '2025-11-01 21:16:33', '2025-11-01 21:17:12'),
(81, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMDMxODQxLCJleHAiOjE3NjIwMzI3NDF9.J8bgVXVeXEyMKf3ypQrRRYmVqzScXVIMZNeDK5NYnwM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMzE4NDEsImV4cCI6MTc2MjYzNjY0MX0.ZoES0jlLv_AaAC9FF-Hhf95HgGe0t77V5Sq0gBX2BXo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-08 21:17:21', '2025-11-01 21:17:21', '2025-11-01 21:27:50'),
(82, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjAzMzQzMCwiZXhwIjoxNzYyMDM0MzMwfQ.p_YvoCRG7VVZPYyXRPEAtW0oAMSpOKA-Dsq3eIlO35A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwMzM0MzAsImV4cCI6MTc2MjYzODIzMH0.Wy5CupX7F2WBHx_PKVYxYHVu6Q7Qv9KG7Pq7h2wlplw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-08 21:43:50', '2025-11-01 21:43:50', '2025-11-01 21:48:01'),
(83, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjA3NzU2MiwiZXhwIjoxNzYyMDc4NDYyfQ.q921nM78IHm18XH_KQti-VKtl7Sk7uuKagTTe0p2tsU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwNzc1NjIsImV4cCI6MTc2MjY4MjM2Mn0.hegcZCPKUSBJJnhx1rRDahE9x5fObFT501jUK5U9m2k', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 09:59:22', '2025-11-02 09:59:22', '2025-11-02 09:59:23'),
(84, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDgxNzk5LCJleHAiOjE3NjIwODI2OTl9.6qO08c-kPbM3BMIdG5l69S5Gfk30Guk82nS459DTpG8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA4MTc5OSwiZXhwIjoxNzYyNjg2NTk5fQ.5cOl_HcNHt3f3Evodjjee1czj4qA89lWleClz2596Gc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 11:09:59', '2025-11-02 11:09:59', '2025-11-02 11:11:00'),
(85, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDg4Njg1LCJleHAiOjE3NjIwODk1ODV9.IChTUg2imQNBfDOGHm9TRToCiLsCNUuj0Pflb0GNqBY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA4ODY4NSwiZXhwIjoxNzYyNjkzNDg1fQ.fm2CUyq_KG7asKAzG1XUfeOWFtz2UMHD8nmHdfZh-D4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:04:45', '2025-11-02 13:04:45', '2025-11-02 13:19:31'),
(86, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDg5OTExLCJleHAiOjE3NjIwOTA4MTF9.3BwENWn7EEKGc65B5FbY2z1waAGL-Sbnp0-Ool0Ui68', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA4OTkxMSwiZXhwIjoxNzYyNjk0NzExfQ.jKPKQ12kKwMhutR4hc7eDTIvqhAPZip33Q4ku45LLHU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:25:11', '2025-11-02 13:25:11', '2025-11-02 13:26:16'),
(87, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDkwMTg3LCJleHAiOjE3NjIwOTEwODd9.9LeMthpgdT8Cp48hMCCo5whfabPPlHIUc7hxAgqpSvA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5MDE4NywiZXhwIjoxNzYyNjk0OTg3fQ.WBTYq24ci_X_ovqfDtrbOqmOpe4V77f6bkJXEXLIVvI', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:29:47', '2025-11-02 13:29:47', '2025-11-02 13:29:51'),
(88, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDkwMjIwLCJleHAiOjE3NjIwOTExMjB9.tz3MQyWkTMZRpzE7ux4cEQb7fpQl6XUELdBu7Xedqq4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5MDIyMCwiZXhwIjoxNzYyNjk1MDIwfQ.BHiWcBhE9wIV_JAOR_Ox8mCaQ1EmHXgylk_kyNd9W7c', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:30:20', '2025-11-02 13:30:20', '2025-11-02 13:30:24'),
(89, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDkwMjQ2LCJleHAiOjE3NjIwOTExNDZ9.Tm8Qr1_oIXnCNx1VZY-zPpJrURQhp_FoAQxL4Zdbvos', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5MDI0NiwiZXhwIjoxNzYyNjk1MDQ2fQ.QWx15GRyNqBUmMM2KGZmNVH3qg5UxfEoN7prl2um-PM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:30:46', '2025-11-02 13:30:46', '2025-11-02 13:30:49'),
(90, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDkwMzIwLCJleHAiOjE3NjIwOTEyMjB9.E33eEO_Fd_DcKfudeF0bzL3nX09g0EM1va3Qc1g8OJ0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5MDMyMCwiZXhwIjoxNzYyNjk1MTIwfQ.PShztUslSWQrk-Pk6TRB4EdiFkujDO9t4Tzp-QccG00', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:32:00', '2025-11-02 13:32:00', '2025-11-02 13:40:10'),
(91, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjA5MTI0MiwiZXhwIjoxNzYyMDkyMTQyfQ.JAuwzW1GeQfK2AtzZRf5swIG1qppGxHT_GpZWrNyN8w', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwOTEyNDIsImV4cCI6MTc2MjY5NjA0Mn0.g4PZDpwo22vAEdfLA3VpUlhwLpXg-2-ZY7s6NjH4klQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 13:47:22', '2025-11-02 13:47:22', '2025-11-02 13:48:20'),
(92, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMDkxMzUxLCJleHAiOjE3NjIwOTIyNTF9.-RQPlt51DezWeqZ-N1wWWrwweJ29JLSP43e_2CP0p74', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIwOTEzNTEsImV4cCI6MTc2MjY5NjE1MX0.m04-kHc7T8GOxyPDIHvFjlcHJqMK3fKtR_bGUUvQP3o', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 13:49:11', '2025-11-02 13:49:11', '2025-11-02 13:54:07'),
(93, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDkxNjYwLCJleHAiOjE3NjIwOTI1NjB9.u3ZAVCPBPAxYJD6ZnU9ug6Jy7r5-xkLU8OclmRk8lAU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5MTY2MCwiZXhwIjoxNzYyNjk2NDYwfQ.kKOUhg6htENjWegl5RDAJlvK_-vuoTMH3dx7RD8zz2s', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 13:54:20', '2025-11-02 13:54:20', '2025-11-02 14:01:42'),
(94, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDk0NjcwLCJleHAiOjE3NjIwOTU1NzB9.qFqC79vRZe0PhzkTSQQNJLcOaD6I3-rBNWv0fO1bkig', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5NDY3MCwiZXhwIjoxNzYyNjk5NDcwfQ.g7Q-io4bPPFJfzuA1OiMSpDWSBf2AzEN3nZU_OZcGeY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 14:44:30', '2025-11-02 14:44:30', '2025-11-02 14:44:38');
INSERT INTO `user_sessions` (`id`, `user_id`, `session_token`, `refresh_token`, `ip_address`, `user_agent`, `is_active`, `expires_at`, `created_at`, `last_activity`) VALUES
(95, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDk0Njk0LCJleHAiOjE3NjIwOTU1OTR9.gd9OLquTegjftPTHH1YUbCdXaAuoBtNFOO3qoFYqmIE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5NDY5NCwiZXhwIjoxNzYyNjk5NDk0fQ.IN2vWIlGvGjMUBNQerx-O-xcxGIxUMBPe9BHgv0Mqew', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 14:44:54', '2025-11-02 14:44:54', '2025-11-02 14:58:53'),
(96, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDk2MzExLCJleHAiOjE3NjIwOTcyMTF9.lf8GLdSRCPDsX58ASP22YJXpbM410kGEKoVIzXKcy8Q', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5NjMxMSwiZXhwIjoxNzYyNzAxMTExfQ.MEZNMNDWw8IVumJ3wHRBDrp1JDzP6Y-QbhY-t9jMSqc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 15:11:51', '2025-11-02 15:11:51', '2025-11-02 15:26:03'),
(97, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMDk3NDYzLCJleHAiOjE3NjIwOTgzNjN9.97uj_AUzNj7Dz6CeOho_YN6LEMZQ63qq8twSZC6aQJg', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjA5NzQ2MywiZXhwIjoxNzYyNzAyMjYzfQ.mZlQY1bQp2RT2djeYoISK5VeN12XFHZqvmVc2lPLAiE', '::1', 'PostmanRuntime/7.49.0', 1, '2025-11-09 15:31:03', '2025-11-02 15:31:03', '2025-11-02 15:37:43'),
(98, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTAxMTI4LCJleHAiOjE3NjIxMDIwMjh9.qLpsy5rvsJ1K4yePyxBCMaPME27xwirib7rfvCSncdE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwMTEyOCwiZXhwIjoxNzYyNzA1OTI4fQ.-0pvowxhw5fcs1rVWqIdXgZ0PEd43gwnexM18PPXWtU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 16:32:08', '2025-11-02 16:32:08', '2025-11-02 16:40:29'),
(99, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTAyODk4LCJleHAiOjE3NjIxMDM3OTh9.KlTXC4o10wmerveICkzF0P5njbjGM9R-lA8jogPKvPw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwMjg5OCwiZXhwIjoxNzYyNzA3Njk4fQ.Y-wOv7_w3_rEoynUe7ekDCB77aEPdSHAN_CiBMH98fQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 17:01:38', '2025-11-02 17:01:38', '2025-11-02 17:08:14'),
(100, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMTAzMzA3LCJleHAiOjE3NjIxMDQyMDd9.7PiAEtrtMi9W8DwWLN_NXjvhVkp59gUGQFMbIwTyWEs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxMDMzMDcsImV4cCI6MTc2MjcwODEwN30.4ueBYX97PZOHByrjuShNOUJsJvV5_wf56dUo-6zdy1I', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 17:08:27', '2025-11-02 17:08:27', '2025-11-02 17:10:19'),
(101, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTAzNDI3LCJleHAiOjE3NjIxMDQzMjd9.V5lB1KhLzS3C-hNf8cg7dj13ZlI-t2vhgxkS-m04kZY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwMzQyNywiZXhwIjoxNzYyNzA4MjI3fQ.zdWnuxq86kcuH11yN_e3_J19Rt1m4502tiNcfr_uM3g', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 17:10:27', '2025-11-02 17:10:27', '2025-11-02 17:20:01'),
(102, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTA1NjE0LCJleHAiOjE3NjIxMDY1MTR9.P9wNf7bLWwDCgR9zJpyt_3rFlgS37nio6CbIDmqkpyc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwNTYxNCwiZXhwIjoxNzYyNzEwNDE0fQ.ccQqqqNFoxKVUi1mEs5pHdc0nhUJbmzgk8W-hyvUSJw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 17:46:54', '2025-11-02 17:46:54', '2025-11-02 18:00:50'),
(103, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMTA3NTMwLCJleHAiOjE3NjIxMDg0MzB9.bwxQ4L4Oi9VmO4GeGTT-uN5SAhc9-XsmeT-9dFJws-s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxMDc1MzAsImV4cCI6MTc2MjcxMjMzMH0.AUw9sdjy8w6F3hvd5NdKnKw0kH57r7dYW-6Bni8UXf4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 18:18:50', '2025-11-02 18:18:50', '2025-11-02 18:21:23'),
(104, 23, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInVzZXJuYW1lIjoiR29qZSIsImVtYWlsIjoibWJvc2liYW5kemVAZ21haWwuY29tIiwicm9sZSI6IkNEQyIsImlhdCI6MTc2MjEwNzY5MywiZXhwIjoxNzYyMTA4NTkzfQ.fBzNYCh8XjOrZ1RPlP-vIL9IUy_rNIcihhzwPzEGvFw', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjMsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxMDc2OTMsImV4cCI6MTc2MjcxMjQ5M30.CF5MlP0BsRwXfz_UN2wLhhnfzvskXQPVJ1oOTBYicxw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 18:21:33', '2025-11-02 18:21:33', '2025-11-02 18:23:36'),
(105, 24, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInVzZXJuYW1lIjoiTW5ndW5pIiwiZW1haWwiOiJ0ZXJlbmNlc2ltZWxhbmVAZ21haWwuY29tIiwicm9sZSI6IklOS0hVTkRMQV9DT1VOQ0lMIiwiaWF0IjoxNzYyMTA3ODI2LCJleHAiOjE3NjIxMDg3MjZ9.3dmfZUKId4MaJrXGVQ9EKi5Uqplxbijt4eD7ZggQUwU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjQsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxMDc4MjYsImV4cCI6MTc2MjcxMjYyNn0.bfH0hSGfVv1CXnwtcggNazGOvwpeUR3oUIzpJ20f5WA', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 18:23:46', '2025-11-02 18:23:46', '2025-11-02 18:33:15'),
(106, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTA4NDAzLCJleHAiOjE3NjIxMDkzMDN9.PaSZvOZhcMX_fWY8LfYoVWQa0hsPjO-hdNu11YEIP0I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwODQwMywiZXhwIjoxNzYyNzEzMjAzfQ.du1E_WEeZehMSVgC-wX9lRwzZpGKW2N7bPiEo5FuSdc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 18:33:23', '2025-11-02 18:33:23', '2025-11-02 18:33:28'),
(107, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTA5NTU5LCJleHAiOjE3NjIxMTA0NTl9.JYL4ft2G7xpgaCjxrO6YbXLGG3OomHz54hSfFNIOoDY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjEwOTU1OSwiZXhwIjoxNzYyNzE0MzU5fQ.Wk7XLW9AhWBLNKqB0Y4Oa6yW8II4tjPlkxFWfbgN4-k', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 18:52:39', '2025-11-02 18:52:39', '2025-11-02 19:03:15'),
(108, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjExMzM2NywiZXhwIjoxNzYyMTE0MjY3fQ.U7lDH3fM9bi7wyVSoW2OmBqnEjE548JaUe3-ZyMN4O8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxMTMzNjcsImV4cCI6MTc2MjcxODE2N30.MJ08W2Z9sj8oKbKdnQ98jLM86zRakrDHq--IHtwHK_A', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 19:56:07', '2025-11-02 19:56:07', '2025-11-02 20:01:29'),
(109, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTEzNjk3LCJleHAiOjE3NjIxMTQ1OTd9.RDfjWicPsOQbe28XpM_jd6opF6JSKe1oN1fWz7WqJEo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjExMzY5NywiZXhwIjoxNzYyNzE4NDk3fQ.Dx46uoGgn6RGfrxrlg0BlQrCtN-acoxGT33GDds9Y18', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 20:01:37', '2025-11-02 20:01:37', '2025-11-02 20:14:16'),
(110, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTE2NTIwLCJleHAiOjE3NjIxMTg2MjB9.ZgThbNNV0Aj3DnDA13KYuq6LGLtjvRnMA9WNLswdto0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjExNjUyMCwiZXhwIjoxNzYyNzIxMzIwfQ.CsEHMRURzxIZ4jECxBM4LjWMqZGRvPb92l1XbgBjdpM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-09 20:48:40', '2025-11-02 20:48:40', '2025-11-02 20:56:04'),
(111, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTE2OTg5LCJleHAiOjE3NjIxMTcxNjl9.Ld8cmD-ySU31hUmL0v9vaWzbhxfFAxqU050Z9u_1NyM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjExNjk4OSwiZXhwIjoxNzYyNzIxNzg5fQ.waRqHuDKVKpy9lgIw4gs1erqFobtIp4LsC4hwpuMcIY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 20:56:29', '2025-11-02 20:56:29', '2025-11-02 20:59:28'),
(112, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTE3ODIwLCJleHAiOjE3NjIxMTgwMDB9.Fxgz9ICf4cHk2rszQAdQueIWtkS-v5YcorylWzel_DM', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjExNzgyMCwiZXhwIjoxNzYyNzIyNjIwfQ.l9yoI7jGm0z4eElH8SyKUp89mlXIEpTyDyd6ihArDGY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-09 21:10:20', '2025-11-02 21:10:20', '2025-11-02 21:12:40'),
(113, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTU0NjExLCJleHAiOjE3NjIxNTczMTF9.vmjwtGl9qTMtzliZUvx_M8KjMRbpdlLXvJ0jJ_5xEFY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE1NDYxMSwiZXhwIjoxNzYyNzU5NDExfQ.CU9ZUy5Xu7jiGBuE5ov22b5Xke9Dh0974NiZSIm_8Y4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-10 07:23:31', '2025-11-03 07:23:31', '2025-11-03 08:06:58'),
(114, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTU3MzY2LCJleHAiOjE3NjIxNjAwNjZ9.sqTDPxYrScF4BhLEqaKIFaBj7OTICExZ-d4aRJxSJ_I', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE1NzM2NiwiZXhwIjoxNzYyNzYyMTY2fQ.QV_TT-LnZguYxra1fvrNuM_Rb3tDV06rgD_SKYx4iS8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 08:09:26', '2025-11-03 08:09:26', '2025-11-03 08:26:50'),
(115, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTU4NDQwLCJleHAiOjE3NjIxNjExNDB9.wBEMeFAdUT-hsJfuB99axd9iWUZ63jWWU0xBBGfrGQc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE1ODQ0MCwiZXhwIjoxNzYyNzYzMjQwfQ.MwSBkWuvBUSr9qmLRVfcXCVW419ZYAInYvcnroEcTKU', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 08:27:20', '2025-11-03 08:27:21', '2025-11-03 08:35:48'),
(116, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTU4OTYzLCJleHAiOjE3NjIxNjE2NjN9.c9iahZ_Zcx5J9nyPljpIOOmX2lTQ25W6IqTsLrJYlwc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE1ODk2MywiZXhwIjoxNzYyNzYzNzYzfQ.qkL1BHdmUuvQ9lEcfURnEpDxFWea1eiuy79rMgyr6nk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 08:36:03', '2025-11-03 08:36:03', '2025-11-03 08:46:53'),
(117, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTU5NjI0LCJleHAiOjE3NjIxNjIzMjR9.pc6M7L00g0RZrVDDeZDClvzZ8oTrKwsF5duwSw6t2oY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE1OTYyNCwiZXhwIjoxNzYyNzY0NDI0fQ.ajYZvb95zHu1gD5k9mirEarGnauETCr4BpvW1bSeO6E', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-10 08:47:04', '2025-11-03 08:47:04', '2025-11-03 09:25:00'),
(118, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTYyNTA0LCJleHAiOjE3NjIxNjUyMDR9.-uA0C-BZUFwSjnb-BFEfCR_fWa7dlGg5lEs58o6hbjA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE2MjUwNCwiZXhwIjoxNzYyNzY3MzA0fQ.YpNNhTVSkP1RYcBu_0SVXQtApfOpi_yhLUmPU-ULAMs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 09:35:04', '2025-11-03 09:35:04', '2025-11-03 09:43:02'),
(119, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInVzZXJuYW1lIjoiRmFuYSIsImVtYWlsIjoibWJvbmdlbmlAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZUQyIsImlhdCI6MTc2MjE2Mjk5NywiZXhwIjoxNzYyMTY1Njk3fQ.GTp_MmfGOPzZTAsdGxSdZawj46k1XhGCfXgycaNOpiA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNjI5OTcsImV4cCI6MTc2Mjc2Nzc5N30.nsfkVWMLIqvvvAaZWzjvJM63RmI00fa0DIjXNphu6QQ', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 09:43:17', '2025-11-03 09:43:17', '2025-11-03 09:45:36'),
(120, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTYzMTQxLCJleHAiOjE3NjIxNjU4NDF9.Bin63Cy6Ot9uMRQ_oqRepAa5jgyb105qsvrxuvsFEOI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE2MzE0MSwiZXhwIjoxNzYyNzY3OTQxfQ.uGgQxYuw1T5IWYNHVtEnSvm1MlAYbe-JMa8c2bETUhg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 09:45:41', '2025-11-03 09:45:41', '2025-11-03 10:08:52'),
(121, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInVzZXJuYW1lIjoiRmFuYSIsImVtYWlsIjoibWJvbmdlbmlAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZUQyIsImlhdCI6MTc2MjE2NDU0MywiZXhwIjoxNzYyMTY3MjQzfQ.z_icrHDxzRABN-m8zTfWs3huHCpISX_W83r_fHCS7mo', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNjQ1NDMsImV4cCI6MTc2Mjc2OTM0M30.h-7vJZVjjYuinTRlX-ZgykPkRJl4pWPte2ow6bM-qRs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 10:09:03', '2025-11-03 10:09:03', '2025-11-03 10:21:47'),
(122, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjE2NTMxNiwiZXhwIjoxNzYyMTY4MDE2fQ.bYFWQsjM1K8io7iXjYafoH42Q82OrLmWoJ7RaGtpvVE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNjUzMTYsImV4cCI6MTc2Mjc3MDExNn0.so72q-yZYh7zCEQL8WXF-NcC4yENrPcL-znnmQOjLCg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 10:21:56', '2025-11-03 10:21:56', '2025-11-03 10:22:11'),
(123, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInVzZXJuYW1lIjoiRmFuYSIsImVtYWlsIjoibWJvbmdlbmlAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZUQyIsImlhdCI6MTc2MjE2NTM0MiwiZXhwIjoxNzYyMTY4MDQyfQ.X2FeGYNI3lQy9t-Sm7N4G7mQuzrIBoKJ4vL_FBSNrwU', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNjUzNDIsImV4cCI6MTc2Mjc3MDE0Mn0.4HSVvAwwuP_JQhicUgEKU6jTQ7b7GRQE8m0_KfVSGc0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 10:22:22', '2025-11-03 10:22:22', '2025-11-03 11:05:40'),
(124, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTY3OTQ2LCJleHAiOjE3NjIxNzA2NDZ9.jnKh4hllUxMOAdbFCWmmGJiJZzZcRwlLNq4E9CxmjB8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE2Nzk0NiwiZXhwIjoxNzYyNzcyNzQ2fQ.Dq8uApCDepPAdi3kwFT8aBEdwNVUq72zuJp29aLTfCk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 11:05:46', '2025-11-03 11:05:46', '2025-11-03 11:11:42'),
(125, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInVzZXJuYW1lIjoiT3dhbWkiLCJlbWFpbCI6Im9sd2V0aHVAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZDIiwiaWF0IjoxNzYyMTY4MzE0LCJleHAiOjE3NjIxNzEwMTR9.jGxHWsb-Ihitij2Gmybf_sSueiLIUnK7B7xOME3pHyQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNjgzMTQsImV4cCI6MTc2Mjc3MzExNH0.UN7JvcquzfLhA4OKEaxFBQtwkjjmYw0hpiDXDQ04jU0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 11:11:54', '2025-11-03 11:11:54', '2025-11-03 11:35:09'),
(126, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTY5NzE3LCJleHAiOjE3NjIxNzI0MTd9.F0Xi5mNRHKe3filUl9MMdWnxkmXtPrxYewsomsI_lUc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE2OTcxNywiZXhwIjoxNzYyNzc0NTE3fQ.YdyAGVt5ZrR9uWlxL2e9AOPayPXVkE5HSzw-6GJiZtg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-10 11:35:17', '2025-11-03 11:35:17', '2025-11-03 11:48:31'),
(127, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTc0OTQwLCJleHAiOjE3NjIxNzc2NDB9.4-u-qGdIipJ7i-httrcwlddzdnCiQdib1Tdg5zfTklQ', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE3NDk0MCwiZXhwIjoxNzYyNzc5NzQwfQ.UWzfWXYi60HG-KAGI-ksMJqt3haOgZbpkJYVA6vIlpo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:02:20', '2025-11-03 13:02:20', '2025-11-03 13:06:25'),
(128, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIxNzUxOTYsImV4cCI6MTc2MjE3Nzg5Nn0.pZfUzkxWnBhI-k0eJWjPysAylFXg2sssGMX7QXp4Kk0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNzUxOTYsImV4cCI6MTc2Mjc3OTk5Nn0.gZy57pcbmPM5SCmGmsOjHC7GgfVMGUFub-O4KQ96Tac', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:06:36', '2025-11-03 13:06:36', '2025-11-03 13:42:37'),
(129, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTc3MzY5LCJleHAiOjE3NjIxODAwNjl9.SW-sY9tUzwnc38KsbuWMVncZU5nResG6OVoTLK_JVXc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE3NzM2OSwiZXhwIjoxNzYyNzgyMTY5fQ.uFH0OZt2G-cJEKOWizskh7OgC989_fLIm4DBWbOEYv4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:42:49', '2025-11-03 13:42:49', '2025-11-03 13:43:28'),
(130, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIxNzc0MTgsImV4cCI6MTc2MjE4MDExOH0.gZPa6s-k0FHU7krwLuiO6lKwh2Ik5xDt3SeXP6WdrKY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNzc0MTgsImV4cCI6MTc2Mjc4MjIxOH0.ui7Qi0vitnPZ6frA8y3WKmpj8pUUKQcZoAPlGHar-Dc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:43:38', '2025-11-03 13:43:38', '2025-11-03 13:51:55'),
(131, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInVzZXJuYW1lIjoiRmFuYSIsImVtYWlsIjoibWJvbmdlbmlAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZUQyIsImlhdCI6MTc2MjE3NzkyNiwiZXhwIjoxNzYyMTgwNjI2fQ.ycv9FunmPdYmBODvW48cjRxKE03aSngyjiluPBF0dbk', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjksInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNzc5MjYsImV4cCI6MTc2Mjc4MjcyNn0.1Nc4eJhnEqx2MTLUkoIM11eFzngfmLze3GsiDOK9XKo', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:52:06', '2025-11-03 13:52:06', '2025-11-03 13:52:29'),
(132, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTc3OTU0LCJleHAiOjE3NjIxODA2NTR9.Zq57P8R_Ucn31qFQKxrOs7VagQudRVmzcaSNHF81D3s', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE3Nzk1NCwiZXhwIjoxNzYyNzgyNzU0fQ.iDeOa6UogF3gcnVeiCkd0GZ0980W4TJNeIw-SzOZ0vY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:52:34', '2025-11-03 13:52:34', '2025-11-03 13:52:45'),
(133, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInVzZXJuYW1lIjoiT3dhbWkiLCJlbWFpbCI6Im9sd2V0aHVAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZDIiwiaWF0IjoxNzYyMTc3OTczLCJleHAiOjE3NjIxODA2NzN9.PZgVw87No5j3WRqJDsAtAh9gnXbgyIjxvRB2zpJDNsE', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNzc5NzMsImV4cCI6MTc2Mjc4Mjc3M30.TFBibPFgirzDe8mI4YPhmvevz6odIuGcdenAL7aqWNk', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 13:52:53', '2025-11-03 13:52:53', '2025-11-03 14:06:44'),
(134, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTc4ODEzLCJleHAiOjE3NjIxODE1MTN9.q3Q05Eqd5NESMoD9ZrA81zp1nZ7UVe5x9OY9Xm-YrP4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE3ODgxMywiZXhwIjoxNzYyNzgzNjEzfQ.vgR3FDA3-sU5mvXEtkMeB6ZlFWufJurB1w9_zIUh9IM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:06:53', '2025-11-03 14:06:53', '2025-11-03 14:07:18'),
(135, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIxNzg4NDgsImV4cCI6MTc2MjE4MTU0OH0.wbLwtFm9p3Fx3gIkrhEaretQpXf6tpQ-a0D_JBp_q4E', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxNzg4NDgsImV4cCI6MTc2Mjc4MzY0OH0.xGgn6p0rOLLEPYwTjFNRTnceAi1mSexNim34fbeBrYg', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:07:28', '2025-11-03 14:07:28', '2025-11-03 14:28:30'),
(136, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTgwMTE1LCJleHAiOjE3NjIxODI4MTV9.z3RxmbA4NXUBCrpNg_LtJJPg9pBIt1g2Y6nw7zoZ24k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE4MDExNSwiZXhwIjoxNzYyNzg0OTE1fQ.tIuu-60DX14T7Y9AhkHvSaoqT1gE6FgFI6nF1rL0RMY', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:28:35', '2025-11-03 14:28:35', '2025-11-03 14:28:45'),
(137, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInVzZXJuYW1lIjoiT3dhbWkiLCJlbWFpbCI6Im9sd2V0aHVAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZDIiwiaWF0IjoxNzYyMTgwMTMzLCJleHAiOjE3NjIxODI4MzN9.zKyO19jl7JGSqunOJzS1GpiT1pCrW9qEXFNfkpp58-k', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODAxMzMsImV4cCI6MTc2Mjc4NDkzM30.0Xqv-3g_bz8xCjtue9jySN27ChLDV1wUWEMCAQJ2bpE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:28:53', '2025-11-03 14:28:53', '2025-11-03 14:34:08'),
(138, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIxODA0NjMsImV4cCI6MTc2MjE4MzE2M30.DMqtNHzshmrQqlT_ZpCmMZkrTuGhNgPd6Fyhpga3ybA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODA0NjMsImV4cCI6MTc2Mjc4NTI2M30.H_NNJbQsh3W7Z3DCu46gb-bT03Rs_Gqhu-RruU5hd80', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:34:23', '2025-11-03 14:34:23', '2025-11-03 14:46:09'),
(139, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInVzZXJuYW1lIjoiT3dhbWkiLCJlbWFpbCI6Im9sd2V0aHVAcmVhbG5ldC5jby5zeiIsInJvbGUiOiJSREZDIiwiaWF0IjoxNzYyMTgxMTgxLCJleHAiOjE3NjIxODM4ODF9.V9ija_a88zGdU6DzauwyslV_f2kcA0IA2Y9NIcSgBr4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzAsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODExODEsImV4cCI6MTc2Mjc4NTk4MX0.xOkzq4g1y01Ud4fbo2lud74qZNanPc6RCLXpS2iLfOs', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:46:21', '2025-11-03 14:46:21', '2025-11-03 14:47:08'),
(140, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIxODEyMzgsImV4cCI6MTc2MjE4MzkzOH0.IVpA8a6p4COO7g3Q81Xr46HTQ2FZ5X8YhAQ3QmszaAI', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODEyMzgsImV4cCI6MTc2Mjc4NjAzOH0.d-wIHYgDj2hrMpfJU5771ua7kd7cK_EW4CR-VEoxgOc', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:47:18', '2025-11-03 14:47:18', '2025-11-03 14:47:46'),
(141, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTgxMjc0LCJleHAiOjE3NjIxODM5NzR9._-z8-gjwbcoaQKdIN4ozLePX0EXaZ6TXjDnMJPAoV84', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE4MTI3NCwiZXhwIjoxNzYyNzg2MDc0fQ.a4-iJ8pf5oiWKxHP2_huwZT9UnviIn_CbSwTHLICOH8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:47:54', '2025-11-03 14:47:54', '2025-11-03 14:48:08'),
(142, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYyMTgxMjk3LCJleHAiOjE3NjIxODM5OTd9.qIOGCoKDfEaYY5CJW2p-xogMhEuYJBqrH5zMmOBx_cc', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODEyOTcsImV4cCI6MTc2Mjc4NjA5N30.NqKCJTTSmIFAVKTzyv11dqBubkaADcBtWoyDrUZdoZw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 14:48:17', '2025-11-03 14:48:17', '2025-11-03 14:59:27'),
(143, 17, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInVzZXJuYW1lIjoiYmVlaGl2ZXMiLCJlbWFpbCI6ImNlbGltcGhpbG9kbGFtaW5pOTRAZ21haWwuY29tIiwicm9sZSI6IkVPRyIsImlhdCI6MTc2MjE4MjExNCwiZXhwIjoxNzYyMTg0ODE0fQ.QUD-mN9qf_zmus1rWB3T8GtQpM8t9mHCIJakPNFbuzA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTcsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIxODIxMTQsImV4cCI6MTc2Mjc4NjkxNH0.C8rYUu-xkbBzomz8selHGfOJ8ZsGlMQys6Oy-Dw92j0', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 15:01:54', '2025-11-03 15:01:54', '2025-11-03 15:08:00'),
(144, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTgyNDkwLCJleHAiOjE3NjIxODUxOTB9.gSTYedGD3YGOgsvmPL_dQaUjeX11QKApAj5VrWGgTx8', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE4MjQ5MCwiZXhwIjoxNzYyNzg3MjkwfQ.VcA9PiBXlpAuBuOvTqpqHnuGopLJZAVpE86xla3ATV4', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-10 15:08:10', '2025-11-03 15:08:10', '2025-11-03 15:29:01'),
(145, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMTkwMjY3LCJleHAiOjE3NjIxOTI5Njd9.6Hgvry8hsjrYwlyogJPMMbfUEFWZa6By7m_rPEMAeGA', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjE5MDI2NywiZXhwIjoxNzYyNzk1MDY3fQ.UzfBTYCUUDtAC3JebV_Oob94edSNxy_tt_1EipV27c8', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 17:17:47', '2025-11-03 17:17:47', '2025-11-03 17:24:06'),
(146, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AcmRmLmdvdi5zeiIsInJvbGUiOiJTVVBFUl9VU0VSIiwiaWF0IjoxNzYyMjA4MjUwLCJleHAiOjE3NjIyMTA5NTB9.L8EDzFpS_19lB18syidkWV5FJnRwMEGbVI3q_XAUVr4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidG9rZW5UeXBlIjoicmVmcmVzaCIsImlhdCI6MTc2MjIwODI1MCwiZXhwIjoxNzYyODEzMDUwfQ.lHhQZEI1cbm7jfV1oxIPLJuNvU-SwvJF98fVskBe5Pw', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 22:17:30', '2025-11-03 22:17:30', '2025-11-03 22:57:00'),
(147, 22, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInVzZXJuYW1lIjoiY3ludGhpYSIsImVtYWlsIjoiY3ludGhpYS5tYWtoYWJhbmU5MDQ0QGdtYWlsLmNvbSIsInJvbGUiOiJNSUNST1BST0pFQ1RTIiwiaWF0IjoxNzYyMjEwNjM0LCJleHAiOjE3NjIyMTMzMzR9.n3R9NptcpWzxGfTCWJYLks51bdDNhU7Hxxi_eRgda1A', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjIsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIyMTA2MzQsImV4cCI6MTc2MjgxNTQzNH0.tTl2GIGoRI16h1I_rJPnlJ1_PQepd8lMumlxs5-4xqM', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 0, '2025-11-10 22:57:14', '2025-11-03 22:57:14', '2025-11-03 22:58:11'),
(148, 31, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInVzZXJuYW1lIjoiQm9uZ2l3ZSIsImVtYWlsIjoibWFraGFiYW5lY3ludGhpYUBnbWFpbC5jb20iLCJyb2xlIjoiUFMiLCJpYXQiOjE3NjIyMTA3MDAsImV4cCI6MTc2MjIxMzQwMH0.1lOTiRRdte7xxoyV7bWxgJnk_0c_GsZLouQygx44vhs', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MzEsInRva2VuVHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjIyMTA3MDAsImV4cCI6MTc2MjgxNTUwMH0.8rHO-YjBy6p0P0lMtiudqeTUJ24E8t-hH5XpuNajkWE', '::ffff:127.0.0.1', 'Dart/3.6 (dart:io)', 1, '2025-11-10 22:58:20', '2025-11-03 22:58:20', '2025-11-03 22:58:25');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `application_attachments`
--
ALTER TABLE `application_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `application_comments`
--
ALTER TABLE `application_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `application_workflow`
--
ALTER TABLE `application_workflow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `committee_approvals`
--
ALTER TABLE `committee_approvals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `committee_members`
--
ALTER TABLE `committee_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `eogs`
--
ALTER TABLE `eogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `eog_documents`
--
ALTER TABLE `eog_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `eog_users`
--
ALTER TABLE `eog_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `forms`
--
ALTER TABLE `forms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `form_questions`
--
ALTER TABLE `form_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `form_responses`
--
ALTER TABLE `form_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `user_notification_preferences`
--
ALTER TABLE `user_notification_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

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
