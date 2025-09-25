import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/card_model.dart';
import '../models/global_image_model.dart';
import 'webdav_service.dart';
import 'sync_settings_service.dart';

/// Service responsible for global cards and images management via WebDAV
class GlobalDataService {
  static final GlobalDataService _instance = GlobalDataService._internal();
  factory GlobalDataService() => _instance;
  GlobalDataService._internal();

  final WebDavService _webdavService = WebDavService();
  final SyncSettingsService _syncService = SyncSettingsService();

  /// Check if global folder is available
  Future<bool> isGlobalFolderAvailable() async {
    try {
      if (!_webdavService.isInitialized) {
        await _syncService.initializeFromSettings();
      }
      return await _webdavService.isGlobalFolderAvailable();
    } catch (e) {
      debugPrint('Error checking global folder availability: $e');
      return false;
    }
  }

  /// Get all global cards
  Future<List<CardModel>> getGlobalCards() async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    final cards = <CardModel>[];
    const globalCardsDir = '/pockard_global/cards';

    try {
      // List all JSON files in the global cards directory
      final files = await _webdavService.listFiles(globalCardsDir);
      final jsonFiles = files.where((file) => file.endsWith('.json')).toList();

      for (final file in jsonFiles) {
        try {
          final remotePath = '$globalCardsDir/$file';
          final bytes = await _webdavService.downloadFile(remotePath);
          
          final jsonString = utf8.decode(bytes);
          final cardData = json.decode(jsonString);
          
          final card = CardModel.fromMap(cardData);
          cards.add(card);
        } catch (e) {
          debugPrint('Error loading global card $file: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading global cards: $e');
    }

    return cards;
  }

  /// Share a card globally
  Future<void> shareCardGlobally(CardModel card, String uploaderIdentifier, String coverSuffix) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    try {
      const globalCardsDir = '/pockard_global/cards';
      
      // Ensure global cards directory exists
      try {
        await _webdavService.createDirectory(globalCardsDir);
      } catch (e) {
        // Directory might already exist
      }

      // Upload card JSON
      final cardJson = json.encode(card.toMap());
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_card_${card.uuid}.json');
      await tempFile.writeAsString(cardJson);
      
      final remotePath = '$globalCardsDir/${card.uuid}.json';
      await _webdavService.uploadFile(tempFile.path, remotePath);
      
      // Clean up temp file
      await tempFile.delete();

      // Upload cover image if it exists
      if (card.coverImagePath != null && await File(card.coverImagePath!).exists()) {
        const globalImagesDir = '/pockard_global/images';
        
        // Ensure global images directory exists
        try {
          await _webdavService.createDirectory(globalImagesDir);
        } catch (e) {
          // Directory might already exist
        }

        final imageFileName = '${card.uuid}_cover.jpg';
        final imageRemotePath = '$globalImagesDir/$imageFileName';
        await _webdavService.uploadFile(card.coverImagePath!, imageRemotePath);
        
        // Update image metadata so author is tracked
        final imageUuid = card.uuid; // Use card UUID without suffix
        final metadataUpdated = await _updateImageMetadata(imageUuid, '${card.name} $coverSuffix', uploaderIdentifier);
        if (!metadataUpdated) {
          debugPrint('Warning: Cover image uploaded but metadata update failed');
        }
      }

      debugPrint('Card shared globally: ${card.uuid}');
    } catch (e) {
      debugPrint('Error sharing card globally: $e');
      rethrow;
    }
  }

