import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/document_provider.dart';
import '../providers/display_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/document_grid_tile.dart';
import '../widgets/document_tile.dart';
import '../widgets/document_minimal_tile.dart';
import '../widgets/tag_chip.dart';
import 'document_detail_screen.dart';
import 'card_form_screen.dart';
import 'settings/settings_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(BuildContext context) async {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      
      final error = await provider.addDocument(file);
      
      if (!context.mounted) return;
      
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
            builder: (context) => CardFormScreen(document: doc),
          ),
        );
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
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.6)),
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                onChanged: (value) => documentProvider.setSearchQuery(value),
              )
            : Text(l10n.appName),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearchVisible) {
                  _searchController.clear();
                  documentProvider.setSearchQuery('');
                }
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => documentProvider.setSortBy(value),
            itemBuilder: (context) {
              final currentSort = documentProvider.sortBy;
              return [
                PopupMenuItem(
                  value: 'recent',
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.sortRecent, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      if (currentSort == 'recent') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 18, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.sortName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      if (currentSort == 'name') Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tags section
          if (documentProvider.allTags.isNotEmpty)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ? _buildEmptyState(context)
                : _buildDocumentsLayout(context, documentProvider.documents, displayProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'documents_fab',
        onPressed: () => _pickDocument(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDocumentsLayout(BuildContext context, List<dynamic> documents, DisplayProvider displayProvider) {
    switch (displayProvider.layoutMode) {
      case LayoutMode.rows:
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: DocumentTile(
                document: doc,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc))),
                onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(document: doc))),
              ),
            );
          },
        );
      case LayoutMode.minimal:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return DocumentMinimalTile(
              document: doc,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc))),
              onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(document: doc))),
            );
          },
        );
      case LayoutMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displayProvider.gridColumns,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: displayProvider.showGridNames ? 0.85 : 1.0,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return DocumentGridTile(
              document: doc,
              showName: displayProvider.showGridNames,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentDetailScreen(document: doc))),
              onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CardFormScreen(document: doc))),
            );
          },
        );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.noCardsFound, // Reusing existing localized string for "no items found"
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your important PDFs and documents here.', // Fallback subtitle
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _pickDocument(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addCard), // "Add" button
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          ),
        ],
      ),
    );
  }
}
