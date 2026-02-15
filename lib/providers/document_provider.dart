import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document_model.dart';
import '../services/database_service.dart';
import '../services/document_sync_service.dart';

class DocumentProvider with ChangeNotifier {
  static const String _sortByKey = 'document_sort_by';

  final DatabaseService _databaseService = DatabaseService();
  final DocumentSyncService _syncService = DocumentSyncService();

  List<DocumentModel> _documents = [];
  List<String> _allTags = [];
  String _selectedTag = '';
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, name

  List<DocumentModel> get documents {
    List<DocumentModel> filtered = _documents.where((doc) => !doc.isDeleted).toList();

    if (_selectedTag.isNotEmpty) {
      filtered = filtered.where((doc) => doc.tags.contains(_selectedTag)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doc) => doc.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) {
          if (a.isPinned != b.isPinned) return b.isPinned ? 1 : -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 'recent':
      default:
        filtered.sort((a, b) {
          if (a.isPinned != b.isPinned) return b.isPinned ? 1 : -1;
          return b.creationDate.compareTo(a.creationDate);
        });
    }

    return filtered;
  }

  List<String> get allTags => _allTags;
  String get selectedTag => _selectedTag;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  Future<void> loadDocuments() async {
    try {
      _documents = await _databaseService.getAllDocuments();
      await _loadTags();
      await _loadSortPreference();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading documents: $e');
    }
  }

  Future<void> _loadSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sortBy = prefs.getString(_sortByKey) ?? 'recent';
    } catch (e) {
      debugPrint('Error loading sort preference: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      _allTags = await _databaseService.getAllTags(forDocuments: true);
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  /// Import a new PDF document.
  /// Handles hashing, duplicate detection, and thumbnail generation.
  Future<String?> addDocument(File pdfFile, {String? name, List<String>? tags}) async {
    try {
      // 1. Generate SHA-256 hash for duplicate detection
      final bytes = await pdfFile.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      // Check for duplicates
      if (_documents.any((doc) => doc.fileHash == hash && !doc.isDeleted)) {
        return 'duplicate';
      }

      // 2. Generate thumbnail (Base64) using pdfrx
      String? previewBase64;
      try {
        final document = await PdfDocument.openFile(pdfFile.path);
        final page = document.pages[0]; // Page 1
        final image = await page.render(
          width: 480, // Target width as per plan
        );
        if (image != null) {
          final uiImage = await image.createImage();
          final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            previewBase64 = base64Encode(byteData.buffer.asUint8List());
          }
          image.dispose();
        }
        await document.dispose();
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }

      // 3. Copy file to local storage
      final appDocsDir = await getApplicationDocumentsDirectory();
      final docsFolder = Directory(p.join(appDocsDir.path, 'documents'));
      if (!await docsFolder.exists()) {
        await docsFolder.create(recursive: true);
      }

      final fileName = p.basename(pdfFile.path);
      final localPath = p.join(docsFolder.path, fileName);
      await pdfFile.copy(localPath);

      // 4. Create model and save to DB
      final newDoc = DocumentModel(
        name: name ?? p.basenameWithoutExtension(pdfFile.path),
        tags: tags ?? [],
        previewBase64: previewBase64,
        localFilePath: localPath,
        fileHash: hash,
        fileSizeBytes: bytes.length,
      );

      await _databaseService.insertDocument(newDoc);
      _documents.add(newDoc);
      await _loadTags();
      notifyListeners();

      _autoSync();
      return null; // Success
    } catch (e) {
      debugPrint('Error adding document: $e');
      return e.toString();
    }
  }

  Future<bool> updateDocument(DocumentModel document) async {
    try {
      await _databaseService.updateDocument(document);
      final index = _documents.indexWhere((doc) => doc.uuid == document.uuid);
      if (index != -1) {
        _documents[index] = document;
      }
      await _loadTags();
      notifyListeners();
      _autoSync();
      return true;
    } catch (e) {
      debugPrint('Error updating document: $e');
      return false;
    }
  }

  Future<bool> togglePin(String uuid) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);
      if (index != -1) {
        final newPinState = !_documents[index].isPinned;
        await _databaseService.toggleDocumentPin(uuid, newPinState);
        _documents[index] = _documents[index].copyWith(isPinned: newPinState);
        notifyListeners();
        _autoSync();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling pin: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String uuid) async {
    try {
      final index = _documents.indexWhere((doc) => doc.uuid == uuid);
      if (index == -1) return false;

      final doc = _documents[index];
      final deletedDoc = doc.copyWith(isDeleted: true);
      _documents[index] = deletedDoc;

      await _databaseService.updateDocument(deletedDoc);
      await _loadTags();
      notifyListeners();
      _autoSync();
      return true;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }

  Future<void> _autoSync() async {
    try {
      // 1. Export all documents (meta + PDF if new)
      for (final doc in _documents) {
        await _syncService.exportDocument(doc);
      }

      // 2. Import metadata from other devices
      final importedMeta = await _syncService.importMetadata();
      for (final doc in importedMeta) {
        final existing = _documents.indexWhere((d) => d.uuid == doc.uuid);
        if (existing == -1) {
          await _databaseService.insertDocument(doc);
          _documents.add(doc);
        } else {
          // Check for updates (hash or updateDate)
          if (doc.updateDate.isAfter(_documents[existing].updateDate)) {
            await _databaseService.updateDocument(doc);
            _documents[existing] = doc;
          }
        }
      }
      await _loadTags();
      notifyListeners();
    } catch (e) {
      debugPrint('Document auto-sync failed: $e');
    }
  }

  void setSelectedTag(String tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setSortBy(String sortBy) async {
    _sortBy = sortBy;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortByKey, sortBy);
    } catch (e) {
      debugPrint('Error saving sort preference: $e');
    }
  }
}
