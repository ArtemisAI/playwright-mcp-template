# Data Extraction Examples

## Basic Element Data Extraction

### Single Element Text Extraction
```javascript
// Extract text from a single element
const title = await page.textContent('h1.page-title');
console.log('Page title:', title);

// Extract with null safety
const safeTitle = await page.locator('h1.page-title').textContent() || 'No title found';

// Extract inner text (respects display/visibility)
const visibleText = await page.innerText('.content-area');

// Extract inner HTML
const htmlContent = await page.innerHTML('.description');
```

### Multiple Elements Extraction
```javascript
// Extract text from multiple elements
const allTitles = await page.locator('h3.scholarship-title').allTextContents();
console.log('All scholarship titles:', allTitles);

// Extract with element mapping
const scholarshipData = await page.locator('.scholarship-item').evaluateAll(elements => 
  elements.map(el => ({
    title: el.querySelector('h3')?.textContent?.trim(),
    amount: el.querySelector('.amount')?.textContent?.trim(),
    deadline: el.querySelector('.deadline')?.textContent?.trim()
  }))
);
```

### Attribute Extraction
```javascript
// Extract specific attributes
const scholarshipUrls = await page.locator('a.scholarship-link').evaluateAll(links => 
  links.map(link => link.href)
);

// Extract multiple attributes from single element
const linkData = await page.evaluate(() => {
  const link = document.querySelector('a.apply-now');
  return {
    href: link?.href,
    text: link?.textContent?.trim(),
    target: link?.target,
    title: link?.title
  };
});
```

## Structured Data Extraction

### Table Data Extraction
```javascript
// Extract complete table data
async function extractTableData(page, tableSelector) {
  return await page.evaluate((selector) => {
    const table = document.querySelector(selector);
    if (!table) return null;
    
    const headers = Array.from(table.querySelectorAll('th')).map(th => th.textContent.trim());
    const rows = Array.from(table.querySelectorAll('tbody tr')).map(row => {
      const cells = Array.from(row.querySelectorAll('td')).map(td => td.textContent.trim());
      const rowData = {};
      headers.forEach((header, index) => {
        rowData[header] = cells[index] || '';
      });
      return rowData;
    });
    
    return { headers, rows };
  }, tableSelector);
}

// Usage
const tableData = await extractTableData(page, '.scholarships-table');
console.log('Table data:', tableData);
```

### List Data Extraction
```javascript
// Extract list items with nested data
async function extractScholarshipList(page) {
  return await page.evaluate(() => {
    const items = Array.from(document.querySelectorAll('.scholarship-item'));
    
    return items.map(item => {
      const titleElement = item.querySelector('h3');
      const amountElement = item.querySelector('.amount');
      const deadlineElement = item.querySelector('.deadline');
      const linkElement = item.querySelector('a');
      const descriptionElement = item.querySelector('.description');
      
      return {
        title: titleElement?.textContent?.trim() || '',
        amount: amountElement?.textContent?.replace('Montant :', '').trim() || '',
        deadline: deadlineElement?.textContent?.replace('Date limite :', '').trim() || '',
        url: linkElement?.href || '',
        description: descriptionElement?.textContent?.trim() || ''
      };
    });
  });
}
```

### Card/Item Data Extraction
```javascript
// Extract data from card-based layouts
async function extractCardData(page, cardSelector) {
  const cards = await page.locator(cardSelector).all();
  const cardData = [];
  
  for (const card of cards) {
    const data = {
      title: await card.locator('h3, .title').textContent() || '',
      subtitle: await card.locator('.subtitle, .category').textContent() || '',
      content: await card.locator('.content, .description').textContent() || '',
      link: await card.locator('a').getAttribute('href') || '',
      image: await card.locator('img').getAttribute('src') || ''
    };
    
    cardData.push(data);
  }
  
  return cardData;
}
```

## Advanced Data Extraction Patterns

