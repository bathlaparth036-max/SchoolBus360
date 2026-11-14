/**
 * SCHOOLBUS360 — PHASE 1 TEST DATA SEED SCRIPT
 *
 * Usage:
 *   node scripts/seed_test_data.js
 *
 * Pre-requisites:
 *   - Google Application Default Credentials or FIREBASE_SERVICE_ACCOUNT set
 *   - Or run with FIRESTORE_EMULATOR_HOST=localhost:8080 for emulator testing
 */

const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

async function seedTestData() {
  console.log('Seeding SchoolBus360 Phase 1 test records...');

  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  // 1. Schools
  const schoolAId = 'school_dps_jalandhar';
  const schoolBId = 'school_sacred_ludhiana';

  await db.collection('schools').doc(schoolAId).set({
    name: 'DPS Jalandhar',
    address: 'GT Road, Jalandhar, Punjab',
    phone: '+911812345678',
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  await db.collection('schools').doc(schoolBId).set({
    name: 'Sacred Heart Convent Ludhiana',
    address: 'Sarabha Nagar, Ludhiana, Punjab',
    phone: '+911612456789',
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  console.log('✔ Schools seeded');

  // 2. Buses
  const bus1Id = 'bus_pb08_1001';
  await db.collection('buses').doc(bus1Id).set({
    schoolId: schoolAId,
    busNumber: 'PB 08 AB 1001 (Bus #1)',
    driverId: 'test_driver_uid_1',
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  console.log('✔ Buses seeded');

  // 3. Users (Admins, Drivers, Parents)
  // Admin User (School A)
  await db.collection('users').doc('test_admin_uid_1').set({
    phone: '+919876500001',
    name: 'Rajinder Kumar (Admin)',
    role: 'admin',
    schoolId: schoolAId,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  // Driver User (School A)
  await db.collection('users').doc('test_driver_uid_1').set({
    phone: '+919876500002',
    name: 'Harpreet Singh (Driver)',
    role: 'driver',
    schoolId: schoolAId,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  await db.collection('drivers').doc('test_driver_uid_1').set({
    schoolId: schoolAId,
    name: 'Harpreet Singh (Driver)',
    phone: '+919876500002',
    assignedBusId: bus1Id,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  // Parent User (School A)
  await db.collection('users').doc('test_parent_uid_1').set({
    phone: '+919876500003',
    name: 'Simranjit Kaur (Parent)',
    role: 'parent',
    schoolId: schoolAId,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  // Parent User (School B) - For Multi-School Isolation Testing
  await db.collection('users').doc('test_parent_uid_2').set({
    phone: '+919876500004',
    name: 'Gurpreet Singh (School B Parent)',
    role: 'parent',
    schoolId: schoolBId,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  console.log('✔ Users and Driver records seeded');

  // 4. Students
  // Student 1 (belongs to Parent 1 in School A)
  await db.collection('students').doc('student_amrit_singh').set({
    schoolId: schoolAId,
    name: 'Amrit Singh',
    parentIds: ['test_parent_uid_1'],
    busId: bus1Id,
    routeId: 'route_model_town',
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  // Student 2 (belongs to School B parent)
  await db.collection('students').doc('student_navneet_kaur').set({
    schoolId: schoolBId,
    name: 'Navneet Kaur',
    parentIds: ['test_parent_uid_2'],
    busId: null,
    routeId: null,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  console.log('✔ Students seeded');
  console.log('\nSeed complete! Test Accounts Created:');
  console.log('----------------------------------------------------');
  console.log('Admin:  +91 98765 00001 (UID: test_admin_uid_1)');
  console.log('Driver: +91 98765 00002 (UID: test_driver_uid_1, Bus: PB 08 AB 1001)');
  console.log('Parent: +91 98765 00003 (UID: test_parent_uid_1, Child: Amrit Singh)');
  console.log('Parent: +91 98765 00004 (UID: test_parent_uid_2, School B)');
  console.log('----------------------------------------------------');
}

seedTestData()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seed failed:', err);
    process.exit(1);
  });
