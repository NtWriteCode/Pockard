import 'package:flutter/material.dart';

class DynamicTagInput extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onTagsChanged;
  final String? hintText;
  final List<String> availableTags; // Existing tags from all cards

  const DynamicTagInput({super.key, required this.initialTags, required this.onTagsChanged, this.hintText, this.availableTags = const []});

  @override
  State<DynamicTagInput> createState() => _DynamicTagInputState();
}

class _DynamicTagInputState extends State<DynamicTagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _tags = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _updateSuggestions(String input) {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Filter available tags that match the input (case-insensitive)
    // and exclude already added tags
    final filtered = widget.availableTags.where((tag) => tag.toLowerCase().contains(input.toLowerCase()) && !_tags.contains(tag)).toList();

    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _handleTextChange(String text) {
    // Update suggestions based on current input
    _updateSuggestions(text);

    // Check for dividing characters: comma, semicolon, space, enter
    final dividers = [',', ';', ' ', '\n'];

    for (String divider in dividers) {
      if (text.contains(divider)) {
        final parts = text.split(divider);
        if (parts.isNotEmpty && parts.first.trim().isNotEmpty) {
          _addTag(parts.first.trim());

          // Set remaining text (if any) back to controller
          final remainingText = parts.length > 1 ? parts.sublist(1).join(divider).trim() : '';
          _controller.text = remainingText;
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: remainingText.length));
          _updateSuggestions(remainingText);
        } else {
          _controller.clear();
          _updateSuggestions('');
        }
        return;
      }
    }
  }

  void _selectSuggestion(String tag) {
    _addTag(tag);
    _controller.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _focusNode.requestFocus();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      widget.onTagsChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Existing tags as pills
                if (_tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _removeTag(tag),
                              child: Icon(Icons.close, size: 14, color: Theme.of(context).primaryColor.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Text input for new tags
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: _handleTextChange,
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _addTag(text.trim());
                      _controller.clear();
                      _updateSuggestions('');
                    }
                  },
                ),
              ],
            ),
          ),

          // Suggestions dropdown
          if (_showSuggestions && _suggestions.isNotEmpty) _buildSuggestionsDropdown(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return InkWell(
            onTap: () => _selectSuggestion(suggestion),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.label_outline, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(suggestion, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
