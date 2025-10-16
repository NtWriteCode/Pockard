import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart';

/// Service for WebDAV operations
class WebDavService {
  static final WebDavService _instance = WebDavService._internal();
  factory WebDavService() => _instance;
  WebDavService._internal();

  Client? _client;

  /// Initialize WebDAV client with credentials
  void initialize(String serverUrl, String username, String password) {
    // Ensure server URL has protocol
    if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
      serverUrl = 'https://$serverUrl';
    }

    _client = newClient(serverUrl, user: username, password: password, debug: false);
  }

  /// Test connection to WebDAV server
  Future<bool> testConnection() async {
    try {
      if (_client == null) return false;

      // Try to ping the server
      await _client!.ping();
      return true;
    } catch (e) {
      debugPrint('WebDAV connection test failed: $e');
      return false;
    }
  }

  /// Check if a directory exists
  Future<bool> directoryExists(String path) async {
    try {
      if (_client == null) return false;

      await _client!.readDir(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create directory (recursively if needed)
  Future<void> createDirectory(String path) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      await _client!.mkdir(path);
      debugPrint('Created directory: $path');
    } catch (e) {
      // Ignore if directory already exists
      if (!e.toString().contains('405') && !e.toString().contains('already exists')) {
        debugPrint('Error creating directory $path: $e');
        rethrow;
      }
    }
  }

  /// Create directory structure for the app
  Future<void> createAppDirectories({String pockardPath = '/pockard'}) async {
    if (_client == null) {
      throw Exception('WebDAV client not initialized');
    }

    try {
      // Create pockard folder
      await createDirectory(pockardPath);
      await createDirectory('$pockardPath/cards');
      await createDirectory('$pockardPath/images');
      debugPrint('Created app directories');
    } catch (e) {
      debugPrint('Error creating app directories: $e');
      rethrow;
    }
  }

  /// Check if global folder is available
  Future<bool> isGlobalFolderAvailable({String globalPath = '/pockard_global'}) async {
    try {
      if (_client == null) return false;
      return await directoryExists(globalPath);
    } catch (e) {
      debugPrint('Error checking global folder: $e');
      return false;
    }
  }

  /// Upload a file to WebDAV server
  Future<void> uploadFile(String localPath, String remotePath) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      final file = io.File(localPath);
      if (!await file.exists()) {
        throw Exception('Local file does not exist: $localPath');
      }

      final bytes = await file.readAsBytes();
      await _client!.write(remotePath, bytes);
      debugPrint('Uploaded file: $remotePath');
    } catch (e) {
      debugPrint('Error uploading file $remotePath: $e');
      rethrow;
    }
  }

  /// Upload bytes directly to WebDAV server
  Future<void> uploadBytes(Uint8List bytes, String remotePath) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      await _client!.write(remotePath, bytes);
      debugPrint('Uploaded bytes to: $remotePath');
    } catch (e) {
      debugPrint('Error uploading bytes to $remotePath: $e');
      rethrow;
    }
  }

  /// Download a file from WebDAV server
  Future<Uint8List> downloadFile(String remotePath) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      final bytes = await _client!.read(remotePath);
      debugPrint('Downloaded file: $remotePath');
      return Uint8List.fromList(bytes);
    } catch (e) {
      debugPrint('Error downloading file $remotePath: $e');
      rethrow;
    }
  }

  /// List files in a directory
  Future<List<String>> listFiles(String path) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      final list = await _client!.readDir(path);
      final files = list.where((item) => !item.isDir!).map((item) => item.name!).toList();

      debugPrint('Listed ${files.length} files in $path');
      return files;
    } catch (e) {
      debugPrint('Error listing files in $path: $e');
      return [];
    }
  }

  /// Delete a file
  Future<void> deleteFile(String remotePath) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      await _client!.remove(remotePath);
      debugPrint('Deleted file: $remotePath');
    } catch (e) {
      debugPrint('Error deleting file $remotePath: $e');
      rethrow;
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String remotePath) async {
    try {
      if (_client == null) return false;

      // Try to read file bytes (if it exists, this won't fail)
      await _client!.read(remotePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disconnect (cleanup)
  void disconnect() {
    _client = null;
    debugPrint('WebDAV client disconnected');
  }

  /// Check if client is initialized
  bool get isInitialized => _client != null;
}
