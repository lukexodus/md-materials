## PHP Form Handling


### $\_GET and $\_POST Superglobals

PHP provides special arrays called superglobals that store external data from various sources, including forms. The two most commonly used for form handling are `$_GET` and `$_POST`.

**Key Points:**

- Superglobals are automatically available in all scopes
- `$_GET` retrieves data sent through URL parameters
- `$_POST` retrieves data sent through HTTP POST method
- Form data is automatically parsed into these arrays
- Values are always strings unless transformed

#### Using $_GET

The `$_GET` superglobal contains data sent through URL query parameters, typically from forms with `method="get"` or direct URL access:

```php
// URL: example.php?name=John&age=30

// Accessing $_GET data
$name = $_GET['name'] ?? ''; // Using null coalescing operator (PHP 7+)
$age = $_GET['age'] ?? '';

echo "Name: $name, Age: $age"; // Output: Name: John, Age: 30

// Checking if a parameter exists
if (isset($_GET['name'])) {
    echo "Name parameter is set";
}

// Looping through all GET parameters
foreach ($_GET as $key => $value) {
    echo "$key: $value<br>";
}
```

GET method characteristics:

- Data is visible in the URL
- Limited to approximately 2000 characters
- Can be bookmarked
- Should never be used for sensitive data
- Ideal for search queries and non-sensitive filters

#### Using $\_POST

The `$_POST` superglobal contains data sent through HTTP POST method, typically from forms with `method="post"`:

```php
// HTML form (form.html)
/*
<form action="process.php" method="post">
    <input type="text" name="username">
    <input type="password" name="password">
    <button type="submit">Submit</button>
</form>
*/

// PHP processing script (process.php)
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

echo "Username: $username"; // Output depends on form submission

// Checking if the form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    echo "Form was submitted using POST method";
}

// Handling form fields with array notation
/*
<form method="post">
    <input type="checkbox" name="interests[]" value="sports"> Sports
    <input type="checkbox" name="interests[]" value="music"> Music
    <input type="checkbox" name="interests[]" value="movies"> Movies
</form>
*/

// Processing checkboxes as an array
if (isset($_POST['interests'])) {
    echo "Selected interests: ";
    foreach ($_POST['interests'] as $interest) {
        echo "$interest, ";
    }
}
```

POST method characteristics:

- Data is sent in the HTTP request body (not visible in URL)
- No practical size limit (server settings dependent)
- Cannot be bookmarked
- More secure for sensitive data (though still requires HTTPS)
- Ideal for submitting data that changes server state

#### Combining $\_GET and $\_POST

Sometimes you might need to use both methods together:

```php
// URL: form_handler.php?source=homepage

// HTML form
/*
<form action="form_handler.php?source=homepage" method="post">
    <input type="text" name="username">
    <button type="submit">Submit</button>
</form>
*/

// PHP processing
$source = $_GET['source'] ?? 'unknown';
$username = $_POST['username'] ?? '';

echo "Form submitted from $source by $username";
```

#### REQUEST Superglobal

The `$_REQUEST` array contains data from `$_GET`, `$_POST`, and `$_COOKIE`:

```php
// Accessing data without knowing the submission method
$username = $_REQUEST['username'] ?? '';

// Note: Using $_REQUEST is generally discouraged as it makes it harder to 
// determine the source of data and may lead to security issues
```

### Form Validation Basics

Form validation is crucial for ensuring that the data received from forms is valid, safe, and in the expected format.

**Key Points:**

- Never trust user input
- Validate on both client-side (JavaScript) and server-side (PHP)
- Server-side validation is mandatory for security
- Use different validation techniques based on the data type
- Always sanitize data before using it

#### Basic Validation Workflow

