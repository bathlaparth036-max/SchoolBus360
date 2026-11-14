import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

/// Entry point for SchoolBus360 Flutter Mobile Application.
/// Initializes Firebase and enables Firestore offline persistence
/// for reliable operation across patchy mobile networks in India.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase SDK
  await Firebase.initializeApp();

  // Configure Firestore offline persistence for patchy network tolerance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const SchoolBus360App());
}
