import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sync_settings_model.dart';
import 'sync_settings_service.dart';

/// Manager for WebDAV connection and sync status
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final SyncSettingsService _syncService = SyncSettingsService();

  bool _isConnected = false;
  bool _isConnecting = false;
  SyncSettingsModel? _currentSettings;

  // Sync status stream (true = last sync succeeded, false = last sync failed or no sync yet)
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatus => _syncStatusController.stream;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get lastSyncSuccess {
    if (_currentSettings == null) return true; // No sync configured, show as success
    // If there's never been a sync attempt, show as failed (red dot)
    if (_currentSettings!.lastSyncAttempt == null) return false;
    // Otherwise, use the actual last sync result
    return _currentSettings!.lastSyncSuccess;
  }

  /// Initialize connection on app start
  Future<void> initializeConnection() async {
    if (_isConnecting) return;

    try {
      final settings = await _syncService.loadSettings();
      if (settings != null && settings.hasCredentials) {
        _currentSettings = settings;
        // Broadcast initial sync status - show as failed if never attempted
        _syncStatusController.add(lastSyncSuccess);
        await _testConnectionInBackground();
      } else {
        // No settings available, broadcast success (no sync to fail)
        _syncStatusController.add(true);
      }
    } catch (e) {
      debugPrint('Failed to initialize connection: $e');
      _syncStatusController.add(false);
    }
  }

  /// Test connection in background without blocking UI
  Future<void> _testConnectionInBackground() async {
    if (_isConnecting || _currentSettings == null) return;

    _isConnecting = true;
    debugPrint('Testing WebDAV connection...');

    try {
      final success = await _syncService.testConnection(_currentSettings!);
      _isConnected = success;

      if (_isConnected) {
        debugPrint('WebDAV connection established');
        // Reload settings to get updated sync status
        _currentSettings = await _syncService.loadSettings();
        // Broadcast sync status - show as failed if never attempted
        _syncStatusController.add(lastSyncSuccess);
      } else {
        debugPrint('WebDAV connection failed');
        // Connection failed, so sync status is also failed
        _syncStatusController.add(false);
      }
    } catch (e) {
      debugPrint('WebDAV connection error: $e');
      _isConnected = false;
      _syncStatusController.add(false);
    } finally {
      _isConnecting = false;
    }
  }

  /// Force reconnection (called when user needs connection)
  Future<bool> ensureConnection() async {
    if (_isConnected) return true;

    if (_currentSettings == null) {
      final settings = await _syncService.loadSettings();
      if (settings == null || !settings.hasCredentials) {
        return false;
      }
      _currentSettings = settings;
    }

    if (_isConnecting) {
      // Wait for current connection attempt
      await Future.delayed(const Duration(milliseconds: 100));
      return _isConnected;
    }

    return await _connectSynchronously();
  }

  /// Synchronous connection for when user needs immediate connection
  Future<bool> _connectSynchronously() async {
    if (_currentSettings == null) return false;

    _isConnecting = true;
    try {
      final success = await _syncService.testConnection(_currentSettings!);
      _isConnected = success;

      if (_isConnected) {
        // Reload settings to get updated sync status
        _currentSettings = await _syncService.loadSettings();
        _syncStatusController.add(lastSyncSuccess);
      } else {
        _syncStatusController.add(false);
      }

      return _isConnected;
    } catch (e) {
      debugPrint('Synchronous WebDAV connection error: $e');
      _isConnected = false;
      _syncStatusController.add(false);
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// Update settings and test new connection
  Future<void> updateSettings(SyncSettingsModel settings) async {
    _currentSettings = settings;
    _disconnect();

    if (settings.hasCredentials) {
      await _testConnectionInBackground();
    }
  }

  /// Disconnect and clean up
  void _disconnect() {
    _isConnected = false;
    _isConnecting = false;
    _syncStatusController.add(false);
    _syncService.disconnect();
  }

  /// Refresh sync status (call this after a sync operation completes)
  Future<void> refreshSyncStatus() async {
    final settings = await _syncService.loadSettings();
    if (settings != null) {
      _currentSettings = settings;
      _syncStatusController.add(lastSyncSuccess);
    }
  }

  /// Manual disconnect (user initiated)
  Future<void> disconnect() async {
    _disconnect();

    // Update persistent storage
    if (_currentSettings != null) {
      final updatedSettings = _currentSettings!.copyWith(isConnected: false);
      await _syncService.saveSettings(updatedSettings);
    }
  }

  /// Get current settings
  SyncSettingsModel? get currentSettings => _currentSettings;

  /// Get current sync settings
  SyncSettingsModel? get syncSettings => _currentSettings;

  /// Dispose resources
  void dispose() {
    _syncStatusController.close();
  }
}