  /// Delete a global card
  Future<void> deleteGlobalCard(String uuid) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    try {
      const globalCardsDir = '/pockard_global/cards';
      final remotePath = '$globalCardsDir/$uuid.json';
      
      await _webdavService.deleteFile(remotePath);
      debugPrint('Global card deleted: $uuid');
    } catch (e) {
      debugPrint('Error deleting global card: $e');
      rethrow;
    }
  }

  /// Get all global images
  Future<List<GlobalImageModel>> getGlobalImages() async {
    if (!_webdavService.isInitialized) {
      debugPrint('ERROR: WebDAV client not initialized when loading global images');
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    final images = <GlobalImageModel>[];
    const globalImagesDir = '/pockard_global/images';
    debugPrint('DEBUG: Loading global images from: $globalImagesDir');

    try {
      // Load metadata first
      Map<String, dynamic> metadata = {};
      try {
        const metadataPath = '$globalImagesDir/images_metadata.json';
        debugPrint('DEBUG: Attempting to load metadata from: $metadataPath');
        final bytes = await _webdavService.downloadFile(metadataPath);
        final metadataString = utf8.decode(bytes);
        debugPrint('DEBUG: Raw metadata content: $metadataString');
        metadata = json.decode(metadataString);
        debugPrint('DEBUG: Parsed metadata: $metadata');
      } catch (e) {
        debugPrint('ERROR: No metadata file found or error loading metadata: $e');
        // Continue without metadata
      }

      // List all image files in the global images directory
      debugPrint('DEBUG: Listing files in global images directory...');
      final files = await _webdavService.listFiles(globalImagesDir);
      debugPrint('DEBUG: Found ${files.length} total files: $files');
      
      final imageFiles = files.where((file) => 
        file.toLowerCase().endsWith('.jpg') || 
        file.toLowerCase().endsWith('.jpeg') || 
        file.toLowerCase().endsWith('.png')
      ).toList();
      debugPrint('DEBUG: Filtered to ${imageFiles.length} image files: $imageFiles');

      for (final file in imageFiles) {
        try {
          debugPrint('DEBUG: Processing image file: $file');
          
          // Extract UUID from filename (format: uuid_suffix.extension or uuid.extension)
          final fileName = path.basenameWithoutExtension(file);
          // Remove suffixes like "_cover", "_logo", etc. to get the base UUID
          String uuid = fileName;
          if (fileName.contains('_')) {
            uuid = fileName.split('_').first;
          }
          debugPrint('DEBUG: Extracted UUID: $uuid from filename: $fileName');
          
          // Get metadata for this image
          final imageMetadata = metadata[uuid] as Map<String, dynamic>?;
          debugPrint('DEBUG: Metadata for $uuid: $imageMetadata');
          
          // Use user-friendly name from metadata, fallback to filename
          String displayName;
          if (imageMetadata != null && imageMetadata['name'] != null) {
            displayName = imageMetadata['name'] as String;
            debugPrint('DEBUG: Using metadata name: $displayName');
          } else {
            // Fallback to filename if no metadata
            displayName = file;
            debugPrint('DEBUG: No metadata found, using filename: $displayName');
          }
          
          // Get upload date from metadata, fallback to now
          DateTime uploadDate;
          if (imageMetadata != null && imageMetadata['uploadDate'] != null) {
            uploadDate = DateTime.fromMillisecondsSinceEpoch(imageMetadata['uploadDate'] as int);
            debugPrint('DEBUG: Using metadata upload date: $uploadDate');
          } else {
            uploadDate = DateTime.now();
            debugPrint('DEBUG: No metadata upload date, using now: $uploadDate');
          }
          
          // Get uploader from metadata, fallback to unknown
          String uploader;
          if (imageMetadata != null && imageMetadata['uploaderPseudoUser'] != null) {
            uploader = imageMetadata['uploaderPseudoUser'] as String;
            debugPrint('DEBUG: Using metadata uploader: $uploader');
          } else {
            uploader = 'unknown';
            debugPrint('DEBUG: No metadata uploader, using unknown: $uploader');
          }
          
          final image = GlobalImageModel(
            uuid: uuid,
            name: displayName,
            imagePath: file,
            uploadDate: uploadDate,
            uploaderPseudoUser: uploader,
          );
          
          images.add(image);
          debugPrint('DEBUG: Successfully created GlobalImageModel: name=$displayName, uuid=$uuid, path=$file');
        } catch (e) {
          debugPrint('ERROR: Failed to process global image $file: $e');
        }
      }
    } catch (e) {
      debugPrint('ERROR: Failed to load global images from $globalImagesDir: $e');
    }

    debugPrint('DEBUG: Returning ${images.length} global images');
    for (final image in images) {
      debugPrint('DEBUG: Final image - name: "${image.name}", uuid: ${image.uuid}, path: ${image.imagePath}');
    }
    return images;
  }

  /// Share an image globally
  Future<void> shareImageGlobally(String imagePath, String imageName, String uploaderIdentifier) async {
    if (!_webdavService.isInitialized) {
      debugPrint('ERROR: WebDAV client not initialized when sharing image globally');
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    try {
      const globalImagesDir = '/pockard_global/images';
      debugPrint('DEBUG: Sharing image globally to: $globalImagesDir');
      debugPrint('DEBUG: Image path: $imagePath');
      debugPrint('DEBUG: Image name: $imageName');
      debugPrint('DEBUG: Uploader: $uploaderIdentifier');
      
      // Ensure global images directory exists
      try {
        await _webdavService.createDirectory(globalImagesDir);
        debugPrint('DEBUG: Created global images directory');
      } catch (e) {
        debugPrint('DEBUG: Global images directory might already exist: $e');
      }

      // Generate unique filename (just UUID + extension)
      final uuid = const Uuid().v4();
      final fileExtension = path.extension(imagePath);
      final fileName = '$uuid$fileExtension';
      debugPrint('DEBUG: Generated filename: $fileName (UUID: $uuid, extension: $fileExtension)');
      
      final remotePath = '$globalImagesDir/$fileName';
      debugPrint('DEBUG: Uploading image to: $remotePath');
      await _webdavService.uploadFile(imagePath, remotePath);
      debugPrint('DEBUG: Image uploaded successfully');

      // Update metadata file
      debugPrint('DEBUG: Updating metadata for image: $uuid');
      final metadataSuccess = await _updateImageMetadata(uuid, imageName, uploaderIdentifier);
      if (!metadataSuccess) {
        debugPrint('WARNING: Image uploaded but metadata update failed - uploader may show as unknown');
        // Still consider the operation successful since image was uploaded
      } else {
        debugPrint('DEBUG: Metadata updated successfully');
      }

      debugPrint('SUCCESS: Image shared globally: $fileName');
    } catch (e) {
      debugPrint('ERROR: Failed to share image globally: $e');
      rethrow;
    }
  }

  /// Update the images metadata file
  /// Returns true if successful, false if failed
  Future<bool> _updateImageMetadata(String uuid, String imageName, String uploaderIdentifier) async {
    try {
      const globalImagesDir = '/pockard_global/images';
      const metadataPath = '$globalImagesDir/images_metadata.json';
      
      // Load existing metadata
      Map<String, dynamic> metadata = {};
      try {
        final bytes = await _webdavService.downloadFile(metadataPath);
        final metadataString = utf8.decode(bytes);
        metadata = json.decode(metadataString) as Map<String, dynamic>;
      } catch (e) {
        // Continue with empty metadata
      }

      // Add/update metadata for this image
      final newImageMetadata = {
        'name': imageName,
        'uploadDate': DateTime.now().millisecondsSinceEpoch,
        'uploaderPseudoUser': uploaderIdentifier,
      };
      metadata[uuid] = newImageMetadata;

      // Upload updated metadata
      final metadataJson = json.encode(metadata);
      final tempDir = await getTemporaryDirectory();
      final tempMetadataFile = File('${tempDir.path}/temp_metadata.json');
      await tempMetadataFile.writeAsString(metadataJson);
      
      await _webdavService.uploadFile(tempMetadataFile.path, metadataPath);
      
      // Clean up temp file
      try {
        await tempMetadataFile.delete();
      } catch (e) {
        // Ignore cleanup errors
      }
      
      return true;
    } catch (e) {
      debugPrint('Failed to update image metadata: $e');
      // Don't rethrow - metadata update failure shouldn't break image upload
      return false;
    }
  }

  /// Delete a global image
  Future<void> deleteGlobalImage(String uuid) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    try {
      const globalImagesDir = '/pockard_global/images';
      
      // Find the image file with this UUID
      final files = await _webdavService.listFiles(globalImagesDir);
      final imageFile = files.firstWhere(
        (file) => file.startsWith(uuid),
        orElse: () => throw Exception('Image not found'),
      );
      
      final remotePath = '$globalImagesDir/$imageFile';
      await _webdavService.deleteFile(remotePath);
      
      // Remove from metadata
      await _removeImageMetadata(uuid);
      
      debugPrint('Global image deleted: $uuid');
    } catch (e) {
      debugPrint('Error deleting global image: $e');
      rethrow;
    }
  }

  /// Remove image metadata entry
  Future<void> _removeImageMetadata(String uuid) async {
    try {
      const globalImagesDir = '/pockard_global/images';
      const metadataPath = '$globalImagesDir/images_metadata.json';
      
      // Load existing metadata
      Map<String, dynamic> metadata = {};
      try {
        final bytes = await _webdavService.downloadFile(metadataPath);
        final metadataString = utf8.decode(bytes);
        metadata = json.decode(metadataString);
      } catch (e) {
        debugPrint('No existing metadata file to update: $e');
        return; // Nothing to remove
      }

      // Remove metadata for this image
      metadata.remove(uuid);

      // Upload updated metadata
      final metadataJson = json.encode(metadata);
      final tempDir = await getTemporaryDirectory();
      final tempMetadataFile = File('${tempDir.path}/temp_metadata.json');
      await tempMetadataFile.writeAsString(metadataJson);
      
      await _webdavService.uploadFile(tempMetadataFile.path, metadataPath);
      await tempMetadataFile.delete(); // Clean up temp file
      
      debugPrint('Removed metadata for image: $uuid');
    } catch (e) {
      debugPrint('Error removing image metadata: $e');
      // Don't rethrow - metadata update failure shouldn't break image deletion
    }
  }

  /// Download a global image to local storage
  Future<String> downloadGlobalImage(GlobalImageModel image) async {
    if (!_webdavService.isInitialized) {
      throw Exception('WebDAV client not initialized');
    }

    // Check if global folder is available
    if (!await isGlobalFolderAvailable()) {
      throw Exception('Global folder (/pockard_global) not available on server');
    }

    try {
      const globalImagesDir = '/pockard_global/images';
      // Use imagePath (UUID-based filename) instead of name (user-friendly display name)
      final remotePath = '$globalImagesDir/${image.imagePath}';
      debugPrint('DEBUG: Downloading global image from: $remotePath');
      
      // Download image bytes
      final bytes = await _webdavService.downloadFile(remotePath);
      debugPrint('DEBUG: Downloaded ${bytes.length} bytes');
      
      // Save to temp directory with a unique name
      final tempDir = await getTemporaryDirectory();
      final finalPath = path.join(tempDir.path, 'pockard_images_${image.uuid}_${path.basename(image.imagePath)}');
      
      await File(finalPath).writeAsBytes(bytes);
      debugPrint('DEBUG: Final image path: $finalPath');
      
      return finalPath;
    } catch (e) {
      debugPrint('Error downloading global image: $e');
      rethrow;
    }
  }
}
