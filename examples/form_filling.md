# Form Filling Examples

## Basic Form Interactions

### Text Input Fields
```javascript
// Fill text input
await page.fill('input[name="email"]', 'user@example.com');

// Clear and fill
await page.locator('input[name="firstName"]').clear();
await page.locator('input[name="firstName"]').fill('John');

// Type with delay (useful for dynamic forms)
await page.type('input[name="search"]', 'scholarship', { delay: 100 });

// Fill multiple fields
await page.fill('input[name="firstName"]', 'John');
await page.fill('input[name="lastName"]', 'Doe');
await page.fill('input[name="email"]', 'john.doe@example.com');
```

### Textarea Fields
```javascript
// Fill textarea with multiple lines
const longText = `This is a long description
that spans multiple lines
and contains detailed information.`;

await page.fill('textarea[name="description"]', longText);

// Clear existing content first
await page.locator('textarea[name="motivation"]').clear();
await page.locator('textarea[name="motivation"]').fill('My motivation for applying...');
```

### Password Fields
```javascript
// Fill password field
await page.fill('input[type="password"]', 'SecurePassword123');

// Handle password confirmation
await page.fill('input[name="password"]', 'SecurePassword123');
await page.fill('input[name="confirmPassword"]', 'SecurePassword123');
```

## Selection Elements

### Dropdown/Select Elements
```javascript
// Select by value
await page.selectOption('select[name="program"]', 'masters');

// Select by text
await page.selectOption('select[name="faculty"]', { label: 'Engineering' });

// Select multiple options
await page.selectOption('select[name="interests"]', ['research', 'teaching', 'industry']);

// Handle dynamic dropdowns
await page.click('select[name="country"]');
await page.waitForSelector('option[value="CA"]');
await page.selectOption('select[name="country"]', 'CA');
```

### Radio Buttons
```javascript
// Select radio button by value
await page.check('input[name="gender"][value="other"]');

// Select by label text
await page.check('input[name="status"] + label:has-text("Student")');

// Check if radio button is already selected
const isSelected = await page.isChecked('input[name="program"][value="phd"]');
if (!isSelected) {
  await page.check('input[name="program"][value="phd"]');
}
```

### Checkboxes
```javascript
// Check a checkbox
await page.check('input[name="newsletter"]');

// Uncheck a checkbox
await page.uncheck('input[name="promotional"]');

// Toggle checkbox state
const isChecked = await page.isChecked('input[name="terms"]');
if (!isChecked) {
  await page.check('input[name="terms"]');
}

// Check multiple checkboxes
const interests = ['research', 'teaching', 'mentoring'];
for (const interest of interests) {
  await page.check(`input[name="interests"][value="${interest}"]`);
}
```

## Complex Form Scenarios

### Scholarship Application Form
```javascript
async function fillScholarshipApplication(page, applicationData) {
  // Personal Information
  await page.fill('input[name="firstName"]', applicationData.firstName);
  await page.fill('input[name="lastName"]', applicationData.lastName);
  await page.fill('input[name="email"]', applicationData.email);
  await page.fill('input[name="studentId"]', applicationData.studentId);
  
  // Academic Information
  await page.selectOption('select[name="program"]', applicationData.program);
  await page.selectOption('select[name="year"]', applicationData.academicYear);
  await page.fill('input[name="gpa"]', applicationData.gpa.toString());
  
  // Scholarship Details
  await page.fill('textarea[name="motivation"]', applicationData.motivation);
  await page.fill('textarea[name="achievements"]', applicationData.achievements);
  
  // File Uploads
  if (applicationData.transcript) {
    await page.setInputFiles('input[name="transcript"]', applicationData.transcript);
  }
  
  // Terms and Conditions
  await page.check('input[name="agreeTerms"]');
  
  return 'Application form filled successfully';
}

// Usage
const applicationData = {
  firstName: 'Ana Luna',
  lastName: 'Gonzalez Bonilla',
  email: 'ana.luna@example.com',
  studentId: '12345678',
  program: 'masters',
  academicYear: '2025',
  gpa: '3.8',
  motivation: 'My motivation for applying to this scholarship...',
  achievements: 'My key achievements include...',
  transcript: 'path/to/transcript.pdf'
};

await fillScholarshipApplication(page, applicationData);
```

### UdeM Engagement Scholarship Form
```javascript
async function fillEngagementScholarship(page, data) {
  // Navigate to application form
  await page.goto('https://bourses.umontreal.ca/apply/engagement');
  await page.waitForSelector('form.scholarship-application');
  
  // Personal Information Section
  await page.fill('input[name="nom"]', data.lastName);
  await page.fill('input[name="prenom"]', data.firstName);
  await page.fill('input[name="courriel"]', data.email);
  await page.fill('input[name="telephone"]', data.phone);
  
  // Academic Information
  await page.selectOption('select[name="programme"]', data.program);
  await page.selectOption('select[name="niveau"]', data.level);
  await page.fill('input[name="numero_etudiant"]', data.studentNumber);
  
  // Engagement Description
  await page.fill('textarea[name="description_engagement"]', data.engagementDescription);
  await page.fill('textarea[name="impact_communaute"]', data.communityImpact);
  await page.fill('textarea[name="objectifs_futurs"]', data.futureGoals);
  
  // Supporting Documents
  if (data.recommendationLetter) {
    await page.setInputFiles('input[name="lettre_recommandation"]', data.recommendationLetter);
  }
  
  if (data.engagementProof) {
    await page.setInputFiles('input[name="preuve_engagement"]', data.engagementProof);
  }
  
  // Confirmation
  await page.check('input[name="confirmation_exactitude"]');
  await page.check('input[name="autorisation_verification"]');
  
  console.log('Engagement scholarship form completed');
}
```

## File Upload Handling

