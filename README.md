# SchoolBus360 — Phase 1 Production Foundation

SchoolBus360 is a lightweight, cost-efficient, and privacy-first school transportation management platform engineered for schools in India (especially Punjab and tier-2/tier-3 cities).

---

## 1. Project Overview

SchoolBus360 is built from the ground up to solve school transport logistics under real-world Indian operational constraints:
- **Low-end Android smartphones**: Minimal memory footprints, no heavy animation overhead, clean contrast under bright sunlight.
- **Patchy mobile connectivity**: Offline tolerance with local caching, automatic reconnection, and non-blocking session restoration.
- **Strict Child Privacy**: Student transport records are accessible exclusively by authorized parents (`request.auth.uid in parentIds`).
- **School-Level Multi-Tenant Data Isolation**: Every school's data is isolated at the database level (`schoolId`) enforced via Cloud Firestore security rules.
- **Low Firebase Cost**: Elimination of unnecessary real-time document listeners, intelligent query scoping, and static profile caching.

**Phase 1 Scope**: Core monorepo foundation, Firebase Authentication via Phone OTP, profile management, role-based routing (Parent, Driver, Admin), Cloud Firestore security rules, Firestore indexes, and offline tolerance.

---

## 2. Architecture & Monorepo Structure

```text
SchoolBus360/
├── mobile/                            # Unified Flutter App (Parent & Driver)
│   ├── lib/
│   │   ├── main.dart                  # App bootstrap, Firestore offline cache init
│   │   ├── app.dart                   # MaterialApp, Providers, Material 3 Theme
│   │   ├── core/
│   │   │   ├── constants/             # AppColors, AppStrings, UserRole
│   │   │   ├── errors/                # AppException, ErrorHandler
│   │   │   ├── services/              # NetworkService (Connectivity monitoring)
│   │   │   ├── theme/                 # High-contrast, battery-friendly AppTheme
│   │   │   └── utils/                 # PhoneFormatter (+91 E.164), Validators
│   │   ├── models/                    # AppUser, School, Student, Driver, Bus, Route
│   │   ├── repositories/              # AuthRepository, UserRepository
│   │   ├── features/
│   │   │   ├── auth/                  # LoginScreen, OtpScreen, AuthController
│   │   │   ├── parent/                # ParentHomeScreen (Proof screen)
│   │   │   └── driver/                # DriverHomeScreen (Proof screen)
│   │   └── routing/                   # AppRouter (Reactive role router)
│   ├── android/                       # Android native configuration
│   ├── ios/                           # iOS native configuration
│   ├── pubspec.yaml                   # Flutter dependencies
│   └── README.md
│
├── admin/                             # React (Vite) Web Portal (Admin)
│   ├── src/
│   │   ├── components/                # Navbar, ErrorAlert, LoadingSpinner
│   │   ├── pages/                     # AdminLogin, AdminDashboard, UnauthorizedPage
│   │   ├── services/                  # firebase.js, authService.js
│   │   ├── models/                    # UserRole.js
│   │   ├── routing/                   # ProtectedRoute.jsx
│   │   ├── App.jsx                    # Root App & Route guards
│   │   ├── index.css                  # Production CSS
│   │   └── main.jsx
│   ├── index.html
│   ├── vite.config.js
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── functions/                         # Firebase Cloud Functions (Node.js)
│   ├── src/
│   │   └── index.js                   # healthCheck & checkUserStatus
│   ├── package.json
│   └── README.md
│
├── scripts/
│   └── seed_test_data.js              # Test data seeder for local / emulator testing
│
├── firestore.rules                    # Production Firestore Security Rules
├── firestore.indexes.json             # Required composite query indexes
├── firebase.json                      # Firebase CLI project configuration
├── .firebaserc                        # Firebase target project mapping
├── .gitignore                         # Comprehensive Git ignore rules
├── .env.example                       # Root environment variable template
└── README.md                          # Master documentation
```

---

## 3. Technology Stack

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Mobile App** | **Flutter** (Dart 3.3+) | Single codebase delivering native performance for Parents and Drivers. |
| **Backend & Auth** | **Firebase Authentication (Phone OTP)** | SMS-based OTP matches Indian mobile usage habits; zero passwords. |
| **Database** | **Cloud Firestore** | Document database with offline persistence and granular security rules. |
| **Cloud Functions** | **Firebase Functions (Node.js 18)** | Serverless backend execution for secure operations. |
| **Mapping Engine** | **OpenStreetMap (`flutter_map`)** | Zero Google Maps API bills; scalable, offline-friendly tile caching. |
| **Admin Portal** | **React 18 + Vite** | Lightweight, responsive web portal for school transport authorities. |

---

## 4. Firestore Schema

