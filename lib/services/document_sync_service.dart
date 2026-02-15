import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/document_model.dart';
import '../services/webdav_service.dart';
import '../services/sync_settings_service.dart';

class DocumentSyncService {
  final WebDavService _webdavService = WebDavService();
  final SyncSettingsService _syncSettingsService = SyncSettingsService();

  /// Export a single document (metadata + PDF) to the server
  Future<void> exportDocument(DocumentModel document) async {
    if (!_webdavService.isInitialized) {
      await _syncSettingsService.initializeFromSettings();
    }

    final settings = await _syncSettingsService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';
    final docRemotePath = '$pockardPath/documents/${document.uuid}.json';
    final pdfRemotePath = '$pockardPath/documents/${document.uuid}.pdf';

    try {
      // 1. Upload Metadata JSON
      final jsonStr = jsonEncode(document.toJson());
      await _webdavService.uploadBytes(Uint8List.fromList(utf8.encode(jsonStr)), docRemotePath);

      // 2. Upload PDF if it exists locally
      if (document.localFilePath != null) {
        final localFile = File(document.localFilePath!);
        if (await localFile.exists()) {
          await _webdavService.uploadFile(localFile.path, pdfRemotePath);
        }
      }
      debugPrint('Document ${document.uuid} exported successfully');
    } catch (e) {
      debugPrint('Error exporting document ${document.uuid}: $e');
      rethrow;
    }
  }

  /// Sync all document metadata from the server
  Future<List<DocumentModel>> importMetadata() async {
    if (!_webdavService.isInitialized) {
      await _syncSettingsService.initializeFromSettings();
    }

    final settings = await _syncSettingsService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';
    final docsDir = '$pockardPath/documents';

    final remoteFiles = await _webdavService.listFiles(docsDir);
    final metadataFiles = remoteFiles.where((f) => f.endsWith('.json')).toList();

    List<DocumentModel> importedDocs = [];
    for (final fileName in metadataFiles) {
      try {
        final bytes = await _webdavService.downloadFile('$docsDir/$fileName');
        final jsonStr = utf8.decode(bytes);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        importedDocs.add(DocumentModel.fromJson(map));
      } catch (e) {
        debugPrint('Error importing metadata for $fileName: $e');
      }
    }
    return importedDocs;
  }

  /// Download the actual PDF file for a document
  Future<File?> downloadPdf(DocumentModel document) async {
    if (!_webdavService.isInitialized) {
      await _syncSettingsService.initializeFromSettings();
    }

    final settings = await _syncSettingsService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';
    final pdfRemotePath = '$pockardPath/documents/${document.uuid}.pdf';

    try {
      final bytes = await _webdavService.downloadFile(pdfRemotePath);
      
      // Save locally
      final appDocsDir = await getApplicationDocumentsDirectory();
      final docsFolder = Directory(p.join(appDocsDir.path, 'documents'));
      if (!await docsFolder.exists()) {
        await docsFolder.create(recursive: true);
      }

      final localFile = File(p.join(docsFolder.path, '${document.uuid}.pdf'));
      await localFile.writeAsBytes(bytes);
      
      debugPrint('Downloaded PDF for ${document.uuid}');
      return localFile;
    } catch (e) {
      debugPrint('Error downloading PDF for ${document.uuid}: $e');
      return null;
    }
  }

  /// Delete document from server
  Future<void> deleteRemoteDocument(String uuid) async {
    if (!_webdavService.isInitialized) {
      await _syncSettingsService.initializeFromSettings();
    }

    final settings = await _syncSettingsService.loadSettings();
    final pockardPath = settings?.pockardFolderPath ?? '/pockard';

    try {
      await _webdavService.deleteFile('$pockardPath/documents/$uuid.json');
      await _webdavService.deleteFile('$pockardPath/documents/$uuid.pdf');
    } catch (e) {
      debugPrint('Error deleting remote document $uuid: $e');
    }
  }
}
