import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/card_model.dart';
import '../models/document_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pockard.db');

    return await openDatabase(path, version: 6, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isDeleted column to existing cards table
      await db.execute('ALTER TABLE cards ADD COLUMN isDeleted INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      // Add isPinned column to existing cards table
      await db.execute('ALTER TABLE cards ADD COLUMN isPinned INTEGER DEFAULT 0');
    }
    if (oldVersion < 4) {
      // Add barcodeImagePath column to existing cards table
      await db.execute('ALTER TABLE cards ADD COLUMN barcodeImagePath TEXT');
    }
    if (oldVersion < 5) {
      // Add category and backImagePath columns to existing cards table
      await db.execute('ALTER TABLE cards ADD COLUMN category INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE cards ADD COLUMN backImagePath TEXT');
    }
    if (oldVersion < 6) {
      // Create documents table
      await db.execute('''
        CREATE TABLE documents(
          uuid TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          tags TEXT,
          previewBase64 TEXT,
          localFilePath TEXT,
          fileHash TEXT NOT NULL,
          fileSizeBytes INTEGER NOT NULL,
          creationDate INTEGER NOT NULL,
          updateDate INTEGER NOT NULL,
          isDeleted INTEGER DEFAULT 0,
          isPinned INTEGER DEFAULT 0
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cards table
    await db.execute('''
      CREATE TABLE cards(
        uuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tags TEXT,
        coverImagePath TEXT,
        backImagePath TEXT,
        creationDate INTEGER NOT NULL,
        updateDate INTEGER NOT NULL,
        usageCount INTEGER DEFAULT 0,
        barcodeData TEXT,
        barcodeType TEXT,
        barcodeImagePath TEXT,
        isDeleted INTEGER DEFAULT 0,
        isPinned INTEGER DEFAULT 0,
        category INTEGER DEFAULT 0
      )
    ''');

    // Documents table
    await db.execute('''
      CREATE TABLE documents(
        uuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tags TEXT,
        previewBase64 TEXT,
        localFilePath TEXT,
        fileHash TEXT NOT NULL,
        fileSizeBytes INTEGER NOT NULL,
        creationDate INTEGER NOT NULL,
        updateDate INTEGER NOT NULL,
        isDeleted INTEGER DEFAULT 0,
        isPinned INTEGER DEFAULT 0
      )
    ''');

    // Tags order table for settings
    await db.execute('''
      CREATE TABLE tag_order(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag TEXT NOT NULL UNIQUE,
        order_index INTEGER NOT NULL
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // Card CRUD operations
  Future<int> insertCard(CardModel card) async {
    final db = await database;
    return await db.insert('cards', card.toMap());
  }

  Future<List<CardModel>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards');
    return List.generate(maps.length, (i) => CardModel.fromMap(maps[i]));
  }

  Future<CardModel?> getCard(String uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards', where: 'uuid = ?', whereArgs: [uuid]);
    if (maps.isNotEmpty) {
      return CardModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCard(CardModel card) async {
    final db = await database;
    return await db.update('cards', card.toMap(), where: 'uuid = ?', whereArgs: [card.uuid]);
  }

  Future<int> deleteCard(String uuid) async {
    final db = await database;
    return await db.delete('cards', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<int> incrementCardUsage(String uuid) async {
    final db = await database;
    return await db.rawUpdate('UPDATE cards SET usageCount = usageCount + 1, updateDate = ? WHERE uuid = ?', [DateTime.now().millisecondsSinceEpoch, uuid]);
  }

  Future<int> resetAllStatistics() async {
    final db = await database;
    return await db.rawUpdate('UPDATE cards SET usageCount = 0');
  }

  Future<int> toggleCardPin(String uuid, bool isPinned) async {
    final db = await database;
    return await db.rawUpdate('UPDATE cards SET isPinned = ?, updateDate = ? WHERE uuid = ?', [isPinned ? 1 : 0, DateTime.now().millisecondsSinceEpoch, uuid]);
  }

  // Document CRUD operations
  Future<int> insertDocument(DocumentModel document) async {
    final db = await database;
    return await db.insert('documents', document.toMap());
  }

  Future<List<DocumentModel>> getAllDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) => DocumentModel.fromMap(maps[i]));
  }

  Future<DocumentModel?> getDocument(String uuid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents', where: 'uuid = ?', whereArgs: [uuid]);
    if (maps.isNotEmpty) {
      return DocumentModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDocument(DocumentModel document) async {
    final db = await database;
    return await db.update('documents', document.toMap(), where: 'uuid = ?', whereArgs: [document.uuid]);
  }

  Future<int> deleteDocument(String uuid) async {
    final db = await database;
    return await db.delete('documents', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<int> toggleDocumentPin(String uuid, bool isPinned) async {
    final db = await database;
    return await db.rawUpdate('UPDATE documents SET isPinned = ?, updateDate = ? WHERE uuid = ?', [isPinned ? 1 : 0, DateTime.now().millisecondsSinceEpoch, uuid]);
  }

  Future<List<DocumentModel>> searchDocuments(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return List.generate(maps.length, (i) => DocumentModel.fromMap(maps[i]));
  }

  Future<List<DocumentModel>> getDocumentsSorted(String sortBy) async {
    final db = await database;
    String orderBy;

    switch (sortBy) {
      case 'name':
        orderBy = 'name ASC';
        break;
      case 'recent':
      case 'date_added':
      default:
        orderBy = 'creationDate DESC';
    }

    final List<Map<String, dynamic>> maps = await db.query('documents', orderBy: orderBy);
    return List.generate(maps.length, (i) => DocumentModel.fromMap(maps[i]));
  }

  Future<List<DocumentModel>> getDocumentsByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents', where: 'tags LIKE ?', whereArgs: ['%$tag%']);
    return List.generate(maps.length, (i) => DocumentModel.fromMap(maps[i]));
  }

  // Search and filter operations
  Future<List<CardModel>> searchCards(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards', where: 'name LIKE ?', whereArgs: ['%$query%']);
    return List.generate(maps.length, (i) => CardModel.fromMap(maps[i]));
  }

  Future<List<CardModel>> getCardsByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cards', where: 'tags LIKE ?', whereArgs: ['%$tag%']);
    return List.generate(maps.length, (i) => CardModel.fromMap(maps[i]));
  }

  Future<List<CardModel>> getCardsSorted(String sortBy) async {
    final db = await database;
    String orderBy;

    switch (sortBy) {
      case 'usage':
        orderBy = 'usageCount DESC';
        break;
      case 'recent':
        orderBy = 'updateDate DESC';
        break;
      case 'name':
        orderBy = 'name ASC';
        break;
      case 'date_added':
        orderBy = 'creationDate DESC';
        break;
      default:
        orderBy = 'updateDate DESC';
    }

    final List<Map<String, dynamic>> maps = await db.query('cards', orderBy: orderBy);
    return List.generate(maps.length, (i) => CardModel.fromMap(maps[i]));
  }

  // Tag management
  Future<List<String>> getAllTags({CardCategory? category, bool forDocuments = false}) async {
    final db = await database;
    String table = forDocuments ? 'documents' : 'cards';
    String query = 'SELECT DISTINCT tags FROM $table WHERE tags IS NOT NULL AND tags != "" AND isDeleted = 0';
    List<dynamic> args = [];
    
    if (!forDocuments && category != null) {
      query += ' AND category = ?';
      args.add(category.index);
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

    Set<String> allTags = {};
    for (var map in maps) {
      String tagsString = map['tags'] ?? '';
      List<String> tags = tagsString.split(',').where((tag) => tag.trim().isNotEmpty).toList();
      allTags.addAll(tags.map((tag) => tag.trim()));
    }

    return allTags.toList()..sort();
  }

  Future<void> saveTagOrder(List<String> tags) async {
    final db = await database;

    // Clear existing order
    await db.delete('tag_order');

    // Insert new order
    for (int i = 0; i < tags.length; i++) {
      await db.insert('tag_order', {'tag': tags[i], 'order_index': i});
    }
  }

  Future<List<String>> getTagOrder() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tag_order', orderBy: 'order_index ASC');
    return maps.map((map) => map['tag'] as String).toList();
  }

  // Settings management
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