### Single File Upload
```javascript
// Upload a single file
await page.setInputFiles('input[type="file"]', 'path/to/document.pdf');

// Upload with file chooser dialog
page.on('filechooser', async (fileChooser) => {
  await fileChooser.setFiles('path/to/document.pdf');
});

await page.click('button:has-text("Upload File")');
```

### Multiple File Upload
```javascript
// Upload multiple files
const files = [
  'path/to/transcript.pdf',
  'path/to/recommendation.pdf',
  'path/to/cv.pdf'
];

await page.setInputFiles('input[name="documents"]', files);

// Handle each file input separately
await page.setInputFiles('input[name="transcript"]', 'path/to/transcript.pdf');
await page.setInputFiles('input[name="cv"]', 'path/to/cv.pdf');
await page.setInputFiles('input[name="letter"]', 'path/to/letter.pdf');
```

### File Upload with Validation
```javascript
async function uploadWithValidation(page, fileSelector, filePath) {
  // Upload file
  await page.setInputFiles(fileSelector, filePath);
  
  // Wait for upload confirmation
  await page.waitForSelector('.upload-success', { timeout: 10000 });
  
  // Verify file was uploaded
  const uploadedFileName = await page.textContent('.uploaded-file-name');
  console.log('Uploaded file:', uploadedFileName);
  
  return uploadedFileName;
}
```

## Form Validation and Error Handling

### Handling Validation Errors
```javascript
async function submitFormWithValidation(page) {
  // Fill required fields
  await page.fill('input[name="email"]', 'invalid-email');
  
  // Attempt to submit
  await page.click('button[type="submit"]');
  
  // Check for validation errors
  const errorMessages = await page.locator('.error-message').allTextContents();
  
  if (errorMessages.length > 0) {
    console.log('Validation errors found:', errorMessages);
    
    // Fix email format
    await page.fill('input[name="email"]', 'valid@email.com');
    
    // Submit again
    await page.click('button[type="submit"]');
  }
  
  // Wait for success confirmation
  await page.waitForSelector('.success-message');
}
```

### Form Field Validation States
```javascript
// Check if field is required
const isRequired = await page.getAttribute('input[name="email"]', 'required') !== null;

// Check field validation state
const isValid = await page.evaluate((selector) => {
  const field = document.querySelector(selector);
  return field.checkValidity();
}, 'input[name="email"]');

// Wait for field to become valid
await page.waitForFunction((selector) => {
  const field = document.querySelector(selector);
  return field.checkValidity();
}, 'input[name="email"]');
```

## Dynamic Form Handling

### Conditional Fields
```javascript
async function handleConditionalFields(page) {
  // Select option that reveals additional fields
  await page.selectOption('select[name="applicationType"]', 'international');
  
  // Wait for conditional fields to appear
  await page.waitForSelector('input[name="visaStatus"]', { state: 'visible' });
  
  // Fill conditional fields
  await page.selectOption('select[name="visaStatus"]', 'student-visa');
  await page.fill('input[name="passportNumber"]', 'AB1234567');
}
```

### Multi-Step Forms
```javascript
async function fillMultiStepForm(page, formData) {
  // Step 1: Personal Information
  await fillPersonalInfo(page, formData.personal);
  await page.click('button:has-text("Next")');
  await page.waitForSelector('.step-2');
  
  // Step 2: Academic Information
  await fillAcademicInfo(page, formData.academic);
  await page.click('button:has-text("Next")');
  await page.waitForSelector('.step-3');
  
  // Step 3: Documents
  await uploadDocuments(page, formData.documents);
  await page.click('button:has-text("Next")');
  await page.waitForSelector('.step-4');
  
  // Step 4: Review and Submit
  await reviewAndSubmit(page);
}
```

### Auto-Save Forms
```javascript
async function handleAutoSaveForm(page, data) {
  // Fill form with auto-save enabled
  await page.fill('input[name="firstName"]', data.firstName);
  
  // Wait for auto-save indicator
  await page.waitForSelector('.auto-saved', { timeout: 5000 });
  
  // Continue filling
  await page.fill('input[name="lastName"]', data.lastName);
  await page.waitForSelector('.auto-saved');
  
  console.log('Form auto-saved successfully');
}
```

## Form Submission

### Basic Form Submission
```javascript
// Submit form and wait for navigation
await Promise.all([
  page.waitForNavigation({ waitUntil: 'networkidle' }),
  page.click('button[type="submit"]')
]);

// Submit form and wait for success message
await page.click('button[type="submit"]');
await page.waitForSelector('.success-message');
```

### Submission with Confirmation
```javascript
async function submitWithConfirmation(page) {
  // Click submit button
  await page.click('button[type="submit"]');
  
  // Handle confirmation dialog
  page.once('dialog', async (dialog) => {
    console.log('Confirmation dialog:', dialog.message());
    await dialog.accept();
  });
  
  // Wait for submission result
  await page.waitForSelector('.submission-result');
  
  const result = await page.textContent('.submission-result');
  return result;
}
```

### Handling Submission Errors
```javascript
async function submitFormWithErrorHandling(page) {
  try {
    await page.click('button[type="submit"]');
    
    // Wait for either success or error
    await Promise.race([
      page.waitForSelector('.success-message'),
      page.waitForSelector('.error-message')
    ]);
    
    // Check which one appeared
    const hasSuccess = await page.locator('.success-message').count() > 0;
    const hasError = await page.locator('.error-message').count() > 0;
    
    if (hasSuccess) {
      console.log('Form submitted successfully');
      return 'success';
    } else if (hasError) {
      const errorText = await page.textContent('.error-message');
      console.log('Submission error:', errorText);
      return 'error';
    }
  } catch (error) {
    console.log('Submission failed:', error.message);
    return 'failed';
  }
}
```