### UdeM Scholarship Portal Extraction
```javascript
async function extractUdeMScholarships(page) {
  // Navigate to filtered results
  await page.goto('https://bourses.umontreal.ca/repertoire-des-bourses/?tx_udembourses[do_search]=1&tx_udembourses[tb][]=4');
  await page.waitForSelector('.scholarship-results');
  
  // Extract all scholarship data
  const scholarships = await page.evaluate(() => {
    const scholarshipLinks = Array.from(document.querySelectorAll('a[href*="detail-dune-bourse"]'));
    
    return scholarshipLinks.map(link => {
      // Extract title
      const titleElement = link.querySelector('h3');
      const title = titleElement?.textContent?.trim() || '';
      
      // Extract amount and deadline from paragraphs
      const paragraphs = Array.from(link.querySelectorAll('p'));
      const amountText = paragraphs[0]?.textContent || '';
      const deadlineText = paragraphs[1]?.textContent || '';
      
      // Clean up the text
      const amount = amountText.replace('Montant :', '').trim();
      const deadline = deadlineText.replace('Date limite :', '').trim();
      
      // Extract description
      const descriptionElement = link.querySelector('.description, p:last-child');
      const description = descriptionElement?.textContent?.trim() || '';
      
      return {
        title,
        amount,
        deadline,
        description,
        url: link.href
      };
    });
  });
  
  return scholarships;
}
```

### Detailed Scholarship Information Extraction
```javascript
async function extractScholarshipDetails(page, scholarshipUrl) {
  await page.goto(scholarshipUrl);
  await page.waitForSelector('.scholarship-detail');
  
  const details = await page.evaluate(() => {
    const extractSection = (selector) => {
      const element = document.querySelector(selector);
      return element?.textContent?.trim() || '';
    };
    
    const extractList = (selector) => {
      const elements = document.querySelectorAll(selector);
      return Array.from(elements).map(el => el.textContent?.trim() || '');
    };
    
    return {
      title: extractSection('h1, .scholarship-title'),
      amount: extractSection('.amount, .prize-amount'),
      deadline: extractSection('.deadline, .application-deadline'),
      description: extractSection('.description, .scholarship-description'),
      eligibility: extractList('.eligibility li, .criteria li'),
      requirements: extractList('.requirements li, .documents li'),
      applicationProcess: extractSection('.application-process, .how-to-apply'),
      contact: {
        email: document.querySelector('a[href^="mailto:"]')?.href?.replace('mailto:', '') || '',
        phone: extractSection('.phone, .contact-phone'),
        office: extractSection('.office, .contact-office')
      },
      additionalInfo: extractSection('.additional-info, .notes')
    };
  });
  
  return details;
}
```

## Data Cleaning and Processing

### Text Cleaning Functions
```javascript
// Clean extracted text data
function cleanExtractedData(rawData) {
  return rawData.map(item => ({
    title: cleanText(item.title),
    amount: cleanAmount(item.amount),
    deadline: cleanDeadline(item.deadline),
    description: cleanText(item.description),
    url: item.url
  }));
}

function cleanText(text) {
  if (!text) return '';
  return text
    .replace(/\s+/g, ' ')
    .replace(/\n+/g, ' ')
    .replace(/\t+/g, ' ')
    .trim();
}

function cleanAmount(amountText) {
  if (!amountText) return '';
  return amountText
    .replace(/Montant\s*:?\s*/i, '')
    .replace(/Amount\s*:?\s*/i, '')
    .trim();
}

function cleanDeadline(deadlineText) {
  if (!deadlineText) return '';
  return deadlineText
    .replace(/Date limite\s*:?\s*/i, '')
    .replace(/Deadline\s*:?\s*/i, '')
    .trim();
}
```

