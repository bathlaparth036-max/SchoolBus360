# SchoolBus360 — Flutter Mobile Application (Phase 1)

This is the mobile application codebase for **SchoolBus360**, built using Flutter and Firebase. It provides unified, role-based experiences for both **Parents** and **Drivers**.

---

## 1. Features Implemented in Phase 1

- **Phone OTP Authentication**: Secure SMS-based login flow tailored for Indian mobile numbers (+91).
- **Persistent Sessions**: User remains logged in across application restarts and cold boots.
- **Strongly-Typed Roles**: Roles are strictly typed (`parent`, `driver`, `admin`, `unknown`) preventing string drift.
- **Role-Based Routing**:
  - `parent` → `ParentHomeScreen` (Displays welcome, role, school, and strictly linked children).
  - `driver` → `DriverHomeScreen` (Displays welcome, role, school, and assigned bus).
  - `admin` → Directs user to the dedicated Admin Web Portal.
  - Unregistered → Shows controlled account-pending notice without privilege escalation.
- **Offline Tolerance**:
  - Firestore offline persistence enabled (`Settings(persistenceEnabled: true)`).
  - Connectivity monitoring via `NetworkService`.
  - Non-intrusive offline banners without app crashes or false "server error" messages.
- **Hardware-Agnostic Driver Identity**:
  - Driver identity is tied strictly to Firebase Auth UID, not hardware IDs, allowing drivers to switch phones seamlessly if a device is damaged.

---

## 2. Directory Structure

```text
mobile/
├── lib/
│   ├── main.dart                      # Firebase init, offline cache setup, bootstrap
│   ├── app.dart                       # Providers, Material 3 theme, root router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # High-contrast color palette for bright sunlight
│   │   │   ├── app_strings.dart       # Centralized user strings
│   │   │   └── user_role.dart         # Strongly typed UserRole enum
│   │   ├── errors/
│   │   │   ├── app_exception.dart     # Domain exceptions (Network, Auth, UserNotFound)
│   │   │   └── error_handler.dart     # Safe mapping of Firebase codes to messages
│   │   ├── services/
│   │   │   └── network_service.dart   # Real-time network connectivity listener
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Fast-rendering Material 3 theme for budget devices
│   │   └── utils/
│   │       ├── phone_formatter.dart   # E.164 normalization (+91)
│   │       └── validators.dart        # 10-digit Indian mobile and 6-digit OTP validators
│   ├── models/
│   │   ├── app_user.dart              # users/{uid} model
│   │   ├── school.dart                # schools/{schoolId} model
│   │   ├── student.dart               # students/{studentId} model
│   │   ├── driver.dart                # drivers/{uid} model
│   │   ├── bus.dart                   # buses/{busId} model
│   │   └── route.dart                 # routes/{routeId} and stops model
│   ├── repositories/
│   │   ├── auth_repository.dart       # Phone verification, OTP verification, signOut
│   │   └── user_repository.dart       # Firestore profile and school retrieval
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_screen.dart      # Minimalist phone input screen
│   │   │   ├── otp_screen.dart        # 6-digit OTP verification with timer
│   │   │   └── auth_controller.dart   # ChangeNotifier state controller
│   │   ├── parent/
│   │   │   └── parent_home_screen.dart # Phase 1 Parent proof screen
│   │   └── driver/
│   │       └── driver_home_screen.dart # Phase 1 Driver proof screen
│   └── routing/
│       └── app_router.dart            # Reactive router based on auth & role
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 3. Setup and Run Instructions

### Prerequisites
- Flutter SDK `>=3.19.0`
- Android Studio / Xcode
- Configured Firebase Project

### 1. Configure Firebase Credentials
1. **Android**: Download `google-services.json` from your Firebase Console and place it in:
   ```text
   mobile/android/app/google-services.json
   ```
2. **iOS**: Download `GoogleService-Info.plist` from your Firebase Console and place it in:
   ```text
   mobile/ios/Runner/GoogleService-Info.plist
   ```
*(Alternatively, execute `flutterfire configure` from the `mobile/` directory).*

### 2. Install Dependencies
```bash
cd mobile
flutter pub get
```

### 3. Run the App
```bash
# Run on connected Android device or emulator
flutter run
```
