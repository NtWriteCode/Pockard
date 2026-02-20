import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/card_model.dart';

class TagProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Category-specific tag lists
  final Map<CardCategory, List<String>> _orderedTagsByCategory = {
    CardCategory.loyalty: [],
    CardCategory.identity: [],
    CardCategory.document: [],
  };
  
  final Map<CardCategory, List<String>> _allTagsByCategory = {
    CardCategory.loyalty: [],
    CardCategory.identity: [],
    CardCategory.document: [],
  };
  
  bool _isLoading = false;

  // Legacy getters (for backward compatibility - returns all tags combined)
  List<String> get orderedTags {
    final allTags = <String>{};
    for (var tags in _orderedTagsByCategory.values) {
      allTags.addAll(tags);
    }
    return allTags.toList();
  }
  
  List<String> get allTags {
    final allTags = <String>{};
    for (var tags in _allTagsByCategory.values) {
      allTags.addAll(tags);
    }
    return allTags.toList();
  }
  
  // Category-specific getters
  List<String> getOrderedTags(CardCategory category) => _orderedTagsByCategory[category] ?? [];
  List<String> getAllTags(CardCategory category) => _allTagsByCategory[category] ?? [];
  
  bool get isLoading => _isLoading;

  Future<void> loadTags({CardCategory? category}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (category != null) {
        // Load tags for specific category
        await _loadTagsForCategory(category);
      } else {
        // Load tags for all categories
        for (var cat in CardCategory.values) {
          await _loadTagsForCategory(cat);
        }
      }
    } catch (e) {
      debugPrint('Error loading tags: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadTagsForCategory(CardCategory category) async {
    // Get all tags from cards for this category
    final allTags = await _databaseService.getAllTags(
      category: category,
      forDocuments: category == CardCategory.document
    );
    _allTagsByCategory[category] = allTags;

    // Get saved tag order for this category
    final savedOrder = await _databaseService.getTagOrder(category: category);

    // Create ordered list: saved order first, then remaining tags alphabetically
    final orderedTags = <String>[];

    // Add tags in saved order
    for (final tag in savedOrder) {
      if (allTags.contains(tag)) {
        orderedTags.add(tag);
      }
    }

    // Add remaining tags alphabetically
    final remainingTags = allTags.where((tag) => !orderedTags.contains(tag)).toList();
    remainingTags.sort();
    orderedTags.addAll(remainingTags);
    
    _orderedTagsByCategory[category] = orderedTags;
  }

  Future<void> reorderTags(int oldIndex, int newIndex, {required CardCategory category}) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final orderedTags = _orderedTagsByCategory[category] ?? [];
    if (oldIndex >= orderedTags.length || newIndex >= orderedTags.length) {
      return;
    }

    final tag = orderedTags.removeAt(oldIndex);
    orderedTags.insert(newIndex, tag);
    _orderedTagsByCategory[category] = orderedTags;
    notifyListeners();

    try {
      await _databaseService.saveTagOrder(orderedTags, category: category);
    } catch (e) {
      debugPrint('Error saving tag order: $e');
      // Revert on error
      await loadTags(category: category);
    }
  }

  int getTagUsageCount(String tag) {
    // This could be enhanced to track actual usage, for now return 0
    return 0;
  }

  /// Export tag order for syncing (all categories)
  Map<String, List<String>> exportTagOrder() {
    return {
      'loyalty': List<String>.from(_orderedTagsByCategory[CardCategory.loyalty] ?? []),
      'identity': List<String>.from(_orderedTagsByCategory[CardCategory.identity] ?? []),
      'document': List<String>.from(_orderedTagsByCategory[CardCategory.document] ?? []),
    };
  }

  /// Import tag order from sync
  Future<void> importTagOrder(Map<String, dynamic> tagOrder) async {
    try {
      // Import for each category
      if (tagOrder.containsKey('loyalty')) {
        final tags = List<String>.from(tagOrder['loyalty'] as List);
        _orderedTagsByCategory[CardCategory.loyalty] = tags;
        await _databaseService.saveTagOrder(tags, category: CardCategory.loyalty);
      }
      
      if (tagOrder.containsKey('identity')) {
        final tags = List<String>.from(tagOrder['identity'] as List);
        _orderedTagsByCategory[CardCategory.identity] = tags;
        await _databaseService.saveTagOrder(tags, category: CardCategory.identity);
      }
      
      if (tagOrder.containsKey('document')) {
        final tags = List<String>.from(tagOrder['document'] as List);
        _orderedTagsByCategory[CardCategory.document] = tags;
        await _databaseService.saveTagOrder(tags, category: CardCategory.document);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing tag order: $e');
      // Revert on error
      await loadTags();
    }
  }
  
  /// Legacy export for backward compatibility
  List<String> exportTagOrderLegacy() {
    return orderedTags;
  }
}
