import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dynamic_tag_input.dart';

class DocumentFormScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentFormScreen({super.key, required this.document});

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  late TextEditingController _nameController;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.document.name);
    _tags = List.from(widget.document.tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;

    final updatedDoc = widget.document.copyWith(
      name: _nameController.text,
      tags: _tags,
    );

    final success = await Provider.of<DocumentProvider>(context, listen: false).updateDocument(updatedDoc);
    if (mounted && success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editCard), // Reusing l10n for consistency
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.cardName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.tags, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DynamicTagInput(
              initialTags: _tags,
              onTagsChanged: (tags) => setState(() => _tags = tags),
              // We could pass available tags here if we want autocomplete
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
