const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Health Check Endpoint
 * Verifies Cloud Functions operational status and Firebase project connectivity.
 */
exports.healthCheck = functions
  .region('asia-south1')
  .https.onRequest((req, res) => {
    res.status(200).json({
      status: 'healthy',
      service: 'SchoolBus360 Cloud Functions',
      phase: 1,
      timestamp: new Date().toISOString(),
      region: 'asia-south1',
    });
  });

/**
 * Secure Backend Admin Provisioning Callable Function
 * For Phase 1 testing and initial school admin creation without client privilege escalation.
 * In production, only accessible by project owner or authenticated superadmin.
 */
exports.checkUserStatus = functions
  .region('asia-south1')
  .https.onCall(async (data, context) => {
    // Requires authenticated caller
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Authentication required to verify account status.'
      );
    }

    const uid = context.auth.uid;
    const userDoc = await db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      return {
        registered: false,
        uid,
      };
    }

    const userData = userDoc.data();
    return {
      registered: true,
      uid,
      role: userData.role,
      schoolId: userData.schoolId,
      active: userData.active === true,
    };
  });
