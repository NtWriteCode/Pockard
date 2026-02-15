import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart';

/// Service for WebDAV operations
class WebDavService {
  static final WebDavService _instance = WebDavService._internal();
  factory WebDavService() => _instance;
  WebDavService._internal();

  Client? _client;
  DateTime? _lastRequestTime;

  // Timeouts to prevent hanging on slow connections
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _transferTimeout = Duration(seconds: 30);

  /// Initialize WebDAV client with credentials
  void initialize(String serverUrl, String username, String password) {
    // Ensure server URL has protocol
    if (!serverUrl.startsWith('http://') && !serverUrl.startsWith('https://')) {
      serverUrl = 'https://$serverUrl';
    }

    _client = newClient(serverUrl, user: username, password: password, debug: false);
  }

  /// Add rate limiting between requests to prevent overwhelming the server
  Future<void> _rateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      const minDelay = Duration(milliseconds: 100); // Minimum 100ms between requests

      if (timeSinceLastRequest < minDelay) {
        final delayNeeded = minDelay - timeSinceLastRequest;
        await Future.delayed(delayNeeded);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Test connection to WebDAV server
  Future<bool> testConnection() async {
    try {
      if (_client == null) return false;

      // Try to ping the server
      await _client!.ping().timeout(_connectionTimeout);

      // Test write permissions by attempting to create a test file
      try {
        final testData = Uint8List.fromList('test'.codeUnits);
        final testPath = '/pockard/.write_test_${DateTime.now().millisecondsSinceEpoch}';
        await _client!.write(testPath, testData).timeout(_connectionTimeout);

        // Clean up test file
        try {
          await _client!.remove(testPath).timeout(_connectionTimeout);
        } catch (cleanupError) {
          debugPrint('Warning: Could not clean up test file: $cleanupError');
        }

        debugPrint('WebDAV connection and write permissions verified');
        return true;
      } catch (writeError) {
        debugPrint('WebDAV write permission test failed: $writeError');
        // Check if it's a permission error
        final errorString = writeError.toString().toLowerCase();
        if (errorString.contains('403') || errorString.contains('forbidden')) {
          debugPrint('Write permission denied - user may have read-only access');
        }
        return false;
      }
    } catch (e) {
      debugPrint('WebDAV connection test failed: $e');
      return false;
    }
  }

  /// Check if a directory exists
  Future<bool> directoryExists(String path) async {
    try {
      if (_client == null) return false;

      await _client!.readDir(path).timeout(_connectionTimeout);
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

      await _client!.mkdir(path).timeout(_connectionTimeout);
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
      await createDirectory('$pockardPath/documents');
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

  /// Upload a file to WebDAV server with retry logic
  Future<void> uploadFile(String localPath, String remotePath) async {
    const maxRetries = 3;
    const baseDelay = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (_client == null) {
          throw Exception('WebDAV client not initialized');
        }

        final file = io.File(localPath);
        if (!await file.exists()) {
          throw Exception('Local file does not exist: $localPath');
        }

        final bytes = await file.readAsBytes();
        await _rateLimit(); // Add rate limiting
        await _client!.write(remotePath, bytes).timeout(_transferTimeout);
        debugPrint('Uploaded file: $remotePath');
        return; // Success, exit retry loop
      } catch (e) {
        debugPrint('Error uploading file $remotePath (attempt ${attempt + 1}/$maxRetries): $e');

        // Check for specific errors
        final errorString = e.toString().toLowerCase();

        // Handle locked responses with retry
        if (errorString.contains('423') || errorString.contains('locked')) {
          if (attempt < maxRetries - 1) {
            final delay = Duration(milliseconds: baseDelay.inMilliseconds * (1 << attempt)); // Exponential backoff
            debugPrint('File locked, retrying in ${delay.inMilliseconds}ms...');
            await Future.delayed(delay);
            continue;
          } else {
            throw Exception('File locked: Server returned 423 Locked after $maxRetries attempts. The file may be in use by another process.');
          }
        }

        // Handle other specific errors
        if (errorString.contains('403') || errorString.contains('forbidden')) {
          throw Exception('Write permission denied: Server returned 403 Forbidden. Please check your WebDAV permissions.');
        } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
          throw Exception('Authentication failed: Server returned 401 Unauthorized. Please check your credentials.');
        } else if (errorString.contains('404') || errorString.contains('not found')) {
          throw Exception('Directory not found: Server returned 404. Please check if the WebDAV path exists.');
        } else if (errorString.contains('500') || errorString.contains('internal server error')) {
          throw Exception('Server error: Server returned 500 Internal Server Error. Please try again later.');
        }

        // For other errors, don't retry
        rethrow;
      }
    }
  }

  /// Upload bytes directly to WebDAV server with retry logic
  Future<void> uploadBytes(Uint8List bytes, String remotePath) async {
    const maxRetries = 3;
    const baseDelay = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (_client == null) {
          throw Exception('WebDAV client not initialized');
        }

        await _rateLimit(); // Add rate limiting
        await _client!.write(remotePath, bytes).timeout(_transferTimeout);
        debugPrint('Uploaded bytes to: $remotePath');
        return; // Success, exit retry loop
      } catch (e) {
        debugPrint('Error uploading bytes to $remotePath (attempt ${attempt + 1}/$maxRetries): $e');

        // Check for specific errors
        final errorString = e.toString().toLowerCase();

        // Handle locked responses with retry
        if (errorString.contains('423') || errorString.contains('locked')) {
          if (attempt < maxRetries - 1) {
            final delay = Duration(milliseconds: baseDelay.inMilliseconds * (1 << attempt)); // Exponential backoff
            debugPrint('File locked, retrying in ${delay.inMilliseconds}ms...');
            await Future.delayed(delay);
            continue;
          } else {
            throw Exception('File locked: Server returned 423 Locked after $maxRetries attempts. The file may be in use by another process.');
          }
        }

        // Handle other specific errors
        if (errorString.contains('403') || errorString.contains('forbidden')) {
          throw Exception('Write permission denied: Server returned 403 Forbidden. Please check your WebDAV permissions.');
        } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
          throw Exception('Authentication failed: Server returned 401 Unauthorized. Please check your credentials.');
        } else if (errorString.contains('404') || errorString.contains('not found')) {
          throw Exception('Directory not found: Server returned 404. Please check if the WebDAV path exists.');
        } else if (errorString.contains('500') || errorString.contains('internal server error')) {
          throw Exception('Server error: Server returned 500 Internal Server Error. Please try again later.');
        }

        // For other errors, don't retry
        rethrow;
      }
    }
  }

  /// Download a file from WebDAV server
  Future<Uint8List> downloadFile(String remotePath) async {
    try {
      if (_client == null) {
        throw Exception('WebDAV client not initialized');
      }

      await _rateLimit(); // Add rate limiting
      final bytes = await _client!.read(remotePath).timeout(_transferTimeout);
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

      await _rateLimit(); // Add rate limiting
      final list = await _client!.readDir(path).timeout(_connectionTimeout);
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

      await _rateLimit(); // Add rate limiting
      await _client!.remove(remotePath).timeout(_connectionTimeout);
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
      await _rateLimit(); // Add rate limiting
      await _client!.read(remotePath).timeout(_transferTimeout);
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
