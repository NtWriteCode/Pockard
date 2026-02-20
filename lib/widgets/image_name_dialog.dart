import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Dialog for entering an image name when sharing globally.
///
/// Returns the entered name as a [String], or null if cancelled.
class ImageNameDialog extends StatefulWidget {
  const ImageNameDialog({super.key});

  @override
  State<ImageNameDialog> createState() => _ImageNameDialogState();
}

class _ImageNameDialogState extends State<ImageNameDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.shareImageGlobally),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.enterImageName),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.imageNameHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.share),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
