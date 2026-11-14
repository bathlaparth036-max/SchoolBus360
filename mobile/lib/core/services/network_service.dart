import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity changes.
/// Critical for patchy 2G/3G/4G coverage in rural/semi-urban Indian environments.
class NetworkService extends ChangeNotifier {
  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      // Default to optimistic online in case connectivity check fails
      _isOnline = true;
    }

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
