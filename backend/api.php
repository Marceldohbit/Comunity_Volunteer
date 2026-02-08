<?php
// Database configuration
$host = 'localhost';
$dbname = 'com_serve';
$username = 'root';
$password = '';

// Set headers for JSON response and CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Database connection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

// Get request parameters
$action = $_GET['action'] ?? '';
$id = $_GET['id'] ?? null;

// Route requests
switch ($action) {
    case 'getCommunities':
        getCommunities($pdo);
        break;
    
    case 'getCommunity':
        getCommunity($pdo, $id);
        break;
    
    case 'getWorks':
        getWorks($pdo);
        break;
    
    case 'getWork':
        getWork($pdo, $id);
        break;
    
    case 'getCategories':
        getCategories($pdo);
        break;
    
    case 'getRegions':
        getRegions($pdo);
        break;
    
    case 'registerVolunteer':
        registerVolunteer($pdo);
        break;
    
    case 'getStats':
        getStats($pdo);
        break;
    
    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        break;
}

// Function to get all communities
function getCommunities($pdo) {
    try {
        $stmt = $pdo->query("
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
        ");
        
        $communities = $stmt->fetchAll();
        echo json_encode(['success' => true, 'data' => $communities]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch communities: ' . $e->getMessage()]);
    }
}

// Function to get single community
function getCommunity($pdo, $id) {
    if (!$id) {
        http_response_code(400);
        echo json_encode(['error' => 'Community ID is required']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("
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
        ");
        
        $stmt->execute([$id]);
        $community = $stmt->fetch();
        
        if ($community) {
            echo json_encode(['success' => true, 'data' => $community]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Community not found']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch community: ' . $e->getMessage()]);
    }
}

// Function to get all volunteer works
function getWorks($pdo) {
    $communityId = $_GET['community_id'] ?? null;
    $categoryId = $_GET['category_id'] ?? null;
    $search = $_GET['search'] ?? null;
    
    try {
        $sql = "
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
        ";
        
        $params = [];
        
        if ($communityId) {
            $sql .= " AND vw.community_id = ?";
            $params[] = $communityId;
        }
        
        if ($categoryId) {
            $sql .= " AND vw.category_id = ?";
            $params[] = $categoryId;
        }
        
        if ($search) {
            $sql .= " AND (vw.title LIKE ? OR vw.description LIKE ? OR c.slug LIKE ?)";
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        $sql .= " ORDER BY vw.start_date DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        
        $works = $stmt->fetchAll();
        echo json_encode(['success' => true, 'data' => $works]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch works: ' . $e->getMessage()]);
    }
}

// Function to get single volunteer work
function getWork($pdo, $id) {
    if (!$id) {
        http_response_code(400);
        echo json_encode(['error' => 'Work ID is required']);
        return;
    }
    
    try {
        $stmt = $pdo->prepare("
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
        ");
        
        $stmt->execute([$id]);
        $work = $stmt->fetch();
        
        if ($work) {
            echo json_encode(['success' => true, 'data' => $work]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Work not found']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch work: ' . $e->getMessage()]);
    }
}

// Function to get all categories
function getCategories($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT * FROM categories 
            WHERE is_active = 1 
            ORDER BY sort_order ASC
        ");
        
        $categories = $stmt->fetchAll();
        echo json_encode(['success' => true, 'data' => $categories]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch categories: ' . $e->getMessage()]);
    }
}

// Function to get all regions
function getRegions($pdo) {
    try {
        $stmt = $pdo->query("
            SELECT * FROM regions 
            ORDER BY name ASC
        ");
        
        $regions = $stmt->fetchAll();
        echo json_encode(['success' => true, 'data' => $regions]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch regions: ' . $e->getMessage()]);
    }
}

// Function to register volunteer
function registerVolunteer($pdo) {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    $required = ['work_id', 'name', 'email', 'phone'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            http_response_code(400);
            echo json_encode(['error' => "Field '$field' is required"]);
            return;
        }
    }
    
    try {
        // Check if work exists and is accepting volunteers
        $stmt = $pdo->prepare("
            SELECT id, volunteers_needed, volunteers_registered, title 
            FROM volunteer_works 
            WHERE id = ? AND status = 'published' AND deleted_at IS NULL
        ");
        $stmt->execute([$data['work_id']]);
        $work = $stmt->fetch();
        
        if (!$work) {
            http_response_code(404);
            echo json_encode(['error' => 'Volunteer work not found or not accepting applications']);
            return;
        }
        
        if ($work['volunteers_registered'] >= $work['volunteers_needed']) {
            http_response_code(400);
            echo json_encode(['error' => 'This volunteer work has reached its capacity']);
            return;
        }
        
        // Insert volunteer registration
        $stmt = $pdo->prepare("
            INSERT INTO volunteer_registrations 
            (volunteer_work_id, status, application_message, motivation, relevant_skills, 
             emergency_contact_name, emergency_contact_phone, has_transportation, created_at) 
            VALUES (?, 'pending', ?, ?, ?, ?, ?, ?, NOW())
        ");
        
        $stmt->execute([
            $data['work_id'],
            $data['message'] ?? "Application from {$data['name']}",
            $data['motivation'] ?? null,
            $data['interests'] ?? null,
            $data['emergency_name'] ?? null,
            $data['emergency_phone'] ?? null,
            isset($data['transportation']) ? 1 : 0
        ]);
        
        $registrationId = $pdo->lastInsertId();
        
        // Update volunteer count
        $pdo->prepare("
            UPDATE volunteer_works 
            SET volunteers_registered = volunteers_registered + 1 
            WHERE id = ?
        ")->execute([$data['work_id']]);
        
        echo json_encode([
            'success' => true, 
            'message' => 'Registration successful! You will be contacted soon.',
            'registration_id' => $registrationId
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Registration failed: ' . $e->getMessage()]);
    }
}

// Function to get statistics
function getStats($pdo) {
    try {
        // Get total works
        $stmt = $pdo->query("
            SELECT COUNT(*) as total_works 
            FROM volunteer_works 
            WHERE status = 'published' AND deleted_at IS NULL
        ");
        $totalWorks = $stmt->fetch()['total_works'];
        
        // Get total volunteers (from registrations)
        $stmt = $pdo->query("
            SELECT COUNT(*) as total_volunteers 
            FROM volunteer_registrations 
            WHERE status IN ('approved', 'completed') AND deleted_at IS NULL
        ");
        $totalVolunteers = $stmt->fetch()['total_volunteers'];
        
        // Get total communities
        $stmt = $pdo->query("
            SELECT COUNT(*) as total_communities 
            FROM communities 
            WHERE status = 'active' AND deleted_at IS NULL
        ");
        $totalCommunities = $stmt->fetch()['total_communities'];
        
        // Get total volunteer hours
        $stmt = $pdo->query("
            SELECT SUM(total_volunteer_hours) as total_hours 
            FROM communities 
            WHERE deleted_at IS NULL
        ");
        $totalHours = $stmt->fetch()['total_hours'] ?? 0;
        
        echo json_encode([
            'success' => true,
            'data' => [
                'total_works' => (int)$totalWorks,
                'total_volunteers' => (int)$totalVolunteers,
                'total_communities' => (int)$totalCommunities,
                'total_hours' => (int)$totalHours
            ]
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch stats: ' . $e->getMessage()]);
    }
}
