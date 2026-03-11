# 📘 SharePoint DMS Setup Guide

## קובץ זה מסביר איך להריץ את המערכת על SharePoint שלך

---

## שלב 1: התקנת PnP PowerShell

פתח PowerShell **כמנהל** והרץ:

```powershell
Install-Module PnP.PowerShell -Force -AllowClobber -Scope CurrentUser
```

---

## שלב 2: הרצת סקריפט ההתקנה

1. עבור לתיקיית הפרויקט:
```powershell
cd C:\Users\ABC\Desktop\aitech
```

2. הרץ את הסקריפט:
```powershell
.\Setup-SharePointDMS.ps1
```

3. תתבקש להתחבר - הכנס את חשבון Microsoft 365 שלך

4. הסקריפט יבנה:
   - ✅ Document Library עם כל העמודות
   - ✅ רשימות (Projects, Signature Workflows, וכו')
   - ✅ תיקיות במבנה מסודר
   - ✅ Views מותאמים אישית
   - ✅ 3 פרויקטים לדוגמה

---

## שלב 3: חיבור Front-End ל-SharePoint

### אופציה A: הרצה ישירה מ-SharePoint

1. העלה את כל קבצי HTML/CSS/JS ל-SharePoint:
   - עבור ל-Site Contents
   - צור Document Library בשם "Site Assets"
   - העלה את כל הקבצים

2. פתח את `index.html` ישירות מ-SharePoint
   - זה יעבוד אוטומטית כי אתה באותו domain

### אופציה B: פיתוח מקומי עם CORS

1. הוסף את השורה הבאה ל-`js/main.js`:
```javascript
<script src="Connect-Frontend-To-SharePoint.js"></script>
```

2. עדכן את הפונקציות הקיימות לקרוא מ-SharePoint:
```javascript
// במקום showToast מדומה, קרא מהשרת:
async function loadDocuments() {
    const docs = await getAllDocuments();
    displayDocuments(docs);
}
```

3. אם יש בעיות CORS, גש ל-SharePoint Admin Center:
   - Settings > Classic Settings
   - הוסף את הכתובת שלך ל-Trusted Origins

### אופציה C: SPFx Development (מתקדם)

אם אתה רוצה פיתוח מקצועי:
```bash
npm install -g @microsoft/generator-sharepoint
yo @microsoft/sharepoint
```

---

## שלב 4: העלאת מסמכים לדוגמה

### דרך 1: ידנית
1. עבור ל-"DMS Documents" בספריית המסמכים
2. לחץ Upload > Files
3. בחר קבצים
4. הגדר metadata (Project, Status, וכו')

### דרך 2: דרך הקוד
```javascript
// HTML:
<input type="file" id="fileUpload" onchange="handleUpload(this)">

// JavaScript:
async function handleUpload(input) {
    const file = input.files[0];
    const result = await uploadDocument(file, 'Projects', {
        'Project': 'SpaceX Project',
        'DocumentStatus': 'Draft',
        'Priority': 'High'
    });
    
    if (result.success) {
        alert('File uploaded!');
    }
}
```

---

## שלב 5: בדיקת המערכת

1. **נווט ל-SharePoint:**
   https://ofekpoint.sharepoint.com/sites/AITECH

2. **בדוק שנוצרו הרשימות:**
   - Site Contents > תראה את כל הרשימות

3. **פתח DMS Documents:**
   - לחץ על Document Library
   - תראה את העמודות: Project, Status, Priority, Notes

4. **בדוק Views:**
   - לחץ על "Project View"
   - תראה סינון מותאם אישית

---

## שלב 6: אוטומציות (Power Automate) - אופציונלי

### Flow 1: שליחת התראה כשמסמך חדש מועלה
1. עבור ל-Power Automate (flow.microsoft.com)
2. Create > Automated Cloud Flow
3. Trigger: "When a file is created (SharePoint)"
4. Action: "Send an email (V2)"

### Flow 2: Auto-Release מסמכים
1. Trigger: Recurrence (Daily)
2. Get items: DMS Documents where AutoReleaseDate = today
3. Update item: Set Status to "Released"

---

## טיפים לפתרון בעיות

### ❌ שגיאת הרשאות
```
Solution: ודא שיש לך Owner או Full Control על האתר
```

### ❌ "Module not found"
```powershell
# הרץ שוב:
Install-Module PnP.PowerShell -Force
```

### ❌ CORS Errors בפיתוח מקומי
```
Solution 1: העלה את הקבצים ל-SharePoint
Solution 2: השתמש ב-SPFx
Solution 3: הגדר Custom Actions
```

### ❌ "Cannot find list"
```
Solution: הרץ את Setup-SharePointDMS.ps1 שוב
```

---

## API Reference מהירה

### קריאת מסמכים
```javascript
const docs = await getAllDocuments();
```

### עדכון מסמך
```javascript
await updateDocument(itemId, {
    'DocumentStatus': 'Approved',
    'Notes': 'Looking good!'
});
```

### יצירת פרויקט
```javascript
await createProject({
    title: 'New Project',
    code: 'PRJ-004',
    priority: 'High',
    status: 'Active'
});
```

### העלאת קובץ
```javascript
const file = document.getElementById('fileInput').files[0];
await uploadDocument(file, 'Projects', {
    'Project': 'SpaceX Project',
    'Priority': 'High'
});
```

---

## מידע נוסף

- **Site URL:** https://ofekpoint.sharepoint.com/sites/AITECH
- **Document Library:** DMS Documents
- **Lists Created:**
  - Projects
  - Signature Workflows
  - Signature Steps
  - Forms

---

## תמיכה

אם יש בעיות, בדוק:
1. האם התחברת ל-SharePoint?
2. האם יש הרשאות מתאימות?
3. האם כל הרשימות נוצרו?
4. האם ה-REST API עובד? (בדוק ב-Console)

---

**הצלחה! 🚀**
