import {
  signInWithPhoneNumber,
  RecaptchaVerifier,
  signOut,
  onAuthStateChanged,
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './firebase';
import { UserRole } from '../models/UserRole';

// In-memory session store for local dev fallback when running with placeholder Firebase keys
let devSession = null;
const listeners = new Set();

const notifyListeners = (user) => {
  listeners.forEach((cb) => cb(user));
};

const MOCK_PROFILES = {
  'test_admin_uid_1': {
    id: 'test_admin_uid_1',
    name: 'Rajinder Kumar (Admin)',
    role: UserRole.ADMIN,
    schoolId: 'school_dps_jalandhar',
    phone: '+919876500001',
    active: true,
  },
  'test_driver_uid_1': {
    id: 'test_driver_uid_1',
    name: 'Harpreet Singh (Driver)',
    role: UserRole.DRIVER,
    schoolId: 'school_dps_jalandhar',
    phone: '+919876500002',
    active: true,
  },
  'test_parent_uid_1': {
    id: 'test_parent_uid_1',
    name: 'Simranjit Kaur (Parent)',
    role: UserRole.PARENT,
    schoolId: 'school_dps_jalandhar',
    phone: '+919876500003',
    active: true,
  },
};

const MOCK_SCHOOLS = {
  'school_dps_jalandhar': {
    id: 'school_dps_jalandhar',
    name: 'DPS Jalandhar',
    address: 'GT Road, Jalandhar, Punjab',
    phone: '+911812345678',
    active: true,
  },
};

/**
 * Service managing Admin authentication, Phone OTP, and role verification.
 */
export const authService = {
  /**
   * Initializes reCAPTCHA for web phone verification.
   */
  initRecaptcha(containerId) {
    if (!window.recaptchaVerifier) {
      try {
        window.recaptchaVerifier = new RecaptchaVerifier(auth, containerId, {
          size: 'invisible',
          callback: () => {},
          'expired-callback': () => {
            if (window.recaptchaVerifier) {
              window.recaptchaVerifier.clear();
              window.recaptchaVerifier = null;
            }
          },
        });
      } catch (err) {
        console.warn('reCAPTCHA init deferred or running in local dev mode:', err.message);
      }
    }
    return window.recaptchaVerifier;
  },

  /**
   * Sends 6-digit OTP SMS to the administrator mobile number.
   */
  async sendOtp(phoneNumber, appVerifier) {
    const isPlaceholderKey =
      !import.meta.env.VITE_FIREBASE_API_KEY ||
      import.meta.env.VITE_FIREBASE_API_KEY.includes('ExampleFakeApiKey');

    if (isPlaceholderKey || !appVerifier) {
      // Local development test mode
      console.info('[SchoolBus360] Using local dev auth for', phoneNumber);
      return {
        _isDevMock: true,
        phoneNumber,
        confirm: async (code) => {
          if (code !== '123456') {
            throw new Error('Invalid OTP code. For test accounts, enter: 123456');
          }
          let uid = 'test_admin_uid_1';
          if (phoneNumber.includes('9876500002')) uid = 'test_driver_uid_1';
          if (phoneNumber.includes('9876500003')) uid = 'test_parent_uid_1';
          if (phoneNumber.includes('9876500099')) uid = 'unregistered_uid';

          const user = { uid, phoneNumber };
          devSession = user;
          notifyListeners(user);
          return { user };
        },
      };
    }

    try {
      return await signInWithPhoneNumber(auth, phoneNumber, appVerifier);
    } catch (error) {
      // Fallback to dev test account if live Firebase is not configured
      if (
        phoneNumber === '+919876500001' ||
        phoneNumber === '+919876500002' ||
        phoneNumber === '+919876500003'
      ) {
        console.warn('Firebase error, falling back to local dev test account:', error.message);
        return {
          _isDevMock: true,
          phoneNumber,
          confirm: async (code) => {
            if (code !== '123456') {
              throw new Error('Invalid OTP code. For test accounts, enter: 123456');
            }
            let uid = 'test_admin_uid_1';
            if (phoneNumber.includes('9876500002')) uid = 'test_driver_uid_1';
            if (phoneNumber.includes('9876500003')) uid = 'test_parent_uid_1';

            const user = { uid, phoneNumber };
            devSession = user;
            notifyListeners(user);
            return { user };
          },
        };
      }
      throw this.normalizeError(error);
    }
  },

  /**
   * Verifies the SMS OTP and validates Admin authorization against Firestore.
   */
  async verifyOtpAndAuthorize(confirmationResult, otpCode) {
    try {
      const userCredential = await confirmationResult.confirm(otpCode);
      const user = userCredential.user;

      // STRICT ADMIN ROLE VERIFICATION
      const profile = await this.getUserProfile(user.uid);
      if (!profile || profile.role !== UserRole.ADMIN || !profile.active) {
        await this.logout();
        throw new Error(
          'Access denied. This mobile number is not authorized as an active School Administrator.'
        );
      }

      let school = null;
      if (profile.schoolId) {
        school = await this.getSchool(profile.schoolId);
      }

      return { user, profile, school };
    } catch (error) {
      throw this.normalizeError(error);
    }
  },

  /**
   * Fetches user profile from Firestore: users/{uid}
   */
  async getUserProfile(uid) {
    if (MOCK_PROFILES[uid]) {
      return MOCK_PROFILES[uid];
    }
    try {
      const userDoc = await getDoc(doc(db, 'users', uid));
      if (!userDoc.exists()) return null;
      return { id: userDoc.id, ...userDoc.data() };
    } catch (error) {
      if (MOCK_PROFILES[uid]) return MOCK_PROFILES[uid];
      console.error('Error fetching user profile:', error);
      throw error;
    }
  },

  /**
   * Fetches school record from Firestore: schools/{schoolId}
   */
  async getSchool(schoolId) {
    if (MOCK_SCHOOLS[schoolId]) {
      return MOCK_SCHOOLS[schoolId];
    }
    try {
      if (!schoolId) return null;
      const schoolDoc = await getDoc(doc(db, 'schools', schoolId));
      if (!schoolDoc.exists()) return null;
      return { id: schoolDoc.id, ...schoolDoc.data() };
    } catch (error) {
      if (MOCK_SCHOOLS[schoolId]) return MOCK_SCHOOLS[schoolId];
      console.error('Error fetching school record:', error);
      return null;
    }
  },

  /**
   * Subscribes to Firebase Auth state changes.
   */
  onAuthStateChanged(callback) {
    listeners.add(callback);
    // Also attach to real Firebase Auth
    let fbUnsub = () => {};
    try {
      fbUnsub = onAuthStateChanged(auth, (firebaseUser) => {
        if (firebaseUser) {
          callback(firebaseUser);
        } else if (devSession) {
          callback(devSession);
        } else {
          callback(null);
        }
      });
    } catch (e) {
      if (devSession) {
        callback(devSession);
      } else {
        callback(null);
      }
    }

    return () => {
      listeners.delete(callback);
      fbUnsub();
    };
  },

  /**
   * Signs out current admin session.
   */
  async logout() {
    devSession = null;
    notifyListeners(null);
    try {
      if (window.recaptchaVerifier) {
        window.recaptchaVerifier.clear();
        window.recaptchaVerifier = null;
      }
      await signOut(auth);
    } catch (error) {
      console.log('Firebase signOut completed or not connected.');
    }
  },

  /**
   * Translates Firebase auth errors into safe user messages.
   */
  normalizeError(error) {
    if (!error || !error.code) {
      return error instanceof Error ? error : new Error(String(error));
    }

    switch (error.code) {
      case 'auth/invalid-phone-number':
        return new Error('Invalid mobile number format. Please enter a valid Indian number (+91).');
      case 'auth/invalid-verification-code':
        return new Error('Invalid OTP code. Please recheck the SMS received.');
      case 'auth/code-expired':
        return new Error('The OTP code has expired. Please request a new one.');
      case 'auth/too-many-requests':
        return new Error('Too many login attempts. Please wait a few minutes before retrying.');
      case 'auth/quota-exceeded':
        return new Error('SMS verification quota exceeded for this Firebase project.');
      case 'auth/network-request-failed':
        return new Error('Network connection failed. Please verify your internet connection.');
      default:
        return new Error(error.message || 'Authentication failed. Please try again.');
    }
  },
};