### Data Validation
```javascript
// Validate extracted data
function validateScholarshipData(scholarships) {
  const validScholarships = [];
  const errors = [];
  
  scholarships.forEach((scholarship, index) => {
    const issues = [];
    
    // Check required fields
    if (!scholarship.title || scholarship.title.length < 3) {
      issues.push('Invalid or missing title');
    }
    
    if (!scholarship.amount) {
      issues.push('Missing amount information');
    }
    
    if (!scholarship.deadline) {
      issues.push('Missing deadline information');
    }
    
    if (!scholarship.url || !scholarship.url.startsWith('http')) {
      issues.push('Invalid or missing URL');
    }
    
    if (issues.length === 0) {
      validScholarships.push(scholarship);
    } else {
      errors.push({ index, issues, data: scholarship });
    }
  });
  
  return { validScholarships, errors };
}
```

## Real-Time Data Extraction

### Dynamic Content Extraction
```javascript
// Extract data from dynamically loaded content
async function extractDynamicContent(page, triggerSelector, contentSelector) {
  // Trigger content load
  await page.click(triggerSelector);
  
  // Wait for content to appear
  await page.waitForSelector(contentSelector);
  
  // Wait for loading indicators to disappear
  await page.waitForSelector('.loading', { state: 'hidden' });
  
  // Extract the dynamic content
  const content = await page.locator(contentSelector).textContent();
  return content;
}
```

### Infinite Scroll Data Extraction
```javascript
async function extractFromInfiniteScroll(page, itemSelector) {
  const allItems = [];
  let previousCount = 0;
  let currentCount = 0;
  
  do {
    // Get current item count
    previousCount = currentCount;
    currentCount = await page.locator(itemSelector).count();
    
    // Extract new items
    const items = await page.locator(itemSelector).all();
    for (let i = previousCount; i < currentCount; i++) {
      const itemData = await extractItemData(items[i]);
      allItems.push(itemData);
    }
    
    // Scroll to load more
    await page.evaluate(() => {
      window.scrollTo(0, document.body.scrollHeight);
    });
    
    // Wait for new content to load
    await page.waitForTimeout(2000);
    
  } while (currentCount > previousCount);
  
  return allItems;
}
```

## Data Export and Storage

### JSON Export
```javascript
// Export extracted data to JSON
async function exportToJSON(data, filename) {
  const jsonData = JSON.stringify(data, null, 2);
  await require('fs').promises.writeFile(filename, jsonData, 'utf8');
  console.log(`Data exported to ${filename}`);
}

// Usage
const scholarshipData = await extractUdeMScholarships(page);
await exportToJSON(scholarshipData, 'scholarships.json');
```

### CSV Export
```javascript
// Export to CSV format
async function exportToCSV(data, filename) {
  if (data.length === 0) return;
  
  // Get headers from first object
  const headers = Object.keys(data[0]);
  
  // Create CSV content
  const csvContent = [
    headers.join(','), // Header row
    ...data.map(row => 
      headers.map(header => 
        `"${(row[header] || '').toString().replace(/"/g, '""')}"`
      ).join(',')
    )
  ].join('\n');
  
  await require('fs').promises.writeFile(filename, csvContent, 'utf8');
  console.log(`Data exported to ${filename}`);
}
```

### Structured Data Update
```javascript
// Update existing data files with new extractions
async function updateScholarshipData(newData, existingDataFile) {
  let existingData = [];
  
  try {
    const fileContent = await require('fs').promises.readFile(existingDataFile, 'utf8');
    existingData = JSON.parse(fileContent);
  } catch (error) {
    console.log('No existing data file found, creating new one');
  }
  
  // Merge data (avoid duplicates based on URL)
  const mergedData = [...existingData];
  const existingUrls = new Set(existingData.map(item => item.url));
  
  newData.forEach(item => {
    if (!existingUrls.has(item.url)) {
      mergedData.push(item);
    }
  });
  
  // Save updated data
  await exportToJSON(mergedData, existingDataFile);
  
  return {
    total: mergedData.length,
    new: newData.length,
    existing: existingData.length
  };
}
```
