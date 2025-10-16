import 'package:flutter/material.dart';
import '../constants/barcode_types.dart';
import '../l10n/app_localizations.dart';

/// A pill-style barcode type selector widget
class BarcodeTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const BarcodeTypeSelector({super.key, required this.selectedType, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.barcodeTypeLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BarcodeTypes.supportedTypes.map((type) {
            final isSelected = selectedType == type['value'];
            return GestureDetector(
              onTap: () => onTypeChanged(type['value']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1),
                ),
                child: Text(
                  type['value'] == 'IMAGE_ONLY' ? l10n.imageOnlyLabel : type['label']!,
                  style: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