```php
<?php
// Initialize variables to store form data and error messages
$name = $email = $website = $comment = $gender = '';
$nameErr = $emailErr = $websiteErr = $genderErr = '';

// Check if the form was submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // Validate name
    if (empty($_POST['name'])) {
        $nameErr = "Name is required";
    } else {
        $name = test_input($_POST['name']);
        // Check if name contains only letters and whitespace
        if (!preg_match("/^[a-zA-Z-' ]*$/", $name)) {
            $nameErr = "Only letters and white space allowed";
        }
    }
    
    // Validate email
    if (empty($_POST['email'])) {
        $emailErr = "Email is required";
    } else {
        $email = test_input($_POST['email']);
        // Check if email is valid
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $emailErr = "Invalid email format";
        }
    }
    
    // Validate website (optional)
    if (!empty($_POST['website'])) {
        $website = test_input($_POST['website']);
        // Check if URL syntax is valid
        if (!filter_var($website, FILTER_VALIDATE_URL)) {
            $websiteErr = "Invalid URL format";
        }
    }
    
    // Validate comment (optional)
    if (!empty($_POST['comment'])) {
        $comment = test_input($_POST['comment']);
    }
    
    // Validate gender
    if (empty($_POST['gender'])) {
        $genderErr = "Gender is required";
    } else {
        $gender = test_input($_POST['gender']);
    }
    
    // If no errors, process the form data
    if (empty($nameErr) && empty($emailErr) && empty($websiteErr) && empty($genderErr)) {
        // Process valid data (e.g., save to database, send email)
        echo "Form submitted successfully!";
    }
}

// Function to sanitize and validate input data
function test_input($data) {
    $data = trim($data);           // Remove extra spaces, tabs, newlines
    $data = stripslashes($data);   // Remove backslashes
    $data = htmlspecialchars($data); // Convert special characters to HTML entities
    return $data;
}
?>

<!-- Display the form with validation messages -->
<form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>">
    Name: <input type="text" name="name" value="<?php echo $name; ?>">
    <span class="error"><?php echo $nameErr; ?></span><br>
    
    Email: <input type="text" name="email" value="<?php echo $email; ?>">
    <span class="error"><?php echo $emailErr; ?></span><br>
    
    Website: <input type="text" name="website" value="<?php echo $website; ?>">
    <span class="error"><?php echo $websiteErr; ?></span><br>
    
    Comment: <textarea name="comment"><?php echo $comment; ?></textarea><br>
    
    Gender:
    <input type="radio" name="gender" value="female" <?php if ($gender == "female") echo "checked"; ?>> Female
    <input type="radio" name="gender" value="male" <?php if ($gender == "male") echo "checked"; ?>> Male
    <span class="error"><?php echo $genderErr; ?></span><br>
    
    <input type="submit" name="submit" value="Submit">
</form>
```

#### Common Validation Techniques

```php
// Validating numeric input
if (!is_numeric($_POST['age'])) {
    $ageErr = "Age must be a number";
}

// Validating integers
if (!filter_var($_POST['zip'], FILTER_VALIDATE_INT)) {
    $zipErr = "ZIP code must be an integer";
}

// Validating range
$age = (int)$_POST['age'];
if ($age < 18 || $age > 120) {
    $ageErr = "Age must be between 18 and 120";
}

// Validating with regular expressions
if (!preg_match("/^[0-9]{5}(-[0-9]{4})?$/", $_POST['zip'])) {
    $zipErr = "Invalid ZIP code format";
}

// Validating dates
$date = $_POST['birthdate'];
$d = DateTime::createFromFormat('Y-m-d', $date);
if (!$d || $d->format('Y-m-d') != $date) {
    $dateErr = "Invalid date format (YYYY-MM-DD required)";
}

// Validating password strength
$password = $_POST['password'];
if (strlen($password) < 8) {
    $pwdErr = "Password must be at least 8 characters";
} elseif (!preg_match("#[0-9]+#", $password)) {
    $pwdErr = "Password must include at least one number";
} elseif (!preg_match("#[a-zA-Z]+#", $password)) {
    $pwdErr = "Password must include at least one letter";
}

// Validating file extensions
$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
$filename = $_FILES['image']['name'];
$fileExtension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
if (!in_array($fileExtension, $allowedExtensions)) {
    $fileErr = "Only JPG, JPEG, PNG & GIF files are allowed";
}
```

#### Using Filter Functions

PHP provides built-in functions for validating and sanitizing data:

```php
// Validating an email address
$email = $_POST['email'];
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $emailErr = "Invalid email format";
}

// Validating an IP address
$ip = $_POST['server_ip'];
if (!filter_var($ip, FILTER_VALIDATE_IP)) {
    $ipErr = "Invalid IP address";
}

// Sanitizing a string
$name = filter_var($_POST['name'], FILTER_SANITIZE_STRING); // Note: deprecated in PHP 8.1+
// Alternative in PHP 8.1+:
$name = htmlspecialchars($_POST['name']);

// Sanitizing an email
$email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);

// Sanitizing a URL
$url = filter_var($_POST['website'], FILTER_SANITIZE_URL);

// Combining validation and sanitization
$age = filter_var($_POST['age'], FILTER_VALIDATE_INT, [
    'options' => [
        'min_range' => 1, 
        'max_range' => 120
    ]
]);
if ($age === false) {
    $ageErr = "Age must be an integer between 1 and 120";
}
```

