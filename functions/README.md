# SchoolBus360 — Cloud Functions Foundation (Phase 1)

This package contains the Firebase Cloud Functions foundation for **SchoolBus360**.

---

## 1. Scope for Phase 1

In accordance with Phase 1 constraints:
- GPS processing, background worker tasks, payment processing, route calculations, and push notifications are intentionally **not** implemented in this phase.
- Only core foundational functions are provided:
  - `healthCheck`: HTTPS health monitor returning service status, phase info, and timestamp.
  - `checkUserStatus`: Authenticated callable function to safely verify caller registration status from backend.

---

## 2. Directory Structure

```text
functions/
├── src/
│   └── index.js       # Cloud Functions definitions
├── package.json       # Dependencies (firebase-admin, firebase-functions)
└── README.md
```

---

## 3. Setup and Deployment

### Install Dependencies
```bash
cd functions
npm install
```

### Local Emulation
```bash
npm run serve
```

### Deploy to Firebase
```bash
firebase deploy --only functions
```
