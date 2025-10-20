import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'webdav_service.dart';
import 'sync_settings_service.dart';

/// Service for syncing user preferences (display settings, tag order, etc.) via WebDAV
class PreferencesSyncService {
  static final PreferencesSyncService _instance = PreferencesSyncService._internal();
  factory PreferencesSyncService() => _instance;
  PreferencesSyncService._internal();

  final WebDavService _webdavService = WebDavService();
  final SyncSettingsService _syncSettingsService = SyncSettingsService();

  /// Upload user preferences to WebDAV server
  Future<void> uploadPreferences({required Map<String, dynamic> displaySettings, required List<String> tagOrder}) async {
    debugPrint('PreferencesSyncService: Starting preferences upload...');

    if (!_webdavService.isInitialized) {
      debugPrint('PreferencesSyncService: WebDAV client not initialized');
      throw Exception('WebDAV client not initialized');
    }

    try {
      // Get the configured pockard folder path
      final settings = await _syncSettingsService.loadSettings();
      final pockardPath = settings?.pockardFolderPath ?? '/pockard';
      debugPrint('PreferencesSyncService: Using pockard path: $pockardPath');

      final preferences = {'display_settings': displaySettings, 'tag_order': tagOrder, 'last_updated': DateTime.now().toIso8601String()};
      debugPrint('PreferencesSyncService: Preferences data: $preferences');

      // Create JSON file
      final preferencesJson = json.encode(preferences);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_preferences.json');
      await tempFile.writeAsString(preferencesJson);

      // Ensure file is fully written before attempting upload
      if (!await tempFile.exists()) {
        debugPrint('PreferencesSyncService: Failed to create temporary preferences file');
        throw Exception('Failed to create temporary preferences file');
      }

      // Upload to WebDAV using the configured path
      final remotePath = '$pockardPath/preferences.json';
      debugPrint('PreferencesSyncService: Uploading to remote path: $remotePath');
      await _webdavService.uploadFile(tempFile.path, remotePath);

      // Clean up temp file
      await tempFile.delete();

      debugPrint('PreferencesSyncService: Preferences uploaded successfully to $remotePath');
    } catch (e) {
      debugPrint('PreferencesSyncService: Error uploading preferences: $e');
      rethrow;
    }
  }

  /// Download user preferences from WebDAV server
  Future<Map<String, dynamic>?> downloadPreferences() async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    try {
      // Get the configured pockard folder path
      final settings = await _syncSettingsService.loadSettings();
      final pockardPath = settings?.pockardFolderPath ?? '/pockard';
      final remotePath = '$pockardPath/preferences.json';

      // Check if preferences file exists
      final exists = await _webdavService.fileExists(remotePath);
      if (!exists) {
        debugPrint('Preferences file does not exist on server at $remotePath');
        return null;
      }

      // Download preferences
      final bytes = await _webdavService.downloadFile(remotePath);
      final jsonString = utf8.decode(bytes);
      final preferences = json.decode(jsonString) as Map<String, dynamic>;

      debugPrint('Preferences downloaded successfully from $remotePath');
      return preferences;
    } catch (e) {
      debugPrint('Error downloading preferences: $e');
      return null;
    }
  }

  /// Check if remote preferences are newer than local
  Future<bool> areRemotePreferencesNewer(DateTime? localLastUpdate) async {
    if (localLastUpdate == null) return true;

    try {
      final remotePrefs = await downloadPreferences();
      if (remotePrefs == null) return false;

      final remoteLastUpdateStr = remotePrefs['last_updated'] as String?;
      if (remoteLastUpdateStr == null) return false;

      final remoteLastUpdate = DateTime.parse(remoteLastUpdateStr);
      return remoteLastUpdate.isAfter(localLastUpdate);
    } catch (e) {
      debugPrint('Error checking remote preferences: $e');
      return false;
    }
  }
}