#### CSRF Protection

Cross-Site Request Forgery (CSRF) protection prevents unauthorized commands from being submitted:

```php
// Start session at the beginning of the script
session_start();

// Create a CSRF token
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
$csrf_token = $_SESSION['csrf_token'];

// In the form
?>
<form method="post" action="process.php">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    <!-- Other form fields -->
    <button type="submit">Submit</button>
</form>
<?php

// When processing the form
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Verify CSRF token
    if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
        die("CSRF token validation failed");
    }
    
    // Process form data
}
```

### File Uploads with $\_FILES

PHP makes it easy to handle file uploads through the `$_FILES` superglobal.

**Key Points:**

- Configure PHP settings in php.ini for file uploads
- Use `enctype="multipart/form-data"` in the form tag
- The `$_FILES` array contains file information
- Always validate file type, size, and extension
- Move uploaded files from temporary directory to permanent location

#### Basic File Upload Form

```html
<form action="upload.php" method="post" enctype="multipart/form-data">
    Select file to upload:
    <input type="file" name="fileToUpload" id="fileToUpload">
    <input type="submit" value="Upload File" name="submit">
</form>
```

#### Processing File Uploads

```php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['fileToUpload'])) {
    $targetDir = "uploads/";
    $targetFile = $targetDir . basename($_FILES["fileToUpload"]["name"]);
    $uploadOk = 1;
    $fileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
    
    // Check if file already exists
    if (file_exists($targetFile)) {
        echo "Sorry, file already exists.";
        $uploadOk = 0;
    }
    
    // Check file size (limit to 2MB)
    if ($_FILES["fileToUpload"]["size"] > 2000000) {
        echo "Sorry, your file is too large.";
        $uploadOk = 0;
    }
    
    // Allow only certain file formats
    $allowedTypes = ["jpg", "jpeg", "png", "gif", "pdf"];
    if (!in_array($fileType, $allowedTypes)) {
        echo "Sorry, only JPG, JPEG, PNG, GIF & PDF files are allowed.";
        $uploadOk = 0;
    }
    
    // Check if $uploadOk is set to 0 by an error
    if ($uploadOk == 0) {
        echo "Sorry, your file was not uploaded.";
    } else {
        // Try to upload file
        if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $targetFile)) {
            echo "The file " . htmlspecialchars(basename($_FILES["fileToUpload"]["name"])) . " has been uploaded.";
        } else {
            echo "Sorry, there was an error uploading your file.";
        }
    }
}
?>
```

#### Understanding the $\_FILES Array

The `$_FILES` superglobal contains an array with information about uploaded files:

```php
/*
$_FILES['fileToUpload'] structure:
[
    'name'      => 'example.jpg',    // Original filename
    'type'      => 'image/jpeg',     // MIME type
    'tmp_name'  => '/tmp/php7A1.tmp', // Temporary file path
    'error'     => 0,                // Error code (0 means no error)
    'size'      => 123456            // File size in bytes
]
*/

// Accessing file information
$fileName = $_FILES['fileToUpload']['name'];
$fileType = $_FILES['fileToUpload']['type'];
$fileTmpPath = $_FILES['fileToUpload']['tmp_name'];
$fileError = $_FILES['fileToUpload']['error'];
$fileSize = $_FILES['fileToUpload']['size'];

// Check for upload errors
if ($fileError !== UPLOAD_ERR_OK) {
    switch ($fileError) {
        case UPLOAD_ERR_INI_SIZE:
            echo "The uploaded file exceeds the upload_max_filesize directive in php.ini";
            break;
        case UPLOAD_ERR_FORM_SIZE:
            echo "The uploaded file exceeds the MAX_FILE_SIZE directive in the HTML form";
            break;
        case UPLOAD_ERR_PARTIAL:
            echo "The uploaded file was only partially uploaded";
            break;
        case UPLOAD_ERR_NO_FILE:
            echo "No file was uploaded";
            break;
        case UPLOAD_ERR_NO_TMP_DIR:
            echo "Missing a temporary folder";
            break;
        case UPLOAD_ERR_CANT_WRITE:
            echo "Failed to write file to disk";
            break;
        case UPLOAD_ERR_EXTENSION:
            echo "A PHP extension stopped the file upload";
            break;
        default:
            echo "Unknown upload error";
            break;
    }
    exit;
}
```

#### Handling Multiple File Uploads

```html
<form action="multiple_upload.php" method="post" enctype="multipart/form-data">
    Select files to upload:
    <input type="file" name="files[]" multiple>
    <input type="submit" value="Upload Files" name="submit">
</form>
```

