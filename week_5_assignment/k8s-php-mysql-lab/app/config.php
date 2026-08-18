<?php
session_start();
$db = new mysqli(getenv('DB_HOST') ?: 'mysql', getenv('DB_USER') ?: 'student_user', getenv('DB_PASSWORD') ?: 'student_password', getenv('DB_NAME') ?: 'students_db');
if ($db->connect_error) { http_response_code(503); die('Database temporarily unavailable.'); }
$db->set_charset('utf8mb4');
$appName = getenv('APP_NAME') ?: 'Student Registration System';
function e($v) { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
function logged_in() { return isset($_SESSION['student']); }
function require_login() { if (!logged_in()) { header('Location: login.php'); exit; } }
?>
