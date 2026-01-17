import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../repositories/user_repository.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final SyncService _syncService = SyncService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  Timer? _debounceSyncTimer;
  Function? onSyncCompleted;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    // Don't notify listeners here to avoid build phase issues

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _userRepository.getCurrentUser();

        // Trigger sync in background after initialization
        _syncInBackground();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    // Only notify after initialization is complete
    notifyListeners();
  }

  /// Sync in background without blocking UI
  void _syncInBackground() {
    Future.delayed(Duration.zero, () async {
      try {
        final result = await _syncService.sync();

        // If sync was unauthorized, log the user out
        if (result['unauthorized'] == true) {
          await logout();
          return;
        }

        // If sync was successful, reload user to get updated last_sync_at
        if (result['success'] == true && _currentUser != null) {
          _currentUser = await _userRepository.getCurrentUser();
          notifyListeners();

          // Notify listeners that sync completed (e.g., to refresh pending sync count)
          onSyncCompleted?.call();
        }
      } catch (e) {
        // Silent fail - don't interrupt user experience
        debugPrint('Background sync failed: $e');
      }
    });
  }

  /// Debounced sync - waits for user to stop making changes before syncing
  /// This prevents overwhelming the server with requests while still syncing quickly
  /// Set SYNC_DEBOUNCE_SECONDS=0 in config for immediate sync
  void scheduleDebouncedSync() {
    // Cancel any pending sync
    _debounceSyncTimer?.cancel();

    // If debounce is 0, sync immediately
    if (AppConfig.syncDebounceSeconds == 0) {
      _syncInBackground();
      return;
    }

    // Schedule a new sync after configured seconds of inactivity
    _debounceSyncTimer = Timer(
      Duration(seconds: AppConfig.syncDebounceSeconds),
      () {
        _syncInBackground();
      },
    );
  }

  @override
  void dispose() {
    _debounceSyncTimer?.cancel();
    super.dispose();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result['success']) {
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();

        // Trigger sync in background after successful login
        _syncInBackground();

        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String? displayName,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.deleteAccount(password: password);

      if (result['success']) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    try {
      // Fetch fresh user data from the API
      final userData = await _authService.getCurrentUserFromApi();

      if (userData != null) {
        _currentUser = userData;
        // Save to local database
        await _userRepository.saveUser(userData);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Trigger sync manually (e.g., when app resumes or device comes online)
  void triggerSync() {
    if (isAuthenticated) {
      _syncInBackground();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
