# PocketPal: Personal Finance Manager

---

## 1. App Description

**PocketPal** is a cross-platform personal finance management app built with Flutter. It empowers users to track expenses, set monthly budgets, visualize spending patterns, and receive actionable financial tips. With Firebase integration, PocketPal ensures secure authentication, cloud data storage, and a seamless user experience across devices.

---

## 2. Feature List

- **User Authentication:** Secure sign-up and login with Firebase Auth.
- **Onboarding Flow:** Guided setup for new users, including budget entry.
- **Expense Tracking:** Add, edit, and delete expenses with categories, notes, and dates.
- **Budget Management:** Set and update monthly budgets; see progress and warnings.
- **Charts & Analytics:** Visualize spending by category and over time (Pie, Bar, Line charts).
- **Financial Tips:** Get curated and API-powered financial advice.
- **Export Data:** Export expenses as CSV or PDF for personal records.
- **Profile Management:** View and edit user profile details.
- **Settings:** Toggle dark mode, manage preferences, and access help/support.
- **Help & Support:** FAQ, contact info, and additional resources.
- **Persistent State:** Uses Provider for state management and SharedPreferences for local storage.
- **Cloud Sync:** Expenses and budgets are stored in Firebase Firestore.
- **(Optional) File Uploads:** Firebase Storage integration for profile pictures or receipts.

---

## 3. Screenshots

*(Insert screenshots of the following screens:)*

- Onboarding
- Login/Register
- Home (Dashboard with charts)
- Add Expense
- Budget Screen
- Expenses List
- Profile
- Settings
- Help & Support

---

## 4. Widget Tree Diagram for Each Screen

*(Sample for Home Screen:)*

### Home Screen Widget Tree
```
Scaffold
 ├── AppBar
 ├── Column
 │    ├── ToggleButtons (Chart Period)
 │    ├── Expanded
 │    │    └── PageView (Charts)
 │    ├── Category Breakdown (PieChart)
 │    ├── BudgetSummaryCards (Row of Cards)
 │    └── BottomNavigationBar
```

*(Repeat for other main screens: Add Expense, Budget, Expenses, Profile, Settings, Help & Support)*

---

## 5. Lessons Learned

- **State Management:** Using Provider made it easy to manage and update app-wide state, but required careful separation of logic and UI.
- **Firebase Integration:** Setting up Auth and Firestore was straightforward, but Storage required careful region selection and security rules.
- **UI/UX:** Handling pixel overflows and responsive layouts was crucial for a professional look on all devices.
- **API Integration:** Not all public APIs return relevant data; fallback to local curated tips ensures reliability.
- **Persistence:** SharedPreferences is great for simple flags (onboarding, login), but Firestore is better for user data.
- **Deployment:** Building and installing APKs is easy with Flutter, but web deployment requires extra configuration.
- **Debugging:** Reading error messages and using the Flutter Inspector helped quickly resolve UI and logic bugs.
- **Documentation:** Keeping code and features well-documented made the final report and presentation much easier.

---

*End of Report* 