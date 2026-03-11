# הוראות העלאה ל-GitHub Pages
=============================================

## שלב 1: התחברות ל-GitHub

הרץ בטרמינל:
```powershell
gh auth login
```

בחר באפשרויות הבאות:
1. **GitHub.com** (לחץ Enter)
2. **HTTPS** (לחץ Enter)
3. **Login with a web browser** (לחץ Enter)
4. העתק את הקוד שמוצג (8 תווים)
5. לחץ Enter - יפתח דפדפן
6. הדבק את הקוד בדפדפן והתחבר

## שלב 2: פרסום האתר

אחרי שנכנסת בהצלחה, פשוט הרץ:
```powershell
.\deploy-to-github.ps1
```

זהו! האתר שלך יהיה ב:
**https://[שם-המשתמש-שלך].github.io/aitech**

---

## אלטרנטיבה - העלאה ידנית (ללא gh CLI)

אם אתה מעדיף בלי כלים, אפשר גם ככה:

### 1. צור repository חדש ב-GitHub:
- גש ל: https://github.com/new
- שם: `aitech`
- סוג: Public
- לחץ "Create repository"

### 2. הרץ את הפקודות האלה:
```powershell
git remote add origin https://github.com/[שם-משתמש]/aitech.git
git branch -M main
git push -u origin main
```

### 3. הפעל GitHub Pages:
- גש להגדרות של ה-repository
- לחץ על "Pages" בצד
- תחת "Source" בחר **main** branch
- לחץ "Save"

האתר יהיה זמין תוך מספר דקות!