```php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['files'])) {
    $targetDir = "uploads/";
    $allowedTypes = ["jpg", "jpeg", "png", "gif"];
    $maxFileSize = 2000000; // 2MB
    $uploadedFiles = 0;
    $errors = [];
    
    // Count total files
    $totalFiles = count($_FILES['files']['name']);
    
    // Loop through each file
    for ($i = 0; $i < $totalFiles; $i++) {
        // Skip if there's an error or no file
        if ($_FILES['files']['error'][$i] !== UPLOAD_ERR_OK || $_FILES['files']['size'][$i] === 0) {
            $errors[] = "Error with file " . ($_FILES['files']['name'][$i] ?? "unknown");
            continue;
        }
        
        // Get file information
        $fileName = basename($_FILES['files']['name'][$i]);
        $targetFile = $targetDir . $fileName;
        $fileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
        $fileSize = $_FILES['files']['size'][$i];
        
        // Validate file
        if (!in_array($fileType, $allowedTypes)) {
            $errors[] = "File type not allowed for $fileName";
            continue;
        }
        
        if ($fileSize > $maxFileSize) {
            $errors[] = "File size too large for $fileName";
            continue;
        }
        
        // Try to upload file
        if (move_uploaded_file($_FILES['files']['tmp_name'][$i], $targetFile)) {
            $uploadedFiles++;
        } else {
            $errors[] = "Failed to upload $fileName";
        }
    }
    
    echo "Successfully uploaded $uploadedFiles files.";
    
    if (!empty($errors)) {
        echo "<br>Errors:<br>";
        foreach ($errors as $error) {
            echo "- $error<br>";
        }
    }
}
?>
```

#### Secure File Upload Best Practices

```php
// Generate a unique filename to prevent overwriting
$newFileName = uniqid() . '.' . $fileType;
$targetFile = $targetDir . $newFileName;

// Store the original filename in the database
$originalFileName = $_FILES['fileToUpload']['name'];

// Check MIME type with finfo (more secure than relying on $_FILES['type'])
$finfo = new finfo(FILEINFO_MIME_TYPE);
$fileContents = file_get_contents($_FILES['fileToUpload']['tmp_name']);
$mimeType = $finfo->buffer($fileContents);

// List of allowed MIME types
$allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf'
];

if (!in_array($mimeType, $allowedMimeTypes)) {
    echo "File type not allowed based on content analysis.";
    exit;
}

// Store uploaded files outside the web root
$targetDir = dirname(__DIR__) . '/secure_uploads/';

// Set proper permissions on uploaded files
if (move_uploaded_file($_FILES['fileToUpload']['tmp_name'], $targetFile)) {
    chmod($targetFile, 0644); // Set read-only for user and group
    echo "File uploaded successfully.";
} else {
    echo "Upload failed.";
}
```

#### Image Processing After Upload

You can use the GD or Imagick libraries to process images after upload:

```php
// Using GD to create a thumbnail
if ($fileType == "jpg" || $fileType == "jpeg") {
    // Create image from uploaded file
    $source = imagecreatefromjpeg($targetFile);
    
    // Get original image dimensions
    list($width, $height) = getimagesize($targetFile);
    
    // Set thumbnail dimensions
    $thumbWidth = 200;
    $thumbHeight = ($height / $width) * $thumbWidth;
    
    // Create thumbnail image
    $thumb = imagecreatetruecolor($thumbWidth, $thumbHeight);
    
    // Resize
    imagecopyresampled($thumb, $source, 0, 0, 0, 0, $thumbWidth, $thumbHeight, $width, $height);
    
    // Save thumbnail
    $thumbFile = $targetDir . "thumb_" . basename($targetFile);
    imagejpeg($thumb, $thumbFile, 80);
    
    // Free memory
    imagedestroy($source);
    imagedestroy($thumb);
    
    echo "Thumbnail created successfully.";
}
```

**Conclusion:** Proper form handling is essential for creating interactive and secure PHP applications. Understanding how to work with `$_GET` and `$_POST` superglobals allows you to capture user input, while validation ensures data integrity and security. File uploads add a powerful dimension to your applications but require careful handling to prevent security vulnerabilities. By following best practices for form processing, validation, and file handling, you can create robust PHP applications that safely and effectively handle user input.

Important subtopics related to PHP form handling include:

- AJAX form submissions
- Form handling with PHP frameworks
- Creating reusable form validation classes
- Server-side form generation
- Security considerations like XSS prevention

---

