import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/user_role.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../models/app_user.dart';
import '../../models/school.dart';
import '../../models/driver.dart';
import '../../models/bus.dart';
import '../../models/student.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

/// Authentication state phases.
enum AuthStatus {
  initial,
  unauthenticated,
  sendingOtp,
  otpSent,
  verifyingOtp,
  authenticated,
  unregistered,
  error,
}

/// Central controller for authentication, session restoration, and user profile state.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  StreamSubscription<User?>? _authSubscription;
  Timer? _cooldownTimer;

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  School? _currentSchool;
  School? get currentSchool => _currentSchool;

  Driver? _driverProfile;
  Driver? get driverProfile => _driverProfile;

  Bus? _assignedBus;
  Bus? get assignedBus => _assignedBus;

  List<Student> _parentStudents = [];
  List<Student> get parentStudents => _parentStudents;

  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

  String? _verificationId;
  String? get verificationId => _verificationId;

  int? _resendToken;
  int _cooldownSeconds = 0;
  int get cooldownSeconds => _cooldownSeconds;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == AuthStatus.initial ||
      _status == AuthStatus.sendingOtp ||
      _status == AuthStatus.verifyingOtp;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  UserRole get currentRole => _currentUser?.role ?? UserRole.unknown;

  AuthController({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository() {
    _init();
  }

  /// Initializes auth stream listener and restores persistent session on cold start.
  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _currentSchool = null;
        _driverProfile = null;
        _assignedBus = null;
        _parentStudents = [];
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        await _fetchUserProfileAndRoute(firebaseUser.uid);
      }
    });
  }

  /// Fetches profile document from Firestore.
  /// Enforces: If user is authenticated in Firebase Auth but has no Firestore profile,
  /// mark as unregistered (do NOT elevate to admin or arbitrary role).
  Future<void> _fetchUserProfileAndRoute(String uid) async {
    try {
      final user = await _userRepository.getUserProfile(uid);
      if (user == null || !user.active) {
        _currentUser = user;
        _status = AuthStatus.unregistered;
        notifyListeners();
        return;
      }

      _currentUser = user;

      // Fetch School details if schoolId is linked
      if (user.schoolId.isNotEmpty) {
        _currentSchool = await _userRepository.getSchool(user.schoolId);
      }

      // If Driver, load driver profile and assigned bus
      if (user.role.isDriver) {
        _driverProfile = await _userRepository.getDriverProfile(uid);
        if (_driverProfile?.assignedBusId != null) {
          _assignedBus = await _userRepository.getBus(_driverProfile!.assignedBusId!);
        }
      }

      // If Parent, load associated students
      if (user.role.isParent && user.schoolId.isNotEmpty) {
        _parentStudents = await _userRepository.getStudentsForParent(
          schoolId: user.schoolId,
          parentUid: uid,
        );
      }

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = ErrorHandler.handle(e).message;
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  /// Sends 6-digit OTP code to the requested phone number.
  Future<void> sendOtp(String formattedPhone) async {
    _phoneNumber = formattedPhone;
    _status = AuthStatus.sendingOtp;
    _errorMessage = null;
    notifyListeners();

    await _authRepository.sendOtp(
      phoneNumber: formattedPhone,
      forceResendingToken: _resendToken,
      onCodeSent: (String verId, int? resendToken) {
        _verificationId = verId;
        _resendToken = resendToken;
        _status = AuthStatus.otpSent;
        _startCooldownTimer();
        notifyListeners();
      },
      onVerificationFailed: (AppException exception) {
        _status = AuthStatus.error;
        _errorMessage = exception.message;
        notifyListeners();
      },
      onAutoVerified: (UserCredential credential) async {
        if (credential.user != null) {
          await _fetchUserProfileAndRoute(credential.user!.uid);
        }
      },
    );
  }

  /// Resends OTP if cooldown timer has completed.
  Future<void> resendOtp() async {
    if (_cooldownSeconds > 0 || _phoneNumber == null) return;
    await sendOtp(_phoneNumber!);
  }

  /// Verifies entered OTP SMS code.
  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      _errorMessage = 'Session expired. Please request a new OTP.';
      _status = AuthStatus.error;
      notifyListeners();
      return;
    }

    _status = AuthStatus.verifyingOtp;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      if (credential.user != null) {
        await _fetchUserProfileAndRoute(credential.user!.uid);
      }
    } catch (e) {
      _status = AuthStatus.otpSent;
      _errorMessage = ErrorHandler.handle(e).message;
      notifyListeners();
    }
  }

  /// Resets back to phone number input screen.
  void changePhoneNumber() {
    _verificationId = null;
    _cooldownTimer?.cancel();
    _cooldownSeconds = 0;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clears any transient error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Logs out the user from Firebase and clears memory state.
  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _currentSchool = null;
      _driverProfile = null;
      _assignedBus = null;
      _parentStudents = [];
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = ErrorHandler.handle(e).message;
      notifyListeners();
    }
  }

  void _startCooldownTimer() {
    _cooldownSeconds = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        _cooldownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