### `schools/{schoolId}`
```typescript
{
  name: string,             // "DPS Jalandhar"
  address: string,          // "GT Road, Jalandhar, Punjab"
  phone: string,            // "+911812345678"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `users/{uid}`
```typescript
{
  phone: string,            // "+919876500001"
  name: string,             // "Rajinder Kumar"
  role: string,             // "parent" | "driver" | "admin"
  schoolId: string,         // "school_dps_jalandhar"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `students/{studentId}`
```typescript
{
  schoolId: string,         // "school_dps_jalandhar"
  name: string,             // "Amrit Singh"
  parentIds: string[],      // ["parent_uid_1", "parent_uid_2"]
  busId: string | null,     // "bus_pb08_1001"
  routeId: string | null,   // "route_model_town"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `drivers/{uid}` *(UID is document ID)*
```typescript
{
  schoolId: string,         // "school_dps_jalandhar"
  name: string,             // "Harpreet Singh"
  phone: string,            // "+919876500002"
  assignedBusId: string | null, // "bus_pb08_1001"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `buses/{busId}`
```typescript
{
  schoolId: string,         // "school_dps_jalandhar"
  busNumber: string,        // "PB 08 AB 1001"
  driverId: string | null,  // "driver_uid_1"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `routes/{routeId}`
```typescript
{
  schoolId: string,         // "school_dps_jalandhar"
  name: string,             // "Route 4 - Model Town"
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### `routes/{routeId}/stops/{stopId}`
```typescript
{
  name: string,             // "Model Town Market"
  latitude: number,         // 31.3124
  longitude: number,        // 75.5789
  sequence: number,         // 1
  active: boolean,          // true
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## 5. Security Model & Data Isolation

1. **Closed by Default**: All collections deny read/write unless explicitly permitted by helper functions.
2. **Multi-School Isolation**: Enforced by `sameSchool(targetSchoolId)`. A user in School A cannot query, read, or modify School B's students, buses, drivers, or routes.
3. **Child Privacy**: Parents can query/read students **only** where their UID exists in the `parentIds` array. A parent cannot enumerate or browse all school students.
4. **Privilege Escalation Prevention**:
   - Clients cannot create users with `role: "admin"`.
   - On self-profile updates, `role`, `schoolId`, and `active` are verified strictly against existing document values (`request.resource.data.role == resource.data.role`).
5. **Driver Phone Switching Resilience**: Driver documents are keyed by Firebase Auth UID (`drivers/{uid}`), never hardware or IMEI identifiers. If a driver's phone breaks, logging into another device automatically restores the driver session and assigned bus.

---

## 6. Firebase Setup Guide

### Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Link Project
In the root directory, configure your Firebase project:
```bash
firebase use --add
# Select your Firebase project or enter its project ID (e.g. schoolbus360-prod)
```

### Step 4: Enable Authentication & Phone Provider
1. Navigate to the **Firebase Console** → **Authentication** → **Sign-in method**.
2. Click **Phone** and toggle **Enable**.
3. Under **Phone numbers for testing**, add test numbers:
   - `+91 98765 00001` with OTP `123456` (Admin)
   - `+91 98765 00002` with OTP `123456` (Driver)
   - `+91 98765 00003` with OTP `123456` (Parent)

### Step 5: Create Cloud Firestore Database
1. In Firebase Console, go to **Cloud Firestore** → **Create Database**.
2. Select **Production Mode** and choose region `asia-south1` (Mumbai).

### Step 6: Deploy Security Rules and Indexes
From the root repository directory:
```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Deploy Firestore composite indexes
firebase deploy --only firestore:indexes
```

### Step 7: Deploy Cloud Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

---

## 7. Running Locally

### A. Seed Test Records
You can run the provided seeding script against Firebase or the Local Emulator:
```bash
npm install firebase-admin
node scripts/seed_test_data.js
```

### B. Mobile Flutter App
```bash
cd mobile

# 1. Download google-services.json from Firebase Console to mobile/android/app/
# 2. Download GoogleService-Info.plist from Firebase Console to mobile/ios/Runner/

# Get dependencies
flutter pub get

# Run on Android emulator or connected device
flutter run
```

### C. Admin Web App
```bash
cd admin

# Install dependencies
npm install

# Copy .env.example and populate with Firebase web credentials
cp .env.example .env.local

# Start Vite dev server
npm run dev
# Open http://localhost:3000 in your browser
```

---

## 8. Security Verification Tests

| Test Case | Procedure | Expected Result |
| :--- | :--- | :--- |
| **Test 1: Parent A vs Parent B** | Parent A attempts to read student where `parentIds` does not include Parent A UID. | **PERMISSION_DENIED** by Firestore Rules. |
| **Test 2: School Isolation** | Parent in School A queries students where `schoolId == "school_b"`. | **PERMISSION_DENIED**; cross-school read blocked. |
| **Test 3: Client Privilege Escalation** | Client attempts to create user with `role: "admin"`. | **PERMISSION_DENIED**; rules reject client-side admin creation. |
| **Test 4: Role Tampering** | User attempts to update own document setting `role = "admin"`. | **PERMISSION_DENIED**; rule enforces `role == resource.data.role`. |
| **Test 5: Cross-School Admin Access** | Admin of School A queries routes with `schoolId == "school_b"`. | **PERMISSION_DENIED**; `sameSchool()` rejects request. |
| **Test 6: Unauthenticated Access** | Unauthenticated request reads `/students` or `/buses`. | **PERMISSION_DENIED**; anonymous read blocked. |
| **Test 7: Logout Invalidation** | User taps Logout. | Auth state reset; protected views become inaccessible. |

---

## 9. Development Test Accounts

Use Firebase Authentication test numbers (configured in Firebase Console) for zero-SMS testing:

| Role | Test Phone Number | Default Test OTP | Document ID (UID) | Linked Institution / Bus |
| :--- | :--- | :--- | :--- | :--- |
| **Admin** | `+91 98765 00001` | `123456` | `test_admin_uid_1` | School: DPS Jalandhar |
| **Driver** | `+91 98765 00002` | `123456` | `test_driver_uid_1` | Bus: PB 08 AB 1001 (DPS Jalandhar) |
| **Parent** | `+91 98765 00003` | `123456` | `test_parent_uid_1` | Child: Amrit Singh (DPS Jalandhar) |
| **Parent (School B)**| `+91 98765 00004` | `123456` | `test_parent_uid_2` | Child: Navneet Kaur (Sacred Heart) |
| **Unregistered User**| `+91 98765 00099` | `123456` | *Dynamic* | None (shows "Account Not Registered") |

---

## Phase 1 Complete

### A. How to Test (Step-by-Step Checklist)

1. **Verify Unauthenticated State**:
   - Launch Flutter app; verify `LoginScreen` appears with `+91` input.
   - Launch React admin; verify `/login` route renders with reCAPTCHA.
2. **Verify Parent Login Flow**:
   - In mobile app, enter `9876500003`, click **Send OTP**.
   - Enter `123456`, click **Verify**.
   - Verify `ParentHomeScreen` displays:
     - Welcome, Simranjit Kaur
     - Role: Parent
     - School: DPS Jalandhar
     - Child: Amrit Singh (Bus: PB 08 AB 1001)
3. **Verify Driver Login Flow**:
   - Logout from Parent account.
   - Enter `9876500002`, verify with `123456`.
   - Verify `DriverHomeScreen` displays:
     - Welcome, Harpreet Singh
     - Role: Driver
     - Assigned Bus: PB 08 AB 1001 (Bus #1)
     - Device-Independent UID notice.
4. **Verify Admin Web Login Flow**:
   - In browser (`http://localhost:3000`), enter `9876500001`.
   - Enter OTP `123456`.
   - Verify `AdminDashboard` displays:
     - Welcome, Rajinder Kumar
     - School: DPS Jalandhar
     - Phase 1 Foundation badge.
5. **Verify Privilege Rejection**:
   - In React Admin portal, enter Parent phone number `9876500003`.
   - Verify authentication is rejected with: *"Access denied. This mobile number is not authorized as an active School Administrator."*
6. **Verify Unregistered User Flow**:
   - In mobile app, enter `9876500099`.
   - Verify controlled onboarding screen: *"Account Not Registered. Please contact your school administrator to register."*
7. **Verify Offline Handling**:
   - Toggle Airplane mode; verify top offline banner appears without app crashing or misleading "server error" alerts.
   - Close and restart app while offline; verify persistent authentication caches user session safely.

---

### B. Known Limitations (Intentionally Excluded from Phase 1)

The following capabilities are deliberately **not** implemented in Phase 1:
- ❌ **No GPS tracking or location gathering**
- ❌ **No Android background location service or foreground service**
- ❌ **No Live map rendering or bus movement animation**
- ❌ **No ETA estimation or travel duration computations**
- ❌ **No Geofencing or stop proximity alerts**
- ❌ **No Student QR scanning or attendance verification**
- ❌ **No Fee collection or UPI deep links**
- ❌ **No Route creation or bus assignment modification UI**
- ❌ **No Trip history or 90-day trajectory logs**

---

### C. What Phase 2 Needs from Phase 1

Phase 2 (Driver GPS Tracking & Trip Engine) directly reuses and builds upon the Phase 1 components:

```text
[Phase 1] Firebase Authentication
   │
   ▼
[Phase 1] Driver UID (drivers/{uid})
   │
   ▼
[Phase 1] Assigned Bus ID (buses/{busId})
   │
   ▼
[Phase 2] Trip Document Creation (trips/{tripId})
   │
   ▼
[Phase 2] Low-Cost Rate-Limited GPS Tracking (Foreground Service)
   │
   ▼
[Phase 2] OpenStreetMap Map Tile Rendering (flutter_map)
```

1. **Authentication Token**: Phase 2 driver background service uses the persistent Firebase Auth token from `AuthRepository`.
2. **Driver Profile & Bus Link**: `Driver.assignedBusId` links GPS location streams directly to the designated vehicle.
3. **School Data Isolation**: Location records in Phase 2 will carry `schoolId` inherited from Phase 1 driver profiles, ensuring parent map views never leak cross-school bus coordinates.
# SchoolBus360
