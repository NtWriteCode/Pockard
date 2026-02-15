import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/document_provider.dart';
import '../providers/display_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/document_grid_tile.dart';
import '../widgets/tag_chip.dart';
import 'document_detail_screen.dart';
import 'document_form_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final provider = Provider.of<DocumentProvider>(context, listen: false);
      
      final error = await provider.addDocument(file);
      
      if (mounted) {
        if (error == 'duplicate') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.duplicateFileError)),
          );
        } else if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        } else {
          // Success! Navigate to edit name/tags
          final doc = provider.documents.last; // The one we just added
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentFormScreen(document: doc),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final documentProvider = Provider.of<DocumentProvider>(context);
    final displayProvider = Provider.of<DisplayProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.search,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      documentProvider.setSearchQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (value) => documentProvider.setSearchQuery(value),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => documentProvider.setSortBy(value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'recent', child: Text(l10n.sortRecent)),
              PopupMenuItem(value: 'name', child: Text(l10n.sortName)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tags filter
          if (documentProvider.allTags.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: documentProvider.allTags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TagChip(
                        tag: l10n.filterAll,
                        isSelected: documentProvider.selectedTag.isEmpty,
                        onTap: () => documentProvider.setSelectedTag(''),
                      ),
                    );
                  }
                  final tag = documentProvider.allTags[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TagChip(
                      tag: tag,
                      isSelected: documentProvider.selectedTag == tag,
                      onTap: () => documentProvider.setSelectedTag(tag),
                    ),
                  );
                },
              ),
            ),

          // Documents list/grid
          Expanded(
            child: documentProvider.documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(l10n.noCardsFound, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  )
                : displayProvider.layoutMode == LayoutMode.grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: documentProvider.documents.length,
                        itemBuilder: (context, index) {
                          final doc = documentProvider.documents[index];
                          return DocumentGridTile(
                            document: doc,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc)),
                            ),
                            onLongPress: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DocumentFormScreen(document: doc)),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: documentProvider.documents.length,
                        itemBuilder: (context, index) {
                          final doc = documentProvider.documents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: doc.previewBase64 != null
                                      ? Image.memory(base64Decode(doc.previewBase64!), fit: BoxFit.cover)
                                      : const Icon(Icons.description_outlined),
                                ),
                              ),
                              title: Text(doc.name),
                              subtitle: doc.tags.isNotEmpty ? Text(doc.tags.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                              trailing: doc.isPinned ? Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary) : null,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDocument(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
