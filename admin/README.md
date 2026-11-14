# SchoolBus360 — React Admin Web Application (Phase 1)

This is the administration web portal for **SchoolBus360**, built with React, Vite, and Firebase.

---

## 1. Features Implemented in Phase 1

- **Firebase Initialization**: Connects to the unified Firebase project via environment variables.
- **Admin Phone OTP Login**: Web phone verification with invisible reCAPTCHA.
- **Strict Role Verification**: Ensures that only accounts with `role: "admin"` and `active: true` in `users/{uid}` can access the dashboard.
- **Privilege Escalation Protection**: Random authenticated numbers or parent/driver accounts are automatically rejected and logged out.
- **Admin Dashboard**: Displays verified administrator name, associated school name, school ID, and Phase 1 boundary indicator.
- **Session Persistence & Logout**: Seamless token restoration and clean sign out.

---

## 2. Directory Structure

```text
admin/
├── src/
│   ├── components/
│   │   ├── ErrorAlert.jsx         # Clean dismissible error notifications
│   │   ├── LoadingSpinner.jsx     # Centered loading spinner
│   │   └── Navbar.jsx             # Top administration header with logout action
│   ├── pages/
│   │   ├── AdminLogin.jsx         # Administrator phone OTP login form
│   │   ├── AdminDashboard.jsx     # Phase 1 proof dashboard
│   │   └── UnauthorizedPage.jsx   # Friendly access denied page
│   ├── services/
│   │   ├── firebase.js            # Firebase App, Auth, and Firestore initialization
│   │   └── authService.js         # Phone auth, reCAPTCHA, and role validation
│   ├── models/
│   │   └── UserRole.js            # Role constants
│   ├── routing/
│   │   └── ProtectedRoute.jsx     # Route guard enforcing admin role
│   ├── App.jsx                    # Root component with routing
│   ├── index.css                  # Modern, clean CSS styles
│   └── main.jsx                   # Entry point
├── index.html
├── vite.config.js
├── package.json
├── .env.example
└── README.md
```

---

## 3. Local Development Setup

### 1. Install Dependencies
```bash
cd admin
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env.local`:
```bash
cp .env.example .env.local
```
Fill in your Firebase Web App credentials in `.env.local`.

### 3. Start Development Server
```bash
npm run dev
```
Open `http://localhost:3000` in your web browser.

### 4. Build for Production
```bash
npm run build
```
Production assets will be output to `admin/dist`, configured for deployment via `firebase deploy --only hosting`.
