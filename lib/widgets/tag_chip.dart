import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback onTap;

  const TagChip({super.key, required this.tag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
