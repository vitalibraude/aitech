# 🚀 העלאת האתר ל-GitHub Pages

## דרך א' - אוטומטית (מומלץ)

פשוט לחץ פעמיים על הקובץ:
```
SETUP.bat
```

או הרץ בטרמינל:
```cmd
.\SETUP.bat
```

הסקריפט יעשה הכל בשבילך!

---

## דרך ב' - ידנית (ללא סקריפט)

### שלב 1: התחבר ל-GitHub
```powershell
gh auth login
```
- בחר: **GitHub.com** (Enter)
- בחר: **HTTPS** (Enter)  
- בחר: **Login with a web browser** (Enter)
- **העתק את הקוד** שמופיע (8 תווים)
- לחץ Enter - יפתח דפדפן
- הדבק את הקוד והתחבר

### שלב 2: צור repository והעלה
```powershell
gh repo create aitech --public --source=. --remote=origin --push
```

### שלב 3: הפעל GitHub Pages
```powershell
gh api repos/{owner}/aitech/pages -X POST -f source[branch]=master -f source[path]=/
```

### שלב 4: קבל את הקישור
```powershell
gh api user --jq .login
```

האתר שלך יהיה ב:
**https://[שם-המשתמש].github.io/aitech**

---

## דרך ג' - דרך האתר של GitHub (ללא פקודות)

### 1. צור repository ב-GitHub:
1. גש ל: https://github.com/new
2. שם repository: `aitech`
3. בחר: **Public**
4. לחץ: **Create repository**

### 2. העלה את הקבצים:
בטרמינל הרץ:
```powershell
git remote add origin https://github.com/[שם-המשתמש-שלך]/aitech.git
git branch -M main  
git push -u origin main
```

### 3. הפעל GitHub Pages:
1. גש להגדרות ה-repository (Settings)
2. בתפריט צד לחץ על **Pages**
3. תחת "Source" בחר: **main** (או master)
4. לחץ **Save**

**זהו!** האתר יעלה תוך דקה-שתיים 🎉

---

## 💡 טיפים

- אם הסקריפט לא עובד, נסה לסגור ולפתוח טרמינל חדש
- אם repository בשם `aitech` כבר קיים, שנה את השם בפקודות
- GitHub Pages לוקח 1-3 דקות להפעיל את האתר
- אם האתר לא עולה, בדוק ב-Settings > Pages שה-Pages מופעל

## ❓ שאלות נפוצות

**Q: האתר לא עובד אחרי ההעלאה**  
A: המתן 2-3 דקות. GitHub צריך זמן לבנות את האתר.

**Q: אני מקבל שגיאה "repository already exists"**  
A: Repository בשם הזה כבר קיים בחשבון שלך. שנה את השם או מחק את הישן.

**Q: דף ריק / 404**  
A: ודא שיש לך קובץ `index.html` בתיקיה הראשית של הפרויקט.
