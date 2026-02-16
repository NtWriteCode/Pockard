import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:open_filex/open_filex.dart';
import '../models/document_model.dart';
import '../providers/document_provider.dart';
import '../services/document_sync_service.dart';
import '../l10n/app_localizations.dart';
import 'card_form_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool _isDownloading = false;

  Future<void> _openPdf(BuildContext context) async {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    
    File? pdfFile;
    if (widget.document.localFilePath != null) {
      pdfFile = File(widget.document.localFilePath!);
    }

    if (pdfFile == null || !await pdfFile.exists()) {
      setState(() => _isDownloading = true);
      try {
        final syncService = DocumentSyncService();
        pdfFile = await syncService.downloadPdf(widget.document);
        if (pdfFile != null) {
          // Update local path in DB
          await provider.updateDocument(widget.document.copyWith(localFilePath: pdfFile.path));
        }
      } finally {
        if (mounted) setState(() => _isDownloading = false);
      }
    }

    if (pdfFile != null && await pdfFile.exists()) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(file: pdfFile!, title: widget.document.name),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    }
  }

  Future<void> _openPdfExternally(BuildContext context) async {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    
    File? pdfFile;
    if (widget.document.localFilePath != null) {
      pdfFile = File(widget.document.localFilePath!);
    }

    if (pdfFile == null || !await pdfFile.exists()) {
      setState(() => _isDownloading = true);
      try {
        final syncService = DocumentSyncService();
        pdfFile = await syncService.downloadPdf(widget.document);
        if (pdfFile != null) {
          await provider.updateDocument(widget.document.copyWith(localFilePath: pdfFile.path));
        }
      } finally {
        if (mounted) setState(() => _isDownloading = false);
      }
    }

    if (pdfFile != null && await pdfFile.exists()) {
      await OpenFilex.open(pdfFile.path);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use a watch here to catch updates (like name changes) if we return from edit screen
    final doc = context.watch<DocumentProvider>().documents.firstWhere(
          (d) => d.uuid == widget.document.uuid,
          orElse: () => widget.document,
        );
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.name),
        actions: [
          IconButton(
            icon: Icon(doc.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => context.read<DocumentProvider>().togglePin(doc.uuid),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CardFormScreen(document: doc)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, doc),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large Preview
            GestureDetector(
              onTap: _isDownloading ? null : () => _openPdf(context),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: doc.previewBase64 != null
                        ? Image.memory(base64Decode(doc.previewBase64!), fit: BoxFit.cover)
                        : Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.description_outlined, size: 80),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Open Button
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : () => _openPdf(context),
              icon: _isDownloading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isDownloading ? 'Downloading...' : 'View in Pockard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _isDownloading ? null : () => _openPdfExternally(context),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text(
                  'Open in external app',
                  style: TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata
            _buildInfoRow(context, Icons.tag, l10n.tags, doc.tags.isEmpty ? 'None' : doc.tags.join(', ')),
            _buildInfoRow(context, Icons.straighten, 'Size', '${(doc.fileSizeBytes / 1024 / 1024).toStringAsFixed(2)} MB'),
            _buildInfoRow(context, Icons.calendar_today, 'Added', dateFormat.format(doc.creationDate)),
            _buildInfoRow(context, Icons.history, 'Modified', dateFormat.format(doc.updateDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Document?'),
        content: Text('This will remove the document from your list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DocumentProvider>().deleteDocument(doc.uuid);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit detail screen
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final File file;
  final String title;

  const PdfViewerScreen({super.key, required this.file, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PdfViewPinch(
        controller: _pdfController,
      ),
    );
  }
}
