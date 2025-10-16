import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class TagProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<String> _orderedTags = [];
  List<String> _allTags = [];
  bool _isLoading = false;

  List<String> get orderedTags => _orderedTags;
  List<String> get allTags => _allTags;
  bool get isLoading => _isLoading;

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get all tags from cards
      _allTags = await _databaseService.getAllTags();

      // Get saved tag order
      final savedOrder = await _databaseService.getTagOrder();

      // Create ordered list: saved order first, then remaining tags alphabetically
      _orderedTags = [];

      // Add tags in saved order
      for (final tag in savedOrder) {
        if (_allTags.contains(tag)) {
          _orderedTags.add(tag);
        }
      }

      // Add remaining tags alphabetically
      final remainingTags = _allTags.where((tag) => !_orderedTags.contains(tag)).toList();
      remainingTags.sort();
      _orderedTags.addAll(remainingTags);
    } catch (e) {
      debugPrint('Error loading tags: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reorderTags(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final tag = _orderedTags.removeAt(oldIndex);
    _orderedTags.insert(newIndex, tag);
    notifyListeners();

    try {
      await _databaseService.saveTagOrder(_orderedTags);
    } catch (e) {
      debugPrint('Error saving tag order: $e');
      // Revert on error
      await loadTags();
    }
  }

  int getTagUsageCount(String tag) {
    // This could be enhanced to track actual usage, for now return 0
    return 0;
  }

  /// Export tag order for syncing
  List<String> exportTagOrder() {
    return List<String>.from(_orderedTags);
  }

  /// Import tag order from sync
  Future<void> importTagOrder(List<String> tagOrder) async {
    try {
      // Update ordered tags
      _orderedTags = List<String>.from(tagOrder);

      // Save to database
      await _databaseService.saveTagOrder(_orderedTags);

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing tag order: $e');
      // Revert on error
      await loadTags();
    }
  }
}
